alter table "public"."dist_balance_log" drop constraint "dist_balance_log_otopupid_fkey",
  add constraint "dist_balance_log_otopupid_fkey"
  foreign key ("otopupid")
  references "public"."otopup"
  ("id") on update restrict on delete restrict;
