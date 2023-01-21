ALTER TABLE "public"."dtopup" ALTER COLUMN "timestamp" drop default;
alter table "public"."dtopup" alter column "timestamp" drop not null;
