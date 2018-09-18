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
******************************************************************/


FUNCTION GetName(parameter_type VARCHAR2, parameter_sub_type VARCHAR2, parameter_value   VARCHAR2) RETURN VARCHAR2;
--PRAGMA RESTRICT_REFERENCES (GetName ,RNPS, WNPS,WNDS);

FUNCTION GetNameByType(parameter_type VARCHAR2, parameter_sub_type VARCHAR2) RETURN VARCHAR2;

FUNCTION GetPresentationSyntax(parameter_type VARCHAR2, parameter_sub_type VARCHAR2, popup_dependency VARCHAR2 DEFAULT NULL, navigator_value VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
--PRAGMA RESTRICT_REFERENCES (GetPresentationSyntax ,RNPS, WNPS,WNDS);

FUNCTION GetDuration(FROM_DATE DATE, TO_DATE DATE) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (GetDuration ,RNPS, WNPS,WNDS);

FUNCTION pad0(num NUMBER) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (pad0 ,RNPS, WNPS,WNDS);

FUNCTION getComponentFullNameLabel(p_component_ext_name VARCHAR2) RETURN VARCHAR2;

END EcDp_Client_Presentation;

