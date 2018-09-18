CREATE OR REPLACE PACKAGE EcBp_CalculateAGA IS
/****************************************************************
** Package        :  EcBp_CalculateAGA, header part
** Calcuates API gravity and volume corection factors (VCF)
** Date        Whom      Change description:
** ----------  --------  --------------------------------------
** 07-08-2014  abdulmaw  ECPD-23912: AGA dll needs to be 64 bit. (com.ec.prod.bs.agalib.dll)
** 15-12-2016  shindani  ECPD-41730: Added procedure calcAga3_TestDevice,function calculateTdevFlowDensity and calculateTdevStdDensity to support AGA3 calculation.
** 21-07-2017  shindani  ECPD-43011: Modified procedure calcAga3,calculateStdDensity,calculateFlowDensity to provide support for AGA8 having calculation Method 1.
*****************************************************************/

TYPE t_componentName IS TABLE OF VARCHAR2(10);
TYPE t_componentTC IS TABLE OF NUMBER;
TYPE t_componentPC IS TABLE OF NUMBER;
TYPE t_pn_z_array IS VARRAY(21) OF NUMBER;
TYPE t_pn_zcomp_array IS VARRAY(21) OF VARCHAR2(10);
TYPE t_pi_z_cid IS VARRAY(21) OF INT;

FUNCTION calculateFlowDensity(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_static_pressure NUMBER,
   p_temp     NUMBER,
   p_compress NUMBER,
   p_mr NUMBER DEFAULT NULL) RETURN NUMBER;

FUNCTION calculateStdDensity(
   p_object_id  VARCHAR2,
   p_daytime DATE,
   p_pressure NUMBER,
   p_temp     NUMBER,
   p_compress NUMBER,
   p_mr NUMBER DEFAULT NULL) RETURN NUMBER;

FUNCTION calculateTdevFlowDensity(
  p_object_id       VARCHAR2,
  p_daytime         DATE,
  p_static_pressure NUMBER,
  p_temp            NUMBER,
  p_compress        NUMBER,
  p_grs NUMBER DEFAULT NULL,
  p_class_name VARCHAR2 DEFAULT NULL
 ) RETURN NUMBER;

FUNCTION calculateTdevStdDensity(
  p_object_id VARCHAR2,
  p_daytime   DATE,
  p_pressure  NUMBER,
  p_temp      NUMBER,
  p_compress  NUMBER,
  p_grs NUMBER DEFAULT NULL
 ) RETURN NUMBER;

FUNCTION calcExpansionFactor(
   p_tapType   VARCHAR2,
   p_beta   NUMBER,
   p_locationType  NUMBER,
   p_isentropicExp  VARCHAR2,
   p_pressureRatio NUMBER,
   p_aga3IFluid NUMBER) RETURN NUMBER;

FUNCTION calcEv(
   p_beta   NUMBER) RETURN NUMBER;

FUNCTION calcKo(
   p_n_taps VARCHAR2,
   p_beta   NUMBER,
   p_dm     NUMBER,
   p_do     NUMBER) RETURN NUMBER;

FUNCTION calcE(
   p_n_taps VARCHAR2,
   p_beta   NUMBER,
   p_dm     NUMBER,
   p_do NUMBER) RETURN NUMBER;

FUNCTION calcFr(
   p_beta   NUMBER,
   p_diffPressure     NUMBER,
   p_staticPressure NUMBER,
   p_do NUMBER,
   p_e NUMBER) RETURN NUMBER;

FUNCTION calcAga3(
   p_object_id  VARCHAR2,
   p_daytime    DATE,
   p_event_type VARCHAR2,
   p_user VARCHAR2) RETURN NUMBER;

PROCEDURE calculate_AGA(
   p_object_id  VARCHAR2,
   p_daytime    DATE,
   p_event_type VARCHAR2,
   p_user VARCHAR2);

PROCEDURE calculate_all_AGA(
   p_object_id  VARCHAR2,
   p_fromdate DATE,
   p_todate DATE,
   p_event_type VARCHAR2,
   p_user VARCHAR2);

PROCEDURE calcAga3_TestDevice(
  p_result_no VARCHAR2,
  p_phase     VARCHAR2,
  p_object_id VARCHAR2,
  p_daytime   DATE,
  p_user      VARCHAR2);

PROCEDURE calcCompressibility_Detail(
   p_object_id varchar2,
   p_daytime date,
   p_flowing_pressure number,
   p_flowing_Temp number,
   p_base_pressure number,
   p_base_Temp number,
   p_flowing_density out number,
   p_base_density out number,
   p_flowing_compressibility out number,
   p_base_compressibility out number,
   p_error out int);

FUNCTION calcCompressibility_RK(
   p_object_id  VARCHAR2,
   p_daytime    DATE,
   p_pressure NUMBER,
   p_temp NUMBER) RETURN NUMBER;

PROCEDURE calc_z_gross_2(
   p_object_id string,
   p_daytime   date,
   p_flowing_pressure number,
   p_flowing_temperature number,
   p_base_pressure number,
   p_base_temperature number,
   p_spec_grav number,
   p_th number,
   p_n2 number,
   p_co2 number,
   p_h2 number,
   p_co number,
   p_db out number,
   p_zb out number,
   p_df out number,
   p_zf out number,
   p_mr out number
);

