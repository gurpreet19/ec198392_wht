CREATE OR REPLACE PACKAGE BODY EcDp_Curve IS

/****************************************************************
** Package        :  EcDp_Curve, body part
**
** $Revision: 1.35 $
**
** Purpose        :  Provide basic functions on curves
**
** Documentation  :  www.energy-components.com
**
** Created  : 01.05.2000  Arild Vervik
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
** 3.1      31.05.00 AV    Added new functions getDefaultAxisLabel
**                  and getDefaultAxisUnit
** 4.1      22.06.00 AV    Added support for Polynomial curves of order 2
** 4.1.     14.07.00 AV    Added function calculateFormula
** 4.1      22.09.00 CFS   Moved all constant functions to EcDp_Curve_Constant
**                 Changed functions to procedures where no functional
**                         logic is performed.
** 4.2      27.09.00 PGI   Inserted exception-handling removed from version 4.1. in function
**                         DeleteCurve, DeletePoint,DeleteSegment,InsertCurve,
**                         InsertPoint, InsertSegment, UpdateCurve, UpdatePoint  and UpdateSegment
** 4.3.     12.12.00 PGI   Added function getPointNo
**                         In createLinearRepresentation - Before processing delete curve segments in any cases
**                  Corrected timeconsuming bug in createLinearRepresentation:
**                         Inserted missing cs.curve_id = p_curve_id in UPDATE expressions.
** 4.4      29.03.01 KEJ   Documented functions and procedures.
** 4.5      11.12.01 SVN   Added curveFit3Point procedure.
**                         Bug fix function calculateFormula. p_curve_constant_a in denominator in 2nd degree polynom solution.
**
**          08.01.04 BIH   Added procedure curveFitLinearLS
**          08.01.04 BIH   Added procedure curveFitPoly2LS
**          05.03.04 BIH   Moved curveFitLinearLS and curveFitPoly2LS to EcBp_Mathlib
**                         ! Cleared package !
**                         Added procedure curveFit and function getYfromX that supports new database model
**                         (from EnergyX 7.3)
**          05.04.04 BIH   Fixed bug where the wrong y was selected for inverse polynomial curves with c2<0 (#994)
**          16.04.04 BIH   Curve point formula type extrapolates values beyond the first and last points (tracker 989)
**          09.11.2005 AV  Changed references to WriteTempText from EcDp_genClasscode to EcDp_DynSQL (code cleanup)
**          24.04.2006 DN  Removed debug logging in moveCurvePoints procedure.
**          24.08.2006 MOT Tracker #1597. Adding getRatioOrWcfromX to get GOR, WR etc from curve
**          31.05.2007 Rajarsar ECPD-5469. Modified getRatioOrWcfromX to get cgr,wgr,watercut_pct and gor from performance curve level.
**          03.10.2007 KAURRJES ECPD-6112: Performance Curve functionality "CURVE_POINT" should tolerate single point
**          10.04.2009 oonnnng  ECPD-6067: Change from anydata.ConvertVarchar2 to anydata.ConvertNumber in moveCurvePoints, moveCurve, and addCurvePoint function.
**          04.11.2009 aliassit ECPD-12484: Modify moveCurve to handle concave coeff values correctly
**          07.01.2010 farhaann ECPD-13409: Modified getYfromX, INV_POLYNOM_2 and curve_parameter value outside curve (ln_root<0) should return "0" instead of "NULL"
**          10.03.2010 musaamah ECPD-13372: Added a new ELSIF block in function getYfromX to calculate a new formula_type POLYNOM_3.
**					    					Modified function curveFit to raise a pop-up error if formula_type is POLYNOM_3.
**		    20.05.2010 Toha ECPD-13372: Modified function curveFit to calculate curve fit for formula_type POLYNOM_3.
**	    27.08.2010 madondin ECPD-13812: Modified function getYfromX and curveFit for conversion purpose in well performance curve graph
**	    31.08.2010 madondin	ECPD-13812: Added 1 new function getMeasurementType to get x and y measurement type
**          15.08.2011 rajarsar ECPD-17602:Added parameter phase for getPreviousPerfCurve
**			21.09.11 madondin ECPD:18467 added new function getYfromXGraph for rendering graph with conversion from dbunit to screenunit
**							  and revert the getYfromX to use the old one which without conversion in order to get correct Volume  in Daily well
**			18.04.2012 limmmchu ECPD-20533: Modified error message ORA number in procedure moveCurvePoints, moveCurve and addCurvePoint
**			10.09.2012 limmmchu ECPD-21803: Modified getYfromXGraph to pass correct value for draw graph.
**			11.07.2013 limmmchu ECPD-24111: Modified moveCurve to change the formula of INV_POLYNOM_2.
**			09.11.2016 shindani ECPD-37700: Modified curveFit procedure to add support when screen unit is different than DB unit.
***         23.02.2017 choooshu ECPD-32359: Modified curveFit, moveCurve, getYfromX and getYfromXGraph to support POLYNOM_4.
*****************************************************************/

---------------------------------------------------------------------------------------------------
-- Function       : getPreviousPerfCurve                                                         --
-- Description    : Returns the previous performance curve for the curve taken as in paramterer  --
--          with the same curve paramters                         --
--                                                                                               --
-- Preconditions  :                                        --
-- Postconditions :                                        --
--                                                                                               --
-- Using tables   : PERFORMANCE_CURVE                                                            --
--                                                                                               --
-- Using functions:                                        --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                        --
--                                                                                               --
-- Behaviour      :                                        --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getPreviousPerfCurve(p_perf_curve_id NUMBER,  p_phase VARCHAR2 DEFAULT NULL) RETURN NUMBER
--</EC-DOC>
  IS
    lv2_curve_object_id PERFORMANCE_CURVE.CURVE_OBJECT_ID%TYPE;
    ln_perf_curve_id NUMBER := NULL;
    CURSOR c_compute IS
      SELECT *
      FROM performance_curve
       WHERE (curve_object_id,curve_purpose,plane_intersect_code,phase) in (select pc.curve_object_id,pc.curve_purpose,pc.plane_intersect_code,phase from performance_curve pc where p_perf_curve_id = pc.perf_curve_id and nvl(p_phase,'OIL') = pc.phase )
      AND daytime < (select daytime from performance_curve pc2 where p_perf_curve_id = pc2.perf_curve_id and nvl(p_phase,'OIL') = pc2.phase)
      ORDER BY daytime DESC;

  BEGIN
    FOR cur_rec IN c_compute LOOP
      ln_perf_curve_id := cur_rec.perf_curve_id;
      EXIT;
    END LOOP;

  RETURN ln_perf_curve_id;
END getPreviousPerfCurve;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : curveFit                                                                     --
-- Description    : Calculates optimal coefficients for the given curve based on points and      --
--                  formula type.                                                                --
--                                                                                               --
-- Preconditions  : The curve points must be entered before calling this procedure               --
-- Postconditions : The C0, C1, C2, Y_VALID_FROM and Y_VALID_TO fields are updated with          --
--                  "optimal" values                                                             --
--                                                                                               --
-- Using tables   : CURVE                                                                        --
--                  CURVE_POINT                                                                  --
--                                                                                               --
-- Using functions: EcBp_Mathlib.curveFitLinearLS                                                --
--                  EcBp_Mathlib.curveFitPoly2LS                                                 --
--                                                                                               --
-- Configuration                                                                                 --
-- required       : The formula type and points must already be set up                           --
--                                                                                               --
-- Behaviour      : Uses least squares to calculate optimal coefficients for a curve of the type --
--                  given by the FORMULA_TYPE column and store them in the CURVE table.          --
--                  If there are too few and/or invalid points, an exception is raised.          --
--                                                                                               --
---------------------------------------------------------------------------------------------------
PROCEDURE curveFit(p_curve_id NUMBER)
--</EC-DOC>
IS
   lv2_formula_type curve.formula_type%TYPE;
   ln_c0 NUMBER:=0;
   ln_c1 NUMBER:=0;
   ln_c2 NUMBER:=0;
   ln_c3 NUMBER:=0;
   ln_c4 NUMBER:=0;
   err NUMBER:=-1;   -- -1:unknown formula type 0:ok >0:least squares failed
   points EcBp_Mathlib.PointCursor;
   n_lock_columns        EcDp_Month_lock.column_list;
   lv2_dbunit_x          VARCHAR2(32);
   lv2_screenunit_x      VARCHAR2(32);
   lv2_dbunit_y          VARCHAR2(32);
   lv2_screenunit_y      VARCHAR2(32);

