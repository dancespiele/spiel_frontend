#[macro_use]
extern crate serde;
#[macro_use]
extern crate log;
#[macro_use]
extern crate diesel;

mod db;
mod docs;
mod error;
mod guard;
mod packtingo;
mod schema;

use db::{init_pool, init_tree};
use docs::{api_doc, swagger_ui};
use error::error_handler;
use guard::{nonce, session_login};
use packtingo::{prize, prize_requested, score};
use std::env;
use std::net::SocketAddr;
use warp::Filter;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    pretty_env_logger::init();

    let key_cert = env::var("KEY_CERT").expect("KEY_CERT must be set");
    let file_cert = env::var("FILE_CERT").expect("FILE_CERT must be set");
    let server_url = env::var("SERVER_URL").expect("SERVER_URL must be set");
    let addr: SocketAddr = server_url.parse().unwrap();
    let tree = init_tree().expect("Failed to initialize sled");
    let pool = init_pool().expect("Failed to initialize pg");

    let cors = warp::cors()
        .allow_any_origin()
        .allow_headers(vec![
            "authorization",
            "User-Agent",
            "access-control-allow-origin",
            "Sec-Fetch-Mode",
            "Referer",
            "Origin",
            "Access-Control-Request-Method",
            "content-type",
            "Access-Control-Request-Headers",
        ])
        .allow_methods(vec!["POST", "GET", "PUT", "PATCH", "DELETE"]);

    let routes = session_login(tree.clone())
        .or(nonce(tree.clone()))
        .or(score(tree.clone(), pool.clone()))
        .or(prize(tree.clone(), pool.clone()))
        .or(prize_requested(tree, pool))
        .or(api_doc())
        .or(swagger_ui())
        .recover(error_handler)
        .with(cors);

    warp::serve(routes)
        .tls()
        .cert_path(&file_cert)
        .key_path(&key_cert)
        .run(addr)
        .await;

    Ok(())
}
