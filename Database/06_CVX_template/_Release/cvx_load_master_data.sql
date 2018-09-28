/****************************************************************
** SQL    :   CVX_LOAD_MASTER_DATA
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

exec UE_CT_INSTALL_HISTORY.entry('11.2 CVX Master Data Template',to_date('9-Feb-2018', 'DD-MON-YYYY'),'11.2 MasterData Template','Central Support')

-- Turn off parsing of "&" character for input parameters
set define off

PROMPT LOADING FRAMEWORK CONFIG...
exec UE_CT_INSTALL_HISTORY.entry('11.2 CVX Framework Template',to_date('9-Feb-2018', 'DD-MON-YYYY'),'Framework Template','Central Support')
START .\_Release\config\cvx_tmpl_instl_framework.sql;

PROMPT LOADING TREEVIEW...
exec UE_CT_INSTALL_HISTORY.entry('11.2 CVX Treeview Template',to_date('9-Feb-2018', 'DD-MON-YYYY'),'11.2 CVX Treeview Template','Central Support')

START .\_Release\config\cvx_tmpl_instl_treeview.sql;

PROMPT LOADING USER, ROLES, ACCESS...
exec UE_CT_INSTALL_HISTORY.entry('11.2 CVX Security Template',to_date('9-Feb-2018', 'DD-MON-YYYY'),'11.2 CVX Security Template','Central Support')
START .\_Release\Security\cvx_tmpl_instl_security.sql;

PROMPT LOADING MISC CONFIG...
exec UE_CT_INSTALL_HISTORY.entry('11.2 CVX Misc Template',to_date('9-Feb-2018', 'DD-MON-YYYY'),'Miscellaneous Template','Central Support')
--Run miscellaneous configurations (i.e. Base Business Product Lists)
START .\_Release\config\cvx_tmpl_instl_misc.sql;

PROMPT LOADING Calc Objects Configuration...
exec UE_CT_INSTALL_HISTORY.entry('11.2 CVX Misc Template',to_date('9-Feb-2018', 'DD-MON-YYYY'),'Calc Objects Template','Central Support')
START .\_Release\config\cvx_tmpl_instl_calc_object.sql

COMMIT;

set define on
