CREATE OR REPLACE PACKAGE BODY EcBp_Mathlib IS
/***********************************************************************
** Package	      :  EcBp_Mathlib
**
** $Revision: 1.10 $
**
** Purpose	      :  Provide functions related mathematical calculations
**
**
** Documentation  :  www.energy-components.com
**
** Created  : 21.01.2000  Carl-Fredrik S�sen
**
** Modification history:
**
** Version  Date      Whom      Change description:
** -------  ------    -----     --------------------------------------
** 1.0      21.01.00  CFS       Initial version
** 3.0      15.03.00  DN        Bug fix in interpolateLinear: (yMax - yMax) replaced with (yMax - yMin).
** 3.1      09.10.00  DN        Added linear regression procedure.
*******
**          04.02.04  BIH       Added least squares curve fit procedures (curveFitLinearLS and curveFitPoly2LS)
**          11.02.04  BIH       Added function interpolateLinearBoundary
**          03.12.04  DN        TI 1823: Removed dummy package constructor.
**          02.10.07  zakiiari  ECPD-5765: Added procedure calcCorrelationCoefficient
**          20.05.10  Toha      ECPD-14426: Added curveFitPoly3LS. Added curveFitPolyNLS to support any order of
**                              polynomial, using least square method + gauss jordan elimination method.
**                              Added procedure: swap, divide, eliminate, gaussJordanElimination, cleanupMatrix, printMatrix, curveFitPolyNLS, curveFitPoly3LS.
**          30.07.12  leongsei  ECPD-10325: Replaced dbms_output by EcDp_DynSql.WriteDebugText
**          23.02.17  choooshu  ECPD-32359: Added curveFitPoly4LS to support 4th order polynomial calculation
***************************************************************************/

--<EC-DOC>
--------------------------------------------------------------------------------------------------
-- Procedure      : curveFitLinearLS                                                            --
-- Description    : Calculates coefficients for linear approximation :  c1*X + c0               --
--                  Finds exact solution with two points and least squares solution if there    --
--                  are more than two points.                                                   --
--                  Typical use:                                                                --
--                  PROCEDURE myproc                                                            --
--                  IS                                                                          --
--                     points EcBp_Mathlib.PointCursor;                                         --
--                     c0 number;                                                               --
--                     c1 number;                                                               --
--                     err number;                                                              --
--                  BEGIN                                                                       --
--                     OPEN points FOR select xval as x,yval as y from mypoints;                --
--                     ecdp_curve.curveFitLinearLS(points,c0,c1,err);                           --
--                     IF err=0 THEN                                                            --
--                        ... c0 and c1 now holds the coeffs ...                                --
--                     END IF;                                                                  --
--                  END myproc;                                                                 --
--                                                                                              --
-- Preconditions  :                                                                             --
-- Postconditions : If err=0 then c0 and c1 holds the coefficients                              --
--                  otherwise err is the error code:                                            --
--                     1 is too few distinct points, 2 is invalid data (NULL)                   --
-- Using tables   :                                                                             --
-- Configuration                                                                                --
-- required       :                                                                             --
-- Behaviour      :                                                                             --
--                                                                                              --
--------------------------------------------------------------------------------------------------
PROCEDURE curveFitLinearLS(
	p_points PointCursor,
	p_c0     OUT NUMBER,
	p_c1     OUT NUMBER,
	p_error  OUT INTEGER	-- 0 is ok, 1 is too few distinct points, 2 is invalid data (NULL)
)
--</EC-DOC>
IS
   num_points integer:=0;
   sum_x number:=0;
   sum_x2 number:=0;
   sum_y number:=0;
   sum_xy number:=0;
   det number:=0;
   point PointRec;
BEGIN
   p_error:=0;
   -- Loop through the points and update temporary values that we
   -- need in the final calculations
   LOOP
      FETCH p_points INTO point;
      EXIT WHEN p_points%NOTFOUND;
      sum_x:=sum_x+point.X;
      sum_x2:=sum_x2+point.X*point.X;
      sum_y:=sum_y+point.Y;
      sum_xy:=sum_xy+point.X*point.Y;
      num_points:=num_points+1;
   END LOOP;
   -- Find the determinant of the solution matrix
   det:=num_points*sum_x2-sum_x*sum_x;
   -- Find the two coefficients
   p_c0:=(sum_x2*sum_y-sum_x*sum_xy)/det;
   p_c1:=(num_points*sum_xy-sum_x*sum_y)/det;
   -- Check for invalid data
   IF p_c0 IS NULL OR p_c1 IS NULL THEN
      p_error:=2;
   END IF;