BEGIN

   --to get dbunit and screenunit for x axis
   lv2_dbunit_x:=ecdp_unit.GetUnitFromLogical(ecdp_curve.getMeasurementType(p_curve_id,'X'));
   lv2_screenunit_x:=ecdp_unit.GetViewUnitFromLogical(ecdp_curve.getMeasurementType(p_curve_id,'X'));

   --to get dbunit and screenunit for y axis
   lv2_dbunit_y:=ecdp_unit.GetUnitFromLogical(ecdp_curve.getMeasurementType(p_curve_id,'Y'));
   lv2_screenunit_y:=ecdp_unit.GetViewUnitFromLogical(ecdp_curve.getMeasurementType(p_curve_id,'Y'));

   EcDp_month_lock.AddParameterToList(n_lock_columns,'CLASS_NAME','CURVE_POINT','STRING',NULL,NULL,NULL);
   EcDp_month_lock.AddParameterToList(n_lock_columns,'TABLE_NAME','CURVE_POINT','STRING',NULL,NULL,NULL);
   EcDp_month_lock.AddParameterToList(n_lock_columns,'CURVE_ID','CURVE_ID','NUMBER','Y',NULL,anydata.ConvertNumber(p_curve_id));

   EcDp_Performance_lock.CheckLockPerformanceCurve('UPDATING',n_lock_columns,n_lock_columns);

   lv2_formula_type:=ec_curve.formula_type(p_curve_id);

   IF lv2_formula_type=EcDp_Curve_Constant.LINEAR THEN
      -- Linear curve fit. Use x as x, y as y and find c0,c1
      OPEN points FOR select NVL(ecdp_unit.convertValue(x_value,lv2_dbunit_x,lv2_screenunit_x),x_value) as x,NVL(ecdp_unit.convertValue(y_value,lv2_dbunit_y,lv2_screenunit_y),y_value) as y from curve_point where curve_id=p_curve_id;
      EcBp_Mathlib.curveFitLinearLS(points,ln_c0,ln_c1,err);
   ELSIF lv2_formula_type=EcDp_Curve_Constant.POLYNOM_2 THEN
      -- Polynom 2 curve fit. Use x as x, y as y and find c0,c1,c2
      OPEN points FOR select NVL(ecdp_unit.convertValue(x_value,lv2_dbunit_x,lv2_screenunit_x),x_value) as x,NVL(ecdp_unit.convertValue(y_value,lv2_dbunit_y,lv2_screenunit_y),y_value) as y from curve_point where curve_id=p_curve_id;
      EcBp_Mathlib.curveFitPoly2LS(points,ln_c0,ln_c1,ln_c2,err);
   ELSIF lv2_formula_type=EcDp_Curve_Constant.INV_POLYNOM_2 THEN
      -- Inverse polynom 2 curve fit. Use y as x, x as y and find c0,c1,c2
      OPEN points FOR select NVL(ecdp_unit.convertValue(y_value,lv2_dbunit_y,lv2_screenunit_y),y_value) as x,NVL(ecdp_unit.convertValue(x_value,lv2_dbunit_x,lv2_screenunit_x),x_value) as y from curve_point where curve_id=p_curve_id;
      EcBp_Mathlib.curveFitPoly2LS(points,ln_c0,ln_c1,ln_c2,err);
   ELSIF lv2_formula_type=EcDp_Curve_Constant.POLYNOM_3 THEN
      -- Polynom 3 curve fit. Use x as x, y as y and find c0,c1,c2,c3
      OPEN points FOR select NVL(ecdp_unit.convertValue(x_value,lv2_dbunit_x,lv2_screenunit_x),x_value) as x,NVL(ecdp_unit.convertValue(y_value,lv2_dbunit_y,lv2_screenunit_y),y_value) as y from curve_point where curve_id=p_curve_id;
      EcBp_Mathlib.curveFitPoly3LS(points,ln_c0,ln_c1,ln_c2,ln_c3,err);
   ELSIF lv2_formula_type=EcDp_Curve_Constant.POLYNOM_4 THEN
      -- Polynom 4 curve fit. Use x as x, y as y and find c0,c1,c2,c3,c4
      OPEN points FOR select NVL(ecdp_unit.convertValue(x_value,lv2_dbunit_x,lv2_screenunit_x),x_value) as x,NVL(ecdp_unit.convertValue(y_value,lv2_dbunit_y,lv2_screenunit_y),y_value) as y from curve_point where curve_id=p_curve_id;
      EcBp_Mathlib.curveFitPoly4LS(points,ln_c0,ln_c1,ln_c2,ln_c3,ln_c4,err);
   END IF;


   -- Done finding values
   -- Check error conditions
   IF err<0 THEN
      RAISE_APPLICATION_ERROR(-20000,'Cannot perform curve fit for formula type '||lv2_formula_type||'.');
   ELSIF err=1 THEN
      RAISE_APPLICATION_ERROR(-20000,'Too few distinct data points, curve fit failed.');
   ELSIF err=2 THEN
      RAISE_APPLICATION_ERROR(-20000,'Invalid data, curve fit failed.');
   ELSIF err>0 THEN
      RAISE_APPLICATION_ERROR(-20000,'Curve fit failed, error code = '||err||'.');
   END IF;

   -- All is OK, update table
   update curve set
      c0=ln_c0,
      c1=ln_c1,
      c2=ln_c2,
      c3=ln_c3,
      c4=ln_c4
   where curve_id=p_curve_id;
END curveFit;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getYfromX                                                                    --
-- Description    : Calculates y from a given x based on formula type and coefficients/points    --
--                                                                                               --
-- Preconditions  : For formula types other than CURVE_POINT the coefficients must be entered    --
--                  or calculated (using curveFit) before calling this function.                 --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : CURVE                                                                        --
--                  CURVE_POINT                                                                  --
--                                                                                               --
-- Using functions: EcBp_MathLib.interpolateLinearBoundary                                       --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      : Calculates y from the given x based on the curve's FORMULA_TYPE:             --
--                    - CURVE_POINT:   Uses linear interpolation between the two points          --
--                                     that are "nearest" in x                                   --
--                    - LINEAR:        y = C1*x + C0                                             --
--                    - POLYNOM_2:     y = C2*x^2 + C1*x + C0                                    --
--                    - POLYNOM_3:     y = C3*x^3 + C2*x^2 + C1*x + C0                           --
--                    - POLYNOM_4:     y = C4*x^4 + C3*x^3 + C2*x^2 + C1*x + C0                  --
--                    - INV_POLYNOM_2: Solves x = C2*y^2 + C1*y + C0 for y using standard        --
--                                     2nd order equation solution techniques.                   --
--                                     If there are more than one valid solution then the        --
--                                     Y_VALID_FROM and Y_VALID_TO values are used to            --
--                                     determine which solution to use.                          --
--                  This function returns NULL if no valid value for y can be found.             --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getYfromX(p_curve_id NUMBER, p_x_value NUMBER) RETURN NUMBER
--</EC-DOC>
IS
   lr_curve curve%ROWTYPE;
   lv2_formula_type curve.formula_type%TYPE;
   ln_x1 NUMBER;
   ln_x2 NUMBER;
   ln_x3 NUMBER;
   ln_y1 NUMBER;
   ln_y2 NUMBER;
   ln_y3 NUMBER;
   ln_y  NUMBER;
   ln_root NUMBER;

   CURSOR c_first_lower_or_equal_x IS
      SELECT x_value,y_value
      FROM curve_point
      WHERE curve_id=p_curve_id
      AND x_value=
      (
         SELECT MAX(x_value)
         FROM curve_point
         WHERE curve_id=p_curve_id
         AND x_value<=p_x_value
      );
   CURSOR c_first_higher_or_equal_x IS
      SELECT x_value,y_value
      FROM curve_point
      WHERE curve_id=p_curve_id
      AND x_value=
      (
         SELECT MIN(x_value)
         FROM curve_point
         WHERE curve_id=p_curve_id
         AND x_value>=p_x_value
      );
   CURSOR c_first_lower_x(cp_refx NUMBER) IS
      SELECT x_value,y_value
      FROM curve_point
      WHERE curve_id=p_curve_id
      AND x_value=
      (
         SELECT MAX(x_value)
         FROM curve_point
         WHERE curve_id=p_curve_id
         AND x_value<cp_refx
      );
   CURSOR c_first_higher_x(cp_refx NUMBER) IS
      SELECT x_value,y_value
      FROM curve_point
      WHERE curve_id=p_curve_id
      AND x_value=
      (
         SELECT MIN(x_value)
         FROM curve_point
         WHERE curve_id=p_curve_id
         AND x_value>cp_refx
      );

