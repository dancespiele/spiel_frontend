use super::packtingo_handlers::*;
use crate::db::Pool;
use crate::guard::auth;
use sled::Db;
use std::sync::Arc;
use tokio::sync::Mutex;
use warp::{Filter, Rejection, Reply};

pub fn score(
    tree: impl Filter<Extract = (Arc<Mutex<Db>>,), Error = Rejection> + Clone + Send,
    pool: impl Filter<Extract = (Arc<Mutex<Pool>>,), Error = Rejection> + Clone + Send,
) -> impl Filter<Extract = impl Reply, Error = Rejection> + Clone {
    warp::path("score").and(
        warp::post()
            .and(auth(tree.clone()))
            .and(pool.clone())
            .and(warp::body::json())
            .and_then(create_score)
            .or(warp::get()
                .and(pool)
                .and(warp::path::param())
                .and_then(get_score)),
    )
}

pub fn prize(
    tree: impl Filter<Extract = (Arc<Mutex<Db>>,), Error = Rejection> + Clone + Send,
    pool: impl Filter<Extract = (Arc<Mutex<Pool>>,), Error = Rejection> + Clone + Send,
) -> impl Filter<Extract = impl Reply, Error = Rejection> + Clone {
    warp::path("prize").and(
        warp::put()
            .and(auth(tree.clone()))
            .and(pool.clone())
            .and(warp::path::param())
            .and_then(update_withdraw_prize)
            .or(warp::get()
                .and(auth(tree))
                .and(pool.clone())
                .and_then(get_prizes)),
    )
}

pub fn prize_requested(
    tree: impl Filter<Extract = (Arc<Mutex<Db>>,), Error = Rejection> + Clone + Send,
    pool: impl Filter<Extract = (Arc<Mutex<Pool>>,), Error = Rejection> + Clone + Send,
) -> impl Filter<Extract = impl Reply, Error = Rejection> + Clone {
    warp::path("prize_requested").and(
        warp::put()
            .and(auth(tree.clone()))
            .and(pool.clone())
            .and(warp::body::json())
            .and_then(update_request_id_prize),
    )
}
