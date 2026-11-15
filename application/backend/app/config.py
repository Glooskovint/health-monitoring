from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    database_url: str = "postgresql+psycopg://postgres:postgres@localhost:5432/eva_health"
    api_title: str = "EVA Health Monitor API"
    api_version: str = "0.1.0"
    cors_origins: str = "http://localhost:5173"

    secret_key: str = "dev-secret-change-me-please-use-a-long-random-value"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 480

    @property
    def cors_origin_list(self) -> list[str]:
        return [origin.strip() for origin in self.cors_origins.split(",") if origin.strip()]


settings = Settings()
