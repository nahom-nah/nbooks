alter table "item"."item_ledger"
  add constraint "item_ledger_outletid_fkey"
  foreign key ("outletid")
  references "public"."outlet"
  ("id") on update restrict on delete restrict;
