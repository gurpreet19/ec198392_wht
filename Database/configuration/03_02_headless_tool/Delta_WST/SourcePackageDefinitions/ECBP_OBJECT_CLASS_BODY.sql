CREATE OR REPLACE PACKAGE BODY EcBp_Object_Class IS

/****************************************************************
** Package        :  EcBp_Object_Class, body part
**
** $Revision: 1.11 $
**
** Purpose        :  Provide basic functions on objects
**
** Documentation  :  www.energy-components.com
**
** Created  : 08.04.2008  Nurliza Jailuddin
**
** Modification history:
**
**  Date       Whom     Change description:
**  ------     -----    --------------------------------------
**  06.03.2008 LIZ      ECPD-4576: Added new procedures CopyObject, WellObject, StreamObject, TankObject
**  21.11.2008 oonnnng  ECPD-6067: Added local month lock checking in CopyObject function.
**  31.12.2008 lauufus  ECPD-10698: Added new User Exit Ue_Object_Class.CopyObject in CopyObject()
**  17.02.2008 leongsei ECPD-6067: Modified function CopyObject for new parameter p_local_lock
**  10.04.2009 oonnnng  ECPD-6067: Update local lock checking function in CopyObject() function with the new design.
**  01.03.2012 musaamah ECPD-18791: Added copied well value down to Perforation Interval.
**  19.04.2012 rajarsar ECPD-20264: Updated procedure StreamObject to ensure correct stream set lists are inserted during copy object.
**  13.09.2013 abdulmaw ECPD-23509: Added new function  getObjName
**  01.11.2013 abdulmaw ECPD-22183: Added new function  copyNewRecord
**  26.05.2015 abdulmaw ECPD-27318: Updated CopyObject function to support Month lock correctly
**  10.09.2015 jainnraj ECPD-31624: Modified PROCEDURE StreamObject to remove FROM_DATE conditions from cursor c_strm_set_list and lv_value on line number 612.
**  31.08.2016 dhavaalo ECPD-38607: Remove usage of EcDp_Utilities.executestatement.
**  10.10.2018 bintjnor ECPD-54963: Added missing Facility Class 1 records in getObjName function.
****************************************************************/
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : executeStatement                                                          --
-- Description    : Used to run Dyanamic sql statements.
--                                                                                               --
-- Preconditions  :                --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                --
--                                                                                               --
-- Using functions:                                                 --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
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
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : CopyObject
-- Description    : Use this function to copy all attributes of an object onto a new object plus child.
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : class
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :  Builds insert statements based on the parameters passed.
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE CopyObject(
   p_class_name      VARCHAR2,
   p_object_id       VARCHAR2,
   p_daytime         DATE,
   p_new_code        VARCHAR2,
   p_new_name        VARCHAR2,
   p_new_date        DATE
)
--</EC-DOC>

IS
  CURSOR c_col_name IS
     SELECT property_name
     FROM v_dao_meta
     WHERE class_name = p_class_name
     AND is_popup = 'N'
     AND NOT (is_relation_code = 'Y' AND group_type IS NULL) -- ignore relation code
     AND Nvl(is_report_only,'N') = 'N'
     AND db_mapping_type in ('COLUMN', 'ATTRIBUTE')
     AND property_name not in ('OBJECT_ID','OBJECT_START_DATE','CODE','NAME','DAYTIME');

  lv_sql                 VARCHAR2(32000);
  lv_col                 VARCHAR2(32000);
  lv_value               VARCHAR2(32000);
  lv_result              VARCHAR2(4000);
  lv_oriCode             VARCHAR2(1000);
  lv_newId               VARCHAR2(1000);

