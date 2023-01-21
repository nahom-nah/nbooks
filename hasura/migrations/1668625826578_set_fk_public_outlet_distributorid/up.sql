alter table "public"."outlet"
  add constraint "outlet_distributorid_fkey"
  foreign key ("distributorid")
  references "public"."distributor"
  ("id") on update restrict on delete restrict;
