/****************************************************************
** SQL    :   CVX_LOAD_VIEWS
**
** Revision:  Version 11.2
**
** Purpose  : Template Upgrade to EC.11.2
**
** Created  : 29-Jan-2018  Gayatri Kulkarni
**
** Modification history:
**
** Version  Date         Whom      		Change description:
** -------  ------       -----     		-----------------------------------
** 11.2     29-Jan-2018  Gayatri  		Passing the parameters as 11.2 for execution of UE_CT_INSTALL_HISTORY
*****************************************************************/

-----------------------------------------------------------------------------
/************************************************************
   This script will create Reporting Views.
************************************************************/
-----------------------------------------------------------------------------

exec UE_CT_INSTALL_HISTORY.entry('11.2 CVX VIEWS',to_date('9-FEB-2018', 'DD-MON-YYYY'), 'CVX Template Views', 'Central Support');

SET DEFINE OFF;

----------------------------------------------------------------------------

/************************************************************
   Create or Replace Oracle  Views 
************************************************************/


-- Install the following CVX Custom Oracle Views
----------------------------------------------------------------------------

PROMPT Load CVX Custom Oracle Views


@.\_Release\Views\CV_BASE_BUSINESS_DEFER.sql;
@.\_Release\Views\CV_EQPM_OFF_CHILD_DAY.sql;
@.\_Release\Views\CV_EQPM_OFF_DAY.sql;
@.\_Release\Views\CV_EQPM_OFF_EVENT_DAY.sql;
@.\_Release\Views\CV_IWEL_CURRENT_STATUS.sql;
@.\_Release\Views\CV_IWEL_DAY_ALLOC_RBF.sql;
@.\_Release\Views\CV_IWEL_DAY_STATUS_RBF.sql;
@.\_Release\Views\CV_IWEL_MTH_ALLOC_RBF.sql;
@.\_Release\Views\CV_LPO_OFF_CHILD_DAY.sql;
@.\_Release\Views\CV_LPO_DAY.sql;
@.\_Release\Views\CV_LPO_OFF_EVENT_DAY.sql;
@.\_Release\Views\CV_PTST_PWEL_RESULT.sql;
@.\_Release\Views\CV_PTST_PWEL_RESULT_RBF.sql;
@.\_Release\Views\CV_PTST_PWEL_TDEV_RESULT.sql;
@.\_Release\Views\CV_PTST_PWEL_TDEV_RESULT_RBF.sql;
@.\_Release\Views\CV_PWEL_CURRENT_STATUS.sql;
@.\_Release\Views\CV_PWEL_DAY_ALLOC_RBF.sql;
@.\_Release\Views\CV_PWEL_DAY_STATUS_RBF.sql;
@.\_Release\Views\CV_PWEL_MTH_ALLOC_RBF.sql;
@.\_Release\Views\CV_STAT_PROCESS_STATUS.sql;
@.\_Release\Views\CV_STRM_DAY_STREAM.sql;
@.\_Release\Views\CV_TANK_DAY_ALL.sql;
@.\_Release\Views\CV_IWEL_MTH_ALLOC.sql;
@.\_Release\Views\CV_PWEL_MTH_ALLOC.sql;
@.\_Release\Views\CV_CURRENT_SPLITS.sql;
@.\_Release\Views\CV_AUDIT_LOGIN.SQL;
@.\_Release\Views\CV_PWEL_EVENT.SQL;
@.\_Release\Views\CT_OBJECT_CLASSES.sql;
SET DEFINE ON;

@.\_Release\Utilities\Invalid.sql;




