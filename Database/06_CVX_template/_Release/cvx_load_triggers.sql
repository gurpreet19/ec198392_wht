/****************************************************************
** SQL    :   CVX_LOAD_TRIGGERS
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

-----------------------------------------------------------------------------
/************************************************************
   This script will create Triggers.
************************************************************/
-----------------------------------------------------------------------------

exec UE_CT_INSTALL_HISTORY.entry('11.2 CVX TRIGGERS',to_date('9-FEB-2018', 'DD-MON-YYYY'), 'CVX Template Triggers', 'Central Support');

SET DEFINE OFF;

----------------------------------------------------------------------------

/************************************************************
   Create or Replace Oracle Triggers 
************************************************************/


-- Install the following CVX Custom Oracle Triggers
----------------------------------------------------------------------------

PROMPT Load CVX Custom Oracle Triggers


@.\_Release\Triggers\CVX_AIU_APPLICATION_LABEL.sql;

SET DEFINE ON;

@.\_Release\Utilities\Invalid.sql;




