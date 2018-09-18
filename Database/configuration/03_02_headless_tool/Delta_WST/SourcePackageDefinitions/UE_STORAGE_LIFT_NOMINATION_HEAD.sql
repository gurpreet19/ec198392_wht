CREATE OR REPLACE PACKAGE ue_Storage_Lift_Nomination IS

/******************************************************************************
** Package        :  ue_Storage_Lift_Nomination, header part
**
** $Revision: 1.9 $
**
** Purpose        :  Includes user-exit functionality for terminal operation screens
**
** Documentation  :  www.energy-components.com
**
** Created  : 11.04.2006 Kari Sandvik
**
** Modification history:
**
** Date        Whom     Change description:
** -------     ------   -----------------------------------------------
** 18.10.2006  rajarsar  Tracker 4635 - Added deleteNomination Procedure
** 12.09.2012  meisihil  ECPD-20962: Added function setBalanceDelta
** 24.01.2013  meisihil  ECPD-20962: Added functions aggrSubDayLifting, calcSubDayLifting to support liftings spread over hours
** 30.03.2015  asareswi  ECPD-19757: Added procedure CreateUpdateSplit
** 30.03.2015  asareswi  ECPD-19757: Added function CalcSplitQty
** 15.10.2015  farhaann  ECPD-32358: Added function getCalendarDetail and getCalendarTooltip
** 17.02.2016  asareswi	 ECPD-33012: Added function getSubDaySplitQty, calcAggrSubDaySplitQty
** 03.03.2017  thotesan	 ECPD-43320: Added function getChartDetailCode, getChartTooltip for Schedule lifting overview
** 05.02.2018  royyypur  ECPD-53946: Added getTextColor to configure the custom color for any day
** -------     ------   ----------------------------------------------------------------------------------------------------
*/

FUNCTION expectedUnloadDate(p_parcel_no NUMBER) RETURN DATE;

PROCEDURE deleteNomination(p_storage_id VARCHAR2,p_from_date DATE,p_to_date DATE);

PROCEDURE validateSplit(p_parcel_no NUMBER);

PROCEDURE getDefaultSplit(p_parcel_no NUMBER);

PROCEDURE setBalanceDelta(p_parcel_no NUMBER);

FUNCTION aggrSubDayLifting(p_parcel_no NUMBER, p_daytime DATE, p_column VARCHAR2 DEFAULT NULL, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;

PROCEDURE calcSubDayLifting(p_parcel_no NUMBER);

PROCEDURE CreateUpdateSplit( p_Parcel_No NUMBER, p_old_lifting_account_id VARCHAR2, p_new_lifting_account_id VARCHAR2);

FUNCTION CalcSplitQty(p_parcel_no NUMBER, p_company_id VARCHAR2, p_lifting_account_id VARCHAR2, p_daytime DATE, p_qty NUMBER) RETURN NUMBER;

FUNCTION getCalendarDetail(p_daytime DATE,p_berth_id VARCHAR2) RETURN VARCHAR2;

FUNCTION getCalendarTooltip(p_daytime DATE,p_berth_id VARCHAR2) RETURN VARCHAR2;

FUNCTION getSubDaySplitQty(p_parcel_no          NUMBER,
                           p_company_id         VARCHAR2,
                           p_lifting_account_id VARCHAR2,
                           p_daytime            DATE,
						   p_qty                NUMBER,
						   p_column             VARCHAR2 DEFAULT NULL)
    RETURN NUMBER;

FUNCTION calcAggrSubDaySplitQty(p_parcel_no     NUMBER,
                           p_company_id         VARCHAR2,
                           p_lifting_account_id VARCHAR2,
                           p_daytime            DATE,
						   p_column             VARCHAR2 DEFAULT NULL,
                           p_xtra_qty           NUMBER DEFAULT 0)
    RETURN NUMBER;

FUNCTION getChartDetailCode(p_daytime DATE,
                            p_berth_id VARCHAR2,
                            p_storage_id VARCHAR2,
                            p_type VARCHAR2 DEFAULT 'DAY') RETURN VARCHAR2;

FUNCTION getChartTooltip(p_daytime DATE,
                         p_berth_id VARCHAR2,
                         p_storage_id VARCHAR2,
                         p_detail_code VARCHAR2,
                         p_type VARCHAR2 DEFAULT 'DAY') RETURN VARCHAR2;


PROCEDURE validateSplitEntry(p_company_id VARCHAR2, p_parcel_no NUMBER,p_lifting_account_id VARCHAR2);


FUNCTION getTextColor(p_daytime DATE,p_berth_id VARCHAR2) RETURN VARCHAR2;
END ue_Storage_Lift_Nomination;