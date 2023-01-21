alter table "public"."load" add column "timestamp" text
 not null unique default timeofday();
