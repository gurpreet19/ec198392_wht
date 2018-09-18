CREATE OR REPLACE PACKAGE BODY ue_visual_tracing IS
/***************************************************************************************************
** Package        : ecdp_visual_tracing, header part
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



/*<EC-DOC>
-------------------------------------------------------------------------------------------------
 Function       : UpdateYearStatus                                                       --
 Description    : Finds all data entities that are linked to a data entity through the tracing.--
                  Does this for each of the data entities in the dataset_flow_document table   --
                  for the given period (month)
                                                                                               --
 Preconditions  :                                                                              --
 Postcondition  :                                                                              --
 Using Tables   :                                                                              --
                                                                                               --
 Using functions:                                                                              --
                                                                                               --
 Configuration                                                                                 --
 required       :                                                                              --
                                                                                               --
 Behaviour      :                                                                              --
                                                                                               --
-------------------------------------------------------------------------------------------------*/
PROCEDURE UpdateYearStatus (
    p_period               DATE,
    p_property_id          VARCHAR2,
    p_tr_area_code         VARCHAR2,
    p_parent_project_id    VARCHAR2 DEFAULT NULL,
    p_process_code         VARCHAR2 DEFAULT NULL,
    p_act_acc_code         VARCHAR2 DEFAULT NULL,
    p_deprecated_code      VARCHAR2 DEFAULT NULL
    )

IS

BEGIN
  null;
END UpdateYearStatus;

    -----------------------------------------------------------------------
    -- Updates the status for all months in specified year.
    ----+----------------------------------+-------------------------------
    FUNCTION GetUpdateYearStatus(
        p_period_string                    VARCHAR2,
        p_property_id                      VARCHAR2,
        p_tr_area_code                     VARCHAR2,
        p_parent_project_id                VARCHAR2,
        p_process_code                     VARCHAR2,
        p_act_acc_code                     VARCHAR2,
        p_deprecated_code                  VARCHAR2)
    RETURN VARCHAR2
    IS

    BEGIN
        RETURN null;
    END GetUpdateYearStatus;


/*<EC-DOC>
-------------------------------------------------------------------------------------------------
 Function       : UpdateVisualTracing                                                       --
 Description    : Finds all data entities that are linked to a data entity through the tracing.--
                  Does this for each of the data entities in the dataset_flow_document table   --
                  for the given period (month)
                                                                                               --
 Preconditions  :                                                                              --
 Postcondition  :                                                                              --
 Using Tables   :                                                                              --
                                                                                               --
 Using functions:                                                                              --
                                                                                               --
 Configuration                                                                                 --
 required       :                                                                              --
                                                                                               --
 Behaviour      :                                                                              --
                                                                                               --
-------------------------------------------------------------------------------------------------*/
PROCEDURE UpdateVisualTracing(
    p_reference_id  VARCHAR2,
    p_type          VARCHAR2,
    p_period        DATE
    )
--</EC-DOC>
IS

BEGIN
  null;
END UpdateVisualTracing;

--<EC-DOC>
----------------------------------------------------------------------------------------------------
-- Function       : get_upload_dataset
-- Description    : Returns a the dataset for a data upload.
-----------------------------------------------------------------------------------------------------
FUNCTION GetUploadProcess(p_source_doc_name VARCHAR2, p_source_doc_ver NUMBER, p_period DATE)
RETURN VARCHAR2
--</EC-DOC>
IS

BEGIN
   return null;
END GetUploadProcess;

--<EC-DOC>
----------------------------------------------------------------------------------------------------
-- Function       : get_report_process
-- Description    : Returns a the Process for a report.
-----------------------------------------------------------------------------------------------------
FUNCTION GetReportProcess(p_document_key VARCHAR2, p_report_no NUMBER, p_period DATE)
RETURN VARCHAR2
--</EC-DOC>
IS

BEGIN
   return null;
END GetReportProcess;


--<EC-DOC>
----------------------------------------------------------------------------------------------------
-- Function       : get_report_actual_accrual
-- Description    : Returns whether a report belongs to a Actual or Accrual
-----------------------------------------------------------------------------------------------------
FUNCTION GetReportActualAccrual(p_document_key VARCHAR2, p_report_no NUMBER)
RETURN VARCHAR2
--</EC-DOC>
IS

BEGIN
   return null;
END GetReportActualAccrual;

--<EC-DOC>
----------------------------------------------------------------------------------------------------
-- Function       : get_forward_reference
-- Description    : This function is for setting icon related to new entitites
--                  Checks if the data entity has a forward reference, i.e.
--                  it exists in the 'from_reference_id' column.
--                  If there is no forward reference it means that this is a new data entity.
--                  In this case the function retuns 'WARNING'
--                  If there is a forward reference AND the data entity is PROVISIONAL/OPEN then the
--                  function returns the OPEN_LOCK.
--                  Else it returns LOCK
-----------------------------------------------------------------------------------------------------
FUNCTION GetForwardReference(p_reference_id VARCHAR2, p_type VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS

BEGIN
   return null;
END GetForwardReference;

--<EC-DOC>
----------------------------------------------------------------------------------------------------
-- Function       : get_note_reference
-- Description    : This function is for finding out if there is a Notes reference for the seleced object
-----------------------------------------------------------------------------------------------------
FUNCTION GetNotesReference(p_reference_id VARCHAR2, p_type VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS

BEGIN
   return null;
END GetNotesReference;

END ue_visual_tracing;