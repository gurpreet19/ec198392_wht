CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_DAY_ALLOC_GAS_SUM_YR" ("YR_FIRST_DAY", "YR_GAS_SUM", "OBJECT_ID") AS 
  (
----------------------------------------------------------------------------------------------------------------
--  V_DAY_ALLOC_GAS_SUM_YR
--
-- $Revision: 1.0 $
--
--  Purpose:   For Widget Yearly Top 5 Gas Producers use
--  Note:
--
--  Date           Whom 		  Change description:
--  -------------- --------		-----------------------------------------------------------------------------------
--  2015-11-03     leongwen   ECPD-26570:Intial version
--                            This view will accumulate the alloc_gas_vol for the whole year with the object id
--                            and will be utilized by the view V_DSHBD_FCTY_TOP5_GAS_YR for the widget to show the
--                            Yearly TOP 5 Gas Producers in the facility
-----------------------------------------------------------------------------------------------------------------
SELECT
DISTINCT TRUNC(a.daytime, 'YEAR') AS YR_FIRST_DAY,
ec_pwel_day_alloc.math_alloc_gas_vol(a.object_id, TRUNC(a.daytime, 'YEAR'), (ADD_MONTHS(TRUNC(a.daytime, 'YEAR'), 12) - 1), 'SUM') AS YR_GAS_SUM,
a.object_id AS OBJECT_ID
FROM pwel_day_alloc a
WHERE a.alloc_gas_vol IS NOT NULL
)