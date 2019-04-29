create or replace 
PACKAGE ue_calc_engine IS
/******************************************************************************
** Package        :  ue_calc_engine, head part
**
** $Revision: 1.2 $
**
** Purpose        :  User exit package called from the calculation engine.
**
** Documentation  :  www.energy-components.com
**
** Created        :  09.05.2006	Hanne Austad
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
********************************************************************/

PROCEDURE postDataWrite(
	p_runno		NUMBER,                             /* alloc_job_log.run_no for the calling calc engine transaction */
	p_transstart	VARCHAR2,                       /* Start date for the calling calc engine transaction, received as string since a DST flag is postfixed, must be parsed in routine */
	p_transend	VARCHAR2,                              /* End date for the calling calc engine transaction */
	p_startdate	DATE,                               /* Value of 'startdate' calc engine parameter */
	p_enddate	DATE,                               /* Value of 'enddate' calc engine parameter */
	p_context	VARCHAR2,                           /* Value of 'context' calc engine parameter */
	p_jobcode	VARCHAR2,                           /* Value of 'jobcode' calc engine parameter */
	p_loglevel	VARCHAR2,                           /* Value of 'loglevel' calc engine parameter */
	p_period	VARCHAR2,                           /* Value of 'period' calc engine parameter */
	p_network_id    VARCHAR2,                           /* Value of 'network_id' calc engine parameter */
	p_dataset       VARCHAR2,                           /* Value of 'dataset' calc engine parameter */
	p_extra_params	VARCHAR2);                          /* Additional calc engine parameters passed as a semi-colon separated string of <param name>=<param value> */

------------------------calcObjAttrFilter---------------------------------------------------------------------------
-- Function       : calcObjAttrFilter
-- Description    : Returns true if should be included
---------------------------------------------------------------------------------------------------
FUNCTION calcObjAttrFilter(
	p_startdate	DATE,                               /* Value of 'startdate' calc engine parameter */
	p_enddate	DATE,                               /* Value of 'enddate' calc engine parameter */
	p_object_type	VARCHAR2,                           /* Value of className */
	p_attr_name	VARCHAR2,                           /* Value of attribute name (sqlSyntax) */
	p_attr_value	VARCHAR2,                       /* Value of attribute */
	p_engineparams	Ecdp_Calculation.PARAM_MAP                       /* Value of calc engine parameter names semicolon separated */
	)	RETURN VARCHAR2;							/* return 'Y' for true */
END;
/


create or replace 
PACKAGE BODY ue_calc_engine IS
/******************************************************************************
** Package        :  ue_calc_engine, body part
**
** $Revision: 1.3 $
**
** Purpose        :  User exit package called from the calculation engine.
**
** Documentation  :  www.energy-components.com
**
** Created        :  09.05.2005	Hanne Austad
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- ------------------------------------------------------------------------------
** 26.04.07    HUS   Removed t_temptext debug
** 14-MAR-2013 SWGN  Added code to persist formula-based streams
** 03-JUN-2014 UDFD  Added code for daily profit centre calculation for reporting streams
** 17-JUN-2015 UDFD  Added code for monthly mass and monthly UPG calculation for reporting streams
** 06-AUG-2015 UDFD  Changed to handle WT_FRAC properly
** 28-APR-2016 UDFD  Added calc for Mol_Frac from Wt_Frac for CO2 - Environmental requirements
** 28-APR-2016 UDFD  Added calc for Mol_Frac from Wt_Frac for C1 - Environmental requirements
** 25-sep-2017 KOIJ  Env Monthly Report - incorrect mapping SW_GP_T1_ACID_GAS_VENT			 
********************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : postDataWrite
-- Description    : User exit procedure called by the calculation engine after successful data write.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
TYPE noms_type IS TABLE OF DV_FCST_STOR_LIFT_NOM%ROWTYPE;
PROCEDURE postDataWrite(
	p_runno		NUMBER,                             /* alloc_job_log.run_no for the calling calc engine transaction */
	p_transstart	VARCHAR2,                       /* Start date for the calling calc engine transaction, received as string since a DST flag is postfixed, must be parsed in routine */
	p_transend	VARCHAR2,                              /* End date for the calling calc engine transaction */
	p_startdate	DATE,                               /* Value of 'startdate' calc engine parameter */
	p_enddate	DATE,                               /* Value of 'enddate' calc engine parameter */
	p_context	VARCHAR2,                           /* Value of 'context' calc engine parameter */
	p_jobcode	VARCHAR2,                           /* Value of 'jobcode' calc engine parameter */
	p_loglevel	VARCHAR2,                           /* Value of 'loglevel' calc engine parameter */
	p_period	VARCHAR2,                           /* Value of 'period' calc engine parameter */
	p_network_id    VARCHAR2,                           /* Value of 'network_id' calc engine parameter */
	p_dataset       VARCHAR2,                           /* Value of 'dataset' calc engine parameter */
	p_extra_params	VARCHAR2)                           /* Additional calc engine parameters passed as a semi-colon separated string of <param name>=<param value> */
--</EC-DOC>
IS
-- The check to exclude allocation streams was removed because the PRRT post processing allocation
--  needs to have those streams included as allocation streams
    CURSOR day_streams IS
    SELECT stream_id
    FROM tv_stream_set_list
    WHERE code = 'GG.0001'
    AND ec_strm_version.strm_meter_freq(stream_id, nvl(p_startdate, p_enddate), '<=') = 'DAY';
    --AND nvl(ec_strm_version.alloc_period(stream_id, nvl(p_startdate, p_enddate), '<='), 'NONE') = 'NONE';

    CURSOR mth_streams IS
    SELECT stream_id
    FROM tv_stream_set_list
    WHERE code = 'GG.0001'
    AND ec_strm_version.strm_meter_freq(stream_id, nvl(p_startdate, p_enddate), '<=') = 'MTH';
    --AND nvl(ec_strm_version.alloc_period(stream_id, nvl(p_startdate, p_enddate), '<='), 'NONE') = 'NONE';

    CURSOR day_upg_streams IS
    SELECT stream_id
    FROM tv_stream_set_list
    WHERE code = 'GG.0002'
    AND ec_strm_version.strm_meter_freq(stream_id, nvl(p_startdate, p_enddate), '<=') = 'DAY';

