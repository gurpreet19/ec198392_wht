CREATE OR REPLACE PACKAGE BODY ue_Dataset_Flow IS
/****************************************************************
** Package        :  ue_Dataset_Flow, body part
**
** Purpose        :  Provide user exit functions for package EcDp_Dataset_Flow
**
** Documentation  :  www.energy-components.com
**
** Created        :  2015-09-03  Georg Hoien
**
************************************************************************************************************************************************************/

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : VerifyReference
-- Description    : This is a INSTEAD OF user-exit addon to the standard EcDp_Dataset_Flow.VerifyReference.
-- Preconditions  : Must be enabled using global variable isVerifyReferenceUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION VerifyReference(
                        p_type                              VARCHAR2,
                        p_reference_id                      VARCHAR2
                        )
RETURN VARCHAR2
IS
BEGIN
    RETURN NULL;
END VerifyReference;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : VerifyReferencePre
-- Description    : This is a PRE user-exit addon to the standard EcDp_Dataset_Flow.VerifyReference.
-- Preconditions  : Must be enabled using global variable isVerifyReferencePreUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION VerifyReferencePre(
                        p_type                              VARCHAR2,
                        p_reference_id                      VARCHAR2
                        )
RETURN VARCHAR2
IS
BEGIN
    RETURN NULL;
END VerifyReferencePre;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : VerifyReferencePost
-- Description    : This is a POST user-exit addon to the standard EcDp_Dataset_Flow.VerifyReference.
-- Preconditions  : Must be enabled using global variable isVerifyReferencePostUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION VerifyReferencePost(
                        p_type                              VARCHAR2,
                        p_reference_id                      VARCHAR2
                        )
RETURN VARCHAR2
IS
BEGIN
    RETURN NULL;
END VerifyReferencePost;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : UnVerifyReference
-- Description    : This is a INSTEAD OF user-exit addon to the standard EcDp_Dataset_Flow.UnVerifyReference.
-- Preconditions  : Must be enabled using global variable isUnVerifyReferenceUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION UnVerifyReference(
                        p_type                              VARCHAR2,
                        p_reference_id                      VARCHAR2
                        )
RETURN VARCHAR2
IS
BEGIN
    RETURN NULL;
END UnVerifyReference;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : UnVerifyReferencePre
-- Description    : This is a PRE user-exit addon to the standard EcDp_Dataset_Flow.UnVerifyReference.
-- Preconditions  : Must be enabled using global variable isUnVerifyReferencePreUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION UnVerifyReferencePre(
                        p_type                              VARCHAR2,
                        p_reference_id                      VARCHAR2
                        )
RETURN VARCHAR2
IS
BEGIN
    RETURN NULL;
END UnVerifyReferencePre;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : UnVerifyReferencePost
-- Description    : This is a POST user-exit addon to the standard EcDp_Dataset_Flow.UnVerifyReference.
-- Preconditions  : Must be enabled using global variable isUnVerifyReferencePostUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION UnVerifyReferencePost(
                        p_type                              VARCHAR2,
                        p_reference_id                      VARCHAR2
                        )
RETURN VARCHAR2
IS
BEGIN
    RETURN NULL;
END UnVerifyReferencePost;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : ApproveReference
-- Description    : This is a INSTEAD OF user-exit addon to the standard EcDp_Dataset_Flow.ApproveReference.
-- Preconditions  : Must be enabled using global variable isApproveReferenceUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION ApproveReference(
                        p_type                              VARCHAR2,
                        p_reference_id                      VARCHAR2
                        )
RETURN VARCHAR2
IS
BEGIN
    RETURN NULL;
END ApproveReference;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : ApproveReferencePre
-- Description    : This is a PRE user-exit addon to the standard EcDp_Dataset_Flow.ApproveReference.
-- Preconditions  : Must be enabled using global variable isApproveReferencePreUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION ApproveReferencePre(
                        p_type                              VARCHAR2,
                        p_reference_id                      VARCHAR2
                        )
RETURN VARCHAR2
IS
BEGIN
    RETURN NULL;
END ApproveReferencePre;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : ApproveReferencePost
-- Description    : This is a POST user-exit addon to the standard EcDp_Dataset_Flow.ApproveReference.
-- Preconditions  : Must be enabled using global variable isApproveReferencePostUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION ApproveReferencePost(
                        p_type                              VARCHAR2,
                        p_reference_id                      VARCHAR2
                        )
