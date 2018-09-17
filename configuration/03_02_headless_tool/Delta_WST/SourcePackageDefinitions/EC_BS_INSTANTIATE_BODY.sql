CREATE OR REPLACE PACKAGE BODY Ec_Bs_Instantiate IS
/***********************************************************************************************************************************************
** Package  :  Ec_Bs_Instantiate
**
** $Revision: 1.123 $
**
** Purpose  :  Calls Ec_Bs_Obj_Pop which generates dynamic SQL.
**
** Created:     14.10.99  Henk Nevland
**
** How-To: Se www.energy-components.com for full version
**
** Short how-to: Create cursor that finds the primary keys for those tables you want to instantiate. Use the same column sequence as this select:
**    select table_name, column_name, position
**  from user_cons_columns
**  where constraint_name like 'PK%'
**  and table_name='STRM_WATER_ANALYSIS'
**  order by POSITION;
**
** Modification history:
**
**
** Date:      Whom:    Change description:
** --------   -----    --------------------------------------------
** 26.09.00   DN       New_day_start/new_day_end. Added logic for instantiating missing days.
** 06.02.01   DN       Procedure i_fcty_day_regularity: Wrong column-names. Replaced with proper ones.
** 25.05.01   KEJ      Documented functions and procedures.
** 23.06.02   PGI      Changed cursor in i_strm_day_stream to object_id i.o. stream_code.
** 13.11.03   LJG      Changed condition in where clause in i_object_item_comment from object_id = mycur.facility to object_id = mycur.object_id.
** 17.02.04   HNE      Changed to release 7.3 requirements. Changed cursors to speed up performance
** 10.04.04   DN       Procedure i_prod_obj_period_status: sysnam removed.
** 17.03.04   DN       Renamed chem_tank_period_status to chem_tank_status.
** 29.04.04   DN       Procedure i_eqpm_day_status. Screen status test YES => Y.
** 10.05.04   HNE      Removed instantiation of operational comments, since its event based from 7.3
** 25.06.04   DN       Procedure new_day_end: Added new_month.
** 16.08.04   DN       Instantiate system_days without using ec_bs_obj_pop package call. Removed obsolete composite keys (facility, separator_no).
** 12.10.04   DN       Merge from BASELINE-7_4 TI 1682: Replaced the remaining calls to Ec_Bs_Obj_Pop with specific SQL.
** 20.10.04   ZALANNUR Removed TANK_METER_FREQ attribute and replaced it with BF_USAGE (Issue 1266)
** 09.10.04   DN       TI 1655: Added is_active clause when retrieving EC-codes for fcty_day_hse.
** 10.11.04   ROV      Tracker#1801: Added instantiation of flowline type 'DL' to method i_pflw_day_status
** 18.02.2005 Hang     The following codes have been modified in function I_iwel_day_status:
**                     WHERE a.well_type IN ('GI', 'WG') AND p_daytime >= a.daytime to
**                     WHERE a.well_type IN ('OPGI', 'GPI', 'GI', 'WG') AND p_daytime >= a.daytime
**                     in order to accommodate new well types as per enhancement for TI#1874.
** 23.02.2005 DN       TI 1965: Renamed separator_type to class_name.
** 24.02.2005 Toha     Cleanup dead codes (old sysnam)
**                     Uses table instead of views
** 09.03.2005 AV       Corrected reference to strm_meter_freq and EQPM_STATUS_SCR
** 09.05.2005 ROV      Updated cursors joining version and objects tables to handle version table end date correctly
** 28.06.2005 SHN      Tracker 2385. Updated i_strm_water_analysis,i_strm_day_stream,i_strm_mth_stream
**                     because stream_category,stream_type are moved from table STREAM to STRM_VERSION.
** 10.10.2005 Nazli    Updated procedure i_pwel_day_status
** 17.08.2005 Ron      Updated function i_tank_measurement to only instantiate tanks with tank meter frequency DAY and MONTH. Tank Meter Frequency = EVENT is excluded.
** 26.08.2005 DN       TI2572: Code walkthrough: make sure that cursors in sub-procedures picks the correct versions by date.
** 29.08.2005 DN       Procedure i_pwel_day_status: corrected default logic.
** 09.12.2005 DN       TI2288: Added new_mth_start.
** 20.12.2005 Nazli    TI2625: Updated i_pwel_day_status and i_iwel_day_status
** 27.12.2005 Ron Boh  TI# 645: Update i_iwel_day_status to instantiate steam injection wells
** 04.01.2006          TI2625: Updated i_pwel_day_status and i_iwel_day_status to handle Well with NO status
** 06.01.2006          TI2625: Corrected error in i_pwel_day_status and i_iwel_day_status as it was qualifying against well_status and not active_well_status
** 08.02.2006 Darren   TI3488 Take the prosty_code IS_ACTIVE into account for i_object_day_weather
** 14.03.2006 BOHHHRON Update function i_iwel_day_status to instantiate OPSI wells.
** 26.03.2006 ZAKIIARI TI#3381: Added function i_wbi_day_status to instantiate Well Bore Intervals.
** 04.04.2006 kaurrnar TI#3296: Daily Pipeline Status
** 26.04.2006 Darren   TI#2619: Added new procedure i_object_item_comment
** 04.05.2006 HUS      TI#3704: Modified cur_get_keys to use new meter freq codes and new aggregate flag.
** 10.05.2006 Jerome   TI#2619: Added procedure i_object_item_comment to be looped in new_day_end
** 15.05.2006 LAU      TD#5881: Modified procedure i_strm_mth_stream
** 26.05.2006 Jerome   TD#6211: Modified procedure i_object_item_comment
** 26.05.2006 DN       TD#6281: Bug fix in i_wbi_day_status procedure.
** 13.06.2006 ZAKIIARI TI#3941: Bug fix in i_strm_mth_stream to use 'MTH' instead of 'MONTH'
** 30.06.2006 LAU      TI#4116: Instantiantion of daily weather objects fails
** 11.07.2006 Toha     TI#2922: Performance for i_wbi_day_status, i_object_item_comment
** 18.07.2006 SSK      TI 3948; Added procedure i_initiate_day
** 28.08.2006 seongkok TI#1202: Modified procedure i_fcty_day_pob
** 23.08.2006 Toha     TI#4367: Records are instantiated for wells without status
** 15.11.2006 Rahmanaz TI#4762 (4638): Removed nvl() function around sv.strm_meter_freq at i_strm_day_stream
** 14.12.2006 Toha     ECPD - Test on WELL_STATUS should be repalce with test on ACTIVE_WELL_STATUS
** 19.01.2007 RAJARSAR Added procedure i_daily_deferment_summary
** 12.02.2007 LAU      ECPD-3632: Added procedure i_iwel_mth_status and added call i_iwel_mth_status from new_month procedure
** 13.04.2007 LAU      ECPD-5253: Modified procedure i_iwel_day_status and i_iwel_mth_status
** 20.04.2007 RAJARSAR ECPD-4823: Modified procedure i_iwel_day_status and i_iwel_mth_status to support new injection type: Water and Steam Injector
** 14.08.2007 LAU      ECPD-2022: Modified procedure i_eqpm_day_status
** 25.09.2007 IDRUSSAB ECPD-6583: Modified i_pwel_day_status
** 21.12.2007 oonnnng  ECPD-6848: Update i_pflw_day_status() function to include instantiation for this new flowline type ('GP')
** 15.02.2008 LIZ      ECPD-4848: Updated i_pwel_day_status, i_iwel_day_status, i_iwel_mth_status to use the ISflags instead of Well_Type.
** 10.03.2008 AZURA    ECPD-3673: Updated i_strm_water_analysis, i_pwel_day_status, i_iwel_day_status to improve the performance of instantiation.
** 13.05.2008 Liz      ECPD-5963: Added procedure i_strm_mth_pc_cpy and modified procedure new_month.
** 21.05.2008 Liz      ECPD-5768: Added procedure i_strm_day_pc_cp and modified procedure new_day_end.
** 21.05.2008 Liz      ECPD-5769: Added procedure i_strm_mth_pc_cp and modified procedure new_month.
** 15.07.2008 Liz      ECPD-5768: Modified procedure i_strm_day_pc_cp and i_strm_mth_pc_cp to include Stream_Phase and to take components from component_set_list.
** 27.08.2008 RAJARSAR ECPD-9038: Modified procedure i_iwel_day_status to add support for well type=CI
** 15.09.2008 Farhaann ECPD-6540: Added procedure i_object_item_mth_comment, call i_object_item_mth_comment from new_month procedure and modified i_object_item_comment procedure.
** 23.10.2008 leongsei ECPD-9240: Modified procedure i_object_item_comment, i_object_item_mth_comment to handle if comments is blank
** 28.10.2008 oonnnng  ECPD-9741: Amend "EcDp_System.getDependentCode('ACTIVE_WELL_STATUS','WELL_STATUS',ec_pwel_period_status.well_status(p_object_id, p_daytime, 'EVENT', '<='));"
                                  to "ec_pwel_period_status.active_well_status(p_object_id, p_daytime, 'EVENT', '<=');"
** 31.10.2008 Liz      ECPD-6067: Modified mostly all functions and procedures to cater for the local lock checking.
** 05.12.2008 Farhaann ECPD-10339: Changed class_name = 'OBJECT_ITEM_COMMENT' in procedure i_object_item_comment
** 17.02.2009 leongsei ECPD-6067: Modified function i_strm_day_stream, i_strm_mth_stream, i_strm_water_analysis, i_psep_day_status,
**                                                  i_eqpm_day_status, i_prod_obj_period_status, i_object_day_weather, i_fcty_day_pob,
**                                                  i_fcty_day_hse, i_pflw_day_status, i_iflw_day_status, i_pwel_day_status,
**                                                  i_iwel_day_status, i_tank_measurement, i_chem_tank_period_status, i_wbi_day_status,
**                                                  i_pipe_day_status, i_object_item_comment, i_daily_deferment_summary, i_iwel_mth_status,
**                                                  i_strm_mth_pc_cpy, i_strm_day_pc_cp, i_strm_mth_pc_cp, i_object_item_mth_comment
**                                     for new parameter p_local_lock
** 10.04.2009 oonnnng  ECPD-6067: Change from using ec_ctrl_system_attribute to ecdp_ctrl_property.getSystemProperty function.
**                                Updated c_groups() cursor, and related statements in new_mth_start() function.
** 30.09.2009 Leongwen ECPD-12867: Modified ec_bs_instantiate.i_tank_measurement() to include tanks linked to BF WR.0060
** 23.12.2009 sharawan ECPD-13448: Modify i_tank_measurement to have checking for measurement_event_type column in sub-query to support different tank business function.
** 28.01.2010 Farhaann ECPD-13601: Added procedure i_chem_inj_point_status
** 24.03.2010 RAJARSAR ECPD-4828: Updated procedure i_strm_day_asset_data
** 25.03.2010 ismaiime ECPD-14247 Modify procedure i_pwel_day_status to support well type = WP
** 31.05.2010 RAJARSAR ECPD-14746: Updated procedure i_strm_day_asset_data to check for active wells and wells not in LPO(lost production opportunity -which is deferment)
** 09.11.2010 RAJARSAR ECPD-15770: Updated procedure i_defer_loss_accounting as table name has been changed to defer_loss_acc_event
** 09.12.2010 KUMARSUR ECPD-16067: Added procedure  i_strm_day_pc_cpy
** 07.01.2011 oonnnng  ECPD-16364: Amend the i_pwel_day_status() procedure to filter out the well_type = OB when performing update on pwel_day_status table.
** 22.02.2011 RAJARSAR ECPD-16192: Updated procedure i_defer_loss_accounting
** 02.12.2011 RAJARSAR ECPD-18799: Updated i_defer_loss_accounting.
** 01.03.2012 musaamah ECPD-18642: Added column downstream_sales and downstream_fuel to i_strm_day_asset_data procedure.
** 02.03.2012 abdulmaw ECPD-20112: Updated procedure i_tank_measurement to include PO.0109 and PO.0110
** 22.04.2012 rajarsar ECPD-19966: Added generic columns in i_object_item_comment and i_object_item_mth_comment
** 12.07.2012 KUMARSUR ECPD-21326: Added procedure i_well_hookup_day_status
** 17.07.2012 RAJARSAR ECPD-21437: Added procedure i_defer_loss_acc_fcty
** 08.10.2012 rajarsar ECPD-22070: Updated insert statement to use correct daytime in i_object_item_mth_comment.
** 09.01.2012 leongsei ECPD-22869: Modified procedure i_defer_loss_acc_fcty
** 21.02.2013 wonggkai ECPD-23143: Added procedure i_fcty_asset_analysis_daily and i_fcty_asset_analysis_monthly
** 22.02.2013 limmmchu ECPD-23143: Added procedure new_week and i_fcty_asset_analysis_weekly
** 05.03.2013 limmmchu ECPD-20005: Modified new_day_end to have the checking of future date for p_to_daytime
** 24.04.2013 musthram ECPD-23726: Water Source Wells - incorrectly updated in instantiation
** 20.08.2013 KUMARSUR ECPD-24470: Remove i_strm_day_pc_cpy and i_strm_mth_pc_cpy, this functions can be used from UE_BS_INSTANTIATE.
** 22.08.2013 KUMARSUR ECPD-28064: Added i_test_device_day_status for Daily Test Device Status.
** 22.04-2015 bintjnor ECPD-30083: Added ORDER BY sort order for i_initiate_day to ensure the instantiation job can be run according to sort order specified.
** 25.05.2015 leongwen ECPD-28746: Enhanced all instantiated codes with rev_text and Ecdp_Timestamp.getCurrentSysdate except i_defer_loss_accounting
** 25.08.2015 dhavaalo ECPD-30576: Modified procedure i_iwel_mth_status to support new injection type: Steam Injector.
** 11.09.2015 kashisag ECPD-28855: Modified the package to allow future date for Initiate Day.
** 16.09.2015 SHINDANI ECPD-19220: Added i_pwel_mth_status for Monthly production well status.
** 08.10.2015 dhavaalo ECPD-32095: Modified i_pwel_mth_status and i_iwel_mth_status.
** 11.09.2015 kashisag ECPD-28855: Modified the package to allow future date for Initiate Day
** 13.11.2015 abdulmaw ECPD-32675: Modified the package to fix INITIATE_DAY
** 21.06.2016 SHINDANI ECPD-34965: Modified procedures i_fcty_day_pob,i_fcty_day_hse,i_object_day_weather,i_object_item_comment,i_object_item_mth_comment
                                   to check facility end date.
** 31.08.2016 dhavaalo ECPD-38607: Remove usage of EcDp_Utilities.executestatement.
** 28.02.2017 shindani ECPD-42926: Modified procedures i_pwel_mth_status and i_iwel_mth_status to prevent generation of previous months records.
** 17.07.2017 dhavaalo ECPD-46761: Modified i_strm_day_asset_data to support new deferment version.
** 30.08.2017 kashisag ECPD-44009: Modified procedure to handle Revision text(rev_text) update on required basis.
** 10.10.2017 leongwen ECPD-49613: Added i_deferment_day for Deferment Day.
** 26.10.2017 kashisag ECPD-44009: The default behaviour for Revision Text is set to update the revision text with 'Created by instantiation process at given date' i.e. The system attribute INITIATE_DAY_REV_TEXT is set to 'Y'. In order to avoid revision text update while inserting/updating set INITIATE_DAY_REV_TEXT = 'N' from system settings -> custom settings.
** 03-11-2017 leongwen ECPD-50437: Modified i_deferment_day procedure to copy the previous loss quantities for different event_no.
** 17.11.2017 dhavaalo ECPD-45043: Remove reference of well_equip_Downtime.
** 17-01-2018 singishi ECPD-47302: Rename table well_deferment to deferment_event
** 08-02-2018 khatrnit ECPD-51428: Modified procedures i_object_item_comment,i_object_item_mth_comment to ensure copy forward works for all object types
************************************************************************************************************************************/
 --<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : executeStatement                                                          --
-- Description    : Used to run Dyanamic sql statements.
--                                                                                               --
-- Preconditions  :                --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                --
--                                                                                               --
-- Using functions:                                                 --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------

FUNCTION executeStatement(
p_statement varchar2)

RETURN VARCHAR2
--</EC-DOC>
IS

li_cursor  integer;
li_ret_val  integer;
lv2_err_string VARCHAR2(32000);

BEGIN

   li_cursor := DBMS_SQL.open_cursor;

   DBMS_SQL.parse(li_cursor,p_statement,DBMS_SQL.v7);
   li_ret_val := DBMS_SQL.execute(li_cursor);
   DBMS_SQL.Close_Cursor(li_cursor);

  RETURN NULL;

EXCEPTION
   WHEN DUP_VAL_ON_INDEX THEN
       DBMS_SQL.Close_Cursor(li_cursor);

    -- record not inserted, already there...
    lv2_err_string := 'Failed to execute (record exists): ' || chr(10) || p_statement || chr(10);
    return lv2_err_string;
  WHEN INVALID_CURSOR THEN

    lv2_err_string := 'Failed to execute (' || SQLERRM || '): ' || chr(10) || p_statement || chr(10);
    return lv2_err_string;

  WHEN OTHERS THEN
    IF DBMS_SQL.is_open(li_cursor) THEN
      DBMS_SQL.Close_Cursor(li_cursor);
      END IF;

    lv2_err_string := 'Failed to execute (' || SQLERRM || '): ' || chr(10) || p_statement || chr(10);
    return lv2_err_string;

