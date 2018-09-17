CREATE OR REPLACE PACKAGE BODY ue_Contract_Sale IS
/****************************************************************
** Package        :  ue_Contract_Sale; body part
**
** $Revision: 1.5 $
**
** Purpose        :  User exit package for sale releated functionality on contracts
**				  :  Any implementation found here is considered an example implementaiont.
**				  :	 Project may override and adjust this ue package
**
** Documentation  :  www.energy-components.com
**
** Created        :  03.02.2009	Kari Sandvik
**
** Modification history:
**
** Date        Whom  			Change description:
** ----------  ----- 			-------------------------------------------
** 10/02/2014  Khairul Affendi  ECPD-17240: Add copy contract features to ue_contract_sale
** 21/02/2014  Khairul Affendi  ECPD-17240: Updated procedure amendContract to use EcDP_Object_copy.genNewCntrObjName to generate name for contract Objects
** 24/07/2014  muhammah			ECPD-26255: added procedure useAccountTemplate
** 02/10/2014  Khairul Affendi	ECPD-28838: Copy features in ue_contract_sale: Contract Account not copied
**************************************************************************************************/
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : amendContract
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE amendContract(
  p_new_object_id VARCHAR2,
  p_from_object_id VARCHAR2,
  p_user VARCHAR2)
--<EC-DOC>
IS

-- Price Objects Cursor
  CURSOR c_product_price (cp_contract_id VARCHAR2, cp_daytime DATE) IS
  SELECT pp.object_id,
         pp.object_code,
         pp.product_id,
         pp.start_date,
         pp.end_date,
         pp.price_concept_code,
         pp.revn_ind,
         pp.description,
         ppv.daytime,
         ppv.quantity_status,
         ppv.price_status,
         ppv.pr_calc_id,
         ppv.name
  FROM product_price pp, product_price_version ppv
  WHERE pp.contract_id = cp_contract_id
  AND pp.object_id = ppv.object_id
  AND ppv.daytime =
       (SELECT MAX(ppver.daytime)
          FROM product_price prpr, product_price_version ppver
         WHERE prpr.object_id = pp.object_id
           AND prpr.object_id = ppver.object_id
           AND cp_daytime < Nvl(prpr.end_date, cp_daytime + 1)
           AND cp_daytime < Nvl(ppver.end_date, cp_daytime + 1));

  -- Contract Accounts Cursor
  CURSOR c_contract_acc (cp_object_id VARCHAR2) IS
  SELECT ca.object_id,
          ca.daytime,
          ca.account_code,
          ca.name,
          ca.x1_uom,
          ca.x2_uom,
          ca.x3_uom,
          ca.price_concept_code,
          ca.product_id,
          ca.delivery_point_id,
          ca.sort_order,
          ca.description,
          ca.quantity_status,
          ca.source_node_id,
          ca.VALUE_1,
          ca.VALUE_2,
          ca.VALUE_3,
          ca.VALUE_4,
          ca.VALUE_5,
          ca.VALUE_6,
          ca.VALUE_7,
          ca.VALUE_8,
          ca.VALUE_9,
          ca.VALUE_10,
          ca.TEXT_1,
          ca.TEXT_2,
          ca.TEXT_3,
          ca.TEXT_4,
          ca.REF_OBJECT_ID_1,
          ca.REF_OBJECT_ID_2,
          ca.REF_OBJECT_ID_3,
          ca.REF_OBJECT_ID_4,
          ca.REF_OBJECT_ID_5
    FROM contract_account ca
    WHERE ca.object_id = cp_object_id;

  -- Variables
  ld_contract_start_date DATE := ec_contract.start_date(p_new_object_id);
  ld_contract_end_date DATE := ec_contract.end_date(p_new_object_id);
  ld_old_cntr_start_date DATE := ec_contract.start_date(p_from_object_id);
  lv2_new_contract_id VARCHAR2(32) := p_new_object_id;
  lv2_from_contract_id VARCHAR2(32) := p_from_object_id;
  lv2_new_contract_code VARCHAR2(32) := ec_contract.object_code(lv2_new_contract_id);
  lv2_from_contract_code VARCHAR2(32) := ec_contract.object_code(lv2_from_contract_id);
  lv2_new_contract_name VARCHAR2(240) := ec_contract_version.name(lv2_new_contract_id, ld_contract_start_date);
  lv2_from_contract_name VARCHAR2(240) := ec_contract_version.name(lv2_from_contract_id, ld_old_cntr_start_date);

  -- Product Price
  lrec_prod_price_version product_price_version%ROWTYPE;
  lv2_new_prodprice_code VARCHAR2(32);
  lv2_new_prodprice_name VARCHAR2(240);
  lv2_new_prodprice_object_id VARCHAR2(32);

  -- Contract Account
  lv2_new_contractacc_object_id VARCHAR2(32):= p_new_object_id;

  -- ** 4-eyes approval stuff ** --
  lv2_4e_recid VARCHAR2(32);
  -- ** END 4-eyes approval stuff ** --

