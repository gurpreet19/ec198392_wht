CREATE OR REPLACE PACKAGE BODY ue_Contract_Delivery_Tracking IS
/****************************************************************
** Package        :  ue_Contract_Delivery_Tracking; body part
**
** $Revision: 1.1.2.5 $
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
** 15.01.2013	muhammah	ECPD-23097: Initial - created functions getPlannedQty, getPlannedPct, getACQToleranceLimit
** 25.01.2013   chooysie    ECPD-20101: Create functions for Contract Delivery Tracking screen: getYtd and getRemaining
** 18.12.2013   chooysie    ECPD-26349: Create functions for Forecast Contract Delivery Tracking screen: getFcstYtd and getFcstRemaining, fix getYtd and getRemaining to pass in contract year instead trunc daytime
** 23.12.2013	muhammah	ECPD-26389: Added new functions - getFcstPlannedQty, getPlannedPct. Updated function getPlannedQty on c_contract cursor
								to nvl (grs_vol_nominated, grs_vol_requested) and use the EcDp_Contract.getContractYear to get the contract year
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
     from STOR_FCST_LIFT_NOM s
       where s.contract_id = cp_contract_id
	   AND s.forecast_id = cp_forecast_id
       AND nvl(s.bl_date, s.nom_firm_date) >= cp_from_date
       AND nvl(s.bl_date, s.nom_firm_date) <= cp_to_date);

  ld_from_date   DATE;
  ld_to_date     DATE;
  ln_planned_qty NUMBER := 0;

BEGIN

  ld_from_date := EcDp_Contract.getContractYearStartDate(p_contract_id,  EcDp_Contract.getContractYear(p_contract_id,p_daytime));
  ld_to_date := EcDp_Contract.getContractYearStartDate(p_contract_id, add_months (EcDp_Contract.getContractYear(p_contract_id,p_daytime),12));

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

END ue_Contract_Delivery_Tracking;