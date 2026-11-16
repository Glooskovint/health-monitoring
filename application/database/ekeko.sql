--
-- PostgreSQL database dump
--


-- Dumped from database version 18.7
-- Dumped by pg_dump version 18.7

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_astronaut_id_fkey;
ALTER TABLE IF EXISTS ONLY public.telemetry DROP CONSTRAINT IF EXISTS telemetry_session_id_fkey;
ALTER TABLE IF EXISTS ONLY public.sessions DROP CONSTRAINT IF EXISTS sessions_astronaut_id_fkey;
ALTER TABLE IF EXISTS ONLY public.predictions DROP CONSTRAINT IF EXISTS predictions_session_id_fkey;
ALTER TABLE IF EXISTS ONLY public.predictions DROP CONSTRAINT IF EXISTS predictions_model_id_fkey;
ALTER TABLE IF EXISTS ONLY public.predictions DROP CONSTRAINT IF EXISTS predictions_hypothesis_code_fkey;
ALTER TABLE IF EXISTS ONLY public.model_metrics DROP CONSTRAINT IF EXISTS model_metrics_model_id_fkey;
ALTER TABLE IF EXISTS ONLY public.medical_events DROP CONSTRAINT IF EXISTS medical_events_session_id_fkey;
ALTER TABLE IF EXISTS ONLY public.medical_events DROP CONSTRAINT IF EXISTS medical_events_event_type_code_fkey;
ALTER TABLE IF EXISTS ONLY public.baselines DROP CONSTRAINT IF EXISTS baselines_session_id_fkey;
ALTER TABLE IF EXISTS ONLY public.alerts DROP CONSTRAINT IF EXISTS alerts_session_id_fkey;
ALTER TABLE IF EXISTS ONLY public.alerts DROP CONSTRAINT IF EXISTS alerts_prediction_id_fkey;
ALTER TABLE IF EXISTS ONLY public.alert_actions DROP CONSTRAINT IF EXISTS alert_actions_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.alert_actions DROP CONSTRAINT IF EXISTS alert_actions_alert_id_fkey;
DROP INDEX IF EXISTS public.idx_telemetry_session_minute;
DROP INDEX IF EXISTS public.idx_sessions_astronaut;
DROP INDEX IF EXISTS public.idx_predictions_session_minute;
DROP INDEX IF EXISTS public.idx_events_session;
DROP INDEX IF EXISTS public.idx_alerts_status;
DROP INDEX IF EXISTS public.idx_alerts_session;
DROP INDEX IF EXISTS public.idx_alert_actions_alert;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_email_key;
ALTER TABLE IF EXISTS ONLY public.telemetry DROP CONSTRAINT IF EXISTS telemetry_session_id_minute_key;
ALTER TABLE IF EXISTS ONLY public.telemetry DROP CONSTRAINT IF EXISTS telemetry_pkey;
ALTER TABLE IF EXISTS ONLY public.sessions DROP CONSTRAINT IF EXISTS sessions_pkey;
ALTER TABLE IF EXISTS ONLY public.predictions DROP CONSTRAINT IF EXISTS predictions_session_id_minute_model_id_key;
ALTER TABLE IF EXISTS ONLY public.predictions DROP CONSTRAINT IF EXISTS predictions_pkey;
ALTER TABLE IF EXISTS ONLY public.models DROP CONSTRAINT IF EXISTS models_pkey;
ALTER TABLE IF EXISTS ONLY public.models DROP CONSTRAINT IF EXISTS models_name_version_key;
ALTER TABLE IF EXISTS ONLY public.model_metrics DROP CONSTRAINT IF EXISTS model_metrics_pkey;
ALTER TABLE IF EXISTS ONLY public.medical_events DROP CONSTRAINT IF EXISTS medical_events_pkey;
ALTER TABLE IF EXISTS ONLY public.event_types DROP CONSTRAINT IF EXISTS event_types_pkey;
ALTER TABLE IF EXISTS ONLY public.baselines DROP CONSTRAINT IF EXISTS baselines_session_id_variable_key;
ALTER TABLE IF EXISTS ONLY public.baselines DROP CONSTRAINT IF EXISTS baselines_pkey;
ALTER TABLE IF EXISTS ONLY public.astronauts DROP CONSTRAINT IF EXISTS astronauts_pkey;
ALTER TABLE IF EXISTS ONLY public.astronauts DROP CONSTRAINT IF EXISTS astronauts_email_key;
ALTER TABLE IF EXISTS ONLY public.alerts DROP CONSTRAINT IF EXISTS alerts_pkey;
ALTER TABLE IF EXISTS ONLY public.alert_actions DROP CONSTRAINT IF EXISTS alert_actions_pkey;
ALTER TABLE IF EXISTS public.users ALTER COLUMN user_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.telemetry ALTER COLUMN telemetry_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.predictions ALTER COLUMN prediction_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.models ALTER COLUMN model_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.model_metrics ALTER COLUMN metric_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.medical_events ALTER COLUMN event_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.baselines ALTER COLUMN baseline_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.alerts ALTER COLUMN alert_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.alert_actions ALTER COLUMN action_id DROP DEFAULT;
DROP VIEW IF EXISTS public.v_telemetry_export;
DROP VIEW IF EXISTS public.v_sessions_export;
DROP VIEW IF EXISTS public.v_predictions_export;
DROP VIEW IF EXISTS public.v_alerts_export;
DROP VIEW IF EXISTS public.v_alert_actions_export;
DROP SEQUENCE IF EXISTS public.users_user_id_seq;
DROP TABLE IF EXISTS public.users;
DROP SEQUENCE IF EXISTS public.telemetry_telemetry_id_seq;
DROP TABLE IF EXISTS public.telemetry;
DROP TABLE IF EXISTS public.sessions;
DROP SEQUENCE IF EXISTS public.predictions_prediction_id_seq;
DROP TABLE IF EXISTS public.predictions;
DROP SEQUENCE IF EXISTS public.models_model_id_seq;
DROP TABLE IF EXISTS public.models;
DROP SEQUENCE IF EXISTS public.model_metrics_metric_id_seq;
DROP TABLE IF EXISTS public.model_metrics;
DROP SEQUENCE IF EXISTS public.medical_events_event_id_seq;
DROP TABLE IF EXISTS public.medical_events;
DROP TABLE IF EXISTS public.event_types;
DROP SEQUENCE IF EXISTS public.baselines_baseline_id_seq;
DROP TABLE IF EXISTS public.baselines;
DROP TABLE IF EXISTS public.astronauts;
DROP SEQUENCE IF EXISTS public.alerts_alert_id_seq;
DROP TABLE IF EXISTS public.alerts;
DROP SEQUENCE IF EXISTS public.alert_actions_action_id_seq;
DROP TABLE IF EXISTS public.alert_actions;
DROP TYPE IF EXISTS public.user_role;
DROP TYPE IF EXISTS public.alert_status;
DROP TYPE IF EXISTS public.alert_level;
--
-- Name: alert_level; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.alert_level AS ENUM (
    'surveillance',
    'alert',
    'critical'
);


--
-- Name: alert_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.alert_status AS ENUM (
    'open',
    'acknowledged',
    'resolved',
    'dismissed'
);