EXCEPTION
   WHEN ZERO_DIVIDE THEN
      -- This only occurs if there are too few distinct points
      p_error:=1;
  WHEN OTHERS THEN
      -- Should never happen!
      RAISE_APPLICATION_ERROR( -20500, 'SQLCODE=' || TO_CHAR(SQLCODE) || ';' || SQLERRM );
END curveFitLinearLS;

--<EC-DOC>
--------------------------------------------------------------------------------------------------
-- Procedure      : curveFitPoly2LS                                                             --
-- Description    : Calculates coefficients for 2nd polynom approximation :  c2*X^2 + c1*X + c0 --
--                  Finds exact solution with three points and least squares solution if there  --
--                  are more than three points.                                                 --
--                  Typical use:                                                                --
--                  PROCEDURE myproc                                                            --
--                  IS                                                                          --
--                     points EcBp_Mathlib.PointCursor;                                         --
--                     c0 number;                                                               --
--                     c1 number;                                                               --
--                     c2 number;                                                               --
--                     err number;                                                              --
--                  BEGIN                                                                       --
--                     OPEN points FOR select xval as x,yval as y from mypoints;                --
--                     ecdp_curve.curveFitPoly2LS(points,c0,c1,c2,err);                         --
--                     IF err=0 THEN                                                            --
--                        ... c0, c1 and c2 now holds the coeffs ...                            --
--                     END IF;                                                                  --
--                  END myproc;                                                                 --
--                                                                                              --
-- Preconditions  :                                                                             --
-- Postconditions : If err=0 then c0, c1 and c2 holds the coefficients                          --
--                  otherwise err is the error code:                                            --
--                     1 is too few distinct points, 2 is invalid data (NULL)                   --
-- Using tables   :                                                                             --
-- Configuration                                                                                --
-- required       :                                                                             --
-- Behaviour      :                                                                             --
--                                                                                              --
--------------------------------------------------------------------------------------------------
PROCEDURE curveFitPoly2LS(
	p_points PointCursor,
	p_c0     OUT NUMBER,
	p_c1     OUT NUMBER,
	p_c2     OUT NUMBER,
	p_error  OUT INTEGER	-- 0 is ok, 1 is too few distinct points, 2 is invalid data (NULL)
)
--</EC-DOC>
IS
   num_points integer:=0;
   sum_x number:=0;
   sum_x2 number:=0;
   sum_x3 number:=0;
   sum_x4 number:=0;
   sum_y number:=0;
   sum_xy number:=0;
   sum_x2y number:=0;
   det number:=0;
   point PointRec;
   tmp number;
BEGIN
   p_error:=0;
   -- Loop through the points and update temporary values that we
   -- need in the final calculations
   LOOP
      FETCH p_points INTO point;
      EXIT WHEN p_points%NOTFOUND;
      tmp:=point.X;
      sum_x:=sum_x+tmp; -- tmp=x
      sum_xy:=sum_xy+tmp*point.Y; -- tmp=x
      tmp:=tmp*point.X;
      sum_x2:=sum_x2+tmp; -- tmp=x^2
      sum_x2y:=sum_x2y+tmp*point.Y; -- tmp=x^2
      tmp:=tmp*point.X;
      sum_x3:=sum_x3+tmp; -- tmp=x^3
      tmp:=tmp*point.X;
      sum_x4:=sum_x4+tmp; -- tmp=x^4
      sum_y:=sum_y+point.Y;
      num_points:=num_points+1;
   END LOOP;
   -- Find the determinant of the solution matrix
   det:=-sum_x*sum_x*sum_x4
        +2*(sum_x*sum_x2*sum_x3)
        -sum_x2*sum_x2*sum_x2
        +num_points*sum_x2*sum_x4
        -num_points*sum_x3*sum_x3;
   -- Find the three coefficients from LS formulas (see the performance curve technical spec
   -- doc for information on why these formulas work :-)
   p_c0:=(sum_y*(sum_x2*sum_x4-sum_x3*sum_x3)+sum_xy*(sum_x2*sum_x3-sum_x*sum_x4)+sum_x2y*(sum_x*sum_x3-sum_x2*sum_x2))/det;
   p_c1:=(sum_y*(sum_x2*sum_x3-sum_x*sum_x4)+sum_xy*(num_points*sum_x4-sum_x2*sum_x2)+sum_x2y*(sum_x*sum_x2-num_points*sum_x3))/det;
   p_c2:=(sum_y*(sum_x*sum_x3-sum_x2*sum_x2)+sum_xy*(sum_x*sum_x2-num_points*sum_x3)+sum_x2y*(num_points*sum_x2-sum_x*sum_x))/det;
   -- Check for invalid data
   IF p_c0 IS NULL OR p_c1 IS NULL OR p_c2 IS NULL THEN
      p_error:=2;
   END IF;
