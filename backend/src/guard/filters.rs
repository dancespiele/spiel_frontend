use super::{auth_guard, get_nonce, login, verify_signature, SessionDto, SignatureDto};
use sled::Db;
use std::sync::Arc;
use tokio::sync::Mutex;
use warp::{Filter, Rejection, Reply};

pub fn auth(
    tree: impl Filter<Extract = (Arc<Mutex<Db>>,), Error = Rejection> + Clone + Send,
) -> impl Filter<Extract = (SessionDto,), Error = Rejection> + Clone {
    warp::header::<String>("Authorization")
        .and(tree)
        .and_then(auth_guard)
}

#[utoipa::path(
    post,
    path = "/login",
    params(SignatureDto),
    responses(
        (status = 200, description = "Session token", body = [&str])
    )
)]
pub fn session_login(
    tree: impl Filter<Extract = (Arc<Mutex<Db>>,), Error = Rejection> + Clone + Send,
) -> impl Filter<Extract = impl Reply, Error = Rejection> + Clone {
    warp::path("login").and(
        warp::post()
            .and(tree)
            .and(warp::body::json())
            .and_then(verify_signature)
            .and_then(login),
    )
}

#[utoipa::path(
    get,
    path = "/nonce/{address}",
    params(
        ("address" = String, Path, description = "Address account to get nonce for")
    ),
    responses(
        (status = 200, description = "Session token", body = [&str]),
    )
)]
pub fn nonce(
    tree: impl Filter<Extract = (Arc<Mutex<Db>>,), Error = Rejection> + Clone + Send,
) -> impl Filter<Extract = impl Reply, Error = Rejection> + Clone {
    warp::path("nonce").and(
        warp::get()
            .and(tree)
            .and(warp::path::param())
            .and_then(get_nonce),
    )
}
