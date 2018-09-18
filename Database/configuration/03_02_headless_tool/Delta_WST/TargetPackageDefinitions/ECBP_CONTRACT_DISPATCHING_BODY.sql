CREATE OR REPLACE PACKAGE BODY EcBp_Contract_Dispatching
IS
/****************************************************************
** Package        :  EcBp_Contract_Dispatching
**
** $Revision: 1.12 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created  : 12.01.06  by Kristin Eide
**
** Modification history:
**
** Date       Whom          Change description:
** --------   -----         --------------------------------------
** 12.01.06   eideekri      Initial version
** 13.01.06   Jean Ferre    Added a procedure ApportionSubDaily
** 27.02.06   kallesve      Added the aggregateSubDaily procedure
** 01.03.06   kallesve      Fixed the getCellValue function
** 01.03.06   eizwanik      Removed division by hours (line 137)
** 29.08.06	  siahohwi      Added estimated qty function
** 28.09.06   siahohwi      Added apportionNGLSubDaily procedure
** 21.03.07   kaurrnar      ECPD 5110: Added ue_contract_dispatching.apportionSubDaily function call
**27.01.09  masamken change this table STRM_SUB_DAY_FLD_SCHEME to STRM_SUB_DAY_SCHEME,and attribute feild_id to parent_object_id
******************************************************************/

--<EC-DOC>
--------------------------------------------------------------------------------------------------
-- Function       : getCellValue                                                              --
-- Description    :													--
--                                                                                              --
-- Preconditions  : 																			--
-- Postcondition  :                                                                             --
-- Using Tables   : 	STRM_SUB_DAY_SCHEME				  										--
--                                                                                              --
-- Using functions: 																			--
--                  																			--
--                                                                                              --
-- Configuration                                                                                --
-- required       :                                                                             --
--                                                                                              --
-- Behaviour      : 	Function return the value of the spesified column given by input parameter.
--							If no value for the given input parameters, the max value of column should
--							be returned. Column is either 'MEASURED_QTY' or 'ESTIMATED_QTY'
--                                                                                              --
--------------------------------------------------------------------------------------------------

FUNCTION getHourlyValue(p_column varchar2, p_object_id varchar2, p_parent_object_id varchar2, p_daytime date, p_summer_time varchar2)
RETURN NUMBER


IS
  ln_qty NUMBER;
  ld_production_day DATE;

  CURSOR c_qty_time (cp_object_id VARCHAR2, cp_parent_object_id varchar2, cp_daytime DATE,cp_summer_time VARCHAR2)
  IS
    SELECT measured_qty, estimated_qty
      FROM STRM_SUB_DAY_SCHEME
     WHERE object_id = cp_object_id
       AND parent_object_id = cp_parent_object_id
       AND summer_time = cp_summer_time
       AND daytime = cp_daytime;

  CURSOR c_avg_day (cp_object_id VARCHAR2, cp_parent_object_id varchar2, cp_daytime DATE,cp_summer_time VARCHAR2)
  IS
    SELECT AVG(measured_qty) avg_day
      FROM STRM_SUB_DAY_SCHEME
     WHERE object_id = cp_object_id
       AND parent_object_id = cp_parent_object_id
       AND production_day = cp_daytime;

  CURSOR c_latest_qty (cp_object_id VARCHAR2, cp_parent_object_id varchar2, cp_daytime DATE)
  IS
    SELECT estimated_qty
      FROM STRM_SUB_DAY_SCHEME
     WHERE object_id = cp_object_id
       AND parent_object_id = cp_parent_object_id
       AND daytime = (SELECT MAX(daytime)
       					FROM STRM_SUB_DAY_SCHEME
       				   WHERE object_id = cp_object_id
       				     AND parent_object_id = cp_parent_object_id
                   AND daytime < cp_daytime
       				     AND estimated_qty IS NOT NULL);