-- CREATE 2 NEW CURSORS - DAILY/MONTHLY UPG STREAMS    - EXCLUDE FROM SETS THOSE IN PARTY ALLOC


    CURSOR LDRS(cp_forecast_id VARCHAR2)IS
    SELECT OBJECT_ID, OBJECT_CODE,PARCEL_NO,CARGO_NO, ETA,NOM_DATE,NOM_DATE_TIME,ETD ,
    (CASE WHEN NOM_DATE_RANGE IN ('0.5','1.5') THEN LDR_START-(NOM_DATE_TIME-ETA) ELSE NULL END)AS  LDR_START_ETA,
    (CASE WHEN NOM_DATE_RANGE IN ('0.5','1.5') THEN LDR_START ELSE NULL END)AS  LDR_START,
    (CASE WHEN NOM_DATE_RANGE IN ('0.5','1.5') THEN LDR_START+(ETD-NOM_DATE_TIME) ELSE NULL END)AS  LDR_START_ETD,
    (CASE WHEN NOM_DATE_RANGE IN ('0.5','1.5') THEN LDR_FINISH-(NOM_DATE_TIME-ETA) ELSE NULL END)AS  LDR_FINISH_ETA,
    (CASE WHEN NOM_DATE_RANGE IN ('0.5','1.5') THEN LDR_FINISH ELSE NULL END)AS  LDR_FINISH,
    (CASE WHEN NOM_DATE_RANGE IN ('0.5','1.5') THEN LDR_FINISH+(ETD-NOM_DATE_TIME) ELSE NULL END)AS  LDR_FINISH_ETD
    FROM DV_FCST_STOR_LIFT_NOM
    WHERE FORECAST_ID = cp_forecast_id
    AND OBJECT_CODE = 'STW_COND';

    CURSOR ALL_CARGOES(cp_forecast_id VARCHAR2, cp_cargo_no NUMBER,cp_start DATE, cp_end DATE)IS
    SELECT OBJECT_CODE,CARGO_NO, NOM_DATE_TIME
    FROM DV_FCST_STOR_LIFT_NOM
    WHERE FORECAST_ID = cp_forecast_id
    AND CARGO_NO <> cp_cargo_no
    AND NOM_DATE_TIME BETWEEN  cp_start AND cp_end
    GROUP BY OBJECT_CODE,CARGO_NO, NOM_DATE_TIME;



    CURSOR profit_centre IS
    SELECT DISTINCT PROFIT_CENTRE_ID
    FROM strm_day_pc_alloc;

    v_start_date DATE;
    v_job_code VARCHAR2(32);
    v_end_date DATE;
    v_current_date DATE;
    v_net_vol NUMBER;
    v_net_mass NUMBER;
    v_energy NUMBER;
    v_storage_id VARCHAR2(32);
    v_storage_id_COND VARCHAR2(32);
    v_forecast_id VARCHAR2(32);
    v_records noms_type;
    v_flag NUMBER;
    v_count NUMBER;
    c_strm_obj_id varchar2(100);
    c_daytime date;

    CURSOR mol_mth_streams IS
    SELECT *
    FROM strm_mth_comp_alloc WHERE DAYTIME >= p_startdate AND DAYTIME <= p_enddate and COMPONENT_NO in ('CO2','C1');



    ln_wt_frac NUMBER;
    ln_mol_frac NUMBER;
    ln_tot_mol_frac number;


