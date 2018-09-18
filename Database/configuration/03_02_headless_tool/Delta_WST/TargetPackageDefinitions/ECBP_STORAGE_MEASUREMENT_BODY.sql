CREATE OR REPLACE PACKAGE BODY EcBp_Storage_measurement IS


/****************************************************************
** Package        :  EcBp_Storage_measurement, body part
**
** $Revision: 1.23.12.4 $
**
** Purpose        :  Finds storage differences for active storages
**
** Documentation  :  www.energy-components.com
**
** Created  : 12.10.2001  Harald Vetrhus
**
** Modification history:
**
** Version  Date        Whom    Change description:
** -------  ----------  -----   --------------------------------------
**  1.2     05.05.2004  FBa     Adjusted to new interface in EcBp_Tank
**  1.3     01.06.2004  EOL     Added mass methods
**  1.5     01.06.2004  EOL     Added 'DAY_CLOSING' to calls to ecbp_tank
**  1.6     06.07.2004  DN      Bug fix ref issue 1321: Use of tank_id instead of object id in tank_usage cursors
**  1.7     03.08.2004  Toha    Replaced sysnam, terminal_code, storage_code to object_id in signatures and made
**                              changes as necessary
**  1.8     13.11.2004  ROV     Bug fix related to tracker issue #1776. Added condition to all of the monthly functions
**                              listed at the end causing the function only to calculate a value in case the input argument
**                              daytime is the last day of the month. Else return zero.
**                              Functions:findStorageGrsMthDiff,findStorageGrsMassMthDiff,
**                              findStorageNetMassMthDiff,findStorageNetMthDiff and findStorageWatMthDiff
**                              Also removed all uncommented code related to tracker #1255
**  1.9     28.01.2005 idrussab	  Added 4 new functions ie getStorageLiftedNetVolSm3, getStorageLiftedNetVolBbls, getStorageLiftedGrsVolSm3, getStorageLiftedGrsVolBbls
**  2.0     28.01.2005 zalannur   tracker #1905: Added 4 new functions to call the above functions, ie findStorageLiftedGrsVolSm3
**  2.1	    28.02.2005 kaurrnar	Removed references to ec_xxx_attribute packages.
**  2.2     14.07.2006 Lau      TI# 3632: Modified function findStorageGrsMthDiff,findStorageGrsMassMthDiff,findStorageNetMthDiff,findStorageNetMassMthDiff,
                                findStorageWatMthDiff
**  2.3     18.09.2006 vikaaroa Updated all methods using EcBp_Tank.find## methods to use EcBp_Tank.findOpening/Closing## methods instead as these take Tanke Meter Freq into account
**  2.4	    09.01.2007 kaurrjes	ECPD-4806: Added 6 new functions ie findStorageLiftedGrsVolSm3, findStorageLiftedGrsVolBbls, findExpNotLiftedDayGrsBbls, findExpNotLiftedMthGrsBbls,
				findExpNotLiftedDayGrsSm3, findExpNotLiftedMthGrsSm3
**  2.5	    17.12.2008 amirrasn	ECPD-10455 :Removed cursor cur_tanks from functions : getStorageDayGrsClosingVol,getStorageDayGrsOpeningVol,
							    getStorageDayGrsClosingMass,getStorageDayGrsOpeningMass,getStorageDayClosingNetVol,getStorageDayOpeningNetVol,
							    getStorageDayClosingNetMass,getStorageDayOpeningNetMass,getStorageDayClosingWatVol,getStorageDayOpeningWatVol,
							    findStorageTotalVolume,findStorageTotalAvailable.
							    Created one common cursor at the top of the package body to replace the existing cursor as above.
								Changed the default value of function parameter "p_exclude_out_of_service" from 'Y' to 'N'.
**          30.12.2008 sharawan ECPD-10416:Replaced all references to EcDp_Type.pb_comp_number%TYPE with NUMBER in functions
**                              findStorageGrsDayDiff, findStorageGrsMassDayDiff, findStorageGrsMthDiff, findStorageGrsMassMthDiff, findStorageNetMassMthDiff,
**                              findStorageNetDayDiff, findStorageNetMassDayDiff, findStorageNetMthDiff, findStorageEnergyDayDiff, findStorageEnergyMthDiff,
**                              getStorageDayGrsClosingVol, getStorageDayGrsOpeningVol, getStorageDayGrsClosingMass, getStorageDayGrsOpeningMass,
**                              getStorageDayClosingNetVol, getStorageDayOpeningNetVol, getStorageDayClosingEnergy, getStorageDayOpeningEnergy,
**                              getStorageDayClosingNetMass, getStorageDayOpeningNetMass, getStorageDayClosingWatVol, getStorageDayOpeningWatVol,
**                              findStorageWatDayDiff, findStorageWatMthDiff, findStorageTotalVolume, findStorageTotalAvailable.
**         08.09.2010 saadsiti  ECPD-15639: Added new function getStorageDayGrsOilCloseVol
**         27.04.2012 musthram	ECPD-20758 : Storage level energy functions should handle "Out of service" parameter
								Modified getStorageDayClosingEnergy and getStorageDayOpeningEnergy
								Modified global cur_tanks cursor
**			01.11.2012 limmmchu ECPD-22065: Added findStorageDiluentDayDiff, getStorageDayClosingDiluent, getStorageDayOpeningDiluent
**			22.01.2013 kumarsur ECPD-23165: Remove NVL(xxxxx,0) to return NULL values for the values which are NULL.
**			27.11.2013 abdulmaw ECPD-26223: Remove else statement to return NULL instead of 0 for monthly function
*****************************************************************/

