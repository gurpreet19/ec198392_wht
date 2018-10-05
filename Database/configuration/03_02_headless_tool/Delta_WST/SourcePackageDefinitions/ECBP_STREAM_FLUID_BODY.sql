CREATE OR REPLACE PACKAGE BODY EcBp_Stream_Fluid IS
/****************************************************************
** Package        :  EcBp_Stream_Fluid; body part
**
** $Revision: 1.227 $
**
** Purpose        :  This package is responsible for stream fluid information
**                   and calculation of fluid
**                   related data like densities, volumes, and masses.
**
** Documentation  :  www.energy-components.com
**
** Created        :  06.12.1999  Carl-Fredrik Sørensen
**
** Modification history:
**
** Version  Date        Whom    Change description:
** -------  ------      -----   --------------------------------------
** 1.0      06/12/1999  CFS     First version
**          29.03.2000  RRA     In findGrsStdVol:
**                              When EcDp_Calc_Method.DERIVED) EcDp_Stream_Derived.getGrsStdVol shall be called
**          13/04/2000  HNE     Bug in findNetStdVolComp: ELSE ln_return_val := NULL (not ELSE ln_return_val := 0)
**          13/04/2000  HNE     Bug in findGrsStdVol: Endret sjekk på IS NOT NULL til IS NULL + at kode for
**                              derived kun kjøres dersom methoden er DERIVED og ikke dersom stream_type='D'.
**          10/05/2000  PGI     In findGrsStdVol a 'default null' for argument p_today is added.
**                              Added 'REMOVE_BSW'-method functionality.
** 3.5      15/05/2000  CFS     Removed dependencies to EcDp_Stream_Allocated (OBSOLETE package).
** 3.5      15/05/2000  CFS     Added calcGrsStdVolTotalToDay, calcGrsStdMassTotalToDay
** 3.5      15/05/2000  CFS     Added calc<Avg/Cum><Grs/Net>Std<Vol/Mass><MthToDay/YearToDay>
** 3.6      18/05/2000  PGI     Changed 'REMOVE_BSW'-method to 'GROSS_BSW' in findNetStdVol.
** 3.7      18/05/2000  DN      Function getBswVolFrac: Analysis is selected from cargo when oil export stream.
** 3.8      07/06/2000  HVe     Function getBSWVolFrac: Added ref_stream method
** 3.8      07/06/2000  HVe     Function findWatVol: Added gross_bsw method as water = grs oil - net oil
** 3.9      15/06/2000  PGI     Function findNetStdVol: Now method 'GROSS_BSW' only use one function to find BSW.
** 3.9      15/06/2000  PGI     Function getBswVolFrac: Substituted selection of oil export stream with a new method 'CARGO_ANALYSIS'.
** 3.9      15/06/2000  PGI     Function getBswVolFrac: Added new method 'COND_WATER_FRAC'.
** 3.10     29/06/2000  PGI     Function findNetStdVol: Make summarise for a period in method 'GROSS_BSW'.
** 3.10.1   20/07/2000  FBa     Function findNetStdVol: With method 'GROSS_BSW', treat missing gross_vol or bsw as 0 if retrieving over a time period (like sum() for other methods)
** 3.11     18/07/2000  HNE     New function: getStdDensFromApiAnalysis.
                                New method 'API_ANALYSIS' in findStdDens.
                                New method 'VOLUME_DENSITY' in findGrsStdVol and findNetStdMass.
                                New method 'GRS_MASS' and 'DERIVED' in findNetStdMass
                                New method 'GRS_VOL' in findNetStdVol
                                New method 'NET_VOL' in findGrsStdVol
                                New method 'NET_MASS' and 'DERIVED' in findGrsStdMass
** 3.12     24/08/2000  BK      Added function calcAvgGrsStdDensMthToDay
** 3.13     22/09/2000  RRa     Changed calcAvg functions Grs/Net Vol/Mass from, removed AND (ln_net_mass > 0) check
**                              as it returned NULL for 0 and negative values summed in the selected period.
** 3.14     27/10/2000  PGI     'Find last analysis': Changed getStdDensFromApiAnalysis and call to this function from method 'API_ANALYSIS' in findStdDens.
** 3.15     17/11/2000  ØJ      Added p_method in calcNetStdDens with default value null.
** 3.17     05.01.2000  FBa     Modified function finNetStdVol. If method GRS_BSW and grs_vol = 0, then net_vol is 0, even if BSW analysis is missing.
** 3.18     05.01.2000  UMF/    Added support for new lab model in getBSWVolFrac / Density function.
**                              Requires package EcBp_Lab, ec packages on lab tables
**                      FBa     Added method 'CARGO_ANALYSIS' to findStdDensity, uses density from cargo module.
** 3.12     12/02/2001  BK      Improved function calcAvgGrsStdDensMthToDay
** 3.19     22/02/2001  HVe     Added function getAvgOilInWater
** 3.20     02/04/2001  KEJ     Documented functions and procedures.
** 3.22     08.05.2001  TSB     Added support for GROSS_BSW method in findNetStdMass,
                                and GRS_BSW_VOL in getBSWWeightFrac
** 3.22     22.05.2001  MNY     Added support for MASS_DENSITY method in findGrsStdVol
** 3.23     28.05.2001  MNY     Added code in MASS_DENSITY method in findGrsStdVol
** 3.24     28.05.2001  LHH     Added support for CALCULATED method in findWatMass,
                                finds water mass using grs_mass and bsw_w
** 3.25     27.06.2001  MNY     Added support for MASS_DENSITY method in findNetStdVol
**          06.07.2001  RRA     Added NVL for getAvgOilInWater period calculation
**          08/10/2001  MAO     Added default case in find-methods for mass and volume to use ec_strm_day_stream
** 3.26     17.08.2001  HNE     Created new function: GetSalt, calcMthWeightedWaterFrac, calcMthWeightedSaltFrac
** 3.29     23.11.2001  MNY     Changed calcCumGrsStdMassMthToDay,
**                              calcCumGrsStdMassYearToDay,
**                              calcCumGrsStdVolMthToDay,
**                              calcCumNetStdVolYearToDay,
**                              calcCumNetStdMassMthToDay,
**                              calcCumNetStdMassYearToDay,
**                              calcCumNetStdVolMthToDay,
**                              calcCummNetStdVolYearToDay,
**                              calcGrsStdMassTotalToDay,
**                              calcGrsStdVolTotalToDay,
**                              calcNetStdMassTotalToDay,
**                              calcNetStdVolTotalToDay
**                              Calculates the sum directly instead of using from and to_date, because these are not working propely.
**                      MNY     Added function calcAvgBswVolFracMthToDay (VESLEFRIKK)
**                      MNY     Added function calcAvgNetStdDensMthToDay (VESLEFRIKK)
** 3.30                 GOZ     Added new function calcGrsStdDens
** 3.31                 MNY     Reversed the fix on version 3.29, because this was to time consuming.
**                              A re-design of all these functions will be done in near future.
**          26.09.2003  DN      Removed lab module methods.
**          01.06.2004  AV      Ref Tracker 1209, added many new methods to several functions ref Stream db functions doc
**                              release 7.4 Increment 2
**          11.06.2004  HNE     Support for single sub daily record values.
**                              NB! If p_today IS NULL and its sub daily record access -> get single record
**                              If p_today IS NOT NULL and its sub daily record access -> get sum over prod days
**          09.07.2004  DN      Tracker 1327: Bug fix in function findStdDens.
**          28.07.2004  KSN     Tracker 1339: Bug fix in function findGrsStdVol
**          11.08.2004  Toha    Removed sysnam and stream_code and update as necessary
**          28.10.2004  Toha    PO.0026 Updated findGrsStdVol for AGA method calculation. Add:
**                                      findSpecificGravity
**                                      agaStaticPress
**                                      agaDiffStaticPress
**          28.10.2004  DN      Function findSpecificGravity: rewrote to not use generated views.
**          29.10.2004  Toha    Fixed function findSpecificGravity
**          18.11.2004          Tracker #1791: Fixed error in method findNetStdVol when NET_VOL_METHOD = 'GRS_BSW'
**          23.11.2004  DN      Tracker #1799: Re-implemented AGA-method in findGrsStdVol by adding new function calcDailyGrsStdVolFromEvents.
**          30.11.2004  MOT     Tracker #1724: Methods getBswWeightFrac and getBswVolFrac extended to handle that bsw methods returns ZERO. Also fixing bug in findNetStdMass in call to getBswWeightFrac (removing '<=' parameter).
**          07.01.2005  ROV     Tracker #1906: Removed undesired NVL usage in methods findNetStdVol,findGrsStdVol,findNetStdMass,findGrsStdMass
**                              Removed all uncommented references to sysnam,facility,stream_code etc..
**          23.02.2005 kaurrnar  Removed deadcode. Changed strm_attribute to strm_version
**          24.02.2005 DN       TI 1965: Removed getStdDensWell and findNetStdVolComp.
**          01.03.2005 Darren   Changed referencing column in findSpecificGravity AGA_REF_ANALYSIS to AGA_REF_ANALYSIS_ID
**          04.03.2005 kaurrnar Changed reference from 'STD_DENSITY_METHOD' to 'STD_DENS_METHOD' and from 'WAT_VOL_METHOD' to 'WATER_VOL_METHOD'.
**          07.03.2005 Toha     TI 1965: removed unused calcMthWeightedSaltFrac and getSalt. Wat_mass_method is water_mass_method.
**          11.03.2005 kaurrnar New method 'ANALYSIS_SP_GRAV' in findStdDens.
**                              Removed implementated methods description which are no longer used in findStdDens
**          27.04.2005 DN       Function findStdDens, method REF_VALUE: replaced function call to findRefValue with simple ec-package.
**          28.04.2005 DN       Bug fix: id columns must be declared varchar2(32).
**          09.05.2005 DN       TI 2203: ON_STRM_SECS redefined to ON_STREAM_HRS.
**          10.05.2005 DN       Function findSpecificGravity: Replaced sysdate with p_daytime in function call.
**          25.07.2005 Ron Boh  Updated function getbswvolfrac in ecbp_stream_fluid to support new BSW method on stream: SAMPLE_ANAL.
**          09.08.2005 Darren   TI 2234 Added new functions findGCV and findEnergy
**          18.08.2005 Toha     TI 2282: Updated getBswVolFrac, findSpecificGravity to use stream reference
**          28.10.2005 nazli    TI 2992: Updated all functions following coding standard formatting
**          02.11.2005 DN       Replaced type reference to objects view to specific object table (STREAM,TANK).
**          10.11.2005 CHONGJER TI 2520: Updated findSpecificGravity - Updated to reflect changes to ec codes.
**          19.12.2005 Ron      TI 2615 Added new functions findCGR, findWGR, findWDF and findCondVol
**                              Updated function findWatVol, getBswVolFrac and getBswWeightFrac
**          02.01.2006 DN       CGR_METHOD renamed to COND_VOL_METHOD.
**          23.01.2006 BOHHHRON Correct Typo error in findWGR
**          25.01.2006 BOHHHRON Update getBswVolFrac and getBswWeightFrac. It should be SAMPLE_ANALYSIS instead of SAMPLE_ANAL
**          20.03.2006 Seongkok TI#3377:  Added new function getSaltWeightFrac and update findNetStdMass
**          28.03.2006 eizwanik TI#3155: Edited findGrsStdVol, getBswVolFrac, findNetStdVol and findWatVol to include calculations for new Truck Ticket screens and their functionality
**          13.04.2006 Lau      TI#3721: Modify findnetstdvol - Add NVL(curEvent.vcf,1) where curEvent.vcf is referenced
**          18.04.2006 Lau      TI#3686: Raise error message to inform when set stream with gross_volume_method = net volume AND net_volume_method = grs volumn.
**          04.05.2006 HUS      TI#3704: Introduce aggregate_flag and stream_meter_method in
**                                         findGrsStdMass
**                                         findGrsStdVol
**                                         findNetStdMass
**                                         findNetStdVol
**                                         findStdDens
**                                         findWatMass
**                                         findWatVol
**                                         getBswVolFrac
**                                         getBswWeightFrac
**                                         getSaltWeightFrac
**                                       STREAM_METER_FREQ=='MONTH' changed to STRM_METER_FREQ='MTH'
**         18.05.2006 Lau       TD#6094: Fixed defect on function getSaltWeightFrac
**         25.05.2006 johanein  Made getSaltWeightFrac robust against vol/mass and mass/mass salt fraction MEASURED in DAY context.
**         13.06.2006 chongjer  TI#3882: Modified EcBp_Stream_FLuid.GetSaltWeightFrac to be robust against "division by zero"
**         07.08.2006 Toha      TI#4266: event streams should return 0
**         22.08.2006 siahohwi  TI#4412: Error in EcBp_Stream_Fluid.findCGR
**         26.09.2006 kaurrjes  TI#4547: Added new method "DERIVED" and "ALLOCATED" in findEnergy function
**         03.11.2006 ottermag  TI#3804: Truck Tickets - Single load Multiple offload (extending findGrsStdVol, findNetStdVol, findWatVol)
**         10.11.2006 seongkok  TI#3804: Added functions find_*_by_pc()
**         21.02.2007 zakiiari  ECDP#3649: Applied conversion factor in findGrsStdVol for TOTALIZER_EVENT, modified findNetStdVol to include manual_adj_vol
**         19.03.2007 Lau       ECPD-2026: Added function calcDailyRateTotalizer,modified findGrsStdVol for method TOTALIZER_EVENT,findNetStdVol to include method TOTALIZER_EVENT and TOTALIZER_EVENT_EXTRAPOLATE
**         30.04.2007 rajarsar  ECPD-5248: Updated function findEnergy with new method VOLUME_MBTU and findGrsStdVol to include new attributes: meter_factor_override, pressure_factor, pressure_factor_override, shrinkage_factor and shrinkage_factor_override.
**         22.05.2007 chongviv  ECPD-5361: Updated function findEnergy with new method VOLUME_REF_MBTU
**         13.06.2007 rajarsar  ECPD-2282: Added new function : getLastNotNullClosingValueDate
**         13.06.2007 rajarsar  ECPD-2026: Updated function : findNetStdvol and calcDailyRateTotalizer
**         13.06.2007 rajarsar  ECPD-5360: Modified function : findNetStdvol
**         29.06.2007 rajarsar  ECPD-5689: Modified function : findNetStdvol
**         23.08.2007 rajarsar  ECPD-6246: Updated findEnergy to add new method FORMULA.
**         30.08.2007 rahmanaz  ECPD-5724: Added function : find_net_mass_by_pc
**         04.09.2007 Lau       ECPD-6268: Modified findGrsStdMass, findNetStdMass, getBswWeightFrac,findWatMass function
**         11.09.2007 idrussab  ECPD-6295: Modified function getSaltWeightFrac, add method SAMPLE_ANALYSIS, COMP_ANALYSIS
**         20.09.2007 idrussab  ECPD-6591: removed function calcstddensnode
**         20.09.2007 ismaiime  ECPD-6019: Modified function findNetStdVol to add manual_adj_vol to net_vol for net_vol_method = 'TANK_DUAL_DIP'
**         28.09.2007 idrussab  ECPD-6646: Modified function findStdDens, getStdDensCompAnalysis, findGCV
**         03.10.2007 ismaiime  ECPD-6683: Modified function findStdDens add if method=ref_stream
**         03.12.2007 ismaiime  ECPD-7037: Modify function findSpecificGravity
**         21.11.2007 oonnnng   ECPD-6716: Updated getBSWVolFrac and getBSWWeightFrac functions to support USER_EXIT.
**         08.01.2008 aliassit  ECPD-7284: Added gravity_factor_override and temp_factor_override to function findGrsStdVol
**         21.01.2008 aliassit  ECPD-7291: Updated findGrsStdVol to add ln_override_grs_vol.
**         12.02.2008 kaurrjes  ECPD-7121: Modified function: findStdDens and findNetStdMass.
**         18.02.2008 aliassit  ECPD-6796: Modified function findEnergy, added ln_energy_override_factor
**         20.02.2008 oonnnng   ECPD-6978: Update findGrsStdVol with ENERGY_GCV (Energy/GCV) method and update findGCV with USER_EXIT method.
**         03.03.2008 rajarsar  ECPD-7127: Added new function : findPowerConsumption
**         03.14.2008 leongsei  ECPD-7381: Modified function findGCV, findEnergy to support stream meter frequency = MTH
**         15.04.2008 aliassit  ECPD-6486: Added GRS_VOL_METHOD: TANK_DUAL_DIP
**                                         Added NET_MASS_METHOD: TANK_DUAL_DIP
**                                         Added  GRS_MASS_METHOD: NET_MASS_WATER
**                                         and added support for all new methods.
**         28.04.2008 leeeewei  ECPD-7888: Modified findGCV function to use ref analysis stream to find gcv if method is COMP_ANALYSIS
**         28.04.2008 ismaiime  ECPD-8333: Modified function findPowerConsumption to aggregate daily measured values over a period
**         06.05.2008 ismaiime  ECPD-8334: Modified function findNetStdVol() to use net_vol for method=MEASURED and strm_meter_method=EVENT
**         09.05.2008 aliassit  ECPD-7895: Modified function findGrsStdVol() to set ln_totalizer_open := 0 if flag is set to 'Y' else it will take the last closing reading value
**         27.05.2008 sharawan  ECPD-7584: Modified function findWatVol to return calculated values instead of NULL for the event streams other than truck transports.
**         02.07.2008 ismaiime  ECPD-8950: Modified functions findGrsStdMass, findGrsStdVol, findNetStdMass and findGrsStdVol to handle monthly derived functions
**         21.08.2008 aliassit  ECPD-7090: Modified findNetStdVol to ensure no volumes are added incorrectly for a certain period
**         21.08.2008 jailunur  ECPD-9462: Modified findGrsStdVol conditions for method ENERGY_GCV.
**         22.08.2008 jailunur  ECPD-9518: Modified findNetStdVol condtion for lv2_tank_object_id attribute.
**         05.09.2008 sharawan  ECPD-7986: Modify functions findGrsStdVol and findNetStdVol in EcBp_Stream_Fluid package to return NULL when density value is 0.
**         23.09.2008 jailunur  ECPD-9576: Modify function findNetStdVol and findGrsStdVol to cater for monthly streams which have method MASS_DENSITY.Ad added c_system_month cursor.
**         16.10.2008 aliassit  ECPD-9984: Modify findGCV to add new GCV method ENERGY_DIV_VOLUME
**         30.10.2008 leongsei  ECPD-10133: Modify findNetStdVol, findWatVol to return positive value
**         02.12.2008 aliassit  ECPD-10482: Modified function findNetStdVol to have curEvent.vcf for method MEASURED_TRUCKED.
**         12.12.2008 oonnnng   ECPD-10285: Amended 'DENSITY' method in getSaltWeightFrac() function to get value from reference analysis stream, when there is a reference stream.
                                            Else, get value from the stream itself.
**         17.12.2008 oonnnng   ECPD-10559: Update method=COMP_ANALYSIS to cater lv2_phase=CON in findStdDens function.
**         19.12.2008 sharawan  ECPD-10269: Modify cursor c_comp_analysis to remove nvl-check on input parameter cp_analysis_type in getBswVolFrac, getBswWeightFrac, getSaltWeightFrac.
**         30.12.2008 sharawan  ECPD-10416:Replaced all references to EcDp_Type.pb_comp_number%TYPE with NUMBER in functions
**                              calcAvgBswVolFracMthToDay, calcAvgGrsStdMassMthToDay, calcAvgGrsStdDensMthToDay, calcAvgNetStdDensMthToDay,
**                              calcCumGrsStdMassMthToDay, calcCumGrsStdMassYearToDay, calcCumGrsStdVolMthToDay, calcCumGrsStdVolYearToDay,
**                              calcCumNetStdMassMthToDay, calcCumNetStdMassYearToDay, calcCumNetStdVolMthToDay, calcCumNetStdVolYearToDay,
**                              calcCumNetStdVolYearToDay, calcGrsStdVolTotalToDay, calcNetStdDens, calcNetStdMassTotalToDay, calcNetStdVolTotalToDay, calcWatVol,
**                              findGrsStdMass, findGrsStdVol, findNetStdMass, findNetStdVol, findStdDens, findWatMass, findWatVol, findCondVol, findCGR, findWGR,
**                              findWDF, getBswVolFrac, getBswWeightFrac, getSaltWeightFrac, getStdDensCompAnalysis, getStdDensFromApiAnalysis, getStdDensRefStream,
**                              getAvgOilInWater, calcgrsStdDens, findGCV, findEnergy, calcDailyRateTotalizer, findPowerConsumption.
**         02.01.2009 oonnnng   ECPD-9983: Update findStdDens(), and calcAvgGrsStdDensMthToDay functions by replace getLastAnalysisSampleByObject with getLastAnalysisSample.
**                                         Update findGCV(), getBSWVolFrac(), getBSWWeightFrac(), getSaltWeightFrac() and findSpecific() functions to call getLastAnalysisSample, instead of using its own cursors.
**         23.01.2009 rajarsar  ECPD-10346: Added function getAttributeName
**         05.02.2009 musaamah  ECPD-10810: Modified findNetStdVol,findGrsStdVol,findNetStdMass: Added the adjustment volume for each record and not only at the end. Removed ln_return_val := ln_return_val + ln_adj_vol at the end.
**         09.02.2009 farhaann  ECPD-10761: Added new function : findGrsDens with CALCULATED and USER_EXIT method
**                                          Added user_exit method in
**                                          - findNetStdMass
**                                          - findGrsStdMass
**                                          - findStdDens
**                                          - findWatVol
**                                          - findWatMass
**                                          - findCondVol
**                                          - findEnergy
**                                          Added grs_mass_minus_water method in findNetStdMass function
**         10.02.2009 leongwen  ECPD-10990: standardise on stream_phase = COND and upgrade all usage of CON to COND
**         19.02.2009 farhaann  ECPD-10761: Modified CALCULATED method in findGrsDens function
**                                          Modified calcgrsStdDens: Point this function to EcBp_Stream_Fluid.findGrsDens
**         26.02.2009 farhaann  ECPD-11055: Added method=COMP_ANALYSIS_SPOT, COMP_ANALYSIS_DAY, COMP_ANALYSIS_MTH, SAMPLE_ANALYSIS_SPOT, SAMPLE_ANALYSIS_DAY and SAMPLE_ANALYSIS_MTH in
**                                          getBSWVolFrac(), getBSWWeightFrac(), getSaltWeightFrac(), findSpecificGravity() and findGCV().
**                                          Added method=COMP_ANALYSIS_SPOT, COMP_ANALYSIS_DAY and COMP_ANALYSIS_MTH in findStdDens()
**         17.03.2009 leongsei  ECPD-11080: Modified function findWatVol, findNetStdMass for method TANK_DUAL_DIP
**                                          and findGrsStdMass for method NET_MASS_WATER
**         13.07.2009 farhaann  ECPD-11892: Added method = 'TOTALIZER_DAY' in findGrsStdVol, findGrsStdMass and findNetStdMass.
**                                          Modified findNetStdVol: Added stream_meter_freq = 'DAY' condition in 'TOTALIZER_DAY' method.
**         24.07.2009 farhaann  ECPD-11892: Modified method 'TOTALIZER_DAY' in findGrsStdVol, findGrsStdMass, findNetStdMass and findNetStdVol.
**                                        : Modified method 'TOTALIZER_EVENT' in findGrsStdVol.
**                                        : Modified cursor c_strm_reference in findGrsStdVol.
**         31.07.2009 farhaann  ECPD-11892: Modified method 'TOTALIZER_DAY' in findGrsStdVol and findGrsStdMass.
**         03.08.2009 embonhaf  ECPD-11153  Added VCF calculation for stream.
**         10.08.2009 leeeewei  ECPD-12153: Modified pressure calculation for chart type = square root in agaStaticPress and agaDiffStaticPress
**         02.09.2009 farhaann  ECPD-11887: Added method = GRS_MASS_BSW_VOL in findNetStdMass()
**         11.09.2009 ismaiime  ECPD-12255: Modified funtion agaStaticPress and agaDiffStaticPress to calculate correctly when chart_unit is configured in meter run.
**         19.11.2009 leongwen  ECPD-13175: Added findOnStreamHours function.
**         07.01.2010 farhaann  ECPD-13520: Added method = MEASURED_API in findStdDens()
**         18.01.2010 ismaiime  ECPD-13664: Modified function findEnergy. Added method TOTALIZER_DAY.
**         03.02.2010 oonnnng   ECPD-13689: Added 'GCV' method in findGCV() function, which refers to the 'Stream Reference Value''s GCV value.
**         03.02.2010 ismaiime  ECPD-13796: Modified function findNetStdVol for method TOTALIZER_EVENT
**         04.02.2010 leongsei  ECPD-13197: Modified function findNetStdVol, findGrsStdVol, findWatVol, findNetStdMass, findGrsStdMass, findWatMass for truck ticket calculation
**         10.01.2011 madondin  ECPD-16400: Modified function findGCV by adding 'REF_STREAM' method which refers to the GCV from Ref. Analysis Stream
**         05.04.2011 farhaann  ECPD-16791: Modified findEnergy, method VOLUME_GCV
**         05.04.2011 musthram  ECPD-16877: Modified function findGCV, to support method FORMULA
**         04.05.2011 leongwen  ECPD-16948: Stream method EcBp_Stream_Fluid.findGCV() doesnt return measured GCV when stream meter freq <> 'DAY' and aggregate_flag='Y'
**       06.06.2011 madondin  ECPD-16946: Modified findNetStdVol, findNetStdMass and findWatVol to make sure if volume=0,then net vol=0
**       27.07.2011 madondin  ECPD-18127: Modified findEnergy, findNetStdVol, findNetStdMass and findWatVol to make sure if volume=0 in between date,then net vol must not equal
**                                          to zero but must be accumulated
**       02.11.2011 kumarsur  ECPD-19035: Modified findEnergy, if date range then it doubles the energy value. Have fixed the function.
**         29.01.2011 madondin  ECPD-19110: Modified calcCumGrsStdMassMthToDay, calcCumGrsStdVolMthToDay, calcCumNetStdMassMthToDay and calcCumNetStdVolMthToDay in order to get
**                      proper aggregation of formula streams using NVL
**        02.12.2011 abdulmaw  ECPD-18570: Update USER_EXIT to have more then one USER_EXIT
**       10.01.2012 choonshu  ECPD-18284: Modified findGrsStdVol and findNetStdVol to fix the formula calculation for a period of time (Monthly)
**       13.01.2012 choonshu  ECPD-18284: Modified findGrsStdMass and findNetStdMass to fix the formula calculation for a period of time (Monthly)
**       06.02.2012 rajarsar  ECPD-19740: Modified findGrsStdMass,findGrsStdVol,findNetStdVol,findWatVol and getBswVolFrac to support union with table object_transport_event.
**       07.05.2012 limmmchu  ECPD-18569: Modified findStdDens to add new method, SAMPLE_ANALYSIS
**       15.06.2012 kumarsur  ECPD-21019: Modified findGrsStdMass added OR aggregate flag = 'Y'
**         16.07.2012 leongwen  ECPD-21376: Modified findStdDens to include the check on 'CO2'
**       27.07.2012 abdulmaw  ECPD-21535: Modified findGrsStdVol, findNetStdVol, findGrsStdMass and findNetStdMass to fix the formula calculation for Monthly
**       14.11.2012 musthram  ECPD-21840: Modified findWatMass to support method Gross Mass - Net Mass
**       09.01.2013 hismahas  ECPD-22580: Added User_Exit in
**                                        - findGrsStdVol
**                                        - findNetStdVol
**   21.03.2013 kumarsur ECPD-22598: Modified findGrsStdVol(),findNetStdVol() and added calcShrunkVol(), calcDiluentVol().
**   29.04.2013 musthram ECPD-22038: Modified findNetStdVol()
**   09.05.2013 musthram ECPD-23714: Modified findGrsStdMass, findGrsStdVol, findNetStdMass, findNetStdVol, findEnergy, findPowerConsumption and getSaltWeightFrac
**  28.05.2013 rajarsar ECPD-21876: Modified main cursor, findGrsStdMass, findGrsStdVol, findNetStdMass, findNetStdVol, find_net_vol_by_pc,find_water_vol_by_pc, findWatVol, findWatMass
**  01.08.2013 leongwen ECPD-20789: Added function findGOR() to find the measured or Reference value for GOR for a stream object.
**  18.09.2013 rajarsar ECPD-24491: Updated function findNetStdMass to support truck ticket events correctly for net method = 'VOLUME_DENSITY' and 'GROSS_BSW'.
**  27.09.2013 rajarsar ECPD-24193: Updated function findGrsStdVol to support method = 'AGA' correctly with the passing of correct class name 'PERIOD_GAS_STREAM_DATA_AGA' instead of 'PERIOD_GAS_STREAM_DATA'.
**  22.10.2013 musthram ECPD-25553: Updated function findGrsStdMass, findGrsStdVol, findGrsStdVol and findNetStdVol to fix formula calculation for Monthly
**  07.11.2013 wonggkai ECPD-25297: Updated function calcDiluentVol, calcShrunkVol, findNetStdVol. when ln_net_vol is 0 update ln_return_val to 0.
**  11.11.2013 leongwen ECPD-22183: Added logic in findGrsStdVol function to support the new gross volume method SEASONAL_VALUE.
**  14.11.2013 leongwen ECPD-22183: Enhanced the logic in findGrsStdVol function to support the new gross volume method SEASONAL_VALUE.
**  13.02.2014 deshpadi ECPD-26749: Modified function findGCV to support the updated GCV_METHOD 'Reference Value(REF_VALUE)'(Previously 'Grs Calorific Value(GCV)').
**  03.03.2014  dhavaalo ECPD-26738 Package ue_stream_fluid is missing the parameter P_TODATE in all functions
**  07.04.2014 kumarsur ECPD-26986: Modified findStdDens and findNetStdMass functions.
**  05.08.2014 kumarsur  ECPD-27067: Modified findGrsStdVol, findNetStdVol, calcShrunkVol and calcDiluentVol.
**  22.08.2014  SOHALRAN  ECPD-26507 Rewrite existing packages - Rewrite Ecbp_stream_fluid.findNetStdVol function for column name in cursor.
**  25.08.2014 sohalran ECPD-26506: Modified Ecbp_stream_fluid.findGrsStdVol we used specific column name in all cursor.
**  10.06.2015 patinpra  ECPD-31246: Modified findEnergy to sum up all month data under FORMULA section.
**  28.10.2015 chaudgau  ECPD-31659: Modified findNetStdVol and findGrsStdVol to reduce multiple calls to ec_strm_version into single row fetch
**  15.03.2016 jainnraj  ECPD-28803: Modified findNetStdVol to make changes for monthly stream to process loop for one DAYTIME
**  15.03.2016 kumarsur  ECPD-33240: Modified findNetStdVol method TOTALIZER_EVENT.
**  29.03.2016 jainnraj  ECPD-34113: Modified findGrsStdVol to make changes for Seasonal volume calculation for non leap year
**  14.07.2016 dhavaalo  ECPD-36648: Modified findGrsStdMass,findGrsStdVol,findNetStdMass,findNetStdVol and findGCV to support monthly frequency stream calculation.
**  02.08.2016 singishi  ECPD-36839: Modified findStdDens to support LNG phase in COMP_ANALYSIS_XXX.
**  17.08.2016 johamlei  ECPD-37553: Added functions getWaterDisposalDays()
**  02-01-2017 singishi  ECPD-38497: Added function SAMPLE_ANALYSIS_SPOT,SAMPLE_ANALYSIS_DAY,SAMPLE_ANALYSIS_MTH.
**  27-04-2017 kahsisag  ECPD-42452: Updated ECBP_STREAM_FLUID.findEnergy function to get value for energy for month.
**  27-04-2017 dhavaalo  ECPD-41351: Modified findNetStdVol method TOTALIZER_EVENT.
**  26-03-2018 abdulmaw  ECPD-55951: Modified findNetStdVol method TOTALIZER_EVENT to fix the calculation if more than 1 event on the same day.
*****************************************************************/
Type rec_seasonal is record
     (
         valid_from                    stream_seasonal_value.valid_from%Type,
         seasonal_factor               stream_seasonal_value.seasonal_factor%Type
     );

Type t_strm_seasonal_val               IS Table of rec_seasonal;

/* Cursors to be used by a number of functions involved with processing table strm_transport_event and object_transport_event for volume */
CURSOR c_strm_transport_event(cp_object_id VARCHAR2, cp_fromday DATE, cp_today DATE) IS
SELECT ste.event_no, ste.daytime
FROM strm_transport_event ste
WHERE ((ste.object_id = cp_object_id) OR (ste.stream_id = cp_object_id))
AND ste.production_day between cp_fromday AND cp_today
UNION ALL
SELECT ote.event_no, ote.daytime
FROM object_transport_event ote
WHERE ((ote.object_id = cp_object_id AND ote.object_type = 'STREAM') OR (ote.to_object_id = cp_object_id AND ote.to_object_type = 'STREAM'))
AND ote.data_class_name = 'OBJECT_SINGLE_TRANSFER'
AND ote.production_day between cp_fromday AND cp_today;



