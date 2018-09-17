CREATE OR REPLACE package ue_Dataset_Flow IS
/****************************************************************
**
** NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE
** NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE

** Enable this User Exit by setting variables below to 'TRUE'

** NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE
** NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE
**
** Package        :  ue_Dataset_Flow, header part
**
** Purpose        :  Provide user exit functions for package EcDp_Dataset_Flow
**
** Documentation  :  www.energy-components.com
**
** Created        :  2015-09-03  Georg Hoien
**
************************************************************************/

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Enabling/Disabling User Exits for EcDp_Dataset_Flow.VerifyReference
------------------------+-----------------------------------+------------------------------------+---------------------------
isVerifyReferenceUEE                                        VARCHAR2(32) := 'FALSE'; -- Instead of
isVerifyReferencePreUEE                                     VARCHAR2(32) := 'FALSE'; -- Pre
isVerifyReferencePostUEE                                    VARCHAR2(32) := 'FALSE'; -- Post

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Enabling/Disabling User Exits for EcDp_Dataset_Flow.UnVerifyReference
------------------------+-----------------------------------+------------------------------------+---------------------------
isUnVerifyReferenceUEE                                      VARCHAR2(32) := 'FALSE'; -- Instead of
isUnVerifyReferencePreUEE                                   VARCHAR2(32) := 'FALSE'; -- Pre
isUnVerifyReferencePostUEE                                  VARCHAR2(32) := 'FALSE'; -- Post

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Enabling/Disabling User Exits for EcDp_Dataset_Flow.ApproveReference
------------------------+-----------------------------------+------------------------------------+---------------------------
isApproveReferenceUEE                                       VARCHAR2(32) := 'FALSE'; -- Instead of
isApproveReferencePreUEE                                    VARCHAR2(32) := 'FALSE'; -- Pre
isApproveReferencePostUEE                                   VARCHAR2(32) := 'FALSE'; -- Post

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Enabling/Disabling User Exits for EcDp_Dataset_Flow.UnApproveReference
------------------------+-----------------------------------+------------------------------------+---------------------------
isUnApproveReferenceUEE                                     VARCHAR2(32) := 'FALSE'; -- Instead of
isUnApproveReferencePreUEE                                  VARCHAR2(32) := 'FALSE'; -- Pre
isUnApproveReferencePostUEE                                 VARCHAR2(32) := 'FALSE'; -- Post

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Enabling/Disabling User Exits for EcDp_Dataset_Flow.Delete
------------------------+-----------------------------------+------------------------------------+---------------------------
isDeleteUEE                                                 VARCHAR2(32) := 'FALSE'; -- Instead of
isDeletePreUEE                                              VARCHAR2(32) := 'FALSE'; -- Pre
isDeletePostUEE                                             VARCHAR2(32) := 'FALSE'; -- Post

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Enabling/Disabling User Exits for EcDp_Dataset_Flow.Submit
------------------------+-----------------------------------+------------------------------------+---------------------------
isSubmitUEE                                                 VARCHAR2(32) := 'FALSE'; -- Instead of
isSubmitPreUEE                                              VARCHAR2(32) := 'FALSE'; -- Pre
isSubmitPostUEE                                             VARCHAR2(32) := 'FALSE'; -- Post

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Enabling/Disabling User Exits for EcDp_Dataset_Flow.SetReportParams
------------------------+-----------------------------------+------------------------------------+---------------------------
isSetReportParamsUEE                                        VARCHAR2(32) := 'FALSE'; -- Instead of
isSetReportParamsPreUEE                                     VARCHAR2(32) := 'FALSE'; -- Pre
isSetReportParamsPostUEE                                    VARCHAR2(32) := 'FALSE'; -- Post

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Enabling/Disabling User Exits for EcDp_Dataset_Flow.GetMappingParameters
------------------------+-----------------------------------+------------------------------------+---------------------------
isGetMappingParametersUEE                                   VARCHAR2(32) := 'FALSE'; -- Instead of
isGetMappingParametersPreUEE                                VARCHAR2(32) := 'FALSE'; -- Pre
isGetMappingParametersPostUEE                               VARCHAR2(32) := 'FALSE'; -- Post

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Enabling/Disabling User Exits for EcDp_Dataset_Flow.FilterLabel
------------------------+-----------------------------------+------------------------------------+---------------------------
isGetFilterLabelUEE                                         VARCHAR2(32) := 'FALSE'; -- Instead of
isGetFilterLabelPreUEE                                      VARCHAR2(32) := 'FALSE'; -- Pre
isGetFilterLabelPostUEE                                     VARCHAR2(32) := 'FALSE'; -- Post

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Enabling/Disabling User Exits for EcDp_Dataset_Flow.ObjectText
------------------------+-----------------------------------+------------------------------------+---------------------------
isgetObjectTextUEE                                          VARCHAR2(32) := 'FALSE'; -- Instead of
isgetObjectTextPreUEE                                       VARCHAR2(32) := 'FALSE'; -- Pre
isgetObjectTextPostUEE                                      VARCHAR2(32) := 'FALSE'; -- Post

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Enabling/Disabling User Exits for EcDp_Dataset_Flow.GetFilterColumn
------------------------+-----------------------------------+------------------------------------+---------------------------
isGetFilterColumnUEE                                        VARCHAR2(32) := 'FALSE'; -- Instead of
isGetFilterColumnPreUEE                                     VARCHAR2(32) := 'FALSE'; -- Pre
isGetFilterColumnPostUEE                                    VARCHAR2(32) := 'FALSE'; -- Post

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Enabling/Disabling User Exits for EcDp_Dataset_Flow.getMappingScreen
------------------------+-----------------------------------+------------------------------------+---------------------------
isGetMappingScreenUEE                                       VARCHAR2(32) := 'FALSE'; -- Instead of
isGetMappingScreenPreUEE                                    VARCHAR2(32) := 'FALSE'; -- Pre
isGetMappingScreenPostUEE                                   VARCHAR2(32) := 'FALSE'; -- Post

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Enabling/Disabling User Exits for EcDp_Dataset_Flow.getMappingText
------------------------+-----------------------------------+------------------------------------+---------------------------
isgetMappingTextUEE                                         VARCHAR2(32) := 'FALSE'; -- Instead of
isgetMappingTextPreUEE                                      VARCHAR2(32) := 'FALSE'; -- Pre
isgetMappingTextPostUEE                                     VARCHAR2(32) := 'FALSE'; -- Post

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Enabling/Disabling User Exits for EcDp_Dataset_Flow.InsJMDataToDS
------------------------+-----------------------------------+------------------------------------+---------------------------
isInsJMDataToDSUEE                                          VARCHAR2(32) := 'FALSE'; -- Instead of
isInsJMDataToDSPreUEE                                       VARCHAR2(32) := 'FALSE'; -- Pre
isInsJMDataToDSPostUEE                                      VARCHAR2(32) := 'FALSE'; -- Post

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Enabling/Disabling User Exits for EcDp_Dataset_Flow.InsJMDataToDS
------------------------+-----------------------------------+------------------------------------+---------------------------
isGetReferenceDescUEE                                       VARCHAR2(32) := 'FALSE'; -- Instead of
isGetReferenceDescPreUEE                                       VARCHAR2(32) := 'FALSE'; -- Pre
isGetReferenceDescPostUEE                                      VARCHAR2(32) := 'FALSE'; -- Post

