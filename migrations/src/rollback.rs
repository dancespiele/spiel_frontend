use crate::migrations::RollbackScript;
use postgres::Client;
use refinery::Runner;

pub fn rollback(rollback_scripts: Vec<RollbackScript>, runner: Runner, conn: &mut Client) {
    let last_migration = runner.get_last_applied_migration(conn).unwrap().unwrap();

    let name_migration = last_migration.name();
    let version = last_migration.version();

    let name_complete_migration = format!("V{}__{}", version, name_migration);

    let rollback_script = rollback_scripts
        .into_iter()
        .find(|rs| rs.name == name_complete_migration);

    if let Some(rs) = rollback_script {
        let sql = rs.sql;

        match conn.batch_execute(&sql) {
            Ok(_) => {
                conn.query(
                    "DELETE from refinery_schema_history WHERE name = $1",
                    &[&name_migration],
                )
                .unwrap();
            }
            Err(err) => eprintln!("Error to execute migration: {}", err),
        };
    } else {
        eprintln!("Rollback not found");
    }
}
