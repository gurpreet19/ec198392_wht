create or replace PACKAGE ue_ct_dg_interface AS
/****************************************************************
** Package        :  UE_CT_CPP_NQM
**
** $Revision: 1.0 $
**
** Purpose        :  This package supports Chevron's Domgas Nomination Process
**
**
**
** Documentation  :  TBD
**
** Created  : Jan 2015  Evert-Jan Stoel, Tieto, Perth
**
** Modification history:
**
** Date        Whom       Change description:
** --------    ---------  ------------------------------------------
** Jan-2017    evee       Initial version for Wheatstone Domgas implementation
** 25-05-2018  wonggkai   item_127808. new executeAction() to called function within package.
*****************************************************************/

  PROCEDURE ApproveWeeklyFPS(p_from_date DATE
                           , p_to_date   DATE
                           , p_user      VARCHAR2);

  PROCEDURE ApproveWeeklyDGWNE(p_from_date DATE
                             , p_to_date   DATE
                             , p_user      VARCHAR2);

  PROCEDURE ApproveDailyFPS(p_from_date DATE
                          , p_to_date   DATE
                          , p_user      VARCHAR2);

  PROCEDURE ApproveDailyData(p_from_date DATE
                          , p_to_date   DATE
                          , p_user      VARCHAR2);

  PROCEDURE ApproveIntraDayFPS(p_from_date DATE
                             , p_to_date   DATE
                             , p_user      VARCHAR2);

  PROCEDURE ApproveIntraDay(p_from_date DATE
                          , p_to_date   DATE
                          , p_user      VARCHAR2);

  PROCEDURE ApprovePostgasDay(p_from_date DATE
                            , p_to_date   DATE
                            , p_user      VARCHAR2);

  PROCEDURE setWeeklyStatus(p_from_date     DATE
                          , p_to_date       DATE
                          , p_status_code prosty_codes.code%type
                          , p_prev_status prosty_codes.code%type
                          , p_message_identifier  VARCHAR2
                          , p_user        VARCHAR2);

  PROCEDURE setDayAheadStatus(p_daytime             DATE
                            , p_status_code         prosty_codes.code%type
                            , p_prev_status         prosty_codes.code%type
                            , p_message_identifier  VARCHAR2
                            , p_user                VARCHAR2);

  PROCEDURE setIntraDayStatus(p_daytime     DATE
                            , p_status_code prosty_codes.code%type
                            , p_prev_status prosty_codes.code%type
                            , p_message_identifier  VARCHAR2
                            , p_user        VARCHAR2);

  PROCEDURE setPostGasDayStatus(p_daytime               DATE
                              , p_message_identifier    VARCHAR2
                              , p_compare_status        VARCHAR2
                              , p_status                VARCHAR
                              , p_user                  VARCHAR2);

  FUNCTION getCodeTextFromAny(p_code VARCHAR2) RETURN VARCHAR2;
  FUNCTION executeStatement(p_statement varchar2) RETURN VARCHAR2;
  FUNCTION getAccountStatus(p_object_id cntracc_per_dim2_alloc.object_id%type
                          , p_daytime   cntracc_per_dim2_alloc.daytime%type) return VARCHAR2;

  FUNCTION getMsgSequenceNumber(p_prefix VARCHAR2) RETURN VARCHAR2;

  PROCEDURE executeAction(p_func VARCHAR2
                            , p_from_date DATE
                            , p_to_date   DATE
                            , p_user      VARCHAR2);
  

END ue_ct_dg_interface;
/
create or replace PACKAGE BODY ue_ct_dg_interface AS
/****************************************************************
** Package        :  ue_ct_dg_interface
**
** $Revision: 1.0 $
**
** Purpose        :  This package supports Chevron's Domgas Nomination Process
**
**
**
** Documentation  :  TBD
**
** Created  : Jan 2015  Evert-Jan Stoel, Tieto, Perth
**
** Modification history:
**
** Date        Whom       Change description:
** --------    ---------  ------------------------------------------
** Jan-2017    evee       Initial version for Wheatstone implementation
** 25-05-2018  wonggkai   item_127808. new executeAction() to called function within package.
** 02-05-2019  kulkagay   Added function executeStatement
*****************************************************************/

