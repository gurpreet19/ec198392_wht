CREATE OR REPLACE PACKAGE BODY ue_pvt_calculation IS
/******************************************************************************
** Package        :  ue_pvt_calculation, body part
**
** $Revision: 1.3 $
**
** Purpose        :  Perform PVT calculation based on user specific code, raise error if not found.
**
** Documentation  :  www.energy-components.com
**
** Created        :  23.03.2006 Khew Kok Seong
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
** 09.05.2006  hagengei	Changed calculateStdAdjValues from function to procedure, input values to handle OUT parameters and added parameter resultNo
** Sep 2008    Mark Berkstresser    Created general CVX structure
** Apr 2009    CTFV	Qualified the well_bore_id in c_RBF cursor due to 9.3 SP08
********************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calculateStdAdjValues
-- Description    : User exit function for PVT calculation
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
-- Behaviour    Mimics the product in determing the portion of flow from each RBF and applying the factors
--                stored on Stream Reference
---------------------------------------------------------------------------------------------------
PROCEDURE calculateStdAdjValues(testNo NUMBER,
                                resultNo VARCHAR2,
                                userId VARCHAR2,
                                pressure NUMBER,
                                temperature NUMBER,
                                flcOilVolRate NUMBER,
                                flcGasVolRate NUMBER,
                                flcConVolRate NUMBER,
                                flcWatVolRate NUMBER,
                                flcOilMassRate NUMBER,
                                flcGasMassRate NUMBER,
                                flcConMassRate NUMBER,
                                flcWatMassRate NUMBER,
                                flcOilDensity NUMBER,
                                flcGasDensity NUMBER,
                                flcConDensity NUMBER,
                                flcWatDensity NUMBER,
                                stdOilVolRate OUT NUMBER,
                                stdGasVolRate OUT NUMBER,
                                stdConVolRate OUT NUMBER,
                                stdWatVolRate OUT NUMBER,
                                stdOilMassRate OUT NUMBER,
                                stdGasMassRate OUT NUMBER,
                                stdConMassRate OUT NUMBER,
                                stdWatMassRate OUT NUMBER,
                                stdOilDensity OUT NUMBER,
                                stdGasDensity OUT NUMBER,
                                stdConDensity OUT NUMBER,
                                stdWatDensity OUT NUMBER)
--</EC-DOC>
IS
ln_oil_factor  NUMBER;
ln_well_id     VARCHAR2(32);
ln_test_date   DATE;
ln_stdOilVolRate_RBF  NUMBER;
ln_stdGasVolRate_RBF  NUMBER;

--  Determine the split factors for the well all the way to the perforation interval
    CURSOR c_RBF_for_well(ln_well_id varchar2, ln_test_date date) IS
              SELECT  ecdp_objects.GetObjCode(wi.WELL_BORE_ID) WELL_BORE_ID, 
                      ecdp_objects.GetObjCode(WEBO_INTERVAL_ID) WEBO_INTERVAL_ID, 
                      ecdp_objects.GetObjCode(pi.object_id) PI_OBJECT_ID,
                      RESV_BLOCK_ID, RESV_FORMATION_ID, 
--dqgm   used rbf_version.stream_id as in 10.3 RESV_BLOCK_FORMATION does not have STREAM_ID                     
					 ecdp_objects.GetObjCode(rbfv.stream_id) STREAM_CODE,
                      rbfv.stream_id STREAM_ID,
                Nvl(ec_perf_interval_gor.oil_pct(pi.object_id, '1-aug-08','<='),0)  PI_OIL_PCT, 
                Nvl(ec_perf_interval_gor.gas_pct(pi.object_id, '1-aug-08','<='),0)  PI_GAS_PCT, 
                Nvl(ec_perf_interval_gor.cond_pct(pi.object_id, '1-aug-08','<='),0) PI_COND_PCT, 
                Nvl(ec_perf_interval_gor.water_pct(pi.object_id, '1-aug-08','<='),0) PI_WATER_PCT,
                Nvl(ec_WEBO_interval_gor.oil_pct(wi.object_id, '1-aug-08','<='),0)  WBI_OIL_PCT, 
                Nvl(ec_WEBO_interval_gor.gas_pct(wi.object_id, '1-aug-08','<='),0)  WBI_GAS_PCT, 
                Nvl(ec_WEBO_interval_gor.cond_pct(wi.object_id, '1-aug-08','<='),0) WBI_COND_PCT, 
                Nvl(ec_WEBO_interval_gor.water_pct(wi.object_id, '1-aug-08','<='),0) WBI_WATER_PCT,
                Nvl(ec_webo_split_factor.oil_contrib_pct(wb.well_id, wb.object_id, '1-aug-08','<='),0)  WB_OIL_PCT, 
                Nvl(ec_webo_split_factor.gas_contrib_pct(wb.well_id, wb.object_id, '1-aug-08','<='),0)  WB_GAS_PCT, 
                Nvl(ec_webo_split_factor.cond_contrib_pct(wb.well_id, wb.object_id, '1-aug-08','<='),0) WB_COND_PCT, 
                Nvl(ec_webo_split_factor.water_contrib_pct(wb.well_id, wb.object_id, '1-aug-08','<='),0) WB_WATER_PCT
                FROM webo_bore wb, webo_interval wi, perf_interval pi,resv_block_formation rbf, rbf_version rbfv ,perf_interval_version pv1 -- Added this join cause 111 moved the resv_block_formation_id from perf_interval to perf_interval_version
                WHERE wb.well_id =  ln_well_id
				 AND pi.object_id = pv1.object_id -- Added this join cause 111 moved the resv_block_formation_id from perf_interval to perf_interval_version
				 AND pv1.end_date IS NULL ---- Added this join cause 111 moved the resv_block_formation_id from perf_interval to perf_interval_version
                 AND wi.well_bore_id = wb.object_id
                 AND pi.webo_interval_id = wi.object_id
                 AND pv1.resv_block_formation_id = rbf.object_id-- Added this join cause 111 moved the resv_block_formation_id from perf_interval to perf_interval_version
-- dqgm added this codition as using version table			
			and rbf.object_id = rbfv.object_id
				 AND Nvl(rbfv.daytime, '01-Jan-1970') <= ln_test_date
                 AND Nvl(rbfv.end_date, SYSDATE) > ln_test_date
				 --dqgm change end
                 AND Nvl(wi.start_date, '01-Jan-1970') <= ln_test_date
                 AND Nvl(wi.end_date, SYSDATE) > ln_test_date
				 AND Nvl(pi.start_date, '01-Jan-1970') <= ln_test_date
				 AND Nvl(pi.end_date, SYSDATE) > ln_test_date;
                 
    CURSOR c_pwel_result (resultno NUMBER) IS
          SELECT object_id, daytime
          from pwel_result
          WHERE result_no = resultno
             AND PRIMARY_IND = 'Y'
             AND FLOWING_IND = 'Y';
 
 BEGIN
 --  Zero out the values we will be calculating
 stdoilvolrate  := 0;
 stdGasVolRate  := 0;
 stdConVolRate  := 0;
 --  No adjustment for water
 stdWatVolRate  := flcWatVolRate;
 
 --  Loop through cursor of well tests to pick up the active well on the well test
   FOR cur_row IN c_pwel_result (resultno) LOOP
          ln_well_id := cur_row.object_id;
          ln_test_date := cur_row.daytime;
          END LOOP;

 --  Loop through the cursor RBF connections to get the relative percentages for each RBF
 --  The well bore, well bore interval and perforation interval must be multiplied together
   FOR cur_row IN c_RBF_for_well(ln_well_id, ln_test_date) LOOP
       --  Oil rate for each RBF
         ln_stdOilVolRate_RBF := cur_row.wb_oil_pct/100 * cur_row.wbi_oil_pct/100 * cur_row.pi_oil_pct/100 * flcOilVolRate;
       -- Adjust the rate for each RBF  This will require custom coding
         stdOilVolRate := stdOilVolRate + ln_stdOilVolRate_RBF * ec_strm_reference_value.osr_const_press_1(cur_row.stream_id,ln_test_date,'<=');
         --  Gas rate for each RBF
         ln_stdGasVolRate_RBF := cur_row.wb_oil_pct/100 * cur_row.wbi_oil_pct/100 * cur_row.pi_oil_pct/100 * flcOilVolRate;
       -- Adjust the rate for each RBF  This will require custom coding
       --  This one needs to be converted to R sub S Plus adjusted gas volume (we will assume the metered volume is at standard conditions)
         stdGasVolRate := stdGasVolRate + ln_stdGasVolRate_RBF * ec_strm_reference_value.osr_const_press_1(cur_row.stream_id,ln_test_date,'<=');  
         END LOOP;
  

--	stdGasVolRate  := temperature;
	stdConVolRate  := -1;
	stdOilMassRate := -1;
	stdGasMassRate := -1;
	stdConMassRate := -1;
	stdWatMassRate := -1;
	stdOilDensity  := -1;
	stdGasDensity  := -1;
	stdConDensity  := -1;
	stdWatDensity  := -1;


END calculateStdAdjValues;

END ue_pvt_calculation;
/
