CREATE OR REPLACE PACKAGE BODY EcBp_Well_Choke IS

/****************************************************************
** Package        :  EcBp_Well_Choke, body part
**
** $Revision: 1.3 $
**
** Purpose        :  Provides choke conversion functions
**
** Documentation  :  www.energy-components.com
**
** Created  : 24.01.2000  Carl-Fredrik Sørensen
**
** Modification history:
**
** Date     Whom  Change description:
** ------   ----- --------------------------------------
** 24.01.00  CFS   Initial version
** 17.04.01  KEJ   Documented functions and procedures.
** 11.08.2004 mazrina    removed sysnam and update as necessary
** 05.10.07  LAU   ECPD-6519: Adapted to new table structure.
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : convertToMilliMeter                                                          --
-- Description    : Converts a choke opening in natural units to millimeter                      --
--                  (linear interpolation based on table lookup)                                 --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : WELL_VERSION                                                                 --
--                  CHOKE_CONVERSION                                                             --
--                                                                                               --
-- Using functions: ECBP_MATHLIB.INTERPOLATELINEAR                                               --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      : CHOKE_PROPERTIES,CHOK_CONVERSION_POINT,                                      --
--                  WELL_CHOKE_ASSIGNMENT must be given license spesific values.                 --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION convertToMilliMeter(
   p_object_id well.object_id%TYPE,
   p_daytime       DATE,
   p_choke_natural NUMBER)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR choke_code_cur(cp_object_id VARCHAR2, cp_daytime DATE) IS
SELECT choke_id, choke_uom
FROM   well_version
WHERE  object_id = cp_object_id
AND    daytime  = (
       SELECT Max(daytime)
       FROM   well_version
       WHERE object_id = cp_object_id
       AND   daytime <= cp_daytime);

CURSOR choke_mm_conv_cursor(cp_choke_id VARCHAR2, cp_source_unit VARCHAR2, cp_daytime DATE) IS
SELECT SOURCE_CHOKE_SIZE choke_size, TARGET_CHOKE_SIZE choke_mm
FROM   choke_conversion
WHERE object_id = cp_choke_id
AND source_unit = cp_source_unit
AND target_unit = 'MM'
AND daytime = (
    SELECT MAX(daytime)
    from choke_conversion
    WHERE object_id = cp_choke_id
    AND source_unit = cp_source_unit
    AND target_unit = 'MM'
    and daytime <= cp_daytime)
ORDER BY SOURCE_CHOKE_SIZE DESC;

ln_choke_curve_point_x1     NUMBER;
ln_choke_curve_point_y1     NUMBER;
ln_choke_curve_point_x2     NUMBER;
ln_choke_curve_point_y2     NUMBER;
ln_prev_choke_curve_point_x NUMBER;
ln_prev_choke_curve_point_y NUMBER;
ln_choke_size_mm            NUMBER;

lv2_choke_id              VARCHAR2(32);
lv2_choke_uom             VARCHAR2(32);
BEGIN

   -- determine which choke type in use for this well/flowline
   FOR code_cur IN choke_code_cur(p_object_id, p_daytime) LOOP

      lv2_choke_id := code_cur.choke_id;
      lv2_choke_uom := code_cur.choke_uom;

   END LOOP;


   IF lv2_choke_uom = 'MM' THEN

      RETURN p_choke_natural; -- already in mm

   END IF;

   ln_prev_choke_curve_point_x := NULL;
   ln_prev_choke_curve_point_y := NULL;

   FOR choke_curv_rec IN choke_mm_conv_cursor(lv2_choke_id, lv2_choke_uom, p_daytime) LOOP

      IF (choke_curv_rec.choke_size = p_choke_natural) THEN

         RETURN choke_curv_rec.choke_mm; -- got it

      ELSIF (choke_curv_rec.choke_size > p_choke_natural) THEN

         ln_choke_curve_point_y2 := choke_curv_rec.choke_mm;
         ln_choke_curve_point_x2 := choke_curv_rec.choke_size;

         ln_choke_curve_point_y1 := ln_prev_choke_curve_point_y;
         ln_choke_curve_point_x1 := ln_prev_choke_curve_point_x;

      ELSE -- ChokeCurvRec.choke_size < v_Choke_curve_x

         IF ln_choke_curve_point_x2 IS NULL THEN

            ln_choke_curve_point_y2 := choke_curv_rec.choke_mm;
            ln_choke_curve_point_x2 := choke_curv_rec.choke_size;

         ELSE
            ln_choke_curve_point_y1 := choke_curv_rec.choke_mm;
            ln_choke_curve_point_x1 := choke_curv_rec.choke_size;

            EXIT; -- got two points

         END IF;

      END IF;

      ln_prev_choke_curve_point_y := choke_curv_rec.choke_mm;
      ln_prev_choke_curve_point_x := choke_curv_rec.choke_size;

   END LOOP;

   IF ((ln_choke_curve_point_x2 IS NULL) AND
       (ln_choke_curve_point_x1 IS NULL)) THEN

      RETURN NULL;

   ELSIF ((ln_choke_curve_point_x2 IS NOT NULL) AND
          (ln_choke_curve_point_x1 IS NOT NULL)) THEN

      ln_choke_size_mm := EcBp_Mathlib.interpolateLinear(
                              p_choke_natural,
                              ln_choke_curve_point_x1,
                              ln_choke_curve_point_x2,
                              ln_choke_curve_point_y1,
                              ln_choke_curve_point_y2);

      IF (ln_choke_size_mm < 0) THEN

         ln_choke_size_mm := 0;

      END IF;

      RETURN ln_choke_size_mm;

   ELSE

      RETURN  Nvl(ln_choke_curve_point_y2,ln_choke_curve_point_y1);

   END IF;

   RETURN NULL; -- nothing found

END convertToMilliMeter;

END EcBp_Well_Choke;