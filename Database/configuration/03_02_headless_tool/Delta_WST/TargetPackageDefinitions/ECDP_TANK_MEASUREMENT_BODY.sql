CREATE OR REPLACE PACKAGE BODY EcDp_Tank_Measurement IS
/****************************************************************
** Package        :  EcDp_Tank_Measurement, body part
**
** $Revision: 1.17 $
**
** Purpose        :  This package is responsible for returning measured tank data.
**
** Documentation  :  www.energy-components.com
**
** Created  : 29.04.2004  Frode Barstad
**
** Modification history:
**
** Version  Date        Whom  Change description:
** -------  ----------  ----- --------------------------------------
** 1.0      29.04.2004  FBa   Initial version
** 1.4      25.05.2004  FBa   Adjusted to new columns names in tank_measurement for ctl and cpl
** 1.5      27.05.2004  FBa   CTL and CPL replaced by new column: VCF
** 1.6      09.06.2004  HNE   Added new parameter to functions accessing tank_measurement
   1.7      03.08.04    Mazrina   removed sysnam and update as necessary
** 1.8      09.11.2005  kaurrnar  TI 2743: Ticket Volume default to NULL if net volume is 0 for function setDefaultTicketVol
**          03.06.2008  ismaiime ECPD-8478: Modify procedure createMeasurementSet. Add new parameter p_tank_object_id.
**          22.10.2008  amirrasn ECPD-9194: Modify createMeasurementSet procedure. Insert new value in CREATED_BY field
** 10.0     21.11.2008  oonnnng  ECPD-6067: Added local month lock checking in createMeasurementSet, setDefaultTicketVol, setDefaultExportTank functions.
**          17.02.2009  leongsei ECPD-6067: Modifie function createMeasurementSet, setDefaultTicketVol, setDefaultExportTank for new parameter p_local_lock
**          10.04.2009  oonnnng  ECPD-6067: Update local lock checking function in createMeasurementSet, setDefaultTicketVol, setDefaultExportTank functions to new design.
*****************************************************************/

CURSOR c_tank_measurement(p_tank_object_id IN TANK.OBJECT_ID%TYPE,
                          p_meas_event_type IN TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
                          p_daytime DATE) IS
SELECT *
FROM tank_measurement tm
WHERE tm.object_id = p_tank_object_id
  AND tm.measurement_event_type = p_meas_event_type
  AND tm.daytime = p_daytime;

--<EC-DOC>
-----------------------------------------------------------------
-- Function     : getGrsVol
-- Description  : Returns the tank's daily value
--
-- Preconditions:
-- Postcondition:
-- Using Tables:  tank_measurement
--
-- Using functions: none
--
-- Configuration required:
--
-- Behaviour
--
-----------------------------------------------------------------
FUNCTION getGrsVol (
   p_tank_object_id TANK.OBJECT_ID%TYPE,
   p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime        DATE)
RETURN NUMBER
--</EC-DOC>
IS

lr_measurement TANK_MEASUREMENT%ROWTYPE;

BEGIN

  OPEN c_tank_measurement( p_tank_object_id, p_meas_event_type, p_daytime );
  FETCH c_tank_measurement INTO lr_measurement;
  CLOSE c_tank_measurement;

  RETURN lr_measurement.grs_vol;

END getGrsVol;


--<EC-DOC>
-----------------------------------------------------------------
-- Function     : getNetVol
-- Description  : Returns the tank's daily value
--
-- Preconditions:
-- Postcondition:
-- Using Tables:  tank_measurement
--
-- Using functions: none
--
-- Configuration required:
--
-- Behaviour
--
-----------------------------------------------------------------
FUNCTION getNetVol (
   p_tank_object_id TANK.OBJECT_ID%TYPE,
   p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime        DATE)
RETURN NUMBER
--</EC-DOC>
IS

lr_measurement TANK_MEASUREMENT%ROWTYPE;

BEGIN

  OPEN c_tank_measurement( p_tank_object_id, p_meas_event_type, p_daytime );
  FETCH c_tank_measurement INTO lr_measurement;
  CLOSE c_tank_measurement;

  RETURN lr_measurement.net_vol;

END getNetVol;


--<EC-DOC>
-----------------------------------------------------------------
-- Function     : getBSWVol
-- Description  : Returns the tank's daily value
--
-- Preconditions:
-- Postcondition:
-- Using Tables:  tank_measurement
--
-- Using functions: none
--
-- Configuration required:
--
-- Behaviour
--
-----------------------------------------------------------------
FUNCTION getBSWVol (
   p_tank_object_id TANK.OBJECT_ID%TYPE,
   p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime        DATE)
