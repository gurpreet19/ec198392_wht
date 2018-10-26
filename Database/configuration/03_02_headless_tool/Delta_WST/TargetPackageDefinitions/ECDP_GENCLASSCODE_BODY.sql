CREATE OR REPLACE PACKAGE BODY EcDp_GenClassCode IS
/****************************************************************
** Package        :  EcDp_GenClass, body part
**
** $Revision: 1.264.4.23 $
**
** Purpose        :  Generate Views, instead of triggers and class methods based on class definitions.
**
** Documentation  :  www.energy-components.com
**
** Created  : 01.01.2003  Henning Stokke
**
** Modification history:
**

** Date     Whom   Change description:
** -------- ------ ------ --------------------------------------
** 19.03.03 AV     Merged development versions, better error handling
**                         writing to t_temptext, standard doc header
** 06.05.03 DN     Renamed t_temptext to t_temptext.
** 09.05.03 AV     Several bug fixes and changes in IUD_Object_triggers
**                 and IUD_Data_triggers.
** 09.05.03 DN     Postponed the class_method logic until a later release.
** 13.05.03 AV     Changed IUD trigger on data classes to use same method as
**                 object_classes with only one physical write
** 14.05.03 AV     Extended TableView trigger generation to include update
**                 Added new procedure BuildTableViews.
** 16.05.03 AV     Added support for different tables in DataClassViewIUTrg
** 19.05.03 AV     Bug fix using wrong class_name in ObjectClassViewIUTrg
** 27.05.03 AV     Bug fix, Object View trigger, set end_date to null
**                 in case new version gets an inconsistent end_date from copy.
** 05.06.03 AV     Bug fix in Object view trigger when referenced id and code is null
**                 Also put nvl on last_updated_by, last_updated_date to use
**                 user and sysdate if they are set to null
**                 Bug fix in data view trigger when referenced id and code is null
** 16.06.03 AV     Added check for correct class type when inserting object_id
**                 for data classes. Relations on data classes that are using obj_id - obj_id_5
**                 is part of key and can not be updated.
** 17.06.03 AV     Fixed bug on update when more than 1 object_id is part of primary key.
** 18.06.03 AV     Added check on class name on insert and mandatory relations check
** 22.07.03 AV     Major changes in IUD triggers Object and data classes
**                 Added check on Object relations against object_start_date
**                 and System earliest date
** 23.07.03 AV     Bug fixes in IUD trigger Objects and data
** 24.07.03 AV     Added check on start_date for object_relations, corrected
**                 spelling mistakes in error messanges.
** 25.07.03 AV     Fix in IUD triggers relation chack
** 19.08.03 AV     Added exception for TRANSFER User in ObjectClassViewIUTrg and
**                 DataClassViewIUTrg when demanding rev text on update
** 02.09.03 SHN    Added a check on relation variables to ensure that they are not NULL
**                 in DataClassViewIUTrg, and modified revision-block.
** 15.09.03 SHN    Modified revision-block in ObjectClassViewIUTrg.
** 20.11.03 SHN    Modified ObjectClassView and ObjectClassViewIUTrg to support storing objects in other tables than Objects, Objects_attribute_row.
** 09.12.03 SHN    Added function ObjectSubClassViewIUTrg
** 15.12.03 SHN    Updated InterfaceClassView.
** 26.05.04 SHN    Added function InterfaceClassViewIUTrg
** 07.06.04 SHN    Added functions ReportClassView,ReportDataClassView,ReportObjectClassView and BuildReportLayer.
** 07.06.04 SHN    Added support for where-condition for Interface views
** 11.06.04 DN     Added local function getSystemName.
** 15.06.04 DN     Modified ReportDataClassView. Extended lv2_cols.
** 23.09.04 DN     Added Nvl-test on last_updated_by in tableClassViewIUTrg procedure.
** 07.10.04 SHN    Added check to ensure that attribute_name is less than or equal to 30 char in AddClassAttributList.
** 08.10.04 SHN    Added function BuildView.
** 15.10.04 AV     Major rewrite of ObjectClassViewIUTrg and DataClassViewIUTrg
**                 Error in revision setting demanded signinficant changes and since rel 8.0 also has
**                 requirements that need restructuring of these triggers, this service fix takes into acoount
**                 these requirements also to avoid having to many solutions floating around, Even if this
**                 requires heavy retesting.
** 15.10.04 AV     Added check on use of object_id, daytime in dataClassView
** 18.10.04 AV     Included generation of trigger action in ObjectClassViewIUTrg and DataClassViewIUTrg
** 22.10.04 AV     Fixed bug in ObjectClassViewIUTrg seting attibute_text for numeric columns, should use attribute_value
** 26.10.04 AV     Added support for  default_value and report_only_ind in object and data view
** 26.10.04 SHN    Rewrote ReportClassView, ReportDataClassView, ReportInterfaceClassView,ReportObjectClassView to support OBJECTS_REPORT_ROW table
** 27.10.04 AV     Add procedure RecompileInvalidViewLayer
** 28.10.04 AV     Added procedure AddMissingAttributes
** 28.10.04 AV     Changed logic for data classes without daytime
** 28.10.04 SHN    Fixed a bug in SafeBuild
** 02.11.04 AV     Added check for unique code in ObjectClassViewIUTrg
** 08.11.04 AV     Fixed bug in AddMissingAttributes, Added _ID to role name when creating attributes
** 09.11.04 SHN    Added support for dataclasses with no daytime in ReportDataClassView
** 09.11.04 AV     Fixed bug in ObjectClassViewIUTrg for relation using attributes, Added _ID to role name when creating attributes
** 11.11.04 SHN    Fixed bug in ObjectClassView when generating -jn views, Added in where clause: attribute_type = 'OBJECT_CODE'
** 02.12.04 SHN     Fixed bug in ReportDataClassView. Tracker 1825.
** 09.12.04 SHN    Fixed bug in ObjectClassViewIUTrg when updateing objects_attr_row.
** 11.01.05 SHN    Modified ObjectClassViewIUTrg to support update of attributes that does not exist in the attribute-table.
                   Also removed update of class_name and object_id from the update objects_attribute_row-statement.
** 21.01.05 SHN    Fixed bug: Tracker 1895 - viewgenerator doesn't store end date on new objects
** 21.01.05 SHN    Added check for END_DATE < FROM_DATE in generated Table trigger. Tracker 1896
** 24.01.05 SHN     Extended BuildViewLayer and BuildReportLayer to make use of class app_space_code.
** 26.01.05 SHN    Removed use of daytime(use EcDp_Objects.GetObjStartDate instead) in OBJECT_CODE lookup for generated dv-views. Tracker 1950.
** 31.01.05 SHN    Suport for dataclasses with daytime < owner objects start date. Tracker 1961
** 17.02.05 AV     Changed references for renamed column is_private => disabled_ind
** 01.03.05 AV     New Consept for object storage
** 06.03.05 AV     Updated with bugfixes ECTP and new functionality creating object and object version view
** 07.03.05 SHN    Updated ObjectClassView with new functionality for creating ov-jn views.
** 10.03.05 AV     Added new version of CreateGroupsView, CreateObjectsView, CreateObjectsVersionView that creates dummy versions
**                 if no object classes or group relations are defined.
** 10.03.05 SHN    Added new version of ReportDataClassView
** 15.03.05 AV     Fixed syncronisation weakness with setting null values
** 22.03.05 AV     Fixed several bugs in sync package and merged to 1 package for each object class with new compile stratyegy
**                 Alo minor adjustments to trigger and create functions
** 01.04.05 AV     Corrected weakness in Data class trigger where a relation is part of key and you update the key
**                 using the foreign object_code instead of object_id.
** 02.04.05 SHN    Modified ReportClassView to support new object storage.
** 06.04.05 SHN    Added support for update of rev_text, last_updated_by/date in generated object triggers.
** 07.04.05 SHN    Modified the generated IUD-trigger to support change in object start/end date
** 08.04.05 AV     Renamed use of Ecdp_objects.if$str to ifDollarStr
** 08.04.05 SHN    Fixed bug in ov-jn-views
** 11.04.05 SHN    Modified ReportTableClassView to exclude password columns from generated rv-views. Tracker 2089.
** 13.04.05 AV     Added support for well hookup in call to getProcessingNode
** 14.04.05 SHN    Added support for proc_node-columns when generating object trigger for WELL.
** 15.04.05 SHN    Fixed bug in ReportTableClassView
** 21.04.05 SHN    Added support for well_id in call to getProcessingNode
** 21.04.05 SHN    Added jn_session,jn_appln in generated ov/dv-jn views
** 28.04.05 AV     Added new procedure CreateGroupSyncPackage
** 20.05.05 SHN    Fixed bug in generated IUD-object trigger when moving object start/end date. TD 3296(8.1)
                   Added support for disabled attributes in CreateGroupsView and CreateDefermentGroupsView
** 13.06.05 AV     Changed logic in AlignParentversion, must first find lowest level in group model that is
**                 used,and align only from that level. This also means that the trigger must only call
**                 alignparentversion once for each group model. Object trigger is also changed for relations
**                 to only call alignparentversion once for each group type. Tracker 2300
** 27.06.05 SHN    Added support for journal-condition in generated object iud-trigger. Tracker 2388.
** 04.07.05 SHN    Added support for trigger action on table classes. Tracker 2409.
** 12.07.05 SHN    Performance enhancement DV\RV-views. Tracker 2387
** 19.07.05 SHN    Made rev_text configurable mandatory. Tracker 2109
** 19.08.05 DN     TI2526 and TI2375: Discard RETURNING option when inserting into views.
** 29.08.05 AV     Added Check in InterfaceClassView, InterfaceClassViewIUTrg, ReportInterfaceClassView
**                 for interfaces without any implementing classes , GENCODEWARNING to T_temptext
** 29.08.05 AV     Added 2 new parameters to getprocessingnode call for special case WELL in trigger package. Tracker #2401
** 30.08.05 DN     TI2570: Removed logic for appending default class name in where clause in procedure DataClassView.
** 03.10.05 DN     TI2758: Improved the handling of required revision text.
** 09.11.05 AV     TI2591: Remove WriteTempText from this package, keeping the version in package EcDp_dynsql.
** 18.11.05 DN     Function CreateObjectsView and CreateObjectsVersionView: Only include persistable object classes.
** 28.11.05 AV     TI3140: Added special handling in ReportDataClassView for classes with time_scope_code = EVENT and defined end_date
** 29.11.05 AV     TI 3114: Added support for UOM columns in ReportTableClassView
** 11.01.06 AV     TI 2288: Monthly data locking several additions, see cvs log for full history
** 11.01.06 AV     TI 2769: Added support for MTH data classes starts in midle of month changes to Dataclass and ReportDataClassView view generation
** 07.02.06 DN     TI 3407: Procedure ObjectClassTriggerPackageBody modified to get the right processing id when a well is connected both to a facility and well hookup.
** 14.02.06 DN     TI 3467: Added findParentObjectId function to CreateGroupSyncPackage procedure.
** 03.03.06 DN     TI 3569: Added default p_id parameter to SafeBuild procedure.
** 23.03.06 AV     TI 3664: Added check in generation of ECTP package for well if wellhookup is not part of group model
** 04.05.06 AV     TI 3008: Changed check in DataClassViewIUTrg, Incuding object end date in check that daytime can not be greater than owner objects end date
** 16.05.06 AV     TI 3799: Fixed bug in DV view generation for data classes with timescope code Month
** 01.06.06 AV     TI 3859: Fixed bug in generation of the trigger packages SyncronizeFRomParent for nonGroupRelations
** 08.06.06 AV     TI 3823: Added ReportDataClassMthView to handle month RV views different from the rest. separated out common
**                         code from RV object class generation to use be able to reuse for data class without including parent rv_view.
**                         Changed  ReportDataClassView to use new functionality for Month Data classes
** 21.07.06 CHONGJER TI4171: Generation of monthly reporting views with unit conversion fails. Updated createReportOCColumnList.
** 26.09.06 LAU      TI 1898: Daytime/End date validation on data classes
** 27.09.06 LAU      TI 4357: Allow updating object_id without changing value
** 22.02.07 KAURRJES ECPD-5053: View generator fails for report classes
** 01.03.07 SIAH     ECPD-5147: Allow to add attribute 'CLASS_NAME' as a key in dv_tablename and jn_tablename
** 23.04.07 CHONGJER Updated procedure CreateObjectsVersionView to use varchar2a type to store dynamic sql statement.
** 25.04.07 HUS      ECPD-4908: Added calls to EcDp_ACL.RefreshObject in triggers; added calls to EcDp_VPD.GenPackage and EcDp_VPD.RefreshPolicies.
** 27.04.07 HUS      ECPD-4908: Miscellaneous bugfixes.
** 29.04.07 HUS      ECPD-4908: Add calls to EcDp_ACL.AssertAccess in object and data class IUD triggers
** 06.09.07 HUS      ECPD-6373: Added four-eyes-approval handling.
** 02.04.08 EMBONHAF ECPD-7945: Removed 2 from SafeBuild function call in ReportClassView
** 22.05.08 embonhaf ECPD-5527: Added check for classes with PRODUCTION_DAY attribute to ensure record can only be created if production_day is bigger than object start date and lesser than object end date.
** 17.02.09 leongsei ECPD-6067: Modified ObjectClassViewIUTrg, to pass in additioanl one parameter, n_object_id to EcDp_Month_lock.validatePeriodForLockOverlap
** 14.03.09 rajarsar ECPD-9038: Updated ObjectClassTriggerBody to replace with l_vt(j).prod_method with l_vt(j).calc_co2_method  and added support proc_node_co2_id and proc_node_co2_inj_id
** 30.07.30 Toha     ECPD-12381: CreateObjectsView to use varchar2a instead of varchar2
** 10.08.09 rajarsar ECPD-11890: Updated ObjectClassTriggerPackageBody to include only attributes that are enabled in class relations.
** 26.03.10 rajarsar ECPD-11223: Updated createReportDCColumnList and createReportOCColumnList
** 18.05.11 RJe      ECPD-16314: Updated InterfaceClassViewIUTrg to cope with large number of classes
** 28.11.11 WANGGDIE ECPD-18872: Improve ColumnExists() function.
** 16.04.12 RJe      ECPD-19511: Added EventView creator
** 26.07.12 Ghebrsem ECPD-21271: Remove assign REC_ID logic from class trigger, it will be handled by IUR table trigger
** 06.11.12 syazwnur ECPD-22426: Create new function ReplaceJNString to handle replacing table_name.
                                 Modified TableClassView, TableClassJNView, DataClassView and DataClassJNView to use varchar2a type to store dynamic sql statement.
** 20.03.13 Jenserun ECPD-23323: Revert/fix REC_ID logic from ECPD-21271
** 07.05.14 kumarsur ECPD-27564: Modify ObjectClassTriggerPackageBody on WELL section.
*****************************************************************/

-- Application Errors raised in code generated by this package.
-- Messages for these numbers are stored in t_basis_language.
--   20100 -   Insert not allowed.
--   20101 -   Update not allowed.
--   20102 -   Delete not allowed.
--   20103 -   Missing values.
--   20104 -   Illegal values
--   20105 -   Record already exists.
--   20106 -   Object not found.
--   20107 -   Invalid number.
--   20108 -   Dynamic parsing of sql failed.
--   20109 -   Illegal object start date.
--   20110 -   Illegal object end date.


syntax_error EXCEPTION;

CURSOR c_dao_class_attr(cp_class_name  VARCHAR2,
                cp_attribute_name VARCHAR2 DEFAULT NULL,
                cp_is_relation  VARCHAR2 DEFAULT NULL,
                cp_is_report_only VARCHAR2 DEFAULT 'N',
                cp_is_popup  VARCHAR2 DEFAULT 'N') IS
  SELECT  property_name attribute_name,
         data_type,
         is_key,
         is_mandatory,
         UPPER(LTRIM(RTRIM(Nvl(db_mapping_type,'X')))) db_mapping_type,
         db_sql_syntax,
         is_relation,
         is_relation_code,
         group_type,
         role_name,
         is_read_only,
         rel_class_name
   FROM dao_meta
   WHERE class_name = cp_class_name
   AND   property_name  = Nvl(cp_attribute_name,property_name )
   AND   Nvl(is_report_only,'N') = cp_is_report_only
   AND   is_popup = cp_is_popup
   AND   is_relation = Nvl(cp_is_relation,is_relation)
   ORDER BY sort_order nulls last,property_name;





TYPE t_varchar_list  IS TABLE OF VARCHAR2(32)
   INDEX BY BINARY_INTEGER;

TYPE t_attribute_rec IS RECORD
(     class_name                 class.class_name%TYPE,
      attribute_name             VARCHAR2(30),
      report_attribute_name      VARCHAR2(30),
      unit                       ctrl_uom_setup.unit%TYPE,
      measurement_type           ctrl_uom_setup.measurement_type%TYPE,
      db_sql_syntax          class_attr_db_mapping.db_sql_syntax%TYPE,
      is_relation            VARCHAR2(1)
);

TYPE t_attribute_list IS TABLE OF t_attribute_rec
   INDEX BY BINARY_INTEGER;


FUNCTION getSystemName
RETURN VARCHAR2
IS

CURSOR c_preference (p_pref_id IN VARCHAR2) IS
SELECT pref_verdi
FROM t_preferanse
WHERE pref_id = p_pref_id;


lv2_return_id t_preferanse.pref_id%TYPE;

BEGIN

   FOR lr_current IN c_preference('SYSNAM') LOOP

        lv2_return_id := lr_current.pref_verdi;

   END LOOP;

   RETURN lv2_return_id;

END getSystemName;

FUNCTION ReplaceJNString(p_input VARCHAR2, p_replace VARCHAR2)
RETURN VARCHAR2
IS

  lv2_temp varchar2(32000);

BEGIN

--Replace table_name
--Already handled:
--lv2_temp := REPLACE(p_input,CHR(10)||p_replace||'.',CHR(10)||p_replace ||'_JN.');
  lv2_temp := REPLACE(UPPER(p_input),' '||p_replace||'.',' '||p_replace||'_JN.');
  lv2_temp := REPLACE(lv2_temp,','||p_replace||'.',','||p_replace||'_JN.');
  lv2_temp := REPLACE(lv2_temp,'('||p_replace||'.','('||p_replace||'_JN.');
  lv2_temp := REPLACE(lv2_temp,' '||p_replace||',',' '||p_replace||'_JN,');
  lv2_temp := REPLACE(lv2_temp,' '||p_replace||' ',' '||p_replace||'_JN ');
  lv2_temp := REPLACE(lv2_temp,' '||p_replace||CHR(10),' '||p_replace||'_JN'||CHR(10));

  RETURN lv2_temp;

END ReplaceJNString;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : AddClassAttributList
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
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
PROCEDURE AddClassAttributList(p_attr_list        IN OUT t_attribute_list,
                          p_count            IN OUT NUMBER,
                          p_class_name       VARCHAR2,
                          p_attribute_name   VARCHAR2,
                          p_unit             VARCHAR2,
                          p_measurement_type VARCHAR2,
                          p_db_sql_syntax    VARCHAR2,
                          p_is_relation    VARCHAR2 DEFAULT 'N')
IS

  lv2_report_attr_name    VARCHAR2(50);
  ln_attr_length        NUMBER;

BEGIN

   p_count := p_count + 1;

   p_attr_list(p_count).class_name := p_class_name;
   p_attr_list(p_count).attribute_name := p_attribute_name;
   p_attr_list(p_count).db_sql_syntax := p_db_sql_syntax;
   p_attr_list(p_count).is_relation := p_is_relation;

   IF p_unit IS NOT NULL THEN

     lv2_report_attr_name := p_attribute_name||'_'||p_unit;
     ln_attr_length := LENGTH(lv2_report_attr_name);

     -- Ensure that the length of report_attribute_name is less than or equal 30 char.
     -- Try first to remove all vowels, if this is not enough the attribute_name is truncated.
     -- (To avoid this situation to occure; try to rename/abbrevaite the attribute_name or the unit.)

     IF ln_attr_length > 30 THEN
       lv2_report_attr_name := Replace(Translate(UPPER(lv2_report_attr_name),'AEIOU','u'),'u');
       ln_attr_length := LENGTH(lv2_report_attr_name);

       IF ln_attr_length > 30 THEN -- Not enought, need to trunc attribute_name
         lv2_report_attr_name := SUBSTR(p_attribute_name,1,LENGTH(p_attribute_name) - (ln_attr_length - 30) - LENGTH(TO_CHAR(p_count))) ||
                         TO_CHAR(p_count)||'_'||p_unit;
       END IF;

     END IF;

      p_attr_list(p_count).report_attribute_name := lv2_report_attr_name;
      p_attr_list(p_count).unit := p_unit;
      p_attr_list(p_count).measurement_type := p_measurement_type;
   ELSE
      p_attr_list(p_count).report_attribute_name := p_attribute_name;
   END IF;

END AddClassAttributList;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : InList
-- Description    : Returns true if target is found in the list, returns false otherwise.
--
-- Preconditions  :
-- Postcondition  :
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
FUNCTION InList(p_list t_varchar_list, p_target VARCHAR2)
RETURN BOOLEAN
--</EC-DOC>
IS
   lb_found       BOOLEAN := FALSE;
   ln_count       NUMBER := 1;
BEGIN

   WHILE NOT lb_found AND ln_count <= p_list.COUNT LOOP

      IF p_list(ln_count) = p_target THEN
         lb_found := TRUE;
      END IF;
      ln_count := ln_count + 1;
   END LOOP;

   RETURN lb_found;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FALSE;

END InList;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : getCurrentPackagerevision
-- Description    : Find current package revision from header
--
-- Preconditions  : Assumes ** $Revision: in package body header
-- Postcondition  :
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
FUNCTION getCurrentPackagerevision RETURN VARCHAR2
--</EC-DOC>

IS

CURSOR c_all_source IS
SELECT text
FROM all_source
WHERE UPPER(name) = 'ECDP_GENCLASSCODE'
AND  TYPE = 'PACKAGE BODY'
AND line < 10
AND text LIKE '%$Revision:%';

lv2_revision  VARCHAR2(4000);

BEGIN

    -- NOTYET  Consider using release label for the package ref CVS, but for now extract revision
    -- Maybe not the most elegant way to do it, so we might change it later
    -- it is also a question if it is more interesting to get the


    FOR cur_source IN c_all_source LOOP

      lv2_revision := SUBSTR(cur_source.text,INSTR(cur_source.text,'$')+1);  -- Copy from start of revision field

    END LOOP;

    RETURN SUBSTR(lv2_revision,1,INSTR(lv2_revision,'$')-1);

END getCurrentPackagerevision;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : GeneratedCodeMsg
-- Description    : Returns a string giving the package revision and daytime for generation
--
-- Preconditions  :
-- Postcondition  :
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
FUNCTION GeneratedCodeMsg RETURN VARCHAR2
--</EC-DOC>

IS


lv2_prog_statement   VARCHAR2(4000) := '-- Generated by EcDp_GenClassCode '||CHR(10);

BEGIN

    RETURN lv2_prog_statement;

END GeneratedCodeMsg;

FUNCTION GeneratedCodeMsg2 RETURN VARCHAR2

IS

BEGIN

    RETURN '-- Generated by EcDp_GenClassCode ';

END GeneratedCodeMsg2;

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
  lv2_searchstr VARCHAR2(1000);
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

     EcDp_dynsql.AddSqlLine(p_view_columns, p_new_column, 'Y'); -- Force Nowrapp


   END IF;

END AddUniqueViewColumns;


--<EC-DOC>
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
   lv2_owner            VARCHAR2(32);

BEGIN
   -- Remove Schema name from table_name, i.g remove EcKernel from EcKernel.Well
   ln_index := INSTR(p_table_name,'.');

   IF ln_index > 0 THEN
      lv2_table_name := SUBSTR(p_table_name,ln_index + 1);
   ELSE
      lv2_table_name := p_table_name;
   END IF;

   IF p_table_owner IS NULL THEN
      lv2_owner := replace(upper(user),'ENERGYX','ECKERNEL');
   ELSE
      lv2_owner := replace(p_table_owner,'ENERGYX','ECKERNEL');
   END IF;

   FOR curTable IN c_columnexists(lv2_table_name,p_column_name,lv2_owner) LOOP
        lb_exsists := TRUE;
   END LOOP;
   RETURN lb_exsists;
END ColumnExists;

--<EC-DOC>
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

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : createReportDataClassColumnList
-- Description    : Build SQL for report views colums on data classes, created as separate function
--                  to be able to reuse for different types of dataclass report views
--
-- Preconditions  : p_class_name must refer to a class of type 'DATA'
--
--
-- Postcondition  : Returns a string with all attributes and relations for given class.
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
PROCEDURE  createReportDCColumnList(lv2_sql_lines IN OUT DBMS_SQL.varchar2a, p_class_name varchar2 ,p_table_name VARCHAR2, p_schema_owner VARCHAR2, p_prod_day VARCHAR2,p_col_start VARCHAR2 DEFAULT 'N')
--</EC-DOC>

IS

   CURSOR c_class_attr IS
    SELECT ca.class_name,
           ca.attribute_name,
           ca.data_type,
           cadm.db_mapping_type,
           cadm.db_sql_syntax,
           cp.uom_code,
           cadm.sort_order
    FROM class_attribute ca, class_attr_db_mapping cadm, class_attr_presentation cp
    WHERE ca.class_name = cadm.class_name
    AND   ca.attribute_name = cadm.attribute_name
    AND   ca.class_name = cp.class_name(+)
    AND   ca.attribute_name = cp.attribute_name(+)
    AND   Nvl(ca.disabled_ind,'N') = 'N'
    AND   ca.class_name = p_class_name
    AND   NOT (ca.class_name = 'T_BASIS_USER' AND ca.attribute_name IN ('PASSWORD_LOGIN','PASSWORD_DB'))
 --   AND   ca.attribute_name NOT IN ('OBJECT_ID')
    ORDER BY cadm.sort_order;

   CURSOR c_attr_unit(cp_class_name VARCHAR2, cp_attribute_name VARCHAR2) IS
    SELECT cp.class_name,
          cp.attribute_name,
          u.db_unit_ind,
          u.unit,
          u.measurement_type
    FROM class_attr_presentation cp, ctrl_uom_setup u
    WHERE cp.uom_code = u.measurement_type
    AND  (u.report_unit_ind = 'Y' OR u.db_unit_ind = 'Y')
    AND  cp.class_name = cp_class_name
    AND  cp.attribute_name = cp_attribute_name;

   CURSOR c_class_relations IS
    SELECT cr.from_class_name,
          cr.to_class_name,
          cr.role_name,
          crdm.db_mapping_type,
          crdm.db_sql_syntax,
          crdm.sort_order
    FROM class_relation cr, class_rel_db_mapping crdm
    WHERE cr.from_class_name = crdm.from_class_name
    AND   cr.to_class_name = crdm.to_class_name
    AND   cr.role_name = crdm.role_name
    AND   cr.to_class_name = p_class_name
    AND   Nvl(cr.disabled_ind,'N') = 'N'
    AND   cr.group_type IS NULL
    ORDER BY sort_order;

   CURSOR c_column(cp_view_name  VARCHAR2,cp_column_name VARCHAR2 DEFAULT NULL) IS
   SELECT column_name
   FROM user_tab_cols
   WHERE table_name = cp_view_name
   AND   column_name = Nvl(cp_column_name,column_name);


   lv2_col                VARCHAR2(10000);
   lv2_attr_unit          VARCHAR2(100);
   lv2_column_name         VARCHAR2(30);
   ln_col_count           INTEGER;

BEGIN

      -- Get dataclass columns

    ln_col_count := 0;

     -- Add non relation attributes
    FOR curAttr IN c_class_attr LOOP

      IF curAttr.db_mapping_type = 'COLUMN' THEN

        lv2_col := p_table_name||'.'||curAttr.db_sql_syntax;

      ELSE

        lv2_col := curAttr.db_sql_syntax;

      END IF;

      lv2_attr_unit := NULL;

      IF curAttr.uom_code IS NOT NULL AND curAttr.data_type IN ('NUMBER','INTEGER') THEN
         -- Get database unit.
          lv2_attr_unit := EcDp_Unit.GetUnitFromLogical(curAttr.uom_code);

          IF lv2_attr_unit = curAttr.uom_code THEN -- clear attribute_unit if uom_code is an unit
            lv2_attr_unit := NULL;
          END IF;

      END IF;

      IF lv2_attr_unit IS NULL THEN

        IF Nvl(p_col_start,'N') = 'Y' AND ln_col_count  = 0 THEN

          AddUniqueViewColumns(lv2_sql_lines ,'  '||lv2_col||' AS '||curAttr.attribute_name);
          ln_col_count := 1;
        ELSE

          AddUniqueViewColumns(lv2_sql_lines ,' ,'||lv2_col||' AS '||curAttr.attribute_name);

        END IF;

      ELSIF lv2_attr_unit IS NOT NULL THEN  -- add unit conversion

          -- Trunc attribute name if attribute_<unit> > 30 characters
          lv2_column_name := UPPER(EcDB_Utils.TruncText(curAttr.attribute_name,30 - (LENGTH(lv2_attr_unit) + 1))||'_'||lv2_attr_unit);

          IF Nvl(p_col_start,'N') = 'Y' AND ln_col_count  = 0 THEN

              AddUniqueViewColumns(lv2_sql_lines ,'  '||lv2_col||' AS '||lv2_column_name);
              ln_col_count := 1;

          ELSE

              AddUniqueViewColumns(lv2_sql_lines ,' ,'||lv2_col||' AS '||lv2_column_name);

          END IF;


          FOR curUnit IN c_attr_unit(p_class_name, curAttr.attribute_name) LOOP

            lv2_column_name := UPPER(EcDB_Utils.TruncText(curAttr.attribute_name,30 - (LENGTH(curUnit.unit) + 1))||'_'||curUnit.unit);

            IF lv2_attr_unit <> curUnit.unit THEN

              lv2_col := ' ,EcDp_Unit.convertValue(';

              IF curAttr.db_mapping_type = 'COLUMN' THEN
                lv2_col := lv2_col||' '||p_table_name||'.'||curAttr.db_sql_syntax||',''';
              ELSIF curAttr.db_mapping_type = 'FUNCTION' THEN
                lv2_col := lv2_col||curAttr.db_sql_syntax||',''';
              END IF;

               lv2_col := lv2_col||lv2_attr_unit||''',''';
              lv2_col := lv2_col||curUnit.unit||''',';
              lv2_col := lv2_col||p_prod_day||',';

              lv2_col := lv2_col||Nvl(TO_CHAR(ec_ctrl_unit_conversion.precision(lv2_attr_unit,curUnit.unit,ecdp_date_time.getCurrentSysdate,'<=')),'NULL');

            IF (ecdp_classmeta.OwnerClassName(p_class_name) IS NOT NULL) THEN
              lv2_col := lv2_col||',NULL,';
              lv2_col := lv2_col||'NULL,';
              lv2_col :=  lv2_col||p_table_name||'.OBJECT_ID';
            END IF;

              AddUniqueViewColumns(lv2_sql_lines ,lv2_col||') AS '||lv2_column_name);

           END IF;

          END LOOP; -- curUnit

        END IF;

        lv2_col := NULL;

      END LOOP; -- curAttr IN c_class_attr

     -- Add relation attributes
     FOR curRel IN c_class_relations LOOP

       IF curRel.db_mapping_type = 'COLUMN' THEN


        IF Nvl(p_col_start,'N') = 'Y' AND ln_col_count  = 0 THEN

            AddUniqueViewColumns(lv2_sql_lines ,'  '||p_table_name||'.'||curRel.db_sql_syntax||' AS '||curRel.role_name||'_ID');
            ln_col_count := 1;

        ELSE

            AddUniqueViewColumns(lv2_sql_lines ,' ,'||p_table_name||'.'||curRel.db_sql_syntax||' AS '||curRel.role_name||'_ID');

        END IF;


         -- Use EcDp_Objects.GetObjCode if rel_class_name is interface
        IF EcDp_ClassMeta.GetClassType(curRel.from_class_name) = 'INTERFACE' THEN

          AddUniqueViewColumns(lv2_sql_lines ,' ,EcDp_Objects.GetObjCode('||p_table_name||'.'||curRel.db_sql_syntax||') AS '||curRel.role_name||'_CODE');

        ELSE -- Better performance in using ec-package

          AddUniqueViewColumns(lv2_sql_lines , ' ,'||EcDp_ClassMeta.GetEcPackage(curRel.from_class_name)||'.object_code('||p_table_name||'.'||curRel.db_sql_syntax||') AS '||curRel.role_name||'_CODE');

        END IF;



       ELSE

         AddUniqueViewColumns(lv2_sql_lines , ' ,'||curRel.db_sql_syntax||' AS '||curRel.role_name||'_ID');
         AddUniqueViewColumns(lv2_sql_lines ,' ,EcDp_Objects.GetObjCode('||curRel.db_sql_syntax||') AS '||curRel.role_name||'_CODE');

       END IF;


     END LOOP;

     AddUniqueViewColumns(lv2_sql_lines ,' ,'||p_table_name||'.RECORD_STATUS');
     AddUniqueViewColumns(lv2_sql_lines ,' ,'||p_table_name||'.CREATED_BY');
     AddUniqueViewColumns(lv2_sql_lines ,' ,'||p_table_name||'.CREATED_DATE');
     AddUniqueViewColumns(lv2_sql_lines ,' ,'||p_table_name||'.LAST_UPDATED_BY');
     AddUniqueViewColumns(lv2_sql_lines ,' ,'||p_table_name||'.LAST_UPDATED_DATE');
     AddUniqueViewColumns(lv2_sql_lines ,' ,'||p_table_name||'.REV_NO');
     AddUniqueViewColumns(lv2_sql_lines ,' ,'||p_table_name||'.REV_TEXT');

     AddUniqueViewColumns(lv2_sql_lines,','||AddSafeViewColumn(p_table_name,'APPROVAL_STATE',p_schema_owner,p_table_name||'.'));
     AddUniqueViewColumns(lv2_sql_lines,','||AddSafeViewColumn(p_table_name,'APPROVAL_BY',p_schema_owner,p_table_name||'.'));
     AddUniqueViewColumns(lv2_sql_lines,','||AddSafeViewColumn(p_table_name,'APPROVAL_DATE',p_schema_owner,p_table_name||'.'));
     AddUniqueViewColumns(lv2_sql_lines,','||AddSafeViewColumn(p_table_name,'REC_ID',p_schema_owner,p_table_name||'.'));

END createReportDCColumnList;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : getDataclassJoinDaytime
-- Description    : find the date column expression to be used in join with parent class
--
-- Preconditions  : p_class_name must refer to a class of type 'DATA'.
--
--
-- Postcondition  : Return a string with sql-syntax
-- Using Tables   : t_temptext
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior
-- Find what date column to use for production day, join with owner class and unit convertion
--
--  Join with parent class, one of the following table columns for the data class table will be choosen:
   --      1) use daytime (sub day resolution may be available on object version) if available
   --      2) use production_day or day column if availabel
   --      3) use start_date if available
   --      4) use class attribute (function) called PRODUCTION_DAY if available
   --      5) If none of the above can be found, dont join with owner class
---------------------------------------------------------------------------------------------------
FUNCTION getDataclassJoinDaytime(
   p_class_name       VARCHAR2
)
RETURN VARCHAR2
--</EC-DOC>
IS

  CURSOR c_class IS
     SELECT c.owner_class_name,c.time_scope_code,cm.db_object_name,cm.db_where_condition
     FROM class c, class_db_mapping cm
     WHERE c.class_name = cm.class_name
     AND c.class_name = p_class_name;


  lv2_join_daytime  VARCHAR2(1000);
  lv2_table_name    VARCHAR2(50);

BEGIN

   FOR curClass IN c_class LOOP
      lv2_table_name := LOWER(curClass.db_object_name);
   END LOOP;

   lv2_join_daytime := NULL;

   -- 1) use daytime (sub day resolution may be available on object version) if available

   lv2_join_daytime := EcDp_ClassMeta.GetClassAttrDbSqlSyntax(p_class_name,'DAYTIME');

   IF  lv2_join_daytime IS NOT NULL THEN

     IF NOT Ecdp_ClassMeta.isfunction(p_class_name, 'DAYTIME' ) THEN   -- Add table prefix

        lv2_join_daytime := lv2_table_name ||'.'||lv2_join_daytime;

     END IF;

   ELSE  --step 2-5

     -- 2) use production_day or day column if availabel

     lv2_join_daytime := EcDp_ClassMeta.GetClassAttrDbSqlSyntax(p_class_name,'PRODUCTION_DAY');


     IF Nvl(lv2_join_daytime,'X') IN ('PRODUCTION_DAY', 'DAY','EVENT_DAY')     THEN

        lv2_join_daytime :=  lv2_table_name ||'.'||lv2_join_daytime;

     ELSE  --step 3-5

       --  3) use start_date if available

       IF EcDp_ClassMeta.HasTableColumn(lv2_table_name,'START_DATE') THEN

          lv2_join_daytime :=  lv2_table_name ||'.start_date';

       END IF;  -- step 3


         --  4) use class attribute (function) called PRODUCTION_DAY if available
         --  5) If none of the above can be found, return null.

         -- step 4 and 5 is allready covered by the code over.

     END IF; --step 3-5


   END IF;  --step 2-5

   RETURN lv2_join_daytime;

END getDataclassJoinDaytime;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : getDataclassProductionDay
-- Description    : find the production day syntax to use for a data class in report view
--
-- Preconditions  : p_class_name must refer to a class of type 'DATA'.
--
--
-- Postcondition  : Return a string with sql-syntax
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior
-- Find what date column to use for production day, join with owner class and unit convertion
--
--  Join with parent class, one of the following table columns for the data class table will be choosen:
   --      1) use production_day class definition if available
   --      2) use production day column from table if  availabele
   --      3) use day column from table if  availabele
   --      4) use trunc daytime/trunc(daytime) from table if available
   --      5) If none of the above can be found, return NULL
---------------------------------------------------------------------------------------------------
FUNCTION getDataclassProductionDay(
   p_class_name       VARCHAR2
)
RETURN VARCHAR2
--</EC-DOC>
IS

  CURSOR c_class IS
     SELECT c.owner_class_name,c.time_scope_code,cm.db_object_name,cm.db_where_condition
     FROM class c, class_db_mapping cm
     WHERE c.class_name = cm.class_name
     AND c.class_name = p_class_name;


  lv2_prod_daytime  VARCHAR2(1000);
  lv2_time_scope_code  VARCHAR2(100);
  lv2_table_name    VARCHAR2(50);

BEGIN

   FOR curClass IN c_class LOOP
      lv2_table_name := LOWER(curClass.db_object_name);
      lv2_time_scope_code := UPPER(curclass.time_scope_code);
   END LOOP;

   lv2_prod_daytime := NULL;

   -- 1) use daytime (sub day resolution may be available on object version) if available

   lv2_prod_daytime := EcDp_ClassMeta.GetClassAttrDbSqlSyntax(p_class_name,'PRODUCTION_DAY');

   IF  lv2_prod_daytime IS NOT NULL THEN

     IF NOT Ecdp_ClassMeta.isfunction(p_class_name, 'PRODUCTION_DAY' ) THEN   -- Add table prefix

        lv2_prod_daytime := lv2_table_name ||'.'||lv2_prod_daytime;

     END IF;

   ELSE  --step 2-5

     -- 2) use production_day or day column if availabel
     IF EcDp_ClassMeta.HasTableColumn(lv2_table_name,'PRODUCTION_DAY') THEN

       lv2_prod_daytime := lv2_table_name ||'.PRODUCTION_DAY';

     ELSIF EcDp_ClassMeta.HasTableColumn(lv2_table_name,'DAY') THEN

       lv2_prod_daytime := lv2_table_name ||'.DAY';

     ELSIF EcDp_ClassMeta.HasTableColumn(lv2_table_name,'EVENT_DAY') THEN

       lv2_prod_daytime := lv2_table_name ||'.EVENT_DAY';

     ELSE  --step 3-5

       --  3) use daytime or start_date if available

       lv2_prod_daytime := EcDp_ClassMeta.GetClassAttrDbSqlSyntax(p_class_name,'DAYTIME');

       IF  lv2_prod_daytime IS NOT NULL THEN

         IF NOT Ecdp_ClassMeta.isfunction(p_class_name, 'DAYTIME' ) THEN   -- Add table prefix

            lv2_prod_daytime := lv2_table_name ||'.'||lv2_prod_daytime;

         END IF;

       ELSE


         IF EcDp_ClassMeta.HasTableColumn(lv2_table_name,'DAYTIME') THEN

           IF NOT lv2_time_scope_code IN ('1HR','SUB_DAY') THEN

              lv2_prod_daytime :=  lv2_table_name ||'.daytime';

           ELSE

              lv2_prod_daytime :=  'trunc('||lv2_table_name ||'.daytime'||',''DD'')';

           END IF;

         ELSIF  EcDp_ClassMeta.HasTableColumn(lv2_table_name,'START_DATE') THEN

             lv2_prod_daytime :=  lv2_table_name ||'.start_date';

         END IF;  -- step 3


           --  5) If none of the above can be found, return null.

           -- step 4 and 5 is allready covered by the code over.

       END IF; --step 3-5

     END IF;

   END IF;  --step 2-5

   RETURN lv2_prod_daytime;

END getDataclassProductionDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : getDataclassSystemDayJoin
-- Description    : Returns the where clause to join with system days, if criterias are met,
--                  otherwise return null to signal that the join should not be done.
--
-- Preconditions  : p_class_name must refer to a class of type 'DATA'.
--
--
-- Postcondition  : Return a string with sql-syntax
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior
-- First check the timescope code
--
--  Then try to resolve the data period, class must have an end_date attribute
--  For start of period the the first available attributes from the list under will be used:
--
--      1) use DAYTIME if available
--      2) use PRODUCTION_DAY if available
--      3) use VALID_FROM_DATE if availabele


---------------------------------------------------------------------------------------------------
FUNCTION getDataclassSystemDayJoin(
   p_class_name       VARCHAR2
)
RETURN VARCHAR2
--</EC-DOC>
IS

  CURSOR c_class IS
     SELECT c.owner_class_name,c.time_scope_code,cm.db_object_name,cm.db_where_condition
     FROM class c, class_db_mapping cm
     WHERE c.class_name = cm.class_name
     AND c.class_name = p_class_name;


  lv2_where            VARCHAR2(1000);
  lv2_time_scope_code  VARCHAR2(100);
  lv2_table_name       VARCHAR2(50);
  lv2_start            VARCHAR2(1000);
  lv2_end              VARCHAR2(1000);


BEGIN

   FOR curClass IN c_class LOOP
      lv2_table_name := LOWER(curClass.db_object_name);
      lv2_time_scope_code := UPPER(curclass.time_scope_code);
   END LOOP;


   IF lv2_time_scope_code = 'EVENT_CONTINUES' THEN

     lv2_end := EcDp_ClassMeta.GetClassAttrDbSqlSyntax(p_class_name,'END_DATE');

     IF lv2_end IS NOT NULL THEN

       IF NOT Ecdp_ClassMeta.isfunction(p_class_name, 'END_DATE' ) THEN   -- Add table prefix

          lv2_end := lv2_table_name ||'.'||lv2_end;

       END IF;

       -- IF end_date is NULL take until sysdate

       lv2_end := 'NVL('||lv2_end||',ecdp_date_time.getcurrentsysdate)' ;


       -- Try DAYTIME

       lv2_start := EcDp_ClassMeta.GetClassAttrDbSqlSyntax(p_class_name,'DAYTIME');

       IF  lv2_start IS NOT NULL THEN

          IF NOT Ecdp_ClassMeta.isfunction(p_class_name, 'DAYTIME' ) THEN   -- Add table prefix

            lv2_start := lv2_table_name ||'.'||lv2_start;

          END IF;


       ELSE -- Try Production day

         lv2_start := EcDp_ClassMeta.GetClassAttrDbSqlSyntax(p_class_name,'PRODUCTION_DAY');

         IF  lv2_start IS NOT NULL THEN

            IF NOT Ecdp_ClassMeta.isfunction(p_class_name, 'PRODUCTION_DAY' ) THEN   -- Add table prefix

              lv2_start := lv2_table_name ||'.'||lv2_start;

            END IF;

         ELSE -- Try valid_from_date

           lv2_start := EcDp_ClassMeta.GetClassAttrDbSqlSyntax(p_class_name,'VALID_FROM_DATE');

           IF  lv2_start IS NOT NULL THEN

              IF NOT Ecdp_ClassMeta.isfunction(p_class_name, 'VALID_FROM_DATE' ) THEN   -- Add table prefix

                lv2_start := lv2_table_name ||'.'||lv2_start;

              END IF;

           END IF; -- Try valid_from_date

         END IF;   -- Try valid_from_date

       END IF; -- Try Production day

       IF lv2_start IS NOT NULL THEN

         lv2_where := ' s.daytime >= '||lv2_start||' AND s.daytime < '||lv2_end ;

       ELSE

         lv2_where := NULL;

       END IF;


     ELSE -- lv2_end IS NULL

       lv2_where := NULL;

     END IF;  -- lv2_end IS NOT NULL

   ELSE  -- lv2_time_scope_code <> 'EFFECTIVE' THEN

     lv2_where := NULL;

   END IF;


   RETURN lv2_where;

END getDataclassSystemDayJoin;




--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : SafeBuild
-- Description    : Compile or write view to t_temptext for script building
--
-- Preconditions  : All sql comes with CREATE OR REPLACE statement (VIEWS, TRIGGERS, PACKAGES)
-- Postcondition  : Checks that view code compiles before existing view is replaced
--
-- Using Tables   :
--
-- Using functions: WriteTempText
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE SafeBuild(p_object_name VARCHAR2,
                    p_object_type VARCHAR2,
                    p_sql         VARCHAR2,
                    p_target      VARCHAR2 DEFAULT 'CREATE',
                    p_sql2        VARCHAR2 DEFAULT '',
                    p_id          VARCHAR2 DEFAULT 'GENCODE')
--</EC-DOC>

IS
  lv2_sql         VARCHAR2(32000) := NULL;
  lb_continue     BOOLEAN;
  lv2_dummyname   VARCHAR2(30);
  lv2_sql2      VARCHAR2(1000);
  ln_split      NUMBER;

  CURSOR c_user_object_status(cp_object_name VARCHAR2, cp_object_type VARCHAR2) IS
  SELECT status FROM user_objects
  WHERE object_name = UPPER(cp_object_name)
  AND   object_type = cp_object_type;


BEGIN

    IF p_target = 'CREATE' THEN -- create the view

      IF p_object_type IN ('VIEW','TRIGGER')  THEN

        -- First check if object compiles without error
        -- Need to drop dummy object if it exists

           lv2_dummyname := 'XX'||SUBSTR(p_object_name,1,28);

           FOR cur_object_status IN c_user_object_status(lv2_dummyname, p_object_type) LOOP

             lv2_sql := 'DROP '||p_object_type||' '||lv2_dummyname;

           END LOOP;

           IF lv2_sql IS NOT NULL THEN
              EXECUTE IMMEDIATE lv2_sql;
           END IF;

         ln_split := INSTR(p_sql,p_object_name) + LENGTH(p_object_name) - 1;
         lv2_sql2 := SUBSTR(p_sql,1,ln_split);
         lv2_sql :=  SUBSTR(p_sql,ln_split + 1);
           lv2_sql2 := REPLACE(lv2_sql2,p_object_name,lv2_dummyname);
           lv2_sql := lv2_sql2||lv2_sql;
           lb_continue := FALSE;

           EXECUTE IMMEDIATE lv2_sql||p_sql2;

           FOR cur_object_status IN c_user_object_status(lv2_dummyname, p_object_type) LOOP

             IF cur_object_status.status = 'VALID' THEN
               lb_continue := TRUE;
             ELSE
               lb_continue := FALSE;
             END IF;

           END LOOP;

           IF lb_continue THEN

             lv2_sql := 'DROP '||p_object_type||' '||lv2_dummyname;

              EXECUTE IMMEDIATE lv2_sql;

              EXECUTE IMMEDIATE p_sql||p_sql2;


           ELSE
              RAISE syntax_error;
           END IF;

        ELSE

              EXECUTE IMMEDIATE p_sql||p_sql2;

        END IF;




    ELSE -- insert in t_temptext

         IF p_sql2 IS NULL THEN

            EcDp_DynSql.WriteTempText(p_id, p_sql || CHR(10) || '/');

         ELSE

            EcDp_DynSql.WriteTempText(p_id, p_sql );
            EcDp_DynSql.WriteTempText(p_id, p_sql2 || CHR(10) || '/');

         END IF;

    END IF;


EXCEPTION

     WHEN OTHERS THEN
         EcDp_DynSql.WriteTempText(p_id || 'ERROR','Syntax error generating '||p_object_type ||' for '||p_object_name||CHR(10)||SQLERRM||CHR(10)|| p_sql);

END SafeBuild;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : ObjectClassView
-- Description    : Generate a view based on a class definition of type OBJECT
--
-- Preconditions  : p_class_name must refer to a class of type OBJECT
--                  Class_attribute and class_attr_db_mapping must be configured for class.
--                  Related classes defined in class_relation.
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
PROCEDURE ObjectClassView(
   p_class_name  VARCHAR2,
   p_daytime     DATE,
   p_target      VARCHAR2 DEFAULT 'CREATE'
)
--</EC-DOC>
IS

  CURSOR c_dao_class_attr IS
   SELECT  property_name attribute_name,
         role_name,
         data_type,
         is_key,
         is_mandatory,
         UPPER(LTRIM(RTRIM(Nvl(db_mapping_type,'X')))) db_mapping_type,
         db_sql_syntax,
         is_relation,
         rel_class_name,
         group_type
  FROM dao_meta
  WHERE class_name = p_class_name
  AND   is_popup = 'N'
  AND   NOT (is_relation_code = 'Y' AND group_type IS NULL) -- ignore relation code
  AND   Nvl(is_report_only,'N') = 'N'
  ORDER BY sort_order nulls last,property_name;

  CURSOR c_table_cols(cp_table_name VARCHAR2) IS
   SELECT column_name
   FROM user_tab_cols
   WHERE table_name = cp_table_name
   ORDER BY column_id;

  lv2_sql                  VARCHAR2(32000);
  lv2_cols                  VARCHAR2(32000);
  lv2_cols_jn                VARCHAR2(32000);
  lv2_ver_cols               VARCHAR2(32000);
  lv2_main_cols              VARCHAR2(32000);
  lv2_ue_user_function               VARCHAR2(1);
  lv2_main_table              class_db_mapping.db_object_name%TYPE;
  lv2_version_table            class_db_mapping.db_object_attribute%TYPE;
  lv2_schema_owner            class_db_mapping.db_object_owner%TYPE;
  lv2_main_table_where          class_db_mapping.db_where_condition%TYPE;
  lv2_class_type             class.class_type%TYPE := EcDp_ClassMeta.GetClassType(p_class_name);

BEGIN

  IF Nvl(lv2_class_type,'X') <> 'OBJECT' THEN

    EcDp_DynSql.WriteTempText('GENCODEERROR','Cannot generate object view for a class with class type '||lv2_class_type);
    RETURN;

  END IF;

  FOR curClass IN EcDp_ClassMeta.c_classes(p_class_name) LOOP
    lv2_main_table := curClass.db_object_name;
    lv2_version_table := curClass.db_object_attribute;
    lv2_schema_owner := curClass.db_object_owner;
    lv2_main_table_where := curClass.db_where_condition;

  END LOOP;

  lv2_ue_user_function := EcDp_ClassMeta.IsUsingUserFunction();

  -- Create view columns
  lv2_cols := ''''||p_class_name||''' AS CLASS_NAME'||CHR(10);

  FOR curAttr IN c_dao_class_attr LOOP

    IF curAttr.db_mapping_type = 'COLUMN' THEN

      lv2_cols := lv2_cols||',o.'||curAttr.db_sql_syntax||' AS '||curAttr.attribute_name||CHR(10);

      IF curAttr.is_relation = 'Y' AND curAttr.group_type IS NULL THEN -- add relation code

        -- Use EcDp_Objects.GetObjCode if rel_class_name is interface
        IF EcDp_ClassMeta.GetClassType(curAttr.rel_class_name) = 'INTERFACE' THEN

          lv2_cols := lv2_cols||',EcDp_Objects.GetObjCode(o.'||curAttr.db_sql_syntax||') AS '||curAttr.role_name||'_CODE'||CHR(10);

        ELSE -- Better performance in using ec-package

          lv2_cols := lv2_cols||','||EcDp_ClassMeta.GetEcPackage(curAttr.rel_class_name)||'.object_code(o.'||curAttr.db_sql_syntax||') AS '||curAttr.role_name||'_CODE'||CHR(10);

        END IF;

      END IF;

    ELSIF curAttr.db_mapping_type = 'ATTRIBUTE' THEN

      lv2_cols := lv2_cols||',oa.'||curAttr.db_sql_syntax||' AS '||curAttr.attribute_name||CHR(10);

      IF curAttr.is_relation = 'Y' AND curAttr.group_type IS NULL THEN -- add relation code

        IF EcDp_ClassMeta.GetClassType(curAttr.rel_class_name) = 'INTERFACE' THEN

          lv2_cols := lv2_cols||',EcDp_Objects.GetObjCode(oa.'||curAttr.db_sql_syntax||') AS '||curAttr.role_name||'_CODE'||CHR(10);

        ELSE

          lv2_cols := lv2_cols||','||EcDp_ClassMeta.GetEcPackage(curAttr.rel_class_name)||'.object_code(oa.'||curAttr.db_sql_syntax||') AS '||curAttr.role_name||'_CODE'||CHR(10);

        END IF;

      END IF;

    ELSIF curAttr.db_mapping_type = 'FUNCTION' THEN

      lv2_cols := lv2_cols||','||curAttr.db_sql_syntax||' AS '||curAttr.attribute_name||CHR(10);

      IF curAttr.is_relation = 'Y' AND curAttr.group_type IS NULL THEN -- add relation code

        -- Use EcDp_Objects.GetObjCode if rel_class_name is interface
        IF EcDp_ClassMeta.GetClassType(curAttr.rel_class_name) = 'INTERFACE' THEN

          lv2_cols := lv2_cols||',EcDp_Objects.GetObjCode('||curAttr.db_sql_syntax||') AS '||curAttr.role_name||'_CODE'||CHR(10);

        ELSE -- Better performance in using ec-package

          lv2_cols := lv2_cols||','||EcDp_ClassMeta.GetEcPackage(curAttr.rel_class_name)||'.object_code('||curAttr.db_sql_syntax||') AS '||curAttr.role_name||'_CODE'||CHR(10);

        END IF;

      END IF;

    END IF;



  END LOOP;

     -- Add standard record information columns
     lv2_cols := lv2_cols||',oa.record_status AS RECORD_STATUS'||CHR(10);

           if lv2_ue_user_function = 'N' then
                       lv2_cols := lv2_cols||',oa.created_by AS CREATED_BY'||CHR(10);

           else

                       lv2_cols := lv2_cols||',ue_user.getusername(oa.created_by) AS CREATED_BY'||CHR(10);

           end if;
     lv2_cols := lv2_cols||',oa.created_date AS CREATED_DATE'||CHR(10);

           if lv2_ue_user_function = 'N' then
                       lv2_cols := lv2_cols||',decode(sign(nvl(o.last_updated_date,o.created_date)-nvl(oa.last_updated_date,oa.created_date)),1,o.last_updated_by,oa.last_updated_by) AS LAST_UPDATED_BY'||CHR(10);

           else

                       lv2_cols := lv2_cols||',ue_user.getusername(decode(sign(nvl(o.last_updated_date,o.created_date)-nvl(oa.last_updated_date,oa.created_date)),1,o.last_updated_by,oa.last_updated_by)) AS LAST_UPDATED_BY'||CHR(10);

           end if;

    lv2_cols := lv2_cols||',decode(sign(nvl(o.last_updated_date,o.created_date)-nvl(oa.last_updated_date,oa.created_date)),1,o.last_updated_date,oa.last_updated_date) AS LAST_UPDATED_DATE'||CHR(10);
  lv2_cols := lv2_cols||',o.rev_no||''.''||oa.rev_no AS REV_NO'||CHR(10);
  lv2_cols := lv2_cols||',decode(sign(nvl(o.last_updated_date,o.created_date)-nvl(oa.last_updated_date,oa.created_date)),1,o.rev_text,oa.rev_text) AS REV_TEXT'||CHR(10);

  lv2_cols := lv2_cols||','||AddSafeViewColumn(lv2_version_table,'approval_state',lv2_schema_owner,'oa.')||CHR(10);
  lv2_cols := lv2_cols||','||AddSafeViewColumn(lv2_version_table,'approval_by',lv2_schema_owner,'oa.')||CHR(10);
  lv2_cols := lv2_cols||','||AddSafeViewColumn(lv2_version_table,'approval_date',lv2_schema_owner,'oa.')||CHR(10);
  lv2_cols := lv2_cols||','||AddSafeViewColumn(lv2_version_table,'rec_id',lv2_schema_owner,'oa.')||CHR(10);

  -- Create view
  lv2_sql :=         'CREATE OR REPLACE VIEW OV_'||p_class_name||' AS'||CHR(10);
  lv2_sql :=lv2_sql||'SELECT'||CHR(10);
  lv2_sql :=lv2_sql||GeneratedCodeMsg;
  lv2_sql :=lv2_sql||lv2_cols;
  lv2_sql :=lv2_sql||'FROM '||lv2_version_table||' oa, '||lv2_main_table||' o'||CHR(10);
  lv2_sql :=lv2_sql||'WHERE oa.object_id = o.object_id'||CHR(10);

  IF lv2_main_table_where IS NOT NULL THEN

    lv2_sql :=lv2_sql||'AND '||lv2_main_table_where||CHR(10);

  END IF;

  -- Build View
  SafeBuild('OV_'||p_class_name,'VIEW',lv2_sql,p_target);



EXCEPTION

  WHEN OTHERS THEN
     EcDp_DynSql.WriteTempText('GENCODEERROR','Syntax error generating view for '||p_class_name||CHR(10)||SQLERRM||CHR(10)||lv2_sql);



END ObjectClassView;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : ObjectClassJNView
-- Description    : Generate a view based on a class definition of type OBJECT
--
-- Preconditions  : p_class_name must refer to a class of type OBJECT
--                  Class_attribute and class_attr_db_mapping must be configured for class.
--                  Related classes defined in class_relation.
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
PROCEDURE ObjectClassJNView(
   p_class_name  VARCHAR2,
   p_daytime     DATE,
   p_target      VARCHAR2 DEFAULT 'CREATE'
)
--</EC-DOC>
IS

  CURSOR c_dao_class_attr IS
   SELECT  property_name attribute_name,
         role_name,
         data_type,
         is_key,
         is_mandatory,
         UPPER(LTRIM(RTRIM(Nvl(db_mapping_type,'X')))) db_mapping_type,
         db_sql_syntax,
         is_relation,
         rel_class_name,
         group_type
  FROM dao_meta
  WHERE class_name = p_class_name
  AND   is_popup = 'N'
  AND   NOT (is_relation_code = 'Y' AND group_type IS NULL) -- ignore relation code
  AND   Nvl(is_report_only,'N') = 'N'
  ORDER BY sort_order nulls last,property_name;

  CURSOR c_table_cols(cp_table_name VARCHAR2) IS
   SELECT column_name
   FROM user_tab_cols
   WHERE table_name = cp_table_name
   ORDER BY column_id;

  lv2_sql                  VARCHAR2(32000);
  lv2_cols                  VARCHAR2(32000);
  lv2_cols_jn                VARCHAR2(32000);
  lv2_ver_cols               VARCHAR2(32000);
  lv2_main_cols              VARCHAR2(32000);
  lv2_ue_user_function                                            VARCHAR2(1);
  lv2_main_table              class_db_mapping.db_object_name%TYPE;
  lv2_version_table            class_db_mapping.db_object_attribute%TYPE;
  lv2_schema_owner            class_db_mapping.db_object_owner%TYPE;
  lv2_main_table_where          class_db_mapping.db_where_condition%TYPE;
  lv2_class_type             class.class_type%TYPE := EcDp_ClassMeta.GetClassType(p_class_name);
  lb_has_approval_state     BOOLEAN:=FALSE;
  lb_has_approval_by        BOOLEAN:=FALSE;
  lb_has_approval_date      BOOLEAN:=FALSE;
  lb_has_rec_id             BOOLEAN:=FALSE;
BEGIN

  IF Nvl(lv2_class_type,'X') <> 'OBJECT' THEN

    EcDp_DynSql.WriteTempText('GENCODEERROR','Cannot generate object view for a class with class type '||lv2_class_type);
    RETURN;

  END IF;

  FOR curClass IN EcDp_ClassMeta.c_classes(p_class_name) LOOP

    lv2_main_table := curClass.db_object_name;
    lv2_version_table := curClass.db_object_attribute;
    lv2_schema_owner := curClass.db_object_owner;
    lv2_main_table_where := curClass.db_where_condition;

  END LOOP;

  -- Create view columns

  lv2_cols := ''''||p_class_name||''' AS CLASS_NAME'||CHR(10);

  FOR curAttr IN c_dao_class_attr LOOP

    IF curAttr.db_mapping_type = 'COLUMN' THEN

      lv2_cols := lv2_cols||',o.'||curAttr.db_sql_syntax||' AS '||curAttr.attribute_name||CHR(10);

      IF curAttr.is_relation = 'Y' AND curAttr.group_type IS NULL THEN -- add relation code

        -- Use EcDp_Objects.GetObjCode if rel_class_name is interface
        IF EcDp_ClassMeta.GetClassType(curAttr.rel_class_name) = 'INTERFACE' THEN

          lv2_cols := lv2_cols||',EcDp_Objects.GetObjCode(o.'||curAttr.db_sql_syntax||') AS '||curAttr.role_name||'_CODE'||CHR(10);

        ELSE -- Better performance in using ec-package

          lv2_cols := lv2_cols||','||EcDp_ClassMeta.GetEcPackage(curAttr.rel_class_name)||'.object_code(o.'||curAttr.db_sql_syntax||') AS '||curAttr.role_name||'_CODE'||CHR(10);

        END IF;

      END IF;

    ELSIF curAttr.db_mapping_type = 'ATTRIBUTE' THEN

      lv2_cols := lv2_cols||',oa.'||curAttr.db_sql_syntax||' AS '||curAttr.attribute_name||CHR(10);

      IF curAttr.is_relation = 'Y' AND curAttr.group_type IS NULL THEN -- add relation code

        IF EcDp_ClassMeta.GetClassType(curAttr.rel_class_name) = 'INTERFACE' THEN

          lv2_cols := lv2_cols||',EcDp_Objects.GetObjCode(oa.'||curAttr.db_sql_syntax||') AS '||curAttr.role_name||'_CODE'||CHR(10);

        ELSE

          lv2_cols := lv2_cols||','||EcDp_ClassMeta.GetEcPackage(curAttr.rel_class_name)||'.object_code(oa.'||curAttr.db_sql_syntax||') AS '||curAttr.role_name||'_CODE'||CHR(10);

        END IF;

      END IF;

    ELSIF curAttr.db_mapping_type = 'FUNCTION' AND Nvl(curAttr.is_key,'N') <> 'Y' THEN    --NOT curAttr.attribute_name IN ('OBJECT_ID') THEN


              IF curAttr.Data_type = 'DATE' THEN

                 lv2_cols := lv2_cols||', to_date(NULL)  AS '||curAttr.attribute_name||CHR(10);

              ELSIF   curAttr.Data_type IN ('NUMBER','INTEGER') THEN

               lv2_cols := lv2_cols||', to_number(NULL)  AS '||curAttr.attribute_name||CHR(10);

              ELSE

               lv2_cols := lv2_cols||', to_char(NULL)  AS '||curAttr.attribute_name||CHR(10);

              END IF;

              IF curAttr.is_relation = 'Y' AND curAttr.group_type IS NULL THEN -- add relation code

        IF EcDp_ClassMeta.GetClassType(curAttr.rel_class_name) = 'INTERFACE' THEN

          lv2_cols := lv2_cols||',EcDp_Objects.GetObjCode('||curAttr.db_sql_syntax||') AS '||curAttr.role_name||'_CODE'||CHR(10);

        ELSE

          lv2_cols := lv2_cols||','||EcDp_ClassMeta.GetEcPackage(curAttr.rel_class_name)||'.object_code('||curAttr.db_sql_syntax||') AS '||curAttr.role_name||'_CODE'||CHR(10);

        END IF;

      END IF;

       ELSE

      lv2_cols := lv2_cols||', '||curAttr.db_sql_syntax||' AS '||curAttr.attribute_name||CHR(10);

    END IF;

  END LOOP;

  -- Add standard record information columns

  lv2_ue_user_function := EcDp_ClassMeta.IsUsingUserFunction();

  lv2_cols := lv2_cols||',oa.record_status AS RECORD_STATUS'||CHR(10);

  if lv2_ue_user_function = 'N' then

       lv2_cols := lv2_cols||',oa.created_by AS CREATED_BY'||CHR(10);

    else

       lv2_cols := lv2_cols||',ue_user.getusername(oa.created_by) AS CREATED_BY'||CHR(10);

        end if;

  lv2_cols := lv2_cols||',oa.created_date AS CREATED_DATE'||CHR(10);

    if lv2_ue_user_function = 'N' then

       lv2_cols := lv2_cols||',decode(sign(nvl(o.last_updated_date,o.created_date)-nvl(oa.last_updated_date,oa.created_date)),1,o.last_updated_by,oa.last_updated_by) AS LAST_UPDATED_BY'||CHR(10);

    else

       lv2_cols := lv2_cols||',ue_user.getusername(decode(sign(nvl(o.last_updated_date,o.created_date)-nvl(oa.last_updated_date,oa.created_date)),1,o.last_updated_by,oa.last_updated_by)) AS LAST_UPDATED_BY'||CHR(10);

    end if;

  lv2_cols := lv2_cols||',decode(sign(nvl(o.last_updated_date,o.created_date)-nvl(oa.last_updated_date,oa.created_date)),1,o.last_updated_date,oa.last_updated_date) AS LAST_UPDATED_DATE'||CHR(10);
  lv2_cols := lv2_cols||',o.rev_no||''.''||oa.rev_no AS REV_NO'||CHR(10);
  lv2_cols := lv2_cols||',decode(sign(nvl(o.last_updated_date,o.created_date)-nvl(oa.last_updated_date,oa.created_date)),1,o.rev_text,oa.rev_text) AS REV_TEXT'||CHR(10);


  /*  ASSUMPTION:
   *
   *   The VERSION and VERSION_JN tables are in sync wrt approval columns. I.e. An approval column will be in
   *   both tables or none of the tables.
   *   column,
   */

  lb_has_approval_state := ColumnExists(lv2_version_table,'approval_state',lv2_schema_owner);
  lb_has_approval_by := ColumnExists(lv2_version_table,'approval_by',lv2_schema_owner);
  lb_has_approval_date := ColumnExists(lv2_version_table,'approval_date',lv2_schema_owner);
  lb_has_rec_id := ColumnExists(lv2_version_table,'rec_id',lv2_schema_owner);

  IF lb_has_approval_state THEN
     lv2_cols := lv2_cols||',oa.approval_state AS APPROVAL_STATE'||CHR(10);
  ELSE
     lv2_cols := lv2_cols||',null AS APPROVAL_STATE'||CHR(10);
  END IF;
  IF lb_has_approval_by THEN
     lv2_cols := lv2_cols||',oa.approval_by AS APPROVAL_BY'||CHR(10);
  ELSE
     lv2_cols := lv2_cols||',null AS APPROVAL_BY'||CHR(10);
  END IF;
  IF lb_has_approval_date THEN
     lv2_cols := lv2_cols||',oa.approval_date AS APPROVAL_DATE'||CHR(10);
  ELSE
     lv2_cols := lv2_cols||',null AS APPROVAL_DATE'||CHR(10);
  END IF;
  IF lb_has_rec_id THEN
     lv2_cols := lv2_cols||',oa.rec_id AS REC_ID'||CHR(10);
  ELSE
     lv2_cols := lv2_cols||',null AS REC_ID'||CHR(10);
  END IF;

  /** No longer in use
  -- Create view
  lv2_sql :=         'CREATE OR REPLACE VIEW OV_'||p_class_name||' AS'||CHR(10);
  lv2_sql :=lv2_sql||'SELECT'||CHR(10);
  lv2_sql :=lv2_sql||GeneratedCodeMsg;
  lv2_sql :=lv2_sql||lv2_cols;
  lv2_sql :=lv2_sql||'FROM '||lv2_version_table||' oa, '||lv2_main_table||' o'||CHR(10);
  lv2_sql :=lv2_sql||'WHERE oa.object_id = o.object_id'||CHR(10);

  IF lv2_main_table_where IS NOT NULL THEN

    lv2_sql :=lv2_sql||'AND '||lv2_main_table_where||CHR(10);

  END IF;

  -- Build View
  -- SafeBuild('OV_'||p_class_name,'VIEW',lv2_sql,p_target);
  */
  -- Create JN-view.

  -- Jn-views are generated only for those classes that have a journal rule defined in CLASS-table
  IF EcDp_ClassMeta.getClassJournalIfCondition(p_class_name) IS NOT NULL THEN

    lv2_sql :=         'CREATE OR REPLACE VIEW OV_'||p_class_name||'_JN AS'||CHR(10);
    lv2_sql :=lv2_sql||'SELECT'||CHR(10);
    lv2_sql :=lv2_sql||GeneratedCodeMsg;
    lv2_sql := lv2_sql||' o.jn_operation'||CHR(10);

    IF lv2_ue_user_function = 'Y' then
    lv2_sql := lv2_sql||',ue_user.getusername(o.jn_oracle_user) AS JN_ORACLE_USER '||CHR(10);
    ELSE
    lv2_sql := lv2_sql||',o.jn_oracle_user'||CHR(10);
    END IF;
    lv2_sql := lv2_sql||',o.jn_datetime'||CHR(10);
    lv2_sql := lv2_sql||',o.jn_notes'||CHR(10);
    lv2_sql := lv2_sql||',o.jn_appln'||CHR(10);
    lv2_sql := lv2_sql||',o.jn_session'||CHR(10);
    lv2_sql := lv2_sql||','||lv2_cols;
    lv2_sql := lv2_sql||'FROM '||lv2_main_table||'_JN o,('||CHR(10);

    lv2_main_cols := NULL;
    lv2_ver_cols := NULL;

    -- Get columns from main table
    FOR curCol IN c_table_cols(lv2_main_table) LOOP

      IF curCol.column_name NOT IN('OBJECT_ID', 'RECORD_STATUS', 'CREATED_BY', 'CREATED_DATE', 'LAST_UPDATED_BY', 'LAST_UPDATED_DATE', 'REV_NO', 'REV_TEXT', 'APPROVAL_STATE', 'APPROVAL_BY', 'APPROVAL_DATE', 'REC_ID') THEN

        lv2_main_cols := lv2_main_cols||', '||LOWER(curCol.column_name);

      END IF;

    END LOOP;

    -- Get columns from version table
    FOR curCol IN c_table_cols(lv2_version_table) LOOP

      IF curCol.column_name NOT IN('OBJECT_ID', 'RECORD_STATUS', 'CREATED_BY', 'CREATED_DATE', 'LAST_UPDATED_BY', 'LAST_UPDATED_DATE', 'REV_NO', 'REV_TEXT', 'APPROVAL_STATE', 'APPROVAL_BY', 'APPROVAL_DATE', 'REC_ID') THEN

        lv2_ver_cols := lv2_ver_cols||', '||LOWER(curCol.column_name);

      END IF;

    END LOOP;

    lv2_sql := lv2_sql||'   SELECT object_id, created_date jn_datetime '||lv2_ver_cols||', ''MAIN'' record_type, ''MAIN'' jn_notes,'||
                    'record_status, created_by, created_date, last_updated_by, last_updated_date, rev_no, rev_text'||CHR(10);

    IF lb_has_approval_state THEN
       lv2_sql := lv2_sql||', approval_state';
    END IF;
    IF lb_has_approval_by THEN
       lv2_sql := lv2_sql||', approval_by';
    END IF;
    IF lb_has_approval_date THEN
       lv2_sql := lv2_sql||', approval_date';
    END IF;
    IF lb_has_rec_id THEN
       lv2_sql := lv2_sql||', rec_id';
    END IF;

    lv2_sql := lv2_sql||'   FROM '||lv2_version_table||CHR(10);
    lv2_sql := lv2_sql||'   UNION ALL'||CHR(10);
    lv2_sql := lv2_sql||'   SELECT object_id, jn_datetime '||lv2_ver_cols||', ''JOUR'' record_type, jn_notes, '||
                     'record_status, created_by, created_date, last_updated_by, last_updated_date, rev_no, rev_text'||CHR(10);


    IF lb_has_approval_state THEN
       lv2_sql := lv2_sql||', approval_state';
    END IF;
    IF lb_has_approval_by THEN
       lv2_sql := lv2_sql||', approval_by';
    END IF;
    IF lb_has_approval_date THEN
       lv2_sql := lv2_sql||', approval_date';
    END IF;
    IF lb_has_rec_id THEN
       lv2_sql := lv2_sql||', rec_id';
    END IF;

    lv2_sql := lv2_sql||'   FROM '||lv2_version_table||'_JN'||CHR(10);
    lv2_sql := lv2_sql||') oa'||CHR(10);
    lv2_sql := lv2_sql||'WHERE o.object_id = oa.object_id'||CHR(10);
    lv2_sql := lv2_sql||'AND   oa.jn_datetime = ('||CHR(10);
    lv2_sql := lv2_sql||' SELECT NVL(MIN(m.jn_datetime),oa.created_date)'||CHR(10);
    lv2_sql := lv2_sql||' FROM ('||CHR(10);
    lv2_sql := lv2_sql||'    SELECT object_id, daytime, created_date jn_datetime'||CHR(10);
    lv2_sql := lv2_sql||'    FROM '||lv2_version_table||CHR(10);
    lv2_sql := lv2_sql||'    UNION ALL'||CHR(10);
    lv2_sql := lv2_sql||'    SELECT object_id, daytime, jn_datetime'||CHR(10);
    lv2_sql := lv2_sql||'    FROM '||lv2_version_table||'_JN'||CHR(10);
    lv2_sql := lv2_sql||'    ) m'||CHR(10);
    lv2_sql := lv2_sql||' WHERE m.object_id = o.object_id'||CHR(10);
    lv2_sql := lv2_sql||' AND m.jn_datetime >= o.jn_datetime'||CHR(10);
    lv2_sql := lv2_sql||' AND m.daytime = oa.daytime'||CHR(10);
    lv2_sql := lv2_sql||')'||CHR(10);
    lv2_sql := lv2_sql||'AND NVL(o.jn_notes,''INDEPENDENT'') <> ''COMMON'''||CHR(10);

    IF lv2_main_table_where IS NOT NULL THEN

      lv2_sql :=lv2_sql||'AND '||lv2_main_table_where||CHR(10);

    END IF;

    lv2_sql := lv2_sql||'UNION ALL'||CHR(10);

    lv2_sql :=lv2_sql||'SELECT'||CHR(10);
    lv2_sql := lv2_sql||' oa.jn_operation'||CHR(10);
    IF lv2_ue_user_function = 'Y' then
    lv2_sql := lv2_sql|| ',ue_user.getusername(oa.jn_oracle_user) AS JN_ORACLE_USER '||CHR(10);
    ELSE
    lv2_sql := lv2_sql||',oa.jn_oracle_user'||CHR(10);
    END IF;
    lv2_sql := lv2_sql||',oa.jn_datetime'||CHR(10);
    lv2_sql := lv2_sql||',oa.jn_notes'||CHR(10);
    lv2_sql := lv2_sql||',oa.jn_appln'||CHR(10);
    lv2_sql := lv2_sql||',oa.jn_session'||CHR(10);
    lv2_sql := lv2_sql||','||lv2_cols;
    lv2_sql := lv2_sql||'FROM '||lv2_version_table||'_JN oa,('||CHR(10);
    lv2_sql := lv2_sql||'   SELECT created_date jn_datetime, object_id '||lv2_main_cols||', ''MAIN'' record_type, ''MAIN'' jn_notes, record_status,'||
                    'created_by, created_date, last_updated_by, last_updated_date, rev_no, rev_text'||CHR(10);
    lv2_sql := lv2_sql||'   FROM '||lv2_main_table||CHR(10);
    lv2_sql := lv2_sql||'   UNION ALL'||CHR(10);
    lv2_sql := lv2_sql||'   SELECT jn_datetime, object_id '||lv2_main_cols||', ''JOUR'' record_type, jn_notes, record_status,'||
                    'created_by, created_date, last_updated_by, last_updated_date, rev_no, rev_text'||CHR(10);
    lv2_sql := lv2_sql||'   FROM '||lv2_main_table||'_JN'||CHR(10);
    lv2_sql := lv2_sql||') o'||CHR(10);
    lv2_sql := lv2_sql||'WHERE oa.object_id = o.object_id'||CHR(10);
    lv2_sql := lv2_sql||'AND   o.jn_datetime = ('||CHR(10);
    lv2_sql := lv2_sql||' SELECT NVL(MIN(m.jn_datetime),o.created_date)'||CHR(10);
    lv2_sql := lv2_sql||' FROM ('||CHR(10);
    lv2_sql := lv2_sql||'    SELECT object_id, created_date jn_datetime'||CHR(10);
    lv2_sql := lv2_sql||'    FROM '||lv2_main_table||CHR(10);
    lv2_sql := lv2_sql||'    UNION ALL'||CHR(10);
    lv2_sql := lv2_sql||'    SELECT object_id, jn_datetime'||CHR(10);
    lv2_sql := lv2_sql||'    FROM '||lv2_main_table||'_JN'||CHR(10);
    lv2_sql := lv2_sql||'    ) m'||CHR(10);
    lv2_sql := lv2_sql||' WHERE m.object_id = oa.object_id'||CHR(10);
    lv2_sql := lv2_sql||' AND m.jn_datetime >= oa.jn_datetime'||CHR(10);
    lv2_sql := lv2_sql||')'||CHR(10);

    IF lv2_main_table_where IS NOT NULL THEN

      lv2_sql :=lv2_sql||'AND '||lv2_main_table_where||CHR(10);

    END IF;

    SafeBuild('OV_'||p_class_name||'_JN','VIEW',lv2_sql,p_target);

  END IF;

EXCEPTION

  WHEN OTHERS THEN
     EcDp_DynSql.WriteTempText('GENCODEERROR','Syntax error generating view for '||p_class_name||CHR(10)||SQLERRM||CHR(10)||lv2_sql);



END ObjectClassJNView;




--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : InterfaceClassView
-- Description    : Generate a view based on a class definition of type INTERFACE
--
-- Preconditions  : p_class_name must refer to a class of type INTERFACE.
--                  The underlying classes of type OBJECT linked through CLASS_DEPENDENCY must
--                  contain all the same attributes as the INTERFACE with same attribute name
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
PROCEDURE InterfaceClassView(
   p_class_name         VARCHAR2,
   p_daytime            DATE,
   p_target             VARCHAR2 DEFAULT 'CREATE'
)
--</EC-DOC>
IS

TYPE column_list_type
IS TABLE OF VARCHAR2(50);

TYPE view_list_type
IS TABLE OF VARCHAR2(32);

Interface_class_mismatch EXCEPTION;

lv2_view_cols           VARCHAR2(8000);
column_list             column_list_type  := column_list_type();
view_list               view_list_type := view_list_type();
ln_columncount          NUMBER;
ln_column               NUMBER;
lb_found                BOOLEAN;
ln_unioncount           NUMBER;

lv2_sql_statement       VARCHAR2(32000);
lv2_base_table_where    VARCHAR2(32);
lv2_cur_class           VARCHAR2(32);  -- Used in exception reporting
lv2_cur_attrib          VARCHAR2(32);  -- Used in exception reporting
lv2_child_class_type    class.class_type%TYPE;
lv2_child_view_name     VARCHAR2(32);
lv2_where_cond          class_db_mapping.db_where_condition%TYPE;
ln_child_view_count    NUMBER := 0;
ln_child_jn_view_count  NUMBER := 0;

CURSOR c_journal_view(cp_view_name  VARCHAR2) IS
 SELECT view_name
 FROM user_views
 WHERE view_name = cp_view_name;



BEGIN

    -- check if interface has classes implementing it
    IF Ecdp_Classmeta.IsImplementationsDefined(p_class_name) = 'Y' THEN


       -- First build create with column list

       lv2_sql_statement := 'CREATE OR REPLACE VIEW IV_' || p_class_name || ' ( ' || chr(10);
       lv2_sql_statement := lv2_sql_statement ||'Class_name' || chr(10);
       ln_columncount := 0;
       ln_unioncount := 0;

       lv2_where_cond := EcDp_ClassMeta.GetClassWhereCondition(p_class_name);

       FOR  ClassesAttr IN EcDp_ClassMeta.c_classes_intf_attr (p_class_name , 'N') LOOP

            ln_columncount := ln_columncount + 1;
            lv2_sql_statement := lv2_sql_statement ||','|| ClassesAttr.attribute_name || chr(10);
            column_list.EXTEND;
            column_list(ln_columncount) := ClassesAttr.attribute_name;

       END LOOP;


       FOR  ClassesRel IN EcDp_ClassMeta.c_classes_intf_rel (p_class_name) LOOP

         ln_columncount := ln_columncount + 1;
         column_list.EXTEND;
         column_list(ln_columncount) := ClassesRel.role_name;

         lv2_sql_statement := lv2_sql_statement || ',' ||  ClassesRel.role_name || '_ID' || chr(10);

         lv2_sql_statement := lv2_sql_statement || ','  || ClassesRel.role_name || '_CODE' || chr(10);

       END LOOP;


       lv2_sql_statement := lv2_sql_statement ||', RECORD_STATUS' || chr(10);
       lv2_sql_statement := lv2_sql_statement ||', CREATED_BY' || chr(10);
       lv2_sql_statement := lv2_sql_statement ||', CREATED_DATE' || chr(10);
       lv2_sql_statement := lv2_sql_statement ||', LAST_UPDATED_BY' || chr(10);
       lv2_sql_statement := lv2_sql_statement ||', LAST_UPDATED_DATE' || chr(10);
       lv2_sql_statement := lv2_sql_statement ||', REV_NO' || chr(10);
       lv2_sql_statement := lv2_sql_statement ||', REV_TEXT' || chr(10);
       lv2_sql_statement := lv2_sql_statement ||', APPROVAL_STATE' || chr(10);
       lv2_sql_statement := lv2_sql_statement ||', APPROVAL_BY' || chr(10);
       lv2_sql_statement := lv2_sql_statement ||', APPROVAL_DATE' || chr(10);
       lv2_sql_statement := lv2_sql_statement ||', REC_ID';
       lv2_sql_statement := lv2_sql_statement ||') AS '||  chr(10);


       -- This will be a union query, need to loop all source classes

       FOR Intf_sources IN EcDp_ClassMeta.c_classes_interface(p_class_name) LOOP

          IF ln_unioncount = 0 THEN
             lv2_view_cols := ' SELECT '||GeneratedCodeMsg||''''||intf_sources.child_class||'''';
          ELSE
             lv2_view_cols := ' UNION ALL SELECT '''||intf_sources.child_class||'''';
          END IF;


          ln_unioncount := ln_unioncount + 1;

          ln_column := 0;

           -- First try to find the column as a normal attribute
           ln_column := ln_column + 1;

           FOR  ClassesAttr IN EcDp_ClassMeta.c_classes_intf_attr (p_class_name , 'N') LOOP

             lb_found := TRUE;

             lv2_view_cols := lv2_view_cols  ||','|| ClassesAttr.attribute_name || chr(10);


           END LOOP;


           FOR  ClassesRel IN EcDp_ClassMeta.c_classes_intf_rel (p_class_name) LOOP

               ln_columncount := ln_columncount + 1;
               column_list.EXTEND;
               column_list(ln_columncount) := ClassesRel.role_name;

            lv2_view_cols := lv2_view_cols || ',' ||  ClassesRel.role_name || '_ID' || chr(10);

               lv2_view_cols := lv2_view_cols || ','  || ClassesRel.role_name || '_CODE' || chr(10);


            END LOOP;

         lv2_view_cols := lv2_view_cols ||
                                   ', RECORD_STATUS '||
                           CHR(10)||', CREATED_BY  '||
                           CHR(10)||', CREATED_DATE  '||
                           CHR(10)||', LAST_UPDATED_BY  '||
                           CHR(10)||', LAST_UPDATED_DATE  '||
                           CHR(10)||', REV_NO  '||
                           CHR(10)||', REV_TEXT  '||
                           CHR(10)||', APPROVAL_STATE' ||
                           CHR(10)||', APPROVAL_BY' ||
                           CHR(10)||', APPROVAL_DATE' ||
                           CHR(10)||', REC_ID' || CHR(10);

         lv2_child_class_type := EcDp_ClassMeta.getClassType(intf_sources.child_class);

         IF lv2_child_class_type = 'OBJECT' THEN

            lv2_child_view_name  := 'OV_' || intf_sources.child_class;

         ELSIF lv2_child_class_type = 'INTERFACE' THEN

            lv2_child_view_name  := 'IV_' || intf_sources.child_class;

         ELSIF lv2_child_class_type = 'SUB_CLASS' THEN

            lv2_child_view_name  := 'OSV_' || intf_sources.child_class;

         ELSIF lv2_child_class_type = 'DATA' THEN

            lv2_child_view_name  := 'DV_' || intf_sources.child_class;

         ELSIF lv2_child_class_type = 'TABLE' THEN

            lv2_child_view_name  := 'TV_' || intf_sources.child_class;

         ELSE

            Raise_Application_Error(-2000, 'Invalid class type for class ' || intf_sources.child_class );

         END IF;

         view_list.EXTEND;
         view_list(ln_unioncount) := lv2_child_view_name;

         lv2_sql_statement := lv2_sql_statement || lv2_view_cols ||
                                 ' FROM '|| lv2_child_view_name || chr(10);

         -- Add where condition on each child class
         IF lv2_where_cond IS NOT NULL THEN

            lv2_sql_statement := lv2_sql_statement ||
                                 ' WHERE '||lv2_where_cond||CHR(10);

         END IF;



       END LOOP; -- Interface



      SafeBuild('IV_'||p_class_name,'VIEW',lv2_sql_statement,p_target);


      -- Create joural view if it exists a journal view for classes that implements this interface
      FOR curChild IN EcDp_ClassMeta.c_classes_interface(p_class_name) LOOP
        ln_child_view_count := ln_child_view_count + 1;

        FOR curJnView IN c_journal_view(UPPER(EcDp_ClassMeta.getClassViewName(curChild.child_class)||'_JN')) LOOP

          ln_child_jn_view_count := ln_child_jn_view_count + 1;

        END LOOP;

      END LOOP;

      IF ln_child_view_count = ln_child_jn_view_count THEN -- Exist journal view for all child classes


        lv2_sql_statement := replace(lv2_sql_statement,'CREATE OR REPLACE VIEW IV_'||p_class_name||' ( ',
                                                             'CREATE OR REPLACE VIEW IV_'||p_class_name||'_JN ( '||CHR(10)||
                                                             '  JN_OPERATION,'||CHR(10)||
                                                             '  JN_ORACLE_USER,'||CHR(10)||
                                                             '  JN_DATETIME,'||CHR(10)||
                                                             '  JN_NOTES,');

        lv2_sql_statement := replace(lv2_sql_statement,'SELECT','SELECT '||
                                                          ' JN_OPERATION,'||CHR(10)||
                                                          ' JN_ORACLE_USER,'||CHR(10)||
                                                          ' JN_DATETIME,'||CHR(10)||
                                                          ' JN_NOTES,'||CHR(10));

        -- Replace all views vith journal views.
        FOR view_counter IN 1..ln_unioncount LOOP

           lv2_sql_statement := replace(lv2_sql_statement,'FROM ' || view_list(view_counter)||' ' ,'FROM ' || view_list(view_counter) || '_JN ');
           lv2_sql_statement := replace(lv2_sql_statement,'FROM ' || view_list(view_counter)||CHR(10) ,'FROM ' || view_list(view_counter) || '_JN ');

        END LOOP;


        SafeBuild('IV_'||p_class_name||'_JN','VIEW',lv2_sql_statement,p_target);

     ELSE

       EcDp_DynSql.WriteTempText('GENCODEWARNING', 'Could not create interface journal view for '||p_class_name||'. Missing journal view for one or more of the implementing child classes!');


     END IF;

   ELSE  -- No implementations exist, write a warning to the log

     EcDp_DynSql.WriteTempText('GENCODEWARNING','No implementations for Interface class '||p_class_name ||'.');


   END IF;

EXCEPTION

    WHEN Interface_class_mismatch THEN
         EcDp_DynSql.WriteTempText('GENCODEERROR','Interface class column '||lv2_cur_attrib ||' not found in class '||lv2_cur_class);
         COMMIT;


     WHEN OTHERS THEN
         EcDp_DynSql.WriteTempText('GENCODEERROR','Syntax error generating view for '||p_class_name||CHR(10)||SQLERRM||CHR(10)||
                                      lv2_sql_statement);


END InterfaceClassView;


PROCEDURE EventView(
     p_class_name         VARCHAR2,
     p_daytime            DATE,
     p_target             VARCHAR2 DEFAULT 'CREATE'
  )
    is
    lv2_sql_1             VARCHAR2(16000);
    lv2_sql_2             VARCHAR2(16000);
    lv2_col_list          VARCHAR2(16000);
    lv2_sql               VARCHAR2(32000);
    lv2_count             NUMBER;
    lv2_main_table        class_db_mapping.db_object_name%TYPE;
    lv2_view_name         VARCHAR2(100);

    CURSOR c_attribute_name is
    SELECT *
    FROM dao_meta
    WHERE CLASS_name = p_class_name AND  DB_MAPPING_TYPE <> 'FUNCTION' order by sort_order;

    BEGIN
    FOR curClass IN EcDp_ClassMeta.c_classes(p_class_name) LOOP
      lv2_main_table := curClass.db_object_name;
    END LOOP;
    lv2_view_name := Ecdp_Classmeta.getClassViewName(p_class_name);

   IF p_target = 'DROP' THEN
          SELECT COUNT(*) into lv2_count
          FROM user_objects
          WHERE object_type = 'VIEW'
          AND object_name = 'EV_' || p_class_name;

          IF lv2_count = 1 THEN
             EXECUTE IMMEDIATE 'DROP VIEW EV_' || p_class_name;
          END IF;
   ELSE


      lv2_sql := 'CREATE OR REPLACE VIEW EV_' || p_class_name ||' AS ' ;

      FOR curAttribute in c_attribute_name LOOP
          lv2_col_list :=  lv2_col_list || ',' || curAttribute.db_sql_syntax||' as '|| curAttribute.property_name;
      END LOOP;

      lv2_sql_1 := 'SELECT c.event_no as EVENT_NO, c.ref_rec_id AS REC_ID, c.ref_rev_no AS REV_NO' || lv2_col_list || ' FROM ';
      lv2_sql_1 := lv2_sql_1 ||  lv2_main_table || ' a, evt_tran_data_con c '|| CHR(10);
      lv2_sql_1 := lv2_sql_1 || 'WHERE a.rev_no = c.ref_rev_no '|| CHR(10);
      lv2_sql_1 := lv2_sql_1 || 'AND   a.rec_id = c.ref_rec_id ' || CHR(10);
      lv2_sql_1 := lv2_sql_1 || 'AND   c.ref_source_name = ''' || lv2_view_name || ''''|| CHR(10);

      lv2_sql_2 := 'SELECT c.event_no as EVENT_NO, c.ref_rec_id AS REC_ID, c.ref_rev_no AS REV_NO' || lv2_col_list || ' FROM ';
      lv2_sql_2 := lv2_sql_2 || lv2_main_table || '_JN j, evt_tran_data_con c '|| CHR(10);
      lv2_sql_2 := lv2_sql_2 || 'WHERE j.rev_no = c.ref_rev_no '|| CHR(10);
      lv2_sql_2 := lv2_sql_2 || 'AND   j.rec_id = c.ref_rec_id'|| CHR(10);
      lv2_sql_2 := lv2_sql_2 || 'AND   c.ref_source_name = ''' || lv2_view_name || ''''|| CHR(10);

      lv2_sql := lv2_sql || CHR(10) || lv2_sql_1 || 'UNION ALL' || CHR(10) || lv2_sql_2;

      -- Build View
      SafeBuild('EV_'||p_class_name,'VIEW',lv2_sql,p_target);
    END IF;
EXCEPTION
  WHEN OTHERS THEN
     EcDp_DynSql.WriteTempText('GENCODEERROR','Syntax error generating view for '||p_class_name||CHR(10)||SQLERRM||CHR(10)||lv2_sql);
END EventView;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : TableClassView
-- Description    : Generate a view based on a class definition of type TABLE
--
-- Preconditions  : p_class_name must refer to a class of type TABLE.
--                  Class_attribute and class_attr_db_mapping must be configured for class.
--                  Table classes can not have relation use virtual attributes.
--
--
-- Postcondition  : View generated or error logged in T_TEMPTEXT.
--                  IF p_target = 'SCRIPT' code generated to T_TEMPTEXT
-- Using Tables   : T_TEMPTEXT
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE TableClassView(
   p_class_name  VARCHAR2,
   p_daytime    DATE,
   p_target VARCHAR2 DEFAULT 'CREATE'
)
--</EC-DOC>

IS

-- ln_cur NUMBER;
lv2_sql_lines DBMS_SQL.varchar2a ;
lv2_table_name VARCHAR2(200) ;
lv2_table_owner VARCHAR2(200) ;
lv2_ue_user_function      VARCHAR2(1);
lv2_base_table_where class_db_mapping.db_where_condition%TYPE;
jn_table_exists BOOLEAN;

BEGIN

    FOR curClasses IN EcDp_ClassMeta.c_classes(p_class_name) LOOP

      lv2_table_name := curClasses.db_object_name;
      lv2_table_owner := curClasses.db_object_owner ;
      lv2_base_table_where := curClasses.db_where_condition;

    END LOOP;

    AddUniqueViewColumns(lv2_sql_lines, 'CREATE OR REPLACE VIEW TV_' || p_class_name || ' AS '||chr(10)||
                         ' SELECT ' || chr(10) ||GeneratedCodeMsg||''''||p_class_name || ''' AS  table_class_name ');

    FOR ClassesAttr IN EcDp_ClassMeta.c_classes_attr(p_class_name, 'N') LOOP


       AddUniqueViewColumns(lv2_sql_lines, ', ' || ClassesAttr.db_sql_syntax || ' AS ' || ClassesAttr.attribute_name);

    END LOOP;



    --EcDp_ClassMeta.isusingUserFunction()  Y/N
    lv2_ue_user_function := EcDp_ClassMeta.IsUsingUserFunction();

    AddUniqueViewColumns(lv2_sql_lines, ', RECORD_STATUS AS RECORD_STATUS');

   if lv2_ue_user_function = 'N'  then

     AddUniqueViewColumns(lv2_sql_lines, ', CREATED_BY AS CREATED_BY');

    else

      AddUniqueViewColumns(lv2_sql_lines, ', ue_user.getusername(CREATED_BY) AS CREATED_BY');

    end if;

    AddUniqueViewColumns(lv2_sql_lines, ', CREATED_DATE AS CREATED_DATE');

    if lv2_ue_user_function = 'N' then

      AddUniqueViewColumns(lv2_sql_lines, ', LAST_UPDATED_BY AS LAST_UPDATED_BY');

    else

      AddUniqueViewColumns(lv2_sql_lines, ', ue_user.getusername(LAST_UPDATED_BY) AS LAST_UPDATED_BY');

    end if;

    AddUniqueViewColumns(lv2_sql_lines, ', LAST_UPDATED_DATE AS LAST_UPDATED_DATE');
    AddUniqueViewColumns(lv2_sql_lines, ', REV_NO AS REV_NO');
    AddUniqueViewColumns(lv2_sql_lines, ', REV_TEXT AS REV_TEXT');

    AddUniqueViewColumns(lv2_sql_lines, ','||AddSafeViewColumn(lv2_table_name,'APPROVAL_STATE',lv2_table_owner,''));
    AddUniqueViewColumns(lv2_sql_lines, ', '||AddSafeViewColumn(lv2_table_name,'APPROVAL_BY',lv2_table_owner,''));
    AddUniqueViewColumns(lv2_sql_lines, ', '||AddSafeViewColumn(lv2_table_name,'APPROVAL_DATE',lv2_table_owner,''));

    if ecdp_classmeta.getClassAttrDbSqlSyntax(p_class_name,'REC_ID') is NULL THEN
      AddUniqueViewColumns(lv2_sql_lines, ','||AddSafeViewColumn(lv2_table_name,'REC_ID',lv2_table_owner,''));
    end if;



    AddUniqueViewColumns(lv2_sql_lines, ' FROM '|| lv2_table_owner ||'.'|| lv2_table_name);

    IF lv2_base_table_where IS NOT NULL THEN

        AddUniqueViewColumns(lv2_sql_lines, ' WHERE ' || lv2_base_table_where);

    END IF;

    EcDp_Dynsql.SafeBuild('TV_'||p_class_name,'VIEW',lv2_sql_lines ,p_target, p_lfflg => 'Y');

END TableClassView;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : TableClassJNView
-- Description    : Generate a view based on a class definition of type TABLE
--
-- Preconditions  : p_class_name must refer to a class of type TABLE.
--                  Class_attribute and class_attr_db_mapping must be configured for class.
--                  Table classes can not have relation use virtual attributes.
--
--
-- Postcondition  : View generated or error logged in T_TEMPTEXT.
--                  IF p_target = 'SCRIPT' code generated to T_TEMPTEXT
-- Using Tables   : T_TEMPTEXT
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE TableClassJNView(
   p_class_name  VARCHAR2,
   p_daytime    DATE,
   p_target VARCHAR2 DEFAULT 'CREATE'
)
--</EC-DOC>

IS

-- ln_cur NUMBER;
lv2_sql_lines DBMS_SQL.varchar2a ;
lv2_table_name VARCHAR2(200) ;
lv2_table_owner VARCHAR2(200) ;
lv2_ue_user_function VARCHAR2(1);
lv2_base_table_where class_db_mapping.db_where_condition%TYPE;
jn_table_exists BOOLEAN;

BEGIN

    FOR curClasses IN EcDp_ClassMeta.c_classes(p_class_name) LOOP

      lv2_table_name := curClasses.db_object_name;
      lv2_table_owner := curClasses.db_object_owner ;
      lv2_base_table_where := curClasses.db_where_condition;

    END LOOP;

    IF EcDp_GenClassCode.TableExists(lv2_table_name||'_JN',lv2_table_owner) THEN

    lv2_ue_user_function := EcDp_ClassMeta.IsUsingUserFunction();
     IF lv2_ue_user_function = 'Y'  THEN
       AddUniqueViewColumns(lv2_sql_lines, 'CREATE OR REPLACE VIEW TV_' || p_class_name || '_JN AS '||chr(10)||
                           ' SELECT ' || chr(10) ||GeneratedCodeMsg||
                          'JN_OPERATION AS JN_OPERATION,'||CHR(10)||
                          'ue_user.getusername(JN_ORACLE_USER) AS JN_ORACLE_USER, '||CHR(10)||
                          'JN_DATETIME AS JN_DATETIME,'||CHR(10)||
                          'JN_NOTES AS JN_NOTES,'||CHR(10)||
                          'JN_APPLN AS JN_APPLN,'||CHR(10)||
                          'JN_SESSION AS JN_SESSION,'||CHR(10)||''''||p_class_name || ''' AS  table_class_name ');
      ELSE
       AddUniqueViewColumns(lv2_sql_lines, 'CREATE OR REPLACE VIEW TV_' || p_class_name || '_JN AS '||chr(10)||
                           ' SELECT ' || chr(10) ||GeneratedCodeMsg||
                          'JN_OPERATION AS JN_OPERATION,'||CHR(10)||
                          'JN_ORACLE_USER AS JN_ORACLE_USER,'||CHR(10)||
                          'JN_DATETIME AS JN_DATETIME,'||CHR(10)||
                          'JN_NOTES AS JN_NOTES,'||CHR(10)||
                          'JN_APPLN AS JN_APPLN,'||CHR(10)||
                          'JN_SESSION AS JN_SESSION,'||CHR(10)||''''||p_class_name || ''' AS  table_class_name ');
       END IF;

      FOR ClassesAttr IN EcDp_ClassMeta.c_classes_attr(p_class_name, 'N') LOOP


           IF ClassesAttr.db_mapping_type = 'FUNCTION'  AND Nvl(ClassesAttr.is_key,'N') <> 'Y' THEN

              IF ClassesAttr.Data_type = 'DATE' THEN

                AddUniqueViewColumns(lv2_sql_lines, ', to_date(NULL) AS ' || ClassesAttr.attribute_name);

              ELSIF   ClassesAttr.Data_type IN ('NUMBER','INTEGER') THEN

                AddUniqueViewColumns(lv2_sql_lines, ', to_number(NULL) AS ' || ClassesAttr.attribute_name);

              ELSE

                AddUniqueViewColumns(lv2_sql_lines, ', to_char(NULL) AS ' || ClassesAttr.attribute_name);

              END IF;



           ELSE

            AddUniqueViewColumns(lv2_sql_lines, ', ' || ClassesAttr.db_sql_syntax || ' AS ' || ClassesAttr.attribute_name);

           END IF;


      END LOOP;

    lv2_ue_user_function := EcDp_ClassMeta.IsUsingUserFunction();

    AddUniqueViewColumns(lv2_sql_lines,', RECORD_STATUS AS RECORD_STATUS');

   if lv2_ue_user_function = 'N'  then

     AddUniqueViewColumns(lv2_sql_lines,', CREATED_BY AS CREATED_BY');

    else

      AddUniqueViewColumns(lv2_sql_lines,', ue_user.getusername(CREATED_BY) AS CREATED_BY');

    end if;

    AddUniqueViewColumns(lv2_sql_lines,', CREATED_DATE AS CREATED_DATE');

    if lv2_ue_user_function = 'N' then

      AddUniqueViewColumns(lv2_sql_lines,', LAST_UPDATED_BY AS LAST_UPDATED_BY');

    else

      AddUniqueViewColumns(lv2_sql_lines,', ue_user.getusername(LAST_UPDATED_BY) AS LAST_UPDATED_BY');

    end if;

    AddUniqueViewColumns(lv2_sql_lines,', LAST_UPDATED_DATE AS LAST_UPDATED_DATE');
    AddUniqueViewColumns(lv2_sql_lines,', REV_NO AS REV_NO');
    AddUniqueViewColumns(lv2_sql_lines,', REV_TEXT AS REV_TEXT');

    AddUniqueViewColumns(lv2_sql_lines, ','||AddSafeViewColumn(lv2_table_name,'APPROVAL_STATE',lv2_table_owner,''));
    AddUniqueViewColumns(lv2_sql_lines,', '||AddSafeViewColumn(lv2_table_name,'APPROVAL_BY',lv2_table_owner,''));
    AddUniqueViewColumns(lv2_sql_lines,', '||AddSafeViewColumn(lv2_table_name,'APPROVAL_DATE',lv2_table_owner,''));

    if ecdp_classmeta.getClassAttrDbSqlSyntax(p_class_name,'REC_ID') is NULL THEN
      AddUniqueViewColumns(lv2_sql_lines,','||AddSafeViewColumn(lv2_table_name,'REC_ID',lv2_table_owner,''));
    end if;

        AddUniqueViewColumns(lv2_sql_lines, ' FROM '|| lv2_table_owner ||'.'|| lv2_table_name  ||'_JN') ;

      IF lv2_base_table_where IS NOT NULL THEN

          AddUniqueViewColumns(lv2_sql_lines, ' WHERE ' || lv2_base_table_where);

      END IF;

      EcDp_Dynsql.SafeBuild('TV_'||p_class_name||'_JN','VIEW',lv2_sql_lines ,p_target, p_lfflg => 'Y');

   END IF; -- Journal table exists

END TableClassJNView;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : DataClassView
-- Description    : Generate a view based on a class definition of type DATA
--
-- Preconditions  : p_class_name must refer to a class of type 'DATA'.
--                  Class_attribute and class_attr_db_mapping must be configured for class.
--
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
PROCEDURE DataClassView(
   p_class_name   VARCHAR2,
   p_daytime      DATE,
   p_target       VARCHAR2 DEFAULT 'CREATE'
)
--</EC-DOC>

IS

lv2_sql_lines           DBMS_SQL.varchar2a;
lv2_table_name          VARCHAR2(100);
lv2_table_where         class_db_mapping.db_where_condition%TYPE;
lv2_object_owner        class_db_mapping.db_object_owner%TYPE;
lb_join_owner_table     BOOLEAN := FALSE;
lv2_owner_class         class.owner_class_name%TYPE;
lv2_owner_class_type    class.cLass_type%TYPE;
lv2_rel_class_type      class.cLass_type%TYPE;
lv2_version_table       VARCHAR2(32);
lv2_main_table          VARCHAR2(32);
lb_use_object_id        BOOLEAN;
lv2_ue_user_function    VARCHAR2(1);
lv2_time_scope_code     class.TIME_SCOPE_CODE%TYPE;

BEGIN

   lv2_owner_class := EcDP_ClassMeta.OwnerClassName(p_class_name);
   lv2_time_scope_code := ec_class.time_scope_code(p_class_name);

   FOR Classes IN EcDp_ClassMeta.c_classes(p_class_name) LOOP
      lv2_object_owner := Classes.db_object_owner;
      lv2_table_where := Classes.db_where_condition;
      lv2_table_name := Classes.db_object_name;
   END LOOP;

   lb_use_object_id := ( lv2_owner_class IS NOT NULL );

   -- Need to determine whether we should join with owner table
   -- Owner table is joined if we have a daytime column and the owner class is of type OBJECT
   IF lb_use_object_id AND Nvl(lv2_time_scope_code,'EVENT') <> 'NONE' THEN

      lv2_owner_class_type := EcDp_ClassMeta.getClassType(lv2_owner_class);

      FOR curOwnerClass IN EcDp_ClassMeta.c_classes(lv2_owner_class) LOOP
         lv2_main_table := curOwnerClass.db_object_name;
         lv2_version_table := curOwnerClass.db_object_attribute;
      END LOOP;

      FOR curDatyimecheck IN EcDp_ClassMeta.c_classes_attr (p_class_name,'N', 'DAYTIME') LOOP
         lb_join_owner_table := (lv2_owner_class_type = 'OBJECT' AND curDatyimecheck.db_sql_syntax = 'DAYTIME' );
      END LOOP;

   END IF;

   AddUniqueViewColumns(lv2_sql_lines, 'CREATE OR REPLACE VIEW DV_'||p_class_name||' AS SELECT '||CHR(10)||GeneratedCodeMsg);
   IF NOT ecdp_classmeta.IsValidAttribute(p_class_name, 'CLASS_NAME') THEN
      AddUniqueViewColumns(lv2_sql_lines,'''' || p_class_name || ''''||' AS CLASS_NAME,');
   END IF;

   IF lb_use_object_id THEN

      AddUniqueViewColumns(lv2_sql_lines, lv2_table_name||'.OBJECT_ID AS OBJECT_ID,');

      IF lb_join_owner_table THEN
         AddUniqueViewColumns(lv2_sql_lines,'o.OBJECT_CODE OBJECT_CODE,');
      ELSIF lv2_owner_class_type = 'OBJECT' THEN
         AddUniqueViewColumns(lv2_sql_lines, EcDp_ClassMeta.GetEcPackage(lv2_owner_class)||'.object_code('||lv2_table_name||'.object_id) AS OBJECT_CODE,');
      ELSE
         AddUniqueViewColumns(lv2_sql_lines, 'EcDp_Objects.GetObjCode('||lv2_table_name||'.object_id) AS OBJECT_CODE,');
      END IF;

   END IF;

   FOR ClassesAttr IN EcDp_ClassMeta.c_dataclasses_attr(p_class_name, 'N') LOOP

      IF UPPER(ClassesAttr.attribute_name) NOT IN ('OBJECT_ID','OBJECT_CODE') AND ClassesAttr.report_only_ind = 'N' THEN

         IF ClassesAttr.db_mapping_type = 'COLUMN' THEN
            AddUniqueViewColumns(lv2_sql_lines, lv2_table_name||'.'||ClassesAttr.db_sql_syntax || ' AS ' || ClassesAttr.attribute_name ||',');
         ELSE
            AddUniqueViewColumns(lv2_sql_lines, ClassesAttr.db_sql_syntax || ' AS ' || ClassesAttr.attribute_name ||',');
         END IF;

      END IF;

   END LOOP; -- Attributes

   FOR ClassesRel IN EcDp_ClassMeta.c_classes_rel(p_class_name) LOOP

      IF ClassesRel.report_only_ind = 'N' THEN

         lv2_rel_class_type := EcDp_ClassMeta.GetClassType(ClassesRel.from_class_name);

         IF ClassesRel.db_mapping_type = 'COLUMN' THEN
            AddUniqueViewColumns(lv2_sql_lines, lv2_table_name||'.'||ClassesRel.db_sql_syntax||' AS '||ClassesRel.role_name||'_ID,');

            IF lv2_rel_class_type = 'OBJECT' THEN
             AddUniqueViewColumns(lv2_sql_lines, EcDp_ClassMeta.GetEcPackage(ClassesRel.from_class_name)||'.object_code('||lv2_table_name||'.'||ClassesRel.db_sql_syntax||') AS ' || ClassesRel.role_name || '_CODE,');
          ELSE
            AddUniqueViewColumns(lv2_sql_lines, 'EcDp_Objects.GetObjCode('||lv2_table_name||'.'||ClassesRel.db_sql_syntax||') AS ' || ClassesRel.role_name || '_CODE,');
          END IF;

         ELSE
            AddUniqueViewColumns(lv2_sql_lines, ClassesRel.db_sql_syntax||' AS '||ClassesRel.role_name||'_ID,');

            IF lv2_rel_class_type = 'OBJECT' THEN
             AddUniqueViewColumns(lv2_sql_lines, EcDp_ClassMeta.GetEcPackage(ClassesRel.from_class_name)||'.object_code('||ClassesRel.db_sql_syntax||') AS ' || ClassesRel.role_name || '_CODE,');
          ELSE
            AddUniqueViewColumns(lv2_sql_lines, 'EcDp_Objects.GetObjCode('||ClassesRel.db_sql_syntax||') AS ' || ClassesRel.role_name || '_CODE,');
          END IF;
         END IF;

      END IF;

   END LOOP; -- Relations

    lv2_ue_user_function := EcDp_ClassMeta.IsUsingUserFunction();

    AddUniqueViewColumns(lv2_sql_lines, lv2_table_name||'.RECORD_STATUS AS RECORD_STATUS,');

    if lv2_ue_user_function = 'N'  then

    AddUniqueViewColumns(lv2_sql_lines, lv2_table_name||'.CREATED_BY AS CREATED_BY,');

    else

      AddUniqueViewColumns(lv2_sql_lines, 'ue_user.getusername('||lv2_table_name||'.CREATED_BY) AS CREATED_BY,');

    end if;

    AddUniqueViewColumns(lv2_sql_lines, lv2_table_name||'.CREATED_DATE AS CREATED_DATE,');

    if lv2_ue_user_function = 'N' then

    AddUniqueViewColumns(lv2_sql_lines, lv2_table_name||'.LAST_UPDATED_BY AS LAST_UPDATED_BY,');

    else

      AddUniqueViewColumns(lv2_sql_lines, 'ue_user.getusername('||lv2_table_name||'.LAST_UPDATED_BY) AS LAST_UPDATED_BY,');

    end if;

    AddUniqueViewColumns(lv2_sql_lines, lv2_table_name||'.LAST_UPDATED_DATE AS LAST_UPDATED_DATE,');
    AddUniqueViewColumns(lv2_sql_lines, lv2_table_name||'.REV_NO AS REV_NO,');
    AddUniqueViewColumns(lv2_sql_lines, lv2_table_name||'.REV_TEXT AS REV_TEXT,');

    AddUniqueViewColumns(lv2_sql_lines, AddSafeViewColumn(lv2_table_name,'APPROVAL_STATE',lv2_object_owner,lv2_table_name||'.')||',');
    AddUniqueViewColumns(lv2_sql_lines, AddSafeViewColumn(lv2_table_name,'APPROVAL_BY',lv2_object_owner,lv2_table_name||'.')||',');
    AddUniqueViewColumns(lv2_sql_lines, AddSafeViewColumn(lv2_table_name,'APPROVAL_DATE',lv2_object_owner,lv2_table_name||'.')||',');
    AddUniqueViewColumns(lv2_sql_lines, AddSafeViewColumn(lv2_table_name,'REC_ID',lv2_object_owner,lv2_table_name||'.'));
    AddUniqueViewColumns(lv2_sql_lines, 'FROM '||lv2_table_name);

   IF lb_join_owner_table THEN
      AddUniqueViewColumns(lv2_sql_lines,', '||lv2_version_table||' oa, '||lv2_main_table||' o');
      AddUniqueViewColumns(lv2_sql_lines,'WHERE '||lv2_table_name||'.object_id = oa.object_id');
      AddUniqueViewColumns(lv2_sql_lines,'AND oa.object_id = o.object_id');




      IF lv2_time_scope_code IN ('MTH','MONTH') THEN

         AddUniqueViewColumns(lv2_sql_lines,'AND '||lv2_table_name||'.daytime >= TRUNC(oa.daytime,''MONTH'')');

         AddUniqueViewColumns(lv2_sql_lines,'AND oa.daytime = (');

         AddUniqueViewColumns(lv2_sql_lines,'SELECT MIN(daytime) FROM '||lv2_version_table||' v2');
         AddUniqueViewColumns(lv2_sql_lines,'WHERE v2.object_id = oa.object_id');
         AddUniqueViewColumns(lv2_sql_lines,'AND   '||lv2_table_name||'.daytime >= trunc(v2.daytime,''MONTH'')');
         AddUniqueViewColumns(lv2_sql_lines,'AND '||lv2_table_name||'.daytime < nvl(v2.end_date,'||lv2_table_name||'.daytime + 1))');

      ELSIF lv2_time_scope_code IN ('YR','YEAR') THEN

         AddUniqueViewColumns(lv2_sql_lines,'AND '||lv2_table_name||'.daytime >= TRUNC(oa.daytime,''YEAR'')');

         AddUniqueViewColumns(lv2_sql_lines,'AND oa.daytime = (');

         AddUniqueViewColumns(lv2_sql_lines,'SELECT MIN(daytime) FROM '||lv2_version_table||' v2');
         AddUniqueViewColumns(lv2_sql_lines,'WHERE v2.object_id = oa.object_id');
         AddUniqueViewColumns(lv2_sql_lines,'AND   '||lv2_table_name||'.daytime >= trunc(v2.daytime,''YEAR'')');
         AddUniqueViewColumns(lv2_sql_lines,'AND '||lv2_table_name||'.daytime < nvl(v2.end_date,'||lv2_table_name||'.daytime + 1))');

      ELSE

         AddUniqueViewColumns(lv2_sql_lines,'AND '||lv2_table_name||'.daytime >= oa.daytime');
         AddUniqueViewColumns(lv2_sql_lines,'AND '||lv2_table_name||'.daytime < nvl(oa.end_date,'||lv2_table_name||'.daytime + 1)');

      END IF;



      IF lv2_table_where IS NOT NULL THEN
          AddUniqueViewColumns(lv2_sql_lines,'AND '||lv2_table_where);
      END IF;

   ELSE

      IF lv2_table_where IS NOT NULL THEN

            AddUniqueViewColumns(lv2_sql_lines,CHR(10)||'WHERE '||lv2_table_where);

      END IF;

   END IF;

   EcDp_Dynsql.SafeBuild('DV_'||p_class_name,'VIEW',lv2_sql_lines ,p_target, p_lfflg => 'Y');

END DataClassView;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : DataClassJNView
-- Description    : Generate a JN view based on a class definition of type DATA
--
-- Preconditions  : p_class_name must refer to a class of type 'DATA'.
--                  Class_attribute and class_attr_db_mapping must be configured for class.
--
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
PROCEDURE DataClassJNView(
   p_class_name   VARCHAR2,
   p_daytime      DATE,
   p_target       VARCHAR2 DEFAULT 'CREATE'
)
--</EC-DOC>

IS

lv2_sql_lines           DBMS_SQL.varchar2a;
lv2_table_name          VARCHAR2(100);
lv2_table_where         class_db_mapping.db_where_condition%TYPE;
lv2_object_owner        class_db_mapping.db_object_owner%TYPE;
lb_join_owner_table     BOOLEAN := FALSE;
lv2_owner_class         class.owner_class_name%TYPE;
lv2_owner_class_type    class.cLass_type%TYPE;
lv2_rel_class_type      class.cLass_type%TYPE;
lv2_version_table       VARCHAR2(32);
lv2_main_table          VARCHAR2(32);
lb_use_object_id        BOOLEAN;
lv2_ue_user_function      VARCHAR2(1);
lv2_time_scope_code     class.TIME_SCOPE_CODE%TYPE;

BEGIN

   lv2_owner_class := EcDP_ClassMeta.OwnerClassName(p_class_name);
   lv2_time_scope_code := ec_class.time_scope_code(p_class_name);

   FOR Classes IN EcDp_ClassMeta.c_classes(p_class_name) LOOP
      lv2_object_owner := Classes.db_object_owner;
      lv2_table_where := Classes.db_where_condition;
      lv2_table_name := Classes.db_object_name;
   END LOOP;

   lb_use_object_id := ( lv2_owner_class IS NOT NULL );

   -- Need to determine whether we should join with owner table
   -- Owner table is joined if we have a daytime column and the owner class is of type OBJECT
   IF lb_use_object_id AND Nvl(lv2_time_scope_code,'EVENT') <> 'NONE' THEN

      lv2_owner_class_type := EcDp_ClassMeta.getClassType(lv2_owner_class);

      FOR curOwnerClass IN EcDp_ClassMeta.c_classes(lv2_owner_class) LOOP
         lv2_main_table := curOwnerClass.db_object_name;
         lv2_version_table := curOwnerClass.db_object_attribute;
      END LOOP;

      FOR curDatyimecheck IN EcDp_ClassMeta.c_classes_attr (p_class_name,'N', 'DAYTIME') LOOP
         lb_join_owner_table := (lv2_owner_class_type = 'OBJECT' AND curDatyimecheck.db_sql_syntax = 'DAYTIME' );
      END LOOP;

   END IF;

   AddUniqueViewColumns(lv2_sql_lines, 'CREATE OR REPLACE VIEW DV_'||p_class_name||'_JN AS SELECT '||CHR(10)||GeneratedCodeMsg);
   lv2_ue_user_function := EcDp_ClassMeta.IsUsingUserFunction();
   IF lv2_ue_user_function = 'Y'  THEN
   AddUniqueViewColumns(lv2_sql_lines,'JN_OPERATION AS JN_OPERATION,'||CHR(10)||
                        'ue_user.getusername(JN_ORACLE_USER) AS JN_ORACLE_USER, '||CHR(10)||
                        'JN_DATETIME AS JN_DATETIME,'||CHR(10)||
                        'JN_NOTES AS JN_NOTES,'||CHR(10)||
                        'JN_APPLN AS JN_APPLN,'||CHR(10)||
                        'JN_SESSION AS JN_SESSION,');
   ELSE
   AddUniqueViewColumns(lv2_sql_lines,'JN_OPERATION AS JN_OPERATION,'||CHR(10)||
                        'JN_ORACLE_USER AS JN_ORACLE_USER,'||CHR(10)||
                        'JN_DATETIME AS JN_DATETIME,'||CHR(10)||
                        'JN_NOTES AS JN_NOTES,'||CHR(10)||
                        'JN_APPLN AS JN_APPLN,'||CHR(10)||
                        'JN_SESSION AS JN_SESSION,');

    END IF;


   IF NOT ecdp_classmeta.IsValidAttribute(p_class_name, 'CLASS_NAME') THEN
      AddUniqueViewColumns(lv2_sql_lines,'''' || p_class_name || ''''||' AS CLASS_NAME,');
   END IF;

   IF lb_use_object_id THEN

      AddUniqueViewColumns(lv2_sql_lines, lv2_table_name||'_JN.OBJECT_ID AS OBJECT_ID,');

      IF lb_join_owner_table THEN
         AddUniqueViewColumns(lv2_sql_lines,'o.OBJECT_CODE OBJECT_CODE,');
      ELSIF lv2_owner_class_type = 'OBJECT' THEN
         AddUniqueViewColumns(lv2_sql_lines,EcDp_ClassMeta.GetEcPackage(lv2_owner_class)||'.object_code('||lv2_table_name||'_JN.object_id) AS OBJECT_CODE,');
      ELSE
         AddUniqueViewColumns(lv2_sql_lines,'EcDp_Objects.GetObjCode('||lv2_table_name||'_JN.object_id) AS OBJECT_CODE,');
      END IF;

   END IF;

   FOR ClassesAttr IN EcDp_ClassMeta.c_dataclasses_attr(p_class_name, 'N') LOOP

      IF UPPER(ClassesAttr.attribute_name) NOT IN ('OBJECT_ID','OBJECT_CODE') AND ClassesAttr.report_only_ind = 'N' THEN

         IF ClassesAttr.db_mapping_type = 'COLUMN' THEN
            AddUniqueViewColumns(lv2_sql_lines,lv2_table_name||'_JN.'||ClassesAttr.db_sql_syntax || ' AS ' || ClassesAttr.attribute_name ||',');
         ELSIF ClassesAttr.db_mapping_type = 'FUNCTION'  AND Nvl(ClassesAttr.is_key,'N') <> 'Y' THEN   --AND ClassesAttr.attribute_name NOT IN ('DATA_CLASS_NAME') THEN  -- For JN view replace function with NULL
         -- Might need some more exceptions here ...

            IF ClassesAttr.Data_type = 'DATE' THEN

               AddUniqueViewColumns(lv2_sql_lines, 'to_date(NULL) AS ' || ClassesAttr.attribute_name ||',');

            ELSIF   ClassesAttr.Data_type IN ('NUMBER','INTEGER') THEN

               AddUniqueViewColumns(lv2_sql_lines, 'to_number(NULL) AS ' || ClassesAttr.attribute_name ||',');

            ELSE

               AddUniqueViewColumns(lv2_sql_lines, 'to_char(NULL) AS ' || ClassesAttr.attribute_name ||',');

            END IF;

         ELSE
            AddUniqueViewColumns(lv2_sql_lines, ReplaceJNString(ClassesAttr.db_sql_syntax || ' AS ' || ClassesAttr.attribute_name ||',', lv2_table_name));
         END IF;

      END IF;

   END LOOP; -- Attributes

   FOR ClassesRel IN EcDp_ClassMeta.c_classes_rel(p_class_name) LOOP

      IF ClassesRel.report_only_ind = 'N' THEN

         lv2_rel_class_type := EcDp_ClassMeta.GetClassType(ClassesRel.from_class_name);

         IF ClassesRel.db_mapping_type = 'COLUMN' THEN
             AddUniqueViewColumns(lv2_sql_lines,lv2_table_name||'_JN.'||ClassesRel.db_sql_syntax||' AS '||ClassesRel.role_name||'_ID,');

            IF lv2_rel_class_type = 'OBJECT' THEN
              AddUniqueViewColumns(lv2_sql_lines,EcDp_ClassMeta.GetEcPackage(ClassesRel.from_class_name)||'.object_code('||lv2_table_name||'_JN.'||ClassesRel.db_sql_syntax||') AS ' || ClassesRel.role_name || '_CODE,');
          ELSE
             AddUniqueViewColumns(lv2_sql_lines,'EcDp_Objects.GetObjCode('||lv2_table_name||'_JN.'||ClassesRel.db_sql_syntax||') AS ' || ClassesRel.role_name || '_CODE,' );
          END IF;

         ELSE
             AddUniqueViewColumns(lv2_sql_lines, ReplaceJNString(ClassesRel.db_sql_syntax||' AS '||ClassesRel.role_name||'_ID,', lv2_table_name));

            IF lv2_rel_class_type = 'OBJECT' THEN
             AddUniqueViewColumns(lv2_sql_lines, ReplaceJNString(EcDp_ClassMeta.GetEcPackage(ClassesRel.from_class_name)||'.object_code('||ClassesRel.db_sql_syntax||') AS ' || ClassesRel.role_name || '_CODE,', lv2_table_name));
          ELSE
            AddUniqueViewColumns(lv2_sql_lines, ReplaceJNString('EcDp_Objects.GetObjCode('||ClassesRel.db_sql_syntax||') AS ' || ClassesRel.role_name || '_CODE,', lv2_table_name));
          END IF;
         END IF;

      END IF;

   END LOOP; -- Relations

   lv2_ue_user_function := EcDp_ClassMeta.IsUsingUserFunction();

   AddUniqueViewColumns(lv2_sql_lines,lv2_table_name||'_JN.RECORD_STATUS AS RECORD_STATUS,');

   if lv2_ue_user_function = 'N'  then

   AddUniqueViewColumns(lv2_sql_lines,lv2_table_name||'_JN.CREATED_BY AS CREATED_BY,');

    else

   AddUniqueViewColumns(lv2_sql_lines,'ue_user.getusername('||lv2_table_name||'_JN.CREATED_BY) AS CREATED_BY,');

   end if;

   AddUniqueViewColumns(lv2_sql_lines,lv2_table_name||'_JN.CREATED_DATE AS CREATED_DATE,');

   IF lv2_ue_user_function = 'N' then

   AddUniqueViewColumns(lv2_sql_lines,lv2_table_name||'_JN.LAST_UPDATED_BY AS LAST_UPDATED_BY,');

   ELSE

   AddUniqueViewColumns(lv2_sql_lines,'ue_user.getusername('||lv2_table_name||'_JN.LAST_UPDATED_BY) AS LAST_UPDATED_BY,');

   end if;

   AddUniqueViewColumns(lv2_sql_lines, lv2_table_name||'_JN.LAST_UPDATED_DATE AS LAST_UPDATED_DATE,');
   AddUniqueViewColumns(lv2_sql_lines, lv2_table_name||'_JN.REV_NO AS REV_NO,');
   AddUniqueViewColumns(lv2_sql_lines, lv2_table_name||'_JN.REV_TEXT AS REV_TEXT,') ;

   AddUniqueViewColumns(lv2_sql_lines, AddSafeViewColumn(lv2_table_name||'_JN','APPROVAL_STATE',lv2_object_owner,lv2_table_name||'_JN.')||',');
   AddUniqueViewColumns(lv2_sql_lines, AddSafeViewColumn(lv2_table_name||'_JN','APPROVAL_BY',lv2_object_owner,lv2_table_name||'_JN.')||',');
   AddUniqueViewColumns(lv2_sql_lines, AddSafeViewColumn(lv2_table_name||'_JN','APPROVAL_DATE',lv2_object_owner,lv2_table_name||'_JN.')||',');
   AddUniqueViewColumns(lv2_sql_lines, AddSafeViewColumn(lv2_table_name||'_JN','REC_ID',lv2_object_owner,lv2_table_name||'_JN.'));

   AddUniqueViewColumns(lv2_sql_lines, 'FROM '||lv2_table_name|| '_JN');

   IF lb_join_owner_table THEN
      AddUniqueViewColumns(lv2_sql_lines, ', '||lv2_version_table||' oa, '||lv2_main_table||' o');
      AddUniqueViewColumns(lv2_sql_lines, 'WHERE '||lv2_table_name||'_JN.object_id = oa.object_id');
      AddUniqueViewColumns(lv2_sql_lines, 'AND oa.object_id = o.object_id');

  --    lv2_time_scope_code := ec_class.time_scope_code(p_class_name);

      IF lv2_time_scope_code IN ('MTH','MONTH') THEN

         AddUniqueViewColumns(lv2_sql_lines,'AND '||lv2_table_name||'_JN.daytime >= TRUNC(oa.daytime,''MONTH'')');

         AddUniqueViewColumns(lv2_sql_lines,'AND oa.daytime = (');

         AddUniqueViewColumns(lv2_sql_lines,'SELECT MIN(daytime) FROM '||lv2_version_table||' v2');
         AddUniqueViewColumns(lv2_sql_lines,'WHERE v2.object_id = oa.object_id');
         AddUniqueViewColumns(lv2_sql_lines,'AND   '||lv2_table_name||'_JN.daytime >= trunc(v2.daytime,''MONTH'')');
         AddUniqueViewColumns(lv2_sql_lines,'AND '||lv2_table_name||'_JN.daytime < nvl(v2.end_date,'||lv2_table_name||'_JN.daytime + 1))');

      ELSIF lv2_time_scope_code IN ('YR','YEAR') THEN

         AddUniqueViewColumns(lv2_sql_lines,'AND '||lv2_table_name||'_JN.daytime >= TRUNC(oa.daytime,''YEAR'')');

         AddUniqueViewColumns(lv2_sql_lines,'AND oa.daytime = (');

         AddUniqueViewColumns(lv2_sql_lines,'SELECT MIN(daytime) FROM '||lv2_version_table||' v2');
         AddUniqueViewColumns(lv2_sql_lines,'WHERE v2.object_id = oa.object_id');
         AddUniqueViewColumns(lv2_sql_lines,'AND   '||lv2_table_name||'_JN.daytime >= trunc(v2.daytime,''YEAR'')');
         AddUniqueViewColumns(lv2_sql_lines,'AND '||lv2_table_name||'_JN.daytime < nvl(v2.end_date,'||lv2_table_name||'_JN.daytime + 1))');


      ELSE

         AddUniqueViewColumns(lv2_sql_lines,'AND '||lv2_table_name||'_JN.daytime >= oa.daytime');
         AddUniqueViewColumns(lv2_sql_lines,'AND '||lv2_table_name||'_JN.daytime < nvl(oa.end_date,'||lv2_table_name||'_JN.daytime + 1)');

      END IF;



      IF lv2_table_where IS NOT NULL THEN
          AddUniqueViewColumns(lv2_sql_lines,'AND'||ReplaceJNString(' '||lv2_table_where, lv2_table_name));
      END IF;

   ELSE

      IF lv2_table_where IS NOT NULL THEN

            AddUniqueViewColumns(lv2_sql_lines,CHR(10)||'WHERE'||ReplaceJNString(' '||lv2_table_where, lv2_table_name));

      END IF;

   END IF;

   -- SafeBuild('DV_'||p_class_name,'VIEW',lv2_sql_lines,p_target);

   -- Use the same sql to create journal view with a few modifications
   -- Only if journal table exists
   IF EcDp_GenClassCode.TableExists(lv2_table_name||'_JN',lv2_object_owner) THEN

      EcDp_Dynsql.SafeBuild('DV_'||p_class_name||'_JN','VIEW',lv2_sql_lines ,p_target, p_lfflg => 'Y');

   END IF;

END DataClassJNView;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : IUTrgApprovalStateHandling
-- Description    : Generate approval state handling code for IU triggers.
--
-- Preconditions  :
--
-- Postcondition  :
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
FUNCTION IUTrgApprovalStateVariables(
   p_class_name  IN VARCHAR2
)
RETURN DBMS_SQL.varchar2a
--</EC-DOC>
IS
  body_lines DBMS_SQL.varchar2a;
BEGIN
  Ecdp_Dynsql.AddSqlLine(body_lines,'   o_approval_state  VARCHAR2(1) := :OLD.approval_state;'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'   o_approval_by     VARCHAR2(30) := :OLD.approval_by;'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'   o_approval_date   DATE := :OLD.approval_date;'||CHR(10));

  if ecdp_classmeta.getClassAttrDbSqlSyntax(p_class_name,'REC_ID') is null then
    Ecdp_Dynsql.AddSqlLine(body_lines,'   o_rec_id          VARCHAR2(32) := :OLD.rec_id;'||CHR(10));
  end if;

  Ecdp_Dynsql.AddSqlLine(body_lines,'   n_approval_state  VARCHAR2(1) := :NEW.approval_state;'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'   n_approval_by     VARCHAR2(30) := :NEW.approval_by;'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'   n_approval_date   DATE := :NEW.approval_date;'||CHR(10));

  if ecdp_classmeta.getClassAttrDbSqlSyntax(p_class_name,'REC_ID') is null then
    Ecdp_Dynsql.AddSqlLine(body_lines,'   n_rec_id          VARCHAR2(32) := :NEW.rec_id;'||CHR(10));
  end if;

  RETURN body_lines;
END IUTrgApprovalStateVariables;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : IUTrgApprovalStateHandling
-- Description    : Generate approval state handling code for IU triggers.
--
-- Preconditions  :
--
-- Postcondition  :
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
FUNCTION IUTrgApprovalStateHandling(
   p_class_name  IN VARCHAR2,
   p_class_type  IN VARCHAR2
)
RETURN DBMS_SQL.varchar2a
--</EC-DOC>
IS
  body_lines DBMS_SQL.varchar2a;
BEGIN
  Ecdp_Dynsql.AddSqlLine(body_lines,'      -- Check new approval_state.'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'      IF Nvl(n_approval_state,''N'') NOT IN (''N'',''O'',''U'',''D'') THEN'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'        IF INSERTING THEN'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'           Raise_Application_Error(-20100,''New approval_state value ''||n_approval_state||'' is unknown.'');'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'        ELSIF UPDATING THEN'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'           Raise_Application_Error(-20101,''New approval_state value ''||n_approval_state||'' is unknown.'');'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'        END IF;'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'      END IF;'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'      -- Check old approval_state.'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'      IF Nvl(o_approval_state,''N'') NOT IN (''N'',''O'',''U'',''D'') THEN'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'        IF INSERTING THEN'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'           Raise_Application_Error(-20100,''Old approval_state value ''||o_approval_state||'' is unknown.'');'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'        ELSIF UPDATING THEN'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'           Raise_Application_Error(-20101,''Old approval_state value ''||o_approval_state||'' is unknown.'');'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'        ELSIF DELETING THEN'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'           Raise_Application_Error(-20102,''Old approval_state value ''||o_approval_state||'' is unknown.'');'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'        END IF;'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'      END IF;'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'      '||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'      IF INSERTING THEN'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'         n_approval_state := Nvl(n_approval_state,''N'');'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'         IF n_approval_state IN (''U'',''D'') THEN'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'            Raise_Application_Error(-20100,''Not allowed to insert '||p_class_name||' object with approval_state ''||n_approval_state||''.'');'|| CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'         END IF;'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'         IF n_rec_id IS NULL AND n_approval_state = ''N'' THEN'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'            n_rec_id := SYS_GUID();'|| CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'         END IF;'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'         IF n_approval_state = ''N'' THEN'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'            IF n_approval_by IS NOT NULL OR n_approval_date IS NOT NULL THEN'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'               Raise_Application_Error(-20100,''Not allowed to set the approved_by and approved_date for an object with approval_state N.'');'|| CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'            END IF;'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'         ELSIF n_approval_state = ''O'' THEN'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'            n_approval_by := Nvl(n_approval_by, Nvl(EcDp_Context.getAppUser, User));'|| CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'            n_approval_date := Nvl(n_approval_date, EcDp_Date_Time.getCurrentSysdate);'|| CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'            n_rec_id := SYS_GUID();'|| CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'         END IF;'||CHR(10));

  IF p_class_type='OBJECT' THEN
    Ecdp_Dynsql.AddSqlLine(body_lines,'      ELSIF lb_new_version THEN'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         n_approval_state := ''N'';'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         n_approval_by := null;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         n_approval_date := null;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         n_rec_id := SYS_GUID();'||CHR(10));
  END IF;

  Ecdp_Dynsql.AddSqlLine(body_lines,'      ELSIF UPDATING THEN'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'         IF EcDp_Approval.InApprovalMode = FALSE  THEN '||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'            IF o_approval_state = ''D'' THEN'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'               Raise_Application_Error(-20101,''Not allowed to update '||p_class_name||' object that is marked for deletion.'');'|| CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'            END IF;'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'            IF n_approval_state IS NOT NULL AND n_approval_state!=o_approval_state THEN'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'               Raise_Application_Error(-20101,''Not allowed to update the approval_state of '||p_class_name||' records.'');'|| CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'            END IF;'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'            IF o_approval_state IS NULL THEN '||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'               o_approval_state := ''O'';'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'            END IF;'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'            IF o_approval_state = ''O'' THEN '||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'               n_approval_state := ''U'';'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'            ELSE'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'               n_approval_state := o_approval_state;'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'            END IF;'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'            IF o_rec_id IS NULL THEN'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'               n_rec_id := SYS_GUID();'|| CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'            ELSIF n_rec_id IS NULL THEN'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'               n_rec_id := o_rec_id;'|| CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'            ELSIF n_rec_id != o_rec_id THEN'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'               Raise_Application_Error(-20101,''Explicit update of rec_id is not supported.'');'|| CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'            END IF;'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'            n_approval_by := null;'|| CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'            n_approval_date := null;'|| CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'         END IF;'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'         -- EcDp_Approval.Accept and EcDp_Approval.Reject will set the new approval columns correctly'|| CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'         -- and will insert/update the appropriate task_detail records.'|| CHR(10));

  IF p_class_type!='OBJECT' THEN
    Ecdp_Dynsql.AddSqlLine(body_lines,'      ELSIF DELETING THEN'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         IF EcDp_Approval.InApprovalMode = FALSE THEN'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'            IF o_approval_state=''D'' THEN'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'               Raise_Application_Error(-20102,''Not allowed to delete '||p_class_name||' record that has already been marked for deletion.'');'|| CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'            ELSIF o_approval_state!=''N'' THEN'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'               -- Old approval_state is ''U'' or ''O'''||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'               IF o_rec_id IS NULL THEN'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'                  n_rec_id := SYS_GUID();'|| CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'               ELSE'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'                  n_rec_id := o_rec_id;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'               END IF;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'               n_approval_by := null;'|| CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'               n_approval_date := null;'|| CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'               n_approval_state := ''D'';'|| CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'            END IF;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         END IF;'||CHR(10));
  END IF;

  Ecdp_Dynsql.AddSqlLine(body_lines,'      END IF;'||CHR(10));
  RETURN body_lines;

END IUTrgApprovalStateHandling;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : ObjectClassViewIUTrg
-- Description    : Generate InsteadOfTrigger for object views, class definition of type OBJECT
--
-- Preconditions  : p_class_name must refer to a class of type OBJECT
--                  Class_attribute and class_attr_db_mapping must be configured for class.
--
--
--
-- Postcondition  : Trigger generated or error logged in t_temptext.
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
PROCEDURE ObjectClassViewIUTrg(
   p_class_name  VARCHAR2,
   p_daytime     DATE,
   p_target      VARCHAR2 DEFAULT 'CREATE'
)
--</EC-DOC>

IS

  CURSOR c_non_version_attributes IS -- Attributes stored on main table
   SELECT ca.attribute_name, cadm.db_sql_syntax
   FROM class_attribute ca, class_attr_db_mapping cadm
   WHERE ca.class_name = cadm.class_name
   AND   ca.attribute_name = cadm.attribute_name
   AND   ca.class_name = p_class_name
   AND   cadm.db_mapping_type = 'COLUMN'
   AND   UPPER(TRIM(ca.attribute_name)) NOT IN ('OBJECT_START_DATE','OBJECT_END_DATE','OBJECT_ID','CODE')
   AND   Nvl(ca.disabled_ind,'N') = 'N'
   AND   Nvl(ca.report_only_ind,'N') = 'N';

  CURSOR c_non_version_relations IS -- Relations stored on main table
   SELECT cr.from_class_name, cr.to_class_name, cr.role_name, crdm.db_sql_syntax
   FROM class_relation cr, class_rel_db_mapping crdm
   WHERE cr.from_class_name = crdm.from_class_name
   AND   cr.to_class_name = crdm.to_class_name
   AND   cr.role_name = crdm.role_name
   AND   cr.to_class_name = p_class_name
   AND   crdm.db_mapping_type = 'COLUMN'
   AND   Nvl(cr.disabled_ind,'N') = 'N'
   AND   Nvl(cr.report_only_ind,'N') = 'N';

  CURSOR c_class_attr_process IS -- Get all attributes named 'CAN_PROC_<X>'
   SELECT attribute_name
   FROM class_attribute
   WHERE class_name = p_class_name
   AND   UPPER(attribute_name) LIKE 'CAN\_PROC\_%' escape '\'
   AND   Nvl(context_code,'X') IN ('EC_FRMW','EC_PROD','EC_TRAN','EC_SALE');

  CURSOR c_group_ancestor_attribute IS -- Group relation on "grandfather or older" level
    SELECT role_name, db_sql_syntax
    FROM dao_meta
    WHERE class_name = p_class_name
    AND is_relation = 'Y'
    AND is_popup = 'N'
    AND is_relation_code = 'N'
    AND group_type IS NOT NULL
    AND Nvl(is_report_only,'N') = 'N'
    AND db_mapping_type <> 'FUNCTION' -- Skip any mappings of type FUNCTION
    AND is_read_only = 'Y';

  CURSOR c_class IS
   SELECT   c.class_name,
         c.class_type,
         Nvl(c.read_only_ind,'N') read_only_ind,
         cdm.db_object_name,
         cdm.db_object_attribute,
         cdm.db_object_owner,
         c.journal_rule_db_syntax if_condition,
         c.lock_rule,
         c.lock_ind,
         c.access_control_ind,
        approval_ind
   FROM class c, class_db_mapping cdm
   WHERE c.class_name = cdm.class_name
   AND   c.class_name = p_class_name;

   CURSOR c_nongroup_class_relations IS
  SELECT  property_name attribute_name,
         data_type,
         is_key,
         is_mandatory,
         UPPER(LTRIM(RTRIM(Nvl(db_mapping_type,'X')))) db_mapping_type,
         db_sql_syntax,
         is_relation,
         is_relation_code,
         group_type,
         role_name,
         is_read_only,
         rel_class_name
   FROM dao_meta
   WHERE class_name = p_class_name
   AND   property_name  = Nvl(NULL,property_name )
   AND   Nvl(is_report_only,'N') = 'N'
   AND   is_popup = 'N'
   AND   is_relation = 'Y'
   AND   group_type IS NULL
   ORDER BY sort_order nulls last,property_name;

   CURSOR c_class_group_types IS
   SELECT DISTINCT group_type
   FROM class_relation
   WHERE to_class_name = p_class_name
   AND   group_type IS NOT NULL;

   CURSOR c_group_class_relations(p_group_type VARCHAR2) IS
  SELECT  property_name attribute_name,
         data_type,
         is_key,
         is_mandatory,
         UPPER(LTRIM(RTRIM(Nvl(db_mapping_type,'X')))) db_mapping_type,
         db_sql_syntax,
         is_relation,
         is_relation_code,
         group_type,
         role_name,
         is_read_only,
         rel_class_name
   FROM dao_meta
   WHERE class_name = p_class_name
   AND   property_name  = Nvl(NULL,property_name )
   AND   Nvl(is_report_only,'N') = 'N'
   AND   is_popup = 'N'
   AND   is_relation = 'Y'
   AND   group_type = p_group_type
   AND   UPPER(LTRIM(RTRIM(Nvl(db_mapping_type,'X')))) <> 'FUNCTION'  -- Skip any mappings of type FUNCTION
   ORDER BY sort_order nulls last,property_name;

  -- Relations that should trigger an ACL refresh
  CURSOR c_acl_class_relations_refresh IS
  SELECT  property_name attribute_name,
         data_type,
         is_key,
         is_mandatory,
         UPPER(LTRIM(RTRIM(Nvl(db_mapping_type,'X')))) db_mapping_type,
         db_sql_syntax,
         is_relation,
         is_relation_code,
         group_type,
         role_name,
         is_read_only,
         rel_class_name,
        access_control_method
   FROM dao_meta
   WHERE class_name = p_class_name
   AND   Nvl(access_control_method,'NA') IN ('FROM_CLASS','TO_CLASS')
   AND   is_popup = 'N'
   AND   is_relation = 'Y'
   ORDER BY sort_order nulls last,property_name;

  -- Relations that require an ACL lookup to determine whether the current user has access to the referenced object
  CURSOR c_acl_class_relations_lookup IS
  SELECT  m.property_name attribute_name,
         m.data_type,
         m.is_key,
         m.is_mandatory,
         UPPER(LTRIM(RTRIM(Nvl(m.db_mapping_type,'X')))) db_mapping_type,
         m.db_sql_syntax,
         m.is_relation,
         m.is_relation_code,
         m.group_type,
         m.role_name,
         m.is_read_only,
         m.rel_class_name,
        c.access_control_ind
   FROM dao_meta m
   ,    class c
   WHERE m.class_name = p_class_name
   AND   m.is_popup = 'N'
   AND   m.is_relation = 'Y'
   AND   m.is_relation_code='N'
   AND   m.db_mapping_type IN ('COLUMN','ATTRIBUTE')
   AND   c.class_name=m.rel_class_name
   AND   NVL(c.access_control_ind,'N')='Y'
   ORDER BY m.sort_order nulls last,m.property_name;


   -- For nav model syncronisation must also handle that this relation can go other way, hence the union
   CURSOR c_nav_model IS
   SELECT n.from_class_name,
          n.to_class_name,
          n.role_name,
          db.db_mapping_type,
          db.db_sql_syntax,
          n.multiplicity
   FROM class_relation cr, nav_model n, class_rel_db_mapping db
   WHERE cr.from_class_name = n.from_class_name
   AND   cr.to_class_name = n.to_class_name
   AND   cr.role_name = n.role_name
   and   cr.from_class_name = db.from_class_name
   AND   cr.to_class_name = db.to_class_name
   AND   cr.role_name = db.role_name
   AND   n.multiplicity IN ('1:N','1:1')
   AND   cr.to_class_name = p_class_name
   UNION ALL
   SELECT n.from_class_name,
          n.to_class_name,
          n.role_name,
          db.db_mapping_type,
          db.db_sql_syntax,
          n.multiplicity
   FROM class_relation cr, nav_model n, class_rel_db_mapping db
   WHERE cr.from_class_name = n.to_class_name
   AND   cr.to_class_name = n.from_class_name
   AND   cr.role_name = n.role_name
   and   cr.from_class_name = db.from_class_name
   AND   cr.to_class_name = db.to_class_name
   AND   cr.role_name = db.role_name
   AND   n.multiplicity IN ('N:1')
   AND   cr.to_class_name = p_class_name
   ;


  body_lines                DBMS_SQL.varchar2a;
  lv2_tmp_sql                VARCHAR2(32000);
  lv2_main_column_list      VARCHAR2(32000) := '';
  lv2_main_value_list        VARCHAR2(32000) := '';
  lv2_main_update_list      VARCHAR2(32000) := '';
  lv2_ver_column_list        VARCHAR2(32000) := '';
  lv2_ver_value_list        VARCHAR2(32000) := '';
  lv2_ver_update_list        VARCHAR2(32000) := '';
  lv2_main_table            class_db_mapping.db_object_name%TYPE;
  lv2_version_table          class_db_mapping.db_object_attribute%TYPE;
  lv2_schema_owner          class_db_mapping.db_object_owner%TYPE;
  lv2_is_read_only          class.read_only_ind%TYPE;
--  lv2_journal_if            class.journal_rule_db_syntax%TYPE;
  lb_use_locking            BOOLEAN;
  lb_rel_access_control     BOOLEAN:=FALSE;
  lb_class_access_control   BOOLEAN:=FALSE;
  lv2_new_varname           VARCHAR2(100);
  lv2_old_varname           VARCHAR2(100);
  lv2_lock_rule             VARCHAR2(200);
  lv2_tablename             VARCHAR2(100);
  lv2_owner_class           VARCHAR2(100) := EcDp_ClassMeta.OwnerClassName(p_class_name);
  lb_approval_enabled       BOOLEAN:=FALSE;
  lb_has_rec_id_column      BOOLEAN:=FALSE;

  lv2_std_main_insert_cols  VARCHAR2(500):='created_by,created_date,last_updated_by,last_updated_date,rev_no,rev_text,record_status';
  lv2_std_ver_insert_cols   VARCHAR2(500):='created_by,created_date,last_updated_by,last_updated_date,rev_no,rev_text,record_status';
  lv2_std_main_insert_vals  VARCHAR2(500):='n_created_by,n_created_date,n_last_updated_by,n_last_updated_date,0,n_rev_text,n_record_status';
  lv2_std_ver_insert_vals   VARCHAR2(500):='n_created_by,n_created_date,n_last_updated_by,n_last_updated_date,0,vt(ci).rev_text,n_record_status';
  lv2_std_main_update_list  VARCHAR2(500):='created_by=n_created_by,created_date=n_created_date,last_updated_by=n_last_updated_by,last_updated_date=n_last_updated_date,rev_no=n_main_rev_no,rev_text=n_rev_text,record_status=n_record_status';
  lv2_std_ver_update_list   VARCHAR2(500);

BEGIN


      IF EcDp_ClassMeta.IsUsingUserFunction() = 'N' THEN
      lv2_std_ver_update_list  :='created_by=n_created_by,created_date=n_created_date,last_updated_by=n_last_updated_by,last_updated_date=n_last_updated_date,rev_no=n_ver_rev_no,rev_text=vt(1).rev_text,record_status=n_record_status';
      ELSE
      lv2_std_ver_update_list  :='last_updated_by=n_last_updated_by,last_updated_date=n_last_updated_date,rev_no=n_ver_rev_no,rev_text=vt(1).rev_text,record_status=n_record_status';
      END IF;


  FOR curClass IN c_class LOOP

    lv2_main_table := curClass.db_object_name;
    lv2_version_table := curClass.db_object_attribute;
    lv2_schema_owner := curClass.db_object_owner;
    lv2_is_read_only := curClass.read_only_ind;
    lv2_tablename := curClass.db_object_name;

  --  lv2_journal_if   := curClass.if_condition;
    lb_approval_enabled := Nvl(curClass.approval_ind,'N')='Y';
    IF Nvl(curClass.lock_ind,'N') = 'Y' THEN
      lb_use_locking := TRUE ;
      lv2_lock_rule := curClass.lock_rule;
    ELSE
      lb_use_locking := FALSE ;
    END IF;

    IF Nvl(curClass.access_control_ind,'N') = 'Y' THEN
      lb_class_access_control := TRUE ;
    ELSE
      lb_class_access_control := FALSE ;
    END IF;

  END LOOP;

  -- No trigger will be generated for read only classes
  IF lv2_is_read_only = 'Y' THEN
    RETURN;
  END IF;

  -- create statement
   Ecdp_Dynsql.AddSqlLine(body_lines,'CREATE OR REPLACE TRIGGER IUD_'||p_class_name||CHR(10)||' INSTEAD OF INSERT OR UPDATE OR DELETE ON OV_'|| p_class_name||CHR(10));
   -- declare section
   Ecdp_Dynsql.AddSqlLine(body_lines,'FOR EACH ROW' || chr(10) || GeneratedCodeMsg || 'DECLARE' ||CHR(10));

   Ecdp_Dynsql.AddSqlLine(body_lines,'   CURSOR c_old_version_row(cp_object_id VARCHAR2) IS' || chr(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'    SELECT daytime'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'    FROM '||lv2_version_table||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'    WHERE object_id = cp_object_id'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'    ORDER BY daytime;'|| chr(10)||CHR(10));

   Ecdp_Dynsql.AddSqlLine(body_lines,'   CURSOR c_prev_version_row(cp_object_id  VARCHAR2, cp_daytime DATE) IS'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'    SELECT *'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'    FROM '||lv2_version_table||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'    WHERE object_id = cp_object_id'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'    AND daytime <= cp_daytime AND Nvl(end_date,cp_daytime + 1) > cp_daytime;'||CHR(10)||CHR(10));

   IF lb_use_locking AND lv2_lock_rule IS NULL THEN

     Ecdp_Dynsql.AddSqlLine(body_lines,'   CURSOR c_next_version(cp_object_id  VARCHAR2, cp_daytime DATE) IS'||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'    SELECT daytime'||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'    FROM '||lv2_version_table||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'    WHERE object_id = cp_object_id'||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'    AND daytime >= cp_daytime AND Nvl(end_date,cp_daytime + 1) > cp_daytime;'||CHR(10)||CHR(10));

   END IF;


    Ecdp_Dynsql.AddSqlLine(body_lines,'   lv2_operation           VARCHAR2(30);'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   lb_datechange           BOOLEAN := FALSE;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   lr_version_row          '||lv2_version_table||'%ROWTYPE;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   lr_curr_main_row         '||lv2_main_table||'%ROWTYPE;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   lr_curr_version_row      '||lv2_version_table||'%ROWTYPE;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   vt                       EcTp_'||p_class_name||'.ver_tab_type := EcTp_'||p_class_name||'.ver_tab_type();'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'   lb_must_allert_children   BOOLEAN := FALSE;'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'   lb_update_main_table      BOOLEAN := FALSE;'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'   lb_update_version_table  BOOLEAN := FALSE;'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'   lb_update_version_not_dt  BOOLEAN := FALSE;'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'   ld_prev_daytime           DATE := NULL;'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'   ln_version_count          NUMBER := 0;'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'   lb_new_version            BOOLEAN := FALSE;'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'   lv2_code_changed          VARCHAR2(1) := NULL;'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'   n_record_status           VARCHAR2(1);'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'   n_rev_text                VARCHAR2(4000);'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'   n_created_by              VARCHAR2(30);'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'   o_created_by              VARCHAR2(30) := :OLD.created_by;'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'   n_created_date            DATE;'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'   n_last_updated_by         VARCHAR2(30);'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'   o_last_updated_by         VARCHAR2(30) := :OLD.last_updated_by;'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'   n_last_updated_date       DATE;'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'   n_init_daytime           DATE;'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'   n_daytime                 DATE := :NEW.daytime;'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'   o_daytime                 DATE := :OLD.daytime;'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'   n_object_id               VARCHAR2(100) := SUBSTR(:NEW.object_id,1,32);'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'   o_object_id               VARCHAR2(100) := SUBSTR(:OLD.object_id,1,32);'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'   n_object_start_date       DATE := :NEW.object_start_date;'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'   o_object_start_date      DATE := :OLD.object_start_date;'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'   n_object_end_date         DATE := :NEW.object_end_date;'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'   o_object_end_date         DATE := :OLD.object_end_date;'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'   n_code                    VARCHAR2(100) := :NEW.code;'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'   n_main_rev_no             NUMBER := nvl(to_number(substr(:old.rev_no,0,InStr(:old.rev_no,''.'')-1)),0);'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'   n_ver_rev_no             NUMBER := nvl(to_number(substr(:old.rev_no,InStr(:old.rev_no,''.'')+1)),0);'||CHR(10));

   Ecdp_Dynsql.AddSqlLine(body_lines,'   n_lock_columns           EcDp_Month_lock.column_list;'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'   o_lock_columns           EcDp_Month_lock.column_list;'||CHR(10));

   lb_has_rec_id_column := ColumnExists(lv2_version_table,'REC_ID',lv2_schema_owner);
   IF lb_approval_enabled THEN
     -- We dont care about the main table
     lv2_std_main_insert_cols:=lv2_std_main_insert_cols;
     lv2_std_main_insert_vals:=lv2_std_main_insert_vals;
     lv2_std_main_update_list:=lv2_std_main_update_list;
     -- Add approval columns to version table
     lv2_std_ver_insert_cols:=lv2_std_ver_insert_cols||',approval_state,approval_by,approval_date,rec_id';
     lv2_std_ver_insert_vals:=lv2_std_ver_insert_vals||',n_approval_state,n_approval_by,n_approval_date,n_rec_id';
     lv2_std_ver_update_list:=lv2_std_ver_update_list||',approval_state=n_approval_state,approval_by=n_approval_by,approval_date=n_approval_date,rec_id=n_rec_id';

     Ecdp_Dynsql.AddSqlLines(body_lines, IUTrgApprovalStateVariables(p_class_name));
   ELSIF lb_has_rec_id_column THEN
     -- We dont care about the main table
     lv2_std_main_insert_cols:=lv2_std_main_insert_cols;
     lv2_std_main_insert_vals:=lv2_std_main_insert_vals;
     lv2_std_main_update_list:=lv2_std_main_update_list;

     lv2_std_ver_insert_cols:=lv2_std_ver_insert_cols||',rec_id';
     lv2_std_ver_insert_vals:=lv2_std_ver_insert_vals||',n_rec_id';
     lv2_std_ver_update_list:=lv2_std_ver_update_list||',rec_id=n_rec_id';

     Ecdp_Dynsql.AddSqlLine(body_lines,'   o_rec_id          VARCHAR2(32) := :OLD.rec_id;'||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'   n_rec_id          VARCHAR2(32) := :NEW.rec_id;'||CHR(10));
   END IF;

   IF lb_use_locking AND lv2_lock_rule IS NULL THEN

     Ecdp_Dynsql.AddSqlLine(body_lines,'   ld_next_daytime          DATE;'||CHR(10));

   END IF;


    FOR curAttr IN c_non_version_attributes LOOP

      Ecdp_Dynsql.AddSqlLine(body_lines,'   n_'||LOWER(curAttr.attribute_name)||'          '||lv2_main_table||'.'||curAttr.db_sql_syntax||'%TYPE := :NEW.'||curAttr.attribute_name||';'||CHR(10));

    END LOOP;

    FOR curRel IN c_non_version_relations LOOP

      Ecdp_Dynsql.AddSqlLine(body_lines,'   n_'||LOWER(curRel.role_name)      ||'_id       '||lv2_main_table||'.'||curRel.db_sql_syntax||'%TYPE := :NEW.'||curRel.role_name||'_ID'||';'||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'   n_'||LOWER(curRel.role_name)      ||'_co       '||lv2_main_table||'.object_code%TYPE := :NEW.'||curRel.role_name||'_CODE'||';'||CHR(10));

    END LOOP;

    FOR curRelCode IN EcDp_ClassMeta.c_classes_rel(p_class_name) LOOP -- since only relation_id for class relation is stored in vt-table, we need separate variables holding the code

      IF Nvl(curRelCode.disabled_ind,'N') = 'N' AND curRelCode.group_type IS NULL AND curRelCode.db_mapping_type = 'ATTRIBUTE' THEN

        Ecdp_Dynsql.AddSqlLine(body_lines,'   n_'||LOWER(curRelCode.role_name)      ||'_co       '||lv2_main_table||'.object_code%TYPE := NULL;'||CHR(10));

      END IF;

    END LOOP;

     -- code block
    Ecdp_Dynsql.AddSqlLine(body_lines,'BEGIN ' || chr(10) || chr(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   ----------------------------------------------------------------------------'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   -- Start Before trigger action block'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   -- Need to find object_id to foreign references given by code so this is available to trigger actions'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   -- Also set record status information'||CHR(10)||CHR(10));

    Ecdp_Dynsql.AddSqlLine(body_lines,'   -- Locate correct version used to initialize the version array'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   n_init_daytime := n_daytime;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   IF UPDATING(''OBJECT_START_DATE'') THEN'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      IF n_object_start_date <= o_object_start_date THEN -- Use first version'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         n_init_daytime := o_object_start_date;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      ELSE'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         n_init_daytime := n_object_start_date;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      END IF;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      lb_datechange := TRUE;'||CHR(10));

    Ecdp_Dynsql.AddSqlLine(body_lines,'   ELSIF UPDATING(''OBJECT_END_DATE'') THEN'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      IF n_object_end_date IS NULL OR n_object_end_date >= Nvl(o_object_end_date,n_object_end_date + 1) THEN  -- Use latest version'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         SELECT MAX(daytime) INTO n_init_daytime'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         FROM '||lv2_version_table||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         WHERE object_id = o_object_id;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      ELSIF n_object_end_date <> n_object_start_date THEN'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'        n_init_daytime := ec_'||LOWER(lv2_version_table)||'.prev_daytime(o_object_id,n_object_end_date);'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      END IF;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      lb_datechange := TRUE;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   END IF;'||CHR(10)||CHR(10));

    Ecdp_Dynsql.AddSqlLine(body_lines,'   OPEN c_prev_version_row(o_object_id,n_init_daytime);'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   FETCH c_prev_version_row INTO lr_version_row;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   CLOSE c_prev_version_row;'||CHR(10)||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   IF INSERTING OR UPDATING(''CODE'') ' );


    FOR curAttr IN c_non_version_attributes LOOP

       Ecdp_Dynsql.AddSqlLine(body_lines,' OR UPDATING('''||curAttr.attribute_name||''') ');

     END LOOP;

    FOR curRel IN c_non_version_relations LOOP

       Ecdp_Dynsql.AddSqlLine(body_lines,' OR UPDATING('''||curRel.role_name||'_ID'') OR UPDATING('''||curRel.role_name||'_CODE'') ');

    END LOOP;

    Ecdp_Dynsql.AddSqlLine(body_lines,' THEN'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      lb_update_main_table := TRUE;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   END IF;'||CHR(10)||CHR(10));

    Ecdp_Dynsql.AddSqlLine(body_lines,'   IF NOT DELETING THEN'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      vt.extend;'||CHR(10)||CHR(10));

    Ecdp_Dynsql.AddSqlLine(body_lines,'     IF UPDATING THEN'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'        vt(vt.LAST).object_id := o_object_id;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'     END IF;'||CHR(10)||CHR(10));

   FOR curAttr IN c_dao_class_attr(p_class_name) LOOP

     IF curAttr.db_mapping_type = 'ATTRIBUTE' AND
        NOT (curAttr.is_relation_code = 'Y' AND curAttr.group_type IS NULL) AND
        curAttr.is_read_only = 'N' THEN

        Ecdp_Dynsql.AddSqlLine(body_lines,'      IF INSERTING OR UPDATING('''||curAttr.attribute_name||''') THEN'||CHR(10));
        Ecdp_Dynsql.AddSqlLine(body_lines,'         vt(vt.LAST).'||LOWER(curAttr.db_sql_syntax)||' := :NEW.'||curAttr.attribute_name||';'||CHR(10));
        Ecdp_Dynsql.AddSqlLine(body_lines,'         lb_update_version_table := TRUE;'||CHR(10));

        IF curAttr.attribute_name <> 'DAYTIME' THEN

           Ecdp_Dynsql.AddSqlLine(body_lines,'         lb_update_version_not_dt := TRUE;'||CHR(10));
       ELSE
           Ecdp_Dynsql.AddSqlLine(body_lines,'         lb_datechange := TRUE;'||CHR(10));

        END IF;

        Ecdp_Dynsql.AddSqlLine(body_lines,'      ELSE'||CHR(10));
        Ecdp_Dynsql.AddSqlLine(body_lines,'         vt(vt.LAST).'||LOWER(curAttr.db_sql_syntax)||' := lr_version_row.'||curAttr.db_sql_syntax||';'||CHR(10));
        Ecdp_Dynsql.AddSqlLine(body_lines,'      END IF;'||CHR(10)||CHR(10));

       IF curAttr.is_relation = 'Y' AND curAttr.group_type IS NULL THEN -- Add relation code

          Ecdp_Dynsql.AddSqlLine(body_lines,'      IF INSERTING OR UPDATING('''||curAttr.role_name||'_CODE'') THEN'||CHR(10));
          Ecdp_Dynsql.AddSqlLine(body_lines,'         n_'||LOWER(curAttr.role_name)||'_co := :NEW.'||curAttr.role_name||'_CODE;'||CHR(10));
          Ecdp_Dynsql.AddSqlLine(body_lines,'         lb_update_version_table := TRUE;'||CHR(10));
         Ecdp_Dynsql.AddSqlLine(body_lines,'         lb_update_version_not_dt := TRUE;'||CHR(10));
          Ecdp_Dynsql.AddSqlLine(body_lines,'      ELSE'||CHR(10));
          Ecdp_Dynsql.AddSqlLine(body_lines,'         n_'||LOWER(curAttr.role_name)||'_co := EcDp_Objects.GetObjCode(vt(vt.LAST).'||LOWER(curAttr.db_sql_syntax)||');'||CHR(10));
          Ecdp_Dynsql.AddSqlLine(body_lines,'      END IF;'||CHR(10)||CHR(10));

       END IF;

     END IF;

   END LOOP;

   FOR curAttr2 IN c_dao_class_attr(p_class_name) LOOP

     IF curAttr2.db_mapping_type = 'ATTRIBUTE' AND
        curAttr2.group_type IS NOT NULL AND
        curAttr2.is_read_only = 'Y' THEN

        Ecdp_Dynsql.AddSqlLine(body_lines,'      IF NOT UPDATING('''||curAttr2.attribute_name||''') THEN'||CHR(10));
        Ecdp_Dynsql.AddSqlLine(body_lines,'         vt(vt.LAST).'||LOWER(curAttr2.db_sql_syntax)||' := lr_version_row.'||curAttr2.db_sql_syntax||';'||CHR(10));
        Ecdp_Dynsql.AddSqlLine(body_lines,'      END IF;'||CHR(10)||CHR(10));

     END IF;

   END LOOP;

    Ecdp_Dynsql.AddSqlLine(body_lines,'      IF INSERTING OR UPDATING(''RECORD_STATUS'') THEN'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         n_record_status := :NEW.RECORD_STATUS;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         lb_update_version_table := TRUE;'||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'         lb_update_version_not_dt := TRUE;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      ELSE'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         n_record_status := lr_version_row.RECORD_STATUS;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      END IF;'||CHR(10)||CHR(10));

    Ecdp_Dynsql.AddSqlLine(body_lines,'      IF INSERTING OR UPDATING(''CREATED_BY'') THEN'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         n_created_by := :NEW.CREATED_BY;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         lb_update_version_table := TRUE;'||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'         lb_update_version_not_dt := TRUE;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      ELSE'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         n_created_by := lr_version_row.CREATED_BY;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      END IF;'||CHR(10)||CHR(10));

    Ecdp_Dynsql.AddSqlLine(body_lines,'      IF INSERTING OR UPDATING(''CREATED_DATE'') THEN'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         n_created_date := :NEW.CREATED_DATE;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         lb_update_version_table := TRUE;'||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'         lb_update_version_not_dt := TRUE;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      ELSE'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         n_created_date := lr_version_row.CREATED_DATE;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      END IF;'||CHR(10)||CHR(10));

    Ecdp_Dynsql.AddSqlLine(body_lines,'      IF INSERTING OR UPDATING(''LAST_UPDATED_BY'') THEN'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         n_last_updated_by := :NEW.LAST_UPDATED_BY;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      ELSE'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         n_last_updated_by := lr_version_row.LAST_UPDATED_BY;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      END IF;'||CHR(10)||CHR(10));

    Ecdp_Dynsql.AddSqlLine(body_lines,'      IF INSERTING OR UPDATING(''LAST_UPDATED_DATE'') THEN'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         n_last_updated_date := :NEW.LAST_UPDATED_DATE;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      ELSE'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         n_last_updated_date := lr_version_row.LAST_UPDATED_DATE;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      END IF;'||CHR(10)||CHR(10));

    Ecdp_Dynsql.AddSqlLine(body_lines,'      IF INSERTING OR UPDATING(''REV_TEXT'') THEN'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         n_rev_text := :NEW.REV_TEXT;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         vt(vt.LAST).rev_text := :NEW.rev_text;'||CHR(10));

    Ecdp_Dynsql.AddSqlLine(body_lines,'      ELSE'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         n_rev_text := lr_version_row.REV_TEXT;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         vt(vt.LAST).rev_text := lr_version_row.REV_TEXT;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      END IF;'||CHR(10)||CHR(10));

    Ecdp_Dynsql.AddSqlLine(body_lines,'      n_daytime := vt(vt.LAST).daytime;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      o_daytime := lr_version_row.daytime;'||CHR(10)||CHR(10));

    -- Special handling for WELL, initialize all proc_node-columns
    IF p_class_name = 'WELL' THEN

      Ecdp_Dynsql.AddSqlLine(body_lines,'      vt(vt.LAST).proc_node_oil_id := lr_version_row.proc_node_oil_id;'||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'      vt(vt.LAST).proc_node_gas_id := lr_version_row.proc_node_gas_id;'||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'      vt(vt.LAST).proc_node_cond_id := lr_version_row.proc_node_cond_id;'||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'      vt(vt.LAST).proc_node_water_id := lr_version_row.proc_node_water_id;'||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'      vt(vt.LAST).proc_node_water_inj_id := lr_version_row.proc_node_water_inj_id;'||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'      vt(vt.LAST).proc_node_gas_inj_id := lr_version_row.proc_node_gas_inj_id;'||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'      vt(vt.LAST).proc_node_diluent_id := lr_version_row.proc_node_diluent_id;'||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'      vt(vt.LAST).proc_node_steam_inj_id := lr_version_row.proc_node_steam_inj_id;'||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'      vt(vt.LAST).proc_node_gas_lift_id := lr_version_row.proc_node_gas_lift_id;'||CHR(10)||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'      vt(vt.LAST).proc_node_co2_id := lr_version_row.proc_node_co2_id;'||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'      vt(vt.LAST).proc_node_co2_inj_id := lr_version_row.proc_node_co2_inj_id;'||CHR(10));


    END IF;

    Ecdp_Dynsql.AddSqlLine(body_lines,'   END IF; -- Not deleting'||CHR(10)||CHR(10));

    Ecdp_Dynsql.AddSqlLine(body_lines,'   -- Support update of only rev_text or last_updated_by/date, need to find correct table'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   IF UPDATING AND NOT lb_update_main_table AND NOT lb_update_version_table AND NOT UPDATING(''OBJECT_START_DATE'') AND NOT UPDATING(''OBJECT_END_DATE'') THEN'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      IF UPDATING(''REV_TEXT'') OR UPDATING(''LAST_UPDATED_BY'') OR UPDATING(''LAST_UPDATED_DATE'') THEN'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         lr_curr_main_row := ec_'||lv2_main_table||'.row_by_pk(o_object_id);'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         lr_curr_version_row := ec_'||lv2_version_table||'.row_by_pk(o_object_id,o_daytime);'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         IF NVL(lr_curr_main_row.last_updated_date,lr_curr_main_row.created_date) > NVL(lr_curr_version_row.last_updated_date,lr_curr_version_row.created_date) THEN'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'            lb_update_main_table := TRUE;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         ELSE'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'            lb_update_version_table := TRUE;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         END IF;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      END IF;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   END IF;'||CHR(10)||CHR(10));


    Ecdp_Dynsql.AddSqlLine(body_lines,EcDp_ClassJournalHelper.makeObjectRuleSection(p_class_name));


    Ecdp_Dynsql.AddSqlLine(body_lines,'   IF INSERTING THEN'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      IF EcDp_objects.GetObjIDFromCode('''||p_class_name||''',n_code) IS NOT NULL  THEN Raise_Application_Error(-20105,''This code is already used within this class.''); END IF;'|| chr(10));

   -- Default values
   FOR ClassesAttrDef IN EcDp_ClassMeta.c_classes_attr(p_class_name) LOOP

      IF ClassesAttrDef.report_only_ind = 'N' AND ClassesAttrDef.default_value IS NOT NULL THEN

        IF ClassesAttrDef.db_mapping_type = 'COLUMN' THEN

           Ecdp_Dynsql.AddSqlLine(body_lines,'      IF n_' || LOWER(ClassesAttrDef.attribute_name) ||' IS NULL THEN n_' || ClassesAttrDef.attribute_name || ' := ' ||ClassesAttrDef.default_value ||'; END IF;'|| chr(10));

        ELSIF ClassesAttrDef.db_mapping_type = 'ATTRIBUTE' THEN

           Ecdp_Dynsql.AddSqlLine(body_lines,'      IF vt(vt.LAST).' || LOWER(ClassesAttrDef.db_sql_syntax) ||' IS NULL THEN vt(vt.LAST).' || LOWER(ClassesAttrDef.db_sql_syntax) || ' := ' ||ClassesAttrDef.default_value ||'; END IF;'|| chr(10));

        END IF;

      END IF;

   END LOOP; -- Default values

    Ecdp_Dynsql.AddSqlLine(body_lines,'      IF :NEW.class_name IS NOT NULL  AND rtrim(upper(:new.class_name)) <> rtrim(upper('''||p_class_name||''')) THEN Raise_Application_Error(-20104,''Given class_name do not correspond to view class name.''); END IF;'||CHR(10)||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      n_object_id := EcDp_objects.GetInsertedObjectID(n_object_id);'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      n_daytime := EcDp_objects.GetInsertedDaytime(n_object_start_date,n_daytime, n_object_end_date);'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      n_object_start_date := n_daytime; '||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      n_created_by := Nvl(n_created_by,USER);'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      n_created_date := Nvl(n_created_date,EcDp_Date_time.getCurrentSysdate);'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      n_last_updated_by := NULL;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      n_last_updated_date := NULL;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      vt(vt.LAST).object_id := n_object_id;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      vt(vt.LAST).daytime := n_daytime;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      vt(vt.LAST).end_date := n_object_end_date;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      vt(vt.LAST).created_by := n_created_by;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      vt(vt.LAST).created_date := n_created_date;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      vt(vt.LAST).last_updated_by := n_last_updated_by;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      vt(vt.LAST).last_updated_date := n_last_updated_date;'||CHR(10)||CHR(10));

   IF lb_use_locking AND lv2_lock_rule IS NULL THEN

     Ecdp_Dynsql.AddSqlLine(body_lines,'   --------------------------------------------------------------------------------------------------------------'||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'   -- Check if Insert violates locked months, in that case this procedure will raise an appropriate error message'||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'   EcDp_Month_lock.validatePeriodForLockOverlap(''INSERTING'',n_daytime,n_object_end_date,''CLASS: '||p_class_name||'; OBJECT_CODE:''||n_code, n_object_id);'||CHR(10)||CHR(10));

   END IF;



    Ecdp_Dynsql.AddSqlLine(body_lines,'      -- Start Insert relation block'||CHR(10));

    -- Handle first non group relations
    FOR curRel IN  c_nongroup_class_relations LOOP

     IF SubStr(curRel.attribute_name, Length(curRel.attribute_name) - 2) = '_ID' THEN -- Ignore code, use id.

      -- versioned
      IF curRel.db_mapping_type = 'ATTRIBUTE' THEN

         Ecdp_Dynsql.AddSqlLine(body_lines,'      vt(vt.LAST).'||LOWER(curRel.db_sql_syntax)||' := EcDp_Objects.GetInsertedRelationID('''||curRel.role_name||''','''||curRel.rel_class_name||''',vt(vt.LAST).'||curRel.db_sql_syntax||',n_'||LOWER(curRel.role_name)||'_co,n_daytime);'||CHR(10)||CHR(10));

      ELSIF curRel.db_mapping_type = 'COLUMN' THEN -- not versioned

         Ecdp_Dynsql.AddSqlLine(body_lines,'      n_'||LOWER(curRel.role_name)||'_id := EcDp_Objects.GetInsertedRelationID('''||curRel.role_name||''','''||curRel.rel_class_name||''',n_'||LOWER(curRel.role_name)||'_id,n_'||LOWER(curRel.role_name)||'_co,n_daytime);'||CHR(10)||CHR(10));

      END IF;

     END IF;

   END LOOP; -- curRel

   -- Group relations, first Loop the different group types this class is part of
   FOR curGroupType IN  c_class_group_types  LOOP

    FOR curRel2 IN  c_group_class_relations(curGroupType.group_type) LOOP

     IF SubStr(curRel2.attribute_name, Length(curRel2.attribute_name) - 2) = '_ID' THEN -- Ignore code, use id.

       IF curRel2.is_read_only = 'N' THEN  -- group relation on parent level

          Ecdp_Dynsql.AddSqlLine(body_lines,'      vt(vt.LAST).'||LOWER(curRel2.db_sql_syntax)||' := EcDp_Objects.GetInsertedRelationID('''||curRel2.role_name||''','''||curRel2.rel_class_name||''',vt(vt.LAST).'||LOWER(curRel2.db_sql_syntax)||',vt(vt.LAST).'||LOWER(REPLACE(curRel2.db_sql_syntax,'_ID','_CODE'))||',n_daytime);'||CHR(10));
          Ecdp_Dynsql.AddSqlLine(body_lines,'      vt(vt.LAST).'||LOWER(REPLACE(curRel2.db_sql_syntax,'_ID','_CODE'))||' := '||LOWER(EcDp_ClassMeta.GetEcPackage(curRel2.rel_class_name))||'.object_code(vt(vt.LAST).'||LOWER(curRel2.db_sql_syntax)||'); -- Keep code and id in sync'||CHR(10)||CHR(10));

       END IF;

     END IF;

    END LOOP; --Currel2





    Ecdp_Dynsql.AddSqlLine(body_lines,'      vt := EcTp_'||p_class_name||'.AlignParentVersions(vt,'''||curGroupType.group_type||''');'||CHR(10)||CHR(10));


   END LOOP; -- curGroupType

    Ecdp_Dynsql.AddSqlLine(body_lines,'      -- End Insert relation block ------'||CHR(10)||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   ELSIF UPDATING THEN'||CHR(10)||CHR(10));

    Ecdp_Dynsql.AddSqlLine(body_lines,'      -- Start other check'|| chr(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      IF UPDATING(''CLASS_NAME'') AND rtrim(upper(:new.class_name)) <> rtrim(upper('''||p_class_name||''')) THEN Raise_Application_Error(-20104,''Given class_name do not correspond to view class name.''); END IF;'|| chr(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      IF Updating(''OBJECT_ID'') THEN'|| CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          IF NOT (Nvl(:NEW.object_id,''NULL'') = :OLD.object_id) THEN'|| CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'             Raise_Application_Error(-20101,''Cannot update object_id '');'|| CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          END IF;'|| CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      END IF;'|| CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      IF Updating(''END_DATE'') THEN Raise_Application_Error(-20101,''Cannot update version end_date, controlled by system ''); END IF;'|| chr(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      -- End other check'|| chr(10)|| chr(10));


   -- Populate parameters for lock function
   IF lb_use_locking AND lv2_lock_rule IS NOT NULL THEN

     Ecdp_Dynsql.AddSqlLine(body_lines,'  EcDp_month_lock.AddParameterToList(n_lock_columns'||
                                                       ',''CLASS_NAME'''||
                                                       ','''||UPPER(p_class_name)||''''||
                                                       ',''STRING''' ||
                                                       ',NULL' ||
                                                       ',NULL' ||
                                                       ',NULL);'||CHR(10));

     Ecdp_Dynsql.AddSqlLine(body_lines,'  EcDp_month_lock.AddParameterToList(n_lock_columns'||
                                                       ',''TABLE_NAME'''||
                                                       ','''||UPPER(lv2_tablename)||''''||
                                                       ',''STRING''' ||
                                                       ',NULL' ||
                                                       ',NULL' ||
                                                       ',NULL);'||CHR(10));

     Ecdp_Dynsql.AddSqlLine(body_lines,'  EcDp_month_lock.AddParameterToList(o_lock_columns'||
                                                       ',''CLASS_NAME'''||
                                                       ','''||UPPER(p_class_name)||''''||
                                                       ',''STRING''' ||
                                                       ',NULL' ||
                                                       ',NULL' ||
                                                       ',NULL);'||CHR(10));

     Ecdp_Dynsql.AddSqlLine(body_lines,'  EcDp_month_lock.AddParameterToList(o_lock_columns'||
                                                       ',''TABLE_NAME'''||
                                                       ','''||UPPER(lv2_tablename)||''''||
                                                       ',''STRING''' ||
                                                       ',NULL' ||
                                                       ',NULL' ||
                                                       ',NULL);'||CHR(10));


     FOR ClassesAttr_lock IN EcDp_ClassMeta.c_classes_attr(p_class_name, 'N') LOOP

        IF ClassesAttr_lock.db_mapping_type = 'COLUMN'
        AND NOT ClassesAttr_lock.attribute_name IN('CREATED_BY','CREATED_DATE','LAST_UPDATED_BY','LAST_UPDATED_DATE','REV_NO','REV_TEXT','RECORD_STATUS')
        AND ClassesAttr_lock.report_only_ind = 'N'
        AND ClassesAttr_lock.data_type IN ('STRING','NUMBER','INTEGER','DATE','VARCHAR2')
        THEN


            Ecdp_Dynsql.AddSqlLine(body_lines,'  EcDp_month_lock.AddParameterToList(n_lock_columns'||
                                                     ','''||UPPER(ClassesAttr_lock.attribute_name)||''''||
                                                     ','''||UPPER(ClassesAttr_lock.db_sql_syntax)||''''||
                                                     ','''||UPPER(ClassesAttr_lock.data_type)||''''||
                                                     ','''||Nvl(ClassesAttr_lock.is_key,'N')||''''||
                                                     ',EcDp_month_lock.isUpdating(UPDATING('''||UPPER(ClassesAttr_lock.attribute_name)||''')),'||
                                                     ecdp_dynsql.Anydata_to_String(ClassesAttr_lock.data_type,'n_'||ClassesAttr_lock.attribute_name)||');'||CHR(10));

            Ecdp_Dynsql.AddSqlLine(body_lines,'  EcDp_month_lock.AddParameterToList(o_lock_columns'||
                                                     ','''||UPPER(ClassesAttr_lock.attribute_name)||''''||
                                                     ','''||UPPER(ClassesAttr_lock.db_sql_syntax)||''''||
                                                     ','''||UPPER(ClassesAttr_lock.data_type)||''''||
                                                     ','''||Nvl(ClassesAttr_lock.is_key,'N')||''''||
                                                     ',EcDp_month_lock.isUpdating(UPDATING('''||UPPER(ClassesAttr_lock.attribute_name)||''')),'||
                                                     ecdp_dynsql.Anydata_to_String(ClassesAttr_lock.data_type,':OLD.'||ClassesAttr_lock.attribute_name)||');'||CHR(10));

            IF UPPER(ClassesAttr_lock.attribute_name) = 'OBJECT_ID' AND lv2_owner_class IS NOT NULL THEN

              Ecdp_Dynsql.AddSqlLine(body_lines,'  EcDp_month_lock.AddParameterToList(n_lock_columns'||
                                                       ',''OBJECT_CODE'''||
                                                       ',''OBJECT_CODE'''||
                                                       ',''VARCHAR2'''||
                                                       ',''Y'''||
                                                       ',EcDp_month_lock.isUpdating(UPDATING('''||UPPER(ClassesAttr_lock.attribute_name)||''')),'||
                                                       ecdp_dynsql.Anydata_to_String('VARCHAR2','n_object_code')||');'||CHR(10));

              Ecdp_Dynsql.AddSqlLine(body_lines,'  EcDp_month_lock.AddParameterToList(o_lock_columns'||
                                                       ',''OBJECT_CODE'''||
                                                       ',''OBJECT_CODE'''||
                                                       ',''VARCHAR2'''||
                                                       ',''Y'''||
                                                       ',EcDp_month_lock.isUpdating(UPDATING('''||UPPER(ClassesAttr_lock.attribute_name)||''')),'||
                                                       ecdp_dynsql.Anydata_to_String('VARCHAR2',':OLD.OBJECT_CODE')||');'||CHR(10));


            END IF; -- 'OBJECT_ID'




       END IF; -- ClassesAttr3.db_mapping_type = 'COLUMN'

     END LOOP;  -- ClassesAttr


    FOR ClassesRel_lock IN EcDp_ClassMeta.c_classes_rel(p_class_name) LOOP

        IF ClassesRel_lock.db_mapping_type = 'COLUMN' THEN


        Ecdp_Dynsql.AddSqlLine(body_lines,'  EcDp_month_lock.AddParameterToList(n_lock_columns'||
                                                 ','''||UPPER(ClassesRel_lock.role_name)||'_ID'''||
                                                 ','''||UPPER(ClassesRel_lock.db_sql_syntax)||''''||
                                                 ',''VARCHAR2'''||
                                                 ','''||Nvl(ClassesRel_lock.is_key,'N')||''''||
                                                 ',EcDp_month_lock.isUpdating(UPDATING('''||UPPER(ClassesRel_lock.role_name)||'_ID'')),'||
                                                 ecdp_dynsql.Anydata_to_String('VARCHAR2','n_'||UPPER(ClassesRel_lock.role_name)||'_ID')||');'||CHR(10));

        Ecdp_Dynsql.AddSqlLine(body_lines,'  EcDp_month_lock.AddParameterToList(n_lock_columns'||
                                                 ','''||UPPER(ClassesRel_lock.role_name)||'_CODE'''||
                                                 ','''||UPPER(ClassesRel_lock.db_sql_syntax)||''''||
                                                 ',''VARCHAR2'''||
                                                 ','''||Nvl(ClassesRel_lock.is_key,'N')||''''||
                                                 ',EcDp_month_lock.isUpdating(UPDATING('''||UPPER(ClassesRel_lock.role_name)||'_CODE'')),'||
                                                 ecdp_dynsql.Anydata_to_String('VARCHAR2','n_'||UPPER(ClassesRel_lock.role_name)||'_CO')||');'||CHR(10));

        Ecdp_Dynsql.AddSqlLine(body_lines,'  EcDp_month_lock.AddParameterToList(o_lock_columns'||
                                                 ','''||UPPER(ClassesRel_lock.role_name)||'_ID'''||
                                                 ','''||UPPER(ClassesRel_lock.db_sql_syntax)||''''||
                                                 ',''VARCHAR2'''||
                                                 ','''||Nvl(ClassesRel_lock.is_key,'N')||''''||
                                                 ',EcDp_month_lock.isUpdating(UPDATING('''||UPPER(ClassesRel_lock.role_name)||'_ID'')),'||
                                                 ecdp_dynsql.Anydata_to_String('VARCHAR2',':old.'||UPPER(ClassesRel_lock.role_name)||'_ID')||');'||CHR(10));

        Ecdp_Dynsql.AddSqlLine(body_lines,'  EcDp_month_lock.AddParameterToList(o_lock_columns'||
                                                 ','''||UPPER(ClassesRel_lock.role_name)||'_CODE'''||
                                                 ','''||UPPER(ClassesRel_lock.db_sql_syntax)||''''||
                                                 ',''VARCHAR2'''||
                                                 ','''||Nvl(ClassesRel_lock.is_key,'N')||''''||
                                                 ',EcDp_month_lock.isUpdating(UPDATING('''||UPPER(ClassesRel_lock.role_name)||'_CODE'')),'||
                                                 ecdp_dynsql.Anydata_to_String('VARCHAR2',':old.'||UPPER(ClassesRel_lock.role_name)||'_CODE')||');'||CHR(10));


     END IF; -- ClassesRel_lock.db_mapping_type = 'COLUMN'

    END LOOP;  -- ClassesRel



     Ecdp_Dynsql.AddSqlLine(body_lines,CHR(10)||CHR(10));


     Ecdp_Dynsql.AddSqlLine(body_lines,'  IF INSERTING THEN ' ||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'    '||lv2_lock_rule||'(''INSERTING'',n_lock_columns,o_lock_columns);' ||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'  ELSIF UPDATING THEN ' ||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'    '||lv2_lock_rule||'(''UPDATING'',n_lock_columns,o_lock_columns);' ||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'  ELSIF DELETING THEN ' ||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'    '||lv2_lock_rule||'(''DELETING'',n_lock_columns,o_lock_columns);' ||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'  END IF;' ||CHR(10)||CHR(10));

   END IF; --    lb_use_locking

   IF lb_use_locking AND lv2_lock_rule IS NULL THEN

     Ecdp_Dynsql.AddSqlLine(body_lines,'   --------------------------------------------------------------------------------------------------------------'||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'   -- Lock checking: First check if we are moving object_start_date or object_end_date '||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'   IF n_object_start_date <> o_object_start_date  THEN'||CHR(10)||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'     EcDp_Month_Lock.validatePeriodForLockOverlap(''UPDATING'','||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'                                                Least(n_object_start_date,o_object_start_date),'||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'                                                Greatest(n_object_start_date,o_object_start_date),'||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'                                                ''CLASS: '||p_class_name||'; OBJECT_CODE:''||n_code, n_object_id);'||CHR(10)||CHR(10));


     Ecdp_Dynsql.AddSqlLine(body_lines,'   END IF; '||CHR(10)||CHR(10));

     Ecdp_Dynsql.AddSqlLine(body_lines,'   IF nvl(n_object_end_date,EcDp_System_Constants.future_date) '||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'   <> nvl(o_object_end_date,EcDp_System_Constants.future_date) THEN '||CHR(10)||CHR(10));

     Ecdp_Dynsql.AddSqlLine(body_lines,'     EcDp_Month_Lock.validatePeriodForLockOverlap(''UPDATING'','||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'                                              LEAST(Nvl(n_object_end_date, EcDp_System_Constants.future_date), '||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'                                                      Nvl(o_object_end_date,EcDp_System_Constants.future_date)), '||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'                                              GREATEST(Nvl(n_object_end_date,EcDp_System_Constants.future_date), '||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'                                                      Nvl(o_object_end_date,EcDp_System_Constants.future_date)), '||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'                                                ''CLASS: '||p_class_name||'; OBJECT_CODE:''||n_code, n_object_id);'||CHR(10)||CHR(10));

     Ecdp_Dynsql.AddSqlLine(body_lines,'   END IF; '||CHR(10)||CHR(10));


     Ecdp_Dynsql.AddSqlLine(body_lines,'   -- Check if we are updating any other main table attributes, Code or non-versioned relations '||CHR(10)||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'   IF lb_update_main_table THEN  '||CHR(10)||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'     EcDp_Month_Lock.validatePeriodForLockOverlap(''UPDATING'','||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'                                                o_object_start_date,o_object_end_date,  '||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'                                                ''CLASS: '||p_class_name||'; OBJECT_CODE:''||n_code, n_object_id);'||CHR(10)||CHR(10));

     Ecdp_Dynsql.AddSqlLine(body_lines,'   END IF;  '||CHR(10)||CHR(10));

     Ecdp_Dynsql.AddSqlLine(body_lines,'   -- OK, Main table locking checks handled.  '||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'   -- Change focus to the version table  '||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'   -- Check first if if we are creating a new version  '||CHR(10)||CHR(10));

     Ecdp_Dynsql.AddSqlLine(body_lines,'   IF UPDATING(''DAYTIME'') THEN'||CHR(10)||CHR(10));

     Ecdp_Dynsql.AddSqlLine(body_lines,'     OPEN  c_next_version(o_object_id,n_daytime);'||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'     FETCH c_next_version INTO ld_next_daytime;'||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'     CLOSE c_next_version;'||CHR(10)||CHR(10));

     Ecdp_Dynsql.AddSqlLine(body_lines,'     EcDp_Month_Lock.validatePeriodForLockOverlap(''UPDATING'','||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'                                                n_daytime,n_daytime,'||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'                                                ''CLASS: '||p_class_name||'; OBJECT_CODE:''||n_code, n_object_id);'||CHR(10)||CHR(10));


     Ecdp_Dynsql.AddSqlLine(body_lines,'   END IF;'||CHR(10)||CHR(10));


     Ecdp_Dynsql.AddSqlLine(body_lines,'   -- Last check for simple attribute changes'||CHR(10));

     Ecdp_Dynsql.AddSqlLine(body_lines,'   IF lb_update_version_not_dt THEN'||CHR(10));

     Ecdp_Dynsql.AddSqlLine(body_lines,'     EcDp_Month_Lock.validatePeriodForLockOverlap(''UPDATING'','||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'                                                n_daytime,vt(vt.LAST).end_date,'||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'                                                ''CLASS: '||p_class_name||'; OBJECT_CODE:''||n_code, n_object_id);'||CHR(10)||CHR(10));

     Ecdp_Dynsql.AddSqlLine(body_lines,'   END IF;'||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'   -- End lock check'||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'   -------------------------------------------------------------------'||CHR(10));

    END IF; -- lb_use_locking

    Ecdp_Dynsql.AddSqlLine(body_lines,'      IF UPDATING(''DAYTIME'') THEN'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         SELECT count(1) INTO ln_version_count'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'        FROM '||lv2_version_table||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'        WHERE object_id = o_object_id AND daytime = n_daytime;'||CHR(10)||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         IF ln_version_count > 0 THEN Raise_Application_Error(-20105,''There is already a version starting on the given daytime.''); END IF;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         IF n_daytime < n_object_start_date OR n_daytime >= nvl(n_object_end_date,n_daytime+1) THEN'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'            Raise_Application_Error(-20104,''Object is not valid for the date specified. Daytime for new version must be between object start date and object end date.'');'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         END IF;'||CHR(10)||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         lb_new_version := TRUE;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         IF n_rec_id = o_rec_id THEN'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'            n_rec_id := NULL;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         END IF;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         vt(vt.LAST).end_date := n_object_end_date;'||CHR(10)||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         -- Need check for previous and next versions to set end_date correct;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         FOR curVer IN c_old_version_row(n_object_id) LOOP'||CHR(10)||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'            IF curVer.daytime < n_daytime THEN ld_prev_daytime := curVer.daytime; END IF;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'            IF curVer.daytime > n_daytime THEN'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'               vt(vt.LAST).end_date := curVer.daytime;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'               EXIT; -- Only interessed in the next after the one we inserted'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'            END IF;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         END LOOP;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         lb_must_allert_children := TRUE;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      END IF;'||CHR(10)||CHR(10));

   -- Check whether we need to alert children
     Ecdp_Dynsql.AddSqlLine(body_lines,'      IF UPDATING(''CODE'') ');

    FOR curProcessAttr IN c_class_attr_process LOOP -- Determine whether some attributes are named 'CAN_PROC_<>

      Ecdp_Dynsql.AddSqlLine(body_lines,' OR UPDATING('''||curProcessAttr.attribute_name||''')');

    END LOOP;

   Ecdp_Dynsql.AddSqlLine(body_lines,' THEN'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'         lb_must_allert_children := TRUE;'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'      END IF;'||CHR(10)||CHR(10));

   Ecdp_Dynsql.AddSqlLine(body_lines,'      IF UPDATING(''CODE'') THEN'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'         lv2_code_changed := ''Y'';'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'      END IF;'||CHR(10)||CHR(10));

   Ecdp_Dynsql.AddSqlLine(body_lines,'      -- Start check for updating read only columns'||CHR(10));

   FOR curGroupRel IN c_group_ancestor_attribute LOOP -- Get all group relations columns that are on "grandfather and older level", not allowed to update these columns

     IF lv2_tmp_sql IS NULL THEN

       lv2_tmp_sql := 'NVL(:NEW.'||curGroupRel.role_name||'_ID,''$NULL$'') <> NVL(:OLD.'||curGroupRel.role_name||'_ID,''$NULL$'') ' ||
                      'OR NVL(:NEW.'||curGroupRel.role_name||'_CODE,''$NULL$'') <> NVL(:OLD.'||curGroupRel.role_name||'_CODE,''$NULL$'')';

     ELSE

       lv2_tmp_sql := lv2_tmp_sql ||' OR NVL(:NEW.'||curGroupRel.role_name||'_ID,''$NULL$'') <> NVL(:OLD.'||curGroupRel.role_name||'_ID,''$NULL$'') ' ||
                      'OR NVL(:NEW.'||curGroupRel.role_name||'_CODE,''$NULL$'') <> NVL(:OLD.'||curGroupRel.role_name||'_CODE,''$NULL$'')';

     END IF;

   END LOOP;

   IF lv2_tmp_sql IS NOT NULL THEN

      Ecdp_Dynsql.AddSqlLine(body_lines,'      IF '||lv2_tmp_sql||' THEN'||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'         Raise_Application_Error(-20101,''Can only update group relations on parent level!'');'||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'      END IF;'||CHR(10));

   END IF;

    Ecdp_Dynsql.AddSqlLine(body_lines,'      -- End check for updating read only columns'||CHR(10)||CHR(10));

    Ecdp_Dynsql.AddSqlLine(body_lines,'      IF lb_update_main_table AND lb_update_version_table THEN'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         EcDp_User_Session.SetUserSessionParameter(''JN_NOTES'',''COMMON'');'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      ELSE'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'        EcDp_User_Session.SetUserSessionParameter(''JN_NOTES'',''INDEPENDENT'');'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      END IF;'||CHR(10)||CHR(10));

---------------------------------------------------------
    Ecdp_Dynsql.AddSqlLine(body_lines,'      -- Start update relation block'||CHR(10));

    -- Handle first non group relations
  FOR curRel IN EcDp_ClassMeta.c_classes_rel(p_class_name) LOOP

    IF curRel.group_type IS NULL THEN -- Ordinary class relation

      -- versioned
      IF curRel.db_mapping_type = 'ATTRIBUTE' THEN

         Ecdp_Dynsql.AddSqlLine(body_lines,'      vt(vt.LAST).'||LOWER(curRel.db_sql_syntax)||' := EcDp_Objects.GetUpdatedRelationID(UPDATING('''||curRel.role_name||'_ID''),UPDATING('''||curRel.role_name||'_CODE''),'''||curRel.role_name||''','''||curRel.from_class_name||''',vt(vt.LAST).'||LOWER(curRel.db_sql_syntax)||',n_'||LOWER(curRel.role_name)||'_co,n_daytime);'||CHR(10));

      ELSIF curRel.db_mapping_type = 'COLUMN' THEN -- not versioned

         Ecdp_Dynsql.AddSqlLine(body_lines,'      n_'||LOWER(curRel.role_name)||'_id := EcDp_Objects.GetUpdatedRelationID(UPDATING('''||curRel.role_name||'_ID''),UPDATING('''||curRel.role_name||'_CODE''),'''||curRel.role_name||''','''||curRel.from_class_name||''',n_'||LOWER(curRel.role_name)||'_id,n_'||LOWER(curRel.role_name)||'_co,n_daytime);'||CHR(10));

      END IF;

    END IF;   -- curRel.group_type IS NULL

   END LOOP; -- curRel

   -- Group relations, first Loop the different group types this class is part of
   FOR curGroupType IN  c_class_group_types  LOOP

    FOR curRel2 IN  EcDp_ClassMeta.c_classes_rel(p_class_name) LOOP

          IF Nvl(curRel2.group_type,'NULL') =  curGroupType.group_type THEN

          Ecdp_Dynsql.AddSqlLine(body_lines,'      vt(vt.LAST).'||LOWER(curRel2.db_sql_syntax)||' := EcDp_Objects.GetUpdatedRelationID(UPDATING('''||curRel2.role_name||'_ID''),UPDATING('''||curRel2.role_name||'_CODE''),'''||curRel2.role_name||''','''||curRel2.from_class_name||''',vt(vt.LAST).'||LOWER(curRel2.db_sql_syntax)||',vt(vt.LAST).'||LOWER(REPLACE(curRel2.db_sql_syntax,'_ID','_CODE'))||',n_daytime);'||CHR(10));
          Ecdp_Dynsql.AddSqlLine(body_lines,'      vt(vt.LAST).'||LOWER(REPLACE(curRel2.db_sql_syntax,'_ID','_CODE'))||' := '||LOWER(EcDp_ClassMeta.GetEcPackage(curRel2.from_class_name))||'.object_code(vt(vt.LAST).'||LOWER(curRel2.db_sql_syntax)||'); -- Keep code and id in sync'||CHR(10));
          Ecdp_Dynsql.AddSqlLine(body_lines,'      IF UPDATING('''||curRel2.role_name||'_ID'') OR UPDATING('''||curRel2.role_name||'_CODE'') OR lb_new_version THEN'||CHR(10));
          Ecdp_Dynsql.AddSqlLine(body_lines,'         lb_must_allert_children := TRUE;'||CHR(10));
          Ecdp_Dynsql.AddSqlLine(body_lines,'      END IF;'||CHR(10)||CHR(10));
          END IF;

   END LOOP;

   Ecdp_Dynsql.AddSqlLine(body_lines,'       vt := EcTp_'||p_class_name||'.AlignParentVersions(vt,'''||curGroupType.group_type||''');'||CHR(10));

   END LOOP; -- curGroupType



    Ecdp_Dynsql.AddSqlLine(body_lines,'      -- End update relation block'||CHR(10)||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      n_created_by := Nvl(n_created_by,USER);'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      n_created_date := Nvl(n_created_date,EcDp_Date_time.getCurrentSysdate);'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      IF NOT UPDATING(''LAST_UPDATED_BY'') OR n_last_updated_by IS NULL THEN n_last_updated_by := Nvl(EcDp_Context.getAppUser,USER); END IF;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      IF NOT UPDATING(''LAST_UPDATED_DATE'') OR n_last_updated_date IS NULL THEN n_last_updated_date := EcDp_Date_time.getCurrentSysdate; END IF;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      vt(vt.LAST).created_by := n_created_by;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      vt(vt.LAST).created_date := n_created_date;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      vt(vt.LAST).last_updated_by := n_last_updated_by;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      vt(vt.LAST).last_updated_date := n_last_updated_date;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   END IF;'||CHR(10)||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   -- End Before Trigger action block -------------------------------------------------'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   ------------------------------------------------------------------------------------'||CHR(10));

   -- Trigger action block
    Ecdp_Dynsql.AddSqlLine(body_lines,'   --**********************************************************************************'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   -- Start Trigger Action block'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   -- Any code block defined as a BEFORE trigger-type in table CLASS_TRIGGER_ACTION will be put here'||CHR(10));

   FOR ClassBeforeAction IN EcDp_ClassMeta.c_class_trigger_action(p_class_name,'BEFORE') LOOP

      Ecdp_Dynsql.AddSqlLine(body_lines, ' IF ' || ClassBeforeAction.triggering_event || ' THEN ' || chr(10)|| chr(10));
        Ecdp_Dynsql.AddSqlLine(body_lines,  ClassBeforeAction.db_sql_syntax || CHR(10)|| chr(10));
       Ecdp_Dynsql.AddSqlLine(body_lines, ' END IF;' || chr(10)|| chr(10));

    END LOOP;

    Ecdp_Dynsql.AddSqlLine(body_lines,'   -- end Trigger Action block Class_trigger_actions before'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   --**********************************************************************************'||CHR(10)||CHR(10));

    Ecdp_Dynsql.AddSqlLine(body_lines,'   IF NOT DELETING THEN  -- check of mandatory columns and date logic'||CHR(10));

  lv2_tmp_sql := NULL;

   FOR curAttr IN EcDp_ClassMeta.c_classes_attr(p_class_name) LOOP

     IF curAttr.is_mandatory = 'Y' AND Nvl(curAttr.disabled_ind,'N') = 'N' AND Nvl(curAttr.report_only_ind,'N') = 'N' THEN

       IF curAttr.db_mapping_type = 'COLUMN' THEN       -- Check non versioned attributes

          Ecdp_Dynsql.AddSqlLine(body_lines,'      IF n_'||LOWER(curAttr.attribute_name)||' IS NULL THEN Raise_Application_Error(-20103,''Missing value for '||curAttr.attribute_name||'''); END IF;'||CHR(10));

       ELSIF curAttr.db_mapping_type = 'ATTRIBUTE' THEN  -- Check versioned attributes

        lv2_tmp_sql := lv2_tmp_sql||'         IF vt(ci).'||LOWER(curAttr.db_sql_syntax)||' IS NULL THEN Raise_Application_Error(-20103,''Missing value for '||curAttr.attribute_name||'''); END IF;'||CHR(10);

       END IF;

     END IF;

   END LOOP;

   FOR curRel IN EcDp_ClassMeta.c_classes_rel(p_class_name) LOOP

     IF curRel.is_mandatory = 'Y' AND Nvl(curRel.disabled_ind,'N') = 'N' AND Nvl(curRel.report_only_ind,'N') = 'N' THEN

       IF curRel.db_mapping_type = 'COLUMN' THEN      -- Check non versioned relations

          Ecdp_Dynsql.AddSqlLine(body_lines,'      IF n_'||LOWER(curRel.role_name)||'_id IS NULL THEN Raise_Application_Error(-20103,''Missing value for '||curRel.role_name||'''); END IF;'||CHR(10));

       ELSIF curRel.db_mapping_type = 'ATTRIBUTE' THEN    -- Check versioned relations/group relations

         lv2_tmp_sql := lv2_tmp_sql||'         IF vt(ci).'||LOWER(curRel.db_sql_syntax)||' IS NULL THEN Raise_Application_Error(-20103,''Missing value for '||curRel.role_name||'''); END IF;'||CHR(10);

       END IF;

     END IF;

   END LOOP;

   IF lv2_tmp_sql IS NOT NULL THEN

      Ecdp_Dynsql.AddSqlLine(body_lines,'      FOR ci IN 1..vt.COUNT LOOP'||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,lv2_tmp_sql);
      Ecdp_Dynsql.AddSqlLine(body_lines,'      END LOOP;'||CHR(10));

   END IF;


   Ecdp_Dynsql.AddSqlLine(body_lines,EcDp_ClassJournalHelper.makeObjectRevTextSection(p_class_name));
   Ecdp_Dynsql.AddSqlLine(body_lines,'   END IF;  -- End mandatory attribute check '||CHR(10)||CHR(10));

   Ecdp_Dynsql.AddSqlLine(body_lines,'   IF UPDATING THEN'||CHR(10)||CHR(10));

   Ecdp_Dynsql.AddSqlLine(body_lines,'      IF UPDATING(''OBJECT_START_DATE'') AND EcDp_Objects.IsValidObjStartDate(o_object_id, n_object_start_date) = ''Y'' THEN'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'         vt := EcTp_'||p_class_name||'.SetObjStartDate(vt, o_object_id, n_object_start_date, n_last_updated_by, n_last_updated_date);'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'         o_daytime := vt(1).daytime;'||CHR(10)||CHR(10));

   Ecdp_Dynsql.AddSqlLine(body_lines,'         IF n_object_start_date < o_object_start_date THEN -- Alert children since moving back in time'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'            lb_must_allert_children := TRUE;'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'            IF lb_update_version_table = FALSE AND vt.COUNT > 1 THEN'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'               lb_update_version_table := TRUE;'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'            END IF;'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'         END IF;'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'      END IF;'||CHR(10)||CHR(10));

   Ecdp_Dynsql.AddSqlLine(body_lines,'      IF UPDATING(''OBJECT_END_DATE'') THEN'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'         vt := EcTp_'||p_class_name||'.SetObjEndDate(vt, o_object_id, n_object_end_date, n_last_updated_by, n_last_updated_date,n_rev_text);'||CHR(10)||CHR(10));

   Ecdp_Dynsql.AddSqlLine(body_lines,'         IF nvl(n_object_end_date,o_object_end_date + 1) > o_object_end_date THEN -- Alert children since moving forth in time'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'            lb_must_allert_children := TRUE;'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'            IF lb_update_version_table = FALSE AND vt.COUNT > 1 THEN'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'               lb_update_version_table := TRUE;'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'            END IF;'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'         END IF;'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'      END IF;'||CHR(10)||CHR(10));

   Ecdp_Dynsql.AddSqlLine(body_lines,'   END IF;'||CHR(10)||CHR(10));

  -- Generate access control block
  FOR curRel IN c_acl_class_relations_lookup LOOP
     Ecdp_Dynsql.AddSqlLine(body_lines,'   -- Access check for '||curRel.role_name||'.'||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'   IF INSERTING OR UPDATING('''||curRel.Role_Name||'_ID'') OR UPDATING('''||curRel.Role_Name||'_CODE'') THEN'||CHR(10));
    IF curRel.db_mapping_type = 'COLUMN' THEN    -- Check non versioned relations
         Ecdp_Dynsql.AddSqlLine(body_lines,'      EcDp_ACL.AssertAccess(n_'||LOWER(curRel.role_name)||'_id, '''||curRel.rel_class_name||''');'||CHR(10));
     ELSIF curRel.db_mapping_type = 'ATTRIBUTE' THEN    -- Check versioned relations/group relations
         Ecdp_Dynsql.AddSqlLine(body_lines,'      EcDp_ACL.AssertAccess(vt(1).'||LOWER(curRel.db_sql_syntax)||', '''||curRel.rel_class_name||''');'||CHR(10));
     END IF;
    Ecdp_Dynsql.AddSqlLine(body_lines,'   END IF;'||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,CHR(10));
  END LOOP;

  IF lb_approval_enabled THEN
    Ecdp_Dynsql.AddSqlLines(body_lines, IUTrgApprovalStateHandling(p_class_name,'OBJECT'));
  END IF;

   Ecdp_Dynsql.AddSqlLine(body_lines,'   IF INSERTING THEN'||CHR(10)||CHR(10));

   -- Now build the column,value and update lists that will be used in the INSERT and UPDATE part.

   IF EcDp_ClassMeta.HasTableColumn(lv2_main_table,'CLASS_NAME') THEN

     lv2_main_column_list := 'CLASS_NAME,' ;
      lv2_main_value_list  := ''''||p_class_name||''',';

   END IF;

    FOR classAttr IN EcDp_ClassMeta.c_classes_attr(p_class_name) LOOP  -- Get Attributes

      IF Nvl(classAttr.report_only_ind,'N') = 'N' AND classAttr.attribute_name NOT IN ('OBJECT_ID','DAYTIME','END_DATE','CREATED_BY','CREATED_DATE','LAST_UPDATED_BY','LAST_UPDATED_DATE','REV_NO','REV_TEXT','RECORD_STATUS') THEN

        IF classAttr.db_mapping_type = 'COLUMN' THEN

            lv2_main_column_list := lv2_main_column_list || classAttr.db_sql_syntax ||',' ;
           lv2_main_value_list  := lv2_main_value_list || 'n_'||LOWER(classAttr.attribute_name)||',';

            IF classAttr.attribute_name NOT IN ('OBJECT_END_DATE','OBJECT_START_DATE') THEN

              lv2_main_update_list := lv2_main_update_list ||  classAttr.db_sql_syntax ||' = n_'||LOWER(classAttr.attribute_name)||',';

            END IF;

        ELSIF classAttr.db_mapping_type = 'ATTRIBUTE' THEN

          lv2_ver_column_list := lv2_ver_column_list || classAttr.db_sql_syntax ||',' ;
           lv2_ver_value_list  := lv2_ver_value_list || 'vt(ci).'||classAttr.db_sql_syntax||',';
            lv2_ver_update_list := lv2_ver_update_list ||  classAttr.db_sql_syntax ||' = vt(ci).'||LOWER(classAttr.db_sql_syntax)||',';

        END IF;

      END IF;

   END LOOP;

   FOR classRel IN EcDp_ClassMeta.c_classes_rel(p_class_name) LOOP -- Get relations on parent level

      IF Nvl(classRel.report_only_ind,'N') = 'N' THEN

        IF classRel.db_mapping_type = 'COLUMN' THEN

            lv2_main_column_list := lv2_main_column_list || classRel.db_sql_syntax ||',' ;
            lv2_main_value_list  := lv2_main_value_list || 'n_'||LOWER(classRel.role_name)||'_id,';
            lv2_main_update_list := lv2_main_update_list ||  classRel.db_sql_syntax ||'= n_'||LOWER(classRel.role_name)||'_id,';

        ELSIF classRel.db_mapping_type = 'ATTRIBUTE' THEN

          lv2_ver_column_list := lv2_ver_column_list || classRel.db_sql_syntax ||',' ;
            lv2_ver_value_list  := lv2_ver_value_list || 'vt(ci).'||LOWER(classRel.db_sql_syntax)||',';
            lv2_ver_update_list := lv2_ver_update_list || classRel.db_sql_syntax ||'= vt(ci).'||LOWER(classRel.db_sql_syntax)||',';

          IF classRel.group_type IS NOT NULL THEN -- need to store code as well if group relation

              lv2_ver_column_list := lv2_ver_column_list || REPLACE(classRel.db_sql_syntax,'_ID','_CODE') ||',' ;
              lv2_ver_value_list  := lv2_ver_value_list || 'vt(ci).'||LOWER(REPLACE(classRel.db_sql_syntax,'_ID','_CODE'))||',';
              lv2_ver_update_list := lv2_ver_update_list || REPLACE(classRel.db_sql_syntax,'_ID','_CODE') ||'= vt(ci).'||LOWER(REPLACE(classRel.db_sql_syntax,'_ID','_CODE'))||',';

          END IF;

        END IF;

      END IF;

   END LOOP;

   FOR curAncestorRel IN c_group_ancestor_attribute LOOP -- Get group relations on "granfather and older" level

     lv2_ver_column_list := lv2_ver_column_list || curAncestorRel.db_sql_syntax ||',' ;
      lv2_ver_value_list  := lv2_ver_value_list || 'vt(ci).'||LOWER(curAncestorRel.db_sql_syntax)||',';
      lv2_ver_update_list := lv2_ver_update_list || curAncestorRel.db_sql_syntax ||'= vt(ci).'||LOWER(curAncestorRel.db_sql_syntax)||',';

      -- need to store code as well
      lv2_ver_column_list := lv2_ver_column_list || REPLACE(curAncestorRel.db_sql_syntax,'_ID','_CODE') ||',' ;
      lv2_ver_value_list  := lv2_ver_value_list || 'vt(ci).'||LOWER(REPLACE(curAncestorRel.db_sql_syntax,'_ID','_CODE'))||',';
       lv2_ver_update_list := lv2_ver_update_list || REPLACE(curAncestorRel.db_sql_syntax,'_ID','_CODE') ||'= vt(ci).'||LOWER(REPLACE(curAncestorRel.db_sql_syntax,'_ID','_CODE'))||',';

   END LOOP;

   -- Special handling for WELL; Support PROC_NODE-columns
   IF p_class_name = 'WELL' THEN

     lv2_ver_column_list := lv2_ver_column_list || 'proc_node_oil_id,' ;
      lv2_ver_value_list  := lv2_ver_value_list  || 'vt(ci).proc_node_oil_id,';
      lv2_ver_update_list := lv2_ver_update_list || 'proc_node_oil_id = vt(ci).proc_node_oil_id,';

      lv2_ver_column_list := lv2_ver_column_list || 'proc_node_gas_id,' ;
      lv2_ver_value_list  := lv2_ver_value_list  || 'vt(ci).proc_node_gas_id,';
      lv2_ver_update_list := lv2_ver_update_list || 'proc_node_gas_id = vt(ci).proc_node_gas_id,';

      lv2_ver_column_list := lv2_ver_column_list || 'proc_node_cond_id,' ;
      lv2_ver_value_list  := lv2_ver_value_list  || 'vt(ci).proc_node_cond_id,';
      lv2_ver_update_list := lv2_ver_update_list || 'proc_node_cond_id = vt(ci).proc_node_cond_id,';

      lv2_ver_column_list := lv2_ver_column_list || 'proc_node_water_id,' ;
      lv2_ver_value_list  := lv2_ver_value_list  || 'vt(ci).proc_node_water_id,';
      lv2_ver_update_list := lv2_ver_update_list || 'proc_node_water_id = vt(ci).proc_node_water_id,';

      lv2_ver_column_list := lv2_ver_column_list || 'proc_node_water_inj_id,' ;
      lv2_ver_value_list  := lv2_ver_value_list  || 'vt(ci).proc_node_water_inj_id,';
      lv2_ver_update_list := lv2_ver_update_list || 'proc_node_water_inj_id = vt(ci).proc_node_water_inj_id,';

      lv2_ver_column_list := lv2_ver_column_list || 'proc_node_gas_inj_id,' ;
      lv2_ver_value_list  := lv2_ver_value_list  || 'vt(ci).proc_node_gas_inj_id,';
      lv2_ver_update_list := lv2_ver_update_list || 'proc_node_gas_inj_id = vt(ci).proc_node_gas_inj_id,';

      lv2_ver_column_list := lv2_ver_column_list || 'proc_node_diluent_id,' ;
      lv2_ver_value_list  := lv2_ver_value_list  || 'vt(ci).proc_node_diluent_id,';
      lv2_ver_update_list := lv2_ver_update_list || 'proc_node_diluent_id = vt(ci).proc_node_diluent_id,';

      lv2_ver_column_list := lv2_ver_column_list || 'proc_node_steam_inj_id,' ;
      lv2_ver_value_list  := lv2_ver_value_list  || 'vt(ci).proc_node_steam_inj_id,';
      lv2_ver_update_list := lv2_ver_update_list || 'proc_node_steam_inj_id = vt(ci).proc_node_steam_inj_id,';


      lv2_ver_column_list := lv2_ver_column_list || 'proc_node_gas_lift_id,' ;
      lv2_ver_value_list  := lv2_ver_value_list  || 'vt(ci).proc_node_gas_lift_id,';
      lv2_ver_update_list := lv2_ver_update_list || 'proc_node_gas_lift_id = vt(ci).proc_node_gas_lift_id,';

      lv2_ver_column_list := lv2_ver_column_list || 'proc_node_co2_id,' ;
      lv2_ver_value_list  := lv2_ver_value_list  || 'vt(ci).proc_node_co2_id,';
      lv2_ver_update_list := lv2_ver_update_list || 'proc_node_co2_id = vt(ci).proc_node_co2_id,';

      lv2_ver_column_list := lv2_ver_column_list || 'proc_node_co2_inj_id,' ;
      lv2_ver_value_list  := lv2_ver_value_list  || 'vt(ci).proc_node_co2_inj_id,';
      lv2_ver_update_list := lv2_ver_update_list || 'proc_node_co2_inj_id = vt(ci).proc_node_co2_inj_id,';




   END IF;

   Ecdp_Dynsql.AddSqlLine(body_lines,'      INSERT INTO '||lv2_main_table||'(object_id,'||lv2_main_column_list||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'                  '||lv2_std_main_insert_cols||')'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'      VALUES(n_object_id,'||lv2_main_value_list||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'             '||lv2_std_main_insert_vals||');'||CHR(10)||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'   ELSIF UPDATING AND lb_update_main_table THEN'||CHR(10)||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'      UPDATE '||lv2_main_table||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'      SET '||lv2_main_update_list||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'          '||lv2_std_main_update_list||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'     WHERE object_id = o_object_id;'||CHR(10)||CHR(10));

   Ecdp_Dynsql.AddSqlLine(body_lines,'   END IF; --Inserting'||CHR(10)||CHR(10));

   Ecdp_Dynsql.AddSqlLine(body_lines,'   IF INSERTING OR lb_new_version THEN'||CHR(10)||CHR(10));

  Ecdp_Dynsql.AddSqlLine(body_lines,'      FOR ci IN 1..vt.COUNT LOOP'||CHR(10));
  IF lb_approval_enabled THEN
     Ecdp_Dynsql.AddSqlLine(body_lines,'         -- Don''t register task detail if inserting as Official.'||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'         IF n_approval_state!=''O'' THEN EcDp_Approval.registerTaskDetail(n_rec_id,'''||p_class_name||''', Nvl(n_last_updated_by, n_created_by)); END IF;'||CHR(10));
  END IF;
   Ecdp_Dynsql.AddSqlLine(body_lines,'         INSERT INTO '||lv2_version_table||'(object_id,daytime,end_date,'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'             '||lv2_ver_column_list||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'             '||lv2_std_ver_insert_cols||')'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'         VALUES(n_object_id,vt(ci).daytime,vt(ci).end_date,'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'               '||lv2_ver_value_list||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'                '||lv2_std_ver_insert_vals||');'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'      END LOOP;'||CHR(10)||CHR(10));

   Ecdp_Dynsql.AddSqlLine(body_lines,'      IF UPDATING AND ld_prev_daytime IS NOT NULL THEN -- Need to set end_date on previous version'||CHR(10)||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'         UPDATE '||lv2_version_table||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'         SET end_date = vt(1).daytime,'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'             last_updated_by = n_last_updated_by,'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'             last_updated_date = n_last_updated_date'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'         WHERE object_id = o_object_id and daytime = ld_prev_daytime;'||CHR(10)||CHR(10));

   Ecdp_Dynsql.AddSqlLine(body_lines,'      END IF;'||CHR(10)||CHR(10));

   Ecdp_Dynsql.AddSqlLine(body_lines,'   ELSIF UPDATING AND lb_update_version_table THEN -- Update current version'||CHR(10)||CHR(10));

   IF lb_approval_enabled THEN
     Ecdp_Dynsql.AddSqlLine(body_lines,'      EcDp_Approval.registerTaskDetail(n_rec_id,'''||p_class_name||''', Nvl(n_last_updated_by, n_created_by));'||CHR(10));
  END IF;


   Ecdp_Dynsql.AddSqlLine(body_lines,'      UPDATE '||lv2_version_table||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'      SET daytime = vt(1).daytime, end_date = vt(1).end_date,'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'          '||REPLACE(lv2_ver_update_list,'vt(ci).','vt(1).')||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'          '||lv2_std_ver_update_list||CHR(10));

   Ecdp_Dynsql.AddSqlLine(body_lines,'      WHERE object_id = o_object_id AND daytime = o_daytime;'||CHR(10)||CHR(10));

   Ecdp_Dynsql.AddSqlLine(body_lines,'      FOR ci IN 2..vt.COUNT LOOP'||CHR(10));

  IF lb_approval_enabled THEN
     Ecdp_Dynsql.AddSqlLine(body_lines,'         n_approval_state := ''N'';'||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'         n_approval_by := null;'||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'         n_approval_date := null;'||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'         n_rec_id := SYS_GUID();'||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'         EcDp_Approval.registerTaskDetail(n_rec_id,'''||p_class_name||''', Nvl(n_last_updated_by, n_created_by));'||CHR(10));
  END IF;

   Ecdp_Dynsql.AddSqlLine(body_lines,'         INSERT INTO '||lv2_version_table||'(object_id,daytime,end_date,'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'             '||lv2_ver_column_list||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'             '||lv2_std_ver_insert_cols||')'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'         VALUES(n_object_id,vt(ci).daytime,vt(ci).end_date,'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'               '||lv2_ver_value_list||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'                '||lv2_std_ver_insert_vals||');'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'      END LOOP;'||CHR(10)||CHR(10));

   Ecdp_Dynsql.AddSqlLine(body_lines,'   END IF; -- INSERTING OR lb_new_version'||CHR(10)||CHR(10));

  IF lb_approval_enabled THEN
     Ecdp_Dynsql.AddSqlLine(body_lines,'   IF (lb_datechange or lb_update_main_table) and not lb_update_version_table and n_object_start_date <> n_object_end_date THEN'||CHR(10)||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'     EcDp_Approval.registerTaskDetail(n_rec_id,'''||p_class_name||''', Nvl(n_last_updated_by, n_created_by));'||CHR(10)||CHR(10));

     Ecdp_Dynsql.AddSqlLine(body_lines,'       UPDATE '||lv2_version_table||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'       SET approval_state=''U'',approval_by=Null,approval_date=null, '||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'             last_updated_by = Nvl(n_last_updated_by, User),'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'             last_updated_date = n_last_updated_date'||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'       WHERE object_id = o_object_id'||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'       and   daytime = n_daytime;'||CHR(10)||CHR(10));



     Ecdp_Dynsql.AddSqlLine(body_lines,'   END IF; '||CHR(10)||CHR(10));
  END IF;


  Ecdp_Dynsql.AddSqlLine(body_lines,'   -- nav model syncronisation'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'   IF inserting OR Updating THEN'||CHR(10)||CHR(10));

  Ecdp_Dynsql.AddSqlLine(body_lines,'     IF inserting THEN'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'       lv2_operation := ''INSERTING'';'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'     ELSE'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'       IF n_object_end_date = n_object_start_date THEN'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'           lv2_operation := ''DELETING'';'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'       ELSE'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'          lv2_operation := ''UPDATING'';'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'       END IF;'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'     END IF;'||CHR(10)||CHR(10));

  FOR curNav IN c_nav_model LOOP

    -- Cases to cover (assuming that object_id dont change and that delete is a update with date change.)
    -- 1. Insert where Ref id is not null
    -- 2. Update where ref_id has changed
    -- 3. Changes in dates on object or version
    -- 4. Version splitting from parent should not be a problem since the overall date and reference does not change.

     Ecdp_Dynsql.AddSqlLine(body_lines,'   FOR ci IN 1..vt.COUNT LOOP'||CHR(10)||CHR(10));

    IF curNav.db_mapping_type = 'ATTRIBUTE' THEN
      Ecdp_Dynsql.AddSqlLine(body_lines,'     IF (inserting AND vt(ci).'||curnav.db_sql_syntax||' IS NOT NULL )'||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'     OR (updating  AND Nvl(vt(ci).'||curnav.db_sql_syntax||',''NULL'') <> Nvl(:OLD.'||curnav.role_name||'_ID,''NULL''))'||CHR(10));
    ELSE
      Ecdp_Dynsql.AddSqlLine(body_lines,'     IF (inserting AND n_'||curnav.db_sql_syntax||' IS NOT NULL )'||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'     OR (updating  AND Nvl(n_'||curnav.db_sql_syntax||',''NULL'') <> Nvl(:OLD.'||curnav.role_name||'_ID,''NULL''))'||CHR(10));
    END IF;
    Ecdp_Dynsql.AddSqlLine(body_lines,'     OR (updating AND  lb_datechange) THEN'||CHR(10)||CHR(10));

    Ecdp_Dynsql.AddSqlLine(body_lines,'       EcDp_nav_model_obj_relation.Syncronize('||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         lv2_operation,'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         '''||curnav.from_class_name||''','||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         '''||curnav.to_class_name||''','||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         '''||curnav.role_name||''','||CHR(10));

    IF curnav.multiplicity IN ('1:N','1:1') THEN
      IF curNav.db_mapping_type = 'ATTRIBUTE' THEN
         Ecdp_Dynsql.AddSqlLine(body_lines,'         vt(ci).'||curnav.db_sql_syntax||','||CHR(10));
       ELSE
         Ecdp_Dynsql.AddSqlLine(body_lines,'         n_'||curnav.db_sql_syntax||','||CHR(10));
       END IF;

      Ecdp_Dynsql.AddSqlLine(body_lines,'         :OLD.'||curnav.role_name||'_ID,'||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'         n_object_id,'||CHR(10));
    ELSE
      IF curNav.db_mapping_type = 'ATTRIBUTE' THEN
         Ecdp_Dynsql.AddSqlLine(body_lines,'         vt(ci).'||curnav.db_sql_syntax||','||CHR(10));
       ELSE
         Ecdp_Dynsql.AddSqlLine(body_lines,'         n_'||curnav.db_sql_syntax||','||CHR(10));
       END IF;

      Ecdp_Dynsql.AddSqlLine(body_lines,'         :OLD.'||curnav.db_sql_syntax||','||CHR(10));

      Ecdp_Dynsql.AddSqlLine(body_lines,'         n_object_id,'||CHR(10));

    END IF;
    Ecdp_Dynsql.AddSqlLine(body_lines,'         n_object_start_date,'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         n_object_end_date,'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         vt(ci).daytime,'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         vt(ci).end_date);'||CHR(10)||CHR(10));

     Ecdp_Dynsql.AddSqlLine(body_lines,'    END IF;'||CHR(10)||CHR(10));

     Ecdp_Dynsql.AddSqlLine(body_lines,'   END LOOP;'||CHR(10)||CHR(10));

  END LOOP;

  Ecdp_Dynsql.AddSqlLine(body_lines,'   END IF; -- nav model syncronisation '||CHR(10)||CHR(10));

   Ecdp_Dynsql.AddSqlLine(body_lines,'   IF lb_must_allert_children THEN'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'      EcTp_'||p_class_name||'.SyncronizeChildren(vt,lv2_code_changed);'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'   END IF;'||CHR(10)||CHR(10));

   Ecdp_Dynsql.AddSqlLine(body_lines,'   IF DELETING THEN'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'      Raise_Application_Error(-20102,''Object delete is not allowed, set object end date. '');'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'   END IF;'||CHR(10)||CHR(10));

  IF lb_class_access_control THEN
    Ecdp_Dynsql.AddSqlLine(body_lines,'   IF INSERTING THEN'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      EcDp_ACL.RefreshObject(n_object_id, '''||p_class_name||''', ''INSERTING'');'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   END IF;'||CHR(10)||CHR(10));

    FOR curRel IN c_acl_class_relations_refresh LOOP
      IF lb_rel_access_control=FALSE THEN
        Ecdp_Dynsql.AddSqlLine(body_lines,'   IF');
      ELSE
        Ecdp_Dynsql.AddSqlLine(body_lines,'OR');
      END IF;
      Ecdp_Dynsql.AddSqlLine(body_lines,' UPDATING('''||curRel.Role_Name||'_ID'') OR UPDATING('''||curRel.Role_Name||'_CODE'') ');
      lb_rel_access_control := TRUE;
    END LOOP;

    IF lb_rel_access_control=TRUE THEN
      -- Generate the access control code block
      Ecdp_Dynsql.AddSqlLine(body_lines,'THEN'||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'      EcDp_ACL.RefreshObject(n_object_id, '''||p_class_name||''', ''UPDATING'');'||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'   END IF;'||CHR(10));
    END IF;
  END IF;

   Ecdp_Dynsql.AddSqlLine(body_lines,' --**********************************************************************************'|| chr(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,' -- Start Trigger Action block'|| chr(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,' -- Any code block defined as a AFTER trigger-type in table CLASS_TRIGGER_ACTION will be put here'|| chr(10)|| chr(10));

   FOR ClassAfterAction IN EcDp_ClassMeta.c_class_trigger_action(p_class_name,'AFTER') LOOP

      Ecdp_Dynsql.AddSqlLine(body_lines,' IF ' || ClassAfterAction.triggering_event || ' THEN ' || chr(10)|| chr(10));
        Ecdp_Dynsql.AddSqlLine(body_lines, ClassAfterAction.db_sql_syntax || CHR(10)|| chr(10));
        Ecdp_Dynsql.AddSqlLine(body_lines,' END IF;' || chr(10)|| chr(10));

   END LOOP;

   Ecdp_Dynsql.AddSqlLine(body_lines,' --'|| chr(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,' -- end Trigger Action block Class_trigger_actions after'|| chr(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,' --**********************************************************************************'|| chr(10) || chr(10));

   Ecdp_Dynsql.AddSqlLine(body_lines,'END;');

  Ecdp_Dynsql.SafeBuild('IUD_'||p_class_name,'TRIGGER',body_lines,p_target);

EXCEPTION

     WHEN OTHERS THEN
         EcDp_DynSql.WriteTempText('GENCODEERROR','Syntax error generating trigger for '||p_class_name||CHR(10)||SQLERRM||CHR(10));



END ObjectClassViewIUTrg;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : TableClassViewIUTrg
-- Description    : Generate InsteadOfTrigger for Table views, class definition of type TABLE
--
-- Preconditions  : p_class_name must refer to a class of type 'TABLE'.
--                  Class_attribute and class_attr_db_mapping must be configured for class.
--
--
--
-- Postcondition  : Trigger generated or error logged in t_temptext.
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
PROCEDURE TableClassViewIUTrg(
   p_class_name  VARCHAR2,
   p_daytime    DATE,
   p_target VARCHAR2 DEFAULT 'CREATE'
)
--</EC-DOC>

IS

  CURSOR c_class IS
     SELECT *
     FROM class
     WHERE class_name = p_class_name;


   body_lines                DBMS_SQL.varchar2a;
   lv2_main_tablename        VARCHAR2(100);
   lv2_tablename             VARCHAR2(100);
   lv2_db_owner              VARCHAR2(100);
   lv2_check_period_start    VARCHAR2(100);
   lv2_check_period_end      VARCHAR2(100);
   lv2_column_list           VARCHAR2(32000) := '';
   lv2_value_list            VARCHAR2(32000) := '';
   lv2_key_list              VARCHAR2(32000) := '';
   lv2_update_list           VARCHAR2(32000) := '';
   lv2_return_columns        VARCHAR2(32000) := '';
   lv2_return_values         VARCHAR2(32000) := '';
   lv2_journal_if            VARCHAR2(4000);
   lv2_lock_ind              VARCHAR2(1);
   lv2_lock_rule             VARCHAR2(200);
   lv2_owner_class           VARCHAR2(100) := EcDp_ClassMeta.OwnerClassName(p_class_name);
   lb_approval_enabled       BOOLEAN:=FALSE;
   lb_has_rec_id_column      BOOLEAN:=FALSE;
   lb_rec_id_in_class        BOOLEAN:=FALSE;


BEGIN

   -- No trigger will be generated for read only classes
   IF Ecdp_Classmeta.IsReadOnlyClass(p_class_name) = 'Y' THEN
      RETURN;
   END IF;

   FOR Classes IN EcDp_ClassMeta.c_classes(p_class_name) LOOP
      lv2_main_tablename := Classes.db_object_owner || '.' || Classes.db_object_name;
      lv2_tablename := UPPER(Classes.db_object_name);
      lv2_db_owner := Classes.db_object_owner;
   END LOOP;

   FOR curClass IN c_class LOOP
      lb_approval_enabled := Nvl(curClass.approval_ind,'N')='Y';
      lv2_lock_ind := Nvl(curClass.LOCK_ind,'N');
      lv2_lock_rule := curClass.lock_rule; -- 'EcDp_Month_lock.CheckDummyLock';
   END LOOP;

   -- Preparing the strings that will be the main part of the INSERT, UPDATE and DELETE statements
   -- Building a column, value, update and key lists.

   FOR ClassesAttr3 IN EcDp_ClassMeta.c_classes_attr(p_class_name, 'N') LOOP

      IF ClassesAttr3.db_mapping_type = 'COLUMN'
      AND NOT ClassesAttr3.attribute_name IN('CREATED_BY','CREATED_DATE','LAST_UPDATED_BY','LAST_UPDATED_DATE','REV_NO','REV_TEXT','RECORD_STATUS','APPROVAL_STATE','APPROVAL_BY','APPROVAL_DATE')
      AND ClassesAttr3.report_only_ind = 'N' THEN

         lv2_column_list := lv2_column_list ||ClassesAttr3.db_sql_syntax||',';
         lv2_value_list := lv2_value_list ||'n_'||ClassesAttr3.attribute_name ||',';
         lv2_update_list := lv2_update_list ||ClassesAttr3.db_sql_syntax||' = n_'||ClassesAttr3.attribute_name ||',';

         IF ClassesAttr3.is_key = 'Y' THEN
           lv2_key_list := lv2_key_list ||ClassesAttr3.db_sql_syntax||'= o_'||ClassesAttr3.attribute_name ||' AND ';

           -- Build a return clause for the INSERT statement to pick up any changes in key from TABLE Triggers
           lv2_return_columns := lv2_return_columns || ClassesAttr3.db_sql_syntax ||',';
           lv2_return_values := lv2_return_values || 'n_'||ClassesAttr3.attribute_name ||',';

         END IF; -- is_key
     END IF; -- ClassesAttr3.db_mapping_type = 'COLUMN'

   END LOOP;  -- ClassesAttr

   lv2_column_list := lv2_column_list||'CREATED_BY,CREATED_DATE,LAST_UPDATED_BY,LAST_UPDATED_DATE,REV_NO,REV_TEXT,RECORD_STATUS';
   lv2_value_list := lv2_value_list  ||'n_CREATED_BY,n_CREATED_DATE,n_LAST_UPDATED_BY,n_LAST_UPDATED_DATE,n_REV_NO,n_REV_TEXT,n_RECORD_STATUS';
   IF EcDp_ClassMeta.IsUsingUserFunction() = 'N' THEN
   lv2_update_list := lv2_update_list||'CREATED_BY = n_CREATED_BY, CREATED_DATE = n_CREATED_DATE , LAST_UPDATED_BY = n_LAST_UPDATED_BY,'||
                                        'LAST_UPDATED_DATE = n_LAST_UPDATED_DATE ,REV_NO = n_rev_no, REV_TEXT = n_REV_TEXT,'||
                                        'RECORD_STATUS = n_RECORD_STATUS';
   ELSE
     lv2_update_list := lv2_update_list||'LAST_UPDATED_BY = n_LAST_UPDATED_BY,'||
                                        'LAST_UPDATED_DATE = n_LAST_UPDATED_DATE ,REV_NO = n_rev_no, REV_TEXT = n_REV_TEXT,'||
                                        'RECORD_STATUS = n_RECORD_STATUS';
   END IF;


  lb_rec_id_in_class := ( ecdp_classmeta.getClassAttrDbSqlSyntax(p_class_name,'REC_ID') is not NULL);

   if not lb_rec_id_in_class THEN

     lb_has_rec_id_column := ColumnExists(lv2_main_tablename,'REC_ID',lv2_db_owner);
     IF lb_approval_enabled THEN
        lv2_column_list := lv2_column_list||',APPROVAL_STATE,APPROVAL_BY,APPROVAL_DATE,REC_ID';
        lv2_value_list := lv2_value_list  ||',n_approval_state,n_approval_by,n_approval_date,n_rec_id';
        lv2_update_list := lv2_update_list||',APPROVAL_STATE = n_approval_state,APPROVAL_BY = n_approval_by,APPROVAL_DATE = n_approval_date,REC_ID = n_rec_id';
     ELSIF lb_has_rec_id_column THEN
        lv2_column_list := lv2_column_list||',REC_ID';
        lv2_value_list := lv2_value_list  ||',n_rec_id';
        lv2_update_list := lv2_update_list||',REC_ID = n_rec_id';
     END IF;

    else

     IF lb_approval_enabled THEN
        lv2_column_list := lv2_column_list||',APPROVAL_STATE,APPROVAL_BY,APPROVAL_DATE';
        lv2_value_list := lv2_value_list  ||',n_approval_state,n_approval_by,n_approval_date';
        lv2_update_list := lv2_update_list||',APPROVAL_STATE = n_approval_state,APPROVAL_BY = n_approval_by,APPROVAL_DATE = n_approval_date';
     END IF;


    end if;

   lv2_key_list := SUBSTR(lv2_key_list,1,LENGTH(lv2_key_list)-5);
   lv2_return_columns := SUBSTR(lv2_return_columns,1,LENGTH(lv2_return_columns)-1);
   lv2_return_values := SUBSTR(lv2_return_values,1,LENGTH(lv2_return_values)-1);

   --------------------------------------------------------------------
   -- Start building the trigger.
   --------------------------------------------------------------------

   Ecdp_Dynsql.AddSqlLine(body_lines,'CREATE OR REPLACE TRIGGER IUV_'||p_class_name||CHR(10)||' INSTEAD OF INSERT OR UPDATE OR DELETE ON TV_'|| p_class_name||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'FOR EACH ROW' || chr(10) || GeneratedCodeMsg || 'DECLARE' ||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'  n_record_status      VARCHAR2(1) := EcDB_Utils.ConditionNVL(NOT Updating(''RECORD_STATUS''),:NEW.record_status,:OLD.record_status);'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'  n_rev_no             NUMBER := NVL(:OLD.rev_no,0);'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'  n_rev_text           VARCHAR2(4000):= EcDB_Utils.ConditionNVL(NOT Updating(''REV_TEXT''),:NEW.rev_text,:OLD.rev_text);'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'  n_created_by         VARCHAR2(30):= EcDB_Utils.ConditionNVL(NOT Updating(''CREATED_BY''),to_char(:NEW.created_by),to_char(:OLD.created_by));'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'  n_created_date       DATE := EcDB_Utils.ConditionNVL(NOT Updating(''CREATED_DATE''),:NEW.created_date,:OLD.created_date);'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'  n_last_updated_by    VARCHAR2(30):= EcDB_Utils.ConditionNVL(NOT Updating(''LAST_UPDATED_BY''),to_char(:NEW.last_updated_by),to_char(:OLD.last_updated_by));'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'  n_last_updated_date  DATE := EcDB_Utils.ConditionNVL(NOT Updating(''LAST_UPDATED_DATE''),:NEW.last_updated_date,:OLD.last_updated_date);'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'  o_created_by         VARCHAR2(30):= :OLD.created_by;'||  chr(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'  o_last_updated_by    VARCHAR2(30):= :OLD.last_updated_by;'|| CHR(10));

   Ecdp_Dynsql.AddSqlLine(body_lines,'  n_lock_columns       EcDp_Month_lock.column_list;'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'  o_lock_columns       EcDp_Month_lock.column_list;'||CHR(10));


   -- Need variables for all class attributes, because of use in possible class_trigger_actions
   FOR ClassesAttr IN EcDp_ClassMeta.c_classes_attr(p_class_name, 'N') LOOP

      IF ClassesAttr.db_mapping_type = 'COLUMN'
      AND ClassesAttr.attribute_name NOT IN('CREATED_BY','CREATED_DATE','LAST_UPDATED_BY','LAST_UPDATED_DATE','REV_NO','REV_TEXT','RECORD_STATUS')
      AND ClassesAttr.report_only_ind = 'N' THEN

         IF ClassesAttr.data_type IN ('NUMBER','INTEGER') THEN

            Ecdp_Dynsql.AddSqlLine(body_lines,'  n_'||ClassesAttr.attribute_name ||' NUMBER  := EcDB_Utils.ConditionNVL(NOT Updating('''||ClassesAttr.attribute_name||'''),:NEW.'||ClassesAttr.attribute_name||',:OLD.'||ClassesAttr.attribute_name||');'||CHR(10));

         ELSIF ClassesAttr.data_type = 'DATE' THEN

            Ecdp_Dynsql.AddSqlLine(body_lines,'  n_'||ClassesAttr.attribute_name||' DATE := EcDB_Utils.ConditionNVL(NOT Updating('''||ClassesAttr.attribute_name||'''),:NEW.'||ClassesAttr.attribute_name||',:OLD.'||ClassesAttr.attribute_name||');'||CHR(10));

         ELSE -- STRING

            Ecdp_Dynsql.AddSqlLine(body_lines,'  n_'||ClassesAttr.attribute_name||' VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('''||ClassesAttr.attribute_name||'''),:NEW.'||ClassesAttr.attribute_name||',:OLD.'||ClassesAttr.attribute_name||');'||CHR(10));

         END IF;

         IF ClassesAttr.is_key = 'Y' THEN

            IF ClassesAttr.data_type IN ('NUMBER','INTEGER') THEN

               Ecdp_Dynsql.AddSqlLine(body_lines,'  o_'||ClassesAttr.attribute_name ||' NUMBER  := :OLD.'||ClassesAttr.attribute_name||';'||CHR(10));

            ELSIF ClassesAttr.data_type = 'DATE' THEN

               Ecdp_Dynsql.AddSqlLine(body_lines,'  o_'||ClassesAttr.attribute_name||' DATE := :OLD.'||ClassesAttr.attribute_name||';'||CHR(10));

            ELSE -- STRING

               Ecdp_Dynsql.AddSqlLine(body_lines,'  o_'||ClassesAttr.attribute_name||' VARCHAR2(4000) := :OLD.'||ClassesAttr.attribute_name||';'||CHR(10));

            END IF;

         END IF; -- is_key

       END IF; -- ClassesAttr.db_mapping_type = 'COLUMN'

   END LOOP;

   IF lb_approval_enabled THEN
     Ecdp_Dynsql.AddSqlLines(body_lines, IUTrgApprovalStateVariables(p_class_name));
   ELSIF lb_has_rec_id_column and not lb_rec_id_in_class THEN
     Ecdp_Dynsql.AddSqlLine(body_lines,'   o_rec_id          VARCHAR2(32) := :OLD.rec_id;'||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'   n_rec_id          VARCHAR2(32) := Nvl(:OLD.rec_id, SYS_GUID());'||CHR(10));
   END IF;

   Ecdp_Dynsql.AddSqlLine(body_lines,'BEGIN'||CHR(10)||CHR(10));



   Ecdp_Dynsql.AddSqlLine(body_lines,'   --*************************************************************************************'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'   -- Start Trigger Action block'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'   -- Any code block defined as a BEFORE trigger-type in table CLASS_TRIGGER_ACTION will be put here'||CHR(10));

   FOR ClassBeforeAction IN EcDp_ClassMeta.c_class_trigger_action(p_class_name,'BEFORE') LOOP
     Ecdp_Dynsql.AddSqlLine(body_lines,'  IF '||ClassbeforeAction.triggering_event||' THEN ' ||CHR(10)||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'    '||ClassbeforeAction.db_sql_syntax||CHR(10)||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'  END IF;'||CHR(10));
   END LOOP;

   Ecdp_Dynsql.AddSqlLine(body_lines,'   --'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'   -- end Trigger Action block Class_trigger_actions before'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'   --*************************************************************************************'||CHR(10)||CHR(10));

   -- Populate parameters for lock function
   IF   lv2_lock_ind = 'Y' THEN

     Ecdp_Dynsql.AddSqlLine(body_lines,'  EcDp_month_lock.AddParameterToList(n_lock_columns'||
                                                       ',''CLASS_NAME'''||
                                                       ','''||UPPER(p_class_name)||''''||
                                                       ',''STRING''' ||
                                                       ',NULL' ||
                                                       ',NULL' ||
                                                       ',NULL);'||CHR(10));

     Ecdp_Dynsql.AddSqlLine(body_lines,'  EcDp_month_lock.AddParameterToList(n_lock_columns'||
                                                       ',''TABLE_NAME'''||
                                                       ','''||UPPER(lv2_tablename)||''''||
                                                       ',''STRING''' ||
                                                       ',NULL' ||
                                                       ',NULL' ||
                                                       ',NULL);'||CHR(10));

     Ecdp_Dynsql.AddSqlLine(body_lines,'  EcDp_month_lock.AddParameterToList(o_lock_columns'||
                                                       ',''CLASS_NAME'''||
                                                       ','''||UPPER(p_class_name)||''''||
                                                       ',''STRING''' ||
                                                       ',NULL' ||
                                                       ',NULL' ||
                                                       ',NULL);'||CHR(10));

     Ecdp_Dynsql.AddSqlLine(body_lines,'  EcDp_month_lock.AddParameterToList(o_lock_columns'||
                                                       ',''TABLE_NAME'''||
                                                       ','''||UPPER(lv2_tablename)||''''||
                                                       ',''STRING''' ||
                                                       ',NULL' ||
                                                       ',NULL' ||
                                                       ',NULL);'||CHR(10));



     FOR ClassesAttr_lock IN EcDp_ClassMeta.c_classes_attr(p_class_name, 'N') LOOP

        IF ClassesAttr_lock.db_mapping_type = 'COLUMN'
        AND NOT ClassesAttr_lock.attribute_name IN('CREATED_BY','CREATED_DATE','LAST_UPDATED_BY','LAST_UPDATED_DATE','REV_NO','REV_TEXT','RECORD_STATUS')
        AND ClassesAttr_lock.report_only_ind = 'N'
        AND ClassesAttr_lock.data_type IN ('STRING','NUMBER','INTEGER','DATE','VARCHAR2')
        THEN


            Ecdp_Dynsql.AddSqlLine(body_lines,'  EcDp_month_lock.AddParameterToList(n_lock_columns'||
                                                     ','''||UPPER(ClassesAttr_lock.attribute_name)||''''||
                                                     ','''||UPPER(ClassesAttr_lock.db_sql_syntax)||''''||
                                                     ','''||UPPER(ClassesAttr_lock.data_type)||''''||
                                                     ','''||Nvl(ClassesAttr_lock.is_key,'N')||''''||
                                                     ',EcDp_month_lock.isUpdating(UPDATING('''||UPPER(ClassesAttr_lock.attribute_name)||''')),'||
                                                     ecdp_dynsql.Anydata_to_String(ClassesAttr_lock.data_type,'n_'||ClassesAttr_lock.attribute_name)||');'||CHR(10));

            Ecdp_Dynsql.AddSqlLine(body_lines,'  EcDp_month_lock.AddParameterToList(o_lock_columns'||
                                                     ','''||UPPER(ClassesAttr_lock.attribute_name)||''''||
                                                     ','''||UPPER(ClassesAttr_lock.db_sql_syntax)||''''||
                                                     ','''||UPPER(ClassesAttr_lock.data_type)||''''||
                                                     ','''||Nvl(ClassesAttr_lock.is_key,'N')||''''||
                                                     ',EcDp_month_lock.isUpdating(UPDATING('''||UPPER(ClassesAttr_lock.attribute_name)||''')),'||
                                                     ecdp_dynsql.Anydata_to_String(ClassesAttr_lock.data_type,':OLD.'||ClassesAttr_lock.attribute_name)||');'||CHR(10));

/* NOTYET support owner on table classes
            IF UPPER(ClassesAttr_lock.attribute_name) = 'OBJECT_ID' AND lv2_owner_class IS NOT NULL THEN

              Ecdp_Dynsql.AddSqlLine(body_lines,'  EcDp_month_lock.AddParameterToList(n_lock_columns'||
                                                       ',''OBJECT_CODE'''||
                                                       ',''OBJECT_CODE'''||
                                                       ',''VARCHAR2'''||
                                                       ',''Y'''||
                                                       ',EcDp_month_lock.isUpdating(UPDATING('''||UPPER(ClassesAttr_lock.attribute_name)||''')),'||
                                                       ecdp_dynsql.Anydata_to_String('VARCHAR2','n_object_code')||');'||CHR(10));

              Ecdp_Dynsql.AddSqlLine(body_lines,'  EcDp_month_lock.AddParameterToList(o_lock_columns'||
                                                       ',''OBJECT_CODE'''||
                                                       ',''OBJECT_CODE'''||
                                                       ',''VARCHAR2'''||
                                                       ',''Y'''||
                                                       ',EcDp_month_lock.isUpdating(UPDATING('''||UPPER(ClassesAttr_lock.attribute_name)||''')),'||
                                                       ecdp_dynsql.Anydata_to_String('VARCHAR2',':OLD.OBJECT_CODE')||');'||CHR(10));


            END IF; -- 'OBJECT_ID'
*/

       END IF; -- ClassesAttr3.db_mapping_type = 'COLUMN'

     END LOOP;  -- ClassesAttr

     Ecdp_Dynsql.AddSqlLine(body_lines,CHR(10)||CHR(10));

     Ecdp_Dynsql.AddSqlLine(body_lines,'  IF INSERTING THEN ' ||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'    '||lv2_lock_rule||'(''INSERTING'',n_lock_columns,o_lock_columns);' ||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'  ELSIF UPDATING THEN ' ||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'    '||lv2_lock_rule||'(''UPDATING'',n_lock_columns,o_lock_columns);' ||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'  ELSIF DELETING THEN ' ||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'    '||lv2_lock_rule||'(''DELETING'',n_lock_columns,o_lock_columns);' ||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'  END IF;' ||CHR(10)||CHR(10));

   END IF; -- lv2_lock_ind


   Ecdp_Dynsql.AddSqlLine(body_lines,'   -- Attributes check'||CHR(10));

   FOR ClassesAttr IN EcDp_ClassMeta.c_classes_attr(p_class_name) LOOP

      -- include check for each property defined as mandatory
      IF ClassesAttr.is_mandatory = 'Y' AND ClassesAttr.db_mapping_type = 'COLUMN' THEN
         Ecdp_Dynsql.AddSqlLine(body_lines,'  IF n_' || ClassesAttr.attribute_name || ' IS NULL THEN Raise_Application_Error(-20103,''Missing value for '|| ClassesAttr.attribute_name||'''); END IF;'||CHR(10));
      END IF;

      -- Date check
      IF ClassesAttr.attribute_name IN ('START_DATE', 'DAYTIME', 'FROM_DAYTIME','FROM_DATE','END_DATE','TO_DAYTIME','TO_DATE')
      AND ClassesAttr.db_mapping_type = 'COLUMN' THEN

          Ecdp_Dynsql.AddSqlLine(body_lines,'  IF n_'||ClassesAttr.attribute_name|| ' < EcDp_System_Constants.Earliest_date THEN ');
          Ecdp_Dynsql.AddSqlLine(body_lines,' Raise_Application_Error(-20104,''Cannot set '|| ClassesAttr.attribute_name || ' before system earliest date: '||TO_CHAR(EcDp_System_Constants.Earliest_date,'dd.mm.yyyy' )||'''); END IF;'||CHR(10));

          IF ClassesAttr.attribute_name IN ('START_DATE', 'DAYTIME', 'FROM_DAYTIME','FROM_DATE') THEN
            lv2_check_period_start := ClassesAttr.attribute_name;
          END IF;

          IF ClassesAttr.attribute_name IN ('END_DATE','TO_DAYTIME','TO_DATE') THEN
            lv2_check_period_end := ClassesAttr.attribute_name;
          END IF;

       END IF;

   END LOOP;

   -- Date period check
   IF lv2_check_period_start IS NOT NULL AND lv2_check_period_end IS NOT NULL THEN -- Add consistent period check
      Ecdp_Dynsql.AddSqlLine(body_lines,'  IF n_'||lv2_check_period_start|| ' > nvl(n_'||lv2_check_period_end||',n_'||lv2_check_period_start||') THEN '||
                                  ' Raise_Application_Error(-20104,'''|| lv2_check_period_end || ' cannot be before '||lv2_check_period_start||': ''||n_'||lv2_check_period_start||'); END IF; ' || CHR(10));
   END IF;

   IF lb_approval_enabled THEN
     Ecdp_Dynsql.AddSqlLines(body_lines, IUTrgApprovalStateHandling(p_class_name,'TABLE'));
   END IF;

   Ecdp_Dynsql.AddSqlLine(body_lines,CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'   IF INSERTING THEN'||CHR(10)||CHR(10));

   FOR ClassesAttrDef IN EcDp_ClassMeta.c_classes_attr(p_class_name) LOOP

      IF ClassesAttrDef.default_value IS NOT NULL AND ClassesAttrDef.report_only_ind = 'N' THEN
          Ecdp_Dynsql.AddSqlLine(body_lines,'      IF  n_' || ClassesAttrDef.attribute_name ||' IS NULL  THEN n_' || ClassesAttrDef.attribute_name || ' := ' ||ClassesAttrDef.default_value ||'; END IF;'||CHR(10)||CHR(10));
      END IF;

   END LOOP;

   IF lb_approval_enabled THEN
     Ecdp_Dynsql.AddSqlLine(body_lines,'    -- Don''t register task detail if inserting as official.'|| CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'    IF n_approval_state!=''O'' THEN EcDp_Approval.registerTaskDetail(n_rec_id, '''||p_class_name||''', n_created_by); END IF;'|| CHR(10));
   END IF;
   -- Insert statement
   Ecdp_Dynsql.AddSqlLine(body_lines,'      INSERT INTO '||lv2_main_tablename||'('||lv2_column_list||')'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'      VALUES('||lv2_value_list||')');

   IF viewExists(lv2_main_tablename, lv2_db_owner) THEN
      Ecdp_Dynsql.AddSqlLine(body_lines, ';' || CHR(10));
   ELSE
      Ecdp_Dynsql.AddSqlLine(body_lines, CHR(10) || '      RETURNING '||lv2_return_columns||' INTO '||lv2_return_values||';'||CHR(10)||CHR(10));
   END IF;

   Ecdp_Dynsql.AddSqlLine(body_lines,'   ELSIF UPDATING THEN'||CHR(10)||CHR(10));

   -- Rev_no handling
   lv2_journal_if := EcDp_ClassMeta.getClassJournalIfCondition(p_class_name);

   Ecdp_Dynsql.AddSqlLine(body_lines,EcDp_ClassJournalHelper.makeJournalRuleSection(p_class_name) ||chr(10));

   Ecdp_Dynsql.AddSqlLine(body_lines,'      IF  NOT UPDATING(''LAST_UPDATED_BY'') OR n_last_updated_by IS NULL THEN  n_last_updated_by := USER;  END IF;'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'      IF  NOT UPDATING(''LAST_UPDATED_DATE'') OR n_last_updated_date IS NULL THEN  n_last_updated_date := EcDp_Date_Time.getCurrentSysdate;  END IF;'||CHR(10)||CHR(10));

   IF lb_approval_enabled THEN
      Ecdp_Dynsql.AddSqlLine(body_lines,'      EcDp_Approval.registerTaskDetail(n_rec_id, '''||p_class_name||''', Nvl(n_last_updated_by, n_created_by));'|| CHR(10));
   END IF;

   -- Update statement
   Ecdp_Dynsql.AddSqlLine(body_lines,'      UPDATE '||lv2_main_tablename||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'      SET '||lv2_update_list||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'      WHERE '||lv2_key_list||';'||CHR(10)||CHR(10));

   Ecdp_Dynsql.AddSqlLine(body_lines,'   ELSE -- deleting'||CHR(10)||CHR(10));

   IF lb_approval_enabled = FALSE THEN
     Ecdp_Dynsql.AddSqlLine(body_lines,'     DELETE FROM '||lv2_main_tablename||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'     WHERE '||lv2_key_list||';'||CHR(10)||CHR(10));
   ELSE
     Ecdp_Dynsql.AddSqlLine(body_lines,'     IF EcDp_Approval.IsAccepting OR o_approval_state=''N'' THEN '||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'         -- We trust DELETEs triggered from EcDp_Approval.Accept, so not need to check source record approval_state.'||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'         -- DELETEs of record with approval_state=''N'' is allowed; the record has never been official.'||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'         IF EcDp_Approval.IsAccepting=FALSE THEN EcDp_Approval.deleteTaskDetail(n_rec_id); END IF;'|| CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'         DELETE FROM '||lv2_main_tablename||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'         WHERE '||lv2_key_list||';'||CHR(10)||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'     ELSE'||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'         -- Mark record for deletion.'||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'         EcDp_Approval.registerTaskDetail(n_rec_id, '''||p_class_name||''', Nvl(EcDp_Context.getAppUser,User));'|| CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'         UPDATE '||lv2_main_tablename||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'         SET    rec_id=n_rec_id'||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'         ,      approval_state=''D'''||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'         ,      approval_by=null'||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'         ,      approval_date=null'||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'         ,      rev_no=(rev_no+1)'||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'         ,      last_updated_by=Nvl(EcDp_Context.getAppUser,User)'||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'         WHERE '||lv2_key_list||';'||CHR(10)||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'     END IF;'||CHR(10));
   END IF;

   Ecdp_Dynsql.AddSqlLine(body_lines,'   END IF; -- Inserting'||CHR(10)||CHR(10));

   -- After trigger block
   Ecdp_Dynsql.AddSqlLine(body_lines,'--*************************************************************************************'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'-- Start Trigger Action block'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'-- Any code block defined as a AFTER trigger-type in table CLASS_TRIGGER_ACTION will be put here'||CHR(10));

   FOR ClassBeforeAction IN EcDp_ClassMeta.c_class_trigger_action(p_class_name,'AFTER') LOOP
     Ecdp_Dynsql.AddSqlLine(body_lines,'   IF '||ClassbeforeAction.triggering_event||' THEN ' ||CHR(10)||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'      '||ClassbeforeAction.db_sql_syntax||CHR(10)||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'   END IF;'||CHR(10));
   END LOOP;

   Ecdp_Dynsql.AddSqlLine(body_lines,'--'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'-- end Trigger Action block Class_trigger_actions after'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'--*************************************************************************************'||CHR(10)||CHR(10));

   Ecdp_Dynsql.AddSqlLine(body_lines,'END;'||CHR(10));

   Ecdp_Dynsql.SafeBuild('IUV_'||p_class_name,'TRIGGER',body_lines,p_target);

EXCEPTION

     WHEN OTHERS THEN
         EcDp_DynSql.WriteTempText('GENCODEERROR','Syntax error generating trigger for '||p_class_name||CHR(10)||SQLERRM||CHR(10));

END TableClassViewIUTrg;











--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : DataClassViewIUTrg
-- Description    : Generate InsteadOfTrigger for data views, class definition of type DATA
--
-- Preconditions  : p_class_name must refer to a class of type 'DATA'.
--                  Class_attribute and class_attr_db_mapping must be configured for class.
--
--
--
-- Postcondition  : Trigger generated or error logged in t_temptext.
--                  IF p_target = 'SCRIPT' code generated to t_temptext
-- Using Tables   : t_temptext
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior       : The validation on daytime against parent object start date will be done according to:
--              1. No object_id -> no parent -> no daytime validation against parent
--              2. No daytime or Time_scope_code = NONE -> No daytime validation against parent
--              3. Trunc parent object start date when time_scope_code = DAY,MONTH
---------------------------------------------------------------------------------------------------
PROCEDURE DataClassViewIUTrg(
   p_class_name  VARCHAR2,
   p_daytime    DATE,
   p_target VARCHAR2 DEFAULT 'CREATE'
)
--</EC-DOC>
IS

CURSOR c_class(cp_class_name VARCHAR2) IS
 SELECT c.owner_class_name,
       c.time_scope_code,
       cm.db_object_name,
       cm.db_object_owner,
       c.lock_ind,
       c.lock_rule,
      NVL(o.access_control_ind,'N') owner_access_control_ind,
      c.approval_ind,
      c.skip_trg_check_ind
 FROM class c, class_db_mapping cm, class o
 WHERE c.class_name = cm.class_name
 AND   c.owner_class_name=o.class_name (+)
 AND c.class_name = cp_class_name;

ln_cur                 NUMBER;
body_lines                DBMS_SQL.varchar2a;

lv2_column_list              VARCHAR2(32000) := '';
lv2_value_list               VARCHAR2(32000) := '';
lv2_key_list                 VARCHAR2(32000) := '';
lv2_update_list              VARCHAR2(32000) := '';
lv2_return_columns           VARCHAR2(32000) := '';
lv2_return_values            VARCHAR2(32000) := '';
lv2_main_tablename           VARCHAR2(100);
lv2_tablename                VARCHAR2(100);
lv2_db_owner                 VARCHAR2(100);
lv2_column_value             VARCHAR2(100);
lb_update_need_rev_text      BOOLEAN;
lv2_data_class_colum         VARCHAR2(32);
lv2_sequence_stmnt           VARCHAR2(4000);
lv2_sequence_attribute       class_attribute.attribute_name%TYPE;
lb_use_object_id             BOOLEAN;
lb_daytime_is_key            BOOLEAN;
lb_daytime_is_attribute      BOOLEAN := FALSE;
lb_daytime_is_private        BOOLEAN := FALSE;
lv2_time_scope_code           class.time_scope_code%TYPE;
lv2_owner_class               class.owner_class_name%TYPE;
lv2_lock_rule                VARCHAR2(200);
lv2_lock_ind                 VARCHAR2(1);
lv2_owner_access_control_ind VARCHAR2(1);
lv2_check_period_start       VARCHAR2(100);
lv2_check_period_end         VARCHAR2(100);
lb_approval_enabled          BOOLEAN:=FALSE;
lb_has_rec_id_column         BOOLEAN:=FALSE;
lb_skip_trg_check            BOOLEAN:=FALSE;


BEGIN

  -- No trigger will be generated for read only classes
    IF Ecdp_Classmeta.IsReadOnlyClass(p_class_name) = 'Y' THEN
       RETURN;
    END IF;

    lb_update_need_rev_text := FALSE;    -- May in future be controlled by some db settings.

    FOR curClass IN c_class(p_class_name) LOOP

      lv2_owner_class := curClass.owner_class_name;
      lv2_main_tablename := curClass.db_object_owner || '.' || curClass.db_object_name;
      lv2_tablename := curClass.db_object_name;
      lv2_db_owner := curClass.db_object_owner;
      lv2_time_scope_code := curClass.time_scope_code;
      lv2_lock_ind := Nvl(curClass.lock_ind,'N');
      lv2_lock_rule := curClass.lock_rule; -- 'EcDp_Month_lock.CheckDummyLock';
      lv2_owner_access_control_ind := curClass.owner_access_control_ind;
      lb_approval_enabled := Nvl(curClass.approval_ind,'N')='Y';
      lb_skip_trg_check := Nvl(curClass.skip_trg_check_ind,'N')='Y';

    END LOOP;


    -- The following section include checks to find what type of data class this is
    -- does it have object_id, daytime, class_name etc

    lb_use_object_id := ( lv2_owner_class IS NOT NULL );

    -- Need to find if we have a public daytime column and if it is key
    FOR curDatyimecheck IN EcDp_ClassMeta.c_classes_attr (p_class_name,'N', 'DAYTIME') LOOP

       lb_daytime_is_attribute := TRUE;
       lb_daytime_is_key := (curDatyimecheck.is_key = 'Y');

    END LOOP;

    IF  NOT lb_daytime_is_attribute THEN  -- Check if it is a private attribute

      lb_daytime_is_key := FALSE;  -- It has to be a public attribute to be key

      FOR curDatyimecheck IN EcDp_ClassMeta.c_classes_attr (p_class_name,'Y', 'DAYTIME') LOOP

         lb_daytime_is_attribute := TRUE;
         lb_daytime_is_private := TRUE;

      END LOOP;

    END IF;

    -- Need to determine whether the table contains a 'class_name' name column.
    -- Check whether it is called CLASS_NAME or DATA_CLASS_NAME.
    IF EcDp_ClassMeta.HasTableColumn(lv2_tablename,'DATA_CLASS_NAME') THEN

       lv2_data_class_colum := 'DATA_CLASS_NAME';
       lv2_column_list := 'DATA_CLASS_NAME,';
       lv2_value_list := ''''||p_class_name||''',';

    ELSIF EcDp_ClassMeta.HasTableColumn(lv2_tablename,'CLASS_NAME') AND NOT ecdp_classmeta.IsValidAttribute(p_class_name, 'CLASS_NAME') THEN

       lv2_data_class_colum := 'CLASS_NAME';
       lv2_column_list := 'CLASS_NAME,';
       lv2_value_list := ''''||p_class_name||''',';

    ELSE

       lv2_data_class_colum := 'NULL';

    END IF;

    -- Preparing the strings that will be the main part of the INSERT, UPDATE and DELETE statements
    -- Building a column, value, update and key lists.

    FOR ClassesAttr3 IN EcDp_ClassMeta.c_classes_attr(p_class_name, 'N') LOOP

      IF ClassesAttr3.db_mapping_type = 'COLUMN'
      AND NOT ClassesAttr3.attribute_name IN('CREATED_BY','CREATED_DATE','LAST_UPDATED_BY','LAST_UPDATED_DATE','REV_NO','REV_TEXT','RECORD_STATUS')
      AND ClassesAttr3.report_only_ind = 'N' THEN

         lv2_column_list := lv2_column_list ||ClassesAttr3.db_sql_syntax||',';
         lv2_value_list := lv2_value_list ||'n_'||ClassesAttr3.attribute_name ||',';
         lv2_update_list := lv2_update_list ||ClassesAttr3.db_sql_syntax||' = n_'||ClassesAttr3.attribute_name ||',';

         IF ClassesAttr3.is_key = 'Y' THEN

           lv2_key_list := lv2_key_list ||ClassesAttr3.db_sql_syntax||'= o_'||ClassesAttr3.attribute_name ||' AND ';

           -- Build a return clause for the INSERT statement to pick up any changes in key from TABLE Triggers

           lv2_return_columns := lv2_return_columns || ClassesAttr3.db_sql_syntax ||',';
           lv2_return_values := lv2_return_values || 'n_'||ClassesAttr3.attribute_name ||',';

         END IF; -- is_key
      END IF; -- ClassesAttr3.db_mapping_type = 'COLUMN'

    END LOOP;  -- ClassesAttr

    FOR ClassesRel7 IN EcDp_ClassMeta.c_classes_rel(p_class_name) LOOP

      IF ClassesRel7.db_mapping_type IN ('COLUMN','ATTRIBUTE')
      AND UPPER(ClassesRel7.db_sql_syntax) <> 'OBJECT_ID'
      AND ClassesRel7.report_only_ind = 'N'  THEN  -- Should not be neccesary, but there are classes where this is wrongly configured

         lv2_column_list := lv2_column_list ||ClassesRel7.db_sql_syntax||',';
         lv2_value_list := lv2_value_list ||'n_'||ClassesRel7.role_name ||'_id,';
         lv2_update_list := lv2_update_list ||ClassesRel7.db_sql_syntax||' = n_'||ClassesRel7.role_name ||'_id,';

         IF ClassesRel7.is_key = 'Y' THEN

           lv2_key_list := lv2_key_list ||Classesrel7.db_sql_syntax||'= o_'||Classesrel7.role_name ||'_id AND ';

           lv2_return_columns := lv2_return_columns || Classesrel7.db_sql_syntax ||',';
           lv2_return_values := lv2_return_values || 'n_'||Classesrel7.role_name ||'_id,';


         END IF; -- is_key

      END IF; -- ClassesRel7.db_mapping_type = 'COLUMN'

    END LOOP;  -- ClassesRel


    lv2_column_list := lv2_column_list ||'CREATED_BY,CREATED_DATE,LAST_UPDATED_BY,LAST_UPDATED_DATE,REV_NO,REV_TEXT,RECORD_STATUS';
    lv2_value_list := lv2_value_list ||'n_CREATED_BY,n_CREATED_DATE,n_LAST_UPDATED_BY,n_LAST_UPDATED_DATE,n_REV_NO,n_REV_TEXT,n_RECORD_STATUS';
    IF EcDp_ClassMeta.IsUsingUserFunction() = 'N' THEN
    lv2_update_list := lv2_update_list || 'CREATED_BY = n_CREATED_BY, CREATED_DATE = n_CREATED_DATE , LAST_UPDATED_BY = n_LAST_UPDATED_BY,'||
                                                 'LAST_UPDATED_DATE = n_LAST_UPDATED_DATE ,REV_NO = n_rev_no, REV_TEXT = n_REV_TEXT,'||
                                                    'RECORD_STATUS = n_RECORD_STATUS';
    ELSE
      lv2_update_list := lv2_update_list || ' LAST_UPDATED_BY = n_LAST_UPDATED_BY,'||
                                                      'LAST_UPDATED_DATE = n_LAST_UPDATED_DATE ,REV_NO = n_rev_no, REV_TEXT = n_REV_TEXT,'||
                                                      'RECORD_STATUS = n_RECORD_STATUS';
    END IF;

   lb_has_rec_id_column := ColumnExists(lv2_main_tablename,'REC_ID',null);
   IF lb_approval_enabled THEN
      lv2_column_list := lv2_column_list||',APPROVAL_STATE,APPROVAL_BY,APPROVAL_DATE,REC_ID';
      lv2_value_list := lv2_value_list  ||',n_approval_state,n_approval_by,n_approval_date,n_rec_id';
      lv2_update_list := lv2_update_list||',APPROVAL_STATE = n_approval_state,APPROVAL_BY = n_approval_by,APPROVAL_DATE = n_approval_date,REC_ID = n_rec_id';
   ELSIF lb_has_rec_id_column THEN
     lv2_column_list := lv2_column_list||',REC_ID';
      lv2_value_list := lv2_value_list  ||',n_rec_id';
      lv2_update_list := lv2_update_list||',REC_ID = n_rec_id';
   END IF;

    lv2_key_list := SUBSTR(lv2_key_list,1,LENGTH(lv2_key_list)-5);

    lv2_return_columns := SUBSTR(lv2_return_columns,1,LENGTH(lv2_return_columns)-1);
    lv2_return_values := SUBSTR(lv2_return_values,1,LENGTH(lv2_return_values)-1);


  -----------------------------------------------------------------------------------------------------------------
  -- Start building the actual trigger, tries to do this as sequential as possible, so it should be simple to
  -- understand and maintain the code
  -----------------------------------------------------------------------------------------------------------------
   Ecdp_Dynsql.AddSqlLine(body_lines,'CREATE OR REPLACE TRIGGER IUD_' || p_class_name ||  chr(10) ||
              ' INSTEAD OF INSERT OR UPDATE OR DELETE ON DV_' || p_class_name ||  chr(10) ||
              ' FOR EACH ROW' || chr(10) || GeneratedCodeMsg || chr(10));

   -- declare section

   Ecdp_Dynsql.AddSqlLine(body_lines,'DECLARE' ||  chr(10));
   IF NOT ecdp_classmeta.IsValidAttribute(p_class_name, 'CLASS_NAME') THEN
      Ecdp_Dynsql.AddSqlLine(body_lines,'  n_class_name         VARCHAR2(30) := EcDB_Utils.ConditionNVL(NOT Updating(''CLASS_NAME''),:NEW.CLASS_NAME,:OLD.CLASS_NAME);' ||  chr(10));
   END IF;

   Ecdp_Dynsql.AddSqlLine(body_lines,'  n_record_status      VARCHAR2(1) := EcDB_Utils.ConditionNVL(NOT Updating(''RECORD_STATUS''),:NEW.record_status,:OLD.record_status);' ||  chr(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'  n_rev_no             NUMBER := NVL(:OLD.rev_no,0);' ||  chr(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'  n_rev_text           VARCHAR2(4000):= EcDB_Utils.ConditionNVL(NOT Updating(''REV_TEXT''),:NEW.rev_text,:OLD.rev_text);'||  chr(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'  n_created_by         VARCHAR2(30):= EcDB_Utils.ConditionNVL(NOT Updating(''CREATED_BY''),to_char(:NEW.created_by),to_char(:OLD.created_by));'||  chr(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'  n_created_date       DATE := EcDB_Utils.ConditionNVL(NOT Updating(''CREATED_DATE''),:NEW.created_date,:OLD.created_date);'||  chr(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'  n_last_updated_by    VARCHAR2(30):= EcDB_Utils.ConditionNVL(NOT Updating(''LAST_UPDATED_BY''),to_char(:NEW.last_updated_by),to_char(:OLD.last_updated_by));'|| CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'  n_last_updated_date  DATE := EcDB_Utils.ConditionNVL(NOT Updating(''LAST_UPDATED_DATE''),:NEW.last_updated_date,:OLD.last_updated_date);'||  chr(10) ||  chr(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'  o_created_by         VARCHAR2(30):= :OLD.created_by;'||  chr(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'  o_last_updated_by    VARCHAR2(30):= :OLD.last_updated_by;'|| CHR(10));

   Ecdp_Dynsql.AddSqlLine(body_lines,'  n_lock_columns       EcDp_Month_lock.column_list;'||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'  o_lock_columns       EcDp_Month_lock.column_list;'||CHR(10));


   -- Need variables for all class attributes and relations, because of possible class_trigger_actions
   -- First loop all class attributes

    FOR ClassesAttr IN EcDp_ClassMeta.c_classes_attr(p_class_name, 'N') LOOP

      IF ClassesAttr.db_mapping_type IN ('COLUMN','ATTRIBUTE')
      AND NOT ClassesAttr.attribute_name IN('DAYTIME','CREATED_BY','CREATED_DATE','LAST_UPDATED_BY','LAST_UPDATED_DATE','REV_NO','REV_TEXT','RECORD_STATUS')
      AND ClassesAttr.report_only_ind = 'N' THEN


         IF ClassesAttr.data_type IN ('NUMBER','INTEGER') THEN

            Ecdp_Dynsql.AddSqlLine(body_lines,'  n_'||ClassesAttr.attribute_name ||' NUMBER  := EcDB_Utils.ConditionNVL(NOT Updating('''||ClassesAttr.attribute_name||'''),:NEW.'||ClassesAttr.attribute_name||',:OLD.'||ClassesAttr.attribute_name||');' ||  chr(10));

         ELSIF ClassesAttr.data_type = 'DATE' THEN

            Ecdp_Dynsql.AddSqlLine(body_lines,'  n_'||ClassesAttr.attribute_name||' DATE := EcDB_Utils.ConditionNVL(NOT Updating('''||ClassesAttr.attribute_name||'''),:NEW.'||ClassesAttr.attribute_name||',:OLD.'||ClassesAttr.attribute_name||');' ||  chr(10));

         ELSE -- STRING

            Ecdp_Dynsql.AddSqlLine(body_lines,'  n_'||ClassesAttr.attribute_name||' VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('''||ClassesAttr.attribute_name||'''),:NEW.'||ClassesAttr.attribute_name||',:OLD.'||ClassesAttr.attribute_name||');' ||  chr(10));

            IF ClassesAttr.attribute_name = 'OBJECT_ID' THEN
              Ecdp_Dynsql.AddSqlLine(body_lines,'  n_object_code VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating(''OBJECT_CODE''),:NEW.object_code,:OLD.object_code);' ||  chr(10));

            END IF;


         END IF;

         IF ClassesAttr.is_key = 'Y' THEN

            IF ClassesAttr.data_type IN ('NUMBER','INTEGER') THEN

               Ecdp_Dynsql.AddSqlLine(body_lines,'  o_'||ClassesAttr.attribute_name ||' NUMBER  := :OLD.'||ClassesAttr.attribute_name||';' ||  chr(10));

            ELSIF ClassesAttr.data_type = 'DATE' THEN

               Ecdp_Dynsql.AddSqlLine(body_lines,'  o_'||ClassesAttr.attribute_name||' DATE := :OLD.'||ClassesAttr.attribute_name||';' ||  chr(10));

            ELSE -- STRING

               Ecdp_Dynsql.AddSqlLine(body_lines,'  o_'||ClassesAttr.attribute_name||' VARCHAR2(4000) := :OLD.'||ClassesAttr.attribute_name||';' ||  chr(10));

            END IF;

         END IF; -- is_key

       END IF; -- ClassesAttr.db_mapping_type <> 'FUNCTION'


    END LOOP;  -- ClassesAttr

    FOR ClassesRel IN EcDp_ClassMeta.c_classes_rel(p_class_name) LOOP

      IF ClassesRel.report_only_ind = 'N' THEN

        Ecdp_Dynsql.AddSqlLine(body_lines, '  n_' || ClassesRel.role_name || '_ID objects.object_id%TYPE := EcDB_Utils.ConditionNVL(NOT Updating('''||ClassesRel.role_name||'_ID''),:NEW.'||ClassesRel.role_name||'_ID,:OLD.'||ClassesRel.role_name||'_ID);' ||  chr(10));
        Ecdp_Dynsql.AddSqlLine(body_lines, '  n_' || ClassesRel.role_name || '_CO objects.code%TYPE := EcDB_Utils.ConditionNVL(NOT Updating('''||ClassesRel.role_name||'_CODE''),:NEW.'||ClassesRel.role_name||'_CODE,:OLD.'||ClassesRel.role_name||'_CODE);' ||  chr(10));

        IF Classesrel.is_key = 'Y' THEN
          Ecdp_Dynsql.AddSqlLine(body_lines, '  o_' || ClassesRel.role_name || '_ID   objects.object_id%TYPE := :OLD.'||ClassesRel.role_name||'_ID;' ||  chr(10));
        END IF; -- is_key

      END IF;

    END LOOP;  -- ClassesRel

   IF lb_daytime_is_attribute AND NOT lb_daytime_is_private THEN

     Ecdp_Dynsql.AddSqlLine(body_lines,'  n_daytime  DATE := EcDB_Utils.ConditionNVL(NOT Updating(''DAYTIME''),:NEW.DAYTIME,:OLD.DAYTIME);'||  chr(10));

      IF lb_daytime_is_key THEN

        Ecdp_Dynsql.AddSqlLine(body_lines,'  o_daytime  DATE := :OLD.DAYTIME;'||  chr(10) ||  chr(10));

      END IF;

   ELSIF lb_daytime_is_attribute THEN  -- private attribute, assume that there is a function in db_sql_syntax that will calculate daytime

    FOR CurPrivateDaytime IN EcDp_ClassMeta.c_classes_attr(p_class_name, 'Y','DAYTIME') LOOP

      Ecdp_Dynsql.AddSqlLine(body_lines, '  n_daytime  DATE := '||CurPrivateDaytime.db_sql_syntax||';'||  chr(10) ||  chr(10));

    END LOOP;

   ELSE  -- create a daytime variable anyway, can be used by Trigger action, set it initaly to object_start_date

      IF lv2_owner_class IS NOT NULL THEN
         Ecdp_Dynsql.AddSqlLine(body_lines, '  n_daytime  DATE := EcDp_Objects.getObjStartDate(n_object_id);'||CHR(10)||CHR(10));
       ELSE
         Ecdp_Dynsql.AddSqlLine(body_lines, '  n_daytime  DATE := EcDp_Date_Time.getCurrentSysdate;'||CHR(10)||CHR(10));
       END IF;

   END IF;

   IF lb_approval_enabled THEN
     Ecdp_Dynsql.AddSqlLines(body_lines, IUTrgApprovalStateVariables(p_class_name));
   ELSIF lb_has_rec_id_column THEN
     Ecdp_Dynsql.AddSqlLine(body_lines,'   n_rec_id          VARCHAR2(32) := :NEW.rec_id;'||CHR(10));
   END IF;

    Ecdp_Dynsql.AddSqlLine(body_lines,CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'BEGIN' || chr(10)|| chr(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,' --------------------------------------------------------------------------' || chr(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,' -- Start Before Trigger action block' || chr(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,' -- Need to find object_ids for foreign references given by code before we leave the control to user exit' || chr(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,' -- Also set record status columns in this section to allow user exits to overule them later' || chr(10)|| chr(10));

    IF NOT lb_skip_trg_check THEN

    Ecdp_Dynsql.AddSqlLine(body_lines,' IF INSERTING THEN -- set any default values from CTRL_ATTRIBUTE.DEFAULT_VALUE ' || chr(10)|| chr(10));

    Ecdp_Dynsql.AddSqlLine(body_lines,'    NULL; -- In case there are no default values ' || CHR(10));

    FOR ClassesAttrDef IN EcDp_ClassMeta.c_classes_attr(p_class_name) LOOP

      IF ClassesAttrDef.default_value IS NOT NULL AND ClassesAttrDef.report_only_ind = 'N' THEN

         Ecdp_Dynsql.AddSqlLine(body_lines,'   IF  n_' || ClassesAttrDef.attribute_name ||' IS NULL  THEN n_' || ClassesAttrDef.attribute_name || ' := ' ||ClassesAttrDef.default_value ||'; END IF;'|| chr(10));

      END IF;

    END LOOP;

    Ecdp_Dynsql.AddSqlLine(body_lines,CHR(10));

    Ecdp_Dynsql.AddSqlLine(body_lines,' END IF;  -- set any default values  ' || chr(10)|| chr(10));

    END IF;

    Ecdp_Dynsql.AddSqlLine(body_lines,' IF INSERTING OR UPDATING THEN ' || chr(10)|| chr(10));


    IF NOT lb_skip_trg_check THEN

    IF lv2_data_class_colum <> 'NULL' THEN
      Ecdp_Dynsql.AddSqlLine(body_lines, '   IF n_class_name IS NOT NULL AND rtrim(upper(n_class_name)) <> rtrim(upper('''||p_class_name ||''')) THEN Raise_Application_Error(-20104,''Given class_name do not correspond to view class name.''); END IF;' ||  chr(10)||  chr(10));
    END IF;

    IF lb_use_object_id THEN

      Ecdp_Dynsql.AddSqlLine(body_lines,'   -- Get object_id given object_code'||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'   IF n_object_id IS NULL AND n_object_code IS NOT NULL THEN'||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'      n_object_id := EcDp_Objects.GetObjIDFromCode('''||lv2_owner_class||''',n_object_code);'||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'   END IF;'||CHR(10));

    END IF;

    FOR ClassesRel3 IN EcDp_ClassMeta.c_classes_rel(p_class_name) LOOP

      IF ClassesRel3.report_only_ind = 'N' THEN

        Ecdp_Dynsql.AddSqlLine(body_lines,CHR(10));
        Ecdp_Dynsql.AddSqlLine(body_lines,'   IF ( INSERTING  AND n_'||ClassesRel3.role_name||'_ID IS NULL AND n_'||ClassesRel3.role_name||'_CO IS NOT NULL) '||CHR(10));
        Ecdp_Dynsql.AddSqlLine(body_lines,'   OR ( UPDATING  AND NOT UPDATING('''||ClassesRel3.role_name||'_ID'') AND UPDATING('''||ClassesRel3.role_name||'_CODE'')) THEN '||CHR(10));
        Ecdp_Dynsql.AddSqlLine(body_lines,'      n_'||ClassesRel3.role_name||'_ID := EcDp_Objects.GetObjIDFromCode('''||ClassesRel3.from_class_name||''', n_'||ClassesRel3.role_name||'_co);'||CHR(10));
        Ecdp_Dynsql.AddSqlLine(body_lines,'   END IF;'||CHR(10));

      END IF;

    END LOOP;

    Ecdp_Dynsql.AddSqlLine(body_lines,chr(10));

    END IF; -- lb_skip_trg_check


    Ecdp_Dynsql.AddSqlLine(body_lines,EcDp_ClassJournalHelper.makeJournalRuleSection(p_class_name) ||chr(10));



   Ecdp_Dynsql.AddSqlLine(body_lines, '   IF INSERTING THEN' ||CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines, '     n_created_by :=  Nvl(n_created_by,user);'|| CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines, '     n_created_date := Nvl(n_created_date,EcDp_Date_Time.getCurrentSysdate);'|| CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines, '     n_RECORD_STATUS := Nvl(n_RECORD_STATUS,''P'');'|| CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines, '   ELSE  -- UPDATING'|| CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines, '     IF  NOT UPDATING(''LAST_UPDATED_BY'') OR n_last_updated_by IS NULL THEN  n_last_updated_by := USER;  END IF;'|| CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines, '     IF  NOT UPDATING(''LAST_UPDATED_DATE'') OR n_last_updated_date IS NULL THEN  n_last_updated_date := EcDp_Date_Time.getCurrentSysdate;  END IF;'|| CHR(10));
   Ecdp_Dynsql.AddSqlLine(body_lines, '   END IF;  -- IF INSERTING'|| CHR(10)|| CHR(10));


    Ecdp_Dynsql.AddSqlLine(body_lines,' END IF;  -- INSERTING OR UPDATING' || chr(10)|| chr(10));






    Ecdp_Dynsql.AddSqlLine(body_lines,' -- End Before Trigger Action block -------------------------------------------------' || chr(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,' -------------------------------------------------------------------------------' || chr(10)|| chr(10));

    IF NOT lb_skip_trg_check THEN

    Ecdp_Dynsql.AddSqlLine(body_lines,' --*************************************************************************************' || chr(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,' -- Start Trigger Action block' || chr(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,' -- Any code block defined as a BEFORE trigger-type in table CLASS_TRIGGER_ACTION will be put here' || chr(10) || chr(10));

    FOR ClassBeforeAction IN EcDp_ClassMeta.c_class_trigger_action(p_class_name,'BEFORE') LOOP

     Ecdp_Dynsql.AddSqlLine(body_lines, ' IF ' || ClassbeforeAction.triggering_event || ' THEN ' || chr(10)|| chr(10));

     Ecdp_Dynsql.AddSqlLine(body_lines,  ClassbeforeAction.db_sql_syntax || CHR(10)|| chr(10));

     Ecdp_Dynsql.AddSqlLine(body_lines,  ' END IF;' || chr(10)|| chr(10));

    END LOOP;



    Ecdp_Dynsql.AddSqlLine(body_lines,' --' || chr(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,' -- end Trigger Action block Class_trigger_actions before' || chr(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,' --*************************************************************************************' || chr(10)|| chr(10));

    END IF; -- lb_skip_trg_check


   -- Populate parameters for lock function
   IF   lv2_lock_ind = 'Y' THEN

     Ecdp_Dynsql.AddSqlLine(body_lines,'  EcDp_month_lock.AddParameterToList(n_lock_columns'||
                                                       ',''CLASS_NAME'''||
                                                       ','''||UPPER(p_class_name)||''''||
                                                       ',''STRING''' ||
                                                       ',NULL' ||
                                                       ',NULL' ||
                                                       ',NULL);'||CHR(10));

     Ecdp_Dynsql.AddSqlLine(body_lines,'  EcDp_month_lock.AddParameterToList(n_lock_columns'||
                                                       ',''TABLE_NAME'''||
                                                       ','''||UPPER(lv2_tablename)||''''||
                                                       ',''STRING''' ||
                                                       ',NULL' ||
                                                       ',NULL' ||
                                                       ',NULL);'||CHR(10));

     Ecdp_Dynsql.AddSqlLine(body_lines,'  EcDp_month_lock.AddParameterToList(o_lock_columns'||
                                                       ',''CLASS_NAME'''||
                                                       ','''||UPPER(p_class_name)||''''||
                                                       ',''STRING''' ||
                                                       ',NULL' ||
                                                       ',NULL' ||
                                                       ',NULL);'||CHR(10));

     Ecdp_Dynsql.AddSqlLine(body_lines,'  EcDp_month_lock.AddParameterToList(o_lock_columns'||
                                                       ',''TABLE_NAME'''||
                                                       ','''||UPPER(lv2_tablename)||''''||
                                                       ',''STRING''' ||
                                                       ',NULL' ||
                                                       ',NULL' ||
                                                       ',NULL);'||CHR(10));


     FOR ClassesAttr_lock IN EcDp_ClassMeta.c_classes_attr(p_class_name, 'N') LOOP

        IF ClassesAttr_lock.db_mapping_type = 'COLUMN'
        AND NOT ClassesAttr_lock.attribute_name IN('CREATED_BY','CREATED_DATE','LAST_UPDATED_BY','LAST_UPDATED_DATE','REV_NO','REV_TEXT','RECORD_STATUS')
        AND ClassesAttr_lock.report_only_ind = 'N'
        AND ClassesAttr_lock.data_type IN ('STRING','NUMBER','INTEGER','DATE','VARCHAR2')
        THEN


            Ecdp_Dynsql.AddSqlLine(body_lines,'  EcDp_month_lock.AddParameterToList(n_lock_columns'||
                                                     ','''||UPPER(ClassesAttr_lock.attribute_name)||''''||
                                                     ','''||UPPER(ClassesAttr_lock.db_sql_syntax)||''''||
                                                     ','''||UPPER(ClassesAttr_lock.data_type)||''''||
                                                     ','''||Nvl(ClassesAttr_lock.is_key,'N')||''''||
                                                     ',EcDp_month_lock.isUpdating(UPDATING('''||UPPER(ClassesAttr_lock.attribute_name)||''')),'||
                                                     ecdp_dynsql.Anydata_to_String(ClassesAttr_lock.data_type,'n_'||ClassesAttr_lock.attribute_name)||');'||CHR(10));

            Ecdp_Dynsql.AddSqlLine(body_lines,'  EcDp_month_lock.AddParameterToList(o_lock_columns'||
                                                     ','''||UPPER(ClassesAttr_lock.attribute_name)||''''||
                                                     ','''||UPPER(ClassesAttr_lock.db_sql_syntax)||''''||
                                                     ','''||UPPER(ClassesAttr_lock.data_type)||''''||
                                                     ','''||Nvl(ClassesAttr_lock.is_key,'N')||''''||
                                                     ',EcDp_month_lock.isUpdating(UPDATING('''||UPPER(ClassesAttr_lock.attribute_name)||''')),'||
                                                     ecdp_dynsql.Anydata_to_String(ClassesAttr_lock.data_type,':OLD.'||ClassesAttr_lock.attribute_name)||');'||CHR(10));

            IF UPPER(ClassesAttr_lock.attribute_name) = 'OBJECT_ID' AND lv2_owner_class IS NOT NULL THEN

              Ecdp_Dynsql.AddSqlLine(body_lines,'  EcDp_month_lock.AddParameterToList(n_lock_columns'||
                                                       ',''OBJECT_CODE'''||
                                                       ',''OBJECT_CODE'''||
                                                       ',''VARCHAR2'''||
                                                       ',''Y'''||
                                                       ',EcDp_month_lock.isUpdating(UPDATING('''||UPPER(ClassesAttr_lock.attribute_name)||''')),'||
                                                       ecdp_dynsql.Anydata_to_String('VARCHAR2','n_object_code')||');'||CHR(10));

              Ecdp_Dynsql.AddSqlLine(body_lines,'  EcDp_month_lock.AddParameterToList(o_lock_columns'||
                                                       ',''OBJECT_CODE'''||
                                                       ',''OBJECT_CODE'''||
                                                       ',''VARCHAR2'''||
                                                       ',''Y'''||
                                                       ',EcDp_month_lock.isUpdating(UPDATING('''||UPPER(ClassesAttr_lock.attribute_name)||''')),'||
                                                       ecdp_dynsql.Anydata_to_String('VARCHAR2',':OLD.OBJECT_CODE')||');'||CHR(10));


            END IF; -- 'OBJECT_ID'




       END IF; -- ClassesAttr3.db_mapping_type = 'COLUMN'

     END LOOP;  -- ClassesAttr


    FOR ClassesRel_lock IN EcDp_ClassMeta.c_classes_rel(p_class_name) LOOP

        IF ClassesRel_lock.db_mapping_type = 'COLUMN' THEN


        Ecdp_Dynsql.AddSqlLine(body_lines,'  EcDp_month_lock.AddParameterToList(n_lock_columns'||
                                                 ','''||UPPER(ClassesRel_lock.role_name)||'_ID'''||
                                                 ','''||UPPER(ClassesRel_lock.db_sql_syntax)||''''||
                                                 ',''VARCHAR2'''||
                                                 ','''||Nvl(ClassesRel_lock.is_key,'N')||''''||
                                                 ',EcDp_month_lock.isUpdating(UPDATING('''||UPPER(ClassesRel_lock.role_name)||'_ID'')),'||
                                                 ecdp_dynsql.Anydata_to_String('VARCHAR2','n_'||UPPER(ClassesRel_lock.role_name)||'_ID')||');'||CHR(10));

        Ecdp_Dynsql.AddSqlLine(body_lines,'  EcDp_month_lock.AddParameterToList(n_lock_columns'||
                                                 ','''||UPPER(ClassesRel_lock.role_name)||'_CODE'''||
                                                 ','''||UPPER(ClassesRel_lock.db_sql_syntax)||''''||
                                                 ',''VARCHAR2'''||
                                                 ','''||Nvl(ClassesRel_lock.is_key,'N')||''''||
                                                 ',EcDp_month_lock.isUpdating(UPDATING('''||UPPER(ClassesRel_lock.role_name)||'_CODE'')),'||
                                                 ecdp_dynsql.Anydata_to_String('VARCHAR2','n_'||UPPER(ClassesRel_lock.role_name)||'_CO')||');'||CHR(10));

        Ecdp_Dynsql.AddSqlLine(body_lines,'  EcDp_month_lock.AddParameterToList(o_lock_columns'||
                                                 ','''||UPPER(ClassesRel_lock.role_name)||'_ID'''||
                                                 ','''||UPPER(ClassesRel_lock.db_sql_syntax)||''''||
                                                 ',''VARCHAR2'''||
                                                 ','''||Nvl(ClassesRel_lock.is_key,'N')||''''||
                                                 ',EcDp_month_lock.isUpdating(UPDATING('''||UPPER(ClassesRel_lock.role_name)||'_ID'')),'||
                                                 ecdp_dynsql.Anydata_to_String('VARCHAR2',':old.'||UPPER(ClassesRel_lock.role_name)||'_ID')||');'||CHR(10));

        Ecdp_Dynsql.AddSqlLine(body_lines,'  EcDp_month_lock.AddParameterToList(o_lock_columns'||
                                                 ','''||UPPER(ClassesRel_lock.role_name)||'_CODE'''||
                                                 ','''||UPPER(ClassesRel_lock.db_sql_syntax)||''''||
                                                 ',''VARCHAR2'''||
                                                 ','''||Nvl(ClassesRel_lock.is_key,'N')||''''||
                                                 ',EcDp_month_lock.isUpdating(UPDATING('''||UPPER(ClassesRel_lock.role_name)||'_CODE'')),'||
                                                 ecdp_dynsql.Anydata_to_String('VARCHAR2',':old.'||UPPER(ClassesRel_lock.role_name)||'_CODE')||');'||CHR(10));


     END IF; -- ClassesRel_lock.db_mapping_type = 'COLUMN'

    END LOOP;  -- ClassesRel



     Ecdp_Dynsql.AddSqlLine(body_lines,CHR(10)||CHR(10));


     Ecdp_Dynsql.AddSqlLine(body_lines,'  IF INSERTING THEN ' ||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'    '||lv2_lock_rule||'(''INSERTING'',n_lock_columns,o_lock_columns);' ||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'  ELSIF UPDATING THEN ' ||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'    '||lv2_lock_rule||'(''UPDATING'',n_lock_columns,o_lock_columns);' ||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'  ELSIF DELETING THEN ' ||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'    '||lv2_lock_rule||'(''DELETING'',n_lock_columns,o_lock_columns);' ||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'  END IF;' ||CHR(10)||CHR(10));

   END IF; -- lv2_lock_ind

    IF lb_approval_enabled THEN
      Ecdp_Dynsql.AddSqlLines(body_lines, IUTrgApprovalStateHandling(p_class_name,'DATA'));
    END IF;

    Ecdp_Dynsql.AddSqlLine(body_lines,' IF INSERTING THEN' || chr(10)|| chr(10));

    IF NOT lb_skip_trg_check THEN

    Ecdp_Dynsql.AddSqlLine(body_lines, '    -- Start Insert check block ---------------------------------------'||  chr(10));

    IF lb_use_object_id THEN

       Ecdp_Dynsql.AddSqlLine(body_lines, '    IF n_Object_id IS NULL THEN Raise_Application_Error(-20103,''Missing value for object_id/object code''); END IF;'||  chr(10));

    END IF;

    FOR ClassesAttr2 IN EcDp_ClassMeta.c_classes_attr(p_class_name) LOOP

        -- include check for each property defined as mandatory
        IF  ClassesAttr2.is_mandatory = 'Y' AND ClassesAttr2.attribute_name NOT IN ('OBJECT_ID','OBJECT_CODE')
        AND ClassesAttr2.db_mapping_type <> 'FUNCTION' AND ClassesAttr2.report_only_ind = 'N' THEN

           IF ClassesAttr2.data_type IN ('NUMBER','INTEGER') THEN

             Ecdp_Dynsql.AddSqlLine(body_lines, '    IF n_' || ClassesAttr2.attribute_name || ' IS NULL THEN Raise_Application_Error(-20103,''Missing value for '|| ClassesAttr2.attribute_name||'''); END IF;'||  chr(10));


           ELSIF ClassesAttr2.data_type = 'DATE' THEN

             Ecdp_Dynsql.AddSqlLine(body_lines, '    IF n_' || ClassesAttr2.attribute_name || ' IS NULL THEN Raise_Application_Error(-20103,''Missing value for '|| ClassesAttr2.attribute_name||'''); END IF;'||  chr(10));


           ELSE -- String

             Ecdp_Dynsql.AddSqlLine(body_lines,'    IF n_' || ClassesAttr2.attribute_name || ' IS NULL THEN Raise_Application_Error(-20103,''Missing value for '|| ClassesAttr2.attribute_name||'''); END IF;'||  chr(10));


           END IF;


        END IF;

        -- Date check
        IF ClassesAttr2.attribute_name IN ('START_DATE', 'DAYTIME', 'FROM_DAYTIME','FROM_DATE','END_DATE','TO_DAYTIME','TO_DATE')
        AND ClassesAttr2.db_mapping_type = 'COLUMN' THEN

          Ecdp_Dynsql.AddSqlLine(body_lines,'    IF n_'||ClassesAttr2.attribute_name|| ' < EcDp_System_Constants.Earliest_date THEN ');
          Ecdp_Dynsql.AddSqlLine(body_lines,' Raise_Application_Error(-20104,''Cannot set '|| ClassesAttr2.attribute_name || ' before system earliest date: '||TO_CHAR(EcDp_System_Constants.Earliest_date,'dd.mm.yyyy' )||'''); END IF;'||CHR(10));

          IF ClassesAttr2.attribute_name IN ('START_DATE', 'DAYTIME', 'FROM_DAYTIME','FROM_DATE') THEN
            lv2_check_period_start := ClassesAttr2.attribute_name;
          END IF;

          IF ClassesAttr2.attribute_name IN ('END_DATE','TO_DAYTIME','TO_DATE') THEN
            lv2_check_period_end := ClassesAttr2.attribute_name;
          END IF;

        END IF;

    END LOOP;

     -- Date period check
    IF lv2_check_period_start IS NOT NULL AND lv2_check_period_end IS NOT NULL THEN -- Add consistent period check
      Ecdp_Dynsql.AddSqlLine(body_lines,'    IF n_'||lv2_check_period_start|| ' > nvl(n_'||lv2_check_period_end||',n_'||lv2_check_period_start||') THEN '||
                                  ' Raise_Application_Error(-20104,'''|| lv2_check_period_end || ' cannot be before '||lv2_check_period_start||': ''||n_'||lv2_check_period_start||'); END IF; ' || CHR(10));
    END IF;

    FOR ClassesRel4 IN EcDp_ClassMeta.c_classes_rel(p_class_name) LOOP

        -- include check for each property defined as mandatory
        IF ClassesRel4.is_mandatory = 'Y'  AND ClassesRel4.report_only_ind = 'N' THEN

           Ecdp_Dynsql.AddSqlLine(body_lines,'    IF n_' || ClassesRel4.role_name || '_ID IS NULL THEN Raise_Application_Error(-20103,''Missing value for '|| ClassesRel4.role_name||'_ID''); END IF;'||CHR(10));

        END IF;

    END LOOP;

    Ecdp_Dynsql.AddSqlLine(body_lines, '    -- End Insert check block ---------------------------------------'||  chr(10)||  chr(10));

    Ecdp_Dynsql.AddSqlLine(body_lines, '  -- Start Insert relation block ---------------------------------------'||  chr(10));

    IF lb_use_object_id THEN

      Ecdp_Dynsql.AddSqlLine(body_lines,'    IF ecdp_objects.isValidOwnerReference('''||p_class_name||''',n_OBJECT_ID) = ''N''  THEN ' || chr(10));
      Ecdp_Dynsql.AddSqlLine(body_lines, '      Raise_Application_Error(-20106,''Given object id is not of the same class as the owner class for this data class.'') ;' ||   chr(10));
      Ecdp_Dynsql.AddSqlLine(body_lines, '    END IF;' || CHR(10)||CHR(10)) ;

      IF lb_daytime_is_key AND Nvl(lv2_time_scope_code,'X') <> 'NONE' THEN -- Add daytime validation against parent object start date.

        IF Ecdp_Classmeta.getClassAttributeDbMappingType(p_class_name, 'PRODUCTION_DAY') = 'COLUMN' THEN

           Ecdp_Dynsql.AddSqlLine(body_lines, '    IF TRUNC(EcDp_Objects.getOBjStartDate(n_object_id)) > EcDp_ProductionDay.getProductionDay('''|| lv2_owner_class ||''', n_object_id, n_daytime) THEN'||CHR(10));

        ELSE

        CASE lv2_time_scope_code  -- Add different daytime check based on the time_scope_code

          WHEN 'DAY' THEN
            Ecdp_Dynsql.AddSqlLine(body_lines, '    IF TRUNC(EcDp_Objects.getOBjStartDate(n_object_id)) > n_daytime THEN'||CHR(10));
          WHEN 'MTH' THEN
            Ecdp_Dynsql.AddSqlLine(body_lines, '    IF TRUNC(EcDp_Objects.getOBjStartDate(n_object_id),''mm'') > n_daytime THEN'||CHR(10));
          WHEN 'YR' THEN
            Ecdp_Dynsql.AddSqlLine(body_lines, '    IF EcDp_Objects.getOBjStartDate(n_object_id) - 365 > n_daytime THEN'||CHR(10));
          ELSE
            Ecdp_Dynsql.AddSqlLine(body_lines, '    IF EcDp_Objects.getOBjStartDate(n_object_id) > n_daytime THEN'||CHR(10));

        END CASE;

        END IF;

        Ecdp_Dynsql.AddSqlLine(body_lines,'       RAISE_APPLICATION_ERROR(-20109,''Daytime is less than owner objects start date.'');'||CHR(10));
        Ecdp_Dynsql.AddSqlLine(body_lines,'    END IF;'||CHR(10)||CHR(10));

        IF Ecdp_Classmeta.getClassAttributeDbMappingType(p_class_name, 'PRODUCTION_DAY') = 'COLUMN' THEN

           Ecdp_Dynsql.AddSqlLine(body_lines, '    IF EcDp_ProductionDay.getProductionDay('''|| lv2_owner_class ||''', n_object_id, n_daytime) >= nvl(EcDp_Objects.getObjEndDate(n_object_id),n_Daytime + 1) THEN'||CHR(10));

        ELSE

        Ecdp_Dynsql.AddSqlLine(body_lines,'    IF n_Daytime >= nvl(EcDp_Objects.getObjEndDate(n_object_id),n_Daytime + 1) THEN'||CHR(10));

        END IF;

        Ecdp_Dynsql.AddSqlLine(body_lines,'       Raise_Application_Error(-20109,''Daytime must be less than owner objects end date.'');'||CHR(10));
        Ecdp_Dynsql.AddSqlLine(body_lines,'    END IF;'||CHR(10)||CHR(10));

      END IF;

    END IF;

    -- LOOP ALL relations to look for date mismatches

    FOR ClassesRel5 IN EcDp_ClassMeta.c_classes_rel(p_class_name) LOOP

        IF ClassesRel5.report_only_ind = 'N' THEN

          IF Nvl(lv2_time_scope_code,'X') <> 'NONE' THEN

            CASE lv2_time_scope_code  -- Add different daytime check based on the time_scope_code

            WHEN 'DAY' THEN
            Ecdp_Dynsql.AddSqlLine(body_lines, '    IF TRUNC(EcDp_Objects.getOBjStartDate(n_' || ClassesRel5.role_name || '_id)) > n_daytime THEN'||CHR(10));
            WHEN 'MTH' THEN
              Ecdp_Dynsql.AddSqlLine(body_lines, '    IF TRUNC(EcDp_Objects.getOBjStartDate(n_' || ClassesRel5.role_name || '_id),''mm'') > n_daytime THEN'||CHR(10));
            WHEN 'YR' THEN
              Ecdp_Dynsql.AddSqlLine(body_lines, '    IF EcDp_Objects.getOBjStartDate(n_' || ClassesRel5.role_name || '_id) - 365 > n_daytime THEN'||CHR(10));
            ELSE
              Ecdp_Dynsql.AddSqlLine(body_lines, '    IF EcDp_Objects.getOBjStartDate(n_' || ClassesRel5.role_name || '_id) > n_daytime THEN'||CHR(10));

          END CASE;

          Ecdp_Dynsql.AddSqlLine(body_lines, '       RAISE_APPLICATION_ERROR(-20109,'' Referred '|| ClassesRel5.role_name||' cannot have a start date later than daytime for this object. '');'||CHR(10));
          Ecdp_Dynsql.AddSqlLine(body_lines, '    END IF;'||CHR(10)||CHR(10));

          END IF;

          Ecdp_Dynsql.AddSqlLine(body_lines, '    IF n_'|| ClassesRel5.role_name ||'_ID IS NOT NULL AND EcDp_objects.isValidClassReference('''||ClassesRel5.from_class_name||''',n_'|| ClassesRel5.role_name ||'_ID) =  ''N'' THEN ' ||  chr(10)) ;
          Ecdp_Dynsql.AddSqlLine(body_lines, '       Raise_Application_Error(-20104,''Referenced '||ClassesRel5.role_name||' is not an object of type '||ClassesRel5.from_class_name||' .'' );' ||  chr(10)) ;
          Ecdp_Dynsql.AddSqlLine(body_lines, '    END IF;' ||  chr(10) ||  chr(10)) ;

        END IF;

    END LOOP;

    Ecdp_Dynsql.AddSqlLine(body_lines, '    -- End Insert relation block ---------------------------------------'||  chr(10));

    END IF; --lb_skip_trg_check

    FOR curRel IN EcDp_ClassMeta.c_classes_rel(p_class_name) LOOP
        IF curRel.access_control_method='ACL_LOOKUP' THEN
          -- Add check for all access controlled references
           Ecdp_Dynsql.AddSqlLine(body_lines,'   IF INSERTING OR UPDATING('''||curRel.Role_Name||'_ID'') OR UPDATING('''||curRel.Role_Name||'_CODE'') THEN'||CHR(10));
           Ecdp_Dynsql.AddSqlLine(body_lines,'      -- Access check for '||curRel.role_name||'.'||CHR(10));
          Ecdp_Dynsql.AddSqlLine(body_lines,'      EcDp_ACL.AssertAccess(n_'||curRel.role_name||'_ID, '''||curRel.from_class_name||''');'||CHR(10));
          Ecdp_Dynsql.AddSqlLine(body_lines,'   END IF;'||CHR(10));
           Ecdp_Dynsql.AddSqlLine(body_lines,CHR(10));
        END IF;
    END LOOP;

  -- OK Build the actual Insert statement
    IF lb_approval_enabled THEN
      Ecdp_Dynsql.AddSqlLine(body_lines,'    -- Don''t register task detail if inserting as official.'|| CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'    IF n_approval_state!=''O'' THEN EcDp_Approval.registerTaskDetail(n_rec_id, '''||p_class_name||''', n_created_by); END IF;'|| CHR(10));
    END IF;

    Ecdp_Dynsql.AddSqlLine(body_lines,'    INSERT INTO '||lv2_main_tablename || '('||lv2_column_list||')'||CHR(10)||
                          '    VALUES('||lv2_value_list||')');

    IF viewExists(lv2_main_tablename, lv2_db_owner) THEN
       Ecdp_Dynsql.AddSqlLine(body_lines, ' ;' || chr(10) || chr(10));
    ELSE
       Ecdp_Dynsql.AddSqlLine(body_lines, CHR(10) || '    RETURNING ' || lv2_return_columns || ' INTO '|| lv2_return_values || ' ;' || chr(10)||  chr(10));
    END IF;
    ----------------------------------------------------------------------------------------------
    -- Update part
    ----------------------------------------------------------------------------------------------

    Ecdp_Dynsql.AddSqlLine(body_lines, '  ELSIF UPDATING THEN '||  chr(10)||  chr(10));

    IF NOT lb_skip_trg_check THEN

    Ecdp_Dynsql.AddSqlLine(body_lines, '    -- Start Update check block ---------------------------------------'||  chr(10));

    FOR ClassesAttr3 IN EcDp_ClassMeta.c_classes_attr(p_class_name) LOOP

        -- include check for each property defined as mandatory
        IF  ClassesAttr3.is_mandatory = 'Y' AND ClassesAttr3.attribute_name NOT IN ('OBJECT_ID','OBJECT_CODE')
        AND ClassesAttr3.db_mapping_type <> 'FUNCTION' AND ClassesAttr3.report_only_ind = 'N' THEN

           IF ClassesAttr3.data_type IN ('NUMBER','INTEGER') THEN

             Ecdp_Dynsql.AddSqlLine(body_lines, '    IF n_' || ClassesAttr3.attribute_name || ' IS NULL THEN Raise_Application_Error(-20103,''Missing value for '|| ClassesAttr3.attribute_name||'''); END IF;'||  chr(10));


           ELSIF ClassesAttr3.data_type = 'DATE' THEN

             Ecdp_Dynsql.AddSqlLine(body_lines, '    IF n_' || ClassesAttr3.attribute_name || ' IS NULL THEN Raise_Application_Error(-20103,''Missing value for '|| ClassesAttr3.attribute_name||'''); END IF;'||  chr(10));


           ELSE -- String

             Ecdp_Dynsql.AddSqlLine(body_lines, '    IF n_' || ClassesAttr3.attribute_name || ' IS NULL THEN Raise_Application_Error(-20103,''Missing value for '|| ClassesAttr3.attribute_name||'''); END IF;'||  chr(10));


           END IF;

        END IF;

        -- Date check
        IF ClassesAttr3.attribute_name IN ('START_DATE', 'DAYTIME', 'FROM_DAYTIME','FROM_DATE','END_DATE','TO_DAYTIME','TO_DATE')
        AND ClassesAttr3.db_mapping_type = 'COLUMN' THEN

          Ecdp_Dynsql.AddSqlLine(body_lines,'    IF n_'||ClassesAttr3.attribute_name|| ' < EcDp_System_Constants.Earliest_date THEN ');
          Ecdp_Dynsql.AddSqlLine(body_lines,' Raise_Application_Error(-20104,''Cannot set '|| ClassesAttr3.attribute_name || ' before system earliest date: '||TO_CHAR(EcDp_System_Constants.Earliest_date,'dd.mm.yyyy' )||'''); END IF;'||CHR(10));

          IF ClassesAttr3.attribute_name IN ('START_DATE', 'DAYTIME', 'FROM_DAYTIME','FROM_DATE') THEN
            lv2_check_period_start := ClassesAttr3.attribute_name;
          END IF;

          IF ClassesAttr3.attribute_name IN ('END_DATE','TO_DAYTIME','TO_DATE') THEN
            lv2_check_period_end := ClassesAttr3.attribute_name;
          END IF;

        END IF;
    END LOOP;

    -- Date period check
    IF lv2_check_period_start IS NOT NULL AND lv2_check_period_end IS NOT NULL THEN -- Add consistent period check
      Ecdp_Dynsql.AddSqlLine(body_lines,'    IF n_'||lv2_check_period_start|| ' > nvl(n_'||lv2_check_period_end||',n_'||lv2_check_period_start||') THEN '||
                                  ' Raise_Application_Error(-20104,'''|| lv2_check_period_end || ' cannot be before '||lv2_check_period_start||': ''||n_'||lv2_check_period_start||'); END IF; ' || CHR(10));
    END IF;

    Ecdp_Dynsql.AddSqlLine(body_lines, '    -- Start Update relation block'||CHR(10));

   IF lb_use_object_id THEN

    Ecdp_Dynsql.AddSqlLine(body_lines,'      IF Updating(''OBJECT_ID'') THEN'|| CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          IF NOT (Nvl(:NEW.object_id,''NULL'') = :OLD.object_id) THEN'|| CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'             Raise_Application_Error(-20101,''Cannot update object_id '');'|| CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          END IF;'|| CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      END IF;'|| CHR(10));

      IF lb_daytime_is_key AND Nvl(lv2_time_scope_code,'X') <> 'NONE' THEN -- Add daytime validation against parent object start date.

        Ecdp_Dynsql.AddSqlLine(body_lines,CHR(10)||'    IF Updating(''DAYTIME'') THEN'||CHR(10)||CHR(10));

        CASE lv2_time_scope_code  -- Add different daytime check based on the time_scope_code

          WHEN 'DAY' THEN
          Ecdp_Dynsql.AddSqlLine(body_lines, '       IF TRUNC(EcDp_Objects.getOBjStartDate(n_object_id)) > n_daytime THEN'||CHR(10));
          WHEN 'MTH' THEN
            Ecdp_Dynsql.AddSqlLine(body_lines, '       IF TRUNC(EcDp_Objects.getOBjStartDate(n_object_id),''mm'') > n_daytime THEN'||CHR(10));
          WHEN 'YR' THEN
            Ecdp_Dynsql.AddSqlLine(body_lines, '       IF EcDp_Objects.getOBjStartDate(n_object_id) - 365 > n_daytime THEN'||CHR(10));
          ELSE
            Ecdp_Dynsql.AddSqlLine(body_lines, '       IF EcDp_Objects.getOBjStartDate(n_object_id) > n_daytime THEN'||CHR(10));

        END CASE;

        Ecdp_Dynsql.AddSqlLine(body_lines, '          RAISE_APPLICATION_ERROR(-20109,''Daytime is less than owner objects start date.'');'||CHR(10));
        Ecdp_Dynsql.AddSqlLine(body_lines, '       END IF;'||CHR(10)||CHR(10));

        Ecdp_Dynsql.AddSqlLine(body_lines, '       IF n_Daytime >= nvl(EcDp_Objects.getObjEndDate(n_object_id),n_Daytime + 1) THEN'||CHR(10));
        Ecdp_Dynsql.AddSqlLine(body_lines, '          Raise_Application_Error(-20109,''Daytime must be less than owner objects end date.'');'||CHR(10));
        Ecdp_Dynsql.AddSqlLine(body_lines, '       END IF;'||CHR(10)||CHR(10));

        Ecdp_Dynsql.AddSqlLine(body_lines,'    END IF;'||CHR(10)||CHR(10));

      END IF;

    END IF;

    FOR ClassesRel7 IN EcDp_ClassMeta.c_classes_rel(p_class_name) LOOP

      IF ClassesRel7.report_only_ind = 'N' THEN

        IF Nvl(lv2_time_scope_code,'X') <> 'NONE' THEN

            CASE lv2_time_scope_code  -- Add different daytime check based on the time_scope_code

            WHEN 'DAY' THEN
            Ecdp_Dynsql.AddSqlLine(body_lines, '    IF TRUNC(EcDp_Objects.getOBjStartDate(n_' || ClassesRel7.role_name || '_id)) > n_daytime THEN'||CHR(10));
            WHEN 'MTH' THEN
              Ecdp_Dynsql.AddSqlLine(body_lines, '    IF TRUNC(EcDp_Objects.getOBjStartDate(n_' || ClassesRel7.role_name || '_id),''mm'') > n_daytime THEN'||CHR(10));
            WHEN 'YR' THEN
              Ecdp_Dynsql.AddSqlLine(body_lines, '    IF EcDp_Objects.getOBjStartDate(n_' || ClassesRel7.role_name || '_id) - 365 > n_daytime THEN'||CHR(10));
            ELSE
              Ecdp_Dynsql.AddSqlLine(body_lines, '    IF EcDp_Objects.getOBjStartDate(n_' || ClassesRel7.role_name || '_id) > n_daytime THEN'||CHR(10));

          END CASE;

        Ecdp_Dynsql.AddSqlLine(body_lines, '       RAISE_APPLICATION_ERROR(-20109,'' Referred '|| ClassesRel7.role_name||' cannot have a start date later than daytime for this object. '');'||CHR(10));
        Ecdp_Dynsql.AddSqlLine(body_lines, '    END IF;'||CHR(10)||CHR(10));

        END IF;

        Ecdp_Dynsql.AddSqlLine(body_lines, '     IF n_'|| ClassesRel7.role_name ||'_ID IS NOT NULL AND EcDp_objects.isValidClassReference('''||ClassesRel7.from_class_name||''',n_'|| ClassesRel7.role_name ||'_ID) =  ''N'' THEN ' ||  chr(10)) ;
        Ecdp_Dynsql.AddSqlLine(body_lines, '        Raise_Application_Error(-20104,''Referenced '||ClassesRel7.role_name||' is not an object of type '||ClassesRel7.from_class_name||' .'' );' ||  chr(10)) ;
        Ecdp_Dynsql.AddSqlLine(body_lines, '     END IF;' ||  chr(10) ||  chr(10)) ;

      END IF;

    END LOOP;

    -- Generate access control block
    FOR curRel IN EcDp_ClassMeta.c_classes_rel(p_class_name) LOOP
        IF curRel.access_control_method='ACL_LOOKUP' AND NVL(curRel.is_key,'N')='N' THEN
          -- Note that we skip the keys. Access control for keys will be done by RLS SELECT predicate on DV view!
           Ecdp_Dynsql.AddSqlLine(body_lines,'   -- Access check for '||curRel.role_name||'.'||CHR(10));
          Ecdp_Dynsql.AddSqlLine(body_lines,'   EcDp_ACL.AssertAccess(n_'||curRel.role_name||'_ID, '''||curRel.from_class_name||''');'||CHR(10));
           Ecdp_Dynsql.AddSqlLine(body_lines,CHR(10));
        END IF;
    END LOOP;

    Ecdp_Dynsql.AddSqlLine(body_lines, '    -- End Update relation block'||CHR(10));

    END IF; --lb_skip_trg_check

   -- OK Build the actual Update statement
   IF lb_approval_enabled THEN
      Ecdp_Dynsql.AddSqlLine(body_lines,'    EcDp_Approval.registerTaskDetail(n_rec_id, '''||p_class_name||''', Nvl(n_last_updated_by, n_created_by));'|| CHR(10));
   END IF;

   Ecdp_Dynsql.AddSqlLine(body_lines,'    UPDATE '||lv2_main_tablename || ' SET '||lv2_update_list||CHR(10)||
                         '    WHERE '||lv2_key_list||';'||  chr(10)||chr(10));

   ----------------------------------------------------------------------------------------------
   -- Update part
   ----------------------------------------------------------------------------------------------

    Ecdp_Dynsql.AddSqlLine(body_lines, '  ELSE -- Deleting '||  chr(10)||  chr(10));

    IF lb_approval_enabled = FALSE THEN
      Ecdp_Dynsql.AddSqlLine(body_lines,'     DELETE FROM '||lv2_main_tablename||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'     WHERE '||lv2_key_list||';'||CHR(10)||CHR(10));
    ELSE
      Ecdp_Dynsql.AddSqlLine(body_lines,'     IF EcDp_Approval.IsAccepting OR o_approval_state=''N'' THEN '||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'         -- We trust DELETEs triggered from EcDp_Approval.Accept, so not need to check source record approval_state.'||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'         -- DELETEs of record with approval_state=''N'' is allowed; the record has never been official.'||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines,'          IF EcDp_Approval.IsAccepting=FALSE THEN EcDp_Approval.deleteTaskDetail(n_rec_id); END IF;'|| CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'         DELETE FROM '||lv2_main_tablename||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'         WHERE '||lv2_key_list||';'||CHR(10)||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'     ELSE'||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'         -- Mark record for deletion.'||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'         EcDp_Approval.registerTaskDetail(n_rec_id, '''||p_class_name||''', Nvl(EcDp_Context.getAppUser,User));'|| CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'         UPDATE '||lv2_main_tablename||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'         SET    rec_id=n_rec_id'||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'         ,      approval_state=''D'''||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'         ,      approval_by=null'||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'         ,      approval_date=null'||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'         ,      rev_no=(rev_no+1)'||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'         ,      last_updated_by=Nvl(EcDp_Context.getAppUser,User)'||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'         WHERE '||lv2_key_list||';'||CHR(10)||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'     END IF;'||CHR(10));
    END IF;

    Ecdp_Dynsql.AddSqlLine(body_lines, '  END IF; -- IF INSERTING  '||  chr(10)||  chr(10));

    IF NOT lb_skip_trg_check THEN

    Ecdp_Dynsql.AddSqlLine(body_lines,' --*************************************************************************************' || chr(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,' -- Start Trigger action block' || chr(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,' -- Any code block defined as a AFTER trigger-type in table CLASS_TRIGGER_ACTION will be put here' || chr(10)|| chr(10));

    FOR ClassAfterAction IN EcDp_ClassMeta.c_class_trigger_action(p_class_name,'AFTER') LOOP

     Ecdp_Dynsql.AddSqlLine(body_lines, ' IF ' || ClassafterAction.triggering_event || ' THEN ' || chr(10)|| chr(10));

     Ecdp_Dynsql.AddSqlLine(body_lines,  ClassafterAction.db_sql_syntax || CHR(10)|| chr(10));

     Ecdp_Dynsql.AddSqlLine(body_lines, ' END IF;' || chr(10)|| chr(10));

    END LOOP;


    Ecdp_Dynsql.AddSqlLine(body_lines,' --' || chr(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,' -- end user exit block Class_trigger_actions after' || chr(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,' --*************************************************************************************' || chr(10)|| chr(10));

    END IF; --lb_skip_trg_check

    Ecdp_Dynsql.AddSqlLine(body_lines, '  END; -- TRIGGER IUD_' || p_class_name||  chr(10));


   Ecdp_Dynsql.SafeBuild('IUD_'||p_class_name,'TRIGGER',body_lines,p_target);

   -- SafeBuild('IUD_'||p_class_name,'TRIGGER',lv2_sql,p_target);


EXCEPTION


     WHEN OTHERS THEN
         EcDp_DynSql.WriteTempText('GENCODEERROR','Syntax error generating trigger for '||p_class_name||CHR(10)||SQLERRM||CHR(10));

END DataClassViewIUTrg;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : BuildView
-- Description    :
--
-- Preconditions  : Class definition in place in CLASS, CLASS_ATTRIBUTE, CLASS_ATTR_DB_MAPPING
--                  CLASS RELATION
--
--
--
--
-- Postcondition  : Views and Triggers created or errors logged to t_temptext
--                  IF p_target='SCRIPT' then code written to t_temptext
--              IF p_build_report_view = true then the corresponded report view is also created.st
--
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
PROCEDURE BuildView(
        p_class_name        VARCHAR2,
        p_target            VARCHAR2 DEFAULT 'CREATE')
IS

  CURSOR c_child_class IS
   SELECT child_class
   FROM class_dependency
   WHERE parent_class =  p_class_name
   AND   dependency_type = 'IMPLEMENTS'
   UNION
   SELECT class_name child_class
   FROM class
   WHERE owner_class_name = p_class_name;

  CURSOR c_err_message IS
    SELECT count(*) count
    FROM t_temptext
    WHERE id = 'GENCODEERROR';


  lb_failed      BOOLEAN DEFAULT FALSE;
  lv2_class_type    class.class_type%TYPE := EcDp_ClassMeta.GetClassType(p_class_name);

BEGIN

  BuildViewLayer(p_target,p_class_name);

  -- Check for errors and print any error messages
  FOR curErr IN c_err_message LOOP
    IF curErr.Count > 0 THEN
      lb_failed := TRUE;
    END IF;
  END LOOP;


  IF NOT lb_failed THEN

    BuildReportLayer(p_target,p_class_name);

    -- Build any related classes
    FOR curChild IN c_child_class LOOP
      BuildReportLayer(p_target,curChild.child_class);
    END LOOP;

  END IF;

END BuildView;

PROCEDURE BuildViewAutonomous(
        p_class_name        VARCHAR2,
        p_target            VARCHAR2 DEFAULT 'CREATE')
IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
       BuildView(p_class_name, p_target);
       Commit;
END BuildViewAutonomous;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : RecompileInvalidViewLayer
-- Description    : Try to recompile invalid objects, to solve dependency
--
-- Preconditions  :
--
--
--
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
---------------------------------------------------------------------------------------------------
PROCEDURE RecompileInvalidViewLayer
--</EC-DOC>

IS


CURSOR c_invalid IS
SELECT uo.object_name, uo.object_type, c.class_type, c.class_name
FROM user_objects uo, class c
WHERE uo.object_type = 'TRIGGER'
and   substr(uo.object_name,1,2) = 'XX'
and   SUBSTR(uo.object_name,7) = c.class_name
AND   c.class_type IN ('OBJECT','INTERFACE','SUB_CLASS','DATA','TABLE')
AND status = 'INVALID'
union all
SELECT uo.object_name, uo.object_type, class_type, c.class_name
FROM user_objects uo, class c
WHERE uo.object_type = 'VIEW'
and   substr(uo.object_name,1,2) = 'XX'
and   SUBSTR(uo.object_name,6) = c.class_name
AND   c.class_type IN ('OBJECT','INTERFACE','SUB_CLASS','DATA','TABLE')
AND status = 'INVALID'
UNION ALL
SELECT uo.object_name, uo.object_type, c.class_type, c.class_name
FROM user_objects uo, class c
WHERE uo.object_type = 'TRIGGER'
AND   SUBSTR(uo.object_name,5) = c.class_name
AND   c.class_type IN ('OBJECT','INTERFACE','SUB_CLASS','DATA','TABLE')
AND status = 'INVALID'
union all
SELECT uo.object_name, uo.object_type, class_type, c.class_name
FROM user_objects uo, class c
WHERE uo.object_type = 'VIEW'
AND   SUBSTR(uo.object_name,4) = c.class_name
AND   c.class_type IN ('OBJECT','INTERFACE','SUB_CLASS','DATA','TABLE')
AND status = 'INVALID'
;
/*
UNION all
SELECT uo.object_name, uo.object_type, NUll as class_type, NULL AS class_name
FROM user_objects uo
WHERE  uo.object_type NOT IN ('VIEW','TRIGGER')
AND status = 'INVALID'
;
*/

lv2_sql         VARCHAR2(4000);
ln_compilecount NUMBER := 0;
ln_oldinvalid   NUMBER := 1000; -- Just start with a high number
ln_invalidcount NUMBER := 0;

BEGIN

   WHILE ln_compilecount < 4 AND ln_invalidcount < ln_oldinvalid LOOP

      ln_oldinvalid := ln_invalidcount; -- To see if it is reducing, if not give up
      ln_invalidcount := 0;
      ln_compilecount := ln_compilecount + 1;

      FOR curInv IN c_invalid LOOP

        ln_invalidcount := ln_invalidcount + 1;

        -- IF this cursor has a value in class_type then it the test before final compile that failed
        -- then use viewlayer function to rebuild, if not simply try to compile

       IF curInv.class_type = 'OBJECT' AND curInv.object_type = 'VIEW' THEN

          ObjectClassView(curInv.class_name, EcDp_Date_Time.getCurrentSysdate,'CREATE');
          ObjectClassJNView(curInv.class_name, EcDp_Date_Time.getCurrentSysdate,'CREATE');
          ObjectClassViewIUTrg(curInv.class_name,EcDp_Date_Time.getCurrentSysdate,'CREATE');

       ELSIF curInv.class_type = 'OBJECT' AND curInv.object_type = 'TRIGGER' THEN

          ObjectClassViewIUTrg(curInv.class_name,EcDp_Date_Time.getCurrentSysdate,'CREATE');

       ELSIF curInv.class_type = 'INTERFACE' AND curInv.object_type = 'VIEW' THEN

          InterfaceClassView(curInv.class_name, EcDp_Date_Time.getCurrentSysdate,'CREATE');
          InterfaceClassViewIUTrg(curInv.class_name, EcDp_Date_Time.getCurrentSysdate,'CREATE');

       ELSIF curInv.class_type = 'INTERFACE' AND curInv.object_type = 'TRIGGER' THEN

          InterfaceClassViewIUTrg(curInv.class_name, EcDp_Date_Time.getCurrentSysdate,'CREATE');


       ELSIF curInv.class_type = 'DATA' AND curInv.object_type = 'VIEW' THEN

           DataClassView(curInv.class_name, EcDp_Date_Time.getCurrentSysdate, 'CREATE');
           DataClassJNView(curInv.class_name, EcDp_Date_Time.getCurrentSysdate, 'CREATE');
           DataClassViewIUTrg(curInv.class_name, EcDp_Date_Time.getCurrentSysdate, 'CREATE');

       ELSIF curInv.class_type = 'DATA' AND curInv.object_type = 'TRIGGER' THEN

           DataClassViewIUTrg(curInv.class_name, EcDp_Date_Time.getCurrentSysdate, 'CREATE');

       ELSIF curInv.class_type = 'TABLE' AND curInv.object_type = 'VIEW' THEN

           TableClassView(curInv.class_name, EcDp_Date_Time.getCurrentSysdate, 'CREATE');
           TableClassJNView(curInv.class_name, EcDp_Date_Time.getCurrentSysdate, 'CREATE');
           TableClassViewIUTrg(curInv.class_name, EcDp_Date_Time.getCurrentSysdate, 'CREATE');

       ELSIF curInv.class_type = 'TABLE' AND curInv.object_type = 'TRIGGER' THEN

           TableClassViewIUTrg(curInv.class_name, EcDp_Date_Time.getCurrentSysdate, 'CREATE');


       ELSE  -- simply try to recompile the invalid object

          IF curInv.object_type IN ('PACKAGE BODY') THEN

             lv2_sql := 'ALTER PACKAGE '||curInv.object_name ||' COMPILE BODY';

          ELSIF    curInv.object_type IN ('PACKAGE', 'VIEW','TRIGGER') THEN

             lv2_sql := 'ALTER '||curInv.object_type ||' '||curInv.object_name ||' COMPILE';

          END IF;

          BEGIN

            IF lv2_sql IS NOT NULL THEN

              EXECUTE IMMEDIATE lv2_sql;

            END IF;

          EXCEPTION
            WHEN OTHERS THEN
              EcDp_DynSql.WriteTempText('RECOMPILE','Syntax error for '||lv2_SQL ||CHR(10)||SQLERRM);

          END;


       END IF;

      END LOOP;  -- Invalid cursor

    END LOOP; -- WHILE;  -- Max Number of recompiles


END RecompileInvalidViewLayer ;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : BuildViewLayer
-- Description    : Build View layer with InsteadOfTrigger based on CLASS definition.
--                  p_app_space code can be used to narrow the classes,
--              p_app_space_code = NONPRODUCT builds all classes with app_space_code not like 'EC_%'
--
-- Preconditions  : Class definition in place in CLASS, CLASS_ATTRIBUTE, CLASS_ATTR_DB_MAPPING
--                  CLASS RELATION
--
--
--
--
-- Postcondition  : Views and Triggers created or errors logged to t_temptext
--                  IF p_target='SCRIPT' then code written to t_temptext
--
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
PROCEDURE BuildViewLayer(
          p_target            VARCHAR2 DEFAULT 'CREATE',
          p_class_name       VARCHAR2 DEFAULT NULL,  -- p_class_name = NULL means all classes
          p_app_space_code   VARCHAR2 DEFAULT NULL,  -- p_app_space_code = NULL means ignore appspace code
          p_ignore_error_ind VARCHAR2 DEFAULT 'N'    -- used in to not raise error in some build cases
           )
--</EC-DOC>

IS

CURSOR c_class IS
SELECT UPPER(LTRIM(RTRIM(class_name))) class_name,
UPPER(LTRIM(RTRIM(class_type))) class_type,
UPPER(LTRIM(RTRIM(create_ev_ind))) create_ev_ind,
DECODE(class_type,'OBJECT',1,'DATA',2,'TABLE',3,'SUB_CLASS',4,'INTERFACE',5,6) sort_order
FROM   class c
WHERE  class_name = Nvl(p_class_name,class_name)
AND ((app_space_code = Nvl(p_app_space_code,app_space_code) AND Nvl(p_app_space_code,'X') <> 'NONPRODUCT')
     OR
     (UPPER(app_space_code) NOT LIKE 'EC\_%' escape '\' AND Nvl(p_app_space_code,'X') = 'NONPRODUCT')
     OR exists (
        select 1 from class_attribute ca
       where c.class_name = ca.class_name
       and (context_code = Nvl(p_app_space_code,context_code) AND Nvl(p_app_space_code,'X') <> 'NONPRODUCT')
       OR  (UPPER(context_code) NOT LIKE 'EC\_%' escape '\' AND Nvl(p_app_space_code,'X') = 'NONPRODUCT'))
    OR exists (
        select 1 from class_relation cr
       where c.class_name = cr.to_class_name
       and (context_code = Nvl(p_app_space_code,context_code) AND Nvl(p_app_space_code,'X') <> 'NONPRODUCT')
       OR  (UPPER(context_code) NOT LIKE 'EC\_%' escape '\' AND Nvl(p_app_space_code,'X') = 'NONPRODUCT'))
      )
ORDER BY sort_order;


CURSOR c_invalid IS
SELECT object_name, object_type
FROM user_objects
WHERE status = 'INVALID';

CURSOR c_obj_class IS
SELECT class_name
FROM class
WHERE class_type = 'OBJECT'
AND ((app_space_code = Nvl(p_app_space_code,app_space_code) AND Nvl(p_app_space_code,'X') <> 'NONPRODUCT')
     OR
     (UPPER(app_space_code) NOT LIKE 'EC\_%' escape '\' AND Nvl(p_app_space_code,'X') = 'NONPRODUCT')) ;

ld_current_sysdate   DATE := EcDp_Date_Time.getCurrentSysdate;

BEGIN


    DELETE FROM T_TEMPTEXT WHERE ID IN ('GENCODE','GENCODEERROR');
    COMMIT;

    IF p_class_name IS NULL OR EcDp_ClassMeta.GetClassType(p_class_name) = 'OBJECT' THEN

      IF p_target = 'CREATE' THEN

        CreateGroupsView;
        CreateObjectsVersionView;
        CreateObjectsView;
        CreateDefermentGroupsView;
        CreateGroupSyncPackage;

      END IF;

      IF p_class_name IS NOT NULL THEN

        ObjectClassTriggerPackageHead(p_class_name,ld_current_sysdate,p_target);
        ObjectClassTriggerPackageBody(p_class_name,ld_current_sysdate,p_target);

      ELSE

        FOR curObj IN c_obj_class LOOP  -- Need to build all headers before bodies
          ObjectClassTriggerPackageHead(curObj.class_name,ld_current_sysdate,p_target);
        END LOOP;


        FOR curObj IN c_obj_class LOOP
          ObjectClassTriggerPackageBody(curObj.class_name,ld_current_sysdate,p_target);
        END LOOP;

      END IF;

    END IF;


    FOR cur_class IN c_class LOOP

       IF cur_class.class_type = 'OBJECT' THEN

          ObjectClassView(cur_class.class_name,ld_current_sysdate,p_target);
          ObjectClassJNView(cur_class.class_name,ld_current_sysdate,p_target);
          ObjectClassViewIUTrg(cur_class.class_name,ld_current_sysdate,p_target);

       ELSIF cur_class.class_type = 'INTERFACE' THEN

          InterfaceClassView(cur_class.class_name,ld_current_sysdate,p_target);
          InterfaceClassViewIUTrg(cur_class.class_name,ld_current_sysdate,p_target);

       ELSIF cur_class.class_type = 'DATA' THEN

           DataClassView(cur_class.class_name,ld_current_sysdate,p_target);
           DataClassJNView(cur_class.class_name,ld_current_sysdate,p_target);
           DataClassViewIUTrg(cur_class.class_name,ld_current_sysdate,p_target);

       ELSIF cur_class.class_type = 'TABLE' THEN

           TableClassView(cur_class.class_name,ld_current_sysdate,p_target);
           TableClassJNView(cur_class.class_name,ld_current_sysdate,p_target);
           TableClassViewIUTrg(cur_class.class_name,ld_current_sysdate,p_target);

      END IF;

      IF cur_class.create_ev_ind = 'Y' THEN
        EventView(cur_class.class_name, ld_current_sysdate,p_target);
      ELSE
        EventView(cur_class.class_name, ld_current_sysdate,'DROP');
      END IF;
   END LOOP;

   -- Try to recompile invalid objects, to solve dependency
   IF p_target = 'CREATE' AND p_class_name IS NULL THEN  -- Only try to fix invalid if we are building the whole view layer

     RecompileInvalidViewLayer;

   END IF;

   -- rebuild navigation model object relations
   EcDp_nav_model_obj_relation.Syncronize(p_ignore_error => p_ignore_error_ind);
   -- Generate EcCp package(s)
   ecdp_vpd.GenPackage(p_class_name);
   -- Refresh RLS policies
   ecdp_vpd.RefreshPolicies(p_class_name);


   IF p_class_name IS NULL THEN

     IF ecdp_4ea_utility.isusing4ea = 'Y'
     OR ec_ctrl_system_attribute.attribute_text(sysdate,'MASTER_DATA_REPORT_ON','<=') = 'Y' THEN

       ecdp_4ea_generate.BuildEC4EA_AllPackageHeader;
       ecdp_4ea_generate.BuildEC4EA_AllPackageBodies;

     END IF;

     ecdp_acl.RefreshAll;

   ELSE

     IF ecdp_4ea_utility.isusing4ea = 'Y'
     OR ec_ctrl_system_attribute.attribute_text(sysdate,'MASTER_DATA_REPORT_ON','<=') = 'Y' THEN

       ecdp_4ea_generate.BuildEC4EA_AllPackageHeader(p_class_name);
       ecdp_4ea_generate.BuildEC4EA_AllPackageBodies(p_class_name);

     END IF;


   END IF;

   -- Build V_approvalrecords and recompile invalid objects.
   ecdp_approval.BuildApprovalRecordView;

END BuildViewLayer;

PROCEDURE BuildViewLayerAutonomous(
          p_target            VARCHAR2 DEFAULT 'CREATE',
          p_class_name       VARCHAR2 DEFAULT NULL,  -- p_class_name = NULL means all classes
          p_app_space_code   VARCHAR2 DEFAULT NULL,  -- p_app_space_code = NULL means ignore appspace code
          p_ignore_error_ind VARCHAR2 DEFAULT 'N'    -- used in to not raise error in some build cases
          )
IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
      BuildViewLayer(p_target, p_class_name, p_app_space_code , p_ignore_error_ind);
      Commit;
END BuildViewLayerAutonomous;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : BuildTableViews
-- Description    : Build View layer with InsteadOfTrigger based on CLASS definition.
--
-- Preconditions  : Class definition in place in CLASS, CLASS_ATTRIBUTE, CLASS_ATTR_DB_MAPPING
--                  CLASS RELATION
--
--
--
--
-- Postcondition  : Views and Triggers created or errors logged to t_temptext
--                  IF p_target='SCRIPT' then code written to t_temptext
--
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
PROCEDURE BuildTableViews(p_target VARCHAR2 DEFAULT 'CREATE')
--</EC-DOC>

IS
CURSOR c_class IS
SELECT class_name, class_type
FROM   class
;


BEGIN
    DELETE FROM T_TEMPTEXT WHERE ID IN ('GENCODE','GENCODEERROR');
    COMMIT;

   FOR cur_class IN c_class LOOP

     IF cur_class.class_type = 'TABLE' THEN

             TableClassView(cur_class.class_name, EcDp_Date_Time.getCurrentSysdate, p_target);
             TableClassJNView(cur_class.class_name, EcDp_Date_Time.getCurrentSysdate, p_target);
             TableClassViewIUTrg(cur_class.class_name, EcDp_Date_Time.getCurrentSysdate, p_target);

     END IF;

   END LOOP;


END BuildTableViews;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : BuildReportLayer
-- Description    : Build report View based on CLASS definition.
--                  p_app_space code can be used to narrow the classes,
--          p_app_space_code = NONPRODUCT builds all classes with app_space_code not like 'EC_%'
--
-- Preconditions  : Class definition in place in CLASS, CLASS_ATTRIBUTE, CLASS_ATTR_DB_MAPPING
--                  CLASS RELATION.
--                  OBJECT and DATA views must have been generated.
--
--
-- Postcondition  : Views created or errors logged to t_temptext
--                  IF p_target='SCRIPT' then code written to t_temptext
--
-- Using Tables   : t_temptext
--
-- Using functions: - ReportClassView
--                  - ReportObjectClassView
--                  - ReportDataClassView
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE BuildReportLayer(p_target VARCHAR2 DEFAULT 'CREATE',
                           p_class_name  VARCHAR2 DEFAULT NULL,     -- p_class_name = NULL means all classes
                           p_app_space_code  VARCHAR2 DEFAULT NULL)  -- p_app_space_code = NULL means ignore appspace code
--</EC-DOC>

IS

   CURSOR c_class IS
    SELECT class_name,
         class_type,
         DECODE(class_type,'OBJECT',1,'SUB_CLASS',2,'TABLE',3,'INTERFACE',4,'DATA',5,'REPORT',7,8) sort_order
    FROM   class c
    WHERE  class_type IN ('REPORT','OBJECT','DATA','TABLE','INTERFACE','SUB_CLASS')
    AND    class_name = Nvl(p_class_name,class_name)
  AND ((app_space_code = Nvl(p_app_space_code,app_space_code) AND Nvl(p_app_space_code,'X') <> 'NONPRODUCT')
     OR
     (UPPER(app_space_code) NOT LIKE 'EC\_%' escape '\' AND Nvl(p_app_space_code,'X') = 'NONPRODUCT')
     OR exists (
      select 1 from class_attribute ca
       where c.class_name = ca.class_name
       and (context_code = Nvl(p_app_space_code,context_code) AND Nvl(p_app_space_code,'X') <> 'NONPRODUCT')
       OR  (UPPER(context_code) NOT LIKE 'EC\_%' escape '\' AND Nvl(p_app_space_code,'X') = 'NONPRODUCT'))
      OR exists (
      select 1 from class_relation cr
       where c.class_name = cr.to_class_name
       and (context_code = Nvl(p_app_space_code,context_code) AND Nvl(p_app_space_code,'X') <> 'NONPRODUCT')
       OR  (UPPER(context_code) NOT LIKE 'EC\_%' escape '\' AND Nvl(p_app_space_code,'X') = 'NONPRODUCT'))
      )
  ORDER BY sort_order;

BEGIN
    DELETE FROM T_TEMPTEXT WHERE ID IN ('GENCODE','GENCODEERROR');
    COMMIT;

   FOR cur_class IN c_class LOOP

     IF cur_class.class_type = 'OBJECT' THEN
         ReportObjectClassView(cur_class.class_name, EcDp_Date_Time.getCurrentSysdate, p_target);
      ELSIF cur_class.class_type = 'INTERFACE' THEN
        ReportInterfaceClassView(cur_class.class_name, EcDp_Date_Time.getCurrentSysdate, p_target);
      ELSIF cur_class.class_type = 'REPORT' THEN
         ReportClassView(cur_class.class_name, EcDp_Date_Time.getCurrentSysdate, p_target);
      ELSIF cur_class.class_type = 'DATA' THEN
         ReportDataClassView(cur_class.class_name, EcDp_Date_Time.getCurrentSysdate, p_target);
      ELSIF cur_class.class_type = 'TABLE' THEN
         ReportTableClassView(cur_class.class_name, EcDp_Date_Time.getCurrentSysdate, p_target);
     END IF;

   END LOOP;

   -- Generate EcCp package(s)
   ecdp_vpd.GenPackage(p_class_name);
   -- Refresh RLS policies
   ecdp_vpd.RefreshPolicies(p_class_name);

END BuildReportLayer;

PROCEDURE BuildReportLayerAutonomous(p_target VARCHAR2 DEFAULT 'CREATE',
                           p_class_name  VARCHAR2 DEFAULT NULL,     -- p_class_name = NULL means all classes
                           p_app_space_code  VARCHAR2 DEFAULT NULL)  -- p_app_space_code = NULL means ignore appspace code
--</EC-DOC>

IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  BuildReportLayer(p_target, p_class_name, p_app_space_code);
  Commit;
END BuildReportLayerAutonomous;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : TableExists
-- Description    :
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
---------------------------------------------------------------------------------------------------
FUNCTION TableExists(
   p_table_name         VARCHAR2,
   p_table_owner        VARCHAR2
)
RETURN BOOLEAN
--</EC-DOC>
IS

   CURSOR c_tableexists(p_tableName VARCHAR2, p_tableOwner  VARCHAR2) IS
   SELECT 1 FROM ALL_TABLES
   WHERE table_name = UPPER(p_tableName)
   AND owner = Nvl(p_tableOwner,user)
   UNION ALL
   SELECT 1 FROM ALL_VIEWS
   WHERE view_name = UPPER(p_tableName)
   AND owner = Nvl(p_tableOwner,USER);

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


   FOR curTable IN c_tableexists(lv2_table_name,p_table_owner) LOOP

        lb_exsists := TRUE;

   END LOOP;

   RETURN lb_exsists;


END TableExists;


---------------------------------------------------------------------------------------------------
-- function       : viewExists
-- Description    :
--
-- Preconditions  :
-- Description    : Ensure that the given view name really exists as a view for the actual owner.
--
--
--
-- Postcondition  :
--
--
-- Using Tables   : All_Views
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
FUNCTION viewExists(
   p_view_name    VARCHAR2,
   p_owner        VARCHAR2
)
RETURN BOOLEAN
--</EC-DOC>
IS

   CURSOR c_view(cp_view_name VARCHAR2, cp_view_owner  VARCHAR2) IS
   SELECT 1 FROM ALL_VIEWS
   WHERE view_name = UPPER(cp_view_name)
   AND owner = Nvl(cp_view_owner,USER);

   lb_exists           BOOLEAN := FALSE;
   lv2_view_name       VARCHAR2(32);
   ln_index             NUMBER := 0;

BEGIN

   -- Remove Schema name from table_name, i.g remove EcKernel from EcKernel.Well
   ln_index := INSTR(p_view_name,'.');

   IF ln_index > 0 THEN
      lv2_view_name := SUBSTR(p_view_name,ln_index + 1);
   ELSE
      lv2_view_name := p_view_name;
   END IF;


   FOR cur_rec IN c_view(lv2_view_name, p_owner) LOOP

        lb_exists := TRUE;

   END LOOP;

   RETURN lb_exists;

END viewExists;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : InterfaceClassViewIUTrg
-- Description    : Generate InsteadOfTrigger for interface views, class definition of type INTERFACE
--
-- Preconditions  : p_class_name must refer to a class of type 'INTERFACE'.
--                  Class_attribute and class_attr_db_mapping must be configured for class.
--
--
--
-- Postcondition  : Trigger generated or error logged in t_temptext.
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
PROCEDURE InterfaceClassViewIUTrg(
   p_class_name  VARCHAR2,
   p_daytime     DATE,
   p_target      VARCHAR2 DEFAULT 'CREATE'
)
--</EC-DOC>
IS
   lv2_upd_statement       VARCHAR2(32000);
   lv2_ins_statement       VARCHAR2(32000);
   lv2_ins_statement_col   VARCHAR2(4000);
   lv2_ins_statement_val   VARCHAR2(4000);
   body_lines              DBMS_SQL.varchar2a;
   lv2_column_value        VARCHAR2(4000);

   CURSOR c_class_intf_attr IS
   SELECT LTRIM(RTRIM(ca.attribute_name)) attribute_name,
          ca.data_type
   FROM class c, class_attribute ca
   WHERE c.class_name  = p_class_name
   AND   c.class_name = ca.class_name
   AND   c.class_type = 'INTERFACE'
   AND   LTRIM(RTRIM(ca.attribute_name)) NOT IN ('OBJECT_ID')
   AND   Nvl(ca.disabled_ind,'N') = 'N';

BEGIN

  -- No trigger will be generated for read only classes or has no implementations
  IF Ecdp_Classmeta.IsReadOnlyClass(p_class_name) = 'Y' OR Ecdp_Classmeta.IsImplementationsDefined(p_class_name) = 'N' THEN

    RETURN;
  END IF;

   lv2_upd_statement := '     IF UPDATING(''CLASS_NAME'') THEN'||CHR(10)||
                        '        Raise_Application_Error(-20101,''Not allowed to update CLASS_NAME!'');'||CHR(10)||
                        '     END IF;'||CHR(10)||CHR(10)||
                        '     IF Updating(''OBJECT_ID'') THEN'|| CHR(10)||
                        '         IF NOT (Nvl(:NEW.object_id,''NULL'') = :OLD.object_id) THEN'|| CHR(10)||
                        '            Raise_Application_Error(-20101,''Not allowed to update object_id '');'|| CHR(10)||
                        '         END IF;'|| CHR(10)||
                        '     END IF;'||CHR(10)||CHR(10)||
                        '     lv2_view_name := EcDp_ClassMeta.GetClassViewName(:New.Class_Name);'||CHR(10)||
                        '     lv2_class_type := EcDp_ClassMeta.GetClassType(:New.Class_Name);'||CHR(10);

   -- Get all normal attributes
   FOR ClassAttr IN c_class_intf_attr LOOP

      -- Add Insert block
      lv2_ins_statement_col :=  lv2_ins_statement_col || ', '|| ClassAttr.attribute_name;
      lv2_ins_statement_val :=  lv2_ins_statement_val || ', :New.'||ClassAttr.attribute_name;

      IF ClassAttr.data_type IN ('NUMBER','INTEGER') THEN

         lv2_column_value := 'anydata.convertnumber(:New.'|| ClassAttr.attribute_name ||')' ;

      ELSIF ClassAttr.data_type = 'DATE' THEN

          lv2_column_value := 'anydata.convertdate(:New.'|| ClassAttr.attribute_name ||')' ;

      ELSE -- STRING

        lv2_column_value := 'anydata.convertvarchar2(:New.'|| ClassAttr.attribute_name ||')' ;

      END IF;

      lv2_upd_statement := lv2_upd_statement ||CHR(10)||
         '    IF UPDATING('''||ClassAttr.attribute_name||''') THEN'||CHR(10)||
         '       EcDp_objects.AddUpdateList(l_update_list, ln_ul_count, '''||ClassAttr.attribute_name||''','''||ClassAttr.data_type ||''','||lv2_column_value||',''''||lv2_view_name||'''');'||CHR(10)||
         '    END IF;'||CHR(10);

      --END IF;

   END LOOP;

   -- Get all relation attributes
   FOR ClassRel IN EcDp_ClassMeta.c_classes_intf_rel(p_class_name) LOOP

       -- Add Insert block
      lv2_ins_statement_col :=  lv2_ins_statement_col || ', '||ClassRel.role_name||'_ID, '||ClassRel.role_name||'_CODE';
      lv2_ins_statement_val :=  lv2_ins_statement_val || ', :New.'||ClassRel.role_name||'_ID, :New.'||ClassRel.role_name||'_CODE';

      lv2_upd_statement := lv2_upd_statement ||CHR(10)||
      '    IF UPDATING('''||ClassRel.role_name||'_ID'') THEN'||CHR(10)||
      '       EcDp_objects.AddUpdateList(l_update_list, ln_ul_count, '''||ClassRel.role_name||'_ID'',''STRING'',anydata.convertvarchar2(:NEW.'||ClassRel.role_name||'_ID),''''||lv2_view_name||'''');'||CHR(10)||
      '    END IF;'||CHR(10)||
      '    IF UPDATING('''||ClassRel.role_name||'_CODE'') THEN'||CHR(10)||
      '       EcDp_objects.AddUpdateList(l_update_list, ln_ul_count, '''||ClassRel.role_name||'_CODE'',''STRING'',anydata.convertvarchar2(:NEW.'||ClassRel.role_name||'_CODE),''''||lv2_view_name||'''');'||CHR(10)||
      '    END IF;'||CHR(10);

   END LOOP;


   lv2_upd_statement := lv2_upd_statement ||CHR(10)||
                     '     IF UPDATING(''RECORD_STATUS'') THEN' ||CHR(10)||
                     '        EcDp_objects.AddUpdateList(l_update_list, ln_ul_count, ''RECORD_STATUS'',''STRING'', anydata.convertvarchar2(:NEW.RECORD_STATUS),''''||lv2_view_name||'''');'||CHR(10)||
                     '     END IF;'||CHR(10)||CHR(10)||
                     '     IF UPDATING(''CREATED_BY'') THEN' ||CHR(10)||
                     '        EcDp_objects.AddUpdateList(l_update_list, ln_ul_count, ''CREATED_BY'',''STRING'', anydata.convertvarchar2(:NEW.CREATED_BY),''''||lv2_view_name||'''');'||CHR(10)||
                     '     END IF;'||CHR(10)||CHR(10)||
                     '     IF UPDATING(''CREATED_DATE'') THEN' ||CHR(10)||
                     '        EcDp_objects.AddUpdateList(l_update_list, ln_ul_count, ''CREATED_DATE'',''DATE'', anydata.convertdate(:NEW.CREATED_DATE),''''||lv2_view_name||'''');'||CHR(10)||
                     '     END IF;'||CHR(10)||CHR(10)||
                     '     IF UPDATING(''LAST_UPDATED_BY'') THEN' ||CHR(10)||
                     '        EcDp_objects.AddUpdateList(l_update_list, ln_ul_count, ''LAST_UPDATED_BY'',''STRING'', anydata.convertvarchar2(:NEW.LAST_UPDATED_BY),''''||lv2_view_name||'''');'||CHR(10)||
                     '     END IF;'||CHR(10)||CHR(10)||
                     '     IF UPDATING(''LAST_UPDATED_DATE'') THEN' ||CHR(10)||
                     '        EcDp_objects.AddUpdateList(l_update_list, ln_ul_count, ''LAST_UPDATED_DATE'',''DATE'', anydata.convertdate(:NEW.LAST_UPDATED_DATE),''''||lv2_view_name||'''');'||CHR(10)||
                     '     END IF;'||CHR(10)||CHR(10)||
                     '     IF UPDATING(''REV_TEXT'') THEN' ||CHR(10)||
                     '        EcDp_objects.AddUpdateList(l_update_list, ln_ul_count, ''REV_TEXT'',''STRING'', anydata.convertvarchar2(:NEW.REV_TEXT),''''||lv2_view_name||'''');'||CHR(10)||
                     '     END IF;'||CHR(10)||CHR(10)||

                     '     IF UPDATING(''APPROVAL_STATE'') THEN' ||CHR(10)||
                     '        EcDp_objects.AddUpdateList(l_update_list, ln_ul_count, ''APPROVAL_STATE'',''STRING'', anydata.convertvarchar2(:NEW.APPROVAL_STATE),''''||lv2_view_name||'''');'||CHR(10)||
                     '     END IF;'||CHR(10)||CHR(10)||
                     '     IF UPDATING(''APPROVAL_BY'') THEN' ||CHR(10)||
                     '        EcDp_objects.AddUpdateList(l_update_list, ln_ul_count, ''APPROVAL_BY'',''STRING'', anydata.convertvarchar2(:NEW.APPROVAL_BY),''''||lv2_view_name||'''');'||CHR(10)||
                     '     END IF;'||CHR(10)||CHR(10)||
                     '     IF UPDATING(''APPROVAL_DATE'') THEN' ||CHR(10)||
                     '        EcDp_objects.AddUpdateList(l_update_list, ln_ul_count, ''APPROVAL_DATE'',''DATE'', anydata.convertvarchar2(:NEW.APPROVAL_DATE),''''||lv2_view_name||'''');'||CHR(10)||
                     '     END IF;'||CHR(10)||CHR(10)||
                     '     IF UPDATING(''REC_ID'') THEN' ||CHR(10)||
                     '        EcDp_objects.AddUpdateList(l_update_list, ln_ul_count, ''REC_ID'',''STRING'', anydata.convertvarchar2(:NEW.REC_ID),''''||lv2_view_name||'''');'||CHR(10)||
                     '     END IF;'||CHR(10)||CHR(10)||


                     '     EcDp_objects.UpdateTables(''''||:New.Class_Name|| '''',''''||lv2_class_type||'''',''''||lv2_view_name||'''', '||CHR(10)||
                     '           l_update_list, '||CHR(10)||
                     '           lv2_object_id, '||CHR(10)||
                     '           :old.daytime);  '||CHR(10)||CHR(10);

   lv2_ins_statement_col := lv2_ins_statement_col ||
                            ',RECORD_STATUS,CREATED_BY,CREATED_DATE,LAST_UPDATED_BY,LAST_UPDATED_DATE,REV_TEXT,APPROVAL_STATE,APPROVAL_BY,APPROVAL_DATE,REC_ID';
   lv2_ins_statement_val := lv2_ins_statement_val ||
                            ',:New.RECORD_STATUS,:New.CREATED_BY,:New.CREATED_DATE,:New.LAST_UPDATED_BY,:New.LAST_UPDATED_DATE,:New.REV_TEXT,:New.APPROVAL_STATE,:New.APPROVAL_BY,:New.APPROVAL_DATE,:New.REC_ID';



  Ecdp_Dynsql.AddSqlLine(body_lines,'CREATE OR REPLACE TRIGGER IUD_'||p_class_name||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'INSTEAD OF INSERT OR UPDATE OR DELETE ON IV_'||p_class_name||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'FOR EACH ROW'||CHR(10)||GeneratedCodeMsg);
  Ecdp_Dynsql.AddSqlLine(body_lines,'DECLARE'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'  lv2_view_name        VARCHAR2(32);'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'  l_update_list        ecdp_objects.update_list;'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'  ln_ul_count          NUMBER := 0;'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'  lv2_class_type       class.class_type%TYPE;'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'  lv2_object_id        VARCHAR2(40);'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'BEGIN'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'  IF INSERTING THEN'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'     lv2_object_id := :New.Object_id;'||CHR(10)||CHR(10));
  -- Build insert statement for all classes that implement this interface
  FOR curClass IN EcDp_ClassMeta.c_classes_interface(p_class_name) LOOP
      Ecdp_Dynsql.AddSqlLine(body_lines, CHR(10) ||
      '      IF :New.Class_Name = '''||curClass.child_class ||''' THEN'||CHR(10)||
      '         INSERT INTO '||EcDp_ClassMeta.GetClassViewName(curClass.child_class)||'(CLASS_NAME, OBJECT_ID'||lv2_ins_statement_col||')'||CHR(10)||
      '         VALUES('''||curClass.child_class||''', lv2_object_id'||lv2_ins_statement_val||');'||CHR(10)||
      '      END IF;'||CHR(10));
  END LOOP;
  Ecdp_Dynsql.AddSqlLine(body_lines,'  ELSIF UPDATING THEN'||CHR(10)||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'     lv2_object_id := :New.Object_id;'||CHR(10)||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,lv2_upd_statement);
  Ecdp_Dynsql.AddSqlLine(body_lines,'  ELSE'||CHR(10)||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'     Raise_Application_Error(-20102,''Object delete is not allowed, set object end date.'');'||CHR(10)||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'  END IF;'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'END;'||CHR(10));


   Ecdp_Dynsql.SafeBuild('ECTP_'||p_class_name,'PACKAGE BODY',body_lines,p_target);

END InterfaceClassViewIUTrg;




--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : ReportClassView
-- Description    : Generate report views, class definition of type REPORT
--
-- Preconditions  : p_class_name must refer to a class of type 'REPORT'.
--                  Class_attribute and class_attr_db_mapping must be configured for class.
--                  Data classes to "report on" must have been defined in CLASS_DEPENDENCY.
--              The data classes and the report class must be owned by the same OBJECT-class.
--              The report view for data classes must have been created.
--
--
-- Postcondition  : View generated or error logged in t_temptext.
--                  IF p_target = 'SCRIPT' code generated to t_temptext
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
PROCEDURE ReportClassView(
   p_class_name   VARCHAR2,
   p_daytime      DATE,
   p_target VARCHAR2 DEFAULT 'CREATE'
)
--</EC-DOC>
IS

   -- Get data classes to report on
   CURSOR c_data_classes IS
    SELECT cd.parent_class report_class_name, cd.child_class data_class_name
    FROM class_dependency cd
    WHERE cd.parent_class = p_class_name
    AND   cd.dependency_type = 'REPORT_MEMBER'
    AND   EXISTS(  -- Ensure that parent_class and child_class have equal owner,
                   -- and that parent_class is a REPORT-class and child_class is a DATA-class.
               SELECT 1
               FROM class report, class data
               WHERE report.class_name = cd.parent_class
               AND   data.class_name = cd.child_class
               AND   data.class_type = 'DATA'
               AND   report.class_type = 'REPORT'
               AND   report.owner_class_name = data.owner_class_name
              );

   CURSOR c_reportclass(cp_class_name  VARCHAR2) IS
     SELECT *
     FROM class
     WHERE class_name = cp_class_name
      AND  class_type = 'REPORT';

   CURSOR c_view_columns(cp_view_name  VARCHAR2) IS
     SELECT UPPER(column_name) column_name
     FROM user_tab_cols
     WHERE table_name = cp_view_name
     AND   column_name NOT IN ('REV_NO','REV_TEXT','RECORD_STATUS','CREATED_BY','CREATED_DATE','LAST_UPDATED_BY','LAST_UPDATED_DATE','APPROVAL_STATE','APPROVAL_BY','APPROVAL_DATE','REC_ID')
    ORDER BY column_id;

   missing_owner                 EXCEPTION;
   invalid_time_scope_code       EXCEPTION;

   TYPE t_column_list IS TABLE OF VARCHAR2(32)
     INDEX BY BINARY_INTEGER;

   lv2_sql                    VARCHAR2(32000);
   l_column_list            t_column_list;
   ln_list_count            NUMBER := 0;
   lv2_owner_class               class.owner_class_name%TYPE;
   lv2_report_tsc                class.time_scope_code%TYPE;
   lb_found                BOOLEAN := FALSE;

BEGIN

   -- Get report class info
   FOR curReportClass IN c_reportclass(p_class_name) LOOP
      lv2_owner_class := curReportClass.Owner_Class_Name;
      lv2_report_tsc :=  curReportClass.time_scope_code;
   END LOOP;

   -- Raise error if lv2_owner_class is null or lv2_report_tsc is null
   IF lv2_owner_class IS NULL THEN
      RAISE missing_owner;
   END IF;

   IF lv2_report_tsc IS NULL THEN
      RAISE invalid_time_scope_code;
   END IF;

   -- Get all view columns
   FOR curDataClass IN c_data_classes LOOP

     FOR curColumn IN c_view_columns('RV_'||curDataClass.data_class_name) LOOP

       FOR colCounter IN 1..l_column_list.COUNT LOOP -- Only include column if it not already included

         IF l_column_list(colCounter) = curColumn.column_name THEN
           lb_found := TRUE;
           EXIT;
         END IF;

       END LOOP;

       IF NOT lb_found THEN
         ln_list_count := ln_list_count + 1;
         l_column_list(ln_list_count) := curColumn.column_name;
       END IF;

       lb_found := FALSE;

     END LOOP;

   END LOOP;

   --------------------------
   -- Start building the view
   --------------------------
   lv2_sql :=       'CREATE OR REPLACE VIEW RV_'||p_class_name||CHR(10);
   lv2_sql := lv2_sql||'(CLASS_NAME';

   FOR colCounter IN 1..l_column_list.COUNT LOOP
      lv2_sql := lv2_sql||','||l_column_list(colCounter);
   END LOOP;

   lv2_sql := lv2_sql||',RECORD_STATUS,CREATED_BY,CREATED_DATE,LAST_UPDATED_BY,LAST_UPDATED_DATE,REV_NO,REV_TEXT,APPROVAL_STATE,APPROVAL_BY,APPROVAL_DATE,REC_ID) AS '||CHR(10);
   lv2_sql := lv2_sql||'('||CHR(10)||GeneratedCodeMsg;

   FOR curDataClass IN c_data_classes LOOP

     lv2_sql := lv2_sql||'SELECT'||CHR(10);
     lv2_sql := lv2_sql||''''||p_class_name||''','||CHR(10);

     FOR colCounter IN 1..l_column_list.COUNT LOOP

       IF EcDp_ClassMeta.IsValidTabCol('RV_'||curDataClass.data_class_name,l_column_list(colCounter)) THEN
         lv2_sql := lv2_sql||' '||l_column_list(colCounter)||','||CHR(10);
       ELSE
         lv2_sql := lv2_sql||' NULL,'||CHR(10);
       END IF;

     END LOOP;

     lv2_sql := lv2_sql||' RECORD_STATUS,'||CHR(10);
     lv2_sql := lv2_sql||' CREATED_BY,'||CHR(10);
     lv2_sql := lv2_sql||' CREATED_DATE,'||CHR(10);
     lv2_sql := lv2_sql||' LAST_UPDATED_BY,'||CHR(10);
     lv2_sql := lv2_sql||' LAST_UPDATED_DATE,'||CHR(10);
     lv2_sql := lv2_sql||' REV_NO,'||CHR(10);
     lv2_sql := lv2_sql||' REV_TEXT,'||CHR(10);
    lv2_sql := lv2_sql||' APPROVAL_STATE,'||CHR(10);
     lv2_sql := lv2_sql||' APPROVAL_BY,'||CHR(10);
     lv2_sql := lv2_sql||' APPROVAL_DATE,'||CHR(10);
     lv2_sql := lv2_sql||' REC_ID'||CHR(10);
     lv2_sql := lv2_sql||'FROM RV_'||curDataClass.data_class_name||CHR(10);
     lv2_sql := lv2_sql||'UNION ALL'||CHR(10);

   END LOOP;

   lv2_sql := SUBSTR(lv2_sql,1,LENGTH(lv2_sql) - 10); -- Remove last 'UNION ALL'

   lv2_sql := lv2_sql||')'||CHR(10);

   SafeBuild('RV_'||p_class_name,'VIEW',lv2_sql,p_target);

EXCEPTION
   WHEN missing_owner THEN
       EcDp_DynSql.WriteTempText('GENCODEERROR','Syntax error generating view for '||p_class_name||CHR(10)||
                     'Owner class missing for '||p_class_name);
   WHEN invalid_time_scope_code THEN
       EcDp_DynSql.WriteTempText('GENCODEERROR','Syntax error generating view for '||p_class_name||CHR(10)||
                     'Invalid time scope code for one or more classes!');
   WHEN OTHERS THEN
      EcDp_DynSql.WriteTempText('GENCODEERROR','Syntax error generating view for '||p_class_name||CHR(10)||SQLERRM||CHR(10)||
                    lv2_sql);

END ReportClassView;

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
           cadm.db_mapping_type,
           cadm.db_sql_syntax,
           cp.uom_code,
           cadm.sort_order
    FROM class_attribute ca, class_attribute ca2,
         class_attr_db_mapping cadm, class_attr_presentation cp
    WHERE ca2.class_name = Nvl(cp_interface,ca.class_name)
    AND   ca2.attribute_name = ca.attribute_name
    AND   ca.class_name = cadm.class_name
    AND   ca.attribute_name = cadm.attribute_name
    AND   ca.class_name = cp.class_name(+)
    AND   ca.attribute_name = cp.attribute_name(+)
    AND   Nvl(ca.disabled_ind,'N') = 'N'
    AND   ca.class_name = cp_class_name
    AND   ca.attribute_name NOT IN('CLASS_NAME','OBJECT_ID','CODE','NAME','OBJECT_START_DATE','OBJECT_END_DATE','DAYTIME','END_DATE')
    ORDER BY cadm.sort_order;

   CURSOR c_attr_unit(cp_class_name VARCHAR2, cp_attribute_name VARCHAR2) IS
    SELECT cp.class_name,
          cp.attribute_name,
          u.db_unit_ind,
          u.unit,
          u.measurement_type
    FROM class_attr_presentation cp, ctrl_uom_setup u
    WHERE cp.uom_code = u.measurement_type
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
    FROM dao_meta d1, dao_meta d2
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
          crdm.db_mapping_type,
          crdm.db_sql_syntax,
          'N' is_group,
          crdm.sort_order
    FROM class_relation cr,
          class_rel_db_mapping crdm
    WHERE cr.from_class_name = crdm.from_class_name
    AND   cr.to_class_name = crdm.to_class_name
    AND   cr.role_name = crdm.role_name
    AND   cr.to_class_name = p_class_name
    AND   Nvl(cr.disabled_ind,'N') = 'N'
    AND   cr.group_type IS NULL
    AND EXISTS ( SELECT 1 FROM class_relation cr2
                 WHERE cr2.to_class_name = Nvl(p_owner_interface,cr.to_class_name)
                 AND   cr2.from_class_name = cr.from_class_name
                 AND   cr2.role_name = cr.role_name
                 UNION ALL
                 SELECT 1 FROM class_attribute ca2
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
     AddUniqueViewColumns(lv2_sql_lines,' ,s.daytime AS '||'PRODUCTION_DAY');
     AddUniqueViewColumns(lv2_sql_lines,' ,oa.daytime AS DAYTIME');
     AddUniqueViewColumns(lv2_sql_lines,' ,oa.end_date AS END_DATE');
   END IF;

  -- Add non relation attributes, but must limit if comming from INTERFACE
  FOR curAttr IN c_class_attr(p_class_name,p_owner_interface) LOOP

    IF curAttr.db_mapping_type = 'COLUMN' THEN

      lv2_col := 'o.'||LOWER(curAttr.db_sql_syntax);

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
        IF EcDp_ClassMeta.GetClassType(curRel.rel_class_name) = 'INTERFACE' THEN

          AddUniqueViewColumns(lv2_sql_lines,',EcDp_Objects.GetObjCode(o.'||curRel.db_sql_syntax||') AS '||curRel.role_name||'_CODE');

        ELSE -- Better performance in using ec-package

          AddUniqueViewColumns(lv2_sql_lines,','||EcDp_ClassMeta.GetEcPackage(curRel.rel_class_name)||'.object_code(o.'||curRel.db_sql_syntax||') AS '||curRel.role_name||'_CODE');

        END IF;

      END IF;

    ELSIF curRel.db_mapping_type = 'ATTRIBUTE' THEN

      AddUniqueViewColumns(lv2_sql_lines,' ,oa.'||LOWER(curRel.db_sql_syntax)||' AS '||curRel.attribute_name);

      IF curRel.is_group = 'N' THEN -- add relation code

        -- Use EcDp_Objects.GetObjCode if rel_class_name is interface
        IF EcDp_ClassMeta.GetClassType(curRel.rel_class_name) = 'INTERFACE' THEN

          AddUniqueViewColumns(lv2_sql_lines,' ,EcDp_Objects.GetObjCode(oa.'||curRel.db_sql_syntax||') AS '||curRel.role_name||'_CODE');

        ELSE -- Better performance in using ec-package

          AddUniqueViewColumns(lv2_sql_lines,' ,'||EcDp_ClassMeta.GetEcPackage(curRel.rel_class_name)||'.object_code(oa.'||curRel.db_sql_syntax||') AS '||curRel.role_name||'_CODE');

        END IF;

      END IF;
    ELSIF curRel.db_mapping_type = 'FUNCTION' THEN

      AddUniqueViewColumns(lv2_sql_lines,','||LOWER(curRel.db_sql_syntax)||' AS '||curRel.attribute_name);

      IF curRel.is_group = 'N' THEN -- add relation code

        -- Use EcDp_Objects.GetObjCode if rel_class_name is interface
        IF EcDp_ClassMeta.GetClassType(curRel.rel_class_name) = 'INTERFACE' THEN

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
   p_class_name   VARCHAR2,
   p_daytime      DATE,
   p_target VARCHAR2 DEFAULT 'CREATE'
)
--</EC-DOC>
IS


   lv2_sql_lines          DBMS_SQL.varchar2a;
   lv2_col                 VARCHAR2(10000);
   lv2_attr_unit           VARCHAR2(100);
   lv2_main_table           class_db_mapping.db_object_name%TYPE;
  lv2_version_table         class_db_mapping.db_object_attribute%TYPE;
  lv2_main_table_where     class_db_mapping.db_where_condition%TYPE;
  lv2_schema_owner         class_db_mapping.db_object_owner%TYPE;
BEGIN


  FOR curClass IN EcDp_ClassMeta.c_classes(p_class_name) LOOP

    lv2_main_table := curClass.db_object_name;
    lv2_version_table := curClass.db_object_attribute;
    lv2_main_table_where := curClass.db_where_condition;
    lv2_schema_owner := curClass.db_object_owner;

  END LOOP;


   AddUniqueViewColumns(lv2_sql_lines,'CREATE OR REPLACE VIEW RV_'||p_class_name||' AS');
   AddUniqueViewColumns(lv2_sql_lines,' SELECT');
   AddUniqueViewColumns(lv2_sql_lines, GeneratedCodeMsg2);
   AddUniqueViewColumns(lv2_sql_lines,''''||p_class_name||''' AS CLASS_NAME');

   createReportOCColumnList(lv2_sql_lines,p_class_name ,'OBJECT');

   -- Add standard record information columns
  AddUniqueViewColumns(lv2_sql_lines,',oa.record_status AS RECORD_STATUS');
  AddUniqueViewColumns(lv2_sql_lines,',oa.created_by AS CREATED_BY');
  AddUniqueViewColumns(lv2_sql_lines,',oa.created_date AS CREATED_DATE');
  AddUniqueViewColumns(lv2_sql_lines,',decode(sign(nvl(o.last_updated_date,o.created_date)-nvl(oa.last_updated_date,oa.created_date)),1,o.last_updated_by,oa.last_updated_by) AS LAST_UPDATED_BY');
  AddUniqueViewColumns(lv2_sql_lines,',decode(sign(nvl(o.last_updated_date,o.created_date)-nvl(oa.last_updated_date,oa.created_date)),1,o.last_updated_date,oa.last_updated_date) AS LAST_UPDATED_DATE');
  AddUniqueViewColumns(lv2_sql_lines,',o.rev_no||''.''||oa.rev_no AS REV_NO');
  AddUniqueViewColumns(lv2_sql_lines,',decode(sign(nvl(o.last_updated_date,o.created_date)-nvl(oa.last_updated_date,oa.created_date)),1,o.rev_text,oa.rev_text) AS REV_TEXT');

  AddUniqueViewColumns(lv2_sql_lines,','||AddSafeViewColumn(lv2_version_table,'approval_state',lv2_schema_owner,'oa.'));
  AddUniqueViewColumns(lv2_sql_lines,','||AddSafeViewColumn(lv2_version_table,'approval_by',lv2_schema_owner,'oa.'));
  AddUniqueViewColumns(lv2_sql_lines,','||AddSafeViewColumn(lv2_version_table,'approval_date',lv2_schema_owner,'oa.'));
  AddUniqueViewColumns(lv2_sql_lines,','||AddSafeViewColumn(lv2_version_table,'rec_id',lv2_schema_owner,'oa.'));

  AddUniqueViewColumns(lv2_sql_lines,'FROM '||lv2_version_table||' oa, '||lv2_main_table||' o, system_days s');
  AddUniqueViewColumns(lv2_sql_lines,'WHERE oa.object_id = o.object_id');
  AddUniqueViewColumns(lv2_sql_lines,'  AND s.daytime >= oa.daytime');
  AddUniqueViewColumns(lv2_sql_lines,'  AND (s.daytime < oa.end_date OR oa.end_date IS NULL)');
  AddUniqueViewColumns(lv2_sql_lines,'  AND (s.daytime < o.end_date OR o.end_date IS NULL)');

  IF lv2_main_table_where IS NOT NULL THEN

    AddUniqueViewColumns(lv2_sql_lines,'AND '||lv2_main_table_where);

  END IF;


   EcDp_Dynsql.SafeBuild('RV_'||p_class_name,'VIEW',lv2_sql_lines,p_target,p_lfflg => 'Y');




EXCEPTION

   WHEN OTHERS THEN
      EcDp_DynSql.WriteTempText('GENCODEERROR','Syntax error generating view for '||p_class_name||CHR(10)||SQLERRM||CHR(10));

END ReportObjectClassView;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : ReportDataClassView
-- Description    : Generate report views, class definition of type DATA
--                  The report view consists of data-view joined with system_days and joined with owner report view.
--
-- Preconditions  : p_class_name must refer to a class of type 'DATA'.
--              RV-owner view must have been created.
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
PROCEDURE ReportDataClassView(
   p_class_name       VARCHAR2,
   p_daytime          DATE,
   p_target           VARCHAR2 DEFAULT 'CREATE'
)
--</EC-DOC>
IS

   lv2_table_name          class_db_mapping.db_object_name%TYPE;
   lv2_owner_class         class.owner_class_name%TYPE;
   lv2_report_tsc         class.time_scope_code%TYPE;
   lv2_timescope_code     class.time_scope_code%TYPE;
   lv2_db_where_cond       class_db_mapping.db_where_condition%TYPE;
   lv2_cls_owner_cond     class_db_mapping.db_where_condition%TYPE;
   lv2_schema_owner       class_db_mapping.db_object_owner%TYPE;

--   lb_daytime_exsist      BOOLEAN;
--   lb_prod_day_exsist      BOOLEAN;
   lv2_main_table         VARCHAR2(30);
   lv2_version_table      VARCHAR2(30);
--   lb_end_date_exists     BOOLEAN;
   ln_owner_count         NUMBER := 0;
   lv2_sql_lines          DBMS_SQL.varchar2a;
   lv2_prod_day           VARCHAR2(1000);
   lv2_join_daytime       VARCHAR2(1000);  -- This should be the string with the date to use in join with owner class
   lv2_UOM_daytime        VARCHAR2(1000);  -- This should be the string with the date to use in UOM convertion
   lv2_join_system_days   VARCHAR2(1000);

   CURSOR c_class IS
   SELECT c.owner_class_name,c.time_scope_code,cm.db_object_name,cm.db_where_condition,c.approval_ind,cm.db_object_owner
   FROM class c, class_db_mapping cm
   WHERE c.class_name = cm.class_name
   AND c.class_name = p_class_name;


   CURSOR c_ownerloop(cp_owner_class  VARCHAR2) IS  -- to be able to loop if owner is INTERFACE
   SELECT child_class owner_class
   FROM   class_dependency cd, class c
   WHERE cd.parent_class = c.class_name
   AND   cd.dependency_type = 'IMPLEMENTS'
   AND   c.class_type = 'INTERFACE'
   AND   c.class_name = cp_owner_class
   UNION ALL
   SELECT class_name owner_class
   FROM   class c
   WHERE c.class_type = 'OBJECT'
   AND   c.class_name = cp_owner_class
   ;

BEGIN

   FOR curClass IN c_class LOOP
      lv2_owner_class := curClass.owner_class_name;
      lv2_report_tsc := curClass.time_scope_code;
      lv2_timescope_code := curClass.time_scope_code;
      lv2_table_name := LOWER(curClass.db_object_name);
      lv2_db_where_cond := curClass.db_where_condition;
      lv2_schema_owner := curClass.Db_Object_Owner;
   END LOOP;

   --  Use "DAY" for all time_scope_code less than day or NULL.
   IF lv2_report_tsc IS NULL THEN
      lv2_report_tsc := 'DAY';
   ELSIF lv2_report_tsc NOT IN ('MTH','WEEK','YR') THEN
       lv2_report_tsc := 'DAY';
   END IF;

   -- Find what date column to use for production day, join with owner class and unit convertion
   -- A) Join with parent class, one of the following table columns for the data class table will be choosen:
   --    See rule in behaviour for getDataclassJoinDaytime
   --
   -- B) Unit convertion
   --      The first 4 as for join with parent class
   --      5) Use EcDp_Date_Time.getCurrentSysdate if all else fails
   --
   -- C) production_day,
   --    Ideally this should be defined as a class attribute, will try to use that approach
   --    if it proves to many cases with changed view interfaces, we might have to add a fallback
   --    rule in the view generator for this

   lv2_join_daytime := getDataclassJoinDaytime(p_class_name);
   lv2_prod_day := getDataclassProductionDay(p_class_name);
   lv2_UOM_daytime  := Nvl(lv2_join_daytime,'Trunc(EcDp_Date_Time.getCurrentSysdate)');


   ln_owner_count := 0;

   IF lv2_join_daytime IS NOT NULL THEN  -- Try to join with owner class, if not this would give a cartesian product, so don't do it

     FOR curOwner IN c_ownerloop(lv2_owner_class) LOOP

         --------------------------
         -- Start building the view
         --------------------------

         ln_owner_count := ln_owner_count + 1;

         IF ln_owner_count = 1 THEN
           AddUniqueViewColumns(lv2_sql_lines ,'CREATE OR REPLACE VIEW RV_'||p_class_name||' AS');
           AddUniqueViewColumns(lv2_sql_lines ,' SELECT');
           AddUniqueViewColumns(lv2_sql_lines ,GeneratedCodeMsg2);
           AddUniqueViewColumns(lv2_sql_lines ,' '''||p_class_name||''' AS DATA_CLASS_NAME');

         ELSE
           AddUniqueViewColumns(lv2_sql_lines ,' UNION ALL');
           AddUniqueViewColumns(lv2_sql_lines ,' SELECT');
           AddUniqueViewColumns(lv2_sql_lines ,' '''||p_class_name||''' AS DATA_CLASS_NAME');
         END IF;


         AddUniqueViewColumns(lv2_sql_lines ,' ,'''||curOwner.owner_class||''' AS OWNER_CLASS_NAME');
         -- For backward compability add production day column

        lv2_join_system_days := getDataclassSystemDayJoin(p_class_name);

        IF lv2_join_system_days IS NOT NULL THEN

           AddUniqueViewColumns(lv2_sql_lines ,' ,s.daytime AS PRODUCTION_'||UPPER(lv2_report_tsc));


        ELSIF lv2_prod_day IS NOT NULL THEN

           AddUniqueViewColumns(lv2_sql_lines ,' ,'||lv2_prod_day||' AS PRODUCTION_'||UPPER(lv2_report_tsc));

         END IF;

         -- Get owner object class columns
         createReportOCColumnList(lv2_sql_lines, curOwner.owner_class ,'DATA',lv2_owner_class);

         -- Get dataclass columns

         createReportDCColumnList(lv2_sql_lines, p_class_name , lv2_table_name, lv2_schema_owner, lv2_uom_daytime);


        -- Join with owners main and version table, if we are here this join should always occure

        FOR curOwnerClass IN EcDp_ClassMeta.c_classes(curOwner.owner_class) LOOP
            lv2_main_table := curOwnerClass.db_object_name;
            lv2_version_table := curOwnerClass.db_object_attribute;
         END LOOP;

        IF lv2_join_system_days IS NULL THEN

           AddUniqueViewColumns(lv2_sql_lines ,'FROM '||lv2_version_table||' oa, '||lv2_main_table||' o, '||lv2_table_name);

        ELSE

           AddUniqueViewColumns(lv2_sql_lines ,'FROM '||lv2_version_table||' oa, '||lv2_main_table||' o, system_days s, '||lv2_table_name);

        END IF;


        AddUniqueViewColumns(lv2_sql_lines ,'WHERE oa.object_id = '||lv2_table_name||'.object_id');
        AddUniqueViewColumns(lv2_sql_lines ,'AND '||lv2_table_name||'.object_id =   o.object_id');

        IF lv2_join_system_days IS NOT NULL THEN

          AddUniqueViewColumns(lv2_sql_lines ,'AND '||lv2_join_system_days);

        END IF;


        IF lv2_report_tsc = 'MTH' THEN

          AddUniqueViewColumns(lv2_sql_lines ,'AND '||lv2_table_name||'.daytime >= TRUNC(oa.daytime,''MONTH'')');
          AddUniqueViewColumns(lv2_sql_lines ,'AND oa.daytime = (');
          AddUniqueViewColumns(lv2_sql_lines ,'   SELECT MIN(daytime) FROM '||lv2_version_table||' oa2');
          AddUniqueViewColumns(lv2_sql_lines ,'   WHERE oa2.object_id = oa.object_id');
          AddUniqueViewColumns(lv2_sql_lines ,'   AND   '||lv2_join_daytime||' >= trunc(oa2.daytime,''MONTH'')');
          AddUniqueViewColumns(lv2_sql_lines ,'AND '||lv2_join_daytime||' < nvl(oa2.end_date,'||lv2_join_daytime||' + 1))');

        ELSIF lv2_report_tsc = 'YR' THEN

          AddUniqueViewColumns(lv2_sql_lines ,'AND '||lv2_table_name||'.daytime >= TRUNC(oa.daytime,''YEAR'')');
          AddUniqueViewColumns(lv2_sql_lines ,'AND oa.daytime = (');
          AddUniqueViewColumns(lv2_sql_lines ,'   SELECT MIN(daytime) FROM '||lv2_version_table||' oa2');
          AddUniqueViewColumns(lv2_sql_lines ,'   WHERE oa2.object_id = oa.object_id');
          AddUniqueViewColumns(lv2_sql_lines ,'   AND   '||lv2_join_daytime||' >= trunc(oa2.daytime,''YEAR'')');
          AddUniqueViewColumns(lv2_sql_lines ,'AND '||lv2_join_daytime||' < nvl(oa2.end_date,'||lv2_join_daytime||' + 1))');

        ELSE -- IF lv2_timescope_code IN ('DAY','1HR') THEN

          AddUniqueViewColumns(lv2_sql_lines ,'AND '||lv2_join_daytime||' >= oa.daytime');
          AddUniqueViewColumns(lv2_sql_lines ,'AND '||lv2_join_daytime||' < nvl(oa.end_date,'||lv2_join_daytime||' + 1)');

       END IF;

       IF lv2_db_where_cond IS NOT NULL THEN

             AddUniqueViewColumns(lv2_sql_lines ,'AND '||lv2_db_where_cond);

       END IF;

       -- add where from owner also if any
       -- note there might be where on both object class and interface so must check for both

       lv2_cls_owner_cond := ecdp_classmeta.getclasswherecondition(curowner.owner_class);
       IF lv2_cls_owner_cond IS NOT NULL THEN

             AddUniqueViewColumns(lv2_sql_lines ,'AND '||lv2_cls_owner_cond);

       END IF;

       IF curowner.owner_class <> lv2_owner_class THEN  -- This is an interface

         lv2_cls_owner_cond := ecdp_classmeta.getclasswherecondition(lv2_owner_class);
         IF lv2_cls_owner_cond IS NOT NULL THEN

               AddUniqueViewColumns(lv2_sql_lines ,'AND '||lv2_cls_owner_cond);

         END IF;

       END IF;


     END LOOP; --owner loop

   END IF; --  lv2_join_daytime IS NOT NULL

   IF ln_owner_count = 0 THEN  -- Data class have no owner or lv2_join_daytime IS NULL

       --------------------------
       -- Start building the view
       --------------------------

       AddUniqueViewColumns(lv2_sql_lines ,'CREATE OR REPLACE VIEW RV_'||p_class_name||' AS');
       AddUniqueViewColumns(lv2_sql_lines ,' SELECT');
       AddUniqueViewColumns(lv2_sql_lines ,GeneratedCodeMsg2);
       AddUniqueViewColumns(lv2_sql_lines ,' '''||p_class_name||''' AS DATA_CLASS_NAME');

       AddUniqueViewColumns(lv2_sql_lines ,' ,'''||Nvl(lv2_owner_class,'NULL')||''' AS OWNER_CLASS_NAME');

--       AddUniqueViewColumns(lv2_sql_lines ,' ,NULL AS OWNER_CLASS_NAME');
       -- Get dataclass columns
       createReportDCColumnList(lv2_sql_lines, p_class_name , lv2_table_name, lv2_schema_owner, lv2_UOM_daytime);

       AddUniqueViewColumns(lv2_sql_lines ,'FROM '||lv2_table_name);

       lv2_join_system_days := getDataclassSystemDayJoin(p_class_name);

       IF lv2_join_system_days IS NOT NULL THEN

          AddUniqueViewColumns(lv2_sql_lines ,', system_days s');
          AddUniqueViewColumns(lv2_sql_lines ,'WHERE '||lv2_join_system_days);

       END IF;


       IF lv2_db_where_cond IS NOT NULL THEN

         IF lv2_join_system_days IS NOT NULL THEN

             AddUniqueViewColumns(lv2_sql_lines ,'AND '||lv2_db_where_cond);

         ELSE

             AddUniqueViewColumns(lv2_sql_lines ,'WHERE '||lv2_db_where_cond);

         END IF;

     END IF;

   END IF;


   EcDp_Dynsql.SafeBuild('RV_'||p_class_name,'VIEW',lv2_sql_lines ,p_target, p_lfflg => 'Y');


END ReportDataClassView;






--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : ReportTableClassView
-- Description    : Generate report views, class definition of type TABLE
--
-- Preconditions  : p_class_name must refer to a class of type 'TABLE'
--                  TV_<p_class_name> must have been created.
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
PROCEDURE ReportTableClassView(
   p_class_name   VARCHAR2,
   p_daytime      DATE,
   p_target       VARCHAR2 DEFAULT 'CREATE'
)
--</EC-DOC>
IS

   lv2_sql_lines        DBMS_SQL.varchar2a;
   lv2_table_name        class_db_mapping.db_object_name%TYPE;
   lv2_where_clause      class_db_mapping.db_where_condition%TYPE;
   lv2_attr_unit        VARCHAR2(100);
   lv2_column_name      VARCHAR2(30);
   lb_daytime_exsist    BOOLEAN;
   lb_prod_day_exsist    BOOLEAN;
   lv2_daytime_syntax   VARCHAR2(200);
   lv2_schema_owner       class_db_mapping.db_object_owner%TYPE;


BEGIN

  FOR curClass IN EcDP_ClassMeta.c_classes(p_class_name) LOOP
    lv2_table_name := curClass.db_object_name;
    lv2_where_clause := curClass.db_where_condition;
    lv2_schema_owner := curClass.db_object_owner;
  END LOOP;




   -- Generate RV_<class_name> for table views.
   AddUniqueViewColumns(lv2_sql_lines, 'CREATE OR REPLACE VIEW RV_' || p_class_name || ' AS ');
   AddUniqueViewColumns(lv2_sql_lines, 'SELECT');
   AddUniqueViewColumns(lv2_sql_lines, GeneratedCodeMsg2);

   lv2_daytime_syntax := EcDp_ClassMeta.getClassAttrDBSqlSyntax(p_class_name,'DAYTIME');

   IF lv2_daytime_syntax IS NULL THEN
     lv2_daytime_syntax := 'EcDp_date_time.getCurrentSysdate';
   END IF;

   -- Get dataclass columns
   createReportDCColumnList(lv2_sql_lines, p_class_name , lv2_table_name, lv2_schema_owner, lv2_daytime_syntax, 'Y');



   AddUniqueViewColumns(lv2_sql_lines, ' FROM '||lv2_table_name);


  IF lv2_where_clause IS NOT NULL THEN

    AddUniqueViewColumns(lv2_sql_lines, ' WHERE '||lv2_where_clause);

  END IF;

  EcDp_Dynsql.SafeBuild('RV_'||p_class_name,'VIEW',lv2_sql_lines,p_target,p_lfflg => 'Y');

END ReportTableClassView;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : ReportInterfaceClassView
-- Description    : Generate report views, class definition of type INTERFACE
--
-- Preconditions  : p_class_name must refer to a class of type 'INTERFACE'
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
PROCEDURE ReportInterfaceClassView(
   p_class_name   VARCHAR2,
   p_daytime      DATE,
   p_target VARCHAR2 DEFAULT 'CREATE'
)
--</EC-DOC>
IS
  TYPE column_list_type
  IS TABLE OF VARCHAR2(50);

  TYPE view_list_type
  IS TABLE OF VARCHAR2(32);

  Interface_class_mismatch EXCEPTION;

  lv2_view_cols           VARCHAR2(8000);
  column_list             column_list_type  := column_list_type();
  view_list               view_list_type := view_list_type();
  ln_columncount          NUMBER;
  ln_column               NUMBER;
  lb_found                BOOLEAN;
  ln_unioncount           NUMBER;

  lv2_sql_statement       VARCHAR2(32000);
  lv2_base_table_where    VARCHAR2(32);
  lv2_cur_class           VARCHAR2(32);  -- Used in exception reporting
  lv2_cur_attrib          VARCHAR2(32);  -- Used in exception reporting
  lv2_child_view_name     VARCHAR2(32);
  lv2_where_cond          class_db_mapping.db_where_condition%TYPE;

BEGIN

    -- check if interface has classes implementing it
    IF Ecdp_Classmeta.IsImplementationsDefined(p_class_name) = 'N' THEN
      RETURN;
    END IF;


   -- First build create with column list

    lv2_sql_statement := 'CREATE OR REPLACE VIEW RV_' || p_class_name || ' ( ' || chr(10);
    lv2_sql_statement := lv2_sql_statement ||'Class_name' || chr(10);
    lv2_sql_statement := lv2_sql_statement ||',Production_day' || chr(10);
    ln_columncount := 0;
    ln_unioncount := 0;

    lv2_where_cond := EcDp_ClassMeta.GetClassWhereCondition(p_class_name);

    FOR  ClassesAttr IN EcDp_ClassMeta.c_classes_intf_attr (p_class_name , 'N') LOOP

         ln_columncount := ln_columncount + 1;
         lv2_sql_statement := lv2_sql_statement ||','|| ClassesAttr.attribute_name || chr(10);
         column_list.EXTEND;
         column_list(ln_columncount) := ClassesAttr.attribute_name;

    END LOOP;


    FOR  ClassesRel IN EcDp_ClassMeta.c_classes_intf_rel (p_class_name) LOOP

      ln_columncount := ln_columncount + 1;
      column_list.EXTEND;
      column_list(ln_columncount) := ClassesRel.role_name;

      lv2_sql_statement := lv2_sql_statement || ',' ||  ClassesRel.role_name || '_ID' || chr(10);

      lv2_sql_statement := lv2_sql_statement || ','  || ClassesRel.role_name || '_CODE' || chr(10);

    END LOOP;


    lv2_sql_statement := lv2_sql_statement ||', RECORD_STATUS' || chr(10);
    lv2_sql_statement := lv2_sql_statement ||', CREATED_BY' || chr(10);
    lv2_sql_statement := lv2_sql_statement ||', CREATED_DATE' || chr(10);
    lv2_sql_statement := lv2_sql_statement ||', LAST_UPDATED_BY' || chr(10);
    lv2_sql_statement := lv2_sql_statement ||', LAST_UPDATED_DATE' || chr(10);
    lv2_sql_statement := lv2_sql_statement ||', REV_NO' || chr(10);
    lv2_sql_statement := lv2_sql_statement ||', REV_TEXT' || chr(10);

    lv2_sql_statement := lv2_sql_statement ||', APPROVAL_STATE' || chr(10);
    lv2_sql_statement := lv2_sql_statement ||', APPROVAL_BY' || chr(10);
    lv2_sql_statement := lv2_sql_statement ||', APPROVAL_DATE' || chr(10);
    lv2_sql_statement := lv2_sql_statement ||', REC_ID';

    lv2_sql_statement := lv2_sql_statement ||') AS '||  chr(10);


    -- This will be a union query, need to loop all source classes

    FOR Intf_sources IN EcDp_ClassMeta.c_classes_interface(p_class_name) LOOP

       IF ln_unioncount = 0 THEN
          lv2_view_cols := ' SELECT '||GeneratedCodeMsg||''''||intf_sources.child_class||'''';
       ELSE
          lv2_view_cols := ' UNION ALL SELECT '''||intf_sources.child_class||'''';
       END IF;

     lv2_view_cols := lv2_view_cols||CHR(10)||',PRODUCTION_DAY'||CHR(10);

       ln_unioncount := ln_unioncount + 1;

       ln_column := 0;

        -- First try to find the column as a normal attribute
        ln_column := ln_column + 1;

        FOR  ClassesAttr IN EcDp_ClassMeta.c_classes_intf_attr (p_class_name , 'N') LOOP

          lb_found := TRUE;

          lv2_view_cols := lv2_view_cols  ||','|| ClassesAttr.attribute_name || chr(10);


        END LOOP;


        FOR  ClassesRel IN EcDp_ClassMeta.c_classes_intf_rel (p_class_name) LOOP

            ln_columncount := ln_columncount + 1;
            column_list.EXTEND;
            column_list(ln_columncount) := ClassesRel.role_name;

        lv2_view_cols := lv2_view_cols || ',' ||  ClassesRel.role_name || '_ID' || chr(10);

            lv2_view_cols := lv2_view_cols || ','  || ClassesRel.role_name || '_CODE' || chr(10);



         END LOOP;

      lv2_view_cols := lv2_view_cols ||
                                ', RECORD_STATUS '||
                        CHR(10)||', CREATED_BY  '||
                        CHR(10)||', CREATED_DATE  '||
                        CHR(10)||', LAST_UPDATED_BY  '||
                        CHR(10)||', LAST_UPDATED_DATE  '||
                        CHR(10)||', REV_NO  '||
                        CHR(10)||', REV_TEXT  '||CHR(10) ||

                        CHR(10)||', APPROVAL_STATE  '||
                        CHR(10)||', APPROVAL_BY  '||
                        CHR(10)||', APPROVAL_DATE  '||
                        CHR(10)||', REC_ID  '||CHR(10) ;


      view_list.EXTEND;
      view_list(ln_unioncount) := lv2_child_view_name;

      lv2_sql_statement := lv2_sql_statement || lv2_view_cols ||
                              ' FROM RV_'|| intf_sources.child_class || chr(10);

      -- Add where condition on each child class
      IF lv2_where_cond IS NOT NULL THEN

         lv2_sql_statement := lv2_sql_statement ||
                              ' WHERE '||lv2_where_cond||CHR(10);

      END IF;



    END LOOP; -- Interface



   SafeBuild('RV_'||p_class_name,'VIEW',lv2_sql_statement,p_target);



EXCEPTION

    WHEN Interface_class_mismatch THEN
         EcDp_DynSql.WriteTempText('GENCODEERROR','Interface class column '||lv2_cur_attrib ||' not found in class '||lv2_cur_class);
         COMMIT;


     WHEN OTHERS THEN
         EcDp_DynSql.WriteTempText('GENCODEERROR','Syntax error generating view for '||p_class_name||CHR(10)||SQLERRM||CHR(10)||
                                      lv2_sql_statement);


END ReportInterfaceClassView;


PROCEDURE AddMissingAttributes(p_class_name VARCHAR2)

IS

CURSOR c_attributes IS
select attribute_name, cdb.DB_OBJECT_ATTRIBUTE, cdb.db_object_owner
from class_attr_db_mapping cadb,
     class c,
     class_db_mapping cdb
where c.class_name = cdb.class_name
and   c.class_name = cadb.class_name
AND   cadb.db_mapping_type = 'ATTRIBUTE'
AND   cdb.DB_OBJECT_ATTRIBUTE IS NOT NULL
AND   c.class_type = 'OBJECT'
and   c.class_name = p_class_name;

CURSOR c_relations IS
select role_name, db_sql_syntax, cdb.DB_OBJECT_ATTRIBUTE, cdb.db_object_owner
from class_rel_db_mapping cadb,
     class c,
     class_db_mapping cdb
where c.class_name = cdb.class_name
and   c.class_name = cadb.to_class_name
AND   cadb.db_mapping_type = 'ATTRIBUTE'
AND   cdb.DB_OBJECT_ATTRIBUTE IS NOT NULL
AND   c.class_type = 'OBJECT'
and   c.class_name = p_class_name;


lv2_attribute_table varchar2(100);
lv2_sql             varchar2(4000);

BEGIN

   -- If there are existing objects, check that all existing objects have all the attributes

   FOR curAttr IN c_attributes LOOP


      IF curAttr.db_object_owner IS NOT NULL AND curAttr.db_object_attribute IS NOT NULL THEN

        lv2_attribute_table := curAttr.db_object_owner ||'.'||curAttr.db_object_attribute;

      ELSE

        lv2_attribute_table := curAttr.db_object_attribute;

      END IF;


      -- Must add the new attribute to all existing versions

      lv2_sql := ' INSERT INTO '||lv2_attribute_table|| '(object_id,daytime,attribute_type,end_date,created_by,created_date) '||chr(10)||
                ' SELECT object_id,daytime,:attribute_name,end_date,:CREATED_BY,:CREATED_DATE'||chr(10)||
                ' FROM '||lv2_attribute_table||' a1 '|| CHR(10)||
                ' where attribute_type = ''OBJECT_CODE'''||CHR(10)||
                ' and not exists ( select 1 from '||lv2_attribute_table||' a2 '||CHR(10)||
                '                  where a1.object_id = a2.object_id '||CHR(10)||
                '                  and   a1.daytime = a2.daytime '||CHR(10)||
                '                  and   a2.attribute_type = :attribute_name) ';


        EXECUTE IMMEDIATE lv2_sql using curAttr.attribute_name, 'SYSTEM', EcDp_Date_Time.getCurrentSysdate, curAttr.attribute_name;

   END LOOP;


   FOR currel IN c_relations LOOP


      IF currel.db_object_owner IS NOT NULL AND currel.db_object_attribute IS NOT NULL THEN

        lv2_attribute_table := currel.db_object_owner ||'.'||currel.db_object_attribute;

      ELSE

        lv2_attribute_table := currel.db_object_attribute;

      END IF;

     -- Must add new relations to all existing versions

         lv2_sql := ' INSERT INTO '||lv2_attribute_table|| '(object_id,daytime,attribute_type,end_date,created_by,created_date) '||chr(10)||
                   ' SELECT object_id,daytime,:attribute_name,end_date,:CREATED_BY,:CREATED_DATE'||chr(10)||
                   ' FROM '||lv2_attribute_table||' a1 '|| CHR(10)||
                   ' where attribute_type = ''OBJECT_CODE'''||CHR(10)||
                   ' and not exists ( select 1 from '||lv2_attribute_table||' a2 '||CHR(10)||
                   '                  where a1.object_id = a2.object_id '||CHR(10)||
                   '                  and   a1.daytime = a2.daytime '||CHR(10)||
                   '                  and   a2.attribute_type = :attribute_name) ';

           EXECUTE IMMEDIATE lv2_sql using currel.db_sql_syntax, 'SYSTEM', EcDp_Date_Time.getCurrentSysdate, currel.db_sql_syntax;

   END LOOP;

END AddMissingAttributes;




--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : ObjectClassTriggerPackageHead
-- Description    :
--
-- Preconditions  :
--
--
--
-- Postcondition  :
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
PROCEDURE ObjectClassTriggerPackageHead(
   p_class_name  VARCHAR2,
   p_daytime     DATE,
   p_target      VARCHAR2 DEFAULT 'CREATE'
)
--</EC-DOC>

IS

CURSOR c_group_relations IS
SELECT cr.group_type, cr.from_class_name, db.db_sql_syntax
FROM class_relation cr, class_rel_db_mapping db
WHERE cr.from_class_name = db.from_class_name
AND   cr.to_class_name = db.to_class_name
AND   cr.role_name = db.role_name
AND   group_type IS NOT NULL
AND   cr.to_class_name = p_class_name
AND   db.db_mapping_type <> 'FUNCTION'  -- Skip any mappings of type FUNCTION
ORDER BY cr.from_class_name;

CURSOR curAllChildren IS
select g.*
from V_GROUP_LEVEL g, class_rel_db_mapping db
WHERE g.from_class_name = db.from_class_name
AND   g.to_class_name = db.to_class_name
AND   g.role_name = db.role_name
AND   db.db_mapping_type <> 'FUNCTION'  -- Skip any mappings of type FUNCTION
AND   g.from_class_name = p_class_name;

CURSOR curAllDistChildren IS
SELECT distinct db.db_sql_syntax
from V_GROUP_LEVEL g, class_rel_db_mapping db
where g.from_class_name = db.from_class_name
and   g.to_class_name = db.to_class_name
and   g.role_name = db.role_name
and   g.class_name = p_class_name
and   db.db_mapping_type <> 'FUNCTION';  -- Skip any mappings of type FUNCTION


CURSOR c_partofGroupModel IS
SELECT 1
FROM class_relation cr, class_rel_db_mapping db
WHERE cr.from_class_name = db.from_class_name
AND   cr.to_class_name = db.to_class_name
AND   cr.role_name = db.role_name
AND   ( cr.from_class_name = p_class_name OR cr.to_class_name = p_class_name  )
AND   ( cr.group_type IS NOT NULL )
and   db.db_mapping_type <> 'FUNCTION';  -- Skip any mappings of type FUNCTION


header_lines   DBMS_SQL.varchar2a;


BEGIN

   -- First create the package header
   Ecdp_Dynsql.AddSqlLine(header_lines, 'CREATE OR REPLACE PACKAGE ECTP_' || p_class_name ||' IS '|| chr(10) );
   Ecdp_Dynsql.AddSqlLine(header_lines, GeneratedCodeMsg||CHR(10) );

   FOR curVer IN ecdp_classMeta.c_classes(p_class_name) LOOP
     Ecdp_Dynsql.AddSqlLine(header_lines,' TYPE ver_tab_type IS TABLE OF ' || curVer.DB_OBJECT_ATTRIBUTE ||'%ROWTYPE;'|| chr(10)|| chr(10));
   END LOOP;

-- declare section
  Ecdp_Dynsql.AddSqlLine(header_lines,'FUNCTION  AlignParentVersions(p_vt         VER_TAB_TYPE,' || chr(10));
  Ecdp_Dynsql.AddSqlLine(header_lines,'                              p_group_type VARCHAR2,' || chr(10));
  Ecdp_Dynsql.AddSqlLine(header_lines,'                              p_from_class VARCHAR2 DEFAULT NULL)' || chr(10));
  Ecdp_Dynsql.AddSqlLine(header_lines,'RETURN ver_tab_type;' || chr(10) || chr(10));


  Ecdp_Dynsql.AddSqlLine(header_lines,'PROCEDURE SyncronizeChildren(p_vt ver_tab_type, p_code_change_ind varchar2 default Null);' || chr(10) || chr(10));

  Ecdp_Dynsql.AddSqlLine(header_lines,'PROCEDURE SyncronizeFromParent(p_daytime DATE, p_end_date DATE, ' || chr(10));


   FOR curAll IN curAllDistChildren LOOP

     Ecdp_Dynsql.AddSqlLine(header_lines,'                               p_'||curAll.db_sql_syntax||' VARCHAR2 default null, ' || chr(10));

   END LOOP;

   Ecdp_Dynsql.AddSqlLine(header_lines,'                               p_vt VER_TAB_TYPE);' || chr(10) || chr(10) || chr(10));


   Ecdp_Dynsql.AddSqlLine(header_lines,'PROCEDURE lockForUpdate(p_where VARCHAR2);' || chr(10) || chr(10));

   Ecdp_Dynsql.AddSqlLine(header_lines,'PROCEDURE CallSyncChildren( p_vt ECTP_'||p_class_name||'.ver_tab_type,p_direct_only varchar2 default NULL);' || chr(10) || chr(10)) ;
   Ecdp_Dynsql.AddSqlLine(header_lines,'PROCEDURE ExtendFilledRow( p_vt IN OUT ECTP_'||p_class_name||'.ver_tab_type);' || chr(10) || chr(10)) ;

  Ecdp_Dynsql.AddSqlLine(header_lines,'FUNCTION SetObjStartDate(p_vt                  ver_tab_type,'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(header_lines,'                         p_object_id           VARCHAR2,'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(header_lines,'                         p_daytime             DATE,'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(header_lines,'                         p_last_updated_by     VARCHAR2 DEFAULT USER,'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(header_lines,'                         p_last_updated_date   DATE DEFAULT EcDp_Date_Time.GetCurrentSysDate)'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(header_lines,'RETURN ver_tab_type;'||CHR(10)||CHR(10));

  Ecdp_Dynsql.AddSqlLine(header_lines,'FUNCTION SetObjEndDate(p_vt                  ver_tab_type,'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(header_lines,'                         p_object_id          VARCHAR2,'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(header_lines,'                         p_end_date          DATE,'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(header_lines,'                         p_last_updated_by   VARCHAR2 DEFAULT USER,'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(header_lines,'                         p_last_updated_date DATE DEFAULT EcDp_Date_Time.GetCurrentSysDate,'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(header_lines,'                         p_rev_text          VARCHAR2)'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(header_lines,'RETURN ver_tab_type;'||CHR(10)||CHR(10));


   Ecdp_Dynsql.AddSqlLine(header_lines,'END;' || chr(10));


   Ecdp_Dynsql.SafeBuild('ECTP_'||p_class_name,'PACKAGE',header_lines,p_target);


END ObjectClassTriggerPackageHead;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : ObjectClassTriggerPackageBody
-- Description    :
--
-- Preconditions  :
--
--
--
-- Postcondition  :
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
PROCEDURE ObjectClassTriggerPackageBody(
   p_class_name  VARCHAR2,
   p_daytime     DATE,
   p_target      VARCHAR2 DEFAULT 'CREATE'
)
--</EC-DOC>

IS

CURSOR c_class_group_types IS
SELECT DISTINCT group_type
FROM class_relation
WHERE to_class_name = p_class_name
AND  nvl(disabled_ind, 'N') = 'N'
AND   group_type IS NOT NULL;


CURSOR c_group_relations(cp_group_type VARCHAR2 DEFAULT NULL) IS
SELECT cr.group_type, cr.from_class_name, db.db_sql_syntax
FROM class_relation cr, class_rel_db_mapping db
WHERE cr.from_class_name = db.from_class_name
AND   cr.to_class_name = db.to_class_name
AND   cr.role_name = db.role_name
AND   group_type IS NOT NULL
AND   group_type = Nvl(cp_group_type,group_type)
AND   cr.to_class_name = p_class_name
AND  nvl(cr.disabled_ind, 'N') = 'N'
and   db.db_mapping_type <> 'FUNCTION'   -- Skip any mappings of type FUNCTION
ORDER BY ecdp_classmeta.getGroupModelLevelSortOrder('operational',cr.to_class_name, cr.from_class_name) DESC, cr.from_class_name;


CURSOR c_denormalised(p_group_type VARCHAR2) IS
SELECT r.group_type, g.class_name, g.from_class_name,g.to_class_name, g.role_name, db_sql_syntax
FROM V_GROUP_LEVEL g, class_rel_db_mapping db, class_relation r
WHERE g.class_name = p_class_name
AND g.to_class_name <> p_class_name
and g.from_class_name = db.from_class_name
and g.to_class_name = db.to_class_name
and g.role_name = db.role_name
AND g.from_class_name = r.from_class_name
and g.to_class_name = r.to_class_name
and g.role_name = r.role_name
AND r.group_type = Nvl(p_group_type,r.group_type)
and db.db_mapping_type <> 'FUNCTION';  -- Skip any mappings of type FUNCTION


CURSOR c_directchild (p_from_class_name VARCHAR2, p_to_class_name VARCHAR2) IS
  SELECT 1
FROM class_relation cr, class_rel_db_mapping db
WHERE cr.from_class_name = db.from_class_name
AND   cr.to_class_name = db.to_class_name
AND   cr.role_name = db.role_name
AND cr.from_class_name = p_from_class_name
    AND cr.to_class_name = p_to_class_name
AND nvl(cr.disabled_ind, 'N') = 'N'
    AND cr.group_type IS NOT NULL
AND   db.db_mapping_type <> 'FUNCTION';  -- Skip any mappings of type FUNCTION


CURSOR curAllChildren IS
select g.*, cr.group_type
from V_GROUP_LEVEL g, class_relation cr, class_rel_db_mapping db
where g.from_class_name = cr.from_class_name
and   g.to_class_name = cr.to_class_name
and   g.role_name = cr.role_name
and   cr.from_class_name = db.from_class_name
and   cr.to_class_name = db.to_class_name
and   cr.role_name = db.role_name
and   db.db_mapping_type <> 'FUNCTION'  -- Skip any mappings of type FUNCTION
and   g.from_class_name = p_class_name;




CURSOR curAllDistinctChildren IS
SELECT DISTINCT class_name
FROM V_GROUP_LEVEL g, class_rel_db_mapping db
where g.from_class_name = db.from_class_name
and   g.to_class_name = db.to_class_name
and   g.role_name = db.role_name
and   db.db_mapping_type <> 'FUNCTION'  -- Skip any mappings of type FUNCTION
AND g.from_class_name = p_class_name;



CURSOR curAllDistChildren IS
SELECT distinct db.db_sql_syntax
from V_GROUP_LEVEL g, class_rel_db_mapping db
where g.from_class_name = db.from_class_name
and   g.to_class_name = db.to_class_name
and   g.role_name = db.role_name
and   g.class_name = p_class_name
and   db.db_mapping_type <> 'FUNCTION';  -- Skip any mappings of type FUNCTION


CURSOR c_partofGroupModel IS
SELECT 1
FROM  class_relation cr, class_rel_db_mapping db
WHERE cr.from_class_name = db.from_class_name
and   cr.to_class_name = db.to_class_name
and   cr.role_name = db.role_name
AND ( cr.from_class_name = p_class_name OR cr.to_class_name = p_class_name )
AND nvl(disabled_ind, 'N') = 'N'
AND   ( group_type IS NOT NULL )
and   db.db_mapping_type <> 'FUNCTION';  -- Skip any mappings of type FUNCTION

CURSOR CurAllDistinctClassGroupTypes IS
SELECT DISTINCT group_type
FROM  class_relation cr, class_rel_db_mapping db
WHERE cr.from_class_name = db.from_class_name
and   cr.to_class_name = db.to_class_name
and   cr.role_name = db.role_name
AND   cr.to_class_name = p_class_name
AND   NVL(cr.disabled_ind, 'N') = 'N'
AND   group_type IS NOT NULL
and   db.db_mapping_type <> 'FUNCTION';  -- Skip any mappings of type FUNCTION



CURSOR c_GRoupLevelType(cp_to_class_name VARCHAR2) IS
SELECT DISTINCT db.db_sql_syntax
FROM  class_relation cr, class_rel_db_mapping db
WHERE cr.from_class_name = db.from_class_name
and   cr.to_class_name = db.to_class_name
and   cr.role_name = db.role_name
AND   cr.from_class_name = p_class_name
and   db.db_mapping_type <> 'FUNCTION'  -- Skip any mappings of type FUNCTION
AND   group_type IS NOT NULL
and   exists (
      select 1 from class_relation cr2, v_group_level g
      where cr.group_type = cr2.group_type
       AND NVL(cr2.disabled_ind, 'N') = 'N'
       and g.from_class_name=cr2.from_class_name
       and g.to_class_name=cr2.to_class_name
       and g.role_name=cr2.role_name
       and g.class_name = cp_to_class_name
       and g.to_class_name=cr.to_class_name
      );



CURSOR curAllDistinctParents(cp_from_class_name VARCHAR2,cp_to_class_name VARCHAR2) IS
SELECT distinct db.db_sql_syntax
from V_GROUP_LEVEL g,
     class_relation cr,
     class_rel_db_mapping db
where g.from_class_name = db.from_class_name
and   g.to_class_name = db.to_class_name
and   g.role_name = db.role_name
AND   g.from_class_name = cr.from_class_name
and   g.to_class_name = cr.to_class_name
and   g.role_name = cr.role_name
AND   g.class_name = cp_from_class_name
and   db.db_mapping_type <> 'FUNCTION'  -- Skip any mappings of type FUNCTION
and   exists (
      select 1 from class_relation cr2
      where cr.group_type = cr2.group_type
      and   cr2.to_class_name = cp_to_class_name
      );



CURSOR c_AllParentsColumns IS
SELECT distinct cr.group_type, db.db_sql_syntax
from V_GROUP_LEVEL g,
     class_relation cr,
     class_rel_db_mapping db
where g.from_class_name = cr.from_class_name
and   g.to_class_name = cr.to_class_name
and   g.role_name = cr.role_name
AND   g.from_class_name = db.from_class_name
and   g.to_class_name = db.to_class_name
and   g.role_name = db.role_name
AND   g.class_name = p_class_name
and   db.db_mapping_type <> 'FUNCTION';  -- Skip any mappings of type FUNCTION




CURSOR c_grouprel_distinct_to(p_from_class_name VARCHAR2) IS
  SELECT DISTINCT cr.to_class_name
  FROM class_relation cr,
     class_rel_db_mapping db
WHERE cr.from_class_name = db.from_class_name
AND   cr.to_class_name = db.to_class_name
AND   cr.role_name = db.role_name
AND cr.from_class_name =  p_from_class_name
    AND cr.group_type IS NOT NULL
AND NVL(cr.disabled_ind, 'N') = 'N'
    AND multiplicity IN ('1:1', '1:N')
and   db.db_mapping_type <> 'FUNCTION'  -- Skip any mappings of type FUNCTION
ORDER BY to_class_name;


CURSOR c_AllNonGroupRelColumns IS
  SELECT cr.role_name, db.db_sql_syntax
  FROM class_relation cr, class_rel_db_mapping db
  WHERE cr.from_class_name =  db.from_class_name
    AND cr.to_class_name =  db.to_class_name
    AND cr.role_name =  db.role_name
    AND cr.group_type IS NULL
    AND multiplicity IN ('1:1', '1:N')
    AND NVL(cr.disabled_ind, 'N') = 'N'
    AND cr.to_class_name = p_class_name
    AND   db.db_mapping_type <> 'FUNCTION'  -- Skip any mappings of type FUNCTION
  ORDER BY role_name
  ;



CURSOR c_ClassDenormCol(p_from_class VARCHAR2, p_to_class VARCHAR2, p_role_name VARCHAR2) IS
select * from class_rel_db_mapping
where from_class_name = p_from_class
AND  to_class_name = p_to_class
AND  role_name = p_role_name
and  db_mapping_type <> 'FUNCTION';  -- Skip any mappings of type FUNCTION


-- At the moment this cursor is only handling well processing_node
CURSOR c_ClassSpesificDenormalised IS
SELECT table_name, column_name
FROM user_tab_columns
WHERE table_name = 'WELL_VERSION'
AND 'WELL' = P_class_name
AND column_name IN ('PROC_NODE_OIL_ID','PROC_NODE_GAS_ID','PROC_NODE_COND_ID',
                    'PROC_NODE_WATER_ID','PROC_NODE_WATER_INJ_ID','PROC_NODE_GAS_INJ_ID',
                    'PROC_NODE_DILUENT_ID','PROC_NODE_STEAM_INJ_ID','PROC_NODE_GAS_LIFT_ID',  'PROC_NODE_CO2_ID','PROC_NODE_CO2_INJ_ID');


CURSOR c_ClassSpesific IS
SELECT table_name, column_name
FROM user_tab_columns
WHERE table_name = 'WELL_VERSION'
AND column_name IN ('PROC_NODE_OIL_ID','PROC_NODE_GAS_ID','PROC_NODE_COND_ID',
                    'PROC_NODE_WATER_ID','PROC_NODE_WATER_INJ_ID','PROC_NODE_GAS_INJ_ID',
                    'PROC_NODE_DILUENT_ID','PROC_NODE_STEAM_INJ_ID','PROC_NODE_GAS_LIFT_ID', 'PROC_NODE_CO2_ID','PROC_NODE_CO2_INJ_ID');


CURSOR c_sameparent IS
select DISTINCT  cr.group_type, db.db_sql_syntax  -- g1.*,
from v_group_level g1, class_relation cr, class_rel_db_mapping db
where g1.from_class_name = cr.from_class_name
and   g1.to_class_name = cr.to_class_name
and   g1.role_name = cr.role_name
AND   g1.from_class_name = db.from_class_name
and   g1.to_class_name = db.to_class_name
and   g1.role_name = db.role_name
and   db.db_mapping_type <> 'FUNCTION'  -- Skip any mappings of type FUNCTION
and  class_name = p_class_name
AND 1 < (
    select count(*) from v_group_level g2
    where g1.class_name = g2.class_name
    and   g1.from_class_name = g2.from_class_name);




body_lines                   DBMS_SQL.varchar2a;
lv2_new_revision             VARCHAR2(100) := 'New revision due to changes on parent level';
lv2_new_version              VARCHAR2(100) := 'New version due to changes on parent level';

lv2_main_tablename           VARCHAR2(100);
lv2_version_tablename        VARCHAR2(32);
lv2_column_list              VARCHAR2(32000) := '';
lv2_value_list               VARCHAR2(32000) := '';
lv2_update_list              VARCHAR2(32000) := '';
ln_groupcursor_count         NUMBER;
lv2_cursorName               VARCHAR2(100);
lb_firsttime                 BOOLEAN;
lv2_vt_name                  VARCHAR2(100);
lb_parent_found              BOOLEAN;
ln_body_length               NUMBER;
lb_partofgroupModel          BOOLEAN := FALSE;
LB_DIRECTCHILD               BOOLEAN;
ln_first_group_level         NUMBER;
lb_wellhookup_inuse          BOOLEAN;
ln_union_count               NUMBER;
ln_class_count               NUMBER;
lb_approval_enabled          BOOLEAN := Nvl(Ec_Class.approval_ind(p_class_name),'N')='Y';
BEGIN

    FOR curClass IN ecdp_classMeta.c_classes(p_class_name) LOOP
      lv2_main_tablename    :=  curClass.DB_OBJECT_NAME;
      lv2_version_tablename :=  curClass.DB_OBJECT_ATTRIBUTE;
    END LOOP;

    FOR curClass IN c_partofGroupModel LOOP

      lb_partofgroupModel := TRUE;

    END LOOP;


   -- create the package body

   Ecdp_Dynsql.AddSqlLine(body_lines,'CREATE OR REPLACE PACKAGE BODY ECTP_' || p_class_name ||' IS '|| chr(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,GeneratedCodeMsg);
   Ecdp_Dynsql.AddSqlLine(body_lines,CHR(10) || CHR(10));

   Ecdp_Dynsql.AddSqlLine(body_lines,'------------------------------------------------------------------------------------------------------' || chr(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'-- AlignParentVersions' || chr(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'------------------------------------------------------------------------------------------------------' || chr(10));





   Ecdp_Dynsql.AddSqlLine(body_lines, 'FUNCTION  AlignParentVersions(p_vt         ver_tab_type,' || chr(10)) ;
   Ecdp_Dynsql.AddSqlLine(body_lines, '                              p_group_type VARCHAR2,' || chr(10)) ;
   Ecdp_Dynsql.AddSqlLine(body_lines, '                              p_from_class VARCHAR2 DEFAULT NULL)' || chr(10)) ;
   Ecdp_Dynsql.AddSqlLine(body_lines, 'RETURN ver_tab_type' || chr(10)) ;
   Ecdp_Dynsql.AddSqlLine(body_lines, 'IS' || chr(10) || chr(10))  ;


   IF  lb_partofgroupModel THEN

      lb_parent_found := FALSE;

      FOR curgroup IN c_group_relations LOOP

         Ecdp_Dynsql.AddSqlLine(body_lines, '  CURSOR ' ||'c_'||SUBSTR(curgroup.group_type,1,3)||'_'||curgroup.from_class_name||'(cp_object_id VARCHAR2, cp_daytime DATE, cp_end_date DATE) IS '|| chr(10));

        FOR curParentVer IN ecdp_classMeta.c_classes(curgroup.from_class_name) LOOP
           Ecdp_Dynsql.AddSqlLine(body_lines, '  SELECT * FROM ' || curParentVer.DB_OBJECT_ATTRIBUTE || chr(10));
         END LOOP;

         Ecdp_Dynsql.AddSqlLine(body_lines, '  WHERE object_id = cp_object_id '|| chr(10));
         Ecdp_Dynsql.AddSqlLine(body_lines, '  AND nvl(end_date,cp_daytime+1 ) > cp_daytime '|| chr(10));
         Ecdp_Dynsql.AddSqlLine(body_lines, '  AND daytime < nvl(cp_end_date,daytime+1 ) '|| chr(10));
         Ecdp_Dynsql.AddSqlLine(body_lines, '  ORDER BY daytime; '|| chr(10)|| chr(10));

         lb_parent_found := TRUE;


      END LOOP;


      Ecdp_Dynsql.AddSqlLine(body_lines, '  l_vt                    ver_tab_type;' || chr(10))  ;
      Ecdp_Dynsql.AddSqlLine(body_lines, '  j                       INTEGER       := 0;' || chr(10))  ;
      Ecdp_Dynsql.AddSqlLine(body_lines, '  ld_prev_parent_end_date DATE;' || chr(10)  ) ;
      Ecdp_Dynsql.AddSqlLine(body_lines, '  lb_parent_found         BOOLEAN := FALSE;' || chr(10) || chr(10) ) ;


      Ecdp_Dynsql.AddSqlLine(body_lines, 'BEGIN' || chr(10) || chr(10));

      IF lb_parent_found THEN

         Ecdp_Dynsql.AddSqlLine(body_lines, '  l_vt := ver_tab_type();'||chr(10) || chr(10));

         Ecdp_Dynsql.AddSqlLine(body_lines, '  FOR i IN 1..p_vt.count LOOP -- Initialy only 1 but subsequencial group models can have more' || chr(10) || chr(10))  ;


         ln_groupcursor_count := 0;

            Ecdp_Dynsql.AddSqlLine(body_lines, '    j := j + 1;' || chr(10));
            Ecdp_Dynsql.AddSqlLine(body_lines, '    l_vt.extend;' || chr(10));
            Ecdp_Dynsql.AddSqlLine(body_lines, '    l_vt(j) := p_vt(i);' || chr(10)|| chr(10));


         FOR curGroupType IN c_class_group_types LOOP

              Ecdp_Dynsql.AddSqlLine(body_lines, '    IF p_group_type = '''||curGroupType.group_type||''' THEN' || chr(10) || chr(10));
              Ecdp_Dynsql.AddSqlLine(body_lines, '           NULL; -- dummy for class relation with only function call' || chr(10));
              ln_first_group_level := 0;

              FOR curgroup2 IN c_group_relations(curGroupType.group_type) LOOP

                 ln_first_group_level := ln_first_group_level + 1;

                 IF ln_first_group_level = 1 THEN

                   Ecdp_Dynsql.AddSqlLine(body_lines, '      IF nvl(p_from_class,'''||curgroup2.from_class_name ||''') = '''||curgroup2.from_class_name ||''''|| chr(10));
                   Ecdp_Dynsql.AddSqlLine(body_lines, '      AND p_vt(i).'||curgroup2.db_sql_syntax ||' IS NOT NULL THEN' || chr(10) || chr(10));

                 ELSE

                   Ecdp_Dynsql.AddSqlLine(body_lines, '      ELSIF nvl(p_from_class,'''||curgroup2.from_class_name ||''') = '''||curgroup2.from_class_name ||''''|| chr(10));
                   Ecdp_Dynsql.AddSqlLine(body_lines, '      AND p_vt(i).'||curgroup2.db_sql_syntax ||' IS NOT NULL THEN' || chr(10) || chr(10));

                 END IF;

               lv2_cursorName := 'curP_'||SUBSTR(curgroup2.group_type,1,3)||'_'||curgroup2.from_class_name;


               Ecdp_Dynsql.AddSqlLine(body_lines, '        FOR '||lv2_cursorName||' IN c_'||SUBSTR(curgroup2.group_type,1,3)||'_'||curgroup2.from_class_name||'(p_vt(i).'||curgroup2.db_sql_syntax  ||',p_vt(i).daytime,p_vt(i).end_date)LOOP' || chr(10)|| chr(10));

               Ecdp_Dynsql.AddSqlLine(body_lines, '          lb_parent_found := TRUE;' || chr(10)|| chr(10));

               -- loop DAO meta to copy parent ids and codes


               FOR curDenorm IN  c_denormalised(curgroup2.group_type) LOOP

                    IF  curDenorm.from_class_name <> curgroup2.from_class_name THEN

                      Ecdp_Dynsql.AddSqlLine(body_lines, '          l_vt(j).'||curDenorm.db_sql_syntax||' := '||lv2_cursorName||'.'||curDenorm.db_sql_syntax||';'|| chr(10));
                      Ecdp_Dynsql.AddSqlLine(body_lines, '          l_vt(j).'||REPLACE(curDenorm.db_sql_syntax,'_ID', '_CODE')||' := '||lv2_cursorName||'.'||REPLACE(curDenorm.db_sql_syntax,'_ID','_CODE')||';'|| chr(10)|| chr(10));

                    END IF;

               END LOOP;

               Ecdp_Dynsql.AddSqlLine(body_lines, CHR(10));

               IF curgroup2.group_type = 'operational' THEN

                  FOR curClassSpesific IN c_ClassSpesificDenormalised LOOP

                     Ecdp_Dynsql.AddSqlLine(body_lines,  '          l_vt(j).'||curClassSpesific.column_name||' := ');
                     Ecdp_Dynsql.AddSqlLine(body_lines,  ' EcDp_Node.getProcessingNode('''||curClassSpesific.column_name||''',');
                     Ecdp_Dynsql.AddSqlLine(body_lines,  ' l_vt(j).daytime, l_vt(j).op_fcty_class_2_id, l_vt(j).op_fcty_class_1_id, l_vt(j).op_well_hookup_id, l_vt(j).alloc_flag, l_vt(j).well_type, l_vt(j).calc_co2_method, l_vt(j).gas_lift_method,l_vt(j).diluent_method);'|| CHR(10));



                  END LOOP;

                 Ecdp_Dynsql.AddSqlLine(body_lines,   CHR(10));

               END IF;

               Ecdp_Dynsql.AddSqlLine(body_lines, '          IF ('||lv2_cursorName||'.end_date  IS NOT NULL AND l_vt(j).end_date IS NULL) ' || chr(10));
               Ecdp_Dynsql.AddSqlLine(body_lines, '          OR ('||lv2_cursorName||'.end_date < nvl(l_vt(j).end_date,'||lv2_cursorName||'.end_date+1)) THEN ' || chr(10)|| chr(10));


               Ecdp_Dynsql.AddSqlLine(body_lines, '            l_vt.extend; ' || chr(10));
               Ecdp_Dynsql.AddSqlLine(body_lines, '            l_vt(j+1) := l_vt(j); ' || chr(10));
               Ecdp_Dynsql.AddSqlLine(body_lines, '            l_vt(j+1).daytime := '||lv2_cursorName||'.end_date; ' || chr(10));
               Ecdp_Dynsql.AddSqlLine(body_lines, '            l_vt(j).end_date := '||lv2_cursorName||'.end_date; ' || chr(10));
               Ecdp_Dynsql.AddSqlLine(body_lines, '            l_vt(j+1).end_date := p_vt(i).end_date; ' || chr(10));
               Ecdp_Dynsql.AddSqlLine(body_lines, '            l_vt(j+1).rev_text := '''||lv2_new_version||''' || replace(l_vt(j).rev_text,'''||lv2_new_version||''','''' ); ' || chr(10));
               Ecdp_Dynsql.AddSqlLine(body_lines, '            l_vt(j+1).created_by := nvl(p_vt(i).last_updated_by,p_vt(i).created_by); ' || chr(10));
               Ecdp_Dynsql.AddSqlLine(body_lines, '            l_vt(j+1).created_date := nvl(p_vt(i).last_updated_date,p_vt(i).last_updated_date); ' || chr(10));


               Ecdp_Dynsql.AddSqlLine(body_lines, '            j := j+1; ' || chr(10) || chr(10));


               Ecdp_Dynsql.AddSqlLine(body_lines, '          END IF; ' || chr(10)|| chr(10));

               Ecdp_Dynsql.AddSqlLine(body_lines, '          ld_prev_parent_end_date := '||lv2_cursorName||'.end_date; ' || chr(10)|| chr(10));


               Ecdp_Dynsql.AddSqlLine(body_lines, '        END LOOP; ' || chr(10)|| chr(10));

               Ecdp_Dynsql.AddSqlLine(body_lines, '        -- if parent terminates before child, the last version can not refer to parent so clear it out ' || chr(10));
               Ecdp_Dynsql.AddSqlLine(body_lines, '        IF ( ld_prev_parent_end_date is not null ' || chr(10));
               Ecdp_Dynsql.AddSqlLine(body_lines, '             AND nvl(l_vt(j).end_date, ld_prev_parent_end_date+1)  > ld_prev_parent_end_date )  ' || chr(10));
               Ecdp_Dynsql.AddSqlLine(body_lines, '        OR  not lb_parent_found THEN ' || chr(10)|| chr(10));


               Ecdp_Dynsql.AddSqlLine(body_lines, '           NULL; -- dummy for classes with no denormalized columns' || chr(10));

               FOR curDenorm IN  c_denormalised(curgroup2.group_type) LOOP


                   Ecdp_Dynsql.AddSqlLine(body_lines, '          l_vt(j).'||curDenorm.db_sql_syntax||' := NULL;' || chr(10));
                   Ecdp_Dynsql.AddSqlLine(body_lines, '          l_vt(j).'||REPLACE(curDenorm.db_sql_syntax,'_ID','_CODE')||' := NULL;' || chr(10)|| chr(10));


               END LOOP;

               Ecdp_Dynsql.AddSqlLine(body_lines, '          l_vt(j).'||curgroup2.db_sql_syntax||' := NULL;'|| chr(10));
               Ecdp_Dynsql.AddSqlLine(body_lines, '          l_vt(j).'||REPLACE(curgroup2.db_sql_syntax,'_ID', '_CODE')||' := NULL;'|| chr(10));


               Ecdp_Dynsql.AddSqlLine(body_lines, CHR(10));

              IF curgroup2.group_type = 'operational' THEN


                  FOR curClassSpesific IN c_ClassSpesificDenormalised LOOP

                     Ecdp_Dynsql.AddSqlLine(body_lines,  '          l_vt(j).'||curClassSpesific.column_name||' := NULL;'|| CHR(10));

                  END LOOP;

                 Ecdp_Dynsql.AddSqlLine(body_lines,   CHR(10));

               END IF;


               Ecdp_Dynsql.AddSqlLine(body_lines, '        END IF; ' || chr(10)|| chr(10));

      --         Ecdp_Dynsql.AddSqlLine(body_lines, '    END IF; ' || chr(10)|| chr(10));



            END LOOP;

            IF ln_first_group_level > 0 THEN

               Ecdp_Dynsql.AddSqlLine(body_lines, '    ELSE ' || chr(10)|| chr(10));

               Ecdp_Dynsql.AddSqlLine(body_lines, '         NULL; -- dummy for classes with no denormalized columns' || chr(10));

               FOR curgroup3 IN c_group_relations(curGroupType.group_type) LOOP

                  FOR curDenorm IN  c_denormalised(curGroupType.group_type) LOOP


                      Ecdp_Dynsql.AddSqlLine(body_lines, '        l_vt(j).'||curDenorm.db_sql_syntax||' := NULL;' || chr(10));
                      Ecdp_Dynsql.AddSqlLine(body_lines, '        l_vt(j).'||REPLACE(curDenorm.db_sql_syntax,'_ID','_CODE')||' := NULL;' || chr(10)|| chr(10));


                  END LOOP;

                  Ecdp_Dynsql.AddSqlLine(body_lines, '        l_vt(j).'||curgroup3.db_sql_syntax||' := NULL;'|| chr(10));
                  Ecdp_Dynsql.AddSqlLine(body_lines, '        l_vt(j).'||REPLACE(curgroup3.db_sql_syntax,'_ID', '_CODE')||' := NULL;'|| chr(10));


                  Ecdp_Dynsql.AddSqlLine(body_lines, CHR(10));

                 IF curGroupType.group_type = 'operational' THEN


                     FOR curClassSpesific IN c_ClassSpesificDenormalised LOOP

                        Ecdp_Dynsql.AddSqlLine(body_lines,  '        l_vt(j).'||curClassSpesific.column_name||' := NULL;'|| CHR(10));

                     END LOOP;

                    Ecdp_Dynsql.AddSqlLine(body_lines,   CHR(10));

                  END IF;

                  EXIT;

               END LOOP;

               Ecdp_Dynsql.AddSqlLine(body_lines, '      END IF; ' || chr(10)|| chr(10));


            END IF;

               Ecdp_Dynsql.AddSqlLine(body_lines, '    END IF; ' || chr(10)|| chr(10));




         END LOOP; -- CurGroupType

         Ecdp_Dynsql.AddSqlLine(body_lines, '  END LOOP;' || chr(10) || chr(10))  ;


       ELSE

         Ecdp_Dynsql.AddSqlLine(body_lines, '  l_vt := p_vt;' || chr(10))  ;


       END IF;

      Ecdp_Dynsql.AddSqlLine(body_lines, '  Return l_vt;' || chr(10))  ;

   ELSE  -- Not part of group model

      Ecdp_Dynsql.AddSqlLine(body_lines, 'BEGIN' || chr(10))  ;
      Ecdp_Dynsql.AddSqlLine(body_lines, '  Return p_vt;' || chr(10))  ;

   END IF; -- Part of group model

   Ecdp_Dynsql.AddSqlLine(body_lines, 'END;' || chr(10) || chr(10))  ;





   Ecdp_Dynsql.AddSqlLine(body_lines,'------------------------------------------------------------------------------------------------------' || chr(10)) ;
   Ecdp_Dynsql.AddSqlLine(body_lines,'-- SyncronizeChildren' || chr(10)) ;
   Ecdp_Dynsql.AddSqlLine(body_lines,'------------------------------------------------------------------------------------------------------' || chr(10)) ;




   Ecdp_Dynsql.AddSqlLine(body_lines, 'PROCEDURE  SyncronizeChildren(p_vt ver_tab_type, p_code_change_ind varchar2 default Null)' || chr(10)) ;
   Ecdp_Dynsql.AddSqlLine(body_lines, 'IS' || chr(10))  ;

   -- Declare version tables for direct child classes in the group model

   IF  lb_partofgroupModel THEN


       Ecdp_Dynsql.AddSqlLine(body_lines,  chr(10)) ;



      Ecdp_Dynsql.AddSqlLine(body_lines, '  cursor c_allObjVer is'||  chr(10))  ;
      Ecdp_Dynsql.AddSqlLine(body_lines, '  select *'||  chr(10))  ;
      Ecdp_Dynsql.AddSqlLine(body_lines, '  from '||lv2_version_tablename||  chr(10))  ;
      Ecdp_Dynsql.AddSqlLine(body_lines, '  where object_id = p_vt(1).object_id;'||  chr(10) || chr(10)) ;

      Ecdp_Dynsql.AddSqlLine(body_lines, '  cursor c_last_updated_main is'||  chr(10))  ;
      Ecdp_Dynsql.AddSqlLine(body_lines, '  select created_by, created_date,last_updated_by, last_updated_date'||  chr(10) ) ;
      Ecdp_Dynsql.AddSqlLine(body_lines, '  from '||lv2_main_tablename||  chr(10))  ;
      Ecdp_Dynsql.AddSqlLine(body_lines, '  where object_id = p_vt(1).object_id;'||  chr(10) || chr(10)) ;


      Ecdp_Dynsql.AddSqlLine(body_lines, '  cursor c_periodObjVer(cp_daytime DATE, cp_end_date DATE) is'||  chr(10))  ;
      Ecdp_Dynsql.AddSqlLine(body_lines, '  select *'||  chr(10))  ;
      Ecdp_Dynsql.AddSqlLine(body_lines, '  from '||lv2_version_tablename||  chr(10))  ;
      Ecdp_Dynsql.AddSqlLine(body_lines, '  where object_id = p_vt(1).object_id'||  chr(10))  ;
      Ecdp_Dynsql.AddSqlLine(body_lines, '  and daytime >= ('||  chr(10) ) ;
      Ecdp_Dynsql.AddSqlLine(body_lines, '  select max(daytime) from '||lv2_version_tablename||' g2'||  chr(10))  ;
      Ecdp_Dynsql.AddSqlLine(body_lines, '  where object_id = p_vt(1).object_id'||  chr(10))  ;
      Ecdp_Dynsql.AddSqlLine(body_lines, '  and daytime < cp_daytime)'||  chr(10))  ;
      Ecdp_Dynsql.AddSqlLine(body_lines, '  AND daytime <= cp_end_date  ;'||  chr(10) || chr(10)) ;

      Ecdp_Dynsql.AddSqlLine(body_lines, '  cursor c_thisObjVer is'||  chr(10))  ;
      Ecdp_Dynsql.AddSqlLine(body_lines, '  select *'||  chr(10))  ;
      Ecdp_Dynsql.AddSqlLine(body_lines, '  from '||lv2_version_tablename||  chr(10))  ;
      Ecdp_Dynsql.AddSqlLine(body_lines, '  where object_id = p_vt(1).object_id'||  chr(10) ) ;
      Ecdp_Dynsql.AddSqlLine(body_lines, '  and daytime = p_vt(1).daytime;'||  chr(10) || chr(10))  ;


      Ecdp_Dynsql.AddSqlLine(body_lines, '  l_vt ver_tab_type := ver_tab_type();'||  chr(10));
      Ecdp_Dynsql.AddSqlLine(body_lines, '  lv2_last_updated_by   varchar2(100);'||  chr(10));
      Ecdp_Dynsql.AddSqlLine(body_lines, '  ld_last_updated_date  date;'||  chr(10));
      Ecdp_Dynsql.AddSqlLine(body_lines, '  lv2_created_by        varchar2(100);'||  chr(10));
      Ecdp_Dynsql.AddSqlLine(body_lines, '  ld_created_date        date;'||  chr(10));



      Ecdp_Dynsql.AddSqlLine(body_lines, '  j INTEGER;'||  chr(10) || chr(10) );


      Ecdp_Dynsql.AddSqlLine(body_lines, 'BEGIN' || chr(10)) ;


      Ecdp_Dynsql.AddSqlLine(body_lines, '  IF Nvl(p_code_change_ind,''N'') = ''N'' THEN '|| chr(10) || chr(10))  ;


      Ecdp_Dynsql.AddSqlLine(body_lines, '     j := 1;' || chr(10) || chr(10))  ;

      Ecdp_Dynsql.AddSqlLine(body_lines, '     FOR curObjVer2 IN c_periodObjVer(p_vt(1).daytime, p_vt(p_vt.LAST).daytime) LOOP' || chr(10) || chr(10))  ;

      Ecdp_Dynsql.AddSqlLine(body_lines, '       l_vt.extend;' || chr(10))   ;
      Ecdp_Dynsql.AddSqlLine(body_lines, '       l_vt(j) := curObjVer2;' || chr(10))   ;
      Ecdp_Dynsql.AddSqlLine(body_lines, '       j := j +1;' || chr(10) || chr(10))  ;

      Ecdp_Dynsql.AddSqlLine(body_lines, '     END LOOP;' || chr(10) || chr(10))  ;


      Ecdp_Dynsql.AddSqlLine(body_lines, '     IF j = 1 THEN' || chr(10) || chr(10))  ;

      Ecdp_Dynsql.AddSqlLine(body_lines, '       FOR curObjVer3 IN c_thisObjVer LOOP' || chr(10) || chr(10))  ;

      Ecdp_Dynsql.AddSqlLine(body_lines, '         l_vt.extend;' || chr(10))   ;
      Ecdp_Dynsql.AddSqlLine(body_lines, '         l_vt(j) := curObjVer3;' || chr(10))   ;
      Ecdp_Dynsql.AddSqlLine(body_lines, '         j := j +1;' || chr(10) || chr(10))  ;

      Ecdp_Dynsql.AddSqlLine(body_lines, '       END LOOP;' || chr(10) || chr(10))  ;


      Ecdp_Dynsql.AddSqlLine(body_lines, '     END IF;' || chr(10) || chr(10))  ;


      Ecdp_Dynsql.AddSqlLine(body_lines, '  ELSE -- Must update all versions '|| chr(10) || chr(10))  ;

      Ecdp_Dynsql.AddSqlLine(body_lines, '    j := 1; '|| chr(10) || chr(10))  ;

      Ecdp_Dynsql.AddSqlLine(body_lines, '    FOR curObj in c_last_updated_main LOOP '|| chr(10))  ;
      Ecdp_Dynsql.AddSqlLine(body_lines, '      lv2_created_by  := curObj.created_by;' || CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines, '      ld_created_date := curObj.created_date;' || CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines, '      lv2_last_updated_by  := curObj.last_updated_by;' || CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines, '      ld_last_updated_date := curObj.last_updated_date;' || CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines, '    END LOOP;'||CHR(10)||CHR(10));

      Ecdp_Dynsql.AddSqlLine(body_lines, '    FOR curObjVer IN c_allObjVer LOOP '|| chr(10) || chr(10))  ;
      Ecdp_Dynsql.AddSqlLine(body_lines, '      l_vt.extend; '|| chr(10));
      Ecdp_Dynsql.AddSqlLine(body_lines, '      l_vt(j) := curObjVer; '|| chr(10));
      Ecdp_Dynsql.AddSqlLine(body_lines, '      l_vt(j).created_by := lv2_created_by;'||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines, '      l_vt(j).created_date := ld_created_date;'||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines, '      l_vt(j).last_updated_by := lv2_last_updated_by;'||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines, '      l_vt(j).last_updated_date := ld_last_updated_date;'||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines, '      j := j +1; '|| chr(10));
      Ecdp_Dynsql.AddSqlLine(body_lines, '    END LOOP; ' || chr(10) || chr(10));


      Ecdp_Dynsql.AddSqlLine(body_lines, '  END IF; '|| chr(10) || chr(10))  ;



      -- First need to lock all rows that need to be update on all levels
      FOR curAll IN curAllChildren LOOP

        FOR curCol IN c_ClassDenormCol(curAll.from_class_name, curAll.to_class_name, curAll.role_name) LOOP

          Ecdp_Dynsql.AddSqlLine(body_lines, '  EcTp_'||curAll.class_name||'.lockForUpdate('''||curCol.db_sql_syntax ||' = ''''''||p_vt(1).object_id||'''''''');' || chr(10))  ;

        END LOOP;

      END LOOP;


      Ecdp_Dynsql.AddSqlLine(body_lines,CHR(10)|| '  CallSyncChildren(l_vt);' || chr(10))  ;


   ELSE  -- Not part of group model

      Ecdp_Dynsql.AddSqlLine(body_lines, 'BEGIN' || chr(10))  ;
      Ecdp_Dynsql.AddSqlLine(body_lines, '  NULL;' || chr(10))  ;

   END IF; -- Part of group model


   Ecdp_Dynsql.AddSqlLine(body_lines, 'END SyncronizeChildren;' || chr(10) || chr(10)) ;






   Ecdp_Dynsql.AddSqlLine(body_lines,'------------------------------------------------------------------------------------------------------' || chr(10)) ;
   Ecdp_Dynsql.AddSqlLine(body_lines,'-- SyncronizeFromParent' || chr(10)) ;
   Ecdp_Dynsql.AddSqlLine(body_lines,'------------------------------------------------------------------------------------------------------' || chr(10)) ;




   Ecdp_Dynsql.AddSqlLine(body_lines, 'PROCEDURE SyncronizeFromParent(p_daytime date, p_end_date date, ' || chr(10));

   FOR curAll23 IN curAllDistChildren LOOP

     Ecdp_Dynsql.AddSqlLine(body_lines, '                               p_'||curAll23.db_sql_syntax||' VARCHAR2 default null, ' || chr(10));

   END LOOP;


   Ecdp_Dynsql.AddSqlLine(body_lines, '                               p_vt ver_tab_type)' || chr(10) || chr(10)) ;



   Ecdp_Dynsql.AddSqlLine(body_lines, 'IS' || chr(10) || chr(10))  ;

   IF  lb_partofgroupModel THEN


      Ecdp_Dynsql.AddSqlLine(body_lines, 'CURSOR c_versions IS' || chr(10)) ;
      Ecdp_Dynsql.AddSqlLine(body_lines, 'SELECT oa.* ' || chr(10)) ;

      FOR curVer20 IN ecdp_classMeta.c_classes(p_class_name) LOOP
        Ecdp_Dynsql.AddSqlLine(body_lines, 'FROM ' || curVer20.DB_OBJECT_ATTRIBUTE ||' oa, '||curVer20.DB_OBJECT_NAME||' o'|| chr(10));
        Ecdp_Dynsql.AddSqlLine(body_lines, 'WHERE oa.object_id = o.object_id AND daytime BETWEEN p_daytime and nvl(p_end_date,daytime)' || chr(10)) ;

        IF curVer20.db_where_condition IS NOT NULL THEN
          Ecdp_Dynsql.AddSqlLine(body_lines, 'AND '||curVer20.db_where_condition || chr(10)) ;
        END IF;

      END LOOP;




   lb_firsttime := TRUE;

   FOR curAll24 IN curAllDistChildren LOOP

      IF lb_firsttime THEN

        Ecdp_Dynsql.AddSqlLine(body_lines, 'AND ( nvl('||curAll24.db_sql_syntax ||',''NULL'') = Nvl(p_'||curAll24.db_sql_syntax||',''NOT_NULL'')' || chr(10));
        lb_firsttime := FALSE;

      ELSE

        Ecdp_Dynsql.AddSqlLine(body_lines, 'OR nvl('||curAll24.db_sql_syntax ||',''NULL'') = Nvl(p_'||curAll24.db_sql_syntax||',''NOT_NULL'')' || chr(10));

      END IF;

   END LOOP;

   IF NOT lb_firsttime THEN

      Ecdp_Dynsql.AddSqlLine(body_lines,')'||CHR(10));

   END IF;


   Ecdp_Dynsql.AddSqlLine(body_lines, '; ' || chr(10) || chr(10)) ;

   FOR curDistGroup IN CurAllDistinctClassGroupTypes LOOP

      Ecdp_Dynsql.AddSqlLine(body_lines, 'lb_upd'||curDistGroup.group_type||' VARCHAR2(1) := ''Y''; ' || chr(10) ) ;

   END LOOP;

   Ecdp_Dynsql.AddSqlLine(body_lines, 'lr  '||lv2_version_tablename||'%ROWTYPE; ' || chr(10) || chr(10)) ;

   -- Special case for well
   IF p_class_name = 'WELL' THEN

      Ecdp_Dynsql.AddSqlLine(body_lines, 'lv2_op_fcty_class_1_id VARCHAR2(32);' || chr(10));
      Ecdp_Dynsql.AddSqlLine(body_lines, 'lv2_op_fcty_class_2_id VARCHAR2(32);' || chr(10));
      Ecdp_Dynsql.AddSqlLine(body_lines, 'lv2_op_well_hookup_id  VARCHAR2(32);' || chr(10));

   END IF;

   Ecdp_Dynsql.AddSqlLine(body_lines,CHR(10)|| 'BEGIN' || chr(10)) ;


   Ecdp_Dynsql.AddSqlLine(body_lines, '  FOR curVer IN c_versions LOOP' || chr(10) || chr(10))  ;

   Ecdp_Dynsql.AddSqlLine(body_lines, '    FOR i IN 1..p_vt.count LOOP ' || chr(10) || chr(10))  ;

   Ecdp_Dynsql.AddSqlLine(body_lines, '      IF curver.daytime >= p_vt(i).daytime AND  curver.daytime <  Nvl(p_vt(i).end_date,curver.daytime+1) THEN ' || chr(10) || chr(10))  ;

   Ecdp_Dynsql.AddSqlLine(body_lines, '        lr := p_vt(i); ' || chr(10)) ;

   -- strip away replication rev text
   Ecdp_Dynsql.AddSqlLine(body_lines, '        lr.rev_text := replace(lr.rev_text,'''||lv2_new_revision||''' ); ' ||  chr(10))  ;
   Ecdp_Dynsql.AddSqlLine(body_lines, '        lr.rev_text := replace(lr.rev_text,'''||lv2_new_version||''' ); ' || chr(10) || chr(10))  ;


   -- Special case for well
   IF p_class_name = 'WELL' THEN

      lb_firsttime := TRUE;

      FOR curAll25 IN curAllDistChildren LOOP

       IF UPPER(curAll25.db_sql_syntax) IN ('OP_WELL_HOOKUP_ID','OP_FCTY_CLASS_1_ID','OP_FCTY_CLASS_2_ID') THEN

           IF lb_firsttime THEN
             Ecdp_Dynsql.AddSqlLine(body_lines, '        IF p_'||curAll25.db_sql_syntax||' IS not null ' || chr(10));
             lb_firsttime := FALSE;
           ELSE
             Ecdp_Dynsql.AddSqlLine(body_lines, '        OR p_'||curAll25.db_sql_syntax||' IS not null ' || chr(10));
           END IF;

        END IF;


      END LOOP;

      Ecdp_Dynsql.AddSqlLine(body_lines,'        THEN'||chr(10)||chr(10));

      -- Need to find if well_hookup is part of group model

      lb_wellhookup_inuse := FALSE;

      FOR curGroupWh IN c_grouprel_distinct_to('WELL_HOOKUP') LOOP
         lb_wellhookup_inuse := TRUE;
      END LOOP;

      IF lb_wellhookup_inuse THEN
        -- If the parent synchronisation context is facility and the current well object version also is associated to a operational hookup use the well hookup reference directly.
        Ecdp_Dynsql.AddSqlLine(body_lines,  '           IF p_OP_FCTY_CLASS_1_ID IS NOT NULL AND curver.op_well_hookup_id IS NOT NULL THEN' || chr(10));
        Ecdp_Dynsql.AddSqlLine(body_lines,  '              lv2_op_fcty_class_1_id := nvl(p_vt(i).op_fcty_class_1_id,curver.op_fcty_class_1_id);' || chr(10));
        Ecdp_Dynsql.AddSqlLine(body_lines,  '              lv2_op_fcty_class_2_id := nvl(p_vt(i).op_fcty_class_2_id,curver.op_fcty_class_2_id);' || chr(10));
        Ecdp_Dynsql.AddSqlLine(body_lines,  '              lv2_op_well_hookup_id := curver.op_well_hookup_id;' || chr(10));

        -- If the parent synchronisation context is well hookup and the current well object version also is associated to a operational facility use the facility references directly.
        Ecdp_Dynsql.AddSqlLine(body_lines,  '           ELSIF p_OP_WELL_HOOKUP_ID IS NOT NULL AND curver.op_fcty_class_1_id IS NOT NULL THEN' || chr(10));
        Ecdp_Dynsql.AddSqlLine(body_lines,  '              lv2_op_fcty_class_1_id := curver.op_fcty_class_1_id;' || chr(10));
        Ecdp_Dynsql.AddSqlLine(body_lines,  '              lv2_op_fcty_class_2_id := curver.op_fcty_class_2_id;' || chr(10));
        Ecdp_Dynsql.AddSqlLine(body_lines,  '              lv2_op_well_hookup_id := nvl(p_vt(i).op_well_hookup_id,curver.op_well_hookup_id);' || chr(10));

        Ecdp_Dynsql.AddSqlLine(body_lines,  '           ELSE ' || chr(10));
        Ecdp_Dynsql.AddSqlLine(body_lines,  '              lv2_op_fcty_class_1_id := nvl(EcDp_objects.ifDollarStr(lb_updoperational,p_vt(i).op_fcty_class_1_id,null),curver.op_fcty_class_1_id);' || chr(10));
        Ecdp_Dynsql.AddSqlLine(body_lines,  '              lv2_op_fcty_class_2_id := nvl(EcDp_objects.ifDollarStr(lb_updoperational,p_vt(i).op_fcty_class_2_id,null),curver.op_fcty_class_2_id);' || chr(10));
        Ecdp_Dynsql.AddSqlLine(body_lines,  '              lv2_op_well_hookup_id  := nvl(EcDp_objects.ifDollarStr(lb_updoperational,p_vt(i).op_well_hookup_id,null),curver.op_well_hookup_id);' || chr(10));

        Ecdp_Dynsql.AddSqlLine(body_lines,  '           END IF;' || chr(10) || chr(10));

      ELSE  -- WELL_HOOKUP is not part of group model

        Ecdp_Dynsql.AddSqlLine(body_lines,  '           lv2_op_fcty_class_1_id := nvl(p_vt(i).op_fcty_class_1_id,curver.op_fcty_class_1_id);' || chr(10));
        Ecdp_Dynsql.AddSqlLine(body_lines,  '           lv2_op_fcty_class_2_id := nvl(p_vt(i).op_fcty_class_2_id,curver.op_fcty_class_2_id);' || chr(10));
        Ecdp_Dynsql.AddSqlLine(body_lines,  '           lv2_op_well_hookup_id  := NULL;' || chr(10));


      END IF;

      FOR curWell1 IN c_ClassSpesific LOOP

        Ecdp_Dynsql.AddSqlLine(body_lines,  '           lr.'||curWell1.column_name ||' := ');
        Ecdp_Dynsql.AddSqlLine(body_lines,  ' EcDp_Node.getProcessingNode('''||curWell1.column_name||''',');
        Ecdp_Dynsql.AddSqlLine(body_lines,  ' curver.daytime, lv2_op_fcty_class_2_id, lv2_op_fcty_class_1_id, lv2_op_well_hookup_id, curver.alloc_flag, curver.well_type, curver.calc_co2_method, curver.gas_lift_method,curver.diluent_method);'|| CHR(10));


      END LOOP;

      Ecdp_Dynsql.AddSqlLine(body_lines,'        ELSE'||chr(10)||chr(10));

      FOR curWell2 IN c_ClassSpesific LOOP

        Ecdp_Dynsql.AddSqlLine(body_lines, '           lr.'||curWell2.column_name ||' := ');
        Ecdp_Dynsql.AddSqlLine(body_lines,  ' curver.'||curWell2.column_name||';' || CHR(10));

       END LOOP;


      Ecdp_Dynsql.AddSqlLine(body_lines,'        END IF;'||chr(10)||chr(10));


   END IF;

      FOR curSameParent IN c_sameparent LOOP  -- Must check if the current row is refering to this parent

         Ecdp_Dynsql.AddSqlLine(body_lines,'        IF p_'||curSameParent.db_sql_syntax||' is NOT NULL AND p_'||curSameParent.db_sql_syntax||' <> curver.'||curSameParent.db_sql_syntax||' THEN '||chr(10)||chr(10));
         Ecdp_Dynsql.AddSqlLine(body_lines,'          lr.'||curSameParent.db_sql_syntax||' := ''$$$$'';'||chr(10));
         Ecdp_Dynsql.AddSqlLine(body_lines,'          lr.'||REPLACE(curSameParent.db_sql_syntax,'_ID','_CODE')||' := ''$$$$'';'||chr(10) ||chr(10));
         Ecdp_Dynsql.AddSqlLine(body_lines,'        END IF;'||chr(10)||chr(10));


      END LOOP;


      Ecdp_Dynsql.AddSqlLine(body_lines, '        IF p_vt(i).end_date IS NOT NULL ' || chr(10))  ;
      Ecdp_Dynsql.AddSqlLine(body_lines, '           AND Nvl(Curver.end_date, p_vt(i).end_date+1) > p_vt(i).end_date THEN ' || chr(10) || chr(10))  ;

      Ecdp_Dynsql.AddSqlLine(body_lines, '           -- First update the current version, no need to check individual columns ' || chr(10) || chr(10))  ;


      -- make update and value list
      lv2_update_list := '           SET END_DATE = p_vt(i).end_date'||CHR(10);

      FOR curFP4C IN c_AllParentsColumns LOOP

        lv2_update_list := lv2_update_list || '           ,'||curFP4C.db_sql_syntax||' = EcDp_objects.ifDollarStr(lb_upd'||curFP4C.group_type||',lr.'||curFP4C.db_sql_syntax||','||curFP4C.db_sql_syntax||')' ||chr(10);
        lv2_update_list := lv2_update_list || '           ,'||REPLACE(curFP4C.db_sql_syntax,'_ID','_CODE')||' = EcDp_objects.ifDollarStr(lb_upd'||curFP4C.group_type||',lr.'||
                                                            REPLACE(curFP4C.db_sql_syntax,'_ID','_CODE')||','||REPLACE(curFP4C.db_sql_syntax,'_ID','_CODE')||')' ||chr(10);

      END LOOP;



      FOR curClassSpesific2 IN c_ClassSpesificDenormalised LOOP

         lv2_update_list := lv2_update_list ||  '           , '||curClassSpesific2.column_name||' = ';
         lv2_update_list := lv2_update_list ||  ' lr.'||curClassSpesific2.column_name||CHR(10);

      END LOOP;


      lv2_update_list := lv2_update_list ||'           ,last_updated_by = p_vt(i).last_updated_by, last_updated_date = p_vt(i).last_updated_date' || chr(10);
      lv2_update_list := lv2_update_list ||'           ,rev_no = rev_no + 1 ' || chr(10);
      lv2_update_list := lv2_update_list ||'           ,rev_text = '''||lv2_new_revision||'''|| nvl(lr.rev_text,'''')' || chr(10);


      Ecdp_Dynsql.AddSqlLine(body_lines, '           UPDATE ' || lv2_version_tablename || chr(10));
      Ecdp_Dynsql.AddSqlLine(body_lines, lv2_update_list);
      Ecdp_Dynsql.AddSqlLine(body_lines, '           WHERE object_id = curver.object_id '|| chr(10));
      Ecdp_Dynsql.AddSqlLine(body_lines, '           AND daytime = Curver.daytime; '|| chr(10) || chr(10));


     Ecdp_Dynsql.AddSqlLine(body_lines, chr(10)) ;


      lv2_column_list := 'object_id, daytime, end_date';
      lv2_value_list  := 'curver.object_id, p_vt(i).end_date, curver.end_date';

      -- IF contains class name then add that also

        FOR ClassesAttr3 IN EcDp_ClassMeta.c_classes_attr(p_class_name) LOOP

          IF ClassesAttr3.db_mapping_type = 'ATTRIBUTE' AND ClassesAttr3.attribute_name NOT IN ('DAYTIME','END_DATE','CREATED_BY','CREATED_DATE','LAST_UPDATED_BY','LAST_UPDATED_DATE','REV_NO','REV_TEXT','RECORD_STATUS') THEN

             lv2_column_list := lv2_column_list ||' ,'||ClassesAttr3.db_sql_syntax;
             lv2_value_list :=  lv2_value_list  ||' ,curver.'||ClassesAttr3.db_sql_syntax;

          END IF;

        END LOOP;


       FOR ClassesRel4a IN c_AllNonGroupRelColumns LOOP

           lv2_column_list := lv2_column_list || CHR(10) ||'           ,'||ClassesRel4a.db_sql_syntax ;
           lv2_value_list :=  lv2_value_list ||CHR(10)   ||'           , curver.'||ClassesRel4a.db_sql_syntax;


       END LOOP;



        FOR ClassesRel4 IN c_AllParentsColumns LOOP

           lv2_column_list := lv2_column_list || CHR(10) ||'           ,'||ClassesRel4.db_sql_syntax || ' ,'||REPLACE(ClassesRel4.db_sql_syntax,'_ID','_CODE');
           lv2_value_list :=  lv2_value_list ||CHR(10)   ||'           , curver.'||ClassesRel4.db_sql_syntax||
                                                    ' ,EcDp_objects.ifDollarStr(lb_upd'||ClassesRel4.group_type||',lr.'||REPLACE(ClassesRel4.db_sql_syntax,'_ID','_CODE')||',curver.'||REPLACE(ClassesRel4.db_sql_syntax,'_ID','_CODE')||')';

       END LOOP;

       lv2_column_list := lv2_column_list||CHR(10) ||  '            ';
       lv2_value_list := lv2_value_list ||CHR(10) ||   '            ';


       FOR curClassSpesific3 IN c_ClassSpesificDenormalised LOOP

         lv2_column_list := lv2_column_list||' ,'||curClassSpesific3.column_name;
         lv2_value_list := lv2_value_list ||' ,lr.'||curClassSpesific3.column_name;

       END LOOP;


       lv2_column_list := lv2_column_list ||'           ,CREATED_BY,CREATED_DATE,REV_TEXT,RECORD_STATUS';
       lv2_value_list :=  lv2_value_list  ||'           ,p_vt(i).LAST_UPDATED_BY, p_vt(i).LAST_UPDATED_DATE, '''||lv2_new_version||'''||lr.REV_TEXT, p_vt(i).RECORD_STATUS ';



      Ecdp_Dynsql.AddSqlLine(body_lines, '           INSERT INTO ' || lv2_version_tablename ||' ('|| chr(10));


      Ecdp_Dynsql.AddSqlLine(body_lines, '           '|| lv2_column_list ||')'|| chr(10));
      Ecdp_Dynsql.AddSqlLine(body_lines, '           VALUES('|| lv2_value_list ||');'|| chr(10) || chr(10));


      Ecdp_Dynsql.AddSqlLine(body_lines,CHR(10));

      Ecdp_Dynsql.AddSqlLine(body_lines, '        ELSE -- No version splitting needed for this  ' || chr(10) || chr(10))  ;

      Ecdp_Dynsql.AddSqlLine(body_lines, '           -- check if we need to do an update  ' || chr(10) || chr(10))  ;

      lb_firsttime := TRUE;


       Ecdp_Dynsql.AddSqlLine(body_lines,CHR(10));


      FOR curFP5b IN c_AllParentsColumns LOOP

        IF lb_firsttime THEN

          Ecdp_Dynsql.AddSqlLine(body_lines, '           IF nvl(curver.'||curFP5b.db_sql_syntax||',''NULL'') <> nvl(EcDp_objects.ifDollarStr(lb_upd'||curFP5b.group_type||',lr.'||curFP5b.db_sql_syntax||',curver.'||curFP5b.db_sql_syntax||'),''NULL'')'|| chr(10));
          lb_firsttime := FALSE;


        ELSE

          Ecdp_Dynsql.AddSqlLine(body_lines, '           OR nvl(curver.'||curFP5b.db_sql_syntax||',''NULL'') <> nvl(EcDp_objects.ifDollarStr(lb_upd'||curFP5b.group_type||',lr.'||curFP5b.db_sql_syntax||',curver.'||curFP5b.db_sql_syntax||'),''NULL'')'|| chr(10));

        END IF;

        Ecdp_Dynsql.AddSqlLine(body_lines, '           OR nvl(curver.'||REPLACE(curFP5b.db_sql_syntax,'_ID','_CODE')||',''NULL'') <> nvl(EcDp_objects.ifDollarStr(lb_upd'||curFP5b.group_type||',lr.'||REPLACE(curFP5b.db_sql_syntax,'_ID','_CODE')||',curver.'||REPLACE(curFP5b.db_sql_syntax,'_ID','_CODE')||'),''NULL'')'|| chr(10));


      END LOOP;



      -- Special case for well
      FOR curClassSpesific5 IN c_ClassSpesificDenormalised LOOP

          IF NOT lb_firsttime THEN
             Ecdp_Dynsql.AddSqlLine(body_lines, '           OR nvl(curver.'||curClassSpesific5.column_name||',''NULL'') <> Nvl(lr.'||curClassSpesific5.column_name||',''NULL'')'|| chr(10));
          ELSE
             Ecdp_Dynsql.AddSqlLine(body_lines, '           IF nvl(curver.'||curClassSpesific5.column_name||',''NULL'') <> Nvl(lr.'||curClassSpesific5.column_name||',''NULL'')'|| chr(10));
             lb_firsttime := FALSE;
          END IF;

       END LOOP;



      IF  NOT lb_firsttime THEN

        Ecdp_Dynsql.AddSqlLine(body_lines, '           THEN '|| chr(10) || chr(10));


        lb_firsttime := TRUE;
        lv2_update_list := '';


         FOR curFP3b IN c_AllParentsColumns LOOP

           IF lb_firsttime THEN

              lv2_update_list := lv2_update_list || '             SET '||curFP3b.db_sql_syntax||' = EcDp_objects.ifDollarStr(lb_upd'||curFP3b.group_type||',lr.'||curFP3b.db_sql_syntax||','||curFP3b.db_sql_syntax||')'|| chr(10);
              lv2_update_list := lv2_update_list || '             , '||REPLACE(curFP3b.db_sql_syntax,'_ID','_CODE')||' = EcDp_objects.ifDollarStr(lb_upd'||curFP3b.group_type||',lr.'||
                                                                       REPLACE(curFP3b.db_sql_syntax,'_ID','_CODE')|| ','||REPLACE(curFP3b.db_sql_syntax,'_ID','_CODE')||')'|| chr(10);
              lb_firsttime := FALSE;


           ELSE

              lv2_update_list := lv2_update_list || '             ,'||curFP3b.db_sql_syntax||' = EcDp_objects.ifDollarStr(lb_upd'||curFP3b.group_type||',p_vt(i).'||curFP3b.db_sql_syntax||','||curFP3b.db_sql_syntax||')'|| chr(10);
              lv2_update_list := lv2_update_list || '             , '||REPLACE(curFP3b.db_sql_syntax,'_ID','_CODE')||' = EcDp_objects.ifDollarStr(lb_upd'||curFP3b.group_type||',p_vt(i).'||
                                                                       REPLACE(curFP3b.db_sql_syntax,'_ID','_CODE')|| ','||REPLACE(curFP3b.db_sql_syntax,'_ID','_CODE')||')'|| chr(10);

           END IF;

         END LOOP;

         FOR curClassSpesific6 IN c_ClassSpesificDenormalised LOOP

            IF NOT lb_firsttime THEN

               lv2_update_list := lv2_update_list ||  '             , '||curClassSpesific6.column_name||' = lr.'||curClassSpesific6.column_name||CHR(10);

            ELSE

               lv2_update_list := lv2_update_list ||  '             SET '||curClassSpesific6.column_name||' = lr.'||curClassSpesific6.column_name||CHR(10);
              lb_firsttime := FALSE;


            END IF;

         END LOOP;



         IF NOT lb_firsttime THEN
            lv2_update_list := lv2_update_list || '             ,last_updated_by = p_vt(i).last_updated_by, last_updated_date = p_vt(i).last_updated_date'||chr(10);
         ELSE
            lv2_update_list := lv2_update_list || '             set last_updated_by = p_vt(i).last_updated_by, last_updated_date = p_vt(i).last_updated_date'||chr(10);
            lb_firsttime := FALSE;

         END IF;

         lv2_update_list := lv2_update_list|| '             ,rev_no = rev_no + 1 , rev_text = '''||lv2_new_revision||'''|| nvl(lr.rev_text,'''')';




         Ecdp_Dynsql.AddSqlLine(body_lines, '             UPDATE ' || lv2_version_tablename || chr(10));
         Ecdp_Dynsql.AddSqlLine(body_lines, lv2_update_list || chr(10));

         Ecdp_Dynsql.AddSqlLine(body_lines, '             WHERE object_id = curver.object_id '|| chr(10));
         Ecdp_Dynsql.AddSqlLine(body_lines, '             AND daytime = Curver.daytime; '|| chr(10) || chr(10));





        Ecdp_Dynsql.AddSqlLine(body_lines, '          END IF; -- IF nvl(curver.... ' || chr(10) || chr(10))  ;



        Ecdp_Dynsql.AddSqlLine(body_lines,CHR(10));



      ELSE

       Ecdp_Dynsql.AddSqlLine(body_lines,'           NULL;'||CHR(10));

      END IF;



      Ecdp_Dynsql.AddSqlLine(body_lines, '        END IF; -- p_vt(i).end_date IS NOT NULL ' || chr(10)|| chr(10))  ;


      Ecdp_Dynsql.AddSqlLine(body_lines, '      END IF; -- curver.daytime BETWEEN .. ' || chr(10) || chr(10))  ;


      Ecdp_Dynsql.AddSqlLine(body_lines, '    END LOOP; -- p_vt ' || chr(10) || chr(10))  ;

      Ecdp_Dynsql.AddSqlLine(body_lines, '  END LOOP; -- curVer' || chr(10) || chr(10))  ;


   ELSE  -- Not part of group model

      Ecdp_Dynsql.AddSqlLine(body_lines, 'BEGIN' || chr(10))  ;
      Ecdp_Dynsql.AddSqlLine(body_lines, '  NULL;' || chr(10))  ;

   END IF; -- Part of group model



   Ecdp_Dynsql.AddSqlLine(body_lines, 'END SyncronizeFromParent; ' || chr(10) || chr(10)) ;


   Ecdp_Dynsql.AddSqlLine(body_lines,'------------------------------------------------------------------------------------------------------' || chr(10)) ;
   Ecdp_Dynsql.AddSqlLine(body_lines,'-- lockForUpdate' || chr(10)) ;
   Ecdp_Dynsql.AddSqlLine(body_lines,'------------------------------------------------------------------------------------------------------' || chr(10)) ;



   Ecdp_Dynsql.AddSqlLine(body_lines, 'PROCEDURE lockForUpdate(p_where VARCHAR2)' || chr(10))  ;
   Ecdp_Dynsql.AddSqlLine(body_lines, 'IS' || chr(10) || chr(10)) ;

   Ecdp_Dynsql.AddSqlLine(body_lines, '  lv2_sql2 varchar2(1000) := ''select * from '||lv2_version_tablename||' where '' || p_where|| '' for update nowait'';' || chr(10) || chr(10)) ;

   Ecdp_Dynsql.AddSqlLine(body_lines, 'BEGIN' || chr(10))  ;
   Ecdp_Dynsql.AddSqlLine(body_lines, '   execute immediate lv2_sql2;' || chr(10))  ;
   Ecdp_Dynsql.AddSqlLine(body_lines, 'END lockForUpdate; ' || chr(10)|| chr(10))  ;


      Ecdp_Dynsql.AddSqlLine(body_lines,'------------------------------------------------------------------------------------------------------' || chr(10)) ;
      Ecdp_Dynsql.AddSqlLine(body_lines,'-- ExtendFilledRow' || chr(10)) ;
      Ecdp_Dynsql.AddSqlLine(body_lines,'------------------------------------------------------------------------------------------------------' || chr(10)) ;


      Ecdp_Dynsql.AddSqlLine(body_lines, 'PROCEDURE ExtendFilledRow( p_vt IN OUT ECTP_'||p_class_name||'.ver_tab_type)' || chr(10) || chr(10)) ;

      Ecdp_Dynsql.AddSqlLine(body_lines, 'IS' || chr(10) || chr(10))  ;



      Ecdp_Dynsql.AddSqlLine(body_lines,chr(10)|| 'BEGIN' || chr(10) || chr(10)) ;

      Ecdp_Dynsql.AddSqlLine(body_lines,chr(10)|| '  p_vt.EXTEND;' || chr(10) || chr(10)) ;


           FOR curParentEFR IN  c_AllParentsColumns LOOP

             Ecdp_Dynsql.AddSqlLine(body_lines,'  p_vt(p_vt.last).'||curParentEFR.db_sql_syntax||' := ''$$$$'';' || chr(10)) ;
             Ecdp_Dynsql.AddSqlLine(body_lines,'  p_vt(p_vt.last).'||REPLACE(curParentEFR.db_sql_syntax,'_ID','_CODE')||' := ''$$$$'';' || chr(10)) ;

           END LOOP; --curParent

      Ecdp_Dynsql.AddSqlLine(body_lines, chr(10)) ;


      Ecdp_Dynsql.AddSqlLine(body_lines,chr(10)|| 'END ExtendFilledRow;' || chr(10) || chr(10)) ;



      Ecdp_Dynsql.AddSqlLine(body_lines,'------------------------------------------------------------------------------------------------------' || chr(10)) ;
      Ecdp_Dynsql.AddSqlLine(body_lines,'-- CallSyncChildren' || chr(10)) ;
      Ecdp_Dynsql.AddSqlLine(body_lines,'------------------------------------------------------------------------------------------------------' || chr(10)) ;




      Ecdp_Dynsql.AddSqlLine(body_lines, 'PROCEDURE CallSyncChildren( p_vt ECTP_'||p_class_name||'.ver_tab_type,p_direct_only varchar2 default NULL)' || chr(10) || chr(10)) ;



      Ecdp_Dynsql.AddSqlLine(body_lines, 'IS' || chr(10) || chr(10))  ;


      -- Need all children here

       FOR curFP3 IN curAllDistinctChildren LOOP

          Ecdp_Dynsql.AddSqlLine(body_lines, '  lvt_'||curFP3.class_name||' ECTP_'||curFP3.class_name||'.ver_tab_type');
          Ecdp_Dynsql.AddSqlLine(body_lines, '  :=  ECTP_'||curFP3.class_name||'.ver_tab_type();' || chr(10))  ;

       END LOOP;

      Ecdp_Dynsql.AddSqlLine(body_lines, '  lv2_object_code '||lv2_main_tablename||'.OBJECT_CODE%TYPE;'||  chr(10));

      Ecdp_Dynsql.AddSqlLine(body_lines,chr(10)|| 'BEGIN' || chr(10) || chr(10)) ;

      Ecdp_Dynsql.AddSqlLine(body_lines, '  lv2_object_code := Ec_'||lv2_main_tablename||'.object_code(p_vt(1).object_id);' || chr(10) || chr(10))  ;

      Ecdp_Dynsql.AddSqlLine(body_lines, '   FOR i IN 1..p_vt.count LOOP ' || chr(10) || chr(10))  ;

      Ecdp_Dynsql.AddSqlLine(body_lines, '     NULL; -- To avoid error when no children ' || chr(10) || chr(10))  ;



      FOR curFP5d IN curAllDistinctChildren LOOP

           lv2_vt_name := 'lvt_'||curFP5d.class_name;

           Ecdp_Dynsql.AddSqlLine(body_lines, '           ECTP_'||curFP5d.class_name||'.ExtendFilledRow('||lv2_vt_name||'); '|| chr(10)) ;

           -- object_id intentionally left blank
           Ecdp_Dynsql.AddSqlLine(body_lines,'           '||lv2_vt_name||'(i).daytime := p_vt(i).daytime;' || chr(10)) ;
           Ecdp_Dynsql.AddSqlLine(body_lines,'           '||lv2_vt_name||'(i).end_date := p_vt(i).end_date;' || chr(10)) ;
           Ecdp_Dynsql.AddSqlLine(body_lines,'           '||lv2_vt_name||'(i).created_by := p_vt(i).created_by;' || chr(10)) ;
           Ecdp_Dynsql.AddSqlLine(body_lines,'           '||lv2_vt_name||'(i).created_date := p_vt(i).created_date;' || chr(10)) ;
           Ecdp_Dynsql.AddSqlLine(body_lines,'           '||lv2_vt_name||'(i).last_updated_by := p_vt(i).last_updated_by;' || chr(10)) ;
           Ecdp_Dynsql.AddSqlLine(body_lines,'           '||lv2_vt_name||'(i).last_updated_date := p_vt(i).last_updated_date;' || chr(10)) ;
           Ecdp_Dynsql.AddSqlLine(body_lines,'           '||lv2_vt_name||'(i).rev_text := p_vt(i).rev_text;' || chr(10)) ;

           -- Now it gets a bit tricky here want to include the current level, but dont know what it is called or how many times
           -- it is called, so first find out how many group models this level is involved in.


           FOR curGRoupLevelType IN  c_GRoupLevelType(curFP5d.class_name) LOOP


                 -- direct parent
                 Ecdp_Dynsql.AddSqlLine(body_lines,'           '||lv2_vt_name||'(i).'||curGRoupLevelType.db_sql_syntax||' := p_vt(i).object_id;' || chr(10)) ;
                 Ecdp_Dynsql.AddSqlLine(body_lines,'           '||lv2_vt_name||'(i).'||REPLACE(curGRoupLevelType.db_sql_syntax,'_ID','_CODE')||' :=  lv2_object_code;' || chr(10)) ;


           END LOOP;



           FOR curParent IN  curAllDistinctParents(p_class_name,curFP5d.class_name) LOOP

             Ecdp_Dynsql.AddSqlLine(body_lines,'           '||lv2_vt_name||'(i).'||curParent.db_sql_syntax||' := p_vt(i).'||curParent.db_sql_syntax||';' || chr(10)) ;
             Ecdp_Dynsql.AddSqlLine(body_lines,'           '||lv2_vt_name||'(i).'||REPLACE(curParent.db_sql_syntax,'_ID','_CODE')||' := p_vt(i).'||REPLACE(curParent.db_sql_syntax,'_ID','_CODE')||';' || chr(10)) ;

           END LOOP; --curParent

           Ecdp_Dynsql.AddSqlLine(body_lines, chr(10)) ;



     END LOOP;

     Ecdp_Dynsql.AddSqlLine(body_lines,'   END LOOP;'|| chr(10) || chr(10)) ;



   -- Now ask child class to do the rest of the job

   FOR curFPChilds2 IN curAllDistinctChildren LOOP


     lb_directchild := FALSE;
     -- Check if this is a direct child
     FOR curChildDirect IN c_directchild(p_class_name, curFPChilds2.class_name) LOOP

       lb_directchild := TRUE;

     END LOOP;


     IF NOT lb_directchild THEN

        Ecdp_Dynsql.AddSqlLine(body_lines, CHR(10)|| '   IF nvl(p_direct_only,''N'') = ''N'' THEN' || chr(10))  ;

     END IF;


      lv2_vt_name := 'lvt_'||curFPChilds2.class_name;
      Ecdp_Dynsql.AddSqlLine(body_lines, CHR(10)|| '         ECTP_'||curFPChilds2.class_name||'.SyncronizeFromParent('||lv2_vt_name||'(1).daytime,'||lv2_vt_name||'('||lv2_vt_name||'.last).end_date,' || chr(10))  ;



     FOR curGRoupLevelType IN  c_GRoupLevelType(curFPChilds2.class_name) LOOP

           Ecdp_Dynsql.AddSqlLine(body_lines, '                                p_'||curGRoupLevelType.db_sql_syntax||' =>  p_vt(1).object_id, '|| chr(10));

     END LOOP;


       Ecdp_Dynsql.AddSqlLine(body_lines, '                                p_vt => '||lv2_vt_name||'); '|| chr(10));
       Ecdp_Dynsql.AddSqlLine(body_lines, chr(10) || chr(10))  ;

     IF NOT lb_directchild THEN

        Ecdp_Dynsql.AddSqlLine(body_lines, '   END IF; -- nvl(p_direct_only,''N'') = ''N'' ' || chr(10))  ;

     END IF;



   END LOOP;


   Ecdp_Dynsql.AddSqlLine(body_lines, '  END CallSyncChildren; ' || chr(10) || chr(10)) ;

   Ecdp_Dynsql.AddSqlLine(body_lines,'------------------------------------------------------------------------------------------------------' || chr(10)) ;
   Ecdp_Dynsql.AddSqlLine(body_lines,'-- SetObjStartDate' || chr(10)) ;
   Ecdp_Dynsql.AddSqlLine(body_lines,'------------------------------------------------------------------------------------------------------' || chr(10)) ;
  Ecdp_Dynsql.AddSqlLine(body_lines,'FUNCTION SetObjStartDate(p_vt               ver_tab_type,'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'                         p_object_id         VARCHAR2,'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'                         p_daytime           DATE,'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'                         p_last_updated_by   VARCHAR2 DEFAULT USER,'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'                         p_last_updated_date DATE DEFAULT EcDp_Date_Time.GetCurrentSysDate)'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'RETURN ver_tab_type'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'IS'||CHR(10)||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'   CURSOR c_obsolete_ver_rows IS'||CHR(10));
  IF lb_approval_enabled THEN
    Ecdp_Dynsql.AddSqlLine(body_lines,'    SELECT object_id,daytime,approval_state,rec_id,end_date'||CHR(10));
  ELSE
    Ecdp_Dynsql.AddSqlLine(body_lines,'    SELECT object_id,daytime'||CHR(10));
  END IF;
  Ecdp_Dynsql.AddSqlLine(body_lines,'    FROM '||LOWER(lv2_version_tablename)||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'    WHERE object_id = p_object_id'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'    AND   end_date <= p_daytime;'||CHR(10)||CHR(10));

  Ecdp_Dynsql.AddSqlLine(body_lines,'   CURSOR c_version_row(cp_object_id VARCHAR2, cp_old_start_date DATE, cp_new_start_date DATE) IS'||CHR(10));
  IF lb_approval_enabled THEN
    Ecdp_Dynsql.AddSqlLine(body_lines,'    SELECT daytime,approval_state,rec_id,end_date'||CHR(10));
  ELSE
    Ecdp_Dynsql.AddSqlLine(body_lines,'    SELECT daytime'||CHR(10));
  END IF;
  Ecdp_Dynsql.AddSqlLine(body_lines,'    FROM '||LOWER(lv2_version_tablename)||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'    WHERE object_id = p_object_id'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'    AND (daytime = cp_old_start_date'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'    OR(daytime < cp_new_start_date AND cp_new_start_date < NVL(end_date,cp_new_start_date + 1)))'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'    FOR UPDATE;'||CHR(10)||CHR(10));

  Ecdp_Dynsql.AddSqlLine(body_lines,'   l_vt                  ver_tab_type := ver_tab_type();'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'   ln_counter            NUMBER := 0;'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'   ld_start_date         DATE := Ec_'||lv2_main_tablename||'.start_date(p_object_id);'||chr(10)||CHR(10));
  IF lb_approval_enabled THEN
    Ecdp_Dynsql.AddSqlLine(body_lines,'   lv2_rec_id          VARCHAR2(32);'||CHR(10));
  END IF;

  Ecdp_Dynsql.AddSqlLine(body_lines,'BEGIN'||CHR(10)||CHR(10));

  Ecdp_Dynsql.AddSqlLine(body_lines,'   IF p_daytime = ld_start_date THEN -- no changes, simply return'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'      RETURN p_vt;'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'   END IF;'||CHR(10)||CHR(10));

  Ecdp_Dynsql.AddSqlLine(body_lines,'   -- Delete all obsolete version entries'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'   IF p_daytime > ld_start_date THEN'||CHR(10)||CHR(10));

  Ecdp_Dynsql.AddSqlLine(body_lines,'      FOR curVerRow IN c_obsolete_ver_rows LOOP'||CHR(10)||CHR(10));

  IF lb_approval_enabled THEN

    Ecdp_Dynsql.AddSqlLine(body_lines,'         IF curVerRow.Approval_State=''N'' THEN'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'           DELETE FROM '||LOWER(lv2_version_tablename)||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'           WHERE object_id = curVerRow.object_id'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'           AND daytime = curVerRow.daytime;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         ELSE'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'           lv2_rec_id := Nvl(curVerRow.rec_id, SYS_GUID());'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'           UPDATE '||LOWER(lv2_version_tablename)||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'           SET    last_updated_by = p_last_updated_by'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'           ,      last_updated_date = p_last_updated_date'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'           ,      approval_state = ''D'''||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'           ,      approval_by = null'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'           ,      approval_date = null'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'           ,      rec_id = lv2_rec_id'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'           ,      rev_no = Nvl(rev_no,0) + 1'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'           WHERE object_id = curVerRow.object_id'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'           AND daytime = curVerRow.daytime;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'           Ecdp_Approval.registerTaskDetail(lv2_rec_id,'''||p_class_name||''',p_last_updated_by);'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'           END IF;'||CHR(10));

  ELSE

    Ecdp_Dynsql.AddSqlLine(body_lines,'         DELETE FROM '||LOWER(lv2_version_tablename)||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         WHERE object_id = curVerRow.object_id'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         AND daytime = curVerRow.daytime;'||CHR(10)||CHR(10));

  END IF;

  Ecdp_Dynsql.AddSqlLine(body_lines,'      END LOOP;'||CHR(10)||CHR(10));

  Ecdp_Dynsql.AddSqlLine(body_lines,'   END IF;'||CHR(10)||CHR(10));

  Ecdp_Dynsql.AddSqlLine(body_lines,'   ln_counter := 0;'||CHR(10)||CHR(10));

  Ecdp_Dynsql.AddSqlLine(body_lines,'   -- Copy version array, exclude obsolete versions'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'   FOR i IN 1..p_vt.Count LOOP'||CHR(10)||CHR(10));

  Ecdp_Dynsql.AddSqlLine(body_lines,'      IF nvl(p_vt(i).end_date,p_daytime + 1) > p_daytime THEN'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'         l_vt.extend;'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'         ln_counter := ln_counter + 1;'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'         l_vt(ln_counter) := p_vt(i);'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'      END IF;'||CHR(10)||CHR(10));

  Ecdp_Dynsql.AddSqlLine(body_lines,'   END LOOP;'||CHR(10)||CHR(10));

  Ecdp_Dynsql.AddSqlLine(body_lines,'   EcDp_User_Session.SetUserSessionParameter(''JN_NOTES'',''COMMON'');'||CHR(10)||CHR(10));

  Ecdp_Dynsql.AddSqlLine(body_lines,'   -- update daytime of related attributes'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'   FOR curVerRow2 IN c_version_row(p_object_id,ld_start_date,p_daytime) LOOP'||CHR(10)||CHR(10));

  IF lb_approval_enabled THEN

    Ecdp_Dynsql.AddSqlLine(body_lines,'      IF Nvl(curVerRow2.end_date,p_daytime+1)>p_daytime THEN'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'        lv2_rec_id := Nvl(curVerRow2.rec_id, SYS_GUID());'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'        UPDATE '||LOWER(lv2_version_tablename)||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'        SET daytime = p_daytime,'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'        rev_no = nvl(rev_no,0) + 1,'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'        last_updated_by = p_last_updated_by,'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'        last_updated_date = p_last_updated_date,'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'        approval_state = DECODE(approval_state, ''N'', ''N'', ''U''),'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'        approval_by = null,'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'        approval_date = null,'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'        rec_id = lv2_rec_id'||CHR(10));

    Ecdp_Dynsql.AddSqlLine(body_lines,'        WHERE CURRENT OF c_version_row;'||CHR(10));

    Ecdp_Dynsql.AddSqlLine(body_lines,'        Ecdp_Approval.registerTaskDetail(lv2_rec_id,'''||p_class_name||''',p_last_updated_by);'||CHR(10));

  ELSE

    Ecdp_Dynsql.AddSqlLine(body_lines,'      UPDATE '||LOWER(lv2_version_tablename)||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      SET daytime = p_daytime,'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      rev_no = nvl(rev_no,0) + 1,'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      last_updated_by = p_last_updated_by,'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      last_updated_date = p_last_updated_date'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      WHERE CURRENT OF c_version_row;'||CHR(10)||CHR(10));

  END IF;

  Ecdp_Dynsql.AddSqlLine(body_lines,'        FOR k IN 1..l_vt.COUNT LOOP'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'          IF l_vt(k).daytime = curVerRow2.daytime THEN'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'             l_vt(k).daytime := p_daytime;'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'          END IF;'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'        END LOOP;'||CHR(10)||CHR(10));

  IF lb_approval_enabled THEN
    Ecdp_Dynsql.AddSqlLine(body_lines,'      END IF;'||CHR(10));
  END IF;

  Ecdp_Dynsql.AddSqlLine(body_lines,'   END LOOP;'||CHR(10)||CHR(10));

  Ecdp_Dynsql.AddSqlLine(body_lines,'   -- update start date on object'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'   UPDATE '||LOWER(lv2_main_tablename)||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'   set start_date = p_daytime,'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'   rev_no = nvl(rev_no,0) + 1,'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'   last_updated_date = p_last_updated_date,'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'   last_updated_by = p_last_updated_by'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'   WHERE object_id = p_object_id;'||CHR(10)||CHR(10));

  Ecdp_Dynsql.AddSqlLine(body_lines,'   -- Alignparent version if moving back in time'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'   IF p_daytime < ld_start_date THEN'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'      NULL;'||CHR(10));

  FOR curGroupRel IN c_group_relations LOOP

    Ecdp_Dynsql.AddSqlLine(body_lines,'      l_vt := EcTp_'||p_class_name||'.AlignParentVersions(l_vt,'''||curGroupRel.group_type||''');'||CHR(10));

  END LOOP;

  Ecdp_Dynsql.AddSqlLine(body_lines,'   END IF;'||CHR(10)||CHR(10));

  Ecdp_Dynsql.AddSqlLine(body_lines,'   RETURN l_vt;'||CHR(10)||CHR(10));

  Ecdp_Dynsql.AddSqlLine(body_lines,'END SetObjStartDate;'||CHR(10)||CHR(10));

  Ecdp_Dynsql.AddSqlLine(body_lines,'------------------------------------------------------------------------------------------------------' || chr(10)) ;
  Ecdp_Dynsql.AddSqlLine(body_lines,'-- SetObjEndDate' || chr(10)) ;
  Ecdp_Dynsql.AddSqlLine(body_lines,'------------------------------------------------------------------------------------------------------' || chr(10)) ;
  Ecdp_Dynsql.AddSqlLine(body_lines,'FUNCTION SetObjEndDate(p_vt                ver_tab_type,'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'                       p_object_id         VARCHAR2,'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'                       p_end_date          DATE,'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'                       p_last_updated_by   VARCHAR2 DEFAULT USER,'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'                       p_last_updated_date DATE DEFAULT EcDp_Date_Time.GetCurrentSysDate,'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'                       p_rev_text          VARCHAR2)'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'RETURN ver_tab_type'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'IS'||CHR(10)||CHR(10));


  -- Build cursors to loop children
  ln_union_count := 0;
  ln_class_count := 0;
  EcDp_Objects_check.AddChildEndDateCursor(body_lines,p_class_name,ln_union_count,0,ln_class_count);

  IF lb_approval_enabled THEN
    Ecdp_Dynsql.AddSqlLine(body_lines,'   CURSOR c_version_row(cp_object_id VARCHAR2) IS'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'    SELECT daytime,approval_state,rec_id,end_date'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'    FROM '||LOWER(lv2_version_tablename)||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'    WHERE object_id = p_object_id'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'    FOR UPDATE;'||CHR(10)||CHR(10));
  END IF;

  Ecdp_Dynsql.AddSqlLine(body_lines,'   ld_start_date      DATE := Ec_'||lv2_main_tablename||'.Start_Date(p_object_id);'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'   ld_old_end_date    DATE := Ec_'||lv2_main_tablename||'.End_Date(p_object_id);'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'   l_vt               ver_tab_type := ver_tab_type();'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'   ln_counter         NUMBER := 0;'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'   lv2_rec_id         VARCHAR2(32);'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'   ln_version_counter NUMBER := 0;'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'   lv2_approval_state VARCHAR2(1);'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'   lv2_session_param  VARCHAR2(200);'||CHR(10));

  Ecdp_Dynsql.AddSqlLine(body_lines,'BEGIN'||CHR(10)||CHR(10));

  Ecdp_Dynsql.AddSqlLine(body_lines,'   IF (ld_old_end_date IS NULL AND p_end_date IS NULL) OR'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'      (ld_old_end_date = p_end_date) THEN -- no changes, simply return'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'      RETURN p_vt;'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'   END IF;'||CHR(10)||CHR(10));

  -- add end date child checks
  EcDp_Objects_check.AddChildEndDateCheck (body_lines, ln_union_count);


  Ecdp_Dynsql.AddSqlLine(body_lines,'   -- Delete object if end_date = start_date'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'   IF p_end_date = ld_start_date  THEN'||CHR(10)||CHR(10));

  Ecdp_Dynsql.AddSqlLine(body_lines,'      IF EcDp_ClassMeta.IsReadOnlyClass('''||p_class_name||''') = ''Y'' THEN'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'         Raise_Application_Error(-20102,''Cannot delete ''||Ec_'||lv2_main_tablename||'.object_code(p_object_id)||'' because the class '||p_class_name||' is defined as read only'');'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'      END IF;'||CHR(10)||CHR(10));

  IF lb_approval_enabled THEN
    Ecdp_Dynsql.AddSqlLine(body_lines,'      FOR curVerRow IN c_version_row(p_object_id) LOOP'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'        IF curVerRow.Approval_State=''N'' THEN'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          DELETE FROM '||LOWER(lv2_version_tablename)||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          WHERE object_id = p_object_id'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          AND   daytime = curVerRow.daytime;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          Ecdp_Approval.deleteTaskDetail(curVerRow.rec_id);'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'        ELSE'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          lv2_rec_id := Nvl(curVerRow.rec_id, SYS_GUID());'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          UPDATE '||LOWER(lv2_version_tablename)||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          SET    last_updated_by = p_last_updated_by'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          ,      last_updated_date = p_last_updated_date'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          ,      approval_state = ''D'''||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          ,      approval_by = null'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          ,      approval_date = null'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          ,      rec_id = lv2_rec_id'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          ,      rev_text = p_rev_text'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          ,      rev_no = nvl(rev_no,0) + 1'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          WHERE object_id = p_object_id'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          AND daytime = curVerRow.daytime;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          Ecdp_Approval.registerTaskDetail(lv2_rec_id,'''||p_class_name||''',p_last_updated_by);          '||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'        END IF;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      END LOOP;'||CHR(10));

    Ecdp_Dynsql.AddSqlLine(body_lines,'      SELECT COUNT(*) INTO ln_version_counter FROM '||LOWER(lv2_version_tablename)||' WHERE object_id=p_object_id;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      IF ln_version_counter=0 THEN'||CHR(10));

    --NOTYET Do we need to handle smart journaling here ?

    Ecdp_Dynsql.AddSqlLine(body_lines,'        DELETE FROM '||LOWER(lv2_main_tablename)||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'        WHERE object_id = p_object_id;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'        EcDp_ACL.RefreshObject(p_object_id,'''||p_class_name||''', ''DELETING'');'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      END IF;'||CHR(10));

  ELSE

    Ecdp_Dynsql.AddSqlLine(body_lines,'      EcDp_ACL.RefreshObject(p_object_id, '''||p_class_name||''', ''DELETING'');'||CHR(10));


    Ecdp_Dynsql.AddSqlLine(body_lines,'      -- Force an update to store the rev_text'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      EcDp_User_Session.SetUserSessionParameter(''JN_NOTES'',''COMMON'');'||CHR(10)||CHR(10));

    Ecdp_Dynsql.AddSqlLine(body_lines,'      update '||LOWER(lv2_version_tablename)||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      set rev_text = p_rev_text,'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          rev_no = rev_no+1,'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          last_updated_by = p_last_updated_by'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      where object_id = p_object_id; '||CHR(10)||CHR(10));

    Ecdp_Dynsql.AddSqlLine(body_lines,'      DELETE FROM '||LOWER(lv2_version_tablename)||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      WHERE object_id = p_object_id;'||CHR(10)||CHR(10));

    Ecdp_Dynsql.AddSqlLine(body_lines,'      DELETE FROM '||LOWER(lv2_main_tablename)||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      WHERE object_id = p_object_id;'||CHR(10)||CHR(10));

  END IF;

  Ecdp_Dynsql.AddSqlLine(body_lines,'      RETURN p_vt;'||CHR(10)||CHR(10));

  Ecdp_Dynsql.AddSqlLine(body_lines,'   END IF;'||CHR(10)||CHR(10));

  Ecdp_Dynsql.AddSqlLine(body_lines,'   -- Copy version array, exclude obsolete versions'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'   FOR i IN 1..p_vt.Count LOOP'||CHR(10)||CHR(10));

  Ecdp_Dynsql.AddSqlLine(body_lines,'      IF p_vt(i).daytime < nvl(p_end_date,p_vt(i).daytime + 1) THEN'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'         l_vt.extend;'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'         ln_counter := ln_counter + 1;'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'         l_vt(ln_counter) := p_vt(i);'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'      END IF;'||CHR(10));

  Ecdp_Dynsql.AddSqlLine(body_lines,'   END LOOP;'||CHR(10)||CHR(10));

  Ecdp_Dynsql.AddSqlLine(body_lines,'   lv2_session_param := EcDp_User_Session.getUserSessionParameter(''JN_NOTES'');'||CHR(10)||CHR(10));

  Ecdp_Dynsql.AddSqlLine(body_lines,'   -- delete all obsolete entries'||CHR(10));

  IF lb_approval_enabled THEN

    Ecdp_Dynsql.AddSqlLine(body_lines,'   EcDp_User_Session.SetUserSessionParameter(''JN_NOTES'',''COMMON'');'||CHR(10)||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   FOR curVerRow IN c_version_row(p_object_id) LOOP'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'     EcDp_User_Session.SetUserSessionParameter(''JN_NOTES'', lv2_session_param);'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'     IF curVerRow.daytime >= p_end_date THEN'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'       IF curVerRow.Approval_State=''N'' THEN'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         DELETE FROM '||LOWER(lv2_version_tablename)||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         WHERE object_id = p_object_id'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         AND   daytime = curVerRow.daytime;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'         Ecdp_Approval.deleteTaskDetail(curVerRow.rec_id);'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'       ELSE'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          lv2_rec_id := Nvl(curVerRow.rec_id, SYS_GUID());'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          UPDATE '||LOWER(lv2_version_tablename)||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          SET    last_updated_by = p_last_updated_by'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          ,      last_updated_date = p_last_updated_date'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          ,      approval_state = ''D'''||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          ,      approval_by = null'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          ,      approval_date = null'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          ,      rec_id = lv2_rec_id'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          ,      rev_no = nvl(rev_no,0) + 1'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          WHERE object_id = p_object_id'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          AND daytime = curVerRow.daytime;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          Ecdp_Approval.registerTaskDetail(lv2_rec_id,'''||p_class_name||''',p_last_updated_by);'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'       END IF;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'       EcDp_User_Session.SetUserSessionParameter(''JN_NOTES'',''COMMON'');'||CHR(10)||CHR(10));
  ELSE

    Ecdp_Dynsql.AddSqlLine(body_lines,'   DELETE FROM '||LOWER(lv2_version_tablename)||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   WHERE object_id = p_object_id'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   AND daytime >= p_end_date;'||CHR(10)||CHR(10));

    Ecdp_Dynsql.AddSqlLine(body_lines,'       EcDp_User_Session.SetUserSessionParameter(''JN_NOTES'',''COMMON'');'||CHR(10)||CHR(10));

  END IF;

  IF lb_approval_enabled THEN

    Ecdp_Dynsql.AddSqlLine(body_lines,'     ELSIF curVerRow.end_date IS NULL OR curVerRow.end_date > p_end_date THEN'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          --  set end date on all related versions'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          lv2_approval_state := ''U'';'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          IF curVerRow.Approval_State=''N'' THEN'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'            lv2_approval_state := ''N'';'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          END IF;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          lv2_rec_id := Nvl(curVerRow.rec_id, SYS_GUID());'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          UPDATE '||LOWER(lv2_version_tablename)||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          SET    end_date = p_end_date'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          ,      rev_no = nvl(rev_no,0) + 1'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          ,      last_updated_by = p_last_updated_by'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          ,      last_updated_date = p_last_updated_date'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          ,      approval_state = lv2_approval_state'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          ,      approval_by = null'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          ,      approval_date = null'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          ,      rec_id = lv2_rec_id'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          WHERE object_id = p_object_id'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          AND daytime = curVerRow.daytime;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'          Ecdp_Approval.registerTaskDetail(lv2_rec_id,'''||p_class_name||''',p_last_updated_by);'||CHR(10));

  ELSE
    Ecdp_Dynsql.AddSqlLine(body_lines,'   --  set end date on all related versions'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   UPDATE '||LOWER(lv2_version_tablename)||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   SET end_date = p_end_date,'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   rev_no = nvl(rev_no,0) + 1,'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   last_updated_by = p_last_updated_by,'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   last_updated_date = p_last_updated_date'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   WHERE object_id = p_object_id'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   AND (end_date IS NULL OR end_date > p_end_date);'||CHR(10)||CHR(10));

  END IF;

  IF lb_approval_enabled THEN

    Ecdp_Dynsql.AddSqlLine(body_lines,'      ELSIF curVerRow.end_date < nvl(p_end_date,curVerRow.end_date + 1) THEN'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'             -- To cover the case when you move object_end_date forward, and the last version has end_date = old.object_end_date'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'             SELECT count(*) INTO ln_version_counter FROM '||LOWER(lv2_version_tablename)||' WHERE object_id = p_object_id AND daytime > curVerRow.daytime;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'             IF ln_version_counter = 0 THEN '||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'               lv2_approval_state := ''U'';'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'               IF curVerRow.Approval_State=''N'' THEN'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'                 lv2_approval_state := ''N'';'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'               END IF;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'               lv2_rec_id := Nvl(curVerRow.rec_id, SYS_GUID());'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'               UPDATE '||LOWER(lv2_version_tablename)||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'               SET    end_date = p_end_date'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'               ,      rev_no = nvl(rev_no,0) + 1'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'               ,      last_updated_by = p_last_updated_by'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'               ,      last_updated_date = p_last_updated_date'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'               ,      approval_state = lv2_approval_state'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'               ,      approval_by = null'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'               ,      approval_date = null'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'               ,      rec_id = lv2_rec_id'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'               WHERE object_id = p_object_id'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'               AND daytime = curVerRow.daytime;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'               Ecdp_Approval.registerTaskDetail(lv2_rec_id,'''||p_class_name||''',p_last_updated_by);'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'             END IF;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'      END IF;'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   END LOOP;'||CHR(10));

  ELSE

    Ecdp_Dynsql.AddSqlLine(body_lines,'   -- To cover the case when you move object_end_date forward, and the last version has end_date = old.object_end_date'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   UPDATE '||LOWER(lv2_version_tablename)||' v'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   SET end_date = p_end_date,'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   rev_no = nvl(rev_no,0) + 1,'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   last_updated_by = p_last_updated_by,'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   last_updated_date = p_last_updated_date'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   WHERE object_id = p_object_id'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   AND end_date IS NOT NULL'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   AND end_date < nvl(p_end_date,end_date + 1)'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'   AND NOT EXISTS('||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'       SELECT 1 FROM '||LOWER(lv2_version_tablename)||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'       WHERE object_id = v.object_id'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'       AND daytime > v.daytime);'||CHR(10)||CHR(10));

  END IF;


  Ecdp_Dynsql.AddSqlLine(body_lines,'   IF (nvl(l_vt(l_vt.LAST).end_date, p_end_date + 1) > p_end_date) OR'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'      (l_vt(l_vt.LAST).end_date IS NOT NULL AND l_vt(l_vt.LAST).end_date < nvl(p_end_date, l_vt(l_vt.LAST).end_date + 1)) THEN'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'         l_vt(l_vt.LAST).end_date := p_end_date;'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'   END IF;'||CHR(10)||CHR(10));

  Ecdp_Dynsql.AddSqlLine(body_lines,'   -- set end date on object'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'   UPDATE '||lv2_main_tablename||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'   SET end_date = p_end_date,'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'   rev_no = nvl(rev_no,0) + 1,'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'   last_updated_by = p_last_updated_by,'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'   last_updated_date = p_last_updated_date'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'   WHERE object_id = p_object_id;'||CHR(10)||CHR(10));

  Ecdp_Dynsql.AddSqlLine(body_lines,'   -- Align parent version if moving forth in time'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'   IF nvl(p_end_date,ld_old_end_date + 1) > ld_old_end_date THEN'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'      NULL;'||CHR(10));

  FOR curGroupRel IN c_group_relations LOOP

    Ecdp_Dynsql.AddSqlLine(body_lines,'      l_vt := EcTp_'||p_class_name||'.AlignParentVersions(l_vt,'''||curGroupRel.group_type||''');'||CHR(10));

  END LOOP;

  Ecdp_Dynsql.AddSqlLine(body_lines,'   END IF;'||CHR(10)||CHR(10));

  Ecdp_Dynsql.AddSqlLine(body_lines,'   RETURN l_vt;'||CHR(10)||CHR(10));

  Ecdp_Dynsql.AddSqlLine(body_lines,'END SetObjEndDate;'||CHR(10));



   Ecdp_Dynsql.AddSqlLine(body_lines, 'END ECTP_'||p_class_name||';' || chr(10) || chr(10))  ;


   Ecdp_Dynsql.SafeBuild('ECTP_'||p_class_name,'PACKAGE BODY',body_lines,p_target);


END ObjectClassTriggerPackageBody;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : CreateObjectsView
-- Description    :
--
-- Preconditions  :
--
--
--
-- Postcondition  :
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
PROCEDURE CreateObjectsView
--</EC-DOC>

IS

  CURSOR c_objects_tables IS
  SELECT c.class_name, cdb.DB_OBJECT_NAME, cdb.db_object_attribute, cdb.db_where_condition
  FROM class c, class_db_mapping cdb
  WHERE c.class_name = cdb.class_name
  AND   c.class_type = 'OBJECT'
  AND Nvl(c.read_only_ind,'N') = 'N'
  AND c.class_name not like 'IMP%'
  ORDER BY c.class_name
  ;


  lb_firsttime                 BOOLEAN := TRUE;
  body_lines                   DBMS_SQL.varchar2a;

BEGIN

  Ecdp_Dynsql.AddSqlLine(body_lines, 'CREATE OR REPLACE VIEW OBJECTS('||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines, 'CLASS_NAME, OBJECT_ID, CODE, START_DATE, END_DATE'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines, ', RECORD_STATUS, CREATED_BY, CREATED_DATE, LAST_UPDATED_BY, LAST_UPDATED_DATE'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines, ', REV_NO, REV_TEXT) AS'||CHR(10));


  FOR curObject IN  c_objects_tables LOOP

    IF NOT lb_firsttime THEN

      Ecdp_Dynsql.AddSqlLine(body_lines, 'UNION ALL'||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines, 'SELECT '''||curObject.class_name||''', object_id, object_code, start_date, end_date '||CHR(10));


    ELSE

      lb_firsttime := FALSE;
      Ecdp_Dynsql.AddSqlLine(body_lines, 'SELECT '||GeneratedCodeMsg);
      Ecdp_Dynsql.AddSqlLine(body_lines, ''''||curObject.class_name||''', object_id, object_code, start_date, end_date '||CHR(10));

    END IF;

    Ecdp_Dynsql.AddSqlLine(body_lines, ',RECORD_STATUS, CREATED_BY, CREATED_DATE, LAST_UPDATED_BY, LAST_UPDATED_DATE'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines, ', REV_NO, REV_TEXT'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines, 'FROM '||curObject.DB_OBJECT_NAME||' o '||CHR(10));

    IF curObject.db_where_condition IS NOT NULL THEN
       Ecdp_Dynsql.AddSqlLine(body_lines, 'WHERE '||curObject.db_where_condition||CHR(10));
    END IF;


  END LOOP;

  IF lb_firsttime THEN  -- create dummy version

    Ecdp_Dynsql.AddSqlLine(body_lines, 'SELECT --'||GeneratedCodeMsg);
    Ecdp_Dynsql.AddSqlLine(body_lines, '''dummy'',''dummy'', ''dummy'', sysdate, sysdate '||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines, ',''P'', ''dummy'', sysdate, ''dummy'', sysdate'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines, ', 0, ''dummy'''||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines, 'FROM dual'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines, 'WHERE 1 = 0'||CHR(10));


  END IF;


   Ecdp_Dynsql.SafeBuild('OBJECTS','VIEW',body_lines,'CREATE');


END;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : CreateObjectsVersionView
-- Description    :
--
-- Preconditions  :
--
--
--
-- Postcondition  :
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
PROCEDURE CreateObjectsVersionView
--</EC-DOC>
IS


  CURSOR c_objects_tables IS
  SELECT c.class_name, cdb.DB_OBJECT_NAME, cdb.db_object_attribute, cdb.db_where_condition
  FROM class c, class_db_mapping cdb
  WHERE c.class_name = cdb.class_name
  AND   c.class_type = 'OBJECT'
  AND Nvl(c.read_only_ind,'N') = 'N'
  and c.class_name not like 'IMP%'
  ORDER BY c.class_name
  ;

  lb_firsttime                 BOOLEAN := TRUE;
  body_lines                   DBMS_SQL.varchar2a;

BEGIN

  Ecdp_Dynsql.AddSqlLine(body_lines,'CREATE OR REPLACE VIEW OBJECTS_VERSION('||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,'CLASS_NAME, OBJECT_ID, OBJECT_START_DATE, OBJECT_END_DATE, DAYTIME, END_DATE, OBJECT_CODE, NAME' ||CHR(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,', RECORD_STATUS, CREATED_BY, CREATED_DATE, LAST_UPDATED_BY, LAST_UPDATED_DATE' || chr(10));
  Ecdp_Dynsql.AddSqlLine(body_lines,', REV_NO, REV_TEXT) AS'||CHR(10));



  FOR curObject IN  c_objects_tables LOOP

    IF NOT lb_firsttime THEN

      Ecdp_Dynsql.AddSqlLine(body_lines,'UNION ALL'||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'SELECT '''||curObject.class_name||''', oa.object_id, o.start_date, o.end_date, oa.daytime, oa.end_date, o.object_code, oa.name '||CHR(10));


    ELSE

      lb_firsttime := FALSE;
      Ecdp_Dynsql.AddSqlLine(body_lines,'SELECT '||GeneratedCodeMsg);
      Ecdp_Dynsql.AddSqlLine(body_lines,''''||curObject.class_name||''', oa.object_id, o.start_date, o.end_date, oa.daytime,  oa.end_date, o.object_code, oa.name '||CHR(10));

    END IF;

    Ecdp_Dynsql.AddSqlLine(body_lines,',oa.RECORD_STATUS, oa.CREATED_BY, oa.CREATED_DATE, oa.LAST_UPDATED_BY, oa.LAST_UPDATED_DATE'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,', oa.REV_NO, oa.REV_TEXT'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'FROM '||curObject.DB_OBJECT_attribute||' oa, '||curObject.DB_OBJECT_NAME||' o '||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'WHERE oa.object_id = o.object_id'||CHR(10));

    IF curObject.db_where_condition IS NOT NULL THEN
       Ecdp_Dynsql.AddSqlLine(body_lines,'AND '||curObject.db_where_condition||CHR(10));
    END IF;


  END LOOP;

  IF lb_firsttime THEN  -- create dummy version

    Ecdp_Dynsql.AddSqlLine(body_lines,'SELECT --'||GeneratedCodeMsg);
    Ecdp_Dynsql.AddSqlLine(body_lines,'''dummy'',''dummy'', sysdate, sysdate, sysdate, sysdate, ''dummy'', ''dummy'''||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,',''P'', ''dummy'', sysdate, ''dummy'', sysdate'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,', 0, ''dummy'''||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'FROM dual'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'WHERE 1 = 0'||CHR(10));


  END IF;

   Ecdp_Dynsql.SafeBuild('OBJECT_VERSION','VIEW',body_lines,'CREATE');

END;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : CreateGroupsView
-- Description    :
--
-- Preconditions  :
--
--
--
-- Postcondition  :
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
PROCEDURE CreateGroupsView
--</EC-DOC>
IS

  CURSOR c_group_connections IS
  SELECT cr.*, db.db_sql_syntax, cdb.DB_OBJECT_NAME, cdb.db_object_attribute, cdb.db_where_condition
  FROM class_relation cr, class_rel_db_mapping db, class_db_mapping cdb
  WHERE cr.from_class_name = db.from_class_name
    AND cr.to_class_name = db.to_class_name
    AND cr.role_name = db.role_name
    AND cr.to_class_name = cdb.class_name
    AND cr.group_type IS NOT NULL
    AND multiplicity IN ('1:1', '1:N')
    AND nvl(cr.disabled_ind,'N') <> 'Y'
  ORDER BY group_type, ALLOC_PRIORITY
  ;

  CURSOR c_alt_group_connections(cp_group_type VARCHAR2, cp_to_class_name VARCHAR2, cp_ne_from_class_name VARCHAR2) IS
  SELECT cr.from_class_name, db.db_sql_syntax
  FROM class_relation cr, class_rel_db_mapping db, class_db_mapping cdb
  WHERE cr.from_class_name = db.from_class_name
    AND cr.to_class_name = db.to_class_name
    AND cr.role_name = db.role_name
    AND cr.to_class_name = cdb.class_name
    AND cr.group_type IS NOT NULL
    AND multiplicity IN ('1:1', '1:N')
    AND nvl(cr.disabled_ind,'N') <> 'Y'
    AND cr.group_type = cp_group_type
    AND cr.to_class_name = cp_to_class_name
    AND cr.from_class_name <> cp_ne_from_class_name
  ;


  view_lines                DBMS_SQL.varchar2a;
  lb_firsttime                 BOOLEAN := TRUE;
  ln_cur_level                 NUMBER;

BEGIN

  Ecdp_Dynsql.AddSqlLine(view_lines,'CREATE OR REPLACE VIEW GROUPS('||CHR(10));
  Ecdp_Dynsql.AddSqlLine(view_lines,GeneratedCodeMsg);
  Ecdp_Dynsql.AddSqlLine(view_lines,'GROUP_TYPE, OBJECT_TYPE, OBJECT_ID, PARENT_GROUP_TYPE, PARENT_OBJECT_TYPE, PARENT_OBJECT_ID'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(view_lines,', DAYTIME, END_DATE, RECORD_STATUS, CREATED_BY, CREATED_DATE, LAST_UPDATED_BY, LAST_UPDATED_DATE'||CHR(10));
  Ecdp_Dynsql.AddSqlLine(view_lines,', REV_NO, REV_TEXT) AS'||CHR(10));

  FOR curGM IN  c_group_connections LOOP

    IF NOT lb_firsttime THEN

      Ecdp_Dynsql.AddSqlLine(view_lines,'UNION ALL'||CHR(10));
      Ecdp_Dynsql.AddSqlLine(view_lines,'SELECT '''||curGM.group_type||''','''||curGM.to_class_name||''', o.object_id'||CHR(10));

    ELSE

      lb_firsttime := FALSE;
      Ecdp_Dynsql.AddSqlLine(view_lines,'SELECT --'||GeneratedCodeMsg);
      Ecdp_Dynsql.AddSqlLine(view_lines,''''||curGM.group_type||''','''||curGM.to_class_name||''', o.object_id'||CHR(10));


    END IF;

    Ecdp_Dynsql.AddSqlLine(view_lines,','''||curGM.group_type||''','''||curGM.from_class_name||''','||curGM.db_sql_syntax||CHR(10));
    Ecdp_Dynsql.AddSqlLine(view_lines,', oa.DAYTIME, oa.END_DATE, oa.RECORD_STATUS, oa.CREATED_BY, oa.CREATED_DATE, oa.LAST_UPDATED_BY, oa.LAST_UPDATED_DATE'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(view_lines,', oa.REV_NO, oa.REV_TEXT'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(view_lines,'FROM '||curGM.db_object_attribute||' oa,'||curGM.DB_OBJECT_NAME||' o '||CHR(10));
    Ecdp_Dynsql.AddSqlLine(view_lines,'WHERE o.object_id = oa.object_id'||CHR(10));

    IF curGM.db_where_condition IS NOT NULL THEN
       Ecdp_Dynsql.AddSqlLine(view_lines,'AND '||curGM.db_where_condition||CHR(10));
    END IF;

    -- check for alternative path from current level upwards
    FOR cur_alt_path in c_alt_group_connections(curGM.group_type, curGM.to_class_name, curGM.from_class_name ) LOOP

       --multiple paths detected
       -- need to find if outer relation is the highest parent
       ln_cur_level := Ecdp_classmeta.getGroupModelLevelSortOrder (curGM.group_type, curGM.to_class_name, curGM.from_class_name);


       IF  ln_cur_level < Ecdp_classmeta.getGroupModelLevelSortOrder (curGM.group_type, curGM.to_class_name, cur_alt_path.from_class_name) THEN

         -- where "inner_child" is null
         Ecdp_Dynsql.AddSqlLine(view_lines,'AND '||cur_alt_path.db_sql_syntax||' IS NULL '||CHR(10));

       ELSE

         -- where "inner_child" is not null
         Ecdp_Dynsql.AddSqlLine(view_lines,'AND '||curGM.db_sql_syntax||' IS NOT NULL '||CHR(10));

       END IF;

    END LOOP;

  END LOOP;

  IF lb_firsttime THEN  -- create dummy version

    Ecdp_Dynsql.AddSqlLine(view_lines,'SELECT --'||GeneratedCodeMsg);
    Ecdp_Dynsql.AddSqlLine(view_lines,'''dummy'',''dummy'', ''dummy'''||CHR(10));
    Ecdp_Dynsql.AddSqlLine(view_lines,',''dummy'',''dummy'',''dummy'''||CHR(10));
    Ecdp_Dynsql.AddSqlLine(view_lines,', sysdate, sysdate, ''P'', ''dummy'', sysdate, ''dummy'', sysdate'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(view_lines,', 0, ''dummy'''||CHR(10));
    Ecdp_Dynsql.AddSqlLine(view_lines,'FROM dual'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(view_lines,'WHERE 1 = 0'||CHR(10));

  END IF;

  Ecdp_Dynsql.SafeBuild('GROUPS','VIEW',view_lines,'CREATE');


END;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : CreateDefermentGroupsView
-- Description    :
--
-- Preconditions  :
--
--
--
-- Postcondition  :
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
PROCEDURE CreateDefermentGroupsView
--</EC-DOC>
IS

  CURSOR c_group_connections IS
  SELECT cr.*, db.db_sql_syntax, cdb.DB_OBJECT_NAME, cdb.db_object_attribute, cdb.db_where_condition
  FROM class_relation cr, class_rel_db_mapping db, class_db_mapping cdb
  WHERE cr.from_class_name = db.from_class_name
    AND cr.to_class_name = db.to_class_name
    AND cr.role_name = db.role_name
    AND cr.to_class_name = cdb.class_name
    AND cr.group_type IS NULL
    AND SUBSTR(upper(cr.role_name),1,4) = 'DEF_'
    AND multiplicity IN ('1:1', '1:N')
    AND nvl(cr.disabled_ind,'N') <> 'Y'
  ORDER BY group_type, ALLOC_PRIORITY
  ;

  lv2_sql                      VARCHAR2(32000);
  lb_firsttime                 BOOLEAN := TRUE;


BEGIN

  lv2_sql := 'CREATE OR REPLACE VIEW DEFERMENT_GROUPS('||CHR(10);
  lv2_sql := lv2_sql ||GeneratedCodeMsg;
  lv2_sql := lv2_sql ||'GROUP_TYPE, OBJECT_TYPE, OBJECT_ID, PARENT_GROUP_TYPE, PARENT_OBJECT_TYPE, PARENT_OBJECT_ID'||CHR(10);
  lv2_sql := lv2_sql ||', DAYTIME, END_DATE, RECORD_STATUS, CREATED_BY, CREATED_DATE, LAST_UPDATED_BY, LAST_UPDATED_DATE'||CHR(10);
  lv2_sql := lv2_sql ||', REV_NO, REV_TEXT) AS'||CHR(10);

  FOR curGM IN  c_group_connections LOOP

    IF NOT lb_firsttime THEN

      lv2_sql := lv2_sql ||'UNION ALL'||CHR(10);
      lv2_sql := lv2_sql ||'SELECT ''deferment'','''||curGM.to_class_name||''', o.object_id';


    ELSE

      lb_firsttime := FALSE;
      lv2_sql := lv2_sql ||'SELECT --'||GeneratedCodeMsg;
      lv2_sql := lv2_sql ||'''deferment'','''||curGM.to_class_name||''', o.object_id';


    END IF;

    lv2_sql := lv2_sql || ',''deferment'','''||curGM.from_class_name||''','||curGM.db_sql_syntax||CHR(10);
    lv2_sql := lv2_sql || ', oa.DAYTIME, oa.END_DATE, oa.RECORD_STATUS, oa.CREATED_BY, oa.CREATED_DATE, oa.LAST_UPDATED_BY, oa.LAST_UPDATED_DATE'||CHR(10);
    lv2_sql := lv2_sql ||', oa.REV_NO, oa.REV_TEXT'||CHR(10);
    lv2_sql := lv2_sql ||'FROM '||curGM.db_object_attribute||' oa,'||curGM.DB_OBJECT_NAME||' o '||CHR(10);
    lv2_sql := lv2_sql ||'WHERE o.object_id = oa.object_id'||CHR(10);
    lv2_sql := lv2_sql ||'AND   '||curGM.db_sql_syntax||' IS NOT NULL'||CHR(10);

    IF curGM.db_where_condition IS NOT NULL THEN
       lv2_sql := lv2_sql ||'AND '||curGM.db_where_condition||CHR(10);
    END IF;


  END LOOP;

  IF lb_firsttime THEN  -- create dummy version

    lv2_sql := lv2_sql ||'SELECT --'||GeneratedCodeMsg;
    lv2_sql := lv2_sql ||'''dummy'',''dummy'', ''dummy'''||CHR(10);
    lv2_sql := lv2_sql || ',''dummy'',''dummy'',''dummy'''||CHR(10);
    lv2_sql := lv2_sql || ', sysdate, sysdate, ''P'', ''dummy'', sysdate, ''dummy'', sysdate'||CHR(10);
    lv2_sql := lv2_sql ||', 0, ''dummy'''||CHR(10);
    lv2_sql := lv2_sql ||'FROM dual'||CHR(10);
    lv2_sql := lv2_sql ||'WHERE 1 = 0'||CHR(10);


  END IF;

   SafeBuild('DEFERMENT_GROUPS','VIEW',lv2_sql,'CREATE');


END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : AddGroupSyncLevel
-- Description    :
--
-- Preconditions  :
--
--
--
-- Postcondition  :
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
PROCEDURE AddGroupSyncLevel(p_group_type     IN VARCHAR2,
                            p_from_class_name IN VARCHAR2,
                            p_body_lines IN OUT DBMS_SQL.varchar2a)
--</EC-DOC>
IS

CURSOR cGroupLevel IS
SELECT distinct group_type, to_class_name class_name
FROM class_relation cr
WHERE cr.group_type = p_group_type
AND   cr.from_class_name = p_from_class_name
AND   EXISTS (
SELECT 1 FROM class_relation cr2
WHERE cr2.group_type = cr.group_type
AND   cr.to_class_name = cr2.from_class_name);


BEGIN

  FOR curTop IN cGroupLevel LOOP

    Ecdp_Dynsql.AddSqlLine(p_body_lines, '    FOR cur'||curTop.class_name||' IN c_'||curTop.class_name||' LOOP'||chr(10)||chr(10));

    Ecdp_Dynsql.AddSqlLine(p_body_lines, '      lvt_'||curTop.class_name||' := ECTP_'||curTop.class_name||'.ver_tab_type();'||chr(10)||chr(10));
    Ecdp_Dynsql.AddSqlLine(p_body_lines, '      i := 1;'||chr(10)||chr(10));

    Ecdp_Dynsql.AddSqlLine(p_body_lines, '      FOR cur'||curTop.class_name||'_v IN c_'||curTop.class_name||'_v(cur'||curTop.class_name||'.object_id) LOOP'||chr(10)||chr(10));

    Ecdp_Dynsql.AddSqlLine(p_body_lines, '        lvt_'||curTop.class_name||'.extend;'||chr(10));
    Ecdp_Dynsql.AddSqlLine(p_body_lines, '        lvt_'||curTop.class_name||'(i) := cur'||curTop.class_name||'_v;'||chr(10));
    Ecdp_Dynsql.AddSqlLine(p_body_lines, '        lvt_'||curTop.class_name||'(i).last_updated_by := ''REPLICATOR'';'||chr(10));
    Ecdp_Dynsql.AddSqlLine(p_body_lines, '        lvt_'||curTop.class_name||'(i).last_updated_date := nvl(EcDp_Date_Time.getCurrentSysdate,sysdate);'||chr(10));
    Ecdp_Dynsql.AddSqlLine(p_body_lines, '        i := i + 1;'||chr(10)||chr(10));

    Ecdp_Dynsql.AddSqlLine(p_body_lines, '      END LOOP;'||chr(10)||chr(10));

    Ecdp_Dynsql.AddSqlLine(p_body_lines, '      IF i > 1 THEN'||chr(10)||chr(10));

    Ecdp_Dynsql.AddSqlLine(p_body_lines, '        ECTP_'||curTop.class_name||'.CallSyncChildren(lvt_'||curTop.class_name||',''Y'');'||chr(10)||chr(10));

    Ecdp_Dynsql.AddSqlLine(p_body_lines, '        lvt_'||curTop.class_name||'.delete;'||chr(10)||chr(10));

    Ecdp_Dynsql.AddSqlLine(p_body_lines, '      END IF;'||chr(10)||chr(10));

    Ecdp_Dynsql.AddSqlLine(p_body_lines, '    END LOOP;'||chr(10)||chr(10));

    -- Recursive Call for children
    AddGroupSyncLevel(curTop.group_type,
                      curTop.class_name,
                      p_body_lines);

  END LOOP;


END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : CreateGroupSyncPackage
-- Description    :
--
-- Preconditions  :
--
--
--
-- Postcondition  :
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
PROCEDURE CreateGroupSyncPackage
--</EC-DOC>
IS

-- Get distinct group model types from the class relations
CURSOR cDistinctGroupType IS
SELECT DISTINCT cr.group_type
FROM class_relation cr, class_db_mapping m, class c
WHERE c.class_name = m.class_name
AND cr.to_class_name = c.class_name
AND cr.group_type IS NOT NULL;

CURSOR cDistinctObjectGroupTables(cp_group_type VARCHAR2) IS
SELECT DISTINCT m.db_object_attribute
FROM class_relation cr, class_db_mapping m, class c
WHERE c.class_name = m.class_name
AND cr.to_class_name = c.class_name
AND cr.group_type = Nvl(cp_group_type, cr.group_type);

CURSOR cDistinctObjectGroupClasses(cp_group_type VARCHAR2, cp_db_object_attribute VARCHAR2) IS
SELECT DISTINCT c.class_name
FROM class_relation cr, class_db_mapping m, class c
WHERE c.class_name = m.class_name
AND cr.to_class_name = c.class_name
AND cr.group_type = cp_group_type
AND m.db_object_attribute = cp_db_object_attribute;

CURSOR cDistinctParentClasses(cp_group_type VARCHAR2, cp_db_object_attribute VARCHAR2) IS
SELECT DISTINCT cr.from_class_name, db.db_sql_syntax
FROM v_group_level g,
     class_relation cr,
     class_rel_db_mapping db
WHERE g.from_class_name = cr.from_class_name
AND   g.to_class_name = cr.to_class_name
AND   g.role_name = cr.role_name
AND   g.from_class_name = db.from_class_name
AND   g.to_class_name = db.to_class_name
AND   g.role_name = db.role_name
AND   cr.group_type = cp_group_type
AND EXISTS (
SELECT *
FROM class_relation cr2, class_db_mapping m, class c
WHERE c.class_name = m.class_name
AND g.class_name = c.class_name
AND cr2.to_class_name = c.class_name
AND cr2.group_type = cr.group_type
AND m.db_object_attribute = cp_db_object_attribute
);


CURSOR cDistinctParentGroupClass IS
SELECT distinct from_class_name, DB_OBJECT_NAME, DB_OBJECT_ATTRIBUTE, DB_WHERE_CONDITION
FROM class_relation cr, class_db_mapping db
WHERE cr.from_class_name = db.class_name
AND cr.group_type is not NULL;

CURSOR cGroupTops IS
SELECT distinct group_type, from_class_name class_name
FROM class_relation cr
WHERE cr.group_type is not NULL
AND NOT EXISTS (
SELECT 1 FROM class_relation cr2
WHERE cr2.group_type IS NOT NULL
AND   cr.group_type = cr2.group_type
AND   cr.from_class_name = cr2.to_class_name);





  lv2_sql                      VARCHAR2(32000);
  lb_firsttime                 BOOLEAN := TRUE;
  header_lines                 DBMS_SQL.varchar2a;
  body_lines                   DBMS_SQL.varchar2a;

  lb_found_group_tops          BOOLEAN := FALSE;
  lb_tabs_to_select            BOOLEAN := FALSE;
  lb_found_parent              BOOLEAN := FALSE;
  lb_found_group               BOOLEAN := FALSE;
  lv2_if_stmt                  VARCHAR2(2000);

BEGIN

   -- First create the package header
   Ecdp_Dynsql.AddSqlLine(header_lines, 'CREATE OR REPLACE PACKAGE ECGP_GROUP IS '|| chr(10) );
   Ecdp_Dynsql.AddSqlLine(header_lines, GeneratedCodeMsg||CHR(10) );


-- declare section
  Ecdp_Dynsql.AddSqlLine(header_lines,'PROCEDURE  Syncronize(p_grouptype   VARCHAR2 DEFAULT NULL);' || chr(10)|| chr(10));

  Ecdp_Dynsql.AddSqlLine(header_lines,'FUNCTION findParentObjectId(p_group_type               VARCHAR2,' || chr(10));
  Ecdp_Dynsql.AddSqlLine(header_lines,'                            p_parent_object_class_name VARCHAR2,' || chr(10));
  Ecdp_Dynsql.AddSqlLine(header_lines,'                            p_object_class_name        VARCHAR2,' || chr(10));
  Ecdp_Dynsql.AddSqlLine(header_lines,'                            p_object_id                VARCHAR2,' || chr(10));
  Ecdp_Dynsql.AddSqlLine(header_lines,'                            p_daytime                  DATE)' || chr(10));
  Ecdp_Dynsql.AddSqlLine(header_lines,'RETURN VARCHAR2;' || chr(10)|| chr(10));

  Ecdp_Dynsql.AddSqlLine(header_lines,'PRAGMA RESTRICT_REFERENCES (findParentObjectId, WNDS, WNPS, RNPS);' || chr(10)|| chr(10));

  Ecdp_Dynsql.AddSqlLine(header_lines,'END;' || chr(10));


  Ecdp_Dynsql.SafeBuild('ECGP_GROUP','PACKAGE',header_lines);


  -- Package body
     -- create the package body

   Ecdp_Dynsql.AddSqlLine(body_lines,'CREATE OR REPLACE PACKAGE BODY ECGP_GROUP IS '|| chr(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,GeneratedCodeMsg);
   Ecdp_Dynsql.AddSqlLine(body_lines,CHR(10) || CHR(10));

   Ecdp_Dynsql.AddSqlLine(body_lines,'------------------------------------------------------------------------------------------------------' || chr(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'-- Syncronize' || chr(10));
   Ecdp_Dynsql.AddSqlLine(body_lines,'------------------------------------------------------------------------------------------------------' || chr(10));





   Ecdp_Dynsql.AddSqlLine(body_lines, 'PROCEDURE  Syncronize(p_grouptype   VARCHAR2 DEFAULT NULL)' || chr(10)) ;
   Ecdp_Dynsql.AddSqlLine(body_lines, 'IS' || chr(10) || chr(10))  ;


   FOR curParentGroupClass IN cDistinctParentGroupClass LOOP

      Ecdp_Dynsql.AddSqlLine(body_lines, 'lvt_'||curParentGroupClass.from_class_name||'   ECTP_'||curParentGroupClass.from_class_name||'.ver_tab_type ;' || chr(10)) ;
      Ecdp_Dynsql.AddSqlLine(body_lines, 'CURSOR c_'||curParentGroupClass.from_class_name||' IS SELECT * FROM '||curParentGroupClass.DB_OBJECT_NAME||' o '||chr(10)) ;
      IF curParentGroupClass.DB_WHERE_CONDITION IS NOT NULL THEN
         Ecdp_Dynsql.AddSqlLine(body_lines, 'WHERE '||curParentGroupClass.DB_WHERE_CONDITION ||chr(10)) ;
     END IF;
     Ecdp_Dynsql.AddSqlLine(body_lines, ' ORDER BY object_code ; '||chr(10)) ;

     Ecdp_Dynsql.AddSqlLine(body_lines, 'CURSOR c_'||curParentGroupClass.from_class_name||'_v(p_object_id VARCHAR2) IS SELECT * FROM '||curParentGroupClass.DB_OBJECT_ATTRIBUTE ||' v '||CHR(10));
     Ecdp_Dynsql.AddSqlLine(body_lines, 'WHERE object_id = p_object_id ORDER BY daytime ;'||chr(10)||chr(10));

   END LOOP;

   Ecdp_Dynsql.AddSqlLine(body_lines, 'i INTEGER := 1;'||chr(10)||chr(10));


  Ecdp_Dynsql.AddSqlLine(body_lines, 'BEGIN'||chr(10)||chr(10));

  -- Now comes the tricky part Need to loop over all parent classes i the right sequence
  -- The idea here is to start on the top level and move downward

  -- The first Loop here takes only the top level with no parents
  FOR curTop IN cGroupTops LOOP

    lb_found_group_tops := TRUE;

    Ecdp_Dynsql.AddSqlLine(body_lines, '  IF '''||curTop.group_type||''' = nvl(p_grouptype,'''||curTop.group_type||''') THEN '||chr(10)||chr(10));


    Ecdp_Dynsql.AddSqlLine(body_lines, '    FOR cur'||curTop.class_name||' IN c_'||curTop.class_name||' LOOP'||chr(10)||chr(10));

    Ecdp_Dynsql.AddSqlLine(body_lines, '      lvt_'||curTop.class_name||' := ECTP_'||curTop.class_name||'.ver_tab_type();'||chr(10)||chr(10));
    Ecdp_Dynsql.AddSqlLine(body_lines, '      i := 1;'||chr(10)||chr(10));

    Ecdp_Dynsql.AddSqlLine(body_lines, '      FOR cur'||curTop.class_name||'_v IN c_'||curTop.class_name||'_v(cur'||curTop.class_name||'.object_id) LOOP'||chr(10)||chr(10));

    Ecdp_Dynsql.AddSqlLine(body_lines, '        lvt_'||curTop.class_name||'.extend;'||chr(10));
    Ecdp_Dynsql.AddSqlLine(body_lines, '        lvt_'||curTop.class_name||'(i) := cur'||curTop.class_name||'_v;'||chr(10));
    Ecdp_Dynsql.AddSqlLine(body_lines, '        lvt_'||curTop.class_name||'(i).last_updated_by := ''REPLICATOR'';'||chr(10)||chr(10));
    Ecdp_Dynsql.AddSqlLine(body_lines, '        lvt_'||curTop.class_name||'(i).last_updated_date := nvl(EcDp_Date_Time.getCurrentSysdate,sysdate);'||chr(10));
    Ecdp_Dynsql.AddSqlLine(body_lines, '        i := i + 1;'||chr(10)||chr(10));

    Ecdp_Dynsql.AddSqlLine(body_lines, '      END LOOP;'||chr(10)||chr(10));

    Ecdp_Dynsql.AddSqlLine(body_lines, '      IF i > 1 THEN'||chr(10)||chr(10));

    Ecdp_Dynsql.AddSqlLine(body_lines, '        ECTP_'||curTop.class_name||'.CallSyncChildren(lvt_'||curTop.class_name||',''Y'');'||chr(10)||chr(10));

    Ecdp_Dynsql.AddSqlLine(body_lines, '        lvt_'||curTop.class_name||'.delete;'||chr(10)||chr(10));

    Ecdp_Dynsql.AddSqlLine(body_lines, '      END IF;'||chr(10)||chr(10));

    Ecdp_Dynsql.AddSqlLine(body_lines, '    END LOOP;'||chr(10)||chr(10));

    -- Recursive Call for children
    AddGroupSyncLevel(curTop.group_type,
                      curTop.class_name,
                      body_lines);

    Ecdp_Dynsql.AddSqlLine(body_lines, '  END IF; -- '||curTop.group_type||chr(10)||chr(10));


  END LOOP;

  IF NOT lb_found_group_tops THEN
     Ecdp_Dynsql.AddSqlLine(body_lines, '   NULL;' || chr(10) || chr(10));
  END IF;

  Ecdp_Dynsql.AddSqlLine(body_lines, 'END;' || chr(10) || chr(10));

-- Create findParentObjectId function

   Ecdp_Dynsql.AddSqlLine(body_lines, 'FUNCTION findParentObjectId(p_group_type               VARCHAR2,' || chr(10));
   Ecdp_Dynsql.AddSqlLine(body_lines, '                            p_parent_object_class_name VARCHAR2,' || chr(10));
   Ecdp_Dynsql.AddSqlLine(body_lines, '                            p_object_class_name        VARCHAR2,' || chr(10));
   Ecdp_Dynsql.AddSqlLine(body_lines, '                            p_object_id                VARCHAR2,' || chr(10));
   Ecdp_Dynsql.AddSqlLine(body_lines, '                            p_daytime                  DATE)' || chr(10));
   Ecdp_Dynsql.AddSqlLine(body_lines, 'RETURN VARCHAR2 IS' || chr(10)|| chr(10));

   FOR cur_tab IN cDistinctObjectGroupTables(NULL) LOOP

      Ecdp_Dynsql.AddSqlLine(body_lines, 'CURSOR c_' || cur_tab.db_object_attribute || '(cp_object_id VARCHAR2, cp_daytime DATE) IS' || chr(10));
      Ecdp_Dynsql.AddSqlLine(body_lines, 'SELECT * FROM ' || cur_tab.db_object_attribute || chr(10));
      Ecdp_Dynsql.AddSqlLine(body_lines, 'WHERE object_id = cp_object_id' || chr(10));
      Ecdp_Dynsql.AddSqlLine(body_lines, 'AND daytime <= cp_daytime AND (end_date > cp_daytime OR end_date IS NULL);' || chr(10) || chr(10));

   END LOOP;


   Ecdp_Dynsql.AddSqlLine(body_lines, 'lv2_parent_object_id VARCHAR2(32);'||chr(10)||chr(10));

   Ecdp_Dynsql.AddSqlLine(body_lines, 'BEGIN'||chr(10)||chr(10));

   FOR cur_rec IN cDistinctGroupType LOOP -- Create if selection structure for distinct group types from group model

      lb_found_group := TRUE;

      IF cDistinctGroupType%ROWCOUNT = 1 THEN
         Ecdp_Dynsql.AddSqlLine(body_lines, '   IF p_group_type = ' || CHR(39) || cur_rec.group_type || CHR(39) || ' THEN' ||chr(10)||chr(10));
      ELSE
         Ecdp_Dynsql.AddSqlLine(body_lines, '   ELSIF p_group_type = ' || CHR(39) || cur_rec.group_type || CHR(39) || ' THEN' ||chr(10)||chr(10));
      END IF;

      lb_tabs_to_select := FALSE;
      Ecdp_Dynsql.AddSqlLine(body_lines, '           NULL; -- dummy for class relation with only function call' || chr(10));

      FOR cur_ver_tab IN cDistinctObjectGroupTables(cur_rec.group_type) LOOP

         lb_tabs_to_select := TRUE;
         -- Generate the if-stmt for all the object classes persisting data for this table
         lv2_if_stmt := NULL;

         FOR cur_if_stmt IN cDistinctObjectGroupClasses(cur_rec.group_type, cur_ver_tab.db_object_attribute) LOOP

            IF lv2_if_stmt IS NULL THEN

               lv2_if_stmt :=  CHR(39) || cur_if_stmt.class_name || CHR(39);

            ELSE

               lv2_if_stmt := lv2_if_stmt || ', ' || CHR(39) || cur_if_stmt.class_name || CHR(39);

            END IF;

         END LOOP;

         IF lv2_if_stmt IS NOT NULL  THEN
            IF cDistinctObjectGroupTables%ROWCOUNT = 1 THEN
               Ecdp_Dynsql.AddSqlLine(body_lines, '     IF p_object_class_name IN (' || lv2_if_stmt || ') THEN' ||chr(10)||chr(10));
            ELSE
               Ecdp_Dynsql.AddSqlLine(body_lines, '     ELSIF p_object_class_name IN (' || lv2_if_stmt || ') THEN' ||chr(10)||chr(10));
            END IF;

            Ecdp_Dynsql.AddSqlLine(body_lines, '         FOR cur_rec IN c_' || cur_ver_tab.db_object_attribute || '(p_object_id, p_daytime) LOOP' ||chr(10)||chr(10));

            lb_found_parent := FALSE;
            FOR cur_par_class IN cDistinctParentClasses(cur_rec.group_type, cur_ver_tab.db_object_attribute) LOOP

               lb_found_parent := TRUE;
               IF cDistinctParentClasses%ROWCOUNT = 1 THEN
                  -- Generate case structure with distinct parent classes in this context
                  Ecdp_Dynsql.AddSqlLine(body_lines, '            IF p_parent_object_class_name = ' || CHR(39) || cur_par_class.from_class_name || CHR(39) || ' THEN' ||chr(10));
               ELSE
                  Ecdp_Dynsql.AddSqlLine(body_lines, '            ELSIF p_parent_object_class_name = ' || CHR(39) || cur_par_class.from_class_name || CHR(39) || ' THEN' ||chr(10));
               END IF;

               Ecdp_Dynsql.AddSqlLine(body_lines, '               lv2_parent_object_id := cur_rec.' || cur_par_class.db_sql_syntax || ';' || CHR(10));

            END LOOP;

            IF lb_found_parent THEN
               Ecdp_Dynsql.AddSqlLine(body_lines, '            END IF;' ||chr(10)||chr(10));
            ELSE
               Ecdp_Dynsql.AddSqlLine(body_lines, '            lv2_parent_object_id := NULL;' || CHR(10));
            END IF;


            Ecdp_Dynsql.AddSqlLine(body_lines, '         END LOOP;' ||chr(10)||chr(10));

         END IF;

      END LOOP;

      IF lb_tabs_to_select THEN
         Ecdp_Dynsql.AddSqlLine(body_lines, '     END IF;' ||chr(10)||chr(10));
      ELSE
         Ecdp_Dynsql.AddSqlLine(body_lines, '     lv2_parent_object_id := NULL;' || CHR(10));
      END IF;

   END LOOP;

   IF lb_found_group THEN
      Ecdp_Dynsql.AddSqlLine(body_lines, '    END IF;  -- Group type' ||chr(10)||chr(10));
   END IF;

   Ecdp_Dynsql.AddSqlLine(body_lines, '   RETURN lv2_parent_object_id;'||chr(10)||chr(10));

   Ecdp_Dynsql.AddSqlLine(body_lines, 'END findParentObjectId;'||chr(10)||chr(10));

  Ecdp_Dynsql.AddSqlLine(body_lines, 'END ECGP_GROUP;' || chr(10) || chr(10))  ;


   Ecdp_Dynsql.SafeBuild('ECGP_GROUP','PACKAGE BODY',body_lines);


END;

END EcDp_GenClassCode;