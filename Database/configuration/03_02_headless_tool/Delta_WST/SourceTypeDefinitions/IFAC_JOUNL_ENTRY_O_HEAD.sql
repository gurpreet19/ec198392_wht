CREATE OR REPLACE TYPE ifac_jounl_entry_o AS OBJECT
(
  document_type    VARCHAR2(32),
  fin_account_code VARCHAR2(240),
  qty_1            NUMBER,
  amount           NUMBER,
  period           DATE,
  journal_entry_no NUMBER,
  fin_wbs_code     VARCHAR2(240)
);