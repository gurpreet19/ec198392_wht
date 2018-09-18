CREATE OR REPLACE PACKAGE BODY ue_stream_ventflare IS
/****************************************************************
** Package        :  ue_stream_ventflare; body part
**
** $Revision: 1.9 $
**
** Purpose        :  Fucntion called for calcNormalRelease and calcUpsetRelease
**
** Documentation  :  www.energy-components.com
**
** Created        :  17.03.2010 Sarojini Rajaretnam
**
** Modification history:
**
** Date        Whom  	Change description:
** ----------  ----- 	-------------------------------------------
** 17.03.2010  rajarsar	ECPD-4828:Initial version
** 13.08.2010  rajarsar	ECPD-15495:Added calcRoutineRunHours and updated calling functions to EcBp_Stream_VentFlare.calcRoutineRunHours accordingly.
** 02.02.2011  farhaann ECPD-16411:Renamed calcNetVol to calcGrsVol
** 16.01.2014  choooshu ECPD-17958:Added calcwellduration
** 11.02.2014  jainopan ECPD-26700:Modified to have calcPotensialRelease RETURN 0 at the end;
** 09.04.2014  kumarsur ECPD-27001:calcGrsVol, rename to calcGrsVolMass.
** 22.03.2018  shindani ECPD-44451:Changed calcGrsVolMass from function to procedure.
** 23.03.2018  shindani ECPD-44451:Moved business logic for calcNormalRelease,calcPotensialRelease,calcUpsetRelease to
                                   EcBp_Stream_VentFlare package.
********************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : calcNormalRelease
-- Description    :
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcNormalRelease(p_object_id VARCHAR2, p_asset_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN

    RETURN NULL;

END calcNormalRelease;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : calcPotensialRelease
-- Description    :
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcPotensialRelease(p_object_id VARCHAR2, p_asset_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN

    RETURN NULL;

END calcPotensialRelease;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : calcUpsetRelease
-- Description    :
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcUpsetRelease(p_object_id VARCHAR2, p_asset_id VARCHAR2, p_daytime DATE)
--</EC-DOC>
RETURN NUMBER
IS

BEGIN

   RETURN NULL;

END calcUpsetRelease;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : calcNormalMTDAvg
-- Description    :
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcNormalMTDAvg(p_object_id VARCHAR2, p_daytime DATE)
--</EC-DOC>
RETURN NUMBER
IS

BEGIN

	   RETURN NULL;

END calcNormalMTDAvg;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : calcGrsVolMass
-- Description    :
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE calcGrsVolMass(p_object_id VARCHAR2, p_daytime DATE, p_user VARCHAR2, p_code_exist OUT VARCHAR2)
IS

BEGIN

  p_code_exist := 'N';

END calcGrsVolMass;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : calcNonRoutineEqpmFailure
-- Description    :
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcNonRoutineEqpmFailure(p_object_id VARCHAR2, p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS


BEGIN


	 RETURN NULL;


END calcNonRoutineEqpmFailure;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : addEqpmEvent
-- Description    :
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE addEqpmEvent(p_object_id VARCHAR2, p_daytime DATE, p_user VARCHAR2)

--</EC-DOC>
IS


BEGIN

   NULL;

END addEqpmEvent;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : calcRoutineRunHours
-- Description    :
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcRoutineRunHours(p_process_unit_id VARCHAR2, p_asset_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS


BEGIN


	 RETURN NULL;


END calcRoutineRunHours;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : calcWellDuration
-- Description    :
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcWellDuration(p_object_id VARCHAR2, p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE, p_well_id VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS


BEGIN


	 RETURN NULL;


END calcWellDuration;

END ue_stream_ventflare;