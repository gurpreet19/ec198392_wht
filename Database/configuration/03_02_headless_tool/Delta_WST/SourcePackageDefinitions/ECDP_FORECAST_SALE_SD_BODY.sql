CREATE OR REPLACE PACKAGE BODY ECDP_Forecast_Sale_Sd IS
/****************************************************************
** Package        :  ECDP_Forecast_Sale_Sd; body part
**
** $Revision: 1.3 $
**
** Purpose        :  Price Forecast business logic
**
** Documentation  :  www.energy-components.com
**
** Created        :  11.10.2009 Kenneth Masamba
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------
********************************************************************/

/****************************************************************
** Package        :  ECDP_Forecast_Sale_Sd; body part
**
** $Revision: 1.3 $
**
** Purpose        :  Handles capacity release operations
**
** Documentation  :  www.energy-components.com
**
** Created        :  11.10.2009 Kenneth Masamba
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------
********************************************************************/

PROCEDURE createForecast(p_new_forecast_code VARCHAR2, p_new_forecast_name VARCHAR2, p_start_date DATE, p_end_date DATE, p_new_forecast_id OUT VARCHAR2)
IS

BEGIN
    p_new_forecast_id:= EcDp_objects.GetInsertedObjectID(p_new_forecast_id);

    INSERT INTO FORECAST(object_id,CLASS_NAME,OBJECT_CODE,START_DATE,END_DATE, created_by)
    VALUES(p_new_forecast_id,'FORECAST_SALE_SD',p_new_forecast_code,p_start_date,p_end_date, ecdp_context.getAppUser);

    INSERT INTO FORECAST_VERSION(object_id,daytime,end_date, NAME, created_by)
    VALUES(p_new_forecast_id, p_start_date, p_end_date, p_new_forecast_name, ecdp_context.getAppUser);

END createForecast;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : copyFromForecast
-- Description    :
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
PROCEDURE copyFromForecast(p_forecast_id VARCHAR2, p_new_forecast_code VARCHAR2, p_new_forecast_name VARCHAR2, p_start_date DATE, p_end_date DATE DEFAULT NULL)
--</EC-DOC>
IS
  TYPE t_FCST_NOMPNT_MTH_STATUS IS TABLE OF FCST_NOMPNT_MTH_STATUS%ROWTYPE;
  l_FCST_NOMPNT_MTH_STATUS t_FCST_NOMPNT_MTH_STATUS;


-- from-data
CURSOR c_FCST_NOMPNT_MTH_STATUS (cp_forecast_id VARCHAR2, cp_from_date DATE, cp_to_date DATE)
IS
	SELECT *
	FROM FCST_NOMPNT_MTH_STATUS
	WHERE forecast_id = cp_forecast_id
    AND daytime between cp_from_date and nvl(cp_to_date, daytime);

ld_now DATE := Ecdp_Timestamp.getCurrentSysdate;

	p_new_forecast_id VARCHAR2(32) := NULL;
