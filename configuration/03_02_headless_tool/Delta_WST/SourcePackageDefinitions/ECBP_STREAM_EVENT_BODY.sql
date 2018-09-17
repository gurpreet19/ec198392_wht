CREATE OR REPLACE PACKAGE BODY EcBp_Stream_Event IS
/****************************************************************
** Package        :  EcBp_Stream_Event; body part
**
** $Revision: 1.31 $
**
** Purpose        :  Stream event handler
**
** Documentation  :  www.energy-components.com
**
** Created        :  10/28/2004,  TAIPUTOH
**
** Modification history:
**
** Date        Whom      Change description:
** ----------  -------   -------------------------------------------
** 28.10.2004  Toha      Initial Version
** 23.11.2004  DN        Renamed files, formatted code and documentation according to standard.
** 07.07.2005  Jerome    Added procedure setStrmSwapEndDate
** 13.07.2005  Darren    Added procedure setStrmFactorEndDate
** 14.07.2005  Darren    Modification on procedure setStrmFactorEndDate
** 22.07.2005  DN        Table name correction. strm_company_swap.
** 16.08.2005  Jerome    Added procedure swap_instantiate
** 07.09.2005  Ting      TD 4098 Update setStrmFactorEndDate to include checking for end date is the same as previous records
** 01.10.2005  Darren    TD 4404 Fixed validatePeriod to include checking for same event to be excluded from overlapping check
** 13.02.2006  Jerome    TD 5620 Updated setStrmSwapEndDate to only set end date for the same company
** 27.02.2007  zakiiari  ECPD#3649: Updated validatePeriod to include p_within_mth parameter and fixed production-day-month checking. Added approvePeriod and verifyPeriod
** 19.03.2007  Lau       ECPD#2026: Added validatePeriodTotalizer, approvePeriodTotalizer and verifyPeriodTotalizer
** 26.03.2007  Lau       ECPD#2026: Added validateTotalizerMax
** 29.06.2007  rajarsar  ECPD#5689: Updated error message for verifyPeriodTotalizer and validateTotalizerMax.
** 28.09.2007  rajarsar  ECPD#6052: Updated swap_instantiate.
** 22.01.2008  aliassit  ECPD#7291: Modify validatePeriodTotalizer by adding p_event_type to check on hidden END_DATE. Modify validatePeriod by adding
                                    checking for END_DATE - viewhidden <> true to raise overlapping event error.
** 27.06.2008  farhaann  ECPD-8939: Updated ORA number for error messages
** 29.04.2009  leongsei  ECPD-11581: Added checkStreamEventLock to check locking for strm_event
** 17.08.2009  leeeewei  ECPD-11662: Updated ORA error code for error messages and modified second checking in validatePeriod
** 23.05.2012  kumarsur  ECPD-18175: Period Oil Lact Stream (PO.0021) - make validate period configurable
** 11.08.2015  hismahas  ECPD-30929: Updated ORA error code for ValidatePeriod
** 07.08.2017  jainnraj  ECPD-46835: Modified procedure validatePeriod to correct the error message.
**************************************************************************************************/

 --<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validatePeriod
-- Description    : Used to validate stream event periods.
--
-- Preconditions  :
-- Postconditions : Possible unhandled application exceptions
--
-- Using tables   : STRM_EVENT
--
-- Using functions: EcDp_Stream.getStreamFacility
--                  EcDp_Facility.getProductionday
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE validatePeriod(p_object_id stream.object_id%TYPE,
                         p_daytime DATE,
                         p_end_date DATE,
                         p_within_mth CHAR DEFAULT 'YES')
--</EC-DOC>
IS

CURSOR c_exists(cp_object_id stream.object_id%TYPE,
                cp_daytime DATE,
                cp_end_date DATE) IS
  SELECT 1 one FROM strm_event e
   WHERE e.object_id = cp_object_id
     AND e.daytime <> cp_daytime
     AND ((e.daytime < cp_daytime AND cp_daytime < e.end_date)
           OR(e.daytime < cp_end_date AND cp_end_date < e.end_date)
           OR(cp_daytime < e.end_date and e.end_date < cp_end_date));


