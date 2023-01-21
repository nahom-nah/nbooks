alter table "item"."item_balance"
  add constraint "item_balance_outletid_fkey"
  foreign key ("outletid")
  references "public"."outlet"
  ("id") on update restrict on delete restrict;
