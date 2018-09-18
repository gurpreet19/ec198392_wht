CREATE OR REPLACE PACKAGE BODY ue_Contract_Tran IS
/****************************************************************
** Package        :  ue_Contract_Tran; body part
**
** $Revision: 1.8 $
**
** Purpose        :  User exit package for transport releated functionality on contracts
**          :  Any implementation found here is considered an example implementaiont.
**          :   Project may override and adjust this ue package
**
** Documentation  :  www.energy-components.com
**
** Created        :  03.02.2009  Kari Sandvik
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------
** 12.02.2014   muhammah  ECPD-17241: Added function copyContract, InsNewContractCopy, InsNewContract
**                                    Updated function createPrepareContract
** 13.02.2014   sharawan  ECPD-17241: Modify procedure amendContract
** 17.02.2014	muhammah  ECPD-17241: Updated function InsNewContractCopy, update calculation id per contract
** 21.02.2014   sharawan  ECPD-17241: Updated procedure amendContract to use EcDP_Object_copy.genNewCntrObjName
**                                    to generate name for contract Objects
** 10.10.2014	muhammah  ECPD-28780: Updated function copyContract to copy only one version per object
**                                  : Updated procedure amendContract to copy only one verson per object and upadate startdate/enddate
**************************************************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : amendContract
-- Description    : amend contract to copy the following objects related to new contract copied
--                  1) Contract Capacity
--                  2) Contract Group List
--                  3) Nomination Point
--                  4) Lifting Account
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: EcDp_Object_Copy
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
  -- Contract Capacity Cursor
  CURSOR c_cntr_cap (cp_contract_id VARCHAR2, cp_daytime DATE) IS
  SELECT cc.object_code,
        cc.start_date,
        cc.end_date cc_end_date,
        cc.contract_id,
        cc.location_id,
        cc.capacity_type,
        ccv.name,
        ccv.daytime,
        ccv.end_date ccv_end_date,
        ccv.capacity_uom,
        ccv.def_reserved_capacity,
        ccv.transaction_direction,
        ccv.value_1,
        ccv.value_2,
        ccv.value_3,
        ccv.value_4,
        ccv.value_5,
        ccv.value_6,
        ccv.value_7,
        ccv.value_8,
        ccv.value_9,
        ccv.value_10,
        ccv.text_1,
        ccv.text_2,
        ccv.text_3,
        ccv.text_4,
        ccv.text_5,
        ccv.text_6,
        ccv.text_7,
        ccv.text_8,
        ccv.text_9,
        ccv.text_10,
        ccv.date_1,
        ccv.date_2,
        ccv.date_3,
        ccv.date_4,
        ccv.date_5
  FROM contract_capacity cc, cntr_capacity_version ccv
 WHERE cc.contract_id = cp_contract_id
   AND cc.object_id = ccv.object_id
   AND ccv.daytime =
       (SELECT MAX(ccver.daytime)
          FROM contract_capacity ccap, cntr_capacity_version ccver
         WHERE ccap.object_id = cc.object_id
           AND ccap.object_id = ccver.object_id
           AND cp_daytime < Nvl(ccap.end_date, cp_daytime + 1)
           AND cp_daytime < Nvl(ccver.end_date, cp_daytime + 1));

  -- Contract Group List cursor
  CURSOR c_cc_element (cp_contract_id VARCHAR2, cp_daytime DATE) IS
  SELECT cce.*
    FROM calc_collection_element cce
   WHERE cce.element_id = cp_contract_id
     AND cce.data_class_name = 'CONTRACT_GROUP_LIST'
     AND cce.daytime =
              (select max(cc.daytime)
                 from calc_collection_element cc
                where cc.element_id = cp_contract_id
                  and cp_daytime < nvl(cc.end_date,cp_daytime+1));

    -- Nomination Point Cursor
    CURSOR c_nompnt (cp_contract_id VARCHAR2, cp_daytime DATE) IS
    SELECT
      np.object_code,
      np.start_date,
      np.end_date np_end_date,
      np.contract_id,
      np.delivery_point_id,
      np.entry_location_id,
      np.exit_location_id,
      npv.daytime,
      npv.end_date npv_end_date,
      npv.name,
      npv.calc_rule_id,
      npv.calc_seq,
      npv.alloc_flag,
      npv.uom,
      npv.diagram_layout_info,
      npv.sort_order,
      npv.comments,
      npv.text_1,
      npv.text_2,
      npv.text_3,
      npv.text_4,
      npv.text_5,
      npv.text_6,
      npv.text_7,
      npv.text_8,
      npv.text_9,
      npv.text_10,
      npv.text_11,
      npv.text_12,
      npv.text_13,
      npv.text_14,
      npv.text_15,
      npv.text_16,
      npv.text_17,
      npv.text_18,
      npv.text_19,
      npv.text_20,
      npv.value_1,
      npv.value_2,
      npv.value_3,
      npv.value_4,
      npv.value_5,
      npv.value_6,
      npv.value_7,
      npv.value_8,
      npv.value_9,
      npv.value_10,
      npv.date_1,
      npv.date_2,
      npv.date_3,
      npv.date_4,
      npv.date_5,
      npv.ref_object_id_1,
      npv.ref_object_id_2,
      npv.ref_object_id_3,
      npv.ref_object_id_4,
      npv.ref_object_id_5,
      npv.operational,
      npv.counter_code
    FROM nomination_point np, nompnt_version npv
   WHERE np.contract_id = cp_contract_id
     AND np.object_id = npv.object_id
     AND npv.daytime =
         (SELECT MAX(npver.daytime)
            FROM nomination_point npd, nompnt_version npver
           WHERE npd.object_id = np.object_id
             AND npd.object_id = npver.object_id
             AND cp_daytime < Nvl(npd.end_date, cp_daytime + 1)
             AND cp_daytime < Nvl(npver.end_date, cp_daytime + 1));

    -- Lifting Account Cursor
    CURSOR c_liftacc (cp_contract_id VARCHAR2, cp_daytime DATE) IS
        SELECT
              la.object_code,
              la.start_date,
              la.end_date la_end_date,
              la.company_id,
              la.storage_id,
              la.profit_centre_id,
              la.lift_agreement_ind,
              la.sort_order,
              la.description,
              lav.daytime,
              lav.end_date lav_end_date,
              lav.name,
              lav.contract_id,
              lav.blmr_calculation_id,
              lav.comments,
              lav.text_1,
              lav.text_2,
              lav.text_3,
              lav.text_4,
              lav.text_5,
              lav.text_6,
              lav.text_7,
              lav.text_8,
              lav.text_9,
              lav.text_10,
              lav.value_1,
              lav.value_2,
              lav.value_3,
              lav.value_4,
              lav.value_5,
              lav.date_1,
              lav.date_2,
              lav.date_3,
              lav.date_4,
              lav.date_5,
              lav.ref_object_id_1,
              lav.ref_object_id_2,
              lav.ref_object_id_3,
              lav.ref_object_id_4,
              lav.ref_object_id_5
        FROM LIFTING_ACCOUNT la, LIFT_ACCOUNT_VERSION lav
       WHERE lav.contract_id = cp_contract_id
         AND la.object_id = lav.object_id
         AND lav.daytime =
             (SELECT MAX(laver.daytime)
                FROM LIFTING_ACCOUNT lam, LIFT_ACCOUNT_VERSION laver
               WHERE lam.object_id = la.object_id
                 AND lam.object_id = laver.object_id
                 AND cp_daytime < Nvl(lam.end_date, cp_daytime + 1)
                 AND cp_daytime < Nvl(laver.end_date, cp_daytime + 1));

  -- Variables
  ld_contract_start_date DATE := ec_contract.start_date(p_new_object_id);
  ld_contract_end_date DATE := ec_contract.end_date(p_new_object_id);
  ld_old_cntr_start_date DATE := ec_contract.start_date(p_from_object_id);
  ld_old_cntr_end_date DATE := ec_contract.end_date(p_from_object_id);
  lv2_new_contract_id VARCHAR2(32) := p_new_object_id;
  lv2_from_contract_id VARCHAR2(32) := p_from_object_id;
  lv2_new_contract_code VARCHAR2(32) := ec_contract.object_code(lv2_new_contract_id);
  lv2_from_contract_code VARCHAR2(32) := ec_contract.object_code(lv2_from_contract_id);
  lv2_new_contract_name VARCHAR2(240) := ec_contract_version.name(lv2_new_contract_id, ld_contract_start_date);
  lv2_from_contract_name VARCHAR2(240) := ec_contract_version.name(lv2_from_contract_id, ld_old_cntr_start_date);

  ln_count_rec NUMBER := 0;

  -- Contract Capacity
  lv2_new_contcap_code VARCHAR2(32);
  lv2_new_contcap_name VARCHAR2(240);
  lv2_new_contcap_object_id VARCHAR2(32);

  -- Contract Group List
  lv2_calc_collection_id VARCHAR2(32);

  -- Nomination Point
  lv2_new_nompnt_code VARCHAR2(32);
  lv2_new_nompnt_name VARCHAR2(240);
  lv2_new_nompnt_object_id VARCHAR2(32);

  -- Lifting Account
  lv2_new_la_code VARCHAR2(32);
  lv2_new_la_name VARCHAR2(240);
  lv2_new_la_object_id VARCHAR2(32);

  -- ** 4-eyes approval stuff ** --
  lv2_4e_recid VARCHAR2(32);
  -- ** END 4-eyes approval stuff ** --

BEGIN
    -- Copying contract capacity
    FOR c_val IN c_cntr_cap (p_from_object_id, ld_contract_start_date) LOOP

       -- Generate new Contract Capacity Object Code and Name
       lv2_new_contcap_code := EcDp_Object_Copy.genNewCntrObjCode(lv2_from_contract_code, lv2_new_contract_code, c_val.object_code, 'CONTRACT_CAPACITY');
       lv2_new_contcap_name := EcDp_Object_Copy.genNewCntrObjName(lv2_from_contract_name, lv2_new_contract_name, c_val.name, 'CONTRACT_CAPACITY');

       -- Copy records for new COntract Capacity
       INSERT INTO contract_capacity
           (object_code,
            start_date,
            end_date,
            contract_id,
            location_id,
            capacity_type,
            created_by,
            created_date)
         VALUES
           (lv2_new_contcap_code,
            ld_contract_start_date,
            DECODE(c_val.cc_end_date, NULL, NULL, ld_contract_end_date), --WYH: should check if copied record has end_date value, set end date only if true
            lv2_new_contract_id,
            c_val.location_id,
            c_val.capacity_type,
            p_user,
            Ecdp_Timestamp.getCurrentSysdate)
        RETURNING object_id INTO lv2_new_contcap_object_id;

        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM cntr_capacity_version WHERE object_id=''lv2_new_contcap_object_id''' INTO ln_count_rec;
        IF ln_count_rec < 1 THEN
          -- Copy records into Version table
          INSERT INTO cntr_capacity_version
                 (object_id,
                  daytime,
                  end_date,
                  name,
                  capacity_uom,
                  def_reserved_capacity,
                  transaction_direction,
                  value_1,
                  value_2,
                  value_3,
                  value_4,
                  value_5,
                  value_6,
                  value_7,
                  value_8,
                  value_9,
                  value_10,
                  text_1,
                  text_2,
                  text_3,
                  text_4,
                  text_5,
                  text_6,
                  text_7,
                  text_8,
                  text_9,
                  text_10,
                  date_1,
                  date_2,
                  date_3,
                  date_4,
                  date_5,
                  created_by,
                  created_date)
           VALUES
                  (lv2_new_contcap_object_id,
                  ld_contract_start_date,
                  DECODE(c_val.ccv_end_date, NULL, NULL, ld_contract_end_date), --WYH: should check if copied record has end_date value, set end date only if true
                  lv2_new_contcap_name,
                  c_val.capacity_uom,
                  c_val.def_reserved_capacity,
                  c_val.transaction_direction,
                  c_val.value_1,
                  c_val.value_2,
                  c_val.value_3,
                  c_val.value_4,
                  c_val.value_5,
                  c_val.value_6,
                  c_val.value_7,
                  c_val.value_8,
                  c_val.value_9,
                  c_val.value_10,
                  c_val.text_1,
                  c_val.text_2,
                  c_val.text_3,
                  c_val.text_4,
                  c_val.text_5,
                  c_val.text_6,
                  c_val.text_7,
                  c_val.text_8,
                  c_val.text_9,
                  c_val.text_10,
                  c_val.date_1,
                  c_val.date_2,
                  c_val.date_3,
                  c_val.date_4,
                  c_val.date_5,
                  p_user,
                  Ecdp_Timestamp.getCurrentSysdate);
        END IF;
        ln_count_rec := 0;

        -- ** 4-eyes approval logic ** --
        IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('CONTRACT_CAPACITY'),'N') = 'Y' THEN

          -- Generate rec_id for the new record
          lv2_4e_recid := SYS_GUID();

          -- Set approval info on new record.
          UPDATE contract_capacity
             SET last_updated_by   = Nvl(EcDp_Context.getAppUser, User),
                 last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
                 approval_state    = 'N',
                 rec_id            = lv2_4e_recid,
                 rev_no            = (nvl(rev_no, 0) + 1)
           WHERE object_id = lv2_new_contcap_object_id
             AND contract_id = lv2_new_contract_id;

          -- Register new record for approval
          Ecdp_Approval.registerTaskDetail(lv2_4e_recid,
                                            'CONTRACT_CAPACITY',
                                            Nvl(EcDp_Context.getAppUser,User));
        END IF;
        -- ** END 4-eyes approval ** --

    END LOOP;

    -- Copying Contract Group List
    FOR c_ele IN c_cc_element (p_from_object_id, ld_contract_start_date) LOOP
      lv2_calc_collection_id := c_ele.object_id;

      -- Copy records for new Calc_collection_element
      INSERT INTO calc_collection_element
             (DATA_CLASS_NAME,
              OBJECT_ID,
              DAYTIME,
              ELEMENT_ID,
              END_DATE,
              DIAGRAM_LAYOUT_INFO,
              CREATED_BY,
              CREATED_DATE)
       VALUES
              ( c_ele.DATA_CLASS_NAME,
                lv2_calc_collection_id,
                ld_contract_start_date,
                lv2_new_contract_id,
                DECODE(c_ele.end_date, NULL, NULL, ld_contract_end_date), --WYH: should check if copied record has end_date value, set end date only if true
                c_ele.DIAGRAM_LAYOUT_INFO,
                p_user,
                Ecdp_Timestamp.getCurrentSysdate
              );

    END LOOP;

    -- Copying Nomination Point
    FOR c_val IN c_nompnt (p_from_object_id, ld_contract_start_date) LOOP

       -- Generate new Nomination Point Object Code
       lv2_new_nompnt_code := EcDp_Object_Copy.genNewCntrObjCode(lv2_from_contract_code, lv2_new_contract_code, c_val.object_code, 'NOMINATION_POINT');
       lv2_new_nompnt_name := EcDp_Object_Copy.genNewCntrObjName(lv2_from_contract_name, lv2_new_contract_name, c_val.name, 'NOMINATION_POINT');

       -- Copy records for new Nomination Point
       INSERT INTO nomination_point
           (object_code,
            start_date,
            end_date,
            contract_id,
            delivery_point_id,
            entry_location_id,
            exit_location_id,
            created_by,
            created_date)
         VALUES
           (lv2_new_nompnt_code,
            ld_contract_start_date,
            DECODE(c_val.np_end_date, NULL, NULL, ld_contract_end_date), --WYH: should check if copied record has end_date value, set end date only if true
            lv2_new_contract_id,
            c_val.delivery_point_id,
            c_val.entry_location_id,
            c_val.exit_location_id,
            p_user,
            Ecdp_Timestamp.getCurrentSysdate)
        RETURNING object_id INTO lv2_new_nompnt_object_id;

        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM nompnt_version WHERE object_id=''lv2_new_nompnt_object_id''' INTO ln_count_rec;
        IF ln_count_rec < 1 THEN
          -- Copy records into Version table
          INSERT INTO nompnt_version
                 (object_id,
                  daytime,
                  end_date,
                  name,
                  calc_rule_id,
                  calc_seq,
                  alloc_flag,
                  uom,
                  diagram_layout_info,
                  sort_order,
                  comments,
                  text_1,
                  text_2,
                  text_3,
                  text_4,
                  text_5,
                  text_6,
                  text_7,
                  text_8,
                  text_9,
                  text_10,
                  text_11,
                  text_12,
                  text_13,
                  text_14,
                  text_15,
                  text_16,
                  text_17,
                  text_18,
                  text_19,
                  text_20,
                  value_1,
                  value_2,
                  value_3,
                  value_4,
                  value_5,
                  value_6,
                  value_7,
                  value_8,
                  value_9,
                  value_10,
                  date_1,
                  date_2,
                  date_3,
                  date_4,
                  date_5,
                  ref_object_id_1,
                  ref_object_id_2,
                  ref_object_id_3,
                  ref_object_id_4,
                  ref_object_id_5,
                  operational,
                  counter_code,
                  created_by,
                  created_date)
           VALUES
                  (lv2_new_nompnt_object_id,
                  ld_contract_start_date,
                  DECODE(c_val.npv_end_date, NULL, NULL, ld_contract_end_date), --WYH: should check if copied record has end_date value, set end date only if true
                  lv2_new_nompnt_name,
                  c_val.calc_rule_id,
                  c_val.calc_seq,
                  c_val.alloc_flag,
                  c_val.uom,
                  c_val.diagram_layout_info,
                  c_val.sort_order,
                  c_val.comments,
                  c_val.text_1,
                  c_val.text_2,
                  c_val.text_3,
                  c_val.text_4,
                  c_val.text_5,
                  c_val.text_6,
                  c_val.text_7,
                  c_val.text_8,
                  c_val.text_9,
                  c_val.text_10,
                  c_val.text_11,
                  c_val.text_12,
                  c_val.text_13,
                  c_val.text_14,
                  c_val.text_15,
                  c_val.text_16,
                  c_val.text_17,
                  c_val.text_18,
                  c_val.text_19,
                  c_val.text_20,
                  c_val.value_1,
                  c_val.value_2,
                  c_val.value_3,
                  c_val.value_4,
                  c_val.value_5,
                  c_val.value_6,
                  c_val.value_7,
                  c_val.value_8,
                  c_val.value_9,
                  c_val.value_10,
                  c_val.date_1,
                  c_val.date_2,
                  c_val.date_3,
                  c_val.date_4,
                  c_val.date_5,
                  c_val.ref_object_id_1,
                  c_val.ref_object_id_2,
                  c_val.ref_object_id_3,
                  c_val.ref_object_id_4,
                  c_val.ref_object_id_5,
                  c_val.operational,
                  c_val.counter_code,
                  p_user,
                  Ecdp_Timestamp.getCurrentSysdate);
        END IF;
        ln_count_rec := 0;

        -- ** 4-eyes approval logic ** --
        IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('NOMINATION_POINT'),'N') = 'Y' THEN

          -- Generate rec_id for the new record
          lv2_4e_recid := SYS_GUID();

          -- Set approval info on new record.
          UPDATE NOMINATION_POINT
             SET last_updated_by   = Nvl(EcDp_Context.getAppUser, User),
                 last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
                 approval_state    = 'N',
                 rec_id            = lv2_4e_recid,
                 rev_no            = (nvl(rev_no, 0) + 1)
           WHERE object_id = lv2_new_nompnt_object_id
             AND contract_id = lv2_new_contract_id;

          -- Register new record for approval
          Ecdp_Approval.registerTaskDetail(lv2_4e_recid,
                                            'NOMINATION_POINT',
                                            Nvl(EcDp_Context.getAppUser,User));
        END IF;
        -- ** END 4-eyes approval ** --
    END LOOP;

    -- Copying Lifting Account
    FOR c_la IN c_liftacc (p_from_object_id, ld_contract_start_date) LOOP

       -- Generate new Lifting Account Object Code
       lv2_new_la_code := EcDp_Object_Copy.genNewCntrObjCode(lv2_from_contract_code, lv2_new_contract_code, c_la.object_code, 'LIFTING_ACCOUNT');
       lv2_new_la_name := EcDp_Object_Copy.genNewCntrObjName(lv2_from_contract_name, lv2_new_contract_name, c_la.name, 'LIFTING_ACCOUNT');

       -- Copy records for new Lifting Account
       INSERT INTO LIFTING_ACCOUNT
           (object_code,
            start_date,
            end_date,
            company_id,
            storage_id,
            profit_centre_id,
            lift_agreement_ind,
            sort_order,
            description,
            created_by,
            created_date)
         VALUES
           (lv2_new_la_code,
            ld_contract_start_date,
            DECODE(c_la.la_end_date, NULL, NULL, ld_contract_end_date), --WYH: should check if copied record has end_date value, set end date only if true
            c_la.company_id,
            c_la.storage_id,
            c_la.profit_centre_id,
            c_la.lift_agreement_ind,
            c_la.sort_order,
            c_la.description,
            p_user,
            Ecdp_Timestamp.getCurrentSysdate)
        RETURNING object_id INTO lv2_new_la_object_id;

        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM LIFT_ACCOUNT_VERSION WHERE object_id=''lv2_new_la_object_id''' INTO ln_count_rec;
        IF ln_count_rec < 1 THEN
          -- Copy records into Version table
          INSERT INTO LIFT_ACCOUNT_VERSION
                 (object_id,
                  daytime,
                  end_date,
                  name,
                  contract_id,
                  blmr_calculation_id,
                  comments,
                  text_1,
                  text_2,
                  text_3,
                  text_4,
                  text_5,
                  text_6,
                  text_7,
                  text_8,
                  text_9,
                  text_10,
                  value_1,
                  value_2,
                  value_3,
                  value_4,
                  value_5,
                  date_1,
                  date_2,
                  date_3,
                  date_4,
                  date_5,
                  ref_object_id_1,
                  ref_object_id_2,
                  ref_object_id_3,
                  ref_object_id_4,
                  ref_object_id_5,
                  created_by,
                  created_date)
           VALUES
                  (lv2_new_la_object_id,
                  ld_contract_start_date,
                  DECODE(c_la.lav_end_date, NULL, NULL, ld_contract_end_date), --WYH: should check if copied record has end_date value, set end date only if true
                  lv2_new_la_name,
                  lv2_new_contract_id,
                  c_la.blmr_calculation_id,
                  c_la.comments,
                  c_la.text_1,
                  c_la.text_2,
                  c_la.text_3,
                  c_la.text_4,
                  c_la.text_5,
                  c_la.text_6,
                  c_la.text_7,
                  c_la.text_8,
                  c_la.text_9,
                  c_la.text_10,
                  c_la.value_1,
                  c_la.value_2,
                  c_la.value_3,
                  c_la.value_4,
                  c_la.value_5,
                  c_la.date_1,
                  c_la.date_2,
                  c_la.date_3,
                  c_la.date_4,
                  c_la.date_5,
                  c_la.ref_object_id_1,
                  c_la.ref_object_id_2,
                  c_la.ref_object_id_3,
                  c_la.ref_object_id_4,
                  c_la.ref_object_id_5,
                  p_user,
                  Ecdp_Timestamp.getCurrentSysdate);
        END IF;
        ln_count_rec := 0;

        -- ** 4-eyes approval logic ** --
        IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('LIFTING_ACCOUNT'),'N') = 'Y' THEN

          -- Generate rec_id for the new record
          lv2_4e_recid := SYS_GUID();

          -- Set approval info on new record.
          UPDATE LIFTING_ACCOUNT
             SET last_updated_by   = Nvl(EcDp_Context.getAppUser, User),
                 last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
                 approval_state    = 'N',
                 rec_id            = lv2_4e_recid,
                 rev_no            = (nvl(rev_no, 0) + 1)
           WHERE object_id = lv2_new_la_object_id
             AND storage_id = c_la.storage_id;

          -- Register new record for approval
          Ecdp_Approval.registerTaskDetail(lv2_4e_recid,
                                            'LIFTING_ACCOUNT',
                                            Nvl(EcDp_Context.getAppUser,User));
        END IF;
        -- ** END 4-eyes approval ** --

    END LOOP;

    -- sycnchronize nav model
    ecdp_nav_model_obj_relation.Syncronize_model('TRAN_COMMERCIAL');

END amendContract;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : createPrepareContract
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
PROCEDURE createPrepareContract(p_PREPARE_NO NUMBER, p_user VARCHAR2 DEFAULT NULL)
--<EC-DOC>
IS
  lv_new_object_code VARCHAR2(32);
  lv_new_object_id VARCHAR2(32);

BEGIN

  --call copyContract
  lv_new_object_code := copyContract(ec_contract_prepare.ref_contract_id(p_PREPARE_NO),
                               ec_contract_prepare.daytime(p_PREPARE_NO),
                               ec_contract_prepare.end_date(p_PREPARE_NO),
                               ec_contract_prepare.code(p_PREPARE_NO),
                               p_PREPARE_NO,
                               nvl(p_user, ecdp_context.getAppUser));

  -- update contract with correct code and name
  lv_new_object_id := ecdp_objects.GetObjIDFromCode('CONTRACT', lv_new_object_code);

  update contract set object_code = ec_contract_prepare.code(p_PREPARE_NO) where object_id = lv_new_object_id;
  update contract_version set name = ec_contract_prepare.name(p_PREPARE_NO) where object_id = lv_new_object_id;

  -- call amendContract
  amendContract(lv_new_object_id, ec_contract_prepare.ref_contract_id(p_PREPARE_NO), nvl(p_user, ecdp_context.getAppUser));

  -- call ue_contract_sale.amendContract
  ue_contract_sale.amendContract(lv_new_object_id, ec_contract_prepare.ref_contract_id(p_PREPARE_NO), nvl(p_user, ecdp_context.getAppUser));

  -- call ue_contract_revn.copyContract

  -- Delete prepare contract so that it doesn't show anymore
  -- Or create a status field and update status
  DELETE contract_prepare where PREPARE_NO = p_PREPARE_NO;

END createPrepareContract;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  copyContract
-- Description    :  This user exit is used when a contract is copied.
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:  ue_contract_sale.amendContract, ue_contract_revn.amendContract
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION copyContract(
   p_from_object_id VARCHAR2,
   p_start_date DATE DEFAULT NULL,
   p_end_date DATE DEFAULT NULL,
   p_from_code      VARCHAR2,
   p_prepare_no VARCHAR2 DEFAULT NULL,
   p_user  VARCHAR2)

RETURN VARCHAR2 -- new contract object_id
--</EC-DOC>
IS

-- Valid contract attributes
CURSOR c_attributes (cp_object_id VARCHAR2, cp_daytime DATE) IS
       SELECT *
         FROM contract_attribute
        WHERE object_id = cp_object_id
          AND daytime =
              (select max(ca.daytime)
                 from contract_attribute ca
                where ca.object_id = cp_object_id
                  and ca.attribute_name = contract_attribute.attribute_name
                  and cp_daytime < nvl(ca.end_date,cp_daytime+1));

-- Contract attribute dimension
CURSOR c_attr_dim (cp_object_id VARCHAR2, cp_daytime DATE) IS
       SELECT cad.object_id, cad.attribute_name, cad.dim_code, cad.daytime, cad.end_date, cad.attribute_string, cad.attribute_date, cad.attribute_number
         FROM cntr_attr_dimension cad
         WHERE cad.object_id = cp_object_id
         AND cp_daytime < nvl(cad.end_date, cp_daytime + 1);

-- Contract Parties
CURSOR c_party_share(cp_contract_id VARCHAR2, cp_daytime DATE) IS
SELECT cps.company_id id, cps.party_role, cps.end_date, cps.party_share, cps.exvat_receiver_id, cps.vat_receiver_id, cps.bank_account_id
  FROM contract_party_share cps
 WHERE cps.object_id = cp_contract_id
   AND cp_daytime < nvl(cps.end_date, cp_daytime + 1);

lv2_object_id contract.object_id%TYPE;
lv2_contract_name contract_attribute.attribute_string%TYPE;
ld_contract_start_date DATE := ec_contract.start_date(p_from_object_id);
ld_contract_end_date DATE := ec_contract.end_date(p_from_object_id);

lv2_sql              VARCHAR2(32000);
lv2_attribute_name   VARCHAR2(24);
lv2_dim_code         VARCHAR2(32);
ln_count_rec NUMBER := 0;

no_date_arguments  EXCEPTION;
start_date_out_of_timespan EXCEPTION;
invalid_new_dates2 EXCEPTION;

-- ** 4-eyes approval stuff ** --
lv2_4e_recid VARCHAR2(32);
-- ** END 4-eyes approval stuff ** --

BEGIN

   -- Not allowed to continue if start date and end date is not passed from the business function
   IF p_start_date IS NULL OR p_end_date IS NULL THEN
      RAISE no_date_arguments;
    END IF;

    -- check that the new start date is within the copied contract lifespan
    IF p_start_date <  ld_contract_start_date OR p_start_date >= ld_contract_end_date then
         RAISE start_date_out_of_timespan;
    END IF;

    --new object dates should not be the same
     IF p_start_date >= p_end_date THEN
        RAISE invalid_new_dates2;
     END IF;

    -- Resetting these variables to be the new contract' start date and end date
    ld_contract_start_date := p_start_date;
    ld_contract_end_date := p_end_date;

    -- Creating and preparing the contract and contract attributes
    lv2_object_id := InsNewContractCopy(p_from_object_id,ld_contract_start_date,p_from_code,p_user,ld_contract_end_date);

     -- Inserting contract attributes
    FOR c_val IN c_attributes(p_from_object_id,ld_contract_start_date) LOOP
       INSERT INTO contract_attribute
         (object_id,
          daytime,
          end_date,
          attribute_name,
          attribute_string,
          attribute_date,
          attribute_number,
          created_by)
       VALUES
         (lv2_object_id,
          ld_contract_start_date,
          DECODE(c_val.end_date, NULL, NULL, ld_contract_end_date), --WYH: should check if copied record has end_date value, set end date only if true
          c_val.attribute_name,
          c_val.attribute_string,
          c_val.attribute_date,
          c_val.attribute_number,
          p_user);

        -- ** 4-eyes approval logic ** --
        IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('CONTRACT_ATTRIBUTE'),'N') = 'Y' THEN

          -- Generate rec_id for the new record
          lv2_4e_recid := SYS_GUID();

          -- Set approval info on new record.
          UPDATE contract_attribute
             SET last_updated_by   = Nvl(EcDp_Context.getAppUser, User),
                 last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
                 approval_state    = 'N',
                 rec_id            = lv2_4e_recid,
                 rev_no            = (nvl(rev_no, 0) + 1)
           WHERE object_id = lv2_object_id
             AND daytime = ld_contract_start_date
             AND attribute_name = c_val.attribute_name;

          -- Register new record for approval
          Ecdp_Approval.registerTaskDetail(lv2_4e_recid,
                                            'CONTRACT_ATTRIBUTE',
                                            Nvl(EcDp_Context.getAppUser,User));
        END IF;
        -- ** END 4-eyes approval ** --

    END LOOP;

    -- Inserting contract attributes dimension
    FOR c_val IN c_attr_dim(p_from_object_id,ld_contract_start_date) LOOP

      lv2_attribute_name := c_val.attribute_name;
      lv2_dim_code :=  c_val.dim_code;
      lv2_sql :=  'SELECT COUNT(*) FROM cntr_attr_dimension WHERE object_id=:lv2_object_id' || CHR(10) ||
                  'and attribute_name= :lv2_attribute_name' || CHR(10) ||
                  'and dim_code= :lv2_dim_code' || CHR(10) ||
                  'and daytime= :ld_contract_start_date' ||CHR(10);

      EXECUTE IMMEDIATE lv2_sql INTO ln_count_rec USING lv2_object_id, lv2_attribute_name, lv2_dim_code, ld_contract_start_date;
        IF ln_count_rec < 1 THEN
           INSERT INTO cntr_attr_dimension
             (object_id,
              attribute_name,
              dim_code,
              daytime,
              end_date,
              attribute_string,
              attribute_date,
              attribute_number,
              created_by)
           VALUES
             (lv2_object_id,
              c_val.attribute_name,
              c_val.dim_code,
              ld_contract_start_date,
              DECODE(c_val.end_date, NULL, NULL, ld_contract_end_date), --WYH: should check if copied record has end_date value, set end date only if true
              c_val.attribute_string,
              c_val.attribute_date,
              c_val.attribute_number,
              p_user);
          END IF;
       ln_count_rec := 0;
        -- ** 4-eyes approval logic ** --
        IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('CNTR_ATTR_DIMENSION'),'N') = 'Y' THEN

          -- Generate rec_id for the new record
          lv2_4e_recid := SYS_GUID();

          -- Set approval info on new record.
          UPDATE cntr_attr_dimension
             SET last_updated_by   = Nvl(EcDp_Context.getAppUser, User),
                 last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
                 approval_state    = 'N',
                 rec_id            = lv2_4e_recid,
                 rev_no            = (nvl(rev_no, 0) + 1)
           WHERE object_id = lv2_object_id
             AND daytime = ld_contract_start_date
             AND attribute_name = c_val.attribute_name;

          -- Register new record for approval
          Ecdp_Approval.registerTaskDetail(lv2_4e_recid,
                                            'CNTR_ATTR_DIMENSION',
                                            Nvl(EcDp_Context.getAppUser,User));
        END IF;
        -- ** END 4-eyes approval ** --

    END LOOP;

    -- Inserting party shares
    FOR c_val IN c_party_share(p_from_object_id,ld_contract_start_date) LOOP
        INSERT INTO Contract_Party_Share
          (Object_Id,
           Company_Id,
           Party_Role,
           Daytime,
           End_Date,
           Party_Share,
           Exvat_Receiver_Id,
           Vat_Receiver_Id,
           Bank_Account_Id,
           Created_By)
        VALUES
          (lv2_object_id,
           c_val.id,
           c_val.party_role,
           ld_contract_start_date,
           DECODE(c_val.end_date, NULL, NULL, ld_contract_end_date), --WYH: should check if copied record has end_date value, set end date only if true
           c_val.party_share,
           c_val.exvat_receiver_id,
           c_val.vat_receiver_id,
           c_val.bank_account_id,
           p_user);

        -- ** 4-eyes approval logic ** --
        IF c_val.party_role = 'CUSTOMER' THEN

          IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('CONTRACT_CUST_PARTIES'),'N') = 'Y' THEN

            -- Generate rec_id for the new record
            lv2_4e_recid := SYS_GUID();

            -- Set approval info on new record.
            UPDATE Contract_Party_Share
               SET last_updated_by   = Nvl(EcDp_Context.getAppUser, User),
                   last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
                   approval_state    = 'N',
                   rec_id            = lv2_4e_recid,
                   rev_no            = (nvl(rev_no, 0) + 1)
             WHERE object_id = lv2_object_id
               AND daytime = ld_contract_start_date
               AND company_id = c_val.id
               AND party_role = c_val.party_role;

            -- Register new record for approval
            Ecdp_Approval.registerTaskDetail(lv2_4e_recid,
                                              'CONTRACT_CUST_PARTIES',
                                              Nvl(EcDp_Context.getAppUser,User));
          END IF;

        ELSIF c_val.party_role = 'VENDOR' THEN

          IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('CONTRACT_VEND_PARTIES'),'N') = 'Y' THEN

            -- Generate rec_id for the new record
            lv2_4e_recid := SYS_GUID();

            -- Set approval info on new record.
            UPDATE Contract_Party_Share
               SET last_updated_by   = Nvl(EcDp_Context.getAppUser, User),
                   last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
                   approval_state    = 'N',
                   rec_id            = lv2_4e_recid,
                   rev_no            = (nvl(rev_no, 0) + 1)
             WHERE object_id = lv2_object_id
               AND daytime = ld_contract_start_date
               AND company_id = c_val.id
               AND party_role = c_val.party_role;

            -- Register new record for approval
            Ecdp_Approval.registerTaskDetail(lv2_4e_recid,
                                              'CONTRACT_VEND_PARTIES',
                                              Nvl(EcDp_Context.getAppUser,User));
          END IF;
        END IF;
        -- ** END 4-eyes approval ** --

    END LOOP;

    -- sycnchronize nav model
     ecdp_nav_model_obj_relation.Syncronize_model('TRAN_COMMERCIAL');
     ecdp_nav_model_obj_relation.Syncronize_model('SALE_COMMERCIAL');
     ecdp_nav_model_obj_relation.Syncronize_model('FINANCIAL');

     RETURN ec_contract.object_code(lv2_object_id);

EXCEPTION

         WHEN start_date_out_of_timespan THEN

              Raise_Application_Error(-20000,'New Start Date:' || p_start_date || ' must be within the selected contract''s time span');

         WHEN invalid_new_dates2 THEN

              Raise_Application_Error(-20000,'New Start Date:' || p_start_date || ' should not be the same as New End Date:' || p_end_date || '');

         WHEN no_date_arguments THEN

              Raise_Application_Error(-20000,'Start date and/or end date is missing');

END copyContract;

/*--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  getObjectCodeNumber
-- Description    :
--
-- Preconditions  :
--
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
-------------------------------------------------------------------------------------------------

FUNCTION getObjectCodeNumber (p_object_code  VARCHAR2)
RETURN INTEGER
--</EC-DOC>

IS
   lb_result INTEGER;
BEGIN
  declare
     lv2_object_code_number VARCHAR2(32);
  begin
     lv2_object_code_number :=  SUBSTR(p_object_code, INSTR(p_object_code,'_', 1, LENGTH(p_object_code) - LENGTH(REPLACE(p_object_code,'_','')))+1);
     lb_result := TO_NUMBER(lv2_object_code_number);
  exception
     when others then
        lb_result := 0;
  end;
  return lb_result;
END getObjectCodeNumber;*/

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  InsNewContractCopy
-- Description    :
--
-- Preconditions  :
--
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
-------------------------------------------------------------------------------------------------
FUNCTION InsNewContractCopy(p_object_id  VARCHAR2, -- to copy from
                            p_start_date DATE, -- to copy from
                            p_code       VARCHAR2,
                            p_user       VARCHAR2,
                            p_end_date   DATE)

