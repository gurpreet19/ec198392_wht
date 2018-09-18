CREATE OR REPLACE PACKAGE BODY ue_allocation IS
/******************************************************************************
** Package        :  ue_allocation, body part
**
** $Revision: 1.1.2.1 $
**
** Purpose        :  Business logic for nominations
**
** Documentation  :  www.energy-components.com
**
** Created        :  11.06.2012 Lee Wei Yap
**
** Modification history:
**
** Date        Whom  		Change description:
** ------      ----- 		-----------------------------------------------------------------------------------------------
** 13.06.2012  leeeewei     Create function to calculate nomination split
**
********************************************************************/

CURSOR c_sum_in_nom_del_delpnt (cp_delpnt_id VARCHAR2, cp_nom_cycle VARCHAR, cp_daytime DATE) IS
 --Sum scheduled qty for delivery points
 SELECT sum(n.SCHEDULED_QTY) SUM_SCHEDULED_QTY,
        sum(n.rep_scheduled_qty) SUM_REP_SCHEDULED_QTY
   FROM nompnt_day_delivery n,
        nomination_point    p,
        nompnt_version      nv,
        delivery_point      d
  WHERE n.object_id = p.object_id
    AND p.object_id = nv.object_id
    AND p.entry_location_id = d.object_id
    AND p.exit_location_id IS NULL
    AND n.daytime = cp_daytime
    AND nv.daytime <= n.daytime
    AND nvl(nv.end_date, n.daytime + 1) > n.daytime
    AND d.object_id = cp_delpnt_id
    AND n.nomination_type = 'TRAN_INPUT'
    AND nvl(n.nom_cycle_code, 'a') = nvl(cp_nom_cycle, 'a')
    AND nvl(nv.operational, 'N') = 'N';


CURSOR c_sum_out_nom_del_delpnt (cp_delpnt_id VARCHAR2, cp_nom_cycle VARCHAR, cp_daytime DATE) IS
 --Sum scheduled qty for delivery points
 SELECT sum(n.SCHEDULED_QTY) SUM_SCHEDULED_QTY,
        sum(n.rep_scheduled_qty) SUM_REP_SCHEDULED_QTY
   FROM nompnt_day_delivery n,
        nomination_point    p,
        nompnt_version      nv,
        delivery_point      d
  WHERE n.object_id = p.object_id
    AND p.object_id = nv.object_id
    AND p.entry_location_id IS NULL
    AND p.exit_location_id = d.object_id
    AND n.daytime = cp_daytime
    AND nv.daytime <= n.daytime
    AND nvl(nv.end_date, n.daytime + 1) > n.daytime
    AND d.object_id = cp_delpnt_id
    AND n.nomination_type = 'TRAN_OUTPUT'
    AND nvl(n.nom_cycle_code, 'a') = nvl(cp_nom_cycle, 'a')
    AND nvl(nv.operational, 'N') = 'N';


CURSOR c_sum_in_nom_del_delstrm (cp_delstrm_id VARCHAR2, cp_nom_cycle VARCHAR, cp_daytime DATE) IS
--Sum scheduled qty for delivery stream
SELECT sum(n.SCHEDULED_QTY) SUM_SCHEDULED_QTY,sum(n.rep_scheduled_qty) SUM_REP_SCHEDULED_QTY
  FROM nompnt_day_delivery n,
       nomination_point      p,
       nompnt_version nv,
       delivery_stream       s,
       delstrm_version       v
 WHERE n.object_id = p.object_id
   AND p.entry_location_id = s.object_id
   AND p.exit_location_id IS NULL
   AND s.object_id = v.object_id
   AND p.object_id = nv.object_id
   AND v.daytime <= n.daytime
   AND nvl(v.end_date, n.daytime + 1) > n.daytime
   AND nvl(nv.end_date, n.daytime + 1) > n.daytime
   AND n.daytime = cp_daytime
   AND nv.daytime <= n.daytime
   AND s.object_id = cp_delstrm_id
   AND n.nomination_type = 'TRAN_INPUT'
   AND nvl(n.nom_cycle_code, 'a') = nvl(cp_nom_cycle, 'a')
   AND nvl(nv.operational, 'N') = 'N';

