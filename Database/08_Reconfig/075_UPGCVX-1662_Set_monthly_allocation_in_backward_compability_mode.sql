-- Set the allocation in backward compability mode
ALTER TABLE calculation_version DISABLE ALL TRIGGERS;
update calculation_version set version_back_compat = 'Y'
where object_id in (select object_id 
                    from calculation 
                    where calc_scope = 'MAIN' 
                    and object_code in 
                    ('CT_DAILY_RESV_MASS',
                     'CT_MONTHLY_RESV_MASS',
                     'CT_WST_DAILY_UPG_MASS_ALLOC',
                     'CT_WST_MONTHLY_UPG_MASS_ALLOC',
                     'LNG_DAILY_MASS_ALLOC',
                     'LNG_MONTHLY_MASS',
                     'WST_PRRT_MONTHLY_ENERGY',
                     'CT_WST_COND_LGU',
                     'CT_WST_LNG_EL',
                     'CT_WST_ADJ_REF_ENTITLEMENT',
                     'CT_WST_COND_PROGRAM',
                     'CT_WST_PC_ALLOWANCE',
                     'CT_WST_RC_REF_ENTITLEMENT',
                     'CT_WST_TANK_TOP_RES',
                     'CT_WST_VALIDATE_SCENARIO',
                     'CT_WST_DGAF',
                     'CT_WST_DGRE',
                     'CT_WST_BL',
                     'CT_CVX_CPP_CUIB_DAY',
                     'CT_CVX_CPP_CUIB_MTH',
                     'CT_CVX_CPP_CU_FIN',
                     'CT_CVX_CPP_CU_IMBAL',
                     'CT_CVX_CPP_EQM',
                     'CT_UBI_CALC',
                     'CT_UBI_DAY_CALC',
                     'CT_UBI_MTH_CALC',
                     'CT_WST_DA_FPS',
                     'CT_WST_DA_NOM',
                     'CT_WST_DGWNE',
                     'CT_WST_PG_ALLOC',
                     'CT_WST_PG_CLOSING',
                     'CT_WST_PG_VAL',
                     'CT_WST_SUB_DAILY',
                     'CT_WST_SUB_DAILY_RRP',
                     'CT_WST_W_FPS'));
ALTER TABLE calculation_version ENABLE ALL TRIGGERS;
