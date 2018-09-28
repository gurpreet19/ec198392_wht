/****************************************************************
** SQL    :   CVX_LOAD_META_DATA
**
** Revision:  Version 11.2
**
** Purpose  : Template Upgrade to EC.11.2
**
** Created  : 29-Jan-2018  Gayatri Kulkarni
**
** Modification history:
**
** Version  Date        Whom      		Change description:
** -------  ------      -----     		-----------------------------------
** 11.2     29-Jan-2018  Gayatri  		Passing the parameters as 11.2 for execution of UE_CT_INSTALL_HISTORY
*****************************************************************/

exec UE_CT_INSTALL_HISTORY.entry('11.2 CVX Meta Data Template',to_date('9-FEB-2018', 'DD-MON-YYYY'),'11.2 MetaData Template','Central Support')

-- Turn off parsing of "&" character for input parameters
set define off


--Call script generated from CVX_Class_delta_manager
@.\_Release\config\cvx_tmpl_instl_metadata.sql;

COMMIT;



--EXECUTE ecdp_genclasscode.buildviewlayer;

set define on