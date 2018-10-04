CREATE OR REPLACE PACKAGE BODY EcDp_Objects IS

/****************************************************************
** Package        :  EcDp_Objects, body part
**
** $Revision: 1.60 $
**
** Purpose        :  Provide basic functions on objects
**
** Documentation  :  www.energy-components.com
**
** Created  : 01.07.2002  Henning Stokke
**
** Modification history:
**
**  Date     Whom  Change description:
**  ------   ----- --------------------------------------
**  13.05.03 AV    Added new procedure WriteObjDataRow
**  27.05.03 AV    Removed setting of end_date in WriteObjAttrRow
**  17.06.03 AV    Updated WriteObj...Row to set record status to P if it is NULL
**  30.06.03 AV    Added rev_text as default parameter in setPropertyxxx procedures
**  22.07.03 AV    Rework added isValidOwnerReference, GetlastDataClassDaytimeRef
**                 UpdateObjectDataTables
**  23.07.03 AV    Added isValidClassReference, more date checks in INsObj
**  24.07.03 AV    Handeling of Integer in UpdateObjectDataTables
**  03.09.03 AV    Added class_name and class_type as parameters to UpdateObjectDataTables
**  04.09.03 SHN   Added data_class_name in the where-clause for GetObjPropertyValue, GetObjPropertyText,
**                 GetObjPropertyDate, SetObjPropertyValue, SetObjPropertyText and SetObjPropertyDate.
**  16.12.03 SHN   Added procedure InsertAttribute.
**  12.05.03 SHN   Added support for record status in function UpdateTables
**  18.08.04 MOT   Amendment of getFirstDataClassDaytimeRef: New constraint in cursor: DB_OBJECT_NAME NOT LIKE 'V_%' to avoid check of hand coded views
**  13.10.04 AV    Added GetInsertedRelationID, GetUpdatedRelationID, GetInsertedDaytime
**  21.10.04 BIH   isValidClassReference extended to handle multiple levels of interface classes (needed to solve #1278)
**  28.10.04 AV    Fix in getLastDataClassDaytimeRef for attribute tables
**  16.11.04 AV    Added function ExistsObjectVersion to check if a version already exist
**                 on the date you are trying to creating a new version for
**  31.12.05 SHN   Added support for daytime < object_start_date in GetInsertedRelationID. Tracker 1961
**  10.02.04 SHN   Rewritten due to major changes in release 8.1.
**  09.03.05 DN    TI 1965.
**  15.03.05 AV    Added new function If$Str, help function for generate trigger package
**  29.03.05 SHN   Fixed bug in GetObjIDFromCode; Added support for Interface class
**  07.04.05 SHN   Removed procedure SetObjStartDate/SetObjEndDate and added function IsValidObjStartDate,IsValidObjEndDate
**  08.04.05 AV    Renamed If$Str to IfDollarStr
**  15.04.05 SHN   Added function GetNonValidRelation
**  08.11.05 Rov   Tracker #3046 Added new function getParentFacility
**  09.11.05 AV    Changed references to WriteTempText from EcDp_genClasscode to EcDp_DynSQL (code cleanup)
**  14.11.04 Rov   Tracker #3046: Removed class name WELL_RESV in getParentFacility since it is was decided to remove this object type
**  08.05.06 Toha  TI#3691: Fixed IsValidObjStartDate, IsValidObjEndDate, GetFirstClassDaytimeRef, GetFirstClassDaytimeRef
**  13.04.07 Nazli ECPD-5207 Added Nvl(c.read_only_ind,'N') = 'N' union for All classes owned by p_class_name GetFirstClassDaytimeRef (line 704)
**  08.04.08 LIZ   ECPD-4576: Took out new procedures and put under EcBp_Production_Object instead.
**  12.07.12 leeeejin	ECPD-21380: Add if statement to function GetObjName if the return value is null from the original implementation, the logic will return the name of the object based on its start date.
**  20.07.12 Wang   Add function CheckObjectAccess to check whether current AppUser have access to given object_id
**  20.09.15 gilviser Using materialized views in GetObjIDFromCode, GetObjClassName and GetObjCode
**  01.10.15 gilviser Using the minimum value, to hide the "too many rows" problem in GetObjIDFromCode
**  06.10.15 gilviser Using the minimum value, to hide the "too many rows" problem in GetObjClassName and GetObjCode
**  06.10.15 gilviser Improved version for isValidClassReference
**  06.10.15 gilviser Using the minimum value, to hide the "too many rows" problem in GetObjName
**  01.09.17 RuneJ  Add function getObjDaytime ECPD-25142
**  23.03.18 royyypur ECPD-53452:Added query on OBJECTS_TABLE before querying on OBJECTS view to gain some performance.
****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : AddUpdateList
-- Description    : Add a new row to a update_list, returns the list and increases the count
--                  used by Instead of triggers to create list of columns for update by
--                  UpdateObjectDataTables
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
PROCEDURE AddUpdateList(
    p_update_list     IN OUT  ecdp_objects.update_list,
    p_count           IN OUT  NUMBER ,
    p_column_name             VARCHAR2 ,
    p_data_type		      VARCHAR2 ,
    p_column_data             ANYDATA,
    p_table_name              VARCHAR2 DEFAULT NULL,
    p_column_attr_name        VARCHAR2 DEFAULT NULL
)
--</EC-DOC>
IS

BEGIN

     IF p_column_name IS NOT NULL  AND  p_data_type IS NOT NULL THEN

       p_count := p_count + 1 ;
       p_update_list(p_count).column_name  := p_column_name;
       p_update_list(p_count).column_type  := LTRIM(RTRIM(UPPER(p_data_type)));
       p_update_list(p_count).column_data  := p_column_data;
       p_update_list(p_count).table_name   := p_table_name;
       p_update_list(p_count).column_attr_name := p_column_attr_name;

     END IF;

END AddUpdateList;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : UpdateTables
-- Description    : Use this function to update tables containing objects if type OBJECT.
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : class
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :  Builds update statements based on the data given in p_update_list.
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE UpdateTables(
   p_class_name       VARCHAR2,
   p_class_type       VARCHAR2,
   p_table_name       VARCHAR2,
   p_update_list      ecdp_objects.update_list,
   p_old_object_id    VARCHAR2,
   p_old_daytime      DATE
)
--</EC-DOC>

IS

   lv2_sql                      VARCHAR2(32000);
   lv2_column                   VARCHAR2(32000);
   ln_count                     NUMBER := 0 ;
   ln_col_count                 NUMBER := 0 ;
   lv2_value                    VARCHAR2(1000);

BEGIN

   lv2_sql := 'UPDATE '||p_table_name;
   ln_count := 0;

   WHILE ln_count < p_update_list.count LOOP

      ln_count := ln_count + 1;

      IF p_update_list(ln_count).table_name = p_table_name THEN

         lv2_value := getUpdateListValue(p_update_list(ln_count));

         ln_col_count := ln_col_count + 1;
         lv2_column := p_update_list(ln_count).column_name || ' = ' || lv2_value;

         IF ln_col_count > 1 THEN
	         lv2_sql := lv2_sql ||CHR(10)||'   , '|| lv2_column ;
         ELSE
            lv2_sql := lv2_sql ||CHR(10)||' SET ' || lv2_column;
         END IF;

      END IF;

   END LOOP;

   IF ln_col_count > 0 THEN

      lv2_sql := lv2_sql ||CHR(10) || ' WHERE object_id = :p_object_id';
      lv2_sql := lv2_sql ||CHR(10) || ' AND   daytime   = :p_daytime';

      EXECUTE IMMEDIATE lv2_sql using p_old_object_id, p_old_daytime;

   END IF;

EXCEPTION

   WHEN OTHERS THEN
   	ecdp_dynsql.writetemptext('GENCODEERROR','Syntax error generating update for '||p_table_name||CHR(10)||SQLERRM||CHR(10)||SUBSTR(lv2_sql,1,3700));
      Raise_Application_Error(-20108,SQLERRM);

END UpdateTables;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : getUpdateListValue
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
FUNCTION getUpdateListValue(p_update_column ecdp_objects.update_column )
RETURN VARCHAR2
--</EC-DOC>
IS

   ln_value             NUMBER;
   ld_date              DATE;
   lv2_value            VARCHAR2(3200);
   lv2_text             VARCHAR2(3200);

BEGIN


   IF p_update_column.column_type IN ('NUMBER') THEN

      ln_value := p_update_column.column_data.accessnumber ;

      IF ln_value IS NULL THEN
         lv2_value := 'NULL';
      ELSE
         lv2_value := TO_CHAR(ln_value,'9999999999999999D9999999999','NLS_NUMERIC_CHARACTERS=''.,''') ;
      END IF;

   ELSIF p_update_column.column_type IN ('INTEGER') THEN

      ln_value := p_update_column.column_data.accessnumber ;

      IF ln_value IS NULL THEN
         lv2_value := 'NULL';
      ELSE

         IF ln_value - FLOOR(ln_value) > 0 THEN

            Raise_Application_Error(-20107,'Value '||ln_value||' is not a valid INTEGER.'  );

         END IF;

         lv2_value := TO_CHAR(ln_value,'9999999999999999D9999999999','NLS_NUMERIC_CHARACTERS=''.,''') ;
      END IF;

   ELSIF p_update_column.column_type = 'DATE' THEN

      ld_date := p_update_column.column_data.accessdate;

      IF ld_date IS NOT NULL THEN
         lv2_value := ecdp_dynsql.date_to_string(ld_date);
      ELSE
         lv2_value := 'NULL' ;
      END IF;

   ELSIF p_update_column.column_type IN ('VARCHAR2','STRING','TEXT') THEN

      lv2_text := p_update_column.column_data.accessvarchar2;

      IF lv2_text IS NOT NULL THEN
         lv2_value := ''''|| REPLACE(lv2_text,'''','''''')||'''';
      ELSE
         lv2_value := 'NULL' ;
      END IF;

   ELSE

      Raise_Application_Error(-20108,'Unsupported data type '||p_update_column.column_type||' in Ecdp_objects.UpdateObjectDataTables .');

   END IF;

   RETURN lv2_value;

END getUpdateListValue;




--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : GetObjIDFromCode
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
FUNCTION GetObjIDFromCode(
  p_class_name          VARCHAR2,
  p_code                VARCHAR2
)
RETURN VARCHAR2
--</EC-DOC>


IS

	CURSOR c_object IS
	 SELECT min(object_id) object_id
	 FROM OBJECTS
	 WHERE (class_name = UPPER(p_class_name) OR
	 		  class_name IN (SELECT child_class FROM class_dependency_cnfg WHERE parent_class = UPPER(p_class_name) and dependency_type = 'IMPLEMENTS'))
	 AND code = p_code;

	lv2_return_val VARCHAR2(32);

BEGIN
  BEGIN
    SELECT min(object_id)
      INTO lv2_return_val
      FROM objects_table
      WHERE class_name = UPPER(p_class_name)
      AND code = p_code;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        lv2_return_val:= null;
  END;
    -- Search in the objects_table first
    -- If not found, search in the OBJECTS view
  IF lv2_return_val IS NULL THEN
    FOR cur_object IN c_object LOOP
      lv2_return_val := cur_object.object_id;
    END LOOP;
  END IF;

  RETURN lv2_return_val;

END GetObjIDFromCode;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : GetObjClassName
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
FUNCTION GetObjClassName(
  p_object_id VARCHAR2
)
RETURN VARCHAR2
--</EC-DOC>
IS

	CURSOR c_object IS
	 SELECT min(class_name) class_name
	 FROM OBJECTS
	 WHERE object_id = p_object_id;

  lv2_return_val class_cnfg.class_name%TYPE;

BEGIN
    BEGIN
    SELECT min(class_name) class_name
      INTO lv2_return_val
      FROM objects_table
      WHERE object_id = p_object_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          lv2_return_val:= null;
    END;
    -- Search in the table first
    -- If not found, search in the OBJECTS view
    IF lv2_return_val IS NULL THEN
      FOR cur_object IN c_object LOOP
        lv2_return_val := cur_object.class_name;
      END LOOP;
    END IF;

    RETURN lv2_return_val;

END GetObjClassName;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : GetObjCode
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
FUNCTION GetObjCode(
  p_object_id VARCHAR2
)
RETURN VARCHAR2
--</EC-DOC>
IS

	CURSOR c_object(cp_object_id VARCHAR2) IS
	 SELECT min(code) code
	 FROM objects
	 WHERE object_id = cp_object_id;

	lv2_return_val VARCHAR2(100);

BEGIN
  BEGIN
    SELECT min(code) code
    INTO lv2_return_val
    FROM objects_table
    WHERE object_id = p_object_id;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
        lv2_return_val:= null;
  END;
    -- Search in the objects_table first
    -- If not found, search in the OBJECTS view
  IF lv2_return_val IS NULL THEN
    FOR cur_object IN c_object(p_object_id) LOOP
      lv2_return_val := cur_object.code;
    END LOOP;
  END IF;

  RETURN lv2_return_val;

END GetObjCode;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : GetObjName
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
FUNCTION GetObjName(p_object_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2

  --</EC-DOC>

 IS

  CURSOR c_object(cp_object_id VARCHAR2, cp_daytime DATE) IS
    SELECT min(name) name
      FROM objects_version
     WHERE object_id = cp_object_id
       AND daytime <= cp_daytime
       AND Nvl(end_date, cp_daytime + 1) > cp_daytime;

  lv2_return_val VARCHAR2(1000);

BEGIN
  BEGIN
    SELECT min(name) name
      INTO lv2_return_val
      FROM objects_version_table
     WHERE object_id = p_object_id
       AND daytime <= p_daytime
       AND Nvl(end_date, p_daytime + 1) > p_daytime;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      lv2_return_val := null;
  END;
  -- Search in the table first
  -- If not found, search in the OBJECTS view
  IF lv2_return_val IS NULL THEN

    FOR cur_object IN c_object(p_object_id, p_daytime) LOOP

      lv2_return_val := cur_object.name;

    END LOOP;

    IF lv2_return_val IS NULL THEN
      FOR cur_object IN c_object(p_object_id, GetObjStartDate(p_object_id)) LOOP

        lv2_return_val := cur_object.name;

      END LOOP;

    END IF;
  END IF;

  RETURN lv2_return_val;

END GetObjName;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : GetObjDaytime
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
-- Behavior       : Mostly good
--
---------------------------------------------------------------------------------------------------
FUNCTION GetObjDaytime(p_object_id VARCHAR2, p_daytime DATE) RETURN DATE

--</EC-DOC>

 IS

  CURSOR c_object(cp_object_id VARCHAR2, cp_daytime DATE) IS
    SELECT min(daytime) daytime
      FROM objects_version
     WHERE object_id = cp_object_id
       AND daytime <= cp_daytime
       AND Nvl(end_date, cp_daytime + 1) > cp_daytime;

  lv2_return_val DATE;

BEGIN
  BEGIN
    SELECT min(daytime) daytime
      INTO lv2_return_val
      FROM objects_version_table
     WHERE object_id = p_object_id
       AND daytime <= p_daytime
       AND Nvl(end_date, p_daytime + 1) > p_daytime;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      lv2_return_val := null;
  END;
  -- Search in the table first
  -- If not found, search in the OBJECTS view
  IF lv2_return_val IS NULL THEN

    FOR cur_object IN c_object(p_object_id, p_daytime) LOOP

      lv2_return_val := cur_object.daytime;

    END LOOP;

    IF lv2_return_val IS NULL THEN
      FOR cur_object IN c_object(p_object_id, GetObjStartDate(p_object_id)) LOOP

        lv2_return_val := cur_object.daytime;

      END LOOP;

    END IF;
  END IF;

  RETURN lv2_return_val;

END GetObjDaytime;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : GetObjStartDate
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
FUNCTION GetObjStartDate(
  p_object_id VARCHAR2
)
RETURN DATE
--</EC-DOC>
IS

	CURSOR c_object IS
	 SELECT start_date
	 FROM OBJECTS
	 WHERE object_id = p_object_id;

	lv2_return_val DATE;

BEGIN

   BEGIN
    SELECT min(start_date)
      INTO lv2_return_val
      FROM OBJECTS_TABLE
     WHERE object_id = p_object_id;
   EXCEPTION WHEN NO_DATA_FOUND THEN
      lv2_return_val := null;
   END;

  -- Search in the table first
  -- If not found, search in the OBJECTS view
  IF lv2_return_val IS NULL THEN
     FOR cur_object IN c_object LOOP

      lv2_return_val := cur_object.start_date;

     END LOOP;
  END IF;

	 RETURN lv2_return_val;

END GetObjStartDate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : GetObjEndDate
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
FUNCTION GetObjEndDate(
  p_object_id VARCHAR2
)
RETURN DATE
--</EC-DOC>
IS

	CURSOR c_object IS
	 SELECT end_date
	 FROM objects
	 WHERE object_id = p_object_id;

	lv2_return_val DATE;

BEGIN

   BEGIN
    SELECT min(end_date)
      INTO lv2_return_val
      FROM OBJECTS_TABLE
     WHERE object_id = p_object_id;
   EXCEPTION WHEN NO_DATA_FOUND THEN
      lv2_return_val := null;
   END;
  -- Search in the table first
  -- If not found, search in the OBJECTS view
   IF lv2_return_val IS NULL THEN
     FOR cur_object IN c_object LOOP

      lv2_return_val := cur_object.end_date;

     END LOOP;
   END IF;

	 RETURN lv2_return_val;

END GetObjEndDate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : IsValidObjStartDate
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
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
FUNCTION IsValidObjStartDate(
                   p_object_id      VARCHAR2,
                   p_daytime        DATE)
RETURN VARCHAR2
--</EC-DOC>
IS

	ld_earliest_date_use	DATE;
	lv2_class_name 		class_cnfg.class_name%TYPE := EcDp_Objects.GetObjClassName(p_object_id);
	lv2_rel_object_id		VARCHAR2(32);

BEGIN

   IF p_daytime < EcDp_System_Constants.EARLIEST_DATE THEN
      Raise_Application_Error(-20109,'Start date for objects can not be before this systems earliest date: '||EcDp_System_Constants.EARLIEST_DATE );
   END IF;

   -- check against end date and prevent setting after end date
   IF p_daytime > GetObjEndDate(p_object_id) THEN
    	Raise_Application_Error(-20109,'New object start date cannot be set after object end date.' );
   END IF;

   -- perform integrity check against any dependent classes to ensure no data outside of object valid date range
   IF lv2_class_name IN ('WELL', 'WELL_BORE') THEN
	ld_earliest_date_use := GetFirstClassDaytimeRef(lv2_class_name, p_object_id, TRUE);
   ELSE
	ld_earliest_date_use := GetFirstClassDaytimeRef(lv2_class_name, p_object_id);
   END IF;

   IF p_daytime > ld_earliest_date_use THEN
   	Raise_Application_Error(-20125,'New object start_date can not be after '||TO_CHAR(ld_earliest_date_use,'dd.mm.yyyy')||
             ' because of references from other objects.' );
   END IF;

   -- perform check on parent start date when moving back in time
   lv2_rel_object_id := GetNonValidRelation(lv2_class_name, p_object_id, p_daytime);

   IF lv2_rel_object_id IS NOT NULL THEN
   	Raise_Application_Error(-20125,'New object start_date cannot be before '||TO_CHAR(EcDp_Objects.GetObjStartDate(lv2_rel_object_id),'dd.mm.yyyy')||
             ' because of reference to object '||EcDp_Objects.GetObjCode(lv2_rel_object_id));
   END IF;

	RETURN 'Y';

END IsValidObjStartDate;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : IsValidObjEndDate
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
FUNCTION IsValidObjEndDate(
   p_object_id  			VARCHAR2,
   p_daytime    			DATE
)
--</EC-DOC>
RETURN VARCHAR2
IS

	ld_start_date			DATE := GetObjStartDate(p_object_id);
	lv2_class_name			class_cnfg.class_name%TYPE := GetObjClassName(p_object_id);
   ld_latest_use			DATE;
	lv2_rel_object_id		VARCHAR2(32);

BEGIN


	IF p_daytime < ld_start_date THEN
    	Raise_Application_Error(-20110,'New object end date cannot be set prior to object start date.' );
   END IF;

   -- perform integrity check against any dependent classes to ensure no data outside of object valid date range
   --Ideally all objects need this checking. However due to uncertainties against performance issues, only WELL
   --and WELL_BORE will be tested. More thorough testing are needed before we allow it to works for objects
   --such as AREA/FCTY etc. The test will be very long!

   IF lv2_class_name IN ('WELL', 'WELL_BORE') THEN
   	ld_latest_use := getLastClassDaytimeRef(lv2_class_name, p_object_id, TRUE);
   ELSE
   	ld_latest_use := getLastClassDaytimeRef(lv2_class_name, p_object_id);
   END IF;

   IF p_daytime < ld_latest_use THEN
		Raise_Application_Error(-20126,'New object end_date can not be before '||
                              TO_CHAR(ld_latest_use,'dd.mm.yyyy')||' because of references from other objects.' );
   END IF;

   -- perform check on parent end date when moving forward in time
   lv2_rel_object_id := GetNonValidRelationEndDate(lv2_class_name, p_object_id, p_daytime);

   IF lv2_rel_object_id IS NOT NULL THEN
   	Raise_Application_Error(-20126,'New object end_date can not be before '||TO_CHAR(EcDp_Objects.GetObjStartDate(lv2_rel_object_id),'dd.mm.yyyy')||
             ' because of reference to object '||EcDp_Objects.GetObjCode(lv2_rel_object_id));
   END IF;

   RETURN 'Y';

END IsValidObjEndDate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : GetFirstClassDaytimeRef
-- Description    : Find the first daytime this object was referred by objects in another class
--                  used for checking if we can change an objects start date
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : class
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
FUNCTION GetFirstClassDaytimeRef(
   p_class_name VARCHAR2,
   p_object_id  VARCHAR2,
   p_recursive BOOLEAN DEFAULT FALSE,
   p_min_date DATE DEFAULT NULL

)
RETURN DATE

--</EC-DOC>

IS
   CURSOR c_child IS
    -- All classes own by p_class_name
    SELECT c.class_name, c.class_type, c.DB_OBJECT_OWNER, c.DB_OBJECT_NAME,  c.DB_WHERE_CONDITION , 'OBJECT_ID' DB_SQL_SYNTAX, 'Y' use_daytime
    FROM class_cnfg c
    WHERE c.owner_class_name = p_class_name
    AND   EcDp_ClassMeta_Cnfg.isReadOnly(c.class_name) = 'N'
    UNION ALL
    -- All data classes with a relation to p_class_name
    SELECT cr.to_class_name, c.class_type, c.DB_OBJECT_OWNER, c.DB_OBJECT_NAME,  c.DB_WHERE_CONDITION ,cr.DB_SQL_SYNTAX, 'Y' use_daytime
    FROM class_relation_cnfg cr, class_cnfg c
    WHERE cr.to_class_name = c.class_name
    AND   cr.from_class_name = p_class_name
    AND   c.class_type = 'DATA'
    UNION ALL
    -- All object classes with a non versioned relation to p_class_name
    SELECT c.class_name, c.class_type, c.db_object_owner, c.db_object_name, c.db_where_condition, cr.db_sql_syntax, 'N' use_daytime
    FROM class_relation_cnfg cr, class_cnfg c
    WHERE cr.to_class_name = c.class_name
    AND   cr.from_class_name = p_class_name
    AND   c.class_type = 'OBJECT'
    AND   cr.db_mapping_type = 'COLUMN'
    UNION ALL
    -- All object classes with a versioned relation/group relation to p_class_name
    SELECT c.class_name, c.class_type, c.db_object_owner, c.db_object_attribute db_object_name, c.db_where_condition, cr.db_sql_syntax, 'Y' use_daytime
    FROM class_relation_cnfg cr, class_cnfg c
    WHERE cr.to_class_name = c.class_name
    AND   cr.from_class_name = p_class_name
    AND   c.class_type = 'OBJECT'
    AND   cr.db_mapping_type = 'ATTRIBUTE'
    UNION ALL
    -- All data classes owned by interfaces used by this class
    SELECT c.class_name, c.class_type, c.DB_OBJECT_OWNER, c.DB_OBJECT_NAME,  c.DB_WHERE_CONDITION , 'OBJECT_ID' DB_SQL_SYNTAX, 'N' use_daytime
    FROM class_cnfg c, class_dependency_cnfg cy
    WHERE c.owner_class_name = cy.parent_class
    AND   cy.child_class = p_class_name
    AND   cy.dependency_type = 'IMPLEMENTS'
    AND   EcDp_ClassMeta_Cnfg.isReadOnly(c.class_name) = 'N';

   lv2_sql     		VARCHAR2(4000);
   ld_tempdate 		DATE;
   ld_mindate  		DATE := p_min_date;
   lv2_column		VARCHAR2(30);
   TYPE cv_type IS REF CURSOR;
   cv cv_type;
   lv2_object_id VARCHAR2(32);

BEGIN

   -- Need to loop all other classes that can refer to this object class

	FOR curChild IN c_child LOOP

		IF curChild.use_daytime = 'Y' THEN

      		lv2_column := 'daytime';

		ELSE

			lv2_column := 'start_date';

		END IF;

		lv2_sql := 	 ' SELECT min('||lv2_column||') FROM '||curChild.DB_OBJECT_OWNER||'.'||curChild.DB_OBJECT_NAME||CHR(10)||
        	         ' WHERE '||curChild.DB_SQL_SYNTAX||' = :p_object_id ';

      	BEGIN

			EXECUTE IMMEDIATE lv2_sql INTO ld_tempdate USING p_object_id ;

        	ld_mindate := least(Nvl(ld_mindate,ld_tempdate), Nvl(ld_tempdate,ld_mindate));

      	EXCEPTION
        	WHEN OTHERS THEN
           	NULL;   -- Continue with the last good min date, ignore that the lookup
                   -- for this class failed
      	END;

        IF p_recursive AND curChild.class_type = 'OBJECT' THEN
            OPEN cv FOR 'SELECT object_id FROM ' || curChild.DB_OBJECT_OWNER || '.' || curChild.DB_OBJECT_NAME ||
              ' WHERE ' || curChild.DB_SQL_SYNTAX || ' = :p_object_id' using p_object_id;
            LOOP
              FETCH cv INTO lv2_object_id;
              EXIT WHEN cv%NOTFOUND;

              -- this function call within loop may use too much of cursors. Try to put the items into varray and loop using it.
              ld_tempdate := GetFirstClassDaytimeRef(curChild.class_name, lv2_object_id, TRUE, ld_mindate);
              ld_mindate := LEAST(Nvl(ld_mindate,ld_tempdate), Nvl(ld_tempdate,ld_mindate));
            END LOOP;
            CLOSE cv;

        END IF;

   	END LOOP;

	RETURN ld_mindate;


END GetFirstClassDaytimeRef;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : GetNonValidRelation
-- Description    : Returns the object_id for related object with start date > p_daytime,
--						  used for checking if we can change an objects start date
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
FUNCTION GetNonValidRelation(
   p_class_name 				VARCHAR2,
   p_object_id  				VARCHAR2,
   p_daytime					DATE
)
RETURN VARCHAR2
--</EC-DOC>
IS

	CURSOR c_relation IS
	 SELECT crdm.db_sql_syntax, cdm.db_object_name,'VERSION' table_mode -- Group relations
	 FROM v_group_level v, class_relation_cnfg crdm, class_cnfg cdm
	 WHERE v.from_class_name = cdm.class_name
	 AND v.from_class_name = crdm.from_class_name
	 AND v.to_class_name = crdm.to_class_name
	 AND v.role_name = crdm.role_name
	 AND v.class_name = p_class_name
	UNION -- Non versioned relations
	 SELECT cr.db_sql_syntax, cdm.db_object_name,'MAIN' table_mode
	 FROM class_relation_cnfg cr, class_cnfg cdm
	 WHERE cr.from_class_name = cdm.class_name
	 AND cr.group_type is null
	 AND cr.db_mapping_type = 'COLUMN'
	 AND cr.to_class_name = p_class_name
	UNION -- Versioned relations
	 SELECT cr.db_sql_syntax, cdm.db_object_name,'VERSION' table_mode
	 FROM class_relation_cnfg cr, class_cnfg cdm
	 WHERE cr.from_class_name = cdm.class_name
	 AND cr.group_type is null
	 AND cr.db_mapping_type = 'ATTRIBUTE'
	 AND cr.to_class_name = p_class_name;

	lv2_sql					VARCHAR2(32000);
	lv2_version_table		class_cnfg.db_object_attribute%TYPE;
	lv2_main_table			class_cnfg.db_object_name%TYPE;
	lv2_table				VARCHAR2(100);
	lv2_relation_id		VARCHAR2(32);
	ld_start_date			DATE;
	lv2_tmp_id				VARCHAR2(32);

	CURSOR c_class IS
	 SELECT db_object_name,
	 		  db_object_attribute
	 FROM class_cnfg
	 WHERE class_name = p_class_name;

BEGIN

	FOR curClass IN c_class LOOP

		lv2_main_table := curClass.db_object_name;
		lv2_version_table	:= curClass.db_object_attribute;

	END LOOP;

	<<relations>>
	FOR curRel IN c_relation LOOP

		IF curRel.table_mode = 'MAIN' THEN
			lv2_table := lv2_main_table;
		ELSE
			lv2_table := lv2_version_table;
		END IF;

		lv2_sql := ' SELECT start_date, object_id'||CHR(10);
		lv2_sql := lv2_sql||' FROM '||curRel.db_object_name||' o'||CHR(10);
		lv2_sql := lv2_sql||' WHERE EXISTS('||CHR(10);
		lv2_sql := lv2_sql||'   SELECT 1 FROM '||lv2_table||CHR(10);
		lv2_sql := lv2_sql||'   WHERE object_id = :p_object_id'||CHR(10);
		lv2_sql := lv2_sql||'   AND '||curRel.db_sql_syntax||' = o.object_id)'||CHR(10);

		BEGIN

			EXECUTE IMMEDIATE lv2_sql INTO ld_start_date, lv2_tmp_id USING p_object_id;

			IF ld_start_date > p_daytime THEN -- found invalid relation
				lv2_relation_id := lv2_tmp_id;
				EXIT relations;
			END IF;

		EXCEPTION
			WHEN OTHERS THEN	-- Continue with the last good min date, ignore that the lookup
         	NULL; 			-- for this class failed
		END;

	END LOOP;

	RETURN lv2_relation_id;


END GetNonValidRelation;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : GetNonValidRelation
-- Description    : Returns the object_id for related object with start date > p_daytime,
--						  used for checking if we can change an objects start date
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
FUNCTION GetNonValidRelationEndDate(
   p_class_name 				VARCHAR2,
   p_object_id  				VARCHAR2,
   p_end_date					DATE
)
RETURN VARCHAR2
--</EC-DOC>
IS

	CURSOR c_relation IS
	 SELECT crdm.db_sql_syntax, cdm.db_object_name,'VERSION' table_mode -- Group relations
	 FROM v_group_level v, class_relation_cnfg crdm, class_cnfg cdm
	 WHERE v.from_class_name = cdm.class_name
	 AND v.from_class_name = crdm.from_class_name
	 AND v.to_class_name = crdm.to_class_name
	 AND v.role_name = crdm.role_name
	 AND v.class_name = p_class_name
	UNION -- Non versioned relations
	 SELECT cr.db_sql_syntax, cdm.db_object_name,'MAIN' table_mode
	 FROM class_relation_cnfg cr, class_cnfg cdm
	 WHERE cr.from_class_name = cdm.class_name
	 AND cr.group_type is null
	 AND cr.db_mapping_type = 'COLUMN'
	 AND cr.to_class_name = p_class_name
	UNION -- Versioned relations
	 SELECT cr.db_sql_syntax, cdm.db_object_name,'VERSION' table_mode
	 FROM class_relation_cnfg cr, class_cnfg cdm
	 WHERE cr.from_class_name = cdm.class_name
	 AND cr.group_type is null
	 AND cr.db_mapping_type = 'ATTRIBUTE'
	 AND cr.to_class_name = p_class_name;

	lv2_sql					VARCHAR2(32000);
	lv2_version_table		class_cnfg.db_object_attribute%TYPE;
	lv2_main_table			class_cnfg.db_object_name%TYPE;
	lv2_table				VARCHAR2(100);
	lv2_relation_id		VARCHAR2(32);
	ld_end_date			DATE;
	lv2_tmp_id				VARCHAR2(32);

	CURSOR c_class IS
	 SELECT db_object_name,
	 		  db_object_attribute
	 FROM class_cnfg
	 WHERE class_name = p_class_name;

BEGIN

	FOR curClass IN c_class LOOP

		lv2_main_table := curClass.db_object_name;
		lv2_version_table	:= curClass.db_object_attribute;

	END LOOP;

	<<relations>>
	FOR curRel IN c_relation LOOP

		IF curRel.table_mode = 'MAIN' THEN
			lv2_table := lv2_main_table;
		ELSE
			lv2_table := lv2_version_table;
		END IF;

		lv2_sql := ' SELECT nvl(end_date,EcDp_System_Constants.FUTURE_DATE()), object_id'||CHR(10);
		lv2_sql := lv2_sql||' FROM '||curRel.db_object_name||' o'||CHR(10);
		lv2_sql := lv2_sql||' WHERE EXISTS('||CHR(10);
		lv2_sql := lv2_sql||'   SELECT 1 FROM '||lv2_table||CHR(10);
		lv2_sql := lv2_sql||'   WHERE object_id = :p_object_id'||CHR(10);
		lv2_sql := lv2_sql||'   AND '||curRel.db_sql_syntax||' = o.object_id)'||CHR(10);

		BEGIN

			EXECUTE IMMEDIATE lv2_sql INTO ld_end_date, lv2_tmp_id USING p_object_id;

			IF ld_end_date < p_end_date THEN -- found invalid relation
				lv2_relation_id := lv2_tmp_id;
				EXIT relations;
			END IF;

		EXCEPTION
			WHEN OTHERS THEN	-- Continue with the last good min date, ignore that the lookup
         	NULL; 			-- for this class failed
		END;

	END LOOP;

	RETURN lv2_relation_id;


END GetNonValidRelationEndDate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : GetLastClassDaytimeRef
-- Description    : Find the last end_date this object was referred by objects in another class
--                  used for checking if we can change an objects end date
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : class
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      : Note, if object referring to this object has an open END_DATE, EcDp_System_Constants.Future_Date will be used.
---------------------------------------------------------------------------------------------------
FUNCTION GetLastClassDaytimeRef(
   p_class_name VARCHAR2,
   p_object_id  VARCHAR2,
   p_recursive BOOLEAN DEFAULT FALSE,
   p_max_date DATE DEFAULT NULL
)
RETURN DATE

--</EC-DOC>

IS

	CURSOR c_child IS
	 -- All classes own by p_class_name
    SELECT c.class_name, c.class_type, c.DB_OBJECT_OWNER, c.DB_OBJECT_NAME,  c.DB_WHERE_CONDITION , 'OBJECT_ID' DB_SQL_SYNTAX
    FROM class_cnfg c
    WHERE c.owner_class_name = p_class_name
    AND   Ecdp_ClassMeta_Cnfg.isReadOnly(c.class_name) = 'N'
    UNION ALL
    -- All data classes with a relation to p_class_name
    SELECT cr.to_class_name, c.class_type, c.DB_OBJECT_OWNER, c.DB_OBJECT_NAME,  c.DB_WHERE_CONDITION ,cr.DB_SQL_SYNTAX
    FROM class_relation_cnfg cr, class_cnfg c
    WHERE cr.to_class_name = c.class_name
    AND   cr.from_class_name = p_class_name
    AND   c.class_type = 'DATA'
    AND   Ecdp_ClassMeta_Cnfg.isReadOnly(c.class_name) = 'N'
    UNION ALL
    -- All object classes with a non versioned relation to p_class_name
    SELECT c.class_name, c.class_type, c.db_object_owner, c.db_object_name, c.db_where_condition, cr.db_sql_syntax
    FROM class_relation_cnfg cr, class_cnfg c
    WHERE cr.to_class_name = c.class_name
    AND   cr.from_class_name = p_class_name
    AND   c.class_type = 'OBJECT'
    AND   cr.db_mapping_type = 'COLUMN'
    AND   Ecdp_ClassMeta_Cnfg.isReadOnly(c.class_name) = 'N'
    UNION ALL
    -- All object classes with a versioned relation/group relation to p_class_name
    SELECT c.class_name, c.class_type, c.db_object_owner, c.db_object_attribute db_object_name, c.db_where_condition, cr.db_sql_syntax
    FROM class_relation_cnfg cr, class_cnfg c
    WHERE cr.to_class_name = c.class_name
    AND   cr.from_class_name = p_class_name
    AND   c.class_type = 'OBJECT'
    AND   cr.db_mapping_type = 'ATTRIBUTE'
    AND   Ecdp_ClassMeta_Cnfg.isReadOnly(c.class_name) = 'N'
    UNION ALL
    -- All data classes owned by interfaces used by this class
    SELECT c.class_name, c.class_type, c.DB_OBJECT_OWNER, c.DB_OBJECT_NAME,  c.DB_WHERE_CONDITION , 'OBJECT_ID' DB_SQL_SYNTAX
    FROM class_cnfg c, class_dependency_cnfg cy
    WHERE c.owner_class_name = cy.parent_class
    AND   cy.child_class = p_class_name
    AND   cy.dependency_type = 'IMPLEMENTS'
    AND   Ecdp_ClassMeta_Cnfg.isReadOnly(c.class_name) = 'N';

   lv2_sql     VARCHAR2(4000);
   lv2_sql_2   VARCHAR2(4000);
   ld_tempdate DATE;
   ld_maxdate  DATE := p_max_date;
   lv2_column  VARCHAR2(30);
   TYPE cv_type IS REF CURSOR;
   cv cv_type;
   lv2_object_id VARCHAR2(32);


BEGIN

   -- Need to loop all other updatable classes that can refer to this object class

	FOR curChild IN c_child LOOP

		lv2_sql := 'SELECT max(nvl(end_date,EcDp_System_Constants.FUTURE_DATE)) FROM '||curChild.DB_OBJECT_OWNER||'.'||curChild.DB_OBJECT_NAME||CHR(10)||
        	         ' WHERE '||curChild.DB_SQL_SYNTAX||' = :p_object_id ';
		lv2_sql_2 := 'SELECT max(DAYTIME) FROM '||curChild.DB_OBJECT_OWNER||'.'||curChild.DB_OBJECT_NAME||CHR(10)||
        	         ' WHERE '||curChild.DB_SQL_SYNTAX||' = :p_object_id ';

      BEGIN

			EXECUTE IMMEDIATE lv2_sql INTO ld_tempdate USING p_object_id ;

        	ld_maxdate := GREATEST(Nvl(ld_maxdate,ld_tempdate), Nvl(ld_tempdate,ld_maxdate));

      EXCEPTION
      	WHEN OTHERS THEN
	      BEGIN

				EXECUTE IMMEDIATE lv2_sql_2 INTO ld_tempdate USING p_object_id ;

	        	ld_maxdate := GREATEST(Nvl(ld_maxdate,ld_tempdate), Nvl(ld_tempdate,ld_maxdate));

	      EXCEPTION
	      	WHEN OTHERS THEN
	           	NULL;   -- Continue with the last good max date, ignore that the lookup
	                   -- for this class failed
	      END;
      END;

      IF p_recursive AND curChild.class_type = 'OBJECT' THEN
        OPEN cv FOR 'SELECT object_id FROM ' || curChild.DB_OBJECT_OWNER || '.' || curChild.DB_OBJECT_NAME ||
          ' WHERE ' || curChild.DB_SQL_SYNTAX || ' = :p_object_id' using p_object_id;
        LOOP
          FETCH cv INTO lv2_object_id;
          EXIT WHEN cv%NOTFOUND;

          -- this function call within loop may use too much of cursors. Try to put the items into varray and loop using it.
          ld_tempdate := GetLastClassDaytimeRef(curChild.class_name, lv2_object_id, TRUE, ld_maxdate);
          ld_maxdate := GREATEST(Nvl(ld_maxdate,ld_tempdate), Nvl(ld_tempdate,ld_maxdate));
        END LOOP;
       CLOSE cv;

   END IF;

   END LOOP;

	RETURN ld_maxdate;


END GetLastClassDaytimeRef;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : DelObj
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
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE DelObj(
   p_object_id VARCHAR2
)
--</EC-DOC>
IS

   lv2_class_name       class_cnfg.class_name%TYPE := Ecdp_Objects.GetObjClassName(p_object_id);
   lv2_sql              VARCHAR2(3200);
   lv2_main_table			VARCHAR2(100);
   lv2_version_table		VARCHAR2(100);

BEGIN
	lv2_main_table := EcDp_ClassMeta.GetClassDBTable(lv2_class_name);
	lv2_version_table := EcDp_ClassMeta.getClassDBAttributeTable(lv2_class_name);

	--Not allowed to delete read only objects
	IF EcDp_ClassMeta.IsReadOnlyClass(lv2_class_name) = 'Y' THEN
		Raise_Application_Error(-20102,'Cannot delete '||GetObjCode(p_object_id)||' because the class '||lv2_class_name||' is defined as read only');
	END IF;


    lv2_sql := 'DELETE FROM '||lv2_version_table||' WHERE object_id = :p_object_id';

    EXECUTE IMMEDIATE lv2_sql using p_object_id;

    lv2_sql := 'DELETE FROM '||lv2_main_table||' WHERE object_id = :p_object_id';

    EXECUTE IMMEDIATE lv2_sql using p_object_id;

END DelObj;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : isValidOwnerReference
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : class
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
--
---------------------------------------------------------------------------------------------------
FUNCTION isValidOwnerReference(
   p_class_name VARCHAR2,
   p_object_id  VARCHAR2
)
RETURN VARCHAR2
--</EC-DOC>

IS
   CURSOR c_interface (p_parent_class VARCHAR2, p_child_class VARCHAR2) IS
	 SELECT 1
    FROM class_dependency_cnfg c
    WHERE c.child_class  = p_child_class
    AND   c.parent_class = p_parent_class
    AND   c.dependency_type = 'IMPLEMENTS';

	lv2_class_name 			VARCHAR2(30);
  	lv2_owner_class_name 	VARCHAR2(30);
  	lv2_result 					VARCHAR2(1) := 'N';

BEGIN

   -- First check if we got a direct match

  lv2_class_name := ecdp_objects.getobjclassname(p_object_id);
  lv2_owner_class_name :=  ecdp_classmeta.ownerclassname(p_class_name);

  IF lv2_class_name = lv2_owner_class_name THEN

    lv2_result := 'Y';

  ELSE

      FOR curInterface IN c_interface(lv2_owner_class_name,lv2_class_name) LOOP

            lv2_result := 'Y';

      END LOOP;

   END IF;

	RETURN lv2_result;

END;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : isValidClassReference
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : class
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
--
---------------------------------------------------------------------------------------------------
FUNCTION isValidClassReference(
   p_class_name VARCHAR2,
   p_object_id  VARCHAR2
)
RETURN VARCHAR2
--</EC-DOC>

IS

	CURSOR c_interface (p_parent_class VARCHAR2, p_child_class VARCHAR2) IS
    SELECT 1
    FROM class_dependency_cnfg c
    where child_class  = p_child_class
    and c.dependency_type = 'IMPLEMENTS'
    start with c.parent_class=p_parent_class
    connect by prior c.child_class=c.parent_class;


	CURSOR c_object_type IS
    SELECT 1
    FROM objects o
    where class_name   = p_class_name
    AND   object_id    = p_object_id;


	lv2_class_name 			VARCHAR2(30);
  	lv2_owner_class_name 	VARCHAR2(30);
  	lv2_result 					VARCHAR2(1) := 'N';

BEGIN

   lv2_class_name := ecdp_objects.getobjclassname(p_object_id);
   -- First check if we got a direct match
    BEGIN
      SELECT 'Y'
      INTO lv2_result
      FROM objects_table o
      where class_name   = p_class_name
      AND   object_id    = p_object_id
      AND ROWNUM = 1;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      lv2_result := 'N';
    END;
  -- Search in the table first
  -- If not found, search in the OBJECTS view
    IF lv2_result = 'N' THEN
      FOR curObj IN c_object_type LOOP

              lv2_result := 'Y';

      END LOOP;
    END IF;

   IF lv2_result = 'N' THEN --see if it is part of an interface

      FOR curInterface IN c_interface(p_class_name,lv2_class_name) LOOP

            lv2_result := 'Y';

      END LOOP;

   END IF;

	RETURN lv2_result;

END isValidClassReference;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : GetInsertedDaytime
-- Description    : Used in object trigger to get object id on insert
--
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
-- Behavior       :
--
--
--
---------------------------------------------------------------------------------------------------
FUNCTION  GetInsertedDaytime(p_object_start_date DATE,
									  p_daytime DATE,
									  p_object_end_date DATE)
RETURN DATE
--</EC-DOC>

IS
  ld_daytime  DATE;
  lv2_err     VARCHAR2(500);

BEGIN

   IF p_object_start_date < EcDp_System_Constants.EARLIEST_DATE THEN

      Raise_Application_Error(-20109,'Start date for objects can not be before this systems earliest date: '||EcDp_System_Constants.EARLIEST_DATE );

   END IF;

   IF p_object_start_date IS NULL AND p_daytime IS NULL THEN
     Raise_Application_Error(-20103,'Missing value for DAYTIME and OBJECT_START_DATE, you must provide at least 1 of these.');
   ELSIF p_object_start_date IS NOT NULL AND p_daytime IS NOT NULL
   AND   p_object_start_date <> p_daytime THEN
     Raise_Application_Error(-20127,'On insert DAYTIME cannot be different from OBJECT_START_DATE.');
   ELSIF p_daytime IS NULL THEN
     ld_daytime := p_object_start_date;
   ELSE
     ld_daytime := p_daytime;
   END IF;

   IF p_object_end_date IS NOT NULL AND p_object_end_date <= ld_daytime THEN
     Raise_Application_Error(-20126,'On insert OBJECT_END_DATE must be greater than OBJECT_START_DATE.');
   END IF;

   RETURN ld_daytime;

END GetInsertedDaytime;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : GetInsertedRelationID
-- Description    : Used in object trigger to check and set object_id for an object relation
--
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
-- Behavior       :
--
--
--
---------------------------------------------------------------------------------------------------
FUNCTION  GetInsertedRelationID(
			p_role_name 			VARCHAR2,
			p_rel_class_name 		VARCHAR2,
			p_new_rel_object_id 	VARCHAR2,
			p_new_object_code 	VARCHAR2,
			p_daytime				DATE)
RETURN VARCHAR2
--</EC-DOC>

IS
  lv2_object_id  				VARCHAR2(32);

BEGIN

	IF p_new_rel_object_id IS NULL AND p_new_object_code IS NULL THEN
		RETURN NULL;
	END IF;

  	IF p_new_rel_object_id IS NULL AND p_new_object_code IS NOT NULL THEN
   	lv2_object_id := EcDp_Objects.GetObjIDFromCode(p_rel_class_name,p_new_object_code);
  	ELSE
   	lv2_object_id := p_new_rel_object_id;
 	END IF;

	IF lv2_object_id IS NULL THEN
   	Raise_Application_Error(-20106,'Foreign key not found, '||p_role_name||' does not exist.');
   END IF;

 	IF lv2_object_id IS NOT NULL AND EcDp_objects.isValidClassReference(p_rel_class_name,lv2_object_id) =  'N' THEN
   	Raise_Application_Error(-20106,'Referenced '||p_role_name||' is not an object of type '||p_rel_class_name||' .' );
 	END IF;

 	IF p_daytime < EcDp_Objects.GetObjStartDate(lv2_object_id) THEN
 		Raise_Application_Error(-20106,'Referred object '||EcDp_Objects.GetObjCode(lv2_object_id)||' has a start date later than this objects start date.');
 	END IF;

 	IF Nvl(EcDp_Objects.GetObjEndDate(lv2_object_id),p_daytime + 1) < p_daytime THEN
   	Raise_Application_Error(-20106,'Referred object '||EcDp_Objects.GetObjCode(lv2_object_id)||' has an end date prior this objects start date.');
   END IF;

 RETURN lv2_object_id;

END GetInsertedRelationID;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : GetUpdatedRelationID
-- Description    : Used in object trigger to check and set object_id for an object relation
--
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
-- Behavior       :
--
--
--
---------------------------------------------------------------------------------------------------
FUNCTION GetUpdatedRelationID(
				p_upd_id 				BOOLEAN,
				p_upd_code 				BOOLEAN,
				p_role_name 			VARCHAR2,
				p_rel_class_name 		VARCHAR2,
				p_new_rel_object_id 	VARCHAR2,
				p_new_object_code 	VARCHAR2,
				p_daytime 				DATE)
RETURN VARCHAR2
--</EC-DOC>
IS

	lv2_object_id  VARCHAR2(32);

BEGIN

	IF p_upd_id AND p_new_rel_object_id IS NULL AND NOT p_upd_code THEN

   	lv2_object_id := NULL;

 	ELSIF p_upd_code AND ( NOT p_upd_id OR p_new_rel_object_id IS NULL )  THEN

   	IF p_new_object_code IS NOT NULL THEN

      	lv2_object_id := EcDp_Objects.GetObjIDFromCode(p_rel_class_name,p_new_object_code);

      	IF lv2_object_id IS NULL THEN

          	Raise_Application_Error(-20106,'Foreign key not found, '||p_role_name||' does not exist.');

      	END IF;

   	ELSE

      	lv2_object_id := NULL;

   	END IF;

 	ELSIF p_upd_id THEN

    	lv2_object_id := p_new_rel_object_id;

 	END IF;

 	IF lv2_object_id IS NOT NULL THEN

   	IF EcDp_Objects.getOBjStartDate(lv2_object_id) > p_daytime THEN
   	 	Raise_Application_Error(-20106,'Referred object '||EcDp_Objects.GetObjCode(lv2_object_id)||' has a start date later than this objects start date.');
   	END IF;

   	IF Nvl(EcDp_Objects.GetObjEndDate(lv2_object_id),p_daytime + 1) < p_daytime THEN
   		Raise_Application_Error(-20106,'Referred object '||EcDp_Objects.GetObjCode(lv2_object_id)||' has an end date prior this objects start date.');
   	END IF;

    	IF EcDp_objects.isValidClassReference(p_rel_class_name,lv2_object_id) =  'N' THEN
      	Raise_Application_Error(-20106,'Referenced '||p_role_name||'('||lv2_object_id||') is not an object of type '||p_rel_class_name||' .' );
    	END IF;

  	END IF;

  	-- No changes, return old relation id
  	IF NOT p_upd_id AND NOT p_upd_code THEN
  		lv2_object_id := p_new_rel_object_id;
  	END IF;

	RETURN lv2_object_id;

END GetUpdatedRelationID;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : GetInsertedObjectID
-- Description    : Used in object trigger to get object id on insert
--
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
-- Behavior       :
--
--
--
---------------------------------------------------------------------------------------------------
FUNCTION  GetInsertedObjectID(p_new_rel_object_id VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>

IS
  lv2_object_id  VARCHAR2(32);
  lv2_err        VARCHAR2(500);

BEGIN

   IF p_new_rel_object_id IS NULL THEN
     lv2_object_id := SYS_GUID();
   ELSE -- giving object_id on insert is allowed
     lv2_object_id := p_new_rel_object_id;
     -- But it must be unique, so check that
     IF  EcDp_Objects.GetObjClassName(lv2_object_id) IS NOT NULL THEN
       Raise_Application_Error(-20105,'Unique constraint violated. An object with that object_id already exists.');
     END IF;
   END IF;

   RETURN lv2_object_id;

END;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : IfDollarStr
-- Description    : Returns the alternativ string if the first = $$$$
--
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
-- Behavior       :
--
--
--
---------------------------------------------------------------------------------------------------
FUNCTION  IfDollarStr(p_condition VARCHAR2,p1 VARCHAR2, p2 VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>

IS
  lv2_str     VARCHAR2(32000);

BEGIN

  IF p_condition = 'Y' AND Nvl(p1,'X') <> '$$$$' THEN

     lv2_str := p1;

  ELSE

     lv2_str := p2;

  END IF;

  RETURN lv2_str;

END;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : CheckObjectAccess
-- Description    : Check if the current user have access to a given object_id in a object class
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
FUNCTION CheckObjectAccess(p_object_id VARCHAR2, p_object_class_name VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2
--</EC-DOC>

IS

  lv2_sql    VARCHAR2(2000);
  ln_result  NUMBER;
  lv2_result VARCHAR2(1);
  lv2_class_name VARCHAR2(2000);
  lv2_view_name VARCHAR2(2000);

BEGIN
  IF p_object_class_name IS NULL AND p_object_id IS NOT NULL THEN
    lv2_class_name := ecdp_objects.GetObjClassName(p_object_id);
  ELSE
    lv2_class_name :=  p_object_class_name;
  END IF;

  lv2_view_name := ecdp_classmeta.getClassViewName(lv2_class_name);

  IF lv2_view_name IS NOT NULL AND p_object_id IS NOT NULL THEN

    lv2_sql := ' SELECT count(*) FROM '||lv2_view_name||' WHERE object_id = '''||p_object_id||'''';

    EXECUTE IMMEDIATE lv2_sql INTO ln_result;

    IF ln_result < 1 THEN
      lv2_result := 'N';
    ELSE
      lv2_result := 'Y';
    END IF;

  ELSE -- If the row has no class and row reference don't enforce ringfencing on it

      lv2_result := 'Y';

  END IF;

  RETURN lv2_result;

END;

END EcDp_Objects;