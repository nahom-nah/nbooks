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
    DATE_PART('day', now()::timestamp - sub.last_transfer::timestamp)  * 24 + DATE_PART('hour', now()::timestamp - sub.last_transfer::timestamp) diff_in_hour,
    coalesce(sub.transfers, 0) as transfers,
    coalesce(sub.deposits, 0) as deposits,
    coalesce((sub.deposits - sub.transfers), 0) AS difference
   FROM ( SELECT u.id,
            u.username,
            u.full_name,
            u.sex,
            u.phone,
            u.distributorid,
            m.balance,
            r.name as role,
            ( SELECT sum(tr.birr_value) AS transfers
                   FROM transfer tr
                  WHERE ((tr.senderid = u.id))) AS transfers,
            ( SELECT sum(dp.amount) AS deposits
                   FROM deposit dp
                  WHERE ((dp.depositorid = u.id) AND (dp.approverid IS NOT NULL))) AS deposits,
            ( select MAX(created_at) as last_transfer
                from transfer tr
                where tr.receiverid = u.id ) as last_transfer
           FROM "user" u
           join "money" m on m.userid = u.id
           JOIN role r ON u.roleid = r.id where r.name = 'Sales') sub;