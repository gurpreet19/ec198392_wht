DECLARE
  CURSOR c_missing_desc IS
	SELECT *
	FROM   class_attribute_cnfg a
	WHERE  a.class_name='TEST_DEVICE' 
	AND    a.attribute_name IN(
           'INSTRUMENTATION_TYPE'
          ,'PT_SOURCE_PREF'
          ,'PT_CALC_BASE'
          ,'PT_GL_STATECONV'
          ,'STD_NET_RATE_METHOD'
          ,'NET_RATE_METHOD'
          ,'GRS_LIQ_RATE_METHOD'
          ,'GRS_GAS_RATE_METHOD'
          ,'GRS_GL_RATE_METHOD'
          ,'GRS_WATER_RATE_METHOD'
          ,'GRS_LIQ_VOL_METHOD'
          ,'GRS_GAS_VOL_METHOD'
          ,'GRS_GL_VOL_METHOD'
          ,'GRS_WATER_VOL_METHOD'
          ,'SHRINKAGE_METHOD'
          ,'METER_FACTOR_METHOD'
          ,'GOR'
          ,'GLR'
          ,'CGR'
          ,'WOR'
          ,'WGR'
          ,'BSW_VOL_METHOD')
    AND NOT EXISTS(
       SELECT 1 FROM class_attr_property_cnfg WHERE class_name=a.class_name AND attribute_name=a.attribute_name AND owner_cntx=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION'
    );   
BEGIN

	FOR cur IN c_missing_desc LOOP
		INSERT INTO class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
		VALUES (cur.class_name, cur.attribute_name, 'DESCRIPTION', 0, '/EC', 'APPLICATION', NULL);
	END LOOP;

	UPDATE class_attr_property_cnfg SET property_value='Instrumentation type is used to control which Test Device data class that will be used for well testing.
