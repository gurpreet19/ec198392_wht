-- Loading ./ECPD21876_UPGRADE_SCRIPT...
DECLARE 
HASENTRY NUMBER;
BEGIN
	-- The script will perform the followings in the sequence below:-
	--1.Create stream set for the stream that has grs Vol method=MEASURED_TRUCKED_LOAD. 
	--Important: This can only be run after there's an entry for PO.0056_U in stream set.

	INSERT INTO TV_STREAM_SET_LIST (STREAM_ID,CODE,FROM_DATE, END_DATE, CREATED_BY, CREATED_DATE) 
	SELECT SV.OBJECT_ID, 'PO.0056_U',SV.DAYTIME,SV.END_DATE, NVL(ECDP_PINC.getInstallModeTag(), USER), TRUNC(SYSDATE) FROM STRM_VERSION SV WHERE SV.GRS_VOL_METHOD = 'MEASURED_TRUCKED_UNLOAD' ;
	 
	--2.Grs vol method in STRM_VERSION table needs to be updated accordingly as MEASURED_TRUCKED_LOAD,MEASURED_TRUCKED_UNLOAD
	--are no longer valid methods.
	--update STRM_VERSION  set  GRS_VOL_METHOD = 'MEASURED_TRUCKED' where GRS_VOL_METHOD in ('MEASURED_TRUCKED_LOAD','MEASURED_TRUCKED_UNLOAD');
	--3. Move data from net_vol to net_vol_adj and set the net_vol to null. This is because NET_VOL_ADJ will have priority 1 and --not be adjusted by VCF later, while NET_VOL will be priority 2 --and will be adjusted by VCF if available.

	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_STRM_TRANSPORT_EVENT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_STRM_TRANSPORT_EVENT DISABLE';
		END IF;
	
	UPDATE STRM_TRANSPORT_EVENT SET NET_VOL_ADJ = NET_VOL, NET_VOL = NULL WHERE DATA_CLASS_NAME IN ('STRM_TRUCK_UNLOAD_VOL', 'STRM_TRUCK_UNLOAD_MASS');

	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_STRM_TRANSPORT_EVENT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_STRM_TRANSPORT_EVENT ENABLE';
		END IF;
EXCEPTION
   WHEN OTHERS 
     THEN
       
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_STRM_TRANSPORT_EVENT ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);


END;
--~^UTDELIM^~--	
-- ECPD25492_WELL_CHRONOLOGY_UPGRADE...
BEGIN

	UPDATE DV_WELL_CHRONOLOGY T SET WELL_CHRON_CODE = 'INPRODUCTION' WHERE T.WELL_CHRON_CODE = 'IN PRODUCTION';

END;
--~^UTDELIM^~--
DECLARE 
HASENTRY NUMBER; 	
BEGIN
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_STRM_VERSION'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_STRM_VERSION DISABLE';
		END IF;

	UPDATE STRM_VERSION SET GCV_METHOD ='REF_VALUE' WHERE GCV_METHOD = 'GCV';
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_STRM_VERSION'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_STRM_VERSION ENABLE';
		END IF;
EXCEPTION
   WHEN OTHERS 
     THEN

       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_STRM_VERSION ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);


END;
--~^UTDELIM^~--	
-- ECPD-30871
/*This is to update all the records having object_type as 'EQPM' instead of 'Chiller,Compressor,Co2 Removal Unit and so on*/ 
DECLARE 
HASENTRY NUMBER;
BEGIN
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_WELL_EQUIP_DOWNTIME'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_WELL_EQUIP_DOWNTIME DISABLE';
		END IF;
		
	UPDATE WELL_EQUIP_DOWNTIME 
	SET object_type=ec_equipment.eqpm_type(OBJECT_ID) 
	WHERE object_type='EQPM';
	Commit;
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_WELL_EQUIP_DOWNTIME'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_WELL_EQUIP_DOWNTIME ENABLE';
		END IF;
EXCEPTION
   WHEN OTHERS 
     THEN

       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_WELL_EQUIP_DOWNTIME ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);

END;
--~^UTDELIM^~--

-- ECPD-30308

-- Block 1 : For migration of Prosty Code
-- Query will skip any Reason code which already exists in prosty_code
BEGIN
    INSERT INTO PROSTY_CODES
        (CODE_TYPE, CODE, CODE_TEXT, IS_SYSTEM_CODE, IS_DEFAULT, IS_ACTIVE, SORT_ORDER, DESCRIPTION
        )
    SELECT 'WEL_DT_REAS_1' code_type,
           rc.reason_code code,
           initcap(rc.reason_code) code_text,
           'N' is_system_code,
           'N' is_default,
           'Y' is_active,
           (SELECT nvl(MAX(a.sort_order), 0)
              FROM prosty_codes a
             WHERE a.code_type = 'WELL_DT_REAS_1') + (rownum * 10) sort_order,
           INITCAP(rc.reason_code) description
      FROM (SELECT DISTINCT UPPER(TRIM(reason_code_1)) reason_code
              FROM well_equip_downtime
             WHERE reason_code_1 IS NOT NULL
               AND UPPER(TRIM(reason_code_1)) NOT IN
                   (SELECT upper(TRIM(code))
                      FROM prosty_codes
                     WHERE code_type = 'WELL_DT_REAS_1')) rc
    UNION ALL
    SELECT 'WEL_DT_REAS_2' code_type,
           rc.reason_code code,
           initcap(rc.reason_code) code_text,
           'N' is_system_code,
           'N' is_default,
           'Y' is_active,
           (SELECT nvl(MAX(a.sort_order), 0)
              FROM prosty_codes a
             WHERE a.code_type = 'WELL_DT_REAS_2') + (rownum * 10) sort_order,
           INITCAP(rc.reason_code) description
      FROM (SELECT DISTINCT UPPER(TRIM(reason_code_2)) reason_code
              FROM well_equip_downtime
             WHERE reason_code_2 IS NOT NULL
               AND UPPER(TRIM(reason_code_2)) NOT IN
                   (SELECT upper(TRIM(code))
                      FROM prosty_codes
                     WHERE code_type = 'WELL_DT_REAS_2')) rc
    UNION ALL
    SELECT 'WEL_DT_REAS_3' code_type,
           rc.reason_code code,
           initcap(rc.reason_code) code_text,
           'N' is_system_code,
           'N' is_default,
           'Y' is_active,
           (SELECT nvl(MAX(a.sort_order), 0)
              FROM prosty_codes a
             WHERE a.code_type = 'WELL_DT_REAS_3') + (rownum * 10) sort_order,
           INITCAP(rc.reason_code) description
      FROM (SELECT DISTINCT UPPER(TRIM(reason_code_3)) reason_code
              FROM well_equip_downtime
             WHERE reason_code_3 IS NOT NULL
               AND UPPER(TRIM(reason_code_3)) NOT IN
                   (SELECT upper(TRIM(code))
                      FROM prosty_codes
                     WHERE code_type = 'WELL_DT_REAS_3')) rc
    UNION ALL
    SELECT 'WEL_DT_REAS_4' code_type,
           rc.reason_code code,
           initcap(rc.reason_code) code_text,
           'N' is_system_code,
           'N' is_default,
           'Y' is_active,
           (SELECT nvl(MAX(a.sort_order), 0)
              FROM prosty_codes a
             WHERE a.code_type = 'WELL_DT_REAS_4') + (rownum * 10) sort_order,
           INITCAP(rc.reason_code) description
      FROM (SELECT DISTINCT UPPER(TRIM(reason_code_4)) reason_code
              FROM well_equip_downtime
             WHERE reason_code_4 IS NOT NULL
               AND UPPER(TRIM(reason_code_4)) NOT IN
                   (SELECT upper(TRIM(code))
                      FROM prosty_codes
                     WHERE code_type = 'WELL_DT_REAS_4')) rc;
    COMMIT;
END;
--~^UTDELIM^~--

-- Block 2 : For data upgrade from well downtime screen to well deferment
DECLARE
-- Cursor Declaration
-- Pull data for D/T Type Group and Single
CURSOR c_parent_well_downtime_rec
IS
SELECT
       object_id, object_type, event_no, parent_event_no, downtime_type
       ,downtime_categ, daytime, end_date, downtime_class_type, master_event_id
       ,parent_daytime, parent_master_event_id, parent_object_id
       ,reason_code_1, reason_code_2, reason_code_3, reason_code_4
       ,cond_loss_rate, cond_loss_volume, gas_loss_rate, gas_loss_volume, gas_inj_loss_rate
       ,gas_inj_loss_volume, oil_loss_rate, oil_loss_volume, steam_inj_loss_rate, steam_inj_loss_volume
       ,water_inj_loss_rate, water_inj_loss_volume, water_loss_rate, water_loss_volume, status
       ,equipment_id, comments, value_1, value_2, value_3, value_4, value_5
       ,value_6, value_7, value_8, value_9, value_10, text_1, text_2
       ,text_3, text_4, text_5, text_6, text_7, text_8, text_9, text_10, date_1, date_2
       ,date_3, date_4, date_5, rev_text
  FROM well_equip_downtime wd
 WHERE (wd.downtime_categ='WELL_OFF' AND wd.downtime_class_type IN ('GROUP','SINGLE'));

-- Pull data for D/T Type Group Child
CURSOR c_child_well_downtime_rec(pn_parent_event_no NUMBER)
IS
SELECT
       object_id, object_type, event_no, parent_event_no, downtime_type
       ,downtime_categ, daytime, end_date, downtime_class_type, master_event_id
       ,parent_daytime, parent_master_event_id, parent_object_id
       ,reason_code_1, reason_code_2, reason_code_3, reason_code_4
       ,cond_loss_rate, cond_loss_volume, gas_loss_rate, gas_loss_volume, gas_inj_loss_rate
       ,gas_inj_loss_volume, oil_loss_rate, oil_loss_volume, steam_inj_loss_rate, steam_inj_loss_volume
       ,water_inj_loss_rate, water_inj_loss_volume, water_loss_rate, water_loss_volume, status
       ,equipment_id, comments, value_1, value_2, value_3, value_4, value_5
       ,value_6, value_7, value_8, value_9, value_10, text_1, text_2
       ,text_3, text_4, text_5, text_6, text_7, text_8, text_9, text_10, date_1, date_2
       ,date_3, date_4, date_5, rev_text
  FROM well_equip_downtime wd
 WHERE wd.downtime_categ='WELL_OFF'
   AND wd.downtime_class_type = 'GROUP_CHILD'
   AND parent_event_no = pn_parent_event_no;

-- Local variable declaration
ln_event_no well_deferment.event_no%TYPE;

BEGIN

  FOR cpr IN c_parent_well_downtime_rec
  LOOP
    INSERT INTO well_deferment
        (
            object_id, object_type, parent_event_no, event_type, deferment_type, scheduled
          , daytime, end_date, master_event_id, parent_daytime, parent_master_event_id, parent_object_id
          , reason_code_1, reason_code_2, reason_code_3, reason_code_4
          , cond_loss_rate, cond_loss_volume
          , gas_loss_rate, gas_loss_volume, gas_inj_loss_rate, gas_inj_loss_volume
          , oil_loss_rate, oil_loss_volume, steam_inj_loss_rate
          , steam_inj_loss_volume, water_inj_loss_rate
          , water_inj_loss_volume, water_loss_rate, water_loss_volume, status
          , comments, value_1, value_2, value_3
          , value_4, value_5, value_6, value_7, value_8, value_9
          , value_10, text_1, text_2, text_3, text_4, text_5, text_6
          , text_7, text_8, text_9
          , text_10, date_1, date_2, date_3, date_4, date_5
          , reason_code_type_1 , reason_code_type_2, reason_code_type_3, reason_code_type_4
          , rev_text, equipment_id
        )
    VALUES
        (
            cpr.object_id, cpr.object_type, NULL, 'DOWN', cpr.downtime_class_type, 'N'
          , cpr.daytime, cpr.end_date, cpr.master_event_id, NULL, NULL, NULL
          , UPPER(TRIM(cpr.reason_code_1)),  UPPER(TRIM(cpr.reason_code_2)), UPPER(TRIM(cpr.reason_code_3)), UPPER(TRIM(cpr.reason_code_4))
          , cpr.cond_loss_rate, cpr.cond_loss_volume
          , cpr.gas_loss_rate, cpr.gas_loss_volume, cpr.gas_inj_loss_rate, cpr.gas_inj_loss_volume
          , cpr.oil_loss_rate, cpr.oil_loss_volume, cpr.steam_inj_loss_rate
          , cpr.steam_inj_loss_volume, cpr.water_inj_loss_rate
          , cpr.water_inj_loss_volume, cpr.water_loss_rate, cpr.water_loss_volume, cpr.status
          , cpr.comments, cpr.value_1, cpr.value_2, cpr.value_3
          , cpr.value_4, cpr.value_5, cpr.value_6, cpr.value_7, cpr.value_8, cpr.value_9
          , cpr.value_10, cpr.text_1, cpr.text_2, cpr.text_3, cpr.text_4, cpr.text_5, cpr.text_6
          , cpr.text_7, cpr.text_8, cpr.text_9
          , cpr.text_10, cpr.date_1, cpr.date_2, cpr.date_3, cpr.date_4, cpr.date_5
          , NVL2(cpr.reason_code_1,'WELL_DT_REAS_1',NULL), NVL2(cpr.reason_code_2,'WELL_DT_REAS_2',NULL)
          , NVL2(cpr.reason_code_3,'WELL_DT_REAS_3',NULL), NVL2(cpr.reason_code_4,'WELL_DT_REAS_4',NULL)
          , cpr.rev_text, cpr.equipment_id
        ) RETURNING event_no INTO ln_event_no;

    IF cpr.downtime_class_type <> 'SINGLE' THEN

        FOR ccr IN c_child_well_downtime_rec(cpr.event_no)
        LOOP

          INSERT INTO well_deferment
              (
                  object_id, object_type, parent_event_no, event_type, deferment_type, scheduled
                , daytime, end_date, master_event_id, parent_daytime, parent_master_event_id, parent_object_id
                , reason_code_1, reason_code_2, reason_code_3, reason_code_4
                , cond_loss_rate, cond_loss_volume
                , gas_loss_rate, gas_loss_volume, gas_inj_loss_rate, gas_inj_loss_volume
                , oil_loss_rate, oil_loss_volume, steam_inj_loss_rate
                , steam_inj_loss_volume, water_inj_loss_rate
                , water_inj_loss_volume, water_loss_rate, water_loss_volume, status
                , comments, value_1, value_2, value_3
                , value_4, value_5, value_6, value_7, value_8, value_9
                , value_10, text_1, text_2, text_3, text_4, text_5, text_6
                , text_7, text_8, text_9
                , text_10, date_1, date_2, date_3, date_4, date_5
                , reason_code_type_1 , reason_code_type_2, reason_code_type_3, reason_code_type_4
                , rev_text, equipment_id
              )
          VALUES
              (
                  ccr.object_id, ccr.object_type, ln_event_no, 'DOWN', ccr.downtime_class_type, 'N'
                , ccr.daytime, ccr.end_date, ccr.master_event_id, ccr.parent_daytime, ccr.parent_master_event_id, ccr.parent_object_id
                , UPPER(TRIM(ccr.reason_code_1)),  UPPER(TRIM(ccr.reason_code_2)), UPPER(TRIM(ccr.reason_code_3)), UPPER(TRIM(ccr.reason_code_4))
                , ccr.cond_loss_rate, ccr.cond_loss_volume
                , ccr.gas_loss_rate, ccr.gas_loss_volume, ccr.gas_inj_loss_rate, ccr.gas_inj_loss_volume
                , ccr.oil_loss_rate, ccr.oil_loss_volume, ccr.steam_inj_loss_rate
                , ccr.steam_inj_loss_volume, ccr.water_inj_loss_rate
                , ccr.water_inj_loss_volume, ccr.water_loss_rate, ccr.water_loss_volume, ccr.status
                , ccr.comments, ccr.value_1, ccr.value_2, ccr.value_3
                , ccr.value_4, ccr.value_5, ccr.value_6, ccr.value_7, ccr.value_8, ccr.value_9
                , ccr.value_10, ccr.text_1, ccr.text_2, ccr.text_3, ccr.text_4, ccr.text_5, ccr.text_6
                , ccr.text_7, ccr.text_8, ccr.text_9
                , ccr.text_10, ccr.date_1, ccr.date_2, ccr.date_3, ccr.date_4, ccr.date_5
                , NVL2(ccr.reason_code_1,'WELL_DT_REAS_1',NULL), NVL2(ccr.reason_code_2,'WELL_DT_REAS_2',NULL)
                , NVL2(ccr.reason_code_3,'WELL_DT_REAS_3',NULL), NVL2(ccr.reason_code_4,'WELL_DT_REAS_4',NULL)
                , ccr.rev_text, ccr.equipment_id
              );
        END LOOP;
    END IF;
  END LOOP;
  COMMIT;
END;
--~^UTDELIM^~--

