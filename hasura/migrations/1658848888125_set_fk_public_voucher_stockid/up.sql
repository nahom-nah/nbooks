alter table "public"."voucher"
  add constraint "voucher_stockid_fkey"
  foreign key ("stockid")
  references "public"."stock"
  ("id") on update restrict on delete restrict;
