CREATE OR REPLACE PACKAGE BODY EcBp_Deferment_Status_Log IS
/****************************************************************
** Package        :  EcBp_Deferment_Status_Log, body part
**
** $Revision: 1.0 $
**
** Purpose        :  This package is responsible for supporting business function
**                   related to Automatic Deferment Raw Data (PD.0024)
** Documentation  :  www.energy-components.com
**
** Created  : 20.02.2018  Gaurav Chaudhary
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 28.05.2018 jainnraj ECPD-56263 Modified purgeStatusNoise to UPDATE On to ON to respect the current system settings value and modified createEvent to remove raise
** 30.05.2018 jainnraj ECPD-56263 Modified purgeStatusNoise to update line 138 to update the close event
** 01.06.2018 jainnraj ECPD-56263 Modified flushData to get the no of days from latest system settings entry
** 05.06.2018 chaudgau ECPD-54420 Added new procedure promoteOfficial and changed logic for purgeStatusNoise and getPrevStatus
********************************************************************/
CURSOR c_def_status_log(p_object_id varchar2,p_daytime date)
IS
SELECT
      object_id
     ,status prev_status
     ,daytime prev_daytime
     ,is_official prev_is_official
     ,LAG(daytime)
         OVER(PARTITION BY object_id ORDER BY object_id, daytime) lag_daytime
     ,LAG(status)
         OVER(PARTITION BY object_id ORDER BY object_id, daytime) lag_status
      FROM deferment_status_log
 WHERE object_id = p_object_id
   AND daytime <= p_daytime
 ORDER BY daytime DESC FETCH FIRST ROW ONLY;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : logError
-- Description    : It help record error against proposed deferment row
-- Using tables   : deferment_status_log
---------------------------------------------------------------------------------------------------

PROCEDURE logError(p_object_id VARCHAR2, p_daytime DATE DEFAULT NULL, p_msg VARCHAR2)
IS
BEGIN
  UPDATE deferment_status_log
     SET err_log = p_msg
   WHERE object_id=p_object_id
     AND daytime = p_daytime;
END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getSystemSetting
-- Description    : fetches system setting value for given key and daytime
-- Using tables   : tv_system_setting
---------------------------------------------------------------------------------------------------
FUNCTION getSystemSetting
(
  p_key VARCHAR2
 ,p_daytime DATE DEFAULT ecdp_date_time.getcurrentsysdate
) RETURN VARCHAR2
RESULT_CACHE
IS
  lv2_value VARCHAR2(2000);
BEGIN
  SELECT VALUE
    INTO lv2_value
    FROM v_system_setting
   WHERE key = p_key
     AND daytime <= p_daytime
ORDER BY daytime DESC FETCH FIRST ROW ONLY;

RETURN lv2_value;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
END getSystemSetting;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getPrevStatus
-- Description    : It perform following actions in given sequence
                    -- 1. Check if noise data exists and either clean it up or mark it as official / correct data.
                    -- 2. Create deferment event if Automatic deferment system setting is set to ON
                    -- 3. Fetches status of previous row for given object to identify redundant data
-- Assumption     : Data for given object will be received in cronological order only.
-- Using tables   : deferment_status_log
---------------------------------------------------------------------------------------------------
FUNCTION getPrevStatus
(
  p_object_id VARCHAR2
 ,p_daytime DATE
 ,p_status NUMBER
) RETURN deferment_status_log.status%TYPE IS
  ln_status deferment_status_log.status%TYPE;
BEGIN

FOR def_log_rec in c_def_status_log(p_object_id,p_daytime)
LOOP

    IF (p_status=def_log_rec.prev_status AND def_log_rec.prev_is_official IS NULL)
        OR ( def_log_rec.lag_status IS NULL AND def_log_rec.prev_is_official IS NULL)
        THEN
        promoteOfficial(p_object_id, p_daytime, p_status, def_log_rec.prev_daytime,def_log_rec.prev_status, def_log_rec.lag_daytime, def_log_rec.lag_status);
    ELSIF def_log_rec.prev_is_official IS NULL
          AND p_status <> def_log_rec.prev_status
        THEN
        purgeStatusNoise(p_object_id, def_log_rec.prev_daytime,def_log_rec.prev_status);
    END IF;
    ln_status := def_log_rec.prev_status;
END LOOP;

  RETURN NVL(ln_status,p_status - 1);
END getPrevStatus;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : promoteOfficial
-- Description    : It marks previous row status as official and push it for event creation if threshold has reached
-- Assumption     : Data for given object will be received in cronological order only.
-- Using tables   : deferment_status_log
---------------------------------------------------------------------------------------------------
PROCEDURE promoteOfficial
(
  p_object_id VARCHAR2
 ,p_daytime DATE
 ,p_status NUMBER
 ,p_prev_daytime DATE
 ,p_prev_status NUMBER
 ,p_lag_daytime DATE
 ,p_lag_status NUMBER
)
IS
  ln_status_threshold NUMBER;
  ln_automatic_deferment VARCHAR2(5);
