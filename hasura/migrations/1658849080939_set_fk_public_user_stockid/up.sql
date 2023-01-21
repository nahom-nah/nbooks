alter table "public"."user"
  add constraint "user_stockid_fkey"
  foreign key ("stockid")
  references "public"."stock"
  ("id") on update restrict on delete restrict;
