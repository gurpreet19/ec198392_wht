CREATE OR REPLACE PACKAGE EcBp_Well_Status IS
/****************************************************************
** Package        :  EcBp_Well_Status, header part
**
** $Revision: 1.1 $
**
** Purpose        :  Provides business functions related to well status.
**
** Documentation  :  www.energy-components.com
**
** Created  : 02.01.2006  Dagfinn Nj?
**
** Modification history:
**
** Date     	Whom  		Change description:
** ------   	----- 		--------------------------------------
** 23.08.2016   dhavaalo 	ECPD-38127-38126- getVolumeUOM and getVolumeUOM function added.
*****************************************************************/

--

PROCEDURE checkWellStatusLock(p_operation VARCHAR2, p_new_lock_columns IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns IN OUT EcDp_Month_Lock.column_list);

FUNCTION getVolumeUOM (
   p_inj_type VARCHAR2)
RETURN VARCHAR2;

FUNCTION getConvertVolume  (
   p_inj_vol  NUMBER,
   p_inj_type VARCHAR2)
RETURN NUMBER;

END EcBp_Well_Status;