CREATE OR REPLACE PACKAGE BODY EcDp_Stor_Fcst_Balance IS
/****************************************************************
** Package        :  EcDp_Stor_Fcst_Balance; body part
**
** $Revision: 1.15.4.7 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created        :  10.06.2008	Kari Sandvik
**
** Modification history:
**
** Date        Whom     Change description:
** ----------  -------- -------------------------------------------
**07.10.2011     lauuufus  ECPD-18670,remove check on sysdate in cursor c_sum_out for calcStorageLevel() and calcStorageLevelSubDay
**18.11.2011     leeeewei  ECPD-18670: Removed cursor parameter cp_sysdate in calcStorageLevel and calcStorageLevelSubDay
**12.09.2011     meisihil  ECPD-20962: Included balance delta in calcStorageLevel and calcStorageLevelSubDay
**24.01.2013     meisihil ECPD-22504: Updated functions getAccEstLiftedQtySubDay, calcStorageLevel and calcStorageLevelSubDay to support liftings spread over hours
**30.01.2013     meisihil ECPD-23233: Update calcStorageLevel to read initialize lifting account
******************************************************************/

/**private global session variables **/
gv_prev_forecast_id forecast.object_id%type;
gv_prev_forecast_id2 forecast.object_id%type;
gv_prev_forecast_id3 forecast.object_id%type;
gv_prev_object_id storage.object_id%type;
gv_prev_object_id2 storage.object_id%type;
gv_prev_object_id3 storage.object_id%type;
gv_prev_date DATE;
gv_prev_date2 DATE;
gv_prev_date3 DATE;
gv_prev_qty NUMBER;
gv_prev_qty2 NUMBER;
gv_prev_qty3 NUMBER;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcStorageLevel
-- Description    : Gets the storage level for storage and forecast
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcStorageLevel(p_storage_id VARCHAR2,
						p_forecast_id VARCHAR2,
						p_daytime DATE,
            p_xtra_qty NUMBER DEFAULT 0)
RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_sum_in (cp_storage_id VARCHAR2, cp_forecast_id VARCHAR2, cp_start DATE, cp_end DATE) IS
	SELECT 	SUM(f.forecast_qty) forecast_qty,
          SUM(f.forecast_qty2) forecast_qty2,
          SUM(f.forecast_qty3) forecast_qty3
	FROM	stor_day_fcst_fcast f
	WHERE	f.object_id = cp_storage_id
			AND f.forecast_id = cp_forecast_id
	      	AND f.daytime >= cp_start
	      	AND f.daytime <= cp_end;

CURSOR c_sum_out (cp_storage_id VARCHAR2, cp_forecast_id VARCHAR2, cp_start DATE, cp_end DATE, cp_cargo_off_qty_ind VARCHAR2, cp_xtra_qty NUMBER) IS
	SELECT SUM(lifted) lifted_qty, SUM(balance_delta_qty) balance_delta_qty
	FROM (
			SELECT  decode(
              cp_xtra_qty,1,
              decode(cp_cargo_off_qty_ind,'N',n.grs_vol_nominated2,nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no,1),   n.grs_vol_nominated2)),
              2,decode(cp_cargo_off_qty_ind,'N',n.grs_vol_nominated3,nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no,2),   n.grs_vol_nominated3)),
              decode(cp_cargo_off_qty_ind,'N',n.grs_vol_nominated ,nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no,null),n.grs_vol_nominated))
              )  lifted,
              decode(
              cp_xtra_qty,1,
              decode(cp_cargo_off_qty_ind,'N',n.balance_delta_qty2,nvl(ecbp_storage_lift_nomination.getLoadBalDeltaVol(n.parcel_no,1),   n.balance_delta_qty2)),
              2,decode(cp_cargo_off_qty_ind,'N',n.balance_delta_qty3,nvl(ecbp_storage_lift_nomination.getLoadBalDeltaVol(n.parcel_no,2),   n.balance_delta_qty3)),
              decode(cp_cargo_off_qty_ind,'N',n.balance_delta_qty ,nvl(ecbp_storage_lift_nomination.getLoadBalDeltaVol(n.parcel_no,null),n.balance_delta_qty))
              )  balance_delta_qty
			FROM 	stor_fcst_lift_nom n,
					cargo_fcst_transport c
			WHERE 	n.object_id = cp_storage_id
				AND n.forecast_id = cp_forecast_id
				AND c.cargo_no = n.cargo_no
				AND c.forecast_id = n.forecast_id
				AND c.cargo_status <> 'D'
				AND nvl(n.DELETED_IND, 'N') <> 'Y'
				AND nvl(n.bl_date, n.nom_firm_date) >= cp_start
				AND nvl(n.bl_date, n.nom_firm_date) <= cp_end
		UNION ALL
			SELECT  decode(
              cp_xtra_qty,1,
              n.grs_vol_nominated2,2,
              n.grs_vol_nominated3,
              n.grs_vol_nominated)  lifted,
              decode(
              cp_xtra_qty,1,
              n.balance_delta_qty2,2,
              n.balance_delta_qty3,
              n.balance_delta_qty) balance_delta_qty
			FROM 	stor_fcst_lift_nom n
			WHERE 	n.object_id = cp_storage_id
				AND n.forecast_id = cp_forecast_id
				AND n.cargo_no IS NULL
				AND nvl(n.DELETED_IND, 'N') <> 'Y'
				AND nvl(n.bl_date, n.nom_firm_date) >= cp_start
				AND nvl(n.bl_date, n.nom_firm_date) <= cp_end
		) a;

