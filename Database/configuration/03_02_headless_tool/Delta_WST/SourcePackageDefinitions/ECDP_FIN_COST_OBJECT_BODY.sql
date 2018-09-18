CREATE OR REPLACE PACKAGE BODY EcDp_Fin_Cost_Object IS
/****************************************************************
** Package        :  EcDp_Fin_Cost_Object, body part
**
** $Revision: 1.19 $
**
** Purpose        :  Provide special functions on Financials Cost Objects for interfacing with Finance applications
**
** Documentation  :  www.energy-components.com
**
** Created  : 01.10.2002  Henning Stokke
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
** 1.0      19.12.02 MVO   Replaced p_segment_obj_id with p_subsegment_id in SUBSEGMENT relation statement
** 1.3      22.09.03 TRA   Node check is skipped when p_financial_code (new param) is not a TA-code. QA: TKL
*****************************************************************/




--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  GetCostObjID
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
FUNCTION GetCostObjID(
   p_type VARCHAR2,
   p_company_id VARCHAR2,
   p_dist_id VARCHAR2,
   p_node_id VARCHAR2,
   p_line_item_type VARCHAR2,
   p_product_id VARCHAR2,
   p_daytime   DATE,
   p_line_item_key VARCHAR2 DEFAULT NULL,
   p_inventory_id VARCHAR2 DEFAULT NULL
)
RETURN fin_cost_object.object_id%TYPE
--</EC-DOC>
IS
lv2_object_id fin_cost_object.object_id%TYPE;
lv2_return_val VARCHAR2(240);

BEGIN

     IF (ue_Fin_Cost_Object.isUserExitEnabled = 'TRUE') THEN
         lv2_return_val := ue_Fin_Cost_Object.GetCostObjID(
                                              p_type,
                                              p_company_id,
                                              p_dist_id,
                                              p_node_id,
                                              p_line_item_type,
                                              p_product_id,
                                              p_daytime,
                                              p_line_item_key,
                                              p_inventory_id);
         RETURN lv2_return_val;
     ELSE


                FOR Obj1 IN gc_cost_obj(p_daytime,p_node_id,p_line_item_type,p_product_id,p_company_id,p_dist_id,p_type) LOOP

                   lv2_object_id := Obj1.id;

                   EXIT;

                END LOOP;
         RETURN lv2_object_id;
     END IF; -- User Exit
END GetCostObjID;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetCostObject
-- Description    : Takes the cost object ID and daytime as argument and look up the reference to the actual revenue order, wbs or cost center to be returned.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION GetCostObject(p_object_id VARCHAR2, p_daytime DATE)
  RETURN VARCHAR2

 IS

  lv2_type           fin_cost_object_version.fin_cost_object_type%type;
  lv2_cost_object_id fin_cost_object_version.fin_cost_object_id%type;

BEGIN

  lv2_type           := ec_fin_cost_object_version.fin_cost_object_type(p_object_id,p_daytime,'<=');
  lv2_cost_object_id := ec_fin_cost_object_version.fin_cost_object_id(p_object_id,p_daytime,'<=');

  IF lv2_type = 'C' THEN
    RETURN ec_fin_cost_center_version.cost_center(lv2_cost_object_id,p_daytime,'<=');
  ELSIF lv2_type = 'W' THEN
    RETURN ec_fin_wbs_version.wbs(lv2_cost_object_id, p_daytime, '<=');
  ELSIF lv2_type = 'O' THEN
    RETURN ec_fin_revenue_order_version.revenue_order(lv2_cost_object_id,p_daytime,'<=');

  END IF;
  RETURN NULL;

END GetCostObject;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetExternalRef
-- Description    : Takes the cost object ID and daytime as argument and look up the reference to the actual external ref to be returned.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION GetExternalRef(p_object_id VARCHAR2, p_daytime DATE)
  RETURN VARCHAR2

 IS

  lv2_type           fin_cost_object_version.fin_cost_object_type%type;
  lv2_cost_object_id fin_cost_object_version.fin_cost_object_id%type;

