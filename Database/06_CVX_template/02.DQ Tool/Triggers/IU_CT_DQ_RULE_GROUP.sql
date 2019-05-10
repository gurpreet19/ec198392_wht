create or replace trigger IU_CT_DQ_RULE_GROUP
  before insert or update on CT_DQ_RULE_GROUP  
  for each row
declare

begin


    IF Inserting THEN 

      IF :new.created_by IS NULL THEN
         :new.created_by := User;
      END IF;

      IF :new.created_date IS NULL THEN
         :new.created_date := EcDp_Date_Time.getCurrentSysdate;
      END IF;

    ELSE 

         IF NOT UPDATING('LAST_UPDATED_BY') THEN
            :new.last_updated_by := User;
         END IF;

         IF NOT UPDATING('LAST_UPDATED_DATE') THEN
           :new.last_updated_date := EcDp_Date_Time.getCurrentSysdate;
         END IF;

    END IF;


    IF Inserting THEN 

  	IF :new.rule_group_id is null then

		EcDp_System_Key.assignNextNumber('CT_DQ_RULE_GROUP', :NEW.rule_group_id);    

  	END IF;

    END IF;



  
end IU_CT_DQ_RULE_GROUP;
/
