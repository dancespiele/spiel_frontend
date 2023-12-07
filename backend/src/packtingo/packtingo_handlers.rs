use super::dtos::{CreateScoreDto, GetScoreDto, UpdatePrizeDto};
use super::models::{Account, Prize, Score};
use crate::db::Pool;
use crate::error::{DbError, Forbidden};
use crate::guard::SessionDto;
use crate::schema::prize::{request_id, withdraw_prize};
use diesel::prelude::*;
use std::env;
use std::sync::Arc;
use tokio::sync::Mutex;
use warp::{reject, reply, Rejection, Reply};

#[utoipa::path(
	post,
	path = "/score",
	request_body = CreateScoreDto,
	responses(
		(status = 200, description = "Score created", body = [&str]),
		(status = 500, description = "Database error"),
		(status = 403, description = "Forbidden"),
		(status = 400, description = "Bad request"),
		(status = 404, description = "Not found")
	),
	security(
		("jwt_token" = ["write:items"])
	)
  )]
pub async fn create_score(
    session: SessionDto,
    pool: Arc<Mutex<Pool>>,
    score_body: CreateScoreDto,
) -> Result<impl Reply, Rejection> {
    use crate::schema::account::dsl::*;
    use crate::schema::prize::dsl::*;
    use crate::schema::score::dsl::*;

    let account_created: Account;

    let conn: &mut PgConnection = &mut pool.lock().await.get().unwrap();

    let account_exist = account
        .filter(address.eq(session.address.clone()))
        .get_result::<Account>(conn)
        .optional()
        .map_err(|err| {
            reject::custom(DbError {
                error: diesel::r2d2::Error::QueryError(err),
            })
        })?;

    let account_model: Account = Account::from(session);

    if account_exist.is_none() {
        account_created = diesel::insert_into(account)
            .values(account_model)
            .get_result::<Account>(conn)
            .map_err(|err| {
                reject::custom(DbError {
                    error: diesel::r2d2::Error::QueryError(err),
                })
            })?;
    } else {
        account_created = account_exist.unwrap();
    }

    let score_model: Score = Score::from((account_created.id, score_body.clone()));

    let score_created = diesel::insert_into(score)
        .values(score_model)
        .get_result::<Score>(conn)
        .map_err(|err| {
            reject::custom(DbError {
                error: diesel::r2d2::Error::QueryError(err),
            })
        })?;

    if score_body.score > 0 || score_body.score <= 4 {
        let prize_model: Prize = Prize::from(score_created.id.clone());

        diesel::insert_into(prize)
            .values(prize_model)
            .get_result::<Prize>(conn)
            .map_err(|err| {
                reject::custom(DbError {
                    error: diesel::r2d2::Error::QueryError(err),
                })
            })?;
    }

    Ok(reply::json(&"Score created"))
}

#[utoipa::path(
	get,
	path = "/prize",
	responses(
		(status = 200, description = "Prizes without withdraw", body = [Vec<Prize>]),
		(status = 500, description = "Database error"),
		(status = 403, description = "Forbidden"),
		(status = 404, description = "Not found")
	),
	security(
		("jwt_token" = ["read:items"])
	)
  )]
pub async fn get_prizes(
    session: SessionDto,
    pool: Arc<Mutex<Pool>>,
) -> Result<impl Reply, Rejection> {
    use crate::schema::account::dsl::*;

    let conn: &mut PgConnection = &mut pool.lock().await.get().unwrap();

    let account_model: Account = account
        .filter(address.eq(session.address.clone()))
        .get_result::<Account>(conn)
        .map_err(|_| reject::not_found())?;

    let score_models: Vec<Score> = Score::belonging_to(&account_model)
        .load::<Score>(conn)
        .map_err(|err| {
            reject::custom(DbError {
                error: diesel::r2d2::Error::QueryError(err),
            })
        })?;

    let prizes: Vec<Prize> = Prize::belonging_to(&score_models)
        .filter(withdraw_prize.eq(false).and(request_id.is_not_null()))
        .load::<Prize>(conn)
        .map_err(|err| {
            reject::custom(DbError {
                error: diesel::r2d2::Error::QueryError(err),
            })
        })?;

    Ok(reply::json(&prizes))
}