END executeStatement;
  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function       : date_string                                                                  --
  ---------------------------------------------------------------------------------------------------
  FUNCTION date_string(p_daytime DATE) RETURN VARCHAR2 IS
    --</EC-DOC>
  BEGIN
    RETURN 'to_date(' || chr(39) || to_char(p_daytime,
                                            'dd-mon-yyyy hh24:mi') || chr(39) || ',' || chr(39) || 'dd-mon-yyyy hh24:mi' || chr(39) || ')';
  END date_string;


  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure  : InsertSystemDay                                                                  --
  ---------------------------------------------------------------------------------------------------
  PROCEDURE InsertSystemDay(p_date DATE)
  --</EC-DOC>

  IS

  PRAGMA  AUTONOMOUS_TRANSACTION;


  BEGIN

     INSERT INTO system_days (daytime) VALUES (p_date);

     COMMIT;

  EXCEPTION
     WHEN DUP_VAL_ON_INDEX THEN
       NULL;

  END InsertSystemDay;


  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : new_day_start
  ---------------------------------------------------------------------------------------------------
  PROCEDURE new_day_start(p_daytime DATE)
  --</EC-DOC>
   IS
    ld_postponed_day DATE;
    ld_lower_date    DATE;
    lr_system_day system_days%ROWTYPE;
    lv2_initiate_day_flag  varchar2(1);

  BEGIN

    -- Lock check
    IF EcDp_Month_lock.withinLockedMonth(p_daytime) IS NOT NULL THEN

      EcDp_Month_lock.raiseValidationError('INSERTING', p_daytime, p_daytime, trunc(p_daytime,'MONTH'), 'ec_bs_instantiate.new_day_start: Cannot instantiate in a locked month');

    END IF;

    ld_lower_date := ec_system_days.prev_daytime(p_daytime) + 1;

    IF ld_lower_date IS NULL THEN
       ld_lower_date := p_daytime;
    END IF;

    -- ECPD-28855 Check the system property and based on that exclude or include future dates
    lv2_initiate_day_flag := nvl(ecdp_ctrl_property.getSystemProperty('INITIATE_DAY', Ecdp_Timestamp.getCurrentSysdate),'N');
    IF (p_daytime <= Trunc(Ecdp_Timestamp.getCurrentSysdate, 'DD') AND lv2_initiate_day_flag IN ('Y','N')) THEN

      FOR ln_day_count IN 0 .. Trunc(Ecdp_Timestamp.getCurrentSysdate, 'DD') - ld_lower_date LOOP

        ld_postponed_day := ld_lower_date + ln_day_count;
   	    lr_system_day := ec_system_days.row_by_pk(ld_postponed_day);

        IF lr_system_day.daytime IS NULL THEN
           InsertSystemDay(ld_postponed_day);
        END IF;

        new_mth_start(ld_postponed_day);

      END LOOP;

    ELSIF ( p_daytime > Trunc(Ecdp_Timestamp.getCurrentSysdate, 'DD') AND lv2_initiate_day_flag = 'Y' ) THEN

      FOR ln_day_count IN 0 .. ld_lower_date - Trunc(Ecdp_Timestamp.getCurrentSysdate, 'DD')  LOOP

        ld_postponed_day := ld_lower_date - ln_day_count;

		    lr_system_day := ec_system_days.row_by_pk(ld_postponed_day);

        IF lr_system_day.daytime IS NULL THEN

           InsertSystemDay(ld_postponed_day);

        END IF;

        new_mth_start(ld_postponed_day);

      END LOOP;
    END IF;

  END new_day_start;


  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : new_day_end
  ---------------------------------------------------------------------------------------------------
  PROCEDURE new_day_end(p_daytime    DATE,
                        p_to_daytime DATE DEFAULT NULL)
  --</EC-DOC>
   IS

    ld_day      DATE;
    ld_end_date DATE;
    lr_system_day system_days%ROWTYPE;
    lv_sys_att    VARCHAR2(32);
    lv2_initiate_day_flag  varchar2(1);

    CURSOR c_daytime IS
     SELECT daytime
     FROM system_days
     WHERE daytime BETWEEN p_daytime
     AND (CASE WHEN p_to_daytime IS NULL AND lv2_initiate_day_flag ='Y' THEN p_daytime
                 WHEN p_to_daytime IS NULL AND lv2_initiate_day_flag ='N' THEN TRUNC(Ecdp_Timestamp.getCurrentSysdate, 'DD')
                   ELSE p_to_daytime END );

  BEGIN

    -- Lock check
    IF EcDp_Month_lock.withinLockedMonth(p_daytime) IS NOT NULL THEN

      EcDp_Month_lock.raiseValidationError('INSERTING', p_daytime, p_daytime, trunc(p_daytime,'MONTH'), 'ec_bs_instantiate.new_day_end: Cannot instantiate in a locked month');

    END IF;

	  -- make sure all rows are present in system_days
    lv2_initiate_day_flag := nvl(ecdp_ctrl_property.getSystemProperty('INITIATE_DAY', Ecdp_Timestamp.getCurrentSysdate),'N');

    IF ( p_to_daytime > Trunc(Ecdp_Timestamp.getCurrentSysdate, 'DD') AND lv2_initiate_day_flag = 'N') THEN
	    ld_end_date := Trunc(Ecdp_Timestamp.getCurrentSysdate, 'DD');

	  ELSIF (p_to_daytime IS NULL OR p_to_daytime < p_daytime) THEN
	    ld_end_date := p_daytime;

	  ELSE
	    ld_end_date := p_to_daytime;

	  END IF;

	  lv_sys_att := ecdp_ctrl_property.getSystemProperty('/com/ec/prod/ha/screens/LOCAL_LOCK_LEVEL', p_daytime);

    -- ECPD-28855 Check the system property and based on that exclude or include future dates
    IF (( lv2_initiate_day_flag = 'Y' ) OR ( lv2_initiate_day_flag ='N' AND p_daytime <= Trunc(Ecdp_Timestamp.getCurrentSysdate, 'DD')) ) THEN

      FOR ln_day_count IN 0 .. (ld_end_date - p_daytime) LOOP

        ld_day := p_daytime + ln_day_count;
        lr_system_day := ec_system_days.row_by_pk(ld_day);

        IF lr_system_day.daytime IS NULL THEN
          InsertSystemDay(ld_day);
        END IF; -- else skip

      END LOOP;


      FOR mycur IN c_daytime LOOP

        i_strm_day_stream(mycur.daytime,lv_sys_att);
        i_pwel_day_status(mycur.daytime,lv_sys_att);
        i_iwel_day_status(mycur.daytime,lv_sys_att);
        i_strm_water_analysis(mycur.daytime,lv_sys_att);
        i_object_day_weather(mycur.daytime,lv_sys_att);
        i_fcty_day_pob(mycur.daytime,lv_sys_att);
        i_psep_day_status(mycur.daytime,lv_sys_att);
        i_eqpm_day_status(mycur.daytime,lv_sys_att);
        i_test_device_day_status(mycur.daytime,lv_sys_att);
        i_fcty_day_hse(mycur.daytime,lv_sys_att);
        i_tank_measurement(mycur.daytime,lv_sys_att);
        i_chem_tank_period_status(mycur.daytime,lv_sys_att);
        i_iflw_day_status(mycur.daytime,lv_sys_att);
        i_pflw_day_status(mycur.daytime,lv_sys_att);
        i_wbi_day_status(mycur.daytime,lv_sys_att);
        i_pipe_day_status(mycur.daytime,lv_sys_att);
        i_daily_deferment_summary(mycur.daytime,lv_sys_att);
        i_object_item_comment(mycur.daytime,lv_sys_att);
        i_strm_day_pc_cp(mycur.daytime,lv_sys_att);
        i_chem_inj_point_status(mycur.daytime,lv_sys_att);
        i_strm_day_asset_data(mycur.daytime);
        i_defer_loss_accounting (mycur.daytime);
        i_defer_loss_acc_fcty(mycur.daytime);
        i_well_hookup_day_status(mycur.daytime,lv_sys_att);
        i_fcty_asset_analysis_daily(mycur.daytime);
        i_deferment_day(mycur.daytime,lv_sys_att);
        new_month(mycur.daytime,lv_sys_att);
        new_week(mycur.daytime,lv_sys_att);

      END LOOP;

    END IF;
  END new_day_end;


  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : new_day_start
  ---------------------------------------------------------------------------------------------------
  PROCEDURE new_mth_start(p_daytime DATE)
  --</EC-DOC>
   IS

    CURSOR c_groups(cp_ctrl_sa VARCHAR2, cp_daytime DATE) IS
    select unique parent_object_id
    from groups
    where upper(group_type) = 'OPERATIONAL'
    and upper(parent_object_type) <>'WELL_HOOKUP'
    and upper(parent_object_type) = upper(cp_ctrl_sa)
    and parent_object_id IS NOT NULL;

    ld_month DATE;
    ld_postponed_mth DATE;
    ld_lower_mth    DATE;
    lr_system_month system_month%ROWTYPE;
    lv_sys_att    VARCHAR2(32);
    lr_operational_lock operational_lock%ROWTYPE;
    lv2_initiate_day_flag  varchar2(1);

  BEGIN

    ld_month := TRUNC(p_daytime,'MM');

    ld_lower_mth := ADD_MONTHS(ec_system_month.prev_daytime(ld_month), 1);

    IF ld_lower_mth IS NULL THEN

      ld_lower_mth := ld_month;

    END IF;

    -- ECPD-28855  Check the system property and based on that exclude or include future months
    lv2_initiate_day_flag := nvl(ecdp_ctrl_property.getSystemProperty('INITIATE_DAY', Ecdp_Timestamp.getCurrentSysdate),'N');
    IF (ld_month <= Trunc(Ecdp_Timestamp.getCurrentSysdate, 'MM') AND ( lv2_initiate_day_flag IN ('Y','N'))) THEN

      FOR ln_day_count IN 0 .. MONTHS_BETWEEN(Trunc(Ecdp_Timestamp.getCurrentSysdate, 'MM'), ld_lower_mth) LOOP

        ld_postponed_mth := ADD_MONTHS(ld_lower_mth, ln_day_count);

        lr_system_month := ec_system_month.row_by_pk(ld_postponed_mth);

        IF lr_system_month.daytime IS NULL THEN

           INSERT INTO system_month (daytime) VALUES (ld_postponed_mth);

        END IF;

      END LOOP;

	  ELSIF ( ld_month > Trunc(Ecdp_Timestamp.getCurrentSysdate, 'MM') AND lv2_initiate_day_flag = 'Y' ) THEN

	    FOR ln_day_count IN 0 .. MONTHS_BETWEEN(ld_lower_mth, Trunc(Ecdp_Timestamp.getCurrentSysdate, 'MM')) LOOP

        ld_postponed_mth := ADD_MONTHS(Trunc(Ecdp_Timestamp.getCurrentSysdate, 'MM'), ln_day_count);

        lr_system_month := ec_system_month.row_by_pk(ld_postponed_mth);

        IF lr_system_month.daytime IS NULL THEN

           INSERT INTO system_month (daytime) VALUES (ld_postponed_mth);

        END IF;

      END LOOP;

	  END IF;

    lv_sys_att := ecdp_ctrl_property.getSystemProperty('/com/ec/prod/ha/screens/LOCAL_LOCK_LEVEL', p_daytime);

    -- ECPD-28855  Check the system property and based on that exclude or include future months
    IF (ld_month <= Trunc(Ecdp_Timestamp.getCurrentSysdate, 'MM') AND lv2_initiate_day_flag IN ('Y','N')) THEN

	    FOR r_groups IN c_groups(lv_sys_att, p_daytime) LOOP

	   	  ld_lower_mth := ADD_MONTHS(ec_operational_lock.prev_daytime(r_groups.parent_object_id, ld_month), 1);

		    IF ld_lower_mth IS NULL THEN

		       ld_lower_mth := ld_month;

		    END IF;

        FOR ln_day_count IN 0 .. MONTHS_BETWEEN(Trunc(Ecdp_Timestamp.getCurrentSysdate, 'MM'), ld_lower_mth) LOOP

          ld_postponed_mth := ADD_MONTHS(ld_lower_mth, ln_day_count);

          lr_operational_lock := ec_operational_lock.row_by_pk(r_groups.parent_object_id, ld_postponed_mth);

          IF lr_operational_lock.daytime IS NULL THEN

             INSERT INTO operational_lock (object_class, object_id, daytime) VALUES (lv_sys_att, r_groups.parent_object_id, ld_postponed_mth);

          END IF;

        END LOOP;
      END LOOP;

	  ELSIF ( ld_month > Trunc(Ecdp_Timestamp.getCurrentSysdate, 'MM') AND lv2_initiate_day_flag = 'Y' ) THEN

	   FOR r_groups IN c_groups(lv_sys_att, p_daytime) LOOP

	     ld_lower_mth := ADD_MONTHS(ec_operational_lock.prev_daytime(r_groups.parent_object_id, ld_month), 1);

		   IF ld_lower_mth IS NULL THEN

		     ld_lower_mth := ld_month;

		   END IF;

       FOR ln_day_count IN 0 .. MONTHS_BETWEEN( ld_lower_mth , Trunc(Ecdp_Timestamp.getCurrentSysdate, 'MM')) LOOP

         ld_postponed_mth := ADD_MONTHS(Trunc(Ecdp_Timestamp.getCurrentSysdate, 'MM'), ln_day_count);

         lr_operational_lock := ec_operational_lock.row_by_pk(r_groups.parent_object_id, ld_postponed_mth);

         IF lr_operational_lock.daytime IS NULL THEN

           INSERT INTO operational_lock (object_class, object_id, daytime) VALUES (lv_sys_att, r_groups.parent_object_id, ld_postponed_mth);

         END IF;

        END LOOP;
      END LOOP;

    END IF;

  END new_mth_start;


  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : new_month                                                                    --
  ---------------------------------------------------------------------------------------------------
  PROCEDURE new_month(p_daytime DATE, p_local_lock VARCHAR2)
  --</EC-DOC>
   IS

    lv2_initiate_day_flag  varchar2(1);

  BEGIN

    -- ECPD-28855  Check the system property and based on that exclude or include future months and make sure date is the first in the month.
    lv2_initiate_day_flag := nvl(ecdp_ctrl_property.getSystemProperty('INITIATE_DAY', Ecdp_Timestamp.getCurrentSysdate),'N');

    IF (TO_CHAR(p_daytime, 'DD') = '01' AND (( lv2_initiate_day_flag = 'Y') OR (lv2_initiate_day_flag='N' AND p_daytime <= Trunc(Ecdp_Timestamp.getCurrentSysdate, 'DD')))) THEN
      i_strm_mth_stream(p_daytime, p_local_lock);
	    i_pwel_mth_status(p_daytime, p_local_lock);
      i_iwel_mth_status(p_daytime, p_local_lock);
      i_strm_mth_pc_cp(p_daytime, p_local_lock);
      i_object_item_mth_comment(p_daytime, p_local_lock);
      i_fcty_asset_analysis_monthly(p_daytime);
    END IF;

  END new_month;

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : new_week                                                                   --
  ---------------------------------------------------------------------------------------------------
  PROCEDURE new_week(p_daytime DATE, p_local_lock VARCHAR2)
  --</EC-DOC>
   IS

		 ld_startWeek VARCHAR(2);
		 ld_defaultStartWeek VARCHAR(2);
		 ld_userStartWeek VARCHAR(2);
		 ld_userCount VARCHAR2(2);
     lv2_initiate_day_flag  varchar2(1);

  BEGIN

	ld_startweek := MOD(trunc(p_daytime,'DD') - date '1000-01-01',7);

    -- ECPD-28855 Check the system property and based on that exclude or include future months and make sure date is the first day of the week.
    lv2_initiate_day_flag := nvl(ecdp_ctrl_property.getSystemProperty('INITIATE_DAY', Ecdp_Timestamp.getCurrentSysdate),'N');
    IF (( lv2_initiate_day_flag = 'Y') OR (lv2_initiate_day_flag = 'N' AND p_daytime <= Trunc(Ecdp_Timestamp.getCurrentSysdate, 'DD'))) THEN

      SELECT count(1) into ld_userCount
         FROM CTRL_PROPERTY
         WHERE key = 'WEEKLY_ANALYSIS_START_DAY'
         AND DAYTIME = (SELECT max(daytime) FROM CTRL_PROPERTY WHERE key = 'WEEKLY_ANALYSIS_START_DAY' AND daytime<=Ecdp_Timestamp.getCurrentSysdate);

             IF ld_userCount > 0 THEN
               SELECT value_string into ld_userStartWeek
               FROM CTRL_PROPERTY
               WHERE key = 'WEEKLY_ANALYSIS_START_DAY'
               AND DAYTIME = (SELECT max(daytime) FROM CTRL_PROPERTY WHERE key = 'WEEKLY_ANALYSIS_START_DAY' AND daytime<=Ecdp_Timestamp.getCurrentSysdate);

             ELSE
               ld_userStartWeek := NULL;
             END IF;

      SELECT default_value_string into ld_defaultStartWeek
      FROM CTRL_PROPERTY_META
      WHERE key = 'WEEKLY_ANALYSIS_START_DAY';

         IF ld_startweek = nvl(ld_userStartWeek, ld_defaultStartWeek) THEN
             i_fcty_asset_analysis_weekly(p_daytime);
         END IF;

    END IF;

  END new_week;


  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : i_strm_day_stream
  ---------------------------------------------------------------------------------------------------
  PROCEDURE i_strm_day_stream(p_daytime DATE, p_local_lock VARCHAR2)
  --</EC-DOC>
   IS

    CURSOR cur_get_keys IS
      SELECT s.object_id, sv.strm_meter_freq -- default DAY
        FROM stream s, strm_version sv
       WHERE (sv.strm_meter_freq = 'DAY' or NVL(sv.aggregate_flag,'')='Y')
             AND sv.stream_type = 'M' -- only measured streams
             AND s.object_id = sv.object_id -- join s, sv
             AND p_daytime >= sv.daytime
             AND p_daytime < Nvl(sv.end_date, p_daytime + 1)
             AND p_daytime < Nvl(s.end_date, p_daytime + 1) AND NOT EXISTS
       (SELECT 1
                FROM strm_day_stream x
               WHERE s.object_id = x.object_id AND p_daytime = x.daytime);

  lv_parent_object_id VARCHAR2(32);
  lv2_rev_text VARCHAR2(2000);

  BEGIN

    IF ecdp_ctrl_property.getSystemProperty('INITIATE_DAY_REV_TEXT', Ecdp_Timestamp.getCurrentSysdate) = 'Y'  THEN
      lv2_rev_text := 'Created by instantiation process at '||to_char(Ecdp_Timestamp.getCurrentSysdate,'yyyy.mm.dd hh24:mi:ss');
    ELSE
      lv2_rev_text := NULL;
    END IF;

    FOR mycur IN cur_get_keys LOOP
      lv_parent_object_id := Ecdp_Groups.findParentObjectId(p_local_lock,'operational','STREAM',mycur.object_id,p_daytime);

      IF EcDp_Month_lock.localWithinLockedMonth(p_local_lock, lv_parent_object_id, p_daytime) IS NULL THEN

          INSERT INTO strm_day_stream (object_id, daytime, rev_text)
          VALUES (mycur.object_id, p_daytime, lv2_rev_text);

      END IF;


    END LOOP;
  END i_strm_day_stream;


  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : i_strm_mth_stream
  ---------------------------------------------------------------------------------------------------
  PROCEDURE i_strm_mth_stream(p_daytime DATE, p_local_lock VARCHAR2)
  --</EC-DOC>
   IS

    CURSOR cur_get_keys IS
      SELECT s.object_id, Nvl(sv.strm_meter_freq, 'DAY') -- default DAY
        FROM stream s, strm_version sv
       WHERE sv.strm_meter_freq = 'MTH' AND sv.stream_type = 'M' -- only measured streams
             AND p_daytime >= sv.daytime
             AND p_daytime < Nvl(sv.end_date, p_daytime + 1)
             AND s.object_id = sv.object_id
             AND p_daytime < Nvl(s.end_date, p_daytime + 1) AND NOT EXISTS
       (SELECT 1
                FROM strm_mth_stream x
               WHERE s.object_id = x.object_id AND p_daytime = x.daytime);

     lv_parent_object_id VARCHAR2(32);
     lv2_rev_text VARCHAR2(2000);

  BEGIN
    IF ecdp_ctrl_property.getSystemProperty('INITIATE_DAY_REV_TEXT', Ecdp_Timestamp.getCurrentSysdate) = 'Y'  THEN
      lv2_rev_text := 'Created by instantiation process at '||to_char(Ecdp_Timestamp.getCurrentSysdate,'yyyy.mm.dd hh24:mi:ss');
    ELSE
      lv2_rev_text := NULL;
    END IF;

    FOR mycur IN cur_get_keys LOOP

      lv_parent_object_id := Ecdp_Groups.findParentObjectId(p_local_lock,'operational','STREAM',mycur.object_id,p_daytime);

      IF EcDp_Month_lock.localWithinLockedMonth(p_local_lock, lv_parent_object_id, p_daytime) IS NULL THEN

        INSERT INTO strm_mth_stream (object_id, daytime, rev_text)
        VALUES (mycur.object_id, p_daytime, lv2_rev_text);

      END IF;


    END LOOP;
  END i_strm_mth_stream;


  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : i_strm_water_analysis
  ---------------------------------------------------------------------------------------------------
  PROCEDURE i_strm_water_analysis(p_daytime DATE, p_local_lock VARCHAR2)
  --</EC-DOC>
   IS
    CURSOR cur_get_keys IS
      SELECT s.object_id, 'DAY_SAMPLER' sampling_method
        FROM stream s, strm_version v, strm_set_list ssl
       WHERE s.object_id = v.object_id
       AND   s.object_id = ssl.object_id
       AND   p_daytime >= ssl.from_date and p_daytime < nvl(ssl.end_date,p_daytime+1)
       AND   ssl.stream_set = 'PO.0004'
       AND   p_daytime >= v.daytime
       AND   p_daytime < Nvl(v.end_date, p_daytime + 1)
       AND   p_daytime < Nvl(s.end_date, p_daytime + 1)
       AND NOT EXISTS (
          SELECT 1 FROM strm_water_analysis swa
          WHERE swa.object_id = s.object_id
          AND swa.daytime = p_daytime
          AND swa.sampling_method = 'DAY_SAMPLER');

    lv_parent_object_id VARCHAR2(32);
    lv2_rev_text VARCHAR2(2000);
  BEGIN

    IF ecdp_ctrl_property.getSystemProperty('INITIATE_DAY_REV_TEXT', Ecdp_Timestamp.getCurrentSysdate) = 'Y'  THEN
      lv2_rev_text := 'Created by instantiation process at '||to_char(Ecdp_Timestamp.getCurrentSysdate,'yyyy.mm.dd hh24:mi:ss');
    ELSE
      lv2_rev_text := NULL;
    END IF;

    FOR mycur IN cur_get_keys LOOP

      lv_parent_object_id := Ecdp_Groups.findParentObjectId(p_local_lock,'operational','STREAM',mycur.object_id,p_daytime);

      IF EcDp_Month_lock.localWithinLockedMonth(p_local_lock, lv_parent_object_id, p_daytime) IS NULL THEN

            INSERT INTO strm_water_analysis (object_id, daytime, sampling_method, rev_text)
            VALUES (mycur.object_id, p_daytime, mycur.sampling_method,lv2_rev_text);

      END IF;

    END LOOP;

  END i_strm_water_analysis;


  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : i_psep_day_status
  --------------------------------------------------------------------------------------------------
  PROCEDURE i_psep_day_status(p_daytime DATE, p_local_lock VARCHAR2)
  --</EC-DOC>
   IS
     CURSOR cur_get_keys IS
            SELECT s.object_id
            FROM separator s, sepa_version sv
            WHERE s.class_name = 'PRODSEPARATOR'
            AND s.object_id = sv.object_id
            AND (sv.sepa_meter_freq = 'DAY' OR sv.aggregate_flag='Y')
            AND p_daytime >= sv.daytime
            AND p_daytime < Nvl(sv.end_date, p_daytime + 1)
            AND p_daytime < Nvl(s.end_date, p_daytime + 1) AND NOT EXISTS (
              SELECT 1 FROM psep_day_status pds
                WHERE pds.object_id = s.object_id
                  AND pds.daytime = p_daytime);

     lv_parent_object_id VARCHAR2(32);
     lv2_rev_text VARCHAR2(2000);

  BEGIN

    IF ecdp_ctrl_property.getSystemProperty('INITIATE_DAY_REV_TEXT', Ecdp_Timestamp.getCurrentSysdate) = 'Y'  THEN
      lv2_rev_text := 'Created by instantiation process at '||to_char(Ecdp_Timestamp.getCurrentSysdate,'yyyy.mm.dd hh24:mi:ss');
    ELSE
      lv2_rev_text := NULL;
    END IF;

    FOR mycur IN cur_get_keys LOOP

      lv_parent_object_id := Ecdp_Groups.findParentObjectId(p_local_lock,'operational','PRODSEPARATOR',mycur.object_id,p_daytime);

      IF EcDp_Month_lock.localWithinLockedMonth(p_local_lock, lv_parent_object_id, p_daytime) IS NULL THEN

         INSERT INTO psep_day_status (object_id, daytime, rev_text)
         VALUES (mycur.object_id, p_daytime,lv2_rev_text);

      END IF;
   END LOOP;
  END i_psep_day_status;


  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : i_eqpm_day_status
  ---------------------------------------------------------------------------------------------------
  PROCEDURE i_eqpm_day_status(p_daytime DATE, p_local_lock VARCHAR2)
  --</EC-DOC>
   IS
    CURSOR cur_get_keys IS
      SELECT e.object_id, e.class_name, ev.EQPM_STATUS_SCR
      FROM equipment e, eqpm_version ev
      WHERE e.object_id = ev.object_id
       AND p_daytime >= ev.daytime
       AND p_daytime < Nvl(ev.end_date, p_daytime + 1)
       AND p_daytime < Nvl(e.end_date, p_daytime + 1)
       AND ev.EQPM_DATA_FREQ = 'DAY' AND USE_IN_BF ='PO.0011'
       AND NOT EXISTS
       (SELECT 1
               FROM eqpm_day_status x
               WHERE e.object_id = x.object_id AND p_daytime = x.daytime);

    lv_parent_object_id VARCHAR2(32);
    lv2_rev_text VARCHAR2(2000);

  BEGIN

    IF ecdp_ctrl_property.getSystemProperty('INITIATE_DAY_REV_TEXT', Ecdp_Timestamp.getCurrentSysdate) = 'Y'  THEN
      lv2_rev_text := 'Created by instantiation process at '||to_char(Ecdp_Timestamp.getCurrentSysdate,'yyyy.mm.dd hh24:mi:ss');
    ELSE
      lv2_rev_text := NULL;
    END IF;

    FOR mycur IN cur_get_keys LOOP

        lv_parent_object_id := Ecdp_Groups.findParentObjectId(p_local_lock,'operational',mycur.class_name,mycur.object_id,p_daytime);

        IF EcDp_Month_lock.localWithinLockedMonth(p_local_lock, lv_parent_object_id, p_daytime) IS NULL THEN

            INSERT INTO eqpm_day_status (object_id, daytime, rev_text)
            VALUES (mycur.object_id, p_daytime, lv2_rev_text);
        END IF;
    END LOOP;
  END i_eqpm_day_status;


  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : i_test_device_day_status
  ---------------------------------------------------------------------------------------------------
  PROCEDURE i_test_device_day_status(p_daytime DATE, p_local_lock VARCHAR2)
  --</EC-DOC>
   IS
    CURSOR cur_get_keys IS
      SELECT e.object_id
      FROM test_device e, test_device_version ev
      WHERE e.object_id = ev.object_id
       AND p_daytime >= ev.daytime
       AND p_daytime < Nvl(ev.end_date, p_daytime + 1)
       AND p_daytime < Nvl(e.end_date, p_daytime + 1)
       AND ev.TEST_DEVICE_DATA_FREQ = 'DAY' AND USE_IN_BF ='PO.0122'
       AND NOT EXISTS
       (SELECT 1
               FROM test_device_day_status x
               WHERE e.object_id = x.object_id AND p_daytime = x.daytime);

    lv_parent_object_id VARCHAR2(32);
    lv2_rev_text VARCHAR2(2000);

  BEGIN

    IF ecdp_ctrl_property.getSystemProperty('INITIATE_DAY_REV_TEXT', Ecdp_Timestamp.getCurrentSysdate) = 'Y'  THEN
      lv2_rev_text := 'Created by instantiation process at '||to_char(Ecdp_Timestamp.getCurrentSysdate,'yyyy.mm.dd hh24:mi:ss');
    ELSE
      lv2_rev_text := NULL;
    END IF;

    FOR mycur IN cur_get_keys LOOP

        lv_parent_object_id := Ecdp_Groups.findParentObjectId(p_local_lock,'operational','TEST_DEVICE',mycur.object_id,p_daytime);

        IF EcDp_Month_lock.localWithinLockedMonth(p_local_lock, lv_parent_object_id, p_daytime) IS NULL THEN

            INSERT INTO test_device_day_status (object_id, daytime, rev_text)
            VALUES (mycur.object_id, p_daytime, lv2_rev_text);
        END IF;
    END LOOP;
  END i_test_device_day_status;


  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : i_object_day_weather
  ---------------------------------------------------------------------------------------------------
  PROCEDURE i_object_day_weather(p_daytime DATE, p_local_lock VARCHAR2)
  --</EC-DOC>
   IS
    CURSOR cur_get_keys IS
      SELECT ws.object_id   object_id,
             ws.facility_id facility_id,
             c.code_type2   item_type,
             c.code2        item_code
        FROM weather_site ws, ctrl_code_dependency c, prosty_codes pc
       WHERE c.dependency_type = 'WHATEVER' AND
             c.code_type1 = 'WEATHER' AND c.code1 = 'WEATHER' AND
             c.code1 = pc.code AND
             pc.is_active = 'Y' AND
             c.code_type1 = pc.code_type
        AND NOT EXISTS (SELECT 1 FROM object_day_weather odw
                        WHERE odw.object_id = ws.object_id
                        AND odw.daytime = p_daytime
                        AND odw.item_code = c.code2
                        AND odw.item_type = c.code_type2)
        AND EXISTS (SELECT 1
                       FROM production_facility pf
                      WHERE pf.OBJECT_ID = ws.object_id
                        AND p_daytime >= pf.start_date
                        AND p_daytime < NVL(pf.end_date,p_daytime+1));


    lv_parent_object_id VARCHAR2(32);
    lv_class_name VARCHAR2(32);
    lv2_rev_text VARCHAR2(2000);

  BEGIN

    IF ecdp_ctrl_property.getSystemProperty('INITIATE_DAY_REV_TEXT', Ecdp_Timestamp.getCurrentSysdate) = 'Y'  THEN
      lv2_rev_text := 'Created by instantiation process at '||to_char(Ecdp_Timestamp.getCurrentSysdate,'yyyy.mm.dd hh24:mi:ss');
    ELSE
      lv2_rev_text := NULL;
    END IF;

    FOR mycur IN cur_get_keys LOOP
        lv_parent_object_id := null;
        lv_class_name := ecdp_objects.GetObjClassName(mycur.object_id);

        IF upper(p_local_lock) <> upper(lv_class_name) THEN
            lv_parent_object_id := Ecdp_Groups.findParentObjectId(p_local_lock,'operational',lv_class_name,mycur.object_id,p_daytime);
        END IF;

        IF lv_parent_object_id IS NULL THEN
               lv_parent_object_id := mycur.object_id;
        END IF;

        IF EcDp_Month_lock.localWithinLockedMonth(p_local_lock, lv_parent_object_id, p_daytime) IS NULL THEN

          INSERT INTO object_day_weather (object_id, daytime, item_code, item_type, rev_text)
          VALUES (mycur.object_id, p_daytime, mycur.item_code, mycur.item_type, lv2_rev_text);

        END IF;

    END LOOP;

  END i_object_day_weather;


  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : i_fcty_day_pob
  ---------------------------------------------------------------------------------------------------
  PROCEDURE i_fcty_day_pob(p_daytime DATE, p_local_lock VARCHAR2)
  --</EC-DOC>
   IS
    TYPE t_fcty_day_pob IS TABLE OF fcty_day_pob%ROWTYPE;
    l_data t_fcty_day_pob;
    lv_parent_object_id VARCHAR2(32);
    lv_class_name VARCHAR2(32);
    ld_date DATE;
    lv2_rev_text VARCHAR2(2000);

    CURSOR c_fcty_day_pob IS
      SELECT *
        FROM fcty_day_pob t
       WHERE daytime = p_daytime - 1 AND p_daytime >= Nvl(from_date, p_daytime) AND
             p_daytime <= Nvl(to_date, p_daytime + 1) and not exists
       (select 1
                from fcty_day_pob x
               where x.object_id = t.object_id and x.daytime = t.daytime + 1 and
                     x.job_category = t.job_category and Nvl(x.name, 'NONAME') = Nvl(t.name,'NONAME'))
        AND EXISTS (SELECT 1
                         FROM production_facility pf
                        WHERE pf.object_id = t.object_id
                          AND p_daytime >= pf.start_date
                          AND p_daytime < NVL(pf.end_date,p_daytime+1));


  BEGIN

    IF ecdp_ctrl_property.getSystemProperty('INITIATE_DAY_REV_TEXT', Ecdp_Timestamp.getCurrentSysdate) = 'Y'  THEN
      lv2_rev_text := 'Created by instantiation process at '||to_char(Ecdp_Timestamp.getCurrentSysdate,'yyyy.mm.dd hh24:mi:ss');
    ELSE
      lv2_rev_text := NULL;
    END IF;

    FOR mycur IN c_fcty_day_pob LOOP
        lv_parent_object_id := null;
        lv_class_name := ecdp_objects.GetObjClassName(mycur.object_id);
        ld_date := mycur.daytime + 1;

        IF upper(p_local_lock) <> upper(lv_class_name) THEN
           lv_parent_object_id := Ecdp_Groups.findParentObjectId(p_local_lock,'operational',lv_class_name,mycur.object_id,p_daytime);
        END IF;

        IF lv_parent_object_id IS NULL THEN
              lv_parent_object_id := mycur.object_id;
        END IF;

        IF Ecdp_Month_Lock.localWithinLockedMonth(p_local_lock, lv_parent_object_id,p_daytime) IS NULL THEN

           INSERT INTO fcty_day_pob
           (object_id,job_category,daytime,from_date,to_date,name,contractor_count,drilling_serv_count,others_count,operator_crew_count,
           operator_others_count,maintenance_serv_count,drilling_ent_count,cabel_serv_count,catering_count,beds_avail_operator,
           flotel_crew,day_visits_count,principal_other_count,principal_count,by_boat_count,by_helicopter_count,head_count,comments,rev_text,
           value_1,value_2,value_3 ,value_4 ,value_5 ,value_6 ,value_7 ,value_8 ,value_9 ,value_10 ,text_1 ,text_2 ,text_3 ,text_4)
           VALUES
           (mycur.object_id,mycur.job_category,ld_date,mycur.from_date,mycur.to_date,mycur.name,mycur.contractor_count,mycur.drilling_serv_count,
            mycur.others_count,mycur.operator_crew_count,mycur.operator_others_count,mycur.maintenance_serv_count,mycur.drilling_ent_count,
            mycur.cabel_serv_count,mycur.catering_count,mycur.beds_avail_operator,mycur.flotel_crew,mycur.day_visits_count,
            mycur.principal_other_count,mycur.principal_count,mycur.by_boat_count,mycur.by_helicopter_count,mycur.head_count,mycur.comments,lv2_rev_text,
            mycur.value_1 ,mycur.value_2 ,mycur.value_3 ,mycur.value_4 ,mycur.value_5 ,mycur.value_6 ,mycur.value_7 ,mycur.value_8 ,mycur.value_9 ,mycur.value_10 ,mycur.text_1 ,mycur.text_2 ,mycur.text_3 ,mycur.text_4);
        END IF;

    END LOOP;

  END i_fcty_day_pob;


  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : i_fcty_day_hse
  ---------------------------------------------------------------------------------------------------
  PROCEDURE i_fcty_day_hse(p_daytime DATE, p_local_lock VARCHAR2)
  --</EC-DOC>
   IS
    CURSOR cur_get_keys IS
      SELECT c.code, p.object_id
      FROM production_facility p, prosty_codes c
      WHERE c.code_type = 'HSE_CODES'
      AND c.is_active = 'Y'
      AND p_daytime >= p.start_date
      AND p_daytime < NVL(p.end_date,p_daytime+1)
      AND NOT EXISTS (SELECT 1 FROM fcty_day_hse fdh
                       WHERE fdh.object_id = p.object_id
                       AND fdh.daytime = p_daytime
                       AND fdh.hse_type = c.code)
       ORDER BY p.object_id;

       lv_parent_object_id VARCHAR2(32);
       lv_class_name VARCHAR2(32);
       lv2_rev_text VARCHAR2(2000);

  BEGIN

    IF ecdp_ctrl_property.getSystemProperty('INITIATE_DAY_REV_TEXT', Ecdp_Timestamp.getCurrentSysdate) = 'Y'  THEN
      lv2_rev_text := 'Created by instantiation process at '||to_char(Ecdp_Timestamp.getCurrentSysdate,'yyyy.mm.dd hh24:mi:ss');
    ELSE
      lv2_rev_text := NULL;
    END IF;

    FOR mycur IN cur_get_keys LOOP
        lv_parent_object_id := null;
        lv_class_name := ecdp_objects.GetObjClassName(mycur.object_id);

        IF upper(p_local_lock) <> upper(lv_class_name) THEN
            lv_parent_object_id := Ecdp_Groups.findParentObjectId(p_local_lock,'operational',lv_class_name,mycur.object_id,p_daytime);
        END IF;

        IF lv_parent_object_id IS NULL THEN
               lv_parent_object_id := mycur.object_id;
        END IF;

        IF EcDp_Month_lock.localWithinLockedMonth(p_local_lock, lv_parent_object_id, p_daytime) IS NULL THEN

          INSERT INTO fcty_day_hse (object_id, daytime, hse_type, quantity, rev_text)
          VALUES (mycur.object_id, p_daytime, mycur.code, 0,lv2_rev_text);
        END IF;

    END LOOP;

  END i_fcty_day_hse;


  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : i_pflw_day_status
  ---------------------------------------------------------------------------------------------------
  PROCEDURE i_pflw_day_status(p_daytime DATE, p_local_lock VARCHAR2)
  --</EC-DOC>
   IS
    CURSOR cur_get_keys IS
      SELECT f.object_id, fv.flowline_type
        FROM flowline f, flwl_version fv
       WHERE fv.flowline_type in ('OP','DL','GP')
       AND (fv.flwl_meter_freq='DAY' OR fv.aggregate_flag='Y')
       AND (fv.flwl_meter_freq='DAY' OR fv.aggregate_flag='Y')
       AND p_daytime >= fv.daytime
       AND p_daytime < Nvl(fv.end_date, p_daytime + 1)
       AND f.object_id = fv.object_id
       AND p_daytime < Nvl(f.end_date, p_daytime + 1) AND NOT EXISTS
       (SELECT 1
                FROM pflw_day_status x
               WHERE f.object_id = x.object_id AND p_daytime = x.daytime);

    lv_parent_object_id VARCHAR2(32);
    lv2_rev_text VARCHAR2(2000);
  BEGIN

    IF ecdp_ctrl_property.getSystemProperty('INITIATE_DAY_REV_TEXT', Ecdp_Timestamp.getCurrentSysdate) = 'Y'  THEN
      lv2_rev_text := 'Created by instantiation process at '||to_char(Ecdp_Timestamp.getCurrentSysdate,'yyyy.mm.dd hh24:mi:ss');
    ELSE
      lv2_rev_text := NULL;
    END IF;

    FOR mycur IN cur_get_keys LOOP

      lv_parent_object_id := Ecdp_Groups.findParentObjectId(p_local_lock,'operational','FLOWLINE',mycur.object_id,p_daytime);

      IF EcDp_Month_lock.localWithinLockedMonth(p_local_lock, lv_parent_object_id, p_daytime) IS NULL THEN

         INSERT INTO pflw_day_status (object_id, daytime, rev_text)
         VALUES (mycur.object_id, p_daytime, lv2_rev_text);

      END IF;
    END LOOP;
  END i_pflw_day_status;

    --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : i_well_hookup_day_status
  ---------------------------------------------------------------------------------------------------
  PROCEDURE i_well_hookup_day_status(p_daytime DATE, p_local_lock VARCHAR2)
  --</EC-DOC>
   IS
    CURSOR cur_get_keys IS
      SELECT w.object_id
        FROM well_hookup w, well_hookup_version wv
       WHERE p_daytime >= wv.daytime
       AND p_daytime < Nvl(wv.end_date, p_daytime + 1)
       AND w.object_id = wv.object_id
       AND p_daytime < Nvl(w.end_date, p_daytime + 1) AND NOT EXISTS
       (SELECT 1
                FROM well_hookup_day_status x
               WHERE w.object_id = x.object_id AND p_daytime = x.daytime);

    lv_parent_object_id VARCHAR2(32);
    lv2_rev_text VARCHAR2(2000);

  BEGIN

    IF ecdp_ctrl_property.getSystemProperty('INITIATE_DAY_REV_TEXT', Ecdp_Timestamp.getCurrentSysdate) = 'Y'  THEN
      lv2_rev_text := 'Created by instantiation process at '||to_char(Ecdp_Timestamp.getCurrentSysdate,'yyyy.mm.dd hh24:mi:ss');
    ELSE
      lv2_rev_text := NULL;
    END IF;

    FOR mycur IN cur_get_keys LOOP

      lv_parent_object_id := Ecdp_Groups.findParentObjectId(p_local_lock,'operational','WELL_HOOKUP',mycur.object_id,p_daytime);

      IF EcDp_Month_lock.localWithinLockedMonth(p_local_lock, lv_parent_object_id, p_daytime) IS NULL THEN

         INSERT INTO well_hookup_day_status (object_id, daytime, rev_text)
         VALUES (mycur.object_id, p_daytime, lv2_rev_text);

      END IF;
    END LOOP;
  END i_well_hookup_day_status;


  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : i_iflw_day_status
  ---------------------------------------------------------------------------------------------------
  PROCEDURE i_iflw_day_status(p_daytime DATE, p_local_lock VARCHAR2)
  --</EC-DOC>
   IS
    CURSOR cur_get_keys IS
      SELECT f.object_id, fv.flowline_type
        FROM flowline f, flwl_version fv
       WHERE fv.flowline_type IN ('GI', 'WI', 'GL')
       AND p_daytime >= fv.daytime
       AND p_daytime < Nvl(fv.end_date, p_daytime + 1)
       AND f.object_id = fv.object_id
       AND p_daytime < Nvl(f.end_date, p_daytime + 1)
       AND NOT EXISTS
       (SELECT 1
                FROM iflw_day_status x
               WHERE f.object_id = x.object_id AND
                     fv.flowline_type = x.inj_type AND p_daytime = x.daytime);

    lv_parent_object_id VARCHAR2(32);
    lv2_rev_text VARCHAR2(2000);

  BEGIN

    IF ecdp_ctrl_property.getSystemProperty('INITIATE_DAY_REV_TEXT', Ecdp_Timestamp.getCurrentSysdate) = 'Y'  THEN
      lv2_rev_text := 'Created by instantiation process at '||to_char(Ecdp_Timestamp.getCurrentSysdate,'yyyy.mm.dd hh24:mi:ss');
    ELSE
      lv2_rev_text := NULL;
    END IF;

    FOR mycur IN cur_get_keys LOOP

      lv_parent_object_id := Ecdp_Groups.findParentObjectId(p_local_lock,'operational','FLOWLINE',mycur.object_id,p_daytime);

      IF EcDp_Month_lock.localWithinLockedMonth(p_local_lock, lv_parent_object_id, p_daytime) IS NULL THEN

        INSERT INTO iflw_day_status (object_id, inj_type, daytime, rev_text)
        VALUES (mycur.object_id, mycur.flowline_type, p_daytime,lv2_rev_text);
      END IF;
    END LOOP;
  END i_iflw_day_status;


  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : i_pwel_day_status
  --
  -- This procedure must also fix any records that have incorrect instrumentation_type
  ---------------------------------------------------------------------------------------------------
   PROCEDURE i_pwel_day_status (p_daytime DATE, p_local_lock VARCHAR2)
  --</EC-DOC>
   IS
    lv_instr_type  VARCHAR2(2);
    lv_well_type VARCHAR2(32);
    lv_data_class_name VARCHAR2(32);
    lv_parent_object_id VARCHAR2(32);
    lv2_rev_text VARCHAR2(2000);

    CURSOR cur_get_keys_1 IS
    SELECT w.object_id, wv.instrumentation_type, wv.well_type
    FROM well w, well_version wv
    WHERE wv.isProducer='Y' -- this is valid after 9.3 sp2. Before service pack 2 we would have to use wv.well_type in ('OP','GP','CP','OPSI','OPGI','GPI','WS')
    AND p_daytime >= wv.daytime AND p_daytime < Nvl(wv.end_date, p_daytime + 1)
    AND p_daytime >= w.start_date AND p_daytime < Nvl(w.end_date, p_daytime + 1)
    AND w.object_id = wv.object_id
    AND NOT EXISTS
       (SELECT 1 -- remove wells that are already in pwel_day_status
       FROM PWEL_DAY_STATUS x
       WHERE w.object_id = x.object_id AND p_daytime = x.daytime
       UNION
       SELECT 1 -- remove wells that have active_well_status='CLOSED_LT' at the beginning of the new production_day.
       FROM PWEL_PERIOD_STATUS pps
       WHERE w.object_id = pps.object_id
       AND pps.time_span='EVENT'
       AND pps.active_well_status='CLOSED_LT'
       AND pps.daytime=
          (SELECT MAX(daytime) from pwel_period_status pps2
          WHERE pps2.object_id=pps.object_id
          AND pps2.time_span='EVENT'
          AND pps2.day <= p_daytime) -- its the production_day "day" we must use
       );

  BEGIN

    IF ecdp_ctrl_property.getSystemProperty('INITIATE_DAY_REV_TEXT', Ecdp_Timestamp.getCurrentSysdate) = 'Y'  THEN
      lv2_rev_text := 'Created by instantiation process at '||to_char(Ecdp_Timestamp.getCurrentSysdate,'yyyy.mm.dd hh24:mi:ss');
    ELSE
      lv2_rev_text := NULL;
    END IF;


    FOR mycur IN cur_get_keys_1 LOOP
      lv_instr_type := mycur.instrumentation_type;
      lv_well_type := mycur.well_type;

      IF lv_well_type = 'WS' OR lv_well_type = 'WP' THEN
          lv_data_class_name := 'PWEL_DAY_STATUS_WS';
      ELSIF lv_instr_type = '1' THEN
          lv_data_class_name := 'PWEL_DAY_STATUS';
      ELSIF lv_instr_type = '2' THEN
          lv_data_class_name := 'PWEL_DAY_STATUS_2';
      ELSIF lv_instr_type = '3' THEN
          lv_data_class_name := 'PWEL_DAY_STATUS_3';
      ELSE
          lv_data_class_name := 'PWEL_DAY_STATUS';
      END IF;

      lv_parent_object_id := Ecdp_Groups.findParentObjectId(p_local_lock,'operational','WELL',mycur.object_id,p_daytime);

      IF EcDp_Month_lock.localWithinLockedMonth(p_local_lock, lv_parent_object_id, p_daytime) IS NULL THEN

         INSERT INTO pwel_day_status (data_class_name, object_id, daytime, rev_text)
         VALUES (lv_data_class_name, mycur.object_id, p_daytime,lv2_rev_text);

      END IF;
     END LOOP;

    -- update revision text
    IF ecdp_ctrl_property.getSystemProperty('INITIATE_DAY_REV_TEXT', Ecdp_Timestamp.getCurrentSysdate) = 'Y'  THEN
      lv2_rev_text := 'Updated data_class_name due to change in instrumentation type';
    ELSE
      lv2_rev_text := NULL;
    END IF;

     -- fix any records that might have incorrect instrumentation_type due to update of instrumentation_type after instantiation
     -- check for missing instrumentation_type=1
     UPDATE pwel_day_status p1
     SET p1.data_class_name = 'PWEL_DAY_STATUS', rev_text = lv2_rev_text
     WHERE p_daytime = p1.daytime
     AND data_class_name <> 'PWEL_DAY_STATUS'
     AND p1.object_id =
        (SELECT wv.object_id FROM well_version wv
        WHERE wv.object_id = p1.object_id
        AND p_daytime >= wv.daytime AND p_daytime < nvl(wv.end_date,p_daytime+1)
        AND nvl(wv.instrumentation_type,'1') = 1 -- null is treated as instrumentation_type=1
        AND wv.well_type NOT IN ('OB','WS','WP')
        );

     -- check for missing instrumentation_type=2
     UPDATE pwel_day_status p1
     SET p1.data_class_name = 'PWEL_DAY_STATUS_2', rev_text = lv2_rev_text
     WHERE p_daytime = p1.daytime
     AND data_class_name <> 'PWEL_DAY_STATUS_2'
     AND p1.object_id =
        (SELECT wv.object_id FROM well_version wv
        WHERE wv.object_id = p1.object_id
        AND p_daytime >= wv.daytime AND p_daytime < nvl(wv.end_date,p_daytime+1)
        AND nvl(wv.instrumentation_type,'1') = 2 -- null is treated as instrumentation_type=1
        AND wv.well_type NOT IN ('OB','WS','WP')
        );

     -- check for missing instrumentation_type=3
     UPDATE pwel_day_status p1
     SET p1.data_class_name = 'PWEL_DAY_STATUS_3', rev_text = lv2_rev_text
     WHERE p_daytime = p1.daytime
     AND data_class_name <> 'PWEL_DAY_STATUS_3'
     AND p1.object_id =
        (SELECT wv.object_id FROM well_version wv
        WHERE wv.object_id = p1.object_id
        AND p_daytime >= wv.daytime AND p_daytime < nvl(wv.end_date,p_daytime+1)
        AND nvl(wv.instrumentation_type,'1') = 3 -- null is treated as instrumentation_type=1
        AND wv.well_type NOT IN ('OB','WS','WP')
        );

     -- check for incorrect water source well
     UPDATE pwel_day_status p1
     SET p1.data_class_name = 'PWEL_DAY_STATUS_WS', rev_text = lv2_rev_text
     WHERE p_daytime = p1.daytime
     AND data_class_name <> 'PWEL_DAY_STATUS_WS'
     AND p1.object_id =
        (SELECT wv.object_id FROM well_version wv
        WHERE wv.object_id = p1.object_id
        AND p_daytime >= wv.daytime AND p_daytime < nvl(wv.end_date,p_daytime+1)
        AND wv.well_type IN ('WS','WP') -- well_type WS is water source well; WP is water producer
        );

  END i_pwel_day_status;

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : i_iwel_day_status
  ---------------------------------------------------------------------------------------------------
  PROCEDURE i_iwel_day_status(p_daytime DATE, p_local_lock VARCHAR2)
  --</EC-DOC>
  IS
   -- create records for all wells where isGasInjector = 'Y'
   CURSOR cur_get_gi_keys IS
     SELECT w.object_id
      FROM well w, well_version wv
      WHERE wv.isGasInjector='Y' -- wv.well_type IN ('OPGI', 'GPI', 'GI', 'WG')
      AND p_daytime >= wv.daytime AND p_daytime < Nvl(wv.end_date, p_daytime + 1)
      AND w.object_id = wv.object_id
      AND p_daytime < Nvl(w.end_date, p_daytime + 1)
      AND NOT EXISTS
         -- remove wells that are already instantiated
         (SELECT 1
         FROM IWEL_DAY_STATUS ids
         WHERE w.object_id = ids.object_id
         AND ids.inj_type = 'GI'
         AND ids.daytime = p_daytime
         UNION
         -- remove wells that have active_well_status='CLOSED_LT' at the beginning of the new production_day.
         SELECT 1
        FROM IWEL_PERIOD_STATUS ips
        WHERE w.object_id = ips.object_id
        AND ips.time_span = 'EVENT'
        AND ips.inj_type = 'GI'
        AND ips.active_well_status = 'CLOSED_LT'
        AND ips.daytime =
           (SELECT MAX(daytime) from iwel_period_status ips2
           WHERE ips2.object_id = ips.object_id
           AND ips2.time_span = 'EVENT'
           AND ips2.inj_type = 'GI'
           AND ips2.day <= p_daytime) -- its the production_day "day" we must use
        );

   CURSOR cur_get_wi_keys IS
     SELECT w.object_id
      FROM well w, well_version wv
      WHERE wv.isWaterInjector='Y' -- wv.well_type IN ('WI', 'WG')
      AND p_daytime >= wv.daytime AND p_daytime < Nvl(wv.end_date, p_daytime + 1)
      AND w.object_id = wv.object_id
      AND p_daytime < Nvl(w.end_date, p_daytime + 1)
      AND NOT EXISTS
         -- remove wells that are already instantiated
         (SELECT 1
         FROM IWEL_DAY_STATUS ids
         WHERE w.object_id = ids.object_id
         AND ids.inj_type = 'WI'
         AND ids.daytime = p_daytime
         UNION
         -- remove wells that have active_well_status='CLOSED_LT' at the beginning of the new production_day.
         SELECT 1
        FROM IWEL_PERIOD_STATUS ips
        WHERE w.object_id = ips.object_id
        AND ips.time_span = 'EVENT'
        AND ips.inj_type = 'WI'
        AND ips.active_well_status = 'CLOSED_LT'
        AND ips.daytime =
           (SELECT MAX(daytime) from iwel_period_status ips2
           WHERE ips2.object_id = ips.object_id
           AND ips2.time_span = 'EVENT'
           AND ips2.inj_type = 'WI'
           AND ips2.day <= p_daytime) -- its the production_day "day" we must use
        );

   CURSOR cur_get_si_keys IS
     SELECT w.object_id
      FROM well w, well_version wv
      WHERE wv.isSteamInjector='Y' -- wv.well_type IN ('SI', 'OPSI')
      AND p_daytime >= wv.daytime AND p_daytime < Nvl(wv.end_date, p_daytime + 1)
      AND w.object_id = wv.object_id
      AND p_daytime < Nvl(w.end_date, p_daytime + 1)
      AND NOT EXISTS
         -- remove wells that are already instantiated
         (SELECT 1
         FROM IWEL_DAY_STATUS ids
         WHERE w.object_id = ids.object_id
         AND ids.inj_type = 'SI'
         AND ids.daytime = p_daytime
         UNION
         -- remove wells that have active_well_status='CLOSED_LT' at the beginning of the new production_day.
         SELECT 1
        FROM IWEL_PERIOD_STATUS ips
        WHERE w.object_id = ips.object_id
        AND ips.time_span = 'EVENT'
        AND ips.inj_type = 'SI'
        AND ips.active_well_status = 'CLOSED_LT'
        AND ips.daytime =
           (SELECT MAX(daytime) from iwel_period_status ips2
           WHERE ips2.object_id = ips.object_id
           AND ips2.time_span = 'EVENT'
           AND ips2.inj_type = 'SI'
           AND ips2.day <= p_daytime) -- its the production_day "day" we must use
        );

   CURSOR cur_get_ai_keys IS
     SELECT w.object_id
      FROM well w, well_version wv
      WHERE wv.isAirInjector='Y' -- wv.well_type IN ('AI')
      AND p_daytime >= wv.daytime AND p_daytime < Nvl(wv.end_date, p_daytime + 1)
      AND w.object_id = wv.object_id
      AND p_daytime < Nvl(w.end_date, p_daytime + 1)
      AND NOT EXISTS
         -- remove wells that are already instantiated
         (SELECT 1
         FROM IWEL_DAY_STATUS ids
         WHERE w.object_id = ids.object_id
         AND ids.inj_type = 'AI'
         AND ids.daytime = p_daytime
         UNION
         -- remove wells that have active_well_status='CLOSED_LT' at the beginning of the new production_day.
         SELECT 1
        FROM IWEL_PERIOD_STATUS ips
        WHERE w.object_id = ips.object_id
        AND ips.time_span = 'EVENT'
        AND ips.inj_type = 'AI'
        AND ips.active_well_status = 'CLOSED_LT'
        AND ips.daytime =
           (SELECT MAX(daytime) from iwel_period_status ips2
           WHERE ips2.object_id = ips.object_id
           AND ips2.time_span = 'EVENT'
           AND ips2.inj_type = 'AI'
           AND ips2.day <= p_daytime) -- its the production_day "day" we must use
        );

  CURSOR cur_get_ci_keys IS
     SELECT w.object_id
      FROM well w, well_version wv
      WHERE wv.isCO2Injector='Y' -- wv.well_type IN ('CI')
      AND p_daytime >= wv.daytime AND p_daytime < Nvl(wv.end_date, p_daytime + 1)
      AND w.object_id = wv.object_id
      AND p_daytime < Nvl(w.end_date, p_daytime + 1)
      AND NOT EXISTS
         -- remove wells that are already instantiated
         (SELECT 1
         FROM IWEL_DAY_STATUS ids
         WHERE w.object_id = ids.object_id
         AND ids.inj_type = 'CI'
         AND ids.daytime = p_daytime
         UNION
         -- remove wells that have active_well_status='CLOSED_LT' at the beginning of the new production_day.
         SELECT 1
        FROM IWEL_PERIOD_STATUS ips
        WHERE w.object_id = ips.object_id
        AND ips.time_span = 'EVENT'
        AND ips.inj_type = 'CI'
        AND ips.active_well_status = 'CLOSED_LT'
        AND ips.daytime =
           (SELECT MAX(daytime) from iwel_period_status ips2
           WHERE ips2.object_id = ips.object_id
           AND ips2.time_span = 'EVENT'
           AND ips2.inj_type = 'CI'
           AND ips2.day <= p_daytime) -- its the production_day "day" we must use
        );

    lv_parent_object_id VARCHAR2(32);
    lv2_rev_text VARCHAR2(2000);

  BEGIN

    IF ecdp_ctrl_property.getSystemProperty('INITIATE_DAY_REV_TEXT', Ecdp_Timestamp.getCurrentSysdate) = 'Y'  THEN
      lv2_rev_text := 'Created by instantiation process at '||to_char(Ecdp_Timestamp.getCurrentSysdate,'yyyy.mm.dd hh24:mi:ss');
    ELSE
      lv2_rev_text := NULL;
    END IF;

    FOR mycur IN cur_get_gi_keys LOOP

      lv_parent_object_id := Ecdp_Groups.findParentObjectId(p_local_lock,'operational','WELL',mycur.object_id,p_daytime);

      IF EcDp_Month_lock.localWithinLockedMonth(p_local_lock, lv_parent_object_id, p_daytime) IS NULL THEN

         INSERT INTO iwel_day_status (object_id, inj_type, daytime, rev_text)
         VALUES (mycur.object_id, 'GI', p_daytime, lv2_rev_text);

      END IF;

    END LOOP;

    FOR mycur IN cur_get_wi_keys LOOP

      lv_parent_object_id := Ecdp_Groups.findParentObjectId(p_local_lock,'operational','WELL',mycur.object_id,p_daytime);

      IF EcDp_Month_lock.localWithinLockedMonth(p_local_lock, lv_parent_object_id, p_daytime) IS NULL THEN

         INSERT INTO iwel_day_status (object_id, inj_type, daytime, rev_text)
         VALUES  (mycur.object_id, 'WI', p_daytime, lv2_rev_text);

      END IF;
    END LOOP;

    FOR mycur IN cur_get_si_keys LOOP

      lv_parent_object_id := Ecdp_Groups.findParentObjectId(p_local_lock,'operational','WELL',mycur.object_id,p_daytime);

      IF EcDp_Month_lock.localWithinLockedMonth(p_local_lock, lv_parent_object_id, p_daytime) IS NULL THEN

         INSERT INTO iwel_day_status(object_id, inj_type, daytime, rev_text)
         VALUES  (mycur.object_id, 'SI', p_daytime, lv2_rev_text);

      END IF;
    END LOOP;

    FOR mycur IN cur_get_ai_keys LOOP

      lv_parent_object_id := Ecdp_Groups.findParentObjectId(p_local_lock,'operational','WELL',mycur.object_id,p_daytime);

      IF EcDp_Month_lock.localWithinLockedMonth(p_local_lock, lv_parent_object_id, p_daytime) IS NULL THEN

         INSERT INTO iwel_day_status (object_id, inj_type, daytime, rev_text)
         VALUES (mycur.object_id, 'AI', p_daytime, lv2_rev_text);

      END IF;
    END LOOP;

    FOR mycur IN cur_get_ci_keys LOOP

      lv_parent_object_id := Ecdp_Groups.findParentObjectId(p_local_lock,'operational','WELL',mycur.object_id,p_daytime);

      IF EcDp_Month_lock.localWithinLockedMonth(p_local_lock, lv_parent_object_id, p_daytime) IS NULL THEN

         INSERT INTO iwel_day_status (object_id, inj_type, daytime, rev_text)
         VALUES (mycur.object_id, 'CI', p_daytime,lv2_rev_text);
      END IF;
    END LOOP;

    -- update any ghost records that have incorrect INJ_TYPE after configuration changes.
    -- test for 'GI'
    DELETE FROM iwel_day_status p1
    WHERE p_daytime = p1.daytime
    AND p1.inj_type = 'GI'
    AND p1.object_id =
      (SELECT wv.object_id FROM well_version wv
        WHERE wv.object_id = p1.object_id
        AND p_daytime >= wv.daytime AND p_daytime < nvl(wv.end_date,p_daytime+1)
        AND nvl(wv.isGasInjector,'N') = 'N'
      );

    -- test for 'WI'
    DELETE FROM iwel_day_status p1
    WHERE p_daytime = p1.daytime
    AND p1.inj_type = 'WI'
    AND p1.object_id =
      (SELECT wv.object_id FROM well_version wv
        WHERE wv.object_id = p1.object_id
        AND p_daytime >= wv.daytime AND p_daytime < nvl(wv.end_date,p_daytime+1)
        AND nvl(wv.isWaterInjector,'N') = 'N'
      );

    -- test for 'SI'
    DELETE FROM iwel_day_status p1
    WHERE p_daytime = p1.daytime
    AND p1.inj_type = 'SI'
    AND p1.object_id =
      (SELECT wv.object_id FROM well_version wv
        WHERE wv.object_id = p1.object_id
        AND p_daytime >= wv.daytime AND p_daytime < nvl(wv.end_date,p_daytime+1)
        AND nvl(wv.isSteamInjector,'N') = 'N'
      );

    -- test for 'AI'
    DELETE FROM iwel_day_status p1
    WHERE p_daytime = p1.daytime
    AND p1.inj_type = 'AI'
    AND p1.object_id =
      (SELECT wv.object_id FROM well_version wv
        WHERE wv.object_id = p1.object_id
        AND p_daytime >= wv.daytime AND p_daytime < nvl(wv.end_date,p_daytime+1)
        AND nvl(wv.isAirInjector,'N') = 'N'
      );

    -- test for 'CI'
    DELETE FROM iwel_day_status p1
    WHERE p_daytime = p1.daytime
    AND p1.inj_type = 'CI'
    AND p1.object_id =
      (SELECT wv.object_id FROM well_version wv
        WHERE wv.object_id = p1.object_id
        AND p_daytime >= wv.daytime AND p_daytime < nvl(wv.end_date,p_daytime+1)
        AND nvl(wv.isCO2Injector,'N') = 'N'
      );

  END i_iwel_day_status;


  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : i_tank_measurement
  ---------------------------------------------------------------------------------------------------
  PROCEDURE i_tank_measurement(p_daytime DATE, p_local_lock VARCHAR2)
  --</EC-DOC>
   IS
    CURSOR cur_get_keys IS
      SELECT t.object_id, tv.bf_usage
        FROM tank t, tank_version tv
        WHERE p_daytime >= tv.daytime
        AND t.object_id = tv.object_id
        AND p_daytime < Nvl(t.end_date, p_daytime + 1)
        AND p_daytime < Nvl(tv.end_date, p_daytime + 1)
        AND tv.tank_meter_freq not in ('EVENT')
        AND NOT EXISTS
         (SELECT 1
                FROM tank_measurement x
               WHERE t.object_id = x.object_id AND p_daytime = x.daytime
                 AND x.measurement_event_type = 'DAY_CLOSING');

    lv_parent_object_id VARCHAR2(32);
    lv2_rev_text VARCHAR2(2000);

  BEGIN

    IF ecdp_ctrl_property.getSystemProperty('INITIATE_DAY_REV_TEXT', Ecdp_Timestamp.getCurrentSysdate) = 'Y'  THEN
      lv2_rev_text := 'Created by instantiation process at '||to_char(Ecdp_Timestamp.getCurrentSysdate,'yyyy.mm.dd hh24:mi:ss');
    ELSE
      lv2_rev_text := NULL;
    END IF;

    FOR mycur IN cur_get_keys LOOP

      lv_parent_object_id := Ecdp_Groups.findParentObjectId(p_local_lock,'operational','TANK',mycur.object_id,p_daytime);

      IF EcDp_Month_lock.localWithinLockedMonth(p_local_lock, lv_parent_object_id, p_daytime) IS NULL THEN

        IF ( substr(mycur.bf_usage, 1, 7) = 'PO.0005' OR
              substr(mycur.bf_usage, 1, 7) = 'WR.0060' OR
             (mycur.bf_usage = 'PO.0006' AND p_daytime = LAST_DAY(p_daytime)) OR
             substr(mycur.bf_usage, 1, 7) = 'PO.0109' OR
             (mycur.bf_usage = 'PO.0110' AND p_daytime = LAST_DAY(p_daytime))
           ) THEN
            INSERT INTO tank_measurement (object_id, measurement_event_type, daytime, rev_text)
            VALUES  (mycur.object_id, 'DAY_CLOSING', p_daytime, lv2_rev_text);
        END IF;
      END IF;
    END LOOP;
  END i_tank_measurement;


  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : i_chem_tank
  ---------------------------------------------------------------------------------------------------
  PROCEDURE i_chem_tank_period_status(p_daytime DATE, p_local_lock VARCHAR2)
  --</EC-DOC>
   IS
    CURSOR cur_get_keys IS
      SELECT ct.object_id, ctv.tank_meter_freq
      FROM chem_tank ct, chem_tank_version ctv
      WHERE p_daytime >= ctv.daytime
      AND p_daytime < Nvl(ctv.end_date, p_daytime + 1)
      AND (ct.end_date > p_daytime OR ct.end_date IS NULL)
      AND ct.object_id = ctv.object_id
      AND NOT EXISTS
        (SELECT 1 FROM chem_tank_status x
         WHERE x.object_id = ct.object_id AND x.daytime = p_daytime);

    lv_parent_object_id VARCHAR2(32);
    lv2_rev_text VARCHAR2(2000);

  BEGIN

    IF ecdp_ctrl_property.getSystemProperty('INITIATE_DAY_REV_TEXT', Ecdp_Timestamp.getCurrentSysdate) = 'Y'  THEN
      lv2_rev_text := 'Created by instantiation process at '||to_char(Ecdp_Timestamp.getCurrentSysdate,'yyyy.mm.dd hh24:mi:ss');
    ELSE
      lv2_rev_text := NULL;
    END IF;

    FOR mycur IN cur_get_keys LOOP

      lv_parent_object_id := Ecdp_Groups.findParentObjectId(p_local_lock,'operational','CHEM_TANK',mycur.object_id,p_daytime);

      IF EcDp_Month_lock.localWithinLockedMonth(p_local_lock, lv_parent_object_id, p_daytime) IS NULL THEN

         IF (mycur.tank_meter_freq = 'DAY' OR (mycur.tank_meter_freq = 'MONTH' AND p_daytime = LAST_DAY(p_daytime))) THEN
             INSERT INTO chem_tank_status (object_id, daytime, rev_text)
             VALUES (mycur.object_id, p_daytime,lv2_rev_text);
         END IF;
      END IF;
    END LOOP;
  END i_chem_tank_period_status;


  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : i_wbi_day_status
  ---------------------------------------------------------------------------------------------------
  PROCEDURE i_wbi_day_status (p_daytime DATE, p_local_lock VARCHAR2)
  --</EC-DOC>
  IS

  CURSOR cur_get_keys_1 IS
    SELECT wbi.object_id
      FROM well w, well_version wv, webo_bore wb, webo_interval wbi,webo_interval_version wbv
      WHERE p_daytime >= wbi.start_date
      AND p_daytime < Nvl(wbi.end_date, to_date('3045-01-01', 'yyyy-mm-dd'))
      AND wb.OBJECT_ID = wbi.WELL_BORE_ID
      AND w.object_id = wb.WELL_ID
      AND wbv.object_id = wbi.object_id
      AND wbv.daytime <= p_daytime
      AND wbv.daytime = (select max(daytime) from webo_interval_version wbv2 where
                         wbv2.object_id = wbi.object_id
                         and wbv2.daytime <= p_daytime)
      AND wbv.interval_type='DIACS'
      AND NVL(ec_pwel_period_status.active_well_status(w.object_id, p_daytime,'EVENT', '<='), 'OPEN') <> 'CLOSED_LT'
      AND w.object_id = wv.object_id
      AND wv.daytime = (select max(daytime) from well_version wv2 where
                         wv2.object_id = wv.object_id
                         and wv2.daytime <= p_daytime)
      AND wv.instrumentation_type IS NOT NULL
      AND ECDP_SYSTEM.getDependentCode('WELL_CLASS','WELL_TYPE', wv.well_type) IN ('P', 'PI','I')
      AND NOT EXISTS
      (SELECT 1
              FROM WBI_DAY_STATUS x
              WHERE wbi.object_id = x.object_id AND p_daytime = x.daytime);

    lv_parent_object_id VARCHAR2(32);
    lv2_rev_text VARCHAR2(2000);

  BEGIN

    IF ecdp_ctrl_property.getSystemProperty('INITIATE_DAY_REV_TEXT', Ecdp_Timestamp.getCurrentSysdate) = 'Y'  THEN
      lv2_rev_text := 'Created by instantiation process at '||to_char(Ecdp_Timestamp.getCurrentSysdate,'yyyy.mm.dd hh24:mi:ss');
    ELSE
      lv2_rev_text := NULL;
    END IF;

    FOR mycur IN cur_get_keys_1 LOOP

      lv_parent_object_id := Ecdp_Groups.findParentObjectId(p_local_lock,'operational','WELL',mycur.object_id,p_daytime);

      IF EcDp_Month_lock.localWithinLockedMonth(p_local_lock, lv_parent_object_id, p_daytime) IS NULL THEN

        INSERT INTO wbi_day_status (object_id, daytime, rev_text)
        VALUES (mycur.object_id, p_daytime, lv2_rev_text);

      END IF;

    END LOOP;
  END i_wbi_day_status;


  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : i_pipe_day_status
  ---------------------------------------------------------------------------------------------------
  PROCEDURE i_pipe_day_status (p_daytime DATE, p_local_lock VARCHAR2)
  --</EC-DOC>
  IS

  CURSOR cur_get_keys IS
    SELECT p.object_id, pv.PIPE_STATUS_SCR
      FROM pipeline p, pipe_version pv
      WHERE p.object_id = pv.object_id
      AND p_daytime >= pv.daytime
      AND p_daytime < Nvl(pv.end_date, p_daytime + 1)
      AND p_daytime < Nvl(p.end_date, p_daytime + 1)
      AND pv.PIPE_STATUS_SCR = 'Y'
      AND NOT EXISTS
      (SELECT 1
              FROM PIPE_DAY_STATUS x
              WHERE p.object_id = x.object_id AND p_daytime = x.daytime);

    lv_parent_object_id VARCHAR2(32);
    lv2_rev_text VARCHAR2(2000);

  BEGIN

    IF ecdp_ctrl_property.getSystemProperty('INITIATE_DAY_REV_TEXT', Ecdp_Timestamp.getCurrentSysdate) = 'Y'  THEN
      lv2_rev_text := 'Created by instantiation process at '||to_char(Ecdp_Timestamp.getCurrentSysdate,'yyyy.mm.dd hh24:mi:ss');
    ELSE
      lv2_rev_text := NULL;
    END IF;

    FOR mycur IN cur_get_keys LOOP

      lv_parent_object_id := Ecdp_Groups.findParentObjectId(p_local_lock,'operational','PIPELINE',mycur.object_id,p_daytime);

      IF EcDp_Month_lock.localWithinLockedMonth(p_local_lock, lv_parent_object_id, p_daytime) IS NULL THEN

         INSERT INTO pipe_day_status (object_id, daytime, rev_text)
         VALUES (mycur.object_id, p_daytime, lv2_rev_text);

      END IF;
    END LOOP;
  END i_pipe_day_status;


  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : i_object_item_comment
  ---------------------------------------------------------------------------------------------------
  PROCEDURE i_object_item_comment(p_daytime DATE, p_local_lock VARCHAR2)
  --</EC-DOC>
  IS
  TYPE t_object_item_comment IS TABLE OF object_item_comment%ROWTYPE;
  l_data t_object_item_comment;
  lv_parent_object_id VARCHAR2(32);
  ld_nextday DATE;
  lv2_rev_text VARCHAR2(2000);

  CURSOR c_object_item_comment IS
  SELECT *
  FROM object_item_comment t
  WHERE
         production_day = p_daytime-1
         AND nvl(copy_forward_ind, 'N') = 'Y'
         AND t.class_name = 'OBJECT_ITEM_COMMENT'
         and not exists (
             select 1 from object_item_comment x
             where x.object_type=t.object_type
             and x.daytime = t.daytime + 1
             and x.comment_type=t.comment_type
             and x.object_id=t.object_id
             and Nvl(x.comments, 'x')=Nvl(t.comments, 'x')
             and x.class_name = 'OBJECT_ITEM_COMMENT');


  BEGIN

    IF ecdp_ctrl_property.getSystemProperty('INITIATE_DAY_REV_TEXT', Ecdp_Timestamp.getCurrentSysdate) = 'Y'  THEN
      lv2_rev_text := 'Created by instantiation process at '||to_char(Ecdp_Timestamp.getCurrentSysdate,'yyyy.mm.dd hh24:mi:ss');
    ELSE
      lv2_rev_text := NULL;
    END IF;

    FOR mycur IN c_object_item_comment LOOP
        ld_nextday := mycur.daytime + 1;
        lv_parent_object_id := null;

        IF upper(p_local_lock) <> upper(mycur.object_type) THEN
           lv_parent_object_id := Ecdp_Groups.findParentObjectId(p_local_lock,'operational',mycur.object_type,mycur.object_id,p_daytime);
        END IF;

        IF lv_parent_object_id IS NULL THEN
              lv_parent_object_id := mycur.object_id;
        END IF;

        IF Ecdp_Month_Lock.localWithinLockedMonth(p_local_lock, lv_parent_object_id, p_daytime) IS NULL THEN
            INSERT INTO object_item_comment (Object_type,object_id,daytime,class_name,duration,planned_ind,comment_event_type,comment_type,report_ind,comments,comments_2,comments_value,copy_forward_ind,rev_text, value_1,value_2,value_3,value_4,value_5,value_6,value_7,value_8,value_9,value_10,text_1,text_2,text_3,text_4)
            VALUES (mycur.object_type,mycur.object_id,ld_nextday,mycur.class_name,mycur.duration,mycur.planned_ind,mycur.comment_event_type,mycur.comment_type,mycur.report_ind,mycur.comments,mycur.comments_2, mycur.comments_value,mycur.copy_forward_ind,lv2_rev_text, mycur.value_1,mycur.value_2,mycur.value_3,mycur.value_4,mycur.value_5,mycur.value_6,mycur.value_7,mycur.value_8,mycur.value_9,mycur.value_10, mycur.text_1,mycur.text_2,
            mycur.text_3,mycur.text_4);

        END IF;

    END LOOP;

  END i_object_item_comment;


  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : i_daily_deferment_summary
  ---------------------------------------------------------------------------------------------------
  PROCEDURE i_daily_deferment_summary(p_daytime DATE, p_local_lock VARCHAR2)
  --</EC-DOC>
  IS
  -- Check that no record has been instantiated in Daily Deferment Summary for the current sys day
  CURSOR cur_get_keys IS
  SELECT deferment_event_no, defer_level_object_id, daytime,
  initial_def_oil_vol, initial_def_gas_vol, initial_def_water_inj_vol,
  initial_def_gas_inj_vol, initial_def_water_vol, initial_def_cond_vol, initial_def_steam_inj_vol
  FROM def_day_deferment_event ddde
  WHERE p_daytime > ecdp_productionday.getproductionday(null,ddde.defer_level_object_id,ddde.daytime)
  AND (ecdp_productionday.getproductionday(null,ddde.defer_level_object_id,ddde.end_date) >= p_daytime  OR ddde.end_date IS NULL)
  AND NOT EXISTS
  (SELECT 1 FROM def_day_summary_event x
  WHERE x.deferment_event_no = ddde.deferment_event_no AND x.daytime = p_daytime);

  ln_def_oil_vol NUMBER;
  ln_def_gas_vol NUMBER;
  ln_def_water_inj_vol NUMBER;
  ln_def_gas_inj_vol NUMBER;
  ln_def_water_vol NUMBER;
  ln_def_cond_vol NUMBER;
  ln_def_steam_inj_vol NUMBER;
  ln_durationformula NUMBER;
  lv_parent_object_id VARCHAR2(32);
  lv_class_name VARCHAR2(32);
  lv2_rev_text VARCHAR2(2000);

  BEGIN

    IF ecdp_ctrl_property.getSystemProperty('INITIATE_DAY_REV_TEXT', Ecdp_Timestamp.getCurrentSysdate) = 'Y'  THEN
      lv2_rev_text := 'Created by instantiation process at '||to_char(Ecdp_Timestamp.getCurrentSysdate,'yyyy.mm.dd hh24:mi:ss');
    ELSE
      lv2_rev_text := NULL;
    END IF;

    FOR mycur IN cur_get_keys LOOP
      ln_def_oil_vol := nvl(ec_def_day_summary_event.def_oil_vol(mycur.deferment_event_no,p_daytime-1),0);
      ln_def_gas_vol := nvl(ec_def_day_summary_event.def_gas_vol(mycur.deferment_event_no,p_daytime-1),0);
      ln_def_water_inj_vol := nvl(ec_def_day_summary_event.def_water_inj_vol(mycur.deferment_event_no,p_daytime-1),0);
      ln_def_gas_inj_vol := nvl(ec_def_day_summary_event.def_gas_inj_vol(mycur.deferment_event_no,p_daytime-1),0);
      ln_def_water_vol := nvl(ec_def_day_summary_event.def_water_vol(mycur.deferment_event_no,p_daytime-1),0);
      ln_def_cond_vol := nvl(ec_def_day_summary_event.def_cond_vol(mycur.deferment_event_no,p_daytime-1),0);
      ln_def_steam_inj_vol := nvl(ec_def_day_summary_event.def_steam_inj_vol(mycur.deferment_event_no,p_daytime-1),0);

      -- Get duration fraction hours
      ln_durationformula := nvl(ecdp_defer_master_event.calcDuration(mycur.deferment_event_no, p_daytime) / ecdp_defer_master_event.calcDuration(mycur.deferment_event_no , p_daytime-1),0);

      -- New value for deferred volumes
      ln_def_oil_vol := ln_def_oil_vol * ln_durationformula;
      ln_def_gas_vol := ln_def_gas_vol * ln_durationformula;
      ln_def_water_inj_vol := ln_def_water_inj_vol * ln_durationformula;
      ln_def_gas_inj_vol := ln_def_gas_inj_vol * ln_durationformula;
      ln_def_water_vol := ln_def_water_vol * ln_durationformula;
      ln_def_cond_vol := ln_def_cond_vol * ln_durationformula;
      ln_def_steam_inj_vol := ln_def_steam_inj_vol * ln_durationformula;

      -- Insert the new record
      lv_class_name := ecdp_objects.GetObjClassName(mycur.defer_level_object_id);
      lv_parent_object_id := null;

      IF upper(p_local_lock) <> upper(lv_class_name) THEN
          lv_parent_object_id := Ecdp_Groups.findParentObjectId(p_local_lock,'operational',lv_class_name,mycur.defer_level_object_id,p_daytime);
      END IF;

      IF lv_parent_object_id IS NULL THEN
             lv_parent_object_id := mycur.defer_level_object_id;
      END IF;

      IF EcDp_Month_lock.localWithinLockedMonth(p_local_lock, lv_parent_object_id, p_daytime) IS NULL THEN

          INSERT INTO DEF_DAY_SUMMARY_EVENT (defer_level_object_id, daytime, deferment_event_no, def_oil_vol, def_gas_vol, def_water_inj_vol, def_gas_inj_vol, def_water_vol, def_cond_vol, def_steam_inj_vol, rev_text)
          VALUES (mycur. defer_level_object_id, p_daytime, mycur.deferment_event_no, ln_def_oil_vol, ln_def_gas_vol, ln_def_water_inj_vol, ln_def_gas_inj_vol, ln_def_water_vol, ln_def_cond_vol, ln_def_steam_inj_vol, lv2_rev_text);

      END IF;

    END LOOP;
  END i_daily_deferment_summary;