BEGIN

  lv2_type           := ec_fin_cost_object_version.fin_cost_object_type(p_object_id, p_daytime, '<=');
  lv2_cost_object_id := ec_fin_cost_object_version.fin_cost_object_id(p_object_id, p_daytime, '<=');

  IF lv2_type = 'C' THEN
    RETURN ec_fin_cost_center_version.fin_external_ref(lv2_cost_object_id,p_daytime,'<=');
  ELSIF lv2_type = 'W' THEN
    RETURN ec_fin_wbs_version.fin_external_ref(lv2_cost_object_id, p_daytime, '<=');
  ELSIF lv2_type = 'O' THEN
    RETURN ec_fin_revenue_order_version.fin_external_ref(lv2_cost_object_id,p_daytime,'<=');

  END IF;
  RETURN NULL;

END GetExternalRef;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : ValidateField
-- Description    : Validates that either a field, a profit center or both is added when creating a new cost object
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
PROCEDURE ValidateField(
          p_field_id                VARCHAR2,
          p_profit_center_id        VARCHAR2
          )
--</EC-DOC>
IS
BEGIN

IF (p_field_id IS NULL AND p_profit_center_id IS NULL) THEN
   Raise_Application_Error(-20000,'A Field, A Profit Center or both must be added in order to continue');
END IF;

END ValidateField;
-------------------------------------------------------------------------------------------------
-- Function       :  GetCostObjAccounts
-- Description    : Gives Cost Accounts as Priority.
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : FIN_COST_OBJECT, FIN_COST_OBJECT_VERSION
--
-- Using functions: Called from Cost Object Assistance screen.
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION GetCostObjAccounts(
   p_type                            VARCHAR2,
   p_company_id                      VARCHAR2,
   p_dist_type                       VARCHAR2,
   p_profit_centre_id                VARCHAR2,
   p_node_id	                     VARCHAR2,
   p_line_item_type                  VARCHAR2,
   p_product_id                      VARCHAR2,
   p_daytime                         DATE
 )
RETURN T_TABLE_MIXED_DATA
--</EC-DOC>
IS


lv2_object_id                 fin_cost_object.object_id%TYPE;
lv2_return_val                VARCHAR2(240);
lt_table_mixed_data           T_TABLE_MIXED_DATA;
lv_fin_cost_object_version    fin_cost_object_version%rowtype;


BEGIN
        lt_table_mixed_data := T_TABLE_MIXED_DATA();


        FOR Obj1 IN gc_cost_obj(p_daytime,p_node_id,p_line_item_type,p_product_id,p_company_id,p_profit_centre_id,p_type,p_dist_type) LOOP



          lv_fin_cost_object_version:=ec_fin_cost_object_version.row_by_pk(Obj1.id, p_daytime,'<=');

          lt_table_mixed_data.EXTEND(1);
          lt_table_mixed_data(lt_table_mixed_data.last):= T_MIXED_DATA(NULL,NULL);

          lt_table_mixed_data(lt_table_mixed_data.last).NUMBER_1                                 := Obj1.priority;
          lt_table_mixed_data(lt_table_mixed_data.last).TEXT_1                                   := ECDP_FIN_COST_OBJECT.GetCostObject(Obj1.id, p_daytime);
          lt_table_mixed_data(lt_table_mixed_data.last).TEXT_2                                   := ECDP_OBJECTS.GetObjName(Obj1.id,p_daytime);
          lt_table_mixed_data(lt_table_mixed_data.last).TEXT_3                                   := ECDP_OBJECTS.GetObjName(lv_fin_cost_object_version.fin_cost_object_id,p_daytime);
          lt_table_mixed_data(lt_table_mixed_data.last).TEXT_4                                   := EC_PROSTY_CODES.code_text(lv_fin_cost_object_version.fin_cost_object_type,'FIN_COST_OBJECT_TYPE');
          lt_table_mixed_data(lt_table_mixed_data.last).TEXT_5                                   := ECDP_OBJECTS.GetObjName(lv_fin_cost_object_version.company_id ,p_daytime);
          lt_table_mixed_data(lt_table_mixed_data.last).TEXT_6                                   := ECDP_OBJECTS.GetObjName(lv_fin_cost_object_version.profit_center_id,p_daytime);
          lt_table_mixed_data(lt_table_mixed_data.last).TEXT_7                                   := ECDP_OBJECTS.GetObjName(lv_fin_cost_object_version.node_id ,p_daytime);
          lt_table_mixed_data(lt_table_mixed_data.last).TEXT_8                                   := EC_PROSTY_CODES.code_text(lv_fin_cost_object_version.line_item_type ,'LINE_ITEM_TYPE');
          lt_table_mixed_data(lt_table_mixed_data.last).TEXT_9                                   := ECDP_OBJECTS.GetObjName(Obj1.product_id,p_daytime);

        END LOOP;


      RETURN lt_table_mixed_data;

