use anyhow::Error as AnyError;
use bcrypt::BcryptError;
use hex::FromHexError;
use jsonwebtoken::errors::Error as ErrorToken;
use serde_json::error::Error as SerdeError;
use siwe::VerificationError;
use sled::Error as SledError;
use std::env::VarError;
use std::str::Utf8Error;
use warp::{reject::Reject, Error as WarpError};

#[derive(Debug)]
pub struct JwtError {
    pub error: ErrorToken,
}

impl Reject for JwtError {}

#[derive(Debug)]
pub struct BadRequest {
    pub error: String,
}

impl<'a> Reject for BadRequest {}

#[derive(Debug)]
pub struct Forbidden {
    pub error: String,
}

impl Reject for Forbidden {}

#[derive(Debug)]
pub struct NotFound {
    pub error: String,
}

impl Reject for NotFound {}

#[derive(Debug)]
pub struct HashPwdError {
    pub error: BcryptError,
}

impl Reject for HashPwdError {}

#[derive(Debug)]
pub struct TreeError {
    pub error: SledError,
}

impl Reject for TreeError {}

#[derive(Debug)]
pub struct VerifySignatureError {
    pub error: VerificationError,
}

impl Reject for VerifySignatureError {}

#[derive(Debug)]
pub struct TransformError {
    pub error: SerdeError,
}

impl Reject for TransformError {}

#[derive(Debug)]
pub struct BufError {
    pub error: WarpError,
}

impl Reject for BufError {}

#[derive(Debug)]
pub struct ConvertToString {
    pub error: Utf8Error,
}

impl Reject for ConvertToString {}

#[derive(Debug)]
pub struct HexError {
    pub error: FromHexError,
}

impl Reject for HexError {}

#[derive(Debug)]
pub struct EnvError {
    pub error: VarError,
}

impl Reject for EnvError {}

#[derive(Debug)]
pub struct CustomError {
    pub error: AnyError,
}

impl Reject for CustomError {}
