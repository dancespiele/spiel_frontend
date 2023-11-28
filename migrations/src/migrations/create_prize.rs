use super::helpers::ExecOpt;
use barrel::backend::Pg;
use barrel::{types, Migration};

pub fn migration(exec_opt: ExecOpt) -> String {
    let mut m = Migration::new();

    match exec_opt {
        ExecOpt::Up => {
            m.create_table("prize", |t| {
                t.add_column("id", types::varchar(255).unique(true).primary(true));
                t.add_column("score_id", types::varchar(255));
                t.add_foreign_key(&["score_id"], "score", &["id"]);
                t.add_column("withdraw_prize", types::boolean());
                t.add_column("created_at", types::datetime());
                t.add_column("updated_at", types::datetime());
            });
            m.make::<Pg>()
        }
        ExecOpt::Down => {
            m.change_table("prize", |t| {
                t.inject_custom("DROP CONSTRAINT prize_score_id_fkey");
            });
            m.drop_table("prize");
            m.make::<Pg>()
        }
    }
}
