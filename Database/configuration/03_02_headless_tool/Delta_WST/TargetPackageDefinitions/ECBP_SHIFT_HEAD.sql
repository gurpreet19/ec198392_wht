CREATE OR REPLACE PACKAGE EcBp_Shift IS
/****************************************************************
** Package        :  EcDp_Shift, header part
**
** $Revision: 1.4.2.1 $
**
** Purpose        :  Retrieve the Shift information and provides general procedures on Shift object
**
** Created  : 14-09-2011  Leong Weng Onn
**
** Modification history:
**
** Date        Whom       Change description:
** ------      -----      -----------------------------------
** 14-09-2011  leongwen   ECPD-18473: Added getWorkingShiftCode()
** 04-01-2012  leongwen   ECPD-19358: Modified the getWorkingShiftCode() function to handle the DST rather than using the fixed values for European
**                        and North American.
** 17-01-2012  leongwen   ECPD-19377: Shift Object enhancements with Cycle.
** 05-04-2012  leongwen   ECPD-20412: Use the Oracle Collection for Shift Object enhancements with Versioning.
*****************************************************************/

TYPE t_object_id                    IS TABLE OF SHIFT_VERSION.OBJECT_ID%TYPE;
TYPE t_code                         IS TABLE OF SHIFT.OBJECT_CODE%TYPE;
TYPE t_daytime                      IS TABLE OF DATE;
TYPE t_start_time                   IS TABLE OF SHIFT_VERSION.START_TIME%TYPE;
TYPE t_duration                     IS TABLE OF NUMBER;
TYPE t_shift_on_duration            IS TABLE OF NUMBER;
TYPE t_shift_off_duration           IS TABLE OF NUMBER;
TYPE t_shift_cycle                  IS TABLE OF NUMBER;

FUNCTION getWorkingShiftCode(p_fcty_obj_id VARCHAR2, p_daytime DATE)
RETURN VARCHAR2;

FUNCTION SwapShift(p_fcty_obj_id VARCHAR2, p_shift_obj_id VARCHAR2, p_daytime DATE, p_cycle NUMBER, p_Shift_StDaytime DATE,
typ_object_id t_object_id, typ_code t_code, typ_duration t_duration)
RETURN VARCHAR2;

FUNCTION getShiftEndExtraTime(p_fcty_obj_id VARCHAR2, p_shift_obj_id VARCHAR2, p_enddate DATE)
RETURN DATE;

END;