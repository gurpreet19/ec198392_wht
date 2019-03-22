begin 
  update qrtz_scheduler_state  set sched_name = 'ECDS', last_updated_by = last_updated_by, last_updated_date = last_updated_date;  
end;
--~^UTDELIM^~--