BEGIN
    EcDp_Generate.generate(NULL, EcDp_Generate.AIUDT_TRIGGERS);
END;
--~^UTDELIM^~--
BEGIN
   EC_GENERATE.Synchronise;
END;
--~^UTDELIM^~--
BEGIN
    EcDp_Generate.generate(NULL, EcDp_Generate.PACKAGES);
END;
--~^UTDELIM^~--
BEGIN
    EcDp_Generate.generate(NULL, EcDp_Generate.AUT_TRIGGERS);
END;
--~^UTDELIM^~--


DECLARE
BEGIN
  INSERT INTO viewlayer_dirty_log (object_name, dirty_type, dirty_ind)
     SELECT class_name, 'VIEWLAYER', '&DIRTY_FLAG_IND'
     FROM   class_cnfg where class_name!='EC_CODES';

  INSERT INTO viewlayer_dirty_log (object_name, dirty_type, dirty_ind)
     SELECT class_name, 'REPORTLAYER', '&DIRTY_FLAG_IND'
     FROM   class_cnfg where class_name!='EC_CODES';
     
  INSERT INTO viewlayer_dirty_log (dirty_type, dirty_ind, object_name) VALUES ('MATVIEW', 'Y', 'CLASS');
  INSERT INTO viewlayer_dirty_log (dirty_type, dirty_ind, object_name) VALUES ('MATVIEW', 'Y', 'CLASS_ATTRIBUTE');
  INSERT INTO viewlayer_dirty_log (dirty_type, dirty_ind, object_name) VALUES ('MATVIEW', 'Y', 'CLASS_ATTR_DB_MAPPING');
  INSERT INTO viewlayer_dirty_log (dirty_type, dirty_ind, object_name) VALUES ('MATVIEW', 'Y', 'CLASS_ATTR_PRESENTATION');
  INSERT INTO viewlayer_dirty_log (dirty_type, dirty_ind, object_name) VALUES ('MATVIEW', 'Y', 'CLASS_DB_MAPPING');
  INSERT INTO viewlayer_dirty_log (dirty_type, dirty_ind, object_name) VALUES ('MATVIEW', 'Y', 'CLASS_DEPENDENCY');
  INSERT INTO viewlayer_dirty_log (dirty_type, dirty_ind, object_name) VALUES ('MATVIEW', 'Y', 'CLASS_RELATION');
  INSERT INTO viewlayer_dirty_log (dirty_type, dirty_ind, object_name) VALUES ('MATVIEW', 'Y', 'CLASS_REL_DB_MAPPING');
  INSERT INTO viewlayer_dirty_log (dirty_type, dirty_ind, object_name) VALUES ('MATVIEW', 'Y', 'CLASS_REL_PRESENTATION');
  INSERT INTO viewlayer_dirty_log (dirty_type, dirty_ind, object_name) VALUES ('MATVIEW', 'Y', 'CLASS_TRIGGER_ACTION');        
END;
--~^UTDELIM^~--

ALTER TRIGGER AP_STOR_FCST_SUBDAY_NOM_SUM DISABLE
--~^UTDELIM^~--

DECLARE
  lv_cnt                NUMBER;
  lv_grs_vol_requested  NUMBER;
  lv_grs_vol_requested2 NUMBER;
  lv_grs_vol_requested3 NUMBER;
  lv_grs_vol_nominated  NUMBER;
  lv_grs_vol_nominated2 NUMBER;
  lv_grs_vol_nominated3 NUMBER;
  lv_grs_vol_schedule   NUMBER;
  lv_grs_vol_scheduled2 NUMBER;
  lv_grs_vol_scheduled3 NUMBER;
  lv_lifted_qty         NUMBER;
  lv_lifted_qty2        NUMBER;
  lv_lifted_qty3        NUMBER;
  lv_unload_qty         NUMBER;
  lv_unload_qty2        NUMBER;
  lv_unload_qty3        NUMBER;
  lv_cooldown_qty       NUMBER;
  lv_cooldown_qty2      NUMBER;
  lv_cooldown_qty3      NUMBER;
  lv_purge_qty          NUMBER;
  lv_purge_qty2         NUMBER;
  lv_purge_qty3         NUMBER;
  lv_vapour_return_qty  NUMBER;
  lv_vapour_return_qty2 NUMBER;
  lv_vapour_return_qty3 NUMBER;
  lv_lauf_qty           NUMBER;
  lv_lauf_qty2          NUMBER;
  lv_lauf_qty3          NUMBER;
  lv_balance_delta_qty  NUMBER;
  lv_balance_delta_qty2 NUMBER;
  lv_balance_delta_qty3 NUMBER;
  HASENTRY NUMBER;
 
  CURSOR c_sum_out_sub_day(cp_parcel_no      NUMBER,
                           cp_production_day DATE,
                           cp_object_id      VARCHAR2) IS
    SELECT SUM(grs_vol_requested) AS grs_vol_requested,
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
     WHERE parcel_no = cp_parcel_no
       AND production_day = cp_production_day
       AND object_id = cp_object_id;

  cursor c_data is
    select * from STOR_SUB_DAY_LIFT_NOM;
