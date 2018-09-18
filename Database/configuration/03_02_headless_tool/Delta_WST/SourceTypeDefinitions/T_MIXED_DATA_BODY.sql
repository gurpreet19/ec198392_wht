CREATE OR REPLACE TYPE BODY T_MIXED_DATA AS
    CONSTRUCTOR FUNCTION T_MIXED_DATA (p_key VARCHAR2, p_description VARCHAR2) RETURN SELF AS RESULT
    IS
    BEGIN
        KEY := p_key;
        DESCRIPTION := p_description;
        TEXT_1 := NULL;
        TEXT_2 := NULL;
        TEXT_3 := NULL;
        TEXT_4 := NULL;
        TEXT_5 := NULL;
        TEXT_6 := NULL;
        TEXT_7 := NULL;
        TEXT_8 := NULL;
        TEXT_9 := NULL;
        TEXT_10 := NULL;
        TEXT_11 := NULL;
        TEXT_12 := NULL;
        TEXT_13 := NULL;
        TEXT_14 := NULL;
        TEXT_15 := NULL;
        TEXT_16 := NULL;
        TEXT_17 := NULL;
        TEXT_18 := NULL;
	TEXT_19 := NULL;
	TEXT_20 := NULL;
        DATE_1 := NULL;
        DATE_2 := NULL;
        DATE_3 := NULL;
        DATE_4 := NULL;
        DATE_5 := NULL;
        NUMBER_1 := NULL;
        NUMBER_2 := NULL;
        NUMBER_3 := NULL;
        NUMBER_4 := NULL;
        NUMBER_5 := NULL;

        RETURN;
    END;
END;