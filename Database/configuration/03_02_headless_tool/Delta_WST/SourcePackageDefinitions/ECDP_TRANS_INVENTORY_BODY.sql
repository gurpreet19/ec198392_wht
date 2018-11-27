CREATE OR REPLACE PACKAGE BODY EcDp_Trans_Inventory IS
/****************************************************************
** Package        :  EcDp_Trans_Inventory, body part
**
** $Revision: 1.2 $
**
** Purpose        :  Provide special functions on Inventory. Use EcDp_Objects for basis functions
**
** Documentation  :  www.energy-components.com
**
** erd  : 23.02.2014 Brandon Lewis
**
** Modification history:
**
** Date       Whom  Change description:
** ---------- ----- --------------------------------------

*****************************************************************/


type T_TRANS_INV_2 is record(
   /*RUN_NO NUMBER
   ,TEMPLATE_CODE VARCHAR2(100)
   ,*/SORT_ITEM NUMBER
   --,BALANCE_LEVEL VARCHAR2(1000)
   ,PROD_STREAM_NAME  VARCHAR2(1000)
   ,INVENTORY_NAME           VARCHAR2(1000)
   ,Country            VARCHAR2(1000)
   ,DELIVERY_POINT           VARCHAR2(1000)
   ,VISIBLE          VARCHAR2(1000)
   ,TRANSACTION_TAG         VARCHAR2(1000)
   ,LAYER_MONTH     DATE
   ,PROD_DATE                           DATE
   ,DIM_1          VARCHAR2(1000)
   ,DIM_2          VARCHAR2(1000)
   ,VALUE            NUMBER
   ,COLUMN_NAME   VARCHAR2(1000)
);


-- Used to pull dimentsions FROM the calculation variable template
    cursor gc_dimensions(cp_object_id  VARCHAR2,
                         cp_daytime    DATE,
                         cp_end_date   DATE) is
           SELECT tvpv.*,
                  null src_object_id,
                  tvpv.type key
             FROM config_variable_param_vrsn tvpv,
                  config_variable_param tvp
            WHERE tvp.object_id = tvpv.object_id
              AND tvp.config_variable_id = cp_object_id
              AND tvpv.daytime <= cp_daytime
              AND nvl(tvp.end_date, nvl(cp_end_date,Ecdp_Timestamp.getCurrentSysdate+1)) >= nvl(cp_end_date,Ecdp_Timestamp.getCurrentSysdate+1)
         ORDER BY tvpv.dimension;

-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
--*** Copy / Paste functionality for Transaction Network and Inventory Lines / Products         ***--
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------------------
-- Function       : btnSaveInventory
-- Description    : This is used by the button in Transaction overview to track the chosen date or inventory
--                  to change when reloading after a button click
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CLIPBOARD
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------


PROCEDURE btnSaveInventory(p_contract_id VARCHAR2,
                           p_calc_group_id VARCHAR2,
                           p_object_id   VARCHAR2 default NULL,
                           p_daytime     DATE,
                           p_user_id     VARCHAR2) IS
  lv2_object_id VARCHAR2(32);
  lv2_key3      VARCHAR2(1000);
  ln_count      NUMBER;
  BEGIN
    lv2_object_id := p_object_id;



  IF lv2_object_id IS NULL THEN

      SELECT count(*) into ln_count
        FROM REVN_CLIPBOARD
       WHERE type = 'INVENTORY_NAVIGATION'
         AND USER_ID = p_user_id
         AND key1 = decode(nvl(p_contract_id,'null'),'null',p_calc_group_id,p_contract_id);

         IF ln_count > 0 THEN
            SELECT KEY2, KEY3 into lv2_object_id, lv2_key3
              FROM REVN_CLIPBOARD
             WHERE type = 'INVENTORY_NAVIGATION'
               AND USER_ID = p_user_id
               AND key1 = decode(nvl(p_contract_id,'null'),'null',p_calc_group_id,p_contract_id);
         END IF;
 END IF;

    DELETE FROM REVN_CLIPBOARD
     WHERE type = 'INVENTORY_NAVIGATION'
       AND USER_ID = p_user_id;

    INSERT INTO REVN_CLIPBOARD
                (TYPE,USER_ID,KEY1,KEY2,KEY3,DAYTIME)
    VALUES ('INVENTORY_NAVIGATION',p_user_id,decode(nvl(p_contract_id,'null'),'null',p_calc_group_id,p_contract_id),lv2_object_id,lv2_key3,p_daytime);

END btnSaveInventory;

-----------------------------------------------------------------------------------------------------
-- Function       : btnSaveInventoryTemplate
-- Description    : This is used by the button in Transaction overview to track the chosen template
--                  when reloading after a button click.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : REVN_CLIPBOARD
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------
PROCEDURE btnSaveInventoryTemplate(p_contract_id          VARCHAR2,
                                   p_prod_stream_group_id VARCHAR2,
                                   p_trans_inventory_id   VARCHAR2,
                                   p_user_id              VARCHAR2,
                                   p_template_code        VARCHAR2) IS
BEGIN
    UPDATE REVN_CLIPBOARD
       SET key3 = p_template_code
     WHERE type = 'INVENTORY_NAVIGATION'
       AND key1 = decode(nvl(p_contract_id, 'null'), 'null', p_prod_stream_group_id, p_contract_id)
       AND key2 = p_trans_inventory_id
       AND user_id = p_user_id;
END btnSaveInventoryTemplate;

-----------------------------------------------------------------------------------------------------
-- Function       : btnCopyTransInv
-- Description    : This is used by the button in Transaction network to copy
--                  a Transaction inventory id to the clipboard to be able to paste somewhere else later
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CLIPBOARD
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------


PROCEDURE btnCopyTransInv(p_trans_inv_id VARCHAR2,
                          p_user_id      VARCHAR2) IS
  BEGIN

    DELETE
      FROM REVN_CLIPBOARD
     WHERE user_id = p_user_id
       AND type = 'TRANS_INV';

    INSERT INTO REVN_CLIPBOARD
           (TYPE,USER_ID,KEY1,DAYTIME)
    VALUES
           ('TRANS_INV',p_user_id,p_trans_inv_id,Ecdp_Timestamp.getCurrentSysdate);

END btnCopyTransInv;


-----------------------------------------------------------------------------------------------------
-- Function       : btnCopyTransInvLine
-- Description    : This is used by the button in Transaction network to copy
--                  a Transaction inventory Line to the clipboard to be able to paste somewhere else later
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CLIPBOARD
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------


PROCEDURE btnCopyTransInvLine(p_trans_inv_id   VARCHAR2,
                              p_trans_inv_line VARCHAR2,
                              p_daytime        DATE,
                              p_user           VARCHAR2) IS
  BEGIN
    DELETE
      FROM REVN_CLIPBOARD
     WHERE user_id = p_user
       AND type = 'TRANS_INV_LINE';

    INSERT INTO REVN_CLIPBOARD
           (TYPE,USER_ID,KEY1,KEY2,DAYTIME)
    VALUES
           ('TRANS_INV_LINE',p_user,p_trans_inv_id,p_trans_inv_line,p_daytime);

END btnCopyTransInvLine;



-----------------------------------------------------------------------------------------------------
-- Function       : btnCopyTransInvLiProdSet
-- Description    : This is used by the button in Transaction network to copy
--                  a Transaction inventory Line Product Set to the clipboard to be able to paste somewhere else later
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CLIPBOARD
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------

PROCEDURE btnCopyTransInvLiProdSet(p_trans_inv_id    VARCHAR2,
                                   p_trans_inv_line  VARCHAR2,
                                   p_daytime         DATE,
                                   p_user_id         VARCHAR2) IS
  BEGIN
    DELETE
      FROM REVN_CLIPBOARD
     WHERE user_id = p_user_id
       AND type = 'TRANS_INV_LINE_PROD_SET';

    INSERT INTO REVN_CLIPBOARD
           (TYPE,USER_ID,KEY1,KEY2,DAYTIME)
    VALUES
           ('TRANS_INV_LINE_PROD_SET',p_user_id,p_trans_inv_id,p_trans_inv_line,p_daytime);

END btnCopyTransInvLiProdSet;


-----------------------------------------------------------------------------------------------------
-- Function       : btnCopyTransInvLiVarSet
-- Description    : This is used by the button in Transaction network to copy
--                  a Transaction inventory Line Product Set to the clipboard to be able to paste someWHERE else later
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CLIPBOARD
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------

PROCEDURE btnCopyTransInvLiVarSet(p_trans_inv_id       VARCHAR2,
                                  p_trans_inv_line     VARCHAR2,
                                  p_daytime            VARCHAR2,
                                  p_product_id         VARCHAR2,
                                  p_cost_type          VARCHAR2,
                                  p_user_id            VARCHAR2,
                                  p_config_variable_id VARCHAR2 DEFAULT NULL,
                                  p_var_exec_order     VARCHAR2 DEFAULT NULL) IS
BEGIN


  DELETE FROM REVN_CLIPBOARD
   WHERE user_id = p_user_id
     AND type = 'TRANS_INV_LINE_VAR_SET';

  INSERT INTO REVN_CLIPBOARD
    (TYPE, USER_ID, KEY1, KEY2, KEY3, KEY4, KEY5, DAYTIME)
  VALUES
    ('TRANS_INV_LINE_VAR_SET',
     p_user_id,
     p_trans_inv_id,
     p_trans_inv_line,
     p_product_id || '-' || p_cost_type,
     p_config_variable_id,
     p_var_exec_order,
     to_date(p_daytime,'yyyy-MM-dd"T"HH24:MI:SS'));

END btnCopyTransInvLiVarSet;


-----------------------------------------------------------------------------------------------------
-- Function       : btnCopyPosting
-- Description    : Procedure is used for copy/paste functionality at different levels related to screen
--                  Transactional Inventory Stream Setup
-- Preconditions  :
-- Postconditions :
-- Using tables   : REVN_CLIPBOARD
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-----------------------------------------------------------------------------------------------------
PROCEDURE btnCopyPosting(p_trans_inv_id       VARCHAR2,
                         p_prod_stream_id     VARCHAR2,
                         p_trans_inv_line_tag VARCHAR2,
                         p_product_group_id   VARCHAR2,
                         p_product_id         VARCHAR2,
                         p_cost_type          VARCHAR2,
                         p_daytime            VARCHAR2,
                         p_user_id            VARCHAR2,
                         p_id                 VARCHAR2) IS         -- Pass NULL if all is applicable
BEGIN

  DELETE FROM REVN_CLIPBOARD
   WHERE user_id = p_user_id
     AND type = 'TRANS_INV_POSTING';

  -- Provide key values in order to retrieve (copy) the posting
  -- If ID is passed, only a single posting will be copied, otherwise the set of postings are copied
  INSERT INTO REVN_CLIPBOARD
    (TYPE, USER_ID, KEY1, KEY2, KEY3, KEY4, KEY5, DAYTIME)
  VALUES
    ('TRANS_INV_POSTING',
     p_user_id,
     p_trans_inv_id,
     p_prod_stream_id,
     p_trans_inv_line_tag,
     p_product_group_id || '-' || p_product_id || '-' || p_cost_type,
     p_id,
     to_date(p_daytime, 'yyyy-MM-dd"T"HH24:MI:SS'));

END btnCopyPosting;

-----------------------------------------------------------------------------------------------------
-- Function       : btnCopyTransInvLiProduct
-- Description    : This is used by the button in Transaction network to copy
--                  a Transaction inventory Line Product id to the clipboard to be able to paste someWHERE else later
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CLIPBOARD
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------


PROCEDURE btnCopyTransInvLiProduct(p_trans_inv_id           VARCHAR2,
                                   p_trans_inv_line         VARCHAR2,
                                   p_daytime                DATE,
                                   p_product_id             VARCHAR2,
                                   p_cost_type              VARCHAR2,
                                   p_user_id                VARCHAR2) IS
  BEGIN
    DELETE
      FROM REVN_CLIPBOARD
     WHERE user_id = p_user_id
       AND type = 'TRANS_INV_LINE_PRODUCT';

    INSERT INTO REVN_CLIPBOARD
           (TYPE,USER_ID,KEY1,KEY2,KEY3,DAYTIME)
    VALUES
           ('TRANS_INV_LINE_PRODUCT',p_user_id,p_trans_inv_id,p_trans_inv_line,p_product_id||'-'||p_cost_type,p_daytime);

END btnCopyTransInvLiProduct;



-----------------------------------------------------------------------------------------------------
-- Function       : btnPasteTransInv
-- Description    : This is used by the button in Transaction network to Paste
--                  a Copied Transaction inventory to a contract
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CLIPBOARD,TRANS_INV_LINE
--
-- Using functions: InsNewTransInvCopy,InsNewTransInvLineCopy
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------

PROCEDURE btnPasteTransInv(p_network_id  VARCHAR2,
                           p_daytime     DATE,
                           p_user_id     VARCHAR2) IS
  cursor saved is
  SELECT*
    FROM REVN_CLIPBOARD
   WHERE TYPE = 'TRANS_INV'
     AND USER_ID = p_user_id;

CURSOR c_TransInvLine(cp_trans_inv_id VARCHAR2,
                      cp_daytime      DATE
                      )        IS
       SELECT*
         FROM TRANS_INV_LINE til
        WHERE til.object_id = cp_trans_inv_id
          AND daytime <= cp_daytime
          AND nvl(end_date,cp_daytime+1) > cp_daytime;

     lv2_new_inv VARCHAR2(32);
     ld_daytime  DATE;

  BEGIN

    ld_daytime := p_daytime;

    FOR item in saved LOOP
        -- Generate new inventory based on old inventory
        lv2_new_inv := InsNewTransInvCopy(p_network_id,
                                          item.key1,
                                          ld_daytime,
                                          ec_trans_inventory.object_code(item.key1),
                                          p_user_id);

        -- Loop over lines
       FOR til in c_TransInvLine(item.key1, ld_daytime) LOOP

           IF til.daytime > ld_daytime THEN
             ld_daytime := til.daytime;
           END IF;

           -- Copy lines FROM old inventory to new
           InsNewTransInvLineCopy(item.key1, -- Tran Inventory to copy
                                  til.tag,             -- Line Tag
                                  lv2_new_inv,         -- Trans Inventory to copy to
                                  til.tag,
                                  til.daytime,
                                  ld_daytime,
                                  p_user_id);


       END LOOP;
    END LOOP;

END btnPasteTransInv;


-----------------------------------------------------------------------------------------------------
-- Function       : btnPasteTransInvLine
-- Description    : This is used by the button in Transaction network to Paste
--                  a Copied Transaction inventory Line to an other Transaction inventory
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CLIPBOARD
--
-- Using functions: InsNewTransInvLineCopy
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------



PROCEDURE btnPasteTransInvLine(p_to_trans_inv_id VARCHAR2,
                               p_daytime         VARCHAR2,
                               p_user_id         VARCHAR2) IS
  cursor saved is
  SELECT*
    FROM REVN_CLIPBOARD
   WHERE TYPE = 'TRANS_INV_LINE'
     AND USER_ID = p_user_id;

     lv2_line VARCHAR2(32);
     ld_date date := to_Date(p_daytime,'YYYY-MM-DD"T"HH24:SS:MI');
  BEGIN

    FOR item in saved LOOP

        lv2_line:= item.key2;
        lv2_line := lv2_line || '_COPY';

/*        IF p_to_trans_inv_id = item.KEY1 THEN
          IF p_daytime = item.Daytime THEN
             lv2_line := lv2_line || '_COPY';

          ELSE
          -- If recent version is not closed then do so
                IF ec_trans_inv_line.end_date(item.key1,
                                              p_daytime,
                                              item.key2,
                                              '<=') IS NULL THEN

                      update trans_inv_line
                         set end_date = p_daytime
                       WHERE object_id = p_to_trans_inv_id
                         and tag = item.key2;


                       updateTILineEndDate(item.key1,
                                           item.key2,
                                           item.daytime,
                                           p_daytime);
                 END IF;
          END IF;
        END IF;*/

         InsNewTransInvLineCopy(item.key1,
                                item.key2,
                                p_to_trans_inv_id,
                                lv2_line,
                                item.daytime,
                                ld_date,
                                p_user_id);
    END LOOP;

END btnPasteTransInvLine;


-----------------------------------------------------------------------------------------------------
-- Function       : btnPasteTransInvLiProdSet
-- Description    : This is used by the button in Transaction network to Paste
--                  a Copied Transaction inventory Line Product set to an other Transaction inventory Line
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CLIPBOARD,TRANS_INV_LI_PRODUCT
--
-- Using functions: CopyTransInvLiProd
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------


PROCEDURE btnPasteTransInvLiProdSet( p_to_trans_inv_id  VARCHAR2,
                                     p_to_line_tag      VARCHAR2,
                                     p_daytime          DATE,
                                     p_user_id          VARCHAR2) IS
  cursor saved is
  SELECT*
    FROM REVN_CLIPBOARD
   WHERE TYPE = 'TRANS_INV_LINE_PROD_SET'
     AND USER_ID = p_user_id;
  BEGIN

    FOR item in saved LOOP


        CopyLineProdSet(item.key1,
                        item.key2,
                        p_to_trans_inv_id,
                        p_to_line_tag,
                        item.daytime,
                        p_daytime,
                        p_user_id);

    END LOOP;
END btnPasteTransInvLiProdSet;



-----------------------------------------------------------------------------------------------------
-- Function       : btnPasteTransInvLiProduct
-- Description    : This is used by the button in Transaction network to Paste
--                  a Copied Transaction inventory Line Product to an other Transaction inventory Line
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CLIPBOARD
--
-- Using functions: CopyTransInvLiProd
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------



PROCEDURE btnPasteTransInvLiProduct( p_to_trans_inv_id          VARCHAR2,
                                     p_to_line_tag              VARCHAR2,
                                     p_daytime                  DATE,
                                     p_user_id                  VARCHAR2) IS
  cursor saved is
  SELECT*
    FROM REVN_CLIPBOARD
   WHERE TYPE = 'TRANS_INV_LINE_PRODUCT'
     AND USER_ID = p_user_id;

     lv2_line VARCHAR2(32);
     lv_product VARCHAR2(32);
     lv_cost_type  VARCHAR2(32);
  BEGIN

    FOR item in saved LOOP

        lv2_line:= item.key2;
        IF p_to_trans_inv_id = item.key1
           and item.key2 = p_to_line_tag
           and item.daytime = p_daytime THEN

          Raise_application_error(-20001,'Can not copy to same inventory');

        END IF;
        lv_product := substr(item.key3,1, instr(item.key3,'|'));
        lv_cost_type := substr(item.key3, instr(item.key3,'|')+1);

/*        CopyTransInvLiProd(item.key1,
                           item.key2,
                           p_to_trans_inv_id,
                           p_to_line_tag,
                           lv_product,
                           lv_cost_type,
                           item.daytime,
                           p_daytime,
                           p_user_id);*/


    END LOOP;

END btnPasteTransInvLiProduct;




-----------------------------------------------------------------------------------------------------
-- Function       : btnPasteTransInvLiVar
-- Description    : This is used by the button in Transaction network to Paste
--                  a Copied Transaction inventory Line Product Variable to an other Transaction inventory Line Product
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CLIPBOARD
--
-- Using functions: CopyTransInvLiProd
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------



PROCEDURE btnPasteTransInvLiVarSet(p_to_trans_inv_id   VARCHAR2,
                                   p_to_prod_stream_id VARCHAR2,
                                   p_to_line_tag       VARCHAR2,
                                   p_to_product_id     VARCHAR2,
                                   p_to_cost_type      VARCHAR2,
                                   p_daytime           VARCHAR2,
                                   p_user_id           VARCHAR2) IS



  cursor saved is
    SELECT *
      FROM REVN_CLIPBOARD
     WHERE TYPE = 'TRANS_INV_LINE_VAR_SET'
       AND USER_ID = p_user_id;

  cursor c_variables(cp_object_id  VARCHAR2,
                     cp_daytime    DATE,
                     cp_product_id VARCHAR2,
                     cp_cost_type  varchar2,
                     cp_line_tag   VARCHAR2,
                     cp_config_variable_id VARCHAR2,
                     cp_var_exec_order NUMBER) is
    SELECT *
      FROM trans_inv_li_pr_var
     WHERE daytime = cp_daytime
       AND product_id = cp_product_id
       AND cost_type = cp_cost_type
       AND line_tag = cp_line_tag
       AND object_id = cp_object_id
       AND config_variable_id =
           nvl(cp_config_variable_id, config_variable_id)
       AND var_exec_order = nvl(cp_var_exec_order, var_exec_order)
     ORDER BY var_exec_order;

  lv2_line                VARCHAR2(32);
  ln_new_exec_order       NUMBER;
  lv_cost_type            VARCHAR2(200);
  lv_product              VARCHAR2(200);
  lr_trans_inv_li_pr_var  trans_inv_li_pr_var%ROWTYPE;

BEGIN

  FOR item in saved LOOP

    lv_product   := substr(item.key3, 1, instr(item.key3, '-')-1);
    lv_cost_type := substr(item.key3, instr(item.key3, '-') + 1);

    FOR var in c_variables(item.key1,
                           item.daytime,
                           lv_product,
                           lv_cost_type,
                           item.key2,
                           item.key4,
                           item.key5) LOOP

      lv2_line := item.key2;


      -- Rec set to copy from
      lr_trans_inv_li_pr_var := ec_trans_inv_li_pr_var.row_by_pk(var.object_id,
                                                                         var.daytime,
                                                                         var.line_tag,
                                                                         var.product_id,
                                                                         var.cost_type,
                                                                         var.var_exec_order,
                                                                         var.config_variable_id,
                                                                         var.prod_stream_id,
                                                                         '<=');

      ln_new_exec_order := CopyTransInvLiPrVar(lr_trans_inv_li_pr_var,
                                               p_to_trans_inv_id,
                                               p_to_prod_stream_id,
                                               p_to_line_tag,
                                               p_to_product_id,
                                               p_to_cost_type,
                                               to_date(p_daytime,'yyyy-MM-dd"T"HH24:MI:SS'),
                                               p_user_id);

    END LOOp;
  END LOOP;

END btnPasteTransInvLiVarSet;



-----------------------------------------------------------------------------------------------------
-- Function       : btnPastePosting
-- Description    : This is used by the button in Transaction network to Paste
--                  a Copied Transaction inventory Line Product Variable to an other Transaction inventory Line Product
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CLIPBOARD
--
-- Using functions: CopyTransInvLiProd
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------
PROCEDURE btnPastePosting(p_object_id      VARCHAR2,
                          p_line_tag       VARCHAR2,
                          p_prod_stream_id VARCHAR2,
                          p_product_id     VARCHAR2,
                          p_cost_type      VARCHAR2,
                          p_daytime        VARCHAR2,
                          p_user_id        VARCHAR2) IS
  cursor saved is
    SELECT *
      FROM REVN_CLIPBOARD
     WHERE TYPE = 'TRANS_INV_POSTING'
       AND USER_ID = p_user_id;

  CURSOR c_variables(cp_object_id      VARCHAR2,
                     cp_daytime        DATE,
                     cp_product_id     VARCHAR2,
                     cp_cost_type      varchar2,
                     cp_line_tag       VARCHAR2,
                     cp_prod_stream_id VARCHAR2,
                     cp_id             NUMBER) IS
    SELECT *
      FROM trans_inv_li_pr_cntracc cap
     WHERE cap.daytime = cp_daytime
       AND cap.product_id = cp_product_id
       AND cap.cost_type = cp_cost_type
       AND cap.line_tag = cp_line_tag
       AND cap.object_id = cp_object_id
       AND cap.prod_stream_id = cp_prod_stream_id
       AND cap.id = nvl(cp_id, cap.id)
     ORDER BY cap.sort_order;

  ln_res                     NUMBER;
  lv_product_id              VARCHAR2(32);
  lv_cost_type               VARCHAR2(32);
  lr_trans_inv_li_pr_cntracc trans_inv_li_pr_cntracc%ROWTYPE;

BEGIN

  FOR item in saved LOOP

    lv_product_id := substr(item.key4, instr(item.key4, '-') + 1,32);
    lv_cost_type  := substr(item.key4,instr(item.key4, '-',1,2) + 1);

    FOR var in c_variables(item.key1,
                           item.daytime,
                           lv_product_id,
                           lv_cost_type,
                           item.key3,
                           item.key2,
                           item.key5) LOOP


      -- Rec set to copy from
      lr_trans_inv_li_pr_cntracc := Ec_Trans_Inv_li_pr_cntracc.row_by_pk(var.object_id,
                                                                         var.daytime,
                                                                         var.line_tag,
                                                                         var.product_id,
                                                                         var.cost_type,
                                                                         var.type,
                                                                         var.account_code,
                                                                         var.prod_stream_id,
                                                                         var.source_type,
                                                                         '=');

      ln_res := CopyTransInvPosting(lr_trans_inv_li_pr_cntracc,
                                    p_object_id,
                                    p_prod_stream_id,
                                    p_line_tag,
                                    p_product_id,
                                    p_cost_type,
                                    to_date(p_daytime,
                                            'yyyy-MM-dd"T"HH24:MI:SS'),
                                    p_user_id);

    END LOOp;
  END LOOP;

END btnPastePosting;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : InsNewTransInv
-- Description    : This will create a transaction inventory based on a node if it has not already been created
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : trans_inventory, trans_inventory_version
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------

FUNCTION InsNewTransInv(p_network_id    VARCHAR2,
                        p_node_id       VARCHAR2,
                        p_object_code   VARCHAR2,
                        p_start_date    DATE,
                        p_end_date      DATE DEFAULT NULL,
                        p_user          VARCHAR2 DEFAULT NULL) return VARCHAR2 is

  lv2_default_code VARCHAR2(100);
  lv2_object_id    trans_inventory.object_id%TYPE;

BEGIN

   lv2_default_code := p_object_code||'_COPY';

   lv2_default_code := Ecdp_Object_Copy.GetCopyObjectCode('TRANS_INVENTORY',lv2_default_code);


   INSERT INTO trans_inventory ti
     (object_code,alloc_network_id,node_id, start_date, end_date, created_by)
   VALUES
     (lv2_default_code, p_network_id, p_node_id, p_start_date, p_end_date, p_user)
   RETURNING object_id INTO lv2_object_id;

   INSERT INTO trans_inventory_version (object_id,  daytime, END_DATE, created_by)
   VALUES (lv2_object_id, p_start_date, p_end_date, p_user);

    -- Set approval info on latest version record.
   UPDATE trans_inventory_version
    SET last_updated_by   = Nvl(EcDp_Context.getAppUser,User),
      last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
      approval_state    = 'N',
      rev_no            = (nvl(rev_no,0) + 1)
    WHERE object_id = lv2_object_id
    AND daytime = (SELECT MAX(daytime)
             FROM trans_inventory_version
            WHERE object_id = lv2_object_id);


    RETURN lv2_object_id;

END ;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : CopyLineProdSet
-- Description    : This will copy the product set on a transaction inventory line to a new line
--                  The variables on the products will also be recreated
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : TRANS_INV_LI_PRODUCT,Trans_Inv_Li_Pr_Var,Trans_Inv_Li_Pr_Var_Dim
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------

PROCEDURE CopyLineProdSet(p_from_trans_inv_id  VARCHAR2, -- Tran Inventory to copy
                             p_from_tag        VARCHAR2,      -- Line Tag
                             p_to_trans_inv_id VARCHAR2,
                             p_to_tag          VARCHAR2,
                             p_daytime         DATE,
                             p_new_daytime     DATE,
                             p_user_id         VARCHAR2) IS


  cursor products(cp_trans_inv_id   VARCHAR2,
                  cp_from_tag       VARCHAR2,
                  cp_daytime        VARCHAR2) is
  SELECT*
    FROM TRANS_INV_LI_PRODUCT
   WHERE object_id = cp_trans_inv_id
     AND LINE_TAG = cp_from_tag
     AND DAYTIME >= cp_daytime
     AND NVL(END_DATE,p_new_daytime+1) > p_new_daytime;


BEGIN

        IF p_to_trans_inv_id = p_from_trans_inv_id
           and p_to_tag = p_from_tag
           and p_daytime = p_new_daytime THEN

          Raise_application_error(-20001,'Can not copy to same Inventory Line');

        END IF;

        -- Loop over products
        FOR prod in products(p_from_trans_inv_id,p_from_tag,p_daytime) LOOP


          CopyTransInvLiProd(prod.object_id,
                             prod.line_tag,
                             p_to_trans_inv_id,
                             p_to_tag,
                             prod.product_id,
                             prod.cost_type,
                             p_daytime,
                             p_new_daytime,
                             p_user_id);


        END LOOP;


END;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : CopyTransInvLiProd
-- Description    : This will insert a new product on a line based on the product on another line
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : TRANS_INV_LI_PRODUCT
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------
PROCEDURE CopyTransInvLiProd(p_from_trans_inv VARCHAR2,
                             p_from_tag       VARCHAR2,
                             p_to_trans_inv   VARCHAR2,
                             p_to_tag         VARCHAR2,
                             p_product_id     VARCHAR2,
                             p_cost_type      VARCHAR2,
                             p_daytime        DATE,
                             p_new_daytime    DATE,
                             p_user_id        VARCHAR2)
IS



  CURSOR c_variables (cp_object_id VARCHAR2,
                      cp_daytime DATE,
                      cp_product_id VARCHAR2,
                      cp_cost_type VARCHAR2,
                      cp_line_tag VARCHAR2
                      ) IS
   SELECT *
     FROM trans_inv_li_pr_var
    WHERE daytime = cp_daytime
      AND product_id = cp_product_id
      AND cost_type = cp_cost_type
      AND line_tag = cp_line_tag
      AND object_id = cp_object_id
    ORDER BY var_exec_order;

      ln_exec_order           NUMBER;
      lr_trans_inv_li_product TRANS_INV_LI_PRODUCT%ROWTYPE;

BEGIN
      lr_trans_inv_li_product := Ec_Trans_Inv_Li_Product.row_by_pk(
                                 p_from_trans_inv,
                                 p_daytime,
                                 p_from_tag,
                                 p_product_id,
                                 p_cost_type,
                                 '<=');

      IF lr_trans_inv_li_product.object_id is not null THEN

         INSERT INTO TRANS_INV_LI_PRODUCT
         (OBJECT_ID
          ,ID
          ,DESCRIPTION
          ,DAYTIME
          ,LINE_TAG
          ,END_DATE
          ,NAME
          ,SEQ_NO
          ,EXEC_ORDER
          ,QUANTITY_SOURCE_METHOD
          ,VALUE_METHOD
          ,PRODUCT_ID
          ,COST_TYPE
          ,PRICE_INDEX_ID
          ,VAL_EXTRACT_TAG
          ,VAL_EXTRACT_TYPE
          ,QTY_EXTRACT_TAG
          ,QTY_EXTRACT_TYPE
          ,EXTR_VAL_NET_ZERO
          ,EXTRACT_REVRS_VAL
          ,EXTRACT_REVRS_QTY
          ,TEXT_1
          ,TEXT_2
          ,TEXT_3
          ,TEXT_4
          ,TEXT_5
          ,TEXT_6
          ,TEXT_7
          ,TEXT_8
          ,TEXT_9
          ,TEXT_10
          ,VALUE_1
          ,VALUE_2
          ,VALUE_3
          ,VALUE_4
          ,VALUE_5
          ,DATE_1
          ,DATE_2
          ,DATE_3
          ,DATE_4
          ,DATE_5
          ,REF_OBJECT_ID_1
          ,REF_OBJECT_ID_2
          ,REF_OBJECT_ID_3
          ,REF_OBJECT_ID_4
          ,REF_OBJECT_ID_5
          ,VAL_EXEC_ORDER
          ,CREATED_BY)
          VALUES
         (p_to_trans_inv
          ,ecdp_system_key.assignNextKeyValue('TRANS_INV_LI_PRODUCT')
          ,lr_trans_inv_li_product.DESCRIPTION
          ,p_new_daytime
          ,p_to_tag
          ,lr_trans_inv_li_product.END_DATE
          ,lr_trans_inv_li_product.NAME
          ,lr_trans_inv_li_product.SEQ_NO
          ,lr_trans_inv_li_product.EXEC_ORDER
          ,lr_trans_inv_li_product.QUANTITY_SOURCE_METHOD
          ,lr_trans_inv_li_product.VALUE_METHOD
          ,lr_trans_inv_li_product.PRODUCT_ID
          ,lr_trans_inv_li_product.COST_TYPE
          ,lr_trans_inv_li_product.PRICE_INDEX_ID
          ,lr_trans_inv_li_product.VAL_EXTRACT_TAG
          ,lr_trans_inv_li_product.VAL_EXTRACT_TYPE
          ,lr_trans_inv_li_product.QTY_EXTRACT_TAG
          ,lr_trans_inv_li_product.QTY_EXTRACT_TYPE
          ,lr_trans_inv_li_product.EXTR_VAL_NET_ZERO
          ,lr_trans_inv_li_product.EXTRACT_REVRS_VAL
          ,lr_trans_inv_li_product.EXTRACT_REVRS_QTY
          ,lr_trans_inv_li_product.TEXT_1
          ,lr_trans_inv_li_product.TEXT_2
          ,lr_trans_inv_li_product.TEXT_3
          ,lr_trans_inv_li_product.TEXT_4
          ,lr_trans_inv_li_product.TEXT_5
          ,lr_trans_inv_li_product.TEXT_6
          ,lr_trans_inv_li_product.TEXT_7
          ,lr_trans_inv_li_product.TEXT_8
          ,lr_trans_inv_li_product.TEXT_9
          ,lr_trans_inv_li_product.TEXT_10
          ,lr_trans_inv_li_product.VALUE_1
          ,lr_trans_inv_li_product.VALUE_2
          ,lr_trans_inv_li_product.VALUE_3
          ,lr_trans_inv_li_product.VALUE_4
          ,lr_trans_inv_li_product.VALUE_5
          ,lr_trans_inv_li_product.DATE_1
          ,lr_trans_inv_li_product.DATE_2
          ,lr_trans_inv_li_product.DATE_3
          ,lr_trans_inv_li_product.DATE_4
          ,lr_trans_inv_li_product.DATE_5
          ,lr_trans_inv_li_product.REF_OBJECT_ID_1
          ,lr_trans_inv_li_product.REF_OBJECT_ID_2
          ,lr_trans_inv_li_product.REF_OBJECT_ID_3
          ,lr_trans_inv_li_product.REF_OBJECT_ID_4
          ,lr_trans_inv_li_product.REF_OBJECT_ID_5
          ,lr_trans_inv_li_product.VAL_EXEC_ORDER
          ,p_user_id) ;
      END IF;


/*
      FOR var in c_variables(p_from_trans_inv,
                             p_daytime,
                             p_product_id,
                             p_cost_type,
                             p_from_tag
                             ) LOOP

         ln_exec_order := CopyTransInvLiPrVar(p_from_trans_inv,
                                              p_from_prod_stream_id,
                                              p_from_tag,
                                              p_product_id,
                                              p_cost_type,
                                              p_to_trans_inv,
                                              p_to_prod_stream_id,
                                              p_to_tag,
                                              p_product_id,
                                              p_cost_type,
                                              var.Config_Variable_Id,
                                              var.var_exec_order,
                                              p_daytime,
                                              p_new_daytime,
                                              p_user_id);

       END LOOP;
*/
END ;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : InsNewTransInvLineCopy
-- Description    : This will insert a new Transaction line on a Transaction inventory based on the line
--                 on another inventory
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : TRANS_INV_LINE
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------

PROCEDURE InsNewTransInvLineCopy(p_from_object_id     VARCHAR2, -- Tran Inventory to copy
                                 p_from_tag           VARCHAR2,-- Line Tag
                                 p_to_object_id       VARCHAR2,
                                 p_to_tag             VARCHAR2,
                                 p_daytime            DATE,
                                 p_new_daytime        DATE,
                                 p_user_id            VARCHAR2) IS

      lr_trans_inv_line TRANS_INV_LINE%ROWTYPE;
      ld_end_Date       DATE;
