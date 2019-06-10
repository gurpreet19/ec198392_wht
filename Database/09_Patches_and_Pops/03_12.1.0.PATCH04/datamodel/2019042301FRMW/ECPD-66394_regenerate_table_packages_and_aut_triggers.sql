DECLARE
BEGIN
    FOR one IN (SELECT trigger_name FROM user_triggers WHERE trigger_name like 'AUT/_%' ESCAPE '/') LOOP
        EXECUTE IMMEDIATE 'DROP TRIGGER ' || one.trigger_name;
    END LOOP;
    Ecdp_Generate.generate(NULL, Ecdp_Generate.PACKAGES + Ecdp_Generate.AUT_TRIGGERS);
END;
/