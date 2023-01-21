alter table "public"."load" alter column "timestamp" set not null;
alter table "public"."load" alter column "timestamp" set default timeofday();
