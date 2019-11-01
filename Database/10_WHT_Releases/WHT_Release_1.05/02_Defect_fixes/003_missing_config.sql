
insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('SCTR_DELIVERY_EVENT', 'END_DATE', 'DEFAULT_VALUE', 2500, '/', 'VIEWLAYER', 'TRUNC(n_daytime) + 1 - 1/24/60/60');

commit;
exec ecdp_viewlayer.buildviewlayer('SCTR_DELIVERY_EVENT', p_force => 'Y'); 
exec ecdp_viewlayer.buildreportlayer('SCTR_DELIVERY_EVENT', p_force => 'Y'); 
insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('PRODUCT_PRICE_LIST', 'PRICE_ELEMENT_CODE', 'DEFAULT_VALUE', 2500, '/', 'VIEWLAYER', '''PE_CPP_CUIB''');

commit;
exec ecdp_viewlayer.buildviewlayer('PRODUCT_PRICE_LIST', p_force => 'Y'); 
exec ecdp_viewlayer.buildreportlayer('PRODUCT_PRICE_LIST', p_force => 'Y'); 
--
insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('CNTR_DAY_LOC_INV_TRANS', 'CREDIT_QTY', 'DEFAULT_VALUE', 2500, '/', 'VIEWLAYER', '0');
insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('CNTR_DAY_LOC_INV_TRANS', 'DEBIT_QTY', 'DEFAULT_VALUE', 2500, '/', 'VIEWLAYER', '0');

commit;
exec ecdp_viewlayer.buildviewlayer('CNTR_DAY_LOC_INV_TRANS', p_force => 'Y'); 
exec ecdp_viewlayer.buildreportlayer('CNTR_DAY_LOC_INV_TRANS', p_force => 'Y'); 
insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('SCTR_MTH_DEL', 'DIRTY_IND', 'DEFAULT_VALUE', 2500, '/', 'VIEWLAYER', '''N''');

commit;
exec ecdp_viewlayer.buildviewlayer('SCTR_MTH_DEL', p_force => 'Y'); 
exec ecdp_viewlayer.buildreportlayer('SCTR_MTH_DEL', p_force => 'Y'); 

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('SCTR_DAY_DEL', 'DIRTY_IND', 'DEFAULT_VALUE', 2500, '/', 'VIEWLAYER', '''N''');

commit;
exec ecdp_viewlayer.buildviewlayer('SCTR_DAY_DEL', p_force => 'Y'); 
exec ecdp_viewlayer.buildreportlayer('SCTR_DAY_DEL', p_force => 'Y'); 
insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('CT_SCTR_MTH_FCST_ALLOC', 'DIRTY_IND', 'DEFAULT_VALUE', 2500, '/', 'VIEWLAYER', '''N''');

commit;
exec ecdp_viewlayer.buildviewlayer('CT_SCTR_MTH_FCST_ALLOC', p_force => 'Y'); 
exec ecdp_viewlayer.buildreportlayer('CT_SCTR_MTH_FCST_ALLOC', p_force => 'Y'); 
insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('SCTR_MTH_FORECAST', 'DIRTY_IND', 'DEFAULT_VALUE', 2500, '/', 'VIEWLAYER', '''N''');

commit;
exec ecdp_viewlayer.buildviewlayer('SCTR_MTH_FORECAST', p_force => 'Y'); 
exec ecdp_viewlayer.buildreportlayer('SCTR_MTH_FORECAST', p_force => 'Y'); 
insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('CT_SCTR_DAY_DEL_ALLOC', 'DIRTY_IND', 'DEFAULT_VALUE', 2500, '/', 'VIEWLAYER', '''N''');

commit;
exec ecdp_viewlayer.buildviewlayer('CT_SCTR_DAY_DEL_ALLOC', p_force => 'Y'); 
exec ecdp_viewlayer.buildreportlayer('CT_SCTR_DAY_DEL_ALLOC', p_force => 'Y'); 
insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('CNTR_DAY_LOC_INVENTORY', 'DIRTY_IND', 'DEFAULT_VALUE', 2500, '/', 'VIEWLAYER', '''N''');

commit;
exec ecdp_viewlayer.buildviewlayer('CNTR_DAY_LOC_INVENTORY', p_force => 'Y'); 
exec ecdp_viewlayer.buildreportlayer('CNTR_DAY_LOC_INVENTORY', p_force => 'Y'); 
insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('CT_SCTR_MTH_DEL_ALLOC', 'DIRTY_IND', 'DEFAULT_VALUE', 2500, '/', 'VIEWLAYER', '''N''');

commit;
exec ecdp_viewlayer.buildviewlayer('CT_SCTR_MTH_DEL_ALLOC', p_force => 'Y'); 
exec ecdp_viewlayer.buildreportlayer('CT_SCTR_MTH_DEL_ALLOC', p_force => 'Y'); 