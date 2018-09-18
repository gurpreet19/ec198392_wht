CREATE OR REPLACE PACKAGE EcDp_Webo_Press_Test IS
/****************************************************************
** Package        :  EcDp_Webo_Press_Test, header part
**
** $Revision: 1.3 $
**
** Purpose        :  Provide Well Bore Press test numbers
**
** Documentation  :  www.energy-components.com
**
** Created  : 27.04.2011  Geir Olav Hagen
**
** Modification history:
**
** Date         Whom       Change description:
** --------     -----      --------------------------------------
** 20110427     xxhageog   Initial version
** 02.05.2011   madondin   ECPD-17395: added new function addPreviousGradients,saveAndCalcDatumPress, toDepthPress and delPerfInterval
** 25-01-2013   limmmchu   ECPD-22868: Added new function countChildEvent and deleteChildEvent
** 30-12-2015   shindani   ECPD-32163: Modified procedure addPreviousGradients.
*****************************************************************/

FUNCTION assignNextGradientSeq(p_event_no NUMBER) RETURN NUMBER;

PROCEDURE addPreviousGradients(p_event_no NUMBER, p_object_id VARCHAR2, p_daytime DATE, p_press_type VARCHAR2);

PROCEDURE saveAndCalcDatumPress(p_event_no NUMBER, p_object_id VARCHAR2, p_datum_press NUMBER);

PROCEDURE toDepthPress(p_event_no NUMBER, p_object_id VARCHAR2, p_user VARCHAR2);

PROCEDURE delPerfInterval(p_event_no NUMBER, p_object_id VARCHAR2);

FUNCTION getDepthToPress(
  p_event_no NUMBER,
  p_object_id VARCHAR2,
  p_grad_seq NUMBER)

RETURN NUMBER;

PROCEDURE deleteChildEvent(p_event_no NUMBER);

FUNCTION countChildEvent(p_event_no NUMBER)
RETURN NUMBER;

END EcDp_Webo_Press_Test;