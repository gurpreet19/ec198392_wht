CREATE OR REPLACE PACKAGE BODY ue_Nomination IS
/******************************************************************************
** Package        :  ue_Nomination, body part
**
** $Revision: 1.35 $
**
** Purpose        :  Business logic for nominations
**
** Documentation  :  www.energy-components.com
**
** Created        :  05.03.2008 Kari Sandvik
**
** Modification history:
**
** Date        Whom  		  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
** 25.04.2012  leeeewei       ECPD-19477: Added function getOperParam
** 14.04.2012  leeeewei       ECPD-19477: Added function getSchedQty and getNominatedQty
** 13.06.2012  sharawan		  ECPD-19476: Added function getCapacityUOM
** 12.12.2013  farhaann	      ECPD-26073: Added function getTotalSchedInOutQtyPrBU and getTotalReqTransfInOutQtyPrBU
** 05.02.2014  leeeewei		  ECPD-26615: Added function getInputNominatedQty and getOutputNominatedQty
** 26.03.2014  chooysie		  ECPD-27059: Updated function getClassUniqueKey to add 'TRNP_SUB_DAY_LOC_MATRIX'
** 08.05.2014  chooysie		  ECPD-27225: Added function setFactorsEndDate and updateFactorsEndDate
** 28.05.2014  leeeewei		  ECPD-27029: Modified function getClassUniqueKey - enabled trending for all classes which using this function
** 10.06.2014  leeeewei		  ECPD-27452: Modified function getClassUniqueKey - class relation
** 21.10.2014  muhammah		  ECPD-28460: Added nomination cycle as parameter to getMatrixReceipt, getMatrixDelivery, getMatrixInventory
** 06.02.2015  hassakha		  ECPD-29477: Added FORECAST_ID, SERIES inside getClassUniqueKey
** 27.05.2015  asareswi		  ECPD-27052: Added p_nomination_seq as a parameter to the function getSchedQty, getNominatedQty, getInputNominatedQty, getOutputNominatedQty. Changed the where condition of the cursor query. Filtering data based on nomination_seq instead of object_id, daytime, summer_time, class_name.
** 17-06-2015  asareswi		  ECPD-27052: Removed all the IF, ELSE condition from the function getClassUniqueKey.
********************************************************************/

/** Cursors used by delivery point functions*/
 CURSOR c_input_nom (cp_delpnt_id VARCHAR2, cp_nom_cycle VARCHAR, cp_daytime DATE) IS
 --Aggregate input nominations for delivery points
 SELECT
         n.daytime,
	       d.object_id,
	       d.object_code,
	       p.contract_id,
         n.nomination_type,
         sum(n.REQUESTED_QTY) REQUESTED_QTY,
	       sum(n.ACCEPTED_QTY) ACCEPTED_QTY,
	       sum(n.EXT_ACCEPTED_QTY) EXT_ACCEPTED_QTY,
	       sum(n.ADJUSTED_QTY) ADJUSTED_QTY,
	       sum(n.EXT_ADJUSTED_QTY) EXT_ADJUSTED_QTY,
	       sum(n.CONFIRMED_QTY) CONFIRMED_QTY,
	       sum(n.EXT_CONFIRMED_QTY) EXT_CONFIRMED_QTY,
	       sum(n.SCHEDULED_QTY) SCHEDULED_QTY,
	       ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_INPUT_UOM', n.daytime) uom,
	       ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_INPUT_UOM_CONDITION', n.daytime) condition,
	       ecdp_contract_attribute.getAttributeNumber(p.contract_id, 'NOM_GRS_NET_PCT', n.daytime) pct
	  FROM nompnt_day_nomination n,
	       nomination_point      p,
	       delivery_point        d
	  WHERE n.object_id = p.object_id
    AND p.entry_location_id = d.object_id
    AND p.exit_location_id is NULL
	  AND n.daytime = cp_daytime
	  AND d.object_id = cp_delpnt_id
	  AND n.nomination_type = 'TRAN_INPUT'
	  AND nvl(n.nom_cycle_code, 'a') = nvl(cp_nom_cycle, 'a')
    GROUP BY n.daytime, d.object_id, d.object_code, p.contract_id, n.nomination_type
UNION ALL
(
 --Aggregate input nominations for delivery streams
SELECT
         n.daytime,
	       d.object_id,
	       d.object_code,
	       p.contract_id,
         n.nomination_type,
         sum(n.REQUESTED_QTY) REQUESTED_QTY,
	       sum(n.ACCEPTED_QTY) ACCEPTED_QTY,
	       sum(n.EXT_ACCEPTED_QTY) EXT_ACCEPTED_QTY,
	       sum(n.ADJUSTED_QTY) ADJUSTED_QTY,
	       sum(n.EXT_ADJUSTED_QTY) EXT_ADJUSTED_QTY,
	       sum(n.CONFIRMED_QTY) CONFIRMED_QTY,
	       sum(n.EXT_CONFIRMED_QTY) EXT_CONFIRMED_QTY,
	       sum(n.SCHEDULED_QTY) SCHEDULED_QTY,
	       ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_INPUT_UOM', n.daytime) uom,
	       ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_INPUT_UOM_CONDITION', n.daytime) condition,
	       ecdp_contract_attribute.getAttributeNumber(p.contract_id, 'NOM_GRS_NET_PCT', n.daytime) pct
	  FROM nompnt_day_nomination n,
	       nomination_point      p,
	       delivery_stream       s,
	       delivery_point        d
	 WHERE n.object_id = p.object_id
     AND ((p.entry_location_id = s.object_id or p.exit_location_id = s.object_id)
     AND (s.entry_delpnt_id = d.object_id or s.exit_delpnt_id = d.object_id))
	   AND n.daytime = cp_daytime
	   AND d.object_id = cp_delpnt_id
	   AND n.nomination_type = 'TRAN_INPUT'
	   AND nvl(n.nom_cycle_code, 'a') = nvl(cp_nom_cycle, 'a')
     GROUP BY n.daytime, d.object_id, d.object_code, p.contract_id, n.nomination_type
 );


CURSOR c_output_nom (cp_delpnt_id VARCHAR2, cp_nom_cycle VARCHAR, cp_daytime DATE) IS
 --Aggregate output nominations for delivery points
 SELECT
         n.daytime,
	       d.object_id,
	       d.object_code,
	       p.contract_id,
         n.nomination_type,
         sum(n.REQUESTED_QTY) REQUESTED_QTY,
	       sum(n.ACCEPTED_QTY) ACCEPTED_QTY,
	       sum(n.EXT_ACCEPTED_QTY) EXT_ACCEPTED_QTY,
	       sum(n.ADJUSTED_QTY) ADJUSTED_QTY,
	       sum(n.EXT_ADJUSTED_QTY) EXT_ADJUSTED_QTY,
	       sum(n.CONFIRMED_QTY) CONFIRMED_QTY,
	       sum(n.EXT_CONFIRMED_QTY) EXT_CONFIRMED_QTY,
	       sum(n.SCHEDULED_QTY) SCHEDULED_QTY,
	       ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_OUTPUT_UOM', n.daytime) uom,
	       ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_OUTPUT_UOM_CONDITION', n.daytime) condition,
	       ecdp_contract_attribute.getAttributeNumber(p.contract_id, 'NOM_GRS_NET_PCT', n.daytime) pct
	  FROM nompnt_day_nomination n,
	       nomination_point      p,
	       delivery_point        d
	  WHERE n.object_id = p.object_id
    AND p.entry_location_id is NULL
    AND p.exit_location_id = d.object_id
	  AND n.daytime = cp_daytime
	  AND d.object_id = cp_delpnt_id
	  AND n.nomination_type = 'TRAN_OUTPUT'
	  AND nvl(n.nom_cycle_code, 'a') = nvl(cp_nom_cycle, 'a')
    GROUP BY n.daytime, d.object_id, d.object_code, p.contract_id, n.nomination_type
UNION ALL
(
 --Aggregate output nominations for delivery streams
SELECT
         n.daytime,
	       d.object_id,
	       d.object_code,
	       p.contract_id,
         n.nomination_type,
         sum(n.REQUESTED_QTY) REQUESTED_QTY,
	       sum(n.ACCEPTED_QTY) ACCEPTED_QTY,
	       sum(n.EXT_ACCEPTED_QTY) EXT_ACCEPTED_QTY,
	       sum(n.ADJUSTED_QTY) ADJUSTED_QTY,
	       sum(n.EXT_ADJUSTED_QTY) EXT_ADJUSTED_QTY,
	       sum(n.CONFIRMED_QTY) CONFIRMED_QTY,
	       sum(n.EXT_CONFIRMED_QTY) EXT_CONFIRMED_QTY,
	       sum(n.SCHEDULED_QTY) SCHEDULED_QTY,
	       ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_OUTPUT_UOM', n.daytime) uom,
	       ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_OUTPUT_UOM_CONDITION', n.daytime) condition,
	       ecdp_contract_attribute.getAttributeNumber(p.contract_id, 'NOM_GRS_NET_PCT', n.daytime) pct
	  FROM nompnt_day_nomination n,
	       nomination_point      p,
	       delivery_stream       s,
	       delivery_point        d
	 WHERE n.object_id = p.object_id
     AND ((p.entry_location_id = s.object_id or p.exit_location_id = s.object_id)
     AND (s.entry_delpnt_id = d.object_id or s.exit_delpnt_id = d.object_id))
	   AND n.daytime = cp_daytime
	   AND d.object_id = cp_delpnt_id
	   AND n.nomination_type = 'TRAN_OUTPUT'
	   AND nvl(n.nom_cycle_code, 'a') = nvl(cp_nom_cycle, 'a')
     GROUP BY n.daytime, d.object_id, d.object_code, p.contract_id, n.nomination_type
 );

/** Cursors used by delivery stream functions*/
CURSOR c_input_nom_destrm (cp_delstrm_id VARCHAR2, cp_nom_cycle VARCHAR, cp_daytime DATE) IS
SELECT s.object_id,
       s.object_code,
       sum(n.REQUESTED_QTY) REQUESTED_QTY,
       sum(n.ACCEPTED_QTY) ACCEPTED_QTY,
       sum(n.EXT_ACCEPTED_QTY) EXT_ACCEPTED_QTY,
       sum(n.ADJUSTED_QTY) ADJUSTED_QTY,
       sum(n.EXT_ADJUSTED_QTY) EXT_ADJUSTED_QTY,
       sum(n.CONFIRMED_QTY) CONFIRMED_QTY,
       sum(n.EXT_CONFIRMED_QTY) EXT_CONFIRMED_QTY,
       sum(n.SCHEDULED_QTY) SCHEDULED_QTY,
       ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_INPUT_UOM', n.daytime) uom,
       ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_INPUT_UOM_CONDITION', n.daytime) condition,
       ecdp_contract_attribute.getAttributeNumber(p.contract_id, 'NOM_GRS_NET_PCT', n.daytime) pct,
       to_char(null) record_status,
       to_char(null) created_by,
       to_date(null) created_date,
       to_char(null) last_updated_by,
       to_date(null) last_updated_date,
       to_number(null) rev_no,
       to_char(null) rev_text
  FROM nompnt_day_nomination n,
       nomination_point      p,
       delivery_stream       s,
       delstrm_version       v
 WHERE n.object_id = p.object_id
   AND (p.entry_location_id = s.object_id or
       p.exit_location_id = s.object_id)
   AND s.object_id = v.object_id
   AND v.daytime <= n.daytime
   AND nvl(v.end_date, n.daytime + 1) > n.daytime
   AND n.daytime = cp_daytime
   AND s.object_id = cp_delstrm_id
   AND n.nomination_type = 'TRAN_INPUT'
   AND nvl(n.nom_cycle_code, 'a') = nvl(cp_nom_cycle, 'a')
 GROUP BY n.daytime, s.object_id, s.object_code, p.contract_id;

CURSOR c_output_nom_destrm (cp_delstrm_id VARCHAR2, cp_nom_cycle VARCHAR, cp_daytime DATE) IS
SELECT s.object_id,
       s.object_code,
       sum(n.REQUESTED_QTY) REQUESTED_QTY,
       sum(n.ACCEPTED_QTY) ACCEPTED_QTY,
       sum(n.EXT_ACCEPTED_QTY) EXT_ACCEPTED_QTY,
       sum(n.ADJUSTED_QTY) ADJUSTED_QTY,
       sum(n.EXT_ADJUSTED_QTY) EXT_ADJUSTED_QTY,
       sum(n.CONFIRMED_QTY) CONFIRMED_QTY,
       sum(n.EXT_CONFIRMED_QTY) EXT_CONFIRMED_QTY,
       sum(n.SCHEDULED_QTY) SCHEDULED_QTY,
	   ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_OUTPUT_UOM', n.daytime) uom,
	   ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_OUTPUT_UOM_CONDITION', n.daytime) condition,
	   ecdp_contract_attribute.getAttributeNumber(p.contract_id, 'NOM_GRS_NET_PCT', n.daytime) pct,
       to_char(null) record_status,
       to_char(null) created_by,
       to_date(null) created_date,
       to_char(null) last_updated_by,
       to_date(null) last_updated_date,
       to_number(null) rev_no,
       to_char(null) rev_text
  FROM nompnt_day_nomination n,
       nomination_point      p,
       delivery_stream       s,
       delstrm_version       v
 WHERE n.object_id = p.object_id
   AND (p.entry_location_id = s.object_id or
       p.exit_location_id = s.object_id)
   AND s.object_id = v.object_id
   AND v.daytime <= n.daytime
   AND Nvl(v.end_date, n.daytime + 1) > n.daytime
   AND n.daytime = cp_daytime
   AND s.object_id = cp_delstrm_id
   AND n.nomination_type = 'TRAN_OUTPUT'
   AND nvl(n.nom_cycle_code, 'a') = nvl(cp_nom_cycle, 'a')
 GROUP BY n.daytime, s.object_id, s.object_code, p.contract_id;

 -- Sub Day Cursors
CURSOR c_input_nom_sub_day (cp_delpnt_id VARCHAR2, cp_nom_cycle VARCHAR2, cp_daytime DATE, cp_summer_time VARCHAR2) IS
 SELECT d.object_id,
       d.object_code,
       n.daytime,
       n.summer_time,
       n.production_day,
       p.contract_id,
       n.nomination_type,
       sum(n.REQUESTED_QTY) REQUESTED_QTY,
       sum(n.ACCEPTED_QTY) ACCEPTED_QTY,
       sum(n.EXT_ACCEPTED_QTY) EXT_ACCEPTED_QTY,
       sum(n.ADJUSTED_QTY) ADJUSTED_QTY,
       sum(n.EXT_ADJUSTED_QTY) EXT_ADJUSTED_QTY,
       sum(n.CONFIRMED_QTY) CONFIRMED_QTY,
       sum(n.EXT_CONFIRMED_QTY) EXT_CONFIRMED_QTY,
       sum(n.SCHEDULED_QTY) SCHEDULED_QTY,
       ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_OUTPUT_UOM', n.daytime) uom,
       ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_OUTPUT_UOM_CONDITION', n.daytime) condition,
       ecdp_contract_attribute.getAttributeNumber(p.contract_id, 'NOM_GRS_NET_PCT', n.daytime) pct
  FROM nompnt_sub_day_nomination n, nomination_point p, delivery_point d
 WHERE n.object_id = p.object_id
   AND p.entry_location_id is NULL
   AND p.exit_location_id = d.object_id
   AND n.daytime = cp_daytime
   AND n.summer_time = cp_summer_time
   AND d.object_id = cp_delpnt_id
   AND n.nomination_type = 'TRAN_INPUT'
   AND nvl(n.nom_cycle_code, 'a') = nvl(cp_nom_cycle, 'a')
 GROUP BY d.object_id, d.object_code, n.daytime, n.summer_time, n.production_day, p.contract_id, n.nomination_type
UNION ALL
SELECT d.object_id,
       d.object_code,
       n.daytime,
       n.summer_time,
       n.production_day,
       p.contract_id,
       n.nomination_type,
       sum(n.REQUESTED_QTY) REQUESTED_QTY,
       sum(n.ACCEPTED_QTY) ACCEPTED_QTY,
       sum(n.EXT_ACCEPTED_QTY) EXT_ACCEPTED_QTY,
       sum(n.ADJUSTED_QTY) ADJUSTED_QTY,
       sum(n.EXT_ADJUSTED_QTY) EXT_ADJUSTED_QTY,
       sum(n.CONFIRMED_QTY) CONFIRMED_QTY,
       sum(n.EXT_CONFIRMED_QTY) EXT_CONFIRMED_QTY,
       sum(n.SCHEDULED_QTY) SCHEDULED_QTY,
       ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_OUTPUT_UOM', n.daytime) uom,
       ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_OUTPUT_UOM_CONDITION', n.daytime) condition,
       ecdp_contract_attribute.getAttributeNumber(p.contract_id, 'NOM_GRS_NET_PCT', n.daytime) pct
  FROM nompnt_sub_day_nomination n, nomination_point p, delivery_stream s, delivery_point d
 WHERE n.object_id = p.object_id
   AND ((p.entry_location_id = s.object_id or p.exit_location_id = s.object_id) AND
       (s.entry_delpnt_id = d.object_id or s.exit_delpnt_id = d.object_id))
   AND n.daytime = cp_daytime
   AND n.summer_time = cp_summer_time
   AND d.object_id = cp_delpnt_id
   AND n.nomination_type = 'TRAN_INPUT'
   AND nvl(n.nom_cycle_code, 'a') = nvl(cp_nom_cycle, 'a')
 GROUP BY d.object_id, d.object_code, n.daytime, n.summer_time, n.production_day, p.contract_id, n.nomination_type;