EXCEPTION
   WHEN ZERO_DIVIDE THEN
      -- This only occurs if there are too few distinct points
      p_error:=1;
  WHEN OTHERS THEN
      -- Should never happen!
      RAISE_APPLICATION_ERROR( -20500, 'SQLCODE=' || TO_CHAR(SQLCODE) || ';' || SQLERRM );
END curveFitPoly2LS;


--------------------------------------------------------------------------------------------------
-- Function       : interpolateLinearBoundary                                                   --
-- Description    : Interpolates two points linearly to get y.                                  --
--                  If one of the points is missing (x and y is NULL), then the other           --
--                  point will be used.                                                         --
-- Preconditions  :                                                                             --
-- Postconditions : Returns NULL if both points are invalid                                     --
-- Using tables   :                                                                             --
-- Configuration                                                                                --
-- required       :                                                                             --
-- Behaviour      :                                                                             --
--                                                                                              --
--------------------------------------------------------------------------------------------------
FUNCTION interpolateLinearBoundary(p_x_value NUMBER,p_x1 NUMBER,p_y1 NUMBER,p_x2 NUMBER,p_y2 NUMBER) RETURN NUMBER
--</EC-DOC>
IS
BEGIN
   -- Handle NULL scenarios first.
   -- This can happen from boundary cases, which should give a valid value out,
   -- and invalid data cases which should return NULL.
   IF (p_x1 IS NULL OR p_y1 IS NULL) AND (p_x2 IS NULL OR p_y2 IS NULL) THEN
      -- Cannot use any of the points, returning NULL
      RETURN NULL;
   ELSIF p_x1 IS NULL OR p_y1 IS NULL THEN
      -- Cannot use the first point, return y2 which we then know must be valid (boundary case)
      RETURN p_y2;
   ELSIF p_x2 IS NULL OR p_y2 IS NULL THEN
      -- Cannot use the second point, return y1 which we then know must be valid (boundary case)
      RETURN p_y1;
   ELSIF p_x1 IS NULL OR p_x2 IS NULL THEN
      -- Some kind of invalid data, return NULL
      RETURN NULL;
   END IF;
   -- Both points are valid, find the result!
   IF p_x1=p_x2 THEN
      -- The same point (exact match).
      RETURN p_y1;
   ELSE
      -- Need to interpolate values
      RETURN p_y1+(p_x_value-p_x1)*(p_y2-p_y1)/(p_x2-p_x1);
   END IF;
END interpolateLinearBoundary;


----------------------------------------------------------------------------------------------
-- Procedure:   calcLinearRegression
-- Description: Calculates a linear equation based upon a set of points using linear regression
--              least square method.
-- Returns:     Linear equation constants.
----------------------------------------------------------------------------------------------
PROCEDURE calcLinearRegression(p_point_list  Ec_discrete_func_type,
                               b OUT NUMBER, -- slope
                               a OUT NUMBER  -- intersect y axis
                               ) IS

-- standard naming replaced by notation closer to mathematical algoritms


sumxy  NUMBER := 0;
sumx   NUMBER := 0;
sumx2  NUMBER := 0;
sumy2  NUMBER := 0;
sumy   NUMBER := 0;

n   NUMBER;
x0  NUMBER;
y0  NUMBER;
i   BINARY_INTEGER := 0;
ln_div NUMBER;

lb_distinct_points BOOLEAN;
ln_prev_x NUMBER;
ln_prev_y NUMBER;

