---------------------------------------------------------------------------------------------------
--  CV_PWEL_MTH_ALLOC_RBF
--
--  Purpose:           	Provides Reservoir Block Formation detail with PWEL_MTH_ALLOC data; 
--            		Provides break down of allocated production volumes to the formation using 
--            		split factor percentages and interval split percentages
--
--
--  Notes:
--
--   	MVAS 05/2008 	9.3
--      HNKO 07/2008    Added 9.3 Version Tables.
--
----------------------------------------------------------------------------------------------------- 


CREATE OR REPLACE VIEW CV_PWEL_MTH_ALLOC_RBF
AS
SELECT 
    A.object_id as object_id, 
    A.daytime, 
    prod_days, 
    A.value_1 as operating_days,
    on_stream_hrs, 
    alloc_net_oil_vol, 
    alloc_gas_vol, 
    alloc_cond_vol, 
    alloc_water_vol, 
    alloc_net_oil_mass, 
    alloc_net_gas_vol, 
    alloc_net_gas_mass, 
    alloc_gas_mass, 
    alloc_cond_mass, 
    alloc_water_mass, 
    alloc_gl_vol, 
    alloc_diluent_vol, 
    theor_net_oil_rate, 
    theor_gas_rate, 
    theor_cond_rate, 
    theor_water_rate, 
    theor_gas_mass, 
    theor_net_oil_mass, 
    theor_cond_mass, 
    theor_water_mass, 
    theor_gl_rate, 
    theor_diluent_rate, 
    net_oil_vol_factor, 
    gas_vol_factor, 
    cond_vol_factor, 
    water_vol_factor, 
    gl_vol_factor, 
    diluent_vol_factor, 
    net_oil_mass_factor, 
    gas_mass_factor, 
    cond_mass_factor, 
    water_mass_factor, 
    load_oil_cl_acc_grs_mass, 
    load_oil_cl_acc_net_mass, 
    load_oil_prod_grs_mass, 
    load_oil_prod_net_mass, 
    load_oil_rcv_grs_mass, 
    load_oil_rcv_net_mass, 
    load_water_closing_acc, 
    load_water_prod, 
    load_water_received, 
    WB.OBJECT_ID AS WELL_BORE_ID,
    WB.OBJECT_CODE AS WELL_BORE_CODE, 
    WBI.OBJECT_ID AS WELL_BORE_INTERVAL_ID,
    WBI.OBJECT_CODE AS WELL_BORE_INTERVAL_CODE, 
    PI.OBJECT_ID AS PERF_INTERVAL_ID,
    PI.OBJECT_CODE AS PERF_INTERVAL_CODE,
    PIV.RESV_BLOCK_FORMATION_ID AS RESV_BLOCK_FORMATION_ID, -- Added this join cause 111 moved the resv_block_formation_id from perf_interval to perf_interval_version
    A.RECORD_STATUS AS RECORD_STATUS,
    A.CREATED_BY AS CREATED_BY,
    A.CREATED_DATE AS CREATED_DATE,
    A.LAST_UPDATED_BY AS LAST_UPDATED_BY,
    A.LAST_UPDATED_DATE AS LAST_UPDATED_DATE,
    A.REV_NO AS REV_NO,
    A.REV_TEXT AS REV_TEXT
FROM 
    PWEL_MTH_ALLOC A,
    WEBO_BORE WB,
    WEBO_VERSION WBV, 
    WEBO_INTERVAL WBI,
    WEBO_INTERVAL_VERSION WBIV,
    PERF_INTERVAL PI,
    PERF_INTERVAL_VERSION PIV
WHERE
-- must use MIN or MAX in case there are multiple version records in the db for the month
-- if MIN or MAX not used, may result in duplicate records 
-- WELL_BORE
A.OBJECT_ID = WB.WELL_ID AND	
WB.OBJECT_ID = WBV.OBJECT_ID AND
  	A.DAYTIME >= TRUNC(WBV.DAYTIME,'MONTH') AND
        WBV.DAYTIME =
               (SELECT MIN (daytime)
                  FROM webo_version wbv1
                 WHERE wbv1.object_id = WBV.object_id
                   AND A.DAYTIME >= TRUNC(wbv1.daytime,'MONTH')
		   AND A.DAYTIME < NVL(wbv1.end_date,A.daytime+1)) AND
-- WELL_BORE_INTERVAL
  	WB.OBJECT_ID = WBI.WELL_BORE_ID AND 
	WBI.OBJECT_ID = WBIV.OBJECT_ID AND 
  	A.DAYTIME >= TRUNC(WBIV.DAYTIME,'MONTH') AND
        WBIV.DAYTIME =
               (SELECT MIN (daytime)
                  FROM webo_interval_version wbiv1
                 WHERE wbiv1.object_id = WBIV.object_id
                   AND A.DAYTIME >= TRUNC(wbiv1.daytime,'MONTH')
		   AND A.DAYTIME < NVL(wbiv1.end_date,A.daytime+1)) AND
-- PERF_INTERVAL
  	WBI.OBJECT_ID = PI.WEBO_INTERVAL_ID AND 
	PI.OBJECT_ID = PIV.OBJECT_ID AND 
  	A.DAYTIME >= TRUNC(PIV.DAYTIME,'MONTH') AND
        PIV.DAYTIME =
               (SELECT MIN (daytime)
                  FROM perf_interval_version piv1
                 WHERE piv1.object_id = PIV.object_id
                   AND A.DAYTIME >= TRUNC(piv1.daytime,'MONTH')
		   AND A.DAYTIME < NVL(piv1.end_date,A.daytime+1));