BEGIN
  -- $Revision: 1.1 $
  -- Common
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_STOR_SUBDAY_NOM_SUM'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_STOR_SUBDAY_NOM_SUM DISABLE';
		END IF;
		
  FOR C_SUBDAY IN C_DATA LOOP
    SELECT Count(*)
      INTO lv_cnt
      FROM STOR_SUBDAY_NOM_SUM n
     WHERE parcel_no = C_SUBDAY.parcel_no
       AND production_day = C_SUBDAY.production_day
       AND object_id = C_SUBDAY.object_id;
       
    IF lv_cnt = 0 THEN
      INSERT INTO STOR_SUBDAY_NOM_SUM
        (parcel_no,
         object_id,
         --daytime,
         --summer_time,
         production_day,
         grs_vol_requested,
         grs_vol_requested2,
         grs_vol_requested3,
         grs_vol_nominated,
         grs_vol_nominated2,
         grs_vol_nominated3,
         grs_vol_schedule,
         grs_vol_scheduled2,
         grs_vol_scheduled3,
         lifted_qty,
         lifted_qty2,
         lifted_qty3,
         unload_qty,
         unload_qty2,
         unload_qty3,
         cooldown_qty,
         cooldown_qty2,
         cooldown_qty3,
         purge_qty,
         purge_qty2,
         purge_qty3,
         vapour_return_qty,
         vapour_return_qty2,
         vapour_return_qty3,
         lauf_qty,
         lauf_qty2,
         lauf_qty3,
         balance_delta_qty,
         balance_delta_qty2,
         balance_delta_qty3)
      
      VALUES
        (C_SUBDAY.parcel_no,
         C_SUBDAY.object_id,
         --C_SUBDAY.daytime,
         --C_SUBDAY.summer_time,
         C_SUBDAY.production_day,
         C_SUBDAY.grs_vol_requested,
         C_SUBDAY.grs_vol_requested2,
         C_SUBDAY.grs_vol_requested3,
         C_SUBDAY.grs_vol_nominated,
         C_SUBDAY.grs_vol_nominated2,
         C_SUBDAY.grs_vol_nominated3,
         C_SUBDAY.grs_vol_schedule,
         C_SUBDAY.grs_vol_scheduled2,
         C_SUBDAY.grs_vol_scheduled3,
         C_SUBDAY.lifted_qty,
         C_SUBDAY.lifted_qty2,
         C_SUBDAY.lifted_qty3,
         C_SUBDAY.unload_qty,
         C_SUBDAY.unload_qty2,
         C_SUBDAY.unload_qty3,
         C_SUBDAY.cooldown_qty,
         C_SUBDAY.cooldown_qty2,
         C_SUBDAY.cooldown_qty3,
         C_SUBDAY.purge_qty,
         C_SUBDAY.purge_qty2,
         C_SUBDAY.purge_qty3,
         C_SUBDAY.vapour_return_qty,
         C_SUBDAY.vapour_return_qty2,
         C_SUBDAY.vapour_return_qty3,
         C_SUBDAY.lauf_qty,
         C_SUBDAY.lauf_qty2,
         C_SUBDAY.lauf_qty3,
         C_SUBDAY.balance_delta_qty,
         C_SUBDAY.balance_delta_qty2,
         C_SUBDAY.balance_delta_qty3);
    
    ELSIF lv_cnt >= 1 THEN
      FOR cur_rec IN c_sum_out_sub_day(C_SUBDAY.parcel_no,
                                       C_SUBDAY.production_day,
                                       C_SUBDAY.object_id) LOOP
      
        lv_grs_vol_requested  := cur_rec.grs_vol_requested;
        lv_grs_vol_requested2 := cur_rec.grs_vol_requested2;
        lv_grs_vol_requested3 := cur_rec.grs_vol_requested3;
        lv_grs_vol_nominated  := cur_rec.grs_vol_nominated;
        lv_grs_vol_nominated2 := cur_rec.grs_vol_nominated2;
        lv_grs_vol_nominated3 := cur_rec.grs_vol_nominated3;
        lv_grs_vol_schedule   := cur_rec.grs_vol_schedule;
        lv_grs_vol_scheduled2 := cur_rec.grs_vol_scheduled2;
        lv_grs_vol_scheduled3 := cur_rec.grs_vol_scheduled3;
        lv_lifted_qty         := cur_rec.lifted_qty;
        lv_lifted_qty2        := cur_rec.lifted_qty2;
        lv_lifted_qty3        := cur_rec.lifted_qty3;
        lv_unload_qty         := cur_rec.unload_qty;
        lv_unload_qty2        := cur_rec.unload_qty2;
        lv_unload_qty3        := cur_rec.unload_qty3;
        lv_cooldown_qty       := cur_rec.cooldown_qty;
        lv_cooldown_qty2      := cur_rec.cooldown_qty2;
        lv_cooldown_qty3      := cur_rec.cooldown_qty3;
        lv_purge_qty          := cur_rec.purge_qty;
        lv_purge_qty2         := cur_rec.purge_qty2;
        lv_purge_qty3         := cur_rec.purge_qty3;
        lv_vapour_return_qty  := cur_rec.vapour_return_qty;
        lv_vapour_return_qty2 := cur_rec.vapour_return_qty2;
        lv_vapour_return_qty3 := cur_rec.vapour_return_qty3;
        lv_lauf_qty           := cur_rec.lauf_qty;
        lv_lauf_qty2          := cur_rec.lauf_qty2;
        lv_lauf_qty3          := cur_rec.lauf_qty3;
        lv_balance_delta_qty  := cur_rec.balance_delta_qty;
        lv_balance_delta_qty2 := cur_rec.balance_delta_qty2;
        lv_balance_delta_qty3 := cur_rec.balance_delta_qty3;
      
      END LOOP;
      UPDATE STOR_SUBDAY_NOM_SUM
         SET grs_vol_requested  = lv_grs_vol_requested,
             grs_vol_requested2 = lv_grs_vol_requested2,
             grs_vol_requested3 = lv_grs_vol_requested3,
             grs_vol_nominated  = lv_grs_vol_nominated,
             grs_vol_nominated2 = lv_grs_vol_nominated2,
             grs_vol_nominated3 = lv_grs_vol_nominated3,
             grs_vol_schedule   = lv_grs_vol_schedule,
             grs_vol_scheduled2 = lv_grs_vol_scheduled2,
             grs_vol_scheduled3 = lv_grs_vol_scheduled3,
             lifted_qty         = lv_lifted_qty,
             lifted_qty2        = lv_lifted_qty2,
             lifted_qty3        = lv_lifted_qty3,
             unload_qty         = lv_unload_qty,
             unload_qty2        = lv_unload_qty2,
             unload_qty3        = lv_unload_qty3,
             cooldown_qty       = lv_cooldown_qty,
             cooldown_qty2      = lv_cooldown_qty2,
             cooldown_qty3      = lv_cooldown_qty3,
             purge_qty          = lv_purge_qty,
             purge_qty2         = lv_purge_qty2,
             purge_qty3         = lv_purge_qty3,
             vapour_return_qty  = lv_vapour_return_qty,
             vapour_return_qty2 = lv_vapour_return_qty2,
             vapour_return_qty3 = lv_vapour_return_qty3,
             lauf_qty           = lv_lauf_qty,
             lauf_qty2          = lv_lauf_qty2,
             lauf_qty3          = lv_lauf_qty3,
             balance_delta_qty  = lv_balance_delta_qty,
             balance_delta_qty2 = lv_balance_delta_qty2,
             balance_delta_qty3 = lv_balance_delta_qty3
       WHERE parcel_no = C_SUBDAY.parcel_no
         AND production_day = C_SUBDAY.production_day
         AND object_id = C_SUBDAY.object_id;
    
    END IF;
  END LOOP;
  
  SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_STOR_SUBDAY_NOM_SUM'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_STOR_SUBDAY_NOM_SUM ENABLE';
		END IF;
