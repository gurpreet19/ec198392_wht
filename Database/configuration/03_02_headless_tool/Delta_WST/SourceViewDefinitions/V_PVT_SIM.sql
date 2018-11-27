CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_PVT_SIM" ("RESULT_NO", "PVTSIM_FIELD_MODE", "PVTSIM_UNIT_TYPE", "NET_COND_MASS_RATE_FLC", "NET_COND_DENSITY_FLC", "EXPORT_PRESS", "EXPORT_TEMP", "EXPORT_GAS_SHRINK", "MPM_OIL_MASS_RATE", "MPM_GAS_MASS_RATE", "MPM_TEMP", "MPM_PRESS", "MPM_OIL_CORR_FACTOR", "MPM_GAS_CORR_FACTOR", "MPM_COMP_ADJ_IND", "DEF_PNLX_CORR_FACTOR", "PSD_PNLX_CORR_FACTOR", "GAS_INJ_MODE", "RES_PRESS_MAX", "RES_PRESS_MIN", "RESERVOIR_PRESS", "RESERVOIR_TEMP", "MPM_CONDUCT", "MPM_CONDUCT_TEMP", "NET_STD_MASS", "SEP_MODE", "WATER_SAT_IND", "SAT_PRESS_GAS", "SAT_TEMP_GAS", "SAT_PRESS_OIL", "SAT_TEMP_OIL", "N2_KFACTOR", "CO2_KFACTOR", "H2S_KFACTOR", "C1_KFACTOR", "C2_KFACTOR", "C3_KFACTOR", "IC4_KFACTOR", "NC4_KFACTOR", "IC5_KFACTOR", "NC5_KFACTOR", "C6_KFACTOR", "C7_KFACTOR", "C8_KFACTOR", "C9_KFACTOR", "C10_KFACTOR", "STAGE1_PRESS", "STAGE2_PRESS", "STAGE3_PRESS", "STAGE4_PRESS", "STAGE5_PRESS", "STAGE6_PRESS", "STAGE7_PRESS", "STAGE8_PRESS", "STAGE1_TEMP", "STAGE2_TEMP", "STAGE3_TEMP", "STAGE4_TEMP", "STAGE5_TEMP", "STAGE6_TEMP", "STAGE7_TEMP", "STAGE8_TEMP", "GAS_MASS_RATE_FLC", "NET_OIL_MASS_RATE_FLC", "GAS_DENSITY_FLC", "NET_OIL_DENSITY_FLC", "TDEV_PRESS", "TDEV_TEMP", "DENS_TOLERANCE", "GOR_TOLERANCE", "COMP_ADJ_IND", "OIL_DENS_CORR_IND", "GAS_DENS_CORR_IND", "INJGAS_STREAM_ID", "C4_KFACTOR", "C5_KFACTOR", "NEOC5_KFACTOR", "C5PL_KFACTOR", "C6PL_KFACTOR", "C7PL_KFACTOR", "C8PL_KFACTOR", "C9PL_KFACTOR", "C10PL_KFACTOR", "P01_KFACTOR", "P02_KFACTOR", "P03_KFACTOR", "P04_KFACTOR", "P05_KFACTOR", "P06_KFACTOR", "P07_KFACTOR", "P08_KFACTOR", "P09_KFACTOR", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_STATE", "APPROVAL_BY", "APPROVAL_DATE", "REC_ID") AS 
  select
       tdr.result_no
      ,NVL (ptrain.pvtsim_field_mode,-1E16) AS pvtsim_field_mode
      ,NVL (tdv.pvtsim_unit_type, -1E16) AS pvtsim_unit_type
      ,NVL (tdr.net_cond_mass_rate_flc, -1E16) AS net_cond_mass_rate_flc
      ,NVL (tdr.net_cond_density_flc, -1E16) AS net_cond_density_flc
      ,NVL (ptrain.export_press, -1E16) AS export_press
      ,NVL (ptrain.export_temp, -1E16) AS export_temp
      ,NVL (tdr.export_gas_shrink, -1E16) AS export_gas_shrink
      ,NVL (tdr.mpm_oil_mass_rate, -1E16) AS mpm_oil_mass_rate
      ,NVL (tdr.mpm_gas_mass_rate, -1E16) AS mpm_gas_mass_rate
      ,NVL (tdr.mpm_temp, -1E16) AS mpm_temp
      ,NVL (tdr.mpm_press, -1E16) AS mpm_press
      ,NVL (Ec_test_device_version.mpm_oil_corr_factor(tdr.object_id, ptr.daytime, '<='), -1E16) AS mpm_oil_corr_factor
      ,NVL (Ec_test_device_version.mpm_gas_corr_factor(tdr.object_id, ptr.daytime, '<='), -1E16) AS mpm_gas_corr_factor
      ,NVL (Ec_test_device_version.mpm_comp_adj_ind(tdr.object_id, ptr.daytime, '<='), -1000) AS mpm_comp_adj_ind
      ,NVL (Ec_test_device_version.def_pnlx_corr_factor(tdr.object_id, ptr.daytime, '<='), -1E16) AS def_pnlx_corr_factor
      ,NVL (Ec_test_device_version.psd_pnlx_corr_factor(tdr.object_id, ptr.daytime, '<='), -1E16) AS psd_pnlx_corr_factor
      ,NVL (Ec_Rbf_Version.gas_inj_ind(ec_perf_interval_version.resv_block_formation_id(pei.object_id, ptr.daytime, '<='), ptr.daytime, '<='), -1000) AS gas_inj_mode
      ,NVL (Ec_Rbf_Version.res_press_max(ec_perf_interval_version.resv_block_formation_id(pei.object_id, ptr.daytime, '<='), ptr.daytime, '<='), -1E16) AS res_press_max
      ,NVL (Ec_Rbf_Version.res_press_min(ec_perf_interval_version.resv_block_formation_id(pei.object_id, ptr.daytime, '<='), ptr.daytime, '<='), -1E16) AS res_press_min
      ,NVL (Ec_Rbf_Version.reservoir_press(ec_perf_interval_version.resv_block_formation_id(pei.object_id, ptr.daytime, '<='), ptr.daytime, '<='), -1E16) AS reservoir_press
      ,NVL (Ec_Rbf_Version.reservoir_temp(ec_perf_interval_version.resv_block_formation_id(pei.object_id, ptr.daytime, '<='), ptr.daytime, '<='), -1E16) AS reservoir_temp
      ,NVL (tdr.mpm_conduct, -1E16) AS mpm_conduct
      ,NVL (tdr.mpm_conduct_temp, -1E16) AS mpm_conduct_temp
      ,NVL ( ( (tdr.net_cond_mass_rate_flc + tdr.gas_mass_rate_flc) / 24), -1E16) AS NET_STD_MASS
      ,NVL (ptrain.sep_mode, -1000) AS sep_mode
      ,NVL (ptrain.water_sat_ind, -1000) AS water_sat_ind
      ,NVL (ptrain.sat_press_gas, -1E16) AS sat_press_gas
      ,NVL (ptrain.sat_temp_gas, -1E16) AS sat_temp_gas
      ,NVL (ptrain.sat_press_oil, -1E16) AS sat_press_oil
      ,NVL (ptrain.sat_temp_oil, -1E16) AS sat_temp_oil
      ,NVL (ptrain.n2_kfactor, -1E16) AS n2_kfactor
      ,NVL (ptrain.co2_kfactor, -1E16) AS co2_kfactor
      ,NVL (ptrain.h2s_kfactor, -1E16) AS h2s_kfactor
      ,NVL (ptrain.c1_kfactor, -1E16) AS c1_kfactor
      ,NVL (ptrain.c2_kfactor, -1E16) AS c2_kfactor
      ,NVL (ptrain.c3_kfactor, -1E16) AS c3_kfactor
      ,NVL (ptrain.ic4_kfactor, -1E16) AS ic4_kfactor
      ,NVL (ptrain.nc4_kfactor, -1E16) AS nc4_kfactor
      ,NVL (ptrain.ic5_kfactor, -1E16) AS ic5_kfactor
      ,NVL (ptrain.nc5_kfactor, -1E16) AS nc5_kfactor
      ,NVL (ptrain.c6_kfactor, -1E16) AS c6_kfactor
      ,NVL (ptrain.c7_kfactor, -1E16) AS c7_kfactor
      ,NVL (ptrain.c8_kfactor, -1E16) AS c8_kfactor
      ,NVL (ptrain.c9_kfactor, -1E16) AS c9_kfactor
      ,NVL (ptrain.c10_kfactor, -1E16) AS c10_kfactor
      ,NVL (DECODE (ptrain.pvtsim_field_mode, 9, ptrain.stage1_press, tdr.tdev_press), -1E16) AS stage1_press
      ,NVL (ptrain.stage2_press, -1E16) AS stage2_press
      ,NVL (ptrain.stage3_press, -1E16) AS stage3_press
      ,NVL (ptrain.stage4_press, -1E16) AS stage4_press
      ,NVL (ptrain.stage5_press, -1E16) AS stage5_press
      ,NVL (ptrain.stage6_press, -1E16) AS stage6_press
      ,NVL (ptrain.stage7_press, -1E16) AS stage7_press
      ,NVL (ptrain.stage8_press, -1E16) AS stage8_press
      ,NVL (DECODE (ptrain.pvtsim_field_mode, 9, ptrain.stage1_temp, tdr.tdev_temp), -1E16) AS stage1_temp
      ,NVL (ptrain.stage2_temp, -1E16) AS stage2_temp
      ,NVL (ptrain.stage3_temp, -1E16) AS stage3_temp
      ,NVL (ptrain.stage4_temp, -1E16) AS stage4_temp
      ,NVL (ptrain.stage5_temp, -1E16) AS stage5_temp
      ,NVL (ptrain.stage6_temp, -1E16) AS stage6_temp
      ,NVL (ptrain.stage7_temp, -1E16) AS stage7_temp
      ,NVL (ptrain.stage8_temp, -1E16) AS stage8_temp
      ,NVL ( (tdr.gas_mass_rate_flc / 24), -1E16) AS gas_mass_rate_flc
      ,NVL ( (tdr.net_cond_mass_rate_flc / 24), -1E16) AS net_oil_mass_rate_flc
      ,NVL ( (tdr.gas_density_flc / 1000), -1E16) AS gas_density_flc
      ,NVL ( (NVL(tdr.net_oil_density_flc,tdr.net_cond_density_flc) / 1000), -1E16) AS net_oil_density_flc
      ,NVL (tdr.tdev_press, -1E16) AS tdev_press
      ,NVL (tdr.tdev_temp, -1E16) AS tdev_temp
      ,NVL (Ec_test_device_version.dens_tolerance(tdr.object_id, ptr.daytime, '<='), -1E16) AS dens_tolerance
      ,NVL (Ec_test_device_version.gor_tolerance(tdr.object_id, ptr.daytime, '<='), -1E16) AS gor_tolerance
      ,NVL (Ec_test_device_version.comp_adj_ind(tdr.object_id, ptr.daytime, '<='), -1000) AS comp_adj_ind
      ,NVL (Ec_test_device_version.oil_dens_corr_ind(tdr.object_id, ptr.daytime, '<='), -1000) AS oil_dens_corr_ind
      ,NVL (Ec_test_device_version.gas_dens_corr_ind(tdr.object_id, ptr.daytime, '<='), -1000) AS gas_dens_corr_ind
      ,Ec_fcty_version.injgas_stream_id(td.prod_fcty_id, ptr.daytime, '<=') AS injgas_stream_id
      ,NVL (ptrain.c4_kfactor, -1E16) AS c4_kfactor
      ,NVL (ptrain.c5_kfactor, -1E16) AS c5_kfactor
      ,NVL (ptrain.neoc5_kfactor, -1E16) AS neoc5_kfactor
      ,NVL (ptrain.c5pl_kfactor, -1E16) AS c5pl_kfactor
      ,NVL (ptrain.c6pl_kfactor, -1E16) AS c6pl_kfactor
      ,NVL (ptrain.c7pl_kfactor, -1E16) AS c7pl_kfactor
      ,NVL (ptrain.c8pl_kfactor, -1E16) AS c8pl_kfactor
      ,NVL (ptrain.c9pl_kfactor, -1E16) AS c9pl_kfactor
      ,NVL (ptrain.c10pl_kfactor, -1E16) AS c10pl_kfactor
      ,NVL (ptrain.p01_kfactor, -1E16) AS p01_kfactor
      ,NVL (ptrain.p02_kfactor, -1E16) AS p02_kfactor
      ,NVL (ptrain.p03_kfactor, -1E16) AS p03_kfactor
      ,NVL (ptrain.p04_kfactor, -1E16) AS p04_kfactor
      ,NVL (ptrain.p05_kfactor, -1E16) AS p05_kfactor
      ,NVL (ptrain.p06_kfactor, -1E16) AS p06_kfactor
      ,NVL (ptrain.p07_kfactor, -1E16) AS p07_kfactor
      ,NVL (ptrain.p08_kfactor, -1E16) AS p08_kfactor
      ,NVL (ptrain.p09_kfactor, -1E16) AS p09_kfactor
      ,NULL AS RECORD_STATUS
      ,NULL AS CREATED_BY
      ,NULL AS CREATED_DATE
      ,NULL AS LAST_UPDATED_BY
      ,NULL AS LAST_UPDATED_DATE
      ,NULL AS REV_NO
      ,NULL AS REV_TEXT
      ,NULL AS APPROVAL_STATE
      ,NULL AS APPROVAL_BY
      ,NULL AS APPROVAL_DATE
      ,NULL AS REC_ID
