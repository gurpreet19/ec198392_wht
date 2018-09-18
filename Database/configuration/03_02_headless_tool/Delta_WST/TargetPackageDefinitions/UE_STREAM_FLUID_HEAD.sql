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
** 05.01.2013  hismahas ECPD-22994 Added getGrsStdVol and getNetStdVol functions.
****************************************************************/

FUNCTION getBSWVol(
      p_object_id    stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getBSWVol, WNDS, WNPS, RNPS);

FUNCTION getBSWWT(
      p_object_id    stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getBSWWT, WNDS, WNPS, RNPS);

FUNCTION getGCV(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getGCV, WNDS, WNPS, RNPS);

FUNCTION getGrsStdMass(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getGrsStdMass, WNDS, WNPS, RNPS);

FUNCTION getGrsStdVol(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getGrsStdVol, WNDS, WNPS, RNPS);

FUNCTION getNetStdMass(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getNetStdMass, WNDS, WNPS, RNPS);

FUNCTION getNetStdVol(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getNetStdVol, WNDS, WNPS, RNPS);

FUNCTION getWatVol(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getWatVol, WNDS, WNPS, RNPS);

FUNCTION getCondVol(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getCondVol, WNDS, WNPS, RNPS);

FUNCTION getEnergy(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getEnergy, WNDS, WNPS, RNPS);

FUNCTION getStdDens(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getStdDens, WNDS, WNPS, RNPS);

FUNCTION getWatMass(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getWatMass, WNDS, WNPS, RNPS);

FUNCTION getGrsDens(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getGrsDens, WNDS, WNPS, RNPS);

FUNCTION getVCF(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getVCF, WNDS, WNPS, RNPS);

FUNCTION findOnStreamHours(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(findOnStreamHours, WNDS, WNPS, RNPS);

end Ue_Stream_Fluid;