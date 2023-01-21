CREATE TABLE "public"."target" ("id" uuid NOT NULL DEFAULT gen_random_uuid(), "created_at" timestamptz NOT NULL DEFAULT now(), "periodid" uuid NOT NULL, "userid" uuid NOT NULL, "target" numeric NOT NULL DEFAULT 0, PRIMARY KEY ("id") );
CREATE EXTENSION IF NOT EXISTS pgcrypto;
