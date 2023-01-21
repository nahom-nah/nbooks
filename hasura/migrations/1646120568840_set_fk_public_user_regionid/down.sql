alter table "public"."user" drop constraint "user_regionid_fkey",
  add constraint "user_regionid_fkey"
  foreign key ("regionid")
  references "public"."teleregion"
  ("id") on update restrict on delete restrict;
