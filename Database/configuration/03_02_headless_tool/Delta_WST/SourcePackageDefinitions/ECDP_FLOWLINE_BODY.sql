CREATE OR REPLACE PACKAGE BODY Ecdp_Flowline IS

/****************************************************************
** Package        :  EcDp_Flowline, header part
**
** $Revision: 1.19 $
**
** Purpose        :  Finds flowline properties.
**
** Documentation  :  www.energy-components.com
**
** Created  : 17.01.2000  Carl-Fredrik S?sen
**
** Modification history:
**
** Version  Date      Whom     Change description:
** -------  --------  -----    --------------------------------------
** 1.0      17.01.00  CFS      Initial version
** 3.0      09.03.00  DN       Bug fix: parameter p_attribute_type was not used!
** 3.1      21.07.00  TeJ      Added three functions for finding field for flowline
** 3.2      04.08.00  MAO      Added function getFlwlEquipmentCode
** 3.3      29.08.00  DN       Added function calcFlowlineTypeFracDay
** 3.4      14.10.00  TeJ      Bug fix: Fixed bug in cursor cur_fieldForWell (function findField)
** 3.5      27.03.01  KEJ      Documented functions and procedures.
** 3.7      05.09.01  FBa      Added function getFlowlineType.
** 3.8      10.08.04  Toha     Replaced sysnam + facility + flowline_no to flowline.object_id. Made changes as necessary.
** 3.9      19.08.04  Toha     Replaced reference to equipment_type with class_name.
**          07.10.04  DN       TI 1656: Added column type declaration to the local variables that holds attribute tezt return values.
**          03.12.04  DN       TI 1823: Removed dummy package constructor.
**          24.05.05  kaurrnar Changed FLWL_ATTRIBUTE to FLWL_VERSION
**          28-02-05  Darren   Change calcFlowlineTypeFracDay ln_current_type := ch_rec.flowline_type;
**          04-03-05  kaurrnar Removed findField function
**          07.03.05  Toha     TI 1965: removed getFieldFromWebo, getFieldFromNode
**          17.08.05  Nazli    TI 1402: added calcPflwUptime, calcIflwUptime
**          24.08.05  Nazli    TI 1402: added getPflwOnStreamHrs and getIflwOnStreamHrs function
**          01.09.05  Removed  getPflwOnStreamHrs and getIflwOnStreamHrs based on 1402
**          31.12.08  sharawan ECPD-10416:Replaced all references to EcDp_Type.pb_comp_number%TYPE with NUMBER in functions calcPflwUptime, calcIflwUptime.
**          24.06.09  leongsei ECPD-11314: Modified function calcPflwUptime, calcIflwUptime
*****************************************************************/

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : calcFlowlineTypeFracDay                                                        --
-- Description    : Calculates how long a flowline was a specific type during a production day.    --
--                  Returns a fraction [0;1]. Null if no configuration at all match requested type.--
-- Preconditions  : Changes is configured with FLOWLINE_TYPE in table flwl_version.              --
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : flwl_version                                                                 --
--                                                                                                 --
-- Using functions: EcDp_flowline_Attribute.FLOWLINE_TYPE,                                         --
--                  ec_flwl_version....                                               --
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------

FUNCTION calcFlowlineTypeFracDay(
       p_object_id flowline.object_id%TYPE,
       p_daytime     DATE,
       p_flwl_type   VARCHAR2)

RETURN NUMBER
--<EC-DOC>
IS

CURSOR c_changes IS
SELECT FLOWLINE_TYPE, DAYTIME
FROM FLWL_VERSION
WHERE object_id = p_object_id
AND daytime >= p_daytime
AND daytime < p_daytime + 1
ORDER BY daytime;

ln_current_type VARCHAR2(32);
ld_last_change DATE;
ln_day_frac NUMBER;
ln_ret_val Ecdp_Type.pb_comp_number%TYPE;

