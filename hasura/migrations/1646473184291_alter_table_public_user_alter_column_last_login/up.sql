ALTER TABLE "public"."user" ALTER COLUMN "last_login" drop default;
alter table "public"."user" alter column "last_login" drop not null;
