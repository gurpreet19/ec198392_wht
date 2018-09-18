CREATE OR REPLACE PACKAGE BODY EcDp_Stream_VentFlare IS
/****************************************************************
** Package        :  EcBp_Stream_VentFlare
**
** $Revision: 1.8.2.2 $
**
** Purpose        :  This package is responsible for supporting business functions
**                         related to Daily Gas Stream - Vent and Flare.
**
** Documentation  :  www.energy-components.com
**
** Created  :  17.03.2010  Sarojini Rajaretnam
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 17.03.2010 rajarsar	ECPD-4828:Initial version
** 31.05.2010 rajarsar	ECPD-14746: Added Procedure insertWell and updated createChildEvent
** 31.05.2010 rajarsar	ECPD-14621: Updated Procedure updateEndDateForChildEvent
** 31.05.2010 rajarsar	ECPD-14622: Updated Procedure updateSource
** 31.05.2010 farhaann	ECPD-14838: Updated Procedure addEqpmEvent and insertWell
** 02.02.2011 farhaann  ECPD-16411: Changed updateSource parameter to use p_grs_vol instead of p_net_vol
** 25.05.2011 rajarsar  ECPD-17408: Added a new procedure delEqpmWellChildEvent
** 26.08.2011 abdulmaw	ECPD-18390: Updated Procedure insertWell
** 22.11.2011 abdulmaw  ECPD-19097: Updated Procedure createChildEvent
** 01.03.2012 musaamah  ECPD-18642: Added column downstream_sales and downstream_fuel to createChildEvent procedure.
** 15.06.2012 syazwnur  ECPD-21282: Updated if statement in createChildEvent procedure to check on NULL end daytime.
** 15.01.2014 choooshu	ECPD-26654: Updated procedure createChildEvent and insertWell to use well uptime in the duration of event instead of total uptime in a production day.
*****************************************************************/
--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Procedure     : UpdatesSource                                                  --
-- Description    :
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                           --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
Procedure updateSource(p_object_id VARCHAR2, p_daytime DATE,  p_user VARCHAR2, p_grs_vol VARCHAR2)


--</EC-DOC>
IS


BEGIN
  IF p_grs_vol IS NOT NULL THEN
    UPDATE strm_day_stream std
      SET std.source = 'MANUAL',
      std.last_updated_by = p_user
      WHERE std.object_id = p_object_id
      AND std.daytime = p_daytime;
  END IF;
END updateSource;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Procedure      : updateEndDateForChildEvent                                               --
-- Description    : updates end_daytime for the same child events
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                           --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
Procedure updateEndDateForChildEvent(p_object_id VARCHAR2, p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE,p_end_daytime DATE, p_user VARCHAR2)


--</EC-DOC>
IS
CURSOR c_strm_day_asset_data IS
  SELECT * FROM STRM_DAY_ASSET_DATA
    WHERE object_id = p_object_id
    AND class_name = p_class_name
    AND asset_id = p_asset_id
    AND start_daytime = p_start_daytime;


BEGIN

  FOR cur_strm_day_asset_data IN  c_strm_day_asset_data  LOOP
    IF cur_strm_day_asset_data.daytime > EcDp_ProductionDay.getProductionDay(null, p_asset_id, p_end_daytime) THEN

      DELETE FROM strm_day_asset_data
        WHERE object_id = p_object_id
        AND class_name = p_class_name
        AND asset_id = p_asset_id
        AND start_daytime = p_start_daytime
        AND daytime = cur_strm_day_asset_data.daytime;


      DELETE FROM strm_day_asset_well_data
        WHERE object_id = p_object_id
        AND class_name = p_class_name
        AND asset_id = p_asset_id
        AND start_daytime = p_start_daytime
        AND daytime = cur_strm_day_asset_data.daytime;

    ELSE

       UPDATE strm_day_asset_data
         SET end_daytime = p_end_daytime,
         last_updated_by = p_user
         WHERE object_id = p_object_id
         AND  class_name = p_class_name
         AND  asset_id = p_asset_id
         AND  start_daytime = p_start_daytime
         AND  daytime = cur_strm_day_asset_data.daytime;

    END IF;
  END LOOP;
