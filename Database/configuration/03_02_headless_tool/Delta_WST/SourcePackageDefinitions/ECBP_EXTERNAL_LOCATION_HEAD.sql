CREATE OR REPLACE PACKAGE EcBp_External_Location IS
/****************************************************************
** Package        :  EcBp_External_Location
**
** $Revision: 1.3 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to external location.
**
** Documentation  :  www.energy-components.com
**
** Created  : 10.07.2012  Mawaddah Abdul Latif
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 10.07.2012 abdulmaw ECPD-21450: Added checkExtLocReferenceValueLock()
** 16.07.2012 limmmchu ECPD-21448: Added checkIfPeriodOverlaps()
** 10.08.2012 limmmchu ECPD-21449: Modified checkIfPeriodOverlaps() to include fcty_object_id
*****************************************************************/

-- Lock check procedures
PROCEDURE checkExtLocReferenceValueLock(p_operation VARCHAR2, p_new_lock_columns IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns IN OUT EcDp_Month_Lock.column_list);
PROCEDURE checkIfPeriodOverlaps(p_object_id VARCHAR2,p_parent_start_date DATE, p_end_date DATE, p_fcty_object_id VARCHAR2);

END EcBp_External_Location;