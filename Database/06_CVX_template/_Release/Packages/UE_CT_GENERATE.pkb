create or replace 
PACKAGE BODY UE_CT_GENERATE IS
/*********************************************************************************************
** Package              : UE_CT_GENERATE, body
**
** Version              : 1.0.0.0
**
** Purpose              : To provide a common method for generating CT classes
**                        This package is a partial copy of ecdp_genclasscode.buildreport layer with the removal of the join to system_days
**
** Modification history:
**
** Date         Whom        Change description
** -------------------------------------------------------------------------------------
** 17-DEC-2011  SWGN        Initial Version
** 12-JUN-2012  CAIL    Added p_ct_class_name_override: Gives the ability to hard code the output class name, with no other text appended.
**              This addresses the bug in which prefixing an existing class name with 'CT_' makes the class name overrun its column size.
** 09-AUG-2012  SUKF        Switched from OV_ based views to table based to allow RV_CT view to include report only columns
** 31-JAN-2018  NIKITA    Procedure GenerateSimplifiedObjectView modified to work with the new Class model
** 03-APR-2018  NIKITA    Procedure GenerateSimplifiedObjectView modified to handle asset customizations
**
*********************************************************************************************/

FUNCTION getJoinColumnSyntax(rec IN EcDp_ClassMeta.c_dataclasses_attr%ROWTYPE)
RETURN VARCHAR2
IS
BEGIN
   RETURN rec.db_join_alias||'.'||REPLACE(LOWER(rec.db_sql_syntax), LOWER(rec.db_join_table||'.'));
END getJoinColumnSyntax;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- procedure      : AddUniqueViewColumns
-- Description    : Add a new column to the list only if the same alias is not allready in the list.
--
-- Preconditions  : The function looks for UNION or UNION ALL statemts, but will not see the difference if these are
--                  commented out. Each new column line must be less than 256 char for the compare to work.
--
-- Postcondition  : Returns a DBMS_SQL.varchar2a structure where the new line is added if the alias is unique
--                  the new line is always added
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE AddUniqueViewColumns(p_view_columns IN OUT DBMS_SQL.varchar2a, p_new_column IN VARCHAR2)
--</EC-DOC>

IS
  lb_found      BOOLEAN;
  lv2_searchstr VARCHAR2(4000);
  lv2_currstr   VARCHAR2(4000);
  lv2_currstr2  VARCHAR2(500);
  ln_start_as   NUMBER;
  comma_start   NUMBER;
  ln_last       NUMBER;
  i             INTEGER;


BEGIN

  lv2_searchstr := UPPER(p_new_column);
  ln_start_as := INSTR(lv2_searchstr,' AS ');
  lb_found := FALSE;

  IF ln_start_as > 0 AND p_view_columns.count > 0 THEN  -- Look for duplicates only when line contains an alias

     lv2_searchstr := SUBSTR(lv2_searchstr,ln_start_as); -- Note to the end of the line

     ln_last := p_view_columns.last;
     i := ln_last;

     WHILE i  >  p_view_columns.first LOOP

        lv2_currstr := RTRIM(UPPER(p_view_columns(i)));

        ln_start_as := INSTR(lv2_currstr,' AS ');
        lv2_currstr2 := SUBSTR(lv2_currstr,ln_start_as); -- Note to the end of the line

        IF ln_start_as > 0 THEN  -- We have something to compare and possibly exclude

           IF Nvl(lv2_currstr2,'NULL') =  nvl(lv2_searchstr,'NULL1') THEN

              lb_found := TRUE;

              -- Replace logic: This procedure is mainly used for data class report views, where owner class columns will be added first
                 --                since we want the data class column to win if there are duplicate column name, this procedure will
                 --                replace the duplicate with this new column definition .

                 -- Need to check if this is the first column, in that case need to remove initial comma

                 IF SUBSTR(LTRIM(lv2_currstr),1,1) = ',' THEN

                    p_view_columns(i) := p_new_column;

                 ELSE

                    comma_start := INSTR(p_new_column,',');  -- There should always be one if we are here.
                    p_view_columns(i) := SUBSTR(p_new_column,1,comma_start-1)||' '||SUBSTR(p_new_column,comma_start+1);

                 END IF;

                 EXIT;

              END IF;

            END IF;

            IF LTRIM(RTRIM(UPPER(p_view_columns(i)))) IN ('UNION', 'UNION ALL') THEN
                -- Dont search any further it is only a point to avoid duplicates within one union,
                -- since we both search and add from the bottom, this should be consistent
                EXIT;
            END IF;

            i := i - 1;

     END LOOP;

   END IF;

   IF NOT lb_found THEN

     EcDp_dynsql.AddSqlLineNoWrap(p_view_columns, p_new_column); -- Force Nowrapp


   END IF;