CURSOR c_output_nom_sub_day (cp_delpnt_id VARCHAR2, cp_nom_cycle VARCHAR2, cp_daytime DATE, cp_summer_time VARCHAR2) IS
 SELECT d.object_id,
       d.object_code,
       n.daytime,
       n.summer_time,
       n.production_day,
       p.contract_id,
       n.nomination_type,
       sum(n.REQUESTED_QTY) REQUESTED_QTY,
       sum(n.ACCEPTED_QTY) ACCEPTED_QTY,
       sum(n.EXT_ACCEPTED_QTY) EXT_ACCEPTED_QTY,
       sum(n.ADJUSTED_QTY) ADJUSTED_QTY,
       sum(n.EXT_ADJUSTED_QTY) EXT_ADJUSTED_QTY,
       sum(n.CONFIRMED_QTY) CONFIRMED_QTY,
       sum(n.EXT_CONFIRMED_QTY) EXT_CONFIRMED_QTY,
       sum(n.SCHEDULED_QTY) SCHEDULED_QTY,
       ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_OUTPUT_UOM', n.daytime) uom,
       ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_OUTPUT_UOM_CONDITION', n.daytime) condition,
       ecdp_contract_attribute.getAttributeNumber(p.contract_id, 'NOM_GRS_NET_PCT', n.daytime) pct
  FROM nompnt_sub_day_nomination n, nomination_point p, delivery_point d
 WHERE n.object_id = p.object_id
   AND p.entry_location_id is NULL
   AND p.exit_location_id = d.object_id
   AND n.daytime = cp_daytime
   AND n.summer_time = cp_summer_time
   AND d.object_id = cp_delpnt_id
   AND n.nomination_type = 'TRAN_OUTPUT'
   AND nvl(n.nom_cycle_code, 'a') = nvl(cp_nom_cycle, 'a')
 GROUP BY d.object_id, d.object_code, n.daytime, n.summer_time, n.production_day, p.contract_id, n.nomination_type
UNION ALL
SELECT d.object_id,
       d.object_code,
       n.daytime,
       n.summer_time,
       n.production_day,
       p.contract_id,
       n.nomination_type,
       sum(n.REQUESTED_QTY) REQUESTED_QTY,
       sum(n.ACCEPTED_QTY) ACCEPTED_QTY,
       sum(n.EXT_ACCEPTED_QTY) EXT_ACCEPTED_QTY,
       sum(n.ADJUSTED_QTY) ADJUSTED_QTY,
       sum(n.EXT_ADJUSTED_QTY) EXT_ADJUSTED_QTY,
       sum(n.CONFIRMED_QTY) CONFIRMED_QTY,
       sum(n.EXT_CONFIRMED_QTY) EXT_CONFIRMED_QTY,
       sum(n.SCHEDULED_QTY) SCHEDULED_QTY,
       ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_OUTPUT_UOM', n.daytime) uom,
       ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_OUTPUT_UOM_CONDITION', n.daytime) condition,
       ecdp_contract_attribute.getAttributeNumber(p.contract_id, 'NOM_GRS_NET_PCT', n.daytime) pct
  FROM nompnt_sub_day_nomination n, nomination_point p, delivery_stream s, delivery_point d
 WHERE n.object_id = p.object_id
   AND ((p.entry_location_id = s.object_id or p.exit_location_id = s.object_id) AND
       (s.entry_delpnt_id = d.object_id or s.exit_delpnt_id = d.object_id))
   AND n.daytime = cp_daytime
   AND n.summer_time = cp_summer_time
   AND d.object_id = cp_delpnt_id
   AND n.nomination_type = 'TRAN_OUTPUT'
   AND nvl(n.nom_cycle_code, 'a') = nvl(cp_nom_cycle, 'a')
 GROUP BY d.object_id, d.object_code, n.daytime, n.summer_time, n.production_day, p.contract_id, n.nomination_type;

 --Delivery Stream cursors
CURSOR c_input_nom_sub_day_delstrm (cp_delstrm_id VARCHAR2, cp_nom_cycle VARCHAR2, cp_daytime DATE, cp_summer_time VARCHAR2) IS
SELECT s.object_id,
       s.object_code,
       n.daytime,
       n.summer_time,
       n.production_day,
       p.contract_id,
       n.nomination_type,
       sum(n.REQUESTED_QTY) REQUESTED_QTY,
       sum(n.ACCEPTED_QTY) ACCEPTED_QTY,
       sum(n.EXT_ACCEPTED_QTY) EXT_ACCEPTED_QTY,
       sum(n.ADJUSTED_QTY) ADJUSTED_QTY,
       sum(n.EXT_ADJUSTED_QTY) EXT_ADJUSTED_QTY,
       sum(n.CONFIRMED_QTY) CONFIRMED_QTY,
       sum(n.EXT_CONFIRMED_QTY) EXT_CONFIRMED_QTY,
       sum(n.SCHEDULED_QTY) SCHEDULED_QTY,
       ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_OUTPUT_UOM', n.daytime) uom,
       ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_OUTPUT_UOM_CONDITION', n.daytime) condition,
       ecdp_contract_attribute.getAttributeNumber(p.contract_id, 'NOM_GRS_NET_PCT', n.daytime) pct
  FROM nompnt_sub_day_nomination n, nomination_point p, delivery_stream s
 WHERE n.object_id = p.object_id
   AND (p.entry_location_id = s.object_id or p.exit_location_id = s.object_id)
   AND n.daytime = cp_daytime
   AND n.summer_time = cp_summer_time
   AND s.object_id = cp_delstrm_id
   AND n.nomination_type = 'TRAN_INPUT'
   AND nvl(n.nom_cycle_code, 'a') = nvl(cp_nom_cycle, 'a')
 GROUP BY s.object_id, s.object_code, n.daytime, n.summer_time, n.production_day, p.contract_id, n.nomination_type;

CURSOR c_output_nom_sub_day_delstrm (cp_delstrm_id VARCHAR2, cp_nom_cycle VARCHAR2, cp_daytime DATE, cp_summer_time VARCHAR2) IS
SELECT s.object_id,
       s.object_code,
       n.daytime,
       n.summer_time,
       n.production_day,
       p.contract_id,
       n.nomination_type,
       sum(n.REQUESTED_QTY) REQUESTED_QTY,
       sum(n.ACCEPTED_QTY) ACCEPTED_QTY,
       sum(n.EXT_ACCEPTED_QTY) EXT_ACCEPTED_QTY,
       sum(n.ADJUSTED_QTY) ADJUSTED_QTY,
       sum(n.EXT_ADJUSTED_QTY) EXT_ADJUSTED_QTY,
       sum(n.CONFIRMED_QTY) CONFIRMED_QTY,
       sum(n.EXT_CONFIRMED_QTY) EXT_CONFIRMED_QTY,
       sum(n.SCHEDULED_QTY) SCHEDULED_QTY,
       ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_OUTPUT_UOM', n.daytime) uom,
       ecdp_contract_attribute.getAttributeString(p.contract_id, 'NOM_OUTPUT_UOM_CONDITION', n.daytime) condition,
       ecdp_contract_attribute.getAttributeNumber(p.contract_id, 'NOM_GRS_NET_PCT', n.daytime) pct
  FROM nompnt_sub_day_nomination n, nomination_point p, delivery_stream s
 WHERE n.object_id = p.object_id
   AND (p.entry_location_id = s.object_id or p.exit_location_id = s.object_id)
   AND n.daytime = cp_daytime
   AND n.summer_time = cp_summer_time
   AND s.object_id = cp_delstrm_id
   AND n.nomination_type = 'TRAN_OUTPUT'
   AND nvl(n.nom_cycle_code, 'a') = nvl(cp_nom_cycle, 'a')
 GROUP BY s.object_id, s.object_code, n.daytime, n.summer_time, n.production_day, p.contract_id, n.nomination_type;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : extConfirmNom
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE extConfirmNom(p_nom_seq NUMBER)
--</EC-DOC>
IS
	ln_qty NUMBER;

BEGIN
	-- example implementation.
	ln_qty := ec_nompnt_day_nomination.ext_confirmed_qty(p_nom_seq);

	if (ln_qty is not null) then
		UPDATE nompnt_day_nomination
		SET CONFIRMED_QTY = ln_qty,
			NOM_STATUS = 'CON', last_updated_by = ecdp_context.getAppUser
		WHERE nomination_seq = p_nom_seq;
	else
		-- replace ORA-20000 with a unique number
		RAISE_APPLICATION_ERROR(-20000, 'Cannot confirm when externally confirmed quantity is null');
	end if;

END extConfirmNom;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : extRejectConfirmedNom
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE extRejectConfirmedNom(p_nom_seq NUMBER)
--</EC-DOC>
IS

BEGIN
	-- example implementation.
	UPDATE nompnt_day_nomination
	SET CONFIRMED_QTY = NULL,
		NOM_STATUS = 'ADJ', last_updated_by = ecdp_context.getAppUser
	WHERE nomination_seq = p_nom_seq;

END extRejectConfirmedNom;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : SubmittNom
-- Description    : Proccedure for submitting nominations for a selected contract on a given day for a cycle.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE submittNom(p_contract_id VARCHAR2, p_daytime date, p_nom_cycle_code varchar2)
--</EC-DOC>
IS

cursor c_contract_nominations (p_contract_id VARCHAR2, p_daytime DATE) is
select n.nomination_seq from nompnt_day_nomination n
where contract_id = p_contract_id
and daytime = p_daytime;

cursor c_contract_nominations_cycle (p_contract_id VARCHAR2, p_daytime DATE, p_nom_cycle_code VARCHAR2 ) is
select n.nomination_seq from nompnt_day_nomination n
where contract_id = p_contract_id
and daytime = p_daytime
and nom_cycle_code = p_nom_cycle_code;


BEGIN
	-- example implementation.

IF p_nom_cycle_code is null THEN
   FOR curCnNom IN c_contract_nominations (p_contract_id, p_daytime) LOOP
       UPDATE nompnt_day_nomination n
	        SET n.accepted_qty = n.requested_qty,
	            NOM_STATUS = 'ACC',
              last_updated_by = ecdp_context.getAppUser
	      WHERE n.nomination_seq=curCnNom.Nomination_Seq
          AND nvl(OPER_NOM_IND, 'N') <> 'Y';
   END LOOP;
END IF;

IF p_nom_cycle_code is not null THEN
  FOR curCnNomCycle IN c_contract_nominations_cycle (p_contract_id, p_daytime, p_nom_cycle_code) LOOP
  UPDATE nompnt_day_nomination n
	SET n.accepted_qty = n.requested_qty,
	NOM_STATUS = 'ACC',
  last_updated_by = ecdp_context.getAppUser
	WHERE n.nomination_seq=curCnNomCycle.Nomination_Seq
  AND nvl(OPER_NOM_IND, 'N') <> 'Y';
  END LOOP;
  END IF;

END submittNom;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calculateBalance
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calculateBalance(p_input_qty NUMBER, p_output_qty NUMBER)
RETURN NUMBER
--</EC-DOC>
IS

ln_result NUMBER;

BEGIN

	ln_result := p_input_qty-p_output_qty;

	RETURN ln_result;

END calculateBalance;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calculateTransfBalance
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calculateTransfBalance(p_contract_id VARCHAR2 DEFAULT NULL, p_date DATE DEFAULT NULL, p_input_qty NUMBER, p_output_qty NUMBER, p_transf_qty NUMBER)
RETURN NUMBER
--</EC-DOC>
IS

ln_result          NUMBER;
ln_transf_qty      NUMBER;
ln_inbalance_sign  NUMBER;
ln_input_sign      NUMBER;
ln_output_sign     NUMBER;
ln_input_qty       NUMBER;
ln_output_qty      NUMBER;

BEGIN

  --getting the sign positive or negative as hard coded values this is a call from Daily Location Contract Balance Screen in Gas Dispatch Module.
  IF p_contract_id IS NULL OR p_date IS NULL THEN
	ln_input_sign  := -1;
	ln_output_sign := 1;
  ELSE
    --getting the sign positive or negative from the contract attribute
    ln_input_sign  := ecdp_contract_attribute.getAttributeString (p_contract_id,'TRAN_INPUT',p_date);
	ln_output_sign := ecdp_contract_attribute.getAttributeString (p_contract_id,'TRAN_OUTPUT',p_date);
  END IF;

  ln_input_qty  := p_input_qty;
  ln_output_qty := p_output_qty;

  ---TRAN_INPUT
  IF p_transf_qty < 0 AND ln_input_sign < 0 THEN
     --TRAN_INPUT -VE
     ln_input_qty :=  ln_input_qty + (p_transf_qty*ln_input_sign);
  END IF;
  IF p_transf_qty > 0 AND ln_input_sign > 0 THEN
     --TRAN_INPUT +VE
     ln_input_qty :=  ln_input_qty + (p_transf_qty*ln_input_sign);
  END IF;

  --TRAN_OUTPUT
  IF p_transf_qty < 0 AND ln_output_sign < 0 THEN
     --TRAN_OUTPUT -VE
     ln_output_qty :=  ln_output_qty + (p_transf_qty*ln_output_sign);
  END IF;
  IF p_transf_qty > 0 AND ln_output_sign > 0 THEN
     --TRAN_OUTPUT +VE
     ln_output_qty :=  ln_output_qty + (p_transf_qty*ln_output_sign);
  END IF;

  --getting the difference btwn input and output, the result should always be +ve
  IF ln_input_qty > ln_output_qty THEN
    ln_inbalance_sign := ln_output_sign;
    ln_result := ln_input_qty - ln_output_qty;
  ELSE
    ln_inbalance_sign := ln_input_sign;
    ln_result := ln_output_qty - ln_input_qty;
  END IF;
    ln_result := ln_result*ln_inbalance_sign;

	RETURN ln_result;

END calculateTransfBalance;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getClassUniqueKey
-- Description    : Used by screens to find the trending key. Also used by the nomination matrix screen.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CLASS_ATTRIBUTE, CLASS_ATTR_DB_MAPPING,CLASS_REL_DB_MAPPING
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE getClassUniqueKey(p_class_name IN VARCHAR2,
                            p_cursor     OUT SYS_REFCURSOR)
--</EC-DOC>
 IS

 BEGIN

  --including attributes other than Gas Dispatching screens (Sales Dispatching/Price Determination)
    OPEN p_cursor FOR
      select attribute_name
        from (select a.attribute_name, EcDp_ClassMeta_Cnfg.getDbSortOrder(a.class_name, a.attribute_name) as sort_order
                from class_attribute_cnfg a
               where a.class_name = p_class_name
                 and a.attribute_name in
                     ('OBJECT_ID',
                      'DAYTIME',
                      'DAY_NOM_SEQ',
                      'SHIPPER_CODE',
                      'LOCATION_TYPE',
                      'NOMINATION_TYPE',
                      'TRANSACTION_TYPE',
                      'NOM_CYCLE_CODE',
                      'CLASS_NAME',
                      'TRANSFER_SERVICE',
                      'RATE_SCHEDULE',
                      'CONTRACT_ID',
                      'CNTR_CAP_TYPE',
                      'TIME_SPAN',
                      'ACCOUNT_CODE',
                      'DATASET',
                      'PRICE_ELEMENT_CODE',
                      'FORECAST_ID',
					  'SERIES')--SLCN_DAY_PRODUCT_QTY
				 and EcDp_ClassMeta_Cnfg.isDisabled(a.class_name, a.attribute_name)!='Y'
              UNION
              select cr.role_name || '_ID', EcDp_ClassMeta_Cnfg.getDbSortOrder(cr.from_class_name, cr.to_class_name, cr.role_name) as sort_order
                from class_relation_cnfg cr
               where cr.to_class_name = p_class_name
                 and (cr.is_key = 'Y' or
                     cr.role_name in ('CONTRACT', 'COMPANY'))
				 and EcDp_ClassMeta_Cnfg.isDisabled(cr.from_class_name, cr.to_class_name, cr.role_name) != 'Y')
       order by sort_order;

