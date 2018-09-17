CREATE OR REPLACE PACKAGE EcBp_Staging_Document IS

  -- Author  : ROSNEDAG
  -- Created : 01.04.2011 10:28:20
  -- Purpose : Processing documents based on staging data.

/*  -- Public type declarations
  type <TypeName> is <Datatype>;

  -- Public constant declarations
  <ConstantName> constant <Datatype> := <Value>;

  -- Public variable declarations
  <VariableName> <Datatype>;
*/


TYPE t_doc_gen_log IS RECORD
  (
  log_item_no      revn_log.log_no%type,
  log_type         revn_log.category%type,
  daytime          DATE,
  cargo_name       cont_transaction.cargo_name%type,
  document_key     cont_document.document_key%type,
  contract_id      contract.object_id%type,
  nav_id           VARCHAR2(2000),
  created_by       revn_log.created_by%type
  );

  -- Public function and procedure declarations
  FUNCTION GenerateDocument(p_contract_id VARCHAR2,
                            p_contract_doc_id VARCHAR2,
                            p_daytime DATE,
                            p_log_item_no NUMBER)
  RETURN VARCHAR2;
-----------------------------------------------------------------------------------------------------------------------------
PROCEDURE WriteLog(p_log_level        VARCHAR2, -- SUMMARY, INFO, WARNING or ERROR
                   p_log_text         VARCHAR2,
                   p_log_item_no      IN OUT NUMBER);
-----------------------------------------------------------------------------------------------------------------------------
PROCEDURE ExceptionHandler(p_object_id       VARCHAR2,
                           p_doc_key         VARCHAR2,
                           p_err_code        NUMBER,
                           p_err_msg         VARCHAR2,
                           p_exception_level VARCHAR2 DEFAULT 'ERROR', -- could be set to WARNING
                           p_delete_doc_ind  VARCHAR2 DEFAULT 'Y',
                           p_log_item_no     IN OUT NUMBER);
-----------------------------------------------------------------------------------------------------------------------------
PROCEDURE SetDocGenStatus(
  p_log_item_no NUMBER,
	p_set_status VARCHAR2);
-----------------------------------------------------------------------------------------------------------------------------
PROCEDURE SetDocStatusCode(p_document_key VARCHAR2,
                           p_status_code VARCHAR2);
-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE RefreshDocument;

-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE InsertFieldSplit(p_ft_st_line_item_no INTEGER);

-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE InsertCompanySplit(p_ft_st_li_dist_no INTEGER);

-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE PreProcessDocument(p_contract_id     VARCHAR2,
                            p_contract_doc_id VARCHAR2,
                            p_daytime         DATE,
                            p_log_item_no     NUMBER);



-----------------------------------------------------------------------------------------------------------------------------

END EcBp_Staging_Document;