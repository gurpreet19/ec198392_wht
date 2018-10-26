CREATE OR REPLACE PACKAGE BODY EcDp_Strm_AGA IS
/******************************************************************************
** Package        :  EcDp_Strm_AGA, body part
**
** $Revision: 1.4 $
**
** Purpose        :  This package is responsible for retrieving last available
**                   meter_run and orifice_plate given stream_id and daytime
**                   for a AGA streams
**
** Documentation  :  www.energy-components.com
**
** Created  : 03.12.2004 TAIPUTOH
**
** Modification history:
**
** Version  Date         Whom           Change description:
** -------  ------       -----          -------------------------------------------
**          28.10.2004   TAIPUTOH       First version
**          18.11.2004   ROV            Tracker #1797,
**                                      Updated body and header as they were swapped
**                                      Added missing descriptions and standard headings
********************************************************************/

  CURSOR c_strm_aga_conn (cp_object_id stream.object_id%TYPE, cp_daytime DATE) IS
  SELECT *
  FROM strm_aga_connection sac
  WHERE sac.object_id = cp_object_id
  AND sac.daytime = (SELECT MAX(sacm.daytime)
                     FROM strm_aga_connection sacm
                     WHERE sacm.object_id = sac.object_id
                     AND sacm.daytime <= cp_daytime);

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getMeterRun
-- Description    : Returns last available meter run for the given stream
--                  on or prior to input daytime
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration  :
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

FUNCTION getMeterRun(p_object_id stream.object_id%TYPE,
                     p_daytime DATE,
                     p_event_type varchar2)
RETURN VARCHAR2
--</EC-DOC>
IS

  ln_retval VARCHAR2(32);

BEGIN

   ln_retval:=NULL;

 --check against override value
  ln_retval := ec_strm_event.meter_run_override(p_object_id,p_event_type,p_daytime);

  IF ln_retval IS NULL THEN
   FOR mycur in c_strm_aga_conn(p_object_id, p_daytime) LOOP
      ln_retval := mycur.meter_run_id;
   END loop;
  END IF;

   RETURN ln_retval;

END getMeterRun;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getOrificePlate
-- Description    : Returns last available orifice plate for the given stream
--                  on or prior to input daytime
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration  :
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getOrificePlate(p_object_id stream.object_id%TYPE,
                         p_daytime DATE,
                         p_event_type varchar2)
RETURN VARCHAR2
--</EC-DOC>
IS

  ln_retval VARCHAR2(32);

BEGIN

  ln_retval:=null;

  --check against override value
  ln_retval := ec_strm_event.orifice_plate_override(p_object_id,p_event_type,p_daytime);

  IF ln_retval IS NULL THEN
    FOR mycur IN c_strm_aga_conn(p_object_id, p_daytime) LOOP
      ln_retval := mycur.orifice_plate_id;
    END loop;
  END IF;

  RETURN ln_retval;

END getOrificePlate;

END EcDp_Strm_AGA;