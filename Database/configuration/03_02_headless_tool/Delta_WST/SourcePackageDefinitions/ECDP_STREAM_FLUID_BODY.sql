CREATE OR REPLACE PACKAGE BODY EcDp_Stream_Fluid IS
/****************************************************************
** Package        :  EcDp_Stream_Fluid; body part
**
** $Revision: 1.16 $
**
** Purpose        :  This package is responsible for stream fluid data services
**
** Documentation  :  www.energy-components.com
**
** Created        :  06.12.1999  Carl-Fredrik S�sen
**
** Modification history:
**
** Date        Whom      Change description:
** ------      -----     --------------------------------------
** 06.12.1999  CFS       First version
** 03.04.2001  KEJ       Documented functions and procedures.
** 07.06.2001  KB        Changes made for Phillips (implemented for ATL)
** 27.05.2004  DN        Adapted to new analysis model. Added getMaxStreamDens.
** 04.08.2004            removes sysnam and stream_code and update as necessary
** 15.02.2005 Ron/Jerome Modified getMaxStreamDens according to tracker 1227
** 11.03.2005 kaurrnar	 Removed deadcodes
**			                 Added 3 new function: getMaxStreamSpecGrav,
**			                 getMaxStreamGasSpecGrav, getMaxStreamOilSpecGrav
** 18.08.2005  Toha      TI 2282: Updated getMaxStreamDens, getMaxStreamSpecGrav to use stream reference
** 17.12.2008  oonnnng   ECPD-10559: Updated getMaxStreamConDens to hardcoded 'CON'.
** 31.12.2008  sharawan  ECPD-10416:Replaced all references to EcDp_Type.pb_comp_number%TYPE with NUMBER in functions
**                       getMaxStreamDens, getMaxStreamConDens, getMaxStreamGasDens, getMaxStreamOilDens, getMaxStreamSpecGrav, getMaxStreamGasSpecGrav, getMaxStreamOilSpecGrav.
** 10.02.2009 leongwen  ECPD-10990: standardise on stream_phase = COND and upgrade all usage of CON to COND
*****************************************************************/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getMaxStreamDens
-- Description  : Returns the maximum density for a given stream on a given
--                day using a component analysis.
--
-- Preconditions: The client must specify the analysis type to use.
-- Postcondition:
--
-- Using Tables:
--                OBJECT_FLUID_ANALYSIS
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour
--
---------------------------------------------------------------------------------------------------
FUNCTION getMaxStreamDens (
   p_object_id     VARCHAR2,
   p_phase         VARCHAR2,
   p_analysis_type VARCHAR2,
   p_daytime       DATE)

RETURN NUMBER
--<EC-DOC>
IS

CURSOR c_max_density(cp_object_id VARCHAR2, cp_phase VARCHAR2, cp_analysis_type VARCHAR2, cp_daytime DATE) IS
SELECT Max(ofa.density) max_dens
FROM object_fluid_analysis ofa
WHERE ofa.object_id = cp_object_id
AND ofa.phase = cp_phase
AND ofa.analysis_type = cp_analysis_type
AND ofa.analysis_status = 'APPROVED'
AND ofa.valid_from_date = (
   SELECT MAX(ofb.valid_from_date)
   FROM object_fluid_analysis ofb
   WHERE ofb.object_id = ofa.object_id
   AND ofb.phase = ofa.phase
   AND ofb.analysis_type = ofa.analysis_type
   AND ofb.density IS NOT NULL
   AND ofb.analysis_status = ofa.analysis_status
   AND ofb.valid_from_date <= cp_daytime);

ln_max_density NUMBER;
lv2_analysis_ref_id stream.object_id%TYPE;

BEGIN

   ln_max_density := NULL;
   lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(p_object_id, p_daytime);

   FOR cur_rec IN c_max_density(lv2_analysis_ref_id, p_phase, p_analysis_type, p_daytime) LOOP

      ln_max_density := cur_rec.max_dens; -- Query should return at most one record

   END LOOP;

   RETURN ln_max_density;

END getMaxStreamDens;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getMaxStreamConDens
-- Description  : Returns the maximum condensate density for a given stream
--                on a given day using a component analysis.
--
-- Preconditions: The client must specify the analysis type to use.
-- Postcondition:
--
-- Using Tables:
--
-- Using functions: getMaxStreamDens
--
-- Configuration
-- required:
--
-- Behaviour
--
---------------------------------------------------------------------------------------------------
FUNCTION getMaxStreamConDens (
     p_object_id     stream.object_id%TYPE,
     p_daytime       DATE,
     p_analysis_type VARCHAR2)

RETURN NUMBER
--<EC-DOC>
IS

ln_max_density NUMBER;

BEGIN

   ln_max_density := getMaxStreamDens(
                                   p_object_id,
                                   Ecdp_Phase.CONDENSATE,
                                   p_analysis_type,
                                   p_daytime);

   RETURN ln_max_density;

END getMaxStreamConDens;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getMaxStreamGasDens
-- Description  : Returns the maximum gas density for a given stream on a
--                given day using a component analysis.
--
-- Preconditions: The client must specify the analysis type to use.
-- Postcondition:
--
-- Using Tables:
--
-- Using functions: getMaxStreamDens
--
-- Configuration
-- required:
--
-- Behaviour
--
---------------------------------------------------------------------------------------------------
FUNCTION getMaxStreamGasDens (
     p_object_id     stream.object_id%TYPE,
     p_daytime       DATE,
     p_analysis_type VARCHAR2)

