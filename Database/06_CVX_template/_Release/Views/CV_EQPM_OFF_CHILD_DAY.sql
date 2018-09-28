---------------------------------------------------------------------------------------------------
--  CV_EQPM_OFF_CHILD_DAY
--
--  Purpose:           Provides downtime detail for equipment child records, providing 1 row for 
--            each day of the event
--
--
--  Notes:     
--
--      MVAS 05/2008    New
--     SRXT 05/2016     Updated to match the new business function and added a where clause condition with few columns changed
--
----------------------------------------------------------------------------------------------------- 


CREATE OR REPLACE VIEW CV_EQPM_OFF_CHILD_DAY
    AS
SELECT 
    PARENT_MASTER_EVENT_ID,
    PARENT_OBJECT_ID,
    PARENT_DAYTIME,
    OBJECT_ID, 
    OBJECT_TYPE, 
    DEFERMENT_TYPE,
    EVENT_TYPE,
    S.DAYTIME AS DAYTIME, 
    D.DAYTIME AS START_DATE, 
    END_DATE, 
    EQUIPMENT_ID,
    STATUS,
    COMMENTS, 
    D.RECORD_STATUS, 
    D.CREATED_BY, 
    D.CREATED_DATE, 
    D.LAST_UPDATED_BY, 
    D.LAST_UPDATED_DATE, 
    D.REV_NO, 
    D.REV_TEXT,
    D.APPROVAL_BY,
    D.APPROVAL_DATE,
    D.APPROVAL_STATE,
    D.REC_ID
FROM 
    DEFERMENT_EVENT D,
    SYSTEM_DAYS S
WHERE 
    S.DAYTIME >= TRUNC(D.DAYTIME-1) AND
    (S.DAYTIME <= TRUNC(D.END_DATE) OR D.END_DATE IS NULL) AND
    EVENT_TYPE = 'DOWN' AND D.OBJECT_TYPE in (select distinct eqpm_type from equipment) AND DEFERMENT_TYPE = 'GROUP_CHILD'
;



