CREATE OR REPLACE PACKAGE BODY Ue_Report_Parameter IS

/****************************************************************
** Package        :  Ue_Report_Parameter, body part
*******************************************************************/
FUNCTION GetPresentationSyntax
(parameter_sub_type VARCHAR2, popup_dependency VARCHAR2 DEFAULT NULL, navigator_value VARCHAR2 DEFAULT NULL)

RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
RETURN NULL;
END GetPresentationSyntax;

FUNCTION Name
(parameter_sub_type   VARCHAR2, parameter_value   VARCHAR2)

RETURN VARCHAR2
IS
BEGIN
RETURN NULL;
END Name;
END Ue_Report_Parameter;