BEGIN

   n := p_point_list.Count;

   IF n >= 2 THEN

      FOR i IN 1..n LOOP

         IF NOT lb_distinct_points AND (i >= 2) THEN

            IF  (p_point_list(i).x <> ln_prev_x) THEN

               lb_distinct_points := TRUE;

            END IF;

         END IF;

      	sumxy := sumxy + ( p_point_list(i).x * p_point_list(i).y );
      	sumx  := sumx  + ( p_point_list(i).x );
      	sumx2  := sumx2  + Power( p_point_list(i).x , 2 );
      	sumy  := sumy  + ( p_point_list(i).y );
      	sumy2  := sumy2  + Power( p_point_list(i).y , 2 );
         ln_prev_x := p_point_list(i).x;

      END LOOP;

      -- Calc avg figures as an initial point.
      x0 := sumx / n;
      y0 := sumy / n;

      ln_div := sumx2 - Power(sumx,2)/n;

      IF ln_div <> 0 THEN

         -- Determine required linear equation constants
         -- Regression coefficient (slope)
   	   b := (sumxy - ((sumx*sumy)/n)) / ln_div;
   	   -- Intersect with y-axis y-value.
         a := y0 - b * x0;

      END IF;

   END IF;

END calcLinearRegression;

-----------------------------------------------------------------
-- Function   : findFunctionValueFromCurve
-- Description: Find a value of a function y = f(x) given by a curve.
--              (i.e. by direct hit or by interpolation)
-----------------------------------------------------------------
FUNCTION findFunctionValueFromCurve(
	p_func_list  Ec_discrete_func_type,
	p_list_size  BINARY_INTEGER,
	p_lookup_val NUMBER)

RETURN NUMBER IS

i             BINARY_INTEGER := 0;
lr_points     Ec_two_points;
lr_prev_point Ec_point;
ln_ret_val    NUMBER;

BEGIN

   IF ((p_list_size >= 1) AND (p_lookup_val IS NOT NULL)) THEN

		FOR i IN 1..p_list_size LOOP

			-- curve point matches lookup value
			IF (p_func_list(i).x = p_lookup_val) THEN

				ln_ret_val := p_func_list(i).y;
				EXIT;

			ELSIF (p_func_list(i).x > p_lookup_val) THEN

				lr_points.p2.x := p_func_list(i).x;
				lr_points.p2.y := p_func_list(i).y;

				lr_points.p1.x := lr_prev_point.x;
				lr_points.p1.y := lr_prev_point.y;

			ELSE -- p_func_list.x(i) < p_lookup_val

				IF (lr_points.p2.x IS NULL) THEN

					lr_points.p2.x := p_func_list(i).x;
					lr_points.p2.y := p_func_list(i).y;

				ELSE

					lr_points.p1.x := p_func_list(i).x;
					lr_points.p1.y := p_func_list(i).y;

					EXIT; -- got two points

				END IF;

			END IF;

			lr_prev_point.x := p_func_list(i).x;
			lr_prev_point.y := p_func_list(i).y;

		END LOOP;

		-- Now, we did not get an exact match but got at least one point to work with
		IF (ln_ret_val IS NULL) THEN

		  IF (lr_points.p2.x IS NULL AND lr_points.p1.x IS NULL) THEN

				ln_ret_val := NULL;

		  ELSIF (lr_points.p2.x IS NOT NULL AND lr_points.p1.x IS NOT NULL) THEN

				ln_ret_val := interpolateLinear(
									p_lookup_val,
									lr_points.p1.x,
									lr_points.p2.x,
									lr_points.p1.y,
									lr_points.p2.y);

		  ELSE

				ln_ret_val := Nvl(lr_points.p2.y, lr_points.p1.y);

		  END IF;

		END IF;

	END IF;

	RETURN ln_ret_val;

END findFunctionValueFromCurve;

-----------------------------------------------------------------
-- Function   : interpolateLinear
-- Description: LINEAR INTERPOLATION/EXTRAPOLATION
-----------------------------------------------------------------
FUNCTION interpolateLinear(
	p_lookup_val NUMBER,
	xMin 			 NUMBER,
	xMax 			 NUMBER,
	yMin 			 NUMBER,
	yMax 			 NUMBER)

RETURN NUMBER IS

BEGIN

   RETURN (yMax - yMin) / (xMax - xMin) * p_lookup_val +
          (yMin - (yMax - yMin) / (xMax - xMin) * xMin);

EXCEPTION

	WHEN zero_divide THEN

	  RETURN yMin;

END interpolateLinear;


-----------------------------------------------------------------
-- Function   : quadraticCurve
-- Description:
-----------------------------------------------------------------

