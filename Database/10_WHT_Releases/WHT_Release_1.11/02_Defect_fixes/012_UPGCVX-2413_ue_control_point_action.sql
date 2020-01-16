CREATE OR REPLACE PACKAGE BODY UE_CONTROL_POINT_ACTION IS
/******************************************************************************
** Package        :  Ue_Control_Point_Action, body part
**
** $Revision: 1.4 $
**
** Purpose        :  Control Point Action user exit package.
**
** Documentation  :  www.energy-components.com
**
** Created        :  24.09.2007    Hanne Austad
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- ------------------------------------------------------------------------------
** 30-May-2018 WVIC  Item 127816: ISWR02579: Modified executeAction to find the highlighted parcel
**                      for commingled cargoes during cargo doc generation
********************************************************************/

TYPE ParameterM_t IS TABLE OF VARCHAR2(2000) INDEX BY VARCHAR2(2000);

--
-- Response codes recognised by the Java action that calls Ue_ControlPointEction.executeAction
--
ln_OK      NUMBER:=0;
ln_WARNING NUMBER:=1;
ln_ERROR   NUMBER:=2;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : exampleImpl
-- Description    : Example implementation of User Exit Control Point Action procedure.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE exampleImpl(
          p_params   IN  ParameterM_t
,         p_response_code OUT NUMBER
,         p_response_text OUT VARCHAR2
)
IS
  CURSOR c_task_details(p_class_name VARCHAR2) IS
    SELECT d.*
    FROM   task t
    ,      task_detail d
    WHERE  t.task_no=d.task_no
    AND    t.task_type='APPROVAL'
    AND    d.status='O'
    AND    Nvl(d.last_updated_by, d.created_by)!=EcDp_Context.getAppUser;
  ln_record_count NUMBER:=0;
  lv2_query       VARCHAR2(2000);