END updateEndDateForChildEvent;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Procedure      : addEqpmEvent                                               --
-- Description    : Adds equipment that are down for that day from Equipment Downtime BF
-- Preconditions  : No overlapping records exist
--                  The equipment is connected through connection_type= VF_NR to the selected stream OR
--                  the stream is connected to a parent where connection type = VF_REL and the parent
--                  has child where connection_type = VF_VRS
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :STRM_DAY_ASSET_DATA
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                           --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
PROCEDURE addEqpmEvent(p_object_id VARCHAR2, p_daytime DATE,  p_user VARCHAR2)

--</EC-DOC>
IS
   ld_start_day  DATE;
   ld_end_day    DATE;
   ln_prod_day_offset NUMBER;

CURSOR c_eqpm(cp_start_day DATE, cp_end_day DATE) IS
 SELECT wed.object_id, wed.object_type, wed.daytime, wed.end_date
     FROM well_equip_downtime wed
     WHERE wed.downtime_categ = 'EQPM_OFF'
     AND wed.daytime >= cp_start_day /* Navigator Date + Production Day Offset */
     AND wed.daytime < cp_end_day /* Navigator Date + 1 + Production Day Offset */
      AND wed.object_id IN (
              SELECT ogc.child_obj_id
                FROM object_group_conn ogc
               WHERE ogc.parent_group_type = 'VF_NR'
                 AND ogc.object_id = p_object_id  /* Selected Non-Routine Stream */
                 --AND ogc.start_date < cp_end_day /* Navigator Date + 1 + Production Day Offset */
                 --AND nvl(ogc.end_date,cp_end_day) > cp_start_day /* Navigator Date + Production Day Offset */
                 AND ogc.start_date <= p_daytime
                 AND NVL (ogc.end_date, p_daytime + 1) > p_daytime
       UNION
              SELECT ogc.child_obj_id
                FROM object_group_conn ogc
               WHERE ogc.parent_group_type = 'VF_VRS'
                 --AND ogc.start_date < cp_end_day /* Navigator Date + 1 + Production Day Offset */
                 --AND nvl(ogc.end_date,cp_end_day) > cp_start_day /* Navigator Date + Production Day Offset */
                 AND ogc.start_date <= p_daytime
                 AND NVL (ogc.end_date, p_daytime + 1) > p_daytime
                 AND ogc.object_id IN (
                        SELECT ogc.object_id
                          FROM object_group_conn ogc
                         WHERE ogc.parent_group_type = 'VF_REL'
                           --AND ogc.start_date < cp_end_day /* Navigator Date + 1 + Production Day Offset */
                           --AND nvl(ogc.end_date,cp_end_day) > cp_start_day /* Navigator Date + Production Day Offset */
                           AND ogc.start_date <= p_daytime
                           AND NVL (ogc.end_date, p_daytime + 1) > p_daytime
                           AND ogc.child_obj_id = p_object_id)) /* Selected Non-Routine Stream */
      AND NOT EXISTS
         (SELECT 1
            FROM strm_day_asset_data a
            WHERE a.object_id = p_object_id
            AND   a.asset_id = wed.object_id
            AND   a.daytime = p_daytime
            AND   a.class_name = 'STRM_DAY_NR_EQPM'
            AND   a.asset_type = wed.object_type
            AND   a.start_daytime = wed.daytime
          );

BEGIN

   ue_stream_ventflare.addEqpmEvent(p_object_id, p_daytime, p_user);
   ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('STREAM',p_object_id, p_daytime)/24;
   ld_start_day := TRUNC(p_daytime) + ln_prod_day_offset;
   ld_end_day   := ld_start_day + 1;

   FOR cur_eqpm IN c_eqpm(ld_start_day, ld_end_day) LOOP
     INSERT  INTO STRM_DAY_ASSET_DATA (object_id, class_name, daytime, asset_id,start_daytime, end_daytime, asset_type) VALUES(p_object_id,'STRM_DAY_NR_EQPM',p_daytime,cur_eqpm.object_id,cur_eqpm.daytime,cur_eqpm.end_date,cur_eqpm.object_type);
   END LOOP;


END addEqpmEvent;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Procedure      : createChildEvent                                              --
-- Description    : create child events
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                           --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
Procedure createChildEvent(p_object_id VARCHAR2, p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE,p_end_daytime DATE, p_user VARCHAR2)


--</EC-DOC>
IS

