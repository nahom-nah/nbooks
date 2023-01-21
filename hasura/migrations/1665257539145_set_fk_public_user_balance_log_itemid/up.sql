alter table "public"."user_balance_log"
  add constraint "user_balance_log_itemid_fkey"
  foreign key ("itemid")
  references "item"."item"
  ("id") on update restrict on delete restrict;
