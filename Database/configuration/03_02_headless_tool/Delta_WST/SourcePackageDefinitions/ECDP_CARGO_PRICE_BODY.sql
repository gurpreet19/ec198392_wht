CREATE OR REPLACE PACKAGE BODY EcDp_Cargo_Price IS
/******************************************************************************
** Package        :  EcDp_Cargo_Price, body part
**
** $Revision: 1.3 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created        :  05.21.2007 Imelda Anggraeny Ismailputri
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
** 01-12-08 leeeewei ECPD-10167: Added new procedure InsNewPriceElementSet
** 21.04.15	  leeeewei	added parameter p_price_category in InsNewPriceElementSet
********************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCargoParcelName
-- Description    : Returns cargo name combine with parcel_no, separated by '/ '
--
-- Preconditions  : p_parcel_key is not null
-- Postconditions :
--
-- Using tables   : storage_lift_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getCargoParcelName(
	p_parcel_key VARCHAR2
)
RETURN VARCHAR2
--</EC-DOC>
IS

	ls_cargo_parcel_name varchar2(300);

BEGIN
	SELECT Decode(Replace(ec_cargo_transport.cargo_name(CARGO_NO) || ' / ' || ec_storage_lift_nomination.nom_sequence(parcel_no) , ' / '),
		NULL, NULL,ec_cargo_transport.cargo_name(CARGO_NO) || ' / ' || ec_storage_lift_nomination.nom_sequence(parcel_no))
	INTO ls_cargo_parcel_name
	FROM storage_lift_nomination
	WHERE parcel_no = p_parcel_key;

	RETURN ls_cargo_parcel_name;

END getCargoParcelName;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : InsNewPriceElementSet
-- Description    : Called from class cargo_price_list used by business function Cargo Price List
--                  Depending on selected price object, this procedure creates a record for each price concept element defined on the price concept.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : price_concept_element, product_price_value
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Inserts into table product_price_value
--
-----------------------------------------------------------------------------------------------------------------------
PROCEDURE InsNewPriceElementSet(
    p_parcel_key                VARCHAR2,
    p_object_id                 VARCHAR2,
    p_price_concept_code        VARCHAR2,
    p_price_element_code        VARCHAR2,
    p_daytime                   DATE,
	p_price_category            VARCHAR2,
    p_user                      VARCHAR2
)
--<EC-DOC>
IS

CURSOR c_price_elements (cp_price_concept_code VARCHAR2) IS
       SELECT price_element_code
       FROM   price_concept_element
       WHERE  price_concept_code = cp_price_concept_code;


lrec_pp_value product_price_value%ROWTYPE;
ln_inserted NUMBER := 0;

BEGIN

lrec_pp_value := ec_product_price_value.row_by_pk(p_object_id,p_price_concept_code,p_price_element_code,p_daytime,p_price_category);

-- Inserting record for each price element
-- Checking if any price element has been inserted

FOR c_val IN c_price_elements(p_price_concept_code) LOOP

ln_inserted := 0;

SELECT count(*)
  INTO ln_inserted
  FROM product_price_value ppv
 WHERE object_id = p_object_id
   AND price_concept_code = p_price_concept_code
   AND daytime = p_daytime
   AND price_element_code = c_val.price_element_code
   AND ppv.parcel_key = p_parcel_key
   AND ppv.price_category = p_price_category;


    -- One record is already inserted
    IF  (ln_inserted = 0)  THEN

      INSERT
      INTO     product_price_value (parcel_key,object_id,price_concept_code,price_element_code,daytime, price_category, calc_price_value,adj_price_value,comments,created_by)
      VALUES   (p_parcel_key, p_object_id,p_price_concept_code, c_val.price_element_code,p_daytime, p_price_category, lrec_pp_value.calc_price_value,lrec_pp_value.adj_price_value,lrec_pp_value.comments,lrec_pp_value.created_by);
    END IF;

END LOOP;

END InsNewPriceElementSet;

END EcDp_Cargo_Price;