BEGIN
	IF (p_forecast_id IS NULL) THEN
		Raise_Application_Error(-20000,'Missing copy from forecast id');
	END IF;

	createForecast(p_new_forecast_code, p_new_forecast_name, p_start_date, p_end_date, p_new_forecast_id);


  OPEN c_FCST_NOMPNT_MTH_STATUS (p_forecast_id, p_start_date, p_end_date);
    LOOP
    FETCH c_FCST_NOMPNT_MTH_STATUS BULK COLLECT INTO l_FCST_NOMPNT_MTH_STATUS LIMIT 2000;

    FOR i IN 1..l_FCST_NOMPNT_MTH_STATUS.COUNT LOOP
      l_FCST_NOMPNT_MTH_STATUS(i).forecast_id := p_new_forecast_id;
      l_FCST_NOMPNT_MTH_STATUS(i).created_by := ecdp_context.getAppUser;
      l_FCST_NOMPNT_MTH_STATUS(i).created_date := ld_now;
      l_FCST_NOMPNT_MTH_STATUS(i).last_updated_by := NULL;
      l_FCST_NOMPNT_MTH_STATUS(i).last_updated_date := NULL;
    END LOOP;

    FORALL i IN 1..l_FCST_NOMPNT_MTH_STATUS.COUNT
      INSERT INTO FCST_NOMPNT_MTH_STATUS VALUES l_FCST_NOMPNT_MTH_STATUS(i);

    EXIT WHEN c_FCST_NOMPNT_MTH_STATUS%NOTFOUND;

  END LOOP;
  CLOSE c_FCST_NOMPNT_MTH_STATUS;

  INSERT INTO FCST_NOMLOC_PERIOD_EVENT a (a.forecast_id, a.event_seq, a.object_id, a.daytime, a.end_date, a.event_type, a.event_qty, a.comments,
         a.text_1, a.text_2, a.text_3, a.text_4, a.text_5, a.text_6, a.text_7, a.text_8, a.text_9, a.text_10, a.text_11, a.text_12, a.text_13, a.text_14, a.text_15,
         a.value_1, a.value_2, a.value_3, a.value_4, a.value_5, a.value_6, a.value_7, a.value_8, a.value_9, a.value_10,a.value_11, a.value_12, a.value_13, a.value_14, a.value_15,
         a.value_16, a.value_17, a.value_18, a.value_19, a.value_20, a.value_21, a.value_22, a.value_23, a.value_24, a.value_25, a.value_26, a.value_27, a.value_28, a.value_29, a.value_30,
         a.date_1, a.date_2, a.date_3, a.date_4, a.date_5, a.created_by)
  SELECT p_new_forecast_id, f.event_seq, f.object_id, f.daytime, f.end_date, f.event_type, f.event_qty, f.comments,
         f.text_1, f.text_2, f.text_3, f.text_4, f.text_5, f.text_6, f.text_7, f.text_8, f.text_9, f.text_10, f.text_11, f.text_12, f.text_13, f.text_14, f.text_15,
         f.value_1, f.value_2, f.value_3, f.value_4, f.value_5, f.value_6, f.value_7, f.value_8, f.value_9, f.value_10,f.value_11, f.value_12, f.value_13, f.value_14, f.value_15,
         f.value_16, f.value_17, f.value_18, f.value_19, f.value_20, f.value_21, f.value_22, f.value_23, f.value_24, f.value_25, f.value_26, f.value_27, f.value_28, f.value_29, f.value_30,
         f.date_1, f.date_2, f.date_3, f.date_4, f.date_5, ecdp_context.getAppUser
  FROM FCST_NOMLOC_PERIOD_EVENT f WHERE f.forecast_id = p_forecast_id
     AND f.daytime >= p_start_date
	   AND f.daytime < nvl(p_end_date, daytime+1);

  INSERT INTO FCST_NOMPNT_PERIOD_EVENT a (a.forecast_id, a.event_seq, a.object_id, a.ref_event_seq, a.daytime, a.end_date, a.event_type, a.event_qty, a.shipper_code, a.contract_id, a.comments,
         a.text_1, a.text_2, a.text_3, a.text_4, a.text_5, a.text_6, a.text_7, a.text_8, a.text_9, a.text_10, a.text_11, a.text_12, a.text_13, a.text_14, a.text_15,
         a.value_1, a.value_2, a.value_3, a.value_4, a.value_5, a.value_6, a.value_7, a.value_8, a.value_9, a.value_10,a.value_11, a.value_12, a.value_13, a.value_14, a.value_15,
         a.value_16, a.value_17, a.value_18, a.value_19, a.value_20, a.value_21, a.value_22, a.value_23, a.value_24, a.value_25, a.value_26, a.value_27, a.value_28, a.value_29, a.value_30,
         a.date_1, a.date_2, a.date_3, a.date_4, a.date_5, a.created_by)
  SELECT p_new_forecast_id, f.event_seq, f.object_id, f.ref_event_seq, f.daytime, f.end_date, f.event_type, f.event_qty, f.shipper_code, f.contract_id, f.comments,
         f.text_1, f.text_2, f.text_3, f.text_4, f.text_5, f.text_6, f.text_7, f.text_8, f.text_9, f.text_10, f.text_11, f.text_12, f.text_13, f.text_14, f.text_15,
         f.value_1, f.value_2, f.value_3, f.value_4, f.value_5, f.value_6, f.value_7, f.value_8, f.value_9, f.value_10,f.value_11, f.value_12, f.value_13, f.value_14, f.value_15,
         f.value_16, f.value_17, f.value_18, f.value_19, f.value_20, f.value_21, f.value_22, f.value_23, f.value_24, f.value_25, f.value_26, f.value_27, f.value_28, f.value_29, f.value_30,
         f.date_1, f.date_2, f.date_3, f.date_4, f.date_5, ecdp_context.getAppUser
  FROM FCST_NOMPNT_PERIOD_EVENT f WHERE f.forecast_id = p_forecast_id
     AND f.daytime >= p_start_date
	   AND f.daytime < nvl(p_end_date, daytime+1);

  INSERT INTO FCST_NOMPNT_SUB_DAY_EVENT a (a.forecast_id, a.event_seq, a.day_event_seq, a.object_id, a.daytime, a.end_date, a.event_type, a.event_qty, a.nom_status, a.shipper_code,
         a.contract_id, a.entry_location_id, a.exit_location_id, a.comments, a.summer_time, a.production_day,
         a.text_1, a.text_2, a.text_3, a.text_4, a.text_5, a.text_6, a.text_7, a.text_8, a.text_9, a.text_10, a.text_11, a.text_12, a.text_13, a.text_14, a.text_15,
         a.value_1, a.value_2, a.value_3, a.value_4, a.value_5, a.value_6, a.value_7, a.value_8, a.value_9, a.value_10,a.value_11, a.value_12, a.value_13, a.value_14, a.value_15,
         a.value_16, a.value_17, a.value_18, a.value_19, a.value_20, a.value_21, a.value_22, a.value_23, a.value_24, a.value_25, a.value_26, a.value_27, a.value_28, a.value_29, a.value_30,
         a.date_1, a.date_2, a.date_3, a.date_4, a.date_5, a.created_by)
  SELECT p_new_forecast_id, f.event_seq, f.day_event_seq, f.object_id, f.daytime, f.end_date, f.event_type, f.event_qty, f.nom_status, f.shipper_code,
         f.contract_id, f.entry_location_id, f.exit_location_id, f.comments, f.summer_time, f.production_day,
         f.text_1, f.text_2, f.text_3, f.text_4, f.text_5, f.text_6, f.text_7, f.text_8, f.text_9, f.text_10, f.text_11, f.text_12, f.text_13, f.text_14, f.text_15,
         f.value_1, f.value_2, f.value_3, f.value_4, f.value_5, f.value_6, f.value_7, f.value_8, f.value_9, f.value_10,f.value_11, f.value_12, f.value_13, f.value_14, f.value_15,
         f.value_16, f.value_17, f.value_18, f.value_19, f.value_20, f.value_21, f.value_22, f.value_23, f.value_24, f.value_25, f.value_26, f.value_27, f.value_28, f.value_29, f.value_30,
         f.date_1, f.date_2, f.date_3, f.date_4, f.date_5, ecdp_context.getAppUser
  FROM FCST_NOMPNT_SUB_DAY_EVENT f WHERE f.forecast_id = p_forecast_id
     AND f.daytime >= p_start_date
	   AND f.daytime < nvl(p_end_date, daytime+1);