END getClassUniqueKey;

    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       : getMatrixRecipt
    -- Description    : Return the total input nomination qty for selected object and date. Used in matrix BF
    --
    -- Preconditions  : The object id sent to this function can be any of the object ids found in the navigator
    --                  The function should work accordingly and aggregate to the object selected
    -- Postconditions :
    --
    -- Using tables   : nompnt_day_nomination
    --
    -- Using functions:
    --
    -- Configuration
    -- required       :
    --
    -- Behaviour      :
    --
    ---------------------------------------------------------------------------------------------------
    FUNCTION getMatrixReceipt(p_object_id  VARCHAR2,
                              p_daytime    DATE,
                              p_qty_column VARCHAR2,
                              p_nom_cycle VARCHAR2) RETURN NUMBER
    --</EC-DOC>
     IS
        CURSOR c_nom(cp_object_id VARCHAR2,
                     cp_daytime   DATE) IS
            select n.contract_id,
                   sum(n.requested_qty) requested_qty,
                   sum(n.accepted_qty) accepted_qty,
                   sum(n.ext_accepted_qty) ext_accepted_qty,
                   sum(n.adjusted_qty) adjusted_qty,
                   sum(n.ext_adjusted_qty) ext_adjusted_qty,
                   sum(n.confirmed_qty) confirmed_qty,
                   sum(n.ext_confirmed_qty) ext_confirmed_qty,
                   sum(n.scheduled_qty) scheduled_qty
              from nompnt_day_nomination n
             where n.nomination_type = 'TRAN_INPUT'
               and n.daytime = cp_daytime
               and n.contract_id = cp_object_id
             group by n.contract_id;

		CURSOR c_nom_cycle(cp_object_id VARCHAR2,
                     cp_daytime   DATE,
                     cp_nom_cycle VARCHAR2) IS
            select n.contract_id,
                   sum(n.requested_qty) requested_qty,
                   sum(n.accepted_qty) accepted_qty,
                   sum(n.ext_accepted_qty) ext_accepted_qty,
                   sum(n.adjusted_qty) adjusted_qty,
                   sum(n.ext_adjusted_qty) ext_adjusted_qty,
                   sum(n.confirmed_qty) confirmed_qty,
                   sum(n.ext_confirmed_qty) ext_confirmed_qty,
                   sum(n.scheduled_qty) scheduled_qty
              from nompnt_day_nomination n
             where n.nomination_type = 'TRAN_INPUT'
               and n.daytime = cp_daytime
               and n.contract_id = cp_object_id
               and n.nom_cycle_code = cp_nom_cycle
             group by n.contract_id;

        ln_recipt_qty NUMBER;

    BEGIN
        -- this is an example implementation if the object id is a CONTRACT
        IF ecdp_objects.GetObjClassName(p_object_id) = 'CONTRACT' THEN
            IF(p_nom_cycle is not null) THEN
				FOR curNom IN c_nom_cycle(p_object_id, p_daytime, p_nom_cycle) LOOP
					case p_qty_column
						when 'REQUESTED_QTY' then
							ln_recipt_qty := curNom.Requested_Qty;
						when 'ACCEPTED_QTY' then
							ln_recipt_qty := curNom.Accepted_Qty;
						when 'EXT_ACCEPTED_QTY' then
							ln_recipt_qty := curNom.Ext_Accepted_Qty;
						when 'ADJUSTED_QTY' then
							ln_recipt_qty := curNom.Adjusted_Qty;
						when 'EXT_ADJUSTED_QTY' then
							ln_recipt_qty := curNom.Ext_Adjusted_Qty;
						when 'CONFIRMED_QTY' then
							ln_recipt_qty := curNom.Confirmed_Qty;
						when 'EXT_CONFIRMED_QTY' then
							ln_recipt_qty := curNom.Ext_Confirmed_Qty;
						when 'SCHEDULED_QTY' then
							ln_recipt_qty := curNom.Scheduled_Qty;
					end case;
				END LOOP;
			ELSE
				FOR curNom IN c_nom(p_object_id, p_daytime) LOOP
					case p_qty_column
						when 'REQUESTED_QTY' then
							ln_recipt_qty := curNom.Requested_Qty;
						when 'ACCEPTED_QTY' then
							ln_recipt_qty := curNom.Accepted_Qty;
						when 'EXT_ACCEPTED_QTY' then
							ln_recipt_qty := curNom.Ext_Accepted_Qty;
						when 'ADJUSTED_QTY' then
							ln_recipt_qty := curNom.Adjusted_Qty;
						when 'EXT_ADJUSTED_QTY' then
							ln_recipt_qty := curNom.Ext_Adjusted_Qty;
						when 'CONFIRMED_QTY' then
							ln_recipt_qty := curNom.Confirmed_Qty;
						when 'EXT_CONFIRMED_QTY' then
							ln_recipt_qty := curNom.Ext_Confirmed_Qty;
						when 'SCHEDULED_QTY' then
							ln_recipt_qty := curNom.Scheduled_Qty;
					end case;
				END LOOP;
			END IF;
        END IF;

        RETURN ln_recipt_qty;

    END getMatrixReceipt;

    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       : getMatrixDelivery
    -- Description    : Return the total output nomination qty for selected object and date. Used in matrix BF
    --
    -- Preconditions  : The object id sent to this function can be any of the object ids found in the navigator
    --                  The function should work accordingly and aggregate to the object selected
    -- Postconditions :
    --
    -- Using tables   : nompnt_day_nomination
    --
    -- Using functions:
    --
    -- Configuration
    -- required       :
    --
    -- Behaviour      :
    --
    ---------------------------------------------------------------------------------------------------
    FUNCTION getMatrixDelivery(p_object_id  VARCHAR2,
                               p_daytime    DATE,
                               p_qty_column VARCHAR2,
                               p_nom_cycle VARCHAR2) RETURN NUMBER
    --</EC-DOC>
     IS
       CURSOR c_nom(cp_object_id VARCHAR2,
                     cp_daytime   DATE) IS
            select n.contract_id,
                   sum(n.requested_qty) requested_qty,
                   sum(n.accepted_qty) accepted_qty,
                   sum(n.ext_accepted_qty) ext_accepted_qty,
                   sum(n.adjusted_qty) adjusted_qty,
                   sum(n.ext_adjusted_qty) ext_adjusted_qty,
                   sum(n.confirmed_qty) confirmed_qty,
                   sum(n.ext_confirmed_qty) ext_confirmed_qty,
                   sum(n.scheduled_qty) scheduled_qty
              from nompnt_day_nomination n
             where n.nomination_type = 'TRAN_OUTPUT'
               and n.daytime = cp_daytime
               and n.contract_id = cp_object_id
             group by n.contract_id;

		CURSOR c_nom_cycle(cp_object_id VARCHAR2,
                     cp_daytime   DATE,
                     cp_nom_cycle VARCHAR2) IS
            select n.contract_id,
                   sum(n.requested_qty) requested_qty,
                   sum(n.accepted_qty) accepted_qty,
                   sum(n.ext_accepted_qty) ext_accepted_qty,
                   sum(n.adjusted_qty) adjusted_qty,
                   sum(n.ext_adjusted_qty) ext_adjusted_qty,
                   sum(n.confirmed_qty) confirmed_qty,
                   sum(n.ext_confirmed_qty) ext_confirmed_qty,
                   sum(n.scheduled_qty) scheduled_qty
              from nompnt_day_nomination n
             where n.nomination_type = 'TRAN_OUTPUT'
               and n.daytime = cp_daytime
               and n.contract_id = cp_object_id
               and n.nom_cycle_code = cp_nom_cycle
             group by n.contract_id;

        ln_del_qty NUMBER;

    BEGIN
        -- this is an example implementation if the object id is a CONTRACT
        IF ecdp_objects.GetObjClassName(p_object_id) = 'CONTRACT' THEN
			IF(p_nom_cycle is not null) THEN
				FOR curNom IN c_nom_cycle(p_object_id, p_daytime, p_nom_cycle) LOOP
					case p_qty_column
						when 'REQUESTED_QTY' then
							ln_del_qty := curNom.Requested_Qty;
						when 'ACCEPTED_QTY' then
							ln_del_qty := curNom.Accepted_Qty;
						when 'EXT_ACCEPTED_QTY' then
							ln_del_qty := curNom.Ext_Accepted_Qty;
						when 'ADJUSTED_QTY' then
							ln_del_qty := curNom.Adjusted_Qty;
						when 'EXT_ADJUSTED_QTY' then
							ln_del_qty := curNom.Ext_Adjusted_Qty;
						when 'CONFIRMED_QTY' then
							ln_del_qty := curNom.Confirmed_Qty;
						when 'EXT_CONFIRMED_QTY' then
							ln_del_qty := curNom.Ext_Confirmed_Qty;
						when 'SCHEDULED_QTY' then
							ln_del_qty := curNom.Scheduled_Qty;
					end case;
				END LOOP;
			ELSE
				FOR curNom IN c_nom(p_object_id, p_daytime) LOOP
					case p_qty_column
						when 'REQUESTED_QTY' then
							ln_del_qty := curNom.Requested_Qty;
						when 'ACCEPTED_QTY' then
							ln_del_qty := curNom.Accepted_Qty;
						when 'EXT_ACCEPTED_QTY' then
							ln_del_qty := curNom.Ext_Accepted_Qty;
						when 'ADJUSTED_QTY' then
							ln_del_qty := curNom.Adjusted_Qty;
						when 'EXT_ADJUSTED_QTY' then
							ln_del_qty := curNom.Ext_Adjusted_Qty;
						when 'CONFIRMED_QTY' then
							ln_del_qty := curNom.Confirmed_Qty;
						when 'EXT_CONFIRMED_QTY' then
							ln_del_qty := curNom.Ext_Confirmed_Qty;
						when 'SCHEDULED_QTY' then
							ln_del_qty := curNom.Scheduled_Qty;
					end case;
				END LOOP;
			END IF;
        END IF;

        RETURN ln_del_qty;
    END getMatrixDelivery;

    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       : getMatrixInventory
    -- Description    : Return the difference between input and output nomination qty for selected object and date. Used in matrix BF
    --
    -- Preconditions  : The object id sent to this function can be any of the object ids found in the navigator
    --                  The function should work accordingly and aggregate to the object selected
    -- Postconditions :
    --
    -- Using tables   : nompnt_day_nomination
    --
    -- Using functions:
    --
    -- Configuration
    -- required       :
    --
    -- Behaviour      :
    --
    ---------------------------------------------------------------------------------------------------
    FUNCTION getMatrixInventory(p_object_id  VARCHAR2,
                                p_daytime    DATE,
                                p_qty_column VARCHAR2,
                                p_nom_cycle VARCHAR2) RETURN NUMBER
    --</EC-DOC>
     IS

    BEGIN
        RETURN getMatrixDelivery(p_object_id, p_daytime, p_qty_column, p_nom_cycle) - getMatrixReceipt(p_object_id, p_daytime, p_qty_column, p_nom_cycle);
    END getMatrixInventory;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalReqQtyPrDelpnt
-- Description    : Returns aggregated qty for a delivery_point on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalReqQtyPrDelpnt(
  p_delpnt_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delpnt_version.nom_uom(p_delpnt_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		-- loop input nominations
		FOR curInput IN c_input_nom (p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.REQUESTED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.REQUESTED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;

		FOR curOutput IN c_output_nom (p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.REQUESTED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.REQUESTED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;

		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;

  RETURN ln_return_qty;

END getTotalReqQtyPrDelpnt;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalAccQtyPrDelpnt
-- Description    : Returns aggregated qty for a delivery_point on a given day for a given cycle.
--					This is an example code. More validation and/or checks may be required
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       : For this example code to work properly,
--					nom_uom on delivery_point must have a value. Contract attributes must have values.
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalAccQtyPrDelpnt(
  p_delpnt_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delpnt_version.nom_uom(p_delpnt_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		-- loop input nominations
		FOR curInput IN c_input_nom (p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.ACCEPTED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.ACCEPTED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;

		FOR curOutput IN c_output_nom (p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.ACCEPTED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.ACCEPTED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;

		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;

  RETURN ln_return_qty;

END getTotalAccQtyPrDelpnt;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalExtAccQtyPrDelpnt
-- Description    : Returns aggregated qty for a delivery point on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalExtAccQtyPrDelpnt(
  p_delpnt_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE
)
RETURN INTEGER
--</EC-DOC>
IS
 	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delpnt_version.nom_uom(p_delpnt_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		-- loop input nominations
		FOR curInput IN c_input_nom (p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.EXT_ACCEPTED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.EXT_ACCEPTED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;

		FOR curOutput IN c_output_nom (p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.EXT_ACCEPTED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.EXT_ACCEPTED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;

		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;

  RETURN ln_return_qty;

END getTotalExtAccQtyPrDelpnt;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalAdjQtyPrDelpnt
-- Description    : Returns aggregated qty for a delivery point on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalAdjQtyPrDelpnt(
  p_delpnt_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delpnt_version.nom_uom(p_delpnt_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		-- loop input nominations
		FOR curInput IN c_input_nom (p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.ADJUSTED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.ADJUSTED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;

		FOR curOutput IN c_output_nom (p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.ADJUSTED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.ADJUSTED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;

		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;

  RETURN ln_return_qty;

END getTotalAdjQtyPrDelpnt;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalExtAdjQtyPrDelpnt
-- Description    : Returns aggregated qty for a contract on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalExtAdjQtyPrDelpnt(
  p_delpnt_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delpnt_version.nom_uom(p_delpnt_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		-- loop input nominations
		FOR curInput IN c_input_nom (p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.EXT_ADJUSTED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.EXT_ADJUSTED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;

		FOR curOutput IN c_output_nom (p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.EXT_ADJUSTED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.EXT_ADJUSTED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;

		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;

  RETURN ln_return_qty;

END getTotalExtAdjQtyPrDelpnt;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalConfQtyPrDelpnt
-- Description    : Returns aggregated qty for a delivery point on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalConfQtyPrDelpnt(
  p_delpnt_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delpnt_version.nom_uom(p_delpnt_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		-- loop input nominations
		FOR curInput IN c_input_nom (p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.CONFIRMED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.CONFIRMED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;

		FOR curOutput IN c_output_nom (p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.CONFIRMED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.CONFIRMED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;

		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;

  RETURN ln_return_qty;

END getTotalConfQtyPrDelpnt;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalExtConfQtyPrDelpnt
-- Description    : Returns aggregated qty for a delivery point on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalExtConfQtyPrDelpnt(
  p_delpnt_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delpnt_version.nom_uom(p_delpnt_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		-- loop input nominations
		FOR curInput IN c_input_nom (p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.EXT_CONFIRMED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.EXT_CONFIRMED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;

		FOR curOutput IN c_output_nom (p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.EXT_CONFIRMED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.EXT_CONFIRMED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;

		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;

  RETURN ln_return_qty;

END getTotalExtConfQtyPrDelpnt;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalSchedQtyPrDelpnt
-- Description    : Returns aggregated qty for a delivery point on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalSchedQtyPrDelpnt(
  p_delpnt_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delpnt_version.nom_uom(p_delpnt_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		-- loop input nominations
		FOR curInput IN c_input_nom (p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.SCHEDULED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.SCHEDULED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;

		FOR curOutput IN c_output_nom (p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.SCHEDULED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.SCHEDULED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;

		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;

  RETURN ln_return_qty;

END getTotalSchedQtyPrDelpnt;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalReqQtyPrDelstrm
-- Description    : Returns aggregated qty for a delivery_point on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalReqQtyPrDelstrm(
  p_delstrm_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delstrm_version.nom_uom(p_delstrm_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		-- loop input nominations
		FOR curInput IN c_input_nom_destrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.REQUESTED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.REQUESTED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;

		FOR curOutput IN c_output_nom_destrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.REQUESTED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.REQUESTED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;

		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;

  	RETURN ln_return_qty;

END getTotalReqQtyPrDelstrm;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalAccQtyPrDelstrm
-- Description    : Returns aggregated qty for a delivery_point on a given day for a given cycle.
--					This is an example code. More validation and/or checks may be required
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       : For this example code to work properly,
--					nom_uom on delivery_point must have a value. Contract attributes must have values.
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalAccQtyPrDelstrm(
  p_delstrm_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delstrm_version.nom_uom(p_delstrm_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		-- loop input nominations
		FOR curInput IN c_input_nom_destrm(p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.ACCEPTED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.ACCEPTED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;

		FOR curOutput IN c_output_nom_destrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.ACCEPTED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.ACCEPTED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;

		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;

  	RETURN ln_return_qty;

END getTotalAccQtyPrDelstrm;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalExtAccQtyPrDelstrm
-- Description    : Returns aggregated qty for a delivery point on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalExtAccQtyPrDelstrm(
  p_delstrm_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE
)
RETURN INTEGER
--</EC-DOC>
IS
 	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delstrm_version.nom_uom(p_delstrm_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		-- loop input nominations
		FOR curInput IN c_input_nom_destrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.EXT_ACCEPTED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.EXT_ACCEPTED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;

		FOR curOutput IN c_output_nom_destrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.EXT_ACCEPTED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.EXT_ACCEPTED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;

		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;

  	RETURN ln_return_qty;

END getTotalExtAccQtyPrDelstrm;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalAdjQtyPrDelstrm
-- Description    : Returns aggregated qty for a delivery point on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalAdjQtyPrDelstrm(
  p_delstrm_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delstrm_version.nom_uom(p_delstrm_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		-- loop input nominations
		FOR curInput IN c_input_nom_destrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.ADJUSTED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.ADJUSTED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;

		FOR curOutput IN c_output_nom_destrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.ADJUSTED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.ADJUSTED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;

		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;

  	RETURN ln_return_qty;

END getTotalAdjQtyPrDelstrm;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalExtAdjQtyPrDelstrm
-- Description    : Returns aggregated qty for a contract on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalExtAdjQtyPrDelstrm(
  p_delstrm_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delstrm_version.nom_uom(p_delstrm_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		-- loop input nominations
		FOR curInput IN c_input_nom_destrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.EXT_ADJUSTED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.EXT_ADJUSTED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;

		FOR curOutput IN c_output_nom_destrm(p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.EXT_ADJUSTED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.EXT_ADJUSTED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;

		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;

  	RETURN ln_return_qty;

END getTotalExtAdjQtyPrDelstrm;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalConfQtyPrDelstrm
-- Description    : Returns aggregated qty for a delivery point on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalConfQtyPrDelstrm(
  p_delstrm_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delstrm_version.nom_uom(p_delstrm_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		-- loop input nominations
		FOR curInput IN c_input_nom_destrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.CONFIRMED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.CONFIRMED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;

		FOR curOutput IN c_output_nom_destrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.CONFIRMED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.CONFIRMED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;

		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;

  	RETURN ln_return_qty;

END getTotalConfQtyPrDelstrm;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalExtConfQtyPrDelstrm
-- Description    : Returns aggregated qty for a delivery point on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalExtConfQtyPrDelstrm(
  p_delstrm_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delstrm_version.nom_uom(p_delstrm_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		-- loop input nominations
		FOR curInput IN c_input_nom_destrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.EXT_CONFIRMED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.EXT_CONFIRMED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;

		FOR curOutput IN c_output_nom_destrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.EXT_CONFIRMED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.EXT_CONFIRMED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;

		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;

  	RETURN ln_return_qty;


END getTotalExtConfQtyPrDelstrm;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalSchedQtyPrDelstrm
-- Description    : Returns aggregated qty for a delivery point on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalSchedQtyPrDelstrm(
  p_delstrm_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delstrm_version.nom_uom(p_delstrm_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		-- loop input nominations
		FOR curInput IN c_input_nom_destrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.SCHEDULED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.SCHEDULED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;

		FOR curOutput IN c_output_nom_destrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.SCHEDULED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.SCHEDULED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;

		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;

  	RETURN ln_return_qty;

END getTotalSchedQtyPrDelstrm;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalAdjQtyPrLocation
-- Description    : Returns aggregated qty for a nomination location on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalAdjQtyPrLocation(
  p_loc_id            VARCHAR2,
  p_nom_cycle            VARCHAR2,
  p_nom_type           VARCHAR2,
  p_date                 DATE

)
RETURN INTEGER
--</EC-DOC>
IS
  lv_loc_class  VARCHAR2(32) :=NULL;
  lv_delivery_point VARCHAR2(32) := 'DELIVERY_POINT';
   lv_delivery_stream VARCHAR2(32) := 'DELIVERY_STREAM';
	ln_return_qty 	NUMBER := NULL;


BEGIN
  lv_loc_class:=ecdp_objects.GetObjClassName(p_loc_id);
  IF(lv_loc_class = lv_delivery_point) Then
        ln_return_qty:=getTotalAdjInOutQtyPrDelpnt(p_loc_id,p_nom_cycle,p_nom_type,p_date);
        END IF;
  IF(lv_loc_class = lv_delivery_stream) Then
        ln_return_qty:=getTotalAdjInOutQtyPrDelstrm(p_loc_id,p_nom_cycle,p_nom_type,p_date);
  END IF;
  return ln_return_qty;

END getTotalAdjQtyPrLocation;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalIExternalQtyPrLocation
-- Description    : Returns aggregated qty for a nomination location on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalExtAdjQtyPrLocation(
  p_loc_id            VARCHAR2,
  p_nom_cycle            VARCHAR2,
  p_nom_type           VARCHAR2,
  p_date                 DATE

)
RETURN INTEGER
--</EC-DOC>
IS
  lv_loc_class  VARCHAR2(32) :=NULL;
  lv_delivery_point VARCHAR2(32) := 'DELIVERY_POINT';
   lv_delivery_stream VARCHAR2(32) := 'DELIVERY_STREAM';
	ln_return_qty 	NUMBER := NULL;


BEGIN
  lv_loc_class:=ecdp_objects.GetObjClassName(p_loc_id);
  IF(lv_loc_class = lv_delivery_point) Then
        ln_return_qty:=getTotalExtAdjInOutQtyPrDpnt(p_loc_id,p_nom_cycle,p_nom_type,p_date);
        END IF;
  IF(lv_loc_class = lv_delivery_stream) Then
        ln_return_qty:=getTotalExtAdjInOutQtyPrDstrm(p_loc_id,p_nom_cycle,p_nom_type,p_date);
  END IF;
  return ln_return_qty;

END getTotalExtAdjQtyPrLocation;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalConfQtyPrLocation
-- Description    : Returns aggregated qty for a nomination location on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalConfQtyPrLocation(
  p_loc_id            VARCHAR2,
  p_nom_cycle            VARCHAR2,
  p_nom_type           VARCHAR2,
  p_date                 DATE

)
RETURN INTEGER
--</EC-DOC>
IS
  lv_loc_class  VARCHAR2(32) :=NULL;
  lv_delivery_point VARCHAR2(32) := 'DELIVERY_POINT';
   lv_delivery_stream VARCHAR2(32) := 'DELIVERY_STREAM';
	ln_return_qty 	NUMBER := NULL;


BEGIN
  lv_loc_class:=ecdp_objects.GetObjClassName(p_loc_id);
  IF(lv_loc_class = lv_delivery_point) Then
        ln_return_qty:=getTotalConfInOutQtyPrDelpnt(p_loc_id,p_nom_cycle,p_nom_type,p_date);
        END IF;
  IF(lv_loc_class = lv_delivery_stream) Then
        ln_return_qty:=getTotalConfInOutQtyPrDelstrm(p_loc_id,p_nom_cycle,p_nom_type,p_date);
  END IF;
  return ln_return_qty;

END getTotalConfQtyPrLocation;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalSchedQtyPrLocation
-- Description    : Returns aggregated qty for a nomination location on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalSchedQtyPrLocation(
  p_loc_id            VARCHAR2,
  p_nom_cycle            VARCHAR2,
  p_nom_type           VARCHAR2,
  p_date                 DATE

)
RETURN INTEGER
--</EC-DOC>
IS
  lv_loc_class  VARCHAR2(32) :=NULL;
  lv_delivery_point VARCHAR2(32) := 'DELIVERY_POINT';
   lv_delivery_stream VARCHAR2(32) := 'DELIVERY_STREAM';
	ln_return_qty 	NUMBER := NULL;


BEGIN
  lv_loc_class:=ecdp_objects.GetObjClassName(p_loc_id);
  IF(lv_loc_class = lv_delivery_point) Then
        ln_return_qty:=getTotalSchedInOutQtyPrDelpnt(p_loc_id,p_nom_cycle,p_nom_type,p_date);
        END IF;
  IF(lv_loc_class = lv_delivery_stream) Then
        ln_return_qty:=getTotalSchedInOutQtyPrDelstrm(p_loc_id,p_nom_cycle,p_nom_type,p_date);
  END IF;
  return ln_return_qty;

END getTotalSchedQtyPrLocation;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalAdjInOutQtyPrDelpnt
-- Description    : Returns aggregated qty for a delivery point on a given day for a given cycle,
--                  either or output based on parameter.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalAdjInOutQtyPrDelpnt(
  p_delpnt_id            VARCHAR2,
  p_nom_cycle            VARCHAR2,
  p_nom_type           VARCHAR2,
  p_date                 DATE

)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;


BEGIN

	lv_dp_uom := ec_delpnt_version.nom_uom(p_delpnt_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
    IF (p_nom_type = 'ENTRY') THEN
		-- loop input nominations
		FOR curInput IN c_input_nom (p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.ADJUSTED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.ADJUSTED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;
   ln_return_qty:=ln_input_qty;
   END IF;

   IF (p_nom_type = 'EXIT') THEN
		FOR curOutput IN c_output_nom(p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.ADJUSTED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.ADJUSTED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;
    ln_return_qty:=ln_output_qty;
    END IF;

	END IF;

  RETURN ln_return_qty;

END getTotalAdjInOutQtyPrDelpnt;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalExtAdjInOutQtyPrDpnt
-- Description    :returns aggregated qty for a delivery point on a given day for a given cycle,
--                  either or output based on parameter.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalExtAdjInOutQtyPrDpnt(
  p_delpnt_id            VARCHAR2,
  p_nom_cycle            VARCHAR2,
  p_nom_type           VARCHAR2,
  p_date                 DATE

)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;


BEGIN

	lv_dp_uom := ec_delpnt_version.nom_uom(p_delpnt_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
    IF (p_nom_type = 'ENTRY') THEN
		-- loop input nominations
		FOR curInput IN c_input_nom (p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.EXT_ADJUSTED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.EXT_ADJUSTED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;
   ln_return_qty:=ln_input_qty;
   END IF;

   IF (p_nom_type = 'EXIT') THEN
		FOR curOutput IN c_output_nom(p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.EXT_ADJUSTED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.EXT_ADJUSTED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;
    ln_return_qty:=ln_output_qty;
    END IF;

	END IF;

  RETURN ln_return_qty;

END getTotalExtAdjInOutQtyPrDpnt;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalConfInOutQtyPrDelpnt
-- Description    : Returns aggregated qty for a delivery point on a given day for a given cycle,
--                  either or output based on parameter.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalConfInOutQtyPrDelpnt(
  p_delpnt_id            VARCHAR2,
  p_nom_cycle            VARCHAR2,
  p_nom_type           VARCHAR2,
  p_date                 DATE

)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;


BEGIN

	lv_dp_uom := ec_delpnt_version.nom_uom(p_delpnt_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
    IF (p_nom_type = 'ENTRY') THEN
		-- loop input nominations
		FOR curInput IN c_input_nom (p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.CONFIRMED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.CONFIRMED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;
   ln_return_qty:=ln_input_qty;
   END IF;

   IF (p_nom_type = 'EXIT') THEN
		FOR curOutput IN c_output_nom(p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.CONFIRMED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.CONFIRMED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;
    ln_return_qty:=ln_output_qty;
    END IF;

	END IF;

  RETURN ln_return_qty;

END getTotalConfInOutQtyPrDelpnt;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalSchedInOutQtyPrDelpnt
-- Description    : Returns aggregated qty for a delivery point on a given day for a given cycle,
--                  either or output based on parameter.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalSchedInOutQtyPrDelpnt(
  p_delpnt_id            VARCHAR2,
  p_nom_cycle            VARCHAR2,
  p_nom_type           VARCHAR2,
  p_date                 DATE

)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;


BEGIN

	lv_dp_uom := ec_delpnt_version.nom_uom(p_delpnt_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
    IF (p_nom_type = 'ENTRY') THEN
		-- loop input nominations
		FOR curInput IN c_input_nom (p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.SCHEDULED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.SCHEDULED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;
   ln_return_qty:=ln_input_qty;
   END IF;

   IF (p_nom_type = 'EXIT') THEN
		FOR curOutput IN c_output_nom(p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.SCHEDULED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.SCHEDULED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;
    ln_return_qty:=ln_output_qty;
    END IF;

	END IF;

  RETURN ln_return_qty;

END getTotalSchedInOutQtyPrDelpnt;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalAdjInOutQtyPrDelstrm
-- Description    : returns aggregated qty for a delivery point on a given day for a given cycle,
--                  either or output based on parameter.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalAdjInOutQtyPrDelstrm(
  p_delstrm_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
    p_nom_type           VARCHAR2,
  p_date                   DATE
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delstrm_version.nom_uom(p_delstrm_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
    IF (p_nom_type = 'ENTRY') THEN
		-- loop input nominations
		FOR curInput IN c_input_nom_destrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.ADJUSTED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.ADJUSTED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;
    ln_return_qty:=ln_input_qty;
    END IF;

    IF (p_nom_type = 'EXIT') THEN
		FOR curOutput IN c_output_nom_destrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.ADJUSTED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.ADJUSTED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;
    ln_return_qty:=ln_output_qty;
    END IF;
	END IF;

  	RETURN ln_return_qty;

END getTotalAdjInOutQtyPrDelstrm;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalExtAdjInOutQtyPrDstrm
-- Description    : returns aggregated qty for a delivery point on a given day for a given cycle,
--                  either or output based on parameter.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalExtAdjInOutQtyPrDstrm(
  p_delstrm_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
    p_nom_type           VARCHAR2,
  p_date                   DATE
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delstrm_version.nom_uom(p_delstrm_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
    IF (p_nom_type = 'ENTRY') THEN
		-- loop input nominations
		FOR curInput IN c_input_nom_destrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.EXT_ADJUSTED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.EXT_ADJUSTED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;
    ln_return_qty:=ln_input_qty;
    END IF;

    IF (p_nom_type = 'EXIT') THEN
    --loop output nominations
		FOR curOutput IN c_output_nom_destrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.EXT_ADJUSTED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.EXT_ADJUSTED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;
    ln_return_qty:=ln_output_qty;
    END IF;
	END IF;

  	RETURN ln_return_qty;


  	RETURN ln_return_qty;

END getTotalExtAdjInOutQtyPrDstrm;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalConfInOutQtyPrDelstrm
-- Description    : returns aggregated qty for a delivery point on a given day for a given cycle,
--                  either or output based on parameter.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalConfInOutQtyPrDelstrm(
  p_delstrm_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
    p_nom_type           VARCHAR2,
  p_date                   DATE
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delstrm_version.nom_uom(p_delstrm_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
    IF (p_nom_type = 'ENTRY') THEN
		-- loop input nominations
		FOR curInput IN c_input_nom_destrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.CONFIRMED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.CONFIRMED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;
    ln_return_qty:=ln_input_qty;
    END IF;

    IF (p_nom_type = 'EXIT') THEN
		FOR curOutput IN c_output_nom_destrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.CONFIRMED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.CONFIRMED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;
    ln_return_qty:=ln_output_qty;
    END IF;
	END IF;

  	RETURN ln_return_qty;

END getTotalConfInOutQtyPrDelstrm;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalSchedInOutQtyPrDelstrm
-- Description    : returns aggregated qty for a delivery point on a given day for a given cycle,
--                  either or output based on parameter.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalSchedInOutQtyPrDelstrm(
  p_delstrm_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
    p_nom_type           VARCHAR2,
  p_date                   DATE
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delstrm_version.nom_uom(p_delstrm_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
    IF (p_nom_type = 'ENTRY') THEN
		-- loop input nominations
		FOR curInput IN c_input_nom_destrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.SCHEDULED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.SCHEDULED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;
    ln_return_qty:=ln_input_qty;
    END IF;

    IF (p_nom_type = 'EXIT') THEN
		FOR curOutput IN c_output_nom_destrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.SCHEDULED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.SCHEDULED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;
    ln_return_qty:=ln_output_qty;
    END IF;
	END IF;

  	RETURN ln_return_qty;

END getTotalSchedInOutQtyPrDelstrm;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalSchedInOutQtyPrBU
-- Description    : return input or output nominations per business unit per day
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : class_dependency, class_db_mapping, objloc_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalSchedInOutQtyPrBU(p_business_unit_id VARCHAR2,
                                   p_daytime          DATE,
                                   p_nomination_type  VARCHAR2)
  RETURN NUMBER
--</EC-DOC>
 IS
  CURSOR c_classes IS
    SELECT c.db_object_name, c.db_object_attribute
      FROM class_dependency_cnfg d, class_cnfg c
     WHERE d.child_class = c.class_name
       AND d.parent_class = 'NOMINATION_LOCATION'
       AND d.dependency_type = 'IMPLEMENTS';

  lv_sql         VARCHAR2(2000);
  lv_main        VARCHAR2(240);
  lv_version     VARCHAR2(240);
  lv_date	     VARCHAR2(100);
  ln_sum         NUMBER;
  ln_total_sum   NUMBER:= 0;

BEGIN

  FOR curClasses IN c_classes LOOP
    lv_version := curClasses.db_object_attribute;
    lv_main    := curClasses.db_object_name;
    lv_date    := EcDp_DynSql.date_to_string(p_daytime);

    IF p_nomination_type = 'EXIT' THEN  --output nomination
      lv_sql := 'SELECT sum(b.scheduled_out_qty)';
      lv_sql := lv_sql || ' FROM ' || lv_version || ', objloc_day_nomination b';
      lv_sql := lv_sql || ' WHERE ' || lv_version || '.object_id = b.object_id';
      lv_sql := lv_sql || ' AND '||lv_version||'.daytime <= '||lv_date;
	  lv_sql := lv_sql || ' AND Nvl('||lv_version||'.end_date, '||lv_date||'+1) > '||lv_date;
      lv_sql := lv_sql || ' AND b.daytime ='||lv_date;
      lv_sql := lv_sql || ' AND ' || lv_version || '.business_unit_id = ''' || p_business_unit_id || '''';
      EXECUTE IMMEDIATE lv_sql INTO ln_sum;

    ELSIF p_nomination_type = 'ENTRY' THEN  --input nomination
      lv_sql := 'SELECT sum(b.scheduled_in_qty)';
      lv_sql := lv_sql || ' FROM ' || lv_version || ', objloc_day_nomination b';
      lv_sql := lv_sql || ' WHERE ' || lv_version || '.object_id = b.object_id';
      lv_sql := lv_sql || ' AND '||lv_version||'.daytime <= '||lv_date;
	  lv_sql := lv_sql || ' AND Nvl('||lv_version||'.end_date, '||lv_date||'+1) > '||lv_date;
      lv_sql := lv_sql || ' AND b.daytime ='||lv_date;
      lv_sql := lv_sql || ' AND ' || lv_version || '.business_unit_id = ''' || p_business_unit_id || '''';
      EXECUTE IMMEDIATE lv_sql INTO ln_sum;

    END IF;
    ln_total_sum := ln_total_sum + NVL(ln_sum, 0);
  END LOOP;
  ln_total_sum := nvl(ln_total_sum, 0);

  RETURN ln_total_sum;
END getTotalSchedInOutQtyPrBU;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalReqTransfInOutQtyPrBU
-- Description    : return input or output transfer nominations per business unit per day
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_transfer, nav_model_object_relation
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalReqTransfInOutQtyPrBU(p_business_unit_id VARCHAR2,
                                       p_daytime          DATE,
                                       p_nomination_type  VARCHAR2,
                                       p_nav_model        VARCHAR2)

 RETURN NUMBER
--</EC-DOC>
 IS
  CURSOR c_req_qty IS
    select a.requested_qty
      from nompnt_day_transfer a, nav_model_object_relation b
     where b.ancestor_object_id = p_business_unit_id
       and a.daytime = p_daytime
       and a.nomination_type = p_nomination_type
       and b.model = p_nav_model
       and a.object_id = b.object_id;

  ln_sum       NUMBER;
  ln_total_sum NUMBER := 0;

BEGIN

  FOR curReqQty IN c_req_qty LOOP
    IF p_nomination_type = 'TRAN_INPUT' THEN
      ln_sum       := Nvl(curReqQty.Requested_Qty, 0);
      ln_total_sum := ln_total_sum + ln_sum;
    ELSIF p_nomination_type = 'TRAN_OUTPUT' THEN
      ln_sum       := Nvl(curReqQty.Requested_Qty, 0);
      ln_total_sum := ln_total_sum + ln_sum;
    END IF;
  END LOOP;
  ln_total_sum := nvl(ln_total_sum, 0);

  RETURN ln_total_sum;

END getTotalReqTransfInOutQtyPrBU;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSubDayReqQtyPrDelpnt
-- Description    : Returns aggregated qty for a delivery_point on a given time for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_sub_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getSubDayReqQtyPrDelpnt(
  p_delpnt_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE,
  p_summer_time          VARCHAR2,
  p_nom_type             VARCHAR2 DEFAULT 'ENTRY_EXIT'
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delpnt_version.nom_uom(p_delpnt_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		IF (p_nom_type = 'ENTRY' OR p_nom_type = 'ENTRY_EXIT') THEN
		-- loop input nominations
		FOR curInput IN c_input_nom_sub_day (p_delpnt_id, p_nom_cycle, p_date, p_summer_time) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.REQUESTED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.REQUESTED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;
		END IF;

		IF (p_nom_type = 'EXIT' OR p_nom_type = 'ENTRY_EXIT') THEN
		FOR curOutput IN c_output_nom_sub_day (p_delpnt_id, p_nom_cycle, p_date, p_summer_time) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.REQUESTED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.REQUESTED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;
		END IF;

		IF p_nom_type = 'ENTRY' THEN
			ln_return_qty := Nvl(ln_input_qty, 0);
		ELSIF p_nom_type = 'EXIT' THEN
			ln_return_qty := Nvl(ln_output_qty, 0);
		ELSIF p_nom_type = 'ENTRY_EXIT' THEN
		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;
	END IF;

  RETURN ln_return_qty;

END getSubDayReqQtyPrDelpnt;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSubDayAccQtyPrDelpnt
-- Description    : Returns aggregated qty for a delivery_point on a given hour for a given cycle.
--					This is an example code. More validation and/or checks may be required
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_sub_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       : For this example code to work properly,
--					nom_uom on delivery_point must have a value. Contract attributes must have values.
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getSubDayAccQtyPrDelpnt(
  p_delpnt_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE,
  p_summer_time          VARCHAR2,
  p_nom_type             VARCHAR2 DEFAULT 'ENTRY_EXIT'
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delpnt_version.nom_uom(p_delpnt_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		IF (p_nom_type = 'ENTRY' OR p_nom_type = 'ENTRY_EXIT') THEN
		-- loop input nominations
		FOR curInput IN c_input_nom_sub_day (p_delpnt_id, p_nom_cycle, p_date, p_summer_time) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.ACCEPTED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.ACCEPTED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;
		END IF;

		IF (p_nom_type = 'EXIT' OR p_nom_type = 'ENTRY_EXIT') THEN
		FOR curOutput IN c_output_nom_sub_day (p_delpnt_id, p_nom_cycle, p_date, p_summer_time) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.ACCEPTED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.ACCEPTED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;
		END IF;

		IF p_nom_type = 'ENTRY' THEN
			ln_return_qty := Nvl(ln_input_qty, 0);
		ELSIF p_nom_type = 'EXIT' THEN
			ln_return_qty := Nvl(ln_output_qty, 0);
		ELSIF p_nom_type = 'ENTRY_EXIT' THEN
		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;
	END IF;

  RETURN ln_return_qty;

END getSubDayAccQtyPrDelpnt;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSubDayExtAccQtyPrDelpnt
-- Description    : Returns aggregated qty for a delivery point on a given hour for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_sub_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getSubDayExtAccQtyPrDelpnt(
  p_delpnt_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE,
  p_summer_time          VARCHAR2,
  p_nom_type             VARCHAR2 DEFAULT 'ENTRY_EXIT'
)
RETURN INTEGER
--</EC-DOC>
IS
 	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delpnt_version.nom_uom(p_delpnt_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		IF (p_nom_type = 'ENTRY' OR p_nom_type = 'ENTRY_EXIT') THEN
		-- loop input nominations
		FOR curInput IN c_input_nom_sub_day (p_delpnt_id, p_nom_cycle, p_date, p_summer_time) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.EXT_ACCEPTED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.EXT_ACCEPTED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;
		END IF;

		IF (p_nom_type = 'EXIT' OR p_nom_type = 'ENTRY_EXIT') THEN
		FOR curOutput IN c_output_nom_sub_day (p_delpnt_id, p_nom_cycle, p_date, p_summer_time) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.EXT_ACCEPTED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.EXT_ACCEPTED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;
		END IF;

		IF p_nom_type = 'ENTRY' THEN
			ln_return_qty := Nvl(ln_input_qty, 0);
		ELSIF p_nom_type = 'EXIT' THEN
			ln_return_qty := Nvl(ln_output_qty, 0);
		ELSIF p_nom_type = 'ENTRY_EXIT' THEN
		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;
	END IF;

  RETURN ln_return_qty;

END getSubDayExtAccQtyPrDelpnt;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSubDayAdjQtyPrDelpnt
-- Description    : Returns aggregated qty for a delivery point on a given hour for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_sub_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getSubDayAdjQtyPrDelpnt(
  p_delpnt_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE,
  p_summer_time          VARCHAR2,
  p_nom_type             VARCHAR2 DEFAULT 'ENTRY_EXIT'
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delpnt_version.nom_uom(p_delpnt_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		IF (p_nom_type = 'ENTRY' OR p_nom_type = 'ENTRY_EXIT') THEN
		-- loop input nominations
		FOR curInput IN c_input_nom_sub_day (p_delpnt_id, p_nom_cycle, p_date, p_summer_time) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.ADJUSTED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.ADJUSTED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;
		END IF;

		IF (p_nom_type = 'EXIT' OR p_nom_type = 'ENTRY_EXIT') THEN
		FOR curOutput IN c_output_nom_sub_day (p_delpnt_id, p_nom_cycle, p_date, p_summer_time) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.ADJUSTED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.ADJUSTED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;
		END IF;

		IF p_nom_type = 'ENTRY' THEN
			ln_return_qty := Nvl(ln_input_qty, 0);
		ELSIF p_nom_type = 'EXIT' THEN
			ln_return_qty := Nvl(ln_output_qty, 0);
		ELSIF p_nom_type = 'ENTRY_EXIT' THEN
		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;
	END IF;

  RETURN ln_return_qty;

END getSubDayAdjQtyPrDelpnt;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSubDayExtAdjQtyPrDelpnt
-- Description    : Returns aggregated qty for a contract on a given hour for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_sub_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getSubDayExtAdjQtyPrDelpnt(
  p_delpnt_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE,
  p_summer_time          VARCHAR2,
  p_nom_type             VARCHAR2 DEFAULT 'ENTRY_EXIT'
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delpnt_version.nom_uom(p_delpnt_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		IF (p_nom_type = 'ENTRY' OR p_nom_type = 'ENTRY_EXIT') THEN
		-- loop input nominations
		FOR curInput IN c_input_nom_sub_day (p_delpnt_id, p_nom_cycle, p_date, p_summer_time) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.EXT_ADJUSTED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.EXT_ADJUSTED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;
		END IF;

		IF (p_nom_type = 'EXIT' OR p_nom_type = 'ENTRY_EXIT') THEN
		FOR curOutput IN c_output_nom_sub_day (p_delpnt_id, p_nom_cycle, p_date, p_summer_time) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.EXT_ADJUSTED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.EXT_ADJUSTED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;
		END IF;

		IF p_nom_type = 'ENTRY' THEN
			ln_return_qty := Nvl(ln_input_qty, 0);
		ELSIF p_nom_type = 'EXIT' THEN
			ln_return_qty := Nvl(ln_output_qty, 0);
		ELSIF p_nom_type = 'ENTRY_EXIT' THEN
		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;
	END IF;

  RETURN ln_return_qty;

END getSubDayExtAdjQtyPrDelpnt;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSubDayConfQtyPrDelpnt
-- Description    : Returns aggregated qty for a delivery point on a given hour for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_sub_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getSubDayConfQtyPrDelpnt(
  p_delpnt_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE,
  p_summer_time          VARCHAR2,
  p_nom_type             VARCHAR2 DEFAULT 'ENTRY_EXIT'
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delpnt_version.nom_uom(p_delpnt_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		IF (p_nom_type = 'ENTRY' OR p_nom_type = 'ENTRY_EXIT') THEN
		-- loop input nominations
		FOR curInput IN c_input_nom_sub_day (p_delpnt_id, p_nom_cycle, p_date, p_summer_time) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.CONFIRMED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.CONFIRMED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;
		END IF;

		IF (p_nom_type = 'EXIT' OR p_nom_type = 'ENTRY_EXIT') THEN
		FOR curOutput IN c_output_nom_sub_day (p_delpnt_id, p_nom_cycle, p_date, p_summer_time) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.CONFIRMED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.CONFIRMED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;
		END IF;

		IF p_nom_type = 'ENTRY' THEN
			ln_return_qty := Nvl(ln_input_qty, 0);
		ELSIF p_nom_type = 'EXIT' THEN
			ln_return_qty := Nvl(ln_output_qty, 0);
		ELSIF p_nom_type = 'ENTRY_EXIT' THEN
		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;
	END IF;

  RETURN ln_return_qty;

END getSubDayConfQtyPrDelpnt;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSubDayExtConfQtyPrDelpnt
-- Description    : Returns aggregated qty for a delivery point on a given hour for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_sub_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getSubDayExtConfQtyPrDelpnt(
  p_delpnt_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE,
  p_summer_time          VARCHAR2,
  p_nom_type             VARCHAR2 DEFAULT 'ENTRY_EXIT'
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delpnt_version.nom_uom(p_delpnt_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		IF (p_nom_type = 'ENTRY' OR p_nom_type = 'ENTRY_EXIT') THEN
		-- loop input nominations
		FOR curInput IN c_input_nom_sub_day (p_delpnt_id, p_nom_cycle, p_date, p_summer_time) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.EXT_CONFIRMED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.EXT_CONFIRMED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;
		END IF;

		IF (p_nom_type = 'EXIT' OR p_nom_type = 'ENTRY_EXIT') THEN
		FOR curOutput IN c_output_nom_sub_day (p_delpnt_id, p_nom_cycle, p_date, p_summer_time) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.EXT_CONFIRMED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.EXT_CONFIRMED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;
		END IF;

		IF p_nom_type = 'ENTRY' THEN
			ln_return_qty := Nvl(ln_input_qty, 0);
		ELSIF p_nom_type = 'EXIT' THEN
			ln_return_qty := Nvl(ln_output_qty, 0);
		ELSIF p_nom_type = 'ENTRY_EXIT' THEN
		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;
	END IF;

  RETURN ln_return_qty;

END getSubDayExtConfQtyPrDelpnt;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSubDaySchedQtyPrDelpnt
-- Description    : Returns aggregated qty for a delivery point on a given hour for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_sub_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getSubDaySchedQtyPrDelpnt(
  p_delpnt_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE,
  p_summer_time          VARCHAR2,
  p_nom_type             VARCHAR2 DEFAULT 'ENTRY_EXIT'
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delpnt_version.nom_uom(p_delpnt_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		IF (p_nom_type = 'ENTRY' OR p_nom_type = 'ENTRY_EXIT') THEN
		-- loop input nominations
		FOR curInput IN c_input_nom_sub_day (p_delpnt_id, p_nom_cycle, p_date, p_summer_time) LOOP
			-- validate contract attributes
			IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.SCHEDULED_QTY IS NOT NULL) THEN
				ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.SCHEDULED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
			END IF;
		END LOOP;
		END IF;

		IF (p_nom_type = 'EXIT' OR p_nom_type = 'ENTRY_EXIT') THEN
		FOR curOutput IN c_output_nom_sub_day (p_delpnt_id, p_nom_cycle, p_date, p_summer_time) LOOP
			-- validate contract attributes
			IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.SCHEDULED_QTY IS NOT NULL) THEN
				ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.SCHEDULED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
			END IF;
		END LOOP;
		END IF;

		IF p_nom_type = 'ENTRY' THEN
			ln_return_qty := Nvl(ln_input_qty, 0);
		ELSIF p_nom_type = 'EXIT' THEN
			ln_return_qty := Nvl(ln_output_qty, 0);
		ELSIF p_nom_type = 'ENTRY_EXIT' THEN
		ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
	END IF;
	END IF;

  RETURN ln_return_qty;

END getSubDaySchedQtyPrDelpnt;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSubDayAdjQtyPrDelstrm
-- Description    : Returns aggregated qty for a delivery stream on a given hour for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_sub_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getSubDayAdjQtyPrDelstrm(
  p_delstrm_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE,
  p_summer_time          VARCHAR2,
  p_nom_type             VARCHAR2 DEFAULT 'ENTRY_EXIT'
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delstrm_version.nom_uom(p_delstrm_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		IF (p_nom_type = 'ENTRY' OR p_nom_type = 'ENTRY_EXIT') THEN
			-- loop input nominations
			FOR curInput IN c_input_nom_sub_day_delstrm (p_delstrm_id, p_nom_cycle, p_date, p_summer_time) LOOP
				-- validate contract attributes
				IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.ADJUSTED_QTY IS NOT NULL) THEN
					ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.ADJUSTED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
				END IF;
			END LOOP;
		END IF;

		IF (p_nom_type = 'EXIT' OR p_nom_type = 'ENTRY_EXIT') THEN
			FOR curOutput IN c_output_nom_sub_day_delstrm (p_delstrm_id, p_nom_cycle, p_date, p_summer_time) LOOP
				-- validate contract attributes
				IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.ADJUSTED_QTY IS NOT NULL) THEN
					ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.ADJUSTED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
				END IF;
			END LOOP;
		END IF;

		IF p_nom_type = 'ENTRY' THEN
			ln_return_qty := Nvl(ln_input_qty, 0);
		ELSIF p_nom_type = 'EXIT' THEN
			ln_return_qty := Nvl(ln_output_qty, 0);
		ELSIF p_nom_type = 'ENTRY_EXIT' THEN
			ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
		END IF;
	END IF;

  RETURN ln_return_qty;

END getSubDayAdjQtyPrDelstrm;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSubDayConfQtyPrDelstrm
-- Description    : Returns aggregated qty for a delivery stream on a given hour for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_sub_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getSubDayConfQtyPrDelstrm(
  p_delstrm_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE,
  p_summer_time          VARCHAR2,
  p_nom_type             VARCHAR2 DEFAULT 'ENTRY_EXIT'
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delstrm_version.nom_uom(p_delstrm_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		IF (p_nom_type = 'ENTRY' OR p_nom_type = 'ENTRY_EXIT') THEN
			-- loop input nominations
			FOR curInput IN c_input_nom_sub_day_delstrm (p_delstrm_id, p_nom_cycle, p_date, p_summer_time) LOOP
				-- validate contract attributes
				IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.CONFIRMED_QTY IS NOT NULL) THEN
					ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.CONFIRMED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
				END IF;
			END LOOP;
		END IF;

		IF (p_nom_type = 'EXIT' OR p_nom_type = 'ENTRY_EXIT') THEN
			FOR curOutput IN c_output_nom_sub_day_delstrm (p_delstrm_id, p_nom_cycle, p_date, p_summer_time) LOOP
				-- validate contract attributes
				IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.CONFIRMED_QTY IS NOT NULL) THEN
					ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.CONFIRMED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
				END IF;
			END LOOP;
		END IF;

		IF p_nom_type = 'ENTRY' THEN
			ln_return_qty := Nvl(ln_input_qty, 0);
		ELSIF p_nom_type = 'EXIT' THEN
			ln_return_qty := Nvl(ln_output_qty, 0);
		ELSIF p_nom_type = 'ENTRY_EXIT' THEN
			ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
		END IF;
	END IF;

  RETURN ln_return_qty;

END getSubDayConfQtyPrDelstrm;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSubDaySchedQtyPrDelstrm
-- Description    : Returns aggregated qty for a delivery stream on a given hour for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_sub_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getSubDaySchedQtyPrDelstrm(
  p_delstrm_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_date                   DATE,
  p_summer_time          VARCHAR2,
  p_nom_type             VARCHAR2 DEFAULT 'ENTRY_EXIT'
)
RETURN INTEGER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN
	lv_dp_uom := ec_delstrm_version.nom_uom(p_delstrm_id, p_date, '<=');
	IF lv_dp_uom IS NOT NULL THEN
		IF (p_nom_type = 'ENTRY' OR p_nom_type = 'ENTRY_EXIT') THEN
			-- loop input nominations
			FOR curInput IN c_input_nom_sub_day_delstrm (p_delstrm_id, p_nom_cycle, p_date, p_summer_time) LOOP
				-- validate contract attributes
				IF (curInput.uom IS NOT NULL AND curInput.condition IS NOT NULL AND curInput.SCHEDULED_QTY IS NOT NULL) THEN
					ln_input_qty := Nvl(ln_input_qty, 0) + ecdp_nomination.converteQty(curInput.SCHEDULED_QTY, curInput.uom, lv_dp_uom, curInput.condition, 'GRS', curInput.pct);
				END IF;
			END LOOP;
		END IF;

		IF (p_nom_type = 'EXIT' OR p_nom_type = 'ENTRY_EXIT') THEN
			FOR curOutput IN c_output_nom_sub_day_delstrm (p_delstrm_id, p_nom_cycle, p_date, p_summer_time) LOOP
				-- validate contract attributes
				IF (curOutput.uom IS NOT NULL AND curOutput.condition IS NOT NULL AND curOutput.SCHEDULED_QTY IS NOT NULL) THEN
					ln_output_qty := Nvl(ln_output_qty, 0) + ecdp_nomination.converteQty(curOutput.SCHEDULED_QTY, curOutput.uom, lv_dp_uom, curOutput.condition, 'GRS', curOutput.pct);
				END IF;
			END LOOP;
		END IF;

		IF p_nom_type = 'ENTRY' THEN
			ln_return_qty := Nvl(ln_input_qty, 0);
		ELSIF p_nom_type = 'EXIT' THEN
			ln_return_qty := Nvl(ln_output_qty, 0);
		ELSIF p_nom_type = 'ENTRY_EXIT' THEN
			ln_return_qty := Nvl(ln_input_qty, 0) - Nvl(ln_output_qty, 0);
		END IF;
	END IF;

  RETURN ln_return_qty;

END getSubDaySchedQtyPrDelstrm;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalSubDayAdjQtyPrLoc
-- Description    : Returns aggregated qty for a nomination location on a given hour for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_sub_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalSubDayAdjQtyPrLoc(
  p_loc_id            VARCHAR2,
  p_nom_cycle            VARCHAR2,
  p_nom_type           VARCHAR2,
  p_date                 DATE,
  p_summer_time        VARCHAR2

)
RETURN INTEGER
--</EC-DOC>
IS
  lv_loc_class  VARCHAR2(32) :=NULL;
  lv_delivery_point VARCHAR2(32) := 'DELIVERY_POINT';
   lv_delivery_stream VARCHAR2(32) := 'DELIVERY_STREAM';
	ln_return_qty 	NUMBER := NULL;


BEGIN
	lv_loc_class:=ecdp_objects.GetObjClassName(p_loc_id);
	IF(lv_loc_class = lv_delivery_point) Then
		ln_return_qty:=getSubDayAdjQtyPrDelpnt(p_loc_id, p_nom_cycle, p_date, p_summer_time, p_nom_type);
	END IF;
	IF(lv_loc_class = lv_delivery_stream) Then
		ln_return_qty:=getSubDayAdjQtyPrDelstrm(p_loc_id, p_nom_cycle, p_date, p_summer_time, p_nom_type);
	END IF;
	RETURN ln_return_qty;

END getTotalSubDayAdjQtyPrLoc;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalSubDayConfQtyPrLoc
-- Description    : Returns aggregated qty for a nomination location on a given hour for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_sub_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalSubDayConfQtyPrLoc(
  p_loc_id            VARCHAR2,
  p_nom_cycle            VARCHAR2,
  p_nom_type           VARCHAR2,
  p_date                 DATE,
  p_summer_time        VARCHAR2

)
RETURN INTEGER
--</EC-DOC>
IS
  lv_loc_class  VARCHAR2(32) :=NULL;
  lv_delivery_point VARCHAR2(32) := 'DELIVERY_POINT';
   lv_delivery_stream VARCHAR2(32) := 'DELIVERY_STREAM';
	ln_return_qty 	NUMBER := NULL;


BEGIN
  lv_loc_class:=ecdp_objects.GetObjClassName(p_loc_id);
  IF(lv_loc_class = lv_delivery_point) Then
        ln_return_qty:=getSubDayConfQtyPrDelpnt(p_loc_id, p_nom_cycle, p_date, p_summer_time, p_nom_type);
        END IF;
	IF(lv_loc_class = lv_delivery_stream) Then
		ln_return_qty:=getSubDayConfQtyPrDelstrm(p_loc_id, p_nom_cycle, p_date, p_summer_time, p_nom_type);
	END IF;
  return ln_return_qty;

END getTotalSubDayConfQtyPrLoc;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalSubDaySchedQtyPrLoc
-- Description    : Returns aggregated qty for a nomination location on a given hour for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_sub_day_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalSubDaySchedQtyPrLoc(
  p_loc_id            VARCHAR2,
  p_nom_cycle            VARCHAR2,
  p_nom_type           VARCHAR2,
  p_date                 DATE,
  p_summer_time        VARCHAR2
)
RETURN INTEGER
--</EC-DOC>
IS
  lv_loc_class  VARCHAR2(32) :=NULL;
  lv_delivery_point VARCHAR2(32) := 'DELIVERY_POINT';
   lv_delivery_stream VARCHAR2(32) := 'DELIVERY_STREAM';
	ln_return_qty 	NUMBER := NULL;


BEGIN
  lv_loc_class:=ecdp_objects.GetObjClassName(p_loc_id);
  IF(lv_loc_class = lv_delivery_point) Then
        ln_return_qty:=getSubDaySchedQtyPrDelpnt(p_loc_id, p_nom_cycle, p_date, p_nom_type);
        END IF;
	IF(lv_loc_class = lv_delivery_stream) Then
		ln_return_qty:=getSubDaySchedQtyPrDelstrm(p_loc_id, p_nom_cycle, p_date, p_summer_time, p_nom_type);
	END IF;
  return ln_return_qty;

END getTotalSubDaySchedQtyPrLoc;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : valid_nompnt
-- Description    : User exit for chosing nomination point (Nomination Point, Counter Nomination Point)
--                Used for validating nomination points in popups, projects can insert logic to narrow the list of possible nomination points.
--                p_nompnt_id  - nomination point which is validated
--                p_nomination_category  - Which nomination point should be possible to choose from (based on the entry, exit location)
--                p_bf_number  - Which screen does it originate from, projects have the possibility to do special validation for different screens
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Return Y if nompnt have been validated and matched the criteria(s)
--
---------------------------------------------------------------------------------------------------
FUNCTION valid_nompnt(p_nompnt_id VARCHAR2,
                      p_nomination_category VARCHAR2 DEFAULT NULL,
                      p_bf_number VARCHAR2 DEFAULT NULL
                      )

RETURN VARCHAR2
IS

-- Used for finding which nompnt category
lv_entry_location_id nomination_point.entry_location_id%TYPE;
lv_exit_location_id  nomination_point.exit_location_id%TYPE;

lv_valid VARCHAR2(1);

BEGIN
    ecdp_dynsql.WriteTempText('OHS','p_bf_number:' || p_bf_number ||', p_nomination_category:' ||p_nomination_category);
  IF p_nomination_category IS NOT NULL THEN
    lv_valid := 'N';

    lv_entry_location_id := ec_nomination_point.entry_location_id(p_nompnt_id);
    lv_exit_location_id := ec_nomination_point.exit_location_id(p_nompnt_id);

    IF p_nomination_category = 'ENTRY_EXIT_PATH' THEN
       lv_valid := 'Y';
    ELSIF p_nomination_category = 'EXIT' THEN
       IF lv_exit_location_id is not null and lv_entry_location_id is null then
          lv_valid := 'Y';
       END IF;
    ELSIF p_nomination_category = 'ENTRY' THEN
       IF lv_exit_location_id is null AND lv_entry_location_id is not null then
          lv_valid := 'Y';
       END IF;
    ELSIF p_nomination_category = 'PATH' THEN
       IF lv_exit_location_id is not null AND lv_entry_location_id is not null THEN
          lv_valid := 'Y';
       END IF;
    ELSIF p_nomination_category = 'EXIT_ENTRY' THEN
       IF (lv_exit_location_id is not null AND lv_entry_location_id is null)
           OR (lv_exit_location_id is null AND lv_entry_location_id is not null) then
          lv_valid := 'Y';
       END IF;
    ELSIF p_nomination_category = 'EXIT_PATH' THEN
       IF (lv_exit_location_id is not null and lv_entry_location_id is null)
           OR (lv_exit_location_id is not null AND lv_entry_location_id is not null) then
          lv_valid := 'Y';
       END IF;
    ELSIF p_nomination_category = 'ENTRY_PATH' THEN
       IF (lv_entry_location_id is not null and lv_exit_location_id is null)
           OR (lv_exit_location_id is not null AND lv_entry_location_id is not null) then
          lv_valid := 'Y';
       END IF;
    ELSE
     lv_valid := 'Y';
    END IF;

  END IF;


RETURN lv_valid;
--RETURN 'Y';

END valid_nompnt;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : valid_nompnt
-- Description    : User exit for chosing nomination point (Nomination Point, Counter Nomination Point)
--                Used for validating nomination points in popups, projects can insert logic to narrow the list of possible nomination points.
--                p_nompnt_id  - nomination point which is validated
--                p_ref_nompnt_id  - Sending in a nomination point to do validation based on (used for counter)
--                p_bf_profile  - BF Profile for the screen - possible to add different BF profiling for validation
--                p_nomination_category  - Which nomination point should be possible to choose from (based on the entry, exit location)
--                p_bf_number  - Which screen does it originate from, projects have the possibility to do special validation for different screens
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Return Y if nompnt have been validated and matched the criteria(s)
--
---------------------------------------------------------------------------------------------------
FUNCTION valid_counter_nompnt(p_nompnt_id VARCHAR2,
                              p_ref_nompnt_id VARCHAR2,
                              p_bf_profile VARCHAR2 DEFAULT NULL,
                              p_nomination_category VARCHAR2 DEFAULT NULL,
                              p_bf_number VARCHAR2 DEFAULT NULL,
                              p_show_operational VARCHAR2 DEFAULT NULL
                              )
RETURN VARCHAR2
IS


lv_valid VARCHAR2(1);

BEGIN
      ecdp_dynsql.WriteTempText('OHS2','p_nompnt_id:' || p_nompnt_id ||', p_ref_nompnt_id:' ||p_ref_nompnt_id||', p_bf_profile:' ||p_bf_profile||', p_nomination_category:' ||p_nomination_category||', p_bf_number:' ||p_bf_number);
  -- Set it to default Y
  lv_valid := 'Y';

  IF p_nompnt_id = p_ref_nompnt_id THEN
     lv_valid := 'N';
  ELSIF REPLACE(p_bf_profile,'$BFPROFILE$',null) IS NOT NULL THEN
    IF ec_contract.bf_profile(ec_nomination_point.contract_id(p_nompnt_id)) != p_bf_profile THEN
       lv_valid := 'N';
    END IF;
  END IF;




RETURN lv_valid;
--RETURN 'Y';

END valid_counter_nompnt;

 --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function       : getTransferCounterQuantity
  -- Description    :
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   : NOMPNT_DAY_TRANSFER
  -- Using functions:
  --
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  --
  ---------------------------------------------------------------------------------------------------
FUNCTION getTransferCounterQuantity(p_transfer_seq NUMBER, p_column VARCHAR2)
RETURN NUMBER

IS

CURSOR c_nom_transfer(b_daytime DATE,b_nompnt_id VARCHAR2, b_counter_nompnt_id VARCHAR2, b_type VARCHAR2, b_service VARCHAR2)
IS
SELECT   *
FROM     NOMPNT_DAY_TRANSFER nt
WHERE    nt.daytime = b_daytime
AND      nt.object_id = b_nompnt_id
AND      nt.counter_nompnt_id = b_counter_nompnt_id
AND      nt.nomination_type = b_type
AND      nt.transfer_service = b_service;

ln_qty NUMBER;
lv_nomination_type prosty_codes.code%TYPE;
BEGIN

ln_qty := 0;

IF ec_nompnt_day_transfer.nomination_type(p_transfer_seq) = 'TRAN_INPUT' THEN
   lv_nomination_type := 'TRAN_OUTPUT';
ELSE
   lv_nomination_type := 'TRAN_INPUT';
END IF;

FOR r_nom_transfer IN c_nom_transfer(ec_nompnt_day_transfer.daytime(p_transfer_seq), ec_nompnt_day_transfer.counter_nompnt_id(p_transfer_seq), ec_nompnt_day_transfer.object_id(p_transfer_seq), lv_nomination_type, ec_nompnt_day_transfer.transfer_service(p_transfer_seq)) LOOP

   IF p_column = 'REQUESTED' THEN
      ln_qty := ln_qty + r_nom_transfer.requested_qty;
   ELSIF p_column = 'ACCEPTED' THEN
      ln_qty := ln_qty + r_nom_transfer.accepted_qty;
   ELSIF p_column = 'ADJUSTED' THEN
      ln_qty := ln_qty + r_nom_transfer.adjusted_qty;
   ELSIF p_column = 'SCHEDULED' THEN
      ln_qty := ln_qty + r_nom_transfer.scheduled_qty;
   END IF;

END LOOP;


--Send blank if qty = 0
IF ln_qty = 0 THEN
   ln_qty := NULL;
ELSE
   ln_qty := qty_sig_converter(ec_nompnt_day_transfer.object_id(p_transfer_seq),lv_nomination_type,ec_nompnt_day_transfer.daytime(p_transfer_seq), ln_qty);
END IF;

RETURN ln_qty;

END getTransferCounterQuantity;


 --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function       : getTransferSummaryCounterQty
  -- Description    :
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   : NOMPNT_DAY_TRANSFER
  -- Using functions:
  --
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  --
  ---------------------------------------------------------------------------------------------------
FUNCTION getTransferSummaryCounterQty(p_daytime DATE, p_nompnt_id VARCHAR2, p_counter_nompnt_id VARCHAR2,  p_column VARCHAR2, p_service VARCHAR2, p_transfer_type VARCHAR2)
RETURN NUMBER

IS

CURSOR c_nom_transfer(b_daytime Date, b_nompnt_id VARCHAR2, b_counter_nompnt_id VARCHAR2, b_type VARCHAR2, b_service VARCHAR2)
IS
SELECT   *
FROM     NOMPNT_DAY_TRANSFER nt
WHERE    nt.daytime = b_daytime
AND      nt.object_id = b_nompnt_id
AND      nt.counter_nompnt_id = b_counter_nompnt_id
AND      nt.nomination_type = b_type
AND      nt.transfer_service = b_service;

ln_qty NUMBER;
lv_transfer_type prosty_codes.code%TYPE;
ln_sign NUMBER;

BEGIN

ln_qty := 0;

IF p_transfer_type = 'TRAN_INPUT' THEN
   lv_transfer_type := 'TRAN_OUTPUT';
ELSE
   lv_transfer_type := 'TRAN_INPUT';
END IF;

FOR r_nom_transfer IN c_nom_transfer(p_daytime, p_nompnt_id, p_counter_nompnt_id, lv_transfer_type, p_service) LOOP

   IF p_column = 'REQUESTED' THEN
      ln_qty := ln_qty + r_nom_transfer.requested_qty;
   ELSIF p_column = 'ACCEPTED' THEN
      ln_qty := ln_qty + r_nom_transfer.accepted_qty;
   ELSIF p_column = 'ADJUSTED' THEN
      ln_qty := ln_qty + r_nom_transfer.adjusted_qty;
   ELSIF p_column = 'SCHEDULED' THEN
      ln_qty := ln_qty + r_nom_transfer.scheduled_qty;
   END IF;

END LOOP;


ln_sign := ecdp_contract_attribute.getAttributeString (ec_nomination_point.contract_id(p_nompnt_id),lv_transfer_type,p_daytime);
 IF ln_sign IS NULL THEN
    IF lv_transfer_type = 'TRAN_INPUT' THEN
       ln_sign := -1;
    ELSE
       ln_sign := 1;
    END IF;
 END IF;

--Send blank if qty = 0
IF ln_qty = 0 THEN
   ln_qty := NULL;
ELSE
   ln_qty := ln_qty * ln_sign;
END IF;

RETURN ln_qty;

END getTransferSummaryCounterQty;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTransferSumQuantity
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : NOMPNT_DAY_NOM_TRANSFER
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTransferSumQuantity(p_nompnt_id         VARCHAR2,
                                p_counter_nompnt_id VARCHAR2,
                                p_daytime           DATE,
                                p_column            VARCHAR2)
RETURN NUMBER
--</EC-DOC>
 IS

 lv_query VARCHAR2(2000);
 ln_sum_input   NUMBER;
 ln_sum_output   NUMBER;
 ln_sum NUMBER;
 ln_sign NUMBER;
 lv_transfer_type VARCHAR2(32);


BEGIN

 lv_transfer_type := ue_nomination.get_nom_type(p_nompnt_id,p_nompnt_id,p_daytime,p_column);
 ln_sign := ecdp_contract_attribute.getAttributeString (ec_nomination_point.contract_id(p_nompnt_id),lv_transfer_type,p_daytime);
 IF ln_sign IS NULL THEN
    IF lv_transfer_type = 'TRAN_INPUT' THEN
       ln_sign := -1;
    ELSE
       ln_sign := 1;
    END IF;
 END IF;

  lv_query := 'SELECT SUM(' || p_column || ') AS sum_col FROM nompnt_day_transfer WHERE object_id = ''' || p_nompnt_id || ''' and daytime = ''' || p_daytime|| ''' and counter_nompnt_id = ''' || p_counter_nompnt_id || '''and nomination_type = ''TRAN_INPUT''';

  EXECUTE IMMEDIATE lv_query into ln_sum_input;

  lv_query := 'SELECT SUM(' || p_column || ') AS sum_col FROM nompnt_day_transfer WHERE object_id = ''' || p_nompnt_id || ''' and daytime = ''' || p_daytime|| ''' and counter_nompnt_id = ''' || p_counter_nompnt_id || '''and nomination_type = ''TRAN_OUTPUT''';

  EXECUTE IMMEDIATE lv_query into ln_sum_output;

  IF lv_transfer_type = 'TRAN_INPUT' THEN
     ln_sum := nvl(ln_sum_output,0) - nvl(ln_sum_input,0);
  ELSIF lv_transfer_type = 'TRAN_OUTPUT' THEN
     ln_sum := nvl(ln_sum_input,0) - nvl(ln_sum_output,0);
  END IF;

  RETURN ln_sum;

END getTransferSumQuantity;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : get_nom_type
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : NOMPNT_DAY_NOM_TRANSFER
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION get_nom_type(p_nompnt_id         VARCHAR2,
                      p_counter_nompnt_id VARCHAR2,
                      p_daytime           DATE,
                      p_column            VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
 IS

 lv_query VARCHAR2(2000);
 ln_sum_input   NUMBER;
 ln_sum_output   NUMBER;
 lv_nom_type VARCHAR2(32);


BEGIN

  lv_query := 'SELECT SUM(' || p_column || ') AS sum_col FROM nompnt_day_transfer WHERE object_id = ''' || p_nompnt_id || ''' and daytime = ''' || p_daytime|| ''' and counter_nompnt_id = ''' || p_counter_nompnt_id || '''and nomination_type = ''TRAN_INPUT''';

  EXECUTE IMMEDIATE lv_query into ln_sum_input;

  lv_query := 'SELECT SUM(' || p_column || ') AS sum_col FROM nompnt_day_transfer WHERE object_id = ''' || p_nompnt_id || ''' and daytime = ''' || p_daytime|| ''' and counter_nompnt_id = ''' || p_counter_nompnt_id || '''and nomination_type = ''TRAN_OUTPUT''';

  EXECUTE IMMEDIATE lv_query into ln_sum_output;

  IF NVL(ln_sum_input,0) = nvl(ln_sum_output,0) THEN
     lv_nom_type := 'TRAN_INPUT';
  ELSIF NVL(ln_sum_input,0) > nvl(ln_sum_output,0) THEN
     lv_nom_type := 'TRAN_INPUT';
  ELSIF NVL(ln_sum_input,0) < nvl(ln_sum_output,0) THEN
     lv_nom_type := 'TRAN_OUTPUT';
  ELSE
     lv_nom_type := 'TRAN_INPUT';
  END IF;

  RETURN lv_nom_type;

END get_nom_type;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTransferSummaryDifference
-- Description    : Return difference between quantities
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

FUNCTION getTransferSummaryDifference(p_nompnt_id VARCHAR2, p_qty NUMBER, p_counter_qty NUMBER, p_transfer_type VARCHAR2, p_daytime DATE)
RETURN NUMBER
IS


ln_difference NUMBER;


BEGIN

  ln_difference := (nvl(p_qty,0) + nvl(p_counter_qty,0));

RETURN ln_difference;

END getTransferSummaryDifference;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : qty_sig_converter
-- Description    : Return qty either as plus or minus
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION qty_sig_converter(p_nompnt_id VARCHAR2, p_transfer_type VARCHAR2, p_daytime DATE,  p_qty NUMBER)
RETURN NUMBER
IS

 ln_sign NUMBER;
 ln_qty  NUMBER;

BEGIN

  ln_sign := ecdp_contract_attribute.getAttributeString (ec_nomination_point.contract_id(p_nompnt_id),p_transfer_type,p_daytime);
 IF ln_sign IS NULL THEN
    IF p_transfer_type = 'TRAN_INPUT' THEN
       ln_sign := -1;
    ELSE
       ln_sign := 1;
    END IF;
 END IF;

 ln_qty := p_qty * ln_sign;

RETURN ln_qty;

END qty_sig_converter;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : createSubdayConfHours
-- Description    : Generates sub-daily nomination location confirmation data records for a contract day.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_confirmation
--                  nompnt_sub_day_confirmation
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      : Generates hourly rows for the given contract day, taking contract
--                  day offsets and daylight savings time transitions into account.
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE createSubdayConfHours(
  p_class_name VARCHAR2,
  p_object_id VARCHAR2,
  p_daytime DATE,
  p_contract_id VARCHAR2,
  p_confirmation_type VARCHAR2,
  p_day_con_seq NUMBER,
  p_con_status VARCHAR2
)

IS
  lr_daytimes Ecdp_Date_Time.Ec_Unique_Daytimes;

BEGIN

  lr_daytimes:= EcDp_ContractDay.getProductionDayDaytimes('CONTRACT',p_contract_id,p_daytime);

  FOR i IN 1 .. lr_daytimes.COUNT LOOP
    INSERT INTO nompnt_sub_day_confirmation (CLASS_NAME, OBJECT_ID, DAYTIME, CONTRACT_ID, CONFIRMATION_TYPE, DAY_CON_SEQ, CON_STATUS) VALUES (p_class_name, p_object_id, lr_daytimes(i).daytime, p_contract_id, p_confirmation_type, p_day_con_seq, p_con_status);
  END LOOP;

END createSubdayConfHours;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : createNomConn
-- Description    : Generates data record in nomination connection and/or nomination point.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_connection
--                  nomination point
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      : Generates a new record in table nompnt_connection where connection does not exit in
--                  counter nomination point
--                  or create a new record in table nomination_point according to shipper code.
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE createNomConn(
  p_object_id VARCHAR2,
  p_daytime DATE,
  p_counter_nompnt_id VARCHAR2,
  p_shipper_code VARCHAR2
)

IS

BEGIN
  null;
END createNomConn;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : aggrSubDailyToDailyConf
-- Description    : Sums up hourly nomination quantities and stores the result in the daily data table.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_sub_day_confirmation
--                  nompnt_day_confirmation
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Finds the sum of all the sub-daily quantities for the given day. The resulting
--                  quantity is written to the daily nomination location confirmation table.
--
---------------------------------------------------------------------------------------------------
PROCEDURE aggrSubDailyToDailyConf(
  p_object_id      VARCHAR2,
  p_daytime        DATE,
  p_contract_id    VARCHAR2,
  p_summer_time    VARCHAR2,
  p_production_day DATE,
  p_day_con_seq    NUMBER
)
--</EC-DOC>
IS
  ln_sum_apt_qty      NUMBER :=0;
	ln_sum_apt_qty_in   NUMBER :=0;
  ln_sum_apt_qty_out  NUMBER :=0;

  ln_sum_adj_qty      NUMBER :=0;
  ln_sum_adj_qty_in   NUMBER :=0;
  ln_sum_adj_qty_out  NUMBER :=0;

  ln_sum_cnf_qty      NUMBER :=0;
  ln_sum_cnf_qty_in   NUMBER :=0;
  ln_sum_cnf_qty_out  NUMBER :=0;

  ln_input            NUMBER;
  ln_output           NUMBER;

  lv_record_exists    VARCHAR2(1):='N';

  ld_daytime DATE;

	CURSOR c_day_exits IS
	SELECT 1 FROM nompnt_day_confirmation WHERE confirmation_seq = p_day_con_seq;


	CURSOR c_sum_apt_qty_in IS
		SELECT SUM(Nvl(ACCEPTED_QTY, 0)) result
		FROM nompnt_sub_day_confirmation
		WHERE day_con_seq = p_day_con_seq AND confirmation_type = 'TRAN_INPUT';

  CURSOR c_sum_apt_qty_out IS
		SELECT SUM(Nvl(ACCEPTED_QTY, 0)) result
		FROM nompnt_sub_day_confirmation
		WHERE day_con_seq = p_day_con_seq AND confirmation_type = 'TRAN_OUTPUT';


  CURSOR c_sum_adj_qty_in IS
		SELECT SUM(Nvl(ADJUSTED_QTY, 0)) result
		FROM nompnt_sub_day_confirmation
		WHERE day_con_seq = p_day_con_seq AND confirmation_type = 'TRAN_INPUT';

  CURSOR c_sum_adj_qty_out IS
		SELECT SUM(Nvl(ADJUSTED_QTY, 0)) result
		FROM nompnt_sub_day_confirmation
		WHERE day_con_seq = p_day_con_seq AND confirmation_type = 'TRAN_OUTPUT';


  CURSOR c_sum_cnf_qty_in IS
		SELECT SUM(Nvl(CONFIRMED_QTY, 0)) result
		FROM nompnt_sub_day_confirmation
		WHERE day_con_seq = p_day_con_seq AND confirmation_type = 'TRAN_INPUT';

  CURSOR c_sum_cnf_qty_out IS
		SELECT SUM(Nvl(CONFIRMED_QTY, 0)) result
		FROM nompnt_sub_day_confirmation
		WHERE day_con_seq = p_day_con_seq AND confirmation_type = 'TRAN_OUTPUT';

BEGIN
  ld_daytime := trunc(p_daytime, 'DDD');
  ln_input  := ecdp_contract_attribute.getAttributeString (p_contract_id,'TRAN_INPUT',ld_daytime);
  ln_output := ecdp_contract_attribute.getAttributeString (p_contract_id,'TRAN_OUTPUT',ld_daytime);

   -- Find the day total
  FOR curAptSumIn IN c_sum_apt_qty_in LOOP
		ln_sum_apt_qty_in := curAptSumIn.result;
	END LOOP;

  FOR curAptSumOut IN c_sum_apt_qty_out LOOP
		ln_sum_apt_qty_out := curAptSumOut.result;
	END LOOP;

  IF ln_sum_apt_qty_in IS NULL THEN
     ln_sum_apt_qty_in := 0;
  END IF;

  IF ln_sum_apt_qty_out IS NULL THEN
     ln_sum_apt_qty_out := 0;
  END IF;

  IF ln_sum_apt_qty_out > ln_sum_apt_qty_in THEN
     ln_sum_apt_qty := ln_sum_apt_qty_out - ln_sum_apt_qty_in;
     ln_sum_apt_qty := ln_sum_apt_qty * ln_output;
  ELSE
     ln_sum_apt_qty := ln_sum_apt_qty_in - ln_sum_apt_qty_out;
     ln_sum_apt_qty := ln_sum_apt_qty * ln_input;
  END IF;

  IF ln_sum_apt_qty IS NULL THEN
     ln_sum_apt_qty := 0;
  END IF;

	FOR curAdjSumIn IN c_sum_adj_qty_in LOOP
		ln_sum_adj_qty_in := curAdjSumIn.result;
	END LOOP;

  FOR curAdjSumOut IN c_sum_adj_qty_out LOOP
		ln_sum_adj_qty_out := curAdjSumOut.result;
	END LOOP;

  IF ln_sum_adj_qty_in IS NULL THEN
     ln_sum_adj_qty_in := 0;
  END IF;

  IF ln_sum_adj_qty_out IS NULL THEN
     ln_sum_adj_qty_out := 0;
  END IF;

  IF ln_sum_adj_qty_out > ln_sum_adj_qty_in THEN
     ln_sum_adj_qty := ln_sum_adj_qty_out - ln_sum_adj_qty_in;
     ln_sum_adj_qty := ln_sum_adj_qty * ln_output;
  ELSE
     ln_sum_adj_qty := ln_sum_adj_qty_in - ln_sum_adj_qty_out;
     ln_sum_adj_qty := ln_sum_adj_qty * ln_input;
  END IF;

  IF ln_sum_adj_qty IS NULL THEN
     ln_sum_adj_qty := 0;
  END IF;

  FOR curCnfSumIn IN c_sum_cnf_qty_in LOOP
		ln_sum_cnf_qty_in := curCnfSumIn.result;
	END LOOP;

  FOR curCnfSumOut IN c_sum_cnf_qty_out LOOP
		ln_sum_cnf_qty_out := curCnfSumOut.result;
	END LOOP;

  IF ln_sum_cnf_qty_in IS NULL THEN
     ln_sum_cnf_qty_in := 0;
  END IF;

  IF ln_sum_cnf_qty_out IS NULL THEN
     ln_sum_cnf_qty_out := 0;
  END IF;

  IF ln_sum_cnf_qty_out > ln_sum_cnf_qty_in THEN
     ln_sum_cnf_qty := ln_sum_cnf_qty_out - ln_sum_cnf_qty_in;
     ln_sum_cnf_qty := ln_sum_cnf_qty * ln_output;
  ELSE
     ln_sum_cnf_qty := ln_sum_cnf_qty_in - ln_sum_cnf_qty_out;
     ln_sum_cnf_qty := ln_sum_cnf_qty * ln_input;
  END IF;

  IF ln_sum_cnf_qty IS NULL THEN
     ln_sum_cnf_qty := 0;
  END IF;


  FOR i in c_day_exits LOOP
    lv_record_exists := 'Y';
  END LOOP;

  IF lv_record_exists = 'Y' THEN -- update existing record
    UPDATE nompnt_day_confirmation
      SET ACCEPTED_QTY = ln_sum_apt_qty,
          ADJUSTED_QTY = ln_sum_adj_qty,
          CONFIRMED_QTY = ln_sum_cnf_qty
	  WHERE confirmation_seq = p_day_con_seq;
  END IF;

END aggrSubDailyToDailyConf;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getOperUOM
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : IV_NOMINATION_LOCATION
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Retrieves operational UOM from nomination location
--
---------------------------------------------------------------------------------------------------
FUNCTION getOperUOM(p_object_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2
--</EC-DOC>
 IS

  lv2_class_name VARCHAR2(32);
  lv_sql         VARCHAR2(2000);
  lv_uom         VARCHAR2(32);

BEGIN
  lv2_class_name := Ecdp_Objects.GetObjClassName(p_object_id);

  lv_sql := 'select oper_uom from iv_nomination_location where object_id  = ''' ||
            p_object_id || ''' and class_name = ''' || lv2_class_name ||
            ''' and ''' || p_daytime || '''' || ' >= daytime ' || ' and ''' ||
            p_daytime || '''' || '  < nvl(end_date, ''' || (p_daytime + 1) ||
            ''')';

  EXECUTE IMMEDIATE lv_sql
    into lv_uom;

  RETURN lv_uom;

END getOperUOM;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNominatedQty
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : OBJLOC_SUB_DAY_NOMINATION
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :Retrieves scheduled qty based on nomination type and nomination status
--
---------------------------------------------------------------------------------------------------
FUNCTION getNominatedQty(p_nomination_seq NUMBER) RETURN NUMBER

 IS

  CURSOR c_nom_qty IS
    select o.accepted_in_qty,
           o.accepted_out_qty,
           o.adjusted_in_qty,
           o.adjusted_out_qty,
           o.confirmed_in_qty,
           o.confirmed_out_qty,
           o.scheduled_in_qty,
           o.scheduled_out_qty,
           o.requested_in_qty,
           o.requested_out_qty,
           o.nomination_type,
           o.nom_status
      from objloc_sub_day_nomination o
     where o.nomination_seq = p_nomination_seq ;

  ln_nominated_qty NUMBER := 0;

BEGIN

  FOR cur_nom_qty IN c_nom_qty LOOP
    IF (cur_nom_qty.nomination_type = 'TRAN_INPUT') THEN
      IF (cur_nom_qty.nom_status = 'ACC') THEN
        ln_nominated_qty := cur_nom_qty.accepted_in_qty;
      ELSIF (cur_nom_qty.nom_status = 'ADJ') THEN
        ln_nominated_qty := cur_nom_qty.adjusted_in_qty;
      ELSIF (cur_nom_qty.nom_status = 'CON') THEN
        ln_nominated_qty := cur_nom_qty.confirmed_in_qty;
      ELSIF (cur_nom_qty.nom_status = 'SCH') THEN
        ln_nominated_qty := cur_nom_qty.scheduled_in_qty;
      ELSIF (cur_nom_qty.nom_status = 'REQ') THEN
        ln_nominated_qty := cur_nom_qty.requested_in_qty;
      ELSE --Rejected
        ln_nominated_qty := 0;
      END IF;
    ELSIF (cur_nom_qty.nomination_type = 'TRAN_OUTPUT') THEN
      IF (cur_nom_qty.nom_status = 'ACC') THEN
        ln_nominated_qty := cur_nom_qty.accepted_out_qty;
      ELSIF (cur_nom_qty.nom_status = 'ADJ') THEN
        ln_nominated_qty := cur_nom_qty.adjusted_out_qty;
      ELSIF (cur_nom_qty.nom_status = 'CON') THEN
        ln_nominated_qty := cur_nom_qty.confirmed_out_qty;
      ELSIF (cur_nom_qty.nom_status = 'SCH') THEN
        ln_nominated_qty := cur_nom_qty.scheduled_out_qty;
      ELSIF (cur_nom_qty.nom_status = 'REQ') THEN
        ln_nominated_qty := cur_nom_qty.requested_out_qty;
      ELSE --Rejected
        ln_nominated_qty := 0;
      END IF;
    ELSE --null
      ln_nominated_qty := 0;
    END IF;

  END LOOP;

  RETURN ln_nominated_qty;
END getNominatedQty;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSchedQty
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : OBJLOC_SUB_DAY_NOMINATION
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :Retrieves scheduled qty based on nomination type (TRAN_INPUT and TRAN_OUTPUT)
--
---------------------------------------------------------------------------------------------------
FUNCTION getSchedQty(p_nomination_seq NUMBER) RETURN NUMBER

 IS

  CURSOR c_sched_qty IS
    select o.scheduled_in_qty, o.scheduled_out_qty, o.nomination_type
      from objloc_sub_day_nomination o
     where o.nomination_seq = p_nomination_seq ;

  ln_sched_qty NUMBER := 0;

BEGIN

  FOR cur_sched_qty in c_sched_qty LOOP
    IF cur_sched_qty.nomination_type = 'TRAN_INPUT' THEN
      ln_sched_qty := cur_sched_qty.scheduled_in_qty;
    ELSIF cur_sched_qty.nomination_type = 'TRAN_OUTPUT' THEN
      ln_sched_qty := cur_sched_qty.scheduled_out_qty;
	ELSE --null
	  ln_sched_qty := 0;
    END IF;
  END LOOP;

  RETURN ln_sched_qty;

END getSchedQty;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCapacityUOM
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : IV_NOMINATION_LOCATION
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Retrieves capacity UOM from nomination location
--
---------------------------------------------------------------------------------------------------
FUNCTION getCapacityUOM(p_object_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2
--</EC-DOC>
 IS

  lv2_class_name VARCHAR2(32);
  lv_sql         VARCHAR2(2000);
  lv_uom         VARCHAR2(32);

BEGIN
  lv2_class_name := Ecdp_Objects.GetObjClassName(p_object_id);

  lv_sql := 'select capacity_uom from iv_nomination_location where object_id  = ''' ||
            p_object_id || ''' and class_name = ''' || lv2_class_name ||
            ''' and ''' || p_daytime || '''' || ' >= daytime ' || ' and ''' ||
            p_daytime || '''' || '  < nvl(end_date, ''' || (p_daytime + 1) ||
            ''')';

  EXECUTE IMMEDIATE lv_sql
    into lv_uom;

  RETURN lv_uom;

END getCapacityUOM;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : createCntrEventPrLocation
-- Description    : find all nomination points on the location which is given in as a parameter, and create records for these in NOMPNT_PERIOD_EVENT
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : NOMPNT_PERIOD_EVENT
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : insert record to NOMPNT_PERIOD_EVENT
--
---------------------------------------------------------------------------------------------------
PROCEDURE createCntrEventPrLocation(p_nomLoc_id VARCHAR2,
                                    p_daytime   DATE,
                                    p_eventType VARCHAR2,
                                    p_eventSeq  NUMBER)
--</EC-DOC>
 IS
  CURSOR cur_nompnt(cp_nom_loc varchar2, cp_daytime date) is
    select object_id, contract_id
      from nomination_point
     where (entry_location_id = cp_nom_loc or exit_location_id = cp_nom_loc)
       and start_date <= cp_daytime
       and cp_daytime < nvl(end_date, cp_daytime + 1);

BEGIN

  for curNompnt in cur_nompnt(p_nomLoc_id, p_daytime) loop
    INSERT INTO NOMPNT_PERIOD_EVENT
      (OBJECT_ID, DAYTIME, EVENT_TYPE, CONTRACT_ID, REF_EVENT_SEQ)
    VALUES
      (curNompnt.object_id,
       p_daytime,
       p_eventType,
       curNompnt.contract_id,
       p_eventSeq);
  end loop;

END createCntrEventPrLocation;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getEventSchedQty
-- Description    : calculate scheduled quantity
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : NOMPNT_DAY_NOMINATION
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : calculate scheduled quantity from NOMPNT_DAY_NOMINATION
--
---------------------------------------------------------------------------------------------------
FUNCTION getEventSchedQty(p_eventSeq NUMBER) RETURN NUMBER
--</EC-DOC>
 IS
 lv_nompnt_id varchar2(32);
 ld_daytime date;
 ln_schd_qty number;
BEGIN

  select object_id, daytime
    into lv_nompnt_id, ld_daytime
    from nompnt_period_event
   where event_seq = p_eventSeq;

  select nvl(sum(scheduled_qty), 0)
    into ln_schd_qty
    from nompnt_day_nomination
   where object_id = lv_nompnt_id
     and daytime = ld_daytime
     and nomination_type = 'SALE_NOM';

  return ln_schd_qty;

END getEventSchedQty;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : calculateCntrEvent
-- Description    : prorate schedule quantity from nominated quantity
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : NOMPNT_PERIOD_EVENT
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : calculate scheduled quantity from nominated quantity
--
---------------------------------------------------------------------------------------------------
PROCEDURE calculateCntrEvent(p_eventSeq NUMBER)
--</EC-DOC>
 IS
  CURSOR cur_nompnt_event(cp_event_seq number) is
    select event_seq
      from nompnt_period_event
     where ref_event_seq = cp_event_seq;

  ln_eventQty  number;
  ln_sched     number;
  ln_sum_sched number := 0;
  ln_cntrEvent number;
BEGIN

  select event_qty
    into ln_eventQty
    from nomloc_period_event c
   where c.event_seq = p_eventSeq;

  for c_nompnt_event in cur_nompnt_event(p_eventSeq) loop
    ln_sum_sched := ln_sum_sched +
                    ue_nomination.getEventSchedQty(c_nompnt_event.event_seq);
  end loop;

  if (ln_sum_sched != 0) then
    for c_nompnt_event in cur_nompnt_event(p_eventSeq) loop
      ln_sched     := ue_nomination.getEventSchedQty(c_nompnt_event.event_seq);
      ln_cntrEvent := ln_eventQty * ln_sched / ln_sum_sched;

      update NOMPNT_PERIOD_EVENT
         set event_qty       = ln_cntrEvent,
             last_updated_by = Nvl(ecdp_context.getAppUser, USER),
             rev_no          = rev_no + 1
       where event_seq = c_nompnt_event.event_seq;
    end loop;
  end if;

END calculateCntrEvent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : createCntrEventPrLocationFcst
-- Description    : find all nomination points on the location which is given in as a parameter, and create records for these in FCST_NOMPNT_PERIOD_EVENT
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FCST_NOMPNT_PERIOD_EVENT
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : insert record to FCST_NOMPNT_PERIOD_EVENT
--
---------------------------------------------------------------------------------------------------
PROCEDURE createCntrEventPrLocationFcst(p_nomLoc_id VARCHAR2,
                                    p_forecast_id   VARCHAR2,
                                    p_daytime   DATE,
                                    p_eventType VARCHAR2,
                                    p_eventSeq  NUMBER)
--</EC-DOC>
 IS
  CURSOR cur_nompnt(cp_nom_loc varchar2, cp_daytime date) is
    select object_id, contract_id
      from nomination_point
     where (entry_location_id = cp_nom_loc or exit_location_id = cp_nom_loc)
       and start_date <= cp_daytime
       and cp_daytime < nvl(end_date, cp_daytime + 1);

BEGIN

  for curNompnt in cur_nompnt(p_nomLoc_id, p_daytime) loop
    INSERT INTO FCST_NOMPNT_PERIOD_EVENT
      (OBJECT_ID, FORECAST_ID, DAYTIME, EVENT_TYPE, CONTRACT_ID, REF_EVENT_SEQ)
    VALUES
      (curNompnt.object_id,
       p_forecast_id,
       p_daytime,
       p_eventType,
       curNompnt.contract_id,
       p_eventSeq);
  end loop;

END createCntrEventPrLocationFcst;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getEventSchedQtyFcst
-- Description    : calculate forecast scheduled quantity
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : NOMPNT_DAY_NOMINATION
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : calculate forecast scheduled quantity from NOMPNT_DAY_NOMINATION
--
---------------------------------------------------------------------------------------------------
FUNCTION getEventSchedQtyFcst(p_eventSeq NUMBER, p_forecast_id VARCHAR2) RETURN NUMBER
--</EC-DOC>
 IS
 lv_nompnt_id varchar2(32);
 ld_daytime date;
 ln_schd_qty number;
BEGIN

  select object_id, daytime
    into lv_nompnt_id, ld_daytime
    from fcst_nompnt_period_event
   where event_seq = p_eventSeq and forecast_id = p_forecast_id;

  select nvl(sum(scheduled_qty), 0)
    into ln_schd_qty
    from nompnt_day_nomination
   where object_id = lv_nompnt_id
     and daytime = ld_daytime
     and nomination_type = 'SALE_NOM';

  return ln_schd_qty;

END getEventSchedQtyFcst;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : calculateCntrEventFcst
-- Description    : prorate forecast schedule quantity from nominated quantity
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FCST_NOMPNT_PERIOD_EVENT
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : calculate forecast scheduled quantity from nominated quantity
--
---------------------------------------------------------------------------------------------------
PROCEDURE calculateCntrEventFcst(p_eventSeq NUMBER, p_forecast_id VARCHAR2)
--</EC-DOC>
 IS
  CURSOR cur_nompnt_event(cp_event_seq number, cp_forecast_id VARCHAR2) is
    select event_seq
      from fcst_nompnt_period_event
     where ref_event_seq = cp_event_seq and forecast_id = cp_forecast_id;

  ln_eventQty  number;
  ln_sched     number;
  ln_sum_sched number := 0;
  ln_cntrEvent number;
BEGIN

  select event_qty
    into ln_eventQty
    from fcst_nomloc_period_event c
   where c.event_seq = p_eventSeq and forecast_id = p_forecast_id;

  for c_nompnt_event in cur_nompnt_event(p_eventSeq, p_forecast_id) loop
    ln_sum_sched := ln_sum_sched +
                    ue_nomination.getEventSchedQtyFcst(c_nompnt_event.event_seq, p_forecast_id);
  end loop;

  if (ln_sum_sched != 0) then
    for c_nompnt_event in cur_nompnt_event(p_eventSeq, p_forecast_id) loop
      ln_sched     := ue_nomination.getEventSchedQtyFcst(c_nompnt_event.event_seq, p_forecast_id);
      ln_cntrEvent := ln_eventQty * ln_sched / ln_sum_sched;

      update FCST_NOMPNT_PERIOD_EVENT
         set event_qty       = ln_cntrEvent,
             last_updated_by = Nvl(ecdp_context.getAppUser, USER),
             rev_no          = rev_no + 1
       where event_seq = c_nompnt_event.event_seq and forecast_id = p_forecast_id;
    end loop;
  end if;

END calculateCntrEventFcst;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getInputNominatedQty
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : OBJLOC_SUB_DAY_NOMINATION
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :Retrieves scheduled qty based on nomination status and nomination type = TRAN_INPUT
--
---------------------------------------------------------------------------------------------------
FUNCTION getInputNominatedQty(p_nomination_seq NUMBER) RETURN NUMBER

 IS

  CURSOR c_nom_qty IS
    select o.accepted_in_qty,
           o.adjusted_in_qty,
           o.confirmed_in_qty,
           o.scheduled_in_qty,
           o.requested_in_qty,
           o.nomination_type,
           o.nom_status
      from objloc_sub_day_nomination o
     where o.nomination_seq = p_nomination_seq ;

  ln_nominated_qty NUMBER := 0;

BEGIN

  FOR cur_nom_qty IN c_nom_qty LOOP
      IF (cur_nom_qty.nom_status = 'ACC') THEN
        ln_nominated_qty := cur_nom_qty.accepted_in_qty;
      ELSIF (cur_nom_qty.nom_status = 'ADJ') THEN
        ln_nominated_qty := cur_nom_qty.adjusted_in_qty;
      ELSIF (cur_nom_qty.nom_status = 'CON') THEN
        ln_nominated_qty := cur_nom_qty.confirmed_in_qty;
      ELSIF (cur_nom_qty.nom_status = 'SCH') THEN
        ln_nominated_qty := cur_nom_qty.scheduled_in_qty;
      ELSIF (cur_nom_qty.nom_status = 'REQ') THEN
        ln_nominated_qty := cur_nom_qty.requested_in_qty;
      ELSE --Rejected
        ln_nominated_qty := 0;
      END IF;

  END LOOP;

  RETURN ln_nominated_qty;

END getInputNominatedQty;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getOutputNominatedQty
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : OBJLOC_SUB_DAY_NOMINATION
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :Retrieves scheduled qty based on nomination status and nomination type = TRAN_OUTPUT
--
---------------------------------------------------------------------------------------------------
FUNCTION getOutputNominatedQty(p_nomination_seq NUMBER) RETURN NUMBER

 IS

  CURSOR c_nom_qty IS
    select o.accepted_out_qty,
           o.adjusted_out_qty,
           o.confirmed_out_qty,
           o.scheduled_out_qty,
           o.requested_out_qty,
           o.nomination_type,
           o.nom_status
      from objloc_sub_day_nomination o
     where o.nomination_seq = p_nomination_seq ;

  ln_nominated_qty NUMBER := 0;

BEGIN

  FOR cur_nom_qty IN c_nom_qty LOOP
      IF (cur_nom_qty.nom_status = 'ACC') THEN
        ln_nominated_qty := cur_nom_qty.accepted_out_qty;
      ELSIF (cur_nom_qty.nom_status = 'ADJ') THEN
        ln_nominated_qty := cur_nom_qty.adjusted_out_qty;
      ELSIF (cur_nom_qty.nom_status = 'CON') THEN
        ln_nominated_qty := cur_nom_qty.confirmed_out_qty;
      ELSIF (cur_nom_qty.nom_status = 'SCH') THEN
        ln_nominated_qty := cur_nom_qty.scheduled_out_qty;
      ELSIF (cur_nom_qty.nom_status = 'REQ') THEN
        ln_nominated_qty := cur_nom_qty.requested_out_qty;
      ELSE --Rejected
        ln_nominated_qty := 0;
      END IF;

  END LOOP;

  RETURN ln_nominated_qty;

END getOutputNominatedQty;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : setFactorsEndDate
-- Description    : set end date for factors
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : OBJ_TRAN_EVENT_FACTOR
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE setFactorsEndDate(p_nomination_point_id VARCHAR2, p_daytime DATE, p_class_name VARCHAR2)
--</EC-DOC>
IS

CURSOR cur_end_date(cp_nomination_point_id VARCHAR2, cp_daytime DATE, cp_class_name VARCHAR2) IS
select min(daytime) end_date from OBJ_TRAN_EVENT_FACTOR
where OBJECT_ID = cp_nomination_point_id
and DAYTIME > cp_daytime
and CLASS_NAME=cp_class_name;

lv2_appuser VARCHAR2(30):=Nvl(EcDp_Context.getAppUser,User);
BEGIN

UPDATE OBJ_TRAN_EVENT_FACTOR
SET END_DATE = p_daytime, REV_NO = NVL2(REV_NO, REV_NO+1, 0), LAST_UPDATED_BY = lv2_appuser
WHERE OBJECT_ID = p_nomination_point_id
AND DAYTIME = (select max(daytime) from OBJ_TRAN_EVENT_FACTOR
where DAYTIME < p_daytime
and p_daytime < NVL(END_DATE, p_daytime+1/(24*60*60))
and object_id= p_nomination_point_id
and CLASS_NAME=p_class_name)
AND p_daytime < NVL(END_DATE, p_daytime+1/(24*60*60))
AND CLASS_NAME = p_class_name;

FOR c_end_date in cur_end_date(p_nomination_point_id, p_daytime, p_class_name) LOOP
  IF c_end_date.end_date is not null THEN
    UPDATE OBJ_TRAN_EVENT_FACTOR
    SET END_DATE = c_end_date.end_date
    where DAYTIME = p_daytime
    and object_id= p_nomination_point_id
    and CLASS_NAME = p_class_name;
  END IF;
END LOOP;

END setFactorsEndDate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : updateFactorsEndDate
-- Description    : update end date for factors
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : OBJ_TRAN_EVENT_FACTOR
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE updateFactorsEndDate(p_nomination_point_id VARCHAR2, p_daytime DATE, p_end_date DATE, p_class_name VARCHAR2)
--</EC-DOC>
IS

lv2_appuser VARCHAR2(30):=Nvl(EcDp_Context.getAppUser,User);
BEGIN

UPDATE OBJ_TRAN_EVENT_FACTOR
SET END_DATE = nvl(p_end_date, null) , REV_NO = NVL2(REV_NO, REV_NO+1, 0), LAST_UPDATED_BY = lv2_appuser
WHERE OBJECT_ID = p_nomination_point_id
AND END_DATE = p_daytime
AND CLASS_NAME = p_class_name;

END updateFactorsEndDate;

END ue_Nomination;