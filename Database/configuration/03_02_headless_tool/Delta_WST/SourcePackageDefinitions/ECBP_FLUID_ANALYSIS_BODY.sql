CREATE OR REPLACE PACKAGE BODY EcBp_Fluid_Analysis IS
/****************************************************************
** Package        :  EcBp_Fluid_Analysis, body part.
**
** $Revision: 1.23 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to fluid analysis.
**
** Documentation  :  www.energy-components.com
**
** Created  : 23.12.2005  Dagfinn Nj�
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 17.02.2009 oonnnng  ECPD-6067: Add new parameter p_object_id to validatePeriodForLockOverlap() and checkUpdateOfLDOForLock()
                       in checkAnalysisLock(), checkAGAAnalysisLock(), checkStrmReferenceValueLock() and checkStrmWaterAnalysisLock() functions.
** 10.04.2009 leongsei ECPD-6067: Added checkStrmComponentLock() function.
** 30.10.2009 rajarsar ECPD-12630: Added getCompSetSortOrder and getCompSet function.
** 11.03.2010 madondin ECPD-13308: Added getPeriodCompSet function.
** 06.05.2010 oonnnng  ECPD-14276: Added checkEqpmReferenceValueLock() and checkWellReferenceValueLock() functions.
** 09.11.2010 rajarsar ECPD-15008: Added checkChokeModelRefValueLock()
** 19.06.2012 limmmchu ECPD-21070: Modified getPeriodCompSet() to included STRM_OIL_COMP, STRM_LNG_COMP and STRM_PC_COMP
** 17.09.2013 wonggkai ECPD-25076: Modified CheckFluidComponentLock, changed p_new_lock_columns checking.
** 24.09.2013 wonggkai ECPD-25076: Modified CheckAnalysisLock, rollback previous changes
** 10.10.2018 rainanid ECPD-58847: Added checkFctyReferenceValueLock()
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : checkAnalysisLock
-- Description    :
--
-- Preconditions  : Checks whether a valid last dated analysis record affects a locked month.
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: EcDp_Fluid_Analysis.getNextAnalysisSample,
--                  EcDp_Fluid_Analysis.getLastAnalysisSample,
--                  EcDp_Month_Lock.checkUpdateOfLDOForLock,
--                  EcDp_Month_Lock.buildIdentifierString,
--                  EcDp_Month_Lock.checkIfColumnsUpdated,
--                  EcDp_Month_Lock.validatePeriodForLockOverlap
--
-- Configuration
-- required       :
--
-- Behaviour      : Allows certain changes in valid dates if they appear outside locked month.
--
-- Updating sample data is not allowed if the period of the current record and the trailing next record (if any)
-- overlap a locked month.
--
-- Updating VALID_FROM_DATE is not allowed if the following situations appear:
--
--   Current or the new date values are within a locked month. Except it should be possible to move the VALID_FROM_DATE for analysis 4 from early April to the 1st of May in order to make the analysis 3 valid throughout April.
--   The period of the new dated analysis and the next trailing analysis (if any) overlap another locked period.
--   The date transition on a locked period passes by a locked month. Moving analysis 3 to June is allowed, but not to move analysis 4 to June.
--
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE checkAnalysisLock(p_operation VARCHAR2, p_new_lock_columns IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns IN OUT EcDp_Month_Lock.column_list)
--</EC-DOC>
IS

ld_new_current_valid DATE;
ld_old_current_valid DATE;
ld_new_next_valid DATE;
ld_old_next_valid DATE;
ld_old_prev_valid DATE;
lv2_new_status VARCHAR2(100);
lv2_old_status VARCHAR2(100);

ld_locked_month DATE;
lv2_id VARCHAR2(2000);

lr_analysis object_fluid_analysis%ROWTYPE;
lv2_columns_updated VARCHAR2(1);
lv2_valid_from_name  VARCHAR2(100);

lv2_o_obj_id                  VARCHAR2(32);
lv2_n_obj_id                  VARCHAR2(32);

BEGIN

   IF p_new_lock_columns.exists('VALID_FROM_DATE') THEN
      ld_new_current_valid := p_new_lock_columns('VALID_FROM_DATE').column_data.AccessDate;
      ld_old_current_valid := p_old_lock_columns('VALID_FROM_DATE').column_data.AccessDate;
      lv2_valid_from_name := 'VALID_FROM_DATE';
   ELSIF p_new_lock_columns.exists('VALID_FROM') THEN
      ld_new_current_valid := p_new_lock_columns('VALID_FROM').column_data.AccessDate;
      ld_old_current_valid := p_old_lock_columns('VALID_FROM').column_data.AccessDate;
      lv2_valid_from_name := 'VALID_FROM';
   ELSE
      ld_new_current_valid := p_new_lock_columns('DAYTIME').column_data.AccessDate;
      ld_old_current_valid := p_old_lock_columns('DAYTIME').column_data.AccessDate;
      lv2_valid_from_name := 'DAYTIME';
   END IF;

   IF p_old_lock_columns.EXISTS('OBJECT_ID') THEN
      lv2_o_obj_id := p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
   END IF;

   IF p_new_lock_columns.EXISTS('OBJECT_ID') THEN
      lv2_n_obj_id := p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
   END IF;

   IF NOT (ld_new_current_valid IS NULL AND ld_old_current_valid IS NULL) THEN


      lv2_new_status := p_new_lock_columns('ANALYSIS_STATUS').column_data.Accessvarchar2;
      lv2_old_status := p_old_lock_columns('ANALYSIS_STATUS').column_data.Accessvarchar2;

      IF p_operation = 'INSERTING' THEN -- Only when inserting new valid analysis

         IF lv2_new_status = 'APPROVED' THEN -- Only test approved records

            lr_analysis := EcDp_Fluid_Analysis.getNextAnalysisSample(
                                 p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                                 p_new_lock_columns('ANALYSIS_TYPE').column_data.AccessVarchar2,
                                 p_new_lock_columns('SAMPLING_METHOD').column_data.AccessVarchar2,
                                 ld_new_current_valid);

            ld_new_next_valid := lr_analysis.valid_from_date;
            lv2_id := EcDp_Month_Lock.buildIdentifierString(p_new_lock_columns);
              EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_new_current_valid, ld_new_next_valid, lv2_id, lv2_n_obj_id);

         END IF;

      ELSIF p_operation = 'UPDATING' THEN

         IF Nvl(lv2_new_status,'X') = 'APPROVED' OR Nvl(lv2_old_status,'Y') = 'APPROVED' THEN -- Only test on approved records

            lv2_id := EcDp_Month_Lock.buildIdentifierString(p_new_lock_columns);

            -- get the next valid daytime
            lr_analysis := EcDp_Fluid_Analysis.getNextAnalysisSample(
            p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
            p_new_lock_columns('ANALYSIS_TYPE').column_data.AccessVarchar2,
            p_new_lock_columns('SAMPLING_METHOD').column_data.AccessVarchar2,
            ld_new_current_valid);

            ld_new_next_valid := lr_analysis.valid_from_date;

            lr_analysis := EcDp_Fluid_Analysis.getNextAnalysisSample(
                                  p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                                  p_old_lock_columns('ANALYSIS_TYPE').column_data.AccessVarchar2,
                                  p_old_lock_columns('SAMPLING_METHOD').column_data.AccessVarchar2,
                                  ld_old_current_valid);

            ld_old_next_valid := lr_analysis.valid_from_date;

            IF ld_new_next_valid = ld_old_current_valid THEN
               ld_new_next_valid := ld_old_next_valid;
            END IF;

            -- Get previous record

            lr_analysis := EcDp_Fluid_Analysis.getLastAnalysisSample(
                           p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           p_new_lock_columns('ANALYSIS_TYPE').column_data.AccessVarchar2,
                           p_new_lock_columns('SAMPLING_METHOD').column_data.AccessVarchar2,
                           ld_old_current_valid - 1/86400);

            ld_old_prev_valid := lr_analysis.valid_from_date;

            p_old_lock_columns(lv2_valid_from_name).is_checked := 'Y';
            IF EcDp_Month_Lock.checkIfColumnsUpdated(p_old_lock_columns) THEN
               lv2_columns_updated := 'Y';
            ELSE
               lv2_columns_updated := 'N';
            END IF;

            EcDp_Month_Lock.checkUpdateOfLDOForLock(ld_new_current_valid,
                                                   ld_old_current_valid,
                                                   ld_new_next_valid,
                                                   ld_old_next_valid,
                                                   ld_old_prev_valid,
                                                   lv2_columns_updated,
                                                   lv2_id,
                                                   lv2_n_obj_id);

         END IF; -- Approved records

      ELSIF p_operation = 'DELETING' THEN -- Only when deleting a valid analysis

         IF lv2_old_status = 'APPROVED' THEN -- Only test approved records

            lr_analysis := EcDp_Fluid_Analysis.getNextAnalysisSample(
                               p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                               p_old_lock_columns('ANALYSIS_TYPE').column_data.AccessVarchar2,
                               p_old_lock_columns('SAMPLING_METHOD').column_data.AccessVarchar2,
                               ld_old_current_valid);

            ld_old_next_valid := lr_analysis.valid_from_date;
            lv2_id := EcDp_Month_Lock.buildIdentifierString(p_old_lock_columns);
            EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_old_current_valid, ld_old_next_valid, lv2_id, lv2_o_obj_id);

         END IF;

      END IF;
   END IF;

END checkAnalysisLock;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : checkAGAAnalysisLock
-- Description    :
--
-- Preconditions  : Checks whether a valid last dated AGA analysis record affects a locked month.
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: EcDp_Stream_Analysis.getNextAGAAnalysisSample,
--                  EcDp_Stream_Analysis.getAGAAnalysis,
--                  EcDp_Month_Lock.checkUpdateOfLDOForLock,
--                  EcDp_Month_Lock.buildIdentifierString,
--                  EcDp_Month_Lock.checkIfColumnsUpdated,
--                  EcDp_Month_Lock.validatePeriodForLockOverlap
--
-- Configuration
-- required       :
--
-- Behaviour      : Allows certain changes in valid dates if they appear outside locked month.
--
-- Updating sample data is not allowed if the period of the current record and the trailing next record (if any)
-- overlap a locked month.
--
-- Updating VALID_FROM_DATE is not allowed if the following situations appear:
--
--   Current or the new date values are within a locked month. Except it should be possible to move the VALID_FROM_DATE for analysis 4 from early April to the 1st of May in order to make the analysis 3 valid throughout April.
--   The period of the new dated analysis and the next trailing analysis (if any) overlap another locked period.
--   The date transition on a locked period passes by a locked month. Moving analysis 3 to June is allowed, but not to move analysis 4 to June.
--
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE checkAGAAnalysisLock(p_operation VARCHAR2, p_new_lock_columns  IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns  IN OUT EcDp_Month_Lock.column_list)
--</EC-DOC>
IS

ld_new_current_valid DATE;
ld_old_current_valid DATE;
ld_new_next_valid DATE;
ld_old_next_valid DATE;
ld_old_prev_valid DATE;
lv2_new_status VARCHAR2(100);
lv2_old_status VARCHAR2(100);

ld_locked_month DATE;
lv2_id VARCHAR2(2000);

lr_analysis object_aga_analysis%ROWTYPE;
lv2_columns_updated VARCHAR2(1);

lv2_o_obj_id                  VARCHAR2(32);
lv2_n_obj_id                  VARCHAR2(32);

BEGIN

   ld_new_current_valid := p_new_lock_columns('VALID_FROM_DATE').column_data.AccessDate;
   ld_old_current_valid := p_old_lock_columns('VALID_FROM_DATE').column_data.AccessDate;

   IF p_old_lock_columns.EXISTS('OBJECT_ID')  THEN
      lv2_o_obj_id := p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
   END IF;

   IF p_new_lock_columns.EXISTS('OBJECT_ID')  THEN
      lv2_n_obj_id := p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
   END IF;

   IF NOT (ld_new_current_valid IS NULL AND ld_old_current_valid IS NULL) THEN

      lv2_new_status := p_new_lock_columns('ANALYSIS_STATUS').column_data.Accessvarchar2;
      lv2_old_status := p_old_lock_columns('ANALYSIS_STATUS').column_data.Accessvarchar2;

      IF p_operation = 'INSERTING' THEN -- Only when inserting new valid analysis

         IF lv2_new_status = 'APPROVED' THEN -- Only test approved records

            lr_analysis := EcDp_Stream_Analysis.getNextAGAAnalysisSample(
                                 p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                                 ld_new_current_valid);

            ld_new_next_valid := lr_analysis.valid_from_date;
            lv2_id := EcDp_Month_Lock.buildIdentifierString(p_new_lock_columns);
            EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_new_current_valid, ld_new_next_valid, lv2_id, lv2_n_obj_id);

         END IF;

      ELSIF p_operation = 'UPDATING' THEN

         IF Nvl(lv2_new_status,'X') = 'APPROVED' OR Nvl(lv2_old_status,'Y') = 'APPROVED' THEN -- Only test on approved records

            lv2_id := EcDp_Month_Lock.buildIdentifierString(p_new_lock_columns);

            -- get the next valid daytime
            lr_analysis := EcDp_Stream_Analysis.getNextAGAAnalysisSample(
                p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                ld_new_current_valid);

            ld_new_next_valid := lr_analysis.valid_from_date;

            lr_analysis := EcDp_Stream_Analysis.getNextAGAAnalysisSample(
                                  p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                                  ld_old_current_valid);

            ld_old_next_valid := lr_analysis.valid_from_date;

            IF ld_new_next_valid = ld_old_current_valid THEN
               ld_new_next_valid := ld_old_next_valid;
            END IF;

            -- Get previous record

            lr_analysis := EcDp_Stream_Analysis.getAGAAnalysis(
                           p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_old_current_valid - 1/86400);

            ld_old_prev_valid := lr_analysis.valid_from_date;

            p_old_lock_columns('VALID_FROM_DATE').is_checked := 'Y';
            IF EcDp_Month_Lock.checkIfColumnsUpdated(p_old_lock_columns) THEN
               lv2_columns_updated := 'Y';
            ELSE
               lv2_columns_updated := 'N';
            END IF;

            EcDp_Month_Lock.checkUpdateOfLDOForLock(ld_new_current_valid,
                                                   ld_old_current_valid,
                                                   ld_new_next_valid,
                                                   ld_old_next_valid,
                                                   ld_old_prev_valid,
                                                   lv2_columns_updated,
                                                   lv2_id,
                                                   lv2_n_obj_id);
         END IF;

      ELSIF p_operation = 'DELETING' THEN -- Only when deleting a valid analysis

         IF lv2_old_status = 'APPROVED' THEN -- Only test approved records

            lr_analysis := EcDp_Stream_Analysis.getNextAGAAnalysisSample(
                               p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                               ld_old_current_valid);

            ld_old_next_valid := lr_analysis.valid_from_date;
            lv2_id := EcDp_Month_Lock.buildIdentifierString(p_old_lock_columns);
            EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_old_current_valid, ld_old_next_valid, lv2_id, lv2_o_obj_id);

         END IF;
      END IF;
   END IF;

END checkAGAAnalysisLock;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : CheckFluidComponentLock
-- Description    :
--
-- Preconditions  : Checks whether a fluid component analysis record affects a locked month.
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: ec_object_fluid_analysis,
--                  checkAnalysisLock
--
-- Configuration
-- required       :
--
-- Behaviour      : Considered as an update on the parent analysis record.
--
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE CheckFluidComponentLock(p_operation VARCHAR2, p_new_lock_columns EcDp_Month_lock.column_list, p_old_lock_columns EcDp_Month_lock.column_list)
--</EC-DOC>
IS

lr_analysis object_fluid_analysis%ROWTYPE;
l_new_lock_columns EcDp_Month_lock.column_list;
l_old_lock_columns EcDp_Month_lock.column_list;

BEGIN

   IF p_operation IN ('INSERTING','UPDATING') THEN
      lr_analysis := ec_object_fluid_analysis.row_by_pk(p_new_lock_columns('ANALYSIS_NO').column_data.AccessNumber);

   ELSE
      lr_analysis := ec_object_fluid_analysis.row_by_pk(p_old_lock_columns('ANALYSIS_NO').column_data.AccessNumber);
   END IF;

   IF p_new_lock_columns.exists('VALID_FROM_DATE') THEN

      EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'VALID_FROM_DATE','VALID_FROM_DATE','DATE','N','N',AnyData.Convertdate(lr_analysis.valid_from_date));
      EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'VALID_FROM_DATE','VALID_FROM_DATE','DATE','N','N',AnyData.Convertdate(lr_analysis.valid_from_date));

   ELSIF  p_new_lock_columns.exists('VALID_FROM') THEN

      EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'VALID_FROM','VALID_FROM_DATE','DATE','N','N',AnyData.Convertdate(lr_analysis.valid_from_date));
      EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'VALID_FROM','VALID_FROM_DATE','DATE','N','N',AnyData.Convertdate(lr_analysis.valid_from_date));

   ELSE

      EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'DAYTIME','DAYTIME','DATE','N','N',AnyData.Convertdate(NVL(lr_analysis.valid_from_date,lr_analysis.daytime)));
      EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'DAYTIME','DAYTIME','DATE','N','N',AnyData.Convertdate(NVL(lr_analysis.valid_from_date,lr_analysis.daytime)));

   END IF;





   -- Populate parent table columns in structure.
   EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'CLASS_NAME','FLUID_ANALYSIS_COMPONENT','VARCHAR2','N','N', NULL);
   EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'OBJECT_ID','OBJECT_ID','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_analysis.object_id));
   EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'ANALYSIS_TYPE','ANALYSIS_TYPE','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_analysis.analysis_type));
   EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'SAMPLING_METHOD','SAMPLING_METHOD','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_analysis.sampling_method));
   EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'PHASE','PHASE','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_analysis.phase));
   EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'ANALYSIS_NO','ANALYSIS_NO','NUMBER','N','N',AnyData.ConvertNumber(lr_analysis.analysis_no));
   EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'ANALYSIS_STATUS','ANALYSIS_STATUS','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_analysis.analysis_status));

   EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'CLASS_NAME','FLUID_ANALYSIS_COMPONENT','VARCHAR2','N','N', NULL);
   EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'OBJECT_ID','OBJECT_ID','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_analysis.object_id));
   EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'ANALYSIS_TYPE','ANALYSIS_TYPE','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_analysis.analysis_type));
   EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'SAMPLING_METHOD','SAMPLING_METHOD','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_analysis.sampling_method));
   EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'PHASE','PHASE','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_analysis.phase));
   EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'ANALYSIS_NO','ANALYSIS_NO','NUMBER','N','N',AnyData.ConvertNumber(lr_analysis.analysis_no));
   EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'ANALYSIS_STATUS','ANALYSIS_STATUS','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_analysis.analysis_status));

   -- Do whatever you want as long the parent is unlocked
   checkAnalysisLock('UPDATING', l_new_lock_columns, l_old_lock_columns);

END CheckFluidComponentLock;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : checkStrmReferenceValueLock
-- Description    :
--
-- Preconditions  : Checks whether a last dated stream reference record affects a locked month.
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: ec_strm_reference_value,
--                  EcDp_Month_Lock.checkUpdateOfLDOForLock,
--                  EcDp_Month_Lock.buildIdentifierString,
--                  EcDp_Month_Lock.checkIfColumnsUpdated,
--                  EcDp_Month_Lock.validatePeriodForLockOverlap
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE checkStrmReferenceValueLock(p_operation VARCHAR2, p_new_lock_columns  IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns  IN OUT EcDp_Month_Lock.column_list)
--</EC-DOC>
IS

ld_new_current_valid DATE;
ld_old_current_valid DATE;
ld_new_next_valid DATE;
ld_old_next_valid DATE;
ld_old_prev_valid DATE;

ld_locked_month DATE;
lv2_id VARCHAR2(2000);
lv2_columns_updated VARCHAR2(1);

lv2_o_obj_id                  VARCHAR2(32);
lv2_n_obj_id                  VARCHAR2(32);

BEGIN

   ld_new_current_valid := p_new_lock_columns('DAYTIME').column_data.AccessDate;
   ld_old_current_valid := p_old_lock_columns('DAYTIME').column_data.AccessDate;

   IF p_old_lock_columns.EXISTS('OBJECT_ID')  THEN
      lv2_o_obj_id := p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
   END IF;

   IF p_new_lock_columns.EXISTS('OBJECT_ID')  THEN
      lv2_n_obj_id := p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
   END IF;

   IF p_operation = 'INSERTING' THEN -- Only when inserting new valid analysis

      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_new_lock_columns);

      ld_new_next_valid := ec_strm_reference_value.next_daytime(
                           p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_new_current_valid);

      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_new_current_valid, ld_new_next_valid, lv2_id, lv2_n_obj_id);

   ELSIF p_operation = 'UPDATING' THEN

      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_new_lock_columns);

      -- get the next valid daytime
      ld_new_next_valid := ec_strm_reference_value.next_daytime(
                           p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_new_current_valid);

      ld_old_next_valid := ec_strm_reference_value.next_daytime(
                           p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_old_current_valid);

      IF ld_new_next_valid = ld_old_current_valid THEN
         ld_new_next_valid := ld_old_next_valid;
      END IF;

      -- Get previous record
      ld_old_prev_valid := ec_strm_reference_value.prev_daytime(
                                  p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                                  ld_old_current_valid);

      p_old_lock_columns('DAYTIME').is_checked := 'Y';

      IF EcDp_Month_Lock.checkIfColumnsUpdated(p_old_lock_columns) THEN
         lv2_columns_updated := 'Y';
      ELSE
         lv2_columns_updated := 'N';
      END IF;

      EcDp_Month_Lock.checkUpdateOfLDOForLock(ld_new_current_valid,
                                             ld_old_current_valid,
                                             ld_new_next_valid,
                                             ld_old_next_valid,
                                             ld_old_prev_valid,
                                             lv2_columns_updated,
                                             lv2_id,
                                             lv2_n_obj_id);

   ELSIF p_operation = 'DELETING' THEN -- Only when deleting a valid analysis

      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_old_lock_columns);

      ld_old_next_valid := ec_strm_reference_value.next_daytime(
                           p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_old_current_valid);

      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_old_current_valid, ld_old_next_valid, lv2_id, lv2_o_obj_id);

   END IF;

END checkStrmReferenceValueLock;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : checkEqpmReferenceValueLock
-- Description    :
--
-- Preconditions  : Checks whether a last dated equipment reference record affects a locked month.
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: ec_eqpm_reference_value,
--                  EcDp_Month_Lock.checkUpdateOfLDOForLock,
--                  EcDp_Month_Lock.buildIdentifierString,
--                  EcDp_Month_Lock.checkIfColumnsUpdated,
--                  EcDp_Month_Lock.validatePeriodForLockOverlap
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE checkEqpmReferenceValueLock(p_operation VARCHAR2, p_new_lock_columns  IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns  IN OUT EcDp_Month_Lock.column_list)
--</EC-DOC>
IS

ld_new_current_valid DATE;
ld_old_current_valid DATE;
ld_new_next_valid DATE;
ld_old_next_valid DATE;
ld_old_prev_valid DATE;

ld_locked_month DATE;
lv2_id VARCHAR2(2000);
lv2_columns_updated VARCHAR2(1);

lv2_o_obj_id                  VARCHAR2(32);
lv2_n_obj_id                  VARCHAR2(32);

BEGIN

   ld_new_current_valid := p_new_lock_columns('DAYTIME').column_data.AccessDate;
   ld_old_current_valid := p_old_lock_columns('DAYTIME').column_data.AccessDate;

   IF p_old_lock_columns.EXISTS('OBJECT_ID')  THEN
      lv2_o_obj_id := p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
   END IF;

   IF p_new_lock_columns.EXISTS('OBJECT_ID')  THEN
      lv2_n_obj_id := p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
   END IF;

   IF p_operation = 'INSERTING' THEN -- Only when inserting new valid analysis

      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_new_lock_columns);

      ld_new_next_valid := ec_eqpm_reference_value.next_daytime(
                           p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_new_current_valid);

      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_new_current_valid, ld_new_next_valid, lv2_id, lv2_n_obj_id);

   ELSIF p_operation = 'UPDATING' THEN

      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_new_lock_columns);

      -- get the next valid daytime
      ld_new_next_valid := ec_eqpm_reference_value.next_daytime(
                           p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_new_current_valid);

      ld_old_next_valid := ec_eqpm_reference_value.next_daytime(
                           p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_old_current_valid);

      IF ld_new_next_valid = ld_old_current_valid THEN
         ld_new_next_valid := ld_old_next_valid;
      END IF;

      -- Get previous record
      ld_old_prev_valid := ec_eqpm_reference_value.prev_daytime(
                                  p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                                  ld_old_current_valid);

      p_old_lock_columns('DAYTIME').is_checked := 'Y';

      IF EcDp_Month_Lock.checkIfColumnsUpdated(p_old_lock_columns) THEN
         lv2_columns_updated := 'Y';
      ELSE
         lv2_columns_updated := 'N';
      END IF;

      EcDp_Month_Lock.checkUpdateOfLDOForLock(ld_new_current_valid,
                                             ld_old_current_valid,
                                             ld_new_next_valid,
                                             ld_old_next_valid,
                                             ld_old_prev_valid,
                                             lv2_columns_updated,
                                             lv2_id,
                                             lv2_n_obj_id);

   ELSIF p_operation = 'DELETING' THEN -- Only when deleting a valid analysis

      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_old_lock_columns);

      ld_old_next_valid := ec_eqpm_reference_value.next_daytime(
                           p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_old_current_valid);

      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_old_current_valid, ld_old_next_valid, lv2_id, lv2_o_obj_id);

   END IF;

END checkEqpmReferenceValueLock;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : checkWellReferenceValueLock
-- Description    :
--
-- Preconditions  : Checks whether a last dated well reference record affects a locked month.
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: ec_well_reference_value,
--                  EcDp_Month_Lock.checkUpdateOfLDOForLock,
--                  EcDp_Month_Lock.buildIdentifierString,
--                  EcDp_Month_Lock.checkIfColumnsUpdated,
--                  EcDp_Month_Lock.validatePeriodForLockOverlap
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE checkWellReferenceValueLock(p_operation VARCHAR2, p_new_lock_columns  IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns  IN OUT EcDp_Month_Lock.column_list)
--</EC-DOC>
IS

ld_new_current_valid DATE;
ld_old_current_valid DATE;
ld_new_next_valid DATE;
ld_old_next_valid DATE;
ld_old_prev_valid DATE;

ld_locked_month DATE;
lv2_id VARCHAR2(2000);
lv2_columns_updated VARCHAR2(1);

lv2_o_obj_id                  VARCHAR2(32);
lv2_n_obj_id                  VARCHAR2(32);

BEGIN

   ld_new_current_valid := p_new_lock_columns('DAYTIME').column_data.AccessDate;
   ld_old_current_valid := p_old_lock_columns('DAYTIME').column_data.AccessDate;

   IF p_old_lock_columns.EXISTS('OBJECT_ID')  THEN
      lv2_o_obj_id := p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
   END IF;

   IF p_new_lock_columns.EXISTS('OBJECT_ID')  THEN
      lv2_n_obj_id := p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
   END IF;

   IF p_operation = 'INSERTING' THEN -- Only when inserting new valid analysis

      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_new_lock_columns);

      ld_new_next_valid := ec_well_reference_value.next_daytime(
                           p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_new_current_valid);

      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_new_current_valid, ld_new_next_valid, lv2_id, lv2_n_obj_id);

   ELSIF p_operation = 'UPDATING' THEN

      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_new_lock_columns);

      -- get the next valid daytime
      ld_new_next_valid := ec_well_reference_value.next_daytime(
                           p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_new_current_valid);

      ld_old_next_valid := ec_well_reference_value.next_daytime(
                           p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_old_current_valid);

      IF ld_new_next_valid = ld_old_current_valid THEN
         ld_new_next_valid := ld_old_next_valid;
      END IF;

      -- Get previous record
      ld_old_prev_valid := ec_well_reference_value.prev_daytime(
                                  p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                                  ld_old_current_valid);

      p_old_lock_columns('DAYTIME').is_checked := 'Y';

      IF EcDp_Month_Lock.checkIfColumnsUpdated(p_old_lock_columns) THEN
         lv2_columns_updated := 'Y';
      ELSE
         lv2_columns_updated := 'N';
      END IF;

      EcDp_Month_Lock.checkUpdateOfLDOForLock(ld_new_current_valid,
                                             ld_old_current_valid,
                                             ld_new_next_valid,
                                             ld_old_next_valid,
                                             ld_old_prev_valid,
                                             lv2_columns_updated,
                                             lv2_id,
                                             lv2_n_obj_id);

   ELSIF p_operation = 'DELETING' THEN -- Only when deleting a valid analysis

      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_old_lock_columns);

      ld_old_next_valid := ec_well_reference_value.next_daytime(
                           p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_old_current_valid);

      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_old_current_valid, ld_old_next_valid, lv2_id, lv2_o_obj_id);

   END IF;

END checkWellReferenceValueLock;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : checkStrmWaterAnalysisLock
-- Description    :
--
-- Preconditions  : Checks whether a last dated stream water analysis record affects a locked month.
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: ec_strm_water_analysis,
--                  EcDp_Month_Lock.checkUpdateOfLDOForLock,
--                  EcDp_Month_Lock.buildIdentifierString,
--                  EcDp_Month_Lock.checkIfColumnsUpdated,
--                  EcDp_Month_Lock.validatePeriodForLockOverlap
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE checkStrmWaterAnalysisLock(p_operation VARCHAR2, p_new_lock_columns  IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns  IN OUT EcDp_Month_Lock.column_list)
--</EC-DOC>
IS

ld_new_current_valid DATE;
ld_old_current_valid DATE;
ld_new_next_valid DATE;
ld_old_next_valid DATE;
ld_old_prev_valid DATE;

ld_locked_month DATE;
lv2_id VARCHAR2(2000);
lv2_columns_updated VARCHAR2(1);

lv2_o_obj_id                  VARCHAR2(32);
lv2_n_obj_id                  VARCHAR2(32);

BEGIN

   ld_new_current_valid := p_new_lock_columns('DAYTIME').column_data.AccessDate;
   ld_old_current_valid := p_old_lock_columns('DAYTIME').column_data.AccessDate;

   IF p_old_lock_columns.EXISTS('OBJECT_ID')  THEN
      lv2_o_obj_id := p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
   END IF;

   IF p_new_lock_columns.EXISTS('OBJECT_ID')  THEN
      lv2_n_obj_id := p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
   END IF;

   IF p_operation = 'INSERTING' THEN -- Only when inserting new valid analysis

      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_new_lock_columns);

      ld_new_next_valid := ec_strm_water_analysis.next_daytime(
                           p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_new_current_valid,
                           'DAY_SAMPLER');

      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_new_current_valid, ld_new_next_valid, lv2_id, lv2_n_obj_id);

   ELSIF p_operation = 'UPDATING' THEN

      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_new_lock_columns);

      -- get the next valid daytime
      ld_new_next_valid := ec_strm_water_analysis.next_daytime(
                           p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_new_current_valid,
                           'DAY_SAMPLER');

      ld_old_next_valid := ec_strm_water_analysis.next_daytime(
                           p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_old_current_valid,
                           'DAY_SAMPLER');

      IF ld_new_next_valid = ld_old_current_valid THEN
         ld_new_next_valid := ld_old_next_valid;
      END IF;

      -- Get previous record
      ld_old_prev_valid := ec_strm_water_analysis.prev_daytime(
                                  p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                                  ld_old_current_valid,
                                  'DAY_SAMPLER');

      p_old_lock_columns('DAYTIME').is_checked := 'Y';

      IF EcDp_Month_Lock.checkIfColumnsUpdated(p_old_lock_columns) THEN
         lv2_columns_updated := 'Y';
      ELSE
         lv2_columns_updated := 'N';
      END IF;

      EcDp_Month_Lock.checkUpdateOfLDOForLock(ld_new_current_valid,
                                             ld_old_current_valid,
                                             ld_new_next_valid,
                                             ld_old_next_valid,
                                             ld_old_prev_valid,
                                             lv2_columns_updated,
                                             lv2_id,
                                             lv2_n_obj_id);

   ELSIF p_operation = 'DELETING' THEN -- Only when deleting a valid analysis

      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_old_lock_columns);

      ld_old_next_valid := ec_strm_water_analysis.next_daytime(
                           p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_old_current_valid,
                           'DAY_SAMPLER');

      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_old_current_valid, ld_old_next_valid, lv2_id, lv2_n_obj_id);

   END IF;

END checkStrmWaterAnalysisLock;

PROCEDURE CheckFluidProductLock(p_operation VARCHAR2, p_new_lock_columns EcDp_Month_lock.column_list, p_old_lock_columns EcDp_Month_lock.column_list)
--</EC-DOC>
IS

lr_analysis object_fluid_analysis%ROWTYPE;
l_new_lock_columns EcDp_Month_lock.column_list;
l_old_lock_columns EcDp_Month_lock.column_list;

BEGIN

   IF p_operation IN ('INSERTING','UPDATING') THEN
      lr_analysis := ec_object_fluid_analysis.row_by_pk(p_new_lock_columns('ANALYSIS_NO').column_data.AccessNumber);

   ELSE
      lr_analysis := ec_object_fluid_analysis.row_by_pk(p_old_lock_columns('ANALYSIS_NO').column_data.AccessNumber);
   END IF;

   IF p_new_lock_columns.exists('VALID_FROM_DATE') THEN

      EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'VALID_FROM_DATE','VALID_FROM_DATE','DATE','N','N',AnyData.Convertdate(lr_analysis.valid_from_date));
      EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'VALID_FROM_DATE','VALID_FROM_DATE','DATE','N','N',AnyData.Convertdate(lr_analysis.valid_from_date));

   ELSIF  p_new_lock_columns.exists('VALID_FROM') THEN

      EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'VALID_FROM','VALID_FROM_DATE','DATE','N','N',AnyData.Convertdate(lr_analysis.valid_from_date));
      EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'VALID_FROM','VALID_FROM_DATE','DATE','N','N',AnyData.Convertdate(lr_analysis.valid_from_date));

   ELSE

      EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'DAYTIME','DAYTIME','DATE','N','N',AnyData.Convertdate(lr_analysis.daytime));
      EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'DAYTIME','DAYTIME','DATE','N','N',AnyData.Convertdate(lr_analysis.daytime));

   END IF;





   -- Populate parent table columns in structure.
   EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'CLASS_NAME','FLUID_ANALYSIS_PRODUCT','VARCHAR2','N','N', NULL);
   EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'OBJECT_ID','OBJECT_ID','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_analysis.object_id));
   EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'ANALYSIS_TYPE','ANALYSIS_TYPE','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_analysis.analysis_type));
   EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'SAMPLING_METHOD','SAMPLING_METHOD','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_analysis.sampling_method));
   EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'PHASE','PHASE','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_analysis.phase));
   EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'ANALYSIS_NO','ANALYSIS_NO','NUMBER','N','N',AnyData.ConvertNumber(lr_analysis.analysis_no));
   EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'ANALYSIS_STATUS','ANALYSIS_STATUS','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_analysis.analysis_status));

   EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'CLASS_NAME','FLUID_ANALYSIS_PRODUCT','VARCHAR2','N','N', NULL);
   EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'OBJECT_ID','OBJECT_ID','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_analysis.object_id));
   EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'ANALYSIS_TYPE','ANALYSIS_TYPE','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_analysis.analysis_type));
   EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'SAMPLING_METHOD','SAMPLING_METHOD','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_analysis.sampling_method));
   EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'PHASE','PHASE','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_analysis.phase));
   EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'ANALYSIS_NO','ANALYSIS_NO','NUMBER','N','N',AnyData.ConvertNumber(lr_analysis.analysis_no));
   EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'ANALYSIS_STATUS','ANALYSIS_STATUS','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_analysis.analysis_status));

   -- Do whatever you want as long the parent is unlocked
   checkAnalysisLock('UPDATING', l_new_lock_columns, l_old_lock_columns);

END CheckFluidProductLock;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : checkStrmComponentLock
-- Description    :
--
-- Preconditions  : Checks whether a stream component analysis record affects a locked month.
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: ec_strm_analysis_event,
--                  checkAnalysisLock
--
-- Configuration
-- required       :
--
-- Behaviour      : Considered as an update on the parent analysis record.
--
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE checkStrmComponentLock(p_operation VARCHAR2, p_new_lock_columns EcDp_Month_lock.column_list, p_old_lock_columns EcDp_Month_lock.column_list)
--</EC-DOC>
IS

lr_analysis strm_analysis_event%ROWTYPE;
l_new_lock_columns EcDp_Month_lock.column_list;
l_old_lock_columns EcDp_Month_lock.column_list;


BEGIN

   IF p_operation IN ('INSERTING','UPDATING') THEN
      lr_analysis := ec_strm_analysis_event.row_by_pk(p_new_lock_columns('ANALYSIS_NO').column_data.AccessNumber);

   ELSE
      lr_analysis := ec_strm_analysis_event.row_by_pk(p_old_lock_columns('ANALYSIS_NO').column_data.AccessNumber);
   END IF;

   IF p_new_lock_columns.exists('VALID_FROM_DATE') THEN

      EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'VALID_FROM_DATE','VALID_FROM_DATE','DATE','N','N',AnyData.Convertdate(lr_analysis.valid_from_date));
      EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'VALID_FROM_DATE','VALID_FROM_DATE','DATE','N','N',AnyData.Convertdate(lr_analysis.valid_from_date));

   ELSIF  p_new_lock_columns.exists('VALID_FROM') THEN

      EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'VALID_FROM','VALID_FROM_DATE','DATE','N','N',AnyData.Convertdate(lr_analysis.valid_from_date));
      EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'VALID_FROM','VALID_FROM_DATE','DATE','N','N',AnyData.Convertdate(lr_analysis.valid_from_date));

   ELSE

      EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'DAYTIME','DAYTIME','DATE','N','N',AnyData.Convertdate(lr_analysis.daytime));
      EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'DAYTIME','DAYTIME','DATE','N','N',AnyData.Convertdate(lr_analysis.daytime));

   END IF;

   -- Populate parent table columns in structure.
   EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'CLASS_NAME','FLUID_ANALYSIS_COMPONENT','VARCHAR2','N','N', NULL);
   EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'OBJECT_ID','OBJECT_ID','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_analysis.object_id));
   EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'ANALYSIS_TYPE','ANALYSIS_TYPE','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_analysis.analysis_type));
   EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'SAMPLING_METHOD','SAMPLING_METHOD','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_analysis.sampling_method));
   EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'PHASE','PHASE','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_analysis.phase));
   EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'ANALYSIS_NO','ANALYSIS_NO','NUMBER','N','N',AnyData.ConvertNumber(lr_analysis.analysis_no));
   EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'ANALYSIS_STATUS','ANALYSIS_STATUS','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_analysis.analysis_status));

   EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'CLASS_NAME','FLUID_ANALYSIS_COMPONENT','VARCHAR2','N','N', NULL);
   EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'OBJECT_ID','OBJECT_ID','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_analysis.object_id));
   EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'ANALYSIS_TYPE','ANALYSIS_TYPE','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_analysis.analysis_type));
   EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'SAMPLING_METHOD','SAMPLING_METHOD','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_analysis.sampling_method));
   EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'PHASE','PHASE','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_analysis.phase));
   EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'ANALYSIS_NO','ANALYSIS_NO','NUMBER','N','N',AnyData.ConvertNumber(lr_analysis.analysis_no));
   EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'ANALYSIS_STATUS','ANALYSIS_STATUS','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_analysis.analysis_status));

   -- Do whatever you want as long the parent is unlocked
   checkAnalysisLock('UPDATING', l_new_lock_columns, l_old_lock_columns);

END checkStrmComponentLock;




--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getCompSet
-- Description    :
--
-- Preconditions  : Get the component set from the configured value in WELL or STREAM
--
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
--
--
---------------------------------------------------------------------------------------------------
FUNCTION getCompSet( p_class_name VARCHAR2, p_object_id  VARCHAR2, p_daytime  DATE, p_analysis_type  VARCHAR2)
--</EC-DOC>

RETURN VARCHAR2
IS

   lr_well_version           well_version%ROWTYPE;
   lr_strm_version           strm_version%ROWTYPE;
   lr_fcty1_version          fcty_version%ROWTYPE;
   lr_fcty2_version          fcty_version%ROWTYPE;
   lv2_comp_set              VARCHAR2(16);


BEGIN


   IF p_class_name = 'WELL' THEN
      lr_well_version := ec_well_version.row_by_pk(p_object_id,p_daytime,'<=');
      lr_fcty1_version := ec_fcty_version.row_by_pk(lr_well_version.op_fcty_class_1_id,p_daytime,'<=');
   ELSIF p_class_name = 'STREAM' THEN
      lr_strm_version := ec_strm_version.row_by_pk(p_object_id,p_daytime,'<=');
      lr_fcty1_version := ec_fcty_version.row_by_pk(lr_strm_version.op_fcty_class_1_id,p_daytime,'<=');
      lr_fcty2_version := ec_fcty_version.row_by_pk(lr_strm_version.op_fcty_class_2_id,p_daytime,'<=');
   END IF;

   --for well,get configured comp_set from well_version,if null get from fcty1, if null get from default value
   IF p_analysis_type = 'WELL_GAS_COMP' THEN
      lv2_comp_set := Nvl(Nvl(lr_well_version.comp_gas_code, lr_fcty1_version.well_comp_gas_code), 'WELL_GAS_COMP');
   ELSIF p_analysis_type = 'WELL_FLSH_GS_CMP' THEN
      lv2_comp_set := Nvl(Nvl(lr_well_version.comp_gas_code, lr_fcty1_version.well_comp_gas_code), 'WELL_FLSH_GS_CMP');
   ELSIF p_analysis_type = 'WELL_INJ_COMP' THEN
      lv2_comp_set := Nvl(Nvl(lr_well_version.comp_gasinj_code,lr_fcty1_version.well_comp_gasinj_code),'WELL_INJ_COMP');
   ELSIF p_analysis_type = 'WELL_OIL_COMP' THEN
      lv2_comp_set := Nvl(Nvl(lr_well_version.comp_liq_code,lr_fcty1_version.well_comp_liq_code),'WELL_OIL_COMP');
   --for stream,get configured comp_set from strm_version,if null get from fcty1, if null get from fcty2, if null get from default value
   ELSIF p_analysis_type = 'STRM_OIL_COMP' THEN
      lv2_comp_set := Nvl(Nvl(lr_strm_version.comp_set_code,lr_fcty1_version.strm_comp_oil_code),Nvl(lr_fcty2_version.strm_comp_oil_code, 'STRM_OIL_COMP'));
   ELSIF p_analysis_type = 'STRM_GAS_COMP' THEN
      lv2_comp_set := Nvl(Nvl(lr_strm_version.comp_set_code,lr_fcty1_version.strm_comp_gas_code),Nvl(lr_fcty2_version.strm_comp_gas_code,'STRM_GAS_COMP'));
   ELSIF p_analysis_type = 'STRM_LNG_COMP' THEN
      lv2_comp_set := Nvl(Nvl(lr_strm_version.comp_set_code,lr_fcty1_version.strm_comp_lng_code),Nvl(lr_fcty2_version.strm_comp_lng_code,'STRM_LNG_COMP'));
   ELSIF p_analysis_type = 'STRM_PC_COMP' THEN
      lv2_comp_set := Nvl(Nvl(lr_strm_version.comp_set_code,lr_fcty1_version.strm_comp_pc_code),Nvl(lr_fcty2_version.strm_comp_pc_code,'STRM_PC_COMP'));
   END IF;

   RETURN lv2_comp_set;


END getCompSet;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getPeriodCompSet
-- Description    :
--
-- Preconditions  : Get the component set from the configured value in STREAM
--
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
--
--
---------------------------------------------------------------------------------------------------
FUNCTION getPeriodCompSet( p_object_id  VARCHAR2, p_daytime  DATE, p_analysis_type  VARCHAR2)
--</EC-DOC>

RETURN VARCHAR2
IS
   lr_strm_version           strm_version%ROWTYPE;
   lr_fcty1_version          fcty_version%ROWTYPE;
   lr_fcty2_version          fcty_version%ROWTYPE;
   lv2_period_comp_set       VARCHAR2(16);


BEGIN

   lr_strm_version := ec_strm_version.row_by_pk(p_object_id,p_daytime,'<=');
   lr_fcty1_version := ec_fcty_version.row_by_pk(lr_strm_version.op_fcty_class_1_id,p_daytime,'<=');
   lr_fcty2_version := ec_fcty_version.row_by_pk(lr_strm_version.op_fcty_class_2_id,p_daytime,'<=');

   IF p_analysis_type = 'STRM_OIL_COMP' THEN
      lv2_period_comp_set := Nvl(Nvl(lr_strm_version.comp_set_code,lr_fcty1_version.strm_comp_oil_code),Nvl(lr_fcty2_version.strm_comp_oil_code,'STRM_OIL_COMP'));
   ELSIF p_analysis_type = 'STRM_GAS_COMP' THEN
      lv2_period_comp_set := Nvl(Nvl(lr_strm_version.comp_set_code,lr_fcty1_version.strm_comp_gas_code),Nvl(lr_fcty2_version.strm_comp_gas_code,'STRM_GAS_COMP'));
   ELSIF p_analysis_type = 'STRM_LNG_COMP' THEN
      lv2_period_comp_set := Nvl(Nvl(lr_strm_version.comp_set_code,lr_fcty1_version.strm_comp_lng_code),Nvl(lr_fcty2_version.strm_comp_lng_code,'STRM_LNG_COMP'));
   ELSIF p_analysis_type = 'STRM_PC_COMP' THEN
      lv2_period_comp_set := Nvl(Nvl(lr_strm_version.comp_set_code,lr_fcty1_version.strm_comp_pc_code),Nvl(lr_fcty2_version.strm_comp_pc_code,'STRM_PC_COMP'));
   END IF;


   RETURN lv2_period_comp_set;


END getPeriodCompSet;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : checkChokeModelReferenceValueLock
-- Description    :
--
-- Preconditions  : Checks whether a last dated choke model reference record affects a locked month.
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: ec_choke_model_ref_value,
--                  EcDp_Month_Lock.checkUpdateOfLDOForLock,
--                  EcDp_Month_Lock.buildIdentifierString,
--                  EcDp_Month_Lock.checkIfColumnsUpdated,
--                  EcDp_Month_Lock.validatePeriodForLockOverlap
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE checkChokeModelRefValueLock(p_operation VARCHAR2, p_new_lock_columns  IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns  IN OUT EcDp_Month_Lock.column_list)
--</EC-DOC>
IS

ld_new_current_valid DATE;
ld_old_current_valid DATE;
ld_new_next_valid DATE;
ld_old_next_valid DATE;
ld_old_prev_valid DATE;

ld_locked_month DATE;
lv2_id VARCHAR2(2000);
lv2_columns_updated VARCHAR2(1);

lv2_o_obj_id                  VARCHAR2(32);
lv2_n_obj_id                  VARCHAR2(32);

BEGIN

   ld_new_current_valid := p_new_lock_columns('DAYTIME').column_data.AccessDate;
   ld_old_current_valid := p_old_lock_columns('DAYTIME').column_data.AccessDate;

   IF p_old_lock_columns.EXISTS('OBJECT_ID')  THEN
      lv2_o_obj_id := p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
   END IF;

   IF p_new_lock_columns.EXISTS('OBJECT_ID')  THEN
      lv2_n_obj_id := p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
   END IF;

   IF p_operation = 'INSERTING' THEN -- Only when inserting new valid analysis

      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_new_lock_columns);

      ld_new_next_valid := ec_choke_model_ref_value.next_daytime(
                           p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_new_current_valid);

      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_new_current_valid, ld_new_next_valid, lv2_id, lv2_n_obj_id);

   ELSIF p_operation = 'UPDATING' THEN

      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_new_lock_columns);

      -- get the next valid daytime
      ld_new_next_valid := ec_choke_model_ref_value.next_daytime(
                           p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_new_current_valid);

      ld_old_next_valid := ec_choke_model_ref_value.next_daytime(
                           p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_old_current_valid);

      IF ld_new_next_valid = ld_old_current_valid THEN
         ld_new_next_valid := ld_old_next_valid;
      END IF;

      -- Get previous record
      ld_old_prev_valid := ec_choke_model_ref_value.prev_daytime(
                                  p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                                  ld_old_current_valid);

      p_old_lock_columns('DAYTIME').is_checked := 'Y';

      IF EcDp_Month_Lock.checkIfColumnsUpdated(p_old_lock_columns) THEN
         lv2_columns_updated := 'Y';
      ELSE
         lv2_columns_updated := 'N';
      END IF;

      EcDp_Month_Lock.checkUpdateOfLDOForLock(ld_new_current_valid,
                                             ld_old_current_valid,
                                             ld_new_next_valid,
                                             ld_old_next_valid,
                                             ld_old_prev_valid,
                                             lv2_columns_updated,
                                             lv2_id,
                                             lv2_n_obj_id);

   ELSIF p_operation = 'DELETING' THEN -- Only when deleting a valid analysis

      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_old_lock_columns);

      ld_old_next_valid := ec_choke_model_ref_value.next_daytime(
                           p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_old_current_valid);

      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_old_current_valid, ld_old_next_valid, lv2_id, lv2_o_obj_id);

   END IF;

END checkChokeModelRefValueLock;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : checkFctyReferenceValueLock
-- Description    :
--
-- Preconditions  : Checks whether a last dated facility reference record affects a locked month.
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: ec_Fcty_reference_value,
--                  EcDp_Month_Lock.checkUpdateOfLDOForLock,
--                  EcDp_Month_Lock.buildIdentifierString,
--                  EcDp_Month_Lock.checkIfColumnsUpdated,
--                  EcDp_Month_Lock.validatePeriodForLockOverlap
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE checkFctyReferenceValueLock(p_operation VARCHAR2, p_new_lock_columns  IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns  IN OUT EcDp_Month_Lock.column_list)
--</EC-DOC>
IS

ld_new_current_valid DATE;
ld_old_current_valid DATE;
ld_new_next_valid DATE;
ld_old_next_valid DATE;
ld_old_prev_valid DATE;

ld_locked_month DATE;
lv2_id VARCHAR2(2000);
lv2_columns_updated VARCHAR2(1);

lv2_o_obj_id                  VARCHAR2(32);
lv2_n_obj_id                  VARCHAR2(32);

BEGIN

   ld_new_current_valid := p_new_lock_columns('DAYTIME').column_data.AccessDate;
   ld_old_current_valid := p_old_lock_columns('DAYTIME').column_data.AccessDate;

   IF p_old_lock_columns.EXISTS('OBJECT_ID')  THEN
      lv2_o_obj_id := p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
   END IF;

   IF p_new_lock_columns.EXISTS('OBJECT_ID')  THEN
      lv2_n_obj_id := p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
   END IF;

   IF p_operation = 'INSERTING' THEN -- Only when inserting new valid analysis

      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_new_lock_columns);

      ld_new_next_valid := ec_fcty_reference_value.next_daytime(
                           p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_new_current_valid);

      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_new_current_valid, ld_new_next_valid, lv2_id, lv2_n_obj_id);

   ELSIF p_operation = 'UPDATING' THEN

      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_new_lock_columns);

      -- get the next valid daytime
      ld_new_next_valid := ec_fcty_reference_value.next_daytime(
                           p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_new_current_valid);

      ld_old_next_valid := ec_fcty_reference_value.next_daytime(
                           p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_old_current_valid);

      IF ld_new_next_valid = ld_old_current_valid THEN
         ld_new_next_valid := ld_old_next_valid;
      END IF;

      -- Get previous record
      ld_old_prev_valid := ec_fcty_reference_value.prev_daytime(
                                  p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                                  ld_old_current_valid);

      p_old_lock_columns('DAYTIME').is_checked := 'Y';

      IF EcDp_Month_Lock.checkIfColumnsUpdated(p_old_lock_columns) THEN
         lv2_columns_updated := 'Y';
      ELSE
         lv2_columns_updated := 'N';
      END IF;

      EcDp_Month_Lock.checkUpdateOfLDOForLock(ld_new_current_valid,
                                             ld_old_current_valid,
                                             ld_new_next_valid,
                                             ld_old_next_valid,
                                             ld_old_prev_valid,
                                             lv2_columns_updated,
                                             lv2_id,
                                             lv2_n_obj_id);

   ELSIF p_operation = 'DELETING' THEN -- Only when deleting a valid analysis

      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_old_lock_columns);

      ld_old_next_valid := ec_fcty_reference_value.next_daytime(
                           p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_old_current_valid);

      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_old_current_valid, ld_old_next_valid, lv2_id, lv2_o_obj_id);

   END IF;

END checkFctyReferenceValueLock;

END EcBp_Fluid_Analysis;