CURSOR cur_tanks(cp_object_id VARCHAR2, cp_daytime DATE, cp_exclude_out_of_service VARCHAR2) IS
SELECT DISTINCT tank_id
FROM tank_usage
WHERE object_id = cp_object_id
AND daytime <= cp_daytime
AND Nvl(end_date, cp_daytime+1) > cp_daytime
AND decode(out_of_service,'Y','Y','XX') <> NVL(out_of_service,cp_exclude_out_of_service);

------------------------------------------------------------------
-- Function:    findStorageGrsDayDiff
-- Description: Returns - if active - the storage diff by all attached tank diffs
------------------------------------------------------------------
FUNCTION findStorageGrsDayDiff (
	p_object_id      	storage.object_id%TYPE,
	p_daytime          	DATE)

RETURN NUMBER IS

ln_return_val NUMBER;

BEGIN
		ln_return_val := getStorageDayGrsClosingVol(p_object_id, p_daytime)
			- getStorageDayGrsOpeningVol(p_object_id, p_daytime);
	RETURN ln_return_val;


END findStorageGrsDayDiff;

------------------------------------------------------------------
-- Function:    findStorageGrsMassDayDiff
-- Description: Returns - if active - the mass storage diff by all attached tank diffs
------------------------------------------------------------------
FUNCTION findStorageGrsMassDayDiff (
	p_object_id        storage.object_id%TYPE,
	p_daytime          DATE)

RETURN NUMBER IS

ln_return_val NUMBER;

BEGIN
	ln_return_val := getStorageDayGrsClosingMass(p_object_id, p_daytime)
			- getStorageDayGrsOpeningMass(p_object_id, p_daytime);
	RETURN ln_return_val;


END findStorageGrsMassDayDiff;

---------------------------------------------------------------------------
-- Function:    findStorageGrsMthDiff
-- Description: Returns - if active - the storage total diff as sum of
--				all attached tank diffs using mht_end - mth_start volumes.
---------------------------------------------------------------------------
FUNCTION findStorageGrsMthDiff (
	p_object_id 	 storage.object_id%TYPE,
	p_daytime      	 DATE)

RETURN NUMBER IS
ln_return_val NUMBER;

BEGIN

	IF (p_daytime = LAST_DAY(p_daytime)) THEN

		ln_return_val := getStorageDayGrsClosingVol(p_object_id, LAST_DAY(p_daytime))
						- getStorageDayGrsOpeningVol(p_object_id, TRUNC(p_daytime, 'mm'));

	END IF;

	RETURN ln_return_val;

END findStorageGrsMthDiff;


----------------------------------------------------------------------------------------
-- Function:    findStorageGrsMassMthDiff
-- Description: Returns - if active - the storage total diff by all attached tank diffs
--				using mht_end - mth_start volumes
----------------------------------------------------------------------------------------
FUNCTION findStorageGrsMassMthDiff (
	p_object_id		storage.object_id%TYPE,
	p_daytime   	DATE)

RETURN NUMBER IS
ln_return_val NUMBER;

BEGIN

	IF (p_daytime = LAST_DAY(p_daytime)) THEN

		ln_return_val := getStorageDayGrsClosingMass(p_object_id, LAST_DAY(p_daytime))
						- getStorageDayGrsOpeningMass(p_object_id, TRUNC(p_daytime, 'mm'));

	END IF;

	RETURN ln_return_val;

END findStorageGrsMassMthDiff;


---------------------------------------------------------------------------------------
-- Function:    findStorageNetMassMthDiff
-- Description: Returns - if active - the storage total diff by all attached tank diffs
--				using mht_end - mth_start volumes
---------------------------------------------------------------------------------------
FUNCTION findStorageNetMassMthDiff (
	p_object_id    		storage.object_id%TYPE,
	p_daytime          	DATE)

RETURN NUMBER IS
ln_return_val NUMBER;

BEGIN

	IF (p_daytime = LAST_DAY(p_daytime)) THEN

		ln_return_val := getStorageDayClosingNetMass(p_object_id, LAST_DAY(p_daytime))
						- getStorageDayOpeningNetMass(p_object_id, TRUNC(p_daytime, 'mm'));

	END IF;

	RETURN ln_return_val;

END findStorageNetMassMthDiff;


------------------------------------------------------------------
-- Function:    findStorageNetDayDiff
-- Description: Returns - if active - the storage diff by all attached tank diffs
------------------------------------------------------------------
FUNCTION findStorageNetDayDiff (
	p_object_id        storage.object_id%TYPE,
	p_daytime          DATE)

RETURN NUMBER IS

ln_return_val NUMBER;

BEGIN
		ln_return_val := getStorageDayClosingNetVol(p_object_id, p_daytime)
			- getStorageDayOpeningNetVol(p_object_id, p_daytime);
	RETURN ln_return_val;


END findStorageNetDayDiff;

--
------------------------------------------------------------------
-- Function:    findStorageDiluentDayDiff
-- Description: Returns - if active - the storage diff by all attached tank diffs
------------------------------------------------------------------

FUNCTION findStorageDiluentDayDiff (
	p_object_id        storage.object_id%TYPE,
	p_daytime          DATE)

