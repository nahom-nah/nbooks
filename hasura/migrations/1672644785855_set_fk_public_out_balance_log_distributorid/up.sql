alter table "public"."out_balance_log"
  add constraint "out_balance_log_distributorid_fkey"
  foreign key ("distributorid")
  references "public"."distributor"
  ("id") on update restrict on delete restrict;
