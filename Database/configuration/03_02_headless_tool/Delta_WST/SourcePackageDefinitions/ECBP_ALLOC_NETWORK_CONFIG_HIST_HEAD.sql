CREATE OR REPLACE PACKAGE EcBp_Alloc_Network_Config_Hist IS
/****************************************************************
** Package        :  EcBp_Alloc_Network_Config_Hist; head part
**
** $Revision: 1.1 $
**
** Purpose        :  Allocation Network List handler
**
** Documentation  :  www.energy-components.com
**
** Created        :  02/10/2015,  Wong Kai Chun
**
** Modification history:
**
** Date        Whom      Change description:
** ----------  -------   -------------------------------------------
** 02.10.2015  wonggkai  Initial Version
** 03.12.2015  wonggkai	 ECPD-33114: Historical Config need to check on the valid configuration from Allocation Network List
**************************************************************************************************/

FUNCTION getElement(p_run_no VARCHAR2, p_object_id VARCHAR2, p_run_date DATE, p_alloc_date DATE, p_daily_mthly VARCHAR2)
RETURN VARCHAR2;

END EcBp_Alloc_Network_Config_Hist;