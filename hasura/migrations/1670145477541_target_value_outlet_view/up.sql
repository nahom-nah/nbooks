CREATE OR REPLACE VIEW "public"."target_value_outlet_view" AS 
 SELECT t.id,
    o.name AS outlet_name,
    o.phone,
    o.email,
    o.distributorid,
    t.periodid,
    p.name,
    p.start_date,
    p.end_date,
    t.target,
    ( SELECT sum(tr.amount) AS sum
           FROM transfer tr
          WHERE ((tr.outletid = t.outletid) AND (tr.is_root = true) AND ((tr.created_at <= p.end_date) AND (tr.created_at >= p.start_date)))) AS value,
    o.id AS outletid,
    d.name AS distributor_name
   FROM (((target t
     JOIN period p ON ((t.periodid = p.id)))
     JOIN "outlet" o ON ((t.outletid = o.id)))
     JOIN distributor d ON ((o.distributorid = d.id)));