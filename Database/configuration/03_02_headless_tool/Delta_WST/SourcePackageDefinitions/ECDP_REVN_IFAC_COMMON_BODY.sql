CREATE OR REPLACE PACKAGE BODY EcDp_REVN_IFAC_COMMON IS

------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetCargoProcessingPeriod(
                         p_ifac ifac_cargo_value%ROWTYPE
                        ,p_contract_start_date DATE
                        )
RETURN DATE
IS
    ld_processing_period DATE;
BEGIN
    ld_processing_period := COALESCE(
              p_ifac.point_of_sale_date,
              p_ifac.Bl_Date,
              p_ifac.Loading_Date,
              p_ifac.Loading_Comm_Date,
              p_ifac.Delivery_Date,
              p_ifac.Delivery_Comm_Date,
              p_contract_start_date);

    RETURN TRUNC(ld_processing_period,'MM');
END GetCargoProcessingPeriod;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetCargoProcessingPeriod(
                         p_ifac T_IFAC_CARGO_VALUE
                        ,p_contract_start_date DATE
                        )
RETURN DATE
IS
    ld_processing_period DATE;
BEGIN
    ld_processing_period := COALESCE(
              p_ifac.point_of_sale_date,
              p_ifac.Bl_Date,
              p_ifac.Loading_Date,
              p_ifac.Loading_Comm_Date,
              p_ifac.Delivery_Date,
              p_ifac.Delivery_Comm_Date,
              p_contract_start_date);

    RETURN TRUNC(ld_processing_period,'MM');
END GetCargoProcessingPeriod;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------


END EcDp_REVN_IFAC_COMMON;