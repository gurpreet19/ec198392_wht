CREATE OR REPLACE FORCE EDITIONABLE VIEW "RV_INVOICE_TEXT_ITEM" ("COLUMN_1", "COLUMN_2", "COLUMN_3", "TEXT_ITEM_COLUMN_TYPE", "TEXT_ITEM_TYPE", "DOCUMENT_KEY") AS 
  select t.column_1,t.column_2,t.column_3, t.text_item_column_type,t.text_item_type,t.document_key
  from rv_cont_document_text_item t
 ORDER by t.sort_order