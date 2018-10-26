CREATE OR REPLACE EDITIONABLE TRIGGER "IUD_T_IFAC_QTY" 
BEFORE INSERT OR UPDATE OR DELETE ON IFAC_QTY
FOR EACH ROW
-- $Revision: 1.2 $
DECLARE

   lrec_new IFAC_QTY%ROWTYPE;
BEGIN

   IF (:NEW.qty1 IS NULL AND :NEW.gcv IS NULL AND :NEW.density IS NULL AND :NEW.mcv IS NULL) THEN
      RAISE_APPLICATION_ERROR(-20000, 'No quantity or conversion factor supplied.');
   END IF;

   lrec_new.stream_item_code := :new.stream_item_code;
   lrec_new.node := :new.node;
   lrec_new.daytime := :New.daytime;
   lrec_new.day_mth := :New.day_mth;
   lrec_new.stream_item_category := :New.stream_item_category;
   lrec_new.product := :New.product;
   lrec_new.company := :New.company;
   lrec_new.profit_center := :New.profit_center;
   lrec_new.alloc_no := :New.alloc_no;
   lrec_new.qty1 := :New.qty1;
   lrec_new.uom1_code := :New.uom1_code;
   lrec_new.qty2 := :New.qty2;
   lrec_new.uom2_code := :New.uom2_code;
   lrec_new.qty3 := :New.qty3;
   lrec_new.uom3_code := :New.uom3_code;
   lrec_new.gcv := :New.gcv;
   lrec_new.gcv_energy_uom := :New.gcv_energy_uom;
   lrec_new.gcv_volume_uom := :New.gcv_volume_uom;
   lrec_new.density := :New.density;
   lrec_new.density_mass_uom := :New.density_mass_uom;
   lrec_new.density_volume_uom := :New.density_volume_uom;
   lrec_new.mcv := :New.mcv;
   lrec_new.mcv_energy_uom := :New.mcv_energy_uom;
   lrec_new.mcv_mass_uom := :New.mcv_mass_uom;
   lrec_new.status := :New.status;

   IF Inserting THEN
      :New.status := Ecdp_Inbound_Interface.TransferQuantitiesRecord(lrec_new, USER);
   ELSIF Updating THEN
      :New.status := Ecdp_Inbound_Interface.TransferQuantitiesRecord(lrec_new, USER);
   ELSIF Deleting THEN
      RAISE_APPLICATION_ERROR(-20000, 'Deletion is not allowed in EC Revenue interface table.');
   END IF;

END;
