CREATE OR REPLACE PACKAGE EcBp_Dry_Gas_Target IS
/****************************************************************
** Package        :  EcBp_Dry_Gas_Target
**
** $Revision: 1.7 $
**
** Purpose        :  Retrieves the calculated quantity with UOM corresponding to available quantity attribute/column
**
** Documentation  :  www.energy-components.com
**
** Created  : 23.12.2005  Stian Skj�tad
**
** Modification history:
**
** Date       Whom  	 		Change description:
** --------   ----- 			---------------------------------------------
** 10.01.06	  ssk			Addded function getDryGasHourprofile (TI 2734)
** 21.03.07   Rahmanaz      ECPD-5148: Added function getProjectedActualPct.
** 21.10.13	  leeeewei		ECPD-25002: Added function getNomLocTargetQty and createNomLocTarget
*****************************************************************************/

PROCEDURE createBeforeDayTarget(p_daytime DATE, p_source_class VARCHAR2, p_source_attr VARCHAR2, p_user VARCHAR2 DEFAULT NULL);

PROCEDURE createWithinDayTarget(p_daytime DATE, p_change_reason VARCHAR2, p_source_class VARCHAR2, p_source_attr VARCHAR2, p_user VARCHAR2 DEFAULT NULL);

FUNCTION getTargetQty(p_object_id VARCHAR2, p_daytime DATE, p_delivery_point_id VARCHAR2, p_nominated_qty NUMBER, p_source_class VARCHAR2, p_source_attr VARCHAR2) RETURN NUMBER;

FUNCTION getWithinTargetQty(p_object_id VARCHAR2, p_delivery_point_id VARCHAR2, p_daytime DATE, p_nominated_qty NUMBER, p_ack_qty NUMBER, p_renom_qty NUMBER, p_source_class VARCHAR2, p_source_attr VARCHAR2) RETURN NUMBER;

FUNCTION getProjectedTargetQty(p_object_id VARCHAR2, p_delivery_point_id VARCHAR2, p_daytime DATE)RETURN NUMBER;

FUNCTION getOffset(p_daytime DATE) RETURN DATE;

FUNCTION getDryGasHourProfile(p_daytime DATE) RETURN NUMBER;

FUNCTION getProjectedActualPct(p_object_id VARCHAR2, p_delivery_point_id VARCHAR2, p_daytime DATE, p_nominated_qty NUMBER) RETURN NUMBER;

FUNCTION getNomLocTargetQty(p_nominated_qty NUMBER,p_desired_pct NUMBER)RETURN NUMBER;

PROCEDURE createNomLocTarget(p_nomloc_id VARCHAR2,p_daytime DATE,p_change_reason VARCHAR2,p_valid_from DATE,p_user VARCHAR2 DEFAULT NULL);

FUNCTION getEndDayTargetQty(p_object_id VARCHAR2,p_daytime DATE,p_production_day DATE) RETURN NUMBER;
FUNCTION getNomLocProfile(p_object_id varchar2, p_daytime DATE, p_production_day DATE) RETURN NUMBER;
END EcBp_Dry_Gas_Target;