FUNCTION quadraticCurve(
	p_whp           NUMBER,
	p_choke_mm      NUMBER,
	p_test_whp      NUMBER,
	p_test_choke_mm NUMBER,
	p_test_qty      NUMBER)

RETURN NUMBER IS

BEGIN

   RETURN ((p_whp / p_test_whp) * (p_choke_mm / p_test_choke_mm)**2 * p_test_qty);

EXCEPTION

	WHEN zero_divide THEN

	  RETURN NULL;

END quadraticCurve;

--<EC-DOC>
----------------------------------------------------------------------------------------------
-- Procedure:   calcCorrelationCoefficient
-- Description: Calculates correlation coefficient based upon a set of points using linear regression
--              least square method.
-- Returns:     Correlation coefficient.
----------------------------------------------------------------------------------------------
PROCEDURE calcCorrelationCoefficient(p_point_list Ec_discrete_func_type, r OUT NUMBER)
--</EC-DOC>
IS
  ln_sum_xy  NUMBER := 0;
  ln_sum_x   NUMBER := 0;
  ln_sum_x2  NUMBER := 0;
  ln_sum_y   NUMBER := 0;
  ln_sum_y2  NUMBER := 0;
  ln_denom   NUMBER := 0;
  ln_numer   NUMBER := 0;
  ln_point_count NUMBER := 0;
  i              BINARY_INTEGER := 0;

BEGIN
  ln_point_count := p_point_list.Count;

  IF ln_point_count >= 2 THEN

    FOR i IN 1..ln_point_count LOOP
      -- collecting known values
      ln_sum_x := ln_sum_x + p_point_list(i).x;
      ln_sum_y := ln_sum_y + p_point_list(i).y;
      ln_sum_xy := ln_sum_xy + (p_point_list(i).x*p_point_list(i).y);

      ln_sum_x2 := ln_sum_x2 + POWER(p_point_list(i).x, 2);
      ln_sum_y2 := ln_sum_y2 + POWER(p_point_list(i).y, 2);
    END LOOP;

    ln_numer := ln_point_count*ln_sum_xy - (ln_sum_x*ln_sum_y);
    ln_denom := SQRT((ln_point_count*ln_sum_x2 - POWER(ln_sum_x,2)) * (ln_point_count*ln_sum_y2 - POWER(ln_sum_y,2)));

    r := ln_numer / ln_denom;

  END IF;

END calcCorrelationCoefficient;

--<EC-DOC>
----------------------------------------------------------------------------------------------
-- Procedure:   getYFromXPolynom2
-- Description: Calculates the y value for a given polynom with maximum 2 degree
--
-- Returns:     Calculated Y value.
----------------------------------------------------------------------------------------------
FUNCTION  getYFromXPolynom2(p_x NUMBER,
                            p_c2 NUMBER,
                            p_c1 NUMBER,
                            p_c0 NUMBER)
RETURN NUMBER
--</EC-DOC>
IS
  ln_y NUMBER;

BEGIN
  ln_y := p_c2*p_x*p_x + p_c1*p_x + p_c0;
  RETURN ln_y;
END;

--<EC-DOC>
----------------------------------------------------------------------------------------------
-- Procedure:   getYFromXPolynom2Inv
-- Description: Calculates the inverse y value for a given polynom with maximum 2 degree
--              least square method.
-- Returns:     Calculated inverse y value if uniqly real solution exist in given range,
--              if not this function will return NULL representing undefined result.
----------------------------------------------------------------------------------------------
FUNCTION  getYFromXPolynom2Inv(p_x NUMBER,
                               p_c2 NUMBER,
                               p_c1 NUMBER,
                               p_c0 NUMBER,
                               p_ymin NUMBER default 0,    -- for graph purposes we are usually interested in Q1, thus the default value
                               p_ymax NUMBER default NULL) -- if the invers function has more than 1 solution in given y-range this function will return NULL as undefined
RETURN NUMBER
--</EC-DOC>
IS
  y1 NUMBER;
  y2 NUMBER;
  y  NUMBER;
  discriminant NUMBER;