BEGIN
   IF p_x_value IS NULL THEN
      RETURN NULL;
   END IF;
   lr_curve:=ec_curve.row_by_pk(p_curve_id);
   lv2_formula_type:=lr_curve.formula_type;
   IF lv2_formula_type=EcDp_Curve_Constant.LINEAR THEN
      -- Linear curve, use c0 and c1
      RETURN lr_curve.c0 + lr_curve.c1*p_x_value;
   ELSIF lv2_formula_type=EcDp_Curve_Constant.POLYNOM_2 THEN
      -- Polynom 2 curve, use c0, c1 and c2
      RETURN lr_curve.c0 + lr_curve.c1*p_x_value + lr_curve.c2*power(p_x_value,2);
   ELSIF lv2_formula_type=EcDp_Curve_Constant.POLYNOM_3 THEN
      -- Polynom 3 curve, use c0, c1, c2 and c3
      RETURN lr_curve.c0 + lr_curve.c1*p_x_value + lr_curve.c2*power(p_x_value,2) + lr_curve.c3*power(p_x_value,3);
   ELSIF lv2_formula_type=EcDp_Curve_Constant.POLYNOM_4 THEN
      -- Polynom 4 curve, use c0, c1, c2, c3 and c4
      RETURN lr_curve.c0 + lr_curve.c1*p_x_value + lr_curve.c2*power(p_x_value,2) + lr_curve.c3*power(p_x_value,3) + lr_curve.c4*power(p_x_value,4);
   ELSIF lv2_formula_type=EcDp_Curve_Constant.INV_POLYNOM_2 THEN
      IF lr_curve.c2=0 OR lr_curve.c2 IS NULL THEN
         -- Inverse linear curve, solve based on c0 and c1
         -- x=c1*y+c0 => y=(x-c0)/c1
         IF lr_curve.c1=0 THEN
            RETURN NULL;
         ELSE
            RETURN (p_x_value-lr_curve.c0)/lr_curve.c1;
         END IF;
      ELSE
         -- Inverse polynom 2 curve with c2!=0, solve root based on c0, c1 and c2
         -- x=c2*y^2+c1*y+c0 => c2*y^2+c1*y+(c0-x)=0
         -- y=(-c1+-sqrt(c1^2-4*(c0-x)*c2))/2*c2
         ln_root:=lr_curve.c1*lr_curve.c1-4*(lr_curve.c0-p_x_value)*lr_curve.c2;
            IF ln_root<0 THEN
            -- Curve input value outside curve range...
            RETURN 0;
         ELSIF ln_root IS NULL THEN
            -- No solution
            RETURN NULL;
         END IF;
         ln_root:=SQRT(ln_root);
         -- Find the two solutions
         -- Always let y1 be the largest one in case there are only one in Q1 (validatation interval -inf to +inf)
         IF lr_curve.c2>0 THEN
            ln_y1:=(-lr_curve.c1+ln_root)/(2*lr_curve.c2);
            ln_y2:=(-lr_curve.c1-ln_root)/(2*lr_curve.c2);
         ELSE
            ln_y1:=(-lr_curve.c1-ln_root)/(2*lr_curve.c2);
            ln_y2:=(-lr_curve.c1+ln_root)/(2*lr_curve.c2);
         END IF;
         -- Only return the solution that is within y_valid_from and y_valid_to
         IF ln_y1>=NVL(lr_curve.y_valid_from,ln_y1) AND ln_y1<=NVL(lr_curve.y_valid_to,ln_y1) THEN
            RETURN ln_y1;
         END IF;
         IF ln_y2>=NVL(lr_curve.y_valid_from,ln_y2) AND ln_y2<=NVL(lr_curve.y_valid_to,ln_y2) THEN
            RETURN ln_y2;
         END IF;
         RETURN NULL;
      END IF;
   ELSIF lv2_formula_type=EcDp_Curve_Constant.CURVE_POINT THEN
      -- Linear interpolation between points
      -- Find the nearest point with a lower x
      FOR r_point IN c_first_lower_or_equal_x LOOP
         ln_x1:=r_point.x_value;
         ln_y1:=r_point.y_value;
      END LOOP;
      -- Find the nearest point with a higher x
      FOR r_point IN c_first_higher_or_equal_x LOOP
         ln_x2:=r_point.x_value;
         ln_y2:=r_point.y_value;
      END LOOP;
      -- Extrapolate boundary cases --
      IF ln_x1 IS NULL AND ln_y1 IS NULL AND (ln_x2 IS NOT NULL OR ln_y2 IS NOT NULL) THEN
         -- p1 is null, so p2 is the point with the lowest x. Extrapolate towards zero.
         -- First find the second lowest x value
         FOR r_point IN c_first_higher_x(ln_x2) LOOP
            ln_x3:=r_point.x_value;
            ln_y3:=r_point.y_value;
         END LOOP;
         -- Extrapolate from p2 to p_x_value, remember that p2 has lower x than p3
         IF ln_x3 IS NOT NULL AND ln_y3 IS NOT NULL THEN -- assuming that there is a next higher point (or more than one point curve)
           ln_y:=EcBp_MathLib.interpolateLinear(p_x_value,ln_x2,ln_x3,ln_y2,ln_y3);
           RETURN ln_y;
         ELSE -- curve point contains only one point
           ln_y:=EcBp_MathLib.interpolateLinearBoundary(p_x_value,ln_x2,ln_y2,ln_x3,ln_y3);
           RETURN ln_y;
         END IF;

      ELSIF ln_x2 IS NULL AND ln_y2 IS NULL AND (ln_x1 IS NOT NULL OR ln_y1 IS NOT NULL) THEN
         -- p2 is null, so p1 is the point with the highest x. Extrapolate towards infinity.
         -- First find the second highest x value
         FOR r_point IN c_first_lower_x(ln_x1) LOOP
            ln_x3:=r_point.x_value;
            ln_y3:=r_point.y_value;
         END LOOP;
         -- Extrapolate from p1 to p_x_value, remember that p3 has lower x than p1
         IF ln_x3 IS NOT NULL AND ln_y3 IS NOT NULL THEN -- assuming that there is a next lower point (or more than one point curve)
           ln_y:=EcBp_MathLib.interpolateLinear(p_x_value,ln_x3,ln_x1,ln_y3,ln_y1);
           RETURN ln_y;
         ELSE -- curve point contains only one point
           ln_y:=EcBp_MathLib.interpolateLinearBoundary(p_x_value,ln_x3,ln_y3,ln_x1,ln_y1);
           RETURN ln_y;
         END IF;

      END IF;
      -- Calculate
      RETURN EcBp_MathLib.interpolateLinearBoundary(p_x_value,ln_x1,ln_y1,ln_x2,ln_y2);
   END IF;
   -- Seems to be an unknown formula type
   RETURN NULL;
END getYfromX;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getYfromXGraph                                                               --
-- Description    : This is only used by the client for rendering of graph purpose,              --
--                  to calculates y from a given x based on formula type and coefficients/points --
-- Preconditions  : For formula types other than CURVE_POINT the coefficients must be entered    --
--                  or calculated (using curveFit) before calling this function.                 --
-- Postconditions : The value return has been converted from db unit to view unit                --
--                                                                                               --
-- Using tables   : CURVE                                                                        --
--                  CURVE_POINT                                                                  --
--                                                                                               --
-- Using functions: EcBp_MathLib.interpolateLinearBoundary                                       --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      : Calculates y from the given x based on the curve's FORMULA_TYPE:             --
--                    - CURVE_POINT:   Uses linear interpolation between the two points          --
--                                     that are "nearest" in x                                   --
--                    - LINEAR:        y = C1*x + C0                                             --
--                    - POLYNOM_2:     y = C2*x^2 + C1*x + C0                                    --
--                    - POLYNOM_3:     y = C3*x^3 + C2*x^2 + C1*x + C0                           --
--                    - POLYNOM_4:     y = C4*x^4 + C3*x^3 + C2*x^2 + C1*x + C0                  --
--                    - INV_POLYNOM_2: Solves x = C2*y^2 + C1*y + C0 for y using standard        --
--                                     2nd order equation solution techniques.                   --
--                                     If there are more than one valid solution then the        --
--                                     Y_VALID_FROM and Y_VALID_TO values are used to            --
--                                     determine which solution to use.                          --
--                  This function returns NULL if no valid value for y can be found.             --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getYfromXGraph(p_curve_id NUMBER, p_x_value NUMBER) RETURN NUMBER
--</EC-DOC>
IS
   lr_curve curve%ROWTYPE;
   lv2_formula_type curve.formula_type%TYPE;
   ln_x1 NUMBER;
   ln_x2 NUMBER;
   ln_x3 NUMBER;
   ln_y1 NUMBER;
   ln_y2 NUMBER;
   ln_y3 NUMBER;
   ln_y  NUMBER;
   ln_root NUMBER;
   lv2_dbunit_x          VARCHAR2(32);
   lv2_screenunit_x      VARCHAR2(32);
   lv2_dbunit_y          VARCHAR2(32);
   lv2_screenunit_y      VARCHAR2(32);

   ln_c0 NUMBER:=0;
   ln_c1 NUMBER:=0;
   ln_c2 NUMBER:=0;
   ln_c3 NUMBER:=0;
   ln_c4 NUMBER:=0;
   points EcBp_Mathlib.PointCursor;
   err NUMBER:=-1;   -- -1:unknown formula type 0:ok >0:least squares failed

   CURSOR c_first_lower_or_equal_x(
   cp_dbunit_x     VARCHAR2,
   cp_screenunit_x VARCHAR2,
   cp_dbunit_y     VARCHAR2,
   cp_screenunit_y VARCHAR2
   )IS
      SELECT  NVL(ecdp_unit.convertValue(x_value,cp_dbunit_x,cp_screenunit_x),x_value) as x_value,
      ecdp_unit.convertValue(y_value,cp_dbunit_y,cp_screenunit_y) as y_value
      FROM curve_point
      WHERE curve_id=p_curve_id
      AND NVL(ecdp_unit.convertValue(x_value,cp_dbunit_x,cp_screenunit_x),x_value)=
      (
         SELECT MAX(NVL(ecdp_unit.convertValue(x_value,cp_dbunit_x,cp_screenunit_x),x_value))
         FROM curve_point
         WHERE curve_id=p_curve_id
         AND NVL(ecdp_unit.convertValue(x_value,cp_dbunit_x,cp_screenunit_x),x_value)<=p_x_value
      );
   CURSOR c_first_higher_or_equal_x(
   cp_dbunit_x     VARCHAR2,
   cp_screenunit_x VARCHAR2,
   cp_dbunit_y     VARCHAR2,
   cp_screenunit_y VARCHAR2
   )IS
      SELECT NVL(ecdp_unit.convertValue(x_value,cp_dbunit_x,cp_screenunit_x),x_value) as x_value,
      ecdp_unit.convertValue(y_value,cp_dbunit_y,cp_screenunit_y) as y_value
      FROM curve_point
      WHERE curve_id=p_curve_id
      AND NVL(ecdp_unit.convertValue(x_value,cp_dbunit_x,cp_screenunit_x),x_value)=
      (
         SELECT MIN(NVL(ecdp_unit.convertValue(x_value,cp_dbunit_x,cp_screenunit_x),x_value))
         FROM curve_point
         WHERE curve_id=p_curve_id
         AND NVL(ecdp_unit.convertValue(x_value,cp_dbunit_x,cp_screenunit_x),x_value)>=p_x_value
      );
   CURSOR c_first_lower_x(
   cp_dbunit_x     VARCHAR2,
   cp_screenunit_x VARCHAR2,
   cp_dbunit_y     VARCHAR2,
   cp_screenunit_y VARCHAR2,
   cp_refx         NUMBER) IS
      SELECT NVL(ecdp_unit.convertValue(x_value,cp_dbunit_x,cp_screenunit_x),x_value) as x_value,
      ecdp_unit.convertValue(y_value,cp_dbunit_y,cp_screenunit_y) as y_value
      FROM curve_point
      WHERE curve_id=p_curve_id
      AND NVL(ecdp_unit.convertValue(x_value,cp_dbunit_x,cp_screenunit_x),x_value)=
      (
         SELECT MAX(NVL(ecdp_unit.convertValue(x_value,cp_dbunit_x,cp_screenunit_x),x_value))
         FROM curve_point
         WHERE curve_id=p_curve_id
         AND NVL(ecdp_unit.convertValue(x_value,cp_dbunit_x,cp_screenunit_x),x_value)<cp_refx
      );
   CURSOR c_first_higher_x(
   cp_dbunit_x     VARCHAR2,
   cp_screenunit_x VARCHAR2,
   cp_dbunit_y     VARCHAR2,
   cp_screenunit_y VARCHAR2,
   cp_refx         NUMBER) IS
      SELECT NVL(ecdp_unit.convertValue(x_value,cp_dbunit_x,cp_screenunit_x),x_value) as x_value,
      ecdp_unit.convertValue(y_value,cp_dbunit_y,cp_screenunit_y) as y_value
      FROM curve_point
      WHERE curve_id=p_curve_id
      AND NVL(ecdp_unit.convertValue(x_value,cp_dbunit_x,cp_screenunit_x),x_value)=
      (
         SELECT MIN(NVL(ecdp_unit.convertValue(x_value,cp_dbunit_x,cp_screenunit_x),x_value))
         FROM curve_point
         WHERE curve_id=p_curve_id
         AND NVL(ecdp_unit.convertValue(x_value,cp_dbunit_x,cp_screenunit_x),x_value)>cp_refx
      );



