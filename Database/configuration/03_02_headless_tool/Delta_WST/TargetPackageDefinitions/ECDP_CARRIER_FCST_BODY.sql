CREATE OR REPLACE PACKAGE BODY EcDp_Carrier_Fcst IS
  /**************************************************************************************************
  ** Package  :  EcDp_Carrier_Fcst
  **
  ** $Revision: 1.3.2.2 $
  **
  ** Purpose  :  This package handles carrier availability
  **
  ** Created:     31.01.2013 hassakha
  **
  ** Modification history:
  **
  ** Date:         Whom:        Rev.  Change description:
  ** ----------    -----       ----   ------------------------------------------------------------------------
  **
  **************************************************************************************************/

  CURSOR c_opres_exist(cp_carrier_id VARCHAR2, cp_daytime DATE, cp_forecast_id VARCHAR2) IS
    select count(*) cnt
      from fcst_oploc_day_restrict o
     where o.object_id = cp_carrier_id
       and o.daytime = cp_daytime
	   and o.forecast_id = cp_forecast_id;

  CURSOR c_nom_date(cp_carrier_id VARCHAR2, cp_daytime DATE, cp_forecast_id VARCHAR2) IS
    select s.nom_firm_date,
           (s.nom_firm_date + c.round_trip_time) RTT,
           c.round_trip_time
      from stor_fcst_lift_nom s, carrier_port_acc c
     where s.carrier_id = c.object_id
       and c.object_id = cp_carrier_id
	   and s.port_id = c.port_id
	   and s.forecast_id = cp_forecast_id
	   and ec_stor_version.op_fcty_class_1_id(s.object_id, s.nom_firm_date, '<=') = c.fcty_class_1_id
       and s.nom_firm_date >= c.daytime
       and cp_daytime >= s.nom_firm_date
       and cp_daytime < (s.nom_firm_date + c.round_trip_time)
     group by s.nom_firm_date, c.round_trip_time
     order by s.nom_firm_date asc;

 --Check if port in nomination entry is null
 CURSOR c_port_is_null(cp_carrier_id VARCHAR2, cp_daytime DATE, cp_forecast_id VARCHAR2) IS
    select count(*) cnt
      from stor_fcst_lift_nom s, carrier_port_acc c
     where s.carrier_id = c.object_id
       and c.object_id = cp_carrier_id
	   and s.forecast_id = cp_forecast_id
       and s.port_id is null
       and c.fcty_class_1_id = ec_stor_version.op_fcty_class_1_id(s.object_id,s.nom_firm_date,'<=')
       and s.nom_firm_date >= c.daytime
       and s.nom_firm_date = cp_daytime;

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function       : isUnavailable
  -- Description    : returns 'Y' if a carrier is unavailable (on maintenance or en route)
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   :
  --
  -- Using functions:
  --
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  --
  ---------------------------------------------------------------------------------------------------
  FUNCTION isUnavailable(p_carrier_id VARCHAR2, p_daytime DATE, p_forecast_id VARCHAR2)
    RETURN VARCHAR2
  --</EC-DOC>
  IS

    lv_ind VARCHAR2(1) := 'N';

  BEGIN
    --If carrier is en route daytime between nom_date + RTT
    FOR cur_nom_date in c_nom_date(p_carrier_id, p_daytime, p_forecast_id) LOOP
      lv_ind := 'Y';
    END LOOP;
	--If carrier under maintenance will be log in daily/period operational restriction
    IF (lv_ind = 'N') THEN
      FOR cur_exists IN c_opres_exist(p_carrier_id, p_daytime, p_forecast_id) LOOP
        IF (cur_exists.cnt > 0) THEN
          lv_ind := 'Y';
        END IF;
      END LOOP;
    END IF;

    -- If carrier does not have a port configured yet
    IF (lv_ind = 'N') THEN
    FOR cur_port_is_null IN c_port_is_null(p_carrier_id, p_daytime, p_forecast_id) LOOP
        IF (cur_port_is_null.cnt > 0) THEN
          lv_ind := 'Y';
        END IF;
      END LOOP;
    END IF;

    RETURN lv_ind;

  END isUnavailable;

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function       : getUnavailableReason
  -- Description    : returns the unavailable reason when a carrier is not available
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   :
  --
  -- Using functions:
  --
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  --
  ---------------------------------------------------------------------------------------------------
  FUNCTION getUnavailableReason(p_carrier_id VARCHAR2, p_daytime DATE, p_forecast_id VARCHAR2)
    RETURN VARCHAR2
  --</EC-DOC>
   IS

   lv_reason VARCHAR2(240);
   lv_restriction_type VARCHAR(24);

  BEGIN

    -- if a carrier is on maintenance: return restriction type
    FOR cur_exists IN c_opres_exist(p_carrier_id, p_daytime, p_forecast_id) LOOP
      IF (cur_exists.cnt > 0) THEN
        lv_restriction_type := ec_fcst_oploc_day_restrict.restriction_type(p_carrier_id,
                                                                       p_forecast_id, p_daytime,
                                                                       '<=');
        lv_reason := ec_prosty_codes.code_text(lv_restriction_type,
                                               'CAP_RESTRICTION_TYPE');

      ELSE
        --if a carrier is en route: return the reason "en route"
        FOR cur_nom_date IN c_nom_date(p_carrier_id, p_daytime, p_forecast_id) LOOP
          lv_reason := 'En Route';
        END LOOP;

		--If a carrier does not have a port configured: return the reason "Destination Unknown"
        FOR  cur_port_is_null IN c_port_is_null(p_carrier_id,p_daytime,p_forecast_id)LOOP
          IF (cur_port_is_null.cnt>0)THEN
            lv_reason := 'Destination Unknown';
          END IF;
        END LOOP;
      END IF;
    END LOOP;

    RETURN lv_reason;

  END getUnavailableReason;

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function       : getNextAvailDate
  -- Description    : returns the next available date when a carrier is not available
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   :
  --
  -- Using functions:
  --
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  --
  ---------------------------------------------------------------------------------------------------
  FUNCTION getNextAvailDate(p_carrier_id VARCHAR2, p_daytime DATE, p_forecast_id VARCHAR2)
    RETURN DATE
  --</EC-DOC>
   IS

    CURSOR c_end_date(cp_carrier_id VARCHAR2, cp_daytime DATE, cp_forecast_id VARCHAR2) IS
    select min(s.daytime)next_avail_date
      from system_days s, fcst_oploc_day_restrict odr
     where not exists
     (select o.daytime
        from fcst_oploc_day_restrict o
       where s.daytime = o.daytime
         and odr.object_id = cp_carrier_id
		 and o.forecast_id = cp_forecast_id)
       and odr.object_id = cp_carrier_id
	   and odr.forecast_id = cp_forecast_id
       and odr.daytime >= cp_daytime
       and s.daytime > cp_daytime;

    ld_avail_date DATE;

  BEGIN

    --if a carrier is on maintenance:(exists in daily operational restriction), retrieve end date from period operational restriction
    FOR cur_exists IN c_opres_exist(p_carrier_id, p_daytime, p_forecast_id) LOOP
      IF (cur_exists.cnt > 0) THEN
        FOR cur_end_date IN c_end_date(p_carrier_id, p_daytime, p_forecast_id) LOOP
          ld_avail_date := cur_end_date.next_avail_date;
        END LOOP;
      ELSE
        --if a carrier is en route: end date is the nom_date + RTT
        FOR cur_nom_date IN c_nom_date(p_carrier_id, p_daytime, p_forecast_id) LOOP
          ld_avail_date := cur_nom_date.rtt;
        END LOOP;

        --If a carrier does not have a port configured: Next available date is null
        FOR cur_port_is_null IN c_port_is_null(p_carrier_id,p_daytime,p_forecast_id)LOOP
          IF(cur_port_is_null.cnt >0) THEN
            ld_avail_date := null;
          END IF;
        END LOOP;
      END IF;
    END LOOP;

    RETURN ld_avail_date;

  END getNextAvailDate;

END EcDp_Carrier_Fcst;