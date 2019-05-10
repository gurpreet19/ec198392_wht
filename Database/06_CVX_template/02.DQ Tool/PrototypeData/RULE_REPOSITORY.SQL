--******************************************************************************************
--** SQL statements created by EC Configuration utility version 94001
--** Workbook source: P:\My Documents\TFS\CVX\9.3\Deployments\Enhancements\Data Quality Tool\PrototypeData\Rule Repository - Copy.xls
--** Computer name  : PBYKENX2347
--** User name      : Scott Sugarbaker
--** Date and time  : 12/16/2014 10:55:34 AM
--******************************************************************************************
set define off
--
--Extracting DELETE statements
--
--Extracting INSERT statements
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Perforation Split factors must sum to 100 %', 'VALIDITY', 'PERFORATION_INTERVALS', 'OBJECTS', 'WELL_BORE', 'SPLIT FACTOR', 'WELL_BORE_INTERVAL_ID', 'daytime', 'FROM (select s.WELL_BORE_INTERVAL_ID, d.daytime, sum(oil) as oil_tot, sum(gas) as gas_tot, sum(water) as water_tot
from Rv_perf_interval_split s, 
(select distinct WELL_BORE_INTERVAL_ID, daytime
from rv_perf_interval_split) d
where s.WELL_BORE_INTERVAL_ID = d.WELL_BORE_INTERVAL_ID
and s.daytime <= d.daytime
and nvl(s.end_date,d.daytime + 1) > d.daytime
group by S.WELL_BORE_INTERVAL_ID , d.daytime)
where (oil_tot <> 100 or gas_tot <> 100 or water_tot <> 100)', 'Perf splits- oil = :oil_tot , gas = :gas_tot , water = :water_tot', 'PERF_INTERVAL_SPLIT');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Well Bore Split factors do not add to 100%', 'VALIDITY', 'PERFORATION_INTERVALS', 'OBJECTS', 'WELL_BORE', 'SPLIT FACTOR', 'object_id', 'daytime', 'FROM (select s.object_ID, s.code, S.NAME, d.daytime, s.OP_SUB_PRODUCTIONUNIT_ID, s.OP_AREA_ID, s.OP_FCTY_2_ID, s.OP_FCTY_1_ID, sum(oil_contrib) as oil_tot, sum(gas_contrib) as gas_tot, sum(water_contrib) as water_tot
from rv_well_bore_split_factor s, 
(select distinct a.object_id, a.daytime
from rv_well_bore_split_factor a) d
where s.object_ID = d.object_ID
and s.daytime <= d.daytime
and nvl(s.end_date,d.daytime + 1) > d.daytime
group by S.object_ID ,s.code, S.NAME, s.OP_SUB_PRODUCTIONUNIT_ID, s.OP_AREA_ID, s.OP_FCTY_2_ID, s.OP_FCTY_1_ID, d.daytime
)
where (oil_tot <> 100 or gas_tot <> 100 or water_tot <> 100)', 'Well bore splits - oil = :oil_tot , gas = :gas_tot , water = :water_tot', 'WELL_BORE_SPLIT');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Stream Tag mapped to ended or disabled objects', 'CONSISTENCY', 'ECIS', 'TAG_DEFINITION', 'STREAM', 'DISABLED IND', 'pk_val_1', 'NULL', 'TAG_ID', 'FROM v_trans_config, class_attribute
where v_trans_config.attribute = class_attribute.attribute_name
and v_trans_config.data_class = class_attribute.class_name
and class_attribute.disabled_ind = ''Y''', 'Tag :TAG_ID for attribute =  :v_trans_config.attribute in class :v_trans_config.data_class', 'MAINTAIN_MAPPINGS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Well Tag mapped to ended or disabled objects', 'CONSISTENCY', 'ECIS', 'TAG_DEFINITION', 'WELL', 'DISABLED IND', 'pk_val_1', 'NULL', 'TAG_ID', 'FROM v_trans_config, class_attribute
where v_trans_config.attribute = class_attribute.attribute_name
and v_trans_config.data_class = class_attribute.class_name
and class_attribute.disabled_ind = ''Y''', 'Tag :TAG_ID for attribute =  :v_trans_config.attribute in class :v_trans_config.data_class', 'MAINTAIN_MAPPINGS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Equipment Tag mapped to ended or disabled objects', 'CONSISTENCY', 'ECIS', 'TAG_DEFINITION', 'EQUIPMENT', 'DISABLED IND', 'pk_val_1', 'NULL', 'TAG_ID', 'FROM v_trans_config, class_attribute
where v_trans_config.attribute = class_attribute.attribute_name
and v_trans_config.data_class = class_attribute.class_name
and class_attribute.disabled_ind = ''Y''', 'Tag :TAG_ID for attribute =  :v_trans_config.attribute in class :v_trans_config.data_class', 'MAINTAIN_MAPPINGS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Tank Tag mapped to ended or disabled objects', 'CONSISTENCY', 'ECIS', 'TAG_DEFINITION', 'TANK', 'DISABLED IND', 'pk_val_1', 'NULL', 'TAG_ID', 'FROM v_trans_config, class_attribute
where v_trans_config.attribute = class_attribute.attribute_name
and v_trans_config.data_class = class_attribute.class_name
and class_attribute.disabled_ind = ''Y''', 'Tag :TAG_ID for attribute =  :v_trans_config.attribute in class :v_trans_config.data_class', 'MAINTAIN_MAPPINGS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Prod Separator Tag mapped to wrong class/attr combination', 'CONSISTENCY', 'ECIS', 'TAG_DEFINITION', 'EQUIPMENT', 'METER FREQ', 'a.pk_val_1', 'NULL', 'TAG_ID', 'FROM V_TRANS_CONFIG a, ov_prodseparator o
where a.pk_val_1 = o.object_id
and a.active = ''Y''
and o.end_date is null
and a.DATA_CLASS = ''PSEP_DAY_STATUS''
and o.sepa_meter_freq != ''DAY''
and o.aggregate_flag != ''Y''', 'Tag :TAG_ID mapped to attribute :a.attribute in class :a.data_class , Object set to frequency :o.SEPA_METER_FREQ and aggregate flag set to :o.aggregate_flag', 'MAINTAIN_MAPPINGS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Tank Tag not read for 180 days', 'COMPLETENESS', 'ECIS', 'TAG_CAPTURE', 'TANK', 'LAST TRANSFER', 'pk_val_1', 'NULL', 'TAG_ID', 'FROM V_TRANS_CONFIG
where active = ''Y''
and (last_transfer < sysdate - 180 
or last_transfer is null)', 'TagID :TAG_ID for attribute :attribute and class :data_class has not been transferred since :last_transfer and written since :last_transfer_write', 'TRANS_TAG_ACTIVITY');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Stream Tag not read for 180 days', 'COMPLETENESS', 'ECIS', 'TAG_CAPTURE', 'STREAM', 'LAST TRANSFER', 'pk_val_1', 'NULL', 'TAG_ID', 'FROM V_TRANS_CONFIG
where active = ''Y''
and (last_transfer < sysdate - 180 
or last_transfer is null)', 'TagID :TAG_ID for attribute :attribute and class :data_class has not been transferred since :last_transfer and written since :last_transfer_write', 'TRANS_TAG_ACTIVITY');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Well Tag not read for 180 days', 'COMPLETENESS', 'ECIS', 'TAG_CAPTURE', 'WELL', 'LAST TRANSFER', 'pk_val_1', 'NULL', 'TAG_ID', 'FROM V_TRANS_CONFIG
where active = ''Y''
and (last_transfer < sysdate - 180 
or last_transfer is null)', 'TagID :TAG_ID for attribute :attribute and class :data_class has not been transferred since :last_transfer and written since :last_transfer_write', 'TRANS_TAG_ACTIVITY');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Equipment Tag not read for 180 days', 'COMPLETENESS', 'ECIS', 'TAG_CAPTURE', 'EQUIPMENT', 'LAST TRANSFER', 'pk_val_1', 'NULL', 'TAG_ID', 'FROM V_TRANS_CONFIG
where active = ''Y''
and (last_transfer < sysdate - 180 
or last_transfer is null)', 'TagID :TAG_ID for attribute :attribute and class :data_class has not been transferred since :last_transfer and written since :last_transfer_write', 'TRANS_TAG_ACTIVITY');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Equipment Missing unit of measure conversion for Tag', 'COMPLETENESS', 'ECIS', 'TAG_DEFINITION', 'EQUIPMENT', 'UOM CODE', 'v_trans_config.pk_val_1', 'NULL', 'TAG_ID', 'FROM v_trans_config, class_attr_presentation, ctrl_uom_setup
where v_trans_config.attribute = class_attr_presentation.attribute_name
and v_trans_config.data_class = class_attr_presentation.class_name
   and class_attr_presentation.uom_code = ctrl_uom_setup.measurement_type
   and v_trans_config.active = ''Y''
   and v_trans_config.from_unit is not null
   and ctrl_uom_setup.db_unit_ind = ''Y''
   and ( (ctrl_uom_setup.unit != v_trans_config.to_unit and
        ctrl_uom_setup.unit not in
        (select tv_unit_conversion.to_unit
            from tv_unit_conversion
           where tv_unit_conversion.from_unit = v_trans_config.to_unit)) or
        (v_trans_config.from_unit != v_trans_config.to_unit and
        v_trans_config.to_unit not in
        (select tv_unit_conversion.to_unit
            from tv_unit_conversion
           where tv_unit_conversion.from_unit = v_trans_config.from_unit)) or
        (ctrl_uom_setup.unit != v_trans_config.from_unit and
        v_trans_config.to_unit is null and
        ctrl_uom_setup.unit not in
        (select tv_unit_conversion.to_unit
            from tv_unit_conversion
           where tv_unit_conversion.from_unit = v_trans_config.from_unit)))', 'Tag :TAG_ID for attribute :v_trans_config.attribute and class :v_trans_config.data_class is mapping from scada unit :v_trans_config.from_unit to :v_trans_config.to_unit mapped to measurement_type :ctrl_uom_setup.measurement_type and class unit :ctrl_uom_setup.unit', 'MAINTAIN_MAPPINGS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Stream Missing unit of measure conversion for Tag', 'COMPLETENESS', 'ECIS', 'TAG_DEFINITION', 'STREAM', 'UOM CODE', 'v_trans_config.pk_val_1', 'NULL', 'TAG_ID', 'FROM v_trans_config, class_attr_presentation, ctrl_uom_setup
where v_trans_config.attribute = class_attr_presentation.attribute_name
and v_trans_config.data_class = class_attr_presentation.class_name
   and class_attr_presentation.uom_code = ctrl_uom_setup.measurement_type
   and v_trans_config.active = ''Y''
   and v_trans_config.from_unit is not null
   and ctrl_uom_setup.db_unit_ind = ''Y''
   and ( (ctrl_uom_setup.unit != v_trans_config.to_unit and
        ctrl_uom_setup.unit not in
        (select tv_unit_conversion.to_unit
            from tv_unit_conversion
           where tv_unit_conversion.from_unit = v_trans_config.to_unit)) or
        (v_trans_config.from_unit != v_trans_config.to_unit and
        v_trans_config.to_unit not in
        (select tv_unit_conversion.to_unit
            from tv_unit_conversion
           where tv_unit_conversion.from_unit = v_trans_config.from_unit)) or
        (ctrl_uom_setup.unit != v_trans_config.from_unit and
        v_trans_config.to_unit is null and
        ctrl_uom_setup.unit not in
        (select tv_unit_conversion.to_unit
            from tv_unit_conversion
           where tv_unit_conversion.from_unit = v_trans_config.from_unit)))', 'Tag :TAG_ID for attribute :v_trans_config.attribute and class :v_trans_config.data_class is mapping from scada unit :v_trans_config.from_unit to :v_trans_config.to_unit mapped to measurement_type :ctrl_uom_setup.measurement_type and class unit :ctrl_uom_setup.unit', 'MAINTAIN_MAPPINGS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Well Missing unit of measure conversion for Tag', 'COMPLETENESS', 'ECIS', 'TAG_DEFINITION', 'WELL', 'UOM CODE', 'v_trans_config.pk_val_1', 'NULL', 'TAG_ID', 'FROM v_trans_config, class_attr_presentation, ctrl_uom_setup
where v_trans_config.attribute = class_attr_presentation.attribute_name
and v_trans_config.data_class = class_attr_presentation.class_name
   and class_attr_presentation.uom_code = ctrl_uom_setup.measurement_type
   and v_trans_config.active = ''Y''
   and v_trans_config.from_unit is not null
   and ctrl_uom_setup.db_unit_ind = ''Y''
   and ( (ctrl_uom_setup.unit != v_trans_config.to_unit and
        ctrl_uom_setup.unit not in
        (select tv_unit_conversion.to_unit
            from tv_unit_conversion
           where tv_unit_conversion.from_unit = v_trans_config.to_unit)) or
        (v_trans_config.from_unit != v_trans_config.to_unit and
        v_trans_config.to_unit not in
        (select tv_unit_conversion.to_unit
            from tv_unit_conversion
           where tv_unit_conversion.from_unit = v_trans_config.from_unit)) or
        (ctrl_uom_setup.unit != v_trans_config.from_unit and
        v_trans_config.to_unit is null and
        ctrl_uom_setup.unit not in
        (select tv_unit_conversion.to_unit
            from tv_unit_conversion
           where tv_unit_conversion.from_unit = v_trans_config.from_unit)))', 'Tag :TAG_ID for attribute :v_trans_config.attribute and class :v_trans_config.data_class is mapping from scada unit :v_trans_config.from_unit to :v_trans_config.to_unit mapped to measurement_type :ctrl_uom_setup.measurement_type and class unit :ctrl_uom_setup.unit', 'MAINTAIN_MAPPINGS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Tank Missing unit of measure conversion for Tag', 'COMPLETENESS', 'ECIS', 'TAG_DEFINITION', 'TANK', 'UOM CODE', 'v_trans_config.pk_val_1', 'NULL', 'TAG_ID', 'FROM v_trans_config, class_attr_presentation, ctrl_uom_setup
where v_trans_config.attribute = class_attr_presentation.attribute_name
and v_trans_config.data_class = class_attr_presentation.class_name
   and class_attr_presentation.uom_code = ctrl_uom_setup.measurement_type
   and v_trans_config.active = ''Y''
   and v_trans_config.from_unit is not null
   and ctrl_uom_setup.db_unit_ind = ''Y''
   and ( (ctrl_uom_setup.unit != v_trans_config.to_unit and
        ctrl_uom_setup.unit not in
        (select tv_unit_conversion.to_unit
            from tv_unit_conversion
           where tv_unit_conversion.from_unit = v_trans_config.to_unit)) or
        (v_trans_config.from_unit != v_trans_config.to_unit and
        v_trans_config.to_unit not in
        (select tv_unit_conversion.to_unit
            from tv_unit_conversion
           where tv_unit_conversion.from_unit = v_trans_config.from_unit)) or
        (ctrl_uom_setup.unit != v_trans_config.from_unit and
        v_trans_config.to_unit is null and
        ctrl_uom_setup.unit not in
        (select tv_unit_conversion.to_unit
            from tv_unit_conversion
           where tv_unit_conversion.from_unit = v_trans_config.from_unit)))', 'Tag :TAG_ID for attribute :v_trans_config.attribute and class :v_trans_config.data_class is mapping from scada unit :v_trans_config.from_unit to :v_trans_config.to_unit mapped to measurement_type :ctrl_uom_setup.measurement_type and class unit :ctrl_uom_setup.unit', 'MAINTAIN_MAPPINGS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Stream Volume Tag mapped to a non-measured stream', 'CONSISTENCY', 'ECIS', 'TAG_DEFINITION', 'STREAM', 'STREAM TYPE', 'o.object_id', 'NULL', 'TAG_ID', 'FROM V_TRANS_CONFIG a, ov_stream o
where a.pk_val_1 = o.object_id
and a.active = ''Y''
and o.stream_type != ''M''
and o.end_date is null', 'Tag :TAG_ID mapped to attribute :a.attribute in class :a.data_class for a stream with a type of :stream_type', 'MAINTAIN_MAPPINGS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Daily Gas Stream Tag mapped to wrong class/attr combination', 'CONSISTENCY', 'ECIS', 'TAG_DEFINITION', 'STREAM', 'STRM SET LIST', 'o.object_id', 'NULL', 'TAG_ID', 'FROM V_TRANS_CONFIG a, ov_stream o
where a.pk_val_1 = o.object_id
and a.active = ''Y''
and o.end_date is null
and a.DATA_CLASS = ''STRM_DAY_STREAM_MEAS_GAS''
and (o.stream_phase != ''GAS'' or
not exists
(select 1
from strm_set_list
where o.object_id = strm_set_list.object_id
AND STRM_SET_LIST.END_DATE IS NULL
and strm_set_list.stream_set = ''PO.0002''))', 'Tag :TAG_ID mapped to attribute :a.attribute in class :a.data_class .  Object phase :o.stream_phase is not gas or stream not linked to strm set list PO.0002', 'MAINTAIN_MAPPINGS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Sub Day Gas Stream Tag mapped to wrong class/attr combination', 'CONSISTENCY', 'ECIS', 'TAG_DEFINITION', 'STREAM', 'METER FREQ', 'o.object_id', 'NULL', 'TAG_ID', 'FROM V_TRANS_CONFIG a, ov_stream o
where a.pk_val_1 = o.object_id
and a.active = ''Y''
and o.end_date is null
and a.DATA_CLASS = ''STRM_SUB_DAY_STATUS_GAS''
and (o.stream_phase != ''GAS'' or
stream_meter_freq in (''DAY'', ''MTH'', ''YR'', ''NA''))', 'Tag :TAG_ID mapped to attribute :a.attribute in class :a.data_class .  Object phase of :o.stream_phase is not gas or stream meter freq of :o.stream_meter_freq is not sub-daily', 'MAINTAIN_MAPPINGS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Daily Oil Stream Tag mapped to wrong class/attr combination', 'CONSISTENCY', 'ECIS', 'TAG_DEFINITION', 'STREAM', 'STRM SET LIST', 'o.object_id', 'NULL', 'TAG_ID', 'FROM V_TRANS_CONFIG a, ov_stream o
where a.pk_val_1 = o.object_id
and a.active = ''Y''
and o.end_date is null
and a.DATA_CLASS = ''STRM_DAY_STREAM_MEAS_OIL''
and (o.stream_phase not in ( ''OIL'',''CON'') or
not exists
(select 1
from strm_set_list
where o.object_id = strm_set_list.object_id
AND STRM_SET_LIST.END_DATE IS NULL
and strm_set_list.stream_set = ''PO.0001''))', 'Tag :TAG_ID mapped to attribute :a.attribute in class :a.data_class .  Object phase :o.stream_phase is not oil/cond or stream not linked to strm set list PO.0001', 'MAINTAIN_MAPPINGS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Daily Water Stream Tag mapped to wrong class/attr combination', 'CONSISTENCY', 'ECIS', 'TAG_DEFINITION', 'STREAM', 'STRM SET LIST', 'o.object_id', 'NULL', 'TAG_ID', 'FROM V_TRANS_CONFIG a, ov_stream o
where a.pk_val_1 = o.object_id
and a.active = ''Y''
and o.end_date is null
and a.DATA_CLASS = ''STRM_DAY_STREAM_MEAS_WAT''
and (o.stream_phase not in ( ''WAT'') or
not exists
(select 1
from strm_set_list
where o.object_id = strm_set_list.object_id
AND STRM_SET_LIST.END_DATE IS NULL
and strm_set_list.stream_set = ''PO.0003''))', 'Tag :TAG_ID mapped to attribute :a.attribute in class :a.data_class .  Object phase :o.stream_phase is not water or stream not linked to strm set list PO.0003', 'MAINTAIN_MAPPINGS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Daily Mass Stream Tag mapped to wrong class/attr combination', 'CONSISTENCY', 'ECIS', 'TAG_DEFINITION', 'STREAM', 'STRM SET LIST', 'o.object_id', 'NULL', 'TAG_ID', 'FROM V_TRANS_CONFIG a, ov_stream o
where a.pk_val_1 = o.object_id
and a.active = ''Y''
and o.end_date is null
and a.DATA_CLASS = ''STRM_DAY_STREAM_MASS''
and (o.stream_phase not in ( ''OIL'',''CON'') or
not exists
(select 1
from strm_set_list
where o.object_id = strm_set_list.object_id
AND STRM_SET_LIST.END_DATE IS NULL
and strm_set_list.stream_set = ''PO.0001.03''))', 'Tag :TAG_ID mapped to attribute :a.attribute in class :a.data_class .  Object phase :o.stream_phase is not oil/cond or stream not linked to strm set list PO.0001.03', 'MAINTAIN_MAPPINGS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Daily Water Analysis Stream Tag mapped to wrong class/attr combination', 'CONSISTENCY', 'ECIS', 'TAG_DEFINITION', 'STREAM', 'STRM SET LIST', 'o.object_id', 'NULL', 'TAG_ID', 'FROM V_TRANS_CONFIG a, ov_stream o
where a.pk_val_1 = o.object_id
and a.active = ''Y''
and o.end_date is null
and a.DATA_CLASS in ( ''STRM_DAY_STREAM_WATER'', ''STRM_DAY_WATER_ANALYSIS'')
and (o.stream_phase not in ( ''WAT'') or
not exists
(select 1
from strm_set_list
where o.object_id = strm_set_list.object_id
AND STRM_SET_LIST.END_DATE IS NULL
and strm_set_list.stream_set = ''PO.0004''))', 'Tag :TAG_ID mapped to attribute :a.attribute in class :a.data_class .  Object phase :o.stream_phase is not water or stream not linked to strm set list PO.0004', 'MAINTAIN_MAPPINGS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Oil Analysis Stream Tag mapped to wrong class/attr combination', 'CONSISTENCY', 'ECIS', 'TAG_DEFINITION', 'STREAM', 'STRM SET LIST', 'o.object_id', 'NULL', 'TAG_ID', 'FROM V_TRANS_CONFIG a, ov_stream o
where a.pk_val_1 = o.object_id
and a.active = ''Y''
and o.end_date is null
and a.DATA_CLASS = ''STRM_OIL_ANALYSIS''
and (o.stream_phase not in ( ''OIL'',''CON'') or
not exists
(select 1
from strm_set_list
where o.object_id = strm_set_list.object_id
AND STRM_SET_LIST.END_DATE IS NULL
and strm_set_list.stream_set = ''PO.0019''))', 'Tag :TAG_ID mapped to attribute :a.attribute in class :a.data_class .  Object phase :o.stream_phase is not oil/cond or stream not linked to strm set list PO.0019', 'MAINTAIN_MAPPINGS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Gas Analysis Stream Tag mapped to wrong class/attr combination', 'CONSISTENCY', 'ECIS', 'TAG_DEFINITION', 'STREAM', 'STRM SET LIST', 'o.object_id', 'NULL', 'TAG_ID', 'FROM V_TRANS_CONFIG a, ov_stream o
where a.pk_val_1 = o.object_id
and a.active = ''Y''
and o.end_date is null
and a.DATA_CLASS = ''STRM_GAS_ANALYSIS''
and (o.stream_phase not in ( ''GAS'') or
not exists
(select 1
from strm_set_list
where o.object_id = strm_set_list.object_id
AND STRM_SET_LIST.END_DATE IS NULL
and strm_set_list.stream_set = ''PO.0020''))', 'Tag :TAG_ID mapped to attribute :a.attribute in class :a.data_class .  Object phase :o.stream_phase is not Gas or stream not linked to strm set list PO.0020', 'MAINTAIN_MAPPINGS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Fluid Component Analysis Stream Tag mapped to wrong class/attr combination', 'CONSISTENCY', 'ECIS', 'TAG_DEFINITION', 'STREAM', 'STRM SET LIST', 'o.object_id', 'NULL', 'TAG_ID', 'FROM V_TRANS_CONFIG a, ov_stream o
where a.pk_val_1 = o.object_id
and a.active = ''Y''
and o.end_date is null
and a.DATA_CLASS = ''FLUID_ANALYSIS_COMPONENT''
and (o.stream_phase not in ( ''GAS'',''OIL'',''CON'') or
not exists
(select 1
from strm_set_list
where o.object_id = strm_set_list.object_id
AND STRM_SET_LIST.END_DATE IS NULL
and strm_set_list.stream_set IN (''PO.0019'',''PO.0020'')))', 'Tag :TAG_ID mapped to attribute :a.attribute in class :a.data_class .  Object phase :o.stream_phase is not oil/cond or stream not linked to strm set list PO.0019 or PO.0020', 'MAINTAIN_MAPPINGS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Monthly Liquid Stream Tag mapped to wrong class/attr combination', 'CONSISTENCY', 'ECIS', 'TAG_DEFINITION', 'STREAM', 'STRM SET LIST', 'o.object_id', 'NULL', 'TAG_ID', 'FROM V_TRANS_CONFIG a, ov_stream o
where a.pk_val_1 = o.object_id
and a.active = ''Y''
and o.end_date is null
and a.DATA_CLASS = ''STRM_MTH_LIQUID''
and (o.stream_phase not in ( ''OIL'',''CON'') or
not exists
(select 1
from strm_set_list
where o.object_id = strm_set_list.object_id
AND STRM_SET_LIST.END_DATE IS NULL
and strm_set_list.stream_set = ''PO.0041''))', 'Tag :TAG_ID mapped to attribute :a.attribute in class :a.data_class .  Object phase :o.stream_phase is not oil/cond or stream not linked to strm set list PO.0041', 'MAINTAIN_MAPPINGS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Equipment Event Tag mapped to wrong class/attr combination', 'CONSISTENCY', 'ECIS', 'TAG_DEFINITION', 'EQUIPMENT', 'USE IN BF', 'o.object_id', 'NULL', 'TAG_ID', 'FROM V_TRANS_CONFIG a, iv_equipment o
where a.pk_val_1 = o.object_id
and a.active = ''Y''
and a.data_class = ''EQPM_EVENT''
and o.end_date is null
and (o.eqpm_data_freq != ''EVENT'' or
o.eqpm_data_freq is null or
o.use_in_bf != ''PO.0064'' or
o.use_in_bf is null)', 'Tag :TAG_ID mapped to attribute :a.attribute in class :a.data_class.  Object set to frequency :o.eqpm_data_freq is not EVENT or BF :o.use_in_bf is not PO.0064', 'MAINTAIN_MAPPINGS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Daily Equipment Status Tag mapped to wrong class/attr combination', 'CONSISTENCY', 'ECIS', 'TAG_DEFINITION', 'EQUIPMENT', 'USE IN BF', 'o.object_id', 'NULL', 'TAG_ID', 'FROM V_TRANS_CONFIG a, iv_equipment o
where a.pk_val_1 = o.object_id
and a.active = ''Y''
and a.data_class = ''EQPM_DAY_STATUS''
and o.end_date is null
and (o.eqpm_data_freq != ''DAY'' or
o.eqpm_data_freq is null or
o.use_in_bf != ''PO.0011'' or
o.use_in_bf is null)', 'Tag :TAG_ID mapped to attribute :a.attribute in class :a.data_class.  Object set to frequency :o.eqpm_data_freq  is not DAY or BF :o.use_in_bf is not PO.0011', 'MAINTAIN_MAPPINGS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Daily Water Injection Well Status Tag mapped to wrong class/attr combination', 'CONSISTENCY', 'ECIS', 'TAG_DEFINITION', 'WELL', 'WELL TYPE', 'o.object_id', 'NULL', 'TAG_ID', 'FROM V_TRANS_CONFIG a, ov_well o
where a.pk_val_1 = o.object_id
and a.active = ''Y''
and a.data_class = ''IWEL_DAY_STATUS_WATER''
and o.well_type != ''WI''
and o.end_date is null', 'Tag :TAG_ID mapped to attribute :a.attribute in class :a.data_class.  Object has a well type of :o.well_type is not Water Injection', 'MAINTAIN_MAPPINGS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Daily Gas Injection Well Status Tag mapped to wrong class/attr combination', 'CONSISTENCY', 'ECIS', 'TAG_DEFINITION', 'WELL', 'WELL TYPE', 'o.object_id', 'NULL', 'TAG_ID', 'FROM V_TRANS_CONFIG a, ov_well o
where a.pk_val_1 = o.object_id
and a.active = ''Y''
and a.data_class = ''IWEL_DAY_STATUS_GAS''
and o.well_type != ''GI''
and o.end_date is null', 'Tag :TAG_ID mapped to attribute :a.attribute in class :a.data_class.  Object has a well type of :o.well_type is not Gas Injection', 'MAINTAIN_MAPPINGS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Daily Steam Injection Well Status Tag mapped to wrong class/attr combination', 'CONSISTENCY', 'ECIS', 'TAG_DEFINITION', 'WELL', 'WELL TYPE', 'o.object_id', 'NULL', 'TAG_ID', 'FROM V_TRANS_CONFIG a, ov_well o
where a.pk_val_1 = o.object_id
and a.active = ''Y''
and a.data_class = ''IWEL_DAY_STATUS_STEAM''
and o.well_type != ''SI''
and o.end_date is null', 'Tag :TAG_ID mapped to attribute :a.attribute in class :a.data_class.  Object has a well type of :o.well_type is not Steam Injection', 'MAINTAIN_MAPPINGS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Daily Air Injection Well Status Tag mapped to wrong class/attr combination', 'CONSISTENCY', 'ECIS', 'TAG_DEFINITION', 'WELL', 'WELL TYPE', 'o.object_id', 'NULL', 'TAG_ID', 'FROM V_TRANS_CONFIG a, ov_well o
where a.pk_val_1 = o.object_id
and a.active = ''Y''
and a.data_class = ''IWEL_DAY_STATUS_AIR''
and o.well_type != ''AI''
and o.end_date is null', 'Tag :TAG_ID mapped to attribute :a.attribute in class :a.data_class.  Object has a well type of :o.well_type is not Air Injection', 'MAINTAIN_MAPPINGS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Daily Production Well Status Tag mapped to wrong class/attr combination', 'CONSISTENCY', 'ECIS', 'TAG_DEFINITION', 'WELL', 'INSTR TYPE', 'o.object_id', 'NULL', 'TAG_ID', 'FROM V_TRANS_CONFIG a, ov_well o
where a.pk_val_1 = o.object_id
and a.active = ''Y''
and a.data_class = ''PWEL_DAY_STATUS''
and o.instrumentation_type != 1
and o.end_date is null', 'Tag :TAG_ID mapped to attribute :a.attribute in class :a.data_class.  Object set to instrumentation type :o.instrumentation_type is not 1', 'MAINTAIN_MAPPINGS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Daily Production Well Status - 2 Tag mapped to wrong class/attr combination', 'CONSISTENCY', 'ECIS', 'TAG_DEFINITION', 'WELL', 'INSTR TYPE', 'o.object_id', 'NULL', 'TAG_ID', 'FROM V_TRANS_CONFIG a, ov_well o
where a.pk_val_1 = o.object_id
and a.active = ''Y''
and a.data_class = ''PWEL_DAY_STATUS_2''
and o.instrumentation_type != 2
and o.end_date is null', 'Tag :TAG_ID mapped to attribute :a.attribute in class :a.data_class.  Object set to instrumentation type :o.instrumentation_type is not 2', 'MAINTAIN_MAPPINGS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Daily Production Well Status - 3 Tag mapped to wrong class/attr combination', 'CONSISTENCY', 'ECIS', 'TAG_DEFINITION', 'WELL', 'INSTR TYPE', 'o.object_id', 'NULL', 'TAG_ID', 'FROM V_TRANS_CONFIG a, ov_well o
where a.pk_val_1 = o.object_id
and a.active = ''Y''
and a.data_class = ''PWEL_DAY_STATUS_3''
and o.instrumentation_type != 3
and o.end_date is null', 'Tag :TAG_ID mapped to attribute :a.attribute in class :a.data_class.  Object set to instrumentation type :o.instrumentation_type is not 3', 'MAINTAIN_MAPPINGS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Daily Water Source Well Status Tag mapped to wrong class/attr combination', 'CONSISTENCY', 'ECIS', 'TAG_DEFINITION', 'WELL', 'WELL TYPE', 'o.object_id', 'NULL', 'TAG_ID', 'FROM V_TRANS_CONFIG a, ov_well o
where a.pk_val_1 = o.object_id
and a.active = ''Y''
and a.data_class = ''PWEL_DAY_STATUS_WS''
and o.WELL_TYPE != ''WS''
and o.end_date is null', 'Tag :TAG_ID mapped to attribute :a.attribute in class :a.data_class.  Object well type is :o.well_type is not WS', 'MAINTAIN_MAPPINGS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Tank Day Dip Status Tag mapped to wrong class/attr combination', 'CONSISTENCY', 'ECIS', 'TAG_DEFINITION', 'TANK', 'BF USAGE', 'o.object_id', 'NULL', 'TAG_ID', 'FROM V_TRANS_CONFIG a, ov_tank o
where a.pk_val_1 = o.object_id
and a.active = ''Y''
and o.end_date is null
and a.DATA_CLASS = ''TANK_DAY_DIP_STATUS''
and o.BF_USAGE != ''PO.0005.02''', 'Tag :TAG_ID mapped to attribute :a.attribute in class :a.data_class.  Object BF usage :o.bf_usage is not PO.0005.02', 'MAINTAIN_MAPPINGS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Tank Day Inventory Single Dip Tag mapped to wrong class/attr combination', 'CONSISTENCY', 'ECIS', 'TAG_DEFINITION', 'TANK', 'BF USAGE', 'o.object_id', 'NULL', 'TAG_ID', 'FROM V_TRANS_CONFIG a, ov_tank o
where a.pk_val_1 = o.object_id
and a.active = ''Y''
and o.end_date is null
and a.DATA_CLASS = ''TANK_DAY_INV_SINGLE_DIP''
and o.BF_USAGE != ''PO.0005.04''', 'Tag :TAG_ID mapped to attribute :a.attribute in class :a.data_class.  Object BF usage :o.bf_usage is not PO.0005.04', 'MAINTAIN_MAPPINGS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Tank Day Oil Inventory Tag mapped to wrong class/attr combination', 'CONSISTENCY', 'ECIS', 'TAG_DEFINITION', 'TANK', 'BF USAGE', 'o.object_id', 'NULL', 'TAG_ID', 'FROM V_TRANS_CONFIG a, ov_tank o
where a.pk_val_1 = o.object_id
and a.active = ''Y''
and o.end_date is null
and a.DATA_CLASS = ''TANK_DAY_INV_OIL''
and o.BF_USAGE != ''PO.0005''', 'Tag :TAG_ID mapped to attribute :a.attribute in class :a.data_class.  Object BF usage :o.bf_usage is not PO.0005', 'MAINTAIN_MAPPINGS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Tank Day Mass Inventory Tag mapped to wrong class/attr combination', 'CONSISTENCY', 'ECIS', 'TAG_DEFINITION', 'TANK', 'BF USAGE', 'o.object_id', 'NULL', 'TAG_ID', 'FROM V_TRANS_CONFIG a, ov_tank o
where a.pk_val_1 = o.object_id
and a.active = ''Y''
and o.end_date is null
and a.DATA_CLASS = ''TANK_DAY_INV_MASS''
and o.BF_USAGE != ''PO.0005.01''', 'Tag :TAG_ID mapped to attribute :a.attribute in class :a.data_class.  Object BF usage :o.bf_usage is not PO.0005.01', 'MAINTAIN_MAPPINGS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, COMMENTS, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, FROM_SQL, ADDNL_INFO) VALUES ('N', 'Daily perf alloc must be sum to daily well alloc', 'This is typically the result of re-allocating the well allocation without then re-allocating the perf allocation to pick up the modified allcoation results', 'CONSISTENCY', 'PERFORATION_INTERVALS', 'DAILY_VOLUMES', 'WELL', 'ALLOC GAS INJ', 'W.OBJECT_ID', 'W.DAYTIME', 'FROM (select
a.well_id, 
a.daytime,
round(sum(nvl(a.ALLOC_GAS_INJ_VOL,0)),0) as perf_tot_vol
from dv_perf_day_alloc a
where a.daytime >= :START_DATE and A.DAYTIME < :END_DATE
group by a.well_id, a.daytime
) p,
(
select
object_id,
daytime,
round(nvl(ALLOC_INJ_VOL,0),0) as well_vol
from Dv_iwel_day_alloc_gas 
where daytime >= :START_DATE and DAYTIME < :END_DATE
) w
where p.well_id = w.object_id
and w.daytime = p.daytime
and p.perf_tot_vol <> w.well_vol', 'Perf total  = :p.perf_tot_vol , well total = :w.well_vol');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, COMMENTS, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, FROM_SQL, ADDNL_INFO) VALUES ('N', 'Daily perf alloc must be sum to daily well alloc', 'This is typically the result of re-allocating the well allocation without then re-allocating the perf allocation to pick up the modified allcoation results', 'CONSISTENCY', 'PERFORATION_INTERVALS', 'DAILY_VOLUMES', 'WELL', 'ALLOC GAS', 'W.OBJECT_ID', 'W.DAYTIME', 'FROM (select
a.well_id, 
a.daytime,
round(sum(nvl(ALLOC_GAS_VOL,0)),0) as perf_tot_vol
from dv_perf_day_alloc a
where a.daytime >= :START_DATE and A.DAYTIME < :END_DATE
group by well_id, a.daytime
) p,
(
select
object_id,
daytime,
round(nvl(ALLOC_GAS_VOL,0),0) as well_vol
from Dv_Pwel_day_alloc
where daytime >= :START_DATE and DAYTIME < :END_DATE
) w
where p.well_id = w.object_id
and w.daytime = p.daytime
and p.perf_tot_vol <> w.well_vol', 'Perf total  = :p.perf_tot_vol , well total = :w.well_vol');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, COMMENTS, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, FROM_SQL, ADDNL_INFO) VALUES ('N', 'Daily perf oil alloc must be sum to daily well alloc', 'This is typically the result of re-allocating the well allocation without then re-allocating the perf allocation to pick up the modified allcoation results', 'CONSISTENCY', 'PERFORATION_INTERVALS', 'DAILY_VOLUMES', 'WELL', 'ALLOC OIL', 'W.OBJECT_ID', 'W.DAYTIME', 'FROM (select
a.well_id, 
a.daytime,
round(sum(nvl(ALLOC_NET_OIL_VOL,0)),0) as perf_tot_vol
from dv_perf_day_alloc a
where a.daytime >= :START_DATE and A.DAYTIME < :END_DATE
group by well_id, a.daytime
) p,
(
select
object_id,
daytime,
round(nvl(ALLOC_NET_OIL_VOL,0),0) as well_vol
from Dv_Pwel_day_alloc
where daytime >= :START_DATE and DAYTIME > :END_DATE
) w
where p.well_id = w.object_id
and w.daytime = p.daytime
and p.perf_tot_vol <> w.well_vol', 'Perf total  = :p.perf_tot_vol , well total = :w.well_vol');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, COMMENTS, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, FROM_SQL, ADDNL_INFO) VALUES ('N', 'Daily perf water inj alloc must be sum to daily well alloc', 'This is typically the result of re-allocating the well allocation without then re-allocating the perf allocation to pick up the modified allcoation results', 'CONSISTENCY', 'PERFORATION_INTERVALS', 'DAILY_VOLUMES', 'WELL', 'ALLOC WATER', 'W.OBJECT_ID', 'W.DAYTIME', 'FROM (select
a.well_id, 
a.daytime,
round(sum(nvl(ALLOC_WATER_INJ_VOL,0)),0) as perf_tot_vol
from dv_perf_day_alloc a
where a.daytime >= :START_DATE and A.DAYTIME < :END_DATE
group by well_id, a.daytime
) p,
(
select
object_id,
daytime,
round(nvl(ALLOC_INJ_VOL,0),0) as well_vol
from Dv_iwel_day_alloc_water 
where daytime >= :START_DATE and DAYTIME < :END_DATE
) w
where p.well_id = w.object_id
and w.daytime = p.daytime
and p.perf_tot_vol <> w.well_vol', 'Perf total  = :p.perf_tot_vol , well total = :w.well_vol');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, COMMENTS, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, FROM_SQL, ADDNL_INFO) VALUES ('N', 'Daily perf water alloc must be sum to daily well alloc', 'This is typically the result of re-allocating the well allocation without then re-allocating the perf allocation to pick up the modified allcoation results', 'CONSISTENCY', 'PERFORATION_INTERVALS', 'DAILY_VOLUMES', 'WELL', 'ALLOC WATER', 'W.OBJECT_ID', 'W.DAYTIME', 'FROM (select
a.well_id, 
a.daytime,
round(sum(nvl(ALLOC_WATER_VOL,0)),0) as perf_tot_vol
from dv_perf_day_alloc a
where a.daytime >= :START_DATE and A.DAYTIME < :END_DATE
group by well_id, a.daytime
) p,
(
select
object_id,
daytime,
round(nvl(ALLOC_WATER_VOL,0),0) as well_vol
from Dv_Pwel_day_alloc
where daytime >= :START_DATE and DAYTIME < :END_DATE
) w
where p.well_id = w.object_id
and w.daytime = p.daytime
and p.perf_tot_vol <> w.well_vol', 'Perf total  = :p.perf_tot_vol , well total = :w.well_vol');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, COMMENTS, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, FROM_SQL, ADDNL_INFO) VALUES ('N', 'Month perf gas inj alloc must be sum to mth well alloc', 'This is typically the result of re-allocating the well allocation without then re-allocating the perf allocation to pick up the modified allcoation results', 'CONSISTENCY', 'PERFORATION_INTERVALS', 'MONTHLY_ALLOCATIONS', 'WELL', 'ALLOC GAS INJ', 'W.OBJECT_ID', 'W.DAYTIME', 'FROM (select
a.well_id, 
a.daytime,
round(sum(nvl(ALLOC_GAS_INJ_VOL,0)),0) as perf_tot_vol
from Dv_perf_day_alloc a
where a.daytime >= :START_DATE and A.DAYTIME < :END_DATE
group by well_id, a.daytime
) p,
(
select
object_id,
daytime,
round(nvl(ALLOC_INJ_VOL,0),0) as well_vol
from Dv_iwel_day_alloc_gas
WHERE daytime >= :START_DATE and DAYTIME < :END_DATE
) w
where p.well_id = w.object_id
and w.daytime = p.daytime
and p.perf_tot_vol <> w.well_vol', 'Perf total  = :p.perf_tot_vol , well total = :w.well_vol');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, COMMENTS, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, FROM_SQL, ADDNL_INFO) VALUES ('N', 'Month perf gas alloc must be sum to mth well alloc', 'This is typically the result of re-allocating the well allocation without then re-allocating the perf allocation to pick up the modified allcoation results', 'CONSISTENCY', 'PERFORATION_INTERVALS', 'MONTHLY_ALLOCATIONS', 'WELL', 'ALLOC GAS', 'W.OBJECT_ID', 'W.DAYTIME', 'FROM (select
a.well_id, 
a.daytime,
round(sum(nvl(ALLOC_GAS_VOL,0)),0) as perf_tot_vol
from Dv_perf_day_alloc a
where a.daytime >= :START_DATE and A.DAYTIME < :END_DATE
group by well_id, a.daytime
) p,
(
select
object_id,
daytime,
round(nvl(ALLOC_gas_VOL,0),0) as well_vol
from Dv_pwel_day_alloc
WHERE daytime >= :START_DATE and DAYTIME < :END_DATE
) w
where p.well_id = w.object_id
and w.daytime = p.daytime
and p.perf_tot_vol <> w.well_vol', 'Perf total  = :p.perf_tot_vol , well total = :w.well_vol');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, COMMENTS, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, FROM_SQL, ADDNL_INFO) VALUES ('N', 'Month perf oil alloc must be sum to mth well alloc', 'This is typically the result of re-allocating the well allocation without then re-allocating the perf allocation to pick up the modified allcoation results', 'CONSISTENCY', 'PERFORATION_INTERVALS', 'MONTHLY_ALLOCATIONS', 'WELL', 'ALLOC OIL', 'W.OBJECT_ID', 'W.DAYTIME', 'FROM (select
a.well_id, 
a.daytime,
round(sum(nvl(ALLOC_NET_OIL_VOL,0)),0) as perf_tot_vol
from Dv_perf_day_alloc a
where a.daytime >= :START_DATE and A.DAYTIME < :END_DATE
group by well_id, a.daytime
) p,
(
select
object_id,
daytime,
round(nvl(ALLOC_NET_OIL_VOL,0),0) as well_vol
from Dv_pwel_day_alloc
WHERE daytime >= :START_DATE and DAYTIME < :END_DATE
) w
where p.well_id = w.object_id
and w.daytime = p.daytime
and p.perf_tot_vol <> w.well_vol', 'Perf total  = :p.perf_tot_vol , well total = :w.well_vol');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, COMMENTS, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, FROM_SQL, ADDNL_INFO) VALUES ('N', 'Month perf inj water alloc must be sum to mth well alloc', 'This is typically the result of re-allocating the well allocation without then re-allocating the perf allocation to pick up the modified allcoation results', 'CONSISTENCY', 'PERFORATION_INTERVALS', 'MONTHLY_ALLOCATIONS', 'WELL', 'ALLOC WATER INJ', 'W.OBJECT_ID', 'W.DAYTIME', 'FROM (select
a.well_id, 
a.daytime,
round(sum(nvl(ALLOC_WATER_INJ_VOL,0)),0) as perf_tot_vol
from Dv_perf_day_alloc a
where a.daytime >= :START_DATE and A.DAYTIME < :END_DATE
group by well_id, a.daytime
) p,
(
select
object_id,
daytime,
round(nvl(ALLOC_INJ_VOL,0),0) as well_vol
from Dv_iwel_day_alloc_WATER
WHERE daytime >= :START_DATE and DAYTIME < :END_DATE
) w
where p.well_id = w.object_id
and w.daytime = p.daytime
and p.perf_tot_vol <> w.well_vol', 'Perf total  = :p.perf_tot_vol , well total = :w.well_vol');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, COMMENTS, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, FROM_SQL, ADDNL_INFO) VALUES ('N', 'Month perf water alloc must be sum to mth well alloc', 'This is typically the result of re-allocating the well allocation without then re-allocating the perf allocation to pick up the modified allcoation results', 'CONSISTENCY', 'PERFORATION_INTERVALS', 'MONTHLY_ALLOCATIONS', 'WELL', 'ALLOC WATER', 'W.OBJECT_ID', 'W.DAYTIME', 'FROM (select
a.well_id, 
a.daytime,
round(sum(nvl(ALLOC_WATER_VOL,0)),0) as perf_tot_vol
from Dv_perf_day_alloc a
where a.daytime >= :START_DATE and A.DAYTIME < :END_DATE
group by well_id, a.daytime
) p,
(
select
object_id,
daytime,
round(nvl(ALLOC_WATER_VOL,0),0) as well_vol
from Dv_pwel_day_alloc
WHERE daytime >= :START_DATE and DAYTIME < :END_DATE
) w
where p.well_id = w.object_id
and w.daytime = p.daytime
and p.perf_tot_vol <> w.well_vol', 'Perf total  = :p.perf_tot_vol , well total = :w.well_vol');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, FROM_SQL, SCREEN_COMPONENT_ID) VALUES ('N', 'Gas lift wells missing gas lift method', 'COMPLETENESS', 'WELLS', 'OBJECTS', 'WELL', 'GAS LIFT METHOD', 'object_id', 'daytime', 'FROM OV_WELL
where WELL_TYPE = ''GL''
AND GAS_LIFT_METHOD IS NULL', 'WELL_MAINTAIN');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, COMMENTS, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Inj Gas Events remaining in NEW status', 'Injection Events are typically loaded into EC as NEW,and then require an operator to determine if the test should be ACCEPTED or REJECTED.  Records remaining in a NEW status are usually an indication that this review process has incorrectly been omitted. ', 'COMPLETENESS', 'WELLS', 'WELL_TESTS', 'WELL', 'STATUS', 'OBJECT_ID', 'DAYTIME', 'NULL', 'from DV_IWEL_EVENT_GAS
where status = ''NEW''', 'The well test was created on :created_date', 'GAS_INJ_WELL_DATA');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, COMMENTS, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Inj Water Events remaining in NEW status', 'Injection Events are typically loaded into EC as NEW,and then require an operator to determine if the test should be ACCEPTED or REJECTED.  Records remaining in a NEW status are usually an indication that this review process has incorrectly been omitted. ', 'COMPLETENESS', 'WELLS', 'WELL_TESTS', 'WELL', 'STATUS', 'OBJECT_ID', 'DAYTIME', 'NULL', 'from DV_IWEL_EVENT_WATER
where status = ''NEW''', 'The well test was created on :created_date', 'WAT_INJ_WELL_DATA');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, COMMENTS, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Inj Steam Events remaining in NEW status', 'Injection Events are typically loaded into EC as NEW,and then require an operator to determine if the test should be ACCEPTED or REJECTED.  Records remaining in a NEW status are usually an indication that this review process has incorrectly been omitted. ', 'COMPLETENESS', 'WELLS', 'WELL_TESTS', 'WELL', 'STATUS', 'OBJECT_ID', 'DAYTIME', 'NULL', 'from DV_IWEL_EVENT_STEAM
where status = ''NEW''', 'The well test was created on :created_date', 'STEAM_INJ_WELL_DATA');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Well Downtime Gas Loss rates cannot be negative', 'VALIDITY', 'WELLS', 'DOWNTIME', 'WELL', 'GAS LOSS RATE', 'object_id', 'daytime', 'FROM DV_WELL_EQPM_OFF_BY_WELL
where GAS_LOSS_RATE < 0', 'Gas loss rate = :gas_loss_rate', 'WELL_DOWNTIME');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Well Downtime Oil Loss rates cannot be negative', 'VALIDITY', 'WELLS', 'DOWNTIME', 'WELL', 'OIL LOSS RATE', 'object_id', 'daytime', 'FROM DV_WELL_EQPM_OFF_BY_WELL
where oil_LOSS_RATE < 0', 'Oil loss rate = :oil_loss_rate', 'WELL_DOWNTIME');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Entered Daily Gas Inj Status On Strm Hrs should be in range of 0 to 24', 'VALIDITY', 'WELLS', 'DAILY_DATA', 'WELL', 'ON STREAM HOURS', 'object_id', 'daytime', 'NULL', 'FROM DV_IWEL_DAY_STATUS_GAS
where (ON_STREAM_HRS < 0 OR ON_STREAM_HRS > 24 OR ON_STREAM_HRS is NULL)', 'The on stream hours = :decode(:on_stream_hrs,null,''NULL'',on_stream_hrs)', 'GAS_WELL_STATUS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Entered Daily Water Inj Status On Strm Hrs should be in range of 0 to 24', 'VALIDITY', 'WELLS', 'DAILY_DATA', 'WELL', 'ON STREAM HOURS', 'object_id', 'daytime', 'NULL', 'FROM DV_IWEL_DAY_STATUS_WATER
where (ON_STREAM_HRS < 0 OR ON_STREAM_HRS > 24 OR ON_STREAM_HRS is NULL)', 'The on stream hours = :decode(:on_stream_hrs,null,''NULL'',on_stream_hrs)', 'WATER_WELL_STATUS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Entered Daily Steam Inj Status On Strm Hrs should be in range of 0 to 24', 'VALIDITY', 'WELLS', 'DAILY_DATA', 'WELL', 'ON STREAM HOURS', 'object_id', 'daytime', 'NULL', 'FROM DV_IWEL_DAY_STATUS_STEAM
where (ON_STREAM_HRS < 0 OR ON_STREAM_HRS > 24 OR ON_STREAM_HRS is NULL)', 'The on stream hours = :decode(:on_stream_hrs,null,''NULL'',on_stream_hrs)', 'STEAM_WELL_STATUS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Entered Daily Prod Status On Stream Hours should be in range of 0 to 24', 'VALIDITY', 'WELLS', 'DAILY_DATA', 'WELL', 'ON STREAM HOURS', 'object_id', 'daytime', 'NULL', 'from DV_PWEL_DAY_STATUS
where (ON_STREAM_HRS < 0 OR ON_STREAM_HRS > 24 OR ON_STREAM_HRS is NULL)', 'The on stream hours = :decode(:on_stream_hrs,null,''NULL'',on_stream_hrs)', 'DAILY_WELL_STATUS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Entered Daily Prod Status 2 On Stream Hours should be in range of 0 to 24', 'VALIDITY', 'WELLS', 'DAILY_DATA', 'WELL', 'ON STREAM HOURS', 'object_id', 'daytime', 'NULL', 'from DV_PWEL_DAY_STATUS_2
where (ON_STREAM_HRS < 0 OR ON_STREAM_HRS > 24 OR ON_STREAM_HRS is NULL)', 'The on stream hours = :decode(:on_stream_hrs,null,''NULL'',on_stream_hrs)', 'DAILY_WELL_STATUS_2');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Entered Daily Prod Status 3 On Stream Hours should be in range of 0 to 24', 'VALIDITY', 'WELLS', 'DAILY_DATA', 'WELL', 'ON STREAM HOURS', 'object_id', 'daytime', 'NULL', 'from DV_PWEL_DAY_STATUS_3
where (ON_STREAM_HRS < 0 OR ON_STREAM_HRS > 24 OR ON_STREAM_HRS is NULL)', 'The on stream hours = :decode(:on_stream_hrs,null,''NULL'',on_stream_hrs)', 'DAILY_WELL_STATUS_3');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Entered Daily Gas Injection is negative', 'VALIDITY', 'WELLS', 'DAILY_DATA', 'WELL', 'GAS INJ', 'a.object_id', 'a.daytime', 'NULL', 'FROM DV_IWEL_DAY_STATUS_GAS a, ov_well o
where o.object_id = a.object_id
and o.daytime <= a.daytime
and nvl(o.end_date,to_date(''12/31/9999'',''mm/dd/yyyy'')) > a.daytime
AND O.alloc_flag = ''Y''
and a.inj_vol < 0', 'Gas injection volume equal to :a.inj_vol', 'GAS_WELL_STATUS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Entered Daily Water Injection is negative', 'VALIDITY', 'WELLS', 'DAILY_DATA', 'WELL', 'WATER INJ', 'a.object_id', 'a.daytime', 'NULL', 'FROM DV_IWEL_DAY_STATUS_water a, ov_well o
where o.object_id = a.object_id
and o.daytime <= a.daytime
and nvl(o.end_date,to_date(''12/31/9999'',''mm/dd/yyyy'')) > a.daytime
AND O.alloc_flag = ''Y''
and a.inj_vol < 0', 'Water injection volume equal to :a.inj_vol', 'WATER_WELL_STATUS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Calculated On hours is > 0 and entered Daily Injection gas volume = 0', 'CONSISTENCY', 'WELLS', 'DAILY_DATA', 'WELL', 'CALC ON HRS', 'a.object_id', 'A.DAYTIME', 'NULL', 'FROM DV_IWEL_DAY_STATUS_GAS a, ov_well o
where o.object_id = a.object_id
and o.daytime <= a.daytime
and nvl(o.end_date,to_date(''12/31/9999'',''mm/dd/yyyy'')) > a.daytime
AND O.alloc_flag = ''Y''
and calc_on_stream_hrs > 0
AND a.INJ_VOL = 0', 'The on stream hours = :on_stream_hrs', 'GAS_WELL_STATUS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Calculated On hours is > 0 and entered Daily Injection water volume = 0', 'CONSISTENCY', 'WELLS', 'DAILY_DATA', 'WELL', 'CALC ON HRS', 'a.object_id', 'A.DAYTIME', 'NULL', 'FROM DV_IWEL_DAY_STATUS_WATER a, ov_well o
where o.object_id = a.object_id
and o.daytime <= a.daytime
and nvl(o.end_date,to_date(''12/31/9999'',''mm/dd/yyyy'')) > a.daytime
AND O.alloc_flag = ''Y''
and calc_on_stream_hrs > 0 
AND a.INJ_VOL = 0', 'The on stream hours = :on_stream_hrs', 'WATER_WELL_STATUS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Calculated On hours is 0 and entered inj gas volume > 0', 'CONSISTENCY', 'WELLS', 'DAILY_DATA', 'WELL', 'CALC ON HRS', 'a.object_id', 'A.DAYTIME', 'NULL', 'FROM DV_IWEL_DAY_STATUS_GAS a, ov_well o
where o.object_id = a.object_id
and o.daytime <= a.daytime
and nvl(o.end_date,to_date(''12/31/9999'',''mm/dd/yyyy'')) > a.daytime
AND O.alloc_flag = ''Y''
and nvl(a.calc_on_stream_hrs,0) = 0
AND a.INJ_VOL > 0', 'The well has an entered injection volume = :a.INJ_VOL ', 'GAS_WELL_STATUS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Calculated On hours is 0 and entered inj water volume > 0', 'CONSISTENCY', 'WELLS', 'DAILY_DATA', 'WELL', 'CALC ON HRS', 'a.object_id', 'A.DAYTIME', 'NULL', 'FROM DV_IWEL_DAY_STATUS_WATER a, ov_well o
where o.object_id = a.object_id
and o.daytime <= a.daytime
and nvl(o.end_date,to_date(''12/31/9999'',''mm/dd/yyyy'')) > a.daytime
AND O.alloc_flag = ''Y''
and nvl(a.calc_on_stream_hrs,0) = 0
AND a.INJ_VOL > 0', 'The well has an entered injection volume = :a.INJ_VOL ', 'WATER_WELL_STATUS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Calculated On hours is 0 and entered inj steam volume > 0', 'CONSISTENCY', 'WELLS', 'DAILY_DATA', 'WELL', 'CALC ON HRS', 'a.object_id', 'A.DAYTIME', 'NULL', 'FROM DV_IWEL_DAY_STATUS_STEAM a, ov_well o
where o.object_id = a.object_id
and o.daytime <= a.daytime
and nvl(o.end_date,to_date(''12/31/9999'',''mm/dd/yyyy'')) > a.daytime
AND O.alloc_flag = ''Y''
and nvl(a.calc_on_stream_hrs,0) = 0
AND a.INJ_VOL > 0', 'The well has an entered injection volume = :a.INJ_VOL', 'STEAM_WELL_STATUS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, COMMENTS, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, SCREEN_COMPONENT_ID) VALUES ('N', 'Entered Daily Gas Injection is NULL for an allocated well', 'Instantiated injection day status records require the manual entry on the injection volume.  A NULL value typically means that a user forgot to enter this data.', 'COMPLETENESS', 'WELLS', 'DAILY_DATA', 'WELL', 'GAS INJ', 'a.object_id', 'a.daytime', 'NULL', 'from DV_IWEL_DAY_STATUS_GAS a, ov_well o
where o.object_id = a.object_id
and o.daytime <= a.daytime
and nvl(o.end_date,to_date(''12/31/9999'',''mm/dd/yyyy'')) > a.daytime
AND O.alloc_flag = ''Y''
and a.inj_vol is NULL', 'GAS_WELL_STATUS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, COMMENTS, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, SCREEN_COMPONENT_ID) VALUES ('N', 'Entered Daily Water Injection is NULL for an allocated well', 'Instantiated injection day status records require the manual entry on the injection volume.  A NULL value typically means that a user forgot to enter this data.', 'COMPLETENESS', 'WELLS', 'DAILY_DATA', 'WELL', 'WATER INJ', 'a.object_id', 'a.daytime', 'NULL', 'from DV_IWEL_DAY_STATUS_water a, ov_well o
where o.object_id = a.object_id
and o.daytime <= a.daytime
and nvl(o.end_date,to_date(''12/31/9999'',''mm/dd/yyyy'')) > a.daytime
AND O.alloc_flag = ''Y''
and a.inj_vol is NULL', 'WATER_WELL_STATUS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, COMMENTS, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'The well daily gas injection alloc results are negative', 'Negative allocation results are typically a sign of problems with the allocation set-up', 'VALIDITY', 'WELLS', 'DAILY_ALLOCATIONS', 'WELL', 'INJ VOL', 'OBJECT_ID', 'DAYTIME', 'NULL', 'from dv_iwel_day_alloc_gas
where ALLOC_INJ_VOL < 0', 'Allocated injection volume = :alloc_inj_vol', 'GAS_WELL_STATUS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, COMMENTS, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'The well daily water injection alloc results are negative', 'Negative allocation results are typically a sign of problems with the allocation set-up', 'VALIDITY', 'WELLS', 'DAILY_ALLOCATIONS', 'WELL', 'INJ VOL', 'OBJECT_ID', 'DAYTIME', 'NULL', 'from dv_iwel_day_alloc_water
where ALLOC_INJ_VOL < 0', 'Allocated injection volume = :alloc_inj_vol', 'WATER_WELL_STATUS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, COMMENTS, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'The well daily steam injection alloc results are negative', 'Negative allocation results are typically a sign of problems with the allocation set-up', 'VALIDITY', 'WELLS', 'DAILY_ALLOCATIONS', 'WELL', 'INJ VOL', 'OBJECT_ID', 'DAYTIME', 'NULL', 'from dv_iwel_day_alloc_steam
where ALLOC_INJ_VOL < 0', 'Allocated injection volume = :alloc_inj_vol', 'STEAM_WELL_STATUS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, COMMENTS, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Well daily alloc gas is negative', 'Negative allocation results are typically a sign of problems with the allocation set-up', 'VALIDITY', 'WELLS', 'DAILY_ALLOCATIONS', 'WELL', 'ALLOC GAS', 'object_id', 'DAYTIME', 'NULL', 'FROM Dv_pwel_day_alloc
where ALLOC_GAS_VOL < 0', 'The allocated gas volume = :alloc_gas_vol', 'DAILY_WELL_STATUS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, COMMENTS, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Well daily alloc gas lift is negative', 'Negative allocation results are typically a sign of problems with the allocation set-up', 'VALIDITY', 'WELLS', 'DAILY_ALLOCATIONS', 'WELL', 'ALLOC GAS LIFT', 'object_id', 'DAYTIME', 'NULL', 'FROM Dv_pwel_day_alloC
where ALLOC_GL_VOL < 0', 'The allocated gas lift volume = :alloc_gl_vol', 'DAILY_WELL_STATUS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, COMMENTS, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, SCREEN_COMPONENT_ID) VALUES ('N', 'Well daily allocated gas lift is NULL for GL well', 'NULL Gas lift results for gas lift wells is typically caused by incorrect gas lift set-up (e.g. forgetting to add a gas lift stream, or forgotting to mark the FC1 as supporting gas lift)', 'COMPLETENESS', 'WELLS', 'DAILY_ALLOCATIONS', 'WELL', 'ALLOC GAS LIFT', 'a.object_id', 'A.DAYTIME', 'NULL', 'FROM Dv_pwel_day_alloc A, OV_WELL O
where o.object_id = a.object_id
and o.daytime <= a.daytime
and nvl(o.end_date,to_date(''12/31/9999'',''mm/dd/yyyy'')) > a.daytime
AND O.PROD_METHOD = ''GL''
AND nvl(O.alloc_flag,''N'') = ''Y''
and A.on_stream_hrs > 0
and A.ALLOC_GL_VOL is NULL', 'DAILY_WELL_STATUS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, COMMENTS, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Non alloc well has daily alloc oil', 'Having allocation results posted for a non-allocated well is usually the result of changing the allocation flag after an allocation.', 'CONSISTENCY', 'WELLS', 'DAILY_ALLOCATIONS', 'WELL', 'ALLOC OIL', 'a.object_id', 'A.DAYTIME', 'NULL', 'FROM DV_PWEL_DAY_ALLOC A, OV_WELL O
where o.object_id = a.object_id
and o.daytime <= a.daytime
and nvl(o.end_date,to_date(''12/31/9999'',''mm/dd/yyyy'')) > a.daytime 
AND nvl(O.alloc_flag,''N'') = ''N''
and NVL(ALLOC_NET_OIL_VOL,0) <> 0', 'The allocated oil volume =  :a.alloc_net_oil_vol', 'DAILY_WELL_STATUS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, COMMENTS, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Well daily allocated oil is negative', 'Negative allocation results are typically a sign of problems with the allocation set-up', 'VALIDITY', 'WELLS', 'DAILY_ALLOCATIONS', 'WELL', 'ALLOC OIL', 'object_id', 'daytime', 'NULL', 'FROM Dv_pwel_day_alloc
where ALLOC_NET_OIL_VOL < 0', 'The allocated oil volume = :alloc_net_oil_vol', 'DAILY_WELL_STATUS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, SCREEN_COMPONENT_ID) VALUES ('N', 'Well daily allocated oil is NULL', 'COMPLETENESS', 'WELLS', 'DAILY_ALLOCATIONS', 'WELL', 'ALLOC OIL', 'a.object_id', 'a.daytime', 'NULL', 'FROM Dv_pwel_day_alloc A, OV_WELL O
where o.object_id = a.object_id
and o.daytime <= a.daytime
and nvl(o.end_date,to_date(''12/31/9999'',''mm/dd/yyyy'')) > a.daytime 
AND nvl(O.alloc_flag,''N'') = ''Y''
and A.on_stream_hrs > 0
and A.ALLOC_net_oil_vol is NULL
and O.well_type = ''OP''', 'DAILY_WELL_STATUS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, COMMENTS, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Well daily allocated water is negative', 'Negative allocation results are typically a sign of problems with the allocation set-up', 'VALIDITY', 'WELLS', 'DAILY_ALLOCATIONS', 'WELL', 'ALLOC WATER', 'object_id', 'daytime', 'NULL', 'FROM dv_pwel_day_alloc
where ALLOC_WATER_VOL < 0', 'The allocated water volume = :alloc_water_vol', 'DAILY_WELL_STATUS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, SCREEN_COMPONENT_ID) VALUES ('N', 'Well Daily allocated water is NULL', 'COMPLETENESS', 'WELLS', 'DAILY_ALLOCATIONS', 'WELL', 'ALLOC WATER', 'a.object_id', 'a.daytime', 'NULL', 'FROM Dv_pwel_day_alloc A, OV_WELL O
where o.object_id = a.object_id
and o.daytime <= a.daytime
and nvl(o.end_date,to_date(''12/31/9999'',''mm/dd/yyyy'')) > a.daytime 
AND nvl(O.alloc_flag,''N'') = ''Y''
and A.on_stream_hrs > 0
and A.ALLOC_WATER_vol is NULL', 'DAILY_WELL_STATUS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, SCREEN_COMPONENT_ID) VALUES ('N', 'Alloc well with on hours has NULL alloc gas inj vol', 'CONSISTENCY', 'WELLS', 'DAILY_ALLOCATIONS', 'WELL', 'INJ VOL', 'a.object_id', 'a.DAYTIME', 'NULL', 'FROM Dv_iwel_day_alloc a, ov_well o
where o.object_id = a.object_id
and o.daytime <= a.daytime
and nvl(o.end_date,to_date(''12/31/9999'',''mm/dd/yyyy'')) > a.daytime
and nvl(o.alloc_flag,''N'') = ''Y''
and a.ALLOC_INJ_VOL is NULL
and a.inj_type = ''GI''', 'GAS_WELL_STATUS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, SCREEN_COMPONENT_ID) VALUES ('N', 'Alloc well with on hours has NULL alloc water inj vol', 'CONSISTENCY', 'WELLS', 'DAILY_ALLOCATIONS', 'WELL', 'INJ VOL', 'a.object_id', 'a.DAYTIME', 'NULL', 'FROM Dv_iwel_day_alloc a, ov_well o
where o.object_id = a.object_id
and o.daytime <= a.daytime
and nvl(o.end_date,to_date(''12/31/9999'',''mm/dd/yyyy'')) > a.daytime
and nvl(o.alloc_flag,''N'') = ''Y''
and a.ALLOC_INJ_VOL is NULL
and a.inj_type = ''WI''', 'WATER_WELL_STATUS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, SCREEN_COMPONENT_ID) VALUES ('N', 'Alloc well with on hours has NULL alloc steam inj vol', 'CONSISTENCY', 'WELLS', 'DAILY_ALLOCATIONS', 'WELL', 'INJ VOL', 'a.object_id', 'a.DAYTIME', 'NULL', 'FROM Dv_iwel_day_alloc a, ov_well o
where o.object_id = a.object_id
and o.daytime <= a.daytime
and nvl(o.end_date,to_date(''12/31/9999'',''mm/dd/yyyy'')) > a.daytime
and nvl(o.alloc_flag,''N'') = ''Y''
and a.ALLOC_INJ_VOL is NULL
and a.inj_type = ''SI''', 'STEAM_WELL_STATUS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, COMMENTS, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Non-allocated well with alloc gas inj vol', 'Having allocation results posted for a non-allocated well is usually the result of changing the allocation flag after an allocation.', 'CONSISTENCY', 'WELLS', 'DAILY_ALLOCATIONS', 'WELL', 'INJ VOL', 'a.object_id', 'a.DAYTIME', 'NULL', 'FROM DV_IWEL_DAY_ALLOC_GAS a, ov_well o
where o.object_id = a.object_id
and o.daytime <= a.daytime
and nvl(o.end_date,to_date(''12/31/9999'',''mm/dd/yyyy'')) > a.daytime
and nvl(o.alloc_flag,''N'') = ''N''
and NVL(a.ALLOC_INJ_VOL,0) <> 0', 'allocated injection volume =  :a.alloc_inj_vol', 'GAS_WELL_STATUS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, COMMENTS, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Non-allocated well with alloc water inj vol', 'Having allocation results posted for a non-allocated well is usually the result of changing the allocation flag after an allocation.', 'CONSISTENCY', 'WELLS', 'DAILY_ALLOCATIONS', 'WELL', 'INJ VOL', 'a.object_id', 'a.DAYTIME', 'NULL', 'FROM DV_IWEL_DAY_ALLOC_WATER a, ov_well o
where o.object_id = a.object_id
and o.daytime <= a.daytime
and nvl(o.end_date,to_date(''12/31/9999'',''mm/dd/yyyy'')) > a.daytime
and nvl(o.alloc_flag,''N'') = ''N''
and NVL(a.ALLOC_INJ_VOL,0) <> 0', 'allocated injection volume =  :a.alloc_inj_vol', 'WATER_WELL_STATUS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, COMMENTS, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Non-allocated well with alloc steam inj vol', 'Having allocation results posted for a non-allocated well is usually the result of changing the allocation flag after an allocation.', 'CONSISTENCY', 'WELLS', 'DAILY_ALLOCATIONS', 'WELL', 'INJ VOL', 'a.object_id', 'a.DAYTIME', 'NULL', 'FROM DV_IWEL_DAY_ALLOC_STEAM a, ov_well o
where o.object_id = a.object_id
and o.daytime <= a.daytime
and nvl(o.end_date,to_date(''12/31/9999'',''mm/dd/yyyy'')) > a.daytime
and nvl(o.alloc_flag,''N'') = ''N''
and NVL(a.ALLOC_INJ_VOL,0) <> 0', 'allocated injection volume =  :a.alloc_inj_vol', 'STEAM_WELL_STATUS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, COMMENTS, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Non-allocated wells has daily alloc gas', 'Having allocation results posted for a non-allocated well is usually the result of changing the allocation flag after an allocation.', 'CONSISTENCY', 'WELLS', 'DAILY_ALLOCATIONS', 'WELL', 'ALLOC GAS', 'a.object_id', 'a.daytime', 'NULL', 'FROM DV_PWEL_DAY_ALLOC A, OV_WELL O
where o.object_id = a.object_id
and o.daytime <= a.daytime
and nvl(o.end_date,to_date(''12/31/9999'',''mm/dd/yyyy'')) > a.daytime 
AND nvl(O.alloc_flag,''N'') = ''N''
and NVL(A.ALLOC_GAS_VOL,0) <> 0', 'The allocated gas volume = :a.alloc_gas_vol', 'DAILY_WELL_STATUS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, COMMENTS, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Non-allocated wells has daily alloc water', 'Having allocation results posted for a non-allocated well is usually the result of changing the allocation flag after an allocation.', 'CONSISTENCY', 'WELLS', 'DAILY_ALLOCATIONS', 'WELL', 'ALLOC WATER', 'a.object_id', 'A.DAYTIME', 'NULL', 'FROM DV_PWEL_DAY_ALLOC A, OV_WELL O
where o.object_id = a.object_id
and o.daytime <= a.daytime
and nvl(o.end_date,to_date(''12/31/9999'',''mm/dd/yyyy'')) > a.daytime 
AND nvl(O.alloc_flag,''N'') = ''N''
and NVL(A.ALLOC_WATER_VOL,0) <> 0', 'The allocated water volume = :a.alloc_water_vol', 'DAILY_WELL_STATUS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, FROM_SQL, SCREEN_COMPONENT_ID) VALUES ('N', 'Calculated On Strm hrs > 0 and daily alloc well vol is 0', 'CONSISTENCY', 'WELLS', 'DAILY_ALLOCATIONS', 'WELL', 'CALC ON HRS', 'a.object_id', 'a.daytime', 'FROM DV_PWEL_DAY_ALLOC A, OV_WELL O
where o.object_id = a.object_id
and o.daytime <= a.daytime
and nvl(o.end_date,to_date(''12/31/9999'',''mm/dd/yyyy'')) > a.daytime 
AND alloc_flag = ''Y''
and (nvl(alloc_net_oil_vol,0) = 0 
and nvl(alloc_gas_vol,0) = 0 
and nvl(alloc_water_vol,0) = 0)
and on_stream_hrs > 0', 'DAILY_WELL_STATUS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Calculated On Stream Hours > 0 and daily well allocated gas injection = 0', 'CONSISTENCY', 'WELLS', 'DAILY_ALLOCATIONS', 'WELL', 'CALC ON HRS', 'a.object_id', 'a.daytime', 'FROM DV_IWEL_DAY_ALLOC A, OV_WELL O
where o.object_id = a.object_id
and o.daytime <= a.daytime
and nvl(o.end_date,to_date(''12/31/9999'',''mm/dd/yyyy'')) > a.daytime 
AND alloc_flag = ''Y''
and on_stream_hrs > 0
and nvl(alloc_inj_vol,0) = 0
and a.inj_type = ''GI''', 'On stream hours =  :on_stream_hrs and well type = :o.well_type', 'GAS_WELL_STATUS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Calculated On Stream Hours > 0 and daily well allocated water injection = 0', 'CONSISTENCY', 'WELLS', 'DAILY_ALLOCATIONS', 'WELL', 'CALC ON HRS', 'a.object_id', 'a.daytime', 'FROM DV_IWEL_DAY_ALLOC A, OV_WELL O
where o.object_id = a.object_id
and o.daytime <= a.daytime
and nvl(o.end_date,to_date(''12/31/9999'',''mm/dd/yyyy'')) > a.daytime 
AND alloc_flag = ''Y''
and on_stream_hrs > 0
and nvl(alloc_inj_vol,0) = 0
and a.inj_type = ''WI''', 'On stream hours =  :on_stream_hrs and well type = :o.well_type', 'WATER_WELL_STATUS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Calculated On Stream Hours > 0 and daily well allocated steam injection = 0', 'CONSISTENCY', 'WELLS', 'DAILY_ALLOCATIONS', 'WELL', 'CALC ON HRS', 'a.object_id', 'a.daytime', 'FROM DV_IWEL_DAY_ALLOC A, OV_WELL O
where o.object_id = a.object_id
and o.daytime <= a.daytime
and nvl(o.end_date,to_date(''12/31/9999'',''mm/dd/yyyy'')) > a.daytime 
AND alloc_flag = ''Y''
and on_stream_hrs > 0
and nvl(alloc_inj_vol,0) = 0
and a.inj_type = ''SI''', 'On stream hours =  :on_stream_hrs and well type = :o.well_type', 'STEAM_WELL_STATUS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, FROM_SQL, SCREEN_COMPONENT_ID) VALUES ('N', 'Alloc well with on hours has NULL daily alloc gas', 'COMPLETENESS', 'WELLS', 'DAILY_ALLOCATIONS', 'WELL', 'CALC ON HRS', 'a.object_id', 'A.DAYTIME', 'FROM Dv_pwel_day_alloc A, OV_WELL O
where o.object_id = a.object_id
and o.daytime <= a.daytime
and nvl(o.end_date,to_date(''12/31/9999'',''mm/dd/yyyy'')) >  a.daytime
AND nvl(O.alloc_flag,''N'') = ''Y''
and A.on_stream_hrs > 0
and A.ALLOC_GAS_VOL is NULL', 'DAILY_WELL_STATUS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, COMMENTS, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Well Tests remaining in NEW status', 'Well Tests are typically loaded into EC as NEW,and then require an operator to determine if the test should be ACCEPTED or REJECTED.  Records remaining in a NEW status are usually an indication that this review process has incorrectly been omitted. ', 'COMPLETENESS', 'WELLS', 'WELL_TESTS', 'WELL', 'STATUS', 'OBJECT_ID', 'DAYTIME', 'RESULT_NO', 'from DV_ct_ptst_pwel_result
where status = ''NEW''', 'The well test was created on :created_date', 'PRODUCTION_TEST_RESULT');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, SCREEN_COMPONENT_ID) VALUES ('N', 'Oil Rate NULL on Accepted Well Test for OP well', 'COMPLETENESS', 'WELLS', 'WELL_TESTS', 'WELL', 'OIL RATE', 'a.object_id', 'a.daytime', 'RESULT_NO', 'FROM DV_CT_PTST_PWEL_RESULT A, ov_well o
where o.object_id = a.object_id
and o.daytime <= a.daytime
and nvl(o.end_date,to_date(''12/31/9999'',''mm/dd/yyyy'')) > a.daytime 
and A.STATUS = ''ACCEPTED''
and A.NET_OIL_RATE_ADJ is NULL
and o.well_type = ''OP''', 'PRODUCTION_TEST_RESULT');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, SCREEN_COMPONENT_ID) VALUES ('N', 'Pump_Speed NULL for pumping wells on Accepted Well Test', 'COMPLETENESS', 'WELLS', 'WELL_TESTS', 'WELL', 'PUMP SPEED', 'a.object_id', 'a.daytime', 'RESULT_NO', 'FROM DV_CT_PTST_PWEL_RESULT A, OV_WELL O
where o.object_id = a.object_id
and o.daytime <= a.daytime
and nvl(o.end_date,to_date(''12/31/9999'',''mm/dd/yyyy'')) > a.daytime 
AND O.prod_method = ''PU''
and A.STATUS = ''ACCEPTED''
and A.pump_speed is null', 'PRODUCTION_TEST_RESULT');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, SCREEN_COMPONENT_ID) VALUES ('N', 'Gas Lift Rate NULL on Accepted Well Test for GL Well', 'COMPLETENESS', 'WELLS', 'WELL_TESTS', 'WELL', 'GL RATE', 'a.object_id', 'a.daytime', 'RESULT_NO', 'FROM DV_CT_PTST_PWEL_RESULT A, OV_WELL O
where o.object_id = a.object_id
and o.daytime <= a.daytime
and nvl(o.end_date,to_date(''12/31/9999'',''mm/dd/yyyy'')) > a.daytime 
AND A.STATUS = ''ACCEPTED''
and O.well_type = ''GL''
and A.gl_rate is NULL', 'PRODUCTION_TEST_RESULT');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, COMMENTS, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Monthly Well alloc gas injection not equal to sum of daily', 'This typically occurs when the daily allocation is modified without re-running the monthly allocation', 'CONSISTENCY', 'WELLS', 'MONTHLY_ALLOCATIONS', 'WELL', 'INJ VOL', 'a.object_id', 'a.DAYTIME', 'NULL', 'from (select 
daytime,
object_id,
nvl(ALLOC_INJ_VOL,0) as monthly_vol,
NVL(LAST_UPDATED_DATE,CREATED_DATE) AS LAST_UPDATED_DATE
FROM DV_IWEL_MTH_ALLOC_GAS
where daytime >= :START_DATE and DAYTIME < :END_DATE
) a,
(
select 
object_id,
sum(nvl(ALLOC_INJ_VOL,0)) as daily_vol,
trunc(daytime,''MM'') as daytime,
MAX(LAST_UPDATED_DATE) AS LAST_UPDATED_DATE
from dv_iwel_day_alloc_gas
where daytime >= :START_DATE and DAYTIME < :END_DATE
group by object_id, trunc(daytime,''MM'')
 ) b
where a.object_id = b.object_id
and a.daytime = b.daytime
and b.daily_vol <> a.monthly_vol', 'The sum of the daily volumes = :b.daily_vol, last changed on :b.last_updated_date;  the monthly volume = :a.monthly_vol, last changed on :a.last_updated_date', 'MTH_GAS_WELL_STATUS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, COMMENTS, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO, SCREEN_COMPONENT_ID) VALUES ('N', 'Monthly Well alloc water injection not equal to sum of daily', 'This typically occurs when the daily allocation is modified without re-running the monthly allocation', 'CONSISTENCY', 'WELLS', 'MONTHLY_ALLOCATIONS', 'WELL', 'INJ VOL', 'a.object_id', 'a.DAYTIME', 'NULL', 'from (select 
daytime,
object_id,
nvl(ALLOC_INJ_VOL,0) as monthly_vol,
NVL(LAST_UPDATED_DATE,CREATED_DATE) AS LAST_UPDATED_DATE
FROM DV_IWEL_MTH_ALLOC_WATER
where daytime >= :START_DATE and DAYTIME < :END_DATE
) a,
(
select 
object_id,
sum(nvl(ALLOC_INJ_VOL,0)) as daily_vol,
trunc(daytime,''MM'') as daytime,
MAX(LAST_UPDATED_DATE) AS LAST_UPDATED_DATE
from dv_iwel_day_alloc_water
where daytime >= :START_DATE and DAYTIME < :END_DATE
group by object_id, trunc(daytime,''MM'')
 ) b
where a.object_id = b.object_id
and a.daytime = b.daytime
and b.daily_vol <> a.monthly_vol', 'The sum of the daily volumes = :b.daily_vol, last changed on :b.last_updated_date;  the monthly volume = :a.monthly_vol, last changed on :a.last_updated_date', 'MTH_WATER_WELL_STATUS');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO) VALUES ('N', 'Monthly alloc gas not equal to sum of daily', 'CONSISTENCY', 'WELLS', 'MONTHLY_ALLOCATIONS', 'WELL', 'ALLOC GAS', 'a.object_id', 'a.daytime', 'NULL', 'FROM (select 
daytime,
object_id,
nvl(ALLOC_GAS_VOL,0) as monthly_vol,
NVL(LAST_UPDATED_DATE,CREATED_DATE) AS LST_UPDATED_DATE
FROM DV_PWEL_MTH_ALLOC
) a,
(
select 
object_id,
sum(nvl(alloc_gas_vol,0)) as daily_vol,
trunc(daytime,''MM'') as daytime,
MAX(LAST_UPDATED_DATE) AS LAST_UPDATED_DATE
from Dv_pwel_day_alloc
group by object_id, trunc(daytime,''MM'')
 ) b
where a.object_id = b.object_id
and a.daytime = b.daytime
and b.daily_vol <> a.monthly_vol', 'The sum of the daily volumes = :b.daily_vol , the monthly volume = :a.monthly_vol');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO) VALUES ('N', 'Monthly alloc gas lift not equal to sum of daily', 'CONSISTENCY', 'WELLS', 'MONTHLY_ALLOCATIONS', 'WELL', 'ALLOC GAS LIFT', 'a.object_id', 'a.daytime', 'NULL', 'FROM (select 
daytime,
object_id,
nvl(ALLOC_GL_VOL,0) as monthly_vol,
NVL(LAST_UPDATED_DATE,CREATED_DATE) AS LST_UPDATED_DATE
FROM DV_PWEL_MTH_ALLOC
) a,
(
select 
object_id,
sum(nvl(alloc_GL_vol,0)) as daily_vol,
trunc(daytime,''MM'') as daytime,
MAX(LAST_UPDATED_DATE) AS LAST_UPDATED_DATE
from Dv_pwel_day_alloc
group by object_id, trunc(daytime,''MM'')
 ) b
where a.object_id = b.object_id
and a.daytime = b.daytime
and b.daily_vol <> a.monthly_vol', 'The sum of the daily volumes = :b.daily_vol , the monthly volume = :a.monthly_vol');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO) VALUES ('N', 'Monthly alloc oil not equal to sum of daily', 'CONSISTENCY', 'WELLS', 'MONTHLY_ALLOCATIONS', 'WELL', 'ALLOC OIL', 'a.object_id', 'a.daytime', 'NULL', 'FROM (select 
daytime,
object_id,
nvl(ALLOC_net_oil_VOL,0) as monthly_vol,
NVL(LAST_UPDATED_DATE,CREATED_DATE) AS LST_UPDATED_DATE
FROM DV_PWEL_MTH_ALLOC
where daytime >= :START_DATE and DAYTIME < :END_DATE
) a,
(
select 
object_id,
sum(nvl(alloc_net_oil_vol,0)) as daily_vol,
trunc(daytime,''MM'') as daytime,
MAX(LAST_UPDATED_DATE) AS LAST_UPDATED_DATE
from Dv_pwel_day_alloc
where daytime >= :START_DATE and DAYTIME < :END_DATE
group by object_id, trunc(daytime,''MM'')
 ) b
where a.object_id = b.object_id
and a.daytime = b.daytime
and b.daily_vol <> a.monthly_vol', 'The sum of the daily volumes = :b.daily_vol , the monthly volume = :a.monthly_vol');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, ADDNL_INFO) VALUES ('N', 'Monthly alloc water not equal to sum of daily', 'CONSISTENCY', 'WELLS', 'MONTHLY_ALLOCATIONS', 'WELL', 'ALLOC WATER', 'a.object_id', 'a.daytime', 'NULL', 'FROM (select 
daytime,
object_id,
nvl(ALLOC_WATER_VOL,0) as monthly_vol,
NVL(LAST_UPDATED_DATE,CREATED_DATE) AS LST_UPDATED_DATE
FROM DV_PWEL_MTH_ALLOC
) a,
(
select 
object_id,
sum(nvl(alloc_WATER_vol,0)) as daily_vol,
trunc(daytime,''MM'') as daytime,
MAX(LAST_UPDATED_DATE) AS LAST_UPDATED_DATE
from Dv_pwel_day_alloc
group by object_id, trunc(daytime,''MM'')
 ) b
where a.object_id = b.object_id
and a.daytime = b.daytime
and b.daily_vol <> a.monthly_vol', 'The sum of the daily volumes = :b.daily_vol , the monthly volume = :a.monthly_vol');
INSERT INTO TV_CT_DQ_RULE (IS_ACTIVE, RULE_DESCRIPTION, COMMENTS, ERROR_TYPE, RULE_CATEGORY, RULE_SUBCATEGORY, OBJECT_TYPE, ATTRIBUTE_NAME, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, FROM_SQL, SCREEN_COMPONENT_ID) VALUES ('N', 'Gas Totalizer closing reading is NULL', 'This assumes that every instantiated volume is expected to be completed', 'COMPLETENESS', 'STREAMS', 'DAILY_VOLUMES', 'STREAM', 'CLOSING_READING', 'object_id', 'daytime', 'null', 'from dv_strm_gas_totalizer
where closing_reading is NULL', 'GAS_STREAM_STATUS');
--
--Extracting UPDATE statements
--
--
set define on