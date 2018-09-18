CREATE OR REPLACE TYPE cost_mapp_info_o AS OBJECT
(
  object_code           VARCHAR2(32),
  object_id             VARCHAR2(32),
  daytime               DATE,
  end_date              DATE,
  split_key_id          VARCHAR2(32),
  split_key_code        VARCHAR2(32),
  other_split_item_id   VARCHAR2(32),
  SPLIT_ITEM_OTHER_CODE VARCHAR2(32)
);