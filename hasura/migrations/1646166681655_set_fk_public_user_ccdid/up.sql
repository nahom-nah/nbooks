alter table "public"."user"
  add constraint "user_ccdid_fkey"
  foreign key ("ccdid")
  references "public"."ccd"
  ("id") on update restrict on delete restrict;