/****************************************************************
** Function/Proc  :  getSumDGJVPNominationVOL
**
** Purpose        :  Update the approval status (not the record_status!) to Approved
** Used by        :  java class FPSApproveAction. Triggered from the screen Daily gas Sales Forecast by context menu.
**
** Date      Whom      Change description:
** --------  --------- ------------------------------------------
** Jan-2017  evee      Initial version for Wheatstone Domgas implementation
**
*****************************************************************/
  PROCEDURE ApproveWeeklyFPS(p_from_date DATE
                           , p_to_date   DATE
                           , p_user      VARCHAR2) IS

    ld_from_date DATE;

  BEGIN

    ld_from_date := p_from_date + 6;

    update cntr_day_dp_forecast
       set text_2 = 'DG_DATA_FPS_APPROVED'
         , rev_text = 'The weekly fps is approved on ' || to_char(sysdate,'yyyy-mm-dd hh24:mi') || ' by ' || p_user
         , last_updated_by = p_user
     where daytime between p_from_date and p_to_date;

  END ApproveWeeklyFPS;

/****************************************************************
** Function/Proc  :  getSumDGJVPNominationVOL
**
** Purpose        :  Update the approval status (not the record_status!) to Approved
** Used by        :  java class DGApproveAction. Triggered from the screen Daily gas Sales Forecast by context menu.
**
** Date      Whom      Change description:
** --------  --------- ------------------------------------------
** Jan-2017  evee      Initial version for Wheatstone Domgas implementation
**
*****************************************************************/
  PROCEDURE ApproveWeeklyDGWNE(p_from_date DATE
                             , p_to_date   DATE
                             , p_user      VARCHAR2) IS
  BEGIN

    update cntr_day_dp_forecast
       set text_2 = 'DG_DATA_WEEK_APP'
         , rev_text = 'The weekly DGWNE is approved on ' || to_char(sysdate,'yyyy-mm-dd hh24:mi') || ' by ' || p_user
         , last_updated_by = p_user
     where daytime between p_from_date and p_to_date;

  END ApproveWeeklyDGWNE;

/****************************************************************
** Function/Proc  :  getSumDGJVPNominationVOL
**
** Purpose        :  Update the approval status (not the record_status!) to Approved
** Used by        :  java class DGApproveAction. Triggered from the screen Daily gas Sales Forecast by context menu.
**
** Date      Whom      Change description:
** --------  --------- ------------------------------------------
** Jan-2017  evee      Initial version for Wheatstone Domgas implementation
**
*****************************************************************/
  PROCEDURE ApproveDailyFPS(p_from_date DATE
                          , p_to_date   DATE
                          , p_user      VARCHAR2) IS

  BEGIN

    update cntr_day_dp_nom
       set text_2 = 'DG_DATA_FPS_APPROVED'
         , rev_text = 'The Daily FPS is approved on ' || to_char(sysdate,'yyyy-mm-dd hh24:mi') || ' by ' || p_user
         , last_updated_by = p_user
     where daytime = p_from_date;

  END ApproveDailyFPS;


/****************************************************************
** Function/Proc  :  getSumDGJVPNominationVOL
**
** Purpose        :  Update the approval status (not the record_status!) to Approved
** Used by        :  java class DGApproveAction. Triggered from the screen Daily gas Sales Forecast by context menu.
**
** Date      Whom      Change description:
** --------  --------- ------------------------------------------
** Jan-2017  evee      Initial version for Wheatstone Domgas implementation
**
*****************************************************************/
  PROCEDURE ApproveDailyData(p_from_date DATE
                          , p_to_date   DATE
                          , p_user      VARCHAR2) IS
  BEGIN

    update cntr_day_dp_nom
       set text_2 = 'DG_DATA_DAY_APP'
         , record_status = 'A'
         , rev_text = 'The Day Ahead is approved on ' || to_char(sysdate,'yyyy-mm-dd hh24:mi') || ' by ' || p_user
         , last_updated_by = p_user
     where daytime = p_from_date;

    update cntracc_per_dim2_alloc
       set record_status = 'A'
         , rev_text = 'The Day Ahead data is approved on ' || to_char(sysdate,'yyyy-mm-dd hh24:mi') || ' by ' || p_user
         , last_updated_by = p_user
     where daytime = p_from_date
       and dim1_key = 'DAY_AHEAD'
       and class_name = 'CT_SCTR_ACC_DAY_DP_ALLOC';

  END ApproveDailyData;

