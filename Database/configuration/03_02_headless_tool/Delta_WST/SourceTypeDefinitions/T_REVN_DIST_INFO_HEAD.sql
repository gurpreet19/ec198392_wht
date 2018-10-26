CREATE OR REPLACE TYPE T_REVN_DIST_INFO IS OBJECT
(    PROFIT_CENTER_ID                      VARCHAR2(32) -- for profit center dist
    ,VENDOR_ID                             VARCHAR2(32) -- for vendor dist
    ,STREAM_ITEM_ID                        VARCHAR2(32)
    ,SPLIT_KEY_ID                          VARCHAR2(32)
    ,CHILD_SPLIT_KEY_ID                    VARCHAR2(32)
    ,SPLIT_SHARE                           NUMBER
    ,DIST_METHOD                           VARCHAR2(32)
);