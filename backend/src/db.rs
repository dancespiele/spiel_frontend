use diesel::{
    r2d2::{Builder, ConnectionManager, Error as PgError, Pool as StartPool},
    PgConnection,
};
use sled::{Db, Error as DbError};
use std::env;
use std::sync::Arc;
use tokio::sync::Mutex;
use warp::{filters::BoxedFilter, Filter};

pub type Pool = StartPool<ConnectionManager<PgConnection>>;

pub type PoolBoxed = Result<BoxedFilter<(Arc<Mutex<Pool>>,)>, Box<PgError>>;

pub fn init_pool() -> PoolBoxed {
    let url = env::var("URL_DB").expect("URL_DB");
    let manager = ConnectionManager::<PgConnection>::new(url);

    let builder = Builder::new();
    let pool = builder.build(manager).unwrap();

    Ok(warp::any()
        .map(move || Arc::new(Mutex::new(pool.clone())))
        .boxed())
}

type TreeBoxed = Result<BoxedFilter<(Arc<Mutex<Db>>,)>, Box<DbError>>;

pub fn init_tree() -> TreeBoxed {
    let sled_url = env::var("SLED_URL").expect("SLED_URL must be provided");
    let tree = sled::open(&sled_url)?;

    Ok(warp::any()
        .map(move || Arc::new(Mutex::new(tree.clone())))
        .boxed())
}
