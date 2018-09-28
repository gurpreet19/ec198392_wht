CREATE OR REPLACE PACKAGE BODY UE_CT_FORECAST IS
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
** 28-March-2005 Mark Berkstresser - Changed function to be generic for ** all types of plans by using substitution for DV_ name.
** July 2008   MWB   Converted to 9.3
** ------     ----- --------------------------------------
*****************************************************************/


FUNCTION calcCumMonthToDate (
   p_object_id        VARCHAR2,
   p_class_name		  VARCHAR2,
   p_attribute		  VARCHAR2,
   p_daytime          DATE)

RETURN NUMBER IS

c_calculate sys_refcursor;
ln_return_val NUMBER;
lv2_sql VARCHAR2(256);
BEGIN

   lv2_sql := 'SELECT SUM(' || p_attribute || ') FROM DV_' || p_class_name || ' WHERE object_id = ''' || p_object_id || ''' AND daytime BETWEEN to_date(''' || to_char(p_daytime,'MM/YYYY') || ''',''MM/YYYY'') AND to_date(''' || to_char(p_daytime,'DD/MM/YYYY') || ''',''DD/MM/YYYY'') and class_name = ''' || p_class_name || '''' ;

   OPEN c_calculate FOR lv2_sql;

   FETCH c_calculate INTO ln_return_val ;

   RETURN ln_return_val;

END calcCumMonthToDate;

FUNCTION calcCumYearToDate (
   p_object_id        VARCHAR2,
   p_class_name		  VARCHAR2,
   p_attribute		  VARCHAR2,
   p_daytime          DATE)

RETURN NUMBER IS

c_calculate sys_refcursor;
ln_return_val NUMBER;
lv2_sql VARCHAR2(256);
BEGIN

   lv2_sql := 'SELECT SUM(' || p_attribute || ') FROM DV_' || p_class_name || ' WHERE object_id = ''' || p_object_id || ''' AND daytime BETWEEN to_date(''' || to_char(TRUNC(p_daytime,'YYYY'),'MM/YYYY') || ''',''MM/YYYY'') AND to_date(''' || to_char(p_daytime,'DD/MM/YYYY') || ''',''DD/MM/YYYY'') and class_name = ''' || p_class_name || '''' ;

   OPEN c_calculate FOR lv2_sql;

   FETCH c_calculate INTO ln_return_val ;

   RETURN ln_return_val;

END calcCumYearToDate;

END UE_CT_FORECAST;
/