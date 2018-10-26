CREATE OR REPLACE PACKAGE BODY EcDp_Maintain_Mappings_update IS
/***********************************************************************
** Package            :  EcDp_Maintain_Mappings_update, body part
**
** $Revision: 1.0 $
**
** Purpose            :  Provide function to do bulk update on many mapping tags
**
**
** Documentation  :  www.energy-components.com
**
** Created  : 04.04.2017  Semere Ghebregiorgish
**
** Modification history:
**
** Version  Date        Whom  Change description:
** -------  ------      ----- --------------------------------------
** 1.0      04.04.2017  SVN   Initial version
***************************************************************************/


    -----------------------------------------------------------------------
    -- Does the bulk update of a selected tags
    ----+----------------------------------+-------------------------------
    FUNCTION DoBulkUpdate(
        p_last_transfer_string               VARCHAR2 DEFAULT NULL,
        p_from_date_string                   VARCHAR2 DEFAULT NULL,
        p_to_date_string                     VARCHAR2 DEFAULT NULL,
        p_active                             VARCHAR2 DEFAULT NULL,
        p_tag_id                             VARCHAR2 DEFAULT NULL,
        p_source_id                          VARCHAR2 DEFAULT NULL,
        p_attribute                          VARCHAR2 DEFAULT NULL,
        p_data_class                         VARCHAR2 DEFAULT NULL,
        p_object_id                          VARCHAR2 DEFAULT NULL,
        p_template_code                      VARCHAR2 DEFAULT NULL,
        p_tag_status                         VARCHAR2 DEFAULT NULL
        )
    RETURN VARCHAR2

    IS

      CURSOR c_selected_tags
        IS
          SELECT MAPPING_NO FROM TV_MAPPINGS_TRANS_CONFIG WHERE
           nvl(TAG_ID, 'X') LIKE nvl2(TRIM(p_tag_id), '%' || p_tag_id || '%', nvl(TAG_ID, 'X'))
           AND nvl(SOURCE_ID, 'X') = nvl2(TRIM(p_source_id), p_source_id, nvl(SOURCE_ID, 'X'))
           AND nvl(ATTRIBUTE, 'X') = nvl2(TRIM(p_attribute), p_attribute, nvl(ATTRIBUTE, 'X'))
           AND nvl(DATA_CLASS, 'X') = nvl2(TRIM(p_data_class), p_data_class, nvl(DATA_CLASS, 'X'))
           AND nvl(PK_VAL_1, 'X') = nvl2(TRIM(p_object_id), p_object_id, nvl(PK_VAL_1, 'X'))
           AND nvl(TEMPLATE_CODE, 'X') = nvl2(TRIM(p_template_code), p_template_code, nvl(TEMPLATE_CODE, 'X'))
           AND nvl(ACTIVE, 'X') = nvl2(TRIM(p_tag_status), p_tag_status, nvl(ACTIVE, 'X')) order by ATTRIBUTE ASC;

        ld_last_transfer                   DATE;
        ld_from_date                       DATE;
        ld_to_date                         DATE;
        ln_item_count                      NUMBER := 0;
        lv_end_user_message                VARCHAR2(240);
        ex_validation_error                EXCEPTION;
    BEGIN


        -- Checking mandatory parameters
        IF (p_last_transfer_string IS NULL AND p_from_date_string IS NULL AND p_to_date_string IS NULL AND p_active IS NULL ) THEN
            lv_end_user_message := 'Error!' || chr(10) || 'There is no new values to update!';
        END IF;

        ld_last_transfer := to_date(p_last_transfer_string, 'yyyy-MM-dd"T"hh24:mi:ss');
        ld_from_date := to_date(p_from_date_string, 'yyyy-MM-dd"T"hh24:mi:ss');
        ld_to_date := to_date(p_to_date_string, 'yyyy-MM-dd"T"hh24:mi:ss');

         IF (ld_from_date > ld_to_date ) THEN
            lv_end_user_message := 'Error!' || chr(10) || 'From_time cannot be after To_time!';
        END IF;

        IF lv_end_user_message IS NOT NULL THEN
            RETURN lv_end_user_message;
        END IF;

        FOR i_items IN c_selected_tags
        LOOP
            ln_item_count := ln_item_count + 1;

            update V_TRANS_CONFIG
              set LAST_TRANSFER = NVL(ld_last_transfer,LAST_TRANSFER),
                  FROM_TIME = NVL(ld_from_date, FROM_TIME),
                  TO_TIME = NVL(ld_to_date,TO_TIME),
                  ACTIVE = NVL(p_active, ACTIVE)
            where mapping_no = i_items.mapping_no;
        END LOOP;

        IF ln_item_count = 0 THEN
            lv_end_user_message := 'Warning!' || chr(10) || 'No tags to update';
            RETURN lv_end_user_message;
        END IF;

        lv_end_user_message := 'Success!' || chr(10) ||  ln_item_count || ' tags are updated';
        RETURN lv_end_user_message;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, SQLERRM || '\n\n' || 'Technical:\n');
    END DoBulkUpdate;

END EcDp_Maintain_Mappings_update;