BEGIN
   IF p_x_value IS NULL THEN
      RETURN NULL;
   END IF;


   --to get dbunit and screenunit for x axis
   lv2_dbunit_x:=ecdp_unit.GetUnitFromLogical(ecdp_curve.getMeasurementType(p_curve_id,'X'));
   lv2_screenunit_x:=ecdp_unit.GetViewUnitFromLogical(ecdp_curve.getMeasurementType(p_curve_id,'X'));

   --to get dbunit and screenunit for y axis
   lv2_dbunit_y:=ecdp_unit.GetUnitFromLogical(ecdp_curve.getMeasurementType(p_curve_id,'Y'));
   lv2_screenunit_y:=ecdp_unit.GetViewUnitFromLogical(ecdp_curve.getMeasurementType(p_curve_id,'Y'));

   lr_curve:=ec_curve.row_by_pk(p_curve_id);
   lv2_formula_type:=lr_curve.formula_type;
   IF lv2_formula_type=EcDp_Curve_Constant.LINEAR THEN
      -- Linear curve, use c0 and c1
	  OPEN points FOR select NVL(ecdp_unit.convertValue(x_value,lv2_dbunit_x,lv2_screenunit_x),x_value) as x,ecdp_unit.convertValue(y_value,lv2_dbunit_y,lv2_screenunit_y) as y from curve_point where curve_id=p_curve_id;
	  IF lr_curve.c0 IS NULL OR lr_curve.c1 IS NULL THEN
         EcBp_Mathlib.curveFitLinearLS(points,ln_c0,ln_c1,err);
	    ELSE
         ln_c0 := lr_curve.c0;
         ln_c1 := lr_curve.c1;
	    END IF;
      RETURN ln_c0 + ln_c1*p_x_value;

   ELSIF lv2_formula_type=EcDp_Curve_Constant.POLYNOM_2 THEN
      -- Polynom 2 curve, use c0, c1 and c2
	  OPEN points FOR select NVL(ecdp_unit.convertValue(x_value,lv2_dbunit_x,lv2_screenunit_x),x_value) as x,ecdp_unit.convertValue(y_value,lv2_dbunit_y,lv2_screenunit_y) as y from curve_point where curve_id=p_curve_id;
        IF lr_curve.c0 IS NULL OR lr_curve.c1 IS NULL OR lr_curve.c2 IS NULL THEN
         EcBp_Mathlib.curveFitPoly2LS(points,ln_c0,ln_c1,ln_c2,err);
	    ELSE
         ln_c0 := lr_curve.c0;
         ln_c1 := lr_curve.c1;
         ln_c2 := lr_curve.c2;
	    END IF;
      RETURN ln_c0 + ln_c1*p_x_value + ln_c2*power(p_x_value,2);

   ELSIF lv2_formula_type=EcDp_Curve_Constant.POLYNOM_3 THEN
      -- Polynom 3 curve, use c0, c1, c2 and c3
    OPEN points FOR select NVL(ecdp_unit.convertValue(x_value,lv2_dbunit_x,lv2_screenunit_x),x_value) as x,ecdp_unit.convertValue(y_value,lv2_dbunit_y,lv2_screenunit_y) as y from curve_point where curve_id=p_curve_id;
      IF lr_curve.c0 IS NULL OR lr_curve.c1 IS NULL OR lr_curve.c2 IS NULL OR lr_curve.c3 IS NULL THEN
         EcBp_Mathlib.curveFitPoly3LS(points,ln_c0,ln_c1,ln_c2,ln_c3,err);
	    ELSE
         ln_c0 := lr_curve.c0;
         ln_c1 := lr_curve.c1;
         ln_c2 := lr_curve.c2;
         ln_c3 := lr_curve.c3;
	    END IF;
      RETURN ln_c0 + ln_c1*p_x_value + ln_c2*power(p_x_value,2) + ln_c3*power(p_x_value,3);

   ELSIF lv2_formula_type=EcDp_Curve_Constant.POLYNOM_4 THEN
      -- Polynom 3 curve, use c0, c1, c2, c3 and c4
    OPEN points FOR select NVL(ecdp_unit.convertValue(x_value,lv2_dbunit_x,lv2_screenunit_x),x_value) as x,ecdp_unit.convertValue(y_value,lv2_dbunit_y,lv2_screenunit_y) as y from curve_point where curve_id=p_curve_id;
      IF lr_curve.c0 IS NULL OR lr_curve.c1 IS NULL OR lr_curve.c2 IS NULL OR lr_curve.c3 IS NULL OR lr_curve.c4 IS NULL THEN
         EcBp_Mathlib.curveFitPoly4LS(points,ln_c0,ln_c1,ln_c2,ln_c3,ln_c4,err);
        ELSE
         ln_c0 := lr_curve.c0;
         ln_c1 := lr_curve.c1;
         ln_c2 := lr_curve.c2;
         ln_c3 := lr_curve.c3;
         ln_c4 := lr_curve.c4;
        END IF;
      RETURN ln_c0 + ln_c1*p_x_value + ln_c2*power(p_x_value,2) + ln_c3*power(p_x_value,3) + ln_c4*power(p_x_value,4);

   ELSIF lv2_formula_type=EcDp_Curve_Constant.INV_POLYNOM_2 THEN
       OPEN points FOR select ecdp_unit.convertValue(y_value,lv2_dbunit_y,lv2_screenunit_y) as x,NVL(ecdp_unit.convertValue(x_value,lv2_dbunit_x,lv2_screenunit_x),x_value) as y from curve_point where curve_id=p_curve_id;
		IF lr_curve.c0 IS NULL OR lr_curve.c1 IS NULL OR lr_curve.c2 IS NULL THEN
          EcBp_Mathlib.curveFitPoly2LS(points,ln_c0,ln_c1,ln_c2,err);
	    ELSE
          ln_c0 := lr_curve.c0;
          ln_c1 := lr_curve.c1;
          ln_c2 := lr_curve.c2;
	    END IF;
      IF ln_c2=0 OR ln_c2 IS NULL THEN
         -- Inverse linear curve, solve based on c0 and c1
         -- x=c1*y+c0 => y=(x-c0)/c1
         IF ln_c1=0 THEN
            RETURN NULL;
         ELSE
            RETURN (p_x_value-ln_c0)/ln_c1;
         END IF;
      ELSE
         -- Inverse polynom 2 curve with c2!=0, solve root based on c0, c1 and c2
         -- x=c2*y^2+c1*y+c0 => c2*y^2+c1*y+(c0-x)=0
         -- y=(-c1+-sqrt(c1^2-4*(c0-x)*c2))/2*c2
         ln_root:=ln_c1*ln_c1-4*(ln_c0-p_x_value)*ln_c2;
            IF ln_root<0 THEN
            -- Curve input value outside curve range...
            RETURN 0;
         ELSIF ln_root IS NULL THEN
            -- No solution
            RETURN NULL;
         END IF;
         ln_root:=SQRT(ln_root);
         -- Find the two solutions
         -- Always let y1 be the largest one in case there are only one in Q1 (validatation interval -inf to +inf)
         IF ln_c2>0 THEN
            ln_y1:=(-ln_c1+ln_root)/(2*ln_c2);
            ln_y2:=(-ln_c1-ln_root)/(2*ln_c2);
         ELSE
            ln_y1:=(-ln_c1-ln_root)/(2*ln_c2);
            ln_y2:=(-ln_c1+ln_root)/(2*ln_c2);
         END IF;
         -- Only return the solution that is within y_valid_from and y_valid_to
         IF ln_y1>=NVL(lr_curve.y_valid_from,ln_y1) AND ln_y1<=NVL(lr_curve.y_valid_to,ln_y1) THEN
            RETURN ln_y1;
         END IF;
         IF ln_y2>=NVL(lr_curve.y_valid_from,ln_y2) AND ln_y2<=NVL(lr_curve.y_valid_to,ln_y2) THEN
            RETURN ln_y2;
         END IF;
         RETURN NULL;
      END IF;
   ELSIF lv2_formula_type=EcDp_Curve_Constant.CURVE_POINT THEN
      -- Linear interpolation between points
      -- Find the nearest point with a lower x
      FOR r_point IN c_first_lower_or_equal_x(lv2_dbunit_x,lv2_screenunit_x,lv2_dbunit_y,lv2_screenunit_y) LOOP
         ln_x1:=r_point.x_value;
         ln_y1:=r_point.y_value;
      END LOOP;
      -- Find the nearest point with a higher x
      FOR r_point IN c_first_higher_or_equal_x(lv2_dbunit_x,lv2_screenunit_x,lv2_dbunit_y,lv2_screenunit_y) LOOP
         ln_x2:=r_point.x_value;
         ln_y2:=r_point.y_value;
      END LOOP;
      -- Extrapolate boundary cases --
      IF ln_x1 IS NULL AND ln_y1 IS NULL AND (ln_x2 IS NOT NULL OR ln_y2 IS NOT NULL) THEN
         -- p1 is null, so p2 is the point with the lowest x. Extrapolate towards zero.
         -- First find the second lowest x value
         FOR r_point IN c_first_higher_x(lv2_dbunit_x,lv2_screenunit_x,lv2_dbunit_y,lv2_screenunit_y,ln_x2) LOOP
            ln_x3:=r_point.x_value;
            ln_y3:=r_point.y_value;
         END LOOP;
         -- Extrapolate from p2 to p_x_value, remember that p2 has lower x than p3
         IF ln_x3 IS NOT NULL AND ln_y3 IS NOT NULL THEN -- assuming that there is a next higher point (or more than one point curve)
           ln_y:=EcBp_MathLib.interpolateLinear(p_x_value,ln_x2,ln_x3,ln_y2,ln_y3);
           RETURN ln_y;
         ELSE -- curve point contains only one point
           ln_y:=EcBp_MathLib.interpolateLinearBoundary(p_x_value,ln_x2,ln_y2,ln_x3,ln_y3);
           RETURN ln_y;
         END IF;

      ELSIF ln_x2 IS NULL AND ln_y2 IS NULL AND (ln_x1 IS NOT NULL OR ln_y1 IS NOT NULL) THEN
         -- p2 is null, so p1 is the point with the highest x. Extrapolate towards infinity.
         -- First find the second highest x value
         FOR r_point IN c_first_lower_x(lv2_dbunit_x,lv2_screenunit_x,lv2_dbunit_y,lv2_screenunit_y,ln_x1) LOOP
            ln_x3:=r_point.x_value;
            ln_y3:=r_point.y_value;
         END LOOP;
         -- Extrapolate from p1 to p_x_value, remember that p3 has lower x than p1
         IF ln_x3 IS NOT NULL AND ln_y3 IS NOT NULL THEN -- assuming that there is a next lower point (or more than one point curve)
           ln_y:=EcBp_MathLib.interpolateLinear(p_x_value,ln_x3,ln_x1,ln_y3,ln_y1);
           RETURN ln_y;
         ELSE -- curve point contains only one point
           ln_y:=EcBp_MathLib.interpolateLinearBoundary(p_x_value,ln_x3,ln_y3,ln_x1,ln_y1);
           RETURN ln_y;
         END IF;

      END IF;

      -- Calculate
     RETURN EcBp_MathLib.interpolateLinearBoundary(p_x_value,ln_x1,ln_y1,ln_x2,ln_y2);
   END IF;
   -- Seems to be an unknown formula type
   RETURN NULL;
