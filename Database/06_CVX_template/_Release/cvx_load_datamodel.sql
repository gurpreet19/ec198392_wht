/****************************************************************
** SQL    :   CVX_LOAD_DATAMODEL
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

exec UE_CT_INSTALL_HISTORY.entry('11.2 CVX Data Model Template',to_date('9-FEB-2018', 'DD-MON-YYYY'),'Data Model Template','Central Support')

set define   off

--Run CT Tables (Commented out because of pre Template folder)
--START .\_Release\DataModel\CT_EC_INSTALL_HISTORY.sql;
--START .\_Release\DataModel\CT_EC_INSTALLED_FEATURES.sql;
START .\_Release\DataModel\EQPM_VERSION.sql;
START .\_Release\DataModel\STRM_TRANSPORT_EVENT.sql;
START .\_Release\DataModel\TANK_MEASUREMENT.sql;
--START .\_Release\DataModel\FLWL_VERSION.SQL;
--START .\_Release\DataModel\PIPE_VERSION.SQL;
--START .\_Release\DataModel\SEPA_VERSION.SQL;
--START .\_Release\DataModel\STOR_VERSION.SQL;
--START .\_Release\DataModel\WELL_HOLE_VERSION.SQL;
START .\_Release\DataModel\OBJECT_GROUP.sql;
--START .\_Release\DataModel\PROSTY_CODES.sql;

set define on