CREATE OR REPLACE PACKAGE EcBp_Fluid_Analysis IS
/****************************************************************
** Package        :  EcBp_Fluid_Analysis
**
** $Revision: 1.10 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to fluid analysis.
**
** Documentation  :  www.energy-components.com
**
** Created  : 23.12.2005  Dagfinn Nj�
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 10.04.2009 leongsei ECPD-6067: Added checkStrmComponentLock() function.
** 30.10.2009 rajarsar ECPD-12630: Added getCompSet function.
** 11.03.2010 madondin ECPD-13308: Added getPeriodCompSet function.
** 06.05.2010 oonnnng  ECPD-14276: Added checkEqpmReferenceValueLock() and checkWellReferenceValueLock() functions.
** 09.11.2010 rajarsar ECPD-15008: Added checkChokeModelRefValueLock()
** 19.06.2012 limmmchu ECPD-21070: Modified getPeriodCompSet()
*****************************************************************/

-- Lock check procedures
PROCEDURE checkAnalysisLock(p_operation VARCHAR2, p_new_lock_columns IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns IN OUT EcDp_Month_Lock.column_list);
PROCEDURE checkAGAAnalysisLock(p_operation VARCHAR2, p_new_lock_columns IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns IN OUT EcDp_Month_Lock.column_list);
PROCEDURE CheckFluidComponentLock(p_operation VARCHAR2, p_new_lock_columns EcDp_Month_lock.column_list, p_old_lock_columns EcDp_Month_lock.column_list);
PROCEDURE checkStrmReferenceValueLock(p_operation VARCHAR2, p_new_lock_columns IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns IN OUT EcDp_Month_Lock.column_list);
PROCEDURE checkEqpmReferenceValueLock(p_operation VARCHAR2, p_new_lock_columns  IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns  IN OUT EcDp_Month_Lock.column_list);
PROCEDURE checkWellReferenceValueLock(p_operation VARCHAR2, p_new_lock_columns  IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns  IN OUT EcDp_Month_Lock.column_list);
PROCEDURE checkStrmWaterAnalysisLock(p_operation VARCHAR2, p_new_lock_columns IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns IN OUT EcDp_Month_Lock.column_list);
PROCEDURE CheckFluidProductLock(p_operation VARCHAR2, p_new_lock_columns EcDp_Month_lock.column_list, p_old_lock_columns EcDp_Month_lock.column_list);
PROCEDURE checkStrmComponentLock(p_operation VARCHAR2, p_new_lock_columns EcDp_Month_lock.column_list, p_old_lock_columns EcDp_Month_lock.column_list);
FUNCTION getCompSet(p_class_name VARCHAR2, p_object_id  VARCHAR2, p_daytime  DATE, p_analysis_type  VARCHAR2) RETURN VARCHAR2;
FUNCTION getPeriodCompSet(p_object_id  VARCHAR2, p_daytime  DATE, p_analysis_type  VARCHAR2) RETURN VARCHAR2;
PROCEDURE checkChokeModelRefValueLock(p_operation VARCHAR2, p_new_lock_columns  IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns  IN OUT EcDp_Month_Lock.column_list);


END EcBp_Fluid_Analysis;