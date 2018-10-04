CREATE OR REPLACE package Ue_Stream_Fluid is

/****************************************************************
** Package        :  Ue_Stream_Fluid
**
** Modification history:
**
** Date        Whom     Change description:
** ---------   -------- --------------------------------------
** 21.12.2007  oonnnng  ECPD-6716: Add getBSWVol and getBSWWT function.
** 20.02.2008  oonnnng	ECPD-6978: Add getGCV function.
** 09.02.2009  farhaann ECPD-10761: Added getNetStdMass, getGrsStdMass, getWatVol, getCondVol, getEnergy,
**                                  getStdDens, getWatMass and getGrsDens functions.
** 03.08.09    embonhaf ECPD-11153 Added VCF calculation for stream.
** 19.11.2009  leongwen ECPD-13175 Added findOnStreamHours function.
** 09.01.2013  hismahas ECPD-22580 Added getGrsStdVol and getNetStdVol functions.
** 08.05.2013  musthram ECPD-23714 Added  getPowerConsumption and getSaltWT functions.
** 03.03.2014  dhavaalo ECPD-26738 Package ue_stream_fluid is missing the parameter P_TODATE in all functions
****************************************************************/

FUNCTION getBSWVol(
      p_object_id    stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER;

FUNCTION getBSWWT(
      p_object_id    stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER;

FUNCTION getGCV(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE,
      p_today       DATE DEFAULT NULL)
RETURN NUMBER;

FUNCTION getGrsStdMass(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE,
      p_today       DATE DEFAULT NULL)
RETURN NUMBER;

FUNCTION getGrsStdVol(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE,
      p_today       DATE DEFAULT NULL)
RETURN NUMBER;

FUNCTION getNetStdMass(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE,
      p_today       DATE DEFAULT NULL)
RETURN NUMBER;

FUNCTION getNetStdVol(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE,
      p_today       DATE DEFAULT NULL)
RETURN NUMBER;

FUNCTION getWatVol(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE,
      p_today       DATE DEFAULT NULL)
RETURN NUMBER;

FUNCTION getCondVol(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE,
      p_today       DATE DEFAULT NULL)
RETURN NUMBER;

FUNCTION getEnergy(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE,
      p_today       DATE DEFAULT NULL)
RETURN NUMBER;

FUNCTION getStdDens(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER;

FUNCTION getWatMass(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE,
      p_today       DATE DEFAULT NULL)
RETURN NUMBER;

FUNCTION getGrsDens(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER;

FUNCTION getVCF(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER;

FUNCTION getPowerConsumption(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE,
      p_today       DATE DEFAULT NULL)
RETURN NUMBER;

FUNCTION getSaltWT(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER;

FUNCTION findOnStreamHours(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE,
      p_today       DATE DEFAULT NULL)
RETURN NUMBER;

end Ue_Stream_Fluid;