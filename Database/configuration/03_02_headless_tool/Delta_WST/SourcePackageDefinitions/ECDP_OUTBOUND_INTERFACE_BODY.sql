CREATE OR REPLACE PACKAGE BODY EcDp_Outbound_Interface IS
/**************************************************************
** Package        :  EcDp_Outbound_Interface, body part
**
** $Revision: 1.10 $
**
**
** Purpose	:  ALL outbound DB interfaces
**
** General Logic:
**
** Modification history:
**
** Date:       Whom  Change description:
** ----------  ----  --------------------------------------------
** 30.12.2005  SRA   Initial version
**************************************************************/

   -- Handle for a clob
   v_iCLOB CLOB;
   pv2_clob_id NUMBER;

---------------------------------------------------------------------------------
FUNCTION TransferInventory(
p_inventory_id VARCHAR2 DEFAULT NULL
,p_daytime VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
IS
   lv2_id VARCHAR2(32);
   ld2_sDate DATE;
   lv2_path VARCHAR2(200);
   lv2_document_level_code VARCHAR2(200);
   lv2_business_code VARCHAR2(32);

CURSOR cinv_val(cp_object_id VARCHAR2, cp_daytime DATE) IS
SELECT * FROM inv_valuation
WHERE object_id = cp_object_id
AND daytime = cp_daytime;

BEGIN

   IF (ue_Outbound_Interface.isUserExitEnabled = 'TRUE') THEN
     lv2_id := ue_Outbound_Interface.TransferInventory(p_inventory_id, p_daytime);
     return lv2_id;
   ELSE

	   -- This function is project-specific.
	   RETURN NULL;

	   CLOBOpen;

	   -------------------------------------------------------------------------------------
	   -- The path should be built up with a PATH name from ctrl_property and a function for
	   -- generation of the correct filename for the interface file.
	   -------------------------------------------------------------------------------------

	   lv2_path := ec_ctrl_system_attribute.attribute_text(to_date(p_daytime,'yyyy-mm-dd"T"hh24:mi:ss'), 'FIN_INV_VAL_DIR', '<=') || 'inventory_' || SUBSTR(nvl(to_date(p_daytime,'yyyy-mm-dd"T"hh24:mi:ss'),ld2_sDate),1,10) || '.txt';
	   lv2_business_code := Ecdp_Objects.GetObjCode(Ecdp_Inventory.GetInventoryBusinessUnitID(p_inventory_id, to_date(p_daytime,'yyyy-mm-dd"T"hh24:mi:ss')));

	   CLOBwriteln('Inventory interface ');
	   CLOBwriteln('Inventory code : '  || ec_inventory.object_code(p_inventory_id));
	   CLOBwriteln('Inventory name : '  || ec_inventory_version.name(p_inventory_id, to_date(p_daytime,'yyyy-mm-dd"T"hh24:mi:ss'), '<='));
	   CLOBwriteln('Inventory daytime : '  || p_daytime);
	   FOR invVal IN cinv_val(p_inventory_id, to_date(p_daytime,'yyyy-mm-dd"T"hh24:mi:ss')) LOOP
	      CLOBwriteln('Inventory valuation Closing Price Value : '  || invVal.Closing_Price_Value );
	      CLOBwriteln('Inventory valuation Closing Memo Value : '  || invVal.Closing_Memo_Value );
	      CLOBwriteln('Inventory valuation Closing Booking Value : '  || invVal.Closing_Booking_Value );
	      CLOBwriteln('Inventory valuation Booking Date : '  || invVal.Booking_Date );
	      lv2_document_level_code := invVal.document_level_code;

	   END LOOP;
	   lv2_id := CLOBClose('IN','Inventory', lv2_business_code, lv2_path);

	   IF lv2_document_level_code = 'TRANSFER' THEN
	        UPDATE inv_valuation
	        SET transfer_date = Ecdp_Timestamp.getCurrentSysdate,
	            last_updated_by = 'INTERFACE'
	        WHERE object_id = p_inventory_id
	        AND daytime = to_date(p_daytime,'yyyy-mm-dd"T"hh24:mi:ss');
	   ELSIF lv2_document_level_code = 'OPEN' THEN
	        UPDATE inv_valuation
	        SET booking_date = NULL,
	            last_updated_by = 'INTERFACE'
	        WHERE object_id = p_inventory_id
	        AND daytime = to_date(p_daytime,'yyyy-mm-dd"T"hh24:mi:ss');

	   END IF;
   END IF;


   RETURN lv2_id;
END TransferInventory;
---------------------------------------------------------------------------------
FUNCTION TransferSPSales(
p_document_id VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
IS
   lv2_id VARCHAR2(32);
   ld2_sDate DATE;
   lv2_path VARCHAR2(200);
   lv2_business_code VARCHAR2(32);

CURSOR cdoc(cp_doc_id VARCHAR2) IS
SELECT * FROM cont_document x
WHERE document_key = NVL(cp_doc_id, document_key)
   AND x.document_level_code ='TRANSFER'
   AND x.fin_interface_file IS NULL
   AND x.financial_code  = 'SALE'
   AND x.book_document_ind = 'Y';

BEGIN

   IF (ue_Outbound_Interface.isUserExitEnabled = 'TRUE') THEN
     lv2_id := ue_Outbound_Interface.TransferSPSales(p_document_id);
     return lv2_id;
   ELSE
	   CLOBOpen;

	   -------------------------------------------------------------------------------------
	   -- The path should be built up with a PATH name from ctrl_property and a function for
	   -- generation of the correct filename for the interface file.
	   -------------------------------------------------------------------------------------

	   lv2_path := ec_ctrl_system_attribute.attribute_text(ec_cont_document.daytime(p_document_id), 'FIN_SALES_DIR', '<=') || 'spSales_' || SUBSTR(ld2_sDate,1,10) || '.txt';
       lv2_business_code := Ecdp_Objects.GetObjCode(Ecdp_Document.GetDocumentBusinessUnitID(p_document_id));

	   CLOBwriteln('SP sales interface ' || p_document_id);

	   FOR docs IN cdoc(p_document_id) LOOP
	       CLOBwriteln('Document Id ' || docs.document_key);
	       CLOBwriteln('Document Date ' || docs.document_date);
	       CLOBwriteln('Document Document Pricing Value : ' || ecdp_transaction.GetSumTransPricingValue(docs.document_key));
	       CLOBwriteln('Document Document Pricing Total : ' || ecdp_transaction.GetSumTransPricingTotal(docs.document_key));
	       CLOBwriteln('Document Document Booking Value : ' || docs.doc_booking_value);
	       CLOBwriteln('Document Document Booking Total : ' || docs.doc_booking_total);
	       CLOBwriteln('Document Document Memo Value : ' || docs.doc_memo_value);
	       CLOBwriteln('Document Document Memo Total : ' || docs.doc_memo_total);
	       CLOBwriteln('----------------------------------------------------------------');

	       -- Set the interface indicator
	       UPDATE cont_document SET fin_interface_file = 'FILE_TO_BE_GENERATED' -- lv2_path
	       WHERE document_key = docs.document_key;

	   END LOOP;

	   lv2_id := CLOBClose('SP','SPSales', lv2_business_code, lv2_path);

	   RETURN lv2_id;
	 END IF;
END TransferSPSales;
---------------------------------------------------------------------------------
FUNCTION TransferSPPurchases(
p_document_id VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
IS
   lv2_id VARCHAR2(32);
   ld2_sDate DATE;
   lv2_path VARCHAR2(200);
   lv2_business_code VARCHAR2(32);

CURSOR cdoc(cp_doc_id VARCHAR2) IS
SELECT * FROM cont_document x
WHERE document_key = NVL(cp_doc_id, document_key)
   AND x.document_level_code ='TRANSFER'
   AND x.fin_interface_file IS NULL
   AND x.financial_code  = 'PURCHASE'
   AND x.book_document_ind = 'Y';

BEGIN
  IF (ue_Outbound_Interface.isUserExitEnabled = 'TRUE') THEN
     lv2_id := ue_Outbound_Interface.TransferSPPurchases(p_document_id);
     return lv2_id;
   ELSE

	   CLOBOpen;

	   -------------------------------------------------------------------------------------
	   -- The path should be built up with a PATH name from ctrl_property and a function for
	   -- generation of the correct filename for the interface file.
	   -------------------------------------------------------------------------------------

	   lv2_path := ec_ctrl_system_attribute.attribute_text(ec_cont_document.daytime(p_document_id), 'FIN_PURCHASES_DIR', '<=') || 'spPurchases_' || SUBSTR(ld2_sDate,1,10) || '.txt';
       lv2_business_code := Ecdp_Objects.GetObjCode(Ecdp_Document.GetDocumentBusinessUnitID(p_document_id));


	   CLOBwriteln('SP purchases interface ' || p_document_id);

	   FOR docs IN cdoc(p_document_id) LOOP
	      CLOBwriteln('Document Id ' || docs.document_key);
	      CLOBwriteln('Document Date ' || docs.document_date);
	      CLOBwriteln('Document Document Pricing Value : ' || ecdp_transaction.GetSumTransPricingValue(docs.document_key));
	      CLOBwriteln('Document Document Pricing Total : ' || ecdp_transaction.GetSumTransPricingTotal(docs.document_key));
	      CLOBwriteln('Document Document Booking Value : ' || docs.doc_booking_value);
	      CLOBwriteln('Document Document Booking Total : ' || docs.doc_booking_total);
	      CLOBwriteln('Document Document Memo Value : ' || docs.doc_memo_value);
	      CLOBwriteln('Document Document Memo Total : ' || docs.doc_memo_total);
	      CLOBwriteln('----------------------------------------------------------------');

	       -- Set the interface indicator
	       UPDATE cont_document SET fin_interface_file = 'FILE_TO_BE_GENERATED' --lv2_path
	       WHERE document_key = docs.document_key;

	   END LOOP;

	   lv2_id := CLOBClose('SP','SPPurchases', lv2_business_code, lv2_path);

	   RETURN lv2_id;
   END IF;
END TransferSPPurchases;

---------------------------------------------------------------------------------
FUNCTION TransferSPTariffIncome(
p_document_id VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
IS
   lv2_id VARCHAR2(32);
   ld2_sDate DATE;
   lv2_path VARCHAR2(200);
   lv2_business_code VARCHAR2(32);

CURSOR cdoc(cp_doc_id VARCHAR2) IS
SELECT * FROM cont_document x
WHERE document_key = NVL(cp_doc_id, document_key)
   AND x.document_level_code ='TRANSFER'
   AND x.fin_interface_file IS NULL
   AND x.financial_code  = 'TA_INCOME'
   AND x.book_document_ind = 'Y';

BEGIN
  IF (ue_Outbound_Interface.isUserExitEnabled = 'TRUE') THEN
     lv2_id := ue_Outbound_Interface.TransferSPTariffIncome(p_document_id);
     return lv2_id;
   ELSE

	   CLOBOpen;

	   -------------------------------------------------------------------------------------
	   -- The path should be built up with a PATH name from ctrl_property and a function for
	   -- generation of the correct filename for the interface file.
	   -------------------------------------------------------------------------------------

	   lv2_path := ec_ctrl_system_attribute.attribute_text(ec_cont_document.daytime(p_document_id), 'FIN_TA_INCOME_DIR', '<=') || 'spTariffIncome_' || SUBSTR(ld2_sDate,1,10) || '.txt';
       lv2_business_code := Ecdp_Objects.GetObjCode(Ecdp_Document.GetDocumentBusinessUnitID(p_document_id));

	   CLOBwriteln('SP tariff income interface ' || p_document_id);

	   FOR docs IN cdoc(p_document_id) LOOP
	       CLOBwriteln('Document Id ' || docs.document_key);
	       CLOBwriteln('Document Date ' || docs.document_date);
	       CLOBwriteln('Document Document Pricing Value : ' || ecdp_transaction.GetSumTransPricingValue(docs.document_key));
	       CLOBwriteln('Document Document Pricing Total : ' || ecdp_transaction.GetSumTransPricingTotal(docs.document_key));
	       CLOBwriteln('Document Document Booking Value : ' || docs.doc_booking_value);
	       CLOBwriteln('Document Document Booking Total : ' || docs.doc_booking_total);
	       CLOBwriteln('Document Document Memo Value : ' || docs.doc_memo_value);
	       CLOBwriteln('Document Document Memo Total : ' || docs.doc_memo_total);
	       CLOBwriteln('----------------------------------------------------------------');

	       -- Set the interface indicator
	       UPDATE cont_document SET fin_interface_file = 'FILE_TO_BE_GENERATED'--lv2_path
	       WHERE document_key = docs.document_key;

	   END LOOP;

	   lv2_id := CLOBClose('SP','SPTariffIncome', lv2_business_code, lv2_path);

	   RETURN lv2_id;
   END IF;
END TransferSPTariffIncome;

---------------------------------------------------------------------------------
FUNCTION TransferSPTariffCost(
p_document_id VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
IS
   lv2_id VARCHAR2(32);
   ld2_sDate DATE;
   lv2_path VARCHAR2(200);
   lv2_business_code VARCHAR2(32);

CURSOR cdoc(cp_doc_id VARCHAR2) IS
SELECT * FROM cont_document x
WHERE document_key = NVL(cp_doc_id, document_key)
   AND x.document_level_code ='TRANSFER'
   AND x.fin_interface_file IS NULL
   AND x.financial_code  = 'TA_COST'
   AND x.book_document_ind = 'Y';

BEGIN
  IF (ue_Outbound_Interface.isUserExitEnabled = 'TRUE') THEN
     lv2_id := ue_Outbound_Interface.TransferSPTariffCost(p_document_id);
     return lv2_id;
   ELSE
	   CLOBOpen;

	   -------------------------------------------------------------------------------------
	   -- The path should be built up with a PATH name from ctrl_property and a function for
	   -- generation of the correct filename for the interface file.
	   -------------------------------------------------------------------------------------

	   lv2_path := ec_ctrl_system_attribute.attribute_text(ec_cont_document.daytime(p_document_id), 'FIN_TA_COST_DIR', '<=') || 'spTariffCost_' || SUBSTR(ld2_sDate,1,10) || '.txt';
       lv2_business_code := Ecdp_Objects.GetObjCode(Ecdp_Document.GetDocumentBusinessUnitID(p_document_id));

	    CLOBwriteln('SP tariff cost interface ' || p_document_id);

	   FOR docs IN cdoc(p_document_id) LOOP
 	       CLOBwriteln('Document Id ' || docs.document_key);
 	       CLOBwriteln('Document Date ' || docs.document_date);
 	       CLOBwriteln('Document Document Pricing Value : ' || ecdp_transaction.GetSumTransPricingValue(docs.document_key));
 	       CLOBwriteln('Document Document Pricing Total : ' || ecdp_transaction.GetSumTransPricingTotal(docs.document_key));
 	       CLOBwriteln('Document Document Booking Value : ' || docs.doc_booking_value);
 	       CLOBwriteln('Document Document Booking Total : ' || docs.doc_booking_total);
         CLOBwriteln('Document Document Memo Value : ' || docs.doc_memo_value);
	       CLOBwriteln('Document Document Memo Total : ' || docs.doc_memo_total);
	       CLOBwriteln('----------------------------------------------------------------');

	       -- Set the interface indicator
	       UPDATE cont_document SET fin_interface_file = 'FILE_TO_BE_GENERATED'--lv2_path
	       WHERE document_key = docs.document_key;

	   END LOOP;

	   lv2_id := CLOBClose('SP','SPTariffCost', lv2_business_code, lv2_path);

	   RETURN lv2_id;
   END IF;
END TransferSPTariffCost;
---------------------------------------------------------------------------------
FUNCTION TransferSPJournalEntry(
p_document_id VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
IS
   lv2_id VARCHAR2(32);
   ld2_sDate DATE;
   lv2_path VARCHAR2(200);
   lv2_business_code VARCHAR2(32);

CURSOR cdoc(cp_doc_id VARCHAR2) IS
SELECT * FROM cont_document x
WHERE document_key = NVL(cp_doc_id, document_key)
   AND x.document_level_code ='TRANSFER'
   AND x.fin_interface_file IS NULL
   AND x.financial_code  = 'JOU_ENT'
   AND x.book_document_ind = 'Y';

BEGIN

   IF (ue_Outbound_Interface.isUserExitEnabled = 'TRUE') THEN
     lv2_id := ue_Outbound_Interface.TransferSPJournalEntry(p_document_id);
     return lv2_id;
   ELSE
	   CLOBOpen;

	   -------------------------------------------------------------------------------------
	   -- The path should be built up with a PATH name from ctrl_property and a function for
	   -- generation of the correct filename for the interface file.
	   -------------------------------------------------------------------------------------

	   lv2_path := ec_ctrl_system_attribute.attribute_text(ec_cont_document.daytime(p_document_id), 'FIN_JOU_ENT_DIR', '<=') || 'spJournalEntry_' || SUBSTR(ld2_sDate,1,10) || '.txt';
       lv2_business_code := Ecdp_Objects.GetObjCode(Ecdp_Document.GetDocumentBusinessUnitID(p_document_id));

	   CLOBwriteln('SP journal entry interface ' || p_document_id);

	   FOR docs IN cdoc(p_document_id) LOOP
           CLOBwriteln('Document Id ' || docs.document_key);
 	       CLOBwriteln('Document Date ' || docs.document_date);
 	       CLOBwriteln('Document Document Pricing Value : ' || ecdp_transaction.GetSumTransPricingValue(docs.document_key));
 	       CLOBwriteln('Document Document Pricing Total : ' || ecdp_transaction.GetSumTransPricingTotal(docs.document_key));
 	       CLOBwriteln('Document Document Booking Value : ' || docs.doc_booking_value);
 	       CLOBwriteln('Document Document Booking Total : ' || docs.doc_booking_total);
 	       CLOBwriteln('Document Document Memo Value : ' || docs.doc_memo_value);
  	       CLOBwriteln('Document Document Memo Total : ' || docs.doc_memo_total);
 	       CLOBwriteln('----------------------------------------------------------------');

	       -- Set the interface indicator
	       UPDATE cont_document SET fin_interface_file = 'FILE_TO_BE_GENERATED' -- lv2_path
	       WHERE document_key = docs.document_key;

	   END LOOP;

	   lv2_id := CLOBClose('SP','SPJournalEntry', lv2_business_code, lv2_path);

	   RETURN lv2_id;
	 END IF;
END TransferSPJournalEntry;

-----------------------------------------------------------------------------------------------------------------------------
FUNCTION TransferERPDocument(
         p_document_id VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
IS

   lv2_id VARCHAR2(32);
   lv2_path VARCHAR2(200);
   lv2_business_code VARCHAR2(32);

CURSOR cdoc(cp_doc_id VARCHAR2) IS
  SELECT x.*,
         (SELECT nvl(sum(booking_amount),0) from cont_erp_postings where document_key = x.document_key) sum_booking_amount,
         (SELECT nvl(sum(local_amount),0) from cont_erp_postings where document_key = x.document_key) sum_local_amount
    FROM cont_document x
   WHERE x.document_key = NVL(cp_doc_id, x.document_key)
     AND x.document_level_code ='TRANSFER'
     AND x.fin_interface_file IS NULL
     AND x.ext_document_key IS NOT NULL
     AND x.book_document_ind = 'Y';

BEGIN

   IF (ue_Outbound_Interface.isUserExitEnabled = 'TRUE') THEN

     lv2_id := ue_Outbound_Interface.TransferERPDocument(p_document_id);
     return lv2_id;

   ELSE

	   CLOBOpen;

	   -------------------------------------------------------------------------------------
	   -- The path should be built up with a PATH name from ctrl_property and a function for
	   -- generation of the correct filename for the interface file.
	   -------------------------------------------------------------------------------------

	   lv2_path := ec_ctrl_system_attribute.attribute_text(ec_cont_document.daytime(p_document_id), 'FIN_ERP_DOC_DIR', '<=') || 'spERPDoc_' || SUBSTR(Ecdp_Timestamp.getCurrentSysdate,1,10) || '.txt';
       lv2_business_code := Ecdp_Objects.GetObjCode(Ecdp_Document.GetDocumentBusinessUnitID(p_document_id));

	   CLOBwriteln('ERP Document interface: ' || p_document_id);

	   FOR docs IN cdoc(p_document_id) LOOP
            CLOBwriteln('Document Key: '           || docs.document_key);
            CLOBwriteln('External Document Key: '  || docs.ext_document_key);
            CLOBwriteln('Document Date: '          || docs.document_date);
            CLOBwriteln('Document Booking Value: ' || docs.sum_booking_amount);
            CLOBwriteln('Document Local Value: '   || docs.sum_local_amount);
            CLOBwriteln('----------------------------------------------------------------');

            -- Set the interface indicator
            UPDATE cont_document
            SET fin_interface_file = 'FILE_TO_BE_GENERATED' -- lv2_path
            WHERE document_key = docs.document_key;

	   END LOOP;

	   lv2_id := CLOBClose('SP','spERPDoc', lv2_business_code, lv2_path);

	   RETURN lv2_id;
	 END IF;

END TransferERPDocument;


---------------------------------------------------------------------------------
--- BASIC FUNCTIONS BELLOW THIS LINE
---------------------------------------------------------------------------------

PROCEDURE CLOBOpen
IS
BEGIN
   DBMS_LOB.CREATETEMPORARY(v_iCLOB, TRUE);
   -- DBMS_LOB.open(v_iCLOB, DBMS_LOB.lob_readwrite);
END CLOBOpen;
---------------------------------------------------------------------------------
FUNCTION CLOBClose(
  p_module VARCHAR2
  ,p_interface_type VARCHAR2
  ,p_business_unit_code VARCHAR2
  ,p_path  VARCHAR2
) RETURN VARCHAR2
IS
BEGIN
   INSERT INTO INTERFACE_CONTENT (FUNCTIONAL_AREA_CODE, INTERFACE_TYPE, BUSINESS_UNIT_CODE, PATH, FILE_CONTENT) VALUES (p_module, p_interface_type, p_business_unit_code, p_path, v_iCLOB)
   RETURNING INTERFACE_NO INTO pv2_clob_id;
   RETURN pv2_clob_id;
END CLOBClose;
---------------------------------------------------------------------------------
PROCEDURE CLOBwriteln(
  p_Text  IN  VARCHAR2
) IS
   n_Length NUMBER := 0;
   v_Text VARCHAR2(2000) := NULL;
BEGIN
    v_Text := p_Text || CHR(10) || CHR(13);
    n_Length := length(v_Text);
    DBMS_LOB.writeappend(v_iCLOB, n_Length, v_Text);
END CLOBwriteln;
---------------------------------------------------------------------------------

END EcDp_Outbound_Interface;