RETURN NUMBER IS

ln_return_val NUMBER;

BEGIN
		ln_return_val := getStorageDayClosingDiluent(p_object_id, p_daytime)
			- getStorageDayOpeningDiluent(p_object_id, p_daytime);
	RETURN ln_return_val;


END findStorageDiluentDayDiff;

------------------------------------------------------------------
-- Function:    findStorageNetMassDayDiff
-- Description: Returns - if active - the storage diff by all attached tank diffs
------------------------------------------------------------------
FUNCTION findStorageNetMassDayDiff (
	p_object_id        storage.object_id%TYPE,
	p_daytime          DATE)

RETURN NUMBER IS

ln_return_val NUMBER;

BEGIN
		ln_return_val := getStorageDayClosingNetMass(p_object_id, p_daytime)
			- getStorageDayOpeningNetMass(p_object_id, p_daytime);
	RETURN ln_return_val;


END findStorageNetMassDayDiff;

---------------------------------------------------------------------------------------
-- Function:    findStorageNetMthDiff
-- Description: Returns - if active - the storage total diff by all attached tank diffs
--						using mht_end - mth_start volumes
---------------------------------------------------------------------------------------
FUNCTION findStorageNetMthDiff (
	p_object_id      	storage.object_id%TYPE,
	p_daytime          	DATE)

RETURN NUMBER IS
ln_return_val NUMBER;

BEGIN

	IF (p_daytime = LAST_DAY(p_daytime))  THEN

		ln_return_val := getStorageDayClosingNetVol(p_object_id, LAST_DAY(p_daytime))
						- getStorageDayOpeningNetVol(p_object_id, TRUNC(p_daytime, 'mm'));

	END IF;

	RETURN ln_return_val;

END findStorageNetMthDiff;


------------------------------------------------------------------
-- Function:    findStorageEnergyDayDiff
-- Description: Returns - if active - the storage diff by all attached tank diffs
------------------------------------------------------------------
FUNCTION findStorageEnergyDayDiff (
	p_object_id        storage.object_id%TYPE,
	p_daytime          DATE)

RETURN NUMBER IS

ln_return_val NUMBER;

BEGIN
		ln_return_val := getStorageDayClosingEnergy(p_object_id, p_daytime)
			- getStorageDayOpeningEnergy(p_object_id, p_daytime);
	RETURN ln_return_val;


END findStorageEnergyDayDiff;

---------------------------------------------------------------------------------------
-- Function:    findStorageEnergyMthDiff
-- Description: Returns - if active - the storage total diff by all attached tank diffs
--						using mht_end - mth_start volumes
---------------------------------------------------------------------------------------
FUNCTION findStorageEnergyMthDiff (
	p_object_id      	storage.object_id%TYPE,
	p_daytime          	DATE)

RETURN NUMBER IS
ln_return_val NUMBER;

BEGIN

	IF (p_daytime = LAST_DAY(p_daytime))  THEN

		ln_return_val := getStorageDayClosingEnergy(p_object_id, LAST_DAY(p_daytime))
						- getStorageDayOpeningEnergy(p_object_id, TRUNC(p_daytime, 'mm'));

	END IF;

	RETURN ln_return_val;

END findStorageEnergyMthDiff;

------------------------------------------------------------------
-- Function:    getStorageDayGrsDipLevel
-- Description: Return the CLOSING grs dip level for a storage for a day
------------------------------------------------------------------
FUNCTION getStorageDayGrsClosingVol (
	p_object_id    		storage.object_id%TYPE,
	p_daytime          	DATE,
  p_exclude_out_of_service VARCHAR2 DEFAULT 'N')

RETURN NUMBER IS
ln_return_val NUMBER;

BEGIN
	ln_return_val := 0;
	FOR mycur IN cur_tanks(p_object_id, p_daytime,p_exclude_out_of_service) LOOP
		ln_return_val := ln_return_val + ecbp_tank.findClosingGrsVol(mycur.tank_id, 'DAY_CLOSING', p_daytime);
	END LOOP;
	RETURN ln_return_val;

END getStorageDayGrsClosingVol;


------------------------------------------------------------------
-- Function:    getStorageDayGrsStdOilCloseVol
-- Description: Return the CLOSING grs dip level for a storage for a day
------------------------------------------------------------------
FUNCTION getStorageDayGrsStdOilCloseVol (
	p_object_id    		storage.object_id%TYPE,
	p_daytime          	DATE,
  p_exclude_out_of_service VARCHAR2 DEFAULT 'N')

RETURN NUMBER IS
ln_return_val NUMBER;

BEGIN
	ln_return_val := 0;
	FOR mycur IN cur_tanks(p_object_id, p_daytime,p_exclude_out_of_service) LOOP
		ln_return_val := ln_return_val + ecbp_tank.findClosingGrsStdOilVol(mycur.tank_id, 'DAY_CLOSING', p_daytime);
	END LOOP;
	RETURN ln_return_val;

END getStorageDayGrsStdOilCloseVol;

------------------------------------------------------------------
-- Function:    getStorageDayOpenGrsDipLevel
-- Description: Return the OPENING grs dip level for a storage for a day
------------------------------------------------------------------
FUNCTION getStorageDayGrsOpeningVol (
	p_object_id        storage.object_id%TYPE,
	p_daytime          DATE,
  p_exclude_out_of_service VARCHAR2 DEFAULT 'N')

