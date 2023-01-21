alter table "public"."zone" add column "updated_at" timestamptz
 null default now();
