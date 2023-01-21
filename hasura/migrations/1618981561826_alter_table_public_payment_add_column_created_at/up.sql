ALTER TABLE "public"."payment" ADD COLUMN "created_at" timestamptz NULL DEFAULT now();
