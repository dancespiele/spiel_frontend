use super::helpers::ExecOpt;
use barrel::backend::Pg;
use barrel::{types, Migration};

pub fn migration(exec_opt: ExecOpt) -> String {
    let mut m = Migration::new();

    match exec_opt {
        ExecOpt::Up => {
            m.create_table("account", |t| {
                t.add_column("id", types::varchar(255).unique(true).primary(true));
                t.add_column("address", types::varchar(255).unique(true));
                t.add_column("created_at", types::datetime());
                t.add_column("updated_at", types::datetime());
            });
            m.make::<Pg>()
        }
        ExecOpt::Down => {
            m.drop_table("account");
            m.make::<Pg>()
        }
    }
}
