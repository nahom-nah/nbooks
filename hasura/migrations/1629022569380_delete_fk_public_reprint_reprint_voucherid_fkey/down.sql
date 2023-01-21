alter table "public"."reprint" add foreign key ("voucherid") references "public"."voucher"("id") on update restrict on delete restrict;