BEGIN
  -- check no. 1
  FOR mycur IN c_exists(p_object_id, p_daytime, p_end_date) LOOP
    RAISE_APPLICATION_ERROR(-20226, 'An event must not overlap with the existing event period.');
  END LOOP;

  -- check no. 2
  IF UPPER(p_within_mth) = 'YES' THEN
      IF trunc(EcDp_ProductionDay.getProductionDay('STREAM', p_object_id, p_daytime),'MM') <> TRUNC(EcDp_ProductionDay.getProductionDay('STREAM', p_object_id, p_end_date),'MM') THEN
        IF p_end_date > Ecdp_Productionday.getProductionDayStart('STREAM', p_object_id, p_daytime+1)
     		THEN
        		RAISE_APPLICATION_ERROR(-20671, 'An event must not span production month boundaries');
     	END IF;
      END IF;
  END IF;

END validatePeriod;

---------------------------------------------------------------------------------------------------
-- Procedure      : validatePeriodTotalizer
-- Description    : Used to validate stream event periods.
--
-- Preconditions  :
-- Postconditions : Possible unhandled application exceptions
--
-- Using tables   : STRM_EVENT
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

PROCEDURE validatePeriodTotalizer(p_object_id stream.object_id%TYPE,
  			 p_event_type VARCHAR2,
                         p_daytime DATE,
                         p_end_date DATE
                         )
--</EC-DOC>
IS

CURSOR c_exists(cp_object_id stream.object_id%TYPE,
		cp_event_type VARCHAR2,
                cp_daytime DATE,
                cp_end_date DATE) IS
  SELECT 1 one FROM strm_event e
   WHERE e.object_id = cp_object_id
     AND e.event_type = cp_event_type
     AND e.daytime <> cp_daytime
     AND ((e.daytime < cp_daytime AND cp_daytime < e.end_date)
           OR(e.daytime < cp_end_date AND cp_end_date < e.end_date)
           OR(cp_daytime < e.end_date and e.end_date < cp_end_date));


BEGIN

  FOR mycur IN c_exists(p_object_id, p_event_type, p_daytime, p_end_date) LOOP
    RAISE_APPLICATION_ERROR(-20000, 'This event overlaps with the existing period for the stream');
  END LOOP;


END validatePeriodTotalizer;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : setStrmSwapEndDate
-- Description    : Set end_date for previous swap request if not exist
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : strm_company_swap
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE setStrmSwapEndDate (p_object_id   VARCHAR2,  -- OBJECT ID
                              p_company_id  VARCHAR2,
                              p_start_date  DATE,      -- START DATE
                              p_end_date    DATE) IS

   -- Check for overlapping
   CURSOR c_strm_company_swap (cp_object_id   VARCHAR2,
                               cp_company_id  VARCHAR2,
                               cp_start_date  DATE,
                               cp_end_date    DATE) IS
   SELECT 1 one
     FROM strm_company_swap
    WHERE object_id = cp_object_id
      AND company_id = cp_company_id
      AND cp_start_date < Nvl(end_date, cp_start_date + 1)
      AND Nvl(cp_end_date, daytime + 1) > daytime
      AND (cp_start_date <> daytime AND nvl(cp_end_date, cp_end_date + 1) <> end_date)
      AND NOT (cp_start_date > daytime AND end_date IS NULL);

BEGIN

   FOR ITEM IN c_strm_company_swap(p_object_id, p_company_id, p_start_date, p_end_date) LOOP
      Raise_Application_Error(-20121, 'The date overlaps with another period');
   END LOOP;

   -- update previous row end date if null
   UPDATE strm_company_swap
      SET end_date = p_start_date
    WHERE object_id = p_object_id
      AND company_id = p_company_id
      AND daytime < p_start_date
      AND end_date IS NULL;

END setStrmSwapEndDate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : setStrmFactorEndDate
-- Description    : Check for period overlapping and
--                set end_date for previous stream company factor if not exist
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : STRM_COMPANY_SPLIT
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

PROCEDURE setStrmFactorEndDate (p_object_id VARCHAR2, -- OBJECT ID
                                p_daytime      DATE,     -- START DATE
                                p_end_date        DATE,
                                p_company_id VARCHAR2) IS

   -- Check for overlapping
   CURSOR c_strm_company_split (cp_object_id  VARCHAR2,
                                cp_daytime       DATE,
                                cp_end_date         DATE,
                                cp_company_id VARCHAR2) IS
   SELECT 1 one
     FROM STRM_COMPANY_SPLIT
    WHERE object_id = cp_object_id
      AND company_id = cp_company_id
      AND cp_daytime < Nvl(end_date, cp_daytime + 1)
      AND Nvl(cp_end_date, daytime + 1) > daytime
      AND ((cp_daytime <> daytime AND nvl(cp_end_date, end_date+1) <> end_date)
      --changes
      OR
      (cp_daytime <> daytime AND nvl(cp_end_date, end_date+1) = end_date))
      AND NOT (cp_daytime > daytime AND end_date IS NULL);

