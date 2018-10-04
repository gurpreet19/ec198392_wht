CREATE OR REPLACE PACKAGE EcDp_Well_Type IS

/****************************************************************
** Package        :  EcDp_Well_Type, header part
**
** $Revision: 1.13 $
**
** Purpose        :  Defines well types.
**
** Documentation  :  www.energy-components.com
**
** Created  : 18.01.2000  Carl-Fredrik S?sen
**
** Modification history:
**
** Version      Date      Whom      Change description:
** -------      ------    -----     --------------------------------------
** 1.0          18.01.00  CFS       Initial version
** 3.1          13.02.02  MNY       Added Function WASTE
**              15.02.05  SJH       TI 1874: Added isOilProducer, isGasProducer
**                                           isWaterProducer, isGasInjector
**                                           isWaterInjector
** 	            27.12.05  BOHHHRON	TI#645: Added isSteamInjector, STEAM_INJECTOR
**	            14.03.06  BOHHHRON	TI#3263: Added OIL_PRODUCER_STEAM_INJECTOR
** 1.9          23.04.06  RAJARSAR	ECPD-4823: Added WATER_STEAM_INJECTOR
**	            11.09.06  CHONGVIV  ECPD-6267: Added AIR_INJECTOR
** EC9_4 draft1 28.01.08  Nurliza   ECPD-4848: Added function OBSERVATION, IsProducer, IsProducerOrOther, IsInjector, IsOther, IsNotOther,
**                                             IsCondensateProducer, IsWasteInjector, findWellClass
** EC9_4 draft1 07.04.08  Nurliza   ECPD-7884: Added new functions SIM_WATER_GAS_INJECTION, WATER_INJECTION_FOR_DISPOSAL, and modified IS<flags> and findWellClass
**	            21.08.08  RAJARSAR  ECPD-9038: Added isCo2Injector, CO2_INJECTOR
**              01.12.09  madondin  ECPD-11310: Added new function GAS_PRODUCER_2
*****************************************************************/

--

FUNCTION CLOSED
RETURN VARCHAR2;

--

FUNCTION CONDENSATE_PRODUCER
RETURN VARCHAR2;

--

FUNCTION GAS_INJECTOR
RETURN VARCHAR2;

--

FUNCTION GAS_PRODUCER
RETURN VARCHAR2;

--

FUNCTION OIL_PRODUCER
RETURN VARCHAR2;

--

FUNCTION WATER_GAS_INJECTOR
RETURN VARCHAR2;

--

FUNCTION WATER_STEAM_INJECTOR
RETURN VARCHAR2;

--

FUNCTION WATER_INJECTOR
RETURN VARCHAR2;

--

FUNCTION WATER_PRODUCER
RETURN VARCHAR2;

--

FUNCTION WATER_SOURCE
RETURN VARCHAR2;

--

FUNCTION WASTE
RETURN VARCHAR2;

--

FUNCTION OIL_PRODUCER_GAS_INJECTOR
RETURN VARCHAR2;

--

FUNCTION GAS_PRODUCER_INJECTOR
RETURN VARCHAR2;

--

FUNCTION STEAM_INJECTOR
RETURN VARCHAR2;

--

FUNCTION AIR_INJECTOR
RETURN VARCHAR2;

--

FUNCTION OIL_PRODUCER_STEAM_INJECTOR
RETURN VARCHAR2;

--

FUNCTION OBSERVATION
RETURN VARCHAR2;

--

FUNCTION SIM_WATER_GAS_INJECTION
RETURN VARCHAR2;

--

FUNCTION WATER_INJECTION_FOR_DISPOSAL
RETURN VARCHAR2;

--

FUNCTION CO2_INJECTOR
RETURN VARCHAR2;

--

FUNCTION isOilProducer(p_well_type VARCHAR2)
RETURN VARCHAR2;

--

FUNCTION isGasProducer(p_well_type VARCHAR2)
RETURN VARCHAR2;

--

FUNCTION isWaterProducer(p_well_type VARCHAR2)
RETURN VARCHAR2;

--

FUNCTION isGasInjector(p_well_type VARCHAR2)
RETURN VARCHAR2;

--

FUNCTION isWaterInjector(p_well_type VARCHAR2)
RETURN VARCHAR2;

--

FUNCTION isSteamInjector(p_well_type VARCHAR2)
RETURN VARCHAR2;

--

FUNCTION isAirInjector(p_well_type VARCHAR2)
RETURN VARCHAR2;

--

FUNCTION isProducer(p_well_type VARCHAR2)
RETURN VARCHAR2;

--

FUNCTION isProducerOrOther(p_well_type VARCHAR2)
RETURN VARCHAR2;

--

FUNCTION isInjector(p_well_type VARCHAR2)
RETURN VARCHAR2;

--

FUNCTION isOther(p_well_type VARCHAR2)
RETURN VARCHAR2;

--

FUNCTION isNotOther(p_well_type VARCHAR2)
RETURN VARCHAR2;

--

FUNCTION isCondensateProducer(p_well_type VARCHAR2)
RETURN VARCHAR2;

--

FUNCTION isWasteInjector(p_well_type VARCHAR2)
RETURN VARCHAR2;

--

FUNCTION isCO2Injector(p_well_type VARCHAR2)
RETURN VARCHAR2;

--

FUNCTION findWellClass(p_well_type VARCHAR2)
RETURN VARCHAR2;

--

FUNCTION GAS_PRODUCER_2
RETURN VARCHAR2;


END EcDp_Well_Type;