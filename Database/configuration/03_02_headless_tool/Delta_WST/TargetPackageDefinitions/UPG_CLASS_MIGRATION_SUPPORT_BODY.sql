CREATE OR REPLACE PACKAGE BODY UPG_Class_Migration_Support IS
/**************************************************************
** Package:    upg_Class_Migration_Support
**
** $Revision: 1.39 $
**
** Filename:   upg_Class_Migration_Support_body.sql
**
** Part of :   EC Kernel
**
** Purpose: Utility functions used during copy from CLASS_xxx to CLASS_xxx_CNFG tables
**          especially for normalizing presentation properties and verify copy against
**          old table structure
**
** General Logic:
**
** Document References:
**
**
** Created:     25.11.2016  Arild Vervik, EC
**
**************************************************************/

Function isValidPropertyCode(p_property_table varchar2,
                             p_property_type varchar2,
                             p_code varchar2) return varchar2
is
  cursor c_class_property_codes is
  select * from class_property_codes
  where property_table_name = p_property_table
  and   property_type = p_property_type
  and   property_code = p_code ;

  lv2_return varchar2(1) := 'N';

begin

  For curPropetycode in c_class_property_codes LOOP
    lv2_return := 'Y';
  end loop;

  return  lv2_return;
end;



PROCEDURE  MigrateClassAttrPresentation IS

  cursor c_class_attr_presentation is
  select cap.* from class_attr_presentation cap
  join class_attribute_cnfg ca on ( cap.class_name = ca.class_name and cap.attribute_name = ca.attribute_name)
   ;

  lv2_sql     varchar2(4000);
  lv2_sql2    varchar2(4000);
  lv2_static  varchar2(4000);
  lv2_temp    varchar2(4000);
  lv2_code    varchar2(1000);
  lv2_value   varchar2(1500);
  lv2_value2  varchar2(1500);
  i           number;