RETURN NUMBER
--<EC-DOC>
IS

ln_max_density NUMBER;

BEGIN

   ln_max_density := getMaxStreamDens(
                             p_object_id,
                             EcDp_Phase.GAS,
                             p_analysis_type,
                             p_daytime);

   RETURN ln_max_density;

END getMaxStreamGasDens;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getMaxStreamOilDens
-- Description  : Returns the maximum oil density for a given stream on a given
--                day using a component analysis.
--
-- Preconditions: The client must specify the analysis type to use.
-- Postcondition:
--
-- Using Tables:
--
-- Using functions: getMaxStreamDens
--
-- Configuration
-- required:
--
-- Behaviour
--
---------------------------------------------------------------------------------------------------
FUNCTION getMaxStreamOilDens (
     p_object_id     stream.object_id%TYPE,
     p_daytime       DATE,
     p_analysis_type VARCHAR2)

RETURN NUMBER
--<EC-DOC>
IS

ln_max_density NUMBER;

BEGIN

   ln_max_density := getMaxStreamDens(
                             p_object_id,
                             EcDp_Phase.OIL,
                             p_analysis_type,
                             p_daytime);

   RETURN ln_max_density;

END getMaxStreamOilDens;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getMaxStreamSpecGrav
-- Description  : Returns the maximum specific gravity for a given stream on a given
--                day using a component analysis.
--
-- Preconditions: The client must specify the analysis type to use.
-- Postcondition:
--
-- Using Tables:	OBJECT_FLUID_ANALYSIS
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour
--
---------------------------------------------------------------------------------------------------
FUNCTION getMaxStreamSpecGrav (
   p_object_id     VARCHAR2,
   p_phase         VARCHAR2,
   p_analysis_type VARCHAR2,
   p_daytime       DATE)

RETURN NUMBER
--<EC-DOC>
IS

CURSOR c_max_sp_grav(cp_object_id VARCHAR2, cp_phase VARCHAR2, cp_analysis_type VARCHAR2, cp_daytime DATE) IS
SELECT Max(ofa.sp_grav) max_sp_grav
FROM object_fluid_analysis ofa
WHERE ofa.object_id = cp_object_id
AND ofa.phase = cp_phase
AND ofa.analysis_type = cp_analysis_type
AND ofa.analysis_status = 'APPROVED'
AND ofa.valid_from_date = (
   SELECT MAX(ofb.valid_from_date)
   FROM object_fluid_analysis ofb
   WHERE ofb.object_id = ofa.object_id
   AND ofb.phase = ofa.phase
   AND ofb.analysis_type = ofa.analysis_type
   AND ofb.sp_grav IS NOT NULL
   AND ofb.analysis_status = ofa.analysis_status
   AND ofb.valid_from_date <= cp_daytime);

ln_max_sp_grav NUMBER;
lv2_analysis_ref_id stream.object_id%TYPE;

BEGIN

   ln_max_sp_grav := NULL;
   lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(p_object_id, p_daytime);

   FOR cur_rec IN c_max_sp_grav(lv2_analysis_ref_id, p_phase, p_analysis_type, p_daytime) LOOP

      ln_max_sp_grav := cur_rec.max_sp_grav; -- Query should return at most one record

   END LOOP;

   RETURN ln_max_sp_grav;

END getMaxStreamSpecGrav;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getMaxStreamGasSpecGrav
-- Description  : Returns the maximum gas specific gravity for a given stream on a
--                given day using a component analysis.
--
-- Preconditions: The client must specify the analysis type to use.
-- Postcondition:
--
-- Using Tables:
--
-- Using functions: getMaxStreamSpecGrav
--
-- Configuration
-- required:
--
-- Behaviour
--
---------------------------------------------------------------------------------------------------
FUNCTION getMaxStreamGasSpecGrav (
	p_object_id     stream.object_id%TYPE,
	p_daytime       DATE,
	p_analysis_type VARCHAR2)

RETURN NUMBER
--<EC-DOC>
IS

ln_max_sp_grav NUMBER;

BEGIN

   ln_max_sp_grav := getMaxStreamSpecGrav(
                             p_object_id,
                             EcDp_Phase.GAS,
                             p_analysis_type,
                             p_daytime);

   RETURN ln_max_sp_grav;

END getMaxStreamGasSpecGrav;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getMaxStreamOilSpecGrav
-- Description  : Returns the maximum oil specific gravity for a given stream on a given
--                day using a component analysis.
--
-- Preconditions: The client must specify the analysis type to use.
-- Postcondition:
--
-- Using Tables:
--
-- Using functions: getMaxStreamSpecGrav
--
-- Configuration
-- required:
--
-- Behaviour
--
---------------------------------------------------------------------------------------------------
FUNCTION getMaxStreamOilSpecGrav (
	p_object_id     stream.object_id%TYPE,
	p_daytime       DATE,
	p_analysis_type VARCHAR2)

RETURN NUMBER
--<EC-DOC>
IS

ln_max_sp_grav NUMBER;

BEGIN

   ln_max_sp_grav := getMaxStreamSpecGrav(
                             p_object_id,
                             EcDp_Phase.OIL,
                             p_analysis_type,
                             p_daytime);

   RETURN ln_max_sp_grav;

END getMaxStreamOilSpecGrav;

END EcDp_Stream_Fluid;