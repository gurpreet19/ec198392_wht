CREATE OR REPLACE PACKAGE EcDp_PlannedWell IS

/****************************************************************
** Package        :  EcDp_PlannedWell, header part
**
** $Revision: 1.0 $
**
** Purpose        :  perform operation for planned well.
**
** Documentation  :  www.energy-components.com
**
** Created  : 10.09.2018  Harikrushna Solia
**
** Modification history:
**
** Version  Date       Whom      Change description:
** -------  --------   --------  --------------------------------------
** 1.0      10.09.2018 solibhar  ECPD-58838: Initial version
*****************************************************************/


PROCEDURE insertWellStatus(
    p_object_id VARCHAR2,
    p_daytime DATE,
    p_user VARCHAR2);

PROCEDURE deleteWellStatus(
    p_object_id VARCHAR2,
    p_daytime DATE);

PROCEDURE changeStatusForPlannedWell(
    p_object_id VARCHAR2,
    p_old_well_status VARCHAR2,
    p_new_well_status VARCHAR2,
    p_action VARCHAR2);

END EcDp_PlannedWell;