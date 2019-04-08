BEGIN

INSERT INTO TEST_DEVICE_ANALYSIS
    (OBJECT_ID, DAYTIME, PRODUCTION_DAY, WET_WATER, DRY_WATER, WET_GLYCOL, DRY_GLYCOL, NITRATE, FREEZE_POINT, CHLORIDE,
    OIL_IN_WATER, COMMENTS, VALUE_1, VALUE_2, VALUE_3, VALUE_4, VALUE_5, VALUE_6, VALUE_7, VALUE_8,
    VALUE_9, VALUE_10, VALUE_11, VALUE_12, VALUE_13, VALUE_14, VALUE_15, VALUE_16, VALUE_17, VALUE_18,
    VALUE_19, VALUE_20, VALUE_21, VALUE_22, VALUE_23, VALUE_24, VALUE_25, VALUE_26, VALUE_27, VALUE_28,
    VALUE_29, VALUE_30, TEXT_1, TEXT_2, TEXT_3, TEXT_4, TEXT_5, DATE_1, DATE_2, DATE_3,
    DATE_4, DATE_5, RECORD_STATUS, CREATED_BY, CREATED_DATE, LAST_UPDATED_BY, LAST_UPDATED_DATE, REV_NO, REV_TEXT, APPROVAL_BY,
    APPROVAL_DATE, APPROVAL_STATE, REC_ID)
  SELECT 
    OBJECT_ID, DAYTIME, PRODUCTION_DAY, WET_WATER, DRY_WATER, WET_GLYCOL, DRY_GLYCOL, NITRATE, FREEZE_POINT, CHLORIDE,
    OIL_IN_WATER, COMMENTS, VALUE_1, VALUE_2, VALUE_3, VALUE_4, VALUE_5, VALUE_6, VALUE_7, VALUE_8,
    VALUE_9, VALUE_10, VALUE_11, VALUE_12, VALUE_13, VALUE_14, VALUE_15, VALUE_16, VALUE_17, VALUE_18,
    VALUE_19, VALUE_20, VALUE_21, VALUE_22, VALUE_23, VALUE_24, VALUE_25, VALUE_26, VALUE_27, VALUE_28,
    VALUE_29, VALUE_30, TEXT_1, TEXT_2, TEXT_3, TEXT_4, TEXT_5, DATE_1, DATE_2, DATE_3,
    DATE_4, DATE_5, RECORD_STATUS, CREATED_BY, CREATED_DATE, LAST_UPDATED_BY, LAST_UPDATED_DATE, REV_NO, REV_TEXT, APPROVAL_BY,
    APPROVAL_DATE, APPROVAL_STATE, REC_ID
  FROM EQPM_ANALYSIS
  WHERE OBJECT_ID IN (
    SELECT OBJECT_ID FROM TEST_DEVICE);

DELETE FROM EQPM_ANALYSIS
WHERE OBJECT_ID IN (
	SELECT OBJECT_ID FROM TEST_DEVICE);
	
END;
--~^UTDELIM^~--	