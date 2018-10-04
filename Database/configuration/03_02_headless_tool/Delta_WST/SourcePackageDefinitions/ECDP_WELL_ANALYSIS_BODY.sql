CREATE OR REPLACE PACKAGE BODY EcDp_Well_Analysis IS

/****************************************************************
** Package        :  EcDp_Well_Analysis, body part
**
** $Revision: 1.6 $
**
** Purpose        :  Defines well analysis.
**
** Documentation  :  www.energy-components.com
**
** Created  : 23.06.2008  Nurliza Jailuddin
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
** 1.0          23.06.08  JAILUNUR  ECDP-5638: Initial version
** 1.1          15.07.08  JAILUNUR  ECPD-5638: Added a call to the User Exit Ue_Well_Analysis
** 1.3          22.07.08  JAILUNUR  ECPD-5638: Add function ErrCond
** 1.4          12.05.09  leeeewei  ECPD-11664:Add support for validation against function attribute SUM (to verify is 100%)in runOilValidations and runGasValidations
**              21.08.09  leeeewei  ECPD-11894:Changes done to make sure records always get updated according to the result of the QA (unless the current status equals the new)
** 1.5          31.08.16  dhavaalo  ECPD-38607: Remove usage of EcDp_Utilities.executestatement and EcDp_Utilities.executeSinglerowNumber
** 1.6          19.10.16  singishi  ECPD-32618: Change all instances of UPDATE OBJECT_FLUID_ANALYSIS table to include both last_update_by and last_update_date for revision info
*****************************************************************/

  CURSOR c_well_oil_analysis (cp_nav_area_id VARCHAR2, cp_nav_sub_area_id VARCHAR2, cp_nav_fcty_1_id VARCHAR2, cp_nav_fcty_2_id VARCHAR2, cp_fromdate DATE, cp_todate DATE, cp_sampling_method VARCHAR2, cp_analysis_status VARCHAR2) IS
      SELECT * FROM object_fluid_analysis
      WHERE analysis_type = 'WELL_OIL_COMP'
      AND daytime BETWEEN cp_fromdate AND cp_todate
      AND daytime <> cp_todate
      AND object_id IN
          (SELECT object_id FROM well_version
          WHERE isproducer = 'Y'
          AND (op_area_id = cp_nav_area_id
          OR op_sub_area_id = cp_nav_sub_area_id
          OR op_fcty_class_1_id = cp_nav_fcty_1_id
          OR op_fcty_class_2_id = cp_nav_fcty_2_id))
      AND sampling_method = nvl(cp_sampling_method, sampling_method)
      AND analysis_status = nvl(cp_analysis_status, analysis_status);


  CURSOR c_attr_validation (cp_class_name VARCHAR2, cp_daytime DATE) IS
      SELECT * FROM class_attr_validation
      WHERE class_name = cp_class_name
      AND daytime <= cp_daytime
      AND nvl(end_date,cp_daytime+1) >= cp_daytime
      AND (warn_min is not null OR warn_max is not null OR warn_pct is not null
      OR err_conditional_ind is not null OR err_min is not null
      OR err_max is not null OR err_mandatory_ind is not null);


  CURSOR c_object_validation (cp_class_name VARCHAR2, cp_object_id VARCHAR2, cp_daytime DATE) IS
      SELECT * FROM object_attr_validation
      WHERE class_name = cp_class_name
      AND object_id = cp_object_id
      AND daytime <= cp_daytime
      AND nvl(end_date,cp_daytime+1) >= cp_daytime
      AND (warn_min is not null OR warn_max is not null OR warn_pct is not null
      OR err_conditional_ind is not null OR err_min is not null
      OR err_max is not null OR err_mandatory_ind is not null);


  CURSOR c_well_gas_analysis (cp_nav_area_id VARCHAR2, cp_nav_sub_area_id VARCHAR2, cp_nav_fcty_1_id VARCHAR2, cp_nav_fcty_2_id VARCHAR2, cp_fromdate DATE, cp_todate DATE, cp_sampling_method VARCHAR2, cp_analysis_status VARCHAR2) IS
    SELECT * FROM object_fluid_analysis
    WHERE analysis_type = 'WELL_GAS_COMP'
    AND daytime BETWEEN cp_fromdate AND cp_todate
    AND daytime <> cp_todate
    AND object_id IN
        (SELECT object_id FROM well_version
        WHERE isproducer = 'Y'
        AND (op_area_id = cp_nav_area_id
        OR op_sub_area_id = cp_nav_sub_area_id
        OR op_fcty_class_1_id = cp_nav_fcty_1_id
        OR op_fcty_class_2_id = cp_nav_fcty_2_id))
    AND sampling_method = nvl(cp_sampling_method, sampling_method)
    AND analysis_status = nvl(cp_analysis_status, analysis_status);

--------------------------------------------------------------------------------------------------------------------
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : executeStatement                                                          --
-- Description    : Used to run Dyanamic sql statements.
--                                                                                               --
-- Preconditions  :                --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                --
--                                                                                               --
-- Using functions:                                                 --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION executeStatement(
p_statement varchar2)

RETURN VARCHAR2
--</EC-DOC>
IS

li_cursor  integer;
li_ret_val  integer;
lv2_err_string VARCHAR2(32000);

BEGIN

   li_cursor := DBMS_SQL.open_cursor;

   DBMS_SQL.parse(li_cursor,p_statement,DBMS_SQL.v7);
   li_ret_val := DBMS_SQL.execute(li_cursor);
   DBMS_SQL.Close_Cursor(li_cursor);

  RETURN NULL;

EXCEPTION
   WHEN DUP_VAL_ON_INDEX THEN
       DBMS_SQL.Close_Cursor(li_cursor);

    -- record not inserted, already there...
    lv2_err_string := 'Failed to execute (record exists): ' || chr(10) || p_statement || chr(10);
    return lv2_err_string;
  WHEN INVALID_CURSOR THEN

    lv2_err_string := 'Failed to execute (' || SQLERRM || '): ' || chr(10) || p_statement || chr(10);
    return lv2_err_string;

  WHEN OTHERS THEN
    IF DBMS_SQL.is_open(li_cursor) THEN
      DBMS_SQL.Close_Cursor(li_cursor);
      END IF;

    lv2_err_string := 'Failed to execute (' || SQLERRM || '): ' || chr(10) || p_statement || chr(10);
    return lv2_err_string;

