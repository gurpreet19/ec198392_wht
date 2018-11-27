CREATE OR REPLACE package body Ue_Stream_Fluid is
/****************************************************************
** Package        :  Ue_Stream_Fluid, body part
**
** Purpose        :  This package is used to program theoretical calculation when a predefined method supplied by EC does not cover the requirements.
**                   Upgrade processes will never replace this package.
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
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getBSWVol
-- Description    : Returns BS and W (volume)
---------------------------------------------------------------------------------------------------
FUNCTION getBSWVol(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getBSWVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getBSWWT
-- Description    : Returns BS and W (weight)
---------------------------------------------------------------------------------------------------
FUNCTION getBSWWT(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getBSWWT;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGCV
-- Description    : Returns GCV value
---------------------------------------------------------------------------------------------------
FUNCTION getGCV(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getGCV;

--<EC-DOC>

---------------------------------------------------------------------------------------------------
-- Function       : getGrsStdMass
-- Description    : Returns getGrsStdMass value
---------------------------------------------------------------------------------------------------
FUNCTION getGrsStdMass(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getGrsStdMass;

--<EC-DOC>

---------------------------------------------------------------------------------------------------
-- Function       : getGrsStdVol
-- Description    : Returns getGrsStdVol value
---------------------------------------------------------------------------------------------------
FUNCTION getGrsStdVol(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getGrsStdVol;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNetStdMass
-- Description    : Returns NetStdMass value
---------------------------------------------------------------------------------------------------
FUNCTION getNetStdMass(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getNetStdMass;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNetStdVol
-- Description    : Returns NetStdVol value
---------------------------------------------------------------------------------------------------
FUNCTION getNetStdVol(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getNetStdVol;

--<EC-DOC>

---------------------------------------------------------------------------------------------------
-- Function       : getWatVol
-- Description    : Returns getWatVol value
---------------------------------------------------------------------------------------------------
FUNCTION getWatVol(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getWatVol;

--<EC-DOC>

---------------------------------------------------------------------------------------------------
-- Function       : getCondVol
-- Description    : Returns getCondVol value
---------------------------------------------------------------------------------------------------
FUNCTION getCondVol(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getCondVol;

--<EC-DOC>

---------------------------------------------------------------------------------------------------
-- Function       : getEnergy
-- Description    : Returns getEnergy value
---------------------------------------------------------------------------------------------------
FUNCTION getEnergy(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getEnergy;

--<EC-DOC>

---------------------------------------------------------------------------------------------------
-- Function       : getStdDens
-- Description    : Returns getStdDens value
---------------------------------------------------------------------------------------------------
FUNCTION getStdDens(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getStdDens;

--<EC-DOC>

---------------------------------------------------------------------------------------------------
-- Function       : getWatMass
-- Description    : Returns getWatMass value
---------------------------------------------------------------------------------------------------
FUNCTION getWatMass(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getWatMass;

--<EC-DOC>

---------------------------------------------------------------------------------------------------
-- Function       : getGrsDens
-- Description    : Returns getGrsDens value
---------------------------------------------------------------------------------------------------
FUNCTION getGrsDens(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getGrsDens;

--<EC-DOC>

---------------------------------------------------------------------------------------------------
-- Function       : getVCF
-- Description    : Returns VCF value
---------------------------------------------------------------------------------------------------
FUNCTION getVCF(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getVCF;

--<EC-DOC>

---------------------------------------------------------------------------------------------------
-- Function       : findOnStreamHours
-- Description    : Returns On Stream Hours
---------------------------------------------------------------------------------------------------
FUNCTION findOnStreamHours(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END findOnStreamHours;

end Ue_Stream_Fluid;