RETURN NUMBER IS
ln_return_val NUMBER;

BEGIN
	ln_return_val := 0;
	FOR mycur IN cur_tanks(p_object_id, p_daytime,p_exclude_out_of_service) LOOP
		ln_return_val := ln_return_val + ecbp_tank.findOpeningGrsVol(mycur.tank_id, 'DAY_CLOSING', p_daytime);
	END LOOP;
	RETURN ln_return_val;

END getStorageDayGrsOpeningVol;


------------------------------------------------------------------
-- Function:    getStorageDayGrsClosingMass
-- Description: Return the CLOSING grs dip level for a storage for a day
------------------------------------------------------------------
FUNCTION getStorageDayGrsClosingMass (
	p_object_id        storage.object_id%TYPE,
	p_daytime          DATE,
  p_exclude_out_of_service VARCHAR2 DEFAULT 'N')

RETURN NUMBER IS
ln_return_val NUMBER;

BEGIN
	ln_return_val := 0;
	FOR mycur IN cur_tanks(p_object_id, p_daytime,p_exclude_out_of_service) LOOP
		ln_return_val := ln_return_val + ecbp_tank.findClosingGrsMass(mycur.tank_id, 'DAY_CLOSING', p_daytime);
	END LOOP;
	RETURN ln_return_val;

END getStorageDayGrsClosingMass;

------------------------------------------------------------------
-- Function:    getStorageDayGrsOpeningMass
-- Description: Return the OPENING grs dip level for a storage for a day
------------------------------------------------------------------
FUNCTION getStorageDayGrsOpeningMass (
	p_object_id        storage.object_id%TYPE,
	p_daytime          DATE,
  p_exclude_out_of_service VARCHAR2 DEFAULT 'N')

RETURN NUMBER IS
ln_return_val NUMBER;

BEGIN
	ln_return_val := 0;
	FOR mycur IN cur_tanks(p_object_id, p_daytime,p_exclude_out_of_service) LOOP
		ln_return_val := ln_return_val + ecbp_tank.findOpeningGrsMass(mycur.tank_id, 'DAY_CLOSING', p_daytime);
	END LOOP;
	RETURN ln_return_val;

END getStorageDayGrsOpeningMass;

------------------------------------------------------------------
-- Function:    getStorageDayClosingDiluent
-- Description: Return the CLOSING net vol for a storage for a day
------------------------------------------------------------------
FUNCTION getStorageDayClosingDiluent (
	p_object_id        storage.object_id%TYPE,
	p_daytime          DATE,
  p_exclude_out_of_service VARCHAR2 DEFAULT 'N')

RETURN NUMBER IS
ln_return_val NUMBER;

BEGIN
	ln_return_val := 0;
	FOR mycur IN cur_tanks(p_object_id, p_daytime,p_exclude_out_of_service) LOOP
		ln_return_val := ln_return_val + ecbp_tank.findClosingDiluentVol(mycur.tank_id, 'DAY_CLOSING', p_daytime);
	END LOOP;
	RETURN ln_return_val;
END getStorageDayClosingDiluent;


------------------------------------------------------------------
-- Function:    getStorageDayOpeningDiluent
-- Description: Return the OPENING net vol for a storage for a day
------------------------------------------------------------------
FUNCTION getStorageDayOpeningDiluent (
	p_object_id     	storage.object_id%TYPE,
	p_daytime          	DATE,
  p_exclude_out_of_service VARCHAR2 DEFAULT 'N')

RETURN NUMBER IS
ln_return_val NUMBER;

BEGIN
	ln_return_val := 0;
	FOR mycur IN cur_tanks(p_object_id, p_daytime,p_exclude_out_of_service) LOOP
		ln_return_val := ln_return_val + ecbp_tank.findOpeningDiluentVol(mycur.tank_id, 'DAY_CLOSING', p_daytime);
	END LOOP;
	RETURN ln_return_val;
END getStorageDayOpeningDiluent;

------------------------------------------------------------------
-- Function:    getStorageClosingNetVol
-- Description: Return the CLOSING net vol for a storage for a day
------------------------------------------------------------------
FUNCTION getStorageDayClosingNetVol (
	p_object_id        storage.object_id%TYPE,
	p_daytime          DATE,
  p_exclude_out_of_service VARCHAR2 DEFAULT 'N')

RETURN NUMBER IS
ln_return_val NUMBER;

BEGIN
	ln_return_val := 0;
	FOR mycur IN cur_tanks(p_object_id, p_daytime,p_exclude_out_of_service) LOOP
		ln_return_val := ln_return_val + ecbp_tank.findClosingNetVol(mycur.tank_id, 'DAY_CLOSING', p_daytime);
	END LOOP;
	RETURN ln_return_val;
END getStorageDayClosingNetVol;

------------------------------------------------------------------
-- Function:    getStorageOpeningNetVol
-- Description: Return the OPENING net vol for a storage for a day
------------------------------------------------------------------
FUNCTION getStorageDayOpeningNetVol (
	p_object_id     	storage.object_id%TYPE,
	p_daytime          	DATE,
  p_exclude_out_of_service VARCHAR2 DEFAULT 'N')

RETURN NUMBER IS
ln_return_val NUMBER;

