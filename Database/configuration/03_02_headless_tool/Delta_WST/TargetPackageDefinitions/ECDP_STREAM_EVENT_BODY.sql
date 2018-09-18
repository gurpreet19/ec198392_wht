CREATE OR REPLACE PACKAGE BODY EcDp_Stream_Event IS
/****************************************************************
** Package        :  EcDp_Stream_Event, body part
**
** $Revision: 1.10 $
**
** Purpose        :  This package is responsible for stream event data access
**
** Documentation  :  www.energy-components.com
**
** Created  : 26.02.2007 Arief Zaki
**
** Modification history:
**
** Date        Whom      Change description:
** ----------  --------  --------------------------------------
** 26.02.2007  zakiiari    First version
** 19.03.2007  Lau         Modified getLastClosingDaytime
** 08.08.2007  chongviv    ECPD-6170: Added verifyperiodtotalizer and approveperiodtotalizer
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validateOverlappingPeriod
-- Description    : Validate that the new entry should not overlap with existing period
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
PROCEDURE validateOverlappingPeriod (
   p_object_id       IN strm_event.object_id%TYPE,
   p_event_type      IN strm_event.event_type%TYPE,
   p_opening_daytime IN strm_event.daytime%TYPE,
   p_closing_daytime IN strm_event.end_date%TYPE)

--</EC-DOC>
IS

  CURSOR c_overlapping_period (cp_object_id strm_event.object_id%TYPE, cp_event_type strm_event.event_type%TYPE, cp_open_date strm_event.daytime%TYPE, cp_close_date strm_event.end_date%TYPE) IS
    SELECT 'X' FROM strm_event t
    WHERE t.object_id = cp_object_id AND
          t.event_type = cp_event_type AND
          (
            (t.daytime <= cp_open_date AND cp_open_date < nvl(t.end_date,t.daytime+1)) OR
            (t.daytime < cp_close_date AND cp_close_date < nvl(t.end_date,t.daytime+1)) OR
            (cp_open_date < nvl(t.end_date,t.daytime+1) and nvl(t.end_date,t.daytime+1) < cp_close_date)
          );

BEGIN

  FOR curStream IN c_overlapping_period(p_object_id, p_event_type, p_opening_daytime, nvl(p_closing_daytime,p_opening_daytime+1)) LOOP
    RAISE_APPLICATION_ERROR(-20000, 'Overlapping period is not allowed.');
  END LOOP;

END validateOverlappingPeriod;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getLastClosingDaytime
-- Description    :
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
FUNCTION getLastClosingDaytime (
   p_object_id       IN strm_event.object_id%TYPE,
   p_event_type      IN strm_event.event_type%TYPE,
   p_to_daytime      IN DATE
)

RETURN DATE
--</EC-DOC>
IS
  ld_return          DATE;

  CURSOR c_last_closing (cp_object_id strm_event.object_id%TYPE, cp_event_type strm_event.event_type%TYPE, cp_to_daytime DATE) IS
    SELECT se.daytime, se.end_date FROM strm_event se
    WHERE se.object_id = cp_object_id AND
          se.event_type = cp_event_type AND
          se.daytime = (SELECT MAX(t.daytime) FROM strm_event t WHERE t.object_id=cp_object_id AND t.event_type=cp_event_type AND t.daytime <= cp_to_daytime);

BEGIN

  FOR cur_closing IN c_last_closing(p_object_id,p_event_type,p_to_daytime) LOOP
    IF cur_closing.end_date IS NULL THEN
      ld_return := cur_closing.daytime + 1;
    ELSE
      ld_return := cur_closing.end_date;
    END IF;
  END LOOP;

  IF ld_return IS NULL THEN
    ld_return := to_date(to_char(ecdp_date_time.getCurrentSysdate,'yyyy/mm/dd hh:mi:am'), 'yyyy/mm/dd hh:mi:am');
  END IF;

  RETURN ld_return;

END getLastClosingDaytime;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : verifyPeriodTotalizer
-- Description    : The Procedure verify the period for the selected stream within the specified period
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : well_period_totalizer
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : -
--
---------------------------------------------------------------------------------------------------
PROCEDURE verifyPeriodTotalizer(p_object_id well.object_id%TYPE,
                         p_class_name VARCHAR2,
                         p_daytime DATE,
                         p_end_date DATE,
                         p_user VARCHAR2)
--</EC-DOC>
IS

ln_exists NUMBER;

lv2_last_update_date VARCHAR2(20);

BEGIN
  lv2_last_update_date := to_char(EcDp_Date_Time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')  ;

    SELECT COUNT(*) INTO ln_exists FROM well_period_totalizer WHERE object_id = p_object_id
    AND class_name = p_class_name
    AND daytime = p_daytime
    AND end_date = p_end_date
    AND record_status='A';

    IF ln_exists = 0 THEN
       UPDATE well_period_totalizer SET record_status='V', last_updated_by = p_user, rev_text = 'Verified at ' ||  lv2_last_update_date
       WHERE object_id = p_object_id
       AND class_name = p_class_name
       AND daytime = p_daytime
       AND end_date = p_end_date;
    ELSE
       RAISE_APPLICATION_ERROR('-20000','Approved record cannot be updated to Verified');
    END IF;

END verifyPeriodTotalizer;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : approvePeriodTotalizer
-- Description    : The Procedure approve the period for the selected stream within the specified period
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : well_period_totalizer
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : -
--
---------------------------------------------------------------------------------------------------
PROCEDURE approvePeriodTotalizer(p_object_id well.object_id%TYPE,
                         p_class_name VARCHAR2,
                         p_daytime DATE,
                         p_end_date DATE,
                         p_user VARCHAR2)
--</EC-DOC>
IS

lv2_last_update_date VARCHAR2(20);

BEGIN
  lv2_last_update_date := to_char(EcDp_Date_Time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')  ;

    UPDATE well_period_totalizer SET record_status='A',last_updated_by = p_user,  rev_text = 'Approved at ' ||  lv2_last_update_date
    WHERE object_id = p_object_id
    AND class_name = p_class_name
    AND daytime = p_daytime
    AND end_date = p_end_date;

END approvePeriodTotalizer;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getOverrideValue
-- Description    : The function get the override value based on the previous day
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : strm_event
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : -
--
---------------------------------------------------------------------------------------------------
FUNCTION getOverrideValue(p_object_id strm_event.object_id%TYPE,
                         p_att_name VARCHAR2,
                         p_event_type VARCHAR2,
                         p_end_date DATE)
RETURN NUMBER
--</EC-DOC>
IS

TYPE cv_type IS REF CURSOR;
cv cv_type;
lv2_sql VARCHAR2(2000);
ld_return NUMBER;

BEGIN
  lv2_sql := 'select '||p_att_name||' from strm_event'||
            ' where object_id = '''||p_object_id||''''||
            ' and event_type = '''||p_event_type||''''||
            ' and daytime = (select max(se2.daytime) from strm_event se2'||
            ' where se2.object_id = '''||p_object_id||''''||
            ' and se2.event_type = '''||p_event_type||''''||
            ' and se2.daytime <= '''||p_end_date||''')';

  OPEN cv FOR lv2_sql;
  LOOP
    FETCH cv INTO ld_return;
    EXIT WHEN cv%NOTFOUND;
  END LOOP;
  CLOSE cv;

  RETURN ld_return;

END getOverrideValue;


END EcDp_Stream_Event;