CURSOR c_sum_out_nom_del_delstrm (cp_delstrm_id VARCHAR2, cp_nom_cycle VARCHAR, cp_daytime DATE) IS
--Sum scheduled qty for delivery stream
SELECT sum(n.SCHEDULED_QTY) SUM_SCHEDULED_QTY,
       sum(n.rep_scheduled_qty) SUM_REP_SCHEDULED_QTY
  FROM nompnt_day_delivery n,
       nomination_point    p,
       nompnt_version      nv,
       delivery_stream     s,
       delstrm_version     v
 WHERE n.object_id = p.object_id
   AND p.object_id = nv.object_id
   AND p.entry_location_id IS NULL
   AND p.exit_location_id = s.object_id
   AND s.object_id = v.object_id
   AND v.daytime <= n.daytime
   AND Nvl(v.end_date, n.daytime + 1) > n.daytime
   AND nvl(nv.end_date, n.daytime + 1) > n.daytime
   AND n.daytime = cp_daytime
   AND nv.daytime <= n.daytime
   AND s.object_id = cp_delstrm_id
   AND n.nomination_type = 'TRAN_OUTPUT'
   AND nvl(n.nom_cycle_code, 'a') = nvl(cp_nom_cycle, 'a')
   AND nvl(nv.operational, 'N') = 'N';

 CURSOR c_in_nom_del_delpnt (cp_delpnt_id VARCHAR2, cp_nom_cycle VARCHAR, cp_daytime DATE,cp_nom_seq NUMBER) IS
 SELECT
         n.daytime,
	     d.object_id,
	     d.object_code,
	     p.contract_id,
         n.nomination_type,
         n.SCHEDULED_QTY,
         n.rep_scheduled_qty
	FROM nompnt_day_delivery n,
	     nomination_point      p,
	     delivery_point        d,
         nompnt_version nv
  WHERE n.object_id = p.object_id
    AND p.object_id = nv.object_id
    AND p.entry_location_id = d.object_id
    AND p.exit_location_id iS NULL
	AND n.daytime = cp_daytime
    AND nv.daytime <= n.daytime
    AND Nvl(nv.end_date, n.daytime + 1) > n.daytime
	AND d.object_id = cp_delpnt_id
	AND n.nomination_type = 'TRAN_INPUT'
	AND nvl(n.nom_cycle_code, 'a') = nvl(cp_nom_cycle, 'a')
    AND nvl(nv.operational,'N') = 'N'
    and n.nomination_seq = cp_nom_seq;

CURSOR c_out_nom_del_delpnt (cp_delpnt_id VARCHAR2, cp_nom_cycle VARCHAR, cp_daytime DATE,cp_nom_seq NUMBER) IS
 SELECT  n.daytime,
	     d.object_id,
	     d.object_code,
	     p.contract_id,
         n.nomination_type,
         n.SCHEDULED_QTY,
         n.rep_scheduled_qty
    FROM nompnt_day_delivery n,
	     nomination_point    p,
	     delivery_point      d,
		 nompnt_version nv
  WHERE n.object_id = p.object_id
    AND p.object_id = nv.object_id
    AND p.entry_location_id iS NULL
    AND p.exit_location_id = d.object_id
	AND n.daytime = cp_daytime
    AND nv.daytime <= n.daytime
    AND Nvl(nv.end_date, n.daytime + 1) > n.daytime
	AND d.object_id = cp_delpnt_id
	AND n.nomination_type = 'TRAN_OUTPUT'
	AND nvl(n.nom_cycle_code, 'a') = nvl(cp_nom_cycle, 'a')
    AND nvl(nv.operational,'N') = 'N'
    and n.nomination_seq = cp_nom_seq;