RETURN VARCHAR2
IS
BEGIN
    RETURN NULL;
END ApproveReferencePost;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : UnApproveReference
-- Description    : This is a INSTEAD OF user-exit addon to the standard EcDp_Dataset_Flow.UnApproveReference.
-- Preconditions  : Must be enabled using global variable isUnApproveReferenceUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION UnApproveReference(
                        p_type                              VARCHAR2,
                        p_reference_id                      VARCHAR2
                        )
RETURN VARCHAR2
IS
BEGIN
    RETURN NULL;
END UnApproveReference;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : UnApproveReferencePre
-- Description    : This is a PRE user-exit addon to the standard EcDp_Dataset_Flow.UnApproveReference.
-- Preconditions  : Must be enabled using global variable isUnApproveReferencePreUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION UnApproveReferencePre(
                        p_type                              VARCHAR2,
                        p_reference_id                      VARCHAR2
                        )
RETURN VARCHAR2
IS
BEGIN
    RETURN NULL;
END UnApproveReferencePre;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : UnApproveReferencePost
-- Description    : This is a POST user-exit addon to the standard EcDp_Dataset_Flow.UnApproveReference.
-- Preconditions  : Must be enabled using global variable isUnApproveReferencePostUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION UnApproveReferencePost(
                        p_type                              VARCHAR2,
                        p_reference_id                      VARCHAR2
                        )
RETURN VARCHAR2
IS
BEGIN
    RETURN NULL;
END UnApproveReferencePost;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : Delete
-- Description    : This is a INSTEAD OF user-exit addon to the standard EcDp_Dataset_Flow.Delete.
-- Preconditions  : Must be enabled using global variable isDeleteUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION Delete(
                        p_type                              VARCHAR2,
                        p_doc_id                            VARCHAR2,
                        p_object_id                         VARCHAR2
                        )
RETURN VARCHAR2
IS
BEGIN
    RETURN NULL;
END Delete;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : DeletePre
-- Description    : This is a PRE user-exit addon to the standard EcDp_Dataset_Flow.Delete.
-- Preconditions  : Must be enabled using global variable isDeletePreUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION DeletePre(
                        p_type                              VARCHAR2,
                        p_doc_id                            VARCHAR2,
                        p_object_id                         VARCHAR2
                        )
RETURN VARCHAR2
IS
BEGIN
    RETURN NULL;
END DeletePre;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : DeletePost
-- Description    : This is a POST user-exit addon to the standard EcDp_Dataset_Flow.Delete.
-- Preconditions  : Must be enabled using global variable isDeletePostUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION DeletePost(
                        p_type                              VARCHAR2,
                        p_doc_id                            VARCHAR2,
                        p_object_id                         VARCHAR2
                        )
RETURN VARCHAR2
IS
BEGIN
    RETURN NULL;
END DeletePost;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : Submit
-- Description    : This is a INSTEAD OF user-exit addon to the standard EcDp_Dataset_Flow.Submit.
-- Preconditions  : Must be enabled using global variable isSubmitUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION Submit(
                        p_report_run                        NUMBER
                        )
RETURN VARCHAR2
IS
BEGIN
    RETURN NULL;
END Submit;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : SubmitPre
-- Description    : This is a PRE user-exit addon to the standard EcDp_Dataset_Flow.Submit.
-- Preconditions  : Must be enabled using global variable isSubmitPreUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION SubmitPre(
                        p_report_run                        NUMBER
                        )
RETURN VARCHAR2
IS
BEGIN
    RETURN NULL;
END SubmitPre;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : SubmitPost
-- Description    : This is a POST user-exit addon to the standard EcDp_Dataset_Flow.Submit.
-- Preconditions  : Must be enabled using global variable isSubmitPostUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION SubmitPost(
                        p_report_run                        NUMBER
                        )
RETURN VARCHAR2
IS
BEGIN
    RETURN NULL;
END SubmitPost;




------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : VerifyReference
-- Description    : This is a INSTEAD OF user-exit addon to the standard EcDp_Dataset_Flow.SetReportParams.
-- Preconditions  : Must be enabled using global variable isSetReportParamsUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION SetReportParams(
                        lv_msg                            VARCHAR2,
                        ds_report_id                      NUMBER
                        )
