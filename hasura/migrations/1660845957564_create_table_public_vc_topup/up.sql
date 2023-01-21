CREATE TABLE "public"."vc_topup" ("id" uuid NOT NULL DEFAULT gen_random_uuid(), "created_at" timestamptz NOT NULL DEFAULT now(), "distributorid" uuid NOT NULL, "approverid" uuid, "creatorid" uuid NOT NULL, "ccdid" uuid, "timestamp" text, "amount" numeric NOT NULL, "approved_at" timestamp, PRIMARY KEY ("id") , FOREIGN KEY ("distributorid") REFERENCES "public"."distributor"("id") ON UPDATE restrict ON DELETE restrict, FOREIGN KEY ("approverid") REFERENCES "public"."user"("id") ON UPDATE restrict ON DELETE restrict, FOREIGN KEY ("creatorid") REFERENCES "public"."user"("id") ON UPDATE restrict ON DELETE restrict, FOREIGN KEY ("ccdid") REFERENCES "public"."ccd"("id") ON UPDATE restrict ON DELETE restrict, UNIQUE ("timestamp"));
CREATE EXTENSION IF NOT EXISTS pgcrypto;