EXCEPTION
        WHEN OTHERS THEN
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_STOR_SUBDAY_NOM_SUM ENABLE';
		END IF;
         raise_application_error(-20000, 'ERROR: Some Other fatal error occured '||sqlerrm);
END;
--~^UTDELIM^~--

ALTER TRIGGER AP_STOR_FCST_SUBDAY_NOM_SUM ENABLE
--~^UTDELIM^~--

ALTER TRIGGER AP_STOR_SUBDAY_NOM_SUM DISABLE
--~^UTDELIM^~--
DECLARE
  lv_cnt                NUMBER;
  lv_grs_vol_requested  NUMBER;
  lv_grs_vol_requested2 NUMBER;
  lv_grs_vol_requested3 NUMBER;
  lv_grs_vol_nominated  NUMBER;
  lv_grs_vol_nominated2 NUMBER;
  lv_grs_vol_nominated3 NUMBER;
  lv_grs_vol_schedule   NUMBER;
  lv_grs_vol_scheduled2 NUMBER;
  lv_grs_vol_scheduled3 NUMBER;
  lv_cooldown_qty       NUMBER;
  lv_cooldown_qty2      NUMBER;
  lv_cooldown_qty3      NUMBER;
  lv_purge_qty          NUMBER;
  lv_purge_qty2         NUMBER;
  lv_purge_qty3         NUMBER;
  lv_vapour_return_qty  NUMBER;
  lv_vapour_return_qty2 NUMBER;
  lv_vapour_return_qty3 NUMBER;
  lv_lauf_qty           NUMBER;
  lv_lauf_qty2          NUMBER;
  lv_lauf_qty3          NUMBER;
  lv_balance_delta_qty  NUMBER;
  lv_balance_delta_qty2 NUMBER;
  lv_balance_delta_qty3 NUMBER;
  HASENTRY NUMBER;
  CURSOR c_sum_out_sub_day(cp_parcel_no      NUMBER,
                           cp_production_day DATE,
                           cp_forecast_id    VARCHAR2,
                           cp_object_id      VARCHAR2) IS
    SELECT SUM(grs_vol_requested) AS grs_vol_requested,
           SUM(grs_vol_requested2) AS grs_vol_requested2,
           SUM(grs_vol_requested3) AS grs_vol_requested3,
           SUM(grs_vol_nominated) AS grs_vol_nominated,
           SUM(grs_vol_nominated2) AS grs_vol_nominated2,
           SUM(grs_vol_nominated3) AS grs_vol_nominated3,
           SUM(grs_vol_schedule) AS grs_vol_schedule,
           SUM(grs_vol_scheduled2) AS grs_vol_scheduled2,
           SUM(grs_vol_scheduled3) AS grs_vol_scheduled3,
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
      FROM STOR_FCST_SUB_DAY_LIFT_NOM
     WHERE parcel_no = cp_parcel_no
       AND production_day = cp_production_day
       AND forecast_id = cp_forecast_id
       AND object_id = cp_object_id;

  cursor c_data is
    select * from STOR_FCST_SUB_DAY_LIFT_NOM;

