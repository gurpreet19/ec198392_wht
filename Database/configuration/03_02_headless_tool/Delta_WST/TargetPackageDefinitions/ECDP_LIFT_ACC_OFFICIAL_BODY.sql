CREATE OR REPLACE PACKAGE BODY EcDp_Lift_Acc_Official IS
/****************************************************************
** Package        :  EcDp_Lift_Acc_Official; body part
**
** $Revision: 1.5 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created        :  07.09.2006  Kari Sandvik
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------
******************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDay
-- Description    : Retreives the daily official number.
--          : If official type is set only the number for that type is returned. Null if no value exist for the selected type
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :  lift_acc_day_official
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
  SELECT official_qty, official_qty2, official_qty3, official_type
  FROM   lift_acc_day_official
  WHERE  object_id = cp_object_id
        AND daytime = cp_daytime;

ln_official_qty  NUMBER := NULL;

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
--          : If official type is set only the total for that type is returned.. Null if none exist
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :  lift_acc_day_official
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
        p_official_type VARCHAR2 DEFAULT NULL,
        p_xtra_qty NUMBER DEFAULT 0)
RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_all(cp_object_id VARCHAR2, cp_from DATE, cp_to DATE, cp_xtra_qty NUMBER) IS
  SELECT decode(cp_xtra_qty, 0,  SUM(official_qty), 1, SUM(official_qty2), 2, SUM(official_qty3))  official_qty
  FROM   lift_acc_day_official
  WHERE  object_id = cp_object_id
        AND object_id = cp_object_id
        AND daytime >= cp_from
        AND daytime < cp_to;

CURSOR c_type(cp_object_id VARCHAR2, cp_from DATE, cp_to DATE, cp_official_type VARCHAR2, cp_xtra_qty NUMBER) IS
  SELECT decode(cp_xtra_qty, 0,  SUM(official_qty), 1, SUM(official_qty2), 2, SUM(official_qty3)) official_qty
  FROM   lift_acc_day_official
  WHERE  object_id = cp_object_id
        AND daytime >= cp_from
        AND daytime < cp_to
        AND official_type = cp_official_type;

ln_official_qty      NUMBER := NULL;
ld_fist_of_next_month   DATE;

BEGIN
  ld_fist_of_next_month := add_months(p_daytime, 1);

  IF p_official_type IS NOT NULL THEN
    FOR curType IN c_type (p_object_id, p_daytime, ld_fist_of_next_month, p_official_type, p_xtra_qty) LOOP
      ln_official_qty := curType.official_qty;
    END LOOP;
  ELSE
    FOR curAll IN c_all (p_object_id, p_daytime, ld_fist_of_next_month, p_xtra_qty) LOOP
      ln_official_qty := curAll.official_qty;
    END LOOP;
  END IF;

  RETURN ln_official_qty;

END getTotalMonth;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : IsMissingOfficialNumbers
-- Description    : Returns 'Y' if there are no numbers where official type = OFFICIAL for the month
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
FUNCTION IsMissingOfficialNumbers(p_object_id VARCHAR2,
                p_daytime DATE)
RETURN VARCHAR2
--</EC-DOC>
IS
  ln_count    NUMBER;
BEGIN

  SELECT count(*)
  INTO ln_count
  FROM lift_acc_day_official
  WHERE object_id = p_object_id
  AND daytime BETWEEN TRUNC(p_daytime,'mm') AND LAST_DAY(p_daytime)
  AND official_type = 'OFFICIAL';

  IF ln_count < TO_NUMBER(TO_CHAR(LAST_DAY(p_daytime),'dd')) THEN
    RETURN 'Y';
  ELSE
    RETURN 'N';
  END IF;

END IsMissingOfficialNumbers;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : aggregateSubDay
-- Description    : Sums up hourly nomination quantities and stores the result in the daily data table.
--
-- Preconditions  : p_daytime should be production day. Daily record must exist before sub daily record
-- Postconditions :
--
-- Using tables   : lift_acc_sub_day_official
--                  lift_acc_day_official
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
      FROM lift_acc_sub_day_official
     WHERE object_id = cp_object_id
       AND production_day = cp_daytime;

  CURSOR c_sum_sub_day2(cp_object_id VARCHAR2, cp_daytime DATE) IS
    SELECT SUM(OFFICIAL_QTY2) official2
      FROM lift_acc_sub_day_official
     WHERE object_id = cp_object_id
       AND production_day = cp_daytime;

  CURSOR c_sum_sub_day3(cp_object_id VARCHAR2, cp_daytime DATE) IS
    SELECT SUM(OFFICIAL_QTY3) official3
      FROM lift_acc_sub_day_official
     WHERE object_id = cp_object_id
       AND production_day = cp_daytime;
  ln_sum_sub_day NUMBER;

BEGIN
  IF (p_xtra_qty = 0) THEN
    FOR curSum IN c_sum_sub_day(p_object_id, p_daytime) LOOP
      ln_sum_sub_day := curSum.official;
    END LOOP;

    UPDATE lift_acc_day_official
       SET official_qty = ln_sum_sub_day, last_updated_by = ecdp_context.getAppUser
     WHERE object_id = p_object_id
       AND daytime = p_daytime;
  ELSIF (p_xtra_qty = 1) THEN
    FOR curSum IN c_sum_sub_day2(p_object_id, p_daytime) LOOP
      ln_sum_sub_day := curSum.official2;
    END LOOP;

    UPDATE lift_acc_day_official
       SET official_qty2 = ln_sum_sub_day, last_updated_by = ecdp_context.getAppUser
     WHERE object_id = p_object_id
       AND daytime = p_daytime;

  ELSIF (p_xtra_qty = 2) THEN
    FOR curSum IN c_sum_sub_day3(p_object_id, p_daytime) LOOP
      ln_sum_sub_day := curSum.official3;
    END LOOP;

    UPDATE lift_acc_day_official
       SET official_qty3 = ln_sum_sub_day, last_updated_by = ecdp_context.getAppUser
     WHERE object_id = p_object_id
       AND daytime = p_daytime;
  END IF;
END aggregateSubDay;

END EcDp_Lift_Acc_Official;