alter table "public"."dist_balance_log" drop constraint "dist_balance_log_itemid_fkey",
  add constraint "dist_balance_log_item_ledeger_id_fkey"
  foreign key ("item_ledeger_id")
  references "item"."item_ledger"
  ("id") on update restrict on delete restrict;
