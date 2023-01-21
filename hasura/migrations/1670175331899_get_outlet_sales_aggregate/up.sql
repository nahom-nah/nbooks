CREATE OR REPLACE FUNCTION public.get_outlet_sales_aggregate(start_date timestamp with time zone, end_date timestamp with time zone)
 RETURNS SETOF pseudo.outlet_sale_aggregate
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
begin
    return query (
        select s.outletid, sum(s.amount * d.value) 
        from public.batch_sale s 
        join public.denomination d on d.id = s.denominationid
        where s.created_at >= start_date and s.created_at <= end_date
        group by(s.outletid)
    );
end;
$function$;
