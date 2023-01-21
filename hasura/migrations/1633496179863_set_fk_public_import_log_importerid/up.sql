alter table "public"."import_log"
           add constraint "import_log_importerid_fkey"
           foreign key ("importerid")
           references "public"."user"
           ("id") on update restrict on delete restrict;
