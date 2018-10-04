CREATE OR REPLACE PACKAGE EcBp_Storage_Lift_Nomination IS
/******************************************************************************
** Package        :  EcBp_Storage_Lift_Nomination, header part
**
** $Revision: 1.26.4.6 $
**
** Purpose        :  Business logic for storage lift nominations
**
** Documentation  :  www.energy-components.com
**
** Created  : 24.09.2004 Kari Sandvik
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- -------------------------------------------
** #.#   DD.MM.YYYY  <initials>
** 1.9	 01.12.2005  skjorsti	Added function getProratedMonthEnd(PARCEL_NO)
** 1.10  04.07.2006 naerlola Added function getUnloadVol
**       03.08.2010 lauuufus ECPD-12065 Add new procedure updateStorageLifting() and insertCargo()
**		 02.02.2012 muhammah ECPD-19571
**       28.02.2012 sharawan ECPD-20106 Modify parameter for getNomUnit to accept object id instead of storage id
**	     12.09.2012 meisihil ECPD-20962: Added function getLoadBalDeltaVol
**		 15.01.2013 muhammah ECPD-23097 Add function: getLiftedVolByIncoterm
**	     24.01.2013 meisihil ECPD-20056: Added functions aggrSubDayLifting, calcSubDayLifting, calcSubDayLiftingCargo, calcAggrSubDaySplitQty, calcSplitQty
**                                       to support liftings spread over hours
**	  	 17.05.2013 chooysie ECPD-24107: Add facility class to insertCargo procedure
********************************************************************/


FUNCTION getNomToleranceMinVol(p_parcel_no NUMBER) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getNomToleranceMinVol, WNDS, WNPS, RNPS);

FUNCTION getNomToleranceMaxVol(p_parcel_no NUMBER) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getNomToleranceMaxVol, WNDS, WNPS, RNPS);

FUNCTION getLiftedVol(p_parcel_no NUMBER, p_xtra_qty NUMBER DEFAULT 0, p_incl_unload VARCHAR2 DEFAULT 'Y') RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getLiftedVol, WNDS, WNPS, RNPS);

FUNCTION getUnloadVol(p_parcel_no NUMBER, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getUnloadVol, WNDS, WNPS, RNPS);

FUNCTION getLoadBalDeltaVol(p_parcel_no NUMBER, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;

FUNCTION getUnloadBalDeltaVol(p_parcel_no NUMBER, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;

FUNCTION getNomUnit(p_object_id VARCHAR2,p_xtra_qty NUMBER DEFAULT 0,p_lifting_event VARCHAR2 DEFAULT 'LOAD') RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (getNomUnit, WNDS, WNPS, RNPS);

FUNCTION getProratedMonthEnd(p_parcel_no NUMBER) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getProratedMonthEnd, WNDS, WNPS, RNPS);

FUNCTION expectedUnloadDate(p_parcel_no NUMBER) RETURN DATE;
PRAGMA RESTRICT_REFERENCES (expectedUnloadDate, WNDS, WNPS, RNPS);

PROCEDURE bdStorageLiftNomination(p_parcel_no NUMBER);

PROCEDURE aiStorageLiftNomination(p_parcel_no NUMBER, p_nom_date DATE, p_nom_date_range VARCHAR2,p_req_date DATE, p_REQ_DATE_RANGE VARCHAR2, p_REQ_GRS_VOL NUMBER, p_REQ_TOLERANCE_TYPE VARCHAR2, p_nom_grs_vol NUMBER, p_user VARCHAR2 DEFAULT NULL);

PROCEDURE aiStorageLiftNomination2(p_parcel_no NUMBER, p_REQ_GRS_VOL2 NUMBER, p_nom_grs_vol2 NUMBER, p_user VARCHAR2 DEFAULT NULL);

PROCEDURE aiStorageLiftNomination3(p_parcel_no NUMBER, p_REQ_GRS_VOL3 NUMBER, p_nom_grs_vol3 NUMBER, p_user VARCHAR2 DEFAULT NULL);

PROCEDURE validateLiftingIndicator(p_old_lifting_code VARCHAR2, p_new_lifting_code VARCHAR2);

PROCEDURE validateBalanceInd(p_cargo_no VARCHAR2);

PROCEDURE deleteNomination(p_storage_id VARCHAR2, p_from_date DATE, p_to_date DATE);

PROCEDURE insertFromLiftProg(p_parcel_no NUMBER, p_nom_qty NUMBER, p_nom_date DATE, p_user VARCHAR2 DEFAULT NULL);

PROCEDURE updateStorageLifting(p_parcel_no NUMBER, p_net_vol NUMBER, p_grs_vol NUMBER, p_net_mass NUMBER, p_grs_mass NUMBER, p_net_energy NUMBER, p_grs_energy NUMBER,p_user VARCHAR2 DEFAULT NULL);

PROCEDURE insertCargo(p_cargo_no VARCHAR2, p_bl_date DATE, p_fcty_class_1 VARCHAR2);

FUNCTION insertReadyForHabour(p_cargo_status VARCHAR2) RETURN VARCHAR2;

FUNCTION getDefSplit(p_parcel_no NUMBER,p_lifting_account_id VARCHAR2) RETURN NUMBER;

PROCEDURE validateSplit(p_Parcel_No NUMBER);

PROCEDURE createUpdateSplit(p_Parcel_No NUMBER, p_old_lifting_account_id VARCHAR2, p_new_lifting_account_id VARCHAR2);

FUNCTION calcNomSplitQty(p_parcel_no NUMBER,p_company_id VARCHAR2,p_lifting_account_id VARCHAR2, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;

FUNCTION calcActualSplitQty(p_parcel_no NUMBER, p_company_id VARCHAR2, p_lifting_account_id VARCHAR2, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;

FUNCTION calcAggrSubDaySplitQty(p_parcel_no NUMBER,p_company_id VARCHAR2,p_lifting_account_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;

FUNCTION calcSplitQty(p_parcel_no NUMBER,p_company_id VARCHAR2,p_lifting_account_id VARCHAR2, p_daytime DATE, p_qty NUMBER) RETURN NUMBER;

FUNCTION getLiftedVolByIncoterm (p_parcel_no NUMBER, p_xtra_qty NUMBER) RETURN NUMBER;

FUNCTION aggrSubDayLifting(p_parcel_no NUMBER, p_daytime DATE, p_column VARCHAR2 DEFAULT NULL, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;

PROCEDURE calcSubDayLifting(p_parcel_no NUMBER);

PROCEDURE calcSubDayLiftingCargo(p_cargo_no NUMBER);

FUNCTION getLiftedVolSubDay (p_parcel_no NUMBER, p_daytime DATE, p_summer_time VARCHAR2, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;

FUNCTION getLoadBalDeltaVolSubDay (p_parcel_no NUMBER, p_daytime DATE, p_summer_time VARCHAR2, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;

END EcBp_Storage_Lift_Nomination;