alter table "public"."setting" alter column "distributor_addon" set default 0;
alter table "public"."setting" add constraint "setting_distributor_addon_key" unique (distributor_addon);
alter table "public"."setting" alter column "distributor_addon" drop not null;
alter table "public"."setting" add column "distributor_addon" int4;
