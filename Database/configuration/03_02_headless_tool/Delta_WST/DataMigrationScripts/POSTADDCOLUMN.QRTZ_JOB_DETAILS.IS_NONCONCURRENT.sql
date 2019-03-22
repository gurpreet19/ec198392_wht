declare
  column_missing EXCEPTION;
  column_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(column_missing, -904);
  PRAGMA EXCEPTION_INIT(column_exists, -1430);
begin
  begin
    EXECUTE IMMEDIATE 'update qrtz_job_details set is_nonconcurrent = is_stateful, is_update_data = is_stateful, last_updated_by = last_updated_by, last_updated_date = last_updated_date';
    exception when column_missing then null;
  end;
  begin
    EXECUTE IMMEDIATE 'update qrtz_fired_triggers set is_nonconcurrent = is_stateful, last_updated_by = last_updated_by, last_updated_date = last_updated_date';
    exception when column_missing then null;
  end;
  commit;
end;
--~^UTDELIM^~--