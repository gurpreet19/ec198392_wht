CREATE OR REPLACE PACKAGE EcBp_Calc_Disp IS
/****************************************************************
** Package        :  EcBp_Calc_Disp
**
** $Revision: 1.3 $
**
** Purpose        :  This package is check if a dispatching calculation
**                   that is approved have already been run.
**
**
** Documentation  :  www.energy-components.com
**
** Created  : 06.03.2009  Olav N?and
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
** 1.0    06.03.2009  ON  First version
*****************************************************************/

PROCEDURE ValidateCalcRun(
    p_calc_collection_id VARCHAR2,
    p_from_date          DATE,
    p_to_date            DATE,
    p_job_no             NUMBER,
    p_nomcycle           VARCHAR2 DEFAULT NULL,
	p_job_id             VARCHAR2);

END EcBp_Calc_Disp;