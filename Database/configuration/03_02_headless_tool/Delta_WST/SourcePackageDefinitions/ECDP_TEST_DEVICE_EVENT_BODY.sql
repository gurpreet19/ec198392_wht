CREATE OR REPLACE PACKAGE BODY EcDp_Test_Device_Event IS

/****************************************************************
** Package        :  EcDp_Test_Device_Event, body part
**
** $Revision: 1.3 $
**
** Purpose        :  General purpose functionality on top of table test_device_event
**
** Documentation  :  www.energy-components.com
**
** Created        :   	14.07.2014  Leong Weng Onn
**
** Modification history:
**
** Date        Whom         Change description:
** ------      -----        --------------------------------------
** 14.07.2014  leongwen     ECPD-28063 - Initial copy, re-use the procedures insertEventStatus, deleteEventStatus and updateEventStatus for test device object use.
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : insertEventDetail
-- Description    : Used to insert row an event details
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : TEST_DEVICE_EVENT_STATUS
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

PROCEDURE insertEventStatus(p_object_id test_device_event.object_id%TYPE, p_daytime DATE, p_user VARCHAR2)
--</EC-DOC>
IS

 CURSOR c_dataclass (cp_object_id test_device_version.object_id%TYPE, cp_daytime DATE, cp_user VARCHAR2) IS
    SELECT data_class_1,data_class_2,data_class_3,data_class_4 FROM test_device_version ee
    WHERE ee.object_id = cp_object_id AND
          ee.daytime = (SELECT MAX(t.daytime) FROM test_device_version t WHERE t.object_id=cp_object_id AND t.daytime <= cp_daytime);

BEGIN

  FOR cur_dataclass IN c_dataclass(p_object_id,p_daytime,p_user) LOOP
    IF cur_dataclass.data_class_1 IS NOT NULL THEN
      INSERT into test_device_event_status (object_id, daytime, class_name, created_by) VALUES (p_object_id, p_daytime, cur_dataclass.data_class_1, p_user);
    END IF;

    IF cur_dataclass.data_class_2 IS NOT NULL THEN
      INSERT into test_device_event_status (object_id, daytime, class_name, created_by) VALUES (p_object_id, p_daytime, cur_dataclass.data_class_2, p_user);
    END IF;

    IF cur_dataclass.data_class_3 IS NOT NULL THEN
      INSERT into test_device_event_status (object_id, daytime, class_name, created_by) VALUES (p_object_id, p_daytime, cur_dataclass.data_class_3, p_user);
    END IF;

    IF cur_dataclass.data_class_4 IS NOT NULL THEN
      INSERT into test_device_event_status (object_id, daytime, class_name, created_by) VALUES (p_object_id, p_daytime, cur_dataclass.data_class_4, p_user);
    END IF;
  END LOOP;

END insertEventStatus;


--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- Procedure      : deleteEventStatus
-- Description    : This procedure cascadingly deletes any data in the test_device_event_status table.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : TEST_DEVICE_EVENT_STATUS
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
PROCEDURE deleteEventStatus(p_object_id test_device_event.object_id%TYPE, p_daytime DATE)
--</EC-DOC>
IS

BEGIN

  DELETE test_device_event_status WHERE object_id = p_object_id and daytime = p_daytime;

END deleteEventStatus;


--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- Procedure      : updateEventStatus
-- Description    : This procedure allows updates on Test Device Event section whenever there are changes to the configuration.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : TEST_DEVICE, TEST_DEVICE_VERSION, TEST_DEVICE_EVENT, TEST_DEVICE_EVENT_STATUS
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

PROCEDURE updateEventStatus(p_object_id test_device.object_id%TYPE, p_daytime DATE)
--</EC-DOC>
IS

 CURSOR c_tdevdataclass_1 (cp_object_id test_device.object_id%TYPE, cp_daytime DATE) IS
    SELECT ee.object_id, ee.daytime, ev.data_class_1
      FROM test_device e, test_device_version ev, test_device_event ee
     WHERE ev.object_id = cp_object_id AND e.object_id = ev.object_id AND ee.object_id = ev.object_id
       AND ev.daytime = cp_daytime
       AND ee.daytime >= cp_daytime
       AND (ee.daytime < ev.end_date OR ev.end_date IS NULL)
       AND ev.data_class_1 NOT IN (SELECT ees.class_name
                                     FROM test_device_version ev, test_device_event ee, test_device_event_status ees
                                    WHERE ee.object_id = ees.object_id AND ev.object_id = ee.object_id AND ees.object_id = cp_object_id
                                      AND ee.daytime >= cp_daytime
                                      AND (ee.daytime < ev.end_date OR ev.end_date IS NULL));

 CURSOR c_tdevdataclass_2 (cp_object_id test_device.object_id%TYPE, cp_daytime DATE) IS
    SELECT ee.object_id, ee.daytime, ev.data_class_2
      FROM test_device e, test_device_version ev, test_device_event ee
     WHERE ev.object_id = cp_object_id AND e.object_id = ev.object_id AND ee.object_id = ev.object_id
       AND ev.daytime = cp_daytime
       AND ee.daytime >= cp_daytime
       AND (ee.daytime < ev.end_date OR ev.end_date IS NULL)
       AND ev.data_class_2 NOT IN (SELECT ees.class_name
                                     FROM test_device_version ev, test_device_event ee, test_device_event_status ees
                                    WHERE ee.object_id = ees.object_id AND ev.object_id = ee.object_id AND ees.object_id = cp_object_id
                                      AND ee.daytime >= cp_daytime
                                      AND (ee.daytime < ev.end_date OR ev.end_date IS NULL));

 CURSOR c_tdevdataclass_3 (cp_object_id test_device.object_id%TYPE, cp_daytime DATE) IS
    SELECT ee.object_id, ee.daytime, ev.data_class_3
      FROM test_device e, test_device_version ev, test_device_event ee
     WHERE ev.object_id = cp_object_id AND e.object_id = ev.object_id AND ee.object_id = ev.object_id
       AND ev.daytime = cp_daytime
       AND ee.daytime >= cp_daytime
       AND (ee.daytime < ev.end_date OR ev.end_date IS NULL)
       AND ev.data_class_3 NOT IN (SELECT ees.class_name
                                     FROM test_device_version ev, test_device_event ee, test_device_event_status ees
                                    WHERE ee.object_id = ees.object_id AND ev.object_id = ee.object_id AND ees.object_id = cp_object_id
                                      AND ee.daytime >= cp_daytime
                                      AND (ee.daytime < ev.end_date OR ev.end_date IS NULL));

 CURSOR c_tdevdataclass_4 (cp_object_id test_device.object_id%TYPE, cp_daytime DATE) IS
    SELECT ee.object_id, ee.daytime, ev.data_class_4
      FROM test_device e, test_device_version ev, test_device_event ee
     WHERE ev.object_id = cp_object_id AND e.object_id = ev.object_id AND ee.object_id = ev.object_id
       AND ev.daytime = cp_daytime
       AND ee.daytime >= cp_daytime
       AND (ee.daytime < ev.end_date OR ev.end_date IS NULL)
       AND ev.data_class_4 NOT IN (SELECT ees.class_name
                                     FROM test_device_version ev, test_device_event ee, test_device_event_status ees
                                    WHERE ee.object_id = ees.object_id AND ev.object_id = ee.object_id AND ees.object_id = cp_object_id
                                      AND ee.daytime >= cp_daytime
                                      AND (ee.daytime < ev.end_date OR ev.end_date IS NULL));

BEGIN

  FOR cur_tdevdataclass_1 IN c_tdevdataclass_1(p_object_id, p_daytime) LOOP
    IF cur_tdevdataclass_1.data_class_1 IS NOT NULL THEN
      INSERT into test_device_event_status (object_id, daytime, class_name) VALUES (cur_tdevdataclass_1.object_id, cur_tdevdataclass_1.daytime, cur_tdevdataclass_1.data_class_1);
    END IF;
  END LOOP;

  FOR cur_tdevdataclass_2 IN c_tdevdataclass_2(p_object_id, p_daytime) LOOP
    IF cur_tdevdataclass_2.data_class_2 IS NOT NULL THEN
      INSERT into test_device_event_status (object_id, daytime, class_name) VALUES (cur_tdevdataclass_2.object_id, cur_tdevdataclass_2.daytime, cur_tdevdataclass_2.data_class_2);
    END IF;
  END LOOP;

  FOR cur_tdevdataclass_3 IN c_tdevdataclass_3(p_object_id, p_daytime) LOOP
    IF cur_tdevdataclass_3.data_class_3 IS NOT NULL THEN
      INSERT into test_device_event_status (object_id, daytime, class_name) VALUES (cur_tdevdataclass_3.object_id, cur_tdevdataclass_3.daytime, cur_tdevdataclass_3.data_class_3);
    END IF;
  END LOOP;

  FOR cur_tdevdataclass_4 IN c_tdevdataclass_4(p_object_id, p_daytime) LOOP
    IF cur_tdevdataclass_4.data_class_4 IS NOT NULL THEN
      INSERT into test_device_event_status (object_id, daytime, class_name) VALUES (cur_tdevdataclass_4.object_id, cur_tdevdataclass_4.daytime, cur_tdevdataclass_4.data_class_4);
    END IF;
  END LOOP;


END updateEventStatus;


END EcDp_Test_Device_Event;