BEGIN
	ln_return_val := 0;
	FOR mycur IN cur_tanks(p_object_id, p_daytime,p_exclude_out_of_service) LOOP
		ln_return_val := ln_return_val + ecbp_tank.findOpeningNetVol(mycur.tank_id, 'DAY_CLOSING', p_daytime);
	END LOOP;
	RETURN ln_return_val;
END getStorageDayOpeningNetVol;


------------------------------------------------------------------
-- Function:    getStorageClosingEnergy
-- Description: Return the CLOSING energy for a storage for a day
------------------------------------------------------------------
FUNCTION getStorageDayClosingEnergy (
	p_object_id        storage.object_id%TYPE,
	p_daytime          DATE,
    p_exclude_out_of_service VARCHAR2 DEFAULT 'N')

RETURN NUMBER IS
ln_return_val NUMBER;

BEGIN
	ln_return_val := 0;
	FOR mycur IN cur_tanks(p_object_id, p_daytime, p_exclude_out_of_service) LOOP
		ln_return_val := ln_return_val + ecbp_tank.findClosingEnergy(mycur.tank_id, 'DAY_CLOSING', p_daytime);
	END LOOP;
	RETURN ln_return_val;
END getStorageDayClosingEnergy;

------------------------------------------------------------------
-- Function:    getStorageOpeningEnergy
-- Description: Return the OPENING energy for a storage for a day
------------------------------------------------------------------
FUNCTION getStorageDayOpeningEnergy (
	p_object_id     	storage.object_id%TYPE,
	p_daytime          	DATE,
    p_exclude_out_of_service VARCHAR2 DEFAULT 'N')

RETURN NUMBER IS
ln_return_val NUMBER;

BEGIN
	ln_return_val := 0;
	FOR mycur IN cur_tanks(p_object_id, p_daytime, p_exclude_out_of_service) LOOP
		ln_return_val := ln_return_val + ecbp_tank.findOpeningEnergy(mycur.tank_id, 'DAY_CLOSING', p_daytime);
	END LOOP;
	RETURN ln_return_val;
END getStorageDayOpeningEnergy;

------------------------------------------------------------------
-- Function:    getStorageClosingNetMass
-- Description: Return the CLOSING net mass for a storage for a day
------------------------------------------------------------------
FUNCTION getStorageDayClosingNetMass (
	p_object_id      	storage.object_id%TYPE,
	p_daytime          	DATE,
  p_exclude_out_of_service VARCHAR2 DEFAULT 'N')

RETURN NUMBER IS
ln_return_val NUMBER;

BEGIN
	ln_return_val := 0;
	FOR mycur IN cur_tanks(p_object_id, p_daytime,p_exclude_out_of_service) LOOP
		ln_return_val := ln_return_val + ecbp_tank.findClosingNetMass(mycur.tank_id, 'DAY_CLOSING', p_daytime);
	END LOOP;
	RETURN ln_return_val;
END getStorageDayClosingNetMass;

------------------------------------------------------------------
-- Function:    getStorageOpeningNetMass
-- Description: Return the OPENING net mass for a storage for a day
------------------------------------------------------------------
FUNCTION getStorageDayOpeningNetMass (
	p_object_id     	storage.object_id%TYPE,
	p_daytime          	DATE,
  p_exclude_out_of_service VARCHAR2 DEFAULT 'N')

RETURN NUMBER IS
ln_return_val NUMBER;

BEGIN
	ln_return_val := 0;
	FOR mycur IN cur_tanks(p_object_id, p_daytime,p_exclude_out_of_service) LOOP
		ln_return_val := ln_return_val + ecbp_tank.findOpeningNetMass(mycur.tank_id, 'DAY_CLOSING', p_daytime);
	END LOOP;
	RETURN ln_return_val;
END getStorageDayOpeningNetMass;


------------------------------------------------------------------
-- Function:    getStorageClosingWatVol
-- Description: Return the CLOSING Wat vol for a storage for a day
------------------------------------------------------------------
FUNCTION getStorageDayClosingWatVol (
	p_object_id     	storage.object_id%TYPE,
	p_daytime          	DATE,
  p_exclude_out_of_service VARCHAR2 DEFAULT 'N')

RETURN NUMBER IS
ln_return_val NUMBER;

BEGIN
	ln_return_val := 0;
	FOR mycur IN cur_tanks(p_object_id, p_daytime,p_exclude_out_of_service) LOOP
		ln_return_val := ln_return_val + ecbp_tank.findClosingWatVol(mycur.tank_id, 'DAY_CLOSING', p_daytime);
	END LOOP;
	RETURN ln_return_val;
END getStorageDayClosingWatVol;

------------------------------------------------------------------
-- Function:    getStorageOpeningWatVol
-- Description: Return the OPENING Wat vol for a storage for a day
------------------------------------------------------------------
FUNCTION getStorageDayOpeningWatVol (
	p_object_id      	storage.object_id%TYPE,
	p_daytime          	DATE,
  p_exclude_out_of_service VARCHAR2 DEFAULT 'N')

RETURN NUMBER IS
ln_return_val NUMBER;

BEGIN
	ln_return_val := 0;
	FOR mycur IN cur_tanks(p_object_id, p_daytime,p_exclude_out_of_service) LOOP
		ln_return_val := ln_return_val + ecbp_tank.findOpeningWatVol(mycur.tank_id, 'DAY_CLOSING', p_daytime);
	END LOOP;
	RETURN ln_return_val;
END getStorageDayOpeningWatVol;