END GetCostObjAccounts;
---------------------------------------------------------------------------------------------------------------------------------
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetCostObjSearchCriteria
-- Description    : Generate the Cost Object Search Criteria Result
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : iv_profit_centre, v_transaction_distribution, PRODUCT_VERSION, prosty_codes,
--                  line_item_template, line_item_tmpl_version, line_item_tmpl_version, fin_account_version
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION GetCostObjSearchCriteria(
          p_daytime                              DATE,
          p_contract_id                          VARCHAR2,
          p_transaction_template_id              varchar2,
          p_price_object_id                      VARCHAR2,
          p_line_item_id                         VARCHAR2,
          p_product_id                           VARCHAR2,
          p_line_item_type                       VARCHAR2,
          p_profit_center_id                     VARCHAR2,
          p_account_id                           VARCHAR2
          )
          RETURN T_TABLE_MIXED_DATA
--</EC-DOC>
IS

-- Cursor which gets dist id from object_list
CURSOR c_dist_id(cp_dist_id VARCHAR2,
                 cp_daytime DATE) IS
SELECT -- Object_list
 ipc.object_id as DIST_ID
  FROM iv_profit_centre ipc
 WHERE ipc.object_id in
       (SELECT ecdp_objects.getobjidfromcode(obls.generic_class_name,
                                             obls.generic_object_code)
          FROM object_list_setup obls
         WHERE obls.object_id = cp_dist_id
           AND obls.daytime <= cp_daytime
           AND nvl(obls.end_date, cp_daytime + 1) > cp_Daytime)
   AND ipc.daytime <= cp_daytime
   AND nvl(ipc.end_date, cp_daytime + 1) > cp_Daytime
UNION
SELECT -- object (only purpose is for date validation as id is already known)
 ipc.object_id as DIST_ID
  FROM iv_profit_centre ipc
 WHERE ipc.object_id = cp_dist_id
   AND ipc.daytime <= cp_daytime
   AND nvl(ipc.end_date, cp_daytime + 1) > cp_Daytime;


-- Cursor which gets the Stream item from transaction_distribution
CURSOR c_stream_id(cp_daytime DATE,
                   cp_product_id VARCHAR2,
                   cp_financial_code VARCHAR2,
                   cp_dist_type VARCHAR2,
                   cp_dist_id VARCHAR2,
                   cp_contract_company_code VARCHAR2,
                   cp_contract_comp VARCHAR2,
                   cp_profit_center_id VARCHAR2) IS
  SELECT
      vtd.object_id as Stream_Item_ID,
      vtd.object_code as Stream_Item_Code,
      vtd.stream_id as Stream_ID
  FROM
      v_transaction_distribution vtd
  WHERE
      vtd.product_id = cp_product_id
      AND vtd.financial_code = cp_financial_code
      AND vtd.daytime <= cp_daytime
      AND vtd.field_id = decode(cp_dist_type, 'OBJECT', cp_dist_id,
                                          'OBJECT_LIST', ec_field.object_id_by_uk('SUM', 'FIELD'),
                                          NULL)
      AND ec_company.object_code(vtd.company_id) LIKE decode(substr(cp_contract_comp, 0, 2), 'MV', '%_FULL', cp_contract_company_code)
  ORDER BY
      vtd.object_code
