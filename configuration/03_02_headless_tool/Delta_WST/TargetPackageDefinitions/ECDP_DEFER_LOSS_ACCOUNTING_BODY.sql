CREATE OR REPLACE PACKAGE BODY EcDp_Defer_Loss_Accounting IS
    /****************************************************************
    ** Package        :  EcDp_Defer_Loss_Accounting
    **
    ** $Revision: 1.9 $
    **
    ** Purpose        :  This package is responsible for supporting business functions
    **                   related to Daily Facility and Field Loss Accounting.
    **
    ** Documentation  :  www.energy-components.com
    **
    ** Created  : 23.09.2010  Sarojini Rajaretnam
    **
    ** Modification history:
    **
    ** Date       	Whom     	Change description:
    ** ------     	-------- 	--------------------------------------
    ** 27.12.2010	rajarsar	ECPD-16192:updated populateFctyStreamRecord,calckBOE and updateRate.
    ** 24.01.2011	rajarsar	ECPD-16192:updated populateFctyStreamRecord,populateFldStreamRecord,calckBOE and updateRate.
    ** 31.01.2011 	rajarsar 	ECPD-16192:Added deleteChildEvent
    ** 30.11.2011 	rajarsar 	ECPD-18879:Updated populateFctyStreamRecord and populateFldStreamRecord
    *****************************************************************/

    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       : calcDuration
    -- Description    :
    --
    -- Preconditions  :
    --
    -- Postconditions :
    -- Using tables   :
    --
    -- Using functions:
    --
    --
    --
    -- Configuration
    -- required       :
    --
    -- Behaviour      :
    --
    --
    ---------------------------------------------------------------------------------------------------
    --</EC-DOC>
    FUNCTION calcDuration(p_object_id VARCHAR2, p_daytime  DATE,
                          p_end_date DATE) RETURN VARCHAR2
    --</EC-DOC>
     IS
        ln_num_of_hours     NUMBER := 0;

    BEGIN


       IF ecdp_objects.GetObjClassName(p_object_id) IN ('FCTY_CLASS_1','FCTY_CLASS_2') THEN
         ln_num_of_hours     := ecdp_date_time.getNumHours('FACILITY', p_object_id, TRUNC(p_daytime, 'DD'));
       ELSE
         ln_num_of_hours     := ecdp_date_time.getNumHours('', p_object_id, TRUNC(p_daytime, 'DD'));
       END IF;
       RETURN (Nvl(p_end_date, ecdp_date_time.getCurrentSysdate) - p_daytime) * ln_num_of_hours;

    END calcDuration;

    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       : populateFctyStreamRecord
    -- Description    : Populate the object attributes during insert into DEFER_LOSS_STRM_EVENT for facility events
    --
    -- Preconditions  : Only during insert into DEFER_LOSS_STRM_EVENT
    -- Postconditions :
    --
    -- Using tables   : CLASS, DEFER_LOSS_STRM_EVENT
    --
    -- Using functions:
    --
    -- Configuration
    -- required       :
    --
    -- Behaviour      :
    --
    ---------------------------------------------------------------------------------------------------
    PROCEDURE populateFctyStreamRecord(p_event_no NUMBER,
                                   p_daytime  DATE DEFAULT NULL,
                                   p_end_date DATE DEFAULT NULL)
    --</EC-DOC>
     IS

        CURSOR c_enddaytime(cp_start_day DATE,cp_end_day DATE ) IS
            SELECT daytime
              FROM system_days
             WHERE daytime BETWEEN cp_start_day AND cp_end_day;

         CURSOR c_streams(cp_day DATE,
                         cp_fcty_id    VARCHAR2) IS
            SELECT  distinct(cmv.stream_id),cmv.object_id
              FROM  choke_model cm, choke_model_version cmv, defer_loss_acc_event dlav
             WHERE dlav.event_no = p_event_no
               and cm.object_code = 'SYSTEM'
               and cmv.parent_choke_model_id = cm.object_id
               and cmv.stream_id IS NOT NULL
               and (cmv.op_fcty_class_2_id = cp_fcty_id or -- use both as it is optional to use fcty_class_1 or fcty_class_2
                cmv.op_fcty_class_1_id = cp_fcty_id)
               and cmv.loss_acc IN ('FACILITY','BOTH')
               and cmv.daytime <= cp_day
               and nvl(cmv.end_date,cp_day + 1) > cp_day
               AND NOT exists
               (select 1
                from defer_loss_strm_event x
                where x.object_id = cmv.stream_id
                and x.daytime = cp_day
                and x.event_no = p_event_no);

        ld_start DATE;
        ld_end   DATE;
        ld_daytime DATE;
        ld_end_prod_day DATE;
        ld_end_prod_day_offset DATE;

    BEGIN
       -- handle that start date and end date can be empty
        ld_start := nvl(p_daytime, ec_DEFER_LOSS_ACC_EVENT.daytime(p_event_no));
        ld_end   := nvl(nvl(p_end_date, ec_DEFER_LOSS_ACC_EVENT.end_date(p_event_no)),EcDp_Date_Time.getCurrentSysdate);
        ld_start := ecdp_productionday.getProductionDay('FACILITY', ec_DEFER_LOSS_ACC_EVENT.object_id(p_event_no), ld_start);
        ld_end_prod_day := ecdp_productionday.getProductionDay('FACILITY', ec_DEFER_LOSS_ACC_EVENT.object_id(p_event_no), ld_end);
        ld_end_prod_day_offset := ecdp_productionday.getProductionDayStart('FACILITY', ec_DEFER_LOSS_ACC_EVENT.object_id(p_event_no),ld_end_prod_day);

        IF ld_end =  ld_end_prod_day_offset THEN
          ld_end := ld_end_prod_day  -1 ;
        ELSE
          ld_end := ld_end_prod_day;
        END IF;
        FOR cur_enddaytime IN c_enddaytime(ld_start,ld_end) LOOP
          ld_daytime := cur_enddaytime.daytime;
          FOR curStreams IN c_streams(ld_daytime, ec_DEFER_LOSS_ACC_EVENT.object_id(p_event_no)) LOOP
            INSERT INTO defer_loss_strm_event
              (event_no, object_id, daytime, choke_model_id, created_by)
            VALUES
              (p_event_no, curStreams.stream_id,  ld_daytime, curStreams.object_id, ecdp_context.getAppUser);
           END LOOP;
         END LOOP;

    END populateFctyStreamRecord;

     --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       : populateFldStreamRecord
    -- Description    : Populate the object attributes during insert into DEFER_LOSS_STRM_EVENT for field events
    --
    -- Preconditions  : Only during insert into DEFER_LOSS_STRM_EVENT
    -- Postconditions :
    --
    -- Using tables   : CLASS, DEFER_LOSS_STRM_EVENT
    --
    -- Using functions:
    --
    -- Configuration
    -- required       :
    --
    -- Behaviour      :
    --
    ---------------------------------------------------------------------------------------------------
    PROCEDURE populateFldStreamRecord(p_event_no NUMBER,
                                   p_daytime  DATE DEFAULT NULL,
                                   p_end_date DATE DEFAULT NULL)
    --</EC-DOC>
     IS

        CURSOR c_enddaytime(cp_start_day DATE,cp_end_day DATE ) IS
            SELECT daytime
              FROM system_days
             WHERE daytime BETWEEN cp_start_day AND cp_end_day;

        CURSOR c_streams(cp_day DATE,
                         cp_fld_id  VARCHAR2) IS
             SELECT  distinct(cmv.stream_id),cmv.object_id
              FROM choke_model cm, choke_model_version cmv, defer_loss_acc_event dlav, strm_version v
             WHERE dlav.event_no = p_event_no
               and cm.object_code = 'SYSTEM'
               and cmv.parent_choke_model_id = cm.object_id
               and cmv.stream_id IS NOT NULL
               and (cmv.geo_field_id = cp_fld_id or -- use both as it is optional to use fcty_class_1 or fcty_class_2
                cmv.geo_sub_field_id = cp_fld_id)
               and cmv.loss_acc IN ('FIELD','BOTH')
               and cmv.daytime <= cp_day
               and nvl(cmv.end_date, cp_day + 1) > cp_day
               AND NOT exists
               (select 1
                from defer_loss_strm_event x
                where x.object_id = cmv.stream_id
                and x.daytime = cp_day
                and x.event_no = p_event_no);

        ld_start DATE;
        ld_end   DATE;
        ld_daytime DATE;
        ld_end_prod_day   DATE;
        ld_end_prod_day_offset DATE;

    BEGIN
        -- handle that start date and end date can be empty
       ld_start := nvl(p_daytime, ec_DEFER_LOSS_ACC_EVENT.daytime(p_event_no));
       ld_end   := nvl(nvl(p_end_date, ec_DEFER_LOSS_ACC_EVENT.end_date(p_event_no)),EcDp_Date_Time.getCurrentSysdate);
       ld_start := ecdp_productionday.getProductionDay('', ec_DEFER_LOSS_ACC_EVENT.object_id(p_event_no), ld_start);
       ld_end_prod_day := ecdp_productionday.getProductionDay('', ec_DEFER_LOSS_ACC_EVENT.object_id(p_event_no), ld_end);
       ld_end_prod_day_offset := ecdp_productionday.getProductionDayStart('', ec_DEFER_LOSS_ACC_EVENT.object_id(p_event_no),ld_end_prod_day);

       IF ld_end =  ld_end_prod_day_offset THEN
         ld_end := ld_end_prod_day  -1 ;
       ELSE
         ld_end := ld_end_prod_day;
       END IF;
       FOR cur_enddaytime IN c_enddaytime(ld_start,ld_end) LOOP
         ld_daytime := cur_enddaytime.daytime;
         FOR curStreams IN c_streams(ld_daytime, ec_DEFER_LOSS_ACC_EVENT.object_id(p_event_no)) LOOP
           INSERT INTO defer_loss_strm_event
             (event_no, object_id, daytime, choke_model_id, created_by)
           VALUES
             (p_event_no, curStreams.stream_id,  ld_daytime, curStreams.object_id, ecdp_context.getAppUser);
         END LOOP;
       END LOOP;

    END populateFldStreamRecord;


    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Procedure      : updateStreamRecord
    -- Description    :
    --
    -- Preconditions  :
    -- Postconditions :
    --
    -- Using tables   : defer_loss_strm_event
    --
    --
    -- Using functions:
    --
    -- Configuration
    -- required       :
    --
    -- Behaviour      : -
    --
    ---------------------------------------------------------------------------------------------------
    PROCEDURE updateStreamRecord(p_event_no NUMBER,
                                 p_daytime  DATE,
                                 p_end_date DATE)
    --</EC-DOC>
     IS

        CURSOR c_defer_loss_strm_event IS
            SELECT * FROM defer_loss_strm_event dls WHERE dls.event_no = p_event_no;

    BEGIN

        FOR cur_one IN c_defer_loss_strm_event LOOP
            IF (cur_one.daytime > p_end_date) OR (p_end_date IS NULL) THEN
                -- when user update the end date lesser than previous record of end date

                DELETE FROM defer_loss_strm_event dls
                 WHERE dls.event_no = cur_one.event_no
                   AND dls.daytime = cur_one.daytime;
            END IF;
        END LOOP;
        -- do we need to update the table if user updated record of end date more than prev end date record?
    END updateStreamRecord;

    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------------
    -- Procedure      : deleteStream
    -- Description    : This procedure delete all streams based on the record select on the 1st data section.
    --
    -- Preconditions  :
    -- Postconditions :
    --
    -- Using tables   : defer_loss_strm_event
    --
    --
    --
    -- Using functions:
    --
    -- Configuration
    -- required       :
    --
    -- Behavior       :
    --
    ---------------------------------------------------------------------------------------------------------
    PROCEDURE deleteStream(p_event_no NUMBER, p_daytime DATE, p_end_date DATE)
    --</EC-DOC>
     IS

      CURSOR c_streams_to_delete(cp_start_date DATE,
                         cp_end_date   DATE) IS
        SELECT  daytime
          FROM defer_loss_strm_event dlsv
        WHERE dlsv.daytime NOT BETWEEN cp_start_date and cp_end_date
          AND dlsv.event_no = p_event_no;

        ld_start DATE;
        ld_end   DATE;
        ld_end_prod_day   DATE;
        ld_end_prod_day_offset DATE;

     BEGIN
        ld_start := nvl(p_daytime, ec_DEFER_LOSS_ACC_EVENT.daytime(p_event_no));
        ld_end   := nvl(nvl(p_end_date, ec_DEFER_LOSS_ACC_EVENT.end_date(p_event_no)),EcDp_Date_Time.getCurrentSysdate);

        IF ecdp_objects.GetObjClassName(ec_DEFER_LOSS_ACC_EVENT.object_id(p_event_no)) IN ('FCTY_CLASS_1','FCTY_CLASS_2') THEN
          ld_start := ecdp_productionday.getProductionDay('FACILITY', ec_DEFER_LOSS_ACC_EVENT.object_id(p_event_no), ld_start);
          ld_end_prod_day := ecdp_productionday.getProductionDay('FACILITY', ec_DEFER_LOSS_ACC_EVENT.object_id(p_event_no), ld_end);
          ld_end_prod_day_offset := ecdp_productionday.getProductionDayStart('FACILITY', ec_DEFER_LOSS_ACC_EVENT.object_id(p_event_no),ld_end_prod_day);
          IF ld_end =  ld_end_prod_day_offset THEN
            ld_end := ld_end_prod_day  -1 ;
          ELSE
            ld_end := ld_end_prod_day;
          END IF;
        ELSE
          ld_start := ecdp_productionday.getProductionDay('', ec_DEFER_LOSS_ACC_EVENT.object_id(p_event_no), ld_start);
          ld_end_prod_day := ecdp_productionday.getProductionDay('', ec_DEFER_LOSS_ACC_EVENT.object_id(p_event_no), ld_end);
          ld_end_prod_day_offset := ecdp_productionday.getProductionDayStart('', ec_DEFER_LOSS_ACC_EVENT.object_id(p_event_no),ld_end_prod_day);
          IF ld_end =  ld_end_prod_day_offset THEN
            ld_end := ld_end_prod_day  -1 ;
          ELSE
            ld_end := ld_end_prod_day;
          END IF;
        END IF;
        FOR curStreamsToDelete IN c_streams_to_delete(ld_start,ld_end) LOOP
          DELETE FROM defer_loss_strm_event a WHERE a.event_no = p_event_no and a.daytime = curStreamsToDelete.Daytime ;
        END LOOP;

    END deleteStream;

    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       : calcStrmDuration
    -- Description    :
    --
    -- Preconditions  :
    --
    -- Postconditions :
    -- Using tables   :
    --
    -- Using functions:
    --
    --
    --
    -- Configuration
    -- required       :
    --
    -- Behaviour      :
    --
    --
    ---------------------------------------------------------------------------------------------------
    --</EC-DOC>
    FUNCTION calcStrmDuration(p_event_no  NUMBER,
                              p_object_id VARCHAR2,
                              p_daytime   DATE) RETURN NUMBER
    --</EC-DOC>
     IS

        ln_retval           NUMBER;
        ln_num_of_hours     NUMBER := 0;
        ld_day              DATE;
        ld_start_daytime    DATE;
        ld_end_daytime      DATE;
        lr_defer_fcty_event DEFER_LOSS_ACC_EVENT%ROWTYPE;

    BEGIN

        lr_defer_fcty_event := ec_DEFER_LOSS_ACC_EVENT.row_by_pk(p_event_no);
        ln_num_of_hours     := ecdp_date_time.getNumHours('STREAM', p_object_id, TRUNC(p_daytime, 'DD'));
        ld_day              := p_daytime +
                               EcDp_ProductionDay.getProductionDayOffset('STREAM', p_object_id, p_daytime) / 24;
        ld_start_daytime    := lr_defer_fcty_event.daytime;
        ld_end_daytime      := lr_defer_fcty_event.end_date;
        ln_retval           := (LEAST(Nvl(ld_end_daytime, ld_day + 1), ld_day + 1) - GREATEST(ld_start_daytime, ld_day)) *
                               ln_num_of_hours;

        RETURN ln_retval;
    END calcStrmDuration;

    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       : calckBOE
    -- Description    :
    --
    -- Preconditions  :
    --
    -- Postconditions :
    -- Using tables   :
    --
    -- Using functions:
    --
    --
    --
    -- Configuration
    -- required       :
    --
    -- Behaviour      :
    --
    --
    ---------------------------------------------------------------------------------------------------
    --</EC-DOC>
    FUNCTION calckBOE(p_event_no  NUMBER,
                     p_object_id VARCHAR2,
                     p_daytime   DATE) RETURN NUMBER
    --</EC-DOC>
     IS
        CURSOR c_defer_loss_strm_event IS
            SELECT *
              FROM defer_loss_strm_event dlf
             WHERE dlf.event_no = p_event_no
               AND dlf.object_id = p_object_id
               AND dlf.daytime = p_daytime;

        ln_retval       NUMBER;
        lv2_condition   VARCHAR(32);
        lv2_uom         VARCHAR(32);
        ln_boeConstant  NUMBER;

    BEGIN

       FOR c_one IN c_defer_loss_strm_event LOOP
         -- find choke model boe factor and then convert to KBOE
         lv2_condition := ec_choke_model_version.condition(c_one.choke_model_id,p_daytime, '<=');
         IF (lv2_condition = 'STABLE_LIQ') THEN
           ln_boeConstant := ec_choke_model_ref_value.stable_liq_to_boe(c_one.choke_model_id, p_daytime,'<=');
         ELSIF (lv2_condition = 'UNSTABLE_LIQ') THEN
           ln_boeConstant := ec_choke_model_ref_value.unstable_liq_to_boe(c_one.choke_model_id, p_daytime,'<=');
         ELSIF (lv2_condition = 'GAS') THEN
           ln_boeConstant := ec_choke_model_ref_value.gas_to_boe(c_one.choke_model_id, p_daytime,'<=');
         END IF;
         lv2_uom       := ec_choke_model_version.uom(c_one.choke_model_id,p_daytime, '<=');

         --find net_vol/net_mass
         IF (lv2_uom IN ('STD_GAS_VOL', 'STD_OIL_VOL')) THEN
           ln_retval  := c_one.net_vol * ln_boeConstant;
         ELSIF (lv2_uom IN ('GAS_MASS', 'OIL_MASS')) THEN
           ln_retval  := c_one.net_mass * ln_boeConstant;
         ELSE
           ln_retval := NULL;
         END IF;
       END LOOP;
       IF ln_retval IS NOT NULL THEN
         ln_retval := Ecdp_Unit.convertValue(ln_retval,
                                                'BOE',
                                                'KBOE',
                                                p_daytime);
       END IF;

       RETURN ln_retval;
    END calckBOE;

 --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Procedure      : updateStreamRecord
    -- Description    :
    --
    -- Preconditions  :
    -- Postconditions :
    --
    -- Using tables   : defer_loss_strm_event
    --
    --
    -- Using functions:
    --
    -- Configuration
    -- required       :
    --
    -- Behaviour      : -
    --
    ---------------------------------------------------------------------------------------------------
    PROCEDURE updateStartDaytimeStreamRecord(p_event_no NUMBER,
                                 p_daytime  DATE)
    --</EC-DOC>
     IS

        CURSOR c_defer_loss_strm_event IS
            SELECT * FROM defer_loss_strm_event dls WHERE dls.event_no = p_event_no;

    BEGIN
      IF p_daytime IS NOT NULL THEN
        FOR cur_one IN c_defer_loss_strm_event LOOP

           update defer_loss_strm_event dls
           SET dls.daytime = p_daytime
           WHERE dls.event_no = p_event_no;

        END LOOP;
      END IF;

    END updateStartDaytimeStreamRecord;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : verifyLossAccounting
