CREATE OR REPLACE EDITIONABLE TRIGGER "AU_STIM_MTH_VALUE" 
  after update on stim_mth_value
  for each row
declare
  -- local variables here
  lr_net_sub_uom ECDP_STREAM_ITEM.t_net_sub_uom;
  lr_net_prior_sub_uom ECDP_STREAM_ITEM.t_net_sub_uom;
  lr_net_sub_booked_uom ECDP_STREAM_ITEM.t_net_sub_uom;
  lr_net_sub_report_uom ECDP_STREAM_ITEM.t_net_sub_uom;
  lr_diff_uom ECDP_STREAM_ITEM.t_net_sub_uom;
  lr_this_value stim_mth_value%ROWTYPE;
  lr_prev_value stim_mth_value%ROWTYPE;
  lr_this_booked stim_mth_booked%ROWTYPE;
  lr_this_reported STIM_MTH_REPORTED%ROWTYPE;
  lr_sum_prior_booked stim_mth_booked%ROWTYPE;
  lr_sum_prior_reported STIM_MTH_REPORTED%ROWTYPE;

  ld_closed_book_date   DATE;
  ld_closed_report_date DATE;
  ld_first_open_book DATE;
  ld_first_open_report DATE;
  lv2_product_id Objects.Object_Id%TYPE;
  lv2_product_code VARCHAR2(32);

CURSOR c_closed_date (cp_object_id VARCHAR2, cp_daytime DATE) IS
SELECT DISTINCT closed_book_date, closed_report_date
      INTO ld_closed_book_date,ld_closed_report_date
      FROM  system_mth_status x
      WHERE daytime = cp_daytime
      AND country_id = ec_company_version.country_id(ec_stream_item_version.company_id(cp_object_id, cp_daytime, '<='), cp_daytime, '<=')
      AND company_id = ec_stream_item_version.company_id(cp_object_id, cp_daytime, '<=')
      AND booking_area_code='QUANTITIES';

CURSOR c_min_book (cp_object_id VARCHAR2, cp_daytime DATE) IS
SELECT min(daytime) as daytime
     FROM  system_mth_status
     WHERE (closed_book_date IS NULL OR closed_book_date > Ecdp_Timestamp.getCurrentSysdate)
     AND daytime > :new.daytime
     AND country_id = ec_company_version.country_id(ec_stream_item_version.company_id(:new.object_id, :new.daytime, '<='), :new.daytime, '<=')
     AND company_id = ec_stream_item_version.company_id(:new.object_id, :new.daytime, '<=')
     AND booking_area_code='QUANTITIES';

CURSOR c_min_report (cp_object_id VARCHAR2, cp_daytime DATE) IS
SELECT min(daytime) as daytime
     FROM  system_mth_status
     WHERE (closed_report_date IS NULL OR closed_report_date > Ecdp_Timestamp.getCurrentSysdate)
     AND daytime > :new.daytime
     AND country_id = ec_company_version.country_id(ec_stream_item_version.company_id(:new.object_id, :new.daytime, '<='), :new.daytime, '<=')
     AND company_id = ec_stream_item_version.company_id(:new.object_id, :new.daytime, '<=')
     AND booking_area_code='QUANTITIES';

CURSOR c_sum_prior_booked (cp_object_id VARCHAR2, cp_daytime DATE, cp_production_period DATE) IS
SELECT
     SUM(NVL(NET_ENERGY_JO,0)) as NET_ENERGY_JO
     ,SUM(NVL(NET_ENERGY_TH,0)) as NET_ENERGY_TH
     ,SUM(NVL(NET_ENERGY_WH,0)) as NET_ENERGY_WH
     ,SUM(NVL(NET_ENERGY_BE,0)) as NET_ENERGY_BE
     ,SUM(NVL(NET_MASS_MA,0)) as NET_MASS_MA
     ,SUM(NVL(NET_MASS_MV,0)) as NET_MASS_MV
     ,SUM(NVL(NET_MASS_UA,0)) as NET_MASS_UA
     ,SUM(NVL(NET_MASS_UV,0)) as NET_MASS_UV
     ,SUM(NVL(NET_VOLUME_BI,0)) as NET_VOLUME_BI
     ,SUM(NVL(NET_VOLUME_BM,0)) as NET_VOLUME_BM
     ,SUM(NVL(NET_VOLUME_SF,0)) as NET_VOLUME_SF
     ,SUM(NVL(NET_VOLUME_NM,0)) as NET_VOLUME_NM
     ,SUM(NVL(NET_VOLUME_SM,0)) as NET_VOLUME_SM
   FROM Stim_Mth_Booked
   WHERE object_id = cp_object_id
   AND daytime <> cp_daytime
   AND production_period = cp_production_period;

