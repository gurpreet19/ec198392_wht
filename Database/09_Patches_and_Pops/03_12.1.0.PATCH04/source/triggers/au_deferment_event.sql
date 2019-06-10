CREATE OR REPLACE TRIGGER au_deferment_event
AFTER UPDATE ON DEFERMENT_EVENT
FOR EACH ROW
DECLARE
  ld_ProdDayForNewStDaytime       DATE := EcDp_ProductionDay.getProductionDay('WELL', :new.OBJECT_ID, :new.DAYTIME);
  ld_ProdDayForOldStDaytime       DATE := EcDp_ProductionDay.getProductionDay('WELL', :old.OBJECT_ID, :old.DAYTIME);
  ld_ProdDayForNewEndDaytime      DATE := EcDp_ProductionDay.getProductionDay('WELL', :new.OBJECT_ID, :new.END_DATE);
  ld_ProdDayForOldEndDaytime      DATE := EcDp_ProductionDay.getProductionDay('WELL', :old.OBJECT_ID, :old.END_DATE);
BEGIN
  IF :new.EVENT_NO = :old.EVENT_NO AND
     :new.OBJECT_ID <> :old.OBJECT_ID THEN
    DELETE FROM WELL_DAY_DEFER_ALLOC WHERE EVENT_NO = :new.EVENT_NO;
  END IF;
  IF :new.DAYTIME  > :old.DAYTIME THEN
    FOR m IN TO_NUMBER(TO_CHAR(ld_ProdDayForOldStDaytime, 'J')) .. TO_NUMBER(TO_CHAR(ld_ProdDayForNewStDaytime, 'J')-1) LOOP
      DELETE FROM WELL_DAY_DEFER_ALLOC WHERE EVENT_NO = :new.EVENT_NO AND m = TO_NUMBER(TO_CHAR(DAYTIME, 'J'));
    END LOOP;
  END IF;
  IF :new.END_DATE < :old.END_DATE THEN
    IF :new.END_DATE = ld_ProdDayForNewEndDaytime + (EcDp_ProductionDay.getProductionDayOffset('WELL', :new.OBJECT_ID, :new.END_DATE)/24) THEN
      ld_ProdDayForNewEndDaytime := ld_ProdDayForNewEndDaytime - 1;
    END IF;
    FOR n IN TO_NUMBER(TO_CHAR(ld_ProdDayForNewEndDaytime, 'J')+1) .. TO_NUMBER(TO_CHAR(ld_ProdDayForOldEndDaytime, 'J')) LOOP
      DELETE FROM WELL_DAY_DEFER_ALLOC WHERE EVENT_NO = :new.EVENT_NO AND n = TO_NUMBER(TO_CHAR(DAYTIME, 'J'));
    END LOOP;
  END IF;
END;
/