END getYfromXGraph;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : moveCurvePoints                                                              --
-- Description    : Regenerates the y values for a given curve by taking an x,y value         --
--          pair as input paramters                                                      --
--                                                                                               --
-- Preconditions  : The curve points and the curve coefisients must be defined for the given    --
--          curve                                     --
-- Postconditions : New X,Y pairs calculated for curve                       --
--                                                                                               --
-- Using tables   : CURVE                                                                        --
--                  CURVE_POINT                                                                  --
--                                                                                               --
-- Using functions:                                                                --
--                                                                                               --
-- Configuration                                                                                 --
-- required       : The formula type and points must already be set up                           --
--                                                                                               --
-- Behaviour      :                                        --
--                                                                                               --
---------------------------------------------------------------------------------------------------
PROCEDURE moveCurvePoints(p_curve_id NUMBER, p_x NUMBER, p_y NUMBER)
--</EC-DOC>
  IS
    lv2_formula_type curve.formula_type%TYPE;
    lv2_coeff curve.C0%TYPE;
    lv2_pic VARCHAR2(32);
    ln_y_old NUMBER:= getYfromX(p_curve_id, p_x);
    ln_ratio NUMBER:= p_y / ln_y_old;
    ln_new_y NUMBER;
    n_lock_columns        EcDp_Month_lock.column_list;

    CURSOR c_curve_points IS
      SELECT x_value,y_value
      FROM curve_point
      WHERE curve_id=p_curve_id;


  BEGIN

    EcDp_month_lock.AddParameterToList(n_lock_columns,'CLASS_NAME','CURVE_POINT','STRING',NULL,NULL,NULL);
    EcDp_month_lock.AddParameterToList(n_lock_columns,'TABLE_NAME','CURVE_POINT','STRING',NULL,NULL,NULL);
    EcDp_month_lock.AddParameterToList(n_lock_columns,'CURVE_ID','CURVE_ID','STRING','Y',NULL,anydata.ConvertNumber(p_curve_id));

    EcDp_Performance_lock.CheckLockPerformanceCurve('UPDATING',n_lock_columns,n_lock_columns);


    select FORMULA_TYPE into lv2_formula_type from CURVE where CURVE_ID = p_curve_id;
    select C1 into lv2_coeff from CURVE where CURVE_ID = p_curve_id;
    select PLANE_INTERSECT_CODE into lv2_pic from PERFORMANCE_CURVE pc where PERF_CURVE_ID in (select PERF_CURVE_ID from CURVE c where c.CURVE_ID = p_curve_id);
       IF p_x is NULL or p_x < 0 or p_y is NULL or p_y < 0 THEN
          RAISE_APPLICATION_ERROR(-20639,'Procedure requires in parameters to be non-NULL non negative number values');
        END IF;
       IF lv2_pic != 'NONE' THEN
          RAISE_APPLICATION_ERROR(-20513,'Procedure can not be performed on 3D performance curves. The plane_intersect_code of the performance curve is '||lv2_pic);
        END IF;
       IF lv2_coeff is NULL AND lv2_formula_type != 'CURVE_POINT'  THEN
          RAISE_APPLICATION_ERROR(-20514,'Procedure can not be performed on curves where C0 is '||lv2_coeff);
        END IF;

    FOR r_point IN c_curve_points LOOP

      ln_new_y:=r_point.y_value * ln_ratio;

      UPDATE curve_point
      SET y_value = ln_new_y
      WHERE curve_id = p_curve_id and x_value = r_point.x_value;

    END LOOP;
