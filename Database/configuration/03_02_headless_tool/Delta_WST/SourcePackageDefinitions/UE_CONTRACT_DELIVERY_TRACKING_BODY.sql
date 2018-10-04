CREATE OR REPLACE PACKAGE BODY ue_Contract_Delivery_Tracking IS
/****************************************************************
** Package        :  ue_Contract_Delivery_Tracking; body part
**
** $Revision: 1.6 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created        :
**
** Modification history:
**
** Date       	Whom      	Change description:
** ----------  	--------  	------------------------------------------------------------------------------------------------------------
** 14.01.2013	muhammah	ECPD-20117: Initial - created funtions getPlannedQty, getPlannedPct, getACQToleranceLimit
** 25.01.2013   chooysie    ECPD-20101: Create functions for Contract Delivery Tracking screen: getYtd and getRemaining
** 17.12.2013   chooysie    ECPD-26108: Create functions for Forecast Contract Delivery Tracking screen: getFcstYtd and getFcstRemaining, fix getYtd
								and getRemaining to pass in contract year instead trunc daytime
** 18.12.2013	muhammah	ECPD-26100: Added new functions - getFcstPlannedQty, getPlannedPct. Updated function getPlannedQty on c_contract cursor
								to nvl (grs_vol_nominated, grs_vol_requested) and use the EcDp_Contract.getContractYear to get the contract
** 25.05.2015	farhaann	ECPD-30572: Added new function, getPlannedLiftVol
** 11.01.2016	asareswi	ECPD-33109: Added new function getFcstPlannedCargos,getPlannedCargos : Count the planned no of cargoes for a contract in a forecast
** 11.01.2016	asareswi	ECPD-33109: Added new function getFcstPlannedProdQty, getPlannedProdQty : To calculate the planned production qty based on the selected storage.
** 20.01.2016	thotesan	ECPD-33109: Modified function getFcstPlannedQty for start and end date parameters.
** 29.02.2016	thotesan	ECPD-33109: Modified function getFcstPlannedQty for retriving data against contract_id.
**************************************************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function	      : getAttributeString
-- Description    : The actual qty will supersede the forecast qty
--
-- Preconditions  : The Lifting accounts must be configured with a contract.
-- Postconditions :
--
-- Using tables   : storage_lift_nomination
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getPlannedQty (p_contract_id VARCHAR2,
							 p_daytime DATE,
							 p_xtra_qty NUMBER DEFAULT 0)
RETURN NUMBER
--</EC-DOC>

IS
--cursor
  CURSOR c_contract(cp_contract_id VARCHAR2, cp_from_date DATE, cp_to_date DATE, cp_xtra_qty NUMBER) IS
    SELECT SUM(lifted_qty) lifted_qty
    FROM (select
			nvl(ecbp_storage_lift_nomination.getLiftedVolByIncoterm(s.parcel_no, cp_xtra_qty),
				nvl(decode(cp_xtra_qty,0,s.grs_vol_nominated, 1,s.grs_vol_nominated2, 2, s.grs_vol_nominated3),
					decode(cp_xtra_qty,0,s.GRS_VOL_REQUESTED, 1,s.GRS_VOL_REQUESTED2, 2, s.GRS_VOL_REQUESTED3)))
		lifted_qty
         from storage_lift_nomination s
         where s.contract_id=cp_contract_id
         AND nvl(s.bl_date, s.nom_firm_date) >= cp_from_date
         AND nvl(s.bl_date, s.nom_firm_date) <= cp_to_date) a;

  ld_from_date  DATE;
  ld_to_date    DATE;
  ln_lifted_qty NUMBER := 0;

BEGIN

  ld_from_date := EcDp_Contract.getContractYearStartDate(p_contract_id,  EcDp_Contract.getContractYear(p_contract_id,p_daytime));
  ld_to_date := EcDp_Contract.getContractYearStartDate(p_contract_id, add_months (EcDp_Contract.getContractYear(p_contract_id,p_daytime),12));

    FOR curContract IN c_contract(p_contract_id, ld_from_date, ld_to_date, p_xtra_qty) LOOP
      IF curContract.lifted_qty IS NULL THEN
        curContract.lifted_qty := 0;
      END IF;
      ln_lifted_qty := curContract.lifted_qty;
    END LOOP;

RETURN ln_lifted_qty;

END getPlannedQty;

--<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function       : getPlannedPct
  -- Description    : Returns the lifted volume for a parcel based on whether the lifting is FOB or CIF/DES.
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
  FUNCTION getPlannedPct (p_contract_id VARCHAR2,
							p_daytime DATE,
							p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER
  --</EC-DOC>
   IS

  lnLiftedPct		NUMBER;
	lnPlannedQty 	NUMBER := 0;
	lnACCQ 			NUMBER := 0;

  BEGIN

	lnPlannedQty := getPlannedQty(p_contract_id, p_daytime, p_xtra_qty);
	lnACCQ := Nvl(ec_contract_attribute.attribute_number(p_contract_id, 'AACQ',p_daytime, '<='), 0);

  IF (lnPlannedQty IS NULL OR lnPlannedQty = 0) OR (lnACCQ IS NULL OR lnACCQ = 0) THEN
    lnLiftedPct := 0;
  ELSE
    lnLiftedPct:= lnPlannedQty/lnACCQ * 100;
  END IF;

	RETURN lnLiftedPct;

 END getPlannedPct ;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getACQToleranceLimit
-- Description    : Checks if the planned percentage exceeds the tolerance limit
--
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
    FUNCTION getACQToleranceLimit(p_plannedPct NUMBER, p_tolPct NUMBER) RETURN VARCHAR2
    --</EC-DOC>
     IS

        ld_msg    VARCHAR2(200);
        ld_msgTxt VARCHAR2(200);

    BEGIN
        IF p_plannedPct =0 AND p_tolPct = 0 THEN
          RETURN NULL;
        ELSE
          IF p_plannedPct NOT BETWEEN (100 - p_tolPct) AND (100 + p_tolPct) THEN
              ld_msg := 'verificationStatus=showStopper;';
              ld_msgTxt := 'verificationText=Tolerance Limit Exceeded';
          END IF;

          IF ld_msgTxt IS NOT NULL THEN
              RETURN ld_msg || ld_msgTxt;
          ELSE
              RETURN NULL;
          END IF;
        END IF;

    END getACQToleranceLimit;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function	      : getYtd
-- Description    :This function shall return the YTD planned/delivered quantity for a contract and contract year
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
FUNCTION getYtd (p_contract_id VARCHAR2,
							 p_daytime DATE,
							 p_xtra_qty NUMBER DEFAULT 0)
RETURN NUMBER
--</EC-DOC>

IS
--cursor
  CURSOR c_contract(cp_contract_id VARCHAR2, cp_from_date DATE, cp_to_date DATE, cp_xtra_qty NUMBER) IS
    SELECT SUM(lifted_qty) lifted_qty
    FROM (select nvl(ecbp_storage_lift_nomination.getLiftedVolByIncoterm(s.parcel_no, cp_xtra_qty),
         decode(cp_xtra_qty,0,s.grs_vol_nominated, 1,s.grs_vol_nominated2, 2, s.grs_vol_nominated3)) lifted_qty
         from storage_lift_nomination s
         where s.contract_id=cp_contract_id
         AND nvl(s.bl_date, s.nom_firm_date) >= cp_from_date
         AND nvl(s.bl_date, s.nom_firm_date) <= cp_to_date) a;

  ld_from_date  DATE;
  ln_lifted_qty NUMBER := 0;

BEGIN
  ld_from_date := EcDp_Contract.getContractYearStartDate(p_contract_id, EcDp_Contract.getContractYear(p_contract_id,p_daytime));

    FOR curContract IN c_contract(p_contract_id , ld_from_date, p_daytime, p_xtra_qty) LOOP
      IF curContract.lifted_qty IS NULL THEN
        curContract.lifted_qty := 0;
      END IF;
      ln_lifted_qty := curContract.lifted_qty;
    END LOOP;

RETURN ln_lifted_qty;

END getYtd;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function	      : getRemaining
-- Description    :This function shall return the YTD planned/delivered quantity for a contract and contract year
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
FUNCTION getRemaining (p_contract_id VARCHAR2,
							 p_daytime DATE,
							 p_xtra_qty NUMBER DEFAULT 0)
RETURN NUMBER
--</EC-DOC>

IS
--cursor
  ln_AACQ NUMBER := 0;
  ln_lifted_qty NUMBER := 0;
  ln_remaining NUMBER :=0;
BEGIN

  IF p_xtra_qty=1 THEN
    ln_AACQ := ec_contract_attribute.attribute_number(p_contract_id, 'AACQ_2', EcDp_Contract.getContractYear(p_contract_id,p_daytime), '<=');
  ELSIF p_xtra_qty=2 THEN
    ln_AACQ := ec_contract_attribute.attribute_number(p_contract_id, 'AACQ_3', EcDp_Contract.getContractYear(p_contract_id,p_daytime), '<=');
  ELSE
    ln_AACQ := ec_contract_attribute.attribute_number(p_contract_id, 'AACQ', EcDp_Contract.getContractYear(p_contract_id,p_daytime), '<=');
  END IF;

  ln_lifted_qty := getYtd(p_contract_id, p_daytime, p_xtra_qty);
  ln_remaining := ln_AACQ-ln_lifted_qty;

RETURN ln_remaining;

END getRemaining;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function	      : getFcstYtd
-- Description    :This function shall return the forecast YTD planned/delivered quantity for a contract and contract year
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
FUNCTION getFcstYtd (p_contract_id VARCHAR2,
  						 p_forecast_id VARCHAR2,
							 p_daytime DATE,
							 p_xtra_qty NUMBER DEFAULT 0)
RETURN NUMBER
--</EC-DOC>

IS
--cursor
  CURSOR c_contract(cp_contract_id VARCHAR2, cp_forecast_id VARCHAR2, cp_from_date DATE, cp_to_date DATE, cp_xtra_qty NUMBER) IS
    SELECT SUM(lifted_qty) lifted_qty
    FROM (select nvl(ecbp_stor_fcst_lift_nom.getLiftedVolByIncoterm(s.parcel_no, s.forecast_id, cp_xtra_qty),
         decode(cp_xtra_qty,0,s.grs_vol_nominated, 1,s.grs_vol_nominated2, 2, s.grs_vol_nominated3)) lifted_qty
         from stor_fcst_lift_nom s
         where s.contract_id=cp_contract_id
         AND s.forecast_id = cp_forecast_id
         AND nvl(s.bl_date, s.nom_firm_date) >= cp_from_date
         AND nvl(s.bl_date, s.nom_firm_date) <= cp_to_date) a;

  ld_from_date  DATE;
  ln_lifted_qty NUMBER := 0;

BEGIN
  ld_from_date := EcDp_Contract.getContractYearStartDate(p_contract_id, EcDp_Contract.getContractYear(p_contract_id,p_daytime));

    FOR curContract IN c_contract(p_contract_id, p_forecast_id, ld_from_date, p_daytime, p_xtra_qty) LOOP
      IF curContract.lifted_qty IS NULL THEN
        curContract.lifted_qty := 0;
      END IF;
      ln_lifted_qty := curContract.lifted_qty;
    END LOOP;

RETURN ln_lifted_qty;

END getFcstYtd;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function	      : getFcstRemaining
-- Description    :This function shall return the forecast YTD planned/delivered quantity for a contract and contract year
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
FUNCTION getFcstRemaining (p_contract_id VARCHAR2,
  						 p_forecast_id VARCHAR2,
							 p_daytime DATE,
							 p_xtra_qty NUMBER DEFAULT 0)
RETURN NUMBER
--</EC-DOC>

IS
--cursor
  ln_AACQ NUMBER := 0;
  ln_lifted_qty NUMBER := 0;
  ln_remaining NUMBER :=0;
BEGIN

  IF p_xtra_qty=1 THEN
    ln_AACQ := ec_contract_attribute.attribute_number(p_contract_id, 'AACQ_2', EcDp_Contract.getContractYear(p_contract_id,p_daytime), '<=');
  ELSIF p_xtra_qty=2 THEN
    ln_AACQ := ec_contract_attribute.attribute_number(p_contract_id, 'AACQ_3', EcDp_Contract.getContractYear(p_contract_id,p_daytime), '<=');
  ELSE
    ln_AACQ := ec_contract_attribute.attribute_number(p_contract_id, 'AACQ', EcDp_Contract.getContractYear(p_contract_id,p_daytime), '<=');
  END IF;

  ln_lifted_qty := getFcstYtd(p_contract_id, p_forecast_id, p_daytime, p_xtra_qty);
  ln_remaining := ln_AACQ-ln_lifted_qty;

RETURN ln_remaining;

END getFcstRemaining;

---------------------------------------------------------------------------------------------------
-- Function	      : getFcstPlannedQty
-- Description    : Get Planned deliveries for a contract in a forecast. (ADP planning)

--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : STOR_FCST_LIFT_NOM
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getFcstPlannedQty(p_forecast_id VARCHAR2,
                           p_contract_id VARCHAR2,
                           p_daytime     DATE,
                           p_xtra_qty    NUMBER DEFAULT 0) RETURN NUMBER
--</EC-DOC>

 IS
  --cursor
  CURSOR c_contract(cp_forecast_id VARCHAR2, cp_contract_id VARCHAR2, cp_from_date DATE, cp_to_date DATE, cp_xtra_qty NUMBER) IS
     SELECT SUM(planned_qty) planned_qty
	       FROM (select nvl(EcBP_Stor_Fcst_Lift_Nom.getLiftedVolByIncoterm(s.parcel_no, cp_forecast_id, cp_xtra_qty),
              nvl(decode(cp_xtra_qty,0,s.grs_vol_nominated, 1,s.grs_vol_nominated2, 2, s.grs_vol_nominated3),
                  decode(cp_xtra_qty,0,s.GRS_VOL_REQUESTED, 1,s.GRS_VOL_REQUESTED2, 2, s.GRS_VOL_REQUESTED3)))
	             planned_qty
     from STOR_FCST_LIFT_NOM s, LIFT_ACCOUNT_VERSION la
       where (s.object_id = cp_contract_id OR la.contract_id = cp_contract_id)
	   AND s.forecast_id = cp_forecast_id
	   AND s.lifting_account_id = la.object_id
       AND nvl(s.bl_date, s.nom_firm_date) >= cp_from_date
       AND nvl(s.bl_date, s.nom_firm_date) <= cp_to_date
	   AND nvl(s.DELETED_IND, 'N') <> 'Y');

  ld_from_date   DATE;
  ld_to_date     DATE;
  ln_planned_qty NUMBER := 0;

BEGIN

  --ld_from_date := EcDp_Contract.getContractYearStartDate(p_contract_id,  EcDp_Contract.getContractYear(p_contract_id,p_daytime));
  --ld_to_date := EcDp_Contract.getContractYearStartDate(p_contract_id, add_months (EcDp_Contract.getContractYear(p_contract_id,p_daytime),12));
	ld_from_date	:= TRUNC(p_daytime, 'YYYY');
	ld_to_date 		:= add_months (ld_from_date,12);

  FOR curContract IN c_contract(p_forecast_id, p_contract_id, ld_from_date, ld_to_date, p_xtra_qty) LOOP
    IF curContract.planned_qty IS NULL THEN
      curContract.planned_qty := 0;
    END IF;
    ln_planned_qty := curContract.planned_qty;
  END LOOP;

  RETURN ln_planned_qty;

END getFcstPlannedQty;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getFcstPlannedPct
-- Description    : Returns planned qty as a percentage of ACQ

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
FUNCTION getFcstPlannedPct(p_forecast_id VARCHAR2,
                           p_contract_id VARCHAR2,
                           p_daytime     DATE,
                           p_xtra_qty    NUMBER DEFAULT 0) RETURN NUMBER
--</EC-DOC>
 IS

  lnPlannedPct NUMBER;
  lnPlannedQty NUMBER := 0;
  lnACCQ       NUMBER := 0;

BEGIN

  lnPlannedQty := getFcstPlannedQty(p_forecast_id,
                                    p_contract_id,
                                    p_daytime,
                                    p_xtra_qty);
  lnACCQ       := Nvl(ec_contract_attribute.attribute_number(p_contract_id,
                                                             'AACQ',
                                                             p_daytime,
                                                             '<='),
                      0);

  IF (lnPlannedQty IS NULL OR lnPlannedQty = 0) OR
     (lnACCQ IS NULL OR lnACCQ = 0) THEN
    lnPlannedPct := 0;
  ELSE
    lnPlannedPct := lnPlannedQty / lnACCQ * 100;
  END IF;

  RETURN lnPlannedPct;

END getFcstPlannedPct;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getPlannedLiftVol
-- Description    : Calculated by summing up all planned liftings with terminal offtake inside the current ADP year.
--                  This is from the perspective of the relationship between the lifter and the operator,
--                  so individual SPA delivery dates (that in certain scenarios - e.g. DES shipments occurring late in the ADP year
--                  can fall outside of the current ADP year) are not considered in this BF.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :storage_lift_nomination, lifting_account, cargo_transport
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getPlannedLiftVol(p_daytime            DATE,
                           p_lifting_account_id VARCHAR2,
                           p_profit_centre_id   VARCHAR2,
                           p_storage_id         VARCHAR2)
--</EC-DOC>
 RETURN NUMBER IS

  CURSOR c_sum_liftings(cp_lifting_account_id VARCHAR2,
                        cp_storage_id         VARCHAR2,
                        cp_profit_centre_id   VARCHAR2,
                        cp_from_date          DATE,
                        cp_to_date            DATE,
                        cp_xtra_qty           NUMBER DEFAULT 0) IS
    SELECT SUM(lifted_qty) lifted_qty
      FROM (select nvl(ecbp_storage_lift_nomination.getLiftedVol(s.parcel_no,cp_xtra_qty),
                       nvl(decode(cp_xtra_qty,0,s.grs_vol_nominated,1,s.grs_vol_nominated2,2,s.grs_vol_nominated3),
                           decode(cp_xtra_qty,0,s.GRS_VOL_REQUESTED,1,s.GRS_VOL_REQUESTED2,2,s.GRS_VOL_REQUESTED3))) lifted_qty
              from storage_lift_nomination s,
                   lifting_account         la,
                   cargo_transport         c,
				   cargo_status_mapping csm
             where s.object_id = la.storage_id
               and s.object_id = cp_storage_id
               and s.lifting_account_id = la.object_id
               and s.lifting_account_id = cp_lifting_account_id
               and la.profit_centre_id = cp_profit_centre_id
               and c.cargo_no = s.cargo_no
               and csm.cargo_status = c.cargo_status
			   and csm.ec_cargo_status <> 'D'
               and nvl(s.bl_date, s.nom_firm_date) >= cp_from_date
               and nvl(s.bl_date, s.nom_firm_date) <= cp_to_date) a;

  ln_lifted_qty NUMBER;
  ld_to_date    DATE;

BEGIN

  ld_to_date := add_months(p_daytime, 1) - 1;
  FOR curSumLift IN c_sum_liftings(p_lifting_account_id,
                                   p_storage_id,
                                   p_profit_centre_id,
                                   p_daytime,
                                   ld_to_date) LOOP
    IF curSumLift.lifted_qty IS NULL THEN
      curSumLift.lifted_qty := 0;
    END IF;
    ln_lifted_qty := curSumLift.lifted_qty;
  END LOOP;

  RETURN ln_lifted_qty;

END getPlannedLiftVol;


---------------------------------------------------------------------------------------------------
-- Function	      : getFcstPlannedCargos
-- Description    : Get total number of planned cargoes for a contract in a forecast.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : STOR_FCST_LIFT_NOM
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getFcstPlannedCargos(p_forecast_id VARCHAR2,
							p_contract_id VARCHAR2,
							p_daytime     DATE) RETURN NUMBER
--</EC-DOC>

 IS
	--cursor
	CURSOR c_contract(cp_forecast_id VARCHAR2, cp_contract_id VARCHAR2, cp_from_date DATE, cp_to_date DATE) IS
	 SELECT COUNT(parcel_no) cargo_cnt
		   FROM (select parcel_no
	 from STOR_FCST_LIFT_NOM s, LIFT_ACCOUNT_VERSION la
	   where (s.object_id = cp_contract_id OR la.contract_id = cp_contract_id)
	   AND s.forecast_id = cp_forecast_id
	   AND s.lifting_account_id = la.object_id
	   AND nvl(s.bl_date, s.nom_firm_date) >= cp_from_date
	   AND nvl(s.bl_date, s.nom_firm_date) < cp_to_date
	   AND nvl(s.DELETED_IND, 'N') <> 'Y');


	ld_from_date   		DATE;
	ld_to_date     		DATE;
	ld_fcst_start_date 	DATE;
	ld_fcst_end_date   	DATE;
	ln_cargo_cnt 		NUMBER := 0;

BEGIN

	ld_from_date	:= TRUNC(p_daytime, 'YYYY');
	ld_to_date 		:= add_months (ld_from_date,12);

	SELECT start_date, end_date
	INTO ld_fcst_start_date, ld_fcst_end_date
	FROM forecast
	WHERE object_id = p_forecast_id;

	FOR curContract IN c_contract(p_forecast_id, p_contract_id, ld_from_date, ld_to_date) LOOP
		ln_cargo_cnt := NVL(curContract.cargo_cnt, 0);
	END LOOP;

	IF ld_from_date < ld_fcst_start_date THEN
		ln_cargo_cnt := NVL(ln_cargo_cnt, 0) + getPlannedCargos (p_contract_id, ld_from_date, ld_fcst_start_date);
	END IF;

	IF ld_fcst_end_date < ld_to_date THEN
		ln_cargo_cnt := NVL(ln_cargo_cnt, 0) + getPlannedCargos (p_contract_id, ld_fcst_end_date, ld_to_date);
	END IF;

  RETURN ln_cargo_cnt;

END getFcstPlannedCargos;

---------------------------------------------------------------------------------------------------
-- Function	      : getPlannedCargos
-- Description    : The actual qty will supersede the forecast qty
--
-- Preconditions  : The Lifting accounts must be configured with a contract.
-- Postconditions :
--
-- Using tables   : storage_lift_nomination
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getPlannedCargos (p_contract_id VARCHAR2,
							p_daytime DATE,
							p_to_date DATE DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>

IS
--cursor
	CURSOR c_contract(cp_contract_id VARCHAR2, cp_from_date DATE, cp_to_date DATE) IS
	SELECT COUNT(parcel_no) lifted_cnt
	FROM (select parcel_no
		 from storage_lift_nomination s, LIFT_ACCOUNT_VERSION la
		 where (s.object_id=cp_contract_id OR la.contract_id = cp_contract_id)
		 AND la.object_id = s.lifting_account_id
		 AND nvl(s.bl_date, s.nom_firm_date) >= cp_from_date
		 AND nvl(s.bl_date, s.nom_firm_date) < cp_to_date) a;


	ld_from_date  DATE;
	ld_to_date    DATE;
	ln_planned_cnt NUMBER := 0;

BEGIN

	IF p_to_date IS NULL THEN
		ld_from_date := EcDp_Contract.getContractYearStartDate(p_contract_id,  EcDp_Contract.getContractYear(p_contract_id,p_daytime));
		ld_to_date 	:= EcDp_Contract.getContractYearStartDate(p_contract_id, add_months (EcDp_Contract.getContractYear(p_contract_id,p_daytime),12));
	ELSE
		ld_from_date := p_daytime;
		ld_to_date := p_to_date;
	END IF;

	FOR curContract IN c_contract(p_contract_id, ld_from_date, ld_to_date) LOOP
		IF curContract.lifted_cnt IS NULL THEN
			curContract.lifted_cnt := 0;
		END IF;
		ln_planned_cnt := curContract.lifted_cnt;
	END LOOP;

	RETURN ln_planned_cnt;

END getPlannedCargos;


---------------------------------------------------------------------------------------------------
-- Function	      : getFcstPlannedProdQty
-- Description    : Get total number of cargoes for a given storage.

--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : STOR_DAY_FCST_FCAST
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
  FUNCTION getFcstPlannedProdQty(p_forecast_id VARCHAR2,
								 p_storage_id VARCHAR2,
								 p_daytime     DATE)
	RETURN NUMBER
  --</EC-DOC>
    IS

	--cursor
	CURSOR c_contract(cp_forecast_id VARCHAR2,
					cp_storage_id  VARCHAR2,
					cp_from_date   DATE,
					cp_to_date     DATE) IS
	SELECT nvl(SUM(forecast_qty), 0) forecast_qty
	  FROM stor_day_fcst_fcast f
	 WHERE f.forecast_id = cp_forecast_id
	   AND f.object_id = cp_storage_id
	   AND f.daytime >= cp_from_date
	   AND f.daytime < cp_to_date;

    ld_from_date 			DATE;
    ld_to_date   			DATE;
	ld_fcst_start_date   	DATE;
	ld_fcst_end_date     	DATE;
	ln_planned_qty 			NUMBER := 0;

  BEGIN

	ld_from_date := TRUNC(p_daytime, 'YYYY');
	ld_to_date := add_months (ld_from_date,12);

	SELECT start_date, end_date
	INTO ld_fcst_start_date, ld_fcst_end_date
	FROM forecast
	WHERE object_id = p_forecast_id;

	FOR curContract IN c_contract(p_forecast_id, p_storage_id, ld_from_date, ld_to_date) LOOP
		ln_planned_qty := curContract.forecast_qty;
	END LOOP;

	IF ld_from_date < ld_fcst_start_date THEN
		ln_planned_qty := ln_planned_qty + getPlannedProdQty (p_storage_id, ld_from_date, ld_fcst_start_date);
	END IF;

	IF ld_fcst_end_date < ld_to_date THEN
		ln_planned_qty := ln_planned_qty + getPlannedProdQty (p_storage_id, ld_fcst_end_date, ld_to_date);
	END IF;

	RETURN ln_planned_qty;

  END getFcstPlannedProdQty;


 ---------------------------------------------------------------------------------------------------
-- Function	      : getPlannedProdQty
-- Description    : Get total number of cargoes for a given storage.

--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : STOR_DAY_FORECAST
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

FUNCTION getPlannedProdQty(p_storage_id VARCHAR2,
                           p_daytime    DATE,
                           p_to_date    DATE DEFAULT NULL) RETURN NUMBER
--</EC-DOC>

 IS
  --cursor
  CURSOR c_contract(cp_storage_id VARCHAR2,
                    cp_from_date  DATE,
                    cp_to_date    DATE) IS
    SELECT nvl(SUM(forecast_qty), 0) forecast_qty
      FROM stor_day_forecast f
     WHERE f.object_id = p_storage_id
       AND f.daytime >= cp_from_date
       AND f.daytime < cp_to_date;

  ld_from_date   DATE;
  ld_to_date     DATE;
  ln_planned_qty NUMBER := 0;

BEGIN

  IF p_to_date IS NULL THEN
    ld_from_date := TRUNC(p_daytime, 'YYYY');
    ld_to_date   := add_months(ld_from_date, 12);
  ELSE
    ld_from_date := p_daytime;
    ld_to_date   := p_to_date;
  END IF;

  FOR curContract IN c_contract(p_storage_id, ld_from_date, ld_to_date) LOOP
    ln_planned_qty := curContract.forecast_qty;
  END LOOP;

  RETURN ln_planned_qty;

END getPlannedProdQty;

END ue_Contract_Delivery_Tracking;