END executeStatement;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : executeSinglerowNumber                                                       --
-- Description    : Executes a dynamic SQL SELECT which returns 1 row of type NUMBER.            --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION executeSinglerowNumber(p_statement VARCHAR2) RETURN NUMBER
--</EC-DOC>
IS

li_cursor      INTEGER;
li_returverdi   INTEGER;
ln_return_value NUMBER;

BEGIN

   li_cursor := DBMS_SQL.Open_Cursor;

   DBMS_SQL.Parse(li_cursor,p_statement,DBMS_SQL.v7);
   DBMS_SQL.Define_Column(li_cursor,1,ln_return_value);

   li_returverdi := DBMS_SQL.Execute(li_cursor);

   IF DBMS_SQL.Fetch_Rows(li_cursor) = 0 THEN

     ln_return_value := NULL;

   ELSE

      DBMS_SQL.Column_Value(li_cursor,1, ln_return_value);

   END IF;

   DBMS_SQL.Close_Cursor(li_cursor);

   RETURN ln_return_value;

EXCEPTION

  WHEN OTHERS THEN

      IF  DBMS_SQL.is_open(li_cursor) THEN
         DBMS_SQL.Close_Cursor(li_cursor);
      END IF;

   RETURN NULL;

END executeSinglerowNumber;

PROCEDURE runQaAnalysis(
  p_nav_class_name VARCHAR2,
  p_nav_object_id VARCHAR2,
  p_fromdate DATE,
  p_todate DATE,
  p_sampling_method VARCHAR2,
  p_analysis_status VARCHAR2)

IS
  lv_status VARCHAR2(32);
  lv_nav_area_id VARCHAR2(32);
  lv_nav_sub_area_id VARCHAR2(32);
  lv_nav_fcty_1_id VARCHAR2(32);
  lv_nav_fcty_2_id VARCHAR2(32);
  lv_object_id VARCHAR2(32);
  ld_daytime DATE;
  ln_exists NUMBER;
  ln_analysis_no NUMBER;
  ln_exists_1 NUMBER;
  lv_sampling VARCHAR2(32);
  ln_exists_2 NUMBER;

BEGIN

    lv_nav_area_id := null;
    lv_nav_sub_area_id := null;
    lv_nav_fcty_1_id := null;
    lv_nav_fcty_2_id := null;


   IF p_nav_class_name = 'AREA' THEN
      lv_nav_area_id := p_nav_object_id;
   ELSIF p_nav_class_name = 'SUB_AREA' THEN
      lv_nav_sub_area_id := p_nav_object_id;
   ELSIF p_nav_class_name = 'FCTY_CLASS_1' THEN
      lv_nav_fcty_1_id := p_nav_object_id;
   ELSIF p_nav_class_name = 'FCTY_CLASS_2' THEN
      lv_nav_fcty_2_id := p_nav_object_id;
   END IF;

       Ecdp_Well_Analysis.runOilValidations(lv_nav_area_id, lv_nav_sub_area_id, lv_nav_fcty_1_id, lv_nav_fcty_2_id, p_fromdate, p_todate, p_sampling_method, p_analysis_status);
       Ecdp_Well_Analysis.runGasValidations(lv_nav_area_id, lv_nav_sub_area_id, lv_nav_fcty_1_id, lv_nav_fcty_2_id, p_fromdate, p_todate, p_sampling_method, p_analysis_status);

   FOR cur_well_oil_analysis IN c_well_oil_analysis(lv_nav_area_id, lv_nav_sub_area_id, lv_nav_fcty_1_id, lv_nav_fcty_2_id, p_fromdate, p_todate, p_sampling_method, p_analysis_status) LOOP
       lv_object_id := cur_well_oil_analysis.object_id;
       ld_daytime := cur_well_oil_analysis.daytime;
       ln_analysis_no := cur_well_oil_analysis.analysis_no;
       lv_status := cur_well_oil_analysis.analysis_status;
       lv_sampling := cur_well_oil_analysis.sampling_method;

         SELECT COUNT(*) INTO ln_exists FROM object_fluid_analysis WHERE analysis_type = 'WELL_GAS_COMP'
         AND object_id = lv_object_id AND daytime = ld_daytime AND sampling_method = lv_sampling;--  and analysis_status not in ('REJECTED');

       IF ln_exists > 0 THEN
          IF lv_status = 'APPROVED' THEN
                    UPDATE object_fluid_analysis
                           SET analysis_status = 'APPROVED',
                           record_status = 'A',
                           last_updated_by = Nvl(ecdp_context.getAppUser(),USER),
                           last_updated_date = Ecdp_Timestamp.getCurrentSysdate
                           WHERE object_id = lv_object_id
                           AND daytime = ld_daytime
                           AND sampling_method = lv_sampling
                           AND analysis_type = 'WELL_GAS_COMP'
                           AND analysis_status not in ('REJECTED', 'APPROVED');

          ELSIF lv_status = 'NEW' THEN
                    UPDATE object_fluid_analysis
                           SET analysis_status = 'APPROVED',
                           record_status = 'A',
                           last_updated_by = Nvl(ecdp_context.getAppUser(),USER),
                           last_updated_date = Ecdp_Timestamp.getCurrentSysdate
                           WHERE object_id = lv_object_id
                           AND daytime = ld_daytime
                           AND sampling_method = lv_sampling
                           AND analysis_status not in ('REJECTED', 'APPROVED');

           ELSIF lv_status = 'INFO' THEN
                    UPDATE object_fluid_analysis
                           SET analysis_status = 'APPROVED',
                           record_status = 'A',
                           last_updated_by = Nvl(ecdp_context.getAppUser(),USER),
                           last_updated_date = Ecdp_Timestamp.getCurrentSysdate
                           WHERE object_id = lv_object_id
                           AND daytime = ld_daytime
                           AND sampling_method = lv_sampling
                           AND analysis_status not in ('REJECTED', 'APPROVED');

           ELSIF lv_status = 'REJECTED' THEN
                    UPDATE object_fluid_analysis
                           SET analysis_status = 'REJECTED',
                           record_status = 'V',
                           comments = 'Due to Oil analysis being REJECTED',
                           last_updated_by = Nvl(ecdp_context.getAppUser(),USER),
                           last_updated_date = Ecdp_Timestamp.getCurrentSysdate
                           WHERE object_id = lv_object_id
                           AND daytime = ld_daytime
                           AND sampling_method = lv_sampling
                           AND analysis_type = 'WELL_GAS_COMP'
                           AND analysis_status <> 'REJECTED';

           END IF;

       ELSE
          UPDATE object_fluid_analysis
                 SET analysis_status = 'REJECTED',
                 record_status = 'V',
                 comments = 'Rejected, could not find more than one analysis for this date',
                 last_updated_by = Nvl(ecdp_context.getAppUser(),USER),
                 last_updated_date = Ecdp_Timestamp.getCurrentSysdate
                 WHERE analysis_no = ln_analysis_no
                 AND analysis_type = 'WELL_OIL_COMP';

       END IF;

       SELECT COUNT(*) INTO ln_exists_1 FROM object_fluid_analysis WHERE analysis_type = 'WELL_GAS_COMP'
       AND object_id = lv_object_id AND daytime = ld_daytime AND sampling_method = lv_sampling AND analysis_status = 'REJECTED';

       IF ln_exists_1 > 0 THEN
                      UPDATE object_fluid_analysis
                           SET analysis_status = 'REJECTED',
                           record_status = 'V',
                           comments = 'Due to Gas analysis being REJECTED',
                           last_updated_by = Nvl(ecdp_context.getAppUser(),USER),
                           last_updated_date = Ecdp_Timestamp.getCurrentSysdate
                           WHERE object_id = lv_object_id
                           AND daytime = ld_daytime
                           AND sampling_method = lv_sampling
                           AND analysis_type = 'WELL_OIL_COMP'
                           AND analysis_status not in ('REJECTED');
       END IF;

    END LOOP;

    FOR cur_well_gas_analysis IN c_well_gas_analysis(lv_nav_area_id, lv_nav_sub_area_id, lv_nav_fcty_1_id, lv_nav_fcty_2_id, p_fromdate, p_todate, p_sampling_method, p_analysis_status) LOOP
         lv_object_id := cur_well_gas_analysis.object_id;
         ld_daytime := cur_well_gas_analysis.daytime;
         ln_analysis_no := cur_well_gas_analysis.analysis_no;
         lv_status := cur_well_gas_analysis.analysis_status;
         lv_sampling := cur_well_gas_analysis.sampling_method;

         SELECT COUNT(*) INTO ln_exists_2 FROM object_fluid_analysis WHERE analysis_type = 'WELL_OIL_COMP'
         AND object_id = lv_object_id AND daytime = ld_daytime AND sampling_method = lv_sampling;

         IF ln_exists_2 = 0 THEN
            UPDATE object_fluid_analysis
                 SET analysis_status = 'REJECTED',
                 record_status = 'V',
                 comments = 'Rejected, could not find more than one analysis for this date',
                 last_updated_by = Nvl(ecdp_context.getAppUser(),USER),
                 last_updated_date = Ecdp_Timestamp.getCurrentSysdate
                 WHERE analysis_no = ln_analysis_no
                 AND analysis_type = 'WELL_GAS_COMP'
                 AND analysis_status <> 'REJECTED';

         END IF;

    END LOOP;

     Ue_Well_Analysis.runQAProcess(p_nav_class_name,p_nav_object_id,p_fromdate,p_todate,p_sampling_method,p_analysis_status);

