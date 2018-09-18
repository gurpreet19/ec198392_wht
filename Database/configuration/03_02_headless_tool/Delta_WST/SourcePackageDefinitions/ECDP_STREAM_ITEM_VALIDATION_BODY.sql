CREATE OR REPLACE PACKAGE BODY EcDp_Stream_Item_Validation IS
/****************************************************************
** Package        :  EcDp_Stream_Item_Validation, body part
**
** $Revision: 1.4 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created  : 27.07.2008  EnergyX Team
**
** Modification history:
**
** Date         Whom  Change description:
** ------       ----- --------------------------------------
** 27.01.2008   sra   Initial version on 9.3
*****************************************************************************************/

PROCEDURE RunValidation(
  p_type VARCHAR2,
  p_daytime DATE,
  p_check_group VARCHAR2,
  p_user VARCHAR2
  )
IS

lv2_class_name VARCHAR2(240);

CURSOR c_log IS
SELECT ccl.*
FROM ctrl_check_log ccl
WHERE daytime = p_daytime
AND ccl.class_name = 'STREAM_ITEM';

lv2_object_id VARCHAR2(32);
lv2_code VARCHAR2(32) := 'NA';
lv2_description VARCHAR2(240) := 'NA';
lv2_comments VARCHAR2(2000) := 'NA';
ln_sort_order NUMBER := 10;
ln_counter NUMBER;

BEGIN

    IF (p_type = 'MONTHLY_VALIDATION') THEN
        lv2_code := to_char(p_daytime, 'YYYY') || '-' || to_char(p_daytime, 'MM');
        lv2_description := to_char(p_daytime, 'YYYY') || '-' || to_char(p_daytime, 'MM') || ' Validation list';
        lv2_class_name := 'STREAM_ITEM';

        -- Flush old validation
        DELETE FROM ctrl_check_log ccl WHERE ccl.daytime = p_daytime AND ccl.check_group = p_check_group;

        -- Run the monthly check
        Pck_Gen_Check.run_check_all(p_daytime, p_daytime, lv2_class_name, NULL);

        lv2_comments := 'Last Run Time: ' || to_char(Ecdp_Timestamp.getCurrentSysdate, 'DD.MM.YYYY HH24:MI:SS') || ' ';

        SELECT count(*) INTO ln_counter FROM ctrl_check_log ccl WHERE ccl.daytime = p_daytime AND ccl.check_group = p_check_group
            AND ccl.severity_level = 'ERROR';
        lv2_comments := lv2_comments || ' Errors: ' || ln_counter;
        SELECT count(*) INTO ln_counter FROM ctrl_check_log ccl WHERE ccl.daytime = p_daytime
            AND ccl.severity_level = 'WARNING';
        lv2_comments := lv2_comments || ' Warnings: ' || ln_counter;
        SELECT count(*) INTO ln_counter FROM ctrl_check_log ccl WHERE ccl.daytime = p_daytime
            AND ccl.severity_level = 'INFORMATION';
        lv2_comments := lv2_comments || ' Information: ' || ln_counter;

    END IF;

    IF (p_type = 'DAILY_VALIDATION') THEN
        lv2_code := to_char(p_daytime, 'YYYY') || '-' || to_char(p_daytime, 'MM') || '-' || to_char(p_daytime, 'DD');
        lv2_description := to_char(p_daytime, 'YYYY') || '-' || to_char(p_daytime, 'MM') || '-' || to_char(p_daytime, 'DD') || ' Validation list';
        lv2_class_name := 'STREAM_ITEM';

        -- Flush old validation
        DELETE FROM ctrl_check_log ccl WHERE ccl.daytime = p_daytime AND ccl.check_group = p_check_group;

        -- Run the daily check
        Pck_Gen_Check.run_check_all(p_daytime, p_daytime, lv2_class_name, NULL);

        lv2_comments := 'Last Run Time: ' || to_char(Ecdp_Timestamp.getCurrentSysdate, 'DD.MM.YYYY HH24:MI:SS') || ' ';

        SELECT count(*) INTO ln_counter FROM ctrl_check_log ccl WHERE ccl.daytime = p_daytime AND ccl.check_group = p_check_group
            AND ccl.severity_level = 'ERROR';
        lv2_comments := lv2_comments || ' Errors: ' || ln_counter;
        SELECT count(*) INTO ln_counter FROM ctrl_check_log ccl WHERE ccl.daytime = p_daytime
            AND ccl.severity_level = 'WARNING';
        lv2_comments := lv2_comments || ' Warnings: ' || ln_counter;
        SELECT count(*) INTO ln_counter FROM ctrl_check_log ccl WHERE ccl.daytime = p_daytime
            AND ccl.severity_level = 'INFORMATION';
        lv2_comments := lv2_comments || ' Information: ' || ln_counter;

    END IF;


    -- Try and find whether there are an existing list in the system
    lv2_object_id := ec_stream_item_collection.object_id_by_uk(lv2_code);

    IF (lv2_object_id IS NULL) THEN
        -- New List

        -- Insert the List object itself
        INSERT INTO stream_item_collection sic (object_code, start_date, description, created_by)
        VALUES (lv2_code, p_daytime, lv2_description, p_user)
        RETURNING object_id INTO lv2_object_id;

        -- Insert the List object version
        INSERT INTO stim_collection_version scv (object_id, daytime, name, category, comments, created_by)
        VALUES (lv2_object_id, p_daytime, lv2_description, p_type, lv2_comments, p_user);

    ELSE
        -- Existing List, delete "old" members

        DELETE FROM stim_collection_setup WHERE object_id = lv2_object_id;

        -- Update with new comments
        UPDATE stim_collection_version SET comments = lv2_comments
        WHERE object_id = lv2_object_id;

    END IF;

    -- Populate the list with stream items
    FOR CurLog IN c_log LOOP
        BEGIN
            INSERT INTO stim_collection_setup scs (object_id, stream_item_id, daytime, reporting_ind, sort_order, created_by)
            VALUES (lv2_object_id, CurLog.Object_Id, p_daytime, 'N', ln_sort_order, p_user);

            ln_sort_order := ln_sort_order + 10;
        EXCEPTION -- Allow same stream item to be inserted
            WHEN OTHERS THEN
                NULL;
        END;
    END LOOP; -- CurLog

END RunValidation;

PROCEDURE DeleteValidationLists(
  p_daytime DATE
  )
IS

CURSOR c_lists IS
SELECT scv.object_id
FROM stim_collection_version scv
WHERE scv.category IN ('DAILY_VALIDATION','MONTHLY_VALIDATION')
AND scv.daytime <= p_daytime;

TYPE t_objects IS TABLE OF VARCHAR2(32);

ltab_objects t_objects := t_objects();

BEGIN


    -- Find all lists to be deleted
    FOR curLists IN c_lists LOOP

        ltab_objects.extend;
        ltab_objects(ltab_objects.last) := curLists.Object_Id;

    END LOOP;

    FOR i IN 1..ltab_objects.count LOOP
        -- Delete connected stream items
        DELETE FROM stim_collection_setup scs WHERE
        scs.daytime <= p_daytime
        AND scs.object_id = ltab_objects(i);

        -- Delete from version table
        DELETE FROM stim_collection_version scv
        WHERE object_id = ltab_objects(i);

        -- Delete from version table
        DELETE FROM stream_item_collection sic
        WHERE object_id = ltab_objects(i);

    END LOOP;

    ltab_objects.delete;

END DeleteValidationLists;

END EcDp_Stream_Item_Validation;