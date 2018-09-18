CREATE OR REPLACE PACKAGE BODY UE_PORT_RESOURCE IS
/******************************************************************************
** Package        :  UE_PORT_RESOURCE, body part
**
** $Revision      :  1.1 $
**
** Purpose        :  Includes user-exit functionality for Port Resource Usage screens
**
** Documentation  :  www.energy-components.com
**
** Created        :  06.6.2017 Swinjal Asare
**
** Modification history:
**
** Date        Whom       Change description:
** -------     ------     ----- ---------------------------------------------------------
** 06-06-2017  asareswi	  ECPD-41986 : Initial Version
** 19-06-2017  farhaann   ECPD-41986 : Added getPortResourceName
** 22-06-2017  sharawan   ECPD-41986 : Modified getPlannedStartTime and getPlannedDuration.
**                                     Cursor modified to return data and fixed the calculation based on the formula.
** 22-06-2017  sharawan   ECPD-41986 : Added getPlannedEndDate function to calculate End Date
** 22-06-2017  farhaann   ECPD-41986 : Added getAvailableResource, getLastUsageCargo, getLastUsageStartTime, getLastUsageEndTime,
**                                     getNextUsageCargo, getNextUsageStartTime and getNextUsageEndTime
** 10-07-2017  asareswi   ECPD-47288 : Added cargo_no parameter in getPlannedStartTime, getPlannedDuration procedure. Added function getLastTimesheetEntry.
** 18-07-2017  asareswi   ECPD-47474 : Added exception in getPlannedDuration procedure.
** 28-09-2017  baratmah   ECPD-48426 : Added procedure instantiatePortResTemplate.
** 12-10-2017  asareswi   ECPD-49156 : Added procedure updatePortResUsage to update port resource usage details when lifting start date, ETA, ETD is updated in cargo information screen.
*********************************************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getPlannedStartTime
-- Description    : Used to calculate planned start time based on Timeline Code in port resource usage screen.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : storage_lift_nomination
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getPlannedStartTime(p_timeline_code VARCHAR2, p_cargo_no NUMBER, p_parcel_no NUMBER, p_start_time DATE DEFAULT NULL)
  RETURN DATE

--</EC-DOC>
IS
  CURSOR c_nomination(cp_cargo_no NUMBER, cp_parcel_no number) IS
         SELECT n.start_lifting_date, ct.est_arrival
           FROM storage_lift_nomination n,
		        cargo_transport ct
          WHERE n.cargo_no = ct.cargo_no
            AND n.cargo_no = cp_cargo_no
            AND n.parcel_no = cp_parcel_no
		    AND n.start_lifting_date IS NOT NULL;

  ld_start_time DATE;

BEGIN

    FOR cur_nom in c_nomination(p_cargo_no, p_parcel_no) LOOP
     IF p_timeline_code = 'LOAD_START' THEN
       ld_start_time := cur_nom.start_lifting_date;

     ELSIF p_timeline_code = 'LOAD_END' THEN
       ld_start_time := cur_nom.start_lifting_date + getPlannedDuration('LOADING', p_cargo_no, p_parcel_no)/24 + getPlannedDuration('RAMP_DOWN', p_cargo_no, p_parcel_no)/24;

     ELSIF p_timeline_code = 'EARLIEST_ETA' THEN
       ld_start_time := cur_nom.est_arrival;

     ELSIF p_timeline_code = 'OFF_BERTH' THEN
       ld_start_time := getPlannedStartTime('LOAD_END', p_cargo_no, p_parcel_no) + getPlannedDuration('POST_LOAD', p_cargo_no, p_parcel_no)/24;

     ELSIF p_timeline_code = 'ETD' THEN
       ld_start_time := getPlannedStartTime('OFF_BERTH', p_cargo_no, p_parcel_no) + getPlannedDuration('OUTBOUND_PILOTAGE', p_cargo_no, p_parcel_no)/24;

     ELSIF p_timeline_code = 'ON_BERTH' THEN
       ld_start_time := cur_nom.start_lifting_date - getPlannedDuration('RAMP_UP', p_cargo_no, p_parcel_no)/24 - getPlannedDuration('PURGE_COOL', p_cargo_no, p_parcel_no)/24 - getPlannedDuration('PRE_LOADING', p_cargo_no, p_parcel_no)/24;

     ELSIF p_timeline_code = 'RAMP_UP' THEN
       ld_start_time := cur_nom.start_lifting_date - getPlannedDuration('RAMP_UP', p_cargo_no, p_parcel_no);

     ELSIF p_timeline_code = 'PC_START' THEN
       ld_start_time := cur_nom.start_lifting_date - getPlannedDuration('RAMP_UP', p_cargo_no, p_parcel_no)/24 - getPlannedDuration('PURGE_COOL', p_cargo_no, p_parcel_no)/24;

     ELSIF p_timeline_code = 'REQ_ARRIVAL_TIME' THEN
       ld_start_time := getPlannedStartTime('ON_BERTH', p_cargo_no, p_parcel_no) - getPlannedDuration('INBOUND_PILOTAGE', p_cargo_no, p_parcel_no)/24;

     ELSIF p_timeline_code = 'CUSTOM' THEN
       ld_start_time :=  p_start_time;
     END IF;
   END LOOP;

   RETURN ld_start_time;

END getPlannedStartTime;

  --<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getPlannedDuration
-- Description    : Used to calculate planned end time based on Duration Code in port resource usage screen.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : storage_lift_nomination, carrier_version
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getPlannedDuration(p_duration_code VARCHAR2, p_cargo_no NUMBER, p_parcel_no NUMBER, p_duration NUMBER DEFAULT NULL)
  RETURN NUMBER

--</EC-DOC>
IS

  CURSOR c_nom_carrier(cp_cargo_no NUMBER, cp_parcel_no NUMBER) IS
         SELECT n.start_lifting_date, n.grs_vol_nominated, n.cooldown_qty, n.purge_qty, n.eta_dest, ct.est_arrival,
		            c.cooldown_rate, to_char(c.purge_time,'HH') purge_time, c.loading_rate
		       FROM storage_lift_nomination n,
                    carrier_version c,
                    cargo_transport ct
		      WHERE n.cargo_no = ct.cargo_no
                AND n.cargo_no = cp_cargo_no
                AND n.parcel_no = cp_parcel_no
		        AND n.carrier_id = c.object_id(+)
		        AND n.start_lifting_date IS NOT NULL;

  ln_planned_duration  NUMBER;
  ln_purge NUMBER;
  ln_cooldown NUMBER;

BEGIN
   FOR cur_nom_carrier in c_nom_carrier(p_cargo_no, p_parcel_no) LOOP
     IF p_duration_code = 'LOADING' THEN
       ln_planned_duration := nvl(cur_nom_carrier.grs_vol_nominated, 0) / nvl(cur_nom_carrier.loading_rate, 0);

     ELSIF p_duration_code = 'PURGE_COOL' THEN
       ln_cooldown := nvl(cur_nom_carrier.cooldown_qty, 0) / nvl(cur_nom_carrier.cooldown_rate, 0);
       ln_purge := nvl(cur_nom_carrier.purge_qty, 0) / nvl(cur_nom_carrier.purge_time, 0);
       ln_planned_duration := ln_cooldown + ln_purge;

     ELSIF p_duration_code = 'ARM_USAGE_TIME' THEN
       ln_planned_duration := 24*(getPlannedStartTime('LOAD_END', p_cargo_no, p_parcel_no) - getPlannedStartTime('PC_START', p_cargo_no, p_parcel_no));

     ELSIF p_duration_code = 'BERTH_TIME' THEN
       ln_planned_duration := 24*(getPlannedStartTime('OFF_BERTH', p_cargo_no, p_parcel_no) - getPlannedStartTime('ON_BERTH', p_cargo_no, p_parcel_no));

     ELSIF p_duration_code = 'RAMP_UP' THEN
       ln_planned_duration := 1;

     ELSIF p_duration_code = 'RAMP_DOWN' THEN
       ln_planned_duration := 1;

     ELSIF p_duration_code = 'PRE_LOADING' THEN
       ln_planned_duration := 3;

     ELSIF p_duration_code = 'POST_LOAD' THEN
       ln_planned_duration := 2;

     ELSIF p_duration_code = 'INBOUND_PILOTAGE' THEN
       ln_planned_duration := 3;

     ELSIF p_duration_code = 'OUTBOUND_PILOTAGE' THEN
       ln_planned_duration := 5;

     ELSIF p_duration_code = 'CUSTOM' THEN
       ln_planned_duration := p_duration;
     END IF;
   END LOOP;

   RETURN round(ln_planned_duration);

   EXCEPTION
     WHEN ZERO_DIVIDE  THEN
       RETURN 0;
END getPlannedDuration;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getPlannedEndDate
-- Description    :
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getPlannedEndDate(p_cargo_no NUMBER, p_parcel_no NUMBER, p_timeline_code VARCHAR2, p_daytime DATE, p_duration_code VARCHAR2, p_duration NUMBER)
  RETURN DATE
--</EC-DOC>
IS
   ld_end_date 	         DATE;
   ld_start_time         DATE;
   ln_planned_duration   NUMBER;

BEGIN
  ld_start_time       := ue_port_resource.getPlannedStartTime(p_timeline_code, p_cargo_no, p_parcel_no, p_daytime);
  ln_planned_duration := ue_port_resource.getPlannedDuration(p_duration_code, p_cargo_no, p_parcel_no, p_duration);

  ld_end_date := ld_start_time + (ln_planned_duration/24);

  RETURN ld_end_date;

END getPlannedEndDate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getPortResourceName
-- Description    : Return Port Resource Name
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions: Ecdp_Timestamp.getCurrentSysdate
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getPortResourceName(p_class_name VARCHAR2, p_object_id VARCHAR2) RETURN VARCHAR2
--</EC-DOC>
IS
  lv_sql         VARCHAR2(2000);
  lv_name        VARCHAR2(240);

BEGIN

  lv_sql := 'select NAME
               from IV_PORT_RESOURCES
              where class_name = ''' || p_class_name || '''
                and object_id = ''' || p_object_id || '''
                and daytime <= Ecdp_Timestamp.getCurrentSysdate
                and Nvl(end_date, Ecdp_Timestamp.getCurrentSysdate + 1) >
                    Ecdp_Timestamp.getCurrentSysdate';

  EXECUTE IMMEDIATE lv_sql
    into lv_name;

  RETURN lv_name;

END getPortResourceName;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getAvailableResource
-- Description    : Return Port Resource Availability
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : port_resource_usage
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getAvailableResource(p_object_id VARCHAR2, p_cargo_no NUMBER, p_daytime DATE, p_end_date DATE)  RETURN VARCHAR2
--<EC-DOC>
IS
 ln_cnt            NUMBER;
 lv_available      VARCHAR2(1);
BEGIN

     SELECT count(*) INTO ln_cnt
      FROM port_resource_usage pru
     WHERE pru.object_id = p_object_id
       AND pru.cargo_no <> p_cargo_no
       AND (pru.end_date >= p_daytime OR pru.end_date IS NULL)
       AND (pru.daytime <= p_end_date OR p_end_date IS NULL);

     IF ln_cnt = 0 THEN
       lv_available := 'Y';
     ELSE
       lv_available := 'N';
     END IF;
     RETURN  lv_available;
END getAvailableResource;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLastUsageCargo
-- Description    : Return last usage cargo
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : port_resource_usage, cargo_transport
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getLastUsageCargo(p_object_id VARCHAR2, p_daytime DATE, p_cargo_no VARCHAR2) RETURN VARCHAR2
--<EC-DOC>
IS
CURSOR c_cargo(cp_object_id VARCHAR2, cp_daytime DATE, cp_cargo_no VARCHAR2)IS
  select ct.cargo_name
    from port_resource_usage pru, cargo_transport ct
   where pru.object_id = cp_object_id
     and pru.cargo_no = ct.cargo_no
     and pru.cargo_no <> cp_cargo_no
    and pru.daytime =
         (select max(pru.daytime) last_daytime
            from port_resource_usage pru
           where pru.object_id = cp_object_id
             and pru.cargo_no <> cp_cargo_no
             and pru.daytime between cp_daytime - 3 and cp_daytime
             and pru.daytime <= cp_daytime);

lv_cargo_name  VARCHAR2(200);
BEGIN
    FOR curCargo IN c_cargo(p_object_id, p_daytime,p_cargo_no) LOOP
		lv_cargo_name := curCargo.cargo_name;
	END LOOP;

	RETURN lv_cargo_name;
END getLastUsageCargo;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLastUsageStartTime
-- Description    : Return last usage start time
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : port_resource_usage
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getLastUsageStartTime(p_object_id VARCHAR2, p_daytime DATE, p_cargo_no VARCHAR2) RETURN DATE
--<EC-DOC>
IS
CURSOR c_date(cp_object_id VARCHAR2, cp_daytime DATE, cp_cargo_no VARCHAR2)IS
 select max(pru.daytime) last_daytime
   from port_resource_usage pru
  where pru.object_id = cp_object_id
    and pru.cargo_no <> cp_cargo_no
    and pru.daytime between cp_daytime - 3 and cp_daytime
    and pru.daytime <= cp_daytime;

ld_date	DATE;

BEGIN
    FOR dateCur IN c_date(p_object_id,p_daytime,p_cargo_no) LOOP
		ld_date :=dateCur.last_daytime;
	END LOOP;

	RETURN ld_date;
END getLastUsageStartTime;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLastUsageEndTime
-- Description    : Return last usage end time
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : port_resource_usage
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getLastUsageEndTime(p_object_id VARCHAR2, p_daytime DATE, p_cargo_no VARCHAR2) RETURN DATE
--<EC-DOC>
IS
CURSOR c_date(cp_object_id VARCHAR2,cp_daytime DATE, cp_cargo_no VARCHAR2)IS
 select min(end_date) last_end_date
   from port_resource_usage pru
  where pru.object_id = cp_object_id
    and pru.cargo_no <> cp_cargo_no
    and pru.daytime =
        (select max(pru.daytime)
           from port_resource_usage pru
          where pru.object_id = cp_object_id
            and pru.cargo_no <> cp_cargo_no
            and pru.daytime between cp_daytime - 3 and cp_daytime
            and pru.daytime <= cp_daytime);

ld_date	DATE;

BEGIN
    FOR dateCur IN c_date(p_object_id,p_daytime,p_cargo_no) LOOP
		ld_date := dateCur.last_end_date;
	END LOOP;

	RETURN ld_date;
END getLastUsageEndTime;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNextUsageCargo
-- Description    : Return next usage cargo
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : port_resource_usage, cargo_transport
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getNextUsageCargo(p_object_id VARCHAR2, p_daytime DATE, p_end_date DATE, p_cargo_no NUMBER) RETURN VARCHAR2
--<EC-DOC>
IS
CURSOR c_cargo(cp_object_id VARCHAR2, cp_daytime DATE, cp_end_date DATE, cp_cargo_no NUMBER)IS
 select ct.cargo_name
   from port_resource_usage pru, cargo_transport ct
  where pru.object_id = cp_object_id
    and pru.cargo_no = ct.cargo_no
    and pru.cargo_no <> cp_cargo_no
    and pru.daytime = (select min(pru.daytime) next_daytime
                        from port_resource_usage pru
                       where pru.object_id = cp_object_id
                         and pru.daytime between cp_daytime and cp_daytime + 3
                         and pru.cargo_no <> cp_cargo_no
                         and pru.end_date > cp_end_date);

lv_cargo_name  VARCHAR2(200);
BEGIN
    FOR curCargo IN c_cargo(p_object_id, p_daytime, p_end_date, p_cargo_no) LOOP
		lv_cargo_name := curCargo.cargo_name;
	END LOOP;

	RETURN lv_cargo_name;
END getNextUsageCargo;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNextUsageStartTime
-- Description    : Return next usage start time
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : port_resource_usage
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getNextUsageStartTime(p_object_id VARCHAR2, p_daytime DATE, p_end_date DATE, p_cargo_no NUMBER) RETURN DATE
--<EC-DOC>
IS
CURSOR c_date(cp_object_id VARCHAR2, cp_daytime DATE, cp_end_date DATE, cp_cargo_no NUMBER)IS
select min(pru.daytime) next_daytime
  from port_resource_usage pru
 where pru.object_id = cp_object_id
   and pru.daytime between cp_daytime and cp_daytime + 3
   and pru.cargo_no <> cp_cargo_no
   and pru.end_date > cp_end_date;

  ld_date	DATE;
BEGIN
   FOR dateCur IN c_date(p_object_id,p_daytime,p_end_date,p_cargo_no) LOOP
		ld_date := dateCur.next_daytime;
   END LOOP;

	RETURN ld_date;
END getNextUsageStartTime;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNextUsageEndTime
-- Description    : Return next usage end time
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : port_resource_usage
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getNextUsageEndTime(p_object_id VARCHAR2, p_daytime DATE, p_end_date DATE, p_cargo_no NUMBER) RETURN DATE
--<EC-DOC>
IS
CURSOR c_date(cp_object_id VARCHAR2, cp_daytime DATE, cp_end_date DATE, cp_cargo_no NUMBER)IS
 select end_date
   from port_resource_usage pru
  where pru.object_id = cp_object_id
    and pru.cargo_no <> cp_cargo_no
    and daytime =  (select min(pru.daytime) next_daytime
                     from port_resource_usage pru
                    where pru.object_id = cp_object_id
                      and pru.daytime between cp_daytime and cp_daytime + 3
                      and pru.cargo_no <> cp_cargo_no
                      and pru.end_date > cp_end_date);

  ld_date	DATE;
BEGIN
   FOR dateCur IN c_date(p_object_id, p_daytime, p_end_date, p_cargo_no) LOOP
		ld_date := dateCur.end_date;
   END LOOP;

	RETURN ld_date;
END getNextUsageEndTime;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLastTimesheetEntry
-- Description    : Return Last time sheet entry
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : port_resource_usage
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getLastTimesheetEntry(p_timeline_code VARCHAR2, p_cargo_no NUMBER, p_product_id VARCHAR2, p_lifting_event VARCHAR2, p_run_no NUMBER DEFAULT 1) RETURN DATE
--<EC-DOC>
IS
BEGIN
  RETURN NULL;
END getLastTimesheetEntry;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- PROCEDURE       : instantiatePortResTemplate
-- Description    : instantiate Port Resource Template
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : port_resource_usage, port_res_usage_template, storage_lift_nomination, stor_version
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE instantiatePortResTemplate(p_cargo_no NUMBER, p_user VARCHAR2)
--<EC-DOC>
IS

CURSOR c_port_usg_template(cp_cargo_no NUMBER)
IS
SELECT distinct n.cargo_no, n.parcel_no, t.product_id, t.port_resource_item_code, t.port_resource_type, t.timeline_code, t.duration_code, t.sort_order
FROM port_res_usage_template t, storage_lift_nomination n, stor_version s
WHERE n.object_id  = s.object_id
      AND t.product_id = s.product_id
      AND n.nom_firm_date >= s.daytime
      AND n.nom_firm_date <  nvl(s.end_date, n.nom_firm_date + 1)
      AND t.lifting_event = 'LOAD'
      AND n.cargo_no = cp_cargo_no
      AND port_resource_item_code not in (select u.port_resource_item_code
                                          from port_resource_usage u
                                          where u.cargo_no = n.cargo_no
                                             and u.product_id = s.product_id
                                             and u.parcel_no = n.parcel_no
                                             and u.cargo_no = cp_cargo_no)
        ORDER BY sort_order;

   ld_start_date            DATE;
   ln_planned_duration      NUMBER;
   ld_end_date              DATE;

BEGIN

  FOR curPortResTmplt IN c_port_usg_template(p_cargo_no) LOOP
    ld_start_date       := getPlannedStartTime(curPortResTmplt.timeline_code, p_cargo_no, curPortResTmplt.parcel_no, NULL);
    ln_planned_duration := getPlannedDuration(curPortResTmplt.duration_code, p_cargo_no, curPortResTmplt.parcel_no, NULL);
    ld_end_date         := getPlannedEndDate(p_cargo_no, curPortResTmplt.parcel_no, curPortResTmplt.timeline_code, ld_start_date, curPortResTmplt.duration_code, ln_planned_duration);

    INSERT INTO port_resource_usage (cargo_no, parcel_no, product_id, port_resource_item_code, port_resource_type, timeline_code, duration_code
    , daytime, duration, end_date, sort_order, created_by)
    VALUES (p_cargo_no, curPortResTmplt.parcel_no, curPortResTmplt.product_id, curPortResTmplt.port_resource_item_code
    , curPortResTmplt.port_resource_type, curPortResTmplt.timeline_code, curPortResTmplt.duration_code
    , ld_start_date, ln_planned_duration, ld_end_date, curPortResTmplt.sort_order, p_user);
  END LOOP;

END instantiatePortResTemplate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- PROCEDURE      : UpdatePortResUsage
-- Description    : Update planned start time, duration and end date in Port Resource Usage as soon as the start lifting date of cargo is updated in cargo information screen.
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : port_resource_usage, storage_lift_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

PROCEDURE updatePortResUsage(p_cargo_no NUMBER, p_parcel_no NUMBER DEFAULT NULL)
--<EC-DOC>
IS

CURSOR c_port_usage(cp_cargo_no NUMBER, cp_parcel_no NUMBER)
IS
  SELECT n.parcel_no, u.port_resource_item_code, u.timeline_code, u.duration_code, u.daytime, u.duration
  FROM port_resource_usage u, storage_lift_nomination n
  WHERE u.cargo_no = n.cargo_no
    AND u.parcel_no = n.parcel_no
    AND n.cargo_no = cp_cargo_no
    AND n.parcel_no = NVL(cp_parcel_no,n.parcel_no)
  ORDER BY sort_order;

   ld_start_date            DATE;
   ln_planned_duration      NUMBER;
   ld_end_date              DATE;

BEGIN
   FOR curUsage in c_port_usage(p_cargo_no, p_parcel_no) LOOP
      ld_start_date       := getPlannedStartTime(curUsage.timeline_code, p_cargo_no, curUsage.parcel_no, curUsage.daytime);
      ln_planned_duration := getPlannedDuration(curUsage.duration_code, p_cargo_no, curUsage.parcel_no, curUsage.duration);
      ld_end_date         := getPlannedEndDate(p_cargo_no, curUsage.parcel_no, curUsage.timeline_code, ld_start_date, curUsage.duration_code, ln_planned_duration);

      UPDATE PORT_RESOURCE_USAGE
      SET daytime = ld_start_date,
          duration = ln_planned_duration,
          end_date = ld_end_date
      WHERE cargo_no = p_cargo_no
      AND parcel_no = curUsage.parcel_no
      AND port_resource_item_code = curUsage.port_resource_item_code ;
   END LOOP;

END updatePortResUsage;

END UE_PORT_RESOURCE;