END AddUniqueViewColumns;

--<EC-DOC>

---------------------------------------------------------------------------------------------------
-- procedure      : GeneratedCodeMsg2
-- Description    :

-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
--  ***** SUKF - THIS IS A DIRECT COPY OF ECDP_GENCLASSCODE.GeneratedCodeMsg2 (NO CUSTOMIZATION HAS OCCURRED)
---------------------------------------------------------------------------------------------------

FUNCTION GeneratedCodeMsg2 RETURN VARCHAR2

IS

BEGIN

    RETURN '-- Generated by EcDp_GenClassCode ';

END GeneratedCodeMsg2;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : createReportObjectClassColumnList
-- Description    : Build SQL for report views colums on object classes, created as separate function
--                  to be able to use from both object class and data classes with this object class
--                  as owner.
--
-- Preconditions  : p_class_name must refer to a class of type 'OBJECT'
--
--
-- Postcondition  : Returns a string with all attributes and relations for given class, except those
--                  that are excluded if caller is a child DATA class
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE  createReportOCColumnList(lv2_sql_lines IN OUT DBMS_SQL.varchar2a, p_class_name varchar2 ,p_caller_type VARCHAR2,p_owner_interface VARCHAR2 DEFAULT NULL)
--</EC-DOC>

IS

  CURSOR c_class_attr(cp_class_name   VARCHAR2,cp_interface VARCHAR2 DEFAULT NULL) IS
    SELECT ca.class_name,
           ca.attribute_name,
           ca.db_mapping_type,
           ca.db_sql_syntax,
           Ecdp_Classmeta_Cnfg.getUomCode(ca.class_name, ca.attribute_name) AS uom_code,
           Ecdp_Classmeta_Cnfg.getDbSortOrder(ca.class_name, ca.attribute_name) AS sort_order
    FROM class_attribute_cnfg ca, class_attribute_cnfg ca2
    WHERE ca2.class_name = Nvl(cp_interface,ca.class_name)
    AND   ca2.attribute_name = ca.attribute_name
    AND   Ecdp_Classmeta_Cnfg.isDisabled(ca.class_name, ca.attribute_name) = 'N'
    AND   ca.class_name = cp_class_name
    AND   ca.attribute_name NOT IN('CLASS_NAME','OBJECT_ID','CODE','NAME','OBJECT_START_DATE','OBJECT_END_DATE','DAYTIME','END_DATE')
    ORDER BY Ecdp_Classmeta_Cnfg.getDbSortOrder(ca.class_name, ca.attribute_name);

   CURSOR c_attr_unit(cp_class_name VARCHAR2, cp_attribute_name VARCHAR2) IS
    SELECT cp.class_name,
          cp.attribute_name,
          u.db_unit_ind,
          u.unit,
          u.measurement_type
    FROM class_attribute_cnfg cp, ctrl_uom_setup u
    WHERE Ecdp_Classmeta_Cnfg.getUomCode(cp.class_name, cp.attribute_name) = u.measurement_type
    AND  (u.report_unit_ind = 'Y' OR u.db_unit_ind = 'Y')
    AND  cp.class_name = cp_class_name
    AND   cp.attribute_name = cp_attribute_name;

   CURSOR c_class_relations IS
    SELECT d1.class_name,      -- Get group relations
          d1.rel_class_name,
          d1.property_name attribute_name,
          d1.role_name,
          d1.db_mapping_type,
          d1.db_sql_syntax,
          'Y' is_group,
          d1.sort_order
    FROM v_dao_meta d1, v_dao_meta d2
    WHERE d2.class_name = Nvl(p_owner_interface,d1.class_name)
    AND   d2.property_name = d1.property_name
    AND   d1.class_name = p_class_name
    AND   d1.is_relation = 'Y'
    AND   d1.is_popup = 'N'
    AND   d1.group_type IS NOT NULL
    UNION ALL          -- Get relations
    SELECT cr.to_class_name,
          cr.from_class_name rel_class_name,
          cr.role_name||'_ID' attribute_name,
          cr.role_name,
          cr.db_mapping_type,
          cr.db_sql_syntax,
          'N' is_group,
          Ecdp_Classmeta_Cnfg.getDbSortOrder(cr.from_class_name, cr.to_class_name, cr.role_name) AS sort_order
    FROM class_relation_cnfg cr
    WHERE cr.to_class_name = p_class_name
    AND   Ecdp_Classmeta_Cnfg.isDisabled(cr.from_class_name, cr.to_class_name, cr.role_name) = 'N'
    AND   cr.group_type IS NULL
    AND EXISTS ( SELECT 1 FROM class_relation_cnfg cr2
                 WHERE cr2.to_class_name = Nvl(p_owner_interface,cr.to_class_name)
                 AND   cr2.from_class_name = cr.from_class_name
                 AND   cr2.role_name = cr.role_name
                 UNION ALL
                 SELECT 1 FROM class_attribute_cnfg ca2
                 WHERE ca2.class_name = p_owner_interface
                 AND   UPPER(ca2.attribute_name) = UPPER(cr.role_name||'_ID')
               )

    ORDER BY sort_order,attribute_name;


   lv2_col                   VARCHAR2(10000);
   lv2_attr_unit             VARCHAR2(100);
   lv2_column_name           VARCHAR2(1000);


