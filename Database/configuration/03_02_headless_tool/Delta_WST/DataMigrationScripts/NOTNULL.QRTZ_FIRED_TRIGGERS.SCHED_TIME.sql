begin
  update qrtz_fired_triggers set sched_time = fired_time, last_updated_by = last_updated_by, last_updated_date = last_updated_date;  
end;
--~^UTDELIM^~--