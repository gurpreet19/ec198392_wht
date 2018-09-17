CREATE OR REPLACE EDITIONABLE TRIGGER "AU_CONT_TRANSACTION_QTY" 
  after update on cont_transaction_qty
  for each row
/****************************************************************
** Trigger        :  AU_CONT_TRANSACTION_QTY
**
** $Revision: 1.17 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created  : 27.03.2003  Jan Efjestad
**
** Modification history:
**
** Version  Date        Whom  Change description:
** -------  ------      ----- --------------------------------------
**          01.04.2003  JE    Removed update of uom_codes in cont_line_item
**          25.04.2003  JE    Added section that update or insert records
**                            into table CONT_TRANSACTION_QTY_UOM
**          13.05.2003  JE    Removed section that insert records into CONT_TRANSACTION_QTY_UOM
** 1.5      15.05.2003  JE    Recreated section that insert records into CONT_TRANSACTION_QTY_UOM
** 1.6      15.05.2003  JE    Updated uom conversion
-- 1.7      10.07.2003  JE    Fixed calculation of net_energy_be values (new method for this)
*****************************************************************/
declare
  -- local variables here
  lr_this_value cont_transaction_qty%ROWTYPE;
  lr_smv              stim_mth_value%rowtype;
  lv2_stream_item_id stream_item.object_id%TYPE;

  ld_daytime          cont_transaction.daytime%TYPE;
  lv2_uom1_code       cont_transaction_qty.uom1_code%TYPE;
  lv2_uom2_code       cont_transaction_qty.uom1_code%TYPE;
  lv2_uom3_code       cont_transaction_qty.uom1_code%TYPE;
  lv2_uom4_code       cont_transaction_qty.uom1_code%TYPE;

  lv2_uom1_group      VARCHAR2(32);
  lv2_uom2_group      VARCHAR2(32);
  lv2_uom3_group      VARCHAR2(32);
  lv2_uom4_group      VARCHAR2(32);

  lv2_volume_uom      cont_transaction_qty.uom1_code%TYPE;
  lv2_mass_uom        cont_transaction_qty.uom1_code%TYPE;
  lv2_energy_uom      cont_transaction_qty.uom1_code%TYPE;
  ln_volume_qty       cont_transaction_qty.net_qty1%TYPE;
  ln_mass_qty         cont_transaction_qty.net_qty1%TYPE;
  ln_energy_qty       cont_transaction_qty.net_qty1%TYPE;

  ln_net_energy_jo            NUMBER;
  ln_net_energy_th            NUMBER;
  ln_net_energy_wh            NUMBER;
  ln_net_mass_ma              NUMBER;
  ln_net_mass_mv              NUMBER;
  ln_net_mass_ua              NUMBER;
  ln_net_mass_uv              NUMBER;
  ln_net_energy_be            NUMBER;
  ln_net_volume_bi            NUMBER;
  ln_net_volume_bm            NUMBER;
  ln_net_volume_sf            NUMBER;
  ln_net_volume_nm            NUMBER;
  ln_net_volume_sm            NUMBER;
  ln_dist_fetched             NUMBER := 0;



  CURSOR c_net_grs (c_object_id cont_transaction_qty.object_id%TYPE, c_transaction_id cont_transaction_qty.transaction_key%TYPE) is
    SELECT li.object_id, li.line_item_key, NVL(li.stim_value_category_code,'NET_CURRENT') stim_value_category_code
      FROM cont_line_item li
     WHERE li.object_id = c_object_id
       AND li.transaction_key = c_transaction_id
       AND li.line_item_based_type = 'QTY';

    lv2_dist_split_type VARCHAR2(200);
    ld_transaction_date DATE;


-- This cursor should be used to see if numbers pr. dist have actually been fetched from the interface on the current contract/transaction
CURSOR c_dist_period_fetched IS
SELECT 1
  FROM ifac_sales_qty i
 WHERE i.contract_id = :new.object_id
   AND i.transaction_key = :new.transaction_key
   AND i.alloc_no_max_ind = 'Y';

