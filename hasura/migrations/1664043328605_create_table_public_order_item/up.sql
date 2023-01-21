CREATE TABLE "public"."order_item" ("id" uuid NOT NULL DEFAULT gen_random_uuid(), "created_at" timestamptz NOT NULL DEFAULT now(), "updated_at" timestamptz NOT NULL DEFAULT now(), "orderid" uuid NOT NULL, "denominationid" uuid NOT NULL, "amount" integer NOT NULL DEFAULT 0, PRIMARY KEY ("id") , FOREIGN KEY ("orderid") REFERENCES "public"."order"("id") ON UPDATE restrict ON DELETE restrict, FOREIGN KEY ("denominationid") REFERENCES "public"."denomination"("id") ON UPDATE restrict ON DELETE restrict, UNIQUE ("orderid", "denominationid"));
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
CREATE TRIGGER "set_public_order_item_updated_at"
BEFORE UPDATE ON "public"."order_item"
FOR EACH ROW
EXECUTE PROCEDURE "public"."set_current_timestamp_updated_at"();
COMMENT ON TRIGGER "set_public_order_item_updated_at" ON "public"."order_item" 
IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE EXTENSION IF NOT EXISTS pgcrypto;