END runQaAnalysis;

----------------------------------------------------------------------------------------------------------------------
PROCEDURE runOilValidations(
  p_area VARCHAR2,
  p_subarea VARCHAR2,
  p_fcty_1 VARCHAR2,
  p_fcty_2 VARCHAR2,
  p_fromdate DATE,
  p_todate DATE,
  p_sampling_method VARCHAR2,
  p_analysis_status VARCHAR2)

IS
  lv_status VARCHAR2(32);
  lv_object_id VARCHAR2(32);
  ld_daytime DATE;
  ln_analysis_no NUMBER;
  lv_sampling VARCHAR2(32);
  lv_attribute VARCHAR2(30);
  ln_warn_min NUMBER;
  ln_warn_max NUMBER;
  ln_warn_pct NUMBER;
  lv_err_cond VARCHAR2(1);
  ln_err_min NUMBER;
  ln_err_max NUMBER;
  lv_err_mand VARCHAR2(1);
  lv_col VARCHAR2(4000);
  ln_value NUMBER;
  lv_sql VARCHAR2(32000);
  lv_text VARCHAR2(32000);
  lv_text1 VARCHAR2 (32000);
  lv_result VARCHAR2 (32000);
  lv_condition VARCHAR2 (32000);

BEGIN

   FOR cur_well_oil_analysis IN c_well_oil_analysis(p_area, p_subarea, p_fcty_1, p_fcty_2, p_fromdate, p_todate, p_sampling_method, p_analysis_status) LOOP
       lv_object_id := cur_well_oil_analysis.object_id;
       ld_daytime := cur_well_oil_analysis.daytime;
       ln_analysis_no := cur_well_oil_analysis.analysis_no;
       lv_status := cur_well_oil_analysis.analysis_status;
       lv_sampling := cur_well_oil_analysis.sampling_method;

              ------- CLASS VALIDATIONS FOR WELL_OIL_COMP_QA  ----------
       lv_text := null;

       FOR cur_attr_validation IN c_attr_validation('WELL_OIL_COMP_QA', ld_daytime) LOOP
           lv_attribute := cur_attr_validation.attribute_name;
           ln_warn_min := cur_attr_validation.warn_min;
           ln_warn_max := cur_attr_validation.warn_max;
           ln_warn_pct := cur_attr_validation.warn_pct;
           lv_err_cond := cur_attr_validation.err_conditional_ind;
           ln_err_min := cur_attr_validation.err_min;
           ln_err_max := cur_attr_validation.err_max;
           lv_err_mand := cur_attr_validation.err_mandatory_ind;


           SELECT trim(db_sql_syntax) INTO lv_col from class_attribute_cnfg WHERE class_name='WELL_OIL_COMP_QA' AND attribute_name=lv_attribute;

           IF lv_col = 'BS_W' THEN
              ln_value := cur_well_oil_analysis.bs_w;
          ELSIF lv_col like 'ecdp_fluid_analysis.sumComponentsAnalysis%' THEN
              ln_value := ecdp_fluid_analysis.sumComponentsAnalysis(cur_well_oil_analysis.analysis_no);
           ELSIF lv_col = 'CNPL_MOL_WT' THEN
              ln_value := cur_well_oil_analysis.cnpl_mol_wt;
           ELSIF lv_col = 'MOL_WT' THEN
              ln_value := cur_well_oil_analysis.mol_wt;
           ELSIF lv_col = 'CNPL_SP_GRAV' THEN
              ln_value := cur_well_oil_analysis.cnpl_sp_grav;
           ELSIF lv_col = 'SP_GRAV' THEN
              ln_value := cur_well_oil_analysis.sp_grav;
           ELSIF lv_col = 'SALT' THEN
              ln_value := cur_well_oil_analysis.salt;
           ELSIF lv_col = 'GCV' THEN
              ln_value := cur_well_oil_analysis.gcv;
           ELSIF lv_col = 'C1_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_oil_analysis.analysis_no,'C1');
           ELSIF lv_col = 'C2_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_oil_analysis.analysis_no,'C2');
           ELSIF lv_col = 'C3_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_oil_analysis.analysis_no,'C3');
           ELSIF lv_col = 'C5PL_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_oil_analysis.analysis_no,'C5+');
           ELSIF lv_col = 'C6_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_oil_analysis.analysis_no,'C6');
           ELSIF lv_col = 'C7PL_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_oil_analysis.analysis_no,'C7+');
           ELSIF lv_col = 'CO2_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_oil_analysis.analysis_no,'CO2');
           ELSIF lv_col = 'IC4_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_oil_analysis.analysis_no,'IC4');
           ELSIF lv_col = 'IC5_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_oil_analysis.analysis_no,'IC5');
           ELSIF lv_col = 'N2_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_oil_analysis.analysis_no,'N2');
           ELSIF lv_col = 'NC4_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_oil_analysis.analysis_no,'NC4');
           ELSIF lv_col = 'NC5_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_oil_analysis.analysis_no,'NC5');
           ELSE
              ln_value := null;
           END IF;


              IF ln_warn_min IS NOT NULL THEN
                 lv_text1 := Ecdp_Well_Analysis.WarnMin('WELL_OIL_COMP',lv_attribute,ln_value,ln_analysis_no,ln_warn_min);
                 IF lv_text1 IS NOT NULL THEN
                    lv_text := lv_text || lv_text1 ||';';
                 END IF;
              END IF;
              IF ln_warn_max IS NOT NULL THEN
                 lv_text1 := Ecdp_Well_Analysis.WarnMax('WELL_OIL_COMP',lv_attribute,ln_value,ln_analysis_no,ln_warn_max);
                 IF lv_text1 IS NOT NULL THEN
                    lv_text := lv_text || lv_text1 ||';';
                 END IF;
              END IF;
              IF ln_warn_pct IS NOT NULL THEN
                 lv_text1 := Ecdp_Well_Analysis.WarnPct('WELL_OIL_COMP',lv_attribute,lv_col,ld_daytime,ln_value,lv_object_id,ln_warn_pct);
                 IF lv_text1 IS NOT NULL THEN
                    lv_text := lv_text || lv_text1 ||';';
                 END IF;
              END IF;
              IF lv_err_cond IS NOT NULL THEN
                 lv_text1 := Ecdp_Well_Analysis.ErrCond('WELL_OIL_COMP',lv_attribute,ln_value,ln_analysis_no,lv_err_cond);
                 IF lv_text1 IS NOT NULL THEN
                    lv_text := lv_text || lv_text1 || ';';
                 END IF;
              END IF;
              IF ln_err_min IS NOT NULL THEN
                 lv_text1 := Ecdp_Well_Analysis.ErrMin('WELL_OIL_COMP',lv_attribute,ln_value,ln_analysis_no,ln_err_min);
                 IF lv_text1 IS NOT NULL THEN
                    lv_text := lv_text || lv_text1 ||';';
                 END IF;
              END IF;
              IF ln_err_max IS NOT NULL THEN
                 lv_text1 := Ecdp_Well_Analysis.ErrMax('WELL_OIL_COMP',lv_attribute,ln_value,ln_analysis_no,ln_err_max);
                 IF lv_text1 IS NOT NULL THEN
                    lv_text := lv_text || lv_text1 ||';';
                 END IF;
              END IF;
              IF lv_err_mand IS NOT NULL THEN
                 lv_text1 := Ecdp_Well_Analysis.ErrMand('WELL_OIL_COMP',lv_attribute,ln_value,ln_analysis_no,lv_err_mand);
                 IF lv_text1 IS NOT NULL THEN
                    lv_text := lv_text || lv_text1 ||';';
                 END IF;
              END IF;

       END LOOP;

       ------------- OBJECT VALIDATION FOR WELL_OIL_COMP_QA --------------------------------

       FOR cur_object_validation IN c_object_validation('WELL_OIL_COMP_QA', lv_object_id, ld_daytime) LOOP
           lv_attribute := cur_object_validation.attribute_name;
           ln_warn_min := cur_object_validation.warn_min;
           ln_warn_max := cur_object_validation.warn_max;
           ln_warn_pct := cur_object_validation.warn_pct;
           lv_err_cond := cur_object_validation.err_conditional_ind;
           ln_err_min := cur_object_validation.err_min;
           ln_err_max := cur_object_validation.err_max;
           lv_err_mand := cur_object_validation.err_mandatory_ind;

           SELECT db_sql_syntax INTO lv_col from class_attribute_cnfg WHERE class_name='WELL_OIL_COMP_QA' AND attribute_name=lv_attribute;


           IF lv_col = 'BS_W' THEN
              ln_value := cur_well_oil_analysis.bs_w;
           ELSIF lv_col like 'ecdp_fluid_analysis.sumComponentsAnalysis%' THEN
              ln_value := ecdp_fluid_analysis.sumComponentsAnalysis(cur_well_oil_analysis.analysis_no);
           ELSIF lv_col = 'CNPL_MOL_WT' THEN
              ln_value := cur_well_oil_analysis.cnpl_mol_wt;
           ELSIF lv_col = 'MOL_WT' THEN
              ln_value := cur_well_oil_analysis.mol_wt;
           ELSIF lv_col = 'CNPL_SP_GRAV' THEN
              ln_value := cur_well_oil_analysis.cnpl_sp_grav;
           ELSIF lv_col = 'SP_GRAV' THEN
              ln_value := cur_well_oil_analysis.sp_grav;
           ELSIF lv_col = 'SALT' THEN
              ln_value := cur_well_oil_analysis.salt;
           ELSIF lv_col = 'GCV' THEN
              ln_value := cur_well_oil_analysis.gcv;
           ELSIF lv_col = 'C1_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_oil_analysis.analysis_no,'C1');
           ELSIF lv_col = 'C2_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_oil_analysis.analysis_no,'C2');
           ELSIF lv_col = 'C3_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_oil_analysis.analysis_no,'C3');
           ELSIF lv_col = 'C5PL_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_oil_analysis.analysis_no,'C5+');
           ELSIF lv_col = 'C6_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_oil_analysis.analysis_no,'C6');
           ELSIF lv_col = 'C7PL_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_oil_analysis.analysis_no,'C7+');
           ELSIF lv_col = 'CO2_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_oil_analysis.analysis_no,'CO2');
           ELSIF lv_col = 'IC4_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_oil_analysis.analysis_no,'IC4');
           ELSIF lv_col = 'IC5_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_oil_analysis.analysis_no,'IC5');
           ELSIF lv_col = 'N2_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_oil_analysis.analysis_no,'N2');
           ELSIF lv_col = 'NC4_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_oil_analysis.analysis_no,'NC4');
           ELSIF lv_col = 'NC5_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_oil_analysis.analysis_no,'NC5');
           ELSE
              ln_value := null;
           END IF;

              IF ln_warn_min IS NOT NULL THEN
                 lv_text1 := Ecdp_Well_Analysis.WarnMin('WELL_OIL_COMP',lv_attribute,ln_value,ln_analysis_no,ln_warn_min);
                 IF lv_text1 IS NOT NULL THEN
                    lv_text := lv_text || lv_text1 ||';';
                 END IF;
              END IF;
              IF ln_warn_max IS NOT NULL THEN
                 lv_text1 := Ecdp_Well_Analysis.WarnMax('WELL_OIL_COMP',lv_attribute,ln_value,ln_analysis_no,ln_warn_max);
                 IF lv_text1 IS NOT NULL THEN
                    lv_text := lv_text || lv_text1 ||';';
                 END IF;
              END IF;
              IF ln_warn_pct IS NOT NULL THEN
                 lv_text1 := Ecdp_Well_Analysis.WarnPct('WELL_OIL_COMP',lv_attribute,lv_col,ld_daytime,ln_value,lv_object_id,ln_warn_pct);
                 IF lv_text1 IS NOT NULL THEN
                    lv_text := lv_text || lv_text1 ||';';
                 END IF;
              IF lv_err_cond IS NOT NULL THEN
                 lv_text1 := Ecdp_Well_Analysis.ErrCond('WELL_OIL_COMP',lv_attribute,ln_value,ln_analysis_no,lv_err_cond);
                 IF lv_text1 IS NOT NULL THEN
                    lv_text := lv_text || lv_text1 || ';';
                 END IF;
              END IF;
              END IF;
              IF ln_err_min IS NOT NULL THEN
                 lv_text1 := Ecdp_Well_Analysis.ErrMin('WELL_OIL_COMP',lv_attribute,ln_value,ln_analysis_no,ln_err_min);
                 IF lv_text1 IS NOT NULL THEN
                    lv_text := lv_text || lv_text1 ||';';
                 END IF;
              END IF;
              IF ln_err_max IS NOT NULL THEN
                 lv_text1 := Ecdp_Well_Analysis.ErrMax('WELL_OIL_COMP',lv_attribute,ln_value,ln_analysis_no,ln_err_max);
                 IF lv_text1 IS NOT NULL THEN
                    lv_text := lv_text || lv_text1 ||';';
                 END IF;
              END IF;
              IF lv_err_mand IS NOT NULL THEN
                 lv_text1 := Ecdp_Well_Analysis.ErrMand('WELL_OIL_COMP',lv_attribute,ln_value,ln_analysis_no,lv_err_mand);
                 IF lv_text1 IS NOT NULL THEN
                    lv_text := lv_text || lv_text1 ||';';
                 END IF;
              END IF;

         END LOOP;

		--IF statement below has been extended to update record in any case
             IF lv_text IS NOT NULL THEN
					lv_sql := 'UPDATE object_fluid_analysis
                               SET ANALYSIS_STATUS =''REJECTED'',comments = '''||lv_text||'''
                               WHERE analysis_no = '||ln_analysis_no||'';
         ELSE
                lv_sql := 'UPDATE object_fluid_analysis
                                  SET ANALYSIS_STATUS =''APPROVED'',comments = NULL
                                  WHERE analysis_no = '||ln_analysis_no||'';
         END IF;
        --IF statement below has been extended to update record in any case
             IF lv_text IS NOT NULL THEN
                   lv_sql := 'UPDATE object_fluid_analysis
                              SET ANALYSIS_STATUS =''REJECTED'',comments = '''||lv_text||''',
                              last_updated_by = '''||Nvl(ecdp_context.getAppUser(),USER)||''',
                              last_updated_date = to_date('''|| to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')||''' , ''YYYY-MM-DD"T"HH24:MI:SS'')
                              WHERE analysis_no = '||ln_analysis_no||'';
            ELSE
                   lv_sql := 'UPDATE object_fluid_analysis
                              SET ANALYSIS_STATUS =''APPROVED'',comments = NULL,
                              last_updated_by = '''||Nvl(ecdp_context.getAppUser(),USER)||''',
                              last_updated_date = to_date('''|| to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')||''' , ''YYYY-MM-DD"T"HH24:MI:SS'')
                              WHERE analysis_no = '||ln_analysis_no||'';
            END IF;

         lv_result := executeStatement(lv_sql);

    END LOOP;


