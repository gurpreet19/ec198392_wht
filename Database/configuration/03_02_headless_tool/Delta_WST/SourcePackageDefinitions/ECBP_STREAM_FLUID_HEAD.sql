CREATE OR REPLACE PACKAGE EcBp_Stream_Fluid IS

/****************************************************************
** Package        :  EcBp_Stream_Fluid
**
** $Revision: 1.32 $
**
** Purpose        :  This package is responsible for stream fluid
**                   information and calculation of fluid related data
**                   like densities, volumes, and masses.
**
** Documentation  :  www.energy-components.com
**
** Created  : 22.11.1999  Carl-Fredrik Sørensen
**
** Modification history:
**
** Date        Whom Change description:
** ------      ---- --------------------------------------
** 22.11.1999  CFS  First version
** 10/05/2000  PGI  In findGrsStdVol a 'default null' for argument p_today is added.
** 15/05/2000  CFS  Added calcGrsStdVolTotalToDay, calcGrsStdMassTotalToDay
** 15/05/2000  CFS  Added calc<Avg/Cum><Grs/Net>Std<Vol/Mass><MthToDay/YearToDay>
** 18/07/2000  HNE  New function: getStdDensFromApiAnalysis.
** 24/08/2000  BK   Added function calcAvgGrsStdDensMthToDay
** 27/10/2000  PGI  Changed argument list to getStdDensFromApiAnalysis.
** 17/11/2000  ØJ   Added p_method DEFAULT NULL in findStdDens.
** 12/02/2001  BK   Improved function calcAvgGrsStdDensMthToDay
** 22/02/2001  HVe  Added function getAvgOilInWater
** 17.08.2001  HNE  Created new function: GetSalt, calcMthWeightedWaterFrac, calcMthWeightedSaltFrac
** 23.11.2001  MNY  Added new function header: calcAvgBswVolFracMthToDay
**             MNY  Added new function header: calcAvgNetStdDensMthToDay
** 30.11.2001  GOZ  Added new function calcgrsStdDens
** 04.08.2004  kaurrnar   removed sysnam and stream_code and update as necessary
** 28.10.2004  Toha Added functions for PO.0026
**                          findSpecificGravity
**                          agaStaticPress
**                          agaDiffStaticPress
** 23.11.2004  DN   Added calcDailyGrsStdVolFromEvents.
** 24.02.2005  DN   TI 1965: Removed getStdDensWell and findNetStdVolComp.
** 04.03.2005 kaurrnar	Removed deadcodes
** 07.03.2005  Toha  TI 1965: removed unused calcMthWeightedSaltFrac and getSalt
** 09.08.2005 Darren TI 2234 Added new functions findGCV and findEnergy
** 19.12.2005 Ron    TI 2615 Added new functions findCGR, findWGR, findWDF and findCondVol
** 20.03.2006 Seongkok TI#3377: Added new function getSaltWeightFrac
** 18.04.2006 Lau    TI#3686: Add parameter p_resolve_loop to Findnetstdvol and FindGrsStdVol
** 10.11.2006 Seongkok TI#3804: Added functions find_*_by_pc()
** 19.03.2007 Lau    ECPD-2026: Added function calcDailyRateTotalizer
** 13.06.2007 rajarsar ECPD-2282: Added new function : getLastNotNullClosingValueDate
** 29.06.2007 rajarsar ECPD-5689: Updated function : calcDailyRateTotalizer and getLastNotNullClosingValueDate
** 30.08.2007 rahmanaz ECPD-5724: Added function : find_net_mass_by_pc
** 20.09.2007 idrussab ECPD-6591: removed function calcstddensnode
** 03.03.2008 rajarsar ECPD-7127: Added new function : findPowerConsumption
** 21.05.2008 leeeewei ECPD-8459: Modified the following functions to return sum(A*B):
**			          calcAvgNetStdVol, calcAvgNetStdMass, calcAvgGrsStdVol, calcAvgGrsStdMass,calcAvgNetStdMassMthToDay,calcAvgNetStdMassYearToDay,
**                                calcAvgNetStdVolMthToDay,calcAvgNetStdVolYearToDay,calcAvgGrsStdMassMthToDay,calcAvgGrsStdMassYearToDay, calcAvgGrsStdVolMthToDay,calcAvgGrsStdVolYearToDay
** 16.10.2008 aliassit ECPD-9984: Added p_today at function declaration findGCV
** 23.01.2009 rajarsar ECPD-10346: Added function getAttributeName and updated agaStaticPress and agaDiffStaticPress.
** 09.02.2009 farhaann ECPD-10761: Added new function : findGrsDens
** 03.08.09   embonhaf ECPD-11153  Added VCF calculation for stream.
** 19.11.2009 leongwen ECPD-13175: Added findOnStreamHours function.
** 21.03.2013 kumarsur ECPD-22598: Modified findGrsStdVol(),findNetStdVol() and added calcShrunkVol(), calcDiluentVol().
** 01.08.2013 leongwen ECPD-20789: Added function findGOR() to find the measured or Reference value for GOR for a stream object.
** 17.08.2016 johamlei ECPD-37553: Added function getWaterDisposalDays().
*****************************************************************/


