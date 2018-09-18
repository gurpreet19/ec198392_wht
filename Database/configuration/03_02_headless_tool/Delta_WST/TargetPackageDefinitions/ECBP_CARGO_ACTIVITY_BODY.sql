CREATE OR REPLACE PACKAGE BODY EcBp_Cargo_Activity IS
/******************************************************************************
** Package        :  EcBp_Cargo_Activity, body part
**
** $Revision: 1.3.58.5 $
**
** Purpose        :  Provide procedures that will be used as trigger action in the class LIFTING_ACTIVITY
**
** Documentation  :  www.energy-components.com
**
** Created  	  :  06.10.2006 / Kok Seong (Khew)
**
** Modification history:
**
** Date        	Whom  			Change description:
** ------      	----- 			-----------------------------------------------------------------------------------------------
** 24.01.2013   meisihil        ECPD-20056: Added functions getLiftingStartDate, getLiftingEndDate to support liftings spread over hours
**
********************************************************************************************************************************/

-- Global cursors
CURSOR c_lifting_activity_code(cp_activity_code VARCHAR2) IS
	SELECT 	*
    FROM 	lifting_activity_code
    WHERE 	activity_code = cp_activity_code;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : activityBOLmapping
--
-- Description    : Procedure that set the bl date/unload date if an activity got a date
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : storage_lift_nomination,
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : The BL_DATE in storage_lift_nomination should be set to the same as in activity
--
---------------------------------------------------------------------------------------------------
PROCEDURE activityBOLmapping(
	p_cargo_no		NUMBER,
	p_activity_code		VARCHAR2,
	p_run_no		NUMBER
)
--</EC-DOC>
IS

	CURSOR c_storage(p_cargo_no NUMBER)IS
	SELECT DISTINCT sln.object_id storage_id
	FROM storage_lift_nomination sln
	WHERE sln.cargo_no = p_cargo_no;

	lv_bol_ind   VARCHAR2(1);
	lv_timestamp VARCHAR2(1);
	--lv_boundary VARCHAR2(32);
    lv_lifting_event VARCHAR2(32);
	lv_prod_day_def VARCHAR2(32);
	ld_bl_date    DATE;
  	ld_start_date DATE;
	ld_end_date   DATE;
	ld_production_day	DATE;
BEGIN
    FOR curCode IN c_lifting_activity_code(p_activity_code) LOOP
		lv_bol_ind := curCode.BOL_IND;
        lv_timestamp := curCode.TIMESTAMP_IND;
        --lv_boundary := curCode.DATE_BOUNDARY_USAGE;
        lv_lifting_event := curCode.LIFTING_EVENT;
    END LOOP;

    IF lv_bol_ind = 'Y' THEN
        ld_start_date := ec_lifting_activity.from_daytime(p_cargo_no, p_activity_code, p_run_no);
        ld_end_date := ec_lifting_activity.to_daytime(p_cargo_no, p_activity_code, p_run_no);
      	IF lv_timestamp = 'Y' THEN
    		ld_bl_date := ld_start_date;
    	ELSE
    		IF ld_end_date IS NOT NULL THEN
    			ld_bl_date := ld_end_date;
    		ELSE
    			ld_bl_date := ld_start_date;
    		END IF;
      	END IF;

        --ecdp_dynsql.WriteTempText('lv_lifting_event=', lv_lifting_event);
        IF lv_lifting_event='LOAD' THEN
        	FOR StorageCur IN c_storage(p_cargo_no) LOOP
  	  		    ld_production_day := ecdp_productionday.getProductionDay('STORAGE',StorageCur.storage_id, ld_bl_date);
  	  		    ld_bl_date := TRUNC(ld_production_day);

  	  		    UPDATE storage_lift_nomination set BL_DATE=ld_bl_date where CARGO_NO=p_cargo_no and OBJECT_ID=StorageCur.storage_id;
  	  	  	END LOOP;
        ELSIF lv_lifting_event='UNLOAD' THEN
            FOR StorageCur IN c_storage(p_cargo_no) LOOP
      			ld_production_day := ecdp_productionday.getProductionDay('STORAGE',StorageCur.storage_id, ld_bl_date);
      			ld_bl_date := TRUNC(ld_production_day);

                --ecdp_dynsql.WriteTempText('ld_bl_date=', ld_bl_date);
                --ecdp_dynsql.WriteTempText('cargo_no=', p_cargo_no);
                --ecdp_dynsql.WriteTempText('OBJECT_ID=', StorageCur.storage_id);

      			UPDATE storage_lift_nomination set UNLOAD_DATE=ld_bl_date where CARGO_NO=p_cargo_no and OBJECT_ID=StorageCur.storage_id;
      		END LOOP;
        END IF;
	END IF;
END activityBOLmapping;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLiftingStartDate
--
-- Description    : Returns the activity start date marked as Lifting Start
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : storage_lift_nomination,
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the activity start date marked as Lifting Start
--
---------------------------------------------------------------------------------------------------
FUNCTION getLiftingStartDate(
	p_cargo_no		NUMBER,
	p_activity_type VARCHAR2 DEFAULT 'LOAD',
	p_lifting_event VARCHAR2 DEFAULT 'LOAD'
) RETURN DATE
--</EC-DOC>
IS

	CURSOR c_activity(cp_cargo_no NUMBER, cp_activity_type VARCHAR2, cp_lifting_event VARCHAR2)
	IS
		SELECT a.from_daytime start_date
		  FROM lifting_activity a, lifting_activity_code c
		 WHERE a.activity_code = c.activity_code
		   AND c.lifting_event = cp_lifting_event
		   AND c.lifting_start_ind = 'Y'
		   AND c.lifting_type = cp_activity_type
		   AND a.cargo_no = cp_cargo_no;

  	ld_start_date DATE;
BEGIN
    FOR c_cur IN c_activity(p_cargo_no, p_activity_type, p_lifting_event) LOOP
    	ld_start_date := c_cur.start_date;
    END LOOP;

    RETURN ld_start_date;
END getLiftingStartDate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLiftingEndDate
--
-- Description    : Returns the activity end (or start) date marked as Lifting End
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : storage_lift_nomination,
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the activity end (or start) date marked as Lifting End
--
---------------------------------------------------------------------------------------------------
FUNCTION getLiftingEndDate(
	p_cargo_no		NUMBER,
	p_activity_type VARCHAR2 DEFAULT 'LOAD',
	p_lifting_event VARCHAR2 DEFAULT 'LOAD'
) RETURN DATE
--</EC-DOC>
IS

	CURSOR c_activity(cp_cargo_no NUMBER, cp_activity_type VARCHAR2, cp_lifting_event VARCHAR2)
	IS
		SELECT a.from_daytime start_date, a.to_daytime end_date, c.timestamp_ind
		  FROM lifting_activity a, lifting_activity_code c
		 WHERE a.activity_code = c.activity_code
		   AND c.lifting_event = cp_lifting_event
		   AND c.lifting_end_ind = 'Y'
		   AND c.lifting_type = cp_activity_type
		   AND a.cargo_no = cp_cargo_no;

  	ld_end_date DATE;
BEGIN
    FOR c_cur IN c_activity(p_cargo_no, p_activity_type, p_lifting_event) LOOP
    	IF c_cur.timestamp_ind = 'Y' THEN
	    	ld_end_date := c_cur.start_date;
	    ELSE
	    	ld_end_date := nvl(c_cur.end_date, c_cur.start_date);
	    END IF;
    END LOOP;

    RETURN ld_end_date;
END getLiftingEndDate;

END EcBp_Cargo_Activity;