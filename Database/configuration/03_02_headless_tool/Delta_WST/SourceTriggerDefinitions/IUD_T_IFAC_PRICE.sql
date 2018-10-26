CREATE OR REPLACE EDITIONABLE TRIGGER "IUD_T_IFAC_PRICE" 
BEFORE INSERT OR UPDATE OR DELETE ON IFAC_PRICE
FOR EACH ROW
-- $Revision: 1.1 $
DECLARE

   lrec_new IFAC_PRICE%ROWTYPE;
BEGIN

   lrec_new.contract_code := :New.contract_code;
   lrec_new.daytime := :New.daytime;
   lrec_new.product := :New.product;
   lrec_new.price_concept_code := :New.price_concept_code;
   lrec_new.price_element_code := :New.price_element_code;
   lrec_new.price_value := :New.price_value;
   lrec_new.currency_code := :New.currency_code;
   lrec_new.uom_code := :New.uom_code;
   lrec_new.status := :New.status;

   IF Inserting THEN
      :New.status := Ecdp_Inbound_Interface.TransferSPPricesRecord(lrec_new, USER);
   ELSIF Updating THEN
      :New.status := Ecdp_Inbound_Interface.TransferSPPricesRecord(lrec_new, USER);
   ELSIF Deleting THEN
      RAISE_APPLICATION_ERROR(-20000, 'Deletion is not allowed in EC Revenue interface table.');
   END IF;

END;