BEGIN

   IF Nvl(p_c2,0) <> 0 THEN  -- if not then this is not Quadratic equation

      -- First find if it has a real or complex solution

      discriminant := p_c1*p_c1 - 4 * p_c2 * (p_c0-p_x );

      y := NULL; -- In case there is no unique real solution within range, then the solution is undefined

      If discriminant >= 0 then

        y1 := ( - p_c1 + sqrt(discriminant) )/ (2* p_c2);
        y2 := ( - p_c1 - sqrt(discriminant) )/ (2* p_c2);

        -- Now need to find what solution to use
        if y1  >= nvl(p_ymin,y1-1) and y1  <= nvl(p_ymax,y1+1)
        and ( y2  < nvl(p_ymin,y2) or y2  >nvl(p_ymax,y2))   then  -- we have one solution in y1

          y := y1;

        elsif y2  >= nvl(p_ymin,y2-1) and y2  <= nvl(p_ymax,y2+1)
        and ( y1  < nvl(p_ymin,y1) or y1  >nvl(p_ymax,y1))   then  -- we have one solution in y2

          y := y2;

        elsif y2  >= nvl(p_ymin,y2-1) and y2  <= nvl(p_ymax,y2+1)
        and   y1 = y2 then --special case where discriminant = 0

          y := y2;

        end if;

      end if;

   ELSIF Nvl(p_c1,0) <> 0 THEN  -- treat it as linear case x = (y-c0)/c1

      y := (p_x-p_c0)/p_c1;

   ELSE  -- the function is a constant, there are no inverse function

      y := NULL;

   END IF;

   return y;
END getYFromXPolynom2Inv;

--<EC-DOC>
----------------------------------------------------------------------------------------------
-- Procedure:   swap
-- Description: To be used by Gauss-Jordan Elimination Method.
--              Swap row i with row k
-- Preconditions  : must only be used by gaussJordanElimination algorithm below                                                                            --
-- Postconditions :                                                                             --
-- Using tables   :                                                                             --
-- Configuration                                                                                --
-- required       :                                                                             --
-- Behaviour      :                                                                             --
--
----------------------------------------------------------------------------------------------
procedure swap(p_matrix in out EcBp_Mathlib.t_matrix,
  i number, -- current matrix row being investigated
  k number, -- row to swap with
  j number  -- current matrix column being investigated
  )
--</EC-DOC>
IS
ln_temp number;
ln_width number := p_matrix(1).count;

begin
  for q in j..ln_width loop
    --swap!
    ln_temp := p_matrix(i)(q);
    p_matrix(i)(q) := p_matrix(k)(q);
    p_matrix(k)(q) := ln_temp;
  end loop;
end swap;

--<EC-DOC>
----------------------------------------------------------------------------------------------
-- Procedure:   divide
-- Description: divide row
-- Preconditions  : must only be used by gaussJordanElimination algorithm below                                                                            --
-- Postconditions :                                                                             --
-- Using tables   :                                                                             --
-- Configuration                                                                                --
-- required       :                                                                             --
-- Behaviour      :                                                                             --
--
----------------------------------------------------------------------------------------------
procedure divide(p_matrix in out EcBp_Mathlib.t_matrix,
  i number, -- current matrix row
  j number  -- current matrix column
  )
--</EC-DOC>
IS
ln_temp number;
ln_width number := p_matrix(1).count;

begin
  ln_temp := p_matrix(i)(j);
  for q in (j+1)..ln_width loop
    p_matrix(i)(q) := p_matrix(i)(q)/ln_temp;
  end loop;
  p_matrix(i)(j) := 1;
end divide;

--<EC-DOC>
----------------------------------------------------------------------------------------------
-- Procedure:   divide
-- Description: eliminate row following gauss jordan elimination
-- Preconditions  : must only be used by gaussJordanElimination algorithm below                                                                            --
-- Postconditions :                                                                             --
-- Using tables   :                                                                             --
-- Configuration                                                                                --
-- required       :                                                                             --
-- Behaviour      :                                                                             --
--
----------------------------------------------------------------------------------------------
procedure eliminate(p_matrix in out EcBp_Mathlib.t_matrix,
  i number, -- current matrix row
  j number  -- current matrix column
  )
--</EC-DOC>
IS
ln_width number := p_matrix(1).count;
ln_row number := p_matrix.count;

begin
  for p in 1..ln_row loop
    if p <> i and p_matrix(p)(j) <> 0 then
      for q in (j+1)..ln_width loop
        p_matrix(p)(q) := p_matrix(p)(q) - p_matrix(p)(j)*p_matrix(i)(q);
      end loop;
      p_matrix(p)(j) := 0;
    end if;
  end loop;
end eliminate;

