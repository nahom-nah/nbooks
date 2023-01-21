alter table "public"."distributor"
  add constraint "distributor_stockid_fkey"
  foreign key ("stockid")
  references "public"."stock"
  ("id") on update restrict on delete restrict;