--<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : i_pwel_mth_status
  ---------------------------------------------------------------------------------------------------
   PROCEDURE i_pwel_mth_status (p_daytime DATE, p_local_lock VARCHAR2)
  --</EC-DOC>
   IS
    lv_data_class_name VARCHAR2(32);
    lv_parent_object_id VARCHAR2(32);
    lv2_rev_text VARCHAR2(2000);

    CURSOR cur_get_keys(cp_daytime DATE) IS
    SELECT w.object_id, wv.instrumentation_type, wv.well_type
    FROM well w, well_version wv
    WHERE wv.isProducer='Y'
    AND p_daytime >= wv.daytime AND p_daytime < Nvl(wv.end_date, p_daytime + 1)
    AND p_daytime >= w.start_date AND p_daytime < Nvl(w.end_date, p_daytime + 1)
    AND w.object_id = wv.object_id
    AND (wv.CALC_OIL_MTH_METHOD IS NOT NULL OR wv.CALC_GAS_MTH_METHOD IS NOT NULL OR CALC_WATER_MTH_METHOD IS NOT NULL OR wv.CALC_COND_MTH_METHOD IS NOT NULL)
    AND NOT EXISTS
       (SELECT 1
       FROM PWEL_MTH_STATUS x
       WHERE w.object_id = x.object_id AND cp_daytime = x.daytime
       UNION
       SELECT 1
       FROM PWEL_PERIOD_STATUS pps
       WHERE w.object_id = pps.object_id
       AND pps.time_span='EVENT'
       AND pps.active_well_status='CLOSED_LT'
       AND pps.daytime=
          (SELECT MAX(daytime) from pwel_period_status pps2
          WHERE pps2.object_id=pps.object_id
          AND pps2.time_span='EVENT'
          AND pps2.day <= p_daytime));

  BEGIN
     lv_data_class_name := 'PWEL_MTH_STATUS';

    IF ecdp_ctrl_property.getSystemProperty('INITIATE_DAY_REV_TEXT', Ecdp_Timestamp.getCurrentSysdate) = 'Y'  THEN
      lv2_rev_text := 'Created by instantiation process at '||to_char(Ecdp_Timestamp.getCurrentSysdate,'yyyy.mm.dd hh24:mi:ss');
    ELSE
      lv2_rev_text := NULL;
    END IF;

     FOR mycur IN cur_get_keys(p_daytime) LOOP

        lv_parent_object_id := Ecdp_Groups.findParentObjectId(p_local_lock,'operational','WELL',mycur.object_id,p_daytime);

        IF EcDp_Month_lock.localWithinLockedMonth(p_local_lock, lv_parent_object_id, p_daytime) IS NULL THEN

          INSERT INTO pwel_mth_status(data_class_name, object_id, daytime, rev_text)
          VALUES(lv_data_class_name, mycur.object_id, p_daytime, lv2_rev_text);

        END IF;
     END LOOP;
  END i_pwel_mth_status;

  ---------------------------------------------------------------------------------------------------
  -- Procedure      : i_iwel_mth_status
  ---------------------------------------------------------------------------------------------------
  PROCEDURE i_iwel_mth_status(p_daytime DATE, p_local_lock VARCHAR2)
  --</EC-DOC>
   IS

  lv_parent_object_id VARCHAR2(32);
  lv2_rev_text VARCHAR2(2000);

  CURSOR cur_get_gi_keys(cp_daytime DATE) IS
      SELECT w.object_id, wv.well_type
       FROM well w, well_version wv
       WHERE wv.isgasinjector = 'Y'
       AND p_daytime >= wv.daytime
       AND p_daytime < Nvl(wv.end_date, p_daytime + 1)
       AND w.object_id = wv.object_id
       AND p_daytime < Nvl(w.end_date, p_daytime + 1)
       AND NVL(ec_iwel_period_status.active_well_status(W.OBJECT_ID, P_DAYTIME,'GI','EVENT','<='), 'OPEN') <> 'CLOSED_LT'
       AND wv.calc_inj_method IN ('MEASURED_MTH','MEASURED_MTH_XTPL_DAY')
       AND NOT EXISTS
            (SELECT 1
             FROM iwel_mth_status x
             WHERE w.object_id = x.object_id
             AND x.inj_type = 'GI'
             AND cp_daytime = x.daytime);

  CURSOR cur_get_wi_keys(cp_daytime DATE) IS
      SELECT w.object_id, wv.well_type
        FROM well w, well_version wv
       WHERE wv.iswaterinjector = 'Y'
       AND p_daytime >= wv.daytime
       AND p_daytime < Nvl(wv.end_date, p_daytime + 1)
       AND w.object_id = wv.object_id
       AND p_daytime < Nvl(w.end_date, p_daytime + 1)
       AND NVL(ec_iwel_period_status.active_well_status(W.OBJECT_ID, P_DAYTIME,'WI','EVENT','<='), 'OPEN') <> 'CLOSED_LT'
       AND wv.calc_water_inj_method IN ('MEASURED_MTH','MEASURED_MTH_XTPL_DAY')
       AND NOT EXISTS
         (SELECT 1
             FROM IWEL_MTH_STATUS x
             WHERE w.object_id = x.object_id
             AND x.inj_type = 'WI'
             AND cp_daytime = x.daytime);

  CURSOR cur_get_si_keys(cp_daytime DATE) IS
      SELECT w.object_id, wv.well_type
        FROM well w, well_version wv
       WHERE wv.issteaminjector = 'Y'
       AND p_daytime >= wv.daytime
       AND p_daytime < Nvl(wv.end_date, p_daytime + 1)
       AND w.object_id = wv.object_id
       AND p_daytime < Nvl(w.end_date, p_daytime + 1)
       AND NVL(ec_iwel_period_status.active_well_status(W.OBJECT_ID, P_DAYTIME,'SI','EVENT','<='), 'OPEN') <> 'CLOSED_LT'
       AND (wv.calc_steam_inj_method IN ('MEASURED_MTH','MEASURED_MTH_XTPL_DAY') OR wv.calc_steam_inj_mth_mtd IS NOT NULL)
       AND NOT EXISTS
         (SELECT 1
             FROM IWEL_MTH_STATUS x
             WHERE w.object_id = x.object_id
             AND x.inj_type = 'SI'
             AND cp_daytime = x.daytime);


  BEGIN

    IF ecdp_ctrl_property.getSystemProperty('INITIATE_DAY_REV_TEXT', Ecdp_Timestamp.getCurrentSysdate) = 'Y'  THEN
      lv2_rev_text := 'Created by instantiation process at '||to_char(Ecdp_Timestamp.getCurrentSysdate,'yyyy.mm.dd hh24:mi:ss');
    ELSE
      lv2_rev_text := NULL;
    END IF;

     FOR mycur IN cur_get_gi_keys(p_daytime) LOOP

        lv_parent_object_id := Ecdp_Groups.findParentObjectId(p_local_lock,'operational','WELL',mycur.object_id,p_daytime);

        IF EcDp_Month_lock.localWithinLockedMonth(p_local_lock, lv_parent_object_id, p_daytime) IS NULL THEN

          INSERT INTO iwel_mth_status  (object_id, inj_type, daytime, rev_text)
          VALUES (mycur.object_id, 'GI', p_daytime, lv2_rev_text);

        END IF;
     END LOOP;

      FOR mycur IN cur_get_wi_keys(p_daytime) LOOP

        lv_parent_object_id := Ecdp_Groups.findParentObjectId(p_local_lock,'operational','WELL',mycur.object_id,p_daytime);

        IF EcDp_Month_lock.localWithinLockedMonth(p_local_lock, lv_parent_object_id, p_daytime) IS NULL THEN

          INSERT INTO iwel_mth_status (object_id, inj_type, daytime, rev_text)
          VALUES (mycur.object_id, 'WI', p_daytime, lv2_rev_text);

        END IF;
      END LOOP;

      FOR mycur IN cur_get_si_keys(p_daytime) LOOP

        lv_parent_object_id := Ecdp_Groups.findParentObjectId(p_local_lock,'operational','WELL',mycur.object_id,p_daytime);

        IF EcDp_Month_lock.localWithinLockedMonth(p_local_lock, lv_parent_object_id, p_daytime) IS NULL THEN

          INSERT INTO iwel_mth_status  (object_id, inj_type, daytime, rev_text)
          VALUES (mycur.object_id, 'SI', p_daytime, lv2_rev_text);
        END IF;
     END LOOP;

  END i_iwel_mth_status;


  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure        : i_initiate_day
  -- Description  : The procedure is called from the screen Initiate Day, which has a button that instantiates the product areas that are deployed to the current system respectively.
  --        This information is read from prosty_codes table -> where code = 'INITIATE_DAY'.
  --        Any instantiation configured with this code in prosty_codes from EC_PROD/EC_TRAN/EC_SALE is runned from this screen using this procedure.
  ---------------------------------------------------------------------------------------------------
  PROCEDURE i_initiate_day(p_daytime DATE, p_to_daytime DATE DEFAULT NULL)
  --</EC-DOC>
  IS
  lv_command  VARCHAR2(2000);

  CURSOR c_i_codes IS
    SELECT   code_text
    FROM   prosty_codes
    WHERE   code_type = 'INITIATE_DAY'
    AND  is_active = 'Y'
    ORDER BY sort_order;

  BEGIN
    FOR c_val IN c_i_codes  LOOP
      lv_command := REPLACE(c_val.code_text,'$daytime',ecdp_dynsql.date_to_string(p_daytime));
      lv_command := REPLACE(lv_command,'$to_daytime',ecdp_dynsql.date_to_string(p_to_daytime));

      lv_command := 'begin ' || lv_command || '; end;';
      EXECUTE IMMEDIATE lv_command;
    END LOOP;

  END i_initiate_day;


  ---------------------------------------------------------------------------------------------------
  -- Procedure      : i_strm_day_pc_cp
  ---------------------------------------------------------------------------------------------------
  PROCEDURE i_strm_day_pc_cp(p_daytime DATE, p_local_lock VARCHAR2)
  --</EC-DOC>
   IS
  lv_profit_centre VARCHAR2(32);
  lv_stream VARCHAR2(32);
  lv_component VARCHAR2(16);
  lv_sql VARCHAR2(1000);
  lv_result VARCHAR2(1000);
  lv_phase VARCHAR2(32);
  lv_parent_object_id VARCHAR2(32);
  lv2_rev_text VARCHAR2(2000);

  CURSOR c_strm_pf_conn(cp_daytime DATE) IS
      SELECT a.object_id object_id, a.profit_centre_id profit_centre, b.stream_phase phase
       FROM strm_profit_centre_conn a, strm_version b
       WHERE a.object_id = b.object_id
       AND b.stream_phase in ('OIL','GAS')
       AND cp_daytime >= a.daytime
       AND cp_daytime < Nvl(a.end_date, cp_daytime + 1)
       AND a.object_id in
       (SELECT object_id from strm_set_list
       WHERE stream_set='PO.0074'
       AND from_date <= cp_daytime
       AND cp_daytime < Nvl(end_date, cp_daytime + 1))
       ;

  CURSOR c_pf_co(cp_daytime DATE, cp_profit_centre VARCHAR2, cp_phase VARCHAR2) IS
      SELECT component_no
        FROM comp_set_list
        WHERE component_set = cp_phase
        AND cp_daytime >= daytime
        AND cp_daytime < Nvl(end_date, cp_daytime + 1)
        ;

  BEGIN

     IF ecdp_ctrl_property.getSystemProperty('INITIATE_DAY_REV_TEXT', Ecdp_Timestamp.getCurrentSysdate) = 'Y'  THEN
       lv2_rev_text := 'Created by instantiation process at '||to_char(Ecdp_Timestamp.getCurrentSysdate,'yyyy.mm.dd hh24:mi:ss');
     ELSE
       lv2_rev_text := NULL;
     END IF;

    FOR mycur IN c_strm_pf_conn(p_daytime) LOOP
      lv_profit_centre := mycur.profit_centre;
      lv_stream := mycur.object_id;

      IF mycur.phase='OIL' then
         lv_phase:='STRM_OIL_COMP';
      ELSIF mycur.phase='GAS' then
         lv_phase:='STRM_GAS_COMP';
      END IF;

      lv_parent_object_id := Ecdp_Groups.findParentObjectId(p_local_lock,'operational','STREAM',mycur.object_id,p_daytime);

      IF EcDp_Month_lock.localWithinLockedMonth(p_local_lock, lv_parent_object_id, p_daytime) IS NULL THEN

         FOR mycur2 IN c_pf_co(p_daytime, mycur.profit_centre, lv_phase) LOOP
          lv_component := mycur2.component_no;

          lv_sql := 'INSERT INTO strm_day_pc_cp_status
            (object_id, profit_centre_id, component_no, daytime, rev_text)
          VALUES
            ('''|| lv_stream ||''', '''|| lv_profit_centre ||''', '''|| lv_component ||''', to_date('''||to_char(p_daytime,'yyyy-mm-dd')||''',''yyyy-mm-dd'')' || ','''||lv2_rev_text||''')';

          lv_result := executeStatement(lv_sql);

          END LOOP;
      END IF;
    END LOOP;

  END i_strm_day_pc_cp;


  ---------------------------------------------------------------------------------------------------
  -- Procedure      : i_strm_mth_pc_cp
  ---------------------------------------------------------------------------------------------------
  PROCEDURE i_strm_mth_pc_cp(p_daytime DATE, p_local_lock VARCHAR2)
  --</EC-DOC>
   IS
  lv_profit_centre VARCHAR2(32);
  lv_stream VARCHAR2(32);
  lv_component VARCHAR2(16);
  lv_sql VARCHAR2(1000);
  lv_result VARCHAR2(1000);
  lv_phase VARCHAR2(32);
  lv_parent_object_id VARCHAR2(32);
  lv2_rev_text VARCHAR2(2000);

  CURSOR c_strm_pf_conn(cp_daytime DATE) IS
      SELECT a.object_id object_id, a.profit_centre_id profit_centre, b.stream_phase phase
       FROM strm_profit_centre_conn a, strm_version b
       WHERE a.object_id = b.object_id
       AND b.stream_phase in ('OIL','GAS')
       AND cp_daytime >= a.daytime
       AND cp_daytime < Nvl(a.end_date, cp_daytime + 1)
       AND a.object_id in
       (SELECT object_id from strm_set_list
       WHERE stream_set='PO.0075'
       AND from_date <= cp_daytime
       AND cp_daytime < Nvl(end_date, cp_daytime + 1))
       ;

  CURSOR c_pf_co(cp_daytime DATE, cp_profit_centre VARCHAR2, cp_phase VARCHAR2) IS
      SELECT component_no
        FROM comp_set_list
        WHERE component_set = cp_phase
        AND cp_daytime >= daytime
        AND cp_daytime < Nvl(end_date, cp_daytime + 1)
        ;

  BEGIN

     IF ecdp_ctrl_property.getSystemProperty('INITIATE_DAY_REV_TEXT', Ecdp_Timestamp.getCurrentSysdate) = 'Y'  THEN
       lv2_rev_text := 'Created by instantiation process at '||to_char(Ecdp_Timestamp.getCurrentSysdate,'yyyy.mm.dd hh24:mi:ss');
     ELSE
       lv2_rev_text := NULL;
     END IF;

    FOR mycur IN c_strm_pf_conn(p_daytime) LOOP
      lv_profit_centre := mycur.profit_centre;
      lv_stream := mycur.object_id;

      IF mycur.phase='OIL' then
         lv_phase:='STRM_OIL_COMP';
      ELSIF mycur.phase='GAS' then
         lv_phase:='STRM_GAS_COMP';
      END IF;

      lv_parent_object_id := Ecdp_Groups.findParentObjectId(p_local_lock,'operational','STREAM',mycur.object_id,p_daytime);

      IF EcDp_Month_lock.localWithinLockedMonth(p_local_lock, lv_parent_object_id, p_daytime) IS NULL THEN

         FOR mycur2 IN c_pf_co(p_daytime, mycur.profit_centre, lv_phase) LOOP
          lv_component := mycur2.component_no;

          lv_sql := 'INSERT INTO strm_mth_pc_cp_status
            (object_id, profit_centre_id, component_no, daytime, rev_text)
          VALUES
            ('''|| lv_stream ||''', '''|| lv_profit_centre ||''', '''|| lv_component ||''', to_date('''||to_char(p_daytime,'yyyy-mm-dd')||''',''yyyy-mm-dd'')' || ','''||lv2_rev_text||''')';

          lv_result := executeStatement(lv_sql);

      END LOOP;

      END IF;
    END LOOP;

  END i_strm_mth_pc_cp;


  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : i_object_item_mth_comment
  ---------------------------------------------------------------------------------------------------
  PROCEDURE i_object_item_mth_comment(p_daytime DATE, p_local_lock VARCHAR2)
