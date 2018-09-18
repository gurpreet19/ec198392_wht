CREATE OR REPLACE PACKAGE BODY EcDp_Collection_Point IS

/****************************************************************
** Package        :  EcDp_Collection_Point, body part
**
** $Revision: 1.6 $
**
** Purpose        :  Allows reorganize groups of objects from one Collection Point to another.
**
** Documentation  :  www.energy-components.com
**
** Created  : 31.12.2012  Suresh
**
** Modification history:
**
** Version  Date       Whom     Change description:
** -------  ------     -----    --------------------------------------
**    1.0   31.12.2012 kumarsur ECPD-22968 Collection Point Hierarchy Reorganization business function.
**    1.1   25.11.2013 choooshu ECPD-24631 Modified updateVersion and insertVersion to raise any errors from executing the statement
**    1.2   31.08.2016 dhavaalo ECPD-38607:Remove usage of EcDp_Utilities.executeSinglerowString and EcDp_Utilities.executeStatement
**          19.10.2016 singishi ECPD-32618 Change the UPDATE statement for PTST_RESULT to include both last_update_by and last_update_date for revision info
*****************************************************************/

lv_update_rev_text constant VARCHAR2(32000) := 'Updated by Collection Point Hierarchy Reorganization';
lv_insert_rev_text constant VARCHAR2(32000) := 'Created by Collection Point Hierarchy Reorganization';

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : executeStatement                                                          --
-- Description    : Used to run Dyanamic sql statements.
--                                                                                               --
-- Preconditions  :                --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                --
--                                                                                               --
-- Using functions:                                                 --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION executeStatement(
p_statement varchar2)

RETURN VARCHAR2
--</EC-DOC>
IS

li_cursor  integer;
li_ret_val  integer;
lv2_err_string VARCHAR2(32000);

BEGIN

   li_cursor := DBMS_SQL.open_cursor;

   DBMS_SQL.parse(li_cursor,p_statement,DBMS_SQL.v7);
   li_ret_val := DBMS_SQL.execute(li_cursor);
   DBMS_SQL.Close_Cursor(li_cursor);

  RETURN NULL;

EXCEPTION
   WHEN DUP_VAL_ON_INDEX THEN
       DBMS_SQL.Close_Cursor(li_cursor);

    -- record not inserted, already there...
    lv2_err_string := 'Failed to execute (record exists): ' || chr(10) || p_statement || chr(10);
    return lv2_err_string;
  WHEN INVALID_CURSOR THEN

    lv2_err_string := 'Failed to execute (' || SQLERRM || '): ' || chr(10) || p_statement || chr(10);
    return lv2_err_string;

  WHEN OTHERS THEN
    IF DBMS_SQL.is_open(li_cursor) THEN
      DBMS_SQL.Close_Cursor(li_cursor);
      END IF;

    lv2_err_string := 'Failed to execute (' || SQLERRM || '): ' || chr(10) || p_statement || chr(10);
    return lv2_err_string;

END executeStatement;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : executeSinglerowString                                                       --
-- Description    : Executes a dynamic SQL SELECT which returns 1 row of type VARCHAR2.          --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION executeSinglerowString(p_statement VARCHAR2) RETURN VARCHAR2
--</EC-DOC>
IS

li_cursor      INTEGER;
li_returverdi   INTEGER;
lv2_return_value VARCHAR2(32000);

BEGIN

   li_cursor := DBMS_SQL.Open_Cursor;

   DBMS_SQL.Parse(li_cursor,p_statement,DBMS_SQL.v7);
   DBMS_SQL.Define_Column(li_cursor,1,lv2_return_value, 2000);

   li_returverdi := DBMS_SQL.Execute(li_cursor);

   IF DBMS_SQL.Fetch_Rows(li_cursor) = 0 THEN

     lv2_return_value := NULL;

   ELSE

      DBMS_SQL.Column_Value(li_cursor,1, lv2_return_value);

   END IF;

   DBMS_SQL.Close_Cursor(li_cursor);

   RETURN lv2_return_value;

EXCEPTION

  WHEN OTHERS THEN

      IF  DBMS_SQL.is_open(li_cursor) THEN
         DBMS_SQL.Close_Cursor(li_cursor);
      END IF;

   RETURN NULL;

END executeSinglerowString;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : createNewVersion                                                             --
-- Description    : A new version of each object would have their Collection Point    			 --
--					set to the new Collection Point value.                                       --
--                                                                                               --
-- Preconditions  :  	                                                                         --
-- Postconditions : 	                                                                         --
-- Using tables   :                                                                              --
-- Using functions:                                               								 --
-- Configuration                                                                                 --
-- required       :                                                                              --
-- Behaviour      : 																			 --
---------------------------------------------------------------------------------------------------