------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------

FUNCTION GetReferenceDescPre(
                        p_DocumentKey                       VARCHAR2,
                        p_type                              VARCHAR2
                        )
RETURN VARCHAR2;
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetReferenceDescPost(
                        p_DocumentKey                       VARCHAR2,
                        p_type                              VARCHAR2,
                        p_return_value                      VARCHAR2
                        )
RETURN VARCHAR2;
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetReferenceDesc(
                        p_DocumentKey                       VARCHAR2,
                        p_type                              VARCHAR2
                        )
RETURN VARCHAR2;
------------------------+-----------------------------------+------------------------------------+---------------------------

FUNCTION SetReportParamsPre(
                        lv_msg                              VARCHAR2,
                        ds_report_id                        NUMBER
                        )
RETURN VARCHAR2;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------

FUNCTION SetReportParamsPost(
                        lv_msg                              VARCHAR2,
                        ds_report_id                        NUMBER
                        )
RETURN VARCHAR2;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------

FUNCTION SetReportParams(
                        lv_msg                              VARCHAR2,
                        ds_report_id                        NUMBER
                        )
RETURN VARCHAR2;

------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION VerifyReference(
                        p_type                              VARCHAR2,
                        p_reference_id                      VARCHAR2
                        )
RETURN VARCHAR2;