BEGIN
      IF (p_object_id is null) THEN
        RAISE_APPLICATION_ERROR (-20697, 'No row is being selected');
      END IF;

      IF EcDp_ClassMeta_Cnfg.getLockInd(p_class_name) = 'Y' THEN
         EcDp_Month_lock.validatePeriodForLockOverlap('INSERTING',p_new_date,NULL,'CLASS: WELL; OBJECT_CODE:'||p_new_code, p_object_id);
      END IF;

      lv_oriCode := ecdp_objects.GetObjCode(p_object_id);

      lv_sql := 'INSERT INTO OV_'|| p_class_name ||'(OBJECT_ID,OBJECT_START_DATE,CODE,NAME,DAYTIME,REV_TEXT';
      lv_value := '(SELECT null,to_date('''||to_char(p_new_date,'yyyy-mm-dd')||''',''yyyy-mm-dd''),'''|| p_new_code ||''','''|| p_new_name ||''','||
                  'to_date('''||to_char(p_new_date,'yyyy-mm-dd')||''',''yyyy-mm-dd''),'''|| p_class_name ||' created as a copy of '|| lv_oriCode ||'''';

      OPEN c_col_name;
      FETCH c_col_name INTO lv_col;

      IF c_col_name%NOTFOUND THEN
        CLOSE c_col_name;
        RAISE_APPLICATION_ERROR(-20000,'No common data columns found for given classes.');
      END IF;

      LOOP

        lv_sql := lv_sql || ',' || lv_col;
        lv_value := lv_value || ',' || lv_col;

        FETCH c_col_name INTO lv_col;
        IF c_col_name%NOTFOUND THEN

          lv_sql := lv_sql || ')';

          EXIT;
        END IF;
      END LOOP;
      CLOSE c_col_name;

      lv_value := lv_value || ' FROM OV_'|| p_class_name ||' WHERE OBJECT_ID='''|| p_object_id ||''' AND DAYTIME=to_date('''||to_char(p_daytime,'yyyy-mm-dd')||''',''yyyy-mm-dd''))';

      lv_sql := lv_sql || lv_value;

      lv_result := executeStatement(lv_sql);

      IF lv_result IS NOT NULL THEN
        RAISE_APPLICATION_ERROR(-20000,'Fail to copy new ' || p_class_name );
      ELSE

        lv_newId := Ecdp_Objects.GetObjIDFromCode(p_class_name,p_new_code);

        IF p_class_name ='WELL' THEN
          EcBp_Object_Class.WellObject(p_object_id,lv_newId,p_new_code,p_new_name,p_new_date,p_daytime);
        ELSIF p_class_name ='STREAM' THEN
          EcBp_Object_Class.StreamObject(p_object_id,lv_newId,p_new_code,p_new_name,p_new_date,p_daytime);
        ELSIF p_class_name ='TANK' THEN
          EcBp_Object_Class.TankObject(p_object_id,lv_newId,p_new_code,p_new_name,p_new_date,p_daytime);
        END IF;

        Ue_Object_Class.CopyObject(p_class_name, p_object_id, p_daytime, p_new_code, p_new_name, p_new_date);

      END IF;

END CopyObject;

---------------------------------------------------------------------------------------------------------------

PROCEDURE WellObject(
          p_ori_id         VARCHAR2,
          p_new_id         VARCHAR2,
          p_new_code       VARCHAR2,
          p_new_name       VARCHAR2,
          p_new_date       DATE,
          p_daytime        DATE
)
IS
   CURSOR c_well_bore (cp_ori_id VARCHAR2, cp_daytime DATE, cp_new_date DATE) IS
          SELECT * FROM OV_WELL_BORE
          WHERE WELL_ID = cp_ori_id
		  AND DAYTIME <= cp_new_date
		  AND nvl(END_DATE,cp_new_date+1) > cp_new_date;

   CURSOR c_webo_interval (cp_webo_id VARCHAR2, cp_daytime DATE, cp_new_date DATE) IS
          SELECT * FROM OV_WELL_BORE_INTERVAL
          WHERE WELL_BORE_ID = cp_webo_id
		  AND DAYTIME <= cp_new_date
		  AND nvl(END_DATE,cp_new_date+1) > cp_new_date;

   CURSOR c_perf_interval (cp_webo_int_id VARCHAR2, cp_daytime DATE, cp_new_date DATE) IS
          SELECT * FROM ov_perf_interval
          WHERE WELL_BORE_INTERVAL_CODE = cp_webo_int_id
		  AND DAYTIME <= cp_new_date
		  AND nvl(END_DATE,cp_new_date+1) > cp_new_date;

   CURSOR c_wb_col IS
          SELECT property_name FROM v_dao_meta
          WHERE class_name = 'WELL_BORE'
          AND is_popup = 'N'
          AND NOT (is_relation_code = 'Y' AND group_type IS NULL) -- ignore relation code
          AND Nvl(is_report_only,'N') = 'N'
          AND db_mapping_type in ('COLUMN', 'ATTRIBUTE')
          AND property_name not in ('OBJECT_ID','OBJECT_START_DATE','CODE','NAME','DAYTIME','WELL_ID');

   CURSOR c_wb_split_col (cp_class_name VARCHAR2) IS
          SELECT property_name FROM v_dao_meta
          WHERE class_name = cp_class_name
          AND is_popup = 'N'
          AND NOT (is_relation_code = 'Y' AND group_type IS NULL) -- ignore relation code
          AND Nvl(is_report_only,'N') = 'N'
          AND db_mapping_type in ('COLUMN', 'ATTRIBUTE')
          AND property_name not in ('OBJECT_ID','DAYTIME','WELL_BORE_ID');

    CURSOR c_perf_int_split_col IS
          SELECT property_name FROM v_dao_meta
          WHERE class_name = 'PERF_INTERVAL_SPLIT'
          AND is_popup = 'N'
          AND NOT (is_relation_code = 'Y' AND group_type IS NULL) -- ignore relation code
          AND Nvl(is_report_only,'N') = 'N'
          AND db_mapping_type in ('COLUMN', 'ATTRIBUTE')
          AND property_name not in ('OBJECT_ID','DAYTIME','WEBO_INTERVAL_ID');

    CURSOR c_wb_int_col IS
          SELECT property_name FROM v_dao_meta
          WHERE class_name = 'WELL_BORE_INTERVAL'
          AND is_popup = 'N'
          AND NOT (is_relation_code = 'Y' AND group_type IS NULL) -- ignore relation code
          AND Nvl(is_report_only,'N') = 'N'
          AND db_mapping_type in ('COLUMN', 'ATTRIBUTE')
          AND property_name not in ('OBJECT_ID','CODE','NAME','DAYTIME','OBJECT_START_DATE','WELL_BORE_ID');

    CURSOR c_perf_int_col IS
          SELECT property_name FROM v_dao_meta
          WHERE class_name = 'PERF_INTERVAL'
          AND is_popup = 'N'
          AND NOT (is_relation_code = 'Y' AND group_type IS NULL) -- ignore relation code
          AND Nvl(is_report_only,'N') = 'N'
          AND db_mapping_type in ('COLUMN', 'ATTRIBUTE')
          AND property_name not in ('OBJECT_ID','CODE','NAME','DAYTIME','OBJECT_START_DATE','WELL_BORE_INTERVAL_ID', 'WELL_BORE_ID', 'WELL_ID');

ln_seq        NUMBER;
lv_oriCode    VARCHAR2(1000);
lv_sql        VARCHAR2(32000);
lv_value      VARCHAR2(32000);
lv_code       VARCHAR2(1000);
lv_name       VARCHAR2(1000);
lv_col        VARCHAR2(1000);
lv_result     VARCHAR2(4000);
lv_id         VARCHAR2(1000);
lv_newId      VARCHAR2(1000);
lv_sql1       VARCHAR2(32000);
lv_value1     VARCHAR2(32000);
lv_result1    VARCHAR2(4000);
ln_seq1       NUMBER;
lv_col1       VARCHAR2(1000);
ln_exist      NUMBER;
lv_code1      VARCHAR2(1000);
lv_name1      VARCHAR2(1000);
lv_sql2       VARCHAR2(32000);
lv_value2     VARCHAR2(32000);
lv_col2       VARCHAR2(1000);
lv_result2    VARCHAR2(4000);
lv_oriCode1   VARCHAR2(1000);
lv_newId1     VARCHAR2(1000);
ln_exist1     NUMBER;
lv_sql3       VARCHAR2(32000);
lv_value3     VARCHAR2(32000);
lv_col3       VARCHAR2(1000);
ln_seq2       NUMBER;
lv_oriCode2   VARCHAR2(1000);
lv_sql4       VARCHAR2(32000);
lv_value4     VARCHAR2(32000);
lv_code2      VARCHAR2(1000);
lv_name2      VARCHAR2(1000);
lv_col4       VARCHAR2(1000);
lv_result4    VARCHAR2(4000);
lv_newId2     VARCHAR2(1000);
ln_exist2     NUMBER;
lv_col5       VARCHAR2(1000);
lv_sql6       VARCHAR2(32000);
lv_value6     VARCHAR2(32000);
lv_result5    VARCHAR2(4000);

BEGIN
          ln_seq := 0;


          FOR cur_wb IN c_well_bore (p_ori_id, p_daytime,p_new_date) LOOP
                     lv_id := cur_wb.object_id;
                     ln_seq := ln_seq + 1;
                     lv_code := p_new_code ||'_WB'|| ln_seq;
                     lv_name := p_new_name ||'_WB'|| ln_seq;
                     lv_oriCode := ecdp_objects.GetObjCode(lv_id);

                     lv_sql := 'INSERT INTO OV_WELL_BORE(OBJECT_ID,CLASS_NAME,CODE,NAME,OBJECT_START_DATE,DAYTIME,WELL_ID,WELL_CODE,REV_TEXT';
                     lv_value := '(SELECT null,class_name,'''|| lv_code ||''','''|| lv_name ||''',to_date('''||to_char(p_new_date,'yyyy-mm-dd')||''',''yyyy-mm-dd''),'||
                                 'to_date('''||to_char(p_new_date,'yyyy-mm-dd')||''',''yyyy-mm-dd''),'''|| p_new_id ||''','''|| p_new_code ||''',''WELL_BORE created as a copy of '' || '''|| lv_oriCode ||'''';


                     OPEN c_wb_col;
                      FETCH c_wb_col INTO lv_col;

                      IF c_wb_col%NOTFOUND THEN
                         CLOSE c_wb_col;
                         RAISE_APPLICATION_ERROR(-20000,'No common data columns found for given classes.');
                      END IF;

                      LOOP

                             lv_sql := lv_sql || ',' || lv_col;
                             lv_value := lv_value || ',' || lv_col;

                        FETCH c_wb_col INTO lv_col;
                        IF c_wb_col%NOTFOUND THEN

                          lv_sql := lv_sql || ')';

                          EXIT;
                        END IF;
                      END LOOP;
                     CLOSE c_wb_col;
                     --add Check for multiple versions
                     lv_value := lv_value || ' FROM OV_WELL_BORE WHERE OBJECT_ID='''|| lv_id ||''' AND DAYTIME <= to_date('''||to_char(p_new_date,'yyyy-mm-dd')||''',''yyyy-mm-dd'')  AND nvl(END_DATE,to_date('''||to_char(p_new_date+1,'yyyy-mm-dd')||''',''yyyy-mm-dd''))> to_date('''||to_char(p_new_date,'yyyy-mm-dd')||''',''yyyy-mm-dd''))';

                     lv_sql := lv_sql || lv_value;

                     lv_result := executeStatement(lv_sql);

                     IF lv_result IS NOT NULL THEN
                        RAISE_APPLICATION_ERROR(-20000,'Fail to copy new WELL_BORE');
                     ELSE
                        lv_newId := Ecdp_Objects.GetObjIDFromCode('WELL_BORE',lv_code);

                        SELECT COUNT(*) INTO ln_exist FROM DV_WELL_BORE_SPLIT_FACTOR
                        WHERE WELL_BORE_ID=lv_id AND DAYTIME >= p_daytime
                        AND nvl(END_DATE,p_daytime+1) > p_daytime;

                            IF ln_exist > 0 THEN

                            lv_sql1 := 'INSERT INTO DV_WELL_BORE_SPLIT_FACTOR(CLASS_NAME,OBJECT_ID,OBJECT_CODE,DAYTIME,WELL_BORE_ID,REV_TEXT';
                            lv_value1 := '(SELECT CLASS_NAME,'''|| p_new_id ||''','''|| p_new_code ||''',to_date('''||to_char(p_new_date,'yyyy-mm-dd')||''',''yyyy-mm-dd''),'||
                                 ''''|| lv_newId ||''',''WELL_BORE_SPLIT_FACTOR created as a copy of '' || '''|| lv_oriCode ||'''';

                            OPEN c_wb_split_col ('WELL_BORE_SPLIT_FACTOR');
                                FETCH c_wb_split_col INTO lv_col1;

                                IF c_wb_split_col%NOTFOUND THEN
                                   CLOSE c_wb_split_col;
                                   RAISE_APPLICATION_ERROR(-20000,'No common data columns found for given classes.');
                                END IF;

                                LOOP

                                       lv_sql1 := lv_sql1 || ',' || lv_col1;
                                       lv_value1 := lv_value1 || ',' || lv_col1;

                                  FETCH c_wb_split_col INTO lv_col1;
                                  IF c_wb_split_col%NOTFOUND THEN

                                    lv_sql1 := lv_sql1 || ')';

                                    EXIT;
                                  END IF;
                                END LOOP;
                             CLOSE c_wb_split_col;
                             --Check for valid splits
                             lv_value1 := lv_value1 || ' FROM DV_WELL_BORE_SPLIT_FACTOR WHERE WELL_BORE_ID='''|| lv_id ||''' AND DAYTIME <= to_date('''||to_char(p_new_date,'yyyy-mm-dd')||''',''yyyy-mm-dd'')  AND nvl(END_DATE,to_date('''||to_char(p_new_date+1,'yyyy-mm-dd')||''',''yyyy-mm-dd''))> to_date('''||to_char(p_new_date,'yyyy-mm-dd')||''',''yyyy-mm-dd''))';

                             lv_sql1 := lv_sql1 || lv_value1;

                             lv_result1 := executeStatement(lv_sql1);

                             IF lv_result1 IS NOT NULL THEN
                                RAISE_APPLICATION_ERROR(-20000,'Fail to copy new WELL_BORE_SPLIT_FACTOR');
                             END IF;
                           END IF;

                            ln_seq1 := 0;

                           FOR cur_webo_int IN c_webo_interval (lv_id, p_daytime, p_new_date) LOOP
                              lv_oriCode1 := cur_webo_int.code;
                              ln_seq1 := ln_seq1 + 1;
                              lv_code1 := p_new_code ||'_WB'|| ln_seq ||'_Int'|| ln_seq1;
                              lv_name1 := p_new_name ||'_WB'|| ln_seq ||'_Int'|| ln_seq1;

                              lv_sql2 := 'INSERT INTO OV_WELL_BORE_INTERVAL(OBJECT_ID,CLASS_NAME,CODE,NAME,OBJECT_START_DATE,DAYTIME,WELL_BORE_ID,WELL_BORE_CODE,REV_TEXT';
                              lv_value2 := '(SELECT null,class_name,'''|| lv_code1 ||''','''|| lv_name1 ||''',to_date('''||to_char(p_new_date,'yyyy-mm-dd')||''',''yyyy-mm-dd''),'||
                                           'to_date('''||to_char(p_new_date,'yyyy-mm-dd')||''',''yyyy-mm-dd''),'''|| lv_newId ||''','''|| lv_code ||''',''WELL_BORE_INTERVAL created as a copy of '' || '''|| lv_oriCode1 ||'''';

                              OPEN c_wb_int_col;
                              FETCH c_wb_int_col INTO lv_col2;

                              IF c_wb_int_col%NOTFOUND THEN
                                 CLOSE c_wb_int_col;
                                 RAISE_APPLICATION_ERROR(-20000,'No common data columns found for given classes.');
                              END IF;

                              LOOP

                                     lv_sql2 := lv_sql2 || ',' || lv_col2;
                                     lv_value2 := lv_value2 || ',' || lv_col2;

                                FETCH c_wb_int_col INTO lv_col2;
                                IF c_wb_int_col%NOTFOUND THEN

                                  lv_sql2 := lv_sql2 || ')';

                                  EXIT;
                                END IF;
                              END LOOP;
                             CLOSE c_wb_int_col;
                                     --added check for multiple versions
                                     lv_value2 := lv_value2 || ' FROM OV_WELL_BORE_INTERVAL WHERE CODE='''|| lv_oriCode1 ||''' AND DAYTIME <= to_date('''||to_char(p_new_date,'yyyy-mm-dd')||''',''yyyy-mm-dd'')  AND nvl(END_DATE,to_date('''||to_char(p_new_date+1,'yyyy-mm-dd')||''',''yyyy-mm-dd''))> to_date('''||to_char(p_new_date,'yyyy-mm-dd')||''',''yyyy-mm-dd''))';

                                     lv_sql2 := lv_sql2 || lv_value2;

                                     lv_result2 := executeStatement(lv_sql2);

                                     IF lv_result1 IS NOT NULL THEN
                                        RAISE_APPLICATION_ERROR(-20000,'Fail to copy new WELL_BORE_INTERVAL');
                                     ELSE
                                        lv_newId1 := Ecdp_Objects.GetObjIDFromCode('WELL_BORE_INTERVAL',lv_code1);

                                        SELECT COUNT(*) INTO ln_exist1 FROM DV_WELL_BORE_INTERVAL_SPLIT
                                        WHERE OBJECT_CODE=lv_oriCode1 AND DAYTIME >= p_daytime
                                        AND nvl(END_DATE,p_daytime+1) > p_daytime;

                                            IF ln_exist1 > 0 THEN

                                            lv_sql3 := 'INSERT INTO DV_WELL_BORE_INTERVAL_SPLIT(CLASS_NAME,OBJECT_ID,OBJECT_CODE,DAYTIME,WELL_BORE_ID,REV_TEXT';
                                            lv_value3 := '(SELECT CLASS_NAME,'''|| lv_newId1 ||''','''|| lv_code1 ||''',to_date('''||to_char(p_new_date,'yyyy-mm-dd')||''',''yyyy-mm-dd''),'||
                                                 ''''|| lv_newId ||''',''WELL_BORE_INTERVAL_SPLIT created as a copy of '' || '''|| lv_oriCode1 ||'''';

                                            OPEN c_wb_split_col ('WELL_BORE_INTERVAL_SPLIT');
                                                FETCH c_wb_split_col INTO lv_col3;

                                                IF c_wb_split_col%NOTFOUND THEN
                                                   CLOSE c_wb_split_col;
                                                   RAISE_APPLICATION_ERROR(-20000,'No common data columns found for given classes.');
                                                END IF;

                                                LOOP

                                                       lv_sql3 := lv_sql3 || ',' || lv_col3;
                                                       lv_value3 := lv_value3 || ',' || lv_col3;

                                                  FETCH c_wb_split_col INTO lv_col3;
                                                  IF c_wb_split_col%NOTFOUND THEN

                                                    lv_sql3 := lv_sql3 || ')';

                                                    EXIT;
                                                  END IF;
                                                END LOOP;
                                             CLOSE c_wb_split_col;
                                             --check for valid splts which are open.
                                             lv_value3 := lv_value3 || ' FROM DV_WELL_BORE_INTERVAL_SPLIT WHERE OBJECT_CODE='''|| lv_oriCode1 ||''' AND DAYTIME <= to_date('''||to_char(p_new_date,'yyyy-mm-dd')||''',''yyyy-mm-dd'')  AND nvl(END_DATE,to_date('''||to_char(p_new_date+1,'yyyy-mm-dd')||''',''yyyy-mm-dd''))> to_date('''||to_char(p_new_date,'yyyy-mm-dd')||''',''yyyy-mm-dd''))';

                                             lv_sql3 := lv_sql3 || lv_value3;

                                             lv_result1 := executeStatement(lv_sql3);

                                             IF lv_result1 IS NOT NULL THEN
                                                RAISE_APPLICATION_ERROR(-20000,'Fail to copy new WELL_BORE_SPLIT_FACTOR');
                                             END IF;
                                           END IF;

                                           ln_seq2 := 0;

                                           FOR cur_perf_interval IN c_perf_interval (lv_oriCode1, p_daytime, p_new_date) LOOP
                                              lv_oriCode2 := cur_perf_interval.code;
                                              ln_seq2 := ln_seq2 + 1;
                                              lv_code2 := p_new_code ||'_WB'|| ln_seq ||'_Int'|| ln_seq1 ||'_PF'|| ln_seq2;
                                              lv_name2 := p_new_name ||'_WB'|| ln_seq ||'_Int'|| ln_seq1 ||'_PF'|| ln_seq2;

                                              lv_sql4 := 'INSERT INTO OV_PERF_INTERVAL(OBJECT_ID,CLASS_NAME,CODE,NAME,OBJECT_START_DATE,DAYTIME,WELL_BORE_INTERVAL_ID,WELL_BORE_INTERVAL_CODE,WELL_ID,WELL_BORE_ID,REV_TEXT';
                                              lv_value4 := '(SELECT null,class_name,'''|| lv_code2 ||''','''|| lv_name2 ||''',to_date('''||to_char(p_new_date,'yyyy-mm-dd')||''',''yyyy-mm-dd''),'||
                                                 'to_date('''||to_char(p_new_date,'yyyy-mm-dd')||''',''yyyy-mm-dd''),'''|| lv_newId1 ||''','''|| lv_code1 ||''','''|| p_new_id ||''','''|| lv_newId ||''',''PERFORATION_INTERVAL created as a copy of '' || '''|| lv_oriCode2 ||'''';

                                              OPEN c_perf_int_col;
                                                FETCH c_perf_int_col INTO lv_col4;

                                                IF c_perf_int_col%NOTFOUND THEN
                                                   CLOSE c_perf_int_col;
                                                   RAISE_APPLICATION_ERROR(-20000,'No common data columns found for given classes.');
                                                END IF;

                                                LOOP

                                                       lv_sql4 := lv_sql4 || ',' || lv_col4;
                                                       lv_value4 := lv_value4 || ',' || lv_col4;

                                                  FETCH c_perf_int_col INTO lv_col4;
                                                  IF c_perf_int_col%NOTFOUND THEN

                                                    lv_sql4 := lv_sql4 || ')';

                                                    EXIT;
                                                  END IF;
                                                END LOOP;
                                               CLOSE c_perf_int_col;
                                               --add Check for multiple versions
                                               lv_value4 := lv_value4 || ' FROM OV_PERF_INTERVAL WHERE CODE='''|| lv_oriCode2 ||''' AND DAYTIME <= to_date('''||to_char(p_new_date,'yyyy-mm-dd')||''',''yyyy-mm-dd'')  AND nvl(END_DATE,to_date('''||to_char(p_new_date+1,'yyyy-mm-dd')||''',''yyyy-mm-dd''))> to_date('''||to_char(p_new_date,'yyyy-mm-dd')||''',''yyyy-mm-dd''))';

                                               lv_sql4 := lv_sql4 || lv_value4;

                                               lv_result4 := executeStatement(lv_sql4);

                                               IF lv_result4 IS NOT NULL THEN
                                                  RAISE_APPLICATION_ERROR(-20000,'Fail to copy new PERFORATION_INTERVAL');
                                               ELSE
                                                  lv_newId2 := Ecdp_Objects.GetObjIDFromCode('PERF_INTERVAL',lv_code2);

                                                  SELECT COUNT(*) INTO ln_exist2 FROM DV_PERF_INTERVAL_SPLIT
                                                  WHERE OBJECT_CODE=lv_oriCode2 AND DAYTIME >= p_daytime
                                                  AND nvl(END_DATE,p_daytime+1) > p_daytime;

                                                      IF ln_exist2 > 0 THEN

                                                      lv_sql6 := 'INSERT INTO DV_PERF_INTERVAL_SPLIT(CLASS_NAME,OBJECT_ID,OBJECT_CODE,DAYTIME,WEBO_INTERVAL_ID,REV_TEXT';
                                                      lv_value6 := '(SELECT CLASS_NAME,'''|| lv_newId2 ||''','''|| lv_code2 ||''',to_date('''||to_char(p_new_date,'yyyy-mm-dd')||''',''yyyy-mm-dd''),'||
                                                           ''''|| lv_newId1 ||''',''PERFORATION_INTERVAL_SPLIT created as a copy of '' || '''|| lv_oriCode2 ||'''';

                                                      OPEN c_perf_int_split_col;
                                                          FETCH c_perf_int_split_col INTO lv_col5;

                                                          IF c_perf_int_split_col%NOTFOUND THEN
                                                             CLOSE c_perf_int_split_col;
                                                             RAISE_APPLICATION_ERROR(-20000,'No common data columns found for given classes.');
                                                          END IF;

                                                          LOOP

                                                                 lv_sql6 := lv_sql6 || ',' || lv_col5;
                                                                 lv_value6 := lv_value6 || ',' || lv_col5;

                                                            FETCH c_perf_int_split_col INTO lv_col5;
                                                            IF c_perf_int_split_col%NOTFOUND THEN

                                                              lv_sql6 := lv_sql6 || ')';

                                                              EXIT;
                                                            END IF;
                                                          END LOOP;
                                                       CLOSE c_perf_int_split_col;
                                                             --check for valid splts which are open.
                                                             lv_value6 := lv_value6 || ' FROM DV_PERF_INTERVAL_SPLIT WHERE OBJECT_CODE='''|| lv_oriCode2 ||''' AND DAYTIME <= to_date('''||to_char(p_new_date,'yyyy-mm-dd')||''',''yyyy-mm-dd'')  AND nvl(END_DATE,to_date('''||to_char(p_new_date+1,'yyyy-mm-dd')||''',''yyyy-mm-dd''))> to_date('''||to_char(p_new_date,'yyyy-mm-dd')||''',''yyyy-mm-dd''))';

                                                             lv_sql6 := lv_sql6 || lv_value6;

                                                             lv_result5 := executeStatement(lv_sql6);

                                                             IF lv_result5 IS NOT NULL THEN
                                                                RAISE_APPLICATION_ERROR(-20000,'Fail to copy new PERF_INTERVAL_SPLIT');
                                                             END IF;

                                                      END IF;

                                                END IF;
                                            END LOOP;
                                            ln_seq2 := 0;

                                     END IF;

                              END LOOP;
                              ln_seq1 := 0;
                     END IF;

          END LOOP;


END WellObject;
-------------------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE StreamObject(
          p_ori_id         VARCHAR2,
          p_new_id         VARCHAR2,
          p_new_code       VARCHAR2,
          p_new_name       VARCHAR2,
          p_new_date       DATE,
          p_daytime        DATE
)
IS

CURSOR c_strm_set_list (cp_ori_id VARCHAR2, cp_daytime DATE) IS
          SELECT * FROM TV_STREAM_SET_LIST
          WHERE STREAM_ID = cp_ori_id
          AND nvl(END_DATE,cp_daytime+1) > cp_daytime;

CURSOR c_strm_set_list_col IS
          SELECT property_name FROM v_dao_meta
          WHERE class_name = 'STREAM_SET_LIST'
          AND is_popup = 'N'
          AND NOT (is_relation_code = 'Y' AND group_type IS NULL) -- ignore relation code
          AND Nvl(is_report_only,'N') = 'N'
          AND db_mapping_type in ('COLUMN', 'ATTRIBUTE')
          AND property_name not in ('STREAM_ID','STREAM_NAME','FROM_DATE','CODE');

lv_sql        VARCHAR2(32000);
lv_value      VARCHAR2(32000);
lv_oriCode    VARCHAR2(1000);
lv_col        VARCHAR2(1000);
lv_result     VARCHAR2(4000);
lv_code       VARCHAR2(1000);

BEGIN
          lv_oriCode := ecdp_objects.GetObjCode(p_ori_id);

          FOR cur_strm_set_list IN c_strm_set_list (p_ori_id, p_new_date) LOOP
              lv_code := cur_strm_set_list.code;
              lv_sql := 'INSERT INTO TV_STREAM_SET_LIST(TABLE_CLASS_NAME,STREAM_ID,STREAM_NAME,CODE,FROM_DATE,REV_TEXT';
              lv_value := '(SELECT TABLE_CLASS_NAME,'''|| p_new_id ||''','''|| p_new_name ||''','''|| lv_code ||''','||
                          'to_date('''||to_char(p_new_date,'yyyy-mm-dd')||''',''yyyy-mm-dd''),''STREAM_SET_LIST created as a copy of '' || '''|| lv_oriCode ||'''';

              OPEN c_strm_set_list_col;
                      FETCH c_strm_set_list_col INTO lv_col;

                      IF c_strm_set_list_col%NOTFOUND THEN
                         CLOSE c_strm_set_list_col;
                         RAISE_APPLICATION_ERROR(-20000,'No common data columns found for given classes.');
                      END IF;

                      LOOP

                             lv_sql := lv_sql || ',' || lv_col;
                             lv_value := lv_value || ',' || lv_col;

                        FETCH c_strm_set_list_col INTO lv_col;
                        IF c_strm_set_list_col%NOTFOUND THEN

                          lv_sql := lv_sql || ')';

                          EXIT;
                        END IF;
                      END LOOP;
                  CLOSE c_strm_set_list_col;

		        lv_value := lv_value || ' FROM TV_STREAM_SET_LIST WHERE STREAM_ID='''|| p_ori_id ||''' AND CODE='''|| lv_code ||''')';

                     lv_sql := lv_sql || lv_value;

                     lv_result := executeStatement(lv_sql);

                     IF lv_result IS NOT NULL THEN
                        RAISE_APPLICATION_ERROR(-20000,'Fail to copy new STREAM_SET_LIST');
                     END IF;
          END LOOP;

END StreamObject;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE TankObject(
          p_ori_id         VARCHAR2,
          p_new_id         VARCHAR2,
          p_new_code       VARCHAR2,
          p_new_name       VARCHAR2,
          p_new_date       DATE,
          p_daytime        DATE
)
IS

CURSOR c_tank_usage (cp_ori_id VARCHAR2, cp_daytime DATE) IS
          SELECT * FROM DV_TANK_USAGE
          WHERE TANK_ID = cp_ori_id
          AND DAYTIME >= cp_daytime
          AND nvl(END_DATE,cp_daytime+1) > cp_daytime;

CURSOR c_tank_usage_col IS
          SELECT property_name FROM v_dao_meta
          WHERE class_name = 'TANK_USAGE'
          AND is_popup = 'N'
          AND NOT (is_relation_code = 'Y' AND group_type IS NULL) -- ignore relation code
          AND Nvl(is_report_only,'N') = 'N'
          AND db_mapping_type in ('COLUMN', 'ATTRIBUTE')
          AND property_name not in ('OBJECT_ID','OBJECT_CODE','TANK_ID','TANK_CODE','DAYTIME');

lv_sql        VARCHAR2(32000);
lv_value      VARCHAR2(32000);
lv_oriCode    VARCHAR2(1000);
lv_col        VARCHAR2(1000);
lv_result     VARCHAR2(4000);
lv_code       VARCHAR2(1000);

BEGIN
          lv_oriCode := ecdp_objects.GetObjCode(p_ori_id);

          FOR cur_tank_usage IN c_tank_usage (p_ori_id, p_daytime) LOOP
              lv_code := cur_tank_usage.OBJECT_CODE;
              lv_sql := 'INSERT INTO DV_TANK_USAGE(CLASS_NAME,OBJECT_ID,OBJECT_CODE,TANK_ID,TANK_CODE,DAYTIME,REV_TEXT';
              lv_value := '(SELECT CLASS_NAME,OBJECT_ID,'''|| lv_code ||''','''|| p_new_id ||''','''|| p_new_code ||''','||
                          'to_date('''||to_char(p_new_date,'yyyy-mm-dd')||''',''yyyy-mm-dd''),''TANK_USAGE created as a copy of '' || '''|| lv_oriCode ||'''';

              OPEN c_tank_usage_col;
                      FETCH c_tank_usage_col INTO lv_col;

                      IF c_tank_usage_col%NOTFOUND THEN
                         CLOSE c_tank_usage_col;
                         RAISE_APPLICATION_ERROR(-20000,'No common data columns found for given classes.');
                      END IF;

                      LOOP

                             lv_sql := lv_sql || ',' || lv_col;
                             lv_value := lv_value || ',' || lv_col;

                        FETCH c_tank_usage_col INTO lv_col;
                        IF c_tank_usage_col%NOTFOUND THEN

                          lv_sql := lv_sql || ')';

                          EXIT;
                        END IF;
                      END LOOP;
                  CLOSE c_tank_usage_col;

                     lv_value := lv_value || ' FROM DV_TANK_USAGE WHERE TANK_ID='''|| p_ori_id ||''' AND OBJECT_CODE='''|| lv_code ||''' AND DAYTIME>=to_date('''||to_char(p_daytime,'yyyy-mm-dd')||''',''yyyy-mm-dd''))';

                     lv_sql := lv_sql || lv_value;

                     lv_result := executeStatement(lv_sql);

                     IF lv_result IS NOT NULL THEN
                        RAISE_APPLICATION_ERROR(-20000,'Fail to copy new TANK_USAGE');
                     END IF;
          END LOOP;

END TankObject;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getObjName
-- Description    : Get Object Name for Well, Stream, Tank, External Location
--
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration  :
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

FUNCTION getObjName(
  p_object_id VARCHAR2,
  p_object_type VARCHAR2,
  p_daytime DATE
)
RETURN VARCHAR2
--</EC-DOC>

IS

	lv2_return_val VARCHAR2(1000);

BEGIN

	IF p_object_type = 'WELL' THEN
		lv2_return_val := ec_well_version.name(p_object_id, p_daytime, '<=');
	ELSIF p_object_type = 'STREAM' THEN
		lv2_return_val := ec_strm_version.name(p_object_id, p_daytime, '<=');
	ELSIF p_object_type = 'TANK' THEN
		lv2_return_val := ec_tank_version.name(p_object_id, p_daytime, '<=');
	ELSIF p_object_type = 'EXTERNAL_LOCATION' THEN
		lv2_return_val := ec_ext_location_version.name(p_object_id, p_daytime, '<=');
	ELSIF p_object_type = 'FCTY_CLASS_1' THEN
		lv2_return_val := ec_fcty_version.name(p_object_id, p_daytime, '<=');
	END IF;

	RETURN lv2_return_val;

END getObjName;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : copyNewRecord
-- Description    : This is to copy the selected records with the same object_id and daytime.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : well_seasonal_value, STREAM_SEASONAL_VALUE
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : -
--
---------------------------------------------------------------------------------------------------
PROCEDURE copyNewRecord(p_object_id VARCHAR2, p_daytime DATE, p_valid_from DATE, p_todate DATE)
--</EC-DOC>
IS

  CURSOR c_well_seasonal(cp_object_id VARCHAR2, cp_daytime DATE) IS
    SELECT *
    FROM well_seasonal_value w
    WHERE w.object_id = cp_object_id
       AND w.daytime = cp_daytime;

  CURSOR c_strm_seasonal(cp_object_id VARCHAR2, cp_daytime DATE) IS
    SELECT *
    FROM STREAM_SEASONAL_VALUE s
    WHERE s.object_id = cp_object_id
       AND s.daytime = cp_daytime;

  TYPE t_well_seasonal IS TABLE OF WELL_SEASONAL_VALUE%ROWTYPE;
    l_well_seasonal t_well_seasonal;

  TYPE t_strm_seasonal IS TABLE OF STREAM_SEASONAL_VALUE%ROWTYPE;
    l_strm_seasonal t_strm_seasonal;

  ln_exist_well NUMBER;
  ln_exist_strm NUMBER;

BEGIN

  IF (p_object_id is null) THEN
      RAISE_APPLICATION_ERROR (-20697, 'No row is being selected');
  END IF;

  IF ecdp_month_lock.withinLockedMonth(p_todate) IS NOT NULL THEN
      EcDp_Month_lock.raiseValidationError('INSERTING', p_todate, p_todate, trunc(p_todate,'MONTH'), 'Cannot insert record in a locked month');
  END IF;

  EcDp_Month_Lock.localLockCheck('withinLockedMonth', p_object_id,
                        p_todate, p_todate,
                        'INSERTING', 'EcBp_Object_Class.CopyObject: Cannot insert record in a locked local month.');

  SELECT COUNT(*) INTO ln_exist_well FROM well_seasonal_value WHERE object_id = p_object_id AND daytime = p_daytime;

  SELECT COUNT(*) INTO ln_exist_strm FROM stream_seasonal_value WHERE object_id = p_object_id AND daytime = p_daytime;

  IF ln_exist_well > 0 THEN
      OPEN c_well_seasonal(p_object_id, p_daytime);
      LOOP
      FETCH c_well_seasonal BULK COLLECT INTO l_well_seasonal LIMIT 2000;

      FOR i IN 1..l_well_seasonal.COUNT LOOP
        l_well_seasonal(i).daytime := p_todate;
      END LOOP;

      FORALL i IN 1..l_well_seasonal.COUNT
        INSERT INTO well_seasonal_value VALUES l_well_seasonal(i);

      EXIT WHEN c_well_seasonal%NOTFOUND;

      END LOOP;
      CLOSE c_well_seasonal;

  ELSIF ln_exist_strm > 0 THEN
      OPEN c_strm_seasonal(p_object_id, p_daytime);
      LOOP
      FETCH c_strm_seasonal BULK COLLECT INTO l_strm_seasonal LIMIT 2000;

      FOR i IN 1..l_strm_seasonal.COUNT LOOP
        l_strm_seasonal(i).daytime := p_todate;
      END LOOP;

      FORALL i IN 1..l_strm_seasonal.COUNT
        INSERT INTO stream_seasonal_value VALUES l_strm_seasonal(i);

      EXIT WHEN c_strm_seasonal%NOTFOUND;

      END LOOP;
      CLOSE c_strm_seasonal;

  ELSE
    RAISE_APPLICATION_ERROR(-20000, 'Cannot copy record.');
  END IF;

END copyNewRecord;

END EcBp_Object_Class;