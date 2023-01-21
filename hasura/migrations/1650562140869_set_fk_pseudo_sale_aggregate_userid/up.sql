alter table "pseudo"."sale_aggregate"
  add constraint "sale_aggregate_userid_fkey"
  foreign key ("userid")
  references "public"."user"
  ("id") on update restrict on delete restrict;
