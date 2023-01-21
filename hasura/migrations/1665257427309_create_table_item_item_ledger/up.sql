CREATE TABLE "item"."item_ledger" ("id" uuid NOT NULL DEFAULT gen_random_uuid(), "created_at" timestamptz NOT NULL DEFAULT now(), "updated_at" timestamptz NOT NULL DEFAULT now(), "itemid" uuid NOT NULL, "userid" uuid, "distributorid" uuid NOT NULL, "amount" integer NOT NULL DEFAULT 0, "price" numeric NOT NULL DEFAULT 0, "total" numeric NOT NULL DEFAULT 0, "timestamp" text NOT NULL, PRIMARY KEY ("id") , FOREIGN KEY ("itemid") REFERENCES "item"."item"("id") ON UPDATE restrict ON DELETE restrict, FOREIGN KEY ("distributorid") REFERENCES "public"."distributor"("id") ON UPDATE restrict ON DELETE restrict, FOREIGN KEY ("userid") REFERENCES "public"."user"("id") ON UPDATE restrict ON DELETE restrict, UNIQUE ("timestamp"));
CREATE OR REPLACE FUNCTION "item"."set_current_timestamp_updated_at"()
RETURNS TRIGGER AS $$
DECLARE
  _new record;
BEGIN
  _new := NEW;
  _new."updated_at" = NOW();
  RETURN _new;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER "set_item_item_ledger_updated_at"
BEFORE UPDATE ON "item"."item_ledger"
FOR EACH ROW
EXECUTE PROCEDURE "item"."set_current_timestamp_updated_at"();
COMMENT ON TRIGGER "set_item_item_ledger_updated_at" ON "item"."item_ledger" 
IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE EXTENSION IF NOT EXISTS pgcrypto;
