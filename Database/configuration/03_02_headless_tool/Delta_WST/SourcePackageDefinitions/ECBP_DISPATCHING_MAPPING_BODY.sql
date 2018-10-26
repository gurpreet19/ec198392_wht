CREATE OR REPLACE PACKAGE BODY EcBp_Dispatching_Mapping
IS
/****************************************************************
** Package        :  EcBp_Dispatching_Mapping
**
** $Revision: 1.9 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created  : 03.01.2006  by Svein Helge Kallevik
**
** Modification history:
**
** Date       Whom  	 Change description:
** --------   ----- 	--------------------------------------
** 03.01.06   shk         Initial version
** 10.07.06   eizwanik    #3590: Edited getCellValue for NULL and negative value handling
** 06.11.06   siah    	  #4702: Added getConvertedValue, getCellValueInViewUnit, setCellValueInViewUnit
** 28.08.07   ismaiime 	  ECPD-6087 Edited getCellValue, cursor streams to condition on daytime and end_date
** 29.08.07   ismaiime	  ECPD-6087 Added setRowMappingEndDate, setColMappingEndDate, validateDelete
** 05.01.09	  ismaiime	  ECPD-9970 Added checks on daytime/end date in functions getColumnValueByName and validateDelete
******************************************************************/


--<EC-DOC>
--------------------------------------------------------------------------------------------------
-- Function       : getCellValue                                                                --
-- Description    : no conversion unit done in this module (in db unit)												--
--                                                                                              --
-- Preconditions  : 																			                                      --
-- Postcondition  :                                                                             --
-- Using Tables   : dispatching_col_mapping					  										                      --
--                                                                                              --
-- Using functions: 																			                                      --
--                  																			                                      --
--                                                                                              --
-- Configuration                                                                                --
-- required       :                                                                             --
--                                                                                              --
-- Behaviour      :                                                                             --
--                                                                                              --
--------------------------------------------------------------------------------------------------
  FUNCTION getCellValue(p_class_name varchar2, p_object_id varchar2, p_attribute_name varchar2, p_daytime date)
  RETURN NUMBER
  --</EC-DOC>
  IS

    ln_tot NUMBER;
    ln_res number;
    ls_sql varchar2(2000);

  	CURSOR streams (p_class_name varchar2, p_object_id varchar2, p_attribute_name varchar2, p_daytime date) is
         SELECT
              table_name, column_name, stream_id, where_clause
         FROM
              dispatching_col_mapping
         WHERE
              bf_class_name = p_class_name and
              object_id = p_object_id and
              attribute_name = p_attribute_name and
              daytime <= p_daytime and
              (end_date > p_daytime or end_date is null);
  BEGIN
    FOR lc_str in streams(p_class_name, p_object_id, p_attribute_name, p_daytime) LOOP
        ls_sql := 'select ' || lc_str.column_name || ' from ' || lc_str.table_name || ' where object_id = :object_id and daytime = :daytime ' || lc_str.where_clause;

        BEGIN
        	execute immediate ls_sql into ln_res using lc_str.stream_id, p_daytime ;
		EXCEPTION
        	WHEN OTHERS THEN
			ln_res := null;
		END;
        --This is to avoid returning 0 when actually the return value should be NULL
        if (ln_res is not null)and(ln_tot is null) then
           ln_tot :=0;
        end if;

        ln_tot := ln_tot + nvl(ln_res,0);
    END LOOP;
    RETURN ln_tot;
  END;

  --</EC-DOC>
--------------------------------------------------------------------------------------------------
-- Procedure      : setCellValue                                                                --
-- Description    :													                                                    --
--                                                                                              --
-- Preconditions  : 																			                                      --
-- Postcondition  :                                                                             --
-- Using Tables   : dispatching_col_mapping					  										--
--                                                                                              --
-- Using functions: 																			--
--                  																			--
--                                                                                              --
-- Configuration                                                                                --
-- required       :                                                                             --
--                                                                                              --
-- Behaviour      :                                                                             --
--                                                                                              --
--------------------------------------------------------------------------------------------------

  PROCEDURE setCellValue(p_class_name varchar2, p_object_id varchar2, p_attribute_name varchar2, p_daytime date, p_value number)
  --</EC-DOC>
  IS
    ls_sql varchar2(2000);
  	 CURSOR streams (p_class_name varchar2, p_object_id varchar2, p_attribute_name varchar2, p_daytime date) IS
         SELECT
              table_name, column_name, stream_id
         FROM
              dispatching_col_mapping
         WHERE
              bf_class_name = p_class_name and
              object_id = p_object_id and
              attribute_name = p_attribute_name and
              daytime <= p_daytime and
              (end_date > p_daytime or end_date is null);
  BEGIN
    FOR lc_str in streams(p_class_name, p_object_id, p_attribute_name, p_daytime) LOOP
        ls_sql := 'update ' || lc_str.table_name || ' set ' || lc_str.column_name || ' = :value where object_id = :object_id and daytime = :daytime';
        execute immediate ls_sql using p_value, lc_str.stream_id, p_daytime;
    END LOOP;
  END;

