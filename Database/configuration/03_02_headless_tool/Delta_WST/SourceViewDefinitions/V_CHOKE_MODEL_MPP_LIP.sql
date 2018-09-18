CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CHOKE_MODEL_MPP_LIP" ("OBJECT_ID", "DAYTIME", "LIP_INC", "MPP_QTY", "MPP_LIP", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_choke_model_mpp_lip.sql
-- View name: v_choke_model_mpp_lip
--
-- $Revision: 1.2 $
--
-- Purpose  : This view is used to find quantities of MPP and LIP for a sub choke for a day.
--
-- Modification history:
--
-- Date       Whom  Change description:
-- ---------- ----  --------------------------------------------------------------------------------
-- 24/01/11   rajarsar   ECPD-16283: Initial version
-- 13.07.2017 kashisag   ECPD-45817: Replaced sysdate with Ecdp_Timestamp.getCurrentSysdate
----------------------------------------------------------------------------------------------------
SELECT
op.object_id OBJECT_ID,
sd.daytime DAYTIME,
nvl(ecbp_choke_model.calcTotalLip(op.object_id,sd.daytime),0) LIP_INC,
op.mpp_qty MPP_QTY,
ecbp_choke_model.calcTotalMppLip(op.object_id,sd.daytime,'CHOKE_MODEL_MPP') MPP_LIP,
'P' AS RECORD_STATUS,
USER AS CREATED_BY,
Ecdp_Timestamp.getCurrentSysdate AS CREATED_DATE,
USER AS LAST_UPDATED_BY,
Ecdp_Timestamp.getCurrentSysdate AS LAST_UPDATED_DATE,
NULL AS REV_NO,
NULL AS REV_TEXT
FROM system_days sd, object_potential op
WHERE op.daytime = (select max(daytime) from object_potential op2
where op2.object_id = op.object_id
and   op2.daytime <= sd.daytime)
)
order by sd.daytime desc