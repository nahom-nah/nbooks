alter table "public"."order_item"
  add constraint "order_item_processorid_fkey"
  foreign key ("processorid")
  references "public"."user"
  ("id") on update restrict on delete restrict;
