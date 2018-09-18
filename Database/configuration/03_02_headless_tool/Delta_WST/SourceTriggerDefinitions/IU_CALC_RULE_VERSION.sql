CREATE OR REPLACE EDITIONABLE TRIGGER "IU_CALC_RULE_VERSION" 
BEFORE INSERT OR UPDATE ON CALC_RULE_VERSION
FOR EACH ROW
DECLARE
 lc_blob BLOB;

BEGIN
    -- $Revision: 1.4 $
    -- Common

          -- initialise first one first time use
      IF EcBp_calc_rule.ptab IS NULL THEN

         EcBp_calc_rule.ptab := EcBp_calc_rule.calc_rule_key_table();

      END IF;
      IF Inserting OR Updating THEN
        -- mark record so that end_date can be set on previous
        EcBp_calc_rule.ptab.EXTEND;
        EcBp_calc_rule.ptab(EcBp_calc_rule.ptab.LAST).calc_id := :New.object_id;
        EcBp_calc_rule.ptab(EcBp_calc_rule.ptab.LAST).daytime := :New.daytime;
        EcBp_calc_rule.ptab(EcBp_calc_rule.ptab.LAST).end_date := :New.end_date;
        EcBp_calc_rule.ptab(EcBp_calc_rule.ptab.LAST).calc_context_id := :New.calc_context_id;
     END IF;


    IF Inserting THEN
      :NEW.record_status := NVL(:NEW.record_status,'P');
      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;

      IF :new.created_date IS NULL THEN
         :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      END IF;

      :new.calc_rule_definition:='<?xml version="1.0" encoding="UTF-8"?><node-type><calc-context>'||ecdp_objects.getObjCode(:new.calc_context_id)||'</calc-context><code>'||:new.object_code||'</code><name>'||:new.name||'</name></node-type>';
      dbms_lob.createtemporary(lc_blob,true,dbms_lob.session);
      :new.calc_rule_document :=  lc_blob;

      :new.rev_no := 0;
    ELSE

     dbms_lob.createtemporary(lc_blob,true,dbms_lob.session);
     :new.calc_rule_document :=  lc_blob;

      IF Nvl(:new.record_status,'P') = Nvl(:old.record_status,'P') THEN
         IF NOT UPDATING('LAST_UPDATED_BY') THEN
            :new.last_updated_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
         END IF;
         IF NOT UPDATING('LAST_UPDATED_DATE') THEN
           :new.last_updated_date := Ecdp_Timestamp.getCurrentSysdate;
         END IF;
      END IF;

    END IF;
END;
