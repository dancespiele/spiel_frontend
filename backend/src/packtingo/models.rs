use crate::schema::{account, prize, score};
use chrono::prelude::*;
use utoipa::ToSchema;

#[derive(Deserialize, Identifiable, Serialize, Queryable, Insertable)]
#[diesel(table_name = account)]
pub struct Account {
    pub id: String,
    pub address: String,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime,
}

#[derive(Deserialize, Identifiable, Serialize, Queryable, Insertable, Associations)]
#[diesel(table_name = score, belongs_to(Account, foreign_key = account_id))]
pub struct Score {
    pub id: String,
    pub account_id: String,
    pub points: i32,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime,
}

#[derive(Deserialize, Identifiable, Serialize, Queryable, Insertable, Associations, ToSchema)]
#[diesel(table_name = prize, belongs_to(Score, foreign_key = score_id))]
pub struct Prize {
    #[schema(example = "pr-133232")]
    pub id: String,
    #[schema(example = "sc-133232")]
    pub score_id: String,
    #[schema(example = false)]
    pub withdraw_prize: bool,
    #[schema(example = "2020-01-01 00:00:00")]
    pub created_at: NaiveDateTime,
    #[schema(example = "2020-01-01 00:00:00")]
    pub updated_at: NaiveDateTime,
    #[schema(example = "134455335")]
    pub request_id: Option<String>,
}
