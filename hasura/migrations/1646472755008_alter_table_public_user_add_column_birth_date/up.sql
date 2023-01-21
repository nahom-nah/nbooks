alter table "public"."user" add column "birth_date" timestamptz
 not null default now();
