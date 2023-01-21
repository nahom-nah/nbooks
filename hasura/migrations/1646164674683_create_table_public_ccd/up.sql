CREATE TABLE "public"."ccd" ("id" uuid NOT NULL DEFAULT gen_random_uuid(), "created_at" timestamptz NOT NULL DEFAULT now(), "name" text NOT NULL, "phone" text NOT NULL, "fax" text NOT NULL, "email" text NOT NULL, "active" boolean NOT NULL DEFAULT true, "balance" numeric NOT NULL DEFAULT 0, PRIMARY KEY ("id") , UNIQUE ("name"));
CREATE EXTENSION IF NOT EXISTS pgcrypto;
