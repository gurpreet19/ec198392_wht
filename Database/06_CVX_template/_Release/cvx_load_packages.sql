/****************************************************************
** SQL    :   CVX_LOAD_PACKAGES
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

exec UE_CT_INSTALL_HISTORY.entry('11.2 CVX Packages Template',to_date('9-FEB-2018', 'DD-MON-YYYY'),'11.2 Packages Template','Central Support');

set define off


---------------------------------------------
PROMPT INSTALLING PACKAGES ...
---------------------------------------------
START .\_Release\Packages\UE_CT_API_CALC.pks;
START .\_Release\Packages\UE_CT_API_CALC.pkb;
START .\_Release\Packages\UE_CT_AUTHENICATE.pks;
START .\_Release\Packages\UE_CT_AUTHENICATE.pkb;
START .\_Release\Packages\UE_CT_ECDP_WELL.pck;
START .\_Release\Packages\Z_PASSWORDVALIDATION.pks;
START .\_Release\Packages\Z_PASSWORDVALIDATION.pkb;
START .\_Release\Packages\UE_CT_FORECAST.pks;
START .\_Release\Packages\UE_CT_FORECAST.pkb;
START .\_Release\Packages\UE_CT_GENERATE.pks;
START .\_Release\Packages\UE_CT_GENERATE.pkb;
START .\_Release\Packages\UE_CT_WELL_RESERVOIR.pks;
START .\_Release\Packages\UE_CT_WELL_RESERVOIR.pkb;
START .\_Release\Packages\UE_PVT_CALCULATION.pks;
START .\_Release\Packages\UE_PVT_CALCULATION.pkb;
START .\_Release\Packages\UE_CT_WELL_TEST_SRV.pks;
START .\_Release\Packages\UE_CT_WELL_TEST_SRV.pkb;
START .\_Release\Packages\UE_CT_WELL_DEFERMENT.pks;
START .\_Release\Packages\UE_CT_WELL_DEFERMENT.pkb;
--START .\_Release\Packages\UE_CT_RP_PACKAGE_GENERATE.pks;
--START .\_Release\Packages\UE_CT_RP_PACKAGE_GENERATE.pkb;

set define on
