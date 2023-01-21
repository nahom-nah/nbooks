alter table "public"."user" alter column "last_login" set not null;
alter table "public"."user" alter column "last_login" set default now();
