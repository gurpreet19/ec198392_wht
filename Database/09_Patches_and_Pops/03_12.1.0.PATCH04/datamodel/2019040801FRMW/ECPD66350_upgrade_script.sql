-- Regenerate all aiudt_ triggers
BEGIN
   FOR one IN ( SELECT table_name, trigger_name FROM user_triggers WHERE trigger_name like 'AIUDT/_%' ESCAPE '/') LOOP
      Ecdp_Generate.Generate(one.table_name, Ecdp_Generate.AIUDT_TRIGGERS);
   END LOOP;
END;
/

-- regenerate object classes
DECLARE
   TYPE varchar_t IS TABLE OF VARCHAR2(15);

   ll_classes  varchar_t;
BEGIN
   ll_classes := varchar_t('FCTY_CLASS_1', 'FCTY_CLASS_2', 'FLOWLINE', 'PIPELINE', 'PRODSEPARATOR', 'STREAM', 'WELL');

   FOR one IN 1 .. ll_classes.COUNT LOOP
      Ecdp_Viewlayer.buildViewLayer(ll_classes(one), p_force => 'Y');
   END LOOP;
END;
/

