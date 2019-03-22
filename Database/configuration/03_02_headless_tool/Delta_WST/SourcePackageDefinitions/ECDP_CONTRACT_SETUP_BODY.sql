CREATE OR REPLACE PACKAGE BODY Ecdp_Contract_Setup IS
/****************************************************************
** Package        :  Ecdp_Contract_Setup, body part
**
** $Revision: 1.205 $
**
** Purpose        :  Provide special functions on Contract. Use EcDp_Objects for basis functions
**
** Documentation  :  www.energy-components.com
**
** Created  : 15.11.2005 Trond-Arne Brattli
**
** Modification history:
**
** Version  Date         Whom   Change description:
** -------  ------       -----  --------------------------------------
**  1.1     15.11.2005   TRA         Initial version
** 1.17     09.02.2006   skjorsti    Handeling new financial-codes TA_INCOME and TA_COST in addition to SALE and PURCHASE in several functions/procedures
**          19.01.2007   DN          Replaced objects_version.daytime%TYPE with DATE.
CVS LOGGING:
$Log: EcDp_Contract_Setup.pck,v $

Revision 1.205  2014/1/23 11:34:11  AP\vadodmau
ID#:ECPD-29641
Signed-off-by:thoresud
When inserting a new Contract Price Value for a Price Object that is the SOURCE for some Factor Price objects in the Contract Price List BF the Factor Price objects should be added automatically and also get calculated.

Revision 1.204  2014/12/17 11:34:11  AP\joshjgau
ID#:ECPD-22778
Signed-off-by:joshjgau
CHanged Function  GencontractCopy.


Revision 1.203  2014/07/16 11:34:11  AP\vadodmau
ID#:ECPD-27784
Signed-off-by:aaaaasho
Indenting Function  GetFinAccSearchCriteria for getting correct Account Mapping Search Criteria.

Revision 1.202  2014/07/16 09:30:06  AP\vadodmau
ID#:ECPD-27784
Signed-off-by:aaaaasho
Changed Function  GetFinAccSearchCriteria for getting correct Account Mapping Search Criteria.

Revision 1.201  2014/07/15 08:58:46  AP\vadodmau
ID#:ECPD-27784
Signed-off-by:aaaaasho
Function  is updated to return  Account Mapping Search Criteria result columns as name/description.

Revision 1.200  2014/07/15 05:53:01  AP\vadodmau
ID#:ECPD-27784
Signed-off-by:aaaaasho
Function  is updated to return  Account Mapping Search Criteria result columns as name/description.

Revision 1.199  2014/07/11 11:04:33  AP\vadodmau
ID#:ECPD-27784
Signed-off-by:aaaaasho
Changed Function  GetFinAccSearchCriteria for getting correct Account Mapping Search Criteria.

Revision 1.198  2014/07/11 06:43:37  AP\vadodmau
ID#:ECPD-27784
Signed-off-by:aaaaasho
Description for Function  GetFinAccSearchCriteria is added.

Revision 1.197  2014/07/11 04:40:28  AP\vadodmau
ID#:ECPD-27784
Signed-off-by:aaaaasho
Function  is added to return  Account Mapping Search Criteria in the Account Mapping Assistance screen.

Revision 1.196  2014/05/23 10:28:58  AP\padekdee
ID#:ECPD-26688
Signed-off-by:bandypiy
Changed to capture User name for new version.

Revision 1.195  2014/05/10 06:31:33  AP\bandypiy
ID#:ECPD-24149
Signed-off-by:padekdee
Added new procedure UpdateDocumentVendorData to add PAYMENT_TERM_BASE_CODE, PAYMENT_TERM_ID, PAYMENT_CALENDAR_COLL_ID,  PAYMENT_SCHEME_ID, BANK_ACCOUNT_ID from previous version

Revision 1.194  2014/05/08 08:37:25  AP\bandypiy
ID#:ECPD-24149
Signed-off-by:padekdee
Updated UpdateDocumentVendor procedure to add PAYMENT_TERM_BASE_CODE, PAYMENT_TERM_ID, PAYMENT_CALENDAR_COLL_ID,  PAYMENT_SCHEME_ID, BANK_ACCOUNT_ID from previous version

Revision 1.193  2014/04/25 13:32:08  lewisbra
ID#:ECPD-23201
Signed-off-by:hannnyii
ACPC5 changes

Revision 1.192  2014/02/26 03:28:38  AP\leeeewei
ID#:ECPD-26250
Signed-off-by:leeeewei
Updated ec_price_index to ec_price_input_item in function updatePriceIndex

Revision 1.191  2014/01/30 09:40:27  hannnyii
ID#:ECPD-26697
Signed-off-by:lewisbra
Added support for a contract to have both period and cargo document setups.

Revision 1.190  2013/08/09 10:47:45  hannnyii
ID#:ECPD-23178
Signed-off-by:heibehaa
Introduced DIST_TYPE, DIST_OBJECT_TYPE (ACPC 3/5)

Revision 1.189  2013/04/10 09:30:35  hannnyii
ID#:ECPD-20206
Signed-off-by:aaaaasho
Done:Added support for updating customer on a document.

Revision 1.188  2013/04/10 08:32:32  AP\aaaaasho
ID#:ECPD-20206
Signed-off-by:hannnyii
Changes for Improved Customer functionality

Revision 1.187  2013/03/22 15:12:20  hannnyii
ID#:ECPD-23430
Signed-off-by:paullanj
Done:Payment due date now support contract without contract owner company as vendor.

Revision 1.186  2013/01/21 11:04:37  hannnyii
ID#:ECPD-22582
Signed-off-by:heibehaa
Done:Renamed EXPORT_COUNTRY_ID to DESTINATION_COUNTRY_ID.

Revision 1.185  2013/01/08 08:29:25  rosnedag
ID#:ECPD-21882
Signed-off-by: hannnyi
Done: Added fallback function to get daytime and document date up to contract start date or contract doc start date

Revision 1.184  2013/01/07 14:21:24  hannnyii
ID#:ECPD-13398
Signed-off-by:hoiengeo
Done:Fixed a bug where the column for transaction date should be transaction_date instead of daytime.

Revision 1.183  2012/12/20 15:37:52  hannnyii
ID#:ECPD-22841
Signed-off-by:rosnedag
Done:Function EcDp_Contract_Setup.UpdateDocumentVendor has been modified so that new CONTRACT_DOC_VENDORS object created automatically by the system now have REC_ID and APPROVAL_STATE = 'O'.

Revision 1.182  2012/11/28 14:39:16  hannnyii
ID#:ECPD-13398
Signed-off-by:rosnedag
Done:EcDp_Contract_Setup.GenFinPostingData now uses system attribute ACNT_LOGIC_DATE_METHOD to decide which date (transaction date/document date) to use to get object versions in Posting Generation.

Revision 1.181  2012/11/16 12:10:07  hannnyii
ID#:ECPD-22119
Signed-off-by:hoiengeo
DONE:Fixed a bug where in Cont Postings Generation it should pick up VAT Code from Line Item instead of Transaction when it is avaiable there.

Revision 1.180  2012/09/17 07:52:29  lewisbra
ID#:ECPD-21906
Signed-off-by:HANNNYII
Made so bank info on cont_document_company does not include bank account info

Revision 1.179  2012/07/19 07:38:25  rosnedag
ID#:ECPD-20658
Signed-off-by: hannnyii
Done: Modifications for document processing performance enhancement.

Revision 1.178  2012/07/02 19:08:25  lewisbra
ID#:ECPD-21071
Signed-off-by:HANNNYII
This allows support for multivendor purchase, Having Title page used
as invoice when all payment to same.

Revision 1.177  2012/06/04 14:44:24  hannnyii
ID#:ECPD-18994
Signed-off-by:rosnedag
Done:Added stream item id back to primary key combination, and package function parameters are updated accordingly.

Revision 1.176  2012/05/10 07:49:39  lewisbra
ID#:ECPD-20717
Signed-off-by:ROSENDAG
Added changes so that MPD will work with full config

Revision 1.175  2012/05/02 12:02:12  rosnedag
ID#:ECPD-20641
Signed-off-by: olberegi
Done: Upload performance changes, refactoring queries to get better execution times.

Revision 1.174  2012/04/10 16:00:16  lewisbra
ID#:ECPD-20433
Signed-off-by:ROSENDAG
fixed testdata for fin_postings_setup

Revision 1.173  2012/04/04 15:05:02  lewisbra
ID#:ECPD-20079
Signed-off-by:ROSNEDAG
Added final changes so interest on ppa will work

Revision 1.172  2012/04/04 14:14:12  lewisbra
ID#:ECPD-20433
Signed-off-by:ROSENDAG
Support for Receiver Scope in FIN_RECEIVER_SCOPE
Abitilty to turn of bookings for vendor in CONTRACT_VENDOR_PARTY
and have system company as an approved vendor scope

Revision 1.171  2012/04/02 11:53:56  hannnyii
ID#:ECPD-20079
Signed-off-by: lewisbra
Blame: lewisbra
Done: Added UpdateInterest Dates function. Some refactoring.

Revision 1.158.2.12  2012/03/23 10:14:29  rosnedag
ID#:ECPD-20328
Signed-off-by: lewisbra
Blame: lewisbra
Done: Added UpdateInterest Dates function. Some refactoring.

Revision 1.158.2.11  2012/02/09 17:21:44  rosnedag
ID#:ECPD-17562
Signed-off-by: hannnyi
Merging PPA code down from HEAD to 10.2

Revision 1.169  2012/02/02 15:06:36  hannnyii
ID#:ECPD-19879
Signed-off-by:rosnedag
Done:FIxed the bug in EcDp_Contract_setup.GenFinPostingData where a wrong company id was picked up. User exits have also been added to that function.

Revision 1.168  2012/01/31 16:02:25  rosnedag
ID#:ECPD-17028
Signed-off-by:hoiengeo
Limiting insert of document setups when Multi PEriod or Reconciliation

Revision 1.167  2012/01/05 15:09:57  hoiengeo
ID#:ECPD-18991
Signed-off-by: lewisbra
Replaced 'sysdate' with 'Ecdp_Timestamp.getCurrentSysdate()'.

Revision 1.166  2011/12/22 12:44:25  rosnedag
ID#:ECPD-17028
Signed-off-by:hoiengeo
Cleaning up old Reconciliation code.

Revision 1.165  2011/07/05 11:07:21  rosnedag
ID#:ECPD-17028
Signed-off-by:skjorsti
Changes for PPA issue

Revision 1.164  2011/07/04 11:21:29  rosnedag
ID#:ECPD-17028
Signed-off-by:skjorsti
Added procedures for validation of multiple PPA or MULTI PERIOD document setups

Revision 1.163  2011/06/08 07:48:42  SKJORSTI
ID#:ECPD-17818
Signed-off-by:milicmir

Bank account can now be specified at doc setup/vendor level

Revision 1.162  2011/05/13 07:42:13  ghergrey
ID#:ECPD-17268
Signed-off-by:skjorsti
Desc:fixed bug for Copy contract .The code for the contract is used
 when for document

Revision 1.158.2.2  2011/05/04 11:21:30  ghergrey
ID#:ECPD-17501
Signed-off-by:skjorsti
Desc:fixed bug for ecdp_Contract_Setup.AggregateFinPostingData
changed day time from Due-Date to Pay-Date

Revision 1.160  2011/05/04 11:13:27  ghergrey
ID#:ECPD-17449
Signed-off-by:skjorsti
Desc:fixed bug for ecdp_Contract_Setup.AggregateFinPostingData
changed day time from Due-Date to Pay-Date

also adde fixed for ECPD-17268

Revision 1.159  2011/05/03 09:14:46  SKJORSTI
ID#:ECPD-17446
Signed-off-by:rosnedag

Fixed problems wrt to general prices on factor prices

Revision 1.158  2011/03/10 12:20:09  SKJORSTI
ID#:ECPD-17093
Signed-off-by:rosnedag

Removing table contract_bank_acc_setup

Revision 1.157  2011/03/10 10:28:10  SKJORSTI
ID#:ECPD-17093
Signed-off-by:rosnedag

Fixed missing values at price object level and
contract doc vendor level when copying contract

Revision 1.156  2011/02/28 09:31:43  ghergrey
ID#:ECPD-16880
Signed-off-by:rosnedag
Desc:Implemented date handling logic as suggested by APA project

Revision 1.155  2011/02/21 13:36:45  rosnedag
ID#:ECPD-16745
Signed-off-by:skjorsti
Better handling of manual vs doc date term changes of document date

Revision 1.154  2011/02/21 11:33:08  rosnedag
ID#:ECPD-16745
Signed-off-by:skjorsti
Introduced paramter document_date in AggregateFinPostingData to avoid mutating trigger iu_cont_document.

Revision 1.153  2011/02/11 10:17:12  rosnedag
ID#:ECPD-16745
Signed-off-by:ravndsig
Added logic for supporting Document Date valid after contract end date.

******************************************************************/

tab_sum_group_object_id t_sum_group_object_id;
tab_price_basis_object_id t_price_basis_object_id;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  GenContractCopy
-- Description    :
--
-- Preconditions  : Pressing "Copy to New" button in screen Contract General Properties
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
-- Behaviour      : Uses insertNewContractCopy to create a new contract.
--                  Attribute values are read and copied from the current contract, and the latest version of the attributes are used while
--                  creating the new contract.
--
-------------------------------------------------------------------------------------------------
FUNCTION GenContractCopy(
   p_object_id VARCHAR2, -- to copy from
   p_code      VARCHAR2,
   p_user      VARCHAR2,
   p_cntr_type VARCHAR2 DEFAULT NULL,--to indicate the copy will be Deal contract (D) or Contract Template (T)
   p_new_startdate DATE DEFAULT NULL,
   p_new_enddate DATE DEFAULT NULL)

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


CURSOR c_contract_doc (cp_daytime DATE) IS
SELECT cd.object_id id,cdv.daytime,cdv.name
  FROM contract_doc cd, contract_doc_version cdv
 WHERE cd.contract_id = p_object_id
   AND cd.object_id = cdv.object_id
   AND cdv.daytime =
       (select max(cdvm.daytime)
               from contract_doc cdm, contract_doc_version cdvm
              WHERE cdm.contract_id = p_object_id
                AND cdm.object_id = cdvm.object_id
                AND cp_daytime < nvl(cdvm.end_date, cp_daytime + 1)
                AND cp_daytime < Nvl(cdm.end_date, cp_daytime + 1));


CURSOR c_trans(cp_contract_doc_id VARCHAR2, cp_daytime DATE) IS
SELECT tt.object_id id,
       ttv.name
  FROM transaction_template tt, transaction_tmpl_version ttv
 WHERE contract_doc_id = cp_contract_doc_id
   AND tt.object_id = ttv.object_id
   AND cp_daytime <  nvl(ttv.end_date, cp_daytime + 1)
   and ttv.daytime <=cp_daytime;


CURSOR c_liv(pc_trans_templ_id VARCHAR2, cp_daytime DATE) IS
SELECT lit.object_id id,
       litv.name
  FROM line_item_template lit, line_item_tmpl_version litv
 WHERE lit.transaction_template_id = pc_trans_templ_id
   AND lit.object_id = litv.object_id
   and  cp_daytime  < nvl(litv.end_date, cp_daytime + 1)
   and litv.daytime <= cp_daytime;

CURSOR c_product_price (cp_contract_id VARCHAR2, cp_daytime DATE) IS
SELECT pp.object_id,
       pp.product_id,
       pp.start_date,
       pp.end_date,
       pp.price_concept_code,
       pp.revn_ind,
       pp.description,
       ppv.daytime,
       ppv.quantity_status,
       ppv.price_status,
       ppv.pr_calc_id
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


CURSOR c_price_val_setup (cp_object_id VARCHAR2, cc_object_id VARCHAR2) IS
SELECT pvs.object_id,--pp1.object_id, -- new target object_id
       pvs.price_concept_code,
       pvs.price_element_code,
       pvs.daytime,
       pvs.end_date,
       pvs.src_product_price_id,--pp2.object_id as src_product_price_id,
       -- pvs.src_product_price_id,
       pvs.src_price_concept_code,
       pvs.src_price_element_code,
       pvs.factor,
       pvs.constant_factor,
       pvs.price_decimals,
       pvs.round_rule,
       pvs.calculated_ind,
       pvs.comments,
       pvs.value_1,
       pvs.value_2,
       pvs.value_3,
       pvs.value_4,
       pvs.value_5,
       pvs.value_6,
       pvs.value_7,
       pvs.value_8,
       pvs.value_9,
       pvs.value_10,
       pvs.text_1,
       pvs.text_2,
       pvs.text_3,
       pvs.text_4,
       pvs.date_1,
       pvs.date_2,
       pvs.date_3,
       pvs.date_4,
       pvs.date_5
  FROM price_value_setup pvs--, product_price pp1, product_price pp2
  WHERE --pp1.contract_id = cp_object_id and pp2.contract_id = cp_object_id
--  AND ecdp_objects.GetObjName(pvs.object_id, pvs.daytime) =  ecdp_objects.GetObjName(pp1.object_id, pp1.start_date)
--  AND ecdp_objects.GetObjName(pvs.src_product_price_id, pvs.daytime) =  ecdp_objects.GetObjName(pp2.object_id, pp1.start_date)
  --and (
  exists (select 1
           FROM product_price pp
          WHERE pp.object_id = pvs.object_id
            AND pp.contract_id = cp_object_id)
            or
        exists
        (SELECT 1
           FROM contract_price_setup cps
          WHERE cps.object_id = cp_object_id
            AND cps.product_price_id = pvs.object_id);


CURSOR c_cntr_price_setup (cp_contract_id VARCHAR2) IS
SELECT cps.object_id,
       cps.product_price_id,
       cps.price_type,
       cps.daytime,
       cps.end_date,
       cps.comments
  FROM contract_price_setup cps
 WHERE cps.object_id = cp_contract_id;


CURSOR c_text_item(cp_contract_id VARCHAR2, cp_contract_doc_id VARCHAR2, cp_daytime DATE) IS
SELECT cti.object_id id,
       cti.description,
       cti.start_date,
       cti.end_date,
       ctiv.end_date v_end_date,
       cti.transaction_template_id,
       cti.sort_order,
       ctiv.name,
       ctiv.daytime,
       ctiv.column_1,
       ctiv.column_2,
       ctiv.column_3,
       ctiv.text_item_column_type,
       ctiv.text_item_type,
       ctiv.comments
  FROM contract_text_item cti, cntr_text_item_version ctiv
 WHERE cti.contract_doc_id = cp_contract_doc_id
   AND cti.contract_id = cp_contract_id
   AND cti.object_id = ctiv.object_id
   AND ctiv.daytime =
       (
        SELECT MAX(ctiv2.daytime)
          FROM contract_text_item cti2, cntr_text_item_version ctiv2
         WHERE cti2.object_id = cti.object_id
           AND cti2.object_id = ctiv2.object_id
           AND cp_daytime < nvl(ctiv2.end_date, cp_daytime + 1)
           AND cp_daytime < Nvl(cti2.end_date, cp_daytime + 1)
           );


CURSOR c_party_share(cp_contract_id VARCHAR2, cp_daytime DATE) IS
SELECT cps.company_id id, cps.party_role, cps.end_date, cps.party_share, cps.exvat_receiver_id, cps.vat_receiver_id, cps.bank_account_id, cps.class_name
  FROM contract_party_share cps
 WHERE cps.object_id = cp_contract_id
   AND (daytime, party_role) IN (select max(daytime), party_role
       from contract_party_share
       where object_id = cp_contract_id
       and cp_daytime < nvl(end_date, cp_daytime + 1)
       group by party_role);


CURSOR c_contract_doc_company(cp_object_id VARCHAR2, cp_daytime DATE) IS
SELECT cdc.object_id, cdc.company_id, cdc.party_role, cdc.daytime, cdc.end_date, cdc.payment_scheme_id, cdc.payment_term_base_code, cdc.payment_term_id,
       cdc.payment_calendar_coll_id, cdc.value_1, cdc.value_2, cdc.value_3, cdc.value_4, cdc.value_5, cdc.value_6, cdc.value_7, cdc.value_8, cdc.value_9,
       cdc.value_10, cdc.text_1, cdc.text_2, cdc.text_3, cdc.text_4, cdc.date_1, cdc.date_2, cdc.date_3, cdc.date_4, cdc.date_5, cdc.comments, cdc.record_status
  FROM contract_doc_company cdc
  WHERE cdc.object_id = cp_object_id
    AND cp_daytime < nvl(cdc.end_date, cp_daytime + 1)  ;



CURSOR c_copy_product_price_code IS
SELECT NVL(MAX(getObjectCodeNumber(t.object_code)),0) + 1 AS next_copy_num
  FROM product_price t
 WHERE t.object_code like '%_COPY_%' or t.object_code like '%_DEAL_%';

CURSOR c_copy_cntr_doc_code IS
SELECT NVL(MAX(getObjectCodeNumber(t.object_code)),0) + 1 AS next_copy_num
  FROM contract_doc t
 WHERE t.object_code like '%_COPY_%';

CURSOR c_copy_cntr_text_item_code(cp_CodeLike VARCHAR2) IS
SELECT NVL(MAX(getObjectCodeNumber(t.object_code)),0) + 1 AS next_copy_num
  FROM contract_text_item t
 WHERE t.object_code like '%' || cp_CodeLike || '%';

CURSOR c_copy_trans_tmpl_code(cp_CodeLike VARCHAR2) IS
SELECT NVL(MAX(getObjectCodeNumber(t.object_code)),0) + 1 AS next_copy_num
  FROM transaction_template t
 WHERE t.object_code like '%' || cp_CodeLike || '%';

CURSOR c_copy_line_item_tmpl_code(cp_CodeLike VARCHAR2) IS
SELECT NVL(MAX(getObjectCodeNumber(t.object_code)),0) + 1 AS next_copy_num
  FROM line_item_template t
 WHERE t.object_code like '%' || cp_CodeLike || '%';


lv2_object_id contract.object_id%TYPE;
lv2_contract_doc_id contract_doc.object_id%TYPE;
lv2_trans_templ_id transaction_template.object_id%TYPE;
lv2_li_templ_id line_item_template.object_id%TYPE;
lv2_contract_name contract_attribute.attribute_string%TYPE;
lv2_trans_name transaction_tmpl_version.name%TYPE;
lv2_trans_templ_name line_item_tmpl_version.name%TYPE;
lv2_split_key split_key.object_id%TYPE;
lv2_cust_split_key split_key.object_id%TYPE;
lv2_vend_split_key split_key.object_id%TYPE;
lv2_id contract.object_id%TYPE;
lv2_trans_templ_split_key_id objects.object_id%TYPE;
ln_cnt NUMBER := 0;
ln_cnt_contract_doc NUMBER := 0;
ln_cnt_text_items NUMBER := 0;
ln_cnt_product_price NUMBER := 0;
ln_cnt_price_setup NUMBER := 0;
ln_cnt_2 NUMBER := 0;
lv_text_item_id VARCHAR2(32);
lv2_product_price_id VARCHAR2(32);
lrec_prod_price_version product_price_version%ROWTYPE;
ld_contract_start_date DATE := ec_contract.start_date(p_object_id);
ld_contract_end_date DATE := ec_contract.end_date(p_object_id);

no_date_arguments  EXCEPTION;
invalid_start_date EXCEPTION;
invalid_new_dates2 EXCEPTION;

lv2_new_object_id VARCHAR2(32);
lv2_new_source_object_id VARCHAR2(32);

-- ** 4-eyes approval stuff ** --
lv2_4e_recid VARCHAR2(32);
-- ** END 4-eyes approval stuff ** --

lv_lit_val_cnt   NUMBER :=0;

BEGIN


   -- Not allowed to continue if start date and end date is not passed from the business function
   IF p_new_startdate IS NULL OR p_new_enddate IS NULL THEN
      RAISE no_date_arguments;
    END IF;

    --new object dates should not be the same
     IF p_new_startdate >= p_new_enddate THEN
        RAISE invalid_new_dates2;
     END IF;

    -- Resetting these variables to be the new contract' start date and end date
    ld_contract_start_date := p_new_startdate;
    ld_contract_end_date := p_new_enddate;


    lv2_contract_name := ec_contract_version.name(p_object_id,ld_contract_start_date,'<=');

     IF p_cntr_type is NULL THEN
       -- Creating and preparing the contract and contract attributes
       lv2_object_id := InsNewContractCopy(p_object_id,ld_contract_start_date,p_code,p_user,ld_contract_end_date);
     ELSE
       -- Creating deal Contract
       lv2_object_id := InsDealContractCopy(p_object_id,ld_contract_start_date,p_code,p_user,ld_contract_end_date, p_cntr_type);
     END IF;

     -- Inserting contract attributes
    FOR c_val IN c_attributes(p_object_id,ld_contract_start_date) LOOP
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


    -- Inserting Contract Price Object
    ln_cnt_product_price := 0;

    tab_price_object := t_price_object();

    FOR c_val IN c_product_price (p_object_id, ld_contract_start_date) LOOP

       -- Getting highest number in use for COPY's
       FOR rsPC IN c_copy_product_price_code LOOP
         ln_cnt_product_price := rsPC.Next_Copy_Num;
       END LOOP;

       -- Main table
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
         (Ecdp_Object_Copy.GetCopyObjectCode('PRICE_OBJECT',ec_product_price.object_code(c_val.object_id) || '_COPY'),
          c_val.product_id,
          ld_contract_start_date,
          DECODE(c_val.end_date, TO_DATE(NULL), TO_DATE(NULL), ld_contract_end_date),
          lv2_object_id,
          c_val.price_concept_Code,
          c_val.revn_ind,
          c_val.description,
          p_user,
          'PRICE_OBJECT')
       RETURNING object_id INTO lv2_product_price_id;

       lrec_prod_price_version := ec_product_price_version.row_by_pk(c_val.object_id,ld_contract_start_date,'<=');

       tab_price_object.extend;
       tab_price_object(tab_price_object.last).new_object_id := lv2_product_price_id;
       tab_price_object(tab_price_object.last).old_object_id := c_val.object_id;

       -- Inserting any valid versions

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
            (lv2_product_price_id,
             ld_contract_start_date,
             decode(lrec_prod_price_version.end_date,
                    TO_DATE(NULL),
                    TO_DATE(NULL),
                    ld_contract_end_date),
             lrec_prod_price_version.name,
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
               WHERE object_id = lv2_product_price_id
                 AND daytime = ld_contract_start_date;

              -- Register version record for approval
              Ecdp_Approval.registerTaskDetail(lv2_4e_recid,
                                                'PRICE_OBJECT',
                                                Nvl(EcDp_Context.getAppUser,User));
            -- ** END 4-eyes approval ** --

            END IF;
            IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('PRICE_OBJECT'),'N') = 'Y' THEN
               ecdp_acl.RefreshObject(lv2_product_price_id,'PRICE_OBJECT','INSERTING');
            END IF;
    END LOOP;


    -- copy price factor
    FOR c_pvs IN c_price_val_setup (p_object_id,lv2_object_id) LOOP

      lv2_new_object_id := null;
      lv2_new_source_object_id := null;

      FOR ln_cnt IN tab_price_object.first..tab_price_object.last LOOP
          IF tab_price_object(ln_cnt).old_object_id = c_pvs.object_id THEN
             lv2_new_object_id := tab_price_object(ln_cnt).new_object_id;
          END IF;
          IF tab_price_object(ln_cnt).old_object_id = c_pvs.src_product_price_id THEN
             lv2_new_source_object_id := tab_price_object(ln_cnt).new_object_id;
          END IF;
      END LOOP;

      lv2_new_object_id := nvl(lv2_new_object_id,c_pvs.object_id);
      lv2_new_source_object_id := nvl(lv2_new_source_object_id,c_pvs.src_product_price_id);

      insert into price_value_setup
        (OBJECT_ID,
         PRICE_CONCEPT_CODE,
         PRICE_ELEMENT_CODE,
         DAYTIME,
         END_DATE,
         SRC_PRODUCT_PRICE_ID,
         SRC_PRICE_CONCEPT_CODE,
         SRC_PRICE_ELEMENT_CODE,
         FACTOR,
         CONSTANT_FACTOR,
         PRICE_DECIMALS,
         ROUND_RULE,
         CALCULATED_IND,
         COMMENTS,
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
         DATE_1,
         DATE_2,
         DATE_3,
         DATE_4,
         DATE_5)
      values
        (lv2_new_object_id,
         c_pvs.price_concept_code,
         c_pvs.price_element_code,
         c_pvs.daytime,
         c_pvs.end_date,
         lv2_new_source_object_id,
         c_pvs.src_price_concept_code,
         c_pvs.src_price_element_code,
         c_pvs.factor,
         c_pvs.constant_factor,
         c_pvs.price_decimals,
         c_pvs.round_rule,
         c_pvs.calculated_ind,
         c_pvs.comments,
         c_pvs.value_1,
         c_pvs.value_2,
         c_pvs.value_3,
         c_pvs.value_4,
         c_pvs.value_5,
         c_pvs.value_6,
         c_pvs.value_7,
         c_pvs.value_8,
         c_pvs.value_9,
         c_pvs.value_10,
         c_pvs.text_1,
         c_pvs.text_2,
         c_pvs.text_3,
         c_pvs.text_4,
         c_pvs.date_1,
         c_pvs.date_2,
         c_pvs.date_3,
         c_pvs.date_4,
         c_pvs.date_5);

        -- ** 4-eyes approval logic ** --
        IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('CNTR_DERIVED_PRICE_SETUP'),'N') = 'Y' THEN

          -- Generate rec_id for the new record
          lv2_4e_recid := SYS_GUID();

          -- Set approval info on new record.
          UPDATE price_value_setup
          SET last_updated_by = Nvl(EcDp_Context.getAppUser,User),
              last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
              approval_state = 'N',
              rec_id = lv2_4e_recid,
              rev_no = (nvl(rev_no,0) + 1)
          WHERE object_id = c_pvs.object_id
          AND daytime = c_pvs.daytime
          AND price_concept_code = c_pvs.price_concept_code
          AND price_element_code = c_pvs.price_element_code;

          -- Register new record for approval
          Ecdp_Approval.registerTaskDetail(lv2_4e_recid,
                                            'CNTR_DERIVED_PRICE_SETUP',
                                            Nvl(EcDp_Context.getAppUser,User));
        END IF;
        -- ** END 4-eyes approval ** --

    END LOOP;


    IF (p_cntr_type IS NULL or p_cntr_type = 'D') THEN --if not creating deal contract or contract template
       -- Handling general prices connected to contract that is being copied
        ln_cnt_price_setup := 0;

        FOR c_val IN c_cntr_price_setup (p_object_id) LOOP

            ln_cnt_price_setup := ln_cnt_price_setup + 1;

            INSERT INTO contract_price_setup
              (object_id,
               product_price_id,
               price_type,
               daytime,
               end_date,
               comments,
               created_by)
            VALUES
              (lv2_object_id,
               c_val.product_price_id,
               c_val.price_type,
               ld_contract_start_date,
               ld_contract_end_date,
               c_val.comments,
               p_user);


            -- ** 4-eyes approval logic ** --
            IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('CNTR_GENERAL_PRICE_SETUP'),'N') = 'Y' THEN

              -- Generate rec_id for the new record
              lv2_4e_recid := SYS_GUID();

              -- Set approval info on new record.
              UPDATE contract_price_setup
              SET last_updated_by = Nvl(EcDp_Context.getAppUser,User),
                  last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
                  approval_state = 'N',
                  rec_id = lv2_4e_recid,
                  rev_no = (nvl(rev_no,0) + 1)
              WHERE object_id = lv2_object_id
              AND daytime = ld_contract_start_date
              AND product_price_id = c_val.product_price_id
              AND price_type = c_val.price_type;

              -- Register new record for approval
              Ecdp_Approval.registerTaskDetail(lv2_4e_recid,
                                                'CNTR_GENERAL_PRICE_SETUP',
                                                Nvl(EcDp_Context.getAppUser,User));
            END IF;
            -- ** END 4-eyes approval ** --

        END LOOP;
    END IF;


    -- Inserting party shares
    FOR c_val IN c_party_share(p_object_id,ld_contract_start_date) LOOP
        INSERT INTO Contract_Party_Share
          (Object_Id,
           Company_Id,
           Party_Role,
           class_name,
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
           c_val.class_name,
           ld_contract_start_date,
           DECODE(c_val.end_date, TO_DATE(NULL), TO_DATE(NULL), ld_contract_end_date),
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


    -- Updating ACL for if ringfencing is enabled
    IF (NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('CONTRACT'),'N') = 'Y') THEN
       -- Update ACL
       EcDp_Acl.RefreshObject(lv2_object_id, 'CONTRACT', 'INSERTING');
    END IF;

    -- Copy CONTRACT_DOC
    FOR ContractDocCur IN c_contract_doc (ld_contract_start_date) LOOP

         FOR rsCD IN c_copy_cntr_doc_code LOOP
           ln_cnt_contract_doc := rsCD.Next_Copy_Num;
         END LOOP;


         lv2_contract_doc_id := EcDp_Document.genContractDocCopy(ContractDocCur.id, lv2_object_id, Ecdp_Object_Copy.GetCopyObjectCode('CONTRACT_DOC', ec_contract_doc.object_code(ContractDocCur.id) || '_COPY') , lv2_contract_name, p_user, ld_contract_start_date, ld_contract_end_date);


         FOR r_cdc IN c_contract_doc_company(ContractDocCur.id, ld_contract_start_date) LOOP
             INSERT INTO contract_doc_company
               (object_id
                ,company_id
                ,party_role
                ,daytime
                ,end_date
                ,payment_scheme_id
                ,payment_term_base_code
                ,payment_term_id
                ,payment_calendar_coll_id
                ,value_1
                ,value_2
                ,value_3
                ,value_4
                ,value_5
                ,value_6
                ,value_7
                ,value_8
                ,value_9
                ,value_10
                ,text_1
                ,text_2
                ,text_3
                ,text_4
                ,date_1
                ,date_2
                ,date_3
                ,date_4
                ,date_5
                ,comments
                ,record_status
                ,created_by)
              VALUES
                 (lv2_contract_doc_id -- New document object_id
                ,r_cdc.company_id
                ,r_cdc.party_role
                ,ld_contract_start_date -- WYH: daytime should be of new daytime
                ,DECODE(r_cdc.end_date, NULL, NULL, ld_contract_end_date) -- WYH: should be using new end date and not copied end date
                ,r_cdc.payment_scheme_id
                ,r_cdc.payment_term_base_code
                ,r_cdc.payment_term_id
                ,r_cdc.payment_calendar_coll_id
                ,r_cdc.value_1
                ,r_cdc.value_2
                ,r_cdc.value_3
                ,r_cdc.value_4
                ,r_cdc.value_5
                ,r_cdc.value_6
                ,r_cdc.value_7
                ,r_cdc.value_8
                ,r_cdc.value_9
                ,r_cdc.value_10
                ,r_cdc.text_1
                ,r_cdc.text_2
                ,r_cdc.text_3
                ,r_cdc.text_4
                ,r_cdc.date_1
                ,r_cdc.date_2
                ,r_cdc.date_3
                ,r_cdc.date_4
                ,r_cdc.date_5
                ,r_cdc.comments
                ,r_cdc.record_status
                ,p_user);


              -- ** 4-eyes approval logic ** --
              IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('CONTRACT_DOC_VENDORS'),'N') = 'Y' THEN

                -- Generate rec_id for the new record
                lv2_4e_recid := SYS_GUID();

                -- Set approval info on new record.
                UPDATE contract_doc_company
                SET last_updated_by = Nvl(EcDp_Context.getAppUser,User),
                    last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
                    approval_state = 'N',
                    rec_id = lv2_4e_recid,
                    rev_no = (nvl(rev_no,0) + 1)
                WHERE object_id = lv2_contract_doc_id
                  AND company_id = r_cdc.company_id
                  AND party_role = r_cdc.party_role
                  AND daytime = r_cdc.daytime;
                -- Register new record for approval
                Ecdp_Approval.registerTaskDetail(lv2_4e_recid,
                                                  'CONTRACT_DOC_VENDORS',
                                                  Nvl(EcDp_Context.getAppUser,User));
              END IF;

         END LOOP;


         syncContractOwnerPayment(lv2_contract_doc_id,'VENDOR',ld_contract_start_date,'CONTRACT_DOC_VENDORS');

         ln_cnt_text_items := 0;
         FOR c_val IN c_text_item(p_object_id,ContractDocCur.id, ld_contract_start_date) LOOP

             -- Get the next number for this combination of contract_code and contract_doc count
             FOR rsTI IN c_copy_cntr_text_item_code(ec_contract.object_code(lv2_object_id) || '_' || to_char(ln_cnt_contract_doc)) LOOP
               ln_cnt_text_items := rsTI.Next_Copy_Num;
             END LOOP;

             -- Inserting document text items
             INSERT INTO contract_text_item
               (object_code,
                start_date,
                end_date,
                contract_id,
                contract_doc_id,
                description,
                sort_order,
                created_by)
             VALUES
               (ec_contract.object_code(lv2_object_id) || '_' ||
                to_char(ln_cnt_contract_doc) || '_' ||
                to_char(ln_cnt_text_items),
                ld_contract_start_date,
                DECODE(c_val.end_date, TO_DATE(NULL), TO_DATE(NULL), ld_contract_end_date),
                lv2_object_id,
                lv2_contract_doc_id,
                c_val.description,
                c_val.sort_order,
                p_user)
             RETURNING object_id INTO lv_text_item_id;

              -- Inserting into version table
                 INSERT INTO cntr_text_item_version
                    (object_id,
                     daytime,
                     end_date,
                     name,
                     column_1,
                     column_2,
                     column_3,
                     text_item_column_type,
                     text_item_type,
                     comments,
                     created_by)
                  VALUES
                    (lv_text_item_id,
                     ld_contract_start_date,
                     DECODE(c_val.v_end_date,TO_DATE(NULL),TO_DATE(NULL),ld_contract_end_date),
                     c_val.name,
                     c_val.column_1,
                     c_val.column_2,
                     c_val.column_3,
                     c_val.text_item_column_type,
                     c_val.text_item_type,
                     c_val.comments,
                     p_user);

                  -- ** 4-eyes approval logic ** --
                  IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('CONTRACT_TEXT_ITEM'),'N') = 'Y' THEN

                    -- Generate rec_id for the new record
                    lv2_4e_recid := SYS_GUID();

                    -- Set approval info on new record.
                    UPDATE cntr_text_item_version
                    SET last_updated_by = Nvl(EcDp_Context.getAppUser,User),
                        last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
                        approval_state = 'N',
                        rec_id = lv2_4e_recid,
                        rev_no = (nvl(rev_no,0) + 1)
                    WHERE object_id = lv_text_item_id
                    AND daytime = ld_contract_start_date;

                    -- Register new record for approval
                    Ecdp_Approval.registerTaskDetail(lv2_4e_recid,
                                                      'CONTRACT_TEXT_ITEM',
                                                      Nvl(EcDp_Context.getAppUser,User));
                  END IF;
                  -- ** END 4-eyes approval ** --

             --Updaing ACL for if ringfencing is enabled
              IF (NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('CONTRACT_TEXT_ITEM'),'N') = 'Y') THEN
                 -- Update ACL
                 EcDp_Acl.RefreshObject(lv_text_item_id, 'CONTRACT_TEXT_ITEM', 'INSERTING');
              END IF;

              END LOOP;

              -- Copy the contract transaction template stuff
              FOR TransCur IN c_trans(ContractDocCur.id, ld_contract_start_date) LOOP

                 -- Get the next number for this combination of contract_code and contract_doc count
                 FOR rsTT IN c_copy_trans_tmpl_code(ec_contract.object_code(lv2_object_id) || '_' || to_char(ln_cnt_contract_doc)) LOOP
                   ln_cnt := rsTT.Next_Copy_Num;
                 END LOOP;

                lv2_trans_templ_id := EcDp_Transaction.GenTransTemplateCopy(TransCur.id,lv2_contract_doc_id,p_object_id,Ecdp_Object_Copy.GetCopyObjectCode('TRANSACTION_TEMPLATE',ec_contract.object_code(lv2_object_id) || '_COPY'),TransCur.name,p_user, 'Y', ld_contract_start_date, ld_contract_end_date);


                  -- Copy LIV templates
                  FOR LIVCur IN c_liv(TransCur.id, ld_contract_start_date) LOOP
                    --WYH: should follow the insert line item convention

                    lv2_li_templ_id := EcDp_Line_Item.GenLITemplateCopy(LIVCur.id,
                                                                        lv2_trans_templ_id,
                                                                        'LIT:' || to_char(ECDP_system_key.AssignNextUniqueNumber('LINE_ITEM_TEMPLATE', 'OBJECT_CODE', 'LIT:')), -- WYH: should follow the insert line item convention
                                                                        LIVCur.NAME,
                                                                        p_user,
                                                                        ld_contract_start_date,
                                                                        ld_contract_end_date);
                  END LOOP;
              END LOOP;
     END LOOP;

     ecdp_nav_model_obj_relation.Syncronize_model('FINANCIAL');
     ecdp_nav_model_obj_relation.Syncronize_model('PROPERTY');

     tab_price_object := NULL;

     RETURN ec_contract.object_code(lv2_object_id);

EXCEPTION

         WHEN invalid_new_dates2 THEN

              Raise_Application_Error(-20000,'New Start Date:' || p_new_startdate || ' should not be the same as New End Date:' || p_new_enddate || '');

         WHEN no_date_arguments THEN

              Raise_Application_Error(-20000,'Start date and/or end date is missing');

END GenContractCopy;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  GenDocSetup
-- Description    :
--
-- Preconditions  : Pressing "Copy Document Setup" button in screen Document Setup screen.
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
-- Behaviour      : Uses InsNewDocSetupCopy to create a new contract doc.
--                  Attribute values are read and copied from the current contract doc, and the latest version of the attributes are used while
--                  creating the new contract.
--
-------------------------------------------------------------------------------------------------
FUNCTION GenDocSetup(
   p_object_id VARCHAR2, -- to copy from
   p_daytime   DATE, -- start date
   p_contract_id VARCHAR2,
   p_code      VARCHAR2,
   p_name      VARCHAR2,
   p_user      VARCHAR2,
   p_cntr_type VARCHAR2 default NULL) --to indicate the copy will be Deal contract (D) or Contract Template (T)

RETURN VARCHAR2 -- new contract doc object_id
--</EC-DOC>
IS

CURSOR c_contract(cp_object_id VARCHAR2, cp_startdate DATE, cp_enddate DATE) IS
  SELECT count(*) as contracts
    FROM contract c, contract_version cv
   WHERE c.object_id = cp_object_id
     AND c.object_id = cv.object_id
     AND cv.daytime >= cp_startdate AND cv.daytime <= cp_enddate
   ORDER BY cv.daytime;

CURSOR c_contract_doc_ds IS -- to differ from the one in GenContractCopy method
SELECT cd.object_id id,cdv.daytime,cdv.name
  FROM contract_doc cd, contract_doc_version cdv
 WHERE cd.contract_id = p_contract_id
   AND cd.object_id = cdv.object_id
   AND cd.object_id = p_object_id
   AND cdv.daytime >= p_daytime
   AND p_daytime < nvl(cdv.end_date, p_daytime + 1)
   AND cd.start_date >= p_daytime
   AND p_daytime < Nvl(cd.end_date, p_daytime + 1);

CURSOR c_contract_doc_company(cp_object_id VARCHAR2) IS
SELECT cdc.object_id, cdc.company_id, cdc.party_role, cdc.daytime, cdc.end_date, cdc.payment_scheme_id, cdc.payment_term_base_code, cdc.payment_term_id,
       cdc.payment_calendar_coll_id, cdc.value_1, cdc.value_2, cdc.value_3, cdc.value_4, cdc.value_5, cdc.value_6, cdc.value_7, cdc.value_8, cdc.value_9,
       cdc.value_10, cdc.text_1, cdc.text_2, cdc.text_3, cdc.text_4, cdc.date_1, cdc.date_2, cdc.date_3, cdc.date_4, cdc.date_5, cdc.comments, cdc.record_status
  FROM contract_doc_company cdc
  WHERE cdc.object_id = cp_object_id;

CURSOR c_trans(cp_contract_doc_id VARCHAR2) IS
SELECT tt.object_id id, ttv.daytime daytime
  FROM transaction_template tt, transaction_tmpl_version ttv
 WHERE contract_doc_id = cp_contract_doc_id
   AND tt.object_id = ttv.object_id
   AND ttv.daytime >= p_daytime
   AND p_daytime < nvl(ttv.end_date, p_daytime + 1)
   AND tt.start_date >= p_daytime
   AND p_daytime < Nvl(tt.end_date, p_daytime + 1)
   AND ttv.daytime = (SELECT max(ttv2.daytime) FROM transaction_tmpl_version ttv2 WHERE ttv2.object_id = ttv.object_id ) ;

CURSOR c_liv(pc_trans_templ_id VARCHAR2) IS
SELECT lit.object_id id
  FROM line_item_template lit, line_item_tmpl_version litv
 WHERE lit.transaction_template_id = pc_trans_templ_id
   AND lit.object_id = litv.object_id
   AND litv.daytime >= p_daytime
   AND p_daytime < nvl(litv.end_date, p_daytime + 1)
   AND lit.start_date >= p_daytime
   AND p_daytime < Nvl(lit.end_date, p_daytime + 1);

CURSOR c_product_price (cp_contract_id VARCHAR2, cp_daytime DATE) IS
SELECT pp.object_id,
       pp.product_id,
       pp.start_date,
       pp.end_date,
       pp.price_concept_code,
       pp.revn_ind,
       pp.description,
       ppv.daytime
  FROM product_price pp, product_price_version ppv
 WHERE pp.contract_id = cp_contract_id
   AND pp.object_id = ppv.object_id
   AND ppv.daytime = (
                     SELECT MAX(ppver.daytime)
                     FROM product_price prpr, product_price_version ppver
                     WHERE prpr.object_id = pp.object_id
                     AND   prpr.object_id = ppver.object_id

                     AND ppver.daytime >= cp_daytime
                     AND prpr.start_date >= cp_daytime
                     AND cp_daytime < Nvl(prpr.end_date, cp_daytime + 1)
                     );

CURSOR c_product_price_versions (cp_object_id VARCHAR2, cp_daytime DATE) IS
SELECT ppv.daytime,
       ppv.end_date,
       ppv.name,
       ppv.currency_id,
       ppv.uom,
       ppv.calc_seq,
       ppv.calc_rule_id,
       ppv.price_group,
       ppv.comments
  FROM product_price pp, product_price_version ppv
 WHERE pp.object_id = cp_object_id
   AND pp.object_id = ppv.object_id
   AND ppv.daytime >= cp_daytime
   AND pp.start_date >= cp_daytime
   AND cp_daytime < Nvl(pp.end_date, cp_daytime + 1);

CURSOR c_cntr_price_setup (cp_contract_id VARCHAR2) IS
SELECT cps.object_id,
       cps.product_price_id,
       cps.price_type,
       cps.daytime,
       cps.end_date,
       cps.comments
  FROM contract_price_setup cps
 WHERE cps.object_id = cp_contract_id;

CURSOR c_text_item(cp_contract_id VARCHAR2, cp_contract_doc_id VARCHAR2, cp_daytime DATE) IS
SELECT cti.object_id id,
       cti.description,
       cti.start_date,
       cti.end_date,
       cti.transaction_template_id,
       cti.sort_order,
       ctiv.name,
       ctiv.daytime,
       ctiv.column_1,
       ctiv.column_2,
       ctiv.column_3,
       ctiv.text_item_column_type,
       ctiv.text_item_type,
       ctiv.comments
  FROM contract_text_item cti, cntr_text_item_version ctiv
 WHERE cti.contract_doc_id = cp_contract_doc_id
   AND cti.contract_id = cp_contract_id
   AND cti.object_id = ctiv.object_id
   AND ctiv.daytime =
       (
        SELECT MAX(ctiv2.daytime)
          FROM contract_text_item cti2, cntr_text_item_version ctiv2
         WHERE cti2.object_id = cti.object_id
           AND cti2.object_id = ctiv2.object_id
           AND ctiv2.daytime >= cp_daytime
           AND cp_daytime < nvl(ctiv2.end_date, cp_daytime + 1)
           AND cti2.start_date >= cp_daytime
           AND cp_daytime < Nvl(cti2.end_date, cp_daytime + 1)
           );

CURSOR c_text_item_version(cp_object_id VARCHAR2, cp_daytime DATE) IS
SELECT ctiv.name,
       ctiv.daytime,
       ctiv.column_1,
       ctiv.column_2,
       ctiv.column_3,
       ctiv.text_item_column_type,
       ctiv.text_item_type,
       ctiv.comments,
       ctiv.end_date
  FROM contract_text_item cti, cntr_text_item_version ctiv
 WHERE cti.object_id = cp_object_id
   AND cti.object_id = ctiv.object_id
   AND ctiv.daytime >= cp_daytime
   AND cp_daytime < nvl(ctiv.end_date, cp_daytime + 1)
   AND cti.start_date >= cp_daytime
   AND cp_daytime < Nvl(cti.end_date, cp_daytime + 1);

CURSOR c_copy_product_price_code IS
SELECT NVL(MAX(getObjectCodeNumber(t.object_code)),0) + 1 AS next_copy_num
  FROM product_price t
 WHERE t.object_code like '%_COPY_%';

CURSOR c_copy_cntr_doc_code IS
SELECT NVL(MAX(getObjectCodeNumber(t.object_code)),0) + 1 AS next_copy_num
  FROM contract_doc t
 WHERE t.object_code like '%_COPY_%';

CURSOR c_copy_cntr_text_item_code(cp_CodeLike VARCHAR2) IS
SELECT NVL(MAX(getObjectCodeNumber(t.object_code)),0) + 1 AS next_copy_num
  FROM contract_text_item t
 WHERE t.object_code like '%' || cp_CodeLike || '%';

CURSOR c_copy_trans_tmpl_code(cp_CodeLike VARCHAR2) IS
SELECT NVL(MAX(getObjectCodeNumber(t.object_code)),0) + 1 AS next_copy_num
  FROM transaction_template t
 WHERE t.object_code like '%' || cp_CodeLike || '%';

CURSOR c_copy_line_item_tmpl_code(cp_CodeLike VARCHAR2) IS
SELECT NVL(MAX(getObjectCodeNumber(t.object_code)),0) + 1 AS next_copy_num
  FROM line_item_template t
 WHERE t.object_code like '%' || cp_CodeLike || '%';


--lv2_object_id contract.object_id%TYPE;
lv2_object_id contract_doc.object_id%TYPE;
lv2_duplicate_object_id contract_doc.object_id%TYPE;
lv2_contract_doc_id contract_doc.object_id%TYPE;
lv2_trans_templ_id transaction_template.object_id%TYPE;
lv2_li_templ_id line_item_template.object_id%TYPE;
lv2_contract_name contract_attribute.attribute_string%TYPE := ec_contract_version.name(p_contract_id,p_daytime,'<=');
lv2_split_key split_key.object_id%TYPE;
lv2_cust_split_key split_key.object_id%TYPE;
lv2_vend_split_key split_key.object_id%TYPE;
lv2_id contract.object_id%TYPE;
lv2_trans_templ_split_key_id objects.object_id%TYPE;
ln_cnt NUMBER := 0;
ln_prev_cnt NUMBER := 0;
ln_cnt_contract_doc NUMBER := 0;
ln_cnt_text_items NUMBER := 0;
ln_cnt_product_price NUMBER := 0;
ln_cnt_price_setup NUMBER := 0;
ln_cnt_2 NUMBER := 0;
lv_text_item_id VARCHAR2(32);
lrec_prod_price_version product_price_version%ROWTYPE;
lv2_contract_area_setup_id   VARCHAR2(32);
lrec_cntr_area_setup_version cntr_area_setup_version%ROWTYPE;
ln_cnt_contract_areas NUMBER;
ln_contracts NUMBER := 0;

lv2_tran_templ_name TRANSACTION_TMPL_VERSION.name%TYPE;
lv2_tt_code VARCHAR2(32);
lv2_tt_name VARCHAR2(240);
lv2_lit_code VARCHAR2(32);
lv2_lit_name VARCHAR2(240);
ln_position NUMBER := 0;
ln_name_position NUMBER := 0;
ln_cnt2 NUMBER := 0;

ld_contract_start_date DATE := ec_contract.start_date(p_contract_id);
ld_contract_end_date DATE := ec_contract.end_date(p_contract_id);

ld_contract_doc_start_date DATE := ec_contract_doc.start_date(p_object_id);
ld_contract_doc_end_date DATE := ec_contract_doc.end_date(p_object_id);

invalid_start_date EXCEPTION;

-- ** 4-eyes approval stuff ** --
lv2_4e_recid VARCHAR2(32);
-- ** END 4-eyes approval stuff ** --

BEGIN
     IF (p_daytime < ld_contract_doc_start_date) THEN
        RAISE invalid_start_date;
     END IF;

     --check number of contracts is valid
    FOR c_val IN c_contract (p_contract_id, ld_contract_start_date, ld_contract_end_date) LOOP
        --no valid version found, number of contracts will be 0
        ln_contracts := c_val.contracts;
    END LOOP;

    ln_cnt_product_price := 0;
    tab_price_object := t_price_object();

    FOR c_val IN c_product_price (p_contract_id, p_daytime) LOOP
       tab_price_object.extend;
       tab_price_object(tab_price_object.last).new_object_id := c_val.object_id;
       tab_price_object(tab_price_object.last).old_object_id := c_val.object_id;
    END LOOP;

     --lv2_object_id := p_object_id;
     lv2_contract_doc_id := InsNewDocSetupCopy(p_object_id,ld_contract_doc_start_date,p_contract_id, p_code,p_user,ld_contract_doc_end_date);

         FOR r_cdc IN c_contract_doc_company(p_object_id) LOOP
             INSERT INTO contract_doc_company
               (object_id
                ,company_id
                ,party_role
                ,daytime
                ,end_date
                ,payment_scheme_id
                ,payment_term_base_code
                ,payment_term_id
                ,payment_calendar_coll_id
                ,value_1
                ,value_2
                ,value_3
                ,value_4
                ,value_5
                ,value_6
                ,value_7
                ,value_8
                ,value_9
                ,value_10
                ,text_1
                ,text_2
                ,text_3
                ,text_4
                ,date_1
                ,date_2
                ,date_3
                ,date_4
                ,date_5
                ,comments
                ,record_status
                ,created_by)
              VALUES
                 (lv2_contract_doc_id -- New document object_id
                ,r_cdc.company_id
                ,r_cdc.party_role
                ,r_cdc.daytime
                ,r_cdc.end_date
                ,r_cdc.payment_scheme_id
                ,r_cdc.payment_term_base_code
                ,r_cdc.payment_term_id
                ,r_cdc.payment_calendar_coll_id
                ,r_cdc.value_1
                ,r_cdc.value_2
                ,r_cdc.value_3
                ,r_cdc.value_4
                ,r_cdc.value_5
                ,r_cdc.value_6
                ,r_cdc.value_7
                ,r_cdc.value_8
                ,r_cdc.value_9
                ,r_cdc.value_10
                ,r_cdc.text_1
                ,r_cdc.text_2
                ,r_cdc.text_3
                ,r_cdc.text_4
                ,r_cdc.date_1
                ,r_cdc.date_2
                ,r_cdc.date_3
                ,r_cdc.date_4
                ,r_cdc.date_5
                ,r_cdc.comments
                ,r_cdc.record_status
                ,p_user);


              -- ** 4-eyes approval logic ** --
              IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('CONTRACT_DOC_VENDORS'),'N') = 'Y' THEN

                -- Generate rec_id for the new record
                lv2_4e_recid := SYS_GUID();

                -- Set approval info on new record.
                UPDATE contract_doc_company
                SET last_updated_by = Nvl(EcDp_Context.getAppUser,User),
                    last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
                    approval_state = 'N',
                    rec_id = lv2_4e_recid,
                    rev_no = (nvl(rev_no,0) + 1)
                WHERE object_id = lv2_contract_doc_id
                  AND company_id = r_cdc.company_id
                  AND party_role = r_cdc.party_role
                  AND daytime = r_cdc.daytime;
                -- Register new record for approval
                Ecdp_Approval.registerTaskDetail(lv2_4e_recid,
                                                  'CONTRACT_DOC_VENDORS',
                                                  Nvl(EcDp_Context.getAppUser,User));
              END IF;

         END LOOP;

     ln_cnt_contract_doc := 0;
     -- Copy CONTRACT_DOC
     FOR ContractDocCur IN c_contract_doc_ds LOOP
         FOR rsCD IN c_copy_cntr_doc_code LOOP
           ln_cnt_contract_doc := rsCD.Next_Copy_Num;
         END LOOP;

         ln_cnt_text_items := 0;
         FOR c_val IN c_text_item(p_contract_id,ContractDocCur.id, p_daytime) LOOP
               -- Get the next number for this combination of contract_code and contract_doc count
               FOR rsTI IN c_copy_cntr_text_item_code(ec_contract.object_code(p_contract_id) || '_' || to_char(ln_cnt_contract_doc)) LOOP
                 ln_cnt_text_items := rsTI.Next_Copy_Num;
               END LOOP;

               -- Inserting document text items
               INSERT INTO contract_text_item
                 (object_code,
                  start_date,
                  end_date,
                  contract_id,
                  contract_doc_id,
                  transaction_template_id,
                  description,
                  sort_order,
                  created_by)
               VALUES
                 (ec_contract.object_code(p_contract_id) || '_' || to_char(ln_cnt_contract_doc)|| '_' || to_char(ln_cnt_text_items),
                  c_val.start_date,
                  c_val.end_date,
                  p_contract_id,
                  lv2_contract_doc_id,
                  c_val.transaction_template_id,
                  c_val.description,
                  c_val.sort_order,
                  p_user) RETURNING object_id INTO lv_text_item_id;

                -- Inserting any valid versions
                FOR c_val_v IN c_text_item_version(c_val.id,p_daytime) LOOP
                   INSERT INTO cntr_text_item_version
                      (object_id,
                       daytime,
                       end_date,
                       name,
                       column_1,
                       column_2,
                       column_3,
                       text_item_column_type,
                       text_item_type,
                       comments,
                       created_by)
                    VALUES
                      (lv_text_item_id,
                       c_val_v.daytime,
                       c_val_v.end_date,
                       c_val_v.name,
                       c_val_v.column_1,
                       c_val_v.column_2,
                       c_val_v.column_3,
                       c_val_v.text_item_column_type,
                       c_val_v.text_item_type,
                       c_val_v.comments,
                       p_user);


                    -- ** 4-eyes approval logic ** --
                    IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('CONTRACT_TEXT_ITEM'),'N') = 'Y' THEN

                      -- Generate rec_id for the new record
                      lv2_4e_recid := SYS_GUID();

                      -- Set approval info on new record.
                      UPDATE cntr_text_item_version
                      SET last_updated_by = Nvl(EcDp_Context.getAppUser,User),
                          last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
                          approval_state = 'N',
                          rec_id = lv2_4e_recid,
                          rev_no = (nvl(rev_no,0) + 1)
                      WHERE object_id = lv_text_item_id
                      AND daytime = c_val_v.daytime;

                      -- Register new record for approval
                      Ecdp_Approval.registerTaskDetail(lv2_4e_recid,
                                                        'CONTRACT_TEXT_ITEM',
                                                        Nvl(EcDp_Context.getAppUser,User));
                    END IF;
                    -- ** END 4-eyes approval ** --


                END LOOP;

                --Updaing ACL for if ringfencing is enabled
                IF (NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('CONTRACT_TEXT_ITEM'),'N') = 'Y') THEN
                   -- Update ACL
                   EcDp_Acl.RefreshObject(lv_text_item_id, 'CONTRACT_TEXT_ITEM', 'INSERTING');
                END IF;
         END LOOP;

         -- Copy the contract transaction template stuff
         FOR TransCur IN c_trans(ContractDocCur.id) LOOP
             --IF (ContractDocCur.id=lv2_contract_doc_id) THEN
                 lv2_tt_code := ec_transaction_template.object_code(TransCur.id);
                 lv2_tt_name := ec_transaction_tmpl_version.name(TransCur.id,TransCur.daytime,'<=');
                 lv2_tt_code := Ecdp_Object_Copy.GetCopyObjectCode('TRANSACTION_TEMPLATE',lv2_tt_code || '_COPY');

                 lv2_trans_templ_id := EcDp_Transaction.GenTransTemplateCopy(TransCur.id,
                                                                 lv2_contract_doc_id,
                                                                 p_contract_id,
                                                                 lv2_tt_code,
                                                                 lv2_tt_name,
                                                                 p_user,
                                                                 'Y');

                 -- Copy LIV templates
                 FOR LIVCur IN c_liv(TransCur.id) LOOP
                   lv2_lit_code := ec_line_item_template.object_code(LIVCur.id);
                   lv2_lit_name := ec_line_item_tmpl_version.name(LIVCur.id,p_daytime);
		   lv2_lit_code := Ecdp_Object_Copy.GetCopyObjectCode('LINE_ITEM_TEMPLATE',lv2_lit_code || '_COPY');

                   lv2_li_templ_id := EcDp_Line_Item.GenLITemplateCopy(LIVCur.id, lv2_trans_templ_id, lv2_lit_code, lv2_lit_name, p_user);
                 END LOOP;

             -- END IF;
         END LOOP;
     END LOOP;

     tab_price_object := NULL;

     RETURN lv2_object_id;

EXCEPTION

     WHEN invalid_start_date THEN
          Raise_Application_Error(-20000,'Can not make a contract copy before the original contract date.');

END GenDocSetup;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  GenTranTemplate
-- Description    :
--
-- Preconditions  : Pressing "Copy Transaction Template" button in the Contract-Transaction General screen.
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
-- Behaviour      : Attribute values are read and copied from the current transaction template, and the latest version of the attributes are used while
--                  creating the new transaction template.
--
-------------------------------------------------------------------------------------------------
FUNCTION GenTranTemplate(
   p_tran_templ_id VARCHAR2, -- to copy from
   p_daytime   DATE, -- start date
   p_contract_id VARCHAR2,
   p_contract_doc_id VARCHAR2,
   p_user      VARCHAR2,
   p_cntr_type VARCHAR2 default NULL) --to indicate the copy will be Deal contract (D) or Contract Template (T)

RETURN VARCHAR2 -- new transaction template  object_id
--</EC-DOC>
IS

CURSOR c_liv(pc_trans_templ_id VARCHAR2) IS
SELECT lit.object_id id
  FROM line_item_template lit, line_item_tmpl_version litv
 WHERE lit.transaction_template_id = pc_trans_templ_id
   AND lit.object_id = litv.object_id
   AND litv.daytime <= p_daytime
   AND nvl(litv.end_date, p_daytime + 1) > p_daytime;

CURSOR c_product_price (cp_contract_id VARCHAR2, cp_daytime DATE) IS
SELECT pp.object_id,
       pp.product_id,
       pp.start_date,
       pp.end_date,
       pp.price_concept_code,
       pp.revn_ind,
       pp.description,
       ppv.daytime
  FROM product_price pp, product_price_version ppv
 WHERE pp.contract_id = cp_contract_id
   AND pp.object_id = ppv.object_id
   AND ppv.daytime = (
                     SELECT MAX(ppver.daytime)
                     FROM product_price prpr, product_price_version ppver
                     WHERE prpr.object_id = pp.object_id
                     AND   prpr.object_id = ppver.object_id

                     AND ppver.daytime >= cp_daytime
                     AND prpr.start_date >= cp_daytime
                     AND cp_daytime < Nvl(prpr.end_date, cp_daytime + 1)
                     );

CURSOR c_copy_trans_tmpl_code(cp_CodeLike VARCHAR2) IS
SELECT NVL(MAX(getObjectCodeNumber(t.object_code)),0) + 1 AS next_copy_num
  FROM transaction_template t
 WHERE t.object_code like '%' || cp_CodeLike || '%';

CURSOR c_copy_line_item_tmpl_code(cp_CodeLike VARCHAR2) IS
SELECT NVL(MAX(getObjectCodeNumber(t.object_code)),0) + 1 AS next_copy_num
  FROM line_item_template t
 WHERE t.object_code like '%' || cp_CodeLike || '%';

lv2_object_id contract_doc.object_id%TYPE;
lv2_duplicate_object_id contract_doc.object_id%TYPE;
lv2_contract_doc_id contract_doc.object_id%TYPE;
lv2_trans_templ_id transaction_template.object_id%TYPE;
lv2_li_templ_id line_item_template.object_id%TYPE;
lv2_tran_templ_name TRANSACTION_TMPL_VERSION.name%TYPE := ec_transaction_tmpl_version.name(p_tran_templ_id,p_daytime,'<=');
lv2_split_key split_key.object_id%TYPE;
lv2_cust_split_key split_key.object_id%TYPE;
lv2_vend_split_key split_key.object_id%TYPE;
lv2_id contract.object_id%TYPE;
lv2_trans_templ_split_key_id objects.object_id%TYPE;
ln_cnt NUMBER := 0;
ln_prev_cnt NUMBER := 0;
ln_cnt_contract_doc NUMBER := 0;
ln_cnt_text_items NUMBER := 0;
ln_cnt_product_price NUMBER := 0;
ln_position NUMBER := 0;
ln_name_position NUMBER := 0;
ln_cnt2 NUMBER := 0;
lv_postfix VARCHAR2(32);
lv2_product_price_id VARCHAR2(32);
lrec_prod_price_version product_price_version%ROWTYPE;
lv2_contract_area_setup_id   VARCHAR2(32);
lrec_cntr_area_setup_version cntr_area_setup_version%ROWTYPE;
ln_cnt_contract_areas NUMBER;
ln_contracts NUMBER := 0;
lv2_tt_code VARCHAR2(100);
lv2_tt_name VARCHAR2(240);
lv2_lit_code VARCHAR2(100);
lv2_lit_name VARCHAR2(240);
lv2_code VARCHAR2(32);
ld_contract_start_date DATE := ec_contract.start_date(p_contract_id);
ld_contract_end_date DATE := ec_contract.end_date(p_contract_id);

ld_tran_templ_start_date DATE := ec_transaction_template.start_date(p_tran_templ_id);
ld_tran_templ_end_date DATE := ec_transaction_template.end_date(p_tran_templ_id);

invalid_start_date EXCEPTION;

BEGIN
     IF (p_daytime < ld_tran_templ_start_date) THEN
        RAISE invalid_start_date;
     END IF;

     ln_cnt_product_price := 0;
     tab_price_object := t_price_object();

     FOR c_val IN c_product_price (p_contract_id, p_daytime) LOOP
        tab_price_object.extend;
        tab_price_object(tab_price_object.last).new_object_id := lv2_product_price_id;
        tab_price_object(tab_price_object.last).old_object_id := c_val.object_id;
     END LOOP;

     lv2_tt_code := ec_transaction_template.object_code(p_tran_templ_id);
     lv2_tt_code := Ecdp_Object_Copy.GetCopyObjectCode('TRANSACTION_TEMPLATE',lv2_tt_code || '_COPY');
     lv2_tt_name := lv2_tran_templ_name;

     -- Copy the contract transaction template stuff
     lv2_trans_templ_id := EcDp_Transaction.GenTransTemplateCopy(p_tran_templ_id,
                                                                 p_contract_doc_id,
                                                                 p_contract_id,
                                                                 lv2_tt_code,
                                                                 lv2_tt_name,
                                                                 p_user,
                                                                 'N',
                                                                 p_daytime);

     -- Copy LIV templates
     FOR LIVCur IN c_liv(p_tran_templ_id) LOOP
       lv2_lit_code := ec_line_item_template.object_code(LIVCur.id);
       lv2_lit_name := ec_line_item_tmpl_version.name(LIVCur.id,p_daytime);
       lv2_lit_code := Ecdp_Object_Copy.GetCopyObjectCode('LINE_ITEM_TEMPLATE',lv2_lit_code || '_COPY');

       lv2_li_templ_id := EcDp_Line_Item.GenLITemplateCopy(LIVCur.id, lv2_trans_templ_id, lv2_lit_code, lv2_lit_name, p_user,p_daytime);
     END LOOP;

	 tab_price_object := NULL;

     RETURN lv2_trans_templ_id;

EXCEPTION

     WHEN invalid_start_date THEN
          Raise_Application_Error(-20000,'Can not make a contract copy before the original contract date.');

END GenTranTemplate;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  DelContract
-- Description    :
--
-- Preconditions  : Deleting all objects referencing this contract if contract has not been processed
--                  i.e. there's not a record in table cont_document for this contract.
--
-- Postconditions :
--
-- Using tables   : contract_doc, contract_doc_version, contract_text_item, cntr_text_item_version, transaction_template, transaction_tmpl_version,
--                  line_item_template, line_item_tmpl_version, product_price, product_price_version, contract_bank_acc_setup, contract_party_share,
--                  contract_attribute, cont_document
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Throws a document exists exception if contract has already been processed
-------------------------------------------------------------------------------------------------
PROCEDURE DelContract(
   p_object_id VARCHAR2,
   p_user      VARCHAR2
   )
--</EC-DOC>
IS

document_exists EXCEPTION;
contract_exists EXCEPTION;

CURSOR c_contract (cp_object_id VARCHAR2) IS
  SELECT count(*) as contracts
    FROM contract c, contract_version cv
   WHERE c.object_id = cv.object_id
   AND cv.parent_contract_id = cp_object_id;

ln_check_cnt NUMBER;

-- ** 4-eyes approval stuff ** --
lv2_contract_approval_ind VARCHAR2(1);



BEGIN

  -- ** 4-eyes approval check on parent class ** --
  -- If this class has approval, all child classes will also have to be approved
  lv2_contract_approval_ind := NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('CONTRACT'),'N');

    SELECT COUNT(*)
      INTO ln_check_cnt
      FROM cont_document
     WHERE object_id = p_object_id;

    IF ln_check_cnt > 0 THEN
        RAISE document_exists;
    END IF;

    FOR v IN c_contract(p_object_id) LOOP
        IF v.contracts > 0 THEN
            RAISE contract_exists;
        END IF;
    END LOOP;


    -- ** 4-eyes approval logic - Controlling DELETE on CONTRACT_TEXT_ITEM ** --
    IF lv2_contract_approval_ind = 'Y' and ec_contract_version.approval_state(p_object_id, ec_contract.start_date(p_object_id)) IN ('O','U') THEN
      Ecdp_Approval.registerTaskDetail(ec_contract_version.rec_id(p_object_id, ec_contract.start_date(p_object_id)),
                                          'CONTRACT',
                                           Nvl(EcDp_Context.getAppUser,User),
                                           'call EcDp_Contract_Setup.DoDelContract(''' || p_object_id || ''')');
    ELSE
        DoDelContract(p_object_id);
    END IF;


    EXCEPTION

        WHEN document_exists THEN

            RAISE_APPLICATION_ERROR(-20000,'The contract '||Ec_Contract.object_code(p_object_id)||' - '||Ec_Contract_Version.name(p_object_id,Ecdp_Timestamp.getCurrentSysdate,'<=')||' cannot be deleted because it has been processed.');
        WHEN contract_exists THEN

            RAISE_APPLICATION_ERROR(-20000,'The contract '||Ec_Contract.object_code(p_object_id)||' - '||Ec_Contract_Version.name(p_object_id,Ecdp_Timestamp.getCurrentSysdate,'<=')||' cannot be deleted because it has child contract.');

END DelContract;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  DoDelContract
-- Description    :
--
-- Preconditions  : Called by 4E callback routine or by DelContract to do actual deltion..
--
-- Postconditions :
--
-- Using tables   : contract_doc, contract_doc_version, contract_text_item, cntr_text_item_version, product_price, product_price_version,
--                   contract_party_share,
--                  contract_attribute,
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------
PROCEDURE DoDelContract(
   p_object_id VARCHAR2
   )
--</EC-DOC>
IS

CURSOR c_contract_doc (pc_object_id VARCHAR2) IS
SELECT cd.object_id id,
       cdv.approval_state, cdv.rec_id -- in use for approval check
  FROM contract_doc cd, contract_doc_version cdv
 WHERE cd.contract_id = pc_object_id
   AND cd.object_id = cdv.object_id;


CURSOR c_price_obj (pc_object_id VARCHAR2) IS
SELECT pp.object_id,
       ppv.approval_state, ppv.rec_id -- in use for approval check
  FROM product_price pp, product_price_version ppv
 WHERE contract_id = pc_object_id
   AND pp.object_id = ppv.object_id;

lv2_contract_approval_ind VARCHAR2(1);

BEGIN

  -- ** 4-eyes approval check on parent class ** --
  -- If this class has approval, all child classes will also have to be approved
    lv2_contract_approval_ind := NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('CONTRACT'),'N');

    FOR ContractDocCur IN c_contract_doc (p_object_id) LOOP
        DoDelContractDoc(ContractDocCur.Id, 'Y');
    END LOOP;

          DELETE task_detail where rec_id in (SELECT REC_ID from Cntr_Text_Item_Version WHERE object_id = p_object_id);
    DELETE Cntr_Text_Item_Version WHERE object_id = p_object_id;
    DELETE Contract_Text_Item WHERE object_id = p_object_id;


    FOR c_val IN c_price_obj (p_object_id) LOOP

          DELETE task_detail where rec_id in (SELECT REC_ID from product_price_value WHERE object_id = c_val.object_id);
        DELETE product_price_value WHERE object_id = c_val.object_id;

          DELETE task_detail where rec_id in (SELECT REC_ID from price_value_setup
                  WHERE (src_product_price_id = c_val.object_id
                       OR object_id = c_val.object_id));

        DELETE price_value_setup
        WHERE (src_product_price_id = c_val.object_id  -- can be set up as source
               OR object_id = c_val.object_id);        -- or as target

          DELETE task_detail where rec_id in (SELECT REC_ID from product_price_version WHERE object_id = c_val.object_id);
        DELETE product_price_version WHERE object_id = c_val.object_id;
        DELETE product_price WHERE object_id = c_val.object_id;

    END LOOP;

      DELETE task_detail where rec_id in (SELECT REC_ID from contract_price_setup WHERE object_id = p_object_id);
    DELETE contract_price_setup WHERE object_id = p_object_id;

      DELETE task_detail where rec_id in (SELECT REC_ID from contract_party_share WHERE object_id = p_object_id);
    DELETE contract_party_share WHERE object_id = p_object_id;

      DELETE task_detail where rec_id in (SELECT REC_ID from contract_attribute WHERE object_id = p_object_id);
    DELETE contract_attribute WHERE object_id = p_object_id;

    IF lv2_contract_approval_ind = 'Y' and ec_contract_version.approval_state(p_object_id, ec_contract.start_date(p_object_id)) = 'D' THEN
       delete contract_version where object_id = p_object_id;
       delete contract where object_id = p_object_id;
    END IF;

     -- DAO will handle the deletion of the contact itself
END DoDelContract;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  DelContractDoc
-- Description    : When an attempt to delete a document template is made, this procedure deletes transaction templates and line item templates related
--                  to this document template
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
PROCEDURE DelContractDoc (
    p_object_id VARCHAR2
   ,p_end_date  DATE
   ,p_user      VARCHAR2
   )

IS

lv2_tt_split_key_id VARCHAR2(32);

-- ** 4-eyes approval stuff ** --
lv2_contract_doc_approval_ind VARCHAR2(1);

-- ** END 4-eyes approval stuff ** --

BEGIN

  IF p_end_date <> ec_contract_doc.start_date(p_object_id) THEN
     RETURN;
  END IF;

  -- ** 4-eyes approval check on parent class ** --
  -- If this class has approval, all child classes will also have to be approved
  lv2_contract_doc_approval_ind := NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('CONTRACT_DOC'),'N');

  -- ** 4-eyes approval logic - Controlling DELETE on CONTRACT_TEXT_ITEM ** --
  IF lv2_contract_doc_approval_ind= 'Y' and ec_contract_doc_version.approval_state(p_object_id, ec_contract_doc.start_date(p_object_id)) IN ('O','U') THEN
    Ecdp_Approval.registerTaskDetail(ec_contract_doc_version.rec_id(p_object_id, ec_contract_doc.start_date(p_object_id)),
                                        'CONTRACT_DOC',
                                         Nvl(EcDp_Context.getAppUser,User),
                                         'call EcDp_Contract_Setup.DoDelContractDoc(''' || p_object_id || ''', ''Y'')');


  ELSE
      DoDelContractDoc(p_object_id);
  END IF;

END DelContractDoc;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  DoDelContractDoc
-- Description    : Do actual deletion of contract doc, either as callback from 4EApproval or from DelContractDoc
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
PROCEDURE DoDelContractDoc (
    p_object_id        VARCHAR2
   ,p_del_contract_doc VARCHAR2 DEFAULT 'N'
   )

IS

lv2_tt_split_key_id VARCHAR2(32);

CURSOR c_trans (cp_contract_doc_id VARCHAR2) IS
SELECT tt.object_id id, ttv.daytime,
       ttv.approval_state, ttv.rec_id
  FROM transaction_template tt, transaction_tmpl_version ttv
 WHERE contract_doc_id = cp_contract_doc_id
   AND tt.object_id = ttv.object_id;

-- ** 4-eyes approval stuff ** --
lv2_contract_doc_approval_ind VARCHAR2(1);

BEGIN

  -- ** 4-eyes approval check on parent class ** --

     DELETE task_detail where rec_id in (SELECT REC_ID from Cntr_Text_Item_Version WHERE object_id IN (select object_id from Contract_Text_Item where contract_doc_id = p_object_id));
     DELETE Cntr_Text_Item_Version WHERE object_id IN (select object_id from Contract_Text_Item where contract_doc_id = p_object_id);
     DELETE Contract_Text_Item WHERE contract_doc_id = p_object_id;

     FOR TransCur IN c_trans (p_object_id) LOOP
         DoDelTransactionTemplate(TransCur.Id, 'Y');
     END LOOP;

     DELETE task_detail where rec_id in (SELECT REC_ID from contract_doc_company WHERE object_id = p_object_id);
     DELETE contract_doc_company WHERE object_id = p_object_id;

     lv2_contract_doc_approval_ind := NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('CONTRACT_DOC'),'N');
     -- deletion of the contract_doc object itself is handeled by DAO
     IF (lv2_contract_doc_approval_ind= 'N' and ec_contract_doc_version.approval_state(p_object_id, ec_contract_doc.start_date(p_object_id)) = 'D' )
                                       or p_del_contract_doc = 'Y' THEN
        delete from contract_doc_version where object_id = p_object_id;
        delete from contract_doc where object_id = p_object_id;
        IF (NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('CONTRACT_DOC'),'N') = 'Y') THEN
             EcDp_Acl.RefreshObject(p_object_id, 'CONTRACT_DOC', 'DELETING');
        END IF;
     END IF;

END DoDelContractDoc;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  DelTransactionTemplate
-- Description    : Deletes sub objects when deleting a transaction template from business function Contract Transaction Template
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
PROCEDURE DelTransactionTemplate(p_object_id VARCHAR2)
--</EC-DOC>
IS

-- ** 4-eyes approval stuff ** --
lv2_trans_templ_approval_ind VARCHAR2(1);

BEGIN

  -- ** 4-eyes approval check on parent class ** --
  -- If this class has approval, all child classes will also have to be approved
  lv2_trans_templ_approval_ind := NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('TRANSACTION_TEMPLATE'),'N');

  -- ** 4-eyes approval logic - Controlling DELETE on CONTRACT_TEXT_ITEM ** --
  IF lv2_trans_templ_approval_ind = 'Y' and ec_transaction_tmpl_version.approval_state(p_object_id, ec_transaction_template.start_date(p_object_id)) IN ('O','U') THEN
    Ecdp_Approval.registerTaskDetail(ec_transaction_tmpl_version.rec_id(p_object_id, ec_transaction_template.start_date(p_object_id)),
                                        'TRANSACTION_TEMPLATE',
                                         Nvl(EcDp_Context.getAppUser,User),
                                         'call EcDp_Contract_Setup.DoDelTransactionTemplate(''' || p_object_id || ''', ''Y'')');

  ELSE
      DoDelTransactionTemplate(p_object_id);
  END IF;


END DelTransactionTemplate;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  DoDelTransactionTemplate
-- Description    : Do actual deletion of transaction template, either as callback from 4EApproval or from DelTransactionTemplate
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
PROCEDURE DoDelTransactionTemplate(p_object_id VARCHAR2, p_del_trans_templ VARCHAR2 default 'N')
--</EC-DOC>
IS


lv2_trans_templ_approval_ind VARCHAR2(1);


CURSOR c_child_split(cp_split_key_id VARCHAR2) IS
SELECT child_split_key_id
  FROM split_key_setup
 WHERE object_id = cp_split_key_id
   AND child_split_key_id is not null;

-- ** END 4-eyes approval stuff ** --

lv2_tt_split_key_id       VARCHAR2(32);
lv2_tt_child_split_key_id VARCHAR2(32);

BEGIN

    -- Get split key ID before transaction is deleted
    lv2_tt_split_key_id := ec_transaction_tmpl_version.split_key_id(p_object_id,ec_transaction_template.start_date(p_object_id),'<=');

    -- The transaction template itself is deleted by DAO. But when 4E approval is in place it needs to be delted here as well.

    lv2_trans_templ_approval_ind := NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('TRANSACTION_TEMPLATE'),'N');

    UPDATE transaction_tmpl_version
       SET split_key_id = NULL,
           last_updated_date = last_updated_date
     WHERE object_id = p_object_id;


    --Delete unused interface records
    DELETE ifac_sales_qty p
     WHERE p.trans_temp_id = p_object_id
       AND p.trans_key_set_ind = 'N';

    DELETE ifac_cargo_value c
     WHERE c.trans_temp_id = p_object_id
       AND c.trans_key_set_ind = 'N';

    -- Deleting text items
      DELETE task_detail where rec_id in (SELECT REC_ID from Cntr_Text_Item_Version WHERE object_id IN (select object_id from Contract_Text_Item where transaction_template_id = p_object_id));
    DELETE Cntr_Text_Item_Version WHERE object_id IN (select object_id from Contract_Text_Item where transaction_template_id = p_object_id);
    DELETE Contract_Text_Item WHERE transaction_template_id = p_object_id;


    -- delete all LI template objects
      DELETE task_detail where rec_id in (SELECT REC_ID from  line_item_tmpl_version WHERE object_id IN (select object_id from Line_Item_Template where transaction_template_id = p_object_id));
    DELETE line_item_tmpl_version WHERE object_id IN (select object_id from Line_Item_Template where transaction_template_id = p_object_id);
    DELETE Line_Item_Template WHERE transaction_template_id = p_object_id;

    -- Deleting all split key information related to the transaction template being deleted.

    -- ** 4-eyes approval logic - Controlling DELETE on SPLIT_KEY_SETUP** --

    IF (lv2_trans_templ_approval_ind = 'Y' and ec_transaction_tmpl_version.approval_state(p_object_id, ec_transaction_template.start_date(p_object_id)) = 'D')
                                     or p_del_trans_templ = 'Y' THEN
       delete from transaction_tmpl_version where object_id = p_object_id;
       delete from transaction_template where object_id = p_object_id;
       IF (NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('TRANSACTION_TEMPLATE'),'N') = 'Y') THEN
           EcDp_Acl.RefreshObject(p_object_id, 'TRANSACTION_TEMPLATE', 'DELETING');
       END IF;
    END IF;


    FOR r_child_split IN c_child_split(lv2_tt_split_key_id) LOOP
        lv2_tt_child_split_key_id := r_child_split.child_split_key_id;

        UPDATE split_key_setup sks set child_split_key_id = null WHERE sks.object_id = lv2_tt_split_key_id and sks.child_split_key_id = lv2_tt_child_split_key_id;
          DELETE task_detail where rec_id in (SELECT REC_ID from split_key_setup sks WHERE sks.object_id = lv2_tt_child_split_key_id);
        DELETE split_key_setup sks WHERE sks.object_id = lv2_tt_child_split_key_id;
          DELETE task_detail where rec_id in (SELECT REC_ID from split_key_version skv WHERE skv.object_id = lv2_tt_child_split_key_id);
        DELETE split_key_version skv WHERE skv.object_id = lv2_tt_child_split_key_id;
        DELETE split_key sk WHERE sk.object_id = lv2_tt_child_split_key_id;

    END LOOP;

      DELETE task_detail where rec_id in (SELECT REC_ID from split_key_setup sks WHERE sks.object_id = lv2_tt_split_key_id);
    DELETE split_key_setup sks WHERE sks.object_id = lv2_tt_split_key_id;
      DELETE task_detail where rec_id in (SELECT REC_ID from split_key_version skv WHERE skv.object_id = lv2_tt_split_key_id);
    DELETE split_key_version skv WHERE skv.object_id = lv2_tt_split_key_id;
    DELETE split_key sk WHERE sk.object_id = lv2_tt_split_key_id;

END DoDelTransactionTemplate;


PROCEDURE ReviseContract(
   p_object_id VARCHAR2,
   p_daytime   DATE,
   p_user      VARCHAR2 DEFAULT NULL
)

IS


ld_start_date DATE := ecdp_objects.getobjstartdate(p_object_id);
ld_end_date DATE := ecdp_objects.getobjenddate(p_object_id);
ld_previous_revision DATE;

revision_exists EXCEPTION;
not_valid_date EXCEPTION;

BEGIN

 IF p_daytime < ld_start_date THEN

        RAISE not_valid_date;

     ELSIF p_daytime > nvl(ld_end_date,p_daytime) THEN

        RAISE not_valid_date;

     END IF;

     --SELECT max(daytime)
     --INTO ld_previous_revision
     --FROM objects_attribute
     --WHERE object_id = p_object_id
     --AND attribute_type = 'CODE'
     --AND daytime <= p_daytime;

     select max(cdv.daytime)
     into ld_previous_revision
     from CONTRACT_DOC cd, CONTRACT_DOC_VERSION cdv
     where cd.object_id = cdv.object_id
     and cd.object_id = p_object_id
     and cdv.daytime <= p_daytime;

     IF ld_previous_revision = p_daytime THEN

        RAISE revision_exists;

     END IF;

     /*FOR AttrRecord IN c_attributes(ld_previous_revision) LOOP

         IF AttrRecord.ov_type = 'CLASSES_ATTR' THEN

           -- for each existing valid attribute, insert new one with new valid from date
           INSERT INTO objects_attribute
              (object_id, daytime, attribute_type, attribute_text, attribute_value, attribute_date,created_by)
           VALUES
              (AttrRecord.object_id, p_daytime, AttrRecord.attribute_type, AttrRecord.attribute_text, AttrRecord.attribute_value, AttrRecord.attribute_date,p_user);

         ELSE

            EcDp_objects.Insobjattrrevision(p_object_id,p_daytime,AttrRecord.attribute_type,AttrRecord.attribute_text,AttrRecord.attribute_value,AttrRecord.attribute_date,AttrRecord.ov_type,p_user);

         END IF;

     END LOOP;*/

EXCEPTION

    WHEN not_valid_date THEN

         Raise_Application_Error(-20000,'Cannot create new version outside start date / end date range.');

    WHEN revision_exists THEN

         Raise_Application_Error(-20000,'Version already exists.');

END ReviseContract;

PROCEDURE CreDefaultCustomerVendor(
   p_object_id VARCHAR2,
   p_daytime   DATE,
   p_user      VARCHAR2 DEFAULT NULL
   )

IS

CURSOR c_vendor (pc_contract_owner_id VARCHAR2) IS
SELECT c.object_id id
FROM company c
WHERE c.company_id = pc_contract_owner_id
AND c.class_name = 'VENDOR'
AND p_daytime >= Nvl(c.start_date,p_daytime-1)
AND p_daytime < Nvl(c.end_date,p_daytime+1);

CURSOR c_customer (pc_contract_owner_id VARCHAR2) IS
SELECT c.object_id id
FROM company c
WHERE c.company_id = pc_contract_owner_id
AND c.class_name = 'CUSTOMER'
AND p_daytime >= Nvl(c.start_date,p_daytime-1)
AND p_daytime < Nvl(c.end_date,p_daytime+1);

lv2_cont_fin_code varchar2(32) := ec_contract_version.financial_code(p_object_id, p_daytime, '<=');
lv2_cont_owner_company varchar2(32):= ec_contract_version.company_id(p_object_id, p_daytime, '<=');
lv2_vendor_id objects.object_id%TYPE;
lv2_customer_id objects.object_id%TYPE;
-- ld_contract_end_date varchar2(32)  := ec_contract.end_date(p_object_id);

no_vendor_assigned EXCEPTION;
no_customer_assigned EXCEPTION;


-- ** 4-eyes approval stuff ** --
lv2_4e_recid VARCHAR2(32);
-- ** END 4-eyes approval stuff ** --


BEGIN
     -- Do not set default customer/vendor if contract owner is empty
     IF lv2_cont_owner_company IS NULL THEN
         RETURN;
     END IF;

     -- Default Bank Details level code set to BY_CONT_OWNER for Single Company Sales
     -- Set document handling code also to Single Doc
     UPDATE contract_version cv SET cv.bank_details_level_code = 'BY_CONT_OWNER'
     , cv.document_handling_code = 'SINGLE_DOC'
     WHERE cv.object_id = p_object_id
     AND cv.daytime = p_daytime;

     IF lv2_cont_fin_code IN ('SALE','TA_INCOME') THEN

       FOR C_VendorCur IN c_vendor(lv2_cont_owner_company) LOOP

          lv2_vendor_id := C_VendorCur.id;
          INSERT INTO contract_party_share (object_id, company_id, party_role, daytime, party_share, class_name)
          VALUES (p_object_id, lv2_vendor_id, 'VENDOR', p_daytime, 100, 'CONTRACT_VEND_PARTIES');


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
             WHERE object_id = p_object_id
               AND daytime = p_daytime
               AND company_id = lv2_vendor_id
               AND party_role = 'VENDOR';

            -- Register new record for approval
            Ecdp_Approval.registerTaskDetail(lv2_4e_recid,
                                              'CONTRACT_VEND_PARTIES',
                                              Nvl(EcDp_Context.getAppUser,User));
          END IF;




       END LOOP;

       IF lv2_vendor_id IS NULL THEN

          RAISE no_vendor_assigned;

       END IF;

     ELSIF lv2_cont_fin_code IN ('PURCHASE','TA_COST') THEN

       -- Now do the same for the customer

       FOR C_CustomerCur IN c_customer(lv2_cont_owner_company) LOOP

          lv2_customer_id := C_CustomerCur.id;
          INSERT INTO contract_party_share (object_id, company_id, party_role, daytime, party_share,class_name)
          VALUES (p_object_id, lv2_customer_id, 'CUSTOMER', p_daytime, 100,'CONTRACT_CUST_PARTIES');


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
             WHERE object_id = p_object_id
               AND daytime = p_daytime
               AND company_id = lv2_customer_id
               AND party_role = 'CUSTOMER';

            -- Register new record for approval
            Ecdp_Approval.registerTaskDetail(lv2_4e_recid,
                                              'CONTRACT_CUST_PARTIES',
                                              Nvl(EcDp_Context.getAppUser,User));
          END IF;





       END LOOP;

       IF lv2_customer_id IS NULL THEN

          RAISE no_customer_assigned;

       END IF;

     ELSIF lv2_cont_fin_code = ('JOU_ENT') THEN

           FOR C_VendorCur IN c_vendor(lv2_cont_owner_company) LOOP

          lv2_vendor_id := C_VendorCur.id;
          INSERT INTO contract_party_share (object_id, company_id, party_role, daytime, party_share,class_name)
          VALUES (p_object_id, lv2_vendor_id, 'VENDOR', p_daytime, 100,'CONTRACT_VEND_PARTIES');


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
             WHERE object_id = p_object_id
               AND daytime = p_daytime
               AND company_id = lv2_vendor_id
               AND party_role = 'VENDOR';

            -- Register new record for approval
            Ecdp_Approval.registerTaskDetail(lv2_4e_recid,
                                              'CONTRACT_VEND_PARTIES',
                                              Nvl(EcDp_Context.getAppUser,User));
          END IF;




       END LOOP;

       IF lv2_vendor_id IS NULL THEN

          RAISE no_vendor_assigned;

       END IF;

       -- Now do the same for the customer

       FOR C_CustomerCur IN c_customer(lv2_cont_owner_company) LOOP

          lv2_customer_id := C_CustomerCur.id;
          INSERT INTO contract_party_share (object_id, company_id, party_role, daytime, party_share, class_name)
          VALUES (p_object_id, lv2_customer_id, 'CUSTOMER', p_daytime, 100,'CONTRACT_CUST_PARTIES');


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
             WHERE object_id = p_object_id
               AND daytime = p_daytime
               AND company_id = lv2_customer_id
               AND party_role = 'CUSTOMER';

            -- Register new record for approval
            Ecdp_Approval.registerTaskDetail(lv2_4e_recid,
                                              'CONTRACT_CUST_PARTIES',
                                              Nvl(EcDp_Context.getAppUser,User));
          END IF;





       END LOOP;

       IF lv2_customer_id IS NULL THEN

          RAISE no_customer_assigned;

       END IF;

     END IF;

EXCEPTION

     WHEN no_vendor_assigned THEN

              Raise_Application_Error(-20000,'The Contract owner company ' || lv2_vendor_id || ' is not defined as a Vendor ' );

     WHEN no_customer_assigned THEN

              Raise_Application_Error(-20000,'The Contract owner company ' || lv2_customer_id || ' is not defined as a Customer ' );


END CreDefaultCustomerVendor;

PROCEDURE ValidateContrCustVend(
   p_object_id VARCHAR2,
   p_daytime   DATE,
   p_user      VARCHAR2 DEFAULT NULL
   )

IS
/*
combination_not_allowed EXCEPTION;
combination_not_use EXCEPTION;
invalid_combination EXCEPTION;
missing_vend_cust EXCEPTION;
invalid_doc_code EXCEPTION;

ln_customer_cnt NUMBER;
ln_vendor_cnt NUMBER;

lv2_financial_code   VARCHAR2(32) := EcDp_Objects.GetObjAttrText(p_object_id,p_daytime,'FINANCIAL_CODE');
lv2_create_doc_code VARCHAR2(32) := Nvl(EcDp_Objects.GetObjAttrText(p_object_id,p_daytime,'DOCUMENT_HANDLING_CODE'),'ONE_PER_PARTY'); -- set default
lv2_bank_details_level_code   VARCHAR2(32) := EcDp_Objects.GetObjAttrText(p_object_id,p_daytime,'BANK_DETAILS_LEVEL_CODE');
*/
combination_not_allowed EXCEPTION;
combination_not_use EXCEPTION;
invalid_combination EXCEPTION;
missing_vend_cust EXCEPTION;
invalid_doc_code EXCEPTION;

ln_customer_cnt NUMBER;
ln_vendor_cnt NUMBER;

lv2_financial_code varchar2(32) := ec_contract_version.financial_code(p_object_id, p_daytime, '<=');
lv2_create_doc_code VARCHAR2(32) := Nvl(ec_contract_version.document_handling_code(p_object_id, p_daytime, '<='), 'ONE_PER_PARTY'); -- set default
lv2_bank_details_level_code VARCHAR2(240) := ec_contract_version.bank_details_level_code(p_object_id, p_daytime, '<=');

BEGIN

    ln_vendor_cnt := GetVendorCnt(p_object_id,p_daytime);
    ln_customer_cnt := GetCustomerCnt(p_object_id,p_daytime);

    --------------------------------------------------------------------------------


    IF ln_customer_cnt > 1 THEN
       RAISE combination_not_allowed;
    END IF;
    --------------------------------------------------------------------------------


     --------------------------------------------------------------------------------
     -- 1 vendor, 1 customer

     /*IF ln_vendor_cnt = 1  AND ln_customer_cnt = 1 THEN

         EcDp_Objects.SetObjAttrText(p_object_id,p_daytime,'DOCUMENT_HANDLING_CODE','SINGLE_DOC',NULL,p_user, p_user);
         EcDp_Objects.SetObjAttrText(p_object_id,p_daytime,'BANK_DETAILS_LEVEL_CODE','BY_CONT_OWNER', null, p_user, p_user);


      --------------------------------------------------------------------------------
     -- 1 vendor, n customers, single document
     ELSIF ln_vendor_cnt = 1  AND ln_customer_cnt > 1 AND lv2_financial_code IN ('SALE','TA_INCOME') THEN

        EcDp_Objects.SetObjAttrText(p_object_id,p_daytime,'DOCUMENT_HANDLING_CODE','ONE_PER_PARTY',null,p_user,p_user);
        EcDp_Objects.SetObjAttrText(p_object_id,p_daytime,'BANK_DETAILS_LEVEL_CODE','BY_CONT_OWNER',null,p_user,p_user);


     --------------------------------------------------------------------------------
     -- 1 vendor, n customers, one per counterparty
     ELSIF ln_vendor_cnt = 1  AND ln_customer_cnt > 1  AND lv2_financial_code IN ('PURCHASE','TA_COST') THEN

        EcDp_Objects.SetObjAttrText(p_object_id,p_daytime,'DOCUMENT_HANDLING_CODE','SINGLE_DOC',null,p_user,p_user);
        EcDp_Objects.SetObjAttrText(p_object_id,p_daytime,'BANK_DETAILS_LEVEL_CODE','BY_EACH_VENDOR',null,p_user,p_user);

     --------------------------------------------------------------------------------
     -- n vendors, 1 customer, single document
      ELSIF ln_vendor_cnt > 1  AND ln_customer_cnt = 1 AND lv2_financial_code IN ('PURCHASE','TA_COST') THEN

        EcDp_Objects.SetObjAttrText(p_object_id,p_daytime,'DOCUMENT_HANDLING_CODE','ONE_PER_PARTY',null,p_user,p_user);
        EcDp_Objects.SetObjAttrText(p_object_id,p_daytime,'BANK_DETAILS_LEVEL_CODE','BY_EACH_VENDOR',null,p_user,p_user);


     --------------------------------------------------------------------------------
     -- n vendors, 1 customer, one per party
      ELSIF ln_vendor_cnt > 1  AND ln_customer_cnt = 1 AND lv2_financial_code IN ('SALE','TA_INCOME') THEN

        EcDp_Objects.SetObjAttrText(p_object_id,p_daytime,'DOCUMENT_HANDLING_CODE','SINGLE_DOC',null,p_user,p_user);


      ELSIF ln_vendor_cnt > 1  AND ln_customer_cnt > 1  THEN

        -- combination not in use
        RAISE invalid_combination;


      ELSIF ln_vendor_cnt = 0  AND ln_customer_cnt = 0  THEN

        -- combination not in use
        RAISE missing_vend_cust;


      ELSIF ln_vendor_cnt = 0  AND ln_customer_cnt >= 1  THEN

        -- ok
        NULL;

      ELSIF ln_vendor_cnt >= 1  AND ln_customer_cnt = 0  THEN

        -- ok
        NULL;

      ELSIF ln_vendor_cnt >= 1  AND ln_customer_cnt = 1  THEN

        -- ok
        NULL;

      ELSIF ln_vendor_cnt = 1  AND ln_customer_cnt >= 1  THEN

        -- ok
        NULL;

      ELSE

        -- combination not in use
        RAISE combination_not_use;


      END IF;*/

EXCEPTION

     /*WHEN missing_vend_cust THEN

              Raise_Application_Error(-20000,'Either customer or vendor is missing. Not able to create document for contract: ' || Nvl(EcDp_Objects.GetObjAttrText(p_object_id,p_daytime,'CODE'),' ') || ' - ' || Nvl(EcDp_Objects.GetObjAttrText(p_object_id,p_daytime,'NAME'),' ') );

     WHEN combination_not_use THEN

              Raise_Application_Error(-20000,'Combination of vendors / customers and create document indicator is not in use for contract: ' || Nvl(EcDp_Objects.GetObjAttrText(p_object_id,p_daytime,'CODE'),' ') || ' - ' || Nvl(EcDp_Objects.GetObjAttrText(p_object_id,p_daytime,'NAME'),' ') );

     WHEN invalid_combination THEN

              Raise_Application_Error(-20000,'Combination of multiple vendors and multiple customers is not allowed. Contract: ' || Nvl(EcDp_Objects.GetObjAttrText(p_object_id,p_daytime,'CODE'),' ') || ' - ' || Nvl(EcDp_Objects.GetObjAttrText(p_object_id,p_daytime,'NAME'),' ') );

     WHEN invalid_doc_code THEN

              Raise_Application_Error(-20000,'Invalid document code: <' || Nvl(lv2_create_doc_code,'Null') || '> for contract: ' || Nvl(EcDp_Objects.GetObjAttrText(p_object_id,p_daytime,'CODE'),' ') || ' - ' || Nvl(EcDp_Objects.GetObjAttrText(p_object_id,p_daytime,'NAME'),' ') );*/

     WHEN combination_not_allowed THEN

              Raise_Application_Error(-20000,'Only one customer allowed.');
END ValidateContrCustVend;



--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  GetPriceElemVal
-- Description    : Retrieves price element value
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
FUNCTION GetPriceElemVal(
   p_object_id VARCHAR2,
   p_price_object_id VARCHAR2,
   p_price_elem_code VARCHAR2,
   p_product_id VARCHAR2,
   p_pricing_currency_id VARCHAR2,
   p_daytime   DATE,
   p_parcel_key VARCHAR2
) RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_price(cp_contract_id VARCHAR2, cp_price_object_id VARCHAR2, cp_price_elem_code VARCHAR2,
               cp_pricing_currency_id VARCHAR2, cp_product_id VARCHAR2, cp_parcel_key VARCHAR2, cp_daytime DATE) IS
(
SELECT ppv.calc_price_value, -- Contract prices
       ppv.adj_price_value,
       ppv.daytime daytime,
       ppv.object_id price_object_id,
       ppv.price_concept_code price_concept_code,
       ppv.price_element_code price_element_code,
       100 SORT_ORDER
  FROM product_price pp, product_price_version ppvs, product_price_value ppv
 WHERE pp.object_id = cp_price_object_id
   AND ppv.price_element_code = cp_price_elem_code
   AND ppv.parcel_key is null
   and cp_parcel_key is null
   AND ppv.object_id = pp.object_id
   AND pp.contract_id = cp_contract_id
   AND ppv.daytime <= cp_daytime
   AND ppv.daytime = (SELECT MAX(daytime)
                        FROM product_price_value ppv2
                       WHERE ppv2.object_id = ppv.object_id
                         AND ppv2.parcel_key is null
                         AND ppv2.daytime <= cp_daytime)
   AND pp.object_id = ppvs.object_id
   AND ppvs.currency_id = cp_pricing_currency_id
   AND ppvs.daytime = (SELECT MAX(ppvs2.daytime)
                        FROM product_price_version ppvs2
                       WHERE ppvs2.object_id = ppvs.object_id
                         AND ppvs2.daytime <= cp_daytime)
UNION
SELECT ppv.calc_price_value, -- Cargo specific prices
       ppv.adj_price_value,
       ppv.daytime daytime,
       ppv.object_id price_object_id,
       ppv.price_concept_code price_concept_code,
       ppv.price_element_code price_element_code,
       100 SORT_ORDER
  FROM product_price pp, product_price_version ppvs, product_price_value ppv
 WHERE pp.object_id = cp_price_object_id
   AND ppv.price_element_code = cp_price_elem_code
   AND ppv.parcel_key is not null
   AND ppv.parcel_key = nvl(cp_parcel_key,'NA')
   AND ppv.object_id = pp.object_id
   AND pp.contract_id = cp_contract_id
   AND ppv.daytime <= cp_daytime
   AND ppv.daytime = (SELECT MAX(daytime)
                        FROM product_price_value ppv2
                       WHERE ppv2.object_id = ppv.object_id
                         AND ppv2.parcel_key is not null
                         AND ppv2.parcel_key = nvl(cp_parcel_key,'NA')
                         AND ppv2.daytime <= cp_daytime)
   AND pp.object_id = ppvs.object_id
   AND ppvs.currency_id = cp_pricing_currency_id
   AND ppvs.daytime = (SELECT MAX(ppvs2.daytime)
                        FROM product_price_version ppvs2
                       WHERE ppvs2.object_id = ppvs.object_id
                         AND ppvs2.daytime <= cp_daytime)
UNION
SELECT gppv.calc_price_value, -- General prices
       gppv.adj_price_value,
       gppv.daytime daytime,
       gppv.object_id price_object_id,
       gppv.price_concept_code price_concept_code,
       gppv.price_element_code price_element_code,
       1 SORT_ORDER
  FROM product_price         gpp,
       product_price_version gppver,
       product_price_value   gppv
 WHERE gpp.object_id = cp_price_object_id
   AND gpp.object_id = gppver.object_id
   AND gppver.daytime <= cp_daytime
   AND gppver.currency_id = cp_pricing_currency_id
   AND gppv.price_element_code = cp_price_elem_code
   AND gppv.object_id = gpp.object_id
   AND gpp.contract_id IS NULL
   AND gppv.parcel_key is null
   AND cp_parcel_key is null
   AND gppv.daytime = (SELECT MAX(daytime)
                         FROM product_price_value ppv2
                        WHERE ppv2.object_id = gppv.object_id
                          AND ppv2.parcel_key is null
                          AND ppv2.daytime <= cp_daytime)
   AND gpp.object_id IN (SELECT product_price_id
                           FROM contract_price_setup
                          WHERE object_id = p_object_id
                            AND daytime <= cp_daytime))
 ORDER BY daytime, SORT_ORDER;

CURSOR c_derived_price(cp_price_object_id VARCHAR2, cp_price_concept_code VARCHAR2, cp_price_element_code VARCHAR2) IS
SELECT pvs.*
FROM price_value_setup pvs
WHERE pvs.object_id = cp_price_object_id
AND   pvs.price_concept_code = cp_price_concept_code
AND   pvs.price_element_code = cp_price_element_code
AND   pvs.daytime <= p_daytime
AND   NVL(pvs.end_date, p_daytime + 1) >= p_daytime
order by pvs.daytime asc;

ln_price_decimals NUMBER := ec_contract_version.price_decimals(p_object_id, p_daytime, '<=');

invalid_price_basis EXCEPTION;

ln_calc_price NUMBER := NULL;
ln_adj_price NUMBER := NULL;
ln_price NUMBER := NULL;
ln_derived_price NUMBER := NULL;

BEGIN



    FOR PriceCur IN c_price(p_object_id, p_price_object_id, p_price_elem_code, p_pricing_currency_id, p_product_id, p_parcel_key, p_daytime) LOOP
        ln_calc_price := PriceCur.calc_price_value;
        ln_adj_price := PriceCur.adj_price_value;

        -- Find Factor Based Price if exists
        FOR CalcPrice IN c_derived_price(PriceCur.price_object_id, PriceCur.price_concept_code, PriceCur.price_element_code) LOOP

            ln_derived_price := GetPriceElemVal(p_object_id, CalcPrice.src_product_price_id, CalcPrice.Src_Price_Element_Code, p_product_id, p_pricing_currency_id, p_daytime, p_parcel_key);
            ln_calc_price := CalcPrice.Factor * ln_derived_price + NVL(CalcPrice.constant_factor, 0);
            ln_adj_price := CalcPrice.Factor * ln_derived_price + NVL(CalcPrice.constant_factor, 0);

        END LOOP;

    END LOOP;

    -- Pick adjusted price if present, else take calculated price
    IF (ln_adj_price IS NULL ) THEN
        ln_price := ln_calc_price;
    ELSE
        ln_price := ln_adj_price;
    END IF;

    IF nvl(ln_price_decimals,-1) >= 0 THEN
        ln_price :=  round(ln_price, ln_price_decimals);
    END IF;


    RETURN ln_price;



END GetPriceElemVal;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  GetPriceElemDate
-- Description    : Retrieves price element date
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
FUNCTION GetPriceElemDate(
   p_object_id VARCHAR2,
   p_price_object_id VARCHAR2,
   p_price_elem_code VARCHAR2,
   p_product_id VARCHAR2,
   p_pricing_currency_id VARCHAR2,
   p_daytime   DATE,
   p_parcel_key VARCHAR2
)
 RETURN DATE
--</EC-DOC>
IS

CURSOR c_price (cp_contract_id VARCHAR2, cp_price_object_id VARCHAR2, cp_price_elem_code VARCHAR2,
                cp_pricing_currency_id VARCHAR2, cp_product_id VARCHAR2, cp_parcel_key VARCHAR2, cp_daytime DATE) IS
(
SELECT
      ppv.daytime -- Contract prices
      ,100 SORT_ORDER
  FROM product_price pp, product_price_version ppvs, product_price_value ppv
 WHERE pp.object_id = cp_price_object_id
   AND pp.product_id = cp_product_id
   AND ppv.price_element_code = cp_price_elem_code
   AND ppv.parcel_key is null
   AND cp_parcel_key is null
   AND ppv.object_id = pp.object_id
   AND pp.contract_id = cp_contract_id
   AND ppv.daytime <= cp_daytime
   AND ppv.daytime = (SELECT MAX(daytime)
                        FROM product_price_value ppv2
                       WHERE ppv2.object_id = ppv.object_id
                         AND ppv2.parcel_key IS NULL
                         AND ppv2.daytime <= cp_daytime)
   AND pp.object_id = ppvs.object_id
   AND ppvs.currency_id = cp_pricing_currency_id
   AND ppvs.daytime = (SELECT MAX(ppvs2.daytime)
                        FROM product_price_version ppvs2
                       WHERE ppvs2.object_id = ppvs.object_id
                         AND ppvs2.daytime <= cp_daytime)
UNION
SELECT
      ppv.daytime -- Cargo prices
      ,100 SORT_ORDER
  FROM product_price pp, product_price_version ppvs, product_price_value ppv
 WHERE pp.object_id = cp_price_object_id
   AND pp.product_id = cp_product_id
   AND ppv.price_element_code = cp_price_elem_code
   AND ppv.parcel_key is not null
   AND ppv.parcel_key = NVL(cp_parcel_key,'NA')
   AND ppv.object_id = pp.object_id
   AND pp.contract_id = cp_contract_id
   AND ppv.daytime <= cp_daytime
   AND ppv.daytime = (SELECT MAX(daytime)
                        FROM product_price_value ppv2
                       WHERE ppv2.object_id = ppv.object_id
                         AND ppv2.parcel_key IS NOT NULL
                         AND ppv2.parcel_key = NVL(cp_parcel_key,'NA')
                         AND ppv2.daytime <= cp_daytime)
   AND pp.object_id = ppvs.object_id
   AND ppvs.currency_id = cp_pricing_currency_id
   AND ppvs.daytime = (SELECT MAX(ppvs2.daytime)
                        FROM product_price_version ppvs2
                       WHERE ppvs2.object_id = ppvs.object_id
                         AND ppvs2.daytime <= cp_daytime)
UNION
SELECT gppv.daytime -- General prices
       ,1 SORT_ORDER
  FROM product_price         gpp,
       product_price_version gppver,
       product_price_value   gppv
 WHERE gpp.object_id = cp_price_object_id
   AND gpp.object_id = gppver.object_id
   AND gpp.product_id = cp_product_id
   AND gppver.daytime <= cp_daytime
   AND gppver.currency_id = cp_pricing_currency_id
   AND gppv.price_element_code = cp_price_elem_code
   AND gppv.object_id = gpp.object_id
   AND gpp.contract_id IS NULL
   AND gppv.parcel_key IS NULL
   AND cp_parcel_key IS NULL
   AND gppv.daytime = (SELECT MAX(daytime)
                         FROM product_price_value ppv2
                        WHERE ppv2.object_id = gppv.object_id
                          AND ppv2.parcel_key IS NULL
                          AND ppv2.daytime <= cp_daytime)
   AND gpp.object_id IN (SELECT product_price_id
                           FROM contract_price_setup
                          WHERE object_id = cp_contract_id
                            AND daytime <= cp_daytime))
 ORDER BY daytime, SORT_ORDER;

ld_price DATE := NULL;

BEGIN

    FOR PriceDCur IN c_price(p_object_id, p_price_object_id, p_price_elem_code, p_pricing_currency_id, p_product_id, p_parcel_key, p_daytime) LOOP
        ld_price := PriceDCur.daytime;
    END LOOP;

    RETURN ld_price;

END GetPriceElemDate;


FUNCTION GetPriceConceptVal(
   p_object_id VARCHAR2,
   p_price_object_id VARCHAR2,
   p_price_concept_code VARCHAR2,
   p_product_id VARCHAR2,
   p_pricing_currency_id VARCHAR2,
   p_daytime   DATE,
   p_parcel_key VARCHAR2 DEFAULT NULL
) RETURN NUMBER

IS


CURSOR c_contract_price_elem IS
SELECT pp.object_id, ppv.price_element_code price_element
FROM product_price pp, product_price_value ppv
WHERE pp.price_concept_code = p_price_concept_code
  AND pp.object_id = ppv.object_id
  AND ppv.daytime = (SELECT MAX(daytime) FROM product_price_value ppv2 WHERE ppv2.object_id = pp.object_id AND ppv.price_concept_code = ppv2.price_concept_code AND ppv.price_element_code = ppv2.price_element_code)
  AND p_daytime >= Nvl(start_date,p_daytime-1)
  AND p_daytime < Nvl(end_date,p_daytime+1)
  AND pp.contract_id = p_object_id
;

CURSOR c_general_price_elem IS
SELECT pp.object_id, ppv.price_element_code price_element
FROM product_price pp, product_price_value ppv
WHERE pp.price_concept_code = p_price_concept_code
  AND pp.object_id = ppv.object_id
  AND ppv.daytime = (SELECT MAX(daytime) FROM product_price_value ppv2 WHERE ppv2.object_id = pp.object_id AND ppv.price_concept_code = ppv2.price_concept_code AND ppv.price_element_code = ppv2.price_element_code)
  AND p_daytime >= Nvl(start_date,p_daytime-1)
  AND p_daytime < Nvl(end_date,p_daytime+1)
  AND pp.contract_id IS NULL
;

ln_return_val NUMBER;


BEGIN
     -- First, check for contract prices
     FOR ConPriceElemCur IN c_contract_price_elem LOOP

         --ln_return_val := Nvl(ln_return_val,0) + GetPriceElemVal(p_object_id, p_price_concept_code, ConPriceElemCur.price_element, p_product_id,p_pricing_currency_id,p_daytime, p_parcel_key);
         ln_return_val := Nvl(ln_return_val,0) + GetPriceElemVal(p_object_id, p_price_object_id, ConPriceElemCur.price_element, p_product_id, p_pricing_currency_id, p_daytime, p_parcel_key);

     END LOOP;

     -- Second, if contract price was not found, attempt to find general price
     IF ln_return_val IS NULL THEN

        FOR GenPriceElemCur IN c_general_price_elem LOOP

            --ln_return_val := Nvl(ln_return_val,0) + GetPriceElemVal(p_object_id, p_price_concept_code, GenPriceElemCur.price_element, p_product_id,p_pricing_currency_id,p_daytime, p_parcel_key);
            ln_return_val := Nvl(ln_return_val,0) + GetPriceElemVal(p_object_id, p_price_object_id, GenPriceElemCur.price_element, p_product_id, p_pricing_currency_id, p_daytime, p_parcel_key);

        END LOOP;

     END IF;

     RETURN ln_return_val;

END GetPriceConceptVal;

PROCEDURE InsNewPriceElementSet(
   p_object_id VARCHAR2,
   p_product_id VARCHAR2,
   p_price_concept_id VARCHAR2,
   p_daytime   DATE,
   p_user     VARCHAR2
)

IS

BEGIN

Raise_Application_Error(-20000,'TO BE IMPLEMENTED');

/*
     -- copy from previous mth prices

     INSERT INTO cont_price_element_value
     (
      OBJECT_ID	,
      PRODUCT_OBJECT_ID	,
      PRICE_ELEMENT_OBJECT_ID	,
      PRICE_CONCEPT_OBJECT_ID,           -- JE 10.12.2002
      DAYTIME	,
      FACTOR_BASIS_LEVEL_CODE	,
      PRICE_BASIS_CODE,
      PRICE_VALUE	,
      CREATED_BY ,
      RECORD_STATUS ,
      FACTOR ,                           -- TRA 24.02.2003
      FACTOR_BASIS ,                     -- TRA 24.02.2003
      PRICE_STRUCT_OBJECT_ID
     )
     SELECT
      OBJECT_ID	,
      PRODUCT_OBJECT_ID	,
      PRICE_ELEMENT_OBJECT_ID	,
      PRICE_CONCEPT_OBJECT_ID,            -- JE 10.12.2002
      p_daytime	,
      FACTOR_BASIS_LEVEL_CODE	,
      PRICE_BASIS_CODE,
      PRICE_VALUE	,
      p_user,
      'P',
      FACTOR ,                           -- TRA 24.02.2003
      FACTOR_BASIS ,                     -- TRA 24.02.2003
      PRICE_STRUCT_OBJECT_ID
     FROM cont_price_element_value x
         WHERE object_id = p_object_id
           AND product_object_id = p_product_id
           AND price_concept_object_id = p_price_concept_id   -- JE 10.12.2002
           AND daytime =
               (SELECT Max(daytime)
               FROM cont_price_element_value
               WHERE object_id = x.object_id
                 AND product_object_id = x.product_object_id
                 AND price_element_object_id = x.price_element_object_id
                 AND price_concept_object_id = x.price_concept_object_id    -- JE 10.12.2002
                 AND daytime <= p_daytime)
           AND EXISTS -- but only take those elements still part of relevant price concept
               (SELECT 'x'
                 FROM objects_relation
                 WHERE from_object_id = p_price_concept_id
                   AND to_object_id = x.price_element_object_id
                   AND role_name = 'PRICE_CONCEPT'
                     AND p_daytime >= Nvl(start_date,p_daytime-1)
                       AND p_daytime < Nvl(end_date,p_daytime+1)
               )
           AND NOT EXISTS -- that are not yet there
               (SELECT 'x'
               FROM cont_price_element_value
               WHERE object_id = x.object_id
                 AND product_object_id = x.product_object_id
                 AND price_element_object_id = x.price_element_object_id
                 AND daytime = p_daytime
               );


         -- insert any new elements, that have now become valid
         INSERT INTO cont_price_element_value
         (
          OBJECT_ID	,
          PRODUCT_OBJECT_ID	,
          PRICE_ELEMENT_OBJECT_ID	,
          PRICE_CONCEPT_OBJECT_ID ,                -- JE 10.12.2002
          DAYTIME	,
          FACTOR_BASIS_LEVEL_CODE	,
          PRICE_BASIS_CODE,
          PRICE_VALUE	,
          CREATED_BY ,
          RECORD_STATUS ,
          FACTOR ,                                 -- TRA 24.02.2003
          FACTOR_BASIS                             -- TRA 24.02.2003
         )
         SELECT
          p_object_id	,
          p_product_id	,
          object_id	,
          p_price_concept_id,                       -- JE 10.12.2002
          p_daytime	,
          NULL	,
          'VALUE',
          NULL	,
          p_user,
          'P',
          NULL ,                                      -- TRA 24.02.2003
          NULL                                        -- TRA 24.02.2003
         FROM objects x -- take all price elements being part of price con
         WHERE class_name = 'PRICE_ELEMENT'
            AND p_daytime >= Nvl(start_date,p_daytime-1)
            AND p_daytime < Nvl(end_date,p_daytime+1)
           AND EXISTS
               (SELECT 'x'
                 FROM objects_relation
                 WHERE from_object_id = p_price_concept_id
                   AND to_object_id = x.object_id
                   AND role_name = 'PRICE_CONCEPT'
                     AND p_daytime >= Nvl(start_date,p_daytime-1)
                      AND p_daytime < Nvl(end_date,p_daytime+1)
                     )
            AND NOT EXISTS -- that are not yet there
               (SELECT 'x'
               FROM cont_price_element_value
               WHERE object_id = p_object_id
                 AND product_object_id = p_product_id
                 AND price_element_object_id = x.object_id -- price elements
                 AND daytime = p_daytime
               );
*/

END InsNewPriceElementSet;




--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : GetCustomerCnt
-- Description    :  Figures out whether there is a Customer related to the current contract
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
FUNCTION GetCustomerCnt(
   p_object_id VARCHAR2,
   p_daytime   DATE
)
RETURN NUMBER

IS

ln_return_val NUMBER;

BEGIN

 SELECT Count(*)
   INTO ln_return_val
   FROM contract_party_share
   WHERE object_id = p_object_id
     AND PARTY_ROLE = 'CUSTOMER'
    AND p_daytime >= Nvl(daytime,p_daytime-1)
    AND p_daytime < Nvl(end_date,p_daytime+1);

   RETURN ln_return_val;

END GetCustomerCnt;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : GetVendorCnt
-- Description    :  Figures out whether there is a Vendor related to the current contract
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
FUNCTION GetVendorCnt(
   p_object_id VARCHAR2,
   p_daytime   DATE
)
RETURN NUMBER
--</EC-DOC>
IS

ln_return_val NUMBER;


BEGIN

 SELECT Count(*)
   INTO ln_return_val
   FROM contract_party_share
   WHERE object_id = p_object_id
     AND PARTY_ROLE = 'VENDOR'
      AND p_daytime >= Nvl(daytime,p_daytime-1)
      AND p_daytime < Nvl(end_date,p_daytime+1);

   RETURN ln_return_val;

END GetVendorCnt;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetCompBankDetails
-- Description    : Retrieves company bank account details
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
FUNCTION GetCompBankDetails(
    p_object_id                     VARCHAR2,
    p_target_obj_id                 VARCHAR2, -- customer or vendor object id
    p_comp_source_obj               VARCHAR2, -- 'COMPANY' or 'VENDOR' or 'CUSTOMER'
    p_currency_id                   VARCHAR2,
    p_daytime                       DATE,
    p_contract_doc_id               VARCHAR2 DEFAULT NULL
)
RETURN t_bank_details
--</EC-DOC>
IS
    CURSOR c_bank_cd(
        cp_object_id                VARCHAR2,
        cp_daytime                  DATE,
        cp_target_id                VARCHAR2,
        cp_company_source           VARCHAR2)
    IS
        SELECT c.bank_account_id
        FROM contract_doc_company c
        WHERE c.party_role = cp_company_source
            AND c.company_id = cp_target_id
            AND c.object_id = cp_object_id
            AND cp_daytime >= Nvl(c.daytime, cp_daytime - 1)
            AND cp_daytime < Nvl(c.end_date, cp_daytime + 1);


    CURSOR c_bank_acc(
        cp_object_id                VARCHAR2,
        cp_daytime                  DATE,
        cp_target_id                VARCHAR2,
        cp_company_source           VARCHAR2)
    IS
        SELECT b.bank_account_id
        FROM contract_party_share b
        WHERE b.party_role = cp_company_source
            AND b.company_id = cp_target_id
            AND b.object_id = cp_object_id
            AND cp_daytime >= Nvl(b.daytime, cp_daytime - 1)
            AND cp_daytime < Nvl(b.end_date, cp_daytime + 1);


    CURSOR c_bank_version(
        cp_target_id                VARCHAR2,
        cp_daytime                  DATE,
        cp_company_source           VARCHAR2,
        cp_currency_id              VARCHAR2)
    IS
        SELECT bank_account.object_id AS bank_account_id
        FROM bank_account, bank_account_version
        WHERE bank_account.object_id = bank_account_version.object_id
            AND NVL(bank_account_version.currency_id, '$NULL$') = NVL(cp_currency_id, '$NULL$')
            AND cp_daytime >= Nvl(bank_account_version.daytime, cp_daytime - 1)
            AND cp_daytime < Nvl(bank_account_version.end_date, cp_daytime + 1)
            AND ((cp_company_source = 'VENDOR' AND bank_account_version.VENDOR_ID = cp_target_id)
                OR (cp_company_source = 'CUSTOMER' AND bank_account_version.CUSTOMER_ID = cp_target_id))
        ORDER BY bank_account_version.PRIORITY;


    lrec_bank_details               t_bank_details;
    lv2_bank_id                     objects.object_id%TYPE;
    lb_target_defined               BOOLEAN;
    invalid_bank_account            EXCEPTION;

BEGIN
    lb_target_defined := FALSE;
    lrec_bank_details := NULL;

    FOR BankAccDSCur IN c_bank_cd(
        p_contract_doc_id,
        p_daytime,
        p_target_obj_id,
        p_comp_source_obj)
    LOOP
        lb_target_defined := TRUE;
        lv2_bank_id := BankAccDSCur.bank_account_id;

        lrec_bank_details.bank_account_id := lv2_bank_id;
        lrec_bank_details.bank_info := ec_bank_account_version.name(lv2_bank_id,p_daytime,'<=')
            || ' ' ||NVL(''||ec_bank_version.bank_swift_code(ec_bank_account_version.BANK_ID(lv2_bank_id,p_daytime,'<='),p_daytime,'<='),'')
            || ' ' ||NVL(''||ec_bank_account_version.account_number(lv2_bank_id,p_daytime,'<='),'')
            || ' ' ||NVL(''||ec_bank_account_version.account_sort(lv2_bank_id,p_daytime,'<='),'');

        lrec_bank_details.bank_account_info := ec_bank_account_version.account_sort(lv2_bank_id,p_daytime,'<=') ||
            NVL('-' || ec_bank_account_version.account_number(lv2_bank_id,p_daytime,'<='),'');

        lrec_bank_details.bank_account_code := ec_bank_account.object_code(lv2_bank_id);
    END LOOP;

    IF lrec_bank_details.bank_account_id IS NULL
    THEN
        -- Just in case we got partial result
        lrec_bank_details := NULL;

        FOR BankAccCur IN c_bank_acc(
            p_object_id,
            p_daytime,
            p_target_obj_id,
            p_comp_source_obj)
        LOOP
            lb_target_defined := TRUE;
            lv2_bank_id := BankAccCur.bank_account_id;

            lrec_bank_details.bank_account_id := lv2_bank_id;
            lrec_bank_details.bank_info := ec_bank_account_version.name(lv2_bank_id,p_daytime,'<=')
                || ' ' ||NVL(''||ec_bank_version.bank_swift_code(ec_bank_account_version.BANK_ID(lv2_bank_id,p_daytime,'<='),p_daytime,'<='),'');

            lrec_bank_details.bank_account_info := ec_bank_account_version.account_sort(lv2_bank_id,p_daytime,'<=') ||
                NVL('-' || ec_bank_account_version.account_number(lv2_bank_id,p_daytime,'<='),'');

            lrec_bank_details.bank_account_code := ec_bank_account.object_code(lv2_bank_id);
        END LOOP;
    END IF;


    -- If the target object (customer/vendor) not defined on contract
    -- We need to look up banking information on bank account object
    IF lb_target_defined = FALSE
    THEN
        FOR bankInfo IN c_bank_version(
            p_target_obj_id,
            p_daytime,
            p_comp_source_obj,
            p_currency_id)
        LOOP
            lv2_bank_id := bankInfo.bank_account_id;
            lrec_bank_details.bank_account_id := lv2_bank_id;
            lrec_bank_details.bank_info := ec_bank_account_version.name(lv2_bank_id,p_daytime,'<=')
                || ' '
                || NVL(
                    '' || ec_bank_version.bank_swift_code(ec_bank_account_version.BANK_ID(lv2_bank_id, p_daytime,'<='), p_daytime, '<='),
                    '');

            lrec_bank_details.bank_account_info := ec_bank_account_version.account_sort(lv2_bank_id,p_daytime,'<=')
                || NVL('-' || ec_bank_account_version.account_number(lv2_bank_id, p_daytime, '<='), '');

            lrec_bank_details.bank_account_code := ec_bank_account.object_code(lv2_bank_id);
            EXIT;
        END LOOP;
    END IF;


    IF (UPPER(lrec_bank_details.bank_account_code) LIKE '%DUMMY%')
    THEN
        RAISE invalid_bank_account;
    END IF;


    RETURN lrec_bank_details;

EXCEPTION
    WHEN invalid_bank_account
    THEN
        Raise_Application_Error(
            -20000,
            'Invalid bank account '''
                || lrec_bank_details.bank_account_code
                || ''' assigned. Please correct in Company Splits panel.');

        RETURN lrec_bank_details;
END GetCompBankDetails;




FUNCTION GetPayDate(
   p_object_id VARCHAR2,
   p_document_id VARCHAR2,
   p_pt_base_code VARCHAR2,
   p_payment_terms_id VARCHAR2,
   p_daytime   DATE  -- invoice_date
)

RETURN DATE

IS

lv2_method VARCHAR2(32) := ec_payment_term_version.payment_term_method(p_payment_terms_id, p_daytime, '<=');
ln_days NUMBER := ec_payment_term_version.day_value(p_payment_terms_id, p_daytime, '<=');
lv2_calendar_object_id objects.object_id%TYPE;
ld_return_val DATE;
ld_source_date DATE := NULL;

no_calendar EXCEPTION;

CURSOR c_trans_max IS
SELECT max(transaction_date) transaction_date
FROM cont_transaction
WHERE object_id = p_object_id
AND document_key = p_document_id;

CURSOR c_trans_min IS
SELECT min(transaction_date) transaction_date
FROM cont_transaction
WHERE object_id = p_object_id
AND document_key = p_document_id;
BEGIN

 -- First use p_pt_base_code to determine ld_source_date
    IF p_pt_base_code = 'FIRST_TRANSACTION_DATE' THEN

        FOR TransFirst IN c_trans_min LOOP

            ld_source_date := TransFirst.transaction_date;

        END LOOP;

    ELSIF p_pt_base_code = 'LAST_TRANSACTION_DATE' THEN

        FOR TransLast IN c_trans_max LOOP

            ld_source_date := TransLast.transaction_date;

        END LOOP;

    ELSE -- ie INVOICE_DATE

        ld_source_date := p_daytime;

    END IF;

    -- Do not proceed if source date is null
    IF (ld_source_date IS NULL) THEN
       RETURN NULL;
    END IF;

    -- Then use ld_source_date to get the correct pay date to return
    IF lv2_method = 'FIXED_DAYS' THEN

        ld_return_val := ld_source_date + ln_days;

    ELSIF lv2_method = 'FIXED_NEXT_MTH' THEN

        IF ln_days > (Last_Day(Add_Months(Trunc(ld_source_date,'MM'),1)) - Add_Months(Trunc(ld_source_date,'MM'),1) ) THEN

            -- set to last day in month
            ld_return_val := Last_Day(Add_Months(Trunc(ld_source_date,'MM'),1));

        ELSE

            ld_return_val := Add_Months(Trunc(ld_source_date,'MM'),1) + ln_days - 1;

        END IF;

    ELSIF lv2_method = 'FIXED_CURR_MTH' THEN

        IF ln_days > ( Last_Day(ld_source_date) - Trunc(ld_source_date,'MM') ) THEN

            -- set to last day in month
            ld_return_val := Last_Day(ld_source_date);

        ELSIF p_daytime < Trunc(ld_source_date,'MM') + ln_days - 1 THEN

            -- set to new date
            ld_return_val := Trunc(ld_source_date,'MM') + ln_days - 1;

        ELSE

            ld_return_val := NULL; -- unknown, cannot set date prior to input date

        END IF;

    ELSIF lv2_method IN ('CALENDAR','CALENDAR_FORWARD','CALENDAR_BACKWARD','CALENDAR_CLOSEST_FORWARD','CALENDAR_CLOSEST_BACKWARD') THEN
        --kheng
        lv2_calendar_object_id := ec_contract_doc_version.PAYMENT_CALENDAR_COLL_ID(p_object_id, p_daytime, '<=');

        IF lv2_calendar_object_id IS NULL THEN

            RAISE no_calendar;

        END IF;

        ld_return_val := Ecdp_Calendar.GetWorkingDaysDate(lv2_calendar_object_id,ld_source_date,ln_days,lv2_method);

    ELSIF lv2_method = 'NO_DATE' THEN

        ld_return_val := NULL; -- do not return any date for this method. no date wanted / needed.

    END IF;

    RETURN ld_return_val;

EXCEPTION

    WHEN no_calendar THEN

        Raise_Application_Error(-20000,'No Calendar connected to contract '||Ec_Contract.object_code(p_object_id)||' - '||Ec_Contract_Version.name(p_object_id,Ecdp_Timestamp.getCurrentSysdate,'<='));

END GetPayDate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : GetLocalCurrencyCode
-- Description    :  Retrieves local currency code related to owner company
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
FUNCTION GetLocalCurrencyCode(
   p_object_id VARCHAR2, -- contract object id
   p_daytime   DATE
   )

RETURN VARCHAR2
--</EC-DOC>
IS

lv2_owner_id company.object_code%TYPE;
lv2_return_val company.object_code%TYPE;

BEGIN

lv2_owner_id := ec_contract_version.company_id(p_object_id,p_daytime,'<=');

lv2_return_val := ec_currency.object_code(ec_company_version.local_currency_id(lv2_owner_id,p_daytime,'<='));

  RETURN lv2_return_val;


END GetLocalCurrencyCode;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : GetTextLineTableFromText
-- Description    :
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
FUNCTION GetTextLineTableFromText(
   p_text VARCHAR2
)

RETURN t_TextLineTable
--</EC-DOC>
IS


ltab_text_line t_TextLineTable := t_TextLineTable();

ln_pos NUMBER := 1;
ln_next_pos NUMBER := 1;
lv2_col_sep VARCHAR2(2) := '::';
lv2_line_sep VARCHAR2(2) := ';;';

-- ln_line_no NUMBER := 1;
ln_col_no NUMBER := 1;
BEGIN

     ltab_text_line.Extend;

     LOOP

         -- parse for columns
         ln_next_pos := InStr(p_text,lv2_col_sep, ln_pos);

         IF ln_next_pos > 0 THEN

            -- found one
            IF ln_col_no = 1 THEN

               ltab_text_line(ltab_text_line.last).col_1_text := Substr(p_text,ln_pos,ln_next_pos-ln_pos);
               ln_col_no := ln_col_no + 1;

            ELSIF ln_col_no = 2 THEN

               ltab_text_line(ltab_text_line.last).col_2_text := Substr(p_text,ln_pos,ln_next_pos-ln_pos);
               ln_col_no := ln_col_no + 1;

            ELSE

                -- not supported, invalid format
                NULL;

            END IF;

            ln_pos := ln_next_pos + length(lv2_col_sep);

         ELSE

             -- parse for more lines
             ln_next_pos := InStr(p_text,lv2_line_sep, ln_pos);

             IF ln_next_pos > 0 THEN


                IF ln_col_no = 1 THEN

                   ltab_text_line(ltab_text_line.last).col_1_text := Substr(p_text,ln_pos,ln_next_pos-ln_pos);

                ELSIF ln_col_no = 2 THEN

                    ltab_text_line(ltab_text_line.last).col_2_text := Substr(p_text,ln_pos,ln_next_pos-ln_pos);

                ELSIF ln_col_no = 3 THEN

                    ltab_text_line(ltab_text_line.last).col_3_text := Substr(p_text,ln_pos,ln_next_pos-ln_pos);

                END IF;

                ln_pos := ln_next_pos + length(lv2_line_sep);
                ln_col_no := 1;
                ltab_text_line.Extend; -- new line

             ELSE

                 -- add rest
                IF ln_col_no = 1 THEN

                   ltab_text_line(ltab_text_line.last).col_1_text := Substr(p_text,ln_pos);

                ELSIF ln_col_no = 2 THEN

                    ltab_text_line(ltab_text_line.last).col_2_text := Substr(p_text,ln_pos);

                ELSIF ln_col_no = 3 THEN

                    ltab_text_line(ltab_text_line.last).col_3_text := Substr(p_text,ln_pos);

                END IF;

                 -- nothing more

                EXIT;

             END IF;

         END IF;

     END LOOP;

     RETURN ltab_text_line;

END GetTextLineTableFromText;

FUNCTION GetCompSplitShare(
   p_object_id VARCHAR2,
   p_comp_source_obj VARCHAR2, -- 'CUSTOMER' or 'VENDOR'
   p_target_obj_id VARCHAR2, -- customer or vendor object id
   p_daytime   DATE
) RETURN NUMBER

IS

lv2_split_key_ID objects.object_id%TYPE;
BEGIN

  IF p_target_obj_id IS NULL THEN

      -- if no valid object, then return unknown
      RETURN NULL;

   ELSE

     --lv2_split_key_ID := EcDp_Objects.GetObjIDToRel(p_object_id, p_comp_source_obj || '_SPLIT_KEY', p_daytime );
     --lv2_split_key_ID := Ec_Split_Key.row_by_object_id(p_object_id);

     RETURN EcDp_Split_Key.GetSplitShareMth(lv2_split_key_ID,p_target_obj_id,p_daytime);

   END IF;
END GetCompSplitShare;




--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : GetDateForPostingAccount
--
-- Description     : Gets the date to be used for picking up Account Mapping, Finiancial Account,
--                   Cost Object Mapping and Cost Object objects used for posting generation for
--                   a line item.
--
-- Parameters      : p_transaction_key - The transaction ley of the line item
--                   p_daytime         - The default daytime used for picking up objects used in
--                                       posting. Currently it is document date, but the logic
--                                       may be subject to future change.
--
-- Returns         : The date for picking up account related objects (see description).
--
-- Behaviour       : Checks system attribute ACCOUNT_LG_DATE_METHOD, if it is 'DOC_DATE', then
--                   the parameter value of p_daytime is used; otherwise transaction date of the
--                   given line item is used.
--
---------------------------------------------------------------------------------------------------
FUNCTION GetDateForPostingAccount(p_transaction_key VARCHAR2, p_daytime DATE)
RETURN DATE
--</EC-DOC>
IS
    lv2_date_method VARCHAR2(32);
    ld_date DATE;

BEGIN
    lv2_date_method := ec_ctrl_system_attribute.attribute_text(p_daytime,
                                                               'ACNT_LOGIC_DATE_METHOD',
                                                               '<=');
    IF lv2_date_method = 'DOC_DATE' THEN
        ld_date := p_daytime;

    ELSIF lv2_date_method = 'TRANS_DATE' OR lv2_date_method IS NULL THEN
        -- Get transaction date by default
        ld_date := ec_cont_transaction.transaction_date(p_transaction_key);

    ELSE
        RAISE_APPLICATION_ERROR(-20000, 'System Attribute ''ACNT_LOGIC_DATE_METHOD'' value '''
                     || lv2_date_method ||''' is not supported.');

    END IF;

    RETURN ld_date;

END GetDateForPostingAccount;


---------------------------------------------------------------------------------------------------
-- Procedure       : GetFinAccSearchCriteria
--
-- Description     : Gets Account Mapping search criteria parameters (used by the Account Mapping screen) like Status,Financial Code,
--                   Account Class,Line Item Type,Company Code,Vendor Code,Etc....
--                   which is to be used for picking up Account Mapping, Finiancial Account,
--                   Cost Object Mapping and Cost Object objects used for posting generation for
--                   a line item.
--
-- Parameters    : p_object_id                  - OBJECT_ID of Contract class
--                 p_daytime                    - The default daytime used for picking up objects used in posting.
--                 p_trans_template_id          - OBJECT_ID of Transaction Template
--                 p_price_object_id            - OBJECT_ID of Price Object
--                 p_product_id                 - OBJECT_ID of Product
--                 p_line_item_template_id      - OBJECT_ID of Line Item Template
--                 p_line_item_type             - OBJECT_CODE of Line Item Type
--
-- Returns        : Posting Ind
--                  Status
--                  Financial Code
--                  Account Class
--                  Line Item Type
--                  Company Code
--                  Vendor Code
--                  Company Category
--                  Product code
--                  Accout Category
--                  Value Type
--                  Company Scope
--                  Vendor Scope
--                  Reciever Scope
--
-- Behavior       :
-- Created By     : Brandon lewis, Maulik Vadodariya
---------------------------------------------------------------------------------------------------

FUNCTION GetFinAccSearchCriteria( -- Get the Account Search criteria result
                                 p_object_id             VARCHAR2, -- contract id
                                 p_daytime               DATE,
                                 p_trans_template_id     VARCHAR2,
                                 p_price_object_id       VARCHAR2 default null,
                                 p_product_id            VARCHAR2 default null,
                                 p_line_item_template_id VARCHAR2 default null,
                                 p_line_item_type        VARCHAR2 default null)
  RETURN T_TABLE_ACC_MAP_ASSIS IS

  CURSOR c_current_company(cp_object_id    VARCHAR2,cp_company_type VARCHAR2,cp_Daytime      DATE) is
    SELECT *
      FROM CONTRACT_PARTY_SHARE X
     WHERE PARTY_ROLE = cp_company_type
       AND object_id = cp_object_id
       AND daytime <= cp_daytime
       AND nvl(end_date, cp_daytime + 1) > cp_daytime;

  CURSOR c_current_vendor(cp_object_id    VARCHAR2,cp_company_type VARCHAR2,cp_Daytime      DATE) is
    SELECT *
      FROM CONTRACT_PARTY_SHARE X
     WHERE PARTY_ROLE = cp_company_type
       AND object_id = cp_object_id
       AND daytime <= cp_daytime
       AND nvl(end_date, cp_daytime + 1) > cp_daytime;

  CURSOR c_current_customer(cp_object_id    VARCHAR2,cp_company_type VARCHAR2,cp_Daytime      DATE) is
    SELECT *
      FROM CONTRACT_PARTY_SHARE X
     WHERE PARTY_ROLE = cp_company_type
       AND object_id = cp_object_id
       AND daytime <= cp_daytime
       AND nvl(end_date, cp_daytime + 1) > cp_daytime;

  CURSOR c_posting_setup(cp_financial_code VARCHAR2,cp_status_code    VARCHAR2) IS
    SELECT *
      FROM fin_posting_setup
     WHERE financial_code = cp_financial_code
       AND decode(status_code, 'ALL', cp_status_code, status_code) = cp_status_code;

  CURSOR c_current_product(cp_product_id      VARCHAR2,cp_price_object_id VARCHAR2,cp_Contract_id     varchar2,cp_daytime         date) is
    SELECT X.OBJECT_ID as product_id, Y.OBJECT_CODE as PRODUCT_CODE
      FROM PRODUCT_VERSION X, PRODUCT Y
     WHERE cp_product_id = X.object_id
       AND daytime <= cp_daytime
       AND nvl(X.end_date, cp_daytime + 1) > cp_daytime
       AND X.OBJECT_ID = Y.OBJECT_ID
    union
    SELECT DISTINCT product_id,ec_product.OBJECT_CODE(product_id) as PRODUCT_CODE
    FROM PRODUCT_PRICE X
    WHERE cp_product_id is null
     AND nvl(cp_price_object_id, object_id) = object_id
     AND contract_id = cp_contract_id
     AND start_date <= cp_daytime
     AND nvl(end_date, start_date + 1) > cp_daytime;

  CURSOR c_current_line_item(cp_line_item_type     VARCHAR2,cp_line_item_template VARCHAR2,cp_template_id        VARCHAR2,cp_daytime            date) is
    SELECT code as line_item_type
      FROM prosty_codes
     WHERE CODE = cp_line_item_type
       AND code_type = 'LINE_ITEM_TYPE'
       AND IS_ACTIVE = 'Y'
    union
    SELECT litv.line_item_type
      FROM line_item_template lit,
      line_item_tmpl_version litv
     WHERE decode(cp_line_item_type, '', NULL, cp_line_item_type) is null
       AND cp_template_id = lit.object_id --This Condition is not allowing to list search criteria at the first time
       AND lit.object_id = decode(cp_line_item_template,'',lit.object_id,cp_line_item_template)
       AND lit.object_id = litv.object_id
       AND litv.daytime <= cp_daytime
       AND nvl(litv.end_date, cp_daytime + 1) > cp_daytime
    union
    SELECT litv.line_item_type
      FROM transaction_tmpl_version ttv,
           line_item_template       lit,
           line_item_tmpl_version   litv
     WHERE decode(cp_line_item_type, '', NULL, cp_line_item_type) is null
       AND decode(cp_line_item_template, '', NULL, cp_line_item_template) IS NULL
       AND cp_template_id = ttv.object_id
       AND lit.transaction_template_id = ttv.objecT_id
       AND lit.object_id = litv.object_id
       AND ttv.daytime <= cp_daytime
       AND nvl(ttv.end_date, cp_daytime + 1) > cp_daytime
       AND litv.daytime <= cp_daytime
       AND nvl(litv.end_date, cp_daytime + 1) > cp_daytime;

  CURSOR c_current_status is
    SELECT 'FINAL' status FROM DUAL
    UNION SELECT 'ACCRUAL' FROM DUAL;

  lv2_financial_code          VARCHAR2(32);
  lv2_product_code            VARCHAR2(32);
  lv2_cust_vend_category_code VARCHAR2(32);
  lv2_debit_credit            VARCHAR2(32);
  lv2_company_code            VARCHAR(32);
  lv2_company_id              VARCHAR(32);
  lv2_vendor_id               VARCHAR2(32);
  lv2_vendor_code             VARCHAR2(32);
  lv2_actual_vendor_id        VARCHAR2(32);
  lv2_actual_customer_id      VARCHAR2(32);
  lv2_fin_company_id          VARCHAR2(32);
  lv2_post_ind                VARCHAR2(1);
  lv2_receiver_id             VARCHAR2(32);
  lv2_company_type            VARCHAR2(32);
  lv2_company_obj_id          VARCHAR2(32);

  lv2_financial_code_desc     VARCHAR2(240);
  lv2_debit_credit_desc       VARCHAR2(240);
  lv2_line_item_type_desc     VARCHAR2(240);
  lv2_company_code_desc       VARCHAR2(240);
  lv2_vendor_code_desc        VARCHAR2(240);
  lv2_product_code_desc       VARCHAR2(240);
  lv2_fin_acc_category_desc   VARCHAR2(240);
  lv2_value_type_desc         VARCHAR2(240);
  lv2_company_scope_desc      VARCHAR2(240);
  lv2_vendor_scope_desc       VARCHAR2(240);
  lv2_receiver_scope_desc     VARCHAR2(240);
  lv2_status_desc             VARCHAR2(240);
  lv2_cust_vend_cat_code_desc VARCHAR2(240);

  lv2_receiver_company_id VARCHAR2(32);

  -- the daytime to be used for getting object versions
  ld_line_item_account_daytime DATE;

  --Table Type variable for returning Account Mapping Search Criteria
  v_T_TABLE_ACC_MAP_ASSIS T_TABLE_ACC_MAP_ASSIS;
  l_index                 number := 0;

BEGIN

  v_T_TABLE_ACC_MAP_ASSIS := T_TABLE_ACC_MAP_ASSIS();

  lv2_financial_code      := ec_contract_version.financial_code(p_object_id,p_daytime,'<=');
  lv2_financial_code_desc := ec_prosty_codes.code_text(lv2_financial_code,'FINANCIAL_CODE_BASIC');
  lv2_company_obj_id      := ec_contract_version.company_id(p_object_id,p_daytime,'<=');

  IF lv2_financial_code in ('SALE', 'TA_INCOME', 'JOU_ENT') THEN
    lv2_company_type := 'VENDOR';
  ELSE
    lv2_company_type := 'CUSTOMER';
  END IF;

  FOR status in c_current_status LOOP

    FOR comp in c_current_company(p_object_id, lv2_company_type, p_daytime) LOOP

      -- Get the daytime to be used for getting correct object versions
      ld_line_item_account_daytime := p_daytime;

      SELECT MAX(GROUP_CODE) into lv2_cust_vend_category_code
      FROM COMPANY_VERSION
      WHERE OBJECT_ID = comp.company_id;
      FOR vend in c_current_vendor(p_object_id, 'VENDOR', p_daytime) LOOP
        -- determine vendor customer
        lv2_actual_vendor_id := comp.company_id;
        FOR cust in c_current_customer(p_object_id, 'CUSTOMER', p_daytime) LOOP
          lv2_actual_customer_id := cust.company_id;

          IF lv2_company_type = 'VENDOR' THEN
            lv2_fin_company_id   := cust.company_id;
            lv2_vendor_id        := comp.company_id;
            lv2_vendor_code      := ec_company.object_code(lv2_vendor_id);
            lv2_vendor_code_desc := ec_company_version.name(lv2_vendor_id,p_daytime,'<=');
          ELSE
            lv2_vendor_id        := cust.company_id;
            lv2_vendor_code      := ec_company.object_code(lv2_vendor_id);
            lv2_fin_company_id   := comp.company_id;
            lv2_vendor_code_desc := ec_company_version.name(lv2_vendor_id,p_daytime,'<=');
          END IF;

        END LOOP;

        FOR PSCur IN c_posting_setup(lv2_financial_code, status.status) LOOP

          IF -- If vendor Scope is only owner see that the vendor is the the company on the contract
           (PSCur.vendor_scope = 'OWNER' and ec_company.company_id(lv2_actual_vendor_id) =lv2_company_obj_id)

           OR PSCur.vendor_scope = 'ALL'
          -- If vendor Scope is not owner see that the vendor is not the the company on the contract
           OR (PSCur.Vendor_Scope = 'NOT_OWNER' and ec_company.company_id(lv2_actual_vendor_id) <>lv2_company_obj_id)
          -- If vendor Scope is system company look up the flag on the company object to see if system is sat
           OR (PSCur.Vendor_Scope = 'SYSTEM_COMPANY' AND ec_company_version.system_company_ind(ec_company.company_id(lv2_actual_vendor_id),ld_line_item_account_daytime,'<=') = 'Y') THEN

            lv2_debit_credit      := PSCur.CREDIT_DEBIT;
            lv2_debit_credit_desc := ec_prosty_codes.code_text(lv2_debit_credit,'ACCOUNT_CLASS_CODE');

            -- Fin the company that the account mapping will use for accounts and cost objects
            IF PSCur.company_scope = 'OWNER' THEN
              lv2_company_id := lv2_company_obj_id;
            ELSIF PSCur.company_scope = 'VENDOR' THEN
              lv2_company_id := ec_company.company_id(lv2_actual_vendor_id);
            ELSIF PSCur.company_scope = 'CUSTOMER' THEN
              lv2_company_id := ec_company.company_id(lv2_actual_customer_id);
            END IF;

            lv2_company_code      := ec_company.object_code(lv2_company_id);
            lv2_company_code_desc := ec_company_version.name(lv2_company_id,p_daytime,'<=');

            -- Get the company that will be recieving the money.
            -- Will check that it is actually the one getting it and if not there will be no posting
            IF nvl(PSCur.receiver_scope, PSCur.company_scope) = 'OWNER' THEN
              lv2_receiver_company_id := lv2_company_obj_id;
            ELSIF nvl(PSCur.receiver_scope, PSCur.company_scope) = 'VENDOR' THEN
              lv2_receiver_company_id := ec_company.company_id(lv2_actual_vendor_id);
            ELSIF nvl(PSCur.receiver_scope, PSCur.company_scope) ='CUSTOMER' THEN
              lv2_receiver_company_id := ec_company.company_id(lv2_actual_customer_id);
            END IF;

            IF PSCur.fin_value_type = 'EX_VAT' THEN
              lv2_receiver_id := vend.exvat_receiver_id;
            ELSE
              lv2_receiver_id := vend.vat_receiver_id;
            END IF;

            IF ec_company.company_id(lv2_receiver_id) = lv2_receiver_company_id
			    AND nvl(ec_contract_party_share.excl_erp_posting_ind(p_Object_Id,lv2_vendor_id,'VENDOR',P_Daytime,'<='),'N') <> 'Y' THEN
                  lv2_post_ind := 'Y';
            ELSE
              lv2_post_ind := 'N';
            END IF;
            IF lv2_company_type = 'CUSTOMER' THEN
              IF ec_company.company_id(lv2_vendor_id) = lv2_company_obj_id THEN
                lv2_post_ind := 'Y';
              END IF;
            END IF;

            FOR li in c_current_line_item(p_line_item_type,p_line_item_template_id,p_trans_template_id,p_daytime) LOOP
              FOR prod in c_current_product(p_product_id,p_price_object_id,p_object_id,p_daytime) LOOP

                lv2_product_code            := ec_product.object_code(prod.product_id);
                lv2_product_code_desc       := ec_product_version.name(prod.product_id,p_daytime,'<=');
                lv2_line_item_type_desc     := ec_prosty_codes.code_text(li.line_item_type,'LINE_ITEM_TYPE');
                lv2_fin_acc_category_desc   := ec_prosty_codes.code_text(PSCur.Fin_Account_Category,'FIN_ACCOUNT_CATEGORY_CODE');
                lv2_value_type_desc         := ec_prosty_codes.code_text(PSCur.fin_value_type,'FIN_VALUE_TYPE');
                lv2_company_scope_desc      := ec_prosty_codes.code_text(PSCur.company_scope,'FIN_COMPANY_SCOPE');
                lv2_vendor_scope_desc       := ec_prosty_codes.code_text(PSCur.vendor_scope,'FIN_VENDOR_SCOPE');
                lv2_receiver_scope_desc     := ec_prosty_codes.code_text(PSCur.receiver_scope,'FIN_RECEIVER_SCOPE');
                lv2_status_desc             := ec_prosty_codes.code_text(status.status,'ACCOUNT_STATUS_CODE');
                lv2_cust_vend_cat_code_desc := ec_prosty_codes.code_text(lv2_cust_vend_category_code,'VENDOR_GROUP_CODE');

                v_T_TABLE_ACC_MAP_ASSIS.extend;
                l_index := v_T_TABLE_ACC_MAP_ASSIS.count;

                v_T_TABLE_ACC_MAP_ASSIS(l_index) := T_ACC_MAP_ASSIS(
		                                                    lv2_post_ind,
                                                                    status.status, --Status
                                                                    lv2_status_desc,
                                                                    lv2_financial_code, --Financial Code
                                                                    lv2_financial_code_desc,
                                                                    lv2_debit_credit, -- Account Class
                                                                    lv2_debit_credit_desc,
                                                                    li.line_item_type, -- Line Item Type
                                                                    lv2_line_item_type_desc,
                                                                    lv2_company_code,
                                                                    lv2_company_code_desc,
                                                                    lv2_vendor_code,
                                                                    lv2_vendor_code_desc,
                                                                    lv2_cust_vend_category_code,
                                                                    lv2_cust_vend_cat_code_desc,
                                                                    lv2_product_code, --prod.PRODUCT_CODE
                                                                    lv2_product_code_desc,
                                                                    PSCur.Fin_Account_Category,
                                                                    lv2_fin_acc_category_desc,
                                                                    PSCur.fin_value_type,
                                                                    lv2_value_type_desc,
                                                                    PSCur.company_scope,
                                                                    lv2_company_scope_desc,
                                                                    PSCur.vendor_scope,
                                                                    lv2_vendor_scope_desc,
                                                                    PSCur.receiver_scope,
                                                                    lv2_receiver_scope_desc);

              END LOOP;
            END LOOP;

          END IF;

        END LOOP; --  Posting Loop
      END LOOP; -- Vendor Loop
    END LOOP; -- Company Loop
  END LOOP; -- Status loop

  Return v_T_TABLE_ACC_MAP_ASSIS;

END GetFinAccSearchCriteria;

PROCEDURE GenFinPostingData( -- set the financial posting data
   p_object_id VARCHAR2,
   p_document_id VARCHAR2,
   p_fin_code VARCHAR2,
   p_status VARCHAR2,
   p_doc_total NUMBER,
   p_company_obj_id VARCHAR2,
   p_daytime   DATE,
   p_user      VARCHAR2
)

IS

CURSOR c_li_di_company(cp_contract_id VARCHAR2, cp_document_id VARCHAR2) IS
SELECT *
  FROM cont_li_dist_company
 WHERE object_id = cp_contract_id
   AND document_key = cp_document_id;

CURSOR c_posting_setup(cp_financial_code VARCHAR2, cp_status_code VARCHAR2) IS
SELECT *
  FROM fin_posting_setup
 WHERE financial_code = cp_financial_code
   AND decode(status_code,'ALL',cp_status_code, status_code) = cp_status_code;


no_account EXCEPTION;
no_cost_object EXCEPTION;

lv2_err_text VARCHAR2(2000);

lv2_financial_code VARCHAR2(32);
lv2_product_code VARCHAR2(32);
lv2_product_obj_id VARCHAR2(32);
lv2_cust_vend_category_code VARCHAR2(32);
lv2_debit_credit VARCHAR2(32);
lv2_company_code VARCHAR(32);
lv2_company_id VARCHAR(32);
lv2_vendor_id VARCHAR2(32);
lv2_fin_company_id VARCHAR2(32);
lv2_post_ind VARCHAR2(1);
lv2_receiver_id VARCHAR2(32);

lv2_accnt_id objects.object_id%TYPE;
lv2_cost_obj_id objects.object_id%TYPE;
lv2_fin_cost_object VARCHAR(240);

lv2_co_type VARCHAR2(1);
lrec_cont_postings CONT_POSTINGS%ROWTYPE;

lv2_receiver_company_id VARCHAR2(32);

-- the daytime to be used for getting object versions
ld_line_item_account_daytime DATE;

BEGIN
	   -- Call the INSTEAD-OF User Exit
     IF ue_fin_account.isGenFinPostingDataUEE = 'TRUE' then
        ue_fin_account.GenFinPostingData(p_object_id,
                                         p_document_id,
                                         p_fin_code,
                                         p_status,
                                         p_doc_total,
                                         p_company_obj_id,
                                         p_daytime,
                                         p_user);
     ELSE
       IF ue_fin_account.isGenFinPostingDataPreUEE = 'TRUE' then
           ue_fin_account.GenFinPostingDataPre(p_object_id,
                                         p_document_id,
                                         p_fin_code,
                                         p_status,
                                         p_doc_total,
                                         p_company_obj_id,
                                         p_daytime,
                                         p_user);
       END IF;

     FOR CLDCCur IN c_li_di_company(p_object_id, p_document_id) LOOP

         -- Get the daytime to be used for getting correct object versions
         ld_line_item_account_daytime := GetDateForPostingAccount(CLDCCur.Transaction_Key,
                                                                  p_daytime);

         lv2_financial_code := ec_contract_version.financial_code(p_object_id, ld_line_item_account_daytime, '<=');

         lv2_product_code := ec_product.object_code(ec_cont_transaction.product_id(CLDCCur.transaction_key));
         lv2_product_obj_id := ec_cont_transaction.product_id(CLDCCur.transaction_key);
         IF lv2_financial_code in ('SALE','TA_INCOME','JOU_ENT') THEN
              lv2_cust_vend_category_code := ec_cont_document_company.company_category_code(p_document_id, CLDCCur.Customer_Id);
              IF lv2_cust_vend_category_code IS NULL THEN
                SELECT MAX(COMPANY_ID) into lv2_cust_vend_category_code
                  FROM CONT_DOCUMENT_COMPANY
                 WHERE COMPANY_ROLE = 'CUSTOMER'
                   AND DOCUMENT_KEY = p_document_id;
              END IF;

         ELSE
              lv2_cust_vend_category_code := ec_cont_document_company.company_category_code(p_document_id, CLDCCur.Vendor_Id);
         END IF;

         FOR PSCur IN c_posting_setup(lv2_financial_code, p_status) LOOP

             -- Some postings only apply to contract owner
             IF (PSCur.vendor_scope = 'OWNER' and ec_company.company_id(CLDCCur.vendor_id) = p_company_obj_id)
                OR PSCur.vendor_scope = 'ALL'
                  OR (PSCur.Vendor_Scope = 'NOT_OWNER' and ec_company.company_id(CLDCCur.vendor_id) <> p_company_obj_id)
                  OR (PSCur.Vendor_Scope = 'SYSTEM_COMPANY' AND ec_company_version.system_company_ind(ec_company.company_id(CLDCCur.vendor_id),ld_line_item_account_daytime,'<=') = 'Y' ) THEN

               -- reset to clear out values from previous iteration
               lv2_accnt_id := NULL;
               lv2_co_type := NULL;
               lv2_cost_obj_id := NULL;
               lv2_debit_credit := PSCur.CREDIT_DEBIT;

               -- determine which company to use when lookup up acc mappings and cost objects
               IF PSCur.company_scope = 'OWNER' THEN
                  lv2_company_id := p_company_obj_id;
               ELSIF PSCur.company_scope = 'VENDOR' THEN
                  lv2_company_id := ec_company.company_id(CLDCCur.vendor_id);
               ELSIF PSCur.company_scope = 'CUSTOMER' THEN
                  lv2_company_id := ec_company.company_id(CLDCCur.customer_id);
               END IF;

               lv2_company_code := ec_company.object_code(lv2_company_id);

                 IF nvl(PSCur.receiver_scope,PSCur.company_scope) = 'OWNER' THEN
                    lv2_receiver_company_id := p_company_obj_id;
                 ELSIF nvl(PSCur.receiver_scope,PSCur.company_scope) = 'VENDOR' THEN
                    lv2_receiver_company_id := ec_company.company_id(CLDCCur.vendor_id);
                 ELSIF nvl(PSCur.receiver_scope,PSCur.company_scope) = 'CUSTOMER' THEN
                    lv2_receiver_company_id := ec_company.company_id(CLDCCur.customer_id);
                 END IF;


               -- determine companies to use for ERP-accnts
               -- set vendor_id
               IF p_fin_code = 'SALE' or p_fin_code = 'TA_INCOME' or p_fin_code = 'JOU_ENT' THEN
                  lv2_fin_company_id := CLDCCur.customer_id;
                  lv2_vendor_id := CLDCCur.vendor_id;
               ELSE
                  lv2_fin_company_id := CLDCCur.vendor_id;
                  lv2_vendor_id := CLDCCur.customer_id;
               END IF;

               IF PSCur.fin_value_type = 'EX_VAT' THEN

                   -- Even if Purchase/TA Cost Receiver should still be vendor
                   IF p_fin_code = 'PURCHASE' or p_fin_code = 'TA_COST' THEN
                     lv2_receiver_id := ec_cont_document_company.exvat_receiver_id(p_document_id,CLDCCur.vendor_id);
                   ELSE
                  lv2_receiver_id := ec_cont_document_company.exvat_receiver_id(p_document_id, lv2_vendor_id);
                   END IF;

                  lrec_cont_postings.receiver_id := lv2_receiver_id;
                  lrec_cont_postings.payment_scheme_id := ec_cont_document_company.payment_scheme_id(p_document_id, lv2_receiver_id);
                    IF ec_company.company_id(ec_cont_document_company.exvat_receiver_id(p_document_id, lv2_vendor_id)) =  lv2_receiver_company_id
                      AND nvl(ec_contract_party_share.excl_erp_posting_ind(CLDCCur.Object_Id, lv2_vendor_id, 'VENDOR',CLDCCur.Daytime,'<='),'N') <> 'Y' THEN
                     lv2_post_ind := 'Y';
                  ELSE
                     lv2_post_ind := 'N';
                  END IF;

                  IF p_fin_code = 'PURCHASE' or p_fin_code = 'TA_COST' THEN

                     IF ec_company.company_id(lv2_vendor_id) = p_company_obj_id THEN
                            --lrec_cont_postings.receiver_id := lv2_vendor_id;
                          lv2_post_ind := 'Y';
                     END IF;

                  END IF;
               ELSE
                   -- Even if Purchase/TA Cost Receiver should still be vendor
                   IF p_fin_code = 'PURCHASE' or p_fin_code = 'TA_COST' THEN
                     lv2_receiver_id := ec_cont_document_company.vat_receiver_id(p_document_id,CLDCCur.vendor_id);
                   ELSE
                  lv2_receiver_id := ec_cont_document_company.vat_receiver_id(p_document_id, lv2_vendor_id);
                   END IF;
                  lrec_cont_postings.receiver_id := lv2_receiver_id;
                  lrec_cont_postings.payment_scheme_id := ec_cont_document_company.payment_scheme_id(p_document_id, lv2_receiver_id);
                    IF ec_company.company_id(ec_cont_document_company.vat_receiver_id(p_document_id, lv2_vendor_id)) =  lv2_receiver_company_id
                      AND nvl(ec_contract_party_share.excl_erp_posting_ind(CLDCCur.Object_Id, lv2_vendor_id, 'VENDOR',CLDCCur.Daytime,'<='),'N') <> 'Y' THEN
                     lv2_post_ind := 'Y';
                  ELSE
                     lv2_post_ind := 'N';
                  END IF;

                  IF p_fin_code = 'PURCHASE' or p_fin_code = 'TA_COST' THEN

                     IF ec_company.company_id(lv2_vendor_id) = p_company_obj_id THEN
                            --lrec_cont_postings.receiver_id := lv2_vendor_id;
                          lv2_post_ind := 'Y';
                     END IF;

                  END IF;

               END IF;

               lrec_cont_postings.payment := PSCur.Payment;
               lrec_cont_postings.item := PSCur.item;
               lrec_cont_postings.counter_item := PSCur.Counter_Item;
               lrec_cont_postings.master_item := PSCur.Master_Item;

               IF lv2_post_ind = 'Y' THEN
                   lv2_accnt_id := EcDp_Fin_Account.GetAccntMappingObjID(lv2_financial_code,lv2_cust_vend_category_code, p_status, CLDCCur.line_item_type, lv2_debit_credit, PSCur.Fin_Account_Category,
                                                                         lv2_product_code, lv2_company_code, CLDCCur.Customer_Id, CLDCCur.Vendor_Id, ld_line_item_account_daytime, ec_stream_item_version.field_id(CLDCCur.Stream_Item_Id,ld_line_item_account_daytime,'<='), CLDCCur.Line_Item_Key, NULL);
                   -- check for NULL
                   IF lv2_accnt_id IS NULL  THEN

                      lv2_err_text := 'document ' || CLDCCur.document_key || ' transaction ' || CLDCCur.transaction_key || ' using the following parameters: FINANCIAL_CODE => ' || lv2_financial_code || ', STATUS_CODE => ' || p_status || ', LINE_ITEM_TYPE => ' || CLDCCur.line_item_type || ', ACCOUNT_CATEGORY =>  ' || PSCur.fin_account_category;

                      RAISE no_account;

                   END IF;


                   lv2_co_type := ec_fin_account_version.fin_cost_object_type(ec_fin_acc_mapping_version.fin_account_id(lv2_accnt_id, ld_line_item_account_daytime,'<='), ld_line_item_account_daytime, '<=');


                   -- Reset
                   lv2_fin_cost_object := NULL;

                   IF Nvl(lv2_co_type,'X') <> 'N' THEN
                       --find account cost object
                       lv2_fin_cost_object := ec_fin_account_version.acct_cost_object(ec_fin_acc_mapping_version.fin_account_id(lv2_accnt_id, ld_line_item_account_daytime,'<='), ld_line_item_account_daytime, '<=');

                       --if no account cost object found
                       IF lv2_fin_cost_object is NULL THEN
                       -- determine cost object (if any), find the cost object in the fin_cost_object class the 'old' way
                       lv2_cost_obj_id := EcDp_Fin_Cost_Object.GetCostObjID(
                                              lv2_co_type,
                                              lv2_company_id,
                                              CLDCCur.dist_id,
                                              CLDCCur.node_id,
                                              CLDCCur.line_item_type,
                                              lv2_product_obj_id,
                                              ld_line_item_account_daytime,
                                              CLDCCur.Line_Item_Key
                                              );

        --   OHA Don't know all details for partners
                            IF lv2_cost_obj_id IS NULL THEN

                              lv2_err_text := lv2_debit_credit || ' document ' || p_document_id || ' transaction ' || CLDCCur.transaction_key || ' using the following parameters: ' ||
                                   ' COMP_CLASS ' || ecdp_objects.GetObjClassName(lv2_company_id) ||
                                   ', COMPANY => ' || Nvl( ec_company_version.name(lv2_company_id, ld_line_item_account_daytime, '<='), ec_company.object_code(lv2_company_id)) ||
                                  ', DIST => ' || Nvl( ec_field_version.name(CLDCCur.dist_id, ld_line_item_account_daytime, '<='), ec_field.object_code(CLDCCur.dist_id) ) ||
                                    ', NODE => ' || Nvl( ec_node_version.name(CLDCCur.node_id, ld_line_item_account_daytime, '<='), ec_node.object_code(CLDCCur.node_id));

                              RAISE no_cost_object;

                           ELSE
                              --find the cost object itself from the object ID:
                              lv2_fin_cost_object := ecdp_fin_cost_object.getcostobject(lv2_cost_obj_id, ld_line_item_account_daytime);


                           END IF;

                       END IF;

                   END IF;


                   lrec_cont_postings.fin_debit_posting_key := ec_fin_acc_mapping_version.fin_debit_posting_key(lv2_accnt_id,ld_line_item_account_daytime,'<=');
                   lrec_cont_postings.fin_credit_posting_key := ec_fin_acc_mapping_version.fin_credit_posting_key(lv2_accnt_id,ld_line_item_account_daytime,'<=');
                   lrec_cont_postings.fin_account_id := ec_fin_acc_mapping_version.fin_account_id(lv2_accnt_id, ld_line_item_account_daytime, '<=');
                   lrec_cont_postings.fin_gl_account := EcDp_Fin_Account.GetAccntNo(lv2_accnt_id, lv2_fin_company_id, ld_line_item_account_daytime);
                   lrec_cont_postings.fin_cost_obj_type := lv2_co_type;
                   lrec_cont_postings.fin_cost_object := lv2_fin_cost_object;
                   lrec_cont_postings.fin_external_ref := ecdp_fin_cost_object.getexternalref(lv2_cost_obj_id,ld_line_item_account_daytime);
                   lrec_cont_postings.product_id := lv2_product_obj_id;

               ELSE
                   lrec_cont_postings.fin_debit_posting_key   := NULL;
                   lrec_cont_postings.fin_credit_posting_key   := NULL;
                   lrec_cont_postings.fin_account_id    := NULL;
                   lrec_cont_postings.fin_gl_account    := NULL;
                   lrec_cont_postings.fin_cost_obj_type := NULL;
                   lrec_cont_postings.fin_cost_object   := NULL;
                   lrec_cont_postings.fin_external_ref  := NULL;
                   lrec_cont_postings.product_id        := NULL;
               END IF;


               lrec_cont_postings.object_id := p_object_id;
               lrec_cont_postings.document_key := p_document_id;
               lrec_cont_postings.line_item_key := CLDCCur.Line_Item_Key;
               lrec_cont_postings.stream_item_id := CLDCCur.Stream_Item_Id;
               lrec_cont_postings.dist_id := CLDCCur.Dist_Id;
               lrec_cont_postings.vendor_id := CLDCCur.Vendor_Id;
               lrec_cont_postings.customer_id := CLDCCur.customer_id;
               Ecdp_System_Key.assignNextNumber('CONT_POSTINGS',lrec_cont_postings.posting_no);
               lrec_cont_postings.daytime := CLDCCur.Daytime;
               lrec_cont_postings.debit_credit_ind := substr(lv2_debit_credit,1,1);

               IF CLDCCur.booking_value >= 0 THEN
                  IF lv2_debit_credit = 'DEBIT' THEN
                     IF PSCur.fin_value_type = 'EX_VAT' THEN
                        lrec_cont_postings.debit_amount := CLDCCur.Booking_Value;
                        lrec_cont_postings.local_debit_amount := CLDCCur.Local_Value;
                        lrec_cont_postings.group_debit_amount := CLDCCur.Group_Value;
                     ELSE
                        lrec_cont_postings.debit_amount := CLDCCur.Booking_Vat_Value;
                        lrec_cont_postings.local_debit_amount := CLDCCur.Local_Vat_Value;
                        lrec_cont_postings.group_debit_amount := CLDCCur.Group_Vat_Value;
                     END IF;
                     lrec_cont_postings.credit_amount := 0;
                     lrec_cont_postings.local_credit_amount := 0;
                     lrec_cont_postings.group_credit_amount := 0;
                  ELSE
                     IF PSCur.fin_value_type = 'EX_VAT' THEN
                        lrec_cont_postings.credit_amount := CLDCCur.Booking_Value;
                        lrec_cont_postings.local_credit_amount := CLDCCur.Local_Value;
                        lrec_cont_postings.group_credit_amount := CLDCCur.Group_Value;
                     ELSE
                        lrec_cont_postings.credit_amount := CLDCCur.Booking_Vat_Value;
                        lrec_cont_postings.local_credit_amount := CLDCCur.Local_Vat_Value;
                        lrec_cont_postings.group_credit_amount := CLDCCur.Group_Vat_Value;
                     END IF;
                     lrec_cont_postings.debit_amount := 0;
                     lrec_cont_postings.local_debit_amount := 0;
                     lrec_cont_postings.group_debit_amount := 0;
                  END IF;
               ELSE
                  IF lv2_debit_credit = 'DEBIT' THEN
                     IF PSCur.fin_value_type = 'EX_VAT' THEN
                        lrec_cont_postings.credit_amount := abs(CLDCCur.Booking_Value);
                        lrec_cont_postings.local_credit_amount := abs(CLDCCur.Local_Value);
                        lrec_cont_postings.group_credit_amount := abs(CLDCCur.Group_Value);
                     ELSE
                        lrec_cont_postings.credit_amount := abs(CLDCCur.Booking_Vat_Value);
                        lrec_cont_postings.local_credit_amount := abs(CLDCCur.local_Vat_Value);
                        lrec_cont_postings.group_credit_amount := abs(CLDCCur.group_Vat_Value);
                     END IF;
                     lrec_cont_postings.debit_amount := 0;
                     lrec_cont_postings.local_debit_amount := 0;
                     lrec_cont_postings.group_debit_amount := 0;
                  ELSE
                     IF PSCur.fin_value_type = 'EX_VAT' THEN
                        lrec_cont_postings.debit_amount := abs(CLDCCur.Booking_Value);
                        lrec_cont_postings.local_debit_amount := abs(CLDCCur.local_Value);
                        lrec_cont_postings.group_debit_amount := abs(CLDCCur.group_Value);
                     ELSE
                        lrec_cont_postings.debit_amount := abs(CLDCCur.Booking_Vat_Value);
                        lrec_cont_postings.local_debit_amount := abs(CLDCCur.local_Vat_Value);
                        lrec_cont_postings.group_debit_amount := abs(CLDCCur.group_Vat_Value);
                     END IF;
                     lrec_cont_postings.credit_amount := 0;
                     lrec_cont_postings.local_credit_amount := 0;
                     lrec_cont_postings.group_credit_amount := 0;
                  END IF;
               END IF;

               IF PSCur.Copy_Vat_Code_Ind = 'Y' THEN
                  lrec_cont_postings.vat_code := nvl(ec_cont_line_item.vat_code(CLDCCur.Line_Item_Key),ec_cont_transaction.vat_code(CLDCCur.Transaction_Key));
               ELSE
                  lrec_cont_postings.vat_code := NULL;
               END IF;

               IF PSCur.fin_value_type = 'EX_VAT' THEN

                   -- Booking value
                   lrec_cont_postings.amount_inc_vat := CLDCCur.Booking_Value + CLDCCur.Booking_Vat_Value;
                   lrec_cont_postings.amount_ex_vat  := CLDCCur.Booking_Value;

                   -- Local value
                   lrec_cont_postings.local_amount_inc_vat := CLDCCur.Local_Value + CLDCCur.Local_Vat_Value;
                   lrec_cont_postings.local_amount_ex_vat  := CLDCCur.Local_Value;

                   -- Group value
                   lrec_cont_postings.group_amount_inc_vat := CLDCCur.Group_Value + CLDCCur.Group_Vat_Value;
                   lrec_cont_postings.group_amount_ex_vat  := CLDCCur.Group_Value;
               ELSE
                   lrec_cont_postings.amount_inc_vat := NULL;
                   lrec_cont_postings.amount_ex_vat  := NULL;
                   lrec_cont_postings.local_amount_inc_vat := NULL;
                   lrec_cont_postings.local_amount_ex_vat  := NULL;
                   lrec_cont_postings.group_amount_inc_vat := NULL;
                   lrec_cont_postings.group_amount_ex_vat  := NULL;

               END IF;

               lrec_cont_postings.post_ind := lv2_post_ind;

               INSERT INTO cont_postings VALUES lrec_cont_postings;

             END IF;
         END LOOP;
     END LOOP;
     IF ue_fin_account.isGenFinPostingDataPostUEE = 'TRUE' THEN
         ue_fin_account.GenFinPostingDataPost(p_object_id,
             p_document_id,
             p_fin_code,
             p_status,
             p_doc_total,
             p_company_obj_id,
             p_daytime,
             p_user);
     END IF;
  END IF;
EXCEPTION

         WHEN no_account THEN

              Raise_Application_Error(-20000,'No account mapping was found for ' || lv2_err_text);

         WHEN no_cost_object THEN

              Raise_Application_Error(-20000,'No cost object was found for ' || lv2_err_text);

END GenFinPostingData;

PROCEDURE AggregateFinPostingData( -- set the financial posting data
   p_object_id VARCHAR2,
   p_document_id VARCHAR2,
   p_document_concept VARCHAR2,
   p_fin_code VARCHAR2,
   p_status VARCHAR2,
   p_doc_total NUMBER,
   p_company_obj_id VARCHAR2,
   p_daytime   DATE,
   p_document_date DATE,
   p_user      VARCHAR2
)

IS


CURSOR c_company_totals(cp_document_key VARCHAR2, cp_document_concept VARCHAR2) IS
select receiver_id,
       payment_scheme_id,
       customer_id,
       sum(debit_amount) - sum(credit_amount) tot_value
  from cont_postings
 where document_key = cp_document_key
   and payment = 'Y'
 group by receiver_id, payment_scheme_id, customer_id;
--having (abs(sum(debit_amount) - sum(credit_amount)) <> 0) OR (cp_document_concept = 'REALLOCATION');

CURSOR c_ps (cp_object_id VARCHAR2, cp_book_total NUMBER, cp_booking_period DATE, cp_status VARCHAR2, cp_doc_date DATE, cp_document_concept VARCHAR) IS
SELECT p.daytime,
       p.value_type,
       decode(p.value_type,
              'FRACTION',
              ((p.frac_num / p.frac_denom) *
              EcDp_Payment_Scheme.GetBookedTotalMinusFixedV(cp_object_id,
                                                             cp_book_total,
                                                             p.prod_mth))+nvl(p.item_value,0),
              'SHARE',
              (p.item_share *
              EcDp_Payment_Scheme.GetBookedTotalMinusFixedV(cp_object_id,
                                                             cp_book_total,
                                                             p.prod_mth))+nvl(p.item_value,0),
              'VALUE',
              p.item_value) val,
       p.description
  FROM payment_scheme_item p
 WHERE p.object_id = cp_object_id
   AND p.prod_mth = cp_booking_period
   AND cp_object_id is not null
   AND cp_status <> 'ACCRUAL'
   AND cp_document_concept <> 'REALLOCATION'
   AND cp_book_total <> 0
UNION ALL
SELECT cp_doc_date daytime,
       'FRACTION' value_type,
       cp_book_total val,
       '' description
  FROM dual
 WHERE cp_status = 'ACCRUAL'
    OR cp_document_concept = 'REALLOCATION'
    OR cp_book_total = 0
UNION ALL
SELECT null, 'FRACTION' value_type, cp_book_total val, '' description
  FROM dual
 WHERE cp_object_id is null
   AND cp_status <> 'ACCRUAL'
   AND cp_document_concept <> 'REALLOCATION'
   AND cp_book_total <> 0;

CURSOR c_postings(cp_document_key VARCHAR2) IS
  select *
    from cont_postings
   where document_key = cp_document_key
   order by line_item_key;

CURSOR c_company_item_totals(cp_document_key VARCHAR2, cp_receiver_id VARCHAR2) IS
select cp.fin_debit_posting_key,
       cp.fin_credit_posting_key,
       cp.fin_gl_account,
       cp.fin_cost_object,
       cp.vat_code,
       cp.post_ind,
       cp.payment,
       cp.receiver_id,
       cp.payment_scheme_id,
       cp.fin_account_id,
       cp.item,
       cp.counter_item,
       cp.vendor_id,
       cp.fin_cost_obj_type,
       cp.fin_external_ref,
       decode(ec_fin_account.object_code(cp.fin_account_id),'CUST_ACCT',null,'VEND_ACCT',null,cldc.uom1_code) uom1_code,
       decode(ec_fin_account.object_code(cp.fin_account_id),'CUST_ACCT',null,'VEND_ACCT',null,sum(cldc.qty1)) qty1,
       abs(sum(cp.debit_amount)) - abs(sum(cp.credit_amount)) tot_value,
       abs(sum(cp.local_debit_amount)) - abs(sum(cp.local_credit_amount)) local_tot_value,
       abs(sum(cp.group_debit_amount)) - abs(sum(cp.group_credit_amount)) group_tot_value,
       sum(amount_inc_vat) tot_inc,
       sum(amount_ex_vat) tot_ex,
       sum(local_amount_inc_vat) local_tot_inc,
       sum(local_amount_ex_vat) local_tot_ex,
       sum(group_amount_inc_vat) group_tot_inc,
       sum(group_amount_ex_vat) group_tot_ex
 from  cont_postings cp, cont_li_dist_company cldc
 where cp.document_key = cp_document_key
   and cp.receiver_id = cp_receiver_id
   and cp.line_item_key = cldc.line_item_key
   and cp.dist_id = cldc.dist_id
   and cp.vendor_id = cldc.vendor_id
   and cp.customer_id = cldc.customer_id
 group by cp.fin_debit_posting_key,
          cp.fin_credit_posting_key,
          cp.fin_gl_account,
          cp.fin_cost_object,
          cp.vat_code,
          cp.post_ind,
          cp.payment,
          cp.receiver_id,
          cp.payment_scheme_id,
          cp.fin_account_id,
          cp.fin_cost_obj_type,
          cp.fin_external_ref,
          decode(ec_fin_account.object_code(cp.fin_account_id),'CUST_ACCT',null,'VEND_ACCT',null,cldc.uom1_code),
          cp.item,
          cp.counter_item,
          cp.vendor_id
having (abs(sum(cp.debit_amount)) - abs(sum(cp.credit_amount)) <> 0);

cursor main_dist(cp_document_key varchar2, cp_finacial_code varchar2) IS
select cpa.vendor_id,
       cpa.item,
       sum(cpa.amount) amount,
       sum(cpa.local_amount) local_amount,
       sum(cpa.group_amount) group_amount,
       sum(cpa.amount_inc_vat) amount_inc_vat,
       sum(cpa.amount_ex_vat) amount_ex_vat,
       sum(cpa.local_amount_inc_vat) local_amount_inc_vat,
       sum(cpa.local_amount_ex_vat) local_amount_ex_vat,
       sum(cpa.group_amount_inc_vat) group_amount_inc_vat,
       sum(cpa.group_amount_ex_vat) group_amount_ex_vat,
       cpa.daytime
  from cont_postings_aggregated cpa, fin_posting_setup fps
 where cpa.document_key = cp_document_key
   and fps.financial_code = cp_finacial_code
   and fps.item = cpa.item
   and fps.credit_debit = decode(cp_finacial_code,
                                 'SALE',
                                 'DEBIT',
                                 'TA_INCOME',
                                 'DEBIT',
                                 'JOU_ENT',
                                 'DEBIT',
                                 'CREDIT')
 group by cpa.vendor_id, cpa.item, cpa.daytime;


cursor move(cp_document_key varchar2) IS
select object_id,
       daytime,
       fin_account_id,
       fin_gl_account,
       fin_cost_obj_type,
       fin_cost_object,
       fin_external_ref,
       sum(amount) amount,
       sum(local_amount) local_amount,
       sum(group_amount) group_amount,
       post_ind,
       document_key,
       vat_code,
       sum(amount_inc_vat) amount_inc_vat,
       payment,
       payment_scheme_id,
       receiver_id,
       sum(amount_ex_vat) amount_ex_vat,
       origin_country_id,
       destination_country_id,
       qty1,
       uom1_code,
       payment_description,
       fin_debit_posting_key,
       fin_credit_posting_key,
       sum(local_amount_inc_vat) local_amount_inc_vat,
       sum(local_amount_ex_vat) local_amount_ex_vat,
       sum(group_amount_inc_vat) group_amount_inc_vat,
       sum(group_amount_ex_vat) group_amount_ex_vat
  from cont_postings_aggregated
 where document_key = cp_document_key
   and interim_ind = 'Y'
 group by object_id,
          daytime,
          fin_account_id,
          fin_gl_account,
          fin_cost_obj_type,
          fin_cost_object,
          fin_external_ref,
          post_ind,
          document_key,
          vat_code,
          payment,
          payment_scheme_id,
          receiver_id,
          origin_country_id,
          destination_country_id,
          qty1,
          uom1_code,
          payment_description,
          fin_debit_posting_key,
          fin_credit_posting_key;



lv2_country_id VARCHAR2(32);
lv2_booking_area_code VARCHAR2(32);
ld_booking_period DATE;
ln_period_fraction NUMBER;
ld_payment_date DATE;
lrec_cp_aggr CONT_POSTINGS_AGGREGATED%ROWTYPE;
ln_item_total NUMBER;
ln_local_item_total NUMBER;
ln_group_item_total NUMBER;
lv2_line_item_key VARCHAR2(32);
lv2_where VARCHAR2(2000);


BEGIN


     -- loop sum of payment for each vendor

     FOR r_comp_totals IN c_company_totals(p_document_id, p_document_concept) LOOP

        lv2_country_id := ec_company_version.country_id(p_company_obj_id, p_daytime, '<=');
        lv2_booking_area_code := ec_contract_version.financial_code(p_object_id, p_daytime, '<=');
        ld_booking_period := ecdp_fin_period.getCurrentOpenPeriod(lv2_country_id, p_company_obj_id, lv2_booking_area_code, 'BOOKING',p_document_id,p_document_date);


        FOR r_ps IN c_ps(r_comp_totals.payment_scheme_id, r_comp_totals.tot_value, ld_booking_period, p_status, p_document_date, p_document_concept) LOOP

            IF r_comp_totals.tot_value <> 0 THEN
                        ln_period_fraction := r_ps.val/r_comp_totals.tot_value;
            ELSE
                        ln_period_fraction := 1;
            END IF;

            ld_payment_date := r_ps.daytime;

            IF r_comp_totals.payment_scheme_id IS NULL THEN -- No payment scheme
                ld_payment_date := nvl(ec_cont_document_company.pay_date(p_document_id, r_comp_totals.receiver_id), p_document_date);
            END IF;

            FOR r_postings In c_company_item_totals(p_document_id, r_comp_totals.receiver_id) LOOP

                lrec_cp_aggr.payment_description := r_ps.description;
                ln_item_total := r_postings.tot_value * ln_period_fraction;
                ln_local_item_total := r_postings.local_tot_value * ln_period_fraction;
                ln_group_item_total := r_postings.group_tot_value * ln_period_fraction;


                lrec_cp_aggr.fin_debit_posting_key := r_postings.fin_debit_posting_key;
                lrec_cp_aggr.fin_credit_posting_key := r_postings.fin_credit_posting_key;

                lrec_cp_aggr.object_id := p_object_id;
                lrec_cp_aggr.daytime := ld_payment_date;
                lrec_cp_aggr.fin_account_id := r_postings.fin_account_id;
                lrec_cp_aggr.fin_gl_account := r_postings.fin_gl_account;
                lrec_cp_aggr.fin_cost_obj_type := r_postings.fin_cost_obj_type;
                lrec_cp_aggr.fin_cost_object := r_postings.fin_cost_object;
                lrec_cp_aggr.fin_external_ref := r_postings.fin_external_ref;
                lrec_cp_aggr.amount := round(ln_item_total,2);
                lrec_cp_aggr.local_amount := round(ln_local_item_total,2);
                lrec_cp_aggr.group_amount := round(ln_group_item_total,2);
                lrec_cp_aggr.post_ind := r_postings.post_ind;
                lrec_cp_aggr.document_key := p_document_id;
                lrec_cp_aggr.vat_code := r_postings.vat_code;
                lrec_cp_aggr.payment := r_postings.payment;
                lrec_cp_aggr.payment_scheme_id := r_postings.payment_scheme_id;
                lrec_cp_aggr.receiver_id := r_postings.receiver_id;
                --The folowing is for NOT taking UOM into account for the posting to the customer account / vendor account
                IF ec_fin_account.object_code(lrec_cp_aggr.fin_account_id) in ('CUST_ACCT', 'VEND_ACCT') THEN
                         lrec_cp_aggr.qty1 := null;
                         lrec_cp_aggr.uom1_code := null;
                         lrec_cp_aggr.vat_code := null;

                ELSE
                         lrec_cp_aggr.qty1 := r_postings.qty1;
                         lrec_cp_aggr.uom1_code := r_postings.uom1_code;
                         lrec_cp_aggr.vat_code := r_postings.vat_code;
                END IF;
                lrec_cp_aggr.amount_ex_vat := round(r_postings.tot_ex * ln_period_fraction,2);
                lrec_cp_aggr.amount_inc_vat := round(r_postings.tot_inc * ln_period_fraction,2);
                lrec_cp_aggr.local_amount_ex_vat := round(r_postings.local_tot_ex * ln_period_fraction,2);
                lrec_cp_aggr.local_amount_inc_vat := round(r_postings.local_tot_inc * ln_period_fraction,2);
                lrec_cp_aggr.group_amount_ex_vat := round(r_postings.group_tot_ex * ln_period_fraction,2);
                lrec_cp_aggr.group_amount_inc_vat := round(r_postings.group_tot_inc * ln_period_fraction,2);
                lrec_cp_aggr.item := r_postings.item;
                lrec_cp_aggr.counter_item := r_postings.counter_item;
                lrec_cp_aggr.vendor_id := r_postings.vendor_id;
                lrec_cp_aggr.interim_ind := 'Y';

                Ecdp_System_Key.assignNextNumber('CONT_POSTINGS_AGGREGATED',lrec_cp_aggr.posting_no);

                INSERT INTO cont_postings_aggregated VALUES lrec_cp_aggr;

            END LOOP;

            -- No Payments LOOP
        END LOOP;

        -- Applying Payment details vs. grand total balance
        FOR r_adj_postings In c_company_item_totals(p_document_id, r_comp_totals.receiver_id) LOOP

            lv2_where := 'document_key = '''||p_document_id
                      ||''' and nvl(fin_account_id,''*NULL*'') = '''||nvl(r_adj_postings.fin_account_id,'*NULL*')
                      ||''' and nvl(fin_cost_object,''*NULL*'') = '''||nvl(r_adj_postings.fin_cost_object,'*NULL*')
                      ||''' and nvl(payment_scheme_id,''*NULL*'') = ''' ||nvl(r_adj_postings.payment_scheme_id,'*NULL*')
                      ||''' and nvl(uom1_code,''*NULL*'') = ''' || nvl(r_adj_postings.uom1_code,'*NULL*')
                      ||''' and receiver_id = '''||r_adj_postings.receiver_id
                      ||''' and item = '''||r_adj_postings.item
                      ||''' and nvl(counter_item, -9999) = '||nvl(r_adj_postings.counter_item,-9999)
                      ||'   and vendor_id = '''||r_adj_postings.vendor_id||'''';


            ecdp_contract_setup.genericrounding('CONT_POSTINGS_AGGREGATED','AMOUNT',r_adj_postings.tot_value, lv2_where);
            ecdp_contract_setup.genericrounding('CONT_POSTINGS_AGGREGATED','LOCAL_AMOUNT',r_adj_postings.local_tot_value, lv2_where);
            ecdp_contract_setup.genericrounding('CONT_POSTINGS_AGGREGATED','GROUP_AMOUNT',r_adj_postings.group_tot_value, lv2_where);
            ecdp_contract_setup.genericrounding('CONT_POSTINGS_AGGREGATED','AMOUNT_EX_VAT',r_adj_postings.tot_ex, lv2_where);
            ecdp_contract_setup.genericrounding('CONT_POSTINGS_AGGREGATED','AMOUNT_INC_VAT',r_adj_postings.tot_inc, lv2_where);
            ecdp_contract_setup.genericrounding('CONT_POSTINGS_AGGREGATED','LOCAL_AMOUNT_EX_VAT',r_adj_postings.local_tot_ex, lv2_where);
            ecdp_contract_setup.genericrounding('CONT_POSTINGS_AGGREGATED','LOCAL_AMOUNT_INC_VAT',r_adj_postings.local_tot_inc, lv2_where);
            ecdp_contract_setup.genericrounding('CONT_POSTINGS_AGGREGATED','GROUP_AMOUNT_EX_VAT',r_adj_postings.group_tot_ex, lv2_where);
            ecdp_contract_setup.genericrounding('CONT_POSTINGS_AGGREGATED','GROUP_AMOUNT_INC_VAT',r_adj_postings.group_tot_inc, lv2_where);


        END LOOP;

     END LOOP;


     FOR c_rec in main_dist(p_document_id, p_fin_code) LOOP

         lv2_where := 'document_key = '''||p_document_id||''' and counter_item = '||c_rec.item||' and vendor_id = '''||c_rec.vendor_id||''' and daytime = to_date('''||to_char(c_rec.daytime,'YYYY-MM-DD')||''',''YYYY-MM-DD'')';
         -- Applying credit/debit balance to postings
         ecdp_contract_setup.genericrounding('CONT_POSTINGS_AGGREGATED','AMOUNT',-c_rec.amount, lv2_where);
         ecdp_contract_setup.genericrounding('CONT_POSTINGS_AGGREGATED','LOCAL_AMOUNT',-c_rec.local_amount, lv2_where);
         ecdp_contract_setup.genericrounding('CONT_POSTINGS_AGGREGATED','GROUP_AMOUNT',-c_rec.group_amount, lv2_where);
         ecdp_contract_setup.genericrounding('CONT_POSTINGS_AGGREGATED','AMOUNT_EX_VAT',c_rec.amount_ex_vat , lv2_where);
         ecdp_contract_setup.genericrounding('CONT_POSTINGS_AGGREGATED','AMOUNT_INC_VAT',c_rec.amount_inc_vat, lv2_where);
         ecdp_contract_setup.genericrounding('CONT_POSTINGS_AGGREGATED','LOCAL_AMOUNT_EX_VAT',c_rec.local_amount_ex_vat , lv2_where);
         ecdp_contract_setup.genericrounding('CONT_POSTINGS_AGGREGATED','LOCAL_AMOUNT_INC_VAT',c_rec.local_amount_inc_vat, lv2_where);
         ecdp_contract_setup.genericrounding('CONT_POSTINGS_AGGREGATED','GROUP_AMOUNT_EX_VAT',c_rec.group_amount_ex_vat , lv2_where);
         ecdp_contract_setup.genericrounding('CONT_POSTINGS_AGGREGATED','GROUP_AMOUNT_INC_VAT',c_rec.group_amount_inc_vat, lv2_where);

     END LOOP;

     FOR r_move in move(p_document_id) LOOP

        lrec_cp_aggr := null;
        ln_item_total := r_move.amount;

        IF ln_item_total >= 0 THEN
           lrec_cp_aggr.fin_posting_key := r_move.fin_debit_posting_key;
           lrec_cp_aggr.debit_credit_ind := 'D';
        ELSE
           lrec_cp_aggr.fin_posting_key := r_move.fin_credit_posting_key;
           lrec_cp_aggr.debit_credit_ind := 'C';
        END IF;


        lrec_cp_aggr.object_id                     := r_move.object_id             ;
        lrec_cp_aggr.daytime                       := r_move.daytime               ;
        lrec_cp_aggr.fin_account_id                := r_move.fin_account_id        ;
        lrec_cp_aggr.fin_gl_account                := r_move.fin_gl_account        ;
        lrec_cp_aggr.fin_cost_obj_type             := r_move.fin_cost_obj_type     ;
        lrec_cp_aggr.fin_cost_object               := r_move.fin_cost_object       ;
        lrec_cp_aggr.fin_external_ref              := r_move.fin_external_ref      ;
        lrec_cp_aggr.amount                        := abs(ln_item_total)           ;
        lrec_cp_aggr.local_amount                  := abs(r_move.local_amount)     ;
        lrec_cp_aggr.group_amount                  := abs(r_move.group_amount)     ;
        lrec_cp_aggr.post_ind                      := r_move.post_ind              ;
        lrec_cp_aggr.document_key                  := r_move.document_key          ;
        lrec_cp_aggr.vat_code                      := r_move.vat_code              ;
        lrec_cp_aggr.amount_inc_vat                := abs(r_move.amount_inc_vat)   ;
        lrec_cp_aggr.payment                       := r_move.payment               ;
        lrec_cp_aggr.payment_scheme_id             := r_move.payment_scheme_id     ;
        lrec_cp_aggr.receiver_id                   := r_move.receiver_id           ;
        lrec_cp_aggr.amount_ex_vat                 := abs(r_move.amount_ex_vat)    ;
        lrec_cp_aggr.item                          := NULL                         ;
        lrec_cp_aggr.counter_item                  := NULL                         ;
        lrec_cp_aggr.master_item                   := NULL                         ;
        lrec_cp_aggr.origin_country_id             := r_move.origin_country_id     ;
        lrec_cp_aggr.destination_country_id        := r_move.destination_country_id     ;
        lrec_cp_aggr.qty1                          := r_move.qty1                  ;
        lrec_cp_aggr.uom1_code                     := r_move.uom1_code             ;
        lrec_cp_aggr.payment_description           := r_move.payment_description   ;
        lrec_cp_aggr.vendor_id                     := NULL                         ;
        lrec_cp_aggr.fin_debit_posting_key         := NULL                         ;
        lrec_cp_aggr.fin_credit_posting_key        := NULL                         ;
        lrec_cp_aggr.interim_ind                   := NULL                         ;
        lrec_cp_aggr.local_amount_inc_vat          := abs(r_move.local_amount_inc_vat)   ;
        lrec_cp_aggr.local_amount_ex_vat           := abs(r_move.local_amount_ex_vat)    ;
        lrec_cp_aggr.group_amount_inc_vat          := abs(r_move.group_amount_inc_vat)   ;
        lrec_cp_aggr.group_amount_ex_vat           := abs(r_move.group_amount_ex_vat)    ;


        Ecdp_System_Key.assignNextNumber('CONT_POSTINGS_AGGREGATED',lrec_cp_aggr.posting_no);

        INSERT INTO cont_postings_aggregated VALUES lrec_cp_aggr;

     END LOOP;

     -- Cleanup interim records
     delete from cont_postings_aggregated where document_key = p_document_id and interim_ind = 'Y';

END AggregateFinPostingData;

-- Function used to check if document is candidate for additional FI transfer
FUNCTION CorrectToFI (
   p_object_id VARCHAR2,
   p_daytime DATE,
   p_document_id VARCHAR2)
RETURN VARCHAR2

IS

CURSOR c_vendor IS
SELECT company_id
  FROM cont_document_company
 WHERE ecdp_objects.GetObjClassName(p_object_id) = 'VENDOR'
   AND object_id = p_object_id
   AND document_key = p_document_id;

CURSOR c_customer IS
SELECT company_id
  FROM cont_document_company
 WHERE ecdp_objects.GetObjClassName(p_object_id) = 'CUSTOMER'
   AND object_id = p_object_id
   AND document_key = p_document_id;

lv2_financial_code VARCHAR2(32) := ec_contract_version.financial_code(p_object_id,p_daytime,'<=');
ln_vendor_cnt NUMBER := 0;
ln_customer_cnt NUMBER := 0;
lv2_doc_handling_code VARCHAR2(32) := ec_contract_version.document_handling_code(p_object_id,p_daytime,'<=');

BEGIN



    IF lv2_doc_handling_code <> 'SINGLE_DOC' THEN

        RETURN 'FALSE';

    END IF;

    FOR Vendor IN c_vendor LOOP

        ln_vendor_cnt := ln_vendor_cnt + 1;

    END LOOP;

    FOR Customer IN c_customer LOOP

        ln_customer_cnt := ln_customer_cnt + 1;

    END LOOP;

    IF (ln_vendor_cnt>1 AND lv2_financial_code IN ('SALE','TA_INCOME','JOU_ENT')) OR (ln_customer_cnt>1 AND lv2_financial_code IN ('PURCHASE','TA_COST')) THEN

        RETURN 'TRUE';

    ELSE

        RETURN 'FALSE';

    END IF;

END CorrectToFI;

PROCEDURE GenericRounding(
      p_table_name VARCHAR2,
      p_column_name VARCHAR2,
      p_total_val  NUMBER,
      p_where VARCHAR2
)

IS

ln_col_sum NUMBER;
lv2_sql_statement VARCHAR2(2000);

lv2_rowid VARCHAR2(32);

li_cursor  INTEGER;
li_ret_val  INTEGER;

BEGIN


     lv2_sql_statement := 'SELECT Sum(' || p_column_name || ') ' ||
                          'FROM ' || p_table_name || ' WHERE ' || p_where;

     -- do dynamic sql parsing
     li_cursor := Dbms_Sql.Open_Cursor;

     Dbms_sql.Parse(li_cursor,lv2_sql_statement,dbms_sql.v7);
     Dbms_Sql.Define_Column(li_cursor,1,ln_col_sum);

     li_ret_val := Dbms_Sql.Execute(li_cursor);

     IF Dbms_Sql.Fetch_Rows(li_cursor) = 0 THEN
         Dbms_Sql.Close_Cursor(li_cursor);
     ELSE
          Dbms_Sql.Column_Value(li_cursor,1,ln_col_sum);
     END IF;

     Dbms_Sql.Close_Cursor(li_cursor);


     IF p_total_val <> ln_col_sum THEN

        lv2_sql_statement := 'SELECT rowid FROM ' || p_table_name ||
                             ' WHERE ' || p_where || ' AND Abs(' || p_column_name || ') = ' ||
                             ' ( SELECT Max(Abs(' || p_column_name || ')) ' ||
                                'FROM ' || p_table_name || ' WHERE ' || p_where || ')';

        -- loop over cursor, but pick the first one
           li_cursor := Dbms_Sql.Open_Cursor;

           Dbms_sql.Parse(li_cursor,lv2_sql_statement,dbms_sql.v7);
           Dbms_Sql.Define_Column(li_cursor,1,lv2_rowid,32);

           li_ret_val := Dbms_Sql.Execute(li_cursor);

           IF Dbms_Sql.Fetch_Rows(li_cursor) > 0 THEN
                 Dbms_Sql.Column_Value(li_cursor,1,lv2_rowid);
           END IF;

           Dbms_Sql.Close_Cursor(li_cursor);

           lv2_sql_statement := 'UPDATE ' || p_table_name ||
                               ' SET ' || p_column_name || ' = ' || p_column_name || ' + ' || to_char(p_total_val - ln_col_sum,'999999999999990.9999999999','NLS_NUMERIC_CHARACTERS='',.''') ||
                               ' ,last_updated_by = ''SYSTEM'' '  ||
                               ' WHERE rowid = ''' || lv2_rowid || '''';

           li_cursor := Dbms_Sql.Open_Cursor;

           Dbms_sql.Parse(li_cursor,lv2_sql_statement,dbms_sql.v7);
           li_ret_val :=  Dbms_sql.Execute(li_cursor);

           Dbms_sql.Close_Cursor(li_cursor);

      END IF;

EXCEPTION

         WHEN OTHERS THEN
            Dbms_sql.Close_Cursor(li_cursor);
            Raise_Application_Error(-20000,'Error please contact technical personell and refer to this message : ' || lv2_sql_statement );

END GenericRounding;

PROCEDURE SetPriceElementFactorBasis(
   p_object_id             VARCHAR2,
   p_price_elem_id         VARCHAR2,
   p_product_id            VARCHAR2,
   p_price_cons_id         VARCHAR2,
   p_factor_basis          VARCHAR2,
   p_daytime               DATE,
   p_user                  VARCHAR2 DEFAULT NULL
)
IS

BEGIN

Raise_Application_Error(-20000,'TO BE IMPLEMENTED');

/*
     UPDATE cont_price_element_value t
     SET    t.factor_basis = p_factor_basis
            ,t.last_updated_by = p_user
     WHERE  t.object_id = p_object_id
     AND    t.product_object_id = p_product_id
     AND    t.price_element_object_id = p_price_elem_id
     AND    t.price_concept_object_id = p_price_cons_id
     AND    t.daytime = p_daytime;
*/



END SetPriceElementFactorBasis;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getShareBankAccount
-- Description    : Function retrieves the bank account defined for a vendor or Customer in a contract party share.
--
-- Preconditions  : One of p_cust_id and p_vend_id must be set
-- Postconditions :
--
-- Using tables   : contract_party_share, bank_account
--
-- Using functions: None
--
-- Configuration
-- required       :
--
-- Behaviour      : Using contract object_id and financial code and contract area code from the treeview
--                  This function might have a problem as contract_party_share is dataclass and we have no daytime!!!
--
---------------------------------------------------------------------------------------------------
FUNCTION getShareBankAccount(
   p_contract_id VARCHAR2,
   p_cust_id     VARCHAR2 DEFAULT NULL,
   p_vend_id     VARCHAR2 DEFAULT NULL
) RETURN VARCHAR2
--</EC-DOC>
IS

rp_bank_acc_code VARCHAR2(255) DEFAULT NULL;

CURSOR c_vend_bank_acc(cp_cont_id VARCHAR2, cp_vend_id VARCHAR2) IS
    SELECT ba.object_code
    FROM contract_party_share cps, bank_account ba
    WHERE ba.object_id = cps.object_id
    AND cps.object_id  = cp_cont_id
    AND cps.company_id = cp_vend_id
    AND cps.party_role = 'VENDOR';

CURSOR c_cust_bank_acc(cp_cont_id VARCHAR2, cp_cust_id VARCHAR2) IS
    SELECT ba.object_code
    FROM contract_party_share cps, bank_account ba
    WHERE ba.object_id = cps.object_id
    AND cps.object_id  = cp_cont_id
    AND cps.company_id = cp_cust_id
    AND cps.party_role = 'CUSTOMER';

BEGIN

-- Check that either vendor or customer is set
IF (p_cust_id IS NULL AND p_vend_id IS NULL) THEN
   Raise_Application_Error(-20000,'Can not retrieve Contract Share Bank Account. Both customer and vendor parameters are null. One of the two must be set.');
ELSIF (p_cust_id IS NOT NULL AND p_vend_id IS NOT NULL) THEN
   Raise_Application_Error(-20000,'Can not retrieve Contract Share Bank Account. Both customer and vendor parameters are set. Only one of the two must be set.');
END IF;

IF (p_cust_id IS NULL AND p_vend_id IS NOT NULL) THEN -- Vendor
  FOR c_val IN c_vend_bank_acc(p_contract_id, p_vend_id) LOOP
      IF (c_val.object_code IS NOT NULL) THEN
         rp_bank_acc_code := c_val.object_code;
      END IF;
  END LOOP;
ELSIF (p_cust_id IS NOT NULL AND p_vend_id IS NULL) THEN -- Customer
  FOR c_val IN c_cust_bank_acc(p_contract_id, p_cust_id) LOOP
      IF (c_val.object_code IS NOT NULL) THEN
         rp_bank_acc_code := c_val.object_code;
      END IF;
  END LOOP;
ELSE
    rp_bank_acc_code := NULL;
END IF;

RETURN rp_bank_acc_code;

END getShareBankAccount;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getShareBankAccountDesc
-- Description    : Function retrieves the bank account description defined for a vendor or Customer in a contract party share.
--
-- Preconditions  : One of p_cust_id and p_vend_id must be set
-- Postconditions :
--
-- Using tables   : contract_party_share, bank_account, bank_account_version
--
-- Using functions: None
--
-- Configuration
-- required       :
--
-- Behaviour      : Using contract object_id and financial code and contract area code from the treeview
--
---------------------------------------------------------------------------------------------------
FUNCTION getShareBankAccountDesc(
   p_contract_id VARCHAR2,
   p_cust_id     VARCHAR2 DEFAULT NULL,
   p_vend_id     VARCHAR2 DEFAULT NULL
) RETURN VARCHAR2
--</EC-DOC>
IS

rp_bank_acc_code VARCHAR2(255) DEFAULT NULL;
rp_bank_acc_desc VARCHAR2(255) DEFAULT NULL;

CURSOR c_bank_acc(cp_bank_acc_code VARCHAR2) IS
       SELECT
         ec_bank_version.name(bav.bank_id, ba.start_date) AS BANK_NAME,
         ec_currency.object_code(bav.CURRENCY_ID) CURRENCY_CODE,
         bav.ACCOUNT_NUMBER
       FROM bank_account ba, bank_account_version bav
       WHERE ba.OBJECT_CODE = cp_bank_acc_code
       AND ba.object_id = bav.object_id;

BEGIN

-- Get the bank Account Code from function "getShareBankAccount"
rp_bank_acc_code := getShareBankAccount(p_contract_id, p_cust_id, p_vend_id);

-- If bank account is set, get other information about the bank account
IF rp_bank_acc_code IS NOT NULL THEN
   -- Bank Name + Bank City + Currency Code + Account Number
   FOR c_val IN c_bank_acc(rp_bank_acc_code) LOOP
       IF c_val.bank_name IS NOT NULL THEN
          rp_bank_acc_desc := c_val.bank_name || ', ';
       END IF;
       IF c_val.currency_code IS NOT NULL THEN
          rp_bank_acc_desc := rp_bank_acc_desc || c_val.currency_code || ', ';
       END IF;
       IF c_val.account_number IS NOT NULL THEN
          rp_bank_acc_desc := rp_bank_acc_desc || 'Account ' || c_val.account_number;
       END IF;
   END LOOP;
END IF;

RETURN rp_bank_acc_desc;

END getShareBankAccountDesc;





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
              project_ind     = lrec_contract.project_ind,
              template_code   = lrec_contract.template_code,
              bf_profile      = lrec_contract.bf_profile,
              description     = lrec_contract.description,
              last_updated_by = p_user
        WHERE object_id = lv2_object_id;


-- Expecting one record - one version
FOR v_obj IN c_version_obj(lv2_object_id) LOOP
    lv_new_obj_daytime := v_obj.daytime;
END LOOP;

      IF lrec_contract.end_date <= lv_new_obj_daytime THEN
         lrec_old_contract_version := ec_contract_version.row_by_pk(p_object_id,lrec_contract.end_date-1,'<=');
      ELSE
         lrec_old_contract_version := ec_contract_version.row_by_pk(p_object_id,lv_new_obj_daytime,'<=');
      END IF;

       UPDATE contract_version cv
          SET cv.name                    = lrec_old_contract_version.name,
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
              cv.first_delivery_date     = lrec_old_contract_version.first_delivery_date,
              cv.last_delivery_date      = lrec_old_contract_version.last_delivery_date,
              cv.calc_approval_check     = lrec_old_contract_version.calc_approval_check,
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

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  InsNewDocSetup
-- Description    : Inserts a new Document Setup
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
--
-------------------------------------------------------------------------------------------------
FUNCTION InsNewDocSetup(p_object_id   VARCHAR2,
                        p_object_code VARCHAR2,
                        p_contract_id VARCHAR2,
                        p_start_date  DATE,
                        p_end_date    DATE DEFAULT NULL,
                        p_user        VARCHAR2 DEFAULT NULL)
--</EC-DOC>
RETURN VARCHAR2

IS
lv2_default_code  VARCHAR2(100) := p_object_code||'_COPY';
lv2_object_id contract_doc.object_id%TYPE;

/* Returning records from all versions of the document setup being copied. Sorted ascending on daytime */
CURSOR c_versions (cp_object_id VARCHAR2) IS
  SELECT cv.daytime, cv.end_date
    FROM contract_doc c, contract_doc_version cv
   WHERE c.object_id = cp_object_id
     AND c.contract_id = p_contract_id
     AND c.object_id = cv.object_id
   ORDER BY cv.daytime;

-- ** 4-eyes approval stuff ** --
lv2_4e_recid VARCHAR2(32);
-- ** END 4-eyes approval stuff ** --

BEGIN

   lv2_default_code := Ecdp_Object_Copy.GetCopyObjectCode('CONTRACT_DOC',lv2_default_code);

   -- debug purpose
    --ecdp_dynsql.WriteTempText('missing sd insnewdocsetup', p_start_date);

   INSERT INTO contract_doc
     (object_code, start_date, end_date, contract_id, created_by)
   VALUES
     (lv2_default_code, p_start_date, p_end_date, p_contract_id, p_user)
   RETURNING object_id INTO lv2_object_id;

    --ecdp_dynsql.WriteTempText('p_object_id is ', p_object_id);

   FOR v IN c_versions(p_object_id) LOOP
     INSERT INTO contract_doc_version
       (object_id, daytime, end_date, created_by)
     VALUES
       (lv2_object_id, v.daytime, v.end_date, p_user);
   END LOOP;

    -- ** 4-eyes approval logic ** --
    IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('CONTRACT_DOC'),'N') = 'Y' THEN

      -- Generate rec_id for the latest version record
      lv2_4e_recid := SYS_GUID();

      -- Set approval info on latest version record.
      UPDATE contract_doc_version
      SET last_updated_by = Nvl(EcDp_Context.getAppUser,User),
          last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
          approval_state = 'N',
          rec_id = lv2_4e_recid,
          rev_no = (nvl(rev_no,0) + 1)
      WHERE object_id = lv2_object_id
      AND daytime = (SELECT MAX(daytime) FROM contract_doc_version WHERE object_id = lv2_object_id);

      -- Register version record for approval
      Ecdp_Approval.registerTaskDetail(lv2_4e_recid,
                                        'CONTRACT_DOC',
                                        Nvl(EcDp_Context.getAppUser,User));
    END IF;
    -- ** END 4-eyes approval ** --

   RETURN lv2_object_id;

END InsNewDocSetup;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  InsNewDocSetupCopy
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
FUNCTION InsNewDocSetupCopy(p_object_id  VARCHAR2, -- to copy from
                            p_start_date DATE, -- to copy from
                            p_contract_id VARCHAR2,
                            p_code       VARCHAR2,
                            p_user       VARCHAR2,
                            p_end_date   DATE DEFAULT NULL)

RETURN VARCHAR2 -- new object_id
--</EC-DOC>
IS

/* Returning records from all versions of the contract doc being copied. Sorted ascending on daytime */
CURSOR c_versions (cp_object_id VARCHAR2) IS
SELECT  cv.NAME
    ,cv.DAYTIME
    ,cv.AMOUNT_IN_WORDS
    ,cv.BOOK_DOCUMENT_CODE
    ,cv.DOC_CONCEPT_CODE
    ,cv.DOC_SCOPE
    ,cv.INT_BASE_AMOUNT_SOURCE
    ,cv.INT_COMPOUNDING_PERIOD
    ,cv.INT_NUM_DAYS
    ,cv.INT_OFFSET
    ,cv.INT_TYPE
    ,cv.INT_TYPE_ID
    ,cv.DOC_NUMBER_FORMAT_FINAL
    ,cv.PAYMENT_TERM_BASE_CODE
    ,cv.PRICE_BASIS
    ,cv.REVIEW_PERIOD
    ,cv.REVIEW_PERIOD_UNIT_CODE
    ,cv.SEND_UNIT_PRICE_IND
    ,cv.USE_CURRENCY_100_IND
    ,cv.AUTOMATION_IND
    ,cv.AUTOMATION_PRIORITY
    ,cv.DOC_TEMPLATE_ID
    ,cv.INV_DOC_TEMPLATE_ID
    ,cv.PAYMENT_TERM_ID
    ,cv.DOC_RECEIVED_BASE_CODE
    ,cv.DOC_RECEIVED_TERM_ID
    ,cv.DOC_DATE_CALENDAR_COLL_ID
    ,cv.DOC_DATE_TERM_ID
    ,cv.DOC_REC_CALENDAR_COLL_ID
    ,cv.PAYMENT_CALENDAR_COLL_ID
    ,cv.BOOKING_CURRENCY_ID
    ,cv.MEMO_CURRENCY_ID
    ,cv.PRICING_CURRENCY_ID
    ,cv.DOC_NUMBER_FORMAT_ACCRUAL
    ,cv.DOC_SEQUENCE_ACCRUAL_ID
    ,cv.DOC_SEQUENCE_FINAL_ID
    ,cv.PAYMENT_SCHEME_ID
    ,cv.COMMENTS
    ,cv.text_1
    ,cv.text_2
    ,cv.text_3
    ,cv.text_4
    ,cv.text_5
    ,cv.text_6
    ,cv.text_7
    ,cv.text_8
    ,cv.text_9
    ,cv.text_10
    ,cv.value_1
    ,cv.value_2
    ,cv.value_3
    ,cv.value_4
    ,cv.value_5
    ,cv.value_6
    ,cv.value_7
    ,cv.value_8
    ,cv.value_9
    ,cv.value_10
    ,cv.date_1
    ,cv.date_2
    ,cv.date_3
    ,cv.date_4
    ,cv.date_5
    ,cv.date_6
    ,cv.date_7
    ,cv.date_8
    ,cv.date_9
    ,cv.date_10
    ,cv.erp_document_ind
    ,cv.hold_final_when_acl_ind
    ,cv.single_parcel_doc_ind
FROM contract_doc c, contract_doc_version cv
 WHERE c.object_id = cp_object_id
   AND c.contract_id = p_contract_id
   AND c.object_id = cv.object_id
 ORDER BY cv.daytime;

lv2_object_id contract_doc.object_id%TYPE;
lrec_contract_doc contract_doc%ROWTYPE;

BEGIN

lrec_contract_doc := ec_contract_doc.row_by_pk(p_object_id);

    -- debug purpose
    --ecdp_dynsql.WriteTempText('missing sd', p_start_date);

     lv2_object_id := InsNewDocSetup(p_object_id,p_code,p_contract_id,p_start_date,p_end_date,p_user);

    -- debug purpose
    --ecdp_dynsql.WriteTempText('missing sd lrec', lrec_contract_doc.start_date);

   UPDATE contract_doc
      SET start_date      = lrec_contract_doc.start_date,
          end_date      = lrec_contract_doc.end_date,
          description     = lrec_contract_doc.description,
          last_updated_by = p_user
    WHERE object_id = lv2_object_id;


/* Applying all versions to the new object */
FOR v IN c_versions(p_object_id) LOOP

       UPDATE contract_doc_version cv
       SET   cv.NAME                          = v.NAME||'_COPY'
      ,cv.AMOUNT_IN_WORDS                   = v.AMOUNT_IN_WORDS
      ,cv.BOOK_DOCUMENT_CODE                = v.BOOK_DOCUMENT_CODE
      ,cv.DOC_CONCEPT_CODE                  = v.DOC_CONCEPT_CODE
      ,cv.DOC_SCOPE                         = v.DOC_SCOPE
      ,cv.INT_BASE_AMOUNT_SOURCE            = v.INT_BASE_AMOUNT_SOURCE
      ,cv.INT_COMPOUNDING_PERIOD            = v.INT_COMPOUNDING_PERIOD
      ,cv.INT_NUM_DAYS                      = v.INT_NUM_DAYS
      ,cv.INT_OFFSET                        = v.INT_OFFSET
      ,cv.INT_TYPE                          = v.INT_TYPE
      ,cv.INT_TYPE_ID                       = v.INT_TYPE_ID
      ,cv.DOC_NUMBER_FORMAT_FINAL           = v.DOC_NUMBER_FORMAT_FINAL
      ,cv.PAYMENT_TERM_BASE_CODE            = v.PAYMENT_TERM_BASE_CODE
      ,cv.PRICE_BASIS                       = v.PRICE_BASIS
      ,cv.REVIEW_PERIOD                     = v.REVIEW_PERIOD
      ,cv.REVIEW_PERIOD_UNIT_CODE           = v.REVIEW_PERIOD_UNIT_CODE
      ,cv.SEND_UNIT_PRICE_IND               = v.SEND_UNIT_PRICE_IND
      ,cv.USE_CURRENCY_100_IND              = v.USE_CURRENCY_100_IND
      ,cv.AUTOMATION_IND                    = v.AUTOMATION_IND
      ,cv.AUTOMATION_PRIORITY               = v.AUTOMATION_PRIORITY
      ,cv.DOC_TEMPLATE_ID                   = v.DOC_TEMPLATE_ID
      ,cv.INV_DOC_TEMPLATE_ID               = v.INV_DOC_TEMPLATE_ID
      ,cv.PAYMENT_TERM_ID                   = v.PAYMENT_TERM_ID
      ,cv.DOC_RECEIVED_BASE_CODE            = v.DOC_RECEIVED_BASE_CODE
      ,cv.DOC_RECEIVED_TERM_ID              = v.DOC_RECEIVED_TERM_ID
      ,cv.DOC_DATE_CALENDAR_COLL_ID         = v.DOC_DATE_CALENDAR_COLL_ID
      ,cv.DOC_DATE_TERM_ID                  = v.DOC_DATE_TERM_ID
      ,cv.DOC_REC_CALENDAR_COLL_ID          = v.DOC_REC_CALENDAR_COLL_ID
      ,cv.PAYMENT_CALENDAR_COLL_ID          = v.PAYMENT_CALENDAR_COLL_ID
      ,cv.BOOKING_CURRENCY_ID               = v.BOOKING_CURRENCY_ID
      ,cv.MEMO_CURRENCY_ID                  = v.MEMO_CURRENCY_ID
      ,cv.PRICING_CURRENCY_ID               = v.PRICING_CURRENCY_ID
      ,cv.DOC_NUMBER_FORMAT_ACCRUAL         = v.DOC_NUMBER_FORMAT_ACCRUAL
      ,cv.DOC_SEQUENCE_ACCRUAL_ID           = v.DOC_SEQUENCE_ACCRUAL_ID
      ,cv.DOC_SEQUENCE_FINAL_ID             = v.DOC_SEQUENCE_FINAL_ID
      ,cv.PAYMENT_SCHEME_ID                 = v.PAYMENT_SCHEME_ID
      ,COMMENTS                             = v.COMMENTS
      ,cv.text_1                            = v.text_1
      ,cv.text_2                            = v.text_2
      ,cv.text_3                            = v.text_3
      ,cv.text_4                            = v.text_4
      ,cv.text_5                            = v.text_5
      ,cv.text_6                            = v.text_6
      ,cv.text_7                            = v.text_7
      ,cv.text_8                            = v.text_8
      ,cv.text_9                            = v.text_9
      ,cv.text_10                           = v.text_10
      ,cv.value_1                           = v.value_1
      ,cv.value_2                           = v.value_2
      ,cv.value_3                           = v.value_3
      ,cv.value_4                           = v.value_4
      ,cv.value_5                           = v.value_5
      ,cv.value_6                           = v.value_6
      ,cv.value_7                           = v.value_7
      ,cv.value_8                           = v.value_8
      ,cv.value_9                           = v.value_9
      ,cv.value_10                          = v.value_10
      ,cv.date_1                            = v.date_1
      ,cv.date_2                            = v.date_2
      ,cv.date_3                            = v.date_3
      ,cv.date_4                            = v.date_4
      ,cv.date_5                            = v.date_5
      ,cv.date_6                            = v.date_6
      ,cv.date_7                            = v.date_7
      ,cv.date_8                            = v.date_8
      ,cv.date_9                            = v.date_9
      ,cv.date_10                           = v.date_10
      ,cv.erp_document_ind                  = v.erp_document_ind
      ,cv.hold_final_when_acl_ind           = v.hold_final_when_acl_ind
      ,cv.single_parcel_doc_ind             = v.single_parcel_doc_ind
      ,LAST_UPDATED_BY                      = p_user
    WHERE object_id = lv2_object_id
          AND daytime = v.daytime;

    -- ** Custom 4-eyes approval logic omitted. This is handled in InsNewDocSetup. ** --

    -- Updating ACL for if ringfencing is enabled
    IF (NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('CONTRACT_DOC'),'N') = 'Y') THEN
       EcDp_Acl.RefreshObject(lv2_object_id, 'CONTRACT_DOC', 'INSERTING');
    END IF;

END LOOP;

     RETURN lv2_object_id;

END InsNewDocSetupCopy;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : validateContractCompany
-- Description    : Validates wether the assigned customer or vendor is the same as the contracts company
--                  On SALE and TA INCOME contracts, company must be the same as vendor.
--                  On PURCHASE and TA COST contracts, company must be the same as customer.
--
-- Preconditions  : Company code must be set on the current contract.
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: ecdp_contract_attribute.getAttributeString
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateContractCompany(
   p_contract_id VARCHAR2,
   p_daytime     DATE,
   p_party_id    VARCHAR2,
   p_party_role  VARCHAR2
)
--</EC-DOC>
IS

lv2_contract_company_id VARCHAR(32);
lv2_contract_financial_code VARCHAR(32);
lv2_self_company_id VARCHAR(32);

BEGIN

    IF p_party_role IS NULL THEN
       Raise_Application_Error(-20000,'Can not validate Contract Company. Party Role is missing.');
    ELSIF p_contract_id IS NULL THEN
       Raise_Application_Error(-20000,'Can not validate Contract Company. Contract_ID is missing.');
    END IF;

    -- Get the company code for this contract
    lv2_contract_company_id := ec_contract_version.company_id(p_contract_id, p_daytime, '<=');

    -- Get the financial code for this contract
    lv2_contract_financial_code := ec_contract_version.financial_code(p_contract_id, p_daytime, '<=');

    -- Get Self Vendor/Customer
    lv2_self_company_id := ec_company.company_id(p_party_id);

    /* OHA MVS IF (p_party_role = 'VENDOR') THEN -- Vendor
       IF lv2_contract_financial_code IN ('SALE', 'TA_INCOME') THEN
          IF nvl(lv2_self_company_id,'x') <> nvl(lv2_contract_company_id,'x') THEN
             Raise_Application_Error(-20000,'Can not validate Contract Company. Selected Vendor must be Contract Company on Sale or Tariff Income contracts.');
          END IF;
       END IF;

    ELS*/IF (p_party_role = 'CUSTOMER') THEN -- Customer
       IF lv2_contract_financial_code IN ('PURCHASE', 'TA_COST') THEN
          IF nvl(lv2_self_company_id,'x') <> nvl(lv2_contract_company_id,'x') THEN
             Raise_Application_Error(-20000,'Can not validate Contract Company. Selected Customer must be Contract Company on Purchase or Tariff Cost contracts.');
          END IF;
       END IF;
    END IF;

END validateContractCompany;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : SetIsSDistributedFlag
-- Description    : Set is distributed flag based on value from dist class
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
PROCEDURE SetIsSDistributedFlag (
            p_code                                  VARCHAR2,
            p_daytime                               DATE,
            p_dist_type                             VARCHAR2,
            p_user                                  VARCHAR2)
--<EC-DOC>


IS

BEGIN

IF (p_dist_type = 'OBJECT') THEN
  UPDATE contract_version
     SET use_distribution_ind = 'N', last_updated_by = p_user
   WHERE object_id IN
         (SELECT object_id FROM contract WHERE object_code = p_code)
     AND daytime = p_daytime;
END IF;

IF (p_dist_type = 'OBJECT_LIST') THEN
  UPDATE contract_version
     SET use_distribution_ind = 'Y', last_updated_by = p_user
   WHERE object_id IN
         (SELECT object_id FROM contract WHERE object_code = p_code)
     AND daytime = p_daytime;
END IF;

-- 4-eyes check is commented out because this update is for some reason run each time contract is updated.
-- This screen update will trigger approval through DAO and viewlayer logic.

END SetIsSDistributedFlag;









--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : GetDocumentsStatus
-- Description    : If the Document Status (attribute on the document) = Final for all documents for the contract in question,
--                  then the Status should be Final. If one or several documents have Document Status = Accrual,
--                  then the Status should be Accrual.
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
FUNCTION GetDocumentsStatus(p_object_id VARCHAR2)
RETURN VARCHAR2
--<EC-DOC>

IS

lv2_status     VARCHAR2(32) := 'FINAL';

CURSOR c_doc (cp_object_id VARCHAR2) IS
SELECT c.status_code FROM cont_document c WHERE c.object_id = cp_object_id;

BEGIN

FOR c_val IN c_doc(p_object_id) LOOP

    IF nvl(c_val.status_code,'ACCRUAL') = 'ACCRUAL' THEN
       lv2_status := 'ACCRUAL';
    END IF;


END LOOP;

RETURN lv2_status;

END GetDocumentsStatus;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getBaseDate
-- Description    :
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
FUNCTION getBaseDate(
   p_object_id VARCHAR2, --contract id
   p_document_key VARCHAR2, --document key
   p_daytime DATE,
   p_date_type VARCHAR2, -- 'DOC_RECEIVED OR PAYMENT',
   p_contract_doc_id VARCHAR2 default NULL, --contract doc id, can be Null during updating dates
   p_vendor_id VARCHAR2 default NULL
)
--</EC-DOC>
RETURN DATE

IS

lv2_base_code VARCHAR(32);
ld_return_val DATE := NULL;
no_calendar EXCEPTION;

--get the maximum transaction date
CURSOR c_trans_max IS
SELECT max(transaction_date) transaction_date
FROM cont_transaction
WHERE document_key = p_document_key;

--get the minimum transaction date
CURSOR c_trans_min IS
SELECT min(transaction_date) transaction_date
FROM cont_transaction
WHERE document_key = p_document_key;

--get the maximum delivery_date_completed
CURSOR c_ddcompleted_max IS
SELECT max(delivery_date_completed) delivery_date_completed
FROM cont_transaction
WHERE document_key = p_document_key;

--get the minimum delivery_date_completed
CURSOR c_ddcompleted_min IS
SELECT min(delivery_date_completed) delivery_date_completed
FROM cont_transaction
WHERE document_key = p_document_key;

--get the maximum delivery_date_commenced
CURSOR c_ddcommenced_max IS
SELECT max(delivery_date_commenced) delivery_date_commenced
FROM cont_transaction
WHERE document_key = p_document_key;

--get the minimum delivery_date_commenced
CURSOR c_ddcommenced_min IS
SELECT min(delivery_date_commenced) delivery_date_commenced
FROM cont_transaction
WHERE document_key = p_document_key;

--get the maximum loading_date_completed
CURSOR c_ldcompleted_max IS
SELECT max(loading_date_completed) loading_date_completed
FROM cont_transaction
WHERE document_key = p_document_key;

--get the minimum loading_date_completed
CURSOR c_ldcompleted_min IS
SELECT min(loading_date_completed) loading_date_completed
FROM cont_transaction
WHERE document_key = p_document_key;

--get the maximum loading_date_commenced
CURSOR c_ldcommenced_max IS
SELECT max(loading_date_commenced) loading_date_commenced
FROM cont_transaction
WHERE document_key = p_document_key;

--get the minimum delivery_date_commenced
CURSOR c_ldcommenced_min IS
SELECT min(loading_date_commenced) loading_date_commenced
FROM cont_transaction
WHERE document_key = p_document_key;

--get the maxium supply_date_from
CURSOR c_sdfrom_max IS
SELECT max(supply_from_date) supply_from_date
FROM cont_transaction
WHERE document_key = p_document_key;

--get the minimum supply_date_from
CURSOR c_sdfrom_min IS
SELECT min(supply_from_date) supply_from_date
FROM cont_transaction
WHERE document_key = p_document_key;

--get the maxium supply_date_to
CURSOR c_sdto_max IS
SELECT max(supply_to_date) supply_to_date
FROM cont_transaction
WHERE document_key = p_document_key;

--get the minimum supply_date_to
CURSOR c_sdto_min IS
SELECT min(supply_to_date) supply_to_date
FROM cont_transaction
WHERE document_key = p_document_key;

--get the minimum bl_date
CURSOR c_bld_min IS
SELECT min(bl_date) bl_date
FROM cont_transaction
WHERE document_key = p_document_key;

--get the maximum bl_date
CURSOR c_bld_max IS
SELECT max(bl_date) bl_date
FROM cont_transaction
WHERE document_key = p_document_key;

--get the maxium price date
CURSOR c_pricedate_max IS
SELECT max(price_date) price_date
FROM cont_transaction
WHERE document_key = p_document_key;

--get the minimum price date
CURSOR c_pricedate_min IS
SELECT min(price_date) price_date
FROM cont_transaction
WHERE document_key = p_document_key;

BEGIN

    --base date is based on base_code, use base_code to check against transaction's date e.g loading/completed, calendar...

   -- when inserting, daytime and contract_doc_id will be not NULL
   IF p_contract_doc_id is not NULL THEN

     IF    p_date_type = 'DOC_RECEIVED' THEN
            lv2_base_code := ec_contract_doc_version.doc_received_base_code(p_contract_doc_id, p_daytime, '<=');
     ELSIF p_date_type = 'PAYMENT' THEN
            lv2_base_code := ec_contract_doc_company.payment_term_base_code(p_contract_doc_id, p_vendor_id, 'VENDOR', p_daytime, '<=');
     END IF;

   ELSE

     IF    p_date_type = 'DOC_RECEIVED' THEN
            lv2_base_code := ec_cont_document.doc_received_base_code(p_document_key);
     ELSIF p_date_type = 'PAYMENT' THEN
            lv2_base_code := ec_cont_document_company.payment_term_base_code(p_document_key, p_vendor_id);
     END IF;

   END IF;


    IF   lv2_base_code = 'POSD_FIRST'  THEN
    --FIRST_TRANSACTION_DATE
        FOR curRec IN c_trans_min LOOP
            ld_return_val := curRec.transaction_date;
        END LOOP;

    ELSIF lv2_base_code = 'POSD_LAST' THEN
    --LAST_TRANSACTION_DATE
        FOR curRec IN c_trans_max LOOP
            ld_return_val := curRec.transaction_date;
        END LOOP;

    ELSIF lv2_base_code = 'LOAD_COMM_FIRST' THEN
    --FIRST_LOADING_COMMENCED_DATE
        FOR curRec IN c_ldcommenced_min LOOP
            ld_return_val := curRec.Loading_Date_Commenced;
        END LOOP;

    ELSIF lv2_base_code = 'LOAD_COMM_LAST' THEN
    --LAST_LOADING_COMMENCED_DATE
        FOR curRec IN c_ldcommenced_max LOOP
            ld_return_val := curRec.Loading_Date_Commenced;
        END LOOP;

    ELSIF lv2_base_code = 'LOAD_COMP_FIRST' THEN
    --FIRST_LOADING_COMPLETED_DATE
        FOR curRec IN c_ldcompleted_min LOOP
            ld_return_val := curRec.Loading_Date_Completed;
        END LOOP;

    ELSIF lv2_base_code = 'LOAD_COMP_LAST' THEN
    --LAST_LOADING_COMPLETED_DATE
        FOR curRec IN c_ldcompleted_max LOOP
            ld_return_val := curRec.Loading_Date_Completed;
        END LOOP;

    ELSIF lv2_base_code = 'DIS_COMM_FIRST' THEN
    --FIRST_DISCHARGE_COMMENCED_DATE
        FOR curRec IN c_ddcommenced_min LOOP
            ld_return_val := curRec.Delivery_Date_Commenced;
        END LOOP;

    ELSIF lv2_base_code = 'DIS_COMM_LAST' THEN
    --LAST_DISCHARGE_COMMENCED_DATE
        FOR curRec IN c_ddcommenced_max LOOP
            ld_return_val := curRec.Delivery_Date_Commenced;
        END LOOP;

    ELSIF lv2_base_code = 'DIS_COMP_FIRST' THEN
    --FIRST_DISCHARGE_COMPLETED_DATE
        FOR curRec IN c_ddcompleted_min LOOP
            ld_return_val := curRec.Delivery_Date_Completed;
        END LOOP;

    ELSIF lv2_base_code = 'DIS_COMP_LAST'  THEN
    --LAST_DISCHARGE_COMPLETED_DATE
        FOR curRec IN c_ddcompleted_max LOOP
            ld_return_val := curRec.Delivery_Date_Completed;
        END LOOP;

    ELSIF lv2_base_code = 'SUPPLY_FROM_FIRST' THEN
      --FIRST_SUPPLY_FROM_DATE
          FOR curRec IN c_sdfrom_min LOOP
              ld_return_val := curRec.Supply_From_Date;
          END LOOP;

    ELSIF lv2_base_code = 'SUPPLY_FROM_LAST' THEN
      --LAST_SUPPLY_FROM_DATE
          FOR curRec IN c_sdfrom_max LOOP
              ld_return_val := curRec.Supply_From_Date;
          END LOOP;

    ELSIF lv2_base_code = 'SUPPLY_TO_FIRST' THEN
      --FIRST_SUPPLY_TO_DATE
          FOR curRec IN c_sdto_min LOOP
              ld_return_val := curRec.Supply_To_Date;
          END LOOP;

    ELSIF lv2_base_code = 'SUPPLY_TO_LAST' THEN
      --LAST_SUPPLY_TO_DATE
          FOR curRec IN c_sdto_max LOOP
              ld_return_val := curRec.Supply_To_Date;
          END LOOP;

    ELSIF lv2_base_code = 'BL_DATE_FIRST' THEN
       --FIRST_BL_DATE
          FOR curRec IN c_bld_min LOOP
              ld_return_val := curRec.Bl_Date;
          END LOOP;

    ELSIF lv2_base_code = 'BL_DATE_LAST' THEN
       --LAST_BL_DATE
          FOR curRec IN c_bld_max LOOP
              ld_return_val := curRec.Bl_Date;
          END LOOP;

    ELSIF lv2_base_code = 'PRICE_DATE_FIRST' THEN
      --FIRST_PRICE_DATE
          FOR curRec IN c_pricedate_min LOOP
              ld_return_val := curRec.Price_Date;
          END LOOP;

    ELSIF lv2_base_code = 'PRICE_DATE_LAST' THEN
      --LAST_PRICE_DATE
          FOR curRec IN c_pricedate_max LOOP
              ld_return_val := curRec.Price_Date;
          END LOOP;

    ELSIF lv2_base_code = 'SYSDATE' THEN
           ld_return_val := trunc(Ecdp_Timestamp.getCurrentSysdate,'dd');

    ELSIF lv2_base_code = 'DOC_RECEIVED_DATE' THEN

        IF p_contract_doc_id is not NULL THEN
           ld_return_val := getDueDate(p_object_id, p_document_key, p_daytime, 'DOC_RECEIVED', p_contract_doc_id);
        ELSE
            ld_return_val := ec_cont_document.document_received_date(p_document_key);
        END IF;

    ELSIF lv2_base_code = 'DOCUMENT_DATE' THEN -- ie INVOICE_DATE


        IF  p_contract_doc_id is not NULL THEN
           ld_return_val := getDocDate(p_object_id, p_document_key, p_daytime, p_daytime, p_contract_doc_id); -- TODO: Set document date
        ELSE
            ld_return_val := ec_cont_document.document_date(p_document_key);
        END IF;

    ELSIF lv2_base_code = 'MANUAL' THEN -- ie INVOICE_DATE

         IF  p_contract_doc_id is not NULL THEN -- return null and let the user key in later
             ld_return_val := NULL;
         ELSE  --updating, use back the inserted date
            IF    p_date_type = 'DOC_RECEIVED' THEN
                ld_return_val := ec_cont_document.doc_received_base_date(p_document_key);
            ELSIF p_date_type = 'PAYMENT' THEN
                ld_return_val := ec_cont_document.payment_due_base_date(p_document_key);
            END IF;
        END IF;


    ELSE -- ie No Date

        ld_return_val := NULL;

    END IF;

    --by using the term method to determine to actual date
    RETURN ld_return_val;

EXCEPTION

    WHEN no_calendar THEN

        Raise_Application_Error(-20000,'No Calendar connected to contract '||Ec_Contract.object_code(p_object_id)||' - '||Ec_Contract_Version.name(p_object_id,Ecdp_Timestamp.getCurrentSysdate,'<='));

END getBaseDate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDocDate
-- Description    :
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
FUNCTION getDocDate(
   p_contract_id VARCHAR2,
   p_document_key VARCHAR2,
   p_daytime DATE,
   p_document_date DATE,
   p_contract_doc_id VARCHAR2 DEFAULT NULL -- can be Null during updating dates
)
--</EC-DOC>
RETURN DATE

IS

  lv2_calendar_coll_id VARCHAR2(32);
  lv2_term_id VARCHAR2(32);
  lv2_method VARCHAR2(32);
  ln_offset NUMBER;
  ln_base_offset NUMBER;
  ld_return_val DATE;
  ld_doc_date DATE;
  ld_contract_start_date DATE := ec_contract.start_date(p_contract_id);
  ld_contract_doc_start_date DATE := ec_contract_doc.start_date(p_contract_doc_id);
  ld_sysdate DATE := trunc(Ecdp_Timestamp.getCurrentSysdate(), 'DD');

  no_calendar EXCEPTION;

--get the maximum transaction date
CURSOR c_trans_max IS
SELECT max(transaction_date) transaction_date
FROM cont_transaction
  WHERE document_key = p_document_key;

--get the minimum transaction date
CURSOR c_trans_min IS
SELECT min(transaction_date) transaction_date
FROM cont_transaction
  WHERE document_key = p_document_key;

--get the maximum delivery_date_completed
CURSOR c_ddcompleted_max IS
SELECT max(delivery_date_completed) delivery_date_completed
FROM cont_transaction
  WHERE document_key = p_document_key;

--get the minimum delivery_date_completed
CURSOR c_ddcompleted_min IS
SELECT min(delivery_date_completed) delivery_date_completed
FROM cont_transaction
  WHERE document_key = p_document_key;

--get the maximum delivery_date_commenced
CURSOR c_ddcommenced_max IS
SELECT max(delivery_date_commenced) delivery_date_commenced
FROM cont_transaction
  WHERE document_key = p_document_key;

--get the minimum delivery_date_commenced
CURSOR c_ddcommenced_min IS
SELECT min(delivery_date_commenced) delivery_date_commenced
FROM cont_transaction
  WHERE document_key = p_document_key;

--get the maximum loading_date_completed
CURSOR c_ldcompleted_max IS
SELECT max(loading_date_completed) loading_date_completed
FROM cont_transaction
  WHERE document_key = p_document_key;

--get the minimum loading_date_completed
CURSOR c_ldcompleted_min IS
SELECT min(loading_date_completed) loading_date_completed
FROM cont_transaction
  WHERE document_key = p_document_key;

--get the maximum loading_date_commenced
CURSOR c_ldcommenced_max IS
SELECT max(loading_date_commenced) loading_date_commenced
FROM cont_transaction
  WHERE document_key = p_document_key;

--get the minimum delivery_date_commenced
CURSOR c_ldcommenced_min IS
SELECT min(loading_date_commenced) loading_date_commenced
FROM cont_transaction
  WHERE document_key = p_document_key;

--get the maxium supply_date_from
CURSOR c_sdfrom_max IS
SELECT max(supply_from_date) supply_from_date
FROM cont_transaction
  WHERE document_key = p_document_key;

--get the minimum supply_date_from
CURSOR c_sdfrom_min IS
SELECT min(supply_from_date) supply_from_date
FROM cont_transaction
  WHERE document_key = p_document_key;

--get the maxium supply_date_to
CURSOR c_sdto_max IS
SELECT max(supply_to_date) supply_to_date
FROM cont_transaction
  WHERE document_key = p_document_key;

--get the minimum supply_date_to
CURSOR c_sdto_min IS
SELECT min(supply_to_date) supply_to_date
FROM cont_transaction
  WHERE document_key = p_document_key;

 CURSOR c_bld_min IS
    SELECT MIN(bl_date) BL_DATE
      FROM cont_transaction
     WHERE document_key = p_document_key;

  CURSOR c_bld_max IS
    SELECT MAX(bl_date) BL_DATE
      FROM cont_transaction
     WHERE document_key = p_document_key;

BEGIN


    -- INSERTING:
    IF  p_contract_doc_id is not NULL THEN
       lv2_term_id := ec_contract_doc_version.doc_date_term_id(p_contract_doc_id, p_daytime, '<=');
       lv2_calendar_coll_id := ec_contract_doc_version.doc_date_calendar_coll_id(p_contract_doc_id, p_daytime, '<=');

    -- UPDATING:
    ELSE
       lv2_term_id := ec_cont_document.doc_date_term_id(p_document_key);
       lv2_calendar_coll_id := ec_cont_document.doc_date_calendar_coll_id(p_document_key);

    END IF;


     lv2_method  :=  ec_doc_date_term_version.doc_date_term_method(lv2_term_id, p_daytime, '<=');
     ln_offset :=  ec_doc_date_term_version.offset(lv2_term_id, p_daytime, '<=');

    IF  lv2_method = 'POSD_FIRST' THEN      --FIRST_TRANSACTION_DATE
          FOR curRec IN c_trans_min LOOP
              ld_return_val := curRec.transaction_date;
          END LOOP;

     ELSIF lv2_method = 'POSD_LAST' THEN      --LAST_TRANSACTION_DATE
          FOR curRec IN c_trans_max LOOP
              ld_return_val := curRec.transaction_date;
          END LOOP;

     ELSIF lv2_method = 'LOAD_COMM_FIRST' THEN      --FIRST_LOADING_COMMENCED_DATE
          FOR curRec IN c_ldcommenced_min LOOP
              ld_return_val := curRec.Loading_Date_Commenced;
          END LOOP;

     ELSIF lv2_method = 'LOAD_COMM_LAST' THEN      --LAST_LOADING_COMMENCED_DATE
          FOR curRec IN c_ldcommenced_max LOOP
              ld_return_val := curRec.Loading_Date_Commenced;
          END LOOP;

     ELSIF lv2_method = 'LOAD_COMP_FIRST' THEN      --FIRST_LOADING_COMPLETED_DATE
          FOR curRec IN c_ldcompleted_min LOOP
              ld_return_val := curRec.Loading_Date_Completed;
          END LOOP;

     ELSIF lv2_method = 'LOAD_COMP_LAST' THEN      --LAST_LOADING_COMPLETED_DATE
          FOR curRec IN c_ldcompleted_max LOOP
              ld_return_val := curRec.Loading_Date_Completed;
          END LOOP;

     ELSIF lv2_method = 'DIS_COMM_FIRST' THEN      --FIRST_DISCHARGE_COMMENCED_DATE
          FOR curRec IN c_ddcommenced_min LOOP
              ld_return_val := curRec.Delivery_Date_Commenced;
          END LOOP;

     ELSIF lv2_method = 'DIS_COMM_LAST' THEN      --LAST_DISCHARGE_COMMENCED_DATE
          FOR curRec IN c_ddcommenced_max LOOP
              ld_return_val := curRec.Delivery_Date_Commenced;
          END LOOP;

     ELSIF lv2_method = 'DIS_COMP_FIRST' THEN      --FIRST_DISCHARGE_COMPLETED_DATE
          FOR curRec IN c_ddcompleted_min LOOP
              ld_return_val := curRec.Delivery_Date_Completed;
          END LOOP;

     ELSIF lv2_method = 'DIS_COMP_LAST' THEN      --LAST_DISCHARGE_COMPLETED_DATE
          FOR curRec IN c_ddcompleted_max LOOP
              ld_return_val := curRec.Delivery_Date_Completed;
          END LOOP;

     ELSIF lv2_method = 'SUPPLY_FROM_FIRST' THEN      --FIRST_SUPPLY_FROM_DATE
          FOR curRec IN c_sdfrom_max LOOP
              ld_return_val := curRec.Supply_From_Date;
          END LOOP;

     ELSIF lv2_method = 'SUPPLY_FROM_LAST' THEN      --LAST_SUPPLY_FROM_DATE
          FOR curRec IN c_sdfrom_min LOOP
              ld_return_val := curRec.Supply_From_Date;
          END LOOP;

     ELSIF lv2_method = 'SUPPLY_TO_FIRST' THEN      --FIRST_SUPPLY_TO_DATE
          FOR curRec IN c_sdto_max LOOP
              ld_return_val := curRec.Supply_To_Date;
          END LOOP;

     ELSIF lv2_method = 'SUPPLY_TO_LAST' THEN      --LAST_SUPPLY_TO_DATE
          FOR curRec IN c_sdto_min LOOP
              ld_return_val := curRec.Supply_To_Date;
          END LOOP;

     ELSIF lv2_method = 'BL_DATE_FIRST' THEN      --BL_DATE_FIRST
          FOR curRec IN c_bld_min LOOP
              ld_return_val := curRec.Bl_Date;
          END LOOP;

     ELSIF lv2_method = 'BL_DATE_LAST' THEN      --BL_DATE_LAST
           FOR curRec IN c_bld_max LOOP
              ld_return_val := curRec.Bl_Date;
          END LOOP;

     ELSIF lv2_method = 'SYSDATE' THEN

           ld_return_val := ld_sysdate;

     END IF;

     -- INSERTING:
     IF p_contract_doc_id IS NOT NULL THEN
        ld_return_val := ecdp_calendar.getCollActualDate(lv2_calendar_coll_id, p_document_date, ln_offset, lv2_method);

     -- UPDATING:
     ELSE
        ld_return_val := NVL(ld_return_val, p_document_date);
     END IF;

     -- Apply fallback to get a valid doc date
     ld_return_val := getValidDocDaytime(p_contract_id, p_contract_doc_id, ld_return_val);


     RETURN ld_return_val;


EXCEPTION

    WHEN no_calendar THEN

        Raise_Application_Error(-20000,'No Calendar connected to contract '||Ec_Contract.object_code(p_contract_id)||' - '||Ec_Contract_Version.name(p_contract_id,Ecdp_Timestamp.getCurrentSysdate(),'<='));

END getDocDate;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION getValidDocDaytime(p_contract_id VARCHAR2,
                            p_contract_doc_id VARCHAR2,
                            p_daytime DATE)
RETURN DATE
IS

  ld_return_val DATE;
  ld_contract_start_date DATE := ec_contract.start_date(p_contract_id);
  ld_contract_doc_start_date DATE := ec_contract_doc.start_date(p_contract_id);

BEGIN

     -- Fallbacks
     -- Set doc date to contract start date if contract start date is higher than the determined value
     ld_return_val := CASE WHEN ld_contract_start_date > p_daytime THEN ld_contract_start_date ELSE p_daytime END;

     -- Set Doc Date to contract_doc_start_date if contract_doc_start_date is higher than contract_start_date
     IF ld_contract_doc_start_date IS NOT NULL THEN
        ld_return_val := CASE WHEN ld_contract_doc_start_date > ld_return_val THEN ld_contract_doc_start_date ELSE ld_return_val END;
     END IF;

     RETURN ld_return_val;

END getValidDocDaytime;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION getDueDate(
   p_object_id VARCHAR2, --contract id
   p_document_key VARCHAR2, --document key
   p_daytime DATE, -- document date
   p_date_type VARCHAR2 default 'DOC_RECEIVED',
   p_contract_doc_id VARCHAR2 default NULL, --contract doc id, can be Null during updating dates
   p_vendor_id VARCHAR2 default NULL
)

RETURN DATE

IS

lv2_method VARCHAR2(32);
lv2_term_id VARCHAR2(32);
lv2_calendar_coll_id VARCHAR2(32);
ln_offset NUMBER;
ld_base_date DATE;
ld_return_val DATE;

no_calendar EXCEPTION;

BEGIN

 --when inserting, daytime will be provide and it is not NULL
 IF  p_contract_doc_id is not NULL THEN

    IF    p_date_type = 'DOC_RECEIVED' THEN

       lv2_term_id := ec_contract_doc_version.doc_received_term_id(p_contract_doc_id, p_daytime, '<=');
       lv2_calendar_coll_id := ec_contract_doc_version.doc_rec_calendar_coll_id(p_contract_doc_id, p_daytime, '<=');
       ld_base_date := getBaseDate(p_object_id, p_document_key, p_daytime, 'DOC_RECEIVED', p_contract_doc_id);

       lv2_method := ec_doc_rec_term_version.doc_received_term_method(lv2_term_id, p_daytime, '<=');
       ln_offset  := ec_doc_rec_term_version.offset(lv2_term_id, p_daytime, '<=');

    ELSIF p_date_type = 'PAYMENT' THEN
       lv2_term_id := ec_contract_doc_company.payment_term_id(p_contract_doc_id, p_vendor_id, 'VENDOR', p_daytime, '<=');
       lv2_calendar_coll_id := ec_contract_doc_company.payment_calendar_coll_id(p_contract_doc_id, p_vendor_id, 'VENDOR', p_daytime, '<=');
       ld_base_date := getBaseDate(p_object_id, p_document_key, p_daytime, 'PAYMENT', p_contract_doc_id, p_vendor_id);

       lv2_method := ec_payment_term_version.payment_term_method(lv2_term_id, p_daytime, '<=');
       ln_offset  := ec_payment_term_version.day_value(lv2_term_id, p_daytime, '<=');

    END IF;

  ELSE -- when updating, it is only depending on document key

     IF    p_date_type = 'DOC_RECEIVED' THEN

       lv2_term_id := ec_cont_document.doc_received_term_id(p_document_key);
       lv2_calendar_coll_id := ec_cont_document.doc_rec_calendar_coll_id(p_document_key);
       ld_base_date := ec_cont_document.doc_received_base_date(p_document_key);

       lv2_method := ec_doc_rec_term_version.doc_received_term_method(lv2_term_id, p_daytime, '<=');
       ln_offset  := ec_doc_rec_term_version.offset(lv2_term_id, p_daytime, '<=');

    ELSIF p_date_type = 'PAYMENT' THEN

       lv2_term_id := ec_cont_document_company.payment_term_id(p_document_key, p_vendor_id);
       lv2_calendar_coll_id := ec_cont_document_company.payment_calendar_coll_id(p_document_key, p_vendor_id);
       ld_base_date := ec_cont_document_company.payment_due_base_date(p_document_key, p_vendor_id);
       lv2_method := ec_payment_term_version.payment_term_method(lv2_term_id, p_daytime, '<=');
       ln_offset  := ec_payment_term_version.day_value(lv2_term_id, p_daytime, '<=');

    END IF;

  END IF;

     IF    lv2_method = 'MANUAL' THEN

        IF  p_contract_doc_id is not NULL THEN --return null and let the user key in later
             ld_return_val := NULL;

        ELSE --updating, use back the inserted date

            IF    p_date_type = 'DOC_RECEIVED' THEN
               ld_return_val := ec_cont_document.document_received_date(p_document_key);
            ELSIF p_date_type = 'PAYMENT' THEN
               ld_return_val := ec_cont_document_company.pay_date(p_document_key, p_vendor_id);
            END IF;

        END IF;

     ELSE

         ld_return_val := ecdp_calendar.getCollActualDate(lv2_calendar_coll_id, ld_base_date, ln_offset, lv2_method);

     END IF;

     RETURN ld_return_val;


EXCEPTION

    WHEN no_calendar THEN

        Raise_Application_Error(-20000,'No Calendar connected to contract '||Ec_Contract.object_code(p_object_id)||' - '||Ec_Contract_Version.name(p_object_id,Ecdp_Timestamp.getCurrentSysdate,'<='));

END getDueDate;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  updateAllDocumentDates
-- Description    :
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
PROCEDURE updateAllDocumentDates(p_object_id     VARCHAR2, --contract id
   p_document_key VARCHAR2, --document key
                                 p_daytime       DATE, -- daytime
                                 p_document_date DATE, -- document date
   p_user VARCHAR2, --curent login user
   p_level NUMBER default 6--level to indicates which dates need to be updated
)
--</EC-DOC>
IS
   ld_doc_date               DATE;
   ld_daytime                DATE;
   ld_contract_end_date      DATE;
   ld_contract_doc_end_date  DATE;
   ld_doc_received_base_date DATE;
   ld_document_received_date DATE;
   ld_payment_due_base_date  DATE;
   ld_pay_date               DATE;
   ld_doc_forex_base_date    DATE;
   lv2_company_id            VARCHAR2(32);
   lv2_fin_code              VARCHAR2(32) := ec_contract_version.financial_code(p_object_id, p_daytime, '<=');
	 ln_level                  NUMBER;
   lb_contract_valid         BOOLEAN := FALSE;
   lv_message                VARCHAR2(1024);
   lv_curr_from_to           VARCHAR2(1024);

CURSOR c_trans_pm(cp_document_key VARCHAR2) IS
SELECT transaction_key, pricing_currency_code, ex_pricing_memo_id, ex_pricing_memo_ts
  FROM cont_transaction t
 WHERE document_key = cp_document_key
   AND t.ex_pricing_memo_dbc = 'DOCUMENT_DATE'
   AND t.reversal_ind <> 'Y';

CURSOR c_trans_pb(cp_document_key VARCHAR2) IS
SELECT transaction_key, pricing_currency_code, ex_pricing_booking_id, ex_pricing_booking_ts
  FROM cont_transaction t
 WHERE document_key = cp_document_key
   AND t.ex_pricing_booking_dbc = 'DOCUMENT_DATE'
   AND t.reversal_ind <> 'Y';

CURSOR c_trans_bl(cp_document_key VARCHAR2) IS
SELECT transaction_key, pricing_currency_code, ex_booking_local_id, ex_booking_local_ts
  FROM cont_transaction t
 WHERE document_key = cp_document_key
   AND t.ex_booking_local_dbc = 'DOCUMENT_DATE'
   AND t.reversal_ind <> 'Y';

CURSOR c_trans_bg(cp_document_key VARCHAR2) IS
SELECT transaction_key, pricing_currency_code, ex_booking_group_id, ex_booking_group_ts
  FROM cont_transaction t
 WHERE document_key = cp_document_key
   AND t.ex_booking_group_dbc = 'DOCUMENT_DATE'
   AND t.reversal_ind <> 'Y';

CURSOR c_cont_doc_comp(cp_document_key VARCHAR2) IS
SELECT company_id
  FROM cont_document_company
 WHERE document_key = p_document_key
   AND company_role = 'VENDOR';

lrec_cont_document cont_document%ROWTYPE := ec_cont_document.row_by_pk(p_document_key);

BEGIN

      -- If level is 6 or higher: update document date based on document date terms
      IF p_level > 5 THEN
         ld_doc_date := getDocDate(p_object_id, p_document_key, p_daytime, p_document_date);
      ELSE
         -- If level is lower than 6: use the keyed in date as document date, and disregard document date terms.
         ld_doc_date := p_document_date;
      END IF;

      -- Get valid daytime based on document date
      ld_daytime := EcDp_Document.GetDocumentDaytime(p_object_id, lrec_cont_document.contract_doc_id, ld_doc_date);


      IF p_level >= 5 THEN

        UPDATE cont_document
           SET document_date = ld_doc_date,
               daytime = ld_daytime
         WHERE document_key = p_document_key;

      END IF;



      --UPDATE DOCUMENT RECEIVED BASE DATE
      IF p_level > 4 THEN
        ld_doc_received_base_date := EcDp_Contract_Setup.getBaseDate(p_object_id, p_document_key, p_daytime, 'DOC_RECEIVED');

        UPDATE cont_document
        SET doc_received_base_date = ld_doc_received_base_date
         WHERE document_key = p_document_key;

      END IF;
      --UPDATE DOCUMENT RECEIVED DATE
      IF p_level > 3 THEN
        ld_document_received_date := EcDp_Contract_Setup.getDueDate(p_object_id, p_document_key, p_daytime, 'DOC_RECEIVED');

        UPDATE cont_document
        SET document_received_date = ld_document_received_date
         WHERE document_key = p_document_key;

      END IF;
      --UPDATE PAYMENT DUE DATE
      IF p_level > 2 THEN

        -- Determine Vendor for this document, for getting correct payment info
        lv2_company_id := EcDp_Document.GetDocumentVendor(p_object_id, p_document_key, p_daytime, lv2_fin_code);

        ld_payment_due_base_date := EcDp_Contract_Setup.getBaseDate(p_object_id, p_document_key, p_daytime, 'PAYMENT', NULL, lv2_company_id);

        UPDATE cont_document
        SET payment_due_base_date = ld_payment_due_base_date
        WHERE document_key = p_document_key;


        FOR r_comp IN c_cont_doc_comp(p_document_key) LOOP
            ld_payment_due_base_date := EcDp_Contract_Setup.getBaseDate(p_object_id, p_document_key, p_daytime, 'PAYMENT', NULL, r_comp.company_id);

            UPDATE cont_document_company
            SET payment_due_base_date = ld_payment_due_base_date
            WHERE document_key = p_document_key
            AND company_id = r_comp.company_id
            AND company_role = 'VENDOR';
        END LOOP;

      END IF;

      lv2_company_id := '';

      --UPDATE PAY DATE
      IF p_level > 1 THEN
        -- Determine Vendor for this document, for getting correct payment info
        lv2_company_id := EcDp_Document.GetDocumentVendor(p_object_id, p_document_key, p_daytime, lv2_fin_code);

        ld_pay_date := EcDp_Contract_Setup.getDueDate(p_object_id, p_document_key, p_daytime, 'PAYMENT', NULL, lv2_company_id);

        UPDATE cont_document
        SET pay_date = ld_pay_date
        WHERE document_key = p_document_key;


        --UPDATE USER
        UPDATE cont_document
        SET last_updated_by = p_user
        WHERE document_key = p_document_key;

        FOR r_comp_2 IN c_cont_doc_comp(p_document_key) LOOP
            ld_pay_date := EcDp_Contract_Setup.getDueDate(p_object_id, p_document_key, p_daytime, 'PAYMENT', NULL, r_comp_2.company_id);

            UPDATE cont_document_company
            SET pay_date = ld_pay_date
            WHERE document_key = p_document_key
            AND company_id = r_comp_2.company_id
            AND company_role = 'VENDOR';
        END LOOP;

        UPDATE cont_document_company
        SET last_updated_by = p_user
        WHERE document_key = p_document_key;

        -- Update Interest Line Items with Payment Due dates
        EcDp_Line_Item.InsPPATransIntLineItem(p_document_key,p_user);

      END IF;

      --UPDATE DOCUMENT_DATE and it is not REVERSAL DOCUMENT
      IF p_level >= 5 AND lrec_cont_document.reversal_ind <> 'Y' THEN

        --update all the transactions
        --when pricing memo forex date base code = 'DOCUMENT_DATE';
        FOR curr IN c_trans_pm(p_document_key) LOOP

            -- find trans forex date
          ld_doc_forex_base_date:= ecdp_currency.GetforexdateViaCurrency(
                        curr.pricing_currency_code,
                        ec_cont_document.booking_currency_code(p_document_key),
                        ec_cont_document.memo_currency_code(p_document_key),
                        ec_cont_document.document_date(p_document_key),
                        curr.ex_pricing_memo_id,
                        curr.ex_pricing_memo_ts);

          UPDATE cont_transaction
          SET ex_pricing_memo_date = ld_doc_forex_base_date
          WHERE transaction_key = curr.transaction_key;

         BEGIN

         SELECT curr_from_to_pr_to_me
           INTO lv_curr_from_to
           FROM DV_FIN_DOC_EX_RATE_MAINTAIN
          WHERE transaction_key = curr.transaction_key;

        EXCEPTION WHEN OTHERS THEN
          lv_curr_from_to := NULL;

        END;

        lv_message:= Ecdp_Transaction.UpdSelectedTransExRate(curr.transaction_key, lv_curr_from_to, p_user);
        END LOOP;

         --when pricing booking forex date base code = 'DOCUMENT_DATE';
        FOR curr IN c_trans_pb(p_document_key) LOOP

            -- find trans forex date
          ld_doc_forex_base_date:= ecdp_currency.GetforexdateViaCurrency(
                        curr.pricing_currency_code,
                        ec_cont_document.booking_currency_code(p_document_key),
                        ec_cont_document.memo_currency_code(p_document_key),
                        ec_cont_document.document_date(p_document_key),
                        curr.ex_pricing_booking_id,
                        curr.ex_pricing_booking_ts);

          UPDATE cont_transaction
          SET ex_pricing_booking_date = ld_doc_forex_base_date
          WHERE transaction_key = curr.transaction_key;

         BEGIN

         SELECT curr_from_to_pr_to_bk
           INTO lv_curr_from_to
           FROM DV_FIN_DOC_EX_RATE_MAINTAIN
          WHERE transaction_key = curr.transaction_key;

        EXCEPTION WHEN OTHERS THEN
          lv_curr_from_to := NULL;

        END;

         lv_message:= Ecdp_Transaction.UpdSelectedTransExRate(curr.transaction_key, lv_curr_from_to, p_user);

        END LOOP;

        --when booking local forex date base code = 'DOCUMENT_DATE';
        FOR curr IN c_trans_bl(p_document_key) LOOP

            -- find trans forex date
          ld_doc_forex_base_date:= ecdp_currency.GetforexdateViaCurrency(
                        ec_cont_document.booking_currency_code(p_document_key),
                        GetLocalCurrencyCode(p_object_id , p_daytime ), -- local currency
                        ec_ctrl_system_attribute.attribute_text(p_daytime, 'GROUP_CURRENCY_CODE', '<='), -- group currency
                        ec_cont_document.document_date(p_document_key),
                        curr.ex_booking_local_id,
                        curr.ex_booking_local_ts);

          UPDATE cont_transaction
          SET ex_booking_local_date = ld_doc_forex_base_date
          WHERE transaction_key = curr.transaction_key;

         BEGIN

         SELECT curr_from_to_bk_to_lc
           INTO lv_curr_from_to
           FROM DV_FIN_DOC_EX_RATE_MAINTAIN
          WHERE transaction_key = curr.transaction_key;

        EXCEPTION WHEN OTHERS THEN
          lv_curr_from_to := NULL;

        END;

         lv_message:= Ecdp_Transaction.UpdSelectedTransExRate(curr.transaction_key, lv_curr_from_to, p_user);

        END LOOP;

        --when booking group forex date base code = 'DOCUMENT_DATE';
        FOR curr IN c_trans_bg(p_document_key) LOOP

            -- find trans forex date
          ld_doc_forex_base_date:= ecdp_currency.GetforexdateViaCurrency(
                        ec_cont_document.booking_currency_code(p_document_key),
                        EcDp_Contract_Setup.GetLocalCurrencyCode(p_object_id , p_daytime ), -- local currency
                        ec_ctrl_system_attribute.attribute_text(p_daytime, 'GROUP_CURRENCY_CODE', '<='), -- group currency
                        ec_cont_document.document_date(p_document_key),
                        curr.ex_booking_group_id,
                        curr.ex_booking_group_ts);

          UPDATE cont_transaction
          SET ex_booking_group_date = ld_doc_forex_base_date
          WHERE transaction_key = curr.transaction_key;

         --update the transaction ex rates
         BEGIN

         SELECT curr_from_to_bk_to_gp
           INTO lv_curr_from_to
           FROM DV_FIN_DOC_EX_RATE_MAINTAIN
          WHERE transaction_key = curr.transaction_key;

        EXCEPTION WHEN OTHERS THEN
          lv_curr_from_to := NULL;

        END;

         lv_message:= Ecdp_Transaction.UpdSelectedTransExRate(curr.transaction_key, lv_curr_from_to, p_user);

        END LOOP;

        --when forex date base code = 'DOCUMENT_FOREX_DATE';
        updateAllDocumentDates(p_object_id, p_document_key, ld_doc_forex_base_date, p_document_date, p_user, -1);

      END IF;

     -- IF document date for some reason has changed
		 IF p_document_date <> ec_cont_document.document_date(p_document_key) THEN
       ln_level := 5;
     END IF;

    IF p_level >= 5 OR ln_level = 5 THEN

         UPDATE cont_transaction
            SET daytime = ld_daytime,
                last_updated_by = p_user
        where document_key = p_document_key
              and daytime != ld_daytime;

        UPDATE cont_transaction_qty
           SET daytime = ld_daytime,
               last_updated_by = p_user
        where TRANSACTION_KEY IN
               (SELECT transaction_key
                  FROM cont_transaction
        where  document_key = p_document_key)
               and daytime != ld_daytime;

        UPDATE cont_line_item
           SET daytime = ld_daytime,
               last_updated_by = p_user
        where document_key = p_document_key
              and daytime != ld_daytime;

        UPDATE cont_line_item_dist
           SET daytime = ld_daytime,
               last_updated_by = p_user
        where document_key = p_document_key
              and daytime != ld_daytime;

        UPDATE cont_li_dist_company
           SET daytime = ld_daytime,
               last_updated_by = p_user
        where document_key = p_document_key
              and daytime != ld_daytime;

    END IF;

END updateAllDocumentDates;

PROCEDURE updatePriceIndex(p_object_id VARCHAR2, p_daytime DATE, p_int_type_id VARCHAR2)
IS
BEGIN
     --if INT_TYPE is changed
     IF p_int_type_id IS NOT NULL THEN
       UPDATE CONTRACT_DOC_VERSION cdv SET cdv.INT_TYPE = ec_price_input_item.object_code(p_int_type_id)
       WHERE cdv.OBJECT_ID = p_object_id
       AND cdv.DAYTIME = p_daytime;
     END IF;
END updatePriceIndex;


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
FUNCTION InsDealContractCopy(p_object_id  VARCHAR2, -- to copy from
                            p_start_date DATE, -- to copy from
                            p_code       VARCHAR2,
                            p_user       VARCHAR2,
                            p_end_date   DATE,
                            p_cntr_type  VARCHAR2 DEFAULT 'T')

RETURN VARCHAR2 -- new object_id
--</EC-DOC>
IS


lv_new_obj_daytime DATE;
lrec_old_contract_version contract_version%ROWTYPE;

CURSOR c_version_obj (cp_object_id VARCHAR2) IS
SELECT c.daytime
FROM   contract_version c
WHERE c.object_id = cp_object_id;

lv2_object_id contract.object_id%TYPE;
lrec_contract contract%ROWTYPE;
lv2_copy_code VARCHAR2(32);
lv2_deal_code VARCHAR2(32);
lv2_deal_name VARCHAR2(100);
lv2_deal_desc VARCHAR2(100);
lv2_deal_comment VARCHAR2(100);
lv2_deal_processable VARCHAR2(1) := 'N';
lv2_version_found_ind VARCHAR(1) := 'N';
invalid_contract_t EXCEPTION; --validation for creating Contract Template
invalid_contract_d EXCEPTION; --validation for creating Deal Contract

-- ** 4-eyes approval stuff ** --
CURSOR c_4e_con(cp_contract_id VARCHAR2,cp_daytime DATE) IS
  SELECT approval_state, rec_id
  FROM contract_version
  WHERE object_id = cp_contract_id
  AND daytime = cp_daytime;
-- ** END 4-eyes approval stuff ** --

BEGIN

   lrec_contract := ec_contract.row_by_pk(p_object_id);

   IF p_cntr_type = 'T' THEN
      --validation, only frame agreement can be used to create Deal Contract Template
      IF ec_contract_version.financial_code(p_object_id, p_start_date, '<=')  <> 'FRAME'
        OR ec_contract_version.parent_contract_id(p_object_id, p_start_date, '<=') IS NOT NULL THEN
         raise invalid_contract_t;
      END IF;

          lv2_deal_code := '_DT';
          lv2_deal_name := ' DEAL TEMPLATE';
          lv2_deal_desc := 'Deal Template under ';
          lv2_deal_comment := 'The Contract Template';
    ELSE
       --validation, only Deal Contract Template can be used to create Actual Deal Contract
       IF ec_contract_version.parent_contract_id(p_object_id, p_start_date, '<=') IS NULL
          OR ec_contract_version.financial_code(p_object_id, p_start_date, '<=')= 'FRAME'
            OR ec_contract_version.processable_code(p_object_id, p_start_date, '<=')= 'Y' THEN
           raise invalid_contract_d;
       END IF;

          lv2_deal_code := '_DEAL';
          lv2_deal_name := ' DEAL';
          lv2_deal_processable := 'Y';
          lv2_deal_desc := 'Deal Contract under ';
          lv2_deal_comment := 'The Deal Contract';
    END IF;

     lv2_object_id := InsDealContract(p_object_id,p_code,p_start_date,p_end_date,p_user, lv2_deal_code);


       UPDATE contract
          SET start_year      = lrec_contract.start_year,
              tran_ind        = lrec_contract.tran_ind,
              sale_ind        = lrec_contract.sale_ind,
              revn_ind        = lrec_contract.revn_ind,
              template_code   = lrec_contract.template_code,
              bf_profile      = lrec_contract.bf_profile,
              description     = DECODE(p_cntr_type,'T',lv2_deal_desc || lrec_contract.object_code, lv2_deal_desc || lrec_contract.object_code), --deal contract description
              last_updated_by = p_user
        WHERE object_id = lv2_object_id;


-- Expecting one record - one version
FOR v_obj IN c_version_obj(lv2_object_id) LOOP
    lv_new_obj_daytime := v_obj.daytime;
END LOOP;

lrec_old_contract_version := ec_contract_version.row_by_pk(p_object_id,lv_new_obj_daytime,'<=');


       UPDATE contract_version cv
          SET cv.name                    = lrec_old_contract_version.name || lv2_deal_name,
              cv.sort_order              = lrec_old_contract_version.sort_order,
              cv.calc_rule_id          = lrec_old_contract_version.calc_rule_id,
              cv.calc_seq                = lrec_old_contract_version.calc_seq,
              cv.calc_group              = lrec_old_contract_version.calc_group,
              cv.production_day_id       = lrec_old_contract_version.production_day_id,
              cv.contract_group_code     = lrec_old_contract_version.contract_group_code,
              cv.contract_area_id        = lrec_old_contract_version.contract_area_id,
              cv.financial_code          = lrec_old_contract_version.financial_code, --financial code from frame agreement
              cv.company_id              = lrec_old_contract_version.company_id,
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
              cv.processable_code        = lv2_deal_processable, --processable code
              cv.first_delivery_date     = lrec_old_contract_version.first_delivery_date,
              cv.last_delivery_date      = lrec_old_contract_version.last_delivery_date,
              comments                   = lv2_deal_comment,
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
              last_updated_by            = p_user,
              cv.parent_contract_id      = p_object_id
        WHERE object_id = lv2_object_id
          AND daytime = lrec_old_contract_version.daytime;

     RETURN lv2_object_id;
EXCEPTION

         WHEN invalid_contract_t THEN
              Raise_Application_Error(-20000,'A Deal Template can only be created when a Frame Agreement is selected');
         WHEN invalid_contract_d THEN
              Raise_Application_Error(-20000,'A Deal Contract can only be created when a Deal Template is selected');

END InsDealContractCopy;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  InsDealContract
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
-- Behaviour      : The new approach (ECPD-8579) sees to that only one version of the contract and the other child objects are copied.
--                  Since the new contract' start date and end date is validated in the client, there should always be at least one valid object
--                  for the dates that are passed to the procedure behind the "Copy To New" button
-------------------------------------------------------------------------------------------------
FUNCTION InsDealContract(p_object_id   VARCHAR2,
                        p_object_code VARCHAR2,
                        p_start_date  DATE,
                        p_end_date    DATE DEFAULT NULL,
                        p_user        VARCHAR2 DEFAULT NULL,
                        p_deal_code VARCHAR2 DEFAULT NULL)
--</EC-DOC>
RETURN VARCHAR2


IS
lv2_default_code  VARCHAR2(100) := p_object_code||p_deal_code;
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

       INSERT INTO contract_version
       (object_id, daytime, created_by)
     VALUES
       (lv2_object_id, p_start_date, p_user);

      -- ** 4-eyes approval logic ** --
    IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('CONTRACT'),'N') = 'Y' THEN

      -- TODO: Set approval info on versions prior to the latest, that is set to 'N' below

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

END InsDealContract;




--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  GetContractAreaCode
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
-- Behaviour      : Retrieveing the current Contract_Area_Code for a given contract.
--                  If it is related to more than one ContractArea, the function will return "MULTI".
--
-------------------------------------------------------------------------------------------------
FUNCTION GetContractAreaCode(
         p_object_id VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS

  CURSOR c_cac IS
    SELECT cas.contract_area_id
    FROM contract_area_setup cas
    WHERE cas.contract_id = p_object_id;

  ln_counter NUMBER := 0;
  lv2_retval VARCHAR2(32) := NULL;

BEGIN

  FOR rsCAC IN c_cac LOOP
    lv2_retval := ec_contract_area.object_code(rsCAC.Contract_Area_Id);
    ln_counter := ln_counter + 1;
  END LOOP;

  IF ln_counter > 1 THEN
    lv2_retval := '[MULTI]';
  END IF;

  RETURN lv2_retval;

END GetContractAreaCode;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  AddContractArea
-- Description    : Adds a contract area to a contract in the contract_area_setup table.
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
PROCEDURE AddContractArea(
          p_contract_code VARCHAR2,
          p_contract_area_code VARCHAR2,
          p_daytime DATE)
--</EC-DOC>
IS

  ln_count NUMBER := 0;
  lv2_New_CAS_Code VARCHAR2(32) := NULL;

  CURSOR c_chk IS
    SELECT Count(*) AS cnt
    FROM contract_area_setup cas
    WHERE cas.contract_id = ec_contract.object_id_by_uk(p_contract_code)
    AND cas.contract_area_id = ec_contract_area.object_id_by_uk(p_contract_area_code);

BEGIN
  IF p_contract_code IS NOT NULL OR p_contract_area_code IS NOT NULL THEN
    FOR rsChk in c_chk LOOP
      ln_count := rsChk.Cnt;
    END LOOP;

    IF ln_count = 0 THEN
      lv2_New_CAS_Code := GetNewContractAreaSetupCode;

      INSERT INTO contract_area_setup (object_code, start_date, contract_area_id, contract_id)
      VALUES (lv2_New_CAS_Code, p_daytime, ec_contract_area.object_id_by_uk(p_contract_area_code), ec_contract.object_id_by_uk(p_contract_code));

      INSERT INTO cntr_area_setup_version (object_id, daytime, name)
      VALUES (ec_contract_area_setup.object_id_by_uk(lv2_New_CAS_Code), p_daytime, 'Contract Area ' || p_contract_area_code || ' for Contract ' || p_contract_code);

      -- Update nav_model with the relation contract-contract_area_setup
      -- DRo: This update should have been provided by the trigger IUD_CONTRACT_AREA_SETUP,
      --      but the trigger is not recieving the contract_area_id and contract_id upon the insert above.
      ecdp_nav_model_obj_relation.Syncronize_model('FINANCIAL');

    END IF;
  ELSE
    Raise_Application_Error(-20000,'Can not add Contract Area to Contract. Contract Code (' || p_contract_code || ') or Contract Area Code (' || p_contract_area_code || ') is missing.');
  END IF;


END AddContractArea;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  GetNewContractAreaSetupCode
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
FUNCTION GetNewContractAreaSetupCode
RETURN VARCHAR2
--</EC-DOC>
IS

  lv2_test_code VARCHAR2(32) := 'CON_CA_';
  ln_counter NUMBER := 1;
  lb_found_new BOOLEAN := FALSE;

  CURSOR c_chk(cp_code VARCHAR2) IS
    SELECT COUNT(*) AS cnt
    FROM contract_area_setup cas
    WHERE cas.object_code = cp_code;

BEGIN

  WHILE lb_found_new = FALSE LOOP
    FOR rsChk in c_chk(lv2_test_code || ln_counter) LOOP
       IF rsChk.Cnt = 0 THEN
         lb_found_new := TRUE;
         lv2_test_code := lv2_test_code || ln_counter;
       ELSE
         lb_found_new := FALSE;
       END IF;
    END LOOP;
    ln_counter := ln_counter + 1;
  END LOOP;

  RETURN lv2_test_code;

END GetNewContractAreaSetupCode;

PROCEDURE updFinancialCode(p_object_id VARCHAR2,
                           p_daytime  VARCHAR2,
                           p_financial_code VARCHAR2)
IS
  /* Returning records from all versions of the contract being copied. Sorted ascending on daytime */
CURSOR c_versions (cp_object_id VARCHAR2, cp_daytime DATE) IS
  SELECT cv.daytime, cv.object_id
    FROM contract c, contract_version cv
   WHERE c.object_id = cp_object_id
     AND c.object_id = cv.object_id
     AND cv.daytime <> cp_daytime
   ORDER BY cv.daytime;
BEGIN

   FOR v IN c_versions(p_object_id, p_daytime) LOOP
     UPDATE contract_version
      SET financial_code = p_financial_code,last_updated_by=Nvl(EcDp_Context.getAppUser, User)
      where object_id = v.object_id
      AND daytime <> v.daytime;
   END LOOP;

END updFinancialCode;

FUNCTION getObjectCodeNumber (p_object_code  VARCHAR2)
RETURN INTEGER
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
END getObjectCodeNumber;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  isCntrPriceElmMoveToVO
-- Description    : Checks whether the contract'SELECT price elements are using "moveQtyToVO"-option.
--                  Is used to determine if UOM-check is necessary in different triggers and packages.
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : product_price, price_concept_element
--
-- Using functions: None
--
-- Configuration
-- required       :
--
-- Behaviour      : Procedure is triggered from after save trigger in BF FT - Contract - Company Splits
--
-------------------------------------------------------------------------------------------------
FUNCTION isCntrPriceElmMoveToVO
   (p_contract_id VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
  lv2_ret_val VARCHAR2(1) := 'N';

  CURSOR c_priceElm IS
    SELECT DISTINCT pce.move_qty_to_vo_ind -- only one record if MoveToVo is Yes
      FROM product_price pp, price_concept_element pce
     WHERE pce.price_concept_code = pp.price_concept_code
       AND pp.contract_id = p_contract_id
       AND pce.move_qty_to_vo_ind = 'Y';
BEGIN

   FOR rs_Pe IN c_priceElm LOOP
     lv2_ret_val := rs_Pe.Move_Qty_To_Vo_Ind;
   END LOOP;

   RETURN lv2_ret_val;

END isCntrPriceElmMoveToVO;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : validateNumberOfShareParties
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: None
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateNumberOfShareParties(
   p_contract_id VARCHAR2,
   p_role_name   VARCHAR2
)
--</EC-DOC>
IS

ln_max NUMBER DEFAULT 0;
lv_num_rows NUMBER DEFAULT 0;
lv2_contract_financial_code VARCHAR(32);

BEGIN

  IF p_role_name IS NULL THEN
     Raise_Application_Error(-20000,'Can not validate number of shares allowed. Role_Name is missing.');
  ELSIF p_contract_id IS NULL THEN
     Raise_Application_Error(-20000,'Can not validate number of shares allowed. Contract_ID is missing.');
  END IF;

  -- Get the financial code for this contract
  lv2_contract_financial_code := ec_contract_version.financial_code(p_contract_id, ec_contract.start_date(p_contract_id), '<=');

  -- Count the parties for this role
  SELECT (count(c.object_id)+1) INTO lv_num_rows
  FROM contract_party_share c
  WHERE c.OBJECT_ID = p_contract_id
  AND c.party_role = p_role_name;

  IF p_role_name = 'VENDOR' THEN -- Vendor

       ln_max := 999;

  ELSIF p_role_name = 'CUSTOMER' THEN -- Customer

     -- Always maximum 1 customer on all contracts
     ln_max := 1;

  END IF;

  IF NVL(lv_num_rows,0) > NVL(ln_max,0) THEN
     Raise_Application_Error(-20000,'Maximum allowed number of ' || initcap(p_role_name) || ' shares in a ' || initcap(replace(lv2_contract_financial_code, '_',' ')) || ' contract is ' || ln_max || '.');
  END IF;

END validateNumberOfShareParties;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : validateContractArea
-- Description    : Validates that contract area code is set on post-save for EC Revenue contracts only
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: None
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateContractArea(p_object_id VARCHAR2, p_daytime DATE)
--</EC-DOC>
IS

lv2_ca_id VARCHAR2(32) := ec_contract_version.contract_area_id(p_object_id,p_daytime,'<=');
lrec_c contract%ROWTYPE := ec_contract.row_by_pk(p_object_id);
BEGIN

IF (nvl(lrec_c.revn_ind,'N') = 'Y' AND nvl(lrec_c.tran_ind,'N') = 'N' AND nvl(lrec_c.sale_ind,'N') = 'N') THEN

   IF (lv2_ca_id IS NULL) THEN
      Raise_Application_Error(-20000,'Contract Area Code is required on an EC Revenue Contract');
   END IF;
END IF;



END validateContractArea;

PROCEDURE populateFactorPrice(p_daytime DATE, p_price_group_id VARCHAR2, p_user VARCHAR2)
IS
--cursor to find all the factor product_price in that price group
CURSOR pvs(cp_price_group_id VARCHAR2, cp_daytime DATE) IS
SELECT price_value,
       object_id,
       price_concept_code,
       price_element_code,
       price_date,
	   price_category
  FROM (SELECT ecdp_contract_setup.GetPriceElemVal(ec_product_price.contract_id(pvs.object_id),
                                                   pvs.object_id,
                                                   pvs.price_element_code,
                                                   ec_product_price.product_id(pvs.object_id),
                                                   ec_product_price_version.currency_id(pvs.object_id,
                                                                                        cp_daytime,
                                                                                        '<='),
                                                   cp_daytime,
                                                   NULL) as price_value,
               pvs.object_id,
               pvs.price_concept_code,
               pvs.price_element_code,
               cp_daytime price_date,
			   ppv.price_category
          FROM price_value_setup       pvs,
               product_price_value     ppv,
               CALC_COLLECTION_ELEMENT cce
         WHERE pvs.src_product_price_id = ppv.object_id
           AND ppv.daytime = cp_daytime
           AND ppv.object_id = cce.element_id
           AND cce.object_id = cp_price_group_id
           AND cp_daytime >= cce.daytime
           AND cp_daytime < NVL(cce.end_date, cp_daytime + 1));

--cursor to find if a factor product_price in that price group is to be inserted
CURSOR pvs_exists(cp_price_group_id VARCHAR2, cp_daytime DATE) IS
SELECT pvs.object_id, pvs.price_concept_code, pvs.price_element_code, ppv.price_category
  FROM price_value_setup       pvs,
       product_price_value     ppv,
       calc_collection_element cce
 WHERE pvs.src_product_price_id = ppv.object_id
   AND ppv.daytime = cp_daytime
   AND ppv.object_id = cce.element_id
   AND cce.object_id = cp_price_group_id
   AND cp_daytime >= cce.daytime
   AND cp_daytime < NVL(cce.end_date, cp_daytime + 1);

ln_price_decimals NUMBER;

BEGIN

FOR cur IN pvs_exists(p_price_group_id, p_daytime) LOOP

     BEGIN
             -- Inserting the factor price skeleton
            INSERT INTO product_price_value
              (object_id,
               price_concept_code,
               price_element_code,
               daytime,
			   price_category,
               record_status,
               created_by,
               created_date,
               approval_state,
               rec_id)
            VALUES
              (cur.object_id,
               cur.price_concept_code,
               cur.price_element_code,
               p_daytime,
			   cur.price_category,
               'P',
               p_user,
               Ecdp_Timestamp.getCurrentSysdate,
               'O',
               SYS_GUID());

          EXCEPTION
              --Do nothing when recored exists
              WHEN DUP_VAL_ON_INDEX THEN
                   NULL;

          END;
 END LOOP;

 -- Updating the factor price
 FOR cur IN pvs(p_price_group_id, p_daytime) LOOP

      --get the contract price decimals
      ln_price_decimals := NULL;

      BEGIN

           UPDATE product_price_value
              SET calc_price_value  = DECODE(ln_price_decimals,
                                             NULL,
                                             cur.price_value,
                                             ROUND(cur.price_value,
                                                   ln_price_decimals)),
                  adj_price_value   = NULL,
                  last_updated_by   = p_user,
                  last_updated_date = Ecdp_Timestamp.getCurrentSysdate
            WHERE object_id = cur.object_id
              AND price_concept_code = cur.price_concept_code
              AND price_element_code = cur.price_element_code
              AND daytime = cur.price_date
			  AND price_category = cur.price_category;
          END;

 END LOOP;

END populateFactorPrice;

PROCEDURE updateFactorAdjustedPrice(
   p_object_id VARCHAR2, --product_price_id
   p_price_concept_code   VARCHAR2,
   p_price_element_code   VARCHAR2,
   p_daytime DATE,
   p_user VARCHAR2
)
IS

CURSOR c_derived_price IS
SELECT ecdp_contract_setup.GetPriceElemVal(ec_product_price.contract_id(pvs.object_id),
  pvs.object_id,
  pvs.price_element_code,
  ec_product_price.product_id(pvs.object_id),
  ec_product_price_version.currency_id(pvs.object_id, p_daytime, '<='),
  p_daytime,
  NULL) as price_value
  ,pvs.object_id
  ,pvs.price_concept_code
  ,pvs.price_element_code
  ,p_daytime price_date
  ,ppv.price_category
  FROM price_value_setup pvs, product_price_value ppv
  WHERE pvs.src_product_price_id = ppv.object_id
  AND pvs.object_id = p_object_id
  AND pvs.price_concept_code = p_price_concept_code
  AND pvs.price_element_code = DECODE(p_price_element_code, 'PRELIMINARY', ecdp_sales_contract_price.GetAnyPriceElement(p_price_concept_code,p_object_id,p_daytime,ppv.price_category), p_price_element_code)
  AND ppv.daytime = p_daytime;

CURSOR c_pvs IS
  SELECT ecdp_contract_setup.GetPriceElemVal(ec_product_price.contract_id(pvs.object_id),
  pvs.object_id,
  pvs.price_element_code,
  ec_product_price.product_id(pvs.object_id),
  ec_product_price_version.currency_id(pvs.object_id, p_daytime, '<='),
  p_daytime,
  NULL) as price_value
  ,pvs.object_id
  ,pvs.price_concept_code
  ,pvs.price_element_code
  ,p_daytime price_date
  ,ppv.price_category
  FROM price_value_setup pvs, product_price_value ppv
  WHERE pvs.src_product_price_id = ppv.object_id(+)
  AND pvs.src_product_price_id = p_object_id
  AND pvs.src_price_concept_code = p_price_concept_code
  AND pvs.src_price_element_code = DECODE(p_price_element_code, 'PRELIMINARY', ecdp_sales_contract_price.GetAnyPriceElement(p_price_concept_code,p_object_id,p_daytime,ppv.price_category), p_price_element_code)
  AND ppv.daytime(+) = p_daytime;

-- ** 4-eyes approval stuff ** --
CURSOR c_4e_ppv(cp_price_object_id VARCHAR2,cp_price_concept_code VARCHAR2,cp_price_element_code VARCHAR2,cp_price_date DATE, cp_price_category VARCHAR2) IS
SELECT ppv.rec_id, ppv.approval_state
  FROM product_price_value ppv
 WHERE OBJECT_ID = cp_price_object_id
   AND PRICE_CONCEPT_CODE = cp_price_concept_code
   AND PRICE_ELEMENT_CODE = cp_price_element_code
   AND DAYTIME = cp_price_date
   AND price_category = cp_price_category;
-- ** END 4-eyes approval stuff ** --

BEGIN

    --update factor based adjusted price
    FOR cur IN c_pvs LOOP

        UPDATE product_price_value SET
           ADJ_PRICE_VALUE =  cur.price_value,
           last_updated_by = p_user,
           last_updated_date = Ecdp_Timestamp.getCurrentSysdate
         WHERE OBJECT_ID = cur.object_id
          AND  PRICE_CONCEPT_CODE = cur.price_concept_code
          AND  PRICE_ELEMENT_CODE = cur.price_element_code
          AND  DAYTIME = cur.price_date
		  AND  PRICE_CATEGORY = cur.price_category;


          -- ** 4-eyes approval logic ** --
          IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('CONTRACT_PRICE_LIST'),'N') = 'Y' THEN

             FOR rs4e IN c_4e_ppv(cur.object_id, cur.price_concept_code, cur.price_element_code, cur.price_date, cur.price_category) LOOP

                -- Only demand approval if a record is in Official state
                IF rs4e.approval_state = 'O' THEN

                   -- Set approval info on record
                   UPDATE product_price_value
                   SET last_updated_by = Nvl(EcDp_Context.getAppUser,User),
                       last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
                       approval_state = 'U',
                       approval_by = null,
                       approval_date = null,
                       rev_no = (nvl(rev_no,0) + 1)
                   WHERE rec_id = rs4e.rec_id;

                   -- Prepare record for approval
                   Ecdp_Approval.registerTaskDetail(rs4e.rec_id,
                                                    'CONTRACT_PRICE_LIST',
                                                    Nvl(EcDp_Context.getAppUser,User));
                END IF;
             END LOOP;
          END IF;
          -- ** END 4-eyes approval ** --

    END LOOP;

    --update if it is derived price
    FOR cur IN c_derived_price LOOP

         UPDATE product_price_value SET
           ADJ_PRICE_VALUE =  cur.price_value,
           last_updated_by = p_user,
           last_updated_date = Ecdp_Timestamp.getCurrentSysdate
         WHERE OBJECT_ID = cur.object_id
          AND  PRICE_CONCEPT_CODE = cur.price_concept_code
          AND  PRICE_ELEMENT_CODE = cur.price_element_code
          AND  DAYTIME = cur.price_date
		  AND  PRICE_CATEGORY = cur.price_category;

          -- ** 4-eyes approval logic ** --
          IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('CONTRACT_PRICE_LIST'),'N') = 'Y' THEN

             FOR rs4e IN c_4e_ppv(cur.object_id, cur.price_concept_code, cur.price_element_code, cur.price_date,cur.price_category) LOOP

                -- Only demand approval if a record is in Official state
                IF rs4e.approval_state = 'O' THEN

                   -- Set approval info on record
                   UPDATE product_price_value
                   SET last_updated_by = Nvl(EcDp_Context.getAppUser,User),
                       last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
                       approval_state = 'U',
                       approval_by = null,
                       approval_date = null,
                       rev_no = (nvl(rev_no,0) + 1)
                   WHERE rec_id = rs4e.rec_id;

                   -- Prepare record for approval
                   Ecdp_Approval.registerTaskDetail(rs4e.rec_id,
                                                    'CONTRACT_PRICE_LIST',
                                                    Nvl(EcDp_Context.getAppUser,User));
                END IF;
             END LOOP;
          END IF;
          -- ** END 4-eyes approval ** --

     END LOOP;

END updateFactorAdjustedPrice;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : insertContractPriceList
-- Description    : When inserting a new Contract Price Value for a Price Object that is the SOURCE for some Factor Price objects
--                  in the Contract Price List BF the Factor Price objects should be added automatically and also get calculated.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: None
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE insertContractPriceList(
    p_object_id                 VARCHAR2,
    p_price_concept_code        VARCHAR2,
    p_price_element_code        VARCHAR2,
    p_daytime                   DATE,
	p_price_category 			VARCHAR2,
    p_user                      VARCHAR2
)
--<EC-DOC>
IS

/*CURSOR c_price_elements (cp_price_concept_code VARCHAR2) IS
       SELECT price_element_code
       FROM   price_concept_element
       WHERE  price_concept_code = cp_price_concept_code;*/

CURSOR c_new_price_list IS
SELECT ecdp_contract_setup.GetPriceElemVal(ec_product_price.contract_id(pvs.object_id),
  pvs.object_id,
  pvs.price_element_code,
  ec_product_price.product_id(pvs.object_id),
  ec_product_price_version.currency_id(pvs.object_id, p_daytime, '<='),
  p_daytime,
  NULL) as price_value
  ,pvs.object_id
  ,pvs.price_concept_code
  ,pvs.price_element_code
  ,p_daytime price_date
  FROM price_value_setup pvs
  WHERE pvs.src_product_price_id = p_object_id
  AND pvs.src_price_concept_code = p_price_concept_code
  AND pvs.src_price_element_code = p_price_element_code
  AND daytime <= p_daytime
  AND nvl(pvs.end_date,p_daytime+1) > p_daytime;


lrec_pp_value product_price_value%ROWTYPE;
ln_inserted NUMBER := 0;
BEGIN

lrec_pp_value := ec_product_price_value.row_by_pk(p_object_id,p_price_concept_code,p_price_element_code,p_daytime, p_price_category);


FOR c_val IN c_new_price_list LOOP

ln_inserted := 0;

SELECT count(*)
  INTO ln_inserted
  FROM product_price_value
 WHERE object_id = c_val.object_id
   AND price_concept_code = c_val.price_concept_code
   AND daytime = c_val.price_date
   AND price_element_code = c_val.price_element_code
   AND price_category = p_price_category;

    -- One record is already inserted
    IF  (ln_inserted = 0) THEN

      INSERT
      INTO     product_price_value (object_id,price_concept_code,price_element_code,daytime,price_category,adj_price_value,comments,created_by)
      VALUES   (c_val.object_id,c_val.price_concept_code, c_val.price_element_code,c_val.price_date,p_price_category, lrec_pp_value.adj_price_value,lrec_pp_value.comments,lrec_pp_value.created_by);

      updateFactorAdjustedPrice(c_val.object_id,c_val.price_concept_code,c_val.price_element_code,c_val.price_date,p_user);
    END IF;
END LOOP;


END insertContractPriceList;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : updateCalcContractPriceList
-- Description    : When updating Calculated Price Derived Price Object should also be updated using this procedure.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: None
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

PROCEDURE updateCalcContractPriceList(
    p_object_id                 VARCHAR2,
    p_price_concept_code        VARCHAR2,
    p_price_element_code        VARCHAR2,
    p_daytime                   DATE,
	p_price_category			VARCHAR2,
    p_user                      VARCHAR2
)
--<EC-DOC>
IS


CURSOR c_new_price_list IS
SELECT ecdp_contract_setup.GetPriceElemVal(ec_product_price.contract_id(pvs.object_id),
  pvs.object_id,
  pvs.price_element_code,
  ec_product_price.product_id(pvs.object_id),
  ec_product_price_version.currency_id(pvs.object_id, p_daytime, '<='),
  p_daytime,
  NULL) as price_value
  ,pvs.object_id
  ,pvs.price_concept_code
  ,pvs.price_element_code
  ,p_daytime price_date
  FROM price_value_setup pvs
  WHERE pvs.src_product_price_id = p_object_id
  AND pvs.src_price_concept_code = p_price_concept_code
  AND pvs.src_price_element_code = p_price_element_code;


lrec_pp_value product_price_value%ROWTYPE;

BEGIN

lrec_pp_value := ec_product_price_value.row_by_pk(p_object_id,p_price_concept_code,p_price_element_code,p_daytime, p_price_category);


FOR c_val IN c_new_price_list LOOP

      updateFactorAdjustedPrice(c_val.object_id,c_val.price_concept_code,c_val.price_element_code,c_val.price_date,p_user);

END LOOP;


END updateCalcContractPriceList;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : updateFactorAdjustedPriceAll
-- Description    : Wrapper for procedure updateFactorAdjustedPrice in order to update all valid price values
--                  when the factor price configuration has changed.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: None
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE updateFactorAdjustedPriceAll(p_object_id          VARCHAR2, --product_price_id
                                       p_price_concept_code VARCHAR2,
                                       p_price_element_code VARCHAR2,
                                       p_daytime            DATE,
                                       p_end_date           DATE,
                                       p_user               VARCHAR2)


IS


CURSOR c_validPrices IS
SELECT ppv.daytime
  FROM product_price_value ppv
 WHERE ppv.object_id = p_object_id
   AND ppv.price_concept_code = p_price_concept_code
   AND ppv.price_element_code = p_price_element_code
   AND ppv.daytime >= p_daytime
   AND ppv.daytime < nvl(p_end_date, ppv.daytime + 1);


BEGIN

FOR p IN c_validPrices LOOP
    updateFactorAdjustedPrice(p_object_id,p_price_concept_code,p_price_element_code,p.daytime,p_user);
END LOOP;

  END updateFactorAdjustedPriceAll;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : UpdateDocumentVendor
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: None
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

PROCEDURE UpdateDocumentVendor(
   p_contract_id  VARCHAR2
)
--</EC-DOC>
IS

cursor cend(p_contract_id varchar2) is
      select
             cd.object_id doc_id, cps.company_id, cps.daytime, cps.end_date, cd.contract_id
      from
           contract_doc_company cdc,
           contract_party_share cps,
           contract_doc cd
      where
           nvl(cdc.end_date,'01-JAN-1008') != nvl(cps.end_date, '01-JAN-1008') and
           cdc.daytime = cps.daytime and
           cdc.party_role = 'VENDOR' and
           cdc.object_id = cd.object_id and
           cdc.company_id = cps.company_id and
           cps.party_role = 'VENDOR' and
           cps.object_id = p_contract_id;

cursor cdocs(p_contract_id varchar2) is
       select
             object_id
       from
             contract_doc
       where
             contract_id = p_contract_id;

-- ** 4-eyes approval stuff ** --
lv2_4e_recid VARCHAR2(32);
lv2_4e_approval_ind VARCHAR2(1);
lv2_4e_approval_state VARCHAR2(1);
lv2_4e_approval_by VARCHAR2(32);
lv2_4e_approval_date DATE;
lv2_4e_rec_id VARCHAR2(32);

CURSOR c_4e_objects(cp_object_id VARCHAR2, cp_company_id varchar2, cp_daytime DATE) IS
  SELECT contract_doc_company.rec_id, contract_doc_company.approval_state
  FROM contract_doc_company
  WHERE contract_doc_company.object_id = cp_object_id
  AND contract_doc_company.daytime = cp_daytime
  AND contract_doc_company.company_id = cp_company_id
  AND contract_doc_company.party_role = 'VENDOR';
-- ** END 4-eyes approval stuff ** --

BEGIN

  lv2_4e_approval_ind := NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('CONTRACT_DOC_VENDORS'),'N');

-- update end of splits

  FOR r1 in cend(p_contract_id) LOOP
      update contract_doc_company set end_date = r1.end_date, rev_no = (NVL(rev_no, 0) + 1)
             where party_role = 'VENDOR' and object_id = r1.doc_id and company_id = r1.company_id and daytime = r1.daytime;
  END LOOP;

-- insert new splits

  FOR r2 in cdocs(p_contract_id) LOOP

      -- ** 4-eyes approval logic ** --

      -- New CONTRACT_DOC_VENDORS object created from CONTRACT_VENDOR_PARTIES are automatically
      -- approved, since it is not created by user

      IF lv2_4e_approval_ind = 'Y' THEN
         lv2_4e_rec_id := SYS_GUID();
         lv2_4e_approval_state := 'O';
         lv2_4e_approval_by := Nvl(EcDp_Context.getAppUser,User);
         lv2_4e_approval_date := Ecdp_Timestamp.getCurrentSysdate;
      ELSE
         lv2_4e_rec_id := NULL;
         lv2_4e_approval_state := NULL;
         lv2_4e_approval_by := NULL;
         lv2_4e_approval_date := NULL;
      END IF;
      -- ** END 4-eyes approval logic ** --

      insert into contract_doc_company(object_id, company_id, party_role, daytime, end_date, created_by,
                                       rec_id, approval_state, approval_by, approval_date, rev_no)
      select doc_id, company_id, 'VENDOR' party_role, daytime, end_date, ecdp_context.getAppUser created_by,
             lv2_4e_rec_id, lv2_4e_approval_state, lv2_4e_approval_by, lv2_4e_approval_date, 0
      from (
          select
                 cd.object_id doc_id, cps.company_id, cps.daytime, cps.end_date
          from
               contract_party_share cps,
               contract_doc cd
          where
               cps.party_role = 'VENDOR' and
               cps.object_id = cd.contract_id and
               cd.object_id = r2.object_id
          minus
          select
               object_id doc_id, company_id, daytime, end_date
          from
               contract_doc_company
          where
               party_role = 'VENDOR' and
               object_id = r2.object_id
      );

    -- clean up old vendors

      delete from contract_doc_company dcdc where
        exists (select '1' from
          (select doc_id, company_id, 'VENDOR' party_role
              from (
                  select
                       object_id doc_id, company_id
                  from
                       contract_doc_company
                  where
                       party_role = 'VENDOR' and
                       object_id = r2.object_id
                  minus
                  select
                         cd.object_id doc_id, cps.company_id
                  from
                       contract_party_share cps,
                       contract_doc cd
                  where
                       cps.party_role = 'VENDOR' and
                       cps.object_id = cd.contract_id and
                       cd.object_id = r2.object_id
              )
          )
          where
               doc_id = dcdc.object_id and
               company_id = dcdc.company_id and
               party_role = dcdc.party_role

      );
  END LOOP;

END UpdateDocumentVendor;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : UpdateDocumentVendorData
-- Description    : This will update Data for document vendors
-- Using tables   : contract_doc_company, contract_party_share, contract_doc
-- Using functions: None
-- Configuration
-- required       : None
-- Behaviour      : This procedure will be called to copy documentvendor data from previous
--                  version while a new version of document vendor will be created
--
---------------------------------------------------------------------------------------------------

PROCEDURE UpdateDocumentVendorData(
   p_contract_id  VARCHAR2
)
--</EC-DOC>
IS

cursor cend(p_contract_id varchar2) is
      select
             cd.object_id doc_id, cps.company_id, cps.daytime, cps.end_date, cd.contract_id
      from
           contract_doc_company cdc,
           contract_party_share cps,
           contract_doc cd
      where
           nvl(cdc.end_date,'01-JAN-1008') != nvl(cps.end_date, '01-JAN-1008') and
           cdc.daytime = cps.daytime and
           cdc.party_role = 'VENDOR' and
           cdc.object_id = cd.object_id and
           cdc.company_id = cps.company_id and
           cps.party_role = 'VENDOR' and
           cps.object_id = p_contract_id;

cursor cdocs(p_contract_id varchar2) is
       select
             object_id
       from
             contract_doc
       where
             contract_id = p_contract_id;

cursor cuDocVend(p_object_id varchar2)is
       select doc_id, company_id, party_role, daytime, end_date,
              ecdp_context.getAppUser created_by
       from (
          select
                 cd.object_id doc_id, cps.company_id, cps.daytime, cps.end_date,
                 cps.party_role
          from
               contract_party_share cps,
               contract_doc cd
          where
               cps.party_role = 'VENDOR' and
               cps.object_id = cd.contract_id and
               cd.object_id = p_object_id
          minus
          select
               object_id doc_id, company_id, daytime, end_date,  party_role
          from
               contract_doc_company
          where
               party_role = 'VENDOR' and
               object_id = p_object_id
      );

-- ** 4-eyes approval stuff ** --
lv2_4e_recid VARCHAR2(32);
lv2_4e_approval_ind VARCHAR2(1);
lv2_4e_approval_state VARCHAR2(1);
lv2_4e_approval_by VARCHAR2(32);
lv2_4e_approval_date DATE;
lv2_4e_rec_id VARCHAR2(32);

CURSOR c_4e_objects(cp_object_id VARCHAR2, cp_company_id varchar2, cp_daytime DATE) IS
  SELECT contract_doc_company.rec_id, contract_doc_company.approval_state
  FROM contract_doc_company
  WHERE contract_doc_company.object_id = cp_object_id
  AND contract_doc_company.daytime = cp_daytime
  AND contract_doc_company.company_id = cp_company_id
  AND contract_doc_company.party_role = 'VENDOR';
-- ** END 4-eyes approval stuff ** --

BEGIN

  lv2_4e_approval_ind := NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('CONTRACT_DOC_VENDORS'),'N');

-- update end of splits

  FOR r1 in cend(p_contract_id) LOOP
      update contract_doc_company set end_date = r1.end_date, rev_no = (NVL(rev_no, 0) + 1)
             where party_role = 'VENDOR' and object_id = r1.doc_id and company_id = r1.company_id and daytime = r1.daytime;
  END LOOP;

-- insert new splits

  FOR r2 in cdocs(p_contract_id) LOOP

      -- ** 4-eyes approval logic ** --

      -- New CONTRACT_DOC_VENDORS object created from CONTRACT_VENDOR_PARTIES are automatically
      -- approved, since it is not created by user

      IF lv2_4e_approval_ind = 'Y' THEN
         lv2_4e_rec_id := SYS_GUID();
         lv2_4e_approval_state := 'O';
         lv2_4e_approval_by := Nvl(EcDp_Context.getAppUser,User);
         lv2_4e_approval_date := Ecdp_Timestamp.getCurrentSysdate;
      ELSE
         lv2_4e_rec_id := NULL;
         lv2_4e_approval_state := NULL;
         lv2_4e_approval_by := NULL;
         lv2_4e_approval_date := NULL;
      END IF;
      -- ** END 4-eyes approval logic ** --

      FOR rec_cuDocVend in cuDocVend( r2.object_id) LOOP


          insert into contract_doc_company(object_id, company_id, party_role, daytime, end_date, created_by,
                                           rec_id, approval_state, approval_by, approval_date, rev_no, bank_account_id,
                                           payment_term_base_code, payment_term_id, payment_calendar_coll_id, payment_scheme_id
                                           )

          select object_id, company_id, party_role, rec_cuDocVend.daytime, rec_cuDocVend.end_date, ecdp_context.getAppUser created_by,
                 lv2_4e_rec_id, lv2_4e_approval_state, lv2_4e_approval_by, lv2_4e_approval_date, 0, Bank_Account_Id,
                 PAYMENT_TERM_BASE_CODE, PAYMENT_TERM_ID, PAYMENT_CALENDAR_COLL_ID, PAYMENT_SCHEME_ID
          from
                 contract_doc_company
          where
                 party_role = 'VENDOR' and
                 object_id = rec_cuDocVend.Doc_Id and
                 object_id = r2.object_id and
                 company_id = rec_cuDocVend.company_id and
                 end_date = rec_cuDocVend.Daytime
          ;
       END LOOP;

    -- clean up old vendors
      delete from contract_doc_company dcdc where
        exists (select '1' from
          (select doc_id, company_id, 'VENDOR' party_role
              from (
                  select
                       object_id doc_id, company_id
                  from
                       contract_doc_company
                  where
                       party_role = 'VENDOR' and
                       object_id = r2.object_id
                  minus
                  select
                         cd.object_id doc_id, cps.company_id
                  from
                       contract_party_share cps,
                       contract_doc cd
                  where
                       cps.party_role = 'VENDOR' and
                       cps.object_id = cd.contract_id and
                       cd.object_id = r2.object_id
              )
          )
          where
               doc_id = dcdc.object_id and
               company_id = dcdc.company_id and
               party_role = dcdc.party_role

      );
  END LOOP;

END UpdateDocumentVendorData;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : syncContractOwnerPayment
-- Description    : Will synch the payment date base code, payment terms, calendar collection - payment terms and payment scheme
--                  between document setup and document vendors business functions for vendor that has the role as contract owner.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: None
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE syncContractOwnerPayment(
   p_object_id  VARCHAR2,  -- contract doc id
   p_party_role VARCHAR2,
   p_daytime    DATE,
   p_class_name VARCHAR2
)

IS

lrec_cdv contract_doc_version%ROWTYPE;
lv2_contract_id VARCHAR2(32) := ec_contract_doc.contract_id(p_object_id);
lv2_fin_code    VARCHAR2(32) := ec_contract_version.financial_code(lv2_contract_id, p_daytime, '<=');
lv2_contract_company_id VARCHAR2(32) := ec_contract_version.company_id(lv2_contract_id, p_daytime, '<=');
lv2_vendor_id   VARCHAR2(32) := NULL;

CURSOR c_cdc(cp_vendor_id VARCHAR2) IS
SELECT cdc.*
  FROM contract_doc_company cdc
 WHERE cdc.object_id = p_object_id
   AND cdc.party_role = p_party_role
   AND cdc.company_id = cp_vendor_id
   AND cdc.daytime = p_daytime;

-- Get Contract owner vendor
CURSOR c_co_vend(cp_daytime DATE) IS
   SELECT object_id FROM company c
   WHERE class_name = 'VENDOR'
   AND c.company_id = lv2_contract_company_id;

-- Get Contract Vendors
CURSOR c_vend(cp_contract_id VARCHAR2) IS
   SELECT ps.company_id FROM contract_party_share ps
   WHERE ps.party_role = 'VENDOR'
   AND ps.object_id = cp_contract_id;

BEGIN


    -- Determine Vendor for this document setup, for getting correct payment info
    IF lv2_fin_code IN ('SALE','TA_INCOME','JOU_ENT') THEN

       -- When Sale or Tariff Income; Contract Owner Company is the Vendor to get payment info from
       FOR rsCOV IN c_co_vend(p_daytime) LOOP
          lv2_vendor_id := rsCOV.object_id;
       END LOOP;

    ELSIF lv2_fin_code IN ('PURCHASE','TA_COST') THEN

       -- When Purchase or Tariff Cost; The single Vendor is the Vendor to get payment info from
       FOR rsV IN c_vend(lv2_contract_id) LOOP
          lv2_vendor_id := rsV.Company_Id;
       END LOOP;
    END IF;



    IF p_class_name = 'CONTRACT_DOC_VENDORS' THEN

       FOR c_val IN c_cdc(lv2_vendor_id) LOOP

         UPDATE contract_doc_version cdv
            SET cdv.payment_scheme_id        = c_val.payment_scheme_id,
                cdv.payment_calendar_coll_id = c_val.payment_calendar_coll_id,
                cdv.payment_term_id          = c_val.payment_term_id,
                cdv.payment_term_base_code   = c_val.payment_term_base_code
          WHERE object_id = p_object_id;

       END LOOP;

    ELSIF p_class_name = 'CONTRACT_DOC' THEN

        lrec_cdv := ec_contract_doc_version.row_by_pk(p_object_id,p_daytime,'<=');

         UPDATE contract_doc_company cdc
            SET cdc.payment_scheme_id        = lrec_cdv.payment_scheme_id,
                cdc.payment_calendar_coll_id = lrec_cdv.payment_calendar_coll_id,
                cdc.payment_term_id          = lrec_cdv.payment_term_id,
                cdc.payment_term_base_code   = lrec_cdv.payment_term_base_code
          WHERE cdc.object_id = p_object_id
            AND cdc.company_id = lv2_vendor_id -- compare with the actual vendor object id
            AND cdc.party_role = p_party_role
            AND cdc.daytime >= lrec_cdv.daytime;

    END IF;


END syncContractOwnerPayment;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : syncContractOwnerDocPayment
-- Description    : Will synch the payment date base code, payment terms, calendar collection - payment terms and payment scheme
--                  between document setup and document vendors business functions for vendor that has the role as contract owner.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: None
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE syncContractOwnerDocPayment(p_document_key VARCHAR2,
                                      p_company_id   VARCHAR2)

IS

lv2_contract_owner_id VARCHAR2(32);


BEGIN

lv2_contract_owner_id := ec_cont_document.owner_company_id(p_document_key);


IF lv2_contract_owner_id = ec_company.company_id(p_company_id) THEN

   UPDATE cont_document d
   SET    d.pay_date = ec_cont_document_company.pay_date(p_document_key,p_company_id),
          d.payment_due_base_date = ec_cont_document_company.payment_due_base_date(p_document_key,p_company_id),
          d.last_updated_by = 'SYSTEM'
   WHERE  document_key = p_document_key;

END IF;


END syncContractOwnerDocPayment;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetDocCompanyNames
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: None
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION GetDocCompanyNames(
   p_document_key  VARCHAR2,
   p_company_type  VARCHAR2     -- CUSTOMER/VENDOR
) RETURN VARCHAR2
--</EC-DOC>
IS

cursor c_comp(p_doc_key varchar2, p_type varchar2) is
select
    ec_company_version.name(cdc.company_id, cd.daytime, '<=') name
from
    cont_document_company cdc,
    cont_document cd
where
    cd.document_key = p_doc_key and
    cdc.document_key = cd.document_key and
    cdc.company_role = p_type;

lv2_name  VARCHAR2(2000);
lb_first  BOOLEAN := true;

BEGIN

     FOR l_comp IN c_comp(p_document_key, p_company_type) LOOP
         IF lb_first THEN
            lv2_name := l_comp.name;
            lb_first := false;
         ELSE
             lv2_name := lv2_name || '/' || l_comp.name;
         END IF;
     END LOOP;

     RETURN lv2_name;

END GetDocCompanyNames;



FUNCTION GetContractCustomerId
(
    p_contract_object_id    VARCHAR2,
    p_daytime               DATE
)
RETURN VARCHAR2
IS

    CURSOR c_company_shares
    (
        cp_contract_object_id VARCHAR2,
        cp_daytime DATE
    )
    IS
        SELECT cps.company_id id
        FROM contract_party_share cps
        WHERE cps.object_id = cp_contract_object_id
            AND cps.party_role = 'CUSTOMER'
            AND cp_daytime >= Nvl(daytime, cp_daytime - 1)
            AND cp_daytime < Nvl(end_date, cp_daytime + 1);

    lv2_company_id VARCHAR2(32);
    ln_company_count NUMBER;
BEGIN
    ln_company_count := 0;

    FOR i_company IN c_company_shares(p_contract_object_id, p_daytime)
    LOOP
        lv2_company_id := i_company.id;
        ln_company_count := ln_company_count + 1;
    END LOOP;

    IF ln_company_count > 1
    THEN
        lv2_company_id := NULL;
    END IF;

    RETURN lv2_company_id;

END GetContractCustomerId;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetDocCustomerId
-- Description    : Gets the customid_id for a document from cont_document_company assuming single customer
--                  Returns null if multiple customers are assigned.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: None
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION GetDocCustomerId(
   p_document_key  VARCHAR2
) RETURN VARCHAR2
--</EC-DOC>
IS

cursor c_comp(p_doc_key varchar2) is
select
    cdc.company_id
from
    cont_document_company cdc
where
    cdc.document_key = p_doc_key and
    cdc.company_role = 'CUSTOMER';

lv2_id  VARCHAR2(2000);
lb_first  BOOLEAN := true;

BEGIN
    ECDP_REVN_ERROR.assert_argument_not_null('p_document_key', p_document_key);

     FOR l_comp IN c_comp(p_document_key) LOOP
         IF lb_first THEN
            lv2_id := l_comp.company_id;
            lb_first := false;
         ELSE
             --Multiple customers found
            lv2_id := NULL;
         END IF;
     END LOOP;

     RETURN lv2_id;

END GetDocCustomerId;


FUNCTION getNumSeq(p_number VARCHAR2, p_char VARCHAR2)
RETURN VARCHAR2
IS

lv2_seq VARCHAR2(32);

BEGIN

IF p_char IS NULL THEN
   RETURN NULL;
END IF;


FOR i IN 0..nvl(p_number,0)-1 LOOP
    lv2_seq := p_char||lv2_seq;
END LOOP;

RETURN lv2_seq;



END getNumSeq;



FUNCTION getNumericFormatString(p_left VARCHAR2,
                                p_decimals NUMBER)
RETURN VARCHAR2
IS

  ln_count NUMBER := 0;
  lv2_ret VARCHAR2(240) := p_left;

BEGIN

  IF NVL(p_decimals,0) > 0 THEN
     lv2_ret := lv2_ret || '.';
  END IF;


  WHILE ln_count < p_decimals LOOP

    lv2_ret := lv2_ret || '0';
    ln_count := ln_count + 1;

  END LOOP;

  RETURN lv2_ret;



END getNumericFormatString;

FUNCTION GetContractPartyComposition(
         p_contract_id VARCHAR2,
         p_daytime DATE)
RETURN VARCHAR2

IS

 CURSOR c_cont (cp_contract_id VARCHAR2, cp_daytime DATE) IS
   SELECT cps.party_role
     FROM contract_party_share cps
    WHERE cps.object_id = cp_contract_id
      AND cps.daytime <= cp_daytime
      AND nvl(cps.end_date, cp_daytime + 1) > cp_daytime;

 lv2_result VARCHAR2(32);
 ln_vend_cnt NUMBER := 0;
 ln_cust_cnt NUMBER := 0;

BEGIN

 FOR rsCont IN c_cont(p_contract_id, p_daytime) LOOP

   IF rsCont.Party_Role = 'CUSTOMER' THEN

     ln_cust_cnt := ln_cust_cnt + 1;

   ELSIF rsCont.Party_Role = 'VENDOR' THEN

     ln_vend_cnt := ln_vend_cnt + 1;

   END IF;

 END LOOP;

 IF ln_cust_cnt > 1 AND ln_vend_cnt > 1 THEN

   lv2_result := 'MVMC';

 ELSIF ln_cust_cnt = 1 AND ln_vend_cnt > 1 THEN

   lv2_result := 'MVSC';

 ELSIF ln_cust_cnt > 1 AND ln_vend_cnt = 1 THEN

   lv2_result := 'SVMC';

 ELSIF ln_cust_cnt = 1 AND ln_vend_cnt = 1 THEN

   lv2_result := 'SVSC';

 END IF;

 RETURN lv2_result;

END GetContractPartyComposition;

------------------------------------------------------------------------------------------------------------------------------

FUNCTION GetContractComposition(
         p_contract_id VARCHAR2,
         p_trans_tmpl_id VARCHAR2,
         p_daytime DATE)
RETURN VARCHAR2

IS

 CURSOR c_cont (cp_contract_id VARCHAR2, cp_daytime DATE) IS
   SELECT cps.party_role
     FROM contract_party_share cps
    WHERE cps.object_id = cp_contract_id
      AND cps.Party_Role = 'VENDOR'
      AND cps.daytime <= cp_daytime
      AND nvl(cps.end_date, cp_daytime + 1) > cp_daytime;

 lv2_result VARCHAR2(32);
 ln_vend_cnt NUMBER := 0;
 lv2_dist_type VARCHAR2(32) := ec_transaction_tmpl_version.dist_type(p_trans_tmpl_id, p_daytime, '<=');

BEGIN

 FOR rsCont IN c_cont(p_contract_id, p_daytime) LOOP

   ln_vend_cnt := ln_vend_cnt + 1;

 END LOOP;

 IF ln_vend_cnt > 1 AND lv2_dist_type = 'OBJECT' THEN

   lv2_result := 'MVSF';

 ELSIF ln_vend_cnt > 1 AND lv2_dist_type = 'OBJECT_LIST' THEN

   lv2_result := 'MVMF';

 ELSIF ln_vend_cnt = 1 AND lv2_dist_type = 'OBJECT' THEN

   lv2_result := 'SVSF';

 ELSIF ln_vend_cnt = 1 AND lv2_dist_type = 'OBJECT_LIST' THEN

   lv2_result := 'SVMF';

 END IF;

 RETURN lv2_result;

END GetContractComposition;


FUNCTION GetVendorComposition(
         p_contract_id VARCHAR2,
         p_daytime DATE)
RETURN VARCHAR2

IS

 CURSOR c_cont (cp_contract_id VARCHAR2, cp_daytime DATE) IS
   SELECT cps.party_role
     FROM contract_party_share cps
    WHERE cps.object_id = cp_contract_id
      AND cps.Party_Role = 'VENDOR'
      AND cps.daytime <= cp_daytime
      AND nvl(cps.end_date, cp_daytime + 1) > cp_daytime;

 lv2_result VARCHAR2(32);
 ln_vend_cnt NUMBER := 0;

BEGIN

 FOR rsCont IN c_cont(p_contract_id, p_daytime) LOOP

   ln_vend_cnt := ln_vend_cnt + 1;

 END LOOP;

 IF ln_vend_cnt > 1  THEN

   lv2_result := 'MV';

 ELSE

   lv2_result := 'SV';

 END IF;

 RETURN lv2_result;

END GetVendorComposition;

/* JDBC query
 */
PROCEDURE q_TransactionTemplate(p_cursor    OUT SYS_REFCURSOR,
                                p_object_id VARCHAR2,
                                p_daytime   DATE)


IS

BEGIN


  OPEN p_cursor FOR
SELECT tt.object_id, ttv.product_id, ttv.price_concept_code, ttv.price_object_id, ttv.daytime
  FROM transaction_template tt, transaction_tmpl_version ttv
 WHERE tt.object_id = p_object_id
   AND tt.object_id = ttv.object_id
   AND tt.start_date <= p_daytime
   AND p_daytime < nvl(tt.end_date, p_daytime + 1)
   AND ttv.daytime =
       (select max(v.daytime)
          from transaction_tmpl_version v
         WHERE v.object_id = tt.object_id
           AND v.daytime <= p_daytime
           AND p_daytime < Nvl(v.end_date, p_daytime + 1));



END q_TransactionTemplate;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION ContractHasDocSetupConcept(p_Contract_Id VARCHAR2,
                                    p_daytime DATE,
                                    p_doc_concept VARCHAR2,
                                    p_doc_setup_id OUT VARCHAR2)
RETURN BOOLEAN
IS

  ret_val BOOLEAN := FALSE;

  CURSOR c_ds IS
    SELECT cd.object_id
      FROM contract_doc cd, contract_doc_version cdv
     WHERE cd.object_id = cdv.object_id
       AND cd.contract_id = p_Contract_Id
       AND cdv.daytime <= p_daytime
       AND NVL(cdv.end_date, p_daytime+1) > p_daytime
       AND cdv.doc_concept_code LIKE p_doc_concept;

BEGIN

   FOR rsDS IN c_ds LOOP

     p_doc_setup_id := rsDS.Object_Id;
     ret_val := TRUE;

   END LOOP;

   RETURN ret_val;

END ContractHasDocSetupConcept;


FUNCTION ContractHasDocSetupConcept(p_Contract_Id VARCHAR2,
                                    p_daytime DATE,
                                    p_doc_concept VARCHAR2)
RETURN BOOLEAN
IS
  lv2_temp VARCHAR2(32);
BEGIN

  RETURN ContractHasDocSetupConcept(p_Contract_Id,
                                    p_daytime,
                                    p_doc_concept,
                                    lv2_temp);

END ContractHasDocSetupConcept;

PROCEDURE ValidateNewDocSetup(p_Contract_Id VARCHAR2,
                              p_daytime DATE,
                              p_doc_concept_code VARCHAR2)
IS
BEGIN

  IF p_doc_concept_code ='MULTI_PERIOD' AND EcDp_Contract_Setup.ContractHasDocSetupConcept(p_contract_id, p_daytime, 'MULTI_PERIOD') THEN
    Raise_Application_Error(-20000, 'It is only allowed to have ONE Multi Period Document Setup per contract.');
  END IF;

/*  IF p_doc_concept_code LIKE 'RECONCILIATION' AND EcDp_Contract_Setup.ContractHasDocSetupConcept(p_contract_id, p_daytime, '%PPA') THEN
    Raise_Application_Error(-20000, 'Only allowed with ONE Reconciliation Document Setup per contract.');
  END IF;*/

END ValidateNewDocSetup;

    ------------------------------------+-------------------------------------------------

    -- This function checks if a document has a single receiver because then the title
    -- page of the invoice should be able to be used as an invoice.
    FUNCTION HasSingleReceiver(
        p_document_key                  VARCHAR2)

    RETURN VARCHAR2
    IS

        CURSOR vat_Receiver(cp_document_key VARCHAR2)
        IS
            SELECT CDC.VAT_RECEIVER_ID  vend_id
            FROM cont_document_company cdc
            WHERE document_key = cp_document_key
                AND cdc.company_role = 'VENDOR';

        CURSOR exvat_Receiver(cp_document_key VARCHAR2)
        IS
            SELECT cdc.exvat_receiver_id vend_id
            FROM cont_document_company cdc
            WHERE document_key = cp_document_key
                AND cdc.company_role = 'VENDOR';

        lv2_vendor                      VARCHAR2(32);
        lb_multiple                     BOOLEAN := FALSE;
        lv2_return                      VARCHAR2(1);

    BEGIN

        FOR vat_vend IN vat_Receiver(p_document_key)
        LOOP
            IF lv2_vendor IS NULL
            THEN
                lv2_vendor := vat_vend.vend_id;
            ELSIF lv2_vendor != vat_vend.vend_id
            THEN
                lb_multiple := TRUE;
                EXIT;
            END IF;
        END LOOP;

        IF lb_multiple = FALSE
        THEN
            FOR vat_vend IN exvat_Receiver(p_document_key)
            LOOP
                IF lv2_vendor IS NULL
                THEN
                    lv2_vendor := vat_vend.vend_id;
                ELSIF lv2_vendor != vat_vend.vend_id
                THEN
                    lb_multiple := TRUE;
                    EXIT;
                END IF;
            END LOOP;
        END IF;

        IF lb_multiple
        THEN
            lv2_return := 'N';
        ELSE
            lv2_return := 'Y';
        END IF;

        RETURN lv2_return;
    END HasSingleReceiver;

    ------------------------------------+-------------------------------------------------

    FUNCTION IsAllowedContractCustomer(
        p_contract_id                   VARCHAR2,
        p_customer_id                   VARCHAR2,
        p_daytime                       DATE,
        p_d_contract_owner_id           VARCHAR2 DEFAULT NULL,
        p_d_restrict_customer_att       VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2
    IS
        lb_result                       VARCHAR2(1);

        lv2_contract_owner_id           VARCHAR2(32);
        lv2_restrict_customer_att       VARCHAR2(32);
    BEGIN

        lb_result := 'Y';
        lv2_restrict_customer_att := p_d_restrict_customer_att;
        lv2_contract_owner_id := p_d_contract_owner_id;

        IF lv2_contract_owner_id IS NULL
        THEN
            lv2_contract_owner_id := ec_contract_version.company_id(
                p_contract_id,
                p_daytime,
                '<=');
        END IF;

        IF lv2_restrict_customer_att IS NULL
        THEN
            lv2_restrict_customer_att := ec_ctrl_system_attribute.attribute_text(
                p_daytime,
                'RESTRICT_CUSTOMERS',
                '<=');
        END IF;

        IF lv2_restrict_customer_att = 'Y'
        THEN
            IF ec_CNTR_OWNER_CUSTOMER_SETUP.prev_equal_daytime(
                p_customer_id,
                lv2_contract_owner_id,
                p_daytime) IS NULL
            THEN
                lb_result := 'N';
            END IF;
        END IF;

        RETURN lb_result;
    END IsAllowedContractCustomer;

/* This function check will not allow Source price object and Source price element combination that has already been added as a Target Price object and Price element
    PROCEDURE IsSourceObjectisderived(p_src_price_object_id   VARCHAR2,p_price_element_code VARCHAR2,p_dayime DATE,p_end_date DATE) IS
    lv2_result varchar2(10) := 'false';

    CURSOR c_SourceObjectisderived IS
      SELECT OBJECT_ID,DAYTIME,END_DATE
        FROM DV_CNTR_DERIVED_PRICE_SETUP
        WHERE PRICE_ELEMENT_CODE=p_price_element_code;
    BEGIN
        FOR rs IN c_SourceObjectisderived LOOP
          IF ((p_src_price_object_id=rs.OBJECT_ID)AND((p_dayime BETWEEN rs.daytime AND rs.end_date-1) AND (nvl(p_end_date,rs.daytime+1) BETWEEN rs.daytime+1 AND rs.end_date-1))) THEN
            lv2_result:='true';
          END IF;
        END LOOP;

      IF lv2_result='true'
        THEN RAISE_APPLICATION_ERROR(-20000, 'Factor Price Objects can not have a Source Price Object / Source Price Element combination that has already been added as a Target Price Object / Target Price Element combination');
      END IF;

    END IsSourceObjectisderived;*/



------------------------------------+------------------------------------------------------------------------------
-- This procedure will not allow same Source and target Price Object / Source and target Price Element combination
------------------------------------+-----------------------------------------------------------------------------

	PROCEDURE IfSrcObjElmCodeSameAsTarget(p_target_price_object_id   VARCHAR2,p_target_price_element_code VARCHAR2,
										  p_source_price_object_id VARCHAR2,p_source_price_element_code VARCHAR2 ) IS
		lv2_result varchar2(10) := 'false';
	BEGIN
			IF(p_target_price_object_id = p_source_price_object_id AND p_target_price_element_code =p_source_price_element_code)
			THEN RAISE_APPLICATION_ERROR(-20000, '\nIllegal Combination!\n' || 'Factor Price Objects can not have same Source Price Object / Source Price Element and  Target Price Object / Target Price Element combination'||  '\n\nCall stack:');
			END IF;
    END IfSrcObjElmCodeSameAsTarget;



------------------------------------+-------------------------------------------------------
-- This procedure will not allow conflicts in Daytime and End date for the Target Price object
-- and Target Price Element Code in the Factor Price Object screen
------------------------------------+----------------------------------------------------------
 PROCEDURE IsdateConflicting(p_target_price_object_id   VARCHAR2,p_target_price_element_code VARCHAR2,
                              p_source_price_object_id VARCHAR2,p_source_price_element_code VARCHAR2 ,p_daytime DATE,p_end_date DATE ) IS

    lv2_result varchar2(10) := 'false';

   CURSOR c_daytime_end_date IS
      SELECT DAYTIME,END_DATE
        FROM DV_CNTR_DERIVED_PRICE_SETUP c
        WHERE c.OBJECT_ID=p_target_price_object_id
        AND c.PRICE_ELEMENT_CODE=p_target_price_element_code
        AND c.SRC_PRICE_OBJECT_ID = p_source_price_object_id
        AND c.SRC_PRICE_ELEMENT_CODE = p_source_price_element_code;
    BEGIN
    FOR rs IN c_daytime_end_date LOOP
        IF (
             (p_daytime between rs.daytime AND nvl(rs.end_date-1,CASE WHEN p_daytime > rs.daytime then p_daytime+1 else rs.daytime+1 END ))
             OR
             (p_end_date between rs.daytime+1 AND nvl(rs.end_date-1,nvl(p_end_date,CASE WHEN p_daytime > rs.daytime then p_daytime+1 else rs.daytime+1 END )))
              OR
              (p_daytime < rs.daytime   AND nvl(p_end_date,rs.daytime+1) > rs.daytime)
           ) THEN
           lv2_result:='true';
        END IF;
      END LOOP;

      IF lv2_result='true' THEN
         RAISE_APPLICATION_ERROR(-20000, '\nError!\n' ||'There is an overlapping "Daytime" and "End date" for the inserted/updated Target Price object-Target Price Element Code and Source price object-Source price element code combination'|| '\n\nCall stack:');
      END IF;

    END IsdateConflicting;

 ---------------------------------------------------------------------------------------------------------------


	FUNCTION IsPriceEditable(
    	p_price_object_id		VARCHAR2,
      p_price_element_code VARCHAR2)
    RETURN VARCHAR2
    IS
    lv2_return VARCHAR2(10):= 'true';

    CURSOR c_SourceObjectisderived IS
      SELECT OBJECT_ID
        FROM DV_CNTR_DERIVED_PRICE_SETUP
        WHERE PRICE_ELEMENT_CODE=p_price_element_code;
    BEGIN
      FOR rs IN c_SourceObjectisderived LOOP
          IF (p_price_object_id=rs.OBJECT_ID) THEN
            lv2_return:='false';
          END IF;
        END LOOP;
    RETURN lv2_return;
    END IsPriceEditable;
    ------------------------------------+-------------------------------------------------
    PROCEDURE IsdateOverlappingOnUpd(p_target_price_object_id   VARCHAR2,
                                  p_target_price_element_code VARCHAR2,
                                  p_source_price_object_id VARCHAR2,
                                  p_source_price_element_code VARCHAR2 ,
                                  p_daytime DATE,p_end_date DATE )
    IS
    lv2_result varchar2(10) := 'false';
     CURSOR c_cnt IS
      SELECT count(*) as cnt
        FROM DV_CNTR_DERIVED_PRICE_SETUP c
        WHERE c.OBJECT_ID=p_target_price_object_id
        AND c.PRICE_ELEMENT_CODE=p_target_price_element_code
        AND c.SRC_PRICE_OBJECT_ID = p_source_price_object_id
        AND c.SRC_PRICE_ELEMENT_CODE = p_source_price_element_code;
     CURSOR c_overlapping_date IS
      SELECT DAYTIME,END_DATE
        FROM DV_CNTR_DERIVED_PRICE_SETUP c
        WHERE c.OBJECT_ID=p_target_price_object_id
        AND c.PRICE_ELEMENT_CODE=p_target_price_element_code
        AND c.SRC_PRICE_OBJECT_ID = p_source_price_object_id
        AND c.SRC_PRICE_ELEMENT_CODE = p_source_price_element_code order by daytime;
    BEGIN

    FOR ls IN c_cnt LOOP
	IF( ls.cnt>1) THEN
    FOR rs IN c_overlapping_date LOOP

        IF(nvl(p_end_date,p_daytime) between rs.daytime+1 and nvl(rs.end_date-1,nvl(p_end_date,p_daytime+1))) then
         lv2_result:='true';
        END IF;
	END LOOP;

    IF lv2_result='true' THEN
         RAISE_APPLICATION_ERROR(-20000, '\nError!\n' ||'There is an overlapping "Daytime" and "End date" for the inserted/updated Target Price object-Target Price Element Code and Source price object-Source price element code combination'|| '\n\nCall stack:');
    END IF;
    END IF;
    END LOOP;
    END IsdateOverlappingOnUpd;


----------------------------------------------------------------------------------------------------------------------------

END Ecdp_Contract_Setup;