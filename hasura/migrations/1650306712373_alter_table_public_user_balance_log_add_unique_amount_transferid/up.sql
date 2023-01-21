alter table "public"."user_balance_log" add constraint "user_balance_log_amount_transferid_key" unique ("amount", "transferid");
