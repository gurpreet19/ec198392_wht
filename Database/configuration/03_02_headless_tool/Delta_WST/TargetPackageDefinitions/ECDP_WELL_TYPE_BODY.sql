CREATE OR REPLACE PACKAGE BODY EcDp_Well_Type IS

/****************************************************************
** Package        :  EcDp_Well_Type, body part
**
** $Revision: 1.23 $
**
** Purpose        :  Defines well types.
**
** Documentation  :  www.energy-components.com
**
** Created  : 17.01.2000  Carl-Fredrik Sørensen
**
** Modification history:
**
** Version  Date      Whom      Change description:
** -------  ------    -----     --------------------------------------
** 1.0      17.01.00  CFS       Initial version
** 3.1      13.02.02  MNY       Added Function WASTE
**          03.12.04  DN        TI 1823: Removed dummy package constructor.
**          15.02.05  SJH       TI 1874: Added isOilProducer, isGasProducer
**                                       isWaterProducer, isGasInjector
**                                       isWaterInjector
**          27.12.05  BOHHHRON  TI#645: Added isSteamInjector, STEAM_INJECTOR
**          14.03.06  BOHHHRON  TI#3263: Added OIL_PRODUCER_STEAM_INJECTOR, updated isOilProducer and isSteamInjector
**          12.02.07  LAU       Fixed function isGasInjector
**          23.04.06  RAJARSAR  ECPD-4823: Added WATER_STEAM_INJECTOR and updated isWaterInjector and isSteamInjector
**          11.9.07   CHONGVIV  ECPD-6475: Added AIR_INJECTOR and updated isAirInjector
** EC9_4    28.01.08  Nurliza   ECPD-4848: Added function OBSERVATION, IsProducer, IsProducerOrOther, IsInjector, IsOther, IsNotOther,
**  (draft1)                                IsCondensateProducer, IsWasteInjector, findWellClass
** EC9_4    07.04.08  Nurliza   ECPD-7884: Added new functions SIM_WATER_GAS_INJECTION, WATER_INJECTION_FOR_DISPOSAL,
**  (draft1)                               and modified IS<flags> and findWellClass
**          21.08.08  RAJARSAR  ECPD-9038: Added isCo2Injector, CO2_INJECTOR
**          01.12.09  madondin  ECPD-11310: Added new function GAS_PRODUCER_2
**          30.12.09  madondin  ECPD-13477: added well type WATER_PRODUCER in isGasProducer
**          04.03.10  leongsei  ECPD-13942: Improve the design for function isOilProducer, isOilProducer, isGasProducer, isWaterProducer,
**                                              isGasInjector, isWaterInjector, isAirInjector, isSteamInjector, isProducer,
**                                              isProducerOrOther, isInjector, isOther, isNotOther, isCondensateProducer,
**                                              isWasteInjector, isCO2Injector, findWellClass
**	    29.04.10  madondin	ECPD-14324: Modified in function isWaterProducer added well type GP2
*****************************************************************/


FUNCTION CLOSED
RETURN VARCHAR2 IS

BEGIN

   RETURN 'CL';

END CLOSED;

--

FUNCTION CONDENSATE_PRODUCER
RETURN VARCHAR2 IS

BEGIN

   RETURN 'CP';

END CONDENSATE_PRODUCER;

--

FUNCTION GAS_INJECTOR
RETURN VARCHAR2 IS

BEGIN

   RETURN 'GI';

END GAS_INJECTOR;

--

FUNCTION AIR_INJECTOR
RETURN VARCHAR2 IS

BEGIN

   RETURN 'AI';

END AIR_INJECTOR;

--

FUNCTION CO2_INJECTOR
RETURN VARCHAR2 IS

BEGIN

   RETURN 'CI';

END CO2_INJECTOR;

--

FUNCTION GAS_PRODUCER
RETURN VARCHAR2 IS

BEGIN

   RETURN 'GP';

END GAS_PRODUCER;

--

FUNCTION OIL_PRODUCER
RETURN VARCHAR2 IS

BEGIN

   RETURN 'OP';

END OIL_PRODUCER;

