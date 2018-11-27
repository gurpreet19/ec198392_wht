CREATE OR REPLACE TYPE T_REVN_OBJ_INFO AS OBJECT (
    object_code                        VARCHAR2(32)
   ,object_name                        VARCHAR2(240)
   ,object_id                          VARCHAR2(32)
   ,version_date                       DATE
   ,version_end_date                   DATE

    -----------------------------------------------------------------------
    -- Initializes a new T_REVN_OBJ_INFO object.
    ----+----------------------------------+-------------------------------
   ,CONSTRUCTOR FUNCTION T_REVN_OBJ_INFO (
        p_object_code                      VARCHAR2
       ,p_object_name                      VARCHAR2
       ,p_object_id                        VARCHAR2
       ,p_version_date                     DATE
       ,p_version_end_date                 DATE
       )
    RETURN SELF AS RESULT
)
;