BEGIN

   FOR ITEM IN c_strm_company_split(p_object_id, p_daytime, p_end_date, p_company_id) LOOP
      Raise_Application_Error(-20121, 'The Date Overlaps with another period');
   END LOOP;

   -- update previous row end date if null
   UPDATE STRM_COMPANY_SPLIT
      SET end_date = p_daytime
    WHERE object_id = p_object_id
      AND company_id = p_company_id
      AND daytime < p_daytime
      AND end_date IS NULL;

END setStrmFactorEndDate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : swap_instantiate
-- Description  : Instantiates all hydrocarbon components associated with the stream swap company
--                into the stream company hydrocarbon swap table.
--
--
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: STRM_COMPANY_SWAP, STRM_COMPANY_HC_SWAP, COMP_SET_LIST
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE swap_instantiate(p_object_id VARCHAR2,
                           p_company_id VARCHAR2,
                           p_daytime DATE) IS

  CURSOR c_current_components IS
  SELECT c.component_no
    FROM comp_set_list c
   WHERE c.component_set = 'STRM_SWAP_COMP'
    AND p_daytime >= c.daytime AND (p_daytime < c.end_date OR c.end_date IS NULL);

  CURSOR c_swap_no IS
  SELECT c.swap_no
    FROM strm_company_swap c
   WHERE c.object_id = p_object_id
     AND c.company_id = p_company_id
     AND c.daytime = p_daytime;

  ln_no_components NUMBER;

BEGIN

   ln_no_components := 0;

   FOR cur IN c_swap_no LOOP

     IF ec_strm_company_swap.company_id(cur.swap_no) IS NOT NULL THEN
        SELECT count(component_no)
          INTO ln_no_components
          FROM strm_company_hc_swap
         WHERE swap_no = cur.swap_no;

        IF ln_no_components = 0 THEN

           FOR cur_rec IN c_current_components LOOP

              INSERT INTO strm_company_hc_swap (swap_no, component_no)
              VALUES (cur.swap_no, cur_rec.component_no);

           END LOOP;

        END IF;

     END IF;

   END LOOP;

END swap_instantiate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : swap_delete
-- Description  : Delete all hydrocarbon components associated with the stream swap company.
--
--
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: STRM_COMPANY_HC_SWAP
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE swap_delete(p_swap_no NUMBER) IS

BEGIN
	-- Delete all components
	DELETE STRM_COMPANY_HC_SWAP
	WHERE SWAP_NO = p_swap_no;

END swap_delete;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : approvePeriod
-- Description    : The Procedure approve the period for the selected stream within the specified period
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
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
PROCEDURE approvePeriod(p_object_id stream.object_id%TYPE,
                         p_daytime DATE,
                         p_end_date DATE)
--</EC-DOC>
IS


BEGIN

  UPDATE strm_event SET record_status='A'
    WHERE object_id = p_object_id
      AND daytime = p_daytime
      AND end_date = p_end_date;

END approvePeriod;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : verifyPeriod
-- Description    : The Procedure verify the period for the selected stream within the specified period
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
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
PROCEDURE verifyPeriod(p_object_id stream.object_id%TYPE,
                         p_daytime DATE,
                         p_end_date DATE)
--</EC-DOC>
IS


BEGIN

  UPDATE strm_event SET record_status='V'
    WHERE object_id = p_object_id
      AND daytime = p_daytime
      AND end_date = p_end_date;

END verifyPeriod;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : verifyPeriodTotalizer
-- Description    : The Procedure verify the period for the selected stream within the specified period
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : STRM_EVENT
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
PROCEDURE verifyPeriodTotalizer(p_object_id stream.object_id%TYPE,
                         p_daytime DATE,
                         p_end_date DATE,
                         p_user VARCHAR2)
--</EC-DOC>
IS

ln_exists NUMBER;

lv2_last_update_date VARCHAR2(20);