CURSOR c_sum_out_sub_day (cp_storage_id VARCHAR2, cp_forecast_id VARCHAR2, cp_start DATE, cp_end DATE, cp_xtra_qty NUMBER) IS
	SELECT SUM(lifted) lifted_qty, SUM(balance_delta_qty) balance_delta_qty
	FROM (
			SELECT
                    ue_Stor_Fcst_Lift_Nom.aggrSubDayLifting(n.forecast_id, n.PARCEL_NO, sn.production_day, NULL, cp_xtra_qty) lifted,
                    ue_Stor_Fcst_Lift_Nom.aggrSubDayLifting(n.forecast_id, n.PARCEL_NO, sn.production_day, 'BALANCE_DELTA', cp_xtra_qty) balance_delta_qty
			FROM 	stor_fcst_lift_nom n,
					cargo_fcst_transport c,
      	            (SELECT distinct forecast_id, production_day, parcel_no FROM stor_fcst_sub_day_lift_nom) sn
			WHERE 	n.object_id = cp_storage_id
				AND n.forecast_id = cp_forecast_id
				AND c.cargo_no = n.cargo_no
				AND c.forecast_id = n.forecast_id
		        AND n.parcel_no = sn.parcel_no
		        AND n.forecast_id = sn.forecast_id
				AND c.cargo_status <> 'D'
				AND nvl(n.DELETED_IND, 'N') <> 'Y'
				AND sn.production_day >= cp_start
				AND sn.production_day <= cp_end
		UNION ALL
			SELECT
                    ue_Stor_Fcst_Lift_Nom.aggrSubDayLifting(n.forecast_id, n.PARCEL_NO, sn.production_day, NULL, cp_xtra_qty) lifted,
                    ue_Stor_Fcst_Lift_Nom.aggrSubDayLifting(n.forecast_id, n.PARCEL_NO, sn.production_day, 'BALANCE_DELTA', cp_xtra_qty) balance_delta_qty
			FROM 	stor_fcst_lift_nom n,
      	            (SELECT distinct forecast_id, production_day, parcel_no FROM stor_fcst_sub_day_lift_nom) sn
			WHERE 	n.object_id = cp_storage_id
				AND n.forecast_id = cp_forecast_id
				AND n.cargo_no IS NULL
		        AND n.parcel_no = sn.parcel_no
		        AND n.forecast_id = sn.forecast_id
				AND nvl(n.DELETED_IND, 'N') <> 'Y'
				AND sn.production_day >= cp_start
				AND sn.production_day <= cp_end
		) a;

	ld_StartDate	DATE;
	ld_EndDate		DATE;
	ld_today		DATE;
	ln_Dip 			NUMBER;
	lnTotalIn		NUMBER;
	lnTotalOut		NUMBER;
 	ln_balance_delta NUMBER;
    lv_prev_forecast_id forecast.object_id%type;
    lv_prev_object_id storage.object_id%type;
	lv_prev_qty     NUMBER;
	lv_prev_date    DATE;
    lv_read_sub_day VARCHAR2(1);

