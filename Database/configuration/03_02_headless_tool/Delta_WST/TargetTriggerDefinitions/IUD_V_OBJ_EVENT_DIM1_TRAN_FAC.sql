CREATE OR REPLACE TRIGGER "IUD_V_OBJ_EVENT_DIM1_TRAN_FAC" 
  INSTEAD OF INSERT OR UPDATE OR DELETE ON v_obj_event_dim1_cp_tran_fac
  FOR EACH ROW

-- $Revision: 1.2.2.1 $
-- $Author: Lee Wei Yap

DECLARE

  CURSOR c_component IS
    SELECT o.daytime,
           o.object_id,
           o.dim1_key,
           o.component_no,
           o.class_name,
           o.frac
      FROM obj_event_dim1_cp_tran_fac o
     WHERE o.daytime =
           (SELECT max(o.daytime) FROM obj_event_dim1_cp_tran_fac o where o.daytime < :NEW.daytime and o.class_name = :NEW.class_name)
       AND o.class_name = :NEW.class_name;

BEGIN

  IF INSERTING THEN
     IF (Nvl(:OLD.daytime, to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS')) <> :NEW.daytime) THEN
      FOR cur_component IN c_component LOOP
        INSERT INTO obj_event_dim1_cp_tran_fac o
          (object_id, daytime, class_name, dim1_key, component_no, frac)
        VALUES
          (cur_component.object_id,
           :NEW.daytime,
           cur_component.class_name,
           cur_component.dim1_key,
           cur_component.component_no,
           cur_component.frac);
      END LOOP;
    END IF;
  END IF;

  IF UPDATING THEN

    UPDATE obj_event_dim1_cp_tran_fac
       SET frac              = :NEW.frac,
           last_updated_by   = :NEW.last_updated_by,
           last_updated_date = :NEW.last_updated_date,
           record_status     = :NEW.record_status,
           rev_no            = :NEW.rev_no,
           rev_text          = :NEW.rev_text
     WHERE daytime = :NEW.daytime
       AND object_id = :NEW.object_id
       AND class_name = :NEW.class_name
       AND dim1_key = :NEW.dim1_key
       AND component_no = :NEW.component_no;
  END IF;

  IF DELETING THEN
   DELETE FROM obj_event_dim1_cp_tran_fac
    WHERE daytime = :OLD.daytime
      AND class_name = :OLD.class_name;
  END IF;
END;