--

FUNCTION WATER_GAS_INJECTOR
RETURN VARCHAR2 IS

BEGIN

   RETURN 'WG';

END WATER_GAS_INJECTOR;

--

FUNCTION WATER_STEAM_INJECTOR
RETURN VARCHAR2 IS

BEGIN

   RETURN 'WSI';

END WATER_STEAM_INJECTOR;

--

FUNCTION WATER_PRODUCER
RETURN VARCHAR2 IS

BEGIN

   RETURN 'WP';

END WATER_PRODUCER;

--

FUNCTION WATER_INJECTOR
RETURN VARCHAR2 IS

BEGIN

   RETURN 'WI';

END WATER_INJECTOR;

--

FUNCTION WATER_SOURCE
RETURN VARCHAR2 IS

BEGIN

   RETURN 'WS';

END WATER_SOURCE;

--

FUNCTION WASTE
RETURN VARCHAR2 IS

BEGIN

   RETURN 'WA';

END WASTE;

--

FUNCTION OIL_PRODUCER_GAS_INJECTOR
RETURN VARCHAR2 IS

BEGIN

   RETURN 'OPGI';

END OIL_PRODUCER_GAS_INJECTOR;

--

FUNCTION GAS_PRODUCER_INJECTOR
RETURN VARCHAR2 IS

BEGIN

   RETURN 'GPI';

END GAS_PRODUCER_INJECTOR;

--

FUNCTION STEAM_INJECTOR
RETURN VARCHAR2 IS

BEGIN

   RETURN 'SI';

END STEAM_INJECTOR;

--

FUNCTION OIL_PRODUCER_STEAM_INJECTOR
RETURN VARCHAR2 IS

BEGIN

   RETURN 'OPSI';

END OIL_PRODUCER_STEAM_INJECTOR;

--

FUNCTION OBSERVATION
RETURN VARCHAR2 IS

BEGIN

   RETURN 'OB';

END OBSERVATION;

--

FUNCTION SIM_WATER_GAS_INJECTION
RETURN VARCHAR2 IS

BEGIN

   RETURN 'SWG';

END SIM_WATER_GAS_INJECTION;

--

FUNCTION WATER_INJECTION_FOR_DISPOSAL
RETURN VARCHAR2 IS

BEGIN

   RETURN 'WID';

END WATER_INJECTION_FOR_DISPOSAL;


------------------------------------------------------------------------------
-- Function : isOilProducer
-- Description : Return IS_TRUE string if the well type is an Oil Producer
--               or Oil Producer - Gas Injector or Oil Producer - Steam Injector
--               or Gas Producer - (Gas/Oil/Wat)
------------------------------------------------------------------------------
FUNCTION isOilProducer(p_well_type VARCHAR2)
RETURN VARCHAR2 IS

BEGIN

   IF  p_well_type IN (EcDp_Well_Type.OIL_PRODUCER,
                       EcDp_Well_Type.OIL_PRODUCER_GAS_INJECTOR,
                       EcDp_Well_Type.OIL_PRODUCER_STEAM_INJECTOR,
                       EcDp_Well_Type.GAS_PRODUCER_2)
   THEN
      RETURN ECDP_TYPE.IS_TRUE;
   ELSE
      RETURN ECDP_TYPE.IS_FALSE;
   END IF;

END isOilProducer;


------------------------------------------------------------------------------
-- Function : isGasProducer
-- Description : Return IS_TRUE string if the well type is a Gas Producer
--               or Gas Producer - Injector or Gas Producer - (Gas/Oil/Wat)
--               or Water Producer(Water and Gas)
------------------------------------------------------------------------------
FUNCTION isGasProducer(p_well_type VARCHAR2)
RETURN VARCHAR2 IS

BEGIN

   IF  p_well_type IN (EcDp_Well_Type.GAS_PRODUCER,
                       EcDp_Well_Type.GAS_PRODUCER_INJECTOR,
                       EcDp_Well_Type.GAS_PRODUCER_2,
                       EcDp_Well_Type.WATER_PRODUCER)
   THEN
      RETURN ECDP_TYPE.IS_TRUE;
   ELSE
      RETURN ECDP_TYPE.IS_FALSE;
   END IF;