BEGIN
  lv2_last_update_date := to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')  ;


    SELECT COUNT(*) INTO ln_exists FROM strm_event WHERE object_id = p_object_id
    AND daytime = p_daytime
    AND end_date = p_end_date
    AND record_status='A';

    IF ln_exists = 0 THEN
       UPDATE strm_event
         SET record_status='V',
             last_updated_by = p_user,
             last_updated_date = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
             rev_text = 'Verified at ' ||  lv2_last_update_date
       WHERE object_id = p_object_id
       AND daytime = p_daytime
       AND end_date = p_end_date;
    ELSE
      RAISE_APPLICATION_ERROR('-20223','Record with Approved status cannot be Verified again.');
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
-- Using tables   : STRM_EVENT
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
PROCEDURE approvePeriodTotalizer(p_object_id stream.object_id%TYPE,
                         p_daytime DATE,
                         p_end_date DATE,
                         p_user VARCHAR2)
--</EC-DOC>
IS


lv2_last_update_date VARCHAR2(20);

BEGIN
  lv2_last_update_date := to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')  ;


    UPDATE strm_event
       SET record_status='A',
           last_updated_by = p_user,
           last_updated_date = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
           rev_text = 'Approved at ' ||  lv2_last_update_date
    WHERE object_id = p_object_id
    AND daytime = p_daytime
    AND end_date = p_end_date;

END approvePeriodTotalizer;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validateTotalizerMax
-- Description    : The Procedure validate the Override  and closing < totalizer max count
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : STRM_REFERENCE_VALUE
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

PROCEDURE validateTotalizerMax(p_object_id stream.object_id%TYPE,
                               p_daytime DATE,
                               p_overwrite NUMBER,
                               p_closing NUMBER)

IS
ln_totalizermax NUMBER;

BEGIN

ln_totalizermax := ec_strm_reference_value.totalizer_max_count(p_object_id,p_daytime,'<=');


 IF ln_totalizermax IS NOT NULL THEN

      IF (p_overwrite IS NOT NULL AND p_closing IS NOT NULL) THEN
         IF (p_overwrite >= ln_totalizermax AND p_closing >= ln_totalizermax) THEN
            RAISE_APPLICATION_ERROR('-20000','Override value and Closing value must be less than Totalizer Max Count');
         END IF;
      END IF;

      IF p_overwrite IS NOT NULL THEN
         IF p_overwrite >= ln_totalizermax THEN
            RAISE_APPLICATION_ERROR('-20000','Override  value must be less than Totalizer Max Count');
         END IF;
      END IF;
      IF p_closing IS NOT NULL THEN
         IF p_closing >= ln_totalizermax THEN
            RAISE_APPLICATION_ERROR('-20000','Override  value must be less than Totalizer Max Count');
         END IF;
      END IF;
 END IF;


END validateTotalizerMax;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : checkStreamEventLock
-- Description    : Wrapper procedure to set necassery parameters before testing if stream event
--                  is locked.
--
--
-- Preconditions  : Assuming that this is an update operation , not changing PK in STRM_EVENT
-- Postconditions : Raises an application error if the given object_id, event_type, daytime is locked
--
-- Using tables   :
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE checkStreamEventLock(p_object_id VARCHAR2, p_event_type VARCHAR2, p_daytime DATE, p_class_name VARCHAR2)
--</EC-DOC>

IS
  lr_strm_event        strm_event%ROWTYPE;
  n_lock_columns       EcDp_Month_lock.column_list;

BEGIN

  lr_strm_event := ec_strm_event.row_by_pk(p_object_id, p_event_type, p_daytime);

  -- Lock test
  EcDp_month_lock.AddParameterToList(n_lock_columns,'CLASS_NAME',p_class_name,'STRING',NULL,NULL,NULL);
  EcDp_month_lock.AddParameterToList(n_lock_columns,'TABLE_NAME','STRM_EVENT','STRING',NULL,NULL,NULL);
  EcDp_month_lock.AddParameterToList(n_lock_columns,'OBJECT_ID','OBJECT_ID','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_strm_event.object_id));
  EcDp_month_lock.AddParameterToList(n_lock_columns,'DAYTIME','DAYTIME','DATE','N','N',anydata.Convertdate(lr_strm_event.DAYTIME));
  EcDp_month_lock.AddParameterToList(n_lock_columns,'END_DATE','DAYTIME','DATE','N','N',anydata.Convertdate(lr_strm_event.END_DATE));

  EcDp_Production_Lock.CheckAnySimpleEventLock('UPDATING',n_lock_columns,n_lock_columns);

END checkStreamEventLock;

END EcBp_Stream_Event;