CREATE OR REPLACE VIEW "public"."distributor_view" AS 
 select sub.id,
        sub.name,
        sub.phone,
        sub.email,
        sub.active,
        sub.sellon,
        sub.balance,
        sub.topups,
        sub.payments,
        sub.payments - sub.topups as difference
 from (SELECT d.id,
    d.name,
    d.phone,
    d.active,
    d.sellon,
    d.balance,
    ( SELECT sum(tp.amount) AS topups
           FROM dtopup tp
          WHERE ((tp.distributorid = d.id) AND (tp.approverid IS NOT NULL))) AS topups,
    ( SELECT sum(py.amount) AS payments
           FROM payment py
          WHERE ((py.distributorid = d.id) AND (py.approverid IS NOT NULL))) AS payments,
    d.email
   FROM distributor d) sub;