END isGasProducer;


------------------------------------------------------------------------------
-- Function : isWaterProducer
-- Description : Return IS_TRUE string if the well type is a Water Producer
--               or Water Source or Gas Producer - (Gas/Oil/Water)
------------------------------------------------------------------------------
FUNCTION isWaterProducer(p_well_type VARCHAR2)
RETURN VARCHAR2 IS

BEGIN

   IF  p_well_type IN (EcDp_Well_Type.WATER_PRODUCER,
                       EcDp_Well_Type.WATER_SOURCE,
                       EcDp_Well_Type.GAS_PRODUCER_2)
   THEN
      RETURN ECDP_TYPE.IS_TRUE;
   ELSE
      RETURN ECDP_TYPE.IS_FALSE;
   END IF;

END isWaterProducer;


------------------------------------------------------------------------------
-- Function : isGasInjector
-- Description : Return IS_TRUE string if the well type is a Gas Injector
--               or Oil Producer - Gas Injector or Water - Gas - Injector
--               or Gas Producer - Injector or Sim. Water and Gas Inj
------------------------------------------------------------------------------
FUNCTION isGasInjector(p_well_type VARCHAR2)
RETURN VARCHAR2 IS

BEGIN

   IF  p_well_type IN (EcDp_Well_Type.GAS_INJECTOR,
                       EcDp_Well_Type.OIL_PRODUCER_GAS_INJECTOR,
                       EcDp_Well_Type.WATER_GAS_INJECTOR,
                       EcDp_Well_Type.GAS_PRODUCER_INJECTOR,
                       EcDp_Well_Type.SIM_WATER_GAS_INJECTION)
   THEN
      RETURN ECDP_TYPE.IS_TRUE;
   ELSE
      RETURN ECDP_TYPE.IS_FALSE;
   END IF;

END isGasInjector;


------------------------------------------------------------------------------
-- Function : isWaterInjector
-- Description : Return IS_TRUE string if the well type is a Water Injector
--               or Water - Gas Injector or Water - Steam Injector or Sim. Water and Gas Inj
--               or Water Injection for Disposal
------------------------------------------------------------------------------
FUNCTION isWaterInjector(p_well_type VARCHAR2)
RETURN VARCHAR2 IS

BEGIN

   IF  p_well_type IN (EcDp_Well_Type.WATER_INJECTOR,
                       EcDp_Well_Type.WATER_GAS_INJECTOR,
                       EcDp_Well_Type.WATER_STEAM_INJECTOR,
                       EcDp_Well_Type.SIM_WATER_GAS_INJECTION,
                       EcDp_Well_Type.WATER_INJECTION_FOR_DISPOSAL)
   THEN
      RETURN ECDP_TYPE.IS_TRUE;
   ELSE
      RETURN ECDP_TYPE.IS_FALSE;
   END IF;

END isWaterInjector;


------------------------------------------------------------------------------
-- Function : isAirInjector
-- Description : Return IS_TRUE string if the well type is an Air Injector
--
------------------------------------------------------------------------------
FUNCTION isAirInjector(p_well_type VARCHAR2)
RETURN VARCHAR2 IS

BEGIN

   IF  p_well_type IN (EcDp_Well_Type.AIR_INJECTOR)
   THEN
      RETURN ECDP_TYPE.IS_TRUE;
   ELSE
      RETURN ECDP_TYPE.IS_FALSE;
   END IF;

END isAirInjector;


------------------------------------------------------------------------------
-- Function : isSteamInjector
-- Description : Return IS_TRUE string if the well type is a Steam Injector
--               or Oil Producer - Steam - Injector or Water and Steam Injector
------------------------------------------------------------------------------
FUNCTION isSteamInjector(p_well_type VARCHAR2)
RETURN VARCHAR2 IS