END moveCurvePoints;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : moveCurve                                                                 --
-- Description    : Regenerates the y curve coeffisients for a given curve, taking an x,y value  --
--          pair as input paramters                                                      --
--                                                                                               --
-- Preconditions  : The curve coeffisent must be defined for the given curve                     --
-- Postconditions : New curve coefficients calcualated for curve                                 --
--                                                                                               --
-- Using tables   : CURVE                                                                        --
--                  CURVE_POINT                                                                  --
--                                                                                               --
-- Using functions:                                                                --
--                                                                                               --
-- Configuration                                                                                 --
-- required       : The formula type and points must already be set up                           --
--                                                                                               --
-- Behaviour      :                                        --
--                                                                                               --
---------------------------------------------------------------------------------------------------
PROCEDURE moveCurve(p_curve_id NUMBER, p_x NUMBER, p_y NUMBER)
--</EC-DOC>
  IS
    lv2_formula_type curve.formula_type%TYPE;
    lv2_c0_old curve.C0%TYPE;
    lv2_c1_old curve.C1%TYPE;
    lv2_c2_old curve.C2%TYPE;
    lv2_c3_old curve.C3%TYPE;
    lv2_c4_old curve.C4%TYPE;
    lv2_c0 curve.C0%TYPE;
    lv2_c1 curve.C1%TYPE;
    lv2_c2 curve.C2%TYPE;
    lv2_c3 curve.C3%TYPE;
    lv2_c4 curve.C4%TYPE;
    lv2_pic VARCHAR2(32);
    ln_y_old NUMBER:= getYfromX(p_curve_id, p_x);
    ln_ratio NUMBER:= p_y / ln_y_old;
	ln_diff_rate NUMBER:= p_y - ln_y_old;
	ln_sum NUMBER:= p_y + ln_y_old;
    n_lock_columns        EcDp_Month_lock.column_list;

  BEGIN

    EcDp_month_lock.AddParameterToList(n_lock_columns,'CLASS_NAME','CURVE_POINT','STRING',NULL,NULL,NULL);
    EcDp_month_lock.AddParameterToList(n_lock_columns,'TABLE_NAME','CURVE_POINT','STRING',NULL,NULL,NULL);
    EcDp_month_lock.AddParameterToList(n_lock_columns,'CURVE_ID','CURVE_ID','STRING','Y',NULL,anydata.ConvertNumber(p_curve_id));

    EcDp_Performance_lock.CheckLockPerformanceCurve('UPDATING',n_lock_columns,n_lock_columns);


    select FORMULA_TYPE into lv2_formula_type from CURVE where CURVE_ID = p_curve_id;
    select C0 into lv2_c0_old from CURVE where CURVE_ID = p_curve_id;
    select C1 into lv2_c1_old from CURVE where CURVE_ID = p_curve_id;
    select C2 into lv2_c2_old from CURVE where CURVE_ID = p_curve_id;
    select C3 into lv2_c3_old from CURVE where CURVE_ID = p_curve_id;
    select C4 into lv2_c4_old from CURVE where CURVE_ID = p_curve_id;
    select PLANE_INTERSECT_CODE into lv2_pic from PERFORMANCE_CURVE pc where PERF_CURVE_ID in (select PERF_CURVE_ID from CURVE c where c.CURVE_ID = p_curve_id);
       IF p_x is NULL or p_x < 0 or p_y is NULL or p_y < 0 THEN
          RAISE_APPLICATION_ERROR(-20639,'Procedure requires in parameters to be non-NULL non negative number values');
        END IF;
       IF lv2_pic != 'NONE' THEN
          RAISE_APPLICATION_ERROR(-20513,'Procedure can not be performed on 3D performance curves. The plane_intersect_code of the performance curve is '||lv2_pic);
        END IF;
       IF lv2_formula_type = 'CURVE_POINT' THEN
          RAISE_APPLICATION_ERROR(-20514,'Procedure can not be performed on curves with formula type '||lv2_formula_type);
        END IF;
       IF lv2_c0_old is NULL THEN
          RAISE_APPLICATION_ERROR(-20514,'Procedure can not be performed on curves where C0 is '||lv2_c0);
        END IF;
      IF lv2_formula_type = 'LINEAR' THEN
          --handles concave function where coeff value c1 (2nd constant) < 0
        IF lv2_c1_old < 0 THEN --adjust c0, lock c1
          --the curve orientation is defined by the value of 2nd constant: negative value implies CONCAVE curve orientation
          --requires that c0 is adjusted while keeping c1 constant.
          lv2_c1:=lv2_c1_old;
          lv2_c0:=lv2_c0_old + ln_diff_rate;
        ELSIF lv2_c1_old > 0 THEN --adjust c0,c1
          lv2_c0:=lv2_c0_old * ln_ratio;
          lv2_c1:=lv2_c1_old * ln_ratio;
        END IF;
	    update CURVE set c0 = lv2_c0, c1 = lv2_c1 where CURVE_ID = P_CURVE_ID;

      ELSIF lv2_formula_type = 'INV_POLYNOM_2' THEN
        --handles concave function where coeff value c2 (2nd constant) < 0
        IF lv2_c2_old < 0 THEN --lock c1 and c2, adjust c0
          --the curve orientation is defined by the value of 2nd constant: negative value implies CONCAVE curve orientation
          --requires that c0 is adjusted while keeping c1 and c2 constants.
          lv2_c2:=lv2_c2_old;
          lv2_c1:=lv2_c1_old;
		  lv2_c0:= p_x - lv2_c2 * p_y **2 - lv2_c1 * p_y;
        ELSIF lv2_c2_old > 0 THEN -- adjust c1, c2
          lv2_c0:=lv2_c0_old;
          lv2_c1:=lv2_c1_old * (1/ln_ratio);
          lv2_c2:=lv2_c2_old * (1/ln_ratio)*(1/ln_ratio);
        END IF;
	   update CURVE set c0 = lv2_c0, c1 = lv2_c1, c2 = lv2_c2 where CURVE_ID = P_CURVE_ID;

      ELSIF lv2_formula_type = 'POLYNOM_2' THEN
        --handles concave function where coeff value c2 (2nd constant) < 0
        IF lv2_c2_old < 0 THEN --adjust c0, lock c1,c2
          --the curve orientation is defined by the value of 2nd constant: negative value implies CONCAVE curve orientation
          --requires that c0 is adjusted while keeping c1 and c2 constants.
          lv2_c2:=lv2_c2_old;
          lv2_c1:=lv2_c1_old;
          lv2_c0:=lv2_c0_old + ln_diff_rate;
        ELSIF lv2_c2_old > 0 THEN --adjust c0,c1,c2
      	  lv2_c0:=lv2_c0_old * ln_ratio;
      	  lv2_c1:=lv2_c1_old * ln_ratio;
      	  lv2_c2:=lv2_c2_old * ln_ratio;
        END IF;
	    update CURVE set c0 = lv2_c0, c1 = lv2_c1, c2 = lv2_c2 where CURVE_ID = P_CURVE_ID;
      ELSIF lv2_formula_type = 'POLYNOM_3' THEN
        --handles concave function where coeff value c3 (3rd constant) < 0
        IF lv2_c3_old < 0 THEN --adjust c0, lock c1,c2,c3
          --the curve orientation is defined by the value of 3rd constant: negative value implies CONCAVE curve orientation
          --requires that c0 is adjusted while keeping c1, c2 and c3 constants.
          lv2_c3:=lv2_c3_old;
          lv2_c2:=lv2_c2_old;
          lv2_c1:=lv2_c1_old;
          lv2_c0:=lv2_c0_old + ln_diff_rate;
        ELSIF lv2_c3_old > 0 THEN --adjust c0,c1,c2,c3
          lv2_c0:=lv2_c0_old * ln_ratio;
          lv2_c1:=lv2_c1_old * ln_ratio;
          lv2_c2:=lv2_c2_old * ln_ratio;
          lv2_c3:=lv2_c3_old * ln_ratio;
        END IF;
        update CURVE set c0 = lv2_c0, c1 = lv2_c1, c2 = lv2_c2, c3 = lv2_c3 where CURVE_ID = P_CURVE_ID;
      ELSIF lv2_formula_type = 'POLYNOM_4' THEN
        --handles concave function where coeff value c4 (4th constant) < 0
        IF lv2_c4_old < 0 THEN --adjust c0, lock c1,c2,c3,c4
          --the curve orientation is defined by the value of 3rd constant: negative value implies CONCAVE curve orientation
          --requires that c0 is adjusted while keeping c1, c2, c3 and c4 constants.
          lv2_c4:=lv2_c4_old;
          lv2_c3:=lv2_c3_old;
          lv2_c2:=lv2_c2_old;
          lv2_c1:=lv2_c1_old;
          lv2_c0:=lv2_c0_old + ln_diff_rate;
        ELSIF lv2_c4_old > 0 THEN --adjust c0,c1,c2,c3,c4
          lv2_c0:=lv2_c0_old * ln_ratio;
          lv2_c1:=lv2_c1_old * ln_ratio;
          lv2_c2:=lv2_c2_old * ln_ratio;
          lv2_c3:=lv2_c3_old * ln_ratio;
        END IF;
        update CURVE set c0 = lv2_c0, c1 = lv2_c1, c2 = lv2_c2, c3 = lv2_c3, c4 = lv2_c4 where CURVE_ID = P_CURVE_ID;
      END IF;
