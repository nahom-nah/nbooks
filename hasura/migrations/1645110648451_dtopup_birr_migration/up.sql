CREATE OR REPLACE FUNCTION public.dtopup_birr(dtopup_info dtopup)
 RETURNS numeric
 LANGUAGE sql
 STABLE
AS $function$
  SELECT (dtopup_info.airtime*(100-dtopup_info.sellon))/100
$function$;
