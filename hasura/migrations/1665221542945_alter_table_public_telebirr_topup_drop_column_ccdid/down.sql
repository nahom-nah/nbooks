alter table "public"."telebirr_topup"
  add constraint "telebirr_topup_ccdid_fkey"
  foreign key (ccdid)
  references "public"."ccd"
  (id) on update restrict on delete restrict;
alter table "public"."telebirr_topup" alter column "ccdid" drop not null;
alter table "public"."telebirr_topup" add column "ccdid" uuid;