-- Block 3 : For data upgrade from well constraint screen to well deferment
DECLARE
-- Cursor Declaration
-- Pull data for D/T Type Group and Single
CURSOR c_parent_well_downtime_rec
IS
SELECT
       object_id, object_type, event_no, parent_event_no, downtime_type
       ,downtime_categ, daytime, end_date, downtime_class_type, master_event_id
       ,parent_daytime, parent_master_event_id, parent_object_id
       ,reason_code_1, reason_code_2, reason_code_3, reason_code_4
       ,cond_loss_rate, cond_loss_volume, gas_loss_rate, gas_loss_volume, gas_inj_loss_rate
       ,gas_inj_loss_volume, oil_loss_rate, oil_loss_volume, steam_inj_loss_rate, steam_inj_loss_volume
       ,water_inj_loss_rate, water_inj_loss_volume, water_loss_rate, water_loss_volume, status
       ,equipment_id, comments, value_1, value_2, value_3, value_4, value_5
       ,value_6, value_7, value_8, value_9, value_10, text_1, text_2
       ,text_3, text_4, text_5, text_6, text_7, text_8, text_9, text_10, date_1, date_2
       ,date_3, date_4, date_5, rev_text
  FROM well_equip_downtime wd
 WHERE (wd.downtime_categ='WELL_LOW' AND wd.downtime_class_type IN ('GROUP','SINGLE'));

-- Pull data for D/T Type Group Child
CURSOR c_child_well_downtime_rec(pn_parent_event_no NUMBER)
IS
SELECT
       object_id, object_type, event_no, parent_event_no, downtime_type
       ,downtime_categ, daytime, end_date, downtime_class_type, master_event_id
       ,parent_daytime, parent_master_event_id, parent_object_id
       ,reason_code_1, reason_code_2, reason_code_3, reason_code_4
       ,cond_loss_rate, cond_loss_volume, gas_loss_rate, gas_loss_volume, gas_inj_loss_rate
       ,gas_inj_loss_volume, oil_loss_rate, oil_loss_volume, steam_inj_loss_rate, steam_inj_loss_volume
       ,water_inj_loss_rate, water_inj_loss_volume, water_loss_rate, water_loss_volume, status
       ,equipment_id, comments, value_1, value_2, value_3, value_4, value_5
       ,value_6, value_7, value_8, value_9, value_10, text_1, text_2
       ,text_3, text_4, text_5, text_6, text_7, text_8, text_9, text_10, date_1, date_2
       ,date_3, date_4, date_5, rev_text
  FROM well_equip_downtime wd
 WHERE wd.downtime_categ='WELL_LOW'
   AND wd.downtime_class_type = 'GROUP_CHILD'
   AND parent_event_no = pn_parent_event_no;

-- Local variable declaration
ln_event_no well_deferment.event_no%TYPE;

BEGIN

  FOR cpr IN c_parent_well_downtime_rec
  LOOP
    INSERT INTO well_deferment
        (
            object_id, object_type, parent_event_no, event_type, deferment_type, scheduled
          , daytime, end_date, master_event_id, parent_daytime, parent_master_event_id, parent_object_id
          , reason_code_1, reason_code_2, reason_code_3, reason_code_4
          , cond_loss_rate, cond_loss_volume
          , gas_loss_rate, gas_loss_volume, gas_inj_loss_rate, gas_inj_loss_volume
          , oil_loss_rate, oil_loss_volume, steam_inj_loss_rate
          , steam_inj_loss_volume, water_inj_loss_rate
          , water_inj_loss_volume, water_loss_rate, water_loss_volume, status
          , comments, value_1, value_2, value_3
          , value_4, value_5, value_6, value_7, value_8, value_9
          , value_10, text_1, text_2, text_3, text_4, text_5, text_6
          , text_7, text_8, text_9
          , text_10, date_1, date_2, date_3, date_4, date_5
          , reason_code_type_1 , reason_code_type_2, reason_code_type_3, reason_code_type_4
          , rev_text, equipment_id
         )
    VALUES
        (
            cpr.object_id, cpr.object_type, NULL, 'CONSTRAINT', cpr.downtime_class_type, 'N'
          , cpr.daytime, cpr.end_date, cpr.master_event_id, NULL, NULL, NULL
          , UPPER(TRIM(cpr.reason_code_1)),  UPPER(TRIM(cpr.reason_code_2)), UPPER(TRIM(cpr.reason_code_3)), UPPER(TRIM(cpr.reason_code_4))
          , cpr.cond_loss_rate, cpr.cond_loss_volume
          , cpr.gas_loss_rate, cpr.gas_loss_volume, cpr.gas_inj_loss_rate, cpr.gas_inj_loss_volume
          , cpr.oil_loss_rate, cpr.oil_loss_volume, cpr.steam_inj_loss_rate
          , cpr.steam_inj_loss_volume, cpr.water_inj_loss_rate
          , cpr.water_inj_loss_volume, cpr.water_loss_rate, cpr.water_loss_volume, cpr.status
          , cpr.comments, cpr.value_1, cpr.value_2, cpr.value_3
          , cpr.value_4, cpr.value_5, cpr.value_6, cpr.value_7, cpr.value_8, cpr.value_9
          , cpr.value_10, cpr.text_1, cpr.text_2, cpr.text_3, cpr.text_4, cpr.text_5, cpr.text_6
          , cpr.text_7, cpr.text_8, cpr.text_9
          , cpr.text_10, cpr.date_1, cpr.date_2, cpr.date_3, cpr.date_4, cpr.date_5
          , NVL2(cpr.reason_code_1,'WELL_DT_REAS_1',NULL), NVL2(cpr.reason_code_2,'WELL_DT_REAS_2',NULL)
          , NVL2(cpr.reason_code_3,'WELL_DT_REAS_3',NULL), NVL2(cpr.reason_code_4,'WELL_DT_REAS_4',NULL)
          , cpr.rev_text, cpr.equipment_id
        ) RETURNING event_no INTO ln_event_no;

    IF cpr.downtime_class_type <> 'SINGLE' THEN

        FOR ccr IN c_child_well_downtime_rec(cpr.event_no)
        LOOP

          INSERT INTO well_deferment
              (
                  object_id, object_type, parent_event_no, event_type, deferment_type, scheduled
                , daytime, end_date, master_event_id, parent_daytime, parent_master_event_id, parent_object_id
                , reason_code_1, reason_code_2, reason_code_3, reason_code_4
                , cond_loss_rate, cond_loss_volume
                , gas_loss_rate, gas_loss_volume, gas_inj_loss_rate, gas_inj_loss_volume
                , oil_loss_rate, oil_loss_volume, steam_inj_loss_rate
                , steam_inj_loss_volume, water_inj_loss_rate
                , water_inj_loss_volume, water_loss_rate, water_loss_volume, status
                , comments, value_1, value_2, value_3
                , value_4, value_5, value_6, value_7, value_8, value_9
                , value_10, text_1, text_2, text_3, text_4, text_5, text_6
                , text_7, text_8, text_9
                , text_10, date_1, date_2, date_3, date_4, date_5
                , reason_code_type_1 , reason_code_type_2, reason_code_type_3, reason_code_type_4
                , rev_text, equipment_id
              )
          VALUES
              (
                  ccr.object_id, ccr.object_type, ln_event_no, 'CONSTRAINT', ccr.downtime_class_type, 'N'
                , ccr.daytime, ccr.end_date, ccr.master_event_id, ccr.parent_daytime, ccr.parent_master_event_id, ccr.parent_object_id
                , UPPER(TRIM(ccr.reason_code_1)),  UPPER(TRIM(ccr.reason_code_2)), UPPER(TRIM(ccr.reason_code_3)), UPPER(TRIM(ccr.reason_code_4))
                , ccr.cond_loss_rate, ccr.cond_loss_volume
                , ccr.gas_loss_rate, ccr.gas_loss_volume, ccr.gas_inj_loss_rate, ccr.gas_inj_loss_volume
                , ccr.oil_loss_rate, ccr.oil_loss_volume, ccr.steam_inj_loss_rate
                , ccr.steam_inj_loss_volume, ccr.water_inj_loss_rate
                , ccr.water_inj_loss_volume, ccr.water_loss_rate, ccr.water_loss_volume, ccr.status
                , ccr.comments, ccr.value_1, ccr.value_2, ccr.value_3
                , ccr.value_4, ccr.value_5, ccr.value_6, ccr.value_7, ccr.value_8, ccr.value_9
                , ccr.value_10, ccr.text_1, ccr.text_2, ccr.text_3, ccr.text_4, ccr.text_5, ccr.text_6
                , ccr.text_7, ccr.text_8, ccr.text_9
                , ccr.text_10, ccr.date_1, ccr.date_2, ccr.date_3, ccr.date_4, ccr.date_5
                , NVL2(ccr.reason_code_1,'WELL_DT_REAS_1',NULL), NVL2(ccr.reason_code_2,'WELL_DT_REAS_2',NULL)
                , NVL2(ccr.reason_code_3,'WELL_DT_REAS_3',NULL), NVL2(ccr.reason_code_4,'WELL_DT_REAS_4',NULL)
                , ccr.rev_text, ccr.equipment_id
              );
        END LOOP;
    END IF;
  END LOOP;
  COMMIT;
END;
--~^UTDELIM^~--

-- Block 4 : For data upgrade from Equipment Downtime screen to well deferment
DECLARE
-- Cursor Declaration
-- Pull data for D/T Type Group and Group_Child
-- Ignore data for Group record as we are moving all Group_child row as Group D/T
CURSOR c_well_eqpm_downtime_rec
IS
SELECT
       object_id, DECODE(downtime_type,'EQPM_DT','EQPM',object_type) object_type, event_no,NULL parent_event_no, downtime_type
       ,downtime_categ, daytime, end_date, DECODE(downtime_type,'EQPM_DT','GROUP',downtime_class_type) downtime_class_type, master_event_id
       ,NULL parent_daytime,NULL parent_master_event_id,NULL parent_object_id
       ,reason_code_1, reason_code_2, reason_code_3, reason_code_4
       ,cond_loss_rate, cond_loss_volume, gas_loss_rate, gas_loss_volume, gas_inj_loss_rate
       ,gas_inj_loss_volume, oil_loss_rate, oil_loss_volume, steam_inj_loss_rate, steam_inj_loss_volume
       ,water_inj_loss_rate, water_inj_loss_volume, water_loss_rate, water_loss_volume, status
       ,equipment_id, comments, value_1, value_2, value_3, value_4, value_5
       ,value_6, value_7, value_8, value_9, value_10, text_1, text_2
       ,text_3, text_4, text_5, text_6, text_7, text_8, text_9, text_10, date_1, date_2
       ,date_3, date_4, date_5, rev_text
  FROM well_equip_downtime wd
 WHERE (wd.downtime_categ='EQPM_OFF' AND wd.downtime_class_type IN ('GROUP_CHILD','SINGLE'));

BEGIN

  FOR cpr IN c_well_eqpm_downtime_rec
  LOOP
    INSERT INTO well_deferment
        (
            object_id, object_type, parent_event_no, event_type, deferment_type, scheduled
          , daytime, end_date, master_event_id, parent_daytime, parent_master_event_id, parent_object_id
          , reason_code_1, reason_code_2, reason_code_3, reason_code_4
          , cond_loss_rate, cond_loss_volume
          , gas_loss_rate, gas_loss_volume, gas_inj_loss_rate, gas_inj_loss_volume
          , oil_loss_rate, oil_loss_volume, steam_inj_loss_rate
          , steam_inj_loss_volume, water_inj_loss_rate
          , water_inj_loss_volume, water_loss_rate, water_loss_volume, status
          , comments, value_1, value_2, value_3
          , value_4, value_5, value_6, value_7, value_8, value_9
          , value_10, text_1, text_2, text_3, text_4, text_5, text_6
          , text_7, text_8, text_9
          , text_10, date_1, date_2, date_3, date_4, date_5
          , reason_code_type_1 , reason_code_type_2, reason_code_type_3, reason_code_type_4
          , rev_text, equipment_id
        )
    VALUES
        (
            cpr.object_id, cpr.object_type, cpr.parent_event_no, 'DOWN', cpr.downtime_class_type, 'N'
          , cpr.daytime, cpr.end_date, cpr.master_event_id, cpr.parent_daytime, cpr.parent_master_event_id, cpr.parent_object_id
          , UPPER(TRIM(cpr.reason_code_1)),  UPPER(TRIM(cpr.reason_code_2)), UPPER(TRIM(cpr.reason_code_3)), UPPER(TRIM(cpr.reason_code_4))
          , cpr.cond_loss_rate, cpr.cond_loss_volume
          , cpr.gas_loss_rate, cpr.gas_loss_volume, cpr.gas_inj_loss_rate, cpr.gas_inj_loss_volume
          , cpr.oil_loss_rate, cpr.oil_loss_volume, cpr.steam_inj_loss_rate
          , cpr.steam_inj_loss_volume, cpr.water_inj_loss_rate
          , cpr.water_inj_loss_volume, cpr.water_loss_rate, cpr.water_loss_volume, cpr.status
          , cpr.comments, cpr.value_1, cpr.value_2, cpr.value_3
          , cpr.value_4, cpr.value_5, cpr.value_6, cpr.value_7, cpr.value_8, cpr.value_9
          , cpr.value_10, cpr.text_1, cpr.text_2, cpr.text_3, cpr.text_4, cpr.text_5, cpr.text_6
          , cpr.text_7, cpr.text_8, cpr.text_9
          , cpr.text_10, cpr.date_1, cpr.date_2, cpr.date_3, cpr.date_4, cpr.date_5
          , NVL2(cpr.reason_code_1,'WELL_DT_REAS_1',NULL), NVL2(cpr.reason_code_2,'WELL_DT_REAS_2',NULL)
          , NVL2(cpr.reason_code_3,'WELL_DT_REAS_3',NULL), NVL2(cpr.reason_code_4,'WELL_DT_REAS_4',NULL)
          , cpr.rev_text, cpr.equipment_id
        );
  END LOOP;
  COMMIT;
END;
--~^UTDELIM^~--

select EcDp_System_key.assignNextNumber('MHM_MSG') from dual
--~^UTDELIM^~--	

BEGIN
	UPDATE assign_id SET MAX_ID = (select CASE WHEN MAX(MESSAGE_ID) IS NULL THEN 1 ELSE MAX(MESSAGE_ID) + 1 END from mhm_msg) WHERE TABLENAME = 'MHM_MSG';
END;
--~^UTDELIM^~--	

-- task domain
DECLARE 
HASENTRY NUMBER;
BEGIN
SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ DISABLE';
		END IF;
		
	update jbpm_bpm_obj
	set OWNER_GLOBAL_ID = 'c27771a1/' || OWNER_GLOBAL_ID,
		OWNER_REF_JSON = EcDp_BPM_util_json.insert_array_element(OWNER_REF_JSON, '"c27771a1"', 0)
	where VALUE_TYPE_NAME in (
		'com.ec.bpm.domain.task.reads.TaskResult',
		'com.ec.bpm.domain.task.reads.TaskSummary',
		'com.ec.bpm.domain.task.reads.TaskDetail');
		
 SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
		END IF;
		
	 EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--
DECLARE 
HASENTRY NUMBER;
BEGIN

SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ DISABLE';
		END IF;
		
		
	update jbpm_bpm_obj
	set VALUE = EcDp_BPM_util_json_clob.replace_value(
			VALUE,
			'_of/.class',
			'"com.ec.bpm.domain.process.model.task.UserTaskRef"')
	where VALUE_TYPE_NAME in (
		'com.ec.bpm.domain.task.reads.TaskResult',
		'com.ec.bpm.domain.task.reads.TaskSummary',
		'com.ec.bpm.domain.task.reads.TaskDetail');
		
			SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
		END IF;
		
	 EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--
DECLARE 
HASENTRY NUMBER;
BEGIN
SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ DISABLE';
		END IF;
		
	update jbpm_bpm_obj
	set VALUE = EcDp_BPM_util_json_clob.insert_array_element(
			VALUE,
			'_of/id/.elements',
			'{".value":"c27771a1",".class":"java.lang.String"},{".value":"8470cc7",".class":"java.lang.String"}',
			0)
	where VALUE_TYPE_NAME in (
		'com.ec.bpm.domain.task.reads.TaskResult',
		'com.ec.bpm.domain.task.reads.TaskSummary',
		'com.ec.bpm.domain.task.reads.TaskDetail');
		
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
		END IF;
		
	 EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
		
END;
--~^UTDELIM^~--
DECLARE 
HASENTRY NUMBER;
BEGIN
SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ DISABLE';
		END IF;
		
	update jbpm_bpm_obj
	set VALUE = EcDp_BPM_util_json_clob.replace_value(
			VALUE,
			'processInstance/.class',
			'"com.ec.bpm.domain.process.model.process.ProcessInstanceRef"')
	where VALUE_TYPE_NAME = 'com.ec.bpm.domain.task.reads.TaskSummary';
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
		END IF;
		
	 EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--

DECLARE 
HASENTRY NUMBER;
BEGIN

SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ DISABLE';
		END IF;
		
	update jbpm_bpm_obj
	set VALUE = EcDp_BPM_util_json_clob.insert_array_element(
			VALUE,
			'processInstance/id',
			'{".value":"1ebd446a",".class":"java.lang.String"}',
			0)
	where VALUE_TYPE_NAME = 'com.ec.bpm.domain.task.reads.TaskSummary';
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
		END IF;
		
	 EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--

DECLARE 
HASENTRY NUMBER;
BEGIN

SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ DISABLE';
		END IF;
		
	update jbpm_bpm_obj
	set VALUE = EcDp_BPM_util_json_clob.replace_name(
			VALUE,
			'processInstance',
			'"correlation"')
	where VALUE_TYPE_NAME = 'com.ec.bpm.domain.task.reads.TaskSummary';
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
		END IF;
		
	 EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--

DECLARE 
HASENTRY NUMBER;
BEGIN

SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ DISABLE';
		END IF;
		
	update jbpm_bpm_obj
	set VALUE = EcDp_BPM_util_json_clob.replace_name(
			VALUE,
			'createdOn',
			'"createdAt"')
	where VALUE_TYPE_NAME = 'com.ec.bpm.domain.task.reads.TaskSummary';
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
		END IF;
		
EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
		
END;
--~^UTDELIM^~--

DECLARE 
HASENTRY NUMBER;
BEGIN

SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ DISABLE';
		END IF;
		
	update jbpm_bpm_obj
	set VALUE = EcDp_BPM_util_json_clob.replace_value(
			VALUE,
			'documentContentId/.class',
			'"com.ec.bpm.domain.task.reads.TaskContentRef"')
	where VALUE_TYPE_NAME = 'com.ec.bpm.domain.task.reads.TaskSummary';
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
		END IF;
		
	EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--
DECLARE 
HASENTRY NUMBER;
BEGIN

SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ DISABLE';
		END IF;
		
	update jbpm_bpm_obj
	set VALUE = EcDp_BPM_util_json_clob.insert_array_element(
			VALUE,
			'documentContentId/id',
			'{".value":"b70eabd0",".class":"java.lang.String"}',
			0)
	where VALUE_TYPE_NAME = 'com.ec.bpm.domain.task.reads.TaskSummary';
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
		END IF;
		
	EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
		
END;
--~^UTDELIM^~--


DECLARE 
HASENTRY NUMBER;
BEGIN

SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ DISABLE';
		END IF;
		
		
	update jbpm_bpm_obj
	set VALUE = EcDp_BPM_util_json_clob.replace_value(
			VALUE,
			'outputContentId/.class',
			'"com.ec.bpm.domain.task.reads.TaskContentRef"')
	where VALUE_TYPE_NAME = 'com.ec.bpm.domain.task.reads.TaskSummary';
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
		END IF;
		
	EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--
DECLARE 
HASENTRY NUMBER;
BEGIN
SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ DISABLE';
		END IF;
		
	update jbpm_bpm_obj
	set VALUE = EcDp_BPM_util_json_clob.insert_array_element(
			VALUE,
			'outputContentId/id',
			'{".value":"b70eabd0",".class":"java.lang.String"}',
			0)
	where VALUE_TYPE_NAME = 'com.ec.bpm.domain.task.reads.TaskSummary';
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
		END IF;
		
	EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--
DECLARE 
HASENTRY NUMBER;

BEGIN

SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ DISABLE';
		END IF;
		
	update jbpm_bpm_obj
	set VALUE = EcDp_BPM_util_json_clob.replace_name(
			VALUE,
			'values',
			'"result"')
	where VALUE_TYPE_NAME = 'com.ec.bpm.domain.task.reads.TaskResult';
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
		END IF;
		
	EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--

DECLARE 
HASENTRY NUMBER;
BEGIN

SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ_RELATION'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ_RELATION DISABLE';
		END IF;
		
	update jbpm_bpm_obj_relation
	set REF_JSON = EcDp_BPM_util_json.insert_array_element(REF_JSON, '"c27771a1"', 0)
	where RELATION_NAME in (
		'ecbpm.domain.task.correlated_process_instance',
		'ecbpm.domain.task.correlated_node_instance');
		
		SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ_RELATION'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ_RELATION ENABLE';
		END IF;
		
	EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ_RELATION ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--
DECLARE 
HASENTRY NUMBER;
BEGIN
SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ_RELATION'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ_RELATION DISABLE';
		END IF;
		
	update jbpm_bpm_obj_relation
	set RELATED_REF_JSON = EcDp_BPM_util_json.insert_array_element(RELATED_REF_JSON, '"c27771a1"', 0)
	where RELATION_NAME in (
		'ecbpm.domain.task.correlated_task');
		
SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ_RELATION'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ_RELATION ENABLE';
		END IF;
		
	EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ_RELATION ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--

BEGIN
	insert into jbpm_bpm_task (GLOBAL_ID, REF_JSON, STATE_DEFINITION, STATE, CORRELATION_GLOBAL_ID, CORRELATION_REF_JSON, ASSIGNEE)
	select 'c27771a1/8470cc7/' || ID,
		'["c27771a1","8470cc7","' || ID || '"]',
		'default',
		 DECODE(STATUS, 'Created', 0, 'Ready', 0, 'Reserved', 1, 'InProgress', 2, 'Suspended', 4, 'Completed', 3, 'Failed', 4, 'Error', 4, 'Exited', 4, 'Obsolete', 4),
		 '1ebd446a/' || PROCESSINSTANCEID || '/' || PROCESSID || '/' || DEPLOYMENTID,
		 '["1ebd446a",' || PROCESSINSTANCEID || ',"' || PROCESSID || '","' || DEPLOYMENTID || '"]',
		 ACTUALOWNER
	from jbpm_task
	where PROCESSINSTANCEID is not null;
END;
--~^UTDELIM^~--

-- process domain

DECLARE 
HASENTRY NUMBER;
BEGIN

SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ_META'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ_META DISABLE';
		END IF;
		
	update jbpm_bpm_obj_meta
	set VALUE = EcDp_BPM_util_json.without_quotes(EcDp_BPM_util_json.value_of(VALUE))
	where NAME in (
		'readonly:ecbpm.domain.process.node.name',
		'readonly:ecbpm.domain.process.node.service_task_name',
		'ecbpm.domain.process.label',
		'ecbpm.domain.vtag.tag');
		
		SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ_META'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ_META ENABLE';
		END IF;
		
	EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ_META ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--

-- ext_ec
DECLARE 
HASENTRY NUMBER;
BEGIN

SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ_META'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ_META DISABLE';
		END IF;
		
	update jbpm_bpm_obj_meta
	set VALUE = EcDp_BPM_util_json.without_quotes(EcDp_BPM_util_json.value_of(VALUE))
	where NAME in (
		'readonly:com.ec.bpm.ext.ec.process.business_action_number',
		'readonly:com.ec.bpm.ext.ec.process.process_creator',
		'readonly:com.ec.bpm.ext.ec.process.schedule_number',
		'readonly:com.ec.bpm.ext.ec.process_creator');
		
		SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ_META'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ_META ENABLE';
		END IF;
		
EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ_META ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--

-- process action domain
DECLARE 
HASENTRY NUMBER;

BEGIN

SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ_META'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ_META DISABLE';
		END IF;
		
	update jbpm_bpm_obj_meta
	set VALUE = EcDp_BPM_util_json.without_quotes(EcDp_BPM_util_json.value_of(VALUE))
	where NAME in (
		'readonly:ecbpm.domain.proaction.node.process_action_name');
		
		SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ_META'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ_META ENABLE';
		END IF;
		
	EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ_META ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--

DECLARE

CURSOR c_report_sets IS 
       select report_set_no, name, functional_area_id 
       from report_set;
       
CURSOR c_reports(p_report_set_no NUMBER) IS 
       select report_set_no, report_runable_no, functional_area_id, sort_order 
       from tv_report_set_list 
       where report_set_no = p_report_set_no;

CURSOR c_report_params(p_report_set_no NUMBER) IS 
       select parameter_value, parameter_name, daytime 
       from tv_report_set_param
       where report_set_no = p_report_set_no;

p_new_report_set_no number;
p_old_name varchar(100);

BEGIN

  -- copy report sets
  FOR cur_set IN c_report_sets LOOP
    insert into report_set (name, functional_area_id ) 
	  values ( concat(cur_set.name, '_NEW'), cur_set.functional_area_id ); 
    
    -- Find the new report set no
    select (select report_set_no from report_set where name = concat(cur_set.name, '_NEW')) 
    into p_new_report_set_no 
    from dual;

    
    -- copy the reports for the report set    
    FOR cur_report IN c_reports(cur_set.report_set_no) LOOP 
        insert into tv_report_set_list (report_set_no, report_runable_no, functional_area_id, sort_order)
        values (p_new_report_set_no, cur_report.report_runable_no, cur_report.functional_area_id, cur_report.sort_order ); 
    END LOOP;

    -- copy parameter values           
    FOR cur_rep_params IN c_report_params(cur_set.report_set_no) LOOP 
        update tv_report_set_param 
        set parameter_value = cur_rep_params.parameter_value 
        where report_set_no = p_new_report_set_no 
              and daytime = cur_rep_params.daytime
              and parameter_name = cur_rep_params.parameter_name;
    END LOOP;

    -- remember old name
    p_old_name := cur_set.name;

    delete from tv_report_set_list where report_set_no = cur_set.report_set_no;
    delete from tv_report_set where report_set_no = cur_set.report_set_no;
    update tv_report_set set name = p_old_name where report_set_no = p_new_report_set_no;

  END LOOP;  
END;
--~^UTDELIM^~--
CREATE SEQUENCE TASK_VAR_ID_SEQ
--~^UTDELIM^~--

CREATE SEQUENCE QUERY_DEF_ID_SEQ
--~^UTDELIM^~--

DROP SEQUENCE PROCESS_LOG_ID_SEQ
--~^UTDELIM^~--

DROP SEQUENCE NODE_PARAM_LOG_ID_SEQ
--~^UTDELIM^~--

CREATE SEQUENCE JBPM_BPM_DATA_SET_USAGE_WS_SEQ
--~^UTDELIM^~--

BEGIN
	INSERT INTO T_BASIS_USERROLE
	(USER_ID, ROLE_ID, APP_ID)
	SELECT USER_ID, 'admin', 1
	FROM T_BASIS_USERROLE
	 WHERE ROLE_ID = 'JBPM.ADMIN'
	AND NOT EXISTS
	(SELECT USER_ID FROM T_BASIS_USERROLE WHERE ROLE_ID = 'admin');	
END;
--~^UTDELIM^~--
-- This script will create report areas based on existing report groups, and will add report area on report definition groups. 
--ALTER TABLE REPORT_DEFINITION_GROUP ADD (REPORT_AREA_ID VARCHAR2(32));
--ALTER TABLE REPORT_DEFINITION_GROUP_JN ADD (REPORT_AREA_ID VARCHAR2(32));

DECLARE
-- Report definition groups that needs to be updated 
CURSOR c_report_def_groups IS
        SELECT rep_group_code, report_group_code
        FROM report_definition_group 
        WHERE report_group_code is not null and report_area_id is null;
		
CURSOR c_report_def_groups_jn IS
        SELECT rep_group_code, report_group_code
        FROM report_definition_group_jn
        WHERE report_group_code is not null and report_area_id is null;
       
BEGIN
  -- Insert Report Areas based on existing ec codes
  insert into OV_REPORT_AREA (CODE, NAME, OBJECT_START_DATE) 
    select CODE, CODE_TEXT, to_date( '01-01-1900', 'dd-mm-yyyy') FROM TV_EC_CODES T WHERE CODE_TYPE = 'REPORT_GROUP' and not exists( select object_code from report_area where object_code = T.CODE ) ;

  -- Update report definitions with the report area in report_definition_group table
  FOR cur_rec IN c_report_def_groups LOOP
    update report_definition_group set report_area_id = (select object_id from report_area where object_code = cur_rec.report_group_code) where report_group_code = cur_rec.report_group_code ;
  END LOOP;
  
  -- Update report definitions with the report area in report_definition_group_jn table
  FOR cur_rec IN c_report_def_groups_jn LOOP
    update report_definition_group_jn set report_area_id = (select object_id from report_area where object_code = cur_rec.report_group_code) where report_group_code = cur_rec.report_group_code ;
  END LOOP;
END;
--~^UTDELIM^~--

BEGIN
	ecdp_classmeta.RefreshMViews;
END;
--~^UTDELIM^~--
-- Purpose of script : It will migrate data from Equipment Downtime (PD.0007) to Equipment Downtime (PD.0022)
-- Created  : 01-JUL-2017  (Gaurav Chaudhary)
--
-- Modification history:
-- Date         Whom      Change description:
-- ----         -----     -----------------------------------
-- 01-JUL-2017  chaudgau  Initial Version
--

-- PL/SQL Block : For data upgrade from Equipment Downtime screen (PD.0007) to Equipment Downtime (PD.0022)
-- EC Code for child record will be considered as group_child

DECLARE

-- Cursor Declaration
-- Pull data for D/T Type Group, Single and Group child
-- Move data for parent data section with new event_no and use it to migrate child data section data, along with updation of parent_event_no
-- EC Ccode Data from downtime_type will be moved to equip_downtime.downtime_class_type column
-- Production day and end day will be generated for each record

CURSOR c_parent_eqpm_downtime_rec
IS
SELECT
       object_id, object_type, event_no, master_event_id
     , NULL parent_event_no, NULL parent_object_id, NULL parent_daytime
     , downtime_type, downtime_class_type, daytime, end_date
     , reason_code_1, reason_code_2, reason_code_3, reason_code_4
     , comments
     , value_1, value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10
     , text_1, text_2, text_3, text_4, text_5, text_6, text_7, text_8, text_9, text_10
     , date_1, date_2, date_3, date_4, date_5
     , rev_text, record_status
  FROM well_equip_downtime wd
 WHERE (wd.downtime_categ='EQPM_OFF' AND wd.downtime_class_type IN ('GROUP','SINGLE'));
 
CURSOR c_child_eqpm_downtime_rec(pn_parent_event_no NUMBER)
IS
SELECT
       object_id, object_type, event_no, master_event_id
     , parent_event_no, parent_object_id, parent_daytime
     , downtime_type, downtime_class_type, daytime, end_date
     , reason_code_1, reason_code_2, reason_code_3, reason_code_4
     , comments
     , value_1, value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10
     , text_1, text_2, text_3, text_4, text_5, text_6, text_7, text_8, text_9, text_10
     , date_1, date_2, date_3, date_4, date_5
     , rev_text, record_status
  FROM well_equip_downtime wd
 WHERE (wd.downtime_categ='EQPM_OFF' AND wd.downtime_class_type = 'GROUP_CHILD')
   AND parent_event_no = pn_parent_event_no;

 ln_event_no equip_downtime.event_no%TYPE;

BEGIN

  FOR cpr IN c_parent_eqpm_downtime_rec
  LOOP
    INSERT INTO equip_downtime
        (
            object_id, object_type, master_event_id
          , parent_event_no, parent_daytime, parent_object_id
          , downtime_class_type, daytime, end_date
          , reason_code_1, reason_code_2, reason_code_3, reason_code_4
          , comments
          , value_1, value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10
          , text_1, text_2, text_3, text_4, text_5, text_6, text_7, text_8, text_9, text_10
          , date_1, date_2, date_3, date_4, date_5
          , rev_text, record_status
        )
    VALUES
        (
            cpr.object_id, cpr.object_type, cpr.master_event_id
          , cpr.parent_event_no, cpr.parent_daytime, cpr.parent_object_id
          , cpr.downtime_type, cpr.daytime, cpr.end_date
          , cpr.reason_code_1, cpr.reason_code_2, cpr.reason_code_3, cpr.reason_code_4
          , cpr.comments
          , cpr.value_1, cpr.value_2, cpr.value_3, cpr.value_4, cpr.value_5, cpr.value_6, cpr.value_7, cpr.value_8, cpr.value_9, cpr.value_10
          , cpr.text_1, cpr.text_2, cpr.text_3, cpr.text_4, cpr.text_5, cpr.text_6, cpr.text_7, cpr.text_8, cpr.text_9, cpr.text_10
          , cpr.date_1, cpr.date_2, cpr.date_3, cpr.date_4, cpr.date_5
          , cpr.rev_text, cpr.record_status
        ) RETURNING event_no INTO ln_event_no;

        IF cpr.downtime_class_type = 'GROUP' THEN
             FOR ccr IN c_child_eqpm_downtime_rec(cpr.event_no)
             LOOP
                 INSERT INTO equip_downtime
                (
                    object_id, object_type, master_event_id
                  , parent_event_no, parent_daytime, parent_object_id
                  , downtime_class_type, daytime, end_date
                  , reason_code_1, reason_code_2, reason_code_3, reason_code_4
                  , comments
                  , value_1, value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10
                  , text_1, text_2, text_3, text_4, text_5, text_6, text_7, text_8, text_9, text_10
                  , date_1, date_2, date_3, date_4, date_5
                  , rev_text, record_status
                )
            VALUES
                (
                    ccr.object_id, ccr.object_type, ccr.master_event_id
                  , ln_event_no, ccr.parent_daytime, ccr.parent_object_id 
                  , 'GROUP_CHILD', ccr.daytime, ccr.end_date
                  , ccr.reason_code_1, ccr.reason_code_2, ccr.reason_code_3, ccr.reason_code_4
                  , ccr.comments
                  , ccr.value_1, ccr.value_2, ccr.value_3, ccr.value_4, ccr.value_5, ccr.value_6, ccr.value_7, ccr.value_8, ccr.value_9, ccr.value_10
                  , ccr.text_1, ccr.text_2, ccr.text_3, ccr.text_4, ccr.text_5, ccr.text_6, ccr.text_7, ccr.text_8, ccr.text_9, ccr.text_10
                  , ccr.date_1, ccr.date_2, ccr.date_3, ccr.date_4, ccr.date_5
                  , ccr.rev_text, ccr.record_status
                );
             END LOOP;
        END IF;
  END LOOP;
  COMMIT;
