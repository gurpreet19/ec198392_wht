CREATE OR REPLACE EDITIONABLE TRIGGER "IUD_V_FCST_RECOVERY_FACTOR" 
  INSTEAD OF INSERT OR UPDATE OR DELETE ON V_FCST_RECOVERY_FACTOR
  FOR EACH ROW

-- $Revision: 1.1 $
-- Common

DECLARE

  CURSOR c_fcst_component IS
    SELECT o.daytime,
           o.object_id,
           o.forecast_id,
           o.component_no,
           o.class_name,
           o.frac
      FROM fcst_recovery_factor o
     WHERE o.daytime = (SELECT max(o.daytime)
                          FROM fcst_recovery_factor o
                         where o.daytime <= :NEW.daytime
						   and o.forecast_id = :NEW.forecast_id
                           and o.class_name = :NEW.class_name)
       AND o.class_name = :NEW.class_name
	   AND o.forecast_id = :NEW.forecast_id;

--Copy previous version from actual table when forecast is FORECAST_TRAN_FC
  CURSOR c_component IS
    SELECT o.daytime,
           o.object_id,
           o.component_no,
           o.class_name,
           o.frac
      FROM obj_event_cp_tran_factor o
     WHERE o.daytime =
           (SELECT max(o.daytime)
              FROM obj_event_cp_tran_factor o
             WHERE o.daytime <= :NEW.daytime
               AND o.class_name = 'TRNP_EVENT_CP_TRAN_FAC')
       AND o.class_name = 'TRNP_EVENT_CP_TRAN_FAC';

lb_insert_fcst BOOLEAN := FALSE; --determine if record have been inserted into forecast table

BEGIN

  IF INSERTING THEN
    IF (Nvl(:OLD.daytime,
            to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS')) <>:NEW.daytime) THEN
      FOR cur_fcst_component IN c_fcst_component LOOP
		lb_insert_fcst := TRUE;
        INSERT INTO fcst_recovery_factor o
          (object_id, daytime, forecast_id, class_name, component_no, frac)
        VALUES
          (cur_fcst_component.object_id,
           :NEW.daytime,
           cur_fcst_component.forecast_id,
           cur_fcst_component.class_name,
           cur_fcst_component.component_no,
           cur_fcst_component.frac);
      END LOOP;

      IF NOT lb_insert_fcst THEN
        FOR cur_component IN c_component LOOP
          INSERT INTO fcst_recovery_factor o
            (object_id,
             daytime,
             forecast_id,
             class_name,
             component_no,
             frac)
          VALUES
            (cur_component.object_id,
             :NEW.daytime,
             :NEW.forecast_id,
             :NEW.class_name,
             cur_component.component_no,
             cur_component.frac);
        END LOOP;
      END IF;
    END IF;
  END IF;

  IF UPDATING THEN
    UPDATE fcst_recovery_factor
       SET object_id         = :NEW.object_id,
           daytime           = :NEW.daytime,
           forecast_id       = :NEW.forecast_id,
           class_name        = :NEW.class_name,
           frac              = :NEW.frac,
           created_by        = :NEW.created_by,
           created_date      = :NEW.created_date,
           last_updated_by   = :NEW.last_updated_by,
           last_updated_date = :NEW.last_updated_date,
           rev_no            = :NEW.rev_no,
           rev_text          = :NEW.rev_text,
           record_status     = :NEW.record_status
     WHERE OBJECT_ID = :NEW.object_id
       AND daytime = :NEW.daytime
       AND forecast_id = :NEW.forecast_id
       AND component_no = :NEW.component_no
       AND class_name = :NEW.class_name;
  END IF;

  IF DELETING THEN
    DELETE FROM fcst_recovery_factor
     WHERE daytime = :OLD.daytime
       AND class_name = :OLD.class_name
       AND forecast_id = :OLD.forecast_id;
  END IF;
END;
