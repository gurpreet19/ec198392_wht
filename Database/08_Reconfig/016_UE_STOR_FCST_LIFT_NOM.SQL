CREATE OR REPLACE PACKAGE ue_Stor_Fcst_Lift_Nom IS

/******************************************************************************
** Package        :  ue_Stor_Fcst_Lift_Nom, header part
**
** $Revision: 1.3 $
**
** Purpose        :  Includes user-exit functionality for terminal operation screens
**
** Documentation  :  www.energy-components.com
**
** Created  : 05.06.2008 Kari Sandvik
**
** Modification history:
**
** Date        	Whom     	Change description:
** -------     	------   	-----------------------------------------------
** 24.01.2013  	meisihil	ECPD-20962: Added functions aggrSubDayLifting, calcSubDayLifting to support liftings spread over hours
** 15.10.2015	muhammah	ECPD-32356: Merged ECPD-31725. Added function getCalendarDetail, getCalendarTooltip
** 15.01.2016	asareswi	ECPD-33109: Added function getCalendarTooltipFcstMngr to get the detail tooltip based on berth id and lifting a/c id.
** 04.02.2016   sharawan    ECPD-33109: Added new function getChartTooltip for Cargo Berth Chart tooltip
** 01.03.2016   farhaann    ECPD-33934: Added new procedure undoCargo
** 04.03.2016   sharawan    ECPD-33109: Added new function getChartDetailCode for Cargo Berth Chart
** 14.03.2016   sharawan    ECPD-34277: Fix tooltip for Berth gantt chart
** 21.04.2016   farhaann    ECPD-34750: Modified procedure undoCargo - added parameter for forecast
** 21.04.2016   farhaann    ECPD-34750: Added new function getVerificationText
** 25.04.2016   thotesan    ECPD-34226: Modified getChartDetailCode,getChartTooltip to remove parameter to handle daily and subdaily
** 28.04.2016   thotesan    ECPD-34226: Modified getChartTooltip for parameter to handle daily and subdaily
** 08.03.2017   farhaann    ECPD-40982: Added getDefaultSplit, validateSplit and calcSplitQty
** 15.03.2017   farhaann    ECPD-40982: Added createUpdateSplit
** 27.03.2017   farhaaan    ECPD-44120: Added function getSubDaySplitQty and calcAggrSubDaySplitQty
** 20.10.2017   sharawan    ECPD-49488: Added function getCarrierDetailCode, getCarrierTooltip, getCarrierUtilisation for the Carrier Utilization Chart in Forecast Manager.
** 31.10.2017   xxwaghmp    ECPD-49488: Modified function getCarrierDetailCode, getCarrierTooltip to add port_id in where clause
** 09.04.2018   royyypur    ECPD-53946: Added getTextColor to configure the custom color for any date
** -------      ------      ----------------------------------------------------------------------------------------------------
*/

PROCEDURE deleteNomination(p_storage_id VARCHAR2,p_forecast_id VARCHAR2,p_from_date DATE,p_to_date DATE);

PROCEDURE setBalanceDelta(p_forecast_id VARCHAR2, p_parcel_no NUMBER);