END;
--~^UTDELIM^~--

-- Purpose of script : It will migrate data from Equipment Downtime tab on Deferment screen(PD.0020) to Equipment Downtime (PD.0022)
-- Created  : 01-JUL-2017  (Gaurav Chaudhary)
--
-- Modification history:
-- Date         Whom      Change description:
-- ----         -----     -----------------------------------
-- 01-JUL-2017  chaudgau  Initial Version
--

-- PL/SQL Block : For data upgrade from Equipment Downtime tab on Deferment screen(PD.0020) to Equipment Downtime (PD.0022)
-- EC Code for downtime_class_type will be considered as EQPM_DT


-- Cursor Declaration
-- Pull data for D/T Type Group, Single and Group child
-- Move data for parent data section with new event_no and use it to migrate child data section data, along with updation of parent_event_no
-- EC Ccode Data from downtime_type will be moved to equip_downtime.downtime_class_type column
-- Production day and end day will be generated for each record
 
BEGIN

    INSERT INTO equip_downtime
        (
            object_id, object_type, master_event_id
          , parent_event_no, parent_daytime, parent_object_id
          , downtime_class_type, daytime, end_date, day, end_day
          , reason_code_1, reason_code_2, reason_code_3, reason_code_4
          , comments
          , value_1, value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10
          , text_1, text_2, text_3, text_4, text_5, text_6, text_7, text_8, text_9, text_10
          , date_1, date_2, date_3, date_4, date_5
          , rev_text, record_status
        )
    SELECT
		   wd.object_id, wd.object_type, wd.master_event_id
		 , NULL parent_event_no, NULL parent_daytime, NULL parent_object_id
		 , 'EQPM_DT' downtime_type, wd.daytime, wd.end_date, wd.day, wd.end_day
		 , wd.reason_code_type_1, wd.reason_code_type_2, wd.reason_code_type_3, wd.reason_code_type_4
		 , wd.comments
		 , wd.value_1, wd.value_2, wd.value_3, wd.value_4, wd.value_5, wd.value_6, wd.value_7, wd.value_8, wd.value_9, wd.value_10
		 , wd.text_1, wd.text_2, wd.text_3, wd.text_4, wd.text_5, wd.text_6, wd.text_7, wd.text_8, wd.text_9, wd.text_10
		 , wd.date_1, wd.date_2, wd.date_3, wd.date_4, wd.date_5
		 , wd.rev_text, wd.record_status
	  FROM well_deferment wd
	  JOIN eqpm_version oa ON oa.object_id = wd.object_id
	 WHERE wd.deferment_type = 'SINGLE'
     AND wd.daytime >= oa.daytime
     AND (oa.end_date is NULL OR wd.daytime < oa.end_date);

  COMMIT;
END;
--~^UTDELIM^~--

DECLARE
      HASENTRY NUMBER;
     sqlQuery clob:='UPDATE ALLOC_JOB_PASS SET METHOD = ''DISPATCHING_SCHD''  WHERE JOB_NO = (select job_no from alloc_job_definition where code = ''DAILY_DISP_SCH_CALC'') and JOB_PASS_NO = ''5''';
BEGIN

   SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_ALLOC_JOB_PASS'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_ALLOC_JOB_PASS DISABLE';
		END IF;
		
     EXECUTE IMMEDIATE sqlQuery;
	 
	  SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_ALLOC_JOB_PASS'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_ALLOC_JOB_PASS ENABLE';
		END IF;
	 
	 
     dbms_output.put_line('SUCCESS: ' || sqlQuery);
     dbms_output.put_line('No of Rows Updated:' || sql%rowcount);
     EXCEPTION
        WHEN OTHERS THEN
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_ALLOC_JOB_PASS ENABLE';
		END IF;
         --UPDATE_MILESTONE_WITH_ERROR('post_add_table_column');
         raise_application_error(-20000, 'ERROR: Some Other fatal error occured' || SQLERRM);
 END;
--~^UTDELIM^~--

DECLARE
     HASENTRY NUMBER;
     sqlQuery clob:='UPDATE ALLOC_JOB_PASS SET METHOD = ''DISPATCHING_SCHD''  WHERE JOB_NO = (select job_no from alloc_job_definition where code = ''SUB_DAILY_DISP_SCH_CALC'') and JOB_PASS_NO = ''8''';
BEGIN
    
	  SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_ALLOC_JOB_PASS'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_ALLOC_JOB_PASS DISABLE';
		END IF;
		
     EXECUTE IMMEDIATE sqlQuery;
	 
	 	  SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_ALLOC_JOB_PASS'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_ALLOC_JOB_PASS ENABLE';
		END IF;
	 
     dbms_output.put_line('SUCCESS: ' || sqlQuery);
     dbms_output.put_line('No of Rows Updated:' || sql%rowcount);
     EXCEPTION
        WHEN OTHERS THEN
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_ALLOC_JOB_PASS ENABLE';
		END IF;
         --UPDATE_MILESTONE_WITH_ERROR('post_add_table_column');
         raise_application_error(-20000, 'ERROR: Some Other fatal error occured' || SQLERRM);
 END;
--~^UTDELIM^~--

DECLARE
 HASENTRY NUMBER;
	 sqlQuery clob  :='UPDATE ALLOC_JOB_PASS SET METHOD = ''DISPATCHING_SCHD'' where METHOD = ''DISPATCHING_SCH''';
	 sqlQuery2 clob :='UPDATE ALLOC_JOB_PASS SET METHOD_CODE=''ALLOC_PASS_METHOD'' WHERE METHOD_CODE IS NULL';
	 
BEGIN
    
	  SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_ALLOC_JOB_PASS'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_ALLOC_JOB_PASS DISABLE';
		END IF;

     EXECUTE IMMEDIATE sqlQuery;
	 dbms_output.put_line('SUCCESS: ' || sqlQuery);
     dbms_output.put_line('No of Rows Updated:' || sql%rowcount);
	 
	 EXECUTE IMMEDIATE sqlQuery2;
	 dbms_output.put_line('SUCCESS: ' || sqlQuery2);
     dbms_output.put_line('No of Rows Updated:' || sql%rowcount);
	 
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_ALLOC_JOB_PASS'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_ALLOC_JOB_PASS ENABLE';
		END IF;
	 
     
     EXCEPTION
        WHEN OTHERS THEN
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_ALLOC_JOB_PASS ENABLE';
		END IF;
         --UPDATE_MILESTONE_WITH_ERROR('post_add_table_column');
         raise_application_error(-20000, 'ERROR: Some Other fatal error occured' || SQLERRM);
 END;
--~^UTDELIM^~--
BEGIN
ecdp_viewlayer.BuildViewLayer('FIN_ITEM_DATASET_MATRIX',p_force => 'Y'); 
END;
--~^UTDELIM^~--

BEGIN
UPDATE VIEWLAYER_DIRTY_LOG SET DIRTY_IND = 'Y' WHERE OBJECT_NAME= 'CALC_COLLECTION_ELEMENT';
END;
--~^UTDELIM^~--

BEGIN 

MERGE INTO CLASS_ATTRIBUTE_CNFG o USING 
(
SELECT
 null APP_SPACE_CNTX, null ATTRIBUTE_NAME, null CLASS_NAME, null DATA_TYPE, null DB_JOIN_TABLE, null DB_JOIN_WHERE, null DB_MAPPING_TYPE, null DB_SQL_SYNTAX, null IS_KEY FROM DUAL WHERE 1=0
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_1', 'TANK_FINDER_OBJECTS', 'DATE', null, null, 'COLUMN', 'DATE_1', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_1', 'VAT_CUST_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_1', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_1', 'VAT_DEST_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_1', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_1', 'VAT_ORIG_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_1', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_1', 'VAT_VEND_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_1', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_10', 'VAT_CUST_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_10', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_10', 'VAT_DEST_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_10', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_10', 'VAT_ORIG_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_10', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_10', 'VAT_VEND_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_10', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_2', 'TANK_FINDER_OBJECTS', 'DATE', null, null, 'COLUMN', 'DATE_2', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_2', 'VAT_CUST_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_2', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_2', 'VAT_DEST_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_2', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_2', 'VAT_ORIG_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_2', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_2', 'VAT_VEND_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_2', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_3', 'TANK_FINDER_OBJECTS', 'DATE', null, null, 'COLUMN', 'DATE_3', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_3', 'VAT_CUST_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_3', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_3', 'VAT_DEST_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_3', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_3', 'VAT_ORIG_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_3', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_3', 'VAT_VEND_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_3', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_4', 'TANK_FINDER_OBJECTS', 'DATE', null, null, 'COLUMN', 'DATE_4', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_4', 'VAT_CUST_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_4', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_4', 'VAT_DEST_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_4', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_4', 'VAT_ORIG_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_4', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_4', 'VAT_VEND_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_4', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_5', 'TANK_FINDER_OBJECTS', 'DATE', null, null, 'COLUMN', 'DATE_5', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_5', 'VAT_CUST_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_5', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_5', 'VAT_DEST_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_5', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_5', 'VAT_ORIG_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_5', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_5', 'VAT_VEND_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_5', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_6', 'VAT_CUST_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_6', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_6', 'VAT_DEST_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_6', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_6', 'VAT_ORIG_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_6', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_6', 'VAT_VEND_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_6', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_7', 'VAT_CUST_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_7', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_7', 'VAT_DEST_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_7', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_7', 'VAT_ORIG_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_7', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_7', 'VAT_VEND_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_7', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_8', 'VAT_CUST_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_8', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_8', 'VAT_DEST_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_8', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_8', 'VAT_ORIG_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_8', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_8', 'VAT_VEND_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_8', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_9', 'VAT_CUST_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_9', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_9', 'VAT_DEST_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_9', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_9', 'VAT_ORIG_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_9', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_9', 'VAT_VEND_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_9', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_1', 'TANK_FINDER_OBJECTS', 'STRING', null, null, 'COLUMN', 'TEXT_1', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_1', 'VAT_CUST_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_1', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_1', 'VAT_DEST_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_1', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_1', 'VAT_ORIG_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_1', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_1', 'VAT_VEND_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_1', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_10', 'TANK_FINDER_OBJECTS', 'STRING', null, null, 'COLUMN', 'TEXT_10', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_10', 'VAT_CUST_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_10', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_10', 'VAT_DEST_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_10', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_10', 'VAT_ORIG_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_10', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_10', 'VAT_VEND_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_10', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_2', 'TANK_FINDER_OBJECTS', 'STRING', null, null, 'COLUMN', 'TEXT_2', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_2', 'VAT_CUST_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_2', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_2', 'VAT_DEST_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_2', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_2', 'VAT_ORIG_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_2', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_2', 'VAT_VEND_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_2', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_3', 'TANK_FINDER_OBJECTS', 'STRING', null, null, 'COLUMN', 'TEXT_3', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_3', 'VAT_CUST_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_3', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_3', 'VAT_DEST_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_3', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_3', 'VAT_ORIG_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_3', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_3', 'VAT_VEND_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_3', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_4', 'TANK_FINDER_OBJECTS', 'STRING', null, null, 'COLUMN', 'TEXT_4', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_4', 'VAT_CUST_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_4', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_4', 'VAT_DEST_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_4', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_4', 'VAT_ORIG_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_4', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_4', 'VAT_VEND_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_4', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_5', 'TANK_FINDER_OBJECTS', 'STRING', null, null, 'COLUMN', 'TEXT_5', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_5', 'VAT_CUST_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_5', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_5', 'VAT_DEST_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_5', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_5', 'VAT_ORIG_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_5', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_5', 'VAT_VEND_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_5', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_6', 'TANK_FINDER_OBJECTS', 'STRING', null, null, 'COLUMN', 'TEXT_6', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_6', 'VAT_CUST_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_6', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_6', 'VAT_DEST_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_6', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_6', 'VAT_ORIG_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_6', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_6', 'VAT_VEND_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_6', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_7', 'TANK_FINDER_OBJECTS', 'STRING', null, null, 'COLUMN', 'TEXT_7', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_7', 'VAT_CUST_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_7', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_7', 'VAT_DEST_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_7', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_7', 'VAT_ORIG_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_7', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_7', 'VAT_VEND_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_7', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_8', 'REPORT_REF_CONN', 'STRING', null, null, 'COLUMN', 'TEXT_8', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_8', 'REPORT_REF_CONN_CM', 'STRING', null, null, 'COLUMN', 'TEXT_8', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_8', 'REPORT_REF_CONN_DOC', 'STRING', null, null, 'COLUMN', 'TEXT_8', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_8', 'REPORT_REF_CONN_TI', 'STRING', null, null, 'COLUMN', 'TEXT_8', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_8', 'REPORT_REF_CONN_TI_LINE', 'STRING', null, null, 'COLUMN', 'TEXT_8', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_8', 'TANK_FINDER_OBJECTS', 'STRING', null, null, 'COLUMN', 'TEXT_8', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_8', 'VAT_CUST_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_8', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_8', 'VAT_DEST_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_8', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_8', 'VAT_ORIG_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_8', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_8', 'VAT_VEND_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_8', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_9', 'REPORT_REF_CONN', 'STRING', null, null, 'COLUMN', 'TEXT_9', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_9', 'REPORT_REF_CONN_CM', 'STRING', null, null, 'COLUMN', 'TEXT_9', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_9', 'REPORT_REF_CONN_DOC', 'STRING', null, null, 'COLUMN', 'TEXT_9', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_9', 'REPORT_REF_CONN_TI', 'STRING', null, null, 'COLUMN', 'TEXT_9', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_9', 'REPORT_REF_CONN_TI_LINE', 'STRING', null, null, 'COLUMN', 'TEXT_9', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_9', 'TANK_FINDER_OBJECTS', 'STRING', null, null, 'COLUMN', 'TEXT_9', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_9', 'VAT_CUST_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_9', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_9', 'VAT_DEST_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_9', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_9', 'VAT_ORIG_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_9', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_9', 'VAT_VEND_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_9', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_1', 'OBJECT_CALC_COMPONENT', 'NUMBER', null, null, 'COLUMN', 'VALUE_1', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_1', 'REVN_CARGO_DG_LOG', 'NUMBER', null, null, 'COLUMN', 'VALUE_1', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_1', 'REVN_CASCADE_LOG', 'NUMBER', null, null, 'COLUMN', 'VALUE_1', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_1', 'REVN_COST_MAP_LOG', 'NUMBER', null, null, 'COLUMN', 'VALUE_1', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_1', 'REVN_ERP_DG_LOG', 'NUMBER', null, null, 'COLUMN', 'VALUE_1', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_1', 'REVN_INTERFACE_LOG', 'NUMBER', null, null, 'COLUMN', 'VALUE_1', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_1', 'REVN_PERIOD_DG_LOG', 'NUMBER', null, null, 'COLUMN', 'VALUE_1', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_1', 'REVN_REVERSE_DG_LOG', 'NUMBER', null, null, 'COLUMN', 'VALUE_1', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_1', 'REVN_SUMMARY_PC_LOG', 'NUMBER', null, null, 'COLUMN', 'VALUE_1', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_1', 'REVN_TI_LOG', 'NUMBER', null, null, 'COLUMN', 'VALUE_1', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_1', 'VAT_CUST_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_1', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_1', 'VAT_DEST_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_1', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_1', 'VAT_ORIG_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_1', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_1', 'VAT_VEND_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_1', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_10', 'VAT_CUST_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_10', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_10', 'VAT_DEST_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_10', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_10', 'VAT_ORIG_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_10', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_10', 'VAT_VEND_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_10', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_2', 'OBJECT_CALC_COMPONENT', 'NUMBER', null, null, 'COLUMN', 'VALUE_2', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_2', 'VAT_CUST_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_2', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_2', 'VAT_DEST_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_2', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_2', 'VAT_ORIG_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_2', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_2', 'VAT_VEND_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_2', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_3', 'OBJECT_CALC_COMPONENT', 'NUMBER', null, null, 'COLUMN', 'VALUE_3', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_3', 'VAT_CUST_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_3', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_3', 'VAT_DEST_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_3', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_3', 'VAT_ORIG_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_3', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_3', 'VAT_VEND_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_3', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_4', 'OBJECT_CALC_COMPONENT', 'NUMBER', null, null, 'COLUMN', 'VALUE_4', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_4', 'VAT_CUST_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_4', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_4', 'VAT_DEST_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_4', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_4', 'VAT_ORIG_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_4', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_4', 'VAT_VEND_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_4', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_5', 'OBJECT_CALC_COMPONENT', 'NUMBER', null, null, 'COLUMN', 'VALUE_5', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_5', 'VAT_CUST_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_5', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_5', 'VAT_DEST_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_5', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_5', 'VAT_ORIG_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_5', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_5', 'VAT_VEND_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_5', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_6', 'VAT_CUST_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_6', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_6', 'VAT_DEST_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_6', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_6', 'VAT_ORIG_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_6', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_6', 'VAT_VEND_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_6', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_7', 'VAT_CUST_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_7', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_7', 'VAT_DEST_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_7', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_7', 'VAT_ORIG_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_7', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_7', 'VAT_VEND_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_7', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_8', 'VAT_CUST_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_8', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_8', 'VAT_DEST_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_8', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_8', 'VAT_ORIG_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_8', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_8', 'VAT_VEND_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_8', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_9', 'VAT_CUST_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_9', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_9', 'VAT_DEST_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_9', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_9', 'VAT_ORIG_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_9', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_9', 'VAT_VEND_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_9', null FROM DUAL
 ) n
