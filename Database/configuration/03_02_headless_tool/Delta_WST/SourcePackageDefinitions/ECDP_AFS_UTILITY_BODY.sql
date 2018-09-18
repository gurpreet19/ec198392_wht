CREATE OR REPLACE PACKAGE BODY ecdp_afs_utility IS
  /**************************************************************************************************************
   ** Package  :  ecdp_afs_utility, body part
   **
   ** $Revision: 1.1 $
   **
   ** Purpose        :  Utility package for AFS Screens
   **
   ** Created        :  27.02.2015 Siew Meng
   **
   ** Modification history:
   **
   ** Date         Whom             Change description:
   ** ------       -----            ------------------------------------------------------------------------------------------
   ** 27.02.2015   chooysie         ECPD-29635 - Initial version.
   ** 11.03.2015   farhaann         ECPD-29637 - Added function getCummDiffMth,getCummAfsMth,getDailyDiffPerc,getCpySortOrder
   ** 13.07.2015   royyypur         ECPD-31435 - Added procedure deleteCompanyAfs
   ** 13.04.2017   thotesan         ECPD-44257 - Added procedure deleteNomPointCompanyAfs to delete the record from FCST_NOMPNT_DAY_CPY_AFS as soon as the record get deleted from FCST_NOMPNT_DAY_AFS table.
   ** 02.04.2018   asareswi         ECPD-50718 - Added procedure deleteStrDaySpAfs, deleteStrDayAfs to delete records from FCST_STRM_DAY_CPY_AFS, FCST_STRM_DAY_SP_CPY_AFS table as soon as records deleted from their respective table.
  **************************************************************************************************************/
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : getActualVol
  -- Description    : Get the Actual Well from the Supply Point (which can be Well or Stream)
  ---------------------------------------------------------------------------------------------------
  FUNCTION getActualVol(p_object_id  VARCHAR2
                      , p_daytime    DATE
					   ) RETURN NUMBER
     IS

     ln_actual   NUMBER;

  BEGIN

    -- Well or Stream?
    IF ecdp_objects.GetObjClassName(p_object_id) = 'WELL' THEN

      BEGIN

        SELECT AVG_GAS_RATE INTO ln_actual
			    FROM PWEL_DAY_STATUS
			   WHERE OBJECT_ID = p_object_id
			     AND DAYTIME = p_daytime;

		  EXCEPTION WHEN NO_DATA_FOUND THEN

        ln_actual := NULL;

      END;

    ELSIF ecdp_objects.GetObjClassName(p_object_id) = 'STREAM' THEN

      BEGIN

        SELECT GRS_VOL INTO ln_actual
			    FROM STRM_DAY_STREAM
			   WHERE OBJECT_ID = p_object_id
			     AND DAYTIME = p_daytime;

		  EXCEPTION WHEN NO_DATA_FOUND THEN

        ln_actual := NULL;

      END;

    END IF;

    RETURN ln_actual;

  END getActualVol;

  ---------------------------------------------------------------------------------------------------
  -- Procedure      : getActualCpy
  -- Description    : Gets Actual volume for Company by applying the AP Share to the total Actual
  ---------------------------------------------------------------------------------------------------
  FUNCTION getActualCpy( p_object_id   VARCHAR2
                        , p_daytime    DATE
                        , p_ap_share   NUMBER
                        ) RETURN NUMBER
     IS

     ln_cpy_actual NUMBER;
     ln_actual     NUMBER;

  BEGIN

    -- All input parameters should exist.
    IF p_object_id IS NULL OR p_daytime IS NULL OR p_ap_share IS NULL THEN
      RETURN NULL;
    END IF;

    -- Get Total Actual
    ln_cpy_actual:= getActualVol(p_object_id, p_daytime) * p_ap_share;

    RETURN ln_cpy_actual;

  END getActualCpy;

  ---------------------------------------------------------------------------------------------------
  -- Function      : getCummDiffMth
  -- Description   : This function gets the cummulative difference for the month from the FCST_AP_DAY_AFS_GRAPH class
  --                 The difference is sum(actual_qty) - sum(avail_net) from the begin-of-month till current-day
  ----------------------- ----------------------------------------------------------------------------
  FUNCTION getCummDiffMth(p_forecast_id      IN VARCHAR2,
                          p_object_id        IN VARCHAR2,
                          p_daytime          IN DATE,
                          p_transaction_type IN VARCHAR2) RETURN NUMBER IS

    lv_diff NUMBER;

  BEGIN

    SELECT SUM(NVL(getActualVol(object_id, daytime), ACTUAL_QTY)) -
           SUM(avail_net_qty)
      INTO lv_diff
      FROM fcst_sp_day_afs
     WHERE object_id = p_object_id
       AND forecast_id = p_forecast_id
       AND transaction_type = p_transaction_type
       AND daytime BETWEEN TRUNC(p_daytime, 'MM') AND TRUNC(p_daytime);

    RETURN lv_diff;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;

  END getCummDiffMth;

  ---------------------------------------------------------------------------------------------------
  -- Function      : getCummAfsMth
  -- Description   : This function gets the cummulative net avail for the month from FCST_SP_DAY_AFS
  --                 Sum(Avail_Net_Qty) from the begin-of-month till current-day
  ---------------------------------------------------------------------------------------------------
  FUNCTION getCummAfsMth(p_forecast_id      IN VARCHAR2,
                         p_object_id        IN VARCHAR2,
                         p_daytime          IN DATE,
                         p_transaction_type IN VARCHAR2) RETURN NUMBER IS

    lv_sum_afs NUMBER := 0;

  BEGIN

    SELECT SUM(avail_net_qty)
      INTO lv_sum_afs
      FROM fcst_sp_day_afs
     WHERE object_id = p_object_id
       AND forecast_id = p_forecast_id
       AND transaction_type = p_transaction_type
       AND daytime BETWEEN TRUNC(p_daytime, 'MM') AND TRUNC(p_daytime);

    RETURN lv_sum_afs;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;

  END getCummAfsMth;

  ---------------------------------------------------------------------------------------------------
  -- Function      : getAvailDailyDiff
  -- Description   : Avail_Daily_Diff = ACTUAL_QTY - AVAIL_NET
  ---------------------------------------------------------------------------------------------------
  FUNCTION getDailyDiffPerc(p_forecast_id      IN VARCHAR2,
                            p_object_id        IN VARCHAR2,
                            p_daytime          IN DATE,
                            p_transaction_type IN VARCHAR2) RETURN NUMBER IS

    ln_actual_qty NUMBER := NULL;
    ln_avail_net  NUMBER := NULL;
    lv_diff       NUMBER := NULL;

  BEGIN

    -- Get ACTUAL_QTY and AVAIL_NET
    BEGIN

      SELECT NVL(getActualVol(p_object_id, p_daytime), ACTUAL_QTY) actual_qty,
             avail_net_qty
        INTO ln_actual_qty, ln_avail_net
        FROM fcst_sp_day_afs
       WHERE object_id = p_object_id
         AND forecast_id = p_forecast_id
         AND transaction_type = p_transaction_type
         AND daytime = p_daytime;

    EXCEPTION
      WHEN OTHERS THEN

        ln_actual_qty := NULL;
        ln_avail_net  := NULL;

    END;

    -- Calculate Perc diff IF both ACTUAL_QTY and AVAIL_NET found
    IF ln_actual_qty IS NOT NULL AND ln_actual_qty <> 0 AND
       ln_avail_net IS NOT NULL THEN

      lv_diff := ROUND(((ln_actual_qty - ln_avail_net) / ln_actual_qty), 4);

      lv_diff := lv_diff * 100;

    END IF;

    RETURN lv_diff;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;

  END getDailyDiffPerc;

  ---------------------------------------------------------------------------------------------------
  -- Procedure      : getCompanySortOrder
  -- Description    : Populates column COMPANY_SORT_ORDER. Required for the Producer cross-tab columns
  --                  in DV_FCST_SP_DAY_AFS_OVERVIEW
  ---------------------------------------------------------------------------------------------------
  FUNCTION getCpySortOrder(p_forecast_id      IN VARCHAR2,
                           p_object_id        IN VARCHAR2,
                           p_daytime          IN DATE,
                           p_transaction_type IN VARCHAR2,
                           p_company_id       IN VARCHAR2) RETURN NUMBER IS

    ln_tmp        NUMBER := 0;
    lv_sort_order NUMBER := 0;

    CURSOR getCompanies(cp_forecast_id      VARCHAR2,
                        cp_object_id        VARCHAR2,
                        cp_daytime          DATE,
                        cp_transaction_type VARCHAR2) IS
      SELECT cv.object_id, cv.name, cv.sort_order
        FROM fcst_sp_day_cpy_afs a, company_version cv
       WHERE a.company_id = cv.object_id
         AND a.object_id = cp_object_id
         AND a.forecast_id = cp_forecast_id
         AND a.daytime = cp_daytime
         AND a.transaction_type = cp_transaction_type
       ORDER BY cv.name;

  BEGIN

    -- Try to get the SORT_ORDER from COMPANY_VERSION for the company.
    -- If not available, use ln_tmp (which is incremented by 10 for each iteration)
    ln_tmp := 0;
    FOR c_cur IN getCompanies(p_forecast_id,
                              p_object_id,
                              p_daytime,
                              p_transaction_type) LOOP

      ln_tmp        := ln_tmp + 10;
      lv_sort_order := NVL(ROUND(c_cur.sort_order), ln_tmp);

      IF c_cur.object_id = p_company_id THEN
        EXIT;
      END IF;

    END LOOP;

    RETURN lv_sort_order;

  END getCpySortOrder;


  ---------------------------------------------------------------------------------------------------
  -- Procedure      : deleteCompanyAfs
  -- Description    : To delete the child record from FCST_SP_DAY_CPY_AFS when a parent is deleted from FCST_SP_DAY_AFS
  ---------------------------------------------------------------------------------------------------

 PROCEDURE deleteCompanyAfs(p_forecast_id 	VARCHAR2,
						    p_ref_afs_seq 	NUMBER)
 IS
	lv_cnt		NUMBER;
