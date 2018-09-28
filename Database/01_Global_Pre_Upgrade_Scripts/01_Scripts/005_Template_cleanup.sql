-- Removing all CT classes
DECLARE
v_object_name varchar2(3000);
lv2_errorMsg VARCHAR2(32767);
Cursor classname is (select Class_name from class where class_name in ('CT_SYSTEM_DAYS','CT_SYSTEM_MONTH','CT_EQPM_OFF_CHILD','CT_EQPM_OFF_CHILD_DAY','CT_EQPM_OFF_EVENT','CT_EQPM_OFF_EVENT_DAY','CT_IWEL_DAY_ALLOC','CT_IWEL_DAY_ALLOC_RBF','CT_IWEL_DAY_STATUS','CT_IWEL_DAY_STATUS_RBF','CT_IWEL_EVENT','CT_IWEL_EVENT_DETAIL','CT_IWEL_MTH_ALLOC','CT_IWEL_MTH_ALLOC_RBF','CT_LPO_OFF_CHILD','CT_LPO_OFF_CHILD_DAY','CT_LPO_OFF_EVENT','CT_LPO_OFF_EVENT_DAY','CT_LPO_OFF_WELL_DAY','CT_PTST_PWEL_RESULT','CT_PTST_PWEL_RESULT_RBF','CT_PTST_PWEL_TDEV_RBF','CT_PTST_PWEL_TDEV_RES_KS','CT_PTST_PWEL_TDEV_RESULT','CT_PWEL_DAY_ALLOC','CT_PWEL_DAY_ALLOC_RBF','CT_PWEL_DAY_STATUS_ALL','CT_PWEL_DAY_STATUS_RBF','CT_PWEL_EVENT','CT_PWEL_MTH_ALLOC','CT_PWEL_MTH_ALLOC_RBF','CT_STRM_DAY_ALLOC','CT_STRM_DAY_STREAM','CT_STRM_EVENT','CT_STRM_MTH_ALLOC','CT_TANK_DAY_ALL','CT_PRODUCTIONUNIT','CT_PROD_SUB_UNIT','CT_AREA','CT_COUNTRY','CT_FCTY_CLASS_1','CT_FCTY_CLASS_2','CT_FIELD','CT_LICENCE','CT_REGION','CT_RESV_BLOCK','CT_RESV_BLOCK_FORMATION','CT_RESV_FORMATION','CT_STREAM','CT_SUB_AREA','CT_TANK','CT_TANK_CURRENT','CT_WELL_CURRENT','CT_WELL','CT_WELL_BORE','CT_WELL_BORE_INTERVAL','CT_WELL_HOLE','CT_STEAM_GENERATOR','CT_CHILLER','CT_CO_GEN_UNIT','CT_CO2_REMOVAL_UNIT','CT_CONDENSATE_SURGE_DRUM','CT_CTRL_SAFETY_SYSTEM','CT_DEHYDRATOR','CT_EMULSIFIER','CT_FUEL_SYSTEMS','CT_GAS_PROC_EQPM','CT_GENERATOR','CT_INCINERATORS','CT_MERCURY_REMOVAL_UNIT','CT_EQUIPMENT_OTHER','CT_POWER_DIST_EQPM','CT_PROCESSING_UNIT','CT_PUMP','CT_REBOILER','CT_REVERSE_OSMOSIS_UNIT','CT_SO2_SCRUBBER','CT_SPLITIGATOR','CT_STABILIZER','CT_UTILITY_EQPM','CT_VAPOUR_RECOVERY_UNIT','CT_WATER_TREATMENT_UNIT','CT_COMPRESSOR','CT_MOTOR','CT_OIL_PLANT','CT_PROCESS_VESSEL','CT_SMALL_ENGINE','CT_EQPM_GAS_ELIMINATOR','CT_EQPM_HEADER','CT_EQPM_PROCESS_VESSEL','CT_EQPM_OIL_PLANT','CT_EQPM_BLOWER','CT_EQPM_HEAT_EXCHANGER','CT_EQPM_CASING_COLL_SYS','CT_EQPM_MOTOR','CT_EQPM_HEATER_TREATER','CT_EQPM_FLARE_SYSTEM','CT_EQPM_SMALL_ENGINE','CT_EQPM_FWKO','CT_EQPM_H2S_FACILITY','CT_EC_INSTALLED_FEATURES','CT_EC_INSTALL_HISTORY','CT_CURRENT_SPLITS','CT_FCST_SP_DAY_AFS_PROD','CT_NAV_DEF_VALUE'));

Cursor objectname(p_classname varchar2) is select object_name from user_objects where (object_name like '%'||p_classname or object_name like '%'||p_classname||'_JN') and object_type = 'VIEW';

Begin
for i in classname loop
  Begin
  /*Delete class entries*/
    Delete object_attr_editable where class_name =i.class_name;
    Delete object_attr_validation where class_name =i.class_name;
    Delete class_trigger_action where class_name =i.class_name;
    Delete class_rel_presentation where to_class_name =i.class_name;
    Delete class_rel_db_mapping where to_class_name =i.class_name;
    Delete class_relation where to_class_name =i.class_name;
    Delete class_attr_presentation where class_name =i.class_name;
    Delete class_attr_db_mapping where class_name =i.class_name;
    Delete class_attribute where class_name =i.class_name;
    Delete class_dependency where child_class =i.class_name;
    Delete class_db_mapping where class_name =i.class_name;
    Delete class where class_name =i.class_name;
    
    for j in objectname(i.class_name) loop
    /*drop Views and JN views*/
      execute immediate 'Drop view '||j.object_name;
     
    end loop;
  Exception when others then
    /*Log entry in t_temptext;*/
    IF (length(i.class_name) + length(sqlerrm) + 100) < 32767 THEN
           lv2_errorMsg := ' [' || i.class_name || ']. Error msg: [' || sqlerrm || ']';
	ELSE
		   lv2_errorMsg := i.class_name; 
    END IF;    
	ecdp_dynsql.WriteTempText('DROP_CT_CLASS','Error for Class: ' || chr(10) || lv2_errorMsg);
  End;
End Loop;
End;
/

-- Removing custom admin role and access
DELETE FROM TV_T_BASIS_ACCESS WHERE ROLE_ID='CVX.ADM';
DELETE FROM TV_T_BASIS_USERROLE WHERE ROLE_ID='CVX.ADM';
DELETE FROM TV_T_BASIS_ROLE WHERE ROLE_ID='CVX.ADM';