-- This cursor should be used to see if numbers pr. dist are actually fetched from the interface on the current contract/transaction
CURSOR c_dist_cargo_fetched IS
SELECT 1
  FROM ifac_cargo_value i
 WHERE i.contract_id = :new.object_id
   AND i.transaction_key = :new.transaction_key
   AND i.alloc_no_max_ind = 'Y';


BEGIN

  lr_this_value.object_id            := :new.object_id        ;
  lr_this_value.transaction_key      := :new.transaction_key  ;
  lr_this_value.net_qty1             := :new.net_qty1         ;
  lr_this_value.net_qty2             := :new.net_qty2         ;
  lr_this_value.net_qty3             := :new.net_qty3         ;
  lr_this_value.net_qty4             := :new.net_qty4         ;
  lr_this_value.grs_qty1             := :new.grs_qty1         ;
  lr_this_value.grs_qty2             := :new.grs_qty2         ;
  lr_this_value.grs_qty3             := :new.grs_qty3         ;
  lr_this_value.grs_qty4             := :new.grs_qty4         ;
  lr_this_value.pre_net_qty1         := :new.pre_net_qty1     ;
  lr_this_value.pre_net_qty2         := :new.pre_net_qty2     ;
  lr_this_value.pre_net_qty3         := :new.pre_net_qty3     ;
  lr_this_value.pre_net_qty4         := :new.pre_net_qty4     ;
  lr_this_value.pre_grs_qty1         := :new.pre_grs_qty1     ;
  lr_this_value.pre_grs_qty2         := :new.pre_grs_qty2     ;
  lr_this_value.pre_grs_qty3         := :new.pre_grs_qty3     ;
  lr_this_value.pre_grs_qty4         := :new.pre_grs_qty4     ;

  lv2_stream_item_id := ec_cont_transaction.stream_item_id(lr_this_value.transaction_key);

    -- Handling for Source Split Based Qtys
    lv2_dist_split_type := ec_cont_transaction.dist_split_type(lr_this_value.transaction_key);
    ld_transaction_date := ec_cont_transaction.transaction_date(lr_this_value.transaction_key);

    -- Might need to update transaction source split share if conditions are correct..
    IF (lv2_dist_split_type = 'SOURCE_SPLIT' AND ld_transaction_date IS NOT NULL) THEN


       -- Need to verify if quantities have been fetched from interface at dist level..
       IF  (ec_cont_transaction.transaction_scope(lr_this_value.transaction_key) = 'CARGO_BASED') THEN

           ln_dist_fetched := 0;

           FOR c_dist IN c_dist_cargo_fetched LOOP
               ln_dist_fetched := ln_dist_fetched + 1;
           END LOOP;

       -- Same check, but for period based transaction
       ELSIF  (ec_cont_transaction.transaction_scope(lr_this_value.transaction_key) = 'PERIOD_BASED') THEN

           ln_dist_fetched := 0;

           FOR c_dist IN c_dist_period_fetched LOOP
               ln_dist_fetched := ln_dist_fetched + 1;
           END LOOP;

       END IF;

       -- Other records than the 'SUM' has not been fetched. Ok to update transaction source split.
       IF nvl(ln_dist_fetched,0) <= 1 AND ec_cont_transaction.reversal_ind(lr_this_value.transaction_key) <> 'Y' THEN
              Ecdp_Transaction.UpdTransSourceSplitShare(lr_this_value.transaction_key, lr_this_value.net_qty1, :new.uom1_code, ld_transaction_date);
       END IF;

    END IF;

  FOR net_grs_rec IN c_net_grs (lr_this_value.object_id, lr_this_value.transaction_key) LOOP

     IF net_grs_rec.stim_value_category_code = 'NET_CURRENT' THEN

        -- now update table
        UPDATE cont_line_item
        SET     QTY1               = lr_this_value.net_qty1 * NVL(contribution_factor,1)
               ,QTY2               = lr_this_value.net_qty2 * NVL(contribution_factor,1)
               ,QTY3               = lr_this_value.net_qty3 * NVL(contribution_factor,1)
               ,QTY4               = lr_this_value.net_qty4 * NVL(contribution_factor,1)
               ,last_updated_by = NVL(:New.last_updated_by,:New.created_by)
        WHERE  object_id = net_grs_rec.object_id
        AND    line_item_key = net_grs_rec.line_item_key;

     ELSIF net_grs_rec.stim_value_category_code = 'GRS_CURRENT' THEN

         -- now update table
         UPDATE cont_line_item
         SET    QTY1                = lr_this_value.grs_qty1 * NVL(contribution_factor,1)
                ,QTY2               = lr_this_value.grs_qty2 * NVL(contribution_factor,1)
                ,QTY3               = lr_this_value.grs_qty3 * NVL(contribution_factor,1)
                ,QTY4               = lr_this_value.grs_qty4 * NVL(contribution_factor,1)
               ,last_updated_by = NVL(:New.last_updated_by,:New.created_by)
         WHERE  object_id = net_grs_rec.object_id
         AND    line_item_key = net_grs_rec.line_item_key;

     ELSIF net_grs_rec.stim_value_category_code = 'NET_PRECEDING' THEN

         -- now update table
        UPDATE cont_line_item
        SET     QTY1               = lr_this_value.pre_net_qty1 * NVL(contribution_factor,1)
               ,QTY2               = lr_this_value.pre_net_qty2 * NVL(contribution_factor,1)
               ,QTY3               = lr_this_value.pre_net_qty3 * NVL(contribution_factor,1)
               ,QTY4               = lr_this_value.pre_net_qty4 * NVL(contribution_factor,1)
               ,last_updated_by = NVL(:New.last_updated_by,:New.created_by)
        WHERE  object_id = net_grs_rec.object_id
        AND    line_item_key = net_grs_rec.line_item_key;

     ELSIF net_grs_rec.stim_value_category_code = 'GRS_PRECEDING' THEN

         -- now update table
         UPDATE cont_line_item
         SET    QTY1                = lr_this_value.pre_grs_qty1 * NVL(contribution_factor,1)
                ,QTY2               = lr_this_value.pre_grs_qty2 * NVL(contribution_factor,1)
                ,QTY3               = lr_this_value.pre_grs_qty3 * NVL(contribution_factor,1)
                ,QTY4               = lr_this_value.pre_grs_qty4 * NVL(contribution_factor,1)
               ,last_updated_by = NVL(:New.last_updated_by,:New.created_by)
         WHERE  object_id = net_grs_rec.object_id
         AND    line_item_key = net_grs_rec.line_item_key;

     END IF;
  END LOOP;

  -- Update or insert record in table CONT_TRANSACTION_QTY_UOM
  IF Updating('NET_QTY1') OR Updating('NET_QTY2') OR Updating('NET_QTY3') OR Updating('NET_QTY4') THEN
    BEGIN
      -- create empty records
      INSERT INTO cont_transaction_qty_uom
         (object_id,
          transaction_key,
          created_by,
          created_date)
      VALUES
         (:new.object_id,
          :new.transaction_key,
          'SYSTEM',
          Ecdp_Timestamp.getCurrentSysdate);
      EXCEPTION  -- when record already exists then do not create a new record.
         WHEN DUP_VAL_ON_INDEX THEN
           NULL;
    END;

    ld_daytime := ec_cont_transaction.daytime(lr_this_value.transaction_key);




    lv2_uom1_code := :New.uom1_code;
    lv2_uom2_code := :New.uom2_code;
    lv2_uom3_code := :New.uom3_code;
    lv2_uom4_code := :New.uom4_code;

    lv2_uom1_group   := EcDp_Unit.GetUOMGroup(lv2_uom1_code);
    lv2_uom2_group   := EcDp_Unit.GetUOMGroup(lv2_uom2_code);
    lv2_uom3_group   := EcDp_Unit.GetUOMGroup(lv2_uom3_code);
    lv2_uom4_group   := EcDp_Unit.GetUOMGroup(lv2_uom4_code);

    -- This is needed to get BOE information from stim_mth_value to populate cont_transaction_qty_uom
    lr_smv := ec_stim_mth_value.row_by_pk(lv2_stream_item_id,trunc(ld_transaction_date,'MM'));


    -- energy
    IF 'E' IN (lv2_uom1_group,lv2_uom2_group,lv2_uom3_group,lv2_uom4_group) THEN

       -- if one or more of the four uoms is one of the 13 standard uom. Use it directly
       -- BE
       IF    lv2_uom1_code = 'BOE' THEN ln_net_energy_be := lr_this_value.NET_QTY1;
       ELSIF lv2_uom2_code = 'BOE' THEN ln_net_energy_be := lr_this_value.NET_QTY2;
       ELSIF lv2_uom3_code = 'BOE' THEN ln_net_energy_be := lr_this_value.NET_QTY3;
       ELSIF lv2_uom4_code = 'BOE' THEN ln_net_energy_be := lr_this_value.NET_QTY4;
       END IF;

       -- 100MJ
       IF    lv2_uom1_code = '100MJ' THEN ln_net_energy_jo := lr_this_value.NET_QTY1;
       ELSIF lv2_uom2_code = '100MJ' THEN ln_net_energy_jo := lr_this_value.NET_QTY2;
       ELSIF lv2_uom3_code = '100MJ' THEN ln_net_energy_jo := lr_this_value.NET_QTY3;
       ELSIF lv2_uom4_code = '100MJ' THEN ln_net_energy_jo := lr_this_value.NET_QTY4;
       END IF;

       -- 100MJ
       IF    lv2_uom1_code = 'THERMS' THEN ln_net_energy_th := lr_this_value.NET_QTY1;
       ELSIF lv2_uom2_code = 'THERMS' THEN ln_net_energy_th := lr_this_value.NET_QTY2;
       ELSIF lv2_uom3_code = 'THERMS' THEN ln_net_energy_th := lr_this_value.NET_QTY3;
       ELSIF lv2_uom4_code = 'THERMS' THEN ln_net_energy_th := lr_this_value.NET_QTY4;
       END IF;

       -- 100MJ
       IF    lv2_uom1_code = 'KWH' THEN ln_net_energy_wh := lr_this_value.NET_QTY1;
       ELSIF lv2_uom2_code = 'KWH' THEN ln_net_energy_wh := lr_this_value.NET_QTY2;
       ELSIF lv2_uom3_code = 'KWH' THEN ln_net_energy_wh := lr_this_value.NET_QTY3;
       ELSIF lv2_uom4_code = 'KWH' THEN ln_net_energy_wh := lr_this_value.NET_QTY4;
       END IF;

       -- find the first uom_code and qty of the uoms with uom_group = E (result to be used to convert all uoms that doesnt ezists for the energy group)

       IF lv2_uom1_group = 'E' THEN

         lv2_energy_uom := lv2_uom1_code;
         ln_energy_qty := lr_this_value.NET_QTY1;

       ELSIF lv2_uom2_group = 'E' THEN

         lv2_energy_uom := lv2_uom2_code;
         ln_energy_qty := lr_this_value.NET_QTY2;

       ELSIF lv2_uom3_group = 'E' THEN

         lv2_energy_uom := lv2_uom3_code;
         ln_energy_qty := lr_this_value.NET_QTY3;

       ELSIF lv2_uom4_group = 'E' THEN

         lv2_energy_uom := lv2_uom4_code;
         ln_energy_qty := lr_this_value.NET_QTY4;

       END IF;

       -- the standard uoms that is not fetched from the UOMx_CODE, must be converted using conversion factors
       IF ln_net_energy_jo IS NULL THEN

          ln_net_energy_jo := ecdp_unit.convertValue(ln_energy_qty, lv2_energy_uom, '100MJ', ld_daytime);

       END IF;

       IF ln_net_energy_th IS NULL THEN

          ln_net_energy_th := ecdp_unit.convertValue(ln_energy_qty, lv2_energy_uom, 'THERMS', ld_daytime);

       END IF;

       IF ln_net_energy_wh IS NULL THEN

          ln_net_energy_wh := ecdp_unit.convertValue(ln_energy_qty, lv2_energy_uom, 'KWH', ld_daytime);

       END IF;

       IF ln_net_energy_be IS NULL THEN
          -- Calculate net_energy_be based on boe_from_unit and boe_factor
          ln_net_energy_be := ecdp_stream_item.getboeunitvalue(lr_smv.object_id,
                                                                 lr_smv.daytime,
                                                                 ln_energy_qty,
                                                                 lv2_energy_uom,
                                                                 lr_smv.boe_from_uom_code,
                                                                 lr_smv.boe_to_uom_code,
                                                                 lr_smv.boe_factor);


       END IF;

    END IF;

    -- mass
    IF 'M' IN (lv2_uom1_group,lv2_uom2_group,lv2_uom3_group,lv2_uom4_group) THEN

       -- if one or more of the four uoms is one of the 13 standard uom. Use it directly
       -- MT
       IF    lv2_uom1_code = 'MT' THEN ln_net_mass_ma := lr_this_value.NET_QTY1;
       ELSIF lv2_uom2_code = 'MT' THEN ln_net_mass_ma := lr_this_value.NET_QTY2;
       ELSIF lv2_uom3_code = 'MT' THEN ln_net_mass_ma := lr_this_value.NET_QTY3;
       ELSIF lv2_uom4_code = 'MT' THEN ln_net_mass_ma := lr_this_value.NET_QTY4;
       END IF;

       -- MTV
       IF    lv2_uom1_code = 'MTV' THEN ln_net_mass_mv := lr_this_value.NET_QTY1;
       ELSIF lv2_uom2_code = 'MTV' THEN ln_net_mass_mv := lr_this_value.NET_QTY2;
       ELSIF lv2_uom3_code = 'MTV' THEN ln_net_mass_mv := lr_this_value.NET_QTY3;
       ELSIF lv2_uom4_code = 'MTV' THEN ln_net_mass_mv := lr_this_value.NET_QTY4;
       END IF;

       -- UST
       IF    lv2_uom1_code = 'UST' THEN ln_net_mass_ua := lr_this_value.NET_QTY1;
       ELSIF lv2_uom2_code = 'UST' THEN ln_net_mass_ua := lr_this_value.NET_QTY2;
       ELSIF lv2_uom3_code = 'UST' THEN ln_net_mass_ua := lr_this_value.NET_QTY3;
       ELSIF lv2_uom4_code = 'UST' THEN ln_net_mass_ua := lr_this_value.NET_QTY4;
       END IF;

       -- USTV
       IF    lv2_uom1_code = 'USTV' THEN ln_net_mass_uv := lr_this_value.NET_QTY1;
       ELSIF lv2_uom2_code = 'USTV' THEN ln_net_mass_uv := lr_this_value.NET_QTY2;
       ELSIF lv2_uom3_code = 'USTV' THEN ln_net_mass_uv := lr_this_value.NET_QTY3;
       ELSIF lv2_uom4_code = 'USTV' THEN ln_net_mass_uv := lr_this_value.NET_QTY4;
       END IF;

       IF lv2_uom1_group = 'M' THEN

         lv2_mass_uom := lv2_uom1_code;
         ln_mass_qty := lr_this_value.NET_QTY1;

       ELSIF lv2_uom2_group = 'M' THEN

         lv2_mass_uom := lv2_uom2_code;
         ln_mass_qty := lr_this_value.NET_QTY2;

       ELSIF lv2_uom3_group = 'M' THEN

         lv2_mass_uom := lv2_uom3_code;
         ln_mass_qty := lr_this_value.NET_QTY3;

       ELSIF lv2_uom4_group = 'M' THEN

         lv2_mass_uom := lv2_uom4_code;
         ln_mass_qty := lr_this_value.NET_QTY4;

       END IF;

       -- the standard uoms that is not fetched from the UOMx_CODE, must be converted using conversion factors
       IF ln_net_mass_ma IS NULL THEN

          ln_net_mass_ma := ecdp_unit.convertValue(ln_mass_qty, lv2_mass_uom, 'MT', ld_daytime);

       END IF;

       IF ln_net_mass_mv IS NULL THEN

          ln_net_mass_mv := ecdp_unit.convertValue(ln_mass_qty, lv2_mass_uom, 'MTV', ld_daytime);

       END IF;

       IF ln_net_mass_ua IS NULL THEN

          ln_net_mass_ua := ecdp_unit.convertValue(ln_mass_qty, lv2_mass_uom, 'UST', ld_daytime);

       END IF;

       IF ln_net_mass_uv IS NULL THEN

          ln_net_mass_uv := ecdp_unit.convertValue(ln_mass_qty, lv2_mass_uom, 'USTV', ld_daytime);

       END IF;


    END IF; -- mass


    -- volume
    IF 'V' IN (lv2_uom1_group,lv2_uom2_group,lv2_uom3_group,lv2_uom4_group) THEN

       -- if one or more of the four uoms is one of the 13 standard uom. Use it directly
       -- BI
       IF    lv2_uom1_code = 'BBLS' THEN ln_net_volume_bi := lr_this_value.NET_QTY1;
       ELSIF lv2_uom2_code = 'BBLS' THEN ln_net_volume_bi := lr_this_value.NET_QTY2;
       ELSIF lv2_uom3_code = 'BBLS' THEN ln_net_volume_bi := lr_this_value.NET_QTY3;
       ELSIF lv2_uom4_code = 'BBLS' THEN ln_net_volume_bi := lr_this_value.NET_QTY4;
       END IF;

       -- BM
       IF    lv2_uom1_code = 'BBLS15' THEN ln_net_volume_bm := lr_this_value.NET_QTY1;
       ELSIF lv2_uom2_code = 'BBLS15' THEN ln_net_volume_bm := lr_this_value.NET_QTY2;
       ELSIF lv2_uom3_code = 'BBLS15' THEN ln_net_volume_bm := lr_this_value.NET_QTY3;
       ELSIF lv2_uom4_code = 'BBLS15' THEN ln_net_volume_bm := lr_this_value.NET_QTY4;
       END IF;

       -- SF
       IF    lv2_uom1_code = 'MSCF' THEN ln_net_volume_sf := lr_this_value.NET_QTY1;
       ELSIF lv2_uom2_code = 'MSCF' THEN ln_net_volume_sf := lr_this_value.NET_QTY2;
       ELSIF lv2_uom3_code = 'MSCF' THEN ln_net_volume_sf := lr_this_value.NET_QTY3;
       ELSIF lv2_uom4_code = 'MSCF' THEN ln_net_volume_sf := lr_this_value.NET_QTY4;
       END IF;

       -- NM
       IF    lv2_uom1_code = 'MNM3' THEN ln_net_volume_nm := lr_this_value.NET_QTY1;
       ELSIF lv2_uom2_code = 'MNM3' THEN ln_net_volume_nm := lr_this_value.NET_QTY2;
       ELSIF lv2_uom3_code = 'MNM3' THEN ln_net_volume_nm := lr_this_value.NET_QTY3;
       ELSIF lv2_uom4_code = 'MNM3' THEN ln_net_volume_nm := lr_this_value.NET_QTY4;
       END IF;

       -- SM
       IF    lv2_uom1_code = 'MSM3' THEN ln_net_volume_sm := lr_this_value.NET_QTY1;
       ELSIF lv2_uom2_code = 'MSM3' THEN ln_net_volume_sm := lr_this_value.NET_QTY2;
       ELSIF lv2_uom3_code = 'MSM3' THEN ln_net_volume_sm := lr_this_value.NET_QTY3;
       ELSIF lv2_uom4_code = 'MSM3' THEN ln_net_volume_sm := lr_this_value.NET_QTY4;
       END IF;

       IF lv2_uom1_group = 'V' and lv2_uom1_code <> 'BOE' THEN

          lv2_volume_uom := lv2_uom1_code;
          ln_volume_qty := lr_this_value.NET_QTY1;

       ELSIF lv2_uom2_group = 'V' and lv2_uom2_code <> 'BOE' THEN

         lv2_volume_uom := lv2_uom2_code;
         ln_volume_qty := lr_this_value.NET_QTY2;

       ELSIF lv2_uom3_group = 'V' and lv2_uom3_code <> 'BOE' THEN

         lv2_volume_uom := lv2_uom3_code;
         ln_volume_qty := lr_this_value.NET_QTY3;

       ELSIF lv2_uom4_group = 'V' and lv2_uom4_code <> 'BOE' THEN

          lv2_volume_uom := lv2_uom4_code;
          ln_volume_qty := lr_this_value.NET_QTY4;

       END IF;

       -- the standard uoms that is not fetched from the UOMx_CODE, must be converted using conversion factors
       IF ln_net_volume_bi IS NULL THEN

          ln_net_volume_bi := ecdp_unit.convertValue(ln_volume_qty, lv2_volume_uom, 'BBLS', ld_daytime);

       END IF;

       IF ln_net_volume_bm IS NULL THEN

          ln_net_volume_bm := ecdp_unit.convertValue(ln_volume_qty, lv2_volume_uom, 'BBLS15', ld_daytime);

       END IF;

       IF ln_net_volume_sf IS NULL THEN

          ln_net_volume_sf := ecdp_unit.convertValue(ln_volume_qty, lv2_volume_uom, 'MSCF', ld_daytime);

       END IF;

       IF ln_net_volume_nm IS NULL THEN

          ln_net_volume_nm := ecdp_unit.convertValue(ln_volume_qty, lv2_volume_uom, 'MNM3', ld_daytime);

       END IF;

       IF ln_net_volume_sm IS NULL THEN

          ln_net_volume_sm := ecdp_unit.convertValue(ln_volume_qty, lv2_volume_uom, 'MSM3', ld_daytime);

       END IF;

    END IF; -- volume



    -- now update table
    UPDATE cont_transaction_qty_uom
    SET   NET_ENERGY_JO         = ln_net_energy_jo
         ,NET_ENERGY_TH         = ln_net_energy_th
         ,NET_ENERGY_WH         = ln_net_energy_wh
   		   ,NET_ENERGY_BE         = ln_net_energy_be
         ,NET_MASS_MA           = ln_net_mass_ma
         ,NET_MASS_MV           = ln_net_mass_mv
         ,NET_MASS_UA           = ln_net_mass_ua
         ,NET_MASS_UV           = ln_net_mass_uv
         ,NET_VOLUME_BI         = ln_net_volume_bi
         ,NET_VOLUME_BM         = ln_net_volume_bm
         ,NET_VOLUME_SF         = ln_net_volume_sf
         ,NET_VOLUME_NM         = ln_net_volume_nm
         ,NET_VOLUME_SM         = ln_net_volume_sm
         ,last_updated_by       = 'SYSTEM'
         ,last_updated_date     = Ecdp_Timestamp.getCurrentSysdate  -- lr_this_value.last_updated_date
    WHERE object_id = lr_this_value.object_id
    AND   transaction_key = lr_this_value.transaction_key;

  END IF;


END AU_CONT_TRANSACTION_QTY;