BEGIN

   AddUniqueViewColumns(lv2_sql_lines,' ,o.object_id AS OBJECT_ID');
   AddUniqueViewColumns(lv2_sql_lines,' ,o.object_code AS CODE');
   AddUniqueViewColumns(lv2_sql_lines,' ,oa.name AS NAME');
   AddUniqueViewColumns(lv2_sql_lines,' ,o.start_date AS OBJECT_START_DATE');
   AddUniqueViewColumns(lv2_sql_lines,' ,o.end_date AS OBJECT_END_DATE');

   IF p_caller_type = 'OBJECT' THEN
   --  AddUniqueViewColumns(lv2_sql_lines,' ,s.daytime AS '||'PRODUCTION_DAY');
     AddUniqueViewColumns(lv2_sql_lines,' ,oa.daytime AS DAYTIME');
     AddUniqueViewColumns(lv2_sql_lines,' ,oa.end_date AS END_DATE');
   END IF;

  -- Add non relation attributes, but must limit if comming from INTERFACE
  FOR curAttr IN c_class_attr(p_class_name,p_owner_interface) LOOP

    IF curAttr.db_mapping_type = 'COLUMN' THEN

      lv2_col := 'o.'||LOWER(curAttr.db_sql_syntax);

    ELSIF curAttr.db_mapping_type IN ('INNER_JOIN', 'LEFT_JOIN') THEN
      FOR cur IN Ecdp_Classmeta.c_classes_attr(p_class_name, 'N', curAttr.Attribute_Name) LOOP
          lv2_col := getJoinColumnSyntax(cur);
      END LOOP;
    ELSIF curAttr.db_mapping_type = 'ATTRIBUTE' THEN

      lv2_col := 'oa.'||LOWER(curAttr.db_sql_syntax);

    ELSIF curAttr.db_mapping_type = 'FUNCTION' THEN

      lv2_col := curAttr.db_sql_syntax;

    END IF;

     -- Get database unit
      lv2_attr_unit := EcDp_Unit.GetUnitFromLogical(curAttr.uom_code);

      IF lv2_attr_unit = curAttr.uom_code THEN -- clear attribute_unit if uom_code is an unit
        lv2_attr_unit := NULL;
      END IF;

    IF lv2_attr_unit IS NULL THEN


      AddUniqueViewColumns(lv2_sql_lines ,' ,'||lv2_col||' AS '||curAttr.attribute_name);

    ELSE -- add unit conversion

      -- Trunc attribute name if attribute_<unit> > 30 characters
      lv2_column_name := lv2_col||' AS '||EcDB_Utils.TruncText(curAttr.attribute_name,30 - (LENGTH(lv2_attr_unit) + 1))||'_'||lv2_attr_unit;