CURSOR c_in_nom_del_delstrm (cp_delstrm_id VARCHAR2, cp_nom_cycle VARCHAR, cp_daytime DATE,cp_nom_seq NUMBER) IS
SELECT s.object_id,
       s.object_code,
       n.SCHEDULED_QTY,
       n.rep_scheduled_qty
  FROM nompnt_day_delivery n,
       nomination_point      p,
       delivery_stream       s,
       delstrm_version       v,
       nompnt_version nv
 WHERE n.object_id = p.object_id
   AND p.object_id = nv.object_id
   AND p.entry_location_id = s.object_id
   AND p.exit_location_id IS NULL
   AND s.object_id = v.object_id
   AND v.daytime <= n.daytime
   AND nv.daytime <= n.daytime
   AND nvl(v.end_date, n.daytime + 1) > n.daytime
   AND Nvl(nv.end_date, n.daytime + 1) > n.daytime
   AND n.daytime = cp_daytime
   AND s.object_id = cp_delstrm_id
   AND n.nomination_type = 'TRAN_INPUT'
   AND nvl(n.nom_cycle_code, 'a') = nvl(cp_nom_cycle, 'a')
   AND nvl(nv.operational,'N') = 'N'
   and n.nomination_seq = cp_nom_seq;

CURSOR c_out_nom_del_delstrm (cp_delstrm_id VARCHAR2, cp_nom_cycle VARCHAR, cp_daytime DATE, cp_nom_seq NUMBER) IS
SELECT s.object_id,
       s.object_code,
       n.SCHEDULED_QTY,
       n.rep_scheduled_qty
  FROM nompnt_day_delivery n,
       nomination_point      p,
       delivery_stream       s,
       delstrm_version       v,
       nompnt_version    nv
 WHERE n.object_id = p.object_id
   AND p.object_id = nv.object_id
   AND p.entry_location_id IS NULL
   AND p.exit_location_id = s.object_id
   AND s.object_id = v.object_id
   AND v.daytime <= n.daytime
   AND nv.daytime <= n.daytime
   AND Nvl(v.end_date, n.daytime + 1) > n.daytime
   AND Nvl(nv.end_date, n.daytime + 1) > n.daytime
   AND n.daytime = cp_daytime
   AND s.object_id = cp_delstrm_id
   AND n.nomination_type = 'TRAN_OUTPUT'
   AND nvl(n.nom_cycle_code, 'a') = nvl(cp_nom_cycle, 'a')
   and nvl(nv.operational,'N') = 'N'
   and n.nomination_seq = cp_nom_seq;

 --<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNomSplit
-- Description    : Returns aggregated qty for a nomination location on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_delivery
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getNomSplit(
  p_loc_id            VARCHAR2,
  p_nom_cycle            VARCHAR2,
  p_loc_type           VARCHAR2,
  p_date                 DATE,
  p_nom_seq              NUMBER

)
RETURN NUMBER
--</EC-DOC>
IS
	lv_loc_class  VARCHAR2(32) :=NULL;
	ln_return_qty 	NUMBER := NULL;


BEGIN
  lv_loc_class:=ecdp_objects.GetObjClassName(p_loc_id);
  IF(lv_loc_class = 'DELIVERY_POINT') Then
        ln_return_qty:=getTotalSchedQtyPrDelpnt(p_loc_id,p_nom_cycle,p_loc_type,p_date,p_nom_seq);
        END IF;
  IF(lv_loc_class = 'DELIVERY_STREAM') Then
        ln_return_qty:=getTotalSchedQtyPrDelstrm(p_loc_id,p_nom_cycle,p_loc_type,p_date,p_nom_seq);
  END IF;

  IF ln_return_qty IS NULL THEN
        ln_return_qty:= 0;
  END IF;

  return ln_return_qty;