END runOilValidations;

----------------------------------------------------------------------------------------------------------------------
PROCEDURE runGasValidations(
  p_area VARCHAR2,
  p_subarea VARCHAR2,
  p_fcty_1 VARCHAR2,
  p_fcty_2 VARCHAR2,
  p_fromdate DATE,
  p_todate DATE,
  p_sampling_method VARCHAR2,
  p_analysis_status VARCHAR2)

IS
  lv_status VARCHAR2(32);
  lv_object_id VARCHAR2(32);
  ld_daytime DATE;
  ln_analysis_no NUMBER;
  lv_sampling VARCHAR2(32);
  lv_attribute VARCHAR2(24);
  ln_warn_min NUMBER;
  ln_warn_max NUMBER;
  ln_warn_pct NUMBER;
  lv_err_cond VARCHAR2(1);
  ln_err_min NUMBER;
  ln_err_max NUMBER;
  lv_err_mand VARCHAR2(1);
  lv_col VARCHAR2(100);
  ln_value NUMBER;
  lv_sql VARCHAR2(32000);
  lv_text VARCHAR2(32000);
  lv_text1 VARCHAR2(32000);
  lv_result VARCHAR2 (32000);
  lv_condition VARCHAR2 (32000);

BEGIN

   FOR cur_well_gas_analysis IN c_well_gas_analysis(p_area, p_subarea, p_fcty_1, p_fcty_2, p_fromdate, p_todate, p_sampling_method, p_analysis_status) LOOP
       lv_object_id := cur_well_gas_analysis.object_id;
       ld_daytime := cur_well_gas_analysis.daytime;
       ln_analysis_no := cur_well_gas_analysis.analysis_no;
       lv_status := cur_well_gas_analysis.analysis_status;
       lv_sampling := cur_well_gas_analysis.sampling_method;

                ------- CLASS VALIDATIONS FOR WELL_GAS_COMP_QA  ----------
       lv_text := null;

       FOR cur_attr_validation IN c_attr_validation('WELL_GAS_COMP_QA', ld_daytime) LOOP
           lv_attribute := cur_attr_validation.attribute_name;
           ln_warn_min := cur_attr_validation.warn_min;
           ln_warn_max := cur_attr_validation.warn_max;
           ln_warn_pct := cur_attr_validation.warn_pct;
           lv_err_cond := cur_attr_validation.err_conditional_ind;
           ln_err_min := cur_attr_validation.err_min;
           ln_err_max := cur_attr_validation.err_max;
           lv_err_mand := cur_attr_validation.err_mandatory_ind;


           SELECT db_sql_syntax INTO lv_col from class_attribute_cnfg WHERE class_name='WELL_GAS_COMP_QA' AND attribute_name=lv_attribute;


           IF lv_col = 'BS_W' THEN
              ln_value := cur_well_gas_analysis.bs_w;
           ELSIF lv_col like 'ecdp_fluid_analysis.sumComponentsAnalysis%' THEN
              ln_value := ecdp_fluid_analysis.sumComponentsAnalysis(cur_well_gas_analysis.analysis_no);
           ELSIF lv_col = 'CNPL_MOL_WT' THEN
              ln_value := cur_well_gas_analysis.cnpl_mol_wt;
           ELSIF lv_col = 'MOL_WT' THEN
              ln_value := cur_well_gas_analysis.mol_wt;
           ELSIF lv_col = 'CNPL_SP_GRAV' THEN
              ln_value := cur_well_gas_analysis.cnpl_sp_grav;
           ELSIF lv_col = 'SP_GRAV' THEN
              ln_value := cur_well_gas_analysis.sp_grav;
           ELSIF lv_col = 'SALT' THEN
              ln_value := cur_well_gas_analysis.salt;
           ELSIF lv_col = 'GCV' THEN
              ln_value := cur_well_gas_analysis.gcv;
           ELSIF lv_col = 'C1_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_gas_analysis.analysis_no,'C1');
           ELSIF lv_col = 'C2_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_gas_analysis.analysis_no,'C2');
           ELSIF lv_col = 'C3_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_gas_analysis.analysis_no,'C3');
           ELSIF lv_col = 'C5PL_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_gas_analysis.analysis_no,'C5+');
           ELSIF lv_col = 'C6_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_gas_analysis.analysis_no,'C6');
           ELSIF lv_col = 'C7PL_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_gas_analysis.analysis_no,'C7+');
           ELSIF lv_col = 'CO2_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_gas_analysis.analysis_no,'CO2');
           ELSIF lv_col = 'IC4_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_gas_analysis.analysis_no,'IC4');
           ELSIF lv_col = 'IC5_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_gas_analysis.analysis_no,'IC5');
           ELSIF lv_col = 'N2_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_gas_analysis.analysis_no,'N2');
           ELSIF lv_col = 'NC4_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_gas_analysis.analysis_no,'NC4');
           ELSIF lv_col = 'NC5_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_gas_analysis.analysis_no,'NC5');
           ELSE
              ln_value := null;
           END IF;

              IF ln_warn_min IS NOT NULL THEN
                 lv_text1 := Ecdp_Well_Analysis.WarnMin('WELL_GAS_COMP',lv_attribute,ln_value,ln_analysis_no,ln_warn_min);
                 IF lv_text1 IS NOT NULL THEN
                    lv_text := lv_text || lv_text1 || ';';
                 END IF;
              END IF;
              IF ln_warn_max IS NOT NULL THEN
                 lv_text1 := Ecdp_Well_Analysis.WarnMax('WELL_GAS_COMP',lv_attribute,ln_value,ln_analysis_no,ln_warn_max);
                 IF lv_text1 IS NOT NULL THEN
                    lv_text := lv_text || lv_text1 || ';';
                 END IF;
              END IF;
              IF ln_warn_pct IS NOT NULL THEN
                 lv_text1 := Ecdp_Well_Analysis.WarnPct('WELL_GAS_COMP',lv_attribute,lv_col,ld_daytime,ln_value,lv_object_id,ln_warn_pct);
                 IF lv_text1 IS NOT NULL THEN
                    lv_text := lv_text || lv_text1 || ';';
                 END IF;
              END IF;
              IF lv_err_cond IS NOT NULL THEN
                 lv_text1 := Ecdp_Well_Analysis.ErrCond('WELL_GAS_COMP',lv_attribute,ln_value,ln_analysis_no,lv_err_cond);
                 IF lv_text1 IS NOT NULL THEN
                    lv_text := lv_text || lv_text1 || ';';
                 END IF;
              END IF;
              IF ln_err_min IS NOT NULL THEN
                 lv_text1 := Ecdp_Well_Analysis.ErrMin('WELL_GAS_COMP',lv_attribute,ln_value,ln_analysis_no,ln_err_min);
                 IF lv_text1 IS NOT NULL THEN
                    lv_text := lv_text || lv_text1 || ';';
                 END IF;
               END IF;
              IF ln_err_max IS NOT NULL THEN
                 lv_text1 := Ecdp_Well_Analysis.ErrMax('WELL_GAS_COMP',lv_attribute,ln_value,ln_analysis_no,ln_err_max);
                 IF lv_text1 IS NOT NULL THEN
                    lv_text := lv_text || lv_text1 || ';';
                 END IF;
              END IF;
              IF lv_err_mand IS NOT NULL THEN
                 lv_text1 := Ecdp_Well_Analysis.ErrMand('WELL_GAS_COMP',lv_attribute,ln_value,ln_analysis_no,lv_err_mand);
                 IF lv_text1 IS NOT NULL THEN
                    lv_text := lv_text || lv_text1 || ';';
                 END IF;
              END IF;

       END LOOP;


       ------------- OBJECT VALIDATION FOR WELL_GAS_COMP_QA --------------------------------

       FOR cur_object_validation IN c_object_validation('WELL_GAS_COMP_QA', lv_object_id, ld_daytime) LOOP
           lv_attribute := cur_object_validation.attribute_name;
           ln_warn_min := cur_object_validation.warn_min;
           ln_warn_max := cur_object_validation.warn_max;
           ln_warn_pct := cur_object_validation.warn_pct;
           lv_err_cond := cur_object_validation.err_conditional_ind;
           ln_err_min := cur_object_validation.err_min;
           ln_err_max := cur_object_validation.err_max;
           lv_err_mand := cur_object_validation.err_mandatory_ind;

           SELECT db_sql_syntax INTO lv_col from class_attribute_cnfg WHERE class_name='WELL_GAS_COMP_QA' AND attribute_name=lv_attribute;


           IF lv_col = 'BS_W' THEN
              ln_value := cur_well_gas_analysis.bs_w;
           ELSIF lv_col like 'ecdp_fluid_analysis.sumComponentsAnalysis%' THEN
              ln_value := ecdp_fluid_analysis.sumComponentsAnalysis(cur_well_gas_analysis.analysis_no);
           ELSIF lv_col = 'CNPL_MOL_WT' THEN
              ln_value := cur_well_gas_analysis.cnpl_mol_wt;
           ELSIF lv_col = 'MOL_WT' THEN
              ln_value := cur_well_gas_analysis.mol_wt;
           ELSIF lv_col = 'CNPL_SP_GRAV' THEN
              ln_value := cur_well_gas_analysis.cnpl_sp_grav;
           ELSIF lv_col = 'SP_GRAV' THEN
              ln_value := cur_well_gas_analysis.sp_grav;
           ELSIF lv_col = 'SALT' THEN
              ln_value := cur_well_gas_analysis.salt;
           ELSIF lv_col = 'GCV' THEN
              ln_value := cur_well_gas_analysis.gcv;
           ELSIF lv_col = 'C1_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_gas_analysis.analysis_no,'C1');
           ELSIF lv_col = 'C2_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_gas_analysis.analysis_no,'C2');
           ELSIF lv_col = 'C3_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_gas_analysis.analysis_no,'C3');
           ELSIF lv_col = 'C5PL_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_gas_analysis.analysis_no,'C5+');
           ELSIF lv_col = 'C6_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_gas_analysis.analysis_no,'C6');
           ELSIF lv_col = 'C7PL_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_gas_analysis.analysis_no,'C7+');
           ELSIF lv_col = 'CO2_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_gas_analysis.analysis_no,'CO2');
           ELSIF lv_col = 'IC4_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_gas_analysis.analysis_no,'IC4');
           ELSIF lv_col = 'IC5_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_gas_analysis.analysis_no,'IC5');
           ELSIF lv_col = 'N2_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_gas_analysis.analysis_no,'N2');
           ELSIF lv_col = 'NC4_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_gas_analysis.analysis_no,'NC4');
           ELSIF lv_col = 'NC5_WT_PCT' THEN
              ln_value := ec_fluid_analysis_component.wt_pct(cur_well_gas_analysis.analysis_no,'NC5');
           ELSE
              ln_value := null;
           END IF;

              IF ln_warn_min IS NOT NULL THEN
                 lv_text1 := Ecdp_Well_Analysis.WarnMin('WELL_GAS_COMP',lv_attribute,ln_value,ln_analysis_no,ln_warn_min);
                 IF lv_text1 IS NOT NULL THEN
                    lv_text := lv_text || lv_text1 || ';';
                 END IF;
              END IF;
              IF ln_warn_max IS NOT NULL THEN
                 lv_text1 := Ecdp_Well_Analysis.WarnMax('WELL_GAS_COMP',lv_attribute,ln_value,ln_analysis_no,ln_warn_max);
                 IF lv_text1 IS NOT NULL THEN
                    lv_text := lv_text || lv_text1 || ';';
                 END IF;
              END IF;
              IF ln_warn_pct IS NOT NULL THEN
                 lv_text1 := Ecdp_Well_Analysis.WarnPct('WELL_GAS_COMP',lv_attribute,lv_col,ld_daytime,ln_value,lv_object_id,ln_warn_pct);
                 IF lv_text1 IS NOT NULL THEN
                    lv_text := lv_text || lv_text1 || ';';
                 END IF;
              END IF;
              IF lv_err_cond IS NOT NULL THEN
                 lv_text1 := Ecdp_Well_Analysis.ErrCond('WELL_GAS_COMP',lv_attribute,ln_value,ln_analysis_no,lv_err_cond);
                 IF lv_text1 IS NOT NULL THEN
                    lv_text := lv_text || lv_text1 || ';';
                 END IF;
              END IF;
              IF ln_err_min IS NOT NULL THEN
                 lv_text1 := Ecdp_Well_Analysis.ErrMin('WELL_GAS_COMP',lv_attribute,ln_value,ln_analysis_no,ln_err_min);
                 IF lv_text1 IS NOT NULL THEN
                    lv_text := lv_text || lv_text1 || ';';
                 END IF;
              END IF;
              IF ln_err_max IS NOT NULL THEN
                 lv_text1 := Ecdp_Well_Analysis.ErrMax('WELL_GAS_COMP',lv_attribute,ln_value,ln_analysis_no,ln_err_max);
                 IF lv_text1 IS NOT NULL THEN
                    lv_text := lv_text || lv_text1 || ';';
                 END IF;
              END IF;
              IF lv_err_mand IS NOT NULL THEN
                 lv_text1 := Ecdp_Well_Analysis.ErrMand('WELL_GAS_COMP',lv_attribute,ln_value,ln_analysis_no,lv_err_mand);
                 IF lv_text1 IS NOT NULL THEN
                    lv_text := lv_text || lv_text1 || ';';
                 END IF;
              END IF;

          END LOOP;

	--IF statement below has been extended to update record in any case
          IF lv_text IS NOT NULL THEN
                lv_sql := 'UPDATE object_fluid_analysis
                                  SET ANALYSIS_STATUS =''REJECTED'',comments = '''||lv_text||'''
                                  WHERE analysis_no = '||ln_analysis_no||'';
          ELSE
                lv_sql := 'UPDATE object_fluid_analysis
                                  SET ANALYSIS_STATUS =''APPROVED'',comments = NULL
                                  WHERE analysis_no = '||ln_analysis_no||'';
          END IF;

          lv_result := executeStatement(lv_sql);

    END LOOP;


