CREATE OR REPLACE PACKAGE EcBp_Storage_measurement IS

/****************************************************************
** Package        :  EcBp_Storage_measurement, header part
**
** $Revision: 1.20 $
**
** Purpose        :  Finds storage differences for active storages
**
** Documentation  :  www.energy-components.com
**
** Created  : 12.10.2001  Harald Vetrhus
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
**          01.06.04 EOL   Added mass functions
**          03.08.04 kaurrnar    removed sysnam and update as necessary
**          28.01.05 idrussab	 Added 4 new functions ie getStorageLiftedNetVolSm3, getStorageLiftedNetVolBbls, getStorageLiftedGrsVolSm3, getStorageLiftedGrsVolBbls
**  2.0     28.01.2005 zalannur   Tracker #1905: Added 4 new functions to call the above functions, ie findStorageLiftedGrsVolSm3
**	        28.02.2005 kaurrnar	Removed deadcodes
** 	        09.01.2007 kaurrjes ECPD-4806: Added 6 new functions ie findStorageLiftedGrsVolSm3, findStorageLiftedGrsVolBbls, findExpNotLiftedDayGrsBbls, findExpNotLiftedMthGrsBbls,
				findExpNotLiftedDayGrsSm3, findExpNotLiftedMthGrsSm3
**          17.12.2008 amirrasn	ECPD-10455 :Changed default value p_exclude_out_of_service from 'Y' to 'N' for all affected function
**          08.09.2010 saadsiti ECPD-15639: Added new function getStorageDayGrsOilCloseVol
**          27.04.2012 musthram	ECPD-19795 : Storage level energy functions should handle "Out of service" parameter
**			01.11.2012 abdulmaw ECPD-22037: Added findStorageDiluentDayDiff, getStorageDayClosingDiluent, getStorageDayOpeningDiluent
*****************************************************************/

--
------------------------------------------------------------------
-- Function:    findStorageGrsDayDiff
-- Description: Returns - if active - the storage diff by all attached tank diffs
------------------------------------------------------------------

FUNCTION findStorageGrsDayDiff (
    p_object_id            storage.object_id%TYPE,
    p_daytime              DATE)

RETURN NUMBER;

------------------------------------------------------------------
-- Function:    findStorageGrsMassDayDiff
-- Description: Returns - if active - the mass storage diff by all attached tank diffs
------------------------------------------------------------------

FUNCTION findStorageGrsMassDayDiff (
    p_object_id            storage.object_id%TYPE,
    p_daytime          DATE)

RETURN NUMBER;

------------------------------------------------------------------
-- Function:    findStorageGrsMthDiff
-- Description: Returns - if active - the storage diff by all attached tank diffs
--						using mht_end - mth_start volumes
------------------------------------------------------------------

FUNCTION findStorageGrsMthDiff (
    p_object_id            storage.object_id%TYPE,
    p_daytime          DATE)

RETURN NUMBER;

------------------------------------------------------------------
-- Function:    findStorageGrsMassMthDiff
-- Description: Returns - if active - the storage diff by all attached tank diffs
--						using mht_end - mth_start volumes
------------------------------------------------------------------

FUNCTION findStorageGrsMassMthDiff (
    p_object_id            storage.object_id%TYPE,
    p_daytime          DATE)

RETURN NUMBER;

------------------------------------------------------------------
-- Function:    findStorageNetMassMthDiff
-- Description: Returns - if active - the storage diff by all attached tank diffs
--						using mht_end - mth_start volumes
------------------------------------------------------------------

FUNCTION findStorageNetMassMthDiff (
    p_object_id            storage.object_id%TYPE,
    p_daytime          DATE)

RETURN NUMBER;

--
------------------------------------------------------------------
-- Function:    findStorageNetDayDiff
-- Description: Returns - if active - the storage diff by all attached tank diffs
------------------------------------------------------------------

FUNCTION findStorageNetDayDiff (
    p_object_id            storage.object_id%TYPE,
    p_daytime          DATE)

RETURN NUMBER;

--
------------------------------------------------------------------
-- Function:    findStorageDiluentDayDiff
-- Description: Returns - if active - the storage diff by all attached tank diffs
------------------------------------------------------------------

FUNCTION findStorageDiluentDayDiff (
    p_object_id            storage.object_id%TYPE,
    p_daytime          DATE)

RETURN NUMBER;

------------------------------------------------------------------
-- Function:    findStorageNetMassDayDiff
-- Description: Returns - if active - the storage diff by all attached tank diffs
------------------------------------------------------------------

FUNCTION findStorageNetMassDayDiff (
    p_object_id            storage.object_id%TYPE,
    p_daytime          DATE)

RETURN NUMBER;

