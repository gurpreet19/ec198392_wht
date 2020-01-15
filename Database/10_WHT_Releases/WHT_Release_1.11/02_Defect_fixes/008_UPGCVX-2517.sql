insert into class_attr_property_Cnfg (Class_name, Attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
                                values ('T_BASIS_USER', 'ACTIVE', 'SCREEN_SORT_ORDER', '2500','/EC', 'APPLICATION', '510' );


insert into class_attr_property_Cnfg (Class_name, Attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
                                values ('T_BASIS_USER', 'APP_ID', 'SCREEN_SORT_ORDER', '2500','/EC', 'APPLICATION', '610');
commit;

UPDATE viewlayer_dirty_log SET DIRTY_IND='Y' WHERE object_name in ('T_BASIS_USER');
commit;
EXECUTE EcDp_Viewlayer.BuildViewLayer('T_BASIS_USER',p_force => 'Y') ;
EXECUTE EcDp_Viewlayer.BuildReportLayer('T_BASIS_USER',p_force => 'Y');
commit;
