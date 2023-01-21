-- CREATE OR REPLACE VIEW "public"."so_credit_view" AS 
 SELECT sub.id,
    sub.name,
    sub.phone,
    sub.balance,
    sub.last_transfer,
    ((date_part('day'::text, ((now())::timestamp without time zone - (sub.last_transfer)::timestamp without time zone)) * (24)::double precision) + date_part('hour'::text, ((now())::timestamp without time zone - (sub.last_transfer)::timestamp without time zone))) AS diff_in_hour,
    COALESCE(sub.transfers, (0)::numeric) AS transfers,
    COALESCE(sub.deposits, (0)::numeric) AS deposits,
    ((((COALESCE(sub.deposits, (0)::numeric)))) - COALESCE(sub.transfers, (0)::numeric)) AS difference,
    sub.allow_agent_chain
   FROM ( SELECT d.id,
            d.name,
            d.phone,
            d.balance,
            ( SELECT sum(tr.birr_value) AS transfers
                   FROM ((transfer tr
                     JOIN "user" u ON ((tr.receiverid = u.id)))
                     JOIN role r ON ((u.roleid = r.id)))
                  WHERE ((tr.distributorid = d.id) AND tr.is_root AND (r.name = 'Agent'::text))) AS transfers,
            ( SELECT sum(dp.amount) AS deposits
                   FROM deposit dp
                  WHERE ((dp.distributorid = d.id) AND (dp.approverid IS NOT NULL) AND dp.is_root)) AS deposits,
            ( SELECT max(top.created_at) AS last_transfer
                   FROM dtopup top
                  WHERE ((top.distributorid = d.id) AND (top.approverid IS NOT NULL))) AS last_transfer,
            d.allow_agent_chain
           FROM distributor d) sub;