RETURN VARCHAR2
IS
BEGIN
    RETURN NULL;
END SetReportParams;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : SetReportParamsPre
-- Description    : This is a PRE user-exit addon to the standard EcDp_Dataset_Flow.SetReportParams.
-- Preconditions  : Must be enabled using global variable isSetReportParamsPreUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION SetReportParamsPre(
                        lv_msg                            VARCHAR2,
                        ds_report_id                      NUMBER
                        )
RETURN VARCHAR2
IS
BEGIN
    RETURN NULL;
END SetReportParamsPre;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : SetReportParamsPost
-- Description    : This is a POST user-exit addon to the standard EcDp_Dataset_Flow.SetReportParamsPost.
-- Preconditions  : Must be enabled using global variable isSetReportParamsPostUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION SetReportParamsPost(
                        lv_msg                            VARCHAR2,
                        ds_report_id                      NUMBER
                        )
RETURN VARCHAR2
IS
BEGIN
    RETURN NULL;
END SetReportParamsPost;



------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : GetMappingParameters
-- Description    : This is a INSTEAD OF user-exit addon to the standard EcDp_Dataset_Flow.GetMappingParameters.
-- Preconditions  : Must be enabled using global variable isGetMappingParametersUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetMappingParameters(p_daytime DATE,
                              p_ref_id VARCHAR2,
                              p_mapping_type VARCHAR2,
                              p_class_name VARCHAR2,
                              p_parameters VARCHAR2,
                              p_return_value VARCHAR2)
RETURN VARCHAR2
IS
    lv_return_value VARCHAR2(4000);
BEGIN
    lv_return_value := p_return_value;
    RETURN lv_return_value;
END GetMappingParameters;
------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : GetMappingParametersPre
-- Description    : This is a PRE user-exit addon to the standard EcDp_Dataset_Flow.GetMappingParameters.
-- Preconditions  : Must be enabled using global variable isSetReportParamsPreUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetMappingParametersPre(p_daytime DATE,
                                  p_ref_id VARCHAR2,
                                  p_mapping_type VARCHAR2,
                                  p_class_name VARCHAR2,
                                  p_parameters VARCHAR2,
                                  p_return_value VARCHAR2)
RETURN VARCHAR2
IS
    lv_return_value VARCHAR2(4000);
BEGIN
    lv_return_value := p_return_value;
    RETURN lv_return_value;
END GetMappingParametersPre;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : SetReportParamsPost
-- Description    : This is a POST user-exit addon to the standard EcDp_Dataset_Flow.GetMappingParameters.
-- Preconditions  : Must be enabled using global variable isSetReportParamsPostUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetMappingParametersPost(p_daytime DATE,
                                  p_ref_id VARCHAR2,
                                  p_mapping_type VARCHAR2,
                                  p_class_name VARCHAR2,
                                  p_parameters VARCHAR2,
                                  p_return_value VARCHAR2)
RETURN VARCHAR2
IS
    lv_return_value VARCHAR2(4000);
BEGIN
    lv_return_value := p_return_value;
    RETURN lv_return_value;
END GetMappingParametersPost;




------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : GetFilterLabel
-- Description    : This is a INSTEAD OF user-exit addon to the standard EcDp_Dataset_Flow.GetFilterLabel.
-- Preconditions  : Must be enabled using global variable isGetFilterLabelUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetFilterLabel(p_mapping_type VARCHAR2,
                             p_direction VARCHAR2,
                             p_type varchar2 default null,
                             p_Filter_number NUMBER,
                             p_return_value VARCHAR2)
RETURN VARCHAR2
IS
    lv_return_value VARCHAR2(4000);
BEGIN
    lv_return_value := p_return_value;
    RETURN lv_return_value;
END GetFilterLabel;
------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : GetFilterLabelPre
-- Description    : This is a PRE user-exit addon to the standard EcDp_Dataset_Flow.GetFilterLabel.
-- Preconditions  : Must be enabled using global variable isSetReportParamsPreUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetFilterLabelPre(p_mapping_type VARCHAR2,
                             p_direction VARCHAR2,
                             p_type varchar2 default null,
                             p_Filter_number NUMBER,
                             p_return_value VARCHAR2)