CURSOR c_sum_prior_reported (cp_object_id VARCHAR2, cp_daytime DATE, cp_production_period DATE) IS
SELECT
      SUM(NVL(NET_ENERGY_JO,0)) as NET_ENERGY_JO
     ,SUM(NVL(NET_ENERGY_TH,0)) as NET_ENERGY_TH
     ,SUM(NVL(NET_ENERGY_WH,0)) as NET_ENERGY_WH
     ,SUM(NVL(NET_ENERGY_BE,0)) as NET_ENERGY_BE
     ,SUM(NVL(NET_MASS_MA,0)) as NET_MASS_MA
     ,SUM(NVL(NET_MASS_MV,0)) as NET_MASS_MV
     ,SUM(NVL(NET_MASS_UA,0)) as NET_MASS_UA
     ,SUM(NVL(NET_MASS_UV,0)) as NET_MASS_UV
     ,SUM(NVL(NET_VOLUME_BI,0)) as NET_VOLUME_BI
     ,SUM(NVL(NET_VOLUME_BM,0)) as NET_VOLUME_BM
     ,SUM(NVL(NET_VOLUME_SF,0)) as NET_VOLUME_SF
     ,SUM(NVL(NET_VOLUME_NM,0)) as NET_VOLUME_NM
     ,SUM(NVL(NET_VOLUME_SM,0)) as NET_VOLUME_SM
   FROM Stim_Mth_Reported
   WHERE object_id = cp_object_id
   AND daytime <> cp_daytime
   AND production_period = cp_production_period;

begin

--find product for the straem item

lv2_product_id := ECDP_STREAM_ITEM.GETPRODUCTFROMSI(:new.OBJECT_ID,:new.daytime);



     --test if the update-man is INSTANTIATE

