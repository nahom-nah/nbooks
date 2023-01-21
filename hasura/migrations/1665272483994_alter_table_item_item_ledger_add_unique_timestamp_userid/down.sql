alter table "item"."item_ledger" drop constraint "item_ledger_timestamp_userid_key";
alter table "item"."item_ledger" add constraint "item_ledger_timestamp_key" unique ("timestamp");
