alter table "public"."deposit"
  add constraint "deposit_auditorid_fkey"
  foreign key ("auditorid")
  references "public"."user"
  ("id") on update restrict on delete restrict;
