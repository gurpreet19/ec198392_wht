CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCTY_SND_DATA" ("DAYTIME", "OBJECT_ID", "SUM_THEOR_GAS", "SUM_THEOR_WAT", "SUM_THEOR_OIL", "SUM_THEOR_COND", "SUM_ALLOC_GAS", "SUM_ALLOC_OIL", "SUM_ALLOC_WAT", "SUM_ALLOC_COND", "FACTOR_OIL", "FACTOR_GAS", "FACTOR_WAT", "FACTOR_COND", "THEOR_OIL_MASS", "THEOR_GAS_MASS", "THEOR_COND_MASS", "THEOR_WAT_MASS", "MASS_FACTOR_OIL", "MASS_FACTOR_GAS", "MASS_FACTOR_WAT", "MASS_FACTOR_COND", "SUM_ALLOC_GAS_MASS", "SUM_ALLOC_OIL_MASS", "SUM_ALLOC_WAT_MASS", "SUM_ALLOC_COND_MASS", "SORT_ORDER", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  SELECT B.DAYTIME                                                                                     DAYTIME
      ,A.OBJECT_ID                                                                                   OBJECT_ID
      ,EcBp_Facility_Theoretical.calcSumOperFacilityGasDay(A.OBJECT_ID,B.DAYTIME)                    SUM_THEOR_GAS
      ,EcBp_Facility_Theoretical.calcSumOperFacilityWatDay(A.OBJECT_ID,B.DAYTIME)                    SUM_THEOR_WAT
      ,EcBp_Facility_Theoretical.calcSumOperFacilityOilDay(A.OBJECT_ID,B.DAYTIME)                    SUM_THEOR_OIL
      ,EcBp_Facility_Theoretical.calcSumOperFacilityCondDay(A.OBJECT_ID,B.DAYTIME)                   SUM_THEOR_COND
      ,EcBp_Alloc_Values.calcSumOperFacilityGasAlloc(A.OBJECT_ID,B.DAYTIME)                          SUM_ALLOC_GAS
      ,EcBp_Alloc_Values.calcSumOperFacilityOilAlloc(A.OBJECT_ID,B.DAYTIME)                          SUM_ALLOC_OIL
      ,EcBp_Alloc_Values.calcSumOperFacilityWatAlloc(A.OBJECT_ID,B.DAYTIME)                          SUM_ALLOC_WAT
      ,EcBp_Alloc_Values.calcSumOperFacilityCondAlloc(A.OBJECT_ID,B.DAYTIME)                         SUM_ALLOC_COND
      ,EcBp_facility_theoretical.getFacilityPhaseFactorDay(A.OBJECT_ID,B.DAYTIME,'OIL')              FACTOR_OIL
      ,EcBp_facility_theoretical.getFacilityPhaseFactorDay(A.OBJECT_ID,B.DAYTIME,'GAS')              FACTOR_GAS
      ,EcBp_facility_theoretical.getFacilityPhaseFactorDay(A.OBJECT_ID,B.DAYTIME,'WATER')            FACTOR_WAT
	  ,EcBp_facility_theoretical.getFacilityPhaseFactorDay(A.OBJECT_ID,B.DAYTIME,'COND')             FACTOR_COND
	  ,EcBp_Facility_Theoretical.calcSumOperFacilityOilMassDay(A.OBJECT_ID,B.DAYTIME)                THEOR_OIL_MASS
      ,EcBp_Facility_Theoretical.calcSumOperFacilityGasMassDay(A.OBJECT_ID,B.DAYTIME)                THEOR_GAS_MASS
      ,EcBp_Facility_Theoretical.calcSumOperFacilityCondMassDay(A.OBJECT_ID,B.DAYTIME)               THEOR_COND_MASS
      ,EcBp_Facility_Theoretical.calcSumOperFacilityWatMassDay(A.OBJECT_ID,B.DAYTIME)                THEOR_WAT_MASS
	  ,EcBp_facility_theoretical.getFacilityMassFactorDay(A.OBJECT_ID,B.DAYTIME,'OIL')               MASS_FACTOR_OIL
      ,EcBp_facility_theoretical.getFacilityMassFactorDay(A.OBJECT_ID,B.DAYTIME,'GAS')               MASS_FACTOR_GAS
      ,EcBp_facility_theoretical.getFacilityMassFactorDay(A.OBJECT_ID,B.DAYTIME,'WATER')             MASS_FACTOR_WAT
	  ,EcBp_facility_theoretical.getFacilityMassFactorDay(A.OBJECT_ID,B.DAYTIME,'COND')              MASS_FACTOR_COND
	  ,EcBp_Alloc_Values.calcSumOperFctyGasMassAlloc(A.OBJECT_ID,B.DAYTIME)                          SUM_ALLOC_GAS_MASS
      ,EcBp_Alloc_Values.calcSumOperFctyOilMassAlloc(A.OBJECT_ID,B.DAYTIME)                          SUM_ALLOC_OIL_MASS
      ,EcBp_Alloc_Values.calcSumOperFctyWatMassAlloc(A.OBJECT_ID,B.DAYTIME)                          SUM_ALLOC_WAT_MASS
      ,EcBp_Alloc_Values.calcSumOperFctyCondMassAlloc(A.OBJECT_ID,B.DAYTIME)                         SUM_ALLOC_COND_MASS
      ,NULL                                                                                          sort_order
      ,NULL                                                                                          record_status
      ,NULL                                                                                          created_by
      ,NULL                                                                                          created_date
      ,NULL                                                                                          last_updated_by
      ,NULL                                                                                          last_updated_date
      ,NULL                                                                                          rev_no
      ,NULL                                                                                          rev_text
 FROM PRODUCTION_FACILITY A, system_days B