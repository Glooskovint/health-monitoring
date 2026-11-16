-- Database initialization script for EVA Health Monitor
-- This runs automatically when PostgreSQL container starts for the first time

-- Enable UUID extension if needed
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create additional indexes for performance
-- These will be created after SQLAlchemy creates the tables
-- You can add custom indexes here if needed

-- Example: CREATE INDEX IF NOT EXISTS idx_astronauts_email ON astronauts(email);

-- Grant permissions (if using non-superuser)
-- GRANT ALL PRIVILEGES ON DATABASE eva_health TO postgres;