BEGIN
    lv_read_sub_day := ecdp_ctrl_property.getSystemProperty('/com/ec/tran/cargo/storage_level/use_sub_day');

    IF gv_prev_QTY IS NULL THEN
    	gv_prev_forecast_id := '0';
       	gv_prev_object_id := '0';
        gv_prev_QTY:=0;
        gv_prev_DATE := TO_DATE('1900-01-01','YYYY-MM-dd');
    END IF;
    IF gv_prev_QTY2 IS NULL THEN
    	gv_prev_forecast_id2 := '0';
       	gv_prev_object_id2 := '0';
        gv_prev_QTY2:=0;
        gv_prev_DATE2 := TO_DATE('1900-01-01','YYYY-MM-dd');
    END IF;
    IF gv_prev_QTY3 IS NULL THEN
    	gv_prev_forecast_id3 := '0';
       	gv_prev_object_id3 := '0';
        gv_prev_QTY3:=0;
        gv_prev_DATE3 := TO_DATE('1900-01-01','YYYY-MM-dd');
    END IF;

	ld_today := TRUNC(ecdp_date_time.getCurrentSysdate);

    IF P_XTRA_QTY=1 THEN
        --use prev_date2 and prev_qty2
        lv_prev_forecast_id := gv_prev_forecast_id2;
        lv_prev_object_id := gv_prev_object_id2;
        lv_prev_date:=gv_prev_date2;
        lv_prev_qty:=gv_prev_qty2;
    ELSIF P_XTRA_QTY=2 THEN
        --use prev_date3 and prev_qty3
        lv_prev_forecast_id := gv_prev_forecast_id3;
        lv_prev_object_id := gv_prev_object_id3;
        lv_prev_date:=gv_prev_date3;
        lv_prev_qty:=gv_prev_qty3;
    ELSE
        --use prev_date and prev_qty
        lv_prev_forecast_id := gv_prev_forecast_id;
        lv_prev_object_id := gv_prev_object_id;
        lv_prev_date:=gv_prev_date;
        lv_prev_qty:=gv_prev_qty;
    END IF;

	-- Get opening balance for forecast period
	ld_StartDate := ec_forecast.start_date(p_forecast_id);
    IF (lv_prev_forecast_id = p_forecast_id) AND (lv_prev_object_id = p_storage_id) AND (p_daytime >= ld_today) AND (trunc(lv_prev_date, 'DD') - trunc(p_daytime, 'DD') = 0) THEN
        --prev_date and p_daytime is identical and in the future
        RETURN NVL(lv_prev_qty, 0); --+0.0001;
    ELSIF (lv_prev_forecast_id = p_forecast_id) AND (lv_prev_object_id = p_storage_id) AND (p_daytime>=ld_today) AND (trunc(lv_prev_date,'DD') - trunc(p_daytime-1,'DD')=0) THEN
        --prev_date is the day before p_daytime and in the future
        ld_StartDate := p_daytime;
        ln_dip := NVL(lv_prev_qty,0); --DEBUG + .01;
    ELSE
    	ln_Dip := getInitBalance(p_storage_id, p_forecast_id, p_xtra_qty);
    	IF ln_Dip IS NULL THEN
	        ln_Dip := EcDp_Storage_Balance.calcStorageLevel(p_storage_id, ld_StartDate-1, NULL, p_xtra_qty);
	    END IF;
    END IF;

	ld_EndDate := p_daytime;

	-- get official/planned incomming
	FOR curIn IN c_sum_in (p_storage_id, p_forecast_id, ld_StartDate, ld_EndDate) LOOP

      IF P_XTRA_QTY = 1 THEN
         lnTotalIn := curIn.forecast_qty2;
      ELSIF P_XTRA_QTY = 2 THEN
         lnTotalIn := curIn.forecast_qty3;
      ELSE
         lnTotalIn := curIn.forecast_qty;
      END IF;

	END LOOP;

	IF ld_today > ld_EndDate THEN
		ld_today := ld_EndDate;
	END IF;

	-- get official/planned lifted
    IF nvl(lv_read_sub_day, 'N') = 'Y' THEN
		FOR curOut IN c_sum_out_sub_day (p_storage_id, p_forecast_id, ld_StartDate, ld_EndDate, p_xtra_qty) LOOP
	  		lnTotalOut := curOut.lifted_qty;
	  		ln_balance_delta := curOut.balance_delta_qty;
		END LOOP;
	ELSE
	FOR curOut IN c_sum_out (p_storage_id, p_forecast_id, ld_StartDate, ld_EndDate, nvl(ec_forecast.cargo_off_qty_ind(p_forecast_id),'N'), p_xtra_qty) LOOP
  		lnTotalOut := curOut.lifted_qty;
  		ln_balance_delta := curOut.balance_delta_qty;
	END LOOP;
	END IF;

	IF (ec_stor_version.storage_type(p_storage_id, p_daytime, '<=') = 'IMPORT') THEN
		ln_dip := ln_Dip - Nvl(lnTotalIn,0) + Nvl(lnTotalOut,0);
	ELSE
		ln_dip := ln_Dip + Nvl(lnTotalIn,0) - Nvl(lnTotalOut,0);
	END IF;

	ln_dip := ln_Dip - Nvl(ln_balance_delta,0);

   IF p_xtra_qty=1 THEN
   	gv_prev_forecast_id2 := p_forecast_id;
   	gv_prev_object_id2 := p_storage_id;
    gv_prev_date2:=p_daytime;
    gv_prev_qty2:=ln_dip;
   ELSIF p_xtra_qty=2 THEN
   	gv_prev_forecast_id3 := p_forecast_id;
   	gv_prev_object_id3 := p_storage_id;
    gv_prev_date3:=p_daytime;
    gv_prev_qty3:=ln_dip;
   ELSE
   	gv_prev_forecast_id := p_forecast_id;
   	gv_prev_object_id := p_storage_id;
    gv_prev_date:=p_daytime;
    gv_prev_qty:=ln_dip;
   END IF;

  return ln_dip;
