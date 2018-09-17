CREATE OR REPLACE PACKAGE BODY EcBp_Cargo_Activity IS
/******************************************************************************
** Package        :  EcBp_Cargo_Activity, body part
**
** $Revision: 1.6 $
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
** 02.09.2013	muhammah		ECPD-6031: Added lifting_event to PROCEDURE activityBOLmapping
** 02.06.2017 sharawan    ECPD-41532: Added getActivityElapsedTime for calculating elapsed time minus the delays happen in between
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
	p_run_no		NUMBER,
	p_lifting_event VARCHAR2
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
        ld_start_date := ec_lifting_activity.from_daytime(p_cargo_no, p_activity_code, p_run_no, p_lifting_event);
        ld_end_date := ec_lifting_activity.to_daytime(p_cargo_no, p_activity_code, p_run_no, p_lifting_event);
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

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getActivityElapsedTime
--
-- Description    : Returns the elapsed time minus the delays that happen in duration of cargo activity.
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : cargo_lifting_delay
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Whenever there is delay recorded in Terminal Operation Delays, the delay time will be deducted from the
--                  actual duration for the cargo activity.
--
---------------------------------------------------------------------------------------------------
FUNCTION getActivityElapsedTime(
	p_cargo_no NUMBER,
	p_activity_start DATE,
  p_activity_end DATE
) RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR c_delays(cp_cargo_no NUMBER, cp_activity_start DATE, cp_activity_end DATE) IS
 WITH main_query AS
    (--get all delay data that happens during the activity time range
    SELECT from_daytime, to_daytime
      FROM cargo_lifting_delay t
     WHERE t.cargo_no = cp_cargo_no
       AND cp_activity_start <= t.to_daytime
       AND cp_activity_end >= t.from_daytime
    ),
 data_range AS
    (--Process overlap data - get delay data and group the data that overlaps within the same overlap range (taking the mininum from_daytime in overlaps data),
     --last row of data will be gone (it can be single or overlap data)
    SELECT from_daytime, to_daytime
      FROM main_query t
     WHERE NOT EXISTS (SELECT 1
              FROM main_query t2
             WHERE t2.from_daytime < t.from_daytime
               AND t2.to_daytime >= t.from_daytime)
     ),
 add_last_row AS
     (--Add back last row of data (it can be single or overlap data) that has been ruled out when processing overlap in data_range
      SELECT from_daytime, to_daytime
        FROM data_range
      UNION ALL
      SELECT from_daytime, to_daytime
        FROM main_query t
       WHERE from_daytime > (SELECT MAX(to_daytime) FROM data_range)
      ),
 extend_data_range AS
     (--Process overlap data - Extend delay data to get the maximum to_daytime from overlap data that has been ruled out from data_range
     SELECT from_daytime, to_daytime
        FROM add_last_row
      UNION ALL
      SELECT pi.from_daytime, t.to_daytime
        FROM add_last_row pi
       INNER JOIN main_query t
          ON pi.to_daytime >= t.from_daytime
         AND pi.to_daytime < t.to_daytime
      ),
 delay_data AS
     (--Process overlap data - using the minimum from_daytime to group the overlaps data and get the maximum to_daytime
     SELECT from_daytime, MAX(to_daytime) AS to_daytime
       FROM extend_data_range
      GROUP BY from_daytime
     )
 SELECT * FROM delay_data i;

 ld_start_delay   	DATE;
 ld_end_delay   	  DATE;
 ln_delay_hours    	NUMBER := 0;
 ln_all_delays    	NUMBER := 0;
 ln_activity_hours 	NUMBER := 0;
 lv_interval        INTERVAL DAY(5) TO SECOND;
 lv_hours           NUMBER;
 lv_hour_str        VARCHAR2(6);
 lv_duration     	  VARCHAR2(100) DEFAULT NULL;

BEGIN

  IF(p_activity_start IS NULL OR p_activity_end IS NULL) THEN
    RETURN NULL;

  ELSE
    --Get the duration of cargo activity
    ln_activity_hours := p_activity_end - p_activity_start;

    --Loop through the cargo_lifting_delay for any delay recorded for the particular cargo in the activity duration range
    FOR cur_delays IN c_delays(p_cargo_no, p_activity_start, p_activity_end) LOOP
        IF p_activity_start > cur_delays.from_daytime THEN ld_start_delay := p_activity_start;
        ELSE ld_start_delay := cur_delays.from_daytime;
        END IF;

        IF p_activity_end < cur_delays.to_daytime THEN ld_end_delay := p_activity_end;
        ELSE ld_end_delay := cur_delays.to_daytime;
        END IF;

        ln_delay_hours := (ld_end_delay - ld_start_delay);
        ln_all_delays := ln_all_delays + nvl(ln_delay_hours, 0);
    END LOOP;

    IF ln_all_delays > 0 THEN
      --Get the duration
      lv_interval := NUMTODSINTERVAL(ln_activity_hours - ln_all_delays, 'DAY');
      lv_hours := ( EXTRACT(DAY FROM lv_interval) * 24) + EXTRACT(HOUR FROM lv_interval);

      IF ( ABS(lv_hours) < 10 ) THEN
          lv_hour_str := TO_CHAR( lv_hours, '00' );
      ELSE
          lv_hour_str := '' || lv_hours;
      END IF;

      --Transform into presentation
      lv_duration := lv_hour_str || ':' || TO_CHAR(EXTRACT(MINUTE FROM lv_interval), 'FM00') || ':' || TO_CHAR(EXTRACT(SECOND FROM lv_interval), 'FM00');

    ELSE
      --Get the original datediff when there are no delay recorded
      lv_duration := ecbp_cargo_transport.getDateDiff(p_activity_start, p_activity_end);
    END IF;

  END IF;

  return lv_duration;

END getActivityElapsedTime;

END EcBp_Cargo_Activity;