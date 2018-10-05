CREATE OR REPLACE TYPE T_JOURNAL_ENTRY_REF_INFO IS OBJECT
(
     root_journal_entry_no  NUMBER,
     root_journal_entry_source  VARCHAR2(4),
     journal_entry_no NUMBER,
     journal_entry_source VARCHAR2(4),
     ref_journal_entry_no VARCHAR2(1000),
     ref_journal_entry_source VARCHAR2(32),
     sort_order NUMBER
);