--<EC-DOC>
----------------------------------------------------------------------------------------------
-- Procedure:   gaussJordanElimination
-- Description: perform gauss-jordan elimination on the given matrix
-- Preconditions  : given matrix must be well formed                                            --
-- Postconditions :                                                                             --
-- Using tables   :                                                                             --
-- Configuration                                                                                --
-- required       :                                                                             --
-- Behaviour      : transform given matrix to reduced row echelon form. algorithm being         --
--                  used can be found in many places
--
----------------------------------------------------------------------------------------------
procedure gaussJordanElimination(p_matrix in out EcBp_Mathlib.t_matrix)
--</EC-DOC>
is
ln_width number := p_matrix(1).count; -- matrix columns
ln_row number := p_matrix.count; -- matrix rows
i number := 1; -- current row position
j number := 1; -- current column position
k number := 1; -- lead

begin
  while i <= ln_row and j <= ln_width loop
    k := i;
    while k <= ln_row and p_matrix(k)(j) = 0 loop
      k := k+1;
    end loop;

    if k <= ln_row then
      if k <> i then
        swap(p_matrix, i, k, j);
      end if;

      if p_matrix(i)(j) <> 1 then
        divide(p_matrix, i, j);
      end if;

      eliminate(p_matrix, i, j);
      i := i+1;
    end if;
    j:= j+1;
  end loop;
end gaussJordanElimination;

--<EC-DOC>
----------------------------------------------------------------------------------------------
-- Procedure:   cleanupMatrix
-- Description: clean up matrix
-- Preconditions  : given matrix must not be empty                                              --
-- Postconditions :                                                                             --
-- Using tables   :                                                                             --
-- Configuration                                                                                --
-- required       :                                                                             --
-- Behaviour      :                                                                             --
--
----------------------------------------------------------------------------------------------
procedure cleanupMatrix(p_matrix IN OUT EcBp_Mathlib.t_matrix)
--</EC-DOC>
is
begin
  for i in 1..p_matrix.count loop
    p_matrix(i).delete;
  end loop;
  p_matrix.delete;
end cleanupMatrix;

--<EC-DOC>
----------------------------------------------------------------------------------------------
-- Procedure:   printMatrix
-- Description: print matrix for test/verification
-- Preconditions  : given matrix must not be empty                                              --
-- Postconditions :                                                                             --
-- Using tables   :                                                                             --
-- Configuration                                                                                --
-- required       :                                                                             --
-- Behaviour      :                                                                             --
--
----------------------------------------------------------------------------------------------
procedure printMatrix(p_matrix EcBp_Mathlib.t_matrix)
--</EC-DOC>
is
ln_width number := p_matrix(1).count; -- matrix columns
ln_row number := p_matrix.count; -- matrix rows
begin
  for i in 1..ln_row loop
    for j in 1..ln_width loop
      ecdp_dynsql.WriteDebugText('EcBp_Mathlib.printMatrix', 'pos(' || i || ','||j||')='|| p_matrix(i)(j)|| ';', 'DEBUG' );
    end loop;
    ecdp_dynsql.WriteDebugText('EcBp_Mathlib.printMatrix', 'end', 'DEBUG' );
  end loop;

end printMatrix;

--<EC-DOC>
----------------------------------------------------------------------------------------------
-- Procedure:   curveFitPolyNLS
-- Description: perform curve fit for any order of polynomial, preferably more than second order
--              using least square method plus gauss jordan elimination
-- Preconditions  : for nth order polynomial, points must be more than n+1                      --
-- Postconditions :                                                                             --
-- Using tables   :                                                                             --
-- Configuration                                                                                --
-- required       :                                                                             --
-- Behaviour      :                                                                             --
--
----------------------------------------------------------------------------------------------
procedure curveFitPolyNLS(p_points PointCursor,
  p_polyOrder number, -- order of polynomial
  p_coeff in out DBMS_SQL.Number_Table,
  p_error out integer)