There are two different ways to record well tests in EC:
Multi Record Multi Well Testing module is using BF'||chr(39)||'s PT.0005 - PT.0011.
Single Record Single Well Testing module is using BF PT.0013
==> 1 - Instr Type 1 
will use TDEV_SAMPLE_1 and TDEV_RESULT_1 (for PT.0005 - PT.0011)
will use TDEV_PT_0013_1 (for PT.0013)
==> 2 - Instr Type 2
will use TDEV_SAMPLE_2 and TDEV_RESULT_2 (for PT.0005 - PT.0011)
will use TDEV_PT_0013_2 (for PT.0013)
==> 3 - Instr Type 3
will use TDEV_SAMPLE_3 and TDEV_RESULT_3 (for PT.0005 - PT.0011)
will use TDEV_PT_0013_3 (for PT.0013)
==> 4 - Instr Type 4
will use TDEV_PT_0013_4 (for PT.0013)'
WHERE CLASS_NAME='TEST_DEVICE' AND ATTRIBUTE_NAME='INSTRUMENTATION_TYPE' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='The Preferred Data Source is only used for Multi Record Multi Well Testing
This attribute will influence the net oil calculation for the test device.
Whenever there is Water-in-Oil data available for the test device oil outlet from both continuous meters (e.g. clamp-on water meter) and manual sampling and laboratory analysis (registered in the "production test event" -screen), this attribute will define which data set should prevail in the net oil calculation.
==> EVENT - Event (Default)
The data in TEST_DEVICE_RESULT.EVENT_OIL_OUT_BSW and TEST_DEVICE_RESULT.EVENT_OIL_OUT_BSW_WT  represent the preferred values for use in net oil calculations.
==> METER - Meter
The data in TEST_DEVICE_RESULT.WATER_IN_OIL_OUT and TEST_DEVICE_RESULT.WATER_IN_OIL_OUT_WT  represent the preferred values for use in net oil calculations.'
WHERE CLASS_NAME='TEST_DEVICE' AND ATTRIBUTE_NAME='PT_SOURCE_PREF' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='The Calculation Basis is only used for Multi Record Multi Well Testing
This attribute will influence all rate calculations for the test device. 
A test device could deliver rate and quantity measurement data in either volumetric or mass units.  The downstream logic and calculations required are slightly different in these two cases and must be adjusted accordingly.  This is controlled by the PT_CALC_BASE attribute.  It is assumed that the test device provides homogeneous output, either all mass based or all volume based.
==> VOLUME - Volume (Default)
The test device measurements will be interpreted as volumetric data.  Numeric propagation will proceed accordingly.
==> MASS - Mass
The test device measurements will be interpreted as mass data.  Numeric propagation will proceed accordingly'
WHERE CLASS_NAME='TEST_DEVICE' AND ATTRIBUTE_NAME='PT_CALC_BASE' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='The Calculation Basis is only used for Multi Record Multi Well Testing
This attribute will influence the calculation of net produced gas.  
Whenever subtracting lift-gas from test device measured gas it is necessary to make sure that the two volumetric rates are referring to the same T,P -conditions.  If not, the well lift-gas rate (normally reported at STP) must be converted to test device T,P -conditions before subtraction.  Assuming near-ideal behaviour of the dry, processed lift-gas, the ideal gas equation is used:  PV = nRT. 
==> Y - Yes
Enables the state conversion of well gas lift volume rates from std. conditions back to test device conditions before subtraction from measured gas volume.
==> N - No (Default)
Disables the state conversion of well gas lift volume rates from std. conditions back to test device conditions before subtraction from measured gas volume.'
WHERE CLASS_NAME='TEST_DEVICE' AND ATTRIBUTE_NAME='PT_GL_STATECONV' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='==> MEASURED - <phase>RateStdAdjattributes
The net standard shrunk rate for all phases are found directly from classes TDEV_PT_0013_X, attributes
Oil, attribute NET_OIL_RATE_ADJ
Gas, attribute GAS_RATE_ADJ
Water, attribute TOT_WATER_RATE_ADJ
Condensate, attribute NET_COND_RATE_ADJ
==> SHRINKAGE - NetRateMethod - ShrinkageVolume
Calls Net Rate Method and adjust it for shrinakge by calling Shrinkage Method'
WHERE CLASS_NAME='TEST_DEVICE' AND ATTRIBUTE_NAME='STD_NET_RATE_METHOD' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='==> MEASURED - NetOilRateFlc
The net standard unshrunk rate for all phases are found directly from classes TDEV_PT_0013_X, attributes
Oil, attribute NET_OIL_RATE_FLC
Gas, attribute GAS_RATE_FLC
Water, attribute TOT_WATER_RATE_FLC
Condensate, attribute NET_COND_RATE_FLC
==> GRS_MINUS_IMPURITY - Grs<phase>RateMethod - ImpurityRate
Calls the Grs Rate Method and deducts the impurity by calling the function calcImpurityRate which cleans out all impurities from Grs Rate. It will calculate and deduct or add the following:
BSW from BSW_VOL_METHOD
Diluent from attribute EST_DILUENT_RATE_FLC
Oil in Water from attribute OIL_IN_WATER_OUT
Gas Lift (press and temp adjusted) from Grs Gas Lift Method
PowerWater from POWER_WATER_FLC'
WHERE CLASS_NAME='TEST_DEVICE' AND ATTRIBUTE_NAME='NET_RATE_METHOD' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='==> MEASURED - Oil Out Rate Raw
The grs liquid rate is found directly from class TDEV_PT_0013_X, attribute OIL_OUT_RATE_RAW
==> VOLUME_DURATION - GrsLiqVolMethod / Duration * 24
The grs liquid rate is found by calling Grs Liq Vol Method and divide by duration of well test and multiply with 24
The duration is either the PWEL_RESULT.DURATION or if null PWEL_RESULT.END_DATE minus PWEL_RESULT.DAYTIME
 ==> CGR - NetRateMethod * CGR
