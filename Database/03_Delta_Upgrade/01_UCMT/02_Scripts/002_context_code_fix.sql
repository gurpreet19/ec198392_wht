declare 
  cursor c_changes_class is
    select old.class_name
    from   CLASS        old
    where  nvl(app_space_code, 'XX') in ('EC_FRMW','EC_PROD','EC_TRAN','EC_SALE','EC_REVN','EC_ECDM','EC_DM','EC_BPM', 'XX')
    and    not exists ( select 'X'
                        from   u_CLASS_cnfg  ootb
                        where  old.class_name     = ootb.class_name
                      )
    order by class_name;

  cursor c_changes_class_attr is
    select old.class_name
    ,      old.attribute_name
    from   CLASS_ATTRIBUTE        old
    where  nvl(context_code, 'XX') in ('EC_FRMW','EC_PROD','EC_TRAN','EC_SALE','EC_REVN','EC_ECDM','EC_DM','EC_BPM', 'XX')
    and    not exists ( select 'X'
                        from   u_CLASS_ATTRIBUTE_cnfg  ootb
                        where  old.class_name     = ootb.class_name
                        and    old.attribute_name = ootb.attribute_name
                      )
    and    (class_name, attribute_name) not in 
	(       select 'CALC_ATTRIBUTE_META', 'IMPL_CLASS_NAME' from dual
      union select 'X', 'X' from dual
	)
    order by class_name
    ,        attribute_name;

  cursor c_changes_class_rel is
    select old.from_class_name
    ,      old.to_class_name
    ,      old.role_name
    from   class_relation        old
    where  nvl(context_code, 'XX') in ('EC_FRMW','EC_PROD','EC_TRAN','EC_SALE','EC_REVN','EC_ECDM','EC_DM','EC_BPM', 'XX')
    and    not exists ( select 'X'
                        from   u_class_relation_cnfg     ootb
                        where  old.from_class_name     = ootb.from_class_name
                        and    old.to_class_name       = ootb.to_class_name
                        and    old.role_name           = ootb.role_name
                      )
    order by from_class_name
    ,        to_class_name
    ,        role_name;

  cursor c_changes_class_trig is
    select old.class_name
    ,      old.triggering_event
    ,      old.trigger_type
    ,      old.sort_order
    from   CLASS_TRIGGER_ACTION        old
    where  nvl(context_code, 'XX') in ('EC_FRMW','EC_PROD','EC_TRAN','EC_SALE','EC_REVN','EC_ECDM','EC_DM','EC_BPM', 'XX')
    and    not exists ( select 'X'
                        from   u_class_trigger_actn_cnfg  ootb
                        where  old.class_name       = ootb.class_name
                        and    old.triggering_event = ootb.triggering_event
                        and    old.trigger_type     = ootb.trigger_type
                        and    old.sort_order       = ootb.sort_order
                        and    old.db_sql_syntax    = ootb.db_sql_syntax
                      )
    order by class_name
    ,        triggering_event
    ,        trigger_type
    ,        sort_order;
	
  ll_stmt long;
    
begin
  for c_change in c_changes_class loop
    begin
      dbms_output.put_line('Adjusting class [ '||c_change.class_name||' ]');
	  update class
	  set    app_space_code    = 'MO' 
	  ,      last_updated_date = last_updated_date
	  ,      last_updated_by   = last_updated_by
	  where  class_name        = c_change.class_name;
    end;
  end loop; 
  
  for c_change in c_changes_class_attr loop
    begin
      dbms_output.put_line('Adjusting class_attribute [ '||c_change.class_name||' --> '||c_change.attribute_name||' ]');
	  update class_attribute
	  set    context_code      = 'MO' 
	  ,      last_updated_date = last_updated_date
	  ,      last_updated_by   = last_updated_by
	  where  class_name        = c_change.class_name
	  and    attribute_name    = c_change.attribute_name;
    end;
  end loop; 

  for c_change in c_changes_class_rel loop
    begin
      dbms_output.put_line('Adjusting class_relation [ '||c_change.from_class_name||' --> '||c_change.to_class_name||' ] and role_name [ '||c_change.role_name||' ]');
	  update class_relation 
	  set    context_code      = 'MO' 
	  ,      last_updated_date = last_updated_date
	  ,      last_updated_by   = last_updated_by
	  where  from_class_name   = c_change.from_class_name
	  and    to_class_name     = c_change.to_class_name
	  and    role_name         = c_change.role_name;
    end;
  end loop; 

  for c_change in c_changes_class_trig loop
    begin
      dbms_output.put_line('Adjusting class_trigger_action [ '||c_change.class_name||' ] triggering_event [ '||c_change.triggering_event||' ] trigger_type [ '||c_change.trigger_type||' ] sort_order [ '||c_change.sort_order||' ]');
	  update class_trigger_action
	  set    context_code      = 'MO' 
	  ,      last_updated_date = last_updated_date
	  ,      last_updated_by   = last_updated_by
	  where  class_name        = c_change.class_name
	  and    triggering_event  = c_change.triggering_event
	  and    trigger_type      = c_change.trigger_type
	  and    sort_order        = c_change.sort_order;
    end;
  end loop; 
  
  update CLASS_METHOD 
  set    context_code             = 'MO' 
  ,      last_updated_date        = last_updated_date
  ,      last_updated_by          = last_updated_by
  where  nvl(context_code, 'XX') in ('EC_FRMW','EC_PROD','EC_TRAN','EC_SALE','EC_REVN','EC_ECDM','EC_DM','EC_BPM');
  
end;
/





