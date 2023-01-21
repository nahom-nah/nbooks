alter table "public"."target"
  add constraint "target_userid_fkey"
  foreign key ("userid")
  references "public"."user"
  ("id") on update restrict on delete restrict;
