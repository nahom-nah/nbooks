alter table "public"."ccd_balance_log"
  add constraint "ccd_balance_log_dtopupid_fkey"
  foreign key ("dtopupid")
  references "public"."dtopup"
  ("id") on update restrict on delete restrict;
