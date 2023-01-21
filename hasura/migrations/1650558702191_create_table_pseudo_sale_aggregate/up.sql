CREATE TABLE "pseudo"."sale_aggregate" ("id" uuid NOT NULL DEFAULT gen_random_uuid(), "userid" uuid NOT NULL, "distributorid" uuid NOT NULL, "amount" numeric NOT NULL DEFAULT 0, PRIMARY KEY ("id") );
CREATE EXTENSION IF NOT EXISTS pgcrypto;
