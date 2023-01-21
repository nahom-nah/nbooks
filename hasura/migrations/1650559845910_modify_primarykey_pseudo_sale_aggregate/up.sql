BEGIN TRANSACTION;
ALTER TABLE "pseudo"."sale_aggregate" DROP CONSTRAINT "sale_aggregate_pkey";

ALTER TABLE "pseudo"."sale_aggregate"
    ADD CONSTRAINT "sale_aggregate_pkey" PRIMARY KEY ("userid");
COMMIT TRANSACTION;
