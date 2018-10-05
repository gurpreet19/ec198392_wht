CREATE OR REPLACE PACKAGE BODY EcDp_Object_List_Setup IS

    -----------------------------------------------------------------------
    -- Returns the number of selected rows from the source object_list_setup
    ----+----------------------------------+-------------------------------
    FUNCTION GetObjectListItemCount_P(
        p_source_generic_class_name        VARCHAR2,
        p_source_object_list_id            VARCHAR2,
        p_user_id                          VARCHAR2
        )
    RETURN NUMBER
    IS
        CURSOR c_selected_object_list_item(
            cp_generic_class_name          VARCHAR2,
            cp_object_list_id              VARCHAR2,
            cp_user_id                     VARCHAR2)
        IS
        select count(*) as item_count
        from object_list_setup
        where generic_class_name = cp_generic_class_name
        and object_id = cp_object_list_id
        and nvl(selected_by_user_id,'NULL') = cp_user_id;

        ln_item_count                      NUMBER := 0;
    BEGIN
        FOR curItem IN c_selected_object_list_item(p_source_generic_class_name,p_source_object_list_id, p_user_id) LOOP
            ln_item_count := curItem.item_count;
        END loop;

        RETURN ln_item_count;
    END GetObjectListItemCount_P;

    -----------------------------------------------------------------------
    -- To make sure that object_id and name does match.
    -- This is needed because the target object_id received from app can
    -- be invalid.
    ----+----------------------------------+-------------------------------
    FUNCTION GetTargetObjectID(
        p_target_object_list_id            VARCHAR2 DEFAULT NULL,
        p_target_object_list_name          VARCHAR2 DEFAULT NULL
        )
    RETURN VARCHAR2
    IS
        CURSOR c_object_list(
            cp_object_id                   VARCHAR2,
            cp_name                        VARCHAR2)
        IS
        select object_id
        from ov_object_list
        where object_id = cp_object_id
        and name = cp_name;

        lv_object_id                       VARCHAR2(32);
    BEGIN
        -- Check if id and name does match
        FOR curItem IN c_object_list(p_target_object_list_id,p_target_object_list_name) LOOP
            lv_object_id := curItem.object_id;
        END loop;

        -- If no match so far, try to look it up by code
        IF lv_object_id IS NULL THEN
            lv_object_id := EcDp_Objects.GetObjIDFromCode('OBJECT_LIST',p_target_object_list_name);
        END IF;

        RETURN nvl(lv_object_id,'NULL');
    END GetTargetObjectID;

    -----------------------------------------------------------------------
    -- Validating the "Open Target List" attributes.
    ----+----------------------------------+-------------------------------
    FUNCTION ValidateOpenTargetListArgs(
        p_target_daytime_string            VARCHAR2 DEFAULT NULL,
        p_target_object_list_name          VARCHAR2 DEFAULT NULL
        )
    RETURN VARCHAR2
    IS
        lv_end_user_message                VARCHAR2(240);
        ex_validation_error                EXCEPTION;
    BEGIN
        IF (p_target_daytime_string IS NULL OR p_target_daytime_string = 'null') THEN
            lv_end_user_message := 'Error!' || chr(10) || 'Not possible to open the target list. ''Target Daytime'' is missing!';
        ELSIF (p_target_object_list_name IS NULL OR p_target_object_list_name = 'null') THEN
            lv_end_user_message := 'Error!' || chr(10) || 'Not possible to open the target list. ''Target Object List'' is missing!';
        END IF;
        IF lv_end_user_message IS NOT NULL THEN
            RAISE ex_validation_error;
        END IF;

        RETURN NULL;
    EXCEPTION
        WHEN ex_validation_error THEN
            RETURN lv_end_user_message;
    END ValidateOpenTargetListArgs;

    -----------------------------------------------------------------------
    -- To check if items exists in the target with the selected date
    ----+----------------------------------+-------------------------------
    FUNCTION GetCountOfItemsInTarget_P(
        p_user_id                          VARCHAR2,
        p_source_generic_class_name        VARCHAR2,
        p_source_object_list_id            VARCHAR2,
        p_target_object_list_id            VARCHAR2,
        p_target_daytime                   DATE
        )
    RETURN NUMBER
    IS
        CURSOR c_item_count
        IS
        select count(trg.generic_object_code) as item_count
        from OBJECT_LIST_SETUP trg
        where trg.generic_class_name = p_source_generic_class_name
        and trg.object_id = p_target_object_list_id
        and trg.daytime = p_target_daytime
        and trg.generic_object_code in (
            select src.generic_object_code
            from OBJECT_LIST_SETUP src
            where src.generic_class_name = trg.generic_class_name
            and src.object_id = p_source_object_list_id
            and selected_by_user_id = p_user_id
        );

        ln_item_count                      NUMBER := 0;
    BEGIN
        FOR curItem IN c_item_count() LOOP
            ln_item_count := curItem.item_count;
        END loop;

        RETURN ln_item_count;
    END GetCountOfItemsInTarget_P;

    -----------------------------------------------------------------------
    -- Executes the copy from source to target object list.
    ----+----------------------------------+-------------------------------
    FUNCTION CopyListItems_P(p_user_id                   VARCHAR2,
                             p_source_generic_class_name VARCHAR2,
                             p_source_object_list_id     VARCHAR2,
                             p_target_daytime            DATE,
                             p_target_object_list_id     VARCHAR2,
                             p_delete_from_currrent_ind  VARCHAR2)

     RETURN NUMBER
    IS
        CURSOR c_source_items
        IS
        select * from object_list_setup
        where generic_class_name = p_source_generic_class_name
        and object_id = p_source_object_list_id
        and selected_by_user_id = p_user_id;

        CURSOR c_target_items(
            cp_generic_object_code         VARCHAR2)
        IS
        select * from object_list_setup
        where generic_class_name = p_source_generic_class_name
        and object_id = p_target_object_list_id
        and generic_object_code = cp_generic_object_code
        order by daytime;

        ld_target_end_date                 DATE;
        ln_item_count                      NUMBER := 0;
    BEGIN
        FOR curSrc IN c_source_items() LOOP
            -- Need check for previous and next versions to set end_date correct
            FOR curTrg IN c_target_items(curSrc.generic_object_code) LOOP
                IF curTrg.daytime < p_target_daytime AND nvl(curTrg.end_date,p_target_daytime+1) >= p_target_daytime THEN
                    -- Keep current end date, if set
                    IF curTrg.end_date IS NOT NULL THEN
                        ld_target_end_date := curTrg.end_date;
                    END IF;

                    update object_list_setup
                    set end_date = p_target_daytime
                    where object_id = curTrg.object_id
                    and generic_object_code = curTrg.generic_object_code
                    and daytime = curTrg.daytime
                    and gen_rel_obj_code = curTrg.gen_rel_obj_code;
                END IF;

                IF curTrg.daytime > p_target_daytime AND ld_target_end_date IS NULL THEN
                    ld_target_end_date := curTrg.daytime;
                END IF;
            END LOOP;

            insert into object_list_setup (
                object_id,           --key
                generic_object_code, --key
                generic_class_name,
                relational_obj_code,
                relation_class,
                daytime,             --key
                end_date,
                split_share,
                sort_order,
                gen_rel_obj_code,    --key
                comments,
                value_1,
                value_2,
                value_3,
                value_4,
                value_5,
                value_6,
                value_7,
                value_8,
                value_9,
                value_10,
                text_1,
                text_2,
                text_3,
                text_4,
                date_1,
                date_2,
                date_3,
                date_4,
                date_5,
                obj_id,
                created_by)
            values (
                p_target_object_list_id,
                curSrc.GENERIC_OBJECT_CODE,
                curSrc.GENERIC_CLASS_NAME,
                curSrc.RELATIONAL_OBJ_CODE,
                curSrc.RELATION_CLASS,
                p_target_daytime,
                ld_target_end_date,
                curSrc.SPLIT_SHARE,
                curSrc.SORT_ORDER,
                curSrc.GEN_REL_OBJ_CODE,
                curSrc.COMMENTS,
                curSrc.VALUE_1,
                curSrc.VALUE_2,
                curSrc.VALUE_3,
                curSrc.VALUE_4,
                curSrc.VALUE_5,
                curSrc.VALUE_6,
                curSrc.VALUE_7,
                curSrc.VALUE_8,
                curSrc.VALUE_9,
                curSrc.VALUE_10,
                curSrc.TEXT_1,
                curSrc.TEXT_2,
                curSrc.TEXT_3,
                curSrc.TEXT_4,
                curSrc.DATE_1,
                curSrc.DATE_2,
                curSrc.DATE_3,
                curSrc.DATE_4,
                curSrc.DATE_5,
                curSrc.OBJ_ID,
                p_user_id);

            ln_item_count := ln_item_count + 1;
        END LOOP;


        -- Deleting source items if flagged for deletion
            IF p_delete_from_currrent_ind = 'Y' THEN
              DELETE object_list_setup
              WHERE generic_class_name = p_source_generic_class_name
              AND object_id = p_source_object_list_id
              AND selected_by_user_id = p_user_id;
          END IF;



        RETURN ln_item_count;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, SQLERRM || '\n\n' || 'Technical:\n');
    END CopyListItems_P;

    -----------------------------------------------------------------------
    -- Copies items from source object list to target object list.
    ----+----------------------------------+-------------------------------
    FUNCTION CopyToTargetObjectList(
        p_user_id                          VARCHAR2,
        p_source_generic_class_name        VARCHAR2 DEFAULT NULL,
        p_source_object_list_id            VARCHAR2 DEFAULT NULL,
        p_target_daytime_string            VARCHAR2 DEFAULT NULL,
        p_target_object_list_name          VARCHAR2 DEFAULT NULL,
        p_target_object_list_id            VARCHAR2 DEFAULT NULL,
        p_delete_from_currrent_ind         VARCHAR2 DEFAULT NULL,
        p_set_end_date_currrent_ind        VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2
    IS
        lv_target_object_list_id           VARCHAR2(32);
        lv_end_user_message                VARCHAR2(240);
        lv_new_object_return_string        VARCHAR2(240);
        ln_item_count                      NUMBER := 0;
        ld_target_daytime                  DATE;
        ex_validation_error                EXCEPTION;
    BEGIN
        -- Checking mandatory parameters
        IF (p_source_generic_class_name IS NULL OR p_source_generic_class_name = 'null') THEN
            lv_end_user_message := 'Error!' || chr(10) || 'Not possible to execute. ''Source List Class'' is missing!';
        ELSIF (p_source_object_list_id IS NULL OR p_source_object_list_id = 'null') THEN
            lv_end_user_message := 'Error!' || chr(10) || 'Not possible to execute. ''Source Object List'' is missing!';
        ELSIF (p_target_daytime_string IS NULL OR p_target_daytime_string = 'null') THEN
            lv_end_user_message := 'Error!' || chr(10) || 'Not possible to execute. ''Target Daytime'' is missing!';
        ELSIF (p_target_object_list_name IS NULL OR p_target_object_list_name = 'null') THEN
            lv_end_user_message := 'Error!' || chr(10) || 'Not possible to execute. ''Target Object List'' is missing!';
        END IF;
        IF lv_end_user_message IS NOT NULL THEN
            RAISE ex_validation_error;
        END IF;
        lv_target_object_list_id := GetTargetObjectID(p_target_object_list_id, p_target_object_list_name);
        ld_target_daytime := to_date(p_target_daytime_string, 'yyyy-MM-dd"T"hh24:mi:ss');

        -- Count the number of selected items
        ln_item_count := GetObjectListItemCount_P(p_source_generic_class_name, p_source_object_list_id, p_user_id);
        IF ln_item_count = 0 THEN
            lv_end_user_message := 'Warning!' || chr(10) || 'No items are found for copying. Please select one or several items.';
            RAISE ex_validation_error;
        END IF;

        -- To create a new object list or use an existing one, that's the question...
        IF lv_target_object_list_id = 'NULL' THEN
            -- Create a new target object list
            insert into ov_object_list (code, name, object_start_date, daytime, generic_class_name)
            values (p_target_object_list_name, p_target_object_list_name, ld_target_daytime, ld_target_daytime, p_source_generic_class_name);

            lv_target_object_list_id := EcDp_Objects.GetObjIDFromCode('OBJECT_LIST',p_target_object_list_name);
            lv_new_object_return_string := 'A new target object list is created: ''' || p_target_object_list_name || '''';
        ELSE
            -- Use an existing target object list. If so, check if the target date is valid
            IF ld_target_daytime < EcDp_Objects.GetObjStartDate(lv_target_object_list_id)
            OR ld_target_daytime >= NVL(EcDp_Objects.GetObjEndDate(lv_target_object_list_id),ld_target_daytime + 1) THEN
                lv_end_user_message := 'Error!' || chr(10) || 'Not possible to execute. The Target Daytime is not valid for the selected Target Object List!' || chr(10) ||
                                       'The Target Object List is valid from ' || to_char(EcDp_Objects.GetObjStartDate(lv_target_object_list_id),'yyyy-MM-dd') || ' to ' || NVL(to_char(EcDp_Objects.GetObjEndDate(lv_target_object_list_id),'yyyy-MM-dd'),'<end date not set>');
                RAISE ex_validation_error;
            END IF;
            -- Also check that no items exists in the target with the selected date
            ln_item_count := GetCountOfItemsInTarget_P(
                p_user_id,
                p_source_generic_class_name,
                p_source_object_list_id,
                lv_target_object_list_id,
                ld_target_daytime);
            IF ln_item_count > 0 THEN
                lv_end_user_message := 'Error!' || chr(10) ||
                                       'Not possible to execute. ' ||
                                       ln_item_count || ' of the selected items does already exist in the target object list with current target daytime (' || to_char(ld_target_daytime,'yyyy-mm-dd') || ').';
                RAISE ex_validation_error;
            END IF;
        END IF;

        -- Copy to target object list
        ln_item_count := CopyListItems_P(
            p_user_id,
            p_source_generic_class_name,
            p_source_object_list_id,
            ld_target_daytime,
            lv_target_object_list_id,
            NVL(p_delete_from_currrent_ind,'N'));

        -- Worst case an update is attempted on deleted records. Should not cause any trouble.
         IF NVL(p_set_end_date_currrent_ind,'N') = 'Y' THEN
            -- Reset copy_ind on the source object list
            UPDATE object_list_setup u
               SET u.end_date = ld_target_daytime
             WHERE generic_class_name = p_source_generic_class_name
               AND object_id = p_source_object_list_id
               AND selected_by_user_id = p_user_id;

           END IF;

           -- If end_date <= daytime, record is valid in negative period => deleting
           DELETE object_list_setup ud
            WHERE ud.generic_class_name = p_source_generic_class_name
              AND ud.object_id = p_source_object_list_id
              AND ud.selected_by_user_id = p_user_id
              AND NVL(ud.end_date, ud.daytime + 1) <= ud.daytime;

            -- Reset copy_ind on the source object list
            update object_list_setup set selected_by_user_id = null
            where generic_class_name = p_source_generic_class_name
            and object_id = p_source_object_list_id
            and selected_by_user_id = p_user_id;







        -- Final feedback to user
        lv_end_user_message := 'Success!' || chr(10) ||
                               lv_new_object_return_string || case nvl(lv_new_object_return_string,'NULL') when 'NULL' then '' else chr(10) end ||
                               ln_item_count || ' ' || CASE ln_item_count WHEN 1 THEN 'item is' ELSE 'items are' END || ' copied to target object list ''' || p_target_object_list_name || '''.';
        RETURN lv_end_user_message;

    EXCEPTION
        WHEN ex_validation_error THEN
            RETURN lv_end_user_message;
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, SQLERRM || '\n\n' || 'Technical:\n');
    END CopyToTargetObjectList;

END EcDp_Object_List_Setup;