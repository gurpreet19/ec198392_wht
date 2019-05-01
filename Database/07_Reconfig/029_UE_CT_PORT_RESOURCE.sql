create or replace PACKAGE UE_CT_PORT_RESOURCE
IS

FUNCTION PortResourceUsageWarnings(p_object_id VARCHAR2, p_start_date DATE, p_end_date DATE, p_event_no NUMBER DEFAULT NULL, p_rec_id VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

FUNCTION PortResourceUsageWarnings(p_cargo_no NUMBER) RETURN VARCHAR2;

PROCEDURE DeterminePortResourceConflict(p_object_id VARCHAR2, p_start_date DATE, p_end_date DATE, p_event_no NUMBER DEFAULT NULL, p_rec_id VARCHAR2 DEFAULT NULL);

FUNCTION IsPortResourceAvailable(p_object_id VARCHAR2, p_start_date DATE, p_end_date DATE DEFAULT NULL) RETURN VARCHAR2;

PROCEDURE auCargoTransport(p_cargo_no NUMBER, p_old_cargo_status VARCHAR2, p_new_cargo_status VARCHAR2, p_user VARCHAR2 DEFAULT NULL);

FUNCTION QueryPortResourcePool(p_port_resource_type VARCHAR2, p_cargo_no NUMBER, p_from_date DATE, p_to_date DATE) RETURN UE_CT_PORT_RES_POOL PIPELINED;

FUNCTION QueryCargoMovements(p_object_id VARCHAR2, p_production_day DATE, p_comment_date DATE, p_comment_type VARCHAR2) RETURN UE_CT_CARGO_MOVEMENT PIPELINED;

END UE_CT_PORT_RESOURCE;
/
create or replace PACKAGE BODY UE_CT_PORT_RESOURCE
IS
  DOWNTIME_CONFLICT VARCHAR2(32) := 'DOWNTIME_CONFLICT';
  USAGE_CONFLICT VARCHAR2(32) := 'USAGE_CONFLICT';
  NO_CONFLICT VARCHAR2(32) := 'NO_CONFLICT';
  c_object_id VARCHAR2(32);
  c_cargo_no NUMBER;
  c_direction VARCHAR2(32);
  c_result TV_CT_PORT_RES_USAGE%ROWTYPE;

  TYPE c_table IS TABLE OF TV_CT_PORT_RES_USAGE%ROWTYPE;

  c_warning_id VARCHAR2(32);
  c_warning_start DATE;
  c_warning_end DATE;
  c_warning VARCHAR2(20000);

  FUNCTION DetermineConflictInner(p_object_id      VARCHAR2,
                                  p_start_date     DATE,
                                  p_end_date       DATE,
                                  p_related_no OUT NUMBER,
                                  p_event_no       NUMBER DEFAULT NULL,
                                  p_rec_id         VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2
  IS
    CURSOR downtime_events
    IS
      SELECT event_no, daytime, NVL(end_date, TO_DATE('01-JAN-2500', 'DD-MON-YYYY')) AS end_date
      FROM   deferment_event
      WHERE  event_type = 'CT_PORT_RESOURCE_OFF'
      AND    object_id = p_object_id
      AND    event_no <> NVL(p_event_no, -1);

    CURSOR resource_usage
    IS
      SELECT res.cargo_no, res.calc_daytime AS daytime, NVL(res.end_date, TO_DATE('01-JAN-2300', 'DD-MON-YYYY')) AS end_date
      FROM   tv_ct_port_res_usage res
      WHERE  res.port_resource_id = p_object_id
      AND    res.cargo_no IN (SELECT nom.cargo_no
                              FROM   dv_storage_lift_nomination nom
                              WHERE  nom.nom_date_time BETWEEN p_start_date - 3 AND p_end_date + 3)
      AND    res.rec_id <> NVL(p_rec_id, 'XX');

    v_end_date DATE := NVL(p_end_date, TO_DATE('01-JAN-2500', 'DD-MON-YYYY'));
    v_start_date DATE := NVL(p_start_date, TO_DATE('01-JAN-2400', 'DD-MON-YYYY'));
  BEGIN

    FOR item IN downtime_events LOOP

      IF (v_start_date < item.end_date)
         AND(v_end_date > item.daytime) THEN
        p_related_no := item.event_no;
        RETURN DOWNTIME_CONFLICT;
      END IF;

    END LOOP;

    FOR item IN resource_usage LOOP

      IF (v_start_date < item.end_date)
         AND(v_end_date > item.daytime) THEN
        p_related_no := item.cargo_no;
        RETURN USAGE_CONFLICT;
      END IF;

    END LOOP;

    RETURN NO_CONFLICT;

  END DetermineConflictInner;

  FUNCTION PortResourceUsageWarnings(p_object_id VARCHAR2, p_start_date DATE, p_end_date DATE, p_event_no NUMBER DEFAULT NULL, p_rec_id VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2
  IS
    v_related_no NUMBER;
    v_result VARCHAR2(32);
    v_return_value VARCHAR2(20000);
  BEGIN

    IF c_warning_id = p_object_id
       AND c_warning_start = p_start_date
       AND c_warning_end = p_end_date THEN
      RETURN c_warning;
    END IF;

    v_result := DetermineConflictInner(p_object_id,
                                       p_start_date,
                                       p_end_Date,
                                       v_related_no,
                                       p_event_no,
                                       p_rec_id);

    v_return_value := '';

    IF v_result = DOWNTIME_CONFLICT THEN
      v_return_value := 'verificationStatus=error;verificationText=The assigned port resource is not available due to a downtime event.';
    END IF;

    IF v_result = USAGE_CONFLICT THEN
      v_return_value := 'verificationStatus=warning;verificationText=The assigned port resource is already in use by cargo ' || ec_cargo_transport.cargo_name(v_related_no);
    END IF;

    c_warning_id := p_object_id;
    c_warning_start := p_start_date;
    c_warning_end := p_end_date;
    c_warning := v_return_value;

    RETURN v_return_value;

  END PortResourceUsageWarnings;

  FUNCTION IsPortResourceAvailable(p_object_id VARCHAR2, p_start_date DATE, p_end_date DATE DEFAULT NULL)
    RETURN VARCHAR2
  IS
    v_related_no NUMBER;
    v_result VARCHAR2(32);
  BEGIN
    v_result := DetermineConflictInner(p_object_id,
                                       p_start_date,
                                       NVL(p_end_Date, p_start_date),
                                       v_related_no,
                                       NULL,
                                       NULL);

    IF (v_result = DOWNTIME_CONFLICT) THEN
      RETURN 'N';
    END IF;

    RETURN 'Y';
  END IsPortResourceAvailable;

  PROCEDURE DeterminePortResourceConflict(p_object_id VARCHAR2, p_start_date DATE, p_end_date DATE, p_event_no NUMBER DEFAULT NULL, p_rec_id VARCHAR2 DEFAULT NULL)
  IS
    v_related_no NUMBER;
    v_result VARCHAR2(32);
  BEGIN

    v_result := DetermineConflictInner(p_object_id,
                                       p_start_date,
                                       p_end_Date,
                                       v_related_no,
                                       p_event_no,
                                       p_rec_id);

    IF v_result = DOWNTIME_CONFLICT THEN
      RAISE_APPLICATION_ERROR(-20850, 'Object has existing downtime event in this time frame.');
    END IF;

  --IF v_result = USAGE_CONFLICT THEN
  --    RAISE_APPLICATION_ERROR(-20851, 'Object is scheduled to a port call during this time frame.');
  --END IF;

  END DeterminePortResourceConflict;

  FUNCTION PortResourceUsageWarnings(p_cargo_no NUMBER)
    RETURN VARCHAR2
  IS
    CURSOR resource_items
    IS
      SELECT port_resource_id, calc_daytime, end_date, rec_id
      FROM   tv_ct_port_res_usage
      WHERE  cargo_no = p_cargo_no
      AND    port_resource_id IS NOT NULL;

    v_fix_date DATE := ue_ct_leadtime.getfirstnomdatetime(p_cargo_no);

    CURSOR downtime_events(cp_object_id VARCHAR2)
    IS
      SELECT event_no, daytime, NVL(end_date, TO_DATE('01-JAN-2500', 'DD-MON-YYYY')) AS end_date
      FROM   deferment_event
      WHERE  event_type = 'CT_PORT_RESOURCE_OFF'
      AND    object_id = cp_object_id
      AND    NVL(end_date, TO_DATE('01-JAN-2500', 'DD-MON-YYYY')) > v_fix_date - 7
      AND    daytime < v_fix_date + 7
      AND    object_id = cp_object_id;

    v_table_result c_table;
    v_temp_result VARCHAR2(55);
    v_related_no NUMBER;
  BEGIN

    SELECT TABLE_CLASS_NAME,
           CARGO_NO,
           PORT_RESOURCE_NAME,
           PORT_RESOURCE_TYPE,
           PORT_RESOURCE_ID,
           CALC_DAYTIME,
           TIMELINE_CODE,
           CALC_DURATION,
           DAYTIME,
           DURATION_CODE,
           DURATION,
           END_DATE,
           NULL,
           NULL,
           COMMENTS,
           SORT_ORDER,
           NULL AS WARNING_SYNTAX,
           RECORD_STATUS,
           CREATED_BY,
           CREATED_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATED_DATE,
           REV_NO,
           REV_TEXT,
           APPROVAL_STATE,
           APPROVAL_BY,
           APPROVAL_DATE,
           REC_ID
    BULK   COLLECT INTO v_table_result
    FROM   tv_ct_port_res_usage
    WHERE  port_resource_id IS NOT NULL
    --AND    cargo_no <> p_cargo_no
    AND    cargo_no IN (SELECT nom.cargo_no
                        FROM   dv_storage_lift_nomination nom
                        WHERE  nom.nom_date_time BETWEEN v_fix_date - 7 AND v_fix_date + 7);

    FOR item IN resource_items LOOP

      FOR row_num IN 1 .. v_table_result.COUNT LOOP

        IF item.port_resource_id = v_table_result(row_num).port_resource_id
           AND item.rec_id <> v_table_result(row_num).rec_id
           AND item.end_date > v_table_result(row_num).calc_daytime
           AND item.calc_daytime < v_table_result(row_num).end_date THEN
          RETURN 'verificationStatus=warning;verificationText=One or more port resources has a conflict.';
        END IF;

      END LOOP;

      FOR d_item IN downtime_events(item.port_resource_id) LOOP
        IF item.end_date > d_item.daytime AND item.calc_daytime < d_item.end_date THEN
          RETURN 'verificationStatus=warning;verificationText=One or more port resources has a conflict.';
        END IF;
      END LOOP;

    END LOOP;

    RETURN '';

  END PortResourceUsageWarnings;

  PROCEDURE auCargoTransport(p_cargo_no NUMBER, p_old_cargo_status VARCHAR2, p_new_cargo_status VARCHAR2, p_user VARCHAR2 DEFAULT NULL)
  IS
    CURSOR parcel_products(cp_cargo_no NUMBER)
    IS
      SELECT ec_stor_version.product_id(object_id, nom_firm_date, '<=') AS product_id
      FROM   storage_lift_nomination
      WHERE  cargo_no = cp_cargo_no;

    CURSOR port_resource_template(cp_cargo_no NUMBER, cp_product_id VARCHAR2, cp_activity_type VARCHAR2)
    IS
      SELECT tmpl.port_resource_name, tmpl.port_resource_type, tmpl.sort_order, tmpl.timeline_code, tmpl.duration_code
      FROM   tv_ct_port_res_use_tmpl tmpl
      WHERE  tmpl.product_id = cp_product_id
      AND    tmpl.lifting_event_code = cp_activity_type
      AND    NOT EXISTS
               (SELECT 'A'
                FROM   ct_port_res_usage pru
                WHERE  pru.cargo_no = p_cargo_no
                AND    pru.sort_order = tmpl.sort_order);

    v_product_id VARCHAR2(32);
    v_activity_type VARCHAR2(32) := 'LOAD';
  BEGIN

    -- if status has changed - fire port resource population when cargo status reaches "O"
    IF (NVL(p_old_cargo_status, 'XXX') <> NVL(p_new_cargo_status, 'XXX'))
       AND p_new_cargo_status = 'O' THEN

      FOR item IN parcel_products(p_cargo_no) LOOP
        v_product_id := item.product_id;
      END LOOP;

      --ecdp_dynsql.writetemptext('PORT_RESOURCE', 'Cargo Number: ' || p_cargo_no || ', Product: ''' || v_product_id || ''', Activity: ' || v_activity_type);

      FOR item IN port_resource_template(p_cargo_no, v_product_id, v_activity_type) LOOP

        INSERT INTO ct_port_res_usage(cargo_no,
                                      port_resource_name,
                                      port_resource_type,
                                      sort_order,
                                      timeline_code,
                                      duration_code)
        VALUES (p_cargo_no,
                item.port_resource_name,
                item.port_resource_type,
                item.sort_order,
                item.timeline_code,
                item.duration_code);

      END LOOP;

    END IF;

  END auCargoTransport;

  FUNCTION QueryPortResourcePool(p_port_resource_type VARCHAR2, p_cargo_no NUMBER, p_from_date DATE, p_to_date DATE)
    RETURN UE_CT_PORT_RES_POOL
    PIPELINED
  IS
    TYPE ref_cur IS REF CURSOR;

    myCursor ref_cur;
    out_rec UE_CT_PORT_RES_POOL_RECTYPE
      := UE_CT_PORT_RES_POOL_RECTYPE(NULL,
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL);
  BEGIN

    OPEN mycursor FOR
      WITH resource_data
           AS (SELECT port_resource_id, cargo_no, calc_daytime AS daytime, end_date
               FROM   tv_ct_port_res_usage
               WHERE  port_resource_type = p_port_resource_type
               AND    port_resource_id IS NOT NULL
               AND    ue_ct_leadtime.getfirstnomdatetime(cargo_no) BETWEEN p_from_date - 7 AND p_to_date + 7)
      SELECT port_resource.name NAME,
             port_resource.object_id OBJECT_ID,
             port_resource.daytime DAYTIME,
             ue_ct_port_resource.isportresourceavailable(port_resource.object_id, p_from_date, p_to_date) resource_available,
             ec_cargo_transport.cargo_name(prev_usage.cargo_no) AS prev_cargo,
             prev_usage.daytime AS prev_start,
             prev_usage.end_date AS prev_end,
             ec_cargo_transport.cargo_name(next_usage.cargo_no) AS next_cargo,
             next_usage.daytime AS next_start,
             next_usage.end_date AS next_end
      FROM  iv_ct_port_resource port_resource
            LEFT OUTER JOIN (SELECT port_resource_id, cargo_no, daytime, end_date, ROW_NUMBER() OVER (PARTITION BY port_resource_id ORDER BY daytime DESC) AS rownumber
                             FROM   resource_data
                             WHERE  daytime <= p_from_Date
                             AND    cargo_no <> p_cargo_no) prev_usage
              ON port_resource.object_id = prev_usage.port_resource_id
            LEFT OUTER JOIN (SELECT port_resource_id, cargo_no, daytime, end_date, ROW_NUMBER() OVER (PARTITION BY port_resource_id ORDER BY daytime ASC) AS rownumber
                             FROM   resource_data
                             WHERE  daytime >= p_from_date
                             AND    cargo_no <> p_cargo_no) next_usage
              ON port_resource.object_id = next_usage.port_resource_id
      WHERE  port_resource.daytime <= p_from_date
      AND    (port_resource.end_date IS NULL
      OR       port_resource.end_date >= p_from_date)
      AND    port_resource.class_name = p_port_resource_type
      AND    NVL(prev_usage.rownumber, 1) = 1
      AND    NVL(next_usage.rownumber, 1) = 1
      AND    (port_resource.object_id IN (SELECT conn.object_name
                                          FROM   tv_object_group_conn conn
                                          WHERE  conn.parent_group_type = 'PORT_RESOURCES'
                                          AND    conn.OBJECT_ID IN (SELECT noms.OBJECT_ID
                                                                    FROM   DV_STORAGE_LIFT_NOMINATION noms
                                                                    WHERE  noms.CARGO_NO = p_cargo_no))
      OR       (SELECT COUNT(*)
                FROM   class_relation rel
                WHERE  rel.to_class_name = p_port_resource_type
                AND    rel.group_type IS NOT NULL) = 0)
      ORDER BY port_resource.name;

    LOOP

      FETCH mycursor
      INTO   out_rec.name,
             out_rec.object_id,
             out_rec.daytime,
             out_rec.resource_available,
             out_rec.prev_cargo,
             out_rec.prev_start,
             out_rec.prev_end,
             out_rec.next_cargo,
             out_rec.next_start,
             out_rec.next_end;

      EXIT WHEN myCursor%NOTFOUND;
      PIPE ROW (out_rec);
    END LOOP;

  END QueryPortResourcePool;

  -- Pipelined function to improve performance on the Vessel Comments BF
  FUNCTION QueryCargoMovements(p_object_id VARCHAR2, p_production_day DATE, p_comment_date DATE, p_comment_type VARCHAR2) RETURN UE_CT_CARGO_MOVEMENT PIPELINED
  IS
    out_rec UE_CT_CARGO_MOVEMENT_RECTYPE;

    CURSOR cargoes_across_day IS
    SELECT UE_CT_CARGO_MOVEMENT_RECTYPE(p_production_day, c.production_day, c.from_date, c.to_date, p_comment_type, c.comments, c.comments_2)
    FROM CV_SYSTEM_VESSEL_COMMENTS c
    WHERE ((c.production_day = p_production_day and p_comment_date is not null)
    OR (c.production_day >= p_production_day + 1 and c.production_day <= p_production_day + 6 and p_comment_date is null))
    AND p_comment_type = 'VESSEL_MOVEMENTS'
    AND p_object_id = ec_production_facility.object_id_by_uk('FC1_GGP_LOG_7000', 'FCTY_CLASS_1')
    ORDER BY c.from_date;

    intermediate_results UE_CT_CARGO_MOVEMENT;
  BEGIN

    OPEN cargoes_across_day;
    FETCH cargoes_across_day BULK COLLECT INTO intermediate_results;
    CLOSE cargoes_across_day;

    out_rec := UE_CT_CARGO_MOVEMENT_RECTYPE(null, null, null, null, null, null, null);

    FOR i in 1 .. intermediate_results.count LOOP
        PIPE ROW (intermediate_results(i));
    END LOOP;

  END QueryCargoMovements;

END UE_CT_PORT_RESOURCE;
/