FUNCTION aggrSubDayLifting(p_forecast_id VARCHAR2, p_parcel_no NUMBER, p_daytime DATE, p_column VARCHAR2 DEFAULT NULL, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;

PROCEDURE calcSubDayLifting(p_forecast_id VARCHAR2, p_parcel_no NUMBER);

FUNCTION getCalendarDetail(p_daytime DATE, p_berth_id VARCHAR2, p_forecast_id VARCHAR2) RETURN VARCHAR2;

FUNCTION getCalendarTooltip(p_daytime DATE, p_berth_id VARCHAR2, p_forecast_id VARCHAR2) RETURN VARCHAR2;

FUNCTION getCalendarTooltipFcstMngr(p_daytime DATE, p_berth_id VARCHAR2, p_forecast_id VARCHAR2, p_lifting_account_id VARCHAR2) RETURN VARCHAR2;

FUNCTION getChartDetailCode(p_daytime DATE,
                            p_berth_id VARCHAR2,
                            p_storage_id VARCHAR2,
                            p_forecast_id VARCHAR2,
                            p_type VARCHAR2 DEFAULT 'DAY') RETURN VARCHAR2;

FUNCTION getChartTooltip(p_daytime DATE,
                         p_berth_id VARCHAR2,
                         p_storage_id VARCHAR2,
                         p_forecast_id VARCHAR2,
                         p_detail_code VARCHAR2,
                         p_type VARCHAR2 DEFAULT 'DAY') RETURN VARCHAR2;

PROCEDURE undoCargo(p_daytime DATE, p_storage_id VARCHAR2, p_forecast_id_1 VARCHAR2 DEFAULT NULL, p_forecast_id_2 VARCHAR2 DEFAULT NULL);

FUNCTION getVerificationText (p_att_name VARCHAR2) RETURN VARCHAR2;

PROCEDURE getDefaultSplit(p_forecast_id VARCHAR2, p_parcel_no NUMBER);

PROCEDURE validateSplit(p_forecast_id VARCHAR2, p_parcel_no NUMBER);

FUNCTION calcSplitQty(p_forecast_id VARCHAR2, p_parcel_no NUMBER, p_company_id VARCHAR2, p_lifting_account_id VARCHAR2, p_daytime DATE, p_qty NUMBER) RETURN NUMBER;

PROCEDURE createUpdateSplit(p_forecast_id VARCHAR2, p_parcel_no NUMBER, p_old_lifting_account_id VARCHAR2, p_new_lifting_account_id VARCHAR2);

FUNCTION getSubDaySplitQty(p_forecast_id VARCHAR2, p_parcel_no NUMBER, p_company_id VARCHAR2, p_lifting_account_id VARCHAR2, p_daytime DATE, p_qty NUMBER, p_column VARCHAR2 DEFAULT NULL) RETURN NUMBER;

FUNCTION calcAggrSubDaySplitQty(p_forecast_id VARCHAR2, p_parcel_no NUMBER, p_company_id VARCHAR2, p_lifting_account_id VARCHAR2, p_daytime DATE, p_column VARCHAR2 DEFAULT NULL, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;

FUNCTION getCarrierUtilisation(p_forecast_id varchar2, p_from_date date, p_to_date date, p_carrier_id varchar2)
    RETURN number;

FUNCTION getCarrierDetailCode(p_carrier_id VARCHAR2,
                            p_forecast_id VARCHAR2,
                            p_product_group VARCHAR2,
							p_daytime DATE) RETURN VARCHAR2;

 FUNCTION getCarrierTooltip(p_daytime DATE,
                         p_carrier_id VARCHAR2,
                         p_product_group VARCHAR2,
                         p_forecast_id VARCHAR2,
                         p_detail_code VARCHAR2) RETURN VARCHAR2;

PROCEDURE validateSplitEntry(p_company_id VARCHAR2, p_parcel_no NUMBER,p_lifting_account_id VARCHAR2,p_forecast_id VARCHAR2);

FUNCTION getTextColor(p_daytime DATE,p_berth_id VARCHAR2, p_forecast_id VARCHAR2) RETURN VARCHAR2;

END ue_Stor_Fcst_Lift_Nom;
/


CREATE OR REPLACE PACKAGE BODY ue_Stor_Fcst_Lift_Nom IS
/******************************************************************************
** Package        :  ue_Stor_Fcst_Lift_Nom, body part
**
** $Revision: 1.3 $
**
** Purpose        :  Includes user-exit functionality for terminal operation screens
**
** Documentation  :  www.energy-components.com
**
** Created  : 05.06.2008 Kari Sandvik
**
** Modification history:
**
** Version  Date     	Whom  		Change description:
** -------  ------   	----- 		-----------------------------------------------------------------------------------------------
** 			24.01.2013	meisihil  	ECPD-20962: Added functions aggrSubDayLifting, calcSubDayLifting to support liftings spread over hours
** 			15.10.2015	muhammah	ECPD-32356: Merged ECPD-31725. Added function getCalendarDetail, getCalendarTooltip
** 			26.10.2015	thotesan	ECPD-32467: Modified cursor in function getCalendarDetail, getCalendarTooltip to include missing where condition for forecast_id.
** 			15.01.2016	asareswi	ECPD-33109: Added function getCalendarTooltipFcstMngr to get the detail tooltip based on berth id and lifting a/c id.
**          04.02.2016  sharawan    ECPD-33109: Added new function getChartTooltip for Cargo Berth Chart tooltip
**          01.03.2016  farhaann    ECPD-33934: Added new procedure undoCargo
**          04.03.2016  sharawan    ECPD-33109: Added new function getChartDetailCode for Cargo Berth Chart
**          14.03.2016  sharawan    ECPD-34277: Fix tooltip for Berth gantt chart
**          19.04.2016  sharawan    ECPD-34403: Fix RESTRICTION and OCCUPIED cargo on same date to show CONFLICT
** 			21.04.2016  farhaann    ECPD-34750: Modified procedure undoCargo - added parameter for forecast
** 			21.04.2016  farhaann    ECPD-34750: Added new function getVerificationText
**          25.04.2016  thotesan    ECPD-34226: Modified getChartDetailCode,getChartTooltip to remove parameter to handle daily and subdaily
**          28.04.2016  thotesan    ECPD-34226: Modified getChartTooltip for parameter to handle daily and subdaily
**          05.10.2016  baratmah    ECPD-36184: Replaced table name STORAGE_BERTH by STORAGE_PORT_RESOURCE and its related column in getChartTooltip procedure
**			27.10.2016	sharawan	ECPD-39295: Modify getChartDetailCode and getChartTooltip to enable Opportunity viewable in Gantt chart.
**												Add private function getOpportunityName.
**      	07.12.2016  sharawan  	ECPD-41698: Modify getChartDetailCode and getChartTooltip to fix null exception caused by group by function
**                             					when including Opportunity.
**          09.01.2017  thotesan    ECPD-42447: Modified getChartDetailCode,getChartTooltip subdaily cursors to filter on forecast_id and storage_id.
**          08.03.2017  farhaann    ECPD-40982: Added getDefaultSplit, validateSplit and calcSplitQty
**          15.03.2017  farhaann    ECPD-40982: Added createUpdateSplit
**          24.03.2017  sharawan    ECPD-42257: Modified subDaily cursor in getChartDetailCode and getChartTooltip to check for the daily table nom_firm_date
**                                              instead of sub daily table daytime, fixing the null pointer exception
**          27.03.2017  farhaaan    ECPD-44120: Added function getSubDaySplitQty and calcAggrSubDaySplitQty
**          30.03.2017  sharawan    ECPD-42257: Modified subDaily cursor in getChartDetailCode and getChartTooltip to get the conflicted cargoes list
**                                              for subdaily by checking the date in between chart_start_date and chart_end_date.
**          02.05.2017  farhaann    ECPD-32533: Modified getCalendarTooltip to show code_text instead of code in tooltip
**          29.05.2017  farhaann    ECPD-32533: Modified getCalendarDetail and getCalendarTooltip
**          01.06.2017  farhaann    ECPD-32533: Modified getCalendarTooltipFcstMngr
**          30.08.2017  asareswi    ECPD-45326: Modified getChartDetailCode, getChartTooltip function to show correct conflict and occupied behaviour of cargoes in berth utilization chart.
**          13.10.2017  psssspra    ECPD-48734: Modified setBalanceDelta to include calculation of Balancedelta qty2 and qty3
**          20.10.2017  sharawan    ECPD-49488: Added function getCarrierDetailCode, getCarrierTooltip, getCarrierUtilisation, getMaintenance (private function)
**                                              for the Carrier Utilization Chart in Forecast Manager.
**          12.02.2018  Prashanthi  ECPD-46130: Added  validateSplitEntry to prevent the same company and lifting account entry for users.
**          09.04.2018  royyypur    ECPD-53946: Added getTextColor to configure the custom color for any date
** -------  ------   ----------------------------------------------------------------------------------------------------
*/

---------------------------------------------------------------------------------------------------
-- Function       : getRestriction
-- Description    :
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
-- Behaviour      : Private
--
---------------------------------------------------------------------------------------------------
FUNCTION getRestriction(p_daytime DATE,
                         p_berth_id VARCHAR2,
                         p_forecast_id VARCHAR2,
						 p_type VARCHAR2 DEFAULT 'DAY'
                       ) RETURN BOOLEAN
--</EC-DOC>
IS
lv_restriction NUMBER;
BEGIN
  SELECT COUNT(*)
    INTO lv_restriction
    FROM FCST_OPLOC_PERIOD_RESTR
   WHERE object_id = p_berth_id
     AND forecast_id = p_forecast_id
     AND p_daytime between decode(p_type,'DAY',TRUNC(start_date),start_date) and decode(p_type,'DAY',TRUNC(end_date),end_date);
  IF lv_restriction >=1 THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END getRestriction;

---------------------------------------------------------------------------------------------------
-- Function       : getMaintenance
-- Description    :
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
-- Behaviour      : Private
--
---------------------------------------------------------------------------------------------------
FUNCTION getMaintenance( p_daytime DATE,
                         p_carrier_id VARCHAR2,
                         p_forecast_id VARCHAR2
                       ) RETURN BOOLEAN
--</EC-DOC>
IS
lv_maintenance NUMBER;
BEGIN
  SELECT COUNT(*)
    INTO lv_maintenance
    from fcst_oploc_period_restr r, carrier c, forecast f
 where r.forecast_id = f.object_id
   and r.object_id = c.object_id
   and f.start_date >= c.start_date
   and c.start_date <= r.start_date
   and r.start_date >= f.start_date
   and r.end_date < f.end_date
   and c.object_id = p_carrier_id
   AND r.forecast_id = p_forecast_id
   AND p_daytime between r.start_date and r.end_date;
  IF lv_maintenance >=1 THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END getMaintenance;

---------------------------------------------------------------------------------------------------
-- Function       : getSubdaily
-- Description    :
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
-- Behaviour      : Private
--
---------------------------------------------------------------------------------------------------
FUNCTION getSubdaily(p_daytime DATE,
                     p_berth_id VARCHAR2,
                     p_forecast_id VARCHAR2,
                     p_storage_id VARCHAR2
                     ) RETURN BOOLEAN
--</EC-DOC>
IS
lv_subdaily NUMBER;
BEGIN
  SELECT COUNT(*)
    INTO lv_subdaily
    FROM V_FCST_CARGO_SUB_DAY_BERTH
   WHERE object_id = p_storage_id
     AND forecast_id = p_forecast_id
     AND berth_id = p_berth_id
     AND p_daytime <> chart_start_date
     AND p_daytime between chart_start_date and chart_end_date;
  IF lv_subdaily >=1 THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END getSubdaily;

---------------------------------------------------------------------------------------------------
-- Function       : getOpportunityName
-- Description    :
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
-- Behaviour      : Private
--
---------------------------------------------------------------------------------------------------
FUNCTION getOpportunityName (p_daytime DATE,
                         p_opportunity_no NUMBER,
                         p_cargo_no NUMBER
                       ) RETURN VARCHAR2
--</EC-DOC>
IS
lv_opportunity_name VARCHAR2(100);

BEGIN

  SELECT opportunity_name INTO lv_opportunity_name
    FROM OPPORTUNITY_GEN_TERM
   WHERE opportunity_no = p_opportunity_no
   and cargo_no = p_cargo_no
   AND p_daytime between daytime and end_date;

  RETURN lv_opportunity_name;
END getOpportunityName;

---------------------------------------------------------------------------------------------------
-- Function       : deleteNomination
-- Description    : Delete all nominations in the selected period that is not fixed and where cargo status is not Official and ready for harbour
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
PROCEDURE deleteNomination(p_storage_id VARCHAR2,p_forecast_id VARCHAR2,p_from_date DATE,p_to_date DATE)
--</EC-DOC>
IS
BEGIN
	NULL;
   raise_application_error(-20783, 'Function disable');													   
END deleteNomination;

---------------------------------------------------------------------------------------------------
-- Function       : setBalanceDelta
-- Description    :
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
PROCEDURE setBalanceDelta(p_forecast_id VARCHAR2, p_parcel_no NUMBER)
--</EC-DOC>
IS

	CURSOR c_nomination(cp_forecast_id VARCHAR2, cp_parcel_no number)
	IS
		SELECT nvl(purge_qty, 0) + nvl(cooldown_qty, 0) + nvl(vapour_return_qty, 0) + nvl(lauf_qty, 0) balance_delta_qty,
			   nvl(purge_qty2, 0) + nvl(cooldown_qty2, 0) + nvl(vapour_return_qty2, 0) + nvl(lauf_qty2, 0) balance_delta_qty2,
			   nvl(purge_qty3, 0) + nvl(cooldown_qty3, 0) + nvl(vapour_return_qty3, 0) + nvl(lauf_qty3, 0) balance_delta_qty3
		  FROM stor_fcst_lift_nom
		 WHERE parcel_no = cp_parcel_no
		   AND forecast_id = cp_forecast_id;

BEGIN

  -- Override the call to EcBp_Storage_Lift_Nomination if project spesific code.
  FOR c_nom IN c_nomination(p_forecast_id, p_parcel_no) loop
      UPDATE stor_fcst_lift_nom
	  set balance_delta_qty = c_nom.balance_delta_qty,
		  balance_delta_qty2 = c_nom.balance_delta_qty2,
		  balance_delta_qty3 = c_nom.balance_delta_qty3,
		  last_updated_by = ecdp_context.getAppUser
	  WHERE parcel_no = p_parcel_no AND forecast_id = p_forecast_id;
  END LOOP;


END setBalanceDelta;

---------------------------------------------------------------------------------------------------
-- Function       : aggrSubDayLifting
-- Description    :
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
FUNCTION aggrSubDayLifting(p_forecast_id VARCHAR2, p_parcel_no NUMBER, p_daytime DATE, p_column VARCHAR2 DEFAULT NULL, p_xtra_qty NUMBER DEFAULT 0)
RETURN NUMBER
--</EC-DOC>
IS
	ln_result NUMBER;
BEGIN
	ln_result := EcBP_Stor_Fcst_Lift_Nom.aggrSubDayLifting(p_forecast_id, p_parcel_no, p_daytime, p_column, p_xtra_qty);
	RETURN ln_result;
END aggrSubDayLifting;

---------------------------------------------------------------------------------------------------
-- Procedure      : calcSubDayLifting
-- Description    :
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
PROCEDURE calcSubDayLifting(p_forecast_id VARCHAR2, p_parcel_no NUMBER)
--</EC-DOC>
IS
	ln_unload_qty NUMBER;
	ln_unload_qty2 NUMBER;
	ln_vp_qty NUMBER;
	ln_vp_qty2 NUMBER;
	ln_lufg_qty NUMBER;
	ln_lufg_qty2 NUMBER;
	ln_unload_lufg_qty NUMBER;
	ln_unload_lufg_qty2 NUMBER;

	CURSOR c_nom(cp_forecast_id VARCHAR2, cp_parcel_no NUMBER)
	IS
		SELECT cargo_no, object_id, start_lifting_date,
		       grs_vol_requested, grs_vol_requested2, grs_vol_nominated, grs_vol_nominated2,
		       lauf_qty, lauf_qty2, balance_delta_qty, balance_delta_qty2
		  FROM stor_fcst_lift_nom
		 WHERE parcel_no = cp_parcel_no
		   AND forecast_id = cp_forecast_id
		   AND cargo_no NOT IN (select cargo_no from cargo_transport where cargo_status = 'D');

	CURSOR c_liftings(cp_parcel_no NUMBER)
	IS
		SELECT load_value, ec_product_meas_setup.LIFTING_EVENT(PRODUCT_MEAS_NO) lifting_event,
		       ec_product_meas_setup.NOM_UNIT_IND(PRODUCT_MEAS_NO) nom_unit_ind,
		       ec_product_meas_setup.NOM_UNIT_IND2(PRODUCT_MEAS_NO) nom_unit_ind2,
		       ec_product_meas_setup.balance_qty_type(PRODUCT_MEAS_NO) balance_qty_type
		  FROM storage_lifting
		 WHERE parcel_no = cp_parcel_no;
BEGIN
	EcBP_Stor_Fcst_Lift_Nom.calcSubDayLifting(p_forecast_id, p_parcel_no);
END calcSubDayLifting;

---------------------------------------------------------------------------------------------------

-- Procedure      : getCalendarDetail
-- Description    :
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

FUNCTION getCalendarDetail(p_daytime DATE, p_berth_id VARCHAR2, p_forecast_id VARCHAR2) RETURN VARCHAR2
 IS
BEGIN
  RETURN NULL;
END getCalendarDetail;


---------------------------------------------------------------------------------------------------

-- Procedure      : getCalendarTooltip
-- Description    :
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

FUNCTION getCalendarTooltip(p_daytime DATE, p_berth_id VARCHAR2, p_forecast_id VARCHAR2) RETURN VARCHAR2
 IS
BEGIN
  RETURN NULL;
END getCalendarTooltip;

---------------------------------------------------------------------------------------------------

-- Procedure      : getCalendarTooltipFcstMngr
-- Description    : This function is used in Forecast manager Calendar tab.
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

FUNCTION getCalendarTooltipFcstMngr(p_daytime DATE, p_berth_id VARCHAR2, p_forecast_id VARCHAR2, p_lifting_account_id VARCHAR2) RETURN VARCHAR2
 IS
BEGIN
  RETURN NULL;

END getCalendarTooltipFcstMngr;

---------------------------------------------------------------------------------------------------

-- Procedure      : getChartTooltip
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : STOR_FCST_LIFT_NOM, CARGO_FCST_TRANSPORT, CARGO_STATUS_MAPPING, BERTH
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :	Generating the tool tip info for Cargo Berth Chart.
--
---------------------------------------------------------------------------------------------------

FUNCTION getChartDetailCode(p_daytime DATE,
                            p_berth_id VARCHAR2,
                            p_storage_id VARCHAR2,
                            p_forecast_id VARCHAR2,
                            p_type VARCHAR2 DEFAULT 'DAY') RETURN VARCHAR2
--</EC-DOC>
 IS

  CURSOR c_day_cargoes(cp_daytime DATE, cp_berth_id VARCHAR2, cp_storage_id VARCHAR2, cp_forecast_id VARCHAR2) IS
             SELECT n.cargo_no, n.opportunity_no
              FROM STOR_FCST_LIFT_NOM N,
                   cargo_fcst_transport CT,
                   STORAGE_PORT_RESOURCE S,
                   CARGO_STATUS_MAPPING  CMAP
             where TRUNC(n.nom_firm_date) = TRUNC(cp_daytime)
               and n.object_id = cp_storage_id
               and n.forecast_id = cp_forecast_id
               and ct.berth_id = cp_berth_id
               and n.forecast_id = ct.forecast_id
               and n.object_id = s.object_id
               and s.port_resource_id = ct.berth_id
               and n.cargo_no = ct.cargo_no
               and ct.cargo_status = cmap.cargo_status
               and cmap.ec_cargo_status != 'D'
               and nvl(n.DELETED_IND, 'N') <> 'Y';

  CURSOR c_subdaily_cargoes(cp_daytime DATE, cp_berth_id VARCHAR2, cp_storage_id VARCHAR2, cp_forecast_id VARCHAR2) IS
             select n.cargo_no, n.opportunity_no
                FROM STOR_FCST_LIFT_NOM   N,
                     cargo_fcst_transport CT,
                     STORAGE_PORT_RESOURCE S,
                     CARGO_STATUS_MAPPING CMAP
               where n.parcel_no IN (SELECT distinct(snd.parcel_no)
                                      FROM stor_fcst_sub_day_lift_nom snd
                                     where snd.object_id = cp_storage_id
                                       and snd.forecast_id = cp_forecast_id)
                 AND cp_daytime >= n.start_lifting_date
				 AND cp_daytime < (SELECT max(snd.daytime) as end_date
                                                               FROM STOR_FCST_SUB_DAY_LIFT_NOM snd
                                                              where snd.parcel_no = n.parcel_no
                                                                and snd.forecast_id = cp_forecast_id
                                                                and snd.object_id = cp_storage_id)
                 and ct.berth_id = cp_berth_id
				 and n.object_id = cp_storage_id
                 and n.forecast_id = cp_forecast_id
                 and n.forecast_id = ct.forecast_id
                 and n.cargo_no = ct.cargo_no
                 and n.object_id = s.object_id
                 and s.port_resource_id = ct.berth_id
                 and ct.cargo_status = cmap.cargo_status
                 and cmap.ec_cargo_status != 'D'
                 and nvl(n.DELETED_IND, 'N') <> 'Y';

  lv_detail_code VARCHAR2(32);
  ld_startDate      DATE;
  ld_production_day DATE;
  ln_rowcount       NUMBER;

BEGIN

    --lv_detail_code := 'RESTRICTION';
    IF getRestriction(p_daytime,p_berth_id,p_forecast_id) THEN
      lv_detail_code := 'RESTRICTION';
    END IF;

    IF p_type = '1HR' THEN
      FOR cur_subday_cargo in c_subdaily_cargoes(p_daytime, p_berth_id, p_storage_id, p_forecast_id) LOOP
        ln_rowcount := c_subdaily_cargoes%ROWCOUNT;
        IF (ln_rowcount > 1) OR (getRestriction(p_daytime,p_berth_id,p_forecast_id)) THEN
          lv_detail_code := 'CONFLICT';
        ELSIF cur_subday_cargo.opportunity_no IS NOT NULL THEN
          lv_detail_code := 'OPPORTUNITY';
        ELSIF cur_subday_cargo.cargo_no IS NOT NULL THEN
          lv_detail_code := 'OCCUPIED';
        END IF;
      END LOOP;
    ELSE
      FOR cur_day_cargo in c_day_cargoes(p_daytime, p_berth_id, p_storage_id, p_forecast_id) LOOP
        ln_rowcount := c_day_cargoes%ROWCOUNT;
        IF (ln_rowcount > 1) OR (getRestriction(p_daytime,p_berth_id,p_forecast_id)) THEN
          lv_detail_code := 'CONFLICT';
        ELSIF cur_day_cargo.opportunity_no IS NOT NULL THEN
          lv_detail_code := 'OPPORTUNITY';
        ELSIF cur_day_cargo.cargo_no IS NOT NULL THEN
          lv_detail_code := 'OCCUPIED';
        END IF;
      END LOOP;
    END IF;

	RETURN lv_detail_code;

END getChartDetailCode;

---------------------------------------------------------------------------------------------------

-- Procedure      : getChartTooltip
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : STOR_FCST_LIFT_NOM, CARGO_FCST_TRANSPORT, CARGO_STATUS_MAPPING, BERTH
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :	Generating the tool tip info for Cargo Berth Chart.
--
---------------------------------------------------------------------------------------------------

FUNCTION getChartTooltip(p_daytime DATE,
                         p_berth_id VARCHAR2,
                         p_storage_id VARCHAR2,
                         p_forecast_id VARCHAR2,
                         p_detail_code VARCHAR2,
                         p_type VARCHAR2 DEFAULT 'DAY') RETURN VARCHAR2
--</EC-DOC>
IS

   CURSOR c_berth_restriction(cp_daytime DATE, cp_berth_id VARCHAR2, cp_storage_id VARCHAR2, cp_forecast_id VARCHAR2) IS
      SELECT restriction_type
        FROM FCST_OPLOC_PERIOD_RESTR r, STORAGE_PORT_RESOURCE s
       WHERE r.object_id = cp_berth_id
         AND cp_daytime between r.start_date and r.end_date
         AND r.forecast_id = cp_forecast_id
         AND s.object_id = cp_storage_id
         AND r.object_id = s.port_resource_id;

   CURSOR c_tooltip_day(cp_daytime DATE, cp_berth_id VARCHAR2, cp_storage_id VARCHAR2, cp_forecast_id VARCHAR2) IS
      select berth_id,
             LISTAGG(cargo_name, ', ') WITHIN GROUP (ORDER BY cargo_name) cargoes
        from (select distinct ct.berth_id berth_id, ct.cargo_name
                          FROM STOR_FCST_LIFT_NOM N,
                               cargo_fcst_transport CT,
                               STORAGE_PORT_RESOURCE S,
                               CARGO_STATUS_MAPPING  CMAP
                         where TRUNC(n.nom_firm_date) = TRUNC(cp_daytime)
                           and n.object_id = cp_storage_id
                           and n.forecast_id = cp_forecast_id
                           and ct.berth_id = cp_berth_id
                           and n.forecast_id = ct.forecast_id
                           and n.object_id = s.object_id
                           and s.port_resource_id = ct.berth_id
                           and n.cargo_no = ct.cargo_no
                           and ct.cargo_status = cmap.cargo_status
                           and cmap.ec_cargo_status != 'D'
                           and nvl(n.DELETED_IND, 'N') <> 'Y')
       group by berth_id;

  CURSOR c_tooltip_subday(cp_daytime DATE, cp_berth_id VARCHAR2, cp_storage_id VARCHAR2, cp_forecast_id VARCHAR2) IS
      select berth_id,
             LISTAGG(cargo_name, ', ') WITHIN GROUP(ORDER BY cargo_name) cargoes
        from (select distinct ct.berth_id berth_id, ct.cargo_name
                FROM STOR_FCST_LIFT_NOM   N,
                     cargo_fcst_transport CT,
                     STORAGE_PORT_RESOURCE S,
                     CARGO_STATUS_MAPPING CMAP
               where n.parcel_no IN (SELECT distinct(snd.parcel_no)
                                      FROM stor_fcst_sub_day_lift_nom snd
                                     where snd.object_id = cp_storage_id
                                       and snd.forecast_id = cp_forecast_id)
                 AND cp_daytime >= n.start_lifting_date
				 AND cp_daytime < (SELECT max(snd.daytime) as end_date
                                                               FROM STOR_FCST_SUB_DAY_LIFT_NOM snd
                                                              where snd.parcel_no = n.parcel_no
                                                                and snd.forecast_id = cp_forecast_id
                                                                and snd.object_id = cp_storage_id)
                 and n.object_id = cp_storage_id
                 and n.forecast_id = cp_forecast_id
				 and ct.berth_id = cp_berth_id
                 and n.forecast_id = ct.forecast_id
                 and n.cargo_no = ct.cargo_no
                 and n.object_id = s.object_id
                 and s.port_resource_id = ct.berth_id
                 and ct.cargo_status = cmap.cargo_status
                 and cmap.ec_cargo_status != 'D'
                 and nvl(n.DELETED_IND, 'N') <> 'Y')
       group by berth_id;

  lv_cargoes VARCHAR2(200);
  lv_restriction VARCHAR2(100);
  lv_tool_tip VARCHAR2(1000);

BEGIN

     IF p_detail_code IN ('RESTRICTION') THEN
      FOR cur_restriction in c_berth_restriction(p_daytime, p_berth_id, p_storage_id, p_forecast_id) LOOP
        lv_restriction := ec_prosty_codes.CODE_TEXT(cur_restriction.restriction_type,'CAP_RESTRICTION_TYPE');
      END LOOP;
      lv_tool_tip := p_detail_code||' : '||lv_restriction;

    ELSIF p_detail_code IN ('CONFLICT', 'OCCUPIED', 'OPPORTUNITY') THEN

      IF p_type = '1HR' THEN
        FOR cur_tooltip_subday in c_tooltip_subday(p_daytime, p_berth_id, p_storage_id, p_forecast_id) LOOP
          lv_cargoes := cur_tooltip_subday.cargoes;
        END LOOP;
      ELSIF p_type = 'DAY' THEN
        FOR cur_tooltip_day in c_tooltip_day(p_daytime, p_berth_id, p_storage_id, p_forecast_id) LOOP
            lv_cargoes := cur_tooltip_day.cargoes;
        END LOOP;
      END IF;

      -- check if conflict with restrictions
      FOR cur_restriction in c_berth_restriction(p_daytime, p_berth_id, p_storage_id, p_forecast_id) LOOP
        lv_restriction := ec_prosty_codes.CODE_TEXT(cur_restriction.restriction_type,'CAP_RESTRICTION_TYPE');
      END LOOP;

      /*IF ln_opportunity_no IS NOT NULL THEN
         lv_tool_tip := p_detail_code||' : '||getOpportunityName(ln_opportunity_no)||' - '||ecdp_objects.GetObjName(p_berth_id, p_daytime)||' : '||lv_cargoes;
      ELS*/
      IF lv_restriction IS NULL THEN
         lv_tool_tip := p_detail_code||' : '||lv_cargoes;
      ELSE
         lv_tool_tip := p_detail_code||' : '||lv_cargoes||' '||'RESTRICTION'||' : '||lv_restriction;
      END IF;

    END IF;

    RETURN lv_tool_tip;

END getChartTooltip;

---------------------------------------------------------------------------------------------------
-- Procedure      : undoCargo
-- Description    : Implement to rollback cargo data to the original values or existing forecast values
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
PROCEDURE undoCargo(p_daytime DATE, p_storage_id VARCHAR2, p_forecast_id_1 VARCHAR2 DEFAULT NULL, p_forecast_id_2 VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS
BEGIN
	NULL;
END undoCargo;

---------------------------------------------------------------------------------------------------
-- Function       : getVerificationText
-- Description    : Set verification text for different value in Forecast Manager - Compare tab
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
FUNCTION getVerificationText (p_att_name VARCHAR2)
  RETURN VARCHAR2
--</EC-DOC>
 IS

BEGIN
    RETURN NULL;
 END getVerificationText;

---------------------------------------------------------------------------------------------------
-- Function       : getDefaultSplit
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : stor_fcst_lift_nom
-- Using functions: ecbp_stor_fcst_lift_nom.createUpdateSplit()
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE getDefaultSplit(p_forecast_id VARCHAR2, p_parcel_no NUMBER)
--</EC-DOC>
IS

cursor c_get_lifting_account(cp_forecast_id VARCHAR2, cp_parcel_no NUMBER) is
select lifting_account_id
  from stor_fcst_lift_nom t
 where t.parcel_no = cp_parcel_no
   and t.forecast_id = cp_forecast_id;

BEGIN

  -- Override the call to ecbp_stor_fcst_lift_nom if project specific code.
  FOR r_get_la IN c_get_lifting_account(p_forecast_id, p_parcel_no) LOOP
	  IF r_get_la.lifting_account_id IS NOT NULL THEN
		ecbp_stor_fcst_lift_nom.createUpdateSplit(p_forecast_id, p_parcel_no, NULL, r_get_la.lifting_account_id);
	  END IF;
  END LOOP;

END getDefaultSplit;

---------------------------------------------------------------------------------------------------
-- Function       : validateSplit
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions: ecbp_stor_fcst_lift_nom.validateSplit()
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateSplit(p_forecast_id VARCHAR2, p_parcel_no NUMBER)
--</EC-DOC>
IS
BEGIN
  --NULL;
  -- Override the call to ecbp_stor_fcst_lift_nom if project specific code.
  ecbp_stor_fcst_lift_nom.validateSplit(p_forecast_id, p_parcel_no);

END validateSplit;

---------------------------------------------------------------------------------------------------
-- Procedure      : calcSplitQty
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions: ecbp_stor_fcst_lift_nom.calcSplitQty()
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcSplitQty(p_forecast_id VARCHAR2, p_parcel_no NUMBER, p_company_id VARCHAR2, p_lifting_account_id VARCHAR2, p_daytime DATE, p_qty NUMBER)
RETURN NUMBER
--</EC-DOC>
AS
	lv_split_qty NUMBER;
BEGIN
	lv_split_qty :=	ecbp_stor_fcst_lift_nom.calcSplitQty(p_forecast_id, p_parcel_no, p_company_id, p_lifting_account_id, p_daytime, p_qty) ;
	RETURN lv_split_qty;

END calcSplitQty;

---------------------------------------------------------------------------------------------------
-- Procedure      : createUpdateSplit
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions: ecbp_stor_fcst_lift_nom.createUpdateSplit()
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE createUpdateSplit(p_forecast_id VARCHAR2, p_parcel_no NUMBER, p_old_lifting_account_id VARCHAR2, p_new_lifting_account_id VARCHAR2)
--</EC-DOC>
	IS
BEGIN
	ecbp_stor_fcst_lift_nom.createUpdateSplit(p_forecast_id, p_parcel_no, p_old_lifting_account_id, p_new_lifting_account_id) ;

END createUpdateSplit;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSubDaySplitQty
-- Description    : Returns the sub daily qty split for a company
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions: calcSplitQty()
--
-- Configuration
-- required       :
--
-- Behaviour      :
-- History        :
---------------------------------------------------------------------------------------------------
FUNCTION getSubDaySplitQty(p_forecast_id VARCHAR2, p_parcel_no NUMBER, p_company_id VARCHAR2, p_lifting_account_id VARCHAR2, p_daytime DATE, p_qty NUMBER, p_column VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
ln_split_qty NUMBER;

BEGIN
	ln_split_qty:= calcSplitQty(p_forecast_id, p_parcel_no, p_company_id, p_lifting_account_id, p_daytime, p_qty);
RETURN ln_split_qty;
END getSubDaySplitQty;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcAggrSubDaySplitQty
-- Description    : Returns the aggregate qty split for a company
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions: aggrSubDayLifting() and calcSplitQty()
--
-- Configuration
-- required       :
--
-- Behaviour      :
-- History        :
---------------------------------------------------------------------------------------------------
FUNCTION calcAggrSubDaySplitQty(p_forecast_id VARCHAR2, p_parcel_no NUMBER, p_company_id VARCHAR2, p_lifting_account_id VARCHAR2, p_daytime DATE, p_column VARCHAR2 DEFAULT NULL, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER
--</EC-DOC>
IS
ln_split_qty NUMBER;
ln_lifted_qty NUMBER;
ln_tot_qty NUMBER;

BEGIN

	ln_lifted_qty := aggrSubDayLifting(p_forecast_id, p_parcel_no, p_daytime, p_column, p_xtra_qty);
	ln_split_qty := calcSplitQty(p_forecast_id, p_parcel_no, p_company_id, p_lifting_account_id, p_daytime, ln_lifted_qty);

RETURN ln_split_qty;

END calcAggrSubDaySplitQty;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : carrier_utilisation
-- Description    : Returns the carrier utilized
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
-- History        :
---------------------------------------------------------------------------------------------------
FUNCTION getCarrierUtilisation(p_forecast_id varchar2, p_from_date date, p_to_date date, p_carrier_id varchar2)
RETURN number
IS


  ln_idle_days number;
  ln_days number;
  ln_active_days number;
  ln_value number;
  ld_prev_start_date date;
  ld_prev_end_date date;
  lb_not_used boolean;
  ld_date date;

  type t_carrier_chart is table of v_fcst_carrier_chart%ROWTYPE index by pls_integer;
  l_carrier_chart t_carrier_chart;
  l_carrier_chart_empty t_carrier_chart;


begin
  --Initalize
  ln_value := 0;
  ln_idle_days := 0;
  ln_days := 0;
  ln_active_days := 0;
  l_carrier_chart := l_carrier_chart_empty;
  lb_not_used := true;

  --Fetch data
  select * bulk collect into l_carrier_chart from v_fcst_carrier_chart where forecast_id = p_forecast_id and daytime between p_from_date and p_to_date and object_id = p_carrier_id and detail_code = 'EN ROUTE' order by chart_start_date;

  ld_prev_end_date := p_from_date-1;
  ld_prev_start_date := p_from_date-1;

  if l_carrier_chart.count > 0 then

    for i IN 1..l_carrier_chart.COUNT loop
      lb_not_used := false;
      if i = 1 then -- fetch idle days for the first cargo
        if trunc(l_carrier_chart(i).chart_start_date) > ld_prev_end_date and trunc(l_carrier_chart(i).chart_start_date) != trunc(p_from_date) then
          -- Calculate idle time
          ln_idle_days := ln_idle_days + (l_carrier_chart(i).chart_start_date - ld_prev_end_date);
         end if;
         ld_prev_end_date := trunc(l_carrier_chart(i).chart_start_date) +1 + l_carrier_chart(i).route_days +1 + l_carrier_chart(i).route_days;
     end if;

     if i > 1 and l_carrier_chart.count > 1 then
       -- find idle days between cargoes
       if trunc(ld_prev_end_date) < trunc(l_carrier_chart(i).chart_start_date)-1 then
          ln_idle_days := ln_idle_days +trunc(l_carrier_chart(i).chart_start_date) - trunc(ld_prev_end_date);
       end if;
       ld_prev_end_date := trunc(l_carrier_chart(i).chart_start_date) +1 + l_carrier_chart(i).route_days +1 + l_carrier_chart(i).route_days;
     end if;

    --  if l_carrier_chart.COUNT = 1 then
         --count nr days before start

      if i = l_carrier_chart.COUNT then -- Last period - check for idle period at the end
        if ld_prev_end_date < p_to_date then
          ln_idle_days := ln_idle_days + (p_to_date - trunc(ld_prev_end_date));
        end if;
      end if;

    --  ld_prev_start_date := trunc(l_carrier_chart(i).chart_start_date);
     -- ld_prev_end_date := trunc(l_carrier_chart(i).chart_start_date) + 1 +l_carrier_chart(i).route_days + 1 + l_carrier_chart(i).route_days;

      end loop;
    end if;

    if lb_not_used then
      ln_value := 0;
    else
      ln_days := p_to_date - p_from_date +1;
      ln_active_days := ln_days - ln_idle_days;
      ln_value := (ln_active_days/ln_days) * 100;
    end if;
    return trunc(ln_value);


END getCarrierUtilisation;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCarrierDetailCode
-- Description    : Returns the detail code for carrier utilisation chart
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
-- History        :
---------------------------------------------------------------------------------------------------

FUNCTION getCarrierDetailCode(p_carrier_id VARCHAR2,
                            p_forecast_id VARCHAR2,
                            p_product_group VARCHAR2,
                            p_daytime DATE) RETURN VARCHAR2
--</EC-DOC>
 IS

  CURSOR c_cargoes(p_carrier_id VARCHAR2, p_forecast_id VARCHAR2, p_product_group VARCHAR2,p_daytime DATE) IS
             select DISTINCT CARGO_NO
               from V_FCST_CARRIER_CHART
              where forecast_id = p_forecast_id
                 and chart_start_date = p_daytime
                and product_group = p_product_group
                and object_id = p_carrier_id;

  lv_detail_code VARCHAR2(32);
  ln_rowcount       NUMBER;

BEGIN

    IF getMaintenance(p_daytime,p_carrier_id,p_forecast_id) THEN
      lv_detail_code := 'MAINTENANCE';
    END IF;

      FOR c_cargo in c_cargoes(p_carrier_id, p_forecast_id,p_product_group ,p_daytime) LOOP
        ln_rowcount := c_cargoes%ROWCOUNT;
        IF (ln_rowcount > 1) OR (getMaintenance(p_daytime,p_carrier_id,p_forecast_id)) THEN
          lv_detail_code := 'CONFLICT';
        ELSIF c_cargo.cargo_no IS NOT NULL THEN
            lv_detail_code := 'EN ROUTE';
        END IF;
      END LOOP;

	RETURN lv_detail_code;

END getCarrierDetailCode;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCarrierTooltip
-- Description    : Returns tooltip for carrier utilisation chart
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
-- History        :
---------------------------------------------------------------------------------------------------

FUNCTION getCarrierTooltip(p_daytime DATE,
                         p_carrier_id VARCHAR2,
                         p_product_group VARCHAR2,
                         p_forecast_id VARCHAR2,
                         p_detail_code VARCHAR2) RETURN VARCHAR2
--</EC-DOC>
IS

   CURSOR c_carrier_maintenance(cp_daytime DATE, cp_carrier_id VARCHAR2, cp_forecast_id VARCHAR2) IS
       SELECT C.OBJECT_CODE
         FROM fcst_oploc_period_restr r, carrier c, forecast f
        WHERE r.forecast_id = f.object_id
          AND r.object_id = c.object_id
          AND f.start_date >= c.start_date
          AND c.start_date <= r.start_date
          AND r.start_date >= f.start_date
          AND r.end_date < f.end_date
          AND cp_daytime between r.start_date and r.end_date
          AND f.object_id = cp_forecast_id
          AND c.object_id = cp_carrier_id;


     CURSOR c_tooltip(cp_daytime DATE, cp_carrier_id VARCHAR2, cp_product_group VARCHAR2, cp_forecast_id VARCHAR2) IS
        select object_id,
         LISTAGG(ec_cargo_fcst_transport.cargo_name(cargo_no, forecast_id),
                 ', ') WITHIN GROUP(ORDER BY ec_cargo_fcst_transport.cargo_name(cargo_no, forecast_id)) cargoes
          from (select DISTINCT cargo_no,forecast_id,object_id
                  from V_FCST_CARRIER_CHART
                 where forecast_id = cp_forecast_id
                   and chart_start_date = cp_daytime
                   and product_group = cp_product_group
                   and object_id = cp_carrier_id)
         group by object_id;

      CURSOR c_tooltip_port(cp_daytime DATE, cp_carrier_id VARCHAR2, cp_product_group VARCHAR2, cp_forecast_id VARCHAR2) IS
        select object_id,
         LISTAGG(ecdp_objects.GetObjName(PORT_ID, daytime),
               ', ') WITHIN GROUP(ORDER BY ec_cargo_fcst_transport.cargo_name(cargo_no, forecast_id)) to_port,
         LISTAGG(nominated_qty,
               ', ') WITHIN GROUP(ORDER BY ec_cargo_fcst_transport.cargo_name(cargo_no, forecast_id)) nominated_qty
                 from (select cargo_no,forecast_id,object_id,nominated_qty,port_id,daytime
                  from V_FCST_CARRIER_CHART
                 where forecast_id = cp_forecast_id
                   and chart_start_date = cp_daytime
                   and product_group = cp_product_group
                   and object_id = cp_carrier_id)
         group by object_id;

  lv_cargoes VARCHAR2(200);
  lv_restriction_cnt NUMBER := 0;
  lv_tool_tip VARCHAR2(1000);
  lv_from_port VARCHAR2(200);
  lv_port VARCHAR2(1000);
  lv_nominated_qty VARCHAR2(1000);

BEGIN

    IF p_detail_code IN ('MAINTENANCE') THEN
      FOR cur_restriction in c_carrier_maintenance(p_daytime, p_carrier_id, p_forecast_id) LOOP
        lv_restriction_cnt := c_carrier_maintenance%ROWCOUNT;
      END LOOP;

    ELSIF p_detail_code IN ('CONFLICT', 'EN ROUTE', 'LOADING', 'UNLOADING', 'RETURN') THEN

        FOR cur_tooltip_day in c_tooltip(p_daytime, p_carrier_id, p_product_group, p_forecast_id) LOOP
            lv_cargoes := cur_tooltip_day.cargoes;
        END LOOP;
        FOR cur_tooltip_port in c_tooltip_port(p_daytime, p_carrier_id, p_product_group, p_forecast_id) LOOP
            lv_port := cur_tooltip_port.to_port;
            lv_nominated_qty := cur_tooltip_port.nominated_qty;
        END LOOP;

        SELECT DISTINCT s.op_fcty_1_code
          INTO lv_from_port
        FROM V_FCST_CARRIER_CHART V, OV_STORAGE S
        WHERE forecast_id = p_forecast_id
        AND chart_start_date = p_daytime
        AND product_group = p_product_group
        AND V.object_id = p_carrier_id
        AND V.NOM_OBJECT_ID = S.OBJECT_ID;

      -- check if conflict with MAINTENANCE
        FOR cur_restriction in c_carrier_maintenance(p_daytime, p_carrier_id, p_forecast_id) LOOP
        lv_restriction_cnt := c_carrier_maintenance%ROWCOUNT;
        END LOOP;

       IF lv_restriction_cnt = 0 THEN
         lv_tool_tip := '<b>'||'Cargo Name:'||'</b>'||lv_cargoes||'<br/>'||'<b>'||'From Port:'||'</b>'||lv_from_port||'<br/>'||'<b>'||'To Port:'||'</b>'||lv_port||'<br/>'||'<b>'||'Nominated Qty:'||'</b>'||lv_nominated_qty;
      ELSE
         lv_tool_tip := '<b>'||'Cargo Name:'||'</b>'||lv_cargoes||'<br/>'||'<b>'||'From Port:'||'</b>'||lv_from_port||'<br/>'||'<b>'||'To Port:'||'</b>'||lv_port||'<br/>'||'<b>'||'Nominated Qty:'||'</b>'||lv_nominated_qty||' '||'MAINTENANCE';
      END IF;

    END IF;

    RETURN lv_tool_tip;

END getCarrierTooltip;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validateSplitEntry
-- Description    : To avoid insertion of records for the same company and Lifting Account.
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
PROCEDURE validateSplitEntry(p_company_id      VARCHAR2,
								  p_parcel_no 	     NUMBER,
								  p_lifting_account_id VARCHAR2,
								  p_forecast_id    VARCHAR2)

--</EC-DOC>
 IS

	CURSOR c_split(p_company_id VARCHAR2, p_parcel_no NUMBER, p_lifting_account_id VARCHAR2, p_forecast_id    VARCHAR2) IS
		SELECT 'X'
			FROM FCST_STOR_LIFT_CPY_SPLIT t
			WHERE t.company_id = p_company_id
			AND t.lifting_account_id = p_lifting_account_id
			AND t.parcel_no = p_parcel_no
			and t.forecast_id = p_forecast_id;

BEGIN

	FOR cur_split_id IN c_split(p_company_id, p_parcel_no, p_lifting_account_id, p_forecast_id) LOOP
			RAISE_APPLICATION_ERROR(-20588, 'Company split already present.');
		END LOOP;

END validateSplitEntry;



-------------------------------------------------------------------------------------------------------

-- Procedure      : getTextColor
-- Description    :
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

FUNCTION getTextColor(p_daytime DATE,p_berth_id VARCHAR2, p_forecast_id VARCHAR2) RETURN VARCHAR2
--</EC-DOC>
 IS
BEGIN
 RETURN NULL;
END getTextColor;

END ue_Stor_Fcst_Lift_Nom;
/
