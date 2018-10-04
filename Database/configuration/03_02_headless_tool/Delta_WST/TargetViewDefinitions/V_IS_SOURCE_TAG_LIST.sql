CREATE OR REPLACE FORCE VIEW "V_IS_SOURCE_TAG_LIST" ("SOURCE_ID", "TAG_ID", "NEXT_READ", "END_TIME", "SOURCE_INTERVAL", "SOURCE_FUNCTION", "SOURCE_DELAY", "SOURCE_DATATYPE", "TIME_ZONE_REGION", "TARGET_TIME_CORRECTION", "TARGET_FUNCTION", "SHIFT_TIME_TO_PERIOD_ST") AS 
  SELECT
m.source_id
,m.tag_id
,Nvl(st.next_read,
     ecdp_ecishelper.calcnextread(m.source_id, m.tag_id,pk_attr_1,pk_val_1,pk_attr_2,pk_val_2,
                                  pk_attr_3,pk_val_3,pk_attr_4,pk_val_4,pk_attr_5,pk_val_5,
								  pk_attr_6,pk_val_6,pk_attr_7,pk_val_7,pk_attr_8,pk_val_8,
								  pk_attr_9,pk_val_9,pk_attr_10,pk_val_10,tt.last_transfer,
								  t.prod_day_start,t.target_interval)) next_read
,NULL end_time
,t.source_interval
,t.source_function
,t.source_delay
,t.source_datatype
,ecdp_ecishelper.getTZRegionFromTagid(m.source_id, m.tag_id,pk_attr_1,pk_val_1,pk_attr_2,pk_val_2,
                                      pk_attr_3,pk_val_3,pk_attr_4,pk_val_4,pk_attr_5,pk_val_5,
									  pk_attr_6,pk_val_6,pk_attr_7,pk_val_7,pk_attr_8,pk_val_8,
									  pk_attr_9,pk_val_9,pk_attr_10,pk_val_10) Time_Zone_Region
, round(Nvl(-PROD_DAY_START,0)*3600) TARGET_TIME_CORRECTION
,TARGET_FUNCTION
,t.shift_time_to_period_st
FROM trans_mapping m,  trans_template t, trans_target_time tt, trans_source_time st
WHERE t.template_no = m.template_no
and   m.tag_id = tt.target_tagid
AND   m.active = 'Y'
AND   m.valid = 'Y'
AND   m.tag_id = st.tag_id (+)