END runGasValidations;
-----------------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION WarnMin(
      p_analysis_type VARCHAR2,
      p_attribute VARCHAR2,
      p_value NUMBER,
      p_analysis_no NUMBER,
      p_val_limit NUMBER)

RETURN VARCHAR2
IS
      lv_return   VARCHAR2(300);
BEGIN
       IF p_value < p_val_limit THEN
         lv_return := 'Warning-below min limit for ' ||p_attribute||'';
       END IF;

      RETURN lv_return;

END WarnMin;

----------------------------------------------------------------------------------------------------------------------

FUNCTION WarnMax(
      p_analysis_type VARCHAR2,
      p_attribute VARCHAR2,
      p_value NUMBER,
      p_analysis_no NUMBER,
      p_val_limit NUMBER)

RETURN VARCHAR2
IS
         lv_return   VARCHAR2(300);
BEGIN
         IF p_value > p_val_limit THEN
          lv_return := 'Warning-above max limit for ' ||p_attribute||'';
         END IF;
     RETURN lv_return;
END WarnMax;

----------------------------------------------------------------------------------------------------------------------

FUNCTION WarnPct(
      p_analysis_type VARCHAR2,
      p_attribute VARCHAR2,
      p_column VARCHAR2,
      p_daytime DATE,
      p_value NUMBER,
      p_object_id VARCHAR2,
      p_val_limit NUMBER)