END calcStorageLevel;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getAccEstLiftedQtySubDay
-- Description    : Returns the total lifted quantity for the prevoius hours of the day for selected lifting account
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : stor_fcst_lift_nom, cargo_fcst_transport
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getAccEstLiftedQtySubDay(p_lifting_account_id VARCHAR2, p_forecast_id VARCHAR2, p_startdate DATE, p_enddate DATE, p_xtra_qty NUMBER DEFAULT 0, p_incl_delta VARCHAR2 DEFAULT 'N', p_summer_time VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  CURSOR   c_lifting (cp_lifting_account_id VARCHAR2, cp_forecast_id VARCHAR2, cp_cargo_off_qty_ind VARCHAR2, cp_startdate DATE, cp_enddate DATE, cp_summer_time VARCHAR2) IS
    SELECT SUM(grs_vol_nominated) grs_vol_nominated, SUM(grs_vol_nominated2) grs_vol_nominated2, SUM(grs_vol_nominated3) grs_vol_nominated3,
    	   SUM(balance_delta_qty) balance_delta_qty, SUM(balance_delta_qty2) balance_delta_qty2, SUM(balance_delta_qty3) balance_delta_qty3
		FROM (    SELECT
              decode(cp_cargo_off_qty_ind,'N',sn.grs_vol_nominated ,nvl(ecbp_storage_lift_nomination.getLiftedVolSubDay(n.parcel_no, sn.daytime, sn.summer_time),sn.grs_vol_nominated)) grs_vol_nominated,
              decode(cp_cargo_off_qty_ind,'N',sn.grs_vol_nominated2,nvl(ecbp_storage_lift_nomination.getLiftedVolSubDay(n.parcel_no, sn.daytime, sn.summer_time,1),   sn.grs_vol_nominated2)) grs_vol_nominated2,
              decode(cp_cargo_off_qty_ind,'N',sn.grs_vol_nominated3,nvl(ecbp_storage_lift_nomination.getLiftedVolSubDay(n.parcel_no, sn.daytime, sn.summer_time,2),   sn.grs_vol_nominated3)) grs_vol_nominated3,
        	  decode(cp_cargo_off_qty_ind,'N',sn.balance_delta_qty,nvl(ecbp_storage_lift_nomination.getLoadBalDeltaVolSubDay(n.parcel_no, sn.daytime, sn.summer_time),   sn.balance_delta_qty)) balance_delta_qty,
              decode(cp_cargo_off_qty_ind,'N',sn.balance_delta_qty2,nvl(ecbp_storage_lift_nomination.getLoadBalDeltaVolSubDay(n.parcel_no, sn.daytime, sn.summer_time,1),sn.balance_delta_qty2)) balance_delta_qty2,
              decode(cp_cargo_off_qty_ind,'N',sn.balance_delta_qty3,nvl(ecbp_storage_lift_nomination.getLoadBalDeltaVolSubDay(n.parcel_no, sn.daytime, sn.summer_time,2),sn.balance_delta_qty3)) balance_delta_qty3
          FROM stor_fcst_lift_nom n, cargo_fcst_transport c, stor_fcst_sub_day_lift_nom sn
         WHERE n.lifting_account_id = cp_lifting_account_id
           AND n.parcel_no = sn.parcel_no
           AND n.forecast_id = sn.forecast_id
           AND sn.daytime between cp_startdate and cp_enddate
		   AND nvl(n.deleted_ind, 'N') <> 'Y'
           AND c.cargo_no = n.cargo_no
           AND c.forecast_id = n.forecast_id
           AND c.cargo_status <> 'D'
		   AND c.forecast_id = cp_forecast_id
		   AND sn.summer_time = NVL(cp_summer_time, sn.summer_time)
        UNION ALL
        SELECT sn.grs_vol_nominated,
               sn.grs_vol_nominated2,
               sn.grs_vol_nominated3,
               sn.balance_delta_qty,
               sn.balance_delta_qty2,
               sn.balance_delta_qty3
          FROM stor_fcst_lift_nom n, stor_fcst_sub_day_lift_nom sn
         WHERE n.lifting_account_id = cp_lifting_account_id
           AND n.forecast_id = cp_forecast_id
           AND n.parcel_no = sn.parcel_no
           AND n.forecast_id = sn.forecast_id
           AND sn.daytime between cp_startdate and cp_enddate
		   AND nvl(n.deleted_ind, 'N') <> 'Y'
           AND n.cargo_no is null
		   AND sn.summer_time = NVL(cp_summer_time, sn.summer_time)) a;
  ln_lifted_qty  NUMBER;
  ln_balance_delta_qty NUMBER;

BEGIN
	FOR curLifted IN c_lifting (p_lifting_account_id, p_forecast_id, nvl(ec_forecast.cargo_off_qty_ind(p_forecast_id),'N'), p_startdate, p_enddate, p_summer_time) LOOP
		IF (p_xtra_qty = 1 ) THEN
			ln_lifted_qty := curLifted.grs_vol_nominated2 ;
            ln_balance_delta_qty := curLifted.balance_delta_qty2;
		ELSIF (p_xtra_qty = 2 ) THEN
			ln_lifted_qty := curLifted.grs_vol_nominated3 ;
            ln_balance_delta_qty := curLifted.balance_delta_qty3;
		ELSE
			ln_lifted_qty := curLifted.grs_vol_nominated ;
            ln_balance_delta_qty := curLifted.balance_delta_qty;
		END IF;
	END LOOP;

    IF p_incl_delta = 'Y' THEN
    	IF (ec_stor_version.storage_type(ec_lifting_account.storage_id(p_lifting_account_id), p_startdate, '<=') = 'IMPORT') THEN
    		ln_lifted_qty := NVL(ln_lifted_qty, 0) - NVL(ln_balance_delta_qty, 0);
    	ELSE
    		ln_lifted_qty := NVL(ln_lifted_qty, 0) + NVL(ln_balance_delta_qty, 0);
    	END IF;
	END IF;
  RETURN ln_lifted_qty;

END getAccEstLiftedQtySubDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcStorageLevelSubDay
-- Description    : Gets the storage level for a date based on planned/official production.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : stor_sub_day_fcst_fcast,  stor_sub_day_official, storage_nomination
--
-- Using functions: calcStorageLevel, EcDp_ProductionDay.getProductionDay
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcStorageLevelSubDay(p_storage_id  VARCHAR2,
                                p_forecast_id VARCHAR2,
                                p_daytime     DATE,
                                p_summer_time VARCHAR2,
								p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER
--</EC-DOC>
 IS
    CURSOR c_sum_in(cp_storage_id VARCHAR2, cp_forecast_id VARCHAR2, cp_start DATE, cp_end DATE) IS
        SELECT SUM(f.forecast_qty) OP,
			   SUM(f.forecast_qty2) OP2,
			   SUM(f.forecast_qty3) OP3
		  FROM stor_sub_day_fcst_fcast f
         WHERE f.object_id = cp_storage_id
           AND f.daytime >= cp_start
           AND f.daytime <= cp_end
		   AND f.forecast_id = cp_forecast_id;

    CURSOR c_sum_intercept(cp_storage_id VARCHAR2, cp_forecast_id VARCHAR2, cp_start DATE, cp_end DATE, cp_summer_time VARCHAR2) IS
        SELECT SUM(f.forecast_qty) OP,
			   SUM(f.forecast_qty2) OP2,
			   SUM(f.forecast_qty3) OP3
		  FROM stor_sub_day_fcst_fcast f
         WHERE f.object_id = cp_storage_id
           AND f.daytime >= cp_start
           AND f.daytime <= cp_end
		   AND f.forecast_id = cp_forecast_id
           AND f.summer_time = cp_summer_time;


	CURSOR c_sumerTime_flag(cp_storage_id VARCHAR2, cp_start DATE, cp_end DATE) IS
		SELECT ecdp_date_time.summertime_flag(t.daytime) summerFlag
		from stor_sub_day_fcst_fcast t
		where t.daytime >= cp_start
			AND t.daytime <= cp_end
			AND t.object_id = cp_storage_id;

    CURSOR c_sum_out(cp_storage_id VARCHAR2, cp_forecast_id VARCHAR2, cp_start DATE, cp_end DATE, cp_cargo_off_qty_ind VARCHAR2, cp_xtra_qty NUMBER, cp_summer_time VARCHAR2 DEFAULT NULL) IS
        SELECT SUM(lifted) lifted_qty, SUM(balance_delta_qty) balance_delta_qty
          FROM (
	            SELECT  decode(
              cp_xtra_qty,1,
              decode(cp_cargo_off_qty_ind,'N',sn.grs_vol_nominated2, nvl(ecbp_storage_lift_nomination.getLiftedVolSubDay(n.parcel_no, sn.daytime, sn.summer_time, 1),    sn.grs_vol_nominated2)),
              2, decode(cp_cargo_off_qty_ind,'N',sn.grs_vol_nominated3, nvl(ecbp_storage_lift_nomination.getLiftedVolSubDay(n.parcel_no, sn.daytime, sn.summer_time, 2),    sn.grs_vol_nominated3)),
              decode(cp_cargo_off_qty_ind,'N',sn.grs_vol_nominated,  nvl(ecbp_storage_lift_nomination.getLiftedVolSubDay(n.parcel_no, sn.daytime, sn.summer_time), sn.grs_vol_nominated))
              )  lifted,
              decode(
              cp_xtra_qty,1,
              decode(cp_cargo_off_qty_ind,'N',sn.balance_delta_qty2,nvl(ecbp_storage_lift_nomination.getLoadBalDeltaVolSubDay(n.parcel_no, sn.daytime, sn.summer_time,1),   sn.balance_delta_qty2)),
              2,decode(cp_cargo_off_qty_ind,'N',sn.balance_delta_qty3,nvl(ecbp_storage_lift_nomination.getLoadBalDeltaVolSubDay(n.parcel_no, sn.daytime, sn.summer_time,2),   sn.balance_delta_qty3)),
              decode(cp_cargo_off_qty_ind,'N',sn.balance_delta_qty ,nvl(ecbp_storage_lift_nomination.getLoadBalDeltaVolSubDay(n.parcel_no, sn.daytime, sn.summer_time),sn.balance_delta_qty))
              )  balance_delta_qty
                  FROM stor_fcst_lift_nom n, cargo_fcst_transport c, stor_fcst_sub_day_lift_nom sn
                 WHERE n.object_id = cp_storage_id
				   AND n.forecast_id = c.forecast_id
				   AND n.forecast_id = cp_forecast_id
				   AND n.parcel_no = sn.parcel_no
                   AND n.forecast_id = sn.forecast_id
                   AND nvl(n.deleted_ind, 'N') <> 'Y'
                   AND c.cargo_no = n.cargo_no
                   AND c.cargo_status <> 'D'
                   AND sn.daytime >= cp_start
                   AND sn.daytime <= cp_end
				   AND sn.summer_time = NVL(cp_summer_time, sn.summer_time)
                UNION ALL
                SELECT decode (cp_xtra_qty, 0, sn.grs_vol_nominated, 1, sn.grs_vol_nominated2, 2, sn.grs_vol_nominated3) lifted,
                       decode(cp_xtra_qty, 0, sn.balance_delta_qty, 1, sn.balance_delta_qty2, 2, sn.balance_delta_qty3) balance_delta_qty
                  FROM stor_fcst_lift_nom n, stor_fcst_sub_day_lift_nom sn
                 WHERE n.object_id = cp_storage_id
                   AND n.forecast_id = cp_forecast_id
                   AND n.parcel_no = sn.parcel_no
                   AND n.forecast_id = sn.forecast_id
                   AND n.cargo_no IS NULL
                   AND sn.daytime >= cp_start
                   AND sn.daytime <= cp_end
				   AND sn.summer_time = NVL(cp_summer_time, sn.summer_time)
				   AND nvl(n.deleted_ind, 'N') <> 'Y') a;

    ld_today          DATE;
    ld_startDate      DATE;
    ln_Dip            NUMBER;
    lnTotalIn         NUMBER;
    lnTotalOut        NUMBER;
 	ln_balance_delta NUMBER;
    ld_production_day DATE;
	lv_summer_flag   VARCHAR2(32);

BEGIN
    ld_production_day := EcDp_ProductionDay.getProductionDay('STORAGE', p_storage_id, p_daytime, p_summer_time);
    ld_startDate      := EcDp_ProductionDay.getProductionDayStart('STORAGE', p_storage_id, ld_production_day);
    ld_today          := TRUNC(ecdp_date_time.getCurrentSysdate);

    -- get opening balance of the day need to check if production day is required
    ln_Dip := calcStorageLevel(p_storage_id, p_forecast_id, ld_production_day - 1, p_xtra_qty);

	--checking the summer time flag intercept
	FOR curIn IN c_sumerTime_flag(p_storage_id, ld_startDate, p_daytime) LOOP
		lv_summer_flag := curIn.summerFlag;
	END LOOP;

    IF(p_summer_time != lv_summer_flag)THEN
		-- Get forecast/official production during an intercept
		FOR curIn IN c_sum_intercept(p_storage_id, p_forecast_id, ld_startDate, p_daytime, p_summer_time) LOOP
			IF (p_xtra_qty = 1 ) THEN
				lnTotalIn := curIn.op2;
			ELSIF (p_xtra_qty = 2 ) THEN
				lnTotalIn := curIn.op3;
			ELSE
				lnTotalIn := curIn.op;
			END IF;
		END LOOP;

		-- get all nominations during an intercept
		FOR curOut IN c_sum_out(p_storage_id, p_forecast_id, ld_StartDate, p_daytime, nvl(ec_forecast.cargo_off_qty_ind(p_forecast_id),'N'), p_xtra_qty, p_summer_time) LOOP
			lnTotalOut := curOut.lifted_qty;
			ln_balance_delta := curOut.balance_delta_qty;
		END LOOP;
	ELSE
		-- Get forecast/official production normal operations
		FOR curIn IN c_sum_in(p_storage_id, p_forecast_id, ld_startDate, p_daytime) LOOP
			IF (p_xtra_qty = 1 ) THEN
				lnTotalIn := curIn.op2;
			ELSIF (p_xtra_qty = 2 ) THEN
				lnTotalIn := curIn.op3;
			ELSE
				lnTotalIn := curIn.op;
			END IF;
		END LOOP;

		-- get all nominations normal operations
		FOR curOut IN c_sum_out(p_storage_id, p_forecast_id, ld_StartDate, p_daytime, nvl(ec_forecast.cargo_off_qty_ind(p_forecast_id),'N'), p_xtra_qty) LOOP
			lnTotalOut := curOut.lifted_qty;
			ln_balance_delta := curOut.balance_delta_qty;
		END LOOP;
	END IF;

    IF (ec_stor_version.storage_type(p_storage_id, p_daytime, '<=') = 'IMPORT') THEN
		ln_dip := ln_Dip - Nvl(lnTotalIn,0) + Nvl(lnTotalOut,0);
    ELSE
		ln_dip := ln_Dip + Nvl(lnTotalIn,0) - Nvl(lnTotalOut,0);
    END IF;

	ln_dip := ln_Dip - Nvl(ln_balance_delta,0);

	return ln_dip;

END calcStorageLevelSubDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getInitBalance
-- Description    : Finds initial balance for storage based on initial balance for the lifting accounts in the forecast
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :                                                                                                                          --
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getInitBalance(p_storage_id VARCHAR2, p_forecast_id VARCHAR2, p_xtra_qty NUMBER DEFAULT 0)
RETURN NUMBER
--<EC-DOC>
IS
	ln_opening_balance		NUMBER;
	ln_la_opening_bal		NUMBER;

	ld_forecast_start_day DATE;
	ld_start_mth DATE;

	CURSOR c_init_count(cp_object_id VARCHAR2, cp_forecast_id VARCHAR2)
	IS
		SELECT count(*) cnt
		  FROM fcst_lift_acc_init_bal bal, lifting_account la
		 WHERE bal.forecast_id = cp_forecast_id
		   AND bal.object_id = la.object_id
		   AND la.storage_id = cp_object_id;

	CURSOR c_init(cp_object_id VARCHAR2, cp_forecast_id VARCHAR2, cp_xtra_qty NUMBER)
	IS
		SELECT la.object_id, DECODE(cp_xtra_qty,0, balance, 1, balance2, 2, balance3) balance
		  FROM fcst_lift_acc_init_bal bal, lifting_account la
		 WHERE bal.forecast_id = cp_forecast_id
		   AND bal.object_id = la.object_id
		   AND la.storage_id = cp_object_id;
BEGIN
	ld_forecast_start_day := ec_forecast.start_date(p_forecast_id);
	ld_start_mth := TRUNC(ld_forecast_start_day, 'MONTH');

	FOR c_cnt IN c_init_count(p_storage_id, p_forecast_id) LOOP
		IF c_cnt.cnt > 0 THEN
			FOR c_cur IN c_init(p_storage_id, p_forecast_id, p_xtra_qty) LOOP
				IF c_cur.balance IS NULL THEN
					-- No initial opening balance on forecast - find from actual
					IF (ld_forecast_start_day = ld_start_mth) THEN
						-- get opening balance month
						ln_la_opening_bal := EcBp_Lift_Acc_Balance.calcEstOpeningBalanceMth(c_cur.object_id, ld_start_mth, p_xtra_qty );
					ELSE
						-- get opening balance for forecast
						ln_la_opening_bal := Nvl(EcBp_Lift_Acc_Balance.calcEstClosingBalanceDay(c_cur.object_id, ld_forecast_start_day-1,p_xtra_qty),0);
					END IF;
				ELSE
					ln_la_opening_bal := c_cur.balance;
				END IF;
				ln_opening_balance := NVL(ln_opening_balance, 0) + NVL(ln_la_opening_bal, 0);
			END LOOP;
		END IF;
	END LOOP;

	RETURN ln_opening_balance;
END;

END EcDp_Stor_Fcst_Balance;