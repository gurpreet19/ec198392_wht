CREATE OR REPLACE PACKAGE UE_CT_FORECAST IS
/****************************************************************
** Package        :  UE_CT_FORECAST
**
** $Revision: 1.0 $
**
** Purpose        :  This package allows calculatate plan month / year to date
**
** Documentation  :  www.energy-components.com
**
** Created  : 10.10.2004  Stephen Webster
**
** Modification history:
**
** Date       Whom  Change description:
** ------     ----- --------------------------------------
** July 2008  MWB   Upgraded to 9.3
*****************************************************************/

FUNCTION calcCumMonthToDate (
   p_object_id        VARCHAR2,
   p_class_name		  VARCHAR2,
   p_attribute		  VARCHAR2,
   p_daytime          DATE)

RETURN NUMBER;

FUNCTION calcCumYearToDate (
   p_object_id        VARCHAR2,
   p_class_name		  VARCHAR2,
   p_attribute		  VARCHAR2,
   p_daytime          DATE)

RETURN NUMBER;


END UE_CT_FORECAST;
/