/****************************************************************
** Function/Proc  :  ApproveIntraDayFPS
**
** Purpose        :  Update the approval status (not the record_status!) to Approved
** Used by        :  java class DGApproveAction. Triggered from the screen Daily Re-nomination by context menu.
**
** Date      Whom      Change description:
** --------  --------- ------------------------------------------
** Jan-2017  evee      Initial version for Wheatstone Domgas implementation
**
*****************************************************************/
  PROCEDURE ApproveIntraDayFPS(p_from_date DATE
                             , p_to_date   DATE
                             , p_user      VARCHAR2) IS
  BEGIN

    update cntr_dp_event
       set text_3 = 'DG_DATA_FPS_APPROVED'
         , rev_text = 'The revised FPS is approved on ' || to_char(sysdate,'yyyy-mm-dd hh24:mi') || ' by ' || p_user
         , last_updated_by = p_user
     where date_3 = p_from_date
       and text_3 = 'DG_DATA_SUB_DAY_PROV'
       and text_7 = 'RFPS'
       and event_type = 'RENOMINATION';

  END ApproveIntraDayFPS;

/****************************************************************
** Function/Proc  :  ApproveIntraDay
**
** Purpose        :  Update the approval status and the record_status to Approved
** Used by        :  java class DGApproveAction. Triggered from the screen Daily Re-nomination by context menu.
**
** Date      Whom      Change description:
** --------  --------- ------------------------------------------
** Jan-2017  evee      Initial version for Wheatstone Domgas implementation
**
*****************************************************************/
  PROCEDURE ApproveIntraDay(p_from_date DATE
                          , p_to_date   DATE
                          , p_user      VARCHAR2) IS
  BEGIN

    update cntr_dp_event
       set date_2 = sysdate
         , text_3 = 'DG_DATA_SUB_DAY_APP'
         , record_status = 'A'
         , rev_text = 'The Intra Day data is approved on ' || to_char(sysdate,'yyyy-mm-dd hh24:mi') || ' by ' || p_user
         , last_updated_by = p_user
     where date_3 = p_from_date
       and text_3 = 'DG_DATA_SUB_DAY_PROV'
       and event_type = 'RENOMINATION';

     update cntracc_per_dim2_alloc
       set record_status = 'A'
         , rev_text = 'The Intra Day data is approved on ' || to_char(sysdate,'yyyy-mm-dd hh24:mi') || ' by ' || p_user
         , last_updated_by = p_user
     where daytime = p_from_date
       and dim1_key IN ('INTRA', 'PREGAS')
       and record_status != 'A'
       and class_name = 'CT_SCTR_ACC_DAY_DP_ALLOC';

  END ApproveIntraDay;

/****************************************************************
** Function/Proc  :  ApprovePostgasDay
**
** Purpose        :  Update the approval status (not the record_status!) to Approved
** Used by        :  java class DGApproveAction. Triggered from the screen Daily Re-nomination by context menu.
**
** Date      Whom      Change description:
** --------  --------- ------------------------------------------
** Jan-2017  evee      Initial version for Wheatstone Domgas implementation
**
*****************************************************************/
  PROCEDURE ApprovePostgasDay(p_from_date DATE
                            , p_to_date   DATE
                            , p_user      VARCHAR2) IS
  BEGIN

    update cntracc_per_dim2_alloc
       set text_1 = 'DG_DATA_POST_APP'
         , record_status = 'A'
         , rev_text = 'The Post Gasday data is approved on ' || to_char(sysdate,'yyyy-mm-dd hh24:mi') || ' by ' || p_user
         , last_updated_by = p_user
     where daytime = p_from_date
       and dim1_key = 'POST_GAS'
       and account_code = 'DG_DATA_STATUS'
       and class_name = 'CT_SCTR_ACC_DAY_DP_ALLOC';

    update cntracc_per_dim2_alloc
       set record_status = 'A'
         , rev_text = 'The Post Gasday data is approved on ' || to_char(sysdate,'yyyy-mm-dd hh24:mi') || ' by ' || p_user
         , last_updated_by = p_user
     where daytime = p_from_date
       and (dim1_key = 'POST_GAS' or dim1_key = 'DAY_AHEAD')
       and record_status = 'P'
       and account_code != 'DG_DATA_STATUS'
       and class_name = 'CT_SCTR_ACC_DAY_DP_ALLOC';

  END ApprovePostgasDay;

