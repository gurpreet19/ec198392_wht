CREATE OR REPLACE PACKAGE ue_Nompnt_Pc_Conn IS
/****************************************************************
** Package        :  ue_Nompnt_Pc_Conn; head part
**
** $Revision: 1.2 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created        :  19.04.2011	Kari Sandvik
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------

**************************************************************************************************/


PROCEDURE moveProfitCentre(p_daytime DATE, p_profit_centre_id VARCHAR2, p_nompnt_id VARCHAR2, p_company_id VARCHAR2, p_new_nompnt_id VARCHAR2);
PROCEDURE connectProfitCentre(p_daytime DATE, p_profit_centre_id VARCHAR2, p_nompnt_id VARCHAR2, p_company_id VARCHAR2, p_priority_split   NUMBER);

END ue_Nompnt_Pc_Conn;