CREATE OR REPLACE PACKAGE BODY EcDp_Tank IS
/****************************************************************
** Package        :  EcDp_Tank, body part
**
** $Revision: 1.13.120.2 $
**
** Purpose        :  This package is responsible for finding data from tank ticket
**                   records.
**
** Documentation  :  www.energy-components.com
**
** Created  : 01.11.2001  Frode Barstad
**
** Modification history:
**
**  Date        Whom  Change description:
**  ----------  ----- --------------------------------------
**  01.11.2001  FBa   First version
**  2002-02-07  FBa   Added SetAttribute
**  2002-03-05  DN    Documented procedure.
    03.08.2004 mazrina    removed sysnam and update as necessary
**  2004-08-19 Toha   added setAttribute
**	 24.05.2005	kaurrnar	Removed deadcode.Removed insertAttribute, updateAttribute and set Attribute
**				Change tank_attribute to tank_version
**          02.03.2004	Ron	Removed function getTankCalcMethod.
				Changed number of parameters passed in to EcDp_Groups.findParentObjectID.
**  27.05.2005  DN   Function getTankFacility: Replaced EcDp_Groups.findParentObjectID with direct ec-package call.
**	17.10.2012	makkkkam	added procedure SetTankTapsEndDate
**	23.10.2012	limmmchu	ECPD:22065 added procedure createTankTapsAnalysis
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getStartDate
-- Description    : Returns start data for tank
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : TANK
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getStartDate(
  p_tank_object_id TANK.OBJECT_ID%TYPE)
RETURN DATE
--</EC-DOC>
IS
  lr_tank          TANK%ROWTYPE;
  ld_retval        DATE;

BEGIN
  lr_tank := ec_tank.row_by_object_id(p_tank_object_id);

  ld_retval := lr_tank.start_date;

  RETURN ld_retval;
END getStartDate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDeadStockVol
-- Description    : Returns dead stock volume for the tank on a given day.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : TANK_VERSION
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getDeadStockVol(
  p_tank_object_id TANK.OBJECT_ID%TYPE,
  p_daytime        DATE)
RETURN NUMBER
--</EC-DOC>
IS

  ln_retval        NUMBER;

BEGIN

  ln_retval := ec_tank_version.DEADSTOCK_VOL(p_tank_object_id, p_daytime,'<=');

  RETURN ln_retval;
END getDeadStockVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDeadStockMass
-- Description    : Returns dead stock mass for the tank on a given day.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : TANK_VERSION
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getDeadStockMass(
  p_tank_object_id TANK.OBJECT_ID%TYPE,
  p_daytime        DATE)
RETURN NUMBER
--</EC-DOC>
IS

  ln_retval        NUMBER;

BEGIN

  ln_retval := ec_tank_version.DEADSTOCK_MASS(p_tank_object_id, p_daytime,'<=');

  RETURN ln_retval;
END getDeadStockMass;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getMaxVol
-- Description    : Returns maximum volume for the tank on a given day.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : TANK_VERSION
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getMaxVol(
  p_tank_object_id TANK.OBJECT_ID%TYPE,
  p_daytime        DATE)
RETURN NUMBER
--</EC-DOC>
IS

  ln_retval        NUMBER;

BEGIN

  ln_retval := ec_tank_version.MAX_VOL(p_tank_object_id, p_daytime,'<=');

  RETURN ln_retval;
END getMaxVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTankMeterFrequency
-- Description    : Returns the metering frequency for a given tank
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : TANK_VERSION
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTankMeterFrequency(
  p_tank_object_id TANK.OBJECT_ID%TYPE,
  p_daytime        DATE)
RETURN VARCHAR2
--</EC-DOC>
IS

  ln_retval        VARCHAR2(300);

BEGIN

  ln_retval := ec_tank_version.TANK_METER_FREQ(p_tank_object_id, p_daytime,'<=');

  RETURN ln_retval;
END getTankMeterFrequency;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTankType
-- Description    : Returns the tank type for a given tank
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : TANK_VERSION
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTankType(
  p_tank_object_id TANK.OBJECT_ID%TYPE,
  p_daytime        DATE)
RETURN VARCHAR2
--</EC-DOC>
IS
  lr_tank          TANK%ROWTYPE;
  ln_retval        VARCHAR2(300);

BEGIN
  lr_tank := ec_tank.row_by_object_id(p_tank_object_id);

  return null;
END getTankType;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getTankFacility
-- Description    : Find the facilty a tank is connected to.
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
FUNCTION  getTankFacility(
   p_tank_object_id  IN VARCHAR2,
   p_daytime           IN DATE)

RETURN VARCHAR2
--</EC-DOC>
IS

BEGIN

   RETURN  ec_tank_version.op_fcty_class_1_id(p_tank_object_id, p_daytime, '<=');

END getTankFacility;

---------------------------------------------------------------------------------------------------
-- Procedure      : SetTankTapsEndDate
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : DV_TANK_TAPS
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior       : Set the end_date of previous day's records with the current new datetime during
--                  new record insertions. Also, it update the end_date
--                  of the respective previous day's records during deleting the existing records.
---------------------------------------------------------------------------------------------------
PROCEDURE SetTankTapsEndDate( p_object_id     VARCHAR2,
                          p_Daytime    DATE,
                          p_DML_Type      VARCHAR2)
IS

  ld_mindate tank_taps.daytime%type := NULL;
  ld_maxdate tank_taps.daytime%type := NULL;
  ld_object_count number :=NULL;

    -- get the MINIMUM daytime LATER than the newDaytime
    CURSOR c_getMinDate IS
    SELECT Min(daytime)
    FROM TANK_TAPS
    WHERE object_id = p_object_id
    AND daytime > p_Daytime;

    -- get the MAXIMUM daytime BEFORE the newDaytime
    CURSOR c_getMaxDate IS
    SELECT Max(daytime)
    FROM TANK_TAPS
    WHERE object_id = p_object_id
    AND daytime < p_Daytime;

    -- get the Count for the object
    CURSOR c_getObjectCount IS
    SELECT Count(*)
    FROM TANK_TAPS
    WHERE object_id = p_object_id
    AND daytime = p_Daytime;

BEGIN

    Open c_getMaxDate;
    Fetch c_getMaxDate into ld_maxdate;
    Close c_getMaxDate;

    Open c_getMinDate;
    Fetch c_getMinDate into ld_mindate;
    Close c_getMinDate;

    Open c_getObjectCount;
    Fetch c_getObjectCount into ld_object_count;
    Close c_getObjectCount;

  If upper(p_DML_Type) = 'INSERT' then

    -- update the previous tank_tap's end date if there are any
    if ld_maxdate is NOT null then
      UPDATE TANK_TAPS
      SET end_date = p_Daytime
      WHERE object_id = p_object_id
      AND daytime = ld_maxdate;
    end if;

    --update the newly inserted tank taps if there are any next records
    if ld_mindate is NOT null then
      UPDATE TANK_TAPS
      SET end_date = ld_mindate
      WHERE object_id = p_object_id
      AND daytime = p_Daytime;
    end if;

  Elsif upper(p_DML_Type) = 'DELETE' then

    if ld_object_count = 0 then
        -- The deleted tank tap have previous and after records,
        -- Set the previous tank taps end date to the next Min daytime.
        if ld_maxdate is not null and ld_mindate is not null then
          UPDATE TANK_TAPS
          SET end_date = ld_mindate
          WHERE object_id = p_object_id
          AND daytime = ld_maxdate;
        end if;

        -- The deleted tank tap is the latest tank tap,
        -- Set the end date of the previous tank tap to NULL
        if ld_maxdate is not null and ld_mindate is null then
          UPDATE TANK_TAPS
          SET end_date = NULL
          WHERE object_id = p_object_id
          AND daytime = ld_maxdate;
        end if;

    end if;

  End if;

END SetTankTapsEndDate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : createTankTapAnalysisForAnalysis
-- Description  : Instantiates all height associated with the current tank taps
--                into the tank analysis and assigns them to the analysis given.
--
--
--
-- Preconditions:
-- Postcondition: Possibly uncommitted changes.
--
-- Using Tables: Tank Tap Analysis, Tank Taps
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour: Only instantiate if analysis exist and there is no records in the Tank Tap Analysis table
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE createTankTapsAnalysis(p_object_id VARCHAR2, p_analysis_no NUMBER, p_daytime DATE, p_user_id VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS

CURSOR c_current_taps(cp_object_id varchar2) IS
SELECT c.TANK_HEIGHT
FROM TANK_TAPS c
WHERE c.object_id = cp_object_id
AND p_daytime >= c.daytime AND (p_daytime < c.end_date OR c.end_date IS NULL);

   ln_no_taps NUMBER;


BEGIN

   ln_no_taps := 0;

   IF ec_tank_analysis.analysis_status(p_analysis_no) IS NOT NULL THEN

      SELECT count(HEIGHT)
      INTO ln_no_taps
      FROM tank_tap_analysis
      WHERE object_id = p_object_id
      AND ANALYSIS_NO = p_analysis_no;

      IF ln_no_taps = 0 THEN

         FOR cur_rec IN c_current_taps(p_object_id) LOOP

            INSERT INTO tank_tap_analysis (height, analysis_no, object_id, created_by)
            VALUES (cur_rec.tank_height, p_analysis_no, p_object_id, p_user_id);

         END LOOP;

      END IF;

   END IF;

END createTankTapsAnalysis;

END;