BEGIN

	SELECT count(*) into lv_cnt
	FROM FCST_SP_DAY_CPY_AFS
	WHERE forecast_id = p_forecast_id
	AND  ref_afs_seq = p_ref_afs_seq ;

	IF lv_cnt > 0 THEN
		DELETE FROM FCST_SP_DAY_CPY_AFS
		WHERE forecast_id = p_forecast_id
		AND  ref_afs_seq = p_ref_afs_seq ;
	END IF;

END deleteCompanyAfs;

--<EC-DOC>
--------------------------------------------------------------------------------------------------
-- Procedure      : deleteNomPointCompanyAfs
-- Description    : Procedure deletes the company AFS record from FCST_NOMPNT_DAY_CPY_AFS table.
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : FCST_NOMPNT_DAY_CPY_AFS
--
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--------------------------------------------------------------------------------------------------
PROCEDURE deleteNomPointCompanyAfs(p_forecast_id 	VARCHAR2,
                                   p_ref_afs_seq 	NUMBER)
 IS
	lv_cnt		NUMBER;
BEGIN

	SELECT count(*) into lv_cnt
	FROM FCST_NOMPNT_DAY_CPY_AFS
	WHERE forecast_id = p_forecast_id
	AND  ref_afs_seq = p_ref_afs_seq ;

	IF lv_cnt > 0 THEN
		DELETE FROM FCST_NOMPNT_DAY_CPY_AFS
		WHERE forecast_id = p_forecast_id
		AND  ref_afs_seq = p_ref_afs_seq ;
	END IF;

