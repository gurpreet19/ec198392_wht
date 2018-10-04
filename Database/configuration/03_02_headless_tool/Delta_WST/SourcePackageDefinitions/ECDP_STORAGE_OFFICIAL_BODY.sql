CREATE OR REPLACE PACKAGE BODY EcDp_Storage_Official IS
/****************************************************************
** Package        :  EcDp_Storage_Official; body part
**
** $Revision: 1.4 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created        :  07.09.2006	Kari Sandvik
**
** Modification history:
**
** Date        Whom  	Change description:
** ----------  ----- 	-------------------------------------------
** 18.12.2013  leeeewei	ECPD-25944: Added new function getStorDayAverage
******************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDay
-- Description    : Retreives the daily official number.
--				  : If official type is set only the number for that type is returned. Null if no value exist for the selected type
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :  stor_day_official
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

FUNCTION getDay(p_object_id VARCHAR2,
				p_daytime DATE,
				p_official_type VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_official(cp_object_id VARCHAR2, cp_daytime DATE)IS
	SELECT official_qty, official_type
	FROM   stor_day_official
	WHERE  object_id = cp_object_id
	      AND daytime = cp_daytime;

ln_official_qty	NUMBER := NULL;

BEGIN
	FOR curOfficial IN c_official (p_object_id, p_daytime) LOOP
		IF p_official_type IS NOT NULL AND p_official_type = curOfficial.official_type THEN
			ln_official_qty := curOfficial.official_qty;
		ELSE
			ln_official_qty := curOfficial.official_qty;
		END IF;
	END LOOP;

	RETURN ln_official_qty;

END getDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalMonth
-- Description    : Retreives the total official number for the month.
--				  : If official type is set only the total for that type is returned
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :  stor_day_official
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

FUNCTION getTotalMonth(p_object_id VARCHAR2,
				p_daytime DATE,
        		p_xtra_qty NUMBER DEFAULT 0,
				p_official_type VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_all(cp_object_id VARCHAR2, cp_from DATE, cp_to DATE) IS
  SELECT SUM(official_qty) official_qty,
         SUM(official_qty2) official_qty2,
         SUM(official_qty3) official_qty3
    FROM stor_day_official
   WHERE object_id = cp_object_id
     AND object_id = cp_object_id
     AND daytime >= cp_from
     AND daytime < cp_to;

CURSOR c_type(cp_object_id VARCHAR2, cp_from DATE, cp_to DATE, cp_official_type VARCHAR2) IS
  SELECT SUM(official_qty) official_qty,
         SUM(official_qty2) official_qty2,
         SUM(official_qty3) official_qty3
    FROM stor_day_official
   WHERE object_id = cp_object_id
     AND daytime >= cp_from
     AND daytime < cp_to
     AND official_type = cp_official_type;

ln_official_qty			NUMBER := NULL;
ld_first_of_next_month 	DATE;

BEGIN
	ld_first_of_next_month := add_months(p_daytime, 1);

	IF p_official_type IS NOT NULL THEN
		FOR curType IN c_type (p_object_id, p_daytime, ld_first_of_next_month, p_official_type) LOOP
      		IF p_xtra_qty = 1 THEN
			   ln_official_qty := curType.official_qty2;
      		ELSIF p_xtra_qty = 2 THEN
         	   ln_official_qty := curType.official_qty3;
      		ELSE
         	   ln_official_qty := curType.official_qty;
      		END IF;
		END LOOP;
	ELSE
		FOR curAll IN c_all (p_object_id, p_daytime, ld_first_of_next_month) LOOP
			IF p_xtra_qty = 1 THEN
			   ln_official_qty := curAll.official_qty2;
      		ELSIF p_xtra_qty = 2 THEN
         	   ln_official_qty := curAll.official_qty3;
      		ELSE
         	   ln_official_qty := curAll.official_qty;
      		END IF;
		END LOOP;
	END IF;

	RETURN ln_official_qty;

END getTotalMonth;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : aggregateSubDay
-- Description    : Sums up hourly nomination quantities and stores the result in the daily data table.
--
-- Preconditions  : p_daytime should be production day. Daily record must exist before sub daily record
-- Postconditions :
--
-- Using tables   : stor_sub_day_official
--                  stor_day_official
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Finds the sum of all the sub-daily quantities for the given day. The resulting
--                  quantity is written to the daily table.
--
---------------------------------------------------------------------------------------------------
PROCEDURE aggregateSubDay(p_object_id VARCHAR2,
						  p_daytime   DATE,
						  p_xtra_qty  NUMBER DEFAULT 0)
--</EC-DOC>
 IS
	CURSOR c_sum_sub_day(cp_object_id VARCHAR2, cp_daytime DATE) IS
		SELECT SUM(OFFICIAL_QTY) official
		  FROM stor_sub_day_official
		 WHERE object_id = cp_object_id
		   AND production_day = cp_daytime;

	CURSOR c_sum_sub_day2(cp_object_id VARCHAR2, cp_daytime DATE) IS
		SELECT SUM(OFFICIAL_QTY2) official2
		  FROM stor_sub_day_official
		 WHERE object_id = cp_object_id
		   AND production_day = cp_daytime;

  CURSOR c_sum_sub_day3(cp_object_id VARCHAR2, cp_daytime DATE) IS
		SELECT SUM(OFFICIAL_QTY3) official3
		  FROM stor_sub_day_official
		 WHERE object_id = cp_object_id
		   AND production_day = cp_daytime;

	ln_sum_sub_day NUMBER;

BEGIN
	IF (p_xtra_qty = 0) THEN
		FOR curSum IN c_sum_sub_day(p_object_id, p_daytime) LOOP
			ln_sum_sub_day := curSum.official;
		END LOOP;

		UPDATE stor_day_official
		   SET official_qty = ln_sum_sub_day, last_updated_by = ecdp_context.getAppUser
		 WHERE object_id = p_object_id
		   AND daytime = p_daytime;
	ELSIF (p_xtra_qty = 1) THEN
		FOR curSum IN c_sum_sub_day2(p_object_id, p_daytime) LOOP
			ln_sum_sub_day := curSum.official2;
		END LOOP;

		UPDATE stor_day_official
		   SET official_qty2 = ln_sum_sub_day, last_updated_by = ecdp_context.getAppUser
		 WHERE object_id = p_object_id
		   AND daytime = p_daytime;
	ELSIF (p_xtra_qty = 2) THEN
		FOR curSum IN c_sum_sub_day3(p_object_id, p_daytime) LOOP
			ln_sum_sub_day := curSum.official3;
		END LOOP;

		UPDATE stor_day_official
		   SET official_qty3 = ln_sum_sub_day, last_updated_by = ecdp_context.getAppUser
		 WHERE object_id = p_object_id
		   AND daytime = p_daytime;
	END IF;
END aggregateSubDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getStorDayAverage
-- Description    : returns daily average of official qty for a given month
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : stor_day_official
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getStorDayAverage(p_storage_id     VARCHAR2,
                           p_first_of_month DATE,
                           p_xtra_qty NUMBER DEFAULT 0,
                           p_official_type  VARCHAR2 DEFAULT NULL)
  RETURN NUMBER
--</EC-DOC>
 IS
  CURSOR c_official_all(cp_storage_id VARCHAR2,cp_first_of_month DATE,cp_first_of_next_month DATE) IS
    SELECT avg(t.official_qty) avg_official_qty,
           avg(t.official_qty2) avg_official_qty2,
           avg(t.official_qty3) avg_official_qty3
      FROM stor_day_official t
     WHERE t.object_id = cp_storage_id
       AND t.daytime >= cp_first_of_month
       AND t.daytime < cp_first_of_next_month;

  CURSOR c_official(cp_storage_id VARCHAR2,cp_first_of_month DATE,cp_first_of_next_month DATE,cp_official_type VARCHAR2) IS
    SELECT avg(t.official_qty) avg_official_qty,
           avg(t.official_qty2) avg_official_qty2,
           avg(t.official_qty3) avg_official_qty3
      FROM stor_day_official t
     WHERE t.object_id = cp_storage_id
       AND t.daytime >= cp_first_of_month
       AND t.daytime < cp_first_of_next_month
       AND t.official_type = cp_official_type;

  ln_day_average         NUMBER := -1;
  ld_first_of_next_month DATE;

BEGIN
  ld_first_of_next_month := add_months(p_first_of_month, 1);

  IF p_official_type IS NOT NULL THEN
    FOR curOfficial IN c_official(p_storage_id,p_first_of_month,ld_first_of_next_month,p_official_type) LOOP
      IF p_xtra_qty = 1 THEN
        ln_day_average := curOfficial.avg_official_qty2;
      ELSIF p_xtra_qty = 2 THEN
        ln_day_average := curOfficial.avg_official_qty3;
      ELSE
        ln_day_average := curOfficial.avg_official_qty;
      END IF;
    END LOOP;
  ELSE
    FOR curAll IN c_official_all(p_storage_id,p_first_of_month,ld_first_of_next_month) LOOP
      IF p_xtra_qty = 1 THEN
        ln_day_average := curAll.avg_official_qty2;
      ELSIF p_xtra_qty = 2 THEN
        ln_day_average := curAll.avg_official_qty3;
      ELSE
        ln_day_average := curAll.avg_official_qty;
      END IF;
    END LOOP;
  END IF;

  RETURN ln_day_average;

END getStorDayAverage;

END EcDp_Storage_Official;