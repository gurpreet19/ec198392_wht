CREATE OR REPLACE PACKAGE BODY EcDp_change_logging IS
/****************************************************************
** Package        :  EcDp_FindRelatedClasses, body part
**
** $Revision: 1.3 $
**
** Purpose        :  Provide special functions on Financials Periods
**
** Documentation  :  www.energy-components.com
**
** Created  : 21.12.2007
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
*****************************************************************/

PROCEDURE AddClassChanges(
    p_class_name          VARCHAR,
    p_object_id           VARCHAR2,
    p_row_id              VARCHAR2,
    p_attribute           VARCHAR2,
    p_old_value           VARCHAR2,
    p_new_value           VARCHAR2,
    p_last_updated_by     VARCHAR2,
    p_last_updated_date   DATE,
    p_rev_no              VARCHAR2,
    p_rev_text            VARCHAR2,
    p_rec_id              VARCHAR2
)
IS

BEGIN

   IF p_class_name IS NOT NULL THEN

     p_tab.extend;
     p_tab(p_tab.last).class_name := p_class_name;
     p_tab(p_tab.last).object_id := p_object_id;
     p_tab(p_tab.last).row_id := p_row_id;
     p_tab(p_tab.last).attribute := p_attribute;
     p_tab(p_tab.last).old_value := p_old_value;
     p_tab(p_tab.last).new_value := p_new_value;
     p_tab(p_tab.last).last_updated_by := p_last_updated_by;
     p_tab(p_tab.last).last_updated_date := p_last_updated_date;
     p_tab(p_tab.last).rev_no := p_rev_no;
     p_tab(p_tab.last).rev_text := p_rev_text;
     p_tab(p_tab.last).rec_id := p_rec_id;


   END IF;

END;



FUNCTION getlogging(
           p_classlist  VARCHAR2,
           p_from_date  DATE,
           p_to_date    DATE,
           p_user_id    VARCHAR2 DEFAULT NULL
)
RETURN t_logging_tab PIPELINED
IS

  lrec t_logging_rec;
  lv2_remaining_classlist VARCHAR2(32000);
  ln_position NUMBER;
  lv2_class VARCHAR2(100);
  lv2_sql VARCHAR2(32000);
  ln_limit NUMBER := 3000;  -- Fallback limit in case entry in ctrl_system attribute is removed;
  lv2_user VARCHAR2(100);

  CURSOR c_class(cp_class VARCHAR2) IS
  SELECT class_name FROM class_cnfg
  WHERE class_name LIKE cp_class;

  CURSOR c_system_attribute IS
  SELECT attribute_value
  FROM ctrl_system_attribute
  WHERE attribute_type = 'MASTER_DATA_REPORT_LIMIT';


BEGIN

    p_tab := t_logging_tab();

    FOR climit IN c_system_attribute LOOP
      ln_limit := climit.attribute_value;
    END LOOP;

    IF p_user_id IS NOT NULL THEN

      lv2_user := ''''||p_user_id||'''';

    ELSE

      lv2_user := 'NULL';

    END IF;



    lv2_remaining_classlist := p_classlist;

    WHILE Nvl(LENGTH(lv2_remaining_classlist),0) > 0 LOOP

       ln_position := INSTR(lv2_remaining_classlist,',');
       IF ln_position = 0 THEN
         ln_position := INSTR(lv2_remaining_classlist,';');
       END IF;

       IF ln_position = 0 THEN
         ln_position := LENGTH(lv2_remaining_classlist)+1;
       END IF;

       lv2_class := SUBSTR(lv2_remaining_classlist,1,ln_position-1);
       lv2_remaining_classlist := SUBSTR(lv2_remaining_classlist,ln_position+1);


       lv2_class := UPPER(REPLACE(lv2_class,'''',''));

       --ecdp_dynsql.WriteTempText('EC4E_DEBUG', 'Class: '||lv2_class||' Remaining class list: '||lv2_remaining_classlist);


       FOR curClass IN c_class(lv2_class) LOOP

       --  ecdp_dynsql.WriteTempText('EC4E_DEBUG', 'Processing Class: '||curClass.class_Name);

         IF p_tab.count < ln_limit THEN

            lv2_sql := 'BEGIN EC4E_'||curClass.class_Name||'.findClassChanges('||ecdp_dynsql.date_to_string(p_from_date)||','||ecdp_dynsql.date_to_string(p_to_date)||','||lv2_user||'); END;';

            ecdp_dynsql.WriteTempText('EC4E_DEBUG', 'Trying to run: '||lv2_sql);

            EXECUTE IMMEDIATE lv2_sql;

         END IF;

       END LOOP;

    END LOOP;


    FOR i IN 1..p_tab.count LOOP

       IF i < ln_limit THEN
         lrec.class_name := p_tab(i).class_name;
         lrec.object_id := p_tab(i).object_id;
         lrec.row_id := p_tab(i).row_id;
         lrec.attribute := p_tab(i).attribute;
         lrec.old_value := p_tab(i).old_value;
         lrec.new_value := p_tab(i).new_value;
         lrec.last_updated_by := p_tab(i).last_updated_by;
         lrec.last_updated_date := p_tab(i).last_updated_date;
         lrec.rev_no := p_tab(i).rev_no;
         lrec.rev_text := p_tab(i).rev_text;
         lrec.rec_id := p_tab(i).rec_id;
       ELSE
         EXIT;
       END IF;

        PIPE ROW ( lrec );
    END LOOP;

    IF p_tab.count >  ln_limit THEN
        lrec.class_name := 'Maximum row limit reached';
        lrec.object_id := NULL;
        lrec.row_id := NULL;
        lrec.attribute := NULL;
        lrec.old_value := NULL;
        lrec.new_value := NULL;
        lrec.last_updated_by := NULL;
        lrec.last_updated_date := NULL;
        lrec.rev_no := NULL;
        lrec.rev_text := NULL;
        lrec.rec_id := NULL;
        PIPE ROW ( lrec );
    END IF;

    RETURN;
END getlogging;


END EcDp_change_logging;