;

-- Cursor which gets the product
CURSOR c_current_product(cp_product_id VARCHAR2,
                         cp_price_object_id VARCHAR2,
                         cp_Contract_id varchar2,
                         cp_daytime date) is
    SELECT
           pv.object_id as product_id
    FROM
           PRODUCT_VERSION pv
    WHERE
           cp_product_id = pv.object_id
           AND pv.daytime <= cp_daytime
           AND nvl(pv.end_date, cp_daytime+1) > cp_daytime
  UNION
    SELECT
           pp.product_id
    FROM
           PRODUCT_PRICE pp
    WHERE
           cp_product_id IS NULL
           AND nvl(cp_price_object_id, pp.object_id) = pp.object_id
           AND pp.contract_id = cp_contract_id
           AND pp.start_date <= cp_daytime
           AND nvl(pp.end_date, pp.start_date+1) > cp_daytime
;

----- Cursor which gets the line item
CURSOR c_current_line_item(cp_line_item_type VARCHAR2,
                           cp_line_item_template_id VARCHAR2,
                           cp_trans_template_id VARCHAR2,
                           cp_daytime date) is
    SELECT
           code as line_item_type
    FROM
           prosty_codes
    WHERE
           CODE = cp_line_item_type
           AND code_type = 'LINE_ITEM_TYPE'
           AND IS_ACTIVE = 'Y'
  UNION
    SELECT
           litv.line_item_type
    FROM
           line_item_template lit,
           line_item_tmpl_version litv
    WHERE
           cp_line_item_type IS NULL
           AND lit.object_id = cp_line_item_template_id
           AND lit.object_id =  litv.object_id
           AND lit.transaction_template_id = cp_trans_template_id
           AND litv.daytime <= cp_daytime
           AND nvl(litv.end_date, cp_daytime+1) > cp_daytime
  UNION
    SELECT
           litv.line_item_type
    FROM
           transaction_tmpl_version ttv,
           line_item_template lit,
           line_item_tmpl_version litv
    WHERE
           cp_line_item_template_id IS NULL
           AND cp_trans_template_id = ttv.object_id
           AND lit.transaction_template_id = ttv.object_id
           AND lit.object_id =  litv.object_id
           AND litv.line_item_type = nvl(cp_line_item_type, litv.line_item_type)
           AND ttv.daytime <= cp_daytime
           AND nvl(ttv.end_date, cp_daytime+1) > cp_daytime
           AND litv.daytime <= cp_daytime
           AND nvl(litv.end_date, cp_daytime+1) > cp_daytime
;

----- Cursor which gets the cost object
CURSOR c_cost_obj( cp_daytime DATE,
                   cp_account_id VARCHAR2) IS
    SELECT
         pc.code as Cost_Object_Type
    FROM
         prosty_codes pc
    WHERE
         cp_account_id is null
         AND pc.code_type ='FIN_COST_OBJECT_TYPE'
         AND IS_ACTIVE = 'Y'
  UNION
    SELECT
         fav.fin_cost_object_type as Cost_Object_Type
    FROM
         fin_account fa,
         fin_account_version fav
    WHERE
         fa.object_id = cp_account_id
         AND fa.object_id = fav.object_id
         AND fav.daytime <= cp_daytime
         AND nvl(fav.end_date, cp_daytime+1) > cp_daytime
