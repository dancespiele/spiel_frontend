use std::env;
use std::net::SocketAddr;
use warp::filters::fs::File;
use warp::Filter;

type ResponseWithHeader = warp::reply::WithHeader<
    warp::reply::WithHeader<
        warp::reply::WithHeader<warp::reply::WithHeader<warp::reply::WithHeader<warp::fs::File>>>,
    >,
>;

fn add_headers(dir: File) -> ResponseWithHeader {
    let reply_cross_embedder =
        warp::reply::with_header(dir, "Cross-Origin-Embedder-Policy", "require-corp");
    let reply_cross_opener = warp::reply::with_header(
        reply_cross_embedder,
        "Cross-Origin-Opener-Policy",
        "same-origin",
    );
    let reply_cache_control = warp::reply::with_header(
        reply_cross_opener,
        "Cache-Control",
        "no-store, no-cache, must-revalidate, max-age=0",
    );

    let reply_pragma = warp::reply::with_header(reply_cache_control, "Pragma", "no-cache");
    let reply = warp::reply::with_header(reply_pragma, "Expires", "0");

    reply
}

#[tokio::main]
async fn main() {
    pretty_env_logger::init();

    let server_url = env::var("WEB_SERVER_URL").expect("SERVER_URL must be set");
    let key_cert = env::var("KEY_CERT").expect("KEY_CERT must be set");
    let file_cert = env::var("FILE_CERT").expect("FILE_CERT must be set");
    let addr: SocketAddr = server_url.parse().unwrap();

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

    let routes = warp::any()
        .and(warp::fs::dir("web"))
        .map(add_headers)
        .with(cors);

    warp::serve(routes)
        .tls()
        .cert_path(&file_cert)
        .key_path(&key_cert)
        .run(addr)
        .await;
}
