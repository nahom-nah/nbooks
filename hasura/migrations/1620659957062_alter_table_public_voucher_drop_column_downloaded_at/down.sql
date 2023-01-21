ALTER TABLE "public"."voucher" ADD COLUMN "downloaded_at" timestamptz;
ALTER TABLE "public"."voucher" ALTER COLUMN "downloaded_at" DROP NOT NULL;
