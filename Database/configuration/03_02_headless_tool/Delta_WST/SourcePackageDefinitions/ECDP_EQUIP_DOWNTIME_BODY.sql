CREATE OR REPLACE PACKAGE BODY EcDp_Equip_Downtime IS

/****************************************************************
** Package        :  EcDp_Equip_Downtime, header part
**
** $Revision: 1.1 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Equipment downtime.
** Documentation  :  www.energy-components.com
**
** Created  : 21.04.2017  Gaurav Chaudhary
**
** Modification history:
**
** Date         Whom      Change description:
** -------      -------   ----------------------------------------------
** 21.04.2017   chaudgau  ECPD-44611: Inital version
** 14.11.2017   chaudgau  ECPD-50458: updateEndDateForChildEvent has been modified to handle NULL value input
*****************************************************************/


--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- Procedure      : updateEndDateForChildEvent
-- Description    : Update end date of child based on parent record end date, only if it is null or empty
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : equip_downtime
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------------
PROCEDURE updateEndDateForChildEvent(p_event_no NUMBER,
                          p_o_end_date DATE,
                         p_user VARCHAR2 ,
                         p_last_updated_date DATE )
--</EC-DOC>
IS
  CURSOR c_end_date IS
  SELECT ed.end_date
    FROM equip_downtime ed
   WHERE ed.event_no = p_event_no;

  ld_parent_end_date DATE;

BEGIN

     FOR cur_end_date IN c_end_date LOOP
        ld_parent_end_date := cur_end_date.end_date;
     END LOOP;

     IF ld_parent_end_date IS NULL THEN
       RETURN;
     END IF;

     UPDATE equip_downtime
        SET end_date = CASE WHEN end_date < ld_parent_end_date
                            THEN end_date
                            ELSE ld_parent_end_date
                       END,
            last_updated_by =  p_user,
            last_updated_date = p_last_updated_date
      WHERE parent_event_no = p_event_no
        AND (end_date is null
             OR end_date <= NVL(p_o_end_date,end_date));

END updateEndDateForChildEvent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- Procedure      : updateReasonCodeForChildEvent
-- Description    : Update Reason Code of child to be same as parent.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : equip_downtime
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------------
PROCEDURE updateReasonCodeForChildEvent(p_event_no NUMBER,
                                        p_user VARCHAR2,
                         p_last_updated_date DATE)
--</EC-DOC>
IS
  CURSOR c_reason_code IS
  SELECT ed.reason_code_1
         ,ed.reason_code_2
         ,ed.reason_code_3
         ,ed.reason_code_4
    FROM equip_downtime ed
   WHERE ed.event_no = p_event_no;

BEGIN

   FOR cur_reason_code IN c_reason_code LOOP
       UPDATE equip_downtime
          SET reason_code_1 = cur_reason_code.reason_code_1,
              reason_code_2 = cur_reason_code.reason_code_2,
              reason_code_3 = cur_reason_code.reason_code_3,
              reason_code_4 = cur_reason_code.reason_code_4,
              last_updated_by =  p_user,
              last_updated_date = p_last_updated_date
        WHERE parent_event_no = p_event_no
          AND (nvl(reason_code_1,'null') <> nvl(cur_reason_code.reason_code_1,'null')
               OR nvl(reason_code_2,'null') <> nvl(cur_reason_code.reason_code_2,'null')
               OR nvl(reason_code_3,'null') <> nvl(cur_reason_code.reason_code_3,'null')
               OR nvl(reason_code_4,'null') <> nvl(cur_reason_code.reason_code_4,'null'));
   END LOOP;

END updateReasonCodeForChildEvent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- Procedure      : updateStartDateForChildEvent
-- Description    : Update start date of child
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : equip_downtime
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------------
PROCEDURE updateStartDateForChildEvent(p_event_no NUMBER,
                          p_o_start_date DATE,
                         p_user VARCHAR2 ,
                         p_last_updated_date DATE )
--</EC-DOC>
IS
  CURSOR c_start_date IS
  SELECT ed.daytime
    FROM equip_downtime ed
   WHERE ed.event_no = p_event_no;

  ld_parent_start_date DATE;

BEGIN

     FOR cur_start_date IN c_start_date LOOP
        ld_parent_start_date := cur_start_date.daytime;
     END LOOP;

     UPDATE equip_downtime
        SET daytime = ld_parent_start_date
            ,last_updated_by =  p_user
            ,last_updated_date = p_last_updated_date
      WHERE parent_event_no = p_event_no
        AND daytime < p_o_start_date;

END updateStartDateForChildEvent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : approveEquipDowntime
-- Description    : The Procedure approve the records for the selected object within the specified period.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : equip_downtime
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
PROCEDURE approveEquipDowntime(p_event_no NUMBER
                               ,p_user_name VARCHAR2)
--</EC-DOC>
IS

  lv2_last_update_date VARCHAR2(20);

BEGIN
  lv2_last_update_date := to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS');

  -- update parent
  UPDATE equip_downtime
     SET record_status='A'
         ,last_updated_by = p_user_name
         ,last_updated_date = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS')
         ,rev_text = 'Approved at ' || lv2_last_update_date
   WHERE event_no = p_event_no;

  -- update child
  UPDATE equip_downtime ed_child
     SET ed_child.record_status='A'
         ,last_updated_by = p_user_name
         ,last_updated_date = to_date (lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS')
         ,rev_text = 'Approved at ' || lv2_last_update_date
   WHERE ed_child.parent_event_no = p_event_no;

END approveEquipDowntime;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : verifyEquipDowntime
-- Description    : The Procedure verifies the records for the selected object within the specified period.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : equip_downtime
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
PROCEDURE verifyEquipDowntime(p_event_no NUMBER
                              ,p_user_name VARCHAR2)
--</EC-DOC>
IS

  ln_exists NUMBER;
  lv2_last_update_date VARCHAR2(20);

BEGIN
  lv2_last_update_date := to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS');

  SELECT COUNT(*) INTO ln_exists
    FROM equip_downtime
   WHERE event_no = p_event_no
     AND record_status='A';

  IF ln_exists = 0 THEN
  -- Update parent
    UPDATE equip_downtime
       SET record_status='V'
           ,last_updated_by = p_user_name
           ,last_updated_date = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS')
           ,rev_text = 'Verified at ' || lv2_last_update_date
    WHERE event_no = p_event_no;

  -- update child
    UPDATE equip_downtime ed_child
       SET ed_child.record_status='V'
           ,last_updated_by = p_user_name
           ,last_updated_date = to_date (lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS')
           ,rev_text = 'Verified at ' || lv2_last_update_date
    WHERE ed_child.parent_event_no = p_event_no;

  ELSE
    RAISE_APPLICATION_ERROR('-20223','Record with Approved status cannot be Verified again.');
  END IF;
END verifyEquipDowntime;

END EcDp_Equip_Downtime;