CREATE OR REPLACE PACKAGE BODY EcDp_PPA_Price IS


-----------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- Function       : IsCargoOnDocument
-- Description    : Confirms given cargo exists on given document.
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION IsCargoOnDocument(p_document_key                VARCHAR2,
                           P_cargo_name                  VARCHAR2)
RETURN VARCHAR2 IS
ln_cargo_cnt                       NUMBER;
BEGIN
  SELECT count(cargo_name) INTO ln_cargo_cnt
         FROM cont_transaction ct,cont_document cd
          WHERE cd.document_key=p_document_key
          AND ct.document_key=cd.document_key
          AND NVL(ct.cargo_name,P_cargo_name)=P_cargo_name;

    IF ln_cargo_cnt >0 THEN
      RETURN 'Y';
      ELSE
        RETURN 'N';
    END IF;

END IsCargoOnDocument;

---------------------------------------------------------------------------------------------------
-- Function       : GenPriceAdjustmentDoc(
-- Description    : To generate a "PPA Price" document.
---------------------------------------------------------------------------------------------------
FUNCTION GenPriceAdjustmentDoc(p_contract_id  VARCHAR2,
                               p_period_from  DATE,
                               p_period_to    DATE,
                               p_user         VARCHAR2,
                               p_log_item_no  IN OUT NUMBER,
                               p_nav_id       VARCHAR2,
                               p_document_key VARCHAR2 DEFAULT NULL,
                               p_log_type VARCHAR2) RETURN VARCHAR2

IS

  -- This cursor decides which documents should be groupped into one PPA document
  -- The cp_customer_id parameter can be null. In this case, documents with same
  -- customer_id will be groupped. If it is not null, then only documents with the
  -- given customer_id will be queried.
  CURSOR c_price_adj_trans(cp_contract_id VARCHAR2, cp_period_from DATE, cp_period_to DATE, cp_customer_id VARCHAR2) IS
    SELECT DISTINCT ct.document_key, ct.transaction_key, ct.trans_template_id, d.customer_id, rownum, d.doc_scope,ct.cargo_name
      FROM cont_document d, cont_transaction ct, cont_line_item cli
     WHERE ct.object_id = cp_contract_id
       AND ct.document_key = d.document_key
       AND d.actual_reversal_date IS NULL
       AND d.status_code='FINAL'
       AND d.customer_id = NVL(cp_customer_id, d.customer_id)
       AND cli.transaction_key = ct.transaction_key
       AND nvl(ct.supply_from_date,ct.price_date) >= cp_period_from
       AND nvl(ct.supply_to_date,ct.price_date) < cp_period_to
       AND cli.line_item_based_type IN ('QTY', 'FREE_UNIT_PRICE_OBJECT')
       AND ct.price_src_type = 'DATE_BASED'
       AND nvl(ct.reversal_ind,'N') = 'N'
       AND d.booking_period < ecdp_fin_period.getCurrentOpenPeriod(ec_company_version.country_id(d.owner_company_id, ct.transaction_date, '<='), d.owner_company_id, d.financial_code)
       AND (ecdp_transaction.getDependentTransaction(ct.transaction_key) IS NULL
       OR ecdp_transaction.GetLatestnGreatestTran(ct.transaction_key)=ct.transaction_key)
       AND cli.unit_price != Ecdp_Contract_Setup.GetPriceElemVal(ct.object_id,
                                               nvl(cli.price_object_id, ct.price_object_id),
                                               cli.price_element_code,
                                               ct.product_id,
                                               ct.pricing_currency_id,
                                               ct.price_date,
                                               NULL);

  CURSOR c_DS(cp_contract_id VARCHAR2, cp_daytime DATE,cp_doc_scope VARCHAR2) IS
    SELECT decode(cdv.doc_concept_code,'MULTI_PERIOD',1,
                                        'PPA',2,
                                        'DEPENDENT',3,
                                        'DEPENDENT_WITHOUT_REVERSAL',4,
                                        'DEPENDENT_PARTIALLY_REVERSAL',5,
                                        'DEPENDENT_ONLY_QTY_REVERSAL',6,
                                        'DEPENDENT_PREV_MTH_CORR',7,
                                        'STANDALONE',8,9) priority,
            cd.object_id,cdv.name,cdv.automation_priority
      FROM contract_doc cd, contract_doc_version cdv
      WHERE cd.object_id = cdv.object_id
      AND cd.contract_id =cp_contract_id
      AND cdv.doc_concept_code <> 'REALLOCATION'
      AND cdv.daytime <= cp_daytime
      AND cdv.Doc_Scope =cp_doc_scope
      AND nvl(cdv.end_date, cp_daytime + 1) > cp_daytime
      ORDER BY priority,cdv.automation_priority;

  -- Finds the newest open document on the document setup to add the ppa price to
  CURSOR c_doc(cp_contract_doc_id VARCHAR2, cp_customer_id VARCHAR2) IS
    SELECT cd.document_key
      FROM cont_document cd
     WHERE cd.contract_doc_id = cp_contract_doc_id
       AND cd.document_level_code != 'BOOKED'
       AND (cd.status_code='FINAL' OR cd.status_code IS NULL)
       AND reversal_date IS NULL
       AND NVL(cd.customer_id, '$NULL$') = NVL(cp_customer_id, '$NULL$')
       AND cd.daytime =
       (SELECT max(cd.daytime) -- find the newest document date
          FROM cont_transaction ct2,
               cont_document cd2
         WHERE ct2.document_key = cd2.document_key
           AND contract_doc_id = cp_contract_doc_id
           AND reversal_date IS NULL
           AND NVL(cd.customer_id, '$NULL$') = NVL(cp_customer_id, '$NULL$')
           AND ct2.transaction_date =
             (SELECT MAX(transaction_date) -- Find with the highest transaction date
                FROM cont_transaction ct3,
                     cont_document cd3
                WHERE ct3.document_key = cd3.document_key
                  AND contract_doc_id = cp_contract_doc_id
                  AND reversal_date IS NULL))
      order by status_code NULLS FIRST,document_key;

  lv2_doc_key              cont_document.document_key%TYPE;
  lv2_transaction_key      cont_transaction.transaction_key%TYPE;
  lv2_reversal_trans_key   cont_transaction.transaction_key%TYPE;
  lrec_doc                 cont_document%ROWTYPE;
  lrec_mpd_doc             cont_document%ROWTYPE;
  lv2_contract_doc_id      contract_doc.object_id%TYPE;
  ld_daytime               DATE := trunc(Ecdp_Timestamp.getCurrentSysdate);
  lv2_document_concept     VARCHAR2(32);
  ld_processing_period     DATE;
  ltab_doc                 t_docTable := t_docTable();
  ltab_source_doc          t_sourceDocTable := t_sourceDocTable();
  lb_new_doc               BOOLEAN := FALSE;
  lb_exist				   BOOLEAN := FALSE;
  lv2_prev_doc_key         cont_document.document_key%TYPE;
  lv2_ppa_doc_key          cont_document.document_key%TYPE;
  lv2_ppa_doc_key_exist    cont_document.document_key%TYPE;
  lv2_cargo_ppa            contract_attribute.attribute_string%TYPE;
  lb_missing_doc_status    BOOLEAN := FALSE;
  lv_document_key          cont_document.document_key%TYPE;
  lb_reversed_doc          BOOLEAN:=FALSE;
  l_context                t_revn_doc_op_context;
  l_logger                 t_revn_logger;
BEGIN

  l_context := t_revn_doc_op_context;
  l_context.config_logger(p_log_item_no, p_log_type);
  l_context.user_id := p_user;
  l_context.processing_contract_id := p_contract_id;

  l_context.get_or_create_logger(l_logger);
  l_logger.update_overall_state(p_nav_id, ecdp_revn_log.LOG_STATUS_RUNNING);
  p_log_item_no := l_logger.log_no;

BEGIN

  lv2_doc_key         := p_document_key;
  lv2_cargo_ppa       := nvl(ecdp_contract_attribute.getattributestring(p_contract_id, 'CARGO_PPA',ld_daytime),'MULTI_CARGO');
   -- make sure all important parameters are set
  IF p_contract_id IS NULL THEN
    l_logger.info('Can not find a Document Setup to use for Prior Period Adjustment document for price changes. No contract has been selected in the navigator.');
  END IF;

  -- Ready to loop transactions to find adjustment candidates
  FOR rsPAT IN c_price_adj_trans(p_contract_id, p_period_from, p_period_to, ec_cont_document.customer_id(lv2_doc_key)) LOOP
        lb_new_doc := FALSE;
        lb_missing_doc_status:=FALSE;
        l_logger.info('Candidate '||rsPAT.rownum||': ['||rsPAT.Document_Key||'/'||rsPAT.Transaction_Key||'/'||ecdp_objects.getobjcode(rsPAT.customer_id)||']');

        lv2_contract_doc_id := ec_transaction_template.contract_doc_id(rsPAT.Trans_Template_Id);
        lv2_document_concept := ec_contract_doc_version.doc_concept_code(lv2_contract_doc_id,p_period_from,'<=');
        IF lv2_doc_key IS NULL AND lv2_document_concept = 'MULTI_PERIOD' AND nvl(lv2_prev_doc_key,'xx') != rsPAT.document_key THEN
           lrec_mpd_doc := ec_cont_document.row_by_pk(EcDp_Document_Gen_Util.GetTheLastMPDDoc(lv2_contract_doc_id, rsPAT.Customer_Id));

           IF lrec_mpd_doc.document_level_code = 'OPEN' THEN

             l_logger.info('Using existing open MPD doc...' || lrec_mpd_doc.document_key);
             lv2_doc_key := lrec_mpd_doc.document_key;

             --do price updates on current mpd before processing
             EcDp_Document.FillDocumentPrice(lv2_doc_key, p_user);

           ELSIF lrec_mpd_doc.document_level_code IN ('TRANSFER','VALID1','VALID2') THEN

                 ecdp_document_gen.GenDocException(p_contract_id, NULL, -20000, 'MPD document exists and is at level ' || lrec_mpd_doc.document_level_code || '. To process prices it must be OPEN or BOOKED.', 'ERROR', 'N', l_logger.log_no);
                 EcDp_Document_Gen.FinalDocGenLog(l_logger, EcDp_Revn_Log.LOG_STATUS_ERROR);
                 RETURN 'ERROR';

           END IF;
        ELSIF lv2_doc_key IS NULL THEN

              l_logger.info('Finding existing document for...' || ec_contract_doc.object_code(ec_transaction_template.contract_doc_id(rsPAT.Trans_Template_Id)));

              -- Use an existing document setup that is not booked for the concept if exists
              FOR doc IN c_doc(lv2_contract_doc_id, rsPAT.customer_id) LOOP
                lb_reversed_doc      :=FALSE;

                IF(Ec_Cont_Document.reversal_ind(doc.document_key)='Y') THEN

                     lb_reversed_doc:=TRUE;
                     lv_document_key:=doc.document_key;
                     CONTINUE;
                END IF;
                IF(rsPAT.Doc_Scope='CARGO_BASED' AND lv2_cargo_ppa='SINGLE_CARGO') THEN
                     IF(IsCargoOnDocument(doc.document_key,rsPAT.Cargo_Name)='Y' AND Ec_Cont_Document.status_code(doc.document_key) IS NULL) THEN
                          lb_missing_doc_status:=TRUE;
                          lv_document_key:=doc.document_key;
                        ELSIF(IsCargoOnDocument(doc.document_key,rsPAT.Cargo_Name)='Y' AND Ec_Cont_Document.status_code(doc.document_key) IS NOT NULL) THEN

                                lrec_doc := ec_cont_document.row_by_pk(doc.document_key);
                                lb_missing_doc_status:=FALSE;
                      END IF;
                   ELSE
                     IF Ec_Cont_Document.status_code(doc.document_key) IS NULL THEN
                           lb_missing_doc_status:=TRUE;
                           lv_document_key:=doc.document_key;
                         ELSE
                           lrec_doc := ec_cont_document.row_by_pk(doc.document_key);
                           lb_missing_doc_status:=FALSE;
                      END IF;
                END IF;

              END LOOP;



              IF lb_reversed_doc THEN
                l_logger.error(lv_document_key||'is reversal document either book or delete it.');
                lrec_doc := NULL;
                continue;
              END IF;
              -- if no direct document was found use the default
              IF lrec_doc.document_key IS null THEN

                  -- IF the existing document concept is dependent and no open was found then a dependent can't be used
                  -- and must be cleared
                  IF lv2_document_concept LIKE '%DEPENDENT%' THEN
                    lv2_document_concept := NULL;
                    lv2_contract_doc_id := NULL;
                  END IF;

                  l_logger.info('No Document was found attempting to find a Standalone or Dependent...');

                  FOR rsDS IN c_DS(p_contract_id, p_period_from,rsPAT.doc_scope) LOOP
                    lv2_contract_doc_id := rsDS.object_id;
                    EXIT; -- go with the first hit
                  END LOOP;

                  --See if there are any open for the default

                  FOR doc IN c_doc(lv2_contract_doc_id, rsPAT.customer_id) LOOP
                     lb_reversed_doc      :=FALSE;

                    IF(Ec_Cont_Document.reversal_ind(doc.document_key)='Y') THEN

                         lb_reversed_doc:=TRUE;
                         lv_document_key:=doc.document_key;
                         CONTINUE;
                    END IF;

                     IF(rsPAT.Doc_Scope='CARGO_BASED' AND lv2_cargo_ppa='SINGLE_CARGO') THEN
                         IF(IsCargoOnDocument(doc.document_key,rsPAT.Cargo_Name)='Y') THEN
                            lrec_doc := ec_cont_document.row_by_pk(doc.document_key);
                         END IF;
                       ELSE
                               lrec_doc := ec_cont_document.row_by_pk(doc.document_key);
                     END IF;
                  END LOOP;
                   IF lb_reversed_doc THEN
                      l_logger.error(lv_document_key||' is reversal document either book or delete it.');
                      lrec_doc := NULL;
                      continue;
                   END IF;

              END IF;

              IF lb_missing_doc_status AND lrec_doc.document_key IS NULL THEN
                l_logger.error('Document Status is missing for Document '||lv_document_key);
                lrec_doc := NULL;
                continue;
               END IF;



              IF lrec_doc.document_key IS NOT null THEN
                 IF lrec_doc.document_level_code = 'OPEN' THEN

                   l_logger.info('Using existing open doc...' || lrec_doc.document_key);
                   lv2_doc_key := lrec_doc.document_key;
                   lv2_ppa_doc_key_exist := lrec_doc.document_key;

                   --do price updates on current mpd before processing
                   EcDp_Document.FillDocumentPrice(lv2_doc_key, p_user);

                 ELSIF lrec_mpd_doc.document_level_code IN ('TRANSFER','VALID1','VALID2') THEN

                       ecdp_document_gen.GenDocException(p_contract_id, NULL, -20000, 'A Valid document exists (' || lv2_doc_key ||') and is at level ' || lrec_doc.document_level_code || '. To process prices it must be OPEN or BOOKED.', 'ERROR', 'N', l_logger.log_no);
                       EcDp_Document_Gen.FinalDocGenLog(l_logger, EcDp_Revn_Log.LOG_STATUS_ERROR);
                       RETURN 'ERROR';

                 END IF;
             END IF;

        END IF;



        IF lv2_doc_key IS NULL THEN

          -- Find if there is any open for the default document

          IF lv2_contract_doc_id IS NULL THEN

            l_logger.info('Can not find a Document Setup to use for Prior Period Adjustment document for price changes. The selected contract does not have a valid Standalone or Multi Period Document Setup.');
            EcDp_Document_Gen.FinalDocGenLog(l_logger, EcDp_Revn_Log.LOG_STATUS_ERROR);
            RETURN 'ERROR';

          END IF;

	         l_logger.info('Creating new document...');

	         -- create single document same as contract type
	         lv2_doc_key := EcDp_Document.GenDocumentSet_I(l_context,
                                                        p_contract_id,
	                                                    lv2_contract_doc_id,
	                                                    NULL, -- preceding doc
	                                                    ld_daytime,
	                                                    ld_daytime,
	                                                    NULL,  -- Doc Id
	                                                    NULL,  -- DG Doc Key
	                                                    'N' ,   -- Insert Transactions Ind
							    'Y'
							    );
          lv2_ppa_doc_key:= lv2_doc_key;
          IF lv2_ppa_doc_key IS NOT NULL THEN
	        UPDATE cont_document SET  status_code=(SELECT status_code from cont_document where document_key=rsPAT.Document_Key) where document_key=lv2_ppa_doc_key;
		        END IF;
          lb_new_doc := TRUE;

	         l_logger.info('Creating new document...');


         UPDATE cont_document SET processing_period = ld_processing_period
          WHERE processing_period IS NULL
            AND document_key =  lv2_doc_key;

          ecdp_document.updateDocumentCustomer(lv2_doc_key,
                                               p_contract_id,
                                               lv2_contract_doc_id,
                                               ec_cont_document.document_level_code(lv2_doc_key),
                                               ld_daytime,
                                               ec_cont_document.booking_currency_id(lv2_doc_key),
                                               p_user,
                                               rsPAT.customer_id,
                                               p_force_update => TRUE);

              IF p_document_key IS NULL THEN
                -- Currently we only update document dates if document was created from this process.
                -- Recalculate the All Document Level Dates and Transaction level, if those dates are depending on transaction level Dates
                EcDp_Contract_Setup.updateAllDocumentDates(p_contract_id,
                                                           lv2_doc_key,
                                                           ld_daytime,
                                                           ld_daytime,
                                                           p_user,
                                                           5);
			  END IF;
        END IF;


        lb_exist := false;

        IF ltab_doc.COUNT > 0 THEN
            FOR i IN ltab_doc.FIRST..ltab_doc.LAST LOOP
                IF ltab_doc(i).dockey = lv2_doc_key THEN
                  lb_exist := TRUE;
                  EXIT;
                END IF;
            END LOOP;
        END IF;

        IF NOT lb_exist THEN
         ltab_doc.EXTEND;
         ltab_doc(ltab_doc.LAST).dockey := lv2_doc_key;
         ltab_doc(ltab_doc.LAST).newdoc := lb_new_doc;
        END IF;


         l_context.processing_document_key := lv2_doc_key;
         l_context.get_or_create_logger(l_logger);

	      lrec_doc := ec_cont_document.row_by_pk(lv2_doc_key);

	      l_logger.info('Creating reversal transaction for candidate '||rsPAT.rownum);
	      lv2_reversal_trans_key := ecdp_transaction.ReverseTransaction(lrec_doc.object_id,ld_daytime,lv2_doc_key,rsPAT.transaction_key,p_user);


	      l_logger.info('Creating new transaction based on candidate '||rsPAT.rownum);

	      -- Inserting new transaction into existing PPA document
	      lv2_transaction_key := ecdp_transaction.InsNewTransaction(lrec_doc.object_id,
	                                                                ld_daytime,
	                                                                lrec_doc.document_key,
	                                                                lrec_doc.document_type,
	                                                                rsPAT.trans_template_id,
	                                                                p_user,
	                                                                NULL,
	                                                                rsPAT.transaction_key,
	                                                                NULL,
	                                                                NULL,
	                                                                NULL,
	                                                                NULL,
	                                                                NULL,
	                                                                'Y', -- create line items
	                                                                NULL,
	                                                                'Y'); -- this is a ppa transaction
                                       ecdp_revn_ft_debug.write_doc('after ins new transaction', lrec_doc.document_key);

         UPDATE cont_transaction SET ppa_trans_code = 'PPA_PRICE' WHERE transaction_key = lv2_transaction_key;

	     -- PPA interest - standard/user-exit
	        IF ue_cont_document.isSetPPAInterestUEEnabled != 'TRUE' THEN

                 IF lv2_document_concept = 'MULTI_PERIOD' OR ec_Cont_transaction.ppa_trans_code(lv2_transaction_key) = 'PPA_PRICE' THEN
	                -- Applying standard interest logic, if the correct line item was found
                    FOR rsLIT IN ecdp_line_item.gc_li_by_tt(rsPAT.trans_template_id,'INTEREST', NULL, ld_daytime) LOOP -- line item type is null, defaults to use the type from the template

                        l_logger.info('Inserting interest line item for PPA Price transaction ' || lv2_transaction_key);
                        EcDp_Line_Item.InsPPATransIntLineItem(lv2_doc_key, p_user, lv2_transaction_key);

                    END LOOP;
	             END IF;

        	END IF;

	        lv2_doc_key := p_document_key;
	        lrec_doc := NULL;
	        lv2_prev_doc_key := rsPAT.document_key;

	        --Remember distinct doc_key from source documents
	        IF ltab_source_doc.COUNT = 0 THEN
	           ltab_source_doc.EXTEND;
	           ltab_source_doc(ltab_source_doc.LAST).dockey := rsPAT.document_key;
	        ELSE
	           FOR i IN ltab_source_doc.FIRST..ltab_source_doc.LAST LOOP
	              EXIT WHEN rsPAT.document_key = ltab_source_doc(i).dockey;
	              IF i = ltab_source_doc.LAST THEN
	                 ltab_source_doc.EXTEND;
	                 ltab_source_doc(ltab_source_doc.LAST).dockey := rsPAT.document_key;
	              END IF;
	           END LOOP;
	        END IF;

  END LOOP; -- Adjustment candidates


  IF ltab_doc.COUNT > 0 THEN
         FOR i IN ltab_doc.FIRST..ltab_doc.LAST LOOP
           lv2_doc_key:=ltab_doc(i).dockey;
            IF lv2_doc_key IS NOT NULL THEN

              -- PPA interest - standard/user-exit
                IF ue_cont_document.isSetPPAInterestUEEnabled = 'TRUE' THEN

                  -- Applying user-exit interest logic
                  l_logger.info('Applying user-exit logic for PPA interest');
                  ue_cont_document.SetPPAInterest(lv2_doc_key,p_user);

                END IF;

              l_logger.info('Updating document VAT information');
              ecdp_document.UpdDocumentVat(lv2_doc_key,ld_daytime,p_user);

              Ecdp_Transaction.SetAllTransSortOrder(lv2_doc_key);

              -- To force the trigger to update document_vendor
              EcDp_Document.UpdDocumentPricingTotal(p_contract_id, lv2_doc_key, 'SYSTEM');

              -- Set Processing Period if MPD and not used existing doc
              IF ltab_doc(i).newdoc = TRUE THEN

                  ld_processing_period := EcDp_Fin_Period.GetCurrOpenPeriodByObject(p_contract_id, ec_cont_document.daytime(lv2_doc_key), ec_contract_version.financial_code(p_contract_id,  ec_cont_document.daytime(lv2_doc_key), '<='));

                  l_logger.info('MPD doc processing period is being sat to ' || ld_processing_period );

                 UPDATE cont_document SET processing_period = ld_processing_period
                        WHERE processing_period IS NULL
                        AND document_key =  lv2_doc_key;

              END IF;

              -- Updating Recommended System Action on the new document and any preceding document in use
              Ecdp_Document_Gen.SetDocumentRecActionCode(lv2_doc_key);

           END IF; -- document created or appended upon?


       END LOOP;
  ELSE
                l_logger.info('PPA price processing found no price adjustments for previous periods.');

  END IF; -- key parameters set?

  --Looping through source documents to do re-analyse
  IF ltab_source_doc.COUNT > 0 THEN
    FOR i IN ltab_source_doc.FIRST..ltab_source_doc.LAST LOOP
      ecdp_document_gen.SetDocumentRecActionCode(ltab_source_doc(i).dockey);
    END LOOP;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      ecdp_document_gen.GenDocException(p_contract_id, lv2_doc_key, SQLCODE, SUBSTR(SQLERRM, 1, 240), 'WARNING', 'N', l_logger.log_no);
      EcDp_Document_Gen.FinalDocGenLog(l_logger, EcDp_Revn_Log.LOG_STATUS_WARNING);
      RETURN 'WARNING';
  END;

  EcDp_Document_Gen.FinalDocGenLog(l_logger, EcDp_Revn_Log.LOG_STATUS_SUCCESS);
  RETURN EcDp_Revn_Log.LOG_STATUS_SUCCESS;

END GenPriceAdjustmentDoc;

END  EcDp_PPA_Price;