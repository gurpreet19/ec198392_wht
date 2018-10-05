CREATE OR REPLACE EDITIONABLE TRIGGER "AU_CONT_LINE_ITEM" 
  after update on CONT_LINE_ITEM
  for each row
/****************************************************************
** Trigger        :  AU_CONT_LINE_ITEM
**
** $Revision: 1.5 $
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
**          13.05.2003  JE    Removed section that insert records into CONT_LINE_ITEM_UOM
** 1.4      15.05.2003  JE    Recreated trigger
** 1.5      15.05.2003  JE    Updated uom conversion
-- 1.6      10.07.2003  JE    Fixed calculation of net_energy_be values (new method for this)
*****************************************************************/
declare
  -- local variables here
  lr_this_value cont_line_item%ROWTYPE;
  ld_transaction_date DATE;
  lr_smv              stim_mth_value%rowtype;

  lv2_uom1_group      VARCHAR2(32);
  lv2_uom2_group      VARCHAR2(32);
  lv2_uom3_group      VARCHAR2(32);
  lv2_uom4_group      VARCHAR2(32);

  lv2_volume_uom      cont_line_item.uom1_code%TYPE;
  lv2_mass_uom        cont_line_item.uom1_code%TYPE;
  lv2_energy_uom      cont_line_item.uom1_code%TYPE;
  ln_volume_qty       cont_line_item.qty1%TYPE;
  ln_mass_qty         cont_line_item.qty1%TYPE;
  ln_energy_qty       cont_line_item.qty1%TYPE;

  ln_net_energy_jo    NUMBER;
  ln_net_energy_th    NUMBER;
  ln_net_energy_wh    NUMBER;
  ln_net_mass_ma      NUMBER;
  ln_net_mass_mv      NUMBER;
  ln_net_mass_ua      NUMBER;
  ln_net_mass_uv      NUMBER;
  ln_net_energy_be    NUMBER;
  ln_net_volume_bi    NUMBER;
  ln_net_volume_bm    NUMBER;
  ln_net_volume_sf    NUMBER;
  ln_net_volume_nm    NUMBER;
  ln_net_volume_sm    NUMBER;

