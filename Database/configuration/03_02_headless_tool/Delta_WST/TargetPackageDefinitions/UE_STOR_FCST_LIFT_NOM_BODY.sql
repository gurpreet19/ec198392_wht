CREATE OR REPLACE PACKAGE BODY ue_Stor_Fcst_Lift_Nom IS
/******************************************************************************
** Package        :  ue_Stor_Fcst_Lift_Nom, body part
**
** $Revision: 1.1.40.2 $
**
** Purpose        :  Includes user-exit functionality for terminal operation screens
**
** Documentation  :  www.energy-components.com
**
** Created  : 05.06.2008 Kari Sandvik
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- -----------------------------------------------------------------------------------------------
** 24.01.2013  meisihil  ECPD-20962: Added functions aggrSubDayLifting, calcSubDayLifting to support liftings spread over hours
** -------     ------   ----------------------------------------------------------------------------------------------------
*/

---------------------------------------------------------------------------------------------------
-- Function       : deleteNomination
-- Description    : Delete all nominations in the selected period that is not fixed and where cargo status is not Official and ready for harbour
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE deleteNomination(p_storage_id VARCHAR2,p_forecast_id VARCHAR2,p_from_date DATE,p_to_date DATE)
--</EC-DOC>
IS
BEGIN
	NULL;
END deleteNomination;

---------------------------------------------------------------------------------------------------
-- Function       : setBalanceDelta
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE setBalanceDelta(p_forecast_id VARCHAR2, p_parcel_no NUMBER)
--</EC-DOC>
IS

	CURSOR c_nomination(cp_forecast_id VARCHAR2, cp_parcel_no number)
	IS
		SELECT nvl(purge_qty, 0) + nvl(cooldown_qty, 0) + nvl(vapour_return_qty, 0) + nvl(lauf_qty, 0) balance_delta_qty
		  FROM stor_fcst_lift_nom
		 WHERE parcel_no = cp_parcel_no
		   AND forecast_id = cp_forecast_id;

BEGIN

  -- Override the call to EcBp_Storage_Lift_Nomination if project spesific code.
  FOR c_nom IN c_nomination(p_forecast_id, p_parcel_no) loop
      UPDATE stor_fcst_lift_nom set balance_delta_qty = c_nom.balance_delta_qty WHERE parcel_no = p_parcel_no AND forecast_id = p_forecast_id;
  END LOOP;


END setBalanceDelta;

---------------------------------------------------------------------------------------------------
-- Function       : aggrSubDayLifting
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION aggrSubDayLifting(p_forecast_id VARCHAR2, p_parcel_no NUMBER, p_daytime DATE, p_column VARCHAR2 DEFAULT NULL, p_xtra_qty NUMBER DEFAULT 0)
RETURN NUMBER
--</EC-DOC>
IS
	ln_result NUMBER;
BEGIN
	ln_result := EcBP_Stor_Fcst_Lift_Nom.aggrSubDayLifting(p_forecast_id, p_parcel_no, p_daytime, p_column, p_xtra_qty);
	RETURN ln_result;
END aggrSubDayLifting;

---------------------------------------------------------------------------------------------------
-- Procedure      : calcSubDayLifting
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE calcSubDayLifting(p_forecast_id VARCHAR2, p_parcel_no NUMBER)
--</EC-DOC>
IS
	ln_unload_qty NUMBER;
	ln_unload_qty2 NUMBER;
	ln_vp_qty NUMBER;
	ln_vp_qty2 NUMBER;
	ln_lufg_qty NUMBER;
	ln_lufg_qty2 NUMBER;
	ln_unload_lufg_qty NUMBER;
	ln_unload_lufg_qty2 NUMBER;

	CURSOR c_nom(cp_forecast_id VARCHAR2, cp_parcel_no NUMBER)
	IS
		SELECT cargo_no, object_id, start_lifting_date,
		       grs_vol_requested, grs_vol_requested2, grs_vol_nominated, grs_vol_nominated2,
		       lauf_qty, lauf_qty2, balance_delta_qty, balance_delta_qty2
		  FROM stor_fcst_lift_nom
		 WHERE parcel_no = cp_parcel_no
		   AND forecast_id = cp_forecast_id
		   AND cargo_no NOT IN (select cargo_no from cargo_transport where cargo_status = 'D');

	CURSOR c_liftings(cp_parcel_no NUMBER)
	IS
		SELECT load_value, ec_product_meas_setup.LIFTING_EVENT(PRODUCT_MEAS_NO) lifting_event,
		       ec_product_meas_setup.NOM_UNIT_IND(PRODUCT_MEAS_NO) nom_unit_ind,
		       ec_product_meas_setup.NOM_UNIT_IND2(PRODUCT_MEAS_NO) nom_unit_ind2,
		       ec_product_meas_setup.balance_qty_type(PRODUCT_MEAS_NO) balance_qty_type
		  FROM storage_lifting
		 WHERE parcel_no = cp_parcel_no;
BEGIN
	EcBP_Stor_Fcst_Lift_Nom.calcSubDayLifting(p_forecast_id, p_parcel_no);
END calcSubDayLifting;

END ue_Stor_Fcst_Lift_Nom;
