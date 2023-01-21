CREATE TABLE "public"."period" ("id" uuid NOT NULL DEFAULT gen_random_uuid(), "name" text NOT NULL, "start_date" timestamptz NOT NULL, "end_Date" timestamptz NOT NULL, "created_at" timestamptz NOT NULL DEFAULT now(), PRIMARY KEY ("id") );
CREATE EXTENSION IF NOT EXISTS pgcrypto;
