CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_IS_TARGET_TAG_LIST" ("SOURCE_ID", "TAG_ID", "TARGET_TAG_ID", "TARGET_INTERVAL", "TARGET_FUNCTION", "TARGET_DATETIME", "FROM_UNIT", "TO_UNIT", "TEMPLATE_CODE", "REV_TEXT_VALUE", "DATA_CLASS", "ATTRIBUTE", "PK_ATTR_1", "PK_VAL_1", "PK_ATTR_2", "PK_VAL_2", "PK_ATTR_3", "PK_VAL_3", "PK_ATTR_4", "PK_VAL_4", "PK_ATTR_5", "PK_VAL_5", "PK_ATTR_6", "PK_VAL_6", "PK_ATTR_7", "PK_VAL_7", "PK_ATTR_8", "PK_VAL_8", "PK_ATTR_9", "PK_VAL_9", "PK_ATTR_10", "PK_VAL_10", "LAST_TRANSFER", "MINIMUM_SAMPLES", "USE_SUMMERTIME", "TARGET_TIME_CORRECTION", "TARGET_TRUNCATE", "TIME_ZONE_REGION") AS 
  SELECT
source_id
,tag_id
,tag_id target_tag_id
,TARGET_INTERVAL
,TARGET_FUNCTION
,TARGET_DATETIME
,FROM_UNIT
,TO_UNIT
,t.TEMPLATE_CODE
,REV_TEXT_VALUE
,DATA_CLASS
,ATTRIBUTE
,PK_ATTR_1
,PK_VAL_1
,PK_ATTR_2
,PK_VAL_2
,PK_ATTR_3
,PK_VAL_3
,PK_ATTR_4
,PK_VAL_4
,PK_ATTR_5
,PK_VAL_5
,PK_ATTR_6
,PK_VAL_6
,PK_ATTR_7
,PK_VAL_7
,PK_ATTR_8
,PK_VAL_8
,PK_ATTR_9
,PK_VAL_9
,PK_ATTR_10
,PK_VAL_10
,ecdp_date_time.local2utc(trunc(c.last_transfer, t.target_truncate),'N',
                          ecdp_ecishelper.getProdDayIdFromTagid(source_id, tag_id,pk_attr_1,pk_val_1,pk_attr_2,pk_val_2,
                                                                pk_attr_3,pk_val_3,pk_attr_4,pk_val_4,pk_attr_5,pk_val_5,
																pk_attr_6,pk_val_6,pk_attr_7,pk_val_7,pk_attr_8,pk_val_8,
																pk_attr_9,pk_val_9,pk_attr_10,pk_val_10)
) last_transfer
, minimum_samples
, use_summertime
, round(Nvl(-PROD_DAY_START,0)*3600) TARGET_TIME_CORRECTION
, TARGET_TRUNCATE
,ecdp_ecishelper.getTZRegionFromTagid(source_id, tag_id,pk_attr_1,pk_val_1,pk_attr_2,pk_val_2,
                                      pk_attr_3,pk_val_3,pk_attr_4,pk_val_4,pk_attr_5,pk_val_5,
									  pk_attr_6,pk_val_6,pk_attr_7,pk_val_7,pk_attr_8,pk_val_8,
									  pk_attr_9,pk_val_9,pk_attr_10,pk_val_10) Time_Zone_Region
FROM v_trans_config c, trans_template t
WHERE c.template_no = t.template_no
and c.active = 'Y'
and t.target_truncate is not null
union all
SELECT
source_id
,tag_id
,tag_id target_tag_id
,TARGET_INTERVAL
,TARGET_FUNCTION
,TARGET_DATETIME
,FROM_UNIT
,TO_UNIT
,t.TEMPLATE_CODE
,REV_TEXT_VALUE
,DATA_CLASS
,ATTRIBUTE
,PK_ATTR_1
,PK_VAL_1
,PK_ATTR_2
,PK_VAL_2
,PK_ATTR_3
,PK_VAL_3
,PK_ATTR_4
,PK_VAL_4
,PK_ATTR_5
,PK_VAL_5
,PK_ATTR_6
,PK_VAL_6
,PK_ATTR_7
,PK_VAL_7
,PK_ATTR_8
,PK_VAL_8
,PK_ATTR_9
,PK_VAL_9
,PK_ATTR_10
,PK_VAL_10
,ecdp_date_time.local2utc(c.last_transfer,'N',
                          ecdp_ecishelper.getProdDayIdFromTagid(source_id, tag_id,pk_attr_1,pk_val_1,pk_attr_2,pk_val_2,
                                                                pk_attr_3,pk_val_3,pk_attr_4,pk_val_4,pk_attr_5,pk_val_5,
																pk_attr_6,pk_val_6,pk_attr_7,pk_val_7,pk_attr_8,pk_val_8,
																pk_attr_9,pk_val_9,pk_attr_10,pk_val_10)
) last_transfer
, minimum_samples
, use_summertime
, round(Nvl(-PROD_DAY_START,0)*3600)
, TARGET_TRUNCATE
,ecdp_ecishelper.getTZRegionFromTagid(source_id, tag_id,pk_attr_1,pk_val_1,pk_attr_2,pk_val_2,
                                      pk_attr_3,pk_val_3,pk_attr_4,pk_val_4,pk_attr_5,pk_val_5,
									  pk_attr_6,pk_val_6,pk_attr_7,pk_val_7,pk_attr_8,pk_val_8,
									  pk_attr_9,pk_val_9,pk_attr_10,pk_val_10) Time_Zone_Region
FROM v_trans_config c, trans_template t
WHERE c.template_no = t.template_no
and c.active = 'Y'
and t.target_truncate is null