--      AddUniqueViewColumns(lv2_sql_lines ,' ,'||lv2_col||' AS '||lv2_column_name);
      AddUniqueViewColumns(lv2_sql_lines ,' ,'||lv2_column_name);

      FOR curUnit IN c_attr_unit(p_class_name, curAttr.attribute_name) LOOP

        lv2_column_name := UPPER(EcDB_Utils.TruncText(curAttr.attribute_name,30 - (LENGTH(curUnit.unit) + 1))||'_'||curUnit.unit);

        IF lv2_attr_unit <> curUnit.unit THEN

          lv2_col := ',EcDp_Unit.convertValue(';

          IF curAttr.db_mapping_type = 'COLUMN' THEN
            lv2_col := lv2_col||'o.'||curAttr.db_sql_syntax||',''';
          ELSIF curAttr.db_mapping_type IN ('INNER_JOIN', 'LEFT_JOIN') THEN
            FOR cur IN Ecdp_Classmeta.c_classes_attr(p_class_name, 'N', curAttr.Attribute_Name) LOOP
                lv2_col := lv2_col||getJoinColumnSyntax(cur)||',''';
            END LOOP;
          ELSIF curAttr.db_mapping_type = 'ATTRIBUTE' THEN
            lv2_col := lv2_col||'oa.'||curAttr.db_sql_syntax||',''';
          ELSIF curAttr.db_mapping_type = 'FUNCTION' THEN
            lv2_col := lv2_col||curAttr.db_sql_syntax||',''';
          END IF;

          lv2_col := lv2_col||lv2_attr_unit||''',''';
          lv2_col := lv2_col||curUnit.unit||''',';
          lv2_col := lv2_col||'oa.daytime,';
          lv2_col := lv2_col||Nvl(TO_CHAR(ec_ctrl_unit_conversion.precision(lv2_attr_unit,curUnit.unit,ecdp_date_time.getCurrentSysdate,'<=')),'NULL');

           IF (ecdp_classmeta.OwnerClassName(p_class_name) IS NOT NULL) THEN
             lv2_col := lv2_col||',NULL,';
             lv2_col := lv2_col||'NULL,';
             lv2_col := lv2_col||'O.OBJECT_ID';
           END IF;

          lv2_col := lv2_col||') AS '||EcDB_Utils.TruncText(curAttr.attribute_name,30 - (LENGTH(curUnit.unit) + 1))||'_'||curUnit.unit;

          AddUniqueViewColumns(lv2_sql_lines ,lv2_col);

        END IF;

      END LOOP;

    END IF;


  END LOOP;

  -- Add relation/group connections, but must limit if comming from INTERFACE
  FOR curRel IN c_class_relations LOOP

    IF curRel.db_mapping_type = 'COLUMN' THEN

      AddUniqueViewColumns(lv2_sql_lines,' ,o.'||LOWER(curRel.db_sql_syntax)||' AS '||curRel.attribute_name);

      IF curRel.is_group = 'N' THEN -- add relation code

        -- Use EcDp_Objects.GetObjCode if rel_class_name is interface
        IF ec_class_cnfg.class_type(curRel.rel_class_name) = 'INTERFACE' THEN

          AddUniqueViewColumns(lv2_sql_lines,',EcDp_Objects.GetObjCode(o.'||curRel.db_sql_syntax||') AS '||curRel.role_name||'_CODE');

        ELSE -- Better performance in using ec-package

          AddUniqueViewColumns(lv2_sql_lines,','||EcDp_ClassMeta.GetEcPackage(curRel.rel_class_name)||'.object_code(o.'||curRel.db_sql_syntax||') AS '||curRel.role_name||'_CODE');

        END IF;

      END IF;

    ELSIF curRel.db_mapping_type = 'ATTRIBUTE' THEN

      AddUniqueViewColumns(lv2_sql_lines,' ,oa.'||LOWER(curRel.db_sql_syntax)||' AS '||curRel.attribute_name);

      IF curRel.is_group = 'N' THEN -- add relation code

        -- Use EcDp_Objects.GetObjCode if rel_class_name is interface
        IF ec_class_cnfg.class_type(curRel.rel_class_name) = 'INTERFACE' THEN

          AddUniqueViewColumns(lv2_sql_lines,' ,EcDp_Objects.GetObjCode(oa.'||curRel.db_sql_syntax||') AS '||curRel.role_name||'_CODE');

        ELSE -- Better performance in using ec-package

          AddUniqueViewColumns(lv2_sql_lines,' ,'||EcDp_ClassMeta.GetEcPackage(curRel.rel_class_name)||'.object_code(oa.'||curRel.db_sql_syntax||') AS '||curRel.role_name||'_CODE');

        END IF;

      END IF;
    ELSIF curRel.db_mapping_type = 'FUNCTION' THEN

      AddUniqueViewColumns(lv2_sql_lines,','||LOWER(curRel.db_sql_syntax)||' AS '||curRel.attribute_name);

      IF curRel.is_group = 'N' THEN -- add relation code

        -- Use EcDp_Objects.GetObjCode if rel_class_name is interface
        IF ec_class_cnfg.class_type(curRel.rel_class_name) = 'INTERFACE' THEN

          AddUniqueViewColumns(lv2_sql_lines,' ,EcDp_Objects.GetObjCode('||curRel.db_sql_syntax||') AS '||curRel.role_name||'_CODE');

        ELSE -- Better performance in using ec-package

          AddUniqueViewColumns(lv2_sql_lines,' ,'||EcDp_ClassMeta.GetEcPackage(curRel.rel_class_name)||'.object_code('||curRel.db_sql_syntax||') AS '||curRel.role_name||'_CODE');

        END IF;

      END IF;
    END IF;

  END LOOP;


END createReportOCColumnList;


--<EC-DOC>
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- function       : ColumnExists
-- Description    : Returns TRUE if the named table/view has a column with the given column name.
--
-- Preconditions  :
-- Description    :
--
--
--
-- Postcondition  :
--
--
-- Using Tables   : All_Tables, All_Views
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior       :
--
--  ***** SUKF - THIS IS A DIRECT COPY OF ECDP_GENCLASSCODE.ColumnExists (NO CUSTOMIZATION HAS OCCURRED)
---------------------------------------------------------------------------------------------------

FUNCTION ColumnExists(
   p_table_name         VARCHAR2,
   p_column_name        VARCHAR2,
   p_table_owner        VARCHAR2
)
RETURN BOOLEAN
--</EC-DOC>
IS

   CURSOR c_columnexists(p_tableName VARCHAR2, p_columnName VARCHAR2, p_tableOwner  VARCHAR2) IS
      SELECT 1 FROM ALL_TABLES t, ALL_TAB_COLUMNS c
      WHERE  t.table_name = UPPER(p_tableName)
      AND    t.owner = Nvl(p_tableOwner,user)
      AND    t.owner = c.owner
      AND    t.table_name = c.table_name
      AND    c.column_name = UPPER(p_columnName)
      UNION ALL
      SELECT 1 FROM ALL_VIEWS v, ALL_TAB_COLUMNS c
      WHERE  v.view_name = UPPER(p_tableName)
      AND    v.owner = Nvl(p_tableOwner,USER)
      AND    v.owner = c.owner
      AND    v.view_name = c.table_name
      AND    c.column_name = UPPER(p_columnName);

   lb_exsists           BOOLEAN := FALSE;
   lv2_table_name       VARCHAR2(32);
   ln_index             NUMBER := 0;

BEGIN
   -- Remove Schema name from table_name, i.g remove EcKernel from EcKernel.Well
   ln_index := INSTR(p_table_name,'.');

   IF ln_index > 0 THEN
      lv2_table_name := SUBSTR(p_table_name,ln_index + 1);
   ELSE
      lv2_table_name := p_table_name;
   END IF;

   FOR curTable IN c_columnexists(lv2_table_name,p_column_name,p_table_owner) LOOP
        lb_exsists := TRUE;
   END LOOP;
   RETURN lb_exsists;
END ColumnExists;

---------------------------------------------------------------------------------------------------
-- function       : AddSafeViewColumn
-- Description    :
--
-- Preconditions  :
--
-- Postcondition  :
--
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
--  ***** SUKF - THIS IS A DIRECT COPY OF ECDP_GENCLASSCODE.AddSafeViewColumn (NO CUSTOMIZATION HAS OCCURRED)
---------------------------------------------------------------------------------------------------

FUNCTION AddSafeViewColumn(
   p_object_name  IN VARCHAR2
,  p_column_name  IN VARCHAR2
,  p_schema_owner IN VARCHAR2
,  p_prefix       IN VARCHAR2
)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
   IF ColumnExists(p_object_name, p_column_name,p_schema_owner) THEN
      IF LENGTH(p_prefix)>0 THEN
         RETURN p_prefix||p_column_name||' AS '||UPPER(p_column_name);
      ELSE
         RETURN p_column_name;
      END IF;
   END IF;
   RETURN 'NULL AS '||UPPER(p_column_name);
END AddSafeViewColumn;

FUNCTION WhereConditionReplace(p_where_condition IN VARCHAR2, p_table_name IN VARCHAR2, p_alias IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
   RETURN REGEXP_REPLACE(p_where_condition, '(\s*)('||p_table_name||')(\.)', '\1'||p_alias||'\3', 1, 0, 'i');
END WhereConditionReplace;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : ReportObjectClassView
-- Description    : Generate report views, class definition of type OBJECT
--
-- Preconditions  : p_class_name must refer to a class of type 'OBJECT'
--                  OV_<p_class_name> must have been created.
--
--
-- Postcondition  : View generated or error logged in t_temptext.
--                  IF p_target = 'SCRIPT' code generated to t_temptext
-- Using Tables   : t_temptext
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE ReportObjectClassView(
   p_class_name   VARCHAR2
)
--</EC-DOC>
IS

   lv2_sql_lines          DBMS_SQL.varchar2a;
   lv2_main_table         class_cnfg.db_object_name%TYPE;
  lv2_version_table       class_cnfg.db_object_attribute%TYPE;
  lv2_main_table_where    class_cnfg.db_where_condition%TYPE;
  lv2_schema_owner        class_cnfg.db_object_owner%TYPE;
BEGIN


  FOR curClass IN c_class_cnfg(p_class_name) LOOP

    lv2_main_table := curClass.db_object_name;
    lv2_version_table := curClass.db_object_attribute;
    lv2_main_table_where := curClass.db_where_condition;
    lv2_schema_owner := curClass.db_object_owner;

  END LOOP;

   AddUniqueViewColumns(lv2_sql_lines,'CREATE OR REPLACE VIEW RV_'||p_class_name||' AS');
   AddUniqueViewColumns(lv2_sql_lines,' SELECT');
   AddUniqueViewColumns(lv2_sql_lines, C_GENERATED_CODE_MSG2);
   AddUniqueViewColumns(lv2_sql_lines,''''||p_class_name||''' AS CLASS_NAME');

   createReportOCColumnList(lv2_sql_lines,p_class_name ,'OBJECT');

   -- Add standard record information columns
  AddUniqueViewColumns(lv2_sql_lines,',oa.record_status AS RECORD_STATUS');
  AddUniqueViewColumns(lv2_sql_lines,',oa.created_by AS CREATED_BY');
  AddUniqueViewColumns(lv2_sql_lines,',oa.created_date AS CREATED_DATE');
  AddUniqueViewColumns(lv2_sql_lines,',decode(sign(nvl(o.last_updated_date,o.created_date)-nvl(oa.last_updated_date,oa.created_date)),1,o.last_updated_by,oa.last_updated_by) AS

LAST_UPDATED_BY');
  AddUniqueViewColumns(lv2_sql_lines,',decode(sign(nvl(o.last_updated_date,o.created_date)-nvl(oa.last_updated_date,oa.created_date)),1,o.last_updated_date,oa.last_updated_date) AS

LAST_UPDATED_DATE');
  AddUniqueViewColumns(lv2_sql_lines,',o.rev_no||''.''||oa.rev_no AS REV_NO');
  AddUniqueViewColumns(lv2_sql_lines,',decode(sign(nvl(o.last_updated_date,o.created_date)-nvl(oa.last_updated_date,oa.created_date)),1,o.rev_text,oa.rev_text) AS REV_TEXT');

  AddUniqueViewColumns(lv2_sql_lines,','||AddSafeViewColumn(lv2_version_table,'approval_state',lv2_schema_owner,'oa.'));
  AddUniqueViewColumns(lv2_sql_lines,','||AddSafeViewColumn(lv2_version_table,'approval_by',lv2_schema_owner,'oa.'));
  AddUniqueViewColumns(lv2_sql_lines,','||AddSafeViewColumn(lv2_version_table,'approval_date',lv2_schema_owner,'oa.'));
  AddUniqueViewColumns(lv2_sql_lines,','||AddSafeViewColumn(lv2_version_table,'rec_id',lv2_schema_owner,'oa.'));

  AddUniqueViewColumns(lv2_sql_lines,'FROM '||lv2_version_table||' oa'|| ',' ||lv2_main_table ||' o');
  AddUniqueViewColumns(lv2_sql_lines,'WHERE oa.OBJECT_ID = o.OBJECT_ID ');
 -- AddUniqueViewColumns(lv2_sql_lines,'INNER JOIN '||lv2_main_table||' o ON o.object_id = oa.object_id');
 -- AddUniqueViewColumns(lv2_sql_lines,'INNER JOIN system_days s ON s.daytime >= oa.daytime AND (s.daytime < oa.end_date OR oa.end_date IS NULL) AND (s.daytime < o.end_date OR o.end_date IS NULL)');

  FOR cur IN c_class_attr_db_join_tables(p_class_name) LOOP
      AddUniqueViewColumns(lv2_sql_lines, REPLACE(cur.db_mapping_type, '_', ' ')||' '||cur.db_join_table||' '||cur.db_join_alias||' ON '||WhereConditionReplace(cur.db_join_where,

cur.db_join_table, cur.db_join_alias));
  END LOOP;

  IF lv2_main_table_where IS NOT NULL THEN

    AddUniqueViewColumns(lv2_sql_lines,'AND '||lv2_main_table_where);

  END IF;


   EcDp_Dynsql.SafeBuild('RV_'||p_class_name,'VIEW',lv2_sql_lines,p_lfflg => 'Y');




EXCEPTION

   WHEN OTHERS THEN
      EcDp_DynSql.WriteTempText('GENCODEERROR','Syntax error generating view for '||p_class_name||CHR(10)||SQLERRM||CHR(10));

END ReportObjectClassView;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- Procedure:     : GenerateSimplifiedObjectView
-- Description    : New custom procedure to build a RV_CT view from an object view.  The new RV_CT view will not join to system days
--

--
---------------------------------------------------------------------------------------------------

PROCEDURE GenerateSimplifiedObjectView(p_object_class_name VARCHAR2, p_ct_class_name_override VARCHAR2 DEFAULT NULL)
IS
    v_class_name        VARCHAR2(32) := 'CT_' || upper(p_object_class_name);
    v_description       varchar2(2000);
    v_dummy             NUMBER;
    v_object_attribute  VARCHAR2(30);
    v_db_object_name    VARCHAR2(30);
    v_db_object_owner   VARCHAR2(30);
    v_db_where_condition VARCHAR2(4000);
    v_time_scope_code    VARCHAR2(32);
    v_label             VARCHAR2(64);
    v_db_object_type    VARCHAR2(32);
    v_property_code varchar2(2000);
    v_property_type varchar2(2000);
    v_property_value varchar2(2000);



 --   cursor c_class_property_cnfg is
 --   select max(owner_cntx) as owner_cntx,property_code from class_property_cnfg WHERE class_name =upper(p_object_class_name)  group by property_code;

     -- List the Class Property Configurations for a given Class
    cursor c_class_property_cnfg is
    select property_code,owner_cntx,presentation_cntx,property_type,property_value
    from class_property_cnfg
    where class_name = p_object_class_name;

    -- List attributes of the given class
    cursor c_class_attr_cnfg is
    select attribute_name,is_key,data_type,db_mapping_type,db_sql_syntax,db_join_table,db_join_where
    from class_attribute_cnfg
    where class_name = p_object_class_name;

    --List the properties of all attributes of this Class
    cursor c_class_attr_property_cnfg is
    select attribute_name,property_code,owner_cntx,presentation_cntx,property_type,property_value
    from class_attr_property_cnfg
    where class_name = p_object_class_name;
  --  and owner_cntx=0;

    -- List the Class Relations for this Class
    cursor c_class_relation_cnfg is
    select from_class_name,role_name,is_key,is_bidirectional,group_type,multiplicity,db_mapping_type,db_sql_syntax
    from class_relation_cnfg
    where to_class_name = p_object_class_name;

    -- List the Properties of all Class Relations for this Class
    cursor c_class_rel_property_cnfg is
    select from_class_name,role_name,property_code,owner_cntx,presentation_cntx,property_type,property_value
    from class_rel_property_cnfg
    where to_class_name = p_object_class_name;

    cursor c_null is
    select from_class_name,to_class_name,role_name from class_relation where to_class_name = p_object_class_name and disabled_ind is null;


BEGIN

    IF p_ct_class_name_override IS NOT NULL THEN
  v_class_name := p_ct_class_name_override;
    END IF;

    -- Do some sanity checks - Check if the Class does not exist or there are more than one entries for the same class
    SELECT count(*) INTO v_dummy FROM class_cnfg WHERE class_name = upper(p_object_class_name);

    IF v_dummy <> 1 THEN
        RAISE_APPLICATION_ERROR(-20101, 'Specified class ''' || upper(p_object_class_name) || ''' does not exist or is ambiguous');
    END IF;

    SELECT class_type INTO v_description FROM class WHERE class_name = upper(p_object_class_name);

    IF v_description <> 'OBJECT' THEN
        RAISE_APPLICATION_ERROR(-20101, 'Specified class ''' || upper(p_object_class_name) || ''' is not an object_class');
    END IF;

    -- Trash the existing CT class definition
  --  DELETE FROM CLASS_REL_PROPERTY_CNFG where owner_cntx = 1500;
    DELETE FROM CLASS_REL_PROPERTY_CNFG where to_class_name = v_class_name;
    DELETE FROM CLASS_RELATION_CNFG WHERE to_class_name = v_class_name;
    DELETE FROM CLASS_ATTR_PROPERTY_CNFG WHERE class_name = v_class_name;
    DELETE FROM CLASS_ATTRIBUTE_CNFG WHERE class_name = v_class_name;
    DELETE FROM CLASS_PROPERTY_CNFG WHERE class_name = v_class_name;
    DELETE FROM CLASS_CNFG WHERE class_name = v_class_name;
    COMMIT;

---- copy the class configuration records for the OV_ view into the CT_ view
    -- Define the CLASS_CNFG
    SELECT  time_scope_code,db_object_owner, db_object_attribute, db_object_name, db_where_condition, db_object_type
    INTO  v_time_scope_code,v_db_object_owner, v_object_attribute, v_db_object_name, v_db_where_condition, v_db_object_type
    FROM class_cnfg WHERE class_name = upper(p_object_class_name);

    INSERT INTO class_cnfg (class_name, class_type, app_space_cntx, time_scope_code,db_object_type, db_object_owner, db_object_name, db_object_attribute, db_where_condition)
    VALUES (v_class_name, 'OBJECT', 'CVX', v_time_scope_code,v_db_object_type,v_db_object_owner, v_db_object_name,v_object_attribute, v_db_where_condition);

    -- Enter the Class Property Config

    FOR i in c_class_property_cnfg LOOP
        insert into class_property_cnfg (class_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
        VALUES (v_class_name,i.PROPERTY_CODE,i.OWNER_CNTX,i.PRESENTATION_CNTX,i.PROPERTY_TYPE,i.PROPERTY_VALUE);
    END LOOP;

    -- Enter the Class Attribute Configs

    FOR i in c_class_attr_cnfg LOOP
        INSERT INTO CLASS_ATTRIBUTE_CNFG (class_name,attribute_name, app_space_cntx, is_key,data_type,db_mapping_type,db_sql_syntax,db_join_table,db_join_where)
        VALUES (v_class_name,i.attribute_name,'CVX',i.is_key,i.data_type,i.db_mapping_type,i.db_sql_syntax,i.db_join_table,i.db_join_where);
    END LOOP;

      -- Enter the Class Atrribute Properties
    FOR i IN c_class_attr_property_cnfg LOOP
        insert into class_attr_property_cnfg (class_name,attribute_name, property_code, owner_cntx,presentation_cntx,property_type,property_value)
        values (v_class_name, i.attribute_name, i.property_code,i.owner_cntx,i.presentation_cntx, i.property_type, i.property_value);
     END LOOP;

     COMMIT;


    -- Enter the Class Relation Configurations
    FOR item IN c_class_relation_cnfg LOOP
        INSERT INTO class_relation_cnfg (from_class_name,to_class_name, role_name,app_space_cntx, is_key,  is_bidirectional, group_type, multiplicity ,db_mapping_type,db_sql_syntax )
        VALUES (item.from_class_name,v_class_name, item.role_name,'CVX', item.is_key,item.is_bidirectional, item.group_type, item.multiplicity ,item.db_mapping_type,item.db_sql_syntax);
    END LOOP;

    -- Enter the Class Relation Properties
    for item in c_class_rel_property_cnfg loop
        insert into class_rel_property_cnfg (from_class_name,to_class_name, role_name,property_code,owner_cntx,presentation_cntx,property_type,property_value)
        VALUES (item.from_class_name,v_class_name, item.role_name,item.property_code,item.owner_cntx,item.presentation_cntx,item.property_type,item.property_value);
    END LOOP;

    COMMIT;

--- build the new RV_CT reporting view
    ReportObjectClassView(v_class_name);

    -- Trash the CT class definition so that Object View is not generated in a subsequent Build View Layer
    DELETE FROM CLASS_REL_PROPERTY_CNFG where owner_cntx = 1500;
    DELETE FROM CLASS_REL_PROPERTY_CNFG where to_class_name = v_class_name;
    DELETE FROM class_relation_cnfg WHERE to_class_name = v_class_name;
    DELETE FROM CLASS_ATTR_PROPERTY_CNFG WHERE class_name = v_class_name;
    DELETE FROM CLASS_ATTRIBUTE_CNFG WHERE class_name = v_class_name;
    DELETE FROM CLASS_PROPERTY_CNFG WHERE class_name = v_class_name;
    DELETE FROM class_cnfg WHERE class_name = v_class_name;
    COMMIT;

END GenerateSimplifiedObjectView;


END UE_CT_GENERATE;
/