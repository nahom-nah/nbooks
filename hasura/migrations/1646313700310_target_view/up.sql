CREATE OR REPLACE VIEW "public"."target_view" AS 
 SELECT
    t.id,
    u.id as userid,
    u.distributorid,
    t.periodid,
    t.target
   FROM ((target t
     JOIN "user" u ON ((t.userid = u.id))));
