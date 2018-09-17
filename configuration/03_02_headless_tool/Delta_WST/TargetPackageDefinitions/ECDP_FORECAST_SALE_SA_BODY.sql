CREATE OR REPLACE PACKAGE BODY ECDP_Forecast_Sale_Sa IS
/****************************************************************
** Package        :  ECDP_Forecast_Sale_Sa; body part
**
** $Revision: 1.2 $
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
** Package        :  ECDP_Forecast_Sale_Sa; body part
**
** $Revision: 1.2 $
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
    VALUES(p_new_forecast_id,'FORECAST_SALE_SA',p_new_forecast_code,p_start_date,p_end_date, ecdp_context.getAppUser);

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
  TYPE t_fcst_cntracc_cpy_status IS TABLE OF fcst_cntracc_cpy_status%ROWTYPE;
  l_fcst_cntracc_cpy_status t_fcst_cntracc_cpy_status;

  TYPE t_FCST_CNTR_MTH_EXPEND IS TABLE OF FCST_CNTR_MTH_EXPEND%ROWTYPE;
  l_FCST_CNTR_MTH_EXPEND t_FCST_CNTR_MTH_EXPEND;

    TYPE t_FCST_CNTR_ACC_STATUS IS TABLE OF FCST_CNTR_ACC_STATUS%ROWTYPE;
  l_FCST_CNTR_ACC_STATUS t_FCST_CNTR_ACC_STATUS;



-- from-data
CURSOR c_FCST_CNTR_MTH_EXPEND (cp_forecast_id VARCHAR2, cp_from_date DATE, cp_to_date DATE)
IS
	SELECT *
	FROM FCST_CNTR_MTH_EXPEND
	WHERE forecast_id = cp_forecast_id
    AND daytime between cp_from_date and nvl(cp_to_date, daytime);


	CURSOR c_fcst_cntracc_cpy_status (cp_forecast_id VARCHAR2, cp_from_date DATE, cp_to_date DATE)
IS
	SELECT *
	FROM fcst_cntracc_cpy_status
	WHERE forecast_id = cp_forecast_id
    AND daytime between cp_from_date and nvl(cp_to_date, daytime);

		CURSOR c_FCST_CNTR_ACC_STATUS (cp_forecast_id VARCHAR2, cp_from_date DATE, cp_to_date DATE)
IS
	SELECT *
	FROM FCST_CNTR_ACC_STATUS
	WHERE forecast_id = cp_forecast_id
    AND daytime between cp_from_date and nvl(cp_to_date, daytime);

ld_now DATE := ecdp_date_time.getCurrentSysdate;

	p_new_forecast_id VARCHAR2(32) := NULL;
BEGIN
	IF (p_forecast_id IS NULL) THEN
		Raise_Application_Error(-20000,'Missing copy from forecast id');
	END IF;

	createForecast(p_new_forecast_code, p_new_forecast_name, p_start_date, p_end_date, p_new_forecast_id);


  OPEN c_fcst_cntracc_cpy_status (p_forecast_id, p_start_date, p_end_date);
    LOOP
    FETCH c_fcst_cntracc_cpy_status BULK COLLECT INTO l_fcst_cntracc_cpy_status LIMIT 2000;

    FOR i IN 1..l_fcst_cntracc_cpy_status.COUNT LOOP
      l_fcst_cntracc_cpy_status(i).forecast_id := p_new_forecast_id;
      l_fcst_cntracc_cpy_status(i).created_by := ecdp_context.getAppUser;
      l_fcst_cntracc_cpy_status(i).created_date := ld_now;
      l_fcst_cntracc_cpy_status(i).last_updated_by := NULL;
      l_fcst_cntracc_cpy_status(i).last_updated_date := NULL;
    END LOOP;

    FORALL i IN 1..l_fcst_cntracc_cpy_status.COUNT
      INSERT INTO fcst_cntracc_cpy_status VALUES l_fcst_cntracc_cpy_status(i);

    EXIT WHEN c_fcst_cntracc_cpy_status%NOTFOUND;

  END LOOP;
  CLOSE c_fcst_cntracc_cpy_status;


    OPEN c_FCST_CNTR_MTH_EXPEND (p_forecast_id, p_start_date, p_end_date);
    LOOP
    FETCH c_FCST_CNTR_MTH_EXPEND BULK COLLECT INTO l_FCST_CNTR_MTH_EXPEND LIMIT 2000;

    FOR i IN 1..l_FCST_CNTR_MTH_EXPEND.COUNT LOOP
      l_FCST_CNTR_MTH_EXPEND(i).forecast_id := p_new_forecast_id;
      l_FCST_CNTR_MTH_EXPEND(i).created_by := ecdp_context.getAppUser;
      l_FCST_CNTR_MTH_EXPEND(i).created_date := ld_now;
      l_FCST_CNTR_MTH_EXPEND(i).last_updated_by := NULL;
      l_FCST_CNTR_MTH_EXPEND(i).last_updated_date := NULL;
    END LOOP;

    FORALL i IN 1..l_FCST_CNTR_MTH_EXPEND.COUNT
      INSERT INTO FCST_CNTR_MTH_EXPEND VALUES l_FCST_CNTR_MTH_EXPEND(i);

    EXIT WHEN c_FCST_CNTR_MTH_EXPEND%NOTFOUND;

  END LOOP;
  CLOSE c_FCST_CNTR_MTH_EXPEND;


    OPEN c_FCST_CNTR_ACC_STATUS (p_forecast_id, p_start_date, p_end_date);
    LOOP
    FETCH c_FCST_CNTR_ACC_STATUS BULK COLLECT INTO l_FCST_CNTR_ACC_STATUS LIMIT 2000;

    FOR i IN 1..l_FCST_CNTR_ACC_STATUS.COUNT LOOP
      l_FCST_CNTR_ACC_STATUS(i).forecast_id := p_new_forecast_id;
      l_FCST_CNTR_ACC_STATUS(i).created_by := ecdp_context.getAppUser;
      l_FCST_CNTR_ACC_STATUS(i).created_date := ld_now;
      l_FCST_CNTR_ACC_STATUS(i).last_updated_by := NULL;
      l_FCST_CNTR_ACC_STATUS(i).last_updated_date := NULL;
    END LOOP;

    FORALL i IN 1..l_FCST_CNTR_ACC_STATUS.COUNT
      INSERT INTO FCST_CNTR_ACC_STATUS VALUES l_FCST_CNTR_ACC_STATUS(i);

    EXIT WHEN c_FCST_CNTR_ACC_STATUS%NOTFOUND;

  END LOOP;
  CLOSE c_FCST_CNTR_ACC_STATUS;



END copyFromForecast;



--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  InsNewPriceElementSet
-- Description    : Called from class fcst_cntracc_cpy_status used by business function Forecast Contract Price (EC Sales)
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
-- Behaviour      : Inserts into table fcst_cntracc_cpy_status
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


lrec_pp_value fcst_cntracc_cpy_status%ROWTYPE;
ln_inserted NUMBER := 0;
BEGIN



lrec_pp_value := ec_fcst_cntracc_cpy_status.row_by_pk(p_object_id,p_forecast_id, p_price_concept_code,p_price_element_code,p_daytime);

-- Inserting record for each price element


-- Checking if any price element has been inserted
FOR c_val IN c_price_elements(p_price_concept_code) LOOP

ln_inserted := 0;

SELECT count(*)
  INTO ln_inserted
  FROM fcst_cntracc_cpy_status
 WHERE object_id = p_object_id
   AND forecast_id = p_forecast_id
   AND price_concept_code = p_price_concept_code
   AND price_element_code = c_val.price_element_code
   AND daytime = p_daytime;

    -- One record is already inserted
    IF  (ln_inserted = 0)  THEN

      INSERT
      INTO     fcst_cntracc_cpy_status (forecast_id, object_id,price_concept_code,price_element_code,daytime,price_value,adj_price_value,comments,created_by)
      VALUES   (p_forecast_id, p_object_id,p_price_concept_code, c_val.price_element_code,p_daytime,lrec_pp_value.price_value,lrec_pp_value.adj_price_value,lrec_pp_value.comments,lrec_pp_value.created_by);
    END IF;
END LOOP;


END InsNewPriceElementSet;*/



END ECDP_Forecast_Sale_Sa;