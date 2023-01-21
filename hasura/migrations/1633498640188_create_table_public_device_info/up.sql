CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TABLE "public"."device_info"("id" uuid NOT NULL DEFAULT gen_random_uuid(), "created_at" timestamptz NOT NULL DEFAULT now(), "updated_at" timestamptz NOT NULL DEFAULT now(), "userid" uuid NOT NULL, "androidid" text, "brand" text, "model" text, "version" text, "device" text, "product" text, "last_used" timestamptz NOT NULL DEFAULT now(), PRIMARY KEY ("id") , FOREIGN KEY ("userid") REFERENCES "public"."user"("id") ON UPDATE restrict ON DELETE restrict, UNIQUE ("userid", "androidid"));
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
CREATE TRIGGER "set_public_device_info_updated_at"
BEFORE UPDATE ON "public"."device_info"
FOR EACH ROW
EXECUTE PROCEDURE "public"."set_current_timestamp_updated_at"();
COMMENT ON TRIGGER "set_public_device_info_updated_at" ON "public"."device_info" 
IS 'trigger to set value of column "updated_at" to current timestamp on row update';