--<EC-DOC>
--------------------------------------------------------------------------------------------------
-- Function       : getColumnValueByName                                                              --
-- Description    :													--
--                                                                                              --
-- Preconditions  : 																			--
-- Postcondition  :                                                                             --
-- Using Tables   : dispatching_col_mapping					  										--
--                                                                                              --
-- Using functions: 																			--
--                  																			--
--                                                                                              --
-- Configuration                                                                                --
-- required       :                                                                             --
--                                                                                              --
-- Behaviour      :                                                                             --
--                                                                                              --
--------------------------------------------------------------------------------------------------
  FUNCTION getColumnValueByName(p_stream_id VARCHAR2, p_field_id VARCHAR2, p_grouping_type VARCHAR2, p_bf_class_name VARCHAR2, p_col_name VARCHAR2, p_daytime DATE)
  RETURN VARCHAR2
  --</EC-DOC>
  IS
  lv_col_val VARCHAR2(100);
  ls_sql VARCHAR2(2000);
  BEGIN
       ls_sql := 'select ' || p_col_name || ' FROM dispatching_col_mapping '||
       			 'WHERE grouping_type = :grouping_type '||
       			 'AND bf_class_name = :bf_class_name '||
        		 'AND object_id = :object_id '||
        		 'AND stream_id = :stream_id '||
        		 'AND daytime <= :daytime AND (end_date > :daytime OR end_date is null)' ;
       execute immediate ls_sql into lv_col_val using p_grouping_type, p_bf_class_name, p_field_id, p_stream_id, p_daytime, p_daytime;
       RETURN lv_col_val;
  END;



--<EC-DOC>
--------------------------------------------------------------------------------------------------
-- Function       : getCellValueInViewUnit                                                      --
-- Description    :													                                                    --
--                                                                                              --
-- Preconditions  : 																			                                      --
-- Postcondition  :                                                                             --
-- Using Tables   : dispatching_col_mapping					  										                      --
--                                                                                              --
-- Using functions: 																			                                      --
--                  																			                                      --
--                                                                                              --
-- Configuration                                                                                --
-- required       :                                                                             --
--                                                                                              --
-- Behaviour      :                                                                             --
--                                                                                              --
--------------------------------------------------------------------------------------------------
  FUNCTION getCellValueInViewUnit(p_class_name varchar2, p_object_id varchar2, p_attribute_name varchar2, p_daytime date)
  RETURN NUMBER
  --</EC-DOC>
  IS

    ln_tot NUMBER;
    ln_return NUMBER;
  BEGIN
    ln_tot := getCellValue(p_class_name,p_object_id,p_attribute_name, p_daytime);
    ln_return := getConvertedValue(p_object_id,p_class_name,ln_tot);
    RETURN ln_return;

  END;

  --</EC-DOC>
--------------------------------------------------------------------------------------------------
-- Procedure      : setCellValueInViewUnit                                                      --
-- Description    :													                                                    --
--                                                                                              --
-- Preconditions  : 																			                                      --
-- Postcondition  :                                                                             --
-- Using Tables   : dispatching_col_mapping					  										                      --
--                                                                                              --
-- Using functions: 																			                                      --
--                  																			                                      --
--                                                                                              --
-- Configuration                                                                                --
-- required       :                                                                             --
--                                                                                              --
-- Behaviour      :                                                                             --
--                                                                                              --
--------------------------------------------------------------------------------------------------

  PROCEDURE setCellValueInViewUnit(p_class_name varchar2, p_object_id varchar2, p_attribute_name varchar2, p_daytime date, p_value number)
  --</EC-DOC>
  IS
    ls_sql varchar2(2000);
    ln_converted NUMBER;

  BEGIN
    ln_converted := getConvertedValue(p_object_id,p_class_name,p_value);
    setCellValue(p_class_name,p_object_id,p_attribute_name,p_daytime, ln_converted);

  END;

--<EC-DOC>
--------------------------------------------------------------------------------------------------
-- Function       : getConvertedValue                                                              --
-- Description    :													--
--                                                                                              --
-- Preconditions  : 																			--
-- Postcondition  :                                                                             --
-- Using Tables   : dispatching_row_mapping					  										--
--                                                                                              --
-- Using functions: 																			--
--                  																			--
--                                                                                              --
-- Configuration                                                                                --
-- required       :                                                                             --
--                                                                                              --
-- Behaviour      :                                                                             --
--                                                                                              --
--------------------------------------------------------------------------------------------------
  FUNCTION getConvertedValue(p_object_id VARCHAR2, p_bf_class_name VARCHAR2, p_val_number NUMBER, p_convert_type VARCHAR2 DEFAULT 'V')
  RETURN NUMBER
  --</EC-DOC>
  IS
  lv_uom_val VARCHAR2(32);
  lv_dbuom_val VARCHAR2(32);
  ln_return_val NUMBER;

  	 CURSOR c_uom (cp_class_name varchar2, cp_object_id varchar2) IS
         SELECT
              uom, db_uom
         FROM
              DISPATCHING_ROW_MAPPING
         WHERE
              bf_class_name = cp_class_name and
              object_id = cp_object_id;

  BEGIN
	  FOR cur_uom IN c_uom(p_bf_class_name, p_object_id) LOOP
        lv_uom_val := cur_uom.uom;
        lv_dbuom_val := cur_uom.db_uom;
        if p_convert_type = 'V' then -- convert to view uom
           ln_return_val := ecdp_unit.convertValue(p_val_number,lv_dbuom_val,lv_uom_val);
        else -- convert to db uom
           ln_return_val := ecdp_unit.convertValue(p_val_number,lv_uom_val,lv_dbuom_val);
        end if;
	  END LOOP;

    RETURN ln_return_val;

