create or replace PACKAGE BODY UE_CT_CARGO_DOCS AS
/****************************************************************
** Package        :  UE_CT_CARGO_DOCS
**
** $Revision: 1.0 $
**
** Purpose        : Contains logic for LNG and Cond Cargo Documentation
**
**
** Documentation  :
**
** Created  : 18.09.2013  ehpu
**
** Modification history:
**
** Date          Whom             Change description:
** ------        --------         --------------------------------------
** 18-Sep-2013   ehpu             Initial version
** 07-Jul-2014   ucta             Added comments to the procs and funcs.
** 30-Jul-2014   ucta             Modified cargo_parcel_func.
** 31-Jul-2014   ucta             Modified cargo_rct_smpl_func.
** 14-Apr-2015   eqyp             WI96803 Refactor for WST implementation.
** 29-Oct-2015   eqyp             WI104403  MA - Cargo Docs - Rename and remap labels for "Captain"
** 30-Oct-2015   fdsm             WI106511  MA - MA - Defect - Cargo Docs - Changes (defect 25)  update to cargo_auth_neg
** 21-Sep-2016   cvmk             111091 - Modified cargo_auth_neg(), cargo_rct_func(), cargo_parcels_func(), cargo_man_func()
** 22-Sep-2016   cvmk             111091 - Modified cargo_bol_func(), cargo_statement_cooling_func()
** 12-Oct-2016   cvmk             111091 - Modified cargo_comp_func()
** 24-Oct-2016   cvmk             111091 - Modified cargo_parcels_func()
** 09-Nov-2016   cvmk             Modified cargo_rct_func(), cargo_rct_smpl_func()
** 23-Dec-2016   evee             Removed subscript from cargo_comp_func
** 22-Mar-2017   cvmk             113805 - Modified cargo_comp_func()
** 22-Nov-2017   wvic             125161 - Modified cargo_man_func(), cargo_timesheet_func(), cargo_bol_func()
** 23-MAY-2018   dfix             127719 - Modified cargo_auth_neg() to return cargo_no instead of cargo_name
** 28-MAY-2018   wvic             127718 - Modified cargo_parcels_func to add BBLS @ 60 DEG F
** 03-JUL-2018   wvic             127719 - Modified cargo_sum_parcels_function to apply 2dp formatting for BBLs
** 01-JUL-2019   gjkz             132627 - Modified cargo_sum_parcels_func to apply 3 decimal point for tonnes and U.S. Barrels @ 60 Deg F.
**                                       - Modified cargo_bol_func, cargo_man_func and cargo_qly_func to add cargo_no.
**                                       - Fixed typo for LIQUEFIED 
*****************************************************************/


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : cargo_statement_cooling_func
-- Description    : returns the vessel name and LC lifting number for the given Cargo.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :  STORAGE_LIFT_NOMINATION, CARGO_TRANSPORT
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      : used by Cargo Docs - Statement of Cooling
--
-----------------------------------------------------------------------------------------------------
FUNCTION cargo_statement_cooling_func (n_parcel_no NUMBER)
   RETURN ue_ct_stmnt_cool    PIPELINED
IS

   TYPE ref_cur IS REF CURSOR;

   myCursor  ref_cur;
   -- Begin
   /*
   out_rec   ue_ct_stmnt_cool_rec_type  := ue_ct_stmnt_cool_rec_type (NULL, NULL);
   */
   out_rec   ue_ct_stmnt_cool_rec_type  := ue_ct_stmnt_cool_rec_type (NULL, NULL, NULL, NULL, NULL);
   -- End
   cargo_doc prosty_codes.code_text%TYPE;
   v_errm    VARCHAR2 (64);

   -- Begin
    CURSOR c_dischargePorts(cp_cargo_no NUMBER)
    IS
       SELECT cargo_no,
              LISTAGG(text_16,' / ') WITHIN GROUP (ORDER BY text_16) AS discharge_ports
         FROM (SELECT DISTINCT cargo_no, text_16
                 FROM storage_lift_nomination
                WHERE cargo_no = cp_cargo_no
              )
        GROUP BY cargo_no;

    lv_discharge_port VARCHAR2(4000);
    n_cargo_no NUMBER;
    product_type product.object_code%TYPE;
    v_bol_date VARCHAR2(4000);
   -- End

BEGIN

--   IF ecbp_cargo_status.getECCargoStatus (ec_cargo_transport.cargo_status (ec_storage_lift_nomination.cargo_no (n_parcel_no))) NOT IN ('A', 'C')   THEN
--      RAISE LOGIN_DENIED;
--   END IF;

   -- Begin
   SELECT MAX(cargo_no) INTO n_cargo_no FROM DV_STORAGE_LIFT_NOM_BLMR WHERE parcel_no = n_parcel_no;

   FOR curDP IN c_dischargePorts(n_cargo_no) LOOP
    lv_discharge_port := curDP.discharge_ports;
   END LOOP;
  -- End

   -- Begin
   --Determine product type
   product_type :=  ec_product.object_code (ec_stor_version.product_id (ec_storage_lift_nomination.object_id (n_parcel_no), ec_storage_lift_nomination.bl_date (n_parcel_no), '<='));

   IF product_type = 'LNG'   THEN
      --Assumption: Only ever '1' Run_No
      v_bol_date := TO_CHAR (ec_lifting_activity.from_daytime (ec_storage_lift_nomination.cargo_no (n_parcel_no), 'LNG_MANIFOLD_CLOSE', 1,'LOAD'), 'DD/MON/YYYY');
   ELSIF product_type = 'COND'   THEN
      v_bol_date := TO_CHAR (ec_lifting_activity.from_daytime (ec_storage_lift_nomination.cargo_no (n_parcel_no), 'COND_MANIFOLD_CLOSE', 1,'LOAD'), 'DD/MON/YYYY');
   END IF;
   -- End

   OPEN myCursor FOR
      SELECT EC_CARRIER_VERSION.NAME(EC_CARGO_TRANSPORT.CARRIER_ID(CARGO_NO)
           , EC_STORAGE_LIFT_NOMINATION.BL_DATE(n_parcel_no),'=<')  as vessel_name, reference_lifting_no AS lc_lifting_no
           , local_port_name AS ports_of_loading
           -- Begin
           /*
           , remote_port_name AS ports_of_discharge
           */
           , lv_discharge_port AS ports_of_discharge
           -- End
           , v_bol_date AS bol_date
      FROM   dv_ct_msg_cargo -- EQYP Changed from Gorgon use of fv_ct_msg_cargo_header
      WHERE  parcel_no = n_parcel_no;

   LOOP
      FETCH myCursor
         INTO out_rec.vessel_name
            , out_rec.lc_lifting_no
            -- Begin
            , out_rec.ports_of_loading
            , out_rec.ports_of_discharge
            , out_rec.bol_date;
            -- End
      EXIT WHEN myCursor%NOTFOUND;
      PIPE ROW (out_rec);
   END LOOP;

   CLOSE myCursor;

   RETURN;
EXCEPTION
   WHEN OTHERS   THEN
      v_errm := SUBSTR (SQLERRM, 1, 64);

      OPEN myCursor FOR
         SELECT 'Internal EC System Error "' || v_errm || '"', NULL FROM DUAL;

      LOOP
         FETCH myCursor
           INTO out_rec.vessel_name
              , out_rec.lc_lifting_no  -- EQYP updated from olc_lifting_number
            -- Begin
            , out_rec.ports_of_loading
            , out_rec.ports_of_discharge
            , out_rec.bol_date;
            -- End
         EXIT WHEN myCursor%NOTFOUND;
         PIPE ROW (out_rec);
      END LOOP;

      CLOSE myCursor;

      RETURN;
END cargo_statement_cooling_func;



--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : cargo_header_func
-- Description    : Returns the lifting schedule for the given Cargo.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : STORAGE_LIFT_NOMINATION, CARGO_TRANSPORT, STORAGE_LIFT_NOM_SPLIT
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :  Used in main section of Cargo Documents: Port Timesheet
-----------------------------------------------------------------------------------------------------
FUNCTION cargo_header_func (v_original VARCHAR2, n_parcel_no NUMBER)
   RETURN ue_ct_cargo
   PIPELINED