--</EC-DOC>
  IS
    ld_lastmonth DATE;
    TYPE t_object_item_comment IS TABLE OF object_item_comment%ROWTYPE;
    l_data t_object_item_comment;
    lv_parent_object_id VARCHAR2(32);
    lv2_rev_text VARCHAR2(2000);

    CURSOR c_object_item_comment(cp_daytime DATE) IS
    SELECT *
    FROM object_item_comment t
    WHERE
         t.class_name ='OBJECT_ITEM_MTH_COMMENT'
         AND t.daytime = ADD_MONTHS(cp_daytime, -1)
         AND nvl(copy_forward_ind, 'N') = 'Y'
         and not exists (
             select 1 from object_item_comment x
             where x.object_type=t.object_type
             and x.daytime = cp_daytime
             and x.comment_type=t.comment_type
             and x.object_id=t.object_id
             and x.class_name ='OBJECT_ITEM_MTH_COMMENT'
             and Nvl(x.comments, 'x')=Nvl(t.comments, 'x'));


  BEGIN

    IF ecdp_ctrl_property.getSystemProperty('INITIATE_DAY_REV_TEXT', Ecdp_Timestamp.getCurrentSysdate) = 'Y'  THEN
      lv2_rev_text := 'Created by instantiation process at '||to_char(Ecdp_Timestamp.getCurrentSysdate,'yyyy.mm.dd hh24:mi:ss');
    ELSE
      lv2_rev_text := NULL;
    END IF;

    ld_lastmonth:= ADD_MONTHS(p_daytime,-1);

    For mycur IN c_object_item_comment(p_daytime) LOOP
        lv_parent_object_id := null;

        IF upper(p_local_lock) <> upper(mycur.object_type) THEN
           lv_parent_object_id := Ecdp_Groups.findParentObjectId(p_local_lock,'operational',mycur.object_type,mycur.object_id,p_daytime);
        END IF;

        IF lv_parent_object_id IS NULL THEN
              lv_parent_object_id := mycur.object_id;
        END IF;

         IF Ecdp_Month_Lock.localWithinLockedMonth(p_local_lock, lv_parent_object_id, p_daytime) IS NULL THEN
            INSERT INTO object_item_comment (Object_type,object_id,daytime,class_name,duration,planned_ind,comment_event_type,comment_type,report_ind,comments,comments_2,comments_value,copy_forward_ind,rev_text,value_1,value_2,value_3,value_4,value_5,value_6,value_7,value_8,value_9,value_10,text_1,text_2,text_3,text_4)
            VALUES (mycur.object_type,mycur.object_id,p_daytime,mycur.class_name,mycur.duration,mycur.planned_ind,mycur.comment_event_type,mycur.comment_type,mycur.report_ind,mycur.comments,mycur.comments_2, mycur.comments_value,mycur.copy_forward_ind,lv2_rev_text, mycur.value_1,mycur.value_2,mycur.value_3,mycur.value_4,mycur.value_5,mycur.value_6,mycur.value_7,mycur.value_8,mycur.value_9,mycur.value_10, mycur.text_1,mycur.text_2,mycur.text_3,mycur.text_4);

         END IF;
     END LOOP;
  END i_object_item_mth_comment;

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : i_chem_inj_point_status
  ---------------------------------------------------------------------------------------------------
  PROCEDURE i_chem_inj_point_status(p_daytime DATE, p_local_lock VARCHAR2)
  --</EC-DOC>
   IS
    CURSOR cur_get_keys IS
      SELECT object_id
       FROM chem_inj_point_version cpv
       WHERE p_daytime >= cpv.daytime
       AND p_daytime < Nvl(cpv.end_date, p_daytime + 1)
       AND NOT EXISTS (
         SELECT 1 FROM chem_inj_point_status x
         WHERE x.object_id = cpv.object_id
         AND x.daytime = p_daytime
         AND x.time_span = 'DAY');

    lv_parent_object_id VARCHAR2(32);
    lv2_rev_text VARCHAR2(2000);

  BEGIN
    IF ecdp_ctrl_property.getSystemProperty('INITIATE_DAY_REV_TEXT', Ecdp_Timestamp.getCurrentSysdate) = 'Y'  THEN
      lv2_rev_text := 'Created by instantiation process at '||to_char(Ecdp_Timestamp.getCurrentSysdate,'yyyy.mm.dd hh24:mi:ss');
    ELSE
      lv2_rev_text := NULL;
    END IF;

    FOR mycur IN cur_get_keys LOOP

        lv_parent_object_id := null;

        lv_parent_object_id := Ecdp_Groups.findParentObjectId(p_local_lock,'operational','CHEM_INJ_POINT',mycur.object_id,p_daytime);

        IF EcDp_Month_lock.localWithinLockedMonth(p_local_lock, lv_parent_object_id, p_daytime) IS NULL THEN

           INSERT INTO chem_inj_point_status  (object_id, daytime, time_span, rev_text)
           VALUES (mycur.object_id, p_daytime, 'DAY', lv2_rev_text);
        END IF;

    END LOOP;
  END i_chem_inj_point_status;

