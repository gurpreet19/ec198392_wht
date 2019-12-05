delete from class_rel_property_cnfg where to_class_name='STORAGE_LIFT_NOM_BLMR' and from_class_name='LIFTING_ACCOUNT' and PROPERTY_CODE='viewhidden';
Update viewlayer_dirty_log set dirty_ind = 'Y' where object_name IN( 'LIFTING_ACCOUNT');
commit;

execute ecdp_viewlayer.buildviewlayer('LIFTING_ACCOUNT', p_force => 'Y'); 
execute ecdp_viewlayer.buildreportlayer('LIFTING_ACCOUNT', p_force => 'Y'); 

commit;