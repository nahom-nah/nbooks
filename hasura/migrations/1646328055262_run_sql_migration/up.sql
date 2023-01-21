CREATE OR REPLACE VIEW "public"."distributor_view" AS 
 SELECT d.id,
    d.name,
    d.phone,
    d.active,
    d.sellon,
    d.balance,
    ( SELECT sum(tp.airtime) AS topups
           FROM dtopup tp
          WHERE ((tp.distributorid = d.id) AND (tp.approverid IS NOT NULL))) AS topups,
    ( SELECT sum(py.amount) AS payments
           FROM payment py
          WHERE ((py.distributorid = d.id) AND (py.approverid IS NOT NULL))) AS payments,
    d.email
   FROM distributor d;
