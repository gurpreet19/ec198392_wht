CREATE OR REPLACE PACKAGE BODY EcBp_perforation IS
/****************************************************************
** Package        :  EcBp_perforation, body part
**
** $Revision: 1.1 $
**
** Purpose        :  Data validation on perforation interval active status.
**
** Documentation  :  www.energy-components.com
**
** Created        :  13.05.2013  Leong Weng Onn
**
** Modification history:
**
** Date        Whom      Change description:
** ----------  --------  --------------------------------------
** 13.05.2013  leongwen  Initial version
** 16.08.2016  jainngou  Added Sum_kHproductWBI method for sum of kH-product for all perforations within a given well bore interval for the day specified.
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : IUAllowPerfClosedLT
-- Description    : This function allowed to set active_perf_status to CLOSED_LT.
--

--
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

PROCEDURE IUAllowPerfClosedLT(p_object_id VARCHAR2, p_daytime DATE, p_summer_time VARCHAR2, p_status VARCHAR2)
IS

   ld_pd_start     DATE;
   ld_daytime      DATE;
   ld_next_daytime DATE;

BEGIN

   -- Conditions to set Perf_active_status to 'SUSPENDED' as 'LT_CLOSED' when insert or update
   IF NVL(p_status, 'OPEN') = 'SUSPENDED' THEN
      ld_pd_start   := ecdp_productionday.getProductionDayStart('PERF_INTERVAL', p_object_id, p_daytime);

      IF p_daytime <> ld_pd_start THEN
         RAISE_APPLICATION_ERROR(-20649, 'Cannot set Active Perforation Status = Suspended, daytime is not equal start of production day.');
      END IF;

      ld_next_daytime := ec_perf_period_status.next_daytime(p_object_id, p_daytime, 'EVENT');
      IF ld_next_daytime <> ld_pd_start THEN
         RAISE_APPLICATION_ERROR(-20650, 'Cannot set Active Perforation Status = Suspended when the next record does not have daytime=start of production day.');
      END IF;
   END IF;

END IUAllowPerfClosedLT;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : AllowPerfClosedLT
-- Description    : This function allowed to set active_perf_status to CLOSED_LT.
--

--
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

PROCEDURE AllowPerfClosedLT(p_object_id VARCHAR2, p_daytime DATE, p_summer_time VARCHAR2, p_status VARCHAR2)
IS

   ld_pd_start     DATE;
   ld_prev_row PERF_PERIOD_STATUS%ROWTYPE;

BEGIN

   ld_pd_start   := ecdp_productionday.getProductionDayStart('PERF_INTERVAL', p_object_id, p_daytime);

   -- Check the daytime is start of production day if the last previous record is LT_CLOSED
   ld_prev_row := ec_perf_period_status.row_by_rel_operator(p_object_id, p_daytime, 'EVENT','<');
   IF ld_prev_row.active_perf_status = 'CLOSED_LT' THEN
      IF p_daytime <> ld_pd_start THEN
         RAISE_APPLICATION_ERROR(-20651, 'New record must be for the beginning of a production day when perforation interval has Active Perforation Status = Suspended.');
      END IF;
   END IF;

END AllowPerfClosedLT;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : DelAllowPerfClosedLT
-- Description    : This function allowed record to be deleted.
--

--
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

PROCEDURE DelAllowPerfClosedLT(p_object_id VARCHAR2, p_daytime DATE, p_summer_time VARCHAR2, p_status VARCHAR2)
IS

   ld_pd_start     DATE;
   ld_next_daytime DATE;
   ld_prev_row PERF_PERIOD_STATUS%ROWTYPE;

BEGIN

   ld_prev_row := ec_perf_period_status.row_by_rel_operator(p_object_id, p_daytime, 'EVENT','<');
   ld_next_daytime := ec_perf_period_status.next_daytime(p_object_id, p_daytime, 'EVENT');
   IF ld_prev_row.active_perf_status = 'CLOSED_LT' THEN
      ld_pd_start := Ecdp_Productionday.getProductionDayStart('PERF_INTERVAL',p_object_id,ld_next_daytime);
      IF ld_pd_start <> ld_next_daytime THEN
         RAISE_APPLICATION_ERROR(-20652, 'Cannot delete record when previous record has Active Perforation Status = Suspended, and the next record does not start on a production day.');
      END IF;
   END IF;

END DelAllowPerfClosedLT;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : Sum_KHproductWBI
-- Description    : This function calculates the sum of kH-product for all perforations within
--                  a given well bore interval for the day specified.
--                  It is assumed that kH-product can be found in perf_interval_version.value_5
--                  Missing values will be treated as 0.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :perf_interval
--
-- Using functions:ec_perf_interval_version
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

FUNCTION Sum_kHproductWBI(p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS
ln_kHproduct	  NUMBER :=0;
ln_return_val   NUMBER;

CURSOR c_PerfIntervals IS
SELECT object_id FROM perf_interval
WHERE webo_interval_id = p_object_id
AND p_daytime BETWEEN start_date AND NVL(end_date,p_daytime);

BEGIN

  FOR cur_PerfInt IN c_PerfIntervals LOOP
    ln_kHproduct := ln_kHproduct + NVL(ec_perf_interval_version.kh_product(cur_PerfInt.object_id, p_daytime,'<='),0);
  END LOOP;

  ln_return_val := ln_kHproduct;

  RETURN ln_return_val;

END Sum_KHproductWBI;

END EcBp_perforation;