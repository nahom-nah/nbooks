alter table "public"."dist_balance_log" drop constraint "dist_balance_log_item_ledeger_id_fkey",
  add constraint "dist_balance_log_itemid_fkey"
  foreign key ("itemid")
  references "item"."item"
  ("id") on update restrict on delete restrict;
