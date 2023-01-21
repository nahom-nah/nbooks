CREATE OR REPLACE VIEW "public"."sales_credit_view" AS 
 SELECT sub.id,
    sub.username,
    sub.full_name,
    sub.sex,
    sub.phone,
    sub.distributorid,
    sub.balance,
    sub.role,
    sub.last_transfer,
    ((date_part('day'::text, ((now())::timestamp without time zone - (sub.last_transfer)::timestamp without time zone)) * (24)::double precision) + date_part('hour'::text, ((now())::timestamp without time zone - (sub.last_transfer)::timestamp without time zone))) AS diff_in_hour,
    COALESCE(sub.transfers, (0)::numeric) AS transfers,
    COALESCE(sub.deposits, (0)::numeric) AS deposits,
    (COALESCE(sub.transfers, (0)::numeric) - COALESCE(sub.deposits, (0)::numeric)) AS difference
   FROM ( SELECT u.id,
            u.username,
            u.full_name,
            u.sex,
            u.phone,
            u.distributorid,
            m.balance,
            r.name AS role,
            ( SELECT sum(tr.birr_value) AS transfers
                   FROM transfer tr
                  WHERE (tr.senderid = u.id)) AS transfers,
            ( SELECT sum(dp.amount) AS deposits
                   FROM deposit dp
                  WHERE ((dp.depositorid = u.id) AND (dp.approverid IS NOT NULL))) AS deposits,
            ( SELECT max(tr.created_at) AS last_transfer
                   FROM transfer tr
                  WHERE (tr.receiverid = u.id)) AS last_transfer
           FROM (("user" u
             JOIN money m ON ((m.userid = u.id)))
             JOIN role r ON ((u.roleid = r.id)))
          WHERE (r.name = 'Sales'::text)) sub;
