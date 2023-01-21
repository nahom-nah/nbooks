alter table "public"."dtopup" alter column "timestamp" set not null;
alter table "public"."dtopup" alter column "timestamp" set default timeofday();
