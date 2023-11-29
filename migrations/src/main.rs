extern crate barrel;
extern crate dotenv;
extern crate postgres;
extern crate refinery;

mod migrations;
mod rollback;

use migrations::{get_migrations, get_rollback_migrations};
use postgres::{Client, NoTls};
use rollback::rollback;
use std::env;

fn main() {
    let args: Vec<String> = env::args().collect();

    let url_db = env::var("DATABASE_URL").expect("DATABASE_URL must be set");

    let mut conn = Client::connect(&url_db, NoTls).unwrap();
    let migrations = get_migrations();

    let rollback_scripts = get_rollback_migrations();

    if args.len() < 2 {
        println!("running migration...");
        migrations.run(&mut conn).unwrap();
        println!("migration done");
    } else if !rollback_scripts.is_empty() {
        rollback(rollback_scripts, migrations, &mut conn);
        println!("rollback done");
    } else {
        println!("Not rollback to run");
    }
}