ON (o.ATTRIBUTE_NAME = n.ATTRIBUTE_NAME
 AND o.CLASS_NAME = n.CLASS_NAME)
WHEN MATCHED THEN UPDATE SET
o.APP_SPACE_CNTX = n.APP_SPACE_CNTX
,o.DATA_TYPE = n.DATA_TYPE
,o.DB_JOIN_TABLE = n.DB_JOIN_TABLE
,o.DB_JOIN_WHERE = n.DB_JOIN_WHERE
,o.DB_MAPPING_TYPE = n.DB_MAPPING_TYPE
,o.DB_SQL_SYNTAX = n.DB_SQL_SYNTAX
,o.IS_KEY = n.IS_KEY
,o.LAST_UPDATED_BY = 'UPGD-TOOL-12.0-DM'
,o.REV_NO = o.REV_NO+1
WHEN NOT MATCHED THEN INSERT
(APP_SPACE_CNTX,ATTRIBUTE_NAME,CLASS_NAME,DATA_TYPE,DB_JOIN_TABLE,DB_JOIN_WHERE,DB_MAPPING_TYPE,DB_SQL_SYNTAX,IS_KEY,CREATED_BY)
VALUES( n.APP_SPACE_CNTX, n.ATTRIBUTE_NAME, n.CLASS_NAME, n.DATA_TYPE, n.DB_JOIN_TABLE, n.DB_JOIN_WHERE, n.DB_MAPPING_TYPE, n.DB_SQL_SYNTAX, n.IS_KEY,'UPGD-TOOL-12.0-DM');


MERGE INTO CLASS_ATTR_PROPERTY_CNFG o USING 
(
SELECT
 null ATTRIBUTE_NAME, null CLASS_NAME, null OWNER_CNTX, null PRESENTATION_CNTX, null PROPERTY_CODE, null PROPERTY_TYPE, null PROPERTY_VALUE FROM DUAL WHERE 1=0
UNION 
 SELECT 'DATE_1', 'TANK_FINDER_OBJECTS', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '9114' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'TANK_FINDER_OBJECTS', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'TANK_FINDER_OBJECTS', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Date 1' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 1' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 1' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '9114' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'vieweditable', 'STATIC_PRESENTATION', 'false' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '260' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 1' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 1' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '260' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '260' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 1' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 1' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '260' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '260' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 1' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 1' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '260' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '260' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 1' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 1' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '260' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '350' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 10' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 10' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '350' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '350' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 10' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 10' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '350' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '350' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 10' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 10' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '350' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '350' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 10' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 10' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '350' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'TANK_FINDER_OBJECTS', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '9115' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'TANK_FINDER_OBJECTS', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'TANK_FINDER_OBJECTS', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Date 2' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 2' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 2' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '9115' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'vieweditable', 'STATIC_PRESENTATION', 'false' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '270' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 2' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 2' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '270' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '270' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 2' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 2' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '270' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '270' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 2' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 2' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '270' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '270' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 2' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 2' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '270' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'TANK_FINDER_OBJECTS', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '9116' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'TANK_FINDER_OBJECTS', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'TANK_FINDER_OBJECTS', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Date 3' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 3' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 3' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '9116' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'vieweditable', 'STATIC_PRESENTATION', 'false' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '280' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 3' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 3' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '280' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '280' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 3' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 3' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '280' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '280' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 3' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 3' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '280' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '280' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 3' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 3' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '280' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'TANK_FINDER_OBJECTS', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '9117' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'TANK_FINDER_OBJECTS', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'TANK_FINDER_OBJECTS', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Date 4' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 4' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 4' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '9117' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'vieweditable', 'STATIC_PRESENTATION', 'false' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '290' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 4' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 4' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '290' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '290' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 4' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 4' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '290' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '290' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 4' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 4' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '290' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '290' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 4' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 4' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '290' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'TANK_FINDER_OBJECTS', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '9118' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'TANK_FINDER_OBJECTS', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'TANK_FINDER_OBJECTS', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Date 5' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 5' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 5' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '9118' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'vieweditable', 'STATIC_PRESENTATION', 'false' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '300' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 5' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 5' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '300' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '300' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 5' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 5' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '300' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '300' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 5' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 5' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '300' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '300' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 5' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 5' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '300' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '310' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 6' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 6' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '310' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '310' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 6' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 6' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '310' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '310' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 6' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 6' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '310' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '310' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 6' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 6' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '310' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '320' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 7' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 7' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '320' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '320' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 7' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 7' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '320' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '320' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 7' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 7' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '320' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '320' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 7' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 7' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '320' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '330' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 8' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 8' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '330' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '330' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 8' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 8' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '330' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '330' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 8' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 8' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '330' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '330' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 8' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 8' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '330' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '340' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 9' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 9' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '340' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '340' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 9' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 9' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '340' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '340' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 9' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 9' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '340' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '340' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 9' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 9' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '340' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'TANK_FINDER_OBJECTS', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '9155' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'TANK_FINDER_OBJECTS', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'TANK_FINDER_OBJECTS', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'TEXT_1' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 1' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 1' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '9155' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'vieweditable', 'STATIC_PRESENTATION', 'false' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '60' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 1' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 1' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '60' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '60' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 1' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 1' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '60' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '60' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 1' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 1' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '60' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '60' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 1' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 1' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '60' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'TANK_FINDER_OBJECTS', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '9164' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'TANK_FINDER_OBJECTS', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'TANK_FINDER_OBJECTS', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'TEXT_10' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 10' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 10' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '9164' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'vieweditable', 'STATIC_PRESENTATION', 'false' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 10' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 10' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 10' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 10' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 10' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 10' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 10' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 10' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'TANK_FINDER_OBJECTS', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '9156' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'TANK_FINDER_OBJECTS', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'TANK_FINDER_OBJECTS', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'TEXT_2' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 2' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 2' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '9156' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'vieweditable', 'STATIC_PRESENTATION', 'false' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '70' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 2' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 2' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '70' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '70' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 2' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 2' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '70' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '70' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 2' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 2' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '70' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '70' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 2' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 2' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '70' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'TANK_FINDER_OBJECTS', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '9157' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'TANK_FINDER_OBJECTS', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'TANK_FINDER_OBJECTS', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'TEXT_3' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 3' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 3' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '9157' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'vieweditable', 'STATIC_PRESENTATION', 'false' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '80' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 3' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 3' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '80' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '80' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 3' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 3' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '80' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '80' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 3' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 3' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '80' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '80' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 3' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 3' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '80' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'TANK_FINDER_OBJECTS', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '9158' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'TANK_FINDER_OBJECTS', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'TANK_FINDER_OBJECTS', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'TEXT_4' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 4' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 4' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '9158' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'vieweditable', 'STATIC_PRESENTATION', 'false' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '90' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 4' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 4' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '90' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '90' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 4' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 4' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '90' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '90' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 4' FROM DUAL
) n
ON (o.ATTRIBUTE_NAME = n.ATTRIBUTE_NAME
 AND o.CLASS_NAME = n.CLASS_NAME
 AND o.OWNER_CNTX = n.OWNER_CNTX
 AND o.PRESENTATION_CNTX = n.PRESENTATION_CNTX
 AND o.PROPERTY_CODE = n.PROPERTY_CODE
 AND o.PROPERTY_TYPE = n.PROPERTY_TYPE)
WHEN MATCHED THEN UPDATE SET
o.PROPERTY_VALUE = n.PROPERTY_VALUE
,o.LAST_UPDATED_BY = 'UPGD-TOOL-12.0-DM'
,o.REV_NO = o.REV_NO+1
WHEN NOT MATCHED THEN INSERT
(ATTRIBUTE_NAME,CLASS_NAME,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_CODE,PROPERTY_TYPE,PROPERTY_VALUE,CREATED_BY)
VALUES( n.ATTRIBUTE_NAME, n.CLASS_NAME, n.OWNER_CNTX, n.PRESENTATION_CNTX, n.PROPERTY_CODE, n.PROPERTY_TYPE, n.PROPERTY_VALUE,'UPGD-TOOL-12.0-DM');

