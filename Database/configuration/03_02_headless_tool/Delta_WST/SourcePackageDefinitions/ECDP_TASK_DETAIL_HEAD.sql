CREATE OR REPLACE PACKAGE EcDp_Task_Detail IS

/****************************************************************
** Package        :  EcDp_Task_Detail, header part
**
** $Revision: 1.1 $
**
** Purpose        : Support functions for Task detail.
**
** Documentation  :  www.energy-components.com
**
** Created  : 11-Oct-2007
**
** Modification history:
**
**  Date     Whom  Change description:
**  ------   ----- --------------------------------------
** 11.10.07  AV    Initial version of package
*****************************************************************/

FUNCTION RecIDDetailDescription(
    p_class_name  IN VARCHAR2,
    p_rec_id      IN VARCHAR2
    ) RETURN VARCHAR2;




END EcDp_Task_Detail;