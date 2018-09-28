declare 
  cursor c_changes_class is
    select old.class_name
    ,      old.db_object_type       as db_object_type_old
    ,      old.db_object_name       as db_object_name_old
    ,      old.db_object_attribute  as db_object_attribute_old
    ,      old.db_where_condition   as db_where_condition_old
    ,      ootb.db_object_type      as db_object_type_new
    ,      ootb.db_object_name      as db_object_name_new
    ,      ootb.db_object_attribute as db_object_attribute_new
    ,      ootb.db_where_condition  as db_where_condition_new
    from   old_class_db_mapping old
    ,      u_class_cnfg         ootb
    where  old.class_name     = ootb.class_name
    and    ( nvl(trim(old.db_object_type),'X')       <> nvl(trim(ootb.db_object_type),'X')
    or       nvl(trim(old.db_object_name),'X')       <> nvl(trim(ootb.db_object_name),'X')
    or       nvl(trim(old.db_object_attribute),'X')  <> nvl(trim(ootb.db_object_attribute),'X')
    or       nvl(trim(old.db_where_condition),'X')   <> nvl(trim(ootb.db_where_condition),'X')
           )
    and    old.class_name not in ( 'XXXX' 
	                             )
    order by class_name;

  cursor c_changes_attr is
    select old.class_name
    ,      old.attribute_name
    ,      old.db_mapping_type  as db_mapping_type_old
    ,      old.db_sql_syntax    as db_sql_syntax_old
    ,      nvl(attr.is_key,'N') as is_key_old
    ,      ootb.db_mapping_type as db_mapping_type_new
    ,      ootb.db_sql_syntax   as db_sql_syntax_new
    ,      nvl(ootb.is_key,'N') as is_key_new
    from   old_class_attr_db_mapping old
    ,      old_class_attribute       attr
    ,      u_class_attribute_cnfg    ootb
    where  old.class_name     = ootb.class_name
    and    old.attribute_name = ootb.attribute_name
    and    old.class_name     = attr.class_name
    and    old.attribute_name = attr.attribute_name
    and    ( trim(old.db_mapping_type)  <> trim(ootb.db_mapping_type)
    or       trim(old.db_sql_syntax)    <> trim(ootb.db_sql_syntax)
    or       trim(nvl(attr.is_key, 'N')) <> trim(nvl(ootb.is_key, 'N'))
           )
    and    old.class_name not in ( 'MANAGE_OUTGOING_MSG' 
	                             )
    order by class_name
    ,        attribute_name;
	
  cursor c_replacements is 
    with replacements as (
            select 'EQPM_RESULT\.'    old_value, 'TEST_DEVICE_RESULT.'    new_value from dual
      union select 'EQPM_RESULT_JN\.' old_value, 'TEST_DEVICE_RESULT_JN.' new_value from dual
    )
    select cadm.class_name
    ,      cadm.attribute_name
    ,      cadm.db_sql_syntax  db_sql_syntax_old
    ,      regexp_replace(cadm.db_sql_syntax, rp.old_value, rp.new_value, 1, 0, 'i') db_sql_syntax_new
    ,      rp.old_value
    ,      rp.new_value
	  from   old_class_attr_db_mapping  cadm
    ,      replacements               rp
    where  regexp_like(cadm.db_sql_syntax, rp.old_value, 'i')
    order by cadm.class_name
    ,        cadm.attribute_name;

  ll_stmt long;
    
