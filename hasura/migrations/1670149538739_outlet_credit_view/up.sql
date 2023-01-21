CREATE OR REPLACE VIEW "public"."outlet_credit_view" AS 
 SELECT sub.id,
    sub.name,
    sub.phone,
    sub.distributorid,
    sub.balance,
    sub.last_transfer,
    ((date_part('day'::text, ((now())::timestamp without time zone - (sub.last_transfer)::timestamp without time zone)) * (24)::double precision) + date_part('hour'::text, ((now())::timestamp without time zone - (sub.last_transfer)::timestamp without time zone))) AS diff_in_hour,
    COALESCE(sub.transfers, (0)::numeric) AS transfers,
    COALESCE(sub.deposits, (0)::numeric) AS deposits,
    (COALESCE(sub.deposits, (0)::numeric) - COALESCE(sub.transfers, (0)::numeric)) AS difference
   FROM ( SELECT o.id,
            o.name,
            o.phone,
            o.distributorid,
            o.balance,
            ( SELECT sum(tr.birr_value) AS sum
                   FROM transfer tr
                  WHERE ((tr.outletid = o.id) AND (tr.is_root = true))) AS transfers,
            ( SELECT sum(dp.amount) AS deposits
                   FROM deposit dp
                  WHERE ((dp.outletid = o.id) AND (dp.approverid IS NOT NULL))) AS deposits,
            ( SELECT max(tr.created_at) AS last_transfer
                   FROM transfer tr
                  WHERE ((tr.outletid = o.id) AND (tr.is_root = true))) AS last_transfer
           FROM (outlet o JOIN distributor dist ON ((dist.id = o.distributorid)))) sub;
