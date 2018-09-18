CREATE OR REPLACE PACKAGE EcDp_Webo_Press_Test IS
/****************************************************************
** Package        :  EcDp_Webo_Press_Test, header part
**
** $Revision: 1.2.4.1 $
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
** 23-01-2013   musthram   ECPD-23161: Added new function countChildEvent and deleteChildEvent
*****************************************************************/

FUNCTION assignNextGradientSeq(p_event_no NUMBER) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (assignNextGradientSeq, WNDS,WNPS, RNPS);

PROCEDURE addPreviousGradients(p_event_no NUMBER, p_object_id VARCHAR2, p_daytime DATE);

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