;

  --Table Type variable for returning Search Criteria
  lt_fin_cost_object            T_TABLE_MIXED_DATA;

  -- Exception variables
  no_cost_object           EXCEPTION;
  no_data                  EXCEPTION;

  -- local variable
  lv2_err_text             VARCHAR2(2000);
  l_index                  NUMBER := 0;
  lv2_node_id              VARCHAR2(32);
  lv2_node_code            VARCHAR2(32);
  lv2_node_name            VARCHAR2(32);
  lv2_financial_code       VARCHAR2(32);
  lv2_company_type         VARCHAR2(32);
  lv2_company_code         VARCHAR2(32);
  lv2_company_name         VARCHAR2(32);
  lv2_company_id           VARCHAR2(32);
  lv2_accnt_id             VARCHAR2(32);
  lv2_cost_obj_text        VARCHAR2(32);
  lv2_fin_cost_object      VARCHAR2(32);
  lv2_dist_type            VARCHAR2(32);
  lv2_dist_code            VARCHAR2(32);
  lv2_dist_id              VARCHAR2(32);
  lv2_trans_dist_id        VARCHAR2(32);
  lv2_dist_object_type     VARCHAR2(32);
  lv2_dist_object_name     VARCHAR2(32);
  lv2_contract_comp        VARCHAR2(32);
  lv2_stream_item_id       VARCHAR2(32);
  lv2_stream_id            VARCHAR2(32);
  lv2_stream_item_code     VARCHAR2(32);
  lv2_stream_item_name     VARCHAR2(240);
  lv2_profit_center_id     VARCHAR2(32);
  lv2_profit_center_code   VARCHAR2(32);
  lv2_profit_center_name   VARCHAR2(32);
  lv2_product_code         VARCHAR2(32);
  lv2_product_name         VARCHAR2(32);
  lv2_product_id           VARCHAR2(32);
  lv2_line_item_type       VARCHAR2(32);
  lv2_line_item_name       VARCHAR2(32);
  lv2_value_point          VARCHAR2(32);
  lv2_stream_ind           VARCHAR2(32);


