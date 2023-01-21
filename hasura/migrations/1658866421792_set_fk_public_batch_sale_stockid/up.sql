alter table "public"."batch_sale"
  add constraint "batch_sale_stockid_fkey"
  foreign key ("stockid")
  references "public"."stock"
  ("id") on update restrict on delete restrict;
