CREATE OR REPLACE VIEW "public"."distributor_view" AS 
SELECT d.id,
       d.name,
       d.phone,
       d.active,
       d.sellon,
       d.balance,
    (SELECT sum(tp.airtime) as topups
           FROM dtopup tp
          WHERE (tp.distributorid = d.id) AND tp.approverid is not null),
    (SELECT sum(py.amount) as payments
           FROM payment py
          WHERE (py.distributorid = d.id) AND py.approverid is not null)
    FROM distributor d;
