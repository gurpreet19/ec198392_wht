CREATE OR REPLACE PACKAGE EcDp_DAC IS
/****************************************************************
** Package        :  EcDp_DAC, header part
**
** $Revision: 1.0 $
**
** Purpose        :
**
**
** Created  : 16-Feb-2018, Shengtong Zhong
**
** Modification history:
**
**  Date           Whom  Change description:
**  ------         ----- --------------------------------------
**  16-Feb-2018    Zho   Initial version
*****************************************************************/

PROCEDURE GenPackage(p_class_name VARCHAR2);
FUNCTION getAccessControlPredicate(p_class_type VARCHAR2, p_class_name VARCHAR2) RETURN VARCHAR2;
PROCEDURE activeObjectPartitioningCheck(p_t_basis_access_id VARCHAR2);

END EcDp_DAC;