BEGIN
      lr_trans_inv_line := ec_trans_inv_line.row_by_pk(p_from_object_id,p_daytime,p_from_tag,'=');

      IF lr_trans_inv_line.END_DATE != p_new_daytime THEN

        ld_end_Date := lr_trans_inv_line.END_DATE;

      END IF;

      IF lr_trans_inv_line.object_id is not null THEN


         INSERT INTO TRANS_INV_LINE
               (OBJECT_ID,
                DESCRIPTION,
                DAYTIME,
                TAG,
                LABEL,
                END_DATE,
                NAME,
                SEQ_NO,
                EXEC_ORDER,
                VAL_EXEC_ORDER,
                TYPE,
                PRORATE_LINE,
                REBALANCE_METHOD,
                XFER_IN_TRANS_ID,
                XFER_IN_LINE,
                TRANS_DEF_DIMENSION,
                STREAM_ID,
                TEXT_1,
                TEXT_2,
                TEXT_3,
                TEXT_4,
                TEXT_5,
                TEXT_6,
                TEXT_7,
                TEXT_8,
                TEXT_9,
                TEXT_10,
                VALUE_1,
                VALUE_2,
                VALUE_3,
                VALUE_4,
                VALUE_5,
                DATE_1,
                DATE_2,
                DATE_3,
                DATE_4,
                DATE_5,
                REF_OBJECT_ID_1,
                REF_OBJECT_ID_2,
                REF_OBJECT_ID_3,
                REF_OBJECT_ID_4,
                REF_OBJECT_ID_5,
                ROUND_TRANSACTION_IND,
                CURRENT_PERIOD_ONLY_IND,
                ROUND_VALUE_IND,
                CREATED_BY)
                VALUES
                (p_to_object_id,
                lr_trans_inv_line.DESCRIPTION,
                p_new_daytime,
                p_to_TAG,
                lr_trans_inv_line.LABEL,
                ld_end_date,
                lr_trans_inv_line.NAME,
                lr_trans_inv_line.SEQ_NO,
                lr_trans_inv_line.EXEC_ORDER,
                lr_trans_inv_line.VAL_EXEC_ORDER,
                lr_trans_inv_line.TYPE,
                lr_trans_inv_line.PRORATE_LINE,
                lr_trans_inv_line.REBALANCE_METHOD,
                lr_trans_inv_line.XFER_IN_TRANS_ID,
                lr_trans_inv_line.XFER_IN_LINE,
                lr_trans_inv_line.TRANS_DEF_DIMENSION,
                lr_trans_inv_line.STREAM_ID,
                lr_trans_inv_line.TEXT_1,
                lr_trans_inv_line.TEXT_2,
                lr_trans_inv_line. TEXT_3,
                lr_trans_inv_line.TEXT_4,
                lr_trans_inv_line.TEXT_5,
                lr_trans_inv_line.TEXT_6,
                lr_trans_inv_line.TEXT_7,
                lr_trans_inv_line.TEXT_8,
                lr_trans_inv_line.TEXT_9,
                lr_trans_inv_line.TEXT_10,
                lr_trans_inv_line.VALUE_1,
                lr_trans_inv_line.VALUE_2,
                lr_trans_inv_line.VALUE_3,
                lr_trans_inv_line.VALUE_4,
                lr_trans_inv_line.VALUE_5,
                lr_trans_inv_line.DATE_1,
                lr_trans_inv_line.DATE_2,
                lr_trans_inv_line.DATE_3,
                lr_trans_inv_line.DATE_4,
                lr_trans_inv_line.DATE_5,
                lr_trans_inv_line.REF_OBJECT_ID_1,
                lr_trans_inv_line.REF_OBJECT_ID_2,
                lr_trans_inv_line.REF_OBJECT_ID_3,
                lr_trans_inv_line.REF_OBJECT_ID_4,
                lr_trans_inv_line.REF_OBJECT_ID_5,
                lr_trans_inv_line.ROUND_TRANSACTION_IND,
                lr_trans_inv_line.CURRENT_PERIOD_ONLY_IND,
                lr_trans_inv_line.ROUND_VALUE_IND,
                p_user_id);

           CopyLineProdSet(p_from_object_id, -- Tran Inventory to copy
                              p_from_tag,      -- Line Tag
                              p_to_object_id,
                              p_to_tag,
                              p_daytime,
                              p_new_daytime,
                              p_user_id);
     END IF;
END;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : InsNewTransInvCopy
-- Description    : This will create a copy of an existing transaction inventory
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : trans_inventory_version
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------


FUNCTION InsNewTransInvCopy(p_network_id  VARCHAR2,
                            p_object_id   VARCHAR2, -- to copy from
                            p_start_date  DATE, -- to copy from
                            p_code        VARCHAR2,
                            p_user        VARCHAR2,
                            p_end_date    DATE DEFAULT NULL
                            )
  return VARCHAR2 is

    lv2_object_id              VARCHAR2(32);
    ld_start_Date              DATE;
    lrec_old_trans_inv_version trans_inventory_version%ROWTYPE;
    lrec_old_trans_inv         trans_inventory%ROWTYPE;
BEGIN
     lrec_old_trans_inv         := ec_trans_inventory.row_by_pk(p_object_id);

     IF lrec_old_trans_inv.start_date > p_start_date then
       ld_start_Date := lrec_old_trans_inv.start_date;
     ELSE
       ld_start_Date := p_start_date;
     END IF;

     lrec_old_trans_inv_version := ec_trans_inventory_version.row_by_pk(p_object_id,ld_start_Date,'<=');






     lv2_object_id := InsNewTransInv(p_network_id,
                                     lrec_old_trans_inv.Node_Id,
                                     p_code,ld_start_date,
                                     p_end_date,
                                     p_user);


       UPDATE trans_inventory_version
          SET NAME= lrec_old_trans_inv_version.Name
              ,DAYTIME= p_start_date
              ,END_DATE= p_end_date
              ,SEQ_NO= lrec_old_trans_inv_version.Seq_No
              ,COST_ASSET_TYPE= lrec_old_trans_inv_version.Cost_Asset_Type
              ,DEPRECIATION= lrec_old_trans_inv_version.Depreciation
              ,SUMMARY_SETUP_ID= lrec_old_trans_inv_version.Summary_Setup_Id
              ,CAPACITY= lrec_old_trans_inv_version.Capacity
              ,LONG_TERM_BOND_RATE_ID= lrec_old_trans_inv_version.Long_Term_Bond_Rate_Id
              ,NEB_EQUITY_RATE_ID= lrec_old_trans_inv_version.Neb_Equity_Rate_Id
              ,CORPORATE_TAX_RATE_ID= lrec_old_trans_inv_version.Corporate_Tax_Rate_Id
              ,VALUATION_METHOD= lrec_old_trans_inv_version.Valuation_Method
              ,QUANTITY_DECIMALS= lrec_old_trans_inv_version.Quantity_Decimals
              ,VALUE_DECIMALS= lrec_old_trans_inv_version.Value_Decimals
              ,PARENT_TRANS_ID= lrec_old_trans_inv_version.parent_trans_id
              ,EXCL_OVERLIFT_PRICE_IND= lrec_old_trans_inv_version.Excl_Overlift_Price_Ind
              ,OVERLIFT_TO_XFER_OUT_IND= lrec_old_trans_inv_version.Overlift_To_Xfer_Out_Ind
              ,COMMENTS= lrec_old_trans_inv_version.Comments
        WHERE OBJECT_ID =  lv2_object_id;

   RETURN  lv2_object_id;
END;



--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : CopyTransInvLiPrVar
-- Description    : This will create a copy of an existing transaction inventory line variable
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : TRANS_INV_LI_PR_VAR_DIM,TRANS_INV_LI_PR_VAR
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------
FUNCTION CopyTransInvLiPrVar(p_rec            TRANS_INV_LI_PR_VAR%ROWTYPE,
                             p_object_id      VARCHAR2,
                             p_prod_Stream_id VARCHAR2,
                             p_line_tag       VARCHAR2,
                             p_product_id     VARCHAR2,
                             p_cost_type      VARCHAR2,
                             p_daytime        DATE,
                             p_user_id        VARCHAR2) RETURN NUMBER

IS

             CURSOR c_TransInvLiProdVarDim(cp_object_id           VARCHAR2,
                                           cp_line_tag            VARCHAR2,
                                           cp_product_id          VARCHAR2,
                                           cp_cost_type           VARCHAR2,
                                           cp_variable_id         VARCHAR2,
                                           cp_var_exec_order      NUMBER,
                                           cp_daytime             DATE) IS
             SELECT tilpvd.*
               FROM Trans_Inv_Li_Pr_Var_Dim tilpvd
              WHERE tilpvd.object_id = cp_object_id
                AND tilpvd.line_tag = cp_line_tag
                AND tilpvd.product_id = cp_product_id
                AND tilpvd.cost_type = cp_cost_type
                AND tilpvd.config_variable_id = cp_variable_id
                AND tilpvd.variable_exec_order = cp_var_exec_order
                AND daytime <= cp_daytime;

ln_new_exec_order      NUMBER;

BEGIN

      SELECT max(nvl(var_exec_order, 0)) + 1
        INTO ln_new_exec_order
        FROM TRANS_INV_LI_PR_VAR
       WHERE OBJECT_ID = p_object_id
         AND LINE_TAG = p_line_tag
         --AND DAYTIME = p_daytime
         AND product_id = p_product_id
         AND cost_type = p_cost_type
         ;

 IF p_rec.object_id IS NOT NULL THEN

         INSERT INTO TRANS_INV_LI_PR_VAR
              (object_id
              ,id
              ,daytime
              ,end_date
              ,name
              ,config_variable_id
              ,prod_stream_id
              ,reverse_value_ind
              ,line_tag
              ,product_id
              ,cost_type
              ,trans_def_dimension
              ,type
              ,text_1
              ,text_2
              ,text_3
              ,text_4
              ,text_5
              ,text_6
              ,text_7
              ,text_8
              ,text_9
              ,text_10
              ,value_1
              ,value_2
              ,value_3
              ,value_4
              ,value_5
              ,date_1
              ,date_2
              ,date_3
              ,date_4
              ,date_5
              ,ref_object_id_1
              ,ref_object_id_2
              ,ref_object_id_3
              ,ref_object_id_4
              ,ref_object_id_5
              ,var_exec_order
              ,net_zero_ind
              ,round_ind
              ,DISABLED_IND
              ,created_by)
              VALUES
              (p_object_id
              ,ecdp_system_key.assignNextKeyValue('TRANS_INV_LI_PR_VAR')
              ,p_daytime
              ,p_rec.end_date
              ,p_rec.name
              ,p_rec.config_variable_id
              ,p_rec.prod_stream_id
              ,p_rec.reverse_value_ind
              ,p_line_tag
              ,p_product_id
              ,p_cost_type
              ,p_rec.trans_def_dimension
              ,p_rec.type
              ,p_rec.text_1
              ,p_rec.text_2
              ,p_rec.text_3
              ,p_rec.text_4
              ,p_rec.text_5
              ,p_rec.text_6
              ,p_rec.text_7
              ,p_rec.text_8
              ,p_rec.text_9
              ,p_rec.text_10
              ,p_rec.value_1
              ,p_rec.value_2
              ,p_rec.value_3
              ,p_rec.value_4
              ,p_rec.value_5
              ,p_rec.date_1
              ,p_rec.date_2
              ,p_rec.date_3
              ,p_rec.date_4
              ,p_rec.date_5
              ,p_rec.ref_object_id_1
              ,p_rec.ref_object_id_2
              ,p_rec.ref_object_id_3
              ,p_rec.ref_object_id_4
              ,p_rec.ref_object_id_5
              ,nvl(ln_new_exec_order,1)
              ,p_rec.net_zero_ind
              ,p_rec.round_ind
              ,nvl(p_rec.disabled_ind,'N')
              ,p_user_id);

         --Refresh the parameters on the variable
         refreshparams(p_object_id,
                       p_prod_Stream_id,
                       p_rec.config_variable_id,
                       p_daytime,
                       p_rec.end_date,
                       p_product_id,
                       p_cost_type,
                       p_line_tag,
                       nvl(ln_new_exec_order,1));

          FOR tilpvp in c_TransInvLiProdVarDim(p_rec.object_id,
                                         p_rec.line_tag,
                                         p_rec.product_id,
                                         p_rec.cost_type,
                                         p_rec.config_variable_id,
                                         p_rec.var_exec_order,
                                         p_rec.daytime) LOOP

            UPDATE TRANS_INV_LI_PR_VAR_DIM tilpvd
               SET tilpvd.text                  = tilpvp.text,
                   tilpvd.trans_param_source_id = tilpvp.trans_param_source_id,
                   tilpvd.key                   = tilpvp.key
             WHERE tilpvd.object_id = p_object_id
               AND tilpvd.line_tag = p_line_tag
               AND tilpvd.product_id = p_product_id
               AND tilpvd.cost_type = p_cost_type
               AND tilpvd.Config_Variable_Id = p_rec.config_variable_id
               AND tilpvd.Variable_Exec_Order = nvl(ln_new_exec_order, 1)
               AND tilpvd.dimension = tilpvp.dimension
               AND tilpvd.daytime = p_daytime;

          END LOOP;

      END IF;

  return ln_new_exec_order;
END;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : CopyTransInvPosting
-- Description    : This will create a copy of an existing transaction inventory posting
-- Preconditions  :
-- Postconditions :
-- Using tables   : TRANS_INV_LI_PR_CNTRACC
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-----------------------------------------------------------------------------------------------------
FUNCTION CopyTransInvPosting(p_rec            trans_inv_li_pr_cntracc%ROWTYPE,
                             p_object_id      VARCHAR2,
                             p_prod_Stream_id VARCHAR2,
                             p_line_tag       VARCHAR2,
                             P_product_id     VARCHAR2,
                             p_cost_type      VARCHAR2,
                             p_daytime        DATE,
                             p_user_id        VARCHAR2) RETURN NUMBER
--</EC-DOC>
 IS



ln_id NUMBER;


BEGIN



  IF p_rec.object_id IS NOT NULL THEN

     ln_id := ecdp_system_key.assignNextNumber('TRANS_INV_LI_PR_CNTRACC');

    -- Inserting a copy of the posting
    -- Any "context values" that might be different are inserted from params
    INSERT INTO TRANS_INV_LI_PR_CNTRACC
      (OBJECT_ID,
       DAYTIME,
       LINE_TAG,
       PRODUCT_ID,
       COST_TYPE,
       ACCOUNT_CODE,
       END_DATE,
       REVERSE_VALUE_IND,
       TYPE,
       ID,
       TRANS_DEF_DIMENSION,
       PROD_STREAM_ID,
       REVERSE_QUANTITY_IND,
       ROUND_QUANTITY_IND,
       ROUND_VALUE_IND,
       DIM_1,
       DIM_2,
       SOURCE_TYPE,
       CONTRACT_TYPE,
       COUNTRY_IND,
       SORT_ORDER,
       TEXT_1,
       TEXT_2,
       TEXT_3,
       TEXT_4,
       TEXT_5,
       TEXT_6,
       TEXT_7,
       TEXT_8,
       TEXT_9,
       TEXT_10,
       VALUE_1,
       VALUE_2,
       VALUE_3,
       VALUE_4,
       VALUE_5,
       DATE_1,
       DATE_2,
       DATE_3,
       DATE_4,
       DATE_5,
       REF_OBJECT_ID_1,
       REF_OBJECT_ID_2,
       REF_OBJECT_ID_3,
       REF_OBJECT_ID_4,
       REF_OBJECT_ID_5,
       CREATED_BY)
    VALUES
      (p_object_id,
       p_daytime,
       p_line_tag,
       P_product_id,
       p_cost_type,
       p_rec.account_code,
       p_rec.end_date,
       p_rec.reverse_value_ind,
       p_rec.type,
       ln_id,
       p_rec.trans_def_dimension,
       p_prod_Stream_id,
       p_rec.reverse_quantity_ind,
       p_rec.round_quantity_ind,
       p_rec.round_value_ind,
       p_rec.dim_1,
       p_rec.dim_2,
       p_rec.source_type,
       p_rec.contract_type,
       p_rec.country_ind,
       p_rec.sort_order,
       p_rec.text_1,
       p_rec.text_2,
       p_rec.text_3,
       p_rec.text_4,
       p_rec.text_5,
       p_rec.text_6,
       p_rec.text_7,
       p_rec.text_8,
       p_rec.text_9,
       p_rec.text_10,
       p_rec.value_1,
       p_rec.value_2,
       p_rec.value_3,
       p_rec.value_4,
       p_rec.value_5,
       p_rec.date_1,
       p_rec.date_2,
       p_rec.date_3,
       p_rec.date_4,
       p_rec.date_5,
       p_rec.ref_object_id_1,
       p_rec.ref_object_id_2,
       p_rec.ref_object_id_3,
       p_rec.ref_object_id_4,
       p_rec.ref_object_id_5,
       p_user_id);

  END IF;

  return ln_id;
END CopyTransInvPosting;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : CreateTransInvLine
-- Description    : This will generate a transaction inventory line based on a stream connected to a
--                  node on a network
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CALC_COLLECTION_ELEMENT,trans_inventory_version,trans_inv_line
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------

FUNCTION CreateTransInvLine(p_tran_inventory_id VARCHAR2,
                             p_trans_node_id     VARCHAR2,
                             p_stream_id         VARCHAR2,
                             p_daytime           DATE,
                             p_log_item_no       NUMBER DEFAULT NULL
                             ) RETURN VARCHAR2
IS
   CURSOR cr_nodes(cp_alloc_network_id VARCHAR2, cp_node_id VARCHAR2) is
   SELECT ELEMENT_ID
     FROM CALC_COLLECTION_ELEMENT c
    WHERE c.object_id = cp_alloc_network_id
      and c.element_id = cp_node_id;


cursor cr_trans_inventory(cp_node_id VARCHAR2,
                          cp_object_id VARCHAR2,
                          cp_daytime  DATE) is
         SELECT ti.object_id
           FROM trans_inventory ti,
                trans_inventory ti2,
                trans_inventory_version tiv,
                trans_inventory_version tiv2
          WHERE ti2.alloc_network_id = ti.alloc_network_id
            and ti2.object_id = cp_object_id
            and ti.node_id = cp_node_id;


cursor cr_trans_inv_line(cp_trans_inv_id VARCHAR2,
                         cp_daytime      DATE,
                         cp_stream_id    VARCHAR2) is
         SELECT til.TAG
           FROM trans_inv_line til
          WHERE til.object_id = cp_trans_inv_id
            and til.stream_id = cp_stream_id
            and type = 'XFER_OUT'
            and til.daytime <= cp_daytime
            and nvl(til.end_date,cp_daytime+1) > cp_daytime ;

      lv2_return                                VARCHAR2(32);
      ln_order                                  NUMBER := 0;
      lv2_default_dimension                     VARCHAR2(32);
      lv2_dimension_item                        VARCHAR2(32);
      lv2_node_category                         VARCHAR(32);
      lv2_node_id                               VARCHAR2(32);
      lv2_type                                  VARCHAR2(32);
      lv2_label                                 VARCHAR2(32);
      lv2_product_set                           VARCHAR2(32);
      lv2_node_type                             VARCHAR2(32);
      lv2_xfer_in_trans                         VARCHAR2(32);
      lv2_xfer_in_line                          VARCHAR2(32);
      ln_xfer_in_count                          NUMBER :=0;
      ln_xfer_out_count                         NUMBER:=0;
      ln_increase_count                         NUMBER:=0;
      ln_decrease_count                         NUMBER:=0;
      ln_pool_count                             NUMBER:=0;
      ln_percentage_count                       NUMBER:=0;
      ln_gain_loss_count                        NUMBER:=0;
      lv2_object_id                             VARCHAR2(32);
      ld_start_date                            DATE;
      ld_end_date                              DATE;
      lv2_object_code                           VARCHAR2(32);
      lv2_rebalance_method                      VARCHAR2(32);
      ln_existing                               NUMBER;
      l_rec_strm_version                        STRM_VERSION%ROWTYPE;
      l_rec_trans_inv                           TRANS_INVENTORY%ROWTYPE;
      lb_error_caught                           BOOLEAN;
      lv2_stream_name                           VARCHAR2(100);
      ld_daytime                                DATE;
      no_trans                                  EXCEPTION;
  BEGIN
      lv2_return         := 'SUCCESS';
      l_rec_trans_inv    := ec_trans_inventory.row_by_pk(p_tran_inventory_id);
      lv2_object_id      := p_stream_id;
      lv2_object_code    := ec_stream.object_code(p_stream_id);
      l_rec_strm_version := ec_strm_version.row_by_pk(p_stream_id,p_daytime,'<=');
      ld_daytime         := p_daytime;


      IF l_rec_trans_inv.object_id is null then
         raise no_trans;
      END IF;

      IF p_stream_ID = 'POOL' THEN
         lv2_stream_name := 'Pool';
      ELSE
        lv2_stream_name := ec_strm_version.name(p_stream_ID,ld_daytime,'<=');
      END IF;

      IF l_rec_strm_version.Object_Id IS NULL and p_stream_id != 'POOL' THEN

        IF ec_stream.start_date(p_stream_ID) > ld_daytime AND nvl(ec_stream.end_date(p_stream_ID),ld_daytime+1) >  p_Daytime THEN
              WriteTransInvGenLog('WARNING','The Stream ' ||lv2_stream_name || ' is not valid in the date that you are attempting to generate inventories for[' || p_Daytime || ']'
                                           || ' it has an object Start Date ' || ec_stream.start_date(p_stream_ID)|| '. The line will be created with this start date.',
                                            p_tran_inventory_id,
                                            'Line Generation : ' || lv2_stream_name);
              ld_daytime := ec_stream.start_date(p_stream_ID);
              lv2_return := 'WARNING';
       ELSIF  ec_stream.end_date(p_stream_ID) <  ld_daytime THEN

              WriteTransInvGenLog('WARNING','The Stream ' ||lv2_stream_name || ' is not valid in the date that you are attempting to generate inventories for[' || p_Daytime || ']'
                                           || ' it has an object end Date ' || ec_stream.end_date(p_stream_ID)|| ' if you want to create please update the navigator to a date after this date.',
                                           p_tran_inventory_id,
                                            'Line Generation : ' || lv2_stream_name);
             lb_error_caught := true;
             lv2_return := 'ERROR';

             RAISE_APPLICATION_ERROR(-20001,'Failed Generation');

       END IF;



      END IF;

      WriteTransInvGenLog('INFO','Attempting to generate line for ' ||  lv2_stream_name , p_tran_inventory_id, 'Line Generation : ' || lv2_stream_name  );


      -- Set logging info
      IF p_log_item_no IS NOT NULL THEN
         rec_trans_inv_gen_log.log_item_no := p_log_item_no;
      ELSE
         rec_trans_inv_gen_log.log_type := 'REVN_TI_LOG';
      END IF;


     -- Handle pool info
     -- Pool records will not auto generate anything lower as they just combine all lines until that point
      IF p_stream_id = 'POOL' THEN
         l_rec_strm_version.stream_category := 'POOL';
      END IF;

      SELECT count(*) into ln_existing FROM
             trans_inv_line til
       WHERE til.object_id = p_tran_inventory_id
         and (til.stream_id in (p_stream_id) or
             (p_stream_id = 'POOL' AND TAG LIKE '%POOL%') );


      IF ln_existing > 0 THEN -- Stop if Pool

          WriteTransInvGenLog('WARNING','There is already an Line created FROM stream ' || lv2_stream_name || ' in order to get new data, DELETE the line then regenerate',p_tran_inventory_id );

      ELSE

      -- Use logic to set default order NUMBER for
      -- From:NO To:YES =              100 + 200 = 300 (increase)
      -- From:NO To:NO =               100 + 200 = 300 (unknown)
      -- From:YES To:NO =              100 + 500 = 600 (Transfer out)
      -- From:NO MATCH To:NO MATCH =   300 + 0   = 300 (unknown)
      -- From:YES To:NO MATCH =        300 + 200 = 500 (decrease)
      -- From:NO To:NO MATCH =         300 + 200 = 500 (unknown)
      -- From:NO MATCH To:YES =        100 + 0   = 100 (Transfer in)
      -- From:NO MATCH To:NO =         100 + 0   = 100 (unknown)

          CASE nvl(l_rec_strm_version.to_node_id,'x')
                 WHEN  p_trans_node_id THEN
                   ln_order := 100;
                 WHEN 'x' THEN
                   ln_order := 100;
                 ELSE
                   ln_order := 300;
          END CASE;

          CASE nvl(l_rec_strm_version.from_node_id,'x')
                 WHEN  p_trans_node_id THEN
                   ln_order := ln_order+500;
                 WHEN 'x' THEN
                   ln_order := ln_order+200;
                 ELSE
                   ln_order := ln_order+0;
          END CASE;

          -- Loop up Stream Category with TRANS_INV_LINE to see if type is given
          lv2_type := nvl(ecdp_inbound_interface.getMappingCode(
                                 l_rec_strm_version.stream_category,
                                 'TRANS_INV_LINE',
                                 ld_daytime),
                                 l_rec_strm_version.stream_category);


          WriteTransInvGenLog('INFO','For stream ' ||  lv2_stream_name  || ' the mapping code for the stream catagory is set to ' || lv2_type,p_tran_inventory_id  );



          IF lv2_type NOT IN ('INCREASE','DECREASE','XFER_IN','XFER_OUT','GAIN_LOSS','POOL') THEN

             -- Matches to node, possible transfer in or increase
             IF l_rec_strm_version.to_node_id = p_trans_node_id THEN

               FOR calc in cr_nodes( ec_trans_inventory.alloc_network_id(p_tran_inventory_id), l_rec_strm_version.from_node_id) LOOP
                   lv2_type := 'XFER_IN';
               END LOOP;

               IF lv2_type != 'XFER_IN' THEN
                 lv2_type := 'INCREASE';
               END IF;

               WriteTransInvGenLog('INFO','Stream ' || lv2_stream_name  || ' will be created as a ' || lv2_type || ' due to the location of the node in the stream configuration',p_tran_inventory_id );


             -- Matches FROM node, possible transfer out or decrease
             ELSIF l_rec_strm_version.from_node_id = p_trans_node_id THEN

               FOR calc in cr_nodes( ec_trans_inventory.alloc_network_id(p_tran_inventory_id), l_rec_strm_version.to_node_id) LOOP
                   lv2_type := 'XFER_OUT';
               END LOOP;

               IF lv2_type != 'XFER_OUT' THEN
                 lv2_type := 'DECREASE';
               END IF;

               WriteTransInvGenLog('INFO','Stream ' ||  lv2_stream_name || ' will be created as a ' || lv2_type || ' due to the location of the node in the stream configuration',p_tran_inventory_id );

             ELSE --No matching on nodes and not supported type

               lv2_type := NULL;

             END IF;


          END IF;

         -- Set start / End Date

         IF ld_daytime > l_rec_trans_inv.start_Date THEN
            ld_start_date      :=  ld_daytime;
         ELSE
            ld_start_date      :=  l_rec_trans_inv.start_Date;
         END IF;
         IF l_rec_strm_version.daytime > ld_start_date THEN
            ld_start_date      :=  l_rec_strm_version.daytime;
         END IF;
         IF l_rec_strm_version.END_DATE > l_rec_trans_inv.END_DATE THEN
            ld_end_date      :=  l_rec_trans_inv.END_DATE;
         ELSE
            ld_end_date      :=  l_rec_strm_version.END_DATE;
         END IF;


         -- Set labels
         CASE lv2_type
                 WHEN 'INCREASE' THEN
                      ln_increase_count := ln_increase_count + 1;
                      lv2_label := 'Increase ' || ln_increase_count;

                 WHEN 'DECREASE' THEN
                      ln_decrease_count := ln_decrease_count + 1;
                      lv2_label := 'Decrease ' || ln_decrease_count;

                 WHEN 'XFER_IN' THEN
                      ln_xfer_in_count := ln_xfer_in_count + 1;
                      lv2_label := 'Transfer in ' || ln_xfer_in_count;

                      -- Find the transfer in objects
                      FOR trans_inv in  cr_trans_inventory(l_rec_strm_version.from_node_id,p_tran_inventory_id,ld_daytime) loop
                         lv2_xfer_in_trans := trans_inv.object_id;
                      END LOOP;

                      FOR trans_inv_line in  cr_trans_inv_line(lv2_xfer_in_trans,ld_daytime,p_stream_id) loop
                         lv2_xfer_in_line := trans_inv_line.tag;
                      END LOOP;


                 WHEN 'XFER_OUT' THEN
                      ln_xfer_out_count := ln_xfer_out_count + 1;
                      lv2_label := 'Transfer Out ' || ln_xfer_out_count;

                 WHEN 'GAIN_LOSS' THEN
                      ln_gain_loss_count := ln_gain_loss_count + 1;
                      lv2_label := 'Gain Loss ' || ln_gain_loss_count;

                 WHEN 'POOL' THEN
                      ln_pool_count := ln_pool_count + 1;
                      lv2_label := 'Pool ' || ln_pool_count;
                      ln_order := 500;

                 WHEN 'PERCENTAGE' THEN
                      ln_percentage_count := ln_percentage_count + 1;
                      lv2_label := 'Percentage ' || ln_percentage_count;

                 ELSE
                      NULL;

          END CASE;


           -- Set the node id FROM the new Inventory Line
           IF lv2_type IN ('XFER_IN','INCREASE') THEN
             lv2_node_id := l_rec_strm_version.from_node_id;
           ELSE
             lv2_node_id := l_rec_strm_version.to_node_id;

           END IF;

           -- If no node found use the parameter
           lv2_node_id := nvl(lv2_node_id,p_trans_node_id);
           lv2_node_category := ec_node_version.node_category(lv2_node_id,ld_daytime,'<=');

           -- Lookup a product set based on the node category
           lv2_node_type := nvl(ecdp_inbound_interface.getMappingCode(lv2_node_category,'TRANS_NODE',ld_daytime),lv2_node_category);


          IF lv2_type = 'POOL' THEN

             ld_start_date  :=  ec_trans_inventory.start_date(p_tran_inventory_id);
             ld_end_date    :=    ec_trans_inventory.END_DATE(p_tran_inventory_id);
             lv2_object_code := ec_trans_inventory.object_code(p_tran_inventory_id) ||'_'|| lv2_type;
             lv2_object_id   := null;

             WriteTransInvGenLog('INFO','For Stream ' || lv2_stream_name
                || ' a pool line has now been created.',p_tran_inventory_id);


             lv2_label := 'Pool Line';
             lv2_rebalance_method := 'REMOVE';

          ELSE -- Not Pool

                IF lv2_type IN ('XFER_OUT','DECREASE') THEN
                  lv2_rebalance_method := 'FLIP';
                END IF;


          END IF;


          INSERT INTO TRANS_INV_LINE
                 (OBJECT_ID,
                 STREAM_ID,
                 DAYTIME,
                 END_DATE,
                 TAG,
                 LABEL,
                 DESCRIPTION,
                 NAME,
                 SEQ_NO,
                 EXEC_ORDER,
                 TYPE,
                 XFER_IN_TRANS_ID,
                 XFER_IN_LINE,
                 TRANS_DEF_DIMENSION,
                 REBALANCE_METHOD,
                 ROUND_VALUE_IND,
                 CREATED_BY,
                 CREATED_DATE)
          VALUES
                 (p_tran_inventory_id,
                 lv2_object_id,
                 ld_START_DATE,
                 ld_END_DATE,
                 lv2_object_code,
                 nvl(lv2_label,ec_strm_version.name(p_stream_id,p_Daytime,'<=')),
                 nvl(lv2_label,ec_strm_version.name(p_stream_id,p_Daytime,'<=')),
                 nvl(ec_strm_version.name(p_stream_id,p_Daytime,'<='),lv2_label),
                 ln_order ,
                 ln_order ,
                 lv2_type,
                 lv2_xfer_in_trans,
                 lv2_xfer_in_line,
                 lv2_dimension_item,
                 lv2_rebalance_method,
                 'Y',
                 'AUTOGEN',
                 Ecdp_Timestamp.getCurrentSysdate);

        END IF;

    IF p_log_item_no IS NULL THEN
        FinalGenLog('SUCCESS' ,p_tran_inventory_id );
    END IF;

    return lv2_return;

EXCEPTION
   WHEN no_trans THEN
     ecdp_dynsql.writetemptext('trans','in' || dbms_utility.format_call_stack);
     raise_application_error(-20001,'A transaction inventory line was attempted to be created without having an inventory created from the Node. This is not possible first generate the Inventory from the Node.' );
   WHEN OTHERS THEN
       IF lb_error_caught = false THEN

         WriteTransInvGenLog('ERROR',SUBSTR(SQLERRM, 1, 240),
                                p_tran_inventory_id,
                                'Transaction Inventory Generation');

       END IF;

       IF p_log_item_no IS NULL THEN -- Only roll back if not accessed via Transaction Inventory
           WriteTransInvGenLog('ERROR','All changes will be rolled back',
                                       p_tran_inventory_id,
                                       'Line Generation');
           FinalGenLog('ERROR' ,p_tran_inventory_id );

           Rollback;

       END IF;
       RETURN 'ERROR';

END CreateTransInvLine;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : CreateTransInvLine
-- Description    : Simply used to call Function CreateTransInvLine without needing a return value
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: CreateTransInvLine
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------


PROCEDURE CreateTransInvLine(p_tran_inventory_id VARCHAR2,
                             p_trans_node_id     VARCHAR2,
                             p_stream_id         VARCHAR2,
                             p_daytime           DATE,
                             p_log_item_no       NUMBER DEFAULT NULL
                             ) IS

    lv2_return VARCHAR2(32);
BEGIN
     lv2_return := CreateTransInvLine(p_tran_inventory_id ,
                             p_trans_node_id     ,
                             p_stream_id         ,
                             p_daytime           ,
                             p_log_item_no);
END CreateTransInvLine;
--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : CreateTransInvLines
-- Description    : Loops over the streams connected to the node and calls procedure to create line for each
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : STRM_VERSION,STREAM
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------

FUNCTION CreateTransInvLines(p_tran_inventory_id VARCHAR2,
                              p_default_method    VARCHAR DEFAULT NULL,
                              p_log_item_no       NUMBER
                              ) RETURN VARCHAR2 IS

      CURSOR cr_streams(cp_node_id VARCHAR2, lv2_pool VARCHAR2) is
      SELECT oa.from_node_id,
             oa.to_node_id ,
             oa.object_id,
             oa.name,
             o.object_code,
             stream_phase,
             stream_category,
             alloc_period,
             oa.daytime      version_daytime,
             oa.end_date     version_end_Date,
             o.end_date,
             o.start_date,
             decode(nvl(oa.from_node_id,'x'),cp_node_id, 1000,'x',300,100 )
              + decode(nvl(oa.to_node_id,'x'), cp_node_id, 0,'x',800,600) type
        FROM STRM_VERSION oa, STREAM o
       WHERE oa.object_id = o.object_id
         and (oa.from_node_id = cp_node_id  or
             oa.to_node_id = cp_node_id )
       union
              SELECT'POOL',
                     'POOL',
                     'POOL',
                     'Poll Line',
                     'Poll Line',
                     'POOL',
                     'POOL',
                     'POOL',
                     null,
                     null,
                     null,
                     null,
                     3
                FROM dual
               WHERE lv2_pool = 'Y'
            order by type,
                     version_daytime;


      lv2_trans_node_id     VARCHAR2(32);
      lv2_pool              VARCHAR2(1) := 'N';
      lv2_return            VARCHAR2(10);
BEGIN
   lv2_return := 'SUCCESS';
   lv2_trans_node_id := ec_trans_inventory.node_id(p_tran_inventory_id);

   IF p_default_method in ('LIFO','FIFO')  THEN

     lv2_pool := 'Y' ;
     WriteTransInvGenLog('INFO','Fifo/Lifo Method found so pool lines will be created. ',p_tran_inventory_id);

   END IF;

    FOR stream in cr_streams( lv2_trans_node_id,lv2_pool) LOOP

       IF ec_trans_inv_line.stream_id( p_tran_inventory_id,stream.version_daytime,stream.Object_Code,'<=') = stream.object_id THEN
         WriteTransInvGenLog('WARNING','Stream item has already been created. And will therefore be skipped. Delete the Line to be able to Regenerate ',p_tran_inventory_id );
       ELSE
          lv2_return := CreateTransInvLine(p_tran_inventory_id ,
                                           lv2_trans_node_id,
                                           stream.object_id,
                                           stream.version_daytime,
                                           p_log_item_no    );
       END IF;

    END LOOP;

    return lv2_return;

END CreateTransInvLines;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : CreateTransInv
-- Description    : Creates Inventory based on node object
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : TRANS_INVENTORY_VERSION,TRANS_INVENTORY
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------