RETURN VARCHAR2
IS
    lv_return_value VARCHAR2(4000);
BEGIN
    lv_return_value := p_return_value;
    RETURN lv_return_value;
END GetFilterLabelPre;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : SetReportParamsPost
-- Description    : This is a POST user-exit addon to the standard EcDp_Dataset_Flow.GetFilterLabel.
-- Preconditions  : Must be enabled using global variable isSetReportParamsPostUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetFilterLabelPost(p_mapping_type VARCHAR2,
                             p_direction VARCHAR2,
                             p_type varchar2 default null,
                             p_Filter_number NUMBER,
                             p_return_value VARCHAR2)
RETURN VARCHAR2
IS
    lv_return_value VARCHAR2(4000);
BEGIN
    lv_return_value := p_return_value;
    RETURN lv_return_value;
END GetFilterLabelPost;





------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : GetFilterColumn
-- Description    : This is a INSTEAD OF user-exit addon to the standard EcDp_Dataset_Flow.GetFilterColumn.
-- Preconditions  : Must be enabled using global variable isGetFilterColumnUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetFilterColumn(p_mapping_type VARCHAR2,
                             p_direction VARCHAR2,
                             p_type varchar2 default null,
                             p_Filter_number NUMBER,
                             p_return_value VARCHAR2)
RETURN VARCHAR2
IS
    lv_return_value VARCHAR2(4000);
BEGIN
    lv_return_value := p_return_value;
    RETURN lv_return_value;
END GetFilterColumn;
------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : GetFilterColumnPre
-- Description    : This is a PRE user-exit addon to the standard EcDp_Dataset_Flow.GetFilterColumn.
-- Preconditions  : Must be enabled using global variable isSetReportParamsPreUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetFilterColumnPre(p_mapping_type VARCHAR2,
                             p_direction VARCHAR2,
                             p_type varchar2 default null,
                             p_Filter_number NUMBER,
                             p_return_value VARCHAR2)
RETURN VARCHAR2
IS
    lv_return_value VARCHAR2(4000);
BEGIN
    lv_return_value := p_return_value;
    RETURN lv_return_value;
END GetFilterColumnPre;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : SetReportParamsPost
-- Description    : This is a POST user-exit addon to the standard EcDp_Dataset_Flow.GetFilterColumn.
-- Preconditions  : Must be enabled using global variable isSetReportParamsPostUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetFilterColumnPost(p_mapping_type VARCHAR2,
                             p_direction VARCHAR2,
                             p_type varchar2 default null,
                             p_Filter_number NUMBER,
                             p_return_value VARCHAR2)
RETURN VARCHAR2
IS
    lv_return_value VARCHAR2(4000);
BEGIN
    lv_return_value := p_return_value;
    RETURN lv_return_value;
END GetFilterColumnPost;


------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : getMappingScreen
-- Description    : This is a INSTEAD OF user-exit addon to the standard EcDp_Dataset_Flow.getMappingScreen.
-- Preconditions  : Must be enabled using global variable isgetMappingScreenUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION getMappingScreen( p_mapping_type VARCHAR2,
                           p_direction VARCHAR2,
                           p_type varchar2,
                           p_return_value VARCHAR2)
RETURN VARCHAR2
IS
    lv_return_value VARCHAR2(4000);
BEGIN
    lv_return_value := p_return_value;
    RETURN lv_return_value;
END getMappingScreen;
------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : getMappingScreenPre
-- Description    : This is a PRE user-exit addon to the standard EcDp_Dataset_Flow.getMappingScreen.
-- Preconditions  : Must be enabled using global variable isSetReportParamsPreUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION getMappingScreenPre( p_mapping_type VARCHAR2,
                           p_direction VARCHAR2,
                           p_type varchar2,
                           p_return_value VARCHAR2)
RETURN VARCHAR2
IS
    lv_return_value VARCHAR2(4000);
BEGIN
    lv_return_value := p_return_value;
    RETURN lv_return_value;
END getMappingScreenPre;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : SetReportParamsPost
-- Description    : This is a POST user-exit addon to the standard EcDp_Dataset_Flow.getMappingScreen.
-- Preconditions  : Must be enabled using global variable isSetReportParamsPostUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION getMappingScreenPost( p_mapping_type VARCHAR2,
                           p_direction VARCHAR2,
                           p_type varchar2,
                           p_return_value VARCHAR2)
