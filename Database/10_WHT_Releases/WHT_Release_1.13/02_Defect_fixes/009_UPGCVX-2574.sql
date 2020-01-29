update CLASS_ATTR_PROPERTY_CNFG 
set property_value='false'
where class_name='TANK_DAY_INV_OIL' 
and attribute_name in ('DIP_UOM','DIP_LEVEL','CALC_DENSITY','BSW_VOL') and property_code='viewhidden';
commit;

update CLASS_ATTR_PROPERTY_CNFG 
set property_value=100
where class_name='TANK_DAY_INV_OIL' 
and attribute_name='TANK_METER_FREQ'and property_code='SCREEN_SORT_ORDER';
commit;

UPDATE viewlayer_dirty_log
SET DIRTY_IND    ='Y'
WHERE object_namE='TANK_DAY_INV_OIL';

commit;

EXECUTE EcDp_Viewlayer.BuildViewLayer('TANK_DAY_INV_OIL') ;
EXECUTE EcDp_Viewlayer.BUILDREPORTLAYER('TANK_DAY_INV_OIL') ;