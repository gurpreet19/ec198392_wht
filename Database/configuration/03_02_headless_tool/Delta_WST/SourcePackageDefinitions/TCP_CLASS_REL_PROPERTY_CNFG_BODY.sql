CREATE OR REPLACE PACKAGE BODY TCP_CLASS_REL_PROPERTY_CNFG IS

  TYPE Varchar2L IS TABLE OF Varchar2(200) index by pls_integer;  /*  table type */
  to_class_name_table Varchar2L ;   /* table to store to class name */
  pos pls_integer;  /* table index */

  PROCEDURE init_data IS
  BEGIN
    pos := 0;
  END;

  PROCEDURE insert_data(to_class_name IN Varchar2) IS
  BEGIN
    pos := pos + 1;
    to_class_name_table(pos) := to_class_name;
  END;

  PROCEDURE check_data IS
    unique_to_class_name_table Varchar2L;
    found_class BOOLEAN := false;
    check_pos pls_integer := 0;
  BEGIN
    WHILE pos > 0
    LOOP
      BEGIN
        FOR curDirtyDescendent IN ecdp_viewlayer_utils.getGrmodel(to_class_name_table(pos)) LOOP
          found_class := false;
          FOR indx IN NVL (unique_to_class_name_table.FIRST, 0) .. NVL (unique_to_class_name_table.LAST, -1)
          LOOP
            IF unique_to_class_name_table(indx) = curDirtyDescendent.class_name THEN
              found_class := true;
            END IF;
          END LOOP;

          IF NOT found_class THEN
            ecdp_viewlayer_utils.set_dirty_ind(curDirtyDescendent.class_name, 'VIEWLAYER', TRUE);
            ecdp_viewlayer_utils.set_dirty_ind(curDirtyDescendent.class_name, 'REPORTLAYER', TRUE);
          ELSE
            check_pos := check_pos + 1;
            unique_to_class_name_table(check_pos) := curDirtyDescendent.class_name;
          END IF;
        END LOOP;
      END;
      pos := pos - 1;
    END LOOP;
    to_class_name_table.DELETE;
  END;

END;