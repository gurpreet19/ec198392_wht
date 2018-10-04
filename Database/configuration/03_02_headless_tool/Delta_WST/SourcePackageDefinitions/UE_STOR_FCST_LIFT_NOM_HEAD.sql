CREATE OR REPLACE PACKAGE ue_Stor_Fcst_Lift_Nom IS

/******************************************************************************
** Package        :  ue_Stor_Fcst_Lift_Nom, header part
**
** $Revision: 1.3 $
**
** Purpose        :  Includes user-exit functionality for terminal operation screens
**
** Documentation  :  www.energy-components.com
**
** Created  : 05.06.2008 Kari Sandvik
**
** Modification history:
**
** Date        	Whom     	Change description:
** -------     	------   	-----------------------------------------------
** 24.01.2013  	meisihil	ECPD-20962: Added functions aggrSubDayLifting, calcSubDayLifting to support liftings spread over hours
** 15.10.2015	muhammah	ECPD-32356: Merged ECPD-31725. Added function getCalendarDetail, getCalendarTooltip
** 15.01.2016	asareswi	ECPD-33109: Added function getCalendarTooltipFcstMngr to get the detail tooltip based on berth id and lifting a/c id.
** 04.02.2016   sharawan    ECPD-33109: Added new function getChartTooltip for Cargo Berth Chart tooltip
** 01.03.2016   farhaann    ECPD-33934: Added new procedure undoCargo
** 04.03.2016   sharawan    ECPD-33109: Added new function getChartDetailCode for Cargo Berth Chart
** 14.03.2016   sharawan    ECPD-34277: Fix tooltip for Berth gantt chart
** 21.04.2016   farhaann    ECPD-34750: Modified procedure undoCargo - added parameter for forecast
** 21.04.2016   farhaann    ECPD-34750: Added new function getVerificationText
** 25.04.2016   thotesan    ECPD-34226: Modified getChartDetailCode,getChartTooltip to remove parameter to handle daily and subdaily
** 28.04.2016   thotesan    ECPD-34226: Modified getChartTooltip for parameter to handle daily and subdaily
** 08.03.2017   farhaann    ECPD-40982: Added getDefaultSplit, validateSplit and calcSplitQty
** 15.03.2017   farhaann    ECPD-40982: Added createUpdateSplit
** 27.03.2017   farhaaan    ECPD-44120: Added function getSubDaySplitQty and calcAggrSubDaySplitQty
** 20.10.2017   sharawan    ECPD-49488: Added function getCarrierDetailCode, getCarrierTooltip, getCarrierUtilisation for the Carrier Utilization Chart in Forecast Manager.
** 31.10.2017   xxwaghmp    ECPD-49488: Modified function getCarrierDetailCode, getCarrierTooltip to add port_id in where clause
** 09.04.2018   royyypur    ECPD-53946: Added getTextColor to configure the custom color for any date
** -------      ------      ----------------------------------------------------------------------------------------------------
*/

PROCEDURE deleteNomination(p_storage_id VARCHAR2,p_forecast_id VARCHAR2,p_from_date DATE,p_to_date DATE);

PROCEDURE setBalanceDelta(p_forecast_id VARCHAR2, p_parcel_no NUMBER);

FUNCTION aggrSubDayLifting(p_forecast_id VARCHAR2, p_parcel_no NUMBER, p_daytime DATE, p_column VARCHAR2 DEFAULT NULL, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;

PROCEDURE calcSubDayLifting(p_forecast_id VARCHAR2, p_parcel_no NUMBER);

FUNCTION getCalendarDetail(p_daytime DATE, p_berth_id VARCHAR2, p_forecast_id VARCHAR2) RETURN VARCHAR2;

FUNCTION getCalendarTooltip(p_daytime DATE, p_berth_id VARCHAR2, p_forecast_id VARCHAR2) RETURN VARCHAR2;

FUNCTION getCalendarTooltipFcstMngr(p_daytime DATE, p_berth_id VARCHAR2, p_forecast_id VARCHAR2, p_lifting_account_id VARCHAR2) RETURN VARCHAR2;

FUNCTION getChartDetailCode(p_daytime DATE,
                            p_berth_id VARCHAR2,
                            p_storage_id VARCHAR2,
                            p_forecast_id VARCHAR2,
                            p_type VARCHAR2 DEFAULT 'DAY') RETURN VARCHAR2;

FUNCTION getChartTooltip(p_daytime DATE,
                         p_berth_id VARCHAR2,
                         p_storage_id VARCHAR2,
                         p_forecast_id VARCHAR2,
                         p_detail_code VARCHAR2,
                         p_type VARCHAR2 DEFAULT 'DAY') RETURN VARCHAR2;

PROCEDURE undoCargo(p_daytime DATE, p_storage_id VARCHAR2, p_forecast_id_1 VARCHAR2 DEFAULT NULL, p_forecast_id_2 VARCHAR2 DEFAULT NULL);

FUNCTION getVerificationText (p_att_name VARCHAR2) RETURN VARCHAR2;

PROCEDURE getDefaultSplit(p_forecast_id VARCHAR2, p_parcel_no NUMBER);

PROCEDURE validateSplit(p_forecast_id VARCHAR2, p_parcel_no NUMBER);

FUNCTION calcSplitQty(p_forecast_id VARCHAR2, p_parcel_no NUMBER, p_company_id VARCHAR2, p_lifting_account_id VARCHAR2, p_daytime DATE, p_qty NUMBER) RETURN NUMBER;

PROCEDURE createUpdateSplit(p_forecast_id VARCHAR2, p_parcel_no NUMBER, p_old_lifting_account_id VARCHAR2, p_new_lifting_account_id VARCHAR2);

FUNCTION getSubDaySplitQty(p_forecast_id VARCHAR2, p_parcel_no NUMBER, p_company_id VARCHAR2, p_lifting_account_id VARCHAR2, p_daytime DATE, p_qty NUMBER, p_column VARCHAR2 DEFAULT NULL) RETURN NUMBER;

FUNCTION calcAggrSubDaySplitQty(p_forecast_id VARCHAR2, p_parcel_no NUMBER, p_company_id VARCHAR2, p_lifting_account_id VARCHAR2, p_daytime DATE, p_column VARCHAR2 DEFAULT NULL, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;

FUNCTION getCarrierUtilisation(p_forecast_id varchar2, p_from_date date, p_to_date date, p_carrier_id varchar2)
    RETURN number;

FUNCTION getCarrierDetailCode(p_carrier_id VARCHAR2,
                            p_forecast_id VARCHAR2,
                            p_product_group VARCHAR2,
							p_daytime DATE) RETURN VARCHAR2;

 FUNCTION getCarrierTooltip(p_daytime DATE,
                         p_carrier_id VARCHAR2,
                         p_product_group VARCHAR2,
                         p_forecast_id VARCHAR2,
                         p_detail_code VARCHAR2) RETURN VARCHAR2;

PROCEDURE validateSplitEntry(p_company_id VARCHAR2, p_parcel_no NUMBER,p_lifting_account_id VARCHAR2,p_forecast_id VARCHAR2);

FUNCTION getTextColor(p_daytime DATE,p_berth_id VARCHAR2, p_forecast_id VARCHAR2) RETURN VARCHAR2;

END ue_Stor_Fcst_Lift_Nom;