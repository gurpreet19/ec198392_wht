CREATE OR REPLACE PACKAGE Ue_Report_Parameter IS
/****************************************************************
** Package        :  Ue_Report_ParamType, header part
*****************************************************************/

FUNCTION GetPresentationSyntax
(parameter_sub_type VARCHAR2, popup_dependency VARCHAR2 DEFAULT NULL, navigator_value VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (GetPresentationSyntax, WNDS, WNPS, RNPS);

FUNCTION Name
(parameter_sub_type   VARCHAR2, parameter_value   VARCHAR2)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (GetPresentationSyntax, WNDS, WNPS, RNPS);

END Ue_Report_Parameter;
