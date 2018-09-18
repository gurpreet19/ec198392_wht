CREATE OR REPLACE EDITIONABLE TRIGGER "U_FIN_DOC_COMPANY" 
INSTEAD OF UPDATE ON v_cont_li_dist_company_sum
FOR EACH ROW

DECLARE

  -- Get Key
  n_TRANSACTION_KEY         VARCHAR2(32) := :NEW.TRANSACTION_KEY;
  n_dist_id                 VARCHAR2(32) := :new.dist_id;
  n_VENDOR_ID               VARCHAR2(32) := :NEW.VENDOR_ID;
  n_CUSTOMER_ID             VARCHAR2(32) := :NEW.CUSTOMER_ID;

  -- Get values to save
  n_QTY1 NUMBER := EcDB_Utils.ConditionNVL(NOT Updating('QTY1'),:NEW.QTY1,:OLD.QTY1);
  n_QTY2 NUMBER := EcDB_Utils.ConditionNVL(NOT Updating('QTY2'),:NEW.QTY2,:OLD.QTY2);
  n_QTY3 NUMBER := EcDB_Utils.ConditionNVL(NOT Updating('QTY3'),:NEW.QTY3,:OLD.QTY3);
  n_QTY4 NUMBER := EcDB_Utils.ConditionNVL(NOT Updating('QTY4'),:NEW.QTY4,:OLD.QTY4);
  n_COMMENTS VARCHAR2(3000) := EcDB_Utils.ConditionNVL(NOT Updating('COMMENTS'),:NEW.COMMENTS,:OLD.COMMENTS);

  ln_company_sum_1 NUMBER;
  ln_company_sum_2 NUMBER;
  ln_company_sum_3 NUMBER;
  ln_company_sum_4 NUMBER;

  -- Get the sum of company level qtys
  CURSOR cCompSum(cp_trans_key VARCHAR2, cp_dist_id VARCHAR2) IS
    SELECT SUM(clidc.qty1) Qty1,
           SUM(clidc.qty2) Qty2,
           SUM(clidc.qty3) Qty3,
           SUM(clidc.qty4) Qty4
    FROM cont_li_dist_company clidc
    WHERE clidc.transaction_key = cp_trans_key
    AND clidc.dist_id = cp_dist_id
    AND clidc.line_item_based_type = 'QTY'
    AND clidc.sort_order = (SELECT MIN(sort_order)
                              FROM cont_line_item cli
                             WHERE cli.transaction_key = clidc.transaction_key
                               AND cli.line_item_based_type = 'QTY');

  -- Loop over companies and calculate split share based on new qtys
  CURSOR cComp(cp_trans_key VARCHAR2, cp_dist_id VARCHAR2) IS
    SELECT clidc.qty1,
           clidc.qty2,
           clidc.qty3,
           clidc.qty4,
           clidc.dist_id,
           clidc.vendor_id,
           clidc.customer_id
    FROM cont_li_dist_company clidc
    WHERE clidc.transaction_key = cp_trans_key
    AND clidc.dist_id = cp_dist_id
    AND clidc.line_item_based_type = 'QTY'
    AND clidc.sort_order = (SELECT MIN(sort_order)
                              FROM cont_line_item cli
                             WHERE cli.transaction_key = clidc.transaction_key
                               AND cli.line_item_based_type = 'QTY');

BEGIN


  IF Ec_Cont_Transaction.transaction_date(n_TRANSACTION_KEY) IS NULL THEN
     Raise_Application_Error(-20000,'Point Of Sale Date is not set on transaction ' ||  n_transaction_key || '. \n\nPlease provide and try again.');
  END IF;

  IF Updating('QTY1') OR Updating('QTY2') OR Updating('QTY3') OR Updating('QTY4') OR Updating('COMMENTS') THEN

     UPDATE cont_li_dist_company lidc
        SET lidc.QTY1              = n_QTY1,
            lidc.QTY2              = n_QTY2,
            lidc.QTY3              = n_QTY3,
            lidc.QTY4              = n_QTY4,
            lidc.COMMENTS          = n_COMMENTS,
            lidc.last_updated_date = lidc.last_updated_date
      WHERE lidc.TRANSACTION_KEY = n_TRANSACTION_KEY
        AND lidc.dist_id = n_dist_id
        AND lidc.CUSTOMER_ID = n_CUSTOMER_ID
        AND lidc.VENDOR_ID = n_VENDOR_ID
        AND lidc.LINE_ITEM_BASED_TYPE = 'QTY';
  END IF;


    -- Get sum of all companies
  FOR rsT IN cCompSum(n_TRANSACTION_KEY, n_dist_id) LOOP

      ln_company_sum_1 := rsT.Qty1;
      ln_company_sum_2 := rsT.Qty2;
      ln_company_sum_3 := rsT.Qty3;
      ln_company_sum_4 := rsT.Qty4;

  END LOOP;

 -- Loop over companies and calculate split share based on new qtys
  FOR rsD IN cComp(n_TRANSACTION_KEY, n_dist_id) LOOP


    UPDATE cont_li_dist_company clidc
       SET clidc.vendor_share      = (CASE WHEN ln_company_sum_1 <> 0 THEN(NVL(rsD.Qty1, 0) / ln_company_sum_1) ELSE clidc.vendor_share END), -- TODO: NVL-handling
           clidc.vendor_share_qty2 = (CASE WHEN ln_company_sum_2 <> 0 THEN(NVL(rsD.Qty2, 0) / ln_company_sum_2) ELSE(CASE WHEN clidc.uom2_code IS NOT NULL THEN clidc.vendor_share_qty2 ELSE NULL END) END),
           clidc.vendor_share_qty3 = (CASE WHEN ln_company_sum_3 <> 0 THEN(NVL(rsD.Qty3, 0) / ln_company_sum_3) ELSE(CASE WHEN clidc.uom3_code IS NOT NULL THEN clidc.vendor_share_qty3 ELSE NULL END) END),
           clidc.vendor_share_qty4 = (CASE WHEN ln_company_sum_4 <> 0 THEN(NVL(rsD.Qty4, 0) / ln_company_sum_4) ELSE(CASE WHEN clidc.uom4_code IS NOT NULL THEN clidc.vendor_share_qty4 ELSE NULL END) END),
           clidc.last_updated_date = clidc.last_updated_date
     WHERE clidc.transaction_key = n_TRANSACTION_KEY
       AND clidc.dist_id = rsD.dist_id
       AND clidc.vendor_id = rsD.vendor_id
       AND clidc.customer_id = rsD.Customer_Id;


  END LOOP;

END;
