CREATE OR REPLACE FORCE VIEW "V_PVT_SIM" ("RESULT_NO", "PVTSIM_FIELD_MODE", "PVTSIM_UNIT_TYPE", "EXPORT_PRESS", "EXPORT_TEMP", "EXPORT_GAS_SHRINK", "MPM_OIL_MASS_RATE", "MPM_GAS_MASS_RATE", "MPM_TEMP", "MPM_PRESS", "MPM_OIL_CORR_FACTOR", "MPM_GAS_CORR_FACTOR", "MPM_COMP_ADJ_IND", "DEF_PNLX_CORR_FACTOR", "PSD_PNLX_CORR_FACTOR", "GAS_INJ_MODE", "RES_PRESS_MAX", "RES_PRESS_MIN", "RESERVOIR_PRESS", "RESERVOIR_TEMP", "MPM_CONDUCT", "MPM_CONDUCT_TEMP", "NET_STD_MASS", "SEP_MODE", "WATER_SAT_IND", "SAT_PRESS_GAS", "SAT_TEMP_GAS", "SAT_PRESS_OIL", "SAT_TEMP_OIL", "N2_KFACTOR", "CO2_KFACTOR", "H2S_KFACTOR", "C1_KFACTOR", "C2_KFACTOR", "C3_KFACTOR", "IC4_KFACTOR", "NC4_KFACTOR", "IC5_KFACTOR", "NC5_KFACTOR", "C6_KFACTOR", "C7_KFACTOR", "C8_KFACTOR", "C9_KFACTOR", "C10_KFACTOR", "STAGE1_PRESS", "STAGE2_PRESS", "STAGE3_PRESS", "STAGE4_PRESS", "STAGE5_PRESS", "STAGE6_PRESS", "STAGE7_PRESS", "STAGE8_PRESS", "STAGE1_TEMP", "STAGE2_TEMP", "STAGE3_TEMP", "STAGE4_TEMP", "STAGE5_TEMP", "STAGE6_TEMP", "STAGE7_TEMP", "STAGE8_TEMP", "GAS_MASS_RATE_FLC", "NET_OIL_MASS_RATE_FLC", "GAS_DENSITY_FLC", "NET_OIL_DENSITY_FLC", "TDEV_PRESS", "TDEV_TEMP", "DENS_TOLERANCE", "GOR_TOLERANCE", "COMP_ADJ_IND", "OIL_DENS_CORR_IND", "GAS_DENS_CORR_IND", "INJGAS_STREAM_ID", "C4_KFACTOR", "C5_KFACTOR", "NEOC5_KFACTOR", "C5PL_KFACTOR", "C6PL_KFACTOR", "C7PL_KFACTOR", "C8PL_KFACTOR", "C9PL_KFACTOR", "C10PL_KFACTOR", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_STATE", "APPROVAL_BY", "APPROVAL_DATE", "REC_ID") AS 
  select
       eqr.result_no
      ,eqr.pvtsim_field_mode
      ,eqr.pvtsim_unit_type
      ,ptrain.export_press
      ,ptrain.export_temp
      ,eqr.export_gas_shrink
      ,eqr.mpm_oil_mass_rate
      ,eqr.mpm_gas_mass_rate
      ,eqr.mpm_temp
      ,eqr.mpm_press
      ,Ec_Eqpm_Version.mpm_oil_corr_factor(eqr.object_id, ptr.daytime, '<=') AS mpm_oil_corr_factor
      ,Ec_Eqpm_Version.mpm_gas_corr_factor(eqr.object_id, ptr.daytime, '<=') AS mpm_gas_corr_factor
      ,Ec_Eqpm_Version.mpm_comp_adj_ind(eqr.object_id, ptr.daytime, '<=') AS mpm_comp_adj_ind
      ,Ec_Eqpm_Version.def_pnlx_corr_factor(eqr.object_id, ptr.daytime, '<=') AS def_pnlx_corr_factor
      ,Ec_Eqpm_Version.psd_pnlx_corr_factor(eqr.object_id, ptr.daytime, '<=') AS psd_pnlx_corr_factor
      ,Ec_Rbf_Version.gas_inj_ind(pei.resv_block_formation_id, ptr.daytime, '<=') AS gas_inj_mode
      ,Ec_Rbf_Version.res_press_max(pei.resv_block_formation_id, ptr.daytime, '<=') AS res_press_max
      ,Ec_Rbf_Version.res_press_min(pei.resv_block_formation_id, ptr.daytime, '<=') AS res_press_min
      ,Ec_Rbf_Version.reservoir_press(pei.resv_block_formation_id, ptr.daytime, '<=') AS reservoir_press
      ,Ec_Rbf_Version.reservoir_temp(pei.resv_block_formation_id, ptr.daytime, '<=') AS reservoir_temp
      ,eqr.mpm_conduct
      ,eqr.mpm_conduct_temp
      ,EcBp_Stream_Fluid.FindNetStdMass((ptrain.hc_feed_stream_id) ,trunc(ptr.daytime,'DD')) AS NET_STD_MASS
      ,ptrain.sep_mode AS sep_mode
      ,ptrain.water_sat_ind AS water_sat_ind
      ,ptrain.sat_press_gas AS sat_press_gas
      ,ptrain.sat_temp_gas AS sat_temp_gas
      ,ptrain.sat_press_oil AS sat_press_oil
      ,ptrain.sat_temp_oil AS sat_temp_oil
      ,ptrain.n2_kfactor AS n2_kfactor
      ,ptrain.co2_kfactor AS co2_kfactor
      ,ptrain.h2s_kfactor AS h2s_kfactor
      ,ptrain.c1_kfactor AS c1_kfactor
      ,ptrain.c2_kfactor AS c2_kfactor
      ,ptrain.c3_kfactor AS c3_kfactor
      ,ptrain.ic4_kfactor AS ic4_kfactor
      ,ptrain.nc4_kfactor AS nc4_kfactor
      ,ptrain.ic5_kfactor AS ic5_kfactor
      ,ptrain.nc5_kfactor AS nc5_kfactor
      ,ptrain.c6_kfactor AS c6_kfactor
      ,ptrain.c7_kfactor AS c7_kfactor
      ,ptrain.c8_kfactor AS c8_kfactor
      ,ptrain.c9_kfactor AS c9_kfactor
      ,ptrain.c10_kfactor AS c10_kfactor
      ,ptrain.stage1_press AS stage1_press
      ,ptrain.stage2_press AS stage2_press
      ,ptrain.stage3_press AS stage3_press
      ,ptrain.stage4_press AS stage4_press
      ,ptrain.stage5_press AS stage5_press
      ,ptrain.stage6_press AS stage6_press
      ,ptrain.stage7_press AS stage7_press
      ,ptrain.stage8_press AS stage8_press
      ,ptrain.stage1_temp AS stage1_temp
      ,ptrain.stage2_temp AS stage2_temp
      ,ptrain.stage3_temp AS stage3_temp
      ,ptrain.stage4_temp AS stage4_temp
      ,ptrain.stage5_temp AS stage5_temp
      ,ptrain.stage6_temp AS stage6_temp
      ,ptrain.stage7_temp AS stage7_temp
      ,ptrain.stage8_temp AS stage8_temp
      ,eqr.gas_mass_rate_flc
      ,eqr.net_oil_mass_rate_flc
      ,eqr.gas_density_flc
      ,eqr.net_oil_density_flc
      ,eqr.tdev_press
      ,eqr.tdev_temp
      ,Ec_Eqpm_Version.dens_tolerance(eqr.object_id, ptr.daytime, '<=') AS dens_tolerance
      ,Ec_Eqpm_Version.gor_tolerance(eqr.object_id, ptr.daytime, '<=') AS gor_tolerance
      ,Ec_Eqpm_Version.comp_adj_ind(eqr.object_id, ptr.daytime, '<=') AS comp_adj_ind
      ,Ec_Eqpm_Version.oil_dens_corr_ind(eqr.object_id, ptr.daytime, '<=') AS oil_dens_corr_ind
      ,Ec_Eqpm_Version.gas_dens_corr_ind(eqr.object_id, ptr.daytime, '<=') AS gas_dens_corr_ind
      ,Ec_fcty_version.injgas_stream_id(eq.prod_fcty_id, ptr.daytime, '<=') AS injgas_stream_id
      ,ptrain.c4_kfactor AS c4_kfactor
      ,ptrain.c5_kfactor AS c5_kfactor
      ,ptrain.neoc5_kfactor AS neoc5_kfactor
      ,ptrain.c5pl_kfactor AS c5pl_kfactor
      ,ptrain.c6pl_kfactor AS c6pl_kfactor
      ,ptrain.c7pl_kfactor AS c7pl_kfactor
      ,ptrain.c8pl_kfactor AS c8pl_kfactor
      ,ptrain.c9pl_kfactor AS c9pl_kfactor
      ,ptrain.c10pl_kfactor AS c10pl_kfactor
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
from      eqpm_result eqr
        , eqpm_version eqv
        , ptst_result ptr
        , pwel_result pwr
        , well_version wv
        , webo_bore web
        , webo_interval wei
        , perf_interval pei
        , equipment eq
        , process_train_version ptrain
where eqr.object_id = eqv.object_id
    and eqr.result_no = ptr.result_no
    and ptr.result_no = pwr.result_no
    and pwr.object_id = wv.object_id
    and ptr.daytime >= wv.daytime and ptr.daytime < nvl(wv.end_date, ptr.daytime+1)
    and wv.process_train_id = ptrain.object_id
    and ptr.daytime >= ptrain.daytime and ptr.daytime < nvl(ptrain.end_date,  ptr.daytime+1)
    and wv.object_id = web.well_id  (+)
    and web.object_id = wei.well_bore_id (+)
    and wei.object_id = pei.webo_interval_id (+)
    and eqv.object_id = eq.object_id (+)