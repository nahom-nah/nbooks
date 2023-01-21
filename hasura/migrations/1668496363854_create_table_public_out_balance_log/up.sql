CREATE TABLE "public"."out_balance_log" ("id" uuid NOT NULL DEFAULT gen_random_uuid(), "created_at" timestamptz NOT NULL DEFAULT now(), "updated_at" timestamptz NOT NULL DEFAULT now(), "outletid" uuid NOT NULL, "amount" numeric NOT NULL, "old_balance" numeric NOT NULL, "new_balance" numeric NOT NULL, "otopupid" uuid NOT NULL, "timestamp" text NOT NULL, "itemid" uuid NOT NULL, PRIMARY KEY ("id") , FOREIGN KEY ("outletid") REFERENCES "public"."outlet"("id") ON UPDATE restrict ON DELETE restrict, FOREIGN KEY ("otopupid") REFERENCES "public"."otopup"("id") ON UPDATE restrict ON DELETE restrict, FOREIGN KEY ("itemid") REFERENCES "item"."item"("id") ON UPDATE restrict ON DELETE restrict, UNIQUE ("timestamp"));
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
CREATE TRIGGER "set_public_out_balance_log_updated_at"
BEFORE UPDATE ON "public"."out_balance_log"
FOR EACH ROW
EXECUTE PROCEDURE "public"."set_current_timestamp_updated_at"();
COMMENT ON TRIGGER "set_public_out_balance_log_updated_at" ON "public"."out_balance_log" 
IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE EXTENSION IF NOT EXISTS pgcrypto;