BEGIN
  -- Assume the following parameters
  --
  --    action_name='auto-approve'
  --    class_name=<class_name>
  --    where-condition=<where condition that must be satisfied>
  --
  IF p_params.EXISTS('action_name')=FALSE OR p_params('action_name') IS NULL THEN
    p_response_code := ln_ERROR;
    p_response_text := 'Missing action_name parameter value.';
    RETURN;
  END IF;
  IF p_params.EXISTS('class_name')=FALSE OR p_params('class_name') IS NULL THEN
    p_response_code := ln_ERROR;
    p_response_text := 'Missing class_name parameter value.';
    RETURN;
  END IF;
  IF p_params.EXISTS('where_condition')=FALSE OR p_params('where_condition') IS NULL THEN
    p_response_code := ln_ERROR;
    p_response_text := 'Missing where_condition parameter value.';
    RETURN;
  END IF;

  IF p_params('action_name')='auto-approve' THEN
       FOR cur IN c_task_details(p_params('class_name')) LOOP
          lv2_query :=
                  'SELECT 1 FROM '||ecdp_classmeta.getClassViewName(cur.class_name)||' '||
                  'WHERE rec_id='''||cur.record_ref_id||''' AND '||p_params('where_condition');
          EXECUTE IMMEDIATE lv2_query;
          IF SQL%ROWCOUNT>0 THEN
            ln_record_count := ln_record_count + 1;
            EcDp_Approval.Accept(cur.record_ref_id, p_params('comments'));
          END IF;
       END LOOP;
       p_response_code := ln_OK;
       p_response_text := 'Auto-approved '||ln_record_count||' records of class '||p_params('class_name');
       RETURN;
  END IF;
  p_response_code := ln_WARNING;
  p_response_text := 'Unknown action_name parameter value.';
END exampleImpl;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : executeAction
-- Description    : User Exit Control Point Action procedure.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE executeAction(
          p_param_names   IN  Varchar2000L_t
,         p_param_values  IN  Varchar2000L_t
,         p_response_code OUT NUMBER
,         p_response_text OUT VARCHAR2
)
IS
  lt_params ParameterM_t;
  v_switch_value VARCHAR2(2000);
  v_parcel_no NUMBER;
  v_cargo_no NUMBER;
  v_lifting_account VARCHAR2(2000);
  v_TEMP VARCHAR2(2000);
  v_count NUMBER;
  v_End_date DATE;
  v_Start_date DATE;
  v_num NUMBER := 1; -- Item 127816


BEGIN
  -- Require that input arrays are parallel
  IF p_param_names.COUNT != p_param_values.COUNT THEN
     Raise_Application_Error(-20120,'Parameter name and value arrays have different sizes.');
  END IF;

 EcDp_DynSql.writetemptext('CTRL_PT', 'START');
  -- Move parameters to a "handier" structure
  FOR i IN 1..p_param_names.COUNT LOOP
     lt_params(p_param_names(i)):=p_param_values(i);
     EcDp_DynSql.writetemptext('CTRL_PT', p_param_names(i) || '[' || p_param_values(i) || ']');
  END LOOP;
  IF lt_params.EXISTS('screentemplate') = TRUE THEN
    v_switch_value := lt_params('screentemplate');
  ELSE
    NULL;--EcDp_DynSql.writetemptext('CTRL_PT', 'No parameter named RetrieveArgs.TreeviewScreenLabel');
  END IF;

  IF lt_params.EXISTS('PROCESS_ID') = TRUE THEN
    v_switch_value := lt_params('PROCESS_ID'); --'DAY_UPG_VER'
    v_End_date := TO_DATE(lt_params('END_DATE'),'YYYY-MM-DD"T"HH24:MI:SS');
    IF lt_params.EXISTS('START_DATE') = TRUE THEN
        v_Start_date := TO_DATE(lt_params('START_DATE'),'YYYY-MM-DD"T"HH24:MI:SS');
    ELSE
        v_Start_date := v_End_date;
    END IF;
  ELSE
    NULL;--EcDp_DynSql.writetemptext('CTRL_PT', 'No parameter named RetrieveArgs.TreeviewScreenLabel');
  END IF;

  -- Initialise returns
  p_response_code := ln_OK;
  p_response_text := NULL;

  EcDp_DynSql.writetemptext('CTRL_PT', 'v_switch_value='||v_switch_value);

  -- Item 127816 Begin
/*  IF v_switch_value = 'Cargo Document' THEN
    v_lifting_account := lt_params('RetrieveArgs.search.LIFTING_ACCOUNT');
    --Example result = 'Chevron (TAPL) LNG \ Chevron (CAPL) LNG'
    SELECT (LENGTH(v_lifting_account) - LENGTH(REPLACE(v_lifting_account,'\','')) + 1 ) INTO v_count FROM DUAL;
    FOR C IN 1..v_count LOOP
        v_TEMP:= 'obj.' || C ||'.datavalue.1';
        IF lt_params.EXISTS(v_TEMP) = TRUE THEN
            v_parcel_no := lt_params(v_TEMP);
            EXIT ;
        END IF;
    END LOOP;
  END IF;
*/
/*
   --Each object represents a parcel. Loop until a parcel is found(For combined liftings)
    WHILE (lt_params.EXISTS('obj.' || v_num || '.datavalue.1') = FALSE AND v_num < 100 ) LOOP
        v_num := v_num + 1;
    END LOOP;

    v_parcel_no := lt_params('obj.' || v_num || '.datavalue.1');
   -- Item 127816 End
*/   
   v_parcel_no := lt_params('RetrieveArgs.nom_docs.PARCEL_NO');

  ---------------------------------
  -- Implement user exit code here!
  ---------------------------------
  --exampleImpl(lt_params, p_response_code, p_response_text);
  --TLXT: 2015-MAY-11: WORK ITEM: 96524
  IF v_switch_value = '/com.ec.tran.to.screens/cargo_document' AND v_parcel_no IS NOT NULL THEN
    --v_parcel_no := lt_params('obj.1.datavalue.1');
    v_cargo_no := lt_params('RetrieveArgs.search.CARGO_NO');
--106784: added by tlxt: to include EDP logic. allow to be generated if it is Ready for Harbour
    IF ecbp_cargo_status.geteccargostatus(ec_cargo_transport.cargo_status(ec_storage_lift_nomination.cargo_no(v_parcel_no))) IN ('R') THEN
      EcDp_DynSql.writetemptext('CTRL_PT', 'Executing prepareCargoDocMessage ' || v_parcel_no);
      UE_CT_CARGO_INFO.prepareCargoDocMessage(v_parcel_no);
      EcDp_DynSql.writetemptext('CTRL_PT', 'Finished prepareCargoDocMessage with p_response_text = ' || p_response_text);
    END IF;
--end 106784
    IF ecbp_cargo_status.geteccargostatus(ec_cargo_transport.cargo_status(ec_storage_lift_nomination.cargo_no(v_parcel_no))) IN ('A','C') THEN
--106784: only CArgo Doc SET = ALL or NULL will transfer the value to PA
		IF NVL(lt_params('SaveArgs.CARGO_DOC_SET'),'NULL' )IN ('ALL','NULL') THEN
		  EcDp_DynSql.writetemptext('CTRL_PT', 'Executing transferCargoAnalysis ' || v_parcel_no);
		  UE_CT_CARGO_INFO.transferCargoAnalysis(v_parcel_no, p_response_Code, p_response_text);
		  EcDp_DynSql.writetemptext('CTRL_PT', 'Finished transferCargoAnalysis with p_response_text = ' || p_response_text);

		  EcDp_DynSql.writetemptext('CTRL_PT', 'Executing transferCargoLoaded ' || v_parcel_no);
		  UE_CT_CARGO_INFO.transferCargoLoaded(v_parcel_no, p_response_Code, p_response_text);
		  EcDp_DynSql.writetemptext('CTRL_PT', 'Finished transferCargoLoaded with p_response_text = ' || p_response_text);
		END IF;
--end 106784
	  EcDp_DynSql.writetemptext('CTRL_PT', 'Executing prepareCargoDocMessage ' || v_parcel_no);
	  UE_CT_CARGO_INFO.prepareCargoDocMessage(v_parcel_no);
	  EcDp_DynSql.writetemptext('CTRL_PT', 'Finished prepareCargoDocMessage with p_response_text = ' || p_response_text);
    END IF;
  END IF;

  IF v_switch_value IN ('DAY_UPG_VER','MTH_APV_P') THEN
    UE_CT_MSG_INTERFACE.SendReadyMessage('CC_PROD_ACTUAL', 'PROD_ACTUALS', v_Start_date, v_End_date, -1, NULL, NULL);
  END IF;



END executeAction;

END Ue_Control_Point_Action;
/
