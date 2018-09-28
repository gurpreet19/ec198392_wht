/****************************************************************
** SQL    :   CVX_LOAD_CALCULATION
**
** Revision:  Version 11.2
**
** Purpose  : Template Upgrade to EC.11.2
**
** Created  : 31-Jan-2018  Gayatri Kulkarni
**
** Modification history:
**
** Version  Date         Whom      		Change description:
** -------  ------       -----     		-----------------------------------
** 11.2     31-Jan-2018  Gayatri  		Passing the parameters as 11.2 for execution of UE_CT_INSTALL_HISTORY
*****************************************************************/

exec UE_CT_INSTALL_HISTORY.entry('11.2 CVX Calculations',to_date('9-FEB-2018', 'DD-MON-YYYY'),'Calculations','Central Support')


set define off

-- load calc rules
--START .\_Release\Config\cvx_tmpl_instl_calc_object.sql
START .\_Release\Calculation\LIB_CALC_WELL_HR.sql
START .\_Release\Calculation\CT_MONTHLY_VOLUME.sql
START .\_Release\Calculation\CT_DAILY_MASS.sql
START .\_Release\Calculation\CT_DAILY_VOLUME_GL.sql
START .\_Release\Calculation\CT_MONTHLY_VOLUME_GL.sql
START .\_Release\Calculation\DV_CALC_OBJECT_ATTRIBUTE.sql


COMMIT;

set define on
