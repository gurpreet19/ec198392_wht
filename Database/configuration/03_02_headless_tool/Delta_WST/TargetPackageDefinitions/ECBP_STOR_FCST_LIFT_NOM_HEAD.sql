CREATE OR REPLACE PACKAGE EcBP_Stor_Fcst_Lift_Nom IS
/******************************************************************************
** Package        :  EcBP_Stor_Fcst_Lift_Nom, header part
**
** $Revision: 1.4.4.3 $
**
** Purpose        :  Business logic for storage lift nominations
**
** Documentation  :  www.energy-components.com
**
** Created  : 04.06.2008 Kari Sandvik
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- -------------------------------------------
**	     24.01.2013 meisihil ECPD-20056: Added functions aggrSubDayLifting, calcSubDayLifting, calcSubDayLiftingCargo
**                                       to support liftings spread over hours
**		 18.12.2013	chooysie ECPD-26389: Added function getLiftedVolByIncoterm
********************************************************************/


FUNCTION getNomToleranceMinVol(p_parcel_no NUMBER, p_forecast_id VARCHAR2) RETURN NUMBER;

FUNCTION getNomToleranceMaxVol(p_parcel_no NUMBER, p_forecast_id VARCHAR2) RETURN NUMBER;

PROCEDURE aiStorageLiftNomination(p_parcel_no NUMBER, p_forecast_id VARCHAR2, p_nom_date DATE, p_nom_date_range VARCHAR2,p_req_date DATE, p_REQ_DATE_RANGE VARCHAR2, p_REQ_GRS_VOL NUMBER, p_REQ_TOLERANCE_TYPE VARCHAR2, p_nom_grs_vol NUMBER);

PROCEDURE aiStorageLiftNomination2(p_forecast_id VARCHAR2, p_parcel_no NUMBER, p_REQ_GRS_VOL2 NUMBER, p_nom_grs_vol2 NUMBER, p_user VARCHAR2 DEFAULT NULL);

PROCEDURE aiStorageLiftNomination3(p_forecast_id VARCHAR2, p_parcel_no NUMBER, p_REQ_GRS_VOL3 NUMBER, p_nom_grs_vol3 NUMBER, p_user VARCHAR2 DEFAULT NULL);

PROCEDURE validateLiftingIndicator(p_forecast_id VARCHAR2, p_old_lifting_code VARCHAR2, p_new_lifting_code VARCHAR2);

PROCEDURE deleteNomination(p_storage_id VARCHAR2, p_forecast_id VARCHAR2, p_from_date DATE, p_to_date DATE);

PROCEDURE insertFromLiftProg(p_parcel_no NUMBER, p_forecast_id VARCHAR2, p_nom_qty NUMBER, p_nom_date DATE);

FUNCTION aggrSubDayLifting(p_forecast_id VARCHAR2, p_parcel_no NUMBER, p_daytime DATE, p_column VARCHAR2 DEFAULT NULL, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;

PROCEDURE calcSubDayLifting(p_forecast_id VARCHAR2, p_parcel_no NUMBER);

PROCEDURE calcSubDayLiftingCargo(p_forecast_id VARCHAR2, p_cargo_no NUMBER);

PROCEDURE createMissingSubDayLift(p_forecast_id VARCHAR2, p_parcel_no NUMBER);

FUNCTION getLiftedVolByIncoterm (p_parcel_no NUMBER, p_forecast_id VARCHAR2, p_xtra_qty NUMBER) RETURN NUMBER;

END EcBP_Stor_Fcst_Lift_Nom;