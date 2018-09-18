CREATE OR REPLACE PACKAGE EcDp_WELL_PLT IS
/****************************************************************
** Package      :  EcDp_WELL_PLT, header part
**
** $Revision: 1.1 $
**
** Purpose      :
**
**
** Documentation:  www.energy-components.com
**
** Created      : 27.11.2013  wonggkai
**
** Modification history:
**
** Version      Date        whom    Change description:
** -------      ----------- ------------------------------------
**  1.0         27-11-2013  wonggkai ECPD-22045: Initial Version
*****************************************************************/

PROCEDURE deleteWellPltResult(p_object_id VARCHAR2, p_daytime date, p_run_no VARCHAR2);

END;