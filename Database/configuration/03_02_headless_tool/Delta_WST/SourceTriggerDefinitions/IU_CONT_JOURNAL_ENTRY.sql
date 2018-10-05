CREATE OR REPLACE EDITIONABLE TRIGGER "IU_CONT_JOURNAL_ENTRY" 
BEFORE INSERT OR UPDATE ON CONT_JOURNAL_ENTRY
FOR EACH ROW
  DECLARE
  p_ref_ID VARCHAR2(32);
  p_ref_detail_ID VARCHAR2(32);
  p_dist_id VARCHAR2(32);
  p_company_id VARCHAR2(32);
  p_conn_id	number;
BEGIN
    -- Basis
    IF Inserting THEN
      :new.record_status := nvl(:new.record_status, 'P');
      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;
      IF :new.created_date IS NULL THEN
         :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;

      -- Assign next key value for pk column, if not set by insert statement
      IF :new.JOURNAL_ENTRY_NO IS NULL THEN
           EcDp_System_Key.assignNextNumber('CONT_JOURNAL_ENTRY', :new.JOURNAL_ENTRY_NO);
      END IF;


    --This section will create the dataset connection to the record
          IF :new.REF_CLASS_NAME IN ('CONT_DOCUMENT','CONT_TRANSACTION','CONT_LINE_ITEM','CONT_LINE_ITEM_DIST','CONT_LI_DIST_COMPANY')
            OR :new.REF_CLASS_NAME LIKE 'RR_CONTRACT_%' OR :new.REF_CLASS_NAME LIKE 'SUM_RR_CONTRACT_%' THEN

                  SELECT max(LINE_ITEM_KEY), max(dist_id), max(vendor_id)
                    into p_ref_id, p_dist_id, p_company_id
                    FROM CONT_LI_DIST_COMPANY
                   WHERE REC_ID = :new.ref_rec_id
                     AND NVL(rev_no, -1) = nvl(:new.ref_rev_no, -1);

        p_ref_detail_ID := ec_cont_line_item.TRANSACTION_KEY(p_ref_id);

/*        IF p_dist_id IS NOT NULL THEN
          p_ref_detail_ID := p_ref_detail_ID ||'-'||ecdp_objects.getobjcode(p_dist_id);
        END IF;

        IF p_company_id IS NOT NULL THEN
          p_ref_detail_ID := p_ref_detail_ID ||'-'||ecdp_objects.getobjcode(p_company_id);
        END IF;*/

        select NVL(MAX(connection_id),-1)
          into p_conn_id
          FROM DATASET_FLOW_DOC_CONN
         WHERE FROM_TYPE = 'CONT_DOCUMENT'
           AND FROM_REFERENCE_ID = ec_cont_line_item.document_key(p_ref_id)
           AND TO_TYPE = 'CONT_JOURNAL_ENTRY'
           AND TO_REFERENCE_ID = :new.document_key;

        IF  p_conn_id < 0  THEN
            ecdp_system_key.assignNextNumber('DATASET_FLOW_DOC_CONN',p_conn_id);


			INSERT INTO DATASET_FLOW_DOC_CONN
			  (FROM_TYPE, FROM_REFERENCE_ID, TO_TYPE, TO_REFERENCE_ID,CONNECTION_ID)
			  VALUES ('CONT_DOCUMENT',
					  ec_cont_line_item.document_key(p_ref_id),
					  'CONT_JOURNAL_ENTRY',
					  :new.document_key,
					  p_conn_id);

		END IF;


        INSERT INTO dataset_flow_detail_conn
          (CONNECTION_ID,
           FROM_ID,
           TO_ID,
           FROM_TYPE,
           FROM_REFERENCE_ID,
           TO_TYPE,
           TO_REFERENCE_ID,
           MAPPING_TYPE,
           MAPPING_ID,
           DETAIL_TO_VALUE,
           RUN_TIME)
        VALUES
          (p_conn_id,
           p_ref_detail_ID,
           :new.JOURNAL_ENTRY_NO,
           'CONT_DOCUMENT',
		   ec_cont_line_item.document_key(p_ref_id),
		   'CONT_JOURNAL_ENTRY',
		   :new.document_key,
           'CLASS',
           :new.cost_mapping_id,
           'N',
           Ecdp_Timestamp.getCurrentSysdate);
          END IF;
    ELSE
      IF Nvl(:new.record_status,'P') = Nvl(:old.record_status,'P') THEN
         IF NOT UPDATING('LAST_UPDATED_BY') THEN
            :new.last_updated_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
         END IF;
         IF NOT UPDATING('LAST_UPDATED_DATE') THEN
           :new.last_updated_date := Ecdp_Timestamp.getCurrentSysdate;
         END IF;
      END IF;
    END IF;
END;
