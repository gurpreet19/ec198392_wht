CREATE OR REPLACE PACKAGE BODY EcBp_Area_Theoretical IS

/****************************************************************
** Package        :  EcBp_Area_Theoretical, header part
**
** $Revision: 1.0 $
**
** Purpose        :  Provides theoretical fluid values (rates etc)
**	                  for a given Area.
**
** Documentation  :  www.energy-components.com
**
** Created  : 27.10.15
**
** Modification history:
**
** Version  Date     	Whom  Change description:
** -------  ------   	----- --------------------------------------
** 1.0   	27.10.15  	kashisag   Initial version
** 1.1   	29.10.15  	dhavaalo   ECPD-32519-getAreaPhaseStdVolMonth Added
** 1.2   	04.05.16  	jainnraj   ECPD-35492-Modify getAreaPhaseStdVolDay,getAreaPhaseStdVolMonth to change default value of FORECAST_TYPE(OFFICIAL)
** 1.3   	14.03.17  	kashisag   ECPD-42996-Updated getAreaPhaseStdVolDay for getting daily planned value for Area
** 1.4      16.04.2018  kashisag   ECPD-53238: Updated daily and monthly functions for actual and planned widgets
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getAreaPhaseStdVolDay                                                    --
-- Description    : Returns total volume for planned, actual, deferred and unassigned deferred   --
--                                                             --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :                                                               --
--                                                                                               --
-- Using functions:                                      --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getAreaPhaseStdVolDay(p_object_id    VARCHAR2,
                          p_daytime      DATE,
                          p_type  VARCHAR2,
                          p_phase VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS
   ln_ret_val NUMBER ;

BEGIN

  IF p_type = 'PLANNED'  THEN
    BEGIN

        SELECT  SUM(EcBp_Facility_Theoretical.getFacilityPhaseStdVolDay(a.object_id, p_daytime, p_type, p_phase))
        INTO    ln_ret_val
        FROM    FCTY_VERSION a
        WHERE   a.OP_AREA_ID  = p_object_id
        AND     a.DAYTIME    <= p_daytime
        GROUP BY p_daytime;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
                ln_ret_val := NULL;
    END ;


  ELSIF p_type = 'ACTUAL'  THEN
    BEGIN

        SELECT  SUM(EcBp_Facility_Theoretical.getFacilityPhaseStdVolDay(a.object_id, p_daytime, p_type, p_phase))
        INTO    ln_ret_val
        FROM    FCTY_VERSION a
        WHERE   a.OP_AREA_ID  = p_object_id
        AND     a.DAYTIME    <= p_daytime
        GROUP BY p_daytime;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
                ln_ret_val:=NULL;
    END ;

  END IF;    -- end if

  RETURN ln_ret_val;

END getAreaPhaseStdVolDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getAreaPhaseStdVolMonth                                                    --
-- Description    : Returns total volume for planned, actual per month per phase for Area  --
--                                                             --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :                                                               --
--                                                                                               --
-- Using functions:                                      --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getAreaPhaseStdVolMonth(p_object_id VARCHAR2,
                                 p_daytime   DATE,
                                 p_type      VARCHAR2,
                                 p_phase     VARCHAR2) RETURN NUMBER
--</EC-DOC>
 IS
  ln_ret_val NUMBER;


BEGIN

  IF p_type = 'PLANNED' THEN

    BEGIN

        SELECT SUM(EcBp_Facility_Theoretical.getFacilityPhaseVolMonth(a.object_id, p_daytime, p_type, p_phase))
        INTO    ln_ret_val
        FROM    FCTY_VERSION a
        WHERE   a.OP_AREA_ID  = p_object_id
        AND     a.DAYTIME    <= p_daytime
        GROUP BY p_daytime;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
                ln_ret_val := NULL;

    END ;
  ELSIF p_type = 'ACTUAL' THEN
    BEGIN
        SELECT SUM(EcBp_Facility_Theoretical.getFacilityPhaseVolMonth(a.object_id, p_daytime, p_type, p_phase))
        INTO    ln_ret_val
        FROM    FCTY_VERSION a
        WHERE   a.OP_AREA_ID  = p_object_id
        AND     a.DAYTIME    <= p_daytime
        GROUP BY p_daytime;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        ln_ret_val := NULL;
    END;

  END IF;

  RETURN ln_ret_val;

END getAreaPhaseStdVolMonth;

END EcBp_Area_Theoretical;