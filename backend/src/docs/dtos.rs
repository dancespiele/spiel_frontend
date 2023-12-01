use crate::guard;
use crate::packtingo;

use utoipa::{
    openapi::security::{ApiKey, ApiKeyValue, SecurityScheme},
    Modify, OpenApi,
};

#[derive(OpenApi)]
#[openapi(
    modifiers(&SecurityAddon),
    paths(
        guard::guard_handlers::login,
        guard::guard_handlers::get_nonce,
        packtingo::packtingo_handlers::create_score,
        packtingo::packtingo_handlers::get_prizes,
        packtingo::packtingo_handlers::get_score,
        packtingo::packtingo_handlers::update_withdraw_prize,
    ),
    components(schemas(
        guard::dtos::SignatureDto,
        packtingo::dtos::GetScoreDto,
        packtingo::models::Prize,
        packtingo::dtos::CreateScoreDto,
    ))
)]
pub struct ApiDoc;

struct SecurityAddon;

impl Modify for SecurityAddon {
    fn modify(&self, openapi: &mut utoipa::openapi::OpenApi) {
        openapi.components.as_mut().unwrap().add_security_scheme(
            "jwt_token",
            SecurityScheme::ApiKey(ApiKey::Header(ApiKeyValue::new("Authorization"))),
        )
    }
}
