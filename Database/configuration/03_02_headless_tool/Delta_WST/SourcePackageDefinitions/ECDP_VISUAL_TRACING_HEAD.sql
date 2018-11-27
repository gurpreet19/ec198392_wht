CREATE OR REPLACE PACKAGE EcDp_Visual_Tracing IS
/***************************************************************************************************
** Package        : EcDp_Visual_Tracing, header part
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

TYPE t_mth_entity_status_rec IS RECORD
  (
  data_entity_cat VARCHAR2(240),
  mth_status VARCHAR2(240)
  );

TYPE t_mth_entity_status IS TABLE OF t_mth_entity_status_rec;

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
    p_source_doc_ver NUMBER,
    p_period DATE
) RETURN VARCHAR2;

FUNCTION GetReportProcess(
    p_document_key VARCHAR2,
    p_report_no NUMBER,
    p_period DATE
) RETURN VARCHAR2;

FUNCTION GetReportActualAccrual(
    p_document_key VARCHAR2,
    p_report_no NUMBER
) RETURN VARCHAR2;

FUNCTION GetForwardReference(
    p_reference_id VARCHAR2,
    p_type         VARCHAR2
) RETURN VARCHAR2;

FUNCTION GetNotesReference(
    p_reference_id VARCHAR2,
    p_type         VARCHAR2
) RETURN VARCHAR2;

FUNCTION GetUpdateYearStatus(
    p_period_string                    VARCHAR2,
    p_property_id                      VARCHAR2,
    p_tr_area_code                     VARCHAR2,
    p_parent_project_id                VARCHAR2,
    p_process_code                     VARCHAR2,
    p_act_acc_code                     VARCHAR2,
    p_deprecated_code                  VARCHAR2
) RETURN VARCHAR2;

END EcDp_Visual_Tracing;