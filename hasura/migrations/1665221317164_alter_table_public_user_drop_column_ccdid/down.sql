alter table "public"."user" alter column "ccdid" drop not null;
alter table "public"."user" add column "ccdid" uuid;
