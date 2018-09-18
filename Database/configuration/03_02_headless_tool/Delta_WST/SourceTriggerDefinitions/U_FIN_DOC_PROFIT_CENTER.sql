CREATE OR REPLACE EDITIONABLE TRIGGER "U_FIN_DOC_PROFIT_CENTER" 
INSTEAD OF UPDATE ON v_cont_line_item_dist_sum
FOR EACH ROW

DECLARE

  -- Get Key
  n_TRANSACTION_KEY VARCHAR2(32) := :NEW.TRANSACTION_KEY;
  n_dist_id VARCHAR2(32) := :new.dist_id;

  -- Get values to save
  n_QTY1 NUMBER := EcDB_Utils.ConditionNVL(NOT Updating('QTY1'),:NEW.QTY1,:OLD.QTY1);
  n_QTY2 NUMBER := EcDB_Utils.ConditionNVL(NOT Updating('QTY2'),:NEW.QTY2,:OLD.QTY2);
  n_QTY3 NUMBER := EcDB_Utils.ConditionNVL(NOT Updating('QTY3'),:NEW.QTY3,:OLD.QTY3);
  n_QTY4 NUMBER := EcDB_Utils.ConditionNVL(NOT Updating('QTY4'),:NEW.QTY4,:OLD.QTY4);
  n_COMMENTS VARCHAR2(3000) := EcDB_Utils.ConditionNVL(NOT Updating('COMMENTS'),:NEW.COMMENTS,:OLD.COMMENTS);

  ln_field_sum_1 NUMBER;
  ln_field_sum_2 NUMBER;
  ln_field_sum_3 NUMBER;
  ln_field_sum_4 NUMBER;

  -- Get the sum of dist level qtys
  CURSOR cDistSum(cp_trans_key VARCHAR2) IS
    SELECT SUM(clid.qty1) Qty1,
           SUM(clid.qty2) Qty2,
           SUM(clid.qty3) Qty3,
           SUM(clid.qty4) Qty4
      FROM cont_line_item_dist clid
     WHERE clid.transaction_key = cp_trans_key
       AND clid.line_item_based_type = 'QTY'
       AND sort_order =
           (SELECT MIN(sort_order)
              FROM cont_line_item cli
             WHERE cli.transaction_key = clid.transaction_key
               AND cli.line_item_based_type = 'QTY');

  -- Loop over fields and calculate split share based on new qtys
  CURSOR cDist(cp_trans_key VARCHAR2) IS
    SELECT clid.qty1,
           clid.qty2,
           clid.qty3,
           clid.qty4,
           clid.dist_id
    FROM cont_line_item_dist clid
    WHERE clid.transaction_key = cp_trans_key
    AND clid.line_item_based_type = 'QTY'
    AND sort_order = (SELECT MIN(sort_order)
                        FROM cont_line_item cli
                       WHERE cli.transaction_key = clid.transaction_key
                         AND cli.line_item_based_type = 'QTY');

BEGIN


  IF Ec_Cont_Transaction.transaction_date(n_TRANSACTION_KEY) IS NULL THEN
     Raise_Application_Error(-20000,'Point Of Sale Date is not set on transaction ' ||  n_transaction_key || '. \n\nPlease provide and try again.');
  END IF;

  -- Update field level with qtys supplied in the screen
  IF Updating('QTY1') OR Updating('QTY2') OR Updating('QTY3') OR Updating('QTY4') OR Updating('COMMENTS') THEN

     UPDATE cont_line_item_dist lid
        SET lid.QTY1              = n_QTY1,
            lid.QTY2              = n_QTY2,
            lid.QTY3              = n_QTY3,
            lid.QTY4              = n_QTY4,
            lid.COMMENTS          = n_COMMENTS,
            lid.last_updated_date = lid.last_updated_date
      WHERE lid.TRANSACTION_KEY = n_TRANSACTION_KEY
        AND lid.dist_id = n_dist_id
        AND lid.LINE_ITEM_BASED_TYPE = 'QTY';

  END IF;


  -- Get sum of all fields
  FOR rsT IN cDistSum(n_TRANSACTION_KEY) LOOP

      ln_field_sum_1 := rsT.Qty1;
      ln_field_sum_2 := rsT.Qty2;
      ln_field_sum_3 := rsT.Qty3;
      ln_field_sum_4 := rsT.Qty4;

  END LOOP;


  -- Loop over fields and calculate split share based on new qtys
  FOR rsD IN cDist(n_TRANSACTION_KEY) LOOP

    UPDATE cont_line_item_dist clid
       SET clid.split_share       = (CASE WHEN ln_field_sum_1 <> 0 THEN(NVL(rsD.Qty1, 0) / ln_field_sum_1) ELSE 0 END),
           clid.split_share_qty2  = (CASE WHEN ln_field_sum_2 <> 0 THEN(NVL(rsD.Qty2, 0) / ln_field_sum_2) ELSE NULL END),
           clid.split_share_qty3  = (CASE WHEN ln_field_sum_3 <> 0 THEN(NVL(rsD.Qty3, 0) / ln_field_sum_3) ELSE NULL END),
           clid.split_share_qty4  = (CASE WHEN ln_field_sum_4 <> 0 THEN(NVL(rsD.Qty4, 0) / ln_field_sum_4) ELSE NULL END),
           clid.last_updated_date = clid.last_updated_date
     WHERE clid.transaction_key = n_TRANSACTION_KEY
       AND clid.dist_id = rsD.dist_id;

  END LOOP;

END;
