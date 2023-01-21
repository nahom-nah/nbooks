CREATE TABLE "item"."load" ("id" uuid NOT NULL DEFAULT gen_random_uuid(), "created_at" timestamptz NOT NULL DEFAULT now(), "updated_at" timestamptz NOT NULL DEFAULT now(), "itemid" uuid NOT NULL, "amount" integer NOT NULL, "old_balance" integer NOT NULL, "new_balance" integer NOT NULL, "creatorid" uuid NOT NULL, "timestamp" text NOT NULL, PRIMARY KEY ("id") , FOREIGN KEY ("creatorid") REFERENCES "public"."user"("id") ON UPDATE restrict ON DELETE restrict, FOREIGN KEY ("itemid") REFERENCES "item"."item"("id") ON UPDATE restrict ON DELETE restrict, UNIQUE ("timestamp"));
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
CREATE TRIGGER "set_item_load_updated_at"
BEFORE UPDATE ON "item"."load"
FOR EACH ROW
EXECUTE PROCEDURE "item"."set_current_timestamp_updated_at"();
COMMENT ON TRIGGER "set_item_load_updated_at" ON "item"."load" 
IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE EXTENSION IF NOT EXISTS pgcrypto;