BEGIN

  IF p_column = 'ESTIMATED_QTY' THEN
	  FOR cur_qty IN c_qty_time(p_object_id, p_parent_object_id, p_daytime, p_summer_time) LOOP
	     IF cur_qty.measured_qty IS NOT NULL THEN
	         ln_qty := cur_qty.measured_qty;
	     ELSE
	     	 ld_production_day := ecdp_productionday.getProductionDay('STREAM',p_object_id,p_daytime, p_summer_time);
	     	 FOR cur_avg_day IN c_avg_day(p_object_id, p_parent_object_id, ld_production_day, p_summer_time) LOOP
		         IF cur_avg_day.avg_day IS NOT NULL THEN
		         	ln_qty := cur_avg_day.avg_day;
			    ELSIF cur_qty.estimated_qty IS NOT NULL THEN
			       ln_qty := cur_qty.estimated_qty;
		         ELSE
		         	FOR cur_latest IN c_latest_qty(p_object_id, p_parent_object_id, p_daytime) LOOP
		         		ln_qty := cur_latest.estimated_qty;
		         	END LOOP;
			    END IF;
			 END LOOP;
	     END IF;
	  END LOOP;
  END IF;

	RETURN ln_qty;

END getHourlyValue;


FUNCTION getCellValue(p_column varchar2, p_object_id varchar2, p_parent_object_id varchar2, p_daytime date, p_summer_time varchar2)
RETURN NUMBER
  --</EC-DOC>
  IS

  ln_qty NUMBER;

  CURSOR c_qty (cp_object_id VARCHAR2, cp_parent_object_id VARCHAR2, cp_daytime DATE,cp_summer_time VARCHAR2)
  IS
    SELECT measured_qty, estimated_qty
      FROM STRM_SUB_DAY_SCHEME
     WHERE object_id = cp_object_id
       AND parent_object_id = cp_parent_object_id
       AND summer_time = cp_summer_time
       AND daytime = cp_daytime;

  BEGIN

  IF p_column = 'MEASURED_QTY' THEN
	  FOR cur_qty IN c_qty(p_object_id, p_parent_object_id, p_daytime, p_summer_time) LOOP
         ln_qty := cur_qty.measured_qty;
	  END LOOP;

  ELSIF p_column = 'ESTIMATED_QTY' THEN
  	ln_qty := gethourlyvalue('ESTIMATED_QTY',p_object_id,p_parent_object_id,p_daytime, p_summer_time);
  END IF;

 	RETURN ln_qty;

  END getCellValue;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : apportionSubDaily
-- Description    : A procedure that splits the corrected value from the input parent_object into corrected
--						  column in the SubDaily section
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : STRM_SUB_DAY_SCHEME
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE apportionSubDaily(
  	p_object_id   			VARCHAR2,
  	p_parent_object_id				VARCHAR2,
	p_production_day		DATE,
	p_corrected_value		NUMBER,
	p_user 					VARCHAR2 	DEFAULT NULL,
  p_class_name    VARCHAR2  DEFAULT 'GAS_DAY_EXP_AND_FUEL'
)
--</EC-DOC>
IS

	lv_subDaily_CorrectedValue NUMBER;

	CURSOR c_corr_qty IS
		SELECT COUNT(daytime) n_hour
		FROM STRM_SUB_DAY_SCHEME
		WHERE  object_id = p_object_id
			AND parent_object_id = p_parent_object_id
			AND production_day = p_production_day;

BEGIN

	lv_subDaily_CorrectedValue := 0;

	FOR curCorrVal IN c_corr_qty LOOP
		IF (curCorrVal.n_hour <> 0) AND (curCorrVal.n_hour IS NOT NULL)
		THEN
      lv_subDaily_CorrectedValue := ecbp_dispatching_mapping.getConvertedValue(p_parent_object_id,p_class_name,p_corrected_value,'D');
			UPDATE STRM_SUB_DAY_SCHEME SET
				corrected_qty = lv_subDaily_CorrectedValue,
				LAST_UPDATED_BY=p_user
			WHERE object_id = p_object_id
				AND parent_object_id = p_parent_object_id
				AND production_day = p_production_day;

		END IF;
	END LOOP;

  --Need to lookup class_name parameter
  --aggregateSubDaily(...);??

  -- Calling user-exit procedure for possible additional functionality
     ue_Contract_Dispatching.apportionSubDaily(p_object_id, p_parent_object_id, p_production_day, p_corrected_value, p_user, p_class_name);

