CREATE OR REPLACE EDITIONABLE TRIGGER "AU_STIM_DAY_VALUE" 
  after update on stim_day_value
  for each row
declare
  -- local variables here
  lr_net_sub_uom ECDP_STREAM_ITEM.t_net_sub_uom;
  lr_this_value stim_mth_value%ROWTYPE; -- Uses MTH
BEGIN

--    IF :new.last_updated_by <> 'INSTANTIATE' THEN
      BEGIN

          -- create empty records
          INSERT INTO stim_day_actual
          (object_id,
           daytime,
           created_by,
           created_date
          )
          VALUES(
           :new.object_id,
           :new.daytime,
           'SYSTEM',
           Ecdp_Timestamp.getCurrentSysdate);
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
             NULL;
        END;
           lr_this_value.OBJECT_ID          :=    :new.OBJECT_ID;
           lr_this_value.DAYTIME            :=    :new.DAYTIME  ;
           lr_this_value.STATUS             :=    :new.STATUS    ;
           lr_this_value.PERIOD_REF_ITEM    :=    :new.PERIOD_REF_ITEM      ;
           lr_this_value.CALC_METHOD        :=    :new.CALC_METHOD          ;
           lr_this_value.BOOKING_STATUS     :=    :new.BOOKING_STATUS       ;
           lr_this_value.NET_MASS_VALUE     :=    :new.NET_MASS_VALUE       ;
           lr_this_value.GROSS_MASS_VALUE   :=    :new.GROSS_MASS_VALUE     ;
           lr_this_value.MASS_UOM_CODE      :=    :new.MASS_UOM_CODE        ;
           lr_this_value.NET_VOLUME_VALUE   :=    :new.NET_VOLUME_VALUE     ;
           lr_this_value.GROSS_VOLUME_VALUE :=    :new.GROSS_VOLUME_VALUE   ;
           lr_this_value.VOLUME_UOM_CODE    :=    :new.VOLUME_UOM_CODE      ;
           lr_this_value.NET_ENERGY_VALUE   :=    :new.NET_ENERGY_VALUE     ;
           lr_this_value.GROSS_ENERGY_VALUE :=    :new.GROSS_ENERGY_VALUE   ;
           lr_this_value.ENERGY_UOM_CODE    :=    :new.ENERGY_UOM_CODE      ;
           lr_this_value.NET_EXTRA1_VALUE   :=    :new.NET_EXTRA1_VALUE     ;
           lr_this_value.GROSS_EXTRA1_VALUE :=    :new.GROSS_EXTRA1_VALUE   ;
           lr_this_value.EXTRA1_UOM_CODE    :=    :new.EXTRA1_UOM_CODE      ;
           lr_this_value.NET_EXTRA2_VALUE   :=    :new.NET_EXTRA2_VALUE     ;
           lr_this_value.GROSS_EXTRA2_VALUE :=    :new.GROSS_EXTRA2_VALUE   ;
           lr_this_value.EXTRA2_UOM_CODE    :=    :new.EXTRA2_UOM_CODE      ;
           lr_this_value.NET_EXTRA3_VALUE   :=    :new.NET_EXTRA3_VALUE     ;
           lr_this_value.GROSS_EXTRA3_VALUE :=    :new.GROSS_EXTRA3_VALUE   ;
           lr_this_value.EXTRA3_UOM_CODE    :=    :new.EXTRA3_UOM_CODE      ;
           lr_this_value.GCV                :=    :new.GCV                  ;
           lr_this_value.GCV_ENERGY_UOM     :=    :new.GCV_ENERGY_UOM       ;
           lr_this_value.GCV_VOLUME_UOM     :=    :new.GCV_VOLUME_UOM       ;
           lr_this_value.DENSITY            :=    :new.DENSITY              ;
           lr_this_value.DENSITY_MASS_UOM   :=    :new.DENSITY_MASS_UOM     ;
           lr_this_value.DENSITY_VOLUME_UOM :=    :new.DENSITY_VOLUME_UOM   ;
           lr_this_value.MCV                :=    :new.MCV                  ;
           lr_this_value.MCV_ENERGY_UOM     :=    :new.MCV_ENERGY_UOM       ;
           lr_this_value.MCV_MASS_UOM       :=    :new.MCV_MASS_UOM         ;
           lr_this_value.BOE_TO_UOM_CODE    :=    :new.BOE_TO_UOM_CODE      ;
           lr_this_value.BOE_FROM_UOM_CODE  :=    :new.BOE_FROM_UOM_CODE    ;
           lr_this_value.BOE_FACTOR         :=    :new.BOE_FACTOR           ;
           lr_this_value.SPLIT_SHARE        :=    :new.SPLIT_SHARE          ;
           lr_this_value.RECORD_STATUS      :=    :new.RECORD_STATUS        ;
           lr_this_value.CREATED_BY         :=    :new.CREATED_BY           ;
           lr_this_value.CREATED_DATE       :=    :new.CREATED_DATE         ;
           lr_this_value.LAST_UPDATED_BY    :=    :new.LAST_UPDATED_BY      ;
           lr_this_value.LAST_UPDATED_DATE  :=    :new.LAST_UPDATED_DATE    ;
           lr_this_value.REV_NO             :=    :new.REV_NO               ;
           lr_this_value.REV_TEXT           :=    :new.REV_TEXT             ;
           lr_this_value.COMMENTS           :=    :new.COMMENTS             ;
           lr_this_value.GCV_SOURCE_ID      :=    :new.GCV_SOURCE_ID        ;
           lr_this_value.DENSITY_SOURCE_ID  :=    :new.DENSITY_SOURCE_ID    ;
           lr_this_value.MCV_SOURCE_ID      :=    :new.MCV_SOURCE_ID        ;
         lr_net_sub_uom.net_energy_jo :=
              ECDP_STREAM_ITEM.GetSubGroupValue(lr_this_value, 'E', 'JO');
         lr_net_sub_uom.net_energy_th :=
              ECDP_STREAM_ITEM.GetSubGroupValue(lr_this_value, 'E', 'TH');
         lr_net_sub_uom.net_energy_wh :=
              ECDP_STREAM_ITEM.GetSubGroupValue(lr_this_value, 'E', 'WH');
         lr_net_sub_uom.net_energy_be :=
              ECDP_STREAM_ITEM.GETBOEVALUE(lr_this_value);
         lr_net_sub_uom.net_mass_ma :=
              ECDP_STREAM_ITEM.GetSubGroupValue(lr_this_value, 'M', 'MA');
         lr_net_sub_uom.net_mass_mv :=
              ECDP_STREAM_ITEM.GetSubGroupValue(lr_this_value, 'M', 'MV');
         lr_net_sub_uom.net_mass_ua :=
              ECDP_STREAM_ITEM.GetSubGroupValue(lr_this_value, 'M', 'UA');
         lr_net_sub_uom.net_mass_uv :=
              ECDP_STREAM_ITEM.GetSubGroupValue(lr_this_value, 'M', 'UV');
         lr_net_sub_uom.net_volume_bi :=
              ECDP_STREAM_ITEM.GetSubGroupValue(lr_this_value, 'V', 'BI');
         lr_net_sub_uom.net_volume_bm :=
              ECDP_STREAM_ITEM.GetSubGroupValue(lr_this_value, 'V', 'BM');
         lr_net_sub_uom.net_volume_sf :=
              ECDP_STREAM_ITEM.GetSubGroupValue(lr_this_value, 'V', 'SF');
         lr_net_sub_uom.net_volume_nm :=
              ECDP_STREAM_ITEM.GetSubGroupValue(lr_this_value, 'V', 'NM');
         lr_net_sub_uom.net_volume_sm :=
              ECDP_STREAM_ITEM.GetSubGroupValue(lr_this_value, 'V', 'SM');

         -- now update table
         UPDATE stim_day_actual
           SET NET_ENERGY_JO         = lr_net_sub_uom.NET_ENERGY_JO
              ,NET_ENERGY_TH         = lr_net_sub_uom.NET_ENERGY_TH
              ,NET_ENERGY_WH         = lr_net_sub_uom.NET_ENERGY_WH
              ,NET_ENERGY_BE         = lr_net_sub_uom.NET_ENERGY_BE
              ,NET_MASS_MA           = lr_net_sub_uom.NET_MASS_MA
              ,NET_MASS_MV           = lr_net_sub_uom.NET_MASS_MV
              ,NET_MASS_UA           = lr_net_sub_uom.NET_MASS_UA
              ,NET_MASS_UV           = lr_net_sub_uom.NET_MASS_UV
              ,NET_VOLUME_BI         = lr_net_sub_uom.NET_VOLUME_BI
              ,NET_VOLUME_BM         = lr_net_sub_uom.NET_VOLUME_BM
              ,NET_VOLUME_SF         = lr_net_sub_uom.NET_VOLUME_SF
              ,NET_VOLUME_NM         = lr_net_sub_uom.NET_VOLUME_NM
              ,NET_VOLUME_SM         = lr_net_sub_uom.NET_VOLUME_SM
              ,STATUS                = lr_this_value.STATUS
              ,PERIOD_REF_ITEM       = lr_this_value.PERIOD_REF_ITEM
              ,CALC_METHOD           = lr_this_value.CALC_METHOD
              ,last_updated_by = lr_this_value.last_updated_by
              ,last_updated_date = lr_this_value.last_updated_date
         WHERE object_id = lr_this_value.object_id
           AND daytime = lr_this_value.daytime;

--  END IF;

END AU_STIM_DAY_VALUE;
