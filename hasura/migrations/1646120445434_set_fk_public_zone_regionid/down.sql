alter table "public"."zone" drop constraint "zone_regionid_fkey",
  add constraint "zone_regionid_fkey"
  foreign key ("regionid")
  references "public"."teleregion"
  ("id") on update restrict on delete restrict;