END apportionSubDaily;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : aggregateSubDaily
-- Description    : A procedure that aggregates the highest priority values from the SubDaily input parent_objects
--                  into the a Daily value and stores this on the dailylevel.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : STRM_SUB_DAY_SCHEME
--
-- Using functions: ecbp_dispatching_mapping.getCellValue
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE aggregateSubDaily(
    p_class_name VARCHAR2,
  	p_stream_mapping				VARCHAR2,
   	p_profitcentre_id   			VARCHAR2,
    p_stream_id VARCHAR2,
	  p_production_day		DATE,
   	p_user 					VARCHAR2 	DEFAULT NULL
)
--</EC-DOC>
IS
ln_ret_val number;

CURSOR c_avg_qty (cp_profitcentre_id varchar2,cp_stream_id varchar2,cp_daytime date) is
	SELECT avg(nvl(t.corrected_qty,nvl(ecbp_contract_dispatching.getCellValue('MEASURED_QTY', T.OBJECT_ID, T.parent_object_ID, T.DAYTIME,T.SUMMER_TIME),ecbp_contract_dispatching.getCellValue('ESTIMATED_QTY', T.OBJECT_ID, T.parent_object_ID, T.DAYTIME,T.SUMMER_TIME)))) corrected_avg
	FROM  STRM_SUB_DAY_SCHEME t
	WHERE  t.PRODUCTION_DAY = cp_daytime
	AND  t.parent_object_ID = cp_profitcentre_id
	AND  t.OBJECT_ID = cp_stream_id;

BEGIN
  for curr_rec in c_avg_qty (p_profitcentre_id,p_stream_id,p_production_day) loop
    ln_ret_val:=curr_rec.corrected_avg;
  end loop;

  if(ln_ret_val is not null) then
    ecbp_dispatching_mapping.setcellvalue(p_class_name,p_profitcentre_id,p_stream_mapping,p_production_day,ln_ret_val);
  end if;
END aggregateSubDaily;

--<EC-DOC>
--------------------------------------------------------------------------------------------------
-- Function       : getStreamIDForNGL                                                           --
-- Description    :													                                                    --
--                                                                                              --
-- Preconditions  : 																			                                      --
-- Postcondition  :                                                                             --
-- Using Tables   : 	dispatching_col_mapping				  										                      --
--                                                                                              --
-- Using functions: 																			                                      --
--                  																			                                      --
--                                                                                              --
-- Configuration                                                                                --
-- required       :                                                                             --
--                                                                                              --
-- Behaviour      : 	Function return the value of the stream id.                               --
--                                                                                              --
--------------------------------------------------------------------------------------------------

FUNCTION getStreamIDForNGL(p_object_id varchar2)
RETURN VARCHAR2
  --</EC-DOC>
  IS
  lv_ret_val varchar2(32);

  CURSOR c_stream_id (c_object_id varchar2) IS
    SELECT STREAM_ID
    FROM dispatching_col_mapping
    WHERE  object_id = c_object_id
    AND grouping_type = 'SUB_DAILY'
    AND bf_class_name='GAS_DAY_NGL_EXPORT';

  BEGIN
  for curr_rec in c_stream_id (p_object_id) loop
    lv_ret_val:=curr_rec.STREAM_ID;
  end loop;

 	RETURN lv_ret_val;

END getStreamIDForNGL;


---------------------------------------------------------------------------------------------------
-- Procedure      : apportionNGLSubDaily
-- Description    : This procedure will get stream id from table before calling apportionSubDaily()
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : dispatching_col_mapping
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE apportionNGLSubDaily(
  p_object_id   			VARCHAR2,
	p_production_day		DATE,
	p_corrected_value		NUMBER,
	p_user 					VARCHAR2 	DEFAULT NULL
)
--</EC-DOC>
IS
lv_ret_val varchar2(32);

BEGIN

  lv_ret_val:= getStreamIDForNGL(p_object_id);

  if (lv_ret_val is not null) then
     apportionSubDaily(lv_ret_val, p_object_id,p_production_day,p_corrected_value,p_user,'GAS_DAY_NGL_EXPORT');
  end if;

  aggregateSubDaily('GAS_DAY_NGL_EXPORT','PREDICTED_EXP',p_object_id,lv_ret_val,p_production_day,p_user);

END apportionNGLSubDaily;

END EcBp_Contract_Dispatching;