BEGIN
  -- $Revision: 1.1 $
  -- Common
		SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_STOR_FCST_SUBDAY_NOM_SUM'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_STOR_FCST_SUBDAY_NOM_SUM DISABLE';
		END IF;
		
  FOR C_SUBDAY IN C_DATA LOOP
    SELECT Count(*)
      INTO lv_cnt
      FROM STOR_FCST_SUBDAY_NOM_SUM n
     WHERE parcel_no = C_SUBDAY.parcel_no
       AND production_day = C_SUBDAY.production_day
       AND forecast_id = C_SUBDAY.forecast_id
       AND object_id = C_SUBDAY.object_id;
  
    IF lv_cnt = 0 THEN
      INSERT INTO STOR_FCST_SUBDAY_NOM_SUM
        (parcel_no,
         forecast_id,
         object_id,
         --daytime,
         --summer_time,
         production_day,
         grs_vol_requested,
         grs_vol_requested2,
         grs_vol_requested3,
         grs_vol_nominated,
         grs_vol_nominated2,
         grs_vol_nominated3,
         grs_vol_schedule,
         grs_vol_scheduled2,
         grs_vol_scheduled3,
         cooldown_qty,
         cooldown_qty2,
         cooldown_qty3,
         purge_qty,
         purge_qty2,
         purge_qty3,
         vapour_return_qty,
         vapour_return_qty2,
         vapour_return_qty3,
         lauf_qty,
         lauf_qty2,
         lauf_qty3,
         balance_delta_qty,
         balance_delta_qty2,
         balance_delta_qty3)
      VALUES
        (C_SUBDAY.parcel_no,
         C_SUBDAY.forecast_id,
         C_SUBDAY.object_id,
         --C_SUBDAY.daytime,
         --C_SUBDAY.summer_time,
         C_SUBDAY.production_day,
         C_SUBDAY.grs_vol_requested,
         C_SUBDAY.grs_vol_requested2,
         C_SUBDAY.grs_vol_requested3,
         C_SUBDAY.grs_vol_nominated,
         C_SUBDAY.grs_vol_nominated2,
         C_SUBDAY.grs_vol_nominated3,
         C_SUBDAY.grs_vol_schedule,
         C_SUBDAY.grs_vol_scheduled2,
         C_SUBDAY.grs_vol_scheduled3,
         C_SUBDAY.cooldown_qty,
         C_SUBDAY.cooldown_qty2,
         C_SUBDAY.cooldown_qty3,
         C_SUBDAY.purge_qty,
         C_SUBDAY.purge_qty2,
         C_SUBDAY.purge_qty3,
         C_SUBDAY.vapour_return_qty,
         C_SUBDAY.vapour_return_qty2,
         C_SUBDAY.vapour_return_qty3,
         C_SUBDAY.lauf_qty,
         C_SUBDAY.lauf_qty2,
         C_SUBDAY.lauf_qty3,
         C_SUBDAY.balance_delta_qty,
         C_SUBDAY.balance_delta_qty2,
         C_SUBDAY.balance_delta_qty3);
    ELSIF lv_cnt >= 1 THEN
      FOR cur_rec IN c_sum_out_sub_day(C_SUBDAY.parcel_no,
                                       C_SUBDAY.production_day,
                                       C_SUBDAY.forecast_id,
                                       C_SUBDAY.object_id) LOOP
      
        lv_grs_vol_requested  := cur_rec.grs_vol_requested;
        lv_grs_vol_requested2 := cur_rec.grs_vol_requested2;
        lv_grs_vol_requested3 := cur_rec.grs_vol_requested3;
        lv_grs_vol_nominated  := cur_rec.grs_vol_nominated;
        lv_grs_vol_nominated2 := cur_rec.grs_vol_nominated2;
        lv_grs_vol_nominated3 := cur_rec.grs_vol_nominated3;
        lv_grs_vol_schedule   := cur_rec.grs_vol_schedule;
        lv_grs_vol_scheduled2 := cur_rec.grs_vol_scheduled2;
        lv_grs_vol_scheduled3 := cur_rec.grs_vol_scheduled3;
        lv_cooldown_qty       := cur_rec.cooldown_qty;
        lv_cooldown_qty2      := cur_rec.cooldown_qty2;
        lv_cooldown_qty3      := cur_rec.cooldown_qty3;
        lv_purge_qty          := cur_rec.purge_qty;
        lv_purge_qty2         := cur_rec.purge_qty2;
        lv_purge_qty3         := cur_rec.purge_qty3;
        lv_vapour_return_qty  := cur_rec.vapour_return_qty;
        lv_vapour_return_qty2 := cur_rec.vapour_return_qty2;
        lv_vapour_return_qty3 := cur_rec.vapour_return_qty3;
        lv_lauf_qty           := cur_rec.lauf_qty;
        lv_lauf_qty2          := cur_rec.lauf_qty2;
        lv_lauf_qty3          := cur_rec.lauf_qty3;
        lv_balance_delta_qty  := cur_rec.balance_delta_qty;
        lv_balance_delta_qty2 := cur_rec.balance_delta_qty2;
        lv_balance_delta_qty3 := cur_rec.balance_delta_qty3;
      
      END LOOP;
      UPDATE STOR_FCST_SUBDAY_NOM_SUM
         SET grs_vol_requested  = lv_grs_vol_requested,
             grs_vol_requested2 = lv_grs_vol_requested2,
             grs_vol_requested3 = lv_grs_vol_requested3,
             grs_vol_nominated  = lv_grs_vol_nominated,
             grs_vol_nominated2 = lv_grs_vol_nominated2,
             grs_vol_nominated3 = lv_grs_vol_nominated3,
             grs_vol_schedule   = lv_grs_vol_schedule,
             grs_vol_scheduled2 = lv_grs_vol_scheduled2,
             grs_vol_scheduled3 = lv_grs_vol_scheduled3,
             cooldown_qty       = lv_cooldown_qty,
             cooldown_qty2      = lv_cooldown_qty2,
             cooldown_qty3      = lv_cooldown_qty3,
             purge_qty          = lv_purge_qty,
             purge_qty2         = lv_purge_qty2,
             purge_qty3         = lv_purge_qty3,
             vapour_return_qty  = lv_vapour_return_qty,
             vapour_return_qty2 = lv_vapour_return_qty2,
             vapour_return_qty3 = lv_vapour_return_qty3,
             lauf_qty           = lv_lauf_qty,
             lauf_qty2          = lv_lauf_qty2,
             lauf_qty3          = lv_lauf_qty3,
             balance_delta_qty  = lv_balance_delta_qty,
             balance_delta_qty2 = lv_balance_delta_qty2,
             balance_delta_qty3 = lv_balance_delta_qty3
       WHERE parcel_no = C_SUBDAY.parcel_no
         AND production_day = C_SUBDAY.production_day
         AND forecast_id = C_SUBDAY.forecast_id
         AND object_id = C_SUBDAY.object_id;
    END IF;
  END LOOP;
   SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_STOR_FCST_SUBDAY_NOM_SUM'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_STOR_FCST_SUBDAY_NOM_SUM ENABLE';
		END IF;