END deleteNomPointCompanyAfs;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : deleteStrDaySpAfs
-- Description    : To delete the child record from FCST_STRM_DAY_SP_CPY_AFS when a parent is deleted from FCST_STRM_DAY_SP_AFS
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : FCST_STRM_DAY_SP_CPY_AFS, FCST_STRM_DAY_SP_AFS
--
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------

 PROCEDURE deleteStrDaySpAfs(p_class_name        IN VARCHAR2,
                             p_forecast_id       IN VARCHAR2,
                             p_supply_point_id   IN VARCHAR2,
                             p_daytime           IN DATE,
                             p_company_id        IN VARCHAR2 DEFAULT NULL,
                             p_transaction_type  IN VARCHAR2)
 IS
	lv_cnt		NUMBER;
BEGIN

    IF p_class_name = 'FCST_SP_DAY_AFS' THEN
		SELECT count(*)
		INTO lv_cnt
		FROM FCST_STRM_DAY_SP_CPY_AFS
		WHERE forecast_id      = p_forecast_id
		AND   daytime          = p_daytime
		AND   supply_point_id  = p_supply_point_id
		AND   transaction_type = p_transaction_type;

		IF lv_cnt > 0 THEN
			DELETE FROM FCST_STRM_DAY_SP_CPY_AFS
			WHERE forecast_id      = p_forecast_id
			AND   daytime          = p_daytime
			AND   supply_point_id  = p_supply_point_id
			AND   transaction_type = p_transaction_type;
		END IF;

		SELECT count(*)
		INTO lv_cnt
		FROM FCST_STRM_DAY_SP_AFS
		WHERE forecast_id      = p_forecast_id
		AND   daytime          = p_daytime
		AND   supply_point_id  = p_supply_point_id
		AND   transaction_type = p_transaction_type;

		IF lv_cnt > 0 THEN
			DELETE FROM FCST_STRM_DAY_SP_AFS
			WHERE forecast_id      = p_forecast_id
			AND   daytime          = p_daytime
			AND   supply_point_id  = p_supply_point_id
			AND   transaction_type = p_transaction_type;
		END IF;

	ELSIF p_class_name = 'FCST_SP_DAY_CPY_AFS' THEN

		SELECT count(*)
		INTO lv_cnt
		FROM FCST_STRM_DAY_SP_CPY_AFS
		WHERE forecast_id      = p_forecast_id
		AND   daytime          = p_daytime
		AND   supply_point_id  = p_supply_point_id
		AND   transaction_type = p_transaction_type
		AND   company_id       = p_company_id;

		IF lv_cnt > 0 THEN
			DELETE FROM FCST_STRM_DAY_SP_CPY_AFS
			WHERE forecast_id      = p_forecast_id
			AND   daytime          = p_daytime
			AND   supply_point_id  = p_supply_point_id
			AND   transaction_type = p_transaction_type
			AND   company_id       = p_company_id;
		END IF;
	END IF;