RETURN NUMBER
--</EC-DOC>
IS

lr_measurement TANK_MEASUREMENT%ROWTYPE;

BEGIN

  OPEN c_tank_measurement( p_tank_object_id, p_meas_event_type, p_daytime );
  FETCH c_tank_measurement INTO lr_measurement;
  CLOSE c_tank_measurement;

  RETURN lr_measurement.bsw_vol;

END getBSWVol;


--<EC-DOC>
-----------------------------------------------------------------
-- Function     : getBSWWt
-- Description  : Returns the tank's daily value
--
-- Preconditions:
-- Postcondition:
-- Using Tables:  tank_measurement
--
-- Using functions: none
--
-- Configuration required:
--
-- Behaviour
--
-----------------------------------------------------------------
FUNCTION getBSWWt (
   p_tank_object_id TANK.OBJECT_ID%TYPE,
   p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime        DATE)
RETURN NUMBER
--</EC-DOC>
IS

lr_measurement TANK_MEASUREMENT%ROWTYPE;

BEGIN

  OPEN c_tank_measurement( p_tank_object_id, p_meas_event_type, p_daytime );
  FETCH c_tank_measurement INTO lr_measurement;
  CLOSE c_tank_measurement;

  RETURN lr_measurement.bsw_mass;

END getBSWWt;


--<EC-DOC>
-----------------------------------------------------------------
-- Function     : getWaterVol
-- Description  : Returns the tank's daily value
--
-- Preconditions:
-- Postcondition:
-- Using Tables:  tank_measurement
--
-- Using functions: none
--
-- Configuration required:
--
-- Behaviour
--
-----------------------------------------------------------------
FUNCTION getWaterVol (
   p_tank_object_id TANK.OBJECT_ID%TYPE,
   p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime        DATE)
RETURN NUMBER
--</EC-DOC>
IS

lr_measurement TANK_MEASUREMENT%ROWTYPE;

BEGIN

  OPEN c_tank_measurement( p_tank_object_id, p_meas_event_type, p_daytime );
  FETCH c_tank_measurement INTO lr_measurement;
  CLOSE c_tank_measurement;

  RETURN lr_measurement.water_vol;

END getWaterVol;


--<EC-DOC>
-----------------------------------------------------------------
-- Function     : getStdDens
-- Description  : Returns the tank's daily value
--
-- Preconditions:
-- Postcondition:
-- Using Tables:  tank_measurement
--
-- Using functions: none
--
-- Configuration required:
--
-- Behaviour
--
-----------------------------------------------------------------
FUNCTION getStdDens (
   p_tank_object_id TANK.OBJECT_ID%TYPE,
   p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime        DATE)
RETURN NUMBER
--</EC-DOC>
IS

lr_measurement TANK_MEASUREMENT%ROWTYPE;

BEGIN

  OPEN c_tank_measurement( p_tank_object_id, p_meas_event_type, p_daytime );
  FETCH c_tank_measurement INTO lr_measurement;
  CLOSE c_tank_measurement;

  RETURN lr_measurement.density;

END getStdDens;


--<EC-DOC>
-----------------------------------------------------------------
-- Function     : getObsDens
-- Description  : Returns the tank's daily value
--
-- Preconditions:
-- Postcondition:
-- Using Tables:  tank_measurement
--
-- Using functions: none
--
-- Configuration required:
--
-- Behaviour
--
-----------------------------------------------------------------
FUNCTION getObsDens (
   p_tank_object_id TANK.OBJECT_ID%TYPE,
   p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime        DATE)
RETURN NUMBER
--</EC-DOC>
IS

lr_measurement TANK_MEASUREMENT%ROWTYPE;

BEGIN

  OPEN c_tank_measurement( p_tank_object_id, p_meas_event_type, p_daytime );
  FETCH c_tank_measurement INTO lr_measurement;
  CLOSE c_tank_measurement;

  RETURN lr_measurement.density_stor;

END getObsDens;


--<EC-DOC>
-----------------------------------------------------------------
-- Function     : getGrsMass
-- Description  : Returns the tank's daily value
--
-- Preconditions:
-- Postcondition:
-- Using Tables:  tank_measurement
--
-- Using functions: none
--
-- Configuration required:
--
-- Behaviour
--
-----------------------------------------------------------------
FUNCTION getGrsMass (
   p_tank_object_id TANK.OBJECT_ID%TYPE,
   p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime        DATE)
