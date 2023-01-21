create or replace view targer_value_view as
select 
t.id, u.full_name, u.sex, u.phone, u.email, u.distributorid, u.regionid, u.teleregionid, t.periodid, p.name, p.start_date, p.end_date, t.target,
(select sum(tr.amount) from transfer tr where ((tr.senderid = t.userid) and (tr.created_at <= p.end_date and tr.created_at >= p.start_date))) as value
from target t 
join period p on t.periodid = p.id 
join "user" u on t.userid = u.id;
