CREATE OR REPLACE PACKAGE BODY EcDp_Task_Detail IS

/****************************************************************
** Package        :  EcDp_Task_Detail, header part
**
** $Revision: 1.9 $
**
** Purpose        : Support functions for Task detail.
**
** Documentation  :  www.energy-components.com
**
** Created  : 11-Oct-2007
**
** Modification history:
**
**  Date     Whom  Change description:
**  ------   ----- --------------------------------------
** 11.10.07  AV    Initial version of package
*****************************************************************/

FUNCTION RecIDDetailDescription(
    p_class_name  IN VARCHAR2,
    p_rec_id      IN VARCHAR2
    ) RETURN VARCHAR2


IS
  lv2_sql VARCHAR(2000);
  lv2_col VARCHAR(2000);
  lv2_result VARCHAR(2000);
  lv2_table_name VARCHAR(32);
  lv2_main_table VARCHAR(32);
  lv2_class_view_name VARCHAR(32);
  lv2_owner_main_ec_pck VARCHAR(32);
  lv2_owner_attr_ec_pck VARCHAR(32);

  lr_class_cnfg class_cnfg%ROWTYPE;
  lr_owner_class_cnfg class_cnfg%ROWTYPE;

  CURSOR c_class_key IS
    SELECT attribute_name FROM class_attribute_cnfg ca
    WHERE class_name = p_class_name
    AND   is_key = 'Y';

