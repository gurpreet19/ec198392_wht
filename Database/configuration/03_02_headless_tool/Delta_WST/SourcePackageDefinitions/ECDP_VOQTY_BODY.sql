CREATE OR REPLACE PACKAGE BODY EcDp_VOQty IS
/****************************************************************
** Package        :  EcDp_VOQty, body part
**
** $Revision: 1.10 $
**
** Purpose        :  Provide functionality to replace to original VO qtys when needed
**
** Documentation  :  www.energy-components.com
**
** Created  : 20.01.2004  Trond-Arne Brattli
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- --------------------------------------
** 13.12.2006  DN    Removed document_key column. Added documentation header.
*****************************************************************/

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Procedure      : StoreVOQty
-- Description    : Stores VO quantities
-- Preconditions  :
-- Postconditions : Uncommited changes.
--
-- Using tables   : cont_qty_stim_mth_value
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------
PROCEDURE StoreVOQty(
        p_object_id VARCHAR2,
        p_transaction_id VARCHAR2,
        p_stream_item_id VARCHAR2,
        p_transaction_date DATE,
        p_user VARCHAR2
)
--</EC-DOC>
IS

CURSOR c_cq_smv(pc_daytime DATE) IS
SELECT *
FROM cont_qty_stim_mth_value
WHERE stream_item_id = p_stream_item_id
AND daytime = pc_daytime
;

ld_daytime DATE;
lrec_cq_smv cont_qty_stim_mth_value%ROWTYPE;
lrec_smv stim_mth_value%ROWTYPE;

BEGIN

   ld_daytime := trunc(p_transaction_date,'MM');

   -- find values
   FOR Cq_smv in c_cq_smv(ld_daytime) LOOP

       lrec_cq_smv := Cq_smv;

   END LOOP;

   -- if lrec_cq_smv.contract_object_id is not null,
   -- current stream_item is already in use
   -- and qtys for the new record must be
   -- copied from another in cont_qty_stim_mth_value

   IF lrec_cq_smv.object_id IS NOT NULL THEN

     INSERT INTO cont_qty_stim_mth_value
        (object_id
        ,transaction_key
        ,transaction_date
        ,stream_item_id
        ,daytime
        ,created_by
        ,status
        ,period_ref_item
        ,calc_method
        ,net_mass_value
        ,mass_uom_code
        ,net_volume_value
        ,volume_uom_code
        ,net_energy_value
        ,energy_uom_code
        ,net_extra1_value
        ,extra1_uom_code
        ,net_extra2_value
        ,extra2_uom_code
        ,net_extra3_value
        ,extra3_uom_code
        ,gcv
        ,gcv_energy_uom
        ,gcv_volume_uom
        ,density
        ,density_mass_uom
        ,density_volume_uom
        ,mcv
        ,mcv_energy_uom
        ,mcv_mass_uom

        )
     VALUES
        (p_object_id
        ,p_transaction_id
        ,p_transaction_date
        ,p_stream_item_id
        ,ld_daytime
        ,p_user
        ,lrec_cq_smv.status
        ,lrec_cq_smv.period_ref_item
        ,lrec_cq_smv.calc_method
        ,lrec_cq_smv.net_mass_value
        ,lrec_cq_smv.mass_uom_code
        ,lrec_cq_smv.net_volume_value
        ,lrec_cq_smv.volume_uom_code
        ,lrec_cq_smv.net_energy_value
        ,lrec_cq_smv.energy_uom_code
        ,lrec_cq_smv.net_extra1_value
        ,lrec_cq_smv.extra1_uom_code
        ,lrec_cq_smv.net_extra2_value
        ,lrec_cq_smv.extra2_uom_code
        ,lrec_cq_smv.net_extra3_value
        ,lrec_cq_smv.extra3_uom_code
        ,lrec_cq_smv.gcv
        ,lrec_cq_smv.gcv_energy_uom
        ,lrec_cq_smv.gcv_volume_uom
        ,lrec_cq_smv.density
        ,lrec_cq_smv.density_mass_uom
        ,lrec_cq_smv.density_volume_uom
        ,lrec_cq_smv.mcv
        ,lrec_cq_smv.mcv_energy_uom
        ,lrec_cq_smv.mcv_mass_uom
       );


   -- otherwise,
   -- the values must be copied from stim_mth_value
   ELSE

     lrec_smv := ec_stim_mth_value.row_by_pk(p_stream_item_id,ld_daytime);

     -- but if the si's calc_method is SP,
     -- it means that it is already in use
     -- in a document which is booked.
     -- then no use to continue
     IF nvl(lrec_smv.calc_method,'NA') = 'SP' THEN

       RETURN;

     END IF;

     INSERT INTO cont_qty_stim_mth_value
        (object_id
        ,transaction_key
        ,transaction_date
        ,stream_item_id
        ,daytime
        ,created_by
        ,status
        ,period_ref_item
        ,calc_method
        ,net_mass_value
        ,mass_uom_code
        ,net_volume_value
        ,volume_uom_code
        ,net_energy_value
        ,energy_uom_code
        ,net_extra1_value
        ,extra1_uom_code
        ,net_extra2_value
        ,extra2_uom_code
        ,net_extra3_value
        ,extra3_uom_code
        ,gcv
        ,gcv_energy_uom
        ,gcv_volume_uom
        ,density
        ,density_mass_uom
        ,density_volume_uom
        ,mcv
        ,mcv_energy_uom
        ,mcv_mass_uom
        )
     VALUES
        (p_object_id
        ,p_transaction_id
        ,p_transaction_date
        ,p_stream_item_id
        ,ld_daytime
        ,p_user
        ,lrec_smv.status
        ,lrec_smv.period_ref_item
        ,lrec_smv.calc_method
        ,lrec_smv.net_mass_value
        ,lrec_smv.mass_uom_code
        ,lrec_smv.net_volume_value
        ,lrec_smv.volume_uom_code
        ,lrec_smv.net_energy_value
        ,lrec_smv.energy_uom_code
        ,lrec_smv.net_extra1_value
        ,lrec_smv.extra1_uom_code
        ,lrec_smv.net_extra2_value
        ,lrec_smv.extra2_uom_code
        ,lrec_smv.net_extra3_value
        ,lrec_smv.extra3_uom_code
        ,lrec_smv.gcv
        ,lrec_smv.gcv_energy_uom
        ,lrec_smv.gcv_volume_uom
        ,lrec_smv.density
        ,lrec_smv.density_mass_uom
        ,lrec_smv.density_volume_uom
        ,lrec_smv.mcv
        ,lrec_smv.mcv_energy_uom
        ,lrec_smv.mcv_mass_uom
       );

   END IF;

   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN

           NULL;  -- Record exists, don't do anything.

