CREATE OR REPLACE PACKAGE BODY EcDp_Flowline_Sub_Well_Conn IS
/******************************************************************************
** Package        :  EcDp_Flowline_Sub_Well_Conn
**
** $Revision: 1.0 $
**
** Purpose        :  Display information about flowline=>well and well => Flowline
**
** Documentation  :  www.energy-components.com
**
** Created  : 23.09.2016  jainngou
**
** Modification history:
**
** Version  Date        Whom      Change description:
** -------  ----------  -----     -----------------------------------------------------------------------------------------------
** 1.0      22.09.2016  jainngou   ECPD-36906:Intial version
** 1.1      05.06.2016  dhavaalo   ECPD-44874-Replace references ref_object_id_3 , ref_object_id_4 with proper column name.
********************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : FlowlineIDForWell
-- Description    : Gives a comma separated list of object_ID's for the flowlines the well is connected
--                  to at the given time.
-- Preconditions  :
--
-- Postconditions :
-- Using tables   : FLOWLINE_SUB_WELL_CONN
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Uses the actual well flowline connection
--
---------------------------------------------------------------------------------------------------

FUNCTION FlowlineIDForWell(
	p_well_id  FLOWLINE_SUB_WELL_CONN.WELL_ID%TYPE,
	p_daytime FLOWLINE_SUB_WELL_CONN.DAYTIME%TYPE)
RETURN VARCHAR2
--</EC-DOC>
 IS

CURSOR c_flowlines(cp_well_id VARCHAR2, cp_daytime DATE) IS
   SELECT object_id, daytime
   FROM   flowline_sub_well_conn a
   WHERE well_id  = cp_well_id
   AND daytime <= cp_daytime
   AND NVL(end_date, cp_daytime + 2) > cp_daytime
   ORDER BY a.daytime DESC;

  lv2_returnval VARCHAR2(2000);

BEGIN

  For v_flowlines IN c_flowlines(p_well_id, p_daytime) LOOP
      IF lv2_returnval IS NULL THEN
          lv2_returnval := v_flowlines.object_id;
      ELSE
          lv2_returnval := lv2_returnval ||','|| v_flowlines.object_id;
      END If;
  END LOOP;

  RETURN lv2_returnval;

END FlowlineIDForWell;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : FlowlinesForWellProdDay
-- Description    : Gives a comma separated list of names for the flowlines connected to the well during the production day.
--
-- Preconditions  : Flowline Name <> NULL. p_daytime represents the aquired production day.
--
-- Postconditions :
-- Using tables   :FLOWLINE_SUB_WELL_CONN
--
-- Using functions: EcDp_ProductionDay.getProductionDayOffset
--
-- Configuration
-- required       :
--
-- Behaviour      : Uses the actual well flowline connection. Cope with production day offset if available.
--
---------------------------------------------------------------------------------------------------
 FUNCTION FlowlinesForWellProdDay(
          p_well_id  FLOWLINE_SUB_WELL_CONN.WELL_ID%TYPE,
          p_daytime FLOWLINE_SUB_WELL_CONN.DAYTIME%TYPE)
          RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR c_flowlines(cp_well_id VARCHAR2, cp_daytime DATE, cp_offset_days NUMBER) IS
   SELECT object_id, daytime
   FROM flowline_sub_well_conn a
   WHERE well_id  = cp_well_id
   AND daytime  < cp_daytime + cp_offset_days
   AND NVL(end_date, cp_daytime + 2) > cp_daytime
   ORDER BY a.daytime DESC;

   lv2_returnval VARCHAR2(2000);
   ln_prod_day_offset NUMBER;

BEGIN

  ln_prod_day_offset := NVL(EcDp_ProductionDay.getProductionDayOffset('WELL', p_well_id, p_daytime),0);

  For v_flowlines IN c_flowlines(p_well_id, p_daytime + ln_prod_day_offset/24, 1) LOOP
      IF lv2_returnval IS NULL THEN
          lv2_returnval := ec_flwl_version.name(v_flowlines.object_id, v_flowlines.daytime, '<=');
      ELSE
          lv2_returnval := lv2_returnval ||', '|| ec_flwl_version.name(v_flowlines.object_id, v_flowlines.daytime, '<=');
      END If;
  END LOOP;

  RETURN lv2_returnval;

END FlowlinesForWellProdDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : FlowlinesForWell
-- Description    : Gives a comma separated list of names for the flowlines connected at the time given
--
-- Preconditions  : Flowline Name <> NULL
--
-- Postconditions :
-- Using tables   :FLOWLINE_SUB_WELL_CONN
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Uses the actual well flowline connection
--
---------------------------------------------------------------------------------------------------

FUNCTION FlowlinesForWell(
          p_well_id  FLOWLINE_SUB_WELL_CONN.WELL_ID%TYPE,
          p_daytime FLOWLINE_SUB_WELL_CONN.DAYTIME%TYPE)
          RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR c_flowlines(cp_well_id VARCHAR2, cp_daytime DATE) IS
  SELECT object_id, daytime
  FROM   flowline_sub_well_conn a
  WHERE well_id  = cp_well_id
  AND daytime <= cp_daytime
  AND NVL(end_date, cp_daytime + 2) > cp_daytime
  ORDER BY a.daytime DESC;


 lv2_returnval VARCHAR2(2000);

BEGIN

  FOR v_flowlines IN c_flowlines(p_well_id, p_daytime) LOOP
      IF lv2_returnval IS NULL THEN
          lv2_returnval := ec_flwl_version.name(v_flowlines.object_id, v_flowlines.daytime, '<=');
      ELSE
          lv2_returnval := lv2_returnval ||', '|| ec_flwl_version.name(v_flowlines.object_id, v_flowlines.daytime, '<=');
      END If;
  END LOOP;

  RETURN lv2_returnval;

END FlowlinesForWell;

  --<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetWellsOnFlowline
-- Description    : Gives a comma separated list of the wellname for the wells connected at this time
--
-- Preconditions  : Well Name <> NULL
--
-- Postconditions :
-- Using tables   :FLOWLINE_SUB_WELL_CONN
--
-- Using functions:
--                  ec_well_attribute.attribute_text
--
-- Configuration
-- required       :
--
-- Behaviour      : Uses the accual well flowline connection
--
---------------------------------------------------------------------------------------------------

FUNCTION GetWellsOnFlowline(
           p_flowline_id  FLOWLINE_SUB_WELL_CONN.OBJECT_ID%TYPE,
           p_daytime FLOWLINE_SUB_WELL_CONN.DAYTIME%TYPE)
           return VARCHAR2
  --</EC-DOC>
IS

 lv2_returnval VARCHAR2(2000);


CURSOR c_well_cursor IS
  SELECT WELL_id, daytime, ecdp_objects.getObjName(well_id,daytime) AS well_name
  FROM FLOWLINE_SUB_WELL_CONN a
  WHERE object_id = p_flowline_id
  AND DAYTIME = (
    SELECT Max(b.DAYTIME)
    FROM FLOWLINE_SUB_WELL_CONN b
    WHERE b.OBJECT_ID = a.object_id
    AND b.WELL_ID = a.WELL_ID
    AND b.DAYTIME <= p_daytime
    AND Nvl(b.end_date, p_daytime + 1) > p_daytime)
  ORDER BY 3;

BEGIN

  FOR v_well_cursor IN c_well_cursor LOOP
      IF lv2_returnval IS NULL THEN
        lv2_returnval:=  v_well_cursor.well_name;
      ELSE
        lv2_returnval:= lv2_returnval||', '|| v_well_cursor.well_name;
      END IF;
  END LOOP;

  RETURN lv2_returnval;

END GetWellsOnFlowline;

  --<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : switchFlowlineForWell
-- Description    : First checks whether well is connected to the flowline, and if necessary, creates a connection to the flowline and ends the existing connection.
--                  This is a simplified function that will work for the typical case where the data capture job populates the F1 and F2 indicators chronologically.
--                  It is not made to handle all possibilities for changes back in time.
--
-- Preconditions  : 1. Well is connected to two flowlines (attributes FLOWLINE_1_ID and FLOWLINE_2_ID)
--                  2. Well is connected to two flowlines (attributes FLOWLINE_1_ID and FLOWLINE_2_ID)
--
-- Postconditions :
-- Using tables   :FLOWLINE_SUB_WELL_CONN
--
-- Using functions:
--                  ec_well_attribute.flowline_1_id
--                  ec_well_attribute.flowline_2_id
--                  ec_flowline_sub_well_conn.prev_equal_daytime
--                  ec_flowline_sub_well_conn.end_date
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

PROCEDURE switchFlowlineForWell(
          p_well_id FLOWLINE_SUB_WELL_CONN.WELL_ID%TYPE,
          p_daytime FLOWLINE_SUB_WELL_CONN.DAYTIME%TYPE,
          p_indicator_no NUMBER,
          p_status NUMBER)
--</EC-DOC>
IS

 lv2_flowlineID VARCHAR2(32);
 ld_flwlConnPrevStartDate DATE;
 ld_flwlConnPrevEndDate DATE;

BEGIN

  IF p_indicator_no = 1 THEN
      lv2_flowlineID := ec_well_version.flowline_1_id(p_well_id, p_daytime, '<=');
  ELSIF p_indicator_no = 2 THEN
      lv2_flowlineID := ec_well_version.flowline_2_id(p_well_id, p_daytime, '<=');
  END IF;

    --Find start and end date for last flowline - sub well connection for flowline and well defined by p_well_id and lv2_flowlineID
  ld_flwlConnPrevStartDate := ec_flowline_sub_well_conn.prev_equal_daytime(lv2_flowlineID, p_well_id, p_daytime);
  ld_flwlConnPrevEndDate := ec_flowline_sub_well_conn.end_date(lv2_flowlineID, p_well_id, ld_flwlConnPrevStartDate);

  IF ld_flwlConnPrevStartDate IS NOT NULL AND ld_flwlConnPrevEndDate IS NULL AND p_status = 0 THEN

      UPDATE DV_FLOWLINE_WELL_CONN
      SET end_date = p_daytime
      WHERE object_id = lv2_flowlineID
      AND well_id = p_well_id
      AND daytime = ld_flwlConnPrevStartDate
      AND end_date IS NULL;

  ELSIF (ld_flwlConnPrevStartDate IS NULL OR ld_flwlConnPrevEndDate < p_daytime) AND p_status = 1 THEN

      --Create new connection
      INSERT INTO DV_FLOWLINE_WELL_CONN(
        object_id,
        well_id,
        daytime)
      VALUES(
        lv2_flowlineID,
        p_well_id,
        p_daytime);

  END IF;

END switchFlowlineForWell;

END EcDp_Flowline_Sub_Well_Conn;