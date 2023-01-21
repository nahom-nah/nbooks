alter table "public"."transfer"
  add constraint "transfer_outletid_fkey"
  foreign key ("outletid")
  references "public"."outlet"
  ("id") on update restrict on delete restrict;
