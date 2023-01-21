alter table "archive"."avoucher"
  add constraint "avoucher_stockid_fkey"
  foreign key ("stockid")
  references "public"."stock"
  ("id") on update restrict on delete restrict;