END;

--<EC-DOC>
--------------------------------------------------------------------------------------------------
-- Function       : setRowMappingEndDate                                                              --
-- Description    :													--
--                                                                                              --
-- Preconditions  : 																			--
-- Postcondition  :                                                                             --
-- Using Tables   : dispatching_row_mapping					  										--
--                                                                                              --
-- Using functions: 																			--
--                  																			--
--                                                                                              --
-- Configuration                                                                                --
-- required       :                                                                             --
--                                                                                              --
-- Behaviour      :
--                                                                                              --
--------------------------------------------------------------------------------------------------
  PROCEDURE setRowMappingEndDate(p_object_id VARCHAR2, p_bf_class_name VARCHAR2, p_daytime DATE)
  --</EC-DOC>
  IS

  cursor c_row is
  SELECT daytime, end_date
    FROM dispatching_row_mapping
    WHERE bf_class_name = p_bf_class_name
    AND object_id = p_object_id;

  BEGIN

  for myCur in c_row loop
      if (myCur.daytime < p_daytime) and (myCur.end_date is null) then
         UPDATE dispatching_row_mapping
         SET end_date = p_daytime
          WHERE bf_class_name = p_bf_class_name
          AND object_id = p_object_id
          AND daytime < p_daytime
          AND end_date is null;
      else if myCur.daytime > p_daytime then

            UPDATE dispatching_row_mapping
            SET end_date = myCur.daytime
             WHERE bf_class_name = p_bf_class_name
             AND object_id = p_object_id
             AND daytime = p_daytime;
            end if;
      end if;
  end loop;
END;

--<EC-DOC>
--------------------------------------------------------------------------------------------------
-- Function       : setColMappingEndDate                                                              --
-- Description    :													--
--                                                                                              --
-- Preconditions  : 																			--
-- Postcondition  :                                                                             --
-- Using Tables   : dispatching_col_mapping					  										--
--                                                                                              --
-- Using functions: 																			--
--                  																			--
--                                                                                              --
-- Configuration                                                                                --
-- required       :                                                                             --
--                                                                                              --
-- Behaviour      :
--                                                                                              --
--------------------------------------------------------------------------------------------------
  PROCEDURE setColMappingEndDate(p_object_id VARCHAR2, p_bf_class_name VARCHAR2, p_daytime DATE, p_attribute_name VARCHAR2, p_stream_id VARCHAR2, p_table_name VARCHAR2)
  --</EC-DOC>
  IS

  cursor c_col is
  SELECT daytime, end_date
    FROM dispatching_col_mapping
    WHERE bf_class_name = p_bf_class_name
    AND object_id = p_object_id
    AND attribute_name = p_attribute_name
    AND stream_id = p_stream_id
    AND table_name = p_table_name;

  BEGIN

  for myCur in c_col loop
      if (myCur.daytime < p_daytime) and (myCur.end_date is null) then
         UPDATE dispatching_col_mapping
         SET end_date = p_daytime
          WHERE bf_class_name = p_bf_class_name
          AND object_id = p_object_id
          AND attribute_name = p_attribute_name
    	  AND stream_id = p_stream_id
    	  AND table_name = p_table_name
          AND daytime < p_daytime
          AND end_date is null;
      else if myCur.daytime > p_daytime then

           UPDATE dispatching_col_mapping
           SET end_date = myCur.daytime
            WHERE bf_class_name = p_bf_class_name
            AND object_id = p_object_id
            AND attribute_name = p_attribute_name
    	    AND stream_id = p_stream_id
    	    AND table_name = p_table_name
            AND daytime = p_daytime;
           end if;
      end if;
  end loop;
END;

--</EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validateDelete
-- Description    : Return an error message if the object set to be deleted, have child records.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : dispatching_row_mapping, dispatching_col_mapping
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Return an error message if the object set to be deleted, have child records.
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateDelete(p_object_id VARCHAR2, p_bf_class_name VARCHAR2, p_daytime DATE, p_end_date DATE)
--</EC-DOC>
IS
	ln_cnt NUMBER := 0;

BEGIN
	SELECT count(*) INTO ln_cnt
	FROM dispatching_col_mapping
  	WHERE object_id = p_object_id
   	AND bf_class_name = p_bf_class_name
   	AND daytime >= p_daytime
   	AND daytime < p_end_date;

	--if child exist, row cannot be deleted. raise error
	IF ln_cnt > 0 THEN
		RAISE_APPLICATION_ERROR(-20533,'Child record found. In order to delete this row all child records must be deleted first.');
	END IF;

END validateDelete;


END EcBp_Dispatching_Mapping;