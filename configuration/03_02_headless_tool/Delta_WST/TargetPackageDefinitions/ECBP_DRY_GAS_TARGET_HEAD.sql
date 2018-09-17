CREATE OR REPLACE PACKAGE EcBp_Dry_Gas_Target IS
/****************************************************************
** Package        :  EcBp_Dry_Gas_Target
**
** $Revision: 1.4 $
**
** Purpose        :  Retrieves the calculated quantity with UOM corresponding to available quantity attribute/column
**
** Documentation  :  www.energy-components.com
**
** Created  : 23.12.2005  Stian Skjørestad
**
** Modification history:
**
** Date       Whom  	 		Change description:
** --------   ----- 			---------------------------------------------
** 10.01.06	  ssk			Addded function getDryGasHourprofile (TI 2734)
** 21.03.07       Rahmanaz              ECPD-5148: Added function getProjectedActualPct.
*****************************************************************************/

PROCEDURE createBeforeDayTarget(p_daytime DATE, p_source_class VARCHAR2, p_source_attr VARCHAR2, p_user VARCHAR2 DEFAULT NULL);

PROCEDURE createWithinDayTarget(p_daytime DATE, p_change_reason VARCHAR2, p_source_class VARCHAR2, p_source_attr VARCHAR2, p_user VARCHAR2 DEFAULT NULL);

FUNCTION getTargetQty(p_object_id VARCHAR2, p_daytime DATE, p_delivery_point_id VARCHAR2, p_nominated_qty NUMBER, p_source_class VARCHAR2, p_source_attr VARCHAR2) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getTargetQty, WNDS, WNPS, RNPS);

FUNCTION getWithinTargetQty(p_object_id VARCHAR2, p_delivery_point_id VARCHAR2, p_daytime DATE, p_nominated_qty NUMBER, p_ack_qty NUMBER, p_renom_qty NUMBER, p_source_class VARCHAR2, p_source_attr VARCHAR2) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getWithinTargetQty, WNDS, WNPS, RNPS);

FUNCTION getProjectedTargetQty(p_object_id VARCHAR2, p_delivery_point_id VARCHAR2, p_daytime DATE)RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getProjectedTargetQty, WNDS, WNPS, RNPS);

FUNCTION getOffset(p_daytime DATE) RETURN DATE;
PRAGMA RESTRICT_REFERENCES(getOffset, WNDS, WNPS, RNPS);

FUNCTION getDryGasHourProfile(p_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getDryGasHourProfile, WNDS, WNPS, RNPS);

FUNCTION getProjectedActualPct(p_object_id VARCHAR2, p_delivery_point_id VARCHAR2, p_daytime DATE, p_nominated_qty NUMBER) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getProjectedActualPct, WNDS, WNPS, RNPS);

END EcBp_Dry_Gas_Target;