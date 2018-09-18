CREATE OR REPLACE PACKAGE BODY EcBp_SND IS

/****************************************************************
** Package        :  EcBp_SND, body part
** Stream Node Diagram(SND)
** Modification history:
**
**  Date        Whom      Change description:
** ----------  --------  --------------------------------------
** 30.01.2017 solibhar  ECPD-42709: New Screen to display live data in SND
**                                  Added the new function to find data class for given object id.
** 16.02.2017 solibhar  ECPD-42711: Added the new function to find Daily Data screen Url for given object id.
** 10.03.2017 solibhar  ECPD-43702: Changed getDailyScreenUrl function to getTvComponentId to return ctrl_tv_preprocedure component_id.
** 14.03.2017 solibhar  ECPD-43710: Changed configuration to condider Well.instrumentation_type type to choose correct screen url for daily well status.
** 20.03.2017 solibhar  ECPD-44453: Added new function getComponentLabel to find EC Screen Label for given component_id.
** 28.03.2017 solibhar  ECPD-43703: Added new functions addIntoCntxMenuItem and deleteFromCntxMenuItem to sync Context Menu entry with CNTX_MENU_ITEM table
									Removed getDailyScreenUrl function
*****************************************************************/

---------------------------------------------------------------------------------------------------
-- Function       : liveDataClass
-- Description    : Returns the class name for SND Live Data.
---------------------------------------------------------------------------------------------------
FUNCTION liveDataClass(
   p_object_id VARCHAR2,
   p_daytime DATE)
RETURN VARCHAR2
IS
	lv2_return_value 	VARCHAR2(32);
	lv2_class_name		VARCHAR2(32) := ecdp_objects.GetObjClassName(p_object_id);
	lv2_isProducer	 	VARCHAR2(32);
BEGIN

   IF lv2_class_name = 'WELL' THEN
		lv2_isProducer :=ecdp_well.isWellProducer(p_object_id,p_daytime);
		IF UPPER(lv2_isProducer) = 'Y' THEN
			lv2_return_value:='PWEL_SND_DATA';
		ELSE
			lv2_return_value:='IWEL_SND_DATA';
		END IF;

   ELSIF lv2_class_name = 'SND_WELL_GROUP' THEN
		lv2_isProducer := ec_snd_group_version.isproducer(p_object_id, p_daytime, '<=');
		IF UPPER(lv2_isProducer) = 'Y' THEN
			lv2_return_value:='PWEL_SND_DATA';
		ELSE
			lv2_return_value:='IWEL_SND_DATA';
		END IF;

   ELSIF lv2_class_name = 'STREAM' THEN
	lv2_return_value:='STRM_SND_DATA';

   ELSIF lv2_class_name = 'FCTY_CLASS_1' THEN
	lv2_return_value:='FCTY_SND_DATA';

   ELSIF lv2_class_name = 'FCTY_CLASS_2' THEN
	lv2_return_value:='FCTY_2_SND_DATA';

	ELSIF lv2_class_name = 'WELL_HOOKUP' THEN
	lv2_return_value:='WELL_HOOKUP_SND_DATA';
   END IF;

   RETURN lv2_return_value;

END liveDataClass;

---------------------------------------------------------------------------------------------------
-- FUNCTION      : getComponentLabel
-- Description   : Returns the EC Screen Label for given component_id from CTRL_TV_PRESENTATION OR SND_UE_SCREEN.
---------------------------------------------------------------------------------------------------

FUNCTION getComponentLabel(p_component_id VARCHAR2)
RETURN VARCHAR2
IS
	lv2_component_lable VARCHAR2(200);

BEGIN

    SELECT c.component_label INTO lv2_component_lable FROM ctrl_tv_presentation c
	WHERE c.component_id = p_component_id;

	RETURN lv2_component_lable;

	EXCEPTION
	WHEN NO_DATA_FOUND THEN
	    SELECT c.component_label INTO lv2_component_lable FROM v_snd_ue_screen c
		WHERE c.component_id = p_component_id;
		RETURN lv2_component_lable;

	WHEN OTHERS	THEN
		RETURN lv2_component_lable;

END getComponentLabel;