RETURN VARCHAR2
IS
    lv_return_value VARCHAR2(4000);
BEGIN
    CASE p_mapping_type

               WHEN 'PROD_VOL_TO_REVENUE' THEN
                 lv_return_value:='PRODVOL2REVN';
               ELSE
                 lv_return_value := p_return_value;
    END CASE;


    RETURN lv_return_value;



END getMappingScreenPost;


------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : getObjectText
-- Description    : This is a INSTEAD OF user-exit addon to the standard EcDp_Dataset_Flow.getObjectText.
-- Preconditions  : Must be enabled using global variable isgetObjectTextUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION getObjectText(p_ref_id VARCHAR2,
                       p_mapping_type VARCHAR2,
                       p_object_id VARCHAR2,
                       p_return_value VARCHAR2,
                       p_daytime DATE)
RETURN VARCHAR2
IS
    lv_return_value VARCHAR2(4000);
BEGIN
    lv_return_value := p_return_value;
    RETURN lv_return_value;
END getObjectText;
------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : getObjectTextPre
-- Description    : This is a PRE user-exit addon to the standard EcDp_Dataset_Flow.getObjectText.
-- Preconditions  : Must be enabled using global variable isSetReportParamsPreUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION getObjectTextPre(p_ref_id VARCHAR2,
                       p_mapping_type VARCHAR2,
                       p_object_id VARCHAR2,
                       p_return_value VARCHAR2,
                       p_daytime DATE)
RETURN VARCHAR2
IS
    lv_return_value VARCHAR2(4000);
BEGIN
    lv_return_value := p_return_value;
    RETURN lv_return_value;
END getObjectTextPre;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : SetReportParamsPost
-- Description    : This is a POST user-exit addon to the standard EcDp_Dataset_Flow.getObjectText.
-- Preconditions  : Must be enabled using global variable isSetReportParamsPostUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION getObjectTextPost(p_ref_id VARCHAR2,
                       p_mapping_type VARCHAR2,
                       p_object_id VARCHAR2,
                       p_return_value VARCHAR2,
                       p_daytime DATE)
RETURN VARCHAR2
IS
    lv_return_value VARCHAR2(4000);
BEGIN
  CASE p_mapping_type
    WHEN 'PROD_VOL_TO_REVENUE' THEN
      lv_return_value := ec_cost_mapping_version.name(p_object_id,
                                                p_daytime,
                                                '<=');
    ELSE
      lv_return_value := p_return_value;
  END CASE;


    RETURN lv_return_value;
END getObjectTextPost;



------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : getMappingText
-- Description    : This is a INSTEAD OF user-exit addon to the standard EcDp_Dataset_Flow.getMappingText.
-- Preconditions  : Must be enabled using global variable isgetMappingTextUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION getMappingText(p_daytime date,
                            p_ref_id VARCHAR2,
                            p_mapping_type VARCHAR2,
                            p_mapping_id VARCHAR2,
                            p_return_value VARCHAR2)
RETURN VARCHAR2
IS
    lv_return_value VARCHAR2(4000);
BEGIN
    lv_return_value := p_return_value;
    RETURN lv_return_value;
END getMappingText;
------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : getMappingTextPre
-- Description    : This is a PRE user-exit addon to the standard EcDp_Dataset_Flow.getMappingText.
-- Preconditions  : Must be enabled using global variable isSetReportParamsPreUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION getMappingTextPre(p_daytime date,
                            p_ref_id VARCHAR2,
                            p_mapping_type VARCHAR2,
                            p_mapping_id VARCHAR2,
                            p_return_value VARCHAR2)
RETURN VARCHAR2
IS
    lv_return_value VARCHAR2(4000);
BEGIN
    lv_return_value := p_return_value;

    RETURN lv_return_value;


END getMappingTextPre;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : SetReportParamsPost
-- Description    : This is a POST user-exit addon to the standard EcDp_Dataset_Flow.getMappingText.
-- Preconditions  : Must be enabled using global variable isSetReportParamsPostUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION getMappingTextPost(p_daytime date,
                            p_ref_id VARCHAR2,
                            p_mapping_type VARCHAR2,
                            p_mapping_id VARCHAR2,
                            p_return_value VARCHAR2)
