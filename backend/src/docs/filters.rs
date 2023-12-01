use super::{serve_swagger, ApiDoc};
use std::sync::Arc;
use utoipa::OpenApi;
use utoipa_swagger_ui::Config;
use warp::{Filter, Rejection, Reply};

pub fn api_doc() -> impl Filter<Extract = impl Reply, Error = Rejection> + Clone {
    warp::path("api-doc.json")
        .and(warp::get())
        .map(|| warp::reply::json(&ApiDoc::openapi()))
}

pub fn swagger_ui() -> impl Filter<Extract = impl Reply, Error = Rejection> + Clone {
    let config = Arc::new(Config::from("/api-doc.json"));
    warp::path("swagger-ui")
        .and(warp::get())
        .and(warp::path::full())
        .and(warp::path::tail())
        .and(warp::any().map(move || config.clone()))
        .and_then(serve_swagger)
}
