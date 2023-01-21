alter table "public"."user" drop constraint "user_telecomregionid_fkey",
  add constraint "user_teleregionid_fkey"
  foreign key ("teleregionid")
  references "public"."teleregion"
  ("id") on update restrict on delete restrict;