PROCEDURE calc_z_gross_1(
   p_object_id string,
   p_daytime   date,
   p_flowing_pressure number,
   p_flowing_temperature number,
   p_base_pressure number,
   p_base_temperature number,
   p_std_pressure NUMBER DEFAULT NULL,
   p_std_temperature NUMBER DEFAULT NULL,
   p_spec_grav number,
   p_th number,
   p_hv number,
   p_n2 number,
   p_co2 number,
   p_h2 number,
   p_co number,
   p_heating_value number,
   p_db out number,
   p_zb out number,
   p_df out number,
   p_zf out number,
   p_mr out number
);

FUNCTION calc_rk_fz(
   p_compressibility NUMBER) RETURN NUMBER;

PROCEDURE calc_charges (
   p_method   IN       int,    --1:use gross caloric,relative density,mole fraction of CO2
                                --2:use relative density and mole fraction of N2 and CO2
                                --option number for selecting the method
   p_hv       IN       number, --Gross calorific heating value for gas mixture in KJ/dm^3 for method 1
   p_gr       IN       number, --Relative density
   p_Xco2     in       number, --the mole faction of CO2, percent
   p_Xn2      in       number, --the mole faction of N2, percent
   p_Xh2      in       number, --the mole faction of H2, percent
   p_Xco      in       number, --the mole faction of CO, percent
   p_th       IN       number, --reference temperature for heating value in kelvin
   p_td       IN       number, --reference temperature for molar density in kelvin
   p_tgr      IN       number, --reference temperature for relative density in kelvin
   p_pd       IN       number, --reference pressure for molar density in Mpa
   p_pgr      IN       number, --reference pressure for relative density in Mpa
   p_xch      out      number, --the mole faction of Ch, percent
   p_n2       out      number, --the mole faction of Ch, percent
   p_zb       out      number, --compressibility factor at 60F and 14.73 psia
   p_db       out      number, --molar density at 60F and 14.73 psia  --Molar density at 60F and 14.73 psia
   p_err      out      int,
   p_mr       out      number  --  Molecular weight of gas mixture.
);

PROCEDURE calc_virgs (
   p_t      IN       number, -- Kelvin
   p_Xch    in       number, --the mole faction of CH, percent
                              --temperature in kelvins
   p_Xco2   in       number, --the mole faction of CO2, percent
   p_Xn2    in       number, --the mole faction of N2, percent
   p_Xh2    in       number, --the mole faction of H2, percent
   p_Xco    in       number, --the mole faction of CO, percent
                              --mole faction
   p_bmix   out      number, --second virial coefficient of the mixture
   p_cmix   out      number, --third virial coefficient of the mixture
   p_bch    IN out   number, --binary ch-ch interaction coefficient
   p_opt    IN       int,    --option number 0: calculate BCH, 1: use BCH input
   p_err    out      int     --Error flag 0:No error,
);

FUNCTION calc_dgross (
   p_p   number,          -- pressure in Mpa
   p_t   number,           -- temperature in kelvin
   p_Xch  number,
   p_Xn2  number,
   p_Xco2 number,
   p_Xh2  number,
   p_Xco  number) RETURN number;

FUNCTION calc_zgross (
   p_d    number,         -- molar density in mol/dm^3
   p_tk   number,
   p_Xch  number,
   p_Xn2  number,
   p_Xco2 number,
   p_Xh2  number,
   p_Xco  number) RETURN number;

FUNCTION calc_pgross (
   p_d   number,          -- Molar density in mol/dm^3
   p_tk  number,
   p_Xch  number,
   p_Xn2  number,
   p_Xco2 number,
   p_Xh2  number,
   p_Xco  number)        -- temperature in kelvin
RETURN number;

FUNCTION calc_z_paramdl(
   p_ncc int,
   p_cid t_pi_z_cid) RETURN int;

PROCEDURE calc_z_chardl(
   p_ncc in int,
   p_xi  in t_pn_z_array,
   p_Tkb in number,
   p_Pb  in number,
   p_zb  out number,
   p_db  out number,
   p_err out int
);

FUNCTION calc_z_ddetail(
   p_p number,            -- Pressure in Mpa
   p_tk number)           -- temperature in kelvins   ,p_bmix number
RETURN number;

PROCEDURE calc_z_Bracket(
   p_p in number,         -- the pressure
   p_tk in number,        -- temperature in kelvins
   p_code out number,
   p_Rho out number,
   p_Rhol out number,
   p_Rhoh out number,
   p_PRhol out number,
   p_PRhoh out number,
   p_err out int
);

FUNCTION calc_z_zdetail(
   p_d number,            -- molar density in mol/dm^3
   p_tk number)           -- temperature in kelvins
RETURN number;

PROCEDURE calc_z_temp(
   p_tk number);

FUNCTION calc_z_Bmix(
   p_tk  number)          -- temperature in kelvins
RETURN number;

FUNCTION calc_z_pdetail(
   p_d number,            -- molar density in mol/dm^3
   p_tk number)           -- temperature in kelvins
RETURN number;

FUNCTION calc_HN(
   p_cid t_pi_z_cid,
   p_x   t_pn_z_array,
   p_ncc int,
   p_Tb  number)          -- Celsius
RETURN number;

END EcBp_CalculateAGA;