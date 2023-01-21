alter table "public"."user" add column "last_login" timestamptz
 not null default now();