END moveCurve;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : addCurvePoint                                                                --
-- Description    : Insert the x and y values for a given curve                                  --
--                                                                                               --
-- Preconditions  :                                         --
--                                                 --
-- Postconditions : New X,Y pairs calculated for curve                       --
--                                                                                               --
-- Using tables   : CURVE                                                                        --
--                  CURVE_POINT                                                                  --
--                                                                                               --
-- Using functions:                                                                --
--                                                                                               --
-- Configuration                                                                                 --
-- required       : The formula type and points must already be set up                           --
--                                                                                               --
-- Behaviour      :                                        --
--                                                                                               --
---------------------------------------------------------------------------------------------------
PROCEDURE addCurvePoint(p_curve_id NUMBER, p_x NUMBER, p_y NUMBER, p_gor NUMBER, p_cgr NUMBER, p_wgr NUMBER, p_watercut_pct NUMBER)
--</EC-DOC>
  IS
    ln_count NUMBER;
    n_lock_columns        EcDp_Month_lock.column_list;


    CURSOR c_curve_points IS
      SELECT x_value,y_value
      FROM curve_point
      WHERE curve_id=p_curve_id;

  BEGIN

     EcDp_month_lock.AddParameterToList(n_lock_columns,'CLASS_NAME','CURVE_POINT','STRING',NULL,NULL,NULL);
     EcDp_month_lock.AddParameterToList(n_lock_columns,'TABLE_NAME','CURVE_POINT','STRING',NULL,NULL,NULL);
     EcDp_month_lock.AddParameterToList(n_lock_columns,'CURVE_ID','CURVE_ID','STRING','Y',NULL,anydata.ConvertNumber(p_curve_id));

     EcDp_Performance_lock.CheckLockPerformanceCurve('INSERTING',n_lock_columns,n_lock_columns);


       IF p_x is NULL or p_x < 0 or p_y is NULL or p_y < 0 THEN
          RAISE_APPLICATION_ERROR(-20639,'Procedure requires in parameters to be non-NULL non negative number values');
        END IF;
        select count(*) into ln_count from CURVE_POINT where CURVE_ID = p_curve_id and X_VALUE = p_x;
        IF ln_count < 1 THEN
          insert into CURVE_POINT (CURVE_ID, X_VALUE, Y_VALUE,GOR,CGR,WGR,WATERCUT_PCT) values (p_curve_id, p_x, p_y, p_gor, p_cgr, p_wgr, p_watercut_pct);
        ELSE
          update CURVE_POINT set Y_VALUE = p_y, GOR = p_gor, CGR = p_cgr, WGR = p_wgr, WATERCUT_PCT = p_watercut_pct where CURVE_ID = p_curve_id and X_VALUE = p_x;
        END IF;

END addCurvePoint;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getRatioOrWcfromX                                                        --
-- Description    : Calculates phase constant (GOR,WGR,CGR) and watercut from a given x based    --
--                  on formula type CURVE_POINT                                       --
--                                                                                               --
-- Preconditions  :                  --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : CURVE                                                                        --
--                  CURVE_POINT                                                                  --
--                                                                                               --
-- Using functions: EcBp_MathLib.interpolateLinearBoundary                                       --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      : Calculates y from the given x based on the curve's FORMULA_TYPE:             --
--                    - CURVE_POINT:   Uses linear interpolation between the two points          --
--                                     that are "nearest" in x                                   --
--                  This function returns NULL if no valid value for y can be found.             --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getRatioOrWcfromX(p_curve_id NUMBER, p_x_value NUMBER, p_constant_type VARCHAR2) RETURN NUMBER

--</EC-DOC>
IS
   lr_curve curve%ROWTYPE;
   ln_x1 NUMBER;
   ln_x2 NUMBER;
   ln_x3 NUMBER;
   ln_y1 NUMBER;
   ln_y2 NUMBER;
   ln_y3 NUMBER;
   ln_y  NUMBER;
   ln_root NUMBER;
   ln_curve_points NUMBER;
   ln_performance_curve NUMBER;
   ln_perf_curve_id NUMBER;

   CURSOR c_first_lower_or_equal_x IS
      SELECT x_value,gor,cgr,wgr,watercut_pct
      FROM curve_point
      WHERE curve_id=p_curve_id
      AND x_value=
      (
         SELECT MAX(x_value)
         FROM curve_point
         WHERE curve_id=p_curve_id
         AND x_value<=p_x_value
         AND (
              (p_constant_type = 'GOR' AND curve_point.gor IS NOT NULL) OR
              (p_constant_type = 'CGR' AND curve_point.cgr IS NOT NULL) OR
              (p_constant_type = 'WGR' AND curve_point.wgr IS NOT NULL) OR
              (p_constant_type = 'WATERCUT_PCT' AND curve_point.watercut_pct IS NOT NULL)
             )
      );
   CURSOR c_first_higher_or_equal_x IS
      SELECT x_value,gor,cgr,wgr,watercut_pct
      FROM curve_point
      WHERE curve_id=p_curve_id
      AND x_value=
      (
         SELECT MIN(x_value)
         FROM curve_point
         WHERE curve_id=p_curve_id
         AND x_value>=p_x_value
         AND (
              (p_constant_type = 'GOR' AND curve_point.gor IS NOT NULL) OR
              (p_constant_type = 'CGR' AND curve_point.cgr IS NOT NULL) OR
              (p_constant_type = 'WGR' AND curve_point.wgr IS NOT NULL) OR
              (p_constant_type = 'WATERCUT_PCT' AND curve_point.watercut_pct IS NOT NULL)
             )
      );
   CURSOR c_first_lower_x(cp_refx NUMBER) IS
      SELECT x_value,gor,cgr,wgr,watercut_pct
      FROM curve_point
      WHERE curve_id=p_curve_id
      AND x_value=
      (
         SELECT MAX(x_value)
         FROM curve_point
         WHERE curve_id=p_curve_id
         AND x_value<cp_refx
         AND (
              (p_constant_type = 'GOR' AND curve_point.gor IS NOT NULL) OR
              (p_constant_type = 'CGR' AND curve_point.cgr IS NOT NULL) OR
              (p_constant_type = 'WGR' AND curve_point.wgr IS NOT NULL) OR
              (p_constant_type = 'WATERCUT_PCT' AND curve_point.watercut_pct IS NOT NULL)
             )
      );
   CURSOR c_first_higher_x(cp_refx NUMBER) IS
      SELECT x_value,gor,cgr,wgr,watercut_pct
      FROM curve_point
      WHERE curve_id=p_curve_id
      AND x_value=
      (
         SELECT MIN(x_value)
         FROM curve_point
         WHERE curve_id=p_curve_id
         AND x_value>cp_refx
         AND (
              (p_constant_type = 'GOR' AND curve_point.gor IS NOT NULL) OR
              (p_constant_type = 'CGR' AND curve_point.cgr IS NOT NULL) OR
              (p_constant_type = 'WGR' AND curve_point.wgr IS NOT NULL) OR
              (p_constant_type = 'WATERCUT_PCT' AND curve_point.watercut_pct IS NOT NULL)
             )
      );

   CURSOR c_one_point IS
      SELECT cp.gor, cp.cgr, cp.wgr, cp.watercut_pct
      FROM curve_point cp WHERE cp.curve_id = p_curve_id
      AND (
           (p_constant_type = 'GOR' AND cp.gor IS NOT NULL) OR
           (p_constant_type = 'CGR' AND cp.cgr IS NOT NULL) OR
           (p_constant_type = 'WGR' AND cp.wgr IS NOT NULL) OR
           (p_constant_type = 'WATERCUT_PCT' AND cp.watercut_pct IS NOT NULL)
          );

  CURSOR c_performance_curve(ln_perf_curve_id NUMBER) IS
    SELECT pc.gor, pc.cgr, pc.wgr, pc.watercut_pct
    FROM performance_curve pc WHERE pc.perf_curve_id = ln_perf_curve_id
    AND (
         (p_constant_type = 'GOR' AND pc.gor IS NOT NULL) OR
         (p_constant_type = 'CGR' AND pc.cgr IS NOT NULL) OR
         (p_constant_type = 'WGR' AND pc.wgr IS NOT NULL) OR
         (p_constant_type = 'WATERCUT_PCT' AND pc.watercut_pct IS NOT NULL)
        );

