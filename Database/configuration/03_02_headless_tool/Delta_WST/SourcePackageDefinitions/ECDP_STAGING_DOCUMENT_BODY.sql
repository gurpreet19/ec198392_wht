CREATE OR REPLACE PACKAGE BODY EcDp_Staging_Document IS

/*  -- Private type declarations
  type <TypeName> is <Datatype>;

  -- Private constant declarations
  <ConstantName> constant <Datatype> := <Value>;

  -- Private variable declarations
  <VariableName> <Datatype>;*/


--<EC-DOC>
-----------------------------------------------------------------------------------------------------------------------------
-- Function       : q_StagingDocuments
-- Description    :
-- Behaviour      :
-- Called from    :
-----------------------------------------------------------------------------------------------------------------------------
PROCEDURE q_StagingDocuments(p_cursor           OUT SYS_REFCURSOR,
                             p_contract_id      VARCHAR2,
                             p_contract_area_id VARCHAR2,
                             p_business_unit_id VARCHAR2)
--</EC-DOC>
IS

BEGIN

  OPEN p_cursor FOR
   SELECT d.*
     FROM ft_st_document        d,
          contract              c,
          contract_version      cv,
          contract_area         ca,
          contract_area_version cav,
          business_unit         bu,
          business_unit_version buv
    WHERE d.object_id = c.object_id
      AND cv.object_id = c.object_id
         -- Resolving contract
      AND c.object_id = nvl(p_contract_id, c.object_id)
      AND cv.daytime = (SELECT MAX(daytime)
                          FROM contract_version
                         WHERE object_id = c.object_id
                           AND daytime <= d.daytime)
      AND d.daytime < nvl(cv.end_date, d.daytime + 1)
         -- Resolving contract area
      AND cv.contract_area_id = ca.object_id
      AND cav.object_id = ca.object_id
      AND ca.object_id = nvl(p_contract_area_id, ca.object_id)
      AND cav.daytime = (SELECT MAX(daytime)
                           FROM contract_area_version
                          WHERE object_id = ca.object_id
                            AND daytime <= d.daytime)
      AND d.daytime < nvl(cav.end_date, d.daytime + 1)
         -- Resolving business unit
      AND cav.business_unit_id = bu.object_id
      AND buv.object_id = bu.object_id
      AND bu.object_id = nvl(p_business_unit_id, bu.object_id)
      AND buv.daytime = (SELECT MAX(buv.daytime)
                           FROM business_unit_version
                          WHERE object_id = bu.object_id
                            AND daytime <= d.daytime)
      AND d.daytime < nvl(buv.end_date, d.daytime + 1);

END q_StagingDocuments;


-----------------------------------------------------------------------------------------------------------------------------

FUNCTION GetTransTemplateID(p_contract_doc_id    VARCHAR2,
                            p_price_concept_code VARCHAR2,
                            p_delivery_point_id  VARCHAR2,
                            p_product_id         VARCHAR2,
                            p_daytime            DATE)
RETURN VARCHAR2
IS

  CURSOR c_tt IS
    SELECT tt.object_id
      FROM transaction_template tt,
           transaction_tmpl_version ttv,
           contract_doc cd
     WHERE tt.object_id = ttv.object_id
       AND ttv.daytime = (SELECT MAX(daytime) FROM transaction_tmpl_version WHERE object_id = tt.object_id AND daytime <= p_daytime)
       AND tt.contract_doc_id = p_contract_doc_id
       AND ttv.price_concept_code = p_price_concept_code
       AND ttv.delivery_point_id = p_delivery_point_id
       AND ttv.product_id = p_product_id
     ORDER BY tt.sort_order;

  lv2_tt transaction_template.object_id%TYPE;

BEGIN


  FOR rsTT IN c_tt LOOP

    IF lv2_tt IS NULL THEN
       lv2_tt := rsTT.Object_Id;
    END IF;

  END LOOP;

  RETURN lv2_tt;

END GetTransTemplateID;


END EcDp_Staging_Document;