CREATE OR REPLACE PACKAGE BODY EcDp_Document_Gen_Util IS
/****************************************************************
** Package        :  EcDp_Document_Gen_Util, header part
**
** $Revision: 1.86 $
**
** Purpose        :  Provide help functions on Cargo and Period based Document Generation.
**                   Logic for processing and manipulate data is still to be persisted in EcDp_Document_Gen.
**                   This package is mainly for lookup functions.
**
** Documentation  :  www.energy-components.com
**
** Created        : 22.05.2008 Dagfinn Rosnes
**
** Modification history:
**
** Version  Date        Whom        Change description:
** -------  ----------  ----        --------------------------------------
** 1.0      22.05.2008  DRo         Copied help functions from EcDp_Document_Gen to this package due to size problems.
*****************************************************************/


    missing_qty EXCEPTION;
    missing_unit_price_unit EXCEPTION;


--<EC-DOC>
-------------------------------------------------------------------------------------------------------------------------------------------
-- Procedure      : GetCargoDocAction
-- Description    :
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------

 -----------------------------------------------------------------------
    -- Validate values for Free Unit line item interface.
    ----+----------------------------------+-------------------------------
    PROCEDURE validate_ifac_as_qty_p(
        p_ifac_rec                         IN OUT NOCOPY ifac_cargo_value%ROWTYPE
        )
    IS
    BEGIN
        IF p_ifac_rec.line_item_based_type != ecdp_revn_ft_constants.li_btype_quantity THEN
            RETURN;
        END IF;

        IF (p_ifac_rec.net_qty1 IS NULL AND p_ifac_rec.uom1_code IS NOT NULL) OR
           (p_ifac_rec.net_qty2 IS NULL AND p_ifac_rec.uom2_code IS NOT NULL) OR
           (p_ifac_rec.net_qty3 IS NULL AND p_ifac_rec.uom3_code IS NOT NULL) OR
           (p_ifac_rec.net_qty4 IS NULL AND p_ifac_rec.uom4_code IS NOT NULL) THEN

           RAISE missing_qty;
        END IF;
    END;

    -----------------------------------------------------------------------
    -- Validate values for Quantity line item interface.
    ----+----------------------------------+-------------------------------
    PROCEDURE validate_ifac_as_free_unit_p(
        p_ifac_rec                         IN OUT NOCOPY ifac_cargo_value%ROWTYPE
        )
    IS
    BEGIN
        IF p_ifac_rec.line_item_based_type != ecdp_revn_ft_constants.li_btype_free_unit THEN
            RETURN;
        END IF;

        IF p_ifac_rec.unit_price_unit IS NULL THEN
            RAISE missing_unit_price_unit;
        END IF;
    END;
---------------------------------------------------------------------------






--- Returns the next Action to be performed
-- No Action  - The cargo document has been created and is set to booked
-- Validation - The cargo document has been created, but is not booked. Validation level is lower than BOOKED.
-- Create     - The cargo document has not yet been created, but is ready for creation. Visible in "Create Document" Tab.
-- Recreate   - The cargo document was booked, but there are new qtys or prices available, which requires that the current document is reversed,
--              and a new one is created. Visible in "Create Document" Tab.
-- Ignored    - The Ignore flag has been set on this cargo.

FUNCTION GetCargoDocAction
  (p_contract_id      VARCHAR2,
   p_cargo_no         VARCHAR2,
   p_parcel_no        VARCHAR2,
   p_qty_type         VARCHAR2,
   p_daytime          DATE,
   p_doc_setup_id     VARCHAR2,
   p_ifac_tt_conn_code VARCHAR2,
   p_customer_id      VARCHAR2
  )