------------------------------------------------------------------
-- Function:    getStorageLiftedNetVolSm3
-- Description: Return the LIFTED net vol for a storage for a day
------------------------------------------------------------------
FUNCTION getStorageLiftedNetVolSm3 (
	p_object_id    		storage.object_id%TYPE,
	p_daytime          	DATE)

RETURN NUMBER IS
ln_return_val parcel_load.NET_VOL%TYPE;

CURSOR cur_tanks IS
SELECT *
FROM parcel_load
WHERE bl_date = p_daytime
AND storage_id = p_object_id;

BEGIN
	ln_return_val := 0;
	FOR mycur IN cur_tanks LOOP
		ln_return_val := ln_return_val + ec_parcel_load.net_vol(mycur.cargo_no, mycur.parcel_load_no);
	END LOOP;
	RETURN ln_return_val;
END getStorageLiftedNetVolSm3;

------------------------------------------------------------------
-- Function:    getStorageLiftedNetVolBbls
-- Description: Return the LIFTED net vol Bbls for a storage for a day
------------------------------------------------------------------
FUNCTION getStorageLiftedNetVolBbls (
	p_object_id    		storage.object_id%TYPE,
	p_daytime          	DATE)

RETURN NUMBER IS
ln_return_val parcel_load.NET_VOL%TYPE;

CURSOR cur_tanks IS
SELECT *
FROM parcel_load
WHERE bl_date = p_daytime
AND storage_id = p_object_id;

BEGIN
	ln_return_val := 0;
	FOR mycur IN cur_tanks LOOP
		ln_return_val := ln_return_val + ec_parcel_load.net_vol_bbls(mycur.cargo_no, mycur.parcel_load_no);
	END LOOP;
	RETURN ln_return_val;
END getStorageLiftedNetVolBbls;

------------------------------------------------------------------
-- Function:    getStorageLiftedGrsVolSm3
-- Description: Return the LIFTED gross vol for a storage for a day
------------------------------------------------------------------
FUNCTION getStorageLiftedGrsVolSm3 (
	p_object_id    		storage.object_id%TYPE,
	p_daytime          	DATE)

RETURN NUMBER IS
ln_return_val parcel_load.NET_VOL%TYPE;

CURSOR cur_tanks IS
SELECT *
FROM parcel_load
WHERE bl_date = p_daytime
AND storage_id = p_object_id;

BEGIN
	ln_return_val := 0;
	FOR mycur IN cur_tanks LOOP
		ln_return_val := ln_return_val + ec_parcel_load.grs_vol(mycur.cargo_no, mycur.parcel_load_no);
	END LOOP;
	RETURN ln_return_val;
END getStorageLiftedGrsVolSm3;

------------------------------------------------------------------
-- Function:    getStorageLiftedGrsVolBbls
-- Description: Return the LIFTED gross vol Bbls for a storage for a day
------------------------------------------------------------------
FUNCTION getStorageLiftedGrsVolBbls (
	p_object_id    		storage.object_id%TYPE,
	p_daytime          	DATE)

RETURN NUMBER IS
ln_return_val parcel_load.NET_VOL%TYPE;

CURSOR cur_tanks IS
SELECT *
FROM parcel_load
WHERE bl_date = p_daytime
AND storage_id = p_object_id;

BEGIN
	ln_return_val := 0;
	FOR mycur IN cur_tanks LOOP
		ln_return_val := ln_return_val + ec_parcel_load.grs_vol_bbls(mycur.cargo_no, mycur.parcel_load_no);
	END LOOP;
	RETURN ln_return_val;
END getStorageLiftedGrsVolBbls;

------------------------------------------------------------------
-- Function:    findStorageWatDayDiff
-- Description: Returns - if active - the storage diff by all attached tank diffs
------------------------------------------------------------------
FUNCTION findStorageWatDayDiff (
	p_object_id     	storage.object_id%TYPE,
	p_daytime          	DATE)

RETURN NUMBER IS

ln_return_val NUMBER;

BEGIN
		ln_return_val := getStorageDayClosingWatVol(p_object_id, p_daytime)
			- getStorageDayOpeningWatVol(p_object_id, p_daytime);
	RETURN ln_return_val;


END findStorageWatDayDiff;

---------------------------------------------------------------------------------
-- Function:    findStorageWatMthDiff
-- Description: Returns - if active - the storage diff by all attached tank diffs
--						using mht_end - mth_start volumes
---------------------------------------------------------------------------------
FUNCTION findStorageWatMthDiff (
	p_object_id    		storage.object_id%TYPE,
	p_daytime          	DATE)

RETURN NUMBER IS
ln_return_val NUMBER;

BEGIN

	IF (p_daytime = LAST_DAY(p_daytime)) THEN

		ln_return_val := getStorageDayClosingWatVol(p_object_id, LAST_DAY(p_daytime))
						- getStorageDayOpeningWatVol(p_object_id, TRUNC(p_daytime, 'mm'));

	END IF;

	RETURN ln_return_val;

END findStorageWatMthDiff;



------------------------------------------------------------------
-- Function:    findStorageTotalVolume
-- Description:
--
------------------------------------------------------------------
FUNCTION findStorageTotalVolume (
	p_object_id     	storage.object_id%TYPE,
	p_daytime          	DATE,
  p_exclude_out_of_service VARCHAR2 DEFAULT 'N')

RETURN NUMBER IS
ln_return_val NUMBER;