RETURN VARCHAR2
IS
         lv_return VARCHAR2(300);

         ln_compare NUMBER;
         lv_sqlpct VARCHAR2(3200);
         ln_min NUMBER;
         ln_max NUMBER;

BEGIN
         lv_sqlpct := 'SELECT '||p_column||' FROM V_'||p_analysis_type||'_QA
                WHERE object_id = '''||p_object_id||'''
                AND daytime =
                      (SELECT MAX(daytime) FROM object_fluid_analysis
                      WHERE object_id = '''||p_object_id||'''
                      AND analysis_type = '''||p_analysis_type||'''
                      AND '||p_column||' IS NOT NULL
                      AND daytime < '''||p_daytime||''')';

         ln_compare := executeSinglerowNumber(lv_sqlpct);

         IF ln_compare IS NOT NULL THEN
            ln_min := ln_compare - (ln_compare * p_val_limit);
            ln_max := ln_compare + (ln_compare * p_val_limit);

            IF abs(p_value - ln_compare) < ln_min THEN
               lv_return := 'Warning-below min % limit for '||p_attribute||'';
            ELSIF abs(p_value - ln_compare) > ln_max THEN
               lv_return := 'Warning-above max % limit for '||p_attribute||'';

            END IF;
         END IF;

     RETURN lv_return;
