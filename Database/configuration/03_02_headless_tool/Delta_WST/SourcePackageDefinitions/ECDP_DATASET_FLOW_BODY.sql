CREATE OR REPLACE PACKAGE BODY EcDp_DATASET_FLOW IS

FUNCTION CheckIfMax( p_type  varchar2,
                     p_reference_id varchar2) return varchar2
 is

 lv2_return varchar2(1);
 ln_later_documents number;

 begin

   lv2_return := 'Y';
   IF p_type like 'CALC_REF%' THEN
       SELECT COUNT(*) INTO ln_later_documents
       from calc_reference
            where ec_calc_reference.calculation_id(p_reference_id)
                  =calculation_id
                  and run_no > p_reference_id
                  and nvl(object_id,'XX') = NVL(ec_calc_reference.object_id(p_reference_id),'XX')
                  and calc_collection_id = ec_calc_reference.calc_collection_id(p_reference_id)
                  AND daytime = ec_calc_reference.daytime(p_reference_id)
                  AND NVL(ACCRUAL_IND,'N') = NVL( ec_calc_reference.accrual_ind(p_reference_id),'N');
   END IF;

   IF ln_later_documents > 0 THEN
     lv2_return := 'N';
   END IF;

 return lv2_return ;


end CheckIfMax;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Function       : GetStatusinTable
-- Description    : Pulls status from the corresponding tables
------------------------+-----------------------------------+------------------------------------+---------------------------


FUNCTION GetStatusinTable(p_type VARCHAR2, p_reference_id VARCHAR2) RETURN VARCHAR2 IS
       lv_status                 VARCHAR2(32);
 CURSOR c_cont_doc IS
    SELECT record_status
      FROM cont_doc
     WHERE document_key = p_reference_id;

    CURSOR c_ifac_journal_entry(
                        cp_source_doc_name                  VARCHAR2) IS
    SELECT DISTINCT ije.record_status status
      FROM ifac_journal_entry ije
     WHERE TO_CHAR(ije.period,'YYYY-MM-DD')||'$'||ije.source_doc_name||'$'||ije.source_doc_ver = cp_source_doc_name;

    CURSOR c_cont_document IS
    SELECT CASE document_level_code
           WHEN 'VALID2'   THEN 'V'
           WHEN 'TRANSFER' THEN 'V'
           WHEN 'BOOKED'   THEN 'A'
           ELSE 'P' END AS status
      FROM cont_document
     WHERE document_key = p_reference_id;
