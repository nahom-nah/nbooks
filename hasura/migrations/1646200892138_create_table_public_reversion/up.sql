CREATE TABLE "public"."reversion" ("id" uuid NOT NULL DEFAULT gen_random_uuid(), "created_at" timestamptz NOT NULL DEFAULT now(), "airtime" numeric NOT NULL, "ccdid" uuid NOT NULL, PRIMARY KEY ("id") , FOREIGN KEY ("ccdid") REFERENCES "public"."ccd"("id") ON UPDATE restrict ON DELETE restrict);
CREATE EXTENSION IF NOT EXISTS pgcrypto;
