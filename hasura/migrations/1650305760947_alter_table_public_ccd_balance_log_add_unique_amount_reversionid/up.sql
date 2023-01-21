alter table "public"."ccd_balance_log" add constraint "ccd_balance_log_amount_reversionid_key" unique ("amount", "reversionid");
