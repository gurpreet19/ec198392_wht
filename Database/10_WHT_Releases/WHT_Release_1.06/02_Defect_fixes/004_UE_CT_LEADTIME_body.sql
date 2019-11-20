create or replace PACKAGE BODY UE_CT_LEADTIME
IS
  /****************************************************************
  ** Package        :  UE_CT_LEADTIME
  **
  ** $Revision: 1.0 $
  **
  ** Purpose        : Contains logic to calculate ETA(RAT) and ETD
  **                  based on nomination record information
  **
  ** Documentation  :
  **
  ** Created  : 28.11.2012  tlxt
  **
  ** Modification history:
  **
  ** Date          Whom             Change description:
  ** ------        --------         --------------------------------------
  ** 28-nov-2012   tlxt             Initial version
  ** 10-jul-2013   swgn             Modified ETC to include default purge/cool rates
  ** 24-JUL-2013   swgn             Added procedures for cargo timelines
  ** 14-nov-2016   cvmk             112304: Modified calc_Combine_ETD_LT()
  ** 29-DEC-2017   wvic             Item_125159: Added function validateETA and validateETD
  ** 06-FEB-2018   wvic             Item_125159: changed validateETD to use calc_Combine_ETD_LT
  **                                  and fixed problem with calc_ETA_LT
  ** 27-SEP-2019   azril            Item_133165: ADO617851: WHS CP - Calculation of ETD in EC is wrong
  *****************************************************************/

  TYPE lt_t_timestamp IS TABLE OF tv_ct_port_res_usage.daytime%type INDEX BY tv_ec_codes.code%type;
  TYPE lt_t_duration IS TABLE OF tv_ct_port_res_usage.duration%type INDEX BY tv_ec_codes.code%type;

  lt_c_t_cargo_no dv_storage_lift_nomination.cargo_no%type;
  lt_c_d_cargo_no dv_storage_lift_nomination.cargo_no%type;
  lt_c_timestamps lt_t_timestamp;
  lt_c_durations lt_t_duration;

  --<EC-DOC>
  -----------------------------------------------------------------------------------------------------
  -- Function       : calc_ETA_LT
  -- Description    :
  -- Preconditions  :
  -- Postconditions :                                                                                --
  --                                                                                                 --
  -- Using tables   :
  --                                                                                                 --
  -- Using functions:
  --
  --                                                                                                 --
  -- Configuration                                                                                   --
  -- required       :                                                                                --
  --                                                                                                 --
  -- Behaviour      :  calculate Lead time for ETA                                         --
  --                                                                                                 --
  -----------------------------------------------------------------------------------------------------
  FUNCTION calc_ETA_LT(p_storage_id VARCHAR2, p_parcel_no NUMBER, p_forecast_no VARCHAR2 DEFAULT NULL, p_type VARCHAR2 DEFAULT 'FCST')
    RETURN NUMBER
  IS
    ln_LT NUMBER := 0;
    ln_LoadingTime DATE;
    ls_Purge_Cool_Ind VARCHAR2(1);
    ln_LT_PRELOAD NUMBER := 0;
    ln_LT_POSTLOAD NUMBER := 0;
    ln_LT_INB_PILOT NUMBER := 0;
    ln_LT_OUTB_PILOT NUMBER := 0;
    ln_LT_RAMP_UP NUMBER := 0;
    ln_ETA DATE;
    ln_purge_cool_duration NUMBER := 0;


    CURSOR prior_cargos(cp_nom_date DATE)
    IS
      SELECT ETD
      FROM   dv_fcst_Stor_lift_nom
      WHERE  nom_date_time <= cp_nom_date
      AND    forecast_id = p_forecast_no
      AND    p_forecast_no IS NOT NULL
      AND    nom_date_time >= cp_nom_date - 3
      UNION ALL
      SELECT ETD
      FROM   dv_storage_lift_nomination
      WHERE  nom_date_time <= cp_nom_date
      AND    nom_date_time >= cp_nom_date - 3
      AND    p_forecast_no IS NULL;
  BEGIN

    IF p_type = 'FCST' THEN

      ln_LoadingTime := EC_STOR_FCST_LIFT_NOM.START_LIFTING_DATE(p_parcel_no, p_forecast_no);
      ls_Purge_Cool_Ind := NVL(EC_STOR_FCST_LIFT_NOM.text_8(p_parcel_no, p_forecast_no), 'N');

      IF(ls_Purge_Cool_Ind = 'Y') THEN
            ln_purge_cool_duration :=  NVL(EC_STOR_FCST_LIFT_NOM.value_8(p_parcel_no, p_forecast_no),0);
      END IF;

        select (ECDP_CONTRACT_ATTRIBUTE.GETATTRIBUTENUMBER(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT', DECODE(ECDP_OBJECTS.GETOBJCODE(p_storage_id),'STW_LNG','C_WST_LNG','C_WST_COND')),'LT_PRELOAD',EC_STOR_FCST_LIFT_NOM.NOM_FIRM_DATE(p_parcel_no, p_forecast_no),'<=')) into ln_LT_PRELOAD from dual;

        select (ECDP_CONTRACT_ATTRIBUTE.GETATTRIBUTENUMBER(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT', DECODE(ECDP_OBJECTS.GETOBJCODE(p_storage_id),'STW_LNG','C_WST_LNG','C_WST_COND')),'LT_RAMP_UP',EC_STOR_FCST_LIFT_NOM.NOM_FIRM_DATE(p_parcel_no, p_forecast_no),'<=')) into ln_LT_RAMP_UP from dual;

        select (ECDP_CONTRACT_ATTRIBUTE.GETATTRIBUTENUMBER(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT', DECODE(ECDP_OBJECTS.GETOBJCODE(p_storage_id),'STW_LNG','C_WST_LNG','C_WST_COND')),'LT_INB_PILOT',EC_STOR_FCST_LIFT_NOM.NOM_FIRM_DATE(p_parcel_no, p_forecast_no),'<=')) into ln_LT_INB_PILOT from dual;

        select (ECDP_CONTRACT_ATTRIBUTE.GETATTRIBUTENUMBER(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT', DECODE(ECDP_OBJECTS.GETOBJCODE(p_storage_id),'STW_LNG','C_WST_LNG','C_WST_COND')),'LT_OUTB_PILOT',EC_STOR_FCST_LIFT_NOM.NOM_FIRM_DATE(p_parcel_no, p_forecast_no),'<=')) into ln_LT_OUTB_PILOT from dual;

    ln_LT := (NVL(ln_purge_cool_duration,0) + NVL(ln_LT_PRELOAD, 0) + NVL(ln_LT_RAMP_UP, 0) + NVL(ln_LT_INB_PILOT, 0)) / 24;


    ELSE
      ln_LoadingTime := EC_STORAGE_LIFT_NOMINATION.START_LIFTING_DATE(p_parcel_no);

      ls_Purge_Cool_Ind := NVL(EC_STORAGE_LIFT_NOMINATION.text_8(p_parcel_no), 'N');

       IF(ls_Purge_Cool_Ind = 'Y') THEN
            -- Item 125159 Begin
            --ln_purge_cool_duration :=  NVL(EC_STOR_FCST_LIFT_NOM.value_8(p_parcel_no, p_forecast_no),0);
            ln_purge_cool_duration :=  NVL(EC_STORAGE_LIFT_NOMINATION.value_7(p_parcel_no),0);
            -- Item 125159 End
      END IF;


        select (ECDP_CONTRACT_ATTRIBUTE.GETATTRIBUTENUMBER(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT', DECODE(ECDP_OBJECTS.GETOBJCODE(p_storage_id),'STW_LNG','C_WST_LNG','C_WST_COND')),'LT_PRELOAD',EC_STORAGE_LIFT_NOMINATION.NOM_FIRM_DATE(p_parcel_no),'<=')) into ln_LT_PRELOAD from dual;


        select (ECDP_CONTRACT_ATTRIBUTE.GETATTRIBUTENUMBER(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT', DECODE(ECDP_OBJECTS.GETOBJCODE(p_storage_id),'STW_LNG','C_WST_LNG','C_WST_COND')),'LT_RAMP_UP',EC_STORAGE_LIFT_NOMINATION.NOM_FIRM_DATE(p_parcel_no),'<=')) into ln_LT_RAMP_UP from dual;


        select (ECDP_CONTRACT_ATTRIBUTE.GETATTRIBUTENUMBER(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT', DECODE(ECDP_OBJECTS.GETOBJCODE(p_storage_id),'STW_LNG','C_WST_LNG','C_WST_COND')),'LT_INB_PILOT',EC_STORAGE_LIFT_NOMINATION.NOM_FIRM_DATE(p_parcel_no),'<=')) into ln_LT_INB_PILOT from dual;

        select (ECDP_CONTRACT_ATTRIBUTE.GETATTRIBUTENUMBER(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT', DECODE(ECDP_OBJECTS.GETOBJCODE(p_storage_id),'STW_LNG','C_WST_LNG','C_WST_COND')),'LT_OUTB_PILOT',EC_STORAGE_LIFT_NOMINATION.NOM_FIRM_DATE(p_parcel_no),'<=')) into ln_LT_OUTB_PILOT from dual;

        ln_LT := ( nvl(ln_purge_cool_duration,0) + NVL(ln_LT_PRELOAD, 0) + NVL(ln_LT_RAMP_UP, 0) + NVL(ln_LT_INB_PILOT, 0)) / 24;

    END IF;

    ln_ETA := ln_LoadingTime - ln_LT;
    --EQYP 10/Nov/2014 TFS Work Item 91580 (CP -Business Function - Nomination Entry / Schedule Lifting (Scenario))
    --Commenting out the bellow block which originates from the Gorgon Implementation. No such requriment in Wheatstone to adjust ETA
    /*
    -- Determine if this RAT conflicts with the departure of the a prior cargo.
    -- If so, adjust this RAT so that conflict is avoided.

    FOR item IN prior_cargos(ln_loadingTime) LOOP

      IF (ln_ETA < item.ETD
          AND ln_ETA + NVL(ln_LT_INB_PILOT, 0) / 24 > item.ETD - NVL(ln_LT_OUTB_PILOT, 0) / 24) THEN
        ln_ETA := item.ETD - NVL(ln_LT_OUTB_PILOT, 0) / 24 - NVL(ln_LT_INB_PILOT, 0) / 24;
      END IF;

    END LOOP;*/

    -- Rounding the result to the nearest minute; sub-minute values cause validation calculation rules to fail, and we don't need data at that resolution anyway.
    ln_LT := ln_LoadingTime - ln_ETA;
    RETURN ROUND(ln_LT * 24 * 60) / (24 * 60);

  END calc_ETA_LT;

  --<EC-DOC>
  -----------------------------------------------------------------------------------------------------
  -- Function       : calc_ETD_LT
  -- Description    :
  -- Preconditions  :
  -- Postconditions :                                                                                --
  --                                                                                                 --
  -- Using tables   :
  --                                                                                                 --
  -- Using functions:
  --
  --                                                                                                 --
  -- Configuration                                                                                   --
  -- required       :                                                                                --
  --                                                                                                 --
  -- Behaviour      :  calculate Lead time for ETD                                         --
  --                                                                                                 --
  -----------------------------------------------------------------------------------------------------
 /* FUNCTION calc_ETD_LT(p_storage_id VARCHAR2, p_parcel_no NUMBER, p_forecast_no VARCHAR2 DEFAULT NULL, p_type VARCHAR2 DEFAULT 'FCST')
    RETURN NUMBER
  IS
    ln_LT NUMBER := 0;
    ln_LoadingTime DATE;

    ln_LT_POSTLOAD NUMBER := 0;
    ln_LT_RAMP_DOWN NUMBER := 0;
    ln_LT_OUTB_PILOT NUMBER := 0;
  BEGIN

    IF p_type = 'FCST' THEN
      ln_LoadingTime := EC_STOR_FCST_LIFT_NOM.START_LIFTING_DATE(p_parcel_no, p_forecast_no);

      ln_LT_POSTLOAD := (EC_ASSET_CALC_ATTRIBUTE.ATTRIBUTE_VALUE(ECDP_OBJECTS.GETOBJIDFROMCODE('COMMERCIAL_ENTITY', 'CE_WST_IAG_NGBA'),
                                                                 EC_STOR_FCST_LIFT_NOM.NOM_FIRM_DATE(p_parcel_no, p_forecast_no),
                                                                 'COMMERCIAL_ENTITY',
                                                                 'LT_POSTLOAD',
                                                                 '<='));
      ln_LT_RAMP_DOWN := (EC_ASSET_CALC_ATTRIBUTE.ATTRIBUTE_VALUE(ECDP_OBJECTS.GETOBJIDFROMCODE('COMMERCIAL_ENTITY', 'CE_WST_IAG_NGBA'),
                                                                  EC_STOR_FCST_LIFT_NOM.NOM_FIRM_DATE(p_parcel_no, p_forecast_no),
                                                                  'COMMERCIAL_ENTITY',
                                                                  'LT_RAMP_DOWN',
                                                                  '<='));
      ln_LT_OUTB_PILOT := (EC_ASSET_CALC_ATTRIBUTE.ATTRIBUTE_VALUE(ECDP_OBJECTS.GETOBJIDFROMCODE('COMMERCIAL_ENTITY', 'CE_WST_IAG_NGBA'),
                                                                   EC_STOR_FCST_LIFT_NOM.NOM_FIRM_DATE(p_parcel_no, p_forecast_no),
                                                                   'COMMERCIAL_ENTITY',
                                                                   'LT_OUTB_PILOT',
                                                                   '<='));

      ln_LT := (NVL(ln_LT_OUTB_PILOT, 0) + NVL(ln_LT_POSTLOAD, 0) + NVL(ln_LT_RAMP_DOWN, 0)) / 24;
    ELSE
      ln_LoadingTime := EC_STORAGE_LIFT_NOMINATION.START_LIFTING_DATE(p_parcel_no);

      ln_LT_POSTLOAD := (EC_ASSET_CALC_ATTRIBUTE.ATTRIBUTE_VALUE(ECDP_OBJECTS.GETOBJIDFROMCODE('COMMERCIAL_ENTITY', 'CE_WST_IAG_NGBA'),
                                                                 EC_STORAGE_LIFT_NOMINATION.NOM_FIRM_DATE(p_parcel_no),
                                                                 'COMMERCIAL_ENTITY',
                                                                 'LT_POSTLOAD',
                                                                 '<='));
      ln_LT_RAMP_DOWN := (EC_ASSET_CALC_ATTRIBUTE.ATTRIBUTE_VALUE(ECDP_OBJECTS.GETOBJIDFROMCODE('COMMERCIAL_ENTITY', 'CE_WST_IAG_NGBA'),
                                                                  EC_STORAGE_LIFT_NOMINATION.NOM_FIRM_DATE(p_parcel_no),
                                                                  'COMMERCIAL_ENTITY',
                                                                  'LT_RAMP_DOWN',
                                                                  '<='));
      ln_LT_OUTB_PILOT := (EC_ASSET_CALC_ATTRIBUTE.ATTRIBUTE_VALUE(ECDP_OBJECTS.GETOBJIDFROMCODE('COMMERCIAL_ENTITY', 'CE_WST_IAG_NGBA'),
                                                                   EC_STORAGE_LIFT_NOMINATION.NOM_FIRM_DATE(p_parcel_no),
                                                                   'COMMERCIAL_ENTITY',
                                                                   'LT_OUTB_PILOT',
                                                                   '<='));

      ln_LT := (NVL(ln_LT_OUTB_PILOT, 0) + NVL(ln_LT_POSTLOAD, 0) + NVL(ln_LT_RAMP_DOWN, 0)) / 24;
    END IF;

    -- Rounding the result to the nearest minute; sub-minute values cause validation calculation rules to fail, and we don't need data at that resolution anyway.
   RETURN ROUND(ln_LT * 24 * 60) / (24 * 60);

  --return ln_LT;


  END calc_ETD_LT;
*/
  FUNCTION calc_Combine_ETD_LT(p_storage_id VARCHAR2, p_parcel_no NUMBER, p_forecast_no VARCHAR2 DEFAULT NULL, p_cargo_no VARCHAR2 DEFAULT NULL, p_type VARCHAR2 DEFAULT 'FCST')
    RETURN DATE
  IS
    ln_LT NUMBER := 0;
    ln_LoadingTime DATE;
    ln_LoadingDate DATE;
    ln_LoadingRate NUMBER;
    ln_ETD DATE;


    ln_LT_POSTLOAD NUMBER := 0;
    ln_LT_RAMP_DOWN NUMBER := 0;
    ln_LT_RAMP_UP NUMBER := 0;
    ln_LT_RAMP_DOWN_RATE NUMBER := 0;
    ln_LT_RAMP_UP_RATE NUMBER := 0;
    ln_LT_OUTB_PILOT NUMBER := 0;

    ln_TOT_NOM_QTY NUMBER;
	ln_CARGO_NO VARCHAR2(50);

    --Item 112304: Begin
    v_return_value DATE;
    --Item 112304: End


	/*EQYP 5/FEB/2015. Work Item 94809. Includeded p_cargo_no in the where clause of query.*/
      CURSOR PRIMARY_CARGO_FCST
    IS
      /*This code is different from Gorgon */
      SELECT SUM(GRS_VOL_NOMINATED) AS TOT_NOM_QTY
      FROM STOR_FCST_LIFT_NOM
      WHERE FORECAST_ID =  p_forecast_no
      AND CARGO_NO = p_cargo_no
      AND OBJECT_ID = p_storage_id
     -- ADO617851 AND REQUESTED_DATE = (SELECT MAX(REQUESTED_DATE) FROM STOR_FCST_LIFT_NOM WHERE CARGO_NO = p_cargo_no
      AND FORECAST_ID =  p_forecast_no;
    /*End Work Item 94809*/

  BEGIN

    IF p_type = 'FCST' THEN
		ln_LoadingTime := EC_STOR_FCST_LIFT_NOM.START_LIFTING_DATE(p_parcel_no,p_forecast_no);
		ln_LoadingDate := EC_STOR_FCST_LIFT_NOM.NOM_FIRM_DATE(p_parcel_no, p_forecast_no);
		ln_CARGO_NO := NVL(p_cargo_no,EC_STOR_FCST_LIFT_NOM.CARGO_NO(p_parcel_no,p_forecast_no));

        select (ECDP_CONTRACT_ATTRIBUTE.GETATTRIBUTENUMBER(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT', DECODE(ECDP_OBJECTS.GETOBJCODE(p_storage_id),'STW_LNG','C_WST_LNG','C_WST_COND')),'LOADING_RATE',ln_LoadingTime,'<=')) into ln_LoadingRate from dual;

        select (ECDP_CONTRACT_ATTRIBUTE.GETATTRIBUTENUMBER(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT', DECODE(ECDP_OBJECTS.GETOBJCODE(p_storage_id),'STW_LNG','C_WST_LNG','C_WST_COND')),'LT_POSTLOAD',ln_LoadingDate,'<=')) into ln_LT_POSTLOAD from dual;

        select (ECDP_CONTRACT_ATTRIBUTE.GETATTRIBUTENUMBER(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT', DECODE(ECDP_OBJECTS.GETOBJCODE(p_storage_id),'STW_LNG','C_WST_LNG','C_WST_COND')),'LT_RAMP_DOWN',ln_LoadingDate,'<=')) into ln_LT_RAMP_DOWN from dual;

        select (ECDP_CONTRACT_ATTRIBUTE.GETATTRIBUTENUMBER(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT', DECODE(ECDP_OBJECTS.GETOBJCODE(p_storage_id),'STW_LNG','C_WST_LNG','C_WST_COND')),'LT_OUTB_PILOT',ln_LoadingDate,'<=')) into ln_LT_OUTB_PILOT from dual;

        select (ECDP_CONTRACT_ATTRIBUTE.GETATTRIBUTENUMBER(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT', DECODE(ECDP_OBJECTS.GETOBJCODE(p_storage_id),'STW_LNG','C_WST_LNG','C_WST_COND')),'LT_RAMP_UP',ln_LoadingDate,'<=')) into ln_LT_RAMP_UP from dual;

        select (ECDP_CONTRACT_ATTRIBUTE.GETATTRIBUTENUMBER(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT', DECODE(ECDP_OBJECTS.GETOBJCODE(p_storage_id),'STW_LNG','C_WST_LNG','C_WST_COND')),'LT_RAMP_DOWN_RATE',ln_LoadingDate,'<=')) into ln_LT_RAMP_DOWN_RATE from dual;

        select (ECDP_CONTRACT_ATTRIBUTE.GETATTRIBUTENUMBER(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT', DECODE(ECDP_OBJECTS.GETOBJCODE(p_storage_id),'STW_LNG','C_WST_LNG','C_WST_COND')),'LT_RAMP_UP_RATE',ln_LoadingDate,'<=')) into ln_LT_RAMP_UP_RATE from dual;

        ln_LT := (NVL(ln_LT_OUTB_PILOT, 0) + NVL(ln_LT_POSTLOAD, 0) + NVL(ln_LT_RAMP_DOWN, 0)) / 24;

      FOR item IN PRIMARY_CARGO_FCST LOOP
        ln_TOT_NOM_QTY := item.TOT_NOM_QTY;
      END LOOP;


      -- Reduce the loading qty by the qty spent during ramp up and ramp down
      ln_tot_nom_qty := ln_tot_nom_qty - (ln_lt_ramp_up_rate * ln_lt_ramp_up) - (ln_lt_ramp_down_rate * ln_lt_ramp_down);



    -- Rounding the result to the nearest minute; sub-minute values cause validation calculation rules to fail, and we don't need data at that resolution anyway.
    --ln_LT := round(ln_LT * 24 * 60) / (24 * 60);
	--TLXT: 98643: 08-JUN-2015
	--Loading rate can be either from Cargo Info(from official regardless it is Official or Scenario as per designed), Carrier or contract attribute (in sequence)
	--VALUE_6: CARGO_INFO-->LOADING_RATE (M3PERHR)
        ln_ETD := (ln_LoadingTime
               + ((ln_TOT_NOM_QTY / COALESCE(ec_cargo_transport.VALUE_6(ln_CARGO_NO),EC_CARRIER_VERSION.LOADING_RATE(EC_STOR_FCST_LIFT_NOM.CARRIER_ID(p_parcel_no, p_forecast_no), ln_LoadingDate, '<='),ln_LoadingRate)) / 24) + ln_LT);

        --Item 112304: Begin
        /*
		RETURN TRUNC(ln_ETD, 'MI');
        */
        v_return_value := TRUNC(ln_ETD, 'MI');
        
      -- return v_return_value;

       --RETURN TRUNC(v_return_value) + CEIL((v_return_value - TRUNC(v_return_value)) * (24))/24;
       -- ADO617851
       RETURN TRUNC(v_return_value) + (ROUND((v_return_value - TRUNC(v_return_value))*48)/48);

        --Item 112304: End


    ELSE

        --Item 112304: Begin
        /*
        RETURN convert_cargo_timeline(ec_storage_lift_nomination.cargo_no(p_parcel_no), 'ETD');
        */
        v_return_value := convert_cargo_timeline(ec_storage_lift_nomination.cargo_no(p_parcel_no), 'ETD');
        
        
       -- RETURN TRUNC(v_return_value) + (v_return_value - TRUNC(v_return_value) * (24))/24;
        
        
        -- RETURN TRUNC(v_return_value) + CEIL((v_return_value - TRUNC(v_return_value)) * (24))/24;
        -- ADO617851
        RETURN TRUNC(v_return_value) + (ROUND((v_return_value - TRUNC(v_return_value))*48)/48);

        --Item 112304: End

    END IF;
  END calc_Combine_ETD_LT;

  FUNCTION calc_Sched_Carrier_RTT(p_parcel_no NUMBER, p_forecast_no VARCHAR2 DEFAULT NULL)
    RETURN NUMBER
  IS
    v_carrier_id VARCHAR2(32);
    v_parcel_date DATE;
    v_previous_carrier_date DATE;

    CURSOR previous_carrier_dates(cv_carrier_id VARCHAR2, cv_parcel_date DATE)
    IS
      SELECT MAX(nom_firm_date) AS nom_firm_date
      FROM   (SELECT nom.nom_firm_date
              FROM   storage_lift_nomination nom LEFT OUTER JOIN cargo_transport trans ON nom.cargo_no = trans.cargo_no
              WHERE  (p_forecast_no IS NULL
              OR       (p_forecast_no IS NOT NULL
              AND       nom.nom_firm_date < ec_forecast.start_date(p_forecast_no)))
              AND    nom.carrier_id = cv_carrier_id
              AND    nom.nom_firm_date < cv_parcel_date
              AND    NVL(ecbp_cargo_status.geteccargostatus(trans.cargo_status), 'X') <> 'D'
              UNION ALL
              SELECT nom_firm_date fnom
              FROM   stor_fcst_lift_nom fnom LEFT OUTER JOIN cargo_fcst_transport ftrans ON fnom.cargo_no = ftrans.cargo_no
              WHERE  fnom.forecast_id = p_forecast_no
              AND    ftrans.forecast_id = p_forecast_no
              AND    p_forecast_no IS NOT NULL
              AND    fnom.carrier_id = cv_carrier_id
              AND    fnom.nom_firm_Date < cv_parcel_date
              AND    NVL(ecbp_cargo_status.geteccargostatus(ftrans.cargo_status), 'X') <> 'D')
      ORDER BY nom_firm_date;
  BEGIN

    --RETURN NULL;

    IF (p_forecast_no IS NULL) THEN
      v_carrier_id := ec_storage_lift_nomination.carrier_id(p_parcel_no);
      v_parcel_date := ec_storage_lift_nomination.nom_firm_Date(p_parcel_no);
    ELSE
      v_carrier_id := ec_stor_fcst_lift_nom.carrier_id(p_parcel_no, p_forecast_no);
      v_parcel_date := ec_stor_fcst_lift_nom.nom_firm_date(p_parcel_no, p_forecast_no);
    END IF;

    IF v_carrier_id IS NULL THEN
      RETURN NULL;
    END IF;

    FOR item IN previous_carrier_dates(v_carrier_id, v_parcel_date) LOOP
      v_previous_carrier_date := item.nom_firm_date;
    END LOOP;

    RETURN TRUNC(v_parcel_date - v_previous_carrier_date);

  END calc_Sched_Carrier_RTT;
  FUNCTION getFirstNomDateTime(p_cargo_no NUMBER, p_forecast_id VARCHAR2 DEFAULT NULL)
    RETURN DATE
  IS
    CURSOR c_date(p_cargo_no NUMBER)
    IS
      SELECT MIN(nom_date_time) min_nom_date
      FROM   dv_storage_lift_nomination t
      WHERE  t.cargo_no = p_cargo_no;

    CURSOR c_fcst_date(p_cargo_no NUMBER, p_forecast_id VARCHAR2)
    IS
      SELECT MIN(nom_date_time) min_nom_date
      FROM   dv_fcst_stor_lift_nom t
      WHERE  t.cargo_no = p_cargo_no
      AND    t.forecast_id = p_forecast_id;

    ld_min_nom_date DATE;
  BEGIN

    IF p_forecast_id IS NULL THEN
        FOR dateCur IN c_date(p_cargo_no) LOOP
          ld_min_nom_date := dateCur.min_nom_date;
        END LOOP;
    ELSE
        FOR dateCur IN c_fcst_date(p_cargo_no, p_forecast_id) LOOP
          ld_min_nom_date := dateCur.min_nom_date;
        END LOOP;
    END IF;

    RETURN ld_min_nom_date;

  END getFirstNomDateTime;

  FUNCTION getPrimaryLifting(p_cargo_no NUMBER)
    RETURN NUMBER
  IS
    CURSOR liftings
    IS
      SELECT parcel_no
      FROM   dv_storage_lift_nomination
      --WHERE  primary_ind = 'Y'
      WHERE    cargo_no = p_cargo_no;
  BEGIN

    FOR item IN liftings LOOP
      RETURN item.parcel_no;
    END LOOP;

    RETURN NULL;

  END getPrimaryLifting;

  -- Gets the latest entry in the timesheet for a given activity
  FUNCTION getLastTimesheetEntry(p_cargo_no NUMBER, p_timeline_code VARCHAR2, p_product_id VARCHAR2) RETURN DATE
  IS

    CURSOR activity_codes(cp_product_id VARCHAR2) IS
    SELECT activity_code
    FROM tv_prod_lift_activity_code
    WHERE cargo_timeline_code = p_timeline_code
    AND product_id = cp_product_id;

    CURSOR entries(cp_activity_code VARCHAR2) IS
    SELECT NVL(to_daytime, from_daytime) daytime
    FROM lifting_activity
    WHERE cargo_no = p_cargo_no
    AND activity_code = cp_activity_code
    ORDER BY from_daytime ASC;

    v_activity_code VARCHAR2(32);
    v_result DATE;

    v_product_id VARCHAR2(32);
  BEGIN

    IF p_product_id IS NULL THEN
        v_product_id := ec_stor_version.product_id(ec_storage_lift_nomination.object_id(getPrimaryLifting(p_cargo_no)), sysdate, '<=');
    ELSE
        v_product_id := p_product_id;
    END IF;

    FOR item IN activity_codes(v_product_id) LOOP
        v_activity_code := item.activity_code;
    END LOOP;

    IF v_activity_code IS NULL THEN
        v_activity_code := p_timeline_code;
    END IF;

    FOR item IN entries(v_activity_code) LOOP
        v_result := item.daytime;
    END LOOP;

    RETURN v_result;
  END getLastTimesheetEntry;

  -- Gets the difference in time between two timesheet entries corresponding to two timeline codes
  FUNCTION getLastTimesheetDiff(p_cargo_no NUMBER, p_start_code VARCHAR2, p_end_code VARCHAR2, p_product_id VARCHAR2) RETURN NUMBER
  IS
  BEGIN
    RETURN getLastTimesheetEntry(p_cargo_no, p_end_code, p_product_id) - getLastTimesheetEntry(p_cargo_no, p_start_code, p_product_id);
  END getLastTimesheetDiff;

  -- Gets the amount of hours lost to delay since a given cargo timeline code
  FUNCTION getCargoDelaySum(p_cargo_no NUMBER, p_start_code VARCHAR2, p_product_id VARCHAR2) RETURN NUMBER
  IS
    CURSOR delays_between(cp_from_timestamp DATE) IS
    SELECT (to_daytime - from_daytime) * 24 AS delay_hrs
    FROM dv_cargo_lifting_delay
    WHERE cargo_no = p_cargo_no
    AND from_daytime >= cp_from_timestamp;

    v_from_timestamp DATE;
    v_return_value NUMBER := 0;
  BEGIN

    v_from_timestamp := getLastTimesheetEntry(p_cargo_no, p_start_code, p_product_id);

    IF v_from_timestamp IS NULL THEN
        RETURN v_return_value;
    END IF;

    FOR item IN delays_between(v_from_timestamp) LOOP
        v_return_value := v_return_value + item.delay_hrs;
    END LOOP;

    RETURN v_return_value;

  END getCargoDelaySum;

  -- Converts a TIMELINE_CODE into a specific timestamp for a particular cargo:
  FUNCTION convert_cargo_timeline(p_cargo_no NUMBER, p_timeline_code VARCHAR2, p_nom_date_time DATE DEFAULT NULL, p_primary_parcel NUMBER DEFAULT NULL)
    RETURN DATE
  IS
    CURSOR total_parcels
    IS
      SELECT SUM(nom_grs_vol) total_nominated
      FROM   dv_storage_lift_nomination
      WHERE  cargo_no = p_cargo_no;
/*
    CURSOR parcel_cool_purge(cp_parcel_no NUMBER)
    IS
      SELECT purge_ind, purge_qty, cooldown_ind, cooldown_qty
      FROM   dv_storage_lift_nomination
      WHERE  parcel_no = cp_parcel_no;
*/
    v_return_value DATE;
    v_primary_parcel NUMBER;
    v_nom_date_time DATE;
    v_product VARCHAR2(32);
  BEGIN

    IF p_timeline_code IS NULL THEN
        RETURN NULL;
    END IF;

    -- Check the cache
    IF lt_c_t_cargo_no = p_cargo_no THEN
        IF lt_c_timestamps.EXISTS(p_timeline_code) THEN
            RETURN lt_c_timestamps(p_timeline_code);
        END IF;
    ELSE
        lt_c_timestamps.delete();
    END IF;

    v_primary_parcel := NVL(p_primary_parcel, getPrimaryLifting(p_cargo_no));
    v_nom_date_time := NVL(p_nom_date_time, getFirstNomDateTime(p_cargo_no));

    v_product := ec_stor_version.product_id(ec_storage_lift_nomination.object_id(v_primary_parcel), v_nom_date_time, '<=');

    v_return_value := getLastTimesheetEntry(p_cargo_no, p_timeline_code, v_product);

    IF v_return_value IS NOT NULL THEN
        RETURN v_return_value;
    END IF;

    IF p_timeline_code = 'EARLIEST_ETA' THEN
      v_return_value := ec_cargo_transport.date_8(p_cargo_no);

    ELSIF p_timeline_code = 'REQ_ARRIVAL_TIME' THEN
      v_return_value := ue_ct_leadtime.convert_cargo_timeline(p_cargo_no, 'LOAD_START', v_nom_date_time, v_primary_parcel)
                        - convert_cargo_duration(p_cargo_no, 'INBOUND_PILOTAGE', v_nom_date_time, v_primary_parcel) / 24
                        - convert_cargo_duration(p_cargo_no, 'PRE_LOADING', v_nom_date_time, v_primary_parcel) / 24
                        - convert_cargo_duration(p_cargo_no, 'PURGE_COOL', v_nom_date_time, v_primary_parcel) / 24
                        - convert_cargo_duration(p_cargo_no, 'RAMP_UP', v_nom_date_time, v_primary_parcel) / 24;

    ELSIF p_timeline_code = 'ON_BERTH' THEN
      v_return_value := ue_ct_leadtime.convert_cargo_timeline(p_cargo_no, 'REQ_ARRIVAL_TIME', v_nom_date_time, v_primary_parcel)
                        + convert_cargo_duration(p_cargo_no, 'INBOUND_PILOTAGE', v_nom_date_time, v_primary_parcel) / 24;

    ELSIF p_timeline_code = 'PC_START' THEN
      v_return_value := ue_ct_leadtime.convert_cargo_timeline(p_cargo_no, 'ON_BERTH', v_nom_date_time, v_primary_parcel)
                        + convert_cargo_duration(p_cargo_no, 'PRE_LOADING', v_nom_date_time, v_primary_parcel) / 24;

    ELSIF p_timeline_code = 'RAMP_UP' THEN
      v_return_value := ue_ct_leadtime.convert_cargo_timeline(p_cargo_no, 'PC_START', v_nom_date_time, v_primary_parcel)
                         + convert_cargo_duration(p_cargo_no, 'PURGE_COOL', v_nom_date_time, v_primary_parcel) / 24;

    ELSIF p_timeline_code = 'LOAD_START' THEN
      v_return_value := v_nom_date_time;

    ELSIF p_timeline_code = 'LOAD_END' THEN
      v_return_value := ue_ct_leadtime.convert_cargo_timeline(p_cargo_no, 'LOAD_START', v_nom_date_time, v_primary_parcel)
                        + (convert_cargo_duration(p_cargo_no, 'LOADING', v_nom_date_time, v_primary_parcel) / 24)
                        + (convert_cargo_duration(p_cargo_no, 'RAMP_DOWN', v_nom_date_time, v_primary_parcel) / 24);

    ELSIF p_timeline_code = 'OFF_BERTH' THEN
      v_return_value := ue_ct_leadtime.convert_cargo_timeline(p_cargo_no, 'LOAD_END', v_nom_date_time, v_primary_parcel)
                        + convert_cargo_duration(p_cargo_no, 'POST_LOAD', v_nom_date_time, v_primary_parcel) / 24;

    ELSIF p_timeline_code = 'ETD' THEN
      v_return_value := ue_ct_leadtime.convert_cargo_timeline(p_cargo_no, 'OFF_BERTH', v_nom_date_time, v_primary_parcel)
                         + convert_cargo_duration(p_cargo_no, 'OUTBOUND_PILOTAGE', v_nom_date_time, v_primary_parcel) / 24;

    ELSIF p_timeline_code = 'CUSTOM' THEN
      v_return_value := NULL;

    END IF;

    v_return_value := TRUNC(v_return_value, 'MI');

    lt_c_t_cargo_no := p_cargo_no;
    lt_c_timestamps(p_timeline_code) := v_return_value;

    RETURN v_return_value;
  END convert_cargo_timeline;

  /*******************************************************************************************************
'*  Name: convert_cargo_duration
'*  Description:
'*
'*
'*  Revision:
'*  15/Jan/2015 - 92526 Cargo Information (Official) Euan Milne (eqyp)
'*******************************************************************************************************/
  FUNCTION convert_cargo_duration(p_cargo_no NUMBER, p_duration_code VARCHAR2, p_nom_date_time DATE DEFAULT NULL, p_primary_parcel NUMBER DEFAULT NULL)
    RETURN NUMBER
  IS
    v_return_value NUMBER;
    v_primary_parcel NUMBER;

    CURSOR total_parcels
    IS
      SELECT SUM(nom_grs_vol) total_nominated
      FROM   dv_storage_lift_nomination
      WHERE  cargo_no = p_cargo_no;
/*
    CURSOR parcel_cool_purge(cp_parcel_no NUMBER)
    IS
      SELECT purge_ind, purge_qty, cooldown_ind, cooldown_qty
      FROM   dv_storage_lift_nomination
      WHERE  parcel_no = cp_parcel_no;
*/
    v_product_id VARCHAR2(32);
    v_object_id VARCHAR2(32);
    v_contract_code VARCHAR2(32);
    v_reference_date DATE;
  BEGIN

    IF p_duration_code IS NULL THEN
        RETURN NULL;
    END IF;

    -- Check the cache
    IF lt_c_d_cargo_no = p_cargo_no THEN
        IF lt_c_durations.EXISTS(p_duration_code) THEN
            RETURN lt_c_durations(p_duration_code);
        END IF;
    ELSE
        lt_c_durations.delete();
    END IF;

    v_reference_date := NVL(p_nom_date_time, getFirstNomDateTime(p_cargo_no));
    v_primary_parcel := NVL(p_primary_parcel, getPrimaryLifting(p_cargo_no));
    v_product_id := ec_stor_version.product_id(ec_storage_lift_nomination.object_id(v_primary_parcel), nvl(p_nom_date_time, sysdate), '<=');
	v_object_id := ec_storage_lift_nomination.object_id(v_primary_parcel);

	SELECT DECODE(ECDP_OBJECTS.GETOBJCODE(v_object_id),'STW_LNG','C_WST_LNG','C_WST_COND') INTO v_contract_code FROM DUAL;

	--ecdp_dynsql.writetemptext('ue_ct_leadtime', 'product Id: ' || v_product_id);


    IF p_duration_code = 'INBOUND_PILOTAGE' THEN
      v_return_value := getLastTimesheetDiff(p_cargo_no, 'REQ_ARRIVAL_TIME', 'ON_BERTH', v_product_id) * 24;
      IF v_return_value IS NULL THEN
        /*  v_return_value := getCargoDelaySum(p_cargo_no, 'REQ_ARRIVAL_TIME', v_product_id) + NVL(EC_CARGO_TRANSPORT.VALUE_10(p_cargo_no),
                            EC_ASSET_CALC_ATTRIBUTE.ATTRIBUTE_VALUE(ECDP_OBJECTS.GETOBJIDFROMCODE('COMMERCIAL_ENTITY', 'CE_BGPA'),
                                                                    EC_STORAGE_LIFT_NOMINATION.NOM_FIRM_DATE(v_primary_parcel),
                                                                    'COMMERCIAL_ENTITY',
                                                                    'LT_INB_PILOT',
                                                                    '<='));*/

        v_return_value := getCargoDelaySum(p_cargo_no, 'REQ_ARRIVAL_TIME', v_product_id) + NVL(EC_CARGO_TRANSPORT.VALUE_10(p_cargo_no),
                            ECDP_CONTRACT_ATTRIBUTE.getAttributeNumber(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT',v_contract_code), 'LT_INB_PILOT', EC_STORAGE_LIFT_NOMINATION.NOM_FIRM_DATE(v_primary_parcel)));


      END IF;

    ELSIF p_duration_code = 'PRE_LOADING' THEN
      v_return_value := getLastTimesheetDiff(p_cargo_no, 'ON_BERTH', 'PC_START', v_product_id) * 24;
      IF v_return_value IS NULL THEN
        /*  v_return_value := getCargoDelaySum(p_cargo_no, 'ON_BERTH', v_product_id) + NVL(EC_CARGO_TRANSPORT.VALUE_9(p_cargo_no),
                            EC_ASSET_CALC_ATTRIBUTE.ATTRIBUTE_VALUE(ECDP_OBJECTS.GETOBJIDFROMCODE('COMMERCIAL_ENTITY', 'CE_BGPA'),
                                                                    EC_STORAGE_LIFT_NOMINATION.NOM_FIRM_DATE(v_primary_parcel),
                                                                    'COMMERCIAL_ENTITY',
                                                                    'LT_PRELOAD',
                                                                    '<=')); */
            v_return_value := getCargoDelaySum(p_cargo_no, 'ON_BERTH', v_product_id) + NVL(EC_CARGO_TRANSPORT.VALUE_9(p_cargo_no),
                            ECDP_CONTRACT_ATTRIBUTE.getAttributeNumber(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT',v_contract_code), 'LT_PRELOAD', EC_STORAGE_LIFT_NOMINATION.NOM_FIRM_DATE(v_primary_parcel)));
      END IF;
/*
    ELSIF p_duration_code = 'PURGE_COOL' THEN
      v_return_value := getLastTimesheetDiff(p_cargo_no, 'PC_START', 'RAMP_UP', v_product) * 24;
      IF v_return_value IS NULL THEN
          v_return_value := getCargoDelaySum(p_cargo_no, 'PC_START', v_product);

          FOR item IN parcel_cool_purge(v_primary_parcel) LOOP

            IF item.purge_ind = 'Y' THEN
              v_return_value := v_return_value
                                + item.purge_qty
                                  / NVL(ec_carrier_version.value_20(ec_cargo_transport.carrier_id(p_cargo_no), v_reference_date, '<='),
                                        EC_ASSET_CALC_ATTRIBUTE.ATTRIBUTE_VALUE(ec_storage_lift_nomination.object_id(v_primary_parcel), v_reference_date, 'STORAGE', 'DEFAULT_PURGE_RATE', '<='));
            END IF;

            IF item.cooldown_ind = 'Y' THEN
              v_return_value := v_return_value
                                + item.cooldown_qty
                                  / NVL(ec_carrier_version.cooldown_rate(ec_cargo_transport.carrier_id(p_cargo_no), v_reference_date, '<='),
                                        EC_ASSET_CALC_ATTRIBUTE.ATTRIBUTE_VALUE(ec_storage_lift_nomination.object_id(v_primary_parcel), v_reference_date, 'STORAGE', 'DEFAULT_COOL_RATE', '<='));
            END IF;

          END LOOP;
      END IF;
*/
    ELSIF p_duration_code = 'RAMP_UP' THEN
      v_return_value := getLastTimesheetDiff(p_cargo_no, 'RAMP_UP', 'LOAD_START', v_product_id) * 24;
      IF v_return_value IS NULL THEN
         /* v_return_value := getCargoDelaySum(p_cargo_no, 'RAMP_UP', v_product_id) + EC_ASSET_CALC_ATTRIBUTE.ATTRIBUTE_VALUE(ECDP_OBJECTS.GETOBJIDFROMCODE('COMMERCIAL_ENTITY', 'CE_BGPA'),
                                                                    EC_STORAGE_LIFT_NOMINATION.NOM_FIRM_DATE(v_primary_parcel),
                                                                    'COMMERCIAL_ENTITY',
                                                                    'LT_RAMP_UP',
                                                                    '<=');*/
            v_return_value := getCargoDelaySum(p_cargo_no, 'RAMP_UP', v_product_id) +
                           ECDP_CONTRACT_ATTRIBUTE.getAttributeNumber(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT',v_contract_code), 'LT_RAMP_UP', EC_STORAGE_LIFT_NOMINATION.NOM_FIRM_DATE(v_primary_parcel));
      END IF;

    ELSIF p_duration_code = 'LOADING' THEN
      v_return_value := getLastTimesheetDiff(p_cargo_no, 'LOAD_START', 'LOAD_END', v_product_id) * 24;

      IF v_return_value IS NULL THEN
          v_return_value := getCargoDelaySum(p_cargo_no, 'LOAD_START', v_product_id);

          FOR item IN total_parcels LOOP
          /*  v_return_value := v_return_value
                              + item.total_nominated
                                / NVL(ec_carrier_version.loading_rate(ec_cargo_transport.carrier_id(p_cargo_no), v_reference_date, '<='),
                                      EC_ASSET_CALC_ATTRIBUTE.ATTRIBUTE_VALUE(ECDP_OBJECTS.GETOBJIDFROMCODE('COMMERCIAL_ENTITY', 'CE_BGPA'), v_reference_date, 'COMMERCIAL_ENTITY', 'LOADING_RATE', '<='));*/

                v_return_value := v_return_value
                              + item.total_nominated
                                / COALESCE(ec_cargo_transport.VALUE_1(p_cargo_no),ec_carrier_version.loading_rate(ec_cargo_transport.carrier_id(p_cargo_no), v_reference_date, '<='),
                                      ECDP_CONTRACT_ATTRIBUTE.getAttributeNumber(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT',v_contract_code), 'LOADING_RATE', EC_STORAGE_LIFT_NOMINATION.NOM_FIRM_DATE(v_primary_parcel)));

          END LOOP;

       /*   v_return_value := v_return_value
                            - (UE_CT_LeadTime.convert_cargo_duration(p_cargo_no, 'RAMP_UP', v_reference_date, v_primary_parcel) *
                               EC_ASSET_CALC_ATTRIBUTE.ATTRIBUTE_VALUE(ECDP_OBJECTS.GETOBJIDFROMCODE('COMMERCIAL_ENTITY', 'CE_BGPA'), v_reference_date, 'COMMERCIAL_ENTITY', 'LT_RAMP_UP_RATE', '<='))
                               / NVL(ec_carrier_version.loading_rate(ec_cargo_transport.carrier_id(p_cargo_no), v_reference_date, '<='),
                                      EC_ASSET_CALC_ATTRIBUTE.ATTRIBUTE_VALUE(ECDP_OBJECTS.GETOBJIDFROMCODE('COMMERCIAL_ENTITY', 'CE_BGPA'), v_reference_date, 'COMMERCIAL_ENTITY', 'LOADING_RATE', '<=')); */
            v_return_value := v_return_value
                            - (UE_CT_LeadTime.convert_cargo_duration(p_cargo_no, 'RAMP_UP', v_reference_date, v_primary_parcel) *
                            ECDP_CONTRACT_ATTRIBUTE.getAttributeNumber(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT',v_contract_code), 'LT_RAMP_UP_RATE', v_reference_date )
                               )
                               / COALESCE(ec_cargo_transport.VALUE_1(p_cargo_no),ec_carrier_version.loading_rate(ec_cargo_transport.carrier_id(p_cargo_no), v_reference_date, '<='),
                                      ECDP_CONTRACT_ATTRIBUTE.getAttributeNumber(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT',v_contract_code), 'LOADING_RATE', v_reference_date ));

        /*  v_return_value := v_return_value
                            - (UE_CT_LeadTime.convert_cargo_duration(p_cargo_no, 'RAMP_DOWN', v_reference_date, v_primary_parcel) *
                               EC_ASSET_CALC_ATTRIBUTE.ATTRIBUTE_VALUE(ECDP_OBJECTS.GETOBJIDFROMCODE('COMMERCIAL_ENTITY', 'CE_BGPA'), v_reference_date, 'COMMERCIAL_ENTITY', 'LT_RAMP_DOWN_RATE', '<='))
                               / NVL(ec_carrier_version.loading_rate(ec_cargo_transport.carrier_id(p_cargo_no), v_reference_date, '<='),
                                      EC_ASSET_CALC_ATTRIBUTE.ATTRIBUTE_VALUE(ECDP_OBJECTS.GETOBJIDFROMCODE('COMMERCIAL_ENTITY', 'CE_BGPA'), v_reference_date, 'COMMERCIAL_ENTITY', 'LOADING_RATE', '<=')); */
            v_return_value := v_return_value
                            - (UE_CT_LeadTime.convert_cargo_duration(p_cargo_no, 'RAMP_DOWN', v_reference_date, v_primary_parcel) *
                               ECDP_CONTRACT_ATTRIBUTE.getAttributeNumber(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT',v_contract_code), 'LT_RAMP_DOWN_RATE', v_reference_date )
                               / COALESCE(ec_cargo_transport.VALUE_1(p_cargo_no),ec_carrier_version.loading_rate(ec_cargo_transport.carrier_id(p_cargo_no), v_reference_date, '<='),
                                      ECDP_CONTRACT_ATTRIBUTE.getAttributeNumber(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT',v_contract_code), 'LOADING_RATE', v_reference_date )));

      END IF;

    ELSIF p_duration_code = 'RAMP_DOWN' THEN
     /* v_return_value := EC_ASSET_CALC_ATTRIBUTE.ATTRIBUTE_VALUE(ECDP_OBJECTS.GETOBJIDFROMCODE('COMMERCIAL_ENTITY', 'CE_BGPA'),
                                                                EC_STORAGE_LIFT_NOMINATION.NOM_FIRM_DATE(v_primary_parcel),
                                                                'COMMERCIAL_ENTITY',
                                                                'LT_RAMP_DOWN',
                                                                '<=');*/
        v_return_value :=   ECDP_CONTRACT_ATTRIBUTE.getAttributeNumber(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT',v_contract_code), 'LT_RAMP_DOWN', v_reference_date );


    ELSIF p_duration_code = 'POST_LOAD' THEN
      v_return_value := getLastTimesheetDiff(p_cargo_no, 'LOAD_END', 'OFF_BERTH', v_product_id) * 24;
      IF v_return_value IS NULL THEN
         /* v_return_value := getCargoDelaySum(p_cargo_no, 'LOAD_END', v_product_id) + NVL(EC_CARGO_TRANSPORT.VALUE_7(p_cargo_no),
                            EC_ASSET_CALC_ATTRIBUTE.ATTRIBUTE_VALUE(ECDP_OBJECTS.GETOBJIDFROMCODE('COMMERCIAL_ENTITY', 'CE_BGPA'),
                                                                    EC_STORAGE_LIFT_NOMINATION.NOM_FIRM_DATE(v_primary_parcel),
                                                                    'COMMERCIAL_ENTITY',
                                                                    'LT_POSTLOAD',
                                                                    '<='));*/
             v_return_value := getCargoDelaySum(p_cargo_no, 'LOAD_END', v_product_id) + NVL(EC_CARGO_TRANSPORT.VALUE_7(p_cargo_no),
                            ECDP_CONTRACT_ATTRIBUTE.getAttributeNumber(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT',v_contract_code), 'LT_POSTLOAD', v_reference_date ));

      END IF;

    ELSIF p_duration_code = 'OUTBOUND_PILOTAGE' THEN
      v_return_value := getLastTimesheetDiff(p_cargo_no, 'OFF_BERTH', 'ETD', v_product_id) * 24;
      IF v_return_value IS NULL THEN
         /* v_return_value := getCargoDelaySum(p_cargo_no, 'OFF_BERTH', v_product_id) + NVL(EC_CARGO_TRANSPORT.VALUE_8(p_cargo_no),
                            EC_ASSET_CALC_ATTRIBUTE.ATTRIBUTE_VALUE(ECDP_OBJECTS.GETOBJIDFROMCODE('COMMERCIAL_ENTITY', 'CE_BGPA'),
                                                                    EC_STORAGE_LIFT_NOMINATION.NOM_FIRM_DATE(v_primary_parcel),
                                                                    'COMMERCIAL_ENTITY',
                                                                    'LT_OUTB_PILOT',
                                                                    '<=')); */
             v_return_value := getCargoDelaySum(p_cargo_no, 'OFF_BERTH', v_product_id) + NVL(EC_CARGO_TRANSPORT.VALUE_8(p_cargo_no),
                            ECDP_CONTRACT_ATTRIBUTE.getAttributeNumber(ECDP_OBJECTS.GETOBJIDFROMCODE('CONTRACT',v_contract_code), 'LT_OUTB_PILOT', v_reference_date ));

      END IF;

    ELSIF p_duration_code = 'BERTH_TIME' THEN
      v_return_value := (NVL(getLastTimesheetEntry(p_cargo_no, 'OFF_BERTH', v_product_id), convert_cargo_timeline(p_cargo_no, 'OFF_BERTH')) -
                        NVL(getLastTimesheetEntry(p_cargo_no, 'ON_BERTH', v_product_id), convert_cargo_timeline(p_cargo_no, 'ON_BERTH') - (getCargoDelaySum(p_cargo_no, 'ON_BERTH', v_product_id) / 24))) * 24;

    ELSIF p_duration_code = 'ARM_USAGE_TIME' THEN
      v_return_value := (NVL(getLastTimesheetEntry(p_cargo_no, 'LOAD_END', v_product_id), convert_cargo_timeline(p_cargo_no, 'LOAD_END')) -
                        NVL(getLastTimesheetEntry(p_cargo_no, 'PC_START', v_product_id), convert_cargo_timeline(p_cargo_no, 'PC_START') - (getCargoDelaySum(p_cargo_no, 'PC_START', v_product_id) / 24))) * 24;

    ELSE
      v_return_value := NULL;
    END IF;

    v_return_value := ROUND(v_return_value, 4);

    lt_c_d_cargo_no := p_cargo_no;
    lt_c_durations(p_duration_code) := v_return_value;

    RETURN v_return_value;
  END convert_cargo_duration;

  --Item_125159 Begin
  -----------------------------------------------------------------------------------------------------
  -- Function       : validateETA
  -- Description    :
  -- Preconditions  :
  -- Postconditions :                                                                                --
  --                                                                                                 --
  -- Using tables   :
  --                                                                                                 --
  -- Using functions:
  --
  --                                                                                                 --
  -- Configuration                                                                                   --
  -- required       :                                                                                --
  --                                                                                                 --
  -- Behaviour      :  validate ETA                                                                  --
  --                                                                                                 --
  -----------------------------------------------------------------------------------------------------
  FUNCTION validateETA(p_storage_id VARCHAR2, p_parcel_no NUMBER, p_forecast_no VARCHAR2 DEFAULT NULL, p_type VARCHAR2 DEFAULT 'FCST')
     RETURN VARCHAR2
  IS
     CURSOR cCpScenariosValid(cp_object_id VARCHAR2, cp_parcel_no NUMBER, cp_cargo_no VARCHAR2, cpFORECAST_ID VARCHAR2, cpCargoOrParcel VARCHAR2) IS
        SELECT DATE_3 as ETA_OVERRIDE,START_LIFTING_DATE AS NOM_DATE_TIME,NOM_FIRM_DATE AS NOM_DATE
          FROM STOR_FCST_LIFT_NOM
         WHERE OBJECT_ID = cp_object_id
	       AND CARGO_NO = cp_cargo_no
	       AND (cpCargoOrParcel = 'C'
	            OR (cpCargoOrParcel = 'P' AND PARCEL_NO = cp_parcel_no))
           AND FORECAST_ID = cpFORECAST_ID;

     lvRetVal           VARCHAR2 (32) := NULL;
     lnCargoNo          VARCHAR2 (50) := EC_STOR_FCST_LIFT_NOM.CARGO_NO(p_parcel_no,p_forecast_no);
     lvCargoOrParcel    VARCHAR2 (1)  := 'C';

  BEGIN
     FOR C_RV IN cCpScenariosValid(p_storage_id, p_parcel_no, lnCargoNo, p_forecast_no, lvCargoOrParcel)
	 LOOP
	    IF C_RV.ETA_OVERRIDE IS NOT NULL
	    THEN
	       IF C_RV.ETA_OVERRIDE >= C_RV.NOM_DATE_TIME and NVL(lvRetVal, 'WARNING') = 'WARNING' THEN
		      lvRetVal := 'ERROR';
           ELSIF C_RV.ETA_OVERRIDE + calc_ETA_LT(p_storage_id, p_parcel_no, p_forecast_no,'FCST') >= C_RV.NOM_DATE_TIME and lvRetVal is NULL THEN
              lvRetVal := 'WARNING';
           END IF;
        END IF;
	 END LOOP;

	 RETURN lvRetVal;
  END validateETA;

  -----------------------------------------------------------------------------------------------------
  -- Function       : validateETD
  -- Description    :
  -- Preconditions  :
  -- Postconditions :                                                                                --
  --                                                                                                 --
  -- Using tables   :
  --                                                                                                 --
  -- Using functions:
  --
  --                                                                                                 --
  -- Configuration                                                                                   --
  -- required       :                                                                                --
  --                                                                                                 --
  -- Behaviour      :  validate ETD                                                                  --
  --                                                                                                 --
  -----------------------------------------------------------------------------------------------------
  FUNCTION validateETD(p_storage_id VARCHAR2, p_parcel_no NUMBER, p_forecast_no VARCHAR2 DEFAULT NULL, p_type VARCHAR2 DEFAULT 'FCST')
     RETURN VARCHAR2
  IS
     CURSOR cCpScenariosValid(cp_object_id VARCHAR2, cp_parcel_no NUMBER, cp_cargo_no VARCHAR2, cpFORECAST_ID VARCHAR2, cpCargoOrParcel VARCHAR2) IS
        SELECT DATE_4 AS ETD_OVERRIDE,START_LIFTING_DATE AS NOM_DATE_TIME,NOM_FIRM_DATE AS NOM_DATE
          FROM STOR_FCST_LIFT_NOM
         WHERE OBJECT_ID = cp_object_id
	       AND CARGO_NO = cp_cargo_no
	       AND (cpCargoOrParcel = 'C'
	            OR (cpCargoOrParcel = 'P' AND PARCEL_NO = cp_parcel_no))
           AND FORECAST_ID = cpFORECAST_ID;

     lvRetVal           VARCHAR2 (32) := NULL;
     lnCargoNo          VARCHAR2 (50) := EC_STOR_FCST_LIFT_NOM.CARGO_NO(p_parcel_no,p_forecast_no);
     lvCargoOrParcel    VARCHAR2 (1)  := 'C';

  BEGIN
     FOR C_EV IN cCpScenariosValid(p_storage_id, p_parcel_no, lnCargoNo, p_forecast_no, lvCargoOrParcel)
     LOOP
        IF C_EV.ETD_OVERRIDE IS NOT NULL THEN
           IF C_EV.ETD_OVERRIDE <= C_EV.NOM_DATE_TIME and NVL(lvRetVal, 'WARNING') = 'WARNING' THEN
		      lvRetVal := 'ERROR';
           ELSIF calc_Combine_ETD_LT(p_storage_id, p_parcel_no, p_forecast_no, lnCargoNo, 'FCST') >= C_EV.ETD_OVERRIDE and lvRetVal is NULL THEN
		      lvRetVal := 'WARNING';
           END IF;
        END IF;
	 END LOOP;

	 RETURN lvRetVal;
  END validateETD;
  --Item_125159 End

END UE_CT_LEADTIME;
/