RETURN VARCHAR2
--</EC-DOC>
IS
  lv2_ret_action VARCHAR2(32) := NULL;
  lv2_doc_level VARCHAR2(32) := NULL;
  lv2_doc_key VARCHAR2(32) := NULL;
  lv2_ignore_ind VARCHAR2(1) := NULL;
  lv2_prec_doc_val_level VARCHAR2(32) := NULL;
  lv2_prec_doc_key VARCHAR2(32) := NULL;
  lr_prec_doc cont_document%ROWTYPE;
  ld_price_date DATE := NULL;
  ln_this_cargo_unit_price NUMBER := NULL;
  ln_current_best_unit_price NUMBER := NULL;
  lv2_doc_setup_concept VARCHAR2(32) := NULL;
  lv2_tt_price_object_id VARCHAR2(32) := NULL;
  lv2_new_alloc_ind VARCHAR2(1) := NULL;
  lv2_total_qty1 NUMBER;
  lv2_field_qty1 NUMBER;
  lv2_source_split_SHARE NUMBER;
  lv2_valid_transaction_key cont_transaction.transaction_key%TYPE;
  lv2_valid_contract_doc_id contract_doc.object_id%TYPE;
  lv2_contract_hold_final_ind VARCHAR2(1) := NULL;
  lv2_sys_att_hold_final_ind VARCHAR2(1) := NULL;


  CURSOR c_Cargo IS
    SELECT DISTINCT cv.contract_id,
                    cv.qty_type,
                    cv.alloc_no,
                    cv.cargo_no,
                    cv.transaction_key,
                    cv.product_id,
                    cv.doc_setup_id,
                    cv.doc_status,
                    cv.ignore_ind
      FROM ifac_cargo_value cv
    WHERE cv.contract_id = p_contract_id
       AND cv.cargo_no = p_cargo_no
       AND cv.qty_type = p_qty_type
       AND cv.customer_id = p_customer_id
       AND cv.alloc_no_max_ind = 'Y'
          -- If key id columns have not been populated, the record should be disregarded.
          AND cv.IGNORE_IND = 'N'
       AND cv.contract_id IS NOT NULL
       AND cv.vendor_id IS NOT NULL
       AND cv.profit_center_id IS NOT NULL
    ORDER BY nvl(cv.transaction_key,'TRANS:0') DESC,
    ALLOC_NO
    ; -- if multiple actions on the same document take those with transactions first


  -- Loop through the cargos
  CURSOR c_CargoValue IS
    SELECT cv.*
        FROM ifac_cargo_value cv
       WHERE cv.contract_id = p_contract_id
         AND cv.cargo_no = p_cargo_no
         AND cv.qty_type = p_qty_type
         AND cv.customer_id = p_customer_id
         AND cv.alloc_no_max_ind = 'Y'
            -- If key id columns have not been populated, the record should be disregarded.
         AND cv.contract_id IS NOT NULL
         AND cv.vendor_id IS NOT NULL
         AND cv.profit_center_id IS NOT NULL
         ORDER BY nvl(cv.transaction_key,'0') ASC,
         ALLOC_NO;
      --      AND cv.product_id IS NOT NULL -- Product to be part of unique key?


  CURSOR c_LItem(cp_doc_key VARCHAR2, cp_product_id VARCHAR2) IS
    SELECT li.*
      FROM cont_line_item li, cont_transaction ct
     WHERE li.transaction_key = ct.transaction_key
       AND li.document_key = cp_doc_key
       AND ct.product_id = cp_product_id
       AND li.line_item_based_type = 'QTY';


 -- CURSOR c_NewAlloc(cp_contract_id VARCHAR2,
   CURSOR c_update_check_li_cargo(cp_contract_id VARCHAR2,
                    cp_doc_setup_id VARCHAR2,
                    cp_cargo_no VARCHAR2,
                    cp_qty_type VARCHAR2,
                    cp_customer_id VARCHAR2,
                    cp_processing_period DATE,
                    cp_doc_status VARCHAR2,
                    cp_contract_hold_final_ind VARCHAR2,
                    cp_sys_att_hold_final_ind VARCHAR2) IS
   SELECT (SELECT count(*)
     FROM ifac_cargo_value cv1
     WHERE cv1.contract_id = cp_contract_id
      AND cv1.cargo_no = cp_cargo_no
      AND cv1.customer_id = cp_customer_id
      AND cv1.qty_type = cp_qty_type
      AND cv1.alloc_no_max_ind = 'Y'
      AND cv1.ignore_ind = 'N'
      AND cv1.trans_key_set_ind = 'N'
      --Anju:below line might have to be removed as this check restricts it to
      AND NVL(cv1.line_item_based_type, ecdp_revn_ft_constants.li_btype_quantity) = ecdp_revn_ft_constants.li_btype_quantity
      AND EXISTS (
               -- See that the result in cv1 (transKey IS NULL) is an actual quantity update on an existing document (transKey is NOT null)
               SELECT 'X'
                 FROM ifac_cargo_value cv3
                WHERE cv3.point_of_sale_date = cv1.point_of_sale_date
                  AND cv3.contract_id = cv1.contract_id
                  AND cv3.vendor_id = cv1.vendor_id
                  AND cv3.customer_id = cv1.customer_id
                  AND cv3.price_concept_code = cv1.price_concept_code
                 -- AND cv3.delivery_point_id = cv1.delivery_point_id
                  AND cv3.doc_setup_id = cv1.doc_setup_id
                  AND NVL(cv3.price_object_id,'X') = NVL(cv1.price_object_id,'X')
                  AND NVL(cv3.ifac_tt_conn_code,'X') = NVL(cv1.ifac_tt_conn_code,'X')
                  AND NVL(cv3.ifac_li_conn_code,'X') = NVL(cv1.ifac_li_conn_code,'X')
                  AND NVL(cv3.line_item_based_type,'X') = NVL(cv1.line_item_based_type,'X')
                  AND NVL(cv3.line_item_type,'X') = NVL(cv1.line_item_type,'X')
                  AND cv3.trans_key_set_ind = 'Y'
                  AND cv3.alloc_no < cv1.alloc_no
                  AND NVL(SkipIfacQtyRecForUpdateCheck(
                      cv1.doc_status, cp_doc_setup_id, cp_customer_id, cp_processing_period,
                      cp_contract_hold_final_ind, cp_sys_att_hold_final_ind, cp_doc_status), 'N') = 'N'
           )) AS new_alloc_recs,
           (SELECT COUNT(*)
             FROM ifac_cargo_value cv5
             WHERE cv5.contract_id = cp_contract_id
               AND cv5.doc_setup_id = cp_doc_setup_id
             --  AND cv5.point_of_sale_date = cp_processing_period
               AND cv5.trans_key_set_ind = 'N'
               AND cv5.alloc_no_max_ind = 'Y'
               -- Id-columns can be NULL if interfaced codes were not matching EC objects.
               AND cv5.vendor_id         IS NOT NULL
               AND cv5.customer_id       IS NOT NULL
               AND cv5.profit_center_id  IS NOT NULL
               AND cv5.product_id        IS NOT NULL ) AS all_recs_in_set FROM dual;
    /*  AND NVL(SkipIfacQtyRecForUpdateCheck(cv.doc_status,
                                            cp_doc_setup_id, cp_customer_id, cp_processing_period,
                                            cp_contract_hold_final_ind,
                                            cp_sys_att_hold_final_ind, cp_doc_status), 'N') = 'N';*/

BEGIN

    IF ue_cont_document.isGetCargoDocActUEEnabled = 'TRUE' THEN
        RETURN ue_cont_document.GetCargoDocAction(p_contract_id,
                                                  p_cargo_no,
                                                  p_qty_type,
                                                  p_daytime,
                                                  p_doc_setup_id,
                                                  p_ifac_tt_conn_code,
                                                  p_customer_id);
    ELSE
        -- Pre user exit
        IF ue_cont_document.isGetPeriodDocActPreUEEnabled = 'TRUE' THEN
            ue_cont_document.GetCargoDocActionPre(p_contract_id,
                                                  p_cargo_no,
                                                  p_qty_type,
                                                  p_daytime,
                                                  p_doc_setup_id,
                                                  p_ifac_tt_conn_code,
                                                  p_customer_id);
        END IF;

  -- Set default action
  lv2_ret_action := 'MANUAL_PROCESSING';

  lv2_doc_setup_concept := ec_contract_doc_version.doc_concept_code(p_doc_setup_id, p_daytime, '<=');

  -- Get the cargo data
  FOR rsCargo IN c_Cargo LOOP
    lv2_doc_key := ec_cont_transaction.document_key(rsCargo.Transaction_Key);
    lv2_ignore_ind := rsCargo.Ignore_Ind;
  END LOOP;

  IF lv2_doc_key IS NOT NULL THEN
    -- Get current document level
    lv2_doc_level := NVL(ec_cont_document.document_level_code(lv2_doc_key),'X');

    -- If document is booked, then no action needs to be taken.
    IF UPPER(lv2_doc_level) = 'BOOKED' THEN
      -- TODO: Check to see if there are cargos that are updating the booked document. In that case, a "reverse and recreate" action is needed.
      lv2_ret_action := 'NO_ACTION';
    ELSIF UPPER(lv2_doc_level) IN ('OPEN', 'VALID1', 'VALID2', 'TRANSFER') THEN
      lv2_ret_action := 'MANUAL_VALIDATION';
    END IF;

  ELSE
    -- Document has not been created for current cargo allocation


    -- Check Ignore flag
    IF lv2_ignore_ind = 'Y' THEN
      lv2_ret_action := 'IGNORED';
      RETURN lv2_ret_action;
    END IF;

    -- Check if there are any empty qtys on the smcv records.
    FOR rsC IN c_CargoValue LOOP
        BEGIN
            validate_ifac_as_qty_p(rsC);
            validate_ifac_as_free_unit_p(rsC);
        EXCEPTION
            WHEN missing_qty THEN
                RETURN 'MISSING_QTY';
            WHEN OTHERS THEN
                RETURN 'IGNORED';
        END;
    END LOOP;

    -- Check if this cargo (with the highest alloc_no) has former allocations (with lower alloc_no)
    -- which have been processed (has transaction_key).
    lv2_prec_doc_key := GetCargoPrecedingDocKey(p_contract_id, p_cargo_no, p_parcel_no, NULL, p_daytime, p_ifac_tt_conn_code, p_customer_id);

    IF lv2_prec_doc_key IS NOT NULL THEN

      lr_prec_doc := ec_cont_document.row_by_pk(lv2_prec_doc_key);
      lv2_prec_doc_val_level := lr_prec_doc.document_level_code;
      lv2_contract_hold_final_ind := ec_contract_doc_version.hold_final_when_acl_ind(
                                        lr_prec_doc.contract_doc_id, lr_prec_doc.processing_period, '<=');
      lv2_sys_att_hold_final_ind := NVL(ec_ctrl_system_attribute.attribute_text(
                                        lr_prec_doc.processing_period, 'HOLD_FINAL_WHEN_ACL_IND', '<='), 'N');

      -- Check validation level for found transaction/document
      IF lv2_prec_doc_val_level IN ('OPEN','VALID1','VALID2','TRANSFER') THEN
      /*
        -- Check if new alloc or new record is dependent doc
        FOR rsNA IN c_update_check_li_cargo(p_contract_id, p_doc_setup_id, p_cargo_no, p_qty_type, p_customer_id,
                                lv2_prec_doc_rec.processing_period, lv2_prec_doc_rec.status_code,
                                 lv2_contract_hold_final_ind, lv2_sys_att_hold_final_ind)  LOOP
            lv2_new_alloc_ind := 'Y';
        END LOOP;

        IF lv2_new_alloc_ind = 'Y' THEN
           -- If new allocation has been inserted, update quantity
           lv2_ret_action := 'UPDATE_QUANTITY';
        ELSE
           -- If new record with dependent DS (different product, delpoint or priceconcept) has been inserted, wait until preceding has been booked.
           lv2_ret_action := 'VALIDATE_PRECEDING';
        END IF;*/
         IF ecdp_document_gen_util.isNewTransactionInterfaced(lr_prec_doc.object_id,
                                               lr_prec_doc.document_key,
                                               lr_prec_doc.document_date,
                                               lr_prec_doc.doc_scope,
                                               lr_prec_doc.Document_Level_Code,
                                               lr_prec_doc.contract_doc_id) = 'Y' THEN
               lv2_ret_action := 'APPEND_OR_UPDATE_DOC';
               ELSE
                -- Check if the record represents a qty update (new alloc) or qty to put into a dependent doc
                FOR rsUC IN c_update_check_li_cargo(p_contract_id, p_doc_setup_id, p_cargo_no, p_qty_type, p_customer_id,
                                lr_prec_doc.processing_period, lr_prec_doc.status_code,
                                 lv2_contract_hold_final_ind, lv2_sys_att_hold_final_ind) LOOP

                    IF rsUC.New_Alloc_Recs > 0 THEN

                        IF rsUC.All_Recs_In_Set = rsUC.New_Alloc_Recs THEN
                            -- There are new quantities, and all records have been updated. Quantity update is complete with all transactions.
                            lv2_ret_action := 'UPDATE_DOC';

                        ELSIF rsUC.All_Recs_In_Set > rsUC.New_Alloc_Recs THEN
                            -- There are new quantities, but only some records have been updated. Quantity update is only partial.
                            lv2_ret_action := 'APPEND_OR_UPDATE_DOC';
                        END IF;

                    ELSIF rsUC.New_Alloc_Recs = 0 AND rsUC.All_Recs_In_Set > 0 THEN
                        IF NVL(lr_prec_doc.Contract_Doc_Id,'XX') != p_doc_setup_id THEN
                        -- This is not a quantity update, but quantities that belong to a dependent document.
                        -- Preceeding doc must be booked before these quantities can be used.
                        	lv2_ret_action := 'VALIDATE_PRECEDING';
                        ELSE
                           lv2_ret_action := 'APPEND_OR_UPDATE_DOC'; -- This is when there is appending to a dependent document that is open
                        END IF;
                    END IF;
                END LOOP;
              END IF;

        -- Make sure that the TRANSFER-level document is not pending on a transfer operation against ERP system.
        IF lv2_prec_doc_val_level = 'TRANSFER' THEN
          IF ec_cont_document.fin_interface_file(lv2_prec_doc_key) IS NOT NULL THEN
            lv2_ret_action := 'PRECEDING_TRANSFER_PENDING';
          END IF;
        END IF;


      ELSIF lv2_prec_doc_val_level = 'BOOKED' THEN
        -- The previous document is BOOKED

        IF p_doc_setup_id IS NOT NULL THEN
          -- A Document Setup was found to match the cargo.

          IF lv2_doc_setup_concept LIKE 'DEPENDENT%' THEN
            -- A Dependent DS was returned by GetCargoDocSetup.
            -- There must be created a dependent doc with reversal transactions based on previous document, and transactions with updated price/qty.
            lv2_ret_action := 'CREATE_DEPENDENT';

          ELSIF lv2_doc_setup_concept = 'STANDALONE' THEN
            -- A Standalone DS was returned by GetCargoDocSetup. The previous document must be reversed.
            -- Simultaneously there must be created a completely new standalone document with updated price/qty.
            lv2_ret_action := 'CREATE_REVERSAL';

          ELSIF lv2_doc_setup_concept = 'REALLOCATION' THEN
            -- A Reallocation DS was returned by GetCargoDocSetup. The previous document must be used as basis for a reallocation.
            lv2_ret_action := 'CREATE_REALLOCATION';

          END IF;

        END IF;
      END IF;

    ELSE
      -- No previous transactions for this cargo (based on contract and cargo_name)
      -- Simply create new invoice.
      lv2_ret_action := 'CREATE_INVOICE';

    END IF; -- preceding doc?

  END IF; -- doc key?

	-- Post user exit
	IF ue_cont_document.isGetCargoDocActPostUEEnabled = 'TRUE' THEN
	    ue_cont_document.GetCargoDocActionPost(p_contract_id,
                                              p_cargo_no,
	                                          p_qty_type,
	                                          p_daytime,
	                                          p_doc_setup_id,
                                              p_ifac_tt_conn_code,
                                              p_customer_id,
	                                          lv2_ret_action);
	END IF;

  RETURN lv2_ret_action;
  END IF; -- Instead_of user exit

END GetCargoDocAction;


------------------------------------------------------------------------------------------------------------
--<EC-DOC>
-------------------------------------------------------------------------------------------------------------------------------------------
-- Procedure      : HasNotReversedAccrualDoc
-- Description    : Checks if the accrual document found by given contract doc and processing period
--                  has not been reversed or the reversal document has not been booked. Return 'Y' if true,
--                  otherwise 'N'.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION HasNotReversedAccrualDoc(p_contract_doc_id VARCHAR2, p_customer_id VARCHAR2, p_period DATE)
    RETURN VARCHAR2
--</EC-DOC>
IS
    CURSOR c_non_booked_reversed_acl_doc(cp_contract_doc_id VARCHAR2, cp_customer_id VARCHAR2, cp_period DATE, cp_search_all_document_setups VARCHAR2) IS
        SELECT document_key
        FROM cont_document
        WHERE cont_document.contract_doc_id = DECODE(cp_search_all_document_setups, 'Y', cont_document.contract_doc_id, cp_contract_doc_id)
            AND cont_document.object_id = ec_contract_doc.contract_id(cp_contract_doc_id)
            AND cont_document.status_code = 'ACCRUAL'
            AND NVL(cont_document.customer_id, '$NULL$') = NVL(cp_customer_id, '$NULL$')
            AND NVL(cont_document.reversal_ind, 'N') = 'N'
            AND NVL(ec_cont_document.document_level_code(ecdp_document.GetReversalDoc(document_key)), '$NOT_FOUND$') != 'BOOKED'
            AND DECODE(NVL(cont_document.doc_scope, 'PERIOD_BASED'),
                    'CARGO_BASED',
                        (CASE WHEN TRUNC(cont_document.document_date, 'MM') = TRUNC(document_date, 'MM') THEN 'Y' ELSE 'N' END),
                    (CASE WHEN cont_document.processing_period = cp_period THEN 'Y' ELSE 'N' END)) = 'Y';

    lb_non_booked_accrual_found VARCHAR2(1) := 'N';
    lv2_doc_scope  VARCHAR2(32);
    lv2_search_all_document_setups VARCHAR2(1) := 'N';
BEGIN
    lv2_doc_scope := ec_contract_doc_version.doc_scope(p_contract_doc_id, p_period, '<=');

    IF lv2_doc_scope = 'CARGO_BASED' THEN
        lv2_search_all_document_setups := 'Y';
    END IF;

    FOR ci_doc IN c_non_booked_reversed_acl_doc(p_contract_doc_id, p_customer_id, p_period, lv2_search_all_document_setups) LOOP
        lb_non_booked_accrual_found := 'Y';
       EXIT;
    END LOOP;

    RETURN lb_non_booked_accrual_found;

END HasNotReversedAccrualDoc;


------------------------------------------------------------------------------------------------------------
--<EC-DOC>
-------------------------------------------------------------------------------------------------------------------------------------------
-- Procedure      : GetHoldFinalWhenAclInd
-- Description    : Gets the HOLD_FINAL_WHEN_ACL_IND for a given Document Setup version. When
--                  the indicator is not set, the value on system attribute 'HOLD_FINAL_WHEN_ACL_IND'
--                  is returned instead.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetHoldFinalWhenAclInd(p_doc_setup_id              VARCHAR2,
                                p_daytime                   DATE,
                                p_contract_hold_final_ind   VARCHAR2 DEFAULT NULL,
                                p_sys_att_hold_final_ind    VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2
--</EC-DOC>
IS
    lv2_sys_att_hold_final_ind ctrl_system_attribute.attribute_text%TYPE := p_sys_att_hold_final_ind;
    lv2_contract_hold_final_ind contract_doc_version.hold_final_when_acl_ind%TYPE := p_contract_hold_final_ind;
    lv2_hold_final_ind contract_doc_version.hold_final_when_acl_ind%TYPE;
BEGIN

    IF lv2_contract_hold_final_ind IS NULL THEN
        -- if the HOLD_FINAL_WHEN_ACL_IND on the contract is not given,
        -- then get it from the contract doc
        lv2_contract_hold_final_ind := ec_contract_doc_version.hold_final_when_acl_ind(
                                                p_doc_setup_id, p_daytime, '<=');
    END IF;

    IF lv2_contract_hold_final_ind IS NOT NULL THEN
        -- The indicator is set on contract, use it
        lv2_hold_final_ind := lv2_contract_hold_final_ind;
    ELSE
        -- The indicator is not set on contract, use the system attribute
        -- instead
        IF lv2_sys_att_hold_final_ind IS NULL THEN
            -- The HOLD_FINAL_WHEN_ACL_IND system attribute value
            -- is not given, query the db for it
            lv2_sys_att_hold_final_ind :=
                NVL(ec_ctrl_system_attribute.attribute_text(p_daytime, 'HOLD_FINAL_WHEN_ACL_IND', '<='), 'N');

        END IF;

        lv2_hold_final_ind := lv2_sys_att_hold_final_ind;
    END IF;

    RETURN lv2_hold_final_ind;
END GetHoldFinalWhenAclInd;




------------------------------------------------------------------------------------------------------------
--<EC-DOC>
-------------------------------------------------------------------------------------------------------------------------------------------
-- Procedure      : SkipIfacQtyRecForUpdateCheck
-- Description    : Checks if a ifac_sales_qty record should be ignored when checking quantity
--                  update from ifac. The parameter p_contract_hold_final_ind and
--                  p_sys_att_hold_final_ind are for performance concern, since each time it
--                  needs to query the contract and system attribute to see if the check is
--                  enabled. For big set of data, get the attribute value before doing the query
--                  and give them as parameter values. p_updating_doc_status is the document
--                  status of the document to be updated by the ifac record, if null is passed,
--                  all documents within the processing period will be checked.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION SkipIfacQtyRecForUpdateCheck(p_ifac_doc_status VARCHAR2,
                                        p_doc_setup_id VARCHAR2,
                                        p_customer_id VARCHAR2,
                                        p_processing_period DATE,
                                        p_contract_hold_final_ind VARCHAR2 DEFAULT NULL,
                                        p_sys_att_hold_final_ind VARCHAR2 DEFAULT NULL,
                                        p_updating_doc_status VARCHAR2 DEFAULT NULL,
                                        p_non_booked_accrual_found VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2
--</EC-DOC>
IS
    lv2_hold_final_ind contract_doc_version.hold_final_when_acl_ind%TYPE;
    lv2_result VARCHAR2(1) := 'N';
    lv2_non_booked_accrual_found VARCHAR(1);
BEGIN

    lv2_hold_final_ind := GetHoldFinalWhenAclInd(p_doc_setup_id, p_processing_period,
                                                p_contract_hold_final_ind, p_sys_att_hold_final_ind);

    --AND decode(cv1.doc_status,'FINAL',DECODE(cp_doc_status,'FINAL', HasNonBookedAccrualReversalDoc(cp_doc_setup_id, cp_processing_period),'N'),'N') = 'N'

    IF lv2_hold_final_ind = 'Y'
        AND p_ifac_doc_status = 'FINAL' AND NVL(p_updating_doc_status, 'FINAL') = 'ACCRUAL' THEN

        -- See if any accrual document in the same processing period and have same document
        -- setup have been reversed and all reversal documents have been booked. If yes
        -- then this ifac record can be processed ('N'), skip ('Y') otherwise.
        IF p_non_booked_accrual_found IS NOT NULL AND LENGTH(p_non_booked_accrual_found) = 1 THEN
            lv2_non_booked_accrual_found := p_non_booked_accrual_found;
        ELSE
            lv2_non_booked_accrual_found := HasNotReversedAccrualDoc(p_doc_setup_id, p_customer_id, p_processing_period);
        END IF;

        lv2_result := lv2_non_booked_accrual_found;
    END IF;

    RETURN lv2_result;
END SkipIfacQtyRecForUpdateCheck;


    -----------------------------------------------------------------------
    -- Validate values for Free Unit line item interface.
    ----+----------------------------------+-------------------------------
    PROCEDURE validate_ifac_as_qty_p(
        p_ifac_rec                         IN OUT NOCOPY ifac_sales_qty%ROWTYPE
        )
    IS
    BEGIN
        IF p_ifac_rec.line_item_based_type != ecdp_revn_ft_constants.li_btype_quantity THEN
            RETURN;
        END IF;

        IF (p_ifac_rec.qty1 IS NULL AND p_ifac_rec.uom1_code IS NOT NULL) OR
           (p_ifac_rec.qty2 IS NULL AND p_ifac_rec.uom2_code IS NOT NULL) OR
           (p_ifac_rec.qty3 IS NULL AND p_ifac_rec.uom3_code IS NOT NULL) OR
           (p_ifac_rec.qty4 IS NULL AND p_ifac_rec.uom4_code IS NOT NULL) THEN

           RAISE missing_qty;
        END IF;
    END;

    -----------------------------------------------------------------------
    -- Validate values for Quantity line item interface.
    ----+----------------------------------+-------------------------------
    PROCEDURE validate_ifac_as_free_unit_p(
        p_ifac_rec                         IN OUT NOCOPY ifac_sales_qty%ROWTYPE
        )
    IS
    BEGIN
        IF p_ifac_rec.line_item_based_type != ecdp_revn_ft_constants.li_btype_free_unit THEN
            RETURN;
        END IF;

        IF p_ifac_rec.unit_price_unit IS NULL THEN
            RAISE missing_unit_price_unit;
        END IF;
    END;


------------------------------------------------------------------------------------------------------------
--<EC-DOC>
-------------------------------------------------------------------------------------------------------------------------------------------
-- Procedure      :
-- Description    :
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetPeriodDocAction
  (p_contract_id VARCHAR2,
   p_contract_doc_id VARCHAR2,
   p_customer_id VARCHAR2,
   p_processing_period DATE,
   p_preceding_doc_key VARCHAR2 DEFAULT NULL,
   p_doc_status        VARCHAR2 DEFAULT 'FINAL'
  )
RETURN VARCHAR2
--</EC-DOC>
IS
  lv2_ret_action VARCHAR2(32) := NULL;
  lv2_doc_level VARCHAR2(32) := NULL;
  lv2_doc_key VARCHAR2(32) := NULL;
  lv2_ignore_ind VARCHAR2(1) := NULL;
  lv2_prec_doc_val_level VARCHAR2(32) := NULL;
  lv2_prec_doc_key VARCHAR2(32) := p_preceding_doc_key;
  lv2_doc_setup_concept VARCHAR2(32) := NULL;
  lv2_tt_price_object_id VARCHAR2(32) := NULL;
  lv2_valid_transaction_key cont_transaction.transaction_key%TYPE;
  lv2_valid_contract_doc_id contract_doc.object_id%TYPE;
  lb_prec_doc_key_was_multiple BOOLEAN := FALSE;
  lv2_contract_hold_final_ind VARCHAR2(1) := NULL;
  lv2_sys_att_hold_final_ind VARCHAR2(1) := NULL;

  lr_prec_doc cont_document%ROWTYPE;

  CURSOR c_Period IS
    SELECT DISTINCT ec_cont_transaction.document_key(cv.transaction_key) Document_Key,
           cv.ignore_ind,
                    (CASE cv.trans_key_set_ind
                      WHEN 'N' THEN 2
                      WHEN 'Y' THEN 1 END) sort_order
      FROM ifac_sales_qty cv
     WHERE cv.contract_id = p_contract_id
       AND cv.doc_setup_id = p_contract_doc_id
       AND cv.processing_period = p_processing_period
       AND cv.alloc_no_max_ind = 'Y'
       AND cv.ignore_ind = 'N'
       -- Id-columns can be NULL if interfaced codes were not matching EC objects.
       AND cv.vendor_id         IS NOT NULL
       AND cv.customer_id = p_customer_id
       AND cv.profit_center_id  IS NOT NULL
       AND cv.product_id        IS NOT NULL
       AND cv.delivery_point_id IS NOT NULL
       ORDER BY ec_cont_transaction.document_key(cv.transaction_key)
    ;

  CURSOR c_PeriodValue IS
    SELECT cv.*
      FROM ifac_sales_qty cv
     WHERE cv.contract_id = p_contract_id
       AND cv.doc_setup_id = p_contract_doc_id
       AND cv.processing_period = p_processing_period
       AND cv.alloc_no_max_ind = 'Y'
       AND cv.ignore_ind = 'N'
       -- Id-columns can be NULL if interfaced codes were not matching EC objects.
       AND cv.vendor_id         IS NOT NULL
       AND cv.customer_id = p_customer_id
       AND cv.profit_center_id  IS NOT NULL
       AND cv.product_id        IS NOT NULL
       AND cv.delivery_point_id IS NOT NULL;

  CURSOR c_TransQtyLItems(cp_trans_key VARCHAR2) IS
    SELECT li.*
      FROM cont_line_item li
     WHERE li.transaction_key = cp_trans_key
       AND li.line_item_based_type = 'QTY';

  CURSOR c_Trans(cp_document_key VARCHAR2) IS
    SELECT ct.transaction_key
      FROM cont_transaction ct
     WHERE ct.document_key = cp_document_key;

 CURSOR c_Child_Transactions(cp_transaction_key VARCHAR2) IS
  SELECT MAX(ct.document_key) first_doc
    FROM cont_transaction ct
   WHERE ct.preceding_trans_key = cp_transaction_key
   HAVING count(*) > 0;

  -- Cursor will check whether there has been inserted quantity updates
  CURSOR c_update_check_li (
  cp_contract_id VARCHAR2
  , cp_doc_setup_id VARCHAR2
  , cp_customer_id VARCHAR2
  ,cp_processing_period DATE
  , cp_doc_status VARCHAR2
  ,cp_contract_hold_final_ind VARCHAR2
  , cp_sys_att_hold_final_ind VARCHAR2
  ) IS
    SELECT (
      SELECT Count(*)
        FROM ifac_sales_qty cv1
       WHERE cv1.contract_id = cp_contract_id
         AND cv1.doc_setup_id = cp_doc_setup_id
         AND cv1.processing_period = cp_processing_period
         AND cv1.trans_key_set_ind = 'N'
         AND cv1.alloc_no_max_ind = 'Y'
         -- Id-columns can be NULL if interfaced codes were not matching EC objects.
         AND cv1.vendor_id         IS NOT NULL
         AND cv1.customer_id = cp_customer_id
         AND cv1.profit_center_id  IS NOT NULL
         AND cv1.product_id        IS NOT NULL
         AND cv1.delivery_point_id IS NOT NULL
         AND NVL(cv1.line_item_based_type, ecdp_revn_ft_constants.li_btype_quantity) = ecdp_revn_ft_constants.li_btype_quantity
         AND EXISTS (
               -- See that the result in cv1 (transKey IS NULL) is an actual quantity update on an existing document (transKey is NOT null)
               SELECT 'X'
                 FROM ifac_sales_qty cv3
                WHERE cv3.processing_period = cv1.processing_period
                  AND cv3.contract_id = cv1.contract_id
                  AND cv3.vendor_id = cv1.vendor_id
                  AND cv3.customer_id = cv1.customer_id
                  AND cv3.price_concept_code = cv1.price_concept_code
                  AND cv3.delivery_point_id = cv1.delivery_point_id
                  AND cv3.doc_setup_id = cv1.doc_setup_id
                  AND cv3.qty_status = cv1.qty_status
                  AND cv3.uom1_code = cv1.uom1_code
                  AND cv3.period_start_date = cv1.period_start_date
                  AND cv3.period_end_date  = cv1.period_end_date
                  AND NVL(cv3.price_object_id,'X') = NVL(cv1.price_object_id,'X')
                  AND NVL(cv3.unique_key_1,'X') = NVL(cv1.unique_key_1,'X')
                  AND NVL(cv3.unique_key_2,'X') = NVL(cv1.unique_key_2,'X')
                  AND NVL(cv3.ifac_tt_conn_code,'X') = NVL(cv1.ifac_tt_conn_code,'X')
                  AND NVL(cv3.ifac_li_conn_code,'X') = NVL(cv1.ifac_li_conn_code,'X')
                  AND NVL(cv3.line_item_based_type,'X') = NVL(cv1.line_item_based_type,'X')
                  AND NVL(cv3.line_item_type,'X') = NVL(cv1.line_item_type,'X')
                  AND cv3.trans_key_set_ind = 'Y'
                  AND cv3.alloc_no < cv1.alloc_no
                  AND NVL(SkipIfacQtyRecForUpdateCheck(
                      cv1.doc_status, cp_doc_setup_id, cp_customer_id, cp_processing_period,
                      cp_contract_hold_final_ind, cp_sys_att_hold_final_ind, cp_doc_status), 'N') = 'N'
           )) AS new_alloc_recs,
           (SELECT COUNT(*)
              FROM ifac_sales_qty cv5
             WHERE cv5.contract_id = cp_contract_id
               AND cv5.doc_setup_id = cp_doc_setup_id
               AND cv5.processing_period = cp_processing_period
               AND cv5.trans_key_set_ind = 'N'
               AND cv5.alloc_no_max_ind = 'Y'
               -- Id-columns can be NULL if interfaced codes were not matching EC objects.
               AND cv5.vendor_id         IS NOT NULL
               AND cv5.customer_id       IS NOT NULL
               AND cv5.profit_center_id  IS NOT NULL
               AND cv5.product_id        IS NOT NULL
               AND cv5.delivery_point_id IS NOT NULL ) AS all_recs_in_set
       FROM dual;

BEGIN


IF ue_cont_document.isGetPeriodDocActUEEnabled = 'TRUE' THEN
    RETURN ue_cont_document.GetPeriodDocAction(p_contract_id,
                p_contract_doc_id, p_customer_id, p_processing_period, p_preceding_doc_key);
ELSE
    IF ue_cont_document.isGetPeriodDocActPreUEEnabled = 'TRUE' THEN
        ue_cont_document.GetPeriodDocActionPre(p_contract_id,
                p_contract_doc_id, p_customer_id, p_processing_period, p_preceding_doc_key);
    END IF;

  -- Set default action
  lv2_ret_action := 'MANUAL_PROCESSING';

  -- Get the general period data
  FOR rsP IN c_Period LOOP

    -- Setting document key if available. Sort order will make sure that if there are any new records (allocs), the lv2_doc_key will not be set, even if there is an existing document.
    lv2_doc_key := rsP.Document_Key;
    lv2_ignore_ind := rsP.Ignore_Ind;

  END LOOP;

  lv2_doc_setup_concept := ec_contract_doc_version.doc_concept_code(p_contract_doc_id, p_processing_period, '<=');

  IF lv2_doc_key IS NOT NULL THEN -- Document exists on records found in ifac_sales_qty

     -- Get current document level
    lv2_doc_level := NVL(ec_cont_document.document_level_code(lv2_doc_key),'X');

     -- If document is booked, then no action needs to be taken.
    IF UPPER(lv2_doc_level) = 'BOOKED' THEN
      -- TODO: Check to see if there are cargos that are updating the booked document. In that case, a "reverse and recreate" action is needed.
      lv2_ret_action := 'NO_ACTION';
    ELSIF UPPER(lv2_doc_level) IN ('OPEN', 'VALID1', 'VALID2', 'TRANSFER') THEN
      lv2_ret_action := 'MANUAL_VALIDATION';
    END IF;




    -- Check Line item prices against newest price element price value, on the same price concept.
    FOR rsPV IN c_PeriodValue LOOP

      -- Transaction key is either a valid (booked) decendant or current
      lv2_valid_transaction_key := nvl(ecdp_document_portfolio.Getlastdoctransaction(lv2_doc_key,rsPV.Transaction_Key),rsPV.Transaction_Key);
      lv2_valid_contract_doc_id := ec_transaction_template.contract_doc_id(ec_cont_transaction.trans_template_id(lv2_valid_transaction_key));

      -- Price object belongs to valid (booked) decendant or current transaction depending on the above variable assignment
      lv2_tt_price_object_id := ec_cont_transaction.price_object_id(lv2_valid_transaction_key);

      FOR rsTLI IN c_TransQtyLItems(lv2_valid_transaction_key) LOOP

        IF nvl(rsTLI.Unit_Price,0) != nvl(Ecdp_Contract_Setup.GetPriceElemVal(p_contract_id, lv2_tt_price_object_id, rsTLI.Price_Element_Code, rsPV.product_id, ec_cont_transaction.pricing_currency_id(lv2_valid_transaction_key), p_processing_period, NULL),0) THEN

          IF UPPER(lv2_doc_level) = 'BOOKED' THEN

             IF lv2_doc_setup_concept LIKE 'DEPENDENT%' THEN


             IF ecdp_document.ispreceding(lv2_doc_key) = 'N' THEN
                -- Create a dependant document based on this document, with reversal transactions and new transactions with updated price.
                lv2_ret_action := 'MANUAL_DEPENDENT_UPDATE_PRICE';

             ELSE
                   IF ecdp_document.hasbookeddependentdoc(lv2_doc_key) = 'Y' THEN
                      lv2_ret_action := 'MANUAL_DEPENDENT_UPDATE_PRICE';
                   ELSE
                       lv2_ret_action := 'MANUAL_VALIDATION_DEPENDENT';
                   END IF;

              END IF;

              ELSIF lv2_doc_setup_concept = 'STANDALONE' THEN

              IF ecdp_document.ispreceding(lv2_doc_key) = 'N' THEN
                   -- This document must be reversed by creating a new reversal document, and a new document with updated price must be created.
                   lv2_ret_action := 'MANUAL_REVERSAL_UPDATE_PRICE';
              ELSE
                   IF ecdp_document.hasbookeddependentdoc(lv2_doc_key) = 'Y' THEN
                      lv2_ret_action := 'MANUAL_REVERSAL_UPDATE_PRICE';
                       ELSE
                          lv2_ret_action := 'MANUAL_VALIDATION_DEPENDENT';
                   END IF;

              END IF;

              END IF;


          ELSIF UPPER(lv2_doc_level) IN ('OPEN', 'VALID1', 'VALID2', 'TRANSFER') THEN

            lv2_ret_action := 'UPDATE_PRICE';

            -- Make sure that the TRANSFER-level document is not pending on a transfer operation against ERP system.
            IF UPPER(lv2_doc_level) = 'TRANSFER' THEN
              IF ec_cont_document.fin_interface_file(lv2_doc_key) IS NOT NULL THEN
                lv2_ret_action := 'TRANSFER_PENDING_UPDATE_PRICE';
              END IF;
            END IF;

          END IF;

        END IF;
      END LOOP;
    END LOOP;

  ELSE
     -- Document has not been created

     -- Check Ignore flag
    IF lv2_ignore_ind = 'Y' THEN
      lv2_ret_action := 'IGNORED';
      RETURN lv2_ret_action;
    END IF;

    -- Check if there are any empty qtys on the smcv records.
    -- Also get the suggested preceding document
    FOR rsPV IN c_PeriodValue LOOP
        BEGIN
            validate_ifac_as_qty_p(rsPV);
            validate_ifac_as_free_unit_p(rsPV);
        EXCEPTION
            WHEN missing_qty THEN
                RETURN 'MISSING_QTY';
            WHEN OTHERS THEN
                RETURN 'IGNORED';
        END;
    END LOOP;

    -- Check if this record (with the highest alloc_no) has former allocations (with lower alloc_no)
    -- which have been processed (has transaction_key) for the same contract and daytime.
    -- This record could either be a quantity update or a record representing a dependent doc setup.
    lr_prec_doc := ec_cont_document.row_by_pk(lv2_prec_doc_key);

    lv2_contract_hold_final_ind := ec_contract_doc_version.hold_final_when_acl_ind(
                                        lr_prec_doc.contract_doc_id, lr_prec_doc.processing_period, '<=');
    lv2_sys_att_hold_final_ind := NVL(ec_ctrl_system_attribute.attribute_text(
                                        p_processing_period, 'HOLD_FINAL_WHEN_ACL_IND', '<='), 'N');

    -- MPD the same document consept is used if not the same then a different document
    IF ec_contract_doc_version.doc_concept_code(p_contract_doc_id, p_processing_period, '<=') = 'MULTI_PERIOD' THEN

       -- If MPD we do not know what document that is the preceding, it may be multiple.
       -- Find out if we have an existing OPEN-to-TRANSFER document on this contract for the same processing period.
       -- If found, use this to apply the new ifac record(s). If not found, create a new MPD document.
      lb_prec_doc_key_was_multiple := TRUE;
      lv2_prec_doc_key := GetPeriodPrecedingDocKeyMPD(p_contract_doc_id, p_customer_id, p_doc_status,p_processing_period);
      lr_prec_doc := ec_cont_document.row_by_pk(lv2_prec_doc_key);
   END IF;

    IF lr_prec_doc.document_key IS NOT NULL THEN
        IF lb_prec_doc_key_was_multiple THEN
            -- If a MPD document has a preceding document (existing document on the same period and contract) the ifac records are expected to be updates for this.
            IF lr_prec_doc.document_level_code IN ('OPEN','VALID1','VALID2','TRANSFER') THEN

                IF lr_prec_doc.document_level_code = 'TRANSFER' AND lr_prec_doc.fin_interface_file IS NOT NULL THEN
                  lv2_ret_action := 'PRECEDING_TRANSFER_PENDING';
                ELSE
                  -- Need to verify not trying to update an mpd that has transaction pulled on a new MPD
                  FOR trans IN c_Trans(lr_prec_doc.document_key)  LOOP
                      FOR child_trans IN c_Child_Transactions(trans.transaction_key) LOOP
                            lv2_ret_action := 'DELETE_RECREATE_CHILD';
                      END LOOP;
                  END LOOP;

                  IF lv2_ret_action != 'DELETE_RECREATE_CHILD' THEN
                    lv2_ret_action := 'APPEND_MPD'; -- Support both new MPD records and updates on existing transactions.
                  END IF;

                END IF;

                ELSE
                -- Preceding document is booked. Create a new document for the same period.
                IF lv2_doc_setup_concept = 'MULTI_PERIOD' THEN
                  lv2_ret_action := 'CREATE_MPD';
                ELSIF lv2_doc_setup_concept = 'RECONCILIATION' THEN
                  lv2_ret_action := 'CREATE_RECON';
                END IF;
            END IF;
        ELSE
            -- Check validation level for found transaction/document
            IF lr_prec_doc.document_level_code IN ('OPEN','VALID1','VALID2','TRANSFER') THEN

               IF ecdp_document_gen_util.isNewTransactionInterfaced(lr_prec_doc.object_id,
                                               lr_prec_doc.document_key,
                                               lr_prec_doc.document_date,
                                               lr_prec_doc.doc_scope,
                                               lr_prec_doc.Document_Level_Code,
                                               lr_prec_doc.contract_doc_id) = 'Y' THEN
                  lv2_ret_action := 'APPEND_OR_UPDATE_DOC';
               ELSE
                -- Check if the record represents a qty update (new alloc) or qty to put into a dependent doc
                FOR rsUC IN c_update_check_li(p_contract_id, p_contract_doc_id, p_customer_id, p_processing_period,
                                            lr_prec_doc.status_code, lv2_contract_hold_final_ind,
                                            lv2_sys_att_hold_final_ind) LOOP

                    IF rsUC.New_Alloc_Recs > 0 THEN

                        IF rsUC.All_Recs_In_Set = rsUC.New_Alloc_Recs THEN
                            -- There are new quantities, and all records have been updated. Quantity update is complete with all transactions.
                            lv2_ret_action := 'UPDATE_DOC';

                        ELSIF rsUC.All_Recs_In_Set > rsUC.New_Alloc_Recs THEN
                            -- There are new quantities, but only some records have been updated. Quantity update is only partial.
                            lv2_ret_action := 'APPEND_OR_UPDATE_DOC';
                        END IF;

                    ELSIF rsUC.New_Alloc_Recs = 0 AND rsUC.All_Recs_In_Set > 0 THEN
                        IF NVL(lr_prec_doc.Contract_Doc_Id,'XX') != p_contract_doc_id THEN
                        -- This is not a quantity update, but quantities that belong to a dependent document.
                        -- Preceeding doc must be booked before these quantities can be used.
                        	lv2_ret_action := 'VALIDATE_PRECEDING';
                        ELSE
                           lv2_ret_action := 'APPEND_OR_UPDATE_DOC'; -- This is when there is appending to a dependent document that is open
                        END IF;
                    END IF;
                END LOOP;
              END IF;
                -- Make sure that the TRANSFER-level document is not pending on a transfer operation against ERP system.
                IF lr_prec_doc.document_level_code = 'TRANSFER' THEN
                    IF lr_prec_doc.fin_interface_file IS NOT NULL THEN
                        lv2_ret_action := 'PRECEDING_TRANSFER_PENDING';
                    END IF;
                END IF;


            ELSIF lr_prec_doc.document_level_code = 'BOOKED' THEN -- The preceding document is BOOKED

                IF lv2_doc_setup_concept LIKE 'DEPENDENT%' THEN

                    -- A Dependent DS has been set on period record
                    lv2_ret_action := 'CREATE_DEPENDENT';

                ELSIF lv2_doc_setup_concept = 'REALLOCATION' THEN

                    -- The interface has identified a reallocation
                    lv2_ret_action := 'CREATE_REALLOCATION';

                ELSIF lv2_doc_setup_concept = 'STANDALONE' THEN

                    -- The document must be reversed based on the previous processed smcv record.
                    -- Simultaneously there must be created a completely new standalone document with updated price/qty.
                    lv2_ret_action := 'CREATE_REVERSAL';

                END IF;

            END IF;


        END IF; -- Multiple period document?
    ELSE
        -- No previous transactions for this document (based on contract and date)
        -- Simply create new invoice.
        IF lv2_doc_setup_concept = 'MULTI_PERIOD' THEN
            lv2_ret_action := 'CREATE_MPD';
        ELSIF lv2_doc_setup_concept = 'RECONCILIATION' THEN
            lv2_ret_action := 'CREATE_RECON';
        ELSE
            lv2_ret_action := 'CREATE_INVOICE';
        END IF;

    END IF; -- Preceding doc?
  END IF; -- Doc Key ?

    IF ue_cont_document.isGetPeriodDocActPostUEEnabled = 'TRUE' THEN
        ue_cont_document.GetPeriodDocActionPost(p_contract_id,
                p_contract_doc_id, p_customer_id, p_processing_period, p_preceding_doc_key, lv2_ret_action);
    END IF;

    RETURN lv2_ret_action;
END IF;


  RETURN lv2_ret_action;

END GetPeriodDocAction;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : GetDocumentRecActionCode
-- Description    : Figure out the state of the document and suggest an action for the user. Some of these actions might automatically be applied
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
PROCEDURE GetDocumentRecActionCode(p_document_key VARCHAR2,
                                   p_val_msg  OUT VARCHAR2,
                                   p_val_code OUT VARCHAR2
)
--</EC-DOC>
IS


  lv2_valid_transaction_key VARCHAR2(32);
  lv2_valid_contract_doc_id VARCHAR2(32);
  lv2_tt_price_object_id    VARCHAR2(32);
  lv2_contract_id           VARCHAR2(32);
  ld_pay_date               DATE;
  ld_doc_received_date      DATE;
  lv2_doc_level             VARCHAR2(32);
  lv2_dep_doc_setup         VARCHAR2(32) := NULL;
  lv2_mpd_doc_setup_id      VARCHAR2(32)  := NULL;
  lv2_complete_doc_code     VARCHAR2(32) := NULL;
  lv2_complete_doc_msg      VARCHAR2(240) := NULL;
  lv2_memo_currency_code    VARCHAR2(32) := NULL;
  ld_daytime                DATE;
  lv2_status_code           VARCHAR2(32);
  lv2_contract_doc_id       VARCHAR2(32);
  lv2_ifac_upd_doc_status   VARCHAR2(32);
  lv2_ifac_dep_doc_status   VARCHAR2(32);

  lb_upd_price             			BOOLEAN := FALSE;
  lb_upd_ifac              			BOOLEAN := FALSE;
  lb_rev_upd_price         			BOOLEAN := FALSE;
  lb_valid_rev_upd_price   			BOOLEAN := FALSE;
  lb_dep_upd_price         			BOOLEAN := FALSE;
  lb_valid_dep_upd_price   			BOOLEAN := FALSE;
  lb_dep_upd_ifac          			BOOLEAN := FALSE;
  lb_valid_dep_upd_ifac    			BOOLEAN := FALSE;
  lb_rev_upd_ifac          			BOOLEAN := FALSE;
  lb_valid_rev_upd_ifac    			BOOLEAN := FALSE;
  lb_create_mpd            			BOOLEAN := FALSE;
  lb_validate_mpd          			BOOLEAN := FALSE;
  lb_has_qty_li            			BOOLEAN := FALSE;
  lb_has_dep_ds            			BOOLEAN := FALSE;
  lb_has_mpd_ds            			BOOLEAN := FALSE;
  lb_ppa                   			BOOLEAN := FALSE;
  lb_upd_vat               			BOOLEAN := FALSE;
  lb_ifac_upd              			BOOLEAN := FALSE;
  lb_ifac_dep              			BOOLEAN := FALSE;
  lb_del_recreate          			BOOLEAN := FALSE;
  lb_unproc_dep_ifac       			BOOLEAN := FALSE;
  lb_append_mpd            			BOOLEAN := FALSE;
  lb_create_ppa_price      			BOOLEAN := FALSE;
  lb_valid_create_ppa_price 		BOOLEAN := FALSE;
  lb_new_mpd               			BOOLEAN := FALSE;
  lb_upd_sourcesplit       			BOOLEAN := FALSE;
  lb_rev_acc_cre_final     			BOOLEAN := FALSE;
  lb_rev_acc_cre_acc       			BOOLEAN := FALSE;
  lb_dep_status_code_err   			BOOLEAN := FALSE;
  lb_delete_child          			BOOLEAN := FALSE;
  lrec_document            			cont_document%ROWTYPE;
  lb_append_doc            			BOOLEAN := FALSE;
  lb_transaction_found     			BOOLEAN := FALSE;
  lv_count_cont_rev_transaction  	NUMBER  := 0;

  CURSOR c_Trans(cp_document_key VARCHAR2) IS
    SELECT ct.bl_date,
           ct.transaction_key,
           ct.document_key,
           ct.daytime,
           ct.product_id,
           ct.price_object_id,
           ct.price_date,
           ct.pricing_currency_id,
           ct.transaction_date,
           ct.supply_from_date,
           ct.supply_to_date,
           ct.cargo_name,
           ct.parcel_name,
           ct.qty_type,
           ct.trans_pricing_value,
           ct.transaction_scope,
           ct.destination_country_id,
           ct.ex_pricing_booking,
           ct.ex_inv_pricing_booking,
           ct.ex_pricing_memo,
           ct.ex_inv_pricing_memo,
           ct.ex_booking_local,
           ct.ex_inv_booking_local,
           ct.ex_booking_group,
           ct.ex_inv_booking_group,
           ct.discharge_port_id,
           ct.loading_port_id,
           ct.carrier_id,
           ct.consignee,
           ct.consignor,
           ct.delivery_point_id,
           ct.price_src_type,
		   ct.vat_code
      FROM cont_transaction ct
     WHERE ct.document_key = cp_document_key
       AND ct.reversal_ind = 'N';

  CURSOR c_TransQtyLItems(cp_trans_key VARCHAR2) IS
SELECT li.line_item_key,
       li.line_item_template_id,
       t.price_object_id,
       li.unit_price,
       li.price_element_code,
       li.qty1,
       li.uom1_code,
       li.qty2,
       li.uom2_code,
       li.qty3,
       li.uom3_code,
       li.qty4,
       li.uom4_code,
       li.pricing_value,
       li.pricing_vat_value,
         li.pricing_total,
         li.vat_code
  FROM cont_line_item li, cont_transaction t
 WHERE li.transaction_key = t.transaction_key
   and li.transaction_key = cp_trans_key
     AND li.line_item_based_type = 'QTY'
     AND t.reversal_ind = 'N'
     AND (NOT EXISTS
           (SELECT ct.transaction_key
              FROM cont_transaction ct
             WHERE (ct.preceding_trans_key = cp_trans_key OR ct.reversed_trans_key = cp_trans_key))
         OR Ecdp_Transaction.HasReversedDependentTrans(cp_trans_key) = 'Y'
         OR  ec_cont_document.actual_reversal_date(ec_cont_transaction.document_key(ecdp_transaction.getDependentTransaction(cp_trans_key))) IS NOT NULL)
      ;

  CURSOR c_TransNonQtyLItems(cp_trans_key VARCHAR2) IS
    SELECT li.*
      FROM cont_line_item li
     WHERE li.transaction_key = cp_trans_key
       AND li.line_item_based_type <> 'QTY';

  CURSOR c_DocSetup(cp_contract_id VARCHAR2, cp_daytime DATE) IS
    SELECT cdv.*
      FROM contract_doc cd, contract_doc_version cdv
     WHERE cd.object_id = cdv.object_id
       AND cdv.daytime = (SELECT MAX(daytime)
                            FROM contract_doc_version
                           WHERE object_id = cd.object_id
                             AND daytime <= cp_daytime)
       AND cd.contract_id = cp_contract_id
       AND cdv.doc_concept_code LIKE 'DEPENDENT%'
     ORDER BY NVL(cdv.automation_priority, 0);

  CURSOR c_Trans_all(cp_document_key VARCHAR2) IS
    SELECT ct.transaction_key
      FROM cont_transaction ct
     WHERE ct.document_key = cp_document_key;

  CURSOR c_Child_Transactions(cp_transaction_key VARCHAR2) IS
   SELECT MAX(ct.document_key) first_doc
     FROM cont_transaction ct
    WHERE ct.preceding_trans_key = cp_transaction_key
   HAVING count(*) > 0;

BEGIN

  IF ue_cont_document.isGetDocRecActionCodeUEEnabled = 'TRUE' THEN

     p_val_code := ue_cont_document.Getdocumentrecactioncode(p_document_key);

  ELSE

    p_val_code := 'NONE'; -- None required - The system has no recommended action for the document.


    lrec_document          := ec_cont_document.row_by_pk(p_document_key);
    lv2_contract_id        := lrec_document.object_id;
    ld_daytime             := lrec_document.daytime;
    lv2_doc_level          := lrec_document.document_level_code;
    lv2_memo_currency_code := lrec_document.memo_currency_code;
    ld_pay_date            := lrec_document.pay_date;
    ld_doc_received_date   := lrec_document.document_received_date;
    lv2_status_code        := lrec_document.status_code;
    lv2_contract_doc_id    := lrec_document.contract_doc_id;

  -- Check if document's contract has MPD document setup
  IF ec_contract_doc_version.doc_scope(lv2_contract_doc_id,ld_daytime,'<=') = 'PERIOD_BASED' THEN
  	lb_has_mpd_ds := ecdp_contract_setup.ContractHasDocSetupConcept(lv2_contract_id, ld_daytime, 'MULTI_PERIOD');
  END IF;
    -- Must be redone if Contract has multiple concepts
  IF lb_has_mpd_ds THEN
     lv2_mpd_doc_setup_id := ec_conT_document.contract_doc_id(p_document_key);
  END IF;

  IF NVL(EcDP_Document.isPreceding(p_document_key),'N') = 'N' OR lb_has_mpd_ds THEN

      -- Call Validation procedure in silent mode to only get the code and msg about what is missing or wrong
      ecdp_document.ValidateDocument(p_document_key, lv2_complete_doc_msg, lv2_complete_doc_code, 'Y');


      FOR rsT IN c_Trans(p_document_key) LOOP

        lb_has_qty_li := FALSE;
        lb_transaction_found := TRUE;
          IF lv2_status_code <> 'ACCRUAL' or nvl(ec_ctrl_system_attribute.attribute_text(ld_daytime,'VAT_ON_ACCRUALS','<='),'Y') = 'Y' THEN
            if rsT.vat_code = 'UNDEFINED' OR rsT.vat_code IS NULL THEN
              lb_upd_vat := TRUE;
            END IF;
          END IF;

        -- Performance: If one indicator is set, do not proceed. This will disallow combinations of actions, eg. "Update Price and Quantity".
        IF NOT lb_upd_price             AND
           NOT lb_upd_ifac              AND
           NOT lb_dep_upd_price         AND
           NOT lb_valid_dep_upd_price   AND
           NOT lb_dep_upd_ifac          AND
           NOT lb_valid_dep_upd_ifac    AND
           NOT lb_rev_upd_price         AND
           NOT lb_valid_rev_upd_price   AND
           NOT lb_rev_upd_ifac          AND
           NOT lb_valid_rev_upd_ifac    AND
           NOT lb_upd_sourcesplit       THEN

          -- Transaction key is either a valid (booked) decendant or current
          lv2_valid_transaction_key := nvl(ecdp_document_portfolio.Getlastdoctransaction(p_document_key, rsT.Transaction_Key), rsT.Transaction_Key);
          lv2_valid_contract_doc_id := ec_transaction_template.contract_doc_id(ec_cont_transaction.trans_template_id(lv2_valid_transaction_key));

        -- Check if document's contract has document setups to use for creating dependent document
        lb_has_dep_ds := ecdp_contract_setup.ContractHasDocSetupConcept(lv2_contract_id, ld_daytime, 'DEPENDENT%', lv2_dep_doc_setup);

          -- Price object belongs to valid (booked) decendant or current transaction depending on the above variable assignment
          lv2_tt_price_object_id := ec_transaction_tmpl_version.price_object_id(ec_cont_transaction.trans_template_id(lv2_valid_transaction_key), ld_daytime, '<=');

        IF ec_cont_transaction.document_key(lv2_valid_transaction_key) = p_document_key THEN -- Price recomended actions should only display on the document with new newest version of the transaction

          FOR rsTLI IN c_TransQtyLItems(lv2_valid_transaction_key) LOOP

            lb_has_qty_li := TRUE;

            IF NOT ecdp_transaction.isifacqtyprice(rsT.Transaction_Key) THEN

                  IF lv2_status_code <> 'ACCRUAL' or nvl(ec_ctrl_system_attribute.attribute_text(ld_daytime,'VAT_ON_ACCRUALS','<='),'Y') = 'Y' THEN
                       IF rsTLI.vat_code = 'UNDEFINED' OR rsTLI.vat_code IS NULL THEN
                          lb_upd_vat := TRUE;
                       END IF;
                  END IF;

                IF rsT.Price_Src_Type != 'PRICING_VALUE' -- Transactions with this price source type should not be evaluated in terms of price.
                    AND ec_cont_document.document_concept(rsT.Document_Key) != 'REALLOCATION' THEN -- Reallocations use unit prices fra preceding document.

                  IF nvl(rsTLI.Unit_Price,0) != nvl(Ecdp_Contract_Setup.GetPriceElemVal(lv2_contract_id,
                                                                             nvl(rsTLI.price_object_id, lv2_tt_price_object_id),
                                                                             rsTLI.Price_Element_Code,
                                                                             rsT.product_id,
                                                                             rsT.Pricing_Currency_Id,
                                                                             rsT.Price_Date,
                                                                             ecdp_transaction.getParcelNoPerTransaction(rsT.transaction_key, rsT.daytime)),0) THEN


                    IF UPPER(lv2_doc_level) IN ('BOOKED','TRANSFER') THEN

                       IF lb_has_mpd_ds THEN

                          IF UPPER(lv2_doc_level) = 'BOOKED' THEN
                               lb_create_ppa_price := TRUE; -- Suggests using PPA Price function (process button)
                          ELSIF UPPER(lv2_doc_level) = 'TRANSFER' THEN
                               lb_valid_create_ppa_price := TRUE; -- Suggests validate document and use PPA Price function (process button)
                          END IF;

                       ELSIF lb_has_dep_ds THEN

                          -- Recommend to use the dependent doc setup for price update
                          IF UPPER(lv2_doc_level) = 'BOOKED' AND lv2_status_code <> 'ACCRUAL'  THEN
                             lb_dep_upd_price := TRUE;
                          ELSIF UPPER(lv2_doc_level) = 'TRANSFER' THEN
                             lb_valid_dep_upd_price := TRUE;
                          END IF;

                       ELSE

                          -- No dependent ds available, recommend full reversal and recreate
                          IF UPPER(lv2_doc_level) = 'BOOKED' THEN
                             lb_rev_upd_price := TRUE;
                          ELSIF UPPER(lv2_doc_level) = 'TRANSFER' THEN
                                lb_valid_rev_upd_price := TRUE;
                          END IF;

                       END IF;

                    ELSIF UPPER(lv2_doc_level) IN ('OPEN', 'VALID1', 'VALID2') THEN

                      lb_upd_price := TRUE;

                    END IF;
                  END IF;
               END IF;
            END IF;
          END LOOP; -- Line items
        END IF;


        -- Has the same document/transaction been updated? Same Qty Status and/or price object.
        lb_ifac_upd := Ecdp_Document.IsIfacUpdated(p_document_key,
                                                   rsT.Transaction_Key,
                                                   'N',
                                                   lv2_contract_doc_id,
                                                   lrec_document.document_level_code,
                                                   lv2_status_code,
                                                   NULL,
                                                   'N',
                                                   NULL,
                                                   NULL,
                                                   lv2_ifac_upd_doc_status);

        -- Has dependent ifac data been made available?
        lb_ifac_dep := Ecdp_Document.IsIfacDependentAvailable(p_document_key,
                                                              rsT.Transaction_Key,
                                                              lv2_ifac_dep_doc_status);

          -- CHECK UPDATE FROM INTERFACE (QUANTITIES/PRICES ETC.)
          IF lb_ifac_upd OR lb_ifac_dep THEN

            IF UPPER(lv2_doc_level) IN ('BOOKED','TRANSFER') THEN

            IF lrec_document.Actual_Reversal_Date IS NULL THEN
             -- If this doc is accrual and the dependent data is final - error
             IF lrec_document.status_code = 'ACCRUAL' AND lv2_ifac_dep_doc_status = 'FINAL' THEN

               lb_dep_status_code_err := TRUE;

             -- If having Accrual doc and received Final qty, recommend Reverse Accrual and create Final
             ELSIF lrec_document.status_code = 'ACCRUAL' AND lv2_ifac_upd_doc_status = 'FINAL' THEN

               lb_rev_acc_cre_final := TRUE;

             ELSIF lrec_document.status_code = 'ACCRUAL' AND lv2_ifac_dep_doc_status = 'ACCRUAL' THEN

               lb_rev_acc_cre_acc := TRUE;

             ELSE


               IF lb_has_mpd_ds THEN

                  -- Need to check if there is a newer document that can handle the new ifac quantities.
                  -- If so, this document should have "No Action"

                  IF p_document_key = GetTheLastMPDDoc(lv2_mpd_doc_setup_id, lrec_document.customer_id) THEN

                    IF UPPER(lv2_doc_level) = 'BOOKED' THEN
                      lb_create_mpd := TRUE;
                    ELSIF UPPER(lv2_doc_level) = 'TRANSFER' THEN
                      lb_validate_mpd := TRUE;
                    END IF;

                  END IF;

               ELSE

                 IF lb_has_dep_ds THEN

                  -- Recommend to use the dependent doc setup for qty update
                  IF UPPER(lv2_doc_level) = 'BOOKED' THEN
                     lb_dep_upd_ifac := TRUE;
                  ELSIF UPPER(lv2_doc_level) = 'TRANSFER' THEN
                     lb_valid_dep_upd_ifac := TRUE;
                  END IF;

               ELSE

                  -- No dependent ds available, recommend full reversal and recreate
                  IF UPPER(lv2_doc_level) = 'BOOKED' THEN
                    lb_rev_upd_ifac := TRUE;
                  ELSIF UPPER(lv2_doc_level) = 'TRANSFER' THEN
                     lb_valid_rev_upd_ifac := TRUE;
                  END IF;

                 END IF; -- dependent?
               END IF; -- multi period?
               END IF;
               END IF;
            ELSIF UPPER(lv2_doc_level) IN ('OPEN', 'VALID1', 'VALID2') THEN

             -- If this doc status has changed

             IF lrec_document.status_code = 'ACCRUAL' AND lv2_ifac_dep_doc_status = 'FINAL' OR
               lrec_document.status_code = 'ACCRUAL' AND lv2_ifac_upd_doc_status = 'FINAL'THEN

               lb_del_recreate := TRUE;

             ELSIF lb_ifac_dep THEN -- new ifac data has different qty type/price object

                 IF lb_has_mpd_ds THEN

                   IF ec_cont_document.document_level_code(p_document_key) != 'BOOKED' THEN
                     FOR doc IN c_Trans_all(p_document_key) LOOP
                       FOR child_trans IN c_Child_Transactions(doc.transaction_key) LOOP
                           lb_delete_child := TRUE;
                       END LOOP;
                     END LOOP;
                   END IF;

                   IF NOT lb_delete_child THEN
                   -- Append transaction to existing document
                      lb_append_mpd := TRUE;
                   END IF;

                 ELSE

                   IF lrec_document.document_concept = 'STANDALONE' THEN

                      -- if standalone and dep ifac data is available: Book/validate standalone and process dependent.
                      lb_valid_dep_upd_ifac := TRUE;

                   ELSIF lrec_document.document_concept LIKE 'DEPENDENT%' THEN

                      -- if dependent and dep ifac data is available: Error situation
                      lb_unproc_dep_ifac := TRUE;

                   END IF;

                 END IF;

               ELSIF lb_ifac_upd THEN  -- new ifac data has same qty type/price object ++

               IF ecdp_document_gen_util.isNewTransactionInterfaced(lrec_document.object_id,p_document_key,lrec_document.document_date,lrec_document.doc_scope,lrec_document.Document_Level_Code,
                                                                    lrec_document.contract_doc_id) = 'Y' THEN
                  lb_append_doc := TRUE;
               ELSE
                  lb_upd_ifac := TRUE;
               END IF;


            END IF;

          END IF;

          ELSIF lrec_document.Preceding_Document_Key IS NOT NULL THEN
            --Check to see if dependent document with new transactions not already on doc
            IF ecdp_document_gen_util.isNewTransactionInterfaced(lrec_document.object_id,p_document_key,lrec_document.document_date,lrec_document.doc_scope,lrec_document.document_level_code,
                                                                    lrec_document.contract_doc_id) = 'Y' THEN
                  lb_append_doc := TRUE;
             END IF;

          END IF;

          -- Check if source split is updated:
          IF EcDp_Document.isDocSourceSplitShareUpdated(p_document_key) = 'Y' THEN
            lb_upd_sourcesplit := TRUE;
          END IF;

        END IF;

      END LOOP; -- Transactions

    /*  START PPA
        Figure out if applicable PPA transactions are available */

/*    ecdp_document_gen.q_PeriodDocumentProcessPPA(c_val,
                                                 lrec_document.object_id,
                                                 ec_contract_area.object_id_by_uk(lrec_document.contract_area_code),
                                                 ec_contract_area_version.business_unit_id(ec_contract_area.object_id_by_uk(lrec_document.contract_area_code),
                                                                                           lrec_document.daytime,
                                                                                           '<='));


    LOOP
      FETCH c_val INTO l_pdgppa;
      EXIT WHEN c_val%NOTFOUND;


    END LOOP;
    CLOSE c_val;


               -- IF all checks are true, PPA update should be suggested.
               -- Doc setup accept ppa?                   ppa interface records found?         document level accepts changes
    lb_ppa := (nvl(lv2_ppa_transaction_ind,'N') = 'Y' AND
              l_pdgppa.contract_id IS NOT NULL AND
              UPPER(lv2_doc_level) IN ('OPEN', 'VALID1', 'VALID2'));*/

    /* END PPA */

	  /* Checking if Reversal transactions exist in the document */

      IF lb_transaction_found = FALSE THEN
       SELECT count(1)
       INTO lv_count_cont_rev_transaction
       FROM cont_transaction ct
       WHERE ct.document_key = p_document_key
       AND ct.reversal_ind = 'Y';

       IF lv_count_cont_rev_transaction <> 0 THEN
         lb_transaction_found := TRUE;
       END IF;

      END IF;

	  IF NOT lb_transaction_found THEN
	   p_val_code := 'TRANS_MISSING';
	  END IF;


      -- Now determine action based on indicators
      IF lb_upd_price AND lb_upd_ifac  THEN
        p_val_code := 'UPDATE_PRICE_IFAC'; -- Due to performance this will never be set.

      ELSIF lb_upd_price AND NOT lb_upd_ifac THEN
        p_val_code := 'UPDATE_PRICE';

      ELSIF NOT lb_upd_price AND lb_upd_ifac THEN
        p_val_code := 'UPDATE_IFAC';

      ELSIF lb_ppa THEN
        p_val_code := 'UPDATE_PPA';
      END IF;

      IF lb_dep_upd_price THEN
        p_val_code := 'DEPENDENT_UPDATE_PRICE';
      ELSIF lb_valid_dep_upd_price THEN
        p_val_code := 'VALIDATE_DEPENDENT_UPDATE_PRICE';
      ELSIF lb_rev_upd_price THEN
        p_val_code := 'REVERSE_UPDATE_PRICE';
      ELSIF lb_valid_rev_upd_price THEN
        p_val_code := 'VALIDATE_REVERSE_UPDATE_PRICE';
      END IF;

      IF lb_dep_upd_ifac THEN
        p_val_code := 'DEPENDENT_UPDATE_IFAC';
      ELSIF lb_valid_dep_upd_ifac THEN
        p_val_code := 'VALIDATE_DEPENDENT_UPDATE_IFAC';
      ELSIF lb_rev_upd_ifac THEN
        p_val_code := 'REVERSE_UPDATE_IFAC';
      ELSIF lb_valid_rev_upd_ifac THEN
        p_val_code := 'VALIDATE_REVERSE_UPDATE_IFAC';
      ELSIF lb_rev_acc_cre_final THEN
        p_val_code := 'REV_ACCRUAL_CRE_FINAL';
      ELSIF lb_rev_acc_cre_acc THEN
        p_val_code := 'REV_ACCRUAL_CRE_ACC';
      ELSIF lb_dep_status_code_err THEN
        p_val_code := 'ACCRUAL_FINAL_DEP_ERR';
      ELSIF lb_del_recreate THEN
        p_val_code := 'DELETE_RECREATE';
      ELSIF lb_unproc_dep_ifac THEN
        p_val_code := 'UNPROCESSABLE_DEP_IFAC';
      ELSIF lb_validate_mpd THEN
        p_val_code := 'VALIDATE_MPD';
      ELSIF lb_create_mpd THEN
        p_val_code := 'CREATE_MPD';
      ELSIF lb_create_ppa_price THEN
        p_val_code := 'CREATE_PPA_PRICE';
      ELSIF lb_valid_create_ppa_price THEN
        p_val_code := 'VALIDATE_CREATE_PPA_PRICE';
      ELSIF lb_append_mpd THEN
        p_val_code := 'APPEND_MPD';
      ELSIF lb_append_doc THEN
        p_val_code := 'APPEND_DOC';
      ELSIF lb_delete_child THEN
        p_val_code := 'DELETE_RECREATE_CHILD';
      END IF;

      -- Updated source split is available, recalculation needed:
      IF lb_upd_sourcesplit THEN
        p_val_code := 'RECALC_SOURCESPLIT';
      END IF;

      -- VAT needs to be updated:
      IF lb_upd_vat THEN
        p_val_code := 'UPDATE_VAT_CODE';
      END IF;

      -- If action was not set by above check, do a final check on the document
      IF p_val_code = 'NONE' THEN

         IF UPPER(lv2_doc_level) IN ('OPEN') THEN

            -- If prices, quantities, pos date or other important information are missing,
            -- you can not set the document to VALID1. It must first be completed.
            IF lv2_complete_doc_code IS NOT NULL THEN
               p_val_code := lv2_complete_doc_code;
               p_val_msg := lv2_complete_doc_msg;
            ELSE
               p_val_code := 'SET_VALID1';
            END IF;

         ELSIF UPPER(lv2_doc_level) IN ('VALID1', 'VALID2', 'TRANSFER') THEN
            p_val_code := 'VALIDATION';

         END IF;
      END IF;
    END IF; -- Is Preceding?


  END IF; -- User exit

END GetDocumentRecActionCode;


FUNCTION GetERPDocumentRecActionCode(p_document_key VARCHAR2
) RETURN VARCHAR2
IS

  lv2_val_msg VARCHAR2(240);
  lv2_val_code VARCHAR2(32);

BEGIN

  GetERPDocumentRecActionCode(p_document_key, lv2_val_msg, lv2_val_code);

  RETURN lv2_val_code;

END GetERPDocumentRecActionCode;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : GetERPDocumentRecActionCode
-- Description    : Figure out the state of the document and suggest an action for the user. Some of these actions might automatically be applied
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
PROCEDURE GetERPDocumentRecActionCode(p_document_key VARCHAR2,
                                      p_val_msg  OUT VARCHAR2,
                                      p_val_code OUT VARCHAR2
)
--</EC-DOC>
IS

  lrec_doc cont_document%ROWTYPE := ec_cont_document.row_by_pk(p_document_key);
  lv2_complete_doc_code VARCHAR2(32);
  lv2_complete_doc_msg VARCHAR2(240);

  ln_count NUMBER := 0;
  lb_new_postings BOOLEAN := FALSE;

  CURSOR c_postings(cp_document_key VARCHAR2) IS
  SELECT * FROM cont_erp_postings
   WHERE document_key = cp_document_key;

BEGIN

  IF ue_cont_document.isGetDocRecActionCodeUEEnabled = 'TRUE' THEN

     p_val_code := ue_cont_document.Getdocumentrecactioncode(p_document_key);

  ELSE

     p_val_code := 'NONE'; -- None required - The system has no recommended action for the document.

     IF NVL(EcDP_Document.isPreceding(p_document_key),'N') = 'N' THEN

        -- Call Validation procedure in silent mode to only get the code and msg about what is missing or wrong
        ecdp_document.ValidateDocument(p_document_key, lv2_complete_doc_msg, lv2_complete_doc_code, 'Y');

        -- If action was not set by above check, do a final check on the document
        IF p_val_code = 'NONE' THEN

           IF lrec_doc.document_level_code = 'OPEN' THEN

              -- If prices, quantities, pos date or other important information are missing,
              -- you can not set the document to VALID1. It must first be completed.
              IF lv2_complete_doc_code IS NOT NULL THEN
                 p_val_code := lv2_complete_doc_code;
                 p_val_msg := lv2_complete_doc_msg;
              ELSE
                 p_val_code := 'SET_VALID1';
              END IF;

           ELSIF lrec_doc.document_level_code IN ('VALID1', 'VALID2', 'TRANSFER') THEN
              p_val_code := 'VALIDATION';

           END IF;
        END IF;
    END IF; -- Is Preceding?
  END IF; -- User exit

END GetERPDocumentRecActionCode;

------------------------------------------------------------------------------------------------------------
--<EC-DOC>
-------------------------------------------------------------------------------------------------------------------------------------------
-- Procedure      :
-- Description    :
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
-- Gets the preceding document for cargo

FUNCTION GetCargoPrecedingDocKey(p_contract_id  VARCHAR2,
                                 p_cargo_no     VARCHAR2,
                                 p_parcel_no  VARCHAR2,
                                 p_doc_key      VARCHAR2,
                                 p_pos_date     DATE,
                                 p_ifac_tt_conn_code VARCHAR2,
                                 p_customer_id  VARCHAR2,
                                 p_prec_doc_key VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
--</EC-DOC>
IS

  lv2_ret_prec_doc_key VARCHAR2(32) := NULL;
  lv2_allow_alt_cust_ind VARCHAR2(32) := 'N';

  CURSOR c_PrecedingCargoDoc(cp_ifac_tt_conn_code VARCHAR2, cp_customer_id VARCHAR2, cp_allow_alt_cust_ind VARCHAR2) IS
     SELECT DISTINCT cd.document_key
       FROM cont_document cd, cont_transaction ct
      WHERE cd.object_id = p_contract_id
        AND ct.document_key = cd.document_key
        AND ct.cargo_name = p_cargo_no
        AND ecdp_document.IsPPADocument(cd.document_key)='N'
        AND (NVL(cd.single_parcel_doc_ind, 'N') = 'N' OR ct.parcel_name = p_parcel_no)
        AND (NOT EXISTS
             (SELECT DISTINCT cd2.document_key
                FROM cont_document cd2
               WHERE cd2.preceding_document_key = cd.document_key) OR
             ecdp_document.hasreverseddependentdoc(cd.document_key) = 'Y')
        AND nvl(cd.reversal_ind, 'N') = 'N' -- Reversal documents can not be used as preceding
        AND nvl(ct.ifac_tt_conn_code, '$NULL$') = nvl(cp_ifac_tt_conn_code, '$NULL$');

BEGIN

  -- If this cargo has not yet been processed
  IF p_doc_key IS NULL THEN

    IF p_prec_doc_key IS NOT NULL THEN

      lv2_ret_prec_doc_key := p_prec_doc_key;

    ELSE
    lv2_allow_alt_cust_ind := nvl(ec_contract_version.allow_alt_cust_ind(p_contract_id,nvl( p_pos_date,Ecdp_Timestamp.getCurrentSysdate), '<='), 'N');

      -- Find out if there are processed documents on the same contract that have no documents depending on them.
      FOR rsPCD IN c_PrecedingCargoDoc(p_ifac_tt_conn_code, p_customer_id, lv2_allow_alt_cust_ind) LOOP

        lv2_ret_prec_doc_key := rsPCD.Document_Key;
        EXIT;

      END LOOP;
    END IF;
  ELSE

    -- The cargo has been processed.
    lv2_ret_prec_doc_key := ec_cont_document.preceding_document_key(p_doc_key);

  END IF;

  RETURN lv2_ret_prec_doc_key;

END GetCargoPrecedingDocKey;

--<EC-DOC>
-------------------------------------------------------------------------------------------------------------------------------------------
-- Procedure      :
-- Description    :
-- Preconditions  : This will only work for non-PPA documents. PPA-documents can have multiple preceding documents.
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
-- Gets the preceding document for period
FUNCTION GetPeriodPrecedingDocKey(p_contract_id        VARCHAR2,
                                  p_processing_period  DATE,
                                  p_supply_from_date   DATE,
                                  p_price_concept_code VARCHAR2,
                                  p_delivery_point_id  VARCHAR2,
                                  p_product_id         VARCHAR2,
                                  p_customer_id        VARCHAR2,
                                  p_unique_key_1       VARCHAR2,
                                  p_unique_key_2       VARCHAR2,
                                  p_prec_doc_key       VARCHAR2,
                                  p_ifac_tt_conn_code  VARCHAR2,
                                  p_appending_doc_id   VARCHAR2 DEFAULT NULL,
                                  p_Qty_Status         VARCHAR2 DEFAULT NULL,
                                  p_Price_Status       VARCHAR2 DEFAULT NULL,
                                  p_uom1_code          VARCHAR2 DEFAULT NULL,
                                  p_price_object_id    VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
--</EC-DOC>
IS

  lv2_ret_prec_doc_key VARCHAR2(32) := NULL;
  lv2_allow_alt_cust_ind VARCHAR2(1);
  ln_count PLS_INTEGER := 0;
  ln_trans_count NUMBER;
  ln_match_count NUMBER;

  TYPE t_docs IS TABLE OF VARCHAR2(32) INDEX BY PLS_INTEGER;
  prec_docs t_docs;


  -- Find processed record for same month on the same contract, and use this as preceding.
  CURSOR c_Prec(cp_contract_id        VARCHAR2,
                cp_processing_period  DATE,
                cp_supply_from_date   DATE,
                cp_price_concept_code VARCHAR2,
                cp_delivery_point_id  VARCHAR2,
                cp_product_id         VARCHAR2,
                cp_customer_id        VARCHAR2,
                cp_unique_key_1       VARCHAR2,
                cp_unique_key_2       VARCHAR2,
                cp_ifac_tt_conn_code  VARCHAR2,
                cp_Appending_doc_id   VARCHAR2,
                cp_Qty_Status         VARCHAR2,
                cp_Price_Status         VARCHAR2,
                cp_uom1_code          VARCHAR2,
                cp_price_object_id    VARCHAR2,
                cp_allow_alt_cust_ind VARCHAR2
                ) IS
     SELECT cd.document_key -- Find an existing record on an existing document
       FROM cont_document cd, cont_transaction ct
      WHERE cd.object_id = cp_contract_id
        AND cd.document_key = ct.document_key
        AND cd.processing_period = cp_processing_period
        AND ct.supply_from_date = cp_supply_from_date
        AND ct.price_concept_code = cp_price_concept_code
        AND ct.delivery_point_id = cp_delivery_point_id
        AND cp_Appending_doc_id IS NULL
        AND ct.product_id = cp_product_id
        AND nvl(cd.customer_id,'xx') = decode(cp_allow_alt_cust_ind,'N',nvl(cd.customer_id,'xx'),cp_customer_id)
        AND NVL(ct.ifac_unique_key_1,'X') = NVL(cp_unique_key_1,'X')
        AND NVL(ct.ifac_unique_key_2,'X') = NVL(cp_unique_key_2,'X')
        AND (NOT EXISTS
                 (SELECT cd4.document_key
                    FROM cont_document cd4
                   WHERE cd4.preceding_document_key = cd.document_key)
            OR ecdp_document.hasreverseddependentdoc(cd.document_key) = 'Y')
        AND cd.reversal_ind = 'N' -- Reversal documents can not be used as preceding
        AND nvl(ct.ifac_tt_conn_code, '$NULL$') = nvl(cp_ifac_tt_conn_code, '$NULL$')
        AND cd.reversal_ind = 'N'
     UNION ALL -- Find update on existing document with Same Document object (Stand alone and MPD) APPDEND
     SELECT cd.document_key
       FROM cont_document cd, cont_transaction ct
      WHERE cd.object_id = cp_contract_id
        AND cd.document_key = ct.document_key
        AND cd.processing_period = cp_processing_period
        AND cd.contract_doc_id = cp_appending_doc_id
        AND cd.document_level_code in ('OPEN','VALID1','VALID2')
        AND (NOT EXISTS
                 (SELECT cd4.document_key
                    FROM cont_document cd4
                   WHERE cd4.preceding_document_key = cd.document_key)
            OR ecdp_document.hasreverseddependentdoc(cd.document_key) = 'Y')
        AND cd.reversal_ind = 'N'
     UNION ALL -- Find new dependent document to try as append document when you dont have a document setup
     SELECT cd.document_key
       FROM cont_document cd, cont_transaction ct,
            transaction_tmpl_version ttv,
            transaction_template tt
      WHERE cd.object_id = cp_contract_id
        AND cd.document_key = ct.document_key
        AND cd.processing_period = cp_processing_period
        AND tt.object_id = ttv.object_id
        AND tt.contract_doc_id = cd.contract_doc_id
        AND cd.object_id = cp_contract_id
        AND cp_Appending_doc_id IS NULL
        AND cd.document_concept LIKE '%DEPENDENT%'
        AND nvl(ttv.price_concept_code,cp_price_concept_code) = cp_price_concept_code
        AND nvl(ttv.delivery_point_id,cp_delivery_point_id) = cp_delivery_point_id
        AND nvl(ttv.uom1_code,cp_uom1_code) = cp_uom1_code
        AND nvl(ttv.req_qty_type,cp_qty_status) = cp_qty_status
        AND nvl(ttv.req_price_status,cp_price_status) = cp_price_status
        AND nvl(ttv.price_object_id,cp_price_object_id) = cp_price_object_id
        AND cd.document_level_code in ('OPEN','VALID1','VALID2')
        AND (NOT EXISTS
                 (SELECT cd4.document_key
                    FROM cont_document cd4
                   WHERE cd4.preceding_document_key = cd.document_key)
            OR ecdp_document.hasreverseddependentdoc(cd.document_key) = 'Y')
        AND cd.reversal_ind = 'N'
     ;

BEGIN

    -- If Multi Period Document you need to find preceding TRANSACTION, not Document. This is handled by the GenPeriodDocument function.
    IF ecdp_contract_setup.ContractHasDocSetupConcept(p_Contract_Id, p_processing_period, 'MULTI_PERIOD') THEN
       RETURN 'MULTIPLE';
    END IF;

    IF p_prec_doc_key IS NOT NULL THEN

      lv2_ret_prec_doc_key := p_prec_doc_key;

    ELSE
       lv2_allow_alt_cust_ind := nvl(ec_contract_version.allow_alt_cust_ind(p_contract_id, p_processing_period, '<='), 'N');
      -- Find out if there are processed documents on the same contract that have no documents depending on them.
      FOR rsPR IN c_Prec(p_contract_id,
                         p_processing_period,
                         p_supply_from_date,
                         p_price_concept_code,
                         p_delivery_point_id,
                         p_product_id,
                         p_customer_id,
                         p_unique_key_1,
                         p_unique_key_2,
                         p_ifac_tt_conn_code,
                         p_appending_doc_id,
                         p_qty_status,
                         p_price_status,
                         p_uom1_code,
                         p_price_object_id,
                         lv2_allow_alt_cust_ind) LOOP

         lv2_ret_prec_doc_key := rsPR.document_key;
         EXIT;
      END LOOP;
    END IF;

  RETURN lv2_ret_prec_doc_key;

END GetPeriodPrecedingDocKey;

--<EC-DOC>
-------------------------------------------------------------------------------------------------------------------------------------------
-- Procedure      :
-- Description    :
-- Preconditions  : This will only work for MPD documents. MPD documents can have multiple preceding documents.
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
-- Gets the preceding document for period
    FUNCTION GetPeriodPrecedingDocKeyMPD(
        p_contract_doc_id               VARCHAR2,
        p_customer_id                   VARCHAR2,
        p_doc_status                    VARCHAR2,
        p_processing_period             DATE DEFAULT NULL)
    RETURN VARCHAR2
    --</EC-DOC>
    IS

      lv2_ret_prec_doc_key              VARCHAR2(32) := NULL;

      -- Find processed last document for same month on the same contract, and use this
      -- as preceding.
      CURSOR c_Prec(
        cp_contract_doc_id              VARCHAR2,
        cp_customer_id                  VARCHAR2,
        cp_processing_period            DATE)
      IS
        SELECT cd.document_key
          FROM cont_document cd
         WHERE cd.contract_doc_id = cp_contract_doc_id
           AND cd.processing_period =
               NVL(cp_processing_period, cd.processing_period)
           AND cd.reversal_ind = 'N' -- Reversal documents can not be used as preceding
           AND NVL(cd.customer_id, '$NULL$') = NVL(cp_customer_id, '$NULL$')
           AND p_doc_status = cd.status_code
           AND NOT EXISTS
         (SELECT 1
                  FROM cont_document cd2
                 WHERE cd2.preceding_document_key = cd.document_key
                   AND cd2.reversal_ind = 'Y')
         ORDER BY cd.created_date DESC;

    BEGIN
        -- Find out if there are processed documents on the same contract that have no
        -- documents depending on them.
        FOR rsPR IN c_Prec(p_contract_doc_id, p_customer_id, p_processing_period)
        LOOP
            lv2_ret_prec_doc_key := rsPR.document_key;
            EXIT; -- Get only the most recent document
        END LOOP;

        RETURN lv2_ret_prec_doc_key;
    END GetPeriodPrecedingDocKeyMPD;

-----------------------------------------------------------------------------------------------------------------------------
    -----------------------------------------------------------------------
    -- Gets the preceding line item key of given interface.
    -- This function works for quantity line item ifac only.
    ----+----------------------------------+-------------------------------
    FUNCTION find_preceding_li_qty_p(
        prec                               IN OUT NOCOPY t_ifac_cargo_value
    )
    RETURN VARCHAR2 IS

        CURSOR c_pt
        (
            cp_contract_id          VARCHAR2
           ,cp_contract_doc         VARCHAR2
           ,cp_product_id           VARCHAR2
           ,cp_customer_id          VARCHAR2
           ,cp_price_concept_code   VARCHAR2
           ,cp_cargo_name           VARCHAR2
           ,cp_parcel_name          VARCHAR2
           ,cp_qty_type             VARCHAR2
           ,cp_field_id             VARCHAR2
           ,cp_doc_status_code      VARCHAR2
           ,cp_uom1_code            VARCHAR2
           ,cp_uom2_code            VARCHAR2
           ,cp_uom3_code            VARCHAR2
           ,cp_uom4_code            VARCHAR2
           ,cp_ifac_tt_conn_code    VARCHAR2
           ,cp_ifac_li_conn_code    VARCHAR2
           ,cp_line_item_type       VARCHAR2
           ,cp_line_item_based_type VARCHAR2
        ) IS
            SELECT cli.line_item_key
            FROM cont_transaction ct
                ,cont_document cd
                ,cont_transaction_qty ctq
                ,cont_line_item cli
            WHERE ct.transaction_key = ctq.transaction_key
                  AND ct.object_id = cp_contract_id
                  AND cli.transaction_key = ct.transaction_key
                  AND cli.line_item_based_type = cp_line_item_based_type
                  AND (cp_line_item_type is NULL OR cli.line_item_type = cp_line_item_type)
                  AND ctq.uom1_code = cp_uom1_code
                  AND nvl(ctq.uom2_code, 'xx') = nvl(cp_uom2_code, 'xx')
                  AND nvl(ctq.uom3_code, 'xx') = nvl(cp_uom3_code, 'xx')
                  AND nvl(ctq.uom4_code, 'xx') = nvl(cp_uom4_code, 'xx')
                  AND cd.actual_reversal_date IS NULL
                  AND cd.document_key = ct.document_key
                  AND cd.actual_reversal_date IS NULL
                  AND nvl(cp_contract_doc, cd.contract_doc_id) = cd.contract_doc_id
                  AND ct.product_id = cp_product_id
                  AND nvl(cd.customer_id, 'xx') = nvl(cp_customer_id, 'xx')
                  AND ct.price_concept_code = cp_price_concept_code
                  AND ct.cargo_name = cp_cargo_name
                  AND ct.parcel_name = cp_parcel_name
                  AND ct.qty_type = cp_qty_type
                  AND cp_field_id IN
                  (decode(ct.dist_type
                             ,'OBJECT_LIST'
                             ,ec_object_list.object_id_by_uk(ct.dist_code)
                             ,ecdp_objects.getobjidfromcode(ct.dist_object_type
                                                           ,ct.dist_code))
                      ,ec_stream_item_version.field_id(ct.stream_item_id
                                                      ,ct.daytime
                                                      ,'<='))
                  AND
                  (NOT EXISTS
                   (SELECT ct2.transaction_key
                    FROM cont_transaction ct2
                    WHERE (ct2.preceding_trans_key = ct.transaction_key OR
                          ct2.reversed_trans_key = ct.transaction_key)) OR
                   ecdp_transaction.hasreverseddependenttrans(ct.transaction_key) = 'Y' OR
                   ecdp_transaction.GetLatestnGreatestTran(ct.transaction_key)=ct.transaction_key)
                  AND nvl(ct.reversal_ind, 'N') = 'N' -- Reversal transactions can not be used as preceding
                  AND cd.status_code = nvl(cp_doc_status_code, cd.status_code)
                  AND nvl(ct.ifac_tt_conn_code, '$NULL$') =
                  nvl(cp_ifac_tt_conn_code, '$NULL$')
                  AND nvl(cli.ifac_li_conn_code, '$NULL$') =
                  nvl(cp_ifac_li_conn_code, '$NULL$')
            ORDER BY ct.created_date DESC;

        CURSOR c_ptd
        (
            cp_contract_id          VARCHAR2
           ,cp_contract_doc         VARCHAR2
           ,cp_product_id           VARCHAR2
           ,cp_customer_id          VARCHAR2
           ,cp_price_concept_code   VARCHAR2
           ,cp_cargo_name           VARCHAR2
           ,cp_parcel_name          VARCHAR2
           ,cp_qty_type             VARCHAR2
           ,cp_field_id             VARCHAR2
           ,cp_doc_status_code      VARCHAR2
           ,cp_uom1_code            VARCHAR2
           ,cp_uom2_code            VARCHAR2
           ,cp_uom3_code            VARCHAR2
           ,cp_uom4_code            VARCHAR2
           ,cp_ifac_tt_conn_code    VARCHAR2
           ,cp_ifac_li_conn_code    VARCHAR2
           ,cp_line_item_type       VARCHAR2
           ,cp_line_item_based_type VARCHAR2
        ) IS
            SELECT cli.line_item_key
            FROM cont_transaction ct
                ,cont_line_item_dist clid
                ,cont_document cd
                ,cont_line_item cli
            WHERE ct.object_id = cp_contract_id
                  AND cli.line_item_key = clid.line_item_key
                  AND cli.line_item_based_type = cp_line_item_based_type
                  AND (cp_line_item_type is NULL OR cli.line_item_type = cp_line_item_type)
                  AND cd.document_key = ct.document_key
                  AND cd.actual_reversal_date IS NULL
                  AND
                  nvl(cp_contract_doc, cd.contract_doc_id) = cd.contract_doc_id
                  AND clid.transaction_key = ct.transaction_key
                  AND ct.product_id = cp_product_id
                  AND nvl(cd.customer_id, 'xx') = nvl(cp_customer_id, 'xx')
                  AND ct.price_concept_code = cp_price_concept_code
                  AND ct.cargo_name = cp_cargo_name
                  AND ct.parcel_name = cp_parcel_name
                  AND ct.qty_type = cp_qty_type
                  AND clid.dist_id = cp_field_id
                  AND clid.line_item_based_type = 'QTY'
                  AND clid.uom1_code = cp_uom1_code
                  AND nvl(clid.uom2_code, 'xx') = nvl(cp_uom2_code, 'xx')
                  AND nvl(clid.uom3_code, 'xx') = nvl(cp_uom3_code, 'xx')
                  AND nvl(clid.uom4_code, 'xx') = nvl(cp_uom4_code, 'xx')
                  AND
                  (NOT EXISTS
                   (SELECT ct2.transaction_key
                    FROM cont_transaction ct2
                    WHERE (ct2.preceding_trans_key = ct.transaction_key OR
                          ct2.reversed_trans_key = ct.transaction_key)) OR
                   ecdp_transaction.hasreverseddependenttrans(ct.transaction_key) = 'Y' OR
                   ecdp_transaction.GetLatestnGreatestTran(ct.transaction_key)=ct.transaction_key)
                  AND nvl(ct.reversal_ind, 'N') = 'N' -- Reversal transactions can not be used as preceding
                  AND cd.status_code = nvl(cp_doc_status_code, cd.status_code)
                  AND nvl(ct.ifac_tt_conn_code, '$NULL$') =
                  nvl(cp_ifac_tt_conn_code, '$NULL$')
                  AND nvl(cli.ifac_li_conn_code, '$NULL$') =
                  nvl(cp_ifac_li_conn_code, '$NULL$')
            ORDER BY ct.created_date DESC;

        CURSOR c_ptc
        (
            cp_contract_id          VARCHAR2
           ,cp_contract_doc         VARCHAR2
           ,cp_product_id           VARCHAR2
           ,cp_customer_id          VARCHAR2
           ,cp_price_concept_code   VARCHAR2
           ,cp_cargo_name           VARCHAR2
           ,cp_parcel_name          VARCHAR2
           ,cp_qty_type             VARCHAR2
           ,cp_field_id             VARCHAR2
           ,cp_vendor_id            VARCHAR2
           ,cp_doc_status_code      VARCHAR2
           ,cp_uom1_code            VARCHAR2
           ,cp_uom2_code            VARCHAR2
           ,cp_uom3_code            VARCHAR2
           ,cp_uom4_code            VARCHAR2
           ,cp_ifac_tt_conn_code    VARCHAR2
           ,cp_ifac_li_conn_code    VARCHAR2
           ,cp_line_item_type       VARCHAR2
           ,cp_line_item_based_type VARCHAR2
        ) IS
            SELECT cli.line_item_key
            FROM cont_transaction ct
                ,cont_li_dist_company clidc
                ,cont_document cd
                ,cont_line_item cli
            WHERE ct.object_id = cp_contract_id
                  AND cli.line_item_key = clidc.line_item_key
                  AND cli.line_item_based_type = cp_line_item_based_type
                  AND (cp_line_item_type is NULL OR cli.line_item_type = cp_line_item_type)
                  AND cd.document_key = ct.document_key
                  AND cd.actual_reversal_date IS NULL
                  AND
                  nvl(cp_contract_doc, cd.contract_doc_id) = cd.contract_doc_id
                  AND clidc.transaction_key = ct.transaction_key
                  AND ct.product_id = cp_product_id
                  AND nvl(cd.customer_id, 'xx') = nvl(cp_customer_id, 'xx')
                  AND ct.price_concept_code = cp_price_concept_code
                  AND ct.cargo_name = cp_cargo_name
                  AND ct.parcel_name = cp_parcel_name
                  AND ct.qty_type = cp_qty_type
                  AND clidc.dist_id = cp_field_id
                  AND clidc.vendor_id = cp_vendor_id
                  AND clidc.uom1_code = cp_uom1_code
                  AND nvl(clidc.uom2_code, 'xx') = nvl(cp_uom2_code, 'xx')
                  AND nvl(clidc.uom3_code, 'xx') = nvl(cp_uom3_code, 'xx')
                  AND nvl(clidc.uom4_code, 'xx') = nvl(cp_uom4_code, 'xx')
                  AND clidc.line_item_based_type = 'QTY'
                  AND
                  (NOT EXISTS
                   (SELECT ct2.transaction_key
                    FROM cont_transaction ct2
                    WHERE (ct2.preceding_trans_key = ct.transaction_key OR
                          ct2.reversed_trans_key = ct.transaction_key)) OR
                          ecdp_transaction.hasreverseddependenttrans(ct.transaction_key) = 'Y' OR
                          ecdp_transaction.GetLatestnGreatestTran(ct.transaction_key)=ct.transaction_key)
                  AND nvl(ct.reversal_ind, 'N') = 'N' -- Reversal transactions can not be used as preceding
                  AND nvl(ct.ifac_tt_conn_code, '$NULL$') =
                  nvl(cp_ifac_tt_conn_code, '$NULL$')
                  AND nvl(cli.ifac_li_conn_code, '$NULL$') =
                  nvl(cp_ifac_li_conn_code, '$NULL$')
            ORDER BY ct.created_date DESC;

        lv2_comp            VARCHAR2(32);
        lv2_trans_key       VARCHAR2(32);
        lv2_contract_doc    VARCHAR2(32);
        lv2_doc_status_code VARCHAR2(10);
        lv2_line_item_key   VARCHAR2(32);
    BEGIN
        IF prec.LINE_ITEM_BASED_TYPE != ecdp_revn_ft_constants.li_btype_quantity THEN
            RETURN NULL;
        END IF;

       /* IF ec_contract_doc_version.doc_concept_code(
                ec_transaction_template.contract_doc_id(prec.trans_temp_id),prec.processing_period,'<=') = 'MULTI_PERIOD' THEN
            lv2_contract_doc := ec_transaction_template.contract_doc_id(prec.trans_temp_id);
        END IF;*/

        IF prec.INTERFACE_LEVEL = ecdp_revn_ifac_wrapper.gconst_level_line_item THEN
            FOR rst IN c_pt(prec.contract_id
                           ,lv2_contract_doc
                           ,prec.product_id
                           ,prec.customer_id
                           ,prec.price_concept_code
                           ,prec.cargo_no
                           ,prec.parcel_no
                           ,prec.qty_type
                           ,prec.profit_center_id
                           ,lv2_doc_status_code
                           ,prec.uom1_code
                           ,prec.uom2_code
                           ,prec.uom3_code
                           ,prec.uom4_code
                           ,prec.ifac_tt_conn_code
                           ,prec.ifac_li_conn_code
                           ,prec.line_item_type
                           ,prec.line_item_based_type) LOOP
                lv2_line_item_key := rst.line_item_key;
                EXIT;
            END LOOP;
        ELSIF prec.INTERFACE_LEVEL = ecdp_revn_ifac_wrapper.gconst_level_profit_center THEN
            FOR rsd IN c_ptd(prec.contract_id
                            ,lv2_contract_doc
                            ,prec.product_id
                            ,prec.customer_id
                            ,prec.price_concept_code
                            ,prec.cargo_no
                            ,prec.parcel_no
                            ,prec.qty_type
                            ,prec.profit_center_id
                            ,lv2_doc_status_code
                            ,prec.uom1_code
                            ,prec.uom2_code
                            ,prec.uom3_code
                            ,prec.uom4_code
                            ,prec.ifac_tt_conn_code
                            ,prec.ifac_li_conn_code
                            ,prec.line_item_type
                            ,prec.line_item_based_type) LOOP
                lv2_line_item_key := rsd.line_item_key;
                EXIT;
            END LOOP;
        ELSIF prec.INTERFACE_LEVEL = ecdp_revn_ifac_wrapper.gconst_level_vendor THEN
            FOR rsc IN c_ptc(prec.contract_id
                            ,lv2_contract_doc
                            ,prec.product_id
                            ,prec.customer_id
                            ,prec.price_concept_code
                            ,prec.cargo_no
                            ,prec.parcel_no
                            ,prec.qty_type
                            ,prec.profit_center_id
                            ,prec.vendor_id
                            ,lv2_doc_status_code
                            ,prec.uom1_code
                            ,prec.uom2_code
                            ,prec.uom3_code
                            ,prec.uom4_code
                            ,prec.ifac_tt_conn_code
                            ,prec.ifac_li_conn_code
                            ,prec.line_item_type
                            ,prec.line_item_based_type) LOOP
                lv2_line_item_key := rsc.line_item_key;
                EXIT;
            END LOOP;
        END IF;

        RETURN lv2_line_item_key;
    END;

---------------------------------------------------------------------------------------------------------



    -----------------------------------------------------------------------
    -- Gets the preceding line item key of given interface.
    -- This function works for quantity line item ifac only.
    ----+----------------------------------+-------------------------------
    FUNCTION find_preceding_li_qty_p(
        prec                               IN OUT NOCOPY t_ifac_sales_qty
    )
    RETURN VARCHAR2 IS

        CURSOR c_pt
        (
            cp_contract_id          VARCHAR2
           ,cp_contract_doc         VARCHAR2
           ,cp_period_from          DATE
           ,cp_period_to            DATE
           ,cp_product_id           VARCHAR2
           ,cp_customer_id          VARCHAR2
           ,cp_price_concept_code   VARCHAR2
           ,cp_delivery_point_id    VARCHAR2
           ,cp_field_id             VARCHAR2
           ,cp_doc_status_code      VARCHAR2
           ,cp_unique_key_1         VARCHAR2
           ,cp_unique_key_2         VARCHAR2
           ,cp_uom1_code            VARCHAR2
           ,cp_uom2_code            VARCHAR2
           ,cp_uom3_code            VARCHAR2
           ,cp_uom4_code            VARCHAR2
           ,cp_ifac_tt_conn_code    VARCHAR2
           ,cp_ifac_li_conn_code    VARCHAR2
           ,cp_line_item_type       VARCHAR2
           ,cp_line_item_based_type VARCHAR2
        ) IS
            SELECT cli.line_item_key
            FROM cont_transaction ct
                ,cont_document cd
                ,cont_transaction_qty ctq
                ,cont_line_item cli
            WHERE ct.transaction_key = ctq.transaction_key
                  AND ct.object_id = cp_contract_id
                  AND cli.transaction_key = ct.transaction_key
                  AND cli.line_item_based_type = cp_line_item_based_type
                  AND (cp_line_item_type is NULL OR cli.line_item_type = cp_line_item_type)
                  AND ctq.uom1_code = cp_uom1_code
                  AND nvl(ctq.uom2_code, 'xx') = nvl(cp_uom2_code, 'xx')
                  AND nvl(ctq.uom3_code, 'xx') = nvl(cp_uom3_code, 'xx')
                  AND nvl(ctq.uom4_code, 'xx') = nvl(cp_uom4_code, 'xx')
                  AND cd.actual_reversal_date IS NULL
                  AND cd.document_key = ct.document_key
                  AND cd.actual_reversal_date IS NULL
                  AND nvl(cp_contract_doc, cd.contract_doc_id) = cd.contract_doc_id
                  AND ct.supply_from_date = cp_period_from
                  AND ct.supply_to_date = cp_period_to
                  AND ct.product_id = cp_product_id
                  AND nvl(cd.customer_id, 'xx') = nvl(cp_customer_id, 'xx')
                  AND ct.price_concept_code = cp_price_concept_code
                  AND ct.delivery_point_id = cp_delivery_point_id
                  AND cp_field_id IN
                  (decode(ct.dist_type
                             ,'OBJECT_LIST'
                             ,ec_object_list.object_id_by_uk(ct.dist_code)
                             ,ecdp_objects.getobjidfromcode(ct.dist_object_type
                                                           ,ct.dist_code))
                      ,ec_stream_item_version.field_id(ct.stream_item_id
                                                      ,ct.daytime
                                                      ,'<='))
                  AND
                  (NOT EXISTS
                   (SELECT ct2.transaction_key
                    FROM cont_transaction ct2
                    WHERE (ct2.preceding_trans_key = ct.transaction_key OR
                          ct2.reversed_trans_key = ct.transaction_key)) OR
                   ecdp_transaction.hasreverseddependenttrans(ct.transaction_key) = 'Y' OR
                   ecdp_transaction.GetLatestnGreatestTran(ct.transaction_key)=ct.transaction_key)
                  AND nvl(ct.reversal_ind, 'N') = 'N' -- Reversal transactions can not be used as preceding
                  AND cd.status_code = nvl(cp_doc_status_code, cd.status_code)
                  AND
                  nvl(ct.ifac_unique_key_1, 'X') = nvl(cp_unique_key_1, 'X')
                  AND
                  nvl(ct.ifac_unique_key_2, 'X') = nvl(cp_unique_key_2, 'X')
                  AND nvl(ct.ifac_tt_conn_code, '$NULL$') =
                  nvl(cp_ifac_tt_conn_code, '$NULL$')
                  AND nvl(cli.ifac_li_conn_code, '$NULL$') =
                  nvl(cp_ifac_li_conn_code, '$NULL$')
            ORDER BY ct.created_date DESC;

        CURSOR c_ptd
        (
            cp_contract_id          VARCHAR2
           ,cp_contract_doc         VARCHAR2
           ,cp_period_from          DATE
           ,cp_period_to            DATE
           ,cp_product_id           VARCHAR2
           ,cp_customer_id          VARCHAR2
           ,cp_price_concept_code   VARCHAR2
           ,cp_delivery_point_id    VARCHAR2
           ,cp_field_id             VARCHAR2
           ,cp_doc_status_code      VARCHAR2
           ,cp_unique_key_1         VARCHAR2
           ,cp_unique_key_2         VARCHAR2
           ,cp_uom1_code            VARCHAR2
           ,cp_uom2_code            VARCHAR2
           ,cp_uom3_code            VARCHAR2
           ,cp_uom4_code            VARCHAR2
           ,cp_ifac_tt_conn_code    VARCHAR2
           ,cp_ifac_li_conn_code    VARCHAR2
           ,cp_line_item_type       VARCHAR2
           ,cp_line_item_based_type VARCHAR2
        ) IS
            SELECT cli.line_item_key
            FROM cont_transaction ct
                ,cont_line_item_dist clid
                ,cont_document cd
                ,cont_line_item cli
            WHERE ct.object_id = cp_contract_id
                  AND cli.line_item_key = clid.line_item_key
                  AND cli.line_item_based_type = cp_line_item_based_type
                  AND (cp_line_item_type is NULL OR cli.line_item_type = cp_line_item_type)
                  AND cd.document_key = ct.document_key
                  AND cd.actual_reversal_date IS NULL
                  AND
                  nvl(cp_contract_doc, cd.contract_doc_id) = cd.contract_doc_id
                  AND clid.transaction_key = ct.transaction_key
                  AND ct.supply_from_date = cp_period_from
                  AND ct.supply_to_date = cp_period_to
                  AND ct.product_id = cp_product_id
                  AND nvl(cd.customer_id, 'xx') = nvl(cp_customer_id, 'xx')
                  AND ct.price_concept_code = cp_price_concept_code
                  AND ct.delivery_point_id = cp_delivery_point_id
                  AND clid.dist_id = cp_field_id
                  AND clid.line_item_based_type = 'QTY'
                  AND clid.uom1_code = cp_uom1_code
                  AND nvl(clid.uom2_code, 'xx') = nvl(cp_uom2_code, 'xx')
                  AND nvl(clid.uom3_code, 'xx') = nvl(cp_uom3_code, 'xx')
                  AND nvl(clid.uom4_code, 'xx') = nvl(cp_uom4_code, 'xx')
                  AND
                  (NOT EXISTS
                   (SELECT ct2.transaction_key
                    FROM cont_transaction ct2
                    WHERE (ct2.preceding_trans_key = ct.transaction_key OR
                          ct2.reversed_trans_key = ct.transaction_key)) OR
                   ecdp_transaction.hasreverseddependenttrans(ct.transaction_key) = 'Y' OR
                   ecdp_transaction.GetLatestnGreatestTran(ct.transaction_key)=ct.transaction_key)
                  AND nvl(ct.reversal_ind, 'N') = 'N' -- Reversal transactions can not be used as preceding
                  AND cd.status_code = nvl(cp_doc_status_code, cd.status_code)
                  AND
                  nvl(ct.ifac_unique_key_1, 'X') = nvl(cp_unique_key_1, 'X')
                  AND
                  nvl(ct.ifac_unique_key_2, 'X') = nvl(cp_unique_key_2, 'X')
                  AND nvl(ct.ifac_tt_conn_code, '$NULL$') =
                  nvl(cp_ifac_tt_conn_code, '$NULL$')
                  AND nvl(cli.ifac_li_conn_code, '$NULL$') =
                  nvl(cp_ifac_li_conn_code, '$NULL$')
            ORDER BY ct.created_date DESC;

        CURSOR c_ptc
        (
            cp_contract_id          VARCHAR2
           ,cp_contract_doc         VARCHAR2
           ,cp_period_from          DATE
           ,cp_period_to            DATE
           ,cp_product_id           VARCHAR2
           ,cp_customer_id          VARCHAR2
           ,cp_price_concept_code   VARCHAR2
           ,cp_delivery_point_id    VARCHAR2
           ,cp_field_id             VARCHAR2
           ,cp_vendor_id            VARCHAR2
           ,cp_doc_status_code      VARCHAR2
           ,cp_unique_key_1         VARCHAR2
           ,cp_unique_key_2         VARCHAR2
           ,cp_uom1_code            VARCHAR2
           ,cp_uom2_code            VARCHAR2
           ,cp_uom3_code            VARCHAR2
           ,cp_uom4_code            VARCHAR2
           ,cp_ifac_tt_conn_code    VARCHAR2
           ,cp_ifac_li_conn_code    VARCHAR2
           ,cp_line_item_type       VARCHAR2
           ,cp_line_item_based_type VARCHAR2
        ) IS
            SELECT cli.line_item_key
            FROM cont_transaction ct
                ,cont_li_dist_company clidc
                ,cont_document cd
                ,cont_line_item cli
            WHERE ct.object_id = cp_contract_id
                  AND cli.line_item_key = clidc.line_item_key
                  AND cli.line_item_based_type = cp_line_item_based_type
                  AND (cp_line_item_type is NULL OR cli.line_item_type = cp_line_item_type)
                  AND cd.document_key = ct.document_key
                  AND cd.actual_reversal_date IS NULL
                  AND
                  nvl(cp_contract_doc, cd.contract_doc_id) = cd.contract_doc_id
                  AND clidc.transaction_key = ct.transaction_key
                  AND ct.supply_from_date = cp_period_from
                  AND ct.supply_to_date = cp_period_to
                  AND ct.product_id = cp_product_id
                  AND nvl(cd.customer_id, 'xx') = nvl(cp_customer_id, 'xx')
                  AND ct.price_concept_code = cp_price_concept_code
                  AND ct.delivery_point_id = cp_delivery_point_id
                  AND clidc.dist_id = cp_field_id
                  AND clidc.vendor_id = cp_vendor_id
                  AND clidc.uom1_code = cp_uom1_code
                  AND nvl(clidc.uom2_code, 'xx') = nvl(cp_uom2_code, 'xx')
                  AND nvl(clidc.uom3_code, 'xx') = nvl(cp_uom3_code, 'xx')
                  AND nvl(clidc.uom4_code, 'xx') = nvl(cp_uom4_code, 'xx')
                  AND clidc.line_item_based_type = 'QTY'
                  AND
                  (NOT EXISTS
                   (SELECT ct2.transaction_key
                    FROM cont_transaction ct2
                    WHERE (ct2.preceding_trans_key = ct.transaction_key OR
                          ct2.reversed_trans_key = ct.transaction_key)) OR
                          ecdp_transaction.hasreverseddependenttrans(ct.transaction_key) = 'Y' OR
                          ecdp_transaction.GetLatestnGreatestTran(ct.transaction_key)=ct.transaction_key)
                  AND nvl(ct.reversal_ind, 'N') = 'N' -- Reversal transactions can not be used as preceding
                  AND cd.status_code = nvl(cp_doc_status_code, cd.status_code)
                  AND
                  nvl(ct.ifac_unique_key_1, 'X') = nvl(cp_unique_key_1, 'X')
                  AND
                  nvl(ct.ifac_unique_key_2, 'X') = nvl(cp_unique_key_2, 'X')
                  AND nvl(ct.ifac_tt_conn_code, '$NULL$') =
                  nvl(cp_ifac_tt_conn_code, '$NULL$')
                  AND nvl(cli.ifac_li_conn_code, '$NULL$') =
                  nvl(cp_ifac_li_conn_code, '$NULL$')
            ORDER BY ct.created_date DESC;

        lv2_comp            VARCHAR2(32);
        lv2_trans_key       VARCHAR2(32);
        lv2_contract_doc    VARCHAR2(32);
        lv2_doc_status_code VARCHAR2(10);
        lv2_line_item_key   VARCHAR2(32);
    BEGIN
        IF prec.LINE_ITEM_BASED_TYPE != ecdp_revn_ft_constants.li_btype_quantity THEN
            RETURN NULL;
        END IF;

        IF ec_contract_doc_version.doc_concept_code(
                ec_transaction_template.contract_doc_id(prec.trans_temp_id),prec.processing_period,'<=') = 'MULTI_PERIOD' THEN
            lv2_contract_doc := ec_transaction_template.contract_doc_id(prec.trans_temp_id);
        ELSIF NOT ecdp_contract_setup.contracthasdocsetupconcept(
                prec.contract_id,prec.processing_period,'MULTI_PERIOD') THEN
            -- None MPD's can distinguish between a final and an accrual interface value
            lv2_doc_status_code := prec.doc_status;
        END IF;

        IF prec.INTERFACE_LEVEL = ecdp_revn_ifac_wrapper.gconst_level_line_item THEN
            FOR rst IN c_pt(prec.contract_id
                           ,lv2_contract_doc
                           ,prec.period_start_date
                           ,prec.period_end_date
                           ,prec.product_id
                           ,prec.customer_id
                           ,prec.price_concept_code
                           ,prec.delivery_point_id
                           ,prec.profit_center_id
                           ,lv2_doc_status_code
                           ,prec.unique_key_1
                           ,prec.unique_key_2
                           ,prec.uom1_code
                           ,prec.uom2_code
                           ,prec.uom3_code
                           ,prec.uom4_code
                           ,prec.ifac_tt_conn_code
                           ,prec.ifac_li_conn_code
                           ,prec.line_item_type
                           ,prec.line_item_based_type) LOOP
                lv2_line_item_key := rst.line_item_key;
                EXIT;
            END LOOP;
        ELSIF prec.INTERFACE_LEVEL = ecdp_revn_ifac_wrapper.gconst_level_profit_center THEN
            FOR rsd IN c_ptd(prec.contract_id
                            ,lv2_contract_doc
                            ,prec.period_start_date
                            ,prec.period_end_date
                            ,prec.product_id
                            ,prec.customer_id
                            ,prec.price_concept_code
                            ,prec.delivery_point_id
                            ,prec.profit_center_id
                            ,lv2_doc_status_code
                            ,prec.unique_key_1
                            ,prec.unique_key_2
                            ,prec.uom1_code
                            ,prec.uom2_code
                            ,prec.uom3_code
                            ,prec.uom4_code
                            ,prec.ifac_tt_conn_code
                            ,prec.ifac_li_conn_code
                            ,prec.line_item_type
                            ,prec.line_item_based_type) LOOP
                lv2_line_item_key := rsd.line_item_key;
                EXIT;
            END LOOP;
        ELSIF prec.INTERFACE_LEVEL = ecdp_revn_ifac_wrapper.gconst_level_vendor THEN
            FOR rsc IN c_ptc(prec.contract_id
                            ,lv2_contract_doc
                            ,prec.period_start_date
                            ,prec.period_end_date
                            ,prec.product_id
                            ,prec.customer_id
                            ,prec.price_concept_code
                            ,prec.delivery_point_id
                            ,prec.profit_center_id
                            ,prec.vendor_id
                            ,lv2_doc_status_code
                            ,prec.unique_key_1
                            ,prec.unique_key_2
                            ,prec.uom1_code
                            ,prec.uom2_code
                            ,prec.uom3_code
                            ,prec.uom4_code
                            ,prec.ifac_tt_conn_code
                            ,prec.ifac_li_conn_code
                            ,prec.line_item_type
                            ,prec.line_item_based_type) LOOP
                lv2_line_item_key := rsc.line_item_key;
                EXIT;
            END LOOP;
        END IF;

        RETURN lv2_line_item_key;
    END;


    -----------------------------------------------------------------------
    -- Gets the preceding line item key of given interface.
    -- This function works for non-quantity line item ifac only.
    ----+----------------------------------+-------------------------------
    FUNCTION find_preceding_li_nq_vend_p(
        prec                               IN OUT NOCOPY t_ifac_sales_qty
       ,p_document_setup_id_overwrite      contract_doc.object_id%TYPE
       ,p_document_status_overwrite        cont_document.status_code%TYPE
    )
    RETURN VARCHAR2 IS
        CURSOR c_ptc
        (
            cp_contract_id          VARCHAR2
           ,cp_contract_doc         VARCHAR2
           ,cp_period_from          DATE
           ,cp_period_to            DATE
           ,cp_product_id           VARCHAR2
           ,cp_customer_id          VARCHAR2
           ,cp_price_concept_code   VARCHAR2
           ,cp_delivery_point_id    VARCHAR2
           ,cp_field_id             VARCHAR2
           ,cp_vendor_id            VARCHAR2
           ,cp_doc_status_code      VARCHAR2
           ,cp_unique_key_1         VARCHAR2
           ,cp_unique_key_2         VARCHAR2
           ,cp_li_unique_key_1      VARCHAR2
           ,cp_li_unique_key_2      VARCHAR2
           ,cp_uom1_code            VARCHAR2
           ,cp_uom2_code            VARCHAR2
           ,cp_uom3_code            VARCHAR2
           ,cp_uom4_code            VARCHAR2
           ,cp_ifac_tt_conn_code    VARCHAR2
           ,cp_ifac_li_conn_code    VARCHAR2
           ,cp_line_item_type       VARCHAR2
           ,cp_line_item_based_type VARCHAR2
        ) IS
            SELECT cli.line_item_key
            FROM cont_transaction ct
                ,cont_transaction_qty ctq
                ,cont_li_dist_company clidc
                ,cont_document cd
                ,cont_line_item cli
            WHERE ct.object_id = cp_contract_id
                  AND ct.transaction_key = ctq.transaction_key
                  AND cli.line_item_key = clidc.line_item_key
                  AND cli.line_item_based_type = cp_line_item_based_type
                  AND ((cp_line_item_type is NULL AND cli.line_item_type IS NULL) OR cli.line_item_type = cp_line_item_type)
                  AND cd.document_key = ct.document_key
                  AND nvl(cp_contract_doc, cd.contract_doc_id) = cd.contract_doc_id
                  AND clidc.transaction_key = ct.transaction_key
                  AND ct.supply_from_date = cp_period_from
                  AND ct.supply_to_date = cp_period_to
                  AND ct.product_id = cp_product_id
                  AND nvl(cd.customer_id, 'xx') = nvl(cp_customer_id, 'xx')
                  AND ct.price_concept_code = cp_price_concept_code
                  AND ct.delivery_point_id = cp_delivery_point_id
                  AND clidc.dist_id = cp_field_id
                  AND clidc.vendor_id = cp_vendor_id
                  AND nvl(ctq.uom1_code, 'xx') = nvl(cp_uom1_code, 'xx')
                  AND nvl(ctq.uom2_code, 'xx') = nvl(cp_uom2_code, 'xx')
                  AND nvl(ctq.uom3_code, 'xx') = nvl(cp_uom3_code, 'xx')
                  AND nvl(ctq.uom4_code, 'xx') = nvl(cp_uom4_code, 'xx')
                  AND
                  (NOT EXISTS
                   (SELECT ct2.transaction_key
                    FROM cont_transaction ct2
                    WHERE (ct2.preceding_trans_key = ct.transaction_key OR
                          ct2.reversed_trans_key = ct.transaction_key)) OR
                   ecdp_transaction.hasreverseddependenttrans(ct.transaction_key) = 'Y')
                  AND nvl(ct.reversal_ind, 'N') = 'N' -- Reversal transactions can not be used as preceding
                  AND cd.status_code = nvl(cp_doc_status_code, cd.status_code)
                  AND nvl(ct.ifac_unique_key_1, 'X') = nvl(cp_unique_key_1, 'X')
                  AND nvl(ct.ifac_unique_key_2, 'X') = nvl(cp_unique_key_2, 'X')
                  AND nvl(ct.ifac_tt_conn_code, '$NULL$') = nvl(cp_ifac_tt_conn_code, '$NULL$')
                  AND nvl(cli.ifac_li_conn_code, '$NULL$') = nvl(cp_ifac_li_conn_code, '$NULL$')
                  AND cli.interest_line_item_key IS NULL -- only get the main interest line item
                  AND nvl(cli.li_unique_key_1, '$NULL$') = nvl(cp_li_unique_key_1, '$NULL$')
                  AND nvl(cli.li_unique_key_2, '$NULL$') = nvl(cp_li_unique_key_2, '$NULL$')
            ORDER BY ct.created_date DESC;

        lv2_line_item_key   VARCHAR2(32);
    BEGIN
        IF prec.LINE_ITEM_BASED_TYPE = ecdp_revn_ft_constants.li_btype_quantity THEN
            RETURN NULL;
        END IF;

        IF prec.INTERFACE_LEVEL != ecdp_revn_ifac_wrapper.gconst_level_vendor THEN
            RETURN NULL;
        END IF;

        FOR rsc IN c_ptc(
                prec.contract_id
               ,p_document_setup_id_overwrite
               ,prec.period_start_date
               ,prec.period_end_date
               ,prec.product_id
               ,prec.customer_id
               ,prec.price_concept_code
               ,prec.delivery_point_id
               ,prec.profit_center_id
               ,prec.vendor_id
               ,p_document_status_overwrite
               ,prec.unique_key_1
               ,prec.unique_key_2
               ,prec.li_unique_key_1
               ,prec.li_unique_key_2
               ,prec.uom1_code
               ,prec.uom2_code
               ,prec.uom3_code
               ,prec.uom4_code
               ,prec.ifac_tt_conn_code
               ,prec.ifac_li_conn_code
               ,prec.line_item_type
               ,prec.line_item_based_type) LOOP
            lv2_line_item_key := rsc.line_item_key;
            EXIT;
        END LOOP;

        RETURN lv2_line_item_key;
    END;



  -----------------------------------------------------------------------
    -- Gets the preceding line item key of given interface.
    -- This function works for non-quantity line item ifac only.
    ----+----------------------------------+-------------------------------
    FUNCTION find_preceding_li_nq_vend_p(
        prec                               IN OUT NOCOPY t_ifac_cargo_value
       ,p_document_setup_id_overwrite      contract_doc.object_id%TYPE
       ,p_document_status_overwrite        cont_document.status_code%TYPE
    )
    RETURN VARCHAR2 IS
        CURSOR c_ptc
        (
            cp_contract_id          VARCHAR2
           ,cp_contract_doc         VARCHAR2
           ,cp_product_id           VARCHAR2
           ,cp_customer_id          VARCHAR2
           ,cp_price_concept_code   VARCHAR2
           ,cp_cargo_name           VARCHAR2
           ,cp_parcel_name          VARCHAR2
           ,cp_qty_type             VARCHAR2
           ,cp_field_id             VARCHAR2
           ,cp_vendor_id            VARCHAR2
           ,cp_doc_status_code      VARCHAR2
           ,cp_li_unique_key_1      VARCHAR2
           ,cp_li_unique_key_2      VARCHAR2
           ,cp_uom1_code            VARCHAR2
           ,cp_uom2_code            VARCHAR2
           ,cp_uom3_code            VARCHAR2
           ,cp_uom4_code            VARCHAR2
           ,cp_ifac_tt_conn_code    VARCHAR2
           ,cp_ifac_li_conn_code    VARCHAR2
           ,cp_line_item_type       VARCHAR2
           ,cp_line_item_based_type VARCHAR2
        ) IS
            SELECT cli.line_item_key
            FROM cont_transaction ct
                ,cont_transaction_qty ctq
                ,cont_li_dist_company clidc
                ,cont_document cd
                ,cont_line_item cli
            WHERE ct.object_id = cp_contract_id
                  AND ct.transaction_key = ctq.transaction_key
                  AND cli.line_item_key = clidc.line_item_key
                  AND cli.line_item_based_type = cp_line_item_based_type
                  AND ((cp_line_item_type is NULL AND cli.line_item_type IS NULL) OR cli.line_item_type = cp_line_item_type)
                  AND cd.document_key = ct.document_key
                  AND nvl(cp_contract_doc, cd.contract_doc_id) = cd.contract_doc_id
                  AND clidc.transaction_key = ct.transaction_key
                  AND ct.product_id = cp_product_id
                  AND nvl(cd.customer_id, 'xx') = nvl(cp_customer_id, 'xx')
                  AND ct.price_concept_code = cp_price_concept_code
                  AND ct.cargo_name = cp_cargo_name
                  AND ct.parcel_name = cp_parcel_name
                  AND ct.qty_type = cp_qty_type
                  AND clidc.dist_id = cp_field_id
                  AND clidc.vendor_id = cp_vendor_id
                  AND nvl(ctq.uom1_code, 'xx') = nvl(cp_uom1_code, 'xx')
                  AND nvl(ctq.uom2_code, 'xx') = nvl(cp_uom2_code, 'xx')
                  AND nvl(ctq.uom3_code, 'xx') = nvl(cp_uom3_code, 'xx')
                  AND nvl(ctq.uom4_code, 'xx') = nvl(cp_uom4_code, 'xx')
                  AND
                  (NOT EXISTS
                   (SELECT ct2.transaction_key
                    FROM cont_transaction ct2
                    WHERE (ct2.preceding_trans_key = ct.transaction_key OR
                          ct2.reversed_trans_key = ct.transaction_key)) OR
                   ecdp_transaction.hasreverseddependenttrans(ct.transaction_key) = 'Y')
                  AND nvl(ct.reversal_ind, 'N') = 'N' -- Reversal transactions can not be used as preceding
                  AND cd.status_code = nvl(cp_doc_status_code, cd.status_code)
                  AND nvl(ct.ifac_tt_conn_code, '$NULL$') = nvl(cp_ifac_tt_conn_code, '$NULL$')
                  AND nvl(cli.ifac_li_conn_code, '$NULL$') = nvl(cp_ifac_li_conn_code, '$NULL$')
                  AND cli.interest_line_item_key IS NULL -- only get the main interest line item
                  AND nvl(cli.li_unique_key_1, '$NULL$') = nvl(cp_li_unique_key_1, '$NULL$')
                  AND nvl(cli.li_unique_key_2, '$NULL$') = nvl(cp_li_unique_key_2, '$NULL$')
            ORDER BY ct.created_date DESC;

        lv2_line_item_key   VARCHAR2(32);
    BEGIN
        IF prec.LINE_ITEM_BASED_TYPE = ecdp_revn_ft_constants.li_btype_quantity THEN
            RETURN NULL;
        END IF;

        IF prec.INTERFACE_LEVEL != ecdp_revn_ifac_wrapper.gconst_level_vendor THEN
            RETURN NULL;
        END IF;

        FOR rsc IN c_ptc(
                prec.contract_id
               ,p_document_setup_id_overwrite
               ,prec.product_id
               ,prec.customer_id
               ,prec.price_concept_code
               ,prec.cargo_no
               ,prec.parcel_no
               ,prec.qty_type
               ,prec.profit_center_id
               ,prec.vendor_id
               ,p_document_status_overwrite
               ,prec.li_unique_key_1
               ,prec.li_unique_key_2
               ,prec.uom1_code
               ,prec.uom2_code
               ,prec.uom3_code
               ,prec.uom4_code
               ,prec.ifac_tt_conn_code
               ,prec.ifac_li_conn_code
               ,prec.line_item_type
               ,prec.line_item_based_type) LOOP
            lv2_line_item_key := rsc.line_item_key;
            EXIT;
        END LOOP;

        RETURN lv2_line_item_key;
    END;


    -----------------------------------------------------------------------
    -- Gets the preceding line item key of given interface.
    -- This function works for non-quantity line item ifac only.
    ----+----------------------------------+-------------------------------
    FUNCTION find_preceding_li_nq_pc_p(
        prec                               IN OUT NOCOPY t_ifac_sales_qty
       ,p_document_setup_id_overwrite      contract_doc.object_id%TYPE
       ,p_document_status_overwrite        cont_document.status_code%TYPE
    )
    RETURN VARCHAR2 IS
        CURSOR c_ptd
        (
            cp_contract_id          VARCHAR2
           ,cp_contract_doc         VARCHAR2
           ,cp_period_from          DATE
           ,cp_period_to            DATE
           ,cp_product_id           VARCHAR2
           ,cp_customer_id          VARCHAR2
           ,cp_price_concept_code   VARCHAR2
           ,cp_delivery_point_id    VARCHAR2
           ,cp_field_id             VARCHAR2
           ,cp_doc_status_code      VARCHAR2
           ,cp_unique_key_1         VARCHAR2
           ,cp_unique_key_2         VARCHAR2
           ,cp_li_unique_key_1      VARCHAR2
           ,cp_li_unique_key_2      VARCHAR2
           ,cp_uom1_code            VARCHAR2
           ,cp_uom2_code            VARCHAR2
           ,cp_uom3_code            VARCHAR2
           ,cp_uom4_code            VARCHAR2
           ,cp_ifac_tt_conn_code    VARCHAR2
           ,cp_ifac_li_conn_code    VARCHAR2
           ,cp_line_item_type       VARCHAR2
           ,cp_line_item_based_type VARCHAR2
        ) IS
            SELECT cli.line_item_key
            FROM cont_transaction ct
                ,cont_transaction_qty ctq
                ,cont_line_item_dist clid
                ,cont_document cd
                ,cont_line_item cli
            WHERE ct.object_id = cp_contract_id
                  AND ct.transaction_key = ctq.transaction_key
                  AND cli.line_item_key = clid.line_item_key
                  AND cli.line_item_based_type = cp_line_item_based_type
                  AND ((cp_line_item_type is NULL AND cli.line_item_type IS NULL) OR cli.line_item_type = cp_line_item_type)
                  AND cd.document_key = ct.document_key
                  AND nvl(cp_contract_doc, cd.contract_doc_id) = cd.contract_doc_id
                  AND clid.transaction_key = ct.transaction_key
                  AND ct.supply_from_date = cp_period_from
                  AND ct.supply_to_date = cp_period_to
                  AND ct.product_id = cp_product_id
                  AND nvl(cd.customer_id, 'xx') = nvl(cp_customer_id, 'xx')
                  AND ct.price_concept_code = cp_price_concept_code
                  AND ct.delivery_point_id = cp_delivery_point_id
                  AND clid.dist_id = cp_field_id
                  AND nvl(ctq.uom1_code, 'xx') = nvl(cp_uom1_code, 'xx')
                  AND nvl(ctq.uom2_code, 'xx') = nvl(cp_uom2_code, 'xx')
                  AND nvl(ctq.uom3_code, 'xx') = nvl(cp_uom3_code, 'xx')
                  AND nvl(ctq.uom4_code, 'xx') = nvl(cp_uom4_code, 'xx')
                  AND
                  (NOT EXISTS
                   (SELECT ct2.transaction_key
                    FROM cont_transaction ct2
                    WHERE (ct2.preceding_trans_key = ct.transaction_key OR
                          ct2.reversed_trans_key = ct.transaction_key)) OR
                   ecdp_transaction.hasreverseddependenttrans(ct.transaction_key) = 'Y')
                  AND nvl(ct.reversal_ind, 'N') = 'N' -- Reversal transactions can not be used as preceding
                  AND cd.status_code = nvl(cp_doc_status_code, cd.status_code)
                  AND nvl(ct.ifac_unique_key_1, 'X') = nvl(cp_unique_key_1, 'X')
                  AND nvl(ct.ifac_unique_key_2, 'X') = nvl(cp_unique_key_2, 'X')
                  AND nvl(ct.ifac_tt_conn_code, '$NULL$') = nvl(cp_ifac_tt_conn_code, '$NULL$')
                  AND nvl(cli.ifac_li_conn_code, '$NULL$') = nvl(cp_ifac_li_conn_code, '$NULL$')
                  AND cli.interest_line_item_key IS NULL -- only get the main interest line item
                  AND nvl(cli.li_unique_key_1, '$NULL$') = nvl(cp_li_unique_key_1, '$NULL$')
                  AND nvl(cli.li_unique_key_2, '$NULL$') = nvl(cp_li_unique_key_2, '$NULL$')
            ORDER BY ct.created_date DESC;

        lv2_line_item_key   VARCHAR2(32);
    BEGIN
        IF prec.LINE_ITEM_BASED_TYPE = ecdp_revn_ft_constants.li_btype_quantity THEN
            RETURN NULL;
        END IF;

        IF prec.INTERFACE_LEVEL != ecdp_revn_ifac_wrapper.gconst_level_profit_center THEN
            RETURN NULL;
        END IF;

        FOR rsd IN c_ptd(
                prec.contract_id
               ,p_document_setup_id_overwrite
               ,prec.period_start_date
               ,prec.period_end_date
               ,prec.product_id
               ,prec.customer_id
               ,prec.price_concept_code
               ,prec.delivery_point_id
               ,prec.profit_center_id
               ,p_document_status_overwrite
               ,prec.unique_key_1
               ,prec.unique_key_2
               ,prec.li_unique_key_1
               ,prec.li_unique_key_2
               ,prec.uom1_code
               ,prec.uom2_code
               ,prec.uom3_code
               ,prec.uom4_code
               ,prec.ifac_tt_conn_code
               ,prec.ifac_li_conn_code
               ,prec.line_item_type
               ,prec.line_item_based_type
               ) LOOP
            lv2_line_item_key := rsd.line_item_key;
            EXIT;
        END LOOP;

        RETURN lv2_line_item_key;
    END;


 -----------------------------------------------------------------------
    -- Gets the preceding line item key of given interface.
    -- This function works for non-quantity line item ifac only.
    ----+----------------------------------+-------------------------------
    FUNCTION find_preceding_li_nq_pc_p(
        prec                               IN OUT NOCOPY t_ifac_cargo_value
       ,p_document_setup_id_overwrite      contract_doc.object_id%TYPE
       ,p_document_status_overwrite        cont_document.status_code%TYPE
    )
    RETURN VARCHAR2 IS
        CURSOR c_ptd
        (
            cp_contract_id          VARCHAR2
           ,cp_contract_doc         VARCHAR2
           ,cp_product_id           VARCHAR2
           ,cp_customer_id          VARCHAR2
           ,cp_price_concept_code   VARCHAR2
           ,cp_cargo_name           VARCHAR2
           ,cp_parcel_name          VARCHAR2
           ,cp_qty_type             VARCHAR2
           ,cp_field_id             VARCHAR2
           ,cp_doc_status_code      VARCHAR2
           ,cp_li_unique_key_1      VARCHAR2
           ,cp_li_unique_key_2      VARCHAR2
           ,cp_uom1_code            VARCHAR2
           ,cp_uom2_code            VARCHAR2
           ,cp_uom3_code            VARCHAR2
           ,cp_uom4_code            VARCHAR2
           ,cp_ifac_tt_conn_code    VARCHAR2
           ,cp_ifac_li_conn_code    VARCHAR2
           ,cp_line_item_type       VARCHAR2
           ,cp_line_item_based_type VARCHAR2
        ) IS
            SELECT cli.line_item_key
            FROM cont_transaction ct
                ,cont_transaction_qty ctq
                ,cont_line_item_dist clid
                ,cont_document cd
                ,cont_line_item cli
            WHERE ct.object_id = cp_contract_id
                  AND ct.transaction_key = ctq.transaction_key
                  AND cli.line_item_key = clid.line_item_key
                  AND cli.line_item_based_type = cp_line_item_based_type
                  AND ((cp_line_item_type is NULL AND cli.line_item_type IS NULL) OR cli.line_item_type = cp_line_item_type)
                  AND cd.document_key = ct.document_key
                  AND nvl(cp_contract_doc, cd.contract_doc_id) = cd.contract_doc_id
                  AND clid.transaction_key = ct.transaction_key
                  AND ct.product_id = cp_product_id
                  AND nvl(cd.customer_id, 'xx') = nvl(cp_customer_id, 'xx')
                  AND ct.price_concept_code = cp_price_concept_code
                  AND ct.cargo_name = cp_cargo_name
                  AND ct.parcel_name = cp_parcel_name
                  AND ct.qty_type = cp_qty_type
                  AND clid.dist_id = cp_field_id
                  AND nvl(ctq.uom1_code, 'xx') = nvl(cp_uom1_code, 'xx')
                  AND nvl(ctq.uom2_code, 'xx') = nvl(cp_uom2_code, 'xx')
                  AND nvl(ctq.uom3_code, 'xx') = nvl(cp_uom3_code, 'xx')
                  AND nvl(ctq.uom4_code, 'xx') = nvl(cp_uom4_code, 'xx')
                  AND
                  (NOT EXISTS
                   (SELECT ct2.transaction_key
                    FROM cont_transaction ct2
                    WHERE (ct2.preceding_trans_key = ct.transaction_key OR
                          ct2.reversed_trans_key = ct.transaction_key)) OR
                   ecdp_transaction.hasreverseddependenttrans(ct.transaction_key) = 'Y')
                  AND nvl(ct.reversal_ind, 'N') = 'N' -- Reversal transactions can not be used as preceding
                  AND cd.status_code = nvl(cp_doc_status_code, cd.status_code)
                  AND nvl(ct.ifac_tt_conn_code, '$NULL$') = nvl(cp_ifac_tt_conn_code, '$NULL$')
                  AND nvl(cli.ifac_li_conn_code, '$NULL$') = nvl(cp_ifac_li_conn_code, '$NULL$')
                  AND cli.interest_line_item_key IS NULL -- only get the main interest line item
                  AND nvl(cli.li_unique_key_1, '$NULL$') = nvl(cp_li_unique_key_1, '$NULL$')
                  AND nvl(cli.li_unique_key_2, '$NULL$') = nvl(cp_li_unique_key_2, '$NULL$')
            ORDER BY ct.created_date DESC;

        lv2_line_item_key   VARCHAR2(32);
    BEGIN
        IF prec.LINE_ITEM_BASED_TYPE = ecdp_revn_ft_constants.li_btype_quantity THEN
            RETURN NULL;
        END IF;

        IF prec.INTERFACE_LEVEL != ecdp_revn_ifac_wrapper.gconst_level_profit_center THEN
            RETURN NULL;
        END IF;

        FOR rsd IN c_ptd(
                prec.contract_id
               ,p_document_setup_id_overwrite
               ,prec.product_id
               ,prec.customer_id
               ,prec.price_concept_code
               ,prec.cargo_no
               ,prec.parcel_no
               ,prec.qty_type
               ,prec.profit_center_id
               ,p_document_status_overwrite
               ,prec.li_unique_key_1
               ,prec.li_unique_key_2
               ,prec.uom1_code
               ,prec.uom2_code
               ,prec.uom3_code
               ,prec.uom4_code
               ,prec.ifac_tt_conn_code
               ,prec.ifac_li_conn_code
               ,prec.line_item_type
               ,prec.line_item_based_type
               ) LOOP
            lv2_line_item_key := rsd.line_item_key;
            EXIT;
        END LOOP;

        RETURN lv2_line_item_key;
    END;


    -----------------------------------------------------------------------
    -- Gets the preceding line item key of given interface.
    -- This function works for non-quantity line item ifac only.
    ----+----------------------------------+-------------------------------
    FUNCTION find_preceding_li_nq_li_p(
        prec                               IN OUT NOCOPY t_ifac_sales_qty
       ,p_document_setup_id_overwrite      contract_doc.object_id%TYPE
       ,p_document_status_overwrite        cont_document.status_code%TYPE
    )
    RETURN VARCHAR2 IS

        CURSOR c_pt
        (
            cp_contract_id          VARCHAR2
           ,cp_contract_doc         VARCHAR2
           ,cp_period_from          DATE
           ,cp_period_to            DATE
           ,cp_product_id           VARCHAR2
           ,cp_customer_id          VARCHAR2
           ,cp_price_concept_code   VARCHAR2
           ,cp_delivery_point_id    VARCHAR2
           ,cp_field_id             VARCHAR2
           ,cp_doc_status_code      VARCHAR2
           ,cp_unique_key_1         VARCHAR2
           ,cp_unique_key_2         VARCHAR2
           ,cp_li_unique_key_1      VARCHAR2
           ,cp_li_unique_key_2      VARCHAR2
           ,cp_uom1_code            VARCHAR2
           ,cp_uom2_code            VARCHAR2
           ,cp_uom3_code            VARCHAR2
           ,cp_uom4_code            VARCHAR2
           ,cp_ifac_tt_conn_code    VARCHAR2
           ,cp_ifac_li_conn_code    VARCHAR2
           ,cp_line_item_type       VARCHAR2
           ,cp_line_item_based_type VARCHAR2
        ) IS
            SELECT cli.line_item_key
            FROM cont_transaction ct
                ,cont_document cd
                ,cont_transaction_qty ctq
                ,cont_line_item cli
            WHERE ct.transaction_key = ctq.transaction_key
                  AND ct.object_id = cp_contract_id
                  AND cli.transaction_key = ct.transaction_key
                  AND cli.line_item_based_type = cp_line_item_based_type
                  AND ((cp_line_item_type is NULL AND cli.line_item_type IS NULL) OR cli.line_item_type = cp_line_item_type)
                  AND nvl(ctq.uom1_code, 'xx') = nvl(cp_uom1_code, 'xx')
                  AND nvl(ctq.uom2_code, 'xx') = nvl(cp_uom2_code, 'xx')
                  AND nvl(ctq.uom3_code, 'xx') = nvl(cp_uom3_code, 'xx')
                  AND nvl(ctq.uom4_code, 'xx') = nvl(cp_uom4_code, 'xx')
                  AND cd.actual_reversal_date IS NULL
                  AND cd.document_key = ct.document_key
                  AND nvl(cp_contract_doc, cd.contract_doc_id) = cd.contract_doc_id
                  AND ct.supply_from_date = cp_period_from
                  AND ct.supply_to_date = cp_period_to
                  AND ct.product_id = cp_product_id
                  AND nvl(cd.customer_id, 'xx') = nvl(cp_customer_id, 'xx')
                  AND ct.price_concept_code = cp_price_concept_code
                  AND ct.delivery_point_id = cp_delivery_point_id
                  AND cp_field_id IN
                  (decode(ct.dist_type
                             ,'OBJECT_LIST'
                             ,ec_object_list.object_id_by_uk(ct.dist_code)
                             ,ecdp_objects.getobjidfromcode(ct.dist_object_type
                                                           ,ct.dist_code))
                      ,ec_stream_item_version.field_id(ct.stream_item_id
                                                      ,ct.daytime
                                                      ,'<='))
                  AND
                  (NOT EXISTS
                   (SELECT ct2.transaction_key
                    FROM cont_transaction ct2
                    WHERE (ct2.preceding_trans_key = ct.transaction_key OR
                          ct2.reversed_trans_key = ct.transaction_key)) OR
                          ecdp_transaction.hasreverseddependenttrans(ct.transaction_key) = 'Y' OR
                          ecdp_transaction.GetLatestnGreatestTran(ct.transaction_key)=ct.transaction_key)
                  AND nvl(ct.reversal_ind, 'N') = 'N' -- Reversal transactions can not be used as preceding
                  AND cd.status_code = nvl(cp_doc_status_code, cd.status_code)
                  AND nvl(ct.ifac_unique_key_1, 'X') = nvl(cp_unique_key_1, 'X')
                  AND nvl(ct.ifac_unique_key_2, 'X') = nvl(cp_unique_key_2, 'X')
                  AND nvl(ct.ifac_tt_conn_code, '$NULL$') = nvl(cp_ifac_tt_conn_code, '$NULL$')
                  AND nvl(cli.ifac_li_conn_code, '$NULL$') = nvl(cp_ifac_li_conn_code, '$NULL$')
                  AND cli.interest_line_item_key IS NULL -- only get the main interest line item
                  AND nvl(cli.li_unique_key_1, '$NULL$') = nvl(cp_li_unique_key_1, '$NULL$')
                  AND nvl(cli.li_unique_key_2, '$NULL$') = nvl(cp_li_unique_key_2, '$NULL$')
            ORDER BY ct.created_date DESC;

        lv2_line_item_key   VARCHAR2(32);
    BEGIN
        IF prec.LINE_ITEM_BASED_TYPE = ecdp_revn_ft_constants.li_btype_quantity THEN
            RETURN NULL;
        END IF;

        IF prec.INTERFACE_LEVEL != ecdp_revn_ifac_wrapper.gconst_level_line_item THEN
            RETURN NULL;
        END IF;

        FOR rst IN c_pt(prec.contract_id
                       ,p_document_setup_id_overwrite
                       ,prec.period_start_date
                       ,prec.period_end_date
                       ,prec.product_id
                       ,prec.customer_id
                       ,prec.price_concept_code
                       ,prec.delivery_point_id
                       ,prec.profit_center_id
                       ,p_document_status_overwrite
                       ,prec.unique_key_1
                       ,prec.unique_key_2
                       ,prec.li_unique_key_1
                       ,prec.li_unique_key_2
                       ,prec.uom1_code
                       ,prec.uom2_code
                       ,prec.uom3_code
                       ,prec.uom4_code
                       ,prec.ifac_tt_conn_code
                       ,prec.ifac_li_conn_code
                       ,prec.line_item_type
                       ,prec.line_item_based_type
                       ) LOOP
            lv2_line_item_key := rst.line_item_key;
            EXIT;
        END LOOP;

        RETURN lv2_line_item_key;
    END;

  -----------------------------------------------------------------------
    -- Gets the preceding line item key of given interface.
    -- This function works for non-quantity line item ifac only.
    ----+----------------------------------+-------------------------------
    FUNCTION find_preceding_li_nq_li_p(
        prec                               IN OUT NOCOPY t_ifac_cargo_value
       ,p_document_setup_id_overwrite      contract_doc.object_id%TYPE
       ,p_document_status_overwrite        cont_document.status_code%TYPE
    )
    RETURN VARCHAR2 IS

        CURSOR c_pt
        (
            cp_contract_id          VARCHAR2
           ,cp_contract_doc         VARCHAR2
           ,cp_product_id           VARCHAR2
           ,cp_customer_id          VARCHAR2
           ,cp_price_concept_code   VARCHAR2
           ,cp_cargo_name           VARCHAR2
           ,cp_parcel_name          VARCHAR2
           ,cp_qty_type             VARCHAR2
           ,cp_field_id             VARCHAR2
           ,cp_doc_status_code      VARCHAR2
           ,cp_li_unique_key_1      VARCHAR2
           ,cp_li_unique_key_2      VARCHAR2
           ,cp_uom1_code            VARCHAR2
           ,cp_uom2_code            VARCHAR2
           ,cp_uom3_code            VARCHAR2
           ,cp_uom4_code            VARCHAR2
           ,cp_ifac_tt_conn_code    VARCHAR2
           ,cp_ifac_li_conn_code    VARCHAR2
           ,cp_line_item_type       VARCHAR2
           ,cp_line_item_based_type VARCHAR2
        ) IS
            SELECT cli.line_item_key
            FROM cont_transaction ct
                ,cont_document cd
                ,cont_transaction_qty ctq
                ,cont_line_item cli
            WHERE ct.transaction_key = ctq.transaction_key
                  AND ct.object_id = cp_contract_id
                  AND cli.transaction_key = ct.transaction_key
                  AND cli.line_item_based_type = cp_line_item_based_type
                  AND ((cp_line_item_type is NULL AND cli.line_item_type IS NULL) OR cli.line_item_type = cp_line_item_type)
                  AND nvl(ctq.uom1_code, 'xx') = nvl(cp_uom1_code, 'xx')
                  AND nvl(ctq.uom2_code, 'xx') = nvl(cp_uom2_code, 'xx')
                  AND nvl(ctq.uom3_code, 'xx') = nvl(cp_uom3_code, 'xx')
                  AND nvl(ctq.uom4_code, 'xx') = nvl(cp_uom4_code, 'xx')
                  AND cd.actual_reversal_date IS NULL
                  AND cd.document_key = ct.document_key
                  AND nvl(cp_contract_doc, cd.contract_doc_id) = cd.contract_doc_id
                  AND ct.product_id = cp_product_id
                  AND nvl(cd.customer_id, 'xx') = nvl(cp_customer_id, 'xx')
                  AND ct.price_concept_code = cp_price_concept_code
                  AND ct.cargo_name = cp_cargo_name
                  AND ct.parcel_name = cp_parcel_name
                  AND ct.qty_type = cp_qty_type
                  AND cp_field_id IN
                  (decode(ct.dist_type
                             ,'OBJECT_LIST'
                             ,ec_object_list.object_id_by_uk(ct.dist_code)
                             ,ecdp_objects.getobjidfromcode(ct.dist_object_type
                                                           ,ct.dist_code))
                      ,ec_stream_item_version.field_id(ct.stream_item_id
                                                      ,ct.daytime
                                                      ,'<='))
                  AND
                  (NOT EXISTS
                   (SELECT ct2.transaction_key
                    FROM cont_transaction ct2
                    WHERE (ct2.preceding_trans_key = ct.transaction_key OR
                          ct2.reversed_trans_key = ct.transaction_key)) OR
                          ecdp_transaction.hasreverseddependenttrans(ct.transaction_key) = 'Y' OR
                          ecdp_transaction.GetLatestnGreatestTran(ct.transaction_key)=ct.transaction_key)
                  AND nvl(ct.reversal_ind, 'N') = 'N' -- Reversal transactions can not be used as preceding
                  AND cd.status_code = nvl(cp_doc_status_code, cd.status_code)
                  AND nvl(ct.ifac_tt_conn_code, '$NULL$') = nvl(cp_ifac_tt_conn_code, '$NULL$')
                  AND nvl(cli.ifac_li_conn_code, '$NULL$') = nvl(cp_ifac_li_conn_code, '$NULL$')
                  AND cli.interest_line_item_key IS NULL -- only get the main interest line item
                  AND nvl(cli.li_unique_key_1, '$NULL$') = nvl(cp_li_unique_key_1, '$NULL$')
                  AND nvl(cli.li_unique_key_2, '$NULL$') = nvl(cp_li_unique_key_2, '$NULL$')
            ORDER BY ct.created_date DESC;

        lv2_line_item_key   VARCHAR2(32);
    BEGIN
        IF prec.LINE_ITEM_BASED_TYPE = ecdp_revn_ft_constants.li_btype_quantity THEN
            RETURN NULL;
        END IF;

        IF prec.INTERFACE_LEVEL != ecdp_revn_ifac_wrapper.gconst_level_line_item THEN
            RETURN NULL;
        END IF;

        FOR rst IN c_pt(prec.contract_id
                       ,p_document_setup_id_overwrite
                       ,prec.product_id
                       ,prec.customer_id
                       ,prec.price_concept_code
                       ,prec.cargo_no
                       ,prec.parcel_no
                       ,prec.qty_type
                       ,prec.profit_center_id
                       ,p_document_status_overwrite
                       ,prec.li_unique_key_1
                       ,prec.li_unique_key_2
                       ,prec.uom1_code
                       ,prec.uom2_code
                       ,prec.uom3_code
                       ,prec.uom4_code
                       ,prec.ifac_tt_conn_code
                       ,prec.ifac_li_conn_code
                       ,prec.line_item_type
                       ,prec.line_item_based_type
                       ) LOOP
            lv2_line_item_key := rst.line_item_key;
            EXIT;
        END LOOP;

        RETURN lv2_line_item_key;
    END;

    -----------------------------------------------------------------------
    -- Gets the preceding line item key of given interface.
    -- This function works for non-quantity line item ifac only.
    ----+----------------------------------+-------------------------------
    FUNCTION find_preceding_li_nq_p(
        prec                               IN OUT NOCOPY t_ifac_sales_qty
    )
    RETURN VARCHAR2 IS
        lv2_level           VARCHAR2(32);
        lv2_trans_key       VARCHAR2(32);
        lv2_contract_doc    VARCHAR2(32);
        lv2_doc_status_code VARCHAR2(10);
        lv2_line_item_key   VARCHAR2(32);
    BEGIN
        IF prec.LINE_ITEM_BASED_TYPE = ecdp_revn_ft_constants.li_btype_quantity THEN
            RETURN NULL;
        END IF;

        IF ec_contract_doc_version.doc_concept_code(
                ec_transaction_template.contract_doc_id(prec.trans_temp_id),prec.processing_period,'<=') = 'MULTI_PERIOD' THEN
            lv2_contract_doc := ec_transaction_template.contract_doc_id(prec.trans_temp_id);
        ELSIF NOT ecdp_contract_setup.contracthasdocsetupconcept(prec.contract_id,prec.processing_period,'MULTI_PERIOD') THEN
            -- None MPD's can distinguish between a final and an accrual interface value
            lv2_doc_status_code := prec.doc_status;
        END IF;

        lv2_line_item_key := nvl(lv2_line_item_key,
            find_preceding_li_nq_li_p(prec, lv2_contract_doc, lv2_doc_status_code));
        lv2_line_item_key := nvl(lv2_line_item_key,
            find_preceding_li_nq_pc_p(prec, lv2_contract_doc, lv2_doc_status_code));
        lv2_line_item_key := nvl(lv2_line_item_key,
            find_preceding_li_nq_vend_p(prec, lv2_contract_doc, lv2_doc_status_code));

        RETURN lv2_line_item_key;
    END;
-----------------------------------------------------------------------
    -- Gets the preceding line item key of given interface.
    -- This function works for non-quantity line item ifac only.
    ----+----------------------------------+-------------------------------
    FUNCTION find_preceding_li_nq_p(
        prec                               IN OUT NOCOPY t_ifac_cargo_value
    )
    RETURN VARCHAR2 IS
        lv2_level           VARCHAR2(32);
        lv2_trans_key       VARCHAR2(32);
        lv2_contract_doc    VARCHAR2(32);
        lv2_doc_status_code VARCHAR2(10);
        lv2_line_item_key   VARCHAR2(32);
    BEGIN
        IF prec.LINE_ITEM_BASED_TYPE = ecdp_revn_ft_constants.li_btype_quantity THEN
            RETURN NULL;
        END IF;

        lv2_line_item_key := nvl(lv2_line_item_key,
            find_preceding_li_nq_li_p(prec, lv2_contract_doc, lv2_doc_status_code));
        lv2_line_item_key := nvl(lv2_line_item_key,
            find_preceding_li_nq_pc_p(prec, lv2_contract_doc, lv2_doc_status_code));
        lv2_line_item_key := nvl(lv2_line_item_key,
            find_preceding_li_nq_vend_p(prec, lv2_contract_doc, lv2_doc_status_code));

        RETURN lv2_line_item_key;
    END;


    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    FUNCTION find_preceding_li_i(
        p_ifac_rec                         IN OUT NOCOPY t_ifac_sales_qty
    )
    RETURN cont_line_item.line_item_key%TYPE
    IS
        l_line_item_key                    cont_line_item.line_item_key%TYPE;
    BEGIN
        p_ifac_rec.Line_Item_Based_Type :=
            NVL(p_ifac_rec.Line_Item_Based_Type, ecdp_revn_ft_constants.li_btype_quantity);
        l_line_item_key := find_preceding_li_qty_p(p_ifac_rec);
        IF l_line_item_key is null then
            l_line_item_key := find_preceding_li_nq_p(p_ifac_rec);
        END IF;

        RETURN l_line_item_key;
    END;


-----------------------------------------------------------------------------------------------------------------------------
 -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    FUNCTION find_preceding_li_i(
        p_ifac_rec                         IN OUT NOCOPY t_ifac_cargo_value
    )
    RETURN cont_line_item.line_item_key%TYPE
    IS
        l_line_item_key                    cont_line_item.line_item_key%TYPE;
    BEGIN
        p_ifac_rec.Line_Item_Based_Type :=
            NVL(p_ifac_rec.Line_Item_Based_Type, ecdp_revn_ft_constants.li_btype_quantity);
        l_line_item_key := find_preceding_li_qty_p(p_ifac_rec);
        IF l_line_item_key is null then
            l_line_item_key := find_preceding_li_nq_p(p_ifac_rec);
        END IF;

        RETURN l_line_item_key;
    END;


-----------------------------------------------------------------------------------------------------------------------------


FUNCTION GetIfacPrecedingTransKey(pRec IN OUT NOCOPY T_IFAC_SALES_QTY)
RETURN VARCHAR2
IS

 CURSOR c_pt (cp_contract_id        VARCHAR2,
              cp_contract_doc       VARCHAR2,
              cp_period_from        DATE,
              cp_period_to          DATE,
              cp_product_id         VARCHAR2,
              cp_customer_id        VARCHAR2,
              cp_price_concept_code VARCHAR2,
              cp_delivery_point_id  VARCHAR2,
              cp_field_id           VARCHAR2,
              cp_doc_status_code    VARCHAR2,
              cp_unique_key_1       VARCHAR2,
              cp_unique_key_2       VARCHAR2,
              cp_uom1_code          VARCHAR2,
              cp_uom2_code          VARCHAR2,
              cp_uom3_code          VARCHAR2,
              cp_uom4_code          VARCHAR2,
              cp_ifac_tt_conn_code  VARCHAR2,
              cp_allow_alt_cust_ind VARCHAR2) IS
  SELECT ct.transaction_key
    FROM cont_transaction ct,
         cont_document cd,
         cont_transaction_qty ctq
   WHERE ct.transaction_key = ctq.transaction_key
     AND ct.object_id = cp_contract_id
     AND nvl(ctq.uom1_code,'xx') = nvl(cp_uom1_code,'xx')
     AND nvl(ctq.uom2_code,'xx') = nvl(cp_uom2_code,'xx')
     AND nvl(ctq.uom3_code,'xx') = nvl(cp_uom3_code,'xx')
     AND nvl(ctq.uom4_code,'xx') = nvl(cp_uom4_code,'xx')
     AND cd.document_key = ct.document_key
     AND cd.actual_reversal_date IS NULL
     AND nvl(cp_contract_doc,cd.contract_doc_id) = cd.contract_doc_id
     AND ct.supply_from_date = cp_period_from
     AND ct.supply_to_date = cp_period_to
     AND ct.product_id = cp_product_id
     AND nvl(cd.customer_id,'xx') = decode(cp_allow_alt_cust_ind,'N',nvl(cd.customer_id,'xx'),cp_customer_id)
     AND ct.price_concept_code = cp_price_concept_code
     AND ct.delivery_point_id = cp_delivery_point_id
     AND cp_field_id IN
         (decode(ct.dist_type,'OBJECT_LIST',
                 ec_object_list.object_id_by_uk(ct.dist_code),
                 ecdp_objects.GetObjIDFromCode(ct.dist_object_type,ct.dist_code)),
          ec_stream_item_version.field_id(ct.stream_item_id, ct.daytime, '<='),
          Ec_Field.object_id_by_uk('SUM','FIELD'))
     AND (NOT EXISTS
          (SELECT ct2.transaction_key
             FROM cont_transaction ct2
            WHERE (ct2.preceding_trans_key = ct.transaction_key OR ct2.reversed_trans_key = ct.transaction_key))
            OR Ecdp_Transaction.HasReversedDependentTrans(ct.transaction_key) = 'Y'
            OR ecdp_transaction.GetLatestnGreatestTran(ct.transaction_key)=ct.transaction_key)
     AND nvl(ct.reversal_ind, 'N') = 'N' -- Reversal transactions can not be used as preceding
     AND cd.status_code = NVL(cp_doc_status_code, cd.status_code)
     AND NVL(ct.ifac_unique_key_1,'X') = NVL(cp_unique_key_1,'X')
     AND NVL(ct.ifac_unique_key_2,'X') = NVL(cp_unique_key_2,'X')
     AND nvl(ct.ifac_tt_conn_code, '$NULL$') = nvl(cp_ifac_tt_conn_code, '$NULL$')
     ORDER BY ct.created_date DESC;

 CURSOR c_ptd (cp_contract_id        VARCHAR2,
               cp_contract_doc       VARCHAR2,
               cp_period_from        DATE,
               cp_period_to          DATE,
               cp_product_id         VARCHAR2,
               cp_customer_id        VARCHAR2,
               cp_price_concept_code VARCHAR2,
               cp_delivery_point_id  VARCHAR2,
               cp_field_id           VARCHAR2,
               cp_doc_status_code    VARCHAR2,
               cp_unique_key_1       VARCHAR2,
               cp_unique_key_2       VARCHAR2,
               cp_uom1_code          VARCHAR2,
               cp_uom2_code          VARCHAR2,
               cp_uom3_code          VARCHAR2,
               cp_uom4_code          VARCHAR2,
               cp_ifac_tt_conn_code  VARCHAR2) IS
  SELECT ct.transaction_key
    FROM cont_transaction ct,
         cont_line_item_dist clid,
         cont_document cd,
         cont_transaction_qty ctq
   WHERE ct.object_id = cp_contract_id
     AND cd.document_key = ct.document_key
     AND cd.actual_reversal_date IS NULL
     AND nvl(cp_contract_doc,cd.contract_doc_id) = cd.contract_doc_id
     AND clid.transaction_key = ct.transaction_key
     AND ctq.transaction_key = ct.transaction_key
     AND ct.supply_from_date = cp_period_from
     AND ct.supply_to_date = cp_period_to
     AND ct.product_id = cp_product_id
     AND nvl(cd.customer_id,'xx') = nvl(cp_customer_id,'xx')
     AND ct.price_concept_code = cp_price_concept_code
     AND ct.delivery_point_id = cp_delivery_point_id
     AND clid.dist_id = cp_field_id
     AND ((--Alt 1: This is a QTY item and the UOM's are looked up on the Profit Center Level.
               clid.line_item_based_type = 'QTY'
           AND clid.uom1_code = cp_uom1_code
           AND nvl(clid.uom2_code,'xx') = nvl(cp_uom2_code,'xx')
           AND nvl(clid.uom3_code,'xx') = nvl(cp_uom3_code,'xx')
           AND nvl(clid.uom4_code,'xx') = nvl(cp_uom4_code,'xx')
          )
          OR
          (--Alt 2: This is an OLI item and the UOM's are looked up on the Transaction Level.
               clid.line_item_based_type != 'QTY'
           AND nvl(ctq.uom1_code,'xx') = nvl(cp_uom1_code,'xx')
           AND nvl(ctq.uom2_code,'xx') = nvl(cp_uom2_code,'xx')
           AND nvl(ctq.uom3_code,'xx') = nvl(cp_uom3_code,'xx')
           AND nvl(ctq.uom4_code,'xx') = nvl(cp_uom4_code,'xx')
          )
         )
     AND (NOT EXISTS
          (SELECT ct2.transaction_key
             FROM cont_transaction ct2
            WHERE (ct2.preceding_trans_key = ct.transaction_key OR ct2.reversed_trans_key = ct.transaction_key))
            OR Ecdp_Transaction.HasReversedDependentTrans(ct.transaction_key) = 'Y'
           OR ecdp_transaction.GetLatestnGreatestTran(ct.transaction_key)=ct.transaction_key )
     AND nvl(ct.reversal_ind, 'N') = 'N' -- Reversal transactions can not be used as preceding
     AND cd.status_code = NVL(cp_doc_status_code, cd.status_code)
     AND NVL(ct.ifac_unique_key_1,'X') = NVL(cp_unique_key_1,'X')
     AND NVL(ct.ifac_unique_key_2,'X') = NVL(cp_unique_key_2,'X')
     AND nvl(ct.ifac_tt_conn_code, '$NULL$') = nvl(cp_ifac_tt_conn_code, '$NULL$')
     ORDER BY ct.created_date DESC;

 CURSOR c_ptc (cp_contract_id        VARCHAR2,
               cp_contract_doc       VARCHAR2,
               cp_period_from        DATE,
               cp_period_to          DATE,
               cp_product_id         VARCHAR2,
               cp_customer_id        VARCHAR2,
               cp_price_concept_code VARCHAR2,
               cp_delivery_point_id  VARCHAR2,
               cp_field_id           VARCHAR2,
               cp_vendor_id          VARCHAR2,
               cp_doc_status_code    VARCHAR2,
               cp_unique_key_1       VARCHAR2,
               cp_unique_key_2       VARCHAR2,
               cp_uom1_code          VARCHAR2,
               cp_uom2_code          VARCHAR2,
               cp_uom3_code          VARCHAR2,
               cp_uom4_code          VARCHAR2,
               cp_ifac_tt_conn_code  VARCHAR2) IS
  SELECT ct.transaction_key
    FROM cont_transaction ct,
         cont_li_dist_company clidc,
         cont_document cd,
         cont_transaction_qty ctq
   WHERE ct.object_id = cp_contract_id
     AND cd.document_key = ct.document_key
     AND cd.actual_reversal_date IS NULL
     AND nvl(cp_contract_doc,cd.contract_doc_id) = cd.contract_doc_id
     AND clidc.transaction_key = ct.transaction_key
     AND ctq.transaction_key = ct.transaction_key
     AND ct.supply_from_date = cp_period_from
     AND ct.supply_to_date = cp_period_to
     AND ct.product_id = cp_product_id
     AND nvl(cd.customer_id,'xx') = nvl(cp_customer_id,'xx')
     AND ct.price_concept_code = cp_price_concept_code
     AND ct.delivery_point_id = cp_delivery_point_id
     AND clidc.dist_id = cp_field_id
     AND clidc.vendor_id = cp_vendor_id
     AND ((--Alt 1: This is a QTY item and the UOM's are looked up on the Vendor Level.
               clidc.line_item_based_type = 'QTY'
           AND clidc.uom1_code = cp_uom1_code
           AND nvl(clidc.uom2_code,'xx') = nvl(cp_uom2_code,'xx')
           AND nvl(clidc.uom3_code,'xx') = nvl(cp_uom3_code,'xx')
           AND nvl(clidc.uom4_code,'xx') = nvl(cp_uom4_code,'xx')
          )
          OR
          (--Alt 2: This is an OLI item and the UOM's are looked up on the Transaction Level.
               clidc.line_item_based_type != 'QTY'
           AND nvl(ctq.uom1_code,'xx') = nvl(cp_uom1_code,'xx')
           AND nvl(ctq.uom2_code,'xx') = nvl(cp_uom2_code,'xx')
           AND nvl(ctq.uom3_code,'xx') = nvl(cp_uom3_code,'xx')
           AND nvl(ctq.uom4_code,'xx') = nvl(cp_uom4_code,'xx')
          )
         )
     AND (NOT EXISTS
          (SELECT ct2.transaction_key
             FROM cont_transaction ct2
            WHERE (ct2.preceding_trans_key = ct.transaction_key OR ct2.reversed_trans_key = ct.transaction_key))
            OR Ecdp_Transaction.HasReversedDependentTrans(ct.transaction_key) = 'Y'
            OR ecdp_transaction.GetLatestnGreatestTran(ct.transaction_key)=ct.transaction_key)
     AND nvl(ct.reversal_ind, 'N') = 'N' -- Reversal transactions can not be used as preceding
     AND cd.status_code = NVL(cp_doc_status_code, cd.status_code)
     AND NVL(ct.ifac_unique_key_1,'X') = NVL(cp_unique_key_1,'X')
     AND NVL(ct.ifac_unique_key_2,'X') = NVL(cp_unique_key_2,'X')
     AND nvl(ct.ifac_tt_conn_code, '$NULL$') = nvl(cp_ifac_tt_conn_code, '$NULL$')
     ORDER BY ct.created_date DESC;

  lv2_comp VARCHAR2(32);
  lv2_trans_key VARCHAR2(32);
  lv2_contract_doc VARCHAR2(32);
  lv2_doc_status_code VARCHAR2(10);
  lv2_line_item_key   VARCHAR2(32);
  lv2_allow_alt_cust_ind VARCHAR2(1);
BEGIN

    lv2_allow_alt_cust_ind := nvl(ec_contract_version.allow_alt_cust_ind(pRec.Contract_Id, pRec.Processing_Period, '<='), 'N');

    IF ec_contract_doc_version.doc_concept_code(ec_transaction_template.contract_doc_id(pRec.Trans_Temp_Id), pRec.Processing_Period,'<=') = 'MULTI_PERIOD' THEN
        lv2_contract_doc := ec_transaction_template.contract_doc_id(pRec.Trans_Temp_Id);
    ELSIF NOT ecdp_contract_setup.ContractHasDocSetupConcept(pRec.Contract_Id, pRec.processing_period, 'MULTI_PERIOD') THEN
        -- None MPD's can distinguish between a final and an accrual interface value
        lv2_doc_status_code := prec.doc_status;
    END IF;

    IF pRec.INTERFACE_LEVEL = ecdp_revn_ifac_wrapper.gconst_level_line_item THEN

         FOR rsT IN c_pt(
             pRec.Contract_Id
            ,lv2_contract_doc
            ,pRec.Period_Start_Date
            ,pRec.Period_End_Date
            ,pRec.Product_Id
            ,pRec.Customer_Id
            ,pRec.Price_Concept_Code
            ,pRec.Delivery_Point_Id
            ,pRec.Profit_Center_Id
            ,lv2_doc_status_code
            ,pRec.Unique_Key_1
            ,pRec.Unique_Key_2
            ,pRec.Uom1_Code
            ,pRec.Uom2_Code
            ,pRec.Uom3_Code
            ,pRec.Uom4_Code
            ,pRec.Ifac_Tt_Conn_Code
            ,lv2_allow_alt_cust_ind
            ) LOOP
             lv2_trans_key := rsT.transaction_key;
             EXIT;
        END LOOP;

    ELSIF pRec.INTERFACE_LEVEL = ecdp_revn_ifac_wrapper.gconst_level_profit_center THEN
        FOR rsD IN c_ptd(
             pRec.Contract_Id
            ,lv2_contract_doc
            ,pRec.Period_Start_Date
            ,pRec.Period_End_Date
            ,pRec.Product_Id
            ,pRec.Customer_Id
            ,pRec.Price_Concept_Code
            ,pRec.Delivery_Point_Id
            ,pRec.Profit_Center_Id
            ,lv2_doc_status_code
            ,pRec.Unique_Key_1
            ,pRec.Unique_Key_2
            ,pRec.Uom1_Code
            ,pRec.Uom2_Code
            ,pRec.Uom3_Code
            ,pRec.Uom4_Code
            ,pRec.Ifac_Tt_Conn_Code
             ) LOOP

            lv2_trans_key := rsD.transaction_key;
            EXIT;
        END LOOP;
    ELSIF pRec.INTERFACE_LEVEL = ecdp_revn_ifac_wrapper.gconst_level_vendor THEN
        FOR rsC IN c_ptc(
             pRec.Contract_Id
            ,lv2_contract_doc
            ,pRec.Period_Start_Date
            ,pRec.Period_End_Date
            ,pRec.Product_Id
            ,pRec.Customer_Id
            ,pRec.Price_Concept_Code
            ,pRec.Delivery_Point_Id
            ,pRec.Profit_Center_Id
            ,pRec.Vendor_Id
            ,lv2_doc_status_code
            ,pRec.Unique_Key_1
            ,pRec.Unique_Key_2
            ,pRec.Uom1_Code
            ,pRec.Uom2_Code
            ,pRec.Uom3_Code
            ,pRec.Uom4_Code
            ,pRec.Ifac_Tt_Conn_Code) LOOP

            lv2_trans_key := rsC.transaction_key;
            EXIT;
        END LOOP;
    END IF;
    ecdp_revn_debug.write('lv2_trans_key         ', lv2_trans_key);

  RETURN lv2_trans_key;

END GetIfacPrecedingTransKey;


-----------------------------------------------------------------------------------------------------------------------------

FUNCTION GetIfacPrecedingTransKey(pRec IN OUT NOCOPY T_IFAC_CARGO_VALUE)
RETURN VARCHAR2
IS

 CURSOR c_pt (cp_contract_id        VARCHAR2,
              cp_contract_doc       VARCHAR2,
              cp_product_id         VARCHAR2,
              cp_customer_id        VARCHAR2,
              cp_price_concept_code VARCHAR2,
              cp_field_id           VARCHAR2,
              cp_doc_status_code    VARCHAR2,
              cp_uom1_code          VARCHAR2,
              cp_uom2_code          VARCHAR2,
              cp_uom3_code          VARCHAR2,
              cp_uom4_code          VARCHAR2,
              cp_ifac_tt_conn_code  VARCHAR2,
              cp_cargo_no           VARCHAR2,
              cp_parcel_no          VARCHAR2) IS
  SELECT ct.transaction_key
    FROM cont_transaction ct,
         cont_document cd,
         cont_transaction_qty ctq
   WHERE ct.transaction_key = ctq.transaction_key
     AND ct.object_id = cp_contract_id
     AND nvl(ctq.uom1_code,'xx') = nvl(cp_uom1_code,'xx')
     AND nvl(ctq.uom2_code,'xx') = nvl(cp_uom2_code,'xx')
     AND nvl(ctq.uom3_code,'xx') = nvl(cp_uom3_code,'xx')
     AND nvl(ctq.uom4_code,'xx') = nvl(cp_uom4_code,'xx')
     AND cd.document_key = ct.document_key
     AND cd.actual_reversal_date IS NULL
     AND nvl(cp_contract_doc,cd.contract_doc_id) = cd.contract_doc_id
     AND ct.product_id = cp_product_id
     AND nvl(cd.customer_id,'xx') = nvl(cp_customer_id,'xx')
     AND ct.price_concept_code = cp_price_concept_code
     AND cp_field_id IN
         (decode(ct.dist_type,'OBJECT_LIST',
                 ec_object_list.object_id_by_uk(ct.dist_code),
                 ecdp_objects.GetObjIDFromCode(ct.dist_object_type,ct.dist_code))
               ,ec_stream_item_version.field_id(ct.stream_item_id, ct.daytime, '<='))
     AND (NOT EXISTS
          (SELECT ct2.transaction_key
             FROM cont_transaction ct2
            WHERE (ct2.preceding_trans_key = ct.transaction_key OR ct2.reversed_trans_key = ct.transaction_key))
            OR Ecdp_Transaction.HasReversedDependentTrans(ct.transaction_key) = 'Y'
            OR ecdp_transaction.GetLatestnGreatestTran(ct.transaction_key)=ct.transaction_key)
     AND nvl(ct.reversal_ind, 'N') = 'N' -- Reversal transactions can not be used as preceding
     AND cd.status_code = NVL(cp_doc_status_code, cd.status_code)
     AND nvl(ct.ifac_tt_conn_code, '$NULL$') = nvl(cp_ifac_tt_conn_code, '$NULL$')
     AND ct.cargo_name = cp_cargo_no
     AND ct.parcel_name = cp_parcel_no
     ORDER BY ct.created_date DESC;

 CURSOR c_ptd (cp_contract_id        VARCHAR2,
               cp_contract_doc       VARCHAR2,
               cp_product_id         VARCHAR2,
               cp_customer_id        VARCHAR2,
               cp_price_concept_code VARCHAR2,
               cp_field_id           VARCHAR2,
               cp_doc_status_code    VARCHAR2,
               cp_uom1_code          VARCHAR2,
               cp_uom2_code          VARCHAR2,
               cp_uom3_code          VARCHAR2,
               cp_uom4_code          VARCHAR2,
               cp_ifac_tt_conn_code  VARCHAR2,
               cp_cargo_no           VARCHAR2,
               cp_parcel_no          VARCHAR2) IS
  SELECT ct.transaction_key
    FROM cont_transaction ct,
         cont_line_item_dist clid,
         cont_document cd,
         cont_transaction_qty ctq
   WHERE ct.object_id = cp_contract_id
     AND cd.document_key = ct.document_key
     AND cd.actual_reversal_date IS NULL
     AND nvl(cp_contract_doc,cd.contract_doc_id) = cd.contract_doc_id
     AND clid.transaction_key = ct.transaction_key
     AND ctq.transaction_key = ct.transaction_key
     AND ct.product_id = cp_product_id
     AND nvl(cd.customer_id,'xx') = nvl(cp_customer_id,'xx')
     AND ct.price_concept_code = cp_price_concept_code
     AND clid.dist_id = cp_field_id
     AND ((--Alt 1: This is a QTY item and the UOM's are looked up on the Profit Center Level.
               clid.line_item_based_type = 'QTY'
           AND clid.uom1_code = cp_uom1_code
           AND nvl(clid.uom2_code,'xx') = nvl(cp_uom2_code,'xx')
           AND nvl(clid.uom3_code,'xx') = nvl(cp_uom3_code,'xx')
           AND nvl(clid.uom4_code,'xx') = nvl(cp_uom4_code,'xx')
          )
          OR
          (--Alt 2: This is an OLI item and the UOM's are looked up on the Transaction Level.
               clid.line_item_based_type != 'QTY'
           AND nvl(ctq.uom1_code,'xx') = nvl(cp_uom1_code,'xx')
           AND nvl(ctq.uom2_code,'xx') = nvl(cp_uom2_code,'xx')
           AND nvl(ctq.uom3_code,'xx') = nvl(cp_uom3_code,'xx')
           AND nvl(ctq.uom4_code,'xx') = nvl(cp_uom4_code,'xx')
          )
         )
     AND (NOT EXISTS
          (SELECT ct2.transaction_key
             FROM cont_transaction ct2
            WHERE (ct2.preceding_trans_key = ct.transaction_key OR ct2.reversed_trans_key = ct.transaction_key))
            OR Ecdp_Transaction.HasReversedDependentTrans(ct.transaction_key) = 'Y'
           OR ecdp_transaction.GetLatestnGreatestTran(ct.transaction_key)=ct.transaction_key )
     AND nvl(ct.reversal_ind, 'N') = 'N' -- Reversal transactions can not be used as preceding
     AND cd.status_code = NVL(cp_doc_status_code, cd.status_code)
     AND nvl(ct.ifac_tt_conn_code, '$NULL$') = nvl(cp_ifac_tt_conn_code, '$NULL$')
     AND ct.cargo_name = cp_cargo_no
     AND ct.parcel_name = cp_parcel_no
     ORDER BY ct.created_date DESC;

 CURSOR c_ptc (cp_contract_id        VARCHAR2,
               cp_contract_doc       VARCHAR2,
               cp_product_id         VARCHAR2,
               cp_customer_id        VARCHAR2,
               cp_price_concept_code VARCHAR2,
               cp_field_id           VARCHAR2,
               cp_vendor_id          VARCHAR2,
               cp_doc_status_code    VARCHAR2,
               cp_uom1_code          VARCHAR2,
               cp_uom2_code          VARCHAR2,
               cp_uom3_code          VARCHAR2,
               cp_uom4_code          VARCHAR2,
               cp_ifac_tt_conn_code  VARCHAR2,
               cp_cargo_no           VARCHAR2,
               cp_parcel_no          VARCHAR2) IS
  SELECT ct.transaction_key
    FROM cont_transaction ct,
         cont_li_dist_company clidc,
         cont_document cd,
         cont_transaction_qty ctq
   WHERE ct.object_id = cp_contract_id
     AND cd.document_key = ct.document_key
     AND cd.actual_reversal_date IS NULL
     AND nvl(cp_contract_doc,cd.contract_doc_id) = cd.contract_doc_id
     AND clidc.transaction_key = ct.transaction_key
     AND ctq.transaction_key = ct.transaction_key
     AND ct.product_id = cp_product_id
     AND nvl(cd.customer_id,'xx') = nvl(cp_customer_id,'xx')
     AND ct.price_concept_code = cp_price_concept_code
     AND clidc.dist_id = cp_field_id
     AND clidc.vendor_id = cp_vendor_id
     AND ((--Alt 1: This is a QTY item and the UOM's are looked up on the Vendor Level.
               clidc.line_item_based_type = 'QTY'
           AND clidc.uom1_code = cp_uom1_code
           AND nvl(clidc.uom2_code,'xx') = nvl(cp_uom2_code,'xx')
           AND nvl(clidc.uom3_code,'xx') = nvl(cp_uom3_code,'xx')
           AND nvl(clidc.uom4_code,'xx') = nvl(cp_uom4_code,'xx')
          )
          OR
          (--Alt 2: This is an OLI item and the UOM's are looked up on the Transaction Level.
               clidc.line_item_based_type != 'QTY'
           AND nvl(ctq.uom1_code,'xx') = nvl(cp_uom1_code,'xx')
           AND nvl(ctq.uom2_code,'xx') = nvl(cp_uom2_code,'xx')
           AND nvl(ctq.uom3_code,'xx') = nvl(cp_uom3_code,'xx')
           AND nvl(ctq.uom4_code,'xx') = nvl(cp_uom4_code,'xx')
          )
         )
     AND (NOT EXISTS
          (SELECT ct2.transaction_key
             FROM cont_transaction ct2
            WHERE (ct2.preceding_trans_key = ct.transaction_key OR ct2.reversed_trans_key = ct.transaction_key))
            OR Ecdp_Transaction.HasReversedDependentTrans(ct.transaction_key) = 'Y'
            OR ecdp_transaction.GetLatestnGreatestTran(ct.transaction_key)=ct.transaction_key)
     AND nvl(ct.reversal_ind, 'N') = 'N' -- Reversal transactions can not be used as preceding
     AND cd.status_code = NVL(cp_doc_status_code, cd.status_code)
     AND nvl(ct.ifac_tt_conn_code, '$NULL$') = nvl(cp_ifac_tt_conn_code, '$NULL$')
     AND ct.cargo_name = cp_cargo_no
     AND ct.parcel_name = cp_parcel_no
     ORDER BY ct.created_date DESC;

  lv2_comp VARCHAR2(32);
  lv2_trans_key VARCHAR2(32);
  lv2_contract_doc VARCHAR2(32);
  lv2_doc_status_code VARCHAR2(10);
  lv2_line_item_key   VARCHAR2(32);
BEGIN

    IF pRec.INTERFACE_LEVEL = ecdp_revn_ifac_wrapper.gconst_level_line_item THEN

         FOR rsT IN c_pt(
             pRec.Contract_Id
            ,lv2_contract_doc
            ,pRec.Product_Id
            ,pRec.Customer_Id
            ,pRec.Price_Concept_Code
            ,pRec.Profit_Center_Id
            ,lv2_doc_status_code
            ,pRec.Uom1_Code
            ,pRec.Uom2_Code
            ,pRec.Uom3_Code
            ,pRec.Uom4_Code
            ,pRec.Ifac_Tt_Conn_Code
            ,pRec.Cargo_No
            ,pRec.Parcel_No
            ) LOOP
             lv2_trans_key := rsT.transaction_key;
             EXIT;
        END LOOP;

    ELSIF pRec.INTERFACE_LEVEL = ecdp_revn_ifac_wrapper.gconst_level_profit_center THEN
         FOR rsD IN c_ptd(
             pRec.Contract_Id
            ,lv2_contract_doc
            ,pRec.Product_Id
            ,pRec.Customer_Id
            ,pRec.Price_Concept_Code
            ,pRec.Profit_Center_Id
            ,lv2_doc_status_code
            ,pRec.Uom1_Code
            ,pRec.Uom2_Code
            ,pRec.Uom3_Code
            ,pRec.Uom4_Code
            ,pRec.Ifac_Tt_Conn_Code
            ,pRec.Cargo_No
            ,pRec.Parcel_No
             ) LOOP

             lv2_trans_key := rsD.transaction_key;
             EXIT;
         END LOOP;
    ELSIF pRec.INTERFACE_LEVEL = ecdp_revn_ifac_wrapper.gconst_level_vendor THEN
         FOR rsC IN c_ptc(
             pRec.Contract_Id
            ,lv2_contract_doc
            ,pRec.Product_Id
            ,pRec.Customer_Id
            ,pRec.Price_Concept_Code
            ,pRec.Profit_Center_Id
            ,pRec.Vendor_Id
            ,lv2_doc_status_code
            ,pRec.Uom1_Code
            ,pRec.Uom2_Code
            ,pRec.Uom3_Code
            ,pRec.Uom4_Code
            ,pRec.Ifac_Tt_Conn_Code
            ,pRec.Cargo_No
            ,pRec.Parcel_No) LOOP

             lv2_trans_key := rsC.transaction_key;
             EXIT;
         END LOOP;
    END IF;
    ecdp_revn_debug.write('lv2_trans_key         ', lv2_trans_key);

  RETURN lv2_trans_key;

END GetIfacPrecedingTransKey;


-----------------------------------------------------------------------------------------------------------------------------

--<EC-DOC>
-------------------------------------------------------------------------------------------------------------------------------------------
-- Function      :  GetERPPrecedingDocKey
-- Description    : Gets the preceding document for contract/production period
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------

FUNCTION GetERPPrecedingDocKey(p_contract_id       VARCHAR2,
                               p_production_period DATE)
RETURN VARCHAR2
--</EC-DOC>
IS

  lv2_ret_prec_doc_key VARCHAR2(32) := NULL;

  -- Find processed record for same production period on the same contract, and use this as preceding.
  CURSOR c_Prec IS
   SELECT d.document_key prec_doc_key
     FROM cont_document d
    WHERE d.object_id = p_contract_id
      AND d.production_period = p_production_period
      AND nvl(d.document_level_code, 'N') = 'BOOKED'
      AND (NOT EXISTS
           (SELECT DISTINCT cd.document_key
              FROM cont_document cd
             WHERE cd.preceding_document_key = d.document_key) OR
           ecdp_document.hasreverseddependentdoc(d.document_key) = 'Y');

BEGIN

      -- Find out if there are processed documents on the same contract that have no documents depending on them.
      FOR rsPR IN c_Prec LOOP

         lv2_ret_prec_doc_key := rsPR.Prec_Doc_Key;

  END LOOP;

  RETURN lv2_ret_prec_doc_key;

END GetERPPrecedingDocKey;



--<EC-DOC>
-------------------------------------------------------------------------------------------------------------------------------------------
-- Procedure      :
-- Description    :
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetCargoDocDate
  (p_contract_id VARCHAR2,
   p_cargo_no VARCHAR2,
   p_qty_type VARCHAR2,
   p_alloc_no NUMBER,
   p_point_of_sale_date DATE,
   p_doc_setup_id VARCHAR2,
   p_customer_id VARCHAR2,
   p_doc_date DATE DEFAULT NULL,
   p_doc_key VARCHAR2 DEFAULT NULL
   )
RETURN DATE
--</EC-DOC>
IS
  ld_return_val DATE := NULL;
  lv2_term_id VARCHAR2(32) := NULL;
  lv2_method VARCHAR2(32) := NULL;

  CURSOR c_posd_min(cp_contract_id VARCHAR2, cp_cargo_no VARCHAR2, cp_qty_type VARCHAR2, cp_alloc_no NUMBER, cp_point_of_sale_date DATE, cp_customer_id VARCHAR2) IS
    SELECT MIN(cv.point_of_sale_date) POS_DATE
      FROM ifac_cargo_value cv
     WHERE cv.contract_id = cp_contract_id
       AND cv.cargo_no = cp_cargo_no
       AND cv.qty_type = cp_qty_type
       AND cv.alloc_no = cp_alloc_no
       AND cv.customer_id = cp_customer_id
       AND TRUNC(cv.point_of_sale_date,'MM') = TRUNC(cp_point_of_sale_date,'MM');

  CURSOR c_posd_max(cp_contract_id VARCHAR2, cp_cargo_no VARCHAR2, cp_qty_type VARCHAR2, cp_alloc_no NUMBER, cp_point_of_sale_date DATE, cp_customer_id VARCHAR2) IS
    SELECT MAX(cv.point_of_sale_date) POS_DATE
      FROM ifac_cargo_value cv
     WHERE cv.contract_id = cp_contract_id
       AND cv.cargo_no = cp_cargo_no
       AND cv.qty_type = cp_qty_type
       AND cv.alloc_no = cp_alloc_no
       AND cv.customer_id = cp_customer_id
       AND TRUNC(cv.point_of_sale_date,'MM') = TRUNC(cp_point_of_sale_date,'MM');

  CURSOR c_ldcommenced_min(cp_contract_id VARCHAR2, cp_cargo_no VARCHAR2, cp_qty_type VARCHAR2, cp_alloc_no NUMBER, cp_point_of_sale_date DATE, cp_customer_id VARCHAR2) IS
    SELECT MIN(cv.loading_comm_date) Loading_Date_Commenced
      FROM ifac_cargo_value cv
     WHERE cv.contract_id = cp_contract_id
       AND cv.cargo_no = cp_cargo_no
       AND cv.qty_type = cp_qty_type
       AND cv.alloc_no = cp_alloc_no
       AND cv.customer_id = cp_customer_id
       AND TRUNC(cv.point_of_sale_date,'MM') = TRUNC(cp_point_of_sale_date,'MM');

  CURSOR c_ldcommenced_max(cp_contract_id VARCHAR2, cp_cargo_no VARCHAR2, cp_qty_type VARCHAR2, cp_alloc_no NUMBER, cp_point_of_sale_date DATE, cp_customer_id VARCHAR2) IS
    SELECT MAX(cv.loading_comm_date) Loading_Date_Commenced
      FROM ifac_cargo_value cv
     WHERE cv.contract_id = cp_contract_id
       AND cv.cargo_no = cp_cargo_no
       AND cv.qty_type = cp_qty_type
       AND cv.alloc_no = cp_alloc_no
       AND cv.customer_id = cp_customer_id
       AND TRUNC(cv.point_of_sale_date,'MM') = TRUNC(cp_point_of_sale_date,'MM');

  CURSOR c_ldcompleted_min(cp_contract_id VARCHAR2, cp_cargo_no VARCHAR2, cp_qty_type VARCHAR2, cp_alloc_no NUMBER, cp_point_of_sale_date DATE, cp_customer_id VARCHAR2) IS
    SELECT MIN(cv.loading_date) Loading_Date_Completed
      FROM ifac_cargo_value cv
     WHERE cv.contract_id = cp_contract_id
       AND cv.cargo_no = cp_cargo_no
       AND cv.qty_type = cp_qty_type
       AND cv.alloc_no = cp_alloc_no
       AND cv.customer_id = cp_customer_id
       AND TRUNC(cv.point_of_sale_date,'MM') = TRUNC(cp_point_of_sale_date,'MM');

  CURSOR c_ldcompleted_max(cp_contract_id VARCHAR2, cp_cargo_no VARCHAR2, cp_qty_type VARCHAR2, cp_alloc_no NUMBER, cp_point_of_sale_date DATE, cp_customer_id VARCHAR2) IS
    SELECT MAX(cv.loading_date) Loading_Date_Completed
      FROM ifac_cargo_value cv
     WHERE cv.contract_id = cp_contract_id
       AND cv.cargo_no = cp_cargo_no
       AND cv.qty_type = cp_qty_type
       AND cv.alloc_no = cp_alloc_no
       AND cv.customer_id = cp_customer_id
       AND TRUNC(cv.point_of_sale_date,'MM') = TRUNC(cp_point_of_sale_date,'MM');

  CURSOR c_ddcommenced_min(cp_contract_id VARCHAR2, cp_cargo_no VARCHAR2, cp_qty_type VARCHAR2, cp_alloc_no NUMBER, cp_point_of_sale_date DATE, cp_customer_id VARCHAR2) IS
    SELECT MIN(cv.delivery_comm_date) Delivery_Date_Commenced
      FROM ifac_cargo_value cv
     WHERE cv.contract_id = cp_contract_id
       AND cv.cargo_no = cp_cargo_no
       AND cv.qty_type = cp_qty_type
       AND cv.alloc_no = cp_alloc_no
       AND cv.customer_id = cp_customer_id
       AND TRUNC(cv.point_of_sale_date,'MM') = TRUNC(cp_point_of_sale_date,'MM');

  CURSOR c_ddcommenced_max(cp_contract_id VARCHAR2, cp_cargo_no VARCHAR2, cp_qty_type VARCHAR2, cp_alloc_no NUMBER, cp_point_of_sale_date DATE, cp_customer_id VARCHAR2) IS
    SELECT MAX(cv.delivery_comm_date) Delivery_Date_Commenced
      FROM ifac_cargo_value cv
     WHERE cv.contract_id = cp_contract_id
       AND cv.cargo_no = cp_cargo_no
       AND cv.qty_type = cp_qty_type
       AND cv.alloc_no = cp_alloc_no
       AND cv.customer_id = cp_customer_id
       AND TRUNC(cv.point_of_sale_date,'MM') = TRUNC(cp_point_of_sale_date,'MM');

  CURSOR c_ddcompleted_min(cp_contract_id VARCHAR2, cp_cargo_no VARCHAR2, cp_qty_type VARCHAR2, cp_alloc_no NUMBER, cp_point_of_sale_date DATE, cp_customer_id VARCHAR2) IS
    SELECT MIN(cv.delivery_date) Delivery_Date_Completed
      FROM ifac_cargo_value cv
     WHERE cv.contract_id = cp_contract_id
       AND cv.cargo_no = cp_cargo_no
       AND cv.qty_type = cp_qty_type
       AND cv.alloc_no = cp_alloc_no
       AND cv.customer_id = cp_customer_id
       AND TRUNC(cv.point_of_sale_date,'MM') = TRUNC(cp_point_of_sale_date,'MM');

  CURSOR c_ddcompleted_max(cp_contract_id VARCHAR2, cp_cargo_no VARCHAR2, cp_qty_type VARCHAR2, cp_alloc_no NUMBER, cp_point_of_sale_date DATE, cp_customer_id VARCHAR2) IS
    SELECT MAX(cv.delivery_date) Delivery_Date_Completed
      FROM ifac_cargo_value cv
     WHERE cv.contract_id = cp_contract_id
       AND cv.cargo_no = cp_cargo_no
       AND cv.qty_type = cp_qty_type
       AND cv.alloc_no = cp_alloc_no
       AND cv.customer_id = cp_customer_id
       AND TRUNC(cv.point_of_sale_date,'MM') = TRUNC(cp_point_of_sale_date,'MM');

  CURSOR c_bld_min(cp_contract_id VARCHAR2, cp_cargo_no VARCHAR2, cp_qty_type VARCHAR2, cp_alloc_no NUMBER, cp_point_of_sale_date DATE, cp_customer_id VARCHAR2) IS
    SELECT MIN(cv.bl_date) BL_DATE
      FROM ifac_cargo_value cv
     WHERE cv.contract_id = cp_contract_id
       AND cv.cargo_no = cp_cargo_no
       AND cv.qty_type = cp_qty_type
       AND cv.alloc_no = cp_alloc_no
       AND cv.customer_id = cp_customer_id
       AND TRUNC(cv.point_of_sale_date,'MM') = TRUNC(cp_point_of_sale_date,'MM');

  CURSOR c_bld_max(cp_contract_id VARCHAR2, cp_cargo_no VARCHAR2, cp_qty_type VARCHAR2, cp_alloc_no NUMBER, cp_point_of_sale_date DATE, cp_customer_id VARCHAR2) IS
    SELECT MAX(cv.bl_date) BL_DATE
      FROM ifac_cargo_value cv
     WHERE cv.contract_id = cp_contract_id
       AND cv.cargo_no = cp_cargo_no
       AND cv.qty_type = cp_qty_type
       AND cv.alloc_no = cp_alloc_no
       AND cv.customer_id = cp_customer_id
       AND TRUNC(cv.point_of_sale_date,'MM') = TRUNC(cp_point_of_sale_date,'MM');

BEGIN

  IF p_doc_date IS NOT NULL THEN
    ld_return_val := p_doc_date;
  ELSE
    --ld_ret_date := GetCargoBLDate(p_contract_id, p_cargo_name, p_qty_type, p_alloc_no, p_daytime);

    IF p_doc_key IS NULL THEN
       lv2_term_id := ec_contract_doc_version.doc_date_term_id(p_doc_setup_id, p_point_of_sale_date, '<=');
    ELSE
       lv2_term_id := ec_cont_document.doc_date_term_id(p_doc_key);
    END IF;

    lv2_method  :=  ec_doc_date_term_version.doc_date_term_method(lv2_term_id, p_point_of_sale_date, '<=');

     IF  lv2_method = 'POSD_FIRST' THEN
          FOR curRec IN c_posd_min(p_contract_id, p_cargo_no, p_qty_type, p_alloc_no, p_point_of_sale_date, p_customer_id) LOOP
              ld_return_val := curRec.POS_DATE;
          END LOOP;

     ELSIF lv2_method = 'POSD_LAST' THEN
          FOR curRec IN c_posd_max(p_contract_id, p_cargo_no, p_qty_type, p_alloc_no, p_point_of_sale_date, p_customer_id) LOOP
              ld_return_val := curRec.POS_DATE;
          END LOOP;

     ELSIF lv2_method = 'LOAD_COMM_FIRST' THEN
          FOR curRec IN c_ldcommenced_min(p_contract_id, p_cargo_no, p_qty_type, p_alloc_no, p_point_of_sale_date, p_customer_id) LOOP
              ld_return_val := curRec.Loading_Date_Commenced;
          END LOOP;

     ELSIF lv2_method = 'LOAD_COMM_LAST' THEN
          FOR curRec IN c_ldcommenced_max(p_contract_id, p_cargo_no, p_qty_type, p_alloc_no, p_point_of_sale_date, p_customer_id) LOOP
              ld_return_val := curRec.Loading_Date_Commenced;
          END LOOP;

     ELSIF lv2_method = 'LOAD_COMP_FIRST' THEN
          FOR curRec IN c_ldcompleted_min(p_contract_id, p_cargo_no, p_qty_type, p_alloc_no, p_point_of_sale_date, p_customer_id) LOOP
              ld_return_val := curRec.Loading_Date_Completed;
          END LOOP;

     ELSIF lv2_method = 'LOAD_COMP_LAST' THEN
          FOR curRec IN c_ldcompleted_max(p_contract_id, p_cargo_no, p_qty_type, p_alloc_no, p_point_of_sale_date, p_customer_id) LOOP
              ld_return_val := curRec.Loading_Date_Completed;
      	  END LOOP;

     ELSIF lv2_method = 'DIS_COMM_FIRST' THEN
          FOR curRec IN c_ddcommenced_min(p_contract_id, p_cargo_no, p_qty_type, p_alloc_no, p_point_of_sale_date, p_customer_id) LOOP
              ld_return_val := curRec.Delivery_Date_Commenced;
          END LOOP;

     ELSIF lv2_method = 'DIS_COMM_LAST' THEN
          FOR curRec IN c_ddcommenced_max(p_contract_id, p_cargo_no, p_qty_type, p_alloc_no, p_point_of_sale_date, p_customer_id) LOOP
              ld_return_val := curRec.Delivery_Date_Commenced;
      	  END LOOP;

     ELSIF lv2_method = 'DIS_COMP_FIRST' THEN
          FOR curRec IN c_ddcompleted_min(p_contract_id, p_cargo_no, p_qty_type, p_alloc_no, p_point_of_sale_date, p_customer_id) LOOP
              ld_return_val := curRec.Delivery_Date_Completed;
          END LOOP;

     ELSIF lv2_method = 'DIS_COMP_LAST' THEN
          FOR curRec IN c_ddcompleted_max(p_contract_id, p_cargo_no, p_qty_type, p_alloc_no, p_point_of_sale_date, p_customer_id) LOOP
              ld_return_val := curRec.Delivery_Date_Completed;
          END LOOP;

     ELSIF lv2_method = 'BL_DATE_FIRST' THEN
          FOR curRec IN c_bld_min(p_contract_id, p_cargo_no, p_qty_type, p_alloc_no, p_point_of_sale_date, p_customer_id) LOOP
              ld_return_val := curRec.Bl_Date;
          END LOOP;

     ELSIF lv2_method = 'BL_DATE_LAST' THEN
          FOR curRec IN c_bld_max(p_contract_id, p_cargo_no, p_qty_type, p_alloc_no, p_point_of_sale_date, p_customer_id) LOOP
              ld_return_val := curRec.Bl_Date;
          END LOOP;

     ELSIF lv2_method = 'SYSDATE' THEN
           ld_return_val := trunc(Ecdp_Timestamp.getCurrentSysdate, 'dd');

     END IF;

     -- If date could not be determined, try to get it by using Ecdp_Contract_Setup
     IF ld_return_val IS NULL THEN
        ld_return_val := Ecdp_Contract_Setup.getDocDate(p_contract_id, p_doc_key, p_point_of_sale_date, p_doc_date, p_doc_setup_id);
     END IF;

     -- Fallback to ensure a valid date
     ld_return_val := ecdp_contract_setup.getValidDocDaytime(p_contract_id, p_doc_setup_id, ld_return_val);

  END IF;

  RETURN ld_return_val;

END GetCargoDocDate;

-----------------------------------------------------------------------------------------------------------------

FUNCTION isDocumentQtyInterfaced (
            p_document_key VARCHAR2)
RETURN VARCHAR2
IS

  CURSOR c_Count(cp_document_key VARCHAR2) IS
    SELECT
    (
    SELECT COUNT(*) FROM ifac_cargo_value c
     WHERE c.transaction_key IN (SELECT transaction_key
                                   FROM cont_transaction
                                  WHERE document_key = cp_document_key)
    )
    +
    (
    SELECT COUNT(*) FROM ifac_sales_qty p
     WHERE p.transaction_key IN (SELECT transaction_key
                                   FROM cont_transaction
                                  WHERE document_key = cp_document_key)
    )
    +
    (
    SELECT COUNT(*) FROM ifac_document d
     WHERE d.document_key = cp_document_key
    ) tot FROM DUAL;

  lv2_ifac_ind VARCHAR2(1) := 'N';

BEGIN

  FOR rsT in c_Count(p_document_key) LOOP
    IF rsT.Tot > 0 THEN
      lv2_ifac_ind := 'Y';
	     END IF;
	  END LOOP;

  RETURN lv2_ifac_ind;

END isDocumentQtyInterfaced;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION GetDocUOMInd(p_document_key VARCHAR2,
                      p_uom_col VARCHAR2)
RETURN VARCHAR2
IS

  CURSOR c_count(cp_document_key VARCHAR2) IS
     SELECT count(uom1_code) uom1,
            count(uom2_code) uom2,
            count(uom3_code) uom3,
            count(uom4_code) uom4
     FROM cont_transaction_qty t
     WHERE ec_cont_transaction.document_key(t.transaction_key) = cp_document_key;

  lv2_ret VARCHAR2(1) := 'N';

BEGIN

  FOR rsC IN c_count(p_document_key) LOOP

      IF p_uom_col = 'UOM1' THEN

         IF NVL(rsC.Uom1,0) > 0 THEN
            lv2_ret := 'Y';
         END IF;

      ELSIF p_uom_col = 'UOM2' THEN

         IF NVL(rsC.Uom2,0) > 0 THEN
            lv2_ret := 'Y';
         END IF;

      ELSIF p_uom_col = 'UOM3' THEN

         IF NVL(rsC.Uom3,0) > 0 THEN
            lv2_ret := 'Y';
         END IF;

      ELSIF p_uom_col = 'UOM4' THEN

         IF NVL(rsC.Uom4,0) > 0 THEN
            lv2_ret := 'Y';
         END IF;

      END IF;

  END LOOP;

  RETURN lv2_ret;

END GetDocUOMInd;

FUNCTION GetDocumentCargoName(
         p_document_key VARCHAR2
) RETURN VARCHAR2
IS

 CURSOR c_cargo(cp_document_key VARCHAR2) IS
   SELECT DISTINCT cargo_name
     FROM cont_transaction t
    WHERE t.document_key = cp_document_key;

  lv2_cargos VARCHAR2(500) := NULL;

BEGIN

  FOR rsC IN c_cargo(p_document_key) LOOP

    IF lv2_cargos IS NOT NULL THEN
      lv2_cargos := lv2_cargos || ', ';
    END IF;

    lv2_cargos := lv2_cargos || rsC.Cargo_Name;

    END LOOP;

  RETURN lv2_cargos;

END GetDocumentCargoName;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION isERPDocEditable(
               p_erp_doc_key VARCHAR2)
RETURN VARCHAR2
IS

  lrec_rec cont_document%ROWTYPE := ec_cont_document.row_by_pk(p_erp_doc_key);
  lv2_ret_val VARCHAR2(1) := 'N';
  ln_count NUMBER := 0;

  CURSOR c_cnt IS
    SELECT COUNT(*) num FROM ifac_document WHERE document_key = p_erp_doc_key;

BEGIN

  -- TODO: Add proper logic for determining editability

  -- Only open documents are editable
  IF lrec_rec.document_level_code = 'OPEN' THEN


    -- Only documents created manually are editable
    FOR rsC IN c_cnt LOOP
      ln_count := rsC.Num;
    END LOOP;
    IF ln_count = 0 THEN
      lv2_ret_val := 'Y';
    END IF;

  END IF;

  RETURN lv2_ret_val;

END isERPDocEditable;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION isERPPostingEditable(
               p_erp_rec_key VARCHAR2)
RETURN VARCHAR2
IS

  rec_erp cont_erp_postings%ROWTYPE := ec_cont_erp_postings.row_by_pk(p_erp_rec_key);
  lv2_ret_val VARCHAR2(1) := 'N';

BEGIN

  IF isERPDocEditable(rec_erp.document_key) = 'Y' THEN

    -- TODO: Add proper logic for determining editability


    -- Reversals are not editable
    IF nvl(rec_erp.reversal_ind,'N') = 'Y' THEN
      lv2_ret_val := 'N';
    ELSE
      lv2_ret_val := 'Y';
    END IF;

  END IF;

  RETURN lv2_ret_val;

END isERPPostingEditable;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION CountDocNonRevTrans(p_Document_Key VARCHAR2)
RETURN NUMBER
IS

  ln_count NUMBER := 0;

  CURSOR c_count IS
    SELECT COUNT(*) count_trans
      FROM cont_transaction ct
     WHERE ct.document_key = p_Document_Key
       AND ct.reversal_ind = 'N';

BEGIN

  FOR rsC IN c_count LOOP
    ln_count := rsC.count_trans;
  END LOOP;

  RETURN ln_count;

END CountDocNonRevTrans;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION GetTheLastMPDDoc(p_contract_doc_id VARCHAR2, p_customer_id VARCHAR2)
RETURN VARCHAR2
IS

  -- Get the last document for this contract / processing period
  CURSOR c_mpd(cp_contract_doc_id VARCHAR2, cp_customer_id VARCHAR2) IS
    SELECT cd.document_key
      FROM cont_document cd
     WHERE cd.contract_doc_id = cp_contract_doc_id
       AND cd.reversal_ind = 'N'
       AND cd.customer_id = cp_customer_id
        AND NOT EXISTS
        (SELECT 1
           FROM cont_document cd2
          WHERE cd2.preceding_document_key = cd.document_key
            AND cd2.reversal_ind = 'Y')
     ORDER BY created_date DESC;

  lv2_last_doc_key cont_document.document_key%TYPE;

BEGIN

  FOR rsD IN c_mpd(p_contract_doc_id, p_customer_id) LOOP

    lv2_last_doc_key := rsD.Document_Key;
    EXIT;

  END LOOP;

  RETURN lv2_last_doc_key;

END GetTheLastMPDDoc;

------------------------------------------------------------------------------------------------------------------------------------------

Function GetParcelNo(p_parcel_no VARCHAR2,
                     p_doc_setup_id VARCHAR2,
                     p_point_of_Sale_date DATE)
  RETURN VARCHAR2
  IS
  lv2_ret_val VARCHAR2(30) := null;
  BEGIN

  IF ec_contract_doc_version.single_parcel_doc_ind(p_doc_setup_id,p_point_of_sale_date,'<=') = 'Y' THEN
     lv2_ret_val := p_parcel_no;
  ELSE
    lv2_ret_val := '';
  END IF;


    RETURN lv2_ret_val;
    END GetParcelNo;

--------------------------------------------------------------------------------------------------
--<EC-DOC>
-------------------------------------------------------------------------------------------------------------------------------------------
-- Function      : isNewTransactionInterfaced
-- Description    : Checks if trasaction is deleted and reinterfaced again then shows error "Delete and recreate to pull new transaction".
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : stim_mth_cargo_value ,stim_mth_contract_value,ifac_cargo_value
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION isNewTransactionInterfaced(p_object_id VARCHAR2,
                                    p_document_key VARCHAR2,
                                    p_doc_date DATE DEFAULT NULL,
                                    p_doc_scope VARCHAR2,
                                    p_Level_code VARCHAR2,
                                    p_contract_doc_id VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS

--Cursor for cargo records
CURSOR c_cargo_pending_records(cp_document_key VARCHAR2) IS
      SELECT DISTINCT usmcv.trans_temp_id
      FROM ifac_cargo_value psmcv, ifac_cargo_value usmcv
      WHERE psmcv.document_key = cp_document_key                   -- document being processed
      AND psmcv.transaction_key IS NULL                            -- transaction deleted
      AND psmcv.alloc_no_max_ind = 'N'                             -- there is record interfaced after document processed
      AND usmcv.alloc_no_max_ind = 'Y'                             -- get hold of unprocessed records.
      AND usmcv.ignore_ind = 'N'
      AND psmcv.contract_id = usmcv.contract_id                    -- match contract id
      AND psmcv.vendor_id = usmcv.vendor_id                        -- match vendor id
      AND psmcv.qty_type = usmcv.qty_type                          -- match quantity type
      AND psmcv.profit_center_id = usmcv.profit_center_id          -- match profit center id
      AND psmcv.price_concept_code = usmcv.price_concept_code;      -- match price concept code

--Cursor for period records
CURSOR c_period_pending_records(cp_document_key VARCHAR2, cp_Level_code VARCHAR2,cp_object_id VARCHAR2,Cp_contract_doc_id VARCHAR2) IS
       SELECT DISTINCT usmcv.trans_temp_id trans_temp_id
       FROM ifac_sales_qty psmcv, ifac_sales_qty usmcv
       WHERE psmcv.document_key = cp_document_key                   -- document being processed
       AND psmcv.transaction_key IS NULL                            -- transaction deleted
       AND psmcv.alloc_no_max_ind = 'N'                             -- there is record interfaced after document processed
       AND usmcv.alloc_no_max_ind = 'Y'                             -- get hold of unprocessed records.
       AND usmcv.ignore_ind = 'N'
       AND psmcv.processing_period = usmcv.processing_period        -- match processing period
       AND psmcv.contract_id = usmcv.contract_id                    -- match contract id
       AND psmcv.vendor_id = usmcv.vendor_id                        -- match vendor id
       AND psmcv.delivery_point_id = usmcv.delivery_point_id        -- match delivery point id
       AND psmcv.profit_center_id = usmcv.profit_center_id         -- match profit center id
  UNION
    SELECT DISTINCT usmcv.trans_temp_id trans_temp_id               -- Get those where it is being appended to open document
       FROM ifac_sales_qty usmcv
       WHERE usmcv.Preceding_Doc_Key = cp_document_key                      -- document being processed
       AND usmcv.doc_setup_id = cp_contract_doc_id
       AND cp_Level_code in ('OPEN','VALID1','VALID2')
       AND usmcv.transaction_key is null
       AND usmcv.contract_id = cp_object_id
       AND usmcv.alloc_no_max_ind = 'Y'
       AND usmcv.ignore_ind = 'N';


CURSOR c_cargo_doc_date is
   SELECT DISTINCT ecdp_document_gen_util.GetCargoDocDate(usmcv.contract_id,              -- Contract_id
                                                       usmcv.cargo_no,                    -- Cargo Name
                                                       usmcv.qty_type,                    -- Quanity Type
                                                       usmcv.alloc_no,                    -- Allocation Number
                                                       trunc(usmcv.point_of_sale_date,'MM'),
                                                       usmcv.doc_setup_id,
                                                       usmcv.customer_id) doc_date

      FROM ifac_cargo_value psmcv, ifac_cargo_value usmcv
      WHERE psmcv.document_key = p_document_key                  -- document being processed
      AND usmcv.alloc_no_max_ind = 'Y'                          -- get hold of unprocessed records.
      AND psmcv.contract_id = usmcv.contract_id                 -- match contract id
      AND psmcv.cargo_no = usmcv.cargo_no                       -- match cargo name
      AND psmcv.vendor_id = usmcv.vendor_id                     -- match vendor id
      AND psmcv.qty_type = usmcv.qty_type                       -- match quantity type
      AND psmcv.profit_center_id = usmcv.profit_center_id       -- match profit center id
      AND psmcv.price_concept_code = usmcv.price_concept_code;  -- match price concept code

TYPE t_trans_temp_id IS TABLE OF VARCHAR2(32);
ltab_trans_temp_id t_trans_temp_id := t_trans_temp_id();

lv2_tran_del_ind VARCHAR2(1) := 'N';
lv2_tran_temp_found NUMBER := -1;
lv2_doc_date DATE;

BEGIN
   -- Check contract_group_code
    IF p_doc_scope = 'CARGO_BASED' THEN

     for c_Doc_date in c_cargo_doc_date loop
       lv2_doc_date := c_Doc_date.doc_date;
     end loop;

      IF lv2_doc_date is not null and lv2_doc_date = p_doc_date THEN

        FOR cprC IN c_cargo_pending_records(p_document_key) LOOP
            ltab_trans_temp_id.EXTEND;
            ltab_trans_temp_id(ltab_trans_temp_id.LAST) := cprC.trans_temp_id;
        END LOOP;
      END IF;

     ELSIF p_doc_scope = 'PERIOD_BASED' THEN
           FOR pprC IN c_period_pending_records(p_document_key,p_Level_code,p_object_id,p_contract_doc_id) LOOP
              ltab_trans_temp_id.EXTEND;
              ltab_trans_temp_id(ltab_trans_temp_id.LAST) := pprC.trans_temp_id;
           END LOOP;

     END IF;

      FOR i IN 1..ltab_trans_temp_id.COUNT LOOP
          SELECT COUNT(*) INTO lv2_tran_temp_found
          FROM Cont_transaction ct WHERE document_key = p_document_key
          AND ct.trans_template_id = ltab_trans_temp_id(i);   -- Collection

          IF lv2_tran_temp_found = 0 THEN
             lv2_tran_del_ind := 'Y';
             EXIT;
          END IF;
      END LOOP;

RETURN lv2_tran_del_ind;

END isNewTransactionInterfaced;

END EcDp_Document_Gen_Util;