table! {
  account (id) {
      id -> Varchar,
      address -> Varchar,
      created_at -> Timestamp,
      updated_at -> Timestamp,
  }
}

table! {
  prize (id) {
      id -> Varchar,
      score_id -> Varchar,
      withdraw_prize -> Bool,
      created_at -> Timestamp,
      updated_at -> Timestamp,
      request_id -> Nullable<Varchar>
  }
}

table! {
  score (id) {
      id -> Varchar,
      account_id -> Varchar,
      points -> Int4,
      created_at -> Timestamp,
      updated_at -> Timestamp,
  }
}

joinable!(prize -> score (score_id));
joinable!(score -> account (account_id));

allow_tables_to_appear_in_same_query!(account, prize, score);