BEGIN


        --Get current status from the given type
        IF p_type IN( 'CONT_JOURNAL_ENTRY','CONT_JOURNAL_SUMMARY') THEN
            lv_status := ec_cont_doc.record_status(p_reference_id);


        ELSIF p_type = 'IFAC_JOURNAL_ENTRY' THEN
            FOR ije_rec IN c_ifac_journal_entry(p_reference_id) LOOP
                lv_status := ije_rec.status;
                --RETURN 'Source document ''' || p_reference_id || ''' can not be unapproved as it is used on other documents (Data Entries: ''' || ije_rec.document_key || '''). The Data Entries document must first be deleted.';
            END LOOP;


        ELSIF p_type = 'CONT_DOCUMENT' THEN

           lv_status := ec_cont_document.document_level_code(p_reference_id);
           case lv_status when
             'OPEN' THEN lv_status := 'P';
            WHEN 'BOOKED' THEN lv_status := 'A';
            ELSE lv_status := 'V';
            END CASE;


        ELSIF p_type = 'CALC_REFERENCE' OR p_type LIKE 'CALC_REF_%' THEN
           lv_status := NVL(ec_calc_reference.accept_status(p_reference_id),
               ec_alloc_job_log.accept_status(p_reference_id));



        ELSIF p_type IN  ('REPORT','REPORT_GENERATED') THEN
          IF p_reference_id IS NULL THEN
            lv_status := 'NO_REPORT';
          ELSE
           lv_status := ec_report.record_status(p_reference_id);
          END IF;

          ELSE
              lv_status := rr_dataset_flow.getdocstatus(p_type,p_reference_id,lv_status);
        END IF;

    return lv_status;

END;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Function       : UpdateDSFlowTableStatus
-- Description    : Will update the content in the DATASET_FLOW_DOCUMENTS table
------------------------+-----------------------------------+------------------------------------+---------------------------
PROCEDURE UpdateDSFlowTableStatus(
                        p_type                              VARCHAR2,
                        p_reference_id                      VARCHAR2,
                        p_status                            VARCHAR2,
                        p_user                              VARCHAR2
                        )
IS
  lv_connection_id NUMBER;

  CURSOR TargetItems (cp_type VARCHAR2,
                        cp_reference_id VARCHAR2) IS
                        select to_type type,
                               to_reference_id reference_id
                          FROM DATASET_FLOW_DOC_CONN
                         WHERE FROM_TYPE = cp_type
                           AND FROM_REFERENCE_ID = cp_reference_id
                           AND (FROM_TYPE NOT LIKE 'CALC_REF%' OR TO_TYPE != 'CONT_JOURNAL_SUMMARY');


    CURSOR c_ifac_journal_entry(
                        cp_source_doc_name                  VARCHAR2) IS
    SELECT DISTINCT ije.record_status status
      FROM ifac_journal_entry ije
     WHERE TO_CHAR(ije.period,'YYYY-MM-DD')||'$'||ije.source_doc_name||'$'||ije.source_doc_ver = cp_source_doc_name;


   CURSOR cr_Depricated (cp_type VARCHAR2,
                        cp_reference_id VARCHAR2,
                        cp_object       VARCHAR2,
                        cp_process_date DATE) IS
                        select reference_id
                          FROM DATASET_FLOW_DOCUMENT
                         WHERE TYPE = cp_type
                           AND ((NVL(ec_cont_doc.summary_setup_id(cp_reference_id),'XX')
                               = NVL(ec_cont_doc.summary_setup_id(reference_id),'XX')
                               AND NVL(ec_cont_doc.inventory_id(cp_reference_id),'XX')
                               = NVL(ec_cont_doc.inventory_id(reference_id),'XX'))
                               OR cp_type != 'CONT_JOURNAL_SUMMARY')
                           AND cp_reference_id != reference_id
                           AND OBJECT = cp_object
                           AND PROCESS_DATE = cp_process_date
                           AND MAX_IND = 'Y';

   CURSOR cr_tin_Depricated (cp_type VARCHAR2,
                        cp_reference_id VARCHAR2,
                        cp_object       VARCHAR2,
                        cp_process_date DATE) IS
                        select reference_id
                          FROM DATASET_FLOW_DOCUMENT
                         WHERE TYPE = cp_type
                           AND (NVL(EC_CALC_REFERENCE.OBJECT_ID(cp_reference_id),'XX')
                               = NVL(EC_CALC_REFERENCE.OBJECT_ID(reference_id),'XX')
                               and cp_type = 'CALC_REF_TIN')
                           AND cp_reference_id != reference_id
                           AND OBJECT = cp_object
                           AND PROCESS_DATE = cp_process_date
                           AND MAX_IND = 'Y';


   CURSOR FindDepricatedSource (cp_type VARCHAR2,
                        cp_reference_id VARCHAR2) IS
                        select count(*) itemcount
                          FROM DATASET_FLOW_DOC_CONN dfdc,
                               DATASET_FLOW_DOCUMENT dfd
                         WHERE to_TYPE = cp_type
                           AND from_type = type
                           AND from_reference_id = reference_id
                           AND to_reference_id = cp_reference_id
                           AND NVL(MAX_IND,'N') != 'Y';


     lv2_depricated          VARCHAR2(100);
     lv_object               VARCHAR2(100);
     ld_process_date         date;
     lv_status               VARCHAR2(32) := p_status;
     lv_prev_ref_id          VARCHAR2(100);
     lv_ref                  VARCHAR2(100);
BEGIN
   ld_process_date := ec_dataset_flow_document.process_date(p_type,p_reference_id);
   lv_object := ec_dataset_flow_document.object(p_type,p_reference_id);
   lv_prev_ref_id := ec_dataset_flow_document.prev_ref_id(p_type,p_reference_id);

   IF lv_status != 'P' THEN --undepricating
     lv_ref := p_reference_id;
   ELSE
     lv_ref := lv_prev_ref_id;
   END IF;

   IF lv_status IN ('P','UD') THEN

     case p_type
        WHEN 'IFAC_JOURNAL_ENTRY' THEN
           FOR ije_rec IN c_ifac_journal_entry(lv_ref) LOOP
                lv_status := ije_rec.status;
                --RETURN 'Source document ''' || p_reference_id || ''' can not be unapproved as it is used on other documents (Data Entries: ''' || ije_rec.document_key || '''). The Data Entries document must first be deleted.';
            END LOOP;
       WHEN 'CONT_JOURNAL_ENTRY' THEN
        lv_status := ec_cont_doc.record_status(lv_ref);
        WHEN 'CONT_JOURNAL_SUMMARY' THEN
        lv_status := ec_cont_doc.record_status(lv_ref);
        WHEN 'CONT_DOCUMENT' THEN
            IF lv_status = 'UD' THEN
                --Find out how to get previous status
                CASE ec_cont_document.document_level_code (lv_ref)
                WHEN 'BOOKED' THEN
                    lv_status := 'A';
                WHEN 'OPEN' THEN
                    lv_status := 'P';
                ELSE
                    lv_status := 'V';
                END CASE;
            END IF;
        WHEN 'REPORT_GENERATED' THEN
          lv_status := ec_report.record_status(lv_ref);
       WHEN 'CALC_REFERENCE' THEN
        lv_status := nvl(ec_calc_reference.accept_status(lv_ref),ec_calc_reference.record_status(lv_ref));
        WHEN 'CALC_REF_TIN' THEN
        lv_status := nvl(ec_calc_reference.accept_status(lv_ref),ec_calc_reference.record_status(lv_ref));
        WHEN 'CALC_REF_ROY' THEN
        lv_status := nvl(ec_calc_reference.accept_status(lv_ref),ec_calc_reference.record_status(lv_ref));
        WHEN 'CONTRACT_ACCOUNT' THEN
             NULL;
        WHEN 'REPORT' THEN
          lv_status := nvl(ec_report.accept_status(lv_ref),ec_calc_reference.record_status(lv_ref));
        ELSE
          lv_status:= rr_dataset_flow.getDocStatus(p_type, p_reference_id, lv_status);
      END CASE;

   END IF;



   if p_status = 'P' THEN
      -- If P need reset status of the preceding doc
             IF ec_dataset_flow_document.status (p_type,lv_ref) != 'D' THEN

                 UPDATE DATASET_FLOW_DOCUMENT
                    SET STATUS = lv_status,
                        last_updated_by = p_user
                  WHERE reference_id = lv_ref
                    AND type = p_type;
            ELSE
                 -- check if there are any depricated source items
                 FOR item in FindDepricatedSource(p_type,lv_ref) LOOP
                     IF item.itemcount = 0 then

                     UPDATE DATASET_FLOW_DOCUMENT
                        SET STATUS = nvl(lv_status,'P'),
                            last_updated_by = p_user
                      WHERE reference_id = lv_ref
                        AND type = p_type;
                     END IF;
                  END LOOP;
            END IF;

             IF ec_dataset_flow_document.status (p_type,p_reference_id) != 'D' THEN

                   UPDATE DATASET_FLOW_DOCUMENT
                      SET STATUS = p_status,
                          last_updated_by = p_user
                    WHERE reference_id = p_reference_id
                      AND type = p_type;

            ELSE
                 -- check if there are any depricated source items
                 FOR item in FindDepricatedSource(p_type,P_reference_id) LOOP
                     IF item.itemcount = 0 then

                     UPDATE DATASET_FLOW_DOCUMENT
                        SET STATUS = p_status,
                            last_updated_by = p_user
                      WHERE reference_id = p_reference_id
                        AND type = p_type;
                     END IF;
                  END LOOP;
            END IF;


  ELSE


         UPDATE DATASET_FLOW_DOCUMENT
                        SET STATUS = lv_status,
                            last_updated_by = p_user
                      WHERE p_reference_id = reference_id
                        AND type = p_type;


  END IF;

        -- Removing Depricated on older items as item is now being unverified
        IF p_status in ('P','UD') THEN

               IF p_status = 'P' THEN
                  lv2_depricated := ec_dataset_flow_document.prev_ref_id(p_type,p_reference_id);

               ELSE

                 lv2_depricated := p_reference_id;
               END IF;



             -- This sets back the previous item to max
             IF p_status = 'P' THEN


               UPDATE DATASET_FLOW_DOCUMENT
                  SET MAX_IND='N',
                      PREV_REF_ID = NULL
                WHERE p_reference_id = reference_id
                  AND type = p_type;


               FOR item in FindDepricatedSource(p_type,lv2_depricated) LOOP
                   IF item.itemcount = 0 then

                      UPDATE DATASET_FLOW_DOCUMENT
                      SET MAX_IND = 'Y',
                          status = nvl(lv_status,'P')
                    WHERE reference_id = lv2_depricated
                      AND type = p_type;
                    ELSE
                      UPDATE DATASET_FLOW_DOCUMENT
                      SET MAX_IND = 'Y'
                    WHERE reference_id = lv2_depricated
                      AND type = p_type;

                    END IF;
                END LOOP;

             else

               FOR item in FindDepricatedSource(p_type,P_reference_id) LOOP
                   IF item.itemcount = 0 then
                     UPDATE DATASET_FLOW_DOCUMENT
                        SET status = lv_status
                      WHERE reference_id = P_reference_id
                        AND type = p_type;
                  END IF;
               END LOOP;
             END IF;


               IF nvl(lv2_depricated,'XX') != nvl(p_reference_id ,'XX') THEN
                   FOR target in TargetItems(p_type,lv2_depricated) LOOP

                            UpdateDSFlowTableStatus(target.type,target.reference_id,'UD',p_user);

                   END LOOP;
               END IF;

        END IF;

        -- Setting Depricated on older items
        IF p_status in ('V','D') OR (p_status= 'A' AND p_type='IFAC_JOURNAL_ENTRY' ) THEN

            IF p_status IN ('V','A')  THEN

			   IF  p_type ='CALC_REF_TIN' THEN

                 FOR Depricated in cr_tin_Depricated(p_type,p_reference_id,lv_object,ld_process_date
                     ) LOOP
                     lv2_depricated := Depricated.reference_id;
                 END LOOP;

			   ELSE

                 FOR Depricated in cr_Depricated(p_type,p_reference_id,lv_object,ld_process_date
                     ) loop
                     lv2_depricated := Depricated.reference_id;
                 END loop;

			   END IF;

            ELSE
               lv2_depricated := p_reference_id;
            END IF;


             IF p_status != 'D' THEN

                 IF lv2_depricated != p_reference_id THEN

                   UPDATE DATASET_FLOW_DOCUMENT
                      SET PREV_REF_ID = lv2_depricated
                    WHERE p_reference_id = reference_id
                      AND type = p_type;

                 END IF;

                 UPDATE DATASET_FLOW_DOCUMENT
                    SET MAX_IND='Y'
                  WHERE p_reference_id = reference_id
                    AND type = p_type;

                 UPDATE DATASET_FLOW_DOCUMENT
                    SET MAX_IND='N',
                        status = 'D'
                  WHERE reference_id = lv2_depricated
                    AND type = p_type;

             END IF;



             IF nvl(lv2_depricated,'XX') != nvl(p_reference_id ,'XX') AND p_type != 'CALC_REF_TIN' THEN

                 FOR target in TargetItems(p_type,lv2_depricated) LOOP
                     UpdateDSFlowTableStatus(target.type,target.reference_id,'D',p_user);
                 END LOOP;
             END IF;

    END IF;


END;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Function       : GetConnectionId
-- Description    : Gives connection id from DATASET_FLOW_DOC_CONN table.
--                  Returns zero when connection id is not found.
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetConnectionId(
                        p_TO_TYPE                           VARCHAR2,
                        p_TO_REFERENCE_ID                   VARCHAR2,
                        p_FROM_TYPE                         VARCHAR2,
                        p_FROM_REFERENCE_ID                 VARCHAR2,
                        p_insert                            BOOLEAN DEFAULT FALSE
                        )
RETURN NUMBER
IS
  lv_connection_id NUMBER;
BEGIN

  SELECT (SELECT dc.connection_id FROM DATASET_FLOW_DOC_CONN dc
   WHERE dc.to_type=p_TO_TYPE
     AND dc.to_reference_id=p_TO_REFERENCE_ID
     AND dc.from_type=p_FROM_TYPE
     AND dc.from_reference_id=p_FROM_REFERENCE_ID) INTO lv_connection_id
    FROM DUAL;

  IF lv_connection_id is null and p_insert THEN
    ecdp_system_key.assignNextNumber('DATASET_FLOW_DOC_CONN',lv_connection_id);
    INSERT INTO DATASET_FLOW_DOC_CONN (connection_id,to_type, to_reference_id, from_type,from_reference_id)
    values (lv_connection_id,p_to_type, p_to_reference_id, p_from_type,p_from_reference_id);


  END IF;

  RETURN lv_connection_id;

END GetConnectionId;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : InsToDSFlowDoc
-- Description    : Inserts data to DATASET_FLOW_DOCUMENT table when Data Mapping/Data extraxt is created.
--                  and when IFAC Data Entry document is aproved.
-- Behaviour      : Called from EcDp_RR_Revn_Common.CreateDocument and ECDP_RR_REVN_MAPPING_INTERFACE.ApproveLatestUpload.
------------------------+-----------------------------------+------------------------------------+---------------------------
PROCEDURE InsToDsFlowDoc(
                        p_type                              VARCHAR2,
                        p_process_date                      DATE,
                        p_object                            VARCHAR2,
                        p_reference_id                      VARCHAR2,
                        p_STATUS                            VARCHAR2,
                        p_MAX_IND                           VARCHAR2,
                        p_DATASET                           VARCHAR2,
                        p_accrual_ind                       VARCHAR2,
                        p_screen_doc_type                   VARCHAR2 default null
                        )
IS


BEGIN

  IF NVL(ec_ctrl_system_attribute.attribute_text(p_process_date,'ENABLE_DOC_TRACING','<='),'N') = 'Y' THEN

        INSERT INTO DATASET_FLOW_DOCUMENT
        (
        TYPE,
        PROCESS_DATE,
        OBJECT,
        REFERENCE_ID,
        STATUS,
        MAX_IND,
        DATASET,
        SCREEN_DOC_TYPE,
        ACCRUAL,
        CREATED_BY,
        CREATED_DATE
        )
        VALUES
        (
         p_type,
         p_process_date,
         p_object,
         p_reference_id,
         p_STATUS ,
         p_MAX_IND ,
         decode(p_type,'CONT_JOURNAL_ENTRY',ec_cont_doc.dataset(p_reference_id),'CONT_JOURNAL_SUMMARY',ec_cont_doc.summary_setup_id(p_reference_id)),
         p_screen_doc_type,
         p_accrual_ind,
         User,
         Ecdp_Timestamp.getCurrentSysdate
        );

        RR_DATASET_FLOW.InsToDsFlowDoc(p_type,p_process_date,
                        p_object     ,
                        p_reference_id,
                        p_STATUS,
                        p_MAX_IND,
                        p_DATASET,
                        p_accrual_ind,
                        p_screen_doc_type);
   END IF;

EXCEPTION WHEN OTHERS
  THEN
  RAISE_APPLICATION_ERROR(-20000, 'Can not insert data to DATASET_FLOW_DOCUMENT table . Unknown error occurred (' || SQLCODE || ') ' || '. ' || SQLERRM);
END InsToDSFlowDoc;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : InsJMDataToDS
-- Description    : Inserts data to DATASET_FLOW_DOC_CONN and DATASET_FLOW_DETAIL_CONN tables when Data Mapping document is created.
------------------------+-----------------------------------+------------------------------------+---------------------------
PROCEDURE InsJMDataToDS(p_document_key                      VARCHAR2
                        )
IS

CURSOR c_ifac_doc IS
SELECT c.ref_journal_entry_src,
       c.ref_journal_entry_no,
       c.journal_entry_no,
       c.cost_mapping_id,
       c.comments,
       TO_CHAR(ije.PERIOD,'YYYY-MM-DD')||'$'||ije.source_doc_name||'$'||ije.source_doc_ver as doc_name,
       c.created_date,
       ije.period
  FROM CONT_JOURNAL_ENTRY c,ifac_journal_entry ije
 WHERE c.document_key=p_document_key
   AND c.ref_journal_entry_no=ije.journal_entry_no
   AND c.reversal_date IS NULL
   AND c.ref_journal_entry_src= 'IFAC'
UNION ALL
SELECT c.ref_journal_entry_src,
       c.ref_journal_entry_no,
       c.journal_entry_no,
       c.cost_mapping_id,
       c.comments,
       cje.document_key as doc_name,
       c.created_date,
       cje.period
  FROM CONT_JOURNAL_ENTRY c,cont_journal_entry cje
 WHERE c.document_key=p_document_key
   AND c.ref_journal_entry_no=cje.journal_entry_no
   AND c.reversal_date IS NULL
   AND c.ref_journal_entry_src= 'CONT'
UNION ALL
SELECT c.ref_journal_entry_src,
       c.ref_journal_entry_no,
       c.journal_entry_no,
       c.cost_mapping_id,
       c.comments,
       NULL as doc_name,
       c.created_date,
       c.period
  FROM CONT_JOURNAL_ENTRY c
 WHERE c.document_key=p_document_key
   AND c.reversal_date IS NULL
   AND c.ref_journal_entry_src= 'CLASS'
   UNION ALL
 SELECT c.ref_journal_entry_src,
        c.ref_journal_entry_no,
        c.journal_entry_no,
        c.cost_mapping_id,
        c.comments,
        NULL as doc_name,
        c.created_date,
        c.period
   FROM CONT_JOURNAL_ENTRY c
  WHERE c.document_key = p_document_key
    AND c.reversal_date IS NULL
    AND c.ref_journal_entry_src != 'MANUAL'
    AND c.ref_journal_entry_src NOT IN (SELECT code
                                         FROM PROSTY_CODES
                                        WHERE code_type = 'COST_MAPPING_JE_SOURCE');

lv_from_type            VARCHAR2(100);
lv_from_id              VARCHAR2(100);
lv_connection_id        NUMBER;
lv_return               VARCHAR2(4000);
BEGIN

-- INSTEAD OF user-exit
IF ue_Dataset_Flow.isInsJMDataToDSUEE = 'TRUE' THEN
   lv_return := ue_Dataset_Flow.InsJMDataToDS(p_document_key);
ELSE
    -- PRE user-exit
    IF ue_Dataset_Flow.isInsJMDataToDSPreUEE = 'TRUE' THEN
        lv_return := ue_Dataset_Flow.InsJMDataToDSPre(p_document_key);
    END IF;

    IF NVL(ec_ctrl_system_attribute.attribute_text(ec_cont_doc.period(p_document_key),'ENABLE_DOC_TRACING','<='),'N') = 'Y' THEN

        FOR c IN c_ifac_doc LOOP

            lv_from_type    :=CASE c.ref_journal_entry_src WHEN 'CLASS' THEN 'CLASS_MAPPING' WHEN 'IFAC' THEN 'IFAC_JOURNAL_ENTRY' WHEN 'CONT' THEN 'CONT_JOURNAL_ENTRY' ELSE c.ref_journal_entry_src END;
            lv_from_id      :=CASE c.ref_journal_entry_src WHEN 'CLASS' THEN 'CLASS_MAP' WHEN 'IFAC' THEN c.doc_name WHEN 'CONT' THEN c.doc_name ELSE c.ref_journal_entry_no END;
            lv_connection_id:=GetConnectionId('CONT_JOURNAL_ENTRY',p_document_key ,lv_from_type,lv_from_id);

            IF (nvl(lv_connection_id,0)=0) THEN
                Ecdp_System_Key.assignNextNumber('DATASET_FLOW_DOC_CONN',lv_connection_id);

                INSERT INTO DATASET_FLOW_DOC_CONN
                (
                CONNECTION_ID,
                TO_TYPE,
                TO_REFERENCE_ID,
                FROM_TYPE,
                FROM_REFERENCE_ID,
                CREATED_BY,
                CREATED_DATE
                )
                VALUES
                (
                lv_connection_id,
                'CONT_JOURNAL_ENTRY',
                p_document_key,
                lv_from_type,
                lv_from_id,
                user,
                Ecdp_Timestamp.getCurrentSysdate
                );
            END IF;

            INSERT INTO DATASET_FLOW_DETAIL_CONN
            (
            CONNECTION_ID,
            TO_TYPE,
            FROM_TYPE,
            TO_REFERENCE_ID,
            FROM_REFERENCE_ID,
            FROM_ID,
            TO_ID,
            MAPPING_TYPE,
            MAPPING_ID,
            RUN_TIME,
            DETAIL_TO_VALUE,
            COMMENTS,
            CREATED_BY,
            CREATED_DATE
            )
            VALUES
            (
            GetConnectionId('CONT_JOURNAL_ENTRY',p_document_key ,lv_from_type,lv_from_id),
            'CONT_JOURNAL_ENTRY',
            lv_from_type,
            p_document_key,
            lv_from_id,
            DECODE(c.ref_journal_entry_src,'CLASS','CLASS_MAPPING',c.ref_journal_entry_no),
            c.journal_entry_no,
            'JOURNAL_MAPPING',
            c.cost_mapping_id ,
            c.created_date,
            'N',
            c.comments,
            user,
            Ecdp_Timestamp.getCurrentSysdate
            );

            --Update Visual Tracing
            EcDp_Visual_Tracing.UpdateVisualTracing(p_document_key,'CONT_JOURNAL_ENTRY', c.period);
        END LOOP;
    END IF;

    -- POST user-exit
    IF ue_Dataset_Flow.isInsJMDataToDSPostUEE = 'TRUE' THEN
        lv_return := ue_Dataset_Flow.InsJMDataToDSPost(p_document_key, lv_return);
    END IF;
END IF;

EXCEPTION WHEN OTHERS
  THEN
    RAISE_APPLICATION_ERROR(-20000, 'Can not insert data to DATASET tables . Unknown error occurred (' || SQLCODE || ') ' || '. ' || SQLERRM);
END InsJMDataToDS;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : InsJEDataToDS
-- Description    : Inserts data to DATASET_FLOW_DOC_CONN and DATASET_FLOW_DETAIL_CONN tables when Data extraxt is created.
-- Behaviour      : Called from EcDp_RR_Revn_Summary.CreateSummaryMonth.
------------------------+-----------------------------------+------------------------------------+---------------------------
PROCEDURE InsJEDataToDS(p_document_key                      VARCHAR2
                        )
IS
CURSOR c_data IS
   SELECT cje.document_key From_document,
          cjs.document_key TO_document,
          cje.journal_entry_no FROM_ID,
          cjs.tag TO_ID,
          'JOURNAL_SUMMARY' Mapping_type ,
          cjs.summary_setup_id MAPPING_ID,
          cjs.created_date run_time,
          cjs.comments,
          cje.period
    FROM summary_setup_list ssl,
	     cont_journal_summary cjs,
	     cont_journal_entry cje
   WHERE cjs.document_key = p_document_key
     AND ssl.OBJECT_ID = cjs.summary_setup_id
     AND cjs.tag = ssl.tag
     AND cje.dataset = ssl.dataset
     AND cje.record_status IN ('A','V')
     AND cje.reversal_date is NULL
     AND cje.period = cjs.period
     AND cje.tag=ssl.tag
     AND cje.CONTRACT_CODE = ec_contract.object_code(cjs.object_id)
     AND NVL(cje.inventory_id,'XX') =NVL(ssl.inventory_id ,NVL(cje.inventory_id,'XX'))
     AND NOT EXISTS(SELECT cd.document_key FROM cont_doc cd
				     WHERE cd.preceding_document_key=cje.document_key
				       AND cd.RECORD_status IN('A','V'));

lv_connection_id        NUMBER;
BEGIN

 IF NVL(ec_ctrl_system_attribute.attribute_text(ec_cont_doc.period(p_document_key),'ENABLE_DOC_TRACING','<='),'N') = 'Y' THEN

     FOR c IN c_data LOOP

      IF (GetConnectionId('CONT_JOURNAL_SUMMARY',c.TO_document ,'CONT_JOURNAL_ENTRY',c.from_document)IS NULL) THEN

       lv_connection_id := ECDP_DATASET_FLOW.GetConnectionId('CONT_JOURNAL_SUMMARY',c.to_document,'CONT_JOURNAL_ENTRY',c.from_document);
       IF nvl(lv_connection_id,0) = 0 THEN
           Ecdp_System_Key.assignNextNumber('DATASET_FLOW_DOC_CONN',lv_connection_id);
       END IF;

       INSERT INTO DATASET_FLOW_DOC_CONN
        (
        CONNECTION_ID,
        TO_TYPE,
        TO_REFERENCE_ID,
        FROM_TYPE,
        FROM_REFERENCE_ID,
        CREATED_BY,
        CREATED_DATE
        )
        VALUES
        (
        lv_connection_id,
        'CONT_JOURNAL_SUMMARY',
        c.to_document,
        'CONT_JOURNAL_ENTRY',
        c.from_document,
        user,
        Ecdp_Timestamp.getCurrentSysdate
        );

        --Update Visual Tracing
        EcDp_Visual_Tracing.UpdateVisualTracing(c.to_document, 'CONT_JOURNAL_SUMMARY', c.period);
     END IF;

         INSERT INTO DATASET_FLOW_DETAIL_CONN
       (
       CONNECTION_ID,
       FROM_ID,
       TO_ID,
       FROM_TYPE,
       TO_TYPE,
       FROM_REFERENCE_ID,
       TO_REFERENCE_ID,
       MAPPING_TYPE,
       MAPPING_ID,
       RUN_TIME,
       DETAIL_TO_VALUE,
       COMMENTS,
       CREATED_BY,
       CREATED_DATE
       )
       VALUES
       (
       GetConnectionId('CONT_JOURNAL_SUMMARY',c.TO_document ,'CONT_JOURNAL_ENTRY',c.from_document),
       c.FROM_ID,
       c.TO_ID,
        'CONT_JOURNAL_SUMMARY',
        'CONT_JOURNAL_ENTRY',
       c.from_document,
       c.to_document,
       c.Mapping_type,
       c.MAPPING_ID ,
       Ecdp_Timestamp.getCurrentSysdate,
       'N',
       c.comments,
       user,
       Ecdp_Timestamp.getCurrentSysdate
       );
    END LOOP;
END IF;

EXCEPTION WHEN OTHERS
  THEN
  RAISE_APPLICATION_ERROR(-20000, 'Can not insert data to DATASET tables . Unknown error occurred (' || SQLCODE || ') ' || '. ' || SQLERRM);

END InsJEDataToDS;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- FUNCTION       : UpdateStatusInTables
-- Description    : Will update record status in the main table if needed
------------------------+-----------------------------------+------------------------------------+---------------------------

PROCEDURE UpdateStatusInTables(
                        p_type                              VARCHAR2,
                        p_reference_id                      VARCHAR2,
                        p_status                            VARCHAR2,
                        p_user                              VARCHAR2) IS
  BEGIN

        CASE p_type
           WHEN 'CONT_JOURNAL_ENTRY' THEN
                         -- Set record status on document and journal entry
              ecdp_rr_revn_common.SetRecordStatusOnDocument(p_reference_id, p_status, p_user, 'CONT_MAPPING_DOC');
              ecdp_rr_revn_common.SetRecordStatusOnJournalEntry(p_reference_id, p_status, p_user);
            WHEN 'CONT_JOURNAL_SUMMARY' THEN
             -- Set record status on document and journal entry
                ecdp_rr_revn_common.SetRecordStatusOnDocument(p_reference_id, p_status, p_user, 'CONT_SUMMARY_DOC');
                Ecdp_Rr_Revn_Summary.SetRecordStatusOnJournalSum(p_reference_id, p_status, p_user);
            WHEN 'IFAC_JOURNAL_ENTRY' THEN
               UPDATE IFAC_JOURNAL_ENTRY X SET RECORD_STATUS = p_status WHERE
                TO_CHAR(PERIOD,'YYYY-MM-DD')||'$'||SOURCE_DOC_NAME||'$'||SOURCE_DOC_VER = p_reference_id;
            WHEN 'REPORT_GENERATED' THEN
              NULL;
            WHEN 'CONT_DOCUMENT' THEN
                UPDATE CONT_DOCUMENT SET SET_TO_NEXT_IND = 'Y' WHERE DOCUMENT_KEY = p_reference_id;
             WHEN 'CALC_REFERENCE' THEN
                UPDATE CALC_REFERENCE X SET  ACCEPT_STATUS = p_status, RECORD_STATUS = p_status WHERE X.RUN_NO = p_reference_id;
                UPDATE ALLOC_JOB_LOG X SET ACCEPT_STATUS = p_status, RECORD_STATUS = p_status WHERE X.RUN_NO = p_reference_id;
            WHEN 'CALC_REF_TIN' THEN
                UPDATE CALC_REFERENCE X SET  ACCEPT_STATUS = p_status, RECORD_STATUS = p_status WHERE X.RUN_NO = p_reference_id;
                UPDATE ALLOC_JOB_LOG X SET  ACCEPT_STATUS = p_status,RECORD_STATUS = p_status WHERE X.RUN_NO = p_reference_id and nvl(x.exit_status,'FAILED') != 'FAILED';
            WHEN 'CALC_REF_ROY' THEN
                UPDATE CALC_REFERENCE X SET  ACCEPT_STATUS = p_status, RECORD_STATUS = p_status WHERE X.RUN_NO = p_reference_id;
                UPDATE ALLOC_JOB_LOG X SET  ACCEPT_STATUS = p_status,RECORD_STATUS = p_status WHERE X.RUN_NO = p_reference_id
                       and nvl(x.exit_status,'FAILED') != 'FAILED';
           WHEN 'CALC_REF_RRCA_REVN' THEN
                UPDATE CALC_REFERENCE X SET  ACCEPT_STATUS = p_status, RECORD_STATUS = p_status WHERE X.RUN_NO = p_reference_id;
                UPDATE ALLOC_JOB_LOG X SET  ACCEPT_STATUS = p_status,RECORD_STATUS = p_status WHERE X.RUN_NO = p_reference_id
                       and nvl(x.exit_status,'FAILED') != 'FAILED';

           WHEN 'REPORT' THEN
              UPDATE REPORT X SET  ACCEPT_STATUS = p_status, RECORD_STATUS = p_status WHERE X.REPORT_NO = p_reference_id;
              UPDATE DATASET_FLOW_REPORT X SET X.STATUS = p_status, RECORD_STATUS = p_status WHERE REPORT_NO = p_reference_id;
            ELSE
              rr_dataset_flow.UpdateStatusInTables( p_type,p_reference_id,p_status,p_user);
        END CASE;





END;


------------------------+-----------------------------------+------------------------------------+---------------------------
-- FUNCTION       : GetLastJMDoc
-- Description    : Gives latest APPROVED/VERIFIED journal mapping document for given contract,dataset and period.
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetLastJMDoc(  p_contract_id                       VARCHAR2,
                        p_dataset                           VARCHAR2,
                        p_period                            DATE
                        )
RETURN VARCHAR2
IS

CURSOR c_doc(cp_contract_id VARCHAR2, cp_dataset VARCHAR2, cp_period DATE) IS
SELECT cd1.document_key
  FROM cont_doc cd1
 WHERE cd1.document_type = 'COST_DATASET'
   AND cd1.record_status IN ('A','V')
   AND cd1.contract_id = cp_contract_id
   AND cd1.dataset = cp_dataset
   AND cd1.period = cp_period
   AND cd1.created_date = (SELECT MAX(created_date)
						     FROM cont_doc cd2
						    WHERE cd2.object_id = cd1.object_id
						      AND cd2.dataset = cd1.dataset
						      AND cd2.period = cd1.period
						      AND cd2.record_status IN ('A','V'));

lv2_ret_doc_key VARCHAR2(32) := NULL;

BEGIN

FOR rsD IN c_doc(p_contract_id, p_dataset, p_period) LOOP
  lv2_ret_doc_key := rsd.document_key;
END LOOP;

RETURN lv2_ret_doc_key;

END GetLastJMDoc;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- FUNCTION       : VerifyReference
-- Description    :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION VerifyReference(
                        p_type                              VARCHAR2,
                        p_reference_id                      VARCHAR2,
                        p_no_table_update                   BOOLEAN DEFAULT FALSE,
                        p_user                              VARCHAR2,
                        p_daytime                           DATE
                        )
RETURN VARCHAR2
IS
    lv_verify_reference                                     VARCHAR2(32);
    lv_verify_reference_pre                                 VARCHAR2(32);
    lv_verify_reference_post                                VARCHAR2(32);
    ln_Expired                                              NUMBER;
    lv_found_Items                                          VARCHAR2(1000);

BEGIN
    -- INSTEAD OF user-exit
    IF ue_Dataset_Flow.isVerifyReferenceUEE = 'TRUE' THEN
        lv_verify_reference := ue_Dataset_Flow.VerifyReference(p_type, p_reference_id);
        RETURN lv_verify_reference;
    ELSE
        -- PRE user-exit
        IF ue_Dataset_Flow.isVerifyReferencePreUEE = 'TRUE' THEN
            lv_verify_reference_pre := ue_Dataset_Flow.VerifyReferencePre(p_type, p_reference_id);
        END IF;

        if p_type like 'CALC_REF%' THEN

          --Check that there isnt a new calc run

          Select count(*) INTO ln_Expired
                 from calc_reference o,
                      calc_reference n
          where o.run_no = p_reference_id
            and o.calculation_id = n.calculation_id
            and o.run_no < n.run_no
            and o.object_id = n.object_id
            and o.calc_collection_id = n.calc_collection_id
            and o.daytime = n.daytime
            and nvl(o.accrual_ind,'N') = nvl(n.accrual_ind,'N');

          IF ln_Expired > 0 THEN
            return 'Newer Calculations runs exist for the month, calculation and object so this calculation can not be verified until they are deleted.';
          END IF;
          ecbp_replicate_sale_qty.ApproveCalc(p_reference_id);

          IF p_type = 'CALC_REF_TIN' THEN
             lv_found_Items := ecdp_trans_inventory.verifyAction(p_reference_id);
          END IF;

          IF lv_found_Items IS not NULL THEN
            return lv_found_Items;
          end if;
        END IF;

        -- If do updating status in actual table as well (not just dataset table)
        IF p_no_table_update = false THEN
           UpdateStatusInTables( p_type  ,
                        p_reference_id   ,
                        'V'         ,
                        p_user);
        END IF;

        IF NVL(ec_ctrl_system_attribute.attribute_text(p_daytime,'ENABLE_DOC_TRACING','<='),'N') = 'Y' THEN
               UpdateDSFlowTableStatus(p_type,p_reference_id,'V',p_user);
        END IF;


        -- POST user-exit
        IF ue_Dataset_Flow.isVerifyReferencePostUEE = 'TRUE' THEN
            lv_verify_reference_post := ue_Dataset_Flow.VerifyReferencePost(p_type, p_reference_id);
        END IF;

        RETURN NULL;
    END IF;

END VerifyReference;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- FUNCTION       : UnVerifyReference
-- Description    :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION UnVerifyReference(
                        p_type                              VARCHAR2,
                        p_reference_id                      VARCHAR2,
                        p_no_table_update                   BOOLEAN DEFAULT FALSE,
                        p_user                              VARCHAR2,
                        p_daytime                           DATE
                        )
RETURN VARCHAR2
IS
    lv_unverify_reference                                   VARCHAR2(32);
    lv_unverify_reference_pre                               VARCHAR2(32);
    lv_unverify_reference_post                              VARCHAR2(32);

    CURSOR usage(cp_type varchar2,
                 cp_reference_id VARCHAR2) is

    SELECT DISTINCT to_reference_id ref_id, to_type type
      FROM dataset_flow_doc_conn dfdc
     WHERE dfdc.from_reference_id = cp_reference_id
       AND dfdc.from_type = cp_type
       AND (from_reference_id != to_reference_id OR
           dfdc.from_type != dfdc.to_type);


    cursor CreatedDocs(cp_run_no number) is
    select distinct document_key,transaction_key
      from cont_transaction
     where calc_run_no = cp_run_no;


    lv_found_Items VARCHAR2(4000);
    lv_msg         VARCHAR2(4000);
    ln_ifac_entries NUMBER;
    ln_report_entries NUMBER;
BEGIN
    -- INSTEAD OF user-exit
    IF ue_Dataset_Flow.isUnVerifyReferenceUEE = 'TRUE' THEN
        lv_unverify_reference := ue_Dataset_Flow.UnVerifyReference(p_type, p_reference_id);
        RETURN lv_unverify_reference;
    ELSE
        -- PRE user-exit
        IF ue_Dataset_Flow.isUnVerifyReferencePreUEE = 'TRUE' THEN
            lv_msg := ue_Dataset_Flow.UnVerifyReferencePre(p_type, p_reference_id);
        END IF;

        -----------------------------------------------------------------------------
        -- Content Section
        -----------------------------------------------------------------------------

       IF CheckIfMax( p_type  ,
                        p_reference_id) = 'N' THEN
           lv_msg := 'The document you are trying to change the status on is not the most current you must remove the newer document before setting this document back to provisional.';
       END IF;

        IF NVL(ec_ctrl_system_attribute.attribute_text(p_daytime,'ENABLE_DOC_TRACING','<='),'N') != 'Y' THEN
                IF p_no_table_update = false THEN
                   UpdateStatusInTables( p_type  ,
                                p_reference_id   ,
                                'P'       ,
                                p_user);
                END IF;
        ELSE

               IF lv_msg IS NULL THEN




                      FOR item in usage(p_type,p_reference_id) LOOP

                        IF item.type = 'CONTRACT_ACCOUNT' THEN


                           SELECT COUNT(*) INTO ln_ifac_entries
                           FROM IFAC_SALES_QTY WHERE TO_CHAR(CALC_RUN_NO) = p_reference_id
                           AND nvl(IGNORE_IND,'N')='N' AND ALLOC_no_MAX_IND = 'Y' AND TRANSACTION_KEY IS NULL;

                           IF ln_ifac_entries > 0 THEN
                              IF LENGTH(lv_found_Items) >0 THEN
                                  lv_found_Items := ' ';
                              END IF;
                                lv_found_Items := lv_found_Items || 'Ifac entries are pending for contract accounts. '|| CHR(10) ||
                                               ' You must first generate the documents then choose delete (no recreate) to remove them from pending.' || chr(10)
                                               || ' before you can unverify this document';
                          /* ELSE
                               FOR doc in CreatedDocs(p_reference_id) LOOP

                                lv_found_Items := lv_found_Items || doc.document_key || '[' || doc.transaction_key ||']';

                               END LOOP;
                               */
                           END IF;
                        ELSIF  item.type = 'CONT_JOURNAL_SUMMARY' AND p_type LIKE 'CALC_REF%' THEN
                               --Take no action if calculation wrote to a extract
                               NULL;
                        ELSIF  item.type = 'REPORT' AND p_type LIKE 'CALC_REF%' THEN
                               SELECT COUNT(*)
                               INTO ln_report_entries
                               FROM dataset_flow_report WHERE TO_CHAR(run_no) = p_reference_id and record_status in ('A','V');

                               IF ln_report_entries > 0 THEN
                                 lv_found_Items := ' You can not unverify the Calculation without setting any generated reports to Provisional first.';
                               END IF;
                        ELSE

                            IF LENGTH(lv_found_Items) >0 THEN
                              lv_found_Items := ', ';
                            END IF;

                              if item.type LIKE 'CALC_REF%' THEN



                                 lv_found_Items := lv_found_Items || EC_CALC_REFERENCE.reference_id(item.ref_id) ||
                                                 '[' || ec_calculation_version.name(ec_calc_reference.calculation_id(item.ref_id),
                                                     ec_calc_reference.daytime(item.ref_id),'<=')
                                                   ||']';

                              ELSE

                                 lv_found_Items := lv_found_Items || item.ref_id || '[' || EcDp_ClassMeta_Cnfg.getLabel(item.type) ||']';
                              END IF;
                        END IF;

                      END LOOP;


                      IF LENGTH(lv_found_Items) >0 THEN
                        lv_msg := 'You can not unverify this document at this time.' || chr(10) ||
                                   'You must first delete documents where values on this document have been pulled.' ||
                                   chr(10) ||lv_found_Items;
                      ELSIF p_type = 'CALC_REF_TIN' THEN
                            lv_msg := ecdp_trans_inventory.unverifyAction(p_reference_id);
                      END IF;


                      IF lv_msg IS NULL THEN




                            -- If do updating status in actual table as well (not just dataset table)
                            IF p_no_table_update = false THEN
                               UpdateStatusInTables( p_type  ,
                                            p_reference_id   ,
                                            'P'       ,
                                            p_user);
                            END IF;

                            UpdateDSFlowTableStatus(p_type,p_reference_id,'P',p_user);
                      END IF;
            END IF;
        END IF;
        -----------------------------------------------------------------------------
        -- End Content Section
        -----------------------------------------------------------------------------

        -- POST user-exit
        IF lv_msg IS NULL AND ue_Dataset_Flow.isUnVerifyReferencePostUEE = 'TRUE' THEN
            lv_unverify_reference_post := ue_Dataset_Flow.UnVerifyReferencePost(p_type, p_reference_id);
        END IF;


        RETURN lv_msg;
    END IF;
END UnVerifyReference;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- FUNCTION       : ApproveReference
-- Description    :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION ApproveReference(
                        p_type                              VARCHAR2,
                        p_reference_id                      VARCHAR2,
                        p_no_table_update                   BOOLEAN DEFAULT FALSE,
                        p_user                              VARCHAR2,
                        p_daytime                           DATE
                        )
RETURN VARCHAR2
IS
    lv_approve_reference                                    VARCHAR2(32);
    lv_approve_reference_pre                                VARCHAR2(32);
    lv_approve_reference_post                               VARCHAR2(32);
    lv_return_msg                                           VARCHAR2(2000);

    CURSOR SourceItems (cp_type VARCHAR2,
                        cp_reference_id VARCHAR2) IS
                        select from_type,
                               from_reference_id
                          FROM DATASET_FLOW_DOC_CONN
                         WHERE TO_TYPE = cp_type
                           AND TO_REFERENCE_ID = cp_reference_id
                           AND (from_type != 'CALC_REF_ROY' OR to_type != 'CONT_JOURNAL_SUMMARY');



BEGIN

    -- INSTEAD OF user-exit
    IF ue_Dataset_Flow.isApproveReferenceUEE = 'TRUE' THEN
        lv_approve_reference := ue_Dataset_Flow.ApproveReference(p_type, p_reference_id);
        RETURN lv_approve_reference;
    ELSE

        -- PRE user-exit
        IF ue_Dataset_Flow.isApproveReferencePreUEE = 'TRUE' THEN
            lv_approve_reference_pre := ue_Dataset_Flow.ApproveReferencePre(p_type, p_reference_id);
        END IF;

     -----------------------------------------------------------------------------
        -- Content Section
        -----------------------------------------------------------------------------
     IF NVL(ec_ctrl_system_attribute.attribute_text(p_daytime,'ENABLE_DOC_TRACING','<='),'N') != 'Y' THEN
              IF p_no_table_update = false THEN
                 UpdateStatusInTables( p_type  ,
                              p_reference_id   ,
                              'A'         ,
                              p_user);
              END IF;

     ELSE


            -- This will set all the children items to approved
            FOR c_children in SourceItems(p_type,p_reference_id) LOOP

              IF ec_dataset_flow_document.status(c_children.from_type,c_children.from_reference_id) IN ( 'V','D') THEN

                      lv_return_msg := Approvereference(c_children.from_type,
                                                        c_children.from_reference_id,
                                                        false,
                                                        p_user,
                                                        p_daytime);
              END IF;
            END LOOP;


             -- Ifac is only inserted once Approved
              CASE p_type
                WHEN 'IFAC_JOURNAL_ENTRY' THEN

                   if ec_dataset_flow_document.status(p_type,p_reference_id) IS NULL THEN
                   EcDp_DATASET_FLOW.InsToDsFlowDoc('IFAC_JOURNAL_ENTRY',
                                 TO_DATE(SUBSTR(p_reference_id,0,instr(p_reference_id,'$')-1),'YYYY-MM-DD'),
                                 SUBSTR(p_reference_id,
                                        instr(p_reference_id,'$')+1,
                                        instr(p_reference_id,'$',instr(p_reference_id,'$')+2)-
                                        instr(p_reference_id,'$')-1 ),
                                  p_reference_id, 'A', 'Y',NULL,NULL);

                   END IF;
               ELSE
                  NULL;
               END CASE;

              -- If do updating status in actual table as well (not just dataset table)
              IF p_no_table_update = false THEN
                 UpdateStatusInTables( p_type  ,
                              p_reference_id   ,
                              'A'         ,
                              p_user);
              END IF;

              if nvl(ec_dataset_flow_document.status(p_type,p_reference_id),'x') != 'D' THEN

                 UpdateDSFlowTableStatus(p_type,p_reference_id,'A',p_user);
              end if;
        END IF;
        -----------------------------------------------------------------------------
        -- End Content Section
        -----------------------------------------------------------------------------




        -- POST user-exit
        IF ue_Dataset_Flow.isApproveReferencePostUEE = 'TRUE' THEN
            lv_approve_reference_post := ue_Dataset_Flow.ApproveReferencePost(p_type, p_reference_id);
        END IF;

        RETURN NULL;
    END IF;
END ApproveReference;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- FUNCTION       : UnApproveReference
-- Description    :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION UnApproveReference(
                        p_type                              VARCHAR2,
                        p_reference_id                      VARCHAR2,
                        p_no_table_update                   BOOLEAN DEFAULT FALSE,
                        p_user                              VARCHAR2,
                        p_daytime                           DATE
                        )
RETURN VARCHAR2
IS
    lv_unapprove_reference                                  VARCHAR2(32);
    lv_unapprove_reference_pre                              VARCHAR2(32);
    lv_unapprove_reference_post                             VARCHAR2(32);
    lv_status                                               VARCHAR2(2):='V';
    lv_found_Items VARCHAR2(4000);
    lv_msg         VARCHAR2(4000);

    CURSOR usage(cp_type varchar2,
                 cp_reference_id VARCHAR2) is

     SELECT DISTINCT
            to_reference_id ref_id,
            to_type type
       FROM dataset_flow_doc_conn dfdc
      WHERE dfdc.from_reference_id = cp_reference_id
        AND dfdc.from_type = cp_type;


BEGIN
    -- INSTEAD OF user-exit
    IF ue_Dataset_Flow.isUnApproveReferenceUEE = 'TRUE' THEN
        lv_unapprove_reference := ue_Dataset_Flow.UnApproveReference(p_type, p_reference_id);
        RETURN lv_unapprove_reference;
    ELSE
        -- PRE user-exit
        IF ue_Dataset_Flow.isUnApproveReferencePreUEE = 'TRUE' THEN
            lv_msg := ue_Dataset_Flow.UnApproveReferencePre(p_type, p_reference_id);
        END IF;


        -----------------------------------------------------------------------------
        -- Content Section
        -----------------------------------------------------------------------------
     IF NVL(ec_ctrl_system_attribute.attribute_text(p_daytime,'ENABLE_DOC_TRACING','<='),'N') != 'Y' THEN


           IF p_no_table_update = false THEN
               UpdateStatusInTables( p_type  ,
                            p_reference_id   ,
                            lv_status         ,
                            p_user);
            END IF;




        ELSE
                IF lv_msg IS NULL THEN

                          -- Ifac is inserted during approval and needs removal during unapproval
                          CASE p_type
                            WHEN 'IFAC_JOURNAL_ENTRY' THEN
                                lv_status := 'P';

                                FOR item in usage(p_type,p_reference_id) LOOP
                                  IF LENGTH(lv_found_Items) >0 THEN
                                    lv_found_Items := ', ';
                                  END IF;
                                  lv_found_Items := lv_found_Items || item.ref_id || '[' || EcDp_ClassMeta_Cnfg.getLabel(item.type) ||']';
                                END LOOP;

                                IF LENGTH(lv_found_Items) >0 THEN
                                  lv_msg := 'Can not un-approve at this time found items must first be deleted:' ||lv_found_Items;
                                END IF;

                           ELSE
                               NULL;
                           END CASE;


                          IF lv_msg is null then
                          -- If updating status in actual table as well (not just dataset table)
                                IF p_no_table_update = false THEN
                                   UpdateStatusInTables( p_type  ,
                                                p_reference_id   ,
                                                lv_status         ,
                                                p_user);
                                END IF;


                                UpdateDSFlowTableStatus(p_type,p_reference_id,lv_status,p_user);


                               if lv_msg is null then

                                     DELETE FROM DATASET_FLOW_DOCUMENT WHERE
                                            TYPE = 'IFAC_JOURNAL_ENTRY'
                                            AND REFERENCE_ID = p_reference_id
                                            AND OBJECT = SUBSTR(p_reference_id,
                                                          instr(p_reference_id,'$')+1,
                                                          instr(p_reference_id,'$',instr(p_reference_id,'$')+2)-
                                                          instr(p_reference_id,'$')-1 )
                                            AND PROCESS_DATE = TO_DATE(SUBSTR(p_reference_id,0,instr(p_reference_id,'$')-1),'YYYY-MM-DD');
                                           lv_status := 'P';
                                     --delete from visual tracing
                                     delete from visual_tracing where
                                            TYPE = 'IFAC_JOURNAL_ENTRY'
                                            and REFERENCE_ID = p_reference_id;
                                     delete from visual_tracing where
                                            HIGHLIGHT_ENTITY_TYPE = 'IFAC_JOURNAL_ENTRY'
                                            and HIGHLIGHT_ENTITY = p_reference_id;


                               END IF;

                          END IF;
                END IF;
        END IF;
        -----------------------------------------------------------------------------
        -- End Content Section
        -----------------------------------------------------------------------------

        -- POST user-exit
        IF lv_msg IS NULL AND ue_Dataset_Flow.isUnApproveReferencePostUEE = 'TRUE' THEN
            lv_msg := ue_Dataset_Flow.UnApproveReferencePost(p_type, p_reference_id);
        END IF;

        RETURN lv_msg;
    END IF;
END UnApproveReference;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- PROCEDURE      : Delete
-- Description    :
------------------------+-----------------------------------+------------------------------------+---------------------------
PROCEDURE Delete(
                        p_type                              VARCHAR2,
                        p_doc_id                            VARCHAR2,
                        p_object_id                         VARCHAR2,
                        p_clean                             VARCHAR2 DEFAULT 'Y'
                        ) is
       lv_msg VARCHAR2(4000);
BEGIN
    lv_msg := ecdp_dataset_flow.DELETE(p_type,p_doc_id, p_object_id,p_clean);

END;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- FUNCTION       : Delete
-- Description    :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION Delete(p_type      VARCHAR2,
                p_doc_id    VARCHAR2,
                p_object_id VARCHAR2,
                p_clean     VARCHAR2 DEFAULT 'Y') RETURN VARCHAR2
IS
    lv_delete                                               VARCHAR2(32);
    lv_delete_pre                                           VARCHAR2(32);
    lv_delete_post                                          VARCHAR2(32);


    cursor cr_calc_extract_qty(p_calc_run_no VARCHAR2) is
       SELECT *
         FROM cont_journal_summary cjs
        WHERE NVL(TO_CHAR(TO_NUMBER(cjs.update_ref_id_qty)),-1) = p_calc_run_no;

    cursor cr_calc_extract_amount(p_calc_run_no VARCHAR2) is
       SELECT *
         FROM cont_journal_summary cjs
        WHERE NVL(TO_CHAR(TO_NUMBER(cjs.update_ref_id_amount)),-1) = p_calc_run_no;

    cursor extract_jn_qty(p_calc_run_no VARCHAR2,
                          p_document_key VARCHAR2,
                          p_list_item_key VARCHAR2) is
       SELECT *
         FROM cont_journal_summary_jn cjsj
        WHERE document_key = p_document_key
          AND cjsj.list_item_key = p_list_item_key
          AND (cjsj.jn_datetime ) in
              (select max(jn_datetime)
                 from cont_journal_summary_jn
                where NVL(TO_CHAR(TO_NUMBER(update_ref_id_qty)),-1) != p_calc_run_no
                  and document_key = cjsj.document_key
                  and list_item_key = cjsj.list_item_key);

    cursor extract_jn_amount(p_calc_run_no VARCHAR2,
                          p_document_key VARCHAR2,
                          p_list_item_key VARCHAR2) is
       SELECT *
         FROM cont_journal_summary_jn cjsj
        WHERE document_key = p_document_key
          AND list_item_key = p_list_item_key
          AND jn_datetime  =
              (select max(jn_datetime)
                 from cont_journal_summary_jn
                where NVL(TO_CHAR(TO_NUMBER(update_ref_id_amount)),-1) != p_calc_run_no
                  and document_key = cjsj.document_key
                  and list_item_key = cjsj.list_item_key);


    CURSOR cr_cntr_acc_trans(p_run_no varchar2) is
             SELECT *
               FROM cntr_acc_period_status caps
             WHERE caps.calc_run_no = p_run_no;

    CURSOR cr_cntr_acc_vend(p_run_no varchar2) is
             SELECT *
               FROM cntracc_per_pc_cpy_status caps
             WHERE caps.calc_run_no = p_run_no;

    CURSOR cr_cntr_acc_pc(p_run_no varchar2) is
             SELECT *
               FROM cntracc_per_pc_cpy_status caps
             WHERE caps.calc_run_no = p_run_no;

      cursor cntacc_trans_jn (p_calc_run_no VARCHAR2,
                          p_contract_id VARCHAR2,
                          p_account_code VARCHAR2,
                          p_time_span VARChAR2,
                          p_daytime   DATE) is
       SELECT *
         FROM cntr_acc_period_status_jn ca
        WHERE object_id = p_contract_id
          AND account_code = p_account_code
          AND time_span = p_time_span
          AND daytime = p_daytime
          AND calc_run_no != p_calc_run_no
          AND (jn_datetime ) =
              (select max(jn_datetime)
                 from cont_journal_summary_jn X
                where calc_run_no != ca.calc_run_no
                  AND object_id = ca.object_id
                  AND account_code = ca.account_code
                  AND time_span = ca.time_span
                  AND daytime = ca.daytime);

      cursor cntacc_pc_jn (p_calc_run_no VARCHAR2,
                          p_contract_id VARCHAR2,
                          p_profit_center VARCHAR2,
                          p_account_code VARCHAR2,
                          p_time_span VARChAR2,
                          p_daytime   DATE) is
       SELECT *
         FROM cntracc_period_pc_status_jn ca
        WHERE object_id = p_contract_id
          AND account_code = p_account_code
          AND time_span = p_time_span
          AND profit_centre_id = p_profit_center
          AND daytime = p_daytime
          AND calc_run_no != p_calc_run_no
          AND (jn_datetime ) =
              (select max(jn_datetime)
                 from cntracc_period_pc_status_jn X
                where calc_run_no != ca.calc_run_no
                  AND object_id = ca.object_id
                  AND profit_centre_id = ca.profit_centre_id
                  AND account_code = ca.account_code
                  AND time_span = ca.time_span
                  AND daytime = ca.daytime);

      cursor cntacc_vend_jn (p_calc_run_no VARCHAR2,
                          p_contract_id VARCHAR2,
                          p_profit_center VARCHAR2,
                          p_company VARCHAR2,
                          p_account_code VARCHAR2,
                          p_time_span VARChAR2,
                          p_daytime   DATE) is
       SELECT *
         FROM cntracc_per_pc_cpy_status_jn ca
        WHERE object_id = p_contract_id
          AND account_code = p_account_code
          AND time_span = p_time_span
          AND daytime = p_daytime
          AND company_id = p_company
          AND profit_centre_id = p_profit_center
          AND calc_run_no != p_calc_run_no
          AND (jn_datetime ) =
              (select max(jn_datetime)
                 from cntracc_per_pc_cpy_status_jn X
                where calc_run_no != ca.calc_run_no
                  AND object_id = ca.object_id
                  AND profit_centre_id = ca.profit_centre_id
                  AND company_id = ca.company_id
                  AND account_code = ca.account_code
                  AND time_span = ca.time_span
                  AND daytime = ca.daytime);
     lv_status VARCHAR2(32);
     ln_report_entries NUMBER;
BEGIN
    -- INSTEAD OF user-exit
    IF ue_Dataset_Flow.isDeleteUEE = 'TRUE' THEN
        lv_delete := ue_Dataset_Flow.Delete(p_type, p_doc_id, p_object_id);
        RETURN lv_delete;
    ELSE
        -- PRE user-exit
        IF ue_Dataset_Flow.isDeletePreUEE = 'TRUE' THEN
            lv_delete_pre := ue_Dataset_Flow.DeletePre(p_type, p_doc_id, p_object_id);
        END IF;

        lv_status := GetStatusinTable(p_type , p_doc_id );

        IF lv_status IN ('A','V') THEN
           Raise_application_error(-20001,'The document can not be deleted when in Verified or Approved state.' );
        END IF;

        IF p_type LIKE 'CALC_REF%' THEN
            SELECT COUNT(*)
            INTO ln_report_entries
            FROM dataset_flow_report WHERE TO_CHAR(run_no) = p_doc_id;
            IF ln_report_entries > 0 THEN
               Raise_application_error(-20002,'Please delete the associated reports first.' );
            END IF;
        END IF;

        DELETE FROM DATASET_FLOW_DETAIL
         WHERE ID IN
               (SELECT FROM_ID
                  FROM DATASET_FLOW_DETAIL_CONN
                 WHERE CONNECTION_ID IN
                       (SELECT ID
                          FROM DATASET_FLOW_DOC_CONN
                         WHERE TO_TYPE = p_type
                           AND TO_REFERENCE_ID = p_doc_id));

       DELETE FROM DATASET_FLOW_DETAIL_CONN X
         WHERE CONNECTION_ID IN
               (SELECT CONNECTION_ID
                  FROM DATASET_FLOW_DOC_CONN
                 WHERE TO_TYPE = p_type
                   AND TO_REFERENCE_ID = p_doc_id);

        DELETE FROM DATASET_FLOW_DOC_CONN
         WHERE TO_TYPE = p_type
           AND TO_REFERENCE_ID = p_doc_id;

-- Logic for FROM_TYPE like 'CALC_REF_ROY' or starting with 'CALC_REF'
        DELETE FROM DATASET_FLOW_DETAIL
         WHERE ID IN
               (SELECT FROM_ID
                  FROM DATASET_FLOW_DETAIL_CONN
                 WHERE CONNECTION_ID IN
                       (SELECT ID
                          FROM DATASET_FLOW_DOC_CONN
                          WHERE TO_TYPE = 'CONT_JOURNAL_SUMMARY'
                               AND FROM_TYPE = p_type
                               AND FROM_REFERENCE_ID = p_doc_id
                               AND FROM_TYPE like 'CALC_REF%'));

       DELETE FROM DATASET_FLOW_DETAIL_CONN X
         WHERE CONNECTION_ID IN
               (SELECT CONNECTION_ID
                  FROM DATASET_FLOW_DOC_CONN
                  WHERE TO_TYPE = 'CONT_JOURNAL_SUMMARY'
                         AND FROM_TYPE = p_type
                         AND FROM_REFERENCE_ID = p_doc_id
                         AND FROM_TYPE like 'CALC_REF%');

        DELETE FROM DATASET_FLOW_DOC_CONN
         WHERE TO_TYPE = 'CONT_JOURNAL_SUMMARY'
               AND FROM_TYPE = p_type
               AND FROM_REFERENCE_ID = p_doc_id
               AND FROM_TYPE like 'CALC_REF%';


        DELETE FROM DATASET_FLOW_DOC_NOTE
         WHERE TYPE = p_type
           AND REFERENCE_ID = p_doc_id;

      IF p_clean = 'Y' THEN
        DELETE FROM DATASET_FLOW_DOCUMENT
         WHERE TYPE = p_type
           and REFERENCE_ID = p_doc_id;
      END IF;


       IF p_type LIKE 'CALC_REF%' THEN
         FOR extract_qty in cr_calc_extract_qty(p_doc_id) LOOP
             FOR extract_jn in extract_jn_qty(p_doc_id,extract_qty.document_key,extract_qty.list_item_key ) LOOP
                 UPDATE CONT_JOURNAL_SUMMARY cjs
                    SET cjs.pre_update_qty1=extract_jn.pre_update_qty1,
                        cjs.actual_qty_1=extract_jn.actual_qty_1,
                        cjs.update_ref_id_qty=extract_jn.update_ref_id_qty
                  WHERE cjs.document_key = extract_jn.document_key
                    AND cjs.list_item_key = extract_jn.list_item_key;
                 exit;
             END LOOP;
         END LOOP;


         FOR extract_qty in cr_calc_extract_amount(p_doc_id) LOOP
             FOR extract_jn in extract_jn_amount(p_doc_id,extract_qty.document_key,extract_qty.list_item_key ) LOOP
                 UPDATE CONT_JOURNAL_SUMMARY cjs
                    SET cjs.pre_update_AMOUNT=extract_jn.pre_update_AMOUNT,
                        cjs.actual_AMOUNT=extract_jn.actual_AMOUNT,
                        cjs.update_ref_id_amount=extract_jn.update_ref_id_amount
                  WHERE cjs.document_key = extract_jn.document_key
                    AND cjs.list_item_key = extract_jn.list_item_key;
                 exit;
             END LOOP;
         END LOOP;


         FOR cntr_acc IN cr_cntr_acc_trans(p_doc_id) LOOP
             FOR ca in cntacc_trans_jn(p_doc_id,cntr_acc.object_id,cntr_acc.account_code,cntr_acc.time_span,cntr_acc.daytime ) LOOP
                 UPDATE CNTR_ACC_PERIOD_STATUS
                    SET vol_qty = ca.vol_qty,
                        mass_qty = ca.mass_qty,
                        energy_qty = ca.energy_qty,
                        x1_qty = ca.x1_qty,
                        x2_qty = ca.x2_qty,
                        x3_qty = ca.x3_qty,
                        amount = ca.amount,
                        calc_run_no = ca.calc_run_no
                  WHERE object_id = ca.object_id
                    AND account_code = ca.account_code
                    AND time_span = ca.time_span
                    AND daytime = ca.daytime;
                 exit;
             END LOOP;
         END LOOP;

         FOR cntr_acc IN cr_cntr_acc_pc(p_doc_id) LOOP
             FOR ca in cntacc_pc_jn(p_doc_id,
                                    cntr_acc.object_id,
                                    cntr_acc.profit_centre_id,
                                    cntr_acc.account_code,
                                    cntr_acc.time_span,
                                    cntr_acc.daytime ) LOOP
                 UPDATE CNTRACC_PERIOD_PC_STATUS
                    SET vol_qty = ca.vol_qty,
                        mass_qty = ca.mass_qty,
                        energy_qty = ca.energy_qty,
                        x1_qty = ca.x1_qty,
                        x2_qty = ca.x2_qty,
                        x3_qty = ca.x3_qty,
                        amount = ca.amount,
                        calc_run_no = ca.calc_run_no
                  WHERE object_id = ca.object_id
                    AND account_code = ca.account_code
                    AND time_span = ca.time_span
                    AND profit_centre_id = ca.profit_centre_id
                    AND daytime = ca.daytime;
                 exit;
             END LOOP;
         END LOOP;

         FOR cntr_acc IN cr_cntr_acc_vend(p_doc_id) LOOP
             FOR ca in cntacc_vend_jn(p_doc_id,
                                    cntr_acc.object_id,
                                    cntr_acc.profit_centre_id,
                                    cntr_acc.company_id,
                                    cntr_acc.account_code,
                                    cntr_acc.time_span,
                                    cntr_acc.daytime ) LOOP
                 UPDATE CNTRACC_PER_PC_CPY_STATUS
                    SET vol_qty = ca.vol_qty,
                        mass_qty = ca.mass_qty,
                        energy_qty = ca.energy_qty,
                        x1_qty = ca.x1_qty,
                        x2_qty = ca.x2_qty,
                        x3_qty = ca.x3_qty,
                        amount = ca.amount,
                        calc_run_no = ca.calc_run_no
                  WHERE object_id = ca.object_id
                    AND account_code = ca.account_code
                    AND time_span = ca.time_span
                    AND company_id = ca.company_id
                    AND profit_centre_id = ca.profit_centre_id
                    AND daytime = ca.daytime;
                 exit;
             END LOOP;
         END LOOP;

       END IF;

       rr_dataset_flow.delete(p_type,p_doc_id,p_object_id,p_clean,lv_status);
       --delete from visual tracing
       delete from visual_tracing where
              TYPE = p_type
              and REFERENCE_ID = p_doc_id;
       delete from visual_tracing where
              HIGHLIGHT_ENTITY_TYPE = p_type
              and HIGHLIGHT_ENTITY = p_doc_id;

        -- POST user-exit
        IF ue_Dataset_Flow.isDeletePostUEE = 'TRUE' THEN
            lv_delete_post := ue_Dataset_Flow.DeletePost(p_type, p_doc_id, p_object_id);
        END IF;

        RETURN NULL;
    END IF;
END Delete;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- FUNCTION       : UpdateDocFlowStatus
-- Description    : Function that should do the updating of records based on the variables passed
------------------------+-----------------------------------+------------------------------------+---------------------------
PROCEDURE UpdateDocFlowStatus(
                        p_type                              VARCHAR2,
                        p_reference_id                      VARCHAR2,
                        p_status                            VARCHAR2,
                        p_user                              VARCHAR2,
                        p_no_table_update                   BOOLEAN DEFAULT FALSE,
                        p_old_status                        VARCHAR2 DEFAULT NULL,
                        p_allow_unapprove                   BOOLEAN DEFAULT FALSE
                        ) IS
lv_msg VARCHAR2(4000);

BEGIN
     lv_msg :=     UpdateDocFlowStatus(
                        p_type                              ,
                        p_reference_id                      ,
                        p_status                            ,
                        p_user                              ,
                        p_no_table_update                   ,
                        p_old_status                        ,
                        p_allow_unapprove
                        );

END;

FUNCTION UpdateDocFlowStatus(
                        p_type                              VARCHAR2,
                        p_reference_id                      VARCHAR2,
                        p_status                            VARCHAR2,
                        p_user                              VARCHAR2,
                        p_no_table_update                   BOOLEAN DEFAULT FALSE,
                        p_old_status                        VARCHAR2 DEFAULT NULL,
                        p_allow_unapprove                   BOOLEAN DEFAULT FALSE
                        )
RETURN VARCHAR2
IS


    lv_status                                               VARCHAR2(32);
    lv_return_msg                                           VARCHAR2(2000);
    lv_activity                                            VARCHAR2(32);
    ld_daytime                                             date;
BEGIN
    --An empty return message means success.
    lv_return_msg := '';

    ld_daytime := nvl(ec_dataset_flow_document.process_date(p_type,p_reference_id),sysdate);
    IF p_old_status IS NOT NULL THEN
      lv_status := p_old_status;
    ELSE

      lv_status := GetStatusinTable(p_type,p_reference_id);
    END IF;

    IF p_type = 'REPORT' AND ec_report.status(p_reference_id) = 'ERROR' THEN

		   RAISE_APPLICATION_ERROR(-20001,'Reports with generated status as ''ERROR'' cannot be set to verified or un-verified.');

	  END IF ;

    IF lv_status = 'NO_REPORT' THEN
      lv_return_msg := 'There is not yet a report Connected. Status can only be done on Generated reports.';
    END IF;

    IF p_status = lv_status THEN

      lv_return_msg := 'No Update possible as the document is already in state requested.';

      case p_status
        WHEN 'A' THEN
              lv_activity := 'APPROVE';
        ELSE
          lv_activity := 'VERIFY';
        END CASE;

    END IF;


    --Determine how to handle the current status
    IF p_status = 'A' AND (lv_status = 'V' or p_type = 'IFAC_JOURNAL_ENTRY') THEN

        lv_return_msg := ApproveReference(p_type, p_reference_id,p_no_table_update,p_user,ld_daytime);
          lv_activity := 'APPROVE';
    END IF;
    IF p_status = 'A' AND lv_status = 'P' and p_type != 'IFAC_JOURNAL_ENTRY' THEN
        lv_return_msg := 'Not able to approve. Need to be verified first. Current status is provisional.';
    END IF;
    IF p_status = 'V' AND lv_status = 'A' then
      if p_allow_unapprove = true THEN
        lv_return_msg := UnApproveReference(p_type, p_reference_id,p_no_table_update,p_user,ld_daytime);
          lv_activity := 'UN-APPROVE';
      ELSE
        lv_return_msg := 'It is not possible to unapprove the document from this screen.';
        lv_activity := 'VERIFY';
      END IF;

    END IF;
    IF p_status = 'V' AND lv_status = 'P' THEN

        lv_return_msg := VerifyReference(p_type, p_reference_id,p_no_table_update,p_user,ld_daytime);
          lv_activity := 'VERIFY';
    END IF;

    IF p_status = 'P' AND lv_status = 'A' THEN
       if p_allow_unapprove = true or p_type = 'IFAC_JOURNAL_ENTRY' THEN
          lv_activity := 'UN-APPROVE';

          lv_return_msg := UnApproveReference(p_type, p_reference_id,p_no_table_update,p_user,ld_daytime);
          IF nvl(lv_return_msg,'NULL') = 'NULL' THEN
              lv_return_msg := UnVerifyReference(p_type, p_reference_id,p_no_table_update,p_user,ld_daytime);
          END IF;
        ELSE
          lv_return_msg := 'It is not possible to unapprove the document from this screen.';
          lv_activity := 'VERIFY';
        END IF;
    END IF;


    IF p_status = 'P' AND lv_status = 'V' THEN

        lv_activity := 'UN-VERIFY';
         lv_return_msg := UnVerifyReference(p_type, p_reference_id,p_no_table_update,p_user,ld_daytime);
    END IF;


       IF NVL(ec_ctrl_system_attribute.attribute_text(ld_daytime,'ENABLE_DOC_TRACING','<='),'N') = 'Y' THEN


              update DATASET_FLOW_DOC_NOTE x
                 SET CLOSED_IND = 'Y'
               WHERE TYPE = p_type
                 AND x.reference_id = p_reference_id
                 AND ACTIVITY = lv_activity;


                IF lv_return_msg IS NOT NULL THEN

                    INSERT INTO DATASET_FLOW_DOC_NOTE x
                      (CLOSED_IND, TYPE, reference_id, ACTIVITY, NOTE, ID, ONE_TIME_MSG)
                    VALUES
                      ('N', p_type, p_reference_id, lv_activity, lv_return_msg, ecdp_system_key.assignNextKeyValue('DATASET_FLOW_DOC_NOTE'), 'Y' );

                END IF;
    ELSIF lv_return_msg IS NOT NULL THEN
      RAISE_APPLICATION_ERROR(-20001, lv_return_msg);
    END IF;

    RETURN lv_return_msg;
END UpdateDocFlowStatus;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- FUNCTION       : GetStatusMessage
-- Description    :
------------------------+-----------------------------------+------------------------------------+---------------------------

procedure UpdateOneTime(p_DocumentKey                       VARCHAR2,
                        p_status                            VARCHAR2,
                        p_type                              VARCHAR2,
                        p_msg                               VARCHAR2
                       )
IS PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

        UPDATE DATASET_FLOW_DOC_NOTE SET CLOSED_IND= 'Y'
        WHERE REFERENCE_ID = p_DocumentKey
         AND NVL(CLOSED_IND,'N') = 'N'
         and p_type = type
         and NOTE = p_msg
         AND replace(activity,'UN-','') = replace(p_status,'UN-','') ;
         commit;
END;

FUNCTION GetStatusMessage(
                        p_DocumentKey                       VARCHAR2,
                        p_status                            VARCHAR2,
                        p_type                              VARCHAR2
                        )
RETURN VARCHAR2
IS

    lv_msg VARCHAR2(2000);
    lv_return VARCHAR2(2000);
    lv_one_time VARCHAR2(1);

    BEGIN


      SELECT MAX(NOTE), MAX(ONE_TIME_MSG)
        INTO lv_msg, lv_one_time
        FROM DATASET_FLOW_DOC_NOTE
       WHERE REFERENCE_ID = p_DocumentKey
         AND NVL(CLOSED_IND,'N') != 'Y'
         and p_type = type
         AND replace(activity,'UN-','') = replace(p_status,'UN-','')
         ;

      lv_return := lv_msg;
      IF nvl(lv_one_time,'N') = 'Y' and lv_msg is not null THEN

        UpdateOneTime(p_DocumentKey    ,
                        p_status       ,
                        p_type,
                        lv_msg);

      END IF;
      if lv_return is not null then
        lv_return := 'Error!' || CHR(10) || lv_return ;
      end if;
      RETURN nvl(lv_return,'Updated Status');

END;



------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure       : InsertIfacToDoc
-- Description     : Called by ecdp_document_gen.trace during financial document processing to provide trace information.
--                   p_reference contain line item key + profit center ID + vendor ID depending of which level interface is done at.
------------------------+-----------------------------------+------------------------------------+---------------------------
PROCEDURE InsertIfacToDoc(p_calc_run_no NUMBER,
                          p_contract_account_class VARCHAR2,
                          p_contract_account VARCHAR2,
                          p_reference VARCHAR2,
                          p_daytime         VARCHAR2) IS

 lv_context_code          VARCHAR2(32);
 ln_connection_id         NUMBER;
 lv_document_key          VARCHAR(32);
 lv_line_item_key         cont_line_item.line_item_key%type;
 lv_transaction_key       cont_transaction.transaction_key%type;
 lv_from_id               dataset_flow_detail_conn.from_id%type;
BEGIN



          IF NVL(ec_ctrl_system_attribute.attribute_text(p_daytime,'ENABLE_DOC_TRACING','<='),'N') = 'Y' THEN



                    lv_line_item_key := nvl(substr(p_reference,0,instr(p_reference,'$')-1),p_reference);

                    lv_document_key := ec_cont_line_item.document_key(lv_line_item_key);
                    lv_transaction_key := ec_cont_line_item.transaction_key(lv_line_item_key);



                    CASE ec_calc_context.object_code(
                                                  ec_calculation.calc_context_id( ec_calc_reference.calculation_id(p_calc_run_no)))
                    WHEN 'EC_REVN_TIN' THEN
                     lv_context_code  := 'CALC_REF_TIN';
                    WHEN 'EC_REVN_TI' THEN
                     lv_context_code  := 'CALC_REF_TIN';
                    ELSE
                      lv_context_code  := 'CALC_REF_ROY';
                    END CASE;

                    insert into dataset_flow_document
                      (TYPE,
                       PROCESS_DATE,
                       OBJECT,
                       REFERENCE_ID,
                       STATUS,
                       MAX_IND,
                       screen_doc_type,
                       accrual)
                      (SELECT 'CONT_DOCUMENT',
                             nvl(ec_cont_document.processing_period(lv_document_key),
                                  ecdp_fin_period.getCurrOpenPeriodByObject(ec_cont_document.object_id(lv_document_key),
                                                                            ec_cont_document.document_date(lv_document_key),
                                                                            'REPORTING',
                                                                            EC_CONT_DOCUMENT.financial_code(lv_document_key))),
                              ec_cont_document.object_id(lv_document_key),
                              lv_document_key,
                              'P',
                              'N',
                              'PERIOD',
                              decode(ec_cont_document.status_code(lv_document_key),'ACCRUAL','Y','N')
                         FROM DUAL
                        WHERE NOT EXISTS (SELECT TYPE
                                 FROM DATASET_FLOW_DOCUMENT
                                WHERE TYPE = 'CONT_DOCUMENT'
                                  AND REFERENCE_ID = lv_document_key));

                  ln_connection_id := ecdp_dataset_flow.GetConnectionId( 'CONT_DOCUMENT',lv_document_key,
                            lv_context_code,p_calc_run_no);

                  IF ln_connection_id IS NULL THEN

                     ecdp_system_key.assignNextNumber('DATASET_FLOW_DOC_CONN',ln_connection_id);

                     insert into dataset_flow_doc_conn
                        (FROM_TYPE, FROM_REFERENCE_ID, TO_TYPE, TO_REFERENCE_ID, connection_id)
                        values (  lv_context_code,p_calc_run_no, 'CONT_DOCUMENT', lv_document_key, ln_connection_id);
                     END IF;
                     --Update Visual Tracing
                     EcDp_Visual_Tracing.UpdateVisualTracing(lv_document_key, 'CONT_DOCUMENT', ec_cont_document.daytime(lv_document_key));


                  lv_from_id := p_calc_run_no || '$' ||
                                ec_cont_document.object_id(lv_document_key) || '$' ||
                                p_contract_account || '$' ||
                                p_reference;

                  insert into dataset_flow_detail_conn
                    (CONNECTION_ID,
                     FROM_ID,
                     TO_ID,
                     FROM_TYPE,
                     TO_TYPE,
                     FROM_REFERENCE_ID,
                     TO_REFERENCE_ID,
                     MAPPING_ID,
                     MAPPING_TYPE,
                     run_time,
                     detail_to_value)
                    (select ln_connection_id,
                            lv_from_id,
                            lv_transaction_key,
                            lv_context_code,
                            'CONT_DOCUMENT',
                            p_calc_run_no,
                            lv_document_key,
                            p_contract_account,
                            p_contract_account_class,
                            sysdate,
                            'N'
                       from DUAL
                      WHERE NOT EXISTS
                      (SELECT ln_connection_id
                               from dataset_flow_detail_conn
                              WHERE CONNECTION_ID = ln_connection_id
                                AND FROM_ID = lv_from_id
                                AND TO_ID = lv_transaction_key
                                AND FROM_TYPE =lv_context_code
                                AND FROM_REFERENCE_ID = p_calc_run_no
                                AND TO_REFERENCE_ID = lv_document_key
                                AND TO_TYPE = 'CONT_DOCUMENT'
                                AND MAPPING_ID = p_contract_account
                                AND MAPPING_TYPE = p_contract_account_class));
          END IF;
END;


PROCEDURE SetReportNo(ds_report_id NUMBER)
  IS

CURSOR  cr_Docs(p_run_no VARCHAR2) IS
        SELECT type
          FROM dataset_flow_document dfd
         WHERE dfd.type LIKE 'CALC_REF%'
           AND reference_id = p_run_no;

    lb_match BOOLEAN;
    rec_dsRep DATASET_FLOW_REPORT%ROWTYPE;
    lv_report_no NUMBER;
    ln_connection_id NUMBER;

BEGIN
    rec_dsRep := EC_DATASET_FLOW_REPORT.row_by_pk(ds_report_id);


      FOR doc in cr_Docs(rec_dsRep.RUN_NO) LOOP
        if EC_DATASET_FLOW_DOCUMENT.record_status('REPORT',rec_dsRep.report_no) IS NULL THEN
           ecdp_dataset_flow.InsToDsFlowDoc('REPORT',rec_dsRep.Daytime,rec_dsRep.Object_Id,rec_dsRep.report_no,'P','Y',NULL,NULL) ;
        END IF;
        ecdp_system_key.assignNextNumber('DATASET_FLOW_DOC_CONN',ln_connection_id);

        insert into dataset_flow_doc_conn
          (FROM_TYPE, FROM_REFERENCE_ID, TO_TYPE, TO_REFERENCE_ID, connection_id)
          values ( doc.type ,rec_dsRep.RUN_NO, 'REPORT', rec_dsRep.report_no, ln_connection_id);

        --Update Visual Tracing
        EcDp_Visual_Tracing.UpdateVisualTracing(rec_dsRep.report_no, 'REPORT', EC_Dataset_Flow_Document.Process_Date('REPORT',rec_dsRep.report_no));
      END LOOP;

END;


PROCEDURE SetStatusMessage(p_type VARCHAR2
                          ,p_document_type VARCHAR2
                          ,p_document_key VARCHAR2
                          ,p_msg VARCHAR2
                          ,p_system_ind VARCHAR2
                          ,p_user_id VARCHAR2) IS
  BEGIN
    INSERT INTO DATASET_FLOW_DOC_NOTE
    (id, type,reference_id,activity,note,system_note_ind,user_name) values
    (ecdp_system_key.assignNextKeyValue('DATASET_FLOW_DOC_NOTE'), p_document_type,p_document_key,p_type,p_msg,p_system_ind,p_user_id);
END;


PROCEDURE SetReportParams(p_ds_report_id NUMBER,p_report_no NUMBER)   IS

      lv_msg VARCHAR2(4000);
      lv_return varchar2(4000);


      lrec_rpt_runable dataset_flow_report%ROWTYPE := ec_dataset_flow_report.row_by_pk(p_ds_report_id);
  BEGIN


      INSERT INTO REPORT_PARAM
        (REPORT_NO,
         PARAMETER_NAME,
         PARAMETER_TYPE,
         PARAMETER_SUB_TYPE,
         USER_VISIBLE_IND,
         SORT_ORDER)
        (SELECT REPORT_NO,
                PARAMETER_NAME,
                PARAMETER_TYPE,
                PARAMETER_SUB_TYPE,
                'Y' AS USER_VISIBLE_IND,
                SORT_ORDER
           FROM REPORT_ITEM_PARAM
          WHERE REPORT_NO = p_report_no
            AND PARAMETER_VALUE IS NULL
            AND (REPORT_NO, PARAMETER_NAME) NOT IN
                (SELECT REPORT_NO, PARAMETER_NAME FROM REPORT_PARAM));


    -- INSTEAD OF user-exit
    IF ue_Dataset_Flow.isSetReportParamsUEE = 'TRUE' THEN
        lv_msg := ue_Dataset_Flow.SetReportParams(lv_msg, p_ds_report_id);
    ELSE
        -- PRE user-exit
        IF ue_Dataset_Flow.isSetReportParamsPreUEE = 'TRUE' THEN
            lv_msg := ue_Dataset_Flow.SetReportParamsPre(lv_msg, p_ds_report_id);
        END IF;




        -- Update report params
          UPDATE report_param rrp
            set rrp.parameter_value = lrec_rpt_runable.id
          where report_no = p_report_no
           and rrp.parameter_name = 'ds_report_id';

          UPDATE report_param rrp
            set rrp.parameter_value = ec_calc_reference.calculation_id(lrec_rpt_runable.run_no)
          where report_no = p_report_no
           and rrp.parameter_name = 'object_id'
           and rrp.parameter_sub_type = 'CALCULATION';

          UPDATE report_param rrp
            set rrp.parameter_value = lrec_rpt_runable.object_id
          where report_no = p_report_no
           and rrp.parameter_name = 'project_id';


          if lrec_rpt_runable.version > -1 then
          UPDATE report_param rrp
            set rrp.parameter_value = to_char(lrec_rpt_runable.RUN_NO)
          where report_no = p_report_no
           and rrp.parameter_name = 'version';
          ELSE
          UPDATE report_param rrp
            set rrp.parameter_value = 'LAST'
          where report_no = p_report_no
           and rrp.parameter_name = 'version';
          END IF;


          UPDATE report_param rrp
            set rrp.parameter_value = to_char(lrec_rpt_runable.daytime,'YYYY-MM-DD"T"HH24:MI:SS')
          where report_no = p_report_no
           and rrp.parameter_name = 'daytime';

          UPDATE report_param rrp
            set rrp.parameter_value = lrec_rpt_runable.document_key
          where report_no = p_report_no
           and rrp.parameter_name = 'document_key';

             UPDATE report_param rrp
            set rrp.parameter_value = lrec_rpt_runable.run_no
          where report_no = p_report_no
           and rrp.parameter_name = 'RUN_NO';

            UPDATE report_param rrp
            set rrp.parameter_value = lrec_rpt_runable.Document_Type
          where report_no = p_report_no
           and rrp.parameter_name = 'TEMPLATE_LAYOUT';


-- Update report params
          UPDATE report_item_param rrp
            set rrp.parameter_value = lrec_rpt_runable.id
          where report_no = p_report_no
           and rrp.parameter_name = 'ds_report_id';

          UPDATE report_item_param rrp
            set rrp.parameter_value = ec_calc_reference.calculation_id(lrec_rpt_runable.run_no)
          where report_no = p_report_no
           and rrp.parameter_name = 'object_id'
           and rrp.parameter_sub_type = 'CALCULATION';

          UPDATE report_item_param rrp
            set rrp.parameter_value = lrec_rpt_runable.object_id
          where report_no = p_report_no
           and rrp.parameter_name = 'project_id';

          UPDATE report_item_param rrp
            set rrp.parameter_value = lrec_rpt_runable.Document_Type
          where report_no = p_report_no
           and rrp.parameter_name = 'TEMPLATE_LAYOUT';

          if lrec_rpt_runable.version > -1 then
          UPDATE report_item_param rrp
            set rrp.parameter_value = to_char(lrec_rpt_runable.RUN_NO)
          where report_no = p_report_no
           and rrp.parameter_name = 'version';
          ELSE
          UPDATE report_item_param rrp
            set rrp.parameter_value = 'LAST'
          where report_no = p_report_no
           and rrp.parameter_name = 'version';
          END IF;


          UPDATE report_item_param rrp
            set rrp.parameter_value = to_char(lrec_rpt_runable.daytime,'YYYY-MM-DD"T"HH24:MI:SS')
          where report_no = p_report_no
           and rrp.parameter_name = 'daytime';

          UPDATE report_item_param rrp
            set rrp.parameter_value = lrec_rpt_runable.document_key
          where report_no = p_report_no
           and rrp.parameter_name = 'document_key';

           UPDATE report_item_param rrp
            set rrp.parameter_value = lrec_rpt_runable.run_no
          where report_no = p_report_no
           and rrp.parameter_name = 'RUN_NO';


      update dataset_flow_report
         set report_no = p_report_no
       where run_no = lrec_rpt_runable.run_no
         and report_runable = lrec_rpt_runable.report_runable
         and id = p_ds_report_id;


        -- POST user-exit
        IF ue_Dataset_Flow.isSetReportParamsPreUEE = 'TRUE' THEN
            lv_msg := ue_Dataset_Flow.SetReportParamsPost(lv_msg, p_ds_report_id);
        END IF;

    END IF;
    IF lv_msg IS NOT NULL THEN
       SetStatusMessage('REPORT','REPORT',p_ds_report_id,lv_msg,'Y',ecdp_context.getAppUser);
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
       SetStatusMessage('REPORT','REPORT',p_ds_report_id,SUBSTR(SQLERRM, 1, 240),'Y',ecdp_context.getAppUser);


END;

FUNCTION getMappingText( p_daytime date, p_ref_id VARCHAR2, p_mapping_type VARCHAR2, p_mapping_id VARCHAR2) RETURN
  VARCHAR2
  IS
         lv_return VARCHAR2(4000);
         lv_mapping_id varchar2(32);
         ln_exec_no NUMBER;
         lv_object_id VARCHAR2(32);
         lv_line  VARCHAR2(32);
         lv_product_id  VARCHAR2(32);
         lv_cost_type  VARCHAR2(32);
  BEGIN


      -- INSTEAD OF user-exit
    IF ue_Dataset_Flow.isGetMappingScreenUEE = 'TRUE' THEN
        lv_return := ue_Dataset_Flow.getMappingText(p_daytime, p_ref_id , p_mapping_type , p_mapping_id  ,lv_return);
        RETURN lv_return;
    ELSE
        lv_return := p_mapping_id;
        -- PRE user-exit
        IF ue_Dataset_Flow.isgetMappingTextPreUEE = 'TRUE' THEN
            lv_return := ue_Dataset_Flow.getMappingTextPre(p_daytime, p_ref_id , p_mapping_type , p_mapping_id  ,lv_return);
        END IF;


         CASE p_mapping_type
           WHEN 'CLASS_MAPPING' THEN
             lv_return := ec_cost_mapping_version.name(p_mapping_id,p_daytime,'<=');

           WHEN 'CLASS' THEN
             lv_return := ec_cost_mapping_version.name(p_mapping_id,p_daytime,'<=');
           WHEN 'TRANSACTION' THEN
             lv_return := ec_transaction_tmpl_version.name(p_mapping_id,p_daytime,'<=');
           WHEN  'SCTR_ACC_MTH_STATUS' THEN
             lv_return := ec_transaction_tmpl_version.name(p_mapping_id,p_daytime,'<=');
           WHEN 'EQUATION' THEN
             lv_return := 'Expand for location';
             lv_mapping_id := p_mapping_id;
             if instr(lv_mapping_id,'|') > 0 then
               lv_mapping_id := substr(p_mapping_id,1,instr(p_mapping_id,'|')-1); -- remove date
             end if;

             SELECT object_id INTO lv_object_id from calc_equation where  to_char(seq_no) = lv_mapping_id;
             SELECT exec_order INTO ln_exec_no from calc_equation x where  to_char(seq_no) = lv_mapping_id;
             lv_return := lv_return || ecdp_calculation.getCalculationPath(lv_object_id,p_daytime,chr(10)) || chr(10) || 'Equation:' || ln_exec_no;

             if lv_object_id is null then lv_return := p_mapping_id; end if;
           WHEN 'JOURNAL_MAPPING' THEN
             lv_return := ec_cost_mapping_version.name(p_mapping_id,p_daytime,'<=');
           WHEN 'JOURNAL_SUMMARY' THEN
             lv_return := ec_summary_setup_version.name(p_mapping_id,p_daytime,'<=');
           WHEN 'CALC_REF_ROY' THEN
             SELECT object_id INTO lv_object_id from calc_equation where  to_char(seq_no) = p_mapping_id;
             SELECT exec_order INTO ln_exec_no from calc_equation where  to_char(seq_no) = p_mapping_id;
             lv_return := ecdp_calculation.getCalculationPath(lv_object_id,p_daytime,CHR(10)) || ' Equation:' || ln_exec_no;
           WHEN 'CALC_REF_TIN' THEN
             SELECT object_id INTO lv_object_id from calc_equation where  to_char(seq_no) = p_mapping_id;
             SELECT exec_order INTO ln_exec_no from calc_equation where  to_char(seq_no) = p_mapping_id;
             lv_return := ecdp_calculation.getCalculationPath(lv_object_id,p_daytime,CHR(10)) || ' Equation:' || ln_exec_no;
           WHEN 'TI_LINE_PROD_EXT' THEN
           Select object_id,line_tag,product_id,cost_type
                 into lv_object_id,lv_line,lv_product_id,lv_cost_type
            from v_trans_inv_li_pr_over
            where to_char(id) = p_mapping_id
             AND period = p_daytime
             AND nvl(end_date,p_daytime) +1 > p_daytime ;

             lv_return := 'Inventory:' || ec_trans_inventory_version.name(lv_object_id, p_daytime, '<=');
             lv_return := lv_return || '/ Line:'  || ec_trans_inv_line.name(lv_object_id,p_daytime,lv_line,'<=');
             lv_return := lv_return || '/ Product:'  || ec_product_version.name( lv_product_id,p_daytime);
             lv_return := lv_return || '/ Cost:' || ec_prosty_codes.code_text(lv_cost_type,'PRODUCT_COST_TYPE');


           WHEN 'TI_VARIABLE' THEN
           Select object_id,line_tag,product_id,cost_type
                 into lv_object_id,lv_line,lv_product_id,lv_cost_type
            from trans_inv_li_pr_var
            where to_char(id) = substr(p_mapping_id,1,decode(instr(p_mapping_id,'$'),0,length(p_mapping_id),instr(p_mapping_id,'$')-1))
             AND daytime <= p_daytime
             AND nvl(end_date,p_daytime) +1 > p_daytime ;

             lv_return := 'Inventory:' || ec_trans_inventory_version.name(lv_object_id, p_daytime, '<=');
             lv_return := lv_return || '/ Line:'  || ec_trans_inv_line.name(lv_object_id,p_daytime,lv_line,'<=');
             lv_return := lv_return || '/ Product:'  ||  ec_product_version.name( lv_product_id,p_daytime);
             lv_return := lv_return || '/ Cost:' || ec_prosty_codes.code_text(lv_cost_type,'PRODUCT_COST_TYPE');
           WHEN 'TI_CONTRACT' THEN
           Select object_id,line_tag,product_id,cost_type
                 into lv_object_id,lv_line,lv_product_id,lv_cost_type
            from trans_inv_li_pr_cntracc
            where to_char(id) = substr(p_mapping_id,1,decode(instr(p_mapping_id,'$'),0,length(p_mapping_id),instr(p_mapping_id,'$')-1))
             AND daytime <= p_daytime
             AND nvl(end_date,p_daytime) +1 > p_daytime ;

             lv_return := 'Inventory:' || ec_trans_inventory_version.name(lv_object_id, p_daytime, '<=');
             lv_return := lv_return || '/ Line:'  || ec_trans_inv_line.name(lv_object_id,p_daytime,lv_line,'<=');
             lv_return := lv_return || ' Product:'  ||  ec_product_version.name( lv_product_id,p_daytime);
             lv_return := lv_return || '/ Cost:' || ec_prosty_codes.code_text(lv_cost_type,'PRODUCT_COST_TYPE');

             --ecdp_calculation.getCalculationPath(lv_object_id,p_daytime,'\') || ' Equation:' || ln_exec_no;

           ELSE
             lv_return := p_mapping_id;
         END CASE;
        -- POST user-exit
        IF ue_Dataset_Flow.isgetMappingTextPostUEE = 'TRUE' THEN
            lv_return := ue_Dataset_Flow.getMappingTextPost(p_daytime, p_ref_id , p_mapping_type , p_mapping_id  ,lv_return);
        END IF;
    END IF;

  RETURN lv_return;

END;

FUNCTION getObjectText(p_ref_id VARCHAR2, p_mapping_type VARCHAR2, p_object_id VARCHAR2, p_daytime DATE) RETURN
  VARCHAR2
  IS
         lv_return VARCHAR2(4000);

  BEGIN


      -- INSTEAD OF user-exit
    IF ue_Dataset_Flow.isGetObjectTextUEE = 'TRUE' THEN
        lv_return := ue_Dataset_Flow.GetObjectText(p_ref_id , p_mapping_type , p_object_id ,lv_return, p_daytime);
        RETURN lv_return;
    ELSE
        -- PRE user-exit
        IF ue_Dataset_Flow.isGetObjectTextPreUEE = 'TRUE' THEN
            lv_return := ue_Dataset_Flow.GetObjectTextPre(p_ref_id , p_mapping_type , p_object_id ,lv_return, p_daytime);
        END IF;


         CASE p_mapping_type
           WHEN 'TI_VARIABLE' THEN
             lv_return := ecdp_objects.getobjname(p_object_id,p_daytime);
           WHEN 'TI_LI_PROD' THEN
             lv_return := ecdp_objects.getobjname(p_object_id,p_daytime);
           WHEN 'CONTRACT_ACCOUNT' then
             lv_return := ecdp_objects.getobjname(p_object_id,p_daytime);
           ELSE
             lv_return := nvl(ecdp_objects.getobjname(p_object_id,p_daytime),p_object_id);

         END CASE;

        lv_return := rr_Dataset_Flow.GetObjectText(lv_return, p_ref_id , p_mapping_type , p_object_id, p_daytime );

        -- POST user-exit
        IF ue_Dataset_Flow.isGetObjectTextPostUEE = 'TRUE' THEN
            lv_return := ue_Dataset_Flow.GetObjectTextPost(p_ref_id , p_mapping_type , p_object_id ,lv_return, p_daytime);
        END IF;
    END IF;


  RETURN lv_return;

END;


FUNCTION getMappingScreen( p_mapping_type VARCHAR2,
                           p_direction VARCHAR2,
                           p_type varchar2 default null,
                           p_other_type varchar2 default null,
                           p_other_ref_id VARCHAR2 DEFAULT NULL) RETURN
  VARCHAR2
  IS
         lv_return VARCHAR2(4000);
         lv_calc_context varchar2(32);
  BEGIN

      -- INSTEAD OF user-exit
    IF ue_Dataset_Flow.isGetMappingScreenUEE = 'TRUE' THEN
        lv_return := ue_Dataset_Flow.GetMappingScreen(p_mapping_type , p_direction , p_type ,lv_return);
        RETURN lv_return;
    ELSE
        -- PRE user-exit
        IF ue_Dataset_Flow.isGetMappingScreenPreUEE = 'TRUE' THEN
            lv_return := ue_Dataset_Flow.GetMappingScreenPre(p_mapping_type , p_direction , p_type ,lv_return);
        END IF;



             CASE p_mapping_type
               WHEN 'CONTRACT_ACCOUNT' THEN
                    IF p_type = 'CALC_REF_ROY' THEN
                      lv_return:='CALC_ROY';
                    ELSIF p_type = 'CONTRACT_ACCOUNT' THEN
                      lv_return:='CONT_ACC';
                    ELSIF p_other_type = 'CONT_JOURNAL_ENTRY' THEN
                      lv_return:='JOUR_MAPPING';
                    ELSIF p_type = 'CONT_DOCUMENT' AND p_other_type = 'CALC_REF_ROY' THEN
                      lv_return:='CALC_ROY';
                    ELSE
                      lv_return:='CALC_TIN';
                    END IF;
               when 'CONT_DOCUMENT' then
                    lv_return := 'CONT_DOC';
               WHEN 'SCTR_ACC_MTH_STATUS' THEN
                    IF p_type = 'CONT_DOCUMENT' THEN
                      lv_return := 'CONT_DOC';

                    ELSE
                      lv_return := 'CONT_ACC';
                   END IF;
               WHEN  'TI_VARIABLE' THEN
                 lv_return:= 'CALC_TIN';
               WHEN 'TI_LINE_PROD_EXT' THEN
                 IF   p_type = 'CONT_JOURNAL_SUMMARY' THEN
                     lv_return := 'SUMMARY';
                 ELSE
                     lv_return:= 'CALC_TIN';
                 END IF;
               WHEN 'TI_CONTRACT' THEN
                 IF p_direction = 'OUT' THEN
                   lv_return:='CALC_TIN';
                 ELSE
                    lv_return:='CONT_ACC';
                 END IF;
               WHEN 'TI_CONTRACT' THEN lv_return:='CONT_ACC';
               WHEN 'CONTRACT_ACCOUNT' THEN
                 IF p_direction = 'IN' THEN
                   lv_return:='CONT_ACC';
                 ELSE
                    NULL; --lv_return:='CONT_ACC';

                 END IF;
               WHEN 'CLASS' THEN
               IF P_DIRECTION = 'OUT' AND P_TYPE  = 'CONT_DOCUMENT' THEN
                 lv_return:='CONT_DOC';
               ELSE
                 lv_return:='JOUR_MAPPING';
               END IF;
               WHEN 'JOURNAL_MAPPING' THEN
                -- IF p_other_type='CLASS_MAPPING' THEN

                  --  lv_return:='CLASS_MAPPING';
                 --ELS
                 IF p_type = 'CLASS_MAPPING' THEN
                   lv_return:='CLASS_MAPPING';
                 ELSIF p_direction = 'OUT' AND p_type = 'IFAC_JOURNAL_ENTRY'
                   THEN
                     lv_return:='IFAC_MAPPING';
                   ELSE
                       lv_return:='JOUR_MAPPING';
                   END IF;
               WHEN 'IFAC_JOURNAL_ENTRY' THEN lv_return:='IFAC_MAPPING';
               WHEN 'EQUATION' THEN
                 IF   p_type = 'CONT_JOURNAL_SUMMARY' THEN
                     lv_return := 'SUMMARY';
                 ELSIF p_type = 'CALC_REF_ROY' AND p_direction = 'OUT' and p_other_type = 'CONTRACT_ACCOUNT' THEN
                   lv_return := 'CALC_ROY';
                 ELSIF p_type = 'CALC_REF_RRCA_REVN'THEN
                   lv_return := 'CALC_RRCA_REV';
                   ELSE
                   lv_return := 'CALC_ROY';
                 END IF;

               WHEN 'JOURNAL_SUMMARY' THEN
                   if p_direction = 'OUT' AND p_type = 'CONT_JOURNAL_ENTRY'
                   THEN
                     lv_return:='JOUR_MAPPING';
                   ELSE
                       lv_return:='SUMMARY';
                   END IF;
               ELSE lv_return:=P_MAPPING_TYPE;
             END CASE;

             lv_return:=rr_dataset_flow.getMappingScreen(lv_return,
                           p_mapping_type,
                           p_direction,
                           p_type,
                           p_other_type,
                           p_other_ref_id);

        -- POST user-exit
        IF ue_Dataset_Flow.isGetMappingScreenPostUEE = 'TRUE' THEN
            lv_return := ue_Dataset_Flow.GetMappingScreenPost(p_mapping_type , p_direction , p_type ,lv_return);
        END IF;
    END IF;

  RETURN lv_return;

END;

FUNCTION getFilterLabel( p_mapping_type VARCHAR2, p_direction VARCHAR2, p_type varchar2 default null, p_Filter_number NUMBER) RETURN
  VARCHAR2
  IS
  cursor EC_CodeFilters(lv_type varchar2) is
         select code_text
         from prosty_codes x
         where code_type = 'DSF_DETAIL_FILTERS'
           AND ';' || alt_code || ';' like '%;' || lv_type || ';%'
           AND is_active = 'Y'
         order by sort_order;

  ln_counter number;
  lv_return VARCHAR2(4000);
  lv_type   VARCHAR2(4000);
  BEGIN


      -- INSTEAD OF user-exit
    IF ue_Dataset_Flow.isGetFilterLabelUEE = 'TRUE' THEN
        lv_return := ue_Dataset_Flow.GetFilterLabel(p_mapping_type , p_direction, p_type , p_Filter_number, lv_return);
        RETURN lv_return;
    ELSE
        -- PRE user-exit
        IF ue_Dataset_Flow.isGetFilterLabelPreUEE = 'TRUE' THEN
            lv_return := ue_Dataset_Flow.GetFilterLabelPre(p_mapping_type , p_direction, p_type , p_Filter_number, lv_return);
        END IF;


          lv_type := getMappingScreen( p_mapping_type , p_direction , p_type );
          ln_counter := 0;
          if lv_return is null then
            for Filter_val in EC_CodeFilters(lv_type) LOOP
                ln_counter := ln_counter+1;
                if ln_counter = p_Filter_number then
                   lv_return := Filter_val.code_text;
                   RETURN lv_return;
                end if;
            END LOOP;
          end if;

        -- POST user-exit
        IF ue_Dataset_Flow.isGetFilterLabelPostUEE = 'TRUE' THEN
            lv_return := ue_Dataset_Flow.GetFilterLabelPost(p_mapping_type , p_direction, p_type , p_Filter_number, lv_return);
        END IF;
    END IF;


  RETURN 'NONE';
END ;


FUNCTION getMappingParameters(p_daytime date, p_ref_id VARCHAR2, p_mapping_type VARCHAR2,p_class_name VARCHAR2, p_parameters VARCHAR2)  RETURN
  VARCHAR2
  IS
  cursor EC_CodeFilters(lv_type varchar2) is
         select code_text
         from prosty_codes
         where code_type = 'DSF_DETAIL_FILTERS'
           AND alt_code = lv_type
         order by sort_order;

  ln_counter number;
  lv_return VARCHAR2(4000);
  lv_type   VARCHAR2(4000);
  lv_value  VARCHAR2(4000);
  lv_param  VARCHAR2(4000);
  lv_attribute_name  VARCHAR2(32);
  lv_parameters  VARCHAR2(4000);
  BEGIN

    lv_return := p_parameters;

      -- INSTEAD OF user-exit
    IF ue_Dataset_Flow.isGetMappingParametersUEE = 'TRUE' THEN
        lv_return := ue_Dataset_Flow.GetMappingParameters(p_daytime,
                                                          p_ref_id ,
                                                          p_mapping_type ,
                                                          p_class_name,
                                                          p_parameters , lv_return);
        RETURN lv_return;
    ELSE
        -- PRE user-exit
        IF ue_Dataset_Flow.isGEtMappingParametersPreUEE = 'TRUE' THEN
            lv_return := ue_Dataset_Flow.GetMappingParametersPre(p_daytime,
                                                          p_ref_id ,
                                                          p_mapping_type ,
                                                          p_class_name,
                                                          p_parameters , lv_return);
        END IF;

          --lv_return  := p_parameters;
          lv_parameters  := p_parameters ;
          IF instr(lv_parameters,';') > 0  THEN
             lv_return := 'Expand for parameters' || chr(10);
             lv_parameters := lv_parameters || ';';
          END IF;
          WHILE instr(lv_parameters,';') > 0 loop

            lv_param := substr(lv_parameters,1,instr(lv_parameters,';')-1);

            lv_attribute_name := substr(lv_param,1,instr(lv_param,'|')-1);

            lv_attribute_name := nvl(ec_class_attr_presentation.label(p_class_name,lv_attribute_name),lv_attribute_name);
            lv_value := substr(lv_param,instr(lv_param,'|')+1);

            lv_value := nvl(ecdp_objects.GetObjName(lv_value,p_daytime), lv_value);

            lv_return :=  lv_return || lv_attribute_name || ': ' || lv_value || chr(10);
            --Remove item from list
            lv_parameters := replace(lv_parameters,lv_param||';','');
          END LOOP;

        -- POST user-exit
        IF ue_Dataset_Flow.isGetMappingParametersPostUEE = 'TRUE' THEN
            lv_return := ue_Dataset_Flow.GetMappingParametersPost(p_daytime,
                                                          p_ref_id ,
                                                          p_mapping_type ,
                                                          p_class_name,
                                                          p_parameters , lv_return);
        END IF;
    END IF;

  RETURN lv_return;
END ;

FUNCTION getFilterColumn( p_mapping_type VARCHAR2, p_direction VARCHAR2, p_type varchar2 default null, p_Filter_number NUMBER) RETURN
  VARCHAR2
  IS
  cursor EC_CodeFilters(lv_type varchar2) is
         select code
         from prosty_codes
         where code_type = 'DSF_DETAIL_FILTERS'
           AND ';' || alt_code || ';' like '%;' || lv_type || ';%'
           AND is_active = 'Y'
         order by sort_order;

  ln_counter number;
  lv_return VARCHAR2(4000);
  lv_type   VARCHAR2(4000);
  BEGIN


      -- INSTEAD OF user-exit
    IF ue_Dataset_Flow.isGetFilterColumnUEE = 'TRUE' THEN
        lv_return := ue_Dataset_Flow.GetFilterColumn(p_mapping_type , p_direction, p_type , p_Filter_number, lv_return);
        RETURN lv_return;
    ELSE
        -- PRE user-exit
        IF ue_Dataset_Flow.isGEtFilterColumnPreUEE = 'TRUE' THEN
            lv_return := ue_Dataset_Flow.GetFilterColumnPre(p_mapping_type , p_direction, p_type , p_Filter_number, lv_return);
        END IF;


               /* IF p_mapping_type = 'JOURNAL_MAPPING' AND p_Filter_number = 1 THEN
                  return 'JOURNAL_ENTRY_NO';

                END IF;*/

                lv_type := getMappingScreen( p_mapping_type , p_direction , p_type );

                ln_counter := 0;
                if lv_return is null then

                  for Filter_val in EC_CodeFilters(lv_type) LOOP
                      ln_counter := ln_counter+1;
                      if ln_counter = p_Filter_number then

                         lv_return := Filter_val.code;

                         RETURN lv_return;
                      end if;
                  END LOOP;
                end if;

        -- POST user-exit
        IF ue_Dataset_Flow.isGetFilterColumnPostUEE = 'TRUE' THEN
            lv_return := ue_Dataset_Flow.GetFilterColumnPost(p_mapping_type , p_direction, p_type , p_Filter_number, lv_return);
        END IF;
    END IF;

  RETURN 'NONE';
END ;



/*

FUNCTION GetMappingParameters(p_ref_id VARCHAR2, p_mapping_type VARCHAR2, p_parameters VARCHAR2) RETURN
  VARCHAR2
  IS


  lv_return VARCHAR2(4000);
  BEGIN


      -- INSTEAD OF user-exit
    IF ue_Dataset_Flow.isGetMappingParametersUEE = 'TRUE' THEN
        lv_return := ue_Dataset_Flow.GetMappingParameters(p_ref_id, p_mapping_type ,p_parameters, lv_return);
        RETURN lv_return;
    ELSE
        -- PRE user-exit
        IF ue_Dataset_Flow.isGEtMappingParametersPreUEE = 'TRUE' THEN
            lv_return := ue_Dataset_Flow.GetMappingParametersPre(p_ref_id, p_mapping_type ,p_parameters, lv_return);
        END IF;
            lv_return := p_parameters;

        -- POST user-exit
        IF ue_Dataset_Flow.isGetMappingParametersPostUEE = 'TRUE' THEN
            lv_return := ue_Dataset_Flow.GetMappingParametersPost(p_ref_id, p_mapping_type ,p_parameters, lv_return);
        END IF;
    END IF;

  RETURN lv_return;
END ;
*/
FUNCTION GetReportVersion(p_daytime date, p_runable number)
   RETURN VARCHAR2 IS
   lv_return varchar2(100);
BEGIN

SELECT TO_CHAR(DAYTIME, 'yyyy-MM-dd"T"HH24:MI:SS') into lv_return
  FROM REPORT_DEF_GRP_VERSION V
 WHERE REP_GROUP_CODE =
       EC_REPORT_RUNABLE.rep_group_code(p_runable)
   AND DAYTIME <= p_DAYTIME
   AND NOT EXISTS
 (SELECT DAYTIME
          FROM REPORT_DEF_GRP_VERSION X
         WHERE X.REP_GROUP_CODE = V.REP_GROUP_CODE
           AND DAYTIME > X.DAYTIME
           AND DAYTIME < p_DAYTIME);

return lv_return;

End;



------------------------+-----------------------------------+------------------------------------+---------------------------
-- FUNCTION       : Submit
-- Description    :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION Submit(        p_report_run                        NUMBER,
                        p_user_id                           VARCHAR2
                        )
RETURN VARCHAR2
IS
    lv_submit                                               VARCHAR2(4000);
    lv_submit_pre                                           VARCHAR2(4000);
    lv_submit_post                                          VARCHAR2(4000);
    lv_return                                               VARCHAR2(4000);
    ld_daytime                                              DATE;
BEGIN

    ld_daytime := ec_report.report_date(p_report_run);
    -- INSTEAD OF user-exit
    IF ue_Dataset_Flow.isSubmitUEE = 'TRUE' THEN
        lv_return := ue_Dataset_Flow.Submit(p_report_run);
        RETURN lv_submit;
    ELSE
        -- PRE user-exit
        IF ue_Dataset_Flow.isSubmitPreUEE = 'TRUE' THEN
            lv_return := ue_Dataset_Flow.SubmitPre(p_report_run);
        END IF;


        lv_return := ApproveReference('REPORT',p_report_run,false,p_user_id,ld_daytime);


        -- POST user-exit
        IF ue_Dataset_Flow.isSubmitPostUEE = 'TRUE' THEN
            lv_return := ue_Dataset_Flow.SubmitPost(p_report_run);
        END IF;

        RETURN NULL;
    END IF;
END Submit;

FUNCTION GetReferenceDesc(
                        p_DocumentKey                       VARCHAR2,
                        p_type                              VARCHAR2
                        )
RETURN VARCHAR2 is
lv_Reference varchar2(100);

BEGIN


     -- INSTEAD OF user-exit
    IF ue_Dataset_Flow.isGetMappingScreenUEE = 'TRUE' THEN
        lv_Reference := ue_Dataset_Flow.getreferenceDesc(p_DocumentKey,p_type);
        RETURN lv_Reference;
    ELSE
        -- PRE user-exit
        IF ue_Dataset_Flow.isGetMappingScreenPreUEE = 'TRUE' THEN
            lv_Reference := ue_Dataset_Flow.getreferenceDescPre(p_DocumentKey,p_type);
        END IF;

        IF p_type = 'IFAC_JOURNAL_ENRY' then
          lv_Reference := REPLACE(p_DocumentKey,'$', ':');
        ELSIF  p_typE like 'CALC_REF%' THEN
           lv_Reference := EC_CALC_REFERENCE.reference_id(p_DocumentKey);
        ELSE
          lv_Reference :=   p_DocumentKey;
        END IF;

        -- POST user-exit
        IF ue_Dataset_Flow.isGetMappingScreenPostUEE = 'TRUE' THEN
            lv_Reference := ue_Dataset_Flow.getreferenceDescPost(p_DocumentKey,p_type,lv_Reference);
        END IF;
    END IF;

  RETURN lv_Reference;
END;

-------------------------------------------------------------------------------------------------
-- Procedure      : UpdateReport
-- Description    : Used by the EC Revenue reporting to update a report.
--
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : report, dataset_flow_report
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------
FUNCTION UpdateReport(p_report_no VARCHAR2)
RETURN VARCHAR2
IS
    lv_end_user_message VARCHAR2(240);

    CURSOR c_report (p_report_no VARCHAR2) IS
    SELECT *
      FROM report r
     WHERE r.report_no = p_report_no;

BEGIN
    --Check if the report is 'Sent' or is 'Approved'. In which case 'clear report' should not be allowed.
    FOR cur IN c_report(p_report_no) LOOP
        IF (cur.send_ind ='Y') THEN
            lv_end_user_message :='Error!' || chr(10) || 'Sent Report cannot be cleared.';
        ELSIF (cur.accept_status !='P') THEN
            lv_end_user_message :='Error!' || chr(10) || 'Verified Report cannot be cleared.';
        END IF;
    END LOOP;

    IF lv_end_user_message IS NOT NULL THEN
        RETURN lv_end_user_message;
    END IF;

    --Update selected report.
    UPDATE tv_dataset_flow_report
    SET    STATUS = NULL, FORMAT = NULL, REPORT_NO = NULL
    WHERE  REPORT_NO = p_report_no;

    --Delete the generated report.
    DELETE FROM REPORT_ITEM_PARAM
    WHERE REPORT_NO = p_report_no;

    DELETE FROM REPORT_ITEM
    WHERE REPORT_NO = p_report_no;

    DELETE FROM REPORT_PARAM
    WHERE REPORT_NO = p_report_no;

    DELETE FROM REPORT
    WHERE REPORT_NO = p_report_no;

    lv_end_user_message := 'OK! Please press Refresh button to refresh the Reports section.';
    RETURN lv_end_user_message;

END UpdateReport;
-------------------------------------------------------------------------------------------------
-- Function       : CheckReportGen
-- Description    : To dispaly the feedback when send button is pressed before the reports are actually generated.
--
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : report, dataset_flow_report
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------
FUNCTION CheckReportGen(p_report_no VARCHAR2) return varchar2
IS
     lv_end_user_message                VARCHAR2(240);
     Rep_Not_Generated                  EXCEPTION;
BEGIN
     IF p_report_no IS NULL THEN
        lv_end_user_message := 'Error!\nPlease generate the report first.';
        RAISE Rep_Not_Generated;
     END IF;
     RETURN lv_end_user_message;
EXCEPTION
   WHEN Rep_Not_Generated THEN
        RETURN lv_end_user_message;
   WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, SQLERRM || '\n\n' || 'Technical:\n');
End CheckReportGen;

END EcDp_DATASET_FLOW;