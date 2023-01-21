alter table "pseudo"."sale_aggregate" alter column "id" set default gen_random_uuid();
alter table "pseudo"."sale_aggregate" alter column "id" drop not null;
alter table "pseudo"."sale_aggregate" add column "id" uuid;