RETURN VARCHAR2 -- new object_id
--</EC-DOC>
IS


lv_new_obj_daytime DATE;
lrec_old_contract_version contract_version%ROWTYPE;
lv2_default_name  VARCHAR2(240);

CURSOR c_version_obj (cp_object_id VARCHAR2) IS
SELECT c.daytime
FROM   contract_version c
WHERE c.object_id = cp_object_id;


lv2_object_id contract.object_id%TYPE;
lrec_contract contract%ROWTYPE;

BEGIN

lrec_contract := ec_contract.row_by_pk(p_object_id);

     lv2_object_id := InsNewContract(p_object_id,p_code,p_start_date,p_end_date,p_user);

       UPDATE contract
          SET start_year      = lrec_contract.start_year,
              tran_ind        = lrec_contract.tran_ind,
              sale_ind        = lrec_contract.sale_ind,
              revn_ind        = lrec_contract.revn_ind,
              template_code   = lrec_contract.template_code,
              bf_profile      = lrec_contract.bf_profile,
              description     = lrec_contract.description,
              last_updated_by = p_user
        WHERE object_id = lv2_object_id;


-- Expecting one record - one version
FOR v_obj IN c_version_obj(lv2_object_id) LOOP
    lv_new_obj_daytime := v_obj.daytime;
