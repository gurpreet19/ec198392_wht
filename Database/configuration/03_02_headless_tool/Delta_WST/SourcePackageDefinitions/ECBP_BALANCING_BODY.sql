CREATE OR REPLACE PACKAGE BODY EcBp_Balancing IS

/****************************************************************
** Package        :  EcDp_Balancing, body part
**
** $Revision: 1.11 $
**
** Purpose        :  Provide support for balancing
**
** Documentation  :  www.energy-components.com
**
** Created  : 21.01.2016  Mawaddah
**
** Modification history:
**
** Date     Whom   		description:
** -------  ------ 		--------------------------------------
** 21.01.16 abdulmaw 	ECPD-30628: Added new function getProductUOM and validateBalancingAdj
** 21.02.16 dhavaalo 	ECPD-30030: Added new function  getProductBalGroup
** 11.02.16 chaudgau    ECPD-38185: Added new function isWaterProductGroup
** 08.11.16 chaudgau    ECPD-39505: Added new function getAdjVolume
** 18.07.17 kashisag    ECPD-45817: Replaced sysdate with Ecdp_Timestamp.getCurrentSysdate
****************************************************************/
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getProductUOM
-- Description    : Returns UOM based on Product Type
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getProductUOM(
        p_product_id     VARCHAR2,
        p_daytime        DATE,
        p_rate_type      VARCHAR2)

RETURN VARCHAR2
--</EC-DOC>
IS

  lv2_product_type VARCHAR2(32);
  lv2_uom          VARCHAR2(32);

  CURSOR cur_view_unit(c_uom_meas_type VARCHAR2) IS
   SELECT unit
   FROM ctrl_uom_setup cus
   WHERE cus.measurement_type = c_uom_meas_type
   AND cus.view_unit_ind = 'Y';

BEGIN

   lv2_product_type := ec_product_version.product_type(p_product_id, p_daytime, '<=');

   IF p_rate_type = 'VOLUME' THEN
      IF lv2_product_type = 'LIQUID' THEN
         lv2_uom := 'STD_LIQ_VOL';
      ELSIF lv2_product_type = 'GAS' THEN
         lv2_uom := 'STD_GAS_VOL';
      ELSE
         lv2_uom := 'STD_LIQ_VOL';
      END IF;

   ELSIF p_rate_type = 'MASS' THEN
      IF lv2_product_type = 'LIQUID' THEN
         lv2_uom := 'LIQ_MASS';
      ELSIF lv2_product_type = 'GAS' THEN
         lv2_uom := 'GAS_MASS';
      ELSE
         lv2_uom := 'LIQ_MASS';
      END IF;

   ELSIF p_rate_type = 'ENERGY' THEN
      IF lv2_product_type = 'GAS' THEN
         lv2_uom := 'ENERGY';
      END IF;
   END IF;

   FOR c_view_unit IN cur_view_unit(lv2_uom) LOOP
       lv2_uom := c_view_unit.unit;
   END LOOP;

   lv2_uom:= ECDP_UNIT.GetUnitLabel(lv2_uom);

RETURN lv2_uom;

END getProductUOM;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getProductBalGroup
-- Description    : Returns Product Bal Group
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getProductBalGroup(
   p_product_balance        strm_version.product_id%TYPE,
   p_daytime          DATE,
   p_end_date 		DATE,
   p_strm_bal_category  strm_version.strm_bal_category%TYPE,
   P_CODE_NAME VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
   lv_product_balance_group            VARCHAR2(32000);

BEGIN

	BEGIN
		  SELECT  DECODE(P_CODE_NAME,'CODE',ECDP_OBJECTS.GetObjCode(OBJECT_ID),'NAME',ECDP_OBJECTS.GetObjName(object_id,daytime),'ID',OBJECT_ID) into lv_product_balance_group
          FROM PRODUCT_STRM_BAL_CAT
          WHERE product_id = p_product_balance
          AND (STRM_BAL_CATEGORY = p_strm_bal_category OR STRM_BAL_CATEGORY = 'ALL')
          AND daytime <= p_daytime
          AND NVL(end_date,Ecdp_Timestamp.getCurrentSysdate) >= NVL(p_end_date,DAYTIME);
	EXCEPTION
		WHEN OTHERS THEN
		lv_product_balance_group:=NULL;
    END;
   RETURN lv_product_balance_group;

END getProductBalGroup;


---------------------------------------------------------------------------------------------------
-- Function       : validateBalancingAdj
-- Description    : validate Monthly Balancing Adjustment
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   :
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateBalancingAdj(
  p_product_group_id VARCHAR2,
  p_product_id       VARCHAR2,
  p_strm_bal_category VARCHAR2,
  p_stream_id		 VARCHAR2,
  p_from_object_type VARCHAR2,
  p_from_object_id   VARCHAR2,
  p_to_object_type   VARCHAR2,
  p_to_object_id     VARCHAR2)
IS

  ue_flag CHAR;

BEGIN

  ue_balancing.validateBalancingAdj(p_product_group_id, p_product_id, p_strm_bal_category, p_stream_id, p_from_object_type, p_from_object_id, p_to_object_type, p_to_object_id, ue_flag);


  -- For product validation
  /*IF (upper(ue_flag) = 'N') THEN

  END IF;*/

END  validateBalancingAdj;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isWaterProductGroup
-- Description    : Check whether the product belongs to Product Group of type Water
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

FUNCTION isWaterProductGroup
  (
    p_product_id        VARCHAR2
   ,p_daytime           DATE
   ,p_end_date          DATE
   ,p_strm_bal_category VARCHAR2
   )
RETURN VARCHAR2
IS
   ln_product_grp_cnt NUMBER;

BEGIN

SELECT COUNT(*) INTO ln_product_grp_cnt
FROM ov_product_group
WHERE object_id IN
      (SELECT object_id
          FROM PRODUCT_STRM_BAL_CAT
          WHERE product_id = p_product_id
          AND (STRM_BAL_CATEGORY = p_strm_bal_category OR STRM_BAL_CATEGORY = 'ALL')
          AND daytime <= p_daytime
          AND NVL(end_date,Ecdp_Timestamp.getCurrentSysdate) >= NVL(p_end_date,DAYTIME)
      )
  AND product_group_type='BALANCING'
  AND is_water_product='Y'
  AND daytime <= p_daytime
  AND NVL(end_date,Ecdp_Timestamp.getCurrentSysdate) >= NVL(p_end_date,DAYTIME);

  RETURN (CASE WHEN ln_product_grp_cnt>0 THEN 'Y' ELSE 'N' END);

END isWaterProductGroup;

FUNCTION getAdjVolume(
    p_strm_object_id     VARCHAR2
   ,p_daytime            DATE
   ,p_property           VARCHAR2 DEFAULT 'NET_VOL')
RETURN NUMBER
IS
    ln_netvol NUMBER;
    ln_netmass NUMBER;
    ln_netenergy NUMBER;
BEGIN
    SELECT net_vol, net_mass, energy
      INTO ln_netvol, ln_netmass, ln_netenergy
      FROM dv_balancing_adj_mth d
     WHERE stream_id = p_strm_object_id
       AND daytime = p_daytime;

    IF p_property = 'NET_VOL' THEN
      RETURN NVL(ln_netvol,0);
    ELSIF p_property = 'NET_MASS' THEN
      RETURN NVL(ln_netmass,0);
    ELSIF p_property = 'NET_ENERGY' THEN
      RETURN NVL(ln_netenergy,0);
    END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
       RETURN 0;
END getAdjVolume;

END EcBp_Balancing;