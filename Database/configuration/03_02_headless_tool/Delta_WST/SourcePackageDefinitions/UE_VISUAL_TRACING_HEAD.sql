CREATE OR REPLACE PACKAGE ue_visual_tracing IS
/***************************************************************************************************
** Package        : UE_visual_tracing, header part
**
** Release        :
**
** Purpose        : Various procedure and functions for the Visual tracing
**
**
**
** Created        : 2016-10-12 - gjossarv
**
** Modification history:
**
** Date        Whom      Change description:
** ----------  --------  ---------------------------------------------------------------------------
** 2016-10-12  gjossarv  Initial version.
***************************************************************************************************/

isUpdGraphTracingUEEnabled            VARCHAR2(32) := 'FALSE';
isUpdYearStatusUEEnabled              VARCHAR2(32) := 'FALSE';
isGetUploadProcessUEEnabled           VARCHAR2(32) := 'FALSE';
isGetReportProcessUEEnabled           VARCHAR2(32) := 'FALSE';
isGetReportActAccUEEnabled            VARCHAR2(32) := 'FALSE';
isGetForwardRefUEEnabled              VARCHAR2(32) := 'FALSE';
isGetNotesRefUEEnabled                VARCHAR2(32) := 'FALSE';
isGetUpdYearStatusUEEnabled           VARCHAR2(32) := 'FALSE';


PROCEDURE UpdateVisualTracing (
    p_reference_id  VARCHAR2,
    p_type          VARCHAR2,
    p_period        DATE
);

PROCEDURE UpdateYearStatus (
    p_period               DATE,
    p_property_id          VARCHAR2,
    p_tr_area_code         VARCHAR2,
    p_parent_project_id    VARCHAR2 DEFAULT NULL,
    p_process_code         VARCHAR2 DEFAULT NULL,
    p_act_acc_code         VARCHAR2 DEFAULT NULL,
    p_deprecated_code      VARCHAR2 DEFAULT NULL
);

FUNCTION GetUploadProcess(
    p_source_doc_name VARCHAR2,
    p_source_doc_ver  NUMBER,
    p_period          DATE
) RETURN VARCHAR2;

FUNCTION GetReportProcess(
    p_document_key VARCHAR2,
    p_report_no NUMBER,
    p_period DATE
)
RETURN VARCHAR2;

FUNCTION GetReportActualAccrual(
    p_document_key VARCHAR2,
    p_report_no NUMBER
)
RETURN VARCHAR2;

FUNCTION GetForwardReference(
    p_reference_id VARCHAR2,
    p_type         VARCHAR2
)
RETURN VARCHAR2;

FUNCTION GetNotesReference(
    p_reference_id VARCHAR2,
    p_type         VARCHAR2
)
RETURN VARCHAR2;

FUNCTION GetUpdateYearStatus(
    p_period_string                    VARCHAR2,
    p_property_id                      VARCHAR2,
    p_tr_area_code                     VARCHAR2,
    p_parent_project_id                VARCHAR2,
    p_process_code                     VARCHAR2,
    p_act_acc_code                     VARCHAR2,
    p_deprecated_code                  VARCHAR2
)
RETURN VARCHAR2;

END ue_visual_tracing;