alter table "public"."user" drop constraint "user_teleregionid_fkey",
  add constraint "user_telecomregionid_fkey"
  foreign key ("teleregionid")
  references "public"."region"
  ("id") on update restrict on delete restrict;
