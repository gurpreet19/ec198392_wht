CREATE OR REPLACE PACKAGE BODY EcDp_Financial_Item IS
  /****************************************************************
  ** Package        :  EcDp_Financial_Item, body part
  *****************************************************************/

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : checkDatasetRules
  -- Description    : Checks all the rules for the dataset.
  --
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   : Financial_Item_setup , financial_item,fin_item_entry
  --
  --
  --
  -- Using functions:
  --
  -- Configuration
  -- required       :
  --
  -- Behavior       :
  --
  ---------------------------------------------------------------------------------------------------
  PROCEDURE checkDatasetRules(p_fin_item_id VARCHAR2,
                              p_dataset     VARCHAR2,
                              p_end_date    DATE,
                              p_daytime     DATE)
  --</EC-DOC>
   IS

    lv_end_date       DATE;
    lv_start_date     DATE;
    lv2_result        varchar2(10) := 'false';
    ln_counter_update number := 0;
    ln_counter_insert number := 0;

    CURSOR c_fin_item IS
      SELECT * FROM financial_item WHERE object_id = p_fin_item_id;

    CURSOR c_daytime_end_date IS
      SELECT DAYTIME, END_DATE
        FROM tv_financial_item_setup A
       WHERE A.fin_item_id = p_fin_item_id
         AND A.dataset = p_dataset;

  BEGIN

    FOR cur_fin_item IN c_fin_item LOOP
      lv_end_date   := cur_fin_item.end_date;
      lv_start_date := cur_fin_item.start_date;

      IF p_end_date < lv_start_date THEN
        Raise_Application_Error(-20000,
                                'The start date of the financial item is later than the end date of the dataset.\n\n');
      END IF;
      IF p_end_date > lv_end_date THEN
        Raise_Application_Error(-20000,
                                'The end date of the financial item is earlier than the end date of the dataset.\n\n');
      END IF;
      IF p_daytime > lv_end_date THEN
        Raise_Application_Error(-20000,
                                'The end date of the financial item is earlier than the daytime of the dataset.\n\n');
      END IF;
      IF p_daytime < lv_start_date THEN
        Raise_Application_Error(-20000,
                                'The start date of the financial item is earlier than the daytime of the dataset.\n\n');
      END IF;

    END LOOP;

    FOR rs IN c_daytime_end_date LOOP
      IF ((p_daytime between rs.daytime AND
         nvl(rs.end_date - 1,
               CASE
                 WHEN p_daytime > rs.daytime then
                  p_daytime + 1
                 else
                  rs.daytime + 1
               END)) OR (p_end_date between rs.daytime + 1 AND
         nvl(rs.end_date - 1,
                              nvl(p_end_date,
                                  CASE
                                    WHEN p_daytime > rs.daytime then
                                     p_daytime + 1
                                    else
                                     rs.daytime + 1
                                  END))) OR
         (p_daytime < rs.daytime AND
         nvl(p_end_date, rs.daytime + 1) > rs.daytime)) THEN

        lv2_result := 'true';

      END IF;
    END LOOP;

    IF lv2_result = 'true' THEN
      RAISE_APPLICATION_ERROR(-20000,
                              'Dataset overlaps with an existing period. \n\n');
    END IF;

  END checkDatasetRules;
  ---------------------------------------------------------------------------------------------------

  ---------------------------------------------------------------------------------------------------
  PROCEDURE checkDatasetOverlapping(p_fin_item_id VARCHAR2,
                                    p_dataset     VARCHAR2,
                                    p_end_date    DATE,
                                    p_daytime     DATE)
  --</EC-DOC>
   IS

    lv2_result                  varchar2(10) := 'false';
    lv_end_date                 DATE;
    lv_start_date               DATE;
    CURSOR c_cnt IS
      SELECT count(*) as cnt
        FROM tv_financial_item_setup A
       WHERE A.fin_item_id = p_fin_item_id
         AND A.dataset = p_dataset;

    CURSOR c_overlapping_date IS
      SELECT DAYTIME, END_DATE
        FROM tv_financial_item_setup A
       WHERE A.fin_item_id = p_fin_item_id
         AND A.dataset = p_dataset
       order by daytime;

      CURSOR c_fin_item IS
      SELECT * FROM financial_item WHERE object_id = p_fin_item_id;

  BEGIN
    FOR ls IN c_cnt LOOP
      IF (ls.cnt > 1) THEN
        FOR rs IN c_overlapping_date LOOP

          IF (nvl(p_end_date, p_daytime) between rs.daytime + 1 and
             nvl(rs.end_date - 1, nvl(p_end_date, p_daytime + 1))) then
            lv2_result := 'true';
          END IF;
          IF ((nvl(p_end_date,to_date('1999-01-01','YYYY-MM-DD')) = nvl(rs.end_date,to_date('1999-01-01','YYYY-MM-DD'))) and
             (p_daytime <> rs.daytime))
             then
            lv2_result := 'true';
          END IF;
          IF (( p_daytime < rs.daytime ) and ((nvl(p_end_date,to_date('2999-01-01','YYYY-MM-DD'))) > rs.daytime) )then
            lv2_result := 'true';
          END IF;
          IF (((p_daytime) > rs.daytime) and (p_daytime < nvl(rs.end_date,to_date('2999-01-01','YYYY-MM-DD'))))then
            lv2_result := 'true';
          END IF;

        END LOOP;

        IF lv2_result = 'true' THEN
          RAISE_APPLICATION_ERROR(-20000,'Dataset overlaps with an existing period \n\n');
        END IF;
      END IF;
    END LOOP;

    FOR cur_fin_item IN c_fin_item LOOP
      lv_end_date   := cur_fin_item.end_date;
      lv_start_date := cur_fin_item.start_date;

      IF p_end_date < lv_start_date THEN
        Raise_Application_Error(-20000,
                                'The start date of the financial item is later than the end date of the dataset.\n\n');
      END IF;
      IF p_end_date > lv_end_date THEN
        Raise_Application_Error(-20000,
                                'The end date of the financial item is earlier than the end date of the dataset.\n\n');
      END IF;
      IF p_daytime > lv_end_date THEN
        Raise_Application_Error(-20000,
                                'The end date of the financial item is earlier than the daytime of the dataset.\n\n');
      END IF;
      IF p_daytime < lv_start_date THEN
        Raise_Application_Error(-20000,
                                'The start date of the financial item is earlier than the daytime of the dataset.\n\n');
      END IF;

   END LOOP;
  END checkDatasetOverlapping;
  ----------------------------------------------------------------------------------------------------

  ---------------------------------------------------------------------------------------------------

  PROCEDURE copyFITemplate(p_template_code     VARCHAR2,
                           p_new_template_code VARCHAR2,
                           p_new_template_name VARCHAR2,
                           p_valid_from        DATE,
                           p_valid_to          DATE DEFAULT NULL,
                           p_contract_area_id  VARCHAR2,
                           p_user              VARCHAR2 DEFAULT NULL) IS
  BEGIN
    -- create contract_template
    INSERT INTO DV_FINANCIAL_ITEM_TEMPLATE
      (template_code,
       name,
       daytime,
       end_date,
       contract_area_id,
       created_by)
    VALUES
      (p_new_template_code,
       p_new_template_name,
       p_valid_from,
       p_valid_to,
       p_contract_area_id,
       p_user);

    --create attributes
    INSERT into dv_fin_item_templ_attr
      (template_code,
       fin_item_id,
       daytime,
       unit_type,
       dataset,
       dataset_priority,
       unit,
       fin_item_name,
       object_link_id,
       object_link_type,
       cost_object_id,
       cost_object_type,
       company_id,
       fin_acct_id,
       sort_order,
       data_fallback_method,
       format_mask,
       comments,
       created_by)
      SELECT p_new_template_code,
             t.FIN_ITEM_ID,
             p_valid_from,
             t.unit_type,
             t.dataset,
             t.dataset_priority,
             t.unit,
             t.fin_item_name,
             t.object_link_id,
             t.object_link_type,
             t.cost_object_id,
             t.cost_object_type,
             t.company_id,
             t.fin_acct_id,
             t.sort_order,
             t.data_fallback_method,
             t.format_mask,
             t.comments,
             p_user
        FROM dv_fin_item_templ_attr t , ov_financial_item o
       WHERE t.template_code = p_template_code
         AND t.fin_item_id = o.object_id
         AND nvl(o.end_date , p_valid_from +1) >= p_valid_from
         AND o.daytime <=  p_valid_from ;

  END copyFITemplate;

  ----------------------------------------------------------------------------------------------------
  -- Function       : CopyTemplateWithoutValue
  -- Description    : Copy Monthly Values for Selected template into current month.
  -------------------------------------------------------------------------------------------------

  FUNCTION CopyTemplateWithoutValue(p_template_code VARCHAR2,
                                    p_from_date     DATE,
                                    p_time_span     VARCHAR2) RETURN VARCHAR2

   IS

    CURSOR c_temp_attr IS
      SELECT t.*
        FROM dv_fin_item_templ_attr t , ov_financial_item o
       WHERE t.template_code = p_template_code
         AND t.fin_item_id = o.object_id
         AND nvl(o.end_date , p_from_date +1) > p_from_date
         AND o.daytime <=  p_from_date ;


    CURSOR c_fin_item_entry(c_time_span      varchar2,
                            c_daytime        date,
                            c_template_code  varchar2,
                            c_fin_item_id    varchar2,
                            c_dataset        varchar2,
                            c_unit           varchar2,
                            c_company_id     varchar2,
                            c_fin_acct_id    varchar2,
                            c_cost_object_id varchar2,
                            c_object_link_id varchar2) IS
    SELECT count(*) as cnt
      FROM dv_fin_item_entry
     WHERE DAYTIME = c_daytime
       AND TIME_SPAN = c_time_span
       AND FIN_ITEM_ID = c_fin_item_id
       AND nvl(DATASET, 'X') = nvl(c_dataset, 'X')
       AND nvl(COMPANY_ID, 'X') = nvl(c_company_id, 'X')
       AND nvl(OBJECT_LINK_ID, 'X') = nvl(c_object_link_id, 'X');

    lv_row_cnt number := 0;
    lv_user_feedback VARCHAR2(32) :='' ;
    lv2_user_feedback VARCHAR2(32) :='' ;
    lv3_user_feedback VARCHAR2(32) :='' ;
    lv_template_entries_cnt number := 0;
    lv_rows_not_inserted number := 0;

  BEGIN

    IF p_template_code = '' or p_template_code IS NULL THEN
      RETURN 'Warning!' || '\n' ||'Please select a template.';
    END IF;

      SELECT COUNT(*) INTO lv_template_entries_cnt
        FROM dv_fin_item_templ_attr t , ov_financial_item o
       WHERE t.template_code = p_template_code
         AND t.fin_item_id = o.object_id
         AND nvl(o.end_date , p_from_date +1) > p_from_date
         AND o.daytime <=  p_from_date ;

    FOR I IN c_temp_attr LOOP
        FOR c_list in c_fin_item_entry(p_time_span,
                                     p_from_date,
                                     i.template_code,
                                     i.fin_item_id,
                                     i.dataset,
                                     i.unit,
                                     i.company_id,
                                     i.fin_acct_id,
                                     i.cost_object_id,
                                     i.object_link_id) LOOP

             IF (c_list.cnt < 1) THEN
                lv_row_cnt := lv_row_cnt + 1;
                INSERT INTO dv_fin_item_entry
                (COST_OBJECT_TYPE,
                 DAYTIME,
                 FIN_ITEM_ID,
                 FIN_ITEM_NAME,
                 SORT_ORDER,
                 DATASET,
                 OBJECT_LINK_ID,
                 OBJECT_LINK_TYPE,
                 COST_OBJECT_ID,
                 UNIT,
                 DATASET_PRIORITY,
                 DATA_FALLBACK_METHOD,
                 TEMPLATE_CODE,
                 FIN_ACCT_ID,
                 COMPANY_ID,
                 COMMENTS,
                 UNIT_TYPE,
                 TIME_SPAN)
            VALUES
                (i.COST_OBJECT_TYPE,
                 p_from_date,
                 i.FIN_ITEM_ID,
                 i.FIN_ITEM_NAME,
                 i.SORT_ORDER,
                 i.DATASET,
                 i.OBJECT_LINK_ID,
                 i.OBJECT_LINK_TYPE,
                 i.COST_OBJECT_ID,
                 i.UNIT,
                 i.DATASET_PRIORITY,
                 i.DATA_FALLBACK_METHOD,
                 i.TEMPLATE_CODE,
                 i.FIN_ACCT_ID,
                 i.COMPANY_ID,
                 i.COMMENTS,
                 i.UNIT_TYPE,
                 p_time_span);
            END IF;
        END LOOP;
    END LOOP;

    IF SQL%ROWCOUNT > 0 THEN

        IF(lv_row_cnt = 1) THEN
            lv_user_feedback := ' entry was ';
        ELSE
            lv_user_feedback := ' entries were ';
        END IF;

        lv_rows_not_inserted  := lv_template_entries_cnt - lv_row_cnt ;

        IF(lv_rows_not_inserted = 1) THEN
            lv2_user_feedback := ' entry was ';
        ELSE
            lv2_user_feedback := ' entries were ';
        END IF;


        IF(lv_template_entries_cnt = 1) THEN
            lv3_user_feedback := ' entry. ';
        ELSE
            lv3_user_feedback := ' entries. ';
        END IF;


        IF(lv_rows_not_inserted = 0) THEN

            RETURN 'Success!' || '\n' || 'Selected Financial Item Template has ' || lv_template_entries_cnt || lv3_user_feedback || lv_row_cnt || lv_user_feedback ||'inserted successfully. ' ;

        ELSE

            RETURN 'Success!' || '\n' || 'Selected Financial Item Template has ' || lv_template_entries_cnt || lv3_user_feedback || lv_row_cnt || lv_user_feedback ||'inserted successfully. ' || lv_rows_not_inserted ||lv2_user_feedback ||'not inserted from Financial Item Template as same entries already exist.' ;

        END IF;

    END IF;


    IF lv_row_cnt = 0 THEN

        RETURN 'No new entries are inserted from template as same entries already exist.';

    END IF;

    RETURN NULL;

  END CopyTemplateWithoutValue;

  ----------------------------------------------------------------------------------------------------
  -- Function       : CopyUseMonthValue
  -- Description    : Copy Monthly values for month selected into current month
  -------------------------------------------------------------------------------------------------
  FUNCTION CopyUseMonthValue(p_template_code VARCHAR2,
                             p_copy_date     DATE,
                             p_from_date     DATE,
                             p_time_span     VARCHAR2) RETURN VARCHAR2

   IS

    CURSOR c_temp_attribute IS

    SELECT t.*
      FROM dv_fin_item_templ_attr t , ov_financial_item o
       WHERE t.template_code = p_template_code
         AND t.fin_item_id = o.object_id
         AND nvl(o.end_date , p_from_date +1) > p_from_date
         AND o.daytime <=  p_from_date ;

    CURSOR c_fin_item_entry(c_time_span      varchar2,
                            c_daytime        date,
                            c_template_code  varchar2,
                            c_fin_item_id    varchar2,
                            c_dataset        varchar2,
                            c_unit           varchar2,
                            c_company_id     varchar2,
                            c_fin_acct_id    varchar2,
                            c_cost_object_id varchar2,
                            c_object_link_id varchar2) IS
    SELECT count(*) as cnt
      FROM dv_fin_item_entry
     WHERE DAYTIME = c_daytime
       AND TIME_SPAN = c_time_span
       AND FIN_ITEM_ID = c_fin_item_id
       AND nvl(DATASET, 'X') = nvl(c_dataset, 'X')
       AND nvl(COMPANY_ID, 'X') = nvl(c_company_id, 'X')
       AND nvl(OBJECT_LINK_ID, 'X') = nvl(c_object_link_id, 'X');

    CURSOR c_fin_item_entry_copy(c1_time_span      varchar2,
                            c1_copy_time        date,
                            c1_template_code  varchar2,
                            c1_fin_item_id    varchar2,
                            c1_dataset        varchar2,
                            c1_unit           varchar2,
                            c1_company_id     varchar2,
                            c1_fin_acct_id    varchar2,
                            c1_cost_object_id varchar2,
                            c1_object_link_id varchar2) IS
      SELECT value_override , value_calculated , value_interfaced , value_result, derived
        FROM dv_fin_item_entry
       WHERE DAYTIME = c1_copy_time
         AND TIME_SPAN = c1_time_span
         AND FIN_ITEM_ID = c1_fin_item_id
         AND nvl(DATASET, 'X') = nvl(c1_dataset, 'X')
         AND nvl(COMPANY_ID, 'X') = nvl(c1_company_id, 'X')
         AND nvl(OBJECT_LINK_ID, 'X') = nvl(c1_object_link_id, 'X');

    lv_row_cnt number := 0;
    lv_user_feedback VARCHAR2(32) :='' ;
    lv2_user_feedback VARCHAR2(32) :='' ;
    lv3_user_feedback VARCHAR2(32) :='' ;
    lv4_user_feedback VARCHAR2(32) :='' ;
    lv_template_entries_cnt number := 0;
    lv_rows_not_inserted number := 0;
    lv_rows_updated number := 0;

  BEGIN

    IF p_template_code = '' or p_template_code IS NULL THEN
        RETURN 'Warning!' || '\n' ||'Please select a template.';
    END IF;
    IF p_copy_date = '' or p_copy_date IS NULL THEN
        RETURN 'Warning!' || '\n' ||'Please fill in a date before clicking this button.';
    END IF;
    SELECT COUNT(*) INTO lv_template_entries_cnt
      FROM dv_fin_item_templ_attr t , ov_financial_item o
       WHERE t.template_code = p_template_code
         AND t.fin_item_id = o.object_id
         AND nvl(o.end_date , p_from_date +1) >= p_from_date
         AND o.daytime <=  p_from_date ;

    FOR I IN c_temp_attribute LOOP
        FOR c_list in c_fin_item_entry(p_time_span,
                                     p_from_date,
                                     i.template_code,
                                     i.fin_item_id,
                                     i.dataset,
                                     i.unit,
                                     i.company_id,
                                     i.fin_acct_id,
                                     i.cost_object_id,
                                     i.object_link_id) LOOP

             IF (c_list.cnt < 1) THEN
                 lv_row_cnt := lv_row_cnt + 1;
                 INSERT INTO dv_fin_item_entry
                 (COST_OBJECT_TYPE,
                  DAYTIME,
                  FIN_ITEM_ID,
                  FIN_ITEM_NAME,
                  SORT_ORDER,
                  DATASET,
                  OBJECT_LINK_ID,
                  OBJECT_LINK_TYPE,
                  COST_OBJECT_ID,
                  UNIT,
                  DATASET_PRIORITY,
                  DATA_FALLBACK_METHOD,
                  TEMPLATE_CODE,
                  FIN_ACCT_ID,
                  COMPANY_ID,
                  COMMENTS,
                  UNIT_TYPE,
                  TIME_SPAN,
                  FORMAT_MASK)
             VALUES
                 (i.COST_OBJECT_TYPE,
                  p_from_date,
                  i.FIN_ITEM_ID,
                  i.FIN_ITEM_NAME,
                  i.SORT_ORDER,
                  i.DATASET,
                  i.OBJECT_LINK_ID,
                  i.OBJECT_LINK_TYPE,
                  i.COST_OBJECT_ID,
                  i.UNIT,
                  i.DATASET_PRIORITY,
                  i.DATA_FALLBACK_METHOD,
                  i.TEMPLATE_CODE,
                  i.FIN_ACCT_ID,
                  i.COMPANY_ID,
                  i.COMMENTS,
                  i.UNIT_TYPE,
                  p_time_span,
                  i.format_mask);


                      FOR c_list_copy in c_fin_item_entry_copy(p_time_span,
                                     p_copy_date,
                                     i.template_code,
                                     i.fin_item_id,
                                     i.dataset,
                                     i.unit,
                                     i.company_id,
                                     i.fin_acct_id,
                                     i.cost_object_id,
                                     i.object_link_id) LOOP
                                 IF(    c_list_copy.value_override IS NOT NULL or  c_list_copy.value_override != ''
                                     or c_list_copy.value_interfaced IS NOT NULL or c_list_copy.value_interfaced !=''
                                     or
                                     c_list_copy.value_calculated IS NOT NULL  or c_list_copy.value_calculated !='' ) THEN

                                         lv_rows_updated := lv_rows_updated+1;
                                            UPDATE dv_fin_item_entry SET value_override = c_list_copy.value_override ,
                                                   value_interfaced = c_list_copy.value_interfaced,
                                                   value_calculated = c_list_copy.value_calculated,
                                                   derived = c_list_copy.derived
                                            WHERE DAYTIME = p_from_date
                                              AND TIME_SPAN = p_time_span
                                              AND FIN_ITEM_ID = i.fin_item_id
                                              AND nvl(DATASET, 'X') = nvl(i.dataset, 'X')
                                              AND nvl(COMPANY_ID, 'X') = nvl(i.company_id, 'X')
                                              AND nvl(OBJECT_LINK_ID, 'X') = nvl(i.object_link_id, 'X');

                                END IF;
                      END LOOP;
               END IF;

        END LOOP;

    END LOOP;

    IF SQL%ROWCOUNT > 0 THEN

        IF(lv_row_cnt = 1) THEN
            lv_user_feedback := ' entry was ';
        ELSE
            lv_user_feedback := ' entries were ';
        END IF;

    lv_rows_not_inserted  := lv_template_entries_cnt - lv_row_cnt ;

    IF(lv_rows_not_inserted = 1) THEN
        lv2_user_feedback := ' entry was ';
    ELSE
        lv2_user_feedback := ' entries were ';
    END IF;

    IF(lv_template_entries_cnt = 1) THEN
        lv3_user_feedback := ' entry. ';
    ELSE
        lv3_user_feedback := ' entries. ';
    END IF;

    IF(lv_rows_updated = 1 and lv_row_cnt = 1)  THEN
        lv4_user_feedback := ' row was updated. ';
    END IF;
    IF(lv_rows_updated = 1 and lv_row_cnt >1) THEN
        lv4_user_feedback := ' rows was updated. ';
    ELSE
        lv4_user_feedback := ' rows were updated. ';
    END IF;



    IF(lv_rows_not_inserted = 0) THEN
         IF( lv_rows_updated = 0 AND  lv_row_cnt = 0) THEN
             RETURN 'Success!' || '\n' || 'Selected Financial Item Template has ' || lv_template_entries_cnt || lv3_user_feedback || lv_row_cnt ||
             lv_user_feedback ||'inserted successfully. No rows were updated with values.' ;
         ELSE
             RETURN 'Success!' || '\n' || 'Selected Financial Item Template has ' || lv_template_entries_cnt || lv3_user_feedback || lv_row_cnt ||
             lv_user_feedback ||'inserted successfully. '|| lv_rows_updated || ' out of ' || lv_row_cnt || lv4_user_feedback ;
         END IF;

    ELSE
         IF( lv_rows_updated = 0 AND  lv_row_cnt = 0) THEN
             RETURN 'Success!' || '\n' || 'Selected Financial Item Template has ' || lv_template_entries_cnt || lv3_user_feedback || lv_row_cnt ||
              lv_user_feedback ||'inserted successfully. ' || lv_rows_not_inserted ||lv2_user_feedback
              ||'not inserted from Financial Item Template as same entries already exist. No rows were updated with values.' ;
         ELSE

             RETURN 'Success!' || '\n' || 'Selected Financial Item Template has ' || lv_template_entries_cnt || lv3_user_feedback || lv_row_cnt ||
              lv_user_feedback ||'inserted successfully. ' || lv_rows_not_inserted ||lv2_user_feedback
              ||'not inserted from Financial Item Template as same entries already exist. ' || lv_rows_updated || ' out of ' || lv_row_cnt || lv4_user_feedback ;
         END IF;

    END IF;

    END IF;

    IF lv_row_cnt = 0 THEN

      RETURN 'No new entries are inserted from template as same entries already exist';

    END IF;

    RETURN NULL;


  END CopyUseMonthValue;

  /********************** COMMENTING AS THIS BUTTON IS COMMENTED ON SCREEN************************---------

  -- Function       : CopyUseMonthValue
  -- Description    : Copy Monthly values for month selected into current month
  ---------------------------------------------------------------------------------------------------------
  FUNCTION CopyValueSelectedItems(P_month DATE, p_from_date DATE)
    RETURN VARCHAR2

   IS

    CURSOR c_selected_item IS

      SELECT a.VALUE_INTERFACED,
             a.VALUE_CALCULATED,
             a.VALUE_OVERRIDE,
             a.FIN_ITEM_ID
        FROM dv_fin_item_entry_mth a, dv_fin_item_entry_mth b
       WHERE TO_CHAR(a.DAYTIME, 'MMYY') = TO_CHAR(P_month, 'MMYY')
         AND  b.SELECTED_IND = 'Y'
         AND a.FIN_item_id = b.FIN_item_id;

  BEGIN

    FOR I IN c_selected_item

     LOOP

      UPDATE dv_fin_item_entry_mth
         SET VALUE_INTERFACED = i.VALUE_INTERFACED,
             VALUE_CALCULATED = i.VALUE_CALCULATED,
             VALUE_OVERRIDE   = i.VALUE_OVERRIDE
       WHERE
       SELECTED_IND = 'Y' and
       daytime = p_from_date
       AND FIN_ITEM_ID = i.FIN_ITEM_ID;

    END LOOP;

    IF SQL%ROWCOUNT > 0 THEN

      RETURN 'Success!';

    END IF;
    RETURN NULL;

  END CopyValueSelectedItems;

  ---------------------------------------------------------------------------------------------------*/
  ---------------------------------------------------------------------------------------------------

  PROCEDURE copyFIDefinition(p_code             VARCHAR2,
                             p_object_id        VARCHAR2,
                             p_new_code         VARCHAR2,
                             p_new_name         VARCHAR2,
                             p_valid_from       DATE,
                             p_valid_to         DATE DEFAULT NULL,
                             p_user             VARCHAR2 DEFAULT NULL,
                             p_contract_area_id VARCHAR2 DEFAULT NULL)

   IS

    ln_counter       number := 0;
    ln_new_object_id varchar2(32) := null;

    CURSOR cur_ver IS

      SELECT p_valid_from            as daytime,
             p_valid_to              as end_date,
             p_new_name              as name,
             fi.description          as description,
             fi.comments             as comments,
             fi.item_type            as item_type,
             fi.unit_type            as unit_type,
             fi.unit                 as unit,
             fi.object_link_id       as object_link_id,
             fi.object_link_type     as object_link_type,
             fi.cost_object_type     as cost_object_type,
             fi.format_mask          as format_mask,
             fi.data_fallback_method as data_fallback_method,
             p_user                  as user_id
        FROM financial_item_version fi
       WHERE fi.object_id = p_object_id
       order by fi.daytime;

    CURSOR cur_dataset IS
      SELECT *
        FROM financial_item_setup fi_set_up
       WHERE fi_set_up.fin_item_id = p_object_id;
  BEGIN

    FOR cur_res IN cur_ver LOOP

      --create Fin Item version /* only one version is created*/
      IF (ln_counter < 1) THEN
        INSERT into ov_financial_item
          (code,
           object_start_date,
           object_end_date,
           daytime,
           name,
           description,
           comments,
           item_type,
           unit_type,
           unit,
           object_link_id,
           object_link_type,
           cost_object_type,
           format_mask,
           data_fallback_method,
           contract_area_id,
           created_by)
        values
          (p_new_code,
           p_valid_from,
           p_valid_to,
           cur_res.daytime,
           cur_res.name,
           cur_res.description,
           cur_res.comments,
           cur_res.item_type,
           cur_res.unit_type,
           cur_res.unit,
           cur_res.object_link_id,
           cur_res.object_link_type,
           cur_res.cost_object_type,
           cur_res.format_mask,
           cur_res.data_fallback_method,
           p_contract_area_id,
           cur_res.user_id);
        ln_counter := ln_counter + 1;
      END IF;
      select object_id
        into ln_new_object_id
        from ov_financial_item
       where code = p_new_code;
    END LOOP;

    FOR cur_ds IN cur_dataset LOOP
      INSERT into financial_item_setup
        (fin_item_id,
         dataset,
         daytime,
         end_date,
         priority,
         comments,
         created_by)
      values
        (ln_new_object_id,
         cur_ds.dataset,
         cur_ds.daytime,
         cur_ds.end_date,
         cur_ds.priority,
         cur_ds.comments,
         p_user);
    END LOOP;

  END copyFIDefinition;
  --------------------------------------------------------------------------------------------------

  /***************COMMENTING AS CODE CALLING HIS FUNCTION IS COMMENTED ON SCREEN ****************************

  PROCEDURE copyFIItem(p_item_name          VARCHAR2,
                       p_financial_item_key VARCHAR2,
                       P_DAYTIME            DATE,
                       p_new_template_code  VARCHAR2,
                       p_new_template_name  VARCHAR2,
                       p_user               VARCHAR2 DEFAULT NULL) is

    cursor c1 is
      select * from dv_fin_item_entry_mth;
    --where selected_ind = 'Y';
  BEGIN

    INSERT INTO DV_FINANCIAL_ITEM_TEMPLATE
      (template_code, name, daytime, created_by)
    VALUES
      (p_new_template_code, p_new_template_name, P_DAYTIME, p_user);

    FOR i in c1 loop
      INSERT into dv_fin_item_entry_mth
        (template_code,
         daytime,
         dataset,
         dataset_priority,
         fin_item_type,
         unit,
         fin_item_name,
         object_link_id,
         object_link_type,
         cost_object_id,
         cost_object_type,
         sort_order,
         created_by,
         status)
      values
        (p_new_template_code,
         i.daytime,
         i.dataset,
         i.dataset_priority,
         i.fin_item_type,
         i.unit,
         i.fin_item_name,
         i.object_link_id,
         i.object_link_type,
         i.cost_object_id,
         i.cost_object_type,
         i.sort_order,
         p_user,
         i.status);

    END LOOP;

    FOR j IN c1 LOOP
      INSERT into dv_fin_item_templ_attr
        (template_code,
         daytime,
         dataset,
         dataset_priority,
         unit,
         fin_item_name,
         object_link_id,
         object_link_type,
         cost_object_id,
         cost_object_type,
         sort_order,
         created_by)
      values
        (p_new_template_code,
         j.daytime,
         j.dataset,
         j.dataset_priority,
         j.unit,
         j.fin_item_name,
         j.object_link_id,
         j.object_link_type,
         j.cost_object_id,
         j.cost_object_type,
         j.sort_order,
         p_user);

    end loop;

    -- update dv_fin_item_entry_mth set selected_ind = 'N' ;
    --where selected_ind = 'Y';

  end copyFIItem;

  --------------------------------------------------------------------------------------------*/

  /***************COMMENTING AS CODE CALLING HIS FUNCTION IS COMMENTED ON SCREEN ****************************

  PROCEDURE updateFITemplate(p_financial_item_key VARCHAR2,
                             P_DAYTIME            DATE,
                             p_template_code      VARCHAR2,
                             p_user               VARCHAR2 DEFAULT NULL)

   IS

    CURSOR c1 is

      SELECT * FROM dv_fin_item_entry_mth; -- WHERE selected_ind = 'Y';

  BEGIN

    for i in c1 loop
      INSERT into dv_fin_item_entry_mth
        (template_code,
         daytime,
         dataset,
         dataset_priority,
         fin_item_type,
         unit,
         fin_item_name,
         object_link_id,
         object_link_type,
         cost_object_id,
         cost_object_type,
         sort_order,
         created_by,
         status)
      values
        (p_template_code,
         i.daytime,
         i.dataset,
         i.dataset_priority,
         i.fin_item_type,
         i.unit,
         i.fin_item_name,
         i.object_link_id,
         i.object_link_type,
         i.cost_object_id,
         i.cost_object_type,
         i.sort_order,
         p_user,
         i.status);

    end loop;

    for i in c1 loop
      INSERT into dv_fin_item_templ_attr
        (template_code,
         daytime,
         dataset,
         dataset_priority,
         unit,
         fin_item_name,
         object_link_id,
         object_link_type,
         cost_object_id,
         cost_object_type,
         sort_order,
         created_by)
      values
        (p_template_code,
         i.daytime,
         i.dataset,
         i.dataset_priority,
         i.unit,
         i.fin_item_name,
         i.object_link_id,
         i.object_link_type,
         i.cost_object_id,
         i.cost_object_type,
         i.sort_order,
         p_user);

    end loop;

      update dv_fin_item_entry_mth set selected_ind = 'N' where selected_ind = 'Y';

  end updateFITemplate;*/

  -------------------------------------------------------------------------------------------------
  -- Function       : getFinancialItemTemplateName
  -- Description    : Returns the name of the Financial Item Template.
  -------------------------------------------------------------------------------------------------
  FUNCTION getFinancialItemTemplateName(p_template_code VARCHAR2,
                                        p_daytime       DATE)
    RETURN FINANCIAL_ITEM_TEMPLATE.NAME%TYPE IS
    CURSOR c_col_val IS
      SELECT name col
        FROM FINANCIAL_ITEM_TEMPLATE
       WHERE template_code = p_template_code
         AND p_daytime >= daytime
         AND p_daytime < nvl(end_date, p_daytime + 1);

    v_return_val FINANCIAL_ITEM_TEMPLATE.NAME%TYPE;
  BEGIN
    FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
    END LOOP;
    RETURN v_return_val;
  END getFinancialItemTemplateName;

  -------------------------------------------------------------------------------------------------
  -- Function       : getUnitName
  -- Description    : Returns the name of the unit.
  -------------------------------------------------------------------------------------------------
  FUNCTION getUnitName(p_unit VARCHAR2, p_daytime DATE) RETURN VARCHAR2 IS
    CURSOR c_curr_unit(c_curr_unit_id VARCHAR2, c_daytime DATE) IS
      SELECT *
        FROM v_curr_unit
       WHERE curr_unit_id = c_curr_unit_id
         AND c_daytime >= daytime
         AND c_daytime < nvl(end_date, c_daytime + 1);

    lv_unit_name VARCHAR2(240);
  BEGIN
    FOR c_rec IN c_curr_unit(p_unit, p_daytime) LOOP
      lv_unit_name := c_rec.name;
    END LOOP;

    RETURN lv_unit_name;
  END getUnitName;

  FUNCTION ExtractDelimitedAltcode(p_code      IN VARCHAR2,
                                   p_code_type IN VARCHAR2,
                                   p_delimiter varchar2,
                                   p_value     number) RETURN VARCHAR IS
    p_extracted_val VARCHAR2(100);

  BEGIN
    SELECT regexp_substr(alt_code, '[^' || p_delimiter || ']+', 1, p_value)
      INTO p_extracted_val
      FROM prosty_codes
     WHERE code_type = p_code_type
       AND code = p_code;

    RETURN p_extracted_val;
  END ExtractDelimitedAltcode;

  -------------------------------------------------------------------------------------------------
  -- Function       : GetLastGeneratedTemplate
  -- Description    : Returns the last generated template code
  -------------------------------------------------------------------------------------------------
  FUNCTION GetLastGeneratedTemplate(p_user_id VARCHAR2) RETURN VARCHAR2 IS
    CURSOR c_last_template_code(cp_user_id VARCHAR2) IS
      SELECT template_code
        FROM (SELECT template_code
                FROM dv_financial_item_template
               where created_by = cp_user_id
               ORDER BY created_date DESC)
       WHERE rownum <= 1;

    lv_last_template_code VARCHAR2(32) := '';
  BEGIN
    FOR cur IN c_last_template_code(p_user_id) LOOP
      lv_last_template_code := cur.template_code;
    END LOOP;

    RETURN lv_last_template_code;
  EXCEPTION
    WHEN OTHERS THEN
      Raise_Application_Error(-20000, SQLERRM || '\n\n' || 'Technical:\n');
  END GetLastGeneratedTemplate;

  -------------------------------------------------------------------------------------------------
  -- Function       : GetValueByPriority
  -- Description    : Returns the result value based on data fallback method
  -------------------------------------------------------------------------------------------------
  FUNCTION GetValueByPriority(value_calculated     NUMBER,
                              value_interfaced     NUMBER,
                              value_override       NUMBER,
                              data_fallback_method VARCHAR2) RETURN NUMBER IS

    lv_result_value NUMBER := 0;
  BEGIN
    IF data_fallback_method = 'OVERRIDDEN_CALCULATED_INTERFACED' or
       data_fallback_method IS NULL THEN
      lv_result_value := nvl(value_override, value_calculated);
      IF (lv_result_value is NULL or lv_result_value = '') THEN
        lv_result_value := value_interfaced;
      END IF;
    END IF;
    IF data_fallback_method = 'OVERRIDDEN_INTERFACED_CALCULATED' THEN
      lv_result_value := nvl(value_override, value_interfaced);
      IF (lv_result_value is NULL or lv_result_value = '') THEN
        lv_result_value := value_calculated;
      END IF;
    END IF;

    RETURN lv_result_value;
  EXCEPTION
    WHEN OTHERS THEN
      Raise_Application_Error(-20000, SQLERRM || '\n\n' || 'Technical:\n');
  END GetValueByPriority;

  -------------------------------------------------------------------------------------------------
  -- Function       : monthValue
  -- Description    : Returns the date format based  on time_span
  -------------------------------------------------------------------------------------------------

  FUNCTION monthValue(p_time_span VARCHAR2, p_nav_date DATE) RETURN varchar2 IS
  BEGIN
    IF p_time_span = 'DAY' THEN
      RETURN to_char(p_nav_date - 1, 'RRRR-MM-dd"T"hh24:mi:ss');
    ELSIF p_time_span = 'MTH' THEN
      RETURN to_char(add_months(p_nav_date, -1), 'RRRR-MM-dd"T"hh24:mi:ss');
    ELSIF p_time_span = 'YR' THEN
      RETURN to_char(add_months(p_nav_date,-12),'RRRR-MM-dd"T"hh24:mi:ss');
    ELSE
      RETURN to_char(p_nav_date, 'RRRR-MM-dd"T"hh24:mi:ss');
    END IF;
  END monthValue;

 -------------------------------------------------------------------------------------------------
  -- Function       : getDatasetCodeText
  -- Description    : Returns the code text of EC Code of FI DATASET.
  -------------------------------------------------------------------------------------------------
  FUNCTION getDatasetCodeText(p_dataset VARCHAR2) RETURN VARCHAR2 IS
    lv_code_text prosty_codes.code_text%TYPE;
  BEGIN
     SELECT code_text
       INTO lv_code_text
       FROM v_fi_dataset_value
      WHERE dataset_value = p_dataset;
    RETURN lv_code_text;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      lv_code_text := INITCAP(p_dataset);
      RETURN lv_code_text;
  END getDatasetCodeText;

  -------------------------------------------------------------------------------------------------
  -- Function       : getDatasetValueHide
  -- Description    : Returns string true or false to suggest whether to hide the dataset value
  --                  of the dataset column on dataset matrix tab on screen.
  -------------------------------------------------------------------------------------------------
  FUNCTION getDatasetValueHide(p_daytime          DATE,
                               p_timespan         VARCHAR2,
                               p_col              NUMBER,
                               p_dataset_code     VARCHAR2,
                               p_fin_template     VARCHAR2,
                               p_fin_item_name    VARCHAR2,
                               p_cost_object      VARCHAR2,
                               p_cost_object_type VARCHAR2,
                               p_object_link      VARCHAR2,
                               p_object_link_type VARCHAR2,
                               p_company          VARCHAR2,
                               p_comments         VARCHAR2,
                               p_business_unit_id VARCHAR2,
                               p_contract_area_id VARCHAR2,
                               p_status           VARCHAR2)
  RETURN VARCHAR2 IS
    lv_val_hide VARCHAR2(10);
  BEGIN
    SELECT CASE WHEN ((p_col = 1 AND ecdp_financial_item.getDatasetFilter(p_col, p_dataset_code) = 'TRUE') OR
                      (p_col = 2 AND ecdp_financial_item.getDatasetFilter(p_col, p_dataset_code) = 'TRUE') OR
                      (p_col = 3 AND ecdp_financial_item.getDatasetFilter(p_col, p_dataset_code) = 'TRUE') OR
                      (p_col = 4 AND ecdp_financial_item.getDatasetFilter(p_col, p_dataset_code) = 'TRUE') OR
                      (p_col = 5 AND ecdp_financial_item.getDatasetFilter(p_col, p_dataset_code) = 'TRUE') OR
                      (p_col = 6 AND ecdp_financial_item.getDatasetFilter(p_col, p_dataset_code) = 'TRUE') OR
                      (p_col = 7 AND ecdp_financial_item.getDatasetFilter(p_col, p_dataset_code) = 'TRUE') OR
                      (p_col = 8 AND ecdp_financial_item.getDatasetFilter(p_col, p_dataset_code) = 'TRUE') OR
                      (p_col = 9 AND ecdp_financial_item.getDatasetFilter(p_col, p_dataset_code) = 'TRUE') OR
                      (p_col = 10 AND ecdp_financial_item.getDatasetFilter(p_col, p_dataset_code) = 'TRUE')
                      )
                THEN 'false'
                ELSE 'true' END dataset_val_hide
      INTO lv_val_hide
      FROM dual
      WHERE EXISTS (  SELECT DISTINCT v.dataset_value
                        FROM dv_fin_item_entry dv,
                             v_fi_dataset_value v
                       WHERE dv.daytime = p_daytime
                         AND dv.time_span = p_timespan
                         AND ecdp_revn_common.Equals(p_fin_template, ec_financial_item_template.name(dv.template_code, dv.daytime,'<='),'Y') ='Y'
                         AND ecdp_revn_common.Equals(p_fin_item_name, dv.fin_item_name, 'Y') = 'Y'
                         AND ecdp_revn_common.Equals(p_cost_object, ecdp_objects.getObjName(dv.cost_object_id, dv.daytime) ,'Y') = 'Y'
                         AND ecdp_revn_common.Equals(p_cost_object_type, dv.cost_object_type, 'Y') = 'Y'
                         AND ecdp_revn_common.Equals(p_object_link_type, dv.object_link_type, 'Y') = 'Y'
                         AND ecdp_revn_common.Equals(p_object_link, ecdp_objects.getObjName(dv.object_link_id, dv.daytime) , 'Y') = 'Y'
                         AND (ecdp_revn_common.Equals(p_business_unit_id, Ec_Contract_Area_Version.business_unit_id(dv.contract_area_id, dv.daytime, '<='), 'Y') = 'Y' OR Ec_Contract_Area_Version.business_unit_id(dv.contract_area_id, dv.daytime, '<=') IS NULL )
                         AND (ecdp_revn_common.Equals(p_contract_area_id, dv.contract_area_id, 'Y') = 'Y' OR dv.contract_area_id IS NULL )
                         AND ecdp_revn_common.Equals(p_company, ecdp_objects.getObjName(dv.company_id, dv.daytime) , 'Y') = 'Y'
                         AND ecdp_revn_common.Equals(p_comments, dv.comments, 'Y') = 'Y'
                         AND ecdp_revn_common.Equals(ec_prosty_codes.code_text(p_status, 'RECORD_STATUS'), status, 'Y') = 'Y'
                         AND dv.dataset = v.code
                         AND TO_NUMBER(SUBSTR(V.dataset_value, 15, 2)) = p_col ) ;

    RETURN lv_val_hide;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 'true';
  END getDatasetValueHide;

  -------------------------------------------------------------------------------------------------
  -- Function       : getDatasetFilter
  -- Description    : Returns true or false to identify whether filter is applied to a specific
  --                  dataset on screen
  -------------------------------------------------------------------------------------------------
  FUNCTION getDatasetFilter(p_col NUMBER,
                            p_dataset_code VARCHAR2) RETURN VARCHAR2 IS
    lv_return NUMBER(1);
  BEGIN

    SELECT 1
      INTO lv_return
      FROM v_fi_dataset_value
      WHERE (code = NVL(p_dataset_code,code) AND NVL(TO_NUMBER(SUBSTR(dataset_value, 15, 2)),p_col) = p_col);

    IF SQL%FOUND THEN
      RETURN 'TRUE';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'FALSE';

  END getDatasetFilter;

END EcDp_Financial_Item;