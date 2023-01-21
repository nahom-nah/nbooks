alter table "public"."deposit" drop constraint "deposit_ref_number_key";
alter table "public"."deposit" add constraint "deposit_depositorid_ref_number_key" unique ("depositorid", "ref_number");
