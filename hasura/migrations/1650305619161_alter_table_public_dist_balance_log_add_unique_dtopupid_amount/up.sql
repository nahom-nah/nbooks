alter table "public"."dist_balance_log" add constraint "dist_balance_log_dtopupid_amount_key" unique ("dtopupid", "amount");
