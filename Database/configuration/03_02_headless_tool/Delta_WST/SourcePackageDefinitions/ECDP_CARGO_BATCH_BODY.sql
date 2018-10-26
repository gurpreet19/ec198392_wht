CREATE OR REPLACE PACKAGE BODY EcDp_Cargo_Batch IS
/******************************************************************************
** Package        :  EcDp_Cargo_Batch, body part
**
** $Revision: 1.6 $
**
** Purpose        :  Handles functinality around cargo batches
**
** Documentation  :  www.energy-components.com
**
** Created  	  :  10.01.2005 	Kari Sandvik
**
** Modification history:
**
** Date        	Whom  			Change description:
** ------      	----- 			-----------------------------------------------------------------------------------------------
** 17.07.2007   kaurrnar    ECPD5477 - Added p_lifting_event parameter to instansiate procedure
** 23.07.2007   kaurrnar    ECPD5477 - Added p_lifting_event parameter to apportionBatchQty procedure
** 22.01.2008   leong       ECPD-7125: Fixed bug in procedure apportionBatchQty
** 03.05.2017   asareswi    ECPD-44419 : Added validation to check balance_ind in apportionBatchQty procedure.
********************************************************************************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : instansiate
-- Description    : Instansiate measrement items for selected cargo batch
--
-- Preconditions  :
-- Postconditions :
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
PROCEDURE instansiate(p_cargo_bach_no NUMBER,
					p_lifting_event VARCHAR2,
					p_user_id VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS

CURSOR c_meas (cp_cargo_bach_no NUMBER)IS
	SELECT DISTINCT m.product_meas_no
	FROM cargo_stor_batch b,
	     storage_lift_nomination n,
	     stor_version v,
	     product_meas_setup m
	WHERE  b.cargo_batch_no = cp_cargo_bach_no
	       AND b.cargo_no = n.cargo_no
	       AND b.storage_id = n.object_id
	       AND n.object_id = v.object_id
	       AND v.daytime <= n.nom_firm_date
	       AND Nvl(v.end_date, n.nom_firm_date+1) > n.nom_firm_date
	       AND v.product_id = m.object_id
	       AND m.lifting_event = p_lifting_event ;

BEGIN
	 FOR curMeas IN c_meas(p_cargo_bach_no) LOOP
         INSERT INTO cargo_stor_batch_lifting (CARGO_BATCH_NO, PRODUCT_MEAS_NO, LIFTING_EVENT, created_by)
         VALUES (p_cargo_bach_no, curMeas.product_meas_no, p_lifting_event, p_user_id);
     END LOOP;

END instansiate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : deleteBatch
-- Description    : delete liftings for selected cargo batch
--
-- Preconditions  :
-- Postconditions :
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
PROCEDURE deleteBatch(p_cargo_bach_no NUMBER)
--</EC-DOC>
IS

BEGIN
	DELETE cargo_stor_batch_lifting WHERE CARGO_BATCH_NO = p_cargo_bach_no;
END deleteBatch;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : apportionBatchQty
-- Description    : Apporten the total quantity on the cargo and storage down to nominations
--
-- Preconditions  : Storage_lifting must have been instantiated. Meaning cargo must have cargo status = 'Official and ready for harbour' (or higher)
-- Postconditions :
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
PROCEDURE apportionBatchQty(p_cargo_no NUMBER,
							p_lifting_event VARCHAR2,
							p_user_id VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS
  lv_cargo_status VARCHAR2(1) := ec_cargo_transport.cargo_status(p_cargo_no);

	CURSOR c_parcels (cp_cargo_no NUMBER, cp_storage_id VARCHAR2)IS
		SELECT l.product_meas_no, sum(l.load_value) batch_qty, n.parcel_no, n.balance_ind, m.nom_unit_ind, n.grs_vol_nominated,
		       (SELECT count(n1.parcel_no)
    		      from storage_lift_nomination n1
    			   where n1.cargo_no = n.cargo_no
    			     and n1.object_id = n.object_id) parcels,
               (select count(s.parcel_no)
                 from storage_lift_nomination s
                  where s.cargo_no = n.cargo_no
                    and s.object_id = n.object_id
                    and nvl(s.balance_ind,'N') = 'Y') Bal_ind_cnt
		FROM cargo_stor_batch b,
		     cargo_stor_batch_lifting l,
		     storage_lift_nomination n,
		     product_meas_setup m
		WHERE b.cargo_no = cp_cargo_no
		      AND B.storage_id = cp_storage_id
		      AND b.cargo_batch_no = l.cargo_batch_no
		      AND b.cargo_no = n.cargo_no
		      AND b.storage_id = n.object_id
		      AND l.product_meas_no = m.product_meas_no
		      AND m.lifting_event = p_lifting_event
		GROUP BY l.product_meas_no, n.parcel_no, n.grs_vol_nominated, m.nom_unit_ind, n.balance_ind, n.cargo_no, n.object_id
		ORDER BY m.nom_unit_ind, l.product_meas_no, Nvl(n.balance_ind, 'N');

	CURSOR c_storage (cp_cargo_no NUMBER)IS
		SELECT b.storage_id, sum(l.load_value) batch_qty
		FROM	cargo_stor_batch b,
	        cargo_stor_batch_lifting l,
	        product_meas_setup m
		WHERE b.cargo_no = cp_cargo_no
	      AND b.cargo_batch_no = l.cargo_batch_no
	      AND l.product_meas_no = m.product_meas_no
	      AND m.nom_unit_ind = 'Y'
	      AND m.lifting_event = p_lifting_event
		GROUP BY b.storage_id    ;

	ln_tot_batch_nom  NUMBER;
	ln_rest		        NUMBER;
	ln_qty		        NUMBER;

BEGIN
    IF(lv_cargo_status != 'A') THEN
	    FOR curStorage IN c_storage(p_cargo_no) LOOP
		    ln_tot_batch_nom := curStorage.batch_qty;
		    ln_rest := NULL;

		    IF ln_tot_batch_nom IS NULL THEN
			    Raise_Application_Error(-20331,'Apportion cannot be performed if the measurement for Nomination Unit is NULL');
		    END IF;

		-- loop parcels and prod meas, balance nomination sorted as the last for each parcel
		    FOR curParcels IN c_parcels(p_cargo_no, curStorage.storage_id) LOOP
			    IF curParcels.parcels = 1 THEN -- if only one parcel all goes to that one

				      UPDATE storage_lifting SET load_value = curParcels.batch_qty, last_updated_by = p_user_id
				      WHERE parcel_no = curParcels.parcel_no AND product_meas_no = curParcels.product_meas_no;

			    ELSIF curParcels.balance_ind IS NULL OR curParcels.balance_ind = 'N' THEN
                    IF curParcels.Bal_ind_cnt = 0 then
                       Raise_Application_Error(-20585,'Apportion cannot be performed. Balance indicator is not set for any one of the nominations connected to the selected cargo.');
                    END IF;
				    IF curParcels.nom_unit_ind = 'Y' THEN
					    ln_qty := curParcels.grs_vol_nominated;
				    ELSE
					    ln_qty := (curParcels.grs_vol_nominated / ln_tot_batch_nom) * curParcels.batch_qty;
				    END IF;

				    UPDATE storage_lifting SET load_value = ln_qty, last_updated_by = p_user_id
				    WHERE parcel_no = curParcels.parcel_no AND product_meas_no = curParcels.product_meas_no;

				    ln_rest := Nvl(ln_rest, curParcels.batch_qty) - ln_qty;
			    ELSIF curParcels.balance_ind = 'Y' THEN
				    -- if last, then add the balance
				    UPDATE storage_lifting SET load_value = ln_rest, last_updated_by = p_user_id
				    WHERE parcel_no = curParcels.parcel_no AND product_meas_no = curParcels.product_meas_no;

				    ln_rest := NULL;
			    END IF;
		    END LOOP;
	    END LOOP;
    ELSE
       Raise_Application_Error(-20334,'Apportion can not be performed when the cargo has status Approved');
    END IF;
END apportionBatchQty;

END EcDp_Cargo_Batch;