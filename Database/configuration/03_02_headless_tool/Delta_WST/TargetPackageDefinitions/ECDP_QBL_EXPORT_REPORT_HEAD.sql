CREATE OR REPLACE PACKAGE EcDp_QBL_Export_Report IS
/****************************************************************
** Package        :  EcDp_QBL_Export_Report, header part
**
** $Revision: 1.3.32.1 $
**
** Purpose        :  Validation on the Report Columns.
**
** Documentation  :  www.energy-components.com
**
** Created  : 14.05.2009  Leong Weng Onn
**
** Modification history:
**
** Date        Who  Change description:
** ----------  ---- --------------------------------------
** 2009-05-14  LeongWen  Initial version
*****************************************************************/

PROCEDURE ValidateReportColumns(p_object_id varchar2, p_qbl_query_no varchar2);
PROCEDURE ValidateOwner(p_qbl_query_no varchar2);

END EcDp_QBL_Export_Report;