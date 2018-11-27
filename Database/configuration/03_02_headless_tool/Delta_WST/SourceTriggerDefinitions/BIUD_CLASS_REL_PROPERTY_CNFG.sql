CREATE OR REPLACE EDITIONABLE TRIGGER "BIUD_CLASS_REL_PROPERTY_CNFG" 
BEFORE INSERT OR UPDATE OR DELETE ON class_rel_property_cnfg
FOR EACH ROW
DECLARE
BEGIN
  IF nvl(:new.property_type, :old.property_type) = 'VIEWLAYER' THEN
    ecdp_viewlayer_utils.set_dirty_ind(nvl(:new.to_class_name, :old.to_class_name), 'VIEWLAYER', TRUE);
    ecdp_viewlayer_utils.set_dirty_ind(nvl(:new.to_class_name, :old.to_class_name), 'REPORTLAYER', TRUE);

    IF nvl(:new.property_code, :old.property_code) = 'ACCESS_CONTROL_METHOD' THEN
        ecdp_viewlayer_utils.set_dirty_ind(nvl(:new.to_class_name, :old.to_class_name), 'DAC', TRUE);
    END IF;

    TCP_CLASS_REL_PROPERTY_CNFG.insert_data(nvl(:new.to_class_name, :old.to_class_name));
  END IF;

  IF nvl(:new.property_code, :old.property_code) IN ('NAME',
                                                     'IS_MANDATORY',
                                                     'DISABLED_IND',
                                                     'REPORT_ONLY_IND',
                                                     'ACCESS_CONTROL_METHOD',
                                                     'ALLOC_PRIORITY',
                                                     'DESCRIPTION',
                                                     'APPROVAL_IND',
                                                     'REVERSE_APPROVAL_IND') THEN

    ecdp_viewlayer_utils.set_dirty_ind('CLASS_RELATION', 'MATVIEW', TRUE);

  ELSIF nvl(:new.property_code, :old.property_code) = 'DB_SORT_ORDER' THEN

    ecdp_viewlayer_utils.set_dirty_ind('CLASS_REL_DB_MAPPING', 'MATVIEW', TRUE);

  ELSIF nvl(:new.property_code, :old.property_code) IN  ('PresentationSyntax', 'DB_PRES_SYNTAX', 'LABEL') THEN

    ecdp_viewlayer_utils.set_dirty_ind('CLASS_REL_PRESENTATION', 'MATVIEW', TRUE);

  ELSIF nvl(:new.property_type, :old.property_type) = 'STATIC_PRESENTATION' THEN

    ecdp_viewlayer_utils.set_dirty_ind('CLASS_REL_PRESENTATION', 'MATVIEW', TRUE);

  END IF;
END;
