CREATE OR REPLACE PACKAGE EcDp_Storage_Receipt IS
/****************************************************************
** Package        :  EcDp_Storage_Receipt; head part
**
** $Revision: 1.2 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created        :  05.09.2006	Kari Sandvik
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------
*****************************************************************/

FUNCTION getPlannedDayCompany(p_storage_id VARCHAR2, p_pc_id VARCHAR2, p_company_id VARCHAR2, p_daytime DATE) RETURN NUMBER;

PROCEDURE aggrOfficial(p_object_id VARCHAR2, p_daytime DATE, p_type VARCHAR2, p_old_qty NUMBER, p_new_qty NUMBER,p_user VARCHAR2 DEFAULT NULL);

PROCEDURE calcLiftAccOfficial(p_object_id VARCHAR2, p_pc_id VARCHAR2, p_company_id VARCHAR2, p_daytime DATE, p_type VARCHAR2, p_old_qty NUMBER, p_new_qty NUMBER,p_user VARCHAR2 DEFAULT NULL);

END EcDp_Storage_Receipt;