RETURN VARCHAR2
IS
    lv_return_value VARCHAR2(4000);
BEGIN

    CASE
           WHEN  p_mapping_type IN ('PROD_VOL_TO_REVENUE','PRODVOL2REVN') THEN
             lv_return_value := ec_cost_mapping_version.name(p_mapping_id,p_daytime,'<=');

    else
             lv_return_value := p_return_value;
    END CASE;

    RETURN lv_return_value;

END getMappingTextPost;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : InsJMDataToDS
-- Description    : This is a INSTEAD OF user-exit addon to the standard EcDp_Dataset_Flow.InsJMDataToDS.
-- Preconditions  : Must be enabled using global variable isInsJMDataToDSUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION InsJMDataToDS( p_document_key                     VARCHAR2
                        )
RETURN VARCHAR2
IS
    lv_return_value VARCHAR2(4000);
BEGIN
    RETURN lv_return_value;
END InsJMDataToDS;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : InsJMDataToDSPre
-- Description    : This is a PRE user-exit addon to the standard EcDp_Dataset_Flow.InsJMDataToDS.
-- Preconditions  : Must be enabled using global variable isInsJMDataToDSPreUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION InsJMDataToDSPre(
                        p_document_key                      VARCHAR2
                        )
RETURN VARCHAR2
IS
    lv_return_value VARCHAR2(4000);
CURSOR c_class_doc IS
SELECT DISTINCT
       c.ref_journal_entry_no,
       c.ref_journal_entry_src,
       period
  FROM CONT_JOURNAL_ENTRY c
 WHERE c.document_key=p_document_key
   AND c.reversal_date IS NULL
   AND C.ref_journal_entry_src NOT IN ('CLASS','CONT','IFAC') ;

BEGIN


    FOR C in c_class_doc loop
    -- Insert into dataset flow document if missing:
    insert into dataset_flow_document
                      (TYPE,
                       PROCESS_DATE,
                       OBJECT,
                       REFERENCE_ID,
                       STATUS,
                       MAX_IND,
                       screen_doc_type)
                      (SELECT c.ref_journal_entry_src,
                               C.period,
                              'MISC',
                              c.ref_journal_entry_no,
                              'P',
                              'N',
                              'PERIOD'
                         FROM DUAL
                        WHERE NOT EXISTS (SELECT TYPE
                                 FROM DATASET_FLOW_DOCUMENT
                                WHERE TYPE = c.ref_journal_entry_src
                                  AND REFERENCE_ID = c.ref_journal_entry_no));

    END LOOP;
    RETURN lv_return_value;
END InsJMDataToDSPre;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : InsJMDataToDSPost
-- Description    : This is a POST user-exit addon to the standard EcDp_Dataset_Flow.InsJMDataToDS.
-- Preconditions  : Must be enabled using global variable isInsJMDataToDSPostUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION InsJMDataToDSPost(
                        p_document_key                      VARCHAR2,
                        p_return_value                      VARCHAR2
                        )
RETURN VARCHAR2
IS
    lv_return_value VARCHAR2(4000);

    CURSOR c_class_detail IS
   SELECT
       c.ref_journal_entry_no,
       c.ref_journal_entry_src,
       c.ref_rec_id,
       period,
       dfdc.connection_id,
       dfdc.to_type,
       dfdc.to_reference_id,
       C.Class_Map_Params,
       c.cost_mapping_id,
       c.created_date,
       c.journal_entry_no
  FROM CONT_JOURNAL_ENTRY c,
       DATASET_FLOW_DOC_CONN dfdc
 WHERE c.document_key=p_document_key
   AND c.reversal_date IS NULL
   AND dfdc.from_type = c.ref_journal_entry_src
   AND dfdc.From_Reference_Id = c.ref_journal_entry_NO
   AND C.ref_journal_entry_src NOT IN ('CLASS','CONT','IFAC') ;

   ln_count number;
   lv_status varchar2(1);
   lv_accrual varchar2(1);
