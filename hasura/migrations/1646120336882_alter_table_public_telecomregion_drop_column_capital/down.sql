alter table "public"."telecomregion" alter column "capital" drop not null;
alter table "public"."telecomregion" add column "capital" text;