BEGIN

   -- Copying Price Object
    FOR c_val IN c_product_price (p_from_object_id, ld_contract_start_date) LOOP

       lv2_new_prodprice_code := EcDp_Object_Copy.genNewCntrObjCode(lv2_from_contract_code, lv2_new_contract_code, c_val.object_code, 'PRICE_OBJECT');
       lv2_new_prodprice_name := EcDp_Object_Copy.genNewCntrObjName(lv2_from_contract_name, lv2_new_contract_name, c_val.name, 'PRICE_OBJECT');

       -- Copy records to new Product Price
       INSERT INTO product_price
         (object_code,
          product_id,
          start_date,
          end_date,
          contract_id,
          price_concept_code,
          revn_ind,
          description,
          created_by,
          class_name)
       VALUES
         (lv2_new_prodprice_code,
          c_val.product_id,
          ld_contract_start_date,
          DECODE(c_val.end_date, TO_DATE(NULL), TO_DATE(NULL), ld_contract_end_date),
          p_new_object_id,
          c_val.price_concept_Code,
          c_val.revn_ind,
          c_val.description,
          p_user,
          'PRICE_OBJECT')
       RETURNING object_id INTO lv2_new_prodprice_object_id;

       lrec_prod_price_version := ec_product_price_version.row_by_pk(c_val.object_id,ld_contract_start_date,'<=');

       -- Copy records into Version table
          INSERT INTO product_price_version
            (object_id,
             daytime,
             end_date,
             name,
             currency_id,
             uom,
             quantity_status,
             price_status,
             pr_calc_id,
             calc_seq,
             calc_rule_id,
             price_group,
             PRICE_ROUNDING_RULE,
             comments,
             text_10, -- Used temporarily to store "old" price object
             created_by)
          VALUES
            (lv2_new_prodprice_object_id,
             ld_contract_start_date,
             decode(lrec_prod_price_version.end_date,
                    TO_DATE(NULL),
                    TO_DATE(NULL),
                    ld_contract_end_date),
             lv2_new_prodprice_name,
             lrec_prod_price_version.currency_id,
             lrec_prod_price_version.uom,
             lrec_prod_price_version.quantity_status,
             lrec_prod_price_version.price_status,
             lrec_prod_price_version.pr_calc_id,
             lrec_prod_price_version.calc_seq,
             lrec_prod_price_version.calc_rule_id,
             lrec_prod_price_version.price_group,
             nvl(lrec_prod_price_version.price_rounding_rule,'BY_PRICE_ELEMENT'),
             lrec_prod_price_version.comments,
             c_val.object_id,
             p_user);

            -- ** 4-eyes approval logic ** --
            IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('PRICE_OBJECT'),'N') = 'Y' THEN

              -- Generate rec_id for the new version record
              lv2_4e_recid := SYS_GUID();

              -- Set approval info on version record. PS! Never do this on a main object table. Approval is only intended for the version attributes.
              UPDATE product_price_version
                 SET last_updated_by   = Nvl(EcDp_Context.getAppUser, User),
                     last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
                     approval_state    = 'N',
                     rec_id            = lv2_4e_recid,
                     rev_no            = (nvl(rev_no, 0) + 1)
               WHERE object_id = lv2_new_prodprice_object_id
                 AND daytime = ld_contract_start_date;

              -- Register version record for approval
              Ecdp_Approval.registerTaskDetail(lv2_4e_recid,
                                                'PRICE_OBJECT',
                                                Nvl(EcDp_Context.getAppUser,User));
            -- ** END 4-eyes approval ** --
            END IF;

            IF NVL(EcDp_ClassMeta_Cnfg.getAccessControlInd('PRICE_OBJECT'),'N') = 'Y' THEN
               ecdp_acl.RefreshObject(lv2_new_prodprice_object_id,'PRICE_OBJECT','INSERTING');
            END IF;

    END LOOP;

    -- Copying Contract Account
    FOR c_con IN c_contract_acc (p_from_object_id) LOOP

        -- Copy records for new Contract_Account
        INSERT INTO contract_account
               (object_id,
			    daytime,
                account_code,
                name,
                x1_uom,
                x2_uom,
                x3_uom,
                price_concept_code,
                product_id,
                delivery_point_id,
                sort_order,
                description,
                quantity_status,
                source_node_id,
                VALUE_1,
                VALUE_2,
                VALUE_3,
                VALUE_4,
                VALUE_5,
                VALUE_6,
                VALUE_7,
                VALUE_8,
                VALUE_9,
                VALUE_10,
                TEXT_1,
                TEXT_2,
                TEXT_3,
                TEXT_4,
                REF_OBJECT_ID_1,
                REF_OBJECT_ID_2,
                REF_OBJECT_ID_3,
                REF_OBJECT_ID_4,
                REF_OBJECT_ID_5,
  	            created_by,
                created_date)
         VALUES
  	           (lv2_new_contractacc_object_id,
			    NVL(ld_contract_start_date, c_con.daytime),
                c_con.account_code,
                c_con.name,
                c_con.x1_uom,
                c_con.x2_uom,
                c_con.x3_uom,
                c_con.price_concept_code,
                c_con.product_id,
                c_con.delivery_point_id,
                c_con.sort_order,
                c_con.description,
                c_con.quantity_status,
                c_con.source_node_id,
                c_con.VALUE_1,
                c_con.VALUE_2,
                c_con.VALUE_3,
                c_con.VALUE_4,
                c_con.VALUE_5,
                c_con.VALUE_6,
                c_con.VALUE_7,
                c_con.VALUE_8,
                c_con.VALUE_9,
                c_con.VALUE_10,
                c_con.TEXT_1,
                c_con.TEXT_2,
                c_con.TEXT_3,
                c_con.TEXT_4,
                c_con.REF_OBJECT_ID_1,
                c_con.REF_OBJECT_ID_2,
                c_con.REF_OBJECT_ID_3,
                c_con.REF_OBJECT_ID_4,
                c_con.REF_OBJECT_ID_5,
                p_user,
                Ecdp_Timestamp.getCurrentSysdate);

        -- ** 4-eyes approval logic ** --
        IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('CONTRACT_ACCOUNT'),'N') = 'Y' THEN

          -- Generate rec_id for the new record
          lv2_4e_recid := SYS_GUID();

          -- Set approval info on new record.
          UPDATE CONTRACT_ACCOUNT
             SET last_updated_by   = Nvl(EcDp_Context.getAppUser, User),
                 last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
                 approval_state    = 'N',
                 rec_id            = lv2_4e_recid,
                 rev_no            = (nvl(rev_no, 0) + 1)
           WHERE object_id = lv2_new_contractacc_object_id;

          -- Register new record for approval
          Ecdp_Approval.registerTaskDetail(lv2_4e_recid,
                                            'CONTRACT_ACCOUNT',
                                            Nvl(EcDp_Context.getAppUser,User));
        END IF;
        -- ** END 4-eyes approval ** --

      END LOOP;

      -- sycnchronize nav model
     ecdp_nav_model_obj_relation.Syncronize_model('TRAN_COMMERCIAL');
     ecdp_nav_model_obj_relation.Syncronize_model('SALE_COMMERCIAL');
     ecdp_nav_model_obj_relation.Syncronize_model('FINANCIAL');

END amendContract;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : useAccountTemplate
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE useAccountTemplate(p_contract_id VARCHAR2, p_tmpl_code VARCHAR2, p_daytime DATE)
--</EC-DOC>
IS

BEGIN

	EcDp_Sales_Contract.useAccountTemplate(p_contract_id, p_tmpl_code, p_daytime);

END useAccountTemplate;

END ue_Contract_Sale;