BEGIN
     lt_fin_cost_object := T_TABLE_MIXED_DATA();

     IF (ue_Fin_Cost_Object.isUserExitEnabled = 'TRUE') THEN
         lt_fin_cost_object := ue_Fin_Cost_Object.GetCostObjSearchCriteria(
                                              p_daytime,
                                              p_contract_id,
                                              p_transaction_template_id,
                                              p_price_object_id,
                                              p_line_item_id,
                                              p_product_id,
                                              p_line_item_type,
                                              p_profit_center_id,
                                              p_account_id);
     ELSE
         -- get financial code from contract
         lv2_financial_code := ec_contract_version.financial_code(p_contract_id, p_daytime, '<=');

         -- get company type from financial code
         IF lv2_financial_code in ('SALE','TA_INCOME','JOU_ENT') THEN
           lv2_company_type :=  'VENDOR';
         ELSE
           lv2_company_type :=  'CUSTOMER';
         END IF;

         -- get company id from contract
         lv2_company_id := ec_contract_version.company_id(p_contract_id, p_daytime, '<=');
         -- get company code from company
         lv2_company_code := ec_company.object_code(lv2_company_id);
         lv2_company_name := ec_company_version.name(lv2_company_id, p_daytime, '<=');

         -- get contract_comp
         lv2_contract_comp := ecdp_contract_setup.GetContractComposition(p_contract_id,
                                          p_transaction_template_id, p_daytime);

         -- get dist type
         lv2_dist_type := ec_transaction_tmpl_version.dist_type(
                                          p_transaction_template_id, p_daytime, '<=');
         lv2_dist_object_type := ec_transaction_tmpl_version.dist_object_type(
                                          p_transaction_template_id, p_daytime, '<=');
         lv2_dist_object_name := EcDp_ClassMeta_Cnfg.getLabel(lv2_dist_object_type);
         lv2_dist_code := ec_transaction_tmpl_version.dist_code(
                                          p_transaction_template_id, p_daytime, '<=');

         IF (lv2_dist_type = 'OBJECT') THEN
            lv2_trans_dist_id := ecdp_objects.GetObjIDFromCode(lv2_dist_object_type,lv2_dist_code);
         ELSIF (lv2_dist_type = 'OBJECT_LIST') THEN
            lv2_trans_dist_id := ecdp_objects.GetObjIDFromCode('OBJECT_LIST',lv2_dist_code);
         END IF;



         -- get stream_ind
         lv2_stream_ind := ec_transaction_tmpl_version.use_stream_items_ind(
                                          p_transaction_template_id, p_daytime, '<=');

         FOR costObjCur in c_cost_obj (p_daytime, p_account_id) LOOP
           -- get cost object
           lv2_fin_cost_object := costObjCur.Cost_Object_Type;

           IF ( lv2_fin_cost_object IS NULl) THEN
              lv2_err_text := 'Cost Object => ' || lv2_fin_cost_object;
              RAISE no_cost_object;
           ELSE
               lv2_cost_obj_text := ec_prosty_codes.code_text(
                                           lv2_fin_cost_object,'FIN_COST_OBJECT_TYPE');

               FOR distCur in c_dist_id(lv2_trans_dist_id, p_daytime) LOOP

                 -- get Dist_id
                 lv2_dist_id := distCur.DIST_ID;

                 -- get profit_centre
                 lv2_profit_center_id := nvl(p_profit_center_id, lv2_dist_id);
                 lv2_profit_center_code := ecdp_objects.getobjcode(lv2_profit_center_id);
                 lv2_profit_center_name := ecdp_objects.GetObjName(lv2_profit_center_id, p_daytime);

                 FOR liCur in c_current_line_item(p_line_item_type,
                                                  p_line_item_id,
                                                  p_transaction_template_id,
                                                  p_daytime) LOOP

                     lv2_line_item_type := liCur.line_item_type;
                     lv2_line_item_name := ec_prosty_codes.code_text(
                                                  lv2_line_item_type,'LINE_ITEM_TYPE');

                     FOR prodCur in c_current_product(p_product_id,
                                                      p_price_object_id,
                                                      p_contract_id,
                                                      p_daytime) LOOP

                         -- get product
                         lv2_product_id := prodCur.product_id;
                         lv2_product_code := ec_product.object_code(lv2_product_id);
                         lv2_product_name := ec_product_version.name(lv2_product_id, p_daytime, '<=');

                         -- check if stream_item_indicator in transaction template
                         IF lv2_stream_ind = 'Y' THEN

                             FOR streamCur in c_stream_id( p_daytime,
                                                           lv2_product_id,
                                                           lv2_financial_code,
                                                           lv2_dist_type,
                                                           lv2_dist_id,
                                                           lv2_company_code,
                                                           lv2_contract_comp,
                                                           lv2_profit_center_id) LOOP

                                 lv2_stream_id := streamCur.Stream_Id;
                                 -- get stream item
                                 lv2_stream_item_id := streamCur.Stream_Item_Id;
                                 lv2_stream_item_code := streamCur.Stream_Item_Code;
                                 lv2_stream_item_name := ec_stream_item_version.name(lv2_stream_item_id, p_daytime, '<=');

                                 -- get node
                                 lv2_value_point := ec_stream_item_version.value_point(
                                                                lv2_stream_item_id, p_daytime, '<=');

                                 IF lv2_value_point = 'TO_NODE' THEN
                                   lv2_node_id := ec_strm_version.to_node_id(
                                                                lv2_stream_id, p_daytime, '<=');
                                 ELSIF lv2_value_point = 'FROM_NODE' THEN
                                   lv2_node_id := ec_strm_version.from_node_id(
                                                                lv2_stream_id, p_daytime, '<=');
                                 ELSE
                                   lv2_node_id := NULL;
                                 END IF;

                                 lv2_node_code := ec_node.object_code(lv2_node_id);
                                 lv2_node_name := ec_node_version.name(lv2_node_id, p_daytime, '<=');

                                 lt_fin_cost_object.extend(1);
                                 lt_fin_cost_object(lt_fin_cost_object.last)  := T_MIXED_DATA(lv2_stream_item_id, lv2_stream_item_code);
                                 lt_fin_cost_object(lt_fin_cost_object.last).TEXT_1 :=  lv2_fin_cost_object;
                                 lt_fin_cost_object(lt_fin_cost_object.last).TEXT_2 :=  lv2_cost_obj_text;
                                 lt_fin_cost_object(lt_fin_cost_object.last).TEXT_3 :=  lv2_company_id;
                                 lt_fin_cost_object(lt_fin_cost_object.last).TEXT_4 :=  lv2_company_name;
                                 lt_fin_cost_object(lt_fin_cost_object.last).TEXT_5 :=  lv2_stream_item_id;
                                 lt_fin_cost_object(lt_fin_cost_object.last).TEXT_6 :=  lv2_stream_item_name;
                                 lt_fin_cost_object(lt_fin_cost_object.last).TEXT_7 :=  lv2_dist_object_name;
                                 lt_fin_cost_object(lt_fin_cost_object.last).TEXT_8 :=  lv2_dist_object_type;
                                 lt_fin_cost_object(lt_fin_cost_object.last).TEXT_9 :=  lv2_profit_center_id;
                                 lt_fin_cost_object(lt_fin_cost_object.last).TEXT_10 :=  lv2_profit_center_name;
                                 lt_fin_cost_object(lt_fin_cost_object.last).TEXT_11 :=  lv2_node_id;
                                 lt_fin_cost_object(lt_fin_cost_object.last).TEXT_12 :=  lv2_node_name;
                                 lt_fin_cost_object(lt_fin_cost_object.last).TEXT_13 :=  lv2_line_item_name;
                                 lt_fin_cost_object(lt_fin_cost_object.last).TEXT_14 :=  lv2_line_item_type;
                                 lt_fin_cost_object(lt_fin_cost_object.last).TEXT_15 :=  lv2_product_name;
                                 lt_fin_cost_object(lt_fin_cost_object.last).TEXT_16 :=  lv2_product_id;

                             END LOOP; --  END streamCur
                          ELSE
                            ---------------
                                 lt_fin_cost_object.extend(1);
                                 lt_fin_cost_object(lt_fin_cost_object.last)  := T_MIXED_DATA(lv2_stream_item_id, lv2_stream_item_code);
                                 lt_fin_cost_object(lt_fin_cost_object.last).TEXT_1 :=  lv2_fin_cost_object;
                                 lt_fin_cost_object(lt_fin_cost_object.last).TEXT_2 :=  lv2_cost_obj_text;
                                 lt_fin_cost_object(lt_fin_cost_object.last).TEXT_3 :=  lv2_company_id;
                                 lt_fin_cost_object(lt_fin_cost_object.last).TEXT_4 :=  lv2_company_name;
                                 lt_fin_cost_object(lt_fin_cost_object.last).TEXT_6 := 'Not Stream Item Profit Centre';
                                 lt_fin_cost_object(lt_fin_cost_object.last).TEXT_7 :=  lv2_dist_object_name;
                                 lt_fin_cost_object(lt_fin_cost_object.last).TEXT_8 :=  lv2_dist_object_type;
                                 lt_fin_cost_object(lt_fin_cost_object.last).TEXT_9 :=  lv2_profit_center_id;
                                 lt_fin_cost_object(lt_fin_cost_object.last).TEXT_10 :=  lv2_profit_center_name;
                                 lt_fin_cost_object(lt_fin_cost_object.last).TEXT_13 :=  lv2_line_item_name;
                                 lt_fin_cost_object(lt_fin_cost_object.last).TEXT_14 :=  lv2_line_item_type;
                                 lt_fin_cost_object(lt_fin_cost_object.last).TEXT_15 :=  lv2_product_name;
                                 lt_fin_cost_object(lt_fin_cost_object.last).TEXT_16 :=  lv2_product_id;

                          END IF;
                       END LOOP; -- End prodCur
                   END LOOP; -- End liCur
               END LOOP; -- End distCur
            END IF; -- End no_cost_object
         END LOOP; -- End costObjCur
     END IF; -- End ue_Fin_Cost_Object

     RETURN lt_fin_cost_object;

EXCEPTION

     WHEN no_cost_object THEN
          Raise_Application_Error(-20000,'No cost object was found for ' || lv2_err_text);


END GetCostObjSearchCriteria;

END EcDp_Fin_Cost_Object;