from      test_device_result tdr
        , test_device_version tdv
        , ptst_result ptr
        , pwel_result pwr
        , well_version wv
        , webo_bore web
        , webo_interval wei
        , perf_interval pei
        , test_device td
        , process_train_version ptrain
where tdr.object_id = tdv.object_id
    and tdr.daytime >= tdv.daytime AND tdr.daytime < Nvl(tdv.end_date, tdr.daytime + 1)
    and tdr.result_no = ptr.result_no
    and ptr.result_no = pwr.result_no
    and pwr.object_id = wv.object_id
    and ptr.daytime >= wv.daytime and ptr.daytime < nvl(wv.end_date, ptr.daytime+1)
    and wv.process_train_id = ptrain.object_id
    and ptr.daytime >= ptrain.daytime and ptr.daytime < nvl(ptrain.end_date,  ptr.daytime+1)
    and wv.object_id = web.well_id  (+)
    and (web.well_id is null OR (web.well_id is not null and tdr.daytime >= web.start_date AND tdr.daytime < Nvl(web.end_date, tdr.daytime + 1)))
    and web.object_id = wei.well_bore_id (+)
    and (wei.well_bore_id is null OR (wei.well_bore_id is not null and tdr.daytime >= wei.start_date AND tdr.daytime < Nvl(wei.end_date, tdr.daytime + 1)))
    and wei.object_id = pei.webo_interval_id (+)
  	and (pei.webo_interval_id is null OR (pei.webo_interval_id is not null and tdr.daytime >= pei.start_date AND tdr.daytime < Nvl(pei.end_date, tdr.daytime + 1)))
    and tdv.object_id = td.object_id (+)