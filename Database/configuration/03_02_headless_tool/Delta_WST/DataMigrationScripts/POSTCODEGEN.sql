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

begin
  for c in (
    select table_name from user_tables
      where table_name in
      (
		'WELL_VERSION', 'STOR_VERSION', 'TANK_VERSION', 'WELL_HOOKUP_VERSION', 'CHEM_TANK_VERSION', 'FCTY_VERSION',
         'PIPE_VERSION', 'SEPA_VERSION', 'FLWL_VERSION', 'STRM_VERSION', 'EQPM_VERSION', 'TEST_DEVICE_VERSION',
		 'CNTR_DAY_CAP_TRADE','ITST_DEFINITION','ITST_RESULT','IWEL_RESULT','NOMPNT_NP_DAY_DELIVERY','WBI_INJ_SAMPLE'
		) )
    LOOP
	  EcDp_Generate.generate(c.table_name,EcDp_Generate.AUT_TRIGGERS);
	  
    END LOOP;
END;
--~^UTDELIM^~--  

begin
   EcDp_Generate.generate(NULL, EcDp_Generate.AIUDT_TRIGGERS);
end;
--~^UTDELIM^~--
  
begin
   EcDp_Generate.generate('SND_GROUP', EcDp_Generate.JN_TRIGGERS);
end;
--~^UTDELIM^~--

begin
	update viewlayer_dirty_log v set v.dirty_ind='Y' where v.object_name in
	(
		'ALLOC_NETWORK',
		'BALANCE',
		'BANK',
		'BANK_ACCOUNT',
		'BLEND',
		'CALC_CONTEXT',
		'CALC_GRP_CONTEXT',
		'CALC_LIBRARY',
		'CALC_PROCESS_ELEMENT',
		'CALC_PROCESS_TRANSITION',
		'CALC_RULE',
		'CALCULATION',
		'CANAL',
		'CHOKE',
		'COMMERCIAL_ENTITY',
		--'COMPANY',
		'COMPANY_CONTACT',
		'CONFIG_VARIABLE',
		'CONFIG_VARIABLE_PARAM',
		'CONSTANT_STANDARD',
		'CONTACT_GROUP',
		'CONTACT_GROUP_SET',
		--'CONTRACT',
		'CONTRACT_AREA_SETUP',
		'CONTRACT_DOC',
		'CONTRACT_GROUP',
		'CONTRACT_TEXT_ITEM',
		'CONTROL_POINT',
		'CONVERSION_GROUP',
		'COST_MAPPING',
		'COUNTY',
		'CURRENCY',
		'CUSTOMER',
		'DEFERMENT_GROUP',
		'DISPOSITION_TYPE',
		'DOC_SEQUENCE',
		'DOC_TEMPLATE',
		'DUMMY_TAG_EVENT',
		'EC_CODE_OBJECT',
		'EXTERNAL_LOCATION',
		--'FCTY_CLASS_1',
		'FIELD_GROUP',
		'FIN_ACCOUNT',
		'FIN_ACCOUNT_MAP_NAV',
		'FIN_ACCOUNT_MAPPING',
		'FIN_COST_CENTER',
		'FIN_COST_OBJECT',
		'FIN_ITEM_GROUP',
		'FIN_REVENUE_ORDER',
		'FIN_UOP_DEPR_KEY',
		'FIN_WBS',
		'FORECAST',
		'FORECAST_SALE_PR',
		'FORECAST_SALE_SA',
		'FORECAST_SALE_SD',
		'FORECAST_TRAN_CP',
		'FORECAST_TRAN_FC',
		'FUNCTIONAL_AREA',
		'IMP_WELL_CI_STREAM',
		'IMP_WELL_CO2_STREAM',
		'IMP_WELL_CP_STREAM',
		'IMP_WELL_DL_STREAM',
		'IMP_WELL_GI_STREAM',
		'IMP_WELL_GL_STREAM',
		'IMP_WELL_GP_STREAM',
		'IMP_WELL_OP_STREAM',
		'IMP_WELL_SI_STREAM',
		'IMP_WELL_WI_STREAM',
		'IMP_WELL_WP_STREAM',
		'INV_FIELD_PRICE_OBJ',
		--'INVENTORY',
		--'INVENTORY_AREA',
		'INVENTORY_FIELD',
		'INVENTORY_PRICE_OBJECT',
		'LICENCE',
		'LIFTING_ACCOUNT',
		'LINE_ITEM_TEMPLATE',
		'MESSAGE_CONTACT',
		'MESSAGE_DEFINITION',
		'MESSAGE_GROUP',
		'MMS_LEASE',
		'OBJECT_LIST',
		'OPERATOR_LEASE',
		'PAYMENT_SCHEME',
		'PRICE_GROUP',
		'PROCESS_TRAIN',
		'PROD_STREAM_GROUP',
		'PRODUCT_COUNTRY',
		'PRODUCT_COUNTRY_BOE',
		'PRODUCT_FIELD',
		'PRODUCT_FIELD_BOE',
		'PRODUCT_NODE',
		'PRODUCT_NODE_BOE',
		'PRODUCT_SALES_ORDER',
		'PRODUCTION_DAY',
		'QB_REPORT_VIEW',
		'REGION',
		'REGULATORY_PERMITS',
		'REPORT_AREA',
		'REPORT_GROUP',
		'REPORT_REF_GROUP',
		'REPORT_REF_ITEM',
		'REPORT_REFERENCE',
		'REPT_CONTEXT',
		'RESV_BLOCK',
		'RESV_FORMATION',
		'REVN_DATA_FILTER',
		'ROYALTY_DEPOSITOR',
		'ROYALTY_OWNER',
		'SND_WELL_GROUP_STREAM',
		'SOURCE_SYSTEM',
		'SPLIT_ITEM_OTHER',
		'SPLIT_KEY',
		'STATE',
		'STATE_LEASE',
		'STREAM_CATEGORY',
		'STREAM_ITEM_CATEGORY',
		'STREAM_ITEM_COLLECTION',
		'SUB_FIELD',
		'SUMMARY_SET',
		'SUMMARY_SETUP',
		'TASK_PROCESS',
		--'TRACT',
		'TRANS_INV_TMPL_SET',
		'TRANS_INVENTORY',
		'TRANSPORT_ZONE_LIST',
		'VAT_CODE',
		'VENDOR',
		'WELL_BORE_INTERVAL',
		'IMP_SOURCE_INTERFACE',
		'REPORT_DEFINITION_GROUP'
	)
	and v.dirty_type in ('VIEWLAYER') and v.dirty_ind='N';
