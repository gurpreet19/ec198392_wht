create or replace package UE_CT_ECDP_WELL is

  -- Author  : FVOH
  -- Created : 1/12/2011 3:33:24 PM
  -- Purpose : Created as a replacement package of ECDP_WELL to handle SHI well status code.  In ECDP_WELL, the SHUT_IN code
  --           is hardcoded in the procedure checkOtherside, and this code is not active.

PROCEDURE checkOtherSide(
    p_object_id            VARCHAR2,
    p_daytime              DATE,
    p_inj_phase            VARCHAR2
);

end UE_CT_ECDP_WELL;
/
create or replace package body UE_CT_EcDp_WELL is

--------------------------------------------------------------------------------------------------
-- Procedure      : checkOtherSide
-- Description    : To check if another side of the well is Open, then follows the following conditions.
--                  This version uses the well status code SHI, and not SHUT_IN which is an inactive
--                  code.  ECDP_WELL.checkOtherside uses the code SHUT_IN, and therefore this replacement
--                  procedure has been created.
--
-- Preconditions  : Upon inserting or updating record in iwel_period_status
-- Postconditions :
--
-- Using tables   :iwel_period_status
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
-- Function and procedure implementations



--exmn Added the executestatement as Tieto removed this procedure from ecdp_utilities from SP02 to SP03
  
FUNCTION executeStatement(
p_statement varchar2)

RETURN VARCHAR2
--</EC-DOC>
IS

li_cursor  integer;
li_ret_val  integer;
lv2_err_string VARCHAR2(32000);

BEGIN

   li_cursor := DBMS_SQL.open_cursor;

   DBMS_SQL.parse(li_cursor,p_statement,DBMS_SQL.v7);
   li_ret_val := DBMS_SQL.execute(li_cursor);
   DBMS_SQL.Close_Cursor(li_cursor);

  RETURN NULL;

EXCEPTION
   WHEN DUP_VAL_ON_INDEX THEN
       DBMS_SQL.Close_Cursor(li_cursor);

    -- record not inserted, already there...
    lv2_err_string := 'Failed to execute (record exists): ' || chr(10) || p_statement || chr(10);
    return lv2_err_string;
  WHEN INVALID_CURSOR THEN

    lv2_err_string := 'Failed to execute (' || SQLERRM || '): ' || chr(10) || p_statement || chr(10);
    return lv2_err_string;

  WHEN OTHERS THEN
    IF DBMS_SQL.is_open(li_cursor) THEN
      DBMS_SQL.Close_Cursor(li_cursor);
      END IF;

    lv2_err_string := 'Failed to execute (' || SQLERRM || '): ' || chr(10) || p_statement || chr(10);
    return lv2_err_string;

END executeStatement;

PROCEDURE checkOtherSide(
   p_object_id       VARCHAR2,
   p_daytime         DATE,
   p_inj_phase       VARCHAR2
)
--</EC-DOC>

IS
  CURSOR c_iwel_period_status (cp_object_id VARCHAR2, cp_daytime DATE, cp_inj_phase VARCHAR2) IS
     SELECT *
     FROM iwel_period_status
     WHERE object_id = cp_object_id
     AND inj_type <> cp_inj_phase
     AND daytime =
                (SELECT MAX(daytime)
                 FROM iwel_period_status
                 WHERE object_id = cp_object_id
                 AND inj_type <> cp_inj_phase);
                -- AND daytime <> to_date(cp_daytime,'yyyy-mm-dd hh24:mi:ss'));

lv_active_status VARCHAR2(32);
ld_date          DATE;
lv_inj_type      VARCHAR2(2);
lv_sql           VARCHAR2(3000);
lv_result        VARCHAR2(4000);


BEGIN
      FOR cur_iwel_period_status IN c_iwel_period_status (p_object_id, p_daytime, p_inj_phase) LOOP
          lv_active_status := cur_iwel_period_status.active_well_status;
          ld_date := cur_iwel_period_status.daytime;
          lv_inj_type := cur_iwel_period_status.inj_type;

          IF lv_active_status = 'OPEN' THEN
             IF ld_date < p_daytime THEN

               lv_sql := 'INSERT INTO iwel_period_status (object_id,daytime,time_span,summer_time,inj_type,well_status)'||
                         'VALUES ('''|| p_object_id ||''',to_date('''||to_char(p_daytime,'yyyy-mm-dd hh24:mi:ss')||''',''yyyy-mm-dd hh24:mi:ss''),''EVENT'',''N'','''|| lv_inj_type ||''',''SHI'')';

               lv_result := executeStatement(lv_sql);

               IF lv_result IS NOT NULL THEN
                  RAISE_APPLICATION_ERROR(-20000,'Fail inserting new record');
               END IF;

             ELSIF ld_date = p_daytime THEN
               lv_sql := 'UPDATE iwel_period_status SET well_status=''SHI'''||
                         'WHERE object_id= '''|| p_object_id ||''''||
                         'AND daytime = to_date('''||to_char(p_daytime,'yyyy-mm-dd hh24:mi:ss')||''',''yyyy-mm-dd hh24:mi:ss'')'||
                         'AND inj_type = '''|| lv_inj_type ||'''';

               lv_result := executeStatement(lv_sql);

               IF lv_result IS NOT NULL THEN
                  RAISE_APPLICATION_ERROR(-20000,'Fail inserting new record');
               END IF;

             END IF;
         END IF;
      END LOOP;


END checkOtherSide;
end UE_CT_ECDP_WELL;
/