---------------------------------------------------------------------------------------------------
-- Procedure      : i_strm_day_asset_data
---------------------------------------------------------------------------------------------------
PROCEDURE i_strm_day_asset_data(p_daytime DATE)
--</EC-DOC>
IS
-- Check that no record has been instantiated in strm_day_asset_data for the current sys day


   CURSOR c_strm_day_asset_data IS
      SELECT *
        FROM strm_day_asset_data t
        WHERE p_daytime >=  ecdp_productionday.getproductionday(null,t.asset_id,t.start_daytime)
        AND t.end_daytime IS NULL
        AND t.class_name != 'STRM_DAY_ROU_REL_SUM'
        AND t.daytime =( select max(daytime) from strm_day_asset_data t2
        where t2.object_id = t.object_id
        AND t2.class_name = t.class_name
        AND t2.asset_id = t.asset_id
        AND t2.start_daytime = t.start_daytime
        AND t2.daytime < p_daytime)
        AND NOT exists
       (select 1
                from strm_day_asset_data x
                where x.object_id = t.object_id
                and x.daytime = p_daytime
                and x.start_daytime = t.start_daytime
                and x.class_name = t.class_name);

    -- just to insert STRM_DAY_ROU_REL_SUM
   CURSOR cur_get_rel_sum_records IS
     SELECT sds.object_id, ecdp_objects.GetObjClassName(sds.object_id) asset_type
       FROM strm_day_stream sds , strm_set_list ssl
       WHERE sds.object_id = ssl.object_id
       AND ssl.stream_set = 'PO.0086_VF_R'
       AND sds.daytime = p_daytime
       AND NOT exists
       (select 1
                from strm_day_asset_data x
                where x.object_id = sds.object_id
                and x.daytime = p_daytime
                and x.start_daytime = p_daytime
                and x.class_name ='STRM_DAY_ROU_REL_SUM'
                and x.asset_id = sds.object_id);

   CURSOR c_StrmDayAssetWellData_PD0020(cp_object_id VARCHAR2,cp_daytime DATE,cp_asset_id VARCHAR2, cp_start_daytime DATE) IS
      SELECT *
        FROM strm_day_asset_well_data w
        WHERE w.object_id = cp_object_id
        AND w.class_name = 'STRM_DAY_NR_EQPM'
        AND w.asset_id = cp_asset_id
        AND w.daytime = cp_daytime
        AND w.start_daytime = cp_start_daytime
        AND ecdp_well.isWellPhaseActiveStatus(w.well_id,null,'OPEN',p_daytime) = 'Y'
        AND w.well_id NOT IN (SELECT object_id FROM deferment_event wed
          WHERE (wed.end_date > p_daytime OR wed.end_date is null)
          AND wed.object_type ='WELL'
          AND wed.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD'))
        AND NOT exists
          (select 1
                from strm_day_asset_well_data x
                where x.object_id = w.object_id
                and x.daytime =p_daytime
                and x.start_daytime = cp_start_daytime
                and x.class_name = w.class_name
                and x.asset_id = cp_asset_id);

 lv2_deferment_version VARCHAR2(32);
 lv2_rev_text VARCHAR2(2000);

BEGIN

    lv2_deferment_version := ec_ctrl_system_attribute.attribute_text(nvl(p_daytime, Ecdp_Timestamp.getCurrentSysdate), 'DEFERMENT_VERSION', '<=');

    IF ecdp_ctrl_property.getSystemProperty('INITIATE_DAY_REV_TEXT', Ecdp_Timestamp.getCurrentSysdate) = 'Y'  THEN
      lv2_rev_text := 'Created by instantiation process at '||to_char(Ecdp_Timestamp.getCurrentSysdate,'yyyy.mm.dd hh24:mi:ss');
    ELSE
      lv2_rev_text := NULL;
    END IF;

    FOR mycur IN c_strm_day_asset_data LOOP
      INSERT INTO strm_day_asset_data
        (object_id, class_name, daytime, asset_id, start_daytime, asset_type, release_method, total_num_occur, rou_rel_override, non_rou_rel_override, daily_release, permit, rel_reason_code, comments, h2s, so2, downstream_sales, downstream_fuel, rev_text)
      VALUES
        (mycur.object_id, mycur.class_name, p_daytime, mycur.asset_id,mycur.start_daytime,mycur.asset_type, mycur.release_method, mycur. total_num_occur, mycur.rou_rel_override, mycur.non_rou_rel_override, mycur.daily_release, mycur.permit, mycur.rel_reason_code, mycur.comments, mycur.h2s, mycur.so2, mycur.downstream_sales, mycur.downstream_fuel, lv2_rev_text);

    IF lv2_deferment_version = 'PD.0020' OR lv2_deferment_version IS NULL THEN
      IF mycur.class_name = 'STRM_DAY_NR_EQPM' THEN
         FOR mycurwell IN c_StrmDayAssetWellData_PD0020(mycur.object_id,mycur.daytime,mycur.asset_id,mycur.start_daytime)
         LOOP

            INSERT INTO strm_day_asset_well_data (object_id, class_name, daytime, asset_id, well_id, start_daytime, rev_text)
            VALUES (mycur.object_id, mycur.class_name, p_daytime, mycurwell.asset_id, mycurwell.well_id, mycurwell.start_daytime,lv2_rev_text);

         END LOOP;
      END IF;
    END IF;
    END LOOP;

    FOR mycur_rel_sum IN cur_get_rel_sum_records
    LOOP
      INSERT INTO strm_day_asset_data (object_id, class_name, daytime, asset_id, start_daytime, asset_type, rev_text)
      VALUES  (mycur_rel_sum.object_id, 'STRM_DAY_ROU_REL_SUM', p_daytime,mycur_rel_sum.object_id,p_daytime,mycur_rel_sum.asset_type,lv2_rev_text);
    END LOOP;


END i_strm_day_asset_data;


---------------------------------------------------------------------------------------------------
-- Procedure      : i_defer_loss_accounting
---------------------------------------------------------------------------------------------------
PROCEDURE i_defer_loss_accounting(p_daytime DATE)
--</EC-DOC>
IS

    CURSOR cur_events (cp_daytime DATE) IS
      select e.event_no, e.class_name
        from defer_loss_acc_event e
       where e.daytime < cp_daytime
         and nvl(e.end_date, cp_daytime+1) > cp_daytime;

BEGIN
  FOR curEvents IN cur_events (p_daytime) LOOP
    IF curEvents.class_name = 'DEFER_LOSS_FCTY_EVENT' THEN
      ecdp_defer_loss_accounting.populateFctyStreamRecord(curEvents.event_no, p_daytime);
    ELSIF  curEvents.class_name = 'DEFER_LOSS_FIELD_EVENT' THEN
      ecdp_defer_loss_accounting.populateFldStreamRecord(curEvents.event_no, p_daytime);
    END IF;
  END LOOP;

END i_defer_loss_accounting;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : i_defer_loss_acc_fcty
---------------------------------------------------------------------------------------------------
PROCEDURE i_defer_loss_acc_fcty(p_daytime DATE)
--</EC-DOC>
IS

    CURSOR cur_get_keys IS
      SELECT distinct sv.op_fcty_class_1_id -- default DAY
        FROM stream s, strm_version sv, strm_set_list ssl
       WHERE (sv.strm_meter_freq = 'DAY' or NVL(sv.aggregate_flag,'')='Y')
             AND sv.stream_type = 'M' -- only measured streams
             AND s.object_id = sv.object_id -- join s, sv
             AND p_daytime >= sv.daytime
             AND p_daytime < Nvl(sv.end_date, p_daytime + 1)
             AND p_daytime < Nvl(s.end_date, p_daytime + 1)
             AND ssl.stream_set = 'PO.0107'
             AND ssl.object_id = sv.object_id
             AND sv.op_fcty_class_1_id is NOT NULL
             AND NOT EXISTS
       (SELECT 1
                FROM defer_loss_acc_event x
               WHERE sv.op_fcty_class_1_id  = x.object_id AND p_daytime = x.daytime AND type IS NULL);

    lv_parent_object_id VARCHAR2(32);
    lv2_rev_text VARCHAR2(2000);

  BEGIN

    IF ecdp_ctrl_property.getSystemProperty('INITIATE_DAY_REV_TEXT', Ecdp_Timestamp.getCurrentSysdate) = 'Y'  THEN
      lv2_rev_text := 'Created by instantiation process at '||to_char(Ecdp_Timestamp.getCurrentSysdate,'yyyy.mm.dd hh24:mi:ss');
    ELSE
      lv2_rev_text := NULL;
    END IF;

    FOR mycur IN cur_get_keys LOOP
      INSERT INTO defer_loss_acc_event(object_id, daytime, end_date,class_name, rev_text)
      VALUES (mycur.op_fcty_class_1_id, p_daytime,p_daytime+1 , 'DEFER_LOSS_FCTY_EVENT', lv2_rev_text);
    END LOOP;
  END i_defer_loss_acc_fcty;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : i_fcty_asset_analysis_daily
---------------------------------------------------------------------------------------------------
PROCEDURE i_fcty_asset_analysis_daily(p_daytime DATE)
--</EC-DOC>
IS

    CURSOR cur_get_analysis_item IS
      SELECT DISTINCT FCTY_OBJECT_ID, START_DATE, END_DATE, ASSET_TYPE, ASSET_ID, ANALYSIS_ITEM
        FROM FCTY_ANALYSIS_ITEM a
        WHERE a.analysis_freq = 'DAILY'
        AND a.START_DATE <= p_daytime
        AND nvl(a.END_DATE, p_daytime+1) > p_daytime
        AND NOT EXISTS
       (SELECT 1
                FROM FCTY_ASSET_ANALYSIS x
               WHERE a.FCTY_OBJECT_ID = x.FCTY_OBJECT_ID AND p_daytime = x.daytime AND a.ASSET_ID=x.ASSET_ID AND a.ANALYSIS_ITEM=x.ANALYSIS_ITEM);
    lv2_rev_text VARCHAR2(2000);

  BEGIN

    IF ecdp_ctrl_property.getSystemProperty('INITIATE_DAY_REV_TEXT', Ecdp_Timestamp.getCurrentSysdate) = 'Y'  THEN
      lv2_rev_text := 'Created by instantiation process for analysis with daily frequency at '||to_char(Ecdp_Timestamp.getCurrentSysdate,'yyyy.mm.dd hh24:mi:ss');
    ELSE
      lv2_rev_text := NULL;
    END IF;

    FOR mycur IN cur_get_analysis_item LOOP
      INSERT INTO FCTY_ASSET_ANALYSIS(FCTY_OBJECT_ID, daytime, due_date, ASSET_TYPE, ASSET_ID, ANALYSIS_ITEM, rev_text)
      VALUES (mycur.FCTY_OBJECT_ID, p_daytime, p_daytime+1, mycur.ASSET_TYPE, mycur.ASSET_ID, mycur.ANALYSIS_ITEM, lv2_rev_text);
    END LOOP;
  END i_fcty_asset_analysis_daily;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : i_fcty_asset_analysis_monthly
---------------------------------------------------------------------------------------------------
PROCEDURE i_fcty_asset_analysis_monthly(p_daytime DATE)
--</EC-DOC>
IS

    ld_duemonth DATE;
    lv2_rev_text VARCHAR2(2000);

    CURSOR cur_get_analysis_item IS
      SELECT DISTINCT FCTY_OBJECT_ID, START_DATE, END_DATE, ASSET_TYPE, ASSET_ID, ANALYSIS_ITEM
        FROM FCTY_ANALYSIS_ITEM a
        WHERE a.analysis_freq = 'MONTHLY'
        AND a.START_DATE <= p_daytime
        AND nvl(a.END_DATE, p_daytime+1) > p_daytime
        AND NOT EXISTS
       (SELECT 1
                FROM FCTY_ASSET_ANALYSIS x
               WHERE a.FCTY_OBJECT_ID = x.FCTY_OBJECT_ID AND p_daytime = x.daytime AND a.ASSET_ID=x.ASSET_ID AND a.ANALYSIS_ITEM=x.ANALYSIS_ITEM);

  BEGIN

    IF ecdp_ctrl_property.getSystemProperty('INITIATE_DAY_REV_TEXT', Ecdp_Timestamp.getCurrentSysdate) = 'Y'  THEN
      lv2_rev_text := 'Created by instantiation process for analysis with monthly frequency at '||to_char(Ecdp_Timestamp.getCurrentSysdate,'yyyy.mm.dd hh24:mi:ss');
    ELSE
      lv2_rev_text := NULL;
    END IF;

    ld_duemonth:= ADD_MONTHS(p_daytime,1);

    FOR mycur IN cur_get_analysis_item LOOP
      INSERT INTO FCTY_ASSET_ANALYSIS (FCTY_OBJECT_ID, daytime, due_date, ASSET_TYPE, ASSET_ID, ANALYSIS_ITEM, rev_text)
      VALUES (mycur.FCTY_OBJECT_ID, p_daytime, ld_duemonth, mycur.ASSET_TYPE, mycur.ASSET_ID, mycur.ANALYSIS_ITEM,lv2_rev_text);
    END LOOP;
  END i_fcty_asset_analysis_monthly;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : i_fcty_asset_analysis_weekly
---------------------------------------------------------------------------------------------------
PROCEDURE i_fcty_asset_analysis_weekly(p_daytime DATE)
--</EC-DOC>
IS

    ld_dueweek DATE;
    lv2_rev_text VARCHAR2(2000);

    CURSOR cur_get_analysis_item IS
      SELECT DISTINCT FCTY_OBJECT_ID, START_DATE, END_DATE, ASSET_TYPE, ASSET_ID, ANALYSIS_ITEM
        FROM FCTY_ANALYSIS_ITEM a
        WHERE a.analysis_freq = 'WEEKLY'
        AND a.START_DATE <= p_daytime
        AND nvl(a.END_DATE, p_daytime+1) > p_daytime
        AND NOT EXISTS
       (SELECT 1
                FROM FCTY_ASSET_ANALYSIS x
               WHERE a.FCTY_OBJECT_ID = x.FCTY_OBJECT_ID AND p_daytime = x.daytime AND a.ASSET_ID=x.ASSET_ID AND a.ANALYSIS_ITEM=x.ANALYSIS_ITEM);

  BEGIN
    IF ecdp_ctrl_property.getSystemProperty('INITIATE_DAY_REV_TEXT', Ecdp_Timestamp.getCurrentSysdate) = 'Y'  THEN
      lv2_rev_text := 'Created by instantiation process for analysis with weekly frequency at '||to_char(Ecdp_Timestamp.getCurrentSysdate,'yyyy.mm.dd hh24:mi:ss');
    ELSE
      lv2_rev_text := NULL;
    END IF;

    ld_dueweek:= p_daytime+7;

    FOR mycur IN cur_get_analysis_item LOOP
      INSERT INTO FCTY_ASSET_ANALYSIS (FCTY_OBJECT_ID, daytime, due_date, ASSET_TYPE, ASSET_ID, ANALYSIS_ITEM, rev_text)
      VALUES (mycur.FCTY_OBJECT_ID, p_daytime, ld_dueweek, mycur.ASSET_TYPE, mycur.ASSET_ID, mycur.ANALYSIS_ITEM, lv2_rev_text);
    END LOOP;
  END i_fcty_asset_analysis_weekly;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : i_deferment_day
---------------------------------------------------------------------------------------------------
PROCEDURE i_deferment_day(p_daytime DATE, p_local_lock VARCHAR2)
--</EC-DOC>
IS
  CURSOR cur_deferment_day IS
  SELECT a.EVENT_NO, a.OBJECT_ID, a.DAYTIME
  FROM DEFERMENT_EVENT a
  WHERE a.CLASS_NAME = 'DEFERMENT_EVENT'
  AND a.DAYTIME <= p_daytime AND END_DATE IS NULL
  AND NOT EXISTS
  (SELECT 1
   FROM DEFERMENT_DAY b
   WHERE b.EVENT_NO = a.EVENT_NO
   AND b.OBJECT_ID = a.OBJECT_ID
   AND b.DAYTIME = p_daytime);

  lv2_rev_text VARCHAR2(2000);
  lr_dD DEFERMENT_DAY%ROWTYPE;
  lv_parent_object_id VARCHAR2(32);
  lv2_object_type VARCHAR2(24);
  ln_EVENT_NO NUMBER;

BEGIN
 IF ecdp_ctrl_property.getSystemProperty('INITIATE_DAY_REV_TEXT', Ecdp_Timestamp.getCurrentSysdate) = 'Y'  THEN
    lv2_rev_text := 'Created by instantiation process at '||to_char(Ecdp_Timestamp.getCurrentSysdate,'yyyy.mm.dd hh24:mi:ss');
  ELSE
    lv2_rev_text := NULL;
  END IF;
  FOR mycur IN cur_deferment_day LOOP
   IF NVL(ln_EVENT_NO,0) <> mycur.EVENT_NO THEN
      lr_dD := ec_deferment_day.row_by_pk(mycur.EVENT_NO, mycur.OBJECT_ID, p_daytime, '<');
      ln_EVENT_NO := mycur.EVENT_NO;
    END IF;
    lv_parent_object_id := null;
    lv2_object_type := ecdp_objects.getobjclassname(mycur.object_id);
    IF upper(p_local_lock) <> upper(lv2_object_type) THEN
      lv_parent_object_id := Ecdp_Groups.findParentObjectId(p_local_lock,'',lv2_object_type,mycur.object_id,p_daytime);
    END IF;
    IF lv_parent_object_id IS NULL THEN
      lv_parent_object_id := mycur.object_id;
    END IF;
    IF Ecdp_Month_Lock.localWithinLockedMonth(p_local_lock, lv_parent_object_id, p_daytime) IS NULL THEN
      INSERT INTO DEFERMENT_DAY (EVENT_NO, OBJECT_ID, DAYTIME, OIL_LOSS_VOLUME, GAS_LOSS_VOLUME, COND_LOSS_VOLUME, WATER_LOSS_VOLUME, WATER_INJ_LOSS_VOLUME,
                                STEAM_INJ_LOSS_VOLUME, GAS_INJ_LOSS_VOLUME, DILUENT_LOSS_VOLUME, GAS_LIFT_LOSS_VOLUME, OIL_LOSS_MASS, GAS_LOSS_MASS, COND_LOSS_MASS,
                                WATER_LOSS_MASS, WATER_INJ_LOSS_MASS, STEAM_INJ_LOSS_MASS, GAS_INJ_LOSS_MASS, GAS_LIFT_LOSS_MASS, COMMENTS,
                                VALUE_1, VALUE_2, VALUE_3, VALUE_4, VALUE_5, VALUE_6, VALUE_7, VALUE_8, VALUE_9, VALUE_10,
                                TEXT_1, TEXT_2, TEXT_3, TEXT_4, TEXT_5, TEXT_6, TEXT_7, TEXT_8, TEXT_9, TEXT_10,
                                DATE_1, DATE_2, DATE_3, DATE_4, DATE_5, REV_TEXT, CLASS_NAME)
      VALUES (mycur.EVENT_NO, mycur.OBJECT_ID, p_daytime, lr_dD.OIL_LOSS_VOLUME, lr_dD.GAS_LOSS_VOLUME, lr_dD.COND_LOSS_VOLUME, lr_dD.WATER_LOSS_VOLUME, lr_dD.WATER_INJ_LOSS_VOLUME,
              lr_dD.STEAM_INJ_LOSS_VOLUME, lr_dD.GAS_INJ_LOSS_VOLUME, lr_dD.DILUENT_LOSS_VOLUME, lr_dD.GAS_LIFT_LOSS_VOLUME, lr_dD.OIL_LOSS_MASS, lr_dD.GAS_LOSS_MASS, lr_dD.COND_LOSS_MASS,
              lr_dD.WATER_LOSS_MASS, lr_dD.WATER_INJ_LOSS_MASS, lr_dD.STEAM_INJ_LOSS_MASS, lr_dD.GAS_INJ_LOSS_MASS, lr_dD.GAS_LIFT_LOSS_MASS, lr_dD.COMMENTS,
              lr_dD.VALUE_1, lr_dD.VALUE_2, lr_dD.VALUE_3, lr_dD.VALUE_4, lr_dD.VALUE_5, lr_dD.VALUE_6, lr_dD.VALUE_7, lr_dD.VALUE_8, lr_dD.VALUE_9, lr_dD.VALUE_10,
              lr_dD.TEXT_1, lr_dD.TEXT_2, lr_dD.TEXT_3, lr_dD.TEXT_4, lr_dD.TEXT_5, lr_dD.TEXT_6, lr_dD.TEXT_7, lr_dD.TEXT_8, lr_dD.TEXT_9, lr_dD.TEXT_10,
              lr_dD.DATE_1, lr_dD.DATE_2, lr_dD.DATE_3, lr_dD.DATE_4, lr_dD.DATE_5, lv2_rev_text, 'DEFERMENT_DAY');
    END IF;
  END LOOP;
END i_deferment_day;

END Ec_Bs_Instantiate;