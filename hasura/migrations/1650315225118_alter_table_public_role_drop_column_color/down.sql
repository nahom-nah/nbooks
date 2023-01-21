alter table "public"."role" alter column "color" set default ''#141414FF'::text';
alter table "public"."role" alter column "color" drop not null;
alter table "public"."role" add column "color" text;
