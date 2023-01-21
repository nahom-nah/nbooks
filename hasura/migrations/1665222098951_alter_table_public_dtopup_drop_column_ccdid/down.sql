alter table "public"."dtopup"
  add constraint "dtopup_ccdid_fkey"
  foreign key (ccdid)
  references "public"."ccd"
  (id) on update restrict on delete restrict;
alter table "public"."dtopup" alter column "ccdid" drop not null;
alter table "public"."dtopup" add column "ccdid" uuid;
