CREATE OR REPLACE VIEW "public"."distributor_target_value_view" AS 
 select sub.*,  ( SELECT sum(t.amount) AS sum
           FROM transfer t 
           join "user" u on u.id = t.senderid
           join role r on u.roleid = r.id
          WHERE (r.slug = 'Sales' AND (t.distributorid = sub.id) AND ((t.created_at <= sub.end_date) AND (t.created_at >= sub.start_date)))) AS value from
 (SELECT d.id,
    d.name,
    p.name as period_name,
    p.start_date,
    p.end_date,
    sum(tr.target)
   FROM (distributor d
     JOIN target_view tr ON (tr.distributorid = d.id)
     join period p on (tr.periodid = p.id))
    group by (d.id, p.name, p.start_date, p.end_date)) sub;
