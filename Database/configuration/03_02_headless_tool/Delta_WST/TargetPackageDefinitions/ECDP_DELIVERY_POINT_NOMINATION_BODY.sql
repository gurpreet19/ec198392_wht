CREATE OR REPLACE PACKAGE BODY EcDp_Delivery_Point_Nomination IS
/******************************************************************************
** Package        :  EcDp_Delivery_Point_Nomination, body part
**
** $Revision: 1.6 $
**
** Purpose        :  Find and work with delivery point nominations
**
** Documentation  :  www.energy-components.com
**
** Created        :  24.03.2006 Kristin Eide
**
** Modification history:
**
** Date        Whom      Change description:
** ------      -----     -----------------------------------------------------------------------------------------------
** 24.03.2006  EIDEEKRI  Initial version
**
**
********************************************************************/



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDeliveryPointProductionDay
-- Description    : Returns the time of the production day
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:  Ec_Ctrl_System_Attribute.attribute_text()
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getDeliveryPointProductionDay(
  p_date        DATE
)
RETURN DATE
--</EC-DOC>
IS
	ld_production_day DATE;
	lv_hour VARCHAR2(10);

BEGIN

	RETURN ecdp_date_time.getProductionDay(NULL,p_date,NULL);

END getDeliveryPointProductionDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDayDelptUpstreamNom
-- Description    : Returns the sum of daily upstream nomination records for the given day and delivery point.
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
-- Behaviour      : Returns the sum of the total upstream nominations for a given delivery point and date.
--
---------------------------------------------------------------------------------------------------
FUNCTION getDayDelptUpstreamNom(
  p_delivery_point_id   VARCHAR2,
  p_date        DATE
)
RETURN INTEGER
--</EC-DOC>
IS
	ln_qty   NUMBER;
   CURSOR c_qty (cp_delivery_point_id VARCHAR2, cp_daytime DATE) IS
      SELECT SUM(upstream_nom_qty) AS downstream_qty
      FROM CNTR_SUB_DAY_DP_SHIP_NOM
      WHERE delivery_point_id = cp_delivery_point_id
      AND production_day = cp_daytime;

BEGIN
   ln_qty := NULL;

   FOR qty_rec IN c_qty(p_delivery_point_id, p_date) LOOP
      ln_qty := NVL(ln_qty,0) + qty_rec.downstream_qty;
   END LOOP;

   RETURN ln_qty;

END getDayDelptUpstreamNom;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDayDelptDownstreamNom
-- Description    : Returns the sum of daily downstream nomination records for the given day and delivery point.
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
-- Behaviour      : Returns the sum of the total downstream nominations for a given delivery point and date.
--
---------------------------------------------------------------------------------------------------
FUNCTION getDayDelptDownstreamNom(
  p_delivery_point_id   VARCHAR2,
  p_date        DATE
)
RETURN INTEGER
--</EC-DOC>
IS

	ln_qty   NUMBER;
   CURSOR c_qty (cp_delivery_point_id VARCHAR2, cp_daytime DATE) IS
      SELECT SUM(downstream_nom_qty) AS downstream_qty
      FROM CNTR_SUB_DAY_DP_SHIP_NOM
      WHERE delivery_point_id = cp_delivery_point_id
      AND production_day = cp_daytime;

BEGIN
   ln_qty := NULL;

   FOR qty_rec IN c_qty(p_delivery_point_id, p_date) LOOP
      ln_qty := NVL(ln_qty,0) + qty_rec.downstream_qty;
   END LOOP;

   RETURN ln_qty;

END getDayDelptDownstreamNom;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDayDeliveryPointNomination
-- Description    : Returns the sum of daily nomination records for the given day and delivery point.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : cntr_day_dp_nom
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the sum of the total nominations for a given delivery point and date.
--
---------------------------------------------------------------------------------------------------
FUNCTION getDayDeliveryPointNomination(
  p_delivery_point_id   VARCHAR2,
  p_date        DATE
)
RETURN INTEGER
--</EC-DOC>
IS

   ln_delpnt_qty		NUMBER;
   ln_contract_qty 	NUMBER;
   lv_contract_uom 	VARCHAR2(32);
   lv_delpnt_uom 		VARCHAR2(32);

   CURSOR c_contract (cp_delivery_point_id VARCHAR2, cp_daytime DATE) IS
  		SELECT object_id
  		FROM cntr_day_dp_nom
  		WHERE delivery_point_id = cp_delivery_point_id
  		AND daytime = cp_daytime;

