declare 
  cursor c_candidates is 
 select class_name
      , attribute_name
    from   ( select ca.class_name, ca.attribute_name
             from   class_attribute_cnfg      ca
             ,      class_attr_property_cnfg  cap
             where  cap.class_name            = ca.class_name
             and    cap.attribute_name        = ca.attribute_name
             and    nvl(ca.is_key, 'N')       = 'N'
             and    ca.app_space_cntx not in ('CVX','WST','CVX_ENH','DELETE_CANDIDATE')
             and    nvl(ecdp_classmeta_cnfg.isDisabled(ca.class_name, ca.attribute_name), 'N') = 'N'
             and    nvl(ecdp_classmeta_cnfg.isMandatory(ca.class_name, ca.attribute_name), 'N') = 'N'
             and    nvl(ecdp_classmeta_cnfg.getMaxStaticPresProperty(ca.class_name, ca.attribute_name, 'viewhidden'), 'false') = 'false'
             and exists ( select 'X'
                             from   old_class cl
                             where  cl.class_name = ca.class_name
                             and    cl.class_type = 'DATA'
                             and    not regexp_like(cl.class_name, '^CLASS', 'i')
                           )
             minus
             select ca.class_name, ca.attribute_name
             from   old_class_attribute         ca
             ,      old_class_attr_presentation cap
             where  nvl(ca.disabled_ind, 'N') = 'N'
             and    cap.class_name            = ca.class_name
             and    cap.attribute_name        = ca.attribute_name
             and    not regexp_like(nvl(cap.static_presentation_syntax, 'X'), 'viewhidden=true', 'i')
              and   ca.CONTEXT_CODE not in ('CVX','WST')
           ) sub
    order by class_name;
  
  ln_rec_cnt number;
  ll_stmt    long;
begin
  dbms_output.put_line('');
  for c_candidate in c_candidates loop
    begin
      dbms_output.put_line('-- Hide new attribute [ '||c_candidate.attribute_name||' ] added to class [ '||c_candidate.class_name||' ]');

	  select count(1) into ln_rec_cnt 
      from   CLASS_ATTR_PROPERTY_CNFG 
      where  class_name     = c_candidate.class_name 
      and    attribute_name = c_candidate.attribute_name 
      and    PROPERTY_CODE  = 'viewhidden' 
	  and    PROPERTY_TYPE  = 'STATIC_PRESENTATION';
	  
	  if ln_rec_cnt = 1 then 
        ll_stmt :=           'update CLASS_ATTR_PROPERTY_CNFG ';
        ll_stmt := ll_stmt ||'set PROPERTY_VALUE = ''true'' '; 
        ll_stmt := ll_stmt ||'where class_name = '''||c_candidate.class_name||''' '; 
        ll_stmt := ll_stmt ||'and attribute_name = '''||c_candidate.attribute_name||''' ';  
        ll_stmt := ll_stmt ||'and PROPERTY_CODE = ''viewhidden'' ';  
        ll_stmt := ll_stmt ||'and PROPERTY_TYPE = ''STATIC_PRESENTATION'' ';  
      else
        ll_stmt :=           'insert into CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) values (';
        ll_stmt := ll_stmt ||''''||c_candidate.class_name||''' '; 
        ll_stmt := ll_stmt ||', '''||c_candidate.attribute_name||''' ';  
        ll_stmt := ll_stmt ||', ''viewhidden'' ';  
        ll_stmt := ll_stmt ||', 2500 ';  
        ll_stmt := ll_stmt ||', ''/EC'' ';  
        ll_stmt := ll_stmt ||', ''STATIC_PRESENTATION'' ';  
        ll_stmt := ll_stmt ||', ''true'')';  
      end if;

      --dbms_output.put_line(ll_stmt||';');
	  execute immediate ll_stmt;

    end;
  end loop;
end;
/