CREATE OR REPLACE PACKAGE EcDp_Client_Presentation IS
/****************************************************************
** Package        :  EcDp_Client_Presentation
**
** $Revision: 1.9 $
**
** Purpose        :  Functions used to Deal with presentation
**
** Documentation  :
**
** Created        :  16.11.2005  Micah Rupersburg
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
** 18-11-2005	rupermic	Added GetDuration
** 22-11-2005 	mot     Added popup dependency parameter to GetPresentationSyntax
** 06-12-2005   mot     Added GetNameByType
** 12-07-07	siah	Added getComponentFullNameLabel
** 28-10-2014	shindani	ECPD-18092: Added function getComponentExtName.
******************************************************************/


FUNCTION GetName(parameter_type VARCHAR2, parameter_sub_type VARCHAR2, parameter_value   VARCHAR2) RETURN VARCHAR2;
--

FUNCTION GetNameByType(parameter_type VARCHAR2, parameter_sub_type VARCHAR2) RETURN VARCHAR2;

FUNCTION GetPresentationSyntax(parameter_type VARCHAR2, parameter_sub_type VARCHAR2, popup_dependency VARCHAR2 DEFAULT NULL, navigator_value VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
--

FUNCTION GetDuration(FROM_DATE DATE, TO_DATE DATE) RETURN VARCHAR2;

FUNCTION getComponentFullNameLabel(p_component_id VARCHAR2) RETURN VARCHAR2;

FUNCTION getComponentExtName(p_component_ext_name VARCHAR2) RETURN VARCHAR2;

END EcDp_Client_Presentation;