EXCEPTION
        WHEN OTHERS THEN
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_STOR_FCST_SUBDAY_NOM_SUM ENABLE';
		END IF;
         raise_application_error(-20000, 'ERROR: Some Other fatal error occured '||sqlerrm);
END;
--~^UTDELIM^~--

ALTER TRIGGER AP_STOR_SUBDAY_NOM_SUM ENABLE
--~^UTDELIM^~--
DECLARE
BEGIN	   	   
	EcDp_Generate.generate('CLASS_ATTRIBUTE_CNFG', EcDp_Generate.ALL_TRIGGERS+EcDp_Generate.PACKAGES);	
	EcDp_Generate.generate('CLASS_ATTR_PROPERTY_CNFG',EcDp_Generate.PACKAGES);
	EXCEPTION WHEN OTHERS THEN null;
END;
--~^UTDELIM^~--  

begin
  for c in (
    select table_name from user_tables
      where table_name in
      (
        'PROD_AREA_FORECAST',
        'PROD_FCTY_FORECAST',
        'PROD_FIELD_FORECAST',
        'PROD_PRODUNIT_FORECAST',
        'PROD_STORAGE_FORECAST',
        'PROD_STRM_FORECAST',
        'PROD_SUB_AREA_FORECAST',
        'PROD_SUB_FIELD_FORECAST',
        'PROD_WELL_FORECAST',
        'PROD_FORECAST'         
    ) )
    LOOP 
    EcDp_Generate.generate(c.table_name,EcDp_Generate.AP_TRIGGERS);
    END LOOP;