BEGIN

   -- Get current configuration at end of day (midnight).

   ln_current_type := Ec_Flwl_version.FLOWLINE_TYPE(p_object_id,
              p_daytime + 1,
                                                       '<=');
   IF ln_current_type IS NOT NULL THEN

      -- Get current configuration at beginning of day (midnight).
      ln_current_type := Ec_Flwl_version.FLOWLINE_TYPE(p_object_id,
              p_daytime,
              '<=');
      ld_last_change := p_daytime;

      FOR ch_rec IN c_changes LOOP

         IF ln_current_type = p_flwl_type THEN

            ln_day_frac := NVL(ln_day_frac,0) + (ch_rec.daytime - ld_last_change);

         END IF;

         --ln_current_type := ch_rec.attribute_text;
         ln_current_type := ch_rec.flowline_type;
         ld_last_change := ch_rec.daytime;

      END LOOP;

      IF ld_last_change = p_daytime THEN -- No changes during day

         IF ln_current_type = p_flwl_type THEN

            ln_day_frac := 1;

         END IF;

      ELSE -- deal with last period until midnight

         IF ln_current_type = p_flwl_type THEN

            ln_day_frac := NVL(ln_day_frac,0) + (p_daytime + 1 - ld_last_change);

         END IF;

      END IF;

      ln_ret_val := ln_day_frac;

   END  IF;

   RETURN ln_ret_val;

END calcFlowlineTypeFracDay;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getFlwlEquipmentCode                                                           --
-- Description    : returns a string containing equipment_code connected to given                  --
--                  flowline/time of type given as input.                                          --
--                                                                                                 --
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : EQUIPMENT_FLWL_CONN                                                            --
--                                                                                                 --
-- Using functions:                                                                                --
--                                                                                                 --
--                                                                                                 --
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------

FUNCTION getFlwlEquipmentId(
   p_object_id flowline.object_id%TYPE,
   p_daytime        DATE,
   p_class_name VARCHAR2,
   p_equipment_seq_no NUMBER)

RETURN VARCHAR2
--<EC-DOC>
IS
   lv_object_id VARCHAR2(32);
   ln_count NUMBER := 1;

   CURSOR eqpm_cursor IS
  SELECT e.object_id
  FROM EQUIPMENT_FLWL_CONN a, equipment e
  WHERE FLOWLINE_ID = p_object_id
  AND e.class_name = p_class_name
  AND e.object_id = a.object_id
  AND DAYTIME = (
    SELECT MAX(b.DAYTIME)
    FROM EQUIPMENT_FLWL_CONN b
    WHERE b.object_id = a.object_id
    AND b.flowline_id = a.flowline_id
    AND b.DAYTIME <= p_daytime
    AND NVL(b.end_date, p_daytime + 1) > p_daytime)
  ORDER BY a.CREATED_DATE;

BEGIN

   lv_object_id := NULL;

   FOR eqpm_rec IN eqpm_cursor LOOP

      IF ln_count = p_equipment_seq_no THEN
          lv_object_id := eqpm_rec.object_id;
          ln_count := ln_count + 1;
        ELSE
          ln_count := ln_count + 1;
        END IF;

   END LOOP;

   RETURN lv_object_id;

END getFlwlEquipmentId;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getFlowlineType                                                           --
-- Description    : Returns the flowline type at a given date
--                                                                                                 --
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : FLWL_VERSION                                                            --
--                                                                                                 --
-- Using functions:                                                                                --
--                                                                                                 --
--                                                                                                 --
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------

FUNCTION getFlowlineType(
   p_object_id flowline.object_id%TYPE,
   p_daytime        DATE
)
RETURN VARCHAR2
--<EC-DOC>
IS

lv2_flowline_type VARCHAR2(300);

BEGIN

   lv2_flowline_type := Ec_Flwl_version.flowline_type(p_object_id, p_daytime,'<=');
   RETURN lv2_flowline_type;

END getFlowlineType;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : calcPflwUptime                                                           --
-- Description    : Returns the production flowline uptime at a given date
--                                                                                                 --
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :                                                     --
--                                                                                                 --
-- Using functions:                                                                                --
--                                                                                                 --
--                                                                                                 --
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
FUNCTION calcPflwUptime(
  p_object_id flowline.object_id%TYPE,
  p_daytime DATE)
RETURN NUMBER IS

BEGIN

  RETURN ec_pflw_day_status.on_stream_hrs(p_object_id, p_daytime);

END calcPflwUptime;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : calcIflwUptime                                                           --
-- Description    : Returns the injection flowline uptime at a given date
--                                                                                                 --
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :                                                     --
--                                                                                                 --
-- Using functions:                                                                                --
--                                                                                                 --
--                                                                                                 --
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
FUNCTION calcIflwUptime(
   p_object_id flowline.object_id%TYPE,
   p_daytime DATE)
RETURN NUMBER IS

BEGIN

  RETURN ec_iflw_day_status.on_stream_hrs(p_object_id,
                                          ec_flwl_version.flowline_type(p_object_id,p_daytime,'<='),
                                          p_daytime);

END calcIflwUptime;


END;