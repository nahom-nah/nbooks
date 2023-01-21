CREATE TABLE "public"."order" ("id" uuid NOT NULL DEFAULT gen_random_uuid(), "created_at" timestamptz NOT NULL DEFAULT now(), "updated_at" timestamptz NOT NULL DEFAULT now(), "distributorid" uuid NOT NULL, "approved_at" timestamptz NOT NULL, "approverid" uuid NOT NULL, "cleared_at" timestamptz NOT NULL, "clearerid" uuid NOT NULL, "creatorid" uuid NOT NULL, PRIMARY KEY ("id") , FOREIGN KEY ("distributorid") REFERENCES "public"."distributor"("id") ON UPDATE restrict ON DELETE restrict, FOREIGN KEY ("approverid") REFERENCES "public"."user"("id") ON UPDATE restrict ON DELETE restrict, FOREIGN KEY ("clearerid") REFERENCES "public"."user"("id") ON UPDATE restrict ON DELETE restrict, FOREIGN KEY ("creatorid") REFERENCES "public"."user"("id") ON UPDATE restrict ON DELETE restrict);
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
CREATE TRIGGER "set_public_order_updated_at"
BEFORE UPDATE ON "public"."order"
FOR EACH ROW
EXECUTE PROCEDURE "public"."set_current_timestamp_updated_at"();
COMMENT ON TRIGGER "set_public_order_updated_at" ON "public"."order" 
IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE EXTENSION IF NOT EXISTS pgcrypto;