BEGIN

  lv2_result := NULL;
  lr_class_cnfg := ec_class_cnfg.row_by_pk(p_class_name);
  IF lr_class_cnfg.class_type = 'OBJECT' THEN
    lv2_table_name := lr_class_cnfg.db_object_attribute;
    lv2_main_table := lr_class_cnfg.db_object_name;
  ELSE
    lv2_table_name := lr_class_cnfg.db_object_name;
  END IF;

  lv2_class_view_name := ecdp_classmeta.getClassViewName(p_class_name);

  IF p_class_name IS NOT NULL AND p_rec_id IS NOT NULL THEN

    lv2_result := 'No key information available';

    IF lr_class_cnfg.class_type = 'OBJECT' THEN

      IF p_class_name = 'CONTRACT_TEXT_ITEM' THEN
        lv2_sql := ' SELECT ecdp_objects.getObjname(o.CONTRACT_ID, o.START_DATE) || '', '' || ecdp_objects.getObjname(o.CONTRACT_DOC_ID, o.START_DATE) || '', '' || to_char(o.START_DATE , ''yyyy-mm-dd hh24:mi:ss'') ' ||
                   '   FROM ' || lv2_main_table || ' o, ' || lv2_table_name || ' ov ' ||
                   '  WHERE o.object_id = ov.object_id ' ||
                   '    AND ov.rec_id = ''' || p_rec_id || '''';
      ELSE
        lv2_sql := ' SELECT o.object_code || '' '' || ov.name || '' '' || to_char(ov.daytime,''dd.mm.yyyy hh24:mi'') ' ||
                   '   FROM ' || lv2_main_table || ' o, ' || lv2_table_name || ' ov ' ||
                   '  WHERE o.object_id = ov.object_id ' ||
                   '    AND ov.rec_id = ''' || p_rec_id || '''';
      END IF;

      lv2_result :=  ecdp_dynsql.execute_singlerow_varchar2(lv2_sql);

      IF lv2_result IS NULL THEN -- This row can be deleted, must then get info from journal table

        IF p_class_name = 'CONTRACT_TEXT_ITEM' THEN
            lv2_sql := ' SELECT ecdp_objects.getObjname(o.CONTRACT_ID, o.START_DATE) || '', '' || ecdp_objects.getObjname(o.CONTRACT_DOC_ID, o.START_DATE) || '', '' || to_char(o.START_DATE , ''yyyy-mm-dd hh24:mi:ss'') ' ||
                       '   FROM ' || lv2_main_table || '_JN o, ' || lv2_table_name || '_JN ov ' ||
                       '  WHERE o.object_id = ov.object_id ' ||
                       '    AND ov.rec_id = ''' || p_rec_id || '''' ||
                       '    AND rownum = 1';
        ELSE
            lv2_sql := ' SELECT o.object_code || '' '' || ov.name || '' '' || to_char(ov.daytime,''dd.mm.yyyy hh24:mi'') ' ||
                       '   FROM ' || lv2_main_table || '_JN o, ' || lv2_table_name || '_JN ov ' ||
                       '  WHERE o.object_id = ov.object_id ' ||
                       '    AND ov.rec_id = ''' || p_rec_id || '''' ||
                       '    AND rownum = 1';
        END IF;

        lv2_result :=  ecdp_dynsql.execute_singlerow_varchar2(lv2_sql);

      END IF;

    ELSIF ecdp_classmeta.getclasstype(p_class_name) = 'DATA'
        AND ecdp_classmeta.getClassAttrDbSqlSyntax(p_class_name,'OBJECT_ID') IS NOT NULL
        AND ecdp_classmeta.getClassAttrDbSqlSyntax(p_class_name,'DAYTIME') IS NOT NULL THEN
      lr_owner_class_cnfg := ec_class_cnfg.row_by_pk(lr_class_cnfg.owner_class_name);
      lv2_owner_main_ec_pck := 'EC_' || lr_owner_class_cnfg.db_object_name;
      lv2_owner_attr_ec_pck := 'EC_' || lr_owner_class_cnfg.db_object_attribute;

      IF p_class_name = 'SPLIT_KEY_SETUP_COMPANY' THEN

                lv2_sql := ' select ec_contract.object_code(cd.contract_id) || '' '' || cdv.name || '' '' || tt.object_code || '' '' || ttv.name ' ||
                 ' from contract_doc             cd, ' ||
                      ' contract_doc_version     cdv, ' ||
                      ' transaction_template     tt, ' ||
                      ' transaction_tmpl_version ttv, ' ||
                      ' split_key_setup          sks_sp, ' ||
                      ' split_key_setup          sks_comp ' ||
                ' where sks_sp.child_split_key_id = sks_comp.object_id ' ||
                  ' and ttv.split_key_id = sks_sp.object_id ' ||
                  ' and cd.object_id = cdv.object_id ' ||
                  ' and cdv.daytime = ' ||
                      ' (select max(cdv_sub.daytime) ' ||
                         ' from contract_doc_version cdv_sub ' ||
                        ' where cdv_sub.object_id = cd.object_id) ' ||
                  ' and tt.object_id = ttv.object_id ' ||
                  ' and ttv.daytime = ' ||
                      ' (select max(ttv_sub.daytime) ' ||
                         ' from transaction_tmpl_version ttv_sub ' ||
                        ' where ttv_sub.object_id = tt.object_id) ' ||
                  ' and tt.contract_doc_id = cd.object_id ' ||
                  ' and sks_comp.rec_id = ''' || p_rec_id || '''' ||
                  ' UNION ALL ' || -- Following part is for SPLIT_KEY_SETUP_SP objects that
                                   -- are mistakenly recognized as SPLIT_KEY_SETUP_COMPANY,
                                   -- since both of the classes have same objects
                  ' select ec_contract.object_code(cd.contract_id) || '' '' || cdv.name || '' '' || tt.object_code || '' '' || ttv.name ' ||
                 ' from contract_doc             cd, ' ||
                      ' contract_doc_version     cdv, ' ||
                      ' transaction_template     tt, ' ||
                      ' transaction_tmpl_version ttv, ' ||
                      ' split_key_setup          sks_comp ' ||
                ' where ttv.split_key_id = sks_comp.object_id ' ||
                  ' and sks_comp.class_name = ''SPLIT_KEY_SETUP_SP''' ||
                  ' and cd.object_id = cdv.object_id ' ||
                  ' and cdv.daytime = ' ||
                      ' (select max(cdv_sub.daytime) ' ||
                         ' from contract_doc_version cdv_sub ' ||
                        ' where cdv_sub.object_id = cd.object_id) ' ||
                  ' and tt.object_id = ttv.object_id ' ||
                  ' and ttv.daytime = ' ||
                      ' (select max(ttv_sub.daytime) ' ||
                         ' from transaction_tmpl_version ttv_sub ' ||
                        ' where ttv_sub.object_id = tt.object_id) ' ||
                  ' and tt.contract_doc_id = cd.object_id ' ||
                  'and sks_comp.rec_id = ''' || p_rec_id || '''';


      ELSIF p_class_name = 'SPLIT_KEY_SETUP_SP' THEN
           lv2_sql := ' select ec_contract.object_code(cd.contract_id) || '' '' || cdv.name || '' '' || tt.object_code || '' '' || ttv.name ' ||
                   ' from contract_doc             cd, ' ||
                        ' contract_doc_version     cdv, ' ||
                        ' transaction_template     tt, ' ||
                        ' transaction_tmpl_version ttv, ' ||
                        ' split_key_setup          sks_sp ' ||
                  ' where ttv.split_key_id = sks_sp.object_id ' ||
                    ' and cd.object_id = cdv.object_id ' ||
                    ' and cdv.daytime = ' ||
                        ' (select max(cdv_sub.daytime) ' ||
                           ' from contract_doc_version cdv_sub ' ||
                          ' where cdv_sub.object_id = cd.object_id) ' ||
                    ' and tt.object_id = ttv.object_id ' ||
                    ' and ttv.daytime = ' ||
                        ' (select max(ttv_sub.daytime) ' ||
                           ' from transaction_tmpl_version ttv_sub ' ||
                          ' where ttv_sub.object_id = tt.object_id) ' ||
                    ' and tt.contract_doc_id = cd.object_id ' ||
                    'and sks_sp.rec_id = ''' || p_rec_id || '''';

      ELSIF p_class_name like 'CONT_DOCUMENT%' THEN
             lv2_sql := ' SELECT ecdp_objects.getObjname(OBJECT_ID, DAYTIME) || '', '' || ecdp_objects.getObjname(EC_CONT_DOCUMENT.contract_doc_id(DOCUMENT_KEY),DAYTIME) || '', '' || to_char(DAYTIME, ''yyyy-mm-dd hh24:mi:ss'') ' ||
                        '   FROM ' || lv2_class_view_name ||
                        '  WHERE rec_id = ''' || p_rec_id || '''' ;

	  ELSIF p_class_name = 'CONTRACT_ATTRIBUTE' THEN
             lv2_sql :=  ' SELECT ''Contract : ''||OBJECT_CODE || '' Attribute Name : '' || ATTRIBUTE_NAME || '' Daytime : '' || to_char(DAYTIME, ''yyyy-mm-dd hh24:mi:ss'') '||
                        '   FROM ' || lv2_class_view_name ||
                        '  WHERE rec_id = ''' || p_rec_id || '''' ;

      ELSIF p_class_name = 'CONTRACT_PRICE_LIST' THEN
             lv2_sql :=  ' SELECT ''Contract : ''||OBJECT_CODE || '' Unit : '' || UOM || '' Daytime : '' || to_char(DAYTIME, ''yyyy-mm-dd hh24:mi:ss'') '||
                        '   FROM ' || lv2_class_view_name ||
                        '  WHERE rec_id = ''' || p_rec_id || '''' ;

      ELSE
             -- General expression to get object code, object name and daytime from data class row
             lv2_sql := ' SELECT ' || lv2_owner_main_ec_pck || '.OBJECT_CODE(object_id) || '' '' || ' || lv2_owner_attr_ec_pck || '.NAME(OBJECT_ID, DAYTIME,''<='') || '' '' || to_char(daytime,''yyyy-mm-dd hh24:mi:ss'') ' ||
                        '   FROM ' || lv2_table_name ||
                        '  WHERE rec_id = ''' || p_rec_id || '''';

      END IF;

      lv2_result :=  ecdp_dynsql.execute_singlerow_varchar2(lv2_sql);

       IF lv2_result IS NULL THEN -- This row can be deleted, must then get info from journal table

          lv2_sql := ' SELECT ' || lv2_owner_main_ec_pck || '.OBJECT_CODE(object_id) || '' '' || ' || lv2_owner_attr_ec_pck || '.NAME(OBJECT_ID, DAYTIME,''<='') || '' '' || to_char(daytime,''yyyy-mm-dd hh24:mi:ss'') ' ||
                     '   FROM ' || lv2_table_name || '_JN ' ||
                     '  WHERE rec_id = ''' || p_rec_id || '''' ||
                     '    AND rownum = 1';


          lv2_result :=  ecdp_dynsql.execute_singlerow_varchar2(lv2_sql);

       END IF;

    ELSE

      lv2_sql := NULL  ;

      FOR curAttr IN c_class_key LOOP

        IF curAttr.attribute_name = 'OBJECT_ID' THEN

            lv2_col := 'ecdp_objects.getObjName(OBJECT_ID,Ecdp_Timestamp.getCurrentSysdate)';

        ELSE

            lv2_col := ''''||curAttr.attribute_name||':''||'||curAttr.attribute_name;

        END IF;

        IF lv2_sql IS NULL THEN

          lv2_sql := lv2_col  ;

        ELSE

          lv2_sql := lv2_sql || '||'';''||'||lv2_col;

        END IF;

      END LOOP;

      lv2_sql := ' SELECT '|| lv2_sql ||' FROM '||ecdp_classmeta.getClassViewName(p_class_name)||' WHERE rec_id = '''||p_rec_id||''''  ;

      lv2_result :=  ecdp_dynsql.execute_singlerow_varchar2(lv2_sql);

       IF lv2_result IS NULL THEN -- This row can be deleted, must then get info from journal table

          lv2_sql := ' SELECT '|| lv2_sql || ' FROM '||lv2_table_name||'_JN'||
                     ' WHERE rec_id = '''||p_rec_id||''' and rownum = 1'  ;

          lv2_result :=  ecdp_dynsql.execute_singlerow_varchar2(lv2_sql);

       END IF;



     END IF;

  END IF;

  RETURN lv2_result;


END;



END EcDp_Task_Detail;