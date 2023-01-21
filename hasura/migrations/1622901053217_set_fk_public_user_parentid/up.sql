alter table "public"."user"
           add constraint "user_parentid_fkey"
           foreign key ("parentid")
           references "public"."user"
           ("id") on update restrict on delete restrict;
