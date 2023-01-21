alter table "public"."deposit"
  add constraint "deposit_outletid_fkey"
  foreign key ("outletid")
  references "public"."outlet"
  ("id") on update restrict on delete restrict;