END copyFromForecast;



--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  InsNewPriceElementSet
-- Description    : Called from class FCST_NOMPNT_MTH_STATUS used by business function Forecast Contract Price (EC Sales)
--                  Depending on selected price object, this procedure creates a record for each price concept element defined on the price concept.
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Inserts into table FCST_NOMPNT_MTH_STATUS
--
-------------------------------------------------------------------------------------------------
/*PROCEDURE InsNewPriceElementSet(
    p_forecast_id               VARCHAR2,
    p_object_id                 VARCHAR2,
    p_price_concept_code        VARCHAR2,
    p_price_element_code        VARCHAR2,
    p_daytime                   DATE)
--<EC-DOC>
IS



CURSOR c_price_elements (cp_price_concept_code VARCHAR2) IS
       SELECT price_element_code
       FROM   price_concept_element
       WHERE  price_concept_code = cp_price_concept_code;


lrec_pp_value FCST_NOMPNT_MTH_STATUS%ROWTYPE;
ln_inserted NUMBER := 0;
BEGIN



lrec_pp_value := ec_FCST_NOMPNT_MTH_STATUS.row_by_pk(p_object_id,p_forecast_id, p_price_concept_code,p_price_element_code,p_daytime);

-- Inserting record for each price element


-- Checking if any price element has been inserted
FOR c_val IN c_price_elements(p_price_concept_code) LOOP

ln_inserted := 0;

SELECT count(*)
  INTO ln_inserted
  FROM FCST_NOMPNT_MTH_STATUS
 WHERE object_id = p_object_id
   AND forecast_id = p_forecast_id
   AND price_concept_code = p_price_concept_code
   AND price_element_code = c_val.price_element_code
   AND daytime = p_daytime;

    -- One record is already inserted
    IF  (ln_inserted = 0)  THEN

      INSERT
      INTO     FCST_NOMPNT_MTH_STATUS (forecast_id, object_id,price_concept_code,price_element_code,daytime,price_value,adj_price_value,comments,created_by)
      VALUES   (p_forecast_id, p_object_id,p_price_concept_code, c_val.price_element_code,p_daytime,lrec_pp_value.price_value,lrec_pp_value.adj_price_value,lrec_pp_value.comments,lrec_pp_value.created_by);
    END IF;
END LOOP;


END InsNewPriceElementSet;*/



END ECDP_Forecast_Sale_Sd;