alter table "public"."user" add column "updated_at" timestamptz
 null default now();
