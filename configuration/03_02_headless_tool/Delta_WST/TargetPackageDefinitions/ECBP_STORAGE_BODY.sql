CREATE OR REPLACE PACKAGE BODY EcBp_Storage IS
/******************************************************************************
** Package        :  EcBp_Storage, body part
**
** $Revision: 1.7 $
**
** Purpose        :  Business logic for storages
**
** Documentation  :  www.energy-components.com
**
** Created  : 01.11.2004 Kari Sandvik
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- -----------------------------------------------------------------------------------------------
** #.#   DD.MM.YYYY  <initials>
** 1.2	 28.02.2005  KAURRNAR	Removed references to ec_xxx_attribute packages
** 1.3   07.04.2005  SHK   Added SafeLimit functions
**       06.07.2007  kaurrjes   ECPD-6102: Start Date/End date on tank_usage are ignored in all methods
********************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getMaxVolLevel
-- Description    : Returns the Max Volumn Level for all tanks connected to the storage
--
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
FUNCTION getMaxVolLevel(p_storage_id VARCHAR2,
						p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

CURSOR 	c_level (cp_storage_id VARCHAR2, cp_daytime DATE)
IS
SELECT SUM (ec_tank_version.MAX_VOL(t.object_id, cp_daytime, '<=')) MAX_LEVEL
FROM tank t, tank_usage tu
WHERE tu.tank_id = t.object_id
AND tu.object_id = cp_storage_id
AND tu.daytime <= cp_daytime
AND nvl(tu.end_date, cp_daytime+1) > cp_daytime
AND nvl(tu.out_of_service, 'N')='N';

lnVol NUMBER;

BEGIN

	FOR curLevel IN c_level (p_storage_id , p_daytime) LOOP
		lnVol := curLevel.MAX_LEVEL;
	END LOOP;

	RETURN lnVol;

END getMaxVolLevel;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getMinVolLevel
-- Description    : Returns the Min Volumn Level for all tanks connected to the storage
--
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
FUNCTION getMinVolLevel(p_storage_id VARCHAR2,
						p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

CURSOR 	c_level (cp_storage_id VARCHAR2, cp_daytime DATE)
IS
SELECT	SUM (ec_tank_version.MIN_VOL(t.object_id, cp_daytime, '<=')) MIN_LEVEL
FROM	tank t, tank_usage tu
WHERE	tu.tank_id = t.object_id
AND tu.object_id = cp_storage_id
AND tu.daytime <= cp_daytime
AND nvl(tu.end_date, cp_daytime+1) > cp_daytime
AND nvl(tu.out_of_service, 'N')='N';

lnVol NUMBER;

BEGIN

	FOR curLevel IN c_level (p_storage_id, p_daytime) LOOP
		lnVol := curLevel.MIN_LEVEL;
	END LOOP;

	RETURN lnVol;

END getMinVolLevel;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getMinSafeLimitVolLevel
-- Description    : Returns the Minimum Operational Safe Limit Level for all tanks connected to the storage
--
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
FUNCTION getMinSafeLimitVolLevel(p_storage_id VARCHAR2,
						p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

CURSOR 	c_level (cp_storage_id VARCHAR2, cp_daytime DATE)
IS
SELECT	SUM (ec_tank_version.MIN_VOL_SAFE_LIMIT(t.object_id, cp_daytime, '<=')) MIN_VOL_SAFE_LIMIT
FROM	tank t, tank_usage tu
WHERE	tu.tank_id = t.object_id
AND tu.object_id = cp_storage_id
AND tu.daytime <= cp_daytime
AND nvl(tu.end_date, cp_daytime+1) > cp_daytime
AND nvl(tu.out_of_service, 'N')='N';

lnVol NUMBER;

BEGIN

	FOR curLevel IN c_level (p_storage_id, p_daytime) LOOP
		lnVol := curLevel.MIN_VOL_SAFE_LIMIT;
	END LOOP;

	RETURN lnVol;

END getMinSafeLimitVolLevel;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getMaxSafeLimitVolLevel
-- Description    : Returns the Maximum Operational Safe Limit Level for all tanks connected to the storage
--
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
FUNCTION getMaxSafeLimitVolLevel(p_storage_id VARCHAR2,
						p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

CURSOR 	c_level (cp_storage_id VARCHAR2, cp_daytime DATE)
IS
SELECT	SUM (ec_tank_version.MAX_VOL_SAFE_LIMIT(t.object_id, cp_daytime, '<=')) MAX_VOL_SAFE_LIMIT
FROM	tank t, tank_usage tu
WHERE	tu.tank_id = t.object_id
AND tu.object_id = cp_storage_id
AND tu.daytime <= cp_daytime
AND nvl(tu.end_date, cp_daytime+1) > cp_daytime
AND nvl(tu.out_of_service, 'N')='N';

lnVol NUMBER;

BEGIN

	FOR curLevel IN c_level (p_storage_id, p_daytime) LOOP
		lnVol := curLevel.MAX_VOL_SAFE_LIMIT;
	END LOOP;

	RETURN lnVol;

END getMaxSafeLimitVolLevel;


END EcBp_Storage;