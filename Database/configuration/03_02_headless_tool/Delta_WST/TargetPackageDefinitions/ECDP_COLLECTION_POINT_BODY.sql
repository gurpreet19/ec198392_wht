CREATE OR REPLACE PACKAGE BODY EcDp_Collection_Point IS

/****************************************************************
** Package        :  EcDp_Collection_Point, body part
**
** $Revision: 1.1.4.6 $
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
**    1.0   31.12.2012 kumarsur ECPD-22967 Collection Point Hierarchy Reorganization business function.
**    1.1   25.11.2013 choooshu ECPD-26170 Modified updateVersion and insertVersion to raise any errors from executing the statement
*****************************************************************/


lv_update_rev_text constant VARCHAR2(32000) := 'Updated by Collection Point Hierarchy Reorganization';
lv_insert_rev_text constant VARCHAR2(32000) := 'Created by Collection Point Hierarchy Reorganization';

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

	 lv_result := EcDp_Utilities.executeStatement(lv_sql);

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
	lv2_daytime := EcDp_Utilities.executeSingleRowString(lv_sql);

	IF to_date(lv2_daytime, 'YYYY-MM-DD"T"HH24:MI:SS') < to_date(to_char(p_daytime,'YYYY-MM-DD"T"HH24:MI:SS'), 'YYYY-MM-DD"T"HH24:MI:SS') THEN
		lv_sql := 'update ov_'|| p_object_type ||'
				set DAYTIME = to_date('''||to_char(p_daytime,'YYYY-MM-DD"T"HH24:MI:SS')||''', ''YYYY-MM-DD"T"HH24:MI:SS''),
					CP_COL_POINT_ID = '''||p_col_point_id||''',
					rev_text = '''||lv_insert_rev_text||''',
					LAST_UPDATED_BY = '''||p_user||'''
				where OBJECT_ID = '''||p_object_id||'''
				and daytime = to_date('''||lv2_daytime||''', ''YYYY-MM-DD"T"HH24:MI:SS'')';

		lv_result := EcDp_Utilities.executeStatement(lv_sql);

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
				LAST_UPDATED_BY = p_user
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
				LAST_UPDATED_BY = p_user
			where RESULT_NO IN (SELECT result_no FROM pwel_result WHERE object_id = p_object_id)
				AND DAYTIME >= p_daytime;

END updateProdTestResultDaytime;

END EcDp_Collection_Point;