BEGIN
	 --Visual Tracing update - ECPD-47555
  IF NVL(ec_ctrl_system_attribute.attribute_text(p_startdate,'ENABLE_VISUAL_TRACING','<='),'N')='Y' THEN
    --RRCA Royalty Calculation
    IF p_context = ecdp_objects.GetObjIDFromCode('CALC_CONTEXT', 'EC_REVN_RRCA') THEN
      EcDp_Visual_Tracing.UpdateVisualTracing(to_char(p_runno), 'CALC_REF_ROY', p_startdate);
    END IF;

    --Transactional Inventory Calculation
    IF p_context = ecdp_objects.GetObjIDFromCode('CALC_CONTEXT', 'EC_REVN_TI') THEN
      EcDp_Visual_Tracing.UpdateVisualTracing(to_char(p_runno), 'CALC_REF_TIN', p_startdate);
    END IF;								  
  END IF;
  --End of Visual Tracing update
   --ecdp_dynsql.writetemptext('ENGINE', p_jobcode || ' [' || to_char(p_startdate, 'DD-MON-YYYY') || ', ' || to_char(p_enddate, 'DD-MON-YYYY') || '] ' || ecdp_context.getAppUser);
    --ecdp_dynsql.writetemptext('ENGINE', 'p_runno=' || p_runno);

    --v_start_date := nvl(p_startdate, p_enddate);
    --v_end_date := p_enddate;
    v_start_date := nvl(to_date(p_transstart,'YYYY-MM-DD"T"HH24:MI:SS'), to_date(p_transend,'YYYY-MM-DD"T"HH24:MI:SS'));
    v_end_date := to_date(p_transend,'YYYY-MM-DD"T"HH24:MI:SS');

    v_job_code := ec_calculation.object_code(p_jobcode);


   -- UDFD: Calc Mol% from Wt% for CO2 and C1
    IF v_job_code = 'LNG_MONTHLY_MASS' THEN

        FOR strm IN mol_mth_streams LOOP
        -- 25-sep-2017 KOIJ  Env Monthly Report - incorrect mapping SW_GP_T1_ACID_GAS_VENT
        select sum(nvl(wt_frac,0)/ec_component_constant.mol_wt(ecdp_objects.getobjidfromcode('CONSTANT_STANDARD','ISO6976_STD'),b.component_no,b.daytime, '<='))
        into ln_tot_mol_frac
        from  strm_mth_comp_alloc b
        where OBJECT_ID=STRM.OBJECT_ID and daytime = STRM.DAYTIME;

           -- USE ISO6976_STD TO GET CONSTANT FOR CO2
           SELECT WT_FRAC INTO ln_wt_frac FROM STRM_MTH_COMP_ALLOC WHERE OBJECT_ID = STRM.OBJECT_ID AND COMPONENT_NO = 'CO2' AND DAYTIME = STRM.DAYTIME;
           ln_mol_frac := ln_wt_frac / ec_component_constant.mol_wt(ecdp_objects.getobjidfromcode('CONSTANT_STANDARD','ISO6976_STD'), 'CO2', strm.daytime, '<=');
          -- 25-sep-2017 KOIJ  Env Monthly Report - incorrect mapping SW_GP_T1_ACID_GAS_VENT
           ln_mol_frac :=ln_mol_frac/ln_tot_mol_frac;
           UPDATE STRM_MTH_COMP_ALLOC SET MOL_FRAC = ln_mol_frac WHERE OBJECT_ID = STRM.OBJECT_ID AND COMPONENT_NO = 'CO2' AND DAYTIME = STRM.DAYTIME;

           -- USE ISO6976_STD TO GET CONSTANT FOR C1
           SELECT WT_FRAC INTO ln_wt_frac FROM STRM_MTH_COMP_ALLOC WHERE OBJECT_ID = STRM.OBJECT_ID AND COMPONENT_NO = 'C1' AND DAYTIME = STRM.DAYTIME;
           ln_mol_frac := ln_wt_frac / ec_component_constant.mol_wt(ecdp_objects.getobjidfromcode('CONSTANT_STANDARD','ISO6976_STD'), 'C1', strm.daytime, '<=');
          -- 25-sep-2017 KOIJ  Env Monthly Report - incorrect mapping SW_GP_T1_ACID_GAS_VENT
	   ln_mol_frac :=ln_mol_frac/ln_tot_mol_frac;
           UPDATE STRM_MTH_COMP_ALLOC SET MOL_FRAC = ln_mol_frac WHERE OBJECT_ID = STRM.OBJECT_ID AND COMPONENT_NO = 'C1' AND DAYTIME = STRM.DAYTIME;

        END LOOP;

    END IF;

    -- Do the daily streams (this is done for daily and monthly allocations)
    --LBFK: Commented Out on WST build. Reporting streams will be calculated and materialized by the calculation rule due to the complexity of formulas
    /*
    IF v_job_code = 'LNG_MONTHLY_MASS' OR v_job_code = 'LNG_DAILY_MASS_ALLOC' OR v_job_code = 'CT_WST_DAILY_UPG_MASS_ALLOC' OR v_job_code = 'CT_WST_MONTHLY_UPG_MASS_ALLOC' THEN
        v_current_date := v_start_date;
        WHILE v_current_date < v_end_date OR (v_start_date = v_end_date AND v_current_date = v_start_date) LOOP

            -- Loop through all streams in the stream set
            FOR item IN day_streams LOOP

               IF v_job_code = 'LNG_MONTHLY_MASS' OR v_job_code = 'LNG_DAILY_MASS_ALLOC' THEN
                -- Insert defaults
                INSERT INTO strm_day_alloc (object_id, daytime)
                SELECT object_id, daytime
                FROM v_strm_day_der_stream
                WHERE object_id = item.stream_id
                AND daytime = v_current_date
                MINUS
                SELECT object_id, daytime
                FROM strm_day_alloc
                WHERE object_id = item.stream_id
                AND daytime = v_current_date;

                -- Have to buffer through a variable for the calculations to work correctly
                v_net_vol := EcBp_Stream_Fluid.findNetStdVol(item.stream_id, v_current_date, v_current_date);
                v_net_mass := EcBp_Stream_Fluid.findNetStdMass(item.stream_id, v_current_date, v_current_date);
                v_energy := EcBp_Stream_Fluid.findEnergy(item.stream_id, v_current_date, v_current_date);

                -- Set the STRM_DAY_ALLOC values
                UPDATE strm_day_alloc
                SET    net_vol = v_net_vol, net_mass = v_net_mass, alloc_energy = v_energy, last_updated_by = ecdp_context.getAppUser
                WHERE  object_id = item.stream_id
                AND daytime = v_current_date;

                -- Set the STRM_DAY_COMP_ALLOC_VALUES
                MERGE INTO strm_day_comp_alloc a
                    USING (SELECT item.stream_id as object_id, strms.component_no, strms.daytime, sum(nvl(strms.net_mass, 0)) AS net_mass, sum(nvl(strms.net_vol, 0)) AS net_vol,
                                  sum(nvl(strms.energy, 0)) AS energy
                           FROM strm_day_comp_alloc strms
                           WHERE strms.object_id IN
                           (
                               SELECT fv.object_id
                               FROM tv_strm_formula_variable fv
                               WHERE fv.class_name = 'STREAM'
                               AND fv.object_method like '%ALLOC%'
                               AND fv.formula_no =
                               (
                                   SELECT f.formula_no
                                   FROM tv_strm_formula f
                                   WHERE f.object_id = item.stream_id
                                   AND f.formula_method = 'NET_MASS_METHOD'
                                   AND f.formula not like '%'||CHR(45)||'%' -- Exclude Subtraction
                                   AND f.formula not like '%'||CHR(47)||'%' -- Exclude Division
                                   AND f.formula not like '%'||CHR(42)||'%' -- Exclude Multiplication
                                   AND f.formula not like '%'||CHR(94)||'%' -- Exclude Exponents
                               )
                           )
                           AND strms.daytime = v_current_date
                           GROUP BY strms.component_no, strms.daytime
                           ) t
                    ON (a.object_id = t.object_id AND a.daytime = t.daytime AND a.component_no = t.component_no)
                WHEN MATCHED THEN
                    UPDATE SET a.net_mass = t.net_mass, a.wt_frac = decode(v_net_mass, 0, 0,t.net_mass/v_net_mass), a.net_vol = t.net_vol, a.energy = t.energy, a.last_updated_by = ecdp_context.getAppUser
                WHEN NOT MATCHED THEN
                    INSERT (object_id, component_no, daytime, net_mass, wt_frac, net_vol, energy, created_by)
                    VALUES (t.object_id, t.component_no, t.daytime, t.net_mass, decode(v_net_mass, 0, 0,t.net_mass/v_net_mass), t.net_vol, t.energy, ecdp_context.getAppUser);

               END IF;

            END LOOP; -- stream

            -- Loop through all streams in the upg stream set
            FOR item IN day_upg_streams LOOP

              -- Loop through all profit centres connected with streams
               IF v_job_code = 'CT_WST_DAILY_UPG_MASS_ALLOC' THEN
                FOR pc IN profit_centre LOOP

                        -- Set the STRM_DAY_PC_ALLOC values
                        MERGE INTO strm_day_pc_alloc a
                            USING (SELECT item.stream_id as object_id, pc.profit_centre_id as profit_centre_id, strms.daytime, sum(nvl(strms.net_mass, 0)) AS net_mass, sum(nvl(strms.net_vol, 0)) AS net_vol, sum(nvl(strms.energy, 0)) AS energy
                                   FROM strm_day_pc_alloc strms
                                   WHERE strms.object_id IN
                                   (
                                       SELECT fv.object_id
                                       FROM tv_strm_formula_variable fv
                                       WHERE fv.class_name = 'STREAM'
                                       AND fv.object_method like '%ALLOC%'
                                       AND fv.formula_no =
                                       (
                                           SELECT f.formula_no
                                           FROM tv_strm_formula f
                                           WHERE f.object_id = item.stream_id
                                           AND f.formula_method = 'NET_MASS_METHOD'
                                           AND f.formula not like '%'||CHR(45)||'%' -- Exclude Subtraction
                                           AND f.formula not like '%'||CHR(47)||'%' -- Exclude Division
                                           AND f.formula not like '%'||CHR(42)||'%' -- Exclude Multiplication
                                           AND f.formula not like '%'||CHR(94)||'%' -- Exclude Exponents
                                       )
                                   )
                                   AND strms.daytime = v_current_date
                                   AND strms.profit_centre_id = pc.profit_centre_id
                                   GROUP BY strms.daytime ) t
                            ON (a.object_id = t.object_id AND a.profit_centre_id = t.profit_centre_id AND a.daytime = t.daytime)
                        WHEN MATCHED THEN
                            UPDATE SET a.net_mass = t.net_mass, a.net_vol = t.net_vol, a.energy = t.energy, a.last_updated_by = ecdp_context.getAppUser
                        WHEN NOT MATCHED THEN
                            INSERT (object_id, profit_centre_id, daytime, net_mass, net_vol, energy, created_by)
                            VALUES (t.object_id, t.profit_centre_id, t.daytime, t.net_mass, t.net_vol, t.energy, ecdp_context.getAppUser);

                        -- SELECT V_NET_MASS PER UPG TO HANDLE WT_FRAC

                        SELECT COUNT(*) INTO v_flag FROM strm_day_pc_alloc s WHERE s.object_id = item.stream_id AND  s.profit_centre_id = pc.profit_centre_id  AND s.daytime = v_current_date;

                        IF v_flag > 0 then
                            SELECT nvl(s.net_mass, 0) INTO v_net_mass FROM strm_day_pc_alloc s WHERE s.object_id = item.stream_id AND  s.profit_centre_id = pc.profit_centre_id  AND s.daytime = v_current_date;
                        end if;

                       --

                        -- Set the STRM_DAY_PC_CP_ALLOC_VALUES
                        MERGE INTO strm_day_pc_cp_alloc a
                            USING (SELECT item.stream_id as object_id, pc.profit_centre_id as profit_centre_id, strms.component_no, strms.daytime, sum(nvl(strms.net_mass, 0)) AS net_mass, sum(nvl(strms.net_vol, 0)) AS net_vol, sum(nvl(strms.energy, 0)) AS energy
                                   FROM strm_day_pc_cp_alloc strms
                                   WHERE strms.object_id IN
                                   (
                                       SELECT fv.object_id
                                       FROM tv_strm_formula_variable fv
                                       WHERE fv.class_name = 'STREAM'
                                       AND fv.object_method like '%ALLOC%'
                                       AND fv.formula_no =
                                       (
                                           SELECT f.formula_no
                                           FROM tv_strm_formula f
                                           WHERE f.object_id = item.stream_id
                                           AND f.formula_method = 'NET_MASS_METHOD'
                                           AND f.formula not like '%'||CHR(45)||'%' -- Exclude Subtraction
                                           AND f.formula not like '%'||CHR(47)||'%' -- Exclude Division
                                           AND f.formula not like '%'||CHR(42)||'%' -- Exclude Multiplication
                                           AND f.formula not like '%'||CHR(94)||'%' -- Exclude Exponents
                                       )
                                   )
                                   AND strms.daytime = v_current_date
                                   AND strms.profit_centre_id = pc.profit_centre_id
                                   GROUP BY strms.component_no, strms.daytime ) t
                            ON (a.object_id = t.object_id AND a.profit_centre_id = t.profit_centre_id AND a.daytime = t.daytime AND a.component_no = t.component_no)
                        WHEN MATCHED THEN
                            UPDATE SET a.net_mass = t.net_mass, a.wt_frac = decode(v_net_mass, 0, 0,t.net_mass/v_net_mass), a.net_vol = t.net_vol, a.energy = t.energy, a.last_updated_by = ecdp_context.getAppUser
                        WHEN NOT MATCHED THEN
                            INSERT (object_id, profit_centre_id, component_no, daytime, net_mass, wt_frac, net_vol, energy, created_by)
                            VALUES (t.object_id, t.profit_centre_id, t.component_no, t.daytime, t.net_mass, decode(v_net_mass, 0, 0,t.net_mass/v_net_mass), t.net_vol, t.energy, ecdp_context.getAppUser);





                END LOOP; -- profit centre

               END IF;

            END LOOP;    -- upg streams

            v_current_date := v_current_date + 1;

        END LOOP;

    END IF;
    */
				  

    IF v_job_code = 'LNG_MONTHLY_MASS' OR v_job_code = 'LNG_DAILY_MASS_ALLOC' THEN
        -- Update Record Status to Provisional
        -- LNG Base Allocation
        UPDATE DV_PWEL_DAY_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= v_start_date and DAYTIME< v_end_date;
        UPDATE DV_PWEL_DAY_COMP_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= v_start_date and DAYTIME< v_end_date;
        UPDATE DV_STRM_DAY_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= v_start_date and DAYTIME< v_end_date;
        UPDATE DV_STRM_DAY_COMP_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= v_start_date and DAYTIME< v_end_date;
        UPDATE DV_IWEL_DAY_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= v_start_date and DAYTIME< v_end_date;
        UPDATE DV_IWEL_DAY_COMP_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= v_start_date and DAYTIME< v_end_date;
        -- Reservoir Allocation
        UPDATE DV_PERF_DAY_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= v_start_date and DAYTIME< v_end_date;
        UPDATE DV_PERF_DAY_COMP_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= v_start_date and DAYTIME< v_end_date;
        UPDATE DV_RBF_DAY_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= v_start_date and DAYTIME< v_end_date;
        -- UPG Allocation
        UPDATE DV_STRM_DAY_PC_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= v_start_date and DAYTIME< v_end_date;
        UPDATE DV_STRM_DAY_PC_CP_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= v_start_date and DAYTIME< v_end_date;
        UPDATE DV_STRM_DAY_PC_CPY_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= v_start_date and DAYTIME< v_end_date;
        UPDATE DV_CT_STRM_DAY_PC_CPY_CP_AL SET RECORD_STATUS = 'P' WHERE DAYTIME >= v_start_date and DAYTIME< v_end_date;
        UPDATE DV_SCTR_ACC_DAY_STATUS SET RECORD_STATUS = 'P' WHERE DAYTIME >= v_start_date and DAYTIME< v_end_date and object_code in ('C_ALLOC_JVP_TAPL', 'C_ALLOC_JVP_CAPL', 'C_ALLOC_JVP_PEW', 'C_ALLOC_JVP_KWI', 'C_ALLOC_JVP_QE','C_ALLOC_UPG_WI','C_ALLOC_JVP_WEJ','C_ALLOC_JVP_KJB','C_ALLOC_UPG_JB');

        IF v_job_code = 'LNG_MONTHLY_MASS' THEN
            -- LNG Base Allocation
            UPDATE DV_PWEL_MTH_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= v_start_date and DAYTIME< v_end_date;
            UPDATE DV_PWEL_MTH_COMP_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= v_start_date and DAYTIME< v_end_date;
            UPDATE DV_STRM_MTH_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= v_start_date and DAYTIME< v_end_date;
            UPDATE DV_STRM_MTH_COMP_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= v_start_date and DAYTIME< v_end_date;
            UPDATE DV_IWEL_MTH_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= v_start_date and DAYTIME< v_end_date;
            UPDATE DV_IWEL_MTH_COMP_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= v_start_date and DAYTIME< v_end_date;
            -- Reservoir Allocation
            UPDATE DV_PERF_MTH_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= v_start_date and DAYTIME< v_end_date;
            UPDATE DV_PERF_MTH_COMP_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= v_start_date and DAYTIME< v_end_date;
            UPDATE DV_RBF_MTH_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= v_start_date and DAYTIME< v_end_date;
            -- UPG Allocation
            UPDATE DV_STRM_MTH_PC_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= v_start_date and DAYTIME< v_end_date;
            UPDATE DV_STRM_MTH_PC_CP_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= v_start_date and DAYTIME< v_end_date;
            UPDATE DV_STRM_MTH_PC_CPY_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= v_start_date and DAYTIME< v_end_date;
            UPDATE DV_CT_STRM_MTH_PC_CPY_CP_AL SET RECORD_STATUS = 'P' WHERE DAYTIME >= v_start_date and DAYTIME< v_end_date;
            UPDATE DV_SCTR_ACC_MTH_STATUS SET RECORD_STATUS = 'P' WHERE DAYTIME >= v_start_date and DAYTIME< v_end_date and object_code in ('C_ALLOC_JVP_TAPL', 'C_ALLOC_JVP_CAPL', 'C_ALLOC_JVP_PEW', 'C_ALLOC_JVP_KWI', 'C_ALLOC_JVP_QE','C_ALLOC_UPG_WI','C_ALLOC_JVP_WEJ','C_ALLOC_JVP_KJB','C_ALLOC_UPG_JB');

        ELSE
            -- LNG Base Allocation
            UPDATE DV_PWEL_MTH_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= TRUNC(v_start_date,'MM') and DAYTIME< v_end_date;
            UPDATE DV_PWEL_MTH_COMP_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= TRUNC(v_start_date,'MM') and DAYTIME< v_end_date;
            UPDATE DV_STRM_MTH_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= TRUNC(v_start_date,'MM') and DAYTIME< v_end_date;
            UPDATE DV_STRM_MTH_COMP_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= TRUNC(v_start_date,'MM') and DAYTIME< v_end_date;
            UPDATE DV_IWEL_MTH_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= TRUNC(v_start_date,'MM') and DAYTIME< v_end_date;
            UPDATE DV_IWEL_MTH_COMP_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= TRUNC(v_start_date,'MM') and DAYTIME< v_end_date;
            -- Reservoir Allocation
            UPDATE DV_PERF_MTH_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= TRUNC(v_start_date,'MM') and DAYTIME< v_end_date;
            UPDATE DV_PERF_MTH_COMP_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= TRUNC(v_start_date,'MM') and DAYTIME< v_end_date;
            UPDATE DV_RBF_MTH_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= TRUNC(v_start_date,'MM') and DAYTIME< v_end_date;
            -- UPG Allocation
            UPDATE DV_STRM_MTH_PC_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= TRUNC(v_start_date,'MM') and DAYTIME< v_end_date;
            UPDATE DV_STRM_MTH_PC_CP_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= TRUNC(v_start_date,'MM') and DAYTIME< v_end_date;
            UPDATE DV_STRM_MTH_PC_CPY_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= TRUNC(v_start_date,'MM') and DAYTIME< v_end_date;
            UPDATE DV_CT_STRM_MTH_PC_CPY_CP_AL SET RECORD_STATUS = 'P' WHERE DAYTIME >= TRUNC(v_start_date,'MM') and DAYTIME< v_end_date;
            UPDATE DV_SCTR_ACC_MTH_STATUS SET RECORD_STATUS = 'P' WHERE DAYTIME >= TRUNC(v_start_date,'MM') and DAYTIME< v_end_date and object_code in ('C_ALLOC_JVP_TAPL', 'C_ALLOC_JVP_CAPL', 'C_ALLOC_JVP_PEW', 'C_ALLOC_JVP_KWI', 'C_ALLOC_JVP_QE','C_ALLOC_UPG_WI','C_ALLOC_JVP_WEJ','C_ALLOC_JVP_KJB','C_ALLOC_UPG_JB');

        END IF;

    END IF;

    IF v_job_code = 'CT_WST_DAILY_UPG_MASS_ALLOC' OR v_job_code = 'CT_WST_MONTHLY_UPG_MASS_ALLOC' THEN
        -- Update Record Status to Provisional

        UPDATE DV_STRM_DAY_PC_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= v_start_date and DAYTIME< v_end_date;
        UPDATE DV_STRM_DAY_PC_CP_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= v_start_date and DAYTIME< v_end_date;
        UPDATE DV_STRM_DAY_PC_CPY_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= v_start_date and DAYTIME< v_end_date;
        UPDATE DV_CT_STRM_DAY_PC_CPY_CP_AL SET RECORD_STATUS = 'P' WHERE DAYTIME >= v_start_date and DAYTIME< v_end_date;
        UPDATE DV_SCTR_ACC_DAY_STATUS SET RECORD_STATUS = 'P' WHERE DAYTIME >= v_start_date and DAYTIME< v_end_date and object_code in ('C_ALLOC_JVP_TAPL', 'C_ALLOC_JVP_CAPL', 'C_ALLOC_JVP_PEW', 'C_ALLOC_JVP_KWI', 'C_ALLOC_JVP_QE','C_ALLOC_UPG_WI','C_ALLOC_JVP_WEJ','C_ALLOC_JVP_KJB','C_ALLOC_UPG_JB');

        IF v_job_code = 'CT_WST_MONTHLY_UPG_MASS_ALLOC' THEN

            UPDATE DV_STRM_MTH_PC_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= v_start_date and DAYTIME< v_end_date;
            UPDATE DV_STRM_MTH_PC_CP_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= v_start_date and DAYTIME< v_end_date;
            UPDATE DV_STRM_MTH_PC_CPY_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= v_start_date and DAYTIME< v_end_date;
            UPDATE DV_CT_STRM_MTH_PC_CPY_CP_AL SET RECORD_STATUS = 'P' WHERE DAYTIME >= v_start_date and DAYTIME< v_end_date;
            UPDATE DV_SCTR_ACC_MTH_STATUS SET RECORD_STATUS = 'P' WHERE DAYTIME >= v_start_date and DAYTIME< v_end_date and object_code in ('C_ALLOC_JVP_TAPL', 'C_ALLOC_JVP_CAPL', 'C_ALLOC_JVP_PEW', 'C_ALLOC_JVP_KWI', 'C_ALLOC_JVP_QE','C_ALLOC_UPG_WI','C_ALLOC_JVP_WEJ','C_ALLOC_JVP_KJB','C_ALLOC_UPG_JB');

        ELSE

            UPDATE DV_STRM_MTH_PC_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= TRUNC(v_start_date,'MM') and DAYTIME< v_end_date;
            UPDATE DV_STRM_MTH_PC_CP_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= TRUNC(v_start_date,'MM') and DAYTIME< v_end_date;
            UPDATE DV_STRM_MTH_PC_CPY_ALLOC SET RECORD_STATUS = 'P' WHERE DAYTIME >= TRUNC(v_start_date,'MM') and DAYTIME< v_end_date;
            UPDATE DV_CT_STRM_MTH_PC_CPY_CP_AL SET RECORD_STATUS = 'P' WHERE DAYTIME >= TRUNC(v_start_date,'MM') and DAYTIME< v_end_date;
            UPDATE DV_SCTR_ACC_MTH_STATUS SET RECORD_STATUS = 'P' WHERE DAYTIME >= TRUNC(v_start_date,'MM') and DAYTIME< v_end_date and object_code in ('C_ALLOC_JVP_TAPL', 'C_ALLOC_JVP_CAPL', 'C_ALLOC_JVP_PEW', 'C_ALLOC_JVP_KWI', 'C_ALLOC_JVP_QE','C_ALLOC_UPG_WI','C_ALLOC_JVP_WEJ','C_ALLOC_JVP_KJB','C_ALLOC_UPG_JB');

        END IF;

    END IF;

    -- Do the monthly streams (this is done for monthly allocations)
    --LBFK: Commented Out on WST build. Reporting streams will be calculated and materialized by the calculation rule due to the complexity of formulas
    /*
    IF v_job_code = 'LNG_MONTHLY_MASS' OR v_job_code = 'CT_WST_MONTHLY_UPG_MASS_ALLOC' THEN
        v_current_date := v_start_date;

        WHILE v_current_date < v_end_date OR (v_start_date = v_end_date AND v_current_date = v_start_date) LOOP

            -- Loop through all streams in the stream set
            FOR item IN day_streams LOOP

             IF v_job_code = 'LNG_MONTHLY_MASS'    THEN
                -- Insert defaults
                INSERT INTO strm_mth_alloc (object_id, daytime)
                SELECT DISTINCT object_id, trunc(daytime, 'MONTH')
                FROM v_strm_day_der_stream
                WHERE object_id = item.stream_id
                AND trunc(daytime, 'MONTH') = v_current_date
                MINUS
                SELECT object_id, daytime
                FROM strm_mth_alloc
                WHERE object_id = item.stream_id
                AND daytime = v_current_date;


                -- Have to buffer through a variable for the calculations to work correctly
                v_net_vol := EcBp_Stream_Fluid.findNetStdVol(item.stream_id, v_current_date, LAST_DAY(v_current_date));
                v_net_mass := EcBp_Stream_Fluid.findNetStdMass(item.stream_id, v_current_date, LAST_DAY(v_current_date));
                v_energy := EcBp_Stream_Fluid.findEnergy(item.stream_id, v_current_date, LAST_DAY(v_current_date));

                -- Set the STRM_MTH_ALLOC values
                UPDATE strm_mth_alloc
                SET    net_vol = v_net_vol, net_mass = v_net_mass, alloc_energy = v_energy, last_updated_by = ecdp_context.getAppUser
                WHERE  object_id = item.stream_id
                AND daytime = v_current_date;

                -- Set the STRM_MTH_COMP_ALLOC_VALUES
                MERGE INTO strm_mth_comp_alloc a
                    USING (SELECT item.stream_id as object_id, strms.component_no, strms.daytime, sum(nvl(strms.net_mass, 0)) AS net_mass, sum(nvl(strms.wt_frac, 0)) AS wt_frac, sum(nvl(strms.net_vol, 0)) AS net_vol, sum(nvl(strms.energy, 0)) AS energy
                           FROM strm_mth_comp_alloc strms
                           WHERE strms.object_id IN
                           (
                               SELECT fv.object_id
                               FROM tv_strm_formula_variable fv
                               WHERE fv.class_name = 'STREAM'
                               AND fv.object_method like '%ALLOC%'
                               AND fv.formula_no =
                               (
                                   SELECT f.formula_no
                                   FROM tv_strm_formula f
                                   WHERE f.object_id = item.stream_id
                                   AND f.formula_method = 'NET_MASS_METHOD'
                                   AND f.formula not like '%'||CHR(45)||'%' -- Exclude Subtraction
                                   AND f.formula not like '%'||CHR(47)||'%' -- Exclude Division
                                   AND f.formula not like '%'||CHR(42)||'%' -- Exclude Multiplication
                                   AND f.formula not like '%'||CHR(94)||'%' -- Exclude Exponents
                               )
                           )
                           AND strms.daytime = v_current_date
                           GROUP BY strms.component_no, strms.daytime
                           ) t
                    ON (a.object_id = t.object_id AND a.daytime = t.daytime AND a.component_no = t.component_no)
                WHEN MATCHED THEN
                    UPDATE SET a.net_mass = t.net_mass, a.wt_frac = decode(v_net_mass, 0, 0,t.net_mass/v_net_mass), a.net_vol = t.net_vol, a.energy = t.energy, a.last_updated_by = ecdp_context.getAppUser
                WHEN NOT MATCHED THEN
                    INSERT (object_id, component_no, daytime, net_mass, wt_frac, net_vol, energy, created_by)
                    VALUES (t.object_id, t.component_no, t.daytime, t.net_mass, decode(v_net_mass, 0, 0,t.net_mass/v_net_mass), t.net_vol, t.energy, ecdp_context.getAppUser);

             END IF;

            END LOOP; -- stream


            -- Loop through all streams in the upg stream set
            FOR item IN day_upg_streams LOOP

               -- Loop through all profit centres connected with streams
               IF v_job_code = 'CT_WST_MONTHLY_UPG_MASS_ALLOC' THEN
                FOR pc IN profit_centre LOOP

                        -- Set the STRM_MTH_PC_ALLOC values
                        MERGE INTO strm_mth_pc_alloc a
                            USING (SELECT item.stream_id as object_id, pc.profit_centre_id as profit_centre_id, strms.daytime, sum(nvl(strms.net_mass, 0)) AS net_mass, sum(nvl(strms.net_vol, 0)) AS net_vol, sum(nvl(strms.energy, 0)) AS energy
                                   FROM strm_mth_pc_alloc strms
                                   WHERE strms.object_id IN
                                   (
                                       SELECT fv.object_id
                                       FROM tv_strm_formula_variable fv
                                       WHERE fv.class_name = 'STREAM'
                                       AND fv.object_method like '%ALLOC%'
                                       AND fv.formula_no =
                                       (
                                           SELECT f.formula_no
                                           FROM tv_strm_formula f
                                           WHERE f.object_id = item.stream_id
                                           AND f.formula_method = 'NET_MASS_METHOD'
                                           AND f.formula not like '%'||CHR(45)||'%' -- Exclude Subtraction
                                           AND f.formula not like '%'||CHR(47)||'%' -- Exclude Division
                                           AND f.formula not like '%'||CHR(42)||'%' -- Exclude Multiplication
                                           AND f.formula not like '%'||CHR(94)||'%' -- Exclude Exponents
                                       )
                                   )
                                   AND strms.daytime = v_current_date
                                   AND strms.profit_centre_id = pc.profit_centre_id
                                   GROUP BY strms.daytime ) t
                            ON (a.object_id = t.object_id AND a.profit_centre_id = t.profit_centre_id AND a.daytime = t.daytime)
                        WHEN MATCHED THEN
                            UPDATE SET a.net_mass = t.net_mass, a.net_vol = t.net_vol, a.energy = t.energy, a.last_updated_by = ecdp_context.getAppUser
                        WHEN NOT MATCHED THEN
                            INSERT (object_id, profit_centre_id, daytime, net_mass, net_vol, energy, created_by)
                            VALUES (t.object_id, t.profit_centre_id, t.daytime, t.net_mass, t.net_vol, t.energy, ecdp_context.getAppUser);

                        -- SELECT V_NET_MASS PER UPG TO HANDLE WT_FRAC

                        SELECT COUNT(*) INTO v_flag FROM strm_mth_pc_alloc s WHERE s.object_id = item.stream_id AND  s.profit_centre_id = pc.profit_centre_id  AND s.daytime = v_current_date;

                        IF v_flag > 0 then
                            SELECT nvl(s.net_mass, 0) INTO v_net_mass FROM strm_mth_pc_alloc s WHERE s.object_id = item.stream_id AND  s.profit_centre_id = pc.profit_centre_id  AND s.daytime = v_current_date;
                        end if;


                        --

                        -- Set the STRM_MTH_PC_CP_ALLOC_VALUES
                        MERGE INTO strm_mth_pc_cp_alloc a
                            USING (SELECT item.stream_id as object_id, pc.profit_centre_id as profit_centre_id, strms.component_no, strms.daytime, sum(nvl(strms.net_mass, 0)) AS net_mass, sum(nvl(strms.wt_frac, 0)) AS wt_frac, sum(nvl(strms.net_vol, 0)) AS net_vol, sum(nvl(strms.energy, 0)) AS energy
                                   FROM strm_mth_pc_cp_alloc strms
                                   WHERE strms.object_id IN
                                   (
                                       SELECT fv.object_id
                                       FROM tv_strm_formula_variable fv
                                       WHERE fv.class_name = 'STREAM'
                                       AND fv.object_method like '%ALLOC%'
                                       AND fv.formula_no =
                                       (
                                           SELECT f.formula_no
                                           FROM tv_strm_formula f
                                           WHERE f.object_id = item.stream_id
                                           AND f.formula_method = 'NET_MASS_METHOD'
                                           AND f.formula not like '%'||CHR(45)||'%' -- Exclude Subtraction
                                           AND f.formula not like '%'||CHR(47)||'%' -- Exclude Division
                                           AND f.formula not like '%'||CHR(42)||'%' -- Exclude Multiplication
                                           AND f.formula not like '%'||CHR(94)||'%' -- Exclude Exponents
                                       )
                                   )
                                   AND strms.daytime = v_current_date
                                   AND strms.profit_centre_id = pc.profit_centre_id
                                   GROUP BY strms.component_no, strms.daytime ) t
                            ON (a.object_id = t.object_id AND a.profit_centre_id = t.profit_centre_id AND a.daytime = t.daytime AND a.component_no = t.component_no)
                        WHEN MATCHED THEN
                            UPDATE SET a.net_mass = t.net_mass, a.wt_frac = decode(v_net_mass, 0, 0,t.net_mass/v_net_mass), a.net_vol = t.net_vol, a.energy = t.energy, a.last_updated_by = ecdp_context.getAppUser
                        WHEN NOT MATCHED THEN
                            INSERT (object_id, profit_centre_id, component_no, daytime, net_mass, wt_frac, net_vol, energy, created_by)
                            VALUES (t.object_id, t.profit_centre_id, t.component_no, t.daytime, t.net_mass, decode(v_net_mass, 0, 0,t.net_mass/v_net_mass), t.net_vol, t.energy, ecdp_context.getAppUser);

                END LOOP; -- profit centre

               END IF;

            END LOOP;

            v_current_date := add_months(v_current_date, 1);
        END LOOP;
    END IF;
    */

    IF v_job_code = 'CT_WST_COND_PROGRAM' THEN

        SELECT SUBSTR(p_extra_params,(INSTR(p_extra_params,'storage_id')+length('storage_id')+1),32) INTO v_storage_id FROM DUAL;
        SELECT SUBSTR(p_extra_params,(INSTR(p_extra_params,'forecast_id')+length('forecast_id')+1),32) INTO v_forecast_id from dual;

        SELECT * BULK COLLECT INTO v_records
        FROM DV_FCST_STOR_LIFT_NOM A
        WHERE FORECAST_ID = v_forecast_id
        AND A.OBJECT_ID = nvl(v_storage_id, a.object_id)
        ORDER BY NOM_DATE_TIME;

        FOR cur_gen IN 1 ..  v_records.count LOOP
             UE_CARGO_FCST_TRANSPORT.CONNECTNOMTOCARGO(v_records(cur_gen).cargo_no,'(' || v_records(cur_gen).parcel_no || ')',v_records(cur_gen).forecast_id);
        END LOOP;
    END IF;

    IF v_job_code = 'CT_WST_VALIDATE_SCENARIO' THEN
        SELECT SUBSTR(p_extra_params,(INSTR(p_extra_params,'forecast_id')+length('forecast_id')+1),32) INTO v_forecast_id from dual;
        SELECT SUBSTR(p_extra_params,(INSTR(p_extra_params,'storage_id')+length('storage_id')+1),32) INTO v_storage_id FROM DUAL;
        --v_storage_id := ECDP_OBJECTS.GETOBJIDFROMCODE('STORAGE', 'STW_LNG');
        v_storage_id_COND := ECDP_OBJECTS.GETOBJIDFROMCODE('STORAGE', 'STW_COND');


        DELETE FROM DV_CT_STOR_VALIDATION WHERE FORECAST_ID <> v_forecast_id or (FORECAST_ID = v_forecast_id and RUN_NO <> p_runno);
