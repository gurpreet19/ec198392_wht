CREATE OR REPLACE PACKAGE BODY ECDP_ROYALTY_UTIL IS

  /***********************************************************************
  ** Type           :  ECDP_ROYALTY_UTIL, header
  **
  ** Purpose        :  Facilitate Royalty Data Handling
  **
  **
  ** Documentation  :  www.energy-components.com
  **
  ** Created        : 27.03.2013 Kenneth Masamba
  **
  ** Modification history:
  **
  ** Version  Date        Whom       Change description:
  ** -------  ----------  --------   --------------------------------------
  ** 1.0      27.03.2013  Kenneth Masamba
  ***************************************************************************/


--<EC-DOC>
--------------------------------------------------------------------------------------------------
-- Function       : getProdSortOrder                                                          --
-- Description    : Used to get the correct sort order from the table PRODUCT_GROUP_SETUP     --                                                                                              --
-- Preconditions  :                                                                             --
-- Postconditions :                                                                             --
--                                                                                              --
-- Using tables   : PRODUCT_GROUP_SETUP                                                                          --
-- Configuration  :                                                                             --
-- required       :                                                                             --
-- Behaviour      :                                                                             --
--                                                                                              --
--------------------------------------------------------------------------------------------------
FUNCTION getProdSortOrder(p_product_group_id VARCHAR2, p_product_id VARCHAR2, p_daytime DATE) RETURN NUMBER
--</EC_DOC>
IS

  ln_sort_order    PRODUCT_GROUP_SETUP.Sort_Order%TYPE;

BEGIN

  -- Check if we can use cached value
  SELECT p.Sort_Order INTO  ln_sort_order
    FROM PRODUCT_GROUP_SETUP P
      WHERE OBJECT_ID = p_product_group_id
        AND PRODUCT_ID = p_product_id
        AND DAYTIME <= p_daytime
        AND p_daytime < NVL(END_DATE, p_daytime + 1/(24*60*60));

 RETURN ln_sort_order;

END getProdSortOrder;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      :updateChildShareSeq
-- Description    :The procedure generates seq key used to link parent share contract with child share
--
-- Preconditions  :
-- Postconditions : This precedure is only used by the USA Division Order BF
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
PROCEDURE updateChildShareSeq(p_contract_id VARCHAR2, p_party_role VARCHAR2, p_daytime DATE, p_company_id VARCHAR2)
--</EC-DOC>
IS

  lv_child_share_link_seq NUMBER;

BEGIN

  EcDp_System_Key.assignNextNumber('SKS_DIVISION_ORDER', lv_child_share_link_seq);

  /*UPDATE CONTRACT_PARTY_SHARE A
    SET A.CHILD_SHARE_LINK_SEQ = lv_child_share_link_seq
      WHERE A.OBJECT_ID = p_contract_id
        AND A.PARTY_ROLE = p_party_role
        AND A.DAYTIME = p_daytime
        AND A.COMPANY_ID = p_company_id;*/


END updateChildShareSeq;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      :CreateBurdens
-- Description    :The procedure generates burden entries for each Royalty Owner
--
-- Preconditions  :
-- Postconditions : This precedure is only used by the USA Division Order BF
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
PROCEDURE CreateBurdens(p_do_code VARCHAR2)
--</EC-DOC>
IS

  cursor RoyaltyOwners (cp_do_id VARCHAR2) is
     select * from contract_party_share cps
       where cps.object_id = cp_do_id
       and cps.PARTY_ROLE = 'DIVISION_ORDER'
       and cps.PARTY_OWNER_CLASS = 'ROYALTY_OWNER'
       order by cps.sort_order;

  cursor WorkingInterest (cp_do_id VARCHAR2) is
     select * from contract_party_share cps2
       where cps2.object_id = cp_do_id
       and cps2.PARTY_ROLE = 'DIVISION_ORDER'
       and cps2.PARTY_OWNER_CLASS = 'COMPANY'
       and cps2.interest_type = 'WI'
       order by cps2.sort_order;

  ln_RO_NRI number;
  ln_WI_GWI number;
  ln_burden_NRI number;
  ln_burden_share number;
  lv2_DO_CODE VARCHAR2(32);
  ln_sort_order number;
  ln_ro_cnt number;
  lv2_do_id VARCHAR2(32);

BEGIN

  lv2_do_id := ec_contract.object_id_by_uk(p_do_code);
  ln_sort_order := 10;
  ln_ro_cnt := 0;
  for ro in RoyaltyOwners (lv2_do_id) loop
    ln_ro_cnt := ln_ro_cnt + 1;
    ln_RO_NRI := ro.nri;
    for wi in WorkingInterest (lv2_do_id) loop
      ln_WI_GWI := wi.gwi;
      ln_burden_NRI := ln_RO_NRI * ln_WI_GWI;
      ln_burden_share := ln_WI_GWI * 100;
      INSERT INTO DV_BEARER (
             OBJECT_CODE,
             PARTY_ROLE,
             DAYTIME,
             PARTY_OWNER_CLASS,
             COMPANY_ID,
             NRI,
             EQUITY,
             SORT_ORDER,
             ROYALTY_OWNER_ID)
      VALUES (
             p_do_code,
             'DIVISION_ORDER',
             ro.daytime,
             'COMPANY',
             wi.company_id, --EcDp_Objects.GetObjIDFromCode('COMPANY', 'WI_HOLDER_001'),
             ln_burden_NRI, -- 3.30659559999998E-02,
             ln_burden_share,
             ln_sort_order,
             ro.company_id); --        EcDp_Objects.GetObjIDFromCode('ROYALTY_OWNER', 'US_RO_001'));
      ln_sort_order := ln_sort_order + 10;
    end loop;
    --stop after the first round!
    --if ln_ro_cnt > 2 then
    -- exit;
    --end if;
  end loop;

END CreateBurdens;
END ECDP_ROYALTY_UTIL;