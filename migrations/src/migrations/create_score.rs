use super::helpers::{get_schema, ExecOpt};
use barrel::backend::Pg;
use barrel::{types, Migration};

pub fn migration(exec_opt: ExecOpt) -> String {
    let m = Migration::new();
    let mut schema = m.schema(get_schema());

    match exec_opt {
        ExecOpt::Up => {
            schema.create_table("auth", |t| {
                t.add_column("id", types::text().unique(true).primary(true));
                t.add_column("user_id", types::text());
                t.add_column("password", types::text());
                t.inject_custom("created_at TIMESTAMP NOT NULL");
                t.inject_custom("updated_at TIMESTAMP NOT NULL");
                t.inject_custom(
                    "CONSTRAINT user_id_auth_fkey foreign key (user_id) references base.user(id) ON DELETE CASCADE",
                );
                t.inject_custom("CONSTRAINT auth_user_id_unique UNIQUE (user_id)");
            });
            schema.make::<Pg>()
        }
        ExecOpt::Down => {
            schema.change_table("auth", |t| {
                t.inject_custom("DROP CONSTRAINT auth_user_id_unique");
                t.inject_custom("DROP CONSTRAINT user_id_auth_fkey");
            });
            schema.drop_table("auth");
            schema.make::<Pg>()
        }
    }
}
