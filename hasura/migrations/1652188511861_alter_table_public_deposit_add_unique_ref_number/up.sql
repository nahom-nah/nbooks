alter table "public"."deposit" drop constraint "deposit_ref_number_depositorid_key";
alter table "public"."deposit" add constraint "deposit_ref_number_key" unique ("ref_number");