FUNCTION CreateTransInv(p_object_id   VARCHAR2,
                         p_node        VARCHAR2,
                         p_version     DATE,
                         p_log_item_no NUMBER DEFAULT NULL) RETURN VARCHAR2 IS

      lv2_default_method VARCHAR2(32);
      ln_existing        NUMBER;
      l_node_version     node_version%rowtype;
      lv2_code           VARCHAR2(32);
      lv2_object_id      VARCHAR2(32);
      lv2_result         VARCHAR2(32);
      ld_daytime         DATE := p_version;
      lv2_return         VARCHAR2(32) := 'SUCCESS';
  BEGIN

      l_node_version := ec_node_version.row_by_pk(p_node,p_version,'<=');
      lv2_code       := ec_node.object_code(p_node);

      IF l_node_version.Object_Id IS NULL THEN

            IF ec_node.start_date(p_node) > ld_daytime AND nvl(ec_node.end_date(p_node),ld_daytime+1) >  p_version THEN
                  WriteTransInvGenLog('WARNING','The Node ' || ec_node_version.name(p_node,ec_node.start_date(p_node),'<=') || ' is not valid in the date that you are attempting to generate inventories for [' || p_version || ']'
                                                || ' it has an object Start Date ' || ec_node.start_date(p_node) || ' . The Stream will be created with this start date.',
                                                p_object_id,
                                                'Line Generation : ' || ec_node_version.name(p_node,ec_node.start_date(p_node)) );

                  ld_daytime := ec_node.start_date(p_node);
                  l_node_version := ec_node_version.row_by_pk(p_node,ld_daytime,'<=');

                  lv2_return := 'WARNING';
           ELSIF  ec_node.end_date(p_node) <  ld_daytime THEN

                  WriteTransInvGenLog('ERROR','The Node ' ||ec_node_version.name(p_node,ec_node.start_date(p_node),'<=') || ' is not valid in the date that you are attempting to generate inventories for[' || p_version || ']'
                                               || ' it has an object end Date ' || ec_node.end_date(p_node)|| ' if you want to create please update the navigator to a date after this date.',
                                               p_object_id,
                                                'Line Generation : ' || ec_node_version.name(p_node,ec_node.start_date(p_node)));
                 lv2_return := 'ERROR';

                 RAISE_APPLICATION_ERROR(-20001,'Failed Generation');

           END IF;


      END IF;

      WriteTransInvGenLog('INFO','Attempting to create Inventory for node ' || ec_node_version.name(p_node,ld_daytime,'<='),p_object_id,
      'Transaction Inventory Generation : ' || ec_node_version.name(p_node,ec_node.start_date(p_node)));

      -- Checks to see if inventory created on contract already
      SELECT count(*) into ln_existing FROM
             trans_inventory_version tiv,
             trans_inventory ti
       WHERE ti.object_id = tiv.object_id
         and ti.node_id = p_node;


      IF ln_existing > 0 THEN

        SELECT max(ti.object_id) into lv2_object_id
          FROM trans_inventory_version tiv,
               trans_inventory ti
         WHERE ti.object_id = tiv.object_id
           and ti.node_id = p_node;

          WriteTransInvGenLog('INFO','There is already an inventory connected to node ' || l_node_version.name ||
                                    ' will attempt to find new stream items on the node.',p_object_id,
                                    'Transaction Inventory Generation');


      ELSE


            -- check to see if already copy already exists to handle new code
            IF ec_trans_inventory.object_id_by_uk(lv2_code) IS NOT NULL THEN

                SELECT count(*) +1 into ln_existing
                   FROM trans_inventory
                  WHERE object_code like lv2_code || '%';

                  lv2_code := lv2_code || '_GEN' || ln_existing;

                  WHILE ec_trans_inventory.object_id_by_uk(lv2_code) IS NOT NULL LOOP

                    ln_existing := ln_existing+1;
                    lv2_code := ec_node.object_code(p_node) || '_GEN' || ln_existing;

                  END LOOP;


            END IF;

      WriteTransInvGenLog('INFO','Attempting to create Inventory for node ' || ec_node_version.name(p_node,ld_daytime,'<='),p_object_id,
      'Transaction Inventory Generation : ' || ec_node_version.name(p_node,ec_node.start_date(p_node)));


            INSERT INTO TRANS_INVENTORY
                   (OBJECT_CODE,
                   START_DATE,
                   END_DATE,
                   ALLOC_NETWORK_ID,
                   NODE_ID,
                   CREATED_BY,
                   CREATED_DATE)
            VALUES
                   (lv2_code,
                   ld_daytime,
                   ec_node.END_DATE(p_node),
                   p_object_id,
                   p_node,
                   'AUTOGEN',
                   Ecdp_Timestamp.getCurrentSysdate); --Need a way to find a value to set

            WriteTransInvGenLog('INFO','Created New Transaction Inventory for node ' ||  lv2_code,p_object_id);

            lv2_object_id := ec_trans_inventory.object_id_by_uk(lv2_code);

            lv2_default_method := 'FIFO';

            IF lv2_default_method IS NOT NULL THEN
               WriteTransInvGenLog('INFO','Created New Transaction Inventory using method ' || lv2_default_method,p_object_id );
            END IF;

            INSERT INTO TRANS_INVENTORY_VERSION
                   (OBJECT_ID,
                    DAYTIME,
                    END_DATE,
                    NAME,
                    SEQ_NO,
                    --CONTRACT_ID,
                    VALUATION_METHOD,
                    CREATED_BY,
                    CREATED_DATE)
            VALUES
                   (lv2_object_id ,
                   ld_daytime,
                   l_node_version.end_date,
                   ec_node_version.name(p_node,l_node_version.Daytime,'<='),
                   l_node_version.alloc_seq,
                   --p_contract_id,
                   lv2_default_method,
                   'AUTOGEN',
                   Ecdp_Timestamp.getCurrentSysdate);

        END IF;



    lv2_result := CreateTransInvLines(lv2_object_id,lv2_default_method,rec_trans_inv_gen_log.log_item_no);


    IF lv2_return = 'SUCCESS' THEN
      lv2_return := lv2_result;
    END IF;

    IF p_log_item_no IS NULL AND lv2_return != 'ERROR' THEN
        FinalGenLog(lv2_return ,p_object_id );
    END IF;

    RETURN lv2_return;

EXCEPTION
   WHEN OTHERS THEN
          IF SUBSTR(SQLERRM, 1, 240) IS NOT NULL THEN
             WriteTransInvGenLog('ERROR',SUBSTR(SQLERRM, 1, 240),
                                    p_object_id,
                                    'Transaction Inventory Generation');
          END IF;
           WriteTransInvGenLog('ERROR','All changes will be rolled back',
                                    p_object_id,
                                    'Transaction Inventory Generation');
           IF p_log_item_no IS NULL THEN
              FinalGenLog('ERROR' ,p_object_id );
              Rollback;
           END IF;

           return 'ERROR';

END CreateTransInv;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : CreateTransInv
-- Description    : Simply used to call Function CreateTransInv without needing a return value
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: CreateTransInv
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------


PROCEDURE CreateTransInv(p_object_id   VARCHAR2,
                         p_node        VARCHAR2,
                         p_version     DATE,
                         p_log_item_no NUMBER DEFAULT NULL) IS

lv2_return VARCHAR2(32);
BEGIN
  lv2_return := CreateTransInv(p_object_id   ,
                         p_node        ,
                         p_version     ,
                         p_log_item_no) ;
END CreateTransInv;


-----------------------------------------------------------------------------------------------------
-- Function       : CreateFromAllocNetwork
-- Description    : This will create trans inventory and transaction inventory lines for all the nodes
--                  and stream items in the given network
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CALC_COLLECTION_ELEMENT, CALC_COLLECTION_VERSION,CALC_COLLECTION,NODE_VERSION,NODE
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------

PROCEDURE CreateFromAllocNetwork(p_object_id    VARCHAR2,
                                 p_daytime      DATE
                                 )

--</EC-DOC>
IS
            CURSOR cr_nodes is
            SELECT no.object_code code ,
                   CALC_COLLECTION_ELEMENT.ELEMENT_ID,
                   noa.daytime version_daytime,
                   noa.end_date version_end_date,
                   no.start_date start_date,
                   no.END_DATE end_Date,
                   ec_node_version.alloc_seq(ELEMENT_ID,noa.daytime,'<=') seq_no
              FROM CALC_COLLECTION_ELEMENT,
                   CALC_COLLECTION_VERSION oa,
                   CALC_COLLECTION o,
                   NODE_VERSION noa,
                   NODE no
             WHERE noa.object_id = no.object_id
               AND CALC_COLLECTION_ELEMENT.ELEMENT_ID = no.object_id
               AND CALC_COLLECTION_ELEMENT.object_id = oa.object_id
               AND oa.object_id = o.object_id
               AND CALC_COLLECTION_ELEMENT.daytime >= oa.daytime
               AND CALC_COLLECTION_ELEMENT.daytime < nvl(oa.end_date,CALC_COLLECTION_ELEMENT.daytime + 1)
               AND o.class_name='ALLOC_NETWORK'
               AND CALC_COLLECTION_ELEMENT.OBJECT_ID = p_object_id
          ORDER BY ec_node_version.alloc_seq(ELEMENT_ID,oa.daytime,'<=') ,oa.daytime, oa.end_date;

   ld_daytime      DATE;
   lv2_log_item_no NUMBER;
   lv2_return      VARCHAR2(32);
   lv2_final       VARCHAR2(32) := 'SUCCESS';
   lb_error_caught BOOLEAN := FALSE;

BEGIN

    WriteTransInvGenLog('INFO','Attempting to generate Network for ' ||  ecdp_objects.GetObjName(p_object_ID,p_Daytime) ,p_object_id, 'Network Generation ' || ecdp_objects.GetObjName(p_object_ID,p_Daytime)  );
    lv2_log_item_no := rec_trans_inv_gen_log.log_item_no;

    FOR node in cr_nodes LOOP

        IF node.version_daytime > p_daytime THEN
          ld_daytime:= node.version_daytime;
        ELSE
          ld_daytime := p_daytime;
        END IF;
        lv2_return :=    CreateTransInv(p_object_id,
                                         node.element_id,
                                         ld_daytime,
                                         lv2_log_item_no );
        IF lv2_return = 'ERROR' THEN
          lb_error_caught := true;
          raise_application_error(-20001,'FAILED');

        ELSIF lv2_return != 'SUCCESS' THEN
          lv2_final := lv2_return;
        END IF;

    END LOOP;


    FinalGenLog(lv2_final ,p_object_id );

EXCEPTION
  WHEN OTHERS THEN
           IF lb_error_caught = false THEN
             WriteTransInvGenLog('ERROR',SUBSTR(SQLERRM, 1, 240),
                                    p_object_id,
                                    'Transaction Inventory Generation');
           END IF;
           WriteTransInvGenLog('ERROR','All changes will be rolled back',
                                    p_object_id,
                                    'Network Generation Generation');

           FinalGenLog('ERROR' ,p_object_id );

           Rollback;



END CreateFromAllocNetwork;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : createProductChild
-- Description    : This simply allows running the function createProductChild as a procedure
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: createProductChild
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------


PROCEDURE createProductChild(p_object_id              VARCHAR2,
                             p_daytime                DATE,
                             p_end_date               DATE,
                             p_line_tag               VARCHAR2,
                             p_quantity_src_attribute VARCHAR2,
                             p_quantity_source_method VARCHAR2,
                             p_product_id             VARCHAR2,
                             p_cost_type              VARCHAR2)
                         is
              lv2_found_variable   VARCHAR2(32);
BEGIN
  lv2_found_variable := createProductChild(p_object_id ,
                                           p_daytime  ,
                                           p_end_date ,
                                           p_line_tag ,
                                           p_quantity_src_attribute ,
                                           p_quantity_source_method ,
                                           p_product_id,
                                           p_cost_type ) ;

END   createProductChild;
/*

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : createProducts
-- Description    : This will autogenerate transaction inventory products based on the product set on the
--                  transaction inventory line when autogenerating with buttons
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : trans_prod_set_item,trans_prod_set_item_vrsn,trans_inv_li_product
--
-- Using functions: createProductChild
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------


PROCEDURE createProducts(p_object_id VARCHAR2,
                         p_daytime VARCHAR2,
                         p_end_date VARCHAR2,
                         p_tag VARCHAR2,
                         p_TRANS_PROD_SET_id VARCHAR2,
                         p_type VARCHAR2)
  is
       cursor cr_Products(cp_object_id VARCHAR2,
                          cp_start_date DATE) is
       SELECT tpsiv.*
         FROM trans_prod_set_item_vrsn tpsiv,
              trans_prod_set_item tpsi
        WHERE tpsi.trans_prod_set_id = cp_object_id
          and tpsiv.object_id = tpsi.object_id
          and daytime <= cp_start_date
          AND nvl(tpsi.end_date,Ecdp_Timestamp.getCurrentSysdate+1)> nvl(p_end_Date,Ecdp_Timestamp.getCurrentSysdate+0.5)
        order by tpsiv.exec_order;

       lv2_valuation_method VARCHAR2(32);
       lv2_found_variable   VARCHAR2(32);
       lv2_quantity_method  VARCHAR2(32);
       ld_daytime           DATE;
BEGIN


    -- Loop over the products in the set
    FOR product in cr_Products(p_TRANS_PROD_SET_id,p_daytime) LOOP

       -- Get an appropriate date
       IF product.daytime >= p_daytime THEN
         ld_daytime := product.daytime;
       ELSE
         ld_daytime := p_daytime;
       END IF;

       -- Use the given type to choose assume the validation methods
       IF p_type NOT in ('GAIN_LOSS','XFER_IN','INCREASE') THEN

          -- Will try to find a variable for the quantity method
          lv2_valuation_method := NVL(product.value_method,'PRORATED_QTY');

       ELSIF p_type = 'XFER_IN' THEN

          lv2_valuation_method := 'XFER_IN';
          lv2_quantity_method := 'XFER_IN';

       ELSIF p_type = 'GAIN_LOSS' THEN

          lv2_valuation_method := 'PRORATED_QTY';
          lv2_quantity_method := 'VARIABLE';

       ELSE

          lv2_valuation_method := 'VARIABLE';
          lv2_quantity_method := 'VARIABLE';

       END IF;

      IF product.object_type = 'FIN_COST_OBJECT' THEN
        lv2_quantity_method := 'NA_COST_OBJECT';
      END IF;

      WriteTransInvGenLog('INFO','For product ' || ec_trans_prod_set_item_vrsn.name(product.object_ID,product.daytime,'<=')
         || ' valuation menthod is ' ||  lv2_valuation_method  ||
         ' Quantity method is ' || lv2_quantity_method,ec_trans_inventory_version.contract_id(p_object_id,p_daytime,'<=') );

       insert into
           trans_inv_li_product
           (OBJECT_ID,
            DESCRIPTION,
            DAYTIME,
            LINE_TAG,
            END_DATE,
            NAME,
            SEQ_NO,
            EXEC_ORDER,
            VAL_EXEC_ORDER,
            QUANTITY_SOURCE_METHOD,
            VALUE_METHOD,
            TRANS_PROD_SET_ITEM_ID,
            CREATED_BY,
            CREATED_DATE)
       values
           (p_object_id,
            product.name,
            ld_daytime,
            p_tag,
            p_End_Date,
            product.Name,
            product.Seq_No,
            product.Exec_Order,
            product.Exec_Order,
            lv2_quantity_method,
            lv2_valuation_method ,
            product.object_id,
            'AUTOGEN',
            Ecdp_Timestamp.getCurrentSysdate);

       -- Increases are often based on variables so see if a variable can be found
       IF p_type in ('GAIN_LOSS','INCREASE','XFER_OUT') THEN


             WriteTransInvGenLog('INFO','Product ' || ec_trans_prod_set_item_vrsn.name(product.object_ID,ld_daytime,'<=')
             || ' was found to be gain/loss or increase will attempt to add variables ',ec_trans_inventory_version.contract_id(p_object_id,p_daytime,'<=') );

              lv2_found_variable :=  createProductChild(p_object_id ,
                                                        ld_daytime  ,
                                                        product.end_date,
                                                        p_tag ,
                                                        product.quantity_src_attribute,
                                                        product.quantity_source_method,
                                                        product.object_id);

            -- If variable found it will set the product to a variable
             IF  lv2_quantity_method IS NULL AND lv2_found_variable IS NOT NULL THEN

               UPDATE trans_inv_li_product
                  SET QUANTITY_SOURCE_METHOD = 'VARIABLE'
                WHERE OBJECT_ID = p_object_id
                  AND TRANS_PROD_SET_ITEM_ID = product.object_id
                  AND ld_daytime =daytime
                  AND p_tag = LINE_TAG;

             END IF;

       END IF;

   END LOOP;

END createProducts;

*/

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : createVarDim
-- Description    : This will create Dimensions for the Transaction Variables based on the calculation Variables
--                  read dimension values. If the variable does not have read variables it will look up the dimensions
--                  FROM the calculation variables main table (internal local variables)
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : config_variable_param,config_variable_param_vrsn,calc_var_key_read_mapping
--
-- Using functions: CreateLocalVariableParams
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------


Procedure createVarDim(p_object_id          VARCHAR2,
                       p_daytime            DATE,
                       p_object_start_date  DATE,
                       p_object_end_date    DATE,
                       p_end_date           DATE,
                       p_calc_context_id    VARCHAR2,
                       p_calc_var_signature VARCHAR2)
IS
         CURSOR cr_dimensions(p_object_id VARCHAR2,
                              cp_calc_var_signature VARCHAR2) is
          SELECT CALC_VAR_SIGNATURE,
                 CLS_NAME,
                 SQL_SYNTAX,
                 DIM_NO
            FROM calc_var_key_read_mapping
           WHERE object_id = p_object_id
             and calc_var_signature = cp_calc_var_signature
             and DIM_NO IS NOT NULL
        order by DIM_NO;
          lv2_found boolean := false;
BEGIN

  -- Remove any dimension that previously existed
  DELETE
    FROM CONFIG_VARIABLE_PARAM
   WHERE config_variable_id = p_object_id;



  -- Loop over dimension on the calculation variable
  FOR dim in cr_dimensions(ec_config_variable_version.calc_context_id(p_object_id,p_daytime,'<=') ,
                          p_calc_var_signature) LOOP

      lv2_found := true;

      -- Insert Paramenter based on parameters
  insert into config_variable_param
             (object_code,
              start_date,
              end_date,
              config_variable_id,
              created_by,
              created_date)
       VALUES(ec_config_variable.object_code(p_object_id) || '_' || dim.dim_no,
              p_object_start_date,
              p_object_end_date,
              p_object_id,
              'AUTOGEN',
              Ecdp_Timestamp.getCurrentSysdate);

      INSERT INTO config_variable_param_vrsn
                 (object_id,
                  daytime,
                  end_date,
                  name,
                  dimension,
                  created_by,
                  created_date)
           VALUES (ec_config_variable_param.object_id_by_uk(ec_config_variable.object_code(p_object_id) || '_' || dim.dim_no),
                  p_daytime,
                  p_end_date,
                  dim.SQL_SYNTAX,
                  dim.dim_no,
                  'AUTOGEN',
                  Ecdp_Timestamp.getCurrentSysdate);

  END LOOP;

  -- If the variable was not a read variable then need to get details FROM each dimension
  -- and populate that way
  IF lv2_found  = false THEN

     CreateLocalVariableParams(p_object_id ,
                               p_daytime   ,
                               p_object_start_date ,
                               p_object_end_date   ,
                               p_end_date ,
                               p_calc_context_id ,
                               p_calc_var_signature );




  END IF;

END  createVarDim;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : CreateLocalVariableParams
-- Description    : This will create Variable parameters based on the dimension types for the calculation variable
--                  This is used when the variable is populated with values inside the calculation
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : calc_variable,calc_object_type,config_variable_param
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------


PROCEDURE  CreateLocalVariableParams(p_object_id          VARCHAR2,
                                     p_daytime            DATE,
                                     p_object_start_date  DATE,
                                     p_object_end_date    DATE,
                                     p_end_date           DATE,
                                     p_calc_context_id    VARCHAR2,
                                     p_calc_var_signature VARCHAR2) IS

    CURSOR Dimensions (cp_object_id VARCHAR2,cp_calc_var_signature  VARCHAR2) is
    SELECT 1 dim_no,
           cot.object_type_code,
           cot.calc_obj_type_category,
           cot.data_type,
           cot.label_override
      FROM calc_variable cv,
           calc_object_type cot
     WHERE cv.object_id = cot.object_id
       and  cv.dim1_object_type_code = cot.object_type_code
       and cv.object_id = cp_object_id
       and cv.calc_var_signature = cp_calc_var_signature
     UNION
    SELECT 2 dim,
           cot.object_type_code,
           cot.calc_obj_type_category,
           cot.data_type,
           cot.label_override
      FROM calc_variable cv,
           calc_object_type cot
     WHERE cv.object_id = cot.object_id
       and cv.dim2_object_type_code = cot.object_type_code
       and cv.object_id = cp_object_id
       and cv.calc_var_signature = cp_calc_var_signature
     UNION
    SELECT 3 dim,
           cot.object_type_code,
           cot.calc_obj_type_category,
           cot.data_type,
           cot.label_override
      FROM calc_variable cv,
           calc_object_type cot
     WHERE cv.object_id = cot.object_id
       and cv.dim3_object_type_code = cot.object_type_code
       and cv.object_id = cp_object_id
       and cv.calc_var_signature = cp_calc_var_signature
     UNION
    SELECT 4 dim,
           cot.object_type_code,
           cot.calc_obj_type_category,
           cot.data_type,
           cot.label_override
      FROM calc_variable cv,
           calc_object_type cot
     WHERE cv.object_id = cot.object_id
       and cv.dim4_object_type_code = cot.object_type_code
       and cv.object_id = cp_object_id
       and cv.calc_var_signature = cp_calc_var_signature
     UNION
    SELECT 5 dim,
           cot.object_type_code,
           cot.calc_obj_type_category,
           cot.data_type,
           cot.label_override
      FROM calc_variable cv,
           calc_object_type cot
     WHERE cv.object_id = cot.object_id
       and cv.dim5_object_type_code = cot.object_type_code
       and cv.object_id = cp_object_id
       and cv.calc_var_signature = cp_calc_var_signature    ;
  lv2_type VARCHAR2(32);
 lv2_label VARCHAR2(32);

BEGIN

    FOR param in Dimensions(p_calc_context_id,p_calc_var_signature) LOOP


        lv2_type:=NULL;

        CASE param.Calc_Obj_Type_Category
          WHEN 'DB' THEN -- Database object
            lv2_label := EcDp_ClassMeta_Cnfg.getLabel(param.object_type_code);
            CASE param.object_type_code
              WHEN 'CONTRACT' THEN
                   lv2_type:='CURRENT_CONTRACT';
              WHEN 'TRANS_INVENTORY' THEN
                   lv2_type:='CURRENT_TRANS';
              WHEN 'PRODUCT' THEN
                   lv2_type:='CURRENT_PRODUCT';
              WHEN 'TRANS_QTY_SOURCE' THEN
                   lv2_type:='SPEC_OBJECT';
              ELSE
                   lv2_type:=NULL;
             END CASE;
          WHEN 'SIMPLE' THEN --None database object
            CASE param.object_type_code
              WHEN 'BALANCE_TAG' THEN
                lv2_type:='CURRENT_DIMENSION';
              WHEN 'LINE_TAG' THEN
                lv2_type:='CURRENT_LINE';
              WHEN 'TRANS_PROD_SET_ITEM' THEN
                lv2_type:='CURRENT_PRODUCT';
              WHEN 'PROD_STREAM_INV' THEN
                lv2_type:='CURRENT_PROD_STREAM_INV';
              WHEN 'DIMENSION_KEY' THEN
                lv2_type:='CURRENT_DIMENSION';

              ELSE
                lv2_type:=NULL;
              END CASE;
          WHEN 'PREDEFINED'  THEN -- Date
            IF param.data_type = 'DATE' THEN
              lv2_type:='CURRENT_MONTH';
            END IF;
          ELSE
               lv2_type:=NULL;
          END CASE;

         -- Insert Paramenter based on parameters
             insert into config_variable_param
                 (
                  object_code,
                  start_date,
                  end_date,
                  config_variable_id,
                  created_by,
                  created_date)
               VALUES
                   (
                   ec_config_variable.object_code(p_object_id) || '_' || param.dim_no,
                   p_object_start_date,
                   p_object_end_date,
                   p_object_id,
                   'AUTOGEN',
                   Ecdp_Timestamp.getCurrentSysdate
                   );



              insert into config_variable_param_vrsn
                     (object_id,
                      daytime,
                      end_date,
                      name,
                      dimension,
                      type,
                      created_by,
                      created_date)
               VALUES
                   (
                   ec_config_variable_param.object_id_by_uk(ec_config_variable.object_code(p_object_id) || '_' || param.dim_no),
                   p_daytime,
                   p_end_date,
                   nvl(param.label_override,lv2_label),
                   param.dim_no,
                   lv2_type,
                     'AUTOGEN',
                     SYSDATE
                   );



        END LOOP;

END   CreateLocalVariableParams;



--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : createProductChild
-- Description    : This will create Variable based on the dimension types for the calculation variable
--                  This is used when the variable is populated with values inside the calculation
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : calc_variable,calc_object_type,config_variable_param
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------


FUNCTION createProductChild(p_object_id              VARCHAR2,
                            p_daytime                DATE,
                            p_end_date               DATE,
                            p_line_tag               VARCHAR2,
                            p_quantity_src_attribute VARCHAR2,
                            p_quantity_source_method VARCHAR2,
                            p_product_id             VARCHAR2,
                            p_cost_type              VARCHAR2) RETURN VARCHAR2 is

    cursor cr_ExistingVariables(cp_object_id VARCHAR2,
                             cp_line_tag VARCHAR2,
                             cp_product_id  VARCHAR2,
                             cp_cost_type  VARCHAR2,
                             cp_type                    VARCHAR2,
                             cp_daytime                 DATE) is
           SELECT*
             FROM TRANS_INV_LI_PR_VAR tilpv
            WHERE object_id = cp_object_id
              AND line_tag = cp_line_tag
              AND type = cp_type
              AND tilpv.product_id = cp_product_id
              and tilpv.cost_type = cp_cost_type
              AND daytime = cp_daytime;


    lb_item_found         BOOLEAN := FALSE;
    lv2_found_variable    VARCHAR2(32);
    lv2_value             VARCHAR2(32);
    lv_exec_order         NUMBER;

BEGIN
/*    --Check if variable exists if so do nothing
      IF p_quantity_source_method IN ('STREAM','TANK','VARIABLE') THEN

          FOR variable in cr_ExistingVariables (p_object_id,
                           p_line_tag ,
                           p_product_id,
                           p_cost_type,
                           'QUANTITY',
                           p_daytime) LOOP


               lb_item_found := TRUE;
               EXIT;
           END LOOP;

      END IF;

      IF lb_item_found = FALSE THEN -- If variable has not been created

            IF p_quantity_src_attribute is not null and
               p_PRODUCT_ID is not null
               AND p_cost_type is not null
               AND p_quantity_source_method IS NOT NULL THEN --Generate when product set and source info given

                 -- Will see if it can find a matching variable
                 lv2_found_variable := FindAppropriateVariable(p_product_id,p_cost_type,
                                                          p_quantity_source_method ,
                                                          p_daytime  ,
                                                          p_end_date ,
                                                          p_quantity_src_attribute,
                                                          p_line_tag,
                                                          p_object_id
                                                          );


                      -- If appropriate variable found insert into variable table
                 IF lv2_found_variable IS NOT NULL THEN

                         SELECT nvl(max(var_exec_order),0)+1
                           into lv_exec_order
                           FROM TRANS_INV_LI_PR_VAR
                          WHERE LINE_TAG = p_line_tag
                            and p_daytime = DAYTIME
                            and p_object_id = OBJECT_ID
                            and p_product_id = product_id
                            and p_cost_type = cost_type;


                         WriteTransInvGenLog('INFO','For product ' || ec_product_version.name(p_product_id,p_daytime,'<=') || ' and cost ' || p_cost_type
                         || ' found variable ' || ec_config_variable_version.name(lv2_found_variable,p_daytime,'<='),p_object_id );


                         -- Create Variable and params
                         INSERT INTO TRANS_INV_LI_PR_VAR tilpv
                               (OBJECT_ID,
                               LINE_TAG,
                               NAME,
                               TYPE,
                               PRODUCT_ID,
                               COST_TYPE,
                               DAYTIME,
                               END_DATE,
                               CONFIG_VARIABLE_ID,
                               var_exec_order,
                               CREATED_BY,
                               CREATED_DATE)
                          VALUES
                               (p_object_id,
                                p_line_tag,
                                ec_config_variable_version.name(lv2_found_variable,p_daytime,'<='),
                                'QUANTITY',
                                p_product_id,
                                p_cost_type,
                                p_daytime,
                                p_end_date,
                                lv2_found_variable,
                                lv_exec_order,
                               'AUTOGEN',
                               Ecdp_Timestamp.getCurrentSysdate);

                          -- update the parameters on the variable
                          refreshparams(p_object_id,lv2_found_variable,p_daytime,p_end_date,p_product_id,p_cost_type,p_line_tag,1);

                          FOR dimension in gc_dimensions(lv2_found_variable,p_daytime,p_end_date)  LOOP

                                 -- Check to see if it is a specific object or a genaric code
                                 lv2_value := findparamvalue(lv2_found_variable,
                                                             dimension.Dimension,
                                                             p_object_id,
                                                             p_line_tag,
                                                             dimension.type,
                                                             p_daytime
                                                             );
                                -- If a generic code then just set the key value
                                IF ecdp_objects.getobjcode(lv2_value) is null THEN
                                     -- Set values for generation
                                      update TRANS_INV_LI_PR_VAR_DIM
                                        set last_updated_date = daytime,
                                            last_updated_by = 'AUTOGEN',
                                            KEY = lv2_value
                                      WHERE OBJECT_ID = p_object_id
                                        and LINE_TAG = p_line_tag
                                        and product_id = p_product_id
                                        and cost_type = p_cost_type
                                        and DAYTIME = p_daytime
                                        and CONFIG_VARIABLE_ID = lv2_found_variable
                                        and CONFIG_VARIABLE_PARAM_ID = dimension.Object_Id;

                                      WriteTransInvGenLog('INFO','Updated parameter for variable dimension ' || dimension.name || ' with value ' || lv2_value,p_object_id);

                                ELSE
                                    -- If is a specific object then do setting to say specific object and set source id
                                    update TRANS_INV_LI_PR_VAR_DIM
                                            set last_updated_date = daytime,
                                                last_updated_by = 'AUTOGEN',
                                                TRANS_PARAM_SOURCE_id = lv2_value,
                                                TRANS_INV_LI_PR_VAR_DIM.Key = 'SPEC_OBJECT'
                                          WHERE OBJECT_ID = p_object_id
                                            and LINE_TAG = p_line_tag
                                            and product_id = p_product_id
                                            and cost_type = p_cost_type
                                            and DAYTIME = p_daytime
                                            and CONFIG_VARIABLE_ID = lv2_found_variable
                                            and CONFIG_VARIABLE_PARAM_ID = dimension.Object_Id;


                                    WriteTransInvGenLog('INFO','Updated parameter for variable dimension ' || dimension.name || ' with object ' || ecdp_objects.getobjcode(lv2_value),p_object_id);


                                END IF;

                          END LOOP;
                 ELSE

                         WriteTransInvGenLog('INFO','For product ' || ec_product_version.name(p_producT_id,p_daytime,'<=') || ' and cost ' || p_cost_type
                         || ' attempted to find appropriate variable and found none.',p_object_id );

                 END IF;

             END IF;

          ELSE

               WriteTransInvGenLog('INFO','Product ' || ec_product_version.name(p_producT_id,p_daytime,'<=') || ' and cost ' || p_cost_type
               || ' already has a variable added so no action will be done.',p_object_id );

          END IF;*/

          RETURN lv2_found_variable;


END      createProductChild;



--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : FindParamValue
-- Description    : This will look to see if the parameter value can be determined by the parameter object type
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : calc_variable,calc_object_type,config_variable_param
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------


FUNCTION FindParamValue (p_variable_id    VARCHAR2,
                         p_dimension      NUMBER,
                         p_object_id      VARCHAR2, --Transaction inventory object
                         p_line_tag       VARCHAR2,
                         p_Type           VARCHAR2,
                         p_daytime        DATE
                         ) return VARCHAR2

is
        lv2_current_dim VARCHAR2(32);
        lv2_context_id  VARCHAR2(32);
        lv2_object_cat   VARCHAR2(32);
        lv2_found_dimension VARCHAR2(32);
        lv2_type           VARCHAR2(32);
BEGIN

                lv2_context_id  := ec_config_variable_version.calc_context_id(p_variable_id,p_daytime,'<=');
                lv2_current_dim := GetParameterObject(p_dimension,p_variable_id,p_Daytime);
                lv2_object_cat  := ec_calc_object_type.calc_obj_type_category(lv2_context_id,lv2_current_dim);

                IF lv2_object_cat = 'DB' THEN
                   lv2_type := 'OBJECT' ;
                ELSE
                   lv2_type :=ec_calc_object_type.data_type(lv2_context_id,lv2_current_dim);
                END IF;



                CASE lv2_type
                   WHEN 'OBJECT' THEN
                       CASE lv2_current_dim
                        WHEN 'STREAM' THEN -- If the type is a stream see if line has a given stream
                            lv2_found_dimension := ec_trans_inv_line.stream_id(p_object_id,p_daytime,p_line_tag,'<=');
                        WHEN 'TANK' THEN   -- Can't choose a tank object FROM the network set
                            lv2_found_dimension := NULL;
                         WHEN 'PRICE_INDEX' THEN -- Can't mull a price object
                           lv2_found_dimension := NULL;
                         WHEN 'TRANS_INVENTORY' THEN
                           lv2_found_dimension := 'CURRENT_TRANS';
                         WHEN 'CONTRACT' THEN
                           lv2_found_dimension := 'CURRENT_CONTRACT';
                         WHEN 'TRANS_DIM_SET_ITEM' THEN
                           lv2_found_dimension := 'LEVEL_DIMENSION';
                         WHEN 'PRODUCT' THEN
                           lv2_found_dimension := 'LEVEL_PRODUCT';
                         ELSE
                            lv2_found_dimension := 'MISSING';
                      END CASE;


                   WHEN 'DATE' THEN
                       lv2_found_dimension := p_Type;
                       IF lv2_found_dimension IS NULL THEN
                         IF lv2_current_dim = 'DAY' THEN --if day type use the first day of the month
                            lv2_found_dimension := 'FIRST_DAY_CURR_MTH';
                         ELSE
                             lv2_found_dimension := 'CURRENT_MONTH';
                         END IF;
                       END IF;
                    WHEN 'NUMBER' THEN
                        lv2_found_dimension := p_Type;
                    ELSE
                      NULL;
                END CASE;

      RETURN lv2_found_dimension;
 END  FindParamValue;



--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : FindAppropriateVariable
-- Description    : This will see if a variable can be found for the product using the transaction inventory products
--                  setup (Class name and attribute and on the same calculation context)
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CONFIG_VARIABLE,CONFIG_VARIABLE_VERSION,calc_var_read_mapping
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------

FUNCTION FindAppropriateVariable(p_product_id           VARCHAR2,
                                 p_cost_type            VARCHAR2,
                                 p_class_name               VARCHAR2,
                                 p_daytime                  DATE,
                                 p_end_Date                 DATE,
                                 p_quantity_src_attribute   VARCHAR2,
                                 p_line_tag                 VARCHAR2,
                                 p_object_id                VARCHAR2)
     RETURN VARCHAR2 IS
     -- Look up based on the calculation variables read values checking the calculation context
     cursor cr_predefined_variables(cp_class_name     VARCHAR2,
                                    cp_attribute_name VARCHAR2,
                                    cp_object_id      VARCHAR2,
                                    cp_daytime        DATE,
                                    cp_end_Date       DATE
                                    )  IS
          SELECT
                 o.OBJECT_ID AS OBJECT_ID,
                 o.OBJECT_CODE AS CODE,
                 oa.NAME AS NAME,
                 o.START_DATE AS OBJECT_START_DATE,
                 o.END_DATE AS OBJECT_END_DATE,
                 oa.DAYTIME AS DAYTIME,
                 oa.END_DATE AS END_DATE,
                 o.DESCRIPTION AS DESCRIPTION,
                 oa.CALC_CONTEXT_ID AS CALC_CONTEXT_ID,
                 EC_CALC_CONTEXT.object_code(oa.CALC_CONTEXT_ID) AS CALC_CONTEXT_CODE,
                 oa.CALC_VAR_SIGNATURE AS CALC_VAR_SIGNATURE
            FROM CONFIG_VARIABLE_VERSION oa,
                 CONFIG_VARIABLE o,
                 CALC_VARIABLE cv,
                 calc_var_read_mapping cvrm,
                 TRANS_INVENTORY ti,
                 ALLOC_NETWORK_JOB_CONN anjc,
                 CALCULATION c
           WHERE ti.object_id = cp_object_id
             AND ti.alloc_network_id = anjc.alloc_network_id
             AND c.calc_context_id = cv.object_id
             AND c.object_id = anjc.job_id
             AND oa.object_id = o.object_id
             AND cv.calc_var_signature = oa.calc_var_signature
             AND oa.calc_context_id = cv.object_id
             AND cvrm.Object_Id = cv.object_id
             AND cv.calc_var_signature = cvrm.calc_var_signature
             AND CLS_NAME = cp_class_name
             AND sql_syntax = cp_attribute_name
             AND oa.daytime <= cp_daytime
             AND nvl(oa.end_date, nvl(cp_end_date,Ecdp_Timestamp.getCurrentSysdate)) >= nvl(cp_end_date,Ecdp_Timestamp.getCurrentSysdate);

     -- Checks to see if variable has already been created on the trans inventory line
     cursor cr_check_existing(cp_object_id VARCHAR2,
                              cp_line_tag VARCHAR2,
                              cp_product_id VARCHAR2,
                              cp_cost_type  VARCHAR2,
                              cp_variable_id VARCHAR2
                                    )  IS
            SELECT count(*) count
              FROM trans_inv_li_pr_var tilpv
             WHERE tilpv.product_id = cp_product_id
               and tilpv.cost_type = cp_cost_type
               and tilpv.config_variable_id = cp_variable_id
               and tilpv.line_tag = cp_line_tag
               and tilpv.object_id = cp_object_id;

   lv2_found_variable VARCHAR2(32);
   ln_found_count      NUMBER;