begin

  delete from t_temptext where id in ('PRES_SYNTAX_ERROR','PRES_SYNTAX_WARNING');
  commit;

  for curRow in c_class_attr_presentation LOOP

     -- Need to deal with PRESENTATION_SYNTAX,  SORT_ORDER and  STATIC_PRESENTATION_SYNTAX
     -- FOR now treat the dynamic PRESENTATION_SYNTAX as one entry, in the future we might want to split this, only add this if it has a value

     lv2_static := curRow.static_presentation_syntax;

     i := instr(lv2_static,';');

     while ( i > 0 ) Loop

        lv2_temp := substr(lv2_static,0,i-1);
        lv2_static := substr(lv2_static,i+1);

        i :=  instr(lv2_temp,'=');

        if ( i > 0)  then

            lv2_code := substr(lv2_temp,0,i-1);
            lv2_value := substr(lv2_temp,i+1);

            lv2_value := replace(lv2_value,'''','''''');

            if (length(lv2_code) > 0 ) and ( length(lv2_value) > 0 )  then


              if isValidPropertyCode('CLASS_ATTR_PROPERTY_CNFG','STATIC_PRESENTATION',lv2_code) = 'Y' then


                 lv2_sql2 := 'select property_value from CLASS_ATTR_PROPERTY_CNFG where class_name = '''||curRow.class_name;
                 lv2_sql2 := lv2_sql2 || ''' and attribute_name = '''|| curRow.attribute_name;
                 lv2_sql2 := lv2_sql2 || ''' and property_code = '''|| lv2_code ||'''';
                 lv2_sql2 := lv2_sql2 || ' and owner_cntx = 0';

                 lv2_value2 := ecdp_dynsql.execute_singlerow_varchar2(lv2_sql2 );

                  if lv2_value2 is null then

                      begin

                         lv2_sql := 'Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name,  property_code, owner_cntx,presentation_cntx,property_type,  property_value, created_by, created_date, record_status) ';
                         lv2_sql := lv2_sql || ' values ('''||curRow.class_name||''','''|| curRow.attribute_name|| ''','''|| lv2_code||''',0,''/EC'',''STATIC_PRESENTATION'','''|| lv2_value||''','''||currow.created_by||''','''|| currow.created_date||''','''||currow.record_status||'''  )';

                         ecdp_dynsql.execute_statement(lv2_sql);

                      EXCEPTION

                        WHEN OTHERS THEN

                        ecdp_dynsql.WriteTempText('PRES_SYNTAX_ERROR',lv2_sql);

                     end;

                  elsif (lv2_value2 <> lv2_value ) then

                     lv2_sql := 'Duplicate property value for Class = '||curRow.class_name||' attribute = '|| curRow.attribute_name|| ' property = '|| lv2_code||' stored value = '|| lv2_value2||' ignored value = '|| lv2_value;

                    ecdp_dynsql.WriteTempText('PRES_SYNTAX_WARNING',lv2_sql );

                 end if;

             else  -- not a valid property code

               lv2_sql := 'Invalid property code for Class = '||curRow.class_name||' attribute = '|| curRow.attribute_name|| ' code = '''|| lv2_code||'''';
               ecdp_dynsql.WriteTempText('PRES_SYNTAX_ERROR',lv2_sql );


             end if;

         else

             lv2_sql := 'Invalid property definition for Class = '||curRow.class_name||' attribute = '|| curRow.attribute_name|| ' string = '''|| lv2_temp||'''';


             ecdp_dynsql.WriteTempText('PRES_SYNTAX_ERROR',lv2_sql );

          end if;

       elsif ( lv2_temp > '') then

             lv2_sql := 'Invalid property definition for Class = '||curRow.class_name||' attribute = '|| curRow.attribute_name|| ' string = '''|| lv2_temp||'''';

             ecdp_dynsql.WriteTempText('PRES_SYNTAX_ERROR',lv2_sql );

       end if;

       i := instr(lv2_static,';');


     end loop; --while ; in string


     if (length(lv2_static) > 0 ) Then

        i :=  instr(lv2_static,'=');

        if ( i > 0)  then

          lv2_code := substr(lv2_static,0,i-1);
          lv2_value := substr(lv2_static,i+1);

          if (length(lv2_code) > 0 ) and ( length(lv2_value) > 0 )  then


            if isValidPropertyCode('CLASS_ATTR_PROPERTY_CNFG','STATIC_PRESENTATION',lv2_code) = 'Y' then

                lv2_value := replace(lv2_value,'''','''''');


                   lv2_sql2 := 'select property_value from CLASS_ATTR_PROPERTY_CNFG where class_name = '''||curRow.class_name;
                   lv2_sql2 := lv2_sql2 || ''' and attribute_name = '''|| curRow.attribute_name;
                   lv2_sql2 := lv2_sql2 || ''' and property_code = '''|| lv2_code ||'''';
                   lv2_sql2 := lv2_sql2 || ' and owner_cntx = 0';

                   lv2_value2 := ecdp_dynsql.execute_singlerow_varchar2(lv2_sql2 );

                    if lv2_value2 is null then

                        begin

                             lv2_sql := 'Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name,  property_code, owner_cntx,presentation_cntx,property_type,  property_value, created_by, created_date, record_status) ';
                             lv2_sql := lv2_sql || ' values ('''||curRow.class_name||''','''|| curRow.attribute_name|| ''','''|| lv2_code||''',0,''/EC'',''STATIC_PRESENTATION'','''|| lv2_value||''','''||currow.created_by||''','''|| currow.created_date||''','''||currow.record_status||'''  )';

                           ecdp_dynsql.execute_statement(lv2_sql);

                        EXCEPTION

                          WHEN OTHERS THEN

                          ecdp_dynsql.WriteTempText('PRES_SYNTAX_ERROR',lv2_sql);

                       end;

                   elsif (lv2_value2 <> lv2_value ) then

                     lv2_sql := 'Duplicate property value for Class = '||curRow.class_name||' attribute = '|| curRow.attribute_name|| ' property = '|| lv2_code||' stored value = '|| lv2_value2||' ignored value = '|| lv2_value;

                     ecdp_dynsql.WriteTempText('PRES_SYNTAX_WARNING',lv2_sql );

                  end if;

             else  -- not a valid property code

               lv2_sql := '2 Invalid property code for Class = '||curRow.class_name||' attribute = '|| curRow.attribute_name|| ' code = '''|| lv2_code||'''';
               ecdp_dynsql.WriteTempText('PRES_SYNTAX_ERROR',lv2_sql );


             end if;


       else

           lv2_sql := 'Invalid property definition for Class = '||curRow.class_name||' attribute = '|| curRow.attribute_name|| ' string = '''|| lv2_static ||'''';


           ecdp_dynsql.WriteTempText('PRES_SYNTAX_ERROR',lv2_sql );

        end if;

     elsif ( lv2_static > '') then

           lv2_sql := 'Invalid property definition for Class = '||curRow.class_name||' attribute = '|| curRow.attribute_name|| ' string = '''|| lv2_static ||'''';

           ecdp_dynsql.WriteTempText('PRES_SYNTAX_ERROR',lv2_sql );

     end if;

  end if;

  END LOOP;

  commit;

end;



PROCEDURE MigrateClassRelPresentation IS
  --CLASS_REL_PRES_CNFG

  cursor c_class_rel_presentation is
  select crp.* from class_rel_presentation crp
  join class_relation_cnfg cr on ( crp.from_class_name = cr.from_class_name
                                   and crp.to_class_name = cr.to_class_name
                                   and crp.role_name = cr.role_name
  ) ;

  lv2_sql     varchar2(4000);
  lv2_sql2    varchar2(4000);
  lv2_static  varchar2(4000);
  lv2_temp    varchar2(4000);
  lv2_code    varchar2(1000);
  lv2_value   varchar2(1500);
  lv2_value2  varchar2(1500);
  i           number;

begin

  for curRow in c_class_rel_presentation LOOP

     -- Need to deal with PRESENTATION_SYNTAX and STATIC_PRESENTATION_SYNTAX
     -- FOR now treat the dynamic PRESENTATION_SYNTAX as one entry, in the future we might want to split this, only add this if it has a value

     lv2_static := curRow.static_presentation_syntax;

     i := instr(lv2_static,';');

     while ( i > 0 ) Loop

        lv2_temp := substr(lv2_static,0,i-1);
        lv2_static := substr(lv2_static,i+1);

        i :=  instr(lv2_temp,'=');

          if ( i > 0)  then

            lv2_code := substr(lv2_temp,0,i-1);
            lv2_value := substr(lv2_temp,i+1);

            if isValidPropertyCode('CLASS_ATTR_PROPERTY_CNFG','STATIC_PRESENTATION',lv2_code) = 'Y' then


                lv2_value := replace(lv2_value,'''','''''');

                if (length(lv2_code) > 0 ) and ( length(lv2_value) > 0 )  then

                   lv2_sql2 := 'select property_value from CLASS_REL_PROPERTY_CNFG where from_class_name = '''||curRow.from_class_name;
                   lv2_sql2 := lv2_sql2 || ''' and to_class_name = '''|| curRow.to_class_name;
                   lv2_sql2 := lv2_sql2 || ''' and role_name = '''|| curRow.role_name;
                   lv2_sql2 := lv2_sql2 || ''' and property_code = '''|| lv2_code ||'''';
                   lv2_sql2 := lv2_sql2 || ' and owner_cntx = 0';

                   lv2_value2 := ecdp_dynsql.execute_singlerow_varchar2(lv2_sql2 );

                    if lv2_value2 is null then

                        begin

                           lv2_sql := 'Insert into CLASS_REL_PROPERTY_CNFG(from_class_name, to_class_name, role_name, property_code, owner_cntx, presentation_cntx, property_type, property_value, created_by, created_date, record_status) ';
                           lv2_sql := lv2_sql || ' values ('''||curRow.from_class_name||''','''|| curRow.to_class_name||''','''|| curRow.role_name|| ''','''|| lv2_code||''',0,''/EC'',''STATIC_PRESENTATION'','''|| lv2_value||''','''||currow.created_by||''','''|| currow.created_date||''','''||currow.record_status||'''  )';
                           ecdp_dynsql.execute_statement(lv2_sql);

                        EXCEPTION

                          WHEN OTHERS THEN

                          ecdp_dynsql.WriteTempText('PRES_SYNTAX_ERROR',lv2_sql);

                       end;

                elsif (lv2_value2 <> lv2_value ) then

                     lv2_sql := 'Duplicate property value for from Class = '||curRow.from_class_name||' to Class = '||curRow.to_class_name||' role_name = '|| curRow.role_name|| ' property = '|| lv2_code||' stored value = '|| lv2_value2||' ignored value = '|| lv2_value;

                    ecdp_dynsql.WriteTempText('PRES_SYNTAX_WARNING',lv2_sql );

                end if;

             else  -- not a valid property code

               lv2_sql := 'Invalid property code for from Class = '||curRow.from_class_name||' to Class = '||curRow.to_class_name||' role_name = '|| curRow.role_name|| ' code = '''|| lv2_code||'''';
               ecdp_dynsql.WriteTempText('PRES_SYNTAX_ERROR',lv2_sql );


             end if;



         else

             lv2_sql := 'Invalid property definition for from Class = '||curRow.from_class_name||' to Class = '||curRow.to_class_name||' role_name = '|| curRow.role_name|| ' string = '''|| lv2_temp||'''';


             ecdp_dynsql.WriteTempText('PRES_SYNTAX_ERROR',lv2_sql );

          end if;

       elsif ( lv2_temp > '') then

             lv2_sql := 'Invalid property definition for for from Class = '||curRow.from_class_name||' to Class = '||curRow.to_class_name||' role_name = '|| curRow.role_name|| ' string = '''|| lv2_temp||'''';
             ecdp_dynsql.WriteTempText('PRES_SYNTAX_ERROR',lv2_sql );

       end if;

       i := instr(lv2_static,';');


     end loop; --while ; in string


     if (length(lv2_static) > 0 ) Then

        i :=  instr(lv2_static,'=');

        if ( i > 0)  then

          lv2_code := substr(lv2_static,0,i-1);
          lv2_value := substr(lv2_static,i+1);

          if isValidPropertyCode('CLASS_ATTR_PROPERTY_CNFG','STATIC_PRESENTATION',lv2_code) = 'Y' then

              lv2_value := replace(lv2_value,'''','''''');

              if (length(lv2_code) > 0 ) and ( length(lv2_value) > 0 )  then

                   lv2_sql2 := 'select property_value from CLASS_REL_PROPERTY_CNFG where from_class_name = '''||curRow.from_class_name;
                   lv2_sql2 := lv2_sql2 || ''' and to_class_name = '''|| curRow.to_class_name;
                   lv2_sql2 := lv2_sql2 || ''' and role_name = '''|| curRow.role_name;
                   lv2_sql2 := lv2_sql2 || ''' and property_code = '''|| lv2_code ||'''';
                   lv2_sql2 := lv2_sql2 || ' and owner_cntx = 0';

                 lv2_value2 := ecdp_dynsql.execute_singlerow_varchar2(lv2_sql2 );

                  if lv2_value2 is null then

                      begin

                         lv2_sql := 'Insert into CLASS_REL_PROPERTY_CNFG(from_class_name, to_class_name, role_name, property_code, owner_cntx, presentation_cntx, property_type, property_value, created_by, created_date, record_status) ';
                         lv2_sql := lv2_sql || ' values ('''||curRow.from_class_name||''','''|| curRow.to_class_name||''','''|| curRow.role_name|| ''','''|| lv2_code||''',0,''/EC'',''STATIC_PRESENTATION'','''|| lv2_value||''','''||currow.created_by||''','''|| currow.created_date||''','''||currow.record_status||'''  )';

                         ecdp_dynsql.execute_statement(lv2_sql);

                      EXCEPTION

                        WHEN OTHERS THEN

                        ecdp_dynsql.WriteTempText('PRES_SYNTAX_ERROR',lv2_sql);

                     end;

                elsif (lv2_value2 <> lv2_value ) then

                    lv2_sql := 'Duplicate property value for from Class = '||curRow.from_class_name||' to Class = '||curRow.to_class_name||' role_name = '|| curRow.role_name|| ' property = '|| lv2_code||' stored value = '|| lv2_value2||' ignored value = '|| lv2_value;

                    ecdp_dynsql.WriteTempText('PRES_SYNTAX_WARNING',lv2_sql );

                end if;

             else  -- not a valid property code

               lv2_sql := 'Invalid property code for from Class = '||curRow.from_class_name||' to Class = '||curRow.to_class_name||' role_name = '|| curRow.role_name|| ' code = '''|| lv2_code||'''';
               ecdp_dynsql.WriteTempText('PRES_SYNTAX_ERROR',lv2_sql );


             end if;


       else

             lv2_sql := 'Invalid property definition for for from Class = '||curRow.from_class_name||' to Class = '||curRow.to_class_name||' role_name = '|| curRow.role_name|| ' string = '''|| lv2_temp||'''';


           ecdp_dynsql.WriteTempText('PRES_SYNTAX_ERROR',lv2_sql );

        end if;

     elsif ( lv2_static > '') then

           lv2_sql := 'Invalid property definition for for from Class = '||curRow.from_class_name||' to Class = '||curRow.to_class_name||' role_name = '|| curRow.role_name|| ' string = '''|| lv2_temp||'''';

           ecdp_dynsql.WriteTempText('PRES_SYNTAX_ERROR',lv2_sql );

     end if;

  end if;

  END LOOP;

  commit;



END;



Procedure MigrateClassProperties
is

CURSOR c_property_columns is
select column_name, replace(c.column_name,'FORCE_CLS_VIEW_WRITE_IND','CALC_ENGINE_TABLE_WRITE_IND') as property_code , p.property_type, DECODE(p.property_type, 'VIEWLAYER', '/', '/EC') as presentation_cntx
from cols c
join class_property_codes p on (replace(c.column_name,'FORCE_CLS_VIEW_WRITE_IND','CALC_ENGINE_TABLE_WRITE_IND') = p.property_code)
where c.table_name = 'CLASS'
and  p.property_table_name = 'CLASS_PROPERTY_CNFG'
and column_name not in (  'RECORD_STATUS', 'CREATED_BY', 'CREATED_DATE', 'LAST_UPDATED_BY', 'LAST_UPDATED_DATE', 'REV_NO',  'REV_TEXT', 'APPROVAL_STATE', 'APPROVAL_BY', 'APPROVAL_DATE', 'REC_ID' )
and column_name not in ('CLASS_NAME','SUPER_CLASS','CLASS_VERSION','CLASS_TYPE','APP_SPACE_CODE','TIME_SCOPE_CODE','OWNER_CLASS_NAME','CALC_MAPPING_SYNTAX') ;




lv2_sql varchar2(32000);
BEGIN

  Insert into CLASS_CNFG(class_name, class_type, app_space_cntx, time_scope_code, owner_class_name, record_status, created_by,
                         created_date,last_updated_by, last_updated_date, rev_no, rev_text, approval_state,
                         approval_by, approval_date, rec_id)
  select class_name, class_type, app_space_code, time_scope_code, owner_class_name, record_status, created_by, created_date,
         last_updated_by, last_updated_date, rev_no, rev_text, approval_state,
         approval_by , approval_date, rec_id
  from class c
  where not exists ( select 1 from class_cnfg cc where c.class_name = cc.class_name );


  update CLASS_CNFG  c set (db_object_type, db_object_owner, db_object_name, db_where_condition, db_object_attribute) =
  ( select db_object_type, db_object_owner, db_object_name, db_where_condition, db_object_attribute
  from class_db_mapping m where c.class_name = m.class_name)
  where exists (select 1 from class_db_mapping m where c.class_name = m.class_name);


  FOR curProperty in c_property_columns LOOP

    lv2_sql := 'Insert into CLASS_PROPERTY_CNFG(class_name, property_code, owner_cntx, presentation_cntx, property_type,';
    lv2_sql := lv2_sql || ' property_value , record_status, created_by, created_date, last_updated_by, last_updated_date,';
    lv2_sql := lv2_sql || ' rev_no, rev_text, approval_state, approval_by,approval_date) ';
    lv2_sql := lv2_sql || 'select c.class_name, '''||curProperty.property_code||''',0, ''' || curProperty.presentation_cntx || ''',''' || curProperty.property_type ||''','||curProperty.column_name;

    lv2_sql := lv2_sql || ', c.record_status, c.created_by, c.created_date, c.last_updated_by, c.last_updated_date, c.rev_no,c.rev_text,';
    lv2_sql := lv2_sql || ' c.approval_state, c.approval_by, c.approval_date from class c ';
    lv2_sql := lv2_sql || ' join class_cnfg c2 on (c.class_name = c2.class_name)';
    lv2_sql := lv2_sql || ' where '||curProperty.column_name||' is not null';


    ecdp_dynsql.execute_statement(lv2_sql);


  END LOOP;

  commit;

END MigrateClassProperties;



Procedure MigrateClassAttribute
is

CURSOR c_property_columns1 is
select column_name, column_name as property_code , p.property_type, DECODE(p.property_type, 'VIEWLAYER', '/', '/EC') as presentation_cntx
from cols c
join class_property_codes p on (c.column_name = p.property_code and p.property_table_name = 'CLASS_ATTR_PROPERTY_CNFG')
where table_name = 'CLASS_ATTRIBUTE'
and column_name not in (  'RECORD_STATUS', 'CREATED_BY', 'CREATED_DATE', 'LAST_UPDATED_BY', 'LAST_UPDATED_DATE', 'REV_NO',  'REV_TEXT', 'APPROVAL_STATE', 'APPROVAL_BY', 'APPROVAL_DATE', 'REC_ID' )
and column_name not in ('CLASS_NAME','ATTRIBUTE_NAME','CONTEXT_CODE', 'IS_KEY','DATA_TYPE','CALC_MAPPING_SYNTAX','DISABLED_CALC_IND') ;

CURSOR c_property_columns2 is
select column_name, replace(column_name,'SORT_ORDER','DB_SORT_ORDER') as property_code , p.property_type, DECODE(p.property_type, 'VIEWLAYER', '/', '/EC') as presentation_cntx
from cols c
join class_property_codes p on (replace(column_name,'SORT_ORDER','DB_SORT_ORDER') = p.property_code and p.property_table_name = 'CLASS_ATTR_PROPERTY_CNFG')
where table_name = 'CLASS_ATTR_DB_MAPPING'
and column_name not in (  'RECORD_STATUS', 'CREATED_BY', 'CREATED_DATE', 'LAST_UPDATED_BY', 'LAST_UPDATED_DATE', 'REV_NO',  'REV_TEXT', 'APPROVAL_STATE', 'APPROVAL_BY', 'APPROVAL_DATE', 'REC_ID' )
and column_name not in ('CLASS_NAME','ATTRIBUTE_NAME','DB_MAPPING_TYPE','DB_SQL_SYNTAX') ;


CURSOR c_property_columns3 is
select column_name, replace(replace(column_name,'SORT_ORDER','SCREEN_SORT_ORDER'),'PRESENTATION_SYNTAX','PresentationSyntax') as property_code , nvl(p.property_type,'DYNAMIC_PRESENTATION') property_type, DECODE(p.property_type, 'VIEWLAYER', '/', '/EC') as presentation_cntx
from cols c
left join class_property_codes p on (replace(replace(column_name,'SORT_ORDER','SCREEN_SORT_ORDER'),'PRESENTATION_SYNTAX','PresentationSyntax') = p.property_code and p.property_table_name = 'CLASS_ATTR_PROPERTY_CNFG')
where table_name = 'CLASS_ATTR_PRESENTATION'
and column_name not in (  'RECORD_STATUS', 'CREATED_BY', 'CREATED_DATE', 'LAST_UPDATED_BY', 'LAST_UPDATED_DATE', 'REV_NO',  'REV_TEXT', 'APPROVAL_STATE', 'APPROVAL_BY', 'APPROVAL_DATE', 'REC_ID' )
and column_name not in ('CLASS_NAME','ATTRIBUTE_NAME','STATIC_PRESENTATION_SYNTAX') ;


  lv2_sql varchar2(32000);

BEGIN

  Insert into CLASS_ATTRIBUTE_CNFG(class_name, attribute_name,  app_space_cntx, is_key, data_type,  record_status, created_by,
                         created_date,last_updated_by, last_updated_date, rev_no, rev_text, approval_state,
                         approval_by, approval_date, rec_id)
  select class_name, attribute_name,
         CASE WHEN context_code IS NULL THEN (SELECT app_space_code FROM class WHERE class_name=ca.class_name) ELSE context_code END AS app_space_cntx,
         is_key, data_type, record_status, created_by, created_date,
         last_updated_by, last_updated_date, rev_no, rev_text, approval_state,
         approval_by , approval_date, rec_id
  from class_attribute ca
  where not exists ( select 1 from class_attribute_cnfg cac where ca.class_name = cac.class_name and ca.attribute_name = cac.attribute_name)
   and exists ( select 1 from class_cnfg cc where ca.class_name = cc.class_name);


  update CLASS_ATTRIBUTE_CNFG  c set (db_mapping_type, db_sql_syntax) =
  ( select db_mapping_type, db_sql_syntax
  from class_attr_db_mapping m where c.class_name = m.class_name and c.attribute_name = m.attribute_name);

  update class_attribute_cnfg cac
  set    cac.app_space_cntx = (select app_space_code from class where class_name=cac.class_name)
  where  cac.app_space_cntx is null;


  FOR curProperty in c_property_columns1 LOOP

    lv2_sql := 'Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type,';
    lv2_sql := lv2_sql || ' property_value , record_status, created_by, created_date, last_updated_by, last_updated_date,';
    lv2_sql := lv2_sql || ' rev_no, rev_text, approval_state, approval_by,approval_date) ';
    lv2_sql := lv2_sql || 'select ca.class_name, ca.attribute_name, '''||curProperty.property_code||''',0,''' || curProperty.presentation_cntx || ''','''||curProperty.property_type||''','||curProperty.column_name;
    lv2_sql := lv2_sql || ', ca.record_status, ca.created_by, ca.created_date, ca.last_updated_by, ca.last_updated_date, ca.rev_no,ca.rev_text,';
    lv2_sql := lv2_sql || ' ca.approval_state, ca.approval_by, ca.approval_date from class_attribute ca ';
    lv2_sql := lv2_sql || ' join class_attribute_cnfg c2 on (ca.class_name = c2.class_name and ca.attribute_name = c2.attribute_name)';
    lv2_sql := lv2_sql || ' where trim('||curProperty.column_name||') is not null';


    ecdp_dynsql.execute_statement(lv2_sql);

  END LOOP;

  FOR curProperty2 in c_property_columns2 LOOP

    lv2_sql := 'Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type,';
    lv2_sql := lv2_sql || ' property_value , record_status, created_by, created_date, last_updated_by, last_updated_date,';
    lv2_sql := lv2_sql || ' rev_no, rev_text, approval_state, approval_by,approval_date) ';
    lv2_sql := lv2_sql || 'select ca.class_name, ca.attribute_name, '''||curProperty2.property_code||''',0,''' || curProperty2.presentation_cntx || ''','''||curProperty2.property_type||''',db.'||curProperty2.column_name;
    lv2_sql := lv2_sql || ', db.record_status, db.created_by, db.created_date, db.last_updated_by, db.last_updated_date, db.rev_no,db.rev_text,';
    lv2_sql := lv2_sql || ' db.approval_state, db.approval_by, db.approval_date from class_attribute ca ';
    lv2_sql := lv2_sql || ' join  CLASS_ATTR_DB_MAPPING db on (ca.class_name = db.class_name and ca.attribute_name = db.attribute_name) ';
    lv2_sql := lv2_sql || ' join class_attribute_cnfg c2 on (ca.class_name = c2.class_name and ca.attribute_name = c2.attribute_name)';
    lv2_sql := lv2_sql || ' where trim(db.'||curProperty2.column_name||') is not null';

    ecdp_dynsql.execute_statement(lv2_sql);

  END LOOP;

  FOR curProperty3 in c_property_columns3 LOOP

    lv2_sql := 'Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type,';
    lv2_sql := lv2_sql || ' property_value , record_status, created_by, created_date, last_updated_by, last_updated_date,';
    lv2_sql := lv2_sql || ' rev_no, rev_text, approval_state, approval_by,approval_date) ';
    lv2_sql := lv2_sql || 'select p.class_name, p.attribute_name, '''||curProperty3.property_code||''',0,''' || curProperty3.presentation_cntx || ''','''||curProperty3.property_type||''',p.'||curProperty3.column_name;
    lv2_sql := lv2_sql || ', p.record_status, p.created_by, p.created_date, p.last_updated_by, p.last_updated_date, p.rev_no, p.rev_text,';
    lv2_sql := lv2_sql || ' p.approval_state, p.approval_by, p.approval_date from CLASS_ATTR_PRESENTATION p';
    lv2_sql := lv2_sql || ' join CLASS_ATTRIBUTE ca on (ca.class_name = p.class_name and ca.attribute_name = p.attribute_name) ';
    lv2_sql := lv2_sql || ' join class_attribute_cnfg c2 on (ca.class_name = c2.class_name and ca.attribute_name = c2.attribute_name)';
    lv2_sql := lv2_sql || ' where trim(p.'||curProperty3.column_name||') is not null';

--    ecdp_dynsql.WriteTempText('DEBUG',lv2_sql );


    ecdp_dynsql.execute_statement(lv2_sql);

  END LOOP;

  MigrateClassAttrPresentation;

  Commit;


end;


Procedure MigrateClassRelation
is

CURSOR c_property_columns1 is
select column_name, column_name as property_code , p.property_type, DECODE(p.property_type, 'VIEWLAYER', '/', '/EC') as presentation_cntx
from cols c
left join class_property_codes p on (column_name = p.property_code and p.property_table_name = 'CLASS_REL_PROPERTY_CNFG')
where table_name = 'CLASS_RELATION'
and column_name not in (  'RECORD_STATUS', 'CREATED_BY', 'CREATED_DATE', 'LAST_UPDATED_BY', 'LAST_UPDATED_DATE', 'REV_NO',  'REV_TEXT', 'APPROVAL_STATE', 'APPROVAL_BY', 'APPROVAL_DATE', 'REC_ID' )
and column_name not in ('FROM_CLASS_NAME','TO_CLASS_NAME','ROLE_NAME','CONTEXT_CODE','IS_KEY','IS_BIDIRECTIONAL','GROUP_TYPE','MULTIPLICITY','CALC_MAPPING_SYNTAX') ;

CURSOR c_property_columns2 is
select column_name, replace(column_name,'SORT_ORDER','DB_SORT_ORDER') as property_code , p.property_type, DECODE(p.property_type, 'VIEWLAYER', '/', '/EC') as presentation_cntx
from cols c
left join class_property_codes p on (replace(column_name,'SORT_ORDER','DB_SORT_ORDER') = p.property_code and p.property_table_name = 'CLASS_REL_PROPERTY_CNFG')
where table_name = 'CLASS_REL_DB_MAPPING'
and column_name not in (  'RECORD_STATUS', 'CREATED_BY', 'CREATED_DATE', 'LAST_UPDATED_BY', 'LAST_UPDATED_DATE', 'REV_NO',  'REV_TEXT', 'APPROVAL_STATE', 'APPROVAL_BY', 'APPROVAL_DATE', 'REC_ID' )
and column_name not in ('FROM_CLASS_NAME','TO_CLASS_NAME','ROLE_NAME','CONTEXT_CODE','DB_MAPPING_TYPE','DB_SQL_SYNTAX') ;

CURSOR c_property_columns3 is
select column_name, replace(replace(column_name,'SORT_ORDER','SCREEN_SORT_ORDER'),'PRESENTATION_SYNTAX','PresentationSyntax') as property_code , nvl(p.property_type,'DYNAMIC_PRESENTATION') property_type, DECODE(p.property_type, 'VIEWLAYER', '/', '/EC') as presentation_cntx
from cols c
left join class_property_codes p on (replace(replace(column_name,'SORT_ORDER','SCREEN_SORT_ORDER'),'PRESENTATION_SYNTAX','PresentationSyntax') = p.property_code and p.property_table_name = 'CLASS_REL_PROPERTY_CNFG')
where table_name = 'CLASS_REL_PRESENTATION'
and column_name not in (  'RECORD_STATUS', 'CREATED_BY', 'CREATED_DATE', 'LAST_UPDATED_BY', 'LAST_UPDATED_DATE', 'REV_NO',  'REV_TEXT', 'APPROVAL_STATE', 'APPROVAL_BY', 'APPROVAL_DATE', 'REC_ID' )
and column_name not in ('FROM_CLASS_NAME','TO_CLASS_NAME','ROLE_NAME','CONTEXT_CODE')
and column_name not in ('STATIC_PRESENTATION_SYNTAX') ;


  lv2_sql varchar2(32000);

BEGIN

  Insert into CLASS_RELATION_CNFG(from_class_name, to_class_name, role_name,  app_space_cntx, is_key, is_bidirectional, group_type, multiplicity, record_status, created_by,
                         created_date,last_updated_by, last_updated_date, rev_no, rev_text, approval_state,
                         approval_by, approval_date, rec_id)
  select from_class_name, to_class_name, role_name,
         CASE WHEN context_code IS NULL THEN (SELECT app_space_code FROM class WHERE class_name=cr.to_class_name) ELSE context_code END AS app_space_cntx,
         is_key, is_bidirectional, group_type, multiplicity, record_status, created_by, created_date,
         last_updated_by, last_updated_date, rev_no, rev_text, approval_state,
         approval_by , approval_date, rec_id
  from class_relation cr
  where not exists ( select 1 from CLASS_RELATION_CNFG crc
                   where cr.from_class_name = crc.from_class_name
                   and   cr.to_class_name = crc.to_class_name
                   and   cr.role_name = crc.role_name
  )
  and exists ( select 1 from class_cnfg cc where cr.from_class_name = cc.class_name)
  and exists ( select 1 from class_cnfg cc where cr.to_class_name = cc.class_name)
  ;


  update CLASS_RELATION_CNFG  c set (db_mapping_type, db_sql_syntax) =
  ( select db_mapping_type, db_sql_syntax
  from class_rel_db_mapping m where c.from_class_name = m.from_class_name and c.to_class_name = m.to_class_name  and c.role_name = m.role_name);


  FOR curProperty in c_property_columns1 LOOP

    lv2_sql := 'Insert into CLASS_REL_PROPERTY_CNFG(from_class_name, to_class_name, role_name, property_code, owner_cntx, presentation_cntx, property_type,';
    lv2_sql := lv2_sql || ' property_value , record_status, created_by, created_date, last_updated_by, last_updated_date,';
    lv2_sql := lv2_sql || ' rev_no, rev_text, approval_state, approval_by,approval_date) ';
    lv2_sql := lv2_sql || 'select cr.from_class_name, cr.to_class_name, cr.role_name, '''||curProperty.property_code||''',0, ''' || curProperty.presentation_cntx || ''',''' ||curProperty.property_type||''',cr.'||curProperty.column_name;
    lv2_sql := lv2_sql || ', cr.record_status, cr.created_by, cr.created_date, cr.last_updated_by, cr.last_updated_date, cr.rev_no, cr.rev_text,';
    lv2_sql := lv2_sql || ' cr.approval_state, cr.approval_by, cr.approval_date from class_relation cr ';
    lv2_sql := lv2_sql || ' join class_relation_cnfg c2 on (cr.from_class_name = c2.from_class_name and cr.to_class_name = c2.to_class_name and cr.role_name = c2.role_name )';
    lv2_sql := lv2_sql || ' where trim(cr.'||curProperty.column_name||') is not null';

    ecdp_dynsql.execute_statement(lv2_sql);

  END LOOP;

  FOR curProperty2 in c_property_columns2 LOOP

    lv2_sql := 'Insert into CLASS_REL_PROPERTY_CNFG(from_class_name, to_class_name, role_name, property_code, owner_cntx, presentation_cntx, property_type,';
    lv2_sql := lv2_sql || ' property_value , record_status, created_by, created_date, last_updated_by, last_updated_date,';
    lv2_sql := lv2_sql || ' rev_no, rev_text, approval_state, approval_by,approval_date) ';
    lv2_sql := lv2_sql || ' select db.from_class_name, db.to_class_name, db.role_name, '''||curProperty2.property_code||''',0, ''' || curProperty2.presentation_cntx || ''',''' ||curProperty2.property_type||''',db.'||curProperty2.column_name;
    lv2_sql := lv2_sql || ', db.record_status, db.created_by, db.created_date, db.last_updated_by, db.last_updated_date, db.rev_no,db.rev_text,';
    lv2_sql := lv2_sql || ' db.approval_state, db.approval_by, db.approval_date from CLASS_REL_DB_MAPPING db';
    lv2_sql := lv2_sql || ' join class_relation_cnfg cr on (db.from_class_name = cr.from_class_name and db.to_class_name = cr.to_class_name and db.role_name = cr.role_name )';
    lv2_sql := lv2_sql || ' where trim(db.'||curProperty2.column_name||') is not null';


--    ecdp_dynsql.WriteTempText('DEBUG',lv2_sql );

    ecdp_dynsql.execute_statement(lv2_sql);

  END LOOP;

  FOR curProperty3 in c_property_columns3 LOOP

    lv2_sql := 'Insert into CLASS_REL_PROPERTY_CNFG(from_class_name, to_class_name, role_name, property_code, owner_cntx, presentation_cntx, property_type,';
    lv2_sql := lv2_sql || ' property_value , record_status, created_by, created_date, last_updated_by, last_updated_date,';
    lv2_sql := lv2_sql || ' rev_no, rev_text, approval_state, approval_by,approval_date) ';
    lv2_sql := lv2_sql || 'select p.from_class_name, p.to_class_name, p.role_name, '''||curProperty3.property_code||''',0, ''' || curProperty3.presentation_cntx || ''',''' ||curProperty3.property_type||''',p.'||curProperty3.column_name;
    lv2_sql := lv2_sql || ', p.record_status, p.created_by, p.created_date, p.last_updated_by, p.last_updated_date, p.rev_no,p.rev_text,';
    lv2_sql := lv2_sql || ' p.approval_state, p.approval_by, p.approval_date from CLASS_REL_PRESENTATION p';
    lv2_sql := lv2_sql || ' join class_relation_cnfg cr on (p.from_class_name = cr.from_class_name and p.to_class_name = cr.to_class_name and p.role_name = cr.role_name )';
    lv2_sql := lv2_sql || ' where trim('||curProperty3.column_name||') is not null';

    ecdp_dynsql.execute_statement(lv2_sql);

  END LOOP;

  MigrateClassRelPresentation;

  Commit;


end;



Procedure CopyClassToNewStructure iS

begin

  MigrateClassProperties;
  MigrateClassAttribute;
  MigrateClassRelation;


  insert into CLASS_DEPENDENCY_CNFG
  (
    parent_class      ,
    child_class       ,
    app_space_cntx    ,
    dependency_type   ,
    record_status     ,
    created_by        ,
    created_date      ,
    last_updated_by   ,
    last_updated_date ,
    rev_no            ,
    rev_text          ,
    approval_state    ,
    approval_by       ,
    approval_date     ,
    rec_id
  )
  select
    d.parent_class      ,
    d.child_class       ,
    replace(c.app_space_cntx,'EC_','EC_'),
    d.dependency_type   ,
    d.record_status     ,
    d.created_by        ,
    d.created_date      ,
    d.last_updated_by   ,
    d.last_updated_date ,
    d.rev_no            ,
    d.rev_text          ,
    d.approval_state    ,
    d.approval_by       ,
    d.approval_date     ,
    d.rec_id
  from class_dependency d
  inner join class_cnfg c on c.class_name = d.child_class
  where not exists(
    select 1 from class_dependency_cnfg d2
    where d.parent_class = d2.parent_class
    and   d.child_class = d2.child_class
    and   d.dependency_type = d2.dependency_type
  )
    and exists ( select 1 from class_cnfg cc where d.parent_class = cc.class_name)
    and exists ( select 1 from class_cnfg cc where d.child_class = cc.class_name);



  insert into CLASS_TRIGGER_ACTN_CNFG
  (
    class_name        ,
    triggering_event  ,
    trigger_type      ,
    sort_order        ,
    db_sql_syntax     ,
    app_space_cntx    ,
    record_status     ,
    created_by        ,
    created_date      ,
    last_updated_by   ,
    last_updated_date ,
    rev_no            ,
    rev_text          ,
    approval_by       ,
    approval_date     ,
    approval_state    ,
    rec_id
  )
  select
    class_name        ,
    triggering_event  ,
    trigger_type      ,
    sort_order        ,
    db_sql_syntax     ,
    CASE WHEN context_code IS NULL THEN (SELECT replace(app_space_code,'EC_','EC_') FROM class WHERE class_name=cta.class_name) ELSE context_code END AS app_space_cntx,
    record_status     ,
    created_by        ,
    created_date      ,
    last_updated_by   ,
    last_updated_date ,
    rev_no            ,
    rev_text          ,
    approval_by       ,
    approval_date     ,
    approval_state    ,
    rec_id
  from class_trigger_action cta
  where exists ( select 1 from class_cnfg cc where cta.class_name = cc.class_name);




	insert into CLASS_TRA_PROPERTY_CNFG
	(
	  class_name        ,
	  triggering_event  ,
	  trigger_type      ,
	  sort_order        ,
	  property_code     ,
	  owner_cntx        ,
	  property_type     ,
	  property_value    ,
	  record_status     ,
	  created_by        ,
	  created_date      ,
	  last_updated_by   ,
	  last_updated_date ,
	  rev_no            ,
	  rev_text          ,
	  approval_by       ,
	  approval_date     ,
	  approval_state    ,
	  rec_id
	)
	select
	  c1.class_name        ,
	  c1.triggering_event  ,
	  c1.trigger_type      ,
	  c1.sort_order        ,
	  'DISABLED_IND'     ,
	  0              ,
	  'VIEWLAYER'       ,
	  c1.disabled_ind      ,
	  c1.record_status     ,
	  c1.created_by        ,
	  c1.created_date      ,
	  c1.last_updated_by   ,
	  c1.last_updated_date ,
	  c1.rev_no            ,
	  c1.rev_text          ,
	  c1.approval_by       ,
	  c1.approval_date     ,
	  c1.approval_state    ,
	  c1.rec_id
	from class_trigger_action c1
	join class_trigger_actn_cnfg c2 on ( c1.class_name = c2.class_name and c1.triggering_event = c2.triggering_event and c1.trigger_type = c2.trigger_type and c1.sort_order = c2.sort_order )
	where disabled_ind is not null
;


	insert into CLASS_TRA_PROPERTY_CNFG
	(
	  class_name        ,
	  triggering_event  ,
	  trigger_type      ,
	  sort_order        ,
	  property_code     ,
	  owner_cntx        ,
	  property_type     ,
	  property_value    ,
	  record_status     ,
	  created_by        ,
	  created_date      ,
	  last_updated_by   ,
	  last_updated_date ,
	  rev_no            ,
	  rev_text          ,
	  approval_by       ,
	  approval_date     ,
	  approval_state    ,
	  rec_id
	)
	select
	  c1.class_name        ,
	  c1.triggering_event  ,
	  c1.trigger_type      ,
	  c1.sort_order        ,
	  'DESCRIPTION'     ,
	  0              ,
	  'APPLICATION'     ,
	  c1.description       ,
	  c1.record_status     ,
	  c1.created_by        ,
	  c1.created_date      ,
	  c1.last_updated_by   ,
	  c1.last_updated_date ,
	  c1.rev_no            ,
	  c1.rev_text          ,
	  c1.approval_by       ,
	  c1.approval_date     ,
	  c1.approval_state    ,
	  c1.rec_id
	from class_trigger_action c1
	join class_trigger_actn_cnfg c2 on ( c1.class_name = c2.class_name and c1.triggering_event = c2.triggering_event and c1.trigger_type = c2.trigger_type and c1.sort_order = c2.sort_order )
	where description is not null
	;


  commit;

end;


Procedure htmlHeader3(p_title varchar2)
is

begin

   ecdp_dynsql.WriteTempText('UPGRADE_CLASS_COMPARE','<H3>'||p_title||'</H3>'  );

end;

Procedure htmltable(p_h1 varchar2
                  , p_h2 varchar2 default null
                  , p_h3 varchar2 default null
                  , p_h4 varchar2 default null
                  , p_h5 varchar2 default null
                  , p_h6 varchar2 default null
                  , p_h7 varchar2 default null
                  )
is

  lv2_html varchar2(1000);

begin

       lv2_html := '<TABLE border=1 width=800><TR bgcolor=lightgrey>';

       if p_h1 is not null then
          lv2_html := lv2_html || '<TD>'||p_h1||'</TD>';
       end if;

       if p_h2 is not null then
          lv2_html := lv2_html || '<TD>'||p_h2||'</TD>';
       end if;

       if p_h3 is not null then
          lv2_html := lv2_html || '<TD>'||p_h3||'</TD>';
       end if;

       if p_h4 is not null then
          lv2_html := lv2_html || '<TD>'||p_h4||'</TD>';
       end if;

       if p_h5 is not null then
          lv2_html := lv2_html || '<TD>'||p_h5||'</TD>';
       end if;

       if p_h6 is not null then
          lv2_html := lv2_html || '<TD>'||p_h6||'</TD>';
       end if;

       if p_h7 is not null then
          lv2_html := lv2_html || '<TD>'||p_h7||'</TD>';
       end if;

       lv2_html := lv2_html || '</TR>';

       ecdp_dynsql.WriteTempText('UPGRADE_CLASS_COMPARE',lv2_html);

end;

Procedure htmlSection(p_i in out number
                      , p_title varchar2
                      , p_h1 varchar2
                      , p_h2 varchar2 default null
                      , p_h3 varchar2 default null
                      , p_h4 varchar2 default null
                      , p_h5 varchar2 default null
                      , p_h6 varchar2 default null
                      , p_h7 varchar2 default null
                      )
is

begin

    IF p_i = 0 then
       htmlHeader3(p_title);
       htmltable(p_h1,p_h2, p_h3, p_h4, p_h5, p_h6,p_h7);
       p_i := 1;
    end if;

end;

Procedure htmlSectionend(p_i in out number)
is
begin

  IF p_i = 1 then
    ecdp_dynsql.WriteTempText('UPGRADE_CLASS_COMPARE','</TABLE><P>');
    p_i := 0;
  end if;
end;







/*PROCEDURE ClassMigrationStatistic
IS

   TYPE data_t IS TABLE OF NUMBER
      INDEX BY PLS_INTEGER;

   TYPE array_t IS TABLE OF data_t
      INDEX BY PLS_INTEGER;


   TYPE array_c is varray(13) of varchar2(50);

cursor c_class_count is
select 1 version_id , count(*) num_count from class
union all
select 3 version_id, count(*) num_count from class_cnfg where app_space_cntx in ('EC_FRMW','EC_PROD','EC_TRAN','EC_SALE','EC_REVN','EC_ECDM','EC_DM','EC_BPM')
union all
select 2 version_id, count(*) num_count from u_class_cnfg where app_space_cntx in ('EC_FRMW','EC_PROD','EC_TRAN','EC_SALE','EC_REVN','EC_ECDM','EC_DM','EC_BPM')
order by 1
;

cursor c_class_attr_count is
select 1 version_id, count(*) num_count from class_attribute
union all
select 3 version_id, count(*) num_count from class_attribute_cnfg where app_space_cntx in ('EC_FRMW','EC_PROD','EC_TRAN','EC_SALE','EC_REVN','EC_ECDM','EC_DM','EC_BPM')
union all
select 2 version_id, count(*) num_count from u_class_attribute_cnfg where app_space_cntx in ('EC_FRMW','EC_PROD','EC_TRAN','EC_SALE','EC_REVN','EC_ECDM','EC_DM','EC_BPM')
order by 1
;

cursor c_class_rel_count is
select 1 version_id, count(*) num_count from class_relation
union all
select 3 version_id, count(*) num_count from class_relation_cnfg where app_space_cntx in ('EC_FRMW','EC_PROD','EC_TRAN','EC_SALE','EC_REVN','EC_ECDM','EC_DM','EC_BPM')
union all
select 2 version_id, count(*) num_count from u_class_relation_cnfg where app_space_cntx in ('EC_FRMW','EC_PROD','EC_TRAN','EC_SALE','EC_REVN','EC_ECDM','EC_DM','EC_BPM')
order by 1
;

cursor c_class_tra_count is
select 1 version_id, count(*) num_count from class_trigger_action
union all
select 3 version_id, count(*) num_count from class_trigger_actn_cnfg where app_space_cntx in ('EC_FRMW','EC_PROD','EC_TRAN','EC_SALE','EC_REVN','EC_ECDM','EC_DM','EC_BPM')
union all
select 2 version_id, count(*) num_count from u_class_trigger_actn_cnfg where app_space_cntx in ('EC_FRMW','EC_PROD','EC_TRAN','EC_SALE','EC_REVN','EC_ECDM','EC_DM','EC_BPM')
order by 1
;

cursor c_class_dep_count is
select 1 version_id, count(*) num_count from class_dependency
union all
select 3 version_id, count(*) num_count from class_dependency_cnfg where app_space_cntx in ('EC_FRMW','EC_PROD','EC_TRAN','EC_SALE','EC_REVN','EC_ECDM','EC_DM','EC_BPM')
union all
select 2 version_id, count(*) num_count from u_class_dependency_cnfg where app_space_cntx in ('EC_FRMW','EC_PROD','EC_TRAN','EC_SALE','EC_REVN','EC_ECDM','EC_DM','EC_BPM')
order by 1
;

cursor c_class_property_count is
select 1 version_id, count(*) num_count from class_property_cnfg where owner_cntx = 1000
union all
select 3 version_id, count(*) num_count from class_property_cnfg where owner_cntx = 0
union all
select 2 version_id, count(*) num_count from class_property_cnfg where owner_cntx = -100
order by 1
;

cursor c_class_attr_property_count is
select 1 version_id, count(*) num_count from class_attr_property_cnfg where owner_cntx = 1000
union all
select 3 version_id, count(*) num_count from class_attr_property_cnfg where owner_cntx = 0
union all
select 2 version_id, count(*) num_count from class_attr_property_cnfg where owner_cntx = -100
order by 1
;

cursor c_class_rel_property_count is
select 1 version_id, count(*) num_count from class_rel_property_cnfg where owner_cntx = 1000
union all
select 3 version_id, count(*) num_count from class_rel_property_cnfg where owner_cntx = 0
union all
select 2 version_id, count(*) num_count from class_rel_property_cnfg where owner_cntx = -100
order by 1
;

cursor c_class_tra_property_count is
select 1 version_id, count(*) num_count from class_tra_property_cnfg where owner_cntx = 1000
union all
select 3 version_id, count(*) num_count from class_tra_property_cnfg where owner_cntx = 0
union all
select 2 version_id, count(*) num_count from class_tra_property_cnfg where owner_cntx = -100
order by 1
;

cursor c_class_property_diff(p_1 number, p_2 number) is
select count(*) num_count from class_property_cnfg c1
join class_property_cnfg c2 on (c1.class_name = c2.class_name
                               and c1.property_code = c2.property_code
                               and c1.property_type = c2.property_type)
where c1.owner_cntx = p_1
and   c2.owner_cntx = p_2
and   c1.property_value <> c2.property_value;

cursor c_class_attr_property_diff(p_1 number, p_2 number) is
select count(*) num_count from class_attr_property_cnfg c1
join class_attr_property_cnfg c2 on (c1.class_name = c2.class_name
                               and c1.attribute_name = c2.attribute_name
                               and c1.property_code = c2.property_code
                               and c1.property_type = c2.property_type)
where c1.owner_cntx = p_1
and   c2.owner_cntx = p_2
and   c1.property_value <> c2.property_value;

cursor c_class_rel_property_diff(p_1 number, p_2 number) is
select count(*) num_count from class_rel_property_cnfg c1
join class_rel_property_cnfg c2 on (c1.from_class_name = c2.from_class_name
                               and c1.to_class_name = c2.to_class_name
                               and c1.role_name = c2.role_name
                               and c1.property_code = c2.property_code
                               and c1.property_type = c2.property_type)
where c1.owner_cntx = p_1
and   c2.owner_cntx = p_2
and   c1.property_value <> c2.property_value;

cursor c_class_tra_property_diff(p_1 number, p_2 number) is
select count(*) num_count from class_tra_property_cnfg c1
join class_tra_property_cnfg c2 on (c1.class_name = c2.class_name
                               and c1.triggering_event = c2.triggering_event
                               and c1.trigger_type = c2.trigger_type
                               and c1.sort_order = c2.sort_order
                               and c1.property_code = c2.property_code
                               and c1.property_type = c2.property_type)
where c1.owner_cntx = p_1
and   c2.owner_cntx = p_2
and   c1.property_value <> c2.property_value;



   l_2d_grid array_t;
   l_column_headers array_c;
   l_row_headers array_c := array_c('Class Count#'
                                  , 'Class Attribute Count#'
                                  , 'Class Relation Count#'
                                  ,'Class Trigger Action Count#'
                                  ,'Class Dependency Count#'
                                  ,'Class Property Count#'
                                  ,'Class Attr Property Count#'
                                  ,'Class Rel Property Count#'
                                  ,'Class TRA Property Count#'
                                  ,'Changed Class Property #'
                                  ,'Changed Attr Class Property #'
                                  ,'Changed Rel Class Property #'
                                  ,'Changed TRA Class Property #'
                                  );

   j number := 0;
   lv2_db_details varchar2(200);

BEGIN

  Delete from t_temptext where id = 'UPGRADE_CLASS_COMPARE';

  FOR c in c_class_count LOOP
    l_2d_grid (1)(c.version_id)  := c.num_count;
  END LOOP;

  FOR c2 in c_class_attr_count LOOP
    l_2d_grid (2) (c2.version_id)  := c2.num_count;
  END LOOP;

  FOR c3 in c_class_rel_count LOOP
    l_2d_grid (3)(c3.version_id)  := c3.num_count;
  END LOOP;

  FOR c4 in c_class_tra_count LOOP
    l_2d_grid (4)(c4.version_id)  := c4.num_count;
  END LOOP;

  FOR c5 in c_class_dep_count LOOP
    l_2d_grid (5) (c5.version_id)  := c5.num_count;
  END LOOP;

  FOR c6 in c_class_property_count LOOP
    l_2d_grid (6) (c6.version_id)  := c6.num_count;
  END LOOP;

  FOR c7 in c_class_attr_property_count LOOP
    l_2d_grid (7) (c7.version_id)  := c7.num_count;
  END LOOP;

  FOR c8 in c_class_rel_property_count LOOP
    l_2d_grid (8) (c8.version_id)  := c8.num_count;
  END LOOP;

  FOR c9 in c_class_tra_property_count LOOP
    l_2d_grid (9) (c9.version_id)  := c9.num_count;
  END LOOP;

  ecdp_dynsql.WriteTempText('UPGRADE_CLASS_COMPARE','<html><CENTER><H1>EC Upgrade, Class Migration report</H1>');

  select 'Generated on '||user||'@'||global_name||' at '||to_char(sysdate,'yyyy-mm-dd hh24:mi')
  into lv2_db_details
  from global_name;

  ecdp_dynsql.WriteTempText('UPGRADE_CLASS_COMPARE','<P>'||lv2_db_details||'<P><CENTER>');


  htmlSection(j, 'Class Migration Statistics','Description','Current DB','Previous EC Version','New EC Version');


  FOR i IN 1..9 LOOP
     ecdp_dynsql.WriteTempText('UPGRADE_CLASS_COMPARE','<tr><td>'||l_row_headers(i)||'</td><td>'||l_2d_grid(i)(1)||'</td><td>'||l_2d_grid(i)(2)||'</td><td>'||l_2d_grid(i)(3)||'</td></tr>');

  END LOOP;

  htmlSectionend(j);


  htmlSection(j, 'Class Property Difference Statistics','Description','Prev to New EC','Prev EC to Current DB','Current DB to New EC');


  FOR c10 in c_class_property_diff(-100,0) LOOP
    l_2d_grid (10) (1)  := c10.num_count;
  END LOOP;

  FOR c11 in c_class_property_diff(-100,1000) LOOP
    l_2d_grid (10) (2)  := c11.num_count;
  END LOOP;

  FOR c12 in c_class_property_diff(0,1000) LOOP
    l_2d_grid (10) (3)  := c12.num_count;
  END LOOP;



  FOR c13 in c_class_attr_property_diff(-100,0) LOOP
    l_2d_grid (11) (1)  := c13.num_count;
  END LOOP;

  FOR c14 in c_class_attr_property_diff(-100,1000) LOOP
    l_2d_grid (11) (2)  := c14.num_count;
  END LOOP;

  FOR c15 in c_class_attr_property_diff(0,1000) LOOP
    l_2d_grid (11) (3)  := c15.num_count;
  END LOOP;

  FOR c16 in c_class_rel_property_diff(-100,0) LOOP
    l_2d_grid (12) (1)  := c16.num_count;
  END LOOP;

  FOR c17 in c_class_rel_property_diff(-100,1000) LOOP
    l_2d_grid (12) (2)  := c17.num_count;
  END LOOP;

  FOR c18 in c_class_rel_property_diff(0,1000) LOOP
    l_2d_grid (12) (3)  := c18.num_count;
  END LOOP;

  FOR c19 in c_class_rel_property_diff(-100,0) LOOP
    l_2d_grid (13) (1)  := c19.num_count;
  END LOOP;

  FOR c20 in c_class_rel_property_diff(-100,1000) LOOP
    l_2d_grid (13) (2)  := c20.num_count;
  END LOOP;

  FOR c21 in c_class_tra_property_diff(0,1000) LOOP
    l_2d_grid (13) (3)  := c21.num_count;
  END LOOP;



  FOR i IN 10..13 LOOP
     ecdp_dynsql.WriteTempText('UPGRADE_CLASS_COMPARE','<tr><td>'||l_row_headers(i)||'</td><td>'||l_2d_grid(i)(1)||'</td><td>'||l_2d_grid(i)(2)||'</td><td>'||l_2d_grid(i)(3)||'</td></tr>');

  END LOOP;

  htmlSectionend(j);


  ecdp_dynsql.WriteTempText('UPGRADE_CLASS_COMPARE','</html>');

  commit;

END;
*/
/*PROCEDURE CreateClassMigrationReport
IS

BEGIN
  ClassMigrationStatistic;
  ecdp_dynsql.WriteTempText('UPGRADE_CLASS_COMPARE','<HR>');
  ecdp_dynsql.WriteTempText('UPGRADE_CLASS_COMPARE','Any findings in the following sections should ideally be fixed.');
  ecdp_dynsql.WriteTempText('UPGRADE_CLASS_COMPARE','<HR>');
  ValidateClassForNewStucture;

END;
*/



/*
Procedure ValidateClassForNewStucture is

begin
  compareClassTable;
  compareClassAttributeTable;
  compareClassRelationTable;
  compareClassTriggerAction;
  compareClassDependency;
end;

*/

Procedure RemoveIdenticalProperties(p_high_owner_cntx number,
                                    p_low_owner_cntx number,
                                    p_property_table_name varchar2 default null,
                                    p_property_type varchar2 default null,
                                    p_property_code varchar2 default null)  is
begin

  if upper(p_property_table_name) = 'CLASS_PROPERTY_CNFG' THEN

     Delete from class_property_cnfg p1
     where property_code = p_property_code
     and property_type = p_property_type
     and owner_cntx = p_high_owner_cntx
     and exists (
       select 1 from class_property_cnfg p2
       where p1.class_name = p2.class_name
       and   p1.property_code = p2.property_code
       and   p1.property_type = p2.property_type
       and   p1.presentation_cntx = p2.presentation_cntx
       and   owner_cntx = p_low_owner_cntx
       and   p1.property_value = p2.property_value
       );


  elsif upper(p_property_table_name) = 'CLASS_ATTR_PROPERTY_CNFG' THEN

     Delete from class_attr_property_cnfg p1
     where property_code = p_property_code
     and property_type = p_property_type
     and owner_cntx = p_high_owner_cntx
     and exists (
       select 1 from class_attr_property_cnfg p2
       where p1.class_name = p2.class_name
       and   p1.attribute_name = p2.attribute_name
       and   p1.presentation_cntx = p2.presentation_cntx
       and   p1.property_code = p2.property_code
       and   p1.property_type = p2.property_type
       and   owner_cntx = p_low_owner_cntx
       and   p1.property_value = p2.property_value
       );



  elsif upper(p_property_table_name) = 'CLASS_REL_PROPERTY_CNFG' THEN

     Delete from class_rel_property_cnfg p1
     where property_code = p_property_code
     and property_type = p_property_type
     and owner_cntx = p_high_owner_cntx
     and exists (
       select 1 from class_rel_property_cnfg p2
       where p1.from_class_name = p2.from_class_name
       and   p1.to_class_name = p2.to_class_name
       and   p1.role_name = p2.role_name
       and   p1.presentation_cntx = p2.presentation_cntx
       and   p1.property_code = p2.property_code
       and   p1.property_type = p2.property_type
       and   owner_cntx = p_low_owner_cntx
       and   p1.property_value = p2.property_value
       );


  elsif upper(p_property_table_name) = 'CLASS_TRA_PROPERTY_CNFG' THEN


     Delete from class_tra_property_cnfg p1
     where property_code = p_property_code
     and property_type = p_property_type
     and owner_cntx = p_high_owner_cntx
     and exists (
       select 1 from class_tra_property_cnfg p2
       where p1.class_name = p2.class_name
       and   p1.triggering_event = p2.triggering_event
       and   p1.trigger_type = p2.trigger_type
       and   p1.sort_order   = p2.sort_order
       and   p1.property_code = p2.property_code
       and   p1.property_type = p2.property_type
       and   owner_cntx = p_low_owner_cntx
       and   p1.property_value = p2.property_value
       );

  end if;

end;



Procedure DeleteUpdPropreties(p_option number)
-- This procedure can be run with 3 different options
--1) Don't remove any rows with owner_cntx = 1000
--2) Remove the once that is equal to the value from 11.1SP3
--3) Remove the once that is equal to 11.1SP3 and EC 11.2 (Default)

IS

BEGIN

  -- This procedure is more spesific for the upgrade case with a 3 way compare as described over.

  if p_option in (2,3) then

     Delete from class_property_cnfg p1
     where owner_cntx = 1000
     and exists (
       select 1 from class_property_cnfg p2
       where p1.class_name = p2.class_name
       and   p1.property_code = p2.property_code
       and   p1.presentation_cntx = p2.presentation_cntx
       and   p1.property_type = p2.property_type
       and   owner_cntx = -100
       and   p1.property_value = p2.property_value
       );


     Delete from class_attr_property_cnfg p1
     where owner_cntx = 1000
     and exists (
       select 1 from class_attr_property_cnfg p2
       where p1.class_name = p2.class_name
       and   p1.attribute_name = p2.attribute_name
       and   p1.property_code = p2.property_code
       and   p1.presentation_cntx = p2.presentation_cntx
       and   p1.property_type = p2.property_type
       and   owner_cntx = -100
       and   p1.property_value = p2.property_value
       );


     Delete from class_rel_property_cnfg p1
     where owner_cntx = 1000
     and exists (
       select 1 from class_rel_property_cnfg p2
       where p1.from_class_name = p2.from_class_name
       and   p1.to_class_name = p2.to_class_name
       and   p1.role_name = p2.role_name
       and   p1.property_code = p2.property_code
       and   p1.presentation_cntx = p2.presentation_cntx
       and   p1.property_type = p2.property_type
       and   owner_cntx = -100
       and   p1.property_value = p2.property_value
       );

     Delete from class_tra_property_cnfg p1
     where owner_cntx = 1000
     and exists (
       select 1 from class_tra_property_cnfg p2
       where p1.class_name = p2.class_name
       and   p1.triggering_event = p2.triggering_event
       and   p1.trigger_type = p2.trigger_type
       and   p1.sort_order = p2.sort_order
       and   p1.property_code = p2.property_code
       and   p1.property_type = p2.property_type
       and   owner_cntx = -100
       and   p1.property_value = p2.property_value
       );

  end if;


  if p_option = 3 then


     Delete from class_property_cnfg p1
     where owner_cntx = 1000
     and exists (
       select 1 from class_property_cnfg p2
       where p1.class_name = p2.class_name
       and   p1.property_code = p2.property_code
       and   p1.presentation_cntx = p2.presentation_cntx
       and   p1.property_type = p2.property_type
       and   owner_cntx = 0
       and   p1.property_value = p2.property_value
       );


     Delete from class_attr_property_cnfg p1
     where owner_cntx = 1000
     and exists (
       select 1 from class_attr_property_cnfg p2
       where p1.class_name = p2.class_name
       and   p1.attribute_name = p2.attribute_name
       and   p1.property_code = p2.property_code
       and   p1.presentation_cntx = p2.presentation_cntx
       and   p1.property_type = p2.property_type
       and   owner_cntx = 0
       and   p1.property_value = p2.property_value
       );


     Delete from class_rel_property_cnfg p1
     where owner_cntx = 1000
     and exists (
       select 1 from class_rel_property_cnfg p2
       where p1.from_class_name = p2.from_class_name
       and   p1.to_class_name = p2.to_class_name
       and   p1.role_name = p2.role_name
       and   p1.property_code = p2.property_code
       and   p1.presentation_cntx = p2.presentation_cntx
       and   p1.property_type = p2.property_type
       and   owner_cntx = 0
       and   p1.property_value = p2.property_value
       );

     Delete from class_tra_property_cnfg p1
     where owner_cntx = 1000
     and exists (
       select 1 from class_tra_property_cnfg p2
       where p1.class_name = p2.class_name
       and   p1.triggering_event = p2.triggering_event
       and   p1.trigger_type = p2.trigger_type
       and   p1.sort_order = p2.sort_order
       and   p1.property_code = p2.property_code
       and   p1.property_type = p2.property_type
       and   owner_cntx = 0
       and   p1.property_value = p2.property_value
       );


  end if;

  commit;

END;


Procedure DeletePrevECPropreties
is

begin


     Delete from class_property_cnfg p1
     where owner_cntx = -100;

     Delete from class_attr_property_cnfg p1
     where owner_cntx = -100;

     Delete from class_rel_property_cnfg p1
     where owner_cntx = -100;

     Delete from class_tra_property_cnfg p1
     where owner_cntx = -100;

    commit;

end;

END;