--  IF :new.last_updated_by <> 'INSTANTIATE' THEN

    BEGIN
        -- create empty records
        INSERT INTO stim_mth_actual
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
           lr_this_value.BOE_TO_UOM_CODE    :=    :new.BOE_TO_UOM_CODE           ;
           lr_this_value.BOE_FROM_UOM_CODE  :=    :new.BOE_FROM_UOM_CODE         ;
           lr_this_value.BOE_FACTOR         :=    :new.BOE_FACTOR           ;
           lr_this_value.SPLIT_SHARE        :=    :new.SPLIT_SHARE          ;
           lr_this_value.RECORD_STATUS      :=    :new.RECORD_STATUS        ;
           lr_this_value.CREATED_BY         :=    :new.CREATED_BY           ;
           lr_this_value.CREATED_DATE       :=    :new.CREATED_DATE         ;
           lr_this_value.LAST_UPDATED_BY    :=    :new.LAST_UPDATED_BY      ;
           lr_this_value.LAST_UPDATED_DATE  :=    :new.LAST_UPDATED_DATE    ;
           lr_this_value.BOOKING_PERIOD     :=    :new.BOOKING_PERIOD       ;
           lr_this_value.REPORTING_PERIOD   :=    :new.REPORTING_PERIOD     ;
           lr_this_value.REV_NO             :=    :new.REV_NO               ;
           lr_this_value.REV_TEXT           :=    :new.REV_TEXT             ;
           lr_this_value.COMMENTS           :=    :new.COMMENTS             ;

           -- Made up a record of the old values

           lr_prev_value.OBJECT_ID          :=    :new.OBJECT_ID;
           lr_prev_value.DAYTIME            :=    :new.DAYTIME  ;
           lr_prev_value.STATUS             :=    :old.STATUS    ;
           lr_prev_value.PERIOD_REF_ITEM    :=    :old.PERIOD_REF_ITEM      ;
           lr_prev_value.CALC_METHOD        :=    :old.CALC_METHOD          ;
           lr_prev_value.BOOKING_STATUS     :=    :old.BOOKING_STATUS       ;
           lr_prev_value.NET_MASS_VALUE     :=    :old.NET_MASS_VALUE       ;
           lr_prev_value.GROSS_MASS_VALUE   :=    :old.GROSS_MASS_VALUE     ;
           lr_prev_value.MASS_UOM_CODE      :=    :old.MASS_UOM_CODE        ;
           lr_prev_value.NET_VOLUME_VALUE   :=    :old.NET_VOLUME_VALUE     ;
           lr_prev_value.GROSS_VOLUME_VALUE :=    :old.GROSS_VOLUME_VALUE   ;
           lr_prev_value.VOLUME_UOM_CODE    :=    :old.VOLUME_UOM_CODE      ;
           lr_prev_value.NET_ENERGY_VALUE   :=    :old.NET_ENERGY_VALUE     ;
           lr_prev_value.GROSS_ENERGY_VALUE :=    :old.GROSS_ENERGY_VALUE   ;
           lr_prev_value.ENERGY_UOM_CODE    :=    :old.ENERGY_UOM_CODE      ;
           lr_prev_value.NET_EXTRA1_VALUE   :=    :old.NET_EXTRA1_VALUE     ;
           lr_prev_value.GROSS_EXTRA1_VALUE :=    :old.GROSS_EXTRA1_VALUE   ;
           lr_prev_value.EXTRA1_UOM_CODE    :=    :old.EXTRA1_UOM_CODE      ;
           lr_prev_value.NET_EXTRA2_VALUE   :=    :old.NET_EXTRA2_VALUE     ;
           lr_prev_value.GROSS_EXTRA2_VALUE :=    :old.GROSS_EXTRA2_VALUE   ;
           lr_prev_value.EXTRA2_UOM_CODE    :=    :old.EXTRA2_UOM_CODE      ;
           lr_prev_value.NET_EXTRA3_VALUE   :=    :old.NET_EXTRA3_VALUE     ;
           lr_prev_value.GROSS_EXTRA3_VALUE :=    :old.GROSS_EXTRA3_VALUE   ;
           lr_prev_value.EXTRA3_UOM_CODE    :=    :old.EXTRA3_UOM_CODE      ;
           lr_prev_value.GCV                :=    :old.GCV                  ;
           lr_prev_value.GCV_ENERGY_UOM     :=    :old.GCV_ENERGY_UOM       ;
           lr_prev_value.GCV_VOLUME_UOM     :=    :old.GCV_VOLUME_UOM       ;
           lr_prev_value.DENSITY            :=    :old.DENSITY              ;
           lr_prev_value.DENSITY_MASS_UOM   :=    :old.DENSITY_MASS_UOM     ;
           lr_prev_value.DENSITY_VOLUME_UOM :=    :old.DENSITY_VOLUME_UOM   ;
           lr_prev_value.MCV                :=    :old.MCV                  ;
           lr_prev_value.MCV_ENERGY_UOM     :=    :old.MCV_ENERGY_UOM       ;
           lr_prev_value.MCV_MASS_UOM       :=    :old.MCV_MASS_UOM         ;
           lr_prev_value.BOE_TO_UOM_CODE    :=    :old.BOE_TO_UOM_CODE           ;
           lr_prev_value.BOE_FROM_UOM_CODE  :=    :old.BOE_FROM_UOM_CODE         ;
           lr_prev_value.BOE_FACTOR         :=    :old.BOE_FACTOR           ;
           lr_prev_value.SPLIT_SHARE        :=    :old.SPLIT_SHARE          ;
           lr_prev_value.RECORD_STATUS      :=    :old.RECORD_STATUS        ;
           lr_prev_value.CREATED_BY         :=    :old.CREATED_BY           ;
           lr_prev_value.CREATED_DATE       :=    :old.CREATED_DATE         ;
           lr_prev_value.LAST_UPDATED_BY    :=    :old.LAST_UPDATED_BY      ;
           lr_prev_value.LAST_UPDATED_DATE  :=    :old.LAST_UPDATED_DATE    ;
           lr_prev_value.BOOKING_PERIOD     :=    :old.BOOKING_PERIOD       ;
           lr_prev_value.REPORTING_PERIOD   :=    :old.REPORTING_PERIOD     ;
           lr_prev_value.REV_NO             :=    :old.REV_NO               ;
           lr_prev_value.REV_TEXT           :=    :old.REV_TEXT             ;
           lr_prev_value.COMMENTS           :=    :old.COMMENTS             ;

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

        -- get privious values

          lr_net_prior_sub_uom.net_energy_jo :=
              ECDP_STREAM_ITEM.GetSubGroupValue(lr_prev_value, 'E', 'JO');

         lr_net_prior_sub_uom.net_energy_th :=
              ECDP_STREAM_ITEM.GetSubGroupValue(lr_prev_value, 'E', 'TH');

         lr_net_prior_sub_uom.net_energy_wh :=
              ECDP_STREAM_ITEM.GetSubGroupValue(lr_prev_value, 'E', 'WH');

         lr_net_prior_sub_uom.net_energy_be :=
              ECDP_STREAM_ITEM.GETBOEVALUE(lr_prev_value);

         lr_net_prior_sub_uom.net_mass_ma :=
              ECDP_STREAM_ITEM.GetSubGroupValue(lr_prev_value, 'M', 'MA');

         lr_net_prior_sub_uom.net_mass_mv :=
              ECDP_STREAM_ITEM.GetSubGroupValue(lr_prev_value, 'M', 'MV');

         lr_net_prior_sub_uom.net_mass_ua :=
              ECDP_STREAM_ITEM.GetSubGroupValue(lr_prev_value, 'M', 'UA');

         lr_net_prior_sub_uom.net_mass_uv :=
              ECDP_STREAM_ITEM.GetSubGroupValue(lr_prev_value, 'M', 'UV');

         lr_net_prior_sub_uom.net_volume_bi :=
              ECDP_STREAM_ITEM.GetSubGroupValue(lr_prev_value, 'V', 'BI');

         lr_net_prior_sub_uom.net_volume_bm :=
              ECDP_STREAM_ITEM.GetSubGroupValue(lr_prev_value, 'V', 'BM');

         lr_net_prior_sub_uom.net_volume_sf :=
              ECDP_STREAM_ITEM.GetSubGroupValue(lr_prev_value, 'V', 'SF');

         lr_net_prior_sub_uom.net_volume_nm :=
              ECDP_STREAM_ITEM.GetSubGroupValue(lr_prev_value, 'V', 'NM');

         lr_net_prior_sub_uom.net_volume_sm :=
              ECDP_STREAM_ITEM.GetSubGroupValue(lr_prev_value, 'V', 'SM');

         -- now update table
         UPDATE stim_mth_actual
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
              ,BOOKING_PERIOD        = lr_this_value.BOOKING_PERIOD
              ,REPORTING_PERIOD      = lr_this_value.REPORTING_PERIOD
              ,last_updated_by       = lr_this_value.last_updated_by
              ,last_updated_date     = lr_this_value.last_updated_date
         WHERE object_id = lr_this_value.object_id
           AND daytime = lr_this_value.daytime;


    -- handle booked and reported tables

    FOR cur IN c_closed_date(:new.object_id, :new.daytime) LOOP
         ld_closed_book_date := cur.closed_book_date;
         ld_closed_report_date := cur.closed_report_date;
    END LOOP;

   -- perform booked numbers update

        IF ld_closed_book_date IS NULL OR ld_closed_book_date > Ecdp_Timestamp.getCurrentSysdate THEN

           ld_first_open_book := :new.daytime;

        ELSE

          FOR cur IN c_min_book(:new.object_id, :new.daytime) LOOP
               ld_first_open_book := cur.daytime;
          END LOOP;

        END IF;


         BEGIN

            INSERT INTO stim_mth_booked
            (object_id,
             daytime,
             production_period,
             created_by,
             created_date
            )
            VALUES(
             :new.object_id,
             ld_first_open_book,
             :new.daytime,
             'SYSTEM',
             Ecdp_Timestamp.getCurrentSysdate);

          EXCEPTION

              WHEN DUP_VAL_ON_INDEX THEN

                   NULL;
          END;

           lr_this_booked := EC_STIM_MTH_BOOKED.ROW_BY_PK(:new.object_id,ld_first_open_book,:new.daytime);

           -- getting all the sum prior adjustment value in booked table
           FOR cur IN c_sum_prior_booked(:new.object_id, ld_first_open_book, :new.daytime) LOOP
              lr_sum_prior_booked.NET_ENERGY_JO         := cur.NET_ENERGY_JO;
              lr_sum_prior_booked.NET_ENERGY_TH         := cur.NET_ENERGY_TH;
              lr_sum_prior_booked.NET_ENERGY_WH         := cur.NET_ENERGY_WH;
              lr_sum_prior_booked.NET_ENERGY_BE         := cur.NET_ENERGY_BE;
              lr_sum_prior_booked.NET_MASS_MA           := cur.NET_MASS_MA;
              lr_sum_prior_booked.NET_MASS_MV           := cur.NET_MASS_MV;
              lr_sum_prior_booked.NET_MASS_UA           := cur.NET_MASS_UA;
              lr_sum_prior_booked.NET_MASS_UV           := cur.NET_MASS_UV;
	            lr_sum_prior_booked.NET_VOLUME_BI         := cur.NET_VOLUME_BI;
	            lr_sum_prior_booked.NET_VOLUME_BM         := cur.NET_VOLUME_BM;
              lr_sum_prior_booked.NET_VOLUME_SF         := cur.NET_VOLUME_SF;
              lr_sum_prior_booked.NET_VOLUME_NM         := cur.NET_VOLUME_NM;
              lr_sum_prior_booked.NET_VOLUME_SM         := cur.NET_VOLUME_SM;
           END LOOP;

             -- calculate the diff between new and old value
             lr_net_sub_booked_uom.net_energy_jo := ECDP_STREAM_ITEM.GetStimDeltaValue(lr_net_sub_uom.net_energy_jo, lr_net_prior_sub_uom.net_energy_jo, lr_this_booked.net_energy_jo, lr_sum_prior_booked.net_energy_jo);--, lr_this_value.DAYTIME, ld_first_open_book, lv2_reopen_ind);
             lr_net_sub_booked_uom.net_energy_th := ECDP_STREAM_ITEM.GetStimDeltaValue(lr_net_sub_uom.net_energy_th, lr_net_prior_sub_uom.net_energy_th, lr_this_booked.net_energy_th, lr_sum_prior_booked.net_energy_th);-- lr_this_value.DAYTIME, ld_first_open_book, lv2_reopen_ind);
             lr_net_sub_booked_uom.net_energy_wh := ECDP_STREAM_ITEM.GetStimDeltaValue(lr_net_sub_uom.net_energy_wh, lr_net_prior_sub_uom.net_energy_wh, lr_this_booked.net_energy_wh, lr_sum_prior_booked.net_energy_wh);-- lr_this_value.DAYTIME, ld_first_open_book, lv2_reopen_ind);
             lr_net_sub_booked_uom.net_energy_be := ECDP_STREAM_ITEM.GetStimDeltaValue(lr_net_sub_uom.net_energy_be, lr_net_prior_sub_uom.net_energy_be, lr_this_booked.net_energy_be, lr_sum_prior_booked.net_energy_be);-- lr_this_value.DAYTIME, ld_first_open_book, lv2_reopen_ind);
             lr_net_sub_booked_uom.net_mass_ma := ECDP_STREAM_ITEM.GetStimDeltaValue(lr_net_sub_uom.net_mass_ma, lr_net_prior_sub_uom.net_mass_ma, lr_this_booked.net_mass_ma, lr_sum_prior_booked.net_mass_ma);--  lr_this_value.DAYTIME, ld_first_open_book, lv2_reopen_ind);
             lr_net_sub_booked_uom.net_mass_mv := ECDP_STREAM_ITEM.GetStimDeltaValue(lr_net_sub_uom.net_mass_mv, lr_net_prior_sub_uom.net_mass_mv, lr_this_booked.net_mass_mv, lr_sum_prior_booked.net_mass_mv);--  lr_this_value.DAYTIME, ld ld_first_open_book, lv2_reopen_ind);
             lr_net_sub_booked_uom.net_mass_ua := ECDP_STREAM_ITEM.GetStimDeltaValue(lr_net_sub_uom.net_mass_ua, lr_net_prior_sub_uom.net_mass_ua, lr_this_booked.net_mass_ua, lr_sum_prior_booked.net_mass_ua);--  lr_this_value.DAYTIME, ld ld_first_open_book, lv2_reopen_ind);
             lr_net_sub_booked_uom.net_mass_uv := ECDP_STREAM_ITEM.GetStimDeltaValue(lr_net_sub_uom.net_mass_uv, lr_net_prior_sub_uom.net_mass_uv, lr_this_booked.net_mass_uv, lr_sum_prior_booked.net_mass_uv);--  lr_this_value.DAYTIME, ld ld_first_open_book, lv2_reopen_ind);
             lr_net_sub_booked_uom.net_volume_bi := ECDP_STREAM_ITEM.GetStimDeltaValue(lr_net_sub_uom.net_volume_bi, lr_net_prior_sub_uom.net_volume_bi, lr_this_booked.net_volume_bi, lr_sum_prior_booked.net_volume_bi);-- lr_this_value.DAYTIME, ld_first_open_book, lv2_reopen_ind);
             lr_net_sub_booked_uom.net_volume_bm := ECDP_STREAM_ITEM.GetStimDeltaValue(lr_net_sub_uom.net_volume_bm, lr_net_prior_sub_uom.net_volume_bm, lr_this_booked.net_volume_bm, lr_sum_prior_booked.net_volume_bm);-- lr_this_value.DAYTIME, ld_first_open_book, lv2_reopen_ind);
             lr_net_sub_booked_uom.net_volume_sf := ECDP_STREAM_ITEM.GetStimDeltaValue(lr_net_sub_uom.net_volume_sf, lr_net_prior_sub_uom.net_volume_sf, lr_this_booked.net_volume_sf, lr_sum_prior_booked.net_volume_sf);-- lr_this_value.DAYTIME, ld_first_open_book, lv2_reopen_ind);
             lr_net_sub_booked_uom.net_volume_nm := ECDP_STREAM_ITEM.GetStimDeltaValue(lr_net_sub_uom.net_volume_nm, lr_net_prior_sub_uom.net_volume_nm, lr_this_booked.net_volume_nm, lr_sum_prior_booked.net_volume_nm);-- lr_this_value.DAYTIME, ld_first_open_book, lv2_reopen_ind);
             lr_net_sub_booked_uom.net_volume_sm := ECDP_STREAM_ITEM.GetStimDeltaValue(lr_net_sub_uom.net_volume_sm, lr_net_prior_sub_uom.net_volume_sm, lr_this_booked.net_volume_sm, lr_sum_prior_booked.net_volume_sm);-- lr_this_value.DAYTIME, ld_first_open_book, lv2_reopen_ind);

         -- now update table
         UPDATE stim_mth_booked
           SET NET_ENERGY_JO         = lr_net_sub_booked_uom.NET_ENERGY_JO
              ,NET_ENERGY_TH         = lr_net_sub_booked_uom.NET_ENERGY_TH
              ,NET_ENERGY_WH         = lr_net_sub_booked_uom.NET_ENERGY_WH
              ,NET_ENERGY_BE         = lr_net_sub_booked_uom.NET_ENERGY_BE
              ,NET_MASS_MA           = lr_net_sub_booked_uom.NET_MASS_MA
              ,NET_MASS_MV           = lr_net_sub_booked_uom.NET_MASS_MV
              ,NET_MASS_UA           = lr_net_sub_booked_uom.NET_MASS_UA
              ,NET_MASS_UV           = lr_net_sub_booked_uom.NET_MASS_UV
	            ,NET_VOLUME_BI         = lr_net_sub_booked_uom.NET_VOLUME_BI
	            ,NET_VOLUME_BM         = lr_net_sub_booked_uom.NET_VOLUME_BM
              ,NET_VOLUME_SF         = lr_net_sub_booked_uom.NET_VOLUME_SF
              ,NET_VOLUME_NM         = lr_net_sub_booked_uom.NET_VOLUME_NM
              ,NET_VOLUME_SM         = lr_net_sub_booked_uom.NET_VOLUME_SM
              ,STATUS                = lr_this_value.STATUS
              ,PERIOD_REF_ITEM       = lr_this_value.PERIOD_REF_ITEM
              ,CALC_METHOD           = lr_this_value.CALC_METHOD
              ,last_updated_by = lr_this_value.last_updated_by
         WHERE object_id = :new.object_id
           AND daytime = ld_first_open_book
           AND production_period = :new.daytime;



  -- perform reported numbers update

        IF ld_closed_report_date IS NULL THEN

           ld_first_open_report := :new.daytime;

        ELSE

           FOR cur IN c_min_report(:new.object_id, :new.daytime) LOOP
               ld_first_open_report := cur.daytime;
           END LOOP;

        END IF;

         BEGIN

            INSERT INTO stim_mth_reported
            (object_id,
             daytime,
             production_period,
             created_by,
             created_date
            )
            VALUES(
             :new.object_id,
             ld_first_open_report,
             :new.daytime,
             'SYSTEM',
             Ecdp_Timestamp.getCurrentSysdate);

          EXCEPTION

              WHEN DUP_VAL_ON_INDEX THEN

                   NULL;
          END;

           lr_this_reported := EC_STIM_MTH_REPORTED.ROW_BY_PK(:new.object_id,ld_first_open_report,:new.daytime);

           -- getting all the sum prior adjustment value in booked table
           FOR cur IN c_sum_prior_reported(:new.object_id, ld_first_open_report, :new.daytime) LOOP
              lr_sum_prior_reported.NET_ENERGY_JO         := cur.NET_ENERGY_JO;
              lr_sum_prior_reported.NET_ENERGY_TH         := cur.NET_ENERGY_TH;
              lr_sum_prior_reported.NET_ENERGY_WH         := cur.NET_ENERGY_WH;
              lr_sum_prior_reported.NET_ENERGY_BE         := cur.NET_ENERGY_BE;
              lr_sum_prior_reported.NET_MASS_MA           := cur.NET_MASS_MA;
              lr_sum_prior_reported.NET_MASS_MV           := cur.NET_MASS_MV;
              lr_sum_prior_reported.NET_MASS_UA           := cur.NET_MASS_UA;
              lr_sum_prior_reported.NET_MASS_UV           := cur.NET_MASS_UV;
	            lr_sum_prior_reported.NET_VOLUME_BI         := cur.NET_VOLUME_BI;
	            lr_sum_prior_reported.NET_VOLUME_BM         := cur.NET_VOLUME_BM;
              lr_sum_prior_reported.NET_VOLUME_SF         := cur.NET_VOLUME_SF;
              lr_sum_prior_reported.NET_VOLUME_NM         := cur.NET_VOLUME_NM;
              lr_sum_prior_reported.NET_VOLUME_SM         := cur.NET_VOLUME_SM;
           END LOOP;

             -- calculate the diff between new and old value
             lr_net_sub_report_uom.net_energy_jo := ECDP_STREAM_ITEM.GetStimDeltaValue(lr_net_sub_uom.net_energy_jo, lr_net_prior_sub_uom.net_energy_jo, lr_this_reported.net_energy_jo, lr_sum_prior_reported.net_energy_jo);-- lr_this_value.DAYTIME, ld_first_open_book, lv2_reopen_ind);
             lr_net_sub_report_uom.net_energy_th := ECDP_STREAM_ITEM.GetStimDeltaValue(lr_net_sub_uom.net_energy_th, lr_net_prior_sub_uom.net_energy_th, lr_this_reported.net_energy_th, lr_sum_prior_reported.net_energy_th);-- lr_this_value.DAYTIME, ld_first_open_book, lv2_reopen_ind);
             lr_net_sub_report_uom.net_energy_wh := ECDP_STREAM_ITEM.GetStimDeltaValue(lr_net_sub_uom.net_energy_wh, lr_net_prior_sub_uom.net_energy_wh, lr_this_reported.net_energy_wh, lr_sum_prior_reported.net_energy_wh);-- lr_this_value.DAYTIME, ld_first_open_book, lv2_reopen_ind);
             lr_net_sub_report_uom.net_energy_be := ECDP_STREAM_ITEM.GetStimDeltaValue(lr_net_sub_uom.net_energy_be, lr_net_prior_sub_uom.net_energy_be, lr_this_reported.net_energy_be, lr_sum_prior_reported.net_energy_be);-- lr_this_value.DAYTIME, ld_first_open_book, lv2_reopen_ind);
             lr_net_sub_report_uom.net_mass_ma := ECDP_STREAM_ITEM.GetStimDeltaValue(lr_net_sub_uom.net_mass_ma, lr_net_prior_sub_uom.net_mass_ma, lr_this_reported.net_mass_ma, lr_sum_prior_reported.net_mass_ma);-- lr_this_value.DAYTIME, ld_first_open_book, lv2_reopen_ind);
             lr_net_sub_report_uom.net_mass_mv := ECDP_STREAM_ITEM.GetStimDeltaValue(lr_net_sub_uom.net_mass_mv, lr_net_prior_sub_uom.net_mass_mv, lr_this_reported.net_mass_mv, lr_sum_prior_reported.net_mass_mv);-- lr_this_value.DAYTIME, ld_first_open_book, lv2_reopen_ind);
             lr_net_sub_report_uom.net_mass_ua := ECDP_STREAM_ITEM.GetStimDeltaValue(lr_net_sub_uom.net_mass_ua, lr_net_prior_sub_uom.net_mass_ua, lr_this_reported.net_mass_ua, lr_sum_prior_reported.net_mass_ua);-- lr_this_value.DAYTIME, ld_first_open_book, lv2_reopen_ind);
             lr_net_sub_report_uom.net_mass_uv := ECDP_STREAM_ITEM.GetStimDeltaValue(lr_net_sub_uom.net_mass_uv, lr_net_prior_sub_uom.net_mass_uv, lr_this_reported.net_mass_uv, lr_sum_prior_reported.net_mass_uv);-- lr_this_value.DAYTIME, ld_first_open_book, lv2_reopen_ind);
             lr_net_sub_report_uom.net_volume_bi := ECDP_STREAM_ITEM.GetStimDeltaValue(lr_net_sub_uom.net_volume_bi, lr_net_prior_sub_uom.net_volume_bi, lr_this_reported.net_volume_bi, lr_sum_prior_reported.net_volume_bi);-- lr_this_value.DAYTIME, ld_first_open_book, lv2_reopen_ind);
             lr_net_sub_report_uom.net_volume_bm := ECDP_STREAM_ITEM.GetStimDeltaValue(lr_net_sub_uom.net_volume_bm, lr_net_prior_sub_uom.net_volume_bm, lr_this_reported.net_volume_bm, lr_sum_prior_reported.net_volume_bm);-- lr_this_value.DAYTIME, ld_first_open_book, lv2_reopen_ind);
             lr_net_sub_report_uom.net_volume_sf := ECDP_STREAM_ITEM.GetStimDeltaValue(lr_net_sub_uom.net_volume_sf, lr_net_prior_sub_uom.net_volume_sf, lr_this_reported.net_volume_sf, lr_sum_prior_reported.net_volume_sf);-- lr_this_value.DAYTIME, ld_first_open_book, lv2_reopen_ind);
             lr_net_sub_report_uom.net_volume_nm := ECDP_STREAM_ITEM.GetStimDeltaValue(lr_net_sub_uom.net_volume_nm, lr_net_prior_sub_uom.net_volume_nm, lr_this_reported.net_volume_nm, lr_sum_prior_reported.net_volume_nm);-- lr_this_value.DAYTIME, ld_first_open_book, lv2_reopen_ind);
             lr_net_sub_report_uom.net_volume_sm := ECDP_STREAM_ITEM.GetStimDeltaValue(lr_net_sub_uom.net_volume_sm, lr_net_prior_sub_uom.net_volume_sm, lr_this_reported.net_volume_sm, lr_sum_prior_reported.net_volume_sm);-- lr_this_value.DAYTIME, ld_first_open_book, lv2_reopen_ind);

        -- now update table
        UPDATE stim_mth_reported
           SET NET_ENERGY_JO   = lr_net_sub_report_uom.NET_ENERGY_JO,
               NET_ENERGY_TH   = lr_net_sub_report_uom.NET_ENERGY_TH,
               NET_ENERGY_WH   = lr_net_sub_report_uom.NET_ENERGY_WH,
               NET_ENERGY_BE   = lr_net_sub_report_uom.NET_ENERGY_BE,
               NET_MASS_MA     = lr_net_sub_report_uom.NET_MASS_MA,
               NET_MASS_MV     = lr_net_sub_report_uom.NET_MASS_MV,
               NET_MASS_UA     = lr_net_sub_report_uom.NET_MASS_UA,
               NET_MASS_UV     = lr_net_sub_report_uom.NET_MASS_UV,
               NET_VOLUME_BI   = lr_net_sub_report_uom.NET_VOLUME_BI,
               NET_VOLUME_BM   = lr_net_sub_report_uom.NET_VOLUME_BM,
               NET_VOLUME_SF   = lr_net_sub_report_uom.NET_VOLUME_SF,
               NET_VOLUME_NM   = lr_net_sub_report_uom.NET_VOLUME_NM,
               NET_VOLUME_SM   = lr_net_sub_report_uom.NET_VOLUME_SM,
               STATUS          = lr_this_value.STATUS,
               PERIOD_REF_ITEM = lr_this_value.PERIOD_REF_ITEM,
               CALC_METHOD     = lr_this_value.CALC_METHOD,
               last_updated_by = lr_this_value.last_updated_by
         WHERE object_id = :new.object_id
           AND daytime = ld_first_open_report
           AND production_period = :new.daytime;

--   END IF;



end AU_STIM_MTH_VALUE;