FUNCTION calcDailyGrsStdVolFromEvents(p_object_id VARCHAR2, p_event_type VARCHAR2, p_daytime DATE)
RETURN NUMBER;

--
FUNCTION calcAvgBswVolFracMthToDay (
   	p_object_id stream.object_id%TYPE,
    	p_daytime     DATE,
   	p_bsw_method  VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

--

FUNCTION calcAvgGrsStdMass (
   	p_object_id stream.object_id%TYPE,
   	p_fromday      DATE,
   	p_today        DATE,
   	p_method       VARCHAR2 DEFAULT NULL,
   	p_null_is_zero VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION calcAvgGrsStdMassMthToDay (
   	p_object_id stream.object_id%TYPE,
   	p_daytime      DATE,
   	p_method       VARCHAR2 DEFAULT NULL,
    p_null_is_zero VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION calcAvgGrsStdMassYearToDay (
   	p_object_id stream.object_id%TYPE,
   	p_daytime      DATE,
   	p_method       VARCHAR2 DEFAULT NULL,
	p_null_is_zero VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION calcAvgGrsStdVol (
   	p_object_id stream.object_id%TYPE,
   	p_fromday      DATE,
   	p_today        DATE,
   	p_method       VARCHAR2 DEFAULT NULL,
	p_null_is_zero VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION calcAvgGrsStdVolMthToDay (
	p_object_id stream.object_id%TYPE,
	p_daytime      DATE,
	p_method       VARCHAR2 DEFAULT NULL,
	p_null_is_zero VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION calcAvgGrsStdVolYearToDay (
	p_object_id stream.object_id%TYPE,
	p_daytime      DATE,
	p_method       VARCHAR2 DEFAULT NULL,
	p_null_is_zero VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION calcAvgNetStdMass (
	p_object_id stream.object_id%TYPE,
	p_fromday      DATE,
	p_today        DATE,
	p_method       VARCHAR2 DEFAULT NULL,
	p_null_is_zero VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION calcAvgNetStdMassMthToDay (
	p_object_id stream.object_id%TYPE,
	p_daytime      DATE,
	p_method       VARCHAR2 DEFAULT NULL,
	p_null_is_zero VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION calcAvgNetStdMassYearToDay (
	p_object_id stream.object_id%TYPE,
	p_daytime      DATE,
	p_method       VARCHAR2 DEFAULT NULL,
	p_null_is_zero VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION calcAvgNetStdVol (
	p_object_id stream.object_id%TYPE,
	p_fromday      DATE,
	p_today        DATE,
	p_method       VARCHAR2 DEFAULT NULL,
	p_null_is_zero VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION calcAvgNetStdVolMthToDay (
	p_object_id stream.object_id%TYPE,
	p_daytime      DATE,
	p_method       VARCHAR2 DEFAULT NULL,
	p_null_is_zero VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION calcAvgGrsStdDensMthToDay (
	p_object_id stream.object_id%TYPE,
	p_daytime      DATE)
RETURN NUMBER;

--

FUNCTION calcAvgNetStdDensMthToDay (
	p_object_id stream.object_id%TYPE,
	p_daytime	 DATE,
	p_method  VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--
FUNCTION calcAvgNetStdVolYearToDay (
	p_object_id stream.object_id%TYPE,
	p_daytime      DATE,
	p_method       VARCHAR2 DEFAULT NULL,
	p_null_is_zero VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION calcCumGrsStdMassMthToDay (
	p_object_id stream.object_id%TYPE,
	p_daytime      DATE,
	p_method       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION calcCumGrsStdMassYearToDay (
	p_object_id stream.object_id%TYPE,
	p_daytime      DATE,
	p_method       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION calcCumGrsStdVolMthToDay (
	p_object_id stream.object_id%TYPE,
	p_daytime      DATE,
	p_method       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION calcCumGrsStdVolYearToDay (
	p_object_id stream.object_id%TYPE,
	p_daytime      DATE,
	p_method       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION calcCumNetStdMassMthToDay (
	p_object_id stream.object_id%TYPE,
	p_daytime      DATE,
	p_method       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION calcCumNetStdVolMthToDay (
	p_object_id stream.object_id%TYPE,
	p_daytime      DATE,
	p_method       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION calcCumNetStdMassYearToDay (
	p_object_id stream.object_id%TYPE,
	p_daytime      DATE,
	p_method       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION calcCumNetStdVolYearToDay (
	p_object_id stream.object_id%TYPE,
	p_daytime      DATE,
	p_method       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION calcGrsStdMassTotalToDay (
	p_object_id stream.object_id%TYPE,
	p_daytime      DATE,
	p_method       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION calcGrsStdVolTotalToDay (
	p_object_id stream.object_id%TYPE,
	p_daytime      DATE,
	p_method       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION calcNetStdDens (
	p_object_id stream.object_id%TYPE,
	p_daytime      DATE,
	p_method       VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

--

FUNCTION calcNetStdMassTotalToDay (
	p_object_id stream.object_id%TYPE,
	p_daytime      DATE,
	p_method       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION calcNetStdVolTotalToDay (
	p_object_id stream.object_id%TYPE,
	p_daytime      DATE,
	p_method       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION calcWatVol (
	p_object_id stream.object_id%TYPE,
	p_fromday      DATE,
	p_today        DATE DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION findGrsStdMass (
	p_object_id stream.object_id%TYPE,
	p_fromday      DATE,
	p_today        DATE DEFAULT NULL,
	p_method       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION findGrsStdVol (
	p_object_id stream.object_id%TYPE,
	p_fromday      DATE,
	p_today        DATE DEFAULT NULL,
	p_method       VARCHAR2 DEFAULT NULL,
	p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION findNetStdMass (
	p_object_id stream.object_id%TYPE,
	p_fromday      DATE,
	p_today        DATE DEFAULT NULL,
	p_method       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION findNetStdVol (
   	p_object_id stream.object_id%TYPE,
	p_fromday      DATE,
	p_today        DATE DEFAULT NULL,
	p_method       VARCHAR2 DEFAULT NULL,
	p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION findStdDens (
	p_object_id stream.object_id%TYPE,
	p_daytime      DATE,
	p_method       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION findWatDens (
	p_object_id stream.object_id%TYPE,
	p_daytime      DATE)
RETURN NUMBER;

--

FUNCTION findWatMass (
	p_object_id stream.object_id%TYPE,
	p_fromday      DATE,
	p_today        DATE DEFAULT NULL,
	p_method       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION findWatVol (
	p_object_id stream.object_id%TYPE,
	p_fromday      DATE,
	p_today        DATE DEFAULT NULL,
	p_method       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION findCondVol (
	p_object_id stream.object_id%TYPE,
	p_fromday      DATE,
	p_today        DATE DEFAULT NULL,
	p_method       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION findGOR(
  p_object_id stream.object_id%TYPE,
  p_fromday DATE,
  p_today DATE DEFAULT NULL,
  p_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION findCGR (
	p_object_id stream.object_id%TYPE,
	p_fromday      DATE,
	p_today        DATE DEFAULT NULL,
	p_method       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;


--


FUNCTION findWGR (
	p_object_id stream.object_id%TYPE,
	p_fromday      DATE,
	p_today        DATE DEFAULT NULL,
	p_method       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;


--


FUNCTION findWDF (
	p_object_id stream.object_id%TYPE,
	p_fromday      DATE,
	p_today        DATE DEFAULT NULL,
	p_method       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION find_grs_vol_by_pc(p_object_id VARCHAR2, p_profit_centre_id VARCHAR2, p_production_day DATE) RETURN NUMBER;

--

FUNCTION find_net_vol_by_pc(p_object_id VARCHAR2, p_profit_centre_id VARCHAR2, p_production_day DATE) RETURN NUMBER;

--

FUNCTION find_water_vol_by_pc(p_object_id VARCHAR2, p_profit_centre_id VARCHAR2, p_production_day DATE) RETURN NUMBER;

--

FUNCTION getBswVolFrac(
	p_object_id stream.object_id%TYPE,
	p_daytime     DATE,
	p_method      VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

--

FUNCTION getBswWeightFrac(
   	p_object_id stream.object_id%TYPE,
	p_daytime     DATE,
	p_method      VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

--

FUNCTION getSaltWeightFrac(
   	p_object_id stream.object_id%TYPE,
	p_daytime     DATE,
	p_method      VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

--

FUNCTION getStdDensCompAnalysis (
	p_object_id stream.object_id%TYPE,
	p_daytime       DATE,
	p_analysis_type VARCHAR2
   )
RETURN NUMBER;

--

FUNCTION getStdDensFromApiAnalysis (
	p_object_id stream.object_id%TYPE,
	p_daytime       	DATE,
	p_analysis_type  	VARCHAR2,
	p_sampling_method VARCHAR2,
	p_compare_oper		VARCHAR2 DEFAULT '=')
RETURN NUMBER;

--

FUNCTION getStdDensRefStream (
	p_object_id stream.object_id%TYPE,
	p_daytime       DATE)
RETURN NUMBER;

--


FUNCTION getAvgOilInWater (
	p_object_id stream.object_id%TYPE,
	p_fromday     DATE,
	p_today	  	 DATE DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION calcMthWeightedWaterFrac(
	p_object_id stream.object_id%TYPE,
	p_daytime DATE)
RETURN NUMBER;

--
FUNCTION calcgrsStdDens (
	p_object_id stream.object_id%TYPE,
	p_daytime      DATE,
	p_method       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findSpecificGravity(p_object_id stream.object_id%TYPE,
                             p_daytime date)
RETURN number;

FUNCTION agaStaticPress(p_object_id stream.object_id%TYPE,
                        p_daytime date,
                        p_class_name VARCHAR2 DEFAULT NULL)
RETURN number;

FUNCTION agaDiffStaticPress(p_object_id stream.object_id%TYPE,
                        p_daytime date,
                        p_class_name VARCHAR2 DEFAULT NULL)
RETURN number;

--

FUNCTION findGCV (
	p_object_id stream.object_id%TYPE,
	p_daytime      DATE,
	p_today        DATE     DEFAULT NULL,
	p_method       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION findEnergy (
     p_object_id    stream.object_id%TYPE,
     p_fromday      DATE,
     p_today        DATE     DEFAULT NULL,
     p_method       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION calcDailyRateTotalizer(
p_object_id stream.object_id%TYPE,
p_daytime   DATE)
RETURN NUMBER;


--

FUNCTION getLastNotNullClosingValueDate(
   p_object_id stream.object_id%TYPE,
   p_daytime DATE)
RETURN DATE;


--

FUNCTION find_net_mass_by_pc(
   p_object_id VARCHAR2,
   p_profit_centre_id VARCHAR2,
   p_production_day DATE)
RETURN NUMBER;

--

FUNCTION findPowerConsumption (
p_object_id stream.object_id%TYPE,
p_fromday   DATE,
p_today     DATE     DEFAULT NULL,
p_method    VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION findGrsDens (
	p_object_id stream.object_id%TYPE,
	p_daytime      DATE,
	p_method       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION getAttributeName(p_class_name VARCHAR2,
                           p_column_name VARCHAR2
                           )
RETURN VARCHAR2;

--

FUNCTION getVCF (
	p_object_id stream.object_id%TYPE,
	p_daytime   DATE,
	p_density   NUMBER,
  p_press     NUMBER,
  p_temp      NUMBER,
	p_method    VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findOnStreamHours (
	p_object_id stream.object_id%TYPE,
  p_fromday       DATE,
  p_today         DATE DEFAULT NULL,
  p_method        VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION calcShrunkVol(
	p_object_id stream.object_id%TYPE,
  p_fromday       DATE,
  p_today         DATE DEFAULT NULL,
  p_method        VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION calcDiluentVol(
	p_object_id stream.object_id%TYPE,
  p_fromday       DATE,
  p_today         DATE DEFAULT NULL,
  p_method        VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION getWaterDisposalDays(
	p_object_id stream.object_id%TYPE,
	p_daytime DATE)
RETURN NUMBER;

END EcBp_Stream_Fluid;