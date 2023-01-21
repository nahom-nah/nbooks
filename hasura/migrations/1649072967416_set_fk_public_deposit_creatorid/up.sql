alter table "public"."deposit"
  add constraint "deposit_creatorid_fkey"
  foreign key ("creatorid")
  references "public"."user"
  ("id") on update restrict on delete restrict;
