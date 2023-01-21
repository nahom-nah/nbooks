alter table "public"."out_balance_log"
  add constraint "out_balance_log_transferid_fkey"
  foreign key ("transferid")
  references "public"."transfer"
  ("id") on update restrict on delete restrict;
