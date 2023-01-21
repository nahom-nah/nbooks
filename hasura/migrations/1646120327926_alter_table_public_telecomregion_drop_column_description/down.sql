alter table "public"."telecomregion" alter column "description" drop not null;
alter table "public"."telecomregion" add column "description" text;
