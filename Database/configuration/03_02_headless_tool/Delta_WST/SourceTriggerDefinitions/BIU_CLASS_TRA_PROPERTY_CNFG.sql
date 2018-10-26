CREATE OR REPLACE EDITIONABLE TRIGGER "BIU_CLASS_TRA_PROPERTY_CNFG" 
BEFORE INSERT OR UPDATE ON class_tra_property_cnfg
FOR EACH ROW
BEGIN
    EcDp_ClassMeta_Cnfg.AssertValidProperty('CLASS_TRA_PROPERTY_CNFG', :new.property_type, :new.property_code, :new.property_value);
END;
