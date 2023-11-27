use super::{Claims, SessionDto, SignatureDto};
use crate::error::ConvertToString;
use crate::error::{CustomError, EnvError, HexError, JwtError, TreeError, VerifySignatureError};
use anyhow::Error;
use hex::{FromHex, ToHex};
use jsonwebtoken::{decode, encode, DecodingKey, EncodingKey, Header, Validation};
use siwe::{generate_nonce, Message, VerificationOpts};
use sled::Db;
use std::env;
use std::str;
use std::sync::Arc;
use tokio::sync::Mutex;
use warp::{reject, reply, Rejection, Reply};

pub async fn verify_signature(
    tree: Arc<Mutex<Db>>,
    signature_dto: SignatureDto,
) -> Result<SessionDto, Rejection> {
    let message: Message = signature_dto.message.parse().unwrap();
    let sig = <[u8; 65]>::from_hex(signature_dto.signature.trim_start_matches("0x"))
        .map_err(|err| reject::custom(HexError { error: err }))?;
    let frontend_domain =
        env::var("FRONTEND_DOMAIN").map_err(|err| reject::custom(EnvError { error: err }))?;

    let db = tree.lock().await;

    let address = message.address.encode_hex::<String>().to_lowercase();

    let nonce = db
        .get(&address)
        .map_err(|err| reject::custom(TreeError { error: err }))?
        .ok_or_else(reject::not_found)?;

    let nonde_str =
        str::from_utf8(&nonce).map_err(|err| reject::custom(ConvertToString { error: err }))?;

    let verification_opt = VerificationOpts {
        domain: Some(frontend_domain.parse().unwrap()),
        nonce: Some(nonde_str.to_string()),
        ..Default::default()
    };

    if let Err(e) = message.verify(&sig, &verification_opt).await {
        return Err(reject::custom(VerifySignatureError { error: e }));
    };

    Ok(SessionDto::from((message.address, message.nonce)))
}

pub async fn login(account: SessionDto) -> Result<impl Reply, Rejection> {
    let secret = env::var("SECRET").expect("SECRET must be set");

    let claims: Claims = Claims::from(account);

    let token = encode(
        &Header::default(),
        &claims,
        &EncodingKey::from_secret(secret.as_ref()),
    )
    .map_err(|err| reject::custom(JwtError { error: err }))?;

    Ok(reply::json(&token))
}

pub async fn get_nonce(tree: Arc<Mutex<Db>>, address: String) -> Result<impl Reply, Rejection> {
    let nonce = generate_nonce();

    let db = tree.lock().await;

    let addr = address.trim_start_matches("0x").to_lowercase();

    db.insert(addr, nonce.as_bytes())
        .map_err(|err| reject::custom(TreeError { error: err }))?;

    Ok(reply::json(&nonce))
}

pub async fn auth_guard(auth_token: String, tree: Arc<Mutex<Db>>) -> Result<SessionDto, Rejection> {
    let secret = env::var("SECRET").expect("SECRET must be set");

    let token = decode::<Claims>(
        &auth_token,
        &DecodingKey::from_secret(secret.as_ref()),
        &Validation::default(),
    )
    .map_err(|err| reject::custom(JwtError { error: err }))?;

    let db = tree.lock().await;

    let address = token.claims.iss.trim_start_matches("0x").to_lowercase();

    let nonce_db = db
        .get(&address)
        .map_err(|err| reject::custom(TreeError { error: err }))?;

    if let Some(nonce) = nonce_db {
        if nonce != token.claims.sub {
            return Err(reject::custom(CustomError {
                error: Error::msg("The nonce of the session doesn't match with the auth token"),
            }));
        }
    }

    let user = SessionDto::from(token.claims);

    Ok(user)
}
