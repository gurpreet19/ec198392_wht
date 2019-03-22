CREATE OR REPLACE PACKAGE EcDp_Deferment_Log IS

/****************************************************************
** Package        :  EcDp_Deferment_Log, header part
**
** $Revision: 1.2 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Deferment.Logs
** Documentation  :  www.energy-components.com
**
** Created  : 04.10.2018  mehtajig
**
** Modification history:
**
** Version  Date       Whom     Change description:
** -------  ----------  -------- ----------------
****************************************************************************************/

procedure getStartEndDate(p_object_id VARCHAR2 DEFAULT NULL,p_nav_group_type VARCHAR2 DEFAULT NULL,p_nav_parent_class_name VARCHAR2 DEFAULT NULL,p_deferment_version VARCHAR2 DEFAULT NULL, p_from_date OUT DATE, p_to_date OUT DATE);

procedure insertStatusLog(p_run_no NUMBER, p_from_date DATE, p_to_date DATE);

procedure updateStatusLog(p_run_no NUMBER, p_exit_status VARCHAR2);

End EcDp_Deferment_Log;