---------------------------------------------------------------------------------------------------
-- Procedure      : addIntoCntxMenuItem
-- Description    : Add new Menu Item in CNTC_MENU_ITEM table
--
--
-- Using tables   : CNTX_MENU_ITEM,BF_COMPONENT_ACTION,CTRL_TV_PRESENTATION
-- Using views    : V_SND_UE_SCREEN
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE addIntoCntxMenuItem (p_component_id  IN VARCHAR2,p_object_type IN  VARCHAR2)
IS

  lv2_screen_lable     			VARCHAR2(2000);
  lv2_func_hidden      			VARCHAR2(200);
  ln_bf_component_action_no     NUMBER;
  lv2_bf_code		   			VARCHAR2(50) := 'CO.00941';
  lv2_bf_comp_code     			VARCHAR2(50) := 'allocation_network';
  lv2_parent_item_code 			VARCHAR2(200) :='prodDataMenu';
  lv2_action_name	   			VARCHAR2(200);
  ln_menu_exist	   				NUMBER;

BEGIN


    SELECT c.component_label INTO lv2_screen_lable FROM ctrl_tv_presentation c
    WHERE c.component_id = p_component_id;

	select count(*) into ln_menu_exist from cntx_menu_item where item_code = lv2_parent_item_code;

	IF ln_menu_exist < 1 THEN
		-- Create "Production Data Menu" item

		ln_bf_component_action_no := EcDp_Business_function.createBFComponentAction(lv2_bf_code,lv2_bf_comp_code,lv2_parent_item_code);

		--insert into cntx_menu_item to create new sub menu item, under "Production Data" menu.
		insert into cntx_menu_item (bf_component_action_no,bf_code, comp_code, item_code,name, min_selected_row,max_selected_row,sort_order)
		values (ln_bf_component_action_no,lv2_bf_code,lv2_bf_comp_code,lv2_parent_item_code, 'Production Data Menu','1','1',500);
	END IF;

	lv2_action_name := p_component_id||'_'||p_object_type;
	ln_bf_component_action_no := EcDp_Business_function.createBFComponentAction(lv2_bf_code,lv2_bf_comp_code,lv2_action_name);


	lv2_func_hidden := 'OBJECT_CLASS_NAME='||p_object_type||';'||'com.ec.frmw.jsf.service.snd.ContextMenuService.canShowTvScreenMenuItem';
	--insert into cntx_menu_item to create new sub menu item, under "Production Data" menu.
    insert into cntx_menu_item (bf_component_action_no,bf_code, comp_code, item_code,name, parent_item_code, func_hidden,min_selected_row,max_selected_row,sort_order)
    values (ln_bf_component_action_no,lv2_bf_code,lv2_bf_comp_code,p_component_id, lv2_screen_lable,lv2_parent_item_code,lv2_func_hidden,'1','1',1000);


	insert into cntx_menu_item_param(bf_component_action_no,bf_code,comp_code,item_code,parameter_name,parameter_value,sort_order)
	values (ln_bf_component_action_no,lv2_bf_code,lv2_bf_comp_code,p_component_id,'PROD_DATA_POPUP','Y',10);

	update snd_prod_data_menu m set m.bf_component_action_no=ln_bf_component_action_no
	where m.component_id=p_component_id and m.node_class_name=p_object_type;


    EXCEPTION
      WHEN OTHERS
      THEN return;

END addIntoCntxMenuItem;


---------------------------------------------------------------------------------------------------
-- Procedure      : deleteFromCntxMenuItem
-- Description    : Add new Menu Item in CNTC_MENU_ITEM table
--
--
-- Using tables   : CNTX_MENU_ITEM,BF_COMPONENT_ACTION
-- Using views    :
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE deleteFromCntxMenuItem(p_bf_component_action_no IN NUMBER)
IS

BEGIN
		delete from cntx_menu_item_param where bf_component_action_no=p_bf_component_action_no;

		delete from cntx_menu_item where bf_component_action_no=p_bf_component_action_no;

		delete from bf_component_action where bf_component_action_no=p_bf_component_action_no;

    EXCEPTION
      WHEN OTHERS
      THEN return;

END deleteFromCntxMenuItem;

END EcBp_SND;