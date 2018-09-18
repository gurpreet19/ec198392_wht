CREATE OR REPLACE TYPE sumry_doc_cont_o AS OBJECT
(
  contract_id         VARCHAR2(32),
  contract_code       VARCHAR2(32),
  period              DATE,
  tag                 VARCHAR2(240),
  summary_doc_key     VARCHAR2(32),
  list_item_key       VARCHAR2(32),
  Summary_setup_id    VARCHAR2(32),
  Actual_amount       NUMBER,
  ACTUAL_QTY_1        NUMBER,
  label               VARCHAR2(240),
  SOURCE_TIME_CONCEPT VARCHAR2(32),
  TARGET_TIME_CONCEPT VARCHAR2(32),
  cjs_fin_account     VARCHAR2(32),
  cjs_fin_cost_center VARCHAR2(32),
  cjs_fin_wbs         VARCHAR2(32),
  ssl_fin_account     VARCHAR2(32),
  ssl_fin_wbs         VARCHAR2(32),
  ssl_fin_cost_center VARCHAR2(32),
  ssl_dataset         VARCHAR2(240),
  summary_setup_code  VARCHAR2(32)
);