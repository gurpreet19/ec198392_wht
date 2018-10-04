CREATE OR REPLACE TYPE T_MIXED_DATA AS OBJECT
(
     KEY                 VARCHAR2(240)
    ,DESCRIPTION         VARCHAR2(240)
    ,TEXT_1              VARCHAR2(240)
    ,TEXT_2              VARCHAR2(240)
    ,TEXT_3              VARCHAR2(240)
    ,TEXT_4              VARCHAR2(240)
    ,TEXT_5              VARCHAR2(240)
    ,TEXT_6              VARCHAR2(240)
    ,TEXT_7              VARCHAR2(240)
    ,TEXT_8              VARCHAR2(240)
    ,TEXT_9              VARCHAR2(240)
    ,TEXT_10             VARCHAR2(240)
    ,TEXT_11             VARCHAR2(240)
    ,TEXT_12             VARCHAR2(240)
    ,TEXT_13             VARCHAR2(240)
    ,TEXT_14             VARCHAR2(240)
    ,TEXT_15             VARCHAR2(240)
    ,TEXT_16             VARCHAR2(240)
    ,TEXT_17             VARCHAR2(240)
    ,TEXT_18             VARCHAR2(240)
    ,TEXT_19             VARCHAR2(240)
    ,TEXT_20             VARCHAR2(240)
    ,DATE_1              DATE
    ,DATE_2              DATE
    ,DATE_3              DATE
    ,DATE_4              DATE
    ,DATE_5              DATE
    ,NUMBER_1            NUMBER
    ,NUMBER_2            NUMBER
    ,NUMBER_3            NUMBER
    ,NUMBER_4            NUMBER
    ,NUMBER_5            NUMBER
    ,CONSTRUCTOR FUNCTION T_MIXED_DATA (p_key VARCHAR2, p_description VARCHAR2) RETURN SELF AS RESULT
)
;