#[utoipa::path(
    get,
	params(
		("score_id" = String, Path, description = "Score id unique identifier"),
	),
    path = "/score/{score_id}",
    responses(
		(status = 200, description = "Score got by account ID", body = [Prize]),
		(status = 500, description = "Database error"),
		(status = 404, description = "Not found")
	)
)]
pub async fn get_score(pool: Arc<Mutex<Pool>>, score_id: String) -> Result<impl Reply, Rejection> {
    use crate::schema::score::dsl::*;

    let conn: &mut PgConnection = &mut pool.lock().await.get().unwrap();

    let score_model: Score = score
        .filter(id.eq(&score_id))
        .get_result::<Score>(conn)
        .map_err(|_| reject::not_found())?;

    let prizes: Prize = Prize::belonging_to(&score_model)
        .filter(withdraw_prize.eq(false))
        .get_result::<Prize>(conn)
        .map_err(|err| {
            reject::custom(DbError {
                error: diesel::r2d2::Error::QueryError(err),
            })
        })?;

    let score_result = GetScoreDto::from((score_model, prizes));

    Ok(reply::json(&score_result))
}

#[utoipa::path(
    put,
    request_body = UpdatePrizeDto,
	security(
		("jwt_token" = ["edit:items"])
	),
    path = "/prize/{prize_id}/{request_id}",
    responses(
		(status = 200, description = "Request id set", body = [Vec<Prize>]),
		(status = 500, description = "Database error"),
		(status = 403, description = "Forbidden"),
		(status = 404, description = "Not found")
	)
)]
pub async fn update_request_id_prize(
    session: SessionDto,
    pool: Arc<Mutex<Pool>>,
    prize_data: UpdatePrizeDto,
) -> Result<impl Reply, Rejection> {
    use crate::schema::prize::dsl::*;

    if session.address != env::var("OWNER_ADDRESS").unwrap() {
        return Err(reject::custom(Forbidden {
            error: String::from("This address doesn't match with the action address"),
        }));
    }

    let conn: &mut PgConnection = &mut pool.lock().await.get().unwrap();

    diesel::update(prize)
        .filter(id.eq(&prize_data.prize_id))
        .set(request_id.eq(&prize_data.request_id))
        .execute(conn)
        .map_err(|err| {
            reject::custom(DbError {
                error: diesel::r2d2::Error::QueryError(err),
            })
        })?;

    Ok(reply::json(&"Prize updated"))
}

#[utoipa::path(
    put,
	params(
		("prize_id" = String, Path, description = "Prize id unique identifier"),
	),
	security(
		("jwt_token" = ["edit:items"])
	),
    path = "/prize/{prize_id}",
    responses(
		(status = 200, description = "Withdraw prize completed", body = [Vec<Prize>]),
		(status = 500, description = "Database error"),
		(status = 403, description = "Forbidden"),
		(status = 404, description = "Not found")
	)
)]
pub async fn update_withdraw_prize(
    _session: SessionDto,
    pool: Arc<Mutex<Pool>>,
    prize_id: String,
) -> Result<impl Reply, Rejection> {
    use crate::schema::prize::dsl::*;

    let conn: &mut PgConnection = &mut pool.lock().await.get().unwrap();

    diesel::update(prize)
        .filter(id.eq(&prize_id))
        .set(withdraw_prize.eq(true))
        .execute(conn)
        .map_err(|err| {
            reject::custom(DbError {
                error: diesel::r2d2::Error::QueryError(err),
            })
        })?;

    Ok(reply::json(&"Prize updated"))
}