begin
  for c_change in c_changes_class loop
    begin
      dbms_output.put_line('Adjusting class [ '||c_change.class_name||' ]');
      if nvl(trim(c_change.db_object_type_old),'X') <> nvl(trim(c_change.db_object_type_new),'X') then
         dbms_output.put_line('- Product  db_object_type = [ '||trim(c_change.db_object_type_new)||' ]');
         dbms_output.put_line('- Customer db_object_type = [ '||trim(c_change.db_object_type_old)||' ]');
         ll_stmt := 'update class_cnfg set db_object_type = '''||regexp_replace(c_change.db_object_type_old, '''', '''''', 1, 0, 'i')||''' where class_name = '''||c_change.class_name||'''';
         execute immediate ll_stmt;
         commit;
	 end if;
	  
      if nvl(trim(c_change.db_object_name_old),'X') <> nvl(trim(c_change.db_object_name_new),'X') then
         dbms_output.put_line('- Product  db_object_name = [ '||trim(c_change.db_object_name_new)||' ]');
         dbms_output.put_line('- Customer db_object_name = [ '||trim(c_change.db_object_name_old)||' ]');
         ll_stmt := 'update class_cnfg set db_object_name = '''||regexp_replace(c_change.db_object_name_old, '''', '''''', 1, 0, 'i')||''' where class_name = '''||c_change.class_name||'''';
         execute immediate ll_stmt;
         commit;
      end if;

      if nvl(trim(c_change.db_object_attribute_old),'X') <> nvl(trim(c_change.db_object_attribute_new),'X') then
         dbms_output.put_line('- Product  db_object_attribute = [ '||trim(c_change.db_object_attribute_new)||' ]');
         dbms_output.put_line('- Customer db_object_attribute = [ '||trim(c_change.db_object_attribute_old)||' ]');
         ll_stmt := 'update class_cnfg set db_object_attribute = '''||regexp_replace(c_change.db_object_attribute_old, '''', '''''', 1, 0, 'i')||''' where class_name = '''||c_change.class_name||'''';
         execute immediate ll_stmt;
         commit;
      end if;

      if nvl(trim(c_change.db_where_condition_old),'X') <> nvl(trim(c_change.db_where_condition_new),'X') then
         dbms_output.put_line('- Product  db_where_condition = [ '||trim(c_change.db_where_condition_new)||' ]');
         dbms_output.put_line('- Customer db_where_condition = [ '||trim(c_change.db_where_condition_old)||' ]');
         ll_stmt := 'update class_cnfg set db_where_condition = '''||regexp_replace(c_change.db_where_condition_old, '''', '''''', 1, 0, 'i')||''' where class_name = '''||c_change.class_name||'''';
         execute immediate ll_stmt;
         commit;
      end if;
	  
      dbms_output.put_line('');
    end;
  end loop; 

  for c_change in c_changes_attr loop
    begin
      dbms_output.put_line('Adjusting class [ '||c_change.class_name||' ] and attribute [ '||c_change.attribute_name||' ]');
      if trim(c_change.db_mapping_type_old) <> trim(c_change.db_mapping_type_new) then
         dbms_output.put_line('- Product  db_mapping_type = [ '||trim(c_change.db_mapping_type_new)||' ]');
         dbms_output.put_line('- Customer db_mapping_type = [ '||trim(c_change.db_mapping_type_old)||' ]');
         ll_stmt := 'update class_attribute_cnfg set db_mapping_type = '''||regexp_replace(c_change.db_mapping_type_old, '''', '''''', 1, 0, 'i')||''' where class_name = '''||c_change.class_name||''' and attribute_name = '''||c_change.attribute_name||'''';
         execute immediate ll_stmt;
         commit;
      end if;
      
      if trim(c_change.db_sql_syntax_old) <> trim(c_change.db_sql_syntax_new) then
         dbms_output.put_line('- Product  db_sql_syntax   = [ '||trim(c_change.db_sql_syntax_new)||' ]');
         dbms_output.put_line('- Customer db_sql_syntax   = [ '||trim(c_change.db_sql_syntax_old)||' ]');
         ll_stmt := 'update class_attribute_cnfg set db_sql_syntax = '''||regexp_replace(c_change.db_sql_syntax_old, '''', '''''', 1, 0, 'i')||''' where class_name = '''||c_change.class_name||''' and attribute_name = '''||c_change.attribute_name||'''';
         execute immediate ll_stmt;
         commit;
      end if;

      if trim(c_change.is_key_old) <> trim(c_change.is_key_new) then
         dbms_output.put_line('- Product  is_key          = [ '||trim(c_change.is_key_new)||' ]');
         dbms_output.put_line('- Customer is_key          = [ '||trim(c_change.is_key_old)||' ]');
         ll_stmt := 'update class_attribute_cnfg set is_key = '''||regexp_replace(c_change.is_key_old, '''', '''''', 1, 0, 'i')||''' where class_name = '''||c_change.class_name||''' and attribute_name = '''||c_change.attribute_name||'''';
         execute immediate ll_stmt;
         commit;
      end if;
      dbms_output.put_line('');
    end;
  end loop; 
  
  for c_replacement in c_replacements loop
    begin
      dbms_output.put_line('Adjusting class [ '||c_replacement.class_name||' ] and attribute [ '||c_replacement.attribute_name||' ]');
      dbms_output.put_line('Replacing [ '||c_replacement.old_value||' ] by [ '||c_replacement.new_value||' ]');
      ll_stmt := 'update class_attribute_cnfg set db_sql_syntax = '''||regexp_replace(c_replacement.db_sql_syntax_new, '''', '''''', 1, 0, 'i')||''' where class_name = '''||c_replacement.class_name||''' and attribute_name = '''||c_replacement.attribute_name||'''';

      execute immediate ll_stmt;
      commit;
      dbms_output.put_line('');
    end;
  end loop; 
end;
/

update class_attribute_cnfg set db_mapping_type = 'COLUMN'   , db_sql_syntax = 'BF_PROFILE'          , last_updated_date = last_updated_date, last_updated_by = last_updated_by where db_sql_syntax is null and class_name = 'REVN_PROD_STREAM' and attribute_name = 'BF_PROFILE';
update class_attribute_cnfg set db_mapping_type = 'ATTRIBUTE', db_sql_syntax = 'CALC_APPROVAL_CHECK' , last_updated_date = last_updated_date, last_updated_by = last_updated_by where db_sql_syntax is null and class_name = 'REVN_PROD_STREAM' and attribute_name = 'CALC_APPROVAL_CHECK';
update class_attribute_cnfg set db_mapping_type = 'COLUMN'   , db_sql_syntax = 'OBJECT_CODE'         , last_updated_date = last_updated_date, last_updated_by = last_updated_by where db_sql_syntax is null and class_name = 'REVN_PROD_STREAM' and attribute_name = 'CODE';
update class_attribute_cnfg set db_mapping_type = 'ATTRIBUTE', db_sql_syntax = 'CONTRACT_GROUP_CODE' , last_updated_date = last_updated_date, last_updated_by = last_updated_by where db_sql_syntax is null and class_name = 'REVN_PROD_STREAM' and attribute_name = 'CONTRACT_GROUP_CODE';
update class_attribute_cnfg set db_mapping_type = 'ATTRIBUTE', db_sql_syntax = 'CONTRACT_RESPONSIBLE', last_updated_date = last_updated_date, last_updated_by = last_updated_by where db_sql_syntax is null and class_name = 'REVN_PROD_STREAM' and attribute_name = 'CONTRACT_RESPONSIBLE';
update class_attribute_cnfg set db_mapping_type = 'ATTRIBUTE', db_sql_syntax = 'DAYTIME'             , last_updated_date = last_updated_date, last_updated_by = last_updated_by where db_sql_syntax is null and class_name = 'REVN_PROD_STREAM' and attribute_name = 'DAYTIME';
update class_attribute_cnfg set db_mapping_type = 'ATTRIBUTE', db_sql_syntax = 'END_DATE'            , last_updated_date = last_updated_date, last_updated_by = last_updated_by where db_sql_syntax is null and class_name = 'REVN_PROD_STREAM' and attribute_name = 'END_DATE';
update class_attribute_cnfg set db_mapping_type = 'ATTRIBUTE', db_sql_syntax = 'FINANCIAL_CODE'      , last_updated_date = last_updated_date, last_updated_by = last_updated_by where db_sql_syntax is null and class_name = 'REVN_PROD_STREAM' and attribute_name = 'FINANCIAL_CODE';
update class_attribute_cnfg set db_mapping_type = 'ATTRIBUTE', db_sql_syntax = 'NAME'                , last_updated_date = last_updated_date, last_updated_by = last_updated_by where db_sql_syntax is null and class_name = 'REVN_PROD_STREAM' and attribute_name = 'NAME';
update class_attribute_cnfg set db_mapping_type = 'COLUMN'   , db_sql_syntax = 'END_DATE'            , last_updated_date = last_updated_date, last_updated_by = last_updated_by where db_sql_syntax is null and class_name = 'REVN_PROD_STREAM' and attribute_name = 'OBJECT_END_DATE';
update class_attribute_cnfg set db_mapping_type = 'COLUMN'   , db_sql_syntax = 'OBJECT_ID'           , last_updated_date = last_updated_date, last_updated_by = last_updated_by where db_sql_syntax is null and class_name = 'REVN_PROD_STREAM' and attribute_name = 'OBJECT_ID';
update class_attribute_cnfg set db_mapping_type = 'COLUMN'   , db_sql_syntax = 'START_DATE'          , last_updated_date = last_updated_date, last_updated_by = last_updated_by where db_sql_syntax is null and class_name = 'REVN_PROD_STREAM' and attribute_name = 'OBJECT_START_DATE';
update class_attribute_cnfg set db_mapping_type = 'COLUMN'   , db_sql_syntax = 'REVN_IND'            , last_updated_date = last_updated_date, last_updated_by = last_updated_by where db_sql_syntax is null and class_name = 'REVN_PROD_STREAM' and attribute_name = 'REVN_IND';
update class_attribute_cnfg set db_mapping_type = 'ATTRIBUTE', db_sql_syntax = 'SORT_ORDER'          , last_updated_date = last_updated_date, last_updated_by = last_updated_by where db_sql_syntax is null and class_name = 'REVN_PROD_STREAM' and attribute_name = 'SORT_ORDER';
update class_attribute_cnfg set db_mapping_type = 'COLUMN'   , db_sql_syntax = 'TEMPLATE_CODE'       , last_updated_date = last_updated_date, last_updated_by = last_updated_by where db_sql_syntax is null and class_name = 'REVN_PROD_STREAM' and attribute_name = 'TEMPLATE_CODE';

declare 
  cursor c_replacements is 
    with max_properties as
    ( select cap.*
      from   class_attribute_cnfg     ca
      ,      class_attr_property_cnfg cap
      where  ca.class_name             = cap.class_name
      and    ca.attribute_name         = cap.attribute_name
      and    cap.property_code        in ( 'UOM_CODE', 'DISABLED_IND' )
      and    cap.owner_cntx            = ( select max(s.owner_cntx) 
                                           from   class_attr_property_cnfg s
                                           where  s.class_name        = cap.class_name
                                           and    s.attribute_name    = cap.attribute_name
                                           and    s.property_code     = cap.property_code
                                           and    s.presentation_cntx = cap.presentation_cntx
                                           and    s.property_type     = cap.property_type
                                         )
      and    ca.data_type         not in ('NUMBER', 'INTEGER')
    )
    select distinct 
	       ca.class_name
    ,      ca.attribute_name
    ,      ca.data_type old_value
    ,      'NUMBER' new_value
    from   max_properties           uo
    ,      ctrl_uom_setup           u
    ,      class_attribute_cnfg     ca
    left outer join 
           max_properties           di
    on     ca.class_name               = di.class_name
    and    ca.attribute_name           = di.attribute_name
    and    di.property_code            = 'DISABLED_IND'
    where  nvl(di.property_value, 'N') = 'N' 
    and    ca.class_name             = uo.class_name
    and    ca.attribute_name         = uo.attribute_name
    and    u.measurement_type        = uo.property_value
    and    u.db_unit_ind            <> 'Y'
    and    uo.property_code          = 'UOM_CODE'
    order by ca.class_name
    ,      ca.attribute_name;

  ll_stmt long;
    
begin
  for c_replacement in c_replacements loop
    begin
      dbms_output.put_line('Adjusting class [ '||c_replacement.class_name||' ] and attribute [ '||c_replacement.attribute_name||' ]');
      dbms_output.put_line('Replacing data type [ '||c_replacement.old_value||' ] by [ '||c_replacement.new_value||' ]');
      ll_stmt := 'update class_attribute_cnfg set data_type = '''||c_replacement.new_value||''' where class_name = '''||c_replacement.class_name||''' and attribute_name = '''||c_replacement.attribute_name||'''';

      execute immediate ll_stmt;
      commit;
      dbms_output.put_line('');
    end;
  end loop; 
end;
/