------------------------------------------------------------------
-- Function:    findStorageNetMthDiff
-- Description: Returns - if active - the storage diff by all attached tank diffs
--						using mht_end - mth_start volumes
------------------------------------------------------------------

FUNCTION findStorageNetMthDiff (
    p_object_id            storage.object_id%TYPE,
    p_daytime          DATE)

RETURN NUMBER;

--
------------------------------------------------------------------
-- Function:    findStorageEnergyDayDiff
-- Description: Returns - if active - the storage diff by all attached tank diffs
------------------------------------------------------------------

FUNCTION findStorageEnergyDayDiff (
    p_object_id            storage.object_id%TYPE,
    p_daytime          DATE)

RETURN NUMBER;

--
------------------------------------------------------------------
-- Function:    findStorageEnergyMthDiff
-- Description: Returns - if active - the storage diff by all attached tank diffs
------------------------------------------------------------------

FUNCTION findStorageEnergyMthDiff (
    p_object_id            storage.object_id%TYPE,
    p_daytime          DATE)

RETURN NUMBER;

------------------------------------------------------------------
-- Function:    getStorageDayGrsClosingVol
-- Description: Return the CLOSING grs dip level for a storage for a day
------------------------------------------------------------------

FUNCTION getStorageDayGrsClosingVol (
    p_object_id            storage.object_id%TYPE,
    p_daytime          DATE,
    p_exclude_out_of_service VARCHAR2 DEFAULT 'N')

RETURN NUMBER;

------------------------------------------------------------------
-- Function:    getStorageDayGrsStdOilCloseVol
-- Description: Return the CLOSING grs dip level for a storage for a day
------------------------------------------------------------------

FUNCTION getStorageDayGrsStdOilCloseVol (
    p_object_id            storage.object_id%TYPE,
    p_daytime          DATE,
    p_exclude_out_of_service VARCHAR2 DEFAULT 'N')

RETURN NUMBER;



------------------------------------------------------------------
-- Function:    getStorageDayOpenGrsDipLevel
-- Description: Return the OPENING grs dip level for a storage for a day
------------------------------------------------------------------

