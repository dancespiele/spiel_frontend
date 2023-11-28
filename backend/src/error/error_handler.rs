use super::{
    BadRequest, BufError, ConvertToString, DbError, EnvError, Forbidden, HashPwdError, HexError,
    JwtError, NotFound, TransformError, TreeError, VerifySignatureError,
};
use std::convert::Infallible;
use warp::http::StatusCode;
use warp::{
    body::BodyDeserializeError,
    reject::{MissingHeader, Rejection},
    reply, Error, Reply,
};

#[derive(Serialize)]
struct ErrorMessage {
    code: u16,
    message: String,
}

pub async fn error_handler(err: Rejection) -> Result<impl Reply, Infallible> {
    let code;
    let message: String;

    if err.is_not_found() {
        code = StatusCode::NOT_FOUND;
        message = "NOT FOUND".to_string();
        error!("not found: {:#?}", err);
    } else if let Some(not_found) = err.find::<NotFound>() {
        code = StatusCode::NOT_FOUND;
        message = format!("Not found error: {:#?}", not_found);
        error!("{}", message);
    } else if let Some(buf_error) = err.find::<BufError>() {
        code = StatusCode::INTERNAL_SERVER_ERROR;
        message = "INTERNAL SERVER ERROR".to_string();
        error!("Buf error: {:#?}", buf_error.error);
    } else if let Some(missing_header) = err.find::<MissingHeader>() {
        code = StatusCode::BAD_REQUEST;
        message = format!("Missing header error: {:#?}", missing_header);
        error!("{}", message);
    } else if let Some(forbidden_error) = err.find::<Forbidden>() {
        code = StatusCode::FORBIDDEN;
        message = format!("Forbidden error: {}", forbidden_error.error);
        error!("{}", message);
    } else if let Some(bad_request) = err.find::<BadRequest>() {
        code = StatusCode::BAD_REQUEST;
        message = format!("Bad request: {}", bad_request.error);
        error!("{}", message);
    } else if let Some(jwt_error) = err.find::<JwtError>() {
        code = StatusCode::FORBIDDEN;
        message = format!("Token error: {}", jwt_error.error);
        error!("{}", message);
    } else if let Some(hash_pwd_error) = err.find::<HashPwdError>() {
        code = StatusCode::INTERNAL_SERVER_ERROR;
        message = format!("Error hashing password: {}", hash_pwd_error.error);
        error!("{}", message);
    } else if let Some(sled_error) = err.find::<TreeError>() {
        code = StatusCode::INTERNAL_SERVER_ERROR;
        message = format!("Sled error: {}", sled_error.error);
        error!("{}", message);
    } else if let Some(serde_json_error) = err.find::<TransformError>() {
        code = StatusCode::INTERNAL_SERVER_ERROR;
        message = format!("Serde json error: {}", serde_json_error.error);
        error!("{}", message);
    } else if let Some(warp_error) = err.find::<Error>() {
        code = StatusCode::INTERNAL_SERVER_ERROR;
        message = format!("Warp error: {}", warp_error);
        error!("{}", message);
    } else if let Some(body_error) = err.find::<BodyDeserializeError>() {
        code = StatusCode::BAD_REQUEST;
        message = format!("{}", body_error);
        error!("{}", message);
    } else if let Some(conver_to_string) = err.find::<ConvertToString>() {
        code = StatusCode::INTERNAL_SERVER_ERROR;
        message = format!("error converting to string: {}", conver_to_string.error);
        error!("{}", message);
    } else if let Some(verification_error) = err.find::<VerifySignatureError>() {
        code = StatusCode::FORBIDDEN;
        message = format!("Verification error: {}", verification_error.error);
        error!("{}", message);
    } else if let Some(from_hex_error) = err.find::<HexError>() {
        code = StatusCode::INTERNAL_SERVER_ERROR;
        message = format!("From hex error: {}", from_hex_error.error);
        error!("{}", message);
    } else if let Some(env_error) = err.find::<EnvError>() {
        code = StatusCode::INTERNAL_SERVER_ERROR;
        message = format!("Env error: {}", env_error.error);
        error!("{}", message);
    } else if let Some(db_error) = err.find::<DbError>() {
        code = StatusCode::INTERNAL_SERVER_ERROR;
        message = format!("Database error: {}", db_error.error);
        error!("{}", message);
    } else {
        code = StatusCode::INTERNAL_SERVER_ERROR;
        message = "UNHANDLE REJECTION".to_string();
        error!("unhandler rejection: {:#?}", err);
    }

    let json = reply::json(&ErrorMessage {
        code: code.as_u16(),
        message,
    });

    Ok(reply::with_status(json, code))
}
