CREATE TABLE "public"."outlet" ("id" uuid NOT NULL DEFAULT gen_random_uuid(), "created_at" timestamptz NOT NULL DEFAULT now(), "updated_at" timestamptz NOT NULL DEFAULT now(), "name" text NOT NULL, "email" text, "active" boolean NOT NULL DEFAULT true, "sellon" numeric NOT NULL DEFAULT 0, "balance" numeric NOT NULL DEFAULT 0, "max_print" numeric NOT NULL DEFAULT 500, "phone" text NOT NULL, "type" text NOT NULL DEFAULT 'DIRECT', PRIMARY KEY ("id") , UNIQUE ("phone"), UNIQUE ("email"));
CREATE OR REPLACE FUNCTION "public"."set_current_timestamp_updated_at"()
RETURNS TRIGGER AS $$
DECLARE
  _new record;
BEGIN
  _new := NEW;
  _new."updated_at" = NOW();
  RETURN _new;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER "set_public_outlet_updated_at"
BEFORE UPDATE ON "public"."outlet"
FOR EACH ROW
EXECUTE PROCEDURE "public"."set_current_timestamp_updated_at"();
COMMENT ON TRIGGER "set_public_outlet_updated_at" ON "public"."outlet" 
IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE EXTENSION IF NOT EXISTS pgcrypto;
