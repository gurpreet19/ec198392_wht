CREATE OR REPLACE PACKAGE BODY EcBp_Replicate_Sale_Qty IS
/****************************************************************
** Package        :  EcBp_Replicate_Sale_Qty
**
** $Revision: 1.10 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created        :  19.04.2006  Jean Ferre
**
** Modification history:
**
** Date        Whom  		Change description:
** ------      ----- 		-----------------------------------------------------------------------------------------------
** 19.04.2006  Jean Ferre  Initial version
** 11.05.2006  KSN			   Rewrite
** 25.09.2015  ARVID       Rewrite
******************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : insertSalesQty
-- Description    : Inserting sales quantities to EC Revenue interface ifac_sales_qty
--                  This procedure is typically called from the IUD trigger of the classes holding the
--                  Contract Account data:
--                    - DV_SCTR_ACC_MTH_STATUS / IUD_SCTR_ACC_YR_STATUS
--                    - DV_SCTR_ACC_MTH_PC_STATUS / IUD_SCTR_ACC_YR_PC_STATUS
--                    - DV_SCTR_ACC_MTH_PC_CPY_STATUS / DV_SCTR_ACC_YR_PC_CPY_STATUS
--                  When called from IUD_SCTR_ACC_MTH_STATUS there is no Profit Centre available directly
--                  so the logic will try to find a Profit Centre to use from the Contract config.
--                  If the Contract is a truly Single Profit Centre type of contract then we can find the
--                  Profit Centre in question and use this for the inserts to the IFAC table.
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
---------------------------------------------------------------------------------------------------
PROCEDURE insertSalesQty(
            p_class_name  VARCHAR2,
            p_object_id		VARCHAR2,
						p_account_code		VARCHAR2,
						p_profit_centre_id	VARCHAR2,
						p_company_id	VARCHAR2,  --NOTE This is a COMPANY Object!
						p_time_span			VARCHAR2,
						p_daytime			DATE,
						p_vol_qty			NUMBER,
						p_mass_qty			NUMBER,
						p_energy_qty		NUMBER,
						p_user				VARCHAR2,
            p_doc_status        VARCHAR2 DEFAULT NULL,
            p_approved    boolean default false
)
IS

BEGIN
  IF UE_Replicate_Sale_Qty.isinsertSalesQtyUEE = 'TRUE' THEN
    --UE support
    UE_Replicate_Sale_Qty.ue_insertSalesQty(p_class_name,
                                            p_object_id,
                                            p_account_code,
                                            p_profit_centre_id,
                                            p_company_id,
                                            p_time_span,
                                            p_daytime,
                                            p_vol_qty,
                                            p_mass_qty,
                                            p_energy_qty,
                                            p_user,
                                            p_doc_status);
  ELSE
    --check if the REVN_IND has been set to 'Y'
    IF nvl(ec_contract.revn_ind(p_object_id),'N') = 'Y' THEN
      --Yes - good
      --Check if the 'Interface to Revenue' flag has been set
      IF nvl(ec_contract_account.interface_to_revenue(p_object_id, p_account_code),'N') = 'N' THEN
        --This contract Account is not configured for interfacing to EC Revenue
        --do nada
        null;
      ELSE
        --This contract Account is configured for interfacing to EC Revenue - good!
        --Check if interfacing to IFAC should only happen to APPROVED data
        IF nvl(ec_contract_version.calc_approval_check(p_object_id, p_daytime, '<='),'N') = 'N' or p_approved = true THEN
          --No approval required - go ahead
          --Find which level we are interfacing
          IF p_profit_centre_id is null and p_company_id is null THEN
            --Interfacing at Transaction Level
            IFAC_TRANSACTION_LEVEL(p_class_name,
                               p_object_id,
                               p_account_code,
                               p_time_span,
                               p_daytime,
                               p_vol_qty,
                               p_mass_qty,
                               p_energy_qty,
                               p_user,
                               p_doc_status);
          ELSIF p_profit_centre_id is not null and p_company_id is null THEN
            --Interfacing at Profit Centre Level
            IFAC_PROFIT_CENTRE_LEVEL(p_class_name,
                            p_object_id,
                            p_account_code,
                            p_profit_centre_id,
                            p_time_span,
                            p_daytime,
                            p_vol_qty,
                            p_mass_qty,
                            p_energy_qty,
                            p_user,
                            p_doc_status);
          ELSE
            --interfacing at Company Level
            IFAC_COMPANY_LEVEL(p_class_name,
                                  p_object_id,
                                  p_account_code,
                                  p_profit_centre_id,
                                  p_company_id,  --NOTE! This is a Company object - not a Vendor object!
                                  p_time_span,
                                  p_daytime,
                                  p_vol_qty,
                                  p_mass_qty,
                                  p_energy_qty,
                                  p_user,
                                  p_doc_status);
          END IF;
        ELSE
          --insert to IFAC only after Calculation Approval
          --In this case we don't do anything from here.
          --There will be a separate procedure that will pick up the approved contract account data records
          --and do the inserts to IFAC
          null;
        END IF;
      END IF;
    ELSE
      --Contract REVN_IND = N
      --do nada
      null;
    END IF;
  END IF; --UE Support
END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : IFAC_TRANSACTION_LEVEL
-- Description    : Inserting sales quantities to EC Revenue interface ifac_sales_qty
--                  at Transaction Level, e.g. No Profit Centre given.
--                  The only case we can interface from this level - DV_SCTR_ACC_MTH_STATUS - is when
--                  the contract is tryly a Single Profit Center type of contract:
--                  - All Transaction Templates are defined as 'Single Profit Centre Allocation'
--                  - Allocating to ONE and ONLY ONE Profit Centre.
--                  For all other cases the EC Sales quantity data should be interfaced from the Profit Centre
--                  level: DV_SCTR_ACC_MTH_PC_STATUS
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
---------------------------------------------------------------------------------------------------
PROCEDURE IFAC_TRANSACTION_LEVEL(
            p_class_name  VARCHAR2,
            p_object_id		VARCHAR2,
            p_account_code		VARCHAR2,
						p_time_span			VARCHAR2,
						p_daytime			DATE,
						p_vol_qty			NUMBER,
						p_mass_qty			NUMBER,
						p_energy_qty		NUMBER,
						p_user				VARCHAR2,
            p_doc_status        VARCHAR2 DEFAULT NULL
)

IS

  lv2_profit_centre_id   VARCHAR2(32);
  lv2_dist_object_type   VARCHAR2(32);
  lv2_dist_code          VARCHAR2(32);
  lv2_debug_mode         VARCHAR2(32);
  lv2_contract_code      VARCHAR2(32);
  ln_mpc_cnt             NUMBER;
  ln_dist_type_cnt       NUMBER;
  ln_dist_code_cnt       NUMBER;

--EXCEPTIONS
  MULTI_PC               EXCEPTION;
  MULTI_DIST_TYPE        EXCEPTION;
  MULTI_DIST_CODE        EXCEPTION;

  --Cursor for finding Multi Profit Centre Transaction Templates
  cursor c_TT_MultiProfitCentres is
    select ttv.*
    from transaction_template tt,
         transaction_tmpl_version ttv,
         contract_doc cd,
         contract c
     where ttv.object_id = tt.object_id
     and cd.object_id = tt.contract_doc_id
     and cd.contract_id = c.object_id
     and c.object_id = p_object_id
     and ttv.dist_type = 'OBJECT_LIST'
     and ttv.daytime <= p_daytime
     and p_daytime < nvl(ttv.end_date,p_daytime+1);

  --Cursor for finding distinct Dist Type for Transaction Templates
  cursor c_TT_DistinctDistType is
    select distinct ttv.dist_type
    from transaction_template tt,
         transaction_tmpl_version ttv,
         contract_doc cd,
         contract c
     where ttv.object_id = tt.object_id
     and cd.object_id = tt.contract_doc_id
     and cd.contract_id = c.object_id
     and c.object_id = p_object_id
     and ttv.daytime <= p_daytime
     and p_daytime < nvl(ttv.end_date,p_daytime+1);

  --Cursor for finding distinct Dist Code for Transaction Templates
  cursor c_TT_DistinctDistCode is
    select distinct ttv.dist_code, ttv.dist_object_type
    from transaction_template tt,
         transaction_tmpl_version ttv,
         contract_doc cd,
         contract c
     where ttv.object_id = tt.object_id
     and cd.object_id = tt.contract_doc_id
     and cd.contract_id = c.object_id
     and c.object_id = p_object_id
     and ttv.daytime <= p_daytime
     and p_daytime < nvl(ttv.end_date,p_daytime+1);


BEGIN
  IF ue_replicate_sale_qty.isIFAC_TRANSACTION_LEVELUEE = 'TRUE' THEN
    --Call UE package
    ue_replicate_sale_qty.ue_IFAC_TRANSACTION_LEVEL(
                    p_class_name,
                    p_object_id,
                    p_account_code,
                    p_time_span,
                    p_daytime,
                    p_vol_qty,
                    p_mass_qty,
                    p_energy_qty,
                    p_user,
                    p_doc_status);
  ELSE
    lv2_debug_mode := ec_ctrl_system_attribute.attribute_text(p_daytime,'IFAC_DEBUG','<=');
    IF lv2_debug_mode = 'Y' THEN
        --delete from t_temptext where id = 'IFAC_TRANSACTION_LEVEL';
        ecdp_dynsql.WriteTempText('IFAC_TRANSACTION_LEVEL', 'p_class_name is ' || p_class_name);
        ecdp_dynsql.WriteTempText('IFAC_TRANSACTION_LEVEL', 'p_object_id is ' || p_object_id);
        ecdp_dynsql.WriteTempText('IFAC_TRANSACTION_LEVEL', 'Code for p_object_id is ' || ecdp_objects.GetObjCode(p_object_id));
        ecdp_dynsql.WriteTempText('IFAC_TRANSACTION_LEVEL', 'p_account_code is ' || p_account_code);
        ecdp_dynsql.WriteTempText('IFAC_TRANSACTION_LEVEL', 'p_time_span is ' || p_time_span);
        ecdp_dynsql.WriteTempText('IFAC_TRANSACTION_LEVEL', 'p_daytime is ' || p_daytime);
        ecdp_dynsql.WriteTempText('IFAC_TRANSACTION_LEVEL', 'p_vol_qty is ' || p_vol_qty);
        ecdp_dynsql.WriteTempText('IFAC_TRANSACTION_LEVEL', 'p_mass_qty is ' || p_mass_qty);
        ecdp_dynsql.WriteTempText('IFAC_TRANSACTION_LEVEL', 'p_energy_qty is ' || p_energy_qty);
        ecdp_dynsql.WriteTempText('IFAC_TRANSACTION_LEVEL', 'p_user is ' || p_user);
    END IF;

    lv2_contract_code := ecdp_objects.GetObjCode(p_object_id);

    --Check if NONE the Transaction Templates for the contract have been set up to be 'Multi Profit Centre Allocation'
    ln_mpc_cnt := 0;
    for x in c_TT_MultiProfitCentres loop
      ln_mpc_cnt := ln_mpc_cnt +1;
    end loop;
    IF ln_mpc_cnt > 0 THEN
      --The contract has one or more Transaction Templates that have been set up as Multi Profit Centre
      --Error
      raise MULTI_PC;
    END IF;

    --Check if all the Transaction Templates are all using the same Dist Object Type, like FIELD / WELL / etc
    ln_dist_type_cnt := 0;
    for x in c_TT_DistinctDistType loop
      ln_dist_type_cnt := ln_dist_type_cnt + 1;
    end loop;
    IF ln_dist_type_cnt > 1 THEN
      --The contract has Transaction Templates that allocates to more than one object type,
      --like FIELD and WELL
      --Error:
      raise MULTI_DIST_TYPE;
    END IF;

    --Check if all Transaction Templates are using ONE and ONLY ONE Dist Code
    ln_dist_code_cnt := 0;
    for x2 in c_TT_DistinctDistCode loop
      ln_dist_code_cnt := ln_dist_code_cnt + 1;
      lv2_dist_code := x2.dist_code;
      lv2_dist_object_type := x2.dist_object_type;
    end loop;
    IF ln_dist_code_cnt > 1 THEN
      --The contract has Transaction Templates that allocates to more than one object,
      --like FIELD A and FIELD B
      --Error:
      raise MULTI_DIST_CODE;
    END IF;

    --Now we have established:
    -- All Transaction Templates of the Contract are Single Profit Centre type
    -- All Transaction Templates of the Contract are allocating to ONE type of objects
    -- All Transaction Templates of the Contract are allocating to the SAME object

    --Find the object ID of the Profit Centre defined by the DIST_TYPE and DIST_CODE
    lv2_profit_centre_id := ecdp_objects.GetObjIDFromCode(lv2_dist_object_type, lv2_dist_code);
    IFAC_PROFIT_CENTRE_LEVEL(p_class_name,
                    p_object_id,
                    p_account_code,
                    lv2_profit_centre_id,
                    p_time_span,
                    p_daytime,
                    p_vol_qty,
                    p_mass_qty,
                    p_energy_qty,
                    p_user,
                    p_doc_status);
  END IF; --UE Check
EXCEPTION

       WHEN MULTI_PC THEN
         Raise_Application_Error(-20000,'Contract '|| lv2_contract_code || ' has Transaction Templates configured as Multi Profit Centre. Interfacing to EC Revenue at Contract Account level not supported for this case. Use Contract Account / Profit Centre instead.');
       WHEN MULTI_DIST_TYPE THEN
         Raise_Application_Error(-20000,'Contract '|| lv2_contract_code || ' has Transaction Templates configured for various Profit Centres types. Interfacing to EC Revenue at Contract Account level not supported for this case. Use Contract Account / Profit Centre instead.');
       WHEN MULTI_DIST_CODE THEN
         Raise_Application_Error(-20000,'Contract '|| lv2_contract_code || ' has Transaction Templates configured for various Profit Centres. Interfacing to EC Revenue at Contract Account level not supported for this case. Use Contract Account / Profit Centre instead.');
END IFAC_TRANSACTION_LEVEL;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : IFAC_PROFIT_CENTRE_LEVEL
-- Description    : Inserting sales quantities to EC Revenue interface ifac_sales_qty
--                  at Profit Centre Level, e.g. Profit Centre given
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
---------------------------------------------------------------------------------------------------
PROCEDURE IFAC_PROFIT_CENTRE_LEVEL(
            p_class_name  VARCHAR2,
            p_object_id		VARCHAR2,
            p_account_code		VARCHAR2,
            p_profit_centre_id VARCHAR2,
						p_time_span			VARCHAR2,
						p_daytime			DATE,
						p_vol_qty			NUMBER,
						p_mass_qty			NUMBER,
						p_energy_qty		NUMBER,
						p_user				VARCHAR2,
            p_doc_status        VARCHAR2 DEFAULT NULL
)

IS
  CURSOR c_ContractVendorList IS
    SELECT cps.company_id as company_id,
           cps.party_share/100 as party_share --70% stored as 70 - divide by 100 to get fraction
    FROM CONTRACT_PARTY_SHARE cps
    WHERE cps.object_id = p_object_id
      AND cps.daytime <= p_daytime
      AND cps.party_role = 'VENDOR'
      AND nvl(cps.end_date, p_daytime +1 ) > p_daytime;

  CURSOR c_FullVendorList (cp_full_vendor_code VARCHAR2) IS
    SELECT c.*
    FROM COMPANY c
    WHERE c.class_name = 'VENDOR'
      AND c.object_code = cp_full_vendor_code;

--Debug mode:
  lv2_debug_mode                 VARCHAR2(32);
  lv2_company_id                 VARCHAR2(32);
  lv2_company_code               VARCHAR2(32);
  lv2_contract_code              VARCHAR2(32);
  ln_party_share                 NUMBER;
  ln_vendor_cnt                  NUMBER;
  lv2_contract_owner_company_id  VARCHAR2(32);
  lv2_country_id                 VARCHAR2(32);
  lv2_country_code               VARCHAR2(32);
  lv2_full_vendor_code           VARCHAR2(32);
  lv2_full_vendor_id             VARCHAR2(32);
  ln_full_vendor_cnt             NUMBER;
  lv2_IFAC_PC_UseFullVendor      VARCHAR2(32);

--EXCEPTIONS
  MISSING_PARTY_SHARE EXCEPTION;
  MULTIPLE_FULL_VENDORS EXCEPTION;
  MISSING_FULL_VENDOR EXCEPTION;
  NO_VENDORS_IN_CONTRACT EXCEPTION;

BEGIN

  IF UE_Replicate_Sale_Qty.isIFAC_PROFIT_CENTRE_LEVELUEE = 'TRUE' then
    --call UE
    UE_Replicate_Sale_Qty.ue_IFAC_PROFIT_CENTRE_LEVEL(p_class_name,
                                                p_object_id,
						                                    p_account_code,
						                                    p_profit_centre_id,
						                                    p_time_span,
						                                    p_daytime,
						                                    p_vol_qty,
						                                    p_mass_qty,
						                                    p_energy_qty,
						                                    p_user,
                                                p_doc_status);
  ELSE
    lv2_debug_mode := ec_ctrl_system_attribute.attribute_text(p_daytime,'IFAC_DEBUG','<=');
    IF lv2_debug_mode = 'Y' THEN
        --delete from t_temptext where id = 'IFAC_PROFIT_CENTRE_LEVEL';
        ecdp_dynsql.WriteTempText('IFAC_PROFIT_CENTRE_LEVEL', 'p_class_name is ' || p_class_name);
        ecdp_dynsql.WriteTempText('IFAC_PROFIT_CENTRE_LEVEL', 'p_object_id is ' || p_object_id);
        ecdp_dynsql.WriteTempText('IFAC_PROFIT_CENTRE_LEVEL', 'Code for p_object_id is ' || ecdp_objects.GetObjCode(p_object_id));
        ecdp_dynsql.WriteTempText('IFAC_PROFIT_CENTRE_LEVEL', 'p_account_code is ' || p_account_code);
        ecdp_dynsql.WriteTempText('IFAC_PROFIT_CENTRE_LEVEL', 'p_profit_centre_id is ' || p_profit_centre_id);
        ecdp_dynsql.WriteTempText('IFAC_PROFIT_CENTRE_LEVEL', 'Code for p_profit_centre_id is ' || ecdp_objects.GetObjCode(p_profit_centre_id));
        ecdp_dynsql.WriteTempText('IFAC_PROFIT_CENTRE_LEVEL', 'p_time_span is ' || p_time_span);
        ecdp_dynsql.WriteTempText('IFAC_PROFIT_CENTRE_LEVEL', 'p_daytime is ' || p_daytime);
        ecdp_dynsql.WriteTempText('IFAC_PROFIT_CENTRE_LEVEL', 'p_vol_qty is ' || p_vol_qty);
        ecdp_dynsql.WriteTempText('IFAC_PROFIT_CENTRE_LEVEL', 'p_mass_qty is ' || p_mass_qty);
        ecdp_dynsql.WriteTempText('IFAC_PROFIT_CENTRE_LEVEL', 'p_energy_qty is ' || p_energy_qty);
        ecdp_dynsql.WriteTempText('IFAC_PROFIT_CENTRE_LEVEL', 'p_user is ' || p_user);
    END IF;

    lv2_IFAC_PC_UseFullVendor := nvl(EcDp_Contract_Attribute.getAttributeString(p_object_id, 'IFAC_PC_USE_FULL_VENDOR', p_daytime),'Y');

    --Find the number of Vendors for the Contract:
    ln_vendor_cnt := 0;
    FOR v in c_ContractVendorList LOOP
      ln_vendor_cnt := ln_vendor_cnt +1;
    END LOOP;

    IF ln_vendor_cnt = 0 THEN
      --Error: No vendors defined for the contract
      raise NO_VENDORS_IN_CONTRACT;
    END IF;

    --If the vendor count > 1 we can use the 'xx_FULL' vendor:
    IF lv2_IFAC_PC_UseFullVendor = 'Y' and ln_vendor_cnt > 1 THEN
      --Interface directly to the Profit Centre level in the IFAC by using the 'xx_FULL' vendor
      --where 'xx' is the Country Code of the Contract Owner Company

      --Find the 'xx_FULL' vendor:
      --First find the Country code of the Contract Owner Company
      lv2_contract_owner_company_id := ec_contract_version.company_id(p_object_id, p_daytime, '<=');
      lv2_country_id := ec_company_version.country_id(lv2_contract_owner_company_id, p_daytime, '<=');
      lv2_country_code := ecdp_objects.GetObjCode(lv2_country_id);
      lv2_full_vendor_code := lv2_country_code || '_FULL';
      ln_full_vendor_cnt := 0;
      FOR v in c_FullVendorList(lv2_full_vendor_code) LOOP
        lv2_full_vendor_id := v.object_id;
        ln_full_vendor_cnt := ln_full_vendor_cnt + 1;
      END LOOP;
      IF ln_full_vendor_cnt = 0 THEN
        --Full Vendor not found
        --Error:
        raise MISSING_FULL_VENDOR;
      ELSIF ln_full_vendor_cnt > 1 THEN
        --Too many
        --Error
        raise MULTIPLE_FULL_VENDORS;
      END IF;
      --Set the party share to 1 because the split to vendors will be done inside EC Revenue
      ln_party_share := 1;
      insertIFAC_PC_CPY_Qty(p_class_name,
                      p_object_id,
                      p_account_code,
                      p_profit_centre_id,
                      lv2_full_vendor_id,  --This object is a VENDOR: the xx_FULL vendor
                      ln_party_share,
                      p_time_span,
                      p_daytime,
                      p_vol_qty,
                      p_mass_qty,
                      p_energy_qty,
                      p_user,
                      p_doc_status);
    ELSE
      --Number of vendors for the contract is 1 OR contract attribute IFAC_PC_USE_FULL_VENDOR = N:
      --We interface to the Company level in the IFAC for each Vendor being part of the contract

      --Get the vendors and call the insertIFAC_PC_Cpy_Qty procedure for each.
      --Note that this loop also works fine in case there is only one vendor!
      FOR v in c_ContractVendorList LOOP
        lv2_company_id := v.company_id;
        ln_party_share := v.party_share;
        IF ln_party_share is null THEN
          --error
          lv2_company_code := ec_company.object_code(lv2_company_id);
          lv2_contract_code := ec_contract.object_code(p_object_id);
          raise MISSING_PARTY_SHARE;
        END IF;
        insertIFAC_PC_CPY_Qty(p_class_name,
                        p_object_id,
                        p_account_code,
                        p_profit_centre_id,
                        lv2_company_id,  --This object is a VENDOR
                        ln_party_share,
                        p_time_span,
                        p_daytime,
                        p_vol_qty,
                        p_mass_qty,
                        p_energy_qty,
                        p_user,
                        p_doc_status);
      END LOOP;
    END IF;
  END IF;
  EXCEPTION

       WHEN MISSING_PARTY_SHARE THEN
         Raise_Application_Error(-20000,'Party Share is missing for Vendor '|| lv2_company_code ||' for contract '||lv2_contract_code||' Please check your configuration in screen Company Splits');
       WHEN MISSING_FULL_VENDOR THEN
         Raise_Application_Error(-20000,'No vendor with code '''||lv2_country_code||'_FULL'' defined for Country '||lv2_country_code ||' (''xx'' is the Country Code)');
       WHEN MULTIPLE_FULL_VENDORS THEN
         Raise_Application_Error(-20000,'There are multiple vendors with code '''||lv2_country_code||'_FULL'' defined for Country '||lv2_country_code ||' (''xx'' is the Country Code)');
       WHEN NO_VENDORS_IN_CONTRACT THEN
         Raise_Application_Error(-20000,'There are no Vendors defined contract '||lv2_contract_code||'. Please check your configuration in screen Company Splits');

END IFAC_PROFIT_CENTRE_LEVEL;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : IFAC_COMPANY_LEVEL
-- Description    : Inserting sales quantities to EC Revenue interface ifac_sales_qty
--                  at Profit Centre / Company Level, e.g. Profit Centre and Company given
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
---------------------------------------------------------------------------------------------------
PROCEDURE IFAC_COMPANY_LEVEL(
            p_class_name  VARCHAR2,
            p_object_id		VARCHAR2,
            p_account_code		VARCHAR2,
            p_profit_centre_id VARCHAR2,
            p_company_id       VARCHAR2, --Note: This is a COMPANY object
						p_time_span			VARCHAR2,
						p_daytime			DATE,
						p_vol_qty			NUMBER,
						p_mass_qty			NUMBER,
						p_energy_qty		NUMBER,
						p_user				VARCHAR2,
            p_doc_status        VARCHAR2 DEFAULT NULL
)

IS
  Cursor c_vendors is
   SELECT * FROM company c
    where c.class_name = 'VENDOR'
    and c.company_id = p_company_id
    --the vendor must be configured as a vendor for the contract:
    and exists (select * from contract_party_share p
               where p.object_id = p_object_id
               and p.company_id = c.object_id);

--Debug mode:
  lv2_debug_mode                 VARCHAR2(32);
  ln_vendor_cnt                  NUMBER;
  lv2_vendor_id                  VARCHAR2(32);
lv2_company_code                 VARCHAR2(32);

--EXCEPTIONS
  NO_VENDOR EXCEPTION;
  MULTIPLE_VENDORS EXCEPTION;


BEGIN
  IF Ue_Replicate_Sale_Qty.isIFAC_COMPANY_LEVELUEE = 'TRUE' THEN
    ue_replicate_sale_qty.ue_IFAC_COMPANY_LEVEL(p_class_name,
                                                p_object_id,
                                                p_account_code,
                                                p_profit_centre_id,
                                                p_company_id,
						                                    p_time_span,
						                                    p_daytime,
						                                    p_vol_qty,
						                                    p_mass_qty,
						                                    p_energy_qty,
						                                    p_user,
                                                p_doc_status
                                                );
  ELSE
      lv2_debug_mode := ec_ctrl_system_attribute.attribute_text(p_daytime,'IFAC_DEBUG','<=');
      IF lv2_debug_mode = 'Y' THEN
          --delete from t_temptext where id = 'IFAC_COMPANY_LEVEL';
          ecdp_dynsql.WriteTempText('IFAC_COMPANY_LEVEL', 'p_class_name is ' || p_class_name);
          ecdp_dynsql.WriteTempText('IFAC_COMPANY_LEVEL', 'p_object_id is ' || p_object_id);
          ecdp_dynsql.WriteTempText('IFAC_COMPANY_LEVEL', 'Code for p_object_id is ' || ecdp_objects.GetObjCode(p_object_id));
          ecdp_dynsql.WriteTempText('IFAC_COMPANY_LEVEL', 'p_account_code is ' || p_account_code);
          ecdp_dynsql.WriteTempText('IFAC_COMPANY_LEVEL', 'p_profit_centre_id is ' || p_profit_centre_id);
          ecdp_dynsql.WriteTempText('IFAC_COMPANY_LEVEL', 'Code for p_profit_centre_id is ' || ecdp_objects.GetObjCode(p_profit_centre_id));
          ecdp_dynsql.WriteTempText('IFAC_COMPANY_LEVEL', 'p_company_id is ' || p_company_id);
          ecdp_dynsql.WriteTempText('IFAC_COMPANY_LEVEL', 'Code for p_company_id is ' || ecdp_objects.GetObjCode(p_company_id));
          ecdp_dynsql.WriteTempText('IFAC_COMPANY_LEVEL', 'p_time_span is ' || p_time_span);
          ecdp_dynsql.WriteTempText('IFAC_COMPANY_LEVEL', 'p_daytime is ' || p_daytime);
          ecdp_dynsql.WriteTempText('IFAC_COMPANY_LEVEL', 'p_vol_qty is ' || p_vol_qty);
          ecdp_dynsql.WriteTempText('IFAC_COMPANY_LEVEL', 'p_mass_qty is ' || p_mass_qty);
          ecdp_dynsql.WriteTempText('IFAC_COMPANY_LEVEL', 'p_energy_qty is ' || p_energy_qty);
          ecdp_dynsql.WriteTempText('IFAC_COMPANY_LEVEL', 'p_user is ' || p_user);
      END IF;
      --Get the CODE of the Company for error handling:
      lv2_company_code := ec_company.object_code(p_company_id);

      -- Find the Vendor object corresponding to the Company object (p_company_id)
      ln_vendor_cnt := 0;
      FOR v in c_vendors LOOP
        ln_vendor_cnt := ln_vendor_cnt + 1;
        lv2_vendor_id := v.object_id;
      END LOOP;
      IF ln_vendor_cnt = 0 THEN
        --The company has no vendor assigned
        --Error
        raise NO_VENDOR;
      END IF;
      IF ln_vendor_cnt > 1 THEN
        --The company has no vendor assigned
        --Error
        raise MULTIPLE_VENDORS;
      END IF;
      --we have ONE vendor matcing the Company
      insertIFAC_PC_Cpy_Qty(p_class_name,
                          p_object_id,
                          p_account_code,
                          p_profit_centre_id,
                          lv2_vendor_id,
                          1,             --Set to 1 because the numbers are already split out by vendor
                          p_time_span,
                          p_daytime,
                          p_vol_qty,
                          p_mass_qty,
                          p_energy_qty,
                          p_user,
                          p_doc_status);
  END IF; --UE handling

  EXCEPTION
       WHEN NO_VENDOR THEN
         Raise_Application_Error(-20000,'Company '||lv2_company_code||' has no Vendor connected. Please check your configuration.');
       WHEN MULTIPLE_VENDORS THEN
         Raise_Application_Error(-20000,'Company '||lv2_company_code||' has multiple Vendors connected that are used with this contract. Please check your configuration.');

END IFAC_COMPANY_LEVEL;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : insertIFAC_PC_CPY_Qty
-- Description    : Inserting sales quantities to EC Revenue interface ifac_sales_qty
--                  per Profit Centre and Vendor
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
---------------------------------------------------------------------------------------------------
PROCEDURE insertIFAC_PC_CPY_Qty(
            p_class_name  VARCHAR2,
            p_object_id		VARCHAR2,
            p_account_code		VARCHAR2,
            p_profit_centre_id VARCHAR2,
            p_vendor_id       VARCHAR2,  --Note: This is a VENDOR object
            p_party_share     NUMBER,
						p_time_span			VARCHAR2,
						p_daytime			DATE,
						p_vol_qty			NUMBER,
						p_mass_qty			NUMBER,
						p_energy_qty		NUMBER,
						p_user				VARCHAR2,
            p_doc_status        VARCHAR2 DEFAULT NULL
)

IS
  CURSOR c_account (cp_object_id VARCHAR2, cp_account_code VARCHAR2)
  IS
    SELECT  ec_contract.object_code(a.object_id) contract_code,
            a.price_concept_code,
            a.price_object_id,
            a.delivery_point_id,
            ec_product.object_code(a.product_id) product_code,
            a.product_id,
            ec_delivery_point.object_code(a.delivery_point_id) delivery_point_code,
            a.x1_uom,
            a.x2_uom,
            a.x3_uom,
            a.qty1_revn_mapping,
            a.qty2_revn_mapping,
            a.qty3_revn_mapping,
            a.qty4_revn_mapping,
            a.quantity_status,
            a.name,
            ec_node.object_code(a.source_node_id) source_node_code,
            a.LINE_ITEM_BASED_TYPE,
            a.line_item_type
    FROM  contract_account a
    WHERE  a.object_id = cp_object_id
      AND  a.account_code = cp_account_code;


  IFACRec IFAC_SALES_QTY%ROWTYPE := NULL;
--Debug mode:
  lv2_debug_mode                 VARCHAR2(32);
  lv2_DocFinalAccrualSetting     VARCHAR2(32);

  lv2_CntrAcc_vol_uom            VARCHAR2(32);
  lv2_CntrAcc_mass_uom           VARCHAR2(32);
  lv2_CntrAcc_energy_uom         VARCHAR2(32);
  lv2_CntrAcc_x1_uom             VARCHAR2(32);
  lv2_CntrAcc_x2_uom             VARCHAR2(32);
  lv2_CntrAcc_x3_uom             VARCHAR2(32);
  lv2_qty_1_uom                  VARCHAR2(32);
  lv2_qty_2_uom                  VARCHAR2(32);
  lv2_qty_3_uom                  VARCHAR2(32);
  lv2_qty_4_uom                  VARCHAR2(32);
  lv2_price_object_uom           VARCHAR2(32);
  lv2_tt_id                      VARCHAR2(32);
  lv2_company_id                 VARCHAR2(32);
  lv2_price_object_id            VARCHAR2(32);
  l_trans_tmpl_info              T_REVN_OBJ_INFO;
  ln_x1_qty                      NUMBER;
  ln_x2_qty                      NUMBER;
  ln_x3_qty                      NUMBER;
  ln_Qty1Rounding                NUMBER;
  ln_Qty2Rounding                NUMBER;
  ln_Qty3Rounding                NUMBER;
  ln_Qty4Rounding                NUMBER;
  ln_PricingValueRounding        NUMBER;
  lv_Interface                   VARCHAR2(25) := '';

--IFAC insert variables:
  lv_ifac_time_span              VARCHAR2(32);
  lv2_ifac_contract_code         VARCHAR2(32);
  lv2_ifac_account_name          VARCHAR2(240);
  lv2_ifac_profit_centre_code    VARCHAR2(32);
  lv2_ifac_price_concept_code    VARCHAR2(32);
  lv2_ifac_price_object_code     VARCHAR2(32);
  lv2_ifac_del_pnt_code          VARCHAR2(32);
  lv2_ifac_product_code          VARCHAR2(32);
  lv2_ifac_source_node_code      VARCHAR2(32);
  lv2_ifac_line_item_based_type  VARCHAR2(32);
  lv2_ifac_line_item_type        VARCHAR2(32);
  lv2_ifac_qty_status            VARCHAR2(32);
  lv2_ifac_account_class_name    VARCHAR2(32);
  lv2_ifac_object_type           VARCHAR2(32);
  lv2_ifac_dist_type             VARCHAR2(32);
  lv2_ifac_contract_account      VARCHAR2(32);
  lv2_ifac_vendor_code           VARCHAR2(32);
  lv2_ifac_doc_status            VARCHAR2(32);
  lv2_TT_uom1_code               VARCHAR2(32);
  lv2_TT_uom2_code               VARCHAR2(32);
  lv2_TT_uom3_code               VARCHAR2(32);
  lv2_TT_uom4_code               VARCHAR2(32);
  lv2_ifac_price_status          VARCHAR2(32);
  ld_ifac_daytime                DATE;
  ld_ifac_processing_period      DATE;
  ld_ifac_period_start_date      DATE;
  ld_ifac_period_end_date        DATE;
  ln_ifac_pricing_value          NUMBER;
  ln_ifac_calc_run_no            NUMBER;
  ln_ifac_qty_1                  NUMBER;
  ln_ifac_qty_2                  NUMBER;
  ln_ifac_qty_3                  NUMBER;
  ln_ifac_qty_4                  NUMBER;
  ln_ifac_unit_price             NUMBER;
  ln_percentage_amount           NUMBER;
  ln_percentage_value            NUMBER;
  ln_ifac_UOM                    VARCHAR2(32);

--EXCEPTIONS
  VOLUME_UOM_MISSING EXCEPTION;
  MASS_UOM_MISSING EXCEPTION;
  ENERGY_UOM_MISSING EXCEPTION;
  PRICE_CONCEPT_CODE_MISSING EXCEPTION;
  DELIVERY_POINT_MISSING EXCEPTION;
  PRODUCT_MISSING EXCEPTION;
  QTY1_CONVERT_FAILURE EXCEPTION;
  UOM1_GROUP_MISMATCH EXCEPTION;
  UOM2_GROUP_MISMATCH EXCEPTION;
  UOM3_GROUP_MISMATCH EXCEPTION;
  UOM4_GROUP_MISMATCH EXCEPTION;
  NO_TT_FOUND EXCEPTION;
  QTY_OR_UOM_MISSING EXCEPTION;
  UNSUPPORTED_DATA_CLASS EXCEPTION;
  PRODUCT_MISMATCH EXCEPTION;
  NO_PRICE_OBJECT_FOUND EXCEPTION;

BEGIN

  IF UE_Replicate_Sale_Qty.isinsertIFAC_PC_CPY_QtyUEE = 'TRUE' then
    --call UE
    UE_Replicate_Sale_Qty.ue_insertIfac_PC_CPY_Qty(p_class_name,
                                                   p_object_id,
						                                       p_account_code,
						                                       p_profit_centre_id,
                                                   p_vendor_id,
                                                   p_party_share,
						                                       p_time_span,
						                                       p_daytime,
						                                       p_vol_qty,
						                                       p_mass_qty,
						                                       p_energy_qty,
						                                       p_user,
                                                   p_doc_status);
  ELSE
    lv2_debug_mode := ec_ctrl_system_attribute.attribute_text(p_daytime,'IFAC_DEBUG','<=');

    IF lv2_debug_mode = 'Y' THEN
      --delete from t_temptext where id = 'insertIFAC_PC_CPY_Qty';
      ecdp_dynsql.WriteTempText('insertIFAC_PC_CPY_Qty', 'p_class_name is ' || p_class_name);
      ecdp_dynsql.WriteTempText('insertIFAC_PC_CPY_Qty', 'p_object_id is ' || p_object_id);
      ecdp_dynsql.WriteTempText('insertIFAC_PC_CPY_Qty', 'Code for p_object_id is ' || ecdp_objects.GetObjCode(p_object_id));
      ecdp_dynsql.WriteTempText('insertIFAC_PC_CPY_Qty', 'p_account_code is ' || p_account_code);
      ecdp_dynsql.WriteTempText('insertIFAC_PC_CPY_Qty', 'p_profit_centre_id is ' || p_profit_centre_id);
      ecdp_dynsql.WriteTempText('insertIFAC_PC_CPY_Qty', 'Code for p_profit_centre_id is ' || ecdp_objects.GetObjCode(p_profit_centre_id));
      ecdp_dynsql.WriteTempText('insertIFAC_PC_CPY_Qty', 'p_vendor_id is ' || p_vendor_id);
      ecdp_dynsql.WriteTempText('insertIFAC_PC_CPY_Qty', 'Code for p_vendor_id is ' || ecdp_objects.GetObjCode(p_vendor_id));
      ecdp_dynsql.WriteTempText('insertIFAC_PC_CPY_Qty', 'p_party_share is ' || p_party_share);
      ecdp_dynsql.WriteTempText('insertIFAC_PC_CPY_Qty', 'p_time_span is ' || p_time_span);
      ecdp_dynsql.WriteTempText('insertIFAC_PC_CPY_Qty', 'p_daytime is ' || p_daytime);
      ecdp_dynsql.WriteTempText('insertIFAC_PC_CPY_Qty', 'p_vol_qty is ' || p_vol_qty);
      ecdp_dynsql.WriteTempText('insertIFAC_PC_CPY_Qty', 'p_mass_qty is ' || p_mass_qty);
      ecdp_dynsql.WriteTempText('insertIFAC_PC_CPY_Qty', 'p_energy_qty is ' || p_energy_qty);
      ecdp_dynsql.WriteTempText('insertIFAC_PC_CPY_Qty', 'p_doc_status is ' || p_doc_status);
      ecdp_dynsql.WriteTempText('insertIFAC_PC_CPY_Qty', 'p_user is ' || p_user);
    END IF;

    -- Get rounding setting
    ln_Qty1Rounding := EcDp_Contract_Attribute.getAttributeNumber(p_object_id, 'QTY1_ROUNDING', p_daytime);
    ln_Qty2Rounding := EcDp_Contract_Attribute.getAttributeNumber(p_object_id, 'QTY2_ROUNDING', p_daytime);
    ln_Qty3Rounding := EcDp_Contract_Attribute.getAttributeNumber(p_object_id, 'QTY3_ROUNDING', p_daytime);
    ln_Qty4Rounding := EcDp_Contract_Attribute.getAttributeNumber(p_object_id, 'QTY4_ROUNDING', p_daytime);
    ln_PricingValueRounding := EcDp_Contract_Attribute.getAttributeNumber(p_object_id, 'AMOUNT_ROUNDING', p_daytime);

    lv2_DocFinalAccrualSetting := nvl(p_doc_status, EcDp_Contract_Attribute.getAttributeString(p_object_id, 'DOC_FINAL_ACCRUAL_SETTING', p_daytime));

    -- Get Uom's from EC Sale Contract Attributes:
    lv2_CntrAcc_vol_uom     := EcDp_Contract_Attribute.getAttributeString(p_object_id, 'DEL_VOL_UOM', p_daytime);
    IF lv2_CntrAcc_vol_uom IS NULL and p_vol_qty is not NULL THEN
      --Error: We have a Volume Qty but no UOM for it
      raise VOLUME_UOM_MISSING;
    END IF;
    lv2_CntrAcc_mass_uom    := EcDp_Contract_Attribute.getAttributeString(p_object_id, 'DEL_MASS_UOM', p_daytime);
    IF lv2_CntrAcc_mass_uom IS NULL and p_mass_qty is not NULL THEN
      --Error: We have a Mass Qty but no UOM for it
      raise MASS_UOM_MISSING;
    END IF;
    lv2_CntrAcc_energy_uom  := EcDp_Contract_Attribute.getAttributeString(p_object_id, 'DEL_ENERGY_UOM', p_daytime);
    IF lv2_CntrAcc_energy_uom IS NULL and p_energy_qty is not NULL THEN
      --Error: We have a Mass Qty but no UOM for it
      raise ENERGY_UOM_MISSING;
    END IF;

    --Get UOMs for the X1 | X2 | X3 from the Contract Account definitions
    lv2_CntrAcc_x1_uom      := ec_contract_account.x1_uom(p_object_id, p_account_code);
    lv2_CntrAcc_x2_uom      := ec_contract_account.x2_uom(p_object_id, p_account_code);
    lv2_CntrAcc_x3_uom      := ec_contract_account.x3_uom(p_object_id, p_account_code);

    -- Set all the variables needed for the IFAC insert:
    FOR curAcc IN c_account(p_object_id, p_account_code) LOOP
      --Get Code of the vendor object
      lv2_ifac_vendor_code := ec_company.object_code(p_vendor_id);

      --IFAC Contract Code
      lv2_ifac_contract_code := ec_contract.object_code(p_object_id);

      --Contract Account Code:
      lv2_ifac_contract_account := p_account_code;

      --IFAC Daytime
      ld_ifac_daytime := p_daytime;

      --IFAC Profit Centre Code
      lv2_ifac_profit_centre_code := ecdp_objects.GetObjCode(p_profit_centre_id);

      --Delivery Point Code
      lv2_ifac_del_pnt_code := curAcc.Delivery_Point_Code;
      IF lv2_ifac_del_pnt_code is null THEN
        --Error: Missing Delivery Point
        raise DELIVERY_POINT_MISSING;
      END IF;

      --Product Code
      lv2_ifac_product_code := curAcc.Product_Code;
      IF lv2_ifac_product_code is null THEN
        --Error: Product Code
        raise PRODUCT_MISSING;
      END IF;

      --Line item based type
      lv2_ifac_line_item_based_type := curAcc.Line_Item_Based_Type;
      lv2_ifac_line_item_type       := curAcc.Line_Item_Type;

      IF lv2_ifac_line_item_based_type is null THEN
        lv2_ifac_line_item_based_type := 'QTY';
      END IF;

      --Source  Code
      lv2_ifac_source_node_code := curAcc.source_node_Code;

      --Verify that the Product at the Contract Account matches the product of the Price Object if this is set:
      IF curAcc.Price_Object_Id is not null THEN
        IF curAcc.Product_id <> ec_product_price.product_id(curAcc.Price_Object_Id) THEN
          --error
          raise PRODUCT_MISMATCH;
        END IF;
      END IF;

      --Quantity Status
      lv2_ifac_qty_status := curAcc.Quantity_Status;
      IF lv2_ifac_qty_status is null THEN
        --Quantity Status not set at the Contract Account.
        --We default to FINAL
        lv2_ifac_qty_status := 'FINAL';
      END IF;

      -- get revenue timespan / Processing Period / Period Start Date / Period End Date / Contract Account Class
      lv2_ifac_account_class_name := p_class_name;-- 'SCTR_ACC_XXX_PC_STATUS';

      ld_ifac_processing_period := EcDp_Fin_Period.GetCurrOpenPeriodByObject(
                  p_object_id,
                  p_daytime,
                  ec_contract_version.financial_code(p_object_id,
                  p_daytime));

      IF p_time_span = 'MTH' THEN
        lv_ifac_time_span := 'M';
        ld_ifac_processing_period := nvl(ld_ifac_processing_period,trunc(p_daytime,'MM'));
        ld_ifac_period_start_date := trunc(p_daytime,'MM');
        ld_ifac_period_end_date := last_day(p_daytime);
      ELSIF p_time_span = 'YR' THEN
        lv_ifac_time_span := 'Y';
        ld_ifac_processing_period := nvl(ld_ifac_processing_period,trunc(p_daytime,'MM'));
        ld_ifac_period_start_date := trunc(p_daytime,'YEAR');
        ld_ifac_period_end_date := last_day(add_months(p_daytime,12 - to_number(to_char(p_daytime,'mm'))));
      END IF;

      --EC Revenue Doc Status: FINAL | ACCRUAL
      --There is no setting for this on the Contract Account.
      --Use Contract Attribute if set:
      IF UE_Replicate_Sale_Qty.isFinalAccrualDocUEE = 'TRUE' THEN
        --UE
        lv2_ifac_doc_status := UE_Replicate_Sale_Qty.ue_FinalAccrualDoc(p_class_name,
                                                                        p_object_id,
                                                                        p_account_code,
                                                                        p_profit_centre_id,
                                                                        p_vendor_id,
                                                                        p_party_share,
                                                                        p_time_span,
                                                                        p_daytime,
                                                                        p_vol_qty,
                                                                        p_mass_qty,
                                                                        p_energy_qty,
                                                                        p_user,
                                                                        p_doc_status);
      ELSE
        IF lv2_DocFinalAccrualSetting is not null THEN
          lv2_ifac_doc_status := lv2_DocFinalAccrualSetting;
        ELSE
          --default to FINAL:
          lv2_ifac_doc_status := 'FINAL';
        END IF;
      END IF; --UE

      --Profit Centre Object Type, ie Field / Well / Pipeline / etc.
      lv2_ifac_object_type := ecdp_objects.GetObjClassName(p_profit_centre_id);

      --Distribution Type:
      --We set this to 'OBJECT' because the insert to IFAC will be with a distinct Profit Centre
      lv2_ifac_dist_type := 'OBJECT';


      --Contract Account Name - will put it into the IFAC.DESCRIPTION
      lv2_ifac_account_name := curAcc.Name;

      --Quantities
      IF p_class_name = 'SCTR_ACC_MTH_STATUS' or p_class_name = 'SCTR_ACC_YR_STATUS' THEN
        --Top level - Contract Account only
        ln_x1_qty := ec_cntr_acc_period_status.x1_qty(p_object_id, p_account_code, p_time_span, p_daytime);
        ln_x2_qty := ec_cntr_acc_period_status.x2_qty(p_object_id, p_account_code, p_time_span, p_daytime);
        ln_x3_qty := ec_cntr_acc_period_status.x3_qty(p_object_id, p_account_code, p_time_span, p_daytime);
        ln_ifac_pricing_value := ec_cntr_acc_period_status.amount(p_object_id, p_account_code, p_time_span, p_daytime) ;
        --Calc Run No
        ln_ifac_calc_run_no := ec_cntr_acc_period_status.calc_run_no(p_object_id, p_account_code, p_time_span, p_daytime);
      ELSIF p_class_name = 'SCTR_ACC_MTH_PC_STATUS' or  p_class_name = 'SCTR_ACC_YR_PC_STATUS'THEN
        --Second level - Contract Account and Profit Centre
        ln_x1_qty := ec_cntracc_period_pc_status.x1_qty(p_object_id, p_profit_centre_id, p_account_code, p_time_span, p_daytime);
        ln_x2_qty := ec_cntracc_period_pc_status.x2_qty(p_object_id, p_profit_centre_id, p_account_code, p_time_span, p_daytime);
        ln_x3_qty := ec_cntracc_period_pc_status.x3_qty(p_object_id, p_profit_centre_id, p_account_code, p_time_span, p_daytime);
        ln_ifac_pricing_value := ec_cntracc_period_pc_status.amount(p_object_id, p_profit_centre_id,  p_account_code, p_time_span, p_daytime) ;
        --Calc Run No
        ln_ifac_calc_run_no := ec_cntracc_period_pc_status.calc_run_no(p_object_id, p_profit_centre_id, p_account_code, p_time_span, p_daytime);
      ELSIF p_class_name = 'SCTR_ACC_MTH_PC_CPY' or p_class_name = 'SCTR_ACC_YR_PC_CPY' THEN
        --Third level - Contract Account and Profit Centre and Company
        --NOTE! The company_id here is the COMPANY object and not the corresponding VENDOE object!
        lv2_company_id := ec_company.company_id(p_vendor_id);
        ln_x1_qty := ec_cntracc_per_pc_cpy_status.x1_qty(p_object_id, p_profit_centre_id, lv2_company_id, p_account_code, p_time_span, p_daytime);
        ln_x2_qty := ec_cntracc_per_pc_cpy_status.x2_qty(p_object_id, p_profit_centre_id, lv2_company_id, p_account_code, p_time_span, p_daytime);
        ln_x3_qty := ec_cntracc_per_pc_cpy_status.x3_qty(p_object_id, p_profit_centre_id, lv2_company_id, p_account_code, p_time_span, p_daytime);
        ln_ifac_pricing_value := ec_cntracc_per_pc_cpy_status.amount(p_object_id, p_profit_centre_id, lv2_company_id,  p_account_code, p_time_span, p_daytime) ;
        --Calc Run No
        ln_ifac_calc_run_no := ec_cntracc_per_pc_cpy_status.calc_run_no(p_object_id, p_profit_centre_id, lv2_company_id, p_account_code, p_time_span, p_daytime);
      ELSE
       --not supported class yet - use user exit!
       RAISE UNSUPPORTED_DATA_CLASS;
      END IF;
      --Mapping logic between EC Sales and EC Revenue:
      --Function QtyUOMMapping returns the UOM for the mapped quantity
      --Function QtyValueMapping returns the Quantity for the mapped quantity
      lv2_qty_1_uom := QtyUOMMapping(curAcc.qty1_revn_mapping,
                                     lv2_CntrAcc_vol_uom,
                                     lv2_CntrAcc_mass_uom,
                                     lv2_CntrAcc_energy_uom,
                                     lv2_CntrAcc_x1_uom,
                                     lv2_CntrAcc_x2_uom,
                                     lv2_CntrAcc_x3_uom);
      ln_ifac_qty_1 := QtyValueMapping(curAcc.qty1_revn_mapping,
                                       p_vol_qty,
                                       p_mass_qty,
                                       p_energy_qty,
                                       ln_x1_qty,
                                       ln_x2_qty,
                                       ln_x3_qty);

      --Pricing Value logic
      IF ln_ifac_pricing_value is not null THEN
        --Get the Unit Price if there is a Qty1 value
        IF ln_ifac_qty_1 is not null AND ln_ifac_qty_1 != 0 then
          ln_ifac_unit_price := ln_ifac_pricing_value / ln_ifac_qty_1;
        END IF;
        --Apply vendor share
        ln_ifac_pricing_value := ln_ifac_pricing_value*p_party_share;
        --Apply rounding if defined:
        IF ln_PricingValueRounding is not null THEN
          ln_ifac_pricing_value := round(ln_ifac_pricing_value,ln_PricingValueRounding);
        END IF;
      END IF;


      IF ln_ifac_qty_1 is not null THEN
        --Apply vendor share:
        ln_ifac_qty_1 := ln_ifac_qty_1*p_party_share;
        --Apply rounding if set:
        IF ln_Qty1Rounding is not null THEN
          ln_ifac_qty_1 := round(ln_ifac_qty_1,ln_Qty1Rounding);
        END IF;
      END IF;

      lv2_qty_2_uom := QtyUOMMapping(curAcc.qty2_revn_mapping,
                                     lv2_CntrAcc_vol_uom,
                                     lv2_CntrAcc_mass_uom,
                                     lv2_CntrAcc_energy_uom,
                                     lv2_CntrAcc_x1_uom,
                                     lv2_CntrAcc_x2_uom,
                                     lv2_CntrAcc_x3_uom);

      ln_ifac_qty_2 := QtyValueMapping(curAcc.qty2_revn_mapping,
                                       p_vol_qty,
                                       p_mass_qty,
                                       p_energy_qty,
                                       ln_x1_qty,
                                       ln_x2_qty,
                                       ln_x3_qty);

      IF ln_ifac_qty_2 is not null THEN
        --Apply vendor share:
        ln_ifac_qty_2 := ln_ifac_qty_2*p_party_share;
        --Apply rounding if set:
        IF ln_Qty2Rounding is not null THEN
          ln_ifac_qty_2 := round(ln_ifac_qty_2,ln_Qty2Rounding);
        END IF;
      END IF;

      lv2_qty_3_uom := QtyUOMMapping(curAcc.qty3_revn_mapping,
                                     lv2_CntrAcc_vol_uom,
                                     lv2_CntrAcc_mass_uom,
                                     lv2_CntrAcc_energy_uom,
                                     lv2_CntrAcc_x1_uom,
                                     lv2_CntrAcc_x2_uom,
                                     lv2_CntrAcc_x3_uom);

      ln_ifac_qty_3 := QtyValueMapping(curAcc.qty3_revn_mapping,
                                       p_vol_qty,
                                       p_mass_qty,
                                       p_energy_qty,
                                       ln_x1_qty,
                                       ln_x2_qty,
                                       ln_x3_qty);

      IF ln_ifac_qty_3 is not null THEN
        --Apply vendor share:
        ln_ifac_qty_3 := ln_ifac_qty_3*p_party_share;
        --Apply rounding if set:
        IF ln_Qty3Rounding is not null THEN
          ln_ifac_qty_3 := round(ln_ifac_qty_3,ln_Qty3Rounding);
        END IF;
      END IF;

      lv2_qty_4_uom := QtyUOMMapping(curAcc.qty4_revn_mapping,
                                     lv2_CntrAcc_vol_uom,
                                     lv2_CntrAcc_mass_uom,
                                     lv2_CntrAcc_energy_uom,
                                     lv2_CntrAcc_x1_uom,
                                     lv2_CntrAcc_x2_uom,
                                     lv2_CntrAcc_x3_uom);
      ln_ifac_qty_4 := QtyValueMapping(curAcc.qty4_revn_mapping,
                                       p_vol_qty,
                                       p_mass_qty,
                                       p_energy_qty,
                                       ln_x1_qty,
                                       ln_x2_qty,
                                       ln_x3_qty);

      IF ln_ifac_qty_4 is not null THEN
        --Apply vendor share:
        ln_ifac_qty_4 := ln_ifac_qty_4*p_party_share;
        --Apply rounding if set:
        IF ln_Qty4Rounding is not null THEN
          ln_ifac_qty_4 := round(ln_ifac_qty_4,ln_Qty4Rounding);
        END IF;
      END IF;

      --Price Status
      --Currently not part of the Contract Account setting
      --UE Support
      IF ue_replicate_sale_qty.isPriceStatusUEE = 'TRUE' THEN
         lv2_ifac_price_status := UE_Replicate_Sale_Qty.ue_PriceStatus(p_class_name,
                                                                        p_object_id,
                                                                        p_account_code,
                                                                        p_profit_centre_id,
                                                                        p_vendor_id,
                                                                        p_party_share,
                                                                        p_time_span,
                                                                        p_daytime,
                                                                        p_vol_qty,
                                                                        p_mass_qty,
                                                                        p_energy_qty,
                                                                        p_user,
                                                                        p_doc_status);

      ELSE
         --By default we set this to NULL:
         lv2_ifac_price_status := NULL;
      END IF;

      IF curAcc.Price_Object_Id is not null THEN
        --Price Concept Code
        --get it from the Price Object at the Contract Account:
        lv2_ifac_price_concept_code := ec_product_price.price_concept_code(curAcc.Price_Object_Id);

        --Price Object UOM - need it for the IfacRec
        --pick the UOM from the Price Object
        lv2_price_object_uom := ec_product_price_version.uom(curAcc.Price_Object_Id, p_daytime, '<=');

        --lv2_price_object_id := curAcc.Price_Object_Id;
        --Price Object Code
        lv2_ifac_price_object_code := ecdp_objects.GetObjCode(curAcc.Price_Object_Id);

      ELSE  --No Price Object at the Contract Account
        --Price Concept Code
        IF curAcc.Price_Concept_Code is not null THEN
          lv2_ifac_price_concept_code := curAcc.Price_Concept_Code;
        ELSE
          --Error: Missing Price Concept Code
          raise PRICE_CONCEPT_CODE_MISSING;
        END IF;

        --Price Object UOM - need it for the IfacRec
        --use the UOM from the mapping
        lv2_price_object_uom := lv2_qty_1_uom;

        --Lets try to get a Price Object
        lv2_price_object_id := GetIfacRecordPriceObject(p_object_id,
                                                       curAcc.Product_Id,
                                                       lv2_ifac_price_concept_code,
                                                       lv2_ifac_qty_status,
                                                       lv2_ifac_price_status,
                                                       p_daytime,
                                                       lv2_qty_1_uom);
        IF lv2_price_object_id is null THEN
          --No Price Object found!
          raise NO_PRICE_OBJECT_FOUND;
        END IF;

        lv2_ifac_price_object_code := ecdp_objects.GetObjCode(lv2_price_object_id);

      END IF;

      --prepare an 'artificial' IFAC record to use in the ecdp_inbound_interface.GetIfacSalesQtyTT call:
      IFACRec.Contract_Id := p_object_id;
      IFACRec.PROCESSING_PERIOD := ld_ifac_processing_period;
      IFACRec.Delivery_Point_Id := curAcc.Delivery_Point_id;
      IFACRec.Product_Id := curAcc.Product_id;
      IFACRec.Profit_Center_id := p_profit_centre_id;
      IFACRec.Qty_Status := lv2_ifac_qty_status;
      IFACRec.Price_Concept_Code := lv2_ifac_price_concept_code;
      IFACRec.Price_Object_Id := lv2_price_object_id;
      IFACRec.Uom1_Code := lv2_price_object_uom;
      IFACRec.Object_Type := lv2_ifac_object_type;
      --IFACRec.Dist_Type := 'OBJECT_LIST';

      --get the TT that will be hit by this contract account
      l_trans_tmpl_info := ecdp_inbound_interface.find_transaction_template(IFACRec, null);
      lv2_tt_id := l_trans_tmpl_info.object_id;

      IF lv2_tt_id is null THEN
        --no TT found - Try without setting the UOM1_Code
        IFACRec.Uom1_Code := '';
        l_trans_tmpl_info :=  ecdp_inbound_interface.find_transaction_template(IFACRec, null);
        lv2_tt_id := l_trans_tmpl_info.object_id;
      END IF;

      IF lv2_tt_id is null THEN
        --no TT found - raise error:
        raise NO_TT_FOUND;
      END IF;
      --These are the UOMs for the TT:
      lv2_TT_uom1_code := ec_transaction_tmpl_version.uom1_code(lv2_tt_id,p_daytime, '<=');
      lv2_TT_uom2_code := ec_transaction_tmpl_version.uom2_code(lv2_tt_id,p_daytime, '<=');
      lv2_TT_uom3_code := ec_transaction_tmpl_version.uom3_code(lv2_tt_id,p_daytime, '<=');
      lv2_TT_uom4_code := ec_transaction_tmpl_version.uom4_code(lv2_tt_id,p_daytime, '<=');
      --lv2_qty_1_uom must be in the same UOM group as lv2_TT_uom1_code
      IF ecdp_unit.GetUOMGroup(lv2_TT_uom1_code) <> ecdp_unit.GetUOMGroup(lv2_qty_1_uom) then
        --error
        raise UOM1_GROUP_MISMATCH;
      END IF;
      --lv2_qty_2_uom must be in the same UOM group as lv2_TT_uom2_code
      IF ecdp_unit.GetUOMGroup(lv2_TT_uom2_code) <> ecdp_unit.GetUOMGroup(lv2_qty_2_uom) AND lv2_TT_uom2_code is not null then
        --error
        raise UOM2_GROUP_MISMATCH;
      END IF;
      --lv2_qty_3_uom must be in the same UOM group as lv2_TT_uom3_code
      IF ecdp_unit.GetUOMGroup(lv2_TT_uom3_code) <> ecdp_unit.GetUOMGroup(lv2_qty_3_uom) AND lv2_TT_uom3_code is not null then
        --error
        raise UOM3_GROUP_MISMATCH;
      END IF;
      --lv2_qty_4_uom must be in the same UOM group as lv2_TT_uom4_code
      IF ecdp_unit.GetUOMGroup(lv2_TT_uom4_code) <> ecdp_unit.GetUOMGroup(lv2_qty_4_uom) AND lv2_TT_uom4_code is not null then
        --error
        raise UOM4_GROUP_MISMATCH;
      END IF;
      --convert qtys:

      IF lv2_TT_uom1_code is not null AND lv2_qty_1_uom is not null AND ln_ifac_qty_1 is not null
        AND NVL(curAcc.Line_Item_Based_Type,'QTY') = 'QTY' THEN

        ln_ifac_qty_1 := ecdp_unit.convertValue(ln_ifac_qty_1,lv2_qty_1_uom,lv2_TT_uom1_code);
        IF ln_ifac_qty_1 is null THEN
           raise QTY1_CONVERT_FAILURE;
        END IF;
      ELSIF NVL(curAcc.Line_Item_Based_Type,'QTY') = 'QTY' THEN
        --ERROR: Quantity 1 is missing or UOMs are missing
        --Quantity 1 is mandatory
        raise QTY_OR_UOM_MISSING;
      END IF;
      IF lv2_TT_uom2_code is not null AND lv2_qty_2_uom is not null AND ln_ifac_qty_2 is not null THEN
        ln_ifac_qty_2 := ecdp_unit.convertValue(ln_ifac_qty_2,lv2_qty_2_uom,lv2_TT_uom2_code);
      ELSE
        ln_ifac_qty_2 := NULL;
        lv2_TT_uom2_code := NULL;
      END IF;
      IF lv2_TT_uom3_code is not null AND lv2_qty_3_uom is not null AND ln_ifac_qty_3 is not null THEN
        ln_ifac_qty_3 := ecdp_unit.convertValue(ln_ifac_qty_3,lv2_qty_3_uom,lv2_TT_uom3_code);
      ELSE
        ln_ifac_qty_3 := NULL;
        lv2_TT_uom3_code := NULL;
      END IF;
      IF lv2_TT_uom4_code is not null AND lv2_qty_4_uom is not null AND ln_ifac_qty_4 is not null THEN
        ln_ifac_qty_4 := ecdp_unit.convertValue(ln_ifac_qty_4,lv2_qty_4_uom,lv2_TT_uom4_code);
      ELSE
        ln_ifac_qty_4 := NULL;
        lv2_TT_uom4_code := NULL;
      END IF;

      if lv2_debug_mode = 'Y' THEN
           ecdp_dynsql.WriteDebugText('REPLICATE_SALES_QTY','Inserting into IFAC - Acct is: '|| p_account_code, 'DEBUG');
           ecdp_dynsql.WriteDebugText('REPLICATE_SALES_QTY','Inserting into IFAC - Vendor is: '|| lv2_ifac_vendor_code, 'DEBUG');
      end if;

      if lv2_ifac_line_item_based_type = 'PERCENTAGE_MANUAL' THEN
          ln_percentage_amount := ln_ifac_pricing_value;
          ln_percentage_value := ln_ifac_qty_1/100;
          ln_ifac_qty_1 := null;
          ln_ifac_pricing_value := null;
        ELSIF   lv2_ifac_line_item_based_type IN('PERCENTAGE_ALL','PERCENTAGE_QTY') THEN

          ln_percentage_value := ln_ifac_qty_1/100;
          ln_ifac_qty_1 := null;
          ln_ifac_pricing_value := null;

       ELSIF   lv2_ifac_line_item_based_type IN('FREE_UNIT','FREE_UNIT_PRICE_OBJECT') THEN
          IF ln_ifac_qty_1 = 0 THEN
            ln_ifac_unit_price := 0;
          ELSE
            ln_ifac_unit_price :=  ln_ifac_pricing_value/ln_ifac_qty_1;
          END IF;

            ln_ifac_UOM:=lv2_qty_1_uom;
      END IF;



--      IF VALUES HAVE NOT CHANGED THEN DONT INTERFACE

          SELECT NVL(B.INTERFACE_CHECK, 'INTERFACE')
					INTO lv_Interface
					FROM
					        (SELECT 'A' OUTPUT FROM DUAL ) A
          LEFT OUTER JOIN
					(
						SELECT
												CASE
														WHEN (TRANS_KEY_SET_IND = 'Y' AND PRECEDING_TRANS_KEY IS NOT NULL )
																 OR
																 (
																  TRANS_KEY_SET_IND = 'N' AND
																	(
																		( NVL(QTY1,0)                   !=  NVL(ln_ifac_qty_1,0)) OR
																		( NVL(QTY2,0)                   !=  NVL(ln_ifac_qty_2,0)) OR
																		( NVL(QTY3,0)                   !=  NVL(ln_ifac_qty_3,0)) OR
																		( NVL(QTY4,0)                   !=  NVL(ln_ifac_qty_4,0)) OR
																		( NVL(pricing_value,0)           !=  NVL(ln_ifac_pricing_value,0))OR --'MONETARY_VALUE'
																		( NVL(unit_price,0)              !=  NVL(ln_ifac_unit_price,0))   OR
																		( NVL(percentage_value,0)        !=  NVL(ln_percentage_value,0))  OR
																		( NVL(percentage_base_amount,0)  !=  NVL(ln_percentage_amount,0))
																	)
																 )
														 THEN
																	'INTERFACE'
														 ELSE
																  'NO_INTERFACE'
												END AS INTERFACE_CHECK, 'A' OUTPUT
						FROM IFAC_SALES_QTY
						WHERE
            				ALLOC_no_max_ind = 'Y' AND
										NVL(contract_code         ,'XX' ) = NVL(lv2_IFAC_contract_code          ,'XX' ) AND
										period_start_date                 = ld_IFAC_period_start_date                   AND  -- these dates will not be null
										period_end_date                   = ld_ifac_period_end_date                     AND
                    processing_period                 = ld_ifac_processing_period                   AND
										NVL(profit_center_code    ,'XX' ) = NVL(lv2_ifac_profit_centre_code     ,'XX' ) AND
										NVL(delivery_point_code   ,'XX' ) = NVL(lv2_ifac_del_pnt_code           ,'XX' ) AND
										NVL(price_object_code     ,'XX' ) = NVL(lv2_IFAC_price_object_code      ,'XX' ) AND
										NVL(price_concept_code    ,'XX' ) = NVL(lv2_IFAC_price_concept_code     ,'XX' ) AND
										NVL(product_code          ,'XX' ) = NVL(lv2_IFAC_product_code           ,'XX' ) AND
										NVL(vendor_code           ,'XX' ) = NVL(lv2_IFAC_vendor_code            ,'XX' ) AND
										NVL(uom1_code             ,'XX' ) = NVL(lv2_TT_uom1_code                ,'XX' ) AND
										NVL(uom2_code             ,'XX' ) = NVL(lv2_TT_uom2_code                ,'XX' ) AND
										NVL(uom3_code             ,'XX' ) = NVL(lv2_TT_uom3_code                ,'XX' ) AND
										NVL(uom4_code             ,'XX' ) = NVL(lv2_TT_uom4_code                ,'XX' ) AND
										NVL(qty_status            ,'XX' ) = NVL(lv2_IFAC_qty_status             ,'XX' ) AND
--										NVL(price_status          ,'XX' ) = NVL(lv2_IFAC_price_status           ,'XX' ) AND  -- lv2_IFAC_price_status is always null. Ignore for now
										NVL(doc_status            ,'XX' ) = NVL(lv2_IFAC_doc_status             ,'XX' ) AND
										NVL(object_type           ,'XX' ) = NVL(lv2_IFAC_object_type            ,'XX' ) AND
										NVL(dist_type             ,'XX' ) = NVL(lv2_IFAC_dist_type              ,'XX' ) AND
										NVL(line_item_based_type  ,'XX' ) = NVL(lv2_ifac_line_item_based_type   ,'XX' ) AND
										NVL(Line_Item_Type        ,'XX' ) = NVL(lv2_ifac_line_item_type         ,'XX' ) AND
										NVL(li_unique_key_1        ,'XX' ) = NVL( decode(ec_contract_account.li_unique_key(p_object_id,lv2_ifac_contract_account),'LI_UNIQUE_KEY_1',lv2_ifac_contract_account)        ,'XX' ) AND
										NVL(li_unique_key_2        ,'XX' ) = NVL(decode(ec_contract_account.li_unique_key(p_object_id,lv2_ifac_contract_account),'LI_UNIQUE_KEY_2',lv2_ifac_contract_account)         ,'XX' ) AND
										ifac_tt_conn_code IS NULL                                                       AND
										ifac_li_conn_code IS NULL
					) B
				 ON A.OUTPUT = B.OUTPUT;


				IF lv_Interface = 'INTERFACE' OR NVL(EC_CONTRACT_ATTRIBUTE.attribute_string(p_object_id,'IFAC_SALES_NEW_VAL_ONLY',p_daytime,'<='),'N') = 'N' THEN
				  IF lv2_debug_mode = 'Y' THEN

 					    ecdp_dynsql.WriteTempText('REVN_DEBUG','Data change detected. Interfacing record' );
				  END IF;

						INSERT INTO v_ifac_sales_qty
							(contract_code,
							 description,
							 processing_period,
							 period_start_date,
							 period_end_date,
							 profit_center_code,
							 delivery_point_code,
							 price_object_code,
							 price_concept_code,
							 product_code,
							 vendor_code,
							 qty1,
							 uom1_code,
							 qty2,
							 uom2_code,
							 qty3,
							 uom3_code,
							 qty4,
							 uom4_code,
							 pricing_value,  --'MONETARY_VALUE'
							 unit_price,
							 qty_status,
							 price_status,
							 doc_status,
							 object_type,
							 dist_type,
							 status,
							 contract_account_class,
							 calc_run_no,
							 contract_account,
							 line_item_based_type,
							 line_item_type,
							 percentage_value,
							 percentage_base_amount,
							 unit_price_unit,
							 created_by,
							 li_unique_key_1,
							 li_unique_key_2)
						VALUES
							(lv2_ifac_contract_code,
							 lv2_ifac_account_name,
							 ld_ifac_processing_period,
							 ld_ifac_period_start_date,
							 ld_ifac_period_end_date,
							 lv2_ifac_profit_centre_code,
							 lv2_ifac_del_pnt_code,
							 lv2_ifac_price_object_code,
							 lv2_ifac_price_concept_code,
							 lv2_ifac_product_code,
							 lv2_ifac_vendor_code,
							 ln_ifac_qty_1,
							 lv2_TT_uom1_code,
							 ln_ifac_qty_2,
							 lv2_TT_uom2_code,
							 ln_ifac_qty_3,
							 lv2_TT_uom3_code,
							 ln_ifac_qty_4,
							 lv2_TT_uom4_code,
							 ln_ifac_pricing_value,
							 ln_ifac_unit_price,
							 lv2_ifac_qty_status,
							 lv2_ifac_price_status,
							 lv2_ifac_doc_status,
							 lv2_ifac_object_type,
							 lv2_ifac_dist_type,
							 'NEW',
							 lv2_ifac_account_class_name,
							 ln_ifac_calc_run_no,
							 lv2_ifac_contract_account,
							 lv2_ifac_line_item_based_type,
							 lv2_ifac_line_item_type,
							 ln_percentage_value,
							 ln_percentage_amount,
							 ln_ifac_UOM,
							 p_user,
							 decode(ec_contract_account.li_unique_key(p_object_id,lv2_ifac_contract_account),'LI_UNIQUE_KEY_1',lv2_ifac_contract_account),
							 decode(ec_contract_account.li_unique_key(p_object_id,lv2_ifac_contract_account),'LI_UNIQUE_KEY_2',lv2_ifac_contract_account));
--       end loop;
       ELSE
				 IF lv2_debug_mode = 'Y' THEN
           ecdp_dynsql.WriteTempText('REVN_DEBUG','No data has been changed.' );
				 END IF;
       END IF;

    END LOOP;
   END IF;
  EXCEPTION

       WHEN VOLUME_UOM_MISSING THEN
         Raise_Application_Error(-20000,'UOM is missing for Volume Quantity. Please ensure that Contract Attribute ''DEL_VOL_UOM'' has a valid UOM set.');
       WHEN MASS_UOM_MISSING THEN
         Raise_Application_Error(-20000,'UOM is missing for Mass Quantity. Please ensure that Contract Attribute ''DEL_MASS_UOM'' has a valid UOM set.');
       WHEN ENERGY_UOM_MISSING THEN
         Raise_Application_Error(-20000,'UOM is missing for Energy Quantity. Please ensure that Contract Attribute ''DEL_ENERGY_UOM'' has a valid UOM set.');
       WHEN PRICE_CONCEPT_CODE_MISSING THEN
         Raise_Application_Error(-20000,'No Price Concept Code defined for Contract Account '|| lv2_ifac_contract_account ||' for contract ' || lv2_ifac_contract_code ||'. Please check the Contract Account configuration in screen ''Contract Acclunt''.');
       WHEN DELIVERY_POINT_MISSING THEN
         Raise_Application_Error(-20000,'No Delivery Point defined for Contract Account '|| lv2_ifac_contract_account ||' for contract ' || lv2_ifac_contract_code ||'. Please check the Contract Account configuration in screen ''Contract Acclunt''.');
       WHEN PRODUCT_MISSING THEN
         Raise_Application_Error(-20000,'No Product defined for Contract Account '|| lv2_ifac_contract_account ||' for contract ' || lv2_ifac_contract_code ||'. Please check the Contract Account configuration in screen ''Contract Acclunt''.');
       WHEN PRODUCT_MISMATCH THEN
         Raise_Application_Error(-20000,'Product defined for Contract Account '|| lv2_ifac_contract_account ||' for contract ' || lv2_ifac_contract_code ||' is different from the Product setting of the Price Object defined for this Contract Account.. Please check the Contract Account configuration in screen ''Contract Acclunt''.');
       WHEN NO_TT_FOUND THEN
         Raise_Application_Error(-20000,'No Transaction Template found for Contract Account '|| lv2_ifac_contract_account ||' for contract ' || lv2_ifac_contract_code ||'. Please check your configuration');
       WHEN UOM1_GROUP_MISMATCH THEN
         Raise_Application_Error(-20000,'The UOM Group setting for the Contract Account UOM is not matching the UOM Group setting for UOM1 of the contract for Contract Account '|| lv2_ifac_contract_account ||' for contract ' || lv2_ifac_contract_code ||'. EC Revenue UOM1 is '||lv2_TT_uom1_code||' and EC Sales UOM is '||lv2_qty_1_uom||'. Please check your configuration');
       WHEN UOM2_GROUP_MISMATCH THEN
         Raise_Application_Error(-20000,'The UOM Group setting for the Contract Account UOM is not matching the UOM Group setting for UOM2 of the contract for Contract Account '|| lv2_ifac_contract_account ||' for contract ' || lv2_ifac_contract_code ||'. EC Revenue UOM2 is '||lv2_TT_uom2_code||' and EC Sales UOM is '||lv2_qty_2_uom||'. Please check your configuration');
       WHEN UOM3_GROUP_MISMATCH THEN
         Raise_Application_Error(-20000,'The UOM Group setting for the Contract Account UOM is not matching the UOM Group setting for UOM3 of the contract for Contract Account '|| lv2_ifac_contract_account ||' for contract ' || lv2_ifac_contract_code ||'. EC Revenue UOM2 is '||lv2_TT_uom3_code||' and EC Sales UOM is '||lv2_qty_3_uom||'. Please check your configuration');
       WHEN UOM4_GROUP_MISMATCH THEN
         Raise_Application_Error(-20000,'The UOM Group setting for the Contract Account UOM is not matching the UOM Group setting for UOM4 of the contract for Contract Account '|| lv2_ifac_contract_account ||' for contract ' || lv2_ifac_contract_code ||'. EC Revenue UOM2 is '||lv2_TT_uom4_code||' and EC Sales UOM is '||lv2_qty_4_uom||'. Please check your configuration');
       WHEN QTY1_CONVERT_FAILURE THEN
         Raise_Application_Error(-20000,'Not able to convert Quantity 1 for Contract Account '
                                        || lv2_ifac_contract_account ||
                                        ' for contract '
                                        || lv2_ifac_contract_code ||
                                        '. Quantity: '
                                        || ln_ifac_qty_1 ||
                                        '. Converting from UOM: '
                                        || nvl(lv2_qty_1_uom,'MISSING!') ||
                                        '. Converting to UOM: '
                                        || nvl(lv2_TT_uom1_code,'MISSING!'));

       WHEN QTY_OR_UOM_MISSING THEN
         Raise_Application_Error(-20000,'Missing key data for Quantity 1 for Contract Account '
                                        || lv2_ifac_contract_account ||
                                        ' for contract '
                                        || lv2_ifac_contract_code ||
                                        '. Quantity: '
                                        || ln_ifac_qty_1 ||
                                        '. Converting from UOM: '
                                        || nvl(lv2_qty_1_uom,'MISSING!') ||
                                        '. Converting to UOM: '
                                        || nvl(lv2_TT_uom1_code,'MISSING!'));

       WHEN UNSUPPORTED_DATA_CLASS THEN
          Raise_Application_Error(-20000,'This interface logic is not supporting data from class '|| lv2_ifac_account_class_name ||'. Please user User Exit functionality.');
       WHEN NO_PRICE_OBJECT_FOUND THEN
          Raise_Application_Error(-20000,'No Price Object found for Contract '
                                          || lv2_ifac_contract_code ||
                                          ' for Contract Account '
                                          || lv2_ifac_contract_code ||
                                          ' for Price Concept '
                                          || lv2_ifac_price_concept_code ||
                                          '. Please check your configuration');

END insertIFAC_PC_CPY_Qty;

FUNCTION QtyUOMMapping(p_mapping_value VARCHAR2,
                       p_vol_uom VARCHAR2,
                       p_mass_uom VARCHAR2,
                       p_energy_uom VARCHAR2,
                       p_x1_uom VARCHAR2,
                       p_x2_uom VARCHAR2,
                       p_x3_uom VARCHAR2) RETURN VARCHAR2
IS

lv2_retval VARCHAR2(200);
--Exceptions
VOL_UOM_MISSING EXCEPTION;
MASS_UOM_MISSING EXCEPTION;
ENERGY_UOM_MISSING EXCEPTION;
X1_UOM_MISSING EXCEPTION;
X2_UOM_MISSING EXCEPTION;
X3_UOM_MISSING EXCEPTION;
UNKNOWN_MAPPING EXCEPTION;

BEGIN
  IF UE_Replicate_Sale_Qty.isQtyUOMMappingUEE = 'TRUE' then
    --call UE
    lv2_retval := UE_Replicate_Sale_Qty.ue_QtyUOMMapping(p_mapping_value,
                                                         p_vol_uom,
                                                         p_mass_uom,
                                                         p_energy_uom,
                                                         p_x1_uom,
                                                         p_x2_uom,
                                                         p_x3_uom);
  ELSE
    CASE p_mapping_value
      WHEN 'VOL_QTY' THEN
        IF p_vol_uom is not null THEN
          lv2_retval := p_vol_uom;
        ELSE
          --Error: Contract Account value VOL_QTY has been mapped to EC Revenue but the UOM for VOL_QTY is missing in the Contract Attribute setting
          raise VOL_UOM_MISSING;
        END IF;
      WHEN 'MASS_QTY' THEN
        IF p_mass_uom is not null THEN
          lv2_retval := p_mass_uom;
        ELSE
          --Error: Contract Account value MASS_QTY has been mapped to EC Revenue but the UOM for MASS_QTY is missing in the Contract Attribute setting
          raise MASS_UOM_MISSING;
        END IF;
      WHEN 'ENERGY_QTY' THEN
        IF p_energy_uom is not null THEN
          lv2_retval := p_energy_uom;
        ELSE
          --Error: Contract Account value ENERGY_QTY has been mapped to EC Revenue but the UOM for ENERGY_QTY is missing in the Contract Attribute setting
          raise ENERGY_UOM_MISSING;
        END IF;
      WHEN 'X1_QTY' THEN
        IF p_x1_uom is not null THEN
          lv2_retval := p_x1_uom;
        ELSE
          --Error: Contract Account value X1 has been mapped to EC Revenue but the UOM for X1 is missing in the Contract Account setting
          raise X1_UOM_MISSING;
        END IF;
      WHEN 'X2_QTY' THEN
        IF p_x2_uom is not null THEN
          lv2_retval := p_x2_uom;
        ELSE
          --Error: Contract Account value X1 has been mapped to EC Revenue but the UOM for X2 is missing in the Contract Account setting
          raise X2_UOM_MISSING;
        END IF;
      WHEN 'X3_QTY' THEN
        IF p_x3_uom is not null THEN
          lv2_retval := p_x3_uom;
        ELSE
          --Error: Contract Account value X1 has been mapped to EC Revenue but the UOM for X3 is missing in the Contract Account setting
          raise X3_UOM_MISSING;
        END IF;
      ELSE
        IF p_mapping_value is not null THEN
           --Error: Unknown mapping
           raise UNKNOWN_MAPPING;
        ELSE
          --There is no Revenue Mapping defined - Return NULL
          lv2_retval := null;
        END IF;
    END CASE;
  END IF;

  RETURN lv2_retval;

EXCEPTION
    WHEN VOL_UOM_MISSING THEN
      Raise_Application_Error(-20000,'The Contract Account has been set up to map the Volume Qty to EC Revenue, but there is no UOM defined for Volume Quantity. Please check the Contract Attribute config in screen Contract Attributes.');
    WHEN MASS_UOM_MISSING THEN
      Raise_Application_Error(-20000,'The Contract Account has been set up to map the Mass Qty to EC Revenue, but there is no UOM defined for Mass Quantity. Please check the Contract Attribute config in screen Contract Attributes.');
    WHEN ENERGY_UOM_MISSING THEN
      Raise_Application_Error(-20000,'The Contract Account has been set up to map the Energy Qty to EC Revenue, but there is no UOM defined for Energy Quantity. Please check the Contract Attribute config in screen Contract Attributes.');
    WHEN X1_UOM_MISSING THEN
      Raise_Application_Error(-20000,'The Contract Account has been set up to map the X1 Qty to EC Revenue, but there is no UOM defined for Quantity X1. Please check the Contract Account config in screen Contract Account.');
    WHEN X2_UOM_MISSING THEN
      Raise_Application_Error(-20000,'The Contract Account has been set up to map the X2 Qty to EC Revenue, but there is no UOM defined for Quantity X2. Please check the Contract Account config in screen Contract Account.');
    WHEN X3_UOM_MISSING THEN
      Raise_Application_Error(-20000,'The Contract Account has been set up to map the X3 Qty to EC Revenue, but there is no UOM defined for Quantity X3. Please check the Contract Account config in screen Contract Account.');
    WHEN UNKNOWN_MAPPING THEN
      Raise_Application_Error(-20000,'Unknown EC Revenue Quantity Mapping: ' || p_mapping_value ||' Please check the Contract Account Revenue Quantity Mappings in screen Contract Account.');
END QtyUOMMapping;

FUNCTION QtyValueMapping(p_mapping_value VARCHAR2,
                         p_vol_qty NUMBER DEFAULT NULL,
                         p_mass_qty NUMBER DEFAULT NULL,
                         p_energy_qty NUMBER DEFAULT NULL,
                         p_x1_qty NUMBER DEFAULT NULL,
                         p_x2_qty NUMBER DEFAULT NULL,
                         p_x3_qty NUMBER DEFAULT NULL ) RETURN NUMBER
IS

ln_retval NUMBER;

--Exceptions
VOL_QTY_MISSING EXCEPTION;
MASS_QTY_MISSING EXCEPTION;
ENERGY_QTY_MISSING EXCEPTION;
X1_QTY_MISSING EXCEPTION;
X2_QTY_MISSING EXCEPTION;
X3_QTY_MISSING EXCEPTION;
UNKNOWN_MAPPING EXCEPTION;

BEGIN
  IF UE_Replicate_Sale_Qty.isQtyValueMappingUEE = 'TRUE' then
    --call UE
    ln_retval := UE_Replicate_Sale_Qty.ue_QtyUOMMapping(p_mapping_value,
                                                         p_vol_qty,
                                                         p_mass_qty,
                                                         p_energy_qty,
                                                         p_x1_qty,
                                                         p_x2_qty,
                                                         p_x3_qty);
  ELSE
    CASE p_mapping_value
      WHEN 'VOL_QTY' THEN
        IF p_vol_qty is not null THEN
           ln_retval := p_vol_qty;
        ELSE
          --Error: Contract Account value VOL_QTY has been mapped to EC Revenue but the VOL_QTY quantity is null
          raise VOL_QTY_MISSING;
        END IF;
      WHEN 'MASS_QTY' THEN
        IF p_mass_qty is not null THEN
           ln_retval := p_mass_qty;
        ELSE
          --Error: Contract Account value MASS_QTY has been mapped to EC Revenue but the MASS_QTY quantity is null
          raise MASS_QTY_MISSING;
        END IF;
      WHEN 'ENERGY_QTY' THEN
        IF p_energy_qty is not null THEN
           ln_retval := p_energy_qty;
        ELSE
          --Error: Contract Account value ENERGY_QTY has been mapped to EC Revenue but the ENERGY_QTY quantity is null
          raise ENERGY_QTY_MISSING;
        END IF;
      WHEN 'X1_QTY' THEN
        IF p_x1_qty is not null THEN
           ln_retval := p_x1_qty;
        ELSE
          --Error: Contract Account value X1 has been mapped to EC Revenue QTY but the X1 quantity is missing
          raise X1_QTY_MISSING;
        END IF;
      WHEN 'X2_QTY' THEN
        IF p_x2_qty is not null THEN
           ln_retval := p_x2_qty;
        ELSE
          --Error: Contract Account value X1 has been mapped to EC Revenue QTY but the X2 quantity is missing
          raise X2_QTY_MISSING;
        END IF;
      WHEN 'X3_QTY' THEN
        IF p_x3_qty is not null THEN
           ln_retval := p_x3_qty;
        ELSE
          --Error: Contract Account value X1 has been mapped to EC Revenue QTY but the X3 quantity is missing
          raise X3_QTY_MISSING;
        END IF;
      ELSE
        IF p_mapping_value is not null THEN
           --Error: Unknown mapping
           raise UNKNOWN_MAPPING;
        ELSE
          --There is no Revenue Mapping defined - Return NULL
          ln_retval := null;
        END IF;
    END CASE;
  END IF;

  RETURN ln_retval;

EXCEPTION
    WHEN VOL_QTY_MISSING THEN
      Raise_Application_Error(-20000,'The Contract Account has been set up to map the Volume Qty to EC Revenue, but Volume quantity is null. Please check the Contract Calculation - or the config in screens Contract Account / Contract Attributes.');
    WHEN MASS_QTY_MISSING THEN
      Raise_Application_Error(-20000,'The Contract Account has been set up to map the Mass Qty to EC Revenue, but Mass quantity is null. Please check the Contract Calculation - or the config in screens Contract Account / Contract Attributes.');
    WHEN ENERGY_QTY_MISSING THEN
      Raise_Application_Error(-20000,'The Contract Account has been set up to map the Energy Qty to EC Revenue, but Energy quantity is null. Please check the Contract Calculation - or the config in screens Contract Account / Contract Attributes.');
    WHEN X1_QTY_MISSING THEN
      Raise_Application_Error(-20000,'The Contract Account has been set up to map the X1 Qty to EC Revenue, but quantity X1 is null. Please check the Contract Calculation - or the config in screen Contract Account.');
    WHEN X2_QTY_MISSING THEN
      Raise_Application_Error(-20000,'The Contract Account has been set up to map the X2 Qty to EC Revenue, but quantity X1 is null. Please check the Contract Calculation - or the config in screen Contract Account.');
    WHEN X3_QTY_MISSING THEN
      Raise_Application_Error(-20000,'The Contract Account has been set up to map the X3 Qty to EC Revenue, but quantity X1 is null. Please check the Contract Calculation - or the config in screen Contract Account.');
    WHEN UNKNOWN_MAPPING THEN
      Raise_Application_Error(-20000,'Unknown EC Revenue Quantity Mapping: ' || p_mapping_value ||' Please check the Contract Account Revenue Quantity Mappings in screen Contract Account.');
END QtyValueMapping;




PROCEDURE ApproveCalc(p_run_no NUMBER) IS
  CURSOR trans_level (cp_run_no number) is
  select *
    from CNTR_ACC_PERIOD_STATUS
   where calc_run_no = cp_run_no;

   CURSOR pc_level (cp_run_no number) is
  select *
    from CNTRACC_PERIOD_PC_STATUS
   where calc_run_no = cp_run_no;

     CURSOR vend_level (cp_run_no number) is
  select *
    from CNTRACC_PER_PC_CPY_STATUS
   where calc_run_no = cp_run_no;
BEGIN

   FOR Trans in trans_level(p_run_no) LOOP

       insertSalesQty(
                'SCTR_ACC_' || Trans.time_Span || '_STATUS'  ,
                Trans.object_id		,
                Trans.account_code		,
                NULL, --p_profit_centre_id	,
                NULL, --p_company_id	,  --NOTE This is a COMPANY Object!
                Trans.time_Span		,
                Trans.daytime			,
                Trans.vol_qty			,
                Trans.mass_qty			,
                Trans.energy_qty		,
                ecdp_context.getAppUser,
                Trans.Interface_Status,
                true);
   END LOOP;

   FOR pc in pc_level(p_run_no) LOOP

       insertSalesQty(
                'SCTR_ACC_' || pc.time_Span || '_PC_STATUS'  ,
                pc.object_id		,
                pc.account_code		,
                pc.profit_centre_id	,
                NULL, --p_company_id	,  --NOTE This is a COMPANY Object!
                pc.time_Span		,
                pc.daytime			,
                pc.vol_qty			,
                pc.mass_qty			,
                pc.energy_qty		,
                ecdp_context.getAppUser,
                pc.Interface_Status,
                true);
   END LOOP;

   FOR pc_comp in vend_level(p_run_no) LOOP

       insertSalesQty(
                'SCTR_ACC_' || pc_comp.time_Span || '_PC_CPY'  ,
                pc_comp.object_id		,
                pc_comp.account_code		,
                pc_comp.profit_centre_id	,
                pc_comp.company_id,
                pc_comp.time_Span		,
                pc_comp.daytime			,
                pc_comp.vol_qty			,
                pc_comp.mass_qty			,
                pc_comp.energy_qty		,
                ecdp_context.getAppUser,
                pc_comp.Interface_Status,
                true);
   END LOOP;

END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : GetIfacRecordPriceObject
-- Description    : Find the best suited Price Object based on input parameters
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
---------------------------------------------------------------------------------------------------
FUNCTION GetIfacRecordPriceObject(p_contract_id        VARCHAR2,
                                  p_product_id         VARCHAR2,
                                  p_price_concept_code VARCHAR2,
                                  p_quantity_status    VARCHAR2,
                                  p_price_status       VARCHAR2,
                                  p_daytime            DATE,
                                  p_uom_code           VARCHAR2 DEFAULT NULL
)RETURN VARCHAR2
IS

  CURSOR c_PP(cp_contract_id VARCHAR2, cp_product_id VARCHAR2, cp_price_concept_code VARCHAR2, cp_price_status VARCHAR2, cp_quantity_status VARCHAR2, cp_daytime DATE, cp_uom_code VARCHAR2) IS
    SELECT pp.object_id
      FROM product_price pp, product_price_version ppv
     WHERE pp.object_id = ppv.object_id
       AND ppv.daytime <= cp_daytime
       AND nvl(ppv.end_date, cp_daytime + 1) > cp_daytime
       AND (pp.contract_id = cp_contract_id
        OR EXISTS (
            SELECT 1
              FROM contract_price_setup cps
             WHERE cps.object_id = cp_contract_id
               AND cps.product_price_id = pp.object_id
               AND cps.price_type = 'GENERAL'
               AND cps.daytime <= cp_daytime
               AND nvl(cps.end_date, cp_daytime + 1) > cp_daytime
                 )) -- Support both contract specific and general price objects
       AND pp.product_id = cp_product_id
       AND pp.price_concept_code = cp_price_concept_code
       --Price objects with NULL for Price Status will be picked up
       AND nvl(ppv.price_status,nvl(cp_price_status,'NA')) = nvl(cp_price_status,'NA')
       --Price objects with NULL for Quantity Status will be picked up
       AND nvl(ppv.quantity_status,nvl(cp_quantity_status,'NA')) = nvl(cp_quantity_status,'NA')
       AND ppv.uom = nvl(cp_uom_code,ppv.uom)
       AND pp.revn_ind = 'Y'
     --order so that price objects with match on Quantity Status and/or Price Status come first
     ORDER BY ppv.quantity_status, ppv.price_status, pp.object_code;

  lv2_ret_id product_price.object_code%TYPE := NULL;

BEGIN

  IF ue_replicate_sale_qty.isGetIfacRecordPriceObjectUEE = 'TRUE' THEN
    RETURN ue_replicate_sale_qty.ue_GetIfacRecordPriceObject(p_contract_id,
                                                             p_product_id,
                                                             p_price_concept_code,
                                                             p_quantity_status,
                                                             p_price_status,
                                                             p_daytime,
                                                             p_uom_code);
  ELSE

    FOR rsPP IN c_pp(p_contract_id, p_product_id, p_price_concept_code, p_price_status, p_quantity_status, p_daytime, p_uom_code) LOOP

      IF lv2_ret_id IS NULL THEN
        lv2_ret_id := rsPP.object_id;
      END IF;

    END LOOP;

    RETURN lv2_ret_id;
  END IF;

END GetIfacRecordPriceObject;

END EcBp_Replicate_Sale_Qty;