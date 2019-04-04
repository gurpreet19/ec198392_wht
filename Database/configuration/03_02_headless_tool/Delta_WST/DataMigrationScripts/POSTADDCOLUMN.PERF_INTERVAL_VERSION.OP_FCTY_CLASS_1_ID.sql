DECLARE
BEGIN
  UPDATE OV_PERF_INTERVAL o SET o.NETWORK_FILTER_ID = 
  EC_WELL_VERSION.OP_FCTY_CLASS_1_ID(WELL_ID, DAYTIME,'<='), o.last_updated_by= o.last_updated_by, o.last_updated_date = o.last_updated_date ;
END;
--~^UTDELIM^~--