END WarnPct;

----------------------------------------------------------------------------------------------------------------------

FUNCTION ErrCond(
      p_analysis_type VARCHAR2,
      p_attribute VARCHAR2,
      p_value NUMBER,
      p_analysis_no NUMBER,
      p_cond VARCHAR2)

RETURN VARCHAR2
IS
      lv_return   VARCHAR2(300);
BEGIN
      IF p_cond = 'Y' THEN
             IF p_value < 10 OR p_value > 100 THEN
              UPDATE object_fluid_analysis
                               SET analysis_status = 'REJECTED',
                               record_status = 'V',
                               last_updated_by = Nvl(ecdp_context.getAppUser(),USER),
                               last_updated_date = Ecdp_Timestamp.getCurrentSysdate
                               WHERE analysis_no = p_analysis_no;

              lv_return := 'Error limits (min 10 max 100) for '||p_attribute||' exceeded';
             END IF;
      END IF;
              RETURN lv_return;

END ErrCond;

----------------------------------------------------------------------------------------------------------------------

FUNCTION ErrMin(
      p_analysis_type VARCHAR2,
      p_attribute VARCHAR2,
      p_value NUMBER,
      p_analysis_no NUMBER,
      p_val_limit NUMBER)
RETURN VARCHAR2
IS
      lv_return VARCHAR2(300);