--FUNCTION getStorageDayOpenGrsDipLevel (
FUNCTION getStorageDayGrsOpeningVol (
    p_object_id            storage.object_id%TYPE,
    p_daytime          DATE,
    p_exclude_out_of_service VARCHAR2 DEFAULT 'N')

RETURN NUMBER;

------------------------------------------------------------------
-- Function:    getStorageDayGrsClosingMass
-- Description: Return the CLOSING grs dip level for a storage for a day
------------------------------------------------------------------

FUNCTION getStorageDayGrsClosingMass (
    p_object_id            storage.object_id%TYPE,
    p_daytime          DATE,
    p_exclude_out_of_service VARCHAR2 DEFAULT 'N')

RETURN NUMBER;

------------------------------------------------------------------
-- Function:    getStorageDayGrsOpeningMass
-- Description: Return the OPENING grs dip level for a storage for a day
------------------------------------------------------------------

FUNCTION getStorageDayGrsOpeningMass (
    p_object_id            storage.object_id%TYPE,
    p_daytime          DATE,
    p_exclude_out_of_service VARCHAR2 DEFAULT 'N')

RETURN NUMBER;

------------------------------------------------------------------
-- Function:    getStorageDayClosingDiluent
-- Description: Return the CLOSING net vol for a storage for a day
------------------------------------------------------------------

FUNCTION getStorageDayClosingDiluent (
    p_object_id            storage.object_id%TYPE,
    p_daytime          DATE,
    p_exclude_out_of_service VARCHAR2 DEFAULT 'N')

RETURN NUMBER;

------------------------------------------------------------------
-- Function:    getStorageDayOpeningDiluent
-- Description: Return the OPENING net vol for a storage for a day
------------------------------------------------------------------

FUNCTION getStorageDayOpeningDiluent (
    p_object_id            storage.object_id%TYPE,
    p_daytime          DATE,
    p_exclude_out_of_service VARCHAR2 DEFAULT 'N')

RETURN NUMBER;

------------------------------------------------------------------
-- Function:    getStorageClosingNetVol
-- Description: Return the CLOSING net vol for a storage for a day
------------------------------------------------------------------

FUNCTION getStorageDayClosingNetVol (
    p_object_id            storage.object_id%TYPE,
    p_daytime          DATE,
    p_exclude_out_of_service VARCHAR2 DEFAULT 'N')

RETURN NUMBER;

------------------------------------------------------------------
-- Function:    getStorageOpeningNetVol
-- Description: Return the OPENING net vol for a storage for a day
------------------------------------------------------------------

FUNCTION getStorageDayOpeningNetVol (
    p_object_id            storage.object_id%TYPE,
    p_daytime          DATE,
    p_exclude_out_of_service VARCHAR2 DEFAULT 'N')

RETURN NUMBER;


------------------------------------------------------------------
-- Function:    getStorageClosingEnergy
-- Description: Return the CLOSING energy for a storage for a day
------------------------------------------------------------------

FUNCTION getStorageDayClosingEnergy (
    p_object_id            storage.object_id%TYPE,
    p_daytime          DATE,
    p_exclude_out_of_service VARCHAR2 DEFAULT 'N')

RETURN NUMBER;

------------------------------------------------------------------
-- Function:    getStorageOpeningEnergy
-- Description: Return the OPENING energy for a storage for a day
------------------------------------------------------------------

FUNCTION getStorageDayOpeningEnergy (
    p_object_id            storage.object_id%TYPE,
    p_daytime          DATE,
    p_exclude_out_of_service VARCHAR2 DEFAULT 'N')

RETURN NUMBER;

------------------------------------------------------------------
-- Function:    getStorageClosingNetMass
-- Description: Return the CLOSING net mass for a storage for a day
------------------------------------------------------------------

FUNCTION getStorageDayClosingNetMass (
    p_object_id            storage.object_id%TYPE,
    p_daytime          DATE,
    p_exclude_out_of_service VARCHAR2 DEFAULT 'N')

RETURN NUMBER;

------------------------------------------------------------------
-- Function:    getStorageOpeningNetMass
-- Description: Return the OPENING net mass for a storage for a day
------------------------------------------------------------------

FUNCTION getStorageDayOpeningNetMass (
    p_object_id            storage.object_id%TYPE,
    p_daytime          DATE,
    p_exclude_out_of_service VARCHAR2 DEFAULT 'N')

RETURN NUMBER;

------------------------------------------------------------------
-- Function:    getStorageClosingWatVol
-- Description: Return the CLOSING wat vol for a storage for a day
------------------------------------------------------------------

FUNCTION getStorageDayClosingWatVol (
    p_object_id            storage.object_id%TYPE,
    p_daytime          DATE,
    p_exclude_out_of_service VARCHAR2 DEFAULT 'N')

RETURN NUMBER;

------------------------------------------------------------------
-- Function:    getStorageOpeningWatVol
-- Description: Return the OPENING wat vol for a storage for a day
------------------------------------------------------------------

FUNCTION getStorageDayOpeningWatVol (
    p_object_id            storage.object_id%TYPE,
    p_daytime          DATE,
    p_exclude_out_of_service VARCHAR2 DEFAULT 'N')

RETURN NUMBER;

------------------------------------------------------------------
-- Function:    getStorageLiftedNetVolSm3
-- Description: Return the LIFTED net vol for a storage for a day
------------------------------------------------------------------

FUNCTION getStorageLiftedNetVolSm3 (
    p_object_id            storage.object_id%TYPE,
    p_daytime          DATE)

RETURN NUMBER;


------------------------------------------------------------------
-- Function:    getStorageLiftedNetVolBbls
-- Description: Return the LIFTED net vol Bbls for a storage for a day
------------------------------------------------------------------

FUNCTION getStorageLiftedNetVolBbls (
    p_object_id            storage.object_id%TYPE,
    p_daytime          DATE)

RETURN NUMBER;

------------------------------------------------------------------
-- Function:    getStorageLiftedGrsVolSm3
-- Description: Return the LIFTED Grs vol for a storage for a day
------------------------------------------------------------------

FUNCTION getStorageLiftedGrsVolSm3 (
    p_object_id            storage.object_id%TYPE,
    p_daytime          DATE)

RETURN NUMBER;

------------------------------------------------------------------
-- Function:    getStorageLiftedGrsVolBbls
-- Description: Return the LIFTED Grs vol Bbls for a storage for a day
------------------------------------------------------------------

FUNCTION getStorageLiftedGrsVolBbls (
    p_object_id            storage.object_id%TYPE,
    p_daytime          DATE)

RETURN NUMBER;

------------------------------------------------------------------
-- Function:    findStorageWatDayDiff
-- Description: Returns - if active - the storage diff by all attached tank diffs
------------------------------------------------------------------

FUNCTION findStorageWatDayDiff (
    p_object_id            storage.object_id%TYPE,
    p_daytime          DATE)

RETURN NUMBER;

------------------------------------------------------------------
-- Function:    findStorageGrsMthDiff
-- Description: Returns - if active - the storage diff by all attached tank diffs
--						using mht_end - mth_start volumes
------------------------------------------------------------------

FUNCTION findStorageWatMthDiff (
    p_object_id            storage.object_id%TYPE,
    p_daytime          DATE)

RETURN NUMBER;

FUNCTION findStorageTotalVolume (
    p_object_id            storage.object_id%TYPE,
    p_daytime          DATE,
    p_exclude_out_of_service VARCHAR2 DEFAULT 'N')

RETURN NUMBER;

FUNCTION findStorageTotalAvailable (
    p_object_id            storage.object_id%TYPE,
    p_daytime          DATE,
    p_exclude_out_of_service VARCHAR2 DEFAULT 'N')

RETURN NUMBER;

------------------------------------------------------------------
-- Function:    findStorageLiftedNetVolSm3
-- Description: Returns - if active - the storage from findStorageLiftedNetVolSm3
------------------------------------------------------------------

FUNCTION findStorageLiftedNetVolSm3 (
    p_object_id            storage.object_id%TYPE,
    p_daytime              DATE)

RETURN NUMBER;

------------------------------------------------------------------
-- Function:    findStorageLiftedNetVolBbls

-- Description: Returns - if active - the storage from findStorageLiftedNetVolBbls
------------------------------------------------------------------

FUNCTION findStorageLiftedNetVolBbls
 (
    p_object_id            storage.object_id%TYPE,
    p_daytime              DATE)

RETURN NUMBER;

------------------------------------------------------------------
-- Function:    findExpNotLiftedDayNetBbls

-- Description: Returns - if active - the storage from findExpNotLiftedDayNetBbls
------------------------------------------------------------------
FUNCTION findExpNotLiftedDayNetBbls(p_object_id VARCHAR2, p_daytime DATE) RETURN NUMBER;

------------------------------------------------------------------
-- Function:    findExpNotLiftedMthNetBbls

-- Description: Returns - if active - the storage from findExpNotLiftedMthNetBbls
------------------------------------------------------------------
FUNCTION findExpNotLiftedMthNetBbls(p_object_id VARCHAR2, p_daytime DATE) RETURN NUMBER;

------------------------------------------------------------------
-- Function:    findExpNotLiftedDayNetSm3

-- Description: Returns - if active - the storage from findExpNotLiftedDayNetSm3
------------------------------------------------------------------
FUNCTION findExpNotLiftedDayNetSm3(p_object_id VARCHAR2, p_daytime DATE) RETURN NUMBER;

------------------------------------------------------------------
-- Function:    findExpNotLiftedMthNetSm3

-- Description: Returns - if active - the storage from findExpNotLiftedMthNetSm3
------------------------------------------------------------------
FUNCTION findExpNotLiftedMthNetSm3(p_object_id VARCHAR2, p_daytime DATE) RETURN NUMBER;

------------------------------------------------------------------
-- Function:    findStorageLiftedGrsVolSm3

-- Description: Returns - if active - the storage from findStorageLiftedGrsVolSm3
------------------------------------------------------------------

FUNCTION findStorageLiftedGrsVolSm3
 (
    p_object_id            storage.object_id%TYPE,
    p_daytime              DATE)

RETURN NUMBER;

------------------------------------------------------------------
-- Function:    findStorageLiftedGrsVolBbls
-- Description: Returns - if active - the storage from findStorageLiftedGrsVolBbls
------------------------------------------------------------------

FUNCTION findStorageLiftedGrsVolBbls
 (
    p_object_id            storage.object_id%TYPE,
    p_daytime              DATE)

RETURN NUMBER;

------------------------------------------------------------------
-- Function:    findExpNotLiftedDayGrsVolBbls

-- Description: Returns - if active - the storage from findExpNotLiftedDayGrsVolBbls
------------------------------------------------------------------
FUNCTION findExpNotLiftedDayGrsBbls(p_object_id VARCHAR2, p_daytime DATE) RETURN NUMBER;

------------------------------------------------------------------
-- Function:    findExpNotLiftedMthGrsVolBbls

-- Description: Returns - if active - the storage from findExpNotLiftedMthGrsVolBbls
------------------------------------------------------------------
FUNCTION findExpNotLiftedMthGrsBbls(p_object_id VARCHAR2, p_daytime DATE) RETURN NUMBER;

------------------------------------------------------------------
-- Function:    findExpNotLiftedDayGrsVolSm3

-- Description: Returns - if active - the storage from findExpNotLiftedDayGrsVolSm3
------------------------------------------------------------------
FUNCTION findExpNotLiftedDayGrsSm3(p_object_id VARCHAR2, p_daytime DATE) RETURN NUMBER;

------------------------------------------------------------------
-- Function:    findExpNotLiftedMthGrsVolSm3

-- Description: Returns - if active - the storage from findExpNotLiftedMthGrsVolSm3
------------------------------------------------------------------
FUNCTION findExpNotLiftedMthGrsSm3(p_object_id VARCHAR2, p_daytime DATE) RETURN NUMBER;

END EcBp_Storage_measurement;