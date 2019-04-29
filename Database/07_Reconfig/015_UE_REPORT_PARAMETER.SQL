CREATE OR REPLACE PACKAGE Ue_Report_Parameter IS
/****************************************************************
** Package        :  Ue_Report_ParamType, header part
*****************************************************************/

FUNCTION GetPresentationSyntax
(parameter_sub_type VARCHAR2, popup_dependency VARCHAR2 DEFAULT NULL, navigator_value VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;

FUNCTION Name
(parameter_sub_type   VARCHAR2, parameter_value   VARCHAR2)
RETURN VARCHAR2;

END Ue_Report_Parameter;

/


CREATE OR REPLACE PACKAGE BODY Ue_Report_Parameter IS

/****************************************************************
** Package        :  Ue_Report_Parameter, body part
**
** Modified By    Date           Reason
** -----------    -----------    -----------------------------------
** SWGN           24-OCT-2014    Updates for the Scheduled Message Action	 
*******************************************************************/
FUNCTION GetPresentationSyntax
(parameter_sub_type VARCHAR2, popup_dependency VARCHAR2 DEFAULT NULL, navigator_value VARCHAR2 DEFAULT NULL)

RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
    IF parameter_sub_type = 'MESSAGE_DISTRIBUTION_NO' THEN
        IF(popup_dependency IS NOT NULL) THEN
           RETURN 'viewwidth=150;PopupURL=/FrontController/com.ec.cvx.common.screens/message_distribution_popup;' ||
          'PopupReturnColumn=TO_PARAM_POPUP;PopupDependency=Screen.this.currentRow.' || popup_dependency ||
          '=ReturnField.MESSAGE_DISTRIBUTION_NO;PopupWidth=450;PopupHeight=400';
         ELSE
             RETURN '';
         END IF;
    END IF; 
END GetPresentationSyntax;

FUNCTION Name
(parameter_sub_type   VARCHAR2, parameter_value   VARCHAR2)

RETURN VARCHAR2
IS
BEGIN
    IF parameter_sub_type = 'MESSAGE_DISTRIBUTION_NO' THEN
        RETURN ECBP_MESSAGING.GetParamSetValueName(parameter_value);
    END IF;
END Name;


END Ue_Report_Parameter;

/
