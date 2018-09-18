CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_DAY_ALLOC_GAS_SUM_MTH" ("MTH_FIRST_DAY", "MTH_GAS_SUM", "OBJECT_ID") AS 
  (
----------------------------------------------------------------------------------------------------------------
--  V_DAY_ALLOC_GAS_SUM_MTH
--
-- $Revision: 1.0 $
--
--  Purpose:   For Widget Monthly Top 5 Gas Producers use
--  Note:
--
--  Date           Whom 		  Change description:
--  -------------- --------		-----------------------------------------------------------------------------------
--  2015-10-30     leongwen   ECPD-26570:Intial version
--                            This view will accumulate the alloc_gas_vol for the whole month with the object id
--                            and will be utilized by the view V_DSHBD_FCTY_T5_GAS_MTH for the widget to show the
--                            Monthly TOP 5 Gas Producers in the facility
-----------------------------------------------------------------------------------------------------------------
SELECT
DISTINCT TRUNC(a.daytime, 'MONTH') AS MTH_FIRST_DAY,
ec_pwel_day_alloc.math_alloc_gas_vol(a.object_id, TRUNC(a.daytime, 'MONTH'), (ADD_MONTHS(TRUNC(a.daytime, 'MONTH'),1) - 1), 'SUM') AS MTH_GAS_SUM,
a.object_id AS OBJECT_ID
FROM pwel_day_alloc a
WHERE a.alloc_gas_vol IS NOT NULL
)