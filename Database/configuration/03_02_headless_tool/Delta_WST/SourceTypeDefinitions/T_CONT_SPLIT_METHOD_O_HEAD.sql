CREATE OR REPLACE TYPE T_CONT_SPLIT_METHOD_O IS OBJECT
(
    SPLIT_KEY      varchar2(1000),
    SPLIT_KEY_ID   varchar2(1000),
    SPLIT_KEY_ITEM  varchar2(1000),
    OBJECT_LIST    varchar2(1000),
    OBJECT_LIST_ID varchar2(1000),
    OBJ_LIST_TYPE  varchar2(1000),
    OBJECT         varchar2(1000),
    OBJECT_ID      varchar2(1000),
    CLASS_TYPE     varchar2(1000),
    PERCENTAGE      varchar2(1000))