BEGIN
   IF p_x_value IS NULL THEN
      RETURN NULL;
   END IF;

   ln_perf_curve_id := ec_curve.perf_curve_id(p_curve_id);

   -- If there are values for CGR, WGR, GOR and WATERCUT_PCT at Performance Curve Level
   SELECT COUNT(pc.perf_curve_id) INTO ln_performance_curve
   FROM performance_curve pc
   WHERE pc.perf_curve_id = ln_perf_curve_id
   AND (
        (p_constant_type = 'GOR' AND pc.gor IS NOT NULL) OR
        (p_constant_type = 'CGR' AND pc.cgr IS NOT NULL) OR
        (p_constant_type = 'WGR' AND pc.wgr IS NOT NULL) OR
        (p_constant_type = 'WATERCUT_PCT' AND pc.watercut_pct IS NOT NULL)
       );


    -- If only one point on the curve, then return this value
   SELECT COUNT(cp.curve_id) INTO ln_curve_points
   FROM curve_point cp
   WHERE cp.curve_id = p_curve_id
   AND (
        (p_constant_type = 'GOR' AND cp.gor IS NOT NULL) OR
        (p_constant_type = 'CGR' AND cp.cgr IS NOT NULL) OR
        (p_constant_type = 'WGR' AND cp.wgr IS NOT NULL) OR
        (p_constant_type = 'WATERCUT_PCT' AND cp.watercut_pct IS NOT NULL)
       );

  IF ln_performance_curve = 1 THEN
     FOR perf_curve IN c_performance_curve(ln_perf_curve_id) LOOP
       IF p_constant_type = 'GOR' THEN
         RETURN perf_curve.gor;
       ELSIF p_constant_type = 'CGR' THEN
          RETURN perf_curve.cgr;
       ELSIF p_constant_type = 'WGR' THEN
         RETURN perf_curve.wgr;
       ELSIF p_constant_type = 'WATERCUT_PCT' THEN
         RETURN perf_curve.watercut_pct;
       ELSE
         RETURN NULL;
       END IF;
     END LOOP;
   ELSE
     IF ln_curve_points = 1 THEN
       FOR curve_point IN c_one_point LOOP
          IF p_constant_type = 'GOR' THEN
            RETURN curve_point.gor;
          ELSIF p_constant_type = 'CGR' THEN
            RETURN curve_point.cgr;
          ELSIF p_constant_type = 'WGR' THEN
            RETURN curve_point.wgr;
          ELSIF p_constant_type = 'WATERCUT_PCT' THEN
            RETURN curve_point.watercut_pct;
          ELSE
            RETURN NULL;
          END IF;
       END LOOP;
     ELSIF ln_curve_points < 1 THEN
       RETURN NULL;
     END IF;
   END IF;

   lr_curve:=ec_curve.row_by_pk(p_curve_id);


      -- Linear interpolation between points
      -- Find the nearest point with a lower x
      FOR r_point IN c_first_lower_or_equal_x LOOP
         ln_x1:=r_point.x_value;
         IF p_constant_type = 'GOR' THEN
            ln_y1:=r_point.gor;
         ELSIF p_constant_type = 'CGR' THEN
            ln_y1:=r_point.cgr;
         ELSIF  p_constant_type = 'WGR' THEN
            ln_y1:=r_point.wgr;
         ELSIF p_constant_type = 'WATERCUT_PCT' THEN
            ln_y1:=r_point.watercut_pct;
         ELSE
            RETURN NULL;
         END IF;
      END LOOP;
      -- Find the nearest point with a higher x
      FOR r_point IN c_first_higher_or_equal_x LOOP
         ln_x2:=r_point.x_value;
         IF p_constant_type = 'GOR' THEN
            ln_y2:=r_point.gor;
         ELSIF p_constant_type = 'CGR' THEN
            ln_y2:=r_point.cgr;
         ELSIF  p_constant_type = 'WGR' THEN
            ln_y2:=r_point.wgr;
         ELSIF p_constant_type = 'WATERCUT_PCT' THEN
            ln_y2:=r_point.watercut_pct;
         ELSE
            RETURN NULL;
         END IF;
      END LOOP;
      -- Extrapolate boundary cases --
      IF ln_x1 IS NULL AND ln_y1 IS NULL AND (ln_x2 IS NOT NULL OR ln_y2 IS NOT NULL) THEN
         -- p1 is null, so p2 is the point with the lowest x. Extrapolate towards zero.
         -- First find the second lowest x value
         FOR r_point IN c_first_higher_x(ln_x2) LOOP
            ln_x3:=r_point.x_value;
            IF p_constant_type = 'GOR' THEN
               ln_y3:=r_point.gor;
            ELSIF p_constant_type = 'CGR' THEN
               ln_y3:=r_point.cgr;
            ELSIF  p_constant_type = 'WGR' THEN
               ln_y3:=r_point.wgr;
            ELSIF p_constant_type = 'WATERCUT_PCT' THEN
               ln_y3:=r_point.watercut_pct;
            ELSE
               RETURN NULL;
            END IF;
         END LOOP;
         -- Extrapolate from p2 to p_x_value, remember that p2 has lower x than p3
         ln_y:=EcBp_MathLib.interpolateLinear(p_x_value,ln_x2,ln_x3,ln_y2,ln_y3);
         RETURN ln_y;
      ELSIF ln_x2 IS NULL AND ln_y2 IS NULL AND (ln_x1 IS NOT NULL OR ln_y1 IS NOT NULL) THEN
         -- p2 is null, so p1 is the point with the highest x. Extrapolate towards infinity.
         -- First find the second highest x value
         FOR r_point IN c_first_lower_x(ln_x1) LOOP
            ln_x3:=r_point.x_value;
            IF p_constant_type = 'GOR' THEN
               ln_y3:=r_point.gor;
            ELSIF p_constant_type = 'CGR' THEN
               ln_y3:=r_point.cgr;
            ELSIF  p_constant_type = 'WGR' THEN
               ln_y3:=r_point.wgr;
            ELSIF p_constant_type = 'WATERCUT_PCT' THEN
               ln_y3:=r_point.watercut_pct;
            ELSE
               RETURN NULL;
            END IF;
         END LOOP;
         -- Extrapolate from p1 to p_x_value, remember that p3 has lower x than p1
         ln_y:=EcBp_MathLib.interpolateLinear(p_x_value,ln_x3,ln_x1,ln_y3,ln_y1);
         RETURN ln_y;
      END IF;
      -- Calculate
      RETURN EcBp_MathLib.interpolateLinearBoundary(p_x_value,ln_x1,ln_y1,ln_x2,ln_y2);

   RETURN NULL;
END getRatioOrWcfromX;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getMeasurementType                                                    --
-- Description    : Returns either x or y axis measurement type  --
--                             				   --
--                                                                                               --
-- Preconditions  :                                        --
-- Postconditions :                                        --
--                                                                                               --
-- Using tables   :                                                          --
--                                                                                               --
-- Using functions:                                        --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                        --
--                                                                                               --
-- Behaviour      :                                        --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getMeasurementType(p_curve_id NUMBER, p_curve_axis VARCHAR2) RETURN VARCHAR2
--</EC-DOC>
  IS
   lv2_measurementtype    VARCHAR2(32);
   lv2_paramcode_x        VARCHAR2(32);

  BEGIN

   IF p_curve_axis = 'Y' then
   --to get the measurement type for y axis
     IF ec_curve.phase(p_curve_id)=ecdp_phase.OIL then
        lv2_measurementtype := 'STD_OIL_RATE';
     ELSIF ec_curve.phase(p_curve_id)=ecdp_phase.GAS then
        lv2_measurementtype := 'STD_GAS_RATE';
     ELSIF ec_curve.phase(p_curve_id)=ecdp_phase.WATER then
        lv2_measurementtype := EcDp_Ctrl_Property.getSystemProperty('DEFAULT_WATER_RATE_UOM');
     ELSIF ec_curve.phase(p_curve_id)=ecdp_phase.LIQUID then
        lv2_measurementtype := 'STD_LIQ_VOL_RATE';
     END IF;
   ELSE
   --to get measurement type for x axis--
     lv2_paramcode_x := ec_performance_curve.curve_parameter_code(ec_curve.perf_curve_id(p_curve_id));

     CASE lv2_paramcode_x
     WHEN 'WH_PRESS'
        THEN lv2_measurementtype := 'PRESS_GAUGE';
     WHEN 'WH_TEMP'
        THEN lv2_measurementtype := 'TEMP';
     WHEN 'BH_PRESS'
        THEN lv2_measurementtype := 'PRESS_GAUGE';
     WHEN 'ANNULUS_PRESS'
        THEN lv2_measurementtype := 'PRESS_GAUGE';
     WHEN 'DP_TUBING'
        THEN lv2_measurementtype := 'PRESS_ABS';
     WHEN 'DP_CHOKE'
        THEN lv2_measurementtype := 'PRESS_ABS';
     WHEN 'GL_PRESS'
        THEN lv2_measurementtype := 'PRESS_GAUGE';
     WHEN 'GL_DIFF_PRESS'
        THEN lv2_measurementtype := 'PRESS_ABS';
     WHEN 'AVG_FLOW_MASS'
        THEN lv2_measurementtype := 'LIQ_MASS_RATE';
     WHEN 'GL_RATE'
        THEN lv2_measurementtype := 'STD_GAS_RATE';
     ELSE
        lv2_measurementtype := null;
     END CASE;

   END IF;

  RETURN lv2_measurementtype;

END getMeasurementType;
--<EC-DOC>


END EcDp_Curve;