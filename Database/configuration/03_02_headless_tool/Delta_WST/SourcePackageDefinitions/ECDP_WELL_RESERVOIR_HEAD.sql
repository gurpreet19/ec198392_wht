CREATE OR REPLACE PACKAGE EcDp_Well_Reservoir IS
/****************************************************************
** Package      :  EcDp_Well_Reservoir, header part
**
** $Revision: 1.14 $
**
** Purpose      :  This package defines well/reservoir related
**                 functionality.
**
** Documentation:  www.energy-components.com
**
** Created      : 02.12.1999  Carl-Fredrik S�sen
**
** Modification history:
**
** Version      Date            Whom    Change description:
** -------      ------  ----- -----------------------------------
**  1.0         02-12-1999      CFS     First Version
**  3.1         06-03-2002      DN      Added procedures createWellBore and createWellBoreInterval.
**		          11.08.2004      mazrina removed sysnam and update as necessary
**              28.11.2005      ROV     TI2742: Added new function getResvBlockFormPhaseFraction
**              01.12.2005      ROV     TI2742: Due to performance problems method getResvBlockFormPhaseFraction have been replaced by new method getWellRBFPhaseFraction
** 		          30.08.2006 	    HUS	    TI3154: Added getWellCoEntPhaseFraction
**  9.1.0       28.09.2006    zakiiari  TI#2610: Added SetWeboIntervalShareEndDate
**  9.1.0       08.11.2006    zakiiari  TI#4512: Added CreateNewPerfIntervalShare, setPerfIntervalShareEndDate, validatePerfIntervalSplit
** 	1.26		    13.03.2007    rajarsar  ECPD-3709: Updated  getWellRBFPhaseFraction,validatePerfIntervalSplit, validateWeboIntervalSplit to include water inj and gas inj
**              11.10.2007    Lau       ECPD-6612:  Added daytime parameter to getRefQualityStream function
**              05.11.2009    farhaann  ECPD-12788: Added getReservoirBlockGasInjFrac(),getReservoirBlockWatInjFrac() and getReservoirBlockSteamInjFrac().
** 				19.01.2012    choonshu	ECPD-19821: Added validateWeboSplitFactor procedure
**              18.07.2017 kashisag   ECPD-45817: Replaced sysdate with Ecdp_Timestamp.getCurrentSysdate
*****************************************************************/

--

PROCEDURE validateWeboIntervalSplit(
         p_well_bore_id    VARCHAR2,
         p_daytime         DATE);

PROCEDURE createWellBore (
   p_object_id well.object_id%TYPE,
   p_bore_id VARCHAR2,
   p_start_date VARCHAR2
);

PROCEDURE createWellBoreInterval (
   p_object_id well.object_id%TYPE,
   p_bore_id webo_bore.object_id%TYPE,
   p_interval_id varchar2,
   p_zone VARCHAR2,
   p_block VARCHAR2,
   p_start_date VARCHAR2
);

FUNCTION findBlockFormationStream(
   p_stream_phase IN VARCHAR2,
   p_block_id  IN resv_block.object_id%TYPE,
   p_formation_id IN resv_formation.object_id%TYPE)

RETURN VARCHAR2;

--
FUNCTION getBlockFormationStream(
   p_stream_phase IN VARCHAR2,
   p_block_id  IN resv_block.object_id%TYPE,
   p_formation_id IN resv_formation.object_id%TYPE)

RETURN VARCHAR2;

--

FUNCTION getFirstWellPerfFaultBlock(
   p_well_id IN VARCHAR2)

RETURN VARCHAR2;

--

FUNCTION getFirstWellPerfFormation(
   p_well_id IN VARCHAR2)

RETURN VARCHAR2;

--

FUNCTION getRefQualityStream(
   p_well_id IN VARCHAR2,
   p_phase   IN VARCHAR2,
   p_daytime IN DATE DEFAULT TRUNC(Ecdp_Timestamp.getCurrentSysdate))

