CREATE OR REPLACE PACKAGE EcDp_Staging_Document IS

  -- Author  : ROSNEDAG
  -- Created : 01.04.2011 10:44:10
  -- Purpose : Utility functions for supporting processing of staging documents.

/*  -- Public type declarations
  type <TypeName> is <Datatype>;

  -- Public constant declarations
  <ConstantName> constant <Datatype> := <Value>;

  -- Public variable declarations
  <VariableName> <Datatype>;*/




CURSOR gc_staging_doc_list(cp_staging_doc_status VARCHAR2) IS
  SELECT d.*
    FROM ft_st_document d
   WHERE d.staging_doc_status = cp_staging_doc_status
   ORDER BY d.created_date DESC;

-----------------------------------------------------------------------------------------------------------------------------

CURSOR gc_staging_trans_list(cp_contract_doc_id VARCHAR2) IS
  SELECT t.*
    FROM ft_st_transaction t, transaction_template tt
   WHERE t.trans_template_id = tt.object_id
     AND tt.contract_doc_id = cp_contract_doc_id;

-----------------------------------------------------------------------------------------------------------------------------

CURSOR gc_staging_transaction(cp_trans_template_id VARCHAR2,
                              cp_product_id VARCHAR2,
                              cp_price_concept_code VARCHAR2,
                              cp_delivery_point_id VARCHAR2,
                              cp_profit_center_id VARCHAR2,
                              cp_qty_type VARCHAR2
                              ) IS
  SELECT t.*
    FROM ft_st_transaction t
   WHERE t.trans_template_id = cp_trans_template_id
     AND t.product_id = cp_product_id
     AND t.price_concept_code = cp_price_concept_code
     AND t.delivery_point_id = cp_delivery_point_id
     AND t.profit_center_id = cp_profit_center_id
     AND t.qty_type = cp_qty_type;

-----------------------------------------------------------------------------------------------------------------------------

CURSOR gc_staging_line_item_list(cp_transaction_no NUMBER,
                                 cp_line_item_based_type VARCHAR2) -- optional
IS
  SELECT li.*
    FROM ft_st_line_item li
   WHERE li.ft_st_transaction_no = cp_transaction_no
     AND li.line_item_based_type = nvl(cp_line_item_based_type, li.line_item_based_type); -- optional

-----------------------------------------------------------------------------------------------------------------------------

CURSOR gc_staging_li_dist_list(cp_transaction_no NUMBER,
                               cp_line_item_no NUMBER) IS
  SELECT lid.*
    FROM ft_st_li_dist lid
   WHERE lid.ft_st_transaction_no = cp_transaction_no
     AND lid.ft_st_line_item_no = cp_line_item_no;

-----------------------------------------------------------------------------------------------------------------------------

CURSOR gc_staging_li_dist_item(cp_transaction_no NUMBER,
                               cp_line_item_no NUMBER,
                               cp_dist_id VARCHAR2) IS
  SELECT lid.*
    FROM ft_st_li_dist lid
   WHERE lid.ft_st_transaction_no = cp_transaction_no
     AND lid.ft_st_line_item_no = cp_line_item_no
     AND lid.dist_id = cp_dist_id;

-----------------------------------------------------------------------------------------------------------------------------

CURSOR gc_staging_lid_comp_list(cp_transaction_no NUMBER,
                               cp_dist_id VARCHAR2,
                               cp_line_item_no NUMBER) IS
  SELECT lidc.*
    FROM ft_st_li_dist_company lidc
   WHERE lidc.ft_st_transaction_no = cp_transaction_no
     AND lidc.ft_st_line_item_no = cp_line_item_no
     AND lidc.dist_id = cp_dist_id;

-----------------------------------------------------------------------------------------------------------------------------

CURSOR gc_staging_lid_comp_item(cp_transaction_no NUMBER,
                                cp_line_item_no NUMBER,
                                cp_dist_id VARCHAR2,
                                cp_vendor_id VARCHAR2) IS
  SELECT lidc.*
    FROM ft_st_li_dist_company lidc
   WHERE lidc.ft_st_transaction_no = cp_transaction_no
     AND lidc.ft_st_line_item_no = cp_line_item_no
     AND lidc.dist_id = cp_dist_id
     AND lidc.vendor_id = cp_vendor_id;

-----------------------------------------------------------------------------------------------------------------------------

CURSOR gc_field_dist(cp_trans_temp_code VARCHAR2,
                     cp_daytime DATE) IS
  SELECT ec_stream_item_version.field_id(sks.split_member_id, cp_daytime, '<=') field_id
    FROM transaction_template tt,
         transaction_tmpl_version ttv,
         split_key_setup sks
   WHERE tt.object_id = ttv.object_id
     AND tt.object_code = cp_trans_temp_code
     AND ttv.daytime = (SELECT MAX(daytime) FROM transaction_tmpl_version WHERE object_id = tt.object_id AND daytime <= cp_daytime)
     AND sks.object_id = ttv.split_key_id;
-----------------------------------------------------------------------------------------------------------------------------

CURSOR gc_company_dist(cp_trans_temp_code VARCHAR2,
                       cp_field_id VARCHAR2,
                       cp_daytime DATE) IS
  SELECT siv.company_id
    FROM transaction_template tt,
         transaction_tmpl_version ttv,
         split_key_setup sks,
         split_key_setup csks,
         stream_item_version siv
   WHERE tt.object_id = ttv.object_id
     AND tt.object_code = cp_trans_temp_code
     AND ttv.daytime = (SELECT MAX(daytime) FROM transaction_tmpl_version WHERE object_id = tt.object_id AND daytime <= cp_daytime)
     AND sks.object_id = ttv.split_key_id
     AND csks.object_id = sks.child_split_key_id
     AND ec_stream_item_version.field_id(sks.split_member_id, cp_daytime, '<=') = cp_field_id
     AND siv.object_id = csks.split_member_id
     AND siv.daytime = (SELECT MAX(daytime) FROM stream_item_version WHERE object_id = siv.object_id AND daytime <= cp_daytime);

-----------------------------------------------------------------------------------------------------------------------------

CURSOR gc_cont_li_dist(cp_transaction_key VARCHAR2) IS
SELECT DISTINCT clid.stream_item_id,
                clid.line_item_key,
                clid.dist_id
  FROM cont_line_item_dist clid
 WHERE clid.transaction_key = cp_transaction_key;

-----------------------------------------------------------------------------------------------------------------------------

CURSOR gc_cont_li_dist_comp(cp_transaction_key VARCHAR2, cp_line_item_key VARCHAR2, cp_field_id VARCHAR2) IS
SELECT DISTINCT clidc.company_stream_item_id,
                clidc.stream_item_id,
                clidc.dist_id,
                clidc.line_item_key,
                clidc.vendor_id,
                clidc.customer_id
  FROM cont_li_dist_company clidc
 WHERE clidc.transaction_key = cp_transaction_key
   AND clidc.line_item_key = cp_line_item_key
   AND clidc.dist_id = cp_field_id;

-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE q_StagingDocuments(p_cursor           OUT SYS_REFCURSOR,
                             p_contract_id      VARCHAR2,
                             p_contract_area_id VARCHAR2,
                             p_business_unit_id VARCHAR2);

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION GetTransTemplateID(p_contract_doc_id    VARCHAR2,
                            p_price_concept_code VARCHAR2,
                            p_delivery_point_id  VARCHAR2,
                            p_product_id         VARCHAR2,
                            p_daytime            DATE)
RETURN VARCHAR2;

END EcDp_Staging_Document;