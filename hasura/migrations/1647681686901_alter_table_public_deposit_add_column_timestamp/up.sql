alter table "public"."deposit" add column "timestamp" text
 null default extract(epoch from now());
