ALTER TABLE "pseudo"."outlet_sale_aggregate" ALTER COLUMN "amount" drop default;
ALTER TABLE "pseudo"."outlet_sale_aggregate" ALTER COLUMN "amount" TYPE numeric;
