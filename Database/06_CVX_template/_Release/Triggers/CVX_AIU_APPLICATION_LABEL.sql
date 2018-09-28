CREATE OR REPLACE TRIGGER CVX_AIU_APPLICATION_LABEL 
/******************************************************************************
** Trigger        :  CVX_AIU_APPLICATION_LABEL 
**
** $Revision: 1.0 $
**
** Purpose        :  Create a template trigger to look at CTRL_DB_VERSION and update the attribute in CTRL_PROPERTY to always display EC version and SP the app is on, on the top bar of the application.
**
** Created        :  23-OCT-2012/Dhanshri Mutke
**
** Modification history:
**
** Date            Whom      Change description:
** ------          -----     -----------------------------------------------------------------------------------------------
**23-Oct-2012      DQGM     Initial Version.
********************************************************************************************************************************/
AFTER INSERT OR UPDATE OF description 
on CTRL_DB_VERSION
begin
	UPDATE ctrl_property  SET VALUE_STRING = (SELECT DESCRIPTION FROM CTRL_DB_VERSION) WHERE KEY = '/com/ec/pf/mainframe/applicationLabel';
END;
/