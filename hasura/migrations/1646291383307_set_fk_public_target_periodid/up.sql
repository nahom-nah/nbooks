alter table "public"."target"
  add constraint "target_periodid_fkey"
  foreign key ("periodid")
  references "public"."period"
  ("id") on update restrict on delete restrict;
