CREATE OR REPLACE PACKAGE BODY EcBp_Stream_Well_Conn IS

/****************************************************************
** Package        :  EcBp_Stream_Well_Conn, body part
**
** $Revision: 1.6 $
**
** Purpose        :  Provide basic functions on stream well connection
**
** Documentation  :  www.energy-components.com
**
** Created  : 06.06.2008 Siti Azura Alias
**
** Modification history:
**
**  Date     Whom  Change description:
**  ------   ----- --------------------------------------
**  27.02.2009 Leongwen ECPD-9994 fixed the alert message from 20602 to 20226
**  11.08.2010 amirrasn ECPD-14747 add new function to find Well Facility ID
**  07.08.2017 jainnraj ECPD-46835: Modified procedure checkIfEventOverlaps to correct the error message.

****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findWellFcty
-- Description    : This function is to return which facility that the well belong to
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions:ECGP_GROUP.findParentObjectId
--                 ecdp_objects.getObjName
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
---------------------------------------------------------------------------------------------------
FUNCTION findWellFcty (p_object_id   well.object_id%TYPE,
                       p_daytime     DATE)

RETURN VARCHAR2
--<EC-DOC>
IS

lv2_fcty_object_id  VARCHAR2(32);
lv2_fcty_name       VARCHAR2(32);

BEGIN

   lv2_fcty_object_id := Ecgp_Group.findParentObjectId('operational','FCTY_CLASS_1','WELL',p_object_id,p_daytime);
   lv2_fcty_name:= Ecdp_Objects.GetObjName(lv2_fcty_object_id,p_daytime);

   RETURN lv2_fcty_name;

END findWellFcty;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findWellFctyId
-- Description    : This function is to return which facility Id that the well belong to
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions:ECGP_GROUP.findParentObjectId
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
---------------------------------------------------------------------------------------------------
FUNCTION findWellFctyId (p_object_id   well.object_id%TYPE,
                         p_daytime     DATE)

RETURN VARCHAR2
--<EC-DOC>
IS

lv2_fcty_object_id  VARCHAR2(32);

BEGIN

   lv2_fcty_object_id := Ecgp_Group.findParentObjectId('operational','FCTY_CLASS_1','WELL',p_object_id,p_daytime);

   RETURN lv2_fcty_object_id;

END findWellFctyId;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      :checkIfEventOverlaps
-- Description    : Checks if overlapping event exists.
--
--
-- Preconditions  :
-- Postconditions : Raises an application error if overlapping event exists.
--
-- Using tables   : strm_well_conn
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE checkIfEventOverlaps (p_object_id VARCHAR2, p_daytime DATE, p_child_object_id VARCHAR2,  p_end_date DATE)
--</EC-DOC>
IS
  -- overlapping period
	CURSOR c_strm_well_conn_insert  IS
		SELECT *
		FROM strm_well_conn swn
		WHERE swn.well_object_id= p_child_object_id
		AND swn.object_id = p_object_id
		AND swn.daytime <> p_daytime
		AND (nvl(swn.end_date, p_daytime+1) > p_daytime)
		AND (swn.daytime < nvl(p_end_date, swn.daytime+1));

	 CURSOR c_strm_well_conn_update  IS
		SELECT *
		FROM strm_well_conn swn1
		WHERE swn1.well_object_id= p_child_object_id
		AND swn1.object_id = p_object_id
		AND swn1.daytime <> p_daytime
		AND ((swn1.daytime > p_daytime  AND  (p_end_date is null OR p_end_date > swn1.daytime))
		OR (swn1.end_date is null  and p_end_date > swn1.daytime)
		OR (swn1.daytime < p_daytime  AND  p_end_date < swn1.end_date));



    lv_message_insert VARCHAR2(4000);
    lv_message_update VARCHAR2(4000);

BEGIN

  lv_message_insert := null;
  lv_message_update := null;

  FOR  cur_strm_well_conn_insert IN  c_strm_well_conn_insert LOOP
    lv_message_insert := 'validation error';
    exit;
  END LOOP;

  FOR  cur_strm_well_conn_update IN  c_strm_well_conn_update LOOP
    lv_message_update := 'validation error';
    exit;
  END LOOP;
   IF INSERTING THEN
     IF lv_message_insert is not null THEN
       RAISE_APPLICATION_ERROR(-20226, 'An event must not overlap with the existing event period.');
     END IF;
   ELSIF UPDATING THEN
     IF lv_message_update is not null THEN
       RAISE_APPLICATION_ERROR(-20226, 'An event must not overlap with the existing event period.');
     END IF;
   END IF;

  END checkIfEventOverlaps;



END EcBp_Stream_Well_Conn;