BEGIN
	ln_delpnt_qty := NULL;
	ln_contract_qty := 0;

	-- the unit of the delivery point
	lv_delpnt_uom := Nvl(EcDp_Unit.GetUnitFromLogical(nvl(Ec_Class_Attr_Presentation.uom_code('DP_SUB_DAY_TARGET_EXIT', 'TARGET_QTY'),'')), '');

   --the nominated_qty of the different contracts
   FOR contract_rec IN c_contract(p_delivery_point_id, p_date) LOOP
     	ln_contract_qty := Nvl(EcDp_Contract_Nomination.getDailyNomination(contract_rec.object_id, p_delivery_point_id, p_date), 0);
  		lv_contract_uom := Nvl(EcDp_Contract_Attribute.getAttributeString(contract_rec.object_id, 'NOM_UOM', p_date), '');

  		IF(lv_contract_uom <> lv_delpnt_uom) THEN
  			--convert to the uom of the delivery point
  			ln_contract_qty := Nvl(EcDp_Unit.convertValue(ln_contract_qty, lv_contract_uom, lv_delpnt_uom), 0);
  		END IF;
  		-- summarize the quantities
  		ln_delpnt_qty := Nvl(ln_delpnt_qty, 0) + ln_contract_qty;

   END LOOP;

   RETURN ln_delpnt_qty;

END getDayDeliveryPointNomination;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSubDayDelpntNomination
-- Description    : Returns the hourly nomination records for the given day and delivery point.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : cntr_sub_day_dp_nom
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the sum of the hourly nominations for a given delivery point and date.
--
---------------------------------------------------------------------------------------------------
FUNCTION getSubDayDelpntNomination(
  p_delivery_point_id   VARCHAR2,
  p_date        DATE,
  p_class_name VARCHAR2
)
RETURN INTEGER
--</EC-DOC>
IS

   ln_delpnt_qty		NUMBER;
   ln_contract_qty	NUMBER;
   lv_contract_uom 	VARCHAR2(32);
   lv_delpnt_uom 		VARCHAR2(32);

  CURSOR c_contract (cp_delivery_point_id VARCHAR2, cp_daytime DATE) IS
  		SELECT object_id
  		FROM cntr_sub_day_dp_nom
  		WHERE delivery_point_id = cp_delivery_point_id
  		AND daytime = cp_daytime;

BEGIN

   ln_delpnt_qty := NULL;

   -- get the uom of the delivery point. dependent of the class
   lv_delpnt_uom := Nvl(EcDp_Unit.GetUnitFromLogical(nvl(Ec_Class_Attr_Presentation.uom_code(p_class_name, 'TARGET_QTY'),'')), '');

   FOR contract_rec IN c_contract(p_delivery_point_id, p_date) LOOP
  		ln_contract_qty := Nvl(EcDp_Contract_Nomination.getSubDailyNomination(contract_rec.object_id, p_delivery_point_id, p_date), 0);
  		lv_contract_uom := Nvl(EcDp_Contract_Attribute.getAttributeString(contract_rec.object_id, 'NOM_UOM', p_date), '');

  		IF(lv_contract_uom <> lv_delpnt_uom) THEN
  			--convert to the uom of the delivery point
  			ln_contract_qty := Nvl(EcDp_Unit.convertValue(ln_contract_qty, lv_contract_uom, lv_delpnt_uom), 0);
  		END IF;
  		-- summarize the quantities
  		ln_delpnt_qty := Nvl(ln_delpnt_qty, 0) + ln_contract_qty;
  	END LOOP;

   RETURN ln_delpnt_qty;

END getSubDayDelpntNomination;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDayDeliveryPointTarget
-- Description    : Returns the sum of the hourly targets for the given day and delivery point.
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
-- Behaviour      : Returns the sum of the total targets for a given delivery point and date.
--
---------------------------------------------------------------------------------------------------
FUNCTION getDayDeliveryPointTarget(
  p_delivery_point_id   VARCHAR2,
  p_date        DATE
)
RETURN INTEGER
--</EC-DOC>
IS

   ln_target   NUMBER;
   CURSOR c_target (cp_object_id VARCHAR2, cp_daytime DATE) IS
      SELECT SUM(target_qty) AS target_qty
      FROM DELPNT_SUB_DAY_TARGET
      WHERE object_id = cp_object_id
      AND production_day = cp_daytime;

BEGIN
   ln_target := NULL;

   FOR target_rec IN c_target(p_delivery_point_id, p_date) LOOP
      ln_target := NVL(ln_target,0) + target_rec.target_qty;
   END LOOP;

   RETURN ln_target;

END getDayDeliveryPointTarget;


END EcDp_Delivery_Point_Nomination;