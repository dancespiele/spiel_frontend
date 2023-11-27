use super::create_score;
use refinery::{Migration, Runner};
use std::env;

pub enum ExecOpt {
    Up,
    Down,
}

pub struct RollbackScript {
    pub name: String,
    pub sql: String,
}

pub fn get_schema() -> String {
    env::var("SCHEMA").unwrap_or_else(|_| String::from(""))
}

pub fn get_migrations() -> Runner {
    let v1_migration =
        Migration::unapplied("V1__create_user", &create_score::migration(ExecOpt::Up)).unwrap();

    Runner::new(&[v1_migration])
}

pub fn get_rollback_migrations() -> Vec<RollbackScript> {
    vec![RollbackScript {
        name: "V1__create_score".to_string(),
        sql: create_score::migration(ExecOpt::Down),
    }]
}