END getNomSplit;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalSchedQtyPrDelpnt
-- Description    :returns aggregated qty for a delivery point on a given day for a given cycle,
--                  either or output based on parameter.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_delivery
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
  p_nom_cycle            VARCHAR2,
  p_loc_type           VARCHAR2,
  p_date                 DATE,
  p_nom_seq NUMBER

)
RETURN NUMBER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;


BEGIN

    IF (p_loc_type = 'ENTRY') THEN
		-- loop input nominations
		FOR curInput IN c_in_nom_del_delpnt (p_delpnt_id, p_nom_cycle, p_date,p_nom_seq) LOOP
			FOR curSumInput IN c_sum_in_nom_del_delpnt(p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
				ln_input_qty := curInput.Scheduled_Qty/curSumInput.SUM_SCHEDULED_QTY*100;
		    END LOOP;
    END LOOP;
   ln_return_qty:=ln_input_qty;
   END IF;

   IF (p_loc_type = 'EXIT') THEN
		FOR curOutput IN c_out_nom_del_delpnt(p_delpnt_id, p_nom_cycle, p_date,p_nom_seq) LOOP
      FOR curSumOutput IN c_sum_out_nom_del_delpnt(p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
			ln_output_qty := curOutput.Scheduled_Qty/curSumOutput.SUM_SCHEDULED_QTY*100;
			END LOOP;
		END LOOP;
    ln_return_qty:=ln_output_qty;
    END IF;

  RETURN ln_return_qty;

END getTotalSchedQtyPrDelpnt;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalSchedQtyPrDelstrm
-- Description    : returns aggregated qty for a delivery point on a given day for a given cycle,
--                  either or output based on parameter.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_delivery
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
  p_loc_type           VARCHAR2,
  p_date                   DATE,
  p_nom_seq NUMBER
)
RETURN NUMBER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN

    IF (p_loc_type = 'ENTRY') THEN
		-- loop input nominations
    FOR curInput IN c_in_nom_del_delstrm (p_delstrm_id, p_nom_cycle, p_date,p_nom_seq) LOOP
		    FOR curSumInput IN c_sum_in_nom_del_delstrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
				ln_input_qty := curInput.Scheduled_Qty/curSumInput.SUM_SCHEDULED_QTY*100;
			END LOOP;
		END LOOP;
    ln_return_qty:=ln_input_qty;
    END IF;

    IF (p_loc_type = 'EXIT') THEN
    --loop output nominations
		FOR curOutput IN c_out_nom_del_delstrm (p_delstrm_id, p_nom_cycle, p_date,p_nom_seq) LOOP
      FOR curSumOutput IN c_sum_out_nom_del_delstrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
				ln_output_qty := curOutput.Scheduled_Qty/curSumOutput.SUM_SCHEDULED_QTY*100;
			END LOOP;
		END LOOP;
    ln_return_qty:=ln_output_qty;
    END IF;


  	RETURN ln_return_qty;

END getTotalSchedQtyPrDelstrm;

 --<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getRepNomSplit
-- Description    : Returns aggregated qty for a nomination location on a given day for a given cycle
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_delivery
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getRepNomSplit(
  p_loc_id            VARCHAR2,
  p_nom_cycle            VARCHAR2,
  p_loc_type           VARCHAR2,
  p_date                 DATE,
  p_nom_seq              NUMBER

)
RETURN NUMBER
--</EC-DOC>
IS
	lv_loc_class  VARCHAR2(32) :=NULL;
	ln_return_qty 	NUMBER := NULL;


BEGIN
  lv_loc_class:=ecdp_objects.GetObjClassName(p_loc_id);
  IF(lv_loc_class = 'DELIVERY_POINT') Then
        ln_return_qty:=getTotalRepSchedQtyPrDelpnt(p_loc_id,p_nom_cycle,p_loc_type,p_date,p_nom_seq);
        END IF;
  IF(lv_loc_class = 'DELIVERY_STREAM') Then
        ln_return_qty:=getTotalRepSchedQtyPrDelstrm(p_loc_id,p_nom_cycle,p_loc_type,p_date,p_nom_seq);
  END IF;

  IF ln_return_qty IS NULL THEN
        ln_return_qty:= 0;
  END IF;

  return ln_return_qty;

END getRepNomSplit;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalRepSchedQtyPrDelpnt
-- Description    :returns aggregated qty for a delivery point on a given day for a given cycle,
--                  either or output based on parameter.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_delivery
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalRepSchedQtyPrDelpnt(
  p_delpnt_id            VARCHAR2,
  p_nom_cycle            VARCHAR2,
  p_loc_type           VARCHAR2,
  p_date                 DATE,
  p_nom_seq NUMBER

)
RETURN NUMBER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN

	--lv_dp_uom := ec_delpnt_version.nom_uom(p_delpnt_id, p_date, '<=');
    IF (p_loc_type = 'ENTRY') THEN
		-- loop input nominations
		FOR curInput IN c_in_nom_del_delpnt (p_delpnt_id, p_nom_cycle, p_date,p_nom_seq) LOOP
			FOR curSumInput IN c_sum_in_nom_del_delpnt(p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
				ln_input_qty := curInput.Rep_Scheduled_Qty/curSumInput.SUM_REP_SCHEDULED_QTY*100;
		    END LOOP;
		END LOOP;
   ln_return_qty:=ln_input_qty;
   END IF;

   IF (p_loc_type = 'EXIT') THEN
		FOR curOutput IN c_out_nom_del_delpnt(p_delpnt_id, p_nom_cycle, p_date,p_nom_seq) LOOP
			FOR curSumOutput IN c_sum_out_nom_del_delpnt(p_delpnt_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
				ln_output_qty := curOutput.Rep_Scheduled_Qty/curSumOutput.SUM_REP_SCHEDULED_QTY*100;
			END LOOP;
		END LOOP;
    ln_return_qty:=ln_output_qty;
    END IF;

  RETURN ln_return_qty;

END getTotalRepSchedQtyPrDelpnt;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalRepSchedQtyPrDelstrm
-- Description    : returns aggregated qty for a delivery point on a given day for a given cycle,
--                  either or output based on parameter.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nompnt_day_delivery
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTotalRepSchedQtyPrDelstrm(
  p_delstrm_id            VARCHAR2,
  p_nom_cycle             VARCHAR2,
  p_loc_type           VARCHAR2,
  p_date                   DATE,
  p_nom_seq NUMBER
)
RETURN NUMBER
--</EC-DOC>
IS
	lv_dp_uom  		VARCHAR2(32);
	ln_input_qty 	NUMBER;
	ln_output_qty 	NUMBER;
	ln_return_qty 	NUMBER := NULL;

BEGIN

    IF (p_loc_type = 'ENTRY') THEN
		-- loop input nominations
    FOR curInput IN c_in_nom_del_delstrm (p_delstrm_id, p_nom_cycle, p_date,p_nom_seq) LOOP
		    FOR curSumInput IN c_sum_in_nom_del_delstrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
				ln_input_qty := curInput.Rep_Scheduled_Qty/curSumInput.SUM_REP_SCHEDULED_QTY*100;
			END LOOP;
		END LOOP;
    ln_return_qty:=ln_input_qty;
    END IF;

    IF (p_loc_type = 'EXIT') THEN
    --loop output nominations
		FOR curOutput IN c_out_nom_del_delstrm (p_delstrm_id, p_nom_cycle, p_date,p_nom_seq) LOOP
			FOR curSumOutput IN c_sum_out_nom_del_delstrm (p_delstrm_id, p_nom_cycle, p_date) LOOP
			-- validate contract attributes
				ln_output_qty := curOutput.Rep_Scheduled_Qty/curSumOutput.SUM_REP_SCHEDULED_QTY*100;
			END LOOP;
		END LOOP;
    ln_return_qty:=ln_output_qty;
    END IF;

  	RETURN ln_return_qty;

END getTotalRepSchedQtyPrDelstrm;

END ue_allocation;