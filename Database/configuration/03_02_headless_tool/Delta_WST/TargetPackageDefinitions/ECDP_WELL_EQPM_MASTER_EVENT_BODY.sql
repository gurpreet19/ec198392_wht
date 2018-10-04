CREATE OR REPLACE PACKAGE BODY EcDp_Well_EQPM_Master_Event IS
/**************************************************************************************************
** Package  :  EcDp_Well_EQPM_Master_Event
**
** $Revision: 1.4 $
**
** Purpose  :  This package handles the triggered inserting / updating of Master Events views
**
** Created:     02.07.2007 Leong WS
**
** Modification history:
**
** Date:        Whom:       Rev.  Change description:
** ----------   -----       ----  ------------------------------------------------------------------------
** 02.07.2007   Leong WS    0.1   First version
**************************************************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : genEventID
-- Description    : Generate the event id for the master events
--
-- Preconditions  : parameter EVENT_TYPE, DAYTIME is required
-- Postconditions :
--
-- Using tables   : TV_Well_EQPM_Master_Event
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
   FUNCTION genEventID(p_event_type VARCHAR2, p_daytime DATE)
   RETURN VARCHAR2
   --</EC-DOC>
   IS
      CURSOR c_well_eqpm_master_event (p_event_type VARCHAR2, p_daytime DATE) IS
         SELECT m.event_type, m.daytime, m.event_id, TO_NUMBER(SUBSTR(m.event_id, -3)) seq_no
           FROM tv_well_eqpm_master_event m
          WHERE event_type = p_event_type
            AND daytime = p_daytime
         ORDER BY TO_NUMBER(SUBSTR(m.event_id, -3)) DESC;

      lv_event_id		VARCHAR2(32);
      ln_seq_no      NUMBER := 0;

   BEGIN

   	FOR curMasterEvents IN c_well_eqpm_master_event (p_event_type, p_daytime) LOOP

   		ln_seq_no := curMasterEvents.seq_no;
   		EXIT;

   	END LOOP;

      -- set sequence no
      ln_seq_no := ln_seq_no + 1;

      -- Event ID is made up of the first five characters of the Event Type, plus year, month, and day, plus a sequence number
      lv_event_id := SUBSTR(p_event_type, 1, 5) || TO_CHAR(p_daytime, 'yyyymmdd') || LPAD(TO_CHAR(ln_seq_no), 3, '0');

      RETURN lv_event_id;

   END genEventID;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : verifyMasterEvent
-- Description    : The Procedure verify the record for the selected master event id
--
-- Preconditions  : parameter MASTER_EVENT_ID is required
-- Postconditions :
--
-- Using tables   : TV_Well_EQPM_Master_Event
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
   PROCEDURE verifyMasterEvent(p_master_event_id NUMBER,
                               p_user_id VARCHAR2) IS
   --</EC-DOC>

      ln_exists         NUMBER;
      lv_rev_text       VARCHAR2(50);

   BEGIN

      SELECT COUNT(*)
        INTO ln_exists
        FROM tv_well_eqpm_master_event
       WHERE master_event_id = p_master_event_id
         AND record_status = 'A';

      IF ln_exists = 0 THEN

         lv_rev_text := 'Verified at ' || TO_CHAR(EcDp_Date_Time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS');

         -- Update parent
         UPDATE tv_well_eqpm_master_event
            SET record_status = 'V',
                last_updated_by = p_user_id,
                rev_text = lv_rev_text
          WHERE master_event_id = p_master_event_id;

      ELSE
         RAISE_APPLICATION_ERROR('-20000', 'Record with Approved status cannot be Verified.');

      END IF;

   END verifyMasterEvent;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : approveMasterEvent
-- Description    : The Procedure approve the record for the selected master event id
--
-- Preconditions  : parameter MASTER_EVEND_ID is required
-- Postconditions :
--
-- Using tables   : TV_Well_EQPM_Master_Event
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
   PROCEDURE approveMasterEvent(p_master_event_id NUMBER,
                                p_user_id VARCHAR2) IS
   --</EC-DOC>

      lv_rev_text       VARCHAR2(50);

   BEGIN

      lv_rev_text := 'Approved at ' || TO_CHAR(EcDp_Date_Time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS');

      -- update parent
      UPDATE tv_well_eqpm_master_event
         SET record_status = 'A',
             last_updated_by = p_user_id,
             rev_text = lv_rev_text
       WHERE master_event_id = p_master_event_id;

   END approveMasterEvent;


END EcDp_Well_EQPM_Master_Event;