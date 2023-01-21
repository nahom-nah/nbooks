CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TABLE "public"."balance_log"("id" uuid NOT NULL DEFAULT gen_random_uuid(), "created_at" timestamptz NOT NULL DEFAULT now(), "userid" uuid NOT NULL, "distributorid" uuid NOT NULL, "amount" numeric NOT NULL, "old_balance" numeric NOT NULL, "new_balance" numeric NOT NULL, "transferid" uuid NOT NULL, PRIMARY KEY ("id") , FOREIGN KEY ("userid") REFERENCES "public"."user"("id") ON UPDATE restrict ON DELETE restrict, FOREIGN KEY ("distributorid") REFERENCES "public"."distributor"("id") ON UPDATE restrict ON DELETE restrict, FOREIGN KEY ("transferid") REFERENCES "public"."transfer"("id") ON UPDATE restrict ON DELETE restrict, UNIQUE ("userid", "transferid"));