CURSOR c_system_month(cp_fromday DATE, cp_today DATE) IS
SELECT daytime
FROM system_month
WHERE daytime BETWEEN cp_fromday AND Nvl(cp_today,cp_fromday);

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcDailyGrsStdVolFromEvents
-- Description    : Returns the total of gross standard volumes for all events contributing to the day
--                  time frame for the stream and class given.
--
-- Preconditions  :  No overlapping event periods
--                   Each event period persists with an end date
--                   End date cannot be equal to daytime (from date).
--                   Only return one single daily rate
--                   No extrapolation
-- Postconditions :
--
-- Using tables   :  STRM_EVENT
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcDailyGrsStdVolFromEvents(p_object_id VARCHAR2, p_event_type VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_strm_event_sum(cp_object_id VARCHAR2, cp_event_type VARCHAR2, cp_day DATE) IS
SELECT SUM(grs_vol * (Least(end_date, cp_day + 1) - GREATEST(daytime, cp_day))/(end_date - daytime)) sum_daily_grs_vol
FROM strm_event
WHERE object_id = cp_object_id
AND event_type = cp_event_type
AND end_date > cp_day
AND daytime < cp_day + 1
;

 ln_return_val NUMBER;

BEGIN

   FOR cur_rec IN c_strm_event_sum(p_object_id, p_event_type, p_daytime) LOOP

      ln_return_val := cur_rec.sum_daily_grs_vol;

   END LOOP;

   RETURN ln_return_val;

END calcDailyGrsStdVolFromEvents;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcAvgBswVolFracMthToDay
-- Description    : Returns average bsw volume fraction from start of month to input date
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: GETBSWVOLFRAC
--        FINDGRSSTDVOL
--                  CALCCUMGRSSTDVOLMTHTODAY
--
--
-- Configuration
-- required       :
--
-- Behaviour      : Calculates the weighted BS_W Volume Fraction by using the gross oil
--        volume.
---------------------------------------------------------------------------------------------------
FUNCTION calcAvgBswVolFracMthToDay (
         p_object_id    stream.object_id%TYPE,
         p_daytime      DATE,
         p_bsw_method  VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

ln_return_val NUMBER;
ln_bsw_vol_sum    NUMBER;
ln_total_oil    NUMBER;

CURSOR c_daytime IS
SELECT daytime
FROM system_days
WHERE daytime BETWEEN Trunc(p_daytime,'MM') AND p_daytime;

BEGIN

   ln_bsw_vol_sum  := 0;
   ln_total_oil    := 0;

   FOR mycur IN c_daytime LOOP

        ln_bsw_vol_sum := ln_bsw_vol_sum +
              (
                nvl(getBswVolFrac(p_object_id, mycur.daytime, p_bsw_method),0) *
                 nvl(findGrsStdVol(p_object_id, mycur.daytime),0)
                );
   END LOOP;

   ln_total_oil := calcCumGrsStdVolMthToDay(p_object_id, p_daytime);

   IF (ln_bsw_vol_sum = 0 and ln_total_oil > 0) THEN

         ln_return_val := 0;

   ELSIF (ln_total_oil > 0 or ln_bsw_vol_sum > 0) THEN

         ln_return_val  := ln_bsw_vol_sum / ln_total_oil;  --Calculate a weighted bsw

   ELSE

         ln_return_val := NULL; --Returns NULL if net oil volume is not found or bsw_sum is 0

   END IF;

   RETURN ln_return_val;

END calcAvgBswVolFracMthToDay;

---------------------------------------------------------------------------------------------------
-- Function       : calcAvgGrsStdMass                                                            --
-- Description    : Returns the average gross mass for a                                         --
--                  stream from a given day to a given day.                                      --
-- Preconditions  : Assumes that all days have been defined.                                     --
--                  NULL is interpreted as a zero value                                          --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions: findGrsStdMass                                                               --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcAvgGrsStdMass (
         p_object_id    stream.object_id%TYPE,
         p_fromday      DATE,
         p_today        DATE,
         p_method       VARCHAR2 DEFAULT NULL,
         p_null_is_zero VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

ln_return_val NUMBER;
ln_days       NUMBER;

CURSOR c_daytime (p_fromday DATE, p_today DATE)IS
SELECT daytime
FROM system_days
WHERE daytime BETWEEN p_fromday AND p_today;

BEGIN
   ln_return_val := 0;

   FOR mycur in c_daytime (p_fromday, nvl(p_today, p_fromday))
   LOOP
     IF (p_null_is_zero IS NULL OR p_null_is_zero = 'N')
        THEN

        -- Get the cumulative net standard production for the period
        ln_return_val := ln_return_val + findGrsStdMass(p_object_id,mycur.daytime, mycur.daytime, p_method);

        ELSE

        ln_return_val := ln_return_val + nvl(findGrsStdMass(p_object_id, mycur.daytime, mycur.daytime, p_method),0);

     END IF;
   END LOOP;

   -- Calculate number of days from the BEGINning of month.
   ln_days := p_today - p_fromday + 1;


   IF ((ln_days > 0) AND (ln_return_val IS NOT NULL)) THEN

      ln_return_val  := ln_return_val / ln_days;

   ELSE

      ln_return_val := NULL; -- Returns NULL if gross volume is not found

   END IF;

   RETURN ln_return_val;

END calcAvgGrsStdMass;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcAvgGrsStdMassMthToDay                                                    --
-- Description    : Calculates the average standard gross mass for a stream                      --
--                  from the beginning of the month to the given day.                            --
-- Preconditions  : Assumes that all days have been defined.                                     --
--                  NULL is interpreted as a zero value                                          --
-- Postcondition  : Returns the average gross standard mass for all days from                    --
--                  the start of month to the given day.                                         --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions: calcAvgGrsStdMass                                                            --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcAvgGrsStdMassMthToDay (
         p_object_id   stream.object_id%TYPE,
         p_daytime     DATE,
         p_method      VARCHAR2 DEFAULT NULL,
         p_null_is_zero VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

ln_return_val NUMBER;
ln_nodays     NUMBER;
ld_fromday    DATE;

BEGIN

   ld_fromday    := greatest(EcDp_Objects.GetObjStartDate(p_object_id),Trunc(p_daytime,'MM'));

   ln_return_val := calcAvgGrsStdMass(
                                      p_object_id,
                                      ld_fromday,
                                      p_daytime,
                                      p_method,
                                      p_null_is_zero);

   RETURN ln_return_val;

END calcAvgGrsStdMassMthToDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcAvgGrsStdMassYearToDay                                                   --
-- Description    : Calculates the average gross standard mass for a stream                      --
--                  from the beginning of the year to the given day                              --
-- Preconditions  : Assumes that all days have been defined.                                     --
--                  NULL is interpreted as a zero value                                          --
-- Postcondition  : Returns the average net standard mass for all days from                      --
--                  the start of year to the given day.                                          --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions: calcAvgGrsStdMass                                                            --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcAvgGrsStdMassYearToDay (
         p_object_id    stream.object_id%TYPE,
         p_daytime      DATE,
         p_method       VARCHAR2 DEFAULT NULL,
         p_null_is_zero VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

ln_return_val NUMBER;
ld_fromday    DATE;

BEGIN

   ld_fromday    := greatest(EcDp_Objects.GetObjStartDate(p_object_id),Trunc(p_daytime,'YYYY'));

   ln_return_val := calcAvgGrsStdMass(
                                     p_object_id,
                                     ld_fromday,
                                     p_daytime,
                                     p_method,
                                     p_null_is_zero);

   RETURN ln_return_val;

END calcAvgGrsStdMassYearToDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcAvgGrsStdVol                                                             --
-- Description    : Returns the average gross standard volume for a                              --
--                  stream from a given day to a given day.                                      --
-- Preconditions  : Assumes that all days have been defined.                                     --
--                  NULL is interpreted as a zero value                                          --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions: findGrsStdVol                                                                --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcAvgGrsStdVol (
                           p_object_id    stream.object_id%TYPE,
                           p_fromday      DATE,
                           p_today        DATE,
                           p_method       VARCHAR2 DEFAULT NULL,
                           p_null_is_zero VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

ln_return_val NUMBER;
ln_days       NUMBER;

CURSOR c_daytime (p_fromday DATE, p_today DATE)IS
SELECT daytime
FROM system_days
WHERE daytime BETWEEN p_fromday AND p_today;

BEGIN
   ln_return_val := 0;

   FOR mycur in c_daytime (p_fromday, nvl(p_today, p_fromday))
   LOOP
     IF (p_null_is_zero IS NULL OR p_null_is_zero = 'N')
        THEN

        -- Get the cumulative net standard production for the period
        ln_return_val := ln_return_val + findGrsStdVol(p_object_id,mycur.daytime, mycur.daytime, p_method);

        ELSE

        ln_return_val := ln_return_val + nvl(findGrsStdVol(p_object_id, mycur.daytime, mycur.daytime, p_method),0);

     END IF;
   END LOOP;

   -- Calculate number of days from the BEGINning of month.
   ln_days := p_today - p_fromday + 1;


   IF ((ln_days > 0) AND (ln_return_val IS NOT NULL)) THEN

      ln_return_val  := ln_return_val / ln_days;

   ELSE

      ln_return_val := NULL; -- Returns NULL if gross volume is not found

   END IF;

   RETURN ln_return_val;

END calcAvgGrsStdVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcAvgGrsStdVolMthToDay                                                     --
-- Description    : Calculates the average standard gross volume for a stream                    --
--                  from the beginning of the month to the given day                             --
-- Preconditions  : Assumes that all days have been defined.                                     --
--                  NULL is interpreted as a zero value                                          --
-- Postcondition  : Returns the average gross standard volume for all days from                  --
--                  the start of month to the given day.                                         --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions: calcAvgGrsStdVol                                                             --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcAvgGrsStdVolMthToDay (
         p_object_id    stream.object_id%TYPE,
         p_daytime      DATE,
         p_method       VARCHAR2 DEFAULT NULL,
         p_null_is_zero VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

ln_return_val  NUMBER; -- Return a PowerBuilder compliant number
ld_fromday     DATE;

BEGIN

   ld_fromday    := greatest(EcDp_Objects.GetObjStartDate(p_object_id),Trunc(p_daytime,'MM'));

   ln_return_val := calcAvgGrsStdVol(
                                     p_object_id,
                                     ld_fromday,
                                     p_daytime,
                                     p_method,
                                     p_null_is_zero);

   RETURN ln_return_val;

END calcAvgGrsStdVolMthToDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcAvgGrsStdVolYearToDay                                                    --
-- Description    : Calculates the average gross standard volume for a stream                    --
--                  from the beginning of the year to the given day                              --
-- Preconditions  : Assumes that all days have been defined.                                     --
--                  NULL is interpreted as a zero value                                          --
-- Postcondition  : Returns the average net standard mass for all days from                      --
--                  the start of year to the given day.                                          --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions: calcAvgGrsStdVol                                                             --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcAvgGrsStdVolYearToDay (
         p_object_id    stream.object_id%TYPE,
         p_daytime      DATE,
         p_method       VARCHAR2 DEFAULT NULL,
         p_null_is_zero VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

ln_return_val NUMBER; -- Return a PowerBuilder compliant number
ld_fromday    DATE;

BEGIN

   ld_fromday    := greatest(EcDp_Objects.GetObjStartDate(p_object_id),Trunc(p_daytime,'YYYY'));

   ln_return_val := calcAvgGrsStdVol(
                                     p_object_id,
                                     ld_fromday,
                                     p_daytime,
                                     p_method,
                                     p_null_is_zero);

   RETURN ln_return_val;

END calcAvgGrsStdVolYearToDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcAvgNetStdMass                                                            --
-- Description    : Returns the average net mass for a                                           --
--                  stream from a given day to a given day.                                      --
-- Preconditions  : Assumes that all days have been defined.                                     --
--                  NULL is interpreted as a zero value                                          --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions: findNetStdMass                                                               --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcAvgNetStdMass (
     p_object_id    stream.object_id%TYPE,
     p_fromday      DATE,
     p_today        DATE,
     p_method       VARCHAR2 DEFAULT NULL,
     p_null_is_zero VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

ln_return_val NUMBER;
ln_days       NUMBER;

CURSOR c_daytime (p_fromday DATE, p_today DATE)IS
SELECT daytime
FROM system_days
WHERE daytime BETWEEN p_fromday AND p_today;

BEGIN

   ln_return_val := 0;

   FOR mycur in c_daytime (p_fromday, nvl(p_today, p_fromday))
   LOOP
     IF (p_null_is_zero IS NULL OR p_null_is_zero = 'N')
        THEN

        -- Get the cumulative net standard production for the period
        ln_return_val := ln_return_val + findNetStdMass(p_object_id,mycur.daytime, mycur.daytime, p_method);

        ELSE

        ln_return_val := ln_return_val + nvl(findNetStdMass(p_object_id, mycur.daytime, mycur.daytime, p_method),0);

     END IF;
   END LOOP;

   -- Calculate number of days from the beginning of month.
   ln_days := p_today - p_fromday + 1;


   IF ((ln_days > 0) AND (ln_return_val IS NOT NULL)) THEN

      ln_return_val  := ln_return_val / ln_days;

   ELSE

      ln_return_val := NULL; -- Returns NULL if gross volume is not found

   END IF;

   RETURN ln_return_val;

END calcAvgNetStdMass;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcAvgNetStdMassMthToDay                                                    --
-- Description    : Calculates the average standard net mass for a stream                        --
--                  from the beginning of the month to the given day                             --
-- Preconditions  : Assumes that all days have been defined.                                     --
--                  NULL is interpreted as a zero value                                          --
-- Postcondition  : Returns the average net standard mass for all days from                      --
--                  the start of month to the given day.                                         --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions: calcAvgNetStdMass                                                            --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcAvgNetStdMassMthToDay (
     p_object_id   stream.object_id%TYPE,
     p_daytime     DATE,
     p_method      VARCHAR2 DEFAULT NULL,
     p_null_is_zero VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

ln_return_val NUMBER; -- Return a PowerBuilder compliant number
ld_fromday    DATE;

BEGIN

   ld_fromday    := greatest(EcDp_Objects.GetObjStartDate(p_object_id),Trunc(p_daytime,'MM'));

   ln_return_val := calcAvgNetStdMass(
                                       p_object_id,
                                       ld_fromday,
                                       p_daytime,
                                       p_method,
                                       p_null_is_zero);


   RETURN ln_return_val;

END calcAvgNetStdMassMthToDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcAvgNetStdMassYearToDay                                                   --
-- Description    : Calculates the average standard mass for a stream                            --
--                  from the beginning of the year to the given day                              --
-- Preconditions  : Assumes that all days have been defined.                                     --
--                  NULL is interpreted as a zero value                                          --
-- Postcondition  : Returns the average net standard mass for all days from                      --
--                  the start of year to the given day.                                          --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions: calcAvgNetStdMass                                                            --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcAvgNetStdMassYearToDay (
     p_object_id    stream.object_id%TYPE,
     p_daytime      DATE,
     p_method       VARCHAR2 DEFAULT NULL,
     p_null_is_zero VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

ln_return_val NUMBER;
ld_fromday    DATE;

BEGIN

   ld_fromday    := greatest(EcDp_Objects.GetObjStartDate(p_object_id),Trunc(p_daytime,'YYYY'));

   ln_return_val := calcAvgNetStdMass(
                                     p_object_id,
                                     ld_fromday,
                                     p_daytime,
                                     p_method,
                                     p_null_is_zero);

   RETURN ln_return_val;

END calcAvgNetStdMassYearToDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcAvgNetStdVol                                                             --
-- Description    : Returns the average net volume for a                                         --
--                  stream from a given day to a given day.                                      --
-- Preconditions  : Assumes that all days have been defined.                                     --
--                  NULL is interpreted as a zero value                                          --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions: findNetStdVol                                                                --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcAvgNetStdVol (
     p_object_id    stream.object_id%TYPE,
     p_fromday      DATE,
     p_today        DATE,
     p_method       VARCHAR2 DEFAULT NULL,
     p_null_is_zero VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

ln_return_val NUMBER;
ln_days     NUMBER;

CURSOR c_daytime (p_fromday DATE, p_today DATE)IS
SELECT daytime
FROM system_days
WHERE daytime BETWEEN p_fromday AND p_today;

BEGIN
   ln_return_val := 0;

   FOR mycur in c_daytime (p_fromday, nvl(p_today, p_fromday))
   LOOP

   IF (p_null_is_zero IS NULL OR p_null_is_zero = 'N')

     THEN
        -- Get the cumulative net standard production for the period
        ln_return_val := ln_return_val + findNetStdVol(p_object_id,mycur.daytime, mycur.daytime, p_method);

   ELSE
        -- p_null_is_zero is zero
        ln_return_val := ln_return_val + nvl(findNetStdVol(p_object_id, mycur.daytime, mycur.daytime, p_method),0);

   END IF;

   END LOOP;

   -- Calculate number of days from the BEGINning of month.
   ln_days := p_today - p_fromday + 1;


   IF ((ln_days > 0) AND (ln_return_val IS NOT NULL)) THEN

      ln_return_val  := ln_return_val / ln_days;

   ELSE

      ln_return_val := NULL; -- Returns NULL if gross volume is not found

   END IF;

   RETURN ln_return_val;

END calcAvgNetStdVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcAvgNetStdVolMthToDay                                                     --
-- Description    : Calculates the average standard net volume for a stream                      --
--                  from the beginning of the month to the given day                             --
-- Preconditions  : Assumes that all days have been defined.                                     --
--                  NULL is interpreted as a zero value                                          --
-- Postcondition  : Returns the average net standard volume for all days from                    --
--                  the start of month to the given day.                                         --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions: calcAvgNetStdVol                                                             --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcAvgNetStdVolMthToDay (
     p_object_id    stream.object_id%TYPE,
     p_daytime      DATE,
     p_method       VARCHAR2 DEFAULT NULL,
     p_null_is_zero VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS


ln_return_val NUMBER; -- Return a PowerBuilder compliant number
ld_fromtime   DATE;

BEGIN

   ld_fromtime   := greatest(EcDp_Objects.GetObjStartDate(p_object_id),Trunc(p_daytime,'MM'));

   ln_return_val := calcAvgNetStdVol(
                                     p_object_id,
                                     ld_fromtime,
                                     p_daytime,
                                     p_method,
                                     p_null_is_zero);

   RETURN ln_return_val;

END calcAvgNetStdVolMthToDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcAvgGrsStdDensMthToDay
-- Description    : Calculates the average standard gross density for a stream
--                  from the beginning of the month to the given day
-- Preconditions  : Strm_day_stream.grs_vol is not NULL
--                  object_fluid_analysis.density carries the registered density
--                  for wet oil
-- Postcondition  : Calculates avg.density by summarising grs volume and
--                   calculated grs mass for the selected period.
-- Using Tables   : strm_day_stream,
--                  object_fluid_analysis
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcAvgGrsStdDensMthToDay (
     p_object_id    stream.object_id%TYPE,
     p_daytime      DATE)

RETURN NUMBER
--</EC-DOC>
IS


CURSOR c_day_vol_dens IS
SELECT s.daytime daytime,s.grs_vol grs_vol
FROM   strm_day_stream s
WHERE  s.object_id = p_object_id
AND    s.daytime between trunc(p_daytime,'MM') and p_daytime;





ln_return_val NUMBER;
ln_total_vol  number :=0;
ln_total_mass number :=0;
lr_analysis_sample object_fluid_analysis%ROWTYPE;


BEGIN


   FOR mycur IN c_day_vol_dens LOOP
     lr_analysis_sample := EcDp_Fluid_Analysis.getLastAnalysisSample(p_object_id, null, null, p_daytime, EcDp_Phase.Oil);

      ln_total_vol  := ln_total_vol  + Nvl(mycur.grs_vol,0);
     ln_total_mass := ln_total_mass + Nvl((mycur.grs_vol * lr_analysis_sample.density),0);

   END LOOP;


   IF (ln_total_vol > 0)  THEN

      ln_return_val := ln_total_mass / ln_total_vol;

   ELSE

      ln_return_val := NULL;

   END IF;

   RETURN ln_return_val;

END calcAvgGrsStdDensMthToDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcAvgNetStdDensMthToDay                                                    --
-- Description    : Returns average density from start of month to input date                    --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : SYSTEM_DAYS                                                                  --
--                                                                                               --
-- Using functions: FINDGRSSTDVOL                                                  --
--        FINDGRSSTDMASS                                                                  --
--                                                                                        --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                 --
--                                                                                               --
-- Behaviour      : Calculates the weighted density  by using the gross oil                   --
--        volume and gross oil mass                                                            --
---------------------------------------------------------------------------------------------------
FUNCTION calcAvgNetStdDensMthToDay (
     p_object_id    stream.object_id%TYPE,
     p_daytime      DATE,
     p_method  VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

ln_return_val NUMBER;
ln_net_vol_sum    NUMBER;
ln_net_mass_sum    NUMBER;

CURSOR c_daytime IS
SELECT daytime
FROM system_days
WHERE daytime BETWEEN Trunc(p_daytime,'MM') AND p_daytime;

BEGIN

   ln_net_vol_sum   := 0;
   ln_net_mass_sum  := 0;

   FOR mycur IN c_daytime LOOP

        ln_net_vol_sum  := ln_net_vol_sum +
                nvl(findNetStdVol(p_object_id, mycur.daytime),0);

        ln_net_mass_sum := ln_net_mass_sum +
               nvl(findNetStdMass(p_object_id, mycur.daytime),0);

   END LOOP;

   IF (ln_net_mass_sum = 0 and ln_net_vol_sum > 0) THEN

      ln_return_val := 0;

   ELSIF (ln_net_vol_sum > 0 or ln_net_mass_sum > 0) THEN

      ln_return_val  := ln_net_mass_sum / ln_net_vol_sum ;  --Calculate a weighted density

   ELSE

      ln_return_val := NULL; --Returns NULL if net oil volume or net oil mass is not found

   END IF;

   RETURN ln_return_val;

END calcAvgNetStdDensMthToDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcAvgNetStdVolYearToDay                                                    --
-- Description    : Calculates the average standard net volume for a stream                      --
--                  from the beginning of the year to the given day                              --
-- Preconditions  : Assumes that all days have been defined.                                     --
--                  NULL is interpreted as a zero value                                          --
-- Postcondition  : Returns the average net standard volume for all days from                    --
--                  the start of year to the given day.                                          --
-- Using Tables   :                                                                              --
--                                                                                               --
--                                                                                               --
-- Using functions: calcAvgNetStdVol                                                             --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcAvgNetStdVolYearToDay (
     p_object_id    stream.object_id%TYPE,
     p_daytime      DATE,
     p_method       VARCHAR2 DEFAULT NULL,
     p_null_is_zero VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

ln_return_val NUMBER;
ld_fromday    DATE;

BEGIN

   ld_fromday    := greatest(EcDp_Objects.GetObjStartDate(p_object_id),Trunc(p_daytime,'YYYY'));

   ln_return_val := calcAvgNetStdVol(
                                     p_object_id,
                                     ld_fromday,
                                     p_daytime,
                                     p_method,
                                     p_null_is_zero);

   RETURN ln_return_val;

END calcAvgNetStdVolYearToDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcCumGrsStdMassMthToDay                                                    --
-- Description    : Calculates the cumulative standard gross mass for a                          --
--                  stream from the beginning of the month to the given day                      --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
--                                                                                               --
-- Using functions: findGrsStdMass                                                               --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcCumGrsStdMassMthToDay (
     p_object_id    stream.object_id%TYPE,
     p_daytime      DATE,
     p_method       VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

ln_return_val NUMBER;
ld_fromday    DATE;
ln_total_val   NUMBER;

  CURSOR c_system_days IS
  SELECT daytime
  FROM system_days
  WHERE daytime BETWEEN ld_fromday AND Nvl(p_daytime, ld_fromday);

BEGIN

   ln_total_val := 0;
   ld_fromday    := greatest(EcDp_Objects.GetObjStartDate(p_object_id),Trunc(p_daytime,'MM'));

   FOR mycur IN c_system_days LOOP
  ln_return_val := findGrsStdMass(
                                   p_object_id,
                                   mycur.daytime,
                   mycur.daytime,
                                   p_method);

    ln_total_val := ln_total_val + ln_return_val;
   END LOOP;

   ln_return_val := ln_total_val;

   RETURN ln_return_val;

END calcCumGrsStdMassMthToDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcCumGrsStdMassYearToDay                                                   --
-- Description    : Calculates the cumulative standard gross mass for a                          --
--                  stream from the beginning of the month to the given day                      --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
--                                                                                               --
-- Using functions: findGrsStdMass                                                               --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcCumGrsStdMassYearToDay (
     p_object_id    stream.object_id%TYPE,
     p_daytime      DATE,
     p_method       VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

ln_return_val NUMBER;

ld_fromday    DATE;

BEGIN

   ld_fromday    := greatest(EcDp_Objects.GetObjStartDate(p_object_id),Trunc(p_daytime,'YYYY'));

   ln_return_val := findGrsStdMass(
                                  p_object_id,
                                  ld_fromday,
                                  p_daytime,
                                  p_method);


   RETURN ln_return_val;

END calcCumGrsStdMassYearToDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcCumGrsStdVolMthToDay                                                     --
-- Description    : Calculates the cumulative standard gross volume                              --
--                  for a stream from start of month to the given day.                           --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
--                                                                                               --
-- Using functions: findGrsStdVol                                                                --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcCumGrsStdVolMthToDay (
     p_object_id    stream.object_id%TYPE,
     p_daytime      DATE,
     p_method       VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

ln_return_val NUMBER;
ld_fromday    DATE;
ln_total_val   NUMBER;

  CURSOR c_system_days IS
  SELECT daytime
  FROM system_days
  WHERE daytime BETWEEN ld_fromday AND Nvl(p_daytime, ld_fromday);

BEGIN

   ln_total_val := 0;
   ld_fromday    := greatest(EcDp_Objects.GetObjStartDate(p_object_id),Trunc(p_daytime,'MM'));

   FOR mycur IN c_system_days LOOP
  ln_return_val := findGrsStdVol(
                                  p_object_id,
                                  mycur.daytime,
                                  mycur.daytime,
                                  p_method);

    ln_total_val := ln_total_val + ln_return_val;
   END LOOP;

   ln_return_val := ln_total_val;

   RETURN ln_return_val;

END calcCumGrsStdVolMthToDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcCumGrsStdVolYearToDay                                                    --
-- Description    : Calculates the cumulative standard gross volume                              --
--                  for a stream from start of year to the given day.                            --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
--                                                                                               --
-- Using functions: findGrsStdVol                                                                --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcCumGrsStdVolYearToDay (
     p_object_id    stream.object_id%TYPE,
     p_daytime      DATE,
     p_method       VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

ln_return_val NUMBER;
ld_fromday    DATE;

BEGIN

   ld_fromday    := greatest(EcDp_Objects.GetObjStartDate(p_object_id),Trunc(p_daytime,'YYYY'));

   ln_return_val := findGrsStdVol(
                                  p_object_id,
                                  ld_fromday,
                                  p_daytime,
                                  p_method);


   RETURN ln_return_val;


END calcCumGrsStdVolYearToDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcCumNetStdMassMthToDay                                                    --
-- Description    : Calculates the cumulative net standard mass in kg for                        --
--                  given stream from start of month to the given day                            --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
--                                                                                               --
-- Using functions: findNetStdMass                                                               --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcCumNetStdMassMthToDay (
     p_object_id    stream.object_id%TYPE,
     p_daytime      DATE,
     p_method       VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

ln_return_val NUMBER;
ld_fromday    DATE;
ln_total_val   NUMBER;

  CURSOR c_system_days IS
  SELECT daytime
  FROM system_days
  WHERE daytime BETWEEN ld_fromday AND Nvl(p_daytime, ld_fromday);

BEGIN

   ln_total_val := 0;
   ld_fromday    := greatest(EcDp_Objects.GetObjStartDate(p_object_id),Trunc(p_daytime,'MM'));

   FOR mycur IN c_system_days LOOP
  ln_return_val := findNetStdMass(
                                  p_object_id,
                                  mycur.daytime,
                                  mycur.daytime,
                                  p_method);

    ln_total_val := ln_total_val + ln_return_val;
   END LOOP;

   ln_return_val := ln_total_val;

   RETURN ln_return_val;


END calcCumNetStdMassMthToDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcCumNetStdMassYearToDay                                                   --
-- Description    : Calculates the cumulative net standard mass in kg for                        --
--                  given stream from start of year to the given day                             --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
--                                                                                               --
-- Using functions: findNetStdMass                                                               --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcCumNetStdMassYearToDay (
     p_object_id    stream.object_id%TYPE,
     p_daytime      DATE,
     p_method       VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

ln_return_val NUMBER;
ld_fromday    DATE;

BEGIN

   ld_fromday    := greatest(EcDp_Objects.GetObjStartDate(p_object_id),Trunc(p_daytime,'YYYY'));

   ln_return_val := findNetStdMass(
                                  p_object_id,
                                  ld_fromday,
                                  p_daytime,
                                  p_method);

   RETURN ln_return_val;

END calcCumNetStdMassYearToDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcCumNetStdVolMthToDay                                                     --
-- Description    : Calculates the cumulative net standard volume for                            --
--                  given stream from start of month to the given day                            --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
--                                                                                               --
-- Using functions: findNetStdVol                                                                --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcCumNetStdVolMthToDay (
     p_object_id    stream.object_id%TYPE,
     p_daytime      DATE,
     p_method       VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

ln_return_val NUMBER;
ld_fromday    DATE;
ln_total_val   NUMBER;

  CURSOR c_system_days IS
  SELECT daytime
  FROM system_days
  WHERE daytime BETWEEN ld_fromday AND Nvl(p_daytime, ld_fromday);

BEGIN

   ln_total_val := 0;
   ld_fromday    := greatest(EcDp_Objects.GetObjStartDate(p_object_id),Trunc(p_daytime,'MM'));

   FOR mycur IN c_system_days LOOP
  ln_return_val := findNetStdVol(
                                  p_object_id,
                                  mycur.daytime,
                                  mycur.daytime,
                                  p_method);

    ln_total_val := ln_total_val + ln_return_val;
   END LOOP;

   ln_return_val := ln_total_val;

   RETURN ln_return_val;

END calcCumNetStdVolMthToDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcCumNetStdVolYearToDay                                                    --
-- Description    : Calculates the cumulative net standard volume for                            --
--                  given stream from start of year to the given day                             --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
--                                                                                               --
-- Using functions: findNetStdVol                                                                --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcCumNetStdVolYearToDay (
     p_object_id    stream.object_id%TYPE,
     p_daytime      DATE,
     p_method       VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

ln_return_val NUMBER;
ld_fromday    DATE;

BEGIN

   ld_fromday    := greatest(EcDp_Objects.GetObjStartDate(p_object_id),Trunc(p_daytime,'YYYY'));

   ln_return_val := findNetStdVol(
                                  p_object_id,
                                  ld_fromday,
                                  p_daytime,
                                  p_method);


   RETURN ln_return_val;

END calcCumNetStdVolYearToDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcGrsStdMassTotalToDay                                                     --
-- Description    : Calculates the cumulative gross standard mass since start                    --
--                  of operations for a stream to a given day.                                   --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
--                                                                                               --
-- Using functions: EcDp_System.getSystemStartDate,                                              --
--                  findGrsStdMass                                                               --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcGrsStdMassTotalToDay (
     p_object_id    stream.object_id%TYPE,
     p_daytime      DATE,
     p_method       VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

ln_return_val NUMBER;
ld_fromday    DATE;

BEGIN

   ld_fromday    := greatest(EcDp_Objects.GetObjStartDate(p_object_id),EcDp_System.getSystemStartDate);

   ln_return_val := findGrsStdMass(
                                  p_object_id,
                                  ld_fromday,
                                  p_daytime,
                                  p_method);


   RETURN ln_return_val;

END calcGrsStdMassTotalToDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcGrsStdVolTotalToDay                                                      --
-- Description    : Calculates the cumulative gross standard volume since start                  --
--                  of operations for a stream to a given day.                                   --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
--                                                                                               --
-- Using functions: EcDp_System.getSystemStartDate,                                              --
--                  findGrsStdVol                                                               --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------

FUNCTION calcGrsStdVolTotalToDay (
     p_object_id    stream.object_id%TYPE,
     p_daytime      DATE,
     p_method       VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

ln_return_val NUMBER;
ld_fromday    DATE;

BEGIN

   ld_fromday    := greatest(EcDp_Objects.GetObjStartDate(p_object_id),EcDp_System.getSystemStartDate);

   ln_return_val := findGrsStdVol(
                                  p_object_id,
                                  ld_fromday,
                                  p_daytime,
                                  p_method);


   RETURN ln_return_val;

END calcGrsStdVolTotalToDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcNetStdDens                                                               --
-- Description    : Returns the calculated net density on a given day                            --
--                  from a calculated stream net mass and net volume.                            --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
--                                                                                               --
-- Using functions: findNetStdVol,                                                               --
--                  findNetStdMass                                                               --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------

FUNCTION calcNetStdDens (
     p_object_id    stream.object_id%TYPE,
     p_daytime      DATE,
     p_method       VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

ln_return_val  NUMBER;
ln_net_vol     NUMBER;
ln_net_mass    NUMBER;

BEGIN

   ln_net_vol  := findNetStdVol(
                                p_object_id,
                                p_daytime,
                                p_daytime,
                                p_method);

   ln_net_mass := findNetStdMass(
                                p_object_id,
                                p_daytime,
                                p_daytime,
                                p_method);

   IF ((ln_net_vol > 0) AND (ln_net_mass IS NOT NULL)) THEN

      ln_return_val := ln_net_mass / ln_net_vol;

   ELSE

      ln_return_val := NULL;

   END IF;

   RETURN ln_return_val;

END calcNetStdDens;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcNetStdMassTotalToDay                                                     --
-- Description    : Calculates the cumulative net standard mass since start                      --
--                  of operations for a stream to a given day.                                   --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
--                                                                                               --
-- Using functions: EcDp_System.getSystemStartDate,                                              --
--                  findNetStdMass                                                               --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcNetStdMassTotalToDay (
     p_object_id    stream.object_id%TYPE,
     p_daytime      DATE,
     p_method       VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

ln_return_val NUMBER;

ld_fromday    DATE;

BEGIN

   ld_fromday    := greatest(EcDp_Objects.GetObjStartDate(p_object_id),EcDp_System.getSystemStartDate);

   ln_return_val := findNetStdMass(
                                  p_object_id,
                                  ld_fromday,
                                  p_daytime,
                                  p_method);


   RETURN ln_return_val;

END calcNetStdMassTotalToDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcNetStdVolTotalToDay                                                     --
-- Description    : Calculates the cumulative net standard volume since start                      --
--                  of operations for a stream to a given day.                                   --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
--                                                                                               --
-- Using functions: EcDp_System.getSystemStartDate,                                              --
--                  findNetStdVol                                                               --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcNetStdVolTotalToDay (
     p_object_id    stream.object_id%TYPE,
     p_daytime      DATE,
     p_method       VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

ln_return_val NUMBER;

ld_fromday    DATE;

BEGIN

   ld_fromday    := greatest(EcDp_Objects.GetObjStartDate(p_object_id),EcDp_System.getSystemStartDate);

   ln_return_val := findNetStdVol(
                                  p_object_id,
                                  ld_fromday,
                                  p_daytime,
                                  p_method);


   RETURN ln_return_val;

END calcNetStdVolTotalToDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcWatVol                                                                   --
-- Description    : Calculates and returns the water volume for a given                          --
--                  stream and period.                                                           --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   : system_days                                                                  --
--                                                                                               --
--                                                                                               --
-- Using functions: findWatMass,                                                                 --
--                  findWatDens                                                                  --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcWatVol (
     p_object_id    stream.object_id%TYPE,
     p_fromday      DATE,
     p_today        DATE DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS


CURSOR c_system_days IS
SELECT daytime
FROM system_days
WHERE daytime BETWEEN p_fromday AND Nvl(p_today, p_fromday);

ln_return_val  NUMBER;
ln_wat_dens    NUMBER;
ln_wat_mass    NUMBER;
ld_day         DATE;
ln_wat_vol     NUMBER;

BEGIN

   ln_wat_vol := 0;

   FOR mycur IN c_system_days LOOP

      ld_day      := mycur.daytime;

      ln_wat_mass := findWatMass(
                                p_object_id,
                                ld_day,
                                ld_day);

      ln_wat_dens := findWatDens(
                                p_object_id,
                                ld_day);

      IF ((ln_wat_mass IS NOT NULL) AND (ln_wat_dens > 0)) THEN

         ln_wat_vol := ln_wat_vol + ln_wat_mass / ln_wat_dens;

      END IF;

   END LOOP;

   IF (ln_wat_vol > 0) THEN

      ln_return_val := ln_wat_vol;

   ELSE

      ln_return_val  := NULL;

   END IF;

   RETURN ln_return_val;

END calcWatVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGrsStdMass
-- Description    : Returns the gross standard mass in kg for a given stream
--                  and period.
-- Preconditions  :
-- Postcondition  : All input data to calucations must have a defined value or else
--                  the funtion will return null
-- Using Tables   : SYSTEM_DAYS
--
-- Using functions: EC_STRM_VERSION....
--                  ECDP_STREAM_MEASURED.GETGRSSTDMASS
--                  ECBP_STREAM_FLUID.FINDGRSSTDVOL
--                  ECBP_STREAM_FLUID.FINDSTDDENS
--                  ECBP_STREAM_FLUID.FINDNETSTDMASS
--
-- Configuration
-- required       :
--
-- Behaviour      : Alternative STRM_VERSION.... (GRS_MASS_METHOD):
--
--                1. 'MEASURED': Find gross mass using data from strm_day_stream/strm_mth_stream only.
--                2. 'NET_MASS_WATER'
--                3. 'FORMULA': Find gross mass based on a formula
--                4. 'NET_MASS': Gross mass equals net mass
--                5. 'VOLUME_DENSITY': Find gross mass as (volume * density)
--                6. 'RUNTIME_RATE': Find gross mass as stream ref value mass rate times on strm fraction
--                7. 'OPEN_CLOSE_WEIGHT'
--                8. 'USER_EXIT'
--                9. 'TOTALIZER_DAY'
---------------------------------------------------------------------------------------------------
FUNCTION findGrsStdMass (
     p_object_id    stream.object_id%TYPE,
     p_fromday      DATE,
     p_today        DATE     DEFAULT NULL,
     p_method       VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

  lv2_method    VARCHAR2(30);
  ln_return_val NUMBER;

  CURSOR c_daytime IS
  SELECT daytime
  FROM system_days
  WHERE daytime BETWEEN p_fromday AND Nvl(p_today,p_fromday);

  CURSOR c_strm_event(cp_object_id VARCHAR2, cp_fromday DATE, cp_today DATE) IS
  SELECT *
  FROM strm_event
  WHERE object_id = cp_object_id
  AND   Nvl(event_day,TRUNC(daytime)) BETWEEN cp_fromday AND cp_today
  ORDER BY daytime ASC;

  CURSOR c_strm_event_single(cp_object_id VARCHAR2, cp_fromday DATE) IS
  SELECT *
  FROM strm_event
  WHERE object_id = cp_object_id
  AND daytime = cp_fromday;


  lv2_records_found    VARCHAR2(1);
  ld_fromday           DATE;
  ld_today             DATE;
  lv2_strm_meter_freq  VARCHAR2(300);
  lv2_strm_meter_method  VARCHAR2(300);
  lv2_aggregate_flag   VARCHAR2(2);
  lv2_stream_object_id stream.object_id%TYPE;
  ln_mass_rate         NUMBER;
  ln_runtime_hrs       NUMBER;
  ln_grsstdmass        NUMBER;
  lb_first_iteration   BOOLEAN;
  lv2_tank_object_id   tank.object_id%TYPE;
  ln_grs_mass           NUMBER;
  ln_closing_read      NUMBER;
  ln_opening_override  NUMBER;
  ln_opening_read      NUMBER;
  lr_strm_day_stream   strm_day_stream%ROWTYPE;
  ln_rollover_val      NUMBER;
  lr_strm_reference_value strm_reference_value%ROWTYPE;
  ln_cur_date       DATE;

BEGIN

  -- For future production day handeling
  ld_fromday := p_fromday;
  ld_today := p_today;

  lv2_stream_object_id :=  p_object_id;

  -- Find this streams strm_meter_freq
  lv2_strm_meter_freq := NVL(ec_strm_version.STRM_METER_FREQ(p_object_id, ld_fromday, '<='),'');

  -- Find this streams aggregate_flag
  lv2_aggregate_flag := NVL(ec_strm_version.aggregate_flag(p_object_id, ld_fromday, '<='),'NA');

  -- Find this streams meter method
  lv2_strm_meter_method := NVL(ec_strm_version.strm_meter_method(p_object_id, ld_fromday, '<='),'');

  -- Determine which method to use
  lv2_method := Nvl(p_method,
                      ec_strm_version.GRS_MASS_METHOD(
                      p_object_id,
                      ld_fromday,
                      '<=' ));

  -- METHOD= 'MEASURED' ( Only measured values.)
  IF (lv2_method = EcDp_Calc_Method.MEASURED) THEN

    IF lv2_strm_meter_freq = 'DAY' OR lv2_aggregate_flag = 'Y' THEN

      ln_return_val := Ec_Strm_day_stream.math_grs_mass(
                                                        p_object_id,
                                                        ld_fromday,
                                                        ld_today);    -- Underlying function uses Oracle BETWEEN

    ELSIF lv2_strm_meter_freq = 'MTH' THEN

      ln_return_val := Ec_Strm_mth_stream.math_grs_mass(
                                                        p_object_id,
                                                        ld_fromday,
                                                        ld_today);     -- Underlying function uses Oracle BETWEEN

    ELSIF lv2_strm_meter_method = 'EVENT' THEN

      ln_return_val := 0;
      IF ld_today IS NULL THEN

        FOR curEvent IN c_strm_event_single(lv2_stream_object_id, ld_fromday) LOOP

          ln_return_val :=  curEvent.grs_mass;

        END LOOP;

      ELSE

        lb_first_iteration := TRUE;

        FOR curEvent IN c_strm_event(lv2_stream_object_id, ld_fromday, ld_today) LOOP

          IF lb_first_iteration THEN

            lb_first_iteration := FALSE;
            ln_return_val :=  curEvent.grs_mass;

          ELSE

            ln_return_val :=  ln_return_val + curEvent.grs_mass;

          END IF;

        END LOOP;
      END IF;
    END IF;


  ELSIF (lv2_method = EcDp_Calc_Method.NET_MASS_WATER) THEN
    ln_return_val := 0;

    -- test if it is a single record or sum over production days to be returned
    IF ld_today IS NULL THEN

      -- Loop over single stream_event record.
      FOR curEvent IN c_strm_event_single(lv2_stream_object_id, ld_fromday) LOOP

        ln_grs_mass := EcBp_Tank.findGrsMass(curEvent.tank_object_id,'DUAL_DIP_OPENING',curEvent.daytime, NULL) -
                       EcBp_Tank.findGrsMass(curEvent.tank_object_id,'DUAL_DIP_CLOSING',curEvent.daytime, NULL);

        ln_return_val :=  ln_grs_mass;

      END LOOP;

    ELSE
      lb_first_iteration:= TRUE;

      FOR curEvent IN c_strm_event(lv2_stream_object_id, ld_fromday, ld_today) LOOP

        ln_grs_mass := EcBp_Tank.findGrsMass(curEvent.tank_object_id,'DUAL_DIP_OPENING',curEvent.daytime, NULL) -
                       EcBp_Tank.findGrsMass(curEvent.tank_object_id,'DUAL_DIP_CLOSING',curEvent.daytime, NULL);

        IF lb_first_iteration THEN

          lb_first_iteration := FALSE;
          ln_return_val := ln_grs_mass;

        ELSE

          ln_return_val := ln_return_val + ln_grs_mass;

        END IF;

      END LOOP;

    END IF;

  ELSIF (lv2_method = EcDp_Calc_Method.FORMULA) THEN
  IF lv2_strm_meter_freq = 'MTH' THEN
       ln_return_val := EcDp_Stream_Formula.getGrsStdMass(
                                                      p_object_id,
                                                      ld_fromday,
                                                      ld_today);
  ELSE
    IF ld_today IS NOT NULL AND ld_today > ld_fromday THEN
      ln_return_val := 0;
      ln_cur_date := ld_fromday;

      WHILE ln_cur_date <= ld_today LOOP
        ln_return_val := ln_return_val + EcDp_Stream_Formula.getGrsStdMass(
                                                      p_object_id,
                                                      ln_cur_date,
                                                      NULL);
        ln_cur_date := ln_cur_date + 1;
      END LOOP;

    ELSE
      ln_return_val := EcDp_Stream_Formula.getGrsStdMass(
                                                      p_object_id,
                                                      ld_fromday,
                                                      ld_today);
    END IF;
  END IF;

  ELSIF (lv2_method = EcDp_Calc_Method.NET_MASS) THEN

    ln_return_val := EcBp_Stream_Fluid.findNetStdMass(
                                                      p_object_id,
                                                      ld_fromday,
                                                      ld_today);


  ELSIF (lv2_method = EcDp_Calc_Method.VOLUME_DENSITY) THEN

    lb_first_iteration:= TRUE;

    IF lv2_strm_meter_freq = 'MTH' THEN

      ln_return_val := EcBp_Stream_Fluid.findGrsStdVol(p_object_id,p_fromday,p_today) *
                              EcBp_Stream_Fluid.findStdDens(p_object_id,p_fromday);
    ELSIF lv2_strm_meter_freq = 'DAY' OR lv2_aggregate_flag = 'Y' THEN

      FOR mycur IN c_daytime LOOP

        ln_grsstdmass := EcBp_Stream_Fluid.findGrsStdVol(p_object_id,mycur.daytime,mycur.daytime) *
                         EcBp_Stream_Fluid.findStdDens(p_object_id,mycur.daytime);

        IF lb_first_iteration THEN

          lb_first_iteration := FALSE;
          ln_return_val := ln_grsstdmass;

        ELSE

          ln_return_val := ln_return_val + ln_grsstdmass;

        END IF;

      END LOOP;

    ELSIF lv2_strm_meter_method = 'EVENT' THEN

      ln_return_val:=0;
      IF ld_today IS NULL THEN
        FOR curEvent IN c_strm_event_single(lv2_stream_object_id,ld_fromday) LOOP
          ln_return_val := ecbp_stream_fluid.findGrsStdVol(p_object_id,curEvent.Daytime)*Ecbp_Stream_Fluid.findStdDens(p_object_id,curEvent.Daytime);
        END LOOP;
      ELSE
        lb_first_iteration:=TRUE;
        FOR curEvent IN c_strm_event(lv2_stream_object_id,ld_fromday,ld_today) LOOP
          IF lb_first_iteration THEN
            lb_first_iteration:=FALSE;
            ln_return_val:=Ecbp_Stream_Fluid.findGrsStdVol(p_object_id,curEvent.Daytime)*Ecbp_Stream_Fluid.findStdDens(p_object_id,curEvent.Daytime);
          ELSE
            ln_return_val:=ln_return_val + Ecbp_Stream_Fluid.findGrsStdVol(p_object_id,curEvent.Daytime);
          END IF;
        END LOOP;
      END IF;
    END IF;

  ELSIF (lv2_method = EcDp_Calc_Method.RUNTIME_RATE) THEN

    lb_first_iteration := TRUE;

    FOR mycur2 IN c_daytime LOOP

      ln_mass_rate := ec_strm_reference_value.hr_mass_rate(lv2_stream_object_id,mycur2.daytime,'<=');
      ln_runtime_hrs := EcBp_Stream_Fluid.findOnStreamHours(p_object_id,mycur2.daytime);

      IF lb_first_iteration THEN

        lb_first_iteration := FALSE;
        ln_return_val := ln_mass_rate * ln_runtime_hrs;

      ELSE

        ln_return_val := ln_return_val + ln_mass_rate * ln_runtime_hrs;

      END IF;

    END LOOP;

  ELSIF (lv2_method = EcDp_Calc_Method.MEASURED_TRUCKED) THEN
    ln_return_val := 0;
    IF ld_today IS NULL THEN -- indicates we are looking for single event value
      ln_return_val := NULL;  -- this is not possible, use EcBp_Truck_Ticket.findGrsStdMass() instead but it cannot be called from here.
    ELSE -- looking for sum of event values over a given period
      lb_first_iteration:= TRUE;
      FOR curEvent2 IN c_strm_transport_event (lv2_stream_object_id, ld_fromday, ld_today) LOOP
        IF lb_first_iteration THEN
          lb_first_iteration := FALSE;
          ln_return_val :=  EcBp_Truck_Ticket.findGrsStdMass(curEvent2.event_no);
        ELSE
          ln_return_val :=  ln_return_val + EcBp_Truck_Ticket.findGrsStdMass(curEvent2.event_no);
        END IF;
      END LOOP;
    END IF;
  ELSIF (lv2_method = EcDp_Calc_Method.OPEN_CLOSE_WEIGHT) THEN

    ln_return_val := 0;
    IF ld_today IS NULL THEN

      FOR curEvent2 IN c_strm_event_single(lv2_stream_object_id, ld_fromday) LOOP

        IF  curEvent2.event_type = 'STRM_OIL_EXPORT_EVENT' THEN

          ln_return_val :=  curEvent2.GRS_CLOSING_MASS - curEvent2.GRS_OPENING_MASS;

        END IF;

      END LOOP;

    ELSE

      lb_first_iteration:= TRUE;

      FOR curEvent2 IN c_strm_event(lv2_stream_object_id, ld_fromday, ld_today) LOOP

        IF  curEvent2.event_type = 'STRM_OIL_EXPORT_EVENT' THEN

          IF lb_first_iteration THEN

            lb_first_iteration := FALSE;
            ln_return_val := curEvent2.GRS_CLOSING_MASS - curEvent2.GRS_OPENING_MASS;

          ELSE

            ln_return_val := ln_return_val + curEvent2.GRS_CLOSING_MASS - curEvent2.GRS_OPENING_MASS;

          END IF;

        END IF;

      END LOOP;

    END IF;

  -- User Exit
  ELSIF (substr(lv2_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN

    ln_return_val := ue_stream_fluid.getGrsStdMass(p_object_id, p_fromday,p_today);

  -- Totalizer Day
  ELSIF (lv2_method = ecdp_calc_method.TOTALIZER_DAY) THEN

    IF lv2_strm_meter_freq = 'DAY' THEN

      lr_strm_day_stream := ec_strm_day_stream.row_by_pk(lv2_stream_object_id, ld_fromday, '=');

      ln_closing_read := lr_strm_day_stream.totalizer_mass;
      ln_opening_override := lr_strm_day_stream.totalizer_mass_override;

      IF ln_opening_override IS NULL THEN

         ln_opening_read := ec_strm_day_stream.totalizer_mass(p_object_id,p_fromday-1);

      END IF;

      lr_strm_reference_value := ec_strm_reference_value.row_by_pk(lv2_stream_object_id, ld_fromday, '<=');
      ln_rollover_val := lr_strm_reference_value.totalizer_max_count;

      IF ln_closing_read < nvl(ln_opening_override,ln_opening_read) THEN

         ln_grs_mass := (ln_closing_read - NVL(ln_opening_override, ln_opening_read) + nvl(ln_rollover_val, 0));

      ELSE

         ln_grs_mass := ln_closing_read - NVL(ln_opening_override,ln_opening_read);

      END IF;

        ln_return_val := ln_grs_mass;

    END IF;

  ELSE

    ln_return_val := NULL;

  END IF;

  RETURN ln_return_val;

END findGrsStdMass;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGrsStdVol
-- Description    : Returns the gross standard volume in Sm3 for a given
--                  stream and period.
-- Preconditions  : All input values to calculation must have a defined value or else
--                  the function call will return null.
-- Postcondition  :
-- Using Tables   : SYSTEM_DAYS
--
-- Using functions: EC_STRM_VERSION....
--                  ECDP_STREAM.GETSTREAMPHASE
--                  ECDP_STREAM_MEASURED.GETGRSSTDVOL
--                  ECBP_STREAM_FLUID.FINDNETSTDVOL
--                  ECBP_STREAM_FLUID.calcDailyGrsStdVolFromEvents
-- Configuration
-- required       :
--
-- Behaviour      : Alternative STRM_VERSION.... (GRS_VOL_METHOD):
--
--                 1. 'MEASURED' ( Only measured values.)
--                 2. 'MASS_DENSITY'
--                 3. 'TANK_DUAL_DIP'                                                                                                                               --
--                 4. 'AGA'
--                 5. 'FORMULA'
--                 6. 'NA'
--                 7. 'NET_VOL'
--                 8. 'RUNTIME_RATE'
--                 9. 'TOTALIZER_EVENT'
--                 10.'NET_VOL_WATER'
--                 11.'MEASURED_TRUCKED' Get grs_vol from truck ticket data
--                 12.'TOTALIZER_DAY'
--                 13.'USER_EXIT'
---------------------------------------------------------------------------------------------------
FUNCTION findGrsStdVol (
     p_object_id    stream.object_id%TYPE,
     p_fromday      DATE,
     p_today        DATE DEFAULT NULL,
     p_method       VARCHAR2 DEFAULT NULL,
     p_resolve_loop VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

  Lv2_method                    VARCHAR2(32);
  ln_grs_vol                    NUMBER;
  ln_net_vol                    NUMBER;
  ln_return_val                 NUMBER;
  lv2_phase                     VARCHAR2(32);
  lv2_type                      VARCHAR2(32);
  lb_first_iteration            BOOLEAN;
  ln_density                    NUMBER;
  ld_fromday                    DATE;
  ld_today                      DATE;
  lv2_strm_meter_freq           VARCHAR2(300);
  lv2_strm_meter_method         VARCHAR2(300);
  lv2_aggregate_flag            VARCHAR2(2);
  ln_vol_rate                   NUMBER;
  ln_runtime_hrs                NUMBER;
  lv2_stream_object_id          stream.object_id%TYPE;
  ln_opening_vol                NUMBER;
  ln_TOTALIZER_MAX_COUNT        NUMBER;
  ln_count                      NUMBER; --AGA prop
  ln_end_date                   DATE; --AGA prop
  ld_prod_day_start             DATE;
  lv2_resolve_loop              VARCHAR2(2000);
  ln_totalizer_close            NUMBER;
  ln_totalizer_open             NUMBER;
  ln_totalizer_open_overwrite   NUMBER;
  ln_conversion_factor          NUMBER;
  ln_meter_factor               NUMBER;
  ln_meter_factor_override      NUMBER;
  ln_pressure_factor            NUMBER;
  ln_pressure_factor_override   NUMBER;
  ln_shrinkage_factor           NUMBER;
  ln_shrinkage_factor_override  NUMBER;
  ln_gravity_factor             NUMBER;
  ln_gravity_factor_override    NUMBER;
  ln_temp_factor                NUMBER;
  ln_temp_factor_override       NUMBER;
  ln_rate_per_event             NUMBER;
  ln_hours_per_event_start      NUMBER;
  ln_vol_per_event_start        NUMBER;
  ln_hours_per_event_between    NUMBER;
  ln_vol_per_event_between      NUMBER;
  ln_hours_per_event_end        NUMBER;
  ln_vol_per_event_end          NUMBER;
  ln_rollover_val               NUMBER;
  ln_total_grs_vol              NUMBER;
  ln_manual_adj                 NUMBER;
  ln_vcf                        NUMBER;
  ln_override_grs_vol           NUMBER;
  ln_adj_vol                    NUMBER;
  lv2_tank_object_id            tank.object_id%TYPE;
  ln_energy                     NUMBER;
  ln_GCV                        NUMBER;
  ln_grs_mass                   NUMBER;
  lv_grs_method                 VARCHAR2(32);
  lr_strm_day_stream            strm_day_stream%ROWTYPE;
  lr_strm_reference_value       strm_reference_value%ROWTYPE;
  ln_closing_read               NUMBER;
  ln_opening_override           NUMBER;
  ln_opening_read               NUMBER;
  ln_cur_date                    DATE;

  lv2_seasonal_stream_objid     STRM_VERSION.REF_SEASONAL_STREAM_ID%TYPE;
  ld_curr_season_year           DATE;
  ld_date                       DATE;
  ld_first_valid_from           DATE;
  ln_last_factor                NUMBER;
  ln_First_year                 NUMBER;
  typ_strm_seasonal_val         t_strm_seasonal_val        := t_strm_seasonal_val();
  lr_strm_version_rec           strm_version%ROWTYPE;

  CURSOR c_daytime IS
  SELECT daytime
  FROM system_days
  WHERE daytime BETWEEN p_fromday AND Nvl(p_today,p_fromday);

  CURSOR c_strm_event(cp_object_id VARCHAR2, cp_fromday DATE, cp_today DATE) IS
  SELECT grs_vol,
         tank_object_id,
         manual_adj_vol,
         Grs_Closing_Vol,
         object_id,
         shrinkage_factor_override,
         pressure_factor_override,
         meter_factor_override,
         daytime,
         Grs_Opening_Vol,
         gravity_factor_override,
         temp_factor_override,
         vcf,Event_Type
  FROM strm_event
  WHERE object_id = cp_object_id
  AND Nvl(event_day,TRUNC(daytime)) BETWEEN cp_fromday AND cp_today
  ORDER BY daytime ASC;

  CURSOR c_strm_event_single(cp_object_id VARCHAR2, cp_fromday DATE) IS
  SELECT grs_vol,
         tank_object_id,
         manual_adj_vol,
         Grs_Closing_Vol,
         object_id,
         shrinkage_factor_override,
         pressure_factor_override,
         meter_factor_override,
         daytime,
         Grs_Opening_Vol,
         gravity_factor_override,
         temp_factor_override,
         vcf,Event_Type
  FROM strm_event
  WHERE object_id = cp_object_id
  AND daytime = cp_fromday;

  CURSOR c_last_strm_event(cp_object_id VARCHAR2, cp_daytime DATE) IS
  SELECT grs_vol,
         tank_object_id,
         manual_adj_vol,
         Grs_Closing_Vol,
         object_id,
         shrinkage_factor_override,
         pressure_factor_override,
         meter_factor_override,
         daytime,
         Grs_Opening_Vol,
         gravity_factor_override,
         temp_factor_override,
         vcf,Event_Type
  FROM strm_event s1
  WHERE object_id = cp_object_id
  AND   daytime = (
                  SELECT MAX(daytime) FROM strm_event s2
                  WHERE s1.object_id = s2.object_id
                  AND   s2.daytime < cp_daytime);

  CURSOR c_strm_reference(cp_object_id VARCHAR2, cp_fromday DATE) IS
  SELECT TOTALIZER_MAX_COUNT,
          CONVERSION_FACTOR,
          METER_FACTOR,
          PRESSURE_FACTOR,
          SHRINKAGE_FACTOR,
          TEMP_FACTOR,
          SPEC_GRAV
  FROM strm_reference_value
  WHERE object_id = cp_object_id
  AND daytime =
    (SELECT max(s2.daytime) FROM strm_reference_value s2
     WHERE s2.object_id = cp_object_id
     AND s2.daytime <= cp_fromday);

  CURSOR c2_curr_season(cp_object_id VARCHAR2, cp_day DATE) IS
    select MAX(trunc(a.valid_from, 'YYYY')) first_day
    from stream_seasonal_value a
    where a.object_id = cp_object_id
    and a.valid_from <= cp_day;

  CURSOR c2_all_seasons(cp_object_id VARCHAR2, cp_firstday DATE) IS
    select a.valid_from, a.seasonal_factor
    from stream_seasonal_value a
    where a.object_id = cp_object_id
    and a.valid_from between cp_firstday
    and to_date('31-12' || to_char(cp_firstday, 'YYYY'), 'DD-MM-YYYY')
    order by a.valid_from asc;

BEGIN

  -- In case we in the future want to do something special about production day
  ld_fromday := p_fromday;
  ld_today := p_today;

  lv2_stream_object_id := p_object_id;

  lr_strm_version_rec := ec_strm_version.row_by_rel_operator(p_object_id, ld_fromday, '<=');

  -- Find this streams strm_meter_freq
  lv2_strm_meter_freq := NVL(lr_strm_version_rec.strm_meter_freq,'');

  -- Find this streams aggregate_flag
  lv2_aggregate_flag := NVL(lr_strm_version_rec.aggregate_flag,'NA');

  -- Find this streams meter method
  lv2_strm_meter_method := NVL(lr_strm_version_rec.strm_meter_method,'');

  -- Determine which method to use
  lv2_method := NVL(p_method,lr_strm_version_rec.grs_vol_method);


  IF (lv2_method = EcDp_Calc_Method.MEASURED) THEN

    IF lv2_strm_meter_freq = 'DAY' OR lv2_aggregate_flag = 'Y' THEN

      ln_return_val := Ec_Strm_day_stream.math_grs_vol(
                                       p_object_id,
                                       ld_fromday,
                                       ld_today);     -- Underlying function uses Oracle BETWEEN

    ELSIF lv2_strm_meter_freq = 'MTH' THEN

      ln_return_val := Ec_Strm_mth_stream.math_grs_vol(
                                       p_object_id,
                                       ld_fromday,
                                       ld_today);    -- Underlying function uses Oracle BETWEEN



    ELSIF lv2_strm_meter_method = 'EVENT' THEN

      ln_return_val := 0;
      IF ld_today IS NULL THEN

        FOR curEvent IN c_strm_event_single(lv2_stream_object_id, ld_fromday) LOOP

          ln_return_val :=  curEvent.grs_vol; -- this is the Volume Override in the BF

        END LOOP;

      ELSE
        lb_first_iteration:= TRUE;

        FOR curEvent IN c_strm_event(lv2_stream_object_id, ld_fromday, ld_today) LOOP

          IF lb_first_iteration THEN
            lb_first_iteration := FALSE;
            ln_return_val :=  curEvent.grs_vol; -- this is the Volume Override in the BF

          ELSE

            ln_return_val :=  ln_return_val + curEvent.grs_vol; -- this is the Volume Override in the BF
          END IF;

        END LOOP;

      END IF;

    END IF;

  ELSIF (lv2_method = EcDp_Calc_Method.TANK_DUAL_DIP) THEN
    ln_return_val := 0;

    -- test if it is a single record or sum over production days to be returned
    IF ld_today IS NULL THEN

      -- Loop over single stream_event record.
      FOR curEvent IN c_strm_event_single(lv2_stream_object_id, ld_fromday) LOOP

        ln_grs_vol := EcBp_Tank.findGrsStdOilVol(curEvent.tank_object_id,'DUAL_DIP_OPENING',curEvent.daytime) -
                      EcBp_Tank.findGrsStdOilVol(curEvent.tank_object_id,'DUAL_DIP_CLOSING',curEvent.daytime);

        ln_return_val :=  ln_grs_vol + Nvl(curEvent.manual_adj_vol,0); -- add adjustment volume, but the default is null

      END LOOP;

    ELSE
      lb_first_iteration:= TRUE;

      FOR curEvent IN c_strm_event(lv2_stream_object_id, ld_fromday, ld_today) LOOP

        ln_grs_vol := EcBp_Tank.findGrsStdOilVol(curEvent.tank_object_id,'DUAL_DIP_OPENING',curEvent.daytime) -
                      EcBp_Tank.findGrsStdOilVol(curEvent.tank_object_id,'DUAL_DIP_CLOSING',curEvent.daytime);

        IF lb_first_iteration THEN
          lb_first_iteration := FALSE;
          ln_return_val := ln_grs_vol + Nvl(curEvent.manual_adj_vol,0); -- add adjustment volume, but the default is null
        ELSE
          ln_return_val := ln_return_val + ln_grs_vol + Nvl(curEvent.manual_adj_vol,0); -- add adjustment volume, but the default is null
        END IF;

      END LOOP;

    END IF;

  -- AGA: refer PO.0026 for algorithm
  ELSIF (lv2_method = Ecdp_Calc_Method.AGA) THEN

    ln_return_val := 0;

    IF lv2_strm_meter_method = 'PERIOD' THEN

      lb_first_iteration:= TRUE;

      FOR mycur IN c_daytime LOOP

        -- Interpretation of production day start
        ld_prod_day_start := EcDp_ProductionDay.getProductionDayStart('STREAM',p_object_id, ld_fromday);
        ln_grs_vol := nvl(calcDailyGrsStdVolFromEvents(p_object_id, 'PERIOD_GAS_STREAM_DATA_AGA', ld_prod_day_start),0);

        IF lb_first_iteration THEN

          lb_first_iteration := FALSE;
          ln_return_val := ln_grs_vol;

        ELSE

          ln_return_val := ln_return_val + ln_grs_vol;

        END IF;

      END LOOP;
    END IF;

  ELSIF (lv2_method = EcDp_Calc_Method.FORMULA) THEN
    ln_return_val := 0;
    IF lv2_strm_meter_freq = 'MTH' THEN
       ln_return_val := EcDp_Stream_Formula.getGrsStdVol(
                                                      p_object_id,
                                                      ld_fromday,
                                                      ld_today);
    ELSE
    IF ld_today IS NOT NULL AND ld_today > ld_fromday THEN
      ln_cur_date := ld_fromday;

      WHILE ln_cur_date <= ld_today LOOP
        ln_return_val := ln_return_val + EcDp_Stream_Formula.getGrsStdVol(
                                                      p_object_id,
                                                      ln_cur_date,
                                                      NULL);
        ln_cur_date := ln_cur_date + 1;
      END LOOP;

    ELSE
      ln_return_val := EcDp_Stream_Formula.getGrsStdVol(
                                                      p_object_id,
                                                      ld_fromday,
                                                      ld_today);
    END IF;
  END IF;

  ELSIF (lv2_method = EcDp_Calc_Method.MASS_DENSITY) THEN

    lb_first_iteration:= TRUE;

    lv_grs_method := Nvl(p_method,lr_strm_version_rec.grs_mass_method);

    IF (lv_grs_method = EcDp_Calc_Method.VOLUME_DENSITY) THEN
      RAISE_APPLICATION_ERROR(-20000,'A loop was detected when trying to calculate Gross Std Volume. Check Configuration.');
    END IF;

    IF lv2_strm_meter_freq = 'MTH' THEN
      -- monthly loop
      FOR mycur IN c_system_month(ld_fromday,ld_today) LOOP
        ln_grs_mass := EcBp_Stream_Fluid.findGrsStdMass(p_object_id,mycur.daytime,LAST_DAY(mycur.daytime));
        -- only access density if grs mass <> 0, else we dont use density.
        IF ln_grs_mass <> 0 THEN
          ln_density := EcBp_Stream_Fluid.findStdDens(p_object_id,mycur.daytime);
        END IF;
        IF lb_first_iteration THEN
          lb_first_iteration := FALSE;
          IF ln_grs_mass = 0 THEN
            ln_return_val := 0;
          ELSIF ln_density > 0 THEN
            ln_return_val := ln_grs_mass / ln_density;
          ELSE
            ln_return_val := NULL;
          END IF;
        ELSE
          IF ln_grs_mass = 0 THEN
            ln_grs_mass := ln_return_val + 0; -- yes, dont add anything if mass is zero, the volume is also zero.
          ELSIF ln_density > 0 THEN
            ln_return_val := ln_return_val + (ln_grs_mass / ln_density);
          ELSE -- negative, zero or NULL density should give NULL
            ln_return_val := NULL;
          END IF;
        END IF;
      END LOOP;

    ELSE
      -- daily loop
      FOR mycur IN c_daytime LOOP
        ln_grs_mass := EcBp_Stream_Fluid.findGrsStdMass(p_object_id,mycur.daytime,mycur.daytime);
        -- only access density if grs mass <> 0, else we dont use density.
        IF ln_grs_mass <> 0 THEN
          ln_density := EcBp_Stream_Fluid.findStdDens(p_object_id,mycur.daytime);
        END IF;
        IF lb_first_iteration THEN
          lb_first_iteration := FALSE;
          IF ln_grs_mass = 0 THEN
            ln_return_val := 0;
          ELSIF ln_density > 0 THEN
            ln_return_val := ln_grs_mass / ln_density;
          ELSE
            ln_return_val := NULL;
          END IF;
        ELSE
          IF ln_grs_mass = 0 THEN
            ln_return_val := ln_return_val + 0; -- yes, dont add anything if mass is zero, the volume is also zero.
          ELSIF ln_density > 0 THEN
            ln_return_val := ln_return_val + (ln_grs_mass / ln_density);
          ELSE
            ln_return_val := NULL; -- negative, zero or NULL density should give NULL
          END IF;
        END IF;
      END LOOP;

    END IF;

  ELSIF (lv2_method = EcDp_Calc_Method.NET_VOL) THEN

    IF InStr(p_resolve_loop,'findGrsStdVol')>0 THEN
      RAISE_APPLICATION_ERROR(-20000,'A loop was detected when trying to calculate a stream''s Gross Std Volume. Possibly due to a mis-configuration of stream attributes.');
    ELSE  -- Call the next function with the argument to this function, or this function name if no argument
      lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findGrsStdVol,';
    END IF;

    ln_return_val := EcBp_Stream_Fluid.findNetStdVol(
                                                     p_object_id,
                                                     ld_fromday,
                                                     ld_today,
                                                     NULL,
                                                     lv2_resolve_loop);

  ELSIF (lv2_method = EcDp_Calc_Method.NA) THEN

    ln_return_val := NULL;

  ELSIF (lv2_method = EcDp_Calc_Method.RUNTIME_RATE) THEN

    lb_first_iteration:= TRUE;

    FOR mycur2 IN c_daytime LOOP

      ln_vol_rate := ec_strm_reference_value.hr_vol_rate(lv2_stream_object_id,mycur2.daytime,'<=');
      ln_runtime_hrs := EcBp_Stream_Fluid.findOnStreamHours(p_object_id,mycur2.daytime);

      IF lb_first_iteration THEN

        lb_first_iteration := FALSE;
        ln_return_val := ln_vol_rate * ln_runtime_hrs;

      ELSE

        ln_return_val := ln_return_val + ln_vol_rate * ln_runtime_hrs;

      END IF;

    END LOOP;

  ELSIF (lv2_method = EcDp_Calc_Method.TOTALIZER_EVENT) THEN

    IF ld_today IS NULL THEN -- indicates we are looking for single event value

      FOR cur_strm_event IN c_strm_event_single(lv2_stream_object_id, ld_fromday) LOOP

        ln_totalizer_close := cur_strm_event.Grs_Closing_Vol;
        -- only access previous closing if needed
        ln_totalizer_open_overwrite := cur_strm_event.Grs_Opening_Vol;
        IF ln_totalizer_open_overwrite IS NULL THEN
          IF ec_strm_reference_value.volume_entry_flag(cur_strm_event.object_id, cur_strm_event.daytime, '<=') = 'Y' THEN
            ln_totalizer_open := 0;
          ELSE
            ln_totalizer_open  := ec_strm_event.grs_closing_vol(cur_strm_event.object_id,cur_strm_event.Event_Type,cur_strm_event.daytime,'<');
          END IF;
        END IF;
        ln_override_grs_vol :=cur_strm_event.grs_vol;
        FOR cur_strm_reference IN c_strm_reference(lv2_stream_object_id, ld_fromday) LOOP
          ln_rollover_val := cur_strm_reference.totalizer_max_count;
          ln_conversion_factor := cur_strm_reference.conversion_factor;
          ln_meter_factor := cur_strm_reference.meter_factor;
          ln_pressure_factor := cur_strm_reference.pressure_factor;
          ln_shrinkage_factor := cur_strm_reference.shrinkage_factor;
          ln_temp_factor := cur_strm_reference.temp_factor;
          ln_gravity_factor := cur_strm_reference.spec_grav;
        END LOOP;

        ln_pressure_factor_override := cur_strm_event.pressure_factor_override;
        ln_meter_factor_override := cur_strm_event.meter_factor_override;
        ln_shrinkage_factor_override := cur_strm_event.shrinkage_factor_override;
        ln_gravity_factor_override := cur_strm_event.gravity_factor_override;
        ln_temp_factor_override := cur_strm_event.temp_factor_override;
        ln_manual_adj := cur_strm_event.Manual_Adj_Vol;
        ln_vcf        := cur_strm_event.vcf;

        IF ln_totalizer_close < nvl(ln_totalizer_open_overwrite, ln_totalizer_open) THEN
          ln_grs_vol :=
                       ((nvl(ln_override_grs_vol,(ln_totalizer_close - nvl(ln_totalizer_open_overwrite, ln_totalizer_open)+ nvl(ln_rollover_val, 0))))
                       * nvl(ln_conversion_factor, 1)
                       * nvl(ln_meter_factor_override, nvl(ln_meter_factor,1))
                       * nvl(ln_pressure_factor_override, nvl(ln_pressure_factor,1))
                       * nvl(ln_shrinkage_factor_override, nvl(ln_shrinkage_factor,1))
                       * nvl(ln_gravity_factor_override, nvl(ln_gravity_factor,1))
                       * nvl(ln_temp_factor_override, nvl(ln_temp_factor,1))
                       * nvl(ln_vcf, 1))
                       + nvl(ln_manual_adj, 0);

        ELSE
          ln_grs_vol :=
                       (nvl(ln_override_grs_vol,(ln_totalizer_close - nvl(ln_totalizer_open_overwrite, ln_totalizer_open)))
                       * nvl(ln_conversion_factor, 1)
                       * nvl(ln_meter_factor_override, nvl(ln_meter_factor,1))
                       * nvl(ln_pressure_factor_override, nvl(ln_pressure_factor,1))
                       * nvl(ln_shrinkage_factor_override, nvl(ln_shrinkage_factor,1))
                       * nvl(ln_gravity_factor_override, nvl(ln_gravity_factor,1))
                       * nvl(ln_temp_factor_override, nvl(ln_temp_factor,1))
                       * nvl(ln_vcf, 1))
                       + nvl(ln_manual_adj, 0);

        END IF;
      END LOOP;

    ELSE -- looking for sum of event values

      ln_total_grs_vol := 0;
      FOR cur_strm_event IN c_strm_event(lv2_stream_object_id, ld_fromday, ld_today) LOOP

        ln_totalizer_close := cur_strm_event.Grs_Closing_Vol;
        ln_totalizer_open_overwrite := cur_strm_event.Grs_Opening_Vol;
        IF ln_totalizer_open_overwrite IS NULL THEN
          IF ec_strm_reference_value.volume_entry_flag(cur_strm_event.object_id, cur_strm_event.daytime, '<=') = 'Y' THEN
            ln_totalizer_open := 0;
          ELSE
            ln_totalizer_open  := ec_strm_event.grs_closing_vol(cur_strm_event.object_id,cur_strm_event.Event_Type,cur_strm_event.daytime,'<');
          END IF;
        END IF;
        ln_override_grs_vol :=cur_strm_event.grs_vol;
        FOR cur_strm_reference IN c_strm_reference(lv2_stream_object_id, ld_fromday) LOOP
          ln_rollover_val := cur_strm_reference.totalizer_max_count;
          ln_conversion_factor := cur_strm_reference.conversion_factor;
          ln_meter_factor := cur_strm_reference.meter_factor;
          ln_pressure_factor := cur_strm_reference.pressure_factor;
          ln_shrinkage_factor := cur_strm_reference.shrinkage_factor;
          ln_temp_factor := cur_strm_reference.temp_factor;
          ln_gravity_factor := cur_strm_reference.spec_grav;
        END LOOP;
        ln_shrinkage_factor_override := cur_strm_event.shrinkage_factor_override;ln_temp_factor := ec_strm_reference_value.temp_factor(cur_strm_event.object_id,cur_strm_event.daytime,'<=');
        ln_pressure_factor_override := cur_strm_event.pressure_factor_override;
        ln_meter_factor_override := cur_strm_event.meter_factor_override;
        ln_gravity_factor_override := cur_strm_event.gravity_factor_override;
        ln_temp_factor_override := cur_strm_event.temp_factor_override;
        ln_manual_adj := cur_strm_event.Manual_Adj_Vol;
        ln_vcf        := cur_strm_event.vcf;

        IF ln_totalizer_close < nvl(ln_totalizer_open_overwrite, ln_totalizer_open) THEN
          ln_grs_vol :=
                     ((nvl(ln_override_grs_vol,(ln_totalizer_close - nvl(ln_totalizer_open_overwrite, ln_totalizer_open)+ nvl(ln_rollover_val, 0))))
                     * nvl(ln_conversion_factor, 1)
                     * nvl(ln_meter_factor_override, nvl(ln_meter_factor,1))
                     * nvl(ln_pressure_factor_override, nvl(ln_pressure_factor,1))
                     * nvl(ln_shrinkage_factor_override, nvl(ln_shrinkage_factor,1))
                     * nvl(ln_gravity_factor_override, nvl(ln_gravity_factor,1))
                     * nvl(ln_temp_factor_override, nvl(ln_temp_factor,1))
                     * nvl(ln_vcf, 1))
                     + nvl(ln_manual_adj, 0);
        ELSE
          ln_grs_vol :=
                       (nvl(ln_override_grs_vol,(ln_totalizer_close - nvl(ln_totalizer_open_overwrite, ln_totalizer_open)))
                       * nvl(ln_conversion_factor, 1)
                       * nvl(ln_meter_factor_override, nvl(ln_meter_factor,1))
                       * nvl(ln_pressure_factor_override, nvl(ln_pressure_factor,1))
                       * nvl(ln_gravity_factor_override, nvl(ln_gravity_factor,1))
                       * nvl(ln_temp_factor_override, nvl(ln_temp_factor,1))
                       * nvl(ln_shrinkage_factor_override, nvl(ln_shrinkage_factor,1))
                       * nvl(ln_vcf, 1))
                       + nvl(ln_manual_adj, 0);

        END IF;

        ln_total_grs_vol := ln_total_grs_vol + NVL(ln_grs_vol,0);

      END LOOP;
      ln_grs_vol := ln_total_grs_vol;

    END IF;
    ln_return_val := ln_grs_vol;

  ELSIF (lv2_method = EcDp_Calc_Method.NET_VOL_WATER) THEN

    ln_return_val := EcBp_Stream_Fluid.findNetStdVol(
                                                     p_object_id,
                                                     ld_fromday,
                                                     ld_today)
                           +
                           EcBp_Stream_Fluid.findWatVol (
                                                        p_object_id,
                                                        ld_fromday,
                                                        ld_today);

   ELSIF  (lv2_method = EcDp_Calc_Method.MEASURED_TRUCKED) THEN
    ln_return_val := 0;
    IF ld_today IS NULL THEN -- indicates we are looking for single event value
      ln_return_val := NULL;  -- this is not possible, use EcBp_Truck_Ticket.findGrsStdVol() instead but it cannot be called from here.
    ELSE -- looking for sum of event values over a given period
      lb_first_iteration:= TRUE;
      FOR curEvent2 IN c_strm_transport_event (lv2_stream_object_id, ld_fromday, ld_today) LOOP
        IF lb_first_iteration THEN
          lb_first_iteration := FALSE;
          ln_return_val :=  EcBp_Truck_Ticket.findGrsStdVol(curEvent2.event_no);
        ELSE
          ln_return_val :=  ln_return_val + EcBp_Truck_Ticket.findGrsStdVol(curEvent2.event_no);
        END IF;
      END LOOP;
    END IF;


  ELSIF (lv2_method = EcDp_Calc_Method.ENERGY_GCV) THEN
    ln_return_val := 0;
    IF lv2_strm_meter_freq = 'MTH' THEN
      ln_energy := EcBp_Stream_Fluid.findEnergy(p_object_id, p_fromday, p_today);
      ln_gcv := EcBp_Stream_Fluid.findGCV(p_object_id, p_fromday);

      IF ln_energy = 0 THEN
        ln_return_val := 0;
      ELSIF ln_energy <> 0 THEN
        IF (ln_gcv = 0 OR ln_gcv IS NULL) THEN
          ln_return_val := NULL;
        ELSE
          ln_return_val := ln_energy/ln_gcv;
        END IF;
      END IF;

    ELSE
      FOR mycur IN c_daytime LOOP
        ln_energy := ecbp_stream_fluid.findEnergy(p_object_id, mycur.daytime, mycur.daytime);
        ln_gcv := ecbp_stream_fluid.findGCV(p_object_id, mycur.daytime);

        IF ln_energy = 0  THEN
          ln_return_val := 0;
        ELSIF ln_energy <> 0 THEN
          IF (ln_gcv = 0 OR ln_gcv IS NULL) THEN
            ln_return_val := NULL;
          ELSE
            ln_return_val := ln_return_val + (ln_energy/ln_gcv);
          END IF;
        END IF;
      END LOOP;
    END IF;

  ELSIF (lv2_method = EcDp_Calc_Method.TOTALIZER_DAY) THEN

    IF lv2_strm_meter_freq = 'DAY' THEN
      lr_strm_reference_value := ec_strm_reference_value.row_by_pk(lv2_stream_object_id, ld_fromday, '<=');

      ln_meter_factor := lr_strm_reference_value.meter_factor;
      ln_pressure_factor := lr_strm_reference_value.pressure_factor;
      ln_shrinkage_factor := lr_strm_reference_value.shrinkage_factor;
      ln_conversion_factor := lr_strm_reference_value.conversion_factor;
      ln_rollover_val := lr_strm_reference_value.totalizer_max_count;

      lr_strm_day_stream := ec_strm_day_stream.row_by_pk(lv2_stream_object_id, ld_fromday, '=');

      ln_meter_factor_override := lr_strm_day_stream.meter_factor_override;
      ln_pressure_factor_override := lr_strm_day_stream.press_factor_override;
      ln_shrinkage_factor_override := lr_strm_day_stream.shrinkage_factor_override;

      ln_closing_read := lr_strm_day_stream.totalizer;
      ln_opening_override := lr_strm_day_stream.totalizer_vol_override;

      IF ln_opening_override IS NULL THEN
         ln_opening_read := ec_strm_day_stream.totalizer(p_object_id,p_fromday-1);
      END IF;

      IF ln_closing_read < nvl(ln_opening_override,ln_opening_read) THEN
         ln_grs_vol := (ln_closing_read - NVL(ln_opening_override, ln_opening_read) + nvl(ln_rollover_val, 0))
                       * nvl(ln_conversion_factor,1)
                       * nvl(ln_meter_factor_override, nvl(ln_meter_factor,1))
                       * nvl(ln_pressure_factor_override, nvl(ln_pressure_factor,1))
                       * nvl(ln_shrinkage_factor_override, nvl(ln_shrinkage_factor,1));

      ELSE
         ln_grs_vol := (ln_closing_read - NVL(ln_opening_override, ln_opening_read))
                       * nvl(ln_conversion_factor,1)
                       * nvl(ln_meter_factor_override, nvl(ln_meter_factor,1))
                       * nvl(ln_pressure_factor_override, nvl(ln_pressure_factor,1))
                       * nvl(ln_shrinkage_factor_override, nvl(ln_shrinkage_factor,1));

      END IF;

      ln_return_val := ln_grs_vol;

    END IF;

    ELSIF (lv2_method = EcDp_Calc_Method.TOTALIZER_EVENT_RAW) THEN

       IF ld_today IS NULL THEN  --indicates we are looking for single event value

          FOR cur_strm_event IN c_strm_event_single(lv2_stream_object_id, ld_fromday) LOOP

             ln_totalizer_close := cur_strm_event.Grs_Closing_Vol;
             --only access previous closing if needed
             ln_totalizer_open_overwrite := cur_strm_event.Grs_Opening_Vol;

             IF ln_totalizer_open_overwrite IS NULL THEN
                IF ec_strm_reference_value.volume_entry_flag(cur_strm_event.object_id, cur_strm_event.daytime, '<=') = 'Y' THEN
                   ln_totalizer_open := 0;
                ELSE
                   ln_totalizer_open := ec_strm_event.grs_closing_vol(cur_strm_event.object_id,cur_strm_event.Event_Type,cur_strm_event.daytime,'<');
                END IF;
             END IF;
                   ln_override_grs_vol :=cur_strm_event.grs_vol;

             FOR cur_strm_reference IN c_strm_reference(lv2_stream_object_id, ld_fromday) LOOP
                 ln_rollover_val := cur_strm_reference.totalizer_max_count;
             END LOOP;

                ln_manual_adj := cur_strm_event.Manual_Adj_Vol;

                IF ln_totalizer_close < nvl(ln_totalizer_open_overwrite, ln_totalizer_open) THEN
                   ln_grs_vol :=(ln_totalizer_close - nvl(ln_totalizer_open_overwrite, ln_totalizer_open)) + nvl(ln_rollover_val, 0)+ nvl(ln_manual_adj, 0);
                ELSE
                   ln_grs_vol :=nvl(ln_override_grs_vol,(ln_totalizer_close - nvl(ln_totalizer_open_overwrite, ln_totalizer_open)))+ nvl(ln_manual_adj, 0);
                END IF;

          END LOOP;

   ELSE -- looking for sum of event values

         ln_total_grs_vol := 0;
         FOR cur_strm_event IN c_strm_event(lv2_stream_object_id, ld_fromday, ld_today) LOOP
            ln_totalizer_close := cur_strm_event.Grs_Closing_Vol;
            ln_totalizer_open_overwrite := cur_strm_event.Grs_Opening_Vol;

          IF ln_totalizer_open_overwrite IS NULL THEN
             IF ec_strm_reference_value.volume_entry_flag(cur_strm_event.object_id, cur_strm_event.daytime, '<=') = 'Y' THEN
                ln_totalizer_open := 0;
             ELSE
                ln_totalizer_open := ec_strm_event.grs_closing_vol(cur_strm_event.object_id,cur_strm_event.Event_Type,cur_strm_event.daytime,'<');
             END IF;
          END IF;
             ln_override_grs_vol :=cur_strm_event.grs_vol;

          FOR cur_strm_reference IN c_strm_reference(lv2_stream_object_id, ld_fromday) LOOP
             ln_rollover_val := cur_strm_reference.totalizer_max_count;
          END LOOP;

          IF ln_totalizer_close < nvl(ln_totalizer_open_overwrite, ln_totalizer_open) THEN
             ln_grs_vol :=(ln_totalizer_close - nvl(ln_totalizer_open_overwrite, ln_totalizer_open)) + nvl(ln_rollover_val, 0);
          ELSE
             ln_grs_vol :=nvl(ln_override_grs_vol,(ln_totalizer_close - nvl(ln_totalizer_open_overwrite, ln_totalizer_open)));
          END IF;
             ln_total_grs_vol := ln_total_grs_vol + NVL(ln_grs_vol,0);

        END LOOP;
        ln_grs_vol := ln_total_grs_vol;
  END IF;
      ln_return_val := ln_grs_vol;

  ELSIF (lv2_method = 'API_BLEND_SHRINKAGE') THEN

	 FOR mycur IN c_daytime LOOP
		 ln_net_vol:= EcBp_Stream_Fluid.findNetStdVol(p_object_id, mycur.daytime, mycur.daytime, NULL, p_resolve_loop);
		 IF ln_net_vol > 0 THEN -- only find blend volume when bitumen volume > 0
			ln_return_val := 0;
			ln_return_val := ln_return_val
							+ ((ln_net_vol/(1-EcBp_VCF.calcDiluentConcentration(p_object_id, mycur.daytime)))
							- EcBp_Stream_Fluid.calcShrunkVol(p_object_id, mycur.daytime));
		 ELSIF ln_net_vol = 0 THEN
			ln_return_val := 0;
		 END IF;
	 END LOOP;

  ELSIF (lv2_method = EcDp_Calc_Method.SEASONAL_VALUE) THEN
    ld_date := Nvl(p_today,p_fromday);

	lv2_seasonal_stream_objid := NVL(lr_strm_version_rec.ref_seasonal_stream_id, p_object_id);

    FOR curCurrent_Season IN c2_curr_season(lv2_seasonal_stream_objid, ld_date) LOOP
      ld_curr_season_year := curCurrent_Season.first_day;
    END LOOP;

    IF ld_curr_season_year IS NOT NULL THEN
      OPEN c2_all_seasons(lv2_seasonal_stream_objid, ld_curr_season_year);
      FETCH c2_all_seasons BULK COLLECT INTO typ_strm_seasonal_val;
      CLOSE c2_all_seasons;

      FOR c IN typ_strm_seasonal_val.FIRST .. typ_strm_seasonal_val.LAST  -- Prepare the control values
      LOOP
        IF c = 1 THEN
          ld_first_valid_from := typ_strm_seasonal_val(c).valid_from;
          ln_First_year := to_char(ld_first_valid_from, 'YYYY');
        END IF;
        ln_last_factor := typ_strm_seasonal_val(c).seasonal_factor;
      END LOOP;

      FOR i IN typ_strm_seasonal_val.FIRST .. typ_strm_seasonal_val.LAST
      LOOP
        IF ld_date >= typ_strm_seasonal_val(i).valid_from THEN
          IF trunc(ld_date, 'YYYY') > trunc(ld_first_valid_from, 'YYYY') THEN -- Next year, check before assign value
            IF ( to_char(ld_date, 'DD')= '29' and to_char(ld_date, 'MM')='02' and (NOT ((mod(ln_First_year,4) = 0 and mod(ln_First_year,100) != 0) or mod(ln_First_year,400)=0 ))) THEN
                 ld_date:= ld_date-1;
             END IF; --If passed date is 29-Feb and last seasonal value year is not a leap year

            IF to_date( (to_char(ld_date, 'DD') || '-' || to_char(ld_date, 'MM') || '-' || ln_First_year), 'DD-MM-YYYY' ) < ld_first_valid_from THEN
              ln_return_val := ln_last_factor;
              EXIT;
            ELSIF to_date( (to_char(ld_date, 'DD') || '-' || to_char(ld_date, 'MM') || '-' || ln_First_year), 'DD-MM-YYYY' ) >= typ_strm_seasonal_val(i).valid_from THEN
              ln_return_val := typ_strm_seasonal_val(i).seasonal_factor;
            END IF;
          ELSE -- current year, must assign value
            ln_return_val := typ_strm_seasonal_val(i).seasonal_factor;
          END IF;
        END IF;
      END LOOP;
      RETURN ln_return_val;
    ELSE
      RETURN NULL;
    END IF;

  -- User Exit
  ELSIF (substr(lv2_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN

    ln_return_val := ue_stream_fluid.getGrsStdVol(p_object_id, p_fromday,p_today);

  ELSE -- undefined

    ln_return_val := NULL;

  END IF;

  RETURN ln_return_val;

END findGrsStdVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findNetStdMass
-- Description    : Returns the net standard mass in kg for given stream
--                  and period.
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions: EC_STRM_VERSION....
--                  EC_STRM_DAY_ALLOC.MATH_NET_MASS
--                  ECDP_STREAM_MEASURED.GETNETSTDMASS
--                  ECBP_STREAM_FLUID.FINDGRSSTDMASS
--                  ECBP_STREAM_FLUID.FINDNETSTDVOL
--                  ECBP_STREAM_FLUID.FINDSTDDENS
--        ECBP_STREAM_FLUID.FINDWDF
--
-- Configuration
-- required       :
--
-- Behaviour      : Alternative STRM_VERSION.... (NET_MASS_METHOD):
--
--                1. 'MEASURED': Find net_mass using data from strm_day_stream only.
--                2. 'ALLOCATED': Get data from strm_day_alloc
--                3. 'GRS_MASS'
--                4. 'VOLUME_DENSITY'
--                5. 'GROSS_BSW' : Calculate net mass based on gross mass and BSW weight frac
--                6. 'FORMULA'
--                7. 'TANK_DUAL_DIP'
--                8. 'GRS_MASS_WDF'
--                9. 'GRS_MASS_MINUS_WATER'
--               10. 'USER_EXIT'
--               11. 'TOTALIZER_DAY'
---------------------------------------------------------------------------------------------------
FUNCTION findNetStdMass (
     p_object_id    stream.object_id%TYPE,
     p_fromday      DATE,
     p_today        DATE     DEFAULT NULL,
     p_method       VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

  lv2_method            VARCHAR2(30);
  lv2_grs_method        VARCHAR2(32);
  ln_bsw_wt             NUMBER;
  ln_grs_mass           NUMBER;
  ln_net_mass           NUMBER;
  ln_return_val         NUMBER;
  ln_netstdmass         NUMBER;
  lv2_stream_object_id  stream.object_id%TYPE;
  ld_fromday            DATE;
  ld_today              DATE;
  lv2_strm_meter_freq   VARCHAR2(300);
  lv2_strm_meter_method VARCHAR2(300);
  lv2_aggregate_flag    VARCHAR2(2);
  lv2_records_found     VARCHAR2(1);
  lb_first_iteration    BOOLEAN;
  ln_wdf                NUMBER;
  lv2_tank_object_id    tank.object_id%TYPE;
  ln_wat_mass           NUMBER;
  ln_salt_wt            NUMBER;
  ln_grs_vol            NUMBER;
  ln_bsw_vol_frac       NUMBER;
  ln_std_dens           NUMBER;
  ln_net_std_vol        NUMBER;
  ln_cur_date			DATE;
  ln_mass 				NUMBER;
  ln_density 			NUMBER;

  CURSOR c_daytime IS
  SELECT daytime
  FROM system_days
  WHERE daytime BETWEEN p_fromday AND Nvl(p_today,p_fromday);

  CURSOR c_strm_event(cp_object_id VARCHAR2, cp_fromday DATE, cp_today DATE) IS
  SELECT *
  FROM strm_event
  WHERE object_id = cp_object_id
  AND   Nvl(event_day,TRUNC(daytime)) BETWEEN cp_fromday AND cp_today
  ORDER BY daytime ASC;

  CURSOR c_strm_event_single(cp_object_id VARCHAR2, cp_fromday DATE) IS
  SELECT *
  FROM strm_event
  WHERE object_id = cp_object_id
  AND daytime = cp_fromday;


BEGIN

  -- For future production day handeling
  ld_fromday := p_fromday;
  ld_today := p_today;

  lv2_stream_object_id := p_object_id;

  -- Find this streams strm_meter_freq
  lv2_strm_meter_freq := NVL(ec_strm_version.STRM_METER_FREQ(p_object_id, ld_fromday, '<='),'');

  -- Find this streams aggregate_flag
  lv2_aggregate_flag := NVL(ec_strm_version.aggregate_flag(p_object_id, ld_fromday, '<='),'NA');

  -- Find this streams meter method
  lv2_strm_meter_method := NVL(ec_strm_version.strm_meter_method(p_object_id, ld_fromday, '<='),'');

  -- Determine which method to use
  lv2_method := Nvl(p_method,
        ec_strm_version.NET_MASS_METHOD(
        p_object_id,
        ld_fromday,
        '<='));

  -- Find net_mass using data from strm_day_stream only.
  IF (lv2_method = EcDp_Calc_Method.MEASURED) THEN

    IF lv2_strm_meter_freq = 'DAY' OR lv2_aggregate_flag = 'Y' THEN

      ln_return_val := Ec_Strm_day_stream.math_net_mass(
                              p_object_id,
                              ld_fromday,
                              ld_today);    -- Underlying function uses Oracle BETWEEN

    ELSIF lv2_strm_meter_freq = 'MTH' THEN

      ln_return_val := Ec_Strm_mth_stream.math_net_mass(
                              p_object_id,
                              ld_fromday,
                              ld_today);    -- Underlying function uses Oracle BETWEEN

    ELSIF lv2_strm_meter_method = 'EVENT' THEN

      ln_return_val := 0;
      IF ld_today IS NULL THEN -- indicates asking for a single event

        FOR curEvent IN c_strm_event_single(lv2_stream_object_id, ld_fromday) LOOP

          ln_return_val :=  curEvent.net_mass;

        END LOOP;

      ELSE
        lb_first_iteration:= TRUE;

        FOR curEvent IN c_strm_event(lv2_stream_object_id, ld_fromday, ld_today) LOOP

          IF lb_first_iteration THEN

            lb_first_iteration:= FALSE;
            ln_return_val :=  curEvent.net_mass;

          ELSE

            ln_return_val :=  ln_return_val + curEvent.net_mass;

          END IF;

        END LOOP;

      END IF;

    END IF;


  -- Get data from strm_day_alloc
  ELSIF (lv2_method = EcDp_Calc_Method.ALLOCATED) THEN

    ln_return_val :=  ec_strm_day_alloc.math_net_mass(
                                                      p_object_id,
                                                      ld_fromday,
                                                      ld_today);

  -- formula
  ELSIF (lv2_method = EcDp_Calc_Method.FORMULA) THEN
  IF lv2_strm_meter_freq = 'MTH' THEN
       ln_return_val := EcDp_Stream_Formula.getNetStdMass(
                                                      p_object_id,
                                                      ld_fromday,
                                                      ld_today);
  ELSE
    IF ld_today IS NOT NULL AND ld_today > ld_fromday THEN
      ln_return_val := 0;
      ln_cur_date := ld_fromday;

      WHILE ln_cur_date <= ld_today LOOP
        ln_return_val := ln_return_val + EcDp_Stream_Formula.getNetStdMass(
                                                      p_object_id,
                                                      ln_cur_date,
                                                      NULL);
        ln_cur_date := ln_cur_date + 1;
      END LOOP;

    ELSE
      ln_return_val := EcDp_Stream_Formula.getNetStdMass(
                                                      p_object_id,
                                                      ld_fromday,
                                                      ld_today);
    END IF;
  END IF;

  ELSIF (lv2_method = EcDp_Calc_Method.GRS_MASS) THEN

    ln_return_val := EcBp_Stream_Fluid.findGrsStdMass(
                                                     p_object_id,
                                                     ld_fromday,
                                                     ld_today);


  ELSIF (lv2_method = EcDp_Calc_Method.VOLUME_DENSITY) THEN
    -- Event records
    IF lv2_strm_meter_method = 'EVENT' THEN
      -- ld_today is null if we ask for one record only
      IF ld_today IS NULL THEN
        -- try access stream_event
        FOR curEvent IN c_strm_event_single(lv2_stream_object_id, ld_fromday) LOOP
          ln_net_std_vol := EcBp_Stream_Fluid.findNetStdVol(curEvent.Object_id,curEvent.daytime);
          IF ln_net_std_vol = 0 THEN
            ln_return_val := 0;
          ELSE
            ln_return_val :=  ln_net_std_vol * EcBp_Stream_Fluid.findStdDens(curEvent.Object_id,curEvent.daytime);
          END IF;
        END LOOP;
      -- if ld_today is not null, then return sum of all records between fromday and today
      ELSE
        ln_return_val := 0;
        FOR curEvent IN c_strm_event(lv2_stream_object_id, ld_fromday, ld_today) LOOP
          ln_net_std_vol := EcBp_Stream_Fluid.findNetStdVol(curEvent.Object_id,curEvent.daytime);
          IF ln_net_std_vol > 0 THEN
            ln_return_val := ln_return_val + ln_net_std_vol * EcBp_Stream_Fluid.findStdDens(curEvent.Object_id,curEvent.daytime);
          END IF;
        END LOOP;
        IF ln_return_val = 0 THEN
          FOR curEvent IN c_strm_transport_event(lv2_stream_object_id, ld_fromday, ld_today) LOOP
            ln_net_std_vol := EcBp_truck_ticket.findNetStdVol(curEvent.Event_no);
            ln_density:= EcBp_Stream_Fluid.findStdDens(lv2_stream_object_id, curEvent.daytime);
            IF ln_net_std_vol > 0 THEN
              ln_mass :=  ln_net_std_vol * ln_density;
              ln_return_val := ln_return_val + ln_mass;
            END IF;
          END LOOP;
        END IF;
      END IF;
    -- Daily Records
    ELSE
      lb_first_iteration:= TRUE;
      IF lv2_strm_meter_freq = 'MTH' THEN

        ln_net_std_vol := EcBp_Stream_Fluid.findNetStdVol(p_object_id,p_fromday,p_today);
        IF ln_net_std_vol = 0 THEN
          ln_return_val := 0;
        ELSE
          ln_return_val := ln_net_std_vol * EcBp_Stream_Fluid.findStdDens(p_object_id,p_fromday);
        END IF;
      ELSE

    ln_return_val := 0;
        FOR mycur IN c_daytime LOOP

              IF lb_first_iteration THEN
                lb_first_iteration := FALSE;
              END IF;

              ln_net_std_vol := EcBp_Stream_Fluid.findNetStdVol(p_object_id,mycur.daytime,mycur.daytime);
              IF ln_net_std_vol = 0 THEN
        IF (ln_return_val IS NULL) THEN
          ln_return_val := ln_return_val;
        END IF;
              ELSE
                ln_return_val := ln_return_val + (ln_net_std_vol * EcBp_Stream_Fluid.findStdDens(p_object_id,mycur.daytime));
              END IF;

        END LOOP;
      END IF;
    END IF;


  -- Calculate based on grs_mass and BSW_wt
  ELSIF (lv2_method = EcDp_Calc_Method.GROSS_BSW) THEN

    IF lv2_strm_meter_method = 'EVENT' THEN
      lv2_grs_method := NVL(
                             p_method,
                             ec_strm_version.GRS_MASS_METHOD(
                                                            p_object_id,
                                                            p_fromday,
                                                            '<=')
                             );

      -- Find net_vol using event based gross volume and bsw from truck transport data
      IF(lv2_grs_method = EcDp_Calc_Method.MEASURED_TRUCKED) THEN
        ln_return_val := 0; -- Because no truck tickets one day should return 0 and not NULL!
        FOR curEvent2 IN c_strm_transport_event(lv2_stream_object_id, ld_fromday, ld_today) LOOP
          ln_net_mass :=  EcBp_truck_ticket.findNetStdMass(curEvent2.Event_No);
          ln_return_val := ln_return_val + ln_net_mass;
        END LOOP;
      END IF; -- END  IF(lv2_grs_method = EcDp_Calc_Method.MEASURED_TRUCKED)
    ELSE   -- not (lv2_strm_meter_method = 'EVENT')
      lb_first_iteration:= TRUE;
      IF lv2_strm_meter_freq = 'MTH' THEN
        ln_grs_mass := findGrsStdMass(p_object_id,p_fromday,p_today);
        IF ln_grs_mass = 0 THEN
          ln_return_val := 0;
        ELSE
          ln_return_val := ln_grs_mass * (1-getBSWWeightFrac(p_object_id,p_fromday));
        END IF;
      ELSE
        ln_return_val := 0;
        FOR mycur2 IN c_daytime LOOP
          ln_grs_mass := findGrsStdMass(p_object_id,mycur2.daytime,mycur2.daytime);
          IF ln_grs_mass = 0 THEN
            ln_netstdmass := 0;
          ELSE
            ln_netstdmass := ln_grs_mass * (1-getBSWWeightFrac(p_object_id,mycur2.daytime));
          END IF;
          IF lb_first_iteration THEN
            lb_first_iteration := FALSE;
            ln_return_val := ln_netstdmass;
          ELSE
            ln_return_val := ln_return_val + ln_netstdmass;
          END IF;
        END LOOP;
      END IF;
    END IF;

  -- Calculate based on grs_mass, BSW_wt and salt_wt
  ELSIF (lv2_method = EcDp_Calc_Method.GROSS_BSW_SALT) THEN

    lb_first_iteration:= TRUE;
     ln_return_val := 0;
    FOR mycur2 IN c_daytime LOOP

    ln_grs_mass := findGrsStdMass(p_object_id,mycur2.daytime,mycur2.daytime);
    IF ln_grs_mass = 0 THEN
     ln_netstdmass := 0;
    ELSE
     ln_netstdmass := ln_grs_mass * (1-getBSWWeightFrac(p_object_id,mycur2.daytime)-getSaltWeightFrac(p_object_id,mycur2.daytime));
    END IF;

      IF lb_first_iteration THEN

        lb_first_iteration := FALSE;
        ln_return_val := ln_netstdmass;

      ELSE

        ln_return_val := ln_return_val + ln_netstdmass;

      END IF;

    END LOOP;


  ELSIF (lv2_method = EcDp_Calc_Method.TANK_DUAL_DIP) THEN
    ln_return_val := 0;

    -- test if it is a single record or sum over production days to be returned
    IF ld_today IS NULL THEN

      -- Loop over single stream_event record.
      FOR curEvent IN c_strm_event_single(lv2_stream_object_id, ld_fromday) LOOP

        ln_net_mass := EcBp_Tank.findNetMass(curEvent.tank_object_id,'DUAL_DIP_OPENING',curEvent.daytime) -
                        EcBp_Tank.findNetMass(curEvent.tank_object_id,'DUAL_DIP_CLOSING',curEvent.daytime);

        ln_return_val :=  ln_net_mass + Nvl(curEvent.manual_adj_vol,0); -- add adjustment volume, but the default is null

      END LOOP;

    ELSE -- its sum over all records belonging to production days between ld_fromday and ld_today
      lb_first_iteration:= TRUE;

      FOR curEvent IN c_strm_event(lv2_stream_object_id, ld_fromday, ld_today) LOOP

        ln_net_mass := EcBp_Tank.findNetMass(curEvent.tank_object_id,'DUAL_DIP_OPENING',curEvent.daytime) -
                         EcBp_Tank.findNetMass(curEvent.tank_object_id,'DUAL_DIP_CLOSING',curEvent.daytime);

        IF lb_first_iteration THEN
          lb_first_iteration := FALSE;
          ln_return_val := ln_net_mass + Nvl(curEvent.manual_adj_vol,0); -- add adjustment volume, but the default is null
        ELSE
          ln_return_val := ln_return_val + ln_net_mass + Nvl(curEvent.manual_adj_vol,0); -- add adjustment volume, but the default is null
        END IF;

      END LOOP;

    END IF;


  -- Get dry gas from wet gas and WDF (Wet Dry Factor)
  ELSIF (lv2_method = EcDp_Calc_Method.GRS_MASS_WDF) THEN

    ln_wdf := findWDF(p_object_id,ld_fromday);

    IF ln_wdf > 0 THEN

      ln_return_val := findGrsStdMass(p_object_id,ld_fromday,ld_today) / ln_wdf;

    ELSE

      Ln_return_val := NULL;

      END IF;


  -- Grs Mass minus Water
  ELSIF (lv2_method = ecdp_calc_method.GRS_MASS_MINUS_WATER) THEN

    ln_grs_mass := findGrsStdMass(p_object_id,ld_fromday,ld_today);
    ln_wat_mass := findWatMass(p_object_id,ld_fromday,ld_today);

    ln_return_val := ln_grs_mass - ln_wat_mass;


  -- User Exit
  ELSIF (substr(lv2_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN

    ln_return_val := ue_stream_fluid.getNetStdMass(p_object_id, p_fromday,p_today);

  -- Totalizer Day
  ELSIF (lv2_method = ecdp_calc_method.TOTALIZER_DAY) THEN

    IF lv2_strm_meter_freq = 'DAY' THEN

    lb_first_iteration:= TRUE;

        FOR mycur IN c_daytime LOOP

          ln_grs_mass := findGrsStdMass(p_object_id, mycur.daytime);

          ln_bsw_wt := getBswWeightFrac(p_object_id, mycur.daytime);

          ln_salt_wt := getSaltWeightFrac(p_object_id, mycur.daytime);

            IF lb_first_iteration THEN

                ln_return_val := (ln_grs_mass * (1-ln_bsw_wt)* (1-nvl(ln_salt_wt,0)));
                lb_first_iteration := FALSE;

            ELSE

                ln_return_val := ln_return_val + (ln_grs_mass * (1-ln_bsw_wt)* (1-nvl(ln_salt_wt,0)));

            END IF;

          END LOOP;

      END IF;

       ln_return_val := ln_grs_mass * (1-ln_bsw_wt)* (1-nvl(ln_salt_wt,0));

  -- GRS_MASS_BSW_VOL
  ELSIF (lv2_method = EcDp_Calc_Method.GRS_MASS_BSW_VOL) THEN

    ln_grs_mass := findGrsStdMass(p_object_id,ld_fromday,ld_today);
    ln_grs_vol  := findGrsStdVol(p_object_id,ld_fromday,ld_today);
    ln_bsw_vol_frac := getBswVolFrac(lv2_stream_object_id, p_fromday);
    ln_std_dens     := findStdDens(p_object_id,ld_fromday);

    IF (ln_grs_mass = 0 AND ln_grs_vol = 0) THEN
      ln_return_val := 0;

    ELSIF (ln_grs_mass > 0 AND ln_grs_vol = 0) THEN
      ln_return_val := NULL;

    ELSE
      ln_return_val := ln_grs_mass * ( 1- (ln_bsw_vol_frac * ln_std_dens / (ln_grs_mass / ln_grs_vol)));

    END IF;

  ELSE -- Default

    ln_return_val := NULL;

  END IF;

  RETURN ln_return_val;

END findNetStdMass;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findNetStdVol
-- Description    : Returns the net standard volume in Sm3 for given
--                  stream and period.
-- Preconditions  : All input variables to calculations must have a defined value, or else
--                  the function call will return null.
-- Postcondition  :
-- Using Tables   : SYSTEM_DAYS
--
-- Using functions: EC_STRM_VERSION....
--                  EC_STRM_DAY_ALLOC.MATH_NET_VOL
--                  ECDP_STREAM_MEASURED.GETNETSTDVOL
--                  ECDP_STREAM_REFERENCE.GETMATHREFVALUE
--                  ECBP_STREAM_FLUID.GETBSWVOLFRAC
--                  ECDP_STREAM_MEASURED.GETGRSSTDVOL
--                  ECBP_STREAM_FLUID.FINDGRSSTDVOL
--
-- Configuration
-- required       :
--
-- Behaviour      : Alternative STRM_VERSION.... (NET_VOL_METHOD):
--
--                 1.  'MEASURED': Find bsw based on measured figures.
--                 2.  'ALLOCATED': Get data from strm_day_alloc
--                 3.  'FORMULA': Value based on a formula using stream formula editor
--                 4.  'GROSS_BSW': Find net_vol using data from gross volume and bsw
--                 5.  'GRS_VOL': equal to grs_vol
--                 6.  'MASS_DENSITY': find net_vol using data from net_mass and density
--                 7.  'NA': Not Applicable , return NULL
--                 8.  'GROSS_FACTOR': Calculate based on gross volume, bsw, meter factor and shrinkage factor
--                 9. 'TANK_DUAL_DIP': Calculate based on tank double dips
--                 10. 'BATCH_API':
--                 11. 'GRS_VOL_WDF'
--                 12. 'TOTALIZER_DAY'
--                 13. 'TOTALIZER_EVENT'
--                 14. 'USER_EXIT'
---------------------------------------------------------------------------------------------------
FUNCTION findNetStdVol (
     p_object_id    stream.object_id%TYPE,
     p_fromday      DATE,
     p_today        DATE     DEFAULT NULL,
     p_method       VARCHAR2 DEFAULT NULL,
     p_resolve_loop VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

  CURSOR c_system_days IS
  SELECT daytime
  FROM system_days
  WHERE daytime BETWEEN p_fromday AND Nvl(p_today, p_fromday);

  CURSOR c_strm_event(cp_object_id VARCHAR2, cp_fromday DATE, cp_today DATE) IS
  SELECT  net_vol,rate_override,quantity,object_id,bs_w,grs_vol,tank_object_id,daytime,manual_adj_vol
  FROM strm_event
  WHERE object_id = cp_object_id
  AND Nvl(event_day,TRUNC(daytime)) BETWEEN cp_fromday AND cp_today
  ORDER BY daytime ASC;

  CURSOR c_strm_event_single(cp_object_id VARCHAR2, cp_fromday DATE) IS
  SELECT net_vol,rate_override,quantity,object_id,bs_w,grs_vol,tank_object_id,manual_adj_vol,density,avg_press,avg_temp,Grs_Closing_Vol,Event_Type,Grs_Opening_Vol,end_date,daytime
  FROM strm_event
  WHERE object_id = cp_object_id
  AND daytime = cp_fromday;

  CURSOR c_strm_totalizer_days(cp_object_id VARCHAR2, cp_day DATE) IS
  SELECT net_vol,rate_override,quantity,object_id,bs_w,grs_vol,tank_object_id,manual_adj_vol,density,avg_press,avg_temp,Grs_Closing_Vol,Event_Type,Grs_Opening_Vol,end_date,daytime
    FROM strm_event
    WHERE object_id = cp_object_id
    AND ((daytime >= cp_day AND daytime < cp_day + 1) OR (daytime < cp_day AND end_date > cp_day))
    ORDER BY daytime;

  CURSOR c_strm_totalizer_event(cp_object_id VARCHAR2, cp_fromday DATE, cp_today DATE) IS
  SELECT net_vol,rate_override,quantity,object_id,bs_w,grs_vol,tank_object_id,manual_adj_vol,density,avg_press,avg_temp,Grs_Closing_Vol,Event_Type,Grs_Opening_Vol,end_date,daytime
  FROM strm_event
  WHERE object_id = cp_object_id
  AND event_day BETWEEN cp_fromday AND nvl(cp_today,cp_fromday)
  ORDER BY daytime ASC;

  -- pwel event inventory
  CURSOR c_pwel_event_inventory(cp_object_id VARCHAR2, cp_fromday DATE, cp_today DATE) IS
  SELECT bsw_out,GRS_OIL_OUT
  FROM pwel_event_inventory
  WHERE unload_stream_id = cp_object_id
  AND Nvl(unload_day,TRUNC(unload_daytime)) BETWEEN cp_fromday AND cp_today
  ORDER BY daytime ASC;

  -- pwel event inventory - single event
  CURSOR c_pwel_event_inventory_single(cp_object_id VARCHAR2, cp_fromday DATE) IS
  SELECT bsw_out,GRS_OIL_OUT
  FROM pwel_event_inventory
  WHERE unload_stream_id = cp_object_id
  AND  unload_daytime = cp_fromday
  ORDER BY daytime ASC;

  lv2_method                  VARCHAR2(32);
  lv2_grs_method              VARCHAR2(32);
  ln_bsw                      NUMBER;
  ln_grs_vol                  NUMBER;
  ln_return_val               NUMBER;
  ld_daytime                  DATE;
  lb_first_iteration          BOOLEAN;
  ln_density                  NUMBER;
  ln_net_vol                  NUMBER;
  lv2_strm_meter_freq         VARCHAR2(300);
  lv2_strm_meter_method       VARCHAR2(300);
  lv2_aggregate_flag          VARCHAR2(2);
  ln_BswVolFrac               NUMBER;
  ln_meter_factor             NUMBER;
  ln_shrinkage_factor         NUMBER;
  ln_grsStdVol                NUMBER;
  ld_fromday                  DATE;
  ld_today                    DATE;
  lv2_stream_object_id        stream.object_id%TYPE;
  ln_batch_api                NUMBER;
  lv2_tank_object_id          tank.object_id%TYPE;
  ln_wdf                      NUMBER;
  lv2_resolve_loop            VARCHAR2(2000);
  ln_accumulated_event_vol    NUMBER;
  ln_day_rate                 NUMBER;
  ln_duration_frac            NUMBER;
  ld_fromdaytime              DATE;
  ln_prod_day_offset          NUMBER;
  ln_totalizer_close          NUMBER;
  ln_totalizer_open           NUMBER;
  ln_totalizer_open_overwrite NUMBER;
  ld_maxdaytime               DATE;
  ln_duration                 NUMBER;
  ln_vcf                      NUMBER;
  ln_adj_vol                  NUMBER;
  lv_net_mass_method          VARCHAR2(32);
  ln_net_mass                 NUMBER;
  ln_bs_w                     NUMBER;
  lv2_phase                   VARCHAR2(32);
  ln_cur_date                 DATE;
  ln_diluent_concentration    NUMBER;
  ln_shrunk_vol               NUMBER;
  lr_strm_version_rec         strm_version%ROWTYPE;

BEGIN

  ld_fromday := p_fromday;
  ld_today := p_today;
  lv2_stream_object_id := p_object_id;

  lr_strm_version_rec := ec_strm_version.row_by_rel_operator(p_object_id, ld_fromday, '<=');

  -- Find this streams strm_meter_freq
  lv2_strm_meter_freq := NVL(lr_strm_version_rec.strm_meter_freq,'');

  -- Find this streams aggregate_flag
  lv2_aggregate_flag := NVL(lr_strm_version_rec.aggregate_flag,'NA');

  -- Find this streams meter method
  lv2_strm_meter_method := NVL(lr_strm_version_rec.strm_meter_method,'');

  lv2_method := Nvl(p_method,lr_strm_version_rec.net_vol_method);

  -- Find net_vol using data from strm_day_stream only
  IF (lv2_method = EcDp_Calc_Method.MEASURED) THEN

    IF lv2_strm_meter_freq = 'DAY' OR lv2_aggregate_flag = 'Y' THEN

      ln_return_val := Ec_Strm_day_stream.math_net_vol(
                                                      p_object_id,
                                                      ld_fromday,
                                                      ld_today);

    ELSIF lv2_strm_meter_freq = 'MTH' THEN

      ln_return_val := Ec_Strm_mth_stream.math_net_vol(
                                                      p_object_id,
                                                      ld_fromday,
                                                      ld_today);

    ELSIF lv2_strm_meter_method = 'EVENT' THEN

      ln_return_val := 0;
      IF ld_today IS NULL THEN

        FOR curEvent IN c_strm_event_single(lv2_stream_object_id, ld_fromday) LOOP

          IF curEvent.net_vol IS NULL THEN
            IF curEvent.rate_override is NULL THEN
              ln_return_val := curEvent.quantity * ec_strm_reference_value.rate(curEvent.object_id, ld_fromday, '<='); -- use rate from strm_reference_value and qty from BF
            ELSE
              ln_return_val := curEvent.quantity * curEvent.rate_override; -- use rate override from BF and qty from BF
            END IF;
          ELSE
            ln_return_val :=  curEvent.net_vol; -- this is the Volume Override in the BF
          END IF;

        END LOOP;

      ELSE
        lb_first_iteration:= TRUE;

        FOR curEvent IN c_strm_event(lv2_stream_object_id, ld_fromday, ld_today) LOOP

          IF lb_first_iteration THEN
            lb_first_iteration := FALSE;
            IF curEvent.net_vol IS NULL THEN
              IF curEvent.rate_override is NULL THEN
                ln_return_val := curEvent.quantity * ec_strm_reference_value.rate(curEvent.object_id, ld_fromday, '<='); -- use rate from strm_reference_value and qty from BF
              ELSE
                ln_return_val := curEvent.quantity * curEvent.rate_override; -- use rate override from BF and qty from BF
              END IF;
            ELSE
              ln_return_val :=  curEvent.net_vol; -- this is the Volume Override in the BF
            END IF;

          ELSE

            IF curEvent.net_vol IS NULL THEN
              IF curEvent.rate_override is NULL THEN
                ln_return_val := ln_return_val + (curEvent.quantity * ec_strm_reference_value.rate(curEvent.object_id, ld_fromday, '<=')); -- use rate from strm_reference_value and qty from BF
              ELSE
                ln_return_val := ln_return_val + (curEvent.quantity * curEvent.rate_override); -- use rate override from BF and qty from BF
              END IF;
            ELSE
              ln_return_val :=  ln_return_val + curEvent.net_vol; -- this is the Volume Override in the BF
            END IF;

          END IF;

        END LOOP;

      END IF;

    ELSE  -- undefined lv2_strm_meter_freq

      ln_return_val := NULL;

    END IF;


  -- Get data from strm_day_alloc
  ELSIF (lv2_method = EcDp_Calc_Method.ALLOCATED) THEN

    ln_return_val :=  ec_strm_day_alloc.math_net_vol(
                                                    p_object_id,
                                                    ld_fromday,
                                                    ld_today);    -- Underlying function uses Oracle BETWEEN

  -- Get data from strm_day_alloc
  ELSIF (lv2_method = EcDp_Calc_Method.ALLOC_THEOR) THEN

    ln_return_val := ec_strm_day_alloc.THEOR_NET_VOL(
                                                     p_object_id,
                                                     ld_fromday,
                                                     '=');

  -- Formula stream method
  ELSIF (lv2_method = EcDp_Calc_Method.FORMULA) THEN
    ln_return_val := 0;
    IF lv2_strm_meter_freq = 'MTH' THEN
       ln_return_val := EcDp_Stream_Formula.getNetStdVol(
                                                      p_object_id,
                                                      ld_fromday,
                                                      ld_today);
    ELSE
    IF ld_today IS NOT NULL AND ld_today > ld_fromday THEN
      ln_cur_date := ld_fromday;

      WHILE ln_cur_date <= ld_today LOOP
        ln_return_val := ln_return_val + EcDp_Stream_Formula.getNetStdVol(
                                                      p_object_id,
                                                      ln_cur_date,
                                                      NULL);
        ln_cur_date := ln_cur_date + 1;
      END LOOP;

    ELSE
      ln_return_val := EcDp_Stream_Formula.getNetStdVol(
                                                      p_object_id,
                                                      ld_fromday,
                                                      ld_today);
    END IF;
  END IF;

  -- Find net_vol using gross volume and bsw
   -- Find net_vol using gross volume and bsw
  ELSIF (lv2_method = EcDp_Calc_Method.GROSS_BSW) THEN

    IF lv2_strm_meter_method = 'EVENT' THEN
      lv2_grs_method := NVL(p_method, lr_strm_version_rec.grs_vol_method);
      lv2_phase := lr_strm_version_rec.stream_phase;
      -- Find net_vol using event based gross volume and bsw from truck transport data
      IF(lv2_grs_method IN (EcDp_Calc_Method.MEASURED_TRUCKED)) THEN
        -- test if it is a single record or sum over production days to be returned
        IF ld_today IS NULL THEN
          ln_return_val := NULL;  -- this is not possible, use EcBp_Stream_TruckTickets.findNetStdVol() instead but it cannot be called from here.
        ELSE -- looking for sum of event values over a given period
          lb_first_iteration:= TRUE;
          ln_return_val := 0;
          FOR curEvent2 IN c_strm_transport_event (lv2_stream_object_id, ld_fromday, ld_today) LOOP
            IF lb_first_iteration THEN
              lb_first_iteration := FALSE;
              IF lv2_phase = 'WAT' THEN
                ln_return_val := EcBp_Truck_Ticket.findWatVol(curEvent2.event_no);
              ELSE
                ln_return_val := EcBp_Truck_Ticket.findNetStdVol(curEvent2.event_no);
              END IF;
            ELSE
              IF lv2_phase = 'WAT' THEN
                ln_return_val := ln_return_val + EcBp_Truck_Ticket.findWatVol(curEvent2.event_no);
              ELSE
                ln_return_val := ln_return_val + EcBp_Truck_Ticket.findNetStdVol(curEvent2.event_no);
              END IF;
            END IF;
          END LOOP;
        END IF;
      -- Find net volume for a truck load by summarize all the unload net volumes
      -- See Ecbp_Stream_Truckticket.getNetVol


      ELSIF(lv2_grs_method = EcDp_Calc_Method.MEASURED) THEN

        IF p_today IS NULL THEN
          FOR cur_strm_event IN c_strm_event_single(p_object_id, p_fromday) LOOP -- expected only 1 record.
            ln_bsw := NVL(cur_strm_event.bs_w,0);
            ln_net_vol := cur_strm_event.grs_vol * (1 - ln_bsw);

          END LOOP;

        ELSE -- p_today IS NOT NULL

          ln_net_vol := 0;

          FOR mycur IN c_system_days LOOP
            FOR cur_strm_event IN c_strm_event(p_object_id, p_fromday, p_today) LOOP
              ln_bsw := NVL(cur_strm_event.bs_w,0);
              ln_net_vol := ln_net_vol + (nvl(cur_strm_event.grs_vol,0) * (1 - ln_bsw));

            END LOOP;

          END LOOP;

          ln_return_val := ln_net_vol;

        END IF;

        ln_return_val := ln_net_vol;

      END IF;

    ELSE -- non event based stream

       lb_first_iteration:= TRUE;

       IF lv2_strm_meter_freq = 'MTH' THEN

     ln_grs_vol := EcBp_Stream_Fluid.findGrsStdVol(lv2_stream_object_id,p_fromday,p_today);
     IF ln_grs_vol = 0 THEN
      ln_return_val := 0;
     ELSE
      ln_return_val := ln_grs_vol  * (1 - getBswVolFrac(lv2_stream_object_id, p_fromday));
     END IF;

       ELSE

         --Calculate net volume and summarise day for day.
      ln_return_val := 0;
         FOR mycur IN c_system_days LOOP
           ln_bsw := getBswVolFrac( p_object_id,
                                    mycur.daytime);

           ln_grs_vol := EcBp_Stream_Fluid.findGrsStdVol(
                                                     p_object_id,
                                                     mycur.daytime,
                                                     mycur.daytime);

      IF lb_first_iteration THEN
         lb_first_iteration := FALSE;
      END IF;

      --if gross volume is 0 then return 0
      IF ln_grs_vol = 0 THEN
        IF (ln_return_val IS NULL) THEN
          ln_return_val := ln_return_val;
        END IF;
      ELSE
        ln_return_val := ln_return_val + ln_grs_vol * (1 - ln_bsw);
      END IF;

         END LOOP;
      END IF;
    END IF;

  -- Equal to grs vol
  ELSIF (lv2_method = EcDp_Calc_Method.GRS_VOL) THEN

    IF InStr(p_resolve_loop,'findNetStdVol')>0 THEN
      RAISE_APPLICATION_ERROR(-20000,'A loop was detected when trying to calculate a stream''s Net Std Volume. Possibly due to a mis-configuration of stream attributes.');
    ELSE  -- Call the next function with the argument to this function, or this function name if no argument
      lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findNetStdVol,';
    END IF;

    ln_return_val := EcBp_Stream_Fluid.findGrsStdVol(
                                                     p_object_id,
                                                     ld_fromday,
                                                     ld_today,
                                                     NULL,
                                                     lv2_resolve_loop);


  -- Equal to net_mass/density
  ELSIF (lv2_method = EcDp_Calc_Method.MASS_DENSITY) THEN

    lb_first_iteration:= TRUE;

    lv_net_mass_method := Nvl(p_method,lr_strm_version_rec.net_mass_method);

    IF (lv_net_mass_method = EcDp_Calc_Method.VOLUME_DENSITY) THEN
      RAISE_APPLICATION_ERROR(-20000,'A loop was detected when trying to calculate Net Std Volume. Check Configuration.');
    END IF;

    IF lv2_strm_meter_freq = 'MTH' THEN
      -- monthly loop
      FOR mycur IN c_system_month(ld_fromday,ld_today) LOOP
        ln_net_mass := EcBp_Stream_Fluid.findNetStdMass(p_object_id,mycur.daytime,LAST_DAY(mycur.daytime));
        -- only access density if grs mass <> 0, else we dont use density.
        IF ln_net_mass <> 0 THEN
          ln_density := EcBp_Stream_Fluid.findStdDens(p_object_id,mycur.daytime);
        END IF;
        IF lb_first_iteration THEN
          lb_first_iteration := FALSE;
          IF ln_net_mass = 0 THEN
            ln_return_val := 0;
          ELSIF ln_density > 0 THEN
            ln_return_val := ln_net_mass / ln_density;
          ELSE
            ln_return_val := NULL;
          END IF;
        ELSE
         IF ln_net_mass = 0 THEN
           ln_return_val := ln_return_val + 0; -- yes, dont add anything if mass is zero, the volume is also zero.
         ELSIF ln_density > 0 THEN
           ln_return_val := ln_return_val + (ln_net_mass / ln_density);
         ELSE -- negative, zero or NULL density should give NULL
           ln_return_val := NULL;
         END IF;
       END IF;
     END LOOP;

   ELSE
     -- daily loop
     FOR mycur IN c_system_days LOOP
       ln_net_mass := EcBp_Stream_Fluid.findNetStdMass(p_object_id,mycur.daytime,mycur.daytime);
       -- only access density if grs mass <> 0, else we dont use density.
       IF ln_net_mass <> 0 THEN
         ln_density := EcBp_Stream_Fluid.findStdDens(p_object_id,mycur.daytime);
       END IF;
       IF lb_first_iteration THEN
         lb_first_iteration := FALSE;
         IF ln_net_mass = 0 THEN
           ln_return_val := 0;
         ELSIF ln_density > 0 THEN
           ln_return_val := ln_net_mass / ln_density;
         ELSE
           ln_return_val := NULL;
         END IF;
       ELSE
         IF ln_net_mass = 0 THEN
           ln_return_val := ln_return_val + 0; -- yes, dont add anything if mass is zero, the volume is also zero.
         ELSIF ln_density > 0 THEN
           ln_return_val := ln_return_val + (ln_net_mass / ln_density);
         ELSE
           ln_return_val := NULL; -- negative, zero or NULL density should give NULL
         END IF;
       END IF;
     END LOOP;

   END IF;


  -- No net vol to be calculated
  ELSIF (lv2_method = EcDp_Calc_Method.NA) THEN

    ln_return_val := NULL;


  -- Equals grs vol adjusted for bsw, meter factor and shrinkage factor
  ELSIF (lv2_method = EcDp_Calc_Method.GROSS_FACTOR) THEN

    lb_first_iteration:= TRUE;

    IF lv2_strm_meter_freq = 'MTH' THEN

      ln_meter_factor     := ec_strm_reference_value.meter_factor(lv2_stream_object_id,p_fromday,'<=');
      ln_shrinkage_factor := ec_strm_reference_value.shrinkage_factor(lv2_stream_object_id,p_fromday,'<=');
      ln_BswVolFrac := EcBp_Stream_Fluid.getBswVolFrac(p_object_id, p_fromday);
      ln_grsStdVol :=  EcBp_Stream_Fluid.findGrsStdVol(p_object_id, p_fromday);

      ln_return_val := ln_grsStdVol * ln_meter_factor * ( 1 - ln_BswVolFrac) * ln_shrinkage_factor;

    ELSE

      FOR mycur IN c_system_days LOOP

        ln_meter_factor     := ec_strm_reference_value.meter_factor(lv2_stream_object_id,mycur.daytime,'<=');
        ln_shrinkage_factor := ec_strm_reference_value.shrinkage_factor(lv2_stream_object_id,mycur.daytime,'<=');
        ln_BswVolFrac := EcBp_Stream_Fluid.getBswVolFrac(p_object_id, mycur.daytime);
        ln_grsStdVol :=  EcBp_Stream_Fluid.findGrsStdVol(p_object_id, mycur.daytime);

        IF lb_first_iteration THEN

           ln_return_val := ln_grsStdVol * ln_meter_factor * ( 1 - ln_BswVolFrac) * ln_shrinkage_factor;
           lb_first_iteration := FALSE;

        ELSE

           ln_return_val := ln_return_val + ln_grsStdVol * ln_meter_factor * ( 1 - ln_BswVolFrac) * ln_shrinkage_factor;

        END IF;

      END LOOP;

    END IF;


  ELSIF (lv2_method = EcDp_Calc_Method.TANK_DUAL_DIP) THEN
    ln_return_val := 0;

    -- test if it is a single record or sum over production days to be returned
    IF ld_today IS NULL THEN
      -- Loop over single stream_event record.
      FOR curEvent IN c_strm_event_single(lv2_stream_object_id, ld_fromday) LOOP
         ln_net_vol := EcBp_Tank.findNetStdOilVol(curEvent.tank_object_id,'DUAL_DIP_OPENING',curEvent.daytime) -
                       EcBp_Tank.findNetStdOilVol(curEvent.tank_object_id,'DUAL_DIP_CLOSING',curEvent.daytime);

         ln_return_val :=  ln_net_vol + Nvl(curEvent.manual_adj_vol,0); -- add adjustment volume, but the default is null

      END LOOP;

    ELSE -- its sum over all records belonging to production days between ld_fromday and ld_today
      lb_first_iteration:= TRUE;

      FOR curEvent IN c_strm_event(lv2_stream_object_id, ld_fromday, ld_today) LOOP
         ln_net_vol := EcBp_Tank.findNetStdOilVol(curEvent.tank_object_id,'DUAL_DIP_OPENING',curEvent.daytime) -
                         EcBp_Tank.findNetStdOilVol(curEvent.tank_object_id,'DUAL_DIP_CLOSING',curEvent.daytime);

         IF lb_first_iteration THEN
           lb_first_iteration := FALSE;
           ln_return_val := ln_net_vol + Nvl(curEvent.manual_adj_vol,0); -- add adjustment volume, but the default is null
         ELSE
           ln_return_val := ln_return_val + ln_net_vol + Nvl(curEvent.manual_adj_vol,0); -- add adjustment volume, but the default is null

         END IF;

       END LOOP;
     END IF;

  -- Get dry gas from wet gas and WDF (Wet Dry Factor)
  ELSIF (lv2_method = EcDp_Calc_Method.GRS_VOL_WDF) THEN

     ln_wdf := findWDF(p_object_id,ld_fromday);

     IF ln_wdf > 0 THEN

       ln_return_val := findGrsStdVol(p_object_id,ld_fromday,ld_today) / ln_wdf;
     ELSE

       Ln_return_val := NULL;

     END IF;


  ELSIF (lv2_method = EcDp_Calc_Method.TOTALIZER_DAY) THEN

     lv2_phase := lr_strm_version_rec.stream_phase;

     -- This is for the new BF Daily Liquid Stream Data (PO.0085) and is only for liquid and meter freq must be DAY
     IF (lv2_strm_meter_freq = 'DAY' AND lv2_phase in ('OIL','COND','WAT')) THEN
       lb_first_iteration:= TRUE;

       FOR mycur IN c_system_days LOOP

         ln_grs_vol := findGrsStdVol(p_object_id,mycur.daytime);

         ln_bs_w := getBswVolFrac(p_object_id,mycur.daytime);

         IF lb_first_iteration THEN

           ln_net_vol := (ln_grs_vol * (1-ln_bs_w));
           lb_first_iteration := FALSE;

         ELSE

           ln_net_vol := ln_net_vol + (ln_grs_vol * (1-ln_bs_w));

         END IF;

       END LOOP;

     -- when lv2_strm_meter_freq is null or 'NA' and p_today is null, then we are asking for one record only; the one equal p_fromday.
     ELSIF ((lv2_strm_meter_freq IS NULL OR lv2_strm_meter_freq='NA') AND p_today IS NULL) THEN

       FOR cur_strm_event IN c_strm_event_single(p_object_id, p_fromday) LOOP -- expected only 1 record.

         ln_bsw := NVL(cur_strm_event.bs_w,0);
         ln_vcf := EcBp_Stream_Fluid.getVCF(p_object_id, p_fromday, cur_strm_event.density, cur_strm_event.avg_press, cur_strm_event.avg_temp);

       END LOOP;

       ln_net_vol :=   EcBp_Stream_Fluid.findGrsStdVol(p_object_id, p_fromday) * (1 - ln_bsw) * NVL(ln_vcf,1);

     -- p_today IS NOT NULL meaning that we should return a volume for production days between p_fromday and p_today
     ELSIF ((lv2_strm_meter_freq IS NULL OR lv2_strm_meter_freq='NA') AND p_today IS NOT NULL) THEN

       ln_accumulated_event_vol := 0;
       ln_net_vol := 0;
       ln_prod_day_offset := (EcDp_ProductionDay.getProductionDayOffset('STREAM', p_object_id, p_fromday) / 24);

       -- loop one day at the time, makes the logic much easier and in 99% of the cases its only one day being queried.
       FOR mycur IN c_system_days LOOP

         ld_fromdaytime := mycur.daytime + ln_prod_day_offset;

           FOR curTotalizer IN c_strm_totalizer_days(p_object_id, ld_fromdaytime) LOOP

             -- calcDailyRateTotalizer will call findNetStdVol(), this function, for each day (p_today is null)
             ln_day_rate := NVL(calcDailyRateTotalizer(p_object_id, curTotalizer.daytime),0);
             ln_duration_frac := least(curTotalizer.end_date, ld_fromdaytime+1) - greatest(curTotalizer.daytime, ld_fromdaytime);
             ln_accumulated_event_vol := ln_accumulated_event_vol + (ln_day_rate * ln_duration_frac);
           END LOOP;

         END LOOP;

         ln_net_vol := NVL(ln_net_vol,0) + ln_accumulated_event_vol;

      END IF;

      ln_return_val := ln_net_vol;

   ELSIF (lv2_method = EcDp_Calc_Method.TOTALIZER_DAY_EXTRAPOLATE) THEN

      -- when lv2_strm_meter_freq is null or 'NA' and p_today is null, then we are asking for one record only; the one equal p_fromday.
      IF ((lv2_strm_meter_freq IS NULL OR lv2_strm_meter_freq='NA') AND p_today IS NULL) THEN

        -- only 1 record.
        FOR cur_strm_event IN c_strm_event_single(p_object_id, p_fromday) LOOP

          ln_bsw := NVL(cur_strm_event.bs_w,0);
          ln_vcf := EcBp_Stream_Fluid.getVCF(p_object_id, p_fromday, cur_strm_event.density, cur_strm_event.avg_press, cur_strm_event.avg_temp);
          ln_totalizer_close := cur_strm_event.Grs_Closing_Vol;
          ln_totalizer_open  := ec_strm_event.grs_closing_vol(cur_strm_event.object_id,cur_strm_event.Event_Type,cur_strm_event.daytime,'<');
          ln_totalizer_open_overwrite := cur_strm_event.Grs_Opening_Vol;

          IF ln_totalizer_close IS NULL AND (ln_totalizer_open_overwrite IS NULL OR ln_totalizer_open IS NULL) THEN
            ld_maxdaytime := getLastNotNullClosingValueDate(p_object_id, p_fromday);
            IF ld_maxdaytime is NOT NULL THEN
              ln_day_rate := calcDailyRateTotalizer(p_object_id, ld_maxdaytime);
              ln_duration := cur_strm_event.end_date - cur_strm_event.daytime;
              ln_net_vol := ln_duration * ln_day_rate;
            END IF;
          ELSE
            ln_net_vol := EcBp_Stream_Fluid.findGrsStdVol(p_object_id, p_fromday) * (1 - nvl(ln_bsw,0)) * NVL(ln_vcf,1);
          END IF;

        END LOOP;

      -- p_today IS NOT NULL meaning that we should return a volume for production days between p_fromday and p_today
      ELSIF ((lv2_strm_meter_freq IS NULL OR lv2_strm_meter_freq='NA') AND p_today IS NOT NULL) THEN

        ln_accumulated_event_vol := 0;
        ln_net_vol := 0;
        ln_prod_day_offset := (EcDp_ProductionDay.getProductionDayOffset('STREAM', p_object_id, p_fromday) / 24);

        -- loop one day at the time, makes the logic much easier and in 99% of the cases its only one day being queried.
        FOR mycur IN c_system_days LOOP

          ld_fromdaytime := mycur.daytime + ln_prod_day_offset;

          FOR curTotalizer IN c_strm_totalizer_days(p_object_id, ld_fromdaytime) LOOP

            -- calcDailyRateTotalizer will call findNetStdVol(), this function, for each day (p_today is null)
            ln_day_rate := NVL(calcDailyRateTotalizer(p_object_id,curTotalizer.daytime),0);
            ln_duration_frac := least(curTotalizer.end_date, ld_fromdaytime+1) - greatest(curTotalizer.daytime, ld_fromdaytime);
            ln_accumulated_event_vol := ln_accumulated_event_vol + (ln_day_rate * ln_duration_frac);

          END LOOP;

        END LOOP;

        ln_net_vol := NVL(ln_net_vol,0) + ln_accumulated_event_vol;

      END IF;

      ln_return_val := ln_net_vol;

   ELSIF (lv2_method = EcDp_Calc_Method.TOTALIZER_EVENT) THEN

      IF p_today IS NULL THEN

        FOR cur_strm_event IN c_strm_event_single(p_object_id, p_fromday) LOOP -- expected only 1 record.
            ln_bsw := NVL(EcBp_Stream_Fluid.getBswVolFrac(p_object_id, cur_strm_event.daytime),0);
        END LOOP;

        ln_net_vol := EcBp_Stream_Fluid.findGrsStdVol(p_object_id, p_fromday, NULL, 'TOTALIZER_EVENT') * (1 - ln_bsw);

      ELSIF p_today IS NOT NULL THEN

        ln_net_vol := 0;

        -- loop one day at the time, makes the logic much easier and in 99% of the cases its only one day being queried.
        FOR mycur IN c_system_days LOOP

          FOR curTotalizer IN c_strm_totalizer_event(p_object_id, mycur.daytime, mycur.daytime) LOOP
             ln_bsw := NVL(EcBp_Stream_Fluid.getBswVolFrac(p_object_id, curTotalizer.daytime),0);
             ln_net_vol := ln_net_vol + nvl(EcBp_Stream_Fluid.findGrsStdVol(p_object_id, curTotalizer.daytime, NULL , 'TOTALIZER_EVENT'),0) * (1 - ln_bsw);
          END LOOP;

        END LOOP;

      END IF;

      ln_return_val := ln_net_vol;


   -- event_well_withdrawn
   ELSIF (lv2_method = EcDp_Calc_Method.WELL_INV_WITHDRAW) THEN

     IF p_today IS NULL THEN
       FOR cur_pwel_event_single IN c_pwel_event_inventory_single(p_object_id, p_fromday) LOOP -- expected only 1 record.
         ln_net_vol := cur_pwel_event_single.grs_oil_out * (1 - Nvl(cur_pwel_event_single.bsw_out, 0));
       END LOOP;

     ELSE -- p_today IS NOT NULL

       ln_net_vol := 0;

       FOR cur_pwel_event_inventory IN c_pwel_event_inventory(p_object_id, p_fromday, p_today) LOOP

         ln_net_vol := ln_net_vol + Nvl(cur_pwel_event_inventory.grs_oil_out * (1 - Nvl(cur_pwel_event_inventory.bsw_out, 0)), 0);

       END LOOP;

     END IF;

     ln_return_val := ln_net_vol;

   ELSIF (lv2_method = 'API_BLEND_SHRINKAGE') THEN

     FOR mycur IN c_system_days LOOP
       ln_net_vol:= EcBp_Stream_Fluid.findNetStdVol(p_object_id, mycur.daytime, mycur.daytime, 'GROSS_BSW', p_resolve_loop);

       IF ln_net_vol > 0 THEN --only calculate bitumen volume if blend volume is > 0
		 ln_return_val := 0;

         ln_diluent_concentration := EcBp_VCF.calcDiluentConcentration(p_object_id, mycur.daytime);
         ln_shrunk_vol := EcBp_Stream_Fluid.calcShrunkVol(p_object_id, mycur.daytime);
         ln_return_val := ln_return_val + ((ln_net_vol + ln_shrunk_vol)*(1-ln_diluent_concentration));
	   ELSIF ln_net_vol = 0 THEN
		ln_return_val := 0;
       END IF;

	   IF lv2_strm_meter_freq = 'MTH' THEN
		EXIT;
	   END IF;
     END LOOP;
     RETURN ln_return_val;

 -- User Exit
   ELSIF (substr(lv2_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN

    ln_return_val := ue_stream_fluid.getNetStdVol(p_object_id, p_fromday,p_today);

   ELSE  -- Undefined

     ln_return_val := NULL;

   END IF;

   RETURN ln_return_val;

END findNetStdVol;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findStdDens
-- Description    : Returns the density in standard condition for a
--                  given stream and day.
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--                 EC_STRM_VERSION....
--
-- Configuration
-- required       : If p_method is null STRM_VERSION.... = 'STD_DENSITY_METHOD'
--                  must be set.
--
-- Behaviour      :
--                Alternaive methods based on configuration:
--                1. METHOD= 'MEASURED' ( Find density using data from strm_day_stream only)
--                2. METHOD= 'CALCULATED' ( Find mass and volume using net_mass and net_vol functions)
--                3. METHOD= 'REF_VALUE' ( Find density using reference value)
--                4. METHOD= 'COMP_ANALYSIS' (get density from last 'comp' analysis)
--                5. METHOD= 'SAMPLE_ANALYSIS' (get density from last 'sample' analysis)
--                6. METHOD= 'ANALYSIS_SP_GRAV' (find density based on specific gravity on last
--                  available comp analysis)
--                7. METHOD= 'ALLOCATED' (find density based on specific gravity on last available comp analysis)
--                8. METHOD= 'REF_STREAM' (find density from a reference stream density)
--                9. METHOD= 'MEASURED_API' (calculate standard density from API)
--                10. METHOD= 'USER_EXIT'
---------------------------------------------------------------------------------------------------
FUNCTION findStdDens (
     p_object_id    stream.object_id%TYPE,
     p_daytime      DATE,
     p_method       VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

ln_return_val    NUMBER;
lv2_method    VARCHAR2(32);
ln_meas_id     NUMBER;
lv2_stream_object_id  stream.object_id%TYPE;
lv2_strm_meter_freq  VARCHAR2(300);
lv2_strm_meter_method  VARCHAR2(300);
lv2_aggregate_flag   VARCHAR2(2);
lv2_phase    VARCHAR2(32);
lv2_analysis_ref_id stream.object_id%TYPE;
lr_analysis    object_fluid_analysis%ROWTYPE;
lr_analysis_sample object_fluid_analysis%ROWTYPE;
ln_wat_dens    NUMBER;
ln_air_dens     NUMBER;

CURSOR c_strm_event_single(cp_object_id VARCHAR2, cp_fromday DATE) IS
SELECT *
FROM strm_event
WHERE object_id = cp_object_id
AND daytime = cp_fromday;

CURSOR c_strm_transport_event_single(cp_object_id VARCHAR2, cp_fromday DATE) IS
SELECT *
FROM strm_transport_event
WHERE ((object_id = cp_object_id) OR (stream_id = cp_object_id))
AND daytime = cp_fromday;

BEGIN

   -- Determine which method to use

   lv2_method := Nvl(p_method, ec_strm_version.STD_DENS_METHOD(
                 p_object_id,
                 p_daytime,
                 '<='));

   -- Find this streams strm_meter_freq
   lv2_strm_meter_freq := NVL(ec_strm_version.STRM_METER_FREQ(p_object_id, p_daytime, '<='),'');

   -- Find this streams aggregate_flag
   lv2_aggregate_flag := NVL(ec_strm_version.aggregate_flag(p_object_id, p_daytime, '<='),'NA');

   -- Find this streams meter method
   lv2_strm_meter_method := NVL(ec_strm_version.strm_meter_method(p_object_id, p_daytime, '<='),'');

   lv2_stream_object_id := p_object_id;

   -- METHOD= 'MEASURED' ( Find density using data from strm_day_stream only)
   IF (lv2_method = EcDp_Calc_Method.MEASURED) THEN

      IF lv2_strm_meter_freq = 'DAY' OR lv2_aggregate_flag = 'Y' THEN

         ln_return_val := Ec_Strm_day_stream.density(
                                                    p_object_id,
                                                    p_daytime);

      ELSIF lv2_strm_meter_freq = 'MTH' THEN

         ln_return_val := Ec_Strm_mth_stream.density(
                                                    p_object_id,
                                                    p_daytime);

      ELSIF lv2_strm_meter_method = 'EVENT' THEN

		FOR curEvent IN c_strm_event_single(lv2_stream_object_id, p_daytime) LOOP
          ln_return_val := curEvent.density;
		END LOOP;

        IF ln_return_val IS NULL THEN
			FOR curEvent IN c_strm_transport_event_single(lv2_stream_object_id, p_daytime) LOOP
				ln_return_val := curEvent.std_density;
			END LOOP;
        END IF;

      END IF;

   -- METHOD= 'CALCULATED' ( Find mass and volume using net_mass and net_vol functions)
   ELSIF (lv2_method = EcDp_Calc_Method.CALCULATED) THEN

      ln_return_val := calcNetStdDens (
                                      p_object_id,
                                      p_daytime);

   -- METHOD= 'REF_VALUE' ( Find density using reference value)
   ELSIF (lv2_method = EcDp_Calc_Method.REF_VALUE) THEN

      ln_return_val := ec_strm_reference_value.density(p_object_id, p_daytime, '<=');

   -- METHOD= 'COMP_ANALYSIS' (get density from last 'comp' analysis)
   ELSIF (lv2_method = EcDp_Calc_Method.COMP_ANALYSIS) THEN

      lv2_phase := Ec_Strm_Version.stream_phase(p_object_id,p_daytime, '<=');
      lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(lv2_stream_object_id, p_daytime);

      IF lv2_phase in ('OIL','COND') THEN

          lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_OIL_COMP', null, p_daytime, lv2_phase);
         ln_return_val := lr_analysis_sample.density;

      ELSIF lv2_phase in ('GAS', 'CO2') THEN

         lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_GAS_COMP', null, p_daytime, lv2_phase);
         ln_return_val := lr_analysis_sample.density;

      ELSIF lv2_phase in ('LNG') THEN

         lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_LNG_COMP', null, p_daytime, lv2_phase);
         ln_return_val := lr_analysis_sample.density;

      ELSE -- Not supported

         ln_return_val := NULL;

      END IF;

   -- METHOD= 'COMP_ANALYSIS_SPOT'
   ELSIF (lv2_method = EcDp_Calc_Method.COMP_ANALYSIS_SPOT) THEN

      lv2_phase := Ec_Strm_Version.stream_phase(p_object_id,p_daytime, '<=');
      lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(lv2_stream_object_id, p_daytime);

      IF lv2_phase in ('OIL','COND') THEN

          lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_OIL_COMP', 'SPOT', p_daytime, lv2_phase);
         ln_return_val := lr_analysis_sample.density;

      ELSIF lv2_phase in ('GAS', 'CO2') THEN

         lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_GAS_COMP', 'SPOT', p_daytime, lv2_phase);
         ln_return_val := lr_analysis_sample.density;

      ELSIF lv2_phase in ('LNG') THEN

          lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_LNG_COMP','SPOT', p_daytime, lv2_phase);
         ln_return_val := lr_analysis_sample.density;

      ELSE -- Not supported

         ln_return_val := NULL;

      END IF;

   -- METHOD= 'COMP_ANALYSIS_DAY'
   ELSIF (lv2_method = EcDp_Calc_Method.COMP_ANALYSIS_DAY) THEN

      lv2_phase := Ec_Strm_Version.stream_phase(p_object_id,p_daytime, '<=');
      lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(lv2_stream_object_id, p_daytime);

      IF lv2_phase in ('OIL','COND') THEN

          lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_OIL_COMP', 'DAY_SAMPLER', p_daytime, lv2_phase);
         ln_return_val := lr_analysis_sample.density;

      ELSIF lv2_phase in ('GAS', 'CO2') THEN

         lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_GAS_COMP', 'DAY_SAMPLER', p_daytime, lv2_phase);
         ln_return_val := lr_analysis_sample.density;

      ELSIF lv2_phase in ('LNG') THEN

         lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_LNG_COMP', 'DAY_SAMPLER', p_daytime, lv2_phase);
         ln_return_val := lr_analysis_sample.density;

      ELSE -- Not supported

         ln_return_val := NULL;

      END IF;

   -- METHOD= 'COMP_ANALYSIS_MTH'
   ELSIF (lv2_method = EcDp_Calc_Method.COMP_ANALYSIS_MTH) THEN

      lv2_phase := Ec_Strm_Version.stream_phase(p_object_id,p_daytime, '<=');
      lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(lv2_stream_object_id, p_daytime);

      IF lv2_phase in ('OIL','COND') THEN

          lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_OIL_COMP', 'MTH_SAMPLER', p_daytime, lv2_phase);
         ln_return_val := lr_analysis_sample.density;

      ELSIF lv2_phase in ('GAS', 'CO2') THEN

         lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_GAS_COMP', 'MTH_SAMPLER', p_daytime, lv2_phase);
         ln_return_val := lr_analysis_sample.density;

      ELSIF lv2_phase in ('LNG') THEN

         lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_LNG_COMP', 'MTH_SAMPLER', p_daytime, lv2_phase);
         ln_return_val := lr_analysis_sample.density;

      ELSE -- Not supported

         ln_return_val := NULL;

      END IF;

   -- METHOD= 'SAMPLE_ANALYSIS' (get density from last stream sample analysis)
   ELSIF (lv2_method = EcDp_Calc_Method.SAMPLE_ANALYSIS) THEN

     lv2_phase := Ec_Strm_Version.stream_phase(p_object_id,p_daytime, '<=');
     lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(lv2_stream_object_id, p_daytime);

     lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_SAMPLE_ANALYSIS', null, p_daytime, lv2_phase);
     ln_return_val := lr_analysis_sample.density;

   -- METHOD= 'SAMPLE_ANALYSIS_SPOT' (get density from last stream sample spot analysis)
   ELSIF (lv2_method = EcDp_Calc_Method.SAMPLE_ANALYSIS_SPOT) THEN

     lv2_phase := Ec_Strm_Version.stream_phase(p_object_id,p_daytime, '<=');
     lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(lv2_stream_object_id, p_daytime);

     lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_SAMPLE_ANALYSIS', 'SPOT', p_daytime, lv2_phase);
     ln_return_val := lr_analysis_sample.density;

   -- METHOD= 'SAMPLE_ANALYSIS_DAY' (get density from last stream sample day analysis)
   ELSIF (lv2_method = EcDp_Calc_Method.SAMPLE_ANALYSIS_DAY) THEN

     lv2_phase := Ec_Strm_Version.stream_phase(p_object_id,p_daytime, '<=');
     lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(lv2_stream_object_id, p_daytime);

     lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_SAMPLE_ANALYSIS', 'DAY_SAMPLER', p_daytime, lv2_phase);
     ln_return_val := lr_analysis_sample.density;

    -- METHOD= 'SAMPLE_ANALYSIS_MTH' (get density from last stream sample month analysis)
   ELSIF (lv2_method = EcDp_Calc_Method.SAMPLE_ANALYSIS_MTH) THEN

     lv2_phase := Ec_Strm_Version.stream_phase(p_object_id,p_daytime, '<=');
     lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(lv2_stream_object_id, p_daytime);

     lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_SAMPLE_ANALYSIS', 'MTH_SAMPLER', p_daytime, lv2_phase);
     ln_return_val := lr_analysis_sample.density;

   -- METHOD= 'ANALYSIS_SP_GRAV' (find density based on specific gravity on last available comp analysis)
   ELSIF (lv2_method = EcDp_Calc_Method.ANALYSIS_SP_GRAV) THEN

     lv2_phase := Ec_Strm_Version.stream_phase(p_object_id,p_daytime, '<=');


      IF lv2_phase = 'OIL' THEN

        lr_analysis := EcDp_Fluid_Analysis.getLastAnalysisSample(p_object_id, 'STRM_OIL_COMP', null, p_daytime, lv2_phase);

        ln_wat_dens := EcDp_System.getWaterDensity(p_daytime => p_daytime);

        ln_return_val := lr_analysis.sp_grav * ln_wat_dens;


      ELSIF lv2_phase in ('GAS', 'CO2') THEN

        lr_analysis := EcDp_Fluid_Analysis.getLastAnalysisSample(p_object_id, 'STRM_GAS_COMP', null, p_daytime, lv2_phase);

        ln_air_dens := EcDp_System.getAirDensity(p_daytime => p_daytime);

        ln_return_val := lr_analysis.sp_grav * ln_air_dens;


      ELSE -- Not supported

        ln_return_val := NULL;

      END IF;


    -- METHOD= 'ALLOCATED' ( Find mass and volume using net_mass and net_vol from allocated figures)
    ELSIF (lv2_method = EcDp_Calc_Method.ALLOCATED) THEN

    ln_return_val := calcNetStdDens (
    p_object_id,
    p_daytime,
    EcDp_Calc_Method.ALLOCATED);

    -- METHOD= 'REF_STREAM' ( Find density from a reference stream density )
    ELSIF (lv2_method = EcDp_Calc_Method.REF_STREAM) THEN

    ln_return_val := getStdDensRefStream (
    p_object_id,
    p_daytime);

   -- METHOD= 'MEASURED_API'
   ELSIF (lv2_method = EcDp_Calc_Method.MEASURED_API) THEN
      IF lv2_strm_meter_method = 'EVENT' THEN
         FOR curEvent IN c_strm_event_single(lv2_stream_object_id, p_daytime) LOOP
            IF (131.5 + curEvent.corr_api) = 0 THEN
               ln_return_val := null;
            ELSE
               ln_return_val := (141.5 * 1000) /
                                (131.5 + curEvent.corr_api);
            END IF;
         END LOOP;

         IF ln_return_val IS NULL THEN
            FOR curEvent IN c_strm_transport_event_single(lv2_stream_object_id, p_daytime) LOOP
               IF (131.5 + curEvent.corr_api) = 0 THEN
                  ln_return_val := null;
               ELSE
                  ln_return_val := (141.5 * 1000) /
                                   (131.5 + curEvent.corr_api);
               END IF;
            END LOOP;
         END IF;
      END IF;

   -- METHOD= 'USER_EXIT'
   ELSIF  (substr(lv2_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN

      ln_return_val := ue_stream_fluid.getStdDens(p_object_id, p_daytime);

   -- Default is reference value
   ELSE

      ln_return_val := NULL;

   END IF;

   RETURN ln_return_val;

END findStdDens;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findWatDens
-- Description    : Returns the density of the produced water for a
--                  given stream and day
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Get system value for water density.
--
---------------------------------------------------------------------------------------------------
FUNCTION findWatDens (
     p_object_id    stream.object_id%TYPE,
     p_daytime      DATE)

RETURN NUMBER
--</EC-DOC>
IS

BEGIN

   RETURN Ecdp_System.getWaterDensity(NULL, p_daytime);

END findWatDens;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findWatMass
-- Description    : Returns the water mass for a given stream and period
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions: EC_STRM_VERSION....
--                  ECDP_STREAM_MEASURED.GETWATMASS
--
-- Configuration
-- required       :
--
-- Behaviour      : Alternative STRM_VERSION....:
--      (EcDp_Stream_Attribute.WAT_MASS_METHOD):
--                 1. 'MEASURED': Find water_mass using data from strm_day_stream only.
--                 2. 'CALCULATED': Find water mass using grs_mass and bsw_w
--                 3. 'USER_EXIT'
--
---------------------------------------------------------------------------------------------------
FUNCTION findWatMass (
     p_object_id      stream.object_id%TYPE,
     p_fromday        DATE,
     p_today          DATE DEFAULT NULL,
     p_method         VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS
  CURSOR c_system_days IS
  SELECT daytime
  FROM system_days
  WHERE  daytime BETWEEN p_fromday AND Nvl(p_today, p_fromday);

  CURSOR c_strm_transport_event_single(cp_object_id VARCHAR2, cp_daytime DATE) IS
  SELECT *
  FROM strm_transport_event
  WHERE ((object_id = cp_object_id) OR (stream_id = cp_object_id))
  AND daytime = cp_daytime;

  ln_grs_mass       NUMBER;
  ln_bsw_wt       NUMBER;
  ln_return_val  NUMBER;
  lv2_method            VARCHAR2(32);
  lv2_strm_meter_freq  VARCHAR2(300);
  lv2_strm_meter_method  VARCHAR2(300);
  lv2_aggregate_flag   VARCHAR2(2);
  ld_daytime         DATE;
  ld_fromday         DATE;
  ld_today           DATE;
  lv2_grs_method    VARCHAR2(32);
  lb_first_iteration   BOOLEAN;
  ln_net_mass       NUMBER;

BEGIN

   -- In case we in the future want to do something special about production day
   ld_fromday := p_fromday;
   ld_today := p_today;

   -- Determine which method to use
   lv2_method := Nvl(p_method,
                     ec_strm_version.water_mass_method(
                                                p_object_id,
                                                p_fromday,
                                                '<='));

   -- Find this streams strm_meter_freq
   lv2_strm_meter_freq := NVL(ec_strm_version.STRM_METER_FREQ(p_object_id, ld_fromday, '<='),'');

   -- Find this streams aggregate_flag
   lv2_aggregate_flag := NVL(ec_strm_version.aggregate_flag(p_object_id, ld_fromday, '<='),'NA');

   -- Find this streams meter method
   lv2_strm_meter_method := NVL(ec_strm_version.strm_meter_method(p_object_id, ld_fromday, '<='),'');

   -- Find water_mass using data from strm_day_stream only.
   IF (lv2_method = EcDp_Calc_Method.MEASURED) THEN
     IF lv2_strm_meter_freq = 'DAY' OR lv2_aggregate_flag = 'Y' THEN
       ln_return_val := Ec_Strm_day_stream.math_water_mass(
                                                            p_object_id,
                                                            ld_fromday,
                                                            ld_today);

     ELSIF lv2_strm_meter_freq = 'MTH' THEN
       ln_return_val := Ec_Strm_mth_stream.math_water_mass(
                                                          p_object_id,
                                                          ld_fromday,
                                                            ld_today);

     -- TODO. Today water mass stored on strm_event is not supported.
     ELSE  -- undefined lv2_strm_meter_freq

       ln_return_val := NULL;

     END IF;

   ELSIF (lv2_method = EcDp_Calc_Method.GROSS_BSW) THEN
    IF lv2_strm_meter_method = 'EVENT' THEN
      lv2_grs_method := NVL(p_method,
      ec_strm_version.GRS_MASS_METHOD(
                  p_object_id,
                  p_fromday,
                  '<='));

      -- Find net_vol using event based gross volume and bsw from truck transport data
        IF (lv2_grs_method = EcDp_Calc_Method.MEASURED_TRUCKED) THEN
         IF ld_today IS NULL THEN -- test if it is a single event record value to be returned
           ln_return_val := NULL;  -- this is not possible.
         ELSE -- looking for sum of event values over a given period
           lb_first_iteration:= TRUE;
           FOR curEvent2 IN c_strm_transport_event (p_object_id, ld_fromday, ld_today) LOOP
             ln_net_mass :=  Ecbp_Truck_Ticket.findNetStdMass(curEvent2.Event_No);
             IF lb_first_iteration THEN
               lb_first_iteration := FALSE;
               ln_return_val := ln_net_mass;
             ELSE
               ln_return_val := ln_return_val + ln_net_mass;
             END IF;
           END LOOP;
         END IF;
        END IF; -- IF (lv2_grs_method = EcDp_Calc_Method.MEASURED_TRUCKED)


    ELSE

      --Calculate mass and summarise day for day.
      FOR mycur2 IN c_system_days LOOP

        ln_bsw_wt := getBswWeightFrac(
                                    p_object_id,
                                     mycur2.daytime);

        ln_grs_mass := EcDp_Stream_Measured.getGrsStdMass(
                                                          p_object_id,
                                                          mycur2.daytime,
                                                          NULL);

        -- If summarizing over a time period, count missing grs_mass and bsw_wt values as 0
        IF ln_bsw_wt IS NULL AND p_fromday <> p_today THEN
          ln_bsw_wt := 0;
        END IF;

        IF ln_grs_mass IS NULL AND p_fromday <> p_today THEN
          ln_grs_mass := 0;
        END IF;

        -- If no liquid and bsw_wt is unknown, mass is also 0
        IF ln_grs_mass = 0 AND ln_bsw_wt IS NULL THEN
          ln_bsw_wt := 0;
        END IF;

        ln_return_val := Nvl(ln_return_val,0) + ln_grs_mass * ln_bsw_wt;

      END LOOP;
    END IF;   --IF lv2_strm_meter_method = 'EVENT'

  ELSIF (lv2_method = EcDp_Calc_Method.VOLUME_DENSITY) THEN
    FOR mycur3 IN c_system_days LOOP
      ln_return_val :=  Nvl(ln_return_val,0) + Nvl(findWatVol(p_object_id,mycur3.daytime) * findWatdens(p_object_id,mycur3.daytime),0);

    END LOOP;

  ELSIF (lv2_method = EcDp_Calc_Method.GRS_MINUS_NET) THEN
    FOR mycur4 IN c_system_days LOOP
      ln_return_val :=  Nvl(ln_return_val,0) + Nvl(findGrsStdMass(p_object_id,mycur4.daytime) - findNetStdMass(p_object_id,mycur4.daytime),0);
    END LOOP;

  -- User Exit
  ELSIF  (substr(lv2_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN

    ln_return_val := ue_stream_fluid.getWatMass(p_object_id, p_fromday,p_today);

  ELSE -- Default

    ln_return_val := NULL;

  END IF;

  RETURN ln_return_val;

END findWatMass;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findWatVol
-- Description    : Returns the water volume for a given stream and period
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--                  EC_STRM_VERSION....
--                  ECDP_STREAM_MEASURED.GETWATVOL
--                  ECBP_STREAM_FLUID.CALCWATVOL
--                  ECBP_STREAM_FLUID.FINDGRSSTDVOL
--
-- Configuration
-- required       :
--
-- Behaviour      : Alternative STRM_VERSION....
--                  (EcDp_Stream_Attribute.WAT_VOL_METHOD):
--                 1. 'MEASURED': Find bsw based on measured figures.
--                 2. 'CALCULATED': Find water_vol using water_mass and wat_density functions.
--                 3. 'GROSS_BSW':  Find water vol using the diff between gross and net oil
--                                    (the bsw is all considered as water).
--                 4. 'USER_EXIT'
--
---------------------------------------------------------------------------------------------------
FUNCTION findWatVol (
     p_object_id    stream.object_id%TYPE,
     p_fromday      DATE,
     p_today        DATE DEFAULT NULL,
     p_method       VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

  -- pwel event inventory
  CURSOR c_pwel_event_inventory(cp_object_id VARCHAR2, cp_fromday DATE, cp_today DATE) IS
  SELECT *
  FROM pwel_event_inventory
  WHERE unload_stream_id = cp_object_id
  AND Nvl(unload_day,TRUNC(unload_daytime)) BETWEEN cp_fromday AND cp_today
  ORDER BY daytime ASC;

  -- pwel event inventory - single event
  CURSOR c_pwel_event_inventory_single(cp_object_id VARCHAR2, cp_fromday DATE) IS
  SELECT *
  FROM pwel_event_inventory
  WHERE unload_stream_id = cp_object_id
  AND  unload_daytime = cp_fromday
  ORDER BY daytime ASC;

  lv2_method              VARCHAR2(30);
  lv2_grs_method          VARCHAR2(32);
  ln_bsw                  NUMBER;
  ln_grs_vol              NUMBER;
  lb_first_iteration      BOOLEAN;
  ln_return_val           NUMBER;
  ln_wat_mass             NUMBER;
  ln_wat_dens             NUMBER;
  lv2_strm_meter_freq     VARCHAR2(300);
  lv2_strm_meter_method   VARCHAR2(300);
  lv2_aggregate_flag      VARCHAR2(2);
  ln_wat_density          NUMBER;
  lv2_stream_object_id    stream.object_id%TYPE;
  lv2_tank_object_id      tank.object_id%TYPE;
  ld_fromday              DATE;
  ld_today                DATE;
  ln_net_vol              NUMBER;
  ln_wat_vol              NUMBER;
  lr_strm_version         strm_version%ROWTYPE;

  CURSOR c_system_days IS
  SELECT daytime
  FROM   system_days
  WHERE  daytime BETWEEN p_fromday AND Nvl(p_today, p_fromday);

  CURSOR c_strm_event(cp_object_id VARCHAR2, cp_fromday DATE, cp_today DATE) IS
  SELECT *
  FROM strm_event
  WHERE object_id = cp_object_id
  AND   Nvl(event_day,TRUNC(daytime)) BETWEEN cp_fromday AND cp_today
  ORDER BY daytime ASC;

  CURSOR c_strm_event_single(cp_object_id VARCHAR2, cp_fromday DATE) IS
  SELECT *
  FROM strm_event
  WHERE object_id = cp_object_id
  AND daytime = cp_fromday;

  CURSOR c_strm_transport_event_single(cp_object_id VARCHAR2, cp_daytime DATE) IS
  SELECT ste.event_no
  FROM strm_transport_event ste
  WHERE ((ste.object_id = cp_object_id) OR (ste.stream_id = cp_object_id))
  AND ste.production_day = cp_daytime
  UNION ALL
  SELECT event_no
  FROM object_transport_event ote
  WHERE ((ote.object_id = cp_object_id AND ote.object_type = 'STREAM') OR (ote.to_object_id = cp_object_id AND ote.to_object_type = 'STREAM'))
  AND ote.data_class_name = 'OBJECT_SINGLE_TRANSFER'
  AND ote.production_day = cp_daytime;

BEGIN

  ld_fromday  := p_fromday;
  ld_today    := p_today;

  lv2_stream_object_id := p_object_id;

  lr_strm_version := ec_strm_version.row_by_pk(p_object_id, p_fromday, '<=');

  -- Determine which method to use
  lv2_method := Nvl(p_method, lr_strm_version.WATER_VOL_METHOD);

  -- Find this streams strm_meter_freq
  lv2_strm_meter_freq := NVL(lr_strm_version.STRM_METER_FREQ, '');

  -- Find this streams aggregate_flag
  lv2_aggregate_flag := NVL(lr_strm_version.aggregate_flag, 'NA');

  -- Find this streams meter method
  lv2_strm_meter_method := NVL(lr_strm_version.strm_meter_method, '');

  -- Find water_vol using measured values
  IF (lv2_method = EcDp_Calc_Method.MEASURED) THEN

    IF lv2_strm_meter_freq = 'DAY' OR lv2_aggregate_flag = 'Y' THEN

      ln_return_val := Ec_Strm_day_stream.math_water_vol(
                                                        p_object_id,
                                                        ld_fromday,
                                                        ld_today);

    ELSIF lv2_strm_meter_freq = 'MTH' THEN

      ln_return_val := Ec_Strm_mth_stream.math_water_vol(
                                                        p_object_id,
                                                        ld_fromday,
                                                        ld_today);

    -- TODO. Today water mass stored on strm_event is not supported.
    ELSE  -- undefined lv2_strm_meter_freq

      ln_return_val := NULL;

    END IF;

  -- Find water vol using the diff between gross and net oil (the bsw is all considered as water)
  ELSIF (lv2_method = EcDp_Calc_Method.GROSS_BSW) THEN

    IF lv2_strm_meter_method = 'EVENT' THEN
      lv2_grs_method := NVL(p_method,
      ec_strm_version.GRS_VOL_METHOD(
                p_object_id,
                    p_fromday,
                    '<='));

      -- Find net_vol using event based gross volume and bsw from truck transport data
      IF(lv2_grs_method = EcDp_Calc_Method.MEASURED_TRUCKED) THEN
        IF ld_today IS NULL THEN -- test if it is a single event record value to be returned
          ln_return_val := NULL;  -- this is not possible, use EcBp_Stream_TruckTickets.findWatVol() instead but it cannot be called from here.

        ELSE -- looking for sum of event values over a given period
          lb_first_iteration:= TRUE;

          FOR curEvent2 IN c_strm_transport_event (lv2_stream_object_id, ld_fromday, ld_today) LOOP
            ln_net_vol := Ecbp_Truck_Ticket.findWatVol(curEvent2.event_no);
            IF lb_first_iteration THEN
              lb_first_iteration := FALSE;
              ln_return_val := ln_net_vol;

            ELSE
               ln_return_val := ln_return_val + ln_net_vol;

            END IF;
          END LOOP;
        END IF;

      -- Finding water vol by summarize all unload water vols linked to given load.

      -- Water vol for a truck unload is calculated in screen and hence stored in WATER_VOL column.


      ELSE -- Only event streams based on truck transports supported

        ln_return_val := findGrsStdVol(p_object_id,p_fromday,p_today)
                         - findNetStdVol(p_object_id,p_fromday,p_today);

      END IF;

    ELSIF lv2_strm_meter_freq = 'DAY' OR lv2_aggregate_flag = 'Y' THEN
      -- DAILY RECORDS
      ln_return_val := 0;
      FOR mycur IN c_system_days LOOP
        ln_return_val := ln_return_val +
                         (findGrsStdVol(p_object_id,
                                        mycur.daytime,
                                        mycur.daytime) *
                         getBswVolFrac(p_object_id, mycur.daytime));
      END LOOP;

    ELSIF lv2_strm_meter_freq = 'MTH' THEN
      -- MONTHLY RECORD
      ln_return_val := 0;
      FOR mycur IN c_system_days LOOP
        IF mycur.daytime = TRUNC(mycur.daytime, 'MM') THEN
          ln_return_val := ln_return_val +
                           (findGrsStdVol(p_object_id,
                                          mycur.daytime,
                                          mycur.daytime) *
                           getBswVolFrac(p_object_id, mycur.daytime));
        END IF;
      END LOOP;

    END IF;

  -- Find water vol using the diff between gross and net
  ELSIF (lv2_method = EcDp_Calc_Method.GRS_MINUS_NET) THEN
    ln_return_val := findGrsStdVol(p_object_id, p_fromday, p_today) -
                          findNetStdVol(p_object_id, p_fromday, p_today);

  -- Find water vol from water mass and water density
  ELSIF (lv2_method = EcDp_Calc_Method.MASS_DENSITY) THEN
  ln_return_val := 0;
    FOR mycur2 IN c_system_days LOOP
    ln_wat_density := ecbp_stream_fluid.findwatdens(p_object_id, mycur2.daytime);
      ln_wat_mass := ecbp_stream_fluid.findwatmass(p_object_id, mycur2.daytime);

      IF ln_wat_mass = 0 THEN
    IF (ln_return_val IS NULL) THEN
      ln_return_val := ln_return_val;
    END IF;
    ELSE
        IF (ln_wat_density = 0) THEN
          ln_wat_density := NULL;
      END IF;
        ln_return_val := ln_return_val + ln_wat_mass / ln_wat_density;
      END IF;

    END LOOP;

  ELSIF (lv2_method = EcDp_Calc_Method.TANK_DUAL_DIP) THEN
    ln_return_val := 0;

    -- test if it is a single record or sum over production days to be returned
    IF ld_today IS NULL THEN

      -- Loop over single stream_event record.
      FOR curEvent IN c_strm_event_single(lv2_stream_object_id, ld_fromday) LOOP

        ln_net_vol := EcBp_Tank.findWaterVol(curEvent.tank_object_id,'DUAL_DIP_OPENING',curEvent.daytime) -
                     EcBp_Tank.findWaterVol(curEvent.tank_object_id,'DUAL_DIP_CLOSING',curEvent.daytime);

        ln_return_val :=  Nvl(ln_return_val,0) + Nvl(ln_net_vol,0);

      END LOOP;

    ELSE

      FOR curEvent IN c_strm_event(lv2_stream_object_id, ld_fromday, ld_today) LOOP

        ln_net_vol := EcBp_Tank.findWaterVol(curEvent.tank_object_id,'DUAL_DIP_OPENING',curEvent.daytime) -
                      EcBp_Tank.findWaterVol(curEvent.tank_object_id,'DUAL_DIP_CLOSING',curEvent.daytime);

        ln_return_val :=  Nvl(ln_return_val,0) + Nvl(ln_net_vol,0);

      END LOOP;

    END IF;

  -- Get water from dry gas and WGR (Water Dry Gas Ratio)
  ELSIF (lv2_method = EcDp_Calc_Method.NET_VOL_WGR) THEN

    ln_return_val := findNetStdVol(p_object_id,ld_fromday, ld_today) * findWGR(p_object_id, ld_fromday);


  -- event_well_withdrawn
  ELSIF(lv2_method = EcDp_Calc_Method.WELL_INV_WITHDRAW) THEN

    IF p_today IS NULL THEN

      FOR cur_pwel_event_single IN c_pwel_event_inventory_single(p_object_id, p_fromday) LOOP -- expected only 1 record.
        ln_net_vol := cur_pwel_event_single.GRS_OIL_OUT * (Nvl(cur_pwel_event_single.BSW_OUT, 0));
      END LOOP;

    ELSE -- p_today IS NOT NULL

      ln_net_vol := 0;

      FOR cur_pwel_event_inventory IN c_pwel_event_inventory(p_object_id, p_fromday, p_today) LOOP

        ln_net_vol := ln_net_vol + nvl(cur_pwel_event_inventory.GRS_OIL_OUT * (Nvl(cur_pwel_event_inventory.BSW_OUT, 0)), 0);

      END LOOP;

    END IF;

    ln_return_val := ln_net_vol;

  -- User exit
  ELSIF  (substr(lv2_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN

    ln_return_val := ue_stream_fluid.getWatVol(p_object_id, p_fromday,p_today);

  ELSE

    ln_return_val := NULL;

  END IF;

  RETURN ln_return_val;

END findWatVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findCondVol
-- Description    : Returns the Condensate Volume value
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--                  EC_STRM_VERSION....
--                  ECBP_STREAM_FLUID.findNetStdVol
--                  ECBP_STREAM_FLUID.findCGR
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      : Alternative STRM_VERSION....
--                  (EcDp_Strm_Version.COND_VOL_METHOD):
--                 1. 'NET_VOL_CGR':   Net Vol * CGR .
--                 2. 'USER_EXIT'
--
--
---------------------------------------------------------------------------------------------------
FUNCTION findCondVol (
     p_object_id    stream.object_id%TYPE,
     p_fromday      DATE,
     p_today        DATE DEFAULT NULL,
     p_method       VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

lv2_method           VARCHAR2(30);
ln_return_val NUMBER;
lv2_stream_object_id stream.object_id%TYPE;
ld_fromday           DATE;
ld_today             DATE;

BEGIN

   ld_fromday  := p_fromday;
   ld_today    := p_today;
   lv2_stream_object_id := p_object_id;

   -- Determine which method to use
   lv2_method := Nvl(p_method,
                     ec_strm_version.COND_VOL_METHOD(
                                                      p_object_id,
                                                      p_fromday,
                                                      '<='));

   -- Find cgr using data from strm_reference_value.
   IF (lv2_method = EcDp_Calc_Method.NET_VOL_CGR) THEN

      ln_return_val := findNetStdVol(lv2_stream_object_id, ld_fromday, ld_today) * findCGR(lv2_stream_object_id, ld_fromday);

   -- User exit
   ELSIF  (substr(lv2_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN

       ln_return_val := ue_stream_fluid.getCondVol(p_object_id, p_fromday,p_today);

   ELSE

       ln_return_val := NULL;

   END IF;


   RETURN ln_return_val;

END findCondVol;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGOR()
-- Description    : Returns the GOR value for a stream object.
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findGOR(
  p_object_id stream.object_id%TYPE,
  p_fromday   DATE,
  p_today     DATE DEFAULT NULL,
  p_method    VARCHAR2 DEFAULT NULL)
RETURN NUMBER
IS
  lv2_method            VARCHAR2(30);
  lv2_strm_meter_freq   VARCHAR2(30);
  lv2_aggregate_flag    VARCHAR2(30);
  ln_return_val         NUMBER;
BEGIN

  lv2_method := Nvl(p_method, ec_strm_version.gor_method(p_object_id,p_fromday,'<='));

  IF (lv2_method = EcDp_Calc_Method.MEASURED) THEN
    lv2_strm_meter_freq := NVL(ec_strm_version.STRM_METER_FREQ(p_object_id, p_fromday, '<='),'');
    lv2_aggregate_flag := NVL(ec_strm_version.aggregate_flag(p_object_id, p_fromday, '<='),'NA');
    IF lv2_strm_meter_freq = 'DAY' OR lv2_aggregate_flag = 'Y' THEN
      ln_return_val := ec_strm_day_stream.gor(p_object_id, p_fromday);
    ELSIF lv2_strm_meter_freq = 'MTH' THEN
      ln_return_val := ec_strm_mth_stream.gor(p_object_id, p_fromday);
    ELSE
      ln_return_val := NULL;
    END IF;
  ELSIF (lv2_method = EcDp_Calc_Method.REF_VALUE) THEN
    ln_return_val := ec_strm_reference_value.gor(p_object_id, p_fromday, '<=');
  ELSE
    ln_return_val := NULL;
  END IF;
  RETURN ln_return_val;

END findGOR;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findCGR
-- Description    : Returns the Condensate dry Gas Ratio value
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--                  EC_STRM_VERSION....
--                  EC_STRM_REFERENCE_VALUE
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      : Alternative STRM_VERSION....
--                  (EcDp_Strm_Version.COND_VOL_METHOD):
--                 1. 'REF_VALUE':   Find water_vol using data from Stream Reference Value.
--
--
---------------------------------------------------------------------------------------------------
FUNCTION findCGR (
     p_object_id    stream.object_id%TYPE,
     p_fromday      DATE,
     p_today        DATE DEFAULT NULL,
     p_method       VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

lv2_method           VARCHAR2(30);
ln_return_val NUMBER;
lv2_stream_object_id stream.object_id%TYPE;
ld_fromday           DATE;
ld_today             DATE;

BEGIN

   ld_fromday  := p_fromday;
   ld_today    := p_today;
   lv2_stream_object_id := p_object_id;

   -- Determine which method to use
   lv2_method := Nvl(p_method,
                     ec_strm_version.cgr_method(
                                                      p_object_id,
                                                      p_fromday,
                                                      '<='));

   -- Find cgr using data from strm_reference_value.
   IF (lv2_method = EcDp_Calc_Method.REF_VALUE) THEN

       ln_return_val := ec_strm_reference_value.CGR(lv2_stream_object_id, ld_fromday, '<=');

   ELSE

      ln_return_val := NULL;

   END IF;

   RETURN ln_return_val;

END findCGR;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findWGR
-- Description    : Returns the Condensate dry Gas Ratio value
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--                  EC_STRM_VERSION....
--                  EC_STRM_REFERENCE_VALUE
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      : Alternative STRM_VERSION....
--                  (EcDp_Strm_Version.WGR_METHOD):
--                 1. 'REF_VALUE':   Find WGR using data from Stream Reference ValuE.
--
--
---------------------------------------------------------------------------------------------------
FUNCTION findWGR (
     p_object_id    stream.object_id%TYPE,
     p_fromday      DATE,
     p_today        DATE DEFAULT NULL,
     p_method       VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

lv2_method           VARCHAR2(30);
ln_return_val NUMBER;
lv2_stream_object_id stream.object_id%TYPE;
ld_fromday           DATE;
ld_today             DATE;

BEGIN

   ld_fromday  := p_fromday;
   ld_today    := p_today;
   lv2_stream_object_id := p_object_id;

   -- Determine which method to use
   lv2_method := Nvl(p_method,
                     ec_strm_version.WGR_METHOD(
                                                      p_object_id,
                                                      p_fromday,
                                                      '<='));

   -- Find wgr using data from strm_reference_value.
   IF (lv2_method = EcDp_Calc_Method.REF_VALUE) THEN

       ln_return_val := ec_strm_reference_value.WGR(lv2_stream_object_id, ld_fromday, '<=');

   ELSE

      ln_return_val := NULL;

   END IF;

   RETURN ln_return_val;

END findWGR;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findWDF
-- Description    : Returns the Condensate dry Gas Ratio value
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--                  EC_STRM_VERSION....
--                  EC_STRM_REFERENCE_VALUE
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      : Alternative STRM_VERSION....
--                  (EcDp_Strm_Version.WDF_METHOD):
--                 1. 'REF_VALUE':   Find WDF using data from Stream Reference ValuE.
--
--
---------------------------------------------------------------------------------------------------
FUNCTION findWDF (
     p_object_id    stream.object_id%TYPE,
     p_fromday      DATE,
     p_today        DATE DEFAULT NULL,
     p_method       VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

lv2_method           VARCHAR2(30);
ln_return_val NUMBER;
lv2_stream_object_id stream.object_id%TYPE;
ld_fromday           DATE;
ld_today             DATE;

BEGIN

   ld_fromday  := p_fromday;
   ld_today    := p_today;
   lv2_stream_object_id := p_object_id;

   -- Determine which method to use
   lv2_method := Nvl(p_method,
                     ec_strm_version.WDF_METHOD(
                                                      p_object_id,
                                                      p_fromday,
                                                      '<='));

   -- Find wdf using data from strm_reference_value.
   IF (lv2_method = EcDp_Calc_Method.REF_VALUE) THEN

             ln_return_val := ec_strm_reference_value.WDF(lv2_stream_object_id, ld_fromday, '<=');

   ELSE

      ln_return_val := NULL;

   END IF;

   RETURN ln_return_val;

END findWDF;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : find_grs_vol_by_pc
-- Description    : Returns the summation of Daily Gross Volume
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--                                                                                                                        --
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION find_grs_vol_by_pc(
p_object_id VARCHAR2,
p_profit_centre_id VARCHAR2,
p_production_day DATE) RETURN NUMBER
--</EC-DOC>
IS

ln_ret_val NUMBER;

BEGIN
     SELECT SUM(ste.grs_vol) INTO ln_ret_val
     FROM strm_transport_event ste
     WHERE ste.object_id = p_object_id
     AND ste.production_day = p_production_day
     AND ste.profit_centre_id = p_profit_centre_id;
RETURN ln_ret_val;
END find_grs_vol_by_pc;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : find_net_vol_by_pc
-- Description    : Returns the summation of Daily Net Volume
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--                                                                                                                        --
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION find_net_vol_by_pc(
p_object_id VARCHAR2,
p_profit_centre_id VARCHAR2,
p_production_day DATE) RETURN NUMBER
--</EC-DOC>
IS

ln_ret_val NUMBER;
BEGIN
     SELECT SUM(ecbp_truck_ticket.findNetStdVol(ste.event_no)) INTO ln_ret_val
     FROM strm_transport_event ste
     WHERE ste.object_id = p_object_id
     AND ste.production_day = p_production_day
     AND ste.profit_centre_id = p_profit_centre_id;
RETURN ln_ret_val;
END find_net_vol_by_pc;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : find_water_vol_by_pc
-- Description    : Returns the summation of Daily Water Volume
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--                                                                                                                        --
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION find_water_vol_by_pc(
p_object_id VARCHAR2,
p_profit_centre_id VARCHAR2,
p_production_day DATE) RETURN NUMBER
--</EC-DOC>
IS

ln_ret_val NUMBER;
BEGIN
     SELECT SUM(ecbp_truck_ticket.findWatVol(ste.event_no)) INTO ln_ret_val
     FROM strm_transport_event ste
     WHERE ste.object_id = p_object_id
     AND ste.production_day = p_production_day
     AND ste.profit_centre_id = p_profit_centre_id;
RETURN ln_ret_val;
END find_water_vol_by_pc;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getBswVolFrac
-- Description    : Returns the bsw volume fraction of a given stream and day.
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--                  EC_STRM_VERSION....
--                  EC_STRM_DAY_STREAM.BS_W
--                  ECDP_STREAM_ANALYSIS.GETBSWVOLFRAC
--                  ECDP_STREAM_ANALYSIS.GETCARGOBSWVOLFRAC
--                  ECDP_STREAM_ANALYSIS.GETCONDWATFRAC
--                  ECBP_STREAM_FLUID.FINDGRSSTDVOL
--                  ECBP_STREAM_FLUID.FINDWATVOL
--                  ECBP_STREAM.FINDREFANALYSISSTREAM
--                  ECBP_STREAM_FLUID.GETBSWVOLFRAC
--
-- Configuration
-- required       :
--
-- Behaviour      : Alternative STRM_VERSION.... (BSW_VOL_METHOD):
--
--                 1. 'MEASURED': Find bsw based on measured figures.
--                 2. 'ANALYSIS': Get bsw from analysis.
--                 3. 'CARGO_ANALYSIS': Get bsw from cargo analysis.
--                 4. 'COND_WATER_FRAC': Get bsw from condensate water analysis.
--                 5. 'CALCULATED': Get bsw from gross volumes.
--                 6. 'REF_STREAM'
--                 7. 'SAMPLE_ANALYSIS'. Get BSW from stream sample analysis with the latest approved analysis_status or analysis_status = NULL.
--
---------------------------------------------------------------------------------------------------
FUNCTION getBswVolFrac(
      p_object_id    stream.object_id%TYPE,
      p_daytime     DATE,
      p_method      VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_strm_event(p_object_id VARCHAR2) IS
SELECT *
FROM strm_event
WHERE object_id = p_object_id
AND   daytime = p_daytime;


CURSOR c_strm_transport_event_single(cp_object_id VARCHAR2, cp_daytime DATE) IS
SELECT bs_w
FROM strm_transport_event
WHERE ((object_id = cp_object_id) OR (stream_id = cp_object_id))
AND production_day = cp_daytime
UNION ALL
SELECT bs_w
FROM object_transport_event ote
WHERE ((ote.object_id = cp_object_id AND ote.object_type = 'STREAM') OR (ote.to_object_id = cp_object_id AND ote.to_object_type = 'STREAM'))
AND ote.data_class_name = 'OBJECT_SINGLE_TRANSFER'
AND production_day  = cp_daytime;


lv2_method    VARCHAR2(32);
lv2_grs_method VARCHAR2(32);
lv2_ref_stream VARCHAR2(32);
ln_return_val NUMBER;
ln_grs_vol    NUMBER;
ln_wat_vol    NUMBER;
ln_meas_id NUMBER;
lv2_stream_object_id  stream.object_id%TYPE;
lv2_strm_meter_freq  VARCHAR2(300);
lv2_strm_meter_method  VARCHAR2(300);
lv2_aggregate_flag   VARCHAR2(2);
lv2_analysis_ref_id stream.object_id%TYPE;
lr_analysis_sample object_fluid_analysis%ROWTYPE;
lv2_phase     VARCHAR2(32);

BEGIN

   -- Find this streams strm_meter_freq
   lv2_strm_meter_freq := NVL(ec_strm_version.STRM_METER_FREQ(p_object_id, p_daytime, '<='),'');

   -- Find this streams aggregate_flag
   lv2_aggregate_flag := NVL(ec_strm_version.aggregate_flag(p_object_id, p_daytime, '<='),'NA');

   -- Find this streams meter method
   lv2_strm_meter_method := NVL(ec_strm_version.strm_meter_method(p_object_id, p_daytime, '<='),'');

   lv2_stream_object_id := p_object_id;

   -- Determine which method to use
  lv2_method := NVL(p_method,
        ec_strm_version.BSW_VOL_METHOD(
                    p_object_id,
        p_daytime,
        '<='));

   lv2_phase := Ec_Strm_Version.stream_phase(p_object_id,p_daytime, '<=');

   -- Find bsw using measured values
   IF (lv2_method = EcDp_Calc_Method.MEASURED) THEN

      IF lv2_strm_meter_freq = 'DAY' OR lv2_aggregate_flag = 'Y' THEN

       ln_return_val := ec_strm_day_stream.bs_w(
                                              p_object_id,
                                              p_daytime);

      ELSIF lv2_strm_meter_freq = 'MTH' THEN

       ln_return_val := ec_strm_mth_stream.bs_w(
                                              p_object_id,
                                              p_daytime);

      ELSIF lv2_strm_meter_method = 'EVENT' THEN

         lv2_grs_method := NVL(p_method,
                               ec_strm_version.GRS_VOL_METHOD(
                                                        p_object_id,
                                                              p_daytime,
                                                              '<=')
                                                              );

         IF(lv2_grs_method = EcDp_Calc_Method.MEASURED_TRUCKED) THEN

            FOR curBsw IN c_strm_transport_event_single(p_object_id, p_daytime)  LOOP

               ln_return_val := curBsw.bs_w;

            END LOOP;

         ELSE

            FOR curEvent2 IN c_strm_event(lv2_stream_object_id)  LOOP

               ln_return_val := curEvent2.bs_w;

            END LOOP;

         END IF;

      END IF;


   ELSIF lv2_method = 'SAMPLE_ANALYSIS' THEN

      lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(lv2_stream_object_id, p_daytime);

      lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_SAMPLE_ANALYSIS', null, p_daytime, lv2_phase);
      ln_return_val := lr_analysis_sample.bs_w;

   ELSIF lv2_method = 'SAMPLE_ANALYSIS_SPOT' THEN

      lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(lv2_stream_object_id, p_daytime);

      lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_SAMPLE_ANALYSIS', 'SPOT', p_daytime, lv2_phase);
      ln_return_val := lr_analysis_sample.bs_w;

   ELSIF lv2_method = 'SAMPLE_ANALYSIS_DAY' THEN

      lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(lv2_stream_object_id, p_daytime);

      lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_SAMPLE_ANALYSIS', 'DAY_SAMPLER', p_daytime, lv2_phase);
      ln_return_val := lr_analysis_sample.bs_w;

   ELSIF lv2_method = 'SAMPLE_ANALYSIS_MTH' THEN

      lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(lv2_stream_object_id, p_daytime);

      lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_SAMPLE_ANALYSIS', 'MTH_SAMPLER', p_daytime, lv2_phase);
      ln_return_val := lr_analysis_sample.bs_w;

   ELSIF (lv2_method = EcDp_Calc_Method.COMP_ANALYSIS) THEN

      lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(lv2_stream_object_id, p_daytime);

      lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_OIL_COMP', null, p_daytime, lv2_phase);
      ln_return_val := lr_analysis_sample.bs_w;

   ELSIF (lv2_method = EcDp_Calc_Method.COMP_ANALYSIS_SPOT) THEN

      lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(lv2_stream_object_id, p_daytime);

      lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_OIL_COMP', 'SPOT', p_daytime, lv2_phase);
      ln_return_val := lr_analysis_sample.bs_w;

   ELSIF (lv2_method = EcDp_Calc_Method.COMP_ANALYSIS_DAY) THEN

      lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(lv2_stream_object_id, p_daytime);

      lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_OIL_COMP', 'DAY_SAMPLER', p_daytime, lv2_phase);
      ln_return_val := lr_analysis_sample.bs_w;

   ELSIF (lv2_method = EcDp_Calc_Method.COMP_ANALYSIS_MTH) THEN

      lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(lv2_stream_object_id, p_daytime);

      lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_OIL_COMP', 'MTH_SAMPLER', p_daytime, lv2_phase);
      ln_return_val := lr_analysis_sample.bs_w;

   ELSIF (lv2_method = EcDp_Calc_Method.REF_VALUE) THEN

      ln_return_val := ec_strm_reference_value.BS_W(p_object_id, p_daytime, '<=');


   ELSIF lv2_method = 'ZERO' THEN

      ln_return_val := 0;

   ELSIF (substr(lv2_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN

     ln_return_val := ue_stream_fluid.getBSWVol(p_object_id, p_daytime);

   ELSE

      ln_return_val := NULL;


   END IF;


   RETURN ln_return_val;

END getBswVolFrac;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getBswWeightFrac
-- Description    : Returns the bsw weight fraction of a given stream and day.
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions: ec_strm_version....,
--        EcDp_Stream_Attribute.BSW_WT_METHOD,
--                  EcDp_Calc_Method.MEASURED,
--                  ec_strm_day_stream.bs_w_wt,
--                  EcDp_Calc_Method.ANALYSIS,
--                  EcDp_Stream_Analysis.getBswWeightFrac
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getBswWeightFrac(
      p_object_id   stream.object_id%TYPE,
      p_daytime     DATE,
      p_method      VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_strm_event(p_object_id VARCHAR2) IS
SELECT *
FROM strm_event
WHERE object_id = p_object_id
AND   daytime = p_daytime
;

CURSOR c_strm_transport_event_single(cp_object_id VARCHAR2, cp_daytime DATE) IS
SELECT *
FROM strm_transport_event
WHERE ((object_id = cp_object_id) OR (stream_id = cp_object_id))
AND daytime = cp_daytime;

lv2_method   VARCHAR2(32);
lv2_grs_method VARCHAR2(32);
ln_return_val   NUMBER;
ln_vol_water   NUMBER;
ln_mass_water   NUMBER;
ln_grs_mass   NUMBER;
lv2_stream_object_id  stream.object_id%TYPE;
lv2_strm_meter_freq  VARCHAR2(300);
lv2_strm_meter_method  VARCHAR2(300);
lv2_aggregate_flag   VARCHAR2(2);
lv2_analysis_ref_id stream.object_id%TYPE;
ld_fromday           DATE;
ld_today             DATE;
lb_first_iteration   BOOLEAN;
ln_denom      NUMBER;
ln_result      NUMBER;
lr_analysis_sample object_fluid_analysis%ROWTYPE;
lv2_phase     VARCHAR2(32);

BEGIN

   -- Find this streams strm_meter_freq
   lv2_strm_meter_freq := NVL(ec_strm_version.STRM_METER_FREQ(p_object_id, p_daytime, '<='),'');

   -- Find this streams aggregate_flag
   lv2_aggregate_flag := NVL(ec_strm_version.aggregate_flag(p_object_id, p_daytime, '<='),'NA');

   -- Find this streams meter method
   lv2_strm_meter_method := NVL(ec_strm_version.strm_meter_method(p_object_id, p_daytime, '<='),'');

   lv2_stream_object_id := p_object_id;

   -- Determine which method to use
   lv2_method := NVL(p_method,
                    ec_strm_version.BSW_WT_METHOD(
                                                  p_object_id,
                                                  p_daytime,
                                                  '<='));

   lv2_phase := Ec_Strm_Version.stream_phase(p_object_id,p_daytime, '<=');

   -- Find bs_w wt using data from strm_day_stream only.
   IF (lv2_method = EcDp_Calc_Method.MEASURED) THEN

      IF lv2_strm_meter_freq = 'DAY' OR lv2_aggregate_flag = 'Y' THEN

          ln_return_val := ec_strm_day_stream.bs_w_wt(
                                                    p_object_id,
                                                     p_daytime);

      ELSIF lv2_strm_meter_freq = 'MTH' THEN

          ln_return_val := ec_strm_mth_stream.bs_w_wt(
                                                    p_object_id,
                                                     p_daytime);

      ELSIF lv2_strm_meter_method = 'EVENT' THEN

        lv2_grs_method := NVL(p_method,
                               ec_strm_version.GRS_MASS_METHOD(
                                                        p_object_id,
                                                              p_daytime,
                                                              '<=')
                                                              );

         IF(lv2_grs_method = EcDp_Calc_Method.MEASURED_TRUCKED) THEN

            FOR curBsw IN c_strm_transport_event_single(p_object_id, p_daytime)  LOOP

               ln_return_val := curBsw.bs_w_wt;

            END LOOP;

         ELSE

            FOR curEvent IN c_strm_event(lv2_stream_object_id)  LOOP

               ln_return_val := curEvent.bs_w_wt;

            END LOOP;

         END IF;

      END IF;


   ELSIF lv2_method = 'SAMPLE_ANALYSIS' THEN

        lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(lv2_stream_object_id, p_daytime);

        lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_SAMPLE_ANALYSIS', null, p_daytime,lv2_phase);
        ln_return_val := lr_analysis_sample.bs_w_wt;

   ELSIF lv2_method = 'SAMPLE_ANALYSIS_SPOT' THEN

        lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(lv2_stream_object_id, p_daytime);

        lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_SAMPLE_ANALYSIS', 'SPOT', p_daytime,lv2_phase);
        ln_return_val := lr_analysis_sample.bs_w_wt;

   ELSIF lv2_method = 'SAMPLE_ANALYSIS_DAY' THEN

        lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(lv2_stream_object_id, p_daytime);

        lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_SAMPLE_ANALYSIS', 'DAY_SAMPLER', p_daytime,lv2_phase);
        ln_return_val := lr_analysis_sample.bs_w_wt;

   ELSIF lv2_method = 'SAMPLE_ANALYSIS_MTH' THEN

        lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(lv2_stream_object_id, p_daytime);

        lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_SAMPLE_ANALYSIS', 'MTH_SAMPLER', p_daytime,lv2_phase);
        ln_return_val := lr_analysis_sample.bs_w_wt;

     -- METHOD= 'COMP_ANALYSIS' (get bsw from analysis)
     ELSIF (lv2_method = EcDp_Calc_Method.COMP_ANALYSIS) THEN

        lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(lv2_stream_object_id, p_daytime);

        lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_OIL_COMP', null, p_daytime,lv2_phase);
        ln_return_val := lr_analysis_sample.bs_w_wt;

   -- METHOD= 'COMP_ANALYSIS_SPOT'
   ELSIF (lv2_method = EcDp_Calc_Method.COMP_ANALYSIS_SPOT) THEN

        lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(lv2_stream_object_id, p_daytime);

        lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_OIL_COMP', 'SPOT', p_daytime,lv2_phase);
        ln_return_val := lr_analysis_sample.bs_w_wt;

   -- METHOD= 'COMP_ANALYSIS_DAY'
   ELSIF (lv2_method = EcDp_Calc_Method.COMP_ANALYSIS_DAY) THEN

        lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(lv2_stream_object_id, p_daytime);

        lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_OIL_COMP', 'DAY_SAMPLER', p_daytime,lv2_phase);
        ln_return_val := lr_analysis_sample.bs_w_wt;

   -- METHOD= 'COMP_ANALYSIS_MTH'
   ELSIF (lv2_method = EcDp_Calc_Method.COMP_ANALYSIS_MTH) THEN

        lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(lv2_stream_object_id, p_daytime);

        lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_OIL_COMP', 'MTH_SAMPLER', p_daytime,lv2_phase);
        ln_return_val := lr_analysis_sample.bs_w_wt;

     ELSIF (lv2_method = EcDp_Calc_Method.REF_VALUE) THEN

        ln_return_val := ec_strm_reference_value.BS_W_WT(p_object_id, p_daytime, '<=');

     ELSIF (lv2_method = 'BSW_VOL_FRAC') THEN

        lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(lv2_stream_object_id, p_daytime);

        lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_OIL_COMP', null, p_daytime,lv2_phase);

        ln_result := getBswVolFrac(p_object_id, p_daytime);

        IF (ln_result <> 0) THEN

            ln_denom := 1 - lr_analysis_sample.sp_grav + lr_analysis_sample.sp_grav/ln_result;

            IF (ln_denom <> 0) THEN
               ln_return_val := 1 / ln_denom;

            ELSE
               ln_return_val := NULL;
            END IF;

        ELSE
            ln_return_val := NULL;
        END IF;

   ELSIF  lv2_method = 'ZERO' THEN

     ln_return_val := 0;

   ELSIF  (substr(lv2_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN

    ln_return_val := ue_stream_fluid.getBSWWT(p_object_id, p_daytime);

  ELSE

    ln_return_val := NULL;

  END IF;

  RETURN ln_return_val;

END getBswWeightFrac;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSaltWeightFrac
-- Description    : Returns the salt weight fraction of a given stream and day.
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions: ec_strm_version....
--                  EcDp_Calc_Method.MEASURED,
--                  ec_strm_day_stream.salt_mass,
--
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getSaltWeightFrac(
      p_object_id   stream.object_id%TYPE,
      p_daytime     DATE,
      p_method      VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_strm_event(p_object_id VARCHAR2) IS
SELECT *
FROM strm_event
WHERE object_id = p_object_id
AND   daytime = p_daytime
;

CURSOR c_strm_transport_event_single(cp_object_id VARCHAR2, cp_daytime DATE) IS
SELECT *
FROM strm_transport_event
WHERE ((object_id = cp_object_id) OR (stream_id = cp_object_id))
AND daytime = cp_daytime;

lv2_method   VARCHAR2(32);
ln_return_val   NUMBER;
lv2_strm_meter_freq  VARCHAR2(300);
lv2_strm_meter_method  VARCHAR2(300);
lv2_aggregate_flag   VARCHAR2(2);
lv2_stream_object_id  stream.object_id%TYPE;
ln_val NUMBER;
lv2_analysis_ref_id stream.object_id%TYPE;
ln_result   NUMBER;
lr_analysis_sample object_fluid_analysis%ROWTYPE;
lv2_phase   VARCHAR2(32);

BEGIN

   -- Find this streams strm_meter_freq
   lv2_strm_meter_freq := NVL(ec_strm_version.STRM_METER_FREQ(p_object_id, p_daytime, '<='),'');

   -- Find this streams aggregate_flag
   lv2_aggregate_flag := NVL(ec_strm_version.aggregate_flag(p_object_id, p_daytime, '<='),'NA');

   -- Find this streams meter method
   lv2_strm_meter_method := NVL(ec_strm_version.strm_meter_method(p_object_id, p_daytime, '<='),'');

   lv2_stream_object_id := p_object_id;

   -- Determine which method to use
   lv2_method := NVL(p_method,
                    ec_strm_version.SALT_WT_METHOD(
                                                  p_object_id,
                                                  p_daytime,
                                                  '<='));


   lv2_phase := Ec_Strm_Version.stream_phase(p_object_id,p_daytime, '<=');

   -- Find bs_w wt using data from strm_day_stream only.
   IF (lv2_method = EcDp_Calc_Method.MEASURED) THEN

      IF lv2_strm_meter_freq = 'DAY' OR lv2_aggregate_flag = 'Y' THEN

         ln_return_val := ec_strm_day_stream.salt_mass(p_object_id, p_daytime);

         IF (ln_return_val is null) THEN
            ln_val := EcBp_Stream_Fluid.findGrsStdMass(p_object_id, p_daytime);
            IF (ln_val = 0) THEN
               ln_return_val := 0;
            ELSE
               ln_return_val := (ec_strm_day_stream.salt(p_object_id,p_daytime) * EcBp_Stream_Fluid.findGrsStdVol(p_object_id, p_daytime)) /
                                ln_val;
            END IF;
         END IF;

      ELSIF lv2_strm_meter_freq = 'MTH' THEN

          ln_return_val := ec_strm_mth_stream.salt(
                                                  p_object_id,
                                         p_daytime);

      ELSIF lv2_strm_meter_method = 'EVENT' THEN

         FOR curEvent IN c_strm_event(lv2_stream_object_id)  LOOP

             ln_return_val := curEvent.salt;

         END LOOP;
      END IF;

      ELSIF lv2_method = 'SAMPLE_ANALYSIS' THEN

        lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(lv2_stream_object_id, p_daytime);

        lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_SAMPLE_ANALYSIS', null, p_daytime, lv2_phase);
        ln_return_val := lr_analysis_sample.salt;

     ELSIF lv2_method = 'SAMPLE_ANALYSIS_SPOT' THEN

        lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(lv2_stream_object_id, p_daytime);

        lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_SAMPLE_ANALYSIS', 'SPOT', p_daytime, lv2_phase);
        ln_return_val := lr_analysis_sample.salt;

     ELSIF lv2_method = 'SAMPLE_ANALYSIS_DAY' THEN

        lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(lv2_stream_object_id, p_daytime);

        lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_SAMPLE_ANALYSIS', 'DAY_SAMPLER', p_daytime, lv2_phase);
        ln_return_val := lr_analysis_sample.salt;

     ELSIF lv2_method = 'SAMPLE_ANALYSIS_MTH' THEN

        lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(lv2_stream_object_id, p_daytime);

        lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_SAMPLE_ANALYSIS', 'MTH_SAMPLER', p_daytime, lv2_phase);
        ln_return_val := lr_analysis_sample.salt;

     -- METHOD= 'COMP_ANALYSIS' (get bsw from analysis)
     ELSIF (lv2_method = EcDp_Calc_Method.COMP_ANALYSIS) THEN

        lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(lv2_stream_object_id, p_daytime);

        lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_OIL_COMP', null, p_daytime, lv2_phase);
        ln_return_val := lr_analysis_sample.salt;

     -- METHOD= 'COMP_ANALYSIS_SPOT'
     ELSIF (lv2_method = EcDp_Calc_Method.COMP_ANALYSIS_SPOT) THEN

        lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(lv2_stream_object_id, p_daytime);

        lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_OIL_COMP', 'SPOT', p_daytime, lv2_phase);
        ln_return_val := lr_analysis_sample.salt;

     -- METHOD= 'COMP_ANALYSIS_DAY'
     ELSIF (lv2_method = EcDp_Calc_Method.COMP_ANALYSIS_DAY) THEN

        lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(lv2_stream_object_id, p_daytime);

        lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_OIL_COMP', 'DAY_SAMPLER', p_daytime, lv2_phase);
        ln_return_val := lr_analysis_sample.salt;

     -- METHOD= 'COMP_ANALYSIS_MTH'
     ELSIF (lv2_method = EcDp_Calc_Method.COMP_ANALYSIS_MTH) THEN

        lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(lv2_stream_object_id, p_daytime);

        lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_OIL_COMP', 'MTH_SAMPLER', p_daytime, lv2_phase);
        ln_return_val := lr_analysis_sample.salt;

     ELSIF (lv2_method = 'DENSITY') THEN

        lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(lv2_stream_object_id, p_daytime);

        lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_OIL_COMP', null, p_daytime, lv2_phase);

        ln_result := (lr_analysis_sample.sp_grav * findWatDens(lv2_analysis_ref_id, p_daytime));

        IF (ln_result <> 0) THEN
           ln_return_val := ec_strm_day_stream.salt(lv2_analysis_ref_id, p_daytime) /ln_result;

        ELSE
           ln_return_val := NULL;
        END IF;

   -- Method == 'USER_EXIT'
   ELSIF (substr(lv2_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN

      ln_return_val := ue_stream_fluid.getSaltWT(p_object_id, p_daytime);

   ELSE

    ln_return_val := NULL;

   END IF;

   RETURN ln_return_val;

END getSaltWeightFrac;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getStdDensCompAnalysis
-- Description    : Returns the standard density to use for a given stream
--                  and day using data from a
--                  component analysis of  type COMP.
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions: ECDP_STREAM.GETSTREAMPHASE
--                  ECDP_STREAM_FLUID.GETMAXSTREAMCONDENS
--                  ECDP_STREAM_FLUID.GETMAXSTREAMGASDENS
--                  ECDP_STREAM_FLUID.GETMAXSTREAMOILDENS
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

FUNCTION getStdDensCompAnalysis (
       p_object_id     stream.object_id%TYPE,
       p_daytime       DATE,
       p_analysis_type VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS

ln_return_val  NUMBER;
lv2_fluid_type VARCHAR2(32);

BEGIN

   lv2_fluid_type := Ec_Strm_Version.stream_phase(p_object_id,p_daytime, '<=');



   IF (lv2_fluid_type = 'COND') THEN

      ln_return_val := EcDp_Stream_Fluid.getMaxStreamConDens(
                                                            p_object_id,
                                                            p_daytime,
                                                            p_analysis_type);


   ELSIF (lv2_fluid_type = 'GAS') THEN

      ln_return_val := EcDp_Stream_Fluid.getMaxStreamGasDens(
                                                            p_object_id,
                                                            p_daytime,
                                                            p_analysis_type);

   ELSE -- TODO: This will return crude density if existing for
        -- for water. Water is not handled this sequence
      ln_return_val := EcDp_Stream_Fluid.getMaxStreamOilDens(
                                                            p_object_id,
                                                            p_daytime,
                                                            p_analysis_type);

   END IF;

   RETURN ln_return_val;

END getStdDensCompAnalysis;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getStdDensFromApiAnalysis                                                    --
-- Description    : Returns the last available standard density based on API                     --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions: EC_STRM_OIL_ANALYSIS.API                                                     --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                      --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getStdDensFromApiAnalysis (
     p_object_id      stream.object_id%TYPE,
     p_daytime         DATE,
     p_analysis_type   VARCHAR2,
     p_sampling_method    VARCHAR2,
     p_compare_oper   VARCHAR2 DEFAULT '=')

RETURN NUMBER
--</EC-DOC>
IS

ln_return_val          NUMBER;
lr_analysis_sample     object_fluid_analysis%ROWTYPE;

BEGIN


  lr_analysis_sample := EcDp_Fluid_Analysis.getLastAnalysisSample (p_object_id,p_analysis_type, p_sampling_method,p_daytime);

   IF (131.5 +   lr_analysis_sample.api) = 0 THEN

      ln_return_val := NULL;

   ELSE

      ln_return_val := (141.5 * 1000) /
                       (131.5 + lr_analysis_sample.api);
   END IF;

   RETURN ln_return_val;

END getStdDensFromApiAnalysis;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getStdDensRefStream
-- Description    : Returns standard density for given stream on a given day
--                  using reference stream density
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions: ECBP_STREAM.FINDREFANALYSISSTREAM
--                  ECBP_STREAM_FLUID.FINDSTDDENS
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getStdDensRefStream (
     p_object_id      stream.object_id%TYPE,
     p_daytime         DATE)

RETURN NUMBER
--</EC-DOC>
IS

ln_return_val     NUMBER;
lv2_ref_stream    VARCHAR2(32);

BEGIN


   lv2_ref_stream := EcBp_Stream.findRefAnalysisStream(
                                                      p_object_id,
                                                      p_daytime);

   -- Find standard density for reference stream
   IF ((lv2_ref_stream IS NOT NULL) AND (lv2_ref_stream <> p_object_id)) THEN

      ln_return_val := findStdDens(
                                   lv2_ref_stream,
                                   p_daytime,
                                   NULL); -- Method set to NULL, must be decided by the reference stream

   ELSE

      ln_return_val := NULL;

   END IF;

   RETURN ln_return_val;

END getStdDensRefStream;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getAvgOilInWater                                                             --
-- Description    : Returns avg oil_in_water weigthed by gross volume                            --
--                  for a water stream.                                                          --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions: ecdp_stream.getStreamPhase                                                   --
--                  ecdp_phase.WATER                                                             --
--                  ecdp_stream_analysis.getDayOilInWater                                        --
--                  findGrsStdVol                                                                --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                      --
--                                                                                               --
---------------------------------------------------------------------------------------------------

FUNCTION getAvgOilInWater (
     p_object_id      stream.object_id%TYPE,
     p_fromday     DATE,
     p_today       DATE DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_daytime IS
SELECT daytime
FROM system_days
WHERE daytime BETWEEN p_fromday AND Nvl(p_today,p_fromday);

ln_return_val NUMBER;
ln_sum_vol NUMBER;
ln_volxoiw NUMBER;
ln_oilinwater NUMBER;
ln_daygrsvol NUMBER;

BEGIN
  -- Only relevant for water streams
  IF (ecdp_stream.getStreamPhase(p_object_id) <> ecdp_phase.WATER) THEN
    RETURN NULL;
  END IF;
  ln_volxoiw := 0;  -- Initialization
  ln_sum_vol := 0;
  FOR mycur IN c_daytime LOOP

   -- Sum(oiw*grs_vol) for period
     ln_oilinwater := nvl(ecdp_stream_analysis.getDayOilInWater(p_object_id, mycur.daytime),0);
    ln_daygrsvol := nvl(findGrsStdVol(p_object_id, mycur.daytime),0);
    ln_sum_vol := ln_sum_vol + ln_daygrsvol;
    ln_volxoiw := ln_volxoiw + (ln_oilinwater * ln_daygrsvol);

  END LOOP;

  -- If any values in the set is null, the total data set is treated as inconsistent and NULL is returned.
  IF Nvl(ln_sum_vol, 0) = 0 OR ln_volxoiw IS NULL THEN

    ln_return_val := NULL;

  ELSE

    ln_return_val := ln_volxoiw/ln_sum_vol;  -- The calculated volume based average

  END IF;

  RETURN ln_return_val;

END getAvgOilInWater;

---------------------------------------------------------------------------------------------------
-- Function       : calcMthWeightedWaterFrac                                                     --
-- Description    : Returns flow weighted monthly water fraction for a stream                    --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions: ecbp_stream_fluid.findGrsStdMass,                                            --
--                  ecbp_stream_fluid.getBswWeightFrac                                           --
--                                                                                               --
--                                                                                               --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                      --
--                                                                                               --
---------------------------------------------------------------------------------------------------

FUNCTION calcMthWeightedWaterFrac(p_object_id stream.object_id%TYPE, p_daytime DATE) RETURN NUMBER IS

ln_mth_water NUMBER;
li_max INTEGER;
li_index INTEGER;
ld_day DATE;
ln_sum_mass NUMBER;
ln_day_mass NUMBER;
ln_day_water NUMBER;

BEGIN


  ln_sum_mass :=0;
  ln_mth_water :=0;
  li_max := to_number(to_char(last_day(p_daytime), 'dd'));

  FOR li_index IN 1..li_max LOOP

   ld_day := to_date(to_char(li_index, '99')||to_char(p_daytime, '.mm.yyyy'), 'dd.mm.yyyy');
   ln_day_mass := nvl(ecbp_stream_fluid.findGrsStdMass(p_object_id,ld_day),0);
   ln_sum_mass := ln_sum_mass + ln_day_mass;
   ln_day_water := nvl(ecbp_stream_fluid.getBswWeightFrac(p_object_id,ld_day),0);
   ln_mth_water := ln_mth_water + (ln_day_water * ln_day_mass);

  END LOOP;

  IF ln_sum_mass > 0 THEN

     ln_mth_water := ln_mth_water / ln_sum_mass;

  ELSE

     RETURN 0;

  END IF;

RETURN ROUND(ln_mth_water,6);

END calcMthWeightedWaterFrac;

------------------------------------------------------------------

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcGrsStdDens                                                               --
-- Description    : Returns the calculated grs density on a given day                            --
--                  from a calculated stream grs mass and grs volume.                            --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
--                                                                                               --
-- Using functions: findGrsStdVol,                                                               --
--                  findGrsStdMass                                                               --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------

FUNCTION calcgrsStdDens (
     p_object_id    stream.object_id%TYPE,
     p_daytime      DATE,
     p_method       VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

ln_return_val  NUMBER;

BEGIN
   -- This function is redundant, do not add logic here, simply call findGrsDens which handles all business logic
   ln_return_val := EcBp_Stream_Fluid.findGrsDens(p_object_id,
                                                  p_daytime,
                                                  p_method);

   RETURN ln_return_val;

END calcGrsStdDens;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findSpecificGravity
-- Description    : Returns the specific gravity
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findSpecificGravity(p_object_id stream.object_id%TYPE,
                             p_daytime date)
RETURN number
--</EC-DOC>
IS

CURSOR c_measure(cp_object_id stream.object_id%TYPE, cp_daytime date) IS
SELECT oa.sp_grav
FROM strm_day_stream oa
WHERE oa.object_id = cp_object_id
AND oa.daytime=cp_daytime
;

ln_spec_grav_method VARCHAR2(32);
ln_return_value NUMBER;
ln_stream_ref stream.object_id%TYPE;
lv2_analysis_ref_id stream.object_id%TYPE;
lr_analysis_sample object_fluid_analysis%ROWTYPE;
lv2_phase  VARCHAR2(32);

BEGIN

  ln_return_value := 0;

  ln_spec_grav_method := ec_strm_version.SPECIFIC_GRAVITY_METHOD(p_object_id, p_daytime, '<=');

  lv2_phase := Ec_Strm_Version.stream_phase(p_object_id,p_daytime, '<=');

IF ln_spec_grav_method = '2' THEN  -- hardcoded value in PROSTY_CODES, type=SPEC_GRAV_METHOD, text=Sample Analysis, any sampling, code=2 ;
    lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(p_object_id, p_daytime);

    lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_SAMPLE_ANALYSIS', null, p_daytime, lv2_phase);
    ln_return_value := lr_analysis_sample.sp_grav;

  ELSIF ln_spec_grav_method = '8' THEN  -- hardcoded value in PROSTY_CODES, type=SPEC_GRAV_METHOD, text=Sample Analysis, Spot sampling, code=8 ;
    lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(p_object_id, p_daytime);

    lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_SAMPLE_ANALYSIS', 'SPOT', p_daytime, lv2_phase);
    ln_return_value := lr_analysis_sample.sp_grav;

  ELSIF ln_spec_grav_method = '9' THEN  -- hardcoded value in PROSTY_CODES, type=SPEC_GRAV_METHOD, text=Sample Analysis, Day sampling, code=9 ;
    lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(p_object_id, p_daytime);

    lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_SAMPLE_ANALYSIS', 'DAY_SAMPLER', p_daytime, lv2_phase);
    ln_return_value := lr_analysis_sample.sp_grav;

  ELSIF ln_spec_grav_method = '10' THEN  -- hardcoded value in PROSTY_CODES, type=SPEC_GRAV_METHOD, text=Sample Analysis, Month sampling, code=10 ;
    lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(p_object_id, p_daytime);

    lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_SAMPLE_ANALYSIS', 'MTH_SAMPLER', p_daytime, lv2_phase);
    ln_return_value := lr_analysis_sample.sp_grav;

  ELSIF ln_spec_grav_method = '4' THEN  -- hardcoded value in PROSTY_CODES, type=SPEC_GRAV_METHOD, text=Component Analysis, any sampling, code=4

    lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(p_object_id, p_daytime);

    lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_GAS_COMP', null, p_daytime, lv2_phase);
    ln_return_value := lr_analysis_sample.sp_grav;

  ELSIF ln_spec_grav_method = '5' THEN  -- hardcoded value in PROSTY_CODES, type=SPEC_GRAV_METHOD, text=Component Analysis, Spot sampling, code=5

    lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(p_object_id, p_daytime);

    lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_GAS_COMP', 'SPOT', p_daytime, lv2_phase);
    ln_return_value := lr_analysis_sample.sp_grav;

  ELSIF ln_spec_grav_method = '6' THEN  -- hardcoded value in PROSTY_CODES, type=SPEC_GRAV_METHOD, text=Component Analysis, Day sampling, code=6

    lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(p_object_id, p_daytime);

    lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_GAS_COMP', 'DAY_SAMPLER', p_daytime, lv2_phase);
    ln_return_value := lr_analysis_sample.sp_grav;

  ELSIF ln_spec_grav_method = '7' THEN  -- hardcoded value in PROSTY_CODES, type=SPEC_GRAV_METHOD, text=Component Analysis, Month sampling, code=7

    lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(p_object_id, p_daytime);

     lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_GAS_COMP', 'MTH_SAMPLER', p_daytime, lv2_phase);
    ln_return_value := lr_analysis_sample.sp_grav;

  ELSIF
    ln_spec_grav_method = '3' THEN  -- hardcoded value in PROSTY_CODES, type=SPEC_GRAV_METHOD, text=MEASURED, code=3

    FOR c_strm_day_stream in c_measure(p_object_id, p_daytime) loop
      ln_return_value := c_strm_day_stream.sp_grav;
    END loop;

  ELSE
       ln_stream_ref := ec_strm_version.AGA_REF_ANALYSIS_ID(p_object_id, p_daytime, '<=');
       ln_return_value := ec_strm_reference_value.spec_grav(nvl(ln_stream_ref,p_object_id), p_daytime, '<=');

  END IF;

  RETURN ln_return_value;

END findSpecificGravity;





--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : agaStaticPress
-- Description    : Returns the static pressure
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION agaStaticPress(p_object_id stream.object_id%TYPE,
                        p_daytime date,
                        p_class_name VARCHAR2 DEFAULT NULL)
RETURN number
--</EC-DOC>
IS

CURSOR c_strm_event(cp_object_id stream.object_id%TYPE,
                    cp_daytime date) IS
  select * from strm_event where object_id=cp_object_id
         and daytime=cp_daytime;

lr_strm_event strm_event%ROWTYPE;
ln_return_value number;
lv_meter_run_id    VARCHAR2(32);
lv_static_chart_unit VARCHAR2(32);
ln_static_chart_value NUMBER;
lv_attr_name         VARCHAR2(32);


BEGIN
  ln_return_value := 0;

  for mycur in c_strm_event(p_object_id, p_daytime) loop

    lr_strm_event:=mycur;

  end loop;

  lv_meter_run_id := nvl(lr_strm_event.meter_run_override,ecdp_strm_aga.getMeterRun(p_object_id, p_daytime,lr_strm_event.event_type));
  IF lv_meter_run_id IS NOT NULL THEN
    lv_static_chart_unit := ec_meter_run_version.static_chart_unit(lv_meter_run_id,p_daytime,'<=');
  ELSE
    --if unit is not set in meter_run, use uom for PRESS_GAUGE
    lv_static_chart_unit := Ecdp_Unit.GetUnitFromLogical('PRESS_GAUGE');
  END IF;

  lv_attr_name := getAttributeName(p_class_name,'STATIC_CHART_VALUE');

  -- reading value will be taken direct from strm event. no need for conversion.
  ln_static_chart_value := lr_strm_event.static_chart_value;

  if (lr_strm_event.static_chart_type in ('LINEAR', 'PERCENT') AND lr_strm_event.static_chart_rating > 0) then

    ln_return_value := ln_static_chart_value/nvl(lr_strm_event.static_chart_scale, 100)*lr_strm_event.static_chart_rating;

    -- convert into display purpose based on UOM
    ln_return_value := Ecdp_Unit.convertValue(ln_return_value,
                                                  nvl(lv_static_chart_unit,'PSIG'),
                                                  Ecdp_Unit.GetUnitFromLogical(EcDp_ClassMeta_Cnfg.getUomCode(p_class_name,'STATIC_PRESS')));


  elsif (lr_strm_event.static_chart_type = 'SQUARE_ROOT' AND lr_strm_event.static_chart_rating > 0) then


    ln_return_value := POWER(nvl( ln_static_chart_value,0), 2) / 100 * lr_strm_event.static_chart_rating;

    -- convert into display purpose based on UOM
    ln_return_value := Ecdp_Unit.convertValue(ln_return_value,
                                                  nvl(lv_static_chart_unit,'PSIG'),
                                                  Ecdp_Unit.GetUnitFromLogical(EcDp_ClassMeta_Cnfg.getUomCode(p_class_name,'STATIC_PRESS')));


  elsif lr_strm_event.static_chart_type = 'READING' then

    ln_return_value := Ecdp_Unit.convertValue(ln_static_chart_value,
                                                  nvl(lv_static_chart_unit,'PSIG'),
                                                  Ecdp_Unit.GetUnitFromLogical(EcDp_ClassMeta_Cnfg.getUomCode(p_class_name,'STATIC_PRESS')));


  ELSIF lr_strm_event.static_chart_type IS NULL THEN

    ln_return_value := Ecdp_Unit.convertValue(ln_static_chart_value,
                                                  nvl(lv_static_chart_unit,'PSIG'),
                                                  Ecdp_Unit.GetUnitFromLogical(EcDp_ClassMeta_Cnfg.getUomCode(p_class_name,'STATIC_PRESS')));

  end if;

  return ln_return_value;

END agaStaticPress;





--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : agaDiffStaticPress
-- Description    : Returns the specific gravity
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION agaDiffStaticPress(p_object_id stream.object_id%TYPE,
                        p_daytime date,
                        p_class_name VARCHAR2 DEFAULT NULL)
RETURN number
--</EC-DOC>
IS

CURSOR c_strm_event(cp_object_id stream.object_id%TYPE,
                    cp_daytime date) IS
  select * from strm_event where object_id=cp_object_id
         and daytime=cp_daytime;

lr_strm_event strm_event%ROWTYPE;
ln_return_value number;
lv_meter_run_id    VARCHAR2(32);
lv_diff_chart_unit VARCHAR2(32);
ln_diff_chart_value NUMBER;
lv_attr_name         VARCHAR2(32);


BEGIN
  ln_return_value := 0;

  for mycur in c_strm_event(p_object_id, p_daytime) loop

    lr_strm_event:=mycur;

  end loop;

  lv_meter_run_id := nvl(lr_strm_event.meter_run_override,ecdp_strm_aga.getMeterRun(p_object_id, p_daytime,lr_strm_event.event_type));
  IF lv_meter_run_id IS NOT NULL THEN
    lv_diff_chart_unit := ec_meter_run_version.diff_chart_unit(lv_meter_run_id,p_daytime,'<=');
  ELSE
    --if unit is not set in meter_run, use uom for PRESS_GAUGE
    lv_diff_chart_unit := Ecdp_Unit.GetUnitFromLogical('PRESS_GAUGE');
  END IF;

  lv_attr_name := getAttributeName(p_class_name,'DIFF_CHART_VALUE');

  -- reading value will be taken direct from strm event. no need for conversion.
  ln_diff_chart_value := lr_strm_event.diff_chart_value;

  if (lr_strm_event.diff_chart_type in ('LINEAR', 'PERCENT') AND lr_strm_event.diff_chart_rating > 0) then

    ln_return_value := ln_diff_chart_value/nvl(lr_strm_event.diff_chart_scale, 100)*lr_strm_event.diff_chart_rating;

    -- convert into display purpose based on UOM
    ln_return_value := Ecdp_Unit.convertValue(ln_return_value,
                                                  nvl(lv_diff_chart_unit,'INH2O'),
                                                  Ecdp_Unit.GetUnitFromLogical(EcDp_ClassMeta_Cnfg.getUomCode(p_class_name,'DIFF_PRESS')));


  elsif (lr_strm_event.diff_chart_type = 'SQUARE_ROOT' AND lr_strm_event.diff_chart_rating > 0) then

    ln_return_value :=  POWER(nvl(ln_diff_chart_value,0), 2) / 100 * lr_strm_event.diff_chart_rating;

    -- convert into display purpose based on UOM
    ln_return_value := Ecdp_Unit.convertValue(ln_return_value,
                                                  nvl(lv_diff_chart_unit,'INH2O'),
                                                  Ecdp_Unit.GetUnitFromLogical(EcDp_ClassMeta_Cnfg.getUomCode(p_class_name,'DIFF_PRESS')));

  elsif lr_strm_event.diff_chart_type = 'READING' then

    ln_return_value := Ecdp_Unit.convertValue(ln_diff_chart_value,
                                                  nvl(lv_diff_chart_unit,'INH2O'),
                                                  Ecdp_Unit.GetUnitFromLogical(EcDp_ClassMeta_Cnfg.getUomCode(p_class_name,'DIFF_PRESS')));


  ELSIF lr_strm_event.diff_chart_type IS NULL THEN

    ln_return_value := Ecdp_Unit.convertValue(ln_diff_chart_value,
                                                  nvl(lv_diff_chart_unit,'INH2O'),
                                                  Ecdp_Unit.GetUnitFromLogical(EcDp_ClassMeta_Cnfg.getUomCode(p_class_name,'DIFF_PRESS')));

  end if;

  return ln_return_value;

END agaDiffStaticPress;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGCV
-- Description    : Returns the Gas Colorific Value for a
--                  given stream and day.
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : OBJECT_FLUID_ANALYSIS
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findGCV (
     p_object_id    stream.object_id%TYPE,
     p_daytime      DATE,
     p_today        DATE DEFAULT NULL,
     p_method       VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_daytime IS
SELECT daytime
FROM system_days
WHERE daytime BETWEEN p_daytime AND Nvl(p_today,p_daytime);

ln_return_val    NUMBER;
lv2_phase    VARCHAR2(32);
lv2_method    VARCHAR2(32);
lv2_stream_object_id  stream.object_id%TYPE;
lv2_strm_meter_freq VARCHAR2(32);
lv2_analysis_ref_id stream.object_id%TYPE;
lv2_energy  VARCHAR2(30);
lv2_volume VARCHAR2(30);
ln_energy NUMBER;
ln_grs_vol NUMBER;
lr_analysis_sample object_fluid_analysis%ROWTYPE;
lv2_aggregate_flag VARCHAR2(32);

BEGIN

   -- Determine which GCV method to use
   lv2_method := Nvl(p_method, ec_strm_version.GCV_METHOD(
                 p_object_id,
                 p_daytime,
                 '<='));

   -- find stream phase
   lv2_phase := Ec_Strm_Version.stream_phase(p_object_id,p_daytime, '<=');

   -- Find this streams aggregate_flag
   lv2_aggregate_flag := NVL(ec_strm_version.aggregate_flag(p_object_id, p_daytime, '<='),'NA');

   IF lv2_phase IN ('GAS','LNG') THEN

      -- METHOD= 'COMP_ANALYSIS' (get density from last 'comp' analysis)
      IF (lv2_method = EcDp_Calc_Method.COMP_ANALYSIS) THEN
         lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(p_object_id, p_daytime);

         lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_GAS_COMP', null, p_daytime, lv2_phase);
         ln_return_val := lr_analysis_sample.gcv;

      -- METHOD= 'COMP_ANALYSIS_SPOT'
      ELSIF (lv2_method = EcDp_Calc_Method.COMP_ANALYSIS_SPOT) THEN
         lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(p_object_id, p_daytime);

         lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_GAS_COMP', 'SPOT', p_daytime, lv2_phase);
         ln_return_val := lr_analysis_sample.gcv;

      -- METHOD= 'COMP_ANALYSIS_DAY'
      ELSIF (lv2_method = EcDp_Calc_Method.COMP_ANALYSIS_DAY) THEN
         lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(p_object_id, p_daytime);

         lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_GAS_COMP', 'DAY_SAMPLER', p_daytime, lv2_phase);
         ln_return_val := lr_analysis_sample.gcv;

      -- METHOD= 'COMP_ANALYSIS_MTH'
      ELSIF (lv2_method = EcDp_Calc_Method.COMP_ANALYSIS_MTH) THEN
         lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(p_object_id, p_daytime);

         lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_GAS_COMP', 'MTH_SAMPLER', p_daytime, lv2_phase);
         ln_return_val := lr_analysis_sample.gcv;

      ELSIF
      -- METHOD= 'MEASURED'
         lv2_method = EcDp_Calc_Method.MEASURED THEN
         lv2_strm_meter_freq := NVL(ec_strm_version.STRM_METER_FREQ(p_object_id, p_daytime, '<='),'');

         IF lv2_strm_meter_freq = 'DAY' OR lv2_aggregate_flag = 'Y' THEN
           --DAILY MEASURED STREAM
            ln_return_val := ec_strm_day_stream.gcv(p_object_id, p_daytime);

         ELSIF   lv2_strm_meter_freq = 'MTH' THEN
           --MONTHLY MEASURED STREAM (Use strm_mth_stream)
           ln_return_val := ec_strm_mth_stream.gcv(p_object_id, p_daytime);
         ELSE
           -- STRM_METER_FREQ= 'NA'
           ln_return_val := NULL;
         END IF;

      ELSIF lv2_method = 'SAMPLE_ANALYSIS' THEN
         lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(p_object_id, p_daytime);

         lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_SAMPLE_ANALYSIS', null, p_daytime, lv2_phase);
         ln_return_val := lr_analysis_sample.gcv;

      ELSIF lv2_method = 'SAMPLE_ANALYSIS_SPOT' THEN
         lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(p_object_id, p_daytime);

         lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_SAMPLE_ANALYSIS', 'SPOT', p_daytime, lv2_phase);
         ln_return_val := lr_analysis_sample.gcv;

      ELSIF lv2_method = 'SAMPLE_ANALYSIS_DAY' THEN
         lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(p_object_id, p_daytime);

         lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_SAMPLE_ANALYSIS', 'DAY_SAMPLER', p_daytime, lv2_phase);
         ln_return_val := lr_analysis_sample.gcv;

      ELSIF lv2_method = 'SAMPLE_ANALYSIS_MTH' THEN
         lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(p_object_id, p_daytime);

         lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, 'STRM_SAMPLE_ANALYSIS', 'MTH_SAMPLER', p_daytime, lv2_phase);
         ln_return_val := lr_analysis_sample.gcv;

      ELSIF lv2_method = 'ENERGY_DIV_VOLUME' THEN
         -- Determine which energy method to use
         lv2_energy := ec_strm_version.ENERGY_METHOD(
                               p_object_id,
                               p_daytime,
                                '<=' );

          -- Determine which volume method to use
         lv2_volume := ec_strm_version.GRS_VOL_METHOD(
                               p_object_id,
                               p_daytime,
                                 '<=' );
          --Raise app[ication error if energy method = VOLUME_GCV or Volume method = ENERGY_GCV
         IF (lv2_energy = EcDp_Calc_Method.VOLUME_GCV OR lv2_volume = EcDp_Calc_Method.ENERGY_GCV) THEN
           RAISE_APPLICATION_ERROR(-20000,'A loop was detected when trying to calculate Gross Std Volume and Energy. Check Configuration.');
         END IF;

         ln_return_val := 0;
         IF lv2_strm_meter_freq = 'MTH' THEN
           ln_energy := EcBp_Stream_Fluid.findEnergy(p_object_id, p_daytime, p_today);
           ln_grs_vol := EcBp_Stream_Fluid.findGrsStdVol(p_object_id, p_daytime);

           IF ln_energy = 0 THEN
             ln_return_val := 0;
           ELSIF ln_energy <> 0 THEN
             IF (ln_grs_vol = 0 OR ln_grs_vol IS NULL) THEN
               ln_return_val := NULL;
             ELSE
              ln_return_val := ln_energy/ln_grs_vol;
             END IF;
           END IF;

         ELSE
         FOR mycur IN c_daytime LOOP
             ln_energy := ecbp_stream_fluid.findEnergy(p_object_id, mycur.daytime, mycur.daytime);
             ln_grs_vol := EcBp_Stream_Fluid.findGrsStdVol(p_object_id, p_daytime);

           IF ln_energy = 0  THEN
              ln_return_val := 0;
             ELSIF ln_energy <> 0 THEN
                 IF (ln_grs_vol = 0 OR ln_grs_vol IS NULL) THEN
                    ln_return_val := NULL;
                 ELSE
                    ln_return_val := ln_return_val + (ln_energy/ln_grs_vol);
                 END IF;
           END IF;
        END LOOP;
      END IF;

      ELSIF (lv2_method = EcDp_Calc_Method.FORMULA) THEN

         ln_return_val := EcDp_Stream_Formula.getGCV(p_object_id, p_daytime, p_today);

      ELSIF lv2_method = 'REF_VALUE' THEN
         ln_return_val := ec_strm_reference_value.gcv(p_object_id, p_daytime, '<=');

      ELSIF lv2_method = 'REF_STREAM' THEN
         lv2_analysis_ref_id := Ecbp_Stream.findRefAnalysisStream(p_object_id, p_daytime);
         ln_return_val := EcBp_Stream_Fluid.findGCV(lv2_analysis_ref_id,p_daytime);

      ELSIF
      -- METHOD= 'USER_EXIT'
      substr(lv2_method,1,9) = EcDp_Calc_Method.USER_EXIT THEN
          ln_return_val := ue_stream_fluid.getGCV(p_object_id, p_daytime,p_today);

      END IF;

   ELSE -- Not supported

        ln_return_val := NULL;

   END IF;

   RETURN ln_return_val;

END findGCV;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findEnergy
-- Description    : Returns the Gas Calorific Value for a given stream
--                  and period.
-- Preconditions  :
-- Postcondition  : All input data to calucations must have a defined value or else
--                  the funtion will return null
-- Using Tables   : SYSTEM_DAYS
--                  STRM_DAY_STREAM
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Alternative STRM_VERSION.... (ENERGY_METHOD):
--
--                1. 'MEASURED': Find energy from strm_day_stream only.
--                2. 'VOLUME_GCV': Net Volume * Latest GCV from latest gas stream analysis
--                3. 'ALLOCATED': Access the STRM_DAY_ALLOC.ALLOC_ENERGY field directly.
--                4. 'VOLUME_REF_MBTU'
--                5. 'USER_EXIT'
--                6. 'TOTALIZER_DAY'
--
---------------------------------------------------------------------------------------------------
FUNCTION findEnergy (
     p_object_id    stream.object_id%TYPE,
     p_fromday      DATE,
     p_today        DATE     DEFAULT NULL,
     p_method       VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

lv2_method    VARCHAR2(30);
ln_return_val NUMBER;
ln_energy_factor_override NUMBER;
lv2_stream_object_id     stream.object_id%TYPE;
ld_fromday               DATE;
ld_today                 DATE;
ld_cur_date              DATE;
ln_total_energy          NUMBER;
lr_strm_day_stream       strm_day_stream%ROWTYPE;
ln_closing_read          NUMBER;
ln_opening_override      NUMBER;
ln_opening_read          NUMBER;
ln_net_std_vol           NUMBER;

CURSOR c_measure(cp_object_id stream.object_id%TYPE, cp_daytime date) IS
SELECT oa.energy
FROM strm_day_stream oa
WHERE oa.object_id = cp_object_id
AND oa.daytime=cp_daytime;

CURSOR c_daytime IS
SELECT daytime
FROM system_days
WHERE daytime BETWEEN p_fromday AND Nvl(p_today,p_fromday);

CURSOR c_mth IS
SELECT daytime
FROM system_month
WHERE daytime BETWEEN p_fromday AND Nvl(p_today,p_fromday);

CURSOR c_alloc(cp_object_id stream.object_id%TYPE, cp_daytime date) IS
SELECT sda.alloc_energy
FROM strm_day_alloc sda
WHERE sda.object_id = cp_object_id
AND sda.daytime=cp_daytime;

CURSOR c_strm_event(cp_object_id VARCHAR2, cp_fromday DATE, cp_today DATE) IS
SELECT *
FROM strm_event
WHERE object_id = cp_object_id
AND Nvl(event_day,TRUNC(daytime)) BETWEEN cp_fromday AND cp_today
ORDER BY daytime ASC;

CURSOR c_strm_event_single(cp_object_id VARCHAR2, cp_fromday DATE) IS
SELECT *
FROM strm_event
WHERE object_id = cp_object_id
AND daytime = cp_fromday
;

lb_first_iteration BOOLEAN;
lv2_strm_meter_freq VARCHAR2(32);
lv2_aggregate_flag VARCHAR2(32);

BEGIN

   ld_fromday := p_fromday;
   ld_today := p_today;
   lv2_stream_object_id := p_object_id;

   -- Find this streams meter frequency flag
   lv2_strm_meter_freq := NVL(ec_strm_version.STRM_METER_FREQ(p_object_id, p_fromday, '<='),'');

   -- Find this streams aggregate_flag
   lv2_aggregate_flag := NVL(ec_strm_version.aggregate_flag(p_object_id, p_fromday, '<='),'NA');

   -- Determine which method to use
   lv2_method := Nvl(p_method,
         ec_strm_version.ENERGY_METHOD(
                     p_object_id,
                     p_fromday,
                           '<=' ));

   -- METHOD= 'MEASURED' ( Only measured values.)
   IF (lv2_method = EcDp_Calc_Method.MEASURED) THEN

     IF lv2_strm_meter_freq = 'DAY' OR lv2_aggregate_flag = 'Y' THEN
       lb_first_iteration:= TRUE;
       FOR mycur IN c_daytime LOOP
         IF lb_first_iteration THEN
           lb_first_iteration:= FALSE;
           ln_return_val := 0;
         END if;

         FOR c_strm_day_stream in c_measure(p_object_id, mycur.daytime) loop
           ln_return_val :=ln_return_val + c_strm_day_stream.energy;
         END loop;
       END LOOP;

     ELSIF lv2_strm_meter_freq = 'MTH' THEN
       ln_return_val := ec_strm_mth_stream.math_energy(p_object_id,p_fromday, p_today);
     END IF;

   -- METHOD= 'VOLUME_GCV' ( Net Volume * Latest GCV from latest gas stream analysis )
   ELSIF (lv2_method = EcDp_Calc_Method.VOLUME_GCV) THEN

     lb_first_iteration:= TRUE;

     IF lv2_strm_meter_freq = 'DAY' OR lv2_aggregate_flag = 'Y' THEN
       FOR mycur IN c_daytime LOOP
         IF lb_first_iteration THEN
           lb_first_iteration:= FALSE;
           ln_return_val := 0;
         END IF;

         ln_net_std_vol := EcBp_Stream_Fluid.findNetStdVol(p_object_id,mycur.daytime,mycur.daytime);
         IF ln_net_std_vol = 0 THEN --When volume is zero, no energy, no GCV
      IF (ln_return_val IS NULL) THEN
        ln_return_val := ln_return_val;
      END IF;
         ELSE
            ln_return_val := ln_return_val + ln_net_std_vol * EcBp_Stream_Fluid.findGCV(p_object_id,mycur.daytime);
         END IF;


       END LOOP;
     ELSIF lv2_strm_meter_freq = 'MTH' THEN
       FOR mycur IN c_mth LOOP
         -- Loop through month after month and find proper GCV for each month
         IF lb_first_iteration THEN
           lb_first_iteration:= FALSE;
           ln_return_val := 0;
         END IF;

         ln_net_std_vol := EcBp_Stream_Fluid.findNetStdVol(p_object_id,mycur.daytime,last_day(mycur.daytime));
         IF ln_net_std_vol = 0 THEN --When volume is zero, no energy, no GCV
            IF (ln_return_val IS NULL) THEN
        ln_return_val := ln_return_val;
      END IF;
         ELSE
            ln_return_val := ln_return_val + ln_net_std_vol * EcBp_Stream_Fluid.findGCV(p_object_id,mycur.daytime);
         END IF;
       END LOOP;

     END IF;

   -- METHOD= 'ALLOCATED' ( Only allocated values.)
   ELSIF (lv2_method = EcDp_Calc_Method.ALLOCATED) THEN

      FOR c_strm_day_alloc in c_alloc(p_object_id, p_fromday) LOOP

          ln_return_val := c_strm_day_alloc.alloc_energy;

       END LOOP;

      -- Method 'VOLUME_REF_BTU'
   ELSIF (lv2_method = EcDp_Calc_Method.VOLUME_REF_MBTU) THEN

     IF p_today IS NULL THEN -- access single record only
     FOR cur_strm_event IN c_strm_event_single(lv2_stream_object_id, ld_fromday) LOOP
         ln_energy_factor_override:= cur_strm_event.energy_factor_override;
         ln_total_energy := ecbp_stream_fluid.findNetStdVol(p_object_id, p_fromday, p_today) * nvl(ln_energy_factor_override, ec_strm_reference_value.mbtu_factor(p_object_id, p_fromday, '<='));
     END LOOP;
     ln_return_val := ln_total_energy;
     ELSE -- access from day to day

       lb_first_iteration:= TRUE;
       FOR cur_strm_event IN c_strm_event(lv2_stream_object_id, ld_fromday, ld_today) LOOP
         ln_energy_factor_override := cur_strm_event.energy_factor_override;
         IF lb_first_iteration THEN
           lb_first_iteration:= FALSE;
           ln_return_val := ecbp_stream_fluid.findNetStdVol(p_object_id, cur_strm_event.daytime, NULL) * nvl(ln_energy_factor_override, ec_strm_reference_value.mbtu_factor(p_object_id, p_fromday, '<='));
     ELSE
       ln_return_val := ln_return_val + ((ecbp_stream_fluid.findNetStdVol(p_object_id, cur_strm_event.daytime, NULL)) * nvl(ln_energy_factor_override, ec_strm_reference_value.mbtu_factor(p_object_id, p_fromday, '<=')));
     END IF;
       END LOOP;
     END IF;

   -- Method == 'FORMULA'
   ELSIF (lv2_method = EcDp_Calc_Method.FORMULA) THEN

      ln_return_val := 0;
    IF lv2_strm_meter_freq='MTH' THEN
        ln_return_val := EcDp_Stream_Formula.getEnergy(p_object_id,ld_fromday,ld_today);
    ELSE
      IF ld_today IS NOT NULL AND ld_today > ld_fromday THEN
        ld_cur_date := ld_fromday;

        WHILE ld_cur_date <= ld_today LOOP
          ln_return_val := ln_return_val + EcDp_Stream_Formula.getEnergy(p_object_id,ld_cur_date,NULL);
          ld_cur_date := ld_cur_date + 1;
        END LOOP;

      ELSE
        ln_return_val := EcDp_Stream_Formula.getEnergy(p_object_id,ld_fromday,ld_today);
      END IF;
    END IF;
   -- Method == 'USER_EXIT'
   ELSIF  (substr(lv2_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN

      ln_return_val := ue_stream_fluid.getEnergy(p_object_id, p_fromday,p_today);

   -- Totalizer Day
   ELSIF (lv2_method = ecdp_calc_method.TOTALIZER_DAY) THEN

    IF lv2_strm_meter_freq = 'DAY' THEN

      lr_strm_day_stream := ec_strm_day_stream.row_by_pk(lv2_stream_object_id, ld_fromday, '=');

      ln_closing_read := lr_strm_day_stream.totalizer_energy;
      ln_opening_override := lr_strm_day_stream.totalizer_energy_override;

      IF ln_opening_override IS NULL THEN

         ln_opening_read := ec_strm_day_stream.totalizer_energy(p_object_id,p_fromday-1);

      END IF;

    END IF;

    ln_return_val := ln_closing_read - nvl(ln_opening_override,ln_opening_read);

   ELSE

      ln_return_val := NULL;

   END IF;

   RETURN ln_return_val;

END findEnergy;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcDailyRateTotalizer
-- Description    : Returns the Daily Rate for Totalizers
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : STRM_EVENT
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

FUNCTION calcDailyRateTotalizer(p_object_id stream.object_id%TYPE,
                                p_daytime   DATE)

RETURN NUMBER
IS
ln_net_vol NUMBER;
ld_end_date DATE;
ln_return_val        NUMBER;
ln_totalizer_close NUMBER;
ln_totalizer_open_overwrite NUMBER;
lv2_method VARCHAR2(32);
ld_maxdaytime DATE;
ln_duration NUMBER;
ln_totalizer_open NUMBER;
lv2_event_type VARCHAR2(32);

CURSOR c_strm_totalizer(cp_object_id VARCHAR2, cp_day DATE) IS
SELECT *
FROM strm_event
WHERE object_id = cp_object_id
AND daytime = cp_day
;

BEGIN


 lv2_method := ec_strm_version.NET_VOL_METHOD(p_object_id,p_daytime,'<=');
 FOR cur_strm_totalizer IN c_strm_totalizer(p_object_id, p_daytime) LOOP
    ln_totalizer_close := cur_strm_totalizer.grs_closing_vol;
    ln_totalizer_open_overwrite := cur_strm_totalizer.grs_opening_vol;
    ln_totalizer_open  := ec_strm_event.grs_closing_vol(p_object_id,cur_strm_totalizer.event_type, p_daytime,'<');
    ld_end_date        := cur_strm_totalizer.end_date;
    lv2_event_type := cur_strm_totalizer.event_type;
 END LOOP;

 IF (lv2_method = EcDp_Calc_Method.TOTALIZER_DAY_EXTRAPOLATE) THEN

   IF ln_totalizer_close IS NULL AND (ln_totalizer_open_overwrite IS NULL OR ln_totalizer_open IS NULL)THEN

     ld_maxdaytime := getLastNotNullClosingValueDate(p_object_id, p_daytime);
     ln_net_vol := findNetStdVol(p_object_id, ld_maxdaytime);
     ln_duration := ec_strm_event.end_date(p_object_id, lv2_event_type, ld_maxdaytime) - ld_maxdaytime;

       IF ln_duration > 0 THEN
          ln_return_val := ln_net_vol / ln_duration;
       ELSE
          ln_return_val := null;
       END IF;

    ELSE

       ln_net_vol := findNetStdVol(p_object_id, p_daytime);
       ln_duration := ld_end_date - p_daytime;

       IF ln_duration > 0 THEN
          ln_return_val := ln_net_vol / ln_duration;
       ELSE
          ln_return_val := null;
       END IF;

    END IF;
ELSE

   ln_net_vol := findNetStdVol(p_object_id, p_daytime);
   ln_duration := ld_end_date - p_daytime;

   IF ln_duration > 0 THEN
     ln_return_val := ln_net_vol / ln_duration;
   ELSE
     ln_return_val := null;
   END IF;

 END IF;

RETURN ln_return_val;

END calcDailyRateTotalizer;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLastNotNullClosingValueDate
-- Description    : Returns the latest available daily injection rate on a given
--                  daytime on or prior to a given daytime
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getLastNotNullClosingValueDate(
    p_object_id stream.object_id%TYPE,
    p_daytime DATE)
RETURN DATE
--</EC-DOC>
IS


CURSOR c_strm_period_tot IS
  SELECT max(daytime) max_daytime
  FROM strm_event
  WHERE object_id = p_object_id
  AND (to_char(to_date(p_daytime), 'yyyymm') between to_char(to_date(end_date), 'yyyymm') AND to_char(add_months(to_date(trunc(to_date(end_date), 'mm')), 1), 'yyyymm'))
  AND GRS_CLOSING_VOL IS NOT NULL
  ORDER BY daytime ASC;

  ld_max_daytime  DATE;

BEGIN

   FOR curRec IN c_strm_period_tot LOOP
     ld_max_daytime := curRec.max_daytime;
   END LOOP;

   RETURN ld_max_daytime;

END getLastNotNullClosingValueDate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : find_net_mass_by_pc
-- Description    : Returns the summation of Daily Net Mass per profit centre
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--                                                                                                                        --
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION find_net_mass_by_pc(
p_object_id VARCHAR2,
p_profit_centre_id VARCHAR2,
p_production_day DATE) RETURN NUMBER
--</EC-DOC>
IS

ln_ret_val NUMBER;
BEGIN
     SELECT SUM(ecbp_truck_ticket.findNetStdMass(ste.event_no)) INTO ln_ret_val
     FROM strm_transport_event ste
     WHERE ste.object_id = p_object_id
     AND ste.production_day = p_production_day
     AND ste.profit_centre_id = p_profit_centre_id;
RETURN ln_ret_val;
END find_net_mass_by_pc;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findPowerConsumption
-- Description    : Returns the Electrical Power Consumption value for a given stream
--                  and period.
-- Preconditions  :
-- Postcondition  : All input data to calucations must have a defined value or else
--                  the funtion will return null
-- Using Tables   : SYSTEM_DAYS
--                  STRM_DAY_STREAM
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Alternative STRM_VERSION.... (ENERGY_METHOD):
--
--                1. 'MEASURED': Find energy from strm_day_stream only.
--                2. 'VOLUME_GCV': Net Volume * Latest GCV from latest gas stream analysis
--                3. 'ALLOCATED': Access the STRM_DAY_ALLOC.ALLOC_ENERGY field directly.
--                4. 'VOLUME_REF_MBTU'
--
---------------------------------------------------------------------------------------------------
FUNCTION findPowerConsumption (
     p_object_id    stream.object_id%TYPE,
     p_fromday      DATE,
     p_today        DATE     DEFAULT NULL,
     p_method       VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

lv2_method    VARCHAR2(30);
ln_return_val NUMBER;

CURSOR c_measure(cp_object_id stream.object_id%TYPE, cp_daytime date) IS
SELECT oa.power_consumption --oa.energy
FROM strm_day_stream oa
WHERE oa.object_id = cp_object_id
AND oa.daytime=cp_daytime;

CURSOR c_daytime IS
SELECT daytime
FROM system_days
WHERE daytime BETWEEN p_fromday AND Nvl(p_today,p_fromday);

CURSOR c_alloc(cp_object_id stream.object_id%TYPE, cp_daytime date) IS
SELECT sda.alloc_energy
FROM strm_day_alloc sda
WHERE sda.object_id = cp_object_id
AND sda.daytime=cp_daytime;

lb_first_iteration BOOLEAN;
lv2_strm_meter_freq VARCHAR2(32);
lv2_aggregate_flag VARCHAR2(32);

BEGIN

   -- Determine which method to use
   lv2_method := Nvl(p_method,
         ec_strm_version.ENERGY_METHOD(
                     p_object_id,
                     p_fromday,
                           '<=' ));

   -- Find this streams meter frequency flag
   lv2_strm_meter_freq := NVL(ec_strm_version.STRM_METER_FREQ(p_object_id, p_fromday, '<='),'');

   -- Find this streams aggregate_flag
   lv2_aggregate_flag := NVL(ec_strm_version.aggregate_flag(p_object_id, p_fromday, '<='),'NA');

   -- METHOD= 'MEASURED' ( Only measured values.)
   IF (lv2_method = EcDp_Calc_Method.MEASURED) THEN
      IF lv2_strm_meter_freq = 'DAY' OR lv2_aggregate_flag = 'Y' THEN
       lb_first_iteration:= TRUE;
       FOR mycur IN c_daytime LOOP
         IF lb_first_iteration THEN
           lb_first_iteration:= FALSE;
           ln_return_val := 0;
         END if;

     FOR c_strm_day_stream IN c_measure(p_object_id, mycur.daytime) loop
      ln_return_val := ln_return_val + c_strm_day_stream.power_consumption;
     END LOOP;
       END LOOP;
      END IF;

   -- Method == 'FORMULA'
   ELSIF (lv2_method = EcDp_Calc_Method.FORMULA) THEN

      ln_return_val := EcDp_Stream_Formula.getPowerConsumption(p_object_id, p_fromday, p_today);

   -- Method == 'USER_EXIT'
   ELSIF  (substr(lv2_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN

      ln_return_val := ue_stream_fluid.getPowerConsumption(p_object_id, p_fromday,p_today);

   ELSE

      ln_return_val := NULL;

   END IF;

   RETURN ln_return_val;

END findPowerConsumption;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGrsDens
-- Description    : Returns the density in gross condition for a
--                  given stream and day.

-- Preconditions  :
-- Postcondition  :





-- Using Tables   :
--
-- Using functions:
--                 EC_STRM_VERSION....
--

-- Configuration
-- required       :
--
-- Behaviour      :
--                Alternative methods based on configuration:
--                1. METHOD= 'CALCULATED' ( Find mass and volume using grs_mass and grs_vol functions)
--                2. METHOD= 'USER_EXIT' ( Find user exit functions)
---------------------------------------------------------------------------------------------------
FUNCTION findGrsDens (
     p_object_id    stream.object_id%TYPE,
     p_daytime      DATE,
     p_method       VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS



ln_return_val    NUMBER;
lv2_method       VARCHAR2(32);
ln_grs_mass      NUMBER;
ln_grs_vol       NUMBER;

BEGIN

   -- Determine which method to use

   lv2_method := Nvl(p_method, ec_strm_version.STD_GRS_DENS_METHOD(
                 p_object_id,
                 p_daytime,
                 '<='));


   -- METHOD = 'CALCULATED' (Find mass and volume using grs_mass and grs_vol functions)
   IF (lv2_method = EcDp_Calc_Method.CALCULATED) THEN

      ln_grs_mass := findGrsStdMass(p_object_id,
                                    p_daytime);

      ln_grs_vol  := findGrsStdVol(p_object_id,
                                   p_daytime);

      IF ln_grs_mass = 0 OR ln_grs_vol = 0 THEN     -- Density is unknown when there is no mass, therefore it will return null

         ln_return_val := NULL;

      ELSE

         ln_return_val := ln_grs_mass / ln_grs_vol;

      END IF;


   -- METHOD = 'USER_EXIT'
   ELSIF  (substr(lv2_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN

      ln_return_val := ue_stream_fluid.getGrsDens(p_object_id, p_daytime);

   -- Default is reference value
   ELSE

      ln_return_val := NULL;

   END IF;


   RETURN ln_return_val;

END findGrsDens;

---------------------------------------------------------------------------------------------------
-- Function       : getAttributeName
-- Description    :
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getAttributeName(p_class_name VARCHAR2,
                              p_column_name VARCHAR2
                           )
RETURN VARCHAR2
IS
  lv_class_name      VARCHAR2(32);
  lv_attr_name       VARCHAR2(32);

  CURSOR c_attribute(cp_class_name VARCHAR2, cp_column_name VARCHAR2) IS
    SELECT * FROM class_attribute_cnfg cm
    WHERE cm.class_name = cp_class_name AND
          cm.db_sql_syntax = cp_column_name;

BEGIN


  FOR cur_attr IN c_attribute(p_class_name,p_column_name) LOOP
    lv_attr_name := cur_attr.attribute_name;
    EXIT;
  END LOOP;

  RETURN lv_attr_name;
END getAttributeName;

---------------------------------------------------------------------------------------------------
-- Function       : getVCF
-- Description    :
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getVCF(
     p_object_id    stream.object_id%TYPE,
     p_daytime      DATE,
     p_density      NUMBER,
     p_press        NUMBER,
     p_temp         NUMBER,
     p_method       VARCHAR2 DEFAULT NULL)

RETURN NUMBER
IS
   lv2_vcf_method   VARCHAR2(32);
   lv2_temp_db_unit       VARCHAR2(1);
   lv2_state_id     VARCHAR2(32);
   lv2_fcty_1_id    VARCHAR2(32);
   ln_return_val    NUMBER;
   ln_press_factor  NUMBER;
   ln_temp_factor   NUMBER;
   ln_abs_temp      NUMBER;
   ln_site_atm_press      NUMBER;
   ln_base_press    NUMBER;
   ln_base_temp     NUMBER;

BEGIN

   lv2_vcf_method := Nvl(p_method, ec_strm_version.vcf_method(p_object_id, p_daytime, '<='));

   -- Get VCF through interpolation (Density, Pressure and Temperature)
   IF (lv2_vcf_method = 'TABLE_DPT') THEN
      ln_return_val := Ecdp_Stream_Dpt_Value.findInvertedFactorFromDPT(p_object_id,p_daytime,p_density,p_press,p_temp,Ecdp_Stream_Dpt_Value.COL_VCF);

   -- Get VCF through interpolation (Pressure and Temperature)
   ELSIF (lv2_vcf_method = 'TABLE_PT') THEN
      ln_return_val := Ecdp_Stream_Pt_Value.findInvertedFactorFromPT(p_object_id,p_daytime,p_press,p_temp,Ecdp_Stream_Pt_Value.COL_VCF);

   ELSIF (lv2_vcf_method = 'FORMULA') THEN
      -- This code assumes that the reference units for "base temp", "base pressure", "site atm pressure"
      -- are the same as those used for PRESS_GAUGE and TEMP

      -- Get STATE pressure base and FCTY_CLASS_1 site atm pressure
      lv2_fcty_1_id := ec_strm_version.op_fcty_class_1_id(p_object_id, p_daytime, '<=');
      lv2_state_id := ec_fcty_version.state_id(lv2_fcty_1_id, p_daytime, '<=');
      ln_base_press := Ecdp_System.getPressureBase(lv2_state_id, p_daytime);
      ln_site_atm_press := Ecdp_System.getSiteAtmPressure(lv2_fcty_1_id, p_daytime);

      -- Pressure factor is: (Measured pressure (gauge not absolute) + site atm pressure) / local pressure base.
      -- uom for all these pressures must be identical, e.g. either psi, bar or kpa.
      IF ln_base_press > 0 THEN
         ln_press_factor := (p_press + ln_site_atm_press) / ln_base_press;
      ELSE
         ln_press_factor := NULL;
      END IF;

      -- Get db unit for Temp, used to determine factor to be added for calculation to be done absolute values.
      lv2_temp_db_unit := Ecdp_Unit.GetUnitFromLogical('TEMP');

      -- Get STATE temperature base
      ln_base_temp := Ecdp_System.getTemperatureBase(lv2_state_id, p_daytime);

      IF (lv2_temp_db_unit = 'C') THEN
         -- 0 Kelvin = -273.15 Celsius
         ln_abs_temp := 273.15;
      ELSIF (lv2_temp_db_unit = 'F') THEN
         -- 0 Kelvin = -459.67 Fahrenheit
         ln_abs_temp := 459.67;
      ELSE
         -- other temperatures not supported yet and probably never used.
         ln_abs_temp := NULL;
      END IF;

      IF (ln_abs_temp + p_temp) > 0 THEN
         ln_temp_factor := (ln_base_temp + ln_abs_temp) / (ln_abs_temp + p_temp);
      ELSE
         ln_temp_factor := NULL;
      END IF;

      -- Volume correction factor (VCF) is: Pressure factor * Temperature Factor
      ln_return_val := ln_press_factor * ln_temp_factor;

   ELSIF (substr(lv2_vcf_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
      ln_return_val := Ue_Stream_Fluid.getVCF(p_object_id,p_daytime);

   END IF;

   RETURN ln_return_val;

END getVCF;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findOnStreamHours
-- Description    : Returns on stream hours which are using runtime * rate as method to calculate
--                  volume.
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : strm_day_stream
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findOnStreamHours (
     p_object_id    stream.object_id%TYPE,
     p_fromday      DATE,
     p_today        DATE DEFAULT NULL,
     p_method       VARCHAR2 DEFAULT NULL)
RETURN NUMBER
IS
ln_return_val     NUMBER;
lv2_method        VARCHAR2(32);
  CURSOR c_daytime IS
  SELECT daytime
  FROM system_days
  WHERE daytime BETWEEN p_fromday AND Nvl(p_today,p_fromday);
BEGIN
  ln_return_val := 0;
  FOR mycur1 IN c_daytime LOOP
    lv2_method := NVL(p_method,ec_strm_version.on_stream_method(p_object_id,mycur1.daytime,'<='));
    IF (lv2_method = EcDp_Calc_Method.MEASURED) THEN
      ln_return_val := ln_return_val + ec_strm_day_stream.on_stream_hrs(p_object_id,mycur1.daytime);
    ELSIF (substr(lv2_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
      ln_return_val := ln_return_val + Ue_Stream_Fluid.findOnStreamHours(p_object_id,mycur1.daytime,p_today);
    ELSE
      -- This will still refer to on_stream_hrs when no Calculation Method has been defined before
      -- This is intended for backwards compatibility. ==> Leongwen
      ln_return_val := ln_return_val + ec_strm_day_stream.on_stream_hrs(p_object_id,mycur1.daytime);
    END IF;
  END LOOP;
  RETURN ln_return_val;
END findOnStreamHours;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcShrunkVol()
-- Description    : Returns the shrunk volume calculated for a blend
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcShrunkVol (
     p_object_id    stream.object_id%TYPE,
     p_fromday      DATE,
     p_today        DATE DEFAULT NULL,
     p_method       VARCHAR2 DEFAULT NULL)
RETURN NUMBER
IS
ln_return_val       NUMBER;
ln_net_vol          NUMBER;
ln_shrinkage_factor NUMBER;
ln_diluent_cut     NUMBER;

  CURSOR c_system_days IS
  SELECT daytime
  FROM system_days
  WHERE daytime BETWEEN p_fromday AND Nvl(p_today, p_fromday);

BEGIN


  FOR mycur IN c_system_days LOOP

    IF ec_strm_version.net_vol_method(p_object_id,mycur.daytime,'<=') = 'API_BLEND_SHRINKAGE' THEN

      ln_net_vol:= EcBp_Stream_Fluid.findNetStdVol(p_object_id, mycur.daytime, mycur.daytime, 'GROSS_BSW');

      IF ln_net_vol > 0 THEN
		ln_return_val := 0;

         ln_shrinkage_factor := EcBp_VCF.calcShrinkageFactor(p_object_id, mycur.daytime);
         ln_return_val := ln_return_val + (ln_net_vol - (ln_net_vol*ln_shrinkage_factor));
	  ELSIF ln_net_vol = 0 THEN
		 ln_return_val := 0;
      END IF;
    ELSIF ec_strm_version.grs_vol_method(p_object_id,mycur.daytime,'<=') = 'API_BLEND_SHRINKAGE' THEN
      ln_net_vol:= EcBp_Stream_Fluid.findNetStdVol(p_object_id, mycur.daytime, mycur.daytime);

	  IF ln_net_vol > 0 THEN
		ln_return_val := 0;

		ln_shrinkage_factor := EcBp_VCF.calcShrinkageFactor(p_object_id, mycur.daytime);
		ln_diluent_cut := EcBp_VCF.calcDiluentConcentration(p_object_id, mycur.daytime);
		ln_return_val := ln_return_val + (ln_net_vol/(1-ln_diluent_cut)*(1-ln_shrinkage_factor));
	  ELSIF ln_net_vol = 0 THEN
		ln_return_val := 0;
	  END IF;
    END IF;

  END LOOP;
  RETURN ln_return_val;
END calcShrunkVol;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcDiluentVol()
-- Description    : Returns the diluent volume calculated for a blend
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcDiluentVol (
     p_object_id    stream.object_id%TYPE,
     p_fromday      DATE,
     p_today        DATE DEFAULT NULL,
     p_method       VARCHAR2 DEFAULT NULL)
RETURN NUMBER
IS
ln_return_val       NUMBER;
ln_diluent_cut      NUMBER;
ln_net_vol          NUMBER;
ln_shrinkage_factor NUMBER;

  CURSOR c_system_days IS
  SELECT daytime
  FROM system_days
  WHERE daytime BETWEEN p_fromday AND Nvl(p_today, p_fromday);

BEGIN


  FOR mycur IN c_system_days LOOP

    IF ec_strm_version.net_vol_method(p_object_id,mycur.daytime,'<=') = 'API_BLEND_SHRINKAGE' THEN

      ln_diluent_cut := NVL(ec_strm_day_stream.diluent_cut(p_object_id,mycur.daytime),
                            EcBp_VCF.calcDiluentConcentration(p_object_id,mycur.daytime));
      ln_net_vol:= EcBp_Stream_Fluid.findNetStdVol(p_object_id, mycur.daytime, mycur.daytime, 'GROSS_BSW');

      IF ln_net_vol > 0 THEN
		 ln_return_val := 0;
         ln_return_val := ln_return_val + (ln_net_vol+calcShrunkVol(p_object_id,mycur.daytime))*ln_diluent_cut;
	  ELSIF ln_net_vol = 0 THEN
		 ln_return_val := 0;
      END IF;

    ELSIF ec_strm_version.grs_vol_method(p_object_id,mycur.daytime,'<=') = 'API_BLEND_SHRINKAGE' THEN
      ln_net_vol:= EcBp_Stream_Fluid.findNetStdVol(p_object_id, mycur.daytime, mycur.daytime);

	  IF ln_net_vol > 0 THEN
		ln_return_val := 0;
		ln_diluent_cut := EcBp_VCF.calcDiluentConcentration(p_object_id, mycur.daytime);
		ln_return_val := ln_return_val + (ln_net_vol/(1-ln_diluent_cut)*ln_diluent_cut);
	  ELSIF ln_net_vol = 0 THEN
		ln_return_val := 0;
	  END IF;
    END IF;

  END LOOP;
  RETURN ln_return_val;
END calcDiluentVol;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWaterDisposalDays
-- Description    : Returns the number of days YTD the stream have registered water disposal (i.e Grs_vol > 0)
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :  strm_day_stream
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getWaterDisposalDays(p_object_id stream.object_id%TYPE, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

	ln_days							NUMBER := 0;

BEGIN

		SELECT COUNT(*) INTO ln_days
		FROM strm_day_stream
		WHERE object_id = p_object_id
		AND grs_vol IS NOT NULL
		AND grs_vol > 0
		AND daytime BETWEEN TRUNC(p_daytime, 'YEAR') AND p_daytime;

  RETURN ln_days;

END getWaterDisposalDays;

END EcBp_Stream_Fluid;