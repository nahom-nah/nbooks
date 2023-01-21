alter table "public"."ccd_balance_log" add constraint "ccd_balance_log_amount_loadid_key" unique ("amount", "loadid");