BEGIN

  IF Updating('UOM1_CODE') OR Updating('UOM2_CODE') OR Updating('UOM3_CODE') OR Updating('UOM3_CODE')
  OR Updating('QTY1') OR Updating('QTY2') OR Updating('QTY3') OR Updating('QTY4') THEN
    BEGIN
      -- create empty records
      INSERT INTO cont_line_item_uom
         (object_id,
          line_item_key,
          created_by,
          created_date)
      VALUES
         (:new.object_id,
          :new.line_item_key,
          'SYSTEM',
          Ecdp_Timestamp.getCurrentSysdate);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
           NULL;
    END;

    lr_this_value.OBJECT_ID              :=    :new.OBJECT_ID              ;
    lr_this_value.LINE_ITEM_KEY          :=    :new.LINE_ITEM_KEY          ;
    lr_this_value.STREAM_ITEM_ID         :=    :new.STREAM_ITEM_ID         ;
    lr_this_value.DAYTIME                :=    :new.DAYTIME                ;
    lr_this_value.TRANSACTION_KEY        :=    :new.TRANSACTION_KEY        ;
    lr_this_value.QTY1                   :=    :new.QTY1                   ;
    lr_this_value.UOM1_CODE              :=    :new.UOM1_CODE              ;
    lr_this_value.QTY2                   :=    :new.QTY2                   ;
    lr_this_value.UOM2_CODE              :=    :new.UOM2_CODE              ;
    lr_this_value.QTY3                   :=    :new.QTY3                   ;
    lr_this_value.UOM3_CODE              :=    :new.UOM3_CODE              ;
    lr_this_value.QTY4                   :=    :new.QTY4                   ;
    lr_this_value.UOM4_CODE              :=    :new.UOM4_CODE              ;

    lv2_uom1_group   := EcDp_Unit.GetUOMGroup(lr_this_value.uom1_code);
    lv2_uom2_group   := EcDp_Unit.GetUOMGroup(lr_this_value.uom2_code);
    lv2_uom3_group   := EcDp_Unit.GetUOMGroup(lr_this_value.uom3_code);
    lv2_uom4_group   := EcDp_Unit.GetUOMGroup(lr_this_value.uom4_code);

    -- This is needed to get BOE information from stim_mth_value to populate cont_line_item_uom
    ld_transaction_date := trunc(ec_cont_transaction.transaction_date(lr_this_value.transaction_key),'MM');
    lr_smv := ec_stim_mth_value.row_by_pk(lr_this_value.stream_item_id,ld_transaction_date);

    -- energy
    IF 'E' IN (lv2_uom1_group,lv2_uom2_group,lv2_uom3_group,lv2_uom4_group) THEN

       -- if one or more of the four uoms is one of the 13 standard uom. Use it directly
       -- BE
       IF lr_this_value.UOM1_CODE = 'BOE' THEN ln_net_energy_be := lr_this_value.QTY1;

       ELSIF lr_this_value.UOM2_CODE = 'BOE' THEN ln_net_energy_be := lr_this_value.QTY2;
       ELSIF lr_this_value.UOM3_CODE = 'BOE' THEN ln_net_energy_be := lr_this_value.QTY3;
       ELSIF lr_this_value.UOM4_CODE = 'BOE' THEN ln_net_energy_be := lr_this_value.QTY4;
       END IF;

       -- 100MJ
       IF    lr_this_value.UOM1_CODE = '100MJ' THEN ln_net_energy_jo := lr_this_value.QTY1;
       ELSIF lr_this_value.UOM2_CODE = '100MJ' THEN ln_net_energy_jo := lr_this_value.QTY2;
       ELSIF lr_this_value.UOM3_CODE = '100MJ' THEN ln_net_energy_jo := lr_this_value.QTY3;
       ELSIF lr_this_value.UOM4_CODE = '100MJ' THEN ln_net_energy_jo := lr_this_value.QTY4;
       END IF;

       -- 100MJ
       IF    lr_this_value.UOM1_CODE = 'THERMS' THEN ln_net_energy_th := lr_this_value.QTY1;
       ELSIF lr_this_value.UOM2_CODE = 'THERMS' THEN ln_net_energy_th := lr_this_value.QTY2;
       ELSIF lr_this_value.UOM3_CODE = 'THERMS' THEN ln_net_energy_th := lr_this_value.QTY3;
       ELSIF lr_this_value.UOM4_CODE = 'THERMS' THEN ln_net_energy_th := lr_this_value.QTY4;
       END IF;

       -- 100MJ
       IF    lr_this_value.UOM1_CODE = 'KWH' THEN ln_net_energy_wh := lr_this_value.QTY1;
       ELSIF lr_this_value.UOM2_CODE = 'KWH' THEN ln_net_energy_wh := lr_this_value.QTY2;
       ELSIF lr_this_value.UOM3_CODE = 'KWH' THEN ln_net_energy_wh := lr_this_value.QTY3;
       ELSIF lr_this_value.UOM4_CODE = 'KWH' THEN ln_net_energy_wh := lr_this_value.QTY4;
       END IF;

       -- find the first uom_code and qty of the uoms with uom_group = E (result to be used to convert all uoms that doesnt ezists for the energy group)

       IF lv2_uom1_group = 'E' THEN

         lv2_energy_uom := lr_this_value.uom1_code;
         ln_energy_qty := lr_this_value.qty1;

       ELSIF lv2_uom2_group = 'E' THEN

         lv2_energy_uom := lr_this_value.uom2_code;
         ln_energy_qty := lr_this_value.qty2;

       ELSIF lv2_uom3_group = 'E' THEN

         lv2_energy_uom := lr_this_value.uom3_code;
         ln_energy_qty := lr_this_value.qty3;

       ELSIF lv2_uom4_group = 'E' THEN

         lv2_energy_uom := lr_this_value.uom4_code;
         ln_energy_qty := lr_this_value.qty4;

       END IF;

       -- the standard uoms that is not fetched from the UOMx_CODE, must be converted using conversion factors
       IF ln_net_energy_jo IS NULL THEN

          ln_net_energy_jo := ecdp_unit.convertValue(ln_energy_qty, lv2_energy_uom, '100MJ', lr_this_value.daytime);

       END IF;

       IF ln_net_energy_th IS NULL THEN

          ln_net_energy_th := ecdp_unit.convertValue(ln_energy_qty, lv2_energy_uom, 'THERMS', lr_this_value.daytime);

       END IF;

       IF ln_net_energy_wh IS NULL THEN

          ln_net_energy_wh := ecdp_unit.convertValue(ln_energy_qty, lv2_energy_uom, 'KWH', lr_this_value.daytime);

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
       IF    lr_this_value.UOM1_CODE = 'MT' THEN ln_net_mass_ma := lr_this_value.QTY1;
       ELSIF lr_this_value.UOM2_CODE = 'MT' THEN ln_net_mass_ma := lr_this_value.QTY2;
       ELSIF lr_this_value.UOM3_CODE = 'MT' THEN ln_net_mass_ma := lr_this_value.QTY3;
       ELSIF lr_this_value.UOM4_CODE = 'MT' THEN ln_net_mass_ma := lr_this_value.QTY4;
       END IF;

       -- MTV
       IF    lr_this_value.UOM1_CODE = 'MTV' THEN ln_net_mass_mv := lr_this_value.QTY1;
       ELSIF lr_this_value.UOM2_CODE = 'MTV' THEN ln_net_mass_mv := lr_this_value.QTY2;
       ELSIF lr_this_value.UOM3_CODE = 'MTV' THEN ln_net_mass_mv := lr_this_value.QTY3;
       ELSIF lr_this_value.UOM4_CODE = 'MTV' THEN ln_net_mass_mv := lr_this_value.QTY4;
       END IF;

       -- UST
       IF    lr_this_value.UOM1_CODE = 'UST' THEN ln_net_mass_ua := lr_this_value.QTY1;
       ELSIF lr_this_value.UOM2_CODE = 'UST' THEN ln_net_mass_ua := lr_this_value.QTY2;
       ELSIF lr_this_value.UOM3_CODE = 'UST' THEN ln_net_mass_ua := lr_this_value.QTY3;
       ELSIF lr_this_value.UOM4_CODE = 'UST' THEN ln_net_mass_ua := lr_this_value.QTY4;
       END IF;

       -- USTV
       IF    lr_this_value.UOM1_CODE = 'USTV' THEN ln_net_mass_uv := lr_this_value.QTY1;
       ELSIF lr_this_value.UOM2_CODE = 'USTV' THEN ln_net_mass_uv := lr_this_value.QTY2;
       ELSIF lr_this_value.UOM3_CODE = 'USTV' THEN ln_net_mass_uv := lr_this_value.QTY3;
       ELSIF lr_this_value.UOM4_CODE = 'USTV' THEN ln_net_mass_uv := lr_this_value.QTY4;
       END IF;

       IF lv2_uom1_group = 'M' THEN

         lv2_mass_uom := lr_this_value.uom1_code;
         ln_mass_qty := lr_this_value.qty1;

       ELSIF lv2_uom2_group = 'M' THEN

         lv2_mass_uom := lr_this_value.uom2_code;
         ln_mass_qty := lr_this_value.qty2;

       ELSIF lv2_uom3_group = 'M' THEN

         lv2_mass_uom := lr_this_value.uom3_code;
         ln_mass_qty := lr_this_value.qty3;

       ELSIF lv2_uom4_group = 'M' THEN

         lv2_mass_uom := lr_this_value.uom4_code;
         ln_mass_qty := lr_this_value.qty4;

       END IF;

       -- the standard uoms that is not fetched from the UOMx_CODE, must be converted using conversion factors
       IF ln_net_mass_ma IS NULL THEN

          ln_net_mass_ma := ecdp_unit.convertValue(ln_mass_qty, lv2_mass_uom, 'MT', lr_this_value.daytime);

       END IF;

       IF ln_net_mass_mv IS NULL THEN

          ln_net_mass_mv := ecdp_unit.convertValue(ln_mass_qty, lv2_mass_uom, 'MTV', lr_this_value.daytime);

       END IF;

       IF ln_net_mass_ua IS NULL THEN

          ln_net_mass_ua := ecdp_unit.convertValue(ln_mass_qty, lv2_mass_uom, 'UST', lr_this_value.daytime);

       END IF;

       IF ln_net_mass_uv IS NULL THEN

          ln_net_mass_uv := ecdp_unit.convertValue(ln_mass_qty, lv2_mass_uom, 'USTV', lr_this_value.daytime);

       END IF;


    END IF; -- mass


    -- volume
    IF 'V' IN (lv2_uom1_group,lv2_uom2_group,lv2_uom3_group,lv2_uom4_group) THEN

       -- if one or more of the four uoms is one of the 13 standard uom. Use it directly
       -- BI
       IF    lr_this_value.UOM1_CODE = 'BBLS' THEN ln_net_volume_bi := lr_this_value.QTY1;
       ELSIF lr_this_value.UOM2_CODE = 'BBLS' THEN ln_net_volume_bi := lr_this_value.QTY2;
       ELSIF lr_this_value.UOM3_CODE = 'BBLS' THEN ln_net_volume_bi := lr_this_value.QTY3;
       ELSIF lr_this_value.UOM4_CODE = 'BBLS' THEN ln_net_volume_bi := lr_this_value.QTY4;
       END IF;

       -- BM
       IF    lr_this_value.UOM1_CODE = 'BBLS15' THEN ln_net_volume_bm := lr_this_value.QTY1;
       ELSIF lr_this_value.UOM2_CODE = 'BBLS15' THEN ln_net_volume_bm := lr_this_value.QTY2;
       ELSIF lr_this_value.UOM3_CODE = 'BBLS15' THEN ln_net_volume_bm := lr_this_value.QTY3;
       ELSIF lr_this_value.UOM4_CODE = 'BBLS15' THEN ln_net_volume_bm := lr_this_value.QTY4;
       END IF;

       -- SF
       IF    lr_this_value.UOM1_CODE = 'MSCF' THEN ln_net_volume_sf := lr_this_value.QTY1;
       ELSIF lr_this_value.UOM2_CODE = 'MSCF' THEN ln_net_volume_sf := lr_this_value.QTY2;
       ELSIF lr_this_value.UOM3_CODE = 'MSCF' THEN ln_net_volume_sf := lr_this_value.QTY3;
       ELSIF lr_this_value.UOM4_CODE = 'MSCF' THEN ln_net_volume_sf := lr_this_value.QTY4;
       END IF;

       -- NM
       IF    lr_this_value.UOM1_CODE = 'MNM3' THEN ln_net_volume_nm := lr_this_value.QTY1;
       ELSIF lr_this_value.UOM2_CODE = 'MNM3' THEN ln_net_volume_nm := lr_this_value.QTY2;
       ELSIF lr_this_value.UOM3_CODE = 'MNM3' THEN ln_net_volume_nm := lr_this_value.QTY3;
       ELSIF lr_this_value.UOM4_CODE = 'MNM3' THEN ln_net_volume_nm := lr_this_value.QTY4;
       END IF;

       -- SM
       IF    lr_this_value.UOM1_CODE = 'MSM3' THEN ln_net_volume_sm := lr_this_value.QTY1;
       ELSIF lr_this_value.UOM2_CODE = 'MSM3' THEN ln_net_volume_sm := lr_this_value.QTY2;
       ELSIF lr_this_value.UOM3_CODE = 'MSM3' THEN ln_net_volume_sm := lr_this_value.QTY3;
       ELSIF lr_this_value.UOM4_CODE = 'MSM3' THEN ln_net_volume_sm := lr_this_value.QTY4;
       END IF;

       IF lv2_uom1_group = 'V' and lr_this_value.uom1_code <> 'BOE' THEN

          lv2_volume_uom := lr_this_value.uom1_code;
          ln_volume_qty := lr_this_value.qty1;

       ELSIF lv2_uom2_group = 'V' and lr_this_value.uom2_code <> 'BOE' THEN

         lv2_volume_uom := lr_this_value.uom2_code;
         ln_volume_qty := lr_this_value.qty2;

       ELSIF lv2_uom3_group = 'V' and lr_this_value.uom3_code <> 'BOE' THEN

         lv2_volume_uom := lr_this_value.uom3_code;
         ln_volume_qty := lr_this_value.qty3;

       ELSIF lv2_uom4_group = 'V' and lr_this_value.uom4_code <> 'BOE' THEN

          lv2_volume_uom := lr_this_value.uom4_code;
          ln_volume_qty := lr_this_value.qty4;

       END IF;

       -- the standard uoms that is not fetched from the UOMx_CODE, must be converted using conversion factors
       IF ln_net_volume_bi IS NULL THEN

          ln_net_volume_bi := ecdp_unit.convertValue(ln_volume_qty, lv2_volume_uom, 'BBLS', lr_this_value.daytime);

       END IF;

       IF ln_net_volume_bm IS NULL THEN

          ln_net_volume_bm := ecdp_unit.convertValue(ln_volume_qty, lv2_volume_uom, 'BBLS15', lr_this_value.daytime);

       END IF;

       IF ln_net_volume_sf IS NULL THEN

          ln_net_volume_sf := ecdp_unit.convertValue(ln_volume_qty, lv2_volume_uom, 'MSCF', lr_this_value.daytime);

       END IF;

       IF ln_net_volume_nm IS NULL THEN

          ln_net_volume_nm := ecdp_unit.convertValue(ln_volume_qty, lv2_volume_uom, 'MNM3', lr_this_value.daytime);

       END IF;

       IF ln_net_volume_sm IS NULL THEN

          ln_net_volume_sm := ecdp_unit.convertValue(ln_volume_qty, lv2_volume_uom, 'MSM3', lr_this_value.daytime);

       END IF;

    END IF; -- volume


    -- now update table
    UPDATE cont_line_item_uom
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
         ,last_updated_date     = Ecdp_Timestamp.getCurrentSysdate
    WHERE object_id = lr_this_value.object_id
    AND   line_item_key = lr_this_value.line_item_key;

  END IF;

END AU_CONT_LINE_ITEM;
