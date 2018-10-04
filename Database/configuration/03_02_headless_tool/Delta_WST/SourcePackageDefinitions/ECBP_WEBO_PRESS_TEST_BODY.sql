CREATE OR REPLACE PACKAGE BODY Ecbp_Webo_Press_Test IS
/**************************************************************
** Package:    Ecbp_Webo_Press_Test
**
** $Revision: 1.0 $
**
** Filename:   Ecbp_Webo_Press_Test.sql
**
** Part of :   EC Kernel
**
** Purpose:
**
** General Logic:
**
** Document References:
**
**
** Created:     26.08.2016  Gourav Jain
**
**
** Modification history:
**
**
** Date:      Whom:      Change description:
** --------   -----      ------------------------------------------------------------------------------------------------------
** 26-08-2016 jainngou   ECPD-36895: Added getDatumDepth and getInitDatumPress to get datum depth and datum init press of RBF.
** 18.07.2017  kashisag ECPD-45817: Replaced sysdate with Ecdp_Timestamp.getCurrentSysdate
*********************************************************************************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDatumDepth
-- Description    : Returns a datum_depth of RBF using well bore id.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :perf_interval
--
--
--
-- Using functions: ec_perf_interval_version,ec_rbf_version,ec_perf_interval
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getDatumDepth(p_object_id webo_bore.object_id%TYPE , p_daytime DATE, p_measdepth NUMBER)
RETURN NUMBER
--</EC-DOC>
IS

 lv2_PerfInt_id    perf_interval.object_id%TYPE := NULL;
 lv2_RBF_id        resv_block_formation.object_id%TYPE := NULL;
 ln_loopcount      NUMBER := 0;
 ln_return_val     NUMBER := NULL;

 CURSOR c_perfintervals IS
    SELECT object_id FROM perf_interval
	WHERE ec_perf_interval.well_bore_id(object_id) = p_object_id
    AND p_measdepth <= ec_perf_interval_version.bottom_perf_md(object_id, p_daytime,'<=')
    AND p_measdepth > ec_perf_interval_version.top_perf_md(object_id, p_daytime,'<=')
    AND p_daytime   >= ec_perf_interval.start_date(object_id)
    AND p_daytime   < NVL(ec_perf_interval.end_date(object_id), Ecdp_Timestamp.getCurrentSysdate + 1);

BEGIN
  FOR cur_PerfInt IN c_perfintervals LOOP
    ln_loopcount   := ln_loopcount + 1;
    lv2_PerfInt_id := cur_PerfInt.object_id;
  END LOOP;

  IF ln_loopcount = 1 THEN
    lv2_RBF_id    := ec_perf_interval_version.resv_block_formation_id(lv2_PerfInt_id,p_daytime,'<=');
    ln_return_val := ec_rbf_version.datum_depth(lv2_RBF_id,p_daytime,'<=');
  END IF;

  RETURN ln_return_val;

END getDatumDepth;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getInitDatumPress
-- Description    : Returns a datum_init_press of RBF using well bore id.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :perf_interval
--
--
--
-- Using functions: ec_perf_interval_version,ec_rbf_version,ec_perf_interval.
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

FUNCTION getInitDatumPress(p_object_id webo_bore.object_id%TYPE , p_daytime DATE, p_measdepth NUMBER)
RETURN NUMBER
--</EC-DOC>
IS

 lv2_PerfInt_id    perf_interval.object_id%TYPE := NULL;
 lv2_RBF_id        resv_block_formation.object_id%TYPE := NULL;
 ln_loopcount      NUMBER := 0;
 ln_return_val     NUMBER := NULL;

 CURSOR c_perfintervals is
    SELECT object_id FROM perf_interval
    WHERE ec_perf_interval.well_bore_id(object_id) = p_object_id
    AND p_measdepth <= ec_perf_interval_version.bottom_perf_md(object_id, p_daytime,'<=')
    AND p_measdepth > ec_perf_interval_version.top_perf_md(object_id, p_daytime,'<=')
    AND p_daytime   >= ec_perf_interval.start_date(object_id)
    AND p_daytime   < NVL(ec_perf_interval.end_date(object_id), Ecdp_Timestamp.getCurrentSysdate + 1);

BEGIN
  FOR cur_PerfInt IN c_perfintervals LOOP
    ln_loopcount   := ln_loopcount + 1;
    lv2_PerfInt_id := cur_PerfInt.object_id;
  END LOOP;

  IF ln_loopcount = 1 THEN
    lv2_RBF_id    := ec_perf_interval_version.resv_block_formation_id(lv2_PerfInt_id,p_daytime,'<=');
    ln_return_val := ec_rbf_version.datum_init_press(lv2_RBF_id,p_daytime,'<=');
  END IF;

  RETURN ln_return_val;

END getInitDatumPress;

END Ecbp_Webo_Press_Test;