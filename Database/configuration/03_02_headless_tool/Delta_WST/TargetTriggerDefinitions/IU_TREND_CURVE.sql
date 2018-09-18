CREATE OR REPLACE TRIGGER "IU_TREND_CURVE" 
BEFORE INSERT OR UPDATE ON TREND_CURVE
FOR EACH ROW
BEGIN
    -- $Revision: 1.2 $
    -- Common
	IF Inserting THEN
		:NEW.record_status := NVL(:NEW.record_status,'P');
		IF :new.created_by IS NULL THEN
		 :new.created_by := User;
		END IF;

		IF :new.trend_segment_no IS NULL THEN
			EcDp_System_Key.assignNextNumber('TREND_CURVE', :new.trend_segment_no);
		END IF;

		IF :new.created_date IS NULL THEN
		 :new.created_date := EcDp_Date_Time.getCurrentSysdate;
		END IF;
		:new.rev_no := 0;
	ELSE
	  IF Nvl(:new.record_status,'P') = Nvl(:old.record_status,'P') THEN
	     IF NOT UPDATING('LAST_UPDATED_BY') THEN
	        :new.last_updated_by := User;
	     END IF;
	     IF NOT UPDATING('LAST_UPDATED_DATE') THEN
	       :new.last_updated_date := EcDp_Date_Time.getCurrentSysdate;
	     END IF;
	  END IF;
	END IF;
END;

