alter table "public"."batch_sale"
  add constraint "batch_sale_outletid_fkey"
  foreign key ("outletid")
  references "public"."outlet"
  ("id") on update restrict on delete restrict;
