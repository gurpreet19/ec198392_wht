CREATE OR REPLACE PACKAGE BODY EcDp_Stream_Formula IS
/****************************************************************
** Package        :  EcDp_Stream_Formula
**
** $Revision: 1.29 $
**
** Purpose        :  This package is responsible for stream fluid information for formula streams
**
** Documentation  :  www.energy-components.com
**
**
** Prerequisite   :  Oracle version 8 or later to use 'EXECUTE IMMEDIATE ...'
**
** Created  : 03.12.2002  Peter Gilling
**
** Modification history:
**
** Date        Whom      Change description:
** ------      -----     -----------------------------------
** 03.12.2002  PGI       First version
** 04.02.2003  UMF       Added function to check for circular reference
** 24.09.2003  LKJ       Bugfix in circular reference .
** 26.04.2004  DN        Function getValueFromFormula: rewrote cursor to join with stream.
** 11.06.2004  EOL       Fixed getNetStdMass and getGrsStdMass.
** 03.08.2004  kaurrnar  removed sysnam and stream_code and update as necessary
** 07.12.2004  ROV       Tracker #1832: Updated getValueFromFormula to deal with change in formula within interval [p_fromday,p_today]
** 07.12.2004  ROV       Tracker #1832: Fixed a bug in the cursor sql in function getValueFromFormula
** 22.12.2004  ROV       Tracker #1875: Added missing NVL handling of parameter p_today in EcDp_Stream_Formula.getValueFromFormula
** 01.03.2005  kaurrnar	 Removed references to ec_xxx_attribute packages
** 28.04.2005  ROV       Tracker #2165: Robustified method replaceItem when dealing with dates. Added to_date(to_char conversion.
** 03.08.2005  chongjer  Tracker #2427: Limitation in number of variables in equation. Increased evaluateFormula's lv2_formula size.
** 15.11.2005  Ron Boh	 Tracker #2160: Add NVL Function to the Formula Editor
** 20.12.2005  DN        Added getNextFormula amd getPreviousFormula.
** 02.10.2006  MOT       #4460: Added Zero function. evaluateFormula extendend to support this.
** 08.11.2006  kaurrnar  Tracker #4723: Increase stringbuffer for formula variable in evaluateFormula function.
** 23.08.2007  rajarsar  ECPD-6246: Added getEnergy.
** 03.03.2008  rajarsar  ECPD-7127: Added getPowerConsumption.
** 26.08.2008  aliassit	 ECPD-9080: Added p_stream_id in function evaluateMethod and replaceItem
** 28.08.2008  amirrasn	 ECPD-10156: Function getValueFromFormula: Added p_object_id in evaluateFormula function.
** 31.12.2008  sharawan  ECPD-10416:Replaced all references to EcDp_Type.pb_comp_number%TYPE with NUMBER in functions
**                       getNetStdVol, getGrsStdVol, getNetStdMass, getGrsStdMass, getEnergy, getPowerConsumption, checkCircularReference.
** 09.02.2009  farhaann  ECPD-10761: Modified function evaluateFormula: Handle 'NULL'
** 11.04.2011  musthram  ECPD-16877: Added function getGCV
** 02.12.2011  abdulmaw  ECPD-18147: Updated function evaluateFormula
** 30.07.2012  abdulmaw  ECPD-21535: Updated function evaluateFormula to fix Monthly Stream calculation
** 22.10.2013  musthram  ECPD-25553: Updated function evaluateFormula to fix formula calculation for Monthly
** 23.02.2016  khatrnit ECPD-31464: Added getLastAvailableFormula returns incorrect formula for current day
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getNetStdVol
-- Description  : Calculate net standard vol for a stream in a given period.
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables:
--
-- Using functions: getValueFromFormula
--
-- Configuration
-- required:        Configuration in STRM_FORMULA and STRM_FORMULA_ITEM table.
--
-- Behaviour
--
---------------------------------------------------------------------------------------------------
FUNCTION getNetStdVol (
     p_object_id     stream.object_id%TYPE,
     p_fromday       DATE,
     p_today         DATE)


RETURN NUMBER
--</EC-DOC>
IS

ln_return_val NUMBER;

BEGIN

   ln_return_val := getValueFromFormula(
					p_object_id,
                                        p_fromday,
					p_today,
					'NET_VOL_METHOD');

   RETURN ln_return_val;



END getNetStdVol;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getGrsStdVol
-- Description  : Calculate gross standard volume for a stream in a given period.
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables:
--
-- Using functions: getValueFromFormula
--
-- Configuration
-- required:        Configuration in STRM_FORMULA and STRM_FORMULA_ITEM table.
--
-- Behaviour
--
---------------------------------------------------------------------------------------------------
FUNCTION getGrsStdVol (
     p_object_id     stream.object_id%TYPE,
     p_fromday       DATE,
     p_today         DATE)


RETURN NUMBER
--</EC-DOC>
IS

ln_return_val NUMBER;

BEGIN

   ln_return_val := getValueFromFormula(
                                        p_object_id,
                                        p_fromday,
                                        p_today,
                                        'GRS_VOL_METHOD');

   RETURN ln_return_val;

END getGrsStdVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getNetStdMass
-- Description  : Calculate net standard mass for a stream in a given period.
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables:
--
-- Using functions: getValueFromFormula
--
-- Configuration
-- required:        Configuration in STRM_FORMULA and STRM_FORMULA_ITEM table.
--
-- Behaviour
--
---------------------------------------------------------------------------------------------------
FUNCTION getNetStdMass (
     p_object_id     stream.object_id%TYPE,
     p_fromday       DATE,
     p_today         DATE)


RETURN NUMBER
--</EC-DOC>
IS

ln_return_val NUMBER;

BEGIN

   ln_return_val := getValueFromFormula(
					p_object_id,
					p_fromday,
					p_today,
					'NET_MASS_METHOD');

   RETURN ln_return_val;

END getNetStdMass;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getGrsStdMass
-- Description  : Calculate gross standard mass for a stream in a given period.
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables:
--
-- Using functions: getValueFromFormula
--
-- Configuration
-- required:        Configuration in STRM_FORMULA and STRM_FORMULA_ITEM table.
--
-- Behaviour
--
---------------------------------------------------------------------------------------------------
FUNCTION getGrsStdMass (
     p_object_id     stream.object_id%TYPE,
     p_fromday       DATE,
     p_today         DATE)


RETURN NUMBER
--</EC-DOC>
IS

ln_return_val NUMBER;

BEGIN

   ln_return_val := getValueFromFormula(
					p_object_id,
					p_fromday,
					p_today,
					'GRS_MASS_METHOD');

   RETURN ln_return_val;

END getGrsStdMass;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getEnergy
-- Description  : Calculate Energy for a stream in a given period.
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables:
--
-- Using functions: getValueFromFormula
--
-- Configuration
-- required:        Configuration in STRM_FORMULA and STRM_FORMULA_ITEM table.
--
-- Behaviour
--
---------------------------------------------------------------------------------------------------
FUNCTION getEnergy (
     p_object_id     stream.object_id%TYPE,
     p_fromday       DATE,
     p_today         DATE)


RETURN NUMBER
--</EC-DOC>
IS

ln_return_val NUMBER;

BEGIN

   ln_return_val := getValueFromFormula(
					p_object_id,
					p_fromday,
					p_today,
					'ENERGY_METHOD');

   RETURN ln_return_val;

END getEnergy;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getPowerConsumption
-- Description  : Calculate Energy for a stream in a given period.
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables:
--
-- Using functions: getValueFromFormula
--
-- Configuration
-- required:        Configuration in STRM_FORMULA and STRM_FORMULA_ITEM table.
--
-- Behaviour
--
---------------------------------------------------------------------------------------------------
FUNCTION getPowerConsumption (
     p_object_id     stream.object_id%TYPE,
     p_fromday       DATE,
     p_today         DATE)


RETURN NUMBER
--</EC-DOC>
IS

ln_return_val NUMBER;

BEGIN

   ln_return_val := getValueFromFormula(
					p_object_id,
					p_fromday,
					p_today,
					'POWER_METHOD');

   RETURN ln_return_val;

END getPowerConsumption;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getValueFromFormula
-- Description  : Find associated formulas active for the method and period and
-- 	              evaluate the formula(s).
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables:    strm_formula,stream
--
-- Using functions:  evaluateFormula
--
-- Configuration
-- required:        Configuration in STRM_FORMULA and STRM_FORMULA_ITEM table.
--
-- Behaviour
--
---------------------------------------------------------------------------------------------------
FUNCTION  getValueFromFormula(
     p_object_id     stream.object_id%TYPE,
     p_fromday       DATE,
     p_today         DATE,
     p_method        VARCHAR2
   )

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_formula
IS
SELECT s.daytime,s.formula_no, s.formula
FROM strm_formula s, stream st
WHERE s.daytime <= NVL(p_today,p_fromday)
AND s.object_id = st.object_id
AND st.object_id = p_object_id
AND s.formula_method = p_method
ORDER BY daytime desc;

ln_return_val NUMBER;
li_flag INTEGER;
ld_interval_start DATE;
ld_interval_end DATE;


BEGIN

  ln_return_val := NULL;
  li_flag := NULL;

  FOR cur_formula IN c_formula
    LOOP

      ld_interval_start := greatest(p_fromday,cur_formula.daytime);

	IF li_flag is NULL THEN-- first iteration
		ln_return_val := evaluateFormula(cur_formula.formula_no,
							cur_formula.formula,
							ld_interval_start,
							NVL(p_today,p_fromday),p_object_id);

		li_flag := 1;
		ld_interval_end := ld_interval_start -1;
	ELSE

		IF((ld_interval_start >= p_fromday) AND (ld_interval_start <= ld_interval_end)) THEN
			ln_return_val := ln_return_val + evaluateFormula(cur_formula.formula_no,
			cur_formula.formula,
			ld_interval_start,
			ld_interval_end,
			p_object_id);

			ld_interval_end := ld_interval_start -1;
		ELSE
			EXIT; -- LOOP
		END IF;
	END IF;

  END LOOP;

  RETURN ln_return_val;

END getValueFromFormula;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : evaluateFormula
-- Description  : Build an expression from a stream formula and execute it using dynamic SQL.
--
-- Preconditions:  Version 8 or later of ORACLE is required to use 'EXECUTE IMMEDIATE'.
-- Postcondition:
--
-- Using Tables:
--
-- Using functions: replaceItem
--
-- Configuration
-- required:         Configuration in STRM_FORMULA and STRM_FORMULA_ITEM table.
--
-- Behaviour
--
---------------------------------------------------------------------------------------------------
FUNCTION evaluateFormula(
   p_formula_id     VARCHAR2,
   p_formula        VARCHAR2,
   p_fromday		  DATE,
   p_today          DATE,
   p_stream_id	VARCHAR2 DEFAULT NULL
)

RETURN NUMBER
--</EC-DOC>
IS

li_len INTEGER;
li_pos INTEGER;
li_days INTEGER;
li_num INTEGER;
ln_return_val NUMBER;
lv2_char VARCHAR2(1);
lv2_nvl_char VARCHAR2(4);
lv2_zero_char VARCHAR2(5);
lv2_null_char VARCHAR2(5);
lv2_formula VARCHAR2(10000);
lv2_except VARCHAR2(1);
lv2_strm_meter_freq VARCHAR2(300);

BEGIN

	-- Find this streams strm_meter_freq
	lv2_strm_meter_freq := NVL(ec_strm_version.strm_meter_freq(p_stream_id, p_fromday, '<='),'');

	li_len := LENGTH( p_formula );
	li_pos := 1;
	li_num := 0;
	lv2_except := 'N';

	IF li_len > 0 THEN

	  -- Replace all characters in A..Z with evaluation expression.
    	  -- If encounter NVL( then the formula will be interpreted as the NVL(*,*) function

		LOOP

        		lv2_char := UPPER(SUBSTR(p_formula, li_pos, 1 ));
        		lv2_nvl_char := UPPER(SUBSTR( p_formula, li_pos, 3 ));
				lv2_zero_char := UPPER(SUBSTR( p_formula, li_pos, 4 ));
				lv2_null_char := UPPER(SUBSTR( p_formula, li_pos, 4 ));

	      		IF lv2_char >= 'A' AND lv2_char <= 'Z' THEN

           			IF lv2_nvl_char = 'NVL' THEN
                			lv2_formula := lv2_formula || 'NVL';
                			li_pos := li_pos + 3;
           			ELSIF lv2_zero_char = 'ZERO' THEN
							--Zero(a,b) is a function in this package
							lv2_formula := lv2_formula || 'ECDP_STREAM_FORMULA.ZERO';
                			li_pos := li_pos + 4;
					ELSIF lv2_null_char = 'NULL' THEN
							lv2_formula := lv2_formula || 'NULL';
                			li_pos := li_pos + 4;
					ELSE
	    	        		lv2_formula := lv2_formula || ecdp_stream_formula.replaceItem(p_formula_id, lv2_char, p_fromday, p_today, p_stream_id);
                			li_pos := li_pos + 1;
           			END IF;

				ELSIF lv2_char >= '0' AND lv2_char <= '9' THEN

					IF li_num = 0 AND p_fromday <> p_today AND lv2_except <> 'Y' AND lv2_strm_meter_freq <> 'MTH' THEN
							li_days := p_today - p_fromday;
							--a constant needs to be multiply by days (eg: A + (days) * 10)
							lv2_formula := lv2_formula || (li_days+1) || '*' || lv2_char;
							li_num := li_num || lv2_char;
							li_pos := li_pos + 1;
					ELSE
							lv2_formula := lv2_formula || lv2_char;
							li_pos := li_pos + 1;
					END IF;

	      		ELSE

					lv2_formula := lv2_formula || lv2_char;
           			li_pos := li_pos + 1;
					li_num := 0;

					IF lv2_char = '*' OR lv2_char = '/' THEN
							lv2_except := 'Y';               -- to indicate that this constant does not need to be multiply by days
					ELSIF lv2_char = '+' OR lv2_char = '-' THEN
							lv2_except := 'N';               -- to indicate that this constant need to be multiply by days
					END IF;

        		END IF;

        		EXIT WHEN li_pos > li_len;

    		END LOOP;

	END IF;

	lv2_formula := 'select ' || lv2_formula || ' from dual';

	-- Execute and calculate expression.
  EXECUTE IMMEDIATE lv2_formula INTO ln_return_val;

  RETURN ln_return_val;

EXCEPTION

   WHEN OTHERS THEN
      RETURN NULL;

END evaluateFormula;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : replaceItem
-- Description  : Building evaluation expression for one item in a stream formula.
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables:  Strm_formula_item
--
-- Using functions: EcBp_Stream_Formula.evaluatemethod
--
-- Configuration
-- required:        Configuration in STRM_FORMULA and STRM_FORMULA_VARIABLE table.
--
-- Behaviour
--
---------------------------------------------------------------------------------------------------
FUNCTION replaceItem(
   p_formula_no     VARCHAR2,
   p_variable_name  VARCHAR2,
   p_fromday        DATE,
   p_today          DATE,
   p_stream_id	VARCHAR2 DEFAULT NULL
   )

RETURN VARCHAR2
--</EC-DOC>
IS

	lv2_item_text VARCHAR2(2000);

	CURSOR c_items
	IS
	SELECT *
	FROM strm_formula_variable s
	WHERE s.formula_no = p_formula_no
	AND s.variable_name = p_variable_name;

BEGIN
   FOR cur_items IN c_items LOOP -- Only expecting one row
       -- Build evaluation expression
       lv2_item_text := ' ecbp_stream_formula.evaluatemethod('
           || CHR(39) ||
           cur_items.class_name  || CHR(39) || ',' || CHR(39) ||
           cur_items.object_id   || CHR(39) || ',' || CHR(39) ||
           cur_items.object_method      || CHR(39) || ',' ||
           'to_date(' || CHR(39) || to_char(p_fromday, 'dd.mm.yyyy hh24:mi:ss') || CHR(39) || ',' || CHR(39) || 'dd.mm.yyyy hh24:mi:ss' || CHR(39) || '),' ||
           'to_date(' || CHR(39) || to_char(p_today, 'dd.mm.yyyy hh24:mi:ss') || CHR(39) || ',' || CHR(39) || 'dd.mm.yyyy hh24:mi:ss' || CHR(39) || '),'
		   || CHR(39) || p_stream_id || CHR(39) || ')';
      EXIT; -- Loop
	END LOOP;

RETURN lv2_item_text;

EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;

END replaceItem;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : checkCircularReference
-- Description  :
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables:
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour          Return values  O = OK
--                                  -1 = Circular reference
--                                  -2 = No method found for given daytime
--
---------------------------------------------------------------------------------------------------
FUNCTION checkCircularReference  (p_daytime            DATE,
                                  p_member_object_id   VARCHAR2,
                                  p_member_method      VARCHAR2,
                                  p_orig_object_id     VARCHAR2,
                                  p_orig_method        VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS

-- Cursor to get stream objects connected in a given formula
CURSOR  c_objects is
SELECT  sf.daytime,
        sfv.object_id,
        translateStrmMethods(sfv.object_method) as method
  FROM  strm_formula sf,
        strm_formula_variable sfv
 WHERE  sf.daytime = (
          SELECT  max(sf2.daytime)
            FROM  strm_formula sf2,
                  strm_formula_variable sfv2
           WHERE
                  sf2.daytime       >= p_daytime
           AND    sf2.object_id      = sf.object_id
           AND    sf2.formula_method = sf.formula_method
        )
 AND    sf.formula_no = sfv.formula_no
 AND    sf.object_id = p_member_object_id
 AND    sf.formula_method = translateStrmMethods (p_member_method)
 AND    sfv.class_name in (select code from prosty_codes pc where pc.code_type = 'STRM_FORMULA_CLASS')
  ;


li_return      NUMBER;
ls_strm_method VARCHAR2(32);
lv2_member_method VARCHAR2(32);

BEGIN

  -- Inititial value is set to 0
  li_return := 0;

 lv2_member_method := translateStrmMethods (p_member_method);
  -- Get method on stream

  IF lv2_member_method = 'GRS_VOL_METHOD' THEN
  	ls_strm_method := ec_strm_version.GRS_VOL_METHOD(p_member_object_id,
                                                     	p_daytime,
                                                     	'<=');

  ELSIF lv2_member_method = 'NET_VOL_METHOD' THEN
  	ls_strm_method := ec_strm_version.NET_VOL_METHOD(p_member_object_id,
                                                     	p_daytime,
                                                     	'<=');

  ELSIF lv2_member_method = 'GRS_MASS_METHOD' THEN
  	ls_strm_method := ec_strm_version.GRS_MASS_METHOD(p_member_object_id,
                                                     	p_daytime,
                                                     	'<=');

  ELSIF lv2_member_method = 'NET_MASS_METHOD' THEN
  	ls_strm_method := ec_strm_version.NET_MASS_METHOD(p_member_object_id,
                                                     	p_daytime,
                                                     	'<=');

  END IF;

  -- method not defined for daytime
  IF ls_strm_method IS NULL THEN
     li_return := 0;

  -- Check method on strm_object and
  -- match current object ID and method with original object ID and method.
  -- If they all are identical and stream method = FORMULA => Circular reference
  ELSIF ls_strm_method = 'FORMULA' AND lv2_member_method = p_orig_method AND p_member_object_id = p_orig_object_id	THEN
     -- found circular reference!
     li_return := -1;

  ELSE
      -- Call recursively for all stream objects connected in stream formula
     FOR mycur IN c_objects LOOP

        li_return := checkCircularReference(p_daytime,
                                            mycur.object_id,
                                            mycur.method,
                                            p_orig_object_id,
                                            p_orig_method);

        IF li_return <> 0 THEN
           RETURN li_return;
        END IF;

  	 END LOOP;

  END IF;

  -- Return value
  RETURN li_return;

-- End function
END checkCircularReference;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : translateStrmMethods
-- Description  :
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables:
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour
--
--
---------------------------------------------------------------------------------------------------
FUNCTION translateStrmMethods (p_method VARCHAR2) RETURN VARCHAR2
--</EC-DOC>
IS

lv2_return_val varchar2(32);

BEGIN

     if p_method = 'GRS_VOL' then
        lv2_return_val := 'GRS_VOL_METHOD';

     elsif p_method = 'NET_VOL' then
        lv2_return_val := 'NET_VOL_METHOD';

     elsif p_method = 'GRS_MASS' then
        lv2_return_val := 'GRS_MASS_METHOD';

     elsif p_method = 'NET_MASS' then
        lv2_return_val := 'NET_MASS_METHOD';

     else
        lv2_return_val := p_method;

     end if;

     return lv2_return_val;

END translateStrmMethods;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getNextFormula
-- Description  :  Returns the next formula record according to a date for a given stream and method.
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: strm_formula
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour
--
--
---------------------------------------------------------------------------------------------------
FUNCTION getNextFormula (
     p_object_id stream.object_id%TYPE,
     p_formula_method         VARCHAR2,
     p_daytime                    DATE)
RETURN strm_formula%ROWTYPE
--</EC-DOC>
IS

CURSOR c_strm_formula(cp_object_id VARCHAR2, cp_formula_method VARCHAR2, cp_daytime DATE) IS
SELECT * FROM strm_formula sf
WHERE sf.object_id = cp_object_id
AND sf.formula_method = cp_formula_method
AND sf.daytime = (
   SELECT MIN(sfm.daytime)
   FROM strm_formula sfm
   WHERE sfm.object_id =  sf.object_id
   AND sfm.formula_method = sf.formula_method
   AND sfm.daytime > cp_daytime
);

lr_strm_formula strm_formula%ROWTYPE;

BEGIN

   FOR cur_rec IN c_strm_formula(p_object_id, p_formula_method, p_daytime) LOOP

      lr_strm_formula := cur_rec;

   END LOOP;

   RETURN lr_strm_formula;

END getNextFormula;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getPreviousFormula
-- Description  : Returns the previous formula record according to a date for a given stream and method.
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: strm_formula
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour
--
--
---------------------------------------------------------------------------------------------------
FUNCTION getPreviousFormula (
     p_object_id stream.object_id%TYPE,
     p_formula_method         VARCHAR2,
     p_daytime                    DATE)
RETURN strm_formula%ROWTYPE
--</EC-DOC>
IS

CURSOR c_strm_formula(cp_object_id VARCHAR2, cp_formula_method VARCHAR2, cp_daytime DATE) IS
SELECT * FROM strm_formula sf
WHERE sf.object_id = cp_object_id
AND sf.formula_method = cp_formula_method
AND sf.daytime = (
   SELECT MAX(sfm.daytime)
   FROM strm_formula sfm
   WHERE sfm.object_id =  sf.object_id
   AND sfm.formula_method = sf.formula_method
   AND sfm.daytime < cp_daytime
);

lr_strm_formula strm_formula%ROWTYPE;

BEGIN

   FOR cur_rec IN c_strm_formula(p_object_id, p_formula_method, p_daytime) LOOP

      lr_strm_formula := cur_rec;

   END LOOP;

   RETURN lr_strm_formula;


END getPreviousFormula;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getLastAvailableFormulaFormula
-- Description  : Returns the previous formula record according to a date for a given stream and method.
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: strm_formula
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour
--
--
---------------------------------------------------------------------------------------------------
FUNCTION getLastAvailableFormula (
     p_object_id stream.object_id%TYPE,
     p_formula_method         VARCHAR2,
     p_daytime                    DATE)
RETURN strm_formula%ROWTYPE
--</EC-DOC>
IS

CURSOR c_strm_formula(cp_object_id VARCHAR2, cp_formula_method VARCHAR2, cp_daytime DATE) IS
SELECT * FROM strm_formula sf
WHERE sf.object_id = cp_object_id
AND sf.formula_method = cp_formula_method
AND sf.daytime = (
   SELECT MAX(sfm.daytime)
   FROM strm_formula sfm
   WHERE sfm.object_id =  sf.object_id
   AND sfm.formula_method = sf.formula_method
   AND sfm.daytime <= cp_daytime
);

lr_strm_formula strm_formula%ROWTYPE;

BEGIN

   FOR cur_rec IN c_strm_formula(p_object_id, p_formula_method, p_daytime) LOOP

      lr_strm_formula := cur_rec;

   END LOOP;

   RETURN lr_strm_formula;


END getlastAvailableFormula;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getGCV
-- Description  : Calculate GCV for a stream in a given period.
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables:
--
-- Using functions: getValueFromFormula
--
-- Configuration
-- required:        Configuration in STRM_FORMULA and STRM_FORMULA_ITEM table.
--
-- Behaviour
--
---------------------------------------------------------------------------------------------------
FUNCTION getGCV (
     p_object_id     stream.object_id%TYPE,
     p_fromday       DATE,
     p_today         DATE)


RETURN NUMBER
--</EC-DOC>
IS

ln_return_val NUMBER;

BEGIN

   ln_return_val := getValueFromFormula(
					p_object_id,
					p_fromday,
					p_today,
					'GCV_METHOD');

   RETURN ln_return_val;

END getGCV;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : ZERO
-- Description  :  Return parameter b if parameter a is 0.
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables:
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour
--
--
---------------------------------------------------------------------------------------------------
FUNCTION zero(p_a NUMBER, p_b NUMBER) RETURN NUMBER
--</EC-DOC>
IS

BEGIN
     IF p_a = 0 THEN
        RETURN p_b;
     END IF;

     RETURN p_a;
END zero;


-- End package
END EcDp_Stream_Formula;