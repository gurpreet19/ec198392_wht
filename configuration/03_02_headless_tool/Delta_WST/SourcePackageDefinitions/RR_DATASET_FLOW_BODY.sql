CREATE OR REPLACE PACKAGE BODY RR_DATASET_FLOW IS
PROCEDURE INIT IS
  BEGIN
  NULL;
END;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- FUNCTION       : getMappingScreen
-- Description    :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION getMappingScreen( p_return VARCHAR2,
                           p_mapping_type VARCHAR2,
                           p_direction VARCHAR2,
                           p_type varchar2 default null,
                           p_other_type varchar2 default null,
                           p_other_ref_id VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
IS
  lv_return VARCHAR2(4000) := p_return;

BEGIN
  return lv_return;
END getMappingScreen;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- FUNCTION       : getObjectText
-- Description    :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION getObjectText(p_return      VARCHAR2,
                       p_ref_id VARCHAR2,
                       p_mapping_type VARCHAR2,
                       p_object_id    VARCHAR2,
                       p_daytime      DATE) RETURN VARCHAR2
IS
  lv_return VARCHAR2(4000) := p_return;

BEGIN
  return lv_return;
END;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- FUNCTION       : GetDocStatus
-- Description    :
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetDocStatus(p_type                                VARCHAR2,
                      p_reference_id                        VARCHAR2,
                      p_status                              VARCHAR2) RETURN VARCHAR2
                      is
lv_status VARCHAR2(4000) := p_status;

BEGIN

  return lv_status;
END;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- PROCEDURE       : InsRRCAToDsFlowDoc
-- Description    :  Called from UpdateRRCARoyRateStatus
------------------------+-----------------------------------+------------------------------------+---------------------------
PROCEDURE InsRRCAToDsFlowDoc(p_type            VARCHAR2,
                             p_process_date    DATE,
                             p_object          VARCHAR2,
                             p_reference_id    VARCHAR2,
                             p_status          VARCHAR2,
                             p_max_ind         VARCHAR2,
                             p_dataset         VARCHAR2,
                             p_accrual_ind     VARCHAR2,
                             p_screen_doc_type VARCHAR2 DEFAULT NULL) IS

BEGIN
 NULL;
END;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- PROCEDURE       : InsToDsFlowDoc
-- Description    :
------------------------+-----------------------------------+------------------------------------+---------------------------
PROCEDURE InsToDsFlowDoc(p_type            VARCHAR2,
                         p_process_date    DATE,
                         p_object          VARCHAR2,
                         p_reference_id    VARCHAR2,
                         p_status          VARCHAR2,
                         p_max_ind         VARCHAR2,
                         p_dataset         VARCHAR2,
                         p_accrual_ind     VARCHAR2,
                         p_screen_doc_type VARCHAR2 DEFAULT NULL) IS

BEGIN
  NULL;
END;


------------------------+-----------------------------------+------------------------------------+---------------------------
-- PROCEDURE       : Delete
-- Description    :  Delete from tracing tables
------------------------+-----------------------------------+------------------------------------+---------------------------
PROCEDURE Delete(p_type      VARCHAR2,
                 p_doc_id    VARCHAR2,
                 p_object_id VARCHAR2,
                 p_clean     VARCHAR2 DEFAULT 'N',
                 p_status    VARCHAR2)
IS
BEGIN
  NULL;

END;


------------------------+-----------------------------------+------------------------------------+---------------------------
-- FUNCTION       : UpdateStatusInTables
-- Description    : Will update record status in the main table if needed
------------------------+-----------------------------------+------------------------------------+---------------------------
PROCEDURE UpdateStatusInTables(p_type         VARCHAR2,
                               p_reference_id VARCHAR2,
                               p_status       VARCHAR2,
                               p_user         VARCHAR2) IS
BEGIN

NULL;
END;


------------------------+-----------------------------------+------------------------------------+---------------------------
-- FUNCTION       : UpdateRRCARoyRateStatus
-- Description    : Called from r_rrca_roy_calc.verifyActual|unVerifyActual|verifyAccrual|unVerifyAccrual
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION UpdateRRCARoyRateStatus(p_type            VARCHAR2,
                                 p_reference_id    VARCHAR2,
                                 p_status          VARCHAR2,
                                 p_process_date    DATE,
                                 p_accrual_ind     VARCHAR2,
                                 p_user            VARCHAR2,
                                 p_no_table_update BOOLEAN DEFAULT FALSE,
                                 p_old_status      VARCHAR2 DEFAULT NULL,
                                 p_allow_unapprove BOOLEAN DEFAULT FALSE)
  RETURN VARCHAR2
IS
v_result   VARCHAR2(500) := '';

BEGIN

RETURN v_result;

END;

END;