MERGE INTO CLASS_ATTR_PROPERTY_CNFG o USING 
(
SELECT
 null ATTRIBUTE_NAME, null CLASS_NAME, null OWNER_CNTX, null PRESENTATION_CNTX, null PROPERTY_CODE, null PROPERTY_TYPE, null PROPERTY_VALUE FROM DUAL WHERE 1=0
UNION 
 SELECT 'TEXT_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 4' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '90' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '90' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 4' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 4' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '90' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'TANK_FINDER_OBJECTS', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '9159' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'TANK_FINDER_OBJECTS', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'TANK_FINDER_OBJECTS', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'TEXT_5' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 5' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 5' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '9159' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'vieweditable', 'STATIC_PRESENTATION', 'false' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 5' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 5' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 5' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 5' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 5' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 5' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 5' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 5' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'TANK_FINDER_OBJECTS', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '9160' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'TANK_FINDER_OBJECTS', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'TANK_FINDER_OBJECTS', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'TEXT_6' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 6' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 6' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '9160' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'vieweditable', 'STATIC_PRESENTATION', 'false' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '110' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 6' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 6' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '110' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '110' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 6' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 6' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '110' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '110' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 6' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 6' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '110' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '110' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 6' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 6' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '110' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'TANK_FINDER_OBJECTS', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '9161' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'TANK_FINDER_OBJECTS', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'TANK_FINDER_OBJECTS', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'TEXT_7' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 7' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 7' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '9161' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'vieweditable', 'STATIC_PRESENTATION', 'false' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 7' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 7' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 7' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 7' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 7' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 7' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 7' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 7' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN', '1000', '/EC', 'LABEL', 'APPLICATION', 'AL/Royalty' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN', '1000', '/EC', 'PopupCache', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN', '1000', '/EC', 'PopupDependency', 'STATIC_PRESENTATION', 'Screen.this.currentRow.TEXT_8=ReturnField.NAME' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN', '1000', '/EC', 'PopupHeight', 'STATIC_PRESENTATION', '300' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN', '1000', '/EC', 'PopupLayout', 'STATIC_PRESENTATION', '/com.ec.revn.cd/layout/ec_codes.xml' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN', '1000', '/EC', 'PopupQueryURL', 'STATIC_PRESENTATION', '/com.ec.revn.sp/query/get_transaction_mapping_other_line_item_popup.xml' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN', '1000', '/EC', 'PopupReturnColumn', 'STATIC_PRESENTATION', 'CODE_TEXT' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN', '1000', '/EC', 'PopupWhereColumn', 'STATIC_PRESENTATION', 'CODE_TYPE' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN', '1000', '/EC', 'PopupWhereOperator', 'STATIC_PRESENTATION', '=' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN', '1000', '/EC', 'PopupWhereValue', 'STATIC_PRESENTATION', 'YES_NO' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN', '1000', '/EC', 'PopupWidth', 'STATIC_PRESENTATION', '350' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN', '1000', '/EC', 'viewhidden', 'DYNAMIC_PRESENTATION', 'DECODE(REF_CLASS,''COST_MAPPING'',null,''false'')' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN', '1000', '/EC', 'viewtranslate', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_CM', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_CM', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_CM', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_CM', '1000', '/EC', 'LABEL', 'APPLICATION', 'AL/Royalty' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_CM', '1000', '/EC', 'PopupDependency', 'STATIC_PRESENTATION', 'Screen.this.currentRow.TEXT_8=ReturnField.CODE' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_CM', '1000', '/EC', 'PopupHeight', 'STATIC_PRESENTATION', '300' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_CM', '1000', '/EC', 'PopupLayout', 'STATIC_PRESENTATION', '/com.ec.frmw.co.screens/layout/ec_code_popup.xml' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_CM', '1000', '/EC', 'PopupQueryURL', 'STATIC_PRESENTATION', '/com.ec.frmw.co.screens/query/ec_code_popup.xml' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_CM', '1000', '/EC', 'PopupReturnColumn', 'STATIC_PRESENTATION', 'CODE_TEXT' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_CM', '1000', '/EC', 'PopupWhereColumn', 'STATIC_PRESENTATION', 'CODE_TYPE' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_CM', '1000', '/EC', 'PopupWhereOperator', 'STATIC_PRESENTATION', '=' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_CM', '1000', '/EC', 'PopupWhereValue', 'STATIC_PRESENTATION', 'YES_NO' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_CM', '1000', '/EC', 'PopupWidth', 'STATIC_PRESENTATION', '250' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_CM', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_CM', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_DOC', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_DOC', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_DOC', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'LABEL', 'APPLICATION', 'AL/Royalty' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'PopupCache', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'PopupDependency', 'STATIC_PRESENTATION', 'Screen.this.currentRow.TEXT_8=ReturnField.NAME' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'PopupHeight', 'STATIC_PRESENTATION', '300' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'PopupLayout', 'STATIC_PRESENTATION', '/com.ec.revn.cd/layout/ec_codes.xml' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'PopupQueryURL', 'STATIC_PRESENTATION', '/com.ec.revn.sp/query/get_transaction_mapping_other_line_item_popup.xml' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'PopupReturnColumn', 'STATIC_PRESENTATION', 'CODE_TEXT' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'PopupWhereColumn', 'STATIC_PRESENTATION', 'CODE_TYPE' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'PopupWhereOperator', 'STATIC_PRESENTATION', '=' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'PopupWhereValue', 'STATIC_PRESENTATION', 'YES_NO' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'PopupWidth', 'STATIC_PRESENTATION', '350' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'viewhidden', 'DYNAMIC_PRESENTATION', 'DECODE(REF_CLASS,''COST_MAPPING'',null,''false'')' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'viewtranslate', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI', '1000', '/EC', 'LABEL', 'APPLICATION', 'AL/Royalty' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI', '1000', '/EC', 'PopupCache', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI', '1000', '/EC', 'PopupDependency', 'STATIC_PRESENTATION', 'Screen.this.currentRow.TEXT_8=ReturnField.NAME' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI', '1000', '/EC', 'PopupHeight', 'STATIC_PRESENTATION', '300' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI', '1000', '/EC', 'PopupLayout', 'STATIC_PRESENTATION', '/com.ec.revn.cd/layout/ec_codes.xml' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI', '1000', '/EC', 'PopupQueryURL', 'STATIC_PRESENTATION', '/com.ec.revn.sp/query/get_transaction_mapping_other_line_item_popup.xml' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI', '1000', '/EC', 'PopupReturnColumn', 'STATIC_PRESENTATION', 'CODE_TEXT' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI', '1000', '/EC', 'PopupWhereColumn', 'STATIC_PRESENTATION', 'CODE_TYPE' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI', '1000', '/EC', 'PopupWhereOperator', 'STATIC_PRESENTATION', '=' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI', '1000', '/EC', 'PopupWhereValue', 'STATIC_PRESENTATION', 'YES_NO' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI', '1000', '/EC', 'PopupWidth', 'STATIC_PRESENTATION', '350' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI', '1000', '/EC', 'viewhidden', 'DYNAMIC_PRESENTATION', 'DECODE(REF_CLASS,''COST_MAPPING'',null,''false'')' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI', '1000', '/EC', 'viewtranslate', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI_LINE', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI_LINE', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI_LINE', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'LABEL', 'APPLICATION', 'AL/Royalty' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'PopupCache', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'PopupDependency', 'STATIC_PRESENTATION', 'Screen.this.currentRow.TEXT_8=ReturnField.NAME' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'PopupHeight', 'STATIC_PRESENTATION', '300' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'PopupLayout', 'STATIC_PRESENTATION', '/com.ec.revn.cd/layout/ec_codes.xml' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'PopupQueryURL', 'STATIC_PRESENTATION', '/com.ec.revn.sp/query/get_transaction_mapping_other_line_item_popup.xml' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'PopupReturnColumn', 'STATIC_PRESENTATION', 'CODE_TEXT' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'PopupWhereColumn', 'STATIC_PRESENTATION', 'CODE_TYPE' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'PopupWhereOperator', 'STATIC_PRESENTATION', '=' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'PopupWhereValue', 'STATIC_PRESENTATION', 'YES_NO' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'PopupWidth', 'STATIC_PRESENTATION', '350' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'viewhidden', 'DYNAMIC_PRESENTATION', 'DECODE(REF_CLASS,''COST_MAPPING'',null,''false'')' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'viewtranslate', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'TANK_FINDER_OBJECTS', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '9162' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'TANK_FINDER_OBJECTS', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'TANK_FINDER_OBJECTS', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'TEXT_8' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 8' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 8' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '9162' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'vieweditable', 'STATIC_PRESENTATION', 'false' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '130' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 8' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 8' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '130' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '130' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 8' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 8' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '130' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '130' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 8' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 8' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '130' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '130' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 8' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 8' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '130' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN', '1000', '/EC', 'LABEL', 'APPLICATION', 'Location' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN', '1000', '/EC', 'PopupCache', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN', '1000', '/EC', 'PopupDependency', 'STATIC_PRESENTATION', 'Screen.this.currentRow.TEXT_9=ReturnField.CODE' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN', '1000', '/EC', 'PopupHeight', 'STATIC_PRESENTATION', '300' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN', '1000', '/EC', 'PopupLayout', 'STATIC_PRESENTATION', '/com.ec.revn.cd/layout/ec_codes.xml' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN', '1000', '/EC', 'PopupQueryURL', 'STATIC_PRESENTATION', '/com.ec.revn.sp/query/get_transaction_mapping_other_line_item_popup.xml' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN', '1000', '/EC', 'PopupReturnColumn', 'STATIC_PRESENTATION', 'CODE_TEXT' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN', '1000', '/EC', 'PopupWhereColumn', 'STATIC_PRESENTATION', 'CODE_TYPE' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN', '1000', '/EC', 'PopupWhereOperator', 'STATIC_PRESENTATION', '=' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN', '1000', '/EC', 'PopupWhereValue', 'STATIC_PRESENTATION', 'CVE_LOCATION' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN', '1000', '/EC', 'PopupWidth', 'STATIC_PRESENTATION', '350' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN', '1000', '/EC', 'viewhidden', 'DYNAMIC_PRESENTATION', 'DECODE(REF_CLASS,''COST_MAPPING'',null,''false'')' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN', '1000', '/EC', 'viewtranslate', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_CM', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '130' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_CM', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_CM', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_CM', '1000', '/EC', 'LABEL', 'APPLICATION', 'Location' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_CM', '1000', '/EC', 'PopupDependency', 'STATIC_PRESENTATION', 'Screen.this.currentRow.TEXT_9=ReturnField.CODE' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_CM', '1000', '/EC', 'PopupHeight', 'STATIC_PRESENTATION', '300' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_CM', '1000', '/EC', 'PopupLayout', 'STATIC_PRESENTATION', '/com.ec.frmw.co.screens/layout/ec_code_popup.xml' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_CM', '1000', '/EC', 'PopupQueryURL', 'STATIC_PRESENTATION', '/com.ec.frmw.co.screens/query/ec_code_popup.xml' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_CM', '1000', '/EC', 'PopupReturnColumn', 'STATIC_PRESENTATION', 'CODE_TEXT' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_CM', '1000', '/EC', 'PopupWhereColumn', 'STATIC_PRESENTATION', 'CODE_TYPE' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_CM', '1000', '/EC', 'PopupWhereOperator', 'STATIC_PRESENTATION', '=' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_CM', '1000', '/EC', 'PopupWhereValue', 'STATIC_PRESENTATION', 'CVE_LOCATION' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_CM', '1000', '/EC', 'PopupWidth', 'STATIC_PRESENTATION', '250' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_CM', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '130' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_CM', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_DOC', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_DOC', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_DOC', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'LABEL', 'APPLICATION', 'Location' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'PopupCache', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'PopupDependency', 'STATIC_PRESENTATION', 'Screen.this.currentRow.TEXT_9=ReturnField.CODE' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'PopupHeight', 'STATIC_PRESENTATION', '300' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'PopupLayout', 'STATIC_PRESENTATION', '/com.ec.revn.cd/layout/ec_codes.xml' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'PopupQueryURL', 'STATIC_PRESENTATION', '/com.ec.revn.sp/query/get_transaction_mapping_other_line_item_popup.xml' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'PopupReturnColumn', 'STATIC_PRESENTATION', 'CODE_TEXT' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'PopupWhereColumn', 'STATIC_PRESENTATION', 'CODE_TYPE' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'PopupWhereOperator', 'STATIC_PRESENTATION', '=' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'PopupWhereValue', 'STATIC_PRESENTATION', 'CVE_LOCATION' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'PopupWidth', 'STATIC_PRESENTATION', '350' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'viewhidden', 'DYNAMIC_PRESENTATION', 'DECODE(REF_CLASS,''COST_MAPPING'',null,''false'')' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'viewtranslate', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI', '1000', '/EC', 'LABEL', 'APPLICATION', 'Location' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI', '1000', '/EC', 'PopupCache', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI', '1000', '/EC', 'PopupDependency', 'STATIC_PRESENTATION', 'Screen.this.currentRow.TEXT_9=ReturnField.CODE' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI', '1000', '/EC', 'PopupHeight', 'STATIC_PRESENTATION', '300' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI', '1000', '/EC', 'PopupLayout', 'STATIC_PRESENTATION', '/com.ec.revn.cd/layout/ec_codes.xml' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI', '1000', '/EC', 'PopupQueryURL', 'STATIC_PRESENTATION', '/com.ec.revn.sp/query/get_transaction_mapping_other_line_item_popup.xml' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI', '1000', '/EC', 'PopupReturnColumn', 'STATIC_PRESENTATION', 'CODE_TEXT' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI', '1000', '/EC', 'PopupWhereColumn', 'STATIC_PRESENTATION', 'CODE_TYPE' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI', '1000', '/EC', 'PopupWhereOperator', 'STATIC_PRESENTATION', '=' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI', '1000', '/EC', 'PopupWhereValue', 'STATIC_PRESENTATION', 'CVE_LOCATION' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI', '1000', '/EC', 'PopupWidth', 'STATIC_PRESENTATION', '350' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI', '1000', '/EC', 'viewhidden', 'DYNAMIC_PRESENTATION', 'DECODE(REF_CLASS,''COST_MAPPING'',null,''false'')' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI', '1000', '/EC', 'viewtranslate', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI_LINE', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI_LINE', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI_LINE', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'LABEL', 'APPLICATION', 'Location' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'PopupCache', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'PopupDependency', 'STATIC_PRESENTATION', 'Screen.this.currentRow.TEXT_9=ReturnField.CODE' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'PopupHeight', 'STATIC_PRESENTATION', '300' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'PopupLayout', 'STATIC_PRESENTATION', '/com.ec.revn.cd/layout/ec_codes.xml' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'PopupQueryURL', 'STATIC_PRESENTATION', '/com.ec.revn.sp/query/get_transaction_mapping_other_line_item_popup.xml' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'PopupReturnColumn', 'STATIC_PRESENTATION', 'CODE_TEXT' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'PopupWhereColumn', 'STATIC_PRESENTATION', 'CODE_TYPE' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'PopupWhereOperator', 'STATIC_PRESENTATION', '=' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'PopupWhereValue', 'STATIC_PRESENTATION', 'CVE_LOCATION' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'PopupWidth', 'STATIC_PRESENTATION', '350' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'viewhidden', 'DYNAMIC_PRESENTATION', 'DECODE(REF_CLASS,''COST_MAPPING'',null,''false'')' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'viewtranslate', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'TANK_FINDER_OBJECTS', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '9163' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'TANK_FINDER_OBJECTS', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'TANK_FINDER_OBJECTS', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'TEXT_9' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 9' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 9' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '9163' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'vieweditable', 'STATIC_PRESENTATION', 'false' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '140' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 9' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 9' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '140' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '140' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 9' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 9' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '140' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '140' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 9' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 9' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '140' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '140' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 9' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 9' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '140' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'OBJECT_CALC_COMPONENT', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '600' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'OBJECT_CALC_COMPONENT', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value Column 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'OBJECT_CALC_COMPONENT', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '600' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_CARGO_DG_LOG', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '900' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_CARGO_DG_LOG', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_CARGO_DG_LOG', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_CARGO_DG_LOG', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_CARGO_DG_LOG', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_CARGO_DG_LOG', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_CARGO_DG_LOG', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '900' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_CARGO_DG_LOG', '1000', '/EC', 'viewhidden', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_CARGO_DG_LOG', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '47' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_CASCADE_LOG', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '900' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_CASCADE_LOG', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_CASCADE_LOG', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_CASCADE_LOG', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_CASCADE_LOG', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_CASCADE_LOG', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_CASCADE_LOG', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '900' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_CASCADE_LOG', '1000', '/EC', 'viewhidden', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_CASCADE_LOG', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '300' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_COST_MAP_LOG', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '110' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_COST_MAP_LOG', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_COST_MAP_LOG', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_COST_MAP_LOG', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_COST_MAP_LOG', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_COST_MAP_LOG', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_COST_MAP_LOG', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '110' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_COST_MAP_LOG', '1000', '/EC', 'viewhidden', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_COST_MAP_LOG', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '47' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_ERP_DG_LOG', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '900' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_ERP_DG_LOG', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_ERP_DG_LOG', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_ERP_DG_LOG', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_ERP_DG_LOG', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_ERP_DG_LOG', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_ERP_DG_LOG', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '900' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_ERP_DG_LOG', '1000', '/EC', 'viewhidden', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_ERP_DG_LOG', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '47' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_INTERFACE_LOG', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '900' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_INTERFACE_LOG', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_INTERFACE_LOG', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_INTERFACE_LOG', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_INTERFACE_LOG', '1000', '/EC', 'LABEL', 'APPLICATION', 'Source Entry No' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_INTERFACE_LOG', '1000', '/EC', 'NAME', 'APPLICATION', 'Source Entry No' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_INTERFACE_LOG', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '900' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_INTERFACE_LOG', '1000', '/EC', 'sortheader', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_INTERFACE_LOG', '1000', '/EC', 'vieweditable', 'STATIC_PRESENTATION', 'false' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_INTERFACE_LOG', '1000', '/EC', 'viewtype', 'STATIC_PRESENTATION', 'label' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_INTERFACE_LOG', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '300' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_PERIOD_DG_LOG', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '900' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_PERIOD_DG_LOG', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_PERIOD_DG_LOG', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_PERIOD_DG_LOG', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_PERIOD_DG_LOG', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_PERIOD_DG_LOG', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_PERIOD_DG_LOG', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '900' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_PERIOD_DG_LOG', '1000', '/EC', 'viewhidden', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_PERIOD_DG_LOG', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '300' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_REVERSE_DG_LOG', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '900' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_REVERSE_DG_LOG', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_REVERSE_DG_LOG', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_REVERSE_DG_LOG', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_REVERSE_DG_LOG', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_REVERSE_DG_LOG', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_REVERSE_DG_LOG', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '900' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_REVERSE_DG_LOG', '1000', '/EC', 'viewhidden', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_REVERSE_DG_LOG', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '47' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_SUMMARY_PC_LOG', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '130' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_SUMMARY_PC_LOG', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_SUMMARY_PC_LOG', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_SUMMARY_PC_LOG', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_SUMMARY_PC_LOG', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_SUMMARY_PC_LOG', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_SUMMARY_PC_LOG', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '130' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_SUMMARY_PC_LOG', '1000', '/EC', 'viewhidden', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_SUMMARY_PC_LOG', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '47' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_TI_LOG', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '900' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_TI_LOG', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_TI_LOG', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_TI_LOG', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_TI_LOG', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_TI_LOG', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_TI_LOG', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '900' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_TI_LOG', '1000', '/EC', 'viewhidden', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_TI_LOG', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '300' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '160' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '160' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '160' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '160' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '160' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '160' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '160' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '160' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '250' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 10' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 10' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '250' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '250' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 10' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 10' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '250' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '250' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL
) n
ON (o.ATTRIBUTE_NAME = n.ATTRIBUTE_NAME
 AND o.CLASS_NAME = n.CLASS_NAME
 AND o.OWNER_CNTX = n.OWNER_CNTX
 AND o.PRESENTATION_CNTX = n.PRESENTATION_CNTX
 AND o.PROPERTY_CODE = n.PROPERTY_CODE
 AND o.PROPERTY_TYPE = n.PROPERTY_TYPE)
WHEN MATCHED THEN UPDATE SET
o.PROPERTY_VALUE = n.PROPERTY_VALUE
,o.LAST_UPDATED_BY = 'UPGD-TOOL-12.0-DM'
,o.REV_NO = o.REV_NO+1
WHEN NOT MATCHED THEN INSERT
(ATTRIBUTE_NAME,CLASS_NAME,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_CODE,PROPERTY_TYPE,PROPERTY_VALUE,CREATED_BY)
VALUES( n.ATTRIBUTE_NAME, n.CLASS_NAME, n.OWNER_CNTX, n.PRESENTATION_CNTX, n.PROPERTY_CODE, n.PROPERTY_TYPE, n.PROPERTY_VALUE,'UPGD-TOOL-12.0-DM');


MERGE INTO CLASS_ATTR_PROPERTY_CNFG o USING 
(
SELECT
 null ATTRIBUTE_NAME, null CLASS_NAME, null OWNER_CNTX, null PRESENTATION_CNTX, null PROPERTY_CODE, null PROPERTY_TYPE, null PROPERTY_VALUE FROM DUAL WHERE 1=0
UNION 
 SELECT 'VALUE_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 10' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 10' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '250' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '250' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 10' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 10' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '250' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'OBJECT_CALC_COMPONENT', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '700' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'OBJECT_CALC_COMPONENT', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value Column 2' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'OBJECT_CALC_COMPONENT', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '700' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '170' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 2' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 2' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '170' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '170' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 2' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 2' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '170' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '170' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 2' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 2' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '170' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '170' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 2' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 2' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '170' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'OBJECT_CALC_COMPONENT', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '800' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'OBJECT_CALC_COMPONENT', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value Column 3' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'OBJECT_CALC_COMPONENT', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '800' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '180' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 3' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 3' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '180' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '180' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 3' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 3' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '180' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '180' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 3' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 3' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '180' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '180' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 3' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 3' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '180' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'OBJECT_CALC_COMPONENT', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '900' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'OBJECT_CALC_COMPONENT', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value Column 4' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'OBJECT_CALC_COMPONENT', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '900' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '190' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 4' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 4' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '190' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '190' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 4' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 4' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '190' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '190' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 4' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 4' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '190' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '190' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 4' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 4' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '190' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'OBJECT_CALC_COMPONENT', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '1000' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'OBJECT_CALC_COMPONENT', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value Column 5' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'OBJECT_CALC_COMPONENT', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '1000' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '200' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 5' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 5' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '200' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '200' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 5' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 5' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '200' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '200' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 5' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 5' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '200' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '200' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 5' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 5' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '200' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '210' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 6' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 6' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '210' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '210' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 6' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 6' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '210' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '210' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 6' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 6' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '210' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '210' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 6' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 6' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '210' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '220' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 7' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 7' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '220' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '220' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 7' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 7' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '220' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '220' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 7' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 7' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '220' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '220' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 7' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 7' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '220' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '230' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 8' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 8' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '230' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '230' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 8' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 8' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '230' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '230' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 8' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 8' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '230' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '230' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 8' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 8' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '230' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '240' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 9' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 9' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '240' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '240' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 9' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 9' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '240' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '240' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 9' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 9' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '240' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '240' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 9' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 9' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '240' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL
) n
ON (o.ATTRIBUTE_NAME = n.ATTRIBUTE_NAME
 AND o.CLASS_NAME = n.CLASS_NAME
 AND o.OWNER_CNTX = n.OWNER_CNTX
 AND o.PRESENTATION_CNTX = n.PRESENTATION_CNTX
 AND o.PROPERTY_CODE = n.PROPERTY_CODE
 AND o.PROPERTY_TYPE = n.PROPERTY_TYPE)
WHEN MATCHED THEN UPDATE SET
o.PROPERTY_VALUE = n.PROPERTY_VALUE
,o.LAST_UPDATED_BY = 'UPGD-TOOL-12.0-DM'
,o.REV_NO = o.REV_NO+1
WHEN NOT MATCHED THEN INSERT
(ATTRIBUTE_NAME,CLASS_NAME,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_CODE,PROPERTY_TYPE,PROPERTY_VALUE,CREATED_BY)
VALUES( n.ATTRIBUTE_NAME, n.CLASS_NAME, n.OWNER_CNTX, n.PRESENTATION_CNTX, n.PROPERTY_CODE, n.PROPERTY_TYPE, n.PROPERTY_VALUE,'UPGD-TOOL-12.0-DM');

