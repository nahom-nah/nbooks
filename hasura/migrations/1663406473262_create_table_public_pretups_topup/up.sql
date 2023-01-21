CREATE TABLE "public"."pretups_topup" ("id" uuid NOT NULL DEFAULT gen_random_uuid(), "created_at" timestamptz NOT NULL DEFAULT now(), "updated_at" timestamptz NOT NULL DEFAULT now(), "distributorid" uuid NOT NULL, "approverid" uuid, "creatorid" uuid NOT NULL, "ccdid" uuid, "timestamp" text, "amount" numeric NOT NULL, "approved_at" timestamptz, PRIMARY KEY ("id") , FOREIGN KEY ("distributorid") REFERENCES "public"."distributor"("id") ON UPDATE restrict ON DELETE restrict, FOREIGN KEY ("approverid") REFERENCES "public"."user"("id") ON UPDATE restrict ON DELETE restrict, FOREIGN KEY ("creatorid") REFERENCES "public"."user"("id") ON UPDATE restrict ON DELETE restrict, FOREIGN KEY ("ccdid") REFERENCES "public"."ccd"("id") ON UPDATE restrict ON DELETE restrict, UNIQUE ("timestamp"));
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
CREATE TRIGGER "set_public_pretups_topup_updated_at"
BEFORE UPDATE ON "public"."pretups_topup"
FOR EACH ROW
EXECUTE PROCEDURE "public"."set_current_timestamp_updated_at"();
COMMENT ON TRIGGER "set_public_pretups_topup_updated_at" ON "public"."pretups_topup" 
IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE EXTENSION IF NOT EXISTS pgcrypto;
