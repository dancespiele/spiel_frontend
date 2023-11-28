use chrono::prelude::*;
use chrono::Duration;
use hex::encode;
use std::ops::Add;
use utoipa::ToSchema;

#[derive(Debug, Serialize, Deserialize, ToSchema)]
pub struct SignatureDto {
    /// Message to sign
    #[schema(example = "Hello, world!")]
    pub message: String,
    #[schema(example = "12345678901234567890")]
    pub signature: String,
}

#[derive(Debug, Serialize, Deserialize, ToSchema)]
pub struct Claims {
    #[schema(example = "12345678901234567")]
    pub sub: String,
    #[schema(example = "0x2Ac9180390a96FBc9532384E13E96ba7CB427403")]
    pub iss: String,
    #[schema(example = "1646186948")]
    pub iat: i64,
    #[schema(example = "1646186948")]
    pub exp: i64,
}

#[derive(Debug, Clone, Deserialize, ToSchema)]
pub struct SessionDto {
    #[schema(example = "0x2Ac9180390a96FBc9532384E13E96ba7CB427403")]
    pub address: String,
    #[schema(example = "12345678901234567")]
    pub nonce: String,
}

impl From<([u8; 20], String)> for SessionDto {
    fn from(value: ([u8; 20], String)) -> Self {
        let (address, nonce) = value;

        SessionDto {
            address: encode(address),
            nonce,
        }
    }
}

impl From<SessionDto> for Claims {
    fn from(account: SessionDto) -> Self {
        let expire_token: DateTime<Utc> = Utc::now() + Duration::days(1);

        Claims {
            sub: account.nonce,
            iss: String::from("0x").add(&account.address),
            iat: Utc::now().timestamp(),
            exp: expire_token.timestamp(),
        }
    }
}

impl From<Claims> for SessionDto {
    fn from(claims: Claims) -> Self {
        SessionDto {
            address: claims.iss,
            nonce: claims.sub,
        }
    }
}