BEGIN
    lv_return_value := p_return_value;

    IF NVL(ec_ctrl_system_attribute.attribute_text(ec_cont_doc.period(p_document_key),'ENABLE_DOC_TRACING','<='),'N') = 'Y' THEN

    for detail in c_class_detail loop


    IF detail.ref_journal_entry_src = 'CONT_DOCUMENT' THEN
    select count(*) into ln_count from dataset_flow_document where
           type = detail.ref_journal_entry_src
           and reference_id = detail.ref_journal_entry_no;

           case ec_cont_document.document_level_code(detail.ref_journal_entry_no)
                  when 'OPEN' then
                       lv_status:='P';
                  when 'BOOKED' then
                    lv_status:='A';
                  else lv_status:='V';
           end case;

           case ec_cont_document.STATUS_CODE(detail.ref_journal_entry_no) when
               'FINAL'
               then lv_accrual:= 'N';
                 else lv_accrual:= 'Y';
           end case;

         if ln_count = 0 then
             ecdp_dataset_flow.InsToDsFlowDoc(detail.ref_journal_entry_src,
                      detail.period,
                      ec_cont_document.object_id(detail.ref_journal_entry_no),
                      detail.ref_journal_entry_no,
                      lv_status,
                      'Y','N/A',
                      lv_accrual,
                      'PERIOD');
          end if;

    END IF;
                    INSERT INTO DATASET_FLOW_DETAIL_CONN
                    (
                    CONNECTION_ID,
                    TO_TYPE,
                    FROM_TYPE,
                    TO_REFERENCE_ID,
                    FROM_REFERENCE_ID,
                    FROM_ID,
                    TO_ID,
                    MAPPING_TYPE,
                    MAPPING_ID,
                    RUN_TIME,
                    DETAIL_TO_VALUE,
                    COMMENTS,
                    CREATED_BY,
                    CREATED_DATE
                    )
                    VALUES
                    (detail.connection_id,
                    detail.to_type,
                    detail.ref_journal_entry_src,
                    p_document_key,
                    detail.ref_journal_entry_no,
                    detail.ref_rec_id,
                    detail.journal_entry_no,
                    detail.ref_journal_entry_src,
                    detail.cost_mapping_id ,
                    detail.created_date,
                    'N',
                    detail.Class_Map_Params,
                    user,
                    Ecdp_Timestamp.getCurrentSysdate
                    );
        END LOOP;
    END IF;

    RETURN lv_return_value;
END InsJMDataToDSPost;


------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : GetReferenceDesc
-- Description    : This is a INSTEAD OF user-exit addon to the standard EcDp_Dataset_Flow.GetReferenceDesc.
-- Preconditions  : Must be enabled using global variable isGetReferenceDescUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetReferenceDesc(
                        p_DocumentKey                       VARCHAR2,
                        p_type                              VARCHAR2)
RETURN VARCHAR2
IS
    lv_return_value VARCHAR2(4000);
BEGIN
    --lv_return_value := p_return_value;
    RETURN lv_return_value;
END GetReferenceDesc;
------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : GetReferenceDescPost
-- Description    : This is a PRE user-exit addon to the standard EcDp_Dataset_Flow.GetReferenceDesc.
-- Preconditions  : Must be enabled using global variable isGetReferenceDescPostUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetReferenceDescPost(
                        p_DocumentKey                       VARCHAR2,
                        p_type                              VARCHAR2,
                        p_return_value                      VARCHAR2)
RETURN VARCHAR2
IS
    lv_return_value VARCHAR2(4000);
BEGIN

--Example of how to set up for Production loaded value
    IF p_type = 'PROD_VOL_TO_REVENUE' then
          null;
          --lv_Reference := rrca_common.getRunReference(p_DocumentKey) ;
    ELSE
        lv_return_value := p_return_value;
    END IF;

    RETURN lv_return_value;


END GetReferenceDescPost;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : GetReferenceDescPre
-- Description    : This is a POST user-exit addon to the standard EcDp_Dataset_Flow. GetReferenceDesc.
-- Preconditions  : Must be enabled using global variable isGetReferenceDescPreUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetReferenceDescPre(
                        p_DocumentKey                       VARCHAR2,
                        p_type                              VARCHAR2)
RETURN VARCHAR2
IS
    lv_return_value VARCHAR2(4000);
BEGIN
    --lv_return_value := p_return_value;
    RETURN lv_return_value;
END GetReferenceDescPre;

END ue_Dataset_Flow;