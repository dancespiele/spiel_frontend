use sled::{Db, Error as DbError};
use std::env;
use std::sync::Arc;
use tokio::sync::Mutex;
use warp::{filters::BoxedFilter, Filter};

type TreeBoxed = Result<BoxedFilter<(Arc<Mutex<Db>>,)>, Box<DbError>>;

pub fn init_tree() -> TreeBoxed {
    let sled_url = env::var("SLED_URL").expect("SLED_URL must be provided");
    let tree = sled::open(&sled_url)?;

    Ok(warp::any()
        .map(move || Arc::new(Mutex::new(tree.clone())))
        .boxed())
}