RETURN NUMBER
--</EC-DOC>
IS

lr_measurement TANK_MEASUREMENT%ROWTYPE;

BEGIN

  OPEN c_tank_measurement( p_tank_object_id, p_meas_event_type, p_daytime );
  FETCH c_tank_measurement INTO lr_measurement;
  CLOSE c_tank_measurement;

  RETURN lr_measurement.grs_mass;

END getGrsMass;


--<EC-DOC>
-----------------------------------------------------------------
-- Function     : getNetMass
-- Description  : Returns the tank's daily value
--
-- Preconditions:
-- Postcondition:
-- Using Tables:  tank_measurement
--
-- Using functions: none
--
-- Configuration required:
--
-- Behaviour
--
-----------------------------------------------------------------
FUNCTION getNetMass (
   p_tank_object_id TANK.OBJECT_ID%TYPE,
   p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime        DATE)
RETURN NUMBER
--</EC-DOC>
IS

lr_measurement TANK_MEASUREMENT%ROWTYPE;

BEGIN

  OPEN c_tank_measurement( p_tank_object_id, p_meas_event_type, p_daytime );
  FETCH c_tank_measurement INTO lr_measurement;
  CLOSE c_tank_measurement;

  RETURN lr_measurement.net_mass;

END getNetMass;


--<EC-DOC>
-----------------------------------------------------------------
-- Function     : getGrsDipLevel
-- Description  : Returns the tank's daily value
--
-- Preconditions:
-- Postcondition:
-- Using Tables:  tank_measurement
--
-- Using functions: none
--
-- Configuration required:
--
-- Behaviour
--
-----------------------------------------------------------------
FUNCTION getGrsDipLevel (
   p_tank_object_id TANK.OBJECT_ID%TYPE,
   p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime        DATE)
RETURN NUMBER
--</EC-DOC>
IS

lr_measurement TANK_MEASUREMENT%ROWTYPE;

BEGIN

  OPEN c_tank_measurement( p_tank_object_id, p_meas_event_type, p_daytime );
  FETCH c_tank_measurement INTO lr_measurement;
  CLOSE c_tank_measurement;

  RETURN lr_measurement.grs_dip_level;

END getGrsDipLevel;


--<EC-DOC>
-----------------------------------------------------------------
-- Function     : getWaterDipLevel
-- Description  : Returns the tank's daily value
--
-- Preconditions:
-- Postcondition:
-- Using Tables:  tank_measurement
--
-- Using functions: none
--
-- Configuration required:
--
-- Behaviour
--
-----------------------------------------------------------------
FUNCTION getWaterDipLevel (
   p_tank_object_id TANK.OBJECT_ID%TYPE,
   p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime        DATE)
RETURN NUMBER
--</EC-DOC>
IS

lr_measurement TANK_MEASUREMENT%ROWTYPE;

BEGIN

  OPEN c_tank_measurement( p_tank_object_id, p_meas_event_type, p_daytime );
  FETCH c_tank_measurement INTO lr_measurement;
  CLOSE c_tank_measurement;

  RETURN lr_measurement.wat_dip_level;

END getWaterDipLevel;


--<EC-DOC>
-----------------------------------------------------------------
-- Function     : getVolumeCorrectionFactor
-- Description  : Returns the tank's volume correction factor, calculated by API component
--
-- Preconditions:
-- Postcondition:
-- Using Tables:  tank_measurement
--
-- Using functions: none
--
-- Configuration required:
--
-- Behaviour
--
-----------------------------------------------------------------
FUNCTION getVolumeCorrectionFactor (
   p_tank_object_id TANK.OBJECT_ID%TYPE,
   p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime        DATE)
RETURN NUMBER
--</EC-DOC>
IS

lr_measurement TANK_MEASUREMENT%ROWTYPE;
ln_vcf         NUMBER;
--ln_ctl         NUMBER;
--ln_cpl         NUMBER;

BEGIN

  OPEN c_tank_measurement( p_tank_object_id, p_meas_event_type, p_daytime );
  FETCH c_tank_measurement INTO lr_measurement;
  CLOSE c_tank_measurement;