end;
--~^UTDELIM^~--

begin
	update viewlayer_dirty_log v set v.dirty_ind='Y' where v.object_name in
	(
		'DEFER_LOSS_STRM_EVENT',
		'FCST_IWEL_DAY_ALLOC',
		'FCST_IWEL_DAY_COMP_ALLOC',
		'FCST_IWEL_MTH_ALLOC',
		'FCST_IWEL_MTH_COMP_ALLOC',
		'FCST_POTENTIAL_VOLUME',
		'FCST_PWEL_DAY_ALLOC',
		'FCST_PWEL_DAY_COMP_ALLOC',
		'FCST_PWEL_MTH_ALLOC',
		'FCST_PWEL_MTH_COMP_ALLOC',
		'FCST_SLNP_PRD_DEL_EVT_NL',
		'FCST_SP_DAY_AFS',
		'FCST_SP_DAY_AFS_GRAPH',
		'FCST_SP_DAY_AFS_LIST',
		'FCST_SP_DAY_AFS_OVERVIEW',
		'FCST_SP_DAY_CPY_AFS',
		'FCST_VOLUME',
		'FCST_WELL_DAY_AFS_ALLOC',
		'FCST_WELL_DAY_CPY_AFS_AL',
		'FLOWLINE_WELL_CONN',
		'FLWL_FORM_ION_ANALYSIS',
		'FLWL_INJ_ION_ANALYSIS',
		'FLWL_PROD_ION_ANALYSIS',
		'FLWL_SUB_DAY_ALLOC',
		'IFLW_SUB_DAY_DATA',
		'IWEL_ANALYSIS_DATA_GAS',
		'IWEL_DAY_ALLOC',
		'IWEL_DAY_ALLOC_GAS',
		'IWEL_DAY_ALLOC_STEAM',
		'IWEL_DAY_ALLOC_WATER',
		'IWEL_DAY_COMP_ALLOC',
		'IWEL_DAY_COMP_DATA_GAS',
		'IWEL_DAY_DATA',
		'IWEL_DAY_PREC_DATA',
		'IWEL_DAY_PROD_ALLOC',
		'IWEL_DAY_STATUS_AIR',
		'IWEL_DAY_STATUS_CO2',
		'IWEL_DAY_STATUS_STEAM',
		'IWEL_EVENT_GAS',
		'IWEL_EVENT_GAS_TOTALIZER',
		'IWEL_EVENT_GAS_UE',
		'IWEL_EVENT_GAS_VOLUME',
		'IWEL_EVENT_STEAM',
		'IWEL_EVENT_STM_TOTALIZER',
		'IWEL_EVENT_STM_UE',
		'IWEL_EVENT_STM_VOLUME',
		'IWEL_EVENT_WAT_TOTALIZER',
		'IWEL_EVENT_WAT_UE',
		'IWEL_EVENT_WAT_VOLUME',
		'IWEL_EVENT_WATER',
		'IWEL_GAS_DATA',
		'IWEL_MTH_ALLOC',
		'IWEL_MTH_ALLOC_GAS',
		'IWEL_MTH_ALLOC_STEAM',
		'IWEL_MTH_ALLOC_WATER',
		'IWEL_MTH_COMP_ALLOC',
		'IWEL_MTH_CPY_ALLOC',
		'IWEL_MTH_PROD_ALLOC',
		'IWEL_MTH_STATUS_GAS',
		'IWEL_MTH_STATUS_STEAM',
		'IWEL_MTH_STATUS_WATER',
		'IWEL_PERIOD_LAST_STATUS',
		'IWEL_SND_DATA',
		'IWEL_SUB_DAY_DATA',
		'IWEL_SUB_DAY_STATUS_STM',
		'IWEL_TOTALIZER_GAS',
		'IWEL_TOTALIZER_WAT',
		'IWEL_WATER_DATA',
		'PFLW_SUB_DAY_DATA',
		'PTST_PWEL_RESULT',
		'PTST_PWEL_RESULT_DATA',
		'PTST_PWEL_SINGLE_RES',
		'PWEL_ANALYSIS_DATA_F_GAS',
		'PWEL_ANALYSIS_DATA_GAS',
		'PWEL_ANALYSIS_DATA_OIL',
		'PWEL_DAY_ALLOC',
		'PWEL_DAY_COENT_ALLOC',
		'PWEL_DAY_COENT_DATA',
		'PWEL_DAY_COMP_ALLOC',
		'PWEL_DAY_COMP_DATA_F_GAS',
		'PWEL_DAY_COMP_DATA_GAS',
		'PWEL_DAY_COMP_DATA_OIL',
		'PWEL_DAY_DATA',
		'PWEL_DAY_PREC_DATA',
		'PWEL_DAY_PROD_ALLOC',
		'PWEL_DAY_STATUS',
		'PWEL_DAY_STATUS_OW',
		'PWEL_DAY_STATUS_WS',
		'PWEL_ESTIMATE',
		'PWEL_EVENT_INVENTORY',
		'PWEL_MTH_ALLOC',
		'PWEL_MTH_COMP_ALLOC',
		'PWEL_MTH_CPY_ALLOC',
		'PWEL_MTH_PROD_ALLOC',
		'PWEL_MTH_PROD_CP_ALLOC',
		'PWEL_MTH_STATUS',
		'PWEL_PERIOD_LAST_STATUS',
		'PWEL_RESULT',
		'PWEL_SND_DATA',
		'PWEL_SUB_DAY_ALLOC',
		'PWEL_SUB_DAY_DATA',
		'PWEL_SUB_DAY_VALID',
		'PWEL_TOTALIZER_GAS',
		'PWEL_TOTALIZER_LIQ',
		'STRM_DAY_STREAM_DER_NGL',
		'STRM_DAY_STREAM_LOSS',
		'STRM_DAY_STREAM_MEAS_NGL',
		'STRM_MTH_NGL',
		'STRM_MTH_STREAM_DER_NGL',
		'TANK_DAY_INV_VOL',
		'WELL_ANALYSIS',
		'WELL_BLOWDOWN_DATA',
		'WELL_BLOWDOWN_EVENT',
		'WELL_CHEM_ANALYSIS',
		'WELL_COMP_ANALYSIS',
		'WELL_DAY_DISP_ALLOC',
		'WELL_DAY_DISP_ALLOC_GAS',
		'WELL_DAY_DISP_ALLOC_LIQ',
		'WELL_DAY_DISP_CP_ALLOC',
		'WELL_DAY_STRM_ALLOC',
		'WELL_DAY_STRM_COMP_ALLOC',
		'WELL_DECLINE',
		'WELL_DEF_DAY_DATA',
		'WELL_DEF_EVENT_ALLOC',
		'WELL_EVENT',
		'WELL_EVENT_ART_LIFT',
		'WELL_EVENT_ART_LIFT_REF',
		'WELL_EVENT_LAST_ALR',
		'WELL_EVENT_SINGLE',
		'WELL_EVENT_SUBSURFACE',
		'WELL_FLASH_GAS_ANALYSIS',
		'WELL_FORM_ION_ANALYSIS',
		'WELL_GAS_ANALYSIS',
		'WELL_GAS_COMP_QA',
		'WELL_GAS_INJ_ANALYSIS',
		'WELL_INJ_ION_ANALYSIS',
		'WELL_LOAD_TO_STRM',
		'WELL_LOADED_FROM_TRUCK',
		'WELL_MTH_DISP_ALLOC',
		'WELL_MTH_DISP_ALLOC_GAS',
		'WELL_MTH_DISP_ALLOC_LIQ',
		'WELL_MTH_DISP_CP_ALLOC',
		'WELL_MTH_STRM_ALLOC',
		'WELL_MTH_STRM_COMP_ALLOC',
		'WELL_OIL_ANALYSIS',
		'WELL_OIL_COMP_QA',
		'WELL_PLAN_BUDGET',
		'WELL_PLAN_OTHER',
		'WELL_PLAN_POTENTIAL',
		'WELL_PLAN_TARGET',
		'WELL_PROD_ION_ANALYSIS',
		'WELL_PRODUCT_ANALYSIS',
		'WELL_REFERENCE_VALUE',
		'WELL_SAMP_LAST_ANAL',
		'WELL_SAMPLE_ANALYSIS',
		'WELL_SEASONAL_VALUE',
		'WELL_SWING_CONNECTION',
		'WELL_WASTE_INJ'
	)
	and v.dirty_type in ('REPORTLAYER') and v.dirty_ind='N';
end;
--~^UTDELIM^~--

