CREATE OR REPLACE TYPE BODY T_REVN_OBJ_INFO AS
    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    CONSTRUCTOR FUNCTION T_REVN_OBJ_INFO(
         p_object_code                     VARCHAR2
        ,p_object_name                     VARCHAR2
        ,p_object_id                       VARCHAR2
        ,p_version_date                    DATE
        ,p_version_end_date                DATE
        )
    RETURN SELF AS RESULT
    IS
    BEGIN
       object_code := p_object_code;
       object_name := p_object_name;
       object_id := p_object_id;
       version_date := p_version_date;
       version_end_date := p_version_end_date;

       RETURN;
    END;
END;