END;
--~^UTDELIM^~--  

declare
  cursor c_tst is
    select object_name
      from user_objects
     where object_name IN ( 'PROD_AREA_FORECAST', 
        'PROD_FIELD_FORECAST',
        'PROD_PRODUNIT_FORECAST',
        'PROD_FORECAST',
        'PROD_STORAGE_FORECAST',
        'PROD_SUB_AREA_FORECAST',
        'PROD_SUB_FIELD_FORECAST',
        'PROD_WELL_FORECAST',
        'QRTZ_CRON_TRIGGERS');

begin
  for i in c_tst loop
    EcDp_Generate.generate(i.object_name,EcDp_Generate.JN_TRIGGERS);
  end loop;
end;
--~^UTDELIM^~--  

-- Manually Updating Dirty Ind flag of some of the classes since there were changes in dependent classes and by default buildViewLayer was not generating view layer for these classes 
BEGIN
	UPDATE VIEWLAYER_DIRTY_LOG SET DIRTY_IND = 'Y' WHERE OBJECT_NAME= 'CURRENCY';
	UPDATE VIEWLAYER_DIRTY_LOG SET DIRTY_IND = 'Y' WHERE OBJECT_NAME= 'CALENDAR_COLLECTION';
	UPDATE VIEWLAYER_DIRTY_LOG SET DIRTY_IND = 'Y' WHERE OBJECT_NAME= 'DELIVERY_POINT';
	UPDATE VIEWLAYER_DIRTY_LOG SET DIRTY_IND = 'Y' WHERE OBJECT_NAME= 'DOC_DATE_TERM';
	UPDATE VIEWLAYER_DIRTY_LOG SET DIRTY_IND = 'Y' WHERE OBJECT_NAME= 'DOC_RECEIVED_TERM';
	UPDATE VIEWLAYER_DIRTY_LOG SET DIRTY_IND = 'Y' WHERE OBJECT_NAME= 'DOC_SEQUENCE';
	UPDATE VIEWLAYER_DIRTY_LOG SET DIRTY_IND = 'Y' WHERE OBJECT_NAME= 'PAYMENT_SCHEME';
	UPDATE VIEWLAYER_DIRTY_LOG SET DIRTY_IND = 'Y' WHERE OBJECT_NAME= 'PAYMENT_TERM';
	UPDATE VIEWLAYER_DIRTY_LOG SET DIRTY_IND = 'Y' WHERE OBJECT_NAME= 'PORT';
	
	UPDATE VIEWLAYER_DIRTY_LOG SET DIRTY_IND = 'Y' WHERE OBJECT_NAME= 'ALLOC_NODE';	
	UPDATE VIEWLAYER_DIRTY_LOG SET DIRTY_IND = 'Y' WHERE OBJECT_NAME= 'ALLOC_PRICE_OBJECT';
	UPDATE VIEWLAYER_DIRTY_LOG SET DIRTY_IND = 'Y' WHERE OBJECT_NAME= 'ALLOC_STREAM';
	UPDATE VIEWLAYER_DIRTY_LOG SET DIRTY_IND = 'Y' WHERE OBJECT_NAME= 'GEOGRAPHICAL_AREA';
	UPDATE VIEWLAYER_DIRTY_LOG SET DIRTY_IND = 'Y' WHERE OBJECT_NAME= 'SCHEDULE_ADVANCED';
	UPDATE VIEWLAYER_DIRTY_LOG SET DIRTY_IND = 'Y' WHERE OBJECT_NAME= 'SCHEDULE_CRON';
	UPDATE VIEWLAYER_DIRTY_LOG SET DIRTY_IND = 'Y' WHERE OBJECT_NAME= 'SCHEDULE_DAILY';
	UPDATE VIEWLAYER_DIRTY_LOG SET DIRTY_IND = 'Y' WHERE OBJECT_NAME= 'SCHEDULE_MONTHLY';
	UPDATE VIEWLAYER_DIRTY_LOG SET DIRTY_IND = 'Y' WHERE OBJECT_NAME= 'SCHEDULE_ONCE';
	UPDATE VIEWLAYER_DIRTY_LOG SET DIRTY_IND = 'Y' WHERE OBJECT_NAME= 'SCHEDULE_SUB_DAILY';
	UPDATE VIEWLAYER_DIRTY_LOG SET DIRTY_IND = 'Y' WHERE OBJECT_NAME= 'SCHEDULE_WEEKLY';
	UPDATE VIEWLAYER_DIRTY_LOG SET DIRTY_IND = 'Y' WHERE OBJECT_NAME= 'SCHEDULE_WHEN';
	UPDATE VIEWLAYER_DIRTY_LOG SET DIRTY_IND = 'Y' WHERE OBJECT_NAME= 'SCHEDULE_YEARLY';
	
	UPDATE VIEWLAYER_DIRTY_LOG SET DIRTY_IND = 'Y' WHERE OBJECT_NAME= 'PDD_DAY_DATA'; 
	UPDATE VIEWLAYER_DIRTY_LOG SET DIRTY_IND = 'Y' WHERE OBJECT_NAME= 'PDAY_DST';
END;
--~^UTDELIM^~--
