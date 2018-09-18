CREATE OR REPLACE PACKAGE BODY EcDp_Performance_Lock IS
/****************************************************************
** Package        :  EcDp_Performance_Lock, head part
**
** $Revision: 1.18 $
**
** Purpose        :  Locking procedures for Performance Test classes
**
** Documentation  :  www.energy-components.com
**
** Created  : 14.12.2005 Arild Vervik
**
** Modification history:
**
** Date       Whom    Change description:
** ------     -----   ---------------------------------------------------------------------
** 17.02.2009 leongsei ECPD-6067: Added local month lock checking to function CheckLockPerformanceCurve, DetectDependentPerfCurveLock.
**                                Fixed bug on function CheckLockPerformanceCurve, to return AccessNumber instead of AccessVarChar2 value for curve_id
** 10.04.2009 leongsei ECPD-6067: Modified function CheckLockProductionTest for local lock checking
** 22.04.2009 leongsei ECPD-6067: Modified function CheckLockProdTestAllStatus for global lock
** 06.08.2009 Leongwen ECPD-11910 PT.0003 - Locking in Performance Curve screen is not working for Third Axis, Curve Points and Co-efficients.
**										 Changed the datatype assignment from [column_data.AccessVarChar2] to [column_data.AccessNumber] for id below
**                     ln_n_curve_id       := l_new('CURVE_ID').column_data.AccessNumber;
**                     ln_o_curve_id       := l_old('CURVE_ID').column_data.AccessNumber;
**										 Also, check the table name for CURVE and CURVE_POINT to assign the perf_curve_id
** 28-01-2011 leongwen ECDP-16574: To correct and enhance the screens which are affected by the changes made in ECPD-16525.
*************************************************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GreatestApproachMethod
-- Description    : Find the logical highest ApproachMethod for given well in given period
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : WELL_VERSION
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior       :
--                 Logical hierarcky starting with highest ApproachMethod
--                 1. Ecdp_Calc_Method.INTERPOLATE_EXTRAPOLATE
--                 2. Ecdp_Calc_Method.EXTRAPOLATE
--                 3. Ecdp_Calc_Method.STEPPED
--
---------------------------------------------------------------------------------------------------
FUNCTION GreatestApproachMethod(p_well_id VARCHAR2, p_from_date DATE, p_to_date DATE) RETURN VARCHAR2
--</EC-DOC>

IS
  CURSOR c_well_version IS
  SELECT DISTINCT Nvl(approach_method, Ecdp_Calc_Method.STEPPED) approach_method
  FROM  well_version wv
  WHERE object_id = p_well_id
  AND   daytime <= p_to_date AND Nvl(end_date,p_from_date+1) > p_from_date;

  lv2_approach_method well_version.approach_method%TYPE := Ecdp_Calc_Method.STEPPED ;

BEGIN

   FOR cur IN c_well_version LOOP

     IF cur.approach_method <> Ecdp_Calc_Method.STEPPED AND lv2_approach_method = Ecdp_Calc_Method.STEPPED THEN

       lv2_approach_method := cur.approach_method;

     ELSIF cur.approach_method = EcDp_Calc_Method.INTERPOLATE_EXTRAPOLATE THEN

       lv2_approach_method := cur.approach_method;

     END IF;

   END LOOP;

   RETURN lv2_approach_method;

END;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : DetectDependentLock
-- Description    : Used to find if a period is locked because the previous or next test for a primary
--                  well (or in the future also flowline) is in a locked period.
--
--
-- Preconditions  : It is the caller that is resposible for setting the correct old and new values (see under behaviour).
-- Postconditions :
--
-- Using tables   : pwel_result, well_version
--
--
--
-- Using functions: GreatestApproachMethod
--
-- Configuration
-- required       :
--
-- Behavior       : Currently this indirect locking is only based on primary wells linked to the test
--                  In the future it will probably also need to check primary flowlines.
--                  Not there can be more than 1 primary well, so we need to loop and validate previous and
--                  next for each of them.
--
--                  The calling procedure will only be CheckLockProductionTest, but that one again can be called
--                  from 32 different Instead of triggers, but the classes "ending up here" will be linked to
--                  tables, PTST_RESULT, EQPM_RESULT, PWEL_RESULT, PFLW_RESULT. It is the procedure CheckLockProductionTest
--                  that is resposible for setting the correct old and new values that is given, so the check here gives meaning
--                  related to the given operation
--
--                  Under are listing of the cases identified, that should be handled by this procedure
--
--                  Direct operations on PTST_RESULT
--                  --------------------------------
--                  1. Insert:  Since there can not possibly be any assosiated wells at this stage, no validation will be done (no rows in cursor).
--                  2. Update:  The most interesting cases are setting valid_from_date or status, usually this can be validated by checking if
--                              delete with old values and insert with new values. The only exception is changing of only valid_from_date, here
--                              should make an exception and allow moving valid_from_date within a unlocked period, as long as it does not affects
--                              any locked period.
--                  3. Delete:  Can be validated if there are dependent objects, since we are currently not using cascading delete, it means that
--                              if it can be validated, delete will be stopped anyway by FK constraints. But no damage done by keeping it, so no
--                              point in and making an exceptions.
--
--                  Operations on EQPM_RESULT, PWEL_RESULT, PFLW_RESULT
--                  ---------------------------------------------------------
--                  In many ways this can be considered as updates to the logical PT unit even if it is an Insert or Delete, but it still makes sence
--                  to know the original operation, because an update on these tables are more complex, since it can (at least in theory) move a result row
--                  from one "old" to a "new" Performance test. In that sence a Insert and Delete are simpler. So it is important that the caller procedure
--                  gives the correct old result_no (p_o_result_no), status and valid from date.
--
--                  1. Insert:  The check only need to take into account the new result_no, status and valid_from_date.
--                  2. Update:  Again use the delete-,insert- check approach, there should be no exception checks needed here.
--                  3. Delete:  The check only need to take into account the old result_no, status and valid_from_date


---------------------------------------------------------------------------------------------------
PROCEDURE  DetectDependentLock(p_operation         VARCHAR2,
                               p_n_result_no       NUMBER,
                               p_o_result_no       NUMBER,
                               p_n_status          VARCHAR2,
                               p_o_status          VARCHAR2,
                               p_n_valid_from_date DATE,
                               p_o_valid_from_date DATE,
                               p_id                VARCHAR2,
                               p_dt_exception      BOOLEAN,
                               p_n_primary_well    VARCHAR2,
                               p_well_id           VARCHAR2
                               )
--</EC-DOC>

IS

  CURSOR c_ptst_prim_well(cp_result_no NUMBER,p_daytime DATE) IS
  SELECT pwr.object_id, wv.approach_method
  FROM  pwel_result pwr, well_version wv
  WHERE pwr.result_no = cp_result_no
  AND   ( pwr.primary_ind = 'Y' OR pwr.object_id = Nvl(p_well_id,'X') AND p_n_primary_well = 'Y')  -- To handle the odd case that primary_ind is being set for an active test
  AND   pwr.object_id =wv.object_id
  AND   p_daytime >= wv.daytime AND p_daytime < Nvl(wv.end_date,p_daytime+1)
  ORDER BY pwr.object_id;  -- There should only be one but to make it deterministic in case not.

  ld_prev   DATE;
  ld_next   DATE;
  lv2_approach_method  WELL_VERSION.APPROACH_METHOD%TYPE;

BEGIN

  -- The most obvious cases are allready taken care of, so here we need to find previous and next performance test
  -- so the assumption here is that this is a test involving a primary well.

  IF p_operation = 'INSERTING' THEN

    FOR curPrimWell IN c_ptst_prim_well(p_n_result_no,p_n_valid_from_date ) LOOP

      -- Find previous and next test, they might be null
      ld_prev :=  ec_ptst_result.valid_from_date(EcDp_Performance_test.getLastValidWellResultNo(curPrimWell.object_id, p_n_valid_from_date - 1/84600));
      ld_next :=  ec_ptst_result.valid_from_date(EcDp_Performance_test.getNextValidWellResultNo(curPrimWell.object_id, p_n_valid_from_date + 1/84600));

      lv2_approach_method := GreatestApproachMethod(curPrimWell.object_id, Nvl(ld_prev,p_n_valid_from_date),Nvl(ld_next,p_n_valid_from_date));

      IF lv2_approach_method  = Ecdp_Calc_Method.STEPPED  THEN

        EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation,p_n_valid_from_date,ld_next, p_id ||'; Next test in locked period detected', curPrimWell.object_id);

      ELSE

        EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation,p_n_valid_from_date,ld_next, p_id||'; Next test in locked period detected', curPrimWell.object_id);
        EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation,Nvl(ld_prev,p_n_valid_from_date),p_n_valid_from_date, p_id||'; Approach method: '||lv2_approach_method ||'; Previous test in locked period detected', curPrimWell.object_id);

      END IF;

    END LOOP;

  ELSIF p_operation = 'DELETING' THEN

    FOR curPrimWell IN c_ptst_prim_well(p_o_result_no, p_o_valid_from_date) LOOP

      -- Find previous and next test, they might be null
      ld_prev :=  ec_ptst_result.valid_from_date(EcDp_Performance_test.getLastValidWellResultNo(curPrimWell.object_id, p_o_valid_from_date - 1/84600));
      ld_next :=  ec_ptst_result.valid_from_date(EcDp_Performance_test.getNextValidWellResultNo(curPrimWell.object_id, p_o_valid_from_date + 1/84600));

      lv2_approach_method := GreatestApproachMethod(curPrimWell.object_id, Nvl(ld_prev,p_o_valid_from_date),Nvl(ld_next,p_o_valid_from_date));

      IF lv2_approach_method  = Ecdp_Calc_Method.STEPPED  THEN

        EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation,p_o_valid_from_date,ld_next, p_id||'; Next test in locked period detected', curPrimWell.object_id);

      ELSE

        EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation,p_o_valid_from_date,ld_next, p_id||'; Next test in locked period detected', curPrimWell.object_id);
        EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation,Nvl(ld_prev,p_o_valid_from_date),p_o_valid_from_date, p_id||'; Approach method: '||lv2_approach_method ||'; Previous test in locked period detected', curPrimWell.object_id);

      END IF;

    END LOOP;

  ELSE  -- Updating

    -- Now it starts to tricky here, but basically we want ot validate this as if it was a delete of the old record and an insert of the
    -- new one, in some cases that will be to strict, so there are a few exceptions that need to be handled up front.

    -- Main update handling, check "delete of old record

    FOR curPrimWell IN c_ptst_prim_well(p_o_result_no, p_o_valid_from_date) LOOP

      -- Find previous and next test, they might be null
      ld_prev :=  ec_ptst_result.valid_from_date(EcDp_Performance_test.getLastValidWellResultNo(curPrimWell.object_id, p_o_valid_from_date - 1/84600));
      ld_next :=  ec_ptst_result.valid_from_date(EcDp_Performance_test.getNextValidWellResultNo(curPrimWell.object_id, p_o_valid_from_date + 1/84600));

      lv2_approach_method := GreatestApproachMethod(curPrimWell.object_id, Nvl(ld_prev,p_o_valid_from_date),Nvl(ld_next,p_o_valid_from_date));

      IF lv2_approach_method  = Ecdp_Calc_Method.STEPPED  THEN

        -- check for the known exception ony updating valid_from_date, this is only interesting for STEPPED (and partly for EXTRAPOLATE, but ignoring this for now)
        -- must also check that we are not outside previous and next test, in that case this is falls back to the delete/insert test

        IF p_dt_exception
           AND least(p_o_valid_from_date,p_n_valid_from_date ) >= Nvl(ld_prev,least(p_o_valid_from_date,p_n_valid_from_date ))
           AND GREATEST(p_o_valid_from_date,p_n_valid_from_date ) < Nvl(ld_next,GREATEST(p_o_valid_from_date,p_n_valid_from_date )) THEN

          EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation,least(p_o_valid_from_date,p_n_valid_from_date ),GREATEST(p_o_valid_from_date,p_n_valid_from_date ), p_id||'; Moving valid_from_date over locked period detected', curPrimWell.object_id);

        ELSE

          EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation,p_o_valid_from_date,ld_next, p_id||'; Next test in locked period detected', curPrimWell.object_id);

        END IF;

      ELSE

        EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation,p_o_valid_from_date,ld_next, p_id||'; Next test in locked period detected', curPrimWell.object_id);
        EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation,Nvl(ld_prev,p_o_valid_from_date),p_o_valid_from_date, p_id||'; Approach method: '||lv2_approach_method ||'; Previous test in locked period detected', curPrimWell.object_id);

      END IF;

    END LOOP;

    -- Test "Insert"
    FOR curPrimWell IN c_ptst_prim_well(p_n_result_no,p_n_valid_from_date ) LOOP

      -- Find previous and next test, they might be null
      ld_prev :=  ec_ptst_result.valid_from_date(EcDp_Performance_test.getLastValidWellResultNo(curPrimWell.object_id, p_n_valid_from_date - 1/84600));
      ld_next :=  ec_ptst_result.valid_from_date(EcDp_Performance_test.getNextValidWellResultNo(curPrimWell.object_id, p_n_valid_from_date + 1/84600));

      lv2_approach_method := GreatestApproachMethod(curPrimWell.object_id, Nvl(ld_prev,p_n_valid_from_date),Nvl(ld_next,p_n_valid_from_date));

      IF lv2_approach_method  = Ecdp_Calc_Method.STEPPED  THEN

        -- check for the known exception ony updating valid_from_date, this is only interesting for STEPPED (and partly for EXTRAPOLATE, but ignoring this for now)
        -- must also check that we are not outside previous and next test, in that case this is falls back to the delete/insert test

        IF p_dt_exception
           AND least(p_o_valid_from_date,p_n_valid_from_date ) >= Nvl(ld_prev,least(p_o_valid_from_date,p_n_valid_from_date ))
           AND GREATEST(p_o_valid_from_date,p_n_valid_from_date ) < Nvl(ld_next,GREATEST(p_o_valid_from_date,p_n_valid_from_date )) THEN

          NULL;  -- Allready checked in "delete" loop.

        ELSE

          EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation,p_n_valid_from_date,ld_next, p_id||'; Next test in locked period detected', curPrimWell.object_id);

        END IF;

      ELSE

        EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation,p_n_valid_from_date,ld_next, p_id ||'; Next test in locked period detected', curPrimWell.object_id);
        EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation,Nvl(ld_prev,p_n_valid_from_date),p_n_valid_from_date, p_id||'; Approach method: '||lv2_approach_method ||'; Previous test in locked period detected', curPrimWell.object_id);

      END IF;

    END LOOP;

  END IF;

END DetectDependentLock;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : DetectDependentLock
-- Description    : Used to find if a period is locked because the previous or next test for a primary
--                  well (or in the future also flowline) is in a locked period.
--
--
-- Preconditions  : It is the caller that is resposible for setting the correct old and new values (see under behaviour).
-- Postconditions :
--
-- Using tables   : pwel_result, well_version
--
--
--
-- Using functions: GreatestApproachMethod
--
-- Configuration
-- required       :
--
-- Behavior       : Currently this indirect locking is only based on primary wells linked to the test
--                  In the future it will probably also need to check primary flowlines.
--                  Not there can be more than 1 primary well, so we need to loop and validate previous and
--                  next for each of them.
--
--                  The calling procedure will only be CheckLockProductionTest, but that one again can be called
--                  from 32 different Instead of triggers, but the classes "ending up here" will be linked to
--                  tables, PTST_RESULT, EQPM_RESULT, PWEL_RESULT, PFLW_RESULT. It is the procedure CheckLockProductionTest
--                  that is resposible for setting the correct old and new values that is given, so the check here gives meaning
--                  related to the given operation
--
--                  Under are listing of the cases identified, that should be handled by this procedure
--
--                  Direct operations on PTST_RESULT
--                  --------------------------------
--                  1. Insert:  Since there can not possibly be any assosiated wells at this stage, no validation will be done (no rows in cursor).
--                  2. Update:  The most interesting cases are setting valid_from_date or status, usually this can be validated by checking if
--                              delete with old values and insert with new values. The only exception is changing of only valid_from_date, here
--                              should make an exception and allow moving valid_from_date within a unlocked period, as long as it does not affects
--                              any locked period.
--                  3. Delete:  Can be validated if there are dependent objects, since we are currently not using cascading delete, it means that
--                              if it can be validated, delete will be stopped anyway by FK constraints. But no damage done by keeping it, so no
--                              point in and making an exceptions.
--
--                  Operations on EQPM_RESULT, PWEL_RESULT, PFLW_RESULT
--                  ---------------------------------------------------------
--                  In many ways this can be considered as updates to the logical PT unit even if it is an Insert or Delete, but it still makes sence
--                  to know the original operation, because an update on these tables are more complex, since it can (at least in theory) move a result row
--                  from one "old" to a "new" Performance test. In that sence a Insert and Delete are simpler. So it is important that the caller procedure
--                  gives the correct old result_no (p_o_result_no), status and valid from date.
--
--                  1. Insert:  The check only need to take into account the new result_no, status and valid_from_date.
--                  2. Update:  Again use the delete-,insert- check approach, there should be no exception checks needed here.
--                  3. Delete:  The check only need to take into account the old result_no, status and valid_from_date


---------------------------------------------------------------------------------------------------
PROCEDURE    DetectDependentPerfCurveLock(
                               p_operation         VARCHAR2,
                               p_n_perf_curve_id   PERFORMANCE_CURVE.PERF_CURVE_ID%TYPE ,
                               p_o_perf_curve_id   PERFORMANCE_CURVE.PERF_CURVE_ID%TYPE,
                               p_n_daytime         DATE,
                               p_o_daytime         DATE,
                               p_n_well_object_id  WELL.OBJECT_ID%TYPE,
                               p_o_well_object_id  WELL.OBJECT_ID%TYPE,
                               p_n_curve_purpose   PERFORMANCE_CURVE.CURVE_PURPOSE%TYPE,
                               p_o_curve_purpose   PERFORMANCE_CURVE.CURVE_PURPOSE%TYPE,
                               p_id                VARCHAR2,
                               p_dt_exception      BOOLEAN
                               )
--</EC-DOC>

IS

  ld_prev   DATE;
  ld_next   DATE;
  lv2_approach_method  WELL_VERSION.APPROACH_METHOD%TYPE;
  lv_old_phase PERFORMANCE_CURVE.PHASE%TYPE;
  lv_new_phase PERFORMANCE_CURVE.PHASE%TYPE;

BEGIN

  lv_old_phase := ec_performance_curve.phase(p_o_perf_curve_id);
  lv_new_phase := ec_performance_curve.phase(p_n_perf_curve_id);

  -- The most obvious cases are allready taken care of, so here we need to find previous and next performance curve
  IF p_operation = 'INSERTING' THEN

    -- Find previous and next test, they might be null
    ld_prev :=  ec_performance_curve.daytime(EcDp_Performance_Curve.getPrevWellPerformanceCurveId(p_n_well_object_id, p_n_daytime - 1/84600, p_n_curve_purpose, lv_new_phase));
    ld_next :=  ec_performance_curve.daytime(EcDp_Performance_Curve.getNextWellPerformanceCurveId(p_n_well_object_id, p_n_daytime + 1/84600, p_n_curve_purpose, lv_new_phase));

    lv2_approach_method := GreatestApproachMethod(p_n_well_object_id, Nvl(ld_prev,p_n_daytime),Nvl(ld_next,p_n_daytime));

    IF lv2_approach_method  = Ecdp_Calc_Method.STEPPED  THEN

      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation,p_n_daytime,ld_next, p_id ||'; Next Curve in locked period detected', p_n_well_object_id);

    ELSE

      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation,p_n_daytime,ld_next, p_id||'; Next Curve in locked period detected', p_n_well_object_id);
      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation,Nvl(ld_prev,p_n_daytime),p_n_daytime, p_id||'; Approach method: '||lv2_approach_method ||'; Previous curve in locked period detected', p_n_well_object_id);

    END IF;

  ELSIF p_operation = 'DELETING' THEN

    -- Find previous and next test, they might be null
    ld_prev :=  ec_performance_curve.daytime(EcDp_Performance_Curve.getPrevWellPerformanceCurveId(p_o_well_object_id, p_o_daytime - 1/84600, p_o_curve_purpose, lv_old_phase));
    ld_next :=  ec_performance_curve.daytime(EcDp_Performance_Curve.getNextWellPerformanceCurveId(p_o_well_object_id, p_o_daytime + 1/84600, p_o_curve_purpose, lv_old_phase));

    lv2_approach_method := GreatestApproachMethod(p_o_well_object_id, Nvl(ld_prev,p_o_daytime),Nvl(ld_next,p_o_daytime));

    IF lv2_approach_method  = Ecdp_Calc_Method.STEPPED  THEN

      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation,p_o_daytime,ld_next, p_id||'; Next cuve in locked period detected', p_o_well_object_id);

    ELSE

      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation,p_o_daytime,ld_next, p_id||'; Next curve in locked period detected', p_o_well_object_id);
      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation,Nvl(ld_prev,p_o_daytime),p_o_daytime, p_id||'; Approach method: '||lv2_approach_method ||'; Previous curve in locked period detected', p_o_well_object_id);

    END IF;

  ELSE  -- Updating

    -- Now it starts to tricky here, but basically we want ot validate this as if it was a delete of the old record and an insert of the
    -- new one, in some cases that will be to strict, so there are a few exceptions that need to be handled up front.

    -- Find previous and next test, they might be null
    ld_prev :=  ec_performance_curve.daytime(EcDp_Performance_Curve.getPrevWellPerformanceCurveId(p_o_well_object_id, p_o_daytime - 1/84600, p_o_curve_purpose, lv_old_phase));
    ld_next :=  ec_performance_curve.daytime(EcDp_Performance_Curve.getNextWellPerformanceCurveId(p_o_well_object_id, p_o_daytime + 1/84600, p_o_curve_purpose, lv_old_phase));

    lv2_approach_method := GreatestApproachMethod(p_o_well_object_id, Nvl(ld_prev,p_o_daytime),Nvl(ld_next,p_o_daytime));

    IF lv2_approach_method  = Ecdp_Calc_Method.STEPPED  THEN

      -- check for the known exception ony updating valid_from_date, this is only interesting for STEPPED (and partly for EXTRAPOLATE, but ignoring this for now)
      -- must also check that we are not outside previous and next test, in that case this is falls back to the delete/insert test

      IF p_dt_exception
         AND least(p_o_daytime,p_n_daytime ) >= Nvl(ld_prev,least(p_o_daytime,p_n_daytime ))
         AND GREATEST(p_o_daytime,p_n_daytime ) < Nvl(ld_next,GREATEST(p_o_daytime,p_n_daytime )) THEN

        EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation,least(p_o_daytime,p_n_daytime),GREATEST(p_o_daytime,p_n_daytime ), p_id||'; Moving daytime over locked period detected', p_n_well_object_id);

      ELSE

        EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation,p_o_daytime,ld_next, p_id||'; Next daytime in locked period detected', p_n_well_object_id);

      END IF;

    ELSE

      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation,p_o_daytime,ld_next, p_id||'; Next curve in locked period detected', p_n_well_object_id);
      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation,Nvl(ld_prev,p_o_daytime),p_o_daytime, p_id||'; Approach method: '||lv2_approach_method ||'; Previous curve in locked period detected', p_n_well_object_id);

    END IF;

    -- Test "Insert"

    -- Find previous and next test, they might be null
    ld_prev :=  ec_performance_curve.daytime(EcDp_Performance_Curve.getPrevWellPerformanceCurveId(p_n_well_object_id, p_n_daytime - 1/84600, p_n_curve_purpose, lv_new_phase));
    ld_next :=  ec_performance_curve.daytime(EcDp_Performance_Curve.getNextWellPerformanceCurveId(p_n_well_object_id, p_n_daytime + 1/84600, p_n_curve_purpose, lv_new_phase));


    lv2_approach_method := GreatestApproachMethod(p_n_well_object_id, Nvl(ld_prev,p_n_daytime),Nvl(ld_next,p_n_daytime));

    IF lv2_approach_method  = Ecdp_Calc_Method.STEPPED  THEN

      -- check for the known exception ony updating valid_from_date, this is only interesting for STEPPED (and partly for EXTRAPOLATE, but ignoring this for now)
      -- must also check that we are not outside previous and next test, in that case this is falls back to the delete/insert test

      IF p_dt_exception
         AND least(p_o_daytime,p_n_daytime ) >= Nvl(ld_prev,least(p_o_daytime,p_n_daytime ))
         AND GREATEST(p_o_daytime,p_n_daytime ) < Nvl(ld_next,GREATEST(p_o_daytime,p_n_daytime )) THEN

        NULL;  -- Allready checked in "delete" loop.

      ELSE

        EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation,p_n_daytime,ld_next, p_id||'; Next curve in locked period detected', p_n_well_object_id);

      END IF;

    ELSE

      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation,p_n_daytime,ld_next, p_id ||'; Next curve in locked period detected', p_n_well_object_id);
      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation,Nvl(ld_prev,p_n_daytime),p_n_daytime, p_id||'; Approach method: '||lv2_approach_method ||'; Previous curve in locked period detected', p_n_well_object_id);

    END IF;

  END IF;

END DetectDependentPerfCurveLock;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : CheckLockProductionTest
-- Description    : Given an object of a class related to Performance testing, find out if update
--                  of the object is allowed checking against locked months.
--
--
-- Preconditions  : Assuming that the caller class is related to Performance testing
-- Postconditions : Raises an application error if the given object is locked
--
-- Using tables   : PTST_RESULT, PWEL_RESULT, WELL_VERSION etc.
--
--
--
-- Using functions: prodTestApproachMethod
--
-- Configuration
-- required       :
--
-- Behavior      :
--                 This procedure can be called from any of the performance test classes, they can roughly be categorized in 3 groups
--                 1. Directly on PTST_RESULT
--                 2. Result classes linked to PTST_RESULT
--                 3. Definition classes that might be related to PTST_RESULT
--
--                 First try to find criteria attributes from PTST_RESULT and handle exceptions,
--                 after that all the 3 categories over can be handled by the same algorithm.
--
--                 Take care of the most obvious cases in this procedure, use sub procedures for more special cases
--                 related to STEPPING, EXTRAPOLATE and INTERPOLATE_EXTRAPOLATE


---------------------------------------------------------------------------------------------------
PROCEDURE  CheckLockProductionTest(p_operation VARCHAR2, l_new IN OUT EcDp_month_lock.column_list, l_old IN OUT EcDp_month_lock.column_list)
--</EC-DOC>

IS

  CURSOR c_ptst_result(cp_test_no NUMBER) IS
  SELECT pr.result_no
  FROM  ptst_result pr
  WHERE pr.test_no = cp_test_no
  AND   pr.status = 'ACCEPTED'
  ORDER BY result_no;  -- There should only be one but to make it deterministic in case not.

  CURSOR c_ptst_object(cp_local_lock VARCHAR2, cp_test_no NUMBER) IS
  SELECT DISTINCT Ecdp_Groups.findParentObjectId(cp_local_lock, 'operational', o.class_name, o.object_id, d.daytime) parent_object_id
  FROM ptst_definition d, ptst_object o
  WHERE o.test_no = d.test_no
  AND d.test_no = cp_test_no;

  ln_n_result_no             PTST_RESULT.RESULT_NO%TYPE;
  ln_o_result_no             PTST_RESULT.RESULT_NO%TYPE;
  ld_n_valid_from            PTST_RESULT.VALID_FROM_DATE%TYPE;
  ld_o_valid_from            PTST_RESULT.VALID_FROM_DATE%TYPE;
  lv2_n_status               PTST_RESULT.STATUS%TYPE;
  lv2_o_status               PTST_RESULT.STATUS%TYPE;
  lv2_n_primary_well         PWEL_RESULT.PRIMARY_IND%TYPE;
  lr_ptst_result             PTST_RESULT%ROWTYPE;
  lv2_test_approach_method   WELL_VERSION.APPROACH_METHOD%TYPE;
  lv2_prim_well_id           WELL.OBJECT_ID%TYPE;
  lv2_id                     VARCHAR(2000);
  lb_dt_exception            BOOLEAN := FALSE;

  lv2_o_obj_id               VARCHAR2(32);
  lv2_n_obj_id               VARCHAR2(32);
  lv2_local_lock             VARCHAR2(32);
  ln_n_test_no               PTST_RESULT.TEST_NO%TYPE;
  ln_o_test_no               PTST_RESULT.TEST_NO%TYPE;
  ld_n_valid_to              PTST_DEFINITION.END_DATE%TYPE;
  ld_o_valid_to              PTST_RESULT.END_DATE%TYPE;

BEGIN

  -- First see if the calling class have RESULT_NO, if not it is a category 3 class (see description above)
  IF l_new.EXISTS('RESULT_NO') THEN

    ln_n_result_no := l_new('RESULT_NO').column_data.AccessNumber;
    ln_o_result_no := l_old('RESULT_NO').column_data.AccessNumber;

  ELSE
    -- This should only occure for a category 3 class
    -- The calling class should then have TEST_NO, so no exception handling for this

    FOR cur_ptst_result IN c_ptst_result(l_new('TEST_NO').column_data.AccessNumber) LOOP

      ln_n_result_no := cur_ptst_result.result_no;

    END LOOP;

    FOR cur_ptst_result IN c_ptst_result(l_old('TEST_NO').column_data.AccessNumber) LOOP

      ln_o_result_no := cur_ptst_result.result_no;

    END LOOP;

  END IF;

  IF NOT ( ln_n_result_no IS NULL AND ln_o_result_no IS NULL )  THEN -- ELSE This is a performance test definition with no active result, so no locking needed

    IF l_new.EXISTS('VALID_FROM_DATE') AND l_new.EXISTS('STATUS') THEN

      ld_n_valid_from := l_new('VALID_FROM_DATE').column_data.AccessDate;
      ld_o_valid_from := l_old('VALID_FROM_DATE').column_data.AccessDate;
      lv2_n_status := l_new('STATUS').column_data.AccessVarchar2;
      lv2_o_status := l_old('STATUS').column_data.AccessVarchar2;

    ELSE

      lr_ptst_result    :=  EC_PTST_RESULT.ROW_BY_PK(ln_n_result_no);
      ld_n_valid_from   :=  lr_ptst_result.VALID_FROM_DATE;
      lv2_n_status      :=  lr_ptst_result.STATUS;

      lr_ptst_result :=  EC_PTST_RESULT.ROW_BY_PK(ln_o_result_no);
      ld_o_valid_from   :=  lr_ptst_result.VALID_FROM_DATE;
      lv2_o_status      :=  lr_ptst_result.STATUS;

    END IF;

    IF l_new.EXISTS('OBJECT_ID')  THEN
      lv2_n_obj_id := l_new('OBJECT_ID').column_data.AccessVarchar2;
      lv2_o_obj_id := l_old('OBJECT_ID').column_data.AccessVarchar2;
    ELSIF l_new.EXISTS('TEST_DEVICE_ID')  THEN
      lv2_n_obj_id := l_new('TEST_DEVICE_ID').column_data.AccessVarchar2;
      lv2_o_obj_id := l_old('TEST_DEVICE_ID').column_data.AccessVarchar2;
    ELSIF l_new.EXISTS('FACILITY_ID') THEN
      lv2_n_obj_id := l_new('FACILITY_ID').column_data.AccessVarchar2;
      lv2_o_obj_id := l_old('FACILITY_ID').column_data.AccessVarchar2;
    ELSE
      lr_ptst_result :=  EC_PTST_RESULT.ROW_BY_PK(ln_n_result_no);
      lv2_n_obj_id :=lr_ptst_result.facility_id;

      lr_ptst_result :=  EC_PTST_RESULT.ROW_BY_PK(ln_o_result_no);
      lv2_o_obj_id :=lr_ptst_result.facility_id;
    END IF;

    IF l_new.EXISTS('PRIMARY_IND') AND l_new.EXISTS('OBJECT_ID') THEN  -- At the moment only the well_result classes have this, will probably need extentions in the future

      lv2_n_primary_well := l_new('PRIMARY_IND').column_data.AccessVarchar2;
      lv2_prim_well_id   := l_old('OBJECT_ID').column_data.AccessVarchar2;

    ELSIF l_new.EXISTS('PRIMARY') AND l_new.EXISTS('OBJECT_ID') THEN

      lv2_n_primary_well := l_new('PRIMARY').column_data.AccessVarchar2;
      lv2_prim_well_id   := l_old('OBJECT_ID').column_data.AccessVarchar2;

    END IF;

    -- OK are now in a possision to handle all performance test classes in almost the same way:

    -- First criteria to check is if valid from date and status is set so the performance test is active, if not there are no lock restrictions

    lv2_id := 'Performance Test assosiated Class:'|| l_new('CLASS_NAME').column_name;

    IF  (ld_n_valid_from IS NOT NULL AND  lv2_n_status = 'ACCEPTED' AND lv2_n_obj_id IS NOT NULL)
        OR (ld_o_valid_from IS NOT NULL AND  lv2_o_status = 'ACCEPTED' AND lv2_o_obj_id IS NOT NULL) THEN

      -- Lets start with the most obvious cases first, prod test within locked month

      IF p_operation = 'INSERTING' THEN

        EcDp_month_lock.validatePeriodForLockOverlap(p_operation, ld_n_valid_from, ld_n_valid_from, lv2_id||' direct lock detected', lv2_n_obj_id);

      ELSIF p_operation = 'UPDATING' THEN

        EcDp_month_lock.validatePeriodForLockOverlap(p_operation, ld_n_valid_from, ld_n_valid_from, lv2_id||' direct lock detected', lv2_n_obj_id);
        EcDp_month_lock.validatePeriodForLockOverlap(p_operation, ld_o_valid_from, ld_o_valid_from, lv2_id||' direct lock detected', lv2_o_obj_id);

      ELSE -- Delete

        EcDp_month_lock.validatePeriodForLockOverlap(p_operation, ld_o_valid_from, ld_o_valid_from, lv2_id||' direct lock detected', lv2_o_obj_id);

      END IF; -- p_operation = 'INSERTING'

      -- Check if this is the identified exception only updating valid_from_date on PTST_RESULT

      IF p_operation = 'UPDATING'
         AND l_new('TABLE_NAME').column_name = 'PTST_RESULT'
         AND ld_n_valid_from IS NOT NULL
         AND ld_o_valid_from IS NOT NULL   -- If one of these are Null , thats fine don't go into the IF
      THEN

        -- CHECK IF we are updating any other attribute
        l_new('VALID_FROM_DATE').is_checked := 'Y';
        lb_dt_exception := NOT Ecdp_month_lock.checkIfColumnsUpdated(l_new);

      END IF;

      DetectDependentLock(p_operation, ln_n_result_no, ln_o_result_no, lv2_n_status, lv2_o_status, ld_n_valid_from,
                          ld_o_valid_from, lv2_id, lb_dt_exception, lv2_n_primary_well, lv2_prim_well_id);

    END IF;  -- Valid from date is not null

  ELSE

    IF lv2_n_obj_id IS NULL THEN
      IF l_new.EXISTS('TEST_NO') THEN
        ln_n_test_no := l_new('TEST_NO').column_data.AccessNumber;
        ln_o_test_no := l_old('TEST_NO').column_data.AccessNumber;
      ELSE
        lr_ptst_result :=  EC_PTST_RESULT.ROW_BY_PK(ln_n_result_no);
        ln_o_test_no :=lr_ptst_result.test_no;

        lr_ptst_result :=  EC_PTST_RESULT.ROW_BY_PK(ln_o_result_no);
        ln_o_test_no :=lr_ptst_result.test_no;
      END IF;

      ld_n_valid_from  := ec_ptst_definition.daytime(ln_n_test_no);
      ld_o_valid_from  := ec_ptst_definition.daytime(ln_o_test_no);
      ld_n_valid_to := ec_ptst_definition.end_date(ln_n_test_no);
      ld_o_valid_to := ec_ptst_definition.end_date(ln_o_test_no);

      IF p_operation = 'INSERTING' THEN

        lv2_local_lock := ecdp_ctrl_property.getSystemProperty('/com/ec/prod/ha/screens/LOCAL_LOCK_LEVEL', ld_n_valid_from);

        FOR cur_ptst_object IN c_ptst_object(lv2_local_lock, ln_n_test_no) LOOP
          IF cur_ptst_object.parent_object_id IS NOT NULL THEN
            EcDp_month_lock.validatePeriodForLockOverlap(p_operation, ld_n_valid_from, ld_n_valid_to, lv2_id||' direct lock detected', cur_ptst_object.parent_object_id);
          END IF;
        END LOOP;

      ELSIF p_operation = 'UPDATING' THEN

        lv2_local_lock := ecdp_ctrl_property.getSystemProperty('/com/ec/prod/ha/screens/LOCAL_LOCK_LEVEL', ld_n_valid_from);

        FOR cur_ptst_object IN c_ptst_object(lv2_local_lock, ln_n_test_no) LOOP
          IF cur_ptst_object.parent_object_id IS NOT NULL THEN
            EcDp_month_lock.validatePeriodForLockOverlap(p_operation, ld_n_valid_from, ld_n_valid_to, lv2_id||' direct lock detected', cur_ptst_object.parent_object_id);
          END IF;
        END LOOP;

        lv2_local_lock := ecdp_ctrl_property.getSystemProperty('/com/ec/prod/ha/screens/LOCAL_LOCK_LEVEL', ld_o_valid_from);

        FOR cur_ptst_object IN c_ptst_object(lv2_local_lock, ln_o_test_no) LOOP
          IF cur_ptst_object.parent_object_id IS NOT NULL THEN
            EcDp_month_lock.validatePeriodForLockOverlap(p_operation, ld_o_valid_from, ld_o_valid_to, lv2_id||' direct lock detected', cur_ptst_object.parent_object_id);
          END IF;
        END LOOP;

      ELSE -- Delete

        lv2_local_lock := ecdp_ctrl_property.getSystemProperty('/com/ec/prod/ha/screens/LOCAL_LOCK_LEVEL', ld_o_valid_from);

        FOR cur_ptst_object IN c_ptst_object(lv2_local_lock, ln_o_test_no) LOOP
          IF cur_ptst_object.parent_object_id IS NOT NULL THEN
            EcDp_month_lock.validatePeriodForLockOverlap(p_operation, ld_o_valid_from, ld_o_valid_to, lv2_id||' direct lock detected', cur_ptst_object.parent_object_id);
          END IF;
        END LOOP;

      END IF; -- p_operation = 'INSERTING'

    END IF;

  END IF;  -- NOT ( ln_n_result_no IS NULL AND ln_o_result_no IS NULL )  THEN

END  CheckLockProductionTest;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : CheckLockPerformanceCurve
-- Description    : Given an object of a class related to Performance curve, find out if update
--                  of the object is allowed checking against locked months.
--
--
-- Preconditions  : Assuming that the caller class is related to Performance curve
-- Postconditions : Raises an application error if the given object is locked
--
-- Using tables   : PERFORMANCE_CURVE, CURVE, CURVE_POINT, WELL_VERSION
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--                 This procedure can be called from any class linked to performance curve
--                 1. Directly on PERFORMANCE_CURVE
--                 2. ON Table CURVE
--                 3. Linked to CURVE using CURVE_ID
--
--                 First Navigate to find Perf_curve_id, well_obj_id and APPROACH_METHOD for given well
--                 after that all the 3 categories over can be handled by the same algorithm.
--
--                 Take care of the most obvious cases in this procedure, use sub procedures for more special cases
--                 related to STEPPING, EXTRAPOLATE and INTERPOLATE_EXTRAPOLATE


---------------------------------------------------------------------------------------------------
PROCEDURE  CheckLockPerformanceCurve(p_operation VARCHAR2, l_new IN OUT EcDp_month_lock.column_list, l_old IN OUT EcDp_month_lock.column_list)
--</EC-DOC>

IS

  ln_n_well_object_id        WELL.OBJECT_ID%TYPE;
  ln_o_well_object_id        WELL.OBJECT_ID%TYPE;
  ln_n_perf_curve_id         PERFORMANCE_CURVE.PERF_CURVE_ID%TYPE;
  ln_o_perf_curve_id         PERFORMANCE_CURVE.PERF_CURVE_ID%TYPE;
  ln_n_curve_purpose         PERFORMANCE_CURVE.CURVE_PURPOSE%TYPE;
  ln_o_curve_purpose         PERFORMANCE_CURVE.CURVE_PURPOSE%TYPE;
  ln_n_curve_id              CURVE.CURVE_ID%TYPE;
  ln_o_curve_id              CURVE.CURVE_ID%TYPE;
  ld_n_daytime               DATE;
  ld_o_daytime               DATE;
  lv2_id                     VARCHAR(2000);
  lb_dt_exception            BOOLEAN := FALSE;

BEGIN

  -- First see if the calling class is PERFORMANCE_CURVE,

  IF l_new('TABLE_NAME').column_name = 'V_PERFORMANCE_CURVE' THEN

    ln_n_perf_curve_id  := l_new('PERF_CURVE_ID').column_data.AccessNumber;
    ln_o_perf_curve_id  := l_old('PERF_CURVE_ID').column_data.AccessNumber;

    ln_n_well_object_id := l_new('CURVE_OBJECT_ID').column_data.AccessVarChar2;
    ln_o_well_object_id := l_old('CURVE_OBJECT_ID').column_data.AccessVarChar2;

    ld_n_daytime   := l_new('DAYTIME').column_data.AccessDate;
    ld_o_daytime   := l_old('DAYTIME').column_data.AccessDate;

    ln_n_curve_purpose   := l_new('CURVE_PURPOSE').column_data.AccessVarChar2;
    ln_o_curve_purpose   := l_old('CURVE_PURPOSE').column_data.AccessVarChar2;

  ELSE -- Assume that the class has CURVE_ID, and us that to find the navigate to performance curve

    ln_n_curve_id       := l_new('CURVE_ID').column_data.AccessNumber;
    ln_o_curve_id       := l_old('CURVE_ID').column_data.AccessNumber;

  	IF l_new('TABLE_NAME').column_name = 'CURVE' THEN
    	ln_n_perf_curve_id  := l_new('PERF_CURVE_ID').column_data.AccessNumber;
    	ln_o_perf_curve_id  := l_old('PERF_CURVE_ID').column_data.AccessNumber;
		ELSIF l_new('TABLE_NAME').column_name = 'CURVE_POINT' THEN
    	ln_n_perf_curve_id  := ec_curve.perf_curve_id(ln_n_curve_id);
    	ln_o_perf_curve_id  := ec_curve.perf_curve_id(ln_o_curve_id);
		END IF;

    ln_n_well_object_id := ec_performance_curve.curve_object_id(ln_n_perf_curve_id);
    ln_o_well_object_id := ec_performance_curve.curve_object_id(ln_o_perf_curve_id);

    ld_n_daytime   := ec_performance_curve.daytime(ln_n_perf_curve_id);
    ld_o_daytime   := ec_performance_curve.daytime(ln_o_perf_curve_id);

    ln_n_curve_purpose   := ec_performance_curve.curve_purpose(ln_n_perf_curve_id);
    ln_o_curve_purpose   := ec_performance_curve.curve_purpose(ln_o_perf_curve_id);

  END IF;

  -- OK are now in a possision to handle all performance curve classes the same way:

  -- Lets start with the most obvious cases first, prod test within locked month

  IF p_operation = 'INSERTING' THEN

    lv2_id := EcDp_Month_Lock.buildIdentifierString(l_new);
    EcDp_month_lock.validatePeriodForLockOverlap(p_operation, ld_n_daytime, ld_n_daytime, lv2_id||' direct lock detected', ln_n_well_object_id);

  ELSIF p_operation = 'UPDATING' THEN

    lv2_id := EcDp_Month_Lock.buildIdentifierString(l_new);
    EcDp_month_lock.validatePeriodForLockOverlap(p_operation, ld_n_daytime, ld_n_daytime, lv2_id||' direct lock detected', ln_n_well_object_id);
    EcDp_month_lock.validatePeriodForLockOverlap(p_operation, ld_o_daytime, ld_o_daytime, lv2_id||' direct lock detected', ln_o_well_object_id);

  ELSE -- Delete

    lv2_id := EcDp_Month_Lock.buildIdentifierString(l_new);
    EcDp_month_lock.validatePeriodForLockOverlap(p_operation, ld_o_daytime, ld_o_daytime, lv2_id||' direct lock detected', ln_o_well_object_id);

  END IF; -- p_operation = 'INSERTING'

  -- Check if this is the identified exception only updating daytime on PERFORMANCE_CURVE

  IF p_operation = 'UPDATING'
     AND   l_new('TABLE_NAME').column_name = 'V_PERFORMANCE_CURVE'
     AND   ld_n_daytime IS NOT NULL
     AND   ld_o_daytime IS NOT NULL
  THEN

    -- CHECK IF we are updating any other attribute
    l_new('DAYTIME').is_checked := 'Y';
    lb_dt_exception := NOT Ecdp_month_lock.checkIfColumnsUpdated(l_new);

  END IF;

  DetectDependentPerfCurveLock(p_operation, ln_n_perf_curve_id, ln_o_perf_curve_id, ld_n_daytime, ld_o_daytime,
                               ln_n_well_object_id, ln_o_well_object_id, ln_n_curve_purpose , ln_o_curve_purpose, lv2_id, lb_dt_exception );

END CheckLockPerformanceCurve;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : CheckResultNoLock
-- Description    : Wrapper procedure to set necassery parameters before testing if performance test result
--                  is locked.
--
--
-- Preconditions  : Assuming that this is an update operation , not changing PK in PTST_RESULT
-- Postconditions : Raises an application error if the given result_no is locked
--
-- Using tables   :
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE  CheckResultNoLock(p_result_no NUMBER)
--</EC-DOC>

IS
  lr_result            ptst_result%ROWTYPE;
  n_lock_columns       EcDp_Month_lock.column_list;

BEGIN

  lr_result := ec_ptst_result.row_by_pk(p_result_no);

  -- Lock test
  EcDp_month_lock.AddParameterToList(n_lock_columns,'CLASS_NAME','PROD_TEST_RESULT','STRING',NULL,NULL,NULL);
  EcDp_month_lock.AddParameterToList(n_lock_columns,'TABLE_NAME','PTST_RESULT','STRING',NULL,NULL,NULL);
  EcDp_month_lock.AddParameterToList(n_lock_columns,'RESULT_NO','RESULT_NO','NUMBER','Y','N',anydata.ConvertNumber(lr_result.RESULT_NO));
  EcDp_month_lock.AddParameterToList(n_lock_columns,'VALID_FROM_DATE','VALID_FROM_DATE','DATE','N','N',anydata.Convertdate(lr_result.VALID_FROM_DATE));
  EcDp_month_lock.AddParameterToList(n_lock_columns,'STATUS','STATUS','STRING','N','N',anydata.ConvertVarChar2(lr_result.STATUS));

  EcDp_Performance_lock.CheckLockProductionTest('UPDATING',n_lock_columns,n_lock_columns);

END CheckResultNoLock;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : CheckLockProdTestAllStatus
-- Description    : New procedure for given an object of a class related to Performance testing, find out if update
--                  of the object is allowed checking against locked months regardless to the STATUS.
--
--
-- Preconditions  : Assuming that the caller class is related to Performance testing
-- Postconditions : Raises an application error if the given object is locked
--
-- Using tables   : PTST_RESULT, PWEL_RESULT, WELL_VERSION, PTST_DEFINITION etc.
--
--
--
-- Using functions: prodTestApproachMethod
--
-- Configuration
-- required       :
--
-- Behavior      :
--                 This procedure can be called from any of the performance test classes, they can roughly be categorized in 3 groups
--                 1. Directly on PTST_RESULT or PTST_DEFINITION or PTST_OBJECT
--                 2. Result classes linked to PTST_RESULT or PTST_DEFINITION
--                 3. Definition classes that might be related to PTST_RESULT or PTST_DEFINITION or PTST_OBJECT
--
--                 First try to find criteria attributes from PTST_RESULT/PTST_DEFINITION/PTST_OBJECT and handle exceptions,
--                 after that all the 3 categories over can be handled by the same algorithm.
--
--                 Take care of the most obvious cases in this procedure, use sub procedures for more special cases
--                 related to STEPPING, EXTRAPOLATE and INTERPOLATE_EXTRAPOLATE


---------------------------------------------------------------------------------------------------
PROCEDURE  CheckLockProdTestAllStatus(p_operation VARCHAR2, l_new IN OUT EcDp_month_lock.column_list, l_old IN OUT EcDp_month_lock.column_list)
--</EC-DOC>

IS

  CURSOR c_ptst_result(cp_test_no NUMBER) IS
  SELECT pr.result_no
  FROM  ptst_result pr
  WHERE pr.test_no = cp_test_no
  ORDER BY result_no;

  CURSOR c_ptst_object(cp_test_no NUMBER) IS
  SELECT d.test_no
  FROM ptst_definition d, ptst_object o
  WHERE o.test_no = d.test_no
  AND d.test_no = cp_test_no;

  ln_n_result_no             PTST_RESULT.RESULT_NO%TYPE;
  ln_o_result_no             PTST_RESULT.RESULT_NO%TYPE;
  ld_n_valid_from            PTST_RESULT.VALID_FROM_DATE%TYPE;
  ld_o_valid_from            PTST_RESULT.VALID_FROM_DATE%TYPE;
  lv2_n_status               PTST_RESULT.STATUS%TYPE;
  lv2_o_status               PTST_RESULT.STATUS%TYPE;
  lv2_n_primary_well         PWEL_RESULT.PRIMARY_IND%TYPE;
  lr_ptst_result             PTST_RESULT%ROWTYPE;
  lv2_prim_well_id           WELL.OBJECT_ID%TYPE;
  lv2_id                     VARCHAR(2000);
  lb_dt_exception            BOOLEAN := FALSE;

  ln_n_test_no               PTST_RESULT.TEST_NO%TYPE;
  ln_o_test_no               PTST_RESULT.TEST_NO%TYPE;
  ld_n_valid_to              PTST_DEFINITION.END_DATE%TYPE;
  ld_o_valid_to              PTST_RESULT.END_DATE%TYPE;

BEGIN

  IF l_new.EXISTS('RESULT_NO') THEN

    ln_n_result_no := l_new('RESULT_NO').column_data.AccessNumber;
    ln_o_result_no := l_old('RESULT_NO').column_data.AccessNumber;

  ELSE

    FOR cur_ptst_result IN c_ptst_result(l_new('TEST_NO').column_data.AccessNumber) LOOP

      ln_n_result_no := cur_ptst_result.result_no;

    END LOOP;

    FOR cur_ptst_result IN c_ptst_result(l_old('TEST_NO').column_data.AccessNumber) LOOP

      ln_o_result_no := cur_ptst_result.result_no;

    END LOOP;

  END IF;

  IF l_new.EXISTS('VALID_FROM_DATE')THEN

    ld_n_valid_from := l_new('VALID_FROM_DATE').column_data.AccessDate;
    ld_o_valid_from := l_old('VALID_FROM_DATE').column_data.AccessDate;

  ELSE

    lr_ptst_result    :=  EC_PTST_RESULT.ROW_BY_PK(ln_n_result_no);
    ld_n_valid_from   :=  lr_ptst_result.VALID_FROM_DATE;

    lr_ptst_result    :=  EC_PTST_RESULT.ROW_BY_PK(ln_o_result_no);
    ld_o_valid_from   :=  lr_ptst_result.VALID_FROM_DATE;

  END IF;

  IF  l_new.EXISTS('START_DATE') THEN

    ld_n_valid_from   := l_new('START_DATE').column_data.AccessDate;
    ld_o_valid_from   := l_old('START_DATE').column_data.AccessDate;

  END IF;

  IF  l_new.EXISTS('DAYTIME') THEN

    ld_n_valid_from   := l_new('DAYTIME').column_data.AccessDate;
    ld_o_valid_from   := l_old('DAYTIME').column_data.AccessDate;

  END IF;

  IF l_new.EXISTS('PRIMARY_IND') AND l_new.EXISTS('OBJECT_ID') THEN

    lv2_n_primary_well := l_new('PRIMARY_IND').column_data.AccessVarchar2;
    lv2_prim_well_id   := l_old('OBJECT_ID').column_data.AccessVarchar2;

  ELSIF l_new.EXISTS('PRIMARY') AND l_new.EXISTS('OBJECT_ID') THEN

    lv2_n_primary_well := l_new('PRIMARY').column_data.AccessVarchar2;
    lv2_prim_well_id   := l_old('OBJECT_ID').column_data.AccessVarchar2;

  END IF;

  lv2_id := 'Performance Test assosiated Class:'|| l_new('CLASS_NAME').column_name;

  IF (ld_n_valid_from IS NOT NULL )  OR  (ld_o_valid_from IS NOT NULL ) THEN

    IF p_operation = 'INSERTING' THEN

      EcDp_month_lock.validatePeriodForLockOverlap(p_operation, ld_n_valid_from, ld_n_valid_from, lv2_id||' direct lock detected', 'N/A' );

    ELSIF p_operation = 'UPDATING' THEN

      EcDp_month_lock.validatePeriodForLockOverlap(p_operation, ld_n_valid_from, ld_n_valid_from, lv2_id||' direct lock detected', 'N/A');
      EcDp_month_lock.validatePeriodForLockOverlap(p_operation, ld_o_valid_from, ld_o_valid_from, lv2_id||' direct lock detected', 'N/A');

    ELSE -- Delete

      EcDp_month_lock.validatePeriodForLockOverlap(p_operation, ld_o_valid_from, ld_o_valid_from, lv2_id||' direct lock detected', 'N/A');

    END IF; -- p_operation = 'INSERTING'

    -- Check if this is the identified exception only updating valid_from_date on PTST_RESULT or PTST_DEFINITION

    IF p_operation = 'UPDATING'
       AND   l_new('TABLE_NAME').column_name = 'PTST_RESULT'
       OR    l_new('TABLE_NAME').column_name = 'PTST_DEFINITION'
       AND   ld_n_valid_from IS NOT NULL
       AND   ld_o_valid_from IS NOT NULL   -- If one of these are Null , thats fine don't go into the IF
    THEN
      -- CHECK IF we are updating any other attribute
      l_new('VALID_FROM_DATE').is_checked := 'Y';
      l_new('START_DATE').is_checked := 'Y';
      l_new('DAYTIME').is_checked := 'Y';
      lb_dt_exception := NOT Ecdp_month_lock.checkIfColumnsUpdated(l_new);

    END IF;

    DetectDependentLock(p_operation, ln_n_result_no, ln_o_result_no, lv2_n_status, lv2_o_status, ld_n_valid_from,
                        ld_o_valid_from, lv2_id, lb_dt_exception, lv2_n_primary_well, lv2_prim_well_id);
  END IF;  -- Valid from date is not null

  IF l_new.EXISTS('TEST_NO') THEN
    ln_n_test_no := l_new('TEST_NO').column_data.AccessNumber;
    ln_o_test_no := l_old('TEST_NO').column_data.AccessNumber;

    ld_n_valid_from  := ec_ptst_definition.daytime(ln_n_test_no);
    ld_o_valid_from  := ec_ptst_definition.daytime(ln_o_test_no);
    ld_n_valid_to := ec_ptst_definition.end_date(ln_n_test_no);
    ld_o_valid_to := ec_ptst_definition.end_date(ln_o_test_no);

    IF p_operation = 'INSERTING' THEN

      FOR cur_ptst_object IN c_ptst_object(ln_n_test_no) LOOP

        EcDp_month_lock.validatePeriodForLockOverlap(p_operation, ld_n_valid_from, ld_n_valid_to, lv2_id||' direct lock detected', 'N/A');

      END LOOP;

    ELSIF p_operation = 'UPDATING' THEN

      FOR cur_ptst_object IN c_ptst_object(ln_n_test_no) LOOP

        EcDp_month_lock.validatePeriodForLockOverlap(p_operation, ld_n_valid_from, ld_n_valid_to, lv2_id||' direct lock detected', 'N/A');

      END LOOP;

      FOR cur_ptst_object IN c_ptst_object(ln_o_test_no) LOOP

        EcDp_month_lock.validatePeriodForLockOverlap(p_operation, ld_o_valid_from, ld_o_valid_to, lv2_id||' direct lock detected', 'N/A');

      END LOOP;

    ELSE -- Delete

      FOR cur_ptst_object IN c_ptst_object(ln_o_test_no) LOOP

        EcDp_month_lock.validatePeriodForLockOverlap(p_operation, ld_o_valid_from, ld_o_valid_to, lv2_id||' direct lock detected', 'N/A');

      END LOOP;

    END IF; -- p_operation = 'INSERTING'

  END IF;

END  CheckLockProdTestAllStatus;


END EcDp_Performance_Lock;