END deleteStrDaySpAfs;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : deleteStrDayAfs
-- Description    : To delete the child record from FCST_STRM_DAY_SP_CPY_AFS when a parent is deleted from FCST_STRM_DAY_SP_AFS
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : FCST_STRM_DAY_AFS, FCST_STRM_DAY_CPY_AFS
--
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------

 PROCEDURE deleteStrDayAfs(p_class_name        IN VARCHAR2,
                           p_forecast_id       IN VARCHAR2,
                           p_object_id         IN VARCHAR2,
                           p_daytime           IN DATE,
                           p_company_id        IN VARCHAR2 DEFAULT NULL,
                           p_transaction_type  IN VARCHAR2)
 IS
	lv_cnt		NUMBER;
BEGIN

    IF p_class_name = 'FCST_NOMPNT_DAY_AFS' THEN
		SELECT count(*)
		INTO lv_cnt
		FROM FCST_STRM_DAY_CPY_AFS
		WHERE forecast_id      = p_forecast_id
		AND   daytime          = p_daytime
		AND   transaction_type = p_transaction_type
		AND   object_id in (  select nvl(o.entry_location_id, o.exit_location_id) object_id
							  from NOMPNT_VERSION oa, NOMINATION_POINT o
							  where oa.object_id  =  o.object_id
							  and   o.object_id   =  p_object_id
							  and   oa.daytime    <= p_daytime
							  and   nvl(o.end_date, p_daytime + 1) > p_daytime );

		IF lv_cnt > 0 THEN
			DELETE FROM FCST_STRM_DAY_CPY_AFS
			WHERE forecast_id      = p_forecast_id
			AND   daytime          = p_daytime
			AND   transaction_type = p_transaction_type
            AND   object_id in (  select nvl(o.entry_location_id, o.exit_location_id) object_id
                                  from NOMPNT_VERSION oa, NOMINATION_POINT o
                                  where oa.object_id  =  o.object_id
                                  and   o.object_id   =  p_object_id
                                  and   oa.daytime    <= p_daytime
                                  and   nvl(o.end_date, p_daytime + 1) > p_daytime );
		END IF;

		SELECT count(*)
		INTO lv_cnt
		FROM FCST_STRM_DAY_AFS
		WHERE forecast_id      = p_forecast_id
		AND   daytime          = p_daytime
		AND   transaction_type = p_transaction_type
		AND   object_id in (  select nvl(o.entry_location_id, o.exit_location_id) object_id
							  from NOMPNT_VERSION oa, NOMINATION_POINT o
							  where oa.object_id  =  o.object_id
							  and   o.object_id   =  p_object_id
							  and   oa.daytime    <= p_daytime
							  and   nvl(o.end_date, p_daytime + 1) > p_daytime );

		IF lv_cnt > 0 THEN
			DELETE FROM FCST_STRM_DAY_AFS
			WHERE forecast_id      = p_forecast_id
			AND   daytime          = p_daytime
			AND   transaction_type = p_transaction_type
		    AND   object_id in (  select nvl(o.entry_location_id, o.exit_location_id) object_id
                                  from NOMPNT_VERSION oa, NOMINATION_POINT o
                                  where oa.object_id  =  o.object_id
                                  and   o.object_id   =  p_object_id
                                  and   oa.daytime    <= p_daytime
                                  and   nvl(o.end_date, p_daytime + 1) > p_daytime );
		END IF;

	ELSIF p_class_name = 'FCST_NOMPNT_DAY_CPY_AFS' THEN

		SELECT count(*)
		INTO lv_cnt
		FROM FCST_STRM_DAY_CPY_AFS
		WHERE forecast_id      = p_forecast_id
		AND   daytime          = p_daytime
		AND   transaction_type = p_transaction_type
		AND   company_id       = p_company_id
		AND   object_id in (  select nvl(o.entry_location_id, o.exit_location_id) object_id
							  from NOMPNT_VERSION oa, NOMINATION_POINT o
							  where oa.object_id  =  o.object_id
							  and   o.object_id   =  p_object_id
							  and   oa.daytime    <= p_daytime
							  and   nvl(o.end_date, p_daytime + 1) > p_daytime );

		IF lv_cnt > 0 THEN
			DELETE FROM FCST_STRM_DAY_CPY_AFS
			WHERE forecast_id      = p_forecast_id
			AND   daytime          = p_daytime
			AND   transaction_type = p_transaction_type
			AND   company_id       = p_company_id
            AND   object_id in (  select nvl(o.entry_location_id, o.exit_location_id) object_id
                                  from NOMPNT_VERSION oa, NOMINATION_POINT o
                                  where oa.object_id  =  o.object_id
                                  and   o.object_id   =  p_object_id
                                  and   oa.daytime    <= p_daytime
                                  and   nvl(o.end_date, p_daytime + 1) > p_daytime );
		END IF;
	END IF;

END deleteStrDayAfs;

END ecdp_afs_utility;