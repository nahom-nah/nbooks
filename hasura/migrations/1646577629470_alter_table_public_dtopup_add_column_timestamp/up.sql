alter table "public"."dtopup" add column "timestamp" text
 not null unique default timeofday();