CURSOR c_enddaytime(cp_end_daytime DATE) IS
  SELECT daytime
    FROM system_days
    WHERE daytime BETWEEN p_daytime + 1
    AND cp_end_daytime;


CURSOR c_strm_day_asset_data(cp_daytime DATE) IS
  SELECT *
    FROM strm_day_asset_data t
    WHERE t.object_id = p_object_id
    AND t.class_name = p_class_name
    AND t.asset_id = p_asset_id
    AND t.daytime = p_daytime
    AND t.start_daytime = p_start_daytime
     AND NOT exists
       (select 1
                from strm_day_asset_data x
                where x.object_id = t.object_id
                and x.start_daytime = t.start_daytime
                and x.class_name = t.class_name
                and x.daytime = cp_daytime
                and x.asset_id = p_asset_id);


    ld_daytime DATE;
	ln_prod_day_offset NUMBER;
    ld_prod_daytime DATE;
    ld_prod_offset_daytime DATE;
	ln_strm_prod_day_offset NUMBER;
	ld_end_daytime DATE;
    ld_event_end_daytime DATE;

BEGIN

    ln_prod_day_offset := Ecdp_Productionday.getProductionDayOffset(null, p_asset_id, p_daytime)/24;

    IF ln_prod_day_offset > 0 THEN
      ld_prod_daytime := Ecdp_Productionday.getProductionDay(null, p_asset_id, p_daytime);
      ld_prod_offset_daytime := (ld_prod_daytime + ln_prod_day_offset) + 2;
    ELSIF ln_prod_day_offset = 0 THEN
      ld_prod_daytime := Ecdp_Productionday.getProductionDay(null, p_asset_id, p_daytime);
      ld_prod_offset_daytime := ld_prod_daytime + 1;
    END IF;

	ln_strm_prod_day_offset := Ecdp_Productionday.getProductionDayOffset('STREAM', p_object_id, p_daytime)/24;
    ld_event_end_daytime := nvl(p_end_daytime, EcDp_Date_Time.getCurrentSysdate + ln_strm_prod_day_offset);
    ld_end_daytime := TRUNC((ld_event_end_daytime - ln_strm_prod_day_offset), 'DD');

    FOR cur_enddaytime IN c_enddaytime(ld_end_daytime) LOOP
      ld_daytime := cur_enddaytime.daytime;
      IF p_end_daytime > ld_prod_offset_daytime OR p_end_daytime is NULL THEN
        FOR cur_strm_day_asset_data IN c_strm_day_asset_data(ld_daytime) LOOP
         INSERT INTO strm_day_asset_data
          (object_id, class_name, daytime, asset_id, start_daytime, end_daytime, asset_type, release_method, total_num_occur, rou_rel_override, non_rou_rel_override, daily_release, permit, rel_reason_code, comments, h2s, so2, downstream_sales, downstream_fuel)
           VALUES
          (cur_strm_day_asset_data.object_id, cur_strm_day_asset_data.class_name, ld_daytime, cur_strm_day_asset_data.asset_id,cur_strm_day_asset_data.start_daytime, p_end_daytime, cur_strm_day_asset_data.asset_type, cur_strm_day_asset_data.release_method, cur_strm_day_asset_data.total_num_occur, cur_strm_day_asset_data.rou_rel_override, cur_strm_day_asset_data.non_rou_rel_override, cur_strm_day_asset_data.daily_release, cur_strm_day_asset_data.permit, cur_strm_day_asset_data.rel_reason_code, cur_strm_day_asset_data.comments, cur_strm_day_asset_data.h2s, cur_strm_day_asset_data.so2, cur_strm_day_asset_data.downstream_sales, cur_strm_day_asset_data.downstream_fuel);
          IF p_class_name = 'STRM_DAY_NR_EQPM' THEN
            insertWell(p_object_id, p_class_name, ld_daytime,p_asset_id,p_start_daytime, p_end_daytime,p_user);
          END IF;
        END LOOP;

        ld_prod_offset_daytime := ld_prod_offset_daytime + 1;
      END IF;
    END LOOP;

END createChildEvent;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Procedure      : createEqpmWellChildEvent                                              --
-- Description    : create well child events for Eqpm
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                           --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
PROCEDURE createEqpmWellChildEvent(p_object_id VARCHAR2, p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_well_id VARCHAR2, p_start_daytime DATE, p_user VARCHAR2)