END;
--~^UTDELIM^~--

begin
  for c in (
    select table_name from user_tables
      where table_name in
      (
        'PROD_AREA_FORECAST', 
        'PROD_FIELD_FORECAST',
        'PROD_PRODUNIT_FORECAST',
        'PROD_FORECAST',
        'PROD_STORAGE_FORECAST',
        'PROD_SUB_AREA_FORECAST',
        'PROD_SUB_FIELD_FORECAST',
        'PROD_WELL_FORECAST'
    ) )
    LOOP 
    EcDp_Generate.generate(c.table_name,EcDp_Generate.IU_TRIGGERS);
    END LOOP;
END;
--~^UTDELIM^~--  

begin
  for c in (
    select table_name from user_tables
      where table_name in
      (
      'PROD_AREA_FORECAST',
      'PROD_FIELD_FORECAST',
      'PROD_FORECAST',
      'PROD_PRODUNIT_FORECAST',
      'PROD_STORAGE_FORECAST',
      'PROD_SUB_AREA_FORECAST',
      'PROD_SUB_FIELD_FORECAST',
      'PROD_WELL_FORECAST' 
    ) )
    LOOP
      EcDp_Generate.generate(c.table_name,EcDp_Generate.IUR_TRIGGERS);
    END LOOP;
END;
--~^UTDELIM^~-- 

BEGIN
	EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW CLASS';
EXCEPTION
WHEN OTHERS
THEN
 NULL;
END;
--~^UTDELIM^~--


CREATE MATERIALIZED VIEW CLASS 
-------------------------------------------------------------------------------------
-- CLASS
--
-- $Revision: 1.4 $
--
--  Purpose: Select the row from Class_cnfg with the higherst owner context, allowing templates and projects to
--           override product settings without changing the product row. 
--
-------------------------------------------------------------------------------------
BUILD IMMEDIATE
REFRESH ON DEMAND
AS
with class_property_max as(
  select class_name, property_code, property_value
  from class_property_cnfg p1 
  where p1.presentation_cntx in ('/', '/EC')
  and owner_cntx = (
        select max(owner_cntx) 
        from class_property_cnfg p1_1
        where p1.class_name = p1_1.class_name 
        and p1.property_code = p1_1.property_code
        and p1.presentation_cntx = p1_1.presentation_cntx
        )  
)
select 
c.CLASS_NAME                                      
,cast(null as varchar2(24)) as SUPER_CLASS                                     
,c.CLASS_TYPE                                      
,c.APP_SPACE_CNTX as APP_SPACE_CODE                                  
,c.TIME_SCOPE_CODE    
,c.OWNER_CLASS_NAME    
,cast(p3.property_value as varchar2(24)) as CLASS_SHORT_CODE
,cast(p4.property_value as varchar2(100)) as LABEL
,cast(p5.property_value as varchar2(1)) as ENSURE_REV_TEXT_ON_UPD
,cast(p6.property_value as varchar2(1)) as READ_ONLY_IND
,cast(p7.property_value as varchar2(1)) as INCLUDE_IN_VALIDATION
,cast(p18.property_value as varchar2(1)) as CALC_ENGINE_TABLE_WRITE_IND
,cast(p8.property_value as varchar2(4000)) as JOURNAL_RULE_DB_SYNTAX
,cast(NULL as varchar2(4000)) as CALC_MAPPING_SYNTAX
,cast(p10.property_value as varchar2(4000)) as LOCK_RULE
,cast(p11.property_value as varchar2(1)) as LOCK_IND
,cast(p12.property_value as varchar2(1)) as ACCESS_CONTROL_IND
,cast(p13.property_value as varchar2(1)) as APPROVAL_IND
,cast(p14.property_value as varchar2(1)) as SKIP_TRG_CHECK_IND
,cast(p15.property_value as varchar2(1)) as INCLUDE_WEBSERVICE
,cast(p16.property_value as varchar2(1)) as CREATE_EV_IND
,cast(p19.property_value as varchar2(1)) as INCLUDE_IN_MAPPING_IND
,cast(p17.property_value as varchar2(4000)) as DESCRIPTION
, cast(null as varchar2(24)) as CLASS_VERSION                                   
,c.RECORD_STATUS                                   
,c.CREATED_BY                                      
,c.CREATED_DATE                                    
,c.LAST_UPDATED_BY                                 
,c.LAST_UPDATED_DATE                               
,c.REV_NO                                          
,c.REV_TEXT                                        
,c.APPROVAL_STATE                                  
,c.APPROVAL_BY                                     
,c.APPROVAL_DATE                                   
,c.REC_ID                                          
from class_cnfg c
left join class_property_max p3 on (c.class_name = p3.class_name and p3.property_code = 'CLASS_SHORT_CODE' )
left join class_property_max p4 on (c.class_name = p4.class_name and p4.property_code = 'LABEL' )
left join class_property_max p5 on (c.class_name = p5.class_name and p5.property_code = 'ENSURE_REV_TEXT_ON_UPD' )
left join class_property_max p6 on (c.class_name = p6.class_name and p6.property_code = 'READ_ONLY_IND' )
left join class_property_max p7 on (c.class_name = p7.class_name and p7.property_code = 'INCLUDE_IN_VALIDATION' )
left join class_property_max p8 on (c.class_name = p8.class_name and p8.property_code = 'JOURNAL_RULE_DB_SYNTAX' )
left join class_property_max p10 on (c.class_name = p10.class_name and p10.property_code = 'LOCK_RULE' )
left join class_property_max p11 on (c.class_name = p11.class_name and p11.property_code = 'LOCK_IND' )
left join class_property_max p12 on (c.class_name = p12.class_name and p12.property_code = 'ACCESS_CONTROL_IND' )
left join class_property_max p13 on (c.class_name = p13.class_name and p13.property_code = 'APPROVAL_IND' )
left join class_property_max p14 on (c.class_name = p14.class_name and p14.property_code = 'SKIP_TRG_CHECK_IND' )
left join class_property_max p15 on (c.class_name = p15.class_name and p15.property_code = 'INCLUDE_WEBSERVICE' )
left join class_property_max p16 on (c.class_name = p16.class_name and p16.property_code = 'CREATE_EV_IND' )
left join class_property_max p17 on (c.class_name = p17.class_name and p17.property_code = 'DESCRIPTION' )
left join class_property_max p18 on (c.class_name = p18.class_name and p18.property_code = 'CALC_ENGINE_TABLE_WRITE_IND' )
left join class_property_max p19 on (c.class_name = p19.class_name and p19.property_code = 'INCLUDE_IN_MAPPING_IND' )
WHERE ec_install_constants.isBlockedAppSpaceCntx(c.app_space_cntx) = 0
--~^UTDELIM^~--

create unique index UIX_CLASS on Class(Class_name)
TABLESPACE &ts_index
--~^UTDELIM^~--

CREATE INDEX IFK_CLASS_2 ON CLASS
 (OWNER_CLASS_NAME)
 INITRANS 2
 MAXTRANS 255
 PCTFREE 50
 STORAGE
 (
   PCTINCREASE 50
   NEXT 65536
 )
 TABLESPACE &ts_index
--~^UTDELIM^~--

CREATE INDEX IFK_CLASS_1 ON CLASS
 (SUPER_CLASS)
 INITRANS 2
 MAXTRANS 255
 PCTFREE 50
 STORAGE
 (
   PCTINCREASE 50
   NEXT 65536
 )
 TABLESPACE &ts_index
--~^UTDELIM^~--

CREATE INDEX IR_CLASS ON CLASS
 (REC_ID)
 INITRANS 2
 MAXTRANS 255
 PCTFREE 50
 STORAGE
 (
   PCTINCREASE 50
   NEXT 65536
 )
 TABLESPACE &ts_index
--~^UTDELIM^~--

BEGIN
	EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW class_attribute';
EXCEPTION
WHEN OTHERS
THEN
 NULL;
END;
--~^UTDELIM^~--


CREATE MATERIALIZED VIEW class_attribute 
-------------------------------------------------------------------------------------
-- class_db_mapping
--
-- $Revision: 1.4 $
--
--  Purpose: Select the row with the higherst owner context, allowing templates and projects to
--           override product settings without changing the product row. 
--
-------------------------------------------------------------------------------------
BUILD IMMEDIATE
REFRESH ON DEMAND
AS
with class_attr_property_max as(
  select p1.class_name, p1.attribute_name, p1.property_code, p1.property_value
  from class_attr_property_cnfg p1, class_cnfg cc, class_attribute_cnfg ca 
  where p1.presentation_cntx in ('/EC', '/')
  and cc.class_name=p1.class_name
  and ca.class_name=p1.class_name
  and ca.attribute_name=p1.attribute_name    
  and ec_install_constants.isBlockedAppSpaceCntx(cc.app_space_cntx) = 0
  and ec_install_constants.isBlockedAppSpaceCntx(ca.app_space_cntx) = 0
  and p1.owner_cntx = (
        select max(owner_cntx) 
        from class_attr_property_cnfg p1_1
        where p1.class_name = p1_1.class_name 
        and   p1.attribute_name = p1_1.attribute_name
        and p1.property_code = p1_1.property_code
        and p1.presentation_cntx = p1_1.presentation_cntx
        )  
)
select 
ca.CLASS_NAME
,ca.attribute_name                                      
,ca.is_key
,cast(p1.property_value as varchar2(1)) as is_mandatory
,ca.APP_SPACE_CNTX as CONTEXT_CODE                                  
,ca.data_type
,cast(null as varchar2(4000)) as calc_mapping_syntax
,cast(null as varchar2(32)) as precision
,cast(null as varchar2(4000)) as default_value
,cast(p5.property_value as varchar2(1)) as disabled_ind
,cast(null as varchar2(1)) as disabled_calc_ind
,cast(p7.property_value as varchar2(1)) as report_only_ind
,cast(p8.property_value as varchar2(4000)) as description
,cast(p9.property_value as varchar2(240)) as name
,cast(null as varchar2(240)) as default_client_value
,cast(p10.property_value as varchar2(1)) as read_only_ind
,ca.RECORD_STATUS                                   
,ca.CREATED_BY                                      
,ca.CREATED_DATE                                    
,ca.LAST_UPDATED_BY                                 
,ca.LAST_UPDATED_DATE                               
,ca.REV_NO                                          
,ca.REV_TEXT                                        
,ca.APPROVAL_STATE                                  
,ca.APPROVAL_BY                                     
,ca.APPROVAL_DATE                                   
,ca.REC_ID                                          
from class_attribute_cnfg ca
inner join class_cnfg cc on cc.class_name = ca.class_name and ec_install_constants.isBlockedAppSpaceCntx(cc.app_space_cntx) = 0
left join class_attr_property_max p1 on (ca.class_name = p1.class_name and ca.attribute_name = p1.attribute_name and p1.property_code = 'IS_MANDATORY' )
left join class_attr_property_max p5 on (ca.class_name = p5.class_name and ca.attribute_name = p5.attribute_name and p5.property_code = 'DISABLED_IND' )
left join class_attr_property_max p7 on (ca.class_name = p7.class_name and ca.attribute_name = p7.attribute_name and p7.property_code = 'REPORT_ONLY_IND' )
left join class_attr_property_max p8 on (ca.class_name = p8.class_name and ca.attribute_name = p8.attribute_name and p8.property_code = 'DESCRIPTION' )
left join class_attr_property_max p9 on (ca.class_name = p9.class_name and ca.attribute_name = p9.attribute_name and p9.property_code = 'NAME' )
left join class_attr_property_max p10 on (ca.class_name = p10.class_name and ca.attribute_name = p10.attribute_name and p10.property_code = 'READ_ONLY_IND' )
where ec_install_constants.isBlockedAppSpaceCntx(ca.app_space_cntx) = 0
--~^UTDELIM^~--

create unique index uix_class_attribute on Class_attribute(Class_name,attribute_name)
TABLESPACE &ts_index
--~^UTDELIM^~--

BEGIN
	EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW class_attr_db_mapping';
EXCEPTION
WHEN OTHERS
THEN
 NULL;
END;
--~^UTDELIM^~--

CREATE MATERIALIZED VIEW class_attr_db_mapping 
-------------------------------------------------------------------------------------
-- class_db_mapping
--
-- $Revision: 1.4 $
--
--  Purpose: Select the row with the higherst owner context, allowing templates and projects to
--           override product settings without changing the product row. 
--
-------------------------------------------------------------------------------------
BUILD IMMEDIATE
REFRESH ON DEMAND
AS
with class_attr_property_max as(
  select p1.class_name, p1.attribute_name, p1.property_code, p1.property_value
  from class_attr_property_cnfg p1, class_cnfg cc, class_attribute_cnfg ca  
  where p1.presentation_cntx in ('/EC', '/')
  and cc.class_name=p1.class_name
  and ca.class_name=p1.class_name
  and ca.attribute_name=p1.attribute_name
  and ec_install_constants.isBlockedAppSpaceCntx(cc.app_space_cntx) = 0
  and ec_install_constants.isBlockedAppSpaceCntx(ca.app_space_cntx) = 0
  and owner_cntx = (
        select max(owner_cntx) 
        from class_attr_property_cnfg p1_1
        where p1.class_name = p1_1.class_name 
        and   p1.attribute_name = p1_1.attribute_name
        and p1.property_code = p1_1.property_code
        and p1.presentation_cntx = p1_1.presentation_cntx
        )  
)
select 
ca.CLASS_NAME
,ca.attribute_name                                      
,ca.db_mapping_type
,ca.db_sql_syntax
,cast(p1.property_value as number) as sort_order
,ca.db_join_table                                   
,ca.db_join_where                                   
,ca.RECORD_STATUS                                   
,ca.CREATED_BY                                      
,ca.CREATED_DATE                                    
,ca.LAST_UPDATED_BY                                 
,ca.LAST_UPDATED_DATE                               
,ca.REV_NO                                          
,ca.REV_TEXT                                        
,ca.APPROVAL_STATE                                  
,ca.APPROVAL_BY                                     
,ca.APPROVAL_DATE                                   
,ca.REC_ID                                          
from class_attribute_cnfg ca
inner join class_cnfg cc on cc.class_name = ca.class_name and ec_install_constants.isBlockedAppSpaceCntx(cc.app_space_cntx) = 0
left join class_attr_property_max p1 on (ca.class_name = p1.class_name and ca.attribute_name = p1.attribute_name and p1.property_code = 'DB_SORT_ORDER' )
where ec_install_constants.isBlockedAppSpaceCntx(ca.app_space_cntx) = 0
--~^UTDELIM^~--

create unique index uix_class_attr_db_mapping on Class_attr_db_mapping(Class_name,attribute_name)
TABLESPACE &ts_index
--~^UTDELIM^~--

CREATE INDEX IR_CLASS_ATTR_DB_MAPPING ON CLASS_ATTR_DB_MAPPING
 (REC_ID)
 INITRANS 2
 MAXTRANS 255
 PCTFREE 50
 STORAGE
 (
   PCTINCREASE 50
   NEXT 65536
 )
 TABLESPACE &ts_index
--~^UTDELIM^~--

BEGIN
	EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW class_attr_presentation';
EXCEPTION
WHEN OTHERS
THEN
 NULL;
END;
--~^UTDELIM^~--

CREATE MATERIALIZED VIEW class_attr_presentation 
-------------------------------------------------------------------------------------
--
-- $Revision: 1.4 $
--
--  Purpose: Select the row with the higherst owner context, allowing templates and projects to
--           override product settings without changing the product row. 
--
-------------------------------------------------------------------------------------
BUILD IMMEDIATE
REFRESH ON DEMAND
AS
with class_attr_property_max as(
  select p1.class_name, p1.attribute_name, p1.property_code, p1.property_value
  from class_attr_property_cnfg p1, class_cnfg cc, class_attribute_cnfg ca   
  where p1.presentation_cntx in ('/EC', '/')
  and cc.class_name=p1.class_name
  and ca.class_name=p1.class_name
  and ca.attribute_name=p1.attribute_name  
  and ec_install_constants.isBlockedAppSpaceCntx(cc.app_space_cntx) = 0  
  and ec_install_constants.isBlockedAppSpaceCntx(ca.app_space_cntx) = 0  
  and p1.owner_cntx = (
        select max(p1_1.owner_cntx) 
        from class_attr_property_cnfg p1_1
        where p1.class_name = p1_1.class_name 
        and   p1.attribute_name = p1_1.attribute_name
        and p1.property_code = p1_1.property_code
        and p1.presentation_cntx = p1_1.presentation_cntx
        )  
  ), 
  class_attr_static as (
  select p1.class_name, p1.attribute_name, listagg(p1.property_code||'='||p1.property_value,';') WITHIN GROUP (ORDER BY p1.property_code) static_presentation_syntax
  from class_attr_property_cnfg p1, class_cnfg cc  
  where p1.presentation_cntx in ('/EC')
  and   p1.property_type = 'STATIC_PRESENTATION'
  and   cc.class_name=p1.class_name
  and   ec_install_constants.isBlockedAppSpaceCntx(cc.app_space_cntx) = 0  
  and   p1.owner_cntx = (
        select max(p1_1.owner_cntx) 
        from class_attr_property_cnfg p1_1
        where p1.class_name = p1_1.class_name 
        and   p1.attribute_name = p1_1.attribute_name
        and p1.property_code = p1_1.property_code
        and p1.presentation_cntx = p1_1.presentation_cntx
        )  
  group by p1.class_name, p1.attribute_name      
  )
