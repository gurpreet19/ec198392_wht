CREATE OR REPLACE PACKAGE BODY EcDp_System_key IS
/****************************************************************
** Package        :  EcDp_System_key, body part
**
** $Revision: 1.5.32.1 $
**
** Purpose        :  Provide system key numbers
**
** Documentation  :  www.energy-components.com
**
** Created  : 27.04.2000  Dagfinn Njå
**
** Modification history:
**
** Date       Whom  Change description:
** --------   ----- --------------------------------------
** 20040219   DN    Added assignNextNumber. Moved from EcDp_System.
*****************************************************************/

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : assignNextNumber
-- Description    : Increments the numerical sequence for a given table and returns the new value.
--
-- Preconditions  : Cannot be used in a distributed database environment.
--
-- Postconditions : Autonomous transaction where only this inserted record is committed. The surrounding
--                  trnasaction will not commit.
--
-- Using tables   : ASSIGN_ID
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Creates a new assign-entry for the requested table if it is not there.
--
-------------------------------------------------------------------------------------------------
FUNCTION assignNextNumber(p_table_name VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS
PRAGMA AUTONOMOUS_TRANSACTION;

CURSOR c_assign(cp_table_name VARCHAR2) IS
SELECT *
FROM assign_id
WHERE tablename = cp_table_name
FOR UPDATE;

ln_next_val NUMBER;

BEGIN

   FOR cur_rec IN c_assign(p_table_name) LOOP

      ln_next_val := Nvl(cur_rec.max_id, 0) + 1;

      UPDATE assign_id
      SET max_id = ln_next_val
      WHERE CURRENT OF c_assign;

   END LOOP;

   IF ln_next_val IS NULL THEN

      ln_next_val := 1;

      INSERT INTO assign_id (tablename, max_id)
      VALUES (p_table_name, ln_next_val);

   END IF;

   COMMIT;

   RETURN ln_next_val;

END assignNextNumber;


-------------------------------------------------------------------------------------------------
-- Procedure      : assignNextNumberNonAutonomous
-- Description    : Increments the numerical sequence for a given table and returns the new value.
--
-- Preconditions  : Cannot be used in a distributed database environment.
--
-- Postconditions : This is th non-autonomous version
--
-- Using tables   : ASSIGN_ID
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Creates a new assign-entry for the requested table if it is not there.
--
-------------------------------------------------------------------------------------------------
FUNCTION assignNextNumberNonAutonomous(p_table_name VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_assign(cp_table_name VARCHAR2) IS
SELECT *
FROM assign_id
WHERE tablename = cp_table_name
FOR UPDATE;

ln_next_val NUMBER;

BEGIN

   FOR cur_rec IN c_assign(p_table_name) LOOP

      ln_next_val := Nvl(cur_rec.max_id, 0) + 1;

      UPDATE assign_id
      SET max_id = ln_next_val
      WHERE CURRENT OF c_assign;

   END LOOP;

   IF ln_next_val IS NULL THEN

      ln_next_val := 1;

      INSERT INTO assign_id (tablename, max_id)
      VALUES (p_table_name, ln_next_val);

   END IF;


   RETURN ln_next_val;

END assignNextNumberNonAutonomous;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : assignNextNumber
-- Description    : Increments the numerical sequence for a given table and makes the new last value
--                  available in the return parameter.
--
-- Preconditions  : Cannot be used in a distributed database environment.
--
-- Postconditions : Autonomous transaction where only this inserted record is committed. The surrounding
--                  trnasaction will not commit.
--
-- Using tables   : ASSIGN_ID
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Creates a new assign-entry for the requested table if it is not there.
--
-------------------------------------------------------------------------------------------------
PROCEDURE assignNextNumber(p_table_name VARCHAR2, po_next_number OUT NUMBER, p_auto_commit BOOLEAN DEFAULT TRUE)
--</EC-DOC>
IS
BEGIN
   IF p_auto_commit THEN
      po_next_number := assignNextNumber(p_table_name);
   ELSE
      po_next_number := assignNextNumberNonAutonomous(p_table_name);
   END IF;
END assignNextNumber;

------------------------------------------------------------------
-- Function   : assignNextKeyValue
-- Description: Returns next key value available and increments sequence in database.
--
------------------------------------------------------------------

FUNCTION assignNextKeyValue(p_table_name VARCHAR2) RETURN NUMBER IS

CURSOR c_nextvalue IS
SELECT object_id_sequence.nextval FROM dual;

ln_nextkeyvalue NUMBER;

BEGIN

   OPEN c_nextvalue;
   FETCH c_nextvalue INTO ln_nextkeyvalue;
   CLOSE c_nextvalue;

   RETURN ln_nextkeyvalue;

END assignNextKeyValue;

------------------------------------------------------------------
-- Function   : showLatestKeyValue
-- Description: Returns the latest key value used
--
------------------------------------------------------------------
FUNCTION showLatestKeyValue RETURN NUMBER IS

CURSOR c_latestvalue IS
SELECT object_id_sequence.currval FROM dual;

ln_latestkeyvalue NUMBER;

BEGIN

   OPEN c_latestvalue;
   FETCH c_latestvalue INTO ln_latestkeyvalue;
   CLOSE c_latestvalue;

   RETURN ln_latestkeyvalue;

END showLatestKeyValue;

------------------------------------------------------------------
-- Function   : showNextKeyValue
-- Description: Returns the next key value available.
--
------------------------------------------------------------------
FUNCTION showNextKeyValue RETURN NUMBER IS


BEGIN

   RETURN showLatestKeyValue + 1;

END showNextKeyValue;

--

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : resetNextNumber
-- Description    : Increments the numerical sequence for a given table with the latest available
--                   number in the actual table.
--
-- Preconditions  : Cannot be used in a distributed database environment.
--                  May only be used by upgrade package or service pack.
--
-- Postconditions : Autonomous transaction where only this inserted record is committed. The surrounding
--                  trnasaction will not commit.
--
-- Using tables   : ASSIGN_ID
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Reset the sequence to predefined (max value used in the table)
--
-------------------------------------------------------------------------------------------------
PROCEDURE resetNextNumber(p_table_name VARCHAR2, p_next_number NUMBER)
--</EC-DOC>
IS
PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
  INSERT INTO assign_id (tablename, max_id)
    VALUES (p_table_name, p_next_number);
  COMMIT;
EXCEPTION WHEN dup_val_on_index THEN
  UPDATE assign_id
    SET max_id = p_next_number
    WHERE tablename=p_table_name;
  COMMIT;

END resetNextNumber;

-------------------------------------------------------------------------------------------------
-- Function      : AssignNextUniqueNumber
-- Description    : Increments the numerical sequence for a given table with the latest available
--                   number in the actual table.
--
-- Preconditions  : Cannot be used in a distributed database environment.
--                : Only designed to work for Line Item template table
--
-- Using tables   : ASSIGN_ID
--
-- Using functions: assignNextNumber
--
-- Configuration
-- required       :
--
-- Behaviour      : Calls assignNextNumber and checks the retrived value for existence in
--                  Line Item template table. Skips over to the next value if found and re applies this
--                  until a non existent value if found.
--
-------------------------------------------------------------------------------------------------
FUNCTION AssignNextUniqueNumber (p_table_name VARCHAR2, p_column_name VARCHAR2, p_code VARCHAR2 )
RETURN NUMBER
--</EC-DOC>
IS

lv_val_cnt NUMBER :=0 ;
lv_catch_value NUMBER :=0 ;
lv_sql VARCHAR2(500) := '' ;

BEGIN

     LOOP
         Ecdp_System_Key.assignNextNumber(p_table_name, lv_catch_value);

         lv_sql := 'Select count(*) from '|| p_table_name ||' where '||  p_column_name ||' = '''|| p_code||lv_catch_value||'''' ;

         EXECUTE IMMEDIATE  lv_sql  INTO lv_val_cnt ;

     EXIT WHEN lv_val_cnt = 0 ;

     End  Loop ;

RETURN lv_catch_value;

EXCEPTION
  WHEN OTHERS THEN
    Raise_Application_Error(-20000,'Invalid sql : ' || lv_sql);

END AssignNextUniqueNumber;


END;