BEGIN
	ln_return_val := 0;
	FOR mycur IN cur_tanks(p_object_id, p_daytime,p_exclude_out_of_service) LOOP
		ln_return_val := ln_return_val + ec_tank_version.max_vol(mycur.tank_id, p_daytime, '<=');
	END LOOP;
	RETURN ln_return_val;
END findStorageTotalVolume;


------------------------------------------------------------------
-- Function:    findStorageTotalAvailable
-- Description:
--
------------------------------------------------------------------
FUNCTION findStorageTotalAvailable (
	p_object_id       	storage.object_id%TYPE,
	p_daytime          	DATE,
  p_exclude_out_of_service VARCHAR2 DEFAULT 'N')

RETURN NUMBER IS
ln_return_val NUMBER;

BEGIN
	ln_return_val := 0;
	FOR mycur IN cur_tanks(p_object_id, p_daytime,p_exclude_out_of_service) LOOP
		ln_return_val := ln_return_val + EcBp_tank.findAvailableVol(mycur.tank_id, 'DAY_CLOSING', p_daytime);
	END LOOP;
	RETURN ln_return_val;
END findStorageTotalAvailable;

------------------------------------------------------------------
-- Function:    findStorageLiftedNetVolSm3
-- Description: Returns - if active - the storage from getStorageLiftedNetVolSm3
------------------------------------------------------------------
FUNCTION findStorageLiftedNetVolSm3 (
	p_object_id      	storage.object_id%TYPE,
	p_daytime          	DATE)

RETURN NUMBER IS

ln_return_val NUMBER;
lv_sql		VARCHAR2(1000);