PROCEDURE createNewVersion(p_object_id VARCHAR2,
							p_object_type VARCHAR2,
							p_daytime VARCHAR2,
							p_col_point_id VARCHAR2,
							p_user VARCHAR2)
--</EC-DOC>
	IS
		lv2_wellCount NUMBER;
		lv_sql       VARCHAR2(32000);
		lv_daytime   DATE;

	BEGIN
	  lv_daytime := to_date(p_daytime, 'YYYY-MM-DD"T"HH24:MI:SS');

	  insertVersion(p_object_id, p_object_type, lv_daytime, p_col_point_id, p_user);

	  IF p_object_type = 'WELL' THEN
			 SELECT COUNT(*) INTO lv2_wellCount FROM PTST_RESULT P , PWEL_RESULT R
			 WHERE P.RESULT_NO = R.RESULT_NO
			 AND R.OBJECT_ID = p_object_id
			 AND P.DAYTIME >= lv_daytime;

			 IF lv2_wellCount > 0 THEN
				updateProdTestResultDaytime(p_object_id, lv_daytime, p_col_point_id, p_user);
			END IF;
	  END IF;

END createNewVersion;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : changeAllVersions                                                            --
-- Description    : All versions of the objects would have their Collection Point                --
--                  updated to the new value.                                                    --
--                                                                                               --
-- Preconditions  :  	                                                                         --
-- Postconditions : 	                                                                         --
-- Using tables   :                                                                              --
-- Using functions:                                               								 --
-- Configuration                                                                                 --
-- required       :                                                                              --
-- Behaviour      : 																			 --
---------------------------------------------------------------------------------------------------

PROCEDURE changeAllVersions(p_object_id VARCHAR2,
							p_object_type VARCHAR2,
							p_col_point_id VARCHAR2,
							p_user VARCHAR2)
--</EC-DOC>
	IS
		lv2_wellCount NUMBER;
		lv_sql       VARCHAR2(32000);

	BEGIN

	updateVersion(p_object_id, p_object_type, p_col_point_id, p_user);
    IF p_object_type = 'WELL' THEN

			SELECT COUNT(*) INTO lv2_wellCount FROM PTST_RESULT P , PWEL_RESULT R
			WHERE P.RESULT_NO = R.RESULT_NO
			AND R.OBJECT_ID = p_object_id;

			IF lv2_wellCount > 0 THEN
				updateProdTestResult(p_object_id, p_col_point_id, p_user);
			END IF;
    END IF;

END changeAllVersions;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : updateVersion                                                       --
-- Description    : Update new Collection Point value to all versions of the selected Equipment,  --
--                  Well, Tank and Stream                                                                            --
-- Preconditions  :  	                                                                         --
-- Postconditions : 	                                                                         --
-- Using tables   :                                                                              --
-- Using functions:                                               								 --
-- Configuration                                                                                 --
-- required       :                                                                              --
-- Behaviour      : Update all version of the Objects's Collection Point to 				     --
--					new Collection Point value.												     --
---------------------------------------------------------------------------------------------------

PROCEDURE updateVersion(p_object_id VARCHAR2,
							p_object_type VARCHAR2,
							p_col_point_id VARCHAR2,
							p_user VARCHAR2)
--</EC-DOC>
IS
	lv_sql       VARCHAR2(32000);
	lv_result     VARCHAR2(4000);

BEGIN

	lv_sql := 'update ov_'|| p_object_type ||'
			set CP_COL_POINT_ID = '''||p_col_point_id||''',
				rev_text = '''||lv_update_rev_text||''',
				LAST_UPDATED_BY = '''||p_user||'''
			where OBJECT_ID = '''||p_object_id||'''';

	 lv_result := executeStatement(lv_sql);

	 IF lv_result IS NOT NULL THEN
       RAISE_APPLICATION_ERROR(-20000,lv_result);
     END IF;

END updateVersion;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : insertVersion                                                                --
-- Description    : Creates a new version for the Equipment, Well, Tank and Stream and set       --
--                  the Collection Point value.                                                  --
-- Preconditions  :  	                                                                         --
-- Postconditions : 	                                                                         --
-- Using tables   :                                                                              --
-- Using functions:                                               								 --
-- Configuration                                                                                 --
-- required       :                                                                              --
-- Behaviour      : Get the latest Version's daytime for the date selected.                      --
--					Call OV_class to create a new Version for the date.		    			     --
---------------------------------------------------------------------------------------------------

