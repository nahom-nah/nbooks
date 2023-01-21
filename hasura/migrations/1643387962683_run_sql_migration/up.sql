CREATE FUNCTION transfer_birr(transfer_info transfer)
RETURNS numeric AS $$
  SELECT (transfer_info.amount*(100-transfer_info.sell_on))/100
$$ LANGUAGE sql STABLE;