--  ln_ctl := Nvl(lr_measurement.ctl_vol_factor, 1);
--  ln_cpl := Nvl(lr_measurement.cpl_vol_factor, 1);
  ln_vcf := Nvl(lr_measurement.vcf, 1);

  RETURN ln_vcf;

END getVolumeCorrectionFactor;


--<EC-DOC>
-----------------------------------------------------------------
-- Function     : createMeasurementSet
-- Description  : Instantiates/deletes all tank_measurement components
--                assosiated with this stream
--
-- Preconditions: Possibly uncommitted changes.
-- Postcondition:
-- Using Tables:  TANK_MEASUREMENT, STRM_EVENT
--
-- Using functions: none
--
-- Configuration required:
--
-- Behaviour: Only instantiate if there is no records in the tank_measurement table.
--
-----------------------------------------------------------------
PROCEDURE createMeasurementSet(
   p_strm_object_id  STRM_EVENT.OBJECT_ID%TYPE,
   p_event_type      STRM_EVENT.EVENT_TYPE%TYPE,
   p_daytime         DATE,
   p_method          VARCHAR2,
   p_tank_object_id  TANK.OBJECT_ID%TYPE DEFAULT NULL)
--</EC-DOC>
IS
   lv2_tank_object_id  TANK.OBJECT_ID%TYPE;
   ln_row_cnt          NUMBER := 0;

BEGIN

   -- lock check
   IF EcDp_Month_lock.withinLockedMonth(p_daytime) IS NOT NULL THEN

      EcDp_Month_lock.raiseValidationError('PROCEDURE', p_daytime, p_daytime, trunc(p_daytime,'MONTH'), 'EcDp_Tank_measurement.CreateMeasurementSet: Can not do this in a locked month');

   END IF;

    EcDp_Month_Lock.localLockCheck('withinLockedMonth', p_strm_object_id,
                                   p_daytime, p_daytime,
                                   'PROCEDURE', 'EcDp_Tank_measurement.CreateMeasurementSet: Can not do this in a local locked month.');

   -- Find Tank Object Id
   IF p_tank_object_id IS NULL THEN
     lv2_tank_object_id := Ecdp_Stream.getStreamTank(p_strm_object_id, p_daytime);
   ELSE
     lv2_tank_object_id := p_tank_object_id;
   END IF;

   IF p_method = 'OPEN_CLOSE' THEN

     -- Check if we are in a delete, insert or update mode
     SELECT COUNT(*) into ln_row_cnt
     FROM STRM_EVENT
     WHERE object_id = p_strm_object_id AND
           event_type =  p_event_type AND
           daytime = p_daytime;

     IF ln_row_cnt = 0 THEN
        -- Delete, clean up tank measurement connected to this stream event

        DELETE FROM TANK_MEASUREMENT
        WHERE DAYTIME = p_daytime AND
              OBJECT_ID = lv2_tank_object_id AND
              MEASUREMENT_EVENT_TYPE IN ('DUAL_DIP_OPENING','DUAL_DIP_CLOSING');

     ELSE
         -- Insert or Update

         -- Check if rows alread exists
         SELECT COUNT(*) into ln_row_cnt
         FROM TANK_MEASUREMENT
         WHERE object_id = lv2_tank_object_id and
               DAYTIME = p_daytime and
               MEASUREMENT_EVENT_TYPE IN ('DUAL_DIP_OPENING','DUAL_DIP_CLOSING');

         IF ln_row_cnt = 0 THEN
           -- Initialize table with new measurements
           INSERT INTO TANK_MEASUREMENT (DAYTIME, OBJECT_ID, MEASUREMENT_EVENT_TYPE, CREATED_BY) VALUES (p_daytime, lv2_tank_object_id, 'DUAL_DIP_OPENING', ecdp_context.getAppUser);
           INSERT INTO TANK_MEASUREMENT (DAYTIME, OBJECT_ID, MEASUREMENT_EVENT_TYPE, CREATED_BY) VALUES (p_daytime, lv2_tank_object_id, 'DUAL_DIP_CLOSING', ecdp_context.getAppUser);
         END IF;
      END IF;
   ELSE
      -- No other methods supported YET
      RETURN;
   END IF;

END createMeasurementSet;