------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION VerifyReferencePre(
                        p_type                              VARCHAR2,
                        p_reference_id                      VARCHAR2
                        )
RETURN VARCHAR2;

------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION VerifyReferencePost(
                        p_type                              VARCHAR2,
                        p_reference_id                      VARCHAR2
                        )
RETURN VARCHAR2;

------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION UnVerifyReference(
                        p_type                              VARCHAR2,
                        p_reference_id                      VARCHAR2
                        )
RETURN VARCHAR2;

------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION UnVerifyReferencePre(
                        p_type                              VARCHAR2,
                        p_reference_id                      VARCHAR2
                        )
RETURN VARCHAR2;

------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION UnVerifyReferencePost(
                        p_type                              VARCHAR2,
                        p_reference_id                      VARCHAR2
                        )
RETURN VARCHAR2;

------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION ApproveReference(
                        p_type                              VARCHAR2,
                        p_reference_id                      VARCHAR2
                        )
RETURN VARCHAR2;

------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION ApproveReferencePre(
                        p_type                              VARCHAR2,
                        p_reference_id                      VARCHAR2
                        )
RETURN VARCHAR2;

------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION ApproveReferencePost(
                        p_type                              VARCHAR2,
                        p_reference_id                      VARCHAR2
                        )
RETURN VARCHAR2;

------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION UnApproveReference(
                        p_type                              VARCHAR2,
                        p_reference_id                      VARCHAR2
                        )
RETURN VARCHAR2;

------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION UnApproveReferencePre(
                        p_type                              VARCHAR2,
                        p_reference_id                      VARCHAR2
                        )
RETURN VARCHAR2;

------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION UnApproveReferencePost(
                        p_type                              VARCHAR2,
                        p_reference_id                      VARCHAR2
                        )
RETURN VARCHAR2;

------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION Delete(
                        p_type                              VARCHAR2,
                        p_doc_id                            VARCHAR2,
                        p_object_id                         VARCHAR2
                        )
RETURN VARCHAR2;

------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION DeletePre(
                        p_type                              VARCHAR2,
                        p_doc_id                            VARCHAR2,
                        p_object_id                         VARCHAR2
                        )
RETURN VARCHAR2;

------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION DeletePost(
                        p_type                              VARCHAR2,
                        p_doc_id                            VARCHAR2,
                        p_object_id                         VARCHAR2
                        )
RETURN VARCHAR2;

------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION Submit(
                        p_report_run                        NUMBER
                        )
RETURN VARCHAR2;

------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION SubmitPre(
                        p_report_run                        NUMBER
                        )
RETURN VARCHAR2;

------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION SubmitPost(
                        p_report_run                        NUMBER
                        )
RETURN VARCHAR2;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------

FUNCTION GetMappingParameters(p_daytime DATE,
                              p_ref_id VARCHAR2,
                              p_mapping_type VARCHAR2,
                              p_class_name VARCHAR2,
                              p_parameters VARCHAR2,
                              p_return_value VARCHAR2)
RETURN VARCHAR2;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------

FUNCTION GetMappingParametersPre(p_daytime DATE,
                                  p_ref_id VARCHAR2,
                                  p_mapping_type VARCHAR2,
                                  p_class_name VARCHAR2,
                                  p_parameters VARCHAR2,
                                  p_return_value VARCHAR2)
RETURN VARCHAR2;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------

FUNCTION GetMappingParametersPost(p_daytime DATE,
                                  p_ref_id VARCHAR2,
                                  p_mapping_type VARCHAR2,
                                  p_class_name VARCHAR2,
                                  p_parameters VARCHAR2,
                                  p_return_value VARCHAR2)
RETURN VARCHAR2;

------------------------+-----------------------------------+------------------------------------+---------------------------


FUNCTION GetFilterLabel(p_mapping_type VARCHAR2,
                             p_direction VARCHAR2,
                             p_type varchar2 default null,
                             p_Filter_number NUMBER,
                             p_return_value VARCHAR2)