--</EC-DOC>
IS

CURSOR c_enddaytime (cp_end_daytime DATE) IS
  SELECT daytime
    FROM system_days
    WHERE daytime BETWEEN p_daytime + 1
    AND  TRUNC(nvl(cp_end_daytime,EcDp_Date_Time.getCurrentSysdate), 'DD');

CURSOR c_eqpm_end_daytime IS
  SELECT end_daytime
    FROM strm_day_asset_data t
    WHERE t.object_id = p_object_id
    AND t.class_name = p_class_name
    AND t.daytime = p_daytime
    AND t.asset_id = p_asset_id;

 CURSOR c_strm_day_asset_well_data(cp_daytime DATE) IS
  SELECT *
    FROM strm_day_asset_well_data t
    WHERE t.object_id = p_object_id
    AND t.class_name = p_class_name
    AND t.asset_id = p_asset_id
    AND t.well_id = p_well_id
    AND t.daytime = p_daytime
    AND t.start_daytime = p_start_daytime
    AND NOT exists
       (select 1
                from strm_day_asset_well_data x
                where x.object_id = t.object_id
                and x.start_daytime = t.start_daytime
                and x.class_name = t.class_name
                and x.asset_id = t.asset_id
                and x.well_id = p_well_id
                and x.daytime = cp_daytime );

    ld_daytime DATE;
    ld_end_daytime DATE;

BEGIN

    FOR cur_eqpm_end_daytime IN c_eqpm_end_daytime LOOP
      ld_end_daytime := cur_eqpm_end_daytime.end_daytime;
      FOR cur_enddaytime IN c_enddaytime(ld_end_daytime) LOOP
        ld_daytime := cur_enddaytime.daytime;
        FOR cur_strm_day_asset_well_data IN c_strm_day_asset_well_data(ld_daytime) LOOP
          INSERT INTO strm_day_asset_well_data
          (object_id, class_name, daytime, asset_id, well_id, start_daytime)
          VALUES
          (p_object_id, p_class_name, ld_daytime, p_asset_id,p_well_id, p_start_daytime);
        END LOOP;
      END LOOP;
    END LOOP;

END createEqpmWellChildEvent;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Procedure      : insertWell                                              --
-- Description    : create well child events for Eqpm when there's connection in Object Grp Connection
-- Preconditions  : Wells must be active producers and are not registered in deferment events.
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                           --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
PROCEDURE insertWell(p_object_id VARCHAR2, p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE,p_end_daytime DATE,p_user VARCHAR2)


--</EC-DOC>
IS

    ln_prod_day_offset NUMBER;
    ld_daytime DATE;
    ld_start_daytime DATE;
    ld_end_daytime DATE;

CURSOR c_obj_grp_conn IS
SELECT *
    FROM object_group_conn ogn
    WHERE ogn.object_id =  p_asset_id
    AND ogn.start_date <= p_daytime
    AND NVL (ogn.end_date, p_daytime + 1) > p_daytime
    AND ogn.object_class IN ('WELL','WELL_HOOKUP','FCTY_CLASS_1')
    AND ogn.parent_group_type = 'VF_WELL_CONTRIB'
    AND ogn.object_id IN (SELECT ogn2.child_obj_id
                       FROM object_group_conn ogn2
                       WHERE ogn2.object_id = p_object_id
                       AND ogn2.parent_group_type = 'VF_NR'
                       AND ogn2.start_date <= p_daytime
                       AND NVL (ogn2.end_date, p_daytime + 1) > p_daytime
                       );

CURSOR c_fcty_class_1_wells(cp_fcty_class_1_id VARCHAR2) IS
  SELECT *
    FROM well_version wv
    WHERE ecgp_group.findParentObjectId('operational','FCTY_CLASS_1','WELL',wv.object_id,p_daytime) = cp_fcty_class_1_id
    AND ecdp_well.isWellPhaseActiveStatus(wv.object_id,null,'OPEN',p_daytime) = 'Y'
	AND p_daytime >= wv.daytime
    AND p_daytime < nvl(wv.end_date, p_daytime+1)
    AND wv.object_id NOT IN (SELECT object_id FROM well_equip_downtime wed
      WHERE (wed.end_date > p_start_daytime OR wed.end_date is null)
      AND (wed.daytime < p_end_daytime OR p_end_daytime IS NULL));


