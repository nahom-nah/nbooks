alter table "public"."dtopup"
  add constraint "dtopup_ccdid_fkey"
  foreign key ("ccdid")
  references "public"."ccd"
  ("id") on update restrict on delete restrict;
