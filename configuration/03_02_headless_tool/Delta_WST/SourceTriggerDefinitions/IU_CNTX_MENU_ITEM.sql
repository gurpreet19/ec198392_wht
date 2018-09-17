CREATE OR REPLACE EDITIONABLE TRIGGER "IU_CNTX_MENU_ITEM" 
BEFORE INSERT OR UPDATE ON CNTX_MENU_ITEM
FOR EACH ROW

DECLARE
  cursor c_bf_component_action is
  select bf_component_action_no
  from bf_component_action bca, bf_component bfc
  where bfc.bf_component_no = bca.bf_component_no
  and   bfc.bf_code = :NEW.bf_code
  and   bfc.comp_code = :NEW.comp_code
  and   bca.name = :NEW.item_code;

  ln_bf_component_action_no  NUMBER;


BEGIN
    -- Common
    -- $Revision: 1.2 $
    -- Handle old code not aware of new key structure
    -- must then set use BF_CODE, COMP_CODE and ITEM_CODE and possibly
    -- make entry in BF_COMPONENT_ACTION


    IF Inserting THEN

      IF :NEW.BF_COMPONENT_ACTION_NO IS NULL THEN

        :NEW.BF_COMPONENT_ACTION_NO := EcDp_Business_function.createBFComponentAction(:NEW.BF_CODE,:NEW.COMP_CODE,:NEW.ITEM_CODE);

      END IF;

      :new.record_status := 'P';
      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;
      IF :new.created_date IS NULL THEN
         :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;


    ELSIF UPDATING THEN

      IF Nvl(:NEW.BF_COMPONENT_ACTION_NO,0) <> Nvl(:OLD.BF_COMPONENT_ACTION_NO,0) THEN

        -- NEED to find and update BF_CODE, COMP_CODE
        :NEW.BF_CODE := EcDp_Business_function.getBFCodefromBFCA(:NEW.BF_COMPONENT_ACTION_NO);
        :NEW.COMP_CODE := EcDp_Business_function.getCompCodefromBFCA(:NEW.BF_COMPONENT_ACTION_NO);

      ELSIF Nvl(:NEW.BF_CODE,'NULL') <> Nvl(:OLD.BF_CODE,'NULL')
        OR Nvl(:NEW.COMP_CODE,'NULL') <> Nvl(:OLD.COMP_CODE,'NULL') THEN

          -- Align BF_COMPONENT_ACTION_NO in case this is an update not aware of new key structure
          :NEW.BF_COMPONENT_ACTION_NO := EcDp_Business_function.createBFComponentAction(:NEW.BF_CODE,:NEW.COMP_CODE,:NEW.ITEM_CODE);


      END IF;



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