CURSOR c_well_hookup_wells(cp_well_hookup_id VARCHAR2, cp_start_daytime DATE, cp_end_daytime DATE) IS
  SELECT *
    FROM well_version wv
    WHERE ecgp_group.findParentObjectId('operational','WELL_HOOKUP','WELL',wv.object_id,p_daytime) = cp_well_hookup_id
    AND ecdp_well.isWellPhaseActiveStatus(wv.object_id,null,'OPEN',p_daytime) = 'Y'
	AND p_daytime >= wv.daytime
    AND p_daytime < nvl(wv.end_date, p_daytime+1)
    AND wv.object_id NOT IN (SELECT object_id FROM well_equip_downtime wed
      WHERE NVL (wed.end_date, cp_end_daytime) >= cp_end_daytime
      AND wed.daytime <= cp_start_daytime);

CURSOR c_wells (cp_well_id VARCHAR2) IS
  SELECT wv.object_id
  FROM well_version wv
  WHERE wv.object_id = cp_well_id
  AND ecdp_well.isWellPhaseActiveStatus(wv.object_id,null,'OPEN',p_daytime) = 'Y'
  AND p_daytime >= wv.daytime
  AND p_daytime < nvl(wv.end_date, p_daytime+1)
  AND wv.object_id NOT IN (SELECT object_id FROM well_equip_downtime wed
    WHERE (wed.end_date > p_start_daytime OR wed.end_date is null)
    AND (wed.daytime < p_end_daytime OR p_end_daytime IS NULL));

BEGIN

    ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('EQUIPMENT', p_asset_id, p_daytime)/24;
    ld_daytime := p_daytime + ln_prod_day_offset;
    ld_start_daytime := greatest(p_start_daytime, ld_daytime);
    ld_end_daytime := least (NVL (p_end_daytime, ld_daytime + 1), ld_daytime + 1);

    FOR cur_obj_grp_conn IN c_obj_grp_conn LOOP
      IF cur_obj_grp_conn.object_class = 'WELL' THEN
        FOR cur_wells IN c_wells(cur_obj_grp_conn.child_obj_id) LOOP
          INSERT INTO strm_day_asset_well_data
            (object_id, class_name, daytime, asset_id, well_id, start_daytime)
          VALUES
            (p_object_id, p_class_name, p_daytime, p_asset_id,cur_obj_grp_conn.child_obj_id, p_start_daytime);
        END LOOP;
      ELSIF cur_obj_grp_conn.object_class = 'WELL_HOOKUP' THEN
        FOR cur_well_hookup_wells IN c_well_hookup_wells(cur_obj_grp_conn.child_obj_id, ld_start_daytime, ld_end_daytime) LOOP
          INSERT INTO strm_day_asset_well_data
          (object_id, class_name, daytime, asset_id, well_id, start_daytime)
          VALUES
          (p_object_id, p_class_name, p_daytime, p_asset_id,cur_well_hookup_wells.object_id, p_start_daytime);
        END LOOP;
      ELSIF cur_obj_grp_conn.object_class = 'FCTY_CLASS_1' THEN
        FOR cur_fcty_class_1_wells IN c_fcty_class_1_wells(cur_obj_grp_conn.child_obj_id) LOOP
          INSERT INTO strm_day_asset_well_data
          (object_id, class_name, daytime, asset_id, well_id, start_daytime)
          VALUES
          (p_object_id, p_class_name, p_daytime, p_asset_id,cur_fcty_class_1_wells.object_id, p_start_daytime);
        END LOOP;
      END IF;
    END LOOP;

END insertWell;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Procedure      : delEqpmWellChildEvent                                                              --
-- Description    : delete wells when Equipments that are linked to the wells are deleted.         --
-- Preconditions  :
-- Postconditions : Wells linked to the equipments are deleted.                                                                                --
--                                                                                                 --
-- Using tables   :
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
Procedure delEqpmWellChildEvent(p_object_id VARCHAR2, p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE)
--</EC-DOC>
IS

BEGIN

   DELETE
     FROM strm_day_asset_well_data
     WHERE object_id = p_object_id
       AND class_name = p_class_name
       AND daytime = p_daytime
       AND asset_id = p_asset_id
       AND start_daytime = p_start_daytime;

END delEqpmWellChildEvent;

END EcDp_Stream_VentFlare;