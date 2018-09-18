CREATE OR REPLACE PACKAGE BODY EcBp_Alloc_Network_Config_Hist IS
/****************************************************************
** Package        :  EcBp_Alloc_Network_Config_Hist; body part
**
** $Revision: 1.1 $
**
** Purpose        :  Allocation Network Configuration History handler
**
** Documentation  :  www.energy-components.com
**
** Created        :  02/10/2015,  Wong Kai Chun
**
** Modification history:
**
** Date        Whom      Change description:
** ----------  --------  -------------------------------------------
** 02.10.2015  wonggkai  Initial Version
** 03.12.2015  wonggkai	 ECPD-33114: Historical Config need to check on the valid configuration from Allocation Network List
**************************************************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getElement
-- Description    : Get Element_ID
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : ALLOC_JOB_LOG, CALC_COLLECTION, DV_ALLOC_NETWORK_LIST, DV_ALLOC_NETWORK_LIST_JN
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

FUNCTION getElement(p_run_no VARCHAR2, p_object_id VARCHAR2, p_run_date DATE, p_alloc_date DATE, p_daily_mthly VARCHAR2) RETURN VARCHAR2
--</EC-DOC>
 IS

  lv2_element_flag     VARCHAR2(1);

BEGIN

  SELECT DECODE(count(1), 0, 'N', 'Y') INTO lv2_element_flag
  FROM ALLOC_JOB_LOG l
  INNER JOIN CALC_COLLECTION c ON l.calc_collection_id = c.object_id
  INNER JOIN (
    SELECT  DENSE_RANK() over (partition by element_id, nvl(LAST_UPDATED_DATE,created_date) order by rev_no desc) rank, daytime, 'CURRENT' JN_OPERATION, nvl(LAST_UPDATED_DATE,created_date) jn_upd_create_date, OBJECT_ID, ELEMENT_ID from DV_ALLOC_NETWORK_LIST
      WHERE nvl(LAST_UPDATED_DATE,created_date) < p_run_date
    UNION ALL
    SELECT  DENSE_RANK() over (partition by element_id, JN_DATETIME order by rev_no desc) rank, daytime, JN_OPERATION, nvl(LAST_UPDATED_DATE,created_date) jn_upd_create_date,OBJECT_ID, ELEMENT_ID from DV_ALLOC_NETWORK_LIST_JN
      WHERE nvl(LAST_UPDATED_DATE,created_date) < p_run_date
    ) n ON n.OBJECT_ID = c.object_id
  WHERE l.run_no = p_run_no and n.element_id = p_object_id
  AND rank = 1
  AND JN_OPERATION <> 'DEL'
  AND ((n.daytime <= p_alloc_date AND p_daily_mthly = 'D')
    OR (trunc(n.daytime,'MM') <= trunc(p_alloc_date,'MM') AND p_daily_mthly = 'M')) ;
  RETURN lv2_element_flag;

END getElement;

END EcBp_Alloc_Network_Config_Hist;