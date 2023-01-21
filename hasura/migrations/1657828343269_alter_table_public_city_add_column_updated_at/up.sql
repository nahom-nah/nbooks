alter table "public"."city" add column "updated_at" timestamptz
 null default now();
