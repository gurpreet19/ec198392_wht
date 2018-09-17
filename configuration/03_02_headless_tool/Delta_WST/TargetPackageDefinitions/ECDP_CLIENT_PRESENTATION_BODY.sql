CREATE OR REPLACE PACKAGE BODY EcDp_Client_Presentation IS
/****************************************************************
** Package        :  EcDp_Client_Presentation
**
** $Revision: 1.25 $
**
** Purpose        :  Functions used to Deal with presentation
**
** Documentation  :
**
** Created        :  16.11.2005  Micah Rupersburg
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
** 18-11-2005	rupermic	added getDuration
** 22-11-2005 	mot       	Added popup dependency parameter to GetPresentationSyntax
** 23-11-2005   DN              Replaced ampersand with and in function GetDuration.
** 27-12-2005 sunderoa          Added new table object popup
** 02-10-2006 Lau       TI4094 - Added PARAMETER_TYPE = 'USER_EXIT'
** 12-07-2007 siah      ECPD-6136 - Added getComponentFullNameLabel
** 27-12-2011 Devendran      ECPD-18092 - Added condition 'Basic Type' in GetNameByType function
******************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetName
-- Description    : Returns either the Same value, EC_CODE TEXT or the name attribute for an object
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: ec_prosty_codes.CODE_TEXT, ecdp_objects.GetObjName
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

FUNCTION GetName(parameter_type VARCHAR2, parameter_sub_type   VARCHAR2, parameter_value   VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
v_tableret VARCHAR2(1024);
BEGIN
IF(PARAMETER_VALUE IS NULL OR PARAMETER_TYPE IS NULL OR PARAMETER_SUB_TYPE IS NULL) THEN
	RETURN NULL;
END IF;

IF(PARAMETER_TYPE = 'EC_OBJECT_TYPE') THEN
	RETURN ecdp_objects.GetObjName(PARAMETER_VALUE, ecdp_date_time.getCurrentSysdate);
END IF;

IF(PARAMETER_TYPE = 'EC_CODE_TYPE') THEN
	RETURN ec_prosty_codes.code_text(PARAMETER_VALUE, PARAMETER_SUB_TYPE);
END IF;

IF(PARAMETER_TYPE = 'EC_TABLE_TYPE') THEN
	v_tableret := ECDP_DYNSQL.execute_singlerow_varchar2(
		 concat(concat(concat(concat('select EC_', parameter_sub_type), '.NAME('''), parameter_value), ''') from dual')
	);
	IF(v_tableret IS NOT null) THEN
		RETURN v_tableret;
	END IF;
END IF;

IF(PARAMETER_TYPE = 'USER_EXIT') THEN
	 RETURN Ue_Report_Parameter.name(parameter_sub_type, parameter_value);
END IF;

RETURN PARAMETER_VALUE;

END GetName;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetNameByType
-- Description    : Returns the "nice name" for the given type
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: ec_class.label
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

FUNCTION GetNameByType(parameter_type VARCHAR2, parameter_sub_type VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS

BEGIN
IF(PARAMETER_TYPE IS NULL OR PARAMETER_SUB_TYPE IS NULL) THEN
	RETURN NULL;
END IF;

IF(PARAMETER_TYPE = 'EC_OBJECT_TYPE') THEN
	RETURN ec_class.label(parameter_sub_type);
END IF;

IF(PARAMETER_TYPE = 'BASIC_TYPE') THEN
	RETURN ec_prosty_codes.code_text(parameter_sub_type,'BASIC_TYPE');
END IF;

IF(PARAMETER_TYPE = 'EC_TABLE_TYPE') THEN
	RETURN ec_prosty_codes.code_text(parameter_sub_type,'EC_TABLE_TYPE');
END IF;

IF(PARAMETER_TYPE = 'USER_EXIT') THEN
	RETURN ec_prosty_codes.code_text(parameter_sub_type,'UE_PARAM_SUB_TYPE');
END IF;

RETURN parameter_sub_type;

END GetNameByType;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetPresentationSyntax
-- Description    : Returns either the value
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

FUNCTION GetPresentationSyntax(parameter_type VARCHAR2, parameter_sub_type VARCHAR2, popup_dependency VARCHAR2 DEFAULT NULL, navigator_value VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
--</EC-DOC>
IS
v_val VARCHAR2(500);
v_tmp VARCHAR2(500);
v_popup_depend VARCHAR2(500);
CURSOR c_col_val IS
	SELECT group_type col
		FROM class_relation cr
	WHERE cr.TO_CLASS_NAME = PARAMETER_SUB_TYPE AND cr.GROUP_TYPE IS NOT NULL;

BEGIN
IF(PARAMETER_TYPE = 'BASIC_TYPE') THEN
	IF(PARAMETER_SUB_TYPE = 'DATE') THEN
		RETURN 'viewwidth=70;viewformatmask=yyyy-MM-dd;pickerurl=/FrontController/com.ec.pf.screenlet.common/filter_date_picker;pickerheight=310;pickerwidth=208';
	END IF;
	IF(PARAMETER_SUB_TYPE = 'DATETIME_LONG') THEN
		RETURN 'viewwidth=110;viewformatmask=yyyy-MM-dd HH:mm:ss;pickerurl=/FrontController/com.ec.pf.screenlet.common/filter_date_time_picker;pickerwidth=208;pickerheight=310';
	END IF;
	IF(PARAMETER_SUB_TYPE = 'TIME') THEN
		RETURN 'viewwidth=70;viewformatmask=HH:mm;vieweditable=false;pickerurl=/FrontController/com.ec.pf.screenlet.common/filter_time_picker;pickerwidth=150;pickerheight=100';
	END IF;
	IF(PARAMETER_SUB_TYPE = 'TIME_LONG') THEN
		RETURN 'viewwidth=70;viewformatmask=HH:mm:ss;pickerurl=/FrontController/com.ec.pf.screenlet.common/filter_time_picker;pickerwidth=150;pickerheight=100';
	END IF;
	IF(PARAMETER_SUB_TYPE = 'DATE_YEAR') THEN
		RETURN 'viewwidth=35;viewformatmask=yyyy;pickerurl=/FrontController/com.ec.pf.screenlet.common/filter_year_picker;pickerheight=218;pickerwidth=201';
	END IF;
	IF(PARAMETER_SUB_TYPE = 'DATE_MONTH') THEN
		RETURN 'viewformatmask=yyyy-MM;viewwidth=50;pickerurl=/FrontController/com.ec.pf.screenlet.common/filter_mth_picker;pickerheight=120;pickerwidth=140';
	END IF;
	IF(PARAMETER_SUB_TYPE = 'DATETIME') THEN
		RETURN 'viewwidth=110;viewformatmask=yyyy-MM-dd HH:mm;pickerurl=/FrontController/com.ec.pf.screenlet.common/filter_date_time_picker;pickerwidth=208;pickerheight=310';
	END IF;
	IF(PARAMETER_SUB_TYPE = 'BOOL') THEN
		RETURN 'viewtype=checkbox';
	END IF;

END IF;
IF(PARAMETER_TYPE = 'EC_CODE_TYPE') THEN

	IF(popup_dependency IS NOT NULL) THEN
     v_popup_depend := 'PopupDependency=Screen.this.currentRow.' || popup_dependency || '=ReturnField.CODE;';
  END IF;

RETURN concat(concat('viewwidth=120;PopupQueryURL=/com.ec.frmw.co.screens/query/ec_code_popup.xml;PopupLayout=/com.ec.frmw.co.screens/layout/ec_code_popup.xml;PopupWhereColumn=CODE_TYPE;PopupWhereValue='
, Parameter_sub_type),
';PopupWhereOperator==;PopupReturnColumn=CODE_TEXT;'|| v_popup_depend ||'PopupWidth=250;PopupHeight=300;PopupCache=true;viewtranslate=TRUE'
);
END IF;

IF(PARAMETER_TYPE = 'EC_OBJECT_TYPE') THEN

	IF(popup_dependency IS NOT NULL) THEN
     v_popup_depend := 'PopupDependency=Screen.this.currentRow.' || popup_dependency || '=ReturnField.OBJECT_ID;';
  END IF;

  FOR cur_row IN c_col_val LOOP
		v_tmp := cur_row.col;
		IF(v_tmp = 'operational') THEN
			v_val := v_tmp;
		END IF;
		IF(v_tmp = 'geographical' AND v_val IS NULL) THEN
			v_val := v_tmp;
		END IF;
	END LOOP;
	IF(v_val IS NOT NULL) THEN
		RETURN CONCAT(CONCAT('viewwidth=150;PopupURL=/FrontController/com.ec.frmw.co.screens/groupmodel_popup?TARGET='
		, PARAMETER_SUB_TYPE),';PopupReturnColumn=OBJECT_NAME;'|| v_popup_depend ||'PopupWidth=700;PopupHeight=500');

	END IF;
		RETURN CONCAT(CONCAT('viewwidth=150;PopupURL=/FrontController/com.ec.frmw.co.screens/object_popup?CLASS_NAME='
		,PARAMETER_SUB_TYPE),';PopupReturnColumn=NAME;'|| v_popup_depend ||'PopupWidth=250;PopupHeight=300');
END IF;

IF(PARAMETER_TYPE = 'EC_TABLE_TYPE') THEN
  IF parameter_sub_type = 'REPORT_DEFINITION_GROUP' THEN
  /*
   This presentation syntax is specific for usage in Create and Maintain Schedules screen (ACTION_INSTANCE_VALUE class) and depends upon
   that the Functional Area is available from screen navigator. If this EC_TABLE_TYPE type is used in another screen, it returns no
   presentation syntax (empty string).
  */
  	IF(popup_dependency IS NOT NULL AND navigator_value IS NOT NULL) THEN
       RETURN 'viewwidth=120;PopupQueryURL=/com.ec.frmw.report.screens/query/rep_def_group_popup.xml;PopupLayout=/com.ec.frmw.report.screens/layout/rep_def_group_popup.xml;' ||
      'PopupReturnColumn=NAME;PopupDependency=Screen.this.currentRow.' || popup_dependency ||
      '=ReturnField.REP_GROUP_CODE$RetrieveArg.FUNC_AREA=' || navigator_value ||
      ';PopupWidth=250;PopupHeight=300';
     ELSE
         RETURN '';
     END IF;

  ELSIF parameter_sub_type = 'PRINTER' THEN
       IF(popup_dependency IS NOT NULL ) THEN
          RETURN 'PopupURL=/FrontController/com.ec.frmw.co.screens/printservice_popup;PopupReturnColumn=NAME;PopupWidth=250;PopupHeight=300;PopupDependency=Screen.this.currentRow.PARAMETER_VALUE=ReturnField.CODE';
        ELSE
            RETURN '';
        END IF;


  /*
    This presentation syntax is specific to the Message Distribution screen. It requires that a message_type is available in the current row as an OBJECT_ID
  */
  ELSIF parameter_sub_type = 'MESSAGE_TEMPLATE' THEN
       IF(popup_dependency IS NOT NULL ) THEN
          RETURN 'PopupURL=/FrontController/com.ec.frmw.mhm.screens/dataclass_dep_popup?CLASS=MSG_FREE_TEXT_SUBJECT;PopupReturnColumn=SUBJECT;' ||
                 'PopupWidth=250;PopupHeight=300;' ||
                 'PopupDependency=Screen.this.currentRow.'|| popup_dependency || '=ReturnField.SUBJECT$RetrieveArg.PARENT_ID=Screen.msg.currentRow.OBJECT_ID$RetrieveArg.DAYTIME=RetrieveArgs.nav.DATE$RetrieveArg.OBJECT_START_DATE=RetrieveArgs.nav.DATE$RetrieveArg.KEYFIELD=SUBJECT';
        ELSE
            RETURN '';
        END IF;
  END IF;



