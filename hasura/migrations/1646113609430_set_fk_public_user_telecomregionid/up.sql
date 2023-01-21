alter table "public"."user"
  add constraint "user_telecomregionid_fkey"
  foreign key ("telecomregionid")
  references "public"."telecomregion"
  ("id") on update restrict on delete restrict;
