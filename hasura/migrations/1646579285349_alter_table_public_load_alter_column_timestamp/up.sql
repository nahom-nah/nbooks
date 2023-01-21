ALTER TABLE "public"."load" ALTER COLUMN "timestamp" drop default;
alter table "public"."load" alter column "timestamp" drop not null;
