CREATE OR REPLACE EDITIONABLE TRIGGER "IUD_STOR_SUB_DAY_LIFT_NOM" 
  FOR INSERT OR UPDATE OR DELETE ON STOR_SUB_DAY_LIFT_NOM
  COMPOUND TRIGGER

  TYPE REC_STOR_SUB_DAY_LIFT_NOM IS RECORD(
    parcel_no          STOR_SUB_DAY_LIFT_NOM.parcel_no%TYPE,
    production_day     STOR_SUB_DAY_LIFT_NOM.production_day%TYPE,
    object_id          STOR_SUB_DAY_LIFT_NOM.object_id%TYPE
  );

  TYPE T_STOR_SUB_DAY_LIFT_NOM IS TABLE OF REC_STOR_SUB_DAY_LIFT_NOM;
  ROW_STOR_SUB_DAY_LIFT_NOM T_STOR_SUB_DAY_LIFT_NOM := T_STOR_SUB_DAY_LIFT_NOM();

  --Executed before each row change- :NEW, :OLD are available
  BEFORE EACH ROW IS
  BEGIN
         -- Original IU trigger for BEFORE INSERT OR UPDATE ON STOR_SUB_DAY_LIFT_NOM
         IF INSERTING THEN

          EcDp_Timestamp_Utils.syncUtcDate('STORAGE', :NEW.object_id, :NEW.utc_daytime, :NEW.time_zone, :NEW.daytime, :NEW.summer_time);
          EcDp_Timestamp_Utils.setProductionDay('STORAGE', :NEW.object_id, :NEW.utc_daytime, :NEW.production_day);

          :new.record_status := nvl(:new.record_status, 'P');
          IF :new.created_by IS NULL THEN
             :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
          END IF;
          IF :new.created_date IS NULL THEN
             :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
          END IF;
          :new.rev_no := 0;
        ELSIF UPDATING THEN
          IF Nvl(:new.record_status,'P') = Nvl(:old.record_status,'P') THEN
             IF NOT UPDATING('LAST_UPDATED_BY') THEN
                :new.last_updated_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
             END IF;
             IF NOT UPDATING('LAST_UPDATED_DATE') THEN
               :new.last_updated_date := Ecdp_Timestamp.getCurrentSysdate;
             END IF;
          END IF;
        END IF;
  END BEFORE EACH ROW;

  --Executed aftereach row change- :NEW, :OLD are available
  AFTER EACH ROW IS
  BEGIN
        ROW_STOR_SUB_DAY_LIFT_NOM.EXTEND();
        ROW_STOR_SUB_DAY_LIFT_NOM(ROW_STOR_SUB_DAY_LIFT_NOM.COUNT).parcel_no := nvl(:NEW.PARCEL_NO, :OLD.PARCEL_NO);
        ROW_STOR_SUB_DAY_LIFT_NOM(ROW_STOR_SUB_DAY_LIFT_NOM.COUNT).production_day := nvl(:NEW.PRODUCTION_DAY, :OLD.PRODUCTION_DAY);
        ROW_STOR_SUB_DAY_LIFT_NOM(ROW_STOR_SUB_DAY_LIFT_NOM.COUNT).object_id := nvl(:NEW.OBJECT_ID, :OLD.OBJECT_ID);
  END AFTER EACH ROW;

  --Executed after DML statement
  AFTER STATEMENT IS
  BEGIN
     FOR I IN 1 .. ROW_STOR_SUB_DAY_LIFT_NOM.COUNT() LOOP
        MERGE INTO STOR_SUBDAY_NOM_SUM o
        USING ( SELECT parcel_no, production_day, object_id,
                       SUM(grs_vol_requested) AS grs_vol_requested,
                       SUM(grs_vol_requested2) AS grs_vol_requested2,
                       SUM(grs_vol_requested3) AS grs_vol_requested3,
                       SUM(grs_vol_nominated) AS grs_vol_nominated,
                       SUM(grs_vol_nominated2) AS grs_vol_nominated2,
                       SUM(grs_vol_nominated3) AS grs_vol_nominated3,
                       SUM(grs_vol_schedule) AS grs_vol_schedule,
                       SUM(grs_vol_scheduled2) AS grs_vol_scheduled2,
                       SUM(grs_vol_scheduled3) AS grs_vol_scheduled3,
                       SUM(lifted_qty) AS lifted_qty,
                       SUM(lifted_qty2) AS lifted_qty2,
                       SUM(lifted_qty3) AS lifted_qty3,
                       SUM(unload_qty) AS unload_qty,
                       SUM(unload_qty2) AS unload_qty2,
                       SUM(unload_qty3) AS unload_qty3,
                       SUM(cooldown_qty) AS cooldown_qty,
                       SUM(cooldown_qty2) AS cooldown_qty2,
                       SUM(cooldown_qty3) AS cooldown_qty3,
                       SUM(purge_qty) AS purge_qty,
                       SUM(purge_qty2) AS purge_qty2,
                       SUM(purge_qty3) AS purge_qty3,
                       SUM(vapour_return_qty) AS vapour_return_qty,
                       SUM(vapour_return_qty2) AS vapour_return_qty2,
                       SUM(vapour_return_qty3) AS vapour_return_qty3,
                       SUM(lauf_qty) AS lauf_qty,
                       SUM(lauf_qty2) AS lauf_qty2,
                       SUM(lauf_qty3) AS lauf_qty3,
                       SUM(balance_delta_qty) AS balance_delta_qty,
                       SUM(balance_delta_qty2) AS balance_delta_qty2,
                       SUM(balance_delta_qty3) AS balance_delta_qty3
                FROM STOR_SUB_DAY_LIFT_NOM
               WHERE parcel_no = ROW_STOR_SUB_DAY_LIFT_NOM(I).PARCEL_NO
                 AND production_day = ROW_STOR_SUB_DAY_LIFT_NOM(I).production_day
                 AND object_id = ROW_STOR_SUB_DAY_LIFT_NOM(I).object_id
               GROUP BY parcel_no, production_day, object_id) f
               ON ( o.parcel_no = f.parcel_no
                   AND o.production_day = f.production_day
                   AND o.object_id = f.object_id )
        WHEN MATCHED THEN
          UPDATE SET o.grs_vol_requested  = f.grs_vol_requested
                    ,o.grs_vol_requested2 = f.grs_vol_requested2
                    ,o.grs_vol_requested3 = f.grs_vol_requested3
                    ,o.grs_vol_nominated  = f.grs_vol_nominated
                    ,o.grs_vol_nominated2 = f.grs_vol_nominated2
                    ,o.grs_vol_nominated3 = f.grs_vol_nominated3
                    ,o.grs_vol_schedule   = f.grs_vol_schedule
                    ,o.grs_vol_scheduled2 = f.grs_vol_scheduled2
                    ,o.grs_vol_scheduled3 = f.grs_vol_scheduled3
                    ,o.lifted_qty         = f.lifted_qty
                    ,o.lifted_qty2        = f.lifted_qty2
                    ,o.lifted_qty3        = f.lifted_qty3
                    ,o.unload_qty         = f.unload_qty
                    ,o.unload_qty2        = f.unload_qty2
                    ,o.unload_qty3        = f.unload_qty3
                    ,o.cooldown_qty       = f.cooldown_qty
                    ,o.cooldown_qty2      = f.cooldown_qty2
                    ,o.cooldown_qty3      = f.cooldown_qty3
                    ,o.purge_qty          = f.purge_qty
                    ,o.purge_qty2         = f.purge_qty2
                    ,o.purge_qty3         = f.purge_qty3
                    ,o.vapour_return_qty  = f.vapour_return_qty
                    ,o.vapour_return_qty2 = f.vapour_return_qty2
                    ,o.vapour_return_qty3 = f.vapour_return_qty3
                    ,o.lauf_qty           = f.lauf_qty
                    ,o.lauf_qty2          = f.lauf_qty2
                    ,o.lauf_qty3          = f.lauf_qty3
                    ,o.balance_delta_qty  = f.balance_delta_qty
                    ,o.balance_delta_qty2 = f.balance_delta_qty2
                    ,o.balance_delta_qty3 = f.balance_delta_qty3
         WHEN NOT MATCHED THEN
              INSERT
                (o.parcel_no,
                 o.object_id,
                 o.production_day,
                 o.grs_vol_requested,
                 o.grs_vol_requested2,
                 o.grs_vol_requested3,
                 o.grs_vol_nominated,
                 o.grs_vol_nominated2,
                 o.grs_vol_nominated3,
                 o.grs_vol_schedule,
                 o.grs_vol_scheduled2,
                 o.grs_vol_scheduled3,
                 o.lifted_qty,
                 o.lifted_qty2,
                 o.lifted_qty3,
                 o.unload_qty,
                 o.unload_qty2,
                 o.unload_qty3,
                 o.cooldown_qty,
                 o.cooldown_qty2,
                 o.cooldown_qty3,
                 o.purge_qty,
                 o.purge_qty2,
                 o.purge_qty3,
                 o.vapour_return_qty,
                 o.vapour_return_qty2,
                 o.vapour_return_qty3,
                 o.lauf_qty,
                 o.lauf_qty2,
                 o.lauf_qty3,
                 o.balance_delta_qty,
                 o.balance_delta_qty2,
                 o.balance_delta_qty3)
              VALUES
                (ROW_STOR_SUB_DAY_LIFT_NOM(I).PARCEL_NO,
                 ROW_STOR_SUB_DAY_LIFT_NOM(I).OBJECT_ID,
                 ROW_STOR_SUB_DAY_LIFT_NOM(I).PRODUCTION_DAY,
                 f.grs_vol_requested,
                 f.grs_vol_requested2,
                 f.grs_vol_requested3,
                 f.grs_vol_nominated,
                 f.grs_vol_nominated2,
                 f.grs_vol_nominated3,
                 f.grs_vol_schedule,
                 f.grs_vol_scheduled2,
                 f.grs_vol_scheduled3,
                 f.lifted_qty,
                 f.lifted_qty2,
                 f.lifted_qty3,
                 f.unload_qty,
                 f.unload_qty2,
                 f.unload_qty3,
                 f.cooldown_qty,
                 f.cooldown_qty2,
                 f.cooldown_qty3,
                 f.purge_qty,
                 f.purge_qty2,
                 f.purge_qty3,
                 f.vapour_return_qty,
                 f.vapour_return_qty2,
                 f.vapour_return_qty3,
                 f.lauf_qty,
                 f.lauf_qty2,
                 f.lauf_qty3,
                 f.balance_delta_qty,
                 f.balance_delta_qty2,
                 f.balance_delta_qty3);
   END LOOP;

   -- Delete record in aggregate sum table when no record exists in main table after delete
   DELETE FROM STOR_SUBDAY_NOM_SUM sumtb
    WHERE NOT EXISTS (SELECT 1 FROM STOR_SUB_DAY_LIFT_NOM nomtb
                       WHERE nomtb.parcel_no = sumtb.parcel_no
                         AND nomtb.object_id  = sumtb.object_id
                         AND nomtb.production_day = sumtb.production_day);
  END AFTER STATEMENT;

END;
