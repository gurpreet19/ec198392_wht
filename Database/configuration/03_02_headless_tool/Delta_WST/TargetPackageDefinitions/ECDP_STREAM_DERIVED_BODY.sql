CREATE OR REPLACE PACKAGE BODY EcDp_Stream_Derived IS
/****************************************************************
** Package        :  EcDp_Stream_Derived
**
** $Revision: 1.6 $
**
** Purpose        :  This package is responsible for stream fluid information for derived streams
**
** Documentation  :  www.energy-components.com
**
** Created  : 22.11.1999  Carl-Fredrik Sørensen
**
** Modification history:
**
** Version  Date        Whom      Change description:
** -------  ----------  --------  ----------------------------------------------------------------------------------------------
** 1.0      14.12.1999  CFS       First version
**          29.03.2000  RRA       Added function getGrsStdVol
** 3.3      19.07.2000  HNE       Added functions getGrsStdMass and getNetStdMass. Add Nvl(p_today,p_fromday) in parameter list.
** 3.3      03.04.2001  KEJ       Documented functions and procedures.
** 3.4      04.08.2004  kaurrnar  removed sysnam and stream_code and update as necessary
**          03.12.2004  DN        TI 1823: Removed dummy package constructor.
** 3.6      26.09.2006  kaurrjes  TI#4547: Added new function getEnergy and removed p_sysnam and p_stream_code
**          03.03.2008  rajarsar  ECPD-7127: added new function getPowerConsumption
**          07.05.2008  leeeewei  ECPD-7225: Modified nvl(p_today,p_fromday)to p_today in call to ec_derived_stream
*********************************************************************************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getNetStdVol                                                                   --
-- Description  : Calculate net standard vol for a stream in a given period.                     --
--                                                                                               --
-- Preconditions:                                                                                --
-- Postcondition:                                                                                --
--                                                                                               --
-- Using Tables:                                                                                 --
--                                                                                               --
-- Using functions: EC_DERIVED_STREAM.MATH_NET_VOL                                               --
--                                                                                               --
-- Configuration                                                                                 --
-- required:        Derived streams are generated based upon STRM_DERIVED table.                 --
--                                                                                               --
-- Behaviour                                                                                     --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getNetStdVol (
   p_object_id stream.object_id%TYPE,
   p_fromday       DATE,
   p_today         DATE)


RETURN NUMBER
--<EC-DOC>
IS

ln_return_val NUMBER; -- Return a number;

BEGIN

   ln_return_val := ec_derived_stream.math_net_vol(
                      p_object_id,
                      p_fromday,
                      p_today);
   RETURN ln_return_val;

END getNetStdVol;

--
FUNCTION getGrsStdVol (
   p_object_id stream.object_id%TYPE,
   p_fromday       DATE,
   p_today         DATE)


RETURN NUMBER IS

ln_return_val NUMBER; -- Return a number;

BEGIN

   ln_return_val := ec_derived_stream.math_grs_vol(
                      p_object_id,
                      p_fromday,
                      p_today);
   RETURN ln_return_val;

END getGrsStdVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getNetStdMass                                                                   --
-- Description  : Calculate net standard mass for a stream in a given period.                    --
--                                                                                               --
-- Preconditions:                                                                                --
-- Postcondition:                                                                                --
--                                                                                               --
-- Using Tables:                                                                                 --
--                                                                                               --
-- Using functions: EC_DERIVED_STREAM.MATH_NET_MASS                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required:        Derived streams are generated based upon STRM_DERIVED table.                 --
--                                                                                               --
-- Behaviour                                                                                     --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getNetStdMass (
   p_object_id stream.object_id%TYPE,
   p_fromday       DATE,
   p_today         DATE)


RETURN NUMBER
--<EC-DOC>
IS

ln_return_val NUMBER; -- Return a number;

BEGIN

   ln_return_val := ec_derived_stream.math_net_mass(
                      p_object_id,
                      p_fromday,
                      p_today);
   RETURN ln_return_val;

END getNetStdMass;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getGrsStdMass                                                                  --
-- Description  : Calculate gross standard mass for a stream in a given period.                  --
--                                                                                               --
-- Preconditions:                                                                                --
-- Postcondition:                                                                                --
--                                                                                               --
-- Using Tables:                                                                                 --
--                                                                                               --
-- Using functions: EC_DERIVED_STREAM.MATH_GRS_MASS                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required:        Derived streams are generated based upon STRM_DERIVED table.                 --
--                                                                                               --
-- Behaviour                                                                                     --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getGrsStdMass (
   p_object_id stream.object_id%TYPE,
   p_fromday       DATE,
   p_today         DATE)


RETURN NUMBER
--<EC-DOC>
IS

ln_return_val NUMBER; -- Return a number;

BEGIN

   ln_return_val := ec_derived_stream.math_grs_mass(
                      p_object_id,
                      p_fromday,
                      p_today);
   RETURN ln_return_val;

END getGrsStdMass;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getEnergy                                                                      --
-- Description  : Calculate energy for a stream in a given period.                               --
--                                                                                               --
-- Preconditions:                                                                                --
-- Postcondition:                                                                                --
--                                                                                               --
-- Using Tables:                                                                                 --
--                                                                                               --
-- Using functions: EC_DERIVED_STREAM.MATH_ENERGY                                                --
--                                                                                               --
-- Configuration                                                                                 --
-- required:        Derived streams are generated based upon STRM_DERIVED table.                 --
--                                                                                               --
-- Behaviour                                                                                     --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getEnergy (
   p_object_id stream.object_id%TYPE,
   p_fromday       DATE,
   p_today         DATE)


RETURN NUMBER
--<EC-DOC>
IS

ln_return_val NUMBER; -- Return a number;

BEGIN

   ln_return_val := ec_derived_stream.math_energy(
                      p_object_id,
                      p_fromday,
                      p_today);
   RETURN ln_return_val;

END getEnergy;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getPowerConsumption                                                            --
-- Description  : Calculate power consumption for an electrical stream in a given period.        --
--                                                                                               --
-- Preconditions:                                                                                --
-- Postcondition:                                                                                --
--                                                                                               --
-- Using Tables:                                                                                 --
--                                                                                               --
-- Using functions: EC_DERIVED_STREAM.MATH_POWER_CONSUMPTION                                     --
--                                                                                               --
-- Configuration                                                                                 --
-- required:        Derived streams are generated based upon STRM_DERIVED table.                 --
--                                                                                               --
-- Behaviour                                                                                     --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getPowerConsumption (
   p_object_id stream.object_id%TYPE,
   p_fromday       DATE,
   p_today         DATE)


RETURN NUMBER
--<EC-DOC>
IS

ln_return_val NUMBER; -- Return a number;

BEGIN

   ln_return_val := ec_derived_stream.math_power_consumption(
                      p_object_id,
                      p_fromday,
                      p_today);
   RETURN ln_return_val;

END getPowerConsumption;



END;