END LOOP;

lrec_old_contract_version := ec_contract_version.row_by_pk(p_object_id,lv_new_obj_daytime,'<=');

lv2_default_name:= lrec_old_contract_version.name||' Copy';
lv2_default_name := Ecdp_Object_Copy.GetCopyObjectName('CONTRACT',lv2_default_name);

       UPDATE contract_version cv
          SET cv.name                    = lv2_default_name,
              cv.sort_order              = lrec_old_contract_version.sort_order,
              cv.calc_rule_id            = lrec_old_contract_version.calc_rule_id,
              cv.calc_seq                = lrec_old_contract_version.calc_seq,
              cv.calc_group              = lrec_old_contract_version.calc_group,
              cv.production_day_id       = lrec_old_contract_version.production_day_id,
              cv.contract_group_code     = lrec_old_contract_version.contract_group_code,
              cv.financial_code          = lrec_old_contract_version.financial_code,
              cv.contract_area_id        = lrec_old_contract_version.contract_area_id,
              cv.company_id              = lrec_old_contract_version.company_id,
              cv.allow_alt_cust_ind      = lrec_old_contract_version.allow_alt_cust_ind,
              cv.contract_term_code      = lrec_old_contract_version.contract_term_code,
              cv.dist_type               = lrec_old_contract_version.dist_type,
              cv.dist_object_type        = lrec_old_contract_version.dist_object_type,
              cv.use_distribution_ind    = lrec_old_contract_version.use_distribution_ind,
              cv.product_type            = lrec_old_contract_version.product_type,
              cv.price_decimals          = lrec_old_contract_version.price_decimals,
              cv.pricing_currency_id     = lrec_old_contract_version.pricing_currency_id,
              cv.booking_currency_id     = lrec_old_contract_version.booking_currency_id,
              cv.memo_currency_id        = lrec_old_contract_version.memo_currency_id,
              cv.uom1_tmpl               = lrec_old_contract_version.uom1_tmpl,
              cv.uom2_tmpl               = lrec_old_contract_version.uom2_tmpl,
              cv.uom3_tmpl               = lrec_old_contract_version.uom3_tmpl,
              cv.uom4_tmpl               = lrec_old_contract_version.uom4_tmpl,
              cv.system_owner            = lrec_old_contract_version.system_owner,
              cv.contract_responsible    = lrec_old_contract_version.contract_responsible,
              cv.legal_owner             = lrec_old_contract_version.legal_owner,
              cv.bank_details_level_code = lrec_old_contract_version.bank_details_level_code,
              cv.document_handling_code  = lrec_old_contract_version.document_handling_code,
              cv.contract_stage_code     = lrec_old_contract_version.contract_stage_code,
              cv.processable_code        = lrec_old_contract_version.processable_code,
			  cv.SA_DAY_CALC_ID          = lrec_old_contract_version.SA_DAY_CALC_ID,
              cv.SA_MTH_CALC_ID          = lrec_old_contract_version.SA_MTH_CALC_ID,
              cv.SA_YR_CALC_ID           = lrec_old_contract_version.SA_MTH_CALC_ID,
              cv.first_delivery_date     = lrec_old_contract_version.first_delivery_date,
              cv.last_delivery_date      = lrec_old_contract_version.last_delivery_date,
              comments                   = lrec_old_contract_version.comments,
              cv.text_1                  = lrec_old_contract_version.text_1,
              cv.text_2                  = lrec_old_contract_version.text_2,
              cv.text_3                  = lrec_old_contract_version.text_3,
              cv.text_4                  = lrec_old_contract_version.text_4,
              cv.text_5                  = lrec_old_contract_version.text_5,
              cv.text_6                  = lrec_old_contract_version.text_6,
              cv.text_7                  = lrec_old_contract_version.text_7,
              cv.text_8                  = lrec_old_contract_version.text_8,
              cv.text_9                  = lrec_old_contract_version.text_9,
              cv.text_10                 = lrec_old_contract_version.text_10,
              cv.text_11                 = lrec_old_contract_version.text_11,
              cv.text_12                 = lrec_old_contract_version.text_12,
              cv.text_13                 = lrec_old_contract_version.text_13,
              cv.text_14                 = lrec_old_contract_version.text_14,
              cv.text_15                 = lrec_old_contract_version.text_15,
              cv.text_16                 = lrec_old_contract_version.text_16,
              cv.text_17                 = lrec_old_contract_version.text_17,
              cv.text_18                 = lrec_old_contract_version.text_18,
              cv.text_19                 = lrec_old_contract_version.text_19,
              cv.text_20                 = lrec_old_contract_version.text_20,
              cv.value_1                 = lrec_old_contract_version.value_1,
              cv.value_2                 = lrec_old_contract_version.value_2,
              cv.value_3                 = lrec_old_contract_version.value_3,
              cv.value_4                 = lrec_old_contract_version.value_4,
              cv.value_5                 = lrec_old_contract_version.value_5,
              cv.value_6                 = lrec_old_contract_version.value_6,
              cv.value_7                 = lrec_old_contract_version.value_7,
              cv.value_8                 = lrec_old_contract_version.value_8,
              cv.value_9                 = lrec_old_contract_version.value_9,
              cv.value_10                = lrec_old_contract_version.value_10,
              cv.date_1                  = lrec_old_contract_version.date_1,
              cv.date_2                  = lrec_old_contract_version.date_2,
              cv.date_3                  = lrec_old_contract_version.date_3,
              cv.date_4                  = lrec_old_contract_version.date_4,
              cv.date_5                  = lrec_old_contract_version.date_5,
              last_updated_by            = p_user
        WHERE object_id = lv2_object_id
          AND daytime = lv_new_obj_daytime;


     -- Update nav_model with the relation contract-contract_area_setup
     Ecdp_Nav_Model_Obj_Relation.Syncronize_model('FINANCIAL');

     RETURN lv2_object_id;

