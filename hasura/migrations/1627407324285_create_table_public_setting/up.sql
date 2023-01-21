CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TABLE "public"."setting"("id" uuid NOT NULL DEFAULT gen_random_uuid(), "created_at" timestamptz NOT NULL DEFAULT now(), "distributor_addon" integer NOT NULL DEFAULT 0, "agent_addon" integer NOT NULL DEFAULT 0, PRIMARY KEY ("id") );
