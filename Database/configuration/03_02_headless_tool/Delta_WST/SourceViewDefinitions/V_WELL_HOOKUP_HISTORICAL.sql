CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_WELL_HOOKUP_HISTORICAL" ("CLASS_NAME", "OBJECT_ID", "OBJECT_CODE", "OBJECT_START_DATE", "OBJECT_END_DATE", "DESCRIPTION", "OBJECT_REV_NO", "DAYTIME", "END_DATE", "NAME", "CALC_RULE_ID", "ALLOC_SEQ", "ALLOC_FLAG", "CAN_PROC_GAS", "CAN_PROC_OIL", "CAN_PROC_WAT", "CAN_PROC_COND", "CAN_PROC_GASINJ", "CAN_PROC_WATINJ", "CAN_PROC_STEAMINJ", "CAN_PROC_GASLIFT", "CAN_PROC_DILUENT", "CAN_PROC_CO2", "CAN_PROC_CO2INJ", "DIAGRAM_LAYOUT_INFO", "RECONCILIATION_METHOD", "COMMENTS", "OP_PU_ID", "OP_PU_CODE", "OP_SUB_PU_ID", "OP_SUB_PU_CODE", "OP_AREA_ID", "OP_AREA_CODE", "OP_SUB_AREA_ID", "OP_SUB_AREA_CODE", "OP_FCTY_CLASS_2_ID", "OP_FCTY_CLASS_2_CODE", "OP_FCTY_CLASS_1_ID", "OP_FCTY_CLASS_1_CODE", "TEXT_1", "TEXT_2", "TEXT_3", "TEXT_4", "TEXT_5", "TEXT_6", "TEXT_7", "TEXT_8", "TEXT_9", "TEXT_10", "VALUE_1", "VALUE_2", "VALUE_3", "VALUE_4", "VALUE_5", "DATE_1", "DATE_2", "DATE_3", "DATE_4", "DATE_5", "REF_OBJECT_ID_1", "REF_OBJECT_ID_2", "REF_OBJECT_ID_3", "REF_OBJECT_ID_4", "REF_OBJECT_ID_5", "GROUP_REF_ID_1", "GROUP_REF_CODE_1", "GROUP_REF_ID_2", "GROUP_REF_CODE_2", "GROUP_REF_ID_3", "GROUP_REF_CODE_3", "GROUP_REF_ID_4", "GROUP_REF_CODE_4", "GROUP_REF_ID_5", "GROUP_REF_CODE_5", "GROUP_REF_ID_6", "GROUP_REF_CODE_6", "GROUP_REF_ID_7", "GROUP_REF_CODE_7", "GROUP_REF_ID_8", "GROUP_REF_CODE_8", "GROUP_REF_ID_9", "GROUP_REF_CODE_9", "GROUP_REF_ID_10", "GROUP_REF_CODE_10", "VERSION_REV_NO", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
------------------------------------------------------------------------------------
--  V_WELL_HOOKUP_HISTORICAL
--
-- $Revision: 1.0 $
--
--  Purpose:   Use in Well Hookup Historical
--  Note:
--
--  Date           Whom 		Change description:
--  -------------- --------		--------
--  09-10-2015     abdulmaw     ECPD-30931:Intial version
-------------------------------------------------------------------------------------
SELECT
'V_WELL_HOOKUP_HISTORICAL' AS CLASS_NAME
,o.OBJECT_ID
,o.OBJECT_CODE
,o.START_DATE AS OBJECT_START_DATE
,o.END_DATE AS OBJECT_END_DATE
,o.DESCRIPTION
,o.REV_NO AS OBJECT_REV_NO
,oa.DAYTIME
,oa.END_DATE
,oa.NAME
,oa.CALC_RULE_ID
,oa.ALLOC_SEQ
,oa.ALLOC_FLAG
,oa.CAN_PROC_GAS
,oa.CAN_PROC_OIL
,oa.CAN_PROC_WAT
,oa.CAN_PROC_COND
,oa.CAN_PROC_GASINJ
,oa.CAN_PROC_WATINJ
,oa.CAN_PROC_STEAMINJ
,oa.CAN_PROC_GASLIFT
,oa.CAN_PROC_DILUENT
,oa.CAN_PROC_CO2
,oa.CAN_PROC_CO2INJ
,oa.DIAGRAM_LAYOUT_INFO
,oa.RECONCILIATION_METHOD
,oa.COMMENTS
,oa.OP_PU_ID
,oa.OP_PU_CODE
,oa.OP_SUB_PU_ID
,oa.OP_SUB_PU_CODE
,oa.OP_AREA_ID
,oa.OP_AREA_CODE
,oa.OP_SUB_AREA_ID
,oa.OP_SUB_AREA_CODE
,oa.OP_FCTY_CLASS_2_ID
,oa.OP_FCTY_CLASS_2_CODE
,oa.OP_FCTY_CLASS_1_ID
,oa.OP_FCTY_CLASS_1_CODE
,oa.TEXT_1
,oa.TEXT_2
,oa.TEXT_3
,oa.TEXT_4
,oa.TEXT_5
,oa.TEXT_6
,oa.TEXT_7
,oa.TEXT_8
,oa.TEXT_9
,oa.TEXT_10
,oa.VALUE_1
,oa.VALUE_2
,oa.VALUE_3
,oa.VALUE_4
,oa.VALUE_5
,oa.DATE_1
,oa.DATE_2
,oa.DATE_3
,oa.DATE_4
,oa.DATE_5
,oa.REF_OBJECT_ID_1
,oa.REF_OBJECT_ID_2
,oa.REF_OBJECT_ID_3
,oa.REF_OBJECT_ID_4
,oa.REF_OBJECT_ID_5
,oa.GROUP_REF_ID_1
,oa.GROUP_REF_CODE_1
,oa.GROUP_REF_ID_2
,oa.GROUP_REF_CODE_2
,oa.GROUP_REF_ID_3
,oa.GROUP_REF_CODE_3
,oa.GROUP_REF_ID_4
,oa.GROUP_REF_CODE_4
,oa.GROUP_REF_ID_5
,oa.GROUP_REF_CODE_5
,oa.GROUP_REF_ID_6
,oa.GROUP_REF_CODE_6
,oa.GROUP_REF_ID_7
,oa.GROUP_REF_CODE_7
,oa.GROUP_REF_ID_8
,oa.GROUP_REF_CODE_8
,oa.GROUP_REF_ID_9
,oa.GROUP_REF_CODE_9
,oa.GROUP_REF_ID_10
,oa.GROUP_REF_CODE_10
,oa.REV_NO AS VERSION_REV_NO
,oa.RECORD_STATUS AS RECORD_STATUS
,oa.CREATED_BY AS CREATED_BY
,oa.CREATED_DATE AS CREATED_DATE
,oa.LAST_UPDATED_BY AS LAST_UPDATED_BY
,oa.LAST_UPDATED_DATE AS LAST_UPDATED_DATE
,oa.REV_NO AS REV_NO
,oa.REV_TEXT AS REV_TEXT
FROM V_WELL_HOOKUP_HIST o, V_WELL_HOOKUP_VERSION_HIST oa
WHERE oa.object_id = o.object_id
)