select 
ca.CLASS_NAME
,ca.attribute_name                                      
,cast(ecdp_classmeta_cnfg.getDynamicPresentationSyntax(ca.class_name, ca.attribute_name) as varchar(4000)) as presentation_syntax
,cast(psp1.static_presentation_syntax as varchar(4000)) as static_presentation_syntax
,cast(p2.property_value as number) as sort_order
,cast(p3.property_value as varchar(4000)) as db_pres_syntax
,cast(p4.property_value as varchar(32)) as label_id
,cast(p5.property_value as varchar(64)) as label
,cast(p6.property_value as varchar(32)) as uom_code
,ca.RECORD_STATUS                                   
,ca.CREATED_BY                                      
,ca.CREATED_DATE                                    
,ca.LAST_UPDATED_BY                                 
,ca.LAST_UPDATED_DATE                               
,ca.REV_NO                                          
,ca.REV_TEXT                                        
,ca.APPROVAL_STATE                                  
,ca.APPROVAL_BY                                     
,ca.APPROVAL_DATE                                   
,ca.REC_ID                                          
from class_attribute_cnfg ca
inner join class_cnfg cc on cc.class_name = ca.class_name and ec_install_constants.isBlockedAppSpaceCntx(cc.app_space_cntx) = 0
left join class_attr_static psp1 on (ca.class_name = psp1.class_name and ca.attribute_name = psp1.attribute_name)
left join class_attr_property_max p2 on (ca.class_name = p2.class_name and ca.attribute_name = p2.attribute_name and p2.property_code = 'SCREEN_SORT_ORDER' )
left join class_attr_property_max p3 on (ca.class_name = p3.class_name and ca.attribute_name = p3.attribute_name and p3.property_code = 'DB_PRES_SYNTAX' )
left join class_attr_property_max p4 on (ca.class_name = p4.class_name and ca.attribute_name = p4.attribute_name and p4.property_code = 'LABEL_ID' )
left join class_attr_property_max p5 on (ca.class_name = p5.class_name and ca.attribute_name = p5.attribute_name and p5.property_code = 'LABEL' )
left join class_attr_property_max p6 on (ca.class_name = p6.class_name and ca.attribute_name = p6.attribute_name and p6.property_code = 'UOM_CODE' )
where ec_install_constants.isBlockedAppSpaceCntx(ca.app_space_cntx) = 0
--~^UTDELIM^~--

create unique index uix_class_attr_presentation on class_attr_presentation(class_name,attribute_name)
TABLESPACE &ts_index
--~^UTDELIM^~--

CREATE INDEX IR_CLASS_ATTR_PRESENTATION ON CLASS_ATTR_PRESENTATION
 (REC_ID)
 INITRANS 2
 MAXTRANS 255
 PCTFREE 50
 STORAGE
 (
   PCTINCREASE 50
   NEXT 65536
 )
 TABLESPACE &ts_index
--~^UTDELIM^~--

BEGIN
	EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW class_relation';
EXCEPTION
WHEN OTHERS
THEN
 NULL;
END;
--~^UTDELIM^~--

CREATE MATERIALIZED VIEW class_relation 
-------------------------------------------------------------------------------------
--
-- $Revision: 1.4 $
--
--  Purpose: Select the row with the higherst owner context, allowing templates and projects to
--           override product settings without changing the product row. 
--
-------------------------------------------------------------------------------------
BUILD IMMEDIATE
REFRESH ON DEMAND
AS
with class_rel_property_max as(
  select p1.from_class_name, p1.to_class_name, p1.role_name, p1.property_code, p1.property_value
  from class_rel_property_cnfg p1, class_cnfg cc 
  where p1.presentation_cntx in ('/', '/EC')
  and cc.class_name=p1.to_class_name
  and ec_install_constants.isBlockedAppSpaceCntx(cc.app_space_cntx) = 0  
  and p1.owner_cntx = (
        select max(owner_cntx) 
        from class_rel_property_cnfg p1_1
        where p1.from_class_name = p1_1.from_class_name 
        and   p1.to_class_name = p1_1.to_class_name
        and   p1.role_name = p1_1.role_name
        and p1.property_code = p1_1.property_code
        and p1.presentation_cntx = p1_1.presentation_cntx
        )  
)
select 
cr.from_CLASS_NAME
,cr.to_class_name
,cr.role_name                                      
,cr.is_key
,cast(p0.property_value as varchar2(50)) as name
,cast(p1.property_value as varchar2(1)) as is_mandatory
,cr.is_bidirectional
,cr.app_space_cntx as context_code
,cr.group_type
,cr.multiplicity
,cast(p2.property_value as varchar2(1)) as disabled_ind
,cast(p3.property_value as varchar2(1)) as report_only_ind
,cast(p4.property_value as varchar2(32)) as access_control_method
,cast(p5.property_value as number) as alloc_priority
,cast(null as varchar2(4000)) as calc_mapping_syntax
,cast(p7.property_value as varchar2(4000)) as description
,cast(p8.property_value as varchar2(1)) as approval_ind
,cast(p9.property_value as varchar2(1)) as reverse_approval_ind
,cr.RECORD_STATUS                                   
,cr.CREATED_BY                                      
,cr.CREATED_DATE                                    
,cr.LAST_UPDATED_BY                                 
,cr.LAST_UPDATED_DATE                               
,cr.REV_NO                                          
,cr.REV_TEXT                                        
,cr.APPROVAL_STATE                                  
,cr.APPROVAL_BY                                     
,cr.APPROVAL_DATE                                   
,cr.REC_ID                                          
from class_relation_cnfg cr
inner join class_cnfg tc on tc.class_name = cr.to_class_name and ec_install_constants.isBlockedAppSpaceCntx(tc.app_space_cntx) = 0
inner join class_cnfg fc on fc.class_name = cr.from_class_name and ec_install_constants.isBlockedAppSpaceCntx(fc.app_space_cntx) = 0
left join class_rel_property_max p0 on (cr.from_class_name = p0.from_class_name and cr.to_class_name = p0.to_class_name and cr.role_name = p0.role_name and p0.property_code = 'NAME' )
left join class_rel_property_max p1 on (cr.from_class_name = p1.from_class_name and cr.to_class_name = p1.to_class_name and cr.role_name = p1.role_name and p1.property_code = 'IS_MANDATORY' )
left join class_rel_property_max p2 on (cr.from_class_name = p2.from_class_name and cr.to_class_name = p2.to_class_name and cr.role_name = p2.role_name and p2.property_code = 'DISABLED_IND' )
left join class_rel_property_max p3 on (cr.from_class_name = p3.from_class_name and cr.to_class_name = p3.to_class_name and cr.role_name = p3.role_name and p3.property_code = 'REPORT_ONLY_IND' )
left join class_rel_property_max p4 on (cr.from_class_name = p4.from_class_name and cr.to_class_name = p4.to_class_name and cr.role_name = p4.role_name and p4.property_code = 'ACCESS_CONTROL_METHOD' )
left join class_rel_property_max p5 on (cr.from_class_name = p5.from_class_name and cr.to_class_name = p5.to_class_name and cr.role_name = p5.role_name and p5.property_code = 'ALLOC_PRIORITY' )
left join class_rel_property_max p7 on (cr.from_class_name = p7.from_class_name and cr.to_class_name = p7.to_class_name and cr.role_name = p7.role_name and p7.property_code = 'DESCRIPTION' )
left join class_rel_property_max p8 on (cr.from_class_name = p8.from_class_name and cr.to_class_name = p8.to_class_name and cr.role_name = p8.role_name and p8.property_code = 'APPROVAL_IND' )
left join class_rel_property_max p9 on (cr.from_class_name = p9.from_class_name and cr.to_class_name = p9.to_class_name and cr.role_name = p9.role_name and p9.property_code = 'REVERSE_APPROVAL_IND' )
where ec_install_constants.isBlockedAppSpaceCntx(cr.app_space_cntx) = 0
--~^UTDELIM^~--

create unique index uix_class_relation on Class_relation(from_class_name,to_class_name,role_name)
TABLESPACE &ts_index
--~^UTDELIM^~--

CREATE INDEX IFK_CLASS_RELATION_2 ON CLASS_RELATION
 (TO_CLASS_NAME)
 INITRANS 2
 MAXTRANS 255
 PCTFREE 50
 STORAGE
 (
   PCTINCREASE 50
   NEXT 65536
 )
 TABLESPACE &ts_index
--~^UTDELIM^~--

CREATE INDEX IR_CLASS_RELATION ON CLASS_RELATION
 (REC_ID)
 INITRANS 2
 MAXTRANS 255
 PCTFREE 50
 STORAGE
 (
   PCTINCREASE 50
   NEXT 65536
 )
 TABLESPACE &ts_index
--~^UTDELIM^~--


BEGIN
	EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW class_rel_db_mapping';
EXCEPTION
WHEN OTHERS
THEN
 NULL;
END;
--~^UTDELIM^~--

CREATE MATERIALIZED VIEW class_rel_db_mapping 
-------------------------------------------------------------------------------------
--
-- $Revision: 1.4 $
--
--  Purpose: Select the row with the higherst owner context, allowing templates and projects to
--           override product settings without changing the product row. 
--
-------------------------------------------------------------------------------------
BUILD IMMEDIATE
REFRESH ON DEMAND
AS
with class_rel_property_max as(
  select from_class_name, to_class_name, role_name, property_code, property_value
  from class_rel_property_cnfg p1 
  where p1.presentation_cntx in ('/EC', '/')
  and owner_cntx = (
        select max(owner_cntx) 
        from class_rel_property_cnfg p1_1
        where p1.from_class_name = p1_1.from_class_name 
        and   p1.to_class_name = p1_1.to_class_name
        and   p1.role_name = p1_1.role_name
        and p1.property_code = p1_1.property_code
        and p1.presentation_cntx = p1_1.presentation_cntx
        )  
)
select 
cr.from_CLASS_NAME
,cr.to_class_name
,cr.role_name                                      
,cr.db_mapping_type
,cr.db_sql_syntax
,cast(p1.property_value as number) as sort_order
,cr.RECORD_STATUS                                   
,cr.CREATED_BY                                      
,cr.CREATED_DATE                                    
,cr.LAST_UPDATED_BY                                 
,cr.LAST_UPDATED_DATE                               
,cr.REV_NO                                          
,cr.REV_TEXT                                        
,cr.APPROVAL_STATE                                  
,cr.APPROVAL_BY                                     
,cr.APPROVAL_DATE                                   
,cr.REC_ID                                          
from class_relation_cnfg cr
left join class_cnfg tc on tc.class_name = cr.to_class_name and ec_install_constants.isBlockedAppSpaceCntx(tc.app_space_cntx) = 0
left join class_cnfg fc on fc.class_name = cr.from_class_name and ec_install_constants.isBlockedAppSpaceCntx(fc.app_space_cntx) = 0
left join class_rel_property_max p1 on (cr.from_class_name = p1.from_class_name and cr.to_class_name = p1.to_class_name and cr.role_name = p1.role_name and p1.property_code = 'DB_SORT_ORDER' )
where ec_install_constants.isBlockedAppSpaceCntx(cr.app_space_cntx) = 0
--~^UTDELIM^~--

create unique index uix_class_rel_db_mapping on Class_rel_db_mapping(from_class_name,to_class_name,role_name)
TABLESPACE &ts_index
--~^UTDELIM^~--

CREATE INDEX IR_CLASS_REL_DB_MAPPING ON CLASS_REL_DB_MAPPING
 (REC_ID)
 INITRANS 2
 MAXTRANS 255
 PCTFREE 50
 STORAGE
 (
   PCTINCREASE 50
   NEXT 65536
 )
 TABLESPACE &ts_index
--~^UTDELIM^~--

BEGIN
	EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW class_rel_presentation';
EXCEPTION
WHEN OTHERS
THEN
 NULL;
END;
--~^UTDELIM^~--

CREATE MATERIALIZED VIEW class_rel_presentation 
-------------------------------------------------------------------------------------
--
-- $Revision: 1.4 $
--
--  Purpose: Select the row with the higherst owner context, allowing templates and projects to
--           override product settings without changing the product row. 
--
-------------------------------------------------------------------------------------
BUILD IMMEDIATE
REFRESH ON DEMAND
AS
with class_rel_property_max as(
  select p1.from_class_name, p1.to_class_name, p1.role_name, p1.property_code, p1.property_value
  from class_rel_property_cnfg p1, class_cnfg cc 
  where p1.presentation_cntx in ('/EC', '/')
  and cc.class_name=p1.to_class_name
  and ec_install_constants.isBlockedAppSpaceCntx(cc.app_space_cntx) = 0    
  and owner_cntx = (
        select max(owner_cntx) 
        from class_rel_property_cnfg p1_1
        where p1.from_class_name = p1_1.from_class_name 
        and   p1.to_class_name = p1_1.to_class_name
        and   p1.role_name = p1_1.role_name
        and   p1.property_code = p1_1.property_code
        and   p1.presentation_cntx = p1_1.presentation_cntx
        )  
),
  class_rel_static as (
  select p1.from_class_name, p1.to_class_name, p1.role_name, listagg(p1.property_code||'='||p1.property_value,';') WITHIN GROUP (ORDER BY p1.property_code) static_presentation_syntax
  from class_rel_property_cnfg p1, class_cnfg cc 
  where p1.presentation_cntx = '/EC'
  and   p1.property_type = 'STATIC_PRESENTATION'
  and   cc.class_name=p1.to_class_name
  and   ec_install_constants.isBlockedAppSpaceCntx(cc.app_space_cntx) = 0      
  and   p1.owner_cntx = (
        select max(owner_cntx) 
        from class_rel_property_cnfg p1_1
        where p1.from_class_name = p1_1.from_class_name 
        and   p1.to_class_name = p1_1.to_class_name
        and   p1.role_name = p1_1.role_name
        and   p1.property_code = p1_1.property_code
        and   p1.presentation_cntx = p1_1.presentation_cntx
        )  
  group by p1.from_class_name, p1.to_class_name, p1.role_name      
  )
select 
cr.from_CLASS_NAME
,cr.to_class_name
,cr.role_name                                      
,cast(psp1.static_presentation_syntax as varchar(4000)) as static_presentation_syntax
,cast(ecdp_classmeta_cnfg.getDynamicPresentationSyntax(cr.from_class_name, cr.to_class_name, cr.role_name) as varchar2(4000)) as presentation_syntax
,cast(p2.property_value as varchar2(4000)) as db_pres_syntax
,cast(p3.property_value as varchar2(64)) as label
,cr.RECORD_STATUS                                   
,cr.CREATED_BY                                      
,cr.CREATED_DATE                                    
,cr.LAST_UPDATED_BY                                 
,cr.LAST_UPDATED_DATE                               
,cr.REV_NO                                          
,cr.REV_TEXT                                        
,cr.APPROVAL_STATE                                  
,cr.APPROVAL_BY                                     
,cr.APPROVAL_DATE                                   
,cr.REC_ID                                          
from class_relation_cnfg cr
inner join class_cnfg tc on tc.class_name = cr.to_class_name and ec_install_constants.isBlockedAppSpaceCntx(tc.app_space_cntx) = 0
inner join class_cnfg fc on fc.class_name = cr.from_class_name and ec_install_constants.isBlockedAppSpaceCntx(fc.app_space_cntx) = 0
left join class_rel_static psp1 on (cr.from_class_name = psp1.from_class_name and cr.to_class_name = psp1.to_class_name and cr.role_name = psp1.role_name )
left join class_rel_property_max p2 on (cr.from_class_name = p2.from_class_name and cr.to_class_name = p2.to_class_name and cr.role_name = p2.role_name and p2.property_code = 'DB_PRES_SYNTAX' )
left join class_rel_property_max p3 on (cr.from_class_name = p3.from_class_name and cr.to_class_name = p3.to_class_name and cr.role_name = p3.role_name and p3.property_code = 'LABEL' )
where ec_install_constants.isBlockedAppSpaceCntx(cr.app_space_cntx) = 0
--~^UTDELIM^~--

create unique index uix_class_rel_presentation on class_rel_presentation(from_class_name,to_class_name, role_name)
TABLESPACE &ts_index
--~^UTDELIM^~--

CREATE INDEX IR_CLASS_REL_PRESENTATION ON CLASS_REL_PRESENTATION
 (REC_ID)
 INITRANS 2
 MAXTRANS 255
 PCTFREE 50
 STORAGE
 (
   PCTINCREASE 50
   NEXT 65536
 )
 TABLESPACE &ts_index
--~^UTDELIM^~--