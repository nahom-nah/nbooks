CREATE OR REPLACE VIEW "public"."target_outlet_view" AS 
 SELECT t.id,
    o.id AS outletid,
    o.distributorid,
    t.periodid,
    t.target
   FROM (target t
     JOIN "outlet" o ON ((t.outletid = o.id)));
