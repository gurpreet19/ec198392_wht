CREATE OR REPLACE PACKAGE EcDp_Production_Lock IS
/****************************************************************
** Package        :  EcDp_Production_Lock, head part
**
** $Revision: 1.10 $
**
** Purpose        :  General Locking procedures dependent on production classes
**
** Documentation  :  www.energy-components.com
**
** Created  : 22.12.2005 Arild Vervik
**
** Modification history:
**
** Date     	  Whom  	 Change description:
** ------   	  ----- 	 ---------------------------------------------------------------------
** 31.05.2007   Rajarsar Added Procedure CheckObjConnDataLock
** 29.10.2007   Zakiiari ECPD-3905: Removed checkPlanLock
** 20.05.2009   oonnnng  ECPD-11852: Add new CheckDirectLock() procedure with different arguments pass in.
*************************************************************************************************/
--

PROCEDURE CheckDirectLock(p_operation VARCHAR2, l_new IN OUT EcDp_month_lock.column_list, l_old IN OUT EcDp_month_lock.column_list);
PROCEDURE CheckDirectLock(p_class_name VARCHAR2, p_table_name VARCHAR2, p_object_id VARCHAR2, p_measurement_event_type VARCHAR2, p_daytime DATE, p_prod_day DATE);

PROCEDURE checkAnySimpleEventLock(p_operation VARCHAR2, p_new_lock_columns IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns IN OUT EcDp_Month_Lock.column_list);

PROCEDURE validateProdDayPeriodForLock(p_operation VARCHAR2,
                                       p_from_daytime DATE,
                                       p_to_daytime DATE,
                                       p_object_id VARCHAR2,
                                       p_object_class_name VARCHAR2,
                                       p_context VARCHAR2);

PROCEDURE CheckAnySimpleProdDayLock(p_operation VARCHAR2, p_new_lock_columns IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns IN OUT EcDp_Month_Lock.column_list);

PROCEDURE CheckProdForecastDataLock(p_operation VARCHAR2, p_new_lock_columns IN OUT EcDp_month_lock.column_list, p_old_lock_columns IN OUT EcDp_month_lock.column_list);

PROCEDURE CheckObjConnDataLock(p_operation VARCHAR2, p_new_lock_columns IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns IN OUT EcDp_Month_Lock.column_list);

PROCEDURE checkConstantStdLock(p_operation VARCHAR2, p_new_lock_columns  IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns IN OUT EcDp_Month_Lock.column_list);

END EcDp_Production_Lock;