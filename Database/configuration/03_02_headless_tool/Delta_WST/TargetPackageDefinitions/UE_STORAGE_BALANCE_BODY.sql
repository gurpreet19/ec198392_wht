CREATE OR REPLACE PACKAGE BODY ue_Storage_Balance IS
/****************************************************************
** Package        :  ue_Storage_Balance; body part
**
** $Revision: 1.2.58.2 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created        :  16.04.2007	Kari Sandvik
**
** Modification history:
**
** Date        Whom     Change description:
** ----------  -------- -------------------------------------------
** 08.03.2013  sharawan     ECPD-23324: Add new function getForecastCargo, getCargoParcel to populate the tooltip in the graph component.
** 22.01.2015  farhaann     ECPD-29806: Add new function getStorageDipDate to get the latest tank dip date
******************************************************************/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getStorageDip
-- Description    : The user exit gives the project an opportunity to do unit conversion on tank dips
--
-- Preconditions  : A nomination unit must be set in product_meas_setup for the storage
-- Postconditions : The number returned must be in the same unit as the nomination unit. The number is basis for all storage balance calculations
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       : The argument to the function is based on the configuration in lifting_measurement_item and product_meas_setup
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getStorageDip(p_storage_id VARCHAR2,
					p_daytime DATE,
					p_condition VARCHAR2, --GRS or NET
					p_group VARCHAR2, -- V or M (or E)
					p_type VARCHAR,  -- OPENING or CLOSING
					p_dip NUMBER) -- The dip retreived from EC Production based on the above configuration
RETURN NUMBER
--</EC-DOC>
IS

BEGIN

	RETURN p_dip;

END getStorageDip;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getMaxVolLevel
-- Description    : Returns the Max Volumn Level for all tanks connected to the storage
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
FUNCTION getMaxVolLevel(p_storage_id VARCHAR2,
						p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
	RETURN ecbp_storage.getMaxVolLevel(p_storage_id, p_daytime);

END getMaxVolLevel;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getMinVolLevel
-- Description    : Returns the Min Volumn Level for all tanks connected to the storage
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
FUNCTION getMinVolLevel(p_storage_id VARCHAR2,
						p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN

	RETURN ecbp_storage.getMinVolLevel(p_storage_id, p_daytime);

END getMinVolLevel;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getMinSafeLimitVolLevel
-- Description    : Returns the Minimum Operational Safe Limit Level for all tanks connected to the storage
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
FUNCTION getMinSafeLimitVolLevel(p_storage_id VARCHAR2,
						p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN

	RETURN ecbp_storage.getMinSafeLimitVolLevel(p_storage_id, p_daytime);

END getMinSafeLimitVolLevel;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getMaxSafeLimitVolLevel
-- Description    : Returns the Maximum Operational Safe Limit Level for all tanks connected to the storage
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
FUNCTION getMaxSafeLimitVolLevel(p_storage_id VARCHAR2,
						p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN

	RETURN ecbp_storage.getMaxSafeLimitVolLevel(p_storage_id, p_daytime);

END getMaxSafeLimitVolLevel;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getForecastCargo
-- Description    : Returns the concatenated Cargo Name and Nom Sequence
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : stor_fcst_lift_nom, cargo_fcst_transport
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getForecastCargo(p_storage_id VARCHAR2,
                          p_forecast_id VARCHAR2,
                          p_daytime DATE)
RETURN VARCHAR2
--</EC-DOC>
IS
    lv_cargoName VARCHAR2(255);

    CURSOR c_cargo_info(cp_storage_id VARCHAR2, cp_forecast_id VARCHAR2, cp_daytime DATE) IS
    --SELECT distinct(ecbp_cargo_transport.getCargoName(cf.cargo_no, n.parcel_no)) cargo_name
    SELECT cf.cargo_name cargo_name, n.nom_sequence nom_seq
      FROM stor_fcst_lift_nom n, cargo_fcst_transport cf
     WHERE cf.cargo_no = n.cargo_no
       AND cf.forecast_id = cp_forecast_id
       AND n.forecast_id = cp_forecast_id
       AND n.object_id = Nvl(cp_storage_id, object_id)
       AND n.nom_firm_date = cp_daytime;

BEGIN

    FOR curCargoInfo IN c_cargo_info(p_storage_id, p_forecast_id, p_daytime) LOOP
		lv_cargoName := curCargoInfo.cargo_name || '-' || curCargoInfo.nom_seq;
    END LOOP;

    RETURN lv_cargoName;

END getForecastCargo;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCargoParcel
-- Description    : Returns the concatenated Forecast and Actual Nominated/Lifted Quantity for a Forecast Cargo
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : stor_fcst_lift_nom, cargo_fcst_transport
-- Using functions: ec_storage_lift_nomination.GRS_VOL_NOMINATED, EcDP_Unit.GetUnitLabel, EcBp_Storage_Lift_Nomination.getNomUnit
--                  EcBp_Storage_Lift_Nomination.getLiftedVol
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getCargoParcel(p_storage_id VARCHAR2,
						p_forecast_id VARCHAR2,
                        p_daytime DATE)
RETURN VARCHAR2
--</EC-DOC>
IS
    ln_parcel_no NUMBER;
    lv_stor_lvl VARCHAR2(100);
    lv_stor_fcst_lvl VARCHAR2(100);
    lv_tooltip VARCHAR2(200);

    CURSOR c_cargo_parcel(cp_storage_id VARCHAR2, cp_forecast_id VARCHAR2, cp_daytime DATE) IS
    SELECT n.parcel_no parcel_no
      FROM stor_fcst_lift_nom n, cargo_fcst_transport cf
     WHERE cf.cargo_no = n.cargo_no
       AND cf.forecast_id = cp_forecast_id
       AND n.forecast_id = cp_forecast_id
       AND n.object_id = Nvl(cp_storage_id, object_id)
       AND n.nom_firm_date = cp_daytime;

BEGIN

    FOR curCargoParcel IN c_cargo_parcel(p_storage_id, p_forecast_id, p_daytime) LOOP
		ln_parcel_no := curCargoParcel.parcel_no;

        lv_stor_fcst_lvl := ec_storage_lift_nomination.GRS_VOL_NOMINATED(ln_parcel_no) || ' ' || EcDP_Unit.GetUnitLabel(EcBp_Storage_Lift_Nomination.getNomUnit(p_storage_id,0));
        lv_stor_lvl := nvl(EcBp_Storage_Lift_Nomination.getLiftedVol(ln_parcel_no), ec_storage_lift_nomination.GRS_VOL_NOMINATED(ln_parcel_no)) || ' ' || EcDP_Unit.GetUnitLabel(EcBp_Storage_Lift_Nomination.getNomUnit(p_storage_id,0));

        lv_tooltip := '"<b>Forecast :</b> ' || lv_stor_fcst_lvl || '<br><b>Actual :</b> ' || lv_stor_lvl || '"';
    END LOOP;

	RETURN lv_tooltip;

END getCargoParcel;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getStorageDipDate
-- Description    : The user exit gives the project an opportunity to find latest tank dip date
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
FUNCTION getStorageDipDate(p_daytime  DATE,
                           p_event_type VARCHAR2,
                           p_last_dip   DATE)
RETURN DATE
--</EC-DOC>
IS

BEGIN
  NULL;
  RETURN p_last_dip;

END getStorageDipDate;

END ue_Storage_Balance;