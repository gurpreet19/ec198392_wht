CREATE OR REPLACE PACKAGE BODY ECDP_ROYALTY_CONTRACT IS
/**************************************************************************************************
** Package  :  ECDP_ROYALTY_CONTRACT
**
** $Revision: 1.1 $
**
** Purpose  :  Data package for Forecasting
**
**
**
** General Logic:
**
** Created  : 21.04.2014 Kenneth Masamba
**
** Modification history:
**
** Date:       Whom: Rev.  Change description:
** ----------  ----- ----  ------------------------------------------------------------------------
** 06.12.2014  masamken   1.1
**************************************************************************************************/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validateOverlappingPeriod
-- Description    : This procedure will check for overlapping period for for the well setup
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : WELL_SETUP
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateOverlappingPeriod(p_object_id   VARCHAR2,
                                    p_perf_int_id VARCHAR2,
                                    p_daytime     DATE,
                                    p_end_date    DATE,
                                    p_class_name  VARCHAR2
                                    )
IS

  ln_counter NUMBER;

BEGIN

  SELECT COUNT(*) INTO ln_counter
  FROM WELL_SETUP A
    WHERE A.OBJECT_ID = p_object_id
     AND A.PERF_INTERVAL_ID = p_perf_int_id
     AND A.DAYTIME <> p_daytime
     AND (A.END_DATE >= p_daytime OR A.END_DATE IS NULL)
     AND (A.DAYTIME < p_end_date OR p_end_date IS NULL)
     AND A.CLASS_NAME = p_class_name;

  IF ln_counter > 0 THEN
    RAISE_APPLICATION_ERROR(-20637, 'Connection overlaps with an existing period');
  END IF;

END validateOverlappingPeriod;

---------------------------------------------------------------------------------------------------
-- Procedure      : validateEndDate
-- Description    : This procedure will validates end date, the end date should not be greater than the object
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : WELL_SETUP
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateEndDate(p_object_id   VARCHAR2,
                                    p_perf_int_id VARCHAR2,
                                    p_daytime     DATE,
                                    p_end_date    DATE
                                    )
IS

  ln_counter NUMBER;

BEGIN

  SELECT COUNT(*) INTO ln_counter
  FROM objects A
    WHERE ((A.END_DATE >= nvl(p_end_date,A.END_DATE)) OR A.END_DATE IS NULL)
      AND A.OBJECT_ID = p_object_id;

  IF ln_counter = 0 THEN
    RAISE_APPLICATION_ERROR(-20638, 'Iligal end date');
  END IF;

END validateEndDate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : instProducts
-- Description    : This Procedure will INSTATIATE Product Group components in the Royalty Screen Products Tab
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
PROCEDURE instProducts(p_daytime DATE, p_contract_id VARCHAR2)
--</EC-DOC>
IS

  CURSOR CUR_PROD_GROUP(cp_daytime DATE, cp_location_id VARCHAR2) IS
    SELECT P.OBJECT_ID,
           P.DAYTIME,
           P.END_DATE,
           P.PRODUCT_ID
      FROM PRODUCT_GROUP_SETUP P;
  lv2_appuser          VARCHAR2(30):=Nvl(EcDp_Context.getAppUser,User);
  ln_product_counter      NUMBER;
  ln_product_counter_data NUMBER;

BEGIN

    SELECT COUNT (P.OBJECT_ID) INTO ln_product_counter
      FROM PRODUCT_GROUP_SETUP P;

    SELECT COUNT(OBJECT_ID) into ln_product_counter_data
      FROM CNTR_PG_SETUP C
        WHERE CONTRACT_ID = p_contract_id
          AND DAYTIME < p_daytime
            AND p_daytime < NVL(END_DATE, p_daytime+1/(24*60*60));

  IF ln_product_counter > 0 THEN
	  INSERT INTO CNTR_PG_SETUP C (C.OBJECT_ID, C.DAYTIME, C.END_DATE, C.PRODUCT_ID, C.CONTRACT_ID, CREATED_BY)
	    SELECT P.OBJECT_ID, p_daytime, P.END_DATE, P.PRODUCT_ID, p_contract_id, lv2_appuser
	    FROM PRODUCT_GROUP_SETUP P
	     WHERE P.DAYTIME <= p_daytime
	      AND p_daytime < Nvl(P.END_DATE, p_daytime + 1/(24*60*60));

	    IF ln_product_counter_data > 0 THEN
		  UPDATE CNTR_PG_SETUP C
		    SET  END_DATE = p_daytime, REV_NO = NVL2(REV_NO, REV_NO+1, 0), LAST_UPDATED_BY =  lv2_appuser
		      WHERE CONTRACT_ID = p_contract_id
		        AND DAYTIME < p_daytime
		          AND p_daytime < NVL(END_DATE, p_daytime+1/(24*60*60));
	    END IF;

  END IF;


END instProducts;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : instProducts
-- Description    : This Procedure will update version product group values in the Royalty Screen Products Tab
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
PROCEDURE updateProducts(p_daytime DATE, p_product_group_id VARCHAR2, p_contract_id VARCHAR2, p_rty_base_volume VARCHAR2, p_use_ind VARCHAR2)
--</EC-DOC>
IS

  CURSOR CUR_PROD_GROUP(cp_daytime DATE, cp_location_id VARCHAR2) IS
    SELECT P.OBJECT_ID,
           P.DAYTIME,
           P.END_DATE,
           P.PRODUCT_ID
      FROM PRODUCT_GROUP_SETUP P;

BEGIN

  UPDATE CNTR_PG_SETUP C SET C.RTY_BASE_VOLUME = p_rty_base_volume, USE_IND = p_use_ind
    WHERE C.OBJECT_ID = p_product_group_id
      AND C.DAYTIME = p_daytime
      AND C.CONTRACT_ID = p_contract_id;

END updateProducts;

END ECDP_ROYALTY_CONTRACT;