RETURN VARCHAR2;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------

FUNCTION GetFilterLabelPre(p_mapping_type VARCHAR2,
                             p_direction VARCHAR2,
                             p_type varchar2 default null,
                             p_Filter_number NUMBER,
                             p_return_value VARCHAR2)
RETURN VARCHAR2;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------

FUNCTION GetFilterLabelPost(p_mapping_type VARCHAR2,
                             p_direction VARCHAR2,
                             p_type varchar2 default null,
                             p_Filter_number NUMBER,
                             p_return_value VARCHAR2)
RETURN VARCHAR2;

FUNCTION GetFilterColumn(p_mapping_type VARCHAR2,
                             p_direction VARCHAR2,
                             p_type varchar2 default null,
                             p_Filter_number NUMBER,
                             p_return_value VARCHAR2)
RETURN VARCHAR2;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------

FUNCTION GetFilterColumnPre(p_mapping_type VARCHAR2,
                             p_direction VARCHAR2,
                             p_type varchar2 default null,
                             p_Filter_number NUMBER,
                             p_return_value VARCHAR2)
RETURN VARCHAR2;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------

FUNCTION GetFilterColumnPost(p_mapping_type VARCHAR2,
                             p_direction VARCHAR2,
                             p_type varchar2 default null,
                             p_Filter_number NUMBER,
                             p_return_value VARCHAR2)
RETURN VARCHAR2;

FUNCTION getMappingScreen( p_mapping_type VARCHAR2,
                           p_direction VARCHAR2,
                           p_type varchar2,
                           p_return_value VARCHAR2)
RETURN VARCHAR2;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------

FUNCTION getMappingScreenPre( p_mapping_type VARCHAR2,
                           p_direction VARCHAR2,
                           p_type varchar2,
                           p_return_value VARCHAR2)
RETURN VARCHAR2;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------

FUNCTION getMappingScreenPost( p_mapping_type VARCHAR2,
                           p_direction VARCHAR2,
                           p_type varchar2,
                           p_return_value VARCHAR2)
RETURN VARCHAR2;

FUNCTION getObjectText(p_ref_id VARCHAR2,
                       p_mapping_type VARCHAR2,
                       p_object_id VARCHAR2,
                       p_return_value VARCHAR2,
                       p_daytime DATE)
RETURN VARCHAR2;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------

FUNCTION getObjectTextPre(p_ref_id VARCHAR2,
                       p_mapping_type VARCHAR2,
                       p_object_id VARCHAR2,
                       p_return_value VARCHAR2,
                       p_daytime DATE)
RETURN VARCHAR2;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------

FUNCTION getObjectTextPost(p_ref_id VARCHAR2,
                       p_mapping_type VARCHAR2,
                       p_object_id VARCHAR2,
                       p_return_value VARCHAR2,
                       p_daytime DATE)
RETURN VARCHAR2;


FUNCTION getMappingText(p_daytime date,
                            p_ref_id VARCHAR2,
                            p_mapping_type VARCHAR2,
                            p_mapping_id VARCHAR2,
                            p_return_value VARCHAR2)
RETURN VARCHAR2;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------

FUNCTION getMappingTextPre(p_daytime date,
                            p_ref_id VARCHAR2,
                            p_mapping_type VARCHAR2,
                            p_mapping_id VARCHAR2,
                            p_return_value VARCHAR2)
RETURN VARCHAR2;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------

FUNCTION getMappingTextPost(p_daytime date,
                            p_ref_id VARCHAR2,
                            p_mapping_type VARCHAR2,
                            p_mapping_id VARCHAR2,
                            p_return_value VARCHAR2) RETURN
  VARCHAR2;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------

FUNCTION InsJMDataToDS( p_document_key                      VARCHAR2
                        )
RETURN VARCHAR2;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------

FUNCTION InsJMDataToDSPre(
                        p_document_key                      VARCHAR2
                        )
RETURN VARCHAR2;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------

FUNCTION InsJMDataToDSPost(
                        p_document_key                      VARCHAR2,
                        p_return_value                      VARCHAR2
                        )
RETURN VARCHAR2;

end ue_Dataset_Flow;