BEGIN

   IF  p_well_type IN (EcDp_Well_Type.STEAM_INJECTOR,
                       EcDp_Well_Type.OIL_PRODUCER_STEAM_INJECTOR,
                       EcDp_Well_Type.WATER_STEAM_INJECTOR)
   THEN
      RETURN ECDP_TYPE.IS_TRUE;
   ELSE
      RETURN ECDP_TYPE.IS_FALSE;
   END IF;

END isSteamInjector;

--
------------------------------------------------------------------------------
-- Function : isProducer
-- Description : Return IS_TRUE string if the well type is a Oil Producer or Condensate Producer
--               or Oil Producer Gas Injector or Oil Producer Steam injector or Gas Producer or
--               Gas Producer Injector or Water Source or Gas Producer (Gas/Oil/Wat) or Water Producer (Water and Gas)
------------------------------------------------------------------------------
FUNCTION isProducer(p_well_type VARCHAR2)
RETURN VARCHAR2 IS

BEGIN

   IF (EcDp_Well_Type.isOilProducer(p_well_type) = ECDP_TYPE.IS_TRUE
    OR EcDp_Well_Type.isGasProducer(p_well_type) = ECDP_TYPE.IS_TRUE
    OR EcDp_Well_Type.isWaterProducer(p_well_type) = ECDP_TYPE.IS_TRUE
    OR EcDp_Well_Type.isCondensateProducer(p_well_type) = ECDP_TYPE.IS_TRUE)
   THEN
      RETURN ECDP_TYPE.IS_TRUE;
   ELSE
      RETURN ECDP_TYPE.IS_FALSE;
   END IF;

END isProducer;

--
------------------------------------------------------------------------------
-- Function : isProducerOrOther
-- Description : Return IS_TRUE string if the well type is a Oil Producer or Condensate Producer
--               or Oil Producer Gas Injector or Oil Producer Steam injector or Gas Producer or
--               Gas Producer Injector or Water Producer (Water and Gas) or Water Source or Observation or
--               Gas Producer (Gas/Oil/Wat)
------------------------------------------------------------------------------
FUNCTION isProducerOrOther(p_well_type VARCHAR2)
RETURN VARCHAR2 IS

BEGIN

   IF (EcDp_Well_Type.isProducer(p_well_type) = ECDP_TYPE.IS_TRUE
    or EcDp_Well_Type.isOther(p_well_type) = ECDP_TYPE.IS_TRUE)
   THEN
      RETURN ECDP_TYPE.IS_TRUE;
   ELSE
      RETURN ECDP_TYPE.IS_FALSE;
   END IF;

END isProducerOrOther;

--
------------------------------------------------------------------------------
-- Function : isInjector
-- Description : Return IS_TRUE string if the well type is a OPGI, OPSI, GPI,
--               GI, WSI, WI, WG, AI, SI, WA, SWG, WID, CI
------------------------------------------------------------------------------
FUNCTION isInjector(p_well_type VARCHAR2)
RETURN VARCHAR2 IS

BEGIN

   IF (EcDp_Well_Type.isGasInjector(p_well_type) = ECDP_TYPE.IS_TRUE
    OR EcDp_Well_Type.isWaterInjector(p_well_type) = ECDP_TYPE.IS_TRUE
    OR EcDp_Well_Type.isAirInjector(p_well_type) = ECDP_TYPE.IS_TRUE
    OR EcDp_Well_Type.isSteamInjector(p_well_type) = ECDP_TYPE.IS_TRUE
    OR EcDp_Well_Type.isWasteInjector(p_well_type) = ECDP_TYPE.IS_TRUE
    OR EcDp_Well_Type.isCO2Injector(p_well_type) = ECDP_TYPE.IS_TRUE)
   THEN
      RETURN ECDP_TYPE.IS_TRUE;
   ELSE
      RETURN ECDP_TYPE.IS_FALSE;
   END IF;

END isInjector;

--
------------------------------------------------------------------------------
-- Function : isOther
-- Description : Return IS_TRUE string if the well type is Observation
------------------------------------------------------------------------------
FUNCTION isOther(p_well_type VARCHAR2)
RETURN VARCHAR2 IS

BEGIN

   IF p_well_type IN (EcDp_Well_Type.OBSERVATION)
   THEN
      RETURN ECDP_TYPE.IS_TRUE;
   ELSE
      RETURN ECDP_TYPE.IS_FALSE;
   END IF;