--reset cancelled cargoes
        UPDATE DV_FCST_STOR_LIFT_NOM
        SET NOM_VALID = 'Y'
        WHERE FORECAST_ID = v_forecast_id
        --AND OBJECT_ID = v_storage_id
        AND
        (ECBP_CARGO_STATUS.GETECCARGOSTATUS (
                      COALESCE (
                         ec_cargo_fcst_transport.cargo_status (CARGO_NO,
                                                               forecast_id),
                         'T')) = 'D');



--FOR LNG
        --UPDATE TANK TOP
        UPDATE DV_FCST_STOR_LIFT_NOM
        SET NOM_VALID = 'N' , VALIDATION_ISSUES = DECODE(VALIDATION_ISSUES,NULL,'TANK_TOP_RL',VALIDATION_ISSUES||',TANK_TOP_RL')
        WHERE FORECAST_ID = v_forecast_id
        AND OBJECT_ID = v_storage_id
        AND (
        ue_ct_cargo_info.getcargotankdipqty(parcel_no, 'OPENING_VOL', FORECAST_ID)>ecbp_storage.getmaxsafelimitvollevel(OBJECT_ID, NOM_DATE)
        OR
        ue_ct_cargo_info.getcargotankdipqty(parcel_no, 'CLOSING_VOL', FORECAST_ID)>ecbp_storage.getmaxsafelimitvollevel(OBJECT_ID, NOM_DATE)
        )
        AND
        (ECBP_CARGO_STATUS.GETECCARGOSTATUS (
                      COALESCE (
                         ec_cargo_fcst_transport.cargo_status (CARGO_NO,
                                                               forecast_id),
                         'T')) <> 'D');

        --UPDATE TANK BOTTOM
        UPDATE DV_FCST_STOR_LIFT_NOM
        SET NOM_VALID = 'N' , VALIDATION_ISSUES = DECODE(VALIDATION_ISSUES,NULL,'TANK_BOTTOM_RL',VALIDATION_ISSUES||',TANK_BOTTOM_RL')
        WHERE FORECAST_ID = v_forecast_id
        AND OBJECT_ID = v_storage_id
        AND (
        ue_ct_cargo_info.getcargotankdipqty(parcel_no, 'OPENING_VOL', FORECAST_ID)<ecbp_storage.getminsafelimitvollevel(OBJECT_ID, NOM_DATE)
        OR
        ue_ct_cargo_info.getcargotankdipqty(parcel_no, 'CLOSING_VOL', FORECAST_ID)<ecbp_storage.getminsafelimitvollevel(OBJECT_ID, NOM_DATE)
        )
        AND
        (ECBP_CARGO_STATUS.GETECCARGOSTATUS (
                      COALESCE (
                         ec_cargo_fcst_transport.cargo_status (CARGO_NO,
                                                               forecast_id),
                         'T')) <> 'D');

