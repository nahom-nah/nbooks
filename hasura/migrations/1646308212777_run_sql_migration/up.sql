CREATE OR REPLACE VIEW "public"."target_value_view" AS 
 SELECT t.id,
    u.full_name,
    u.sex,
    u.phone,
    u.email,
    u.distributorid,
    u.regionid,
    u.teleregionid,
    t.periodid,
    p.name,
    p.start_date,
    p.end_date,
    t.target,
    ( SELECT sum(tr.amount) AS sum
           FROM transfer tr
          WHERE ((tr.senderid = t.userid) AND ((tr.created_at <= p.end_date) AND (tr.created_at >= p.start_date)))) AS value,
    ( SELECT count(*) AS count
           FROM "user" u_1
          WHERE (t.userid = u_1.parentid)) AS agents,
    u.id as userid
   FROM ((target t
     JOIN period p ON ((t.periodid = p.id)))
     JOIN "user" u ON ((t.userid = u.id)));