END isOther;

--
------------------------------------------------------------------------------
-- Function : isNotOther
-- Description : Return IS_TRUE string if the well type is a OP, CP, OPGI, OPSI, GP, GPI,
--               WS, GI, WSI, WI, WG, AI, SI, WA,CI, SWG, WID, GP2
------------------------------------------------------------------------------
FUNCTION isNotOther(p_well_type VARCHAR2)
RETURN VARCHAR2 IS

BEGIN

   IF (EcDp_Well_Type.isOther(p_well_type) = ECDP_TYPE.IS_FALSE)
   THEN
      RETURN ECDP_TYPE.IS_TRUE;
   ELSE
      RETURN ECDP_TYPE.IS_FALSE;
   END IF;

END isNotOther;

--
------------------------------------------------------------------------------
-- Function : isCondensateProducer
-- Description : Return IS_TRUE string if the well type is Condensate Producer
------------------------------------------------------------------------------
FUNCTION isCondensateProducer(p_well_type VARCHAR2)
RETURN VARCHAR2 IS

BEGIN

   IF p_well_type IN (EcDp_Well_Type.CONDENSATE_PRODUCER)
   THEN
      RETURN ECDP_TYPE.IS_TRUE;
   ELSE
      RETURN ECDP_TYPE.IS_FALSE;
   END IF;

END isCondensateProducer;

--
-----------------------------------------------------------------------------
-- Function : isWasteInjector
-- Description : Return IS_TRUE string if the well type is Waste
------------------------------------------------------------------------------
FUNCTION isWasteInjector(p_well_type VARCHAR2)
RETURN VARCHAR2 IS

BEGIN

   IF p_well_type IN (EcDp_Well_Type.WASTE)
   THEN
      RETURN ECDP_TYPE.IS_TRUE;
   ELSE
      RETURN ECDP_TYPE.IS_FALSE;
   END IF;

END isWasteInjector;

--
-----------------------------------------------------------------------------
-- Function : isCO2Injector
-- Description : Return IS_TRUE string if the well type is CO2 Injector
------------------------------------------------------------------------------
FUNCTION isCO2Injector(p_well_type VARCHAR2)
RETURN VARCHAR2 IS

BEGIN

   IF p_well_type IN (EcDp_Well_Type.CO2_INJECTOR)
   THEN
      RETURN ECDP_TYPE.IS_TRUE;
   ELSE
      RETURN ECDP_TYPE.IS_FALSE;
   END IF;

END isCO2Injector;

--
-----------------------------------------------------------------------------
-- Function : findWellClass
-- Description : Return WELL_CLASS for selected WELL_TYPE
------------------------------------------------------------------------------
FUNCTION findWellClass(p_well_type VARCHAR2)
RETURN VARCHAR2 IS

BEGIN

   IF (EcDp_Well_Type.isProducer(p_well_type) = ECDP_TYPE.IS_TRUE AND EcDp_Well_Type.isInjector(p_well_type) = ECDP_TYPE.IS_FALSE) THEN
      RETURN 'P';
   ELSIF (EcDp_Well_Type.isProducer(p_well_type) = ECDP_TYPE.IS_TRUE AND EcDp_Well_Type.isInjector(p_well_type) = ECDP_TYPE.IS_TRUE) THEN
      RETURN 'PI';
   ELSIF (EcDp_Well_Type.isProducer(p_well_type) = ECDP_TYPE.IS_FALSE AND EcDp_Well_Type.isInjector(p_well_type) = ECDP_TYPE.IS_TRUE) THEN
      RETURN 'I';
   ELSIF EcDp_Well_Type.isOther(p_well_type) = ECDP_TYPE.IS_TRUE THEN
      RETURN 'O';
   ELSE
      RETURN NULL;
   END IF;

END findWellClass;

--

FUNCTION GAS_PRODUCER_2
RETURN VARCHAR2 IS

BEGIN

   RETURN 'GP2';

END GAS_PRODUCER_2;


END EcDp_Well_Type;