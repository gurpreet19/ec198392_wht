CREATE OR REPLACE PACKAGE ue_Stor_Fcst_Lift_Nom IS

/******************************************************************************
** Package        :  ue_Stor_Fcst_Lift_Nom, header part
**
** $Revision: 1.1.40.2 $
**
** Purpose        :  Includes user-exit functionality for terminal operation screens
**
** Documentation  :  www.energy-components.com
**
** Created  : 05.06.2008 Kari Sandvik
**
** Modification history:
**
** Date        Whom     Change description:
** -------     ------   -----------------------------------------------
** 24.01.2013  meisihil  ECPD-20962: Added functions aggrSubDayLifting, calcSubDayLifting to support liftings spread over hours
** -------     ------   ----------------------------------------------------------------------------------------------------
*/

PROCEDURE deleteNomination(p_storage_id VARCHAR2,p_forecast_id VARCHAR2,p_from_date DATE,p_to_date DATE);

PROCEDURE setBalanceDelta(p_forecast_id VARCHAR2, p_parcel_no NUMBER);

FUNCTION aggrSubDayLifting(p_forecast_id VARCHAR2, p_parcel_no NUMBER, p_daytime DATE, p_column VARCHAR2 DEFAULT NULL, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;

PROCEDURE calcSubDayLifting(p_forecast_id VARCHAR2, p_parcel_no NUMBER);

END ue_Stor_Fcst_Lift_Nom;