/****************************************************************
** Function/Proc  :  setWeeklyStatus
**
** Purpose        :  Update the approval status (not the record_status!) to Sent
**                   Requires a diffrent set up because this is not called from a context menu but from the java class itself
** Used by        :  java class FPSDayAhead and FinalDayAhead
**
** Date      Whom      Change description:
** --------  --------- ------------------------------------------
** Feb-2017  evee      Initial version for Wheatstone Domgas implementation
**
*****************************************************************/
  PROCEDURE setWeeklyStatus(p_from_date     DATE
                          , p_to_date       DATE
                          , p_status_code prosty_codes.code%type
                          , p_prev_status prosty_codes.code%type
                          , p_message_identifier  VARCHAR2
                          , p_user        VARCHAR2) IS
  BEGIN

    update cntr_day_dp_forecast
       set text_2 = p_status_code
         , rev_text = 'The Weekly data is approved on ' || to_char(sysdate,'yyyy-mm-dd hh24:mi') || ' by ' || p_user || ' for message ' || p_message_identifier
          , last_updated_by = p_user
     where daytime between p_from_date and p_to_date
       and text_2 = p_prev_status;

  END setWeeklyStatus;

/****************************************************************
** Function/Proc  :  setDailyStatus
**
** Purpose        :  Update the approval status (not the record_status!) to Sent
**                   Requires a diffrent set up because this is not called from a context menu but from the java class itself
** Used by        :  java class FPSDayAhead and FinalDayAhead
**
** Date      Whom      Change description:
** --------  --------- ------------------------------------------
** Feb-2017  evee      Initial version for Wheatstone Domgas implementation
**
*****************************************************************/
  PROCEDURE setDayAheadStatus(p_daytime             DATE
                             , p_status_code        prosty_codes.code%type
                             , p_prev_status        prosty_codes.code%type
                             , p_message_identifier VARCHAR2
                             , p_user               VARCHAR2) IS
  BEGIN

    update cntr_day_dp_nom
       set text_2 = p_status_code
         , rev_text = 'The Day Ahead data is approved on ' || to_char(sysdate,'yyyy-mm-dd hh24:mi') || ' by ' || p_user || ' for message ' || p_message_identifier
         , last_updated_by = p_user
     where daytime = p_daytime
       and text_2 = p_prev_status;

  END setDayAheadStatus;

/****************************************************************
** Function/Proc  :  setIntraDayStatus
**
** Purpose        :  Update the approval status (not the record_status!) to Sent
**                   Requires a diffrent set up because this is not called from a context menu but from the java class itself
** Used by        :  java class FPSIntraday and FinalIntraDayGenerator
**
** Date      Whom      Change description:
** --------  --------- ------------------------------------------
** Feb-2017  evee      Initial version for Wheatstone Domgas implementation
**
*****************************************************************/
  PROCEDURE setIntraDayStatus(p_daytime     DATE
                             , p_status_code prosty_codes.code%type
                             , p_prev_status prosty_codes.code%type
                             , p_message_identifier  VARCHAR2
                             , p_user        VARCHAR2) IS
  BEGIN

    update cntr_dp_event
       set text_3 = p_status_code
         , rev_text = 'The IntraDay data is approved on ' || to_char(sysdate,'yyyy-mm-dd hh24:mi') || ' by ' || p_user || ' for message ' || p_message_identifier
         , last_updated_by = p_user
     where date_3 = p_daytime
       and text_3 = p_prev_status
       and event_type = 'RENOMINATION';

  END setIntraDayStatus;

/****************************************************************
** Function/Proc  :  setDQStatus
**
** Purpose        :  Update the approval status (not the record_status!) to Sent
**                   Only for the contract account data status
** Used by        :  java class FPSIntraday and FinalIntraDayGenerator
**
** Date      Whom      Change description:
** --------  --------- ------------------------------------------
** Feb-2017  evee      Initial version for Wheatstone Domgas implementation
**
*****************************************************************/
  PROCEDURE setPostGasDayStatus(p_daytime               DATE
                              , p_message_identifier    VARCHAR2
                              , p_compare_status        VARCHAR2
                              , p_status                VARCHAR
                              , p_user                  VARCHAR2) IS
  BEGIN

    update cntracc_per_dim2_alloc
       set text_1 = case when text_1 = p_compare_status then 'DG_DATA_POST_DF_SENT' else p_status end
       -- text_1 = case when text_1 = 'DG_DATA_POST_FCM_SENT' then 'DG_DATA_POST_DF_SENT' else 'DG_DATA_POST_DDQ_SENT' end
         , rev_text = 'Delivered Quantities sent by ' || p_user || ' with message ' || p_message_identifier
     where daytime = p_daytime
       and dim1_key = 'POST_GAS'
       and account_code = 'DG_DATA_STATUS';

  END setPostGasDayStatus;

