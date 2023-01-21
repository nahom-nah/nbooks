CREATE OR REPLACE VIEW "public"."distributor_target_value_view" AS 
 SELECT sub.distributorid,
    sub.periodid,
    sub.start_date,
    sub.end_date,
    sub.sum,
    ( SELECT sum(t.amount) AS sum
           FROM ((transfer t
             JOIN "user" u ON ((u.id = t.senderid)))
             JOIN role r ON ((u.roleid = r.id)))
          WHERE ((r.slug = 'Sales'::text) AND (t.distributorid = sub.distributorid) AND ((t.created_at <= sub.end_date) AND (t.created_at >= sub.start_date)))) AS value
   FROM ( SELECT d.id as distributorid,
            p.id AS periodid,
            p.start_date,
            p.end_date,
            sum(tr.target) AS sum
           FROM ((distributor d
             JOIN target_view tr ON ((tr.distributorid = d.id)))
             JOIN period p ON ((tr.periodid = p.id)))
          GROUP BY d.id, p.id, p.start_date, p.end_date) sub;