The grs liquid rate is found by calling the Net Rate Method and multiply with the result from CGR Method. This option is only applicable to Gas Wells.
==> USER_EXIT - User Exit
Calls the default empty function Ue_Testdevice.findGrsLiqRate'
WHERE CLASS_NAME='TEST_DEVICE' AND ATTRIBUTE_NAME='GRS_LIQ_RATE_METHOD' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='==> MEASURED - Gas Out Rate Raw
The grs gas rate is found directly from class TDEV_PT_0013_X, attribute GAS_OUT_RATE_RAW
==> VOLUME_DURATION - GrsGasVolMethod / Duration * 24
The grs gas rate is found by calling Grs Gas Vol Method and divide by duration of well test and multiply with 24
The duration is either the PWEL_RESULT.DURATION or if null PWEL_RESULT.END_DATE minus PWEL_RESULT.DAYTIME
==> LIQUID_GOR - NetLiqRateMethod * GOR
The grs gas rate is found by calling the Net Liq Rate Method and multiply with the result from GOR Method. This option is only applicable to Oil Wells.
==> USER_EXIT - User Exit
Calls the default emtpy function Ue_Testdevice.findGrsGasRate'
WHERE CLASS_NAME='TEST_DEVICE' AND ATTRIBUTE_NAME='GRS_GAS_RATE_METHOD' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='==> MEASURED - Gas Lift Rate Raw
The grs gas lift rate is found directly from class TDEV_PT_0013_X, attribute GAS_LIFT_RATE_RAW
==> VOLUME_DURATION - GrsGLVolMethod / Duration * 24
The grs gas lift rate is found by calling Grs GL Vol Method and divide by duration of well test and multiply with 24
The duration is either the PWEL_RESULT.DURATION or if null PWEL_RESULT.END_DATE minus PWEL_RESULT.DAYTIME
==> USER_EXIT - User Exit
Calls the default emtpy function Ue_Testdevice.findGrsGasLiftRate'
WHERE CLASS_NAME='TEST_DEVICE' AND ATTRIBUTE_NAME='GRS_GL_RATE_METHOD' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='==> MEASURED - Water Out Rate Raw
The water rate is found directly from class TDEV_PT_0013_X, attribute WATER_OUT_RATE_RAW
==> VOLUME_DURATION - GrsWaterVolMethod / Duration * 24
The water rate is found by calling Grs Water Vol Method and divide by duration of well test and multiply with 24
The duration is either the PWEL_RESULT.DURATION or if null PWEL_RESULT.END_DATE minus PWEL_RESULT.DAYTIME
==> WOR_WGR - NetRateMethod<phase> * WOR_WGR
If the well is an Oil Producer, then the water rate is found by calling the Net Rate Method for Oil and multiply with the WOR found by calling the WOR Method
If the well is a Gas Producer, then the water rate is found by calling the Net Rate Method for Gas and multiply with the WGR found by calling the WGR Method
==> USER_EXIT - User Exit
Calls the default emtpy function Ue_Testdevice.findGrsWaterRate'
WHERE CLASS_NAME='TEST_DEVICE' AND ATTRIBUTE_NAME='GRS_WATER_RATE_METHOD' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='==> MEASURED - Oil Out Vol Raw
The grs liquid volume is found directly from class TDEV_PT_0013_X, attribute OIL_OUT_VOL_RAW
==> TOTALIZER - Totalizer
The grs liquid volume is found from totalizer closing reading minus totalizer opening reading.
In addition, the volume will be corrected with a number of factors from Test Device Reference Value and override values from TDEV_PT_0013_X data class. If override value is found, its using the override, if not its using the Test Device Reference Values and if both are null, the default is 1. 
The vcf (volume correction factor) is calculated using Observed Gravity, Observed Temp and Run Temp as input to an API library which returns Corrected Gravity and a VCF.
Returned volume is =  (((totalizer close - totalizer open) * conversion factor * meter factor * shrinakge factor * volume correction factor ) + adjustment volume) * (1-bsw).'
WHERE CLASS_NAME='TEST_DEVICE' AND ATTRIBUTE_NAME='GRS_LIQ_VOL_METHOD' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='==> MEASURED - Gas Out Vol Raw
Grs gas volume is found directly from class TDEV_PT_0013_X, attribute GAS_OUT_VOL_RAW
==> ORIFICE_AGA - Orifice AGA
Grs gas vol is found by multiplying attribute GAS_VOL_OUT_AGA with Duration.
The duration is either the PWEL_RESULT.DURATION or if null PWEL_RESULT.END_DATE minus PWEL_RESULT.DAYTIME.
The GAS_VOL_OUT_AGA is the result volume/hour rate from the AGA calculations. To configure AGA calculations, you have to define Meter Runs, Orifice Plates, Meter Run and Orifice Plate Connection and record reference data for Test Device Reference Values and Stream AGA Analysis. You can override the Meter Run and Orifice Plate if the default Test Device setup isn'||chr(39)||'t correct for the test.
For more details, see BF documentation for Test Device and Test Device Reference values'
WHERE CLASS_NAME='TEST_DEVICE' AND ATTRIBUTE_NAME='GRS_GAS_VOL_METHOD' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='==> MEASURED - Gas Lift Out Vol Raw
Grs gaslift volume is found directly from class TDEV_PT_0013_X, attribute GAS_LIFT_VOL_RAW
==> CHOKE_LOOKUP - Choke Lookup
Grs gaslift volume is found by calculating gaslift hourly rate and multiply with Duration. Gaslift hourly rate is found from the BF Choke Gas Lift Conversion where parameters for gaslift choke size and gaslift differential pressure is sent as parameters to the lookup table.
==> ORIFICE_AGA - Orifice AGA
Grs gaslift volume is found by multiplying attribute GAS_LIFT_VOL_OUT_AGA with Duration.
See GRS_GAS_VOL_METHOD for AGA details. There are dedicated attributes for Gaslift when configuring AGA calc.'
WHERE CLASS_NAME='TEST_DEVICE' AND ATTRIBUTE_NAME='GRS_GL_VOL_METHOD' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='==> MEASURED - Water Out Vol Raw
Grs water volume is found directly from class TDEV_PT_0013_X, attribute WATER_OUT_VOL_RAW
==> TOTALIZER - Totalizer
The water volume is found from totalizer closing reading minus totalizer opening reading.
In addition, the volume will be corrected with a number of factors from Test Device Reference Value and override values from TDEV_PT_0013_X data class. If override value is found, its using the override, if not its using the Test Device Reference Values and if both are null, the default is 1. 
Returned volume is =  ((totalizer close - totalizer open) * conversion factor * meter factor) + adjustment volume.'
WHERE CLASS_NAME='TEST_DEVICE' AND ATTRIBUTE_NAME='GRS_WATER_VOL_METHOD' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='==> NO_SHRINKAGE - No Shrinkage
No adjustment to the volume, Net Volume = Net Std Volume
==> EQUATION - Equation
Shrinakge will be calculated based on a formula where parameters are fetched from the test device (ln_tdev_temp and ln_tdev_press) and constants are fetched from a Quality Stream linked to the same Reservoir Block Formation as the Well is producing from.
Oil Shrinkage Factor = 
((ln_osr_const_1 * (power(ln_tdev_press, ln_osr_const_press_1)) * (power(ln_tdev_temp, ln_osr_const_temp_1))) +
(ln_osr_const_press_2 * power(ln_tdev_press, ln_osr_const_press_3)) +
(ln_osr_const_press_4 * power(ln_tdev_press, ln_osr_const_press_5)) +
(ln_osr_const_temp_2 * power(ln_tdev_temp, ln_osr_const_temp_3))
)
Gas Shrinakge Factor =
((ln_gsr_const_1 * power(ln_tdev_press, ln_gsr_const_press_1) * power(ln_tdev_temp, ln_gsr_const_temp_1)) +
(ln_gsr_const_press_2 * power(ln_tdev_press, ln_gsr_const_press_3)) +
(ln_gsr_const_press_4 * power(ln_tdev_press, ln_gsr_const_press_5)) +
(ln_gsr_const_temp_2 * power(ln_tdev_temp, ln_gsr_const_temp_3))
)
Gas In Solution =
((ln_gis_const_1 * power(ln_tdev_press, ln_gis_const_press_1) * power(ln_tdev_temp, ln_gis_const_temp_1)) +
(ln_gis_const_press_2 * power(ln_tdev_press, ln_gis_const_press_3)) +
(ln_gis_const_press_4 * power(ln_tdev_press, ln_gis_const_press_5)) +
(ln_gis_const_temp_2 * power(ln_tdev_temp, ln_gis_const_temp_3))
)
NetStdOil = NetOil * Oil Shrinakge Factor
NetStdGas = (NetGas * Gas Shrinakge Factor) + (NetOil * Gas In Solution)
==> TDEV_FACTOR - Test Device Ref Factor
Gets Oil and Gas shrinkage from Test Device Reference Value
==> WELL_FACTOR - Well Ref Factor
Gets Oil and Gas shrinkage from Well Reference Value
==> WELL_TDEV_FACTOR - Well / Tdev Ref Factor 
Gets Oil and Gas shrinkage from Well Reference Value, but if null uses Test Device Reference Value
==> TABLE_LOOKUP - Table Lookup
Shrinkage will be found from a lookup table using well head temperature, well head pressure, test device density and Well quality Stream as input. The Well quality Stream is found either directly from the Well object itself or from the first Perforation Interval the Well is connected to. (the Perf Interval has a link to Res Block Formation which has a quality Stream)
The table lookup will return Bo, Bg and Rs which is then used to calculate shrinakge for all three phases:
Std Net Oil Rate = Net Oil Rate / Bo
Std Gas Rate = (Gas Rate / Bg ) + (Net Oil Rate * Rs)
Std Water Rate = Water Rate / Bw
==> MEASURED - Entered Directly 
Std Net Oil Rate = Net Oil Rate * (Oil Shrinkage factor)
(Oil shrinkage factor is found directly from class TDEV_PT_0013_X, attribute OIL_SHRINKAGE_OVERRIDE)
Std Gas Rate = (Net Gas Rate * Gas Shrinkage factor) + (Net Oil Rate * Gas Flash factor)
(Gas Shrinkage factor is found directly from class TDEV_PT_0013_X, attribute GAS_SHRINKAGE_OVERRIDE)
(Gas Flash factor is found directly from class TDEV_PT_0013_X, attribute GAS_FLASH_FACTOR)
==> USER_EXIT - User Exit
Calls the empty function Ue_TestDevice.calcShrinkageVolume'
WHERE CLASS_NAME='TEST_DEVICE' AND ATTRIBUTE_NAME='SHRINKAGE_METHOD' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='==> COPY_FORWARD - Copy Forward
Uses the Test Device Override Meter Factor - if null, then defaults to 1
==> TDEV_REFERENCE - Test Device Reference
Uses the Test Device Reference values for Oil and Water Meter Factors - if null, then defaults to use the Test Device Override Meter Factor.'
WHERE CLASS_NAME='TEST_DEVICE' AND ATTRIBUTE_NAME='METER_FACTOR_METHOD' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='==> MEASURED - Measured
GOR is found directly from class TDEV_PT_0013_X, attribute GOR
==> GAS_DIV_OIL - Gas Div Oil
GOR is calculated from the StdNetGasRate Method divided by NetStdOilRate Method
==> WELL_REFERENCE_VALUE - Well Reference Value
GOR is found by looking up last available GOR from Well reference values'
WHERE CLASS_NAME='TEST_DEVICE' AND ATTRIBUTE_NAME='GOR' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='==> MEASURED - Measured
GLR is found directly from class TDEV_PT_0013_X, attribute GLR
==> GAS_DIV_LIQUID - Gas Div Liqiud
GLR is calculated from the StdNetGasRate Method divided by the sum of NetStdOilRate Method + NetStdWaterRate Method
==> WELL_REFERENCE_VALUE - Well Reference Value
GLR is found by looking up last available GLR from Well reference values'
WHERE CLASS_NAME='TEST_DEVICE' AND ATTRIBUTE_NAME='GLR' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='==> MEASURED - Measured
CGR is found directly from class TDEV_PT_0013_X, attribute CGR
==> COND_DIV_GAS - Cond Div Gas
CGR is calculated from the StdNetCondensateRate Method divided by NetStdGasRate Method
==> WELL_REFERENCE_VALUE - Well Reference Value
CGR is found by looking up last available CGR from Well reference values'
WHERE CLASS_NAME='TEST_DEVICE' AND ATTRIBUTE_NAME='CGR' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='==> MEASURED - Measured
WOR is found directly from class TDEV_PT_0013_X, attribute WOR
==> WATER_DIV_OIL - Water Div Oil
WOR is calculated from the StdNetWaterRate Method divided by NetStdOilRate Method
==> WELL_REFERENCE_VALUE - Well Reference Value
WOR is found by looking up last available WOR from Well reference values'
WHERE CLASS_NAME='TEST_DEVICE' AND ATTRIBUTE_NAME='WOR' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='==> MEASURED - Measured
WGR is found directly from class TDEV_PT_0013_X, attribute WGR
==> WATER_DIV_GAS - Water Div Gas
WGR is calculated from the StdNetWaterRate Method divided by NetStdGasRate Method
==> WELL_REFERENCE_VALUE - Well Reference Value
WGR is found by looking up last available WGR from Well reference values'
WHERE CLASS_NAME='TEST_DEVICE' AND ATTRIBUTE_NAME='WGR' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='==> MEASURED - Measured
BSW volume % is found directly from class TDEV_PT_0013_X, attribute WATER_IN_OIL_OUT
==> SAMPLE_ANALYSIS - Sample Analysis, any sampling
Get last available BSW volume % from Well Sample Analysis, regardless of  sample method
==> SAMPLE_ANALYSIS_SPOT - Sample Analysis, Spot sampling
Get last available BSW volume % from Well Sample Analysis, where sample method is SPOT
==> SAMPLE_ANALYSIS_DAY - Sample Analysis, Day sampling
Get last available BSW volume % from Well Sample Analysis, where sample method is DAY_SAMPLER
==> SAMPLE_ANALYSIS_MTH - Sample Analysis, Month sampling
Get last available BSW volume % from Well Sample Analysis, where sample method is MTH_SAMPLER
==> WELL_REFERENCE_VALUE - Well Reference Value
BSW volume % is found by looking up last available BSW from Well reference values'
WHERE CLASS_NAME='TEST_DEVICE' AND ATTRIBUTE_NAME='BSW_VOL_METHOD' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
END;
/
