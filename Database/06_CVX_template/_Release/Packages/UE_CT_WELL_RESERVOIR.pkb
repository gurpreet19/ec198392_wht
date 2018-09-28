CREATE OR REPLACE PACKAGE BODY UE_CT_Well_Reservoir IS
/****************************************************************
** Package : UE_CT_Well_Reservoir
**
** $Revision: 1.29.2.3 $
**
** Purpose : This package defines well/reservoir related
** functionality.

** Documentation: www.energy-components.com
**
** Created : 18.11.1999 Carl-Fredrik Sørensen
**
** Modification history:
**
** Date           Whom     Change description:
** ------------  -----------------------------------
** 24.08.2011     LBFK     First Version
** 24.01.2012     JGIH     Package modified to include only
**                   	   relevant code for zonal allocation.
*****************************************************************/

------------------------------------------------------------------------------------
CURSOR c_parent_reservoir(p_rbf_id VARCHAR2) IS 
SELECT NVL(A.RESV_FORMATION_ID,A.OBJECT_ID) AS OBJECT_ID
 FROM RESV_FORMATION A, RESV_BLOCK_FORMATION B 
 WHERE A.OBJECT_ID = B.RESV_FORMATION_ID
 AND B.OBJECT_ID = p_rbf_id;
------------------------------------------------------------------------------------
CURSOR c_reservoir(p_parent_rf_id VARCHAR2) IS 
SELECT RF.OBJECT_ID, RF.OBJECT_CODE
FROM RESV_FORMATION RF, RESV_FORMATION_VERSION RFV
WHERE RF.OBJECT_ID = RFV.OBJECT_ID
AND RFV.END_DATE IS NULL 
AND RF.OBJECT_ID = p_parent_rf_id;
------------------------------------------------------------------------------------
CURSOR c_zone(p_rbf_id VARCHAR2) IS 
SELECT A.OBJECT_ID, A.OBJECT_CODE
 FROM RESV_FORMATION A, RESV_BLOCK_FORMATION B, RESV_FORMATION_VERSION RFV 
 WHERE A.OBJECT_ID = B.RESV_FORMATION_ID
 AND A.OBJECT_ID = RFV.OBJECT_ID
 AND RFV.END_DATE IS NULL
 AND A.RESV_FORMATION_ID IS NOT NULL 
 AND B.OBJECT_ID = p_rbf_id;
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
-- Function : reservoir_id 
-- Parameters : RESV_BLOCK_FORMATION_ID 
-- Description : returns reservoir_id 
------------------------------------------------------------------------------------
FUNCTION reservoir_id(p_object_id VARCHAR2) 
RETURN RESV_FORMATION.OBJECT_ID%TYPE
 IS
 lv2_rf_obj_id RESV_FORMATION.OBJECT_ID%TYPE;
 lv2_return_obj_id RESV_FORMATION.OBJECT_ID%TYPE;
 BEGIN
 
 FOR cur_row in c_parent_reservoir(p_object_id) LOOP
 lv2_rf_obj_id := cur_row.object_id;
 END LOOP;

 FOR cur_row in c_reservoir(lv2_rf_obj_id) LOOP
 lv2_return_obj_id := cur_row.object_id;
 END LOOP;
 
 RETURN lv2_return_obj_id;
 END reservoir_id;
 
------------------------------------------------------------------------------------
-- Function : reservoir_code
--Parameters : RESV_BLOCK_FORMATION_ID 
-- Description : returns reservoir_code 
------------------------------------------------------------------------------------
FUNCTION reservoir_code(p_object_id VARCHAR2) 
RETURN RESV_FORMATION.OBJECT_CODE%TYPE
 IS
 lv2_rf_obj_id RESV_FORMATION.OBJECT_ID%TYPE;
 lv2_return_obj_code RESV_FORMATION.OBJECT_CODE%TYPE;
 BEGIN

 FOR cur_row in c_parent_reservoir(p_object_id) LOOP
 lv2_rf_obj_id := cur_row.object_id;
 END LOOP;

 FOR cur_row in c_reservoir(lv2_rf_obj_id) LOOP
 lv2_return_obj_code := cur_row.object_code;
 END LOOP;

 RETURN lv2_return_obj_code;
 END reservoir_code;
 
------------------------------------------------------------------------------------
-- Function : zone_id 
-- Parameters : RESV_BLOCK_FORMATION_ID 
-- Description : returns zone_id 
------------------------------------------------------------------------------------
FUNCTION zone_id(p_object_id VARCHAR2) 
RETURN RESV_FORMATION.OBJECT_ID%TYPE
 IS
 lv2_return_obj_id RESV_FORMATION.OBJECT_ID%TYPE;
 BEGIN
 
 FOR cur_row in c_zone(p_object_id) LOOP
 lv2_return_obj_id := cur_row.object_id;
 END LOOP;
 
 RETURN lv2_return_obj_id;
 END zone_id;
 
------------------------------------------------------------------------------------
-- Function : zone_code
--Parameters : RESV_BLOCK_FORMATION_ID 
-- Description : returns zone_code 
------------------------------------------------------------------------------------
FUNCTION zone_code(p_object_id VARCHAR2) 
RETURN RESV_FORMATION.OBJECT_CODE%TYPE
 IS
 lv2_rf_obj_id RESV_FORMATION.OBJECT_ID%TYPE;
 lv2_return_obj_code RESV_FORMATION.OBJECT_CODE%TYPE;
 BEGIN


 FOR cur_row in c_zone(p_object_id) LOOP
 lv2_return_obj_code := cur_row.object_code;
 END LOOP;

 RETURN lv2_return_obj_code;
 END zone_code;
 

END;
/

