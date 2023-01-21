alter table "public"."dist_balance_log"
  add constraint "dist_balance_log_otopupid_fkey"
  foreign key ("otopupid")
  references "public"."dtopup"
  ("id") on update restrict on delete restrict;