--<EC-DOC>
-----------------------------------------------------------------
-- Function     : setDefaultTicketVol
-- Description  : Set default value (NetStdVol) for Ticket Net Volume
--                (STRM_EVENT.GRS_VOL) if NULL
--
-- Preconditions: Possibly uncommitted changes.
-- Postcondition:
-- Using Tables:  STRM_EVENT
--
-- Using functions: none
--
-- Configuration required:
--
-- Behaviour:
--
-----------------------------------------------------------------
PROCEDURE setDefaultTicketVol(
   p_strm_object_id TANK.OBJECT_ID%TYPE,
   p_daytime DATE,
   p_ticket_net_vol STRM_EVENT.GRS_VOL%TYPE)
--</EC-DOC>
IS
  ln_net_std_vol  STRM_EVENT.GRS_VOL%TYPE;

BEGIN

   -- lock check
   IF EcDp_Month_lock.withinLockedMonth(p_daytime) IS NOT NULL THEN

      EcDp_Month_lock.raiseValidationError('PROCEDURE', p_daytime, p_daytime, trunc(p_daytime,'MONTH'), 'EcDp_Tank_measurement.setDefaultTicketVol: Can not do this in a locked month');

   END IF;

    EcDp_Month_Lock.localLockCheck('withinLockedMonth', p_strm_object_id,
                                   p_daytime, p_daytime,
                                   'PROCEDURE', 'EcDp_Tank_measurement.setDefaultTicketVol: Can not do this in a local locked month');

   IF (p_ticket_net_vol IS NULL OR p_ticket_net_vol=0) THEN
     ln_net_std_vol := EcBp_Stream_Fluid.findNetStdVol(p_strm_object_id,
                                                       p_daytime,
                                                       p_daytime,
                                                       EcDp_Calc_Method.TANK_DUAL_DIP);

     IF ln_net_std_vol IS NOT NULL THEN
        -- Update STRM_EVENT record with default
        UPDATE STRM_EVENT
           SET NET_VOL = ln_net_std_vol
         WHERE OBJECT_ID = p_strm_object_id AND
                EVENT_TYPE = 'OIL_TANK_BATCH_EXPORT' AND
               DAYTIME = p_daytime;

     END IF;
   END IF;

END setDefaultTicketVol;

--<EC-DOC>
-----------------------------------------------------------------
-- Function     : setDefaultExportTank
-- Description  : Set default value (TANK_OBJECT_ID) for Export Tank
--                (STRM_EVENT.TANK_OBJ_ID) if NULL
--
-- Preconditions: Possibly uncommitted changes.
-- Postcondition:
-- Using Tables:  STRM_EVENT
--
-- Using functions: none
--
-- Configuration required:
--
-- Behaviour:
--
-----------------------------------------------------------------
PROCEDURE setDefaultExportTank(
   p_strm_object_id TANK.OBJECT_ID%TYPE,
   p_daytime DATE)
--</EC-DOC>
IS

CURSOR c_tank IS
       SELECT tank_object_id
       FROM STRM_EVENT
       WHERE object_id = p_strm_object_id
       AND daytime = p_daytime
       AND event_type = 'OIL_TANK_BATCH_EXPORT';

lv2_tank_object_id TANK.OBJECT_ID%TYPE;

BEGIN

  -- lock check
  IF EcDp_Month_lock.withinLockedMonth(p_daytime) IS NOT NULL THEN

    EcDp_Month_lock.raiseValidationError('PROCEDURE', p_daytime, p_daytime, trunc(p_daytime,'MONTH'), 'EcDp_Tank_measurement.setDefaultExportTank: Cannot do this in a locked month');

  END IF;

    EcDp_Month_Lock.localLockCheck('withinLockedMonth', p_strm_object_id,
                                   p_daytime, p_daytime,
                                   'PROCEDURE', 'EcDp_Tank_measurement.setDefaultExportTank: Can not do this in a local locked month.');

    FOR c_t IN c_tank LOOP

      IF c_t.tank_object_id IS NULL THEN
        lv2_tank_object_id := Ecdp_Stream.getStreamTank(p_strm_object_id, p_daytime);

        IF lv2_tank_object_id IS NOT NULL THEN
        --Update STRM_EVENT with default tank connected to stream
          UPDATE STRM_EVENT
          SET TANK_OBJECT_ID = lv2_tank_object_id
          WHERE OBJECT_ID = p_strm_object_id
          AND EVENT_TYPE = 'OIL_TANK_BATCH_EXPORT'
          AND DAYTIME =  p_daytime;
        END IF;
      END IF;
    END LOOP;

END setDefaultExportTank;

END EcDp_Tank_Measurement;