--
-- Name: user_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.user_role AS ENUM (
    'astronaut',
    'flight_surgeon',
    'mission_control',
    'researcher'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alert_actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alert_actions (
    action_id bigint NOT NULL,
    alert_id bigint NOT NULL,
    user_id bigint NOT NULL,
    action character varying(40) NOT NULL,
    comment text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: alert_actions_action_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.alert_actions_action_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: alert_actions_action_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.alert_actions_action_id_seq OWNED BY public.alert_actions.action_id;


--
-- Name: alerts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alerts (
    alert_id bigint NOT NULL,
    prediction_id bigint NOT NULL,
    session_id character varying(40) NOT NULL,
    level public.alert_level NOT NULL,
    summary text NOT NULL,
    recommended_action text,
    status public.alert_status DEFAULT 'open'::public.alert_status NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    resolved_at timestamp with time zone
);


--
-- Name: alerts_alert_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.alerts_alert_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: alerts_alert_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.alerts_alert_id_seq OWNED BY public.alerts.alert_id;


--
-- Name: astronauts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.astronauts (
    astronaut_id character varying(20) NOT NULL,
    full_name character varying(120) NOT NULL,
    birth_date date,
    email character varying(160),
    active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: baselines; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baselines (
    baseline_id bigint NOT NULL,
    session_id character varying(40) NOT NULL,
    variable character varying(40) NOT NULL,
    window_minutes integer DEFAULT 30 NOT NULL,
    mean numeric(12,5) NOT NULL,
    std numeric(12,5) NOT NULL,
    computed_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: baselines_baseline_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.baselines_baseline_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: baselines_baseline_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.baselines_baseline_id_seq OWNED BY public.baselines.baseline_id;


--
-- Name: event_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_types (
    code character varying(40) NOT NULL,
    name character varying(120) NOT NULL,
    category character varying(40) NOT NULL,
    description text
);


--
-- Name: medical_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.medical_events (
    event_id bigint NOT NULL,
    session_id character varying(40) NOT NULL,
    event_type_code character varying(40) NOT NULL,
    onset_minute integer NOT NULL,
    end_minute integer,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT medical_events_check CHECK (((end_minute IS NULL) OR (end_minute >= onset_minute))),
    CONSTRAINT medical_events_onset_minute_check CHECK ((onset_minute >= 0))
);


--
-- Name: medical_events_event_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.medical_events_event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: medical_events_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.medical_events_event_id_seq OWNED BY public.medical_events.event_id;


--
-- Name: model_metrics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.model_metrics (
    metric_id bigint NOT NULL,
    model_id bigint NOT NULL,
    split character varying(20) NOT NULL,
    metric_name character varying(60) NOT NULL,
    value numeric(10,5) NOT NULL,
    computed_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: model_metrics_metric_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.model_metrics_metric_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: model_metrics_metric_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.model_metrics_metric_id_seq OWNED BY public.model_metrics.metric_id;


--
-- Name: models; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.models (
    model_id bigint NOT NULL,
    name character varying(120) NOT NULL,
    version character varying(40) NOT NULL,
    algorithm character varying(120) NOT NULL,
    horizon_minutes integer DEFAULT 30 NOT NULL,
    hyperparameters jsonb DEFAULT '{}'::jsonb NOT NULL,
    is_active boolean DEFAULT false NOT NULL,
    trained_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT models_horizon_minutes_check CHECK ((horizon_minutes > 0))
);


--
-- Name: models_model_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.models_model_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: models_model_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.models_model_id_seq OWNED BY public.models.model_id;


--
-- Name: predictions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.predictions (
    prediction_id bigint NOT NULL,
    session_id character varying(40) NOT NULL,
    minute integer NOT NULL,
    model_id bigint NOT NULL,
    horizon_minutes integer NOT NULL,
    risk_score numeric(6,5) NOT NULL,
    level public.alert_level NOT NULL,
    hypothesis_code character varying(40),
    top_features jsonb DEFAULT '[]'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT predictions_horizon_minutes_check CHECK ((horizon_minutes > 0)),
    CONSTRAINT predictions_minute_check CHECK ((minute >= 0)),
    CONSTRAINT predictions_risk_score_check CHECK (((risk_score >= (0)::numeric) AND (risk_score <= (1)::numeric)))
);


--
-- Name: predictions_prediction_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.predictions_prediction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: predictions_prediction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.predictions_prediction_id_seq OWNED BY public.predictions.prediction_id;


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    session_id character varying(40) NOT NULL,
    astronaut_id character varying(20) NOT NULL,
    started_at timestamp with time zone NOT NULL,
    ended_at timestamp with time zone,
    environment jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT sessions_check CHECK (((ended_at IS NULL) OR (ended_at >= started_at)))
);


--
-- Name: telemetry; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.telemetry (
    telemetry_id bigint NOT NULL,
    session_id character varying(40) NOT NULL,
    minute integer NOT NULL,
    recorded_at timestamp with time zone NOT NULL,
    hr_bpm numeric(6,2),
    spo2_pct numeric(5,2),
    resp_rate_bpm numeric(5,2),
    core_temp_c numeric(5,2),
    skin_temp_c numeric(5,2),
    eeg_theta_beta_ratio numeric(7,4),
    eeg_alpha_uv2 numeric(8,3),
    eeg_quality numeric(5,4),
    emg_rms_uv numeric(8,3),
    emg_mdf_hz numeric(8,3),
    rad_dose_rate_usv_h numeric(10,4),
    rad_cum_dose_msv numeric(10,4),
    CONSTRAINT telemetry_eeg_quality_check CHECK (((eeg_quality IS NULL) OR ((eeg_quality >= (0)::numeric) AND (eeg_quality <= (1)::numeric)))),
    CONSTRAINT telemetry_minute_check CHECK ((minute >= 0))
);


--
-- Name: telemetry_telemetry_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.telemetry_telemetry_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: telemetry_telemetry_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.telemetry_telemetry_id_seq OWNED BY public.telemetry.telemetry_id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    user_id bigint NOT NULL,
    full_name character varying(120) NOT NULL,
    email character varying(160) NOT NULL,
    role public.user_role NOT NULL,
    hashed_password character varying(255) NOT NULL,
    astronaut_id character varying(20),
    is_active boolean DEFAULT true NOT NULL,
    last_login_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users.user_id;


--
-- Name: v_alert_actions_export; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_alert_actions_export AS
 SELECT aa.action_id,
    aa.alert_id,
    al.session_id,
    (al.level)::text AS alert_level,
    u.user_id,
    u.full_name AS user_name,
    (u.role)::text AS user_role,
    aa.action,
    aa.comment,
    aa.created_at
   FROM ((public.alert_actions aa
     JOIN public.alerts al ON ((al.alert_id = aa.alert_id)))
     JOIN public.users u ON ((u.user_id = aa.user_id)));


--
-- Name: v_alerts_export; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_alerts_export AS
 SELECT al.alert_id,
    al.prediction_id,
    al.session_id,
    s.astronaut_id,
    a.full_name AS astronaut_name,
    (al.level)::text AS level,
    al.summary,
    al.recommended_action,
    (al.status)::text AS status,
    al.created_at,
    al.resolved_at
   FROM ((public.alerts al
     JOIN public.sessions s ON (((s.session_id)::text = (al.session_id)::text)))
     JOIN public.astronauts a ON (((a.astronaut_id)::text = (s.astronaut_id)::text)));


--
-- Name: v_predictions_export; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_predictions_export AS
 SELECT p.prediction_id,
    p.session_id,
    s.astronaut_id,
    a.full_name AS astronaut_name,
    s.started_at AS session_started_at,
    p.minute,
    p.horizon_minutes,
    p.risk_score,
    (p.level)::text AS level,
    p.hypothesis_code,
    et.name AS hypothesis_name,
    p.created_at AS predicted_at
   FROM (((public.predictions p
     JOIN public.sessions s ON (((s.session_id)::text = (p.session_id)::text)))
     JOIN public.astronauts a ON (((a.astronaut_id)::text = (s.astronaut_id)::text)))
     LEFT JOIN public.event_types et ON (((et.code)::text = (p.hypothesis_code)::text)));


--
-- Name: v_sessions_export; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_sessions_export AS
 SELECT s.session_id,
    s.astronaut_id,
    a.full_name AS astronaut_name,
    s.started_at,
    s.ended_at,
        CASE
            WHEN (s.ended_at IS NOT NULL) THEN (round((EXTRACT(epoch FROM (s.ended_at - s.started_at)) / 60.0)))::integer
            ELSE NULL::integer
        END AS duration_minutes,
    COALESCE(p.predictions, (0)::bigint) AS predictions,
    p.max_risk_score,
    COALESCE(al.total_alerts, (0)::bigint) AS total_alerts,
    COALESCE(al.open_alerts, (0)::bigint) AS open_alerts
   FROM (((public.sessions s
     JOIN public.astronauts a ON (((a.astronaut_id)::text = (s.astronaut_id)::text)))
     LEFT JOIN ( SELECT predictions.session_id,
            count(*) AS predictions,
            max(predictions.risk_score) AS max_risk_score
           FROM public.predictions
          GROUP BY predictions.session_id) p ON (((p.session_id)::text = (s.session_id)::text)))
     LEFT JOIN ( SELECT alerts.session_id,
            count(*) AS total_alerts,
            count(*) FILTER (WHERE (alerts.status = 'open'::public.alert_status)) AS open_alerts
           FROM public.alerts
          GROUP BY alerts.session_id) al ON (((al.session_id)::text = (s.session_id)::text)));


--
-- Name: v_telemetry_export; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_telemetry_export AS
 SELECT t.telemetry_id,
    t.session_id,
    s.astronaut_id,
    a.full_name AS astronaut_name,
    t.minute,
    t.recorded_at,
    t.hr_bpm,
    t.spo2_pct,
    t.resp_rate_bpm,
    t.core_temp_c,
    t.skin_temp_c,
    t.eeg_theta_beta_ratio,
    t.eeg_alpha_uv2,
    t.eeg_quality,
    t.emg_rms_uv,
    t.emg_mdf_hz,
    t.rad_dose_rate_usv_h,
    t.rad_cum_dose_msv
   FROM ((public.telemetry t
     JOIN public.sessions s ON (((s.session_id)::text = (t.session_id)::text)))
     JOIN public.astronauts a ON (((a.astronaut_id)::text = (s.astronaut_id)::text)));


--
-- Name: alert_actions action_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert_actions ALTER COLUMN action_id SET DEFAULT nextval('public.alert_actions_action_id_seq'::regclass);


--
-- Name: alerts alert_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alerts ALTER COLUMN alert_id SET DEFAULT nextval('public.alerts_alert_id_seq'::regclass);


--
-- Name: baselines baseline_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baselines ALTER COLUMN baseline_id SET DEFAULT nextval('public.baselines_baseline_id_seq'::regclass);


--
-- Name: medical_events event_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medical_events ALTER COLUMN event_id SET DEFAULT nextval('public.medical_events_event_id_seq'::regclass);


--
-- Name: model_metrics metric_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.model_metrics ALTER COLUMN metric_id SET DEFAULT nextval('public.model_metrics_metric_id_seq'::regclass);


--
-- Name: models model_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.models ALTER COLUMN model_id SET DEFAULT nextval('public.models_model_id_seq'::regclass);


--
-- Name: predictions prediction_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.predictions ALTER COLUMN prediction_id SET DEFAULT nextval('public.predictions_prediction_id_seq'::regclass);


--
-- Name: telemetry telemetry_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telemetry ALTER COLUMN telemetry_id SET DEFAULT nextval('public.telemetry_telemetry_id_seq'::regclass);


--
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);


--
-- Data for Name: alert_actions; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.alert_actions VALUES (1, 5, 2, 'acknowledge', NULL, '2026-11-15 00:13:15.771901-05');
INSERT INTO public.alert_actions VALUES (2, 4, 2, 'acknowledge', NULL, '2026-11-15 00:13:19.637565-05');


--
-- Data for Name: alerts; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.alerts VALUES (1, 1, 'EVA-001', 'alert', 'Astronauta AST001: patrón compatible con hipoxia/hipercapnia: spo2_pct -0.9σ, skin_temp_c +0.9σ, rad_dose_rate_usv_h +0.1σ, emg_mdf_hz -0.0σ, eeg_alpha_uv2 +0.0σ → riesgo 44% en próximos 30 min.', 'Verificar suministro de O2 y scrubber de CO2; reducir esfuerzo; preparar retorno a la esclusa.', 'open', '2026-11-14 23:38:46.372067-05', NULL);
INSERT INTO public.alerts VALUES (2, 3, 'EVA-001', 'critical', 'Astronauta AST001: patrón compatible con hipoxia/hipercapnia: spo2_pct -3.6σ, rad_dose_rate_usv_h +1.2σ, emg_mdf_hz -2.2σ, eeg_alpha_uv2 -1.7σ → riesgo 91% en próximos 30 min.', 'Verificar suministro de O2 y scrubber de CO2; reducir esfuerzo; preparar retorno a la esclusa.', 'open', '2026-11-14 23:38:46.372067-05', NULL);
INSERT INTO public.alerts VALUES (3, 18, 'EVA-001', 'critical', 'Astronauta AST001: patrón compatible con hipoxia/hipercapnia: spo2_pct -1.7σ, rad_dose_rate_usv_h +0.9σ, emg_mdf_hz -1.5σ, eeg_alpha_uv2 -1.0σ, emg_rms_uv -0.5σ → riesgo 75% en próximos 30 min.', 'Verificar suministro de O2 y scrubber de CO2; reducir esfuerzo; preparar retorno a la esclusa.', 'open', '2026-11-14 23:38:46.372067-05', NULL);
INSERT INTO public.alerts VALUES (6, 37, 'EVA-002', 'alert', 'Astronauta AST002: patrón compatible con hipoxia/hipercapnia: spo2_pct -0.9σ, emg_mdf_hz -2.0σ, eeg_alpha_uv2 -2.6σ → riesgo 63% en próximos 30 min.', 'Verificar suministro de O2 y scrubber de CO2; reducir esfuerzo; preparar retorno a la esclusa.', 'open', '2026-11-14 23:38:47.592768-05', NULL);
INSERT INTO public.alerts VALUES (5, 21, 'EVA-002', 'critical', 'Astronauta AST002: patrón compatible con estrés cardíaco: rad_dose_rate_usv_h +1.2σ, hr_bpm +1.6σ, emg_mdf_hz -1.6σ, spo2_pct -0.3σ, eeg_alpha_uv2 -1.0σ → riesgo 78% en próximos 30 min.', 'Confirmar con telemetría y contacto verbal; reducir esfuerzo; alertar al médico de vuelo.', 'acknowledged', '2026-11-14 23:38:47.592768-05', NULL);
INSERT INTO public.alerts VALUES (4, 20, 'EVA-002', 'alert', 'Astronauta AST002: patrón compatible con exposición a radiación: rad_dose_rate_usv_h +0.8σ, spo2_pct -0.2σ, emg_mdf_hz -0.5σ, emg_rms_uv +0.8σ, eeg_alpha_uv2 -0.2σ → riesgo 43% en próximos 30 min.', 'Solicitar refugio/blindaje; consultar clima espacial; registrar dosis acumulada.', 'acknowledged', '2026-11-14 23:38:47.592768-05', NULL);


--
-- Data for Name: astronauts; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.astronauts VALUES ('AST001', 'Ana Torres', NULL, 'ana.torres@example.org', true, '2026-11-14 20:21:39.995334-05');
INSERT INTO public.astronauts VALUES ('AST002', 'Luis Medina', NULL, 'luis.medina@example.org', true, '2026-11-14 20:21:39.995334-05');


--
-- Data for Name: baselines; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.baselines VALUES (1, 'EVA-001', 'hr_bpm', 30, 74.81139, 2.36570, '2026-11-14 23:35:55.694459-05');
INSERT INTO public.baselines VALUES (2, 'EVA-001', 'spo2_pct', 30, 98.49275, 0.53421, '2026-11-14 23:35:55.694459-05');
INSERT INTO public.baselines VALUES (3, 'EVA-001', 'resp_rate_bpm', 30, 14.96755, 0.80541, '2026-11-14 23:35:55.694459-05');
INSERT INTO public.baselines VALUES (4, 'EVA-001', 'core_temp_c', 30, 37.11099, 0.05542, '2026-11-14 23:35:55.694459-05');
INSERT INTO public.baselines VALUES (5, 'EVA-001', 'skin_temp_c', 30, 33.74268, 0.21728, '2026-11-14 23:35:55.694459-05');
INSERT INTO public.baselines VALUES (6, 'EVA-001', 'eeg_theta_beta_ratio', 30, 0.88690, 0.06793, '2026-11-14 23:35:55.694459-05');
INSERT INTO public.baselines VALUES (7, 'EVA-001', 'eeg_alpha_uv2', 30, 126.26983, 5.25717, '2026-11-14 23:35:55.694459-05');
INSERT INTO public.baselines VALUES (8, 'EVA-001', 'eeg_quality', 30, 0.94723, 0.00981, '2026-11-14 23:35:55.694459-05');
INSERT INTO public.baselines VALUES (9, 'EVA-001', 'emg_rms_uv', 30, 43.10451, 2.69188, '2026-11-14 23:35:55.694459-05');
INSERT INTO public.baselines VALUES (10, 'EVA-001', 'emg_mdf_hz', 30, 72.81706, 2.62688, '2026-11-14 23:35:55.694459-05');
INSERT INTO public.baselines VALUES (11, 'EVA-001', 'rad_dose_rate_usv_h', 30, 0.50536, 0.08618, '2026-11-14 23:35:55.694459-05');
INSERT INTO public.baselines VALUES (12, 'EVA-001', 'rad_cum_dose_msv', 30, 0.12752, 0.07415, '2026-11-14 23:35:55.694459-05');
INSERT INTO public.baselines VALUES (13, 'EVA-002', 'hr_bpm', 30, 74.58593, 2.11929, '2026-11-14 23:35:55.694459-05');
INSERT INTO public.baselines VALUES (14, 'EVA-002', 'spo2_pct', 30, 98.27274, 0.49026, '2026-11-14 23:35:55.694459-05');
INSERT INTO public.baselines VALUES (15, 'EVA-002', 'resp_rate_bpm', 30, 15.16507, 0.83781, '2026-11-14 23:35:55.694459-05');
INSERT INTO public.baselines VALUES (16, 'EVA-002', 'core_temp_c', 30, 37.11030, 0.06500, '2026-11-14 23:35:55.694459-05');
INSERT INTO public.baselines VALUES (17, 'EVA-002', 'skin_temp_c', 30, 33.63966, 0.19740, '2026-11-14 23:35:55.694459-05');
INSERT INTO public.baselines VALUES (18, 'EVA-002', 'eeg_theta_beta_ratio', 30, 0.86342, 0.06365, '2026-11-14 23:35:55.694459-05');
INSERT INTO public.baselines VALUES (19, 'EVA-002', 'eeg_alpha_uv2', 30, 125.63915, 5.25901, '2026-11-14 23:35:55.694459-05');
INSERT INTO public.baselines VALUES (20, 'EVA-002', 'eeg_quality', 30, 0.94845, 0.00960, '2026-11-14 23:35:55.694459-05');
INSERT INTO public.baselines VALUES (21, 'EVA-002', 'emg_rms_uv', 30, 43.50239, 3.69230, '2026-11-14 23:35:55.694459-05');
INSERT INTO public.baselines VALUES (22, 'EVA-002', 'emg_mdf_hz', 30, 72.95085, 2.53959, '2026-11-14 23:35:55.694459-05');
INSERT INTO public.baselines VALUES (23, 'EVA-002', 'rad_dose_rate_usv_h', 30, 0.49543, 0.07702, '2026-11-14 23:35:55.694459-05');
INSERT INTO public.baselines VALUES (24, 'EVA-002', 'rad_cum_dose_msv', 30, 0.13133, 0.07086, '2026-11-14 23:35:55.694459-05');


--
-- Data for Name: event_types; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.event_types VALUES ('hipoxia_hipercapnia', 'Hipoxia / Hipercapnia', 'Respiratorio', 'Fallo del sistema de soporte vital, fuga del traje o saturacion de CO2.');
INSERT INTO public.event_types VALUES ('estres_termico', 'Estrés térmico / Hipertermia', 'Sistémico', 'Fallo de regulación térmica del traje o esfuerzo extremo.');
INSERT INTO public.event_types VALUES ('estres_cardiaco', 'Estrés cardíaco / Arritmia', 'Cardiovascular', 'Evento cardiovascular con alteración de FC y SpO2.');
INSERT INTO public.event_types VALUES ('fatiga_lesion_muscular', 'Fatiga / Lesión muscular', 'Físico', 'Esfuerzo extremo prolongado, trauma por presión del traje.');
INSERT INTO public.event_types VALUES ('exposicion_radiacion', 'Exposición a radiación aguda (SPE)', 'Ambiental', 'Evento de partículas solares con aumento sostenido de tasa de dosis.');


--
-- Data for Name: medical_events; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.medical_events VALUES (1, 'EVA-001', 'hipoxia_hipercapnia', 70, 90, NULL, '2026-11-14 23:35:55.694459-05');
INSERT INTO public.medical_events VALUES (2, 'EVA-002', 'estres_termico', 80, 100, NULL, '2026-11-14 23:35:55.694459-05');


--
-- Data for Name: model_metrics; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: models; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.models VALUES (1, 'eva-risk-mvp', '0.1.0', 'heuristic-sigma', 30, '{}', true, '2026-11-14 20:21:39.995334-05');


--
-- Data for Name: predictions; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.predictions VALUES (20, 'EVA-002', 30, 1, 30, 0.42990, 'alert', 'exposicion_radiacion', '[{"score": 0.269, "sigma": 0.77, "variable": "rad_dose_rate_usv_h", "direction": "up"}, {"score": 0.101, "sigma": -0.23, "variable": "spo2_pct", "direction": "down"}, {"score": 0.091, "sigma": -0.53, "variable": "emg_mdf_hz", "direction": "down"}, {"score": 0.077, "sigma": 0.77, "variable": "emg_rms_uv", "direction": "up"}, {"score": 0.024, "sigma": -0.24, "variable": "eeg_alpha_uv2", "direction": "down"}]', '2026-11-14 23:38:47.592768-05');
INSERT INTO public.predictions VALUES (21, 'EVA-002', 35, 1, 30, 0.78350, 'critical', 'estres_cardiaco', '[{"score": 0.426, "sigma": 1.2, "variable": "rad_dose_rate_usv_h", "direction": "up"}, {"score": 0.325, "sigma": 1.55, "variable": "hr_bpm", "direction": "up"}, {"score": 0.27, "sigma": -1.61, "variable": "emg_mdf_hz", "direction": "down"}, {"score": 0.152, "sigma": -0.33, "variable": "spo2_pct", "direction": "down"}, {"score": 0.152, "sigma": -1.03, "variable": "eeg_alpha_uv2", "direction": "down"}]', '2026-11-14 23:38:47.592768-05');
INSERT INTO public.predictions VALUES (22, 'EVA-002', 40, 1, 30, 0.72450, 'critical', 'hipoxia_hipercapnia', '[{"score": 0.834, "sigma": -2.02, "variable": "spo2_pct", "direction": "down"}, {"score": 0.172, "sigma": 0.49, "variable": "rad_dose_rate_usv_h", "direction": "up"}, {"score": 0.165, "sigma": -0.84, "variable": "emg_mdf_hz", "direction": "down"}, {"score": 0.118, "sigma": -0.96, "variable": "eeg_alpha_uv2", "direction": "down"}, {"score": 0.0, "sigma": -0.29, "variable": "eeg_theta_beta_ratio", "direction": "down"}]', '2026-11-14 23:38:47.592768-05');
INSERT INTO public.predictions VALUES (23, 'EVA-002', 45, 1, 30, 0.74670, 'critical', 'hipoxia_hipercapnia', '[{"score": 0.772, "sigma": -1.88, "variable": "spo2_pct", "direction": "down"}, {"score": 0.277, "sigma": -2.47, "variable": "eeg_alpha_uv2", "direction": "down"}, {"score": 0.268, "sigma": -1.64, "variable": "emg_mdf_hz", "direction": "down"}, {"score": 0.056, "sigma": 0.28, "variable": "hr_bpm", "direction": "up"}]', '2026-11-14 23:38:47.592768-05');
INSERT INTO public.predictions VALUES (24, 'EVA-002', 50, 1, 30, 0.89440, 'critical', 'hipoxia_hipercapnia', '[{"score": 1.614, "sigma": -4.13, "variable": "spo2_pct", "direction": "down"}, {"score": 0.347, "sigma": -2.05, "variable": "emg_mdf_hz", "direction": "down"}, {"score": 0.283, "sigma": -2.49, "variable": "eeg_alpha_uv2", "direction": "down"}, {"score": 0.003, "sigma": -0.96, "variable": "rad_dose_rate_usv_h", "direction": "down"}, {"score": 0.001, "sigma": -0.56, "variable": "skin_temp_c", "direction": "down"}]', '2026-11-14 23:38:47.592768-05');
INSERT INTO public.predictions VALUES (25, 'EVA-002', 55, 1, 30, 0.76890, 'critical', 'hipoxia_hipercapnia', '[{"score": 0.489, "sigma": -1.19, "variable": "spo2_pct", "direction": "down"}, {"score": 0.478, "sigma": 1.36, "variable": "rad_dose_rate_usv_h", "direction": "up"}, {"score": 0.424, "sigma": -3.83, "variable": "eeg_alpha_uv2", "direction": "down"}, {"score": 0.073, "sigma": -0.4, "variable": "emg_mdf_hz", "direction": "down"}, {"score": 0.001, "sigma": -1.06, "variable": "skin_temp_c", "direction": "down"}]', '2026-11-14 23:38:47.592768-05');
INSERT INTO public.predictions VALUES (26, 'EVA-002', 60, 1, 30, 0.79590, 'critical', 'hipoxia_hipercapnia', '[{"score": 0.639, "sigma": -1.58, "variable": "spo2_pct", "direction": "down"}, {"score": 0.424, "sigma": 1.21, "variable": "rad_dose_rate_usv_h", "direction": "up"}, {"score": 0.356, "sigma": -3.1, "variable": "eeg_alpha_uv2", "direction": "down"}, {"score": 0.17, "sigma": -1.13, "variable": "emg_mdf_hz", "direction": "down"}]', '2026-11-14 23:38:47.592768-05');
INSERT INTO public.predictions VALUES (27, 'EVA-002', 65, 1, 30, 0.75490, 'critical', 'hipoxia_hipercapnia', '[{"score": 0.641, "sigma": -1.6, "variable": "spo2_pct", "direction": "down"}, {"score": 0.404, "sigma": -2.52, "variable": "emg_mdf_hz", "direction": "down"}, {"score": 0.34, "sigma": -3.4, "variable": "eeg_alpha_uv2", "direction": "down"}, {"score": 0.009, "sigma": -0.71, "variable": "emg_rms_uv", "direction": "down"}, {"score": 0.006, "sigma": -3.01, "variable": "resp_rate_bpm", "direction": "down"}]', '2026-11-14 23:38:47.592768-05');
INSERT INTO public.predictions VALUES (28, 'EVA-002', 70, 1, 30, 0.97080, 'critical', 'estres_cardiaco', '[{"score": 1.392, "sigma": -3.47, "variable": "spo2_pct", "direction": "down"}, {"score": 0.815, "sigma": 3.23, "variable": "core_temp_c", "direction": "up"}, {"score": 0.502, "sigma": 2.06, "variable": "hr_bpm", "direction": "up"}, {"score": 0.411, "sigma": 7.09, "variable": "skin_temp_c", "direction": "up"}, {"score": 0.258, "sigma": -1.72, "variable": "emg_mdf_hz", "direction": "down"}]', '2026-11-14 23:38:47.592768-05');
INSERT INTO public.predictions VALUES (29, 'EVA-002', 75, 1, 30, 0.97040, 'critical', 'estres_termico', '[{"score": 1.02, "sigma": 11.53, "variable": "core_temp_c", "direction": "up"}, {"score": 0.696, "sigma": -1.74, "variable": "spo2_pct", "direction": "down"}, {"score": 0.642, "sigma": 2.72, "variable": "hr_bpm", "direction": "up"}, {"score": 0.422, "sigma": 13.98, "variable": "skin_temp_c", "direction": "up"}, {"score": 0.397, "sigma": 1.14, "variable": "rad_dose_rate_usv_h", "direction": "up"}]', '2026-11-14 23:38:47.592768-05');
INSERT INTO public.predictions VALUES (30, 'EVA-002', 80, 1, 30, 0.98490, 'critical', 'estres_termico', '[{"score": 1.025, "sigma": 21.53, "variable": "core_temp_c", "direction": "up"}, {"score": 0.961, "sigma": 3.54, "variable": "resp_rate_bpm", "direction": "up"}, {"score": 0.899, "sigma": 7.83, "variable": "hr_bpm", "direction": "up"}, {"score": 0.456, "sigma": 1.3, "variable": "rad_dose_rate_usv_h", "direction": "up"}, {"score": 0.427, "sigma": 21.73, "variable": "skin_temp_c", "direction": "up"}]', '2026-11-14 23:38:47.592768-05');
INSERT INTO public.predictions VALUES (31, 'EVA-002', 85, 1, 30, 0.98390, 'critical', 'estres_termico', '[{"score": 1.059, "sigma": 4.1, "variable": "resp_rate_bpm", "direction": "up"}, {"score": 1.018, "sigma": 20.46, "variable": "core_temp_c", "direction": "up"}, {"score": 0.898, "sigma": 9.61, "variable": "hr_bpm", "direction": "up"}, {"score": 0.424, "sigma": 23.71, "variable": "skin_temp_c", "direction": "up"}, {"score": 0.309, "sigma": 0.88, "variable": "rad_dose_rate_usv_h", "direction": "up"}]', '2026-11-14 23:38:47.592768-05');
INSERT INTO public.predictions VALUES (32, 'EVA-002', 90, 1, 30, 0.98250, 'critical', 'estres_termico', '[{"score": 1.006, "sigma": 20.15, "variable": "core_temp_c", "direction": "up"}, {"score": 0.884, "sigma": 9.87, "variable": "hr_bpm", "direction": "up"}, {"score": 0.86, "sigma": 3.3, "variable": "resp_rate_bpm", "direction": "up"}, {"score": 0.532, "sigma": 1.77, "variable": "eeg_theta_beta_ratio", "direction": "up"}, {"score": 0.407, "sigma": 22.14, "variable": "skin_temp_c", "direction": "up"}]', '2026-11-14 23:38:47.592768-05');
INSERT INTO public.predictions VALUES (33, 'EVA-002', 95, 1, 30, 0.97400, 'critical', 'estres_termico', '[{"score": 1.016, "sigma": 5.26, "variable": "resp_rate_bpm", "direction": "up"}, {"score": 1.001, "sigma": 18.76, "variable": "core_temp_c", "direction": "up"}, {"score": 0.8, "sigma": 8.61, "variable": "hr_bpm", "direction": "up"}, {"score": 0.4, "sigma": 22.65, "variable": "skin_temp_c", "direction": "up"}, {"score": 0.199, "sigma": 0.66, "variable": "eeg_theta_beta_ratio", "direction": "up"}]', '2026-11-14 23:38:47.592768-05');
INSERT INTO public.predictions VALUES (34, 'EVA-002', 100, 1, 30, 0.97650, 'critical', 'estres_termico', '[{"score": 1.003, "sigma": 4.29, "variable": "resp_rate_bpm", "direction": "up"}, {"score": 1.0, "sigma": 21.07, "variable": "core_temp_c", "direction": "up"}, {"score": 0.8, "sigma": 8.01, "variable": "hr_bpm", "direction": "up"}, {"score": 0.402, "sigma": 24.32, "variable": "skin_temp_c", "direction": "up"}, {"score": 0.244, "sigma": -1.63, "variable": "emg_mdf_hz", "direction": "down"}]', '2026-11-14 23:38:47.592768-05');
INSERT INTO public.predictions VALUES (35, 'EVA-002', 105, 1, 30, 0.97120, 'critical', 'estres_termico', '[{"score": 1.0, "sigma": 13.69, "variable": "core_temp_c", "direction": "up"}, {"score": 0.81, "sigma": 3.24, "variable": "resp_rate_bpm", "direction": "up"}, {"score": 0.8, "sigma": 5.77, "variable": "hr_bpm", "direction": "up"}, {"score": 0.4, "sigma": 15.81, "variable": "skin_temp_c", "direction": "up"}, {"score": 0.299, "sigma": 0.85, "variable": "rad_dose_rate_usv_h", "direction": "up"}]', '2026-11-14 23:38:47.592768-05');
INSERT INTO public.predictions VALUES (36, 'EVA-002', 110, 1, 30, 0.93030, 'critical', 'estres_termico', '[{"score": 1.0, "sigma": 5.23, "variable": "core_temp_c", "direction": "up"}, {"score": 0.533, "sigma": 1.52, "variable": "rad_dose_rate_usv_h", "direction": "up"}, {"score": 0.4, "sigma": 6.44, "variable": "skin_temp_c", "direction": "up"}, {"score": 0.283, "sigma": -1.61, "variable": "emg_mdf_hz", "direction": "down"}, {"score": 0.265, "sigma": 1.32, "variable": "hr_bpm", "direction": "up"}]', '2026-11-14 23:38:47.592768-05');
INSERT INTO public.predictions VALUES (37, 'EVA-002', 115, 1, 30, 0.63470, 'alert', 'hipoxia_hipercapnia', '[{"score": 0.368, "sigma": -0.88, "variable": "spo2_pct", "direction": "down"}, {"score": 0.33, "sigma": -2.02, "variable": "emg_mdf_hz", "direction": "down"}, {"score": 0.309, "sigma": -2.63, "variable": "eeg_alpha_uv2", "direction": "down"}]', '2026-11-14 23:38:47.592768-05');
INSERT INTO public.predictions VALUES (38, 'EVA-002', 119, 1, 30, 0.61020, 'alert', 'hipoxia_hipercapnia', '[{"score": 0.45, "sigma": -4.15, "variable": "eeg_alpha_uv2", "direction": "down"}, {"score": 0.234, "sigma": -1.35, "variable": "emg_mdf_hz", "direction": "down"}, {"score": 0.138, "sigma": 0.39, "variable": "rad_dose_rate_usv_h", "direction": "up"}, {"score": 0.12, "sigma": -0.29, "variable": "spo2_pct", "direction": "down"}]', '2026-11-14 23:38:47.592768-05');
INSERT INTO public.predictions VALUES (1, 'EVA-001', 30, 1, 30, 0.43900, 'alert', 'hipoxia_hipercapnia', '[{"score": 0.382, "sigma": -0.94, "variable": "spo2_pct", "direction": "down"}, {"score": 0.095, "sigma": 0.95, "variable": "skin_temp_c", "direction": "up"}, {"score": 0.045, "sigma": 0.13, "variable": "rad_dose_rate_usv_h", "direction": "up"}, {"score": 0.03, "sigma": 0.0, "variable": "emg_mdf_hz", "direction": "down"}, {"score": 0.026, "sigma": 0.02, "variable": "eeg_alpha_uv2", "direction": "up"}]', '2026-11-14 23:38:46.372067-05');
INSERT INTO public.predictions VALUES (2, 'EVA-001', 35, 1, 30, 0.25020, 'surveillance', 'hipoxia_hipercapnia', '[{"score": 0.201, "sigma": -1.61, "variable": "eeg_alpha_uv2", "direction": "down"}, {"score": 0.059, "sigma": 0.59, "variable": "emg_rms_uv", "direction": "up"}, {"score": 0.016, "sigma": -0.11, "variable": "emg_mdf_hz", "direction": "down"}, {"score": 0.012, "sigma": 0.01, "variable": "spo2_pct", "direction": "up"}]', '2026-11-14 23:38:46.372067-05');
INSERT INTO public.predictions VALUES (3, 'EVA-001', 40, 1, 30, 0.91440, 'critical', 'hipoxia_hipercapnia', '[{"score": 1.456, "sigma": -3.56, "variable": "spo2_pct", "direction": "down"}, {"score": 0.407, "sigma": 1.16, "variable": "rad_dose_rate_usv_h", "direction": "up"}, {"score": 0.379, "sigma": -2.2, "variable": "emg_mdf_hz", "direction": "down"}, {"score": 0.216, "sigma": -1.7, "variable": "eeg_alpha_uv2", "direction": "down"}]', '2026-11-14 23:38:46.372067-05');
INSERT INTO public.predictions VALUES (4, 'EVA-001', 45, 1, 30, 0.74100, 'critical', 'hipoxia_hipercapnia', '[{"score": 0.851, "sigma": -2.03, "variable": "spo2_pct", "direction": "down"}, {"score": 0.267, "sigma": -2.22, "variable": "eeg_alpha_uv2", "direction": "down"}, {"score": 0.174, "sigma": -0.87, "variable": "emg_mdf_hz", "direction": "down"}, {"score": 0.059, "sigma": 0.16, "variable": "rad_dose_rate_usv_h", "direction": "up"}]', '2026-11-14 23:38:46.372067-05');
INSERT INTO public.predictions VALUES (5, 'EVA-001', 50, 1, 30, 0.83400, 'critical', 'hipoxia_hipercapnia', '[{"score": 1.256, "sigma": -3.11, "variable": "spo2_pct", "direction": "down"}, {"score": 0.489, "sigma": -3.06, "variable": "emg_mdf_hz", "direction": "down"}, {"score": 0.051, "sigma": -0.51, "variable": "eeg_alpha_uv2", "direction": "down"}]', '2026-11-14 23:38:46.372067-05');
INSERT INTO public.predictions VALUES (6, 'EVA-001', 55, 1, 30, 0.90690, 'critical', 'hipoxia_hipercapnia', '[{"score": 1.488, "sigma": -3.69, "variable": "spo2_pct", "direction": "down"}, {"score": 0.54, "sigma": -3.37, "variable": "emg_mdf_hz", "direction": "down"}, {"score": 0.346, "sigma": -3.46, "variable": "eeg_alpha_uv2", "direction": "down"}]', '2026-11-14 23:38:46.372067-05');
INSERT INTO public.predictions VALUES (7, 'EVA-001', 60, 1, 30, 0.97990, 'critical', 'hipoxia_hipercapnia', '[{"score": 1.695, "sigma": -8.54, "variable": "spo2_pct", "direction": "down"}, {"score": 0.746, "sigma": 2.77, "variable": "resp_rate_bpm", "direction": "up"}, {"score": 0.447, "sigma": -4.7, "variable": "eeg_alpha_uv2", "direction": "down"}, {"score": 0.412, "sigma": -2.65, "variable": "emg_mdf_hz", "direction": "down"}, {"score": 0.369, "sigma": 1.21, "variable": "eeg_theta_beta_ratio", "direction": "up"}]', '2026-11-14 23:38:46.372067-05');
INSERT INTO public.predictions VALUES (8, 'EVA-001', 65, 1, 30, 0.99560, 'critical', 'hipoxia_hipercapnia', '[{"score": 1.743, "sigma": -13.3, "variable": "spo2_pct", "direction": "down"}, {"score": 1.216, "sigma": 8.99, "variable": "eeg_theta_beta_ratio", "direction": "up"}, {"score": 1.108, "sigma": 7.83, "variable": "resp_rate_bpm", "direction": "up"}, {"score": 0.9, "sigma": 5.75, "variable": "hr_bpm", "direction": "up"}, {"score": 0.45, "sigma": -5.47, "variable": "eeg_alpha_uv2", "direction": "down"}]', '2026-11-14 23:38:46.372067-05');
INSERT INTO public.predictions VALUES (9, 'EVA-001', 70, 1, 30, 0.99720, 'critical', 'hipoxia_hipercapnia', '[{"score": 1.769, "sigma": -20.56, "variable": "spo2_pct", "direction": "down"}, {"score": 1.221, "sigma": 12.7, "variable": "eeg_theta_beta_ratio", "direction": "up"}, {"score": 1.116, "sigma": 13.65, "variable": "resp_rate_bpm", "direction": "up"}, {"score": 0.9, "sigma": 9.61, "variable": "hr_bpm", "direction": "up"}, {"score": 0.45, "sigma": -6.41, "variable": "eeg_alpha_uv2", "direction": "down"}]', '2026-11-14 23:38:46.372067-05');
INSERT INTO public.predictions VALUES (10, 'EVA-001', 75, 1, 30, 0.99640, 'critical', 'hipoxia_hipercapnia', '[{"score": 1.745, "sigma": -18.61, "variable": "spo2_pct", "direction": "down"}, {"score": 1.216, "sigma": 13.95, "variable": "eeg_theta_beta_ratio", "direction": "up"}, {"score": 1.106, "sigma": 13.88, "variable": "resp_rate_bpm", "direction": "up"}, {"score": 0.899, "sigma": 10.49, "variable": "hr_bpm", "direction": "up"}, {"score": 0.449, "sigma": -8.63, "variable": "eeg_alpha_uv2", "direction": "down"}]', '2026-11-14 23:38:46.372067-05');
INSERT INTO public.predictions VALUES (11, 'EVA-001', 80, 1, 30, 0.99500, 'critical', 'hipoxia_hipercapnia', '[{"score": 1.632, "sigma": -18.5, "variable": "spo2_pct", "direction": "down"}, {"score": 1.207, "sigma": 13.35, "variable": "eeg_theta_beta_ratio", "direction": "up"}, {"score": 1.058, "sigma": 15.82, "variable": "resp_rate_bpm", "direction": "up"}, {"score": 0.891, "sigma": 11.1, "variable": "hr_bpm", "direction": "up"}, {"score": 0.416, "sigma": -6.72, "variable": "eeg_alpha_uv2", "direction": "down"}]', '2026-11-14 23:38:46.372067-05');
INSERT INTO public.predictions VALUES (12, 'EVA-001', 85, 1, 30, 0.99520, 'critical', 'hipoxia_hipercapnia', '[{"score": 1.6, "sigma": -20.86, "variable": "spo2_pct", "direction": "down"}, {"score": 1.201, "sigma": 14.88, "variable": "eeg_theta_beta_ratio", "direction": "up"}, {"score": 1.029, "sigma": 14.39, "variable": "resp_rate_bpm", "direction": "up"}, {"score": 0.861, "sigma": 11.0, "variable": "hr_bpm", "direction": "up"}, {"score": 0.4, "sigma": -7.73, "variable": "eeg_alpha_uv2", "direction": "down"}]', '2026-11-14 23:38:46.372067-05');
INSERT INTO public.predictions VALUES (13, 'EVA-001', 90, 1, 30, 0.99730, 'critical', 'hipoxia_hipercapnia', '[{"score": 1.6, "sigma": -18.37, "variable": "spo2_pct", "direction": "down"}, {"score": 1.201, "sigma": 14.77, "variable": "eeg_theta_beta_ratio", "direction": "up"}, {"score": 1.033, "sigma": 14.21, "variable": "resp_rate_bpm", "direction": "up"}, {"score": 0.814, "sigma": 11.51, "variable": "hr_bpm", "direction": "up"}, {"score": 0.4, "sigma": -7.13, "variable": "eeg_alpha_uv2", "direction": "down"}]', '2026-11-14 23:38:46.372067-05');
INSERT INTO public.predictions VALUES (14, 'EVA-001', 95, 1, 30, 0.99520, 'critical', 'hipoxia_hipercapnia', '[{"score": 1.6, "sigma": -11.42, "variable": "spo2_pct", "direction": "down"}, {"score": 1.2, "sigma": 10.31, "variable": "eeg_theta_beta_ratio", "direction": "up"}, {"score": 1.0, "sigma": 10.87, "variable": "resp_rate_bpm", "direction": "up"}, {"score": 0.8, "sigma": 6.97, "variable": "hr_bpm", "direction": "up"}, {"score": 0.4, "sigma": -5.98, "variable": "eeg_alpha_uv2", "direction": "down"}]', '2026-11-14 23:38:46.372067-05');
INSERT INTO public.predictions VALUES (15, 'EVA-001', 100, 1, 30, 0.99360, 'critical', 'hipoxia_hipercapnia', '[{"score": 1.6, "sigma": -5.75, "variable": "spo2_pct", "direction": "down"}, {"score": 1.036, "sigma": 3.45, "variable": "eeg_theta_beta_ratio", "direction": "up"}, {"score": 1.0, "sigma": 4.31, "variable": "resp_rate_bpm", "direction": "up"}, {"score": 0.735, "sigma": 3.68, "variable": "hr_bpm", "direction": "up"}, {"score": 0.357, "sigma": 1.43, "variable": "core_temp_c", "direction": "up"}]', '2026-11-14 23:38:46.372067-05');
INSERT INTO public.predictions VALUES (16, 'EVA-001', 105, 1, 30, 0.34560, 'surveillance', 'hipoxia_hipercapnia', '[{"score": 0.369, "sigma": -0.92, "variable": "spo2_pct", "direction": "down"}, {"score": 0.055, "sigma": -0.24, "variable": "emg_mdf_hz", "direction": "down"}]', '2026-11-14 23:38:46.372067-05');
INSERT INTO public.predictions VALUES (17, 'EVA-001', 110, 1, 30, 0.11040, 'surveillance', 'fatiga_lesion_muscular', '[{"score": 0.062, "sigma": -0.28, "variable": "emg_mdf_hz", "direction": "down"}, {"score": 0.053, "sigma": -0.53, "variable": "eeg_alpha_uv2", "direction": "down"}, {"score": 0.002, "sigma": -1.32, "variable": "rad_dose_rate_usv_h", "direction": "down"}]', '2026-11-14 23:38:46.372067-05');
INSERT INTO public.predictions VALUES (18, 'EVA-001', 115, 1, 30, 0.74640, 'critical', 'hipoxia_hipercapnia', '[{"score": 0.668, "sigma": -1.67, "variable": "spo2_pct", "direction": "down"}, {"score": 0.305, "sigma": 0.87, "variable": "rad_dose_rate_usv_h", "direction": "up"}, {"score": 0.263, "sigma": -1.47, "variable": "emg_mdf_hz", "direction": "down"}, {"score": 0.134, "sigma": -1.0, "variable": "eeg_alpha_uv2", "direction": "down"}, {"score": 0.002, "sigma": -0.54, "variable": "emg_rms_uv", "direction": "down"}]', '2026-11-14 23:38:46.372067-05');
INSERT INTO public.predictions VALUES (19, 'EVA-001', 119, 1, 30, 0.67830, 'critical', 'hipoxia_hipercapnia', '[{"score": 0.485, "sigma": -1.18, "variable": "spo2_pct", "direction": "down"}, {"score": 0.31, "sigma": 0.88, "variable": "rad_dose_rate_usv_h", "direction": "up"}, {"score": 0.185, "sigma": -1.4, "variable": "eeg_alpha_uv2", "direction": "down"}, {"score": 0.154, "sigma": -0.74, "variable": "emg_mdf_hz", "direction": "down"}]', '2026-11-14 23:38:46.372067-05');


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.sessions VALUES ('EVA-001', 'AST001', '2026-01-10 03:00:00-05', '2026-01-10 04:59:00-05', '{}', '2026-11-14 23:35:55.694459-05');
INSERT INTO public.sessions VALUES ('EVA-002', 'AST002', '2026-01-10 05:00:00-05', '2026-01-10 06:59:00-05', '{}', '2026-11-14 23:35:55.694459-05');


--
-- Data for Name: telemetry; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.telemetry VALUES (1, 'EVA-001', 0, '2026-01-10 03:00:00-05', 71.71, 97.91, 13.92, 37.04, 33.47, 0.7251, 121.662, 0.9473, 39.349, 70.232, 0.5186, 0.0086);
INSERT INTO public.telemetry VALUES (2, 'EVA-001', 1, '2026-01-10 03:01:00-05', 74.58, 98.38, 14.18, 36.98, 33.32, 0.8206, 127.221, 0.9504, 40.097, 71.397, 0.3837, 0.0150);
INSERT INTO public.telemetry VALUES (3, 'EVA-001', 2, '2026-01-10 03:02:00-05', 71.87, 98.34, 14.81, 37.01, 33.63, 0.8290, 125.239, 0.9389, 42.534, 67.635, 0.2904, 0.0199);
INSERT INTO public.telemetry VALUES (4, 'EVA-001', 3, '2026-01-10 03:03:00-05', 71.53, 97.69, 14.91, 37.07, 33.33, 0.8671, 116.968, 0.9491, 40.355, 71.219, 0.5655, 0.0293);
INSERT INTO public.telemetry VALUES (5, 'EVA-001', 4, '2026-01-10 03:04:00-05', 74.26, 98.37, 14.85, 37.07, 33.47, 0.7969, 120.268, 0.9550, 40.886, 75.980, 0.4345, 0.0365);
INSERT INTO public.telemetry VALUES (6, 'EVA-001', 5, '2026-01-10 03:05:00-05', 71.02, 98.63, 15.48, 37.09, 33.79, 0.9118, 122.768, 0.9358, 40.427, 73.525, 0.3845, 0.0430);
INSERT INTO public.telemetry VALUES (7, 'EVA-001', 6, '2026-01-10 03:06:00-05', 73.51, 98.41, 14.35, 37.11, 33.76, 0.9640, 126.935, 0.9439, 40.712, 70.255, 0.5762, 0.0526);
INSERT INTO public.telemetry VALUES (8, 'EVA-001', 7, '2026-01-10 03:07:00-05', 72.52, 98.30, 15.19, 37.05, 33.61, 0.7630, 118.994, 0.9443, 44.001, 74.590, 0.4985, 0.0609);
INSERT INTO public.telemetry VALUES (9, 'EVA-001', 8, '2026-01-10 03:08:00-05', 74.38, 98.46, 15.50, 37.14, 33.74, 0.8113, 129.464, 0.9538, 46.773, 72.414, 0.6562, 0.0718);
INSERT INTO public.telemetry VALUES (10, 'EVA-001', 9, '2026-01-10 03:09:00-05', 73.33, 99.21, 14.90, 37.08, 33.48, 0.8606, 132.570, 0.9582, 45.475, 67.975, 0.5569, 0.0811);
INSERT INTO public.telemetry VALUES (11, 'EVA-001', 10, '2026-01-10 03:10:00-05', 75.33, 98.17, 14.45, 37.11, 34.07, 0.8213, 123.782, 0.9636, 42.362, 72.232, 0.5078, 0.0895);
INSERT INTO public.telemetry VALUES (12, 'EVA-001', 11, '2026-01-10 03:11:00-05', 71.90, 98.59, 14.11, 37.16, 33.74, 0.9935, 127.753, 0.9637, 40.058, 72.930, 0.5259, 0.0983);
INSERT INTO public.telemetry VALUES (13, 'EVA-001', 12, '2026-01-10 03:12:00-05', 78.02, 97.66, 15.70, 37.16, 34.06, 0.9198, 126.992, 0.9448, 40.463, 73.757, 0.4847, 0.1064);
INSERT INTO public.telemetry VALUES (14, 'EVA-001', 13, '2026-01-10 03:13:00-05', 78.69, 98.22, 15.28, 37.05, 33.69, 0.9014, 131.188, 0.9645, 44.285, 71.300, 0.5366, 0.1153);
INSERT INTO public.telemetry VALUES (15, 'EVA-001', 14, '2026-01-10 03:14:00-05', 75.79, 98.80, 14.61, 37.19, 33.79, 0.9269, 133.726, 0.9561, 45.457, 77.983, 0.5195, 0.1240);
INSERT INTO public.telemetry VALUES (16, 'EVA-001', 15, '2026-01-10 03:15:00-05', 74.26, 98.63, 16.18, 37.15, 33.89, 0.9547, 125.028, 0.9327, 45.643, 74.255, 0.4514, 0.1315);
INSERT INTO public.telemetry VALUES (17, 'EVA-001', 16, '2026-01-10 03:16:00-05', 76.66, 98.89, 14.47, 37.17, 33.75, 0.8230, 130.040, 0.9495, 42.624, 74.934, 0.5390, 0.1405);
INSERT INTO public.telemetry VALUES (18, 'EVA-001', 17, '2026-01-10 03:17:00-05', 73.81, 98.79, 15.90, 37.11, 33.87, 0.8990, 139.235, 0.9314, 47.027, 73.340, 0.4920, 0.1487);
INSERT INTO public.telemetry VALUES (19, 'EVA-001', 18, '2026-01-10 03:18:00-05', 78.80, 98.59, 16.77, 37.13, 33.87, 0.8752, 124.527, 0.9506, 44.140, 74.395, 0.3316, 0.1542);
INSERT INTO public.telemetry VALUES (20, 'EVA-001', 19, '2026-01-10 03:19:00-05', 79.00, 98.52, 16.42, 37.10, 33.86, 1.0582, 123.651, 0.9350, 43.360, 74.945, 0.5555, 0.1635);
INSERT INTO public.telemetry VALUES (21, 'EVA-001', 20, '2026-01-10 03:20:00-05', 77.57, 98.47, 14.07, 37.13, 34.05, 0.9228, 118.179, 0.9496, 49.172, 78.235, 0.5449, 0.1726);
INSERT INTO public.telemetry VALUES (22, 'EVA-001', 21, '2026-01-10 03:21:00-05', 75.57, 97.97, 14.59, 37.15, 33.90, 0.9274, 125.481, 0.9385, 42.587, 71.622, 0.5515, 0.1818);
INSERT INTO public.telemetry VALUES (23, 'EVA-001', 22, '2026-01-10 03:22:00-05', 70.27, 98.41, 15.47, 37.22, 33.80, 0.9466, 125.731, 0.9426, 42.806, 76.918, 0.5795, 0.1914);
INSERT INTO public.telemetry VALUES (24, 'EVA-001', 23, '2026-01-10 03:23:00-05', 75.80, 100.00, 15.11, 37.17, 33.84, 0.8830, 139.107, 0.9651, 40.506, 72.963, 0.5343, 0.2003);
INSERT INTO public.telemetry VALUES (25, 'EVA-001', 24, '2026-01-10 03:24:00-05', 76.29, 97.87, 13.51, 37.04, 33.76, 0.8858, 129.001, 0.9423, 40.874, 69.591, 0.5263, 0.2091);
INSERT INTO public.telemetry VALUES (26, 'EVA-001', 25, '2026-01-10 03:25:00-05', 75.35, 99.02, 15.60, 37.12, 34.03, 0.8803, 123.668, 0.9448, 42.603, 69.155, 0.5125, 0.2176);
INSERT INTO public.telemetry VALUES (27, 'EVA-001', 26, '2026-01-10 03:26:00-05', 74.98, 98.32, 14.49, 37.14, 34.09, 0.8847, 124.083, 0.9441, 43.929, 70.781, 0.4900, 0.2258);
INSERT INTO public.telemetry VALUES (28, 'EVA-001', 27, '2026-01-10 03:27:00-05', 74.46, 99.39, 15.59, 37.17, 33.59, 0.9113, 120.528, 0.9531, 45.147, 71.580, 0.6600, 0.2368);
INSERT INTO public.telemetry VALUES (29, 'EVA-001', 28, '2026-01-10 03:28:00-05', 75.30, 97.48, 15.25, 37.09, 33.72, 0.8956, 127.737, 0.9296, 40.141, 74.438, 0.6041, 0.2469);
INSERT INTO public.telemetry VALUES (30, 'EVA-001', 29, '2026-01-10 03:29:00-05', 77.80, 99.30, 13.36, 37.14, 33.32, 0.9470, 126.571, 0.9386, 49.345, 73.940, 0.3487, 0.2527);
INSERT INTO public.telemetry VALUES (31, 'EVA-001', 30, '2026-01-10 03:30:00-05', 74.38, 97.99, 14.80, 37.07, 33.95, 0.7887, 126.375, 0.9681, 40.512, 72.815, 0.5162, 0.2613);
INSERT INTO public.telemetry VALUES (32, 'EVA-001', 31, '2026-01-10 03:31:00-05', 72.21, 98.64, 14.70, 37.03, 34.01, 0.8926, 123.402, 0.9436, 40.296, 74.581, 0.4883, 0.2694);
INSERT INTO public.telemetry VALUES (33, 'EVA-001', 32, '2026-01-10 03:32:00-05', 74.29, 98.18, 14.98, 37.06, 33.79, 0.8366, 127.806, 0.9567, 41.937, 70.110, 0.4248, 0.2765);
INSERT INTO public.telemetry VALUES (34, 'EVA-001', 33, '2026-01-10 03:33:00-05', 71.66, 97.74, 15.06, 37.05, 33.93, 0.9521, 123.174, 0.9345, 40.764, 71.376, 0.3809, 0.2828);
INSERT INTO public.telemetry VALUES (35, 'EVA-001', 34, '2026-01-10 03:34:00-05', 72.41, 98.33, 14.04, 37.01, 33.44, 0.9197, 121.629, 0.9417, 40.398, 73.122, 0.4452, 0.2903);
INSERT INTO public.telemetry VALUES (36, 'EVA-001', 35, '2026-01-10 03:35:00-05', 73.63, 98.50, 14.79, 37.10, 33.46, 0.8789, 117.820, 0.9460, 44.703, 72.537, 0.5002, 0.2986);
INSERT INTO public.telemetry VALUES (37, 'EVA-001', 36, '2026-01-10 03:36:00-05', 70.04, 98.37, 13.73, 36.98, 33.41, 0.8264, 110.524, 0.9536, 41.227, 69.395, 0.5830, 0.3083);
INSERT INTO public.telemetry VALUES (38, 'EVA-001', 37, '2026-01-10 03:37:00-05', 73.40, 97.73, 13.60, 37.04, 33.21, 0.7892, 117.311, 0.9507, 40.925, 70.307, 0.5908, 0.3182);
INSERT INTO public.telemetry VALUES (39, 'EVA-001', 38, '2026-01-10 03:38:00-05', 72.38, 97.83, 13.12, 37.03, 33.60, 0.8700, 116.062, 0.9503, 39.699, 69.725, 0.5008, 0.3265);
INSERT INTO public.telemetry VALUES (40, 'EVA-001', 39, '2026-01-10 03:39:00-05', 68.25, 98.35, 14.33, 37.04, 33.92, 0.7732, 118.954, 0.9501, 45.286, 66.105, 0.5389, 0.3355);
INSERT INTO public.telemetry VALUES (41, 'EVA-001', 40, '2026-01-10 03:40:00-05', 68.49, 96.59, 12.36, 36.90, 33.66, 0.7375, 117.338, 0.9384, 40.880, 67.034, 0.6054, 0.3456);
INSERT INTO public.telemetry VALUES (42, 'EVA-001', 41, '2026-01-10 03:41:00-05', 69.20, 97.45, 13.76, 36.96, 33.70, 0.7789, 111.788, 0.9444, 36.924, 70.364, 0.5307, 0.3544);
INSERT INTO public.telemetry VALUES (43, 'EVA-001', 42, '2026-01-10 03:42:00-05', 70.71, 98.22, 13.21, 36.94, 33.43, 0.8413, 116.701, 0.9465, 35.109, 69.969, 0.4530, 0.3620);
INSERT INTO public.telemetry VALUES (44, 'EVA-001', 43, '2026-01-10 03:43:00-05', 71.40, 96.79, 14.22, 36.87, 33.22, 0.8102, 109.908, 0.9492, 38.085, 66.293, 0.6074, 0.3721);
INSERT INTO public.telemetry VALUES (45, 'EVA-001', 44, '2026-01-10 03:44:00-05', 73.49, 96.71, 12.38, 36.97, 33.09, 0.7304, 116.638, 0.9569, 36.824, 68.185, 0.4379, 0.3794);
INSERT INTO public.telemetry VALUES (46, 'EVA-001', 45, '2026-01-10 03:45:00-05', 72.87, 97.41, 13.55, 36.89, 33.35, 0.7344, 114.615, 0.9399, 39.531, 70.542, 0.5195, 0.3881);
INSERT INTO public.telemetry VALUES (47, 'EVA-001', 46, '2026-01-10 03:46:00-05', 71.55, 98.04, 13.88, 36.92, 33.35, 0.7794, 115.241, 0.9403, 36.882, 63.672, 0.4995, 0.3964);
INSERT INTO public.telemetry VALUES (48, 'EVA-001', 47, '2026-01-10 03:47:00-05', 70.73, 98.20, 13.27, 36.94, 33.29, 0.6788, 107.345, 0.9403, 32.403, 68.468, 0.4834, 0.4044);
INSERT INTO public.telemetry VALUES (49, 'EVA-001', 48, '2026-01-10 03:48:00-05', 70.87, 97.58, 13.82, 36.94, 33.14, 0.7106, 111.281, 0.9338, 38.242, 69.350, 0.4995, 0.4128);
INSERT INTO public.telemetry VALUES (50, 'EVA-001', 49, '2026-01-10 03:49:00-05', 68.59, 98.06, 11.39, 36.89, 33.29, 0.6906, 120.489, 0.9597, 35.174, 66.592, 0.4690, 0.4206);
INSERT INTO public.telemetry VALUES (51, 'EVA-001', 50, '2026-01-10 03:50:00-05', 68.41, 96.83, 13.94, 36.92, 33.40, 0.6598, 123.566, 0.9698, 36.290, 64.773, 0.4307, 0.4278);
INSERT INTO public.telemetry VALUES (52, 'EVA-001', 51, '2026-01-10 03:51:00-05', 70.15, 97.01, 12.90, 36.92, 32.93, 0.8108, 120.674, 0.9376, 31.284, 65.853, 0.4175, 0.4347);
INSERT INTO public.telemetry VALUES (53, 'EVA-001', 52, '2026-01-10 03:52:00-05', 68.69, 96.15, 12.73, 36.95, 33.00, 0.6934, 105.120, 0.9564, 34.679, 70.165, 0.5165, 0.4433);
INSERT INTO public.telemetry VALUES (54, 'EVA-001', 53, '2026-01-10 03:53:00-05', 68.39, 97.70, 12.50, 36.79, 33.27, 0.6956, 113.179, 0.9538, 33.686, 67.017, 0.6390, 0.4540);
INSERT INTO public.telemetry VALUES (55, 'EVA-001', 54, '2026-01-10 03:54:00-05', 66.85, 98.28, 12.66, 36.82, 33.69, 0.7100, 119.032, 0.9582, 30.071, 66.332, 0.4580, 0.4616);
INSERT INTO public.telemetry VALUES (56, 'EVA-001', 55, '2026-01-10 03:55:00-05', 66.34, 96.52, 12.88, 36.88, 33.28, 0.6855, 108.074, 0.9401, 33.376, 63.967, 0.4837, 0.4697);
INSERT INTO public.telemetry VALUES (57, 'EVA-001', 56, '2026-01-10 03:56:00-05', 70.82, 96.29, 13.44, 36.81, 33.20, 0.7921, 110.566, 0.9547, 30.049, 65.247, 0.5221, 0.4784);
INSERT INTO public.telemetry VALUES (58, 'EVA-001', 57, '2026-01-10 03:57:00-05', 74.02, 95.27, 14.51, 36.91, 33.16, 0.8287, 109.591, 0.9525, 37.027, 66.148, 0.5122, 0.4869);
INSERT INTO public.telemetry VALUES (59, 'EVA-001', 58, '2026-01-10 03:58:00-05', 73.06, 95.32, 16.09, 36.84, 33.17, 0.8762, 108.994, 0.9415, 37.768, 64.155, 0.4154, 0.4938);
INSERT INTO public.telemetry VALUES (60, 'EVA-001', 59, '2026-01-10 03:59:00-05', 76.94, 94.81, 16.23, 36.91, 33.12, 0.9909, 98.284, 0.9626, 37.001, 67.156, 0.5150, 0.5024);
INSERT INTO public.telemetry VALUES (61, 'EVA-001', 60, '2026-01-10 04:00:00-05', 76.89, 93.93, 17.20, 36.86, 33.24, 0.9694, 101.567, 0.9431, 31.955, 65.855, 0.3515, 0.5083);
INSERT INTO public.telemetry VALUES (62, 'EVA-001', 61, '2026-01-10 04:01:00-05', 81.80, 93.87, 17.64, 36.81, 33.03, 1.0992, 86.425, 0.9518, 37.333, 65.648, 0.4604, 0.5160);
INSERT INTO public.telemetry VALUES (63, 'EVA-001', 62, '2026-01-10 04:02:00-05', 82.73, 92.97, 19.29, 36.87, 33.09, 1.1537, 97.388, 0.9656, 34.546, 64.301, 0.4304, 0.5231);
INSERT INTO public.telemetry VALUES (64, 'EVA-001', 63, '2026-01-10 04:03:00-05', 80.16, 92.32, 18.42, 36.81, 32.85, 1.1915, 97.304, 0.9369, 30.456, 66.921, 0.4727, 0.5310);
INSERT INTO public.telemetry VALUES (65, 'EVA-001', 64, '2026-01-10 04:04:00-05', 87.22, 91.88, 20.22, 36.81, 33.23, 1.3437, 89.578, 0.9356, 39.241, 65.916, 0.4673, 0.5388);
INSERT INTO public.telemetry VALUES (66, 'EVA-001', 65, '2026-01-10 04:05:00-05', 88.41, 91.39, 21.27, 36.87, 33.41, 1.4978, 97.509, 0.9567, 32.823, 74.456, 0.4041, 0.5455);
INSERT INTO public.telemetry VALUES (67, 'EVA-001', 66, '2026-01-10 04:06:00-05', 89.67, 89.89, 23.09, 36.92, 33.00, 1.4762, 91.424, 0.9468, 32.812, 65.728, 0.4651, 0.5533);
INSERT INTO public.telemetry VALUES (68, 'EVA-001', 67, '2026-01-10 04:07:00-05', 92.51, 89.35, 23.34, 36.86, 32.96, 1.4986, 93.592, 0.9443, 43.802, 68.407, 0.4068, 0.5601);
INSERT INTO public.telemetry VALUES (69, 'EVA-001', 68, '2026-01-10 04:08:00-05', 92.86, 89.11, 22.88, 37.03, 33.13, 1.6429, 92.342, 0.9489, 34.121, 67.141, 0.5290, 0.5689);
INSERT INTO public.telemetry VALUES (70, 'EVA-001', 69, '2026-01-10 04:09:00-05', 98.36, 88.39, 23.61, 36.93, 33.21, 1.5733, 79.779, 0.9357, 39.219, 71.855, 0.6487, 0.5797);
INSERT INTO public.telemetry VALUES (71, 'EVA-001', 70, '2026-01-10 04:10:00-05', 97.55, 87.51, 25.96, 36.99, 33.29, 1.7494, 92.556, 0.9489, 36.370, 68.501, 0.5464, 0.5888);
INSERT INTO public.telemetry VALUES (72, 'EVA-001', 71, '2026-01-10 04:11:00-05', 96.88, 87.66, 24.75, 36.93, 33.77, 1.8012, 81.670, 0.9407, 37.274, 70.668, 0.4551, 0.5964);
INSERT INTO public.telemetry VALUES (73, 'EVA-001', 72, '2026-01-10 04:12:00-05', 102.06, 87.15, 25.46, 37.05, 33.01, 1.8315, 73.508, 0.9491, 38.085, 70.531, 0.2476, 0.6005);
INSERT INTO public.telemetry VALUES (74, 'EVA-001', 73, '2026-01-10 04:13:00-05', 95.57, 87.60, 25.79, 36.93, 33.40, 1.7208, 81.405, 0.9415, 39.739, 70.369, 0.6146, 0.6107);
INSERT INTO public.telemetry VALUES (75, 'EVA-001', 74, '2026-01-10 04:14:00-05', 98.34, 87.77, 25.89, 36.97, 33.45, 1.7103, 85.929, 0.9408, 36.548, 66.359, 0.5929, 0.6206);
INSERT INTO public.telemetry VALUES (76, 'EVA-001', 75, '2026-01-10 04:15:00-05', 99.62, 88.55, 26.15, 36.91, 33.27, 1.8346, 80.906, 0.9391, 39.296, 69.513, 0.4191, 0.6276);
INSERT INTO public.telemetry VALUES (77, 'EVA-001', 76, '2026-01-10 04:16:00-05', 99.50, 87.79, 24.25, 37.03, 33.35, 1.8702, 79.650, 0.9342, 43.814, 67.030, 0.4491, 0.6351);
INSERT INTO public.telemetry VALUES (78, 'EVA-001', 77, '2026-01-10 04:17:00-05', 101.59, 87.92, 25.00, 37.03, 33.50, 1.8775, 89.008, 0.9804, 35.728, 70.489, 0.4147, 0.6420);
INSERT INTO public.telemetry VALUES (79, 'EVA-001', 78, '2026-01-10 04:18:00-05', 102.95, 88.54, 26.79, 36.99, 33.42, 1.7200, 95.269, 0.9551, 40.293, 72.728, 0.5601, 0.6513);
INSERT INTO public.telemetry VALUES (80, 'EVA-001', 79, '2026-01-10 04:19:00-05', 102.84, 87.37, 25.86, 37.05, 33.66, 1.8774, 82.322, 0.9513, 48.094, 72.567, 0.5696, 0.6608);
INSERT INTO public.telemetry VALUES (81, 'EVA-001', 80, '2026-01-10 04:20:00-05', 101.08, 88.61, 27.71, 37.06, 33.86, 1.7937, 90.944, 0.9590, 39.615, 73.693, 0.4460, 0.6683);
INSERT INTO public.telemetry VALUES (82, 'EVA-001', 81, '2026-01-10 04:21:00-05', 99.74, 88.27, 27.89, 37.08, 33.82, 1.8084, 88.988, 0.9382, 40.537, 73.472, 0.4969, 0.6766);
INSERT INTO public.telemetry VALUES (83, 'EVA-001', 82, '2026-01-10 04:22:00-05', 104.47, 88.21, 26.49, 37.14, 33.53, 1.7763, 95.689, 0.9541, 36.119, 72.180, 0.4677, 0.6843);
INSERT INTO public.telemetry VALUES (84, 'EVA-001', 83, '2026-01-10 04:23:00-05', 105.27, 87.99, 26.30, 37.04, 33.47, 1.8242, 82.556, 0.9397, 38.140, 69.373, 0.3752, 0.6906);
INSERT INTO public.telemetry VALUES (85, 'EVA-001', 84, '2026-01-10 04:24:00-05', 100.93, 88.05, 25.93, 37.12, 33.69, 1.8441, 87.936, 0.9659, 44.004, 73.579, 0.2931, 0.6955);
INSERT INTO public.telemetry VALUES (86, 'EVA-001', 85, '2026-01-10 04:25:00-05', 100.84, 87.35, 26.56, 37.13, 33.58, 1.8977, 85.626, 0.9558, 38.927, 72.347, 0.5336, 0.7044);
INSERT INTO public.telemetry VALUES (87, 'EVA-001', 86, '2026-01-10 04:26:00-05', 103.39, 88.40, 28.29, 37.10, 33.64, 1.7393, 100.028, 0.9463, 40.337, 75.734, 0.5988, 0.7144);
INSERT INTO public.telemetry VALUES (88, 'EVA-001', 87, '2026-01-10 04:27:00-05', 102.69, 87.78, 27.28, 37.09, 33.51, 1.9345, 80.922, 0.9557, 45.494, 77.394, 0.5260, 0.7231);
INSERT INTO public.telemetry VALUES (89, 'EVA-001', 88, '2026-01-10 04:28:00-05', 98.49, 88.10, 27.09, 37.15, 33.96, 1.7888, 90.290, 0.9597, 48.969, 77.192, 0.4688, 0.7309);
INSERT INTO public.telemetry VALUES (90, 'EVA-001', 89, '2026-01-10 04:29:00-05', 104.91, 89.40, 27.93, 37.17, 33.94, 1.8511, 85.011, 0.9598, 43.488, 73.567, 0.4537, 0.7385);
INSERT INTO public.telemetry VALUES (91, 'EVA-001', 90, '2026-01-10 04:30:00-05', 102.03, 88.68, 26.41, 37.14, 33.83, 1.8899, 88.786, 0.9579, 50.308, 72.550, 0.5988, 0.7485);
INSERT INTO public.telemetry VALUES (92, 'EVA-001', 91, '2026-01-10 04:31:00-05', 102.80, 87.92, 25.82, 37.11, 33.95, 1.8391, 97.414, 0.9564, 42.121, 72.361, 0.4022, 0.7552);
INSERT INTO public.telemetry VALUES (93, 'EVA-001', 92, '2026-01-10 04:32:00-05', 98.87, 89.86, 25.70, 37.11, 33.98, 1.8108, 105.259, 0.9571, 45.469, 75.275, 0.5488, 0.7643);
INSERT INTO public.telemetry VALUES (94, 'EVA-001', 93, '2026-01-10 04:33:00-05', 96.08, 91.24, 26.00, 37.25, 33.81, 1.7157, 102.039, 0.9500, 46.831, 73.736, 0.4845, 0.7724);
INSERT INTO public.telemetry VALUES (95, 'EVA-001', 94, '2026-01-10 04:34:00-05', 99.05, 91.35, 24.05, 37.19, 33.83, 1.6479, 102.014, 0.9378, 44.906, 71.725, 0.5168, 0.7810);
INSERT INTO public.telemetry VALUES (96, 'EVA-001', 95, '2026-01-10 04:35:00-05', 91.30, 92.39, 23.72, 37.16, 33.78, 1.5873, 94.826, 0.9390, 44.544, 74.683, 0.4936, 0.7892);
INSERT INTO public.telemetry VALUES (97, 'EVA-001', 96, '2026-01-10 04:36:00-05', 89.76, 92.66, 22.07, 37.10, 33.86, 1.4884, 112.897, 0.9567, 47.151, 74.601, 0.4324, 0.7965);
INSERT INTO public.telemetry VALUES (98, 'EVA-001', 97, '2026-01-10 04:37:00-05', 87.98, 92.52, 23.58, 37.09, 33.75, 1.4127, 107.718, 0.9442, 39.264, 71.899, 0.3887, 0.8029);
INSERT INTO public.telemetry VALUES (99, 'EVA-001', 98, '2026-01-10 04:38:00-05', 87.67, 93.56, 20.26, 37.15, 33.67, 1.4084, 109.348, 0.9523, 40.782, 75.120, 0.4676, 0.8107);
INSERT INTO public.telemetry VALUES (100, 'EVA-001', 99, '2026-01-10 04:39:00-05', 86.79, 94.72, 19.79, 37.15, 33.70, 1.3596, 118.052, 0.9548, 41.073, 71.492, 0.4469, 0.8182);
INSERT INTO public.telemetry VALUES (101, 'EVA-001', 100, '2026-01-10 04:40:00-05', 83.51, 95.42, 18.44, 37.19, 33.77, 1.1214, 113.055, 0.9241, 42.181, 72.451, 0.4512, 0.8257);
INSERT INTO public.telemetry VALUES (102, 'EVA-001', 101, '2026-01-10 04:41:00-05', 81.35, 95.64, 17.80, 37.20, 34.00, 1.0942, 123.703, 0.9338, 41.785, 76.434, 0.3208, 0.8310);
INSERT INTO public.telemetry VALUES (103, 'EVA-001', 102, '2026-01-10 04:42:00-05', 81.15, 95.85, 17.26, 37.11, 34.08, 1.0393, 119.043, 0.9563, 43.237, 71.550, 0.4953, 0.8393);
INSERT INTO public.telemetry VALUES (104, 'EVA-001', 103, '2026-01-10 04:43:00-05', 78.16, 97.56, 15.83, 37.09, 33.79, 0.9995, 120.372, 0.9498, 41.641, 71.383, 0.5353, 0.8482);
INSERT INTO public.telemetry VALUES (105, 'EVA-001', 104, '2026-01-10 04:44:00-05', 73.74, 98.33, 15.78, 37.04, 33.76, 0.9438, 126.978, 0.9616, 42.339, 71.335, 0.4515, 0.8557);
INSERT INTO public.telemetry VALUES (106, 'EVA-001', 105, '2026-01-10 04:45:00-05', 71.91, 98.00, 14.95, 37.09, 33.59, 0.8256, 126.737, 0.9450, 40.003, 72.196, 0.4788, 0.8637);
INSERT INTO public.telemetry VALUES (107, 'EVA-001', 106, '2026-01-10 04:46:00-05', 71.53, 98.75, 15.26, 37.09, 33.69, 0.8821, 124.306, 0.9589, 47.756, 72.391, 0.5352, 0.8726);
INSERT INTO public.telemetry VALUES (108, 'EVA-001', 107, '2026-01-10 04:47:00-05', 75.21, 98.12, 13.79, 37.12, 33.33, 0.9381, 128.244, 0.9519, 42.586, 75.449, 0.4243, 0.8797);
INSERT INTO public.telemetry VALUES (109, 'EVA-001', 108, '2026-01-10 04:48:00-05', 70.92, 97.95, 14.31, 37.01, 33.65, 0.8480, 119.228, 0.9660, 37.884, 69.095, 0.5301, 0.8885);
INSERT INTO public.telemetry VALUES (110, 'EVA-001', 109, '2026-01-10 04:49:00-05', 72.59, 98.41, 13.97, 37.00, 33.47, 0.7993, 125.304, 0.9452, 43.959, 72.516, 0.5832, 0.8983);
INSERT INTO public.telemetry VALUES (111, 'EVA-001', 110, '2026-01-10 04:50:00-05', 74.57, 98.55, 14.85, 37.01, 33.52, 0.7340, 123.501, 0.9433, 42.481, 72.076, 0.3918, 0.9048);
INSERT INTO public.telemetry VALUES (112, 'EVA-001', 111, '2026-01-10 04:51:00-05', 70.49, 97.93, 13.85, 37.03, 33.32, 0.8197, 112.949, 0.9284, 43.019, 68.085, 0.4552, 0.9124);
INSERT INTO public.telemetry VALUES (113, 'EVA-001', 112, '2026-01-10 04:52:00-05', 69.44, 97.35, 13.83, 36.99, 33.72, 0.8316, 119.425, 0.9576, 43.806, 71.188, 0.4675, 0.9202);
INSERT INTO public.telemetry VALUES (114, 'EVA-001', 113, '2026-01-10 04:53:00-05', 74.06, 98.89, 14.47, 37.09, 33.69, 0.8433, 114.614, 0.9389, 39.892, 66.694, 0.4526, 0.9277);
INSERT INTO public.telemetry VALUES (115, 'EVA-001', 114, '2026-01-10 04:54:00-05', 73.51, 97.62, 14.28, 36.92, 33.38, 0.8437, 120.441, 0.9529, 44.738, 72.293, 0.4299, 0.9349);
INSERT INTO public.telemetry VALUES (116, 'EVA-001', 115, '2026-01-10 04:55:00-05', 74.16, 97.60, 13.80, 36.98, 33.67, 0.7277, 120.996, 0.9552, 41.645, 68.948, 0.5803, 0.9446);
INSERT INTO public.telemetry VALUES (117, 'EVA-001', 116, '2026-01-10 04:56:00-05', 69.86, 98.43, 13.96, 36.89, 33.51, 0.7850, 116.305, 0.9426, 38.082, 66.158, 0.6353, 0.9551);
INSERT INTO public.telemetry VALUES (118, 'EVA-001', 117, '2026-01-10 04:57:00-05', 68.78, 97.48, 14.42, 36.98, 33.55, 0.8439, 115.883, 0.9395, 40.935, 70.315, 0.4738, 0.9630);
INSERT INTO public.telemetry VALUES (119, 'EVA-001', 118, '2026-01-10 04:58:00-05', 68.28, 98.38, 13.93, 36.87, 33.54, 0.6882, 114.409, 0.9388, 36.100, 66.744, 0.4509, 0.9706);
INSERT INTO public.telemetry VALUES (120, 'EVA-001', 119, '2026-01-10 04:59:00-05', 72.03, 97.86, 13.87, 36.98, 33.28, 0.7568, 118.912, 0.9671, 40.336, 70.874, 0.5815, 0.9802);
INSERT INTO public.telemetry VALUES (121, 'EVA-002', 0, '2026-01-10 05:00:00-05', 74.11, 97.11, 14.62, 37.01, 33.51, 0.7736, 117.874, 0.9542, 42.520, 67.004, 0.5174, 0.0086);
INSERT INTO public.telemetry VALUES (122, 'EVA-002', 1, '2026-01-10 05:01:00-05', 71.13, 97.57, 14.37, 37.00, 33.39, 0.7699, 122.072, 0.9499, 37.141, 68.651, 0.4854, 0.0167);
INSERT INTO public.telemetry VALUES (123, 'EVA-002', 2, '2026-01-10 05:02:00-05', 73.31, 97.57, 14.54, 36.98, 34.10, 0.7695, 117.377, 0.9519, 38.122, 72.319, 0.6441, 0.0274);
INSERT INTO public.telemetry VALUES (124, 'EVA-002', 3, '2026-01-10 05:03:00-05', 71.97, 98.23, 13.93, 37.04, 33.86, 0.8695, 117.458, 0.9655, 44.723, 71.962, 0.4473, 0.0349);
INSERT INTO public.telemetry VALUES (125, 'EVA-002', 4, '2026-01-10 05:04:00-05', 73.11, 97.80, 14.72, 37.03, 33.15, 0.8790, 123.575, 0.9608, 41.227, 71.686, 0.5892, 0.0447);
INSERT INTO public.telemetry VALUES (126, 'EVA-002', 5, '2026-01-10 05:05:00-05', 73.99, 98.39, 16.74, 37.05, 33.66, 0.9272, 119.213, 0.9396, 37.727, 72.686, 0.5501, 0.0539);
INSERT INTO public.telemetry VALUES (127, 'EVA-002', 6, '2026-01-10 05:06:00-05', 74.92, 97.61, 15.28, 37.13, 33.62, 0.8496, 127.213, 0.9537, 44.323, 69.746, 0.4860, 0.0620);
INSERT INTO public.telemetry VALUES (128, 'EVA-002', 7, '2026-01-10 05:07:00-05', 71.23, 98.65, 15.03, 37.08, 33.72, 0.7773, 128.696, 0.9453, 43.141, 74.434, 0.4395, 0.0693);
INSERT INTO public.telemetry VALUES (129, 'EVA-002', 8, '2026-01-10 05:08:00-05', 76.25, 98.43, 14.76, 37.12, 33.44, 0.8915, 125.255, 0.9604, 42.441, 71.747, 0.5296, 0.0781);
INSERT INTO public.telemetry VALUES (130, 'EVA-002', 9, '2026-01-10 05:09:00-05', 73.93, 97.82, 14.68, 37.17, 33.69, 0.8246, 129.033, 0.9315, 37.047, 72.718, 0.5145, 0.0867);
INSERT INTO public.telemetry VALUES (131, 'EVA-002', 10, '2026-01-10 05:10:00-05', 74.66, 98.00, 14.78, 37.04, 33.77, 0.7933, 125.175, 0.9526, 38.431, 71.916, 0.5631, 0.0961);
INSERT INTO public.telemetry VALUES (132, 'EVA-002', 11, '2026-01-10 05:11:00-05', 77.48, 97.72, 15.19, 37.06, 33.47, 0.9592, 129.690, 0.9420, 44.625, 74.458, 0.5145, 0.1047);
INSERT INTO public.telemetry VALUES (133, 'EVA-002', 12, '2026-01-10 05:12:00-05', 79.02, 98.81, 12.91, 37.11, 33.61, 0.8739, 126.799, 0.9435, 40.953, 76.093, 0.5478, 0.1138);
INSERT INTO public.telemetry VALUES (134, 'EVA-002', 13, '2026-01-10 05:13:00-05', 73.31, 98.87, 15.53, 37.20, 33.55, 0.9273, 124.029, 0.9616, 43.840, 68.991, 0.5028, 0.1222);
INSERT INTO public.telemetry VALUES (135, 'EVA-002', 14, '2026-01-10 05:14:00-05', 71.19, 98.44, 15.06, 37.12, 33.48, 0.8362, 123.133, 0.9475, 48.463, 75.096, 0.4622, 0.1299);
INSERT INTO public.telemetry VALUES (136, 'EVA-002', 15, '2026-01-10 05:15:00-05', 77.39, 97.89, 15.62, 37.13, 33.83, 0.9268, 124.194, 0.9580, 44.717, 78.620, 0.4757, 0.1378);
INSERT INTO public.telemetry VALUES (137, 'EVA-002', 16, '2026-01-10 05:16:00-05', 77.45, 98.91, 14.34, 37.21, 33.58, 0.7856, 132.042, 0.9607, 45.016, 73.366, 0.6267, 0.1483);
INSERT INTO public.telemetry VALUES (138, 'EVA-002', 17, '2026-01-10 05:17:00-05', 76.39, 98.27, 15.70, 37.09, 33.68, 0.8463, 116.905, 0.9382, 48.608, 71.757, 0.4560, 0.1559);
INSERT INTO public.telemetry VALUES (139, 'EVA-002', 18, '2026-01-10 05:18:00-05', 72.67, 99.03, 15.20, 37.17, 33.78, 0.8412, 123.110, 0.9584, 44.815, 75.539, 0.2470, 0.1600);
INSERT INTO public.telemetry VALUES (140, 'EVA-002', 19, '2026-01-10 05:19:00-05', 77.22, 98.35, 16.72, 37.12, 33.81, 0.9330, 123.620, 0.9587, 43.064, 76.578, 0.5635, 0.1694);
INSERT INTO public.telemetry VALUES (141, 'EVA-002', 20, '2026-01-10 05:20:00-05', 75.98, 98.24, 15.05, 37.16, 33.39, 0.8720, 132.654, 0.9373, 48.814, 72.725, 0.5259, 0.1781);
INSERT INTO public.telemetry VALUES (142, 'EVA-002', 21, '2026-01-10 05:21:00-05', 72.66, 98.83, 15.50, 37.20, 34.07, 0.9611, 128.917, 0.9377, 48.891, 71.328, 0.4649, 0.1859);
INSERT INTO public.telemetry VALUES (143, 'EVA-002', 22, '2026-01-10 05:22:00-05', 76.37, 98.80, 16.27, 37.14, 33.45, 0.8828, 128.596, 0.9465, 49.066, 73.368, 0.3851, 0.1923);
INSERT INTO public.telemetry VALUES (144, 'EVA-002', 23, '2026-01-10 05:23:00-05', 75.76, 97.99, 16.32, 37.15, 33.50, 0.9480, 139.373, 0.9300, 47.413, 74.731, 0.5141, 0.2009);
INSERT INTO public.telemetry VALUES (145, 'EVA-002', 24, '2026-01-10 05:24:00-05', 75.41, 98.79, 14.61, 37.21, 33.50, 0.9889, 134.913, 0.9381, 44.530, 76.477, 0.4607, 0.2085);
INSERT INTO public.telemetry VALUES (146, 'EVA-002', 25, '2026-01-10 05:25:00-05', 74.29, 98.32, 15.86, 37.10, 33.76, 0.9142, 125.934, 0.9413, 40.333, 70.450, 0.4056, 0.2153);
INSERT INTO public.telemetry VALUES (147, 'EVA-002', 26, '2026-01-10 05:26:00-05', 71.04, 98.13, 15.20, 37.13, 33.58, 0.8319, 121.654, 0.9361, 40.431, 74.739, 0.3876, 0.2218);
INSERT INTO public.telemetry VALUES (148, 'EVA-002', 27, '2026-01-10 05:27:00-05', 74.37, 98.16, 16.63, 37.03, 33.77, 0.8611, 122.369, 0.9532, 44.357, 70.975, 0.5341, 0.2307);
INSERT INTO public.telemetry VALUES (149, 'EVA-002', 28, '2026-01-10 05:28:00-05', 74.95, 99.09, 14.44, 37.18, 33.68, 0.7735, 128.400, 0.9492, 40.968, 74.759, 0.4623, 0.2384);
INSERT INTO public.telemetry VALUES (150, 'EVA-002', 29, '2026-01-10 05:29:00-05', 76.02, 98.36, 15.32, 37.13, 33.79, 0.8147, 129.903, 0.9502, 49.322, 73.610, 0.5601, 0.2477);
INSERT INTO public.telemetry VALUES (151, 'EVA-002', 30, '2026-01-10 05:30:00-05', 72.27, 98.16, 14.79, 37.03, 33.45, 0.8544, 124.398, 0.9520, 46.344, 71.593, 0.5545, 0.2570);
INSERT INTO public.telemetry VALUES (152, 'EVA-002', 31, '2026-01-10 05:31:00-05', 73.30, 98.22, 14.82, 36.98, 33.67, 0.8211, 119.589, 0.9311, 41.320, 68.364, 0.5696, 0.2664);
INSERT INTO public.telemetry VALUES (153, 'EVA-002', 32, '2026-01-10 05:32:00-05', 72.89, 97.43, 14.08, 37.11, 33.52, 0.8317, 121.812, 0.9487, 37.187, 71.738, 0.4554, 0.2740);
INSERT INTO public.telemetry VALUES (154, 'EVA-002', 33, '2026-01-10 05:33:00-05', 79.05, 98.12, 14.14, 37.11, 33.58, 0.8508, 118.683, 0.9656, 40.025, 72.277, 0.5906, 0.2839);
INSERT INTO public.telemetry VALUES (155, 'EVA-002', 34, '2026-01-10 05:34:00-05', 72.30, 98.18, 14.77, 37.08, 33.37, 0.8394, 117.700, 0.9425, 39.572, 73.646, 0.6277, 0.2943);
INSERT INTO public.telemetry VALUES (156, 'EVA-002', 35, '2026-01-10 05:35:00-05', 77.88, 98.11, 13.68, 36.99, 33.89, 0.7454, 120.199, 0.9443, 46.365, 68.865, 0.5881, 0.3041);
INSERT INTO public.telemetry VALUES (157, 'EVA-002', 36, '2026-01-10 05:36:00-05', 75.05, 98.00, 14.50, 36.94, 33.52, 0.8034, 108.231, 0.9542, 41.771, 67.178, 0.3870, 0.3106);
INSERT INTO public.telemetry VALUES (158, 'EVA-002', 37, '2026-01-10 05:37:00-05', 70.68, 97.77, 13.86, 36.96, 33.32, 0.8211, 118.090, 0.9489, 39.602, 71.147, 0.4877, 0.3187);
INSERT INTO public.telemetry VALUES (159, 'EVA-002', 38, '2026-01-10 05:38:00-05', 73.65, 98.04, 14.59, 37.06, 33.20, 0.8436, 128.714, 0.9403, 39.779, 69.185, 0.5353, 0.3276);
INSERT INTO public.telemetry VALUES (160, 'EVA-002', 39, '2026-01-10 05:39:00-05', 72.72, 97.60, 14.79, 36.94, 33.44, 0.8404, 128.902, 0.9449, 41.806, 70.007, 0.3734, 0.3339);
INSERT INTO public.telemetry VALUES (161, 'EVA-002', 40, '2026-01-10 05:40:00-05', 69.52, 97.28, 13.42, 36.95, 33.45, 0.8448, 120.588, 0.9765, 38.317, 70.816, 0.5332, 0.3428);
INSERT INTO public.telemetry VALUES (162, 'EVA-002', 41, '2026-01-10 05:41:00-05', 74.20, 97.65, 14.27, 37.04, 33.27, 0.7691, 120.349, 0.9457, 36.016, 72.579, 0.4816, 0.3508);
INSERT INTO public.telemetry VALUES (163, 'EVA-002', 42, '2026-01-10 05:42:00-05', 74.42, 97.54, 13.43, 36.99, 33.35, 0.7200, 113.594, 0.9527, 36.248, 68.773, 0.3194, 0.3561);
INSERT INTO public.telemetry VALUES (164, 'EVA-002', 43, '2026-01-10 05:43:00-05', 69.60, 97.65, 13.13, 36.89, 33.20, 0.7608, 124.015, 0.9360, 37.034, 70.244, 0.5268, 0.3649);
INSERT INTO public.telemetry VALUES (165, 'EVA-002', 44, '2026-01-10 05:44:00-05', 70.31, 97.47, 13.41, 36.92, 32.91, 0.7141, 106.242, 0.9629, 39.962, 66.418, 0.5644, 0.3743);
INSERT INTO public.telemetry VALUES (166, 'EVA-002', 45, '2026-01-10 05:45:00-05', 75.18, 97.35, 14.22, 36.93, 33.28, 0.6875, 112.648, 0.9461, 30.195, 68.775, 0.4743, 0.3822);
INSERT INTO public.telemetry VALUES (167, 'EVA-002', 46, '2026-01-10 05:46:00-05', 71.00, 97.41, 15.33, 36.82, 33.12, 0.7715, 126.689, 0.9401, 42.298, 65.614, 0.6035, 0.3922);
INSERT INTO public.telemetry VALUES (168, 'EVA-002', 47, '2026-01-10 05:47:00-05', 70.05, 98.70, 14.41, 36.86, 33.88, 0.6738, 112.834, 0.9681, 34.297, 65.918, 0.5105, 0.4008);
INSERT INTO public.telemetry VALUES (169, 'EVA-002', 48, '2026-01-10 05:48:00-05', 70.63, 97.74, 12.57, 36.90, 33.40, 0.7995, 115.586, 0.9375, 36.301, 65.732, 0.6055, 0.4108);
INSERT INTO public.telemetry VALUES (170, 'EVA-002', 49, '2026-01-10 05:49:00-05', 66.22, 97.79, 12.28, 36.94, 33.41, 0.7301, 116.056, 0.9466, 37.984, 66.666, 0.5585, 0.4202);
INSERT INTO public.telemetry VALUES (171, 'EVA-002', 50, '2026-01-10 05:50:00-05', 69.55, 96.25, 12.61, 36.95, 33.53, 0.7198, 112.532, 0.9466, 37.618, 67.739, 0.4217, 0.4272);
INSERT INTO public.telemetry VALUES (172, 'EVA-002', 51, '2026-01-10 05:51:00-05', 70.64, 98.08, 12.26, 36.86, 33.32, 0.7466, 110.737, 0.9447, 34.133, 67.191, 0.5343, 0.4361);
INSERT INTO public.telemetry VALUES (173, 'EVA-002', 52, '2026-01-10 05:52:00-05', 69.17, 96.76, 12.12, 36.89, 32.98, 0.7184, 110.764, 0.9440, 35.435, 69.637, 0.5231, 0.4448);
INSERT INTO public.telemetry VALUES (174, 'EVA-002', 53, '2026-01-10 05:53:00-05', 68.54, 96.69, 13.21, 36.91, 33.33, 0.7626, 114.730, 0.9370, 35.082, 67.223, 0.5577, 0.4541);
INSERT INTO public.telemetry VALUES (175, 'EVA-002', 54, '2026-01-10 05:54:00-05', 68.08, 97.38, 13.08, 36.92, 33.41, 0.7346, 114.161, 0.9397, 31.810, 65.906, 0.5833, 0.4638);
INSERT INTO public.telemetry VALUES (176, 'EVA-002', 55, '2026-01-10 05:55:00-05', 69.82, 97.69, 11.76, 36.78, 33.43, 0.6991, 105.498, 0.9588, 35.816, 71.936, 0.6000, 0.4738);
INSERT INTO public.telemetry VALUES (177, 'EVA-002', 56, '2026-01-10 05:56:00-05', 69.70, 97.33, 12.96, 36.85, 32.91, 0.7465, 113.383, 0.9225, 33.099, 64.347, 0.5785, 0.4835);
INSERT INTO public.telemetry VALUES (178, 'EVA-002', 57, '2026-01-10 05:57:00-05', 68.91, 98.14, 11.69, 36.80, 33.41, 0.6673, 106.713, 0.9447, 32.724, 67.082, 0.5895, 0.4933);
INSERT INTO public.telemetry VALUES (179, 'EVA-002', 58, '2026-01-10 05:58:00-05', 65.85, 97.26, 12.82, 36.86, 33.37, 0.7067, 109.159, 0.9389, 29.562, 65.287, 0.5012, 0.5016);
INSERT INTO public.telemetry VALUES (180, 'EVA-002', 59, '2026-01-10 05:59:00-05', 70.91, 97.22, 14.45, 36.85, 33.11, 0.7211, 107.314, 0.9521, 28.912, 67.435, 0.5053, 0.5101);
INSERT INTO public.telemetry VALUES (181, 'EVA-002', 60, '2026-01-10 06:00:00-05', 69.54, 97.50, 11.96, 36.81, 33.53, 0.7288, 109.342, 0.9542, 36.429, 70.073, 0.5888, 0.5199);
INSERT INTO public.telemetry VALUES (182, 'EVA-002', 61, '2026-01-10 06:01:00-05', 70.03, 97.22, 14.13, 36.86, 33.05, 0.6458, 108.232, 0.9464, 37.636, 68.098, 0.5921, 0.5297);
INSERT INTO public.telemetry VALUES (183, 'EVA-002', 62, '2026-01-10 06:02:00-05', 69.61, 97.88, 14.50, 36.91, 33.55, 0.6346, 109.102, 0.9425, 27.476, 66.553, 0.6114, 0.5399);
INSERT INTO public.telemetry VALUES (184, 'EVA-002', 63, '2026-01-10 06:03:00-05', 68.35, 97.58, 12.37, 36.85, 33.30, 0.6543, 118.999, 0.9308, 36.672, 65.581, 0.6191, 0.5503);
INSERT INTO public.telemetry VALUES (185, 'EVA-002', 64, '2026-01-10 06:04:00-05', 71.08, 96.47, 11.33, 36.83, 33.16, 0.7092, 113.645, 0.9567, 31.835, 63.146, 0.5202, 0.5589);
INSERT INTO public.telemetry VALUES (186, 'EVA-002', 65, '2026-01-10 06:05:00-05', 68.99, 97.49, 12.64, 36.88, 33.57, 0.6426, 107.776, 0.9564, 40.892, 66.540, 0.3990, 0.5656);
INSERT INTO public.telemetry VALUES (187, 'EVA-002', 66, '2026-01-10 06:06:00-05', 67.08, 97.71, 12.55, 37.09, 34.06, 0.7408, 116.783, 0.9488, 39.898, 67.172, 0.5051, 0.5740);
INSERT INTO public.telemetry VALUES (188, 'EVA-002', 67, '2026-01-10 06:07:00-05', 75.19, 97.93, 15.25, 36.99, 33.80, 0.6904, 119.056, 0.9451, 38.587, 65.086, 0.4925, 0.5822);
INSERT INTO public.telemetry VALUES (189, 'EVA-002', 68, '2026-01-10 06:08:00-05', 78.46, 98.47, 12.79, 37.19, 34.39, 0.7175, 109.863, 0.9566, 37.412, 68.792, 0.4874, 0.5903);
INSERT INTO public.telemetry VALUES (190, 'EVA-002', 69, '2026-01-10 06:09:00-05', 79.94, 97.24, 14.11, 37.30, 34.69, 0.6802, 122.420, 0.9354, 37.478, 67.353, 0.4434, 0.5977);
INSERT INTO public.telemetry VALUES (191, 'EVA-002', 70, '2026-01-10 06:10:00-05', 78.96, 96.57, 14.30, 37.32, 35.04, 0.8340, 120.399, 0.9640, 31.152, 68.588, 0.3894, 0.6042);
INSERT INTO public.telemetry VALUES (192, 'EVA-002', 71, '2026-01-10 06:11:00-05', 77.38, 97.91, 15.24, 37.54, 34.80, 0.7224, 109.730, 0.9336, 41.226, 68.931, 0.6245, 0.6146);
INSERT INTO public.telemetry VALUES (193, 'EVA-002', 72, '2026-01-10 06:12:00-05', 81.93, 97.87, 14.85, 37.61, 35.38, 0.7121, 112.013, 0.9512, 42.400, 68.988, 0.5980, 0.6246);
INSERT INTO public.telemetry VALUES (194, 'EVA-002', 73, '2026-01-10 06:13:00-05', 81.19, 97.67, 17.80, 37.75, 35.88, 0.7385, 110.367, 0.9540, 38.241, 70.140, 0.5258, 0.6333);
INSERT INTO public.telemetry VALUES (195, 'EVA-002', 74, '2026-01-10 06:14:00-05', 83.32, 98.50, 16.48, 37.73, 36.01, 0.8175, 113.711, 0.9572, 41.561, 69.447, 0.4375, 0.6406);
INSERT INTO public.telemetry VALUES (196, 'EVA-002', 75, '2026-01-10 06:15:00-05', 80.35, 97.42, 15.49, 37.86, 36.40, 0.7506, 124.098, 0.9513, 39.977, 70.984, 0.5829, 0.6503);
INSERT INTO public.telemetry VALUES (197, 'EVA-002', 76, '2026-01-10 06:16:00-05', 82.14, 98.38, 15.73, 37.92, 37.02, 0.8396, 123.725, 0.9518, 44.490, 67.119, 0.4756, 0.6583);
INSERT INTO public.telemetry VALUES (198, 'EVA-002', 77, '2026-01-10 06:17:00-05', 86.89, 99.10, 18.08, 38.11, 36.99, 0.9258, 123.424, 0.9399, 47.702, 67.679, 0.4305, 0.6654);
INSERT INTO public.telemetry VALUES (199, 'EVA-002', 78, '2026-01-10 06:18:00-05', 87.78, 97.64, 18.09, 38.17, 37.49, 0.9162, 113.551, 0.9637, 38.602, 73.785, 0.6524, 0.6763);
INSERT INTO public.telemetry VALUES (200, 'EVA-002', 79, '2026-01-10 06:19:00-05', 94.29, 98.08, 17.27, 38.27, 37.78, 0.7414, 126.043, 0.9408, 45.804, 73.113, 0.4775, 0.6843);
INSERT INTO public.telemetry VALUES (201, 'EVA-002', 80, '2026-01-10 06:20:00-05', 91.19, 98.10, 18.13, 38.51, 37.93, 0.8402, 127.951, 0.9462, 39.985, 68.838, 0.5954, 0.6942);
INSERT INTO public.telemetry VALUES (202, 'EVA-002', 81, '2026-01-10 06:21:00-05', 92.77, 98.51, 17.48, 38.39, 38.19, 0.8281, 116.717, 0.9494, 39.638, 71.960, 0.5051, 0.7026);
INSERT INTO public.telemetry VALUES (203, 'EVA-002', 82, '2026-01-10 06:22:00-05', 90.89, 98.75, 18.58, 38.40, 38.24, 0.9027, 119.362, 0.9465, 45.380, 72.398, 0.5901, 0.7125);
INSERT INTO public.telemetry VALUES (204, 'EVA-002', 83, '2026-01-10 06:23:00-05', 93.27, 98.13, 19.33, 38.38, 38.37, 0.9519, 130.194, 0.9729, 38.305, 71.271, 0.4787, 0.7204);
INSERT INTO public.telemetry VALUES (205, 'EVA-002', 84, '2026-01-10 06:24:00-05', 91.17, 98.58, 18.53, 38.45, 38.39, 0.8864, 120.195, 0.9555, 45.308, 73.336, 0.5024, 0.7288);
INSERT INTO public.telemetry VALUES (206, 'EVA-002', 85, '2026-01-10 06:25:00-05', 94.95, 98.16, 18.60, 38.44, 38.32, 0.9144, 124.320, 0.9369, 39.875, 72.005, 0.5634, 0.7382);
INSERT INTO public.telemetry VALUES (207, 'EVA-002', 86, '2026-01-10 06:26:00-05', 93.90, 97.56, 19.30, 38.41, 38.02, 0.9868, 127.503, 0.9583, 51.567, 71.930, 0.4683, 0.7460);
INSERT INTO public.telemetry VALUES (208, 'EVA-002', 87, '2026-01-10 06:27:00-05', 95.45, 97.84, 19.04, 38.43, 38.44, 0.9026, 122.019, 0.9597, 46.651, 71.190, 0.4450, 0.7534);
INSERT INTO public.telemetry VALUES (209, 'EVA-002', 88, '2026-01-10 06:28:00-05', 91.55, 97.95, 19.79, 38.41, 38.20, 0.8349, 124.967, 0.9648, 46.582, 70.235, 0.4208, 0.7604);
INSERT INTO public.telemetry VALUES (210, 'EVA-002', 89, '2026-01-10 06:29:00-05', 93.99, 98.29, 18.70, 38.39, 38.01, 0.8954, 125.346, 0.9614, 44.329, 71.693, 0.5555, 0.7697);
INSERT INTO public.telemetry VALUES (211, 'EVA-002', 90, '2026-01-10 06:30:00-05', 95.51, 98.19, 17.93, 38.42, 38.01, 0.9759, 120.565, 0.9467, 49.111, 75.494, 0.4589, 0.7773);
INSERT INTO public.telemetry VALUES (212, 'EVA-002', 91, '2026-01-10 06:31:00-05', 91.32, 98.49, 18.99, 38.52, 38.26, 0.8289, 132.638, 0.9604, 44.138, 75.399, 0.5041, 0.7857);
INSERT INTO public.telemetry VALUES (213, 'EVA-002', 92, '2026-01-10 06:32:00-05', 90.53, 98.55, 18.38, 38.42, 38.11, 0.9149, 128.793, 0.9368, 42.153, 73.925, 0.5371, 0.7947);
INSERT INTO public.telemetry VALUES (214, 'EVA-002', 93, '2026-01-10 06:33:00-05', 93.13, 97.49, 20.09, 38.54, 38.62, 0.9267, 131.317, 0.9435, 45.539, 71.717, 0.5097, 0.8032);
INSERT INTO public.telemetry VALUES (215, 'EVA-002', 94, '2026-01-10 06:34:00-05', 90.14, 98.89, 18.95, 38.49, 38.34, 0.8770, 132.215, 0.9383, 44.204, 72.924, 0.5595, 0.8125);
INSERT INTO public.telemetry VALUES (216, 'EVA-002', 95, '2026-01-10 06:35:00-05', 92.84, 98.73, 19.57, 38.33, 38.11, 0.9056, 133.047, 0.9557, 48.923, 73.549, 0.5081, 0.8210);
INSERT INTO public.telemetry VALUES (217, 'EVA-002', 96, '2026-01-10 06:36:00-05', 91.97, 98.38, 18.61, 38.42, 38.26, 0.8664, 128.048, 0.9318, 46.231, 74.312, 0.5357, 0.8299);
INSERT INTO public.telemetry VALUES (218, 'EVA-002', 97, '2026-01-10 06:37:00-05', 91.99, 98.33, 19.86, 38.44, 38.69, 0.8271, 126.554, 0.9387, 42.509, 72.315, 0.4615, 0.8376);
INSERT INTO public.telemetry VALUES (219, 'EVA-002', 98, '2026-01-10 06:38:00-05', 94.42, 98.00, 19.57, 38.37, 38.20, 0.9611, 129.922, 0.9527, 46.648, 74.958, 0.5502, 0.8468);
INSERT INTO public.telemetry VALUES (220, 'EVA-002', 99, '2026-01-10 06:39:00-05', 95.58, 98.03, 19.06, 38.47, 38.43, 0.9202, 133.914, 0.9450, 40.564, 76.235, 0.4999, 0.8551);
INSERT INTO public.telemetry VALUES (221, 'EVA-002', 100, '2026-01-10 06:40:00-05', 91.56, 98.55, 18.76, 38.48, 38.44, 0.9043, 129.803, 0.9503, 47.516, 68.823, 0.4065, 0.8619);
INSERT INTO public.telemetry VALUES (222, 'EVA-002', 101, '2026-01-10 06:41:00-05', 91.26, 98.30, 18.08, 38.37, 37.76, 0.8955, 127.388, 0.9506, 41.742, 72.997, 0.5982, 0.8719);
INSERT INTO public.telemetry VALUES (223, 'EVA-002', 102, '2026-01-10 06:42:00-05', 91.08, 98.96, 18.37, 38.16, 37.55, 0.8723, 132.895, 0.9614, 45.267, 71.481, 0.5103, 0.8804);
INSERT INTO public.telemetry VALUES (224, 'EVA-002', 103, '2026-01-10 06:43:00-05', 88.11, 98.33, 17.23, 38.18, 37.32, 0.9148, 118.657, 0.9387, 54.667, 71.222, 0.5230, 0.8891);
INSERT INTO public.telemetry VALUES (225, 'EVA-002', 104, '2026-01-10 06:44:00-05', 88.14, 97.92, 18.97, 38.05, 37.04, 0.9597, 121.545, 0.9451, 42.401, 70.005, 0.5221, 0.8978);
INSERT INTO public.telemetry VALUES (226, 'EVA-002', 105, '2026-01-10 06:45:00-05', 86.82, 98.47, 17.88, 38.00, 36.76, 0.8504, 131.100, 0.9430, 47.313, 72.113, 0.5612, 0.9071);
INSERT INTO public.telemetry VALUES (227, 'EVA-002', 106, '2026-01-10 06:46:00-05', 88.13, 97.20, 16.93, 37.84, 36.71, 0.8354, 138.106, 0.9347, 43.836, 71.458, 0.5404, 0.9161);
INSERT INTO public.telemetry VALUES (228, 'EVA-002', 107, '2026-01-10 06:47:00-05', 81.93, 98.07, 15.44, 37.77, 35.75, 0.7832, 124.327, 0.9488, 45.514, 69.240, 0.5337, 0.9250);
INSERT INTO public.telemetry VALUES (229, 'EVA-002', 108, '2026-01-10 06:48:00-05', 82.28, 98.10, 15.80, 37.66, 35.90, 0.8225, 127.533, 0.9473, 47.235, 71.702, 0.4860, 0.9331);
INSERT INTO public.telemetry VALUES (230, 'EVA-002', 109, '2026-01-10 06:49:00-05', 76.98, 97.49, 16.27, 37.56, 35.46, 0.7993, 121.927, 0.9438, 42.560, 70.903, 0.6492, 0.9439);
INSERT INTO public.telemetry VALUES (231, 'EVA-002', 110, '2026-01-10 06:50:00-05', 77.39, 98.71, 14.90, 37.45, 34.91, 0.8885, 124.227, 0.9514, 41.980, 68.852, 0.6122, 0.9542);
INSERT INTO public.telemetry VALUES (232, 'EVA-002', 111, '2026-01-10 06:51:00-05', 80.10, 98.09, 15.28, 37.41, 34.72, 0.8074, 118.927, 0.9465, 39.441, 72.155, 0.4737, 0.9620);
INSERT INTO public.telemetry VALUES (233, 'EVA-002', 112, '2026-01-10 06:52:00-05', 75.02, 97.74, 13.86, 37.35, 34.53, 0.8525, 118.081, 0.9646, 40.892, 73.271, 0.4989, 0.9704);
INSERT INTO public.telemetry VALUES (234, 'EVA-002', 113, '2026-01-10 06:53:00-05', 74.34, 97.74, 14.60, 37.19, 34.40, 0.8778, 120.515, 0.9622, 31.888, 69.092, 0.5200, 0.9790);
INSERT INTO public.telemetry VALUES (235, 'EVA-002', 114, '2026-01-10 06:54:00-05', 74.75, 98.17, 14.14, 37.05, 33.62, 0.8876, 125.010, 0.9631, 39.656, 68.631, 0.5444, 0.9881);
INSERT INTO public.telemetry VALUES (236, 'EVA-002', 115, '2026-01-10 06:55:00-05', 71.48, 97.84, 13.79, 36.94, 33.28, 0.7721, 111.810, 0.9560, 41.726, 67.829, 0.3538, 0.9940);
INSERT INTO public.telemetry VALUES (237, 'EVA-002', 116, '2026-01-10 06:56:00-05', 72.07, 97.98, 13.73, 36.90, 33.04, 0.8616, 117.002, 0.9550, 38.590, 69.869, 0.3977, 1.0006);
INSERT INTO public.telemetry VALUES (238, 'EVA-002', 117, '2026-01-10 06:57:00-05', 70.15, 97.13, 12.86, 36.92, 33.04, 0.7450, 113.889, 0.9381, 38.004, 68.699, 0.4330, 1.0078);
INSERT INTO public.telemetry VALUES (239, 'EVA-002', 118, '2026-01-10 06:58:00-05', 74.83, 98.12, 14.31, 36.92, 33.56, 0.7986, 111.729, 0.9432, 46.759, 67.588, 0.5389, 1.0168);
INSERT INTO public.telemetry VALUES (240, 'EVA-002', 119, '2026-01-10 06:59:00-05', 70.15, 98.13, 12.74, 36.88, 33.59, 0.7627, 103.834, 0.9502, 37.093, 69.532, 0.5257, 1.0256);


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.users VALUES (1, 'Ana Torres', 'ana.torres@example.org', 'astronaut', 'pbkdf2_sha256$260000$afce96d10236aa0ddee4d91fadbad8d7$cfd8f0534c6bc9b7a6d636fc2ab9b028e8e20977a4df67ad869f51a295a140a1', 'AST001', true, NULL, '2026-11-14 20:21:39.995334-05');
INSERT INTO public.users VALUES (3, 'Control de Misión', 'control@example.org', 'mission_control', 'pbkdf2_sha256$260000$c5bb3b3835dbc6f8286391f52bce13b1$ae78cae1b5bb05d3fc5c18d11836d79874836da5c035736c5a6e65d646a251c8', NULL, true, NULL, '2026-11-14 20:21:39.995334-05');
INSERT INTO public.users VALUES (4, 'Investigación', 'investigador@example.org', 'researcher', 'pbkdf2_sha256$260000$f9ed82e45fb8f50f1a9e6b355fb50288$3ba88578997384bab4498e93cc8111ea4ad46ff1dd144637f2f38d3efb43a89a', NULL, true, '2026-11-14 21:01:54.788868-05', '2026-11-14 20:21:39.995334-05');
INSERT INTO public.users VALUES (2, 'Dr. Marco Ruiz', 'medico@example.org', 'flight_surgeon', 'pbkdf2_sha256$260000$264f533bdb046344de5cd993ed5bd472$83609e82795fc53c8a28b7a0f2613148b7705c3b8b76e827401a32049f03d687', NULL, true, '2026-11-15 00:12:56.2336-05', '2026-11-14 20:21:39.995334-05');


--
-- Name: alert_actions_action_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.alert_actions_action_id_seq', 2, true);


--
-- Name: alerts_alert_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.alerts_alert_id_seq', 6, true);


--
-- Name: baselines_baseline_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.baselines_baseline_id_seq', 24, true);


--
-- Name: medical_events_event_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.medical_events_event_id_seq', 2, true);


--
-- Name: model_metrics_metric_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.model_metrics_metric_id_seq', 1, false);


--
-- Name: models_model_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.models_model_id_seq', 1, true);


--
-- Name: predictions_prediction_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.predictions_prediction_id_seq', 38, true);


--
-- Name: telemetry_telemetry_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.telemetry_telemetry_id_seq', 240, true);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_user_id_seq', 4, true);


--
-- Name: alert_actions alert_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert_actions
    ADD CONSTRAINT alert_actions_pkey PRIMARY KEY (action_id);


--
-- Name: alerts alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alerts
    ADD CONSTRAINT alerts_pkey PRIMARY KEY (alert_id);


--
-- Name: astronauts astronauts_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.astronauts
    ADD CONSTRAINT astronauts_email_key UNIQUE (email);


--
-- Name: astronauts astronauts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.astronauts
    ADD CONSTRAINT astronauts_pkey PRIMARY KEY (astronaut_id);


--
-- Name: baselines baselines_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baselines
    ADD CONSTRAINT baselines_pkey PRIMARY KEY (baseline_id);


--
-- Name: baselines baselines_session_id_variable_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baselines
    ADD CONSTRAINT baselines_session_id_variable_key UNIQUE (session_id, variable);


--
-- Name: event_types event_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_types
    ADD CONSTRAINT event_types_pkey PRIMARY KEY (code);


--
-- Name: medical_events medical_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medical_events
    ADD CONSTRAINT medical_events_pkey PRIMARY KEY (event_id);


--
-- Name: model_metrics model_metrics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.model_metrics
    ADD CONSTRAINT model_metrics_pkey PRIMARY KEY (metric_id);


--
-- Name: models models_name_version_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.models
    ADD CONSTRAINT models_name_version_key UNIQUE (name, version);


--
-- Name: models models_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.models
    ADD CONSTRAINT models_pkey PRIMARY KEY (model_id);


--
-- Name: predictions predictions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.predictions
    ADD CONSTRAINT predictions_pkey PRIMARY KEY (prediction_id);


--
-- Name: predictions predictions_session_id_minute_model_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.predictions
    ADD CONSTRAINT predictions_session_id_minute_model_id_key UNIQUE (session_id, minute, model_id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (session_id);


--
-- Name: telemetry telemetry_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telemetry
    ADD CONSTRAINT telemetry_pkey PRIMARY KEY (telemetry_id);


--
-- Name: telemetry telemetry_session_id_minute_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telemetry
    ADD CONSTRAINT telemetry_session_id_minute_key UNIQUE (session_id, minute);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: idx_alert_actions_alert; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_alert_actions_alert ON public.alert_actions USING btree (alert_id);


--
-- Name: idx_alerts_session; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_alerts_session ON public.alerts USING btree (session_id);


--
-- Name: idx_alerts_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_alerts_status ON public.alerts USING btree (status);


--
-- Name: idx_events_session; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_events_session ON public.medical_events USING btree (session_id);


--
-- Name: idx_predictions_session_minute; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_predictions_session_minute ON public.predictions USING btree (session_id, minute);


--
-- Name: idx_sessions_astronaut; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sessions_astronaut ON public.sessions USING btree (astronaut_id);


--
-- Name: idx_telemetry_session_minute; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_telemetry_session_minute ON public.telemetry USING btree (session_id, minute);


--
-- Name: alert_actions alert_actions_alert_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert_actions
    ADD CONSTRAINT alert_actions_alert_id_fkey FOREIGN KEY (alert_id) REFERENCES public.alerts(alert_id) ON DELETE CASCADE;


--
-- Name: alert_actions alert_actions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert_actions
    ADD CONSTRAINT alert_actions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id);


--
-- Name: alerts alerts_prediction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alerts
    ADD CONSTRAINT alerts_prediction_id_fkey FOREIGN KEY (prediction_id) REFERENCES public.predictions(prediction_id) ON DELETE CASCADE;


--
-- Name: alerts alerts_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alerts
    ADD CONSTRAINT alerts_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.sessions(session_id) ON DELETE CASCADE;


--
-- Name: baselines baselines_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baselines
    ADD CONSTRAINT baselines_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.sessions(session_id) ON DELETE CASCADE;


--
-- Name: medical_events medical_events_event_type_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medical_events
    ADD CONSTRAINT medical_events_event_type_code_fkey FOREIGN KEY (event_type_code) REFERENCES public.event_types(code);


--
-- Name: medical_events medical_events_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medical_events
    ADD CONSTRAINT medical_events_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.sessions(session_id) ON DELETE CASCADE;


--
-- Name: model_metrics model_metrics_model_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.model_metrics
    ADD CONSTRAINT model_metrics_model_id_fkey FOREIGN KEY (model_id) REFERENCES public.models(model_id) ON DELETE CASCADE;


--
-- Name: predictions predictions_hypothesis_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.predictions
    ADD CONSTRAINT predictions_hypothesis_code_fkey FOREIGN KEY (hypothesis_code) REFERENCES public.event_types(code);


--
-- Name: predictions predictions_model_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.predictions
    ADD CONSTRAINT predictions_model_id_fkey FOREIGN KEY (model_id) REFERENCES public.models(model_id);


--
-- Name: predictions predictions_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.predictions
    ADD CONSTRAINT predictions_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.sessions(session_id) ON DELETE CASCADE;


--
-- Name: sessions sessions_astronaut_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_astronaut_id_fkey FOREIGN KEY (astronaut_id) REFERENCES public.astronauts(astronaut_id) ON DELETE CASCADE;


--
-- Name: telemetry telemetry_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telemetry
    ADD CONSTRAINT telemetry_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.sessions(session_id) ON DELETE CASCADE;


--
-- Name: users users_astronaut_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_astronaut_id_fkey FOREIGN KEY (astronaut_id) REFERENCES public.astronauts(astronaut_id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--