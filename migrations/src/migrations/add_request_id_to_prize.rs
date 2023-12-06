use super::helpers::ExecOpt;
use barrel::backend::Pg;
use barrel::{types, Migration};

pub fn migration(exec_opt: ExecOpt) -> String {
    let mut m = Migration::new();

    match exec_opt {
        ExecOpt::Up => {
            m.change_table("prize", |t| {
                t.add_column("request_id", types::varchar(255).nullable(true));
            });
            m.make::<Pg>()
        }
        ExecOpt::Down => {
            m.change_table("prize", |t| t.drop_column("request_id"));
            m.make::<Pg>()
        }
    }
}