BEGIN

       -- Find all read variables matching the class and attribute indicated.
       FOR variable in cr_predefined_variables(p_class_name,
                                               p_quantity_src_attribute,
                                               p_object_id,
                                               p_daytime,
                                               p_end_Date) LOOP

           -- Check variable is not already on the
           for verify in cr_check_existing(p_object_id ,
                              p_line_tag ,
                              p_product_id ,
                              p_cost_type,
                              variable.object_id) LOOP
             ln_found_count := verify.count;
           END loop;


           IF ln_found_count  = 0 THEN
               lv2_found_variable:=variable.object_id;
               EXIT;
           END IF;

       END LOOP;

   RETURN lv2_found_variable                                   ;

END FindAppropriateVariable;



--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : UpdateTILineStartDate
-- Description    : This will update start date for all children for the transaction inventory Line
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : TRANS_INV_LINE,TRANS_INV_MSG
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------

PROCEDURE UpdateTILineStartDate(p_object_id VARCHAR2,
                         p_line_tag         VARCHAR2,
                         p_new_daytime      DATE,
                         p_old_daytime      DATE) IS


  CURSOR children_li_pr (cp_object_id VARCHAR2,
                        cp_line_tag   VARCHAR2,
                        cp_daytime    DATE) IS
         SELECT*
           FROM TRANS_INV_LI_PRODUCT
         WHERE object_id = cp_object_id
            AND line_tag = cp_line_tag
            AND daytime = cp_daytime;

  BEGIN


       FOR prod in children_li_pr(p_object_id,
                                  p_line_tag,
                                  p_old_daytime) LOOP

               UPDATE TRANS_INV_LI_PRODUCT
                  SET daytime = p_new_daytime
                WHERE daytime = p_old_daytime
                  AND line_tag = p_line_tag;

               UpdateTILiVarStartDate(p_object_id ,
                         p_line_tag    ,
                         prod.product_id ,
                         prod.cost_type,
                         p_new_daytime      ,
                         p_old_daytime
               );

       END LOOP;








END UpdateTILineStartDate;



--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : UpdateTILineTag
-- Description    : This will update tags on all children for a line
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : TRANS_INV_LI_PRODUCT
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------

PROCEDURE UpdateTILiProd(p_object_id                      VARCHAR2,
                         p_line_tag                       VARCHAR2,
                         p_daytime                        DATE,
                         p_product_id                 VARCHAR2,
                         p_cost_type                  VARCHAR2,
                         p_new_product_id     VARCHAR2,
                         p_new_cost_type      varchar2) IS


  CURSOR children_li_pr_var (cp_object_id         VARCHAR2,
                        cp_line_tag               VARCHAR2,
                        cp_product_id                 VARCHAR2,
                        cp_cost_type                  VARCHAR2,
                        cp_daytime                DATE) IS
         SELECT*
           FROM TRANS_INV_LI_PR_VAR
         WHERE object_id = cp_object_id
            AND product_id = cp_product_id
            and cost_type = cp_cost_type
            AND line_tag = cp_line_tag
            AND daytime = cp_daytime;

  CURSOR children_li_pr_var_dim (cp_object_id         VARCHAR2,
                        cp_line_tag                   VARCHAR2,
                        cp_product_id                 VARCHAR2,
                        cp_cost_type                  VARCHAR2,
                        cp_variable_id                VARCHAR2,
                        cp_var_exec_order             NUMBER,
                        cp_daytime                    DATE) IS
         SELECT*
           FROM TRANS_INV_LI_PR_VAR_DIM
         WHERE object_id = cp_object_id
            AND product_id = cp_product_id
            and cost_type = cp_cost_type
            AND line_tag = cp_line_tag
            AND VARIABLE_EXEC_ORDER = cp_var_exec_order
            AND CONFIG_VARIABLE_ID = cp_variable_id
            AND daytime = cp_daytime;
BEGIN

              FOR var in children_li_pr_var(p_object_id,
                                            p_line_tag,
                                            p_product_id,
                                            p_cost_type,
                                            p_daytime) LOOP

               UPDATE TRANS_INV_LI_PR_VAR
                  SET product_id = p_product_id,
                      cost_type = p_cost_type
                WHERE daytime = p_daytime
                  AND product_id = p_product_id
                  and cost_type = p_cost_type
                  AND var_exec_order= var.var_exec_order
                  AND config_variable_id = var.config_variable_id
                  AND line_tag = p_line_tag;

                      FOR dim in children_li_pr_var_dim(p_object_id,
                                                        p_line_tag,
                                                        p_product_id,
                                                        p_cost_type,
                                                        var.config_variable_id,
                                                        var.var_exec_order,
                                                        p_daytime) LOOP


                           UPDATE TRANS_INV_LI_PR_VAR_DIM
                              SET product_id = p_new_product_id,
                                  cost_type = p_new_cost_type
                            WHERE daytime = p_daytime
                              AND product_id = p_product_id
                              and cost_type = p_cost_type
                              AND variable_exec_order= var.var_exec_order
                              AND config_variable_id = var.config_variable_id
                              AND dimension = dim.dimension
                              AND line_tag = p_line_tag;

                      END LOOP;

              END LOOP;



END UpdateTILiProd;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : UpdateTILineTag
-- Description    : This will update tags on all children for a line
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : TRANS_INV_LI_PRODUCT
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------

PROCEDURE UpdateTILineTag(p_object_id VARCHAR2,
                         p_line_tag         VARCHAR2,
                         p_new_line_tag     VARCHAR2,
                         p_daytime          DATE) IS


  CURSOR children_li_pr (cp_object_id VARCHAR2,
                        cp_line_tag   VARCHAR2,
                        cp_daytime    DATE) IS
         SELECT*
           FROM TRANS_INV_LI_PRODUCT
         WHERE object_id = cp_object_id
            AND line_tag = cp_line_tag
            AND daytime = cp_daytime;

  BEGIN


       FOR prod in children_li_pr(p_object_id,
                                  p_line_tag,
                                  p_daytime) LOOP

               UPDATE TRANS_INV_LI_PRODUCT
                  SET line_tag = p_new_line_tag
                WHERE daytime = p_daytime
                  AND line_tag = p_line_tag;

               UpdateTILiVarTag(p_object_id ,
                                     p_line_tag    ,
                                     p_new_line_tag,
                                     prod.product_id ,
                                     prod.cost_type,
                                     p_daytime
               );

       END LOOP;








END UpdateTILineTag;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : UpdateTILiVarStartDate
-- Description    : This will update start date for all children for the transaction inventory Variable
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : TRANS_INV_LINE,TRANS_INV_MSG
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------

PROCEDURE UpdateTILiVarStartDate(p_object_id VARCHAR2,
                         p_line_tag          VARCHAR2,
                         p_product_id        VARCHAR2,
                         p_cost_type         VARCHAR2,
                         p_new_daytime      DATE,
                         p_old_daytime      DATE) IS


  CURSOR children_li_pr_var (cp_object_id         VARCHAR2,
                        cp_line_tag               VARCHAR2,
                        cp_Product_id             VARCHAR2,
                        cp_cost_type              VARCHAR2,
                        cp_daytime                DATE) IS
         SELECT*
           FROM TRANS_INV_LI_PR_VAR
         WHERE object_id = cp_object_id
            AND product_id = cp_product_id
            and cost_type = cp_cost_type
            AND line_tag = cp_line_tag
            AND daytime = cp_daytime;

  CURSOR children_li_pr_var_dim (cp_object_id         VARCHAR2,
                        cp_line_tag                   VARCHAR2,
                        cp_Product_id             VARCHAR2,
                        cp_cost_type              VARCHAR2,
                        cp_variable_id                VARCHAR2,
                        cp_var_exec_order             NUMBER,
                        cp_daytime                    DATE) IS
         SELECT*
           FROM TRANS_INV_LI_PR_VAR_DIM
         WHERE object_id = cp_object_id
            AND product_id = cp_product_id
            and cost_type = cp_cost_type
            AND line_tag = cp_line_tag
            AND VARIABLE_EXEC_ORDER = cp_var_exec_order
            AND CONFIG_VARIABLE_ID = cp_variable_id
            AND daytime = cp_daytime;
BEGIN

              FOR var in children_li_pr_var(p_object_id,
                                            p_line_tag,
                                            p_product_id,
                                            p_cost_type,
                                            p_old_daytime) LOOP

               UPDATE TRANS_INV_LI_PR_VAR
                  SET daytime = p_new_daytime
                WHERE daytime = p_old_daytime
                  AND product_id = p_product_id
                  and cost_type = p_cost_type
                  AND var_exec_order= var.var_exec_order
                  AND config_variable_id = var.config_variable_id
                  AND line_tag = p_line_tag;

                      FOR dim in children_li_pr_var_dim(p_object_id,
                                                        p_line_tag,
                                                        p_product_id,
                                                        p_cost_type,
                                                        var.config_variable_id,
                                                        var.var_exec_order,
                                                        p_old_daytime) LOOP


                           UPDATE TRANS_INV_LI_PR_VAR_DIM
                              SET daytime = p_new_daytime
                            WHERE daytime = p_old_daytime
                              AND product_id = p_product_id
                              and cost_type = p_cost_type
                              AND variable_exec_order= var.var_exec_order
                              AND config_variable_id = var.config_variable_id
                              AND dimension = dim.dimension
                              AND line_tag = p_line_tag;

                      END LOOP;

              END LOOP;



END UpdateTILiVarStartDate;



--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : UpdateTILiVarTag
-- Description    : This will update tags on all children FROM variable down
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : TRANS_INV_LI_PR_VAR,TRANS_INV_LI_PR_VAR_DIM
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------

PROCEDURE UpdateTILiVarTag(p_object_id              VARCHAR2,
                           p_line_tag               VARCHAR2,
                           p_new_line_tag           VARCHAR2,
                           p_product_id VARCHAR2,
                           p_cost_type VARCHAR2,
                           p_daytime                DATE) IS


  CURSOR children_li_pr_var (cp_object_id         VARCHAR2,
                        cp_line_tag               VARCHAR2,
                        cp_product_id VARCHAR2,
                        cp_cost_type VARCHAR2,
                        cp_daytime                DATE) IS
         SELECT*
           FROM TRANS_INV_LI_PR_VAR
         WHERE object_id = cp_object_id
            AND product_id = cp_product_id
            AND cost_type = cp_cost_type
            AND line_tag = cp_line_tag
            AND daytime = cp_daytime;

  CURSOR children_li_pr_var_dim (cp_object_id         VARCHAR2,
                        cp_line_tag                   VARCHAR2,
                        cp_product_id VARCHAR2,
                        cp_cost_type VARCHAR2,
                        cp_variable_id                VARCHAR2,
                        cp_var_exec_order             NUMBER,
                        cp_daytime                    DATE) IS
         SELECT*
           FROM TRANS_INV_LI_PR_VAR_DIM
         WHERE object_id = cp_object_id
            AND product_id = cp_product_id
            AND cost_type = cp_cost_type
            AND line_tag = cp_line_tag
            AND VARIABLE_EXEC_ORDER = cp_var_exec_order
            AND CONFIG_VARIABLE_ID = cp_variable_id
            AND daytime = cp_daytime;
BEGIN

              FOR var in children_li_pr_var(p_object_id,
                                            p_line_tag,
                                            p_product_id,
                                            p_cost_type,
                                            p_daytime) LOOP

               UPDATE TRANS_INV_LI_PR_VAR
                  SET line_tag = p_new_line_tag
                WHERE daytime = p_daytime
                  AND product_id = p_product_id
                  AND cost_type = p_cost_type
                  AND var_exec_order= var.var_exec_order
                  AND config_variable_id = var.config_variable_id
                  AND line_tag = p_line_tag;

                      FOR dim in children_li_pr_var_dim(p_object_id,
                                                        p_line_tag,
                                                        p_product_id,
                                                        p_cost_type,
                                                        var.config_variable_id,
                                                        var.var_exec_order,
                                                        p_daytime) LOOP


                           UPDATE TRANS_INV_LI_PR_VAR_DIM
                              SET line_tag = p_new_line_tag
                            WHERE daytime = p_daytime
                              AND product_id = p_product_id
                              AND cost_type = p_cost_type
                              AND variable_exec_order= var.var_exec_order
                              AND config_variable_id = var.config_variable_id
                              AND dimension = dim.dimension
                              AND line_tag = p_line_tag;

                      END LOOP;

              END LOOP;



END UpdateTILiVarTag;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : UpdateTIPrEndDate
-- Description    : This will update all children of the transaction inventory Line with the new end date
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : TRANS_INV_LINE,TRANS_INV_MSG
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------

PROCEDURE UpdateTILineEndDate(p_object_id         VARCHAR2,
                         p_line_tag               VARCHAR2,
                         p_new_daytime            DATE,
                         p_new_end_date           DATE) IS

   CURSOR c_prod is
        SELECT*
          FROM TRANS_INV_LI_PRODUCT
         WHERE object_id = p_object_id
           AND line_tag = p_line_tag
           AND daytime = p_new_daytime;
BEGIN

   FOR prod in c_prod LOOP

      UPDATE TRANS_INV_LI_PRODUCT current_rec
         SET END_DATE = p_new_end_date
       WHERE object_id = p_object_id
         AND line_tag = p_line_tag
         AND prod.product_id = product_id
         AND prod.cost_type = cost_type
         AND daytime = p_new_daytime;


         UpdateTILiVarEndDate(p_object_id ,
                              p_line_tag  ,
                              prod.product_id,
                              prod.cost_type      ,
                              p_new_daytime ,
                              p_new_end_date ) ;
    END LOOP;

END UpdateTILineEndDate;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : UpdateTIVarEndDate
-- Description    : This will update all children of the transaction inventory version with the new end date
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : TRANS_INV_LINE,TRANS_INV_MSG
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------

PROCEDURE UpdateTILiVarEndDate(p_object_id VARCHAR2,
                               p_line_tag  VARCHAR2,
                               p_producT_id VARCHAR2,
                               p_cost_type VARCHAR2,
                               p_new_daytime DATE,
                               p_new_end_date DATE) IS
BEGIN

  UPDATE TRANS_INV_LI_PR_VAR current_rec
     SET END_DATE = p_new_end_date
   WHERE object_id = p_object_id
     AND p_product_id=product_id
     AND cost_type = p_cost_type
     AND line_tag = p_line_tag
     AND daytime = p_new_daytime;

  UPDATE TRANS_INV_LI_PR_VAR_DIM current_rec
     SET END_DATE = p_new_end_date
   WHERE object_id = p_object_id
     AND p_product_id=product_id
     AND cost_type = p_cost_type
     AND line_tag = p_line_tag
     AND daytime = p_new_daytime;

END UpdateTILiVarEndDate;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : UpdateTIEndDate
-- Description    : This will update all children of the transaction inventory version with the new end date
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : TRANS_INV_LINE,TRANS_INV_MSG
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------

PROCEDURE UpdateTIEndDate(p_object_id VARCHAR2,
                         p_new_daytime DATE,
                         p_new_end_date DATE) IS

     cursor c_lines is
        SELECT tag,
               daytime
          FROM trans_inv_line
         WHERE object_id = p_object_id
           AND daytime = ec_trans_inv_line.prev_daytime(p_object_id,p_new_end_date,trans_inv_line.tag)
           AND nvl(end_date,to_date('01011811','ddmmyyyy')) != nvl(p_new_end_date,to_date('01011811','ddmmyyyy'));


     cursor c_msg is
        SELECT message_code,
               daytime
          FROM trans_inv_msg
         WHERE object_id = p_object_id
           AND daytime = ec_trans_inv_msg.prev_daytime(p_object_id,p_new_end_date,trans_inv_msg.message_code,trans_inv_msg.product_id,trans_inv_msg.cost_type,trans_inv_msg.prod_stream_id)
           AND nvl(end_date,to_date('01011811','ddmmyyyy')) != nvl(p_new_end_date,to_date('01011811','ddmmyyyy'));
BEGIN

  FOR line in c_lines LOOP
        UPDATE TRANS_INV_LINE current_rec
           SET END_DATE = p_new_end_date
         WHERE object_id = p_object_id
           AND daytime =line.daytime
           AND TAG = line.tag;

     UpdateTILineEndDate(p_object_id,
                       line.tag,
                       p_new_daytime ,
                       p_new_end_date );

  END LOOP;


  FOR msg in c_msg LOOP
        UPDATE TRANS_INV_MSG current_rec
           SET END_DATE = p_new_end_date
         WHERE object_id = p_object_id
           AND daytime =msg.daytime
           AND message_code = msg.message_code;

     UpdateTILiVarEndDate(p_object_id ,
                        msg.message_code,
                        'MESSAGE',
                        'NA',
                        p_new_daytime ,
                        p_new_end_date );
  END LOOP;

END UpdateTIEndDate;



--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : refreshparams
-- Description    : This will DELETE all the variable params and add them back (used when variable changed)
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : TRANS_INV_LI_PR_VAR_DIM
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------

PROCEDURE refreshparams(p_object_id                   VARCHAR2,
                        p_prod_stream_id              VARCHAR2,
                         p_config_variable_id          VARCHAR2,
                         p_daytime                    DATE,
                         p_end_date                   DATE,
                         p_product_id                 VARCHAR2,
                         p_cost_type                  varchar2,
                         p_line_tag                   VARCHAR2,
                         p_exec_order                 VARCHAR2) IS



  BEGIN

   DELETE
     FROM TRANS_INV_LI_PR_VAR_DIM tilpvd
    WHERE p_object_id = object_id
      AND line_tag = p_line_tag
      and CONFIG_VARIABLE_ID = p_config_variable_id
      AND p_product_id = product_id
      and cost_type = p_cost_type
      AND daytime = p_daytime
      AND prod_stream_id = p_prod_Stream_id
      AND variable_exec_order = p_exec_order;

  -- Loop all dimensions
  FOR dimension in gc_dimensions(p_config_variable_id,p_daytime,p_end_date)  LOOP

        INSERT INTO TRANS_INV_LI_PR_VAR_DIM tilpvd
                    (object_id,
                     LINE_TAG,
                     producT_id,
                     cost_type,
                     DAYTIME,
                     END_DATE,
                     CONFIG_VARIABLE_ID,
                     DIMENSION,
                     CONFIG_VARIABLE_PARAM_ID,
                     KEY,
                     TRANS_PARAM_SOURCE_ID,
                     VARIABLE_EXEC_ORDER,
                     PROD_STREAM_ID,
                     CREATED_BY,
                     CREATED_DATE)
              VALUES
                     (p_object_id,
                      p_line_tag,
                      p_product_id,
                      p_cost_type,
                      p_daytime,
                      p_end_date,
                      p_config_variable_id,
                      dimension.dimension,
                      dimension.object_id,
                      dimension.key,
                      dimension.src_object_id,
                      p_exec_order,
                      p_prod_stream_id,
                       'AUTOGEN',
                       Ecdp_Timestamp.getCurrentSysdate
                      );

  END LOOP;

END Refreshparams;



--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : FindVariableParamType
-- Description    : This will return the data type for a parameter based on the trans variable parameter object
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: GetParameterObject
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      : used by classes trans_inv_pr_var_dim and trans_msg_var_dim
--
-----------------------------------------------------------------------------------------------------

FUNCTION FindVariableParamType(p_object_id  VARCHAR2,
                               p_daytime    DATE)


RETURN VARCHAR2 IS
       lv2_type                VARCHAR2(32);
       lv2_current_dim         VARCHAR2(32);
       lv2_object_cat          VARCHAR2(32);
       lv2_context_id          VARCHAR2(32);
       lv2_variable_id         VARCHAR2(32);
       lv2_dimension           NUMBER;
BEGIN
      lv2_variable_id := ec_config_variable_param.config_variable_id( p_object_id );
      lv2_dimension   := EC_CONFIG_VARIABLE_PARAM_VRSN.dimension(p_object_id,p_daytime,'<=');


      lv2_context_id  := ec_config_variable_version.calc_context_id(lv2_variable_id,p_daytime,'<=');
      lv2_current_dim := GetParameterObject(lv2_dimension,lv2_variable_id, p_daytime);


      lv2_object_cat :=ec_calc_object_type.calc_obj_type_category(lv2_context_id,lv2_current_dim);
      IF lv2_object_cat = 'DB' OR lv2_current_dim='TRANS_PROD_SET_ITEM' OR lv2_current_dim='PROD_STREAM_INV' THEN
         lv2_type := 'OBJECT' ;
      ELSIF lv2_object_cat = 'SIMPLE' THEN
         lv2_type := 'TEXT' ;
      ELSE
         lv2_type :=ec_calc_object_type.data_type(lv2_context_id,lv2_current_dim);
      END IF;

RETURN lv2_type;

END FindVariableParamType;

-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
--*** Logging                                                                                   ***--
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------



--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : WriteTransInvGenLog
-- Description    : Writes log when Generating Transaction Inventory Config based on an Allocation Network
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : revn_log, revn_log_item
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------


PROCEDURE WriteTransInvGenLog(p_log_level        VARCHAR2, -- SUMMARY, INFO, WARNING or ERROR
                              p_log_text         VARCHAR2,
                              p_contract_id      VARCHAR2,
                              p_run_description  VARCHAR2 DEFAULT NULL
                              )
IS

  PRAGMA AUTONOMOUS_TRANSACTION;

  lv2_sys_log_level ctrl_system_attribute.attribute_text%type;
  lb_write_detail   BOOLEAN := TRUE;
  ln_log_item_no    NUMBER;
BEGIN

  IF rec_trans_inv_gen_log.log_type is null THEN
    rec_trans_inv_gen_log.log_type := 'REVN_TI_LOG';
  END IF;


  IF rec_trans_inv_gen_log.log_item_no IS NULL OR rec_trans_inv_gen_log.log_item_no = -1 THEN

     -- Create the log item
     INSERT INTO revn_log
       (category, daytime, status,contract_id,description)
     VALUES
       (rec_trans_inv_gen_log.log_type,
        Ecdp_Timestamp.getCurrentSysdate,
        'RUNNING',
        p_contract_id,
        p_run_description)
     RETURNING log_no INTO ln_log_item_no;

     rec_trans_inv_gen_log.log_item_no := ln_log_item_no;

  END IF;

  -- Check settings for logging: DEBUG (shows all), INFO (only Info and Summary), SUMMARY (only Summary)
  IF p_log_level NOT IN ('ERROR','WARNING') THEN -- Errors and warnings are always written to the log.
    lv2_sys_log_level := NVL(ec_ctrl_system_attribute.attribute_text(Ecdp_Timestamp.getCurrentSysdate, 'REVN_TI_LOG_LEVEL', '<='),'DEBUG');
    IF lv2_sys_log_level = 'INFO' AND p_log_level NOT IN ('DEBUG','INFO') THEN
      lb_write_detail := FALSE;
    END IF;
  END IF;

  IF lb_write_detail THEN
    INSERT INTO revn_log_item
      (category,
       log_no,
       text_3,
       daytime,
       description,
       status,
       created_by)
    VALUES
      (rec_trans_inv_gen_log.log_type,
       rec_trans_inv_gen_log.log_item_no,
       rec_trans_inv_gen_log.trans_inv_id,
       Ecdp_Timestamp.getCurrentSysdate,
       p_log_text,
       p_log_level,
       rec_trans_inv_gen_log.created_by);
  else
    raise_application_error(-20001,lv2_sys_log_level||'-'|| p_log_level);
  END IF;

  COMMIT;

END WriteTransInvGenLog;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : WriteTransInvGenLog
-- Description    : Updates the status of the log
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : revn_log
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      : used by function FinalGenLog
--
-----
-----------------------------------------------------------------------------------------------------

PROCEDURE SetGenStatus(
  p_set_status VARCHAR2
  )
IS

  PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

  -- Do the update of the log
  UPDATE revn_log SET
    STATUS = DECODE(p_set_status, NULL, STATUS, p_set_status)
  WHERE log_no = rec_trans_inv_gen_log.log_item_no;

  COMMIT;

END SetGenStatus;



--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : FinalGenLog
-- Description    : Writes the final status when a Process has completed creates record for final comment as well
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : revn_log
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      : used by function FinalGenLog
--
-----
-----------------------------------------------------------------------------------------------------


PROCEDURE FinalGenLog(p_final_status VARCHAR2,p_contract_id VARCHAR2)
IS
  lv2_current_status VARCHAR2(32);
  lv2_use_status VARCHAR2(32);

  CURSOR c_Log IS
    SELECT STATUS
    FROM revn_log
    WHERE log_no = rec_trans_inv_gen_log.log_item_no;

BEGIN

  FOR rsLog IN c_Log LOOP
      lv2_current_status := rsLog.status;
  END LOOP;

  IF p_final_status = 'ERROR' THEN
     lv2_use_status := p_final_status;
  ELSIF p_final_status = 'WARNING' THEN
     IF lv2_current_status != 'ERROR' OR lv2_current_status IS NULL THEN
        lv2_use_status := p_final_status;
     ELSE
        lv2_use_status := lv2_current_status;
     END IF;
  ELSIF p_final_status = 'SUCCESS' THEN
     IF (lv2_current_status != 'ERROR' AND lv2_current_status != 'WARNING') OR lv2_current_status IS NULL THEN
        lv2_use_status := p_final_status;
     ELSE
        lv2_use_status := lv2_current_status;
     END IF;
  END IF;

  WriteTransInvGenLog('INFO','Document processing FINISHED with status [' || p_final_status || ']. Overall status is [' || lv2_use_status || ']' || CHR(10) || CHR(13), p_contract_id);

  SetGenStatus(lv2_use_status);
  rec_trans_inv_gen_log.log_item_no := -1;

END FinalGenLog;

-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
--*** Functions used for Transaction Inventory Screens                                          ***--
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetParameterObject
-- Description    : This allows getting the object type for a specific dimension in a calculation variable
--                  based on a transaction variable
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : calc_variable,calc_object_type,config_variable_param
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      : is used by classes TRANS_INV_LI_PR_VAR_DIM and TRANS_INV_MSG_VAR_DIM to display
--                  the product type in the screen
--
-----------------------------------------------------------------------------------------------------


FUNCTION GetParameterObject(p_dimension VARCHAR2,p_variable_id VARCHAR2, p_daytime date) RETURN VARCHAR2
  IS
  lv2_current_dim VARCHAR2(32);
  lv2_context_id  VARCHAR2(32);
  lv2_signature VARCHAR2(400);
 BEGIN

       lv2_context_id := ec_config_variable_version.calc_context_id(p_variable_id,p_daytime,'<=');
       lv2_signature := ec_config_variable_version.calc_var_signature(p_variable_id,p_daytime,'<=');


                CASE p_dimension
                  WHEN 1 THEN
                       lv2_current_dim := ec_calc_variable.dim1_object_type_code(lv2_context_id,lv2_signature);
                  WHEN 2 THEN
                       lv2_current_dim := ec_calc_variable.dim2_object_type_code(lv2_context_id,lv2_signature);
                  WHEN 3 THEN
                       lv2_current_dim := ec_calc_variable.dim3_object_type_code(lv2_context_id,lv2_signature);
                  WHEN 4 THEN
                       lv2_current_dim := ec_calc_variable.dim4_object_type_code(lv2_context_id,lv2_signature);
                  WHEN 5 THEN
                       lv2_current_dim := ec_calc_variable.dim5_object_type_code(lv2_context_id,lv2_signature);
                END CASE;

    RETURN lv2_current_dim;
END ;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetNextInventory
-- Description    : This is used to find the next valid inventory when in the overview screen and pressing
--                  the next inventory button
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : trans_inventory_version,trans_inventory
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------


FUNCTION GetNextInventory(p_group_id VARCHAR2,
                          p_object_id VARCHAR2,
                          p_trans_inv_id VARCHAR2,
                          p_daytime   DATE)  return VARCHAR2 IS
cursor next_inv is
 SELECT tiv2.*
       FROM trans_inventory_version tiv1,
            trans_inventory_version tiv2,
            trans_inventory ti1,
            trans_inventory ti2,
            trans_inv_prod_stream tip1,
            trans_inv_prod_stream tip2,
            calc_collection_element cce1,
            calc_collection_element cce2
      WHERE tiv1.object_id = ti1.object_id
        AND tiv2.object_id = ti2.object_id
        AND tiv1.object_id = p_trans_inv_id
        AND tip2.daytime <= p_daytime
        AND nvl(tip2.end_Date,p_daytime+1) >  p_daytime
        AND tip1.object_id = cce1.element_id
        and tip1.inventory_id =tiv1.object_id
        and tip2.inventory_id =tiv2.object_id
        and tip1.object_id = p_object_id
        AND cce2.element_id = tip2.object_id
        --AND cce1.element_id != cce2.element_id
        AND cce1.object_id = cce2.object_id
        AND cce1.daytime <= p_daytime
        AND nvl(cce1.end_Date,p_daytime+1) >  p_daytime
        AND cce2.daytime <= p_daytime
        AND nvl(cce2.end_Date,p_daytime+1) >  p_daytime
        and cce1.object_id = p_group_id
        AND ((tip1.exec_order < tip2.exec_order
        AND cce1.sort_order = cce2.sort_order)
        OR cce1.sort_order < cce2.sort_order)
    ORDER BY cce2.sort_order, tip2.exec_order;
 lv2_return VARCHAR2(32);

BEGIN

    for inv in next_inv loop
      lv2_return := inv.object_id;
      exit;
    end loop;



RETURN lv2_return;
END GetNextInventory;



--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetPreviousInventory
-- Description    : This is used to find the previous valid inventory when in the overview screen and pressing
--                  the previous inventory button
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : trans_inventory_version,trans_inventory
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------

FUNCTION GetPreviousInventory(p_group_id varchar2,
                              p_object_id VARCHAR2,
                          p_trans_inv_id VARCHAR2,
                          p_daytime   DATE)
 return VARCHAR2 IS
     cursor prev_inv is
     SELECT tiv2.*
       FROM trans_inventory_version tiv1,
            trans_inventory_version tiv2,
            trans_inventory ti1,
            trans_inventory ti2,
            trans_inv_prod_stream tip1,
            trans_inv_prod_stream tip2,
            calc_collection_element cce1,
            calc_collection_element cce2
      WHERE tiv1.object_id = ti1.object_id
        AND tiv2.object_id = ti2.object_id
        AND tip2.daytime <= p_daytime
        AND tiv1.object_id = p_trans_inv_id
        AND nvl(tip2.end_Date,p_daytime+1) >  p_daytime
        AND tip1.object_id = cce1.element_id
        and tip1.inventory_id =tiv1.object_id
        and tip2.inventory_id =tiv2.object_id
        and tip1.object_id = p_object_id
        AND cce2.element_id = tip2.object_id
         -- AND cce1.element_id != cce2.element_id
        AND cce1.object_id = cce2.object_id
        AND cce1.daytime <= p_daytime
        AND nvl(cce1.end_Date,p_daytime+1) >  p_daytime
        AND cce2.daytime <= p_daytime
        AND nvl(cce2.end_Date,p_daytime+1) >  p_daytime
        and cce1.object_id = p_group_id
        AND ((tip1.exec_order > tip2.exec_order
        AND cce1.sort_order = cce2.sort_order)
        OR cce1.sort_order > cce2.sort_order)
        ORDER BY cce2.sort_order desc,  tip2.exec_order DESC;

 lv2_return VARCHAR2(32);
BEGIN
    for inv in prev_inv loop
      lv2_return := inv.object_id;
      exit;
    end loop;

RETURN lv2_return;
END GetPreviousInventory;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetSourceId
-- Description    : Used when inserting into trans_inv_li_pr_var_dim a source param to make sure correct class is pulled
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : trans_inventory_version,trans_inventory
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------


FUNCTION  GetSourceId(p_object_id    VARCHAR2,
                      p_daytime      DATE,
                      p_dimention   NUMBER,
                      p_source_param VARCHAR2) RETURN VARCHAR2
IS
      lv2_return     VARCHAR2(32);
      lv2_class_name VARCHAR2(32);
BEGIN
      lv2_class_name := GetParameterObject(p_dimention ,p_object_id , p_daytime ) ;
      lv2_return := ecdp_objects.GetObjIDFromCode(lv2_class_name,p_source_param);
      return lv2_return;

END GetSourceId;


-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
--*** Functions for allowing skipping items in the Transaction Inventory calculation at levels  ***--
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------
-- Function       : SkipInventory
-- Description    : This is used by the calculation section to see if the inventory should be skipped when matching
--                  Transaction Inventory and Month
-- Behaviour      : Evaluation down inside user exit, this is pulled by class V_TRANS_INV_SKIP_INV
--
-----------------------------------------------------------------------------------------------------

FUNCTION SkipInventory(p_contract_id VARCHAR2,
                p_object_id VARCHAR2,
                       p_daytime DATE)  RETURN VARCHAR IS
BEGIN
  RETURN ue_trans_inventory.SkipInventory(p_contract_id ,p_object_id,p_daytime);
END SkipInventory;

-----------------------------------------------------------------------------------------------------
-- Function       : SkipLine
-- Description    : This is used by the calculation section to see if the inventory line should be skipped when matching
--                  Transaction Inventory, Month and Line
-- Behaviour      : Evaluation down inside user exit, this is pulled by class V_TRANS_INV_SKIP_LINE
--
-----------------------------------------------------------------------------------------------------

FUNCTION SkipLine(p_contract_id VARCHAR2,
                  p_object_id VARCHAR2,
                  p_daytime DATE,
                  p_line_tag VARCHAR2)RETURN VARCHAR IS
BEGIN
  RETURN ue_trans_inventory.SkipLine(p_contract_id ,p_object_id,p_daytime,p_line_tag);
END SkipLine;

-----------------------------------------------------------------------------------------------------
-- Function       : SkipProduct
-- Description    : This is used by the calculation section to see if the product should be skipped when matching
--                  Transaction Inventory, Month, Line and Product
-- Behaviour      : Evaluation down inside user exit, this is pulled by class V_TRANS_INV_SKIP_PROD
--
-----------------------------------------------------------------------------------------------------

FUNCTION SkipProduct(p_contract_id VARCHAR2,
                     p_object_id VARCHAR2,
                     p_daytime DATE,
                     p_product_id VARCHAR2,
                     p_cost_type varchar2,
                     p_line_tag VARCHAR2)
                                  RETURN VARCHAR IS
BEGIN
  RETURN ue_trans_inventory.SkipProduct(p_contract_id ,p_object_id, p_daytime,p_product_id,p_cost_type ,p_line_tag);
END SkipProduct;

-----------------------------------------------------------------------------------------------------
-- Function       : SkipVariable
-- Description    : This is used by the calculation section to see if the variable should be skipped when matching
--                  Transaction Inventory, Month, Line, Product, variable id, for the execution order of the variable
-- Behaviour      : Evaluation down inside user exit, this is pulled by class V_TRANS_INV_SKIP_PR_VAR
--
-----------------------------------------------------------------------------------------------------

FUNCTION SkipVariable(p_contract_id VARCHAR2,
                      p_object_id VARCHAR2,
                      p_daytime DATE,
                      p_product_id VARCHAR2,
                      p_cost_type VARCHAR2,
                      p_line_tag VARCHAR2,
                      p_exec_order NUMBER,
                      p_config_variable VARCHAR2)       RETURN VARCHAR IS
BEGIN
  RETURN ue_trans_inventory.SkipVariable(p_contract_id ,p_object_id,p_daytime,p_product_id,p_cost_type,p_line_tag,p_exec_order,p_config_variable);
END SkipVariable;


-----------------------------------------------------------------------------------------------------
-- Function       : SkipAllObj
-- Description    : This is used by the calculation section to see if the object should be skipped when matching
--                  Transaction Inventory, Month, Line, Product and Object
-- Behaviour      : Evaluation down inside user exit, this is pulled by class V_TRANS_INV_SKIP_OBJ
--
-----------------------------------------------------------------------------------------------------


FUNCTION SkipAllDim(p_contract_id VARCHAR2,
                    p_object_id VARCHAR2,
                    p_daytime DATE,
                    p_product_id VARCHAR2,
                    p_cost_type varchar2,
                    p_line_tag VARCHAR2,
                    p_dimension_id VARCHAR2)     RETURN VARCHAR IS
BEGIN
  RETURN ue_trans_inventory.SkipAllDim(p_contract_id ,p_object_id,p_daytime,p_product_id,p_cost_type,p_line_tag,p_dimension_id);
END SkipAllDim;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : AllowChangeProdSet
-- Description    : This checks to see if it should prevent allowing change of product set on transaction inventory
--                  because there are trans_inv_li_products connected to the product set
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : calc_variable,calc_object_type,config_variable_param
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      : is used by classes TRANS_INV_LI_PR_VAR_DIM and TRANS_INV_MSG_VAR_DIM to display
--                  the product type in the screen
--
-----------------------------------------------------------------------------------------------------

function AllowChangeProdSet(p_daytime   DATE,
                            p_end_date  DATE,
                            p_product_group   VARCHAR2,
                            p_object_id VARCHAR2) return boolean


  is
  ln_count NUMBER;
  lb_allow boolean;
  BEGIN
    lb_allow := true;
    IF ln_count >0 THEN
      lb_allow := false;
    END IF ;
    return lb_allow;

end AllowChangeProdSet;