/****************************************************************
** Function/Proc  :  getCodeTextFromAny
**
** Purpose        :  helper function for contract account result screen: in case the given parameter ==  a ec code it should return the code text rather than the code.
**                   if not equal than the given code is returned.
** Used by        :  context menu on contract account result screen.
**
** Date      Whom      Change description:
** --------  --------- ------------------------------------------
** FEB-2017  evee      Initial version for Wheatstone Domgas implementation
**
*****************************************************************/
  FUNCTION getCodeTextFromAny(p_code VARCHAR2) RETURN VARCHAR2
  IS

    lv_code PROSTY_CODES.CODE_TEXT%type;

  BEGIN

    lv_code := EC_PROSTY_CODES.CODE_TEXT(p_code, 'DG_DATA_STAGE');

    if lv_code is not null then
        return lv_code;
    end if;

    return p_code;

  END;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : executeStatement                                                             --
-- Description    : Executes a dynamic SQL statement. No binding                                 --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION executeStatement(p_statement varchar2) RETURN VARCHAR2
--</EC-DOC>
IS

li_cursor	integer;
li_ret_val	integer;
lv2_err_string VARCHAR2(2000);

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

/****************************************************************
** Function/Proc  :  getAccountStatus
**
** Purpose        :  helper function to retrieve the post gas day data status for the contract account result screen
** Used by        :  context menu on contract account result screen.
**
** Date      Whom      Change description:
** --------  --------- ------------------------------------------
** FEB-2017  evee      Initial version for Wheatstone Domgas implementation
**
*****************************************************************/
  FUNCTION getAccountStatus(p_object_id cntracc_per_dim2_alloc.object_id%type
                          , p_daytime   cntracc_per_dim2_alloc.daytime%type) RETURN VARCHAR2 IS

    lv_status cntracc_per_dim2_alloc.text_1%type;

  BEGIN

    select text_1 into lv_status
      from cntracc_per_dim2_alloc
     where class_name = 'CT_SCTR_ACC_DAY_DP_ALLOC'
       and dim1_key = 'POST_GAS'
       and account_code = 'DG_DATA_STATUS'
       and object_id = p_object_id
       and daytime = p_daytime;

     return lv_status;

    EXCEPTION
        when NO_DATA_FOUND then
            return null;

  END;

/****************************************************************
** Function/Proc  :  getMsgSequenceNumber
**
** Purpose        :  Return the sequence number that is used as the message identifier
**
** Used by        :  all outbound message to the portal. Called from the java code.
**
** Date      Whom      Change description:
** --------  --------- ------------------------------------------
** May-2017  FDSM      Initial version for Wheatstone implementation
**
*****************************************************************/
FUNCTION getMsgSequenceNumber(p_prefix VARCHAR2) RETURN VARCHAR2
IS

  l_sql varchar2(2000);
  l_val number;

BEGIN


    l_sql := 'select DG_MSG_SEQ_' || p_prefix || '.nextval from dual';

    execute immediate l_sql into l_val;

    return p_prefix || '-' || LPAD(l_val, 4, '0') ;

END getMsgSequenceNumber;

/****************************************************************
** Function/Proc  :  executeAction
**
** Purpose        :  get function name and execute function within called by Java.
** Used by        :  java class DGApproveAction. Triggered from the screen Daily gas Sales Forecast by context menu.
**
** Date        Whom       Change description:
** --------    ---------  ------------------------------------------
** 25-05-2018  wonggkai   item_127808. new executeAction() to called function within package.
**
*****************************************************************/
  PROCEDURE executeAction(p_func VARCHAR2
                            , p_from_date DATE
                            , p_to_date   DATE
                          , p_user      VARCHAR2) IS

  lv_sql        VARCHAR2(4000);
  lv_result    VARCHAR2(4000);

  BEGIN

    lv_sql := 'call ue_ct_dg_interface.' || p_func || '(''' || p_from_date || ''',''' || p_to_date || ''',''' || p_user || ''')' ;

    lv_result := executeStatement(lv_sql);
   
  END executeAction;

END ue_ct_dg_interface;
/