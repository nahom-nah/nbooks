alter table "pseudo"."sale_aggregate"
  add constraint "sale_aggregate_distributorid_fkey"
  foreign key ("distributorid")
  references "public"."distributor"
  ("id") on update restrict on delete restrict;