BEGIN
         IF p_value < p_val_limit THEN

             UPDATE object_fluid_analysis
                   SET analysis_status = 'REJECTED',
                   record_status = 'V',
                   last_updated_by = Nvl(ecdp_context.getAppUser(),USER),
                   last_updated_date = Ecdp_Timestamp.getCurrentSysdate
             WHERE analysis_no = p_analysis_no;

             lv_return := 'Error-below min limit for '||p_attribute||'';

         END IF;

             RETURN lv_return;

END ErrMin;

----------------------------------------------------------------------------------------------------------------------

FUNCTION ErrMax(
      p_analysis_type VARCHAR2,
      p_attribute VARCHAR2,
      p_value NUMBER,
      p_analysis_no NUMBER,
      p_val_limit NUMBER)
RETURN VARCHAR2
IS
      lv_return VARCHAR2(300);
BEGIN
         IF p_value > p_val_limit THEN

                    UPDATE object_fluid_analysis
                           SET analysis_status = 'REJECTED',
                           record_status = 'V',
                           last_updated_by = Nvl(ecdp_context.getAppUser(),USER),
                           last_updated_date = Ecdp_Timestamp.getCurrentSysdate
                           WHERE analysis_no = p_analysis_no;

                    lv_return := 'Error-above max limit for '||p_attribute||'';
         END IF;
              RETURN lv_return;
END ErrMax;

----------------------------------------------------------------------------------------------------------------------

FUNCTION ErrMand(
      p_analysis_type VARCHAR2,
      p_attribute VARCHAR2,
      p_value NUMBER,
      p_analysis_no NUMBER,
      p_cond VARCHAR2)
RETURN VARCHAR2
IS
       lv_return VARCHAR2(300);
BEGIN
         IF p_cond = 'Y' THEN
             IF p_value IS NULL THEN
              UPDATE object_fluid_analysis
                               SET analysis_status = 'REJECTED',
                               record_status = 'V',
                               last_updated_by = Nvl(ecdp_context.getAppUser(),USER),
                               last_updated_date = Ecdp_Timestamp.getCurrentSysdate
                               WHERE analysis_no = p_analysis_no;

              lv_return := 'Error-the '||p_attribute||' field is mandatory';
             END IF;
         END IF;
              RETURN lv_return;

END ErrMand;


END EcDp_Well_Analysis;