-- Description    : The Procedure verifies the records for the selected object within the specified period.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : defer_loss_acc_event, defer_loss_strm_event
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : -
--
---------------------------------------------------------------------------------------------------
PROCEDURE verifyLossAccounting(p_event_no VARCHAR2,
                         p_user_name VARCHAR2)
--</EC-DOC>
IS


  lv2_last_update_date VARCHAR2(20);

BEGIN
  lv2_last_update_date := to_char(EcDp_Date_Time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')  ;


  -- Update parent
    UPDATE  defer_loss_acc_event
       SET record_status='V',
           last_updated_by = p_user_name,
           last_updated_date = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
           rev_text = 'Verified at ' ||  lv2_last_update_date
    WHERE event_no = p_event_no
    AND   record_status = 'P';

  -- update child
    UPDATE defer_loss_strm_event
       SET record_status='V',
           last_updated_by = p_user_name,
           last_updated_date = last_updated_date,
           rev_text = 'Verified at ' ||  lv2_last_update_date
    WHERE event_no = p_event_no
    AND   record_status = 'P';


END verifyLossAccounting;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : approveLossAccounting
-- Description    : The Procedure approves the records for the selected object within the specified period.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : defer_loss_acc_event, defer_loss_strm_event
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : -
--
---------------------------------------------------------------------------------------------------
PROCEDURE approveLossAccounting(p_event_no VARCHAR2,
                         p_user_name VARCHAR2)
--</EC-DOC>
IS

  lv2_last_update_date VARCHAR2(20);

BEGIN
  lv2_last_update_date := to_char(EcDp_Date_Time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')  ;



  -- Update parent
    UPDATE  defer_loss_acc_event
       SET record_status='A',
           last_updated_by = p_user_name,
           last_updated_date = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
           rev_text = 'Approved at ' ||  lv2_last_update_date
    WHERE event_no = p_event_no;

  -- update child
    UPDATE defer_loss_strm_event
       SET record_status='A',
           last_updated_by = p_user_name,
           last_updated_date = last_updated_date,
           rev_text = 'Approved at ' ||  lv2_last_update_date
    WHERE event_no = p_event_no;


END approveLossAccounting;

--<EC-DOC>
    ---------------------------------------------------------------------------------------------------------
    -- Procedure      : updateRate
    -- Description    : This procedure updates Rate for records more than p_daytime.
    --
    -- Preconditions  :
    -- Postconditions :
    --
    -- Using tables   : defer_loss_strm_event
    --
    --
    --
    -- Using functions:
    --
    -- Configuration
    -- required       :
    --
    -- Behavior       :
    --
    ---------------------------------------------------------------------------------------------------------
    PROCEDURE updateRate(p_event_no VARCHAR2,p_object_id VARCHAR2, p_daytime DATE,p_user_name VARCHAR2)
    --</EC-DOC>
     IS

      CURSOR c_defer_loss_strm_event IS
        SELECT  *
          FROM defer_loss_strm_event dlsv
        WHERE dlsv.event_no = p_event_no
        AND dlsv.daytime = p_daytime
        AND dlsv.object_id = p_object_id;


      CURSOR c_update_defer_loss_strm_event IS
        SELECT  *
          FROM defer_loss_strm_event dlsv
        WHERE dlsv.event_no = p_event_no
        AND dlsv.object_id = p_object_id
        AND dlsv.daytime > p_daytime;


        ln_rate NUMBER;
        ln_curRate NUMBER;
        lv2_rateType VARCHAR2(32);
        ln_strmDuration NUMBER;
        ln_curStrmDuration NUMBER;

     BEGIN

        ln_strmDuration := calcStrmDuration(p_event_no, p_object_id, p_daytime);
        FOR curStreams IN c_defer_loss_strm_event LOOP
          IF (ec_choke_model_version.uom(curStreams.Choke_Model_Id,p_daytime, '<=') IN ('STD_OIL_VOL','STD_GAS_VOL')) THEN
            ln_rate := curStreams.Net_Vol;
            lv2_rateType := 'VOL';
          ELSIF (ec_choke_model_version.uom(curStreams.Choke_Model_Id,p_daytime, '<=') IN ('GAS_MASS','OIL_MASS')) THEN
            ln_rate := curStreams.Net_Mass;
            lv2_rateType := 'MASS';
          ELSE
            ln_rate := NULL;
            lv2_rateType :=NULL;
          END IF;
        END LOOP;

        FOR curStreamsUpdate IN c_update_defer_loss_strm_event LOOP

          ln_curStrmDuration := calcStrmDuration(p_event_no, p_object_id,curStreamsUpdate.Daytime);
          IF ln_rate IS NOT NULL THEN
            ln_curRate := ln_curStrmDuration * ln_rate / ln_strmDuration;
            IF lv2_rateType = 'VOL' THEN

              UPDATE defer_loss_strm_event dlse set dlse.net_vol = ln_curRate, last_updated_by = p_user_name
                WHERE dlse.event_no = p_event_no
                AND dlse.daytime = curStreamsUpdate.Daytime
                AND dlse.object_id = p_object_id;


            ELSIF lv2_rateType = 'MASS' THEN

              UPDATE defer_loss_strm_event dlse set dlse.net_mass = ln_curRate, last_updated_by = p_user_name
              WHERE dlse.event_no = p_event_no
              AND dlse.daytime = curStreamsUpdate.Daytime
              AND dlse.object_id = p_object_id;


            END IF;
          END IF;
       END LOOP;
    END updateRate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : deleteChildEvent
-- Description    : Delete child events.
--
--
-- Preconditions  :
-- Postconditions : .
--
-- Using tables   : defer_loss_acc_event, defer_loss_
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE deleteChildEvent(p_event_no NUMBER)
--</EC-DOC>
IS

BEGIN

DELETE FROM defer_loss_strm_event
WHERE event_no = p_event_no;

END deleteChildEvent;

END EcDp_Defer_Loss_Accounting;