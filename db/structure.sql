--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: bounced_emails; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE bounced_emails (
    id integer NOT NULL,
    raw_content text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sent_email_id integer
);


--
-- Name: bounced_emails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bounced_emails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bounced_emails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bounced_emails_id_seq OWNED BY bounced_emails.id;


--
-- Name: donations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE donations (
    id integer NOT NULL,
    petition_id integer,
    member_id integer,
    referral_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    amount double precision
);


--
-- Name: donations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE donations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: donations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE donations_id_seq OWNED BY donations.id;


--
-- Name: email_errors; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE email_errors (
    id integer NOT NULL,
    member_id integer NOT NULL,
    email character varying(255),
    error text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: email_errors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE email_errors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_errors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE email_errors_id_seq OWNED BY email_errors.id;


--
-- Name: email_experiments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE email_experiments (
    id integer NOT NULL,
    sent_email_id integer,
    goal character varying(255),
    key character varying(255),
    choice character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: email_experiments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE email_experiments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_experiments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE email_experiments_id_seq OWNED BY email_experiments.id;


--
-- Name: facebook_actions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE facebook_actions (
    id integer NOT NULL,
    member_id integer,
    petition_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    type character varying(255),
    action_id character varying(255)
);


--
-- Name: facebook_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE facebook_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: facebook_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE facebook_actions_id_seq OWNED BY facebook_actions.id;


--
-- Name: facebook_friends; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE facebook_friends (
    id integer NOT NULL,
    member_id integer NOT NULL,
    facebook_id character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: facebook_friends_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE facebook_friends_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: facebook_friends_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE facebook_friends_id_seq OWNED BY facebook_friends.id;


--
-- Name: facebook_share_widget_shares; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE facebook_share_widget_shares (
    id integer NOT NULL,
    user_facebook_id character varying(255),
    friend_facebook_id character varying(255),
    url character varying(255),
    message text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: facebook_share_widget_shares_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE facebook_share_widget_shares_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: facebook_share_widget_shares_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE facebook_share_widget_shares_id_seq OWNED BY facebook_share_widget_shares.id;


--
-- Name: last_updated_unsubscribes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE last_updated_unsubscribes (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_locked boolean NOT NULL
);


--
-- Name: last_updated_unsubscribes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE last_updated_unsubscribes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: last_updated_unsubscribes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE last_updated_unsubscribes_id_seq OWNED BY last_updated_unsubscribes.id;


--
-- Name: mailer_process_trackers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE mailer_process_trackers (
    id integer NOT NULL,
    is_locked boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: mailer_process_trackers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE mailer_process_trackers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mailer_process_trackers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE mailer_process_trackers_id_seq OWNED BY mailer_process_trackers.id;


--
-- Name: members; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE members (
    id integer NOT NULL,
    email character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    first_name character varying(255),
    last_name character varying(255),
    referral_code character varying(255),
    country_code character varying(255),
    state_code character varying(255),
    facebook_uid bigint
);


--
-- Name: members_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE members_id_seq OWNED BY members.id;


--
-- Name: memberships; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE memberships (
    id integer NOT NULL,
    member_id integer,
    last_signed_at timestamp without time zone,
    last_emailed_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: memberships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE memberships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: memberships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE memberships_id_seq OWNED BY memberships.id;


--
-- Name: petition_descriptions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE petition_descriptions (
    id integer NOT NULL,
    facebook_description text NOT NULL,
    petition_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: petition_descriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE petition_descriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: petition_descriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE petition_descriptions_id_seq OWNED BY petition_descriptions.id;


--
-- Name: petition_images; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE petition_images (
    id integer NOT NULL,
    url text NOT NULL,
    petition_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    stored boolean
);


--
-- Name: petition_images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE petition_images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: petition_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE petition_images_id_seq OWNED BY petition_images.id;


--
-- Name: petition_reports; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE petition_reports (
    id integer NOT NULL,
    petition_id integer,
    petition_title text,
    petition_created_at timestamp without time zone,
    sent_emails_count_day integer,
    signatures_count_day integer,
    opened_emails_count_day integer,
    clicked_emails_count_day integer,
    signed_from_emails_count_day integer,
    new_members_count_day integer,
    unsubscribes_count_day integer,
    like_count_day integer,
    hit_count_day integer,
    opened_emails_rate_day double precision,
    clicked_emails_rate_day double precision,
    signed_from_emails_rate_day double precision,
    new_members_rate_day double precision,
    unsubscribes_rate_day double precision,
    like_rate_day double precision,
    hit_rate_day double precision,
    sent_emails_count_week integer,
    signatures_count_week integer,
    opened_emails_count_week integer,
    clicked_emails_count_week integer,
    signed_from_emails_count_week integer,
    new_members_count_week integer,
    unsubscribes_count_week integer,
    like_count_week integer,
    hit_count_week integer,
    opened_emails_rate_week double precision,
    clicked_emails_rate_week double precision,
    signed_from_emails_rate_week double precision,
    new_members_rate_week double precision,
    unsubscribes_rate_week double precision,
    like_rate_week double precision,
    hit_rate_week double precision,
    sent_emails_count_month integer,
    signatures_count_month integer,
    opened_emails_count_month integer,
    clicked_emails_count_month integer,
    signed_from_emails_count_month integer,
    new_members_count_month integer,
    unsubscribes_count_month integer,
    like_count_month integer,
    hit_count_month integer,
    opened_emails_rate_month double precision,
    clicked_emails_rate_month double precision,
    signed_from_emails_rate_month double precision,
    new_members_rate_month double precision,
    unsubscribes_rate_month double precision,
    like_rate_month double precision,
    hit_rate_month double precision,
    sent_emails_count_year integer,
    signatures_count_year integer,
    opened_emails_count_year integer,
    clicked_emails_count_year integer,
    signed_from_emails_count_year integer,
    new_members_count_year integer,
    unsubscribes_count_year integer,
    like_count_year integer,
    hit_count_year integer,
    opened_emails_rate_year double precision,
    clicked_emails_rate_year double precision,
    signed_from_emails_rate_year double precision,
    new_members_rate_year double precision,
    unsubscribes_rate_year double precision,
    like_rate_year double precision,
    hit_rate_year double precision
);


--
-- Name: petition_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE petition_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: petition_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE petition_reports_id_seq OWNED BY petition_reports.id;


--
-- Name: petition_summaries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE petition_summaries (
    id integer NOT NULL,
    short_summary text NOT NULL,
    petition_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: petition_summaries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE petition_summaries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: petition_summaries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE petition_summaries_id_seq OWNED BY petition_summaries.id;


--
-- Name: petition_titles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE petition_titles (
    id integer NOT NULL,
    title text NOT NULL,
    title_type character varying(255) NOT NULL,
    petition_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: petition_titles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE petition_titles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: petition_titles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE petition_titles_id_seq OWNED BY petition_titles.id;


--
-- Name: petition_versions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE petition_versions (
    id integer NOT NULL,
    title text,
    description text,
    petition_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: petition_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE petition_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: petition_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE petition_versions_id_seq OWNED BY petition_versions.id;


--
-- Name: petitions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE petitions (
    id integer NOT NULL,
    title text NOT NULL,
    description text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    owner_id integer,
    to_send boolean DEFAULT false,
    ip_address character varying(255),
    location character varying(255),
    deleted boolean,
    featured_on timestamp without time zone
);


--
-- Name: petitions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE petitions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: petitions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE petitions_id_seq OWNED BY petitions.id;


--
-- Name: referrals; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE referrals (
    id integer NOT NULL,
    code character varying(255),
    member_id integer,
    petition_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: referrals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE referrals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: referrals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE referrals_id_seq OWNED BY referrals.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: sent_emails; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sent_emails (
    id integer NOT NULL,
    email character varying(255) NOT NULL,
    member_id integer NOT NULL,
    petition_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    signature_id integer,
    opened_at timestamp without time zone,
    clicked_at timestamp without time zone,
    type character varying(255) DEFAULT 'SentEmail'::character varying
);


--
-- Name: sent_emails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sent_emails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sent_emails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sent_emails_id_seq OWNED BY sent_emails.id;


--
-- Name: settings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE settings (
    id integer NOT NULL,
    data hstore,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE settings_id_seq OWNED BY settings.id;


--
-- Name: signatures; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE signatures (
    id integer NOT NULL,
    email character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    petition_id integer NOT NULL,
    ip_address character varying(255) NOT NULL,
    user_agent character varying(255) NOT NULL,
    browser_name character varying(255),
    created_member boolean,
    member_id integer NOT NULL,
    referer_id integer,
    reference_type character varying(255),
    referring_url text,
    first_name character varying(255),
    last_name character varying(255),
    city character varying(255),
    metrocode character varying(255),
    state character varying(255),
    state_code character varying(255),
    country_code character varying(255),
    http_referer character varying(255)
);


--
-- Name: signatures_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE signatures_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: signatures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE signatures_id_seq OWNED BY signatures.id;


--
-- Name: social_media_trials; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE social_media_trials (
    id integer NOT NULL,
    member_id integer,
    petition_id integer,
    goal character varying(255),
    key character varying(255),
    choice text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    referral_code character varying(255),
    referral_id integer
);


--
-- Name: social_media_trials_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE social_media_trials_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: social_media_trials_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE social_media_trials_id_seq OWNED BY social_media_trials.id;


--
-- Name: unsubscribes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE unsubscribes (
    id integer NOT NULL,
    email character varying(255) NOT NULL,
    cause character varying(255),
    member_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    ip_address character varying(255),
    user_agent character varying(255),
    sent_email_id integer
);


--
-- Name: unsubscribes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE unsubscribes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: unsubscribes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE unsubscribes_id_seq OWNED BY unsubscribes.id;


--
-- Name: user_feedbacks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_feedbacks (
    id integer NOT NULL,
    name character varying(255),
    email character varying(255),
    message text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_feedbacks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_feedbacks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_feedbacks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_feedbacks_id_seq OWNED BY user_feedbacks.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_super_user boolean DEFAULT false NOT NULL,
    is_admin boolean DEFAULT false NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    failed_attempts integer DEFAULT 0,
    unlock_token character varying(255),
    locked_at timestamp without time zone
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY bounced_emails ALTER COLUMN id SET DEFAULT nextval('bounced_emails_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY donations ALTER COLUMN id SET DEFAULT nextval('donations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY email_errors ALTER COLUMN id SET DEFAULT nextval('email_errors_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY email_experiments ALTER COLUMN id SET DEFAULT nextval('email_experiments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY facebook_actions ALTER COLUMN id SET DEFAULT nextval('facebook_actions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY facebook_friends ALTER COLUMN id SET DEFAULT nextval('facebook_friends_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY facebook_share_widget_shares ALTER COLUMN id SET DEFAULT nextval('facebook_share_widget_shares_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY last_updated_unsubscribes ALTER COLUMN id SET DEFAULT nextval('last_updated_unsubscribes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY mailer_process_trackers ALTER COLUMN id SET DEFAULT nextval('mailer_process_trackers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY members ALTER COLUMN id SET DEFAULT nextval('members_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY memberships ALTER COLUMN id SET DEFAULT nextval('memberships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY petition_descriptions ALTER COLUMN id SET DEFAULT nextval('petition_descriptions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY petition_images ALTER COLUMN id SET DEFAULT nextval('petition_images_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY petition_reports ALTER COLUMN id SET DEFAULT nextval('petition_reports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY petition_summaries ALTER COLUMN id SET DEFAULT nextval('petition_summaries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY petition_titles ALTER COLUMN id SET DEFAULT nextval('petition_titles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY petition_versions ALTER COLUMN id SET DEFAULT nextval('petition_versions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY petitions ALTER COLUMN id SET DEFAULT nextval('petitions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY referrals ALTER COLUMN id SET DEFAULT nextval('referrals_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sent_emails ALTER COLUMN id SET DEFAULT nextval('sent_emails_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY settings ALTER COLUMN id SET DEFAULT nextval('settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY signatures ALTER COLUMN id SET DEFAULT nextval('signatures_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY social_media_trials ALTER COLUMN id SET DEFAULT nextval('social_media_trials_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY unsubscribes ALTER COLUMN id SET DEFAULT nextval('unsubscribes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_feedbacks ALTER COLUMN id SET DEFAULT nextval('user_feedbacks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: bounced_emails_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY bounced_emails
    ADD CONSTRAINT bounced_emails_pkey PRIMARY KEY (id);


--
-- Name: donation_clicks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY donations
    ADD CONSTRAINT donation_clicks_pkey PRIMARY KEY (id);


--
-- Name: email_errors_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY email_errors
    ADD CONSTRAINT email_errors_pkey PRIMARY KEY (id);


--
-- Name: email_experiments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY email_experiments
    ADD CONSTRAINT email_experiments_pkey PRIMARY KEY (id);


--
-- Name: facebook_friends_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY facebook_friends
    ADD CONSTRAINT facebook_friends_pkey PRIMARY KEY (id);


--
-- Name: facebook_share_widget_shares_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY facebook_share_widget_shares
    ADD CONSTRAINT facebook_share_widget_shares_pkey PRIMARY KEY (id);


--
-- Name: last_updated_unsubscribes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY last_updated_unsubscribes
    ADD CONSTRAINT last_updated_unsubscribes_pkey PRIMARY KEY (id);


--
-- Name: likes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY facebook_actions
    ADD CONSTRAINT likes_pkey PRIMARY KEY (id);


--
-- Name: mailer_process_trackers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mailer_process_trackers
    ADD CONSTRAINT mailer_process_trackers_pkey PRIMARY KEY (id);


--
-- Name: members_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY members
    ADD CONSTRAINT members_pkey PRIMARY KEY (id);


--
-- Name: memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY memberships
    ADD CONSTRAINT memberships_pkey PRIMARY KEY (id);


--
-- Name: petition_descriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY petition_descriptions
    ADD CONSTRAINT petition_descriptions_pkey PRIMARY KEY (id);


--
-- Name: petition_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY petition_images
    ADD CONSTRAINT petition_images_pkey PRIMARY KEY (id);


--
-- Name: petition_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY petition_reports
    ADD CONSTRAINT petition_reports_pkey PRIMARY KEY (id);


--
-- Name: petition_summaries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY petition_summaries
    ADD CONSTRAINT petition_summaries_pkey PRIMARY KEY (id);


--
-- Name: petition_titles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY petition_titles
    ADD CONSTRAINT petition_titles_pkey PRIMARY KEY (id);


--
-- Name: petition_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY petition_versions
    ADD CONSTRAINT petition_versions_pkey PRIMARY KEY (id);


--
-- Name: petitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY petitions
    ADD CONSTRAINT petitions_pkey PRIMARY KEY (id);


--
-- Name: referral_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY referrals
    ADD CONSTRAINT referral_codes_pkey PRIMARY KEY (id);


--
-- Name: sent_emails_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sent_emails
    ADD CONSTRAINT sent_emails_pkey PRIMARY KEY (id);


--
-- Name: settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: signatures_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY signatures
    ADD CONSTRAINT signatures_pkey PRIMARY KEY (id);


--
-- Name: social_media_experiments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY social_media_trials
    ADD CONSTRAINT social_media_experiments_pkey PRIMARY KEY (id);


--
-- Name: unsubscribes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY unsubscribes
    ADD CONSTRAINT unsubscribes_pkey PRIMARY KEY (id);


--
-- Name: user_feedbacks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_feedbacks
    ADD CONSTRAINT user_feedbacks_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_email_experiments_on_sent_email_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_email_experiments_on_sent_email_id ON email_experiments USING btree (sent_email_id);


--
-- Name: index_facebook_actions_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_facebook_actions_on_created_at ON facebook_actions USING btree (created_at);


--
-- Name: index_likes_on_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_likes_on_member_id ON facebook_actions USING btree (member_id);


--
-- Name: index_likes_on_petition_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_likes_on_petition_id ON facebook_actions USING btree (petition_id);


--
-- Name: index_members_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_members_on_email ON members USING btree (email);


--
-- Name: index_members_on_referral_code; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_members_on_referral_code ON members USING btree (referral_code);


--
-- Name: index_memberships_on_created_at_and_last_emailed_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_memberships_on_created_at_and_last_emailed_at ON memberships USING btree (created_at, last_emailed_at);


--
-- Name: index_memberships_on_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_memberships_on_member_id ON memberships USING btree (member_id);


--
-- Name: index_petition_reports_on_clicked_emails_rate_day; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petition_reports_on_clicked_emails_rate_day ON petition_reports USING btree (clicked_emails_rate_day);


--
-- Name: index_petition_reports_on_clicked_emails_rate_month; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petition_reports_on_clicked_emails_rate_month ON petition_reports USING btree (clicked_emails_rate_month);


--
-- Name: index_petition_reports_on_clicked_emails_rate_week; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petition_reports_on_clicked_emails_rate_week ON petition_reports USING btree (clicked_emails_rate_week);


--
-- Name: index_petition_reports_on_clicked_emails_rate_year; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petition_reports_on_clicked_emails_rate_year ON petition_reports USING btree (clicked_emails_rate_year);


--
-- Name: index_petition_reports_on_hit_rate_day; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petition_reports_on_hit_rate_day ON petition_reports USING btree (hit_rate_day);


--
-- Name: index_petition_reports_on_hit_rate_month; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petition_reports_on_hit_rate_month ON petition_reports USING btree (hit_rate_month);


--
-- Name: index_petition_reports_on_hit_rate_week; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petition_reports_on_hit_rate_week ON petition_reports USING btree (hit_rate_week);


--
-- Name: index_petition_reports_on_hit_rate_year; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petition_reports_on_hit_rate_year ON petition_reports USING btree (hit_rate_year);


--
-- Name: index_petition_reports_on_like_rate_day; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petition_reports_on_like_rate_day ON petition_reports USING btree (like_rate_day);


--
-- Name: index_petition_reports_on_like_rate_month; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petition_reports_on_like_rate_month ON petition_reports USING btree (like_rate_month);


--
-- Name: index_petition_reports_on_like_rate_week; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petition_reports_on_like_rate_week ON petition_reports USING btree (like_rate_week);


--
-- Name: index_petition_reports_on_like_rate_year; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petition_reports_on_like_rate_year ON petition_reports USING btree (like_rate_year);


--
-- Name: index_petition_reports_on_new_members_rate_day; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petition_reports_on_new_members_rate_day ON petition_reports USING btree (new_members_rate_day);


--
-- Name: index_petition_reports_on_new_members_rate_month; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petition_reports_on_new_members_rate_month ON petition_reports USING btree (new_members_rate_month);


--
-- Name: index_petition_reports_on_new_members_rate_week; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petition_reports_on_new_members_rate_week ON petition_reports USING btree (new_members_rate_week);


--
-- Name: index_petition_reports_on_new_members_rate_year; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petition_reports_on_new_members_rate_year ON petition_reports USING btree (new_members_rate_year);


--
-- Name: index_petition_reports_on_opened_emails_rate_day; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petition_reports_on_opened_emails_rate_day ON petition_reports USING btree (opened_emails_rate_day);


--
-- Name: index_petition_reports_on_opened_emails_rate_month; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petition_reports_on_opened_emails_rate_month ON petition_reports USING btree (opened_emails_rate_month);


--
-- Name: index_petition_reports_on_opened_emails_rate_week; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petition_reports_on_opened_emails_rate_week ON petition_reports USING btree (opened_emails_rate_week);


--
-- Name: index_petition_reports_on_opened_emails_rate_year; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petition_reports_on_opened_emails_rate_year ON petition_reports USING btree (opened_emails_rate_year);


--
-- Name: index_petition_reports_on_petition_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petition_reports_on_petition_created_at ON petition_reports USING btree (petition_created_at);


--
-- Name: index_petition_reports_on_petition_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petition_reports_on_petition_id ON petition_reports USING btree (petition_id);


--
-- Name: index_petition_reports_on_petition_title; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petition_reports_on_petition_title ON petition_reports USING btree (petition_title);


--
-- Name: index_petition_reports_on_sent_emails_count_day; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petition_reports_on_sent_emails_count_day ON petition_reports USING btree (sent_emails_count_day);


--
-- Name: index_petition_reports_on_sent_emails_count_month; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petition_reports_on_sent_emails_count_month ON petition_reports USING btree (sent_emails_count_month);


--
-- Name: index_petition_reports_on_sent_emails_count_week; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petition_reports_on_sent_emails_count_week ON petition_reports USING btree (sent_emails_count_week);


--
-- Name: index_petition_reports_on_sent_emails_count_year; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petition_reports_on_sent_emails_count_year ON petition_reports USING btree (sent_emails_count_year);


--
-- Name: index_petition_reports_on_signed_from_emails_rate_day; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petition_reports_on_signed_from_emails_rate_day ON petition_reports USING btree (signed_from_emails_rate_day);


--
-- Name: index_petition_reports_on_signed_from_emails_rate_month; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petition_reports_on_signed_from_emails_rate_month ON petition_reports USING btree (signed_from_emails_rate_month);


--
-- Name: index_petition_reports_on_signed_from_emails_rate_week; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petition_reports_on_signed_from_emails_rate_week ON petition_reports USING btree (signed_from_emails_rate_week);


--
-- Name: index_petition_reports_on_signed_from_emails_rate_year; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petition_reports_on_signed_from_emails_rate_year ON petition_reports USING btree (signed_from_emails_rate_year);


--
-- Name: index_petition_reports_on_unsubscribes_rate_day; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petition_reports_on_unsubscribes_rate_day ON petition_reports USING btree (unsubscribes_rate_day);


--
-- Name: index_petition_reports_on_unsubscribes_rate_month; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petition_reports_on_unsubscribes_rate_month ON petition_reports USING btree (unsubscribes_rate_month);


--
-- Name: index_petition_reports_on_unsubscribes_rate_week; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petition_reports_on_unsubscribes_rate_week ON petition_reports USING btree (unsubscribes_rate_week);


--
-- Name: index_petition_reports_on_unsubscribes_rate_year; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petition_reports_on_unsubscribes_rate_year ON petition_reports USING btree (unsubscribes_rate_year);


--
-- Name: index_petitions_on_title; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petitions_on_title ON petitions USING btree (title);


--
-- Name: index_referral_codes_on_code; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_referral_codes_on_code ON referrals USING btree (code);


--
-- Name: index_referral_codes_on_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_referral_codes_on_member_id ON referrals USING btree (member_id);


--
-- Name: index_sent_emails_on_clicked_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sent_emails_on_clicked_at ON sent_emails USING btree (clicked_at);


--
-- Name: index_sent_emails_on_created_at_and_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sent_emails_on_created_at_and_type ON sent_emails USING btree (created_at, type);


--
-- Name: index_sent_emails_on_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sent_emails_on_member_id ON sent_emails USING btree (member_id);


--
-- Name: index_sent_emails_on_opened_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sent_emails_on_opened_at ON sent_emails USING btree (opened_at);


--
-- Name: index_sent_emails_on_petition_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sent_emails_on_petition_id ON sent_emails USING btree (petition_id);


--
-- Name: index_sent_emails_on_signature_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sent_emails_on_signature_id ON sent_emails USING btree (signature_id);


--
-- Name: index_signatures_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_signatures_on_created_at ON signatures USING btree (created_at);


--
-- Name: index_signatures_on_created_member; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_signatures_on_created_member ON signatures USING btree (created_member);


--
-- Name: index_signatures_on_petition_id_and_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_signatures_on_petition_id_and_member_id ON signatures USING btree (petition_id, member_id);


--
-- Name: index_signatures_on_referer_id_and_petition_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_signatures_on_referer_id_and_petition_id ON signatures USING btree (referer_id, petition_id);


--
-- Name: index_social_media_trials_on_referral_code; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_social_media_trials_on_referral_code ON social_media_trials USING btree (referral_code);


--
-- Name: index_social_media_trials_on_referral_code_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_social_media_trials_on_referral_code_id ON social_media_trials USING btree (referral_id);


--
-- Name: index_unsubscribes_on_member_id_and_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_unsubscribes_on_member_id_and_created_at ON unsubscribes USING btree (member_id, created_at);


--
-- Name: index_unsubscribes_on_sent_email_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_unsubscribes_on_sent_email_id ON unsubscribes USING btree (sent_email_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_users_on_unlock_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_unlock_token ON users USING btree (unlock_token);


--
-- Name: unique_facebook_friend; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_facebook_friend ON facebook_friends USING btree (member_id, facebook_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: unique_share; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_share ON facebook_share_widget_shares USING btree (user_facebook_id, friend_facebook_id, url);


--
-- Name: bounced_emails_sent_email_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bounced_emails
    ADD CONSTRAINT bounced_emails_sent_email_id_fk FOREIGN KEY (sent_email_id) REFERENCES sent_emails(id);


--
-- Name: email_errors_member_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY email_errors
    ADD CONSTRAINT email_errors_member_id_fk FOREIGN KEY (member_id) REFERENCES members(id);


--
-- Name: facebook_friends_member_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY facebook_friends
    ADD CONSTRAINT facebook_friends_member_id_fk FOREIGN KEY (member_id) REFERENCES members(id);


--
-- Name: petition_descriptions_petition_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY petition_descriptions
    ADD CONSTRAINT petition_descriptions_petition_id_fk FOREIGN KEY (petition_id) REFERENCES petitions(id);


--
-- Name: petition_images_petition_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY petition_images
    ADD CONSTRAINT petition_images_petition_id_fk FOREIGN KEY (petition_id) REFERENCES petitions(id);


--
-- Name: petition_summaries_petition_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY petition_summaries
    ADD CONSTRAINT petition_summaries_petition_id_fk FOREIGN KEY (petition_id) REFERENCES petitions(id);


--
-- Name: petition_titles_petition_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY petition_titles
    ADD CONSTRAINT petition_titles_petition_id_fk FOREIGN KEY (petition_id) REFERENCES petitions(id);


--
-- Name: petition_versions_petition_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY petition_versions
    ADD CONSTRAINT petition_versions_petition_id_fk FOREIGN KEY (petition_id) REFERENCES petitions(id);


--
-- Name: petitions_owner_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY petitions
    ADD CONSTRAINT petitions_owner_id_fk FOREIGN KEY (owner_id) REFERENCES users(id);


--
-- Name: sent_emails_member_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sent_emails
    ADD CONSTRAINT sent_emails_member_id_fk FOREIGN KEY (member_id) REFERENCES members(id);


--
-- Name: sent_emails_petition_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sent_emails
    ADD CONSTRAINT sent_emails_petition_id_fk FOREIGN KEY (petition_id) REFERENCES petitions(id);


--
-- Name: sent_emails_signature_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sent_emails
    ADD CONSTRAINT sent_emails_signature_id_fk FOREIGN KEY (signature_id) REFERENCES signatures(id);


--
-- Name: signatures_member_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY signatures
    ADD CONSTRAINT signatures_member_id_fk FOREIGN KEY (member_id) REFERENCES members(id);


--
-- Name: signatures_petition_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY signatures
    ADD CONSTRAINT signatures_petition_id_fk FOREIGN KEY (petition_id) REFERENCES petitions(id);


--
-- Name: unsubscribes_member_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY unsubscribes
    ADD CONSTRAINT unsubscribes_member_id_fk FOREIGN KEY (member_id) REFERENCES members(id);


--
-- Name: unsubscribes_sent_email_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY unsubscribes
    ADD CONSTRAINT unsubscribes_sent_email_id_fk FOREIGN KEY (sent_email_id) REFERENCES sent_emails(id);


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_migrations (version) VALUES ('20120423162418');

INSERT INTO schema_migrations (version) VALUES ('20120423181812');

INSERT INTO schema_migrations (version) VALUES ('20120423182832');

INSERT INTO schema_migrations (version) VALUES ('20120423204744');

INSERT INTO schema_migrations (version) VALUES ('20120423205223');

INSERT INTO schema_migrations (version) VALUES ('20120424204557');

INSERT INTO schema_migrations (version) VALUES ('20120424214309');

INSERT INTO schema_migrations (version) VALUES ('20120425182101');

INSERT INTO schema_migrations (version) VALUES ('20120425184002');

INSERT INTO schema_migrations (version) VALUES ('20120425184924');

INSERT INTO schema_migrations (version) VALUES ('20120425194605');

INSERT INTO schema_migrations (version) VALUES ('20120425203252');

INSERT INTO schema_migrations (version) VALUES ('20120425212929');

INSERT INTO schema_migrations (version) VALUES ('20120430153714');

INSERT INTO schema_migrations (version) VALUES ('20120501195241');

INSERT INTO schema_migrations (version) VALUES ('20120502204320');

INSERT INTO schema_migrations (version) VALUES ('20120502204707');

INSERT INTO schema_migrations (version) VALUES ('20120502205039');

INSERT INTO schema_migrations (version) VALUES ('20120502205741');

INSERT INTO schema_migrations (version) VALUES ('20120502213546');

INSERT INTO schema_migrations (version) VALUES ('20120503192313');

INSERT INTO schema_migrations (version) VALUES ('20120503215401');

INSERT INTO schema_migrations (version) VALUES ('20120503220358');

INSERT INTO schema_migrations (version) VALUES ('20120507170034');

INSERT INTO schema_migrations (version) VALUES ('20120507205734');

INSERT INTO schema_migrations (version) VALUES ('20120508174238');

INSERT INTO schema_migrations (version) VALUES ('20120509193400');

INSERT INTO schema_migrations (version) VALUES ('20120511185131');

INSERT INTO schema_migrations (version) VALUES ('20120511200136');

INSERT INTO schema_migrations (version) VALUES ('20120514193702');

INSERT INTO schema_migrations (version) VALUES ('20120514194002');

INSERT INTO schema_migrations (version) VALUES ('20120514194233');

INSERT INTO schema_migrations (version) VALUES ('20120517143836');

INSERT INTO schema_migrations (version) VALUES ('20120521213355');

INSERT INTO schema_migrations (version) VALUES ('20120523181749');

INSERT INTO schema_migrations (version) VALUES ('20120523202636');

INSERT INTO schema_migrations (version) VALUES ('20120525150132');

INSERT INTO schema_migrations (version) VALUES ('20120529212035');

INSERT INTO schema_migrations (version) VALUES ('20120530185112');

INSERT INTO schema_migrations (version) VALUES ('20120612172923');

INSERT INTO schema_migrations (version) VALUES ('20120612194642');

INSERT INTO schema_migrations (version) VALUES ('20120615133057');

INSERT INTO schema_migrations (version) VALUES ('20120616194448');

INSERT INTO schema_migrations (version) VALUES ('20120619190009');

INSERT INTO schema_migrations (version) VALUES ('20120620204450');

INSERT INTO schema_migrations (version) VALUES ('20120620213532');

INSERT INTO schema_migrations (version) VALUES ('20120628204431');

INSERT INTO schema_migrations (version) VALUES ('20120703162414');

INSERT INTO schema_migrations (version) VALUES ('20120706175120');

INSERT INTO schema_migrations (version) VALUES ('20120709205117');

INSERT INTO schema_migrations (version) VALUES ('20120713175837');

INSERT INTO schema_migrations (version) VALUES ('20120717180041');

INSERT INTO schema_migrations (version) VALUES ('20120717220916');

INSERT INTO schema_migrations (version) VALUES ('20120727144159');

INSERT INTO schema_migrations (version) VALUES ('20120727195543');

INSERT INTO schema_migrations (version) VALUES ('20120730192950');

INSERT INTO schema_migrations (version) VALUES ('20120731151657');

INSERT INTO schema_migrations (version) VALUES ('20120802164454');

INSERT INTO schema_migrations (version) VALUES ('20120807021552');

INSERT INTO schema_migrations (version) VALUES ('20120813135808');

INSERT INTO schema_migrations (version) VALUES ('20120814144247');

INSERT INTO schema_migrations (version) VALUES ('20120814205636');

INSERT INTO schema_migrations (version) VALUES ('20120815195803');

INSERT INTO schema_migrations (version) VALUES ('20120907162148');

INSERT INTO schema_migrations (version) VALUES ('20120907192317');

INSERT INTO schema_migrations (version) VALUES ('20120907192626');

INSERT INTO schema_migrations (version) VALUES ('20120907192741');

INSERT INTO schema_migrations (version) VALUES ('20120907192921');

INSERT INTO schema_migrations (version) VALUES ('20120911183827');

INSERT INTO schema_migrations (version) VALUES ('20120912200102');

INSERT INTO schema_migrations (version) VALUES ('20120912230331');

INSERT INTO schema_migrations (version) VALUES ('20120919173938');

INSERT INTO schema_migrations (version) VALUES ('20120927213629');

INSERT INTO schema_migrations (version) VALUES ('20120928182724');

INSERT INTO schema_migrations (version) VALUES ('20120928213712');

INSERT INTO schema_migrations (version) VALUES ('20121001201648');

INSERT INTO schema_migrations (version) VALUES ('20121002150543');

INSERT INTO schema_migrations (version) VALUES ('20121002194102');

INSERT INTO schema_migrations (version) VALUES ('20121002194512');

INSERT INTO schema_migrations (version) VALUES ('20121003182142');

INSERT INTO schema_migrations (version) VALUES ('20121022164546');

INSERT INTO schema_migrations (version) VALUES ('20121025143023');

INSERT INTO schema_migrations (version) VALUES ('20121025192718');

INSERT INTO schema_migrations (version) VALUES ('20121029223417');

INSERT INTO schema_migrations (version) VALUES ('20121106204337');

INSERT INTO schema_migrations (version) VALUES ('20121107183005');

INSERT INTO schema_migrations (version) VALUES ('20121107190755');

INSERT INTO schema_migrations (version) VALUES ('20121107225527');

INSERT INTO schema_migrations (version) VALUES ('20121108222518');

INSERT INTO schema_migrations (version) VALUES ('20121108224349');

INSERT INTO schema_migrations (version) VALUES ('20121109170525');

INSERT INTO schema_migrations (version) VALUES ('20121114190641');

INSERT INTO schema_migrations (version) VALUES ('20121128192958');

INSERT INTO schema_migrations (version) VALUES ('20121204152700');

INSERT INTO schema_migrations (version) VALUES ('20121205153530');

INSERT INTO schema_migrations (version) VALUES ('20121205220148');

INSERT INTO schema_migrations (version) VALUES ('20121205225644');

INSERT INTO schema_migrations (version) VALUES ('20121205231636');

INSERT INTO schema_migrations (version) VALUES ('20121206152505');

INSERT INTO schema_migrations (version) VALUES ('20121206221047');

INSERT INTO schema_migrations (version) VALUES ('20121207184454');

INSERT INTO schema_migrations (version) VALUES ('20121207204236');

INSERT INTO schema_migrations (version) VALUES ('20121207215125');

INSERT INTO schema_migrations (version) VALUES ('20121207215431');

INSERT INTO schema_migrations (version) VALUES ('20121214220106');

INSERT INTO schema_migrations (version) VALUES ('20121217222152');

INSERT INTO schema_migrations (version) VALUES ('20121217232901');

INSERT INTO schema_migrations (version) VALUES ('20121221190432');

INSERT INTO schema_migrations (version) VALUES ('20121221195144');

INSERT INTO schema_migrations (version) VALUES ('20130102220933');

INSERT INTO schema_migrations (version) VALUES ('20130722204142');

INSERT INTO schema_migrations (version) VALUES ('20130726021512');

INSERT INTO schema_migrations (version) VALUES ('20130807201238');

INSERT INTO schema_migrations (version) VALUES ('20130807232909');

INSERT INTO schema_migrations (version) VALUES ('20130813172552');

INSERT INTO schema_migrations (version) VALUES ('20130813205234');

INSERT INTO schema_migrations (version) VALUES ('20130815221806');

INSERT INTO schema_migrations (version) VALUES ('20130820193236');

INSERT INTO schema_migrations (version) VALUES ('20130821005215');