RETURN VARCHAR2;

--

FUNCTION getReservoirBlockConFraction(
  p_object_id well.object_id%TYPE,
	p_block_id  IN resv_block.object_id%TYPE,
  p_formation_id IN resv_formation.object_id%TYPE,
  p_daytime        DATE)

RETURN NUMBER;

--

FUNCTION getReservoirBlockGasFraction(
  p_object_id well.object_id%TYPE,
	p_block_id  IN resv_block.object_id%TYPE,
  p_formation_id IN resv_formation.object_id%TYPE,
	p_daytime        DATE)

RETURN NUMBER;

--

FUNCTION getReservoirBlockOilFraction(
  p_object_id well.object_id%TYPE,
	p_block_id  IN resv_block.object_id%TYPE,
  p_formation_id IN resv_formation.object_id%TYPE,
  p_daytime        DATE)

RETURN NUMBER;

--

FUNCTION getReservoirBlockPhaseFraction(
  p_object_id well.object_id%TYPE,
	p_block_id  IN resv_block.object_id%TYPE,
  p_formation_id IN resv_formation.object_id%TYPE,
	p_daytime        DATE,
	p_phase			  VARCHAR2)

RETURN NUMBER;

--

FUNCTION getReservoirBlockWatFraction(
  p_object_id well.object_id%TYPE,
	p_block_id  IN resv_block.object_id%TYPE,
  p_formation_id IN resv_formation.object_id%TYPE,
	p_daytime        DATE)

RETURN NUMBER;

--

FUNCTION getReservoirBlockGasInjFrac(
  p_object_id well.object_id%TYPE,
  p_block_id IN resv_block.object_id%TYPE,
  p_formation_id IN resv_formation.object_id%TYPE,
  p_daytime DATE)

RETURN NUMBER;

--

FUNCTION getReservoirBlockWatInjFrac(
  p_object_id well.object_id%TYPE,
  p_block_id IN resv_block.object_id%TYPE,
  p_formation_id IN resv_formation.object_id%TYPE,
  p_daytime DATE)

RETURN NUMBER;

--

FUNCTION getReservoirBlockSteamInjFrac(
  p_object_id well.object_id%TYPE,
  p_block_id IN resv_block.object_id%TYPE,
  p_formation_id IN resv_formation.object_id%TYPE,
  p_daytime DATE)

RETURN NUMBER;

--

PROCEDURE CreateNewWellBoreIntervalShare(
        p_owner_object_id     VARCHAR2,
        p_daytime             DATE,
        p_class_name          VARCHAR2
        );

PROCEDURE setWeboIntervalShareEndDate(
        p_owner_object_id     VARCHAR2,
        p_daytime             DATE,
        p_class_name          VARCHAR2
        );

FUNCTION getWellRBFPhaseFraction(
        p_well_id well.object_id%TYPE,
        p_resv_block_form_id IN resv_block_formation.object_id%TYPE,
	p_daytime DATE,
	p_phase_direction	VARCHAR2)

RETURN NUMBER;

FUNCTION getWellCoEntPhaseFraction(
  p_well_id                        well.object_id%TYPE,
	p_coent_id                 commercial_entity.object_id%TYPE,
	p_daytime                  DATE,
	p_phase	                   VARCHAR2)

RETURN NUMBER;

PROCEDURE CreateNewPerfIntervalShare(
        p_owner_object_id     VARCHAR2,
        p_daytime             DATE,
        p_class_name          VARCHAR2
        );

PROCEDURE setPerfIntervalShareEndDate(
        p_owner_object_id     VARCHAR2,
        p_daytime             DATE,
        p_class_name          VARCHAR2
        );

PROCEDURE validatePerfIntervalSplit(
         p_well_bore_interval_id    VARCHAR2,
         p_daytime                  DATE);

PROCEDURE validateWeboSplitFactor(
         p_well_id    VARCHAR2,
         p_daytime         DATE);

END;