BEGIN
	lv_sql := 'select ecdp_if_tran_cargo.GETLIFTEDNETVOLSM3('''||p_object_id||''','''||p_daytime||''') from dual';
	EXECUTE IMMEDIATE lv_sql INTO ln_return_val;
	RETURN ln_return_val;

END findStorageLiftedNetVolSm3;

------------------------------------------------------------------
-- Function:    findStorageLiftedNetVolBbls
-- Description: Returns - if active - storage from getStorageLiftedNetVolBbls
------------------------------------------------------------------
FUNCTION findStorageLiftedNetVolBbls (
	p_object_id      	storage.object_id%TYPE,
	p_daytime          	DATE)

RETURN NUMBER IS

ln_return_val NUMBER;
lv_sql		VARCHAR2(1000);

BEGIN
	lv_sql := 'select ecdp_if_tran_cargo.GETLIFTEDNETVOLBBLS('''||p_object_id||''','''||p_daytime||''') from dual';
	EXECUTE IMMEDIATE lv_sql INTO ln_return_val;
	RETURN ln_return_val;

END findStorageLiftedNetVolBbls;

------------------------------------------------------------------
-- Function:    findStorageLiftedGrsVolSm3
-- Description: Returns - if active - the storage from getStorageLiftedGrsVolSm3
------------------------------------------------------------------
FUNCTION findStorageLiftedGrsVolSm3 (
	p_object_id      	storage.object_id%TYPE,
	p_daytime          	DATE)

RETURN NUMBER IS

ln_return_val NUMBER;
lv_sql		VARCHAR2(1000);

BEGIN
	lv_sql := 'select ecdp_if_tran_cargo.GETLIFTEDGRSVOLSM3('''||p_object_id||''','''||p_daytime||''') from dual';
	EXECUTE IMMEDIATE lv_sql INTO ln_return_val;
	RETURN ln_return_val;

END findStorageLiftedGrsVolSm3;

------------------------------------------------------------------
-- Function:    findStorageLiftedGrsVolBbls
-- Description: Returns - if active - storage from getStorageLiftedGrsVolBbls
------------------------------------------------------------------
FUNCTION findStorageLiftedGrsVolBbls (
	p_object_id      	storage.object_id%TYPE,
	p_daytime          	DATE)

RETURN NUMBER IS

ln_return_val NUMBER;
lv_sql		VARCHAR2(1000);

BEGIN
	lv_sql := 'select ecdp_if_tran_cargo.GETLIFTEDGRSVOLBBLS('''||p_object_id||''','''||p_daytime||''') from dual';
	EXECUTE IMMEDIATE lv_sql INTO ln_return_val;
	RETURN ln_return_val;

END findStorageLiftedGrsVolBbls;

------------------------------------------------------------------
-- Function:    findExpNotLiftedDayNetBbls
-- Description: Returns - if active - storage from findExpNotLiftedDayNetBbls
------------------------------------------------------------------
FUNCTION findExpNotLiftedDayNetBbls (
	p_object_id VARCHAR2,
	p_daytime          	DATE)

RETURN NUMBER IS

ln_return_val NUMBER;
lv_sql		VARCHAR2(1000);

BEGIN
	lv_sql := 'select ecdp_if_tran_cargo.GETDAYEXPNOTLIFTEDNETBBLS('''||p_object_id||''','''||p_daytime||''') from dual';
	EXECUTE IMMEDIATE lv_sql INTO ln_return_val;
	RETURN ln_return_val;

END findExpNotLiftedDayNetBbls;

------------------------------------------------------------------
-- Function:    findExpNotLiftedMthNetBbls
-- Description: Returns - if active - storage from findExpNotLiftedMthNetBbls
------------------------------------------------------------------
FUNCTION findExpNotLiftedMthNetBbls (
	p_object_id VARCHAR2,
	p_daytime          	DATE)

RETURN NUMBER IS

ln_return_val NUMBER;
lv_sql		VARCHAR2(1000);

BEGIN
	lv_sql := 'select ecdp_if_tran_cargo.GETMTHEXPNOTLIFTEDNETBBLS('''||p_object_id||''','''||p_daytime||''') from dual';
	EXECUTE IMMEDIATE lv_sql INTO ln_return_val;
	RETURN ln_return_val;

END findExpNotLiftedMthNetBbls;

------------------------------------------------------------------
-- Function:    findExpNotLiftedDayNetSm3
-- Description: Returns - if active - storage from findExpNotLiftedDayNetSm3
------------------------------------------------------------------
FUNCTION findExpNotLiftedDayNetSm3 (
	p_object_id VARCHAR2,
	p_daytime          	DATE)

RETURN NUMBER IS

ln_return_val NUMBER;
lv_sql		VARCHAR2(1000);

BEGIN
	lv_sql := 'select ecdp_if_tran_cargo.GETDAYEXPNOTLIFTEDNETSM3('''||p_object_id||''','''||p_daytime||''') from dual';
	EXECUTE IMMEDIATE lv_sql INTO ln_return_val;
	RETURN ln_return_val;

END findExpNotLiftedDayNetSm3;

------------------------------------------------------------------
-- Function:    findExpNotLiftedMthNetSm3
-- Description: Returns - if active - storage from findExpNotLiftedMthNetSm3
------------------------------------------------------------------
FUNCTION findExpNotLiftedMthNetSm3 (
	p_object_id VARCHAR2,
	p_daytime          	DATE)

RETURN NUMBER IS

ln_return_val NUMBER;
lv_sql		VARCHAR2(1000);

BEGIN
	lv_sql := 'select ecdp_if_tran_cargo.GETMTHEXPNOTLIFTEDNETSM3('''||p_object_id||''','''||p_daytime||''') from dual';
	EXECUTE IMMEDIATE lv_sql INTO ln_return_val;
	RETURN ln_return_val;

END findExpNotLiftedMthNetSm3;

------------------------------------------------------------------
-- Function:    findExpNotLiftedDayGrsSm3
-- Description: Returns - if active - storage from findExpNotLiftedDayGrsSm3
------------------------------------------------------------------
FUNCTION findExpNotLiftedDayGrsSm3 (
	p_object_id VARCHAR2,
	p_daytime          	DATE)

RETURN NUMBER IS

ln_return_val NUMBER;
lv_sql		VARCHAR2(1000);

BEGIN
	lv_sql := 'select ecdp_if_tran_cargo.GETDAYEXPNOTLIFTEDGRSSM3('''||p_object_id||''','''||p_daytime||''') from dual';
	EXECUTE IMMEDIATE lv_sql INTO ln_return_val;
	RETURN ln_return_val;

END findExpNotLiftedDayGrsSm3;

------------------------------------------------------------------
-- Function:    findExpNotLiftedMthGrsSm3
-- Description: Returns - if active - storage from findExpNotLiftedMthGrsSm3
------------------------------------------------------------------
FUNCTION findExpNotLiftedMthGrsSm3 (
	p_object_id VARCHAR2,
	p_daytime          	DATE)

RETURN NUMBER IS

ln_return_val NUMBER;
lv_sql		VARCHAR2(1000);

BEGIN
	lv_sql := 'select ecdp_if_tran_cargo.GETMTHEXPNOTLIFTEDGRSSM3('''||p_object_id||''','''||p_daytime||''') from dual';
	EXECUTE IMMEDIATE lv_sql INTO ln_return_val;
	RETURN ln_return_val;

END findExpNotLiftedMthGrsSm3;

------------------------------------------------------------------
-- Function:    findExpNotLiftedDayGrsBbls
-- Description: Returns - if active - storage from findExpNotLiftedDayGrsBbls
------------------------------------------------------------------
FUNCTION findExpNotLiftedDayGrsBbls (
	p_object_id VARCHAR2,
	p_daytime          	DATE)

RETURN NUMBER IS

ln_return_val NUMBER;
lv_sql		VARCHAR2(1000);

BEGIN
	lv_sql := 'select ecdp_if_tran_cargo.GETDAYEXPNOTLIFTEDGRSBBLS('''||p_object_id||''','''||p_daytime||''') from dual';
	EXECUTE IMMEDIATE lv_sql INTO ln_return_val;
	RETURN ln_return_val;

END findExpNotLiftedDayGrsBbls;

------------------------------------------------------------------
-- Function:    findExpNotLiftedMthGrsBbls
-- Description: Returns - if active - storage from findExpNotLiftedMthGrsBbls
------------------------------------------------------------------
FUNCTION findExpNotLiftedMthGrsBbls (
	p_object_id VARCHAR2,
	p_daytime          	DATE)

RETURN NUMBER IS

ln_return_val NUMBER;
lv_sql		VARCHAR2(1000);

BEGIN
	lv_sql := 'select ecdp_if_tran_cargo.GETMTHEXPNOTLIFTEDGRSBBLS('''||p_object_id||''','''||p_daytime||''') from dual';
	EXECUTE IMMEDIATE lv_sql INTO ln_return_val;
	RETURN ln_return_val;

END findExpNotLiftedMthGrsBbls;


END EcBp_Storage_measurement;