PROCEDURE insertVersion(p_object_id VARCHAR2,
							p_object_type VARCHAR2,
							p_daytime DATE,
							p_col_point_id VARCHAR2,
							p_user VARCHAR2)
--</EC-DOC>
IS
	lv2_daytime  VARCHAR2(20);
	lv_sql       VARCHAR2(32000);
	lv_result     VARCHAR2(4000);

BEGIN

	lv_sql := 'select to_char(MAX(DAYTIME), ''YYYY-MM-DD"T"HH24:MI:SS'') from ov_'|| p_object_type ||' where OBJECT_ID = '''||p_object_id||'''';
	lv2_daytime := executeSingleRowString(lv_sql);

	IF to_date(lv2_daytime, 'YYYY-MM-DD"T"HH24:MI:SS') < to_date(to_char(p_daytime,'YYYY-MM-DD"T"HH24:MI:SS'), 'YYYY-MM-DD"T"HH24:MI:SS') THEN
		lv_sql := 'update ov_'|| p_object_type ||'
				set DAYTIME = to_date('''||to_char(p_daytime,'YYYY-MM-DD"T"HH24:MI:SS')||''', ''YYYY-MM-DD"T"HH24:MI:SS''),
					CP_COL_POINT_ID = '''||p_col_point_id||''',
					rev_text = '''||lv_insert_rev_text||''',
					LAST_UPDATED_BY = '''||p_user||'''
				where OBJECT_ID = '''||p_object_id||'''
				and daytime = to_date('''||lv2_daytime||''', ''YYYY-MM-DD"T"HH24:MI:SS'')';

		lv_result := executeStatement(lv_sql);

		IF lv_result IS NOT NULL THEN
			RAISE_APPLICATION_ERROR(-20000,lv_result);
		END IF;
	ELSE
		RAISE_APPLICATION_ERROR(-20000,'Not allowed to create an in-between version of the object.');
	END IF;

END insertVersion;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : updateProdTestResult                                                         --
-- Description    : Update new Collection Point value to Well on test					         --
--                                                                                               --
-- Preconditions  :  	                                                                         --
-- Postconditions : 	                                                                         --
-- Using tables   :   			                                                                 --
-- Using functions:                                               								 --
-- Configuration                                                                                 --
-- required       :                                                                              --
-- Behaviour      : Update Well on test Collection Point to 									 --
--					new Collection Point value.												     --
---------------------------------------------------------------------------------------------------

PROCEDURE updateProdTestResult(p_object_id VARCHAR2,
							p_col_point_id VARCHAR2,
							p_user VARCHAR2)
--</EC-DOC>
IS

BEGIN

      update PTST_RESULT
      set COLLECTION_POINT_ID = p_col_point_id,
				rev_text = lv_update_rev_text,
				LAST_UPDATED_BY = p_user,
				LAST_UPDATED_DATE = Ecdp_Timestamp.getCurrentSysdate
			where RESULT_NO IN (SELECT result_no FROM pwel_result WHERE object_id = p_object_id);

END updateProdTestResult;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : updateProdTestResultDaytime                                                  --
-- Description    : Update new Collection Point value to Well on test starting from the date     --
--                  new version been created.                                                    --
-- Preconditions  :  	                                                                         --
-- Postconditions : 	                                                                         --
-- Using tables   :   			                                                                 --
-- Using functions:                                               								 --
-- Configuration                                                                                 --
-- required       :                                                                              --
-- Behaviour      : Update Well on test Collection Point to 									 --
--					new Collection Point value from the date new version been created.		     --
---------------------------------------------------------------------------------------------------

PROCEDURE updateProdTestResultDaytime(p_object_id VARCHAR2,
							p_daytime DATE,
							p_col_point_id VARCHAR2,
							p_user VARCHAR2)
--</EC-DOC>
IS

BEGIN

      update PTST_RESULT
      set COLLECTION_POINT_ID = p_col_point_id,
				rev_text = lv_insert_rev_text,
				LAST_UPDATED_BY = p_user,
				LAST_UPDATED_DATE = Ecdp_Timestamp.getCurrentSysdate
			where RESULT_NO IN (SELECT result_no FROM pwel_result WHERE object_id = p_object_id)
				AND DAYTIME >= p_daytime;

END updateProdTestResultDaytime;

END EcDp_Collection_Point;