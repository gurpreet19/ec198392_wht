CREATE OR REPLACE PACKAGE BODY EcDp_AlertLog IS

TYPE KeyValue_M IS TABLE OF VARCHAR2(250) INDEX BY VARCHAR2(30);
TYPE Key_L IS TABLE OF VARCHAR2(30);

keyValueMap KeyValue_M;
keyTypeMap KeyValue_M;
keyList Key_L := Key_L();

----------------------------------------------------------------------------------------
-- Return input string in single quotes
----------------------------------------------------------------------------------------
FUNCTION squote(p_text IN VARCHAR2) RETURN VARCHAR2
IS
BEGIN
   RETURN CHR(39)||p_text||CHR(39);
END squote;

----------------------------------------------------------------------------------------
-- Return formatted call stack including parameters if they have been registered
----------------------------------------------------------------------------------------
FUNCTION getCallStack(p_start_depth IN INTEGER) RETURN VARCHAR2
IS
   l_depth PLS_INTEGER;
   lv2_call_stack VARCHAR2(32000);
   lv2_key VARCHAR2(30);
   lv2_parameter_values VARCHAR2(4000) := '';
BEGIN
  IF keyValueMap.COUNT > 0 THEN
      FOR i IN 1..keyList.COUNT LOOP
          lv2_key := keyList(i);
         IF i > 1 THEN
            lv2_parameter_values := lv2_parameter_values || ', ';
         END IF;
         lv2_parameter_values := lv2_parameter_values || chr(10) || '    ' || lv2_key || ' ' || keyTypeMap(lv2_key) || ' => ' || keyValueMap(lv2_key);
      END LOOP;
   END IF;

   lv2_call_stack := utl_call_stack.concatenate_subprogram(utl_call_stack.subprogram(p_start_depth));
   IF length(lv2_parameter_values) > 0 THEN
      lv2_call_stack := lv2_call_stack || '(' || lv2_parameter_values || ')';
   ELSE
      lv2_call_stack := lv2_call_stack || '(' || 'N/A' || ')';
   END IF;

   lv2_call_stack := lv2_call_stack || chr(10) || chr(10) ||
                     '=========================== CALL STACK ===========================' || chr(10) || chr(10);

   l_depth := utl_call_stack.dynamic_depth;
   lv2_call_stack := lv2_call_stack ||
                     'Depth   Line  Status     Name'||chr(10)||
                     '------------------------------------------------------------------';
   FOR i IN p_start_depth..l_depth LOOP
      lv2_call_stack := lv2_call_stack ||
          chr(10) ||
          rpad(to_char(l_depth-i+1), 5) || ' ' ||
          rpad(to_char(utl_call_stack.unit_line(i),'99999'), 7) || ' ' ||
          rpad(CASE WHEN i = p_start_depth THEN 'DEPRECATED' ELSE 'CALL' END, 10) || ' ' ||
          utl_call_stack.concatenate_subprogram(utl_call_stack.subprogram(i));
   END LOOP;

   RETURN substr(lv2_call_stack, 1, 4000);
END getCallStack;

----------------------------------------------------------------------------------------
-- Register parameter to function/procedure (included in t_alert_log.context)
----------------------------------------------------------------------------------------
PROCEDURE addParam(p_name IN VARCHAR2, p_value IN VARCHAR2)
IS
BEGIN
   keyList.EXTEND(1);
   keyList(keyList.COUNT) := p_name;
   keyValueMap(p_name) := CASE WHEN p_value IS NULL THEN 'NULL' ELSE squote(p_value) END;
   keyTypeMap(p_name) := 'VARCHAR2';
END addParam;

----------------------------------------------------------------------------------------
-- Register parameter to function/procedure (included in t_alert_log.context)
----------------------------------------------------------------------------------------
PROCEDURE addParam(p_name IN VARCHAR2, p_value IN NUMBER)
IS
BEGIN
   keyList.EXTEND(1);
   keyList(keyList.COUNT) := p_name;
   keyValueMap(p_name) := CASE WHEN p_value IS NULL THEN 'NULL' ELSE to_char(p_value) END;
   keyTypeMap(p_name) := 'NUMBER';
END addParam;

----------------------------------------------------------------------------------------
-- Register parameter to function/procedure (included in t_alert_log.context)
----------------------------------------------------------------------------------------
PROCEDURE addParam(p_name IN VARCHAR2, p_value IN DATE)
IS
BEGIN
   keyList.EXTEND(1);
   keyList(keyList.COUNT) := p_name;
   keyValueMap(p_name) := CASE WHEN p_value IS NULL THEN 'NULL' ELSE squote(to_char(p_value, 'YYYY-MM-DD')) END;
   keyTypeMap(p_name) := 'DATE';
END addParam;

----------------------------------------------------------------------------------------
-- Clear registered parameters.
----------------------------------------------------------------------------------------
PROCEDURE clearParams
IS
BEGIN
  keyTypeMap.DELETE;
  keyValueMap.DELETE;
  keyList.DELETE;
  keyList := Key_L();
END clearParams;

----------------------------------------------------------------------------------------
-- Insert entry in t_alert_log with type='DEPRECATED' using AUTONOMOUS TRANSACTION
----------------------------------------------------------------------------------------
PROCEDURE deprecate(p_message IN VARCHAR2)
IS
   PRAGMA AUTONOMOUS_TRANSACTION;

   lv2_origin VARCHAR2(240) := utl_call_stack.concatenate_subprogram(utl_call_stack.subprogram(2));
   lv2_call_stack VARCHAR2(4000) := getCallStack(3);
BEGIN

  INSERT INTO t_alert_log (type, origin, message, context) VALUES ('DEPRECATED', lv2_origin, p_message, lv2_call_stack);
  COMMIT;

  clearParams;
END deprecate;

END EcDp_AlertLog;