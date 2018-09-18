CREATE OR REPLACE TYPE cnt_jounl_entry_o AS OBJECT
(
  journal_entry_no     NUMBER,
  cost_mapping_id      VARCHAR2(32),
  document_key         VARCHAR2(240),
  period               DATE,
  dataset              VARCHAR2(32),
  amount               NUMBER,
  qty_1                NUMBER,
  fin_account_code     VARCHAR2(32),
  fin_cost_center_code VARCHAR2(240),
  fin_wbs_code         VARCHAR2(240),
  ref_journal_entry_no VARCHAR2(1000),
  reversal_date        DATE,
  contract_code        VARCHAR2(32),
  created_date         DATE
);