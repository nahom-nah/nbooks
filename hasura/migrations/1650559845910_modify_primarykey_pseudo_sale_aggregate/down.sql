alter table "pseudo"."sale_aggregate" drop constraint "sale_aggregate_pkey";
alter table "pseudo"."sale_aggregate"
    add constraint "sale_aggregate_pkey"
    primary key ("id");