IS

   TYPE ref_cur IS REF CURSOR;
   myCursor  ref_cur;
   out_rec   ue_ct_cargo_rec_type := ue_ct_cargo_rec_type(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
   cargo_doc prosty_codes.code_text%TYPE;
   v_errm    VARCHAR2 (64);
   lv_company_code VARCHAR2 (32);

BEGIN
   IF ecbp_cargo_status.getECCargoStatus (ec_cargo_transport.cargo_status (ec_storage_lift_nomination.cargo_no (n_parcel_no))) NOT IN ('A', 'C')   THEN
      RAISE LOGIN_DENIED;
   END IF;

    --Determine lifting company code
   lv_company_code :=  ECDP_OBJECTS.GETOBJCODE(EC_LIFTING_ACCOUNT.COMPANY_ID(ec_storage_lift_nomination.lifting_account_id (n_parcel_no)));

   --Determine if Document 'Original' or 'Copy'
   CASE v_original
      WHEN 'Y'      THEN
         cargo_doc := 'Original';
      WHEN 'N'      THEN
         cargo_doc := 'Copy';
      ELSE
         cargo_doc := 'NULL';
   END CASE;

   OPEN myCursor FOR
      SELECT cargo_doc AS cargo_doc_ttl
           , EC_CARRIER_VERSION.NAME(EC_CARGO_TRANSPORT.CARRIER_ID(CARGO_NO), EC_STORAGE_LIFT_NOMINATION.BL_DATE(n_parcel_no),'=<')
           , TO_CHAR (  EC_STORAGE_LIFT_NOMINATION.BL_DATE(n_parcel_no) , 'dd-Mon-yyyy') AS bl_date
           , consignor
           , reference_lifting_no AS lc_lifting_number  -- EQYP updated from olc_lifting_number
           , CONSIGNEE AS CONSIGNEE_NAME
           , bl_number AS bl_no
           , local_port_name AS local_port
           , notify_party
           , edn
           , TO_CHAR (charter_date, 'dd-Mon-yyyy') AS charterparty
           , scac_uic
           , remote_port_name AS discharge_Port
      FROM   dv_ct_msg_cargo
      WHERE  parcel_no = n_parcel_no;

   LOOP
      FETCH myCursor
         INTO out_rec.rec_type
            , out_rec.vessel_name
            , out_rec.bl_date
            , out_rec.consignor_name
            , out_rec.lc_lifting_number  -- EQYP updated from olc_lifting_number
            , out_rec.consignee_name
            , out_rec.bl_no
            , out_rec.local_port
            , out_rec.notify_party
            , out_rec.edn
            , out_rec.charterparty
            , out_rec.scac_uic
            , out_rec.discharge_Port;


      EXIT WHEN myCursor%NOTFOUND;
      PIPE ROW (out_rec);
   END LOOP;

   CLOSE myCursor;

   RETURN;
EXCEPTION
   WHEN OTHERS   THEN
      v_errm := SUBSTR (SQLERRM, 1, 64);
      OPEN myCursor FOR
        SELECT 'Internal EC System Error "'||v_errm||'"',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL from dual;

      LOOP
         FETCH myCursor
            INTO out_rec.rec_type
               , out_rec.vessel_name
               , out_rec.bl_date
               , out_rec.consignor_name
               , out_rec.lc_lifting_number  -- EQYP updated from olc_lifting_number
               , out_rec.consignee_name
               , out_rec.bl_no
               , out_rec.local_port
               , out_rec.notify_party
               , out_rec.edn
               , out_rec.charterparty
               , out_rec.scac_uic
               , out_rec.discharge_Port;

        EXIT WHEN myCursor%NOTFOUND;
        PIPE ROW (out_rec);
      END LOOP;

      CLOSE myCursor;

      RETURN;
END cargo_header_func;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : cargo_timesheet_func
-- Description    : Returns the Cargo activities timesheet data for the given Cargo.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : LIFTING_ACTIVITY
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :  Used in sub-report of Cargo Documents: Port Timesheet.
--
-----------------------------------------------------------------------------------------------------
FUNCTION cargo_timesheet_func (n_parcel_no NUMBER)
   RETURN ue_ct_cargo_timesheet   PIPELINED
IS
   TYPE ref_cur IS REF CURSOR;

   myCursor  ref_cur;
   out_rec   ue_ct_cargo_timesheet_rec_type := ue_ct_cargo_timesheet_rec_type (NULL, NULL, NULL, NULL, NULL, NULL, NULL);
   n_cargo_no storage_lift_nomination.cargo_no%TYPE;
   v_errm    VARCHAR2 (64);

BEGIN
   -- Item 125161 Begin
   --IF ecbp_cargo_status.getECCargoStatus ( ec_cargo_transport.cargo_status ( ec_storage_lift_nomination.cargo_no (n_parcel_no))) NOT IN ('A', 'C')   THEN
   IF ecbp_cargo_status.getECCargoStatus ( ec_cargo_transport.cargo_status ( ec_storage_lift_nomination.cargo_no (n_parcel_no))) NOT IN ('A', 'C', 'R')   THEN
   -- Item 125161 End
      RAISE LOGIN_DENIED;
   END IF;

   n_cargo_no := ec_storage_lift_nomination.cargo_no (n_parcel_no);

   OPEN myCursor FOR
      SELECT   cargo_no, event_no, activity_name, TO_CHAR (activity_start, 'dd-Mon-yyyy HH24:MI') AS activity_start
             , CASE
                  WHEN ec_lifting_activity_code.timestamp_ind (activity_code,'LOAD') =   'Y'
                  THEN 'N/A'
                  ELSE TO_CHAR (activity_end, 'dd-Mon-yyyy HH24:MI')
               END    AS activity_end
             , comments
      FROM     dv_prod_lifting_activity
      WHERE    cargo_no = n_cargo_no
      ORDER BY event_no;


   LOOP
      FETCH myCursor
         INTO out_rec.cargo_no
            , out_rec.event_no
            , out_rec.activity_name
            , out_rec.activity_start
            , out_rec.activity_end
            , out_rec.comments;

      EXIT WHEN myCursor%NOTFOUND;
      PIPE ROW (out_rec);
   END LOOP;

   CLOSE myCursor;

   RETURN;
-- return error message into Cargo Doc for assisting DEBUG
EXCEPTION
   WHEN OTHERS THEN
      v_errm := SUBSTR (SQLERRM, 1, 64);
      OPEN myCursor FOR
        SELECT NULL,NULL,NULL,NULL,NULL,'Internal EC System Error "'||v_errm||'"' from dual;

      LOOP
         FETCH myCursor
            INTO out_rec.cargo_no
               , out_rec.event_no
               , out_rec.activity_name
               , out_rec.activity_start
               , out_rec.activity_end
               , out_rec.comments;

         EXIT WHEN myCursor%NOTFOUND;
         PIPE ROW (out_rec);
      END LOOP;

      CLOSE myCursor;

      RETURN;
END cargo_timesheet_func;

  --<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       :cargo_comp_func
-- Description    : return the appropriate component analysis for the given Cargo
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CARGO_ANALYSIS, CARGO_ANALYSIS_ITEM
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      : Used in sub-report of Cargo Documents:  Certificate of Quality
--
-----------------------------------------------------------------------------------------------------
FUNCTION cargo_comp_func (n_parcel_no NUMBER)
   RETURN ue_ct_cargo_comp
   PIPELINED
IS

   TYPE ref_cur IS REF CURSOR;
   myCursor  ref_cur;
   out_rec   ue_ct_cargo_comp_rec_type  :=  ue_ct_cargo_comp_rec_type(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
   n_cargo_no storage_lift_nomination.cargo_no%TYPE;
   n_analysis_no cargo_analysis.analysis_no%TYPE;
   v_product_code product.object_code%TYPE;
   v_errm    VARCHAR2 (64);

--Listing for cargo_analysis_component
-- listing provided by Sam Webb
--
--10 C1
--20 C2
--30 C3+ = C3, IC4, IC5, NC4, NC5, C6, C7, C8, C9+
--40 C4+ = IC4, IC5, NC4, NC5, C6, C7, C8, C9+
--50 C5+ = IC5, NC5, C6, C7, C8, C9+
--60 N2
--70 CO2
--80 O2

BEGIN
--INSERT INTO TEMP1 VALUES('1','IN');
--Commit;
   IF ecbp_cargo_status.getECCargoStatus (ec_cargo_transport.cargo_status ( ec_storage_lift_nomination.cargo_no (n_parcel_no))) NOT IN  ('A', 'C')   THEN      
      RAISE LOGIN_DENIED;
	 --v_errm := 'Test';
   END IF;

   n_cargo_no := ec_storage_lift_nomination.cargo_no (n_parcel_no);

   SELECT analysis_no, product_code
   INTO   n_analysis_no, v_product_code
   FROM   dv_cargo_analysis
   WHERE  cargo_no = n_cargo_no AND NVL (official_ind, 'N') = 'Y';


   IF v_product_code = 'COND'   THEN
      OPEN myCursor FOR
         SELECT n_cargo_no AS cargo_no
              , grp
              , analysis_item
              , test_method
              , analysis_value
              , unit AS analysis_unit
              , min_spec
              , max_spec
         FROM   (SELECT   ec_analysis_item.item_name (analysis_item_code)   AS analysis_item
                        , analysis_value
                        , unit
                        , ec_analysis_item.text_3 (analysis_item_code)      AS test_method
                        , ec_analysis_item.text_5 (analysis_item_code)   || ec_analysis_item.value_10 (analysis_item_code)    AS min_spec
                        , ec_analysis_item.text_4 (analysis_item_code)   || ec_analysis_item.value_9 (analysis_item_code)     AS max_spec
                        , 1 AS grp
                 FROM     dv_cargo_analysis_basic
                 WHERE    analysis_no = n_analysis_no
                 AND      dv_cargo_analysis_basic.analysis_item_code IN ('RVP',
                                                                         'BS_W',
                                                                         'SALT',
                                                                         'DENSITY',
                                                                         'MERCURY',
                                                                         'API',
                                                                         'COND_SULFUR')


                 ORDER BY sort_order);

   ELSIF v_product_code = 'LNG'   THEN
      OPEN myCursor FOR
        SELECT n_cargo_no AS cargo_no
              , grp
              , analysis_item
              , test_method
              , analysis_value
              , unit AS analysis_unit
              , min_spec
              , max_spec
           FROM  (
           --Item 113805: Begin
           /*
           SELECT --CASE WHEN analysis_item_code in ('H2S', 'MERCAPTAN', 'SULFUR')
                         --     THEN ec_analysis_item.item_name (analysis_item_code) || '<sup>2</sup>'
                         --     ELSE ec_analysis_item.item_name (analysis_item_code)
                         -- END AS analysis_item ,
                         ec_analysis_item.item_name (analysis_item_code) AS analysis_item,
                         analysis_value ,
                         unit ,
                         ec_analysis_item.text_3 (analysis_item_code) AS test_method ,
                         ec_analysis_item.text_5 (analysis_item_code) || ec_analysis_item.value_10 (analysis_item_code) AS min_spec ,
                         ec_analysis_item.text_4 (analysis_item_code) || ec_analysis_item.value_9 (analysis_item_code)  AS max_spec ,
                         1 AS grp
                    FROM dv_cargo_analysis_basic
                   WHERE analysis_no = n_analysis_no
                     AND analysis_item_code IN ('H2S','HG', 'MERCAPTAN', 'SULFUR', 'CO2', 'OXYGEN')
            */

                SELECT --CASE WHEN analysis_item_code in ('H2S', 'MERCAPTAN', 'SULFUR')
                                         --     THEN ec_analysis_item.item_name (analysis_item_code) || '<sup>2</sup>'
                                         --     ELSE ec_analysis_item.item_name (analysis_item_code)
                                         -- END AS analysis_item ,
                       ec_analysis_item.item_name (analysis_item_code) AS analysis_item,
                       analysis_value ,
                       unit ,
                       ec_analysis_item.text_3 (analysis_item_code) AS test_method ,
                       ec_analysis_item.text_5 (analysis_item_code) || ec_analysis_item.value_10 (analysis_item_code) AS min_spec ,
                       ec_analysis_item.text_4 (analysis_item_code) || ec_analysis_item.value_9 (analysis_item_code)  AS max_spec ,
                       1 AS grp
                  FROM dv_cargo_analysis_basic
                 WHERE analysis_no = n_analysis_no
                   AND analysis_item_code IN ('HG', 'MERCAPTAN', 'OXYGEN')
                 UNION ALL
                SELECT   (CASE WHEN INSTR(ec_analysis_item.item_name (analysis_item_code), '(') > 0
                             THEN RTRIM(substr(ec_analysis_item.item_name (analysis_item_code), 1, instr(ec_analysis_item.item_name (analysis_item_code), '(') -1))
                             ELSE ec_analysis_item.item_name (analysis_item_code)
                         END) AS analysis_item,
                       analysis_value ,
                       unit ,
                       ec_analysis_item.text_3 (analysis_item_code) AS test_method ,
                       ec_analysis_item.text_5 (analysis_item_code) || ec_analysis_item.value_10 (analysis_item_code) AS min_spec ,
                       ec_analysis_item.text_4 (analysis_item_code) || ec_analysis_item.value_9 (analysis_item_code)  AS max_spec ,
                       1 AS grp
                  FROM dv_cargo_analysis_basic
                 WHERE analysis_no = n_analysis_no
                   AND (
                         CASE WHEN (ec_cargo_analysis_item.analysis_value(analysis_no, 'H2S') IS NULL
                                    AND ec_cargo_analysis_item.analysis_value(analysis_no, 'H2S_UOP212') IS NOT NULL)
                            THEN 'H2S_UOP212'
                            WHEN (ec_cargo_analysis_item.analysis_value(analysis_no, 'H2S_UOP212') IS NULL
                                    AND ec_cargo_analysis_item.analysis_value(analysis_no, 'H2S') IS NOT NULL)
                            THEN 'H2S'
                            WHEN (ec_cargo_analysis_item.analysis_value(analysis_no, 'H2S') IS NOT NULL
                                  AND ec_cargo_analysis_item.analysis_value(analysis_no, 'H2S_UOP212') IS NOT NULL)
                            THEN (SELECT item_code FROM analysis_item WHERE item_code in ('H2S', 'H2S_UOP212') AND Nvl(text_6,'N') = 'Y')
                            ELSE 'H2S'
                         END
                   ) = analysis_item_code
                UNION ALL
                SELECT   (CASE WHEN INSTR(ec_analysis_item.item_name (analysis_item_code), '(') > 0
                             THEN RTRIM(substr(ec_analysis_item.item_name (analysis_item_code), 1, instr(ec_analysis_item.item_name (analysis_item_code), '(') -1))
                             ELSE ec_analysis_item.item_name (analysis_item_code)
                         END) AS analysis_item,
                       analysis_value ,
                       unit ,
                       ec_analysis_item.text_3 (analysis_item_code) AS test_method ,
                       ec_analysis_item.text_5 (analysis_item_code) || ec_analysis_item.value_10 (analysis_item_code) AS min_spec ,
                       ec_analysis_item.text_4 (analysis_item_code) || ec_analysis_item.value_9 (analysis_item_code)  AS max_spec ,
                       1 AS grp
                  FROM dv_cargo_analysis_basic
                 WHERE analysis_no = n_analysis_no
                   AND (
                         CASE WHEN (ec_cargo_analysis_item.analysis_value(analysis_no, 'CO2') IS NULL
                                    AND ec_cargo_analysis_item.analysis_value(analysis_no, 'CO2_ISO') IS NOT NULL)
                            THEN 'CO2_ISO'
                            WHEN (ec_cargo_analysis_item.analysis_value(analysis_no, 'CO2_ISO') IS NULL
                                    AND ec_cargo_analysis_item.analysis_value(analysis_no, 'CO2') IS NOT NULL)
                            THEN 'CO2'
                            WHEN (ec_cargo_analysis_item.analysis_value(analysis_no, 'CO2') IS NOT NULL
                                  AND ec_cargo_analysis_item.analysis_value(analysis_no, 'CO2_ISO') IS NOT NULL)
                            THEN (SELECT item_code FROM analysis_item WHERE item_code in ('CO2', 'CO2_ISO') AND Nvl(text_6,'N') = 'Y')
                            ELSE 'CO2'
                         END
                   ) = analysis_item_code
                UNION ALL
                SELECT  (CASE WHEN INSTR(ec_analysis_item.item_name (analysis_item_code), '(') > 0
                             THEN RTRIM(substr(ec_analysis_item.item_name (analysis_item_code), 1, instr(ec_analysis_item.item_name (analysis_item_code), '(') -1))
                             ELSE ec_analysis_item.item_name (analysis_item_code)
                         END) AS analysis_item,
                       analysis_value ,
                       unit ,
                       ec_analysis_item.text_3 (analysis_item_code) AS test_method ,
                       ec_analysis_item.text_5 (analysis_item_code) || ec_analysis_item.value_10 (analysis_item_code) AS min_spec ,
                       ec_analysis_item.text_4 (analysis_item_code) || ec_analysis_item.value_9 (analysis_item_code)  AS max_spec ,
                       1 AS grp
                  FROM dv_cargo_analysis_basic
                 WHERE analysis_no = n_analysis_no
                   AND (
                         CASE WHEN (ec_cargo_analysis_item.analysis_value(analysis_no, 'SULFUR') IS NULL
                                    AND ec_cargo_analysis_item.analysis_value(analysis_no, 'SULFUR_D6667') IS NOT NULL)
                            THEN 'SULFUR_D6667'
                            WHEN (ec_cargo_analysis_item.analysis_value(analysis_no, 'SULFUR_D6667') IS NULL
                                    AND ec_cargo_analysis_item.analysis_value(analysis_no, 'SULFUR') IS NOT NULL)
                            THEN 'SULFUR'
                            WHEN (ec_cargo_analysis_item.analysis_value(analysis_no, 'SULFUR') IS NOT NULL
                                  AND ec_cargo_analysis_item.analysis_value(analysis_no, 'SULFUR_D6667') IS NOT NULL)
                            THEN (SELECT item_code FROM analysis_item WHERE item_code in ('SULFUR', 'SULFUR_D6667') AND Nvl(text_6,'N') = 'Y')
                            ELSE 'SULFUR'
                         END
                   ) = analysis_item_code
            --Item 113805: End
          UNION ALL
                  SELECT ec_analysis_item.item_name (analysis_item_code) AS analysis_item ,
                         analysis_value ,
                         ec_ctrl_unit.label ('MOLPCT') AS unit ,
                         ec_analysis_item.text_3 (analysis_item_code) AS test_method ,
                         ec_analysis_item.text_5 (analysis_item_code) || TRIM(TO_CHAR(ec_analysis_item.value_10 (analysis_item_code), 990.9)) AS min_spec ,
                         ec_analysis_item.text_4 (analysis_item_code) || TRIM(TO_CHAR(ec_analysis_item.value_9 (analysis_item_code), 990.9))  AS max_spec ,
                         2 AS grp
                    FROM dv_cargo_analysis_basic
                   WHERE analysis_no = n_analysis_no
                     AND ANALYSIS_ITEM_CODE IN ('C3+','C4+','C5+')
          UNION ALL
                  SELECT ec_analysis_item.item_name (analysis_item_code) AS analysis_item ,
                         analysis_value ,
                         ec_ctrl_unit.label ('MOLPCT') AS unit ,
                         ec_analysis_item.text_3 (analysis_item_code) AS test_method ,
                         ec_analysis_item.text_5 (analysis_item_code) || TRIM(TO_CHAR(ec_analysis_item.value_10 (analysis_item_code), 990.9)) AS min_spec ,
                         ec_analysis_item.text_4 (analysis_item_code) || TRIM(TO_CHAR(ec_analysis_item.value_9 (analysis_item_code), 990.9))  AS max_spec ,
                         2 AS grp
                    FROM dv_cargo_analysis_component
                   WHERE analysis_no = n_analysis_no
                     -- Item 111091: Begin
                     /*
                     AND analysis_item_code IN ('N2','C1','C2','C3','IC4','NC4','NC5','NC6')
                     */
                     AND analysis_item_code IN ('N2','C1','C2','C3','IC4','NC4','IC5','NC5','NC6')
                     -- Item 111091: End
          UNION ALL
                  SELECT ec_analysis_item.item_name (analysis_item_code) AS analysis_item ,
                         analysis_value ,
                         unit ,
                         ec_analysis_item.text_3 (analysis_item_code) AS test_method ,
                         ec_analysis_item.text_5 (analysis_item_code) || TO_CHAR(ec_analysis_item.value_10 (analysis_item_code), 'FM99,999') AS min_spec ,
                         ec_analysis_item.text_4 (analysis_item_code) || TO_CHAR(ec_analysis_item.value_9 (analysis_item_code), 'FM99,999')  AS max_spec ,
                         3 AS grp
                    FROM dv_cargo_analysis_basic
                   WHERE analysis_no = n_analysis_no
                     AND analysis_item_code IN ('LNG_DENSITY','VOLUME_GHV','WOBBE_INDEX')
  )
ORDER BY GRP ASC,
  CASE
    WHEN analysis_item like 'Hydrogen Sulphide%' AND grp =1 THEN 1
    WHEN analysis_item like 'Mercaptan Sulphur%' AND grp =1 THEN 2
    WHEN analysis_item = 'Mercury'  AND grp =1 THEN 3
    WHEN analysis_item like 'Total Sulphur%' AND grp =1 THEN 4
    WHEN analysis_item = 'Carbon Dioxide' AND grp =1 THEN 5
    WHEN analysis_item = 'Oxygen' AND grp =1 THEN 6
    WHEN analysis_item = 'Methane' AND GRP = 2 THEN 1
    WHEN analysis_item = 'Ethane' AND GRP = 2 THEN 2
    WHEN analysis_item = 'Propane + Heavier' AND grp =2 THEN 3
    WHEN analysis_item = 'Propane' AND grp = 2 THEN 4
    WHEN analysis_item = 'Butanes + Heavier' AND grp =2 THEN 5
    WHEN analysis_item = 'i-Butane' AND grp = 2 THEN 6
    WHEN analysis_item = 'n-Butane' AND grp = 2 THEN 7
    WHEN analysis_item = 'Pentanes + Heavier' AND grp = 2 THEN 8
    WHEN analysis_item = 'i-Pentane' AND grp = 2 THEN 9
    WHEN analysis_item = 'n-Pentane' AND grp = 2 THEN 10
    WHEN analysis_item = 'n-Hexanes' AND grp = 2 THEN 11
    WHEN analysis_item = 'Nitrogen' AND grp = 2 THEN 12
    WHEN analysis_item = 'Density' AND grp =3 THEN 1
    WHEN analysis_item = 'GHV (Volume)' AND grp =3 THEN 2
    WHEN analysis_item = 'Wobbe Index' AND grp =3 THEN 3
  END;
   END IF;

   LOOP FETCH myCursor
         INTO out_rec.cargo_no
            , out_rec.grp
            , out_rec.analysis_item
            , out_rec.test_method
            , out_rec.analysis_value
            , out_rec.analysis_unit
            , out_rec.min_spec
            , out_rec.max_spec;

      EXIT WHEN myCursor%NOTFOUND;
      PIPE ROW (out_rec);
   END LOOP;

   CLOSE myCursor;

   RETURN;
-- return error message into Cargo Doc for assisting DEBUG
EXCEPTION
   WHEN OTHERS   THEN
      v_errm := SUBSTR (SQLERRM, 1, 64);

      OPEN myCursor FOR
         SELECT NULL,NULL,NULL,'Internal EC System Error "'||v_errm||'"',NULL,NULL,NULL,NULL FROM dual;

      LOOP
         FETCH myCursor
            INTO out_rec.cargo_no
               , out_rec.grp
               , out_rec.analysis_item
               , out_rec.test_method
               , out_rec.analysis_value
               , out_rec.analysis_unit
               , out_rec.min_spec
               , out_rec.max_spec;

         EXIT WHEN myCursor%NOTFOUND;
         PIPE ROW (out_rec);
      END LOOP;

      CLOSE myCursor;

      RETURN;
END cargo_comp_func;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       :cargo_qly_func
-- Description    : return the analysis sample details of the given Cargo.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CARGO_ANALYSIS
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      : used in the main report for Cargo Documents:  Certificate of Quality
--
-----------------------------------------------------------------------------------------------------
FUNCTION cargo_qly_func (v_original VARCHAR2, n_parcel_no NUMBER)
   RETURN ue_ct_cargo_qly   PIPELINED
IS

   TYPE ref_cur IS REF CURSOR;
   myCursor  ref_cur;
   -- Begin
   /*
   out_rec   ue_ct_cargo_qly_rec_type  := ue_ct_cargo_qly_rec_type(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
   */
   out_rec   ue_ct_cargo_qly_rec_type  := ue_ct_cargo_qly_rec_type(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);  --Item 132627
   -- End
   cargo_doc prosty_codes.code_text%TYPE;
   n_cargo_no storage_lift_nomination.cargo_no%TYPE;
   v_errm    VARCHAR2 (64);
   lv_company_code VARCHAR2 (32);

   -- Begin
   v_bol_date VARCHAR2(4000);
   product_type product.object_code%TYPE;
   -- End

BEGIN
   IF ecbp_cargo_status.getECCargoStatus ( ec_cargo_transport.cargo_status (ec_storage_lift_nomination.cargo_no (n_parcel_no))) NOT IN ('A', 'C') THEN
      RAISE LOGIN_DENIED;
   END IF;

   -- Begin
   --Determine product type
   product_type :=  ec_product.object_code (ec_stor_version.product_id (ec_storage_lift_nomination.object_id (n_parcel_no), ec_storage_lift_nomination.bl_date (n_parcel_no), '<='));
   -- End

   --Determine if Document 'Original' or 'Copy'
   CASE v_original
      WHEN 'Y'      THEN
         cargo_doc := 'Original';
      WHEN 'N'      THEN
         cargo_doc := 'Copy';
      ELSE
         cargo_doc := 'NULL';
   END CASE;

   n_cargo_no := ec_storage_lift_nomination.cargo_no (n_parcel_no);
   lv_company_code :=  ECDP_OBJECTS.GETOBJCODE(EC_LIFTING_ACCOUNT.COMPANY_ID(ec_storage_lift_nomination.lifting_account_id (n_parcel_no)));

-- Begin
   IF product_type = 'LNG'   THEN
      --Assumption: Only ever '1' Run_No
      v_bol_date := TO_CHAR (ec_lifting_activity.from_daytime (ec_storage_lift_nomination.cargo_no (n_parcel_no), 'LNG_MANIFOLD_CLOSE', 1,'LOAD'), 'DD/MON/YYYY');
   ELSIF product_type = 'COND'   THEN
      v_bol_date := TO_CHAR (ec_lifting_activity.from_daytime (ec_storage_lift_nomination.cargo_no (n_parcel_no), 'COND_MANIFOLD_CLOSE', 1,'LOAD'), 'DD/MON/YYYY');
   END IF;
-- End

   OPEN myCursor FOR
      SELECT cargo_doc AS cargo_doc_ttl
           , EC_CARRIER_VERSION.NAME(EC_CARGO_TRANSPORT.CARRIER_ID(CARGO_NO), EC_STORAGE_LIFT_NOMINATION.BL_DATE(n_parcel_no),'=<')  as vessel_name
           , TO_CHAR (sample_daytime, 'dd-Mon-yyyy HH24:MI') AS sample_daytime
           , seal_no AS sample_number
           , sample_id
           , EC_CT_LIFTING_NUMBERS.lifting_number (n_parcel_no)   AS lc_lifting_number  -- EQYP updated from olc_lifting_number
           , ec_product_version.name (product_id, daytime, '<=')      AS product
           , ec_prosty_codes.code_text (sampling_method, 'CARGO_SAMPLING_METHOD')  AS sampling_method
           , CASE lv_company_code
              WHEN 'TAPL' THEN 'Y'
              WHEN 'CAPL' THEN 'Y'
              ELSE null
            END AS show_chevron_logo
           -- Begin
           , sample_source
           , ec_prosty_codes.CODE_TEXT(ANALYSIS_TYPE, 'CARGO_ANALYSIS_TYPE') AS analysis_method
           , v_bol_date AS bol_date
           -- End
		   , n_cargo_no AS cargo_no  --Item 132627
      FROM   dv_cargo_analysis
      WHERE  cargo_no = n_cargo_no AND NVL (official_ind, 'N') = 'Y';

   LOOP
      FETCH myCursor
         INTO out_rec.rec_type
            , out_rec.vessel_name
            , out_rec.sample_datetime
            , out_rec.sample_number
            , out_rec.sample_id
            , out_rec.lc_lifting_number
            , out_rec.product
            , out_rec.sampling_method
            , out_rec.show_chevron_logo
            -- Begin
            , out_rec.sample_source
            , out_rec.analysis_method
            , out_rec.bol_date
            -- End
            , out_rec.cargo_no;  --Item 132627
      EXIT WHEN myCursor%NOTFOUND;
      PIPE ROW (out_rec);
   END LOOP;

   CLOSE myCursor;

   RETURN;
-- return error message into Cargo Doc for assisting DEBUG
EXCEPTION
   WHEN OTHERS   THEN
      v_errm := SUBSTR (SQLERRM, 1, 64);

      OPEN myCursor FOR
         SELECT 'Internal EC System Error "'||v_errm||'"',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL from dual; --Item 132627

      LOOP
         FETCH myCursor
            INTO out_rec.rec_type
               , out_rec.vessel_name
               , out_rec.sample_datetime
               , out_rec.sample_number
               , out_rec.sample_id
               , out_rec.lc_lifting_number
               , out_rec.product
               , out_rec.sampling_method
               , out_rec.show_chevron_logo
               -- Begin
               , out_rec.sample_source
               , out_rec.analysis_method
               , out_rec.bol_date
               -- End
               , out_rec.cargo_no;  --Item 132627
         EXIT WHEN myCursor%NOTFOUND;
         PIPE ROW (out_rec);
      END LOOP;

      CLOSE myCursor;

      RETURN;
END cargo_qly_func;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : cargo_man_func
-- Description    : return the lifting details for the given Cargo.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : STORAGE_LIFT_NOMINATION, CARGO_TRANSPORT, STORAGE_LIFT_NOM_SPLIT
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      : used in the main report section of Cargo Documents:
--                   1. Cargo Manifest
--                   2. Certificate of Quantity
--                   3. Receipt for Documents
--                   4. Port Timesheet
--
-----------------------------------------------------------------------------------------------------
FUNCTION cargo_man_func (v_original VARCHAR2, n_parcel_no NUMBER)
   RETURN ue_ct_cargo_man
   PIPELINED
IS

   TYPE ref_cur IS REF CURSOR;
   myCursor  ref_cur;
   -- Begin
   /*
   out_rec   ue_ct_cargo_man_rec_type  := ue_ct_cargo_man_rec_type(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
   */
   out_rec ue_ct_cargo_man_rec_type := ue_ct_cargo_man_rec_type(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL); --Item 132627: Added cargo_no
   -- End
   cargo_doc prosty_codes.code_text%TYPE;
   product_type product.object_code%TYPE;
   v_errm    VARCHAR2 (64);
   arrived_loadport VARCHAR2 (240);
   sailed_loadport VARCHAR2 (240);
   product_note VARCHAR2 (240);
   lv_company_code VARCHAR2 (32);
   n_cargo_no storage_lift_nomination.cargo_no%TYPE;  --Item 132627
   -- Begin
   v_count NUMBER := 0;
   v_bol_date VARCHAR2(4000);
   -- End

BEGIN
   -- Item 125161 Begin
   --IF ecbp_cargo_status.getECCargoStatus (ec_cargo_transport.cargo_status (ec_storage_lift_nomination.cargo_no (n_parcel_no))) NOT IN ('A', 'C')   THEN
   IF ecbp_cargo_status.getECCargoStatus (ec_cargo_transport.cargo_status (ec_storage_lift_nomination.cargo_no (n_parcel_no))) NOT IN ('A', 'C', 'R')   THEN
   -- Item 125161 End
      RAISE LOGIN_DENIED;
   END IF;

   --Determine product type
   product_type :=  ec_product.object_code (ec_stor_version.product_id (ec_storage_lift_nomination.object_id (n_parcel_no), ec_storage_lift_nomination.bl_date (n_parcel_no), '<='));

   n_cargo_no := ec_storage_lift_nomination.cargo_no (n_parcel_no);  --Item 132627
  --Determine Lifting Company Code
  lv_company_code :=  ECDP_OBJECTS.GETOBJCODE(EC_LIFTING_ACCOUNT.COMPANY_ID(ec_storage_lift_nomination.lifting_account_id (n_parcel_no)));

   --Determine if Document 'Original' or 'Copy'
   CASE v_original
      WHEN 'Y'      THEN
         cargo_doc := 'Original';
      WHEN 'N'      THEN
         cargo_doc := 'Copy';
      ELSE
         cargo_doc := 'NULL';
   END CASE;


   IF product_type = 'LNG'   THEN
      --Assumption: Only ever '1' Run_No
      arrived_loadport :=  TO_CHAR (ec_lifting_activity.from_daytime (ec_storage_lift_nomination.cargo_no (n_parcel_no), 'LNG_PILOT_STATION', 1,'LOAD'), 'dd-Mon-yyyy HH24:MI');
      sailed_loadport := TO_CHAR (ec_lifting_activity.from_daytime (ec_storage_lift_nomination.cargo_no (n_parcel_no), 'LNG_SHIP_DEPARTS', 1,'LOAD'), 'dd-Mon-yyyy HH24:MI');

      -- Begin
      /*
      product_note := 'LNG';
      */
      product_note := 'LIQUEFIED NATURAL GAS (LNG)';
      v_bol_date := TO_CHAR (ec_lifting_activity.from_daytime (ec_storage_lift_nomination.cargo_no (n_parcel_no), 'LNG_MANIFOLD_CLOSE', 1,'LOAD'), 'DD/MON/YYYY');
      -- End

   ELSIF product_type = 'COND'   THEN
      --Assumption: Only ever '1' Run_No
      arrived_loadport := TO_CHAR (ec_lifting_activity.from_daytime (ec_storage_lift_nomination.cargo_no (n_parcel_no), 'COND_PILOT_STATION', 1,'LOAD'), 'dd-Mon-yyyy HH24:MI');
      sailed_loadport := TO_CHAR (ec_lifting_activity.from_daytime (ec_storage_lift_nomination.cargo_no (n_parcel_no), 'COND_SHIP_DEPARTS', 1,'LOAD'), 'dd-Mon-yyyy HH24:MI');
      product_note := 'WHEATSTONE CONDENSATE';
      -- Begin
      v_bol_date := TO_CHAR (ec_lifting_activity.from_daytime (ec_storage_lift_nomination.cargo_no (n_parcel_no), 'COND_MANIFOLD_CLOSE', 1,'LOAD'), 'DD/MON/YYYY');
      -- End
   END IF;

   -- Begin
   SELECT COUNT(1) INTO v_count
     FROM storage_lift_nomination
    WHERE cargo_no = ec_storage_lift_nomination.cargo_no (n_parcel_no);
   -- End

   OPEN myCursor FOR
      SELECT cargo_doc AS cargo_doc_ttl
           ,  EC_CARRIER_VERSION.NAME(EC_CARGO_TRANSPORT.CARRIER_ID(CARGO_NO), EC_STORAGE_LIFT_NOMINATION.BL_DATE(n_parcel_no),'=<')
           , MASTER as captain         --eqyp. Mapped to Master, Gorgon implementation had this shown aas null.
           , arrived_loadport
           , sailed_loadport
           , local_port_name AS ports_of_loading
           , remote_port_name AS ports_of_discharge
           , lifting_account_id
           , lifting_account_name
           , consignor AS consignor
           , consignee AS CONSIGNEE
           , reference_lifting_no AS lc_lifting_number
           , bl_number AS bl_no
           , edn
           , product_note        --used in Certificate of Quality
           -- Begin
           , scac_uic
           , notify_party
           , v_bol_date AS bol_date
           , CASE WHEN v_count > 1
                  THEN 'Sub Manifest'
                  ELSE 'Main Manifest'
              END AS doc_header
           -- End
		   , n_cargo_no AS cargo_no   --Item 132627
      FROM   dv_ct_msg_cargo
     --        INNER JOIN dv_ct_msg_cargo_detail mcd -- dv_ct_msg_cargo_split mcs
     --           ON msh.parcel_no = mcd.parcel_no
      WHERE  parcel_no = n_parcel_no;

   LOOP
      FETCH myCursor
         INTO out_rec.rec_type
            , out_rec.vessel_name
            , out_rec.captain
            , out_rec.arrived_loadport
            , out_rec.sailed_loadport
            , out_rec.ports_of_loading
            , out_rec.ports_of_discharge
            , out_rec.lifting_account_id
            , out_rec.lifting_account_name
            , out_rec.consignor
            , out_rec.consignee
            , out_rec.lc_lifting_no
            , out_rec.bl_no
            , out_rec.edn
            , out_rec.product_note
            -- Begin
            , out_rec.scac_uic
            , out_rec.notify_party
            , out_rec.bol_date
            , out_rec.doc_header
            -- End
            , out_rec.cargo_no;  --Item 132627

      EXIT WHEN myCursor%NOTFOUND;
      PIPE ROW (out_rec);
   END LOOP;

   CLOSE myCursor;

   RETURN;
-- return error message into Cargo Doc for assisting DEBUG
EXCEPTION
   WHEN OTHERS   THEN
      v_errm := SUBSTR (SQLERRM, 1, 64);

      OPEN myCursor FOR
      -- Begin
         /*
         SELECT 'Internal EC System Error "'||v_errm||'"',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL from dual;
        */
          SELECT 'Internal EC System Error "'||v_errm||'"',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL from dual; --Item 132627: Added cargo_no
      -- End

      LOOP
         FETCH myCursor
            INTO out_rec.rec_type
               , out_rec.vessel_name
               , out_rec.captain
               , out_rec.arrived_loadport
               , out_rec.sailed_loadport
               , out_rec.ports_of_loading
               , out_rec.ports_of_discharge
               , out_rec.lifting_account_id
               , out_rec.lifting_account_name
               , out_rec.consignor
               , out_rec.consignee
               , out_rec.lc_lifting_no
               , out_rec.bl_no
               , out_rec.edn
               , out_rec.product_note
               -- Begin
               , out_rec.scac_uic
               , out_rec.notify_party
               , out_rec.bol_date
               , out_rec.doc_header
               -- End
               , out_rec.cargo_no;   --Item 132627
         EXIT WHEN myCursor%NOTFOUND;
         PIPE ROW (out_rec);
      END LOOP;

      CLOSE myCursor;

      RETURN;
END cargo_man_func;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       :cargo_rct_func
-- Description    : return the lifting details for a given cargo
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CARGO_TRANSPORT, STORAGE_LIFT_NOM_SPLIT
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      : used in main report section of the following Cargo documents:
--                   1. Receipt for Samples
--
-----------------------------------------------------------------------------------------------------
FUNCTION cargo_rct_func (v_original VARCHAR2, n_parcel_no NUMBER)
   -- Begin
   /*
   RETURN ue_ct_cargo_man
   */
   RETURN ue_ct_cargo_rct
   -- End
   PIPELINED
IS
   TYPE ref_cur IS REF CURSOR;

   myCursor  ref_cur;

-- Begin
   /*
   out_rec   ue_ct_cargo_man_rec_type := ue_ct_cargo_man_rec_type(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
  */
   out_rec   ue_ct_cargo_rct_rec_type := ue_ct_cargo_rct_rec_type(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
-- End
   cargo_doc prosty_codes.code_text%TYPE;
   product_type product.object_code%TYPE;
   v_errm    VARCHAR2 (64);
   arrived_loadport VARCHAR2 (240);
   sailed_loadport VARCHAR2 (240);
   product_note VARCHAR2 (240);
   lv_company_code VARCHAR2 (32);

   -- Begin
    CURSOR c_dischargePorts(cp_cargo_no NUMBER)
    IS
       SELECT cargo_no,
              LISTAGG(text_16,' / ') WITHIN GROUP (ORDER BY text_16) AS discharge_ports
         FROM (SELECT DISTINCT cargo_no, text_16
                 FROM storage_lift_nomination
                WHERE cargo_no = cp_cargo_no
              )
        GROUP BY cargo_no;

    lv_discharge_port VARCHAR2(4000);
    n_cargo_no NUMBER;
   -- End

BEGIN
   -- Begin
   /*
   IF ecbp_cargo_status.getECCargoStatus (ec_cargo_transport.cargo_status (ec_storage_lift_nomination.cargo_no (n_parcel_no))) NOT IN  ('A', 'C')  THEN
      RAISE LOGIN_DENIED;
   END IF;
  */
  -- End

   -- Begin
   SELECT MAX(cargo_no) INTO n_cargo_no FROM DV_STORAGE_LIFT_NOM_BLMR WHERE parcel_no = n_parcel_no;

   FOR curDP IN c_dischargePorts(n_cargo_no) LOOP
    lv_discharge_port := curDP.discharge_ports;
   END LOOP;
  -- End

   --Determine product type
   product_type := ec_product.object_code ( ec_stor_version.product_id (ec_storage_lift_nomination.object_id (n_parcel_no), ec_storage_lift_nomination.bl_date (n_parcel_no) , '<='));

   --Determine Lifting Company Code
  lv_company_code :=  ECDP_OBJECTS.GETOBJCODE(EC_LIFTING_ACCOUNT.COMPANY_ID(ec_storage_lift_nomination.lifting_account_id (n_parcel_no)));

   --Determine if Document 'Original' or 'Copy'
   CASE v_original
      WHEN 'Y'      THEN
         cargo_doc := 'Original';
      WHEN 'N'      THEN
         cargo_doc := 'Copy';
      ELSE
         cargo_doc := 'NULL';
   END CASE;


   IF product_type = 'LNG'   THEN
      --Assumption: Only ever '1' Run_No
      arrived_loadport := TO_CHAR (ec_lifting_activity.from_daytime ( ec_storage_lift_nomination.cargo_no (n_parcel_no), 'LNG_PILOT_STATION', 1,'LOAD'), 'dd-Mon-yyyy HH24:MI');
      sailed_loadport := TO_CHAR (ec_lifting_activity.from_daytime (ec_storage_lift_nomination.cargo_no (n_parcel_no), 'LNG_SHIP_DEPARTS', 1,'LOAD'), 'dd-Mon-yyyy HH24:MI');
      -- Begin
      /*
      product_note := 'LNG';
      */
      product_note := 'LIQUEFIED NATURAL GAS (LNG)';  --Item 132627
      -- End

   ELSIF product_type = 'COND'   THEN
      --Assumption: Only ever '1' Run_No
      arrived_loadport := TO_CHAR (ec_lifting_activity.from_daytime (ec_storage_lift_nomination.cargo_no (n_parcel_no), 'COND_PILOT_STATION', 1,'LOAD'), 'dd-Mon-yyyy HH24:MI');
      sailed_loadport := TO_CHAR (ec_lifting_activity.from_daytime (ec_storage_lift_nomination.cargo_no (n_parcel_no), 'COND_SHIP_DEPARTS', 1,'LOAD'), 'dd-Mon-yyyy HH24:MI');
      product_note := 'WHEATSTONE CONDENSATE';
   END IF;

   OPEN myCursor FOR
      SELECT cargo_doc AS cargo_doc_ttl
           , EC_CARRIER_VERSION.NAME(EC_CARGO_TRANSPORT.CARRIER_ID(CARGO_NO), EC_STORAGE_LIFT_NOMINATION.BL_DATE(n_parcel_no),'=<')
           , master as captain          --mapped to master, gorgon had this as null
           , arrived_loadport
           , sailed_loadport
           , local_port_name AS ports_of_loading
           -- Begin
           /*
           , remote_port_name AS ports_of_discharge
           */
           , lv_discharge_port AS ports_of_discharge
           -- End
           , lifting_account_id
           , lifting_account_name
           , consignor AS consignor
           , consignee AS CONSIGNEE
           , reference_lifting_no AS lc_lifting_number
           , bl_number AS bl_no
           , edn
           , product_note         --used in Certificate of Quality
      FROM   dv_ct_msg_cargo
      WHERE  parcel_no = n_parcel_no;

   LOOP
      FETCH myCursor
         INTO out_rec.rec_type
            , out_rec.vessel_name
            , out_rec.captain
            , out_rec.arrived_loadport
            , out_rec.sailed_loadport
            , out_rec.ports_of_loading
            , out_rec.ports_of_discharge
            , out_rec.lifting_account_id
            , out_rec.lifting_account_name
            , out_rec.consignor
            , out_rec.consignee
            , out_rec.lc_lifting_no
            , out_rec.bl_no
            , out_rec.edn
            , out_rec.product_note;

      EXIT WHEN myCursor%NOTFOUND;
      PIPE ROW (out_rec);
   END LOOP;

   CLOSE myCursor;

   RETURN;
-- return error message into Cargo Doc for assisting DEBUG
EXCEPTION
   WHEN OTHERS   THEN
      v_errm := SUBSTR (SQLERRM, 1, 64);

      OPEN myCursor FOR
         SELECT 'Internal EC System Error "'||v_errm||'"',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL from dual;

      LOOP
         FETCH myCursor
            INTO out_rec.rec_type
               , out_rec.vessel_name
               , out_rec.captain
               , out_rec.arrived_loadport
               , out_rec.sailed_loadport
               , out_rec.ports_of_loading
               , out_rec.ports_of_discharge
               , out_rec.lifting_account_id
               , out_rec.lifting_account_name
               , out_rec.consignor
               , out_rec.consignee
               , out_rec.lc_lifting_no
               , out_rec.bl_no
               , out_rec.edn
               , out_rec.product_note;

         EXIT WHEN myCursor%NOTFOUND;
         PIPE ROW (out_rec);
      END LOOP;

      CLOSE myCursor;

      RETURN;
END cargo_rct_func;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : cargo_parcels_func
-- Description    : return the lifting quantity in different unit of measure for the given Lifting.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : STORAGE_LIFT_NOM_SPLIT, CARGO_ANALYSIS_ITEM
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      : used in sub-report of the following Cargo documents:
--                   1. Bill of Lading
--                   2. Certificate of Quantity
--
-- Modification history:
-- Date          Whom             Change description:
-- ------        --------         --------------------------------------
-- 30-Jul-2014   ucta             Modified cursor to obtain the Gross and Net value for Condensate.
-- 08-Sep-2015   EQYP             W/I 101268. Update to return Grade,  and set volume and mass to 2dp.
-- 28-MAY-2018   wvic             127718 - Modified cargo_parcels_func to add BBLS @ 60 DEG F
-----------------------------------------------------------------------------------------------------

FUNCTION cargo_parcels_func (n_parcel_no NUMBER, v_lifting_account_id VARCHAR2)
   RETURN ue_ct_cargo_vals    PIPELINED
IS
   TYPE ref_cur IS REF CURSOR;

   myCursor  ref_cur;

   out_rec   ue_ct_cargo_vals_rec_type := ue_ct_cargo_vals_rec_type(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

   v_product_type product.object_code%TYPE;
   v_grade   VARCHAR2 (240);
   v_errm    VARCHAR2 (64);
   n_analysis_no NUMBER;

BEGIN
   IF ecbp_cargo_status.getECCargoStatus(ec_cargo_transport.cargo_status(ec_storage_lift_nomination.cargo_no(n_parcel_no))) NOT IN ('A','C')   THEN
      RAISE LOGIN_DENIED;
   END IF;

   --Determine product type
   v_product_type := ec_product.object_code (ec_stor_version.product_id (ec_storage_lift_nomination.object_id (n_parcel_no), ec_storage_lift_nomination.bl_date (n_parcel_no), '<='));

   v_grade := ec_stor_version.text_7 (ec_storage_lift_nomination.object_id (n_parcel_no), ec_storage_lift_nomination.bl_date (n_parcel_no) , '<=');

   SELECT analysis_no
   INTO   n_analysis_no
   FROM   dv_cargo_analysis
   WHERE  cargo_no = ec_storage_lift_nomination.cargo_no (n_parcel_no)
   AND    NVL (official_ind, 'N') = 'Y';

   If v_product_type = 'COND' then
      OPEN myCursor FOR
      SELECT cargo_no
           , parcel_no
           , NAME
           -- Begin 111091
           /*
           , ROUND(gross,2)
           , ROUND(net,2)
           */
           , ROUND(gross,3)
           , ROUND(net,3)
           -- End 111091
           , unit
           , v_grade AS grade
           , v_product_type AS product_code
           , sort_order
      FROM    (SELECT ec_storage_lift_nomination.cargo_no (c.parcel_no)  AS cargo_no
                   , c.parcel_no
                   , 'SM3 @ 15 DEG C' AS NAME
                   -- Begin 111091
                   /*
                   , ROUND(LIFTED_GROSS_VOL,2) AS gross
                   , ROUND(c.lifted_vol,2) AS net
                   */
                   , ROUND(LIFTED_GROSS_VOL,3) AS gross
                   , ROUND(c.lifted_vol,3) AS net
                   -- End 111091
                   , ec_ctrl_unit.label (c.lifted_vol_uom) AS unit
                   , 1 AS sort_order
              FROM   dv_ct_msg_cargo c
                     join dv_storage_lifting l on (l.parcel_no = c.parcel_no)
                     join dv_prod_meas_setup m on (m.product_meas_no = l.product_meas_no and
                                                   m.meas_item = 'LIFT_COND_VOL_GRS')
              WHERE  c.parcel_no = n_parcel_no
              AND    c.lifting_account_id =  NVL (v_lifting_account_id, c.lifting_account_id)
              -- Item 127718 Begin
              UNION ALL
              SELECT ec_storage_lift_nomination.cargo_no (c.parcel_no)  AS cargo_no
                   , c.parcel_no
                   , 'U.S. BARRELS @ 60 DEG F' AS NAME
                   , ROUND(l1.load_value,2) AS gross
                   , ROUND(l2.load_value,2) AS net
                   , l1.unit AS unit
                   , 2 AS sort_order
              FROM   dv_ct_msg_cargo c
                     join dv_storage_lifting l1 on (l1.parcel_no = c.parcel_no)
                     join dv_prod_meas_setup m1 on (m1.product_meas_no = l1.product_meas_no and
                                                    m1.meas_item = 'LIFT_COND_BBLS_GRS')
                     join dv_storage_lifting l2 on (l2.parcel_no = c.parcel_no)
                     join dv_prod_meas_setup m2 on (m2.product_meas_no = l2.product_meas_no and
                                                    m2.meas_item = 'LIFT_COND_BBLS_NET')
              WHERE  c.parcel_no = n_parcel_no
              AND    c.lifting_account_id =  NVL (v_lifting_account_id, c.lifting_account_id)
              -- Item 127718 End
              UNION ALL
              SELECT ec_storage_lift_nomination.cargo_no (c.parcel_no)  AS cargo_no
                   , c.parcel_no
                   , 'METRIC TONS IN AIR' AS NAME
                   -- Begin 111091
                   /*
                   , round(LIFTED_COND_GROSS_MASS,2) AS gross
                   , round(c.lifted_mass,2) AS net
                   */
                   , round(LIFTED_COND_GROSS_MASS,3) AS gross
                   , round(c.lifted_mass,3) AS net
                   -- End 111091
                   , ec_ctrl_unit.label (c.lifted_mass_uom) AS unit
                   -- Item 127718 Begin
                   --, 2 AS sort_order
                   , 3 AS sort_order
                   -- Item 127718 End
              FROM   dv_ct_msg_cargo c -- EQYP updatd from dv_ct_msg_cargo_split c
                     join dv_storage_lifting l on (l.parcel_no = c.parcel_no)
                     join dv_prod_meas_setup m on (m.product_meas_no = l.product_meas_no and
                                                   m.meas_item = 'LIFT_COND_MASS_AIR_GRS')
              WHERE  c.parcel_no = n_parcel_no
              AND    c.lifting_account_id =   NVL (v_lifting_account_id, c.lifting_account_id)
            )
      ORDER BY parcel_no, sort_order;

   Else -- 'LNG'
      OPEN myCursor FOR
      SELECT cargo_no
           , parcel_no
           , NAME
           , gross     -- LNG volume are actually Net value.  However, it is returned as Gross because of the report displays the Gross value.
           , net
           , unit
           , v_grade AS grade
           , v_product_type AS product_code
           , sort_order
      FROM     (SELECT ec_storage_lift_nomination.cargo_no (parcel_no)  AS cargo_no
                   , parcel_no
                   , 'QUANTITY LOADED' AS NAME
                   , ROUND(lifted_vol,3) AS gross
                   , TO_NUMBER(NULL) AS net
                   , ec_ctrl_unit.label (lifted_vol_uom) AS unit
                   , 1 AS sort_order
              FROM   dv_ct_msg_cargo --EQYP updated from dv_ct_msg_cargo_split
              WHERE  parcel_no = n_parcel_no
              AND    lifting_account_id =  NVL (v_lifting_account_id, lifting_account_id)
              UNION ALL
              SELECT ec_storage_lift_nomination.cargo_no (parcel_no)  AS cargo_no
                   , parcel_no
                   , 'QUANTITY LOADED' AS NAME
                   , ROUND(lifted_mass,2) as gross
                   , TO_NUMBER(NULL) AS net
                   , ec_ctrl_unit.label (lifted_mass_uom) AS unit
                   , 2 AS sort_order
              FROM   dv_ct_msg_cargo -- Upddated from dv_ct_msg_cargo_split
              WHERE  parcel_no = n_parcel_no
              AND    lifting_account_id =   NVL (v_lifting_account_id, lifting_account_id)
              UNION ALL
              SELECT ec_storage_lift_nomination.cargo_no (parcel_no)   AS cargo_no
                   , parcel_no
                   , 'QUANTITY LOADED' AS NAME
                   , ROUND(lifted_energy,0)
                   , TO_NUMBER(NULL) AS net
                   , ec_ctrl_unit.label (lifted_energy_uom) AS unit
                   , 3 AS sort_order
              FROM   dv_ct_msg_cargo --Updated from dv_ct_msg_cargo_split
              WHERE  parcel_no = n_parcel_no
              AND    lifting_account_id =  NVL (v_lifting_account_id, lifting_account_id)
              -- Begin
              /*
              UNION ALL
              SELECT ec_storage_lift_nomination.cargo_no (n_parcel_no)   AS cargo_no
                   , n_parcel_no
                   , 'GROSS HEATING VALUE' AS NAME
                   , ROUND(analysis_value,3) AS gross
                   , TO_NUMBER(NULL) AS net
                   , unit
                   , 4 AS sort_order
              FROM   dv_cargo_analysis_basic
              WHERE  analysis_no = n_analysis_no
              AND    analysis_item_code = 'VOLUME_GHV'
              */
              -- End
              )
      ORDER BY parcel_no, sort_order;
   End if;

   LOOP
      FETCH myCursor
         INTO out_rec.cargo_no
            , out_rec.parcel_no
            , out_rec.name
            , out_rec.gross
            , out_rec.net
            , out_rec.unit
            , out_rec.grade
            , out_rec.product_code
            , out_rec.sort_order;

      EXIT WHEN myCursor%NOTFOUND;
      PIPE ROW (out_rec);
   END LOOP;

   CLOSE myCursor;

   RETURN;
-- return error message into Cargo Doc for assisting DEBUG
EXCEPTION
   WHEN OTHERS   THEN
      v_errm := SUBSTR (SQLERRM, 1, 64);

      OPEN myCursor FOR SELECT NULL,NULL,'Internal EC System Error "'||v_errm||'"',NULL,NULL,NULL,NULL,NULL,NULL from dual;

      LOOP
         FETCH myCursor
            INTO out_rec.cargo_no
               , out_rec.parcel_no
               , out_rec.name
               , out_rec.gross
               , out_rec.net
               , out_rec.unit
               , out_rec.grade
               , out_rec.product_code
               , out_rec.sort_order;

         EXIT WHEN myCursor%NOTFOUND;
         PIPE ROW (out_rec);
      END LOOP;

      CLOSE myCursor;

      RETURN;
END cargo_parcels_func;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : cargo_all_parcels_func
-- Description    : return the lifting quantity in different unit of measure for all Lifting accounts.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : STORAGE_LIFT_NOM_SPLIT, CARGO_ANALYSIS_ITEM
--
-- Using functions: UE_CT_CARGO_DOCS.CARGO_PARCELS_FUNC
--
--
-- Configuration
-- required       :
--
-- Behaviour      : used in sub-report of the following Cargo document: Cargo Manifest
--
-----------------------------------------------------------------------------------------------------
FUNCTION cargo_all_parcels_func (n_parcel_no NUMBER
                               , v_lifting_account_id VARCHAR2)
   RETURN ue_ct_cargo_vals   PIPELINED
IS
   TYPE ref_cur IS REF CURSOR;

   myCursor  ref_cur;

   out_rec   ue_ct_cargo_vals_rec_type := ue_ct_cargo_vals_rec_type(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

   TYPE all_parcels_type IS VARRAY (100) OF NUMBER;

   all_parcels all_parcels_type;

   n_cargo_no storage_lift_nomination.cargo_no%TYPE;
   v_errm    VARCHAR2 (64);
BEGIN
   IF ecbp_cargo_status.getECCargoStatus (ec_cargo_transport.cargo_status (ec_storage_lift_nomination.cargo_no (n_parcel_no))) NOT IN ('A', 'C')   THEN
      RAISE LOGIN_DENIED;
   END IF;
/*
   n_cargo_no := ec_storage_lift_nomination.cargo_no (n_parcel_no);

   SELECT parcel_no   BULK   COLLECT INTO all_parcels        --get all parcel_no # for the cargo_no
   FROM   dv_storage_lift_nom_blmr
   --WHERE  ec_storage_lift_nomination.cargo_no (parcel_no) = n_cargo_no;
   WHERE  parcel_no = n_parcel_no;


   FOR indx IN 1 .. all_parcels.COUNT                 --Loop through all parcels
   LOOP
      OPEN myCursor FOR
         SELECT   *  FROM  TABLE (  ue_ct_cargo_docs.cargo_parcels_func (all_parcels (indx), v_lifting_account_id))
         ORDER BY sort_order;

      LOOP
         FETCH myCursor
            INTO                                --insert each parcel into cursor
                out_rec.cargo_no
               , out_rec.parcel_no
               , out_rec.name
               , out_rec.gross
               , out_rec.net
               , out_rec.unit
               , out_rec.grade
               , out_rec.product_code
               , out_rec.sort_order;

         EXIT WHEN myCursor%NOTFOUND;
         PIPE ROW (out_rec);
      END LOOP;
   END LOOP;

   CLOSE myCursor;

*/

   --FOR indx IN 1 .. all_parcels.COUNT                 --Loop through all parcels
   --LOOP
      OPEN myCursor FOR
         SELECT   *  FROM  TABLE (  ue_ct_cargo_docs.cargo_parcels_func (n_parcel_no, v_lifting_account_id))
         ORDER BY sort_order;

      LOOP
         FETCH myCursor
            INTO                                --insert each parcel into cursor
                out_rec.cargo_no
               , out_rec.parcel_no
               , out_rec.name
               , out_rec.gross
               , out_rec.net
               , out_rec.unit
               , out_rec.grade
               , out_rec.product_code
               , out_rec.sort_order;

         EXIT WHEN myCursor%NOTFOUND;
         PIPE ROW (out_rec);
      END LOOP;
   --END LOOP;

   CLOSE myCursor;


   RETURN;
-- return error message into Cargo Doc for assisting DEBUG
EXCEPTION
   WHEN OTHERS   THEN
      v_errm := SUBSTR (SQLERRM, 1, 64);

      OPEN myCursor FOR
         SELECT NULL,NULL,'Internal EC System Error "'||v_errm||'"',NULL,NULL,NULL,NULL,NULL,NULL from dual;

      LOOP
         FETCH myCursor
            INTO out_rec.cargo_no
               , out_rec.parcel_no
               , out_rec.name
               , out_rec.gross
               , out_rec.net
               , out_rec.unit
               , out_rec.grade
               , out_rec.product_code
               , out_rec.sort_order;

         EXIT WHEN myCursor%NOTFOUND;
         PIPE ROW (out_rec);
      END LOOP;

      CLOSE myCursor;

      RETURN;
END cargo_all_parcels_func;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       :cargo_sum_parcels_func
-- Description    : return the total lifting quantity in different unit of measure for all Lifting accounts.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : STORAGE_LIFT_NOM_SPLIT, CARGO_ANALYSIS_ITEM
--
-- Using functions: UE_CT_CARGO_DOCS.CARGO_ALL_PARCELS_FUNC
--
--
-- Configuration
-- required       :
--
-- Behaviour      : used in sub-report of the following Cargo document: Certificate Of Origin
--
-----------------------------------------------------------------------------------------------------
FUNCTION cargo_sum_parcels_func (n_parcel_no NUMBER, v_lifting_account_id  VARCHAR2)
      RETURN ue_ct_cargo_vals      PIPELINED

IS
    TYPE ref_cur IS REF CURSOR;
    myCursor ref_cur;

    out_rec ue_ct_cargo_vals_rec_type  := ue_ct_cargo_vals_rec_type(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
    v_errm  VARCHAR2(64);

BEGIN
   IF ecbp_cargo_status.getECCargoStatus (ec_cargo_transport.cargo_status (ec_storage_lift_nomination.cargo_no (n_parcel_no))) NOT IN ('A', 'C')   THEN
      RAISE LOGIN_DENIED;
   END IF;

   OPEN myCursor FOR
      SELECT   cargo_no
             , n_parcel_no
             , name
             -- Begin
             /*
             , SUM (gross) AS gross
             , SUM (net) AS net
             */
             -- Item 127719 Begin
             --, CASE WHEN (unit = ec_ctrl_unit.label('M3') OR product_code = 'COND') THEN
             , CASE WHEN (unit = ec_ctrl_unit.label('M3') OR (product_code = 'COND' and unit <> ec_ctrl_unit.label('BBL'))) THEN
             -- Item 127719 End
                    TO_CHAR(SUM (gross), 'FM9,999,999.990')
             -- Item 132627 Added trailing zero for Cond-BBL and LNG-tonnes
               WHEN (product_code = 'COND' and unit = ec_ctrl_unit.label('BBL')) OR (product_code = 'LNG' and unit = ec_ctrl_unit.label('TONNES')) THEN
                    TO_CHAR(SUM (gross), 'FM9,999,999.00')
             -- Item 132627 End                   
                    ELSE TRIM(TRAILING '.' FROM TO_CHAR(SUM (gross), 'FM9,999,999.999'))
                END
                     AS gross
             -- Item 127719 Begin
             --, CASE WHEN (unit = ec_ctrl_unit.label('M3') OR product_code = 'COND') THEN
             , CASE WHEN (unit = ec_ctrl_unit.label('M3') OR (product_code = 'COND' and unit <> ec_ctrl_unit.label('BBL'))) THEN
             -- Item 127719 End
                    TO_CHAR(SUM (net), 'FM9,999,999.990')
             --Item 132627 Added trailing zero for Cond-BBL
               WHEN (product_code = 'COND' and unit = ec_ctrl_unit.label('BBL')) THEN
                    TO_CHAR(SUM (net), 'FM9,999,999.00')               
                    ELSE TRIM(TRAILING '.' FROM TO_CHAR(SUM (net), 'FM9,999,999.999'))
                END AS net
             -- End
             , unit
             , grade
             , product_code
             , sort_order
      FROM TABLE (ue_ct_cargo_docs.cargo_all_parcels_func (n_parcel_no, v_lifting_account_id))
      GROUP BY cargo_no
             , name
             , unit
             , grade
             , product_code
             , sort_order
      ORDER BY sort_order;

   LOOP
      FETCH myCursor
         INTO                                   --insert each parcel into cursor
             out_rec.cargo_no
            , out_rec.parcel_no
            , out_rec.name
            , out_rec.gross
            , out_rec.net
            , out_rec.unit
            , out_rec.grade
            , out_rec.product_code
            , out_rec.sort_order;

      EXIT WHEN myCursor%NOTFOUND;
      PIPE ROW (out_rec);
   END LOOP;

   CLOSE myCursor;

   RETURN;
-- return error message into Cargo Doc for assisting DEBUG
EXCEPTION
   WHEN OTHERS   THEN
      v_errm := SUBSTR (SQLERRM, 1, 64);

      OPEN myCursor FOR SELECT NULL,NULL,'Internal EC System Error "'||v_errm||'"',NULL,NULL,NULL,NULL,NULL,NULL from dual;

      LOOP
         FETCH myCursor
            INTO out_rec.cargo_no
               , out_rec.parcel_no
               , out_rec.name
               , out_rec.gross
               , out_rec.net
               , out_rec.unit
               , out_rec.grade
               , out_rec.product_code
               , out_rec.sort_order;

         EXIT WHEN myCursor%NOTFOUND;
         PIPE ROW (out_rec);
      END LOOP;

      CLOSE myCursor;

      RETURN;
END cargo_sum_parcels_func;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : cargo_bol_func
-- Description    : return the lifting details.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : LIFT_DOC_INSTRUCTION, STORAGE_LIFT_NOMINATION, CARGO_TRANSPORT,
--                  STORAGE_LIFT_NOM_SPLIT
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : used in the main report section of the following Cargo Documents:
--                   1. Bill of Lading
--                   2. Certificate of Origin
--
-----------------------------------------------------------------------------------------------------
FUNCTION cargo_bol_func (v_original VARCHAR2,n_parcel_no NUMBER, p_document_code VARCHAR2 DEFAULT NULL)
      RETURN ue_ct_cargo_bol       PIPELINED

IS
    TYPE ref_cur IS REF CURSOR;
    myCursor ref_cur;
    -- Begin
    /*
    out_rec ue_ct_cargo_bol_rec_type  := ue_ct_cargo_bol_rec_type(NULL,NULL,NULL,NULL
                        ,NULL,NULL,NULL,NULL
                        ,NULL,NULL,NULL,NULL
                        ,NULL,NULL,NULL,NULL
                        ,NULL,NULL,NULL,NULL);
    */
    out_rec ue_ct_cargo_bol_rec_type  := ue_ct_cargo_bol_rec_type(NULL,NULL,NULL,NULL
                        ,NULL,NULL,NULL,NULL
                        ,NULL,NULL,NULL,NULL
                        ,NULL,NULL,NULL,NULL
                        ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);   --Item 132627: Added cargo no 
    -- End

	-- Item 125161 Begin
    CURSOR c_num_bol_copies (cp_doc_code VARCHAR2, cp_parcel_no NUMBER)
    IS
       SELECT ec_prosty_codes.alt_code(original, 'CARGO_DOC_ORIGINAL') AS no_bl
       FROM   tv_lift_doc_instruction
       WHERE  doc_code = cp_doc_code
       AND    parcel_no = cp_parcel_no
       AND    original IS NOT NULL;
	-- Item 125161 End

    cargo_doc prosty_codes.code_text%TYPE;
    no_bl   NUMBER;
    v_errm  VARCHAR2(64);
    v_product_type VARCHAR2(32);
    v_doc_code     VARCHAR2(32);
    lv_company_code VARCHAR(32);

   -- Begin
   arrived_loadport VARCHAR2 (240);
   sailed_loadport VARCHAR2 (240);
   v_bol_date VARCHAR2(4000);
   product_note VARCHAR2 (240);
   -- End
   n_cargo_no storage_lift_nomination.cargo_no%TYPE;  --Item 132627

BEGIN
   IF ecbp_cargo_status.getECCargoStatus (ec_cargo_transport.cargo_status (ec_storage_lift_nomination.cargo_no (n_parcel_no))) NOT IN ('A', 'C')   THEN
      RAISE LOGIN_DENIED;
   END IF;

   n_cargo_no := ec_storage_lift_nomination.cargo_no (n_parcel_no);  --Item 132627

   --Determine lifting company code
   lv_company_code :=  ECDP_OBJECTS.GETOBJCODE(EC_LIFTING_ACCOUNT.COMPANY_ID(ec_storage_lift_nomination.lifting_account_id (n_parcel_no)));

   --Determine product type
   v_product_type := ec_product.object_code ( ec_stor_version.product_id (
                                        ec_storage_lift_nomination.object_id (n_parcel_no)
                                      , ec_storage_lift_nomination.bl_date (n_parcel_no)
                                      , '<='));

   --Determine if Document 'Original' or 'Copy'
   CASE v_original
      WHEN 'Y'      THEN
         cargo_doc := 'Original';
      WHEN 'N'      THEN
         -- Begin
         IF p_document_code = 'BOL' THEN
            cargo_doc := 'Copy - Non Negotiable';
         ELSE
         -- End
            cargo_doc := 'Copy';
         END IF;
      ELSE
         cargo_doc := ec_prosty_codes.code_text (v_original, 'CARGO_DOC_ORIGINAL'); --used for BOL doc
   END CASE;

   CASE
      WHEN v_product_type = 'LNG'      THEN
         v_doc_code := 'BOL_LNG';
         -- Begin
         arrived_loadport :=  TO_CHAR (ec_lifting_activity.from_daytime (ec_storage_lift_nomination.cargo_no (n_parcel_no), 'LNG_PILOT_STATION', 1,'LOAD'), 'dd-Mon-yyyy HH24:MI');
         sailed_loadport := TO_CHAR (ec_lifting_activity.from_daytime (ec_storage_lift_nomination.cargo_no (n_parcel_no), 'LNG_SHIP_DEPARTS', 1,'LOAD'), 'dd-Mon-yyyy HH24:MI');
         v_bol_date := TO_CHAR (ec_lifting_activity.from_daytime (ec_storage_lift_nomination.cargo_no (n_parcel_no), 'LNG_MANIFOLD_CLOSE', 1,'LOAD'), 'DD/MON/YYYY');
         product_note := 'LIQUEFIED NATURAL GAS (LNG)';
         -- End
      WHEN v_product_type = 'COND'      THEN
         v_doc_code := 'BOL_COND';
         -- Begin
         arrived_loadport := TO_CHAR (ec_lifting_activity.from_daytime (ec_storage_lift_nomination.cargo_no (n_parcel_no), 'COND_PILOT_STATION', 1,'LOAD'), 'dd-Mon-yyyy HH24:MI');
         sailed_loadport := TO_CHAR (ec_lifting_activity.from_daytime (ec_storage_lift_nomination.cargo_no (n_parcel_no), 'COND_SHIP_DEPARTS', 1,'LOAD'), 'dd-Mon-yyyy HH24:MI');
         v_bol_date := TO_CHAR (ec_lifting_activity.from_daytime (ec_storage_lift_nomination.cargo_no (n_parcel_no), 'COND_MANIFOLD_CLOSE', 1,'LOAD'), 'DD/MON/YYYY');
         product_note := 'WHEATSTONE CONDENSATE';
         -- End
   END CASE;

   --Calculate 'No of Bill Of lading'
   -- Begin
   /*
   SELECT COUNT (original)
   */
   /* Item 125161 Begin
   SELECT ec_prosty_codes.alt_code(original, 'CARGO_DOC_ORIGINAL')
   -- End
   INTO   no_bl
   FROM   tv_lift_doc_instruction
   WHERE  doc_code = v_doc_code
   AND    parcel_no = n_parcel_no
   AND    original IS NOT NULL;
   */

   FOR cur_no_bl IN c_num_bol_copies (v_doc_code, n_parcel_no)
   LOOP
      no_bl := cur_no_bl.no_bl;
   END LOOP;
   -- Item 125161 End

   OPEN myCursor FOR
      SELECT cargo_doc AS cargo_doc_ttl
           , lifting_account_id         --ensure you are using lifting_account_id from split
           , lifting_account_name
           , bl_number AS bl_no
           , TO_CHAR (  EC_STORAGE_LIFT_NOMINATION.BL_DATE(n_parcel_no) , 'dd-Mon-yyyy') AS bl_date
           , consignor
           , reference_lifting_no AS lc_lifting_number --EQYP updated from olc_lifting_number
           , CONSIGNEE AS CONSIGNEE_NAME
           , notify_party
           , EC_CARRIER_VERSION.NAME(EC_CARGO_TRANSPORT.CARRIER_ID(CARGO_NO), EC_STORAGE_LIFT_NOMINATION.BL_DATE(n_parcel_no),'=<')
           , TO_CHAR (charter_date, 'dd-Mon-yyyy') AS charterparty
           , edn
           , local_port_name AS local_port
           , remote_port_name AS discharge_Port
           , scac_uic
           , decode(v_product_type,'COND','CONDENSATE',v_product_type) AS freight
           , no_bl                                   --this is variable
           , MASTER
           , ec_cargo_transport.text_18 (cargo_no) AS carrier_name
           , agent
           -- Begin
           , v_bol_date AS bol_date
           , arrived_loadport
           , sailed_loadport
           , bol_comments
           , product_note
           -- End
		   , n_cargo_no AS cargo_no   --Item 132627
      FROM   dv_ct_msg_cargo
          --   INNER JOIN  dv_ct_msg_cargo_detail mcd ON msh.parcel_no = mcd.parcel_no -- EQYP updated from dv_ct_msg_cargo_split mcs  ON msh.parcel_no = mcs.parcel_no
      WHERE  parcel_no = n_parcel_no;

   LOOP
      FETCH myCursor
         INTO out_rec.cargo_doc_ttl
            , out_rec.lifting_account_id
            , out_rec.lifting_account_name
            , out_rec.bl_no
            , out_rec.bl_date
            , out_rec.consignor_name
            , out_rec.lc_lifting_number
            , out_rec.consignee_name
            , out_rec.notify_party
            , out_rec.vessel_name
            , out_rec.charterparty
            , out_rec.edn
            , out_rec.local_port
            , out_rec.discharge_Port
            , out_rec.scac_uic
            , out_rec.freight
            , out_rec.no_bol
            , out_rec.master
            , out_rec.carrier_name
            , out_rec.agent
            -- Begin
            , out_rec.bol_date
            , out_rec.arrived_loadport
            , out_rec.sailed_loadport
            , out_rec.bol_comments
            , out_rec.product_note
            -- End
			, out_rec.cargo_no;  --Item 132627

      EXIT WHEN myCursor%NOTFOUND;
      PIPE ROW (out_rec);
   END LOOP;

   CLOSE myCursor;

   RETURN;
-- return error message into Cargo Doc for assisting DEBUG
EXCEPTION
   WHEN OTHERS   THEN
      v_errm := SUBSTR (SQLERRM, 1, 64);

      OPEN myCursor FOR
         SELECT 'Internal EC System Error ' || v_errm , NULL
              , NULL, NULL, NULL, NULL, NULL, NULL, NULL
              , NULL, NULL, NULL, NULL, NULL, NULL, NULL
              , NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL  --Item 132627: Added cargo no 
              -- End
         FROM   DUAL;

      LOOP
         FETCH myCursor
            INTO out_rec.cargo_doc_ttl
               , out_rec.lifting_account_id
               , out_rec.lifting_account_name
               , out_rec.bl_no
               , out_rec.bl_date
               , out_rec.consignor_name
               , out_rec.lc_lifting_number
               , out_rec.consignee_name
               , out_rec.notify_party
               , out_rec.vessel_name
               , out_rec.charterparty
               , out_rec.edn
               , out_rec.local_port
               , out_rec.discharge_Port
               , out_rec.scac_uic
               , out_rec.freight
               , out_rec.no_bol
               , out_rec.master
               , out_rec.carrier_name
               , out_rec.agent
               -- Begin
               , out_rec.bol_date
               , out_rec.arrived_loadport
               , out_rec.sailed_loadport
               , out_rec.bol_comments
               , out_rec.product_note
               -- End
               , out_rec.cargo_no;   --Item 132627

         EXIT WHEN myCursor%NOTFOUND;
         PIPE ROW (out_rec);
      END LOOP;

      CLOSE myCursor;

      RETURN;
END cargo_bol_func;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       :cargo_rct_docs_func
-- Description    : return the list of documents for Receipting.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : STORAGE_LIFTING, LIFT_DOC_INSTRUCTION, CARGO_DOC_TEMPLATE_LIST
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      : Use in sub-report of Cargo Document: Reciept For Documents
--
-----------------------------------------------------------------------------------------------------
FUNCTION cargo_rct_docs_func (n_parcel_no NUMBER)
      RETURN ue_ct_cargo_rct_docs      PIPELINED

IS
    TYPE ref_cur IS REF CURSOR;
    myCursor ref_cur;

    out_rec ue_ct_cargo_rct_docs_rec_type  := ue_ct_cargo_rct_docs_rec_type(NULL,NULL,NULL,NULL,NULL,NULL);

    v_code cargo_doc_template_list.code%TYPE;
    v_product_type product.object_code%TYPE;
    v_errm  VARCHAR2(64);

BEGIN
   IF ecbp_cargo_status.getECCargoStatus ( ec_cargo_transport.cargo_status ( ec_storage_lift_nomination.cargo_no (n_parcel_no))) NOT IN    ('A', 'C')   THEN
      RAISE LOGIN_DENIED;
   END IF;

   --Determine product type
   SELECT DISTINCT ec_product.object_code (ec_product_meas_setup.object_id (sl.product_meas_no))
   INTO   v_product_type
   FROM   dv_storage_lifting sl
   WHERE  parcel_no = n_parcel_no;

   CASE v_product_type
      WHEN 'COND'      THEN
         v_code := 'COND_TEMPLATE';
      WHEN 'LNG'      THEN
         v_code := 'LNG_TEMPLATE';
   END CASE;


   OPEN myCursor FOR
      SELECT code AS code
           , cargo_documents AS cargo_documents
           , NVL (originals, 0) AS originals
           , NVL (copies, 0) AS copies
           , NVL (master_copies, 0) AS master_copies
           , NVL (consignee_copies, 0) AS consignee_copies
      FROM   (SELECT   code
                     , ec_prosty_codes.code_text (doc_code, 'CARGO_DOCUMENT')  AS cargo_documents
                     , (SELECT SUM (
                                  CASE original
                                     WHEN 'Y'  THEN  1
                                     WHEN 'N'  THEN  0
                                     ELSE
                                        (CASE WHEN REGEXP_LIKE (ec_prosty_codes.alt_code (original, 'CARGO_DOC_ORIGINAL'), '^[0-9]+$') THEN--checking alt_code is a Number ..else null
                                          TO_NUMBER (ec_prosty_codes.alt_code (original, 'CARGO_DOC_ORIGINAL'))
                                         END)
                                  END)
                        FROM   tv_lift_doc_instruction
                        WHERE  parcel_no = n_parcel_no
                        AND    doc_code = cdtl.doc_code
                        AND    ec_company_contact.object_code ( company_contact_id) NOT IN ('CC_MASTER_RECEIVER', 'CC_CONSIGNEE_RECEIVER')) AS originals
                     , (SELECT SUM (copies)
                        FROM   tv_lift_doc_instruction
                        WHERE  parcel_no = n_parcel_no
                        AND    doc_code = cdtl.doc_code
                        AND    ec_company_contact.object_code ( company_contact_id) NOT IN ('CC_MASTER_RECEIVER', 'CC_CONSIGNEE_RECEIVER')) AS copies   --sum of copies = total copies
                     , (SELECT SUM (copies)
                        FROM   tv_lift_doc_instruction
                        WHERE  parcel_no = n_parcel_no
                        AND    doc_code = cdtl.doc_code
                        AND    ec_company_contact.object_code (company_contact_id) = 'CC_MASTER_RECEIVER')     AS master_copies
                     , (SELECT SUM (copies)
                        FROM   tv_lift_doc_instruction
                        WHERE  parcel_no = n_parcel_no
                        AND    doc_code = cdtl.doc_code
                        AND    ec_company_contact.object_code (company_contact_id) = 'CC_CONSIGNEE_RECEIVER')  AS consignee_copies
              FROM     tv_cargo_doc_template_list cdtl
              WHERE    code = v_code
              ORDER BY sort_order);

   LOOP
      FETCH myCursor
         INTO                                   --insert each parcel into cursor
             out_rec.code
            , out_rec.cargo_documents
            , out_rec.originals
            , out_rec.copies
            , out_rec.master_copies
            , out_rec.consignee_copies;

      EXIT WHEN myCursor%NOTFOUND;
      PIPE ROW (out_rec);
   END LOOP;

   CLOSE myCursor;

   RETURN;
-- return error message into Cargo Doc for assisting DEBUG
EXCEPTION
   WHEN OTHERS   THEN
      v_errm := SUBSTR (SQLERRM, 1, 64);

      OPEN myCursor FOR
         SELECT NULL, 'Internal EC System Error "' || v_errm || '"', NULL, NULL, NULL, NULL FROM   DUAL;

      LOOP
         FETCH myCursor
            INTO out_rec.code
               , out_rec.cargo_documents
               , out_rec.originals
               , out_rec.copies
               , out_rec.master_copies
               , out_rec.consignee_copies;

         EXIT WHEN myCursor%NOTFOUND;
         PIPE ROW (out_rec);
      END LOOP;

      CLOSE myCursor;

      RETURN;
END cargo_rct_docs_func;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       :cargo_rct_smpl_func
-- Description    : return the cargo analysis details for a given cargo.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CARGO_ANALYSIS
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      : use in sub-report of Cargo Document: Reciept For Samples
--
-- Modification history:
-- Date          Whom             Change description:
-- ------        --------         --------------------------------------
-- 31-Jul-2014   ucta             Added Cylinder_ID column.
-----------------------------------------------------------------------------------------------------
FUNCTION cargo_rct_smpl_func (n_parcel_no NUMBER)
      RETURN ue_ct_cargo_rct_smpl      PIPELINED

IS
    TYPE ref_cur IS REF CURSOR;
    myCursor ref_cur;

    out_rec ue_ct_cargo_rct_smpl_rec_type  := ue_ct_cargo_rct_smpl_rec_type(NULL,NULL,NULL,NULL,NULL,NULL,NULL);
    v_errm  VARCHAR2(64);

BEGIN

-- Begin
/*
   IF ecbp_cargo_status.getECCargoStatus (ec_cargo_transport.cargo_status (ec_storage_lift_nomination.cargo_no (n_parcel_no))) NOT IN ('A', 'C')  THEN
      RAISE LOGIN_DENIED;
   END IF;
*/
-- End

   OPEN myCursor FOR
      SELECT cargo_no AS code
           , sample_id AS no_and_size_of_smpl
           , grade AS grade
           , sample_source AS smpl_source
           , cylinder_id
           , seal_no AS seal_no
           , comments AS remarks
      FROM   dv_ct_msg_cargo_analysis
      WHERE  NVL (is_official, 'N') = 'N'
      AND    analysis_type = 'DIST_SAMPLE'
      AND    cargo_no = ec_storage_lift_nomination.cargo_no (n_parcel_no);

   LOOP
      FETCH myCursor
         INTO                                   --insert each parcel into cursor
             out_rec.code
            , out_rec.no_and_size_of_smpl
            , out_rec.grade
            , out_rec.smpl_source
            , out_rec.cylinder_id
            , out_rec.seal_no
            , out_rec.remarks;

      EXIT WHEN myCursor%NOTFOUND;
      PIPE ROW (out_rec);
   END LOOP;

   CLOSE myCursor;

   RETURN;
-- return error message into Cargo Doc for assisting DEBUG
EXCEPTION
   WHEN OTHERS   THEN
      v_errm := SUBSTR (SQLERRM, 1, 64);

      OPEN myCursor FOR
         SELECT NULL, NULL , 'Internal EC System Error "' || v_errm || '"', NULL, NULL, NULL, NULL FROM   DUAL;

      LOOP
         FETCH myCursor
            INTO out_rec.code
               , out_rec.no_and_size_of_smpl
               , out_rec.grade
               , out_rec.smpl_source
               , out_rec.cylinder_id
               , out_rec.seal_no
               , out_rec.remarks;

         EXIT WHEN myCursor%NOTFOUND;
         PIPE ROW (out_rec);
      END LOOP;

      CLOSE myCursor;

      RETURN;
END cargo_rct_smpl_func;


FUNCTION cargo_auth_neg (n_parcel_no NUMBER) RETURN ue_ct_cargo_auth_neg PIPELINED
IS
   TYPE ref_cur IS REF CURSOR;
   myCursor ref_cur;
   n_cargo_no NUMBER;
   out_rec ue_ct_cargo_auth_neg_rec_type  := ue_ct_cargo_auth_neg_rec_type(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

   -- Begin
    CURSOR c_dischargePorts(cp_cargo_no NUMBER)
    IS
       SELECT cargo_no,
              LISTAGG(text_16,' / ') WITHIN GROUP (ORDER BY text_16) AS discharge_ports
         FROM (SELECT DISTINCT cargo_no, text_16
                 FROM storage_lift_nomination
                WHERE cargo_no = cp_cargo_no
              )
        GROUP BY cargo_no;

    lv_discharge_port VARCHAR2(4000);
   -- End

BEGIN

  SELECT MAX(cargo_no) INTO n_cargo_no FROM DV_STORAGE_LIFT_NOM_BLMR WHERE parcel_no = n_parcel_no;

  -- Begin
   FOR curDP IN c_dischargePorts(n_cargo_no) LOOP
    lv_discharge_port := curDP.discharge_ports;
   END LOOP;
  -- End

   OPEN myCursor FOR
     SELECT
       EC_CARRIER_VERSION.NAME(EC_CARGO_TRANSPORT.CARRIER_ID(n_cargo_no), COALESCE(EC_STORAGE_LIFT_NOMINATION.BL_DATE(n_parcel_no), DAYTIME),'=<') AS vessel,
       -- Begin
       /*
       EC_STORAGE_LIFT_NOMINATION.TEXT_16(n_parcel_no) AS discharge_port,
      */
       lv_discharge_port as discharge_port,
       -- End
       ec_stor_version.text_7 (ec_storage_lift_nomination.object_id (n_parcel_no), COALESCE(ec_storage_lift_nomination.bl_date (n_parcel_no), DAYTIME) , '<=') AS grade,
       EC_CARGO_TRANSPORT.MASTER(n_cargo_no),
       ec_representative.name('CARGO_AGENT', EC_CARGO_TRANSPORT.AGENT(n_cargo_no)) AS agent, --WI 106511 changed to dislay the name instead of the code
       EC_PORT_VERSION.NAME(EC_PORT.OBJECT_ID_BY_UK('PORT_ASH'), SYSDATE, '<=') AS local_port,
       -- Begin
       /*
       DECODE(ecdp_objects.getobjcode(object_id),'STW_COND',EC_STORAGE_LIFTING.LOAD_VALUE(n_parcel_no, (SELECT PRODUCT_MEAS_NO FROM DV_PROD_MEAS_SETUP WHERE LIFTING_EVENT = 'LOAD' AND MEAS_ITEM = 'LIFT_TOT_COND_VOL_NET')),EC_STORAGE_LIFTING.LOAD_VALUE(PARCEL_NO, (SELECT PRODUCT_MEAS_NO FROM DV_PROD_MEAS_SETUP WHERE LIFTING_EVENT = 'LOAD' AND MEAS_ITEM = 'LIFT_TOT_LNG_VOL_NET'))) AS lifted_vol,
       */
       TO_CHAR(DECODE(ecdp_objects.getobjcode(object_id),'STW_COND',EC_STORAGE_LIFTING.LOAD_VALUE(n_parcel_no, (SELECT PRODUCT_MEAS_NO FROM DV_PROD_MEAS_SETUP WHERE LIFTING_EVENT = 'LOAD' AND MEAS_ITEM = 'LIFT_TOT_COND_VOL_GRS')),EC_STORAGE_LIFTING.LOAD_VALUE(PARCEL_NO, (SELECT PRODUCT_MEAS_NO FROM DV_PROD_MEAS_SETUP WHERE LIFTING_EVENT = 'LOAD' AND MEAS_ITEM = 'LIFT_TOT_LNG_VOL_NET'))), '999,999.999') AS lifted_vol,
       -- End
       ecdp_unit.GetUnitLabel(ec_lifting_measurement_item.unit(ec_product_meas_setup.item_code( DECODE(ecdp_objects.getobjcode(object_id),'STW_COND',(SELECT PRODUCT_MEAS_NO FROM DV_PROD_MEAS_SETUP WHERE LIFTING_EVENT = 'LOAD' AND MEAS_ITEM = 'LIFT_TOT_COND_VOL_GRS'),(SELECT PRODUCT_MEAS_NO FROM DV_PROD_MEAS_SETUP WHERE LIFTING_EVENT = 'LOAD' AND MEAS_ITEM = 'LIFT_TOT_LNG_VOL_NET'))))) || DECODE(ecdp_objects.getobjcode(object_id),'STW_COND', ' (GSV)', '') AS lifted_unit,

    --Item 127719:Begin
--       ec_cargo_transport.cargo_name(n_cargo_no) AS cargo_no,
         n_cargo_no AS cargo_no,
    --Item 127719:Begin
       EC_CARGO_TRANSPORT.TEXT_18(n_cargo_no) AS carrier,
       ec_company_version.name(ec_cargo_transport.REF_OBJECT_ID_10(n_cargo_no), COALESCE(EC_STORAGE_LIFT_NOMINATION.BL_DATE(n_parcel_no), DAYTIME), '<=') as transporter
      FROM DV_STORAGE_LIFT_NOM_BLMR WHERE CARGO_NO = n_cargo_no AND ROWNUM = 1;

   LOOP
      FETCH myCursor
         INTO
            out_rec.vessel,
            out_rec.discharge_port,
            out_rec.grade,
            out_rec.master,
            out_rec.agent,
            out_rec.local_port,
            out_rec.lifted_vol,
            out_rec.lifted_unit,
            out_rec.cargo_no,
            out_rec.carrier,
            out_rec.transporter;

         EXIT WHEN myCursor%NOTFOUND;
      PIPE ROW (out_rec);
   END LOOP;

   CLOSE myCursor;

   RETURN;

END cargo_auth_neg;


END UE_CT_CARGO_DOCS;
/