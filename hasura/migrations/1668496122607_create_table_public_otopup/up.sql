CREATE TABLE "public"."otopup" ("id" uuid NOT NULL DEFAULT gen_random_uuid(), "created_at" timestamptz NOT NULL DEFAULT now(), "updated_at" timestamptz NOT NULL DEFAULT now(), "approved_at" timestamptz, "sellon" numeric NOT NULL DEFAULT 0, "amount" numeric NOT NULL DEFAULT 0, "outletid" uuid NOT NULL, "distributorid" uuid NOT NULL, "creatorid" uuid NOT NULL, "approverid" uuid NOT NULL, "airtime" numeric NOT NULL DEFAULT 0, "timestamp" text, PRIMARY KEY ("id") , FOREIGN KEY ("distributorid") REFERENCES "public"."distributor"("id") ON UPDATE restrict ON DELETE restrict, FOREIGN KEY ("approverid") REFERENCES "public"."user"("id") ON UPDATE restrict ON DELETE restrict, FOREIGN KEY ("creatorid") REFERENCES "public"."user"("id") ON UPDATE restrict ON DELETE restrict, FOREIGN KEY ("outletid") REFERENCES "public"."outlet"("id") ON UPDATE restrict ON DELETE restrict, UNIQUE ("timestamp"));
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
CREATE TRIGGER "set_public_otopup_updated_at"
BEFORE UPDATE ON "public"."otopup"
FOR EACH ROW
EXECUTE PROCEDURE "public"."set_current_timestamp_updated_at"();
COMMENT ON TRIGGER "set_public_otopup_updated_at" ON "public"."otopup" 
IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE EXTENSION IF NOT EXISTS pgcrypto;
