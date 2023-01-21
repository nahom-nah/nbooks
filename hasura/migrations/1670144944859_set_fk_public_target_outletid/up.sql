alter table "public"."target"
  add constraint "target_outletid_fkey"
  foreign key ("outletid")
  references "public"."outlet"
  ("id") on update restrict on delete restrict;