Function SingleValue(
  p_OBJECT_ID       VARCHAR2,
  p_DAYTIME         DATE,
  p_LAYER_MONTH     DATE,
  p_DIMENSION_TAG   VARCHAR2,
  p_TABLE_NAME      VARCHAR2,
  p_CALC_RUN_NO     VARCHAR2,
  p_column_name     VARCHAR2) RETURN NUMBER IS
  ln_return NUMBER;
  lv_sql VARCHAR2(4000);

  TYPE cur_typ        IS REF CURSOR;
  cur cur_typ;

  BEGIN

  lv_sql := 'SELECT MAX(' || p_column_name || ')  FROM ' || p_TABLE_NAME || ' WHERE '
         || ' LAYER_MONTH =TO_DATE(''' || TO_CHAR(p_LAYER_MONTH,'MMDDYY') || ''',''MMDDYY'')'
         || ' AND DAYTIME=TO_DATE(''' || TO_CHAR(p_daytime,'MMDDYY') || ''',''MMDDYY'')'
         || ' AND DIMENSION_TAG=''' || p_DIMENSION_TAG|| ''' '
         || ' AND OBJECT_ID = ''' ||p_OBJECT_ID  || ''' '
         || ' AND CALC_RUN_NO=''' || p_CALC_RUN_NO|| ''' ';


   OPEN cur FOR

     lv_sql;

   LOOP
      FETCH cur INTO ln_return;
      EXIT WHEN cur%NOTFOUND;

   END LOOP;
   CLOSE cur;

  RETURN ln_return;
END SingleValue;


FUNCTION GetDimName(p_object_id VARCHAR2,
                    p_line_tag VARCHAR2,
                    p_contract_id VARCHAR2,
                    p_daytime date) return varchar2 is
   lv2_name VARCHAR2(32);
BEGIN


   SELECT MAX(ecdp_trans_inventory.DimNameFromTag(p_object_id,p_contract_id,p_daytime,dil.DIM_ITEM_ID_1,1) ||
       decode(dil.DIM_ITEM_ID_2 , null, null , '|')||
       ecdp_trans_inventory.DimNameFromTag(p_object_id,p_contract_id,p_daytime,dil.DIM_ITEM_ID_2,2)) INTO lv2_name FROM
   V_DIMENSION_ITEMS_LINE dil
   where dil.OBJECT_ID = p_object_id
     and tag = p_line_tag
     and contract_id = p_contract_id
     and daytime = p_daytime;

   RETURN lv2_name;
END;




FUNCTION DimNameFromTag(p_object_id VARCHAR2,
                        p_contract_id VARCHAR2,
                        p_daytime DATE,
                        p_dim_tag VARCHAR2) return varchar2
is
begin

  return DimNameFromTag(p_object_id ,
                        p_contract_id ,
                        p_daytime ,
                        p_dim_tag ,
                         -1 );
end;




FUNCTION DimNameFromTag(p_object_id VARCHAR2,
                        p_contract_id VARCHAR2,
                        p_daytime DATE,
                        p_dim_tag VARCHAR2,
                        p_dim_number NUMBER) return varchar2 is

   lv2_name VARCHAR2(300);
   lv2_name2 VARCHAR2(300);
   dim_type VARCHAR2(32);
   dim_syntax VARCHAR2(32);
   ln_dim_temp number;
   lv_dim_temp varchar2(200);
BEGIN

   ln_dim_temp:= p_dim_number;
  lv_dim_temp := p_dim_tag;



  IF p_dim_number < 2 AND INSTR(p_dim_tag,'|') > 0 THEN
    lN_dim_temp :=1;
    lv_dim_temp := substr(lv_dim_temp,0,instr(lv_dim_temp,'|')-1);
  END IF;

  IF p_dim_number < 2 THEN
   dim_type := EC_CNTR_ATTR_DIM_TYPE.attribute_type('TRANS_INV_DIM_' || ln_dim_temp);
   dim_syntax := EC_CNTR_ATTR_DIM_TYPE.attribute_syntax('TRANS_INV_DIM_' || ln_dim_temp);

   if instr(lv_dim_temp,'|') > 0 then
     lv_dim_temp:=substr(lv_dim_temp,1,instr(lv_dim_temp,'|')-1);
   end if;



   IF dim_type = 'EC_CODE' then
     lv2_name := ec_prosty_codes.code_text(lv_dim_temp,dim_syntax);
   ELSIF dim_type = 'OBJECT' then
     lv2_name := ecdp_objects.GetObjName(ec_prosty_codes.code_text(lv_dim_temp,dim_syntax),p_daytime);
   ELSE
     NULL;
   END IF;
  END IF;



   IF (p_dim_number = -1 and lv2_name is not null) or p_dim_number = 2 THEN

       ln_dim_temp := 2;
       lv_dim_temp := p_dim_tag;


       IF instr(lv_dim_temp,'|') > 0 THEN
            lv_dim_temp:= substr(lv_dim_temp,Instr(lv_dim_temp,'|')+1);
       END IF;
       IF instr(lv_dim_temp,'|') > 0 THEN
           lv_dim_temp := substr(lv_dim_temp,1,instr(lv_dim_temp,'|')-1);
       END IF;

       dim_type := EC_CNTR_ATTR_DIM_TYPE.attribute_type('TRANS_INV_DIM_' || ln_dim_temp);
       dim_syntax := EC_CNTR_ATTR_DIM_TYPE.attribute_syntax('TRANS_INV_DIM_' || ln_dim_temp);

       IF dim_type = 'EC_CODE' then
         lv2_name2 :=  ec_prosty_codes.code_text(lv_dim_temp,dim_syntax);
       ELSIF dim_type = 'OBJECT' then
         lv2_name2 := ecdp_objects.GetObjName(ec_prosty_codes.code_text(lv_dim_temp,dim_syntax),p_daytime);
       ELSE
         NULL;
       END IF;



       if lv2_name is not null  then
         lv2_name:= lv2_name ||'/';


       end if;
         lv2_name:= lv2_name || lv2_name2;
   END IF;

   RETURN lv2_name;
END;


-----------------------------------------------------------------------
-- Check if the row already exists in the OVERRIDE_DIMENSION table
-- for the given time scope.
-- Returns BOOLEAN.
----+---+--------------------------------+-----------------------------
FUNCTION Exist_OverrideDimension(
    p_object_id                          VARCHAR2,
    p_line_tag                           VARCHAR2,
    p_project_id                         VARCHAR2,
    p_daytime                            DATE,
    p_end_date                           DATE) RETURN BOOLEAN
IS
    CURSOR cr_get_override_dim_dist_count(
        cp_object_id                     VARCHAR2,
        cp_line_tag                      VARCHAR2,
        cp_project_id                    VARCHAR2,
        cp_daytime                       DATE,
        cp_end_date                      DATE)
    IS
        SELECT count(line_tag) as item_count
          FROM OVERRIDE_DIMENSION
         WHERE trans_inv_id = cp_object_id
           AND line_tag = cp_line_tag
           AND project_id = cp_project_id
           AND (   --Check if "Start_Date" exists inside existing item
                   (cp_daytime between daytime and nvl(end_date-1, cp_daytime))
                   --Check if "End_Date" exists inside existing item
                   or (cp_end_date between daytime+1 and end_date)
                   --Check if existing item exists between "Start_Date" and "End_Date"
                   or (cp_daytime < daytime and cp_end_date > end_date)
               );

    ln_item_count                        NUMBER := 0;
    lb_item_exists                       BOOLEAN := FALSE;
BEGIN
    FOR item in cr_get_override_dim_dist_count(p_object_id, p_line_tag, p_project_id, p_daytime, p_end_date) LOOP
        ln_item_count := item.item_count;
    END LOOP;
    IF ln_item_count > 0 THEN
        lb_item_exists := TRUE;
    END IF;

    RETURN lb_item_exists;
END;

-----------------------------------------------------------------------
-- Check if DIMENSION_ITEMS_LINE exists for specified date.
-- Returns user feedback to be used in screens.
----+---+--------------------------------+-----------------------------
FUNCTION Exist_DimensionItemsLine(
    p_object_id                          VARCHAR2,
    p_line_tag                           VARCHAR2,
    p_project_id                         VARCHAR2,
    p_daytime                            DATE) RETURN VARCHAR2
IS
    CURSOR cr_existing_composition(
        cp_object_id                     VARCHAR2,
        cp_line_tag                      VARCHAR2,
        cp_project_id                    VARCHAR2,
        cp_daytime                       DATE)
    IS
        SELECT count(*) as item_count
          FROM V_DIMENSION_ITEMS_LINE l
         WHERE object_id = cp_object_id
           AND tag = nvl(cp_line_tag, tag)
           AND contract_id= nvl(cp_project_id,contract_id)
           AND daytime = nvl(cp_daytime, daytime);

    CURSOR cr_prev_composition(
        cp_object_id                     VARCHAR2,
        cp_line_tag                      VARCHAR2,
        cp_project_id                    VARCHAR2,
        cp_daytime                       DATE)
    IS
        SELECT max(daytime) as daytime
          FROM V_DIMENSION_ITEMS_LINE l
         WHERE object_id = cp_object_id
           AND contract_id= cp_project_id
           AND tag = cp_line_tag
           AND daytime < cp_daytime
         ORDER BY daytime;

    CURSOR cr_next_composition(
        cp_object_id                     VARCHAR2,
        cp_line_tag                      VARCHAR2,
        cp_project_id                    VARCHAR2,
        cp_daytime                       DATE)
    IS
        SELECT daytime FROM (
            SELECT *
              FROM V_DIMENSION_ITEMS_LINE l
             WHERE object_id = cp_object_id
               AND contract_id= cp_project_id
               AND tag = cp_line_tag
               AND daytime > cp_daytime
             ORDER BY daytime
        )
        WHERE rownum <= 1;

    ln_item_count                        NUMBER := 0;
    lv_alternative_date                  VARCHAR2(240);
    lv_end_user_message                  VARCHAR2(240) := '';
    ex_validation_error                  EXCEPTION;
BEGIN
    --Check if specified object_id exists in existing composition.
    FOR item in cr_existing_composition(p_object_id, null, null, null) LOOP
        ln_item_count := item.item_count;
    END LOOP;
    IF ln_item_count = 0 THEN
        lv_end_user_message := ec_trans_inventory_version.name(p_object_id, p_daytime, '<=');
        lv_end_user_message := CASE nvl(lv_end_user_message,'NULL') WHEN 'NULL' THEN '' ELSE ' (' || lv_end_user_message || ')' END;
        lv_end_user_message := 'The specified transaction inventory' || lv_end_user_message || ' does not exist in existing composition.';
        RAISE ex_validation_error;
    END IF;

    --Check if specified line tag exists in existing composition.
    FOR item in cr_existing_composition(p_object_id, p_line_tag, null, null) LOOP
        ln_item_count := item.item_count;
    END LOOP;
    IF ln_item_count = 0 THEN
        lv_end_user_message := 'The specified transaction line (' || p_line_tag || ') does not exist in existing composition.';
        RAISE ex_validation_error;
    END IF;


    --Check if specified project exists in existing composition.
    FOR item in cr_existing_composition(p_object_id, p_line_tag, p_project_id, null) LOOP
        ln_item_count := item.item_count;
    END LOOP;
    IF ln_item_count = 0 THEN
        lv_end_user_message := 'The specified Stream/Project/Contract (' || ec_contract_version.name(p_project_id,p_daytime) || ') does not exist in existing composition.';
        RAISE ex_validation_error;
    END IF;


    --Check if specified line tag exists in existing composition for specified daytime.
    FOR item in cr_existing_composition(p_object_id, p_line_tag, p_project_id, p_daytime) LOOP
        ln_item_count := item.item_count;
    END LOOP;
    IF ln_item_count = 0 THEN
        lv_end_user_message := 'The specified transaction line (' || p_line_tag || ') does not exist in existing composition for specified date ''' || to_char(p_daytime, 'yyyy-mm-dd') || '''.';
        --Check for prev period end
        lv_alternative_date := '';
        FOR item in cr_prev_composition(p_object_id, p_line_tag, p_project_id, p_daytime) LOOP
            lv_alternative_date := to_char(item.daytime, 'yyyy-mm-dd');
        END LOOP;
        IF lv_alternative_date IS NOT NULL THEN
            lv_end_user_message := lv_end_user_message ||  chr(10) || 'The previous avaliable period ends ''' || lv_alternative_date || '''.';
        END IF;
        --Check for next period start
        lv_alternative_date := '';
        FOR item in cr_next_composition(p_object_id, p_line_tag, p_project_id, p_daytime) LOOP
            lv_alternative_date := to_char(item.daytime, 'yyyy-mm-dd');
        END LOOP;
        IF lv_alternative_date IS NOT NULL THEN
            lv_end_user_message := lv_end_user_message ||  chr(10) || 'The next avaliable period starts from ''' || lv_alternative_date || '''.';
        END IF;

        RAISE ex_validation_error;
    END IF;

    RETURN NULL;
EXCEPTION
    WHEN ex_validation_error THEN
        RETURN lv_end_user_message;
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, SQLERRM || '\n\n' || 'Technical:\n');
END Exist_DimensionItemsLine;

-----------------------------------------------------------------------
-- Check if dates are valid compare to each other.
-- Returns user feedback to be used in screens.
----+---+--------------------------------+-----------------------------
FUNCTION CheckDimensionDates(
    p_start_date                         DATE,
    p_end_date                           DATE) RETURN VARCHAR2
IS
    lv_end_user_message                  VARCHAR2(240);
    ex_validation_error                  EXCEPTION;
BEGIN
    --Validate dates
    IF NOT (p_end_date > p_start_date) THEN
        lv_end_user_message := 'The specified ''To Date'' cannot be less or equal to ''From Date''.';
        RAISE ex_validation_error;
    END IF;

    RETURN NULL;
EXCEPTION
    WHEN ex_validation_error THEN
        RETURN lv_end_user_message;
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, SQLERRM || '\n\n' || 'Technical:\n');
END CheckDimensionDates;

-----------------------------------------------------------------------
-- This will create a new version with the existing setup and allow
-- the user to change it.
-- Returns user feedback to be used in screens.
----+---+--------------------------------+-----------------------------
FUNCTION CreateDimOverride(
    p_object_id                          VARCHAR2,
    p_line_tag                           VARCHAR2,
    p_project_id                         VARCHAR2,
    p_daytime                            VARCHAR2,
    p_end_date                           VARCHAR2) RETURN VARCHAR2
IS
    CURSOR cr_existing_composition(
        cp_object_id                     VARCHAR2,
        cp_line_tag                      VARCHAR2,
        cp_project_id                    VARCHAR2,
        cp_daytime                       DATE)
    IS
        SELECT *
          FROM V_DIMENSION_ITEMS_LINE
         WHERE object_id =  cp_object_id
           AND tag = cp_line_tag
           AND contract_id = cp_project_id
           AND daytime = cp_daytime;

    ld_daytime                           DATE := to_date(p_daytime,'yyyy-MM-dd"T"HH24:MI:SS');
    ld_end_date                          DATE := to_date(p_end_date,'yyyy-MM-dd"T"HH24:MI:SS');
    ln_item_count                        NUMBER := 0;
    lv_end_user_message                  VARCHAR2(1024);
    ex_validation_error                  EXCEPTION;
BEGIN
    --Validate dates
  IF p_daytime IS NULL OR p_daytime = '' THEN
        lv_end_user_message := 'Warning!' || chr(10) || 'Not possible to create. Start Month is not set.';
        RAISE ex_validation_error;
    END IF;
    IF p_end_date IS NULL OR p_end_date = '' THEN
        lv_end_user_message := 'Warning!' || chr(10) || 'Not possible to create. End Month is not set.';
        RAISE ex_validation_error;
    END IF;
    lv_end_user_message := CheckDimensionDates(ld_daytime, ld_end_date);
    IF lv_end_user_message IS NOT NULL THEN
        lv_end_user_message := 'Warning!' || chr(10) || 'Not possible to create. ' || lv_end_user_message;
        RAISE ex_validation_error;
    END IF;

    --Check if DIMENSION_ITEMS_LINE exists for specified date
    lv_end_user_message := Exist_DimensionItemsLine(p_object_id, p_line_tag, p_project_id, ld_daytime);
    IF lv_end_user_message IS NOT NULL THEN
        lv_end_user_message := 'Warning!' || chr(10) || 'Not possible to create. ' || lv_end_user_message;
        RAISE ex_validation_error;
    END IF;

    --Check if the row already exists in the OVERRIDE_DIMENSION table
    IF Exist_OverrideDimension(p_object_id, p_line_tag,  p_project_id, ld_daytime, ld_end_date) THEN
        lv_end_user_message := 'Warning!' || chr(10) || 'Not possible to create. Override Version already exists in the time scope between ''' || to_char(ld_daytime,'yyyy-mm-dd') || ''' and ''' || to_char(ld_end_date,'yyyy-mm-dd') || '''.';
        RAISE ex_validation_error;
    END IF;

    ln_item_count := 0;
    FOR item in cr_existing_composition(p_object_id,p_line_tag,p_project_id,ld_daytime) LOOP
        INSERT INTO OVERRIDE_DIMENSION (
            OBJECT_ID,
            DAYTIME,
            END_DATE,
            PROJECT_ID,
            TRANS_INV_ID,
            LINE_TAG,
            EXEC_ORDER,
            DISABLED_IND,
            DIM_SET_ITEM_ID_1,
            DIM_SET_ITEM_ID_2)
        VALUES (
            item.DIM_OBJECT_ID,
            ld_daytime,
            ld_end_date,
            item.CONTRACT_ID,
            item.object_id,
            item.tag,
            item.EXEC_ORDER,
            'N',
            item.DIM_ITEM_1,
            item.DIM_ITEM_2);

        ln_item_count := ln_item_count + 1;
    END LOOP;
    IF ln_item_count = 0 THEN
        lv_end_user_message := 'Warning!' || chr(10) || 'No overrides are created!';
        lv_end_user_message := p_object_id||'-'||p_line_tag||'-'||p_project_id||'-'||ld_daytime;
        RAISE ex_validation_error;
    END IF;

    --Final feedback to user
    lv_end_user_message := 'Success!' || chr(10) || 'A new Override Version starting from ''' || to_char(ld_daytime,'yyyy-mm-dd') || ''' is created.';
    RETURN lv_end_user_message;

EXCEPTION
    WHEN ex_validation_error THEN
        RETURN lv_end_user_message;
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, SQLERRM || '\n\n' || 'Technical:\n');
END CreateDimOverride;

-----------------------------------------------------------------------
-- Deletes the specified dimension override.
----+---+--------------------------------+-----------------------------
PROCEDURE DeleteDimOverride(
    p_object_id                          VARCHAR2,
    p_line_tag                           VARCHAR2,
    p_project_id                         VARCHAR2,
    p_daytime                            DATE)
IS
BEGIN
    delete from override_dimension od
     where trans_inv_id = p_object_id
       and od.line_tag=p_line_tag
       and project_id = p_project_id
       and daytime = p_daytime;
END DeleteDimOverride;

-----------------------------------------------------------------------
-- Copies specified dimension override to a new date.
-- Returns user feedback to be used in screens.
----+---+--------------------------------+-----------------------------
FUNCTION CopyDimToNewVersion(
    p_object_id                          VARCHAR2,
    p_line_tag                           VARCHAR2,
    p_project_id                         VARCHAR2,
    p_daytime                            VARCHAR2,
    p_new_daytime                        VARCHAR2,
    p_new_end_date                       VARCHAR2) RETURN VARCHAR2
IS
    cursor cr_existing_composition(
        cp_object_id                     VARCHAR2,
        cp_line_tag                      VARCHAR2,
        cp_project_id                    VARCHAR2,
        cp_daytime                       DATE)
    IS
        SELECT * FROM OVERRIDE_DIMENSION
         WHERE TRANS_INV_ID =  cp_object_id
           AND LINE_TAG = cp_line_tag
           AND daytime = cp_daytime
           AND project_id = cp_project_id;

    ld_daytime             DATE := to_date(p_daytime,'yyyy-MM-dd"T"HH24:MI:SS');
    ld_new_daytime         DATE := to_date(p_new_daytime,'yyyy-MM-dd"T"HH24:MI:SS');
    ld_new_end_date        DATE := to_date(p_new_end_date,'yyyy-MM-dd"T"HH24:MI:SS');
    lv_end_user_message    VARCHAR2(1024);
    ex_validation_error    EXCEPTION;
BEGIN
    --Validate dates
    lv_end_user_message := CheckDimensionDates(ld_new_daytime, ld_new_end_date);
    IF lv_end_user_message IS NOT NULL THEN
        lv_end_user_message := 'Warning!' || chr(10) || 'Not possible to copy. ' || lv_end_user_message;
        RAISE ex_validation_error;
    END IF;

    --Check if DIMENSION_ITEMS_LINE exists for specified date
    lv_end_user_message := Exist_DimensionItemsLine(p_object_id, p_line_tag, p_project_id, ld_new_daytime);
    IF lv_end_user_message IS NOT NULL THEN
        lv_end_user_message := 'Warning!' || chr(10) || 'Not possible to copy. ' || lv_end_user_message;
        RAISE ex_validation_error;
    END IF;

    --Check if the row already exists in the OVERRIDE_DIMENSION table.
    IF Exist_OverrideDimension(p_object_id, p_line_tag, p_project_id, ld_new_daytime, ld_new_end_date) THEN
        lv_end_user_message := 'Warning!' || chr(10) || 'Not possible to copy. Override Version already exists in the time scope between ''' || to_char(ld_new_daytime,'yyyy-mm-dd') || ''' and ''' || to_char(ld_new_end_date,'yyyy-mm-dd') || '''.';
        RAISE ex_validation_error;
    END IF;

    --Copy the item
    FOR item in cr_existing_composition(p_object_id, p_line_tag,p_project_id, ld_daytime) LOOP
        INSERT INTO OVERRIDE_DIMENSION (
            OBJECT_ID,
            DAYTIME,
            END_DATE,
            PROJECT_ID,
            TRANS_INV_ID,
            LINE_TAG,
            EXEC_ORDER,
            DISABLED_IND,
            DIM_SET_ITEM_ID_1,
            DIM_SET_ITEM_ID_2)
        VALUES (
            item.OBJECT_ID,
            ld_new_daytime,
            ld_new_end_date,
            item.PROJECT_ID,
            item.TRANS_INV_ID,
            item.LINE_TAG,
            item.EXEC_ORDER,
            'N',
            item.DIM_SET_ITEM_ID_1,
            item.DIM_SET_ITEM_ID_2);
    END LOOP;

    --Final feedback to user
    lv_end_user_message := 'Success!' || chr(10) || 'A new copy of ''' || to_char(ld_daytime,'yyyy-mm-dd') || ''' is created starting from ''' || to_char(ld_new_daytime,'yyyy-mm-dd') || ''' and ends ''' || to_char(ld_new_end_date,'yyyy-mm-dd') || '''.';
    RETURN lv_end_user_message;

EXCEPTION
    WHEN ex_validation_error THEN
        RETURN lv_end_user_message;
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, SQLERRM || '\n\n' || 'Technical:\n');
END CopyDimToNewVersion;

FUNCTION CheckDimGroupChange(p_object_id VARCHAR2,
                           p_daytime DATE,
                           p_end_date DATE DEFAULT NULL) return VARCHAR2 is
begin
  null;
  return null;
end CheckDimGroupChange;

FUNCTION CheckDimSetChange(p_object_id VARCHAR2,
                           p_daytime DATE,
                           p_end_date DATE DEFAULT NULL) return VARCHAR2 is
begin
  null;
  return null;
end CheckDimSetChange;

FUNCTION DefaultInventory(p_inventory_id VARCHAR2,
                          p_product_id VARCHAR2,
                          p_daytime DATE,
                          p_user_id VARCHAR2,
                          p_contract_id VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
IS
        lv_ret_inv VARCHAR2(32);

     CURSOR c_inventory is

       SELECT tiv.object_id INTO lv_ret_inv
                      FROM trans_inventory_version tiv,
                     trans_inv_prod_stream tip,
                     contract_version cv,
                     calc_collection_element cce
                 WHERE cce.DAYTIME <= p_daytime
                   AND nvl(cce.END_DATE,p_daytime + 1) > p_daytime
                   AND cce.object_id = p_product_id
                   AND cce.element_id = cv.object_id
                   AND tiv.DAYTIME <= p_daytime
                   AND nvl(tiv.END_DATE,p_daytime + 1) > p_daytime
                   AND tip.DAYTIME <= p_daytime
                   AND nvl(tip.END_DATE,p_daytime + 1) > p_daytime
                  and tip.object_id = decode(nvl(p_contract_id,'null'),'null',tip.object_id,p_contract_id)
                  AND cv.object_id = tip.object_id
                  AND tip.inventory_id = tiv.object_id
                  and cv.daytime <= p_daytime
                  AND NVL(cv.end_date,p_DAYTIME+1) >p_daytime
                  ORDER BY TIP.EXEC_ORDER;

     BEGIN

     if nvl(p_inventory_id,'null') !='null' then
       return p_inventory_id;
     else

       SELECT MAX(key2) INTO lv_ret_inv
                      FROM REVN_CLIPBOARD,
                     trans_inventory_version tiv,
                     trans_inv_prod_stream tip,
                     contract_version cv,
                     calc_collection_element cce
                 WHERE USER_ID = p_user_id
                   and type = 'INVENTORY_NAVIGATION'
--                   and key1 in (p_contract_id,p_prod_set_group_id)
                   AND cce.DAYTIME <= p_daytime
                   AND nvl(cce.END_DATE,p_daytime + 1) > p_daytime
                   --AND cce.object_id = p_prod_set_group_id
                   AND cce.element_id = cv.object_id
                   AND tiv.object_id=key2
                   AND tiv.DAYTIME <= p_daytime
                   AND nvl(tiv.END_DATE,p_daytime + 1) > p_daytime
                   AND tip.DAYTIME <= p_daytime
                   AND nvl(tip.END_DATE,p_daytime + 1) > p_daytime
                  and tip.object_id = decode(nvl(p_contract_id,'null'),'null',tip.object_id,p_contract_id)
                  AND cv.object_id = tip.object_id
                  AND tip.inventory_id = tiv.object_id
                  and cv.daytime <= p_daytime
                  AND NVL(cv.end_date,p_DAYTIME+1) >p_daytime;

     IF lv_ret_inv IS NULL THEN
       for inv in c_inventory LOOP
         lv_ret_inv := INV.OBJECT_ID;
         RETURN lv_ret_inv;
       END LOOP;

     END IF;
     RETURN lv_ret_inv;

     end if;

END;


FUNCTION DefaultInventory(p_run_no  VARCHAR2 default '-1',
                          p_user_id VARCHAR2)  RETURN VARCHAR2 is
    lv_return varchar2(32);
    lrec_calc_ref  calc_reference%rowtype;
    lv_contract_id VARCHAR2(32);
BEGIN
  IF p_run_no != '-1' and  p_run_no != 'null'  THEN
      lrec_calc_ref := ec_calc_reference.row_by_pk(to_number(p_run_no));
      if lrec_calc_ref.calc_collection_id != lrec_calc_ref.ref_object_id_1 then
         lv_contract_id:=lrec_calc_ref.ref_object_id_1;
      end if;

      lv_return := DefaultInventory(null,lrec_calc_ref.calc_collection_id,lrec_calc_ref.daytime,p_user_id,lv_contract_id);
  END IF;
  return lv_return;
END;


-----------------------------------------------------------------------------------------------------
-- Function       : DefaultInventoryTemplate
-- Description    : This is used by the app query-xml in Transaction Inventory Overview to get the
--                  chosen template when reload.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : REVN_CLIPBOARD, V_TRANS_INV_TMPL_SELECTOR
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Getting a template code from clipboard.
--                  The cursor join will make sure the template code is still valid.
-----------------------------------------------------------------------------------------------------
FUNCTION DefaultInventoryTemplate(p_contract_id          VARCHAR2,
                                  p_revn_prod_stream_id  VARCHAR2,
                                  p_prod_stream_group_id VARCHAR2,
                                  p_trans_inventory_id   VARCHAR2,
                                  p_user_id              VARCHAR2)  RETURN VARCHAR2 IS
    CURSOR c_clipboard IS
        SELECT rc.key3
          FROM REVN_CLIPBOARD rc
          JOIN V_TRANS_INV_NAV_TMPL tt
               ON rc.key2 = tt.INVENTORY_ID
               AND rc.key3 = tt.CODE
               AND rc.daytime >= tt.DAYTIME
               AND rc.daytime < nvl(tt.END_DATE, rc.daytime + 1)
               AND tt.CONTRACT_ID = p_contract_id
         WHERE rc.type = 'INVENTORY_NAVIGATION'
           AND rc.user_id = p_user_id
           AND rc.key1 = decode(nvl(p_revn_prod_stream_id, 'null'), 'null', p_prod_stream_group_id, p_revn_prod_stream_id)
           AND rc.key2 = p_trans_inventory_id
      ORDER BY rc.daytime DESC;

    lv_return VARCHAR2(32);
BEGIN
    IF nvl(p_prod_stream_group_id,'$NULL$') != '$NULL$' AND nvl(p_trans_inventory_id,'$NULL$') != '$NULL$' THEN
        FOR cb IN c_clipboard LOOP
            lv_return := cb.key3;
            EXIT;
        END LOOP;
    END IF;

    RETURN lv_return;
END;


FUNCTION CreateTransInvLineOverride(p_trans_inventory_id VARCHAR2,
                                     p_contract_id        VARCHAR2,
                                     p_trans_inv_line     VARCHAR2,
                                     p_daytime            DATE,
                                     p_from_date          DATE,
                                     p_to_date            DATE,
                                     p_user_id            VARCHAR2)  RETURN VARCHAR2 IS

  lrec_trans_inv_line trans_inv_line%rowtype;
  ln_found NUMBER;

BEGIN

  select count(*) into ln_found from trans_inv_line_override
         where object_id = p_trans_inventory_id
           and tag = p_trans_inv_line
           and p_contract_id = contract_id
           and (
           -- From Date is between the dates
                   (daytime < p_from_date   and nvl(end_date,p_from_date+1) > p_from_date)
           -- To Date is between the dates
                or (p_to_date > daytime     and p_to_date < nvl(end_date,p_to_date+1))
           -- From Date is before and to date is after
                or (daytime > p_from_date and p_to_date>nvl(end_date,p_to_date+1) ));

  IF ln_found >0 THEN
     RAISE_APPLICATION_ERROR(-20001, 'There is overlapping values for the given period and it can not be created for the period ' || to_char(p_from_date,'YYYY-MM-dd') || ' to ' || to_char(p_to_date,'YYYY-MM-dd') );
  END IF;




-- Check from and to are acceptable
   lrec_trans_inv_line := ec_trans_inv_line.row_by_pk(p_trans_inventory_id,p_daytime,p_trans_inv_line);
  IF EC_TRANS_INVENTORY_VERSION.valuation_method(p_trans_inventory_id,p_daytime,'<=') = 'TEMPLATE' THEN
    RAISE_APPLICATION_ERROR(-20001,'This is a template inventory. You can not overrider Lines and Products. You can add Variables.');
  END IF;

  --RAISE_APPLICATION_ERROR(-20001,ECDP_OBJECTS.GETOBJCODE(p_trans_inventory_id) ||'-'|| ec_trans_inventory_version.config_template(p_trans_inventory_id,p_daytime,'<='));

   IF lrec_trans_inv_line.Object_Id IS NULL AND
     ec_trans_inventory_version.config_template(p_trans_inventory_id,p_daytime,'<=') is not null then
     lrec_trans_inv_line := ec_trans_inv_line.row_by_pk(ec_trans_inventory_version.config_template(p_trans_inventory_id,p_daytime,'<=') ,p_daytime,p_trans_inv_line);
   end if;

   INSERT INTO TRANS_INV_LINE_OVERRIDE
   (OBJECT_ID,
    DAYTIME ,
    END_DATE,
    EXEC_ORDER,
    VAL_EXEC_ORDER,
    CONTRACT_ID,
    trans_def_dimension,
    TAG,
    DIMENSION_OVER_MONTH_IND,
    ROUND_TRANSACTION_IND,
    ROUND_VALUE_IND,
    CURRENT_PERIOD_ONLY_IND,
    PRORATE_LINE         ,
    PRODUCT_SOURCE_METHOD,
    Xfer_In_Trans_Id     ,
    XFER_IN_LINE,
    DESCRIPTION,
    POST_PROCESS_IND
    )
   VALUES
   (
    p_trans_inventory_id,
    p_from_date ,
    p_to_date,
    lrec_trans_inv_line.EXEC_ORDER,
    lrec_trans_inv_line.VAL_EXEC_ORDER,
    p_CONTRACT_ID,
    lrec_trans_inv_line.trans_def_dimension,
    lrec_trans_inv_line.TAG,
    lrec_trans_inv_line.DIMENSION_OVER_MONTH_IND,
    lrec_trans_inv_line.ROUND_TRANSACTION_IND,
    lrec_trans_inv_line.ROUND_VALUE_IND,
    lrec_trans_inv_line.CURRENT_PERIOD_ONLY_IND,
    lrec_trans_inv_line.PRORATE_LINE         ,
    lrec_trans_inv_line.Product_Source_Method     ,
    lrec_trans_inv_line.Xfer_In_Trans_Id     ,
    lrec_trans_inv_line.XFER_IN_LINE,
    lrec_trans_inv_line.Description,
    lrec_trans_inv_line.POST_PROCESS_IND
    );

RETURN 'Override Created';
END;

FUNCTION getdefaultProRateProduct(p_TYPE VARCHAR2,
         p_PRORATE_LINE VARCHAR2,
         p_PRODUCT_SOURCE_METHOD VARCHAR2,
         p_object_id VARCHAR2,
         p_product_id  VARCHAR2,
         p_counter_product_ind VARCHAR2,
         p_cost_type VARCHAR2 DEFAULT NULL,
         p_sum_value_cost_ind  VARCHAR2 DEFAULT NULL,
         p_master_product varchar2
         )
  RETURN VARCHAR2

is
  lv_return varchar2(32);
BEGIN
  CASE p_PRODUCT_SOURCE_METHOD
      WHEN 'PULL_MASTER' THEN
          lv_return :=p_master_product;
      WHEN 'PULL_NONMASTER_FROM_EXTR' THEN
         if p_master_product != p_product_id then
          lv_return :=p_master_product;
          end if;
       ELSE
        lv_return := NULL;
    END CASE;
    return lv_return;
END;

FUNCTION getdefaultQtyMtd(p_TYPE VARCHAR2,
         p_PRORATE_LINE VARCHAR2,
        p_PRODUCT_SOURCE_METHOD VARCHAR2,
         p_object_id VARCHAR2,
         p_product_id  VARCHAR2,
         p_counter_product_ind VARCHAR2,
         p_is_master_IND VARCHAR2,
         p_cost_type VARCHAR2 DEFAULT NULL,
         p_sum_value_cost_ind  VARCHAR2 DEFAULT NULL         ) RETURN VARCHAR2
is
      lv_return VARCHAR2(32);
BEGIN


  CASE p_PRODUCT_SOURCE_METHOD
      WHEN 'PULL_MASTER' THEN
        IF NVL(p_is_master_IND,'N') = 'Y' THEN
          lv_return :='EXTRACT';
        ELSE
           lv_return :='PRORATED_QTY';
        END IF;
      WHEN 'PULL_NONMASTER_FROM_EXTR' THEN
        IF NVL(p_is_master_IND,'N') = 'N' THEN
          lv_return :='EXTRACT';
        ELSE
           lv_return :='PRORATED_QTY';
        END IF;
      WHEN 'PULL_EACH_FROM_EXTR' THEN
        lv_return :='EXTRACT';
      WHEN 'PULL_ALL_FROM_EXTR' THEN
        lv_return :='EXTRACT';
      WHEN 'XFER_IN' THEN
        lv_return:='XFER_IN';
      ELSE
        lv_return := NULL;
    END CASE;

    RETURN lv_return;
END;


FUNCTION getdefaultValMtd(p_TYPE VARCHAR2,
         p_PRORATE_LINE VARCHAR2,
         p_PRODUCT_SOURCE_METHOD VARCHAR2,
         p_object_id VARCHAR2,
         p_product_id  VARCHAR2,
         p_counter_product_ind VARCHAR2,
         p_is_master_IND VARCHAR2,
         p_cost_type VARCHAR2 DEFAULT NULL,
         p_sum_value_cost_ind  VARCHAR2 DEFAULT NULL,
         p_line_type  VARCHAR2 DEFAULT NULL
         ) RETURN VARCHAR2
is
         lv_return VARCHAR2(32);
BEGIN

  --IF p_cost_type != 'NA' THEN
  IF p_line_type = 'NET_ZERO' THEN
    lv_return := 'NONE';
  ELSE
  CASE nvl(p_PRODUCT_SOURCE_METHOD,'EMPTY')
      WHEN 'PULL_MASTER' THEN
        lv_return :='PRORATED_QTY';
      WHEN 'PULL_NONMASTER_FROM_EXTR' THEN
        lv_return :='PRORATED_QTY';
      WHEN 'PULL_EACH_FROM_EXTR' THEN
        lv_return :='PRORATED_QTY';
      WHEN 'PULL_ALL_FROM_EXTR' THEN
        lv_return :='EXTRACT';
      WHEN 'XFER_IN' THEN
        lv_return:='XFER_IN';
      WHEN 'EMPTY' THEN
           CASE p_TYPE
             WHEN 'XFER_IN' THEN
               lv_return:='XFER_IN';
             WHEN 'XFER_OUT' THEN
               lv_return :='PRORATED_QTY';
             WHEN 'DECREASE' THEN
               lv_return :='PRORATED_QTY';
             WHEN 'POOL' THEN
               lv_return:= NULL;
             WHEN 'GAIN_LOSS' THEN
                lv_return:=  'JOURNAL_EXT';
             WHEN 'INCREASE' THEN
                lv_return:=  'JOURNAL_EXT';
            ELSE
                lv_return :='PRORATED_QTY';
            END CASE;
      ELSE

        lv_return := NULL;
      END CASE;
      END IF;
      RETURN lv_return;
END;


FUNCTION CreateTransInvProdOverride(p_trans_inventory_id VARCHAR2,
                                     p_contract_id        VARCHAR2,
                                     p_trans_inv_line     VARCHAR2,
                                     p_product_id         VARCHAR2,
                                     p_cost_type       VARCHAR2,
                                     p_daytime            DATE,
                                     p_from_date          DATE,
                                     p_to_date            DATE,
                                     p_user_id            VARCHAR2)  RETURN VARCHAR2 IS

  lrec_trans_inv_li_product trans_inv_li_product%rowtype;
  ln_found NUMBER;

  cursor default_values (cp_trans_inventory_id varchar2,
                         cp_daytime            varchar2,
                         cp_trans_inv_line     varchar2,
                         cp_product_id         varchar2,
                         cp_cost_type          varchar2,
                         cp_contract_id        varchar2)  is
select *
from v_trans_inv_li_pr_over v
 where period = cp_daytime
 and object_id = cp_trans_inventory_id
 and cp_trans_inv_line = V.line_tag
 and product_id = p_product_id
 and cost_type = cp_cost_type
 and v.project = cp_contract_id;
BEGIN

  select count(*) into ln_found from trans_inv_li_pr_over
         where object_id = p_trans_inventory_id
           and tag = p_trans_inv_line
           and p_contract_id = contract_id
           and product_id = p_product_id
           and cost_type = p_cost_type
           and (
           -- From Date is between the dates
                   (daytime < p_from_date   and nvl(end_date,p_from_date+1) > p_from_date)
           -- To Date is between the dates
                or (p_to_date > daytime     and p_to_date < nvl(end_date,p_to_date+1))
           -- From Date is before and to date is after
                or (daytime > p_from_date and p_to_date>nvl(end_date,p_to_date+1) ));

  IF ln_found >0 THEN
     RAISE_APPLICATION_ERROR(-20001, 'There is overlapping values for the given period and it can not be created for the period ' || to_char(p_from_date,'YYYY-MM-dd') || ' to ' || to_char(p_to_date,'YYYY-MM-dd') );
  END IF;

  IF EC_TRANS_INVENTORY_VERSION.valuation_method(p_trans_inventory_id,p_daytime,'<=') = 'TEMPLATE' THEN
    RAISE_APPLICATION_ERROR(-20001,'This is a template inventory. You can not overrider Lines and Products. You can add Variables.');
  END IF;

-- Check from and to are acceptable
   lrec_trans_inv_li_product := ec_trans_inv_li_product.row_by_pk(p_trans_inventory_id,p_daytime,p_trans_inv_line,p_product_id,p_cost_type);

   IF lrec_trans_inv_li_product.OBJECT_ID IS NULL AND
     ec_trans_inventory_version.config_template(p_trans_inventory_id,p_daytime,'<=') is not null then
     lrec_trans_inv_li_product := ec_trans_inv_li_product.row_by_pk(ec_trans_inventory_version.config_template(p_trans_inventory_id,p_daytime,'<=') ,p_daytime,p_trans_inv_line,p_product_id,p_cost_type);
   end if;

   if lrec_trans_inv_li_product.object_id is not null then

           INSERT INTO TRANS_INV_LI_PR_OVER
           (OBJECT_ID,
            DAYTIME ,
            END_DATE,
            EXEC_ORDER,
            CONTRACT_ID,
            trans_def_dimension,
            TAG,
            PRODUCT_ID,
            COST_TYPE,
            PRORATE_DIM_TO_PROD_ID,
            SEQ_NO,
            QTY_EXEC_ORDER,
            QTY_SOURCE_METHOD,
            VALUE_METHOD,
            PRICE_INDEX,
            VAL_EXTRACT_TAG,
            QTY_EXTRACT_TAG,
            VAL_EXTRACT_TYPE,
            QTY_EXTRACT_TYPE,
            EXTR_VAL_NET_ZERO,
            EXTRACT_REVRS_VAL,
            EXTRACT_REVRS_QTY,
            ID,
            PRORATE_LINE,
            PRORATE_IND
            )
           VALUES
           (
            p_trans_inventory_id,
            p_from_date ,
            p_to_date,
            lrec_trans_inv_li_product.Val_Exec_Order,
            p_CONTRACT_ID,
            nvl(lrec_trans_inv_li_product.trans_def_dimension,ec_trans_inv_line.trans_def_dimension(p_trans_inventory_id,p_daytime,p_trans_inv_line)),
            lrec_trans_inv_li_product.line_TAG,
            p_product_id,
            p_cost_type,
            lrec_trans_inv_li_product.PRORATE_DIM_TO_PROD_ID,
            lrec_trans_inv_li_product.SEQ_NO,
            lrec_trans_inv_li_product.Exec_Order,
            lrec_trans_inv_li_product.Quantity_Source_Method,
            lrec_trans_inv_li_product.VALUE_METHOD,
            lrec_trans_inv_li_product.PRICE_INDEX_ID,
            lrec_trans_inv_li_product.VAL_EXTRACT_TAG,
            lrec_trans_inv_li_product.QTY_EXTRACT_TAG,
            lrec_trans_inv_li_product.VAL_EXTRACT_TYPE,
            lrec_trans_inv_li_product.QTY_EXTRACT_TYPE,
            lrec_trans_inv_li_product.EXTR_VAL_NET_ZERO,
            lrec_trans_inv_li_product.EXTRACT_REVRS_VAL,
            lrec_trans_inv_li_product.EXTRACT_REVRS_QTY,
            ecdp_system_key.assignNextKeyValue('TRANS_INV_LI_PR_OVER'),
            lrec_trans_inv_li_product.Prorate_Line,
            lrec_trans_inv_li_product.PRORATE_IND
        );
   ELSE
        for def_val in default_values (p_trans_inventory_id,
                                       p_daytime,
                                       p_trans_inv_line,
                                       p_product_id,
                                       p_cost_type,
                                       p_contract_id) LOOP
          INSERT INTO TRANS_INV_LI_PR_OVER
           (OBJECT_ID ,
            DAYTIME ,
            END_DATE,
            EXEC_ORDER,
            CONTRACT_ID,
            trans_def_dimension,
            TAG,
            PRODUCT_ID,
            COST_TYPE,
            PRORATE_DIM_TO_PROD_ID,
            SEQ_NO,
            QTY_EXEC_ORDER,
            QTY_SOURCE_METHOD,
            VALUE_METHOD,
            --PRICE_INDEX,
            --VAL_EXTRACT_TAG,
            --QTY_EXTRACT_TAG,
            VAL_EXTRACT_TYPE,
            QTY_EXTRACT_TYPE,
            --EXTR_VAL_NET_ZERO,
            --EXTRACT_REVRS_VAL,
            --EXTRACT_REVRS_QTY,
            ID,
            PRORATE_LINE
            )
           VALUES
           (
            p_trans_inventory_id,
            p_from_date ,
            p_to_date,
            def_val.Val_Exec_Order,
            p_CONTRACT_ID,
            def_val.trans_def_dimension,
            def_val.line_TAG,
            p_product_id,
            p_cost_type,
            def_val.PRORATE_DIM_TO_PROD_ID,
            def_val.SEQ_NO,
            def_val.Exec_Order,
            def_val.Quantity_Source_Method,
            def_val.VALUE_METHOD,
            --def_val.PRICE_INDEX_ID,
            --def_val.VAL_EXTRACT_TAG,
            --def_val.QTY_EXTRACT_TAG,
            def_val.VAL_EXTRACT_TYPE,
            def_val.QTY_EXTRACT_TYPE,
            --def_val.EXTR_VAL_NET_ZERO,
            --def_val.EXTRACT_REVRS_VAL,
            --def_val.EXTRACT_REVRS_QTY,
            ecdp_system_key.assignNextKeyValue('TRANS_INV_LI_PR_OVER'),
            def_val.PRORATE_LINE
        );
        END LOOP;
   END IF;
RETURN 'Override Created';
END;





FUNCTION DimOrder(p_object_id VARCHAR2,
                  p_dimensions VARCHAR2,
                  p_daytime DATE) RETURN NUMBER
IS
     ln_return NUMBER;
     lv_dim1   VARCHAR2(1000);
     lv_dim2   VARCHAR2(1000);
     lv2_dimensions VARCHAR2(400);
     ln_dim1   NUMBER;
     ln_dim2   NUMBER := 0;
BEGIN
     lv2_dimensions := substr(p_dimensions,0,instr(p_dimensions,'|',-1)-1);

      if instr(lv2_dimensions, '|') = 0 then
         ln_dim1 :=  LENGTH(lv2_dimensions);
      else
         ln_dim1 :=  instr(lv2_dimensions,'|') - 1;
      end if;

     lv_dim1 :=
     substr(lv2_dimensions,
              1,
             ln_dim1);

        if instr(lv2_dimensions, '|') = 0 then
           ln_dim2 :=  LENGTH(lv2_dimensions);
        else
           ln_dim2 :=  instr(lv2_dimensions,'|') + 1;
        end if;

     lv_dim2 := substr(lv2_dimensions,ln_dim2);


     BEGIN
       IF ec_CNTR_ATTR_DIM_TYPE.attribute_type('TRANS_INV_DIM_1') = 'EC_CODE' THEN
            ln_dim1:= NVL( EC_PROsty_codes.sort_order(
                      lv_dim1,
                      ec_CNTR_ATTR_DIM_TYPE.attribute_syntax('TRANS_INV_DIM_1')),0);

         ELSE
             ln_dim1:= NVL( to_number(
                   EC_CNTR_ATTR_DIMENSION.attribute_string(p_object_id,'TRANS_INV_DIM_1',lv_dim1,p_DAYTIME,'<=')) ,1) ;
       END IF;
     EXCEPTION
       WHEN OTHERS THEN
         ln_dim1:= NVL( EC_CNTR_ATTR_DIMENSION.attribute_string(p_object_id,'TRANS_INV_DIM_1',lv_dim1,p_DAYTIME,'<=') ,1) ;
     END;

    IF lv_dim2 is not null then
      BEGIN
        IF ec_CNTR_ATTR_DIM_TYPE.attribute_type('TRANS_INV_DIM_2') = 'EC_CODE' THEN
            ln_dim2:= NVL( EC_PROsty_codes.SORT_ORDER(
                      lv_dim2,
                      ec_CNTR_ATTR_DIM_TYPE.attribute_syntax('TRANS_INV_DIM_2')),0);

         ELSE
               ln_dim2 :=  NVL(  to_number(EC_CNTR_ATTR_DIMENSION.attribute_string(p_object_id,'TRANS_INV_DIM_2',lv_dim2,p_DAYTIME,'<=')),0) ;
        END IF;
     EXCEPTION
       WHEN OTHERS THEN

        ln_dim2 :=  NVL(  (EC_CNTR_ATTR_DIMENSION.attribute_string(p_object_id,'TRANS_INV_DIM_2',lv_dim2,p_DAYTIME,'<=')),0) ;
      END;
    END IF;

    ln_return := ln_dim1 ;

    IF ln_dim2 != 0 THEN

      ln_return := ln_return + 1/ ln_dim2 ;

    END IF;

    return ln_return;

END;
-------------------------
FUNCTION SortOrder(p_sort_order           NUMBER,
                   p_dimension_tag        VARCHAR2,
                   p_layer_month          DATE ,
                   p_prod_stream_id       VARCHAR2,
                   p_daytime              DATE) RETURN NUMBER
IS
lv_sort_order  NUMBER;
lv_dimorder    NUMBER;
lv_prod_date   DATE;
BEGIN
  lv_dimorder:= DimOrder(p_prod_stream_id,p_DIMENSION_TAG,p_daytime);
begin
  lv_prod_date:=to_date(substr(p_dimension_tag,instr(p_dimension_tag,'|',-1)+1),'YYYY-MM-DD"T"HH24:MI:SS');
end;

  lv_sort_order:= p_sort_order + to_number(to_char(p_layer_month,'YYYYMM'))/1000000 + to_number(to_char(lv_prod_date,'YYYYMM'))/1000000000000 + lv_dimorder/100000000000000000;


 return lv_sort_order;
exception
  when others
    then
     lv_prod_date:= Ecdp_Timestamp.getCurrentSysdate;
      lv_sort_order:= p_sort_order + to_number(to_char(p_layer_month,'YYYYMM'))/1000000 + to_number(to_char(lv_prod_date,'YYYYMM'))/1000000000000 + lv_dimorder/100000000000000000;


 return lv_sort_order;

  END;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : IsTransInvSummaryValid
-- Description    : Run upon insert/update inside popupscreen for inventory summaries inside screen Transactional Inventory Stream Setup
--                : Function consider mainly date issues that are not covered by class/table keys/constraints.
-- Preconditions  :
-- Postconditions :
-- Using tables   : trans_inventory_version, contract_version
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      : Run from class trigger action
-----------------------------------------------------------------------------------------------------
PROCEDURE IsTransInvSummaryValid(p_trans_inv_id   VARCHAR2,
                                 p_prod_stream_id VARCHAR2,
                                 p_start_date     DATE,
                                 p_end_date       DATE)

 IS

  valid                BOOLEAN := FALSE;
  valid_trans_inv_conn BOOLEAN := FALSE;
  lrec_ti              trans_inventory_version%rowtype;
  lrec_tip             contract_version%rowtype;
  invalid_connection      EXCEPTION;
  invalid_prod_stream     EXCEPTION;
  invalid_trans_inventory EXCEPTION;

  CURSOR ti_conn IS
    SELECT 1
      FROM trans_inv_prod_stream tips
     WHERE tips.object_id = p_prod_stream_id
       AND tips.inventory_id = p_trans_inv_id
       AND tips.daytime <= p_start_date
       AND NVL(tips.end_date, p_start_date + 1) > p_start_date
       AND tips.daytime < NVL(p_end_date, tips.daytime + 1)
       AND NVL(tips.end_date, DATE '2900-01-01' + 1) >
           NVL(p_end_date, DATE '2900-01-01');

BEGIN

  -- Evaluate trans inventory
  lrec_ti := ec_trans_inventory_version.row_by_pk(p_trans_inv_id,
                                                  p_start_date,
                                                  '<=');
  IF lrec_ti.object_id IS NOT NULL THEN

    -- Fetch again using end date if present
    IF p_end_date IS NOT NULL THEN
      lrec_ti := ec_trans_inventory_version.row_by_pk(p_trans_inv_id,
                                                      p_end_date,
                                                      '<=');
    END IF;
    -- Trans inventory is valid for start date and end date
    IF lrec_ti.object_id IS NOT NULL THEN

      -- Next: evaluate product stream
      lrec_tip := ec_contract_version.row_by_pk(p_prod_stream_id,
                                                p_start_date,
                                                '<=');
      IF lrec_tip.object_id IS NOT NULL THEN

        -- Fetch again using end date if present
        IF p_end_date IS NOT NULL THEN
          lrec_tip := ec_contract_version.row_by_pk(p_prod_stream_id,
                                                    p_end_date,
                                                    '<=');
        END IF;

        -- Trans inventory is valid for start date and end date
        IF lrec_tip.object_id IS NOT NULL THEN
          valid := TRUE;
        ELSE
          RAISE invalid_prod_stream;
        END IF;
      ELSE
        RAISE invalid_prod_stream;
      END IF;
    ELSE
      RAISE invalid_trans_inventory;
    END IF;

  ELSE
    RAISE invalid_trans_inventory;
  END IF;

  -- Check to see if a valid transaction inventory / product stream connection exists
  FOR r IN ti_conn LOOP
    valid_trans_inv_conn := TRUE;
  END LOOP;

  IF NOT valid_trans_inv_conn THEN
    RAISE invalid_connection;
  END IF;

EXCEPTION
  WHEN invalid_connection THEN
    raise_application_error(-20001,
                            'Could not find a valid transaction inventory product stream connection for [' ||
                            ec_trans_inventory.object_code(p_trans_inv_id) || '/' || ec_contract.object_code(p_prod_stream_id) ||
                            ']\n\n');
  WHEN invalid_trans_inventory THEN
    raise_application_error(-20001,
                            'Transaction Inventory ['||
                            ec_trans_inventory.object_code(p_trans_inv_id) ||
                             '] is not valid throughout selected period.\n\n');
  WHEN invalid_prod_stream THEN
    raise_application_error(-20001,
                            'Product Stream ['||
                            ec_contract.object_code(p_prod_stream_id) ||
                             '] is not valid throughout selected period.\n\n');

END IsTransInvSummaryValid;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : UpdTransInvSummary
-- Description    : Set end date on previous version of otherwise same record
-- Preconditions  :
-- Postconditions :
-- Using tables   : trans_inv_summary_item
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      : Run from class trigger action
-----------------------------------------------------------------------------------------------------
PROCEDURE UpdTransInvSummary(p_trans_inv_id       VARCHAR2,
                             p_prod_stream_id     VARCHAR2,
                             p_src_trans_inv_id   VARCHAR2,
                             p_src_prod_stream_id VARCHAR2,
                             p_src_trans_inv_line VARCHAR2,
                             p_start_date         DATE,
                             p_end_date           DATE) IS

  -- Same record except for earlier daytime and end date being null
  CURSOR s IS
    SELECT *
      FROM trans_inv_summary_item i
     WHERE i.object_id = p_prod_stream_id
       AND i.trans_inv_id = p_trans_inv_id
       AND i.source_prod_stream_id = p_src_prod_stream_id
       AND i.source_trans_inv_id = p_src_trans_inv_id
       AND i.source_trans_inv_line = p_src_trans_inv_line
       AND i.daytime =
           (SELECT MAX(ii.daytime)
              FROM trans_inv_summary_item ii
             WHERE ii.object_id = i.object_id
               AND ii.trans_inv_id = i.trans_inv_id
               AND ii.source_prod_stream_id = i.source_prod_stream_id
               AND ii.source_trans_inv_id = i.source_trans_inv_id
               AND ii.source_trans_inv_line = i.source_trans_inv_line
               AND ii.daytime < p_start_date
               AND ii.end_date IS NULL);

BEGIN

  FOR r IN s LOOP

    UPDATE trans_inv_summary_item iu
       SET iu.end_date = p_start_date
     WHERE iu.object_id = p_prod_stream_id
       AND iu.trans_inv_id = p_trans_inv_id
       AND iu.source_prod_stream_id = p_src_prod_stream_id
       AND iu.source_trans_inv_id = p_src_trans_inv_id
       AND iu.source_trans_inv_line = p_src_trans_inv_line
       AND iu.daytime = r.daytime;

  END LOOP;

END UpdTransInvSummary;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : UpdTransInvProdStream
-- Description    : Returns error if dates are changed where summaries are present.
-- Preconditions  :
-- Postconditions :
-- Using tables   : trans_inv_prod_stream
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      : Run from class trigger action on date change.
-----------------------------------------------------------------------------------------------------
PROCEDURE UpdTransInvProdStream(p_trans_inv_id   VARCHAR2,
                                p_prod_stream_id VARCHAR2,
                                p_start_date     DATE,
                                p_end_date       DATE) IS

  -- Summary items that are invalidated on the dates used.
  CURSOR s IS
    SELECT *
      FROM trans_inv_summary_item i
     WHERE i.object_id = p_prod_stream_id
       AND i.trans_inv_id = p_trans_inv_id
       AND (i.Daytime < p_start_date OR
           i.daytime > NVL(p_end_date, i.daytime));


  invalid_update EXCEPTION;
BEGIN

  FOR r IN s LOOP
    RAISE invalid_update;
  END LOOP;

EXCEPTION
  WHEN invalid_update THEN
    raise_application_error(-20001,
                            'Cannot change dates on records such that summary items get invalidated.\n\n');

END UpdTransInvProdStream;

PROCEDURE DeleteCalc(p_calc_run_no NUMBER) IS
  -- Find where PP Calc no is Blend, Get PP Prev key which is last ran calc for blend, update calc on
  cursor c_Trans(cp_calc_run_no number) is
  select key, calc_run_no,pp_prev_key,PP_CALC_NO
    from trans_inventory_trans
   where pp_calc_no = p_calc_run_no;

  -- Find where the PP Calc no is blend, Get PP Prev Key which is id of ingored ID, update calc no
  cursor c_Balance(cp_calc_run_no number) is
  select key, calc_run_no,pp_prev_key,PP_CALC_NO
    from trans_inventory_balance
   where pp_calc_no = p_calc_run_no;

  BEGIN
    for tr in c_Trans(p_calc_run_no) loop

      update trans_inventory_trans set calc_run_no = abs(calc_run_no) where pp_calc_no = tr.pp_prev_key and calc_run_no<0;
      delete from trans_inventory_trans where pp_calc_no = p_calc_run_no;
    end loop;

    for bl in c_Balance(p_calc_run_no) loop
        update trans_inventory_balance set calc_run_no = abs(calc_run_no)  where key = bl.pp_prev_key  and calc_run_no<0;
        delete from trans_inventory_balance where pp_calc_no = p_calc_run_no;
    end loop;

END DeleteCalc;
-----------------------------------------------------------------------------------------------------
-- Function       : Exist_TransInvSummaryItem
-- Description    : Returns error if tried to delete inventory from Transactional Inventory Stream Setup screen and inventory is having Inventory Summaries.
-- Preconditions  :
-- Postconditions :
-- Using tables   : TRANS_INV_SUMMARY_ITEM
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      : Run from class trigger action .
-----------------------------------------------------------------------------------------------------
FUNCTION Exist_TransInvSummaryItem(p_object_id VARCHAR2,
                  p_trans_inventory_id VARCHAR2,
                  p_daytime DATE) RETURN VARCHAR2
IS
lv_msg VARCHAR2(2000);
CURSOR summary_items IS
SELECT DISTINCT daytime
   FROM TRANS_INV_SUMMARY_ITEM
  WHERE OBJECT_ID = p_object_id
    AND TRANS_INV_ID = p_trans_inventory_id;

BEGIN
lv_msg:=NULL;

FOR si IN summary_items
  LOOP

    lv_msg:=lv_msg ||si.daytime||',';
    END LOOP;

IF lv_msg IS NULL THEN
  RETURN 'N';
  ELSE
    RETURN SUBSTR(lv_msg,1,length(lv_msg)-1);
    END IF;

END;
-----------------------------------------------------------------------------------------------------
-- Function       : Exist_TransInvPosting
-- Description    : Returns error if tried to delete inventory from Transactional Inventory Stream Setup screen and inventory is having Inventory postings.
-- Preconditions  :
-- Postconditions :
-- Using tables   : TRANS_INV_LI_PR_CNTRACC
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      : Run from class trigger action .
-----------------------------------------------------------------------------------------------------
FUNCTION Exist_TransInvPosting(p_object_id VARCHAR2,
                  p_trans_inventory_id VARCHAR2,
                  p_daytime DATE
                 ) RETURN VARCHAR2
IS
lv_cnt NUMBER;
lv_product_id VARCHAR2(100);
lv_msg VARCHAR2(2000);

CURSOR Inv_posting IS
SELECT ec_product_version.name(product_id,daytime,'<=') || ' ' || ec_prosty_codes.code_text(COST_TYPE,'PRODUCT_COST_TYPE')  || ' (' ||daytime|| ')'  prod
 FROM TRANS_INV_LI_PR_CNTRACC
  WHERE p_daytime <= daytime
  AND OBJECT_ID = p_trans_inventory_id
  AND PROD_STREAM_ID = p_object_id
  AND LINE_TAG = 'TRANS_INVENTORY';

BEGIN
lv_msg:=NULL;

FOR cost_type IN Inv_posting
  LOOP

    lv_msg:=lv_msg ||cost_type.prod||',';
    END LOOP;

IF lv_msg IS NULL THEN
  RETURN 'N';
  ELSE
    RETURN SUBSTR(lv_msg,1,length(lv_msg)-1);
    END IF;

END;
-----------------------------------------------------------------------------------------------------
-- Function       : Exist_TransInvLinePosting
-- Description    : Returns error if tried to delete inventory from Transactional Inventory Stream Setup screen and inventory is having Line postings.
-- Preconditions  :
-- Postconditions :
-- Using tables   : TRANS_INV_LI_PR_CNTRACC
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      : Run from class trigger action .
-----------------------------------------------------------------------------------------------------
FUNCTION Exist_TransInvLinePosting(p_object_id                      VARCHAR2,
                                   p_trans_inventory_id             VARCHAR2,
                                   p_start_date                     DATE DEFAULT NULL,
                                   p_tag                            VARCHAR2 DEFAULT NULL,
                                   p_end_date                       DATE DEFAULT NULL,
                                   p_product_id                     VARCHAR2 DEFAULT NULL,
                                   p_cost_type                      VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
IS
lv_cnt NUMBER;
lv_product_id VARCHAR2(100);
lv_msg VARCHAR2(2000);

CURSOR InvLine IS
SELECT DISTINCT NVL(ec_trans_inv_line.name(tiv.config_template,tilpc.daytime,tilpc.line_tag,'<='),ec_trans_inv_line.name(tilpc.OBJECT_ID,tilpc.daytime,tilpc.line_tag,'<=')) line_name,line_tag,tilpc.OBJECT_ID inv_id,tilpc.PROD_STREAM_ID proj_id
 FROM TRANS_INV_LI_PR_CNTRACC tilpc,TRANS_INVENTORY_VERSION tiv
  WHERE  (tilpc.OBJECT_ID IN (SELECT object_id FROM ov_trans_inventory where config_template_id = p_trans_inventory_id) OR tilpc.OBJECT_ID=p_trans_inventory_id)
    AND tilpc.PROD_STREAM_ID = NVL(p_object_id,tilpc.PROD_STREAM_ID)
    AND tilpc.LINE_TAG <> 'TRANS_INVENTORY'
    AND tiv.object_id=tilpc.object_id
    AND tiv.daytime <=tilpc.daytime
    AND NVL(tiv.end_date,tilpc.daytime+1)>tilpc.daytime
    AND tilpc.daytime >= NVL(p_start_date,tilpc.daytime)
    AND tilpc.daytime <= NVL(p_end_date,tilpc.daytime)
    AND (tilpc.end_date < NVL(p_end_date,tilpc.end_date+1) OR tilpc.end_date IS NULL )
    AND tilpc.LINE_TAG =NVL(p_tag,tilpc.LINE_TAG)
    AND tilpc.product_id=NVL(p_product_id,tilpc.product_id)
    AND tilpc.cost_type=NVL(p_cost_type,tilpc.cost_type);


CURSOR InvLinePosting(cp_line_tag VARCHAR2,cp_trans_inventory_id VARCHAR2 DEFAULT NULL,cp_object_id VARCHAR2 DEFAULT NULL) IS
SELECT ec_product_version.name(product_id,daytime,'<=') || ' ' || ec_prosty_codes.code_text(COST_TYPE,'PRODUCT_COST_TYPE')|| ' (' ||daytime|| ')' prod_val
 FROM TRANS_INV_LI_PR_CNTRACC
  WHERE daytime >= NVL(p_start_date,daytime)
    AND daytime <= NVL(p_end_date,daytime)
    AND (end_date < NVL(p_end_date,end_date+1) OR end_date IS NULL )
    AND OBJECT_ID = NVL(cp_trans_inventory_id,OBJECT_ID)
    AND PROD_STREAM_ID = NVL(cp_object_id,PROD_STREAM_ID)
    AND LINE_TAG =cp_line_tag
    AND product_id=NVL(p_product_id,product_id)
    AND cost_type=NVL(p_cost_type,cost_type);


BEGIN
lv_msg:=NULL;
IF p_object_id IS NOT NULL THEN
FOR line IN InvLine
  LOOP
    IF lv_msg IS NOT NULL THEN
      lv_msg:=SUBSTR(lv_msg,1,length(lv_msg)-1)||chr(10)||'Line: '||line.line_name||chr(10)||'Product Set Item: ';
      ELSE
    lv_msg:=lv_msg||'Line: '||line.line_name||chr(10)||'Product Set Item: ';
    END IF;

   FOR prod IN InvLinePosting(line.line_tag,p_trans_inventory_id,p_object_id)

      LOOP
        lv_msg:=lv_msg ||prod.prod_val||',';
        END LOOP;

    END LOOP;
ELSE
FOR line IN InvLine
  LOOP

   FOR prod IN InvLinePosting(line.line_tag,line.inv_id,line.proj_id)

      LOOP
        lv_msg:=lv_msg ||ec_contract_version.name(line.proj_id,p_start_date,'<=')||' / '||ec_trans_inventory_version.name(line.inv_id,p_start_date,'<=') ||' / '||line.line_name||' / '||prod.prod_val||'\n';
        END LOOP;

    END LOOP;

END IF;

IF lv_msg IS NULL THEN
  RETURN 'N';
  ELSIF SUBSTR(lv_msg,-2)='\n' THEN
    RETURN SUBSTR(lv_msg,1,length(lv_msg)-2);
    ELSE
      RETURN SUBSTR(lv_msg,1,length(lv_msg)-1);
    END IF;

END;
-----------------------------------------------------------------------------------------------------
-- Function       : Exist_LineOverride
-- Description    : Returns error if tried to delete inventory line from Transactional Inventory Template screen and line is overriden.
-- Preconditions  :
-- Postconditions :
-- Using tables   : TRANS_INV_LINE_OVERRIDE
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      : Run from class trigger action .
-----------------------------------------------------------------------------------------------------
FUNCTION Exist_LineOverride(p_line_tag                  VARCHAR2,
                            p_object_id                 VARCHAR2,
                            p_start_date                DATE DEFAULT NULL,
                            p_end_date                  DATE DEFAULT NULL
                            ) RETURN VARCHAR2
IS
lv_cnt NUMBER;
lv_product_id VARCHAR2(100);
lv_msg VARCHAR2(2000);


CURSOR LineOverride IS
 SELECT EcDp_objects.GetObjName(til.contract_id,til.daytime) Prod_stream,EcDp_objects.GetObjName(til.object_id,til.daytime) Trans_inventory,til.daytime
 FROM TRANS_INV_LINE_OVERRIDE til,trans_inventory_version ti where til.tag=p_line_tag
  AND ti.object_id=til.object_id
  AND ti.config_template=p_object_id
  AND ti.daytime <=til.daytime
  AND NVL(ti.end_date,til.daytime+1)>til.daytime
  AND til.daytime >= NVL(p_start_date,til.daytime)
  AND til.daytime <= NVL(p_end_date,til.daytime)
  AND (til.end_date < NVL(p_end_date,til.end_date+1) OR til.end_date IS NULL );



BEGIN
lv_msg:=NULL;


  FOR lo IN LineOverride

      LOOP
        IF lv_msg IS NOT NULL THEN
           lv_msg:=lv_msg ||chr(10);
         END IF;
        lv_msg:=lv_msg ||lo.Prod_stream||' / '||lo.Trans_inventory||'('||lo.daytime||')';
        END LOOP;

IF lv_msg IS NULL THEN
  RETURN 'N';
  ELSE
    RETURN lv_msg;
    END IF;

END;
-----------------------------------------------------------------------------------------------------
-- Function       : Exist_ProductOverride
-- Description    : Returns error if tried to delete Product from Transactional Inventory Template screen and Product is overriden.
-- Preconditions  :
-- Postconditions :
-- Using tables   : TRANS_INV_LI_PR_OVER
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      : Run from class trigger action .
-----------------------------------------------------------------------------------------------------
FUNCTION Exist_ProductOverride(p_line_tag                  VARCHAR2,
                               p_object_id                 VARCHAR2,
                               p_product_id                VARCHAR2 DEFAULT NULL,
                               p_cost_type                 VARCHAR2 DEFAULT NULL,
                               p_start_date                DATE DEFAULT NULL,
                               p_end_date                  DATE DEFAULT NULL
                               ) RETURN VARCHAR2
IS
lv_cnt NUMBER;
lv_product_id VARCHAR2(100);
lv_msg VARCHAR2(2000);


CURSOR ProdOverride IS
SELECT EcDp_objects.GetObjName(tilpo.contract_id,tilpo.daytime) Prod_stream,EcDp_objects.GetObjName(tilpo.object_id,tilpo.daytime) Trans_inventory,ec_trans_inv_line.name(tiv.config_template,tilpo.daytime,tilpo.tag,'<=') tag_name,tilpo.daytime,
ec_product_version.name(tilpo.product_id,tilpo.daytime,'<=') || ' ' || ec_prosty_codes.code_text(tilpo.COST_TYPE,'PRODUCT_COST_TYPE')|| ' (' ||tilpo.daytime|| ')' prod_val
 FROM TRANS_INV_LI_PR_OVER tilpo,TRANS_INVENTORY_VERSION tiv
 WHERE tilpo.tag=p_line_tag
  AND tilpo.product_id=NVL(p_product_id,tilpo.product_id)
  AND tilpo.cost_type=NVL(p_cost_type,tilpo.cost_type)
  AND tiv.object_id=tilpo.object_id
  AND tiv.config_template=p_object_id
  AND tiv.daytime <=tilpo.daytime
  AND NVL(tiv.end_date,tilpo.daytime+1)>tilpo.daytime
  AND tilpo.daytime >= NVL(p_start_date,tilpo.daytime)
  AND tilpo.daytime <= NVL(p_end_date,tilpo.daytime)
  AND (tilpo.end_date < NVL(p_end_date,tilpo.end_date+1) OR tilpo.end_date IS NULL);


BEGIN
lv_msg:=NULL;

  FOR po IN ProdOverride

      LOOP
        IF lv_msg IS NOT NULL THEN
           lv_msg:=lv_msg ||chr(10);
         END IF;
        lv_msg:=lv_msg ||po.Prod_stream||' / '||po.Trans_inventory||' / '||po.tag_name||' / '||po.prod_val;
        END LOOP;

IF lv_msg IS NULL THEN
  RETURN 'N';
  ELSE
    RETURN lv_msg;
    END IF;

END;

-----------------------------------------------------------------------------------------------------
-- Function       : Exist_TransInvLineProdVar
-- Description    : Returns error if tried to delete inventory from Transactional Inventory Stream Setup screen and inventory is having product variables.
-- Preconditions  :
-- Postconditions :
-- Using tables   : TRANS_INV_LI_PR_VAR
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      : Run from class trigger action .
-----------------------------------------------------------------------------------------------------
FUNCTION Exist_TransInvLineProdVar(p_object_id                      VARCHAR2,
                                   p_trans_inventory_id             VARCHAR2,
                                   p_start_date                     DATE DEFAULT NULL,
                                   p_tag                            VARCHAR2 DEFAULT NULL,
                                   p_end_date                       DATE DEFAULT NULL,
                                   p_product_id                     VARCHAR2 DEFAULT NULL,
                                   p_cost_type                      VARCHAR2 DEFAULT NULL
                                   ) RETURN VARCHAR2
IS
lv_cnt NUMBER;
lv_product_id VARCHAR2(100);
lv_msg VARCHAR2(2000);

CURSOR Linetag IS
SELECT DISTINCT NVL(ec_trans_inv_line.name(tiv.config_template,tilpv.daytime,tilpv.line_tag,'<='),ec_trans_inv_line.name(tilpv.OBJECT_ID,tilpv.daytime,tilpv.line_tag,'<=')) line_name,tilpv.line_tag,tilpv.OBJECT_ID inv_id,tilpv.PROD_STREAM_ID proj_id
 FROM TRANS_INV_LI_PR_VAR tilpv,TRANS_INVENTORY_VERSION tiv
  WHERE (tilpv.OBJECT_ID IN (SELECT object_id FROM ov_trans_inventory where config_template_id = p_trans_inventory_id) OR tilpv.OBJECT_ID=p_trans_inventory_id)
    AND tilpv.PROD_STREAM_ID = NVL(p_object_id,tilpv.PROD_STREAM_ID)
    AND tiv.object_id=tilpv.object_id
    AND tiv.daytime <=tilpv.daytime
    AND NVL(tiv.end_date,tilpv.daytime+1)>tilpv.daytime
    AND tilpv.daytime >= NVL(p_start_date,tilpv.daytime)
    AND tilpv.daytime <= NVL(p_end_date,tilpv.daytime)
    AND (tilpv.end_date < NVL(p_end_date,tilpv.end_date+1) OR tilpv.end_date IS NULL )
    AND tilpv.LINE_TAG =NVL(p_tag,tilpv.LINE_TAG)
    AND tilpv.product_id=NVL(p_product_id,tilpv.product_id)
    AND tilpv.cost_type=NVL(p_cost_type,tilpv.cost_type);


CURSOR ProdVar(cp_line_tag VARCHAR2,cp_trans_inventory_id VARCHAR2 DEFAULT NULL,cp_object_id VARCHAR2 DEFAULT NULL) IS
SELECT DISTINCT ec_product_version.name(product_id,daytime,'<=') || ' ' || ec_prosty_codes.code_text(COST_TYPE,'PRODUCT_COST_TYPE')|| ' (' ||daytime|| ')' prod_val
 FROM TRANS_INV_LI_PR_VAR
  WHERE daytime >= NVL(p_start_date,daytime)
    AND daytime <= NVL(p_end_date,daytime)
    AND (end_date < NVL(p_end_date,end_date+1) OR end_date IS NULL )
    AND OBJECT_ID = NVL(cp_trans_inventory_id,OBJECT_ID)
    AND PROD_STREAM_ID = NVL(cp_object_id,PROD_STREAM_ID)
    AND LINE_TAG =cp_line_tag
    AND product_id=NVL(p_product_id,product_id)
    AND cost_type=NVL(p_cost_type,cost_type);


BEGIN
lv_msg:=NULL;

IF p_object_id IS NOT NULL THEN
  FOR line IN Linetag
    LOOP
      IF lv_msg IS NOT NULL THEN
        lv_msg:=SUBSTR(lv_msg,1,length(lv_msg)-1)||chr(10)||'Line: '||line.line_name||chr(10)||'Product Set Item: ';
        ELSE
      lv_msg:=lv_msg||'Line: '||line.line_name||chr(10)||'Product Set Item: ';
      END IF;
      FOR prod IN ProdVar(line.line_tag,p_trans_inventory_id,p_object_id)

      LOOP
        lv_msg:=lv_msg ||prod.prod_val||',';
        END LOOP;

      END LOOP;
ELSE
  FOR line IN Linetag
    LOOP
      FOR prod IN ProdVar(line.line_tag,line.inv_id,line.proj_id)
          LOOP
          lv_msg:=lv_msg ||ec_contract_version.name(line.proj_id,p_start_date,'<=')||' / '||ec_trans_inventory_version.name(line.inv_id,p_start_date,'<=') ||' / '||line.line_name||' / '||prod.prod_val||'\n';
          END LOOP;
     END LOOP;
END IF;

IF lv_msg IS NULL THEN
  RETURN 'N';
   ELSIF SUBSTR(lv_msg,-2)='\n' THEN
    RETURN SUBSTR(lv_msg,1,length(lv_msg)-2);
    ELSE
      RETURN SUBSTR(lv_msg,1,length(lv_msg)-1);
END IF;

END;
-----------------------------------------------------------------------------------------------------
-- Function       : Exist_TransInvMessages
-- Description    : Returns error if tried to delete inventory from Transactional Inventory Stream Setup screen and inventory is having messages.
-- Preconditions  :
-- Postconditions :
-- Using tables   : TRANS_INV_MSG
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      : Run from class trigger action .
-----------------------------------------------------------------------------------------------------
FUNCTION Exist_TransInvMessages(p_object_id VARCHAR2,
                  p_trans_inventory_id VARCHAR2,
                  p_daytime DATE
                 ) RETURN VARCHAR2

IS
lv_msg VARCHAR2(2000);
CURSOR TransInvMsg IS
 SELECT DISTINCT daytime
   FROM TRANS_INV_MSG
  WHERE  OBJECT_ID = p_trans_inventory_id
    AND PROD_STREAM_ID = p_object_id;


BEGIN
lv_msg:=NULL;

FOR tim IN TransInvMsg
  LOOP

    lv_msg:=lv_msg ||tim.daytime||',';
    END LOOP;

IF lv_msg IS NULL THEN
  RETURN 'N';
  ELSE
    RETURN SUBSTR(lv_msg,1,length(lv_msg)-1);
    END IF;

END;
-----------------------------------------------------------------------------------------------------
-- Function       : PreDeleteInventoryTest
-- Description    : Checks is there any data related to inventory before delete.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      : Run from class trigger action .
-----------------------------------------------------------------------------------------------------
FUNCTION PreInventoryDeleteTest(p_object_id                       VARCHAR2,
                                p_trans_inventory_id              VARCHAR2,
                                p_daytime                         DATE
                                ) RETURN VARCHAR2
IS
lv_end_user_message VARCHAR2(4000);

BEGIN
IF Ecdp_Trans_Inventory.Exist_TransInvSummaryItem(p_object_id,p_trans_inventory_id,p_daytime)<>'N' THEN
      lv_end_user_message:='Referenced Invetory is having Summaries.Click on '||chr(39)||'Inventory Summaries'||chr(39)|| ' button to be able to delete.Following are dates for which Summary Items are added'||chr(10)||Ecdp_Trans_Inventory.Exist_TransInvSummaryItem(p_object_id,p_trans_inventory_id,p_daytime);
       ELSIF ecdp_trans_inventory.Exist_TransInvMessages(p_object_id,p_trans_inventory_id,p_daytime)<>'N' THEN
       lv_end_user_message:='Referenced Invetory is having Messages.Click on '||chr(39)||'Log Messages'||chr(39)|| ' button to be able to delete.Following are dates for which Messages are added'||chr(10)||ecdp_trans_inventory.Exist_TransInvMessages(p_object_id,p_trans_inventory_id,p_daytime);
       ELSIF  ecdp_trans_inventory.Exist_TransInvPosting(p_object_id,p_trans_inventory_id,p_daytime)<>'N' THEN
       lv_end_user_message:='Referenced Invetory is having Inventory Postings.Click on '||chr(39)||'Inventory Postings'||chr(39)|| ' button to be able to delete.'||chr(10)||'Following are Product Set Item having Postings:'||chr(10)||ecdp_trans_inventory.Exist_TransInvPosting(p_object_id,p_trans_inventory_id,p_daytime);
       ELSIF  ecdp_trans_inventory.Exist_TransInvLinePosting(p_object_id,p_trans_inventory_id,p_daytime)<>'N' THEN
       lv_end_user_message:='Referenced Invetory is having Inventory Line Postings.Click on '||chr(39)||'Line Postings'||chr(39)|| ' button to be able to delete.'||chr(10)||'Following are Lines and Product Set Items having Postings:'||chr(10)||ecdp_trans_inventory.Exist_TransInvLinePosting(p_object_id,p_trans_inventory_id,p_daytime);
       ELSIF ecdp_trans_inventory.Exist_TransInvLineProdVar(p_object_id,p_trans_inventory_id,p_daytime)<>'N' THEN
       lv_end_user_message:='Referenced Invetory is having Product Variables.Click on '||chr(39)||'Product Variables'||chr(39)|| ' button to be able to delete.'||chr(10)||'Following are Lines and Product Set Items having Variables:'||chr(10)||ecdp_trans_inventory.Exist_TransInvLineProdVar(p_object_id,p_trans_inventory_id,p_daytime);
       ELSE
       lv_end_user_message:='N';
 END IF;

 RETURN lv_end_user_message;

END;


FUNCTION verifyAction(p_calc_run_no VARCHAR2) RETURN VARCHAR2 IS

    lrec_calc_ref calc_reference%rowtype;

  BEGIN
    lrec_calc_ref   := ec_calc_reference.row_by_pk(p_calc_run_no);

    --Hide records being replaced
    update trans_inventory_trans t
       set calc_run_no = abs(calc_run_no) * -1
     where calc_run_no > 0
       and t.pp_calc_no in
           (select run_no
              from calc_reference cr
             where daytime = lrec_calc_ref.daytime
               and cr.calculation_id = lrec_calc_ref.calculation_id
               and NVL(cr.accrual_ind, 'N') =
                   NVL(lrec_calc_ref.accrual_ind, 'N')
               and cr.object_id = lrec_calc_ref.object_id
               and lrec_calc_ref.run_no > cr.run_no
               and accept_status in ('A', 'V'))
               and abs(calc_run_no) != lrec_calc_ref.run_no;

    update trans_inventory_trans t
       set calc_run_no = abs(calc_run_no) * -1
     where calc_run_no > 0
       and t.key in
           (select pp_prev_key
              from trans_inventory_trans tit
             where lrec_calc_ref.run_no = pp_calc_no
               and pp_prev_key is not null)
               and abs(calc_run_no) != lrec_calc_ref.run_no;


    --Make records inserted from the calc to official
    update trans_inventory_balance
       set calc_run_no = calc_run_no * -1
     where calc_run_no > 0
       and pp_calc_no in
           (select run_no
              from calc_reference cr
             where daytime = lrec_calc_ref.daytime
               and cr.calculation_id = lrec_calc_ref.calculation_id
               and NVL(cr.accrual_ind, 'N') =
                   NVL(lrec_calc_ref.accrual_ind, 'N')
               and cr.object_id = lrec_calc_ref.object_id
               and lrec_calc_ref.run_no > cr.run_no
               and accept_status in ('A', 'V'))
               and abs(calc_run_no) != lrec_calc_ref.run_no;


    update trans_inventory_balance t
       set calc_run_no = abs(calc_run_no) * -1
     where calc_run_no > 0
       and t.key in
           (select pp_prev_key
              from trans_inventory_balance tit
             where lrec_calc_ref.run_no = pp_calc_no
               and pp_prev_key is not null)
               and abs(calc_run_no) != lrec_calc_ref.run_no;


    -- Setting official calc to be valid
    update trans_inventory_balance
       set calc_run_no = abs(calc_run_no)
     where pp_calc_no = lrec_calc_ref.run_no
       and nvl(to_char(pp_calc_no), 'x') != to_char(abs(calc_run_no));

    update trans_inventory_trans
       set calc_run_no = abs(calc_run_no)
     where pp_calc_no = lrec_calc_ref.run_no
       and nvl(to_char(pp_calc_no), 'x') != to_char(abs(calc_run_no));

  RETURN NULL;
END verifyAction;

FUNCTION unverifyAction(p_calc_run_no VARCHAR2) RETURN VARCHAR2 IS
    lrec_calc_ref calc_reference%rowtype;


  BEGIN
    lrec_calc_ref   := ec_calc_reference.row_by_pk(p_calc_run_no);

    update trans_inventory_trans set calc_run_no = ABS(calc_run_no) where key in
    (select pp_prev_key
              from trans_inventory_trans tit
             where lrec_calc_ref.run_no = pp_calc_no
               and pp_prev_key is not null)
               and abs(calc_run_no) != lrec_calc_ref.run_no;


    update trans_inventory_trans set calc_run_no = ABS(calc_run_no) where pp_calc_no in
    (select max(run_no) from calc_reference cr where daytime = lrec_calc_ref.daytime
            and cr.calculation_id = lrec_calc_ref.calculation_id
         and NVL(cr.accrual_ind,'N') = NVL(lrec_calc_ref.accrual_ind,'N')
         and cr.object_id = lrec_calc_ref.object_id
         and lrec_calc_ref.run_no != cr.run_no
         and accept_status in ('A','V') )
         and abs(calc_run_no) != lrec_calc_ref.run_no;

    update trans_inventory_balance set calc_run_no = ABS(calc_run_no) where key in
    (select pp_prev_key
              from trans_inventory_balance tib
             where lrec_calc_ref.run_no = pp_calc_no
               and pp_prev_key is not null)
               and abs(calc_run_no) != lrec_calc_ref.run_no;

    update trans_inventory_balance set calc_run_no = ABS(calc_run_no) where pp_calc_no in
    (select MAX(run_no) from calc_reference cr where daytime = lrec_calc_ref.daytime
            and cr.calculation_id = lrec_calc_ref.calculation_id
         and NVL(cr.accrual_ind,'N') = NVL(lrec_calc_ref.accrual_ind,'N')
         and cr.object_id = lrec_calc_ref.object_id
         and lrec_calc_ref.run_no != cr.run_no
         and accept_status in ('A','V'))
         and abs(calc_run_no) != lrec_calc_ref.run_no;




    update trans_inventory_balance set calc_run_no = abs(calc_run_no)*-1 where pp_calc_no = lrec_calc_ref.run_no and nvl(to_char(pp_calc_no),'x')!=to_char(abs(calc_run_no)) ;
    update trans_inventory_trans set calc_run_no = abs(calc_run_no)*-1 where pp_calc_no = lrec_calc_ref.run_no and nvl(to_char(pp_calc_no),'x')!=to_char(abs(calc_run_no));

  RETURN NULL;
END unverifyAction;


-----------------------------------------------------------------------------------------------------
-- Function       : CheckAttbSyntax
-- Description    : Returns error if Attribute syntax is not valid
-- Preconditions  :
-- Postconditions :
-- Using tables   : TRANS_INV_LI_PR_VAR
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      : called from class trigger action.
-----------------------------------------------------------------------------------------------------
PROCEDURE CheckAttbSyntax(p_attribute_syntax VARCHAR2,
                          p_scope VARCHAR2) IS


CURSOR TransInvCol(c_class1 VARCHAR2, c_class2 VARCHAR2) IS
    select distinct attribute_name
    from class_attribute_cnfg
    where class_name in(c_class1,c_class2);


CURSOR GetTokens(c_attbString VARCHAR2) IS
    select regexp_substr(c_attbString,'[^-,+]+', 1, level) as attribute_name from dual
    connect by regexp_substr(c_attbString, '[^-,+]+', 1, level) is not null;

  not_valid_syntax   EXCEPTION;
  pPosition          number       :=0;
  mPosition          number       :=0;
  nLength            number       := LENGTH(p_attribute_syntax);
  lv2_className1     VARCHAR2(32);
  lv2_className2     Varchar2(32);
  bFound             boolean      := false;

BEGIN

  pPosition := INSTR(p_attribute_syntax, '+');
  mPosition := INSTR(p_attribute_syntax, '-');

  IF (p_scope = 'BALANCE') THEN
    lv2_className1:='TRANS_INVENTORY_BALANCE';
    lv2_className2:= null;
  ELSIF (p_scope='TRANSACTION') THEN
    lv2_className1:='TRANS_INVENTORY_TRANS';
    lv2_className2:= null;
  ELSE
    lv2_className1:='TRANS_INVENTORY_TRANS';
    lv2_className2:='TRANS_INVENTORY_BALANCE';
    --END IF;
  END IF;

  IF (pPosition = 0 AND mPosition =0) then--check syntax without + or - sign without parsing (only for column name)
    FOR colName IN TransInvCol(lv2_className1,lv2_className2) LOOP
      IF (colName.Attribute_Name = p_attribute_syntax) Then
        bFound := true;
      END IF;
    END LOOP;
  ELSIF (pPosition = 1 OR mPosition =1 OR pPosition = nLength OR mPosition = nLength) THEN -- Checking syntax if + and - placed at the start or end of p_attribute_syntax
      bFound := false;
  ELSE-- parse p_attribute_syntax using + or -
      FOR attb IN GetTokens(p_attribute_syntax) LOOP
        bFound := false;
        FOR colName IN TransInvCol(lv2_className1,lv2_className2) LOOP
          IF (colName.Attribute_Name = attb.attribute_name) Then
            bFound := true;
            EXIT;
          END IF;
        END LOOP;
        IF (not bFound) THEN
          EXIT;
        END IF;
      END LOOP;
  END IF;

  IF (not bFound) THEN
    raise not_valid_syntax;
  END IF;

  EXCEPTION
    WHEN not_valid_syntax THEN
      raise_application_error (-20867, 'Not a valid Syntax. Please enter valid Syntax');

END CheckAttbSyntax;


-----------------------------------------------------------------------------------------------------
-- Function       : PreDeleteTemplateTest
-- Description    : Checks is there any data related to template line and products before delete.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      : Run from class trigger action .
-----------------------------------------------------------------------------------------------------
FUNCTION PreDeleteTemplateTest( p_tag                       VARCHAR2,
                                p_object_id                 VARCHAR2,
                                p_daytime                   DATE,
                                p_end_date                  DATE,
                                p_product_id                VARCHAR2,
                                p_cost_type                 VARCHAR2,
                                p_type                      VARCHAR2
                                ) RETURN VARCHAR2
IS
lv_end_user_message VARCHAR2(4000);

BEGIN
IF p_type='LINE' THEN
  IF Ecdp_Trans_Inventory.Exist_LineOverride(p_tag,p_object_id,p_daytime,p_end_date) <> 'N'  THEN RAISE_APPLICATION_ERROR(-20000, 'Referenced line is overridden in the following product streams. Delete overrides first to be able to delete the line. \n\n'||Ecdp_Trans_Inventory.Exist_LineOverride(p_tag,p_object_id,p_daytime,p_end_date)||'\n\nTechnical details:');
     ELSIF Ecdp_Trans_Inventory.Exist_ProductOverride(p_tag,p_object_id,null,null,p_daytime,p_end_date) <> 'N'  THEN RAISE_APPLICATION_ERROR(-20000, 'Referenced line products are overridden in the following product streams. Delete overrides first to be able to delete the line.\n\n'||Ecdp_Trans_Inventory.Exist_ProductOverride(p_tag,p_object_id,null,null,p_daytime,p_end_date)||'\n\nTechnical details:' );
     ELSIF Ecdp_Trans_Inventory.Exist_TransInvLinePosting(null,p_object_id,p_daytime,p_tag,p_end_date) <> 'N'  THEN RAISE_APPLICATION_ERROR(-20000, 'Referenced line is having postings in the following product streams. Delete postings first to be able to delete the line. \n\n'||Ecdp_Trans_Inventory.Exist_TransInvLinePosting(null,p_object_id,p_daytime,p_tag,p_end_date)||'\n\nTechnical details:');
     ELSIF Ecdp_Trans_Inventory.Exist_TransInvLineProdVar(null,p_object_id,p_daytime,p_tag,p_end_date,null,null) <> 'N'  THEN RAISE_APPLICATION_ERROR(-20000, 'Referenced line products have variables in the following product streams. Delete variables first to be able to delete the line. \n\n'||Ecdp_Trans_Inventory.Exist_TransInvLineProdVar(null,p_object_id,p_daytime,p_tag,p_end_date,null)||'\n\nTechnical details:');
  END IF;
 ELSIF p_type='PRODUCT' THEN
  IF Ecdp_Trans_Inventory.Exist_ProductOverride(p_tag,p_object_id,p_product_id,p_COST_TYPE,p_daytime,p_end_date) <> 'N'  THEN RAISE_APPLICATION_ERROR(-20000, 'Referenced product is overridden in the following product streams. Delete overrides first to be able to delete the product.\n\n'||Ecdp_Trans_Inventory.Exist_ProductOverride(p_tag,p_object_id,p_product_id,p_COST_TYPE,p_daytime,p_end_date)||'\n\nTechnical details:');
     ELSIF Ecdp_Trans_Inventory.Exist_TransInvLinePosting(null,p_object_id,p_daytime,p_tag,p_end_date,p_product_id,p_cost_type) <> 'N'  THEN RAISE_APPLICATION_ERROR(-20000, 'Referenced product is having postings in the following product streams. Delete postings first to be able to delete the product. \n\n'||Ecdp_Trans_Inventory.Exist_TransInvLinePosting(null,p_object_id,p_daytime,p_tag,p_end_date,p_product_id)||'\n\nTechnical details:');
     ELSIF Ecdp_Trans_Inventory.Exist_TransInvLineProdVar(null,p_object_id,p_daytime,p_tag,p_end_date,p_product_id,p_cost_type) <> 'N'  THEN RAISE_APPLICATION_ERROR(-20000, 'Referenced product is having variables in the following product streams. Delete variables first to be able to delete the product. \n\n'||Ecdp_Trans_Inventory.Exist_TransInvLineProdVar(null,p_object_id,p_daytime,p_tag,p_end_date,p_product_id,p_cost_type)||'\n\nTechnical details:');
  END IF;

 END IF;
RETURN lv_end_user_message;

END;

-----------------------------------------------------------------------------------------------------
-- Function       : CreateTransInvProdVarOverride
-- Description    : Create Product Variable override and return suitable message.
-- Preconditions  :
-- Postconditions :
-- Using tables   : TRANS_INV_LI_PR_VAR
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      : Run from product variable screen (product_variables.xhtml).
-----------------------------------------------------------------------------------------------------
Procedure CreateTransInvProdVarOverride(p_trans_inventory_id VARCHAR2,
                                       p_prod_Stream_id     VARCHAR2,
                                       p_line_tag           VARCHAR2,
                                       p_product_id         VARCHAR2,
                                       p_cost_type          VARCHAR2,
                                       p_daytime            DATE,
                                       p_user_id            VARCHAR2,
                                       p_config_variable_id VARCHAR2,
                                       p_var_exec_order     VARCHAR2,
                                       p_over_ind           VARCHAR2)
                                       IS

  lrec_trans_inv_li_pr_var trans_inv_li_pr_var%rowtype;
  ln_found NUMBER;
  ln_new_exec_order      NUMBER;
  -- cursor to get variable records
  cursor default_values (cp_trans_inventory_id varchar2,
                         cp_daytime            varchar2,
                         cp_product_id         varchar2,
                         cp_cost_type          varchar2,
                         cp_prod_Stream_id     varchar2,
                         cp_line_tag           varchar2,
                         cp_config_variable_id VARCHAR2,
                         cp_var_exec_order     VARCHAR2)  is

      select *
      from v_trans_inv_li_pr_var_over
       where daytime       <= cp_daytime
         and prod_stream_id = cp_prod_Stream_id
         and cp_line_tag    = line_tag
         and product_id     = p_product_id
         and cost_type      = cp_cost_type
         and object_id      = cp_trans_inventory_id
         and config_variable_id = cp_config_variable_id
         and var_exec_order = cp_var_exec_order;


  --- cursor get parameter records
  CURSOR c_TransInvLiProdVarDim(cp_object_id           VARCHAR2,
                                cp_line_tag            VARCHAR2,
                                cp_product_id          VARCHAR2,
                                cp_cost_type           VARCHAR2,
                                cp_variable_id         VARCHAR2,
                                cp_var_exec_order      NUMBER,
                                cp_daytime             DATE) IS

       SELECT tilpvd.*
       FROM Trans_Inv_Li_Pr_Var_Dim tilpvd
        WHERE tilpvd.object_id = cp_object_id
          AND tilpvd.line_tag = cp_line_tag
          AND tilpvd.product_id = cp_product_id
          AND tilpvd.cost_type = cp_cost_type
          AND tilpvd.config_variable_id = cp_variable_id
          AND tilpvd.variable_exec_order = cp_var_exec_order
          AND daytime <= cp_daytime;

BEGIN

  IF (p_over_ind = 'N') THEN
    RAISE_APPLICATION_ERROR(-20151, 'Selected Product Variable can not be overridden or Override checkbox not selected. Please select valid Product Variable or Override checkbox');
  END IF;

  select count(*) into ln_found from trans_inv_li_pr_var
         where object_id      = p_trans_inventory_id
           and line_tag       = p_line_tag
           and product_id     = p_product_id
           and cost_type      = p_cost_type
           and prod_stream_id = p_prod_Stream_id
           and config_variable_id = p_config_variable_id
           and var_exec_order = p_var_exec_order
           and daytime       <= p_daytime;

  SELECT max(nvl(var_exec_order, 0)) + 1
        INTO ln_new_exec_order
        FROM TRANS_INV_LI_PR_VAR
       WHERE OBJECT_ID = p_trans_inventory_id
         AND LINE_TAG = p_line_tag
         AND DAYTIME = p_daytime
         AND product_id = p_product_id
         AND cost_type = p_cost_type
         AND config_variable_id = p_config_variable_id
         AND var_exec_order = p_var_exec_order;

  IF ln_found >0 THEN
     RAISE_APPLICATION_ERROR(-20001, 'There is overlapping values for the given period and it can not be created for the period ' );
  END IF;

  IF EC_TRANS_INVENTORY_VERSION.valuation_method(p_trans_inventory_id,p_daytime,'<=') = 'TEMPLATE' THEN
    RAISE_APPLICATION_ERROR(-20001,'This is a template inventory. You can not overrider Lines and Products. You can add Variables.');
  END IF;

  FOR def_val in default_values (p_trans_inventory_id,
                                 p_daytime,
                                 p_product_id,
                                 p_cost_type,
                                 p_prod_Stream_id,
                                 p_line_tag,
                                 p_config_variable_id,
                                 p_var_exec_order) LOOP

    lrec_trans_inv_li_pr_var :=   ec_trans_inv_li_pr_var.row_by_pk(p_trans_inventory_id,
                                                                   p_daytime,
                                                                   p_line_tag,
                                                                   p_product_id,
                                                                   p_cost_type,
                                                                   p_var_exec_order,
                                                                   p_config_variable_id,
                                                                   p_prod_stream_id);


   IF lrec_trans_inv_li_pr_var.object_id is NOT NULL THEN
       INSERT INTO TRANS_INV_LI_PR_VAR
              (object_id
              ,id
              ,daytime
              ,end_date
              ,name
              ,config_variable_id
              ,prod_stream_id
              ,reverse_value_ind
              ,line_tag
              ,product_id
              ,cost_type
              ,trans_def_dimension
              ,type
              ,text_1
              ,text_2
              ,text_3
              ,text_4
              ,text_5
              ,text_6
              ,text_7
              ,text_8
              ,text_9
              ,text_10
              ,value_1
              ,value_2
              ,value_3
              ,value_4
              ,value_5
              ,date_1
              ,date_2
              ,date_3
              ,date_4
              ,date_5
              ,ref_object_id_1
              ,ref_object_id_2
              ,ref_object_id_3
              ,ref_object_id_4
              ,ref_object_id_5
              ,var_exec_order
              ,net_zero_ind
              ,round_ind
              ,disabled_ind
              ,created_by)
              VALUES
              (p_trans_inventory_id
              ,lrec_trans_inv_li_pr_var.id
              ,p_daytime
              ,lrec_trans_inv_li_pr_var.end_date
              ,lrec_trans_inv_li_pr_var.name
              ,lrec_trans_inv_li_pr_var.config_variable_id
              ,lrec_trans_inv_li_pr_var.prod_stream_id
              ,lrec_trans_inv_li_pr_var.reverse_value_ind
              ,p_line_tag
              ,p_product_id
              ,p_cost_type
              ,lrec_trans_inv_li_pr_var.trans_def_dimension
              ,lrec_trans_inv_li_pr_var.type
              ,lrec_trans_inv_li_pr_var.text_1
              ,lrec_trans_inv_li_pr_var.text_2
              ,lrec_trans_inv_li_pr_var.text_3
              ,lrec_trans_inv_li_pr_var.text_4
              ,lrec_trans_inv_li_pr_var.text_5
              ,lrec_trans_inv_li_pr_var.text_6
              ,lrec_trans_inv_li_pr_var.text_7
              ,lrec_trans_inv_li_pr_var.text_8
              ,lrec_trans_inv_li_pr_var.text_9
              ,lrec_trans_inv_li_pr_var.text_10
              ,lrec_trans_inv_li_pr_var.value_1
              ,lrec_trans_inv_li_pr_var.value_2
              ,lrec_trans_inv_li_pr_var.value_3
              ,lrec_trans_inv_li_pr_var.value_4
              ,lrec_trans_inv_li_pr_var.value_5
              ,lrec_trans_inv_li_pr_var.date_1
              ,lrec_trans_inv_li_pr_var.date_2
              ,lrec_trans_inv_li_pr_var.date_3
              ,lrec_trans_inv_li_pr_var.date_4
              ,lrec_trans_inv_li_pr_var.date_5
              ,lrec_trans_inv_li_pr_var.ref_object_id_1
              ,lrec_trans_inv_li_pr_var.ref_object_id_2
              ,lrec_trans_inv_li_pr_var.ref_object_id_3
              ,lrec_trans_inv_li_pr_var.ref_object_id_4
              ,lrec_trans_inv_li_pr_var.ref_object_id_5
              ,p_var_exec_order
              ,lrec_trans_inv_li_pr_var.net_zero_ind
              ,lrec_trans_inv_li_pr_var.round_ind
              ,nvl(lrec_trans_inv_li_pr_var.disabled_ind,'N')
              ,p_user_id);
    ELSE -- inserting new record
       INSERT INTO TRANS_INV_LI_PR_VAR
              (object_id
              ,id
              ,daytime
              ,end_date
              ,name
              ,config_variable_id
              ,prod_stream_id
              ,reverse_value_ind
              ,line_tag
              ,product_id
              ,cost_type
              ,trans_def_dimension
              ,type
              ,text_1
              ,text_2
              ,text_3
              ,text_4
              ,text_5
              ,text_6
              ,text_7
              ,text_8
              ,text_9
              ,text_10
              ,value_1
              ,value_2
              ,value_3
              ,value_4
              ,value_5
              ,date_1
              ,date_2
              ,date_3
              ,date_4
              ,date_5
              ,ref_object_id_1
              ,ref_object_id_2
              ,ref_object_id_3
              ,ref_object_id_4
              ,ref_object_id_5
              ,var_exec_order
              ,net_zero_ind
              ,round_ind
              ,disabled_ind
              ,created_by)
              VALUES
              (p_trans_inventory_id
              ,def_val.id
              ,p_daytime
              ,def_val.end_date
              ,def_val.name
              ,def_val.config_variable_id
              ,def_val.prod_stream_id
              ,def_val.reverse_value_ind
              ,p_line_tag
              ,p_product_id
              ,p_cost_type
              ,def_val.trans_def_dimension
              ,def_val.type
              ,def_val.text_1
              ,def_val.text_2
              ,def_val.text_3
              ,def_val.text_4
              ,def_val.text_5
              ,def_val.text_6
              ,def_val.text_7
              ,def_val.text_8
              ,def_val.text_9
              ,def_val.text_10
              ,def_val.value_1
              ,def_val.value_2
              ,def_val.value_3
              ,def_val.value_4
              ,def_val.value_5
              ,def_val.date_1
              ,def_val.date_2
              ,def_val.date_3
              ,def_val.date_4
              ,def_val.date_5
              ,def_val.ref_object_id_1
              ,def_val.ref_object_id_2
              ,def_val.ref_object_id_3
              ,def_val.ref_object_id_4
              ,def_val.ref_object_id_5
              ,p_var_exec_order
              ,def_val.net_zero_ind
              ,def_val.round_ind
              ,nvl(def_val.disabled_ind,'N')
              ,p_user_id);

         --Refresh the parameters on the variable
         refreshparams(p_trans_inventory_id,
                       p_prod_Stream_id,
                       p_config_variable_id,
                       p_daytime,
                       def_val.end_date,
                       p_product_id,
                       p_cost_type,
                       p_line_tag,
                       p_var_exec_order);

      lrec_trans_inv_li_pr_var := ec_trans_inv_li_pr_var.row_by_pk(p_trans_inventory_id,
                                                                   p_daytime,
                                                                   p_line_tag,
                                                                   p_product_id,
                                                                   p_cost_type,
                                                                   p_var_exec_order,
                                                                   p_config_variable_id,
                                                                   p_prod_stream_id);

       FOR tilpvp in c_TransInvLiProdVarDim(lrec_trans_inv_li_pr_var.object_id,
                                            lrec_trans_inv_li_pr_var.line_tag,
                                            lrec_trans_inv_li_pr_var.product_id,
                                            lrec_trans_inv_li_pr_var.cost_type,
                                            lrec_trans_inv_li_pr_var.config_variable_id,
                                            lrec_trans_inv_li_pr_var.var_exec_order,
                                            lrec_trans_inv_li_pr_var.daytime) LOOP

            UPDATE TRANS_INV_LI_PR_VAR_DIM tilpvd
               SET tilpvd.text                  = tilpvp.text,
                   tilpvd.trans_param_source_id = tilpvp.trans_param_source_id,
                   tilpvd.key                   = tilpvp.key
             WHERE tilpvd.object_id           = p_trans_inventory_id
               AND tilpvd.line_tag            = p_line_tag
               AND tilpvd.product_id          = p_product_id
               AND tilpvd.cost_type           = p_cost_type
               AND tilpvd.Config_Variable_Id  = lrec_trans_inv_li_pr_var.config_variable_id
               AND tilpvd.Variable_Exec_Order = p_var_exec_order
               AND tilpvd.dimension           = tilpvp.dimension
               AND tilpvd.daytime             = p_daytime;

       END LOOP;
     END IF;
  END LOOP;

END CreateTransInvProdVarOverride;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : CreateTransInvLiPrVar
-- Description    : This will create a transaction inventory line product variable
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : TRANS_INV_LI_PR_VAR_DIM,TRANS_INV_LI_PR_VAR
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------
PROCEDURE CreateTransInvLiPrVar(p_object_id           VARCHAR2,
                                p_prod_Stream_id      VARCHAR2,
                                p_line_tag            VARCHAR2,
                                p_product_id          VARCHAR2,
                                p_cost_type           VARCHAR2,
                                p_daytime             DATE,
                                p_end_date            DATE,
                                p_config_variable_id  VARCHAR2,
                                p_var_exec_order      VARCHAR2,
                                p_name                VARCHAR2,
                                p_reverse_value_ind   VARCHAR2,
                                p_net_zero_ind        VARCHAR2,
                                p_round_ind           VARCHAR2,
                                p_type                VARCHAR2,
                                p_post_process_ind    VARCHAR2,
                                p_trans_def_dimension VARCHAR2,
                                p_disable_ind         VARCHAR2,
                                p_user_id             VARCHAR2)

IS

             CURSOR c_TransInvLiProdVarDim(cp_object_id           VARCHAR2,
                                           cp_line_tag            VARCHAR2,
                                           cp_product_id          VARCHAR2,
                                           cp_cost_type           VARCHAR2,
                                           cp_variable_id         VARCHAR2,
                                           cp_var_exec_order      NUMBER,
                                           cp_daytime             DATE) IS
             SELECT tilpvd.*
               FROM Trans_Inv_Li_Pr_Var_Dim tilpvd
              WHERE tilpvd.object_id = cp_object_id
                AND tilpvd.line_tag = cp_line_tag
                AND tilpvd.product_id = cp_product_id
                AND tilpvd.cost_type = cp_cost_type
                AND tilpvd.config_variable_id = cp_variable_id
                AND tilpvd.variable_exec_order = cp_var_exec_order
                AND daytime <= cp_daytime;

ln_new_exec_order      NUMBER;

BEGIN

      SELECT max(nvl(var_exec_order, 0)) + 1
        INTO ln_new_exec_order
        FROM TRANS_INV_LI_PR_VAR
       WHERE OBJECT_ID = p_object_id
         AND LINE_TAG = p_line_tag
         AND DAYTIME = p_daytime
         AND product_id = p_product_id
         AND cost_type = p_cost_type
         AND config_variable_id = p_config_variable_id
         AND var_exec_order = p_var_exec_order;

         INSERT INTO TRANS_INV_LI_PR_VAR
              (object_id
              ,id
              ,daytime
              ,end_date
              ,name
              ,config_variable_id
              ,prod_stream_id
              ,reverse_value_ind
              ,line_tag
              ,product_id
              ,cost_type
              ,trans_def_dimension
              ,type
              ,var_exec_order
              ,net_zero_ind
              ,round_ind
              ,post_process_ind
              ,disabled_ind
              ,created_by)
              VALUES
              (p_object_id
              ,ecdp_system_key.assignNextKeyValue('TRANS_INV_LI_PR_VAR')
              ,p_daytime
              ,p_end_date
              ,p_name
              ,p_config_variable_id
              ,p_prod_stream_id
              ,p_reverse_value_ind
              ,p_line_tag
              ,p_product_id
              ,p_cost_type
              ,p_trans_def_dimension
              ,p_type
              ,p_var_exec_order
              ,p_net_zero_ind
              ,p_round_ind
              ,p_post_process_ind
              ,nvl(p_disable_ind,'N')
              ,p_user_id);

         --Refresh the parameters on the variable
         refreshparams(p_object_id,
                       p_prod_Stream_id,
                       p_config_variable_id,
                       p_daytime,
                       p_end_date,
                       p_product_id,
                       p_cost_type,
                       p_line_tag,
                       p_var_exec_order);

          FOR tilpvp in c_TransInvLiProdVarDim(p_object_id,
                                         p_line_tag,
                                         p_product_id,
                                         p_cost_type,
                                         p_config_variable_id,
                                         p_var_exec_order,
                                         p_daytime) LOOP

            UPDATE TRANS_INV_LI_PR_VAR_DIM tilpvd
               SET tilpvd.text                  = tilpvp.text,
                   tilpvd.trans_param_source_id = tilpvp.trans_param_source_id,
                   tilpvd.key                   = tilpvp.key
             WHERE tilpvd.object_id = p_object_id
               AND tilpvd.line_tag = p_line_tag
               AND tilpvd.product_id = p_product_id
               AND tilpvd.cost_type = p_cost_type
               AND tilpvd.Config_Variable_Id = p_config_variable_id
               AND tilpvd.Variable_Exec_Order = p_var_exec_order
               AND tilpvd.dimension = tilpvp.dimension
               AND tilpvd.daytime = p_daytime;

          END LOOP;

END CreateTransInvLiPrVar;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : DeleteTransInvProdVarOverride
-- Description    : This will delete transaction inventory line product variable
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : TRANS_INV_LI_PR_VAR_DIM,TRANS_INV_LI_PR_VAR
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------
PROCEDURE DeleteTransInvProdVarOverride(p_trans_inventory_id VARCHAR2,
                                        p_prod_Stream_id     VARCHAR2,
                                        p_line_tag           VARCHAR2,
                                        p_product_id         VARCHAR2,
                                        p_cost_type          VARCHAR2,
                                        p_daytime            DATE,
                                        p_config_variable_id VARCHAR2,
                                        p_var_exec_order     VARCHAR2,
                                        p_disable_ind        VARCHAR2) IS
BEGIN
  -- Deleting records from TRANS_INV_LI_PR_VAR table
  DELETE TRANS_INV_LI_PR_VAR
  WHERE object_id = p_trans_inventory_id
    AND line_tag = p_line_tag
    AND product_id = p_product_id
    AND cost_type = p_cost_type
    AND prod_stream_id = p_prod_Stream_id
    AND VAR_EXEC_ORDER = p_var_exec_order
    AND CONFIG_VARIABLE_ID = p_config_variable_id
    AND daytime = p_daytime;

  -- Deleting records from TRANS_INV_LI_PR_VAR_DIM table
  DELETE
     FROM TRANS_INV_LI_PR_VAR_DIM tilpvd
    WHERE object_id = p_trans_inventory_id
      AND line_tag = p_line_tag
      and CONFIG_VARIABLE_ID = p_config_variable_id
      AND product_id = p_product_id
      and cost_type = p_cost_type
      AND daytime = p_daytime
      AND prod_stream_id = p_prod_Stream_id
      AND variable_exec_order = p_var_exec_order;

END DeleteTransInvProdVarOverride;




-----------------------------------------------------------------------------------------------------
-- Function       : IsUsingTemplate
-- Description    : While changing template inventory to normal invetory ,checks is given template is being used by any other inventory before delete.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      : Run from class trigger action .
-----------------------------------------------------------------------------------------------------
FUNCTION IsUsingTemplate( p_template_id                      VARCHAR2,
                          p_daytime                          VARCHAR2
                         ) RETURN VARCHAR2
IS
lv_msg VARCHAR2(4000);

CURSOR inventories IS
SELECT DISTINCT object_id FROM TRANS_INVENTORY_VERSION
WHERE CONFIG_TEMPLATE=p_template_id;

BEGIN
  lv_msg:=NULL;

FOR inv IN inventories
  LOOP
    lv_msg:=lv_msg||ec_trans_inventory_version.name(inv.object_id,p_daytime,'<=')||'\n';
    END LOOP;

IF lv_msg IS NULL THEN
  RETURN 'N';
  ELSE
    RETURN SUBSTR(lv_msg,1,length(lv_msg)-2);
    END IF;

END;

function GetLineLabel(p_trans_inventory_id VARCHAR2,
                                        p_prod_Stream_id     VARCHAR2,
                                        p_line_tag           VARCHAR2,
                                        p_daytime              date,
                                        p_with_number VARCHAR2 default 'N') RETURN VARCHAR2

                                        IS
 lv2_return VARCHAR2(100);
 lv2_inv_id VARCHAR2(32);
 lv2_prod_stream_id VARCHAR2(32);
 lv2_label varchar2(4000);
 lv2_inv_other VARCHAR2(32);
 lv2_prod_stream_other VARCHAR2(32);
 lv2_to_inv_id VARCHAR2(32);
 lv2_to_prod_stream_id VARCHAR2(32);
 lv2_to_tag varchar2(4000);
 lv2_replace varchar2(4000);
 ln_sort_order number;
 lv2_sort_order varchar2(10);
 cursor c_find_counter(cp_object_id  varchar2,
                       cp_line_tag varchar2,
                       cp_daytime date) is
        select til.object_id,null as contract_id,tag from
           trans_inv_line til
        where
           til.xfer_in_trans_id =  cp_object_id
           and til.xfer_in_line=cp_line_tag
           and daytime <= cp_daytime
           and nvl(end_date,cp_daytime+1) > cp_daytime;

 cursor c_find_counter_over(cp_prod_stream_id varchar2,
                       cp_object_id  varchar2,
                       cp_line_tag varchar2,
                       cp_daytime date) is
        select til.object_id,contract_id,tag from
           trans_inv_line_override til
        where
           til.xfer_in_trans_id =  cp_object_id
           and til.xfer_in_line=cp_line_tag
           and daytime <= cp_daytime
           and nvl(end_date,cp_daytime+1) > cp_daytime
           and nvl(til.Src_Prod_Stream_Id,til.contract_id)=cp_prod_stream_id;

 BEGIN
   lv2_inv_id := nvl(ec_trans_inventory_version.config_template(p_trans_inventory_id,P_daytime,'<='),p_trans_inventory_id);
   ln_sort_order := ec_trans_inv_line.seq_no(lv2_inv_id,p_daytime,p_line_tag,'<=');
   lv2_label := ec_trans_inv_line.label(lv2_inv_id,p_daytime,p_line_tag,'<=');
   lv2_prod_stream_id := p_prod_Stream_id;

   if lv2_label is null then
     lv2_label := ec_trans_inv_line.label(p_trans_inventory_id,p_daytime,p_line_tag,'<=');
   end if;

   if lv2_label like '%' ||'_'||'OUT$%' THEN
      for ps in c_find_counter_over(p_prod_Stream_id,p_trans_inventory_id,p_line_tag,p_daytime) loop
        lv2_to_inv_id :=ps.object_id;
        lv2_to_prod_stream_id := ps.contract_id;
        lv2_to_tag:=ps.tag;
        EXIT;
      end loop;
      if lv2_to_inv_id is null then
      for ps in c_find_counter(lv2_inv_id,p_line_tag,p_daytime) loop
        lv2_to_inv_id :=ps.object_id;
        lv2_to_prod_stream_id := p_prod_Stream_id;
        lv2_to_tag:=ps.tag;
        EXIT;
      end loop;
      end if;
       IF lv2_label LIKE '%$TRANS_INV_OUT$%' THEN
         lv2_replace := ec_trans_inventory_version.name(lv2_to_inv_id,p_daytime,'<=' );
         if lv2_replace is not null then
           lv2_label:= replace(lv2_label,'$TRANS_INV_OUT$',lv2_replace);
         end if;

       END IF;

       IF lv2_label LIKE '%$PROD_STREAM_OUT$%' THEN

        lv2_replace := ec_CONTRACT_version.name(lv2_to_prod_stream_id,p_daytime,'<=' );
         if lv2_replace is not null then
           lv2_label:= replace(lv2_label,'$PROD_STREAM_OUT$',lv2_replace);
         end if;
       END IF;

   END IF;
   IF  lv2_label like '%' ||'_'||'IN$%' THEN


       IF lv2_label LIKE '%$TRANS_INV_IN$%' THEN
         lv2_inv_other := ec_trans_inv_line_OVERRIDE.xfer_in_trans_id(p_trans_inventory_id,P_DAYTIME,lv2_prod_stream_id,p_line_tag,'<=');
         lv2_inv_other:=nvl(lv2_inv_other,ec_trans_inv_line.xfer_in_trans_id(lv2_inv_id,P_DAYTIME,p_line_tag,'<='));

         lv2_replace := ec_trans_inventory_version.name(lv2_inv_other,p_daytime,'<=');
         if lv2_replace is not null then
           lv2_label:= replace(lv2_label,'$TRANS_INV_IN$',lv2_replace);
         end if;
       END IF;

       IF lv2_label LIKE '%$PROD_STREAM_IN$%' THEN
         lv2_prod_stream_other := ec_trans_inv_line_OVERRIDE.src_prod_stream_id(p_trans_inventory_id,P_DAYTIME,lv2_prod_stream_id,p_line_tag,'<=');
         lv2_prod_stream_other:=nvl(lv2_prod_stream_other,lv2_prod_stream_id);
         lv2_replace := ec_CONTRACT_version.name(lv2_prod_stream_other,p_daytime,'<=' );

         if lv2_replace is not null then
           lv2_label:= replace(lv2_label,'$PROD_STREAM_IN$',lv2_replace);
         end if;
       END IF;
   END IF;


   if p_with_number = 'Y' AND lv2_label is not null then
     case
       when ln_sort_order <10 then
         lv2_sort_order := lv2_sort_order || '00000';
       when ln_sort_order <100 then
         lv2_sort_order := lv2_sort_order || '0000';
       when ln_sort_order <1000 then
         lv2_sort_order := lv2_sort_order || '000';
       when ln_sort_order <10000 then
         lv2_sort_order := lv2_sort_order|| '00';
       when ln_sort_order <100000 then
         lv2_sort_order := lv2_sort_order || '0';
      end case;
     lv2_label:= lv2_sort_order ||ln_sort_order || ' : ' || lv2_label;
   ELSIF  p_with_number = 'Y' AND p_line_tag = 'REBALANCE_LINE' THEN
     lv2_label:= '999999 : Rebalance Line';
   end if;
   IF lv2_label IS NULL then
     IF ec_trans_inventory.object_id_by_uk(p_line_tag) is not null then
       lv2_label := ec_trans_inventory_version.name( ec_trans_inventory.object_id_by_uk(p_line_tag),p_daytime,'<=');
     END IF;
   END IF;
   RETURN lv2_label;
 END;


procedure Trans_inv_Report(
                        p_template_code varchar2
                        ,p_run_no NUMBER
                        ,p_daytime date
                        ,p_object_id varchar2
                        ,p_inventory_id varchar2 default null
                        ,p_level VARCHAR2
                        ,rec_b IN OUT T_TABLE_TRANS_INV
                        ,p_include_country_ind VARCHAR2
                        ,p_include_del_point_ind VARCHAR2
                        )


IS
rec_b2 T_TRANS_INV_2;
--
    ln_count number;

CURSOR c_template(p_layout VARCHAR2) is
select * from TRANS_INVENTORY_TMPL_ATTR
where template_code = p_layout
and (TRANS_INVENTORY_scope =p_level
    OR TRANS_INVENTORY_scope = 'ALL'
    OR ( TRANS_INVENTORY_scope='BALANCE'
    and p_level in ('OPENING','CLOSING')))
and attribute_syntax in ('DIM_1','DIM_2','PROD_DATE','LAYER_MONTH')
ORDER BY SORT_ORDER;

CURSOR c_template_other(p_layout VARCHAR2) is
select * from TRANS_INVENTORY_TMPL_ATTR
where template_code = p_layout
and (TRANS_INVENTORY_scope =p_level
    OR TRANS_INVENTORY_scope = 'ALL'
    OR ( TRANS_INVENTORY_scope='BALANCE'
    and p_level in ('OPENING','CLOSING')))
and attribute_syntax not in ('DIM_1','DIM_2','PROD_DATE','LAYER_MONTH')
ORDER BY SORT_ORDER;

lv_sql varchar2(4000);
lv_sql_main_tag varchar2(4000);
lv_sql_tag CLOB;
lc_result sys_refcursor;
p_collection T_TABLE_TRANS_INV;
ln_run_no number;
p_level_name varchar2(100);
p_transaction_name varchar2(1000);
  lv_sort_order VARCHAR2(100);
BEGIN


    lv_sql := 'SELECT NVL(SORT_ORDER,0.9999999999999999999999) AS SORT_ITEM,'
           ||'EC_CONTRACT_VERSION.NAME(PROD_STREAM_ID,DAYTIME,''<='') AS PROD_STREAM_NAME,(SELECT max(EXEC_ORDER) FROM TRANS_INV_PROD_STREAM WHERE DAYTIME <= X.DAYTIME AND NVL(END_dATE,x.DAYTIME+1) >X.DAYTIME AND INVENTORY_ID = X.OBJECT_ID AND
    OBJECT_ID = prod_stream_id) || '' : '' || EC_TRANS_INVENTORY_VERSION.NAME(OBJECT_ID,DAYTIME,''<='')INVENTORY_NAME,$VVV$ AS COUNTRY,$WWW$ AS DELIVERY_POINT,$YYY$ AS REPORT_VISIBLE,
           $XXX$ AS TRANSACTION_TAG,';
  IF  p_level = 'TRANSACTION' THEN
    lv_sql := REPLACE(lv_sql,'$XXX$','nvl(ecdp_trans_inventory.GetLineLabel(x.OBJECT_ID,
                                        x.PROD_STREAM_ID,
                                        X.TRANSACTION_TAG,
                                       x.DAYTIME,''Y''),TRANSACTION_TAG)' );
    lv_sql := REPLACE(lv_sql,'$YYY$','decode(TRANSACTION_TAG,''REBALANCE_LINE'',''N'',''Y'')' );

  ELSE
    lv_sql := REPLACE(lv_sql,'$XXX$','''' || p_level ||'''' );
    lv_sql := REPLACE(lv_sql,'$YYY$','''Y''' );
  END IF;
  ln_count:= 0;
  ln_run_no := P_run_no;


    lv_sql_main_tag := lv_sql;
    lv_sql_tag := '';
    for temp in c_template(p_template_code) LOOP
      CASE  Temp.attribute_syntax
        WHEN 'DIM_1' THEN
        lv_sql_main_tag := lv_sql_main_tag || ' nvl(ecdp_trans_inventory.DimNameFromTag(object_id,prod_stream_id,daytime,DIMENSION_TAG,1),substr(DIMENSION_TAG,1,decode(instr(DIMENSION_TAG,''|''),0,LENGTH(DIMENSION_TAG),instr(DIMENSION_TAG,''|'')-1))) AS DIM_1,';
        WHEN 'DIM_2' THEN
           lv_sql_main_tag := lv_sql_main_tag || ' nvl(ecdp_trans_inventory.DimNameFromTag(object_id,prod_stream_id,daytime,DIMENSION_TAG,2),substr(DIMENSION_TAG,instr(DIMENSION_TAG,''|'')+1,instr(DIMENSION_TAG,''|'',-1)-instr(DIMENSION_TAG,''|'')-1)) AS DIM_2,';
        WHEN 'PROD_DATE' THEN
           lv_sql_main_tag := lv_sql_main_tag || ' to_date(decode(dimension_tag,''NA'',NULL,substr(dimension_tag,instr(dimension_tag,''|'',-1)+1)),''YYYY-MM-DD"T"HH24:MI:SS'') AS PROD_DATE,';
        WHEN 'LAYER_MONTH' THEN
           lv_sql_main_tag := lv_sql_main_tag || ' LAYER_MONTH,';

      END CASE;
    END LOOP;

      IF NVL(p_include_country_ind,'N') = 'Y' THEN
        lv_sql_main_tag := REPLACE(lv_sql_main_tag,'$VVV$', 'ec_geogr_area_version.name(ec_trans_inventory_version.country_id(object_id,daytime,''<=''),daytime,''<='')');
      ELSE
        lv_sql_main_tag := REPLACE(lv_sql_main_tag,'$VVV$', '''N/A''');
      END IF;

      IF NVL(p_include_del_point_ind,'N') = 'Y' THEN
        lv_sql_main_tag := REPLACE(lv_sql_main_tag,'$WWW$',
        '(SELECT EC_DELPNT_VERSION.NAME(MAX(KEY_1), X.daytime, ''<='') '||
        '  FROM RRCA_REVN_KEY'||
        ' WHERE PAGE = ''BLEND'''||
        '   AND KEY_2 ='||
        '       EC_TRANS_INVENTORY.node_id(X.daytime)'||
        '   AND DAYTIME <= X.daytime'||
        '   AND NVL(END_dATE, X.daytime + 1) >X.daytime'||
        '   AND OBJECT_ID = X.PROD_STREAM_ID)');
      ELSE
        lv_sql_main_tag := REPLACE(lv_sql_main_tag,'$WWW$', '''N/A''');
      END IF;

    for temp in c_template_other(p_template_code) LOOP
      lv_sort_order := TO_CHAR(TEMP.sort_order);

      IF TEMP.sort_order < 1000 THEN lv_sort_order := '0' || lv_sort_order; END IF;
      IF TEMP.sort_order < 1000 THEN lv_sort_order := '0' || lv_sort_order; END IF;
      IF TEMP.sort_order < 100 THEN lv_sort_order := '0' || lv_sort_order; END IF;
      IF TEMP.sort_order < 10 THEN lv_sort_order := '0' || lv_sort_order; END IF;

        lv_sql_tag :=  lv_sql_tag ||  lv_sql_main_tag || ' NVL(' || Temp.attribute_syntax || ',0) as REPORT_VALUE,  ''' ;
           lv_sql_tag :=  lv_sql_tag|| '
 ['  || lv_sort_order ||']
 ' ;
        IF TEMP.LABEL_HEADER IS NOT NULL THEN
           lv_sql_tag :=  lv_sql_tag ||TEMP.LABEL_HEADER || '
 ' ;
        END IF;

        lv_sql_tag :=  lv_sql_tag || Temp.label;
        IF TEMP.UOM IS NOT NULL THEN
           lv_sql_tag :=  lv_sql_tag|| '
 ['  || TEMP.UOM ||']' ;
        END IF;
        lv_sql_tag :=  lv_sql_tag || ''' AS COLUMN_NAME';
        IF p_level = 'TRANSACTION' THEN
           lv_sql_tag :=lv_sql_tag || ' FROM TRANS_INVENTORY_TRANS X WHERE CALC_RUN_NO =' ||to_char(p_run_no);
        ELSE
           lv_sql_tag :=lv_sql_tag || ' FROM TRANS_INVENTORY_BALANCE X WHERE CALC_RUN_NO =' ||to_char(p_run_no);
        END IF;
        IF p_inventory_id is not null then
          lv_sql_tag :=lv_sql_tag || ' and object_id= ''' || p_inventory_id || ''' ';
        end if;
        lv_sql_tag :=lv_sql_tag || ' union all ';
    END LOOP;

    lv_sql_tag := substr(lv_sql_tag,1,length(lv_sql_tag)-10);
    --lv_sql_tag := 'SELECT * FROM (' || lv_sql_tag  ||') ';
    --ECDP_DYNSQL.WRITETEMPTEXT('sql' || p_template_code ,'X'||lv_sql_tag);


open lc_result for lv_sql_tag ;
   LOOP

        fetch lc_result INTO rec_b2;

        rec_b.extend(1);
        CASE p_level
          WHEN 'OPENING' THEN p_level_name := '1. Opening';
          when 'CLOSING' then p_level_name := '3. Closing';
            else p_level_name := '2. Transaction';
         end case;
        rec_b(rec_b.last) := T_TRANS_INV(
                                           P_object_id,
                                           rec_b2.SORT_ITEM,
                                           p_level_name,
                                           rec_b2.PROD_STREAM_NAME,
                                           rec_b2.INVENTORY_NAME,
                                           rec_b2.COUNTRY,
                                           rec_b2.DELIVERY_POINT,
                                           rec_b2.VISIBLE,
                                           rec_b2.TRANSACTION_TAG,
                                           rec_b2.LAYER_MONTH,
                                           rec_b2.PROD_DATE,
                                           rec_b2.DIM_1,
                                           rec_b2.DIM_2,
                                           rec_b2.value,
                                           rec_b2.COLUMN_NAME,
                                           p_daytime,
                                           p_run_no,
                                           p_template_code
                                           ) ;
       ln_count:=ln_count+1;
        exit when lc_result%notfound;

    end loop;
    close lc_result;
    rec_b.trim;
END;


FUNCTION  Trans_inv_Report(p_level varchar2,
                           p_inventory_id varchar2 default null,
                           p_run_no number,
                           p_template_code varchar2,
                           p_include_country_ind VARCHAR2 DEFAULT 'Y',
                           p_include_delivery_point_ind VARCHAR2 DEFAULT 'Y') RETURN
  T_TABLE_TRANS_INV
  IS
  cursor PendingItems is
      select p_run_no as run_no,p_template_code as template_code, daytime, object_id
      from calc_reference where run_no = p_run_no
      AND (SELECT COUNT(*) FROM TV_TRANS_INV_TMPL_ATTR WHERE TEMPLATE_CODE = p_template_code) > 0 ;

  rec_b T_TABLE_TRANS_INV;
  BEGIN
     rec_b := T_TABLE_TRANS_INV();
       for pending in pendingitems loop
         IF p_level = 'ALL' OR p_level = 'OPENING' THEN
                Trans_inv_Report(
                        pending.template_code,
                        ec_calc_reference.open_run_no(pending.run_no),
                        pending.daytime,
                        pending.object_id,
                        p_inventory_id,
                        'OPENING',
                        rec_b,
                        p_include_country_ind,
                        p_include_delivery_point_ind
                        );
         END IF;
         IF p_level = 'ALL' OR p_level = 'TRANSACTION' THEN
           Trans_inv_Report(
                        pending.template_code,
                        pending.run_no,
                        pending.daytime,
                        pending.object_id,
                        p_inventory_id,
                        'TRANSACTION',
                        rec_b,
                        p_include_country_ind,
                        p_include_delivery_point_ind
                        );
         END IF;

         IF p_level = 'ALL' OR p_level = 'CLOSING' THEN
           Trans_inv_Report(
                        pending.template_code,
                        pending.run_no,
                        pending.daytime,
                        pending.object_id,
                        p_inventory_id,
                        'CLOSING',
                        rec_b,
                        p_include_country_ind,
                        p_include_delivery_point_ind
                        );
         END IF;



        end loop;
    return rec_b;

END Trans_inv_Report;

PROCEDURE CopyMsg(p_object_id in out varchar2  ,
                  p_prod_stream_id in out varchar2  ,
                  p_alt_inventory_id in out varchar2,
                  p_alt_prod_stream_id in out varchar2 ,
                  o_object_id  in out varchar2  ,
                  o_prod_stream_id in out varchar2  ,
                  p_daytime varchar2,
                  p_tag varchar2,
                  p_disabled_ind varchar2 default 'N') is
  lv2_object_id varchar2(32);
  lv2_prod_stream_id varchar2(32);
  lv2_alt_prod_stream_id varchar2(32);
  lv2_alt_inventory_id varchar2(32);
  rec_msg TRANS_INV_MSG%ROWTYPE;
begin
  lv2_object_id:=p_alt_inventory_id;
  lv2_alt_prod_stream_id:=p_prod_stream_id;
  lv2_prod_stream_id:=p_alt_prod_stream_id;
  lv2_alt_inventory_id:=p_object_id;
  rec_msg := EC_TRANS_INV_MSG.row_by_pk(p_object_id,p_daytime,p_tag,'TRANS_INVENTORY','TRANS_INVENTORY',p_prod_stream_id,'<=');
  INSERT INTO TRANS_INV_MSG
      (OBJECT_ID,
      DESCRIPTION,
      DAYTIME,
      MESSAGE_CODE,
      PROD_STREAM_ID,
      END_DATE,
      NAME,
      SEQ_NO,
      FREQUENCY,
      COMPARE_TYPE,
      MSG_TYPE,
      LOG_LEVEL,
      LINE_TAG,
      PRODUCT_ID,
      COST_TYPE,
      TRANS_DEF_DIMENSION,
      MSG_OBJECT_ID,
      MSG_LINE_TAG,
      MSG_PROD_ITEM_ID,
      OBJECT_TYPE,
      PRETEXT,
      MIDTEXT,
      POSTTEXT,
      COMPARE_SPAN,
      TEXT_1,
      TEXT_2,
      TEXT_3,
      TEXT_4,
      TEXT_5,
      TEXT_6,
      TEXT_7,
      TEXT_8,
      TEXT_9,
      TEXT_10,
      VALUE_1,
      VALUE_2,
      VALUE_3,
      VALUE_4,
      VALUE_5,
      DATE_1,
      DATE_2,
      DATE_3,
      DATE_4,
      DATE_5,
      REF_OBJECT_ID_1,
      REF_OBJECT_ID_2,
      REF_OBJECT_ID_3,
      REF_OBJECT_ID_4,
      REF_OBJECT_ID_5,
      DISABLED_IND,
      ALT_PROD_STREAM_ID,
      ALT_INVENTORY_ID)
      VALUES
      (lv2_OBJECT_ID,
      rec_msg.DESCRIPTION,
      p_DAYTIME,
      p_tag,
      LV2_PROD_STREAM_ID,
      rec_msg.END_DATE,
      rec_msg.NAME,
      rec_msg.SEQ_NO,
      rec_msg.FREQUENCY,
      rec_msg.COMPARE_TYPE,
      rec_msg.MSG_TYPE,
      rec_msg.LOG_LEVEL,
      rec_msg.LINE_TAG,
      rec_msg.PRODUCT_ID,
      rec_msg.COST_TYPE,
      rec_msg.TRANS_DEF_DIMENSION,
      rec_msg.MSG_OBJECT_ID,
      rec_msg.MSG_LINE_TAG,
      rec_msg.MSG_PROD_ITEM_ID,
      rec_msg.OBJECT_TYPE,
      rec_msg.PRETEXT,
      rec_msg.MIDTEXT,
      rec_msg.POSTTEXT,
      rec_msg.COMPARE_SPAN,
      rec_msg.TEXT_1,
      rec_msg.TEXT_2,
      rec_msg.TEXT_3,
      rec_msg.TEXT_4,
      rec_msg.TEXT_5,
      rec_msg.TEXT_6,
      rec_msg.TEXT_7,
      rec_msg.TEXT_8,
      rec_msg.TEXT_9,
      rec_msg.TEXT_10,
      rec_msg.VALUE_1,
      rec_msg.VALUE_2,
      rec_msg.VALUE_3,
      rec_msg.VALUE_4,
      rec_msg.VALUE_5,
      rec_msg.DATE_1,
      rec_msg.DATE_2,
      rec_msg.DATE_3,
      rec_msg.DATE_4,
      rec_msg.DATE_5,
      rec_msg.REF_OBJECT_ID_1,
      rec_msg.REF_OBJECT_ID_2,
      rec_msg.REF_OBJECT_ID_3,
      rec_msg.REF_OBJECT_ID_4,
      rec_msg.REF_OBJECT_ID_5,
      p_disabled_ind,
      lv2_alt_prod_stream_id,
      lv2_alt_inventory_id);

  p_alt_inventory_id:=lv2_alt_inventory_id;
  p_prod_stream_id  :=lv2_prod_stream_id;
  p_alt_prod_stream_id :=lv2_alt_prod_stream_id;
  p_object_id:=lv2_object_id;
  o_object_id:=p_object_id;
  o_prod_stream_id:=p_prod_stream_id;
end CopyMsg;

PROCEDURE CopyPosting(p_object_id in out VARCHAR2,
                      p_prod_stream_id in out VARCHAR2,
                      p_alt_inventory_id in out VARCHAR2,
                      p_alt_prod_stream_id in out VARCHAR2,
                      o_object_id in out VARCHAR2,
                      o_prod_stream_id in out VARCHAR2,
                      p_daytime in out DATE,
                      n_id in out VARCHAR2,
                      n_ref_id  in out VARCHAR2,
                      p_disabled_ind VARCHAR2 DEFAULT 'N')
  is
 lv2_object_id varchar2(32);
  lv2_prod_stream_id varchar2(32);
  lv2_alt_prod_stream_id varchar2(32);
  lv2_alt_inventory_id varchar2(32);
  rec_cntr TRANS_INV_LI_PR_CNTRACC%ROWTYPE;
  lv2_product_id  VARCHAR2(32);
  lv2_cost_type VARCHAR2(32);
  lv2_line_tag VARCHAR2(32);
  lv2_type VARCHAR2(32);
  lv2_account_code VARCHAR2(32);
  lv2_source_type VARCHAR2(32);
begin

  select product_id,cost_type,line_tag,type,account_code,source_type into
          lv2_product_id,lv2_cost_type,lv2_line_tag,lv2_type,lv2_account_code,lv2_source_type
          from Trans_Inv_Li_Pr_Cntracc where id=n_id;

  lv2_object_id:=p_alt_inventory_id;
  lv2_alt_prod_stream_id:=p_prod_stream_id;
  lv2_prod_stream_id:=p_alt_prod_stream_id;
  lv2_alt_inventory_id:=p_object_id;
  rec_cntr := Ec_Trans_Inv_Li_Pr_Cntracc.row_by_pk(p_object_id,p_daytime,lv2_line_tag,
          lv2_product_id,lv2_cost_type,lv2_type,lv2_account_code,p_prod_stream_id,lv2_source_type,'<=');
  n_ref_id:=n_id;
  ecdp_system_key.assignNextNumber('TRANS_INV_LI_PR_CNTRACC',n_id);


  INSERT INTO Trans_Inv_Li_Pr_Cntracc (
        ACCOUNT_CODE,
        ALT_INVENTORY_ID,
        ALT_PROD_STREAM_ID,
        CONTRACT_TYPE,
        COST_TYPE,
        COUNTRY_IND,
        DATE_1,
        DATE_2,
        DATE_3,
        DATE_4,
        DATE_5,
        DAYTIME,
        DIM_1,
        DIM_2,
        DISABLED_IND,
        END_DATE,
        ID,
        LINE_TAG,
        OBJECT_ID,
        PRODUCT_ID,
        PROD_STREAM_ID,
        REF_ID,
        REF_OBJECT_ID_1,
        REF_OBJECT_ID_2,
        REF_OBJECT_ID_3,
        REF_OBJECT_ID_4,
        REF_OBJECT_ID_5,
        REVERSE_QUANTITY_IND,
        REVERSE_VALUE_IND,
        ROUND_QUANTITY_IND,
        ROUND_VALUE_IND,
        SORT_ORDER,
        SOURCE_TYPE,
        TEXT_1,
        TEXT_10,
        TEXT_2,
        TEXT_3,
        TEXT_4,
        TEXT_5,
        TEXT_6,
        TEXT_7,
        TEXT_8,
        TEXT_9,
        TRANS_DEF_DIMENSION,
        TYPE,
        VALUE_1,
        VALUE_2,
        VALUE_3,
        VALUE_4,
        VALUE_5)
  values
  (rec_cntr.ACCOUNT_CODE,
    lv2_ALT_INVENTORY_ID,
    lv2_ALT_PROD_STREAM_ID,
    rec_cntr.CONTRACT_TYPE,
    rec_cntr.COST_TYPE,
    rec_cntr.COUNTRY_IND,
    rec_cntr.DATE_1,
    rec_cntr.DATE_2,
    rec_cntr.DATE_3,
    rec_cntr.DATE_4,
    rec_cntr.DATE_5,
    rec_cntr.DAYTIME,
    rec_cntr.DIM_1,
    rec_cntr.DIM_2,
    p_DISABLED_IND,
    rec_cntr.END_DATE,
    n_ID,
    rec_cntr.LINE_TAG,
    lv2_OBJECT_ID,
    rec_cntr.PRODUCT_ID,
    lv2_PROD_STREAM_ID,
    n_REf_ID,
    rec_cntr.REF_OBJECT_ID_1,
    rec_cntr.REF_OBJECT_ID_2,
    rec_cntr.REF_OBJECT_ID_3,
    rec_cntr.REF_OBJECT_ID_4,
    rec_cntr.REF_OBJECT_ID_5,
    rec_cntr.REVERSE_QUANTITY_IND,
    rec_cntr.REVERSE_VALUE_IND,
    rec_cntr.ROUND_QUANTITY_IND,
    rec_cntr.ROUND_VALUE_IND,
    rec_cntr.SORT_ORDER,
    rec_cntr.SOURCE_TYPE,
    rec_cntr.TEXT_1,
    rec_cntr.TEXT_10,
    rec_cntr.TEXT_2,
    rec_cntr.TEXT_3,
    rec_cntr.TEXT_4,
    rec_cntr.TEXT_5,
    rec_cntr.TEXT_6,
    rec_cntr.TEXT_7,
    rec_cntr.TEXT_8,
    rec_cntr.TEXT_9,
    rec_cntr.TRANS_DEF_DIMENSION,
    rec_cntr.TYPE,
    rec_cntr.VALUE_1,
    rec_cntr.VALUE_2,
    rec_cntr.VALUE_3,
    rec_cntr.VALUE_4,
    rec_cntr.VALUE_5
);

  p_alt_inventory_id:=lv2_alt_inventory_id;
  p_prod_stream_id  :=lv2_prod_stream_id;
  p_alt_prod_stream_id :=lv2_alt_prod_stream_id;
  p_object_id:=lv2_object_id;
  o_object_id:=p_object_id;
  o_prod_stream_id:=p_prod_stream_id;


END CopyPosting;



PROCEDURE CopyRef(p_alt_key varchar2,
                  o_alt_key in out varchar2,
                  p_REPORT_REF_CONN_ID varchar2,
                  o_REPORT_REF_CONN_ID in out varchar2,
                  p_id in out number,
                  o_id in out number,
                  p_ref_id in out number,
                  p_disabled_ind VARCHAR2 DEFAULT 'N')
  is
  rec_ref report_ref_connection%ROWTYPE;

begin
  rec_ref:=ec_report_ref_connection.row_by_pk(p_id);
  p_ref_id:=p_id;
  ecdp_system_key.assignNextNumber('REPORT_REF_CONNECTION',p_id);

  o_REPORT_REF_CONN_ID := p_REPORT_REF_CONN_ID;
  o_alt_key:=p_alt_key;
  o_id:=p_id;
  INSERT INTO REPORT_REF_CONNECTION
  (
  ALT_KEY,
    COMPANY_ID,
    DATASET,
    DATASET_TYPE,
    DATE_1,
    DATE_10,
    DATE_2,
    DATE_3,
    DATE_4,
    DATE_5,
    DATE_6,
    DATE_7,
    DATE_8,
    DATE_9,
    DAYTIME,
    DIMENSION_2_IND,
    DIMENSION_IND,
    DISABLED_IND,
    DOCUMENT_LEVEL,
    END_DATE,
    ID,
    LAYER_IND,
    LINE_ITEM_TYPE,
    PRICE_CONCEPT_CODE,
    PRICE_ELEMENT_CODE,
    PRODUCT_ID,
    PROD_MTH_IND,
    PROFIT_CENTRE_ID,
    QTY_COLUMN,
    REF_CLASS,
    REF_ID,
    REF_OBJECT_ID_1,
    REF_OBJECT_ID_10,
    REF_OBJECT_ID_2,
    REF_OBJECT_ID_3,
    REF_OBJECT_ID_4,
    REF_OBJECT_ID_5,
    REF_OBJECT_ID_6,
    REF_OBJECT_ID_7,
    REF_OBJECT_ID_8,
    REF_OBJECT_ID_9,
    REPORT_REF_CONN_ID,
    REPORT_REF_ID,
    REVERSE_IND,
    SORT_ORDER,
    TEXT_1,
    TEXT_10,
    TEXT_2,
    TEXT_3,
    TEXT_4,
    TEXT_5,
    TEXT_6,
    TEXT_7,
    TEXT_8,
    TEXT_9,
    TRANS_INV_IND,
    TRANS_LINE_IND,
    VALUE_1,
    VALUE_10,
    VALUE_2,
    VALUE_3,
    VALUE_4,
    VALUE_5,
    VALUE_6,
    VALUE_7,
    VALUE_8,
    VALUE_9,
    VAL_COLUMN)
  VALUES
  (p_ALT_KEY,
    rec_ref.COMPANY_ID,
    rec_ref.DATASET,
    rec_ref.DATASET_TYPE,
    rec_ref.DATE_1,
    rec_ref.DATE_10,
    rec_ref.DATE_2,
    rec_ref.DATE_3,
    rec_ref.DATE_4,
    rec_ref.DATE_5,
    rec_ref.DATE_6,
    rec_ref.DATE_7,
    rec_ref.DATE_8,
    rec_ref.DATE_9,
    rec_ref.DAYTIME,
    rec_ref.DIMENSION_2_IND,
    rec_ref.DIMENSION_IND,
    p_DISABLED_IND,
    rec_ref.DOCUMENT_LEVEL,
    rec_ref.END_DATE,
    p_ID,
    rec_ref.LAYER_IND,
    rec_ref.LINE_ITEM_TYPE,
    rec_ref.PRICE_CONCEPT_CODE,
    rec_ref.PRICE_ELEMENT_CODE,
    rec_ref.PRODUCT_ID,
    rec_ref.PROD_MTH_IND,
    rec_ref.PROFIT_CENTRE_ID,
    rec_ref.QTY_COLUMN,
    rec_ref.REF_CLASS,
    p_REF_ID,
    rec_ref.REF_OBJECT_ID_1,
    rec_ref.REF_OBJECT_ID_10,
    rec_ref.REF_OBJECT_ID_2,
    rec_ref.REF_OBJECT_ID_3,
    rec_ref.REF_OBJECT_ID_4,
    rec_ref.REF_OBJECT_ID_5,
    rec_ref.REF_OBJECT_ID_6,
    rec_ref.REF_OBJECT_ID_7,
    rec_ref.REF_OBJECT_ID_8,
    rec_ref.REF_OBJECT_ID_9,
    p_REPORT_REF_CONN_ID,
    rec_ref.REPORT_REF_ID,
    rec_ref.REVERSE_IND,
    rec_ref.SORT_ORDER,
    rec_ref.TEXT_1,
    rec_ref.TEXT_10,
    rec_ref.TEXT_2,
    rec_ref.TEXT_3,
    rec_ref.TEXT_4,
    rec_ref.TEXT_5,
    rec_ref.TEXT_6,
    rec_ref.TEXT_7,
    rec_ref.TEXT_8,
    rec_ref.TEXT_9,
    rec_ref.TRANS_INV_IND,
    rec_ref.TRANS_LINE_IND,
    rec_ref.VALUE_1,
    rec_ref.VALUE_10,
    rec_ref.VALUE_2,
    rec_ref.VALUE_3,
    rec_ref.VALUE_4,
    rec_ref.VALUE_5,
    rec_ref.VALUE_6,
    rec_ref.VALUE_7,
    rec_ref.VALUE_8,
    rec_ref.VALUE_9,
    rec_ref.VAL_COLUMN);

END;

END EcDp_Trans_Inventory;