--</EC-DOC>
is
l_point Ec_point;
l_matrix EcBp_Mathlib.t_matrix;
ln_count number := 0; -- number of points must be more than polynomial order
m number := p_polyOrder+1; -- number of coeff
begin
  -- initiate matrix
  for i in 1..m loop
    for j in 1..(m+1) loop
      l_matrix(i)(j) := 0;
    end loop;
  end loop;
  -- fill up matrix using points, then least square it to generate matrix
  loop
    fetch p_points into l_point;
    exit when p_points%NOTFOUND;

      -- adds to each matrix, with least square polynomial
    for i in 1..m loop
      for j in 1..m loop
        l_matrix(i)(j):=l_matrix(i)(j) + power(l_point.x, i-1+j-1);
      end loop;

      -- last column
      l_matrix(i)(m+1) := l_matrix(i)(m+1) + l_point.y * power(l_point.x, i-1);
    end loop;
    ln_count := ln_count+1;
  end loop; -- end fetch points

  if ln_count < m then -- too little number
    p_error := 1;
    cleanupMatrix(l_matrix);
    return;
  end if;

  -- reduce matrix to echelon form
  gaussJordanElimination(l_matrix);
  -- printMatrix(l_matrix);
  -- set coefficient
  for i in 1..m loop
    p_coeff(i) := l_matrix(i)(m+1);
  end loop;

  -- cleanup matrix
  cleanupMatrix(l_matrix);
end curveFitPolyNLS;

--<EC-DOC>
--------------------------------------------------------------------------------------------------
-- Procedure      : curveFitPoly3LS                                                             --
-- Description    : Calculates coefficients for 3rd polynom approximation :                     --
--                  c3*X^3+c2*X^2 + c1*X + c0                                                   --
--                  Finds approximate solution with four points and least squares solution      --
--                  and gauss-jordan elimination, if there                                      --
--                  are more than four points.                                                  --
--                                                                                              --
-- Preconditions  :                                                                             --
-- Postconditions : If err=0 then c0, c1, c2 and c3 holds the coefficients                          --
--                  otherwise err is the error code:                                            --
--                     1 is too few distinct points, 2 is invalid data (NULL)                   --
-- Using tables   :                                                                             --
-- Configuration                                                                                --
-- required       :                                                                             --
-- Behaviour      :                                                                             --
--                                                                                              --
--------------------------------------------------------------------------------------------------
PROCEDURE curveFitPoly3LS(
	p_points PointCursor,
	p_c0     OUT NUMBER,
	p_c1     OUT NUMBER,
	p_c2     OUT NUMBER,
	p_c3     OUT NUMBER,
	p_error  OUT INTEGER	-- 0 is ok, 1 is too few distinct points, 2 is invalid data (NULL)
)
--</EC-DOC>
is
l_coeff DBMS_SQL.Number_Table;
begin
  curveFitPolyNLS(p_points, 3, l_coeff, p_error);

  if p_error <> 0 then
    l_coeff.delete;
    return;
  end if;
  p_c0 := l_coeff(1);
  p_c1 := l_coeff(2);
  p_c2 := l_coeff(3);
  p_c3 := l_coeff(4);

  l_coeff.delete;
end;

--<EC-DOC>
--------------------------------------------------------------------------------------------------
-- Procedure      : curveFitPoly4LS                                                             --
-- Description    : Calculates coefficients for 4th polynom approximation :                     --
--                  c4*X^4 + c3*X^3 + c2*X^2 + c1*X + c0                                        --
--                  Finds approximate solution with four points and least squares solution      --
--                  and gauss-jordan elimination, if there                                      --
--                  are more than five points.                                                  --
-- Preconditions  :                                                                             --
-- Postconditions : If err=0 then c0, c1, c2, c3 and c4 holds the coefficients                          --
--                  otherwise err is the error code:                                            --
--                     1 is too few distinct points, 2 is invalid data (NULL)                   --
-- Using tables   :                                                                             --
-- Configuration                                                                                --
-- required       :                                                                             --
-- Behaviour      :                                                                             --
--                                                                                              --
--------------------------------------------------------------------------------------------------
PROCEDURE curveFitPoly4LS(
    p_points PointCursor,
    p_c0     OUT NUMBER,
    p_c1     OUT NUMBER,
    p_c2     OUT NUMBER,
    p_c3     OUT NUMBER,
    p_c4     OUT NUMBER,
    p_error  OUT INTEGER    -- 0 is ok, 1 is too few distinct points, 2 is invalid data (NULL)
)
--</EC-DOC>
is
l_coeff DBMS_SQL.Number_Table;
begin
  curveFitPolyNLS(p_points, 4, l_coeff, p_error);

  if p_error <> 0 then
    l_coeff.delete;
    return;
  end if;
  p_c0 := l_coeff(1);
  p_c1 := l_coeff(2);
  p_c2 := l_coeff(3);
  p_c3 := l_coeff(4);
  p_c4 := l_coeff(5);

  l_coeff.delete;
end;

END;