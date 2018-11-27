CREATE OR REPLACE PACKAGE BODY EcDp_BPM_EC_Event_Inbound IS

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    FUNCTION pop_pending_event(p_max_count NUMBER DEFAULT 1)
    RETURN SYS_REFCURSOR
    IS
        l_event_temp                      sys.odcinumberlist;
        l_max_count                       NUMBER;
        l_event_id                        SYS_REFCURSOR;
    BEGIN
        IF p_max_count IS NULL THEN
          l_max_count := 1;
        ELSE
          l_max_count := p_max_count;
        END IF;

        UPDATE BPM_EC_EVENT_INBOUND
        SET STATE = gv2_state_processing
        WHERE STATE = gv2_state_new
              AND id IN (
                  SELECT id FROM (SELECT id FROM BPM_EC_EVENT_INBOUND WHERE STATE = gv2_state_new ORDER BY TIME)
                  WHERE rownum <= l_max_count
              )
        RETURNING ID
        BULK COLLECT INTO l_event_temp;

        OPEN l_event_id FOR
           SELECT id FROM BPM_EC_EVENT_INBOUND
           WHERE id IN (SELECT column_value FROM TABLE(l_event_temp))
           ORDER BY TIME;

        RETURN l_event_id;
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    FUNCTION add_event (
        p_source                           VARCHAR2
       ,p_type                             NUMBER
       ,p_attributes                       IN OUT NOCOPY T_BPM_TABLE_T_EVENT_ATTRIBUTE
       )
    RETURN NUMBER
    IS
        l_dup_type_code                    VARCHAR2(32);
        l_inbound_id                       NUMBER;
    BEGIN
        IF p_type = 1 THEN
            l_dup_type_code :='GENERAL';
        ELSIF p_type = 2 THEN
            l_dup_type_code :='DATASET_SOURCE_UPDATED';
        ELSIF p_type = 3 THEN
            l_dup_type_code :='DATASET_STATE_UPDATED';
        ELSIF p_type = 4 THEN
            l_dup_type_code :='DATASET_DELETED';
        ELSIF p_type = 5 THEN
            l_dup_type_code :='DATASET_UPDATED';
        END IF;

        INSERT INTO BPM_EC_EVENT_INBOUND(SOURCE,TYPE,DUP_TYPE_CODE) VALUES (p_source,p_type,l_dup_type_code)
            RETURNING ID INTO l_inbound_id;

        IF p_attributes IS NOT NULL AND p_attributes.count > 0 THEN
            FOR i IN p_attributes.FIRST .. p_attributes.LAST LOOP
                INSERT INTO BPM_EC_EVENT_INBOUND_ATT(INBOUND_ID,ATTRIBUTE_NAME,ATTRIBUTE_VALUE) VALUES (l_inbound_id,p_attributes(i).NAME, p_attributes(i).VALUE);
            END LOOP;
        END IF;

        RETURN l_inbound_id;
   END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    FUNCTION on_generic_event (
        p_name                             VARCHAR2
       ,p_source                           VARCHAR2
       ,p_attributes                       IN OUT NOCOPY T_BPM_TABLE_T_EVENT_ATTRIBUTE
       )
    RETURN NUMBER
    IS
        l_inbound_id                       NUMBER;
    BEGIN
        INSERT INTO BPM_EC_EVENT_INBOUND(SOURCE,TYPE,DUP_TYPE_CODE) VALUES (p_source, 1, 'GENERAL')
             RETURNING ID INTO l_inbound_id;

        p_attributes.extend(1);
        p_attributes(p_attributes.LAST) := T_BPM_EVENT_ATTRIBUTE('NAME', p_name);

        FOR i IN p_attributes.FIRST .. p_attributes.LAST LOOP
          INSERT INTO BPM_EC_EVENT_INBOUND_ATT(INBOUND_ID,ATTRIBUTE_NAME,ATTRIBUTE_VALUE) VALUES (l_inbound_id, p_attributes(i).NAME, p_attributes(i).VALUE);
        END LOOP;

        RETURN l_inbound_id;
   END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    FUNCTION on_dataset_source_updated (
        p_dataset                          VARCHAR2
       ,p_dataset_type                     VARCHAR2
       ,p_source                           VARCHAR2
       ,p_source_type                      VARCHAR2
       ,p_source_id                        VARCHAR2
       ,p_source_dataset                   VARCHAR2
       ,p_source_dataset_type              VARCHAR2
     )
    RETURN NUMBER
    IS
        l_event_attribute_table            T_BPM_TABLE_T_EVENT_ATTRIBUTE;
        l_inbound_id                       NUMBER;
    BEGIN
        l_event_attribute_table := T_BPM_TABLE_T_EVENT_ATTRIBUTE();
        l_event_attribute_table.extend(6);

        l_event_attribute_table(1) := T_BPM_EVENT_ATTRIBUTE('DATASET_ID', p_dataset);
        l_event_attribute_table(2) := T_BPM_EVENT_ATTRIBUTE('DATASET_TYPE', p_dataset_type);
        l_event_attribute_table(3) := T_BPM_EVENT_ATTRIBUTE('UPDATED_SOURCE_TYPE', p_source_type);
        l_event_attribute_table(4) := T_BPM_EVENT_ATTRIBUTE('UPDATED_SOURCE_ID', p_source_id);
        l_event_attribute_table(5) := T_BPM_EVENT_ATTRIBUTE('UPDATED_SOURCE_DATASET_ID', p_source_dataset);
        l_event_attribute_table(6) := T_BPM_EVENT_ATTRIBUTE('UPDATED_SOURCE_DATASET_TYPE', p_source_dataset_type);

        l_inbound_id := add_event(p_source => p_source, p_type => 2, p_attributes => l_event_attribute_table);

        RETURN l_inbound_id;
    END;


    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    FUNCTION on_dataset_state_updated (
        p_dataset                          VARCHAR2
       ,p_dataset_type                     VARCHAR2
       ,p_old_state                        VARCHAR2
       ,p_new_state                        VARCHAR2
       ,p_source                           VARCHAR2
     )
    RETURN NUMBER
    IS
        l_event_attribute_table            T_BPM_TABLE_T_EVENT_ATTRIBUTE;
        l_inbound_id                       NUMBER;
    BEGIN
        l_event_attribute_table := T_BPM_TABLE_T_EVENT_ATTRIBUTE();
        l_event_attribute_table.extend(4);

        l_event_attribute_table(1) := T_BPM_EVENT_ATTRIBUTE('DATASET_ID', p_dataset);
        l_event_attribute_table(2) := T_BPM_EVENT_ATTRIBUTE('DATASET_TYPE', p_dataset_type);
        l_event_attribute_table(3) := T_BPM_EVENT_ATTRIBUTE('OLD_STATE', p_old_state);
        l_event_attribute_table(4) := T_BPM_EVENT_ATTRIBUTE('NEW_STATE', p_new_state);

        l_inbound_id := add_event(p_source => p_source, p_type => 3, p_attributes => l_event_attribute_table);

        RETURN l_inbound_id;
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    FUNCTION on_dataset_deleted (
        p_dataset                          VARCHAR2
       ,p_dataset_type                     VARCHAR2
       ,p_source                           VARCHAR2
     )
    RETURN NUMBER
    IS
        l_event_attribute_table            T_BPM_TABLE_T_EVENT_ATTRIBUTE;
        l_inbound_id                       NUMBER;
    BEGIN
        l_event_attribute_table := T_BPM_TABLE_T_EVENT_ATTRIBUTE();
        l_event_attribute_table.extend(2);
        l_event_attribute_table(1) := T_BPM_EVENT_ATTRIBUTE('DATASET_ID', p_dataset);
        l_event_attribute_table(2) := T_BPM_EVENT_ATTRIBUTE('DATASET_TYPE', p_dataset_type);

        l_inbound_id := add_event(p_source => p_source, p_type => 4, p_attributes => l_event_attribute_table);

        RETURN l_inbound_id;
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    FUNCTION on_dataset_updated (
        p_dataset                          VARCHAR2
       ,p_dataset_type                     VARCHAR2
       ,p_attribute_name                   VARCHAR2
       ,p_source                           VARCHAR2
     )
    RETURN NUMBER
    IS
        l_event_attribute_table            T_BPM_TABLE_T_EVENT_ATTRIBUTE;
        l_inbound_id                       NUMBER;
    BEGIN
        l_event_attribute_table := T_BPM_TABLE_T_EVENT_ATTRIBUTE();
        l_event_attribute_table.extend(3);
        l_event_attribute_table(1) := T_BPM_EVENT_ATTRIBUTE('DATASET_ID', p_dataset);
        l_event_attribute_table(2) := T_BPM_EVENT_ATTRIBUTE('DATASET_TYPE', p_dataset_type);
        l_event_attribute_table(3) := T_BPM_EVENT_ATTRIBUTE('UPDATED_DS_ATTRIBUTE', p_attribute_name);

        l_inbound_id := add_event(p_source => p_source, p_type => 5, p_attributes => l_event_attribute_table);

        RETURN l_inbound_id;
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    FUNCTION clean_up
    RETURN NUMBER
    IS
        CURSOR c_event IS
               SELECT ID,
               STATE,
               TIME,
               SOURCE,
               TYPE,
               HANDLED_TIME,
               RECORD_STATUS,
               CREATED_BY,
               CREATED_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATED_DATE,
               REV_NO,
               REV_TEXT,
               APPROVAL_BY,
               APPROVAL_DATE,
               APPROVAL_STATE,
               REC_ID
               FROM BPM_EC_EVENT_INBOUND WHERE STATE IN (gv2_state_processed_successful, gv2_state_processed_failed)
               ORDER BY TIME;

        CURSOR c_event_att(p_event_id NUMBER) IS
               SELECT * FROM BPM_EC_EVENT_INBOUND_ATT where INBOUND_ID = p_event_id;

        TYPE l_IdsTab IS TABLE OF c_event%ROWTYPE;
        TYPE l_attTab IS TABLE OF c_event_att%ROWTYPE;

        l_event_temp                       l_IdsTab;
        l_event_att_temp                   l_attTab;
        l_count                            NUMBER;
   BEGIN
        l_count := 0;
        OPEN c_event;

        LOOP
          FETCH c_event BULK COLLECT INTO l_event_temp LIMIT 20;

          IF l_event_temp.count()=0 THEN
            exit;
          END IF;

          l_count := l_count + l_event_temp.count;

           FOR i in l_event_temp.first()..l_event_temp.last() LOOP
                 OPEN c_event_att(l_event_temp(i).ID);
                 FETCH c_event_att BULK COLLECT INTO l_event_att_temp;
                 CLOSE c_event_att;

                 INSERT INTO BPM_EC_EVENT_ARCHIVE (INBOUND_ID,
                                                   STATE,
                                                   TIME,
                                                   SOURCE,
                                                   TYPE,
                                                   HANDLED_TIME,
                                                   RECORD_STATUS,
                                                   CREATED_BY,
                                                   CREATED_DATE,
                                                   LAST_UPDATED_BY,
                                                   LAST_UPDATED_DATE,
                                                   REV_NO,
                                                   REV_TEXT,
                                                   APPROVAL_BY,
                                                   APPROVAL_DATE,
                                                   APPROVAL_STATE,
                                                   REC_ID)
                                           VALUES (l_event_temp(i).ID,
                                                   l_event_temp(i).STATE,
                                                   l_event_temp(i).TIME,
                                                   l_event_temp(i).SOURCE,
                                                   l_event_temp(i).TYPE,
                                                   l_event_temp(i).HANDLED_TIME,
                                                   l_event_temp(i).RECORD_STATUS,
                                                   l_event_temp(i).CREATED_BY,
                                                   l_event_temp(i).CREATED_DATE,
                                                   l_event_temp(i).LAST_UPDATED_BY,
                                                   l_event_temp(i).LAST_UPDATED_DATE,
                                                   l_event_temp(i).REV_NO,
                                                   l_event_temp(i).REV_TEXT,
                                                   l_event_temp(i).APPROVAL_BY,
                                                   l_event_temp(i).APPROVAL_DATE,
                                                   l_event_temp(i).APPROVAL_STATE,
                                                   l_event_temp(i).REC_ID);


                 FORALL i IN l_event_att_temp.first..l_event_att_temp.last
                   INSERT INTO BPM_EC_EVENT_ARCHIVE_ATT VALUES l_event_att_temp(i);

                 FORALL i IN l_event_att_temp.first..l_event_att_temp.last
                   DELETE FROM BPM_EC_EVENT_INBOUND_ATT WHERE INBOUND_ID=l_event_att_temp(i).INBOUND_ID;

                 DELETE FROM BPM_EC_EVENT_INBOUND where ID=l_event_temp(i).ID;

           END LOOP;

         END LOOP;

         CLOSE c_event;

         IF l_event_temp IS NOT NULL THEN
             l_event_temp.delete();
         END IF;

         IF l_event_att_temp IS NOT NULL THEN
             l_event_att_temp.delete();
         END IF;

         RETURN l_count;
   END;

END EcDp_BPM_EC_Event_Inbound;