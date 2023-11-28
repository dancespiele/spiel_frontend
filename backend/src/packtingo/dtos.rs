use super::models::{Account, Prize, Score};
use crate::guard::SessionDto;
use chrono::prelude::*;
use utoipa::ToSchema;

#[derive(Debug, Clone, Deserialize, ToSchema)]
pub struct CreateScoreDto {
    #[schema(example = 3)]
    pub score: i32,
}

#[derive(Debug, Clone, Deserialize, Serialize, ToSchema)]
pub struct GetScoreDto {
    #[schema(example = "p-1wdkq")]
    prize_id: String,
    #[schema(example = 3)]
    score: i32,
    #[schema(example = true)]
    withdraw_prize: bool,
}

impl From<SessionDto> for Account {
    fn from(session: SessionDto) -> Self {
        let uuid = format!("{}", uuid::Uuid::new_v4());
        Account {
            id: format!(
                "ac-{}",
                uuid.parse::<String>()
                    .expect("problem to pass to String from uuid format")
            ),
            address: session.address,
            created_at: Utc::now().naive_utc(),
            updated_at: Utc::now().naive_utc(),
        }
    }
}

impl From<(String, CreateScoreDto)> for Score {
    fn from(packtingo_score: (String, CreateScoreDto)) -> Self {
        let (account_id, create_score_dto) = packtingo_score;
        let uuid = format!("{}", uuid::Uuid::new_v4());

        Self {
            id: format!(
                "sc-{}",
                uuid.parse::<String>()
                    .expect("problem to pass to String from uuid format")
            ),
            account_id,
            points: create_score_dto.score,
            created_at: Utc::now().naive_utc(),
            updated_at: Utc::now().naive_utc(),
        }
    }
}

impl From<(String, bool)> for Prize {
    fn from(prize: (String, bool)) -> Self {
        let (score_id, withdraw_prize) = prize;

        Self {
            id: format!(
                "pr-{}",
                score_id
                    .parse::<String>()
                    .expect("problem to pass to String from uuid format")
            ),
            score_id,
            withdraw_prize,
            created_at: Utc::now().naive_utc(),
            updated_at: Utc::now().naive_utc(),
        }
    }
}

impl From<(Score, Prize)> for GetScoreDto {
    fn from(score_result: (Score, Prize)) -> Self {
        let (score, prize) = score_result;

        Self {
            prize_id: prize.id,
            score: score.points,
            withdraw_prize: prize.withdraw_prize,
        }
    }
}
