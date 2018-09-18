CREATE OR REPLACE EDITIONABLE TRIGGER "BIUD_CLASS_PROPERTY_CNFG" 
BEFORE INSERT OR UPDATE OR DELETE ON class_property_cnfg
FOR EACH ROW
DECLARE
BEGIN
  IF nvl(:new.property_type, :old.property_type) = 'VIEWLAYER' THEN
    ecdp_viewlayer_utils.set_dirty_ind(nvl(:new.class_name, :old.class_name), 'VIEWLAYER', TRUE);
    ecdp_viewlayer_utils.set_dirty_ind(nvl(:new.class_name, :old.class_name), 'REPORTLAYER', TRUE);

    FOR curDirtyDependent IN ecdp_viewlayer_utils.c_interface_class(nvl(:new.class_name, :old.class_name)) LOOP
      ecdp_viewlayer_utils.set_dirty_ind(curDirtyDependent.interface_class, 'VIEWLAYER', TRUE);
      ecdp_viewlayer_utils.set_dirty_ind(curDirtyDependent.interface_class, 'REPORTLAYER', TRUE);
    END LOOP;

    IF nvl(:new.property_code, :old.property_code) = 'ACCESS_CONTROL_IND' THEN
      ecdp_viewlayer_utils.set_dirty_ind(nvl(:new.class_name, :old.class_name), 'DAC', TRUE);
      FOR curDirtyDependent IN ecdp_viewlayer_utils.c_dac_dependent_class(nvl(:new.class_name, :old.class_name)) LOOP
        ecdp_viewlayer_utils.set_dirty_ind(curDirtyDependent.dependent_class, 'VIEWLAYER', TRUE);
        ecdp_viewlayer_utils.set_dirty_ind(curDirtyDependent.dependent_class, 'REPORTLAYER', TRUE);
        ecdp_viewlayer_utils.set_dirty_ind(curDirtyDependent.dependent_class, 'DAC', TRUE);
      END LOOP;
    END IF;
  END IF;

  IF nvl(:new.property_code, :old.property_code) IN ('CLASS_SHORT_CODE',
                                                     'LABEL',
                                                     'ENSURE_REV_TEXT_ON_UPD',
                                                     'READ_ONLY_IND',
                                                     'INCLUDE_IN_VALIDATION',
                                                     'JOURNAL_RULE_DB_SYNTAX',
                                                     'LOCK_RULE',
                                                     'LOCK_IND',
                                                     'ACCESS_CONTROL_IND',
                                                     'APPROVAL_IND',
                                                     'SKIP_TRG_CHECK_IND',
                                                     'INCLUDE_WEBSERVICE',
                                                     'CREATE_EV_IND',
                                                     'DESCRIPTION',
                                                     'CALC_ENGINE_TABLE_WRITE_IND',
                                                     'INCLUDE_IN_MAPPING_IND') THEN

    ecdp_viewlayer_utils.set_dirty_ind('CLASS', 'MATVIEW', TRUE);

  END IF;
END;
