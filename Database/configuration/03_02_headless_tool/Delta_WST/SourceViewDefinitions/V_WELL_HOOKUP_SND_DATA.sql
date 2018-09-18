CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_WELL_HOOKUP_SND_DATA" ("DAYTIME", "OBJECT_ID", "SUM_THEOR_GAS", "SUM_THEOR_WAT", "SUM_THEOR_OIL", "SUM_THEOR_COND", "SUM_ALLOC_GAS", "SUM_ALLOC_OIL", "SUM_ALLOC_WAT", "SUM_ALLOC_COND", "FACTOR_OIL", "FACTOR_GAS", "FACTOR_WAT", "FACTOR_COND", "SUM_ALLOC_OIL_MASS", "SUM_ALLOC_WAT_MASS", "SUM_ALLOC_GAS_MASS", "SUM_ALLOC_COND_MASS", "THEOR_OIL_MASS", "THEOR_GAS_MASS", "THEOR_COND_MASS", "THEOR_WAT_MASS", "MASS_FACTOR_OIL", "MASS_FACTOR_GAS", "MASS_FACTOR_WAT", "MASS_FACTOR_COND", "SORT_ORDER", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  SELECT B.DAYTIME                                                                                     DAYTIME
      ,A.OBJECT_ID                                                                                   OBJECT_ID
      ,EcBp_Well_Hookup_Theoretical.calcSumOperWellHookGasDay(A.OBJECT_ID,B.DAYTIME)                 SUM_THEOR_GAS
      ,EcBp_Well_Hookup_Theoretical.calcSumOperWellHookWatDay(A.OBJECT_ID,B.DAYTIME)                 SUM_THEOR_WAT
      ,EcBp_Well_Hookup_Theoretical.calcSumOperWellHookOilDay(A.OBJECT_ID,B.DAYTIME)                 SUM_THEOR_OIL
      ,EcBp_Well_Hookup_Theoretical.calcSumOperWellHookCondDay(A.OBJECT_ID,B.DAYTIME)                SUM_THEOR_COND
      ,EcBp_Alloc_Values.calcSumOperWellHookGasAlloc(A.OBJECT_ID,B.DAYTIME)                          SUM_ALLOC_GAS
      ,EcBp_Alloc_Values.calcSumOperWellHookOilAlloc(A.OBJECT_ID,B.DAYTIME)                          SUM_ALLOC_OIL
      ,EcBp_Alloc_Values.calcSumOperWellHookWatAlloc(A.OBJECT_ID,B.DAYTIME)                          SUM_ALLOC_WAT
      ,EcBp_Alloc_Values.calcSumOperWellHookCondAlloc(A.OBJECT_ID,B.DAYTIME)                         SUM_ALLOC_COND
      ,EcBp_Well_Hookup_Theoretical.getWellHookPhaseFactorDay(A.OBJECT_ID,B.DAYTIME,'OIL')           FACTOR_OIL
      ,EcBp_Well_Hookup_Theoretical.getWellHookPhaseFactorDay(A.OBJECT_ID,B.DAYTIME,'GAS')           FACTOR_GAS
      ,EcBp_Well_Hookup_Theoretical.getWellHookPhaseFactorDay(A.OBJECT_ID,B.DAYTIME,'WATER')         FACTOR_WAT
	  ,EcBp_Well_Hookup_Theoretical.getWellHookPhaseFactorDay(A.OBJECT_ID,B.DAYTIME,'COND')          FACTOR_COND
	  ,EcDp_Well_Hookup_Alloc.sumWellHookAllocProdMass(A.OBJECT_ID,'NET_OIL_MASS',B.DAYTIME)         SUM_ALLOC_OIL_MASS
	  ,EcDp_Well_Hookup_Alloc.sumWellHookAllocProdMass(A.OBJECT_ID,'WAT_MASS',B.DAYTIME)             SUM_ALLOC_WAT_MASS
	  ,EcDp_Well_Hookup_Alloc.sumWellHookAllocProdMass(A.OBJECT_ID,'GAS_MASS',B.DAYTIME)             SUM_ALLOC_GAS_MASS
	  ,EcDp_Well_Hookup_Alloc.sumWellHookAllocProdMass(A.OBJECT_ID,'COND_MASS',B.DAYTIME)            SUM_ALLOC_COND_MASS
	  ,EcBp_Well_Hookup_Theoretical.calcSumOperWellHookOilMassDay(A.OBJECT_ID,B.DAYTIME)             THEOR_OIL_MASS
      ,EcBp_Well_Hookup_Theoretical.calcSumOperWellHookGasMassDay(A.OBJECT_ID,B.DAYTIME)             THEOR_GAS_MASS
      ,EcBp_Well_Hookup_Theoretical.calcSumOperWellHookCondMassDay(A.OBJECT_ID,B.DAYTIME)            THEOR_COND_MASS
      ,EcBp_Well_Hookup_Theoretical.calcSumOperWellHookWatMassDay(A.OBJECT_ID,B.DAYTIME)             THEOR_WAT_MASS
	  ,EcBp_Well_Hookup_Theoretical.getWellHookPhaseMassFactorDay(A.OBJECT_ID,B.DAYTIME,'OIL')       MASS_FACTOR_OIL
      ,EcBp_Well_Hookup_Theoretical.getWellHookPhaseMassFactorDay(A.OBJECT_ID,B.DAYTIME,'GAS')       MASS_FACTOR_GAS
      ,EcBp_Well_Hookup_Theoretical.getWellHookPhaseMassFactorDay(A.OBJECT_ID,B.DAYTIME,'WATER')     MASS_FACTOR_WAT
	  ,EcBp_Well_Hookup_Theoretical.getWellHookPhaseMassFactorDay(A.OBJECT_ID,B.DAYTIME,'COND')      MASS_FACTOR_COND
      ,NULL                                                                                          sort_order
      ,NULL                                                                                          record_status
      ,NULL                                                                                          created_by
      ,NULL                                                                                          created_date
      ,NULL                                                                                          last_updated_by
      ,NULL                                                                                          last_updated_date
      ,NULL                                                                                          rev_no
      ,NULL                                                                                          rev_text
 FROM Well_hookup A, system_days B