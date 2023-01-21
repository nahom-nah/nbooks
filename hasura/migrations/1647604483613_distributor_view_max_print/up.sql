CREATE OR REPLACE VIEW "public"."distributor_view" AS 
 SELECT sub.id,
    sub.name,
    sub.phone,
    sub.email,
    sub.active,
    sub.sellon,
    sub.balance,
    sub.topups,
    sub.payments,
    (sub.payments - sub.topups) AS difference,
    sub.max_print
   FROM ( SELECT d.id,
            d.name,
            d.phone,
            d.active,
            d.sellon,
            d.balance,
            ( SELECT sum(tp.amount) AS topups
                   FROM dtopup tp
                  WHERE ((tp.distributorid = d.id) AND (tp.approverid IS NOT NULL))) AS topups,
            ( SELECT sum(py.amount) AS payments
                   FROM deposit py
                  WHERE ((py.distributorid = d.id) AND (py.approverid IS NOT NULL))) AS payments,
            d.email,
            d.max_print
           FROM distributor d) sub;
