alter table "public"."region" add column "updated_at" timestamptz
 null default now();
