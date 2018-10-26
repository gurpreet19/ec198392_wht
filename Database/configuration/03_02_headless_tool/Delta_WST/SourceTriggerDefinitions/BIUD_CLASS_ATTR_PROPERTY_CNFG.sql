CREATE OR REPLACE EDITIONABLE TRIGGER "BIUD_CLASS_ATTR_PROPERTY_CNFG" 
BEFORE INSERT OR UPDATE OR DELETE ON class_attr_property_cnfg
FOR EACH ROW
DECLARE
BEGIN
  IF nvl(:new.property_type, :old.property_type) = 'VIEWLAYER' THEN

    ecdp_viewlayer_utils.set_dirty_ind(nvl(:new.class_name, :old.class_name), 'VIEWLAYER', TRUE);
    ecdp_viewlayer_utils.set_dirty_ind(nvl(:new.class_name, :old.class_name), 'REPORTLAYER', TRUE);

  END IF;

  IF nvl(:new.property_code, :old.property_code) = 'DB_SORT_ORDER' THEN

    ecdp_viewlayer_utils.set_dirty_ind('CLASS_ATTR_DB_MAPPING', 'MATVIEW', TRUE);

  ELSIF nvl(:new.property_code, :old.property_code) IN ('IS_MANDATORY', 'DISABLED_IND', 'REPORT_ONLY_IND', 'DESCRIPTION', 'NAME', 'READ_ONLY_IND') THEN

    ecdp_viewlayer_utils.set_dirty_ind('CLASS_ATTRIBUTE', 'MATVIEW', TRUE);

  ELSIF nvl(:new.property_code, :old.property_code) IN ('PresentationSyntax', 'SCREEN_SORT_ORDER', 'DB_PRES_SYNTAX', 'LABEL_ID', 'LABEL', 'UOM_CODE') THEN

    ecdp_viewlayer_utils.set_dirty_ind('CLASS_ATTR_PRESENTATION', 'MATVIEW', TRUE);

  ELSIF nvl(:new.property_type, :old.property_type) = 'STATIC_PRESENTATION' THEN

    ecdp_viewlayer_utils.set_dirty_ind('CLASS_ATTR_PRESENTATION', 'MATVIEW', TRUE);

  END IF;
END;