END StoreVOQty;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Procedure      : ReStoreVOQty
-- Description    : RE-stores VO quantities. This procedure should be called when a transaction is deleted.
-- Preconditions  :
-- Postconditions : Uncommited changes.
--
-- Using tables   : cont_qty_stim_mth_value
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : If no remaining transactions using this exists, original qtys are written back to VO.
--
-----------------------------------------------------------------------------------------------------
PROCEDURE ReStoreVOQty (
        p_object_id VARCHAR2,
        p_transaction_id VARCHAR2,
        p_stream_item_id VARCHAR2,
        p_transaction_date DATE,
        p_user VARCHAR2
)
--</EC-DOC>
IS

CURSOR c_cq_smv(cp_daytime DATE, cp_transaction_key VARCHAR2) IS
SELECT *
  FROM cont_qty_stim_mth_value
 WHERE stream_item_id = p_stream_item_id
   AND daytime = cp_daytime
   AND transaction_key != cp_transaction_key;

ld_daytime DATE;
ln_count_si NUMBER := -1;
lrec_cq_smv cont_qty_stim_mth_value%ROWTYPE;

BEGIN

   ld_daytime := trunc(p_transaction_date,'MM');

   SELECT COUNT(*)
     INTO ln_count_si
     FROM cont_qty_stim_mth_value
    WHERE stream_item_id = p_stream_item_id
      AND daytime = ld_daytime;

   IF ln_count_si = 1 THEN -- this means that the last transaction using this stream_item is being deleted.

       lrec_cq_smv := ec_cont_qty_stim_mth_value.row_by_pk(p_object_id, p_stream_item_id, p_transaction_id, ld_daytime, '<=');

       -- write back original qtys to VO, if not taken by another transaction.
       IF lrec_cq_smv.stream_item_id IS NOT NULL THEN

         UPDATE stim_mth_value
         SET  status             = lrec_cq_smv.status
             ,period_ref_item    = lrec_cq_smv.period_ref_item
             ,calc_method        = lrec_cq_smv.calc_method
             ,net_mass_value     = lrec_cq_smv.net_mass_value
             ,mass_uom_code      = lrec_cq_smv.mass_uom_code
             ,net_volume_value   = lrec_cq_smv.net_volume_value
             ,volume_uom_code    = lrec_cq_smv.volume_uom_code
             ,net_energy_value   = lrec_cq_smv.net_energy_value
             ,energy_uom_code    = lrec_cq_smv.energy_uom_code
             ,net_extra1_value   = lrec_cq_smv.net_extra1_value
             ,extra1_uom_code    = lrec_cq_smv.extra1_uom_code
             ,net_extra2_value   = lrec_cq_smv.net_extra2_value
             ,extra2_uom_code    = lrec_cq_smv.extra2_uom_code
             ,net_extra3_value   = lrec_cq_smv.net_extra3_value
             ,extra3_uom_code    = lrec_cq_smv.extra3_uom_code
             ,gcv                = lrec_cq_smv.gcv
             ,gcv_energy_uom     = lrec_cq_smv.gcv_energy_uom
             ,gcv_volume_uom     = lrec_cq_smv.gcv_volume_uom
             ,density            = lrec_cq_smv.density
             ,density_mass_uom   = lrec_cq_smv.density_mass_uom
             ,density_volume_uom = lrec_cq_smv.density_volume_uom
             ,mcv                = lrec_cq_smv.mcv
             ,mcv_energy_uom     = lrec_cq_smv.mcv_energy_uom
             ,mcv_mass_uom       = lrec_cq_smv.mcv_mass_uom
             ,transaction_key    = NULL
             ,last_updated_by    = 'INSTANTIATE'
         WHERE object_id = p_stream_item_id
         AND daytime = ld_daytime
         AND transaction_key = lrec_cq_smv.transaction_key; -- Only reset if the same transaction has "reserved" the SI

         CleanUp(p_stream_item_id, ld_daytime, p_object_id, p_transaction_id);

       END IF;


   -- No records exist.
   -- Then a document with this si is already booked.
   -- Do nothing.
   ELSIF ln_count_si = 0 THEN

       NULL;

   ELSE -- other transactions using this stream_item is in use, just update stim_mth_value with new contract and transaction

       FOR Cq_smv IN c_cq_smv(ld_daytime, p_transaction_id) LOOP

           lrec_cq_smv := Cq_smv;

           UPDATE stim_mth_value
              SET transaction_key = lrec_cq_smv.transaction_key,
                  last_updated_by = p_user
            WHERE object_id = p_stream_item_id
              AND daytime = ld_daytime
              AND transaction_key = p_transaction_id;

       END LOOP;

       CleanUp(p_stream_item_id, ld_daytime, p_object_id, p_transaction_id);

   END IF;

END ReStoreVOQty;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Procedure      : CleanUp
-- Description    : This procedure should be called directly when a document is booked. (without optional params)
-- Preconditions  :
-- Postconditions : Uncommited changes.
--
-- Using tables   : cont_qty_stim_mth_value
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : It could be called from ReStoreVOQty, if the last transaction using this si is deleted.
--
-----------------------------------------------------------------------------------------------------
PROCEDURE CleanUp (
        p_stream_item_id VARCHAR2,
        p_daytime DATE,
        p_object_id VARCHAR2 DEFAULT NULL,
        p_transaction_id VARCHAR2 DEFAULT NULL
)
--</EC-DOC>
IS

BEGIN

   DELETE FROM cont_qty_stim_mth_value
   WHERE stream_item_id = p_stream_item_id
   AND daytime = p_daytime
   AND object_id = nvl(p_object_id,object_id)
   AND transaction_key = nvl(p_transaction_id,transaction_key)
   ;

END CleanUp;

END EcDp_VOQty;