--FOR COND
        --UPDATE TANK TOP
        UPDATE DV_FCST_STOR_LIFT_NOM
        SET NOM_VALID = 'N' , VALIDATION_ISSUES = DECODE(VALIDATION_ISSUES,NULL,'TANK_TOP_RL',VALIDATION_ISSUES||',TANK_TOP_RL')
        WHERE FORECAST_ID = v_forecast_id
        AND OBJECT_ID = v_storage_id_COND
        AND (
        ue_ct_cargo_info.getcargotankdipqty(parcel_no, 'OPENING_VOL', FORECAST_ID)>ecbp_storage.getmaxsafelimitvollevel(OBJECT_ID, NOM_DATE)
        OR
        ue_ct_cargo_info.getcargotankdipqty(parcel_no, 'CLOSING_VOL', FORECAST_ID)>ecbp_storage.getmaxsafelimitvollevel(OBJECT_ID, NOM_DATE)
        )
        AND
        (ECBP_CARGO_STATUS.GETECCARGOSTATUS (
                      COALESCE (
                         ec_cargo_fcst_transport.cargo_status (CARGO_NO,
                                                               forecast_id),
                         'T')) <> 'D');

        --UPDATE TANK BOTTOM
        UPDATE DV_FCST_STOR_LIFT_NOM
        SET NOM_VALID = 'N' , VALIDATION_ISSUES = DECODE(VALIDATION_ISSUES,NULL,'TANK_BOTTOM_RL',VALIDATION_ISSUES||',TANK_BOTTOM_RL')
        WHERE FORECAST_ID = v_forecast_id
        AND OBJECT_ID = v_storage_id_COND
        AND (
        ue_ct_cargo_info.getcargotankdipqty(parcel_no, 'OPENING_VOL', FORECAST_ID)<ecbp_storage.getminsafelimitvollevel(OBJECT_ID, NOM_DATE)
        OR
        ue_ct_cargo_info.getcargotankdipqty(parcel_no, 'CLOSING_VOL', FORECAST_ID)<ecbp_storage.getminsafelimitvollevel(OBJECT_ID, NOM_DATE)
        )
        AND
        (ECBP_CARGO_STATUS.GETECCARGOSTATUS (
                      COALESCE (
                         ec_cargo_fcst_transport.cargo_status (CARGO_NO,
                                                               forecast_id),
                         'T')) <> 'D');


        --tlxt: 99706: 06-jul-2015: CP - Calculation - Validate Scenario - LDR
        IF NVL(EC_CTRL_SYSTEM_ATTRIBUTE.ATTRIBUTE_TEXT(SYSDATE, 'ENABLE_COND_LDR_VAL' , '<='),'N') = 'Y' THEN
            UPDATE STOR_FCST_LIFT_NOM
            SET TEXT_19 = NULL
            WHERE FORECAST_ID = v_forecast_id;
            FOR COND_CARGOES IN LDRS(v_forecast_id) LOOP
                FOR ALL_LDR_START IN ALL_CARGOES(v_forecast_id, COND_CARGOES.CARGO_NO ,COND_CARGOES.LDR_START_ETA , COND_CARGOES.LDR_START_ETD  ) LOOP
                    UPDATE STOR_FCST_LIFT_NOM
                    SET TEXT_19 = TEXT_19 || NVL2(TEXT_19,', ','LDR Start Conflicting with Cargo ') || ALL_LDR_START.CARGO_NO
                    WHERE FORECAST_ID = v_forecast_id
                    AND CARGO_NO = COND_CARGOES.CARGO_NO
                    AND OBJECT_ID = COND_CARGOES.OBJECT_ID;
                END LOOP;
                FOR ALL_LDR_FINISH IN ALL_CARGOES(v_forecast_id, COND_CARGOES.CARGO_NO ,COND_CARGOES.LDR_FINISH_ETA , COND_CARGOES.LDR_FINISH_ETD  ) LOOP
                    UPDATE STOR_FCST_LIFT_NOM
                    SET TEXT_19 = TEXT_19 || NVL2(TEXT_19,', ','LDR Finish Conflicting with Cargo ') || ALL_LDR_FINISH.CARGO_NO
                    WHERE FORECAST_ID = v_forecast_id
                    AND CARGO_NO = COND_CARGOES.CARGO_NO
                    AND OBJECT_ID = COND_CARGOES.OBJECT_ID;
                END LOOP;
            END LOOP;
        END IF;
        --end edit tlxt
    END IF;

    --TLXT: work item 101063
    IF v_job_code = 'CT_WST_DAILY_UPG_MASS_ALLOC' OR v_job_code = 'CT_WST_MONTHLY_UPG_MASS_ALLOC'  THEN
        UE_CT_COND_INV_CP.CALCINVENTORY(v_end_date);
    END IF;

    ECDP_DYNSQL.WRITETEMPTEXT('UE_CALC_ENGIGNE', 'v_job_code='||v_job_code|| ' p_runno=' || p_runno || ' p_extra_params=' || p_extra_params ||  ' v_start_date=' ||v_start_date || ' v_end_date='||v_end_date);
END postDataWrite;


--<EC-DOC>
------------------------calcObjAttrFilter---------------------------------------------------------------------------
-- Function       : calcObjAttrFilter
-- Description    : Returns true if should be included
---------------------------------------------------------------------------------------------------
FUNCTION calcObjAttrFilter(
	p_startdate	DATE,                               /* Value of 'startdate' calc engine parameter */
	p_enddate	DATE,                               /* Value of 'enddate' calc engine parameter */
	p_object_type	VARCHAR2,                           /* Value of className */
	p_attr_name	VARCHAR2,                           /* Value of attribute name (sqlSyntax) */
	p_attr_value	VARCHAR2,                       /* Value of attribute */
	p_engineparams	Ecdp_Calculation.PARAM_MAP                       /* Value of calc engine parameter names semicolon separated */								  
	)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
	RETURN 'Y';
END calcObjAttrFilter;
END ue_calc_engine;
/