END IF;

IF(PARAMETER_TYPE = 'USER_EXIT') THEN
    RETURN Ue_Report_Parameter.GetPresentationSyntax(parameter_sub_type,popup_dependency,navigator_value);
END IF;

RETURN '';

END GetPresentationSyntax;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetDuration
-- Description    : Makes a friendly string which is the duration in Days, hours, minutes and seconds
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

FUNCTION GetDuration(FROM_DATE DATE, TO_DATE DATE)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
IF(FROM_DATE IS NULL  OR TO_DATE IS NULL) THEN
	RETURN NULL;
END IF;

RETURN CONCAT(
	CONCAT(CONCAT(
	pad0((EXTRACT(DAY FROM TO_DSINTERVAL(TO_TIMESTAMP(TO_CHAR(TO_DATE, 'yyyymmdd HH24:MI:SS'), 'yyyymmdd HH24:MI:SS')
		- TO_TIMESTAMP(TO_CHAR(FROM_DATE, 'yyyymmdd HH24:MI:SS'), 'yyyymmdd HH24:MI:SS'))) *24) +
		EXTRACT(HOUR FROM TO_DSINTERVAL(TO_TIMESTAMP(TO_CHAR(TO_DATE, 'yyyymmdd HH24:MI:SS'), 'yyyymmdd HH24:MI:SS')
		- TO_TIMESTAMP(TO_CHAR(FROM_DATE, 'yyyymmdd HH24:MI:SS'), 'yyyymmdd HH24:MI:SS')))
	), ':') ,
	CONCAT(pad0(EXTRACT(MINUTE FROM TO_DSINTERVAL(TO_TIMESTAMP(TO_CHAR(TO_DATE, 'yyyymmdd HH24:MI:SS'), 'yyyymmdd HH24:MI:SS')
		- TO_TIMESTAMP(TO_CHAR(FROM_DATE, 'yyyymmdd HH24:MI:SS'), 'yyyymmdd HH24:MI:SS')))),':'))
		, pad0(EXTRACT(second FROM TO_DSINTERVAL(TO_TIMESTAMP(TO_CHAR(TO_DATE, 'yyyymmdd HH24:MI:SS'), 'yyyymmdd HH24:MI:SS')
		- TO_TIMESTAMP(TO_CHAR(FROM_DATE, 'yyyymmdd HH24:MI:SS'), 'yyyymmdd HH24:MI:SS')))));

END GetDuration;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : pad0
-- Description    : prepend a 0 if the number is less that 10
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

FUNCTION pad0(num NUMBER) RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
	IF(abs(num) < 10) THEN
		RETURN '0' || floor(num);
	END IF;

	RETURN '' || floor(num);

END;

FUNCTION getComponentFullNameLabel(p_component_ext_name VARCHAR2) RETURN VARCHAR2
IS

lv_full_name varchar2(4000);

CURSOR c_ctrl_tv is
SELECT  level, component_id, parent_component_id, component_label
FROM ctrl_tv_presentation
START WITH  component_ext_name = p_component_ext_name
CONNECT BY prior parent_component_id = component_id
ORDER BY level DESC;

BEGIN
  FOR cur_tv in c_ctrl_tv LOOP
    IF lv_full_name is null THEN
      lv_full_name := cur_tv.component_label;
    ELSE
      lv_full_name := lv_full_name || '>' || cur_tv.component_label;
    END IF;
    END LOOP;
  RETURN lv_full_name;
END;




END EcDp_Client_Presentation;