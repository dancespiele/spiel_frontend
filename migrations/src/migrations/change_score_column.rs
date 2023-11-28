use super::helpers::ExecOpt;
use barrel::backend::Pg;
use barrel::Migration;

pub fn migration(exec_opt: ExecOpt) -> String {
    let mut m = Migration::new();

    match exec_opt {
        ExecOpt::Up => {
            m.change_table("score", |t| t.rename_column("score", "points"));
            m.make::<Pg>()
        }
        ExecOpt::Down => {
            m.change_table("score", |t| t.rename_column("points", "score"));
            m.make::<Pg>()
        }
    }
}
