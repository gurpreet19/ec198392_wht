CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FI_DATASET_VALUE" ("CODE", "DATASET_VALUE", "CODE_TEXT", "SORT_ORDER") AS 
  SELECT fid.code,
      'DATASET_VALUE_'||ROWNUM dataset_value,
      fid.code_text,
      fid.sort_order
 FROM (SELECT *
        FROM prosty_codes
       WHERE code_type = 'FIN_ITEM_DATASET'
       ORDER BY sort_order
      ) fid