END InsNewContractCopy;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  InsNewContract
-- Description    : Inserts a new contract
--
-- Preconditions  : Should not be used if DAO-model is adequat
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Inserts into main/version table.
--                : The new approach (ECPD-8579) sees to that only one version of the contract and the other child objects are copied.
--                  Since the new contract' start date and end date is validated in the client, there should always be at least one valid object
--                  for the dates that are passed to the procedure behind the "Copy To New" button
--
-------------------------------------------------------------------------------------------------
FUNCTION InsNewContract(p_object_id   VARCHAR2,
                        p_object_code VARCHAR2,
                        p_start_date  DATE,
                        p_end_date    DATE DEFAULT NULL,
                        p_user        VARCHAR2 DEFAULT NULL)
--</EC-DOC>
RETURN VARCHAR2

IS
lv2_default_code  VARCHAR2(100) := p_object_code||'_COPY';
lv2_object_id contract.object_id%TYPE;

-- ** 4-eyes approval stuff ** --
lv2_4e_recid VARCHAR2(32);
-- ** END 4-eyes approval stuff ** --

BEGIN

   lv2_default_code := Ecdp_Object_Copy.GetCopyObjectCode('CONTRACT',lv2_default_code);

   INSERT INTO contract
     (object_code, start_date, end_date, created_by)
   VALUES
     (lv2_default_code, p_start_date, p_end_date, p_user)
   RETURNING object_id INTO lv2_object_id;

   -- WYH: If p_end_date has value, it should also be inserted - as per when new object is created
   INSERT INTO contract_version (object_id, daytime, END_DATE, created_by) VALUES (lv2_object_id, p_start_date, p_end_date, p_user);

    -- ** 4-eyes approval logic ** --
    IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('CONTRACT'),'N') = 'Y' THEN

      -- Generate rec_id for the latest version record
      lv2_4e_recid := SYS_GUID();

      -- Set approval info on latest version record.
      UPDATE contract_version
      SET last_updated_by = Nvl(EcDp_Context.getAppUser,User),
          last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
          approval_state = 'N',
          rec_id = lv2_4e_recid,
          rev_no = (nvl(rev_no,0) + 1)
      WHERE object_id = lv2_object_id
      AND daytime = (SELECT MAX(daytime) FROM contract_version WHERE object_id = lv2_object_id);

      -- Register version record for approval
      Ecdp_Approval.registerTaskDetail(lv2_4e_recid,
                                        'CONTRACT',
                                        Nvl(EcDp_Context.getAppUser,User));
    END IF;
    -- ** END 4-eyes approval ** --

   RETURN lv2_object_id;

END InsNewContract;

END ue_Contract_Tran;