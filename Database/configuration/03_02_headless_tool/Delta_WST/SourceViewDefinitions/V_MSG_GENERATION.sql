CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_MSG_GENERATION" ("MESSAGE_TYPE", "TO_PARAM_SET", "TO_PARAM", "DAYTIME", "FREQUENCY", "MESSAGE_NAME", "MESSAGE_DISTRIBUTION_NO", "MSG_TYPE_ID", "REV_TEXT", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "RECORD_STATUS") AS 
  (
SELECT ECDP_OBJECTS.GetObjCode (MD.OBJECT_ID) MESSAGE_TYPE,
           ECBP_MESSAGING.GETPARAMSETNAME (MD.MESSAGE_DISTRIBUTION_NO)
              TO_PARAM_SET,
           ECBP_MESSAGING.GetParamSetValue(MD.MESSAGE_DISTRIBUTION_NO) AS TO_PARAM,
           SD.DAYTIME AS DAYTIME,
           MDV.FREQUENCY AS FREQUENCY,
           ECDP_OBJECTS.GetObjName (MD.OBJECT_ID, SD.DAYTIME) MESSAGE_NAME,
           MD.MESSAGE_DISTRIBUTION_NO MESSAGE_DISTRIBUTION_NO,
           MD.OBJECT_ID AS msg_type_id,
           NULL AS REV_TEXT,
           NULL AS CREATED_BY,
           NULL AS CREATED_DATE,
           NULL AS LAST_UPDATED_BY,
           NULL AS LAST_UPDATED_DATE,
           NULL AS REV_NO,
           'P' AS RECORD_STATUS
      FROM MESSAGE_DISTRIBUTION MD,
           MESSAGE_DEF_VERSION MDV,
           SYSTEM_DAYS SD
     WHERE MD.OBJECT_ID = MDV.OBJECT_ID
       AND MDV.DAYTIME <= SD.DAYTIME AND (MDV.END_DATE > SD.DAYTIME OR MDV.END_DATE IS NULL)
)