BEGIN

   ln_status_threshold := TO_NUMBER(getSystemSetting
                                    (
                                      'DEFERMENT_STATUS_THRESHOLD'
                                     ,TRUNC(p_daytime)
                                     )
                                  );

   IF (ROUND((p_daytime - p_lag_daytime) *1440) >= ln_status_threshold
       AND p_status <> p_lag_status)
       OR p_lag_status IS NULL
  THEN
     UPDATE deferment_status_log
        SET is_official='Y'
      WHERE object_id=p_object_id
        AND daytime=p_prev_daytime
        AND status=p_prev_status;

      ln_automatic_deferment := getSystemSetting
                                 (
                                  'DEFERMENT_AUTO_GEN'
                                  ,TRUNC(p_prev_daytime)
                                 );

      IF UPPER(ln_automatic_deferment) = 'ON' THEN
        -- Call for auto creation of event if automatic deferment setting is on
        createEvent( p_start_date => CASE WHEN p_prev_status = 0 THEN p_prev_daytime END
                    ,p_end_date => CASE WHEN p_prev_status = 1 THEN p_prev_daytime END
                    ,p_object_id => p_object_id
                    ,p_created_by => USER);
      END IF;
END IF;

END promoteOfficial;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure   : purgeStatusNoise
-- Description : Used by class trigger action during Insert to clean status noise.
--               Existing table row will be deleted for given object if:
--               -Inserted row status differ from existing row
--               -If it is not considered as official
-- Assumption   : Data for given object will be received in cronological order only.
-- Using tables : deferment_status_log
---------------------------------------------------------------------------------------------------
PROCEDURE purgeStatusNoise
(
  p_object_id VARCHAR2
 ,p_prev_daytime DATE
 ,p_prev_status NUMBER
) IS
--  ln_automatic_deferment VARCHAR2(5);
BEGIN
      DELETE FROM deferment_status_log
       WHERE object_id=p_object_id
         AND daytime=p_prev_daytime
         AND status=p_prev_status;
END purgeStatusNoise;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : flushData
-- Description    : Used to clean data from table leaving last two status of each Object
--
-- Using tables   : deferment_status_log
---------------------------------------------------------------------------------------------------
PROCEDURE flushData IS
  ln_num_days number;
BEGIN
  ln_num_days:= getSystemSetting
                         (
                          'DEFERMENT_LOG_FLUSH'
                          );
  DELETE FROM deferment_status_log
   WHERE ROWID IN (SELECT ROWID
                   FROM (SELECT object_id
                               ,daytime
                               ,rank() over(PARTITION BY object_id ORDER BY daytime DESC) rnk
                           FROM deferment_status_log)
                  WHERE rnk > 2)
     AND daytime <= (ecdp_date_time.getcurrentsysdate - ln_num_days);
END flushData;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : createEvent
-- Description    : Generate deferment event into target BF (PD.0020 / PD.0023)
--
-- Using tables   : TV_WELL_DEFERMENT, DV_DEFERMENT_EVENT
---------------------------------------------------------------------------------------------------
PROCEDURE createEvent
(
  p_start_date DATE
 ,p_end_date DATE DEFAULT NULL
 ,p_object_id VARCHAR2
 ,p_created_by VARCHAR2
) IS
  lv2_screen_usage VARCHAR2(100);
  lv2_err_msg VARCHAR2(2000);
BEGIN
    lv2_screen_usage := getSystemSetting
                         (
                          'DEFERMENT_TARGET_SCREEN'
                          ,TRUNC(NVL(p_start_date, p_end_date))
                         );

  IF p_start_date IS NULL THEN
    IF lv2_screen_usage = 'PD.0020' THEN
      UPDATE TV_WELL_DEFERMENT
         SET end_date = p_end_date
       WHERE object_id = p_object_id
         AND end_date IS NULL;

    ELSIF lv2_screen_usage = 'PD.0023' THEN
      UPDATE DV_DEFERMENT_EVENT
         SET end_date = p_end_date
       WHERE defer_object_id = p_object_id
         AND end_date IS NULL;
    END IF;

    IF SQL%ROWCOUNT = 0 THEN
      logError(p_object_id, p_end_date, 'Open ended Deferment event not found');
    ELSE
      UPDATE DEFERMENT_STATUS_LOG
         SET EVENT_CREATED='Y'
       WHERE object_id=p_object_id
         AND daytime = p_end_date;
    END IF;

    RETURN;
  END IF;

  IF lv2_screen_usage = 'PD.0020' THEN
    INSERT INTO TV_WELL_DEFERMENT (DAYTIME, END_DATE, EVENT_TYPE, SCHEDULED, OBJECT_TYPE, OBJECT_ID, CREATED_BY)
    VALUES (p_start_date, p_end_date, 'DOWN', 'N', ecdp_objects.GetObjClassName(p_object_id), p_object_id, p_created_by);
  ELSIF lv2_screen_usage = 'PD.0023' THEN
    INSERT INTO DV_DEFERMENT_EVENT (DAYTIME, END_DATE, EVENT_TYPE, SCHEDULED, OBJECT_TYPE, DEFER_OBJECT_ID, DEFERMENT_TYPE, CREATED_BY)
    VALUES (p_start_date, p_end_date, 'DOWN', 'N', ecdp_objects.GetObjClassName(p_object_id), p_object_id, 'SINGLE', p_created_by);
  END IF;

  UPDATE DEFERMENT_STATUS_LOG
     SET EVENT_CREATED='Y'
   WHERE object_id=p_object_id
     AND (daytime = p_start_date OR daytime = p_end_date);

EXCEPTION
  WHEN OTHERS THEN
  lv2_err_msg := SUBSTR(SQLERRM,11);
  logError(p_object_id, p_start_date, lv2_err_msg);
  --RAISE;
END;
END EcBp_Deferment_Status_Log;