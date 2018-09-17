CREATE OR REPLACE PACKAGE BODY EcDp_Price IS
/****************************************************************
** Package        :  EcDp_Price, body part
**
** $Revision: 1.15 $
**
** Purpose        :  Provide special functions on Price objects. Use EcDp_Objects for basis functions
**
** Documentation  :  www.energy-components.com
**
** Created  : 27.11.2005  Trond-Arne Brattli
**
** Modification history:
**
** Version  Date         Whom  Change description:
** -------  ----------   ----- --------------------------------------
******************************************************************/


FUNCTION GetPriceStructVal(
   p_object_id VARCHAR2,
   p_daytime   DATE
) RETURN NUMBER

IS
/*
CURSOR c_price_elem IS
SELECT to_object_id id
FROM objects_relation x
WHERE from_class_name = 'PRICE_CONCEPT'
  AND to_class_name = 'PRICE_ELEMENT'
  AND role_name = 'PRICE_CONCEPT'
  AND p_daytime >= Nvl(start_date,p_daytime-1)
  AND p_daytime < Nvl(end_date,p_daytime+1)
  AND EXISTS
      (SELECT 'x' FROM objects_relation
      WHERE from_object_id = x.from_object_id
        AND to_object_id = p_object_id
        AND role_name = 'PRICE_CONCEPT'
        AND p_daytime >= Nvl(start_date,p_daytime-1)
        AND p_daytime < Nvl(end_date,p_daytime+1)
      )
  AND NOT EXISTS
      (SELECT 'x' FROM objects_relation WHERE to_object_id = x.to_object_id
                AND role_name = 'SUM_GROUP' AND from_class_name = 'PRICE_ELEMENT'
      );

ln_return_val NUMBER;
*/
BEGIN
	Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
  RETURN NULL;
/*
     FOR PriceElemCur IN c_price_elem LOOP

         ln_return_val := Nvl(ln_return_val,0) + nvl(GetPriceElemVal(PriceElemCur.id, p_object_id, p_daytime),0);

     END LOOP;

     RETURN ln_return_val;
*/
END GetPriceStructVal;

FUNCTION IsPriceElemSumGroup(
   p_object_id VARCHAR2, -- price element
   p_daytime   DATE
) RETURN VARCHAR2

IS
/*
CURSOR c_child IS
SELECT to_object_id id
FROM objects_relation x
WHERE role_name = 'SUM_GROUP'
  AND from_object_id = p_object_id
  AND to_class_name = 'PRICE_ELEMENT'
  AND p_daytime >= Nvl(start_date,p_daytime-1)
  AND p_daytime < Nvl(end_date,p_daytime+1);

lv2_return_val VARCHAR2(1) := 'N';
*/
BEGIN
	Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
  RETURN NULL;
/*
     FOR ChldCur IN c_child LOOP

         lv2_return_val := 'Y';

         EXIT; -- no need to continue

     END LOOP;

     RETURN lv2_return_val;
*/
END IsPriceElemSumGroup;

FUNCTION GetPriceElemVal(
   p_price_elem_id VARCHAR2, -- price element
   p_price_struct_id VARCHAR2,
   p_daytime   DATE
) RETURN NUMBER

IS
/*
CURSOR c_child IS
SELECT to_object_id id
FROM objects_relation x
WHERE from_object_id = p_price_elem_id -- price element
  AND role_name = 'SUM_GROUP'
  AND to_class_name = 'PRICE_ELEMENT'
  AND p_daytime >= Nvl(start_date,p_daytime-1)
  AND p_daytime < Nvl(end_date,p_daytime+1)
  ;

ib_found BOOLEAN := FALSE;

lv2_basis_price_elem_id objects.object_id%TYPE;

ln_factor NUMBER;
ln_return_val NUMBER;
lv2_price_basis VARCHAR2(32);
lv2_factor_basis VARCHAR2(32);

lrec_prcl prcl_mth_value%ROWTYPE := ec_prcl_mth_value.row_by_pk(p_price_elem_id, p_price_struct_id, p_daytime, '<=');
*/
BEGIN
	Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
  RETURN NULL;
/*
   -- check if SUM_GROUP, if so calculate and add up for each child
   FOR ChildCur IN c_child LOOP

       ib_found := TRUE;

       ln_return_val := Nvl(ln_return_val,0) + GetPriceElemVal(ChildCur.id, p_price_struct_id, p_daytime);

   END LOOP;

   IF NOT ib_found THEN

      lv2_price_basis := lrec_prcl.price_basis_code;

         IF Nvl(lv2_price_basis,'XXX') = 'FACTOR' THEN

            -- CODE is stored in table, must be converted to corresponding id
            lv2_factor_basis := lrec_prcl.factor_basis;
            lv2_basis_price_elem_id := EcDp_Objects.GetObjIDFromCode('PRICE_ELEMENT', lv2_factor_basis, p_daytime);

            IF lv2_basis_price_elem_id IS NOT NULL THEN

               ln_factor := lrec_prcl.factor;

               ln_return_val :=  Nvl( ln_factor, 1) * GetPriceElemVal(lv2_basis_price_elem_id, p_price_struct_id, p_daytime);

            END IF;

          ELSE

             ln_return_val := lrec_prcl.price_value;

          END IF;

    END IF;

    RETURN ln_return_val;
*/
END GetPriceElemVal;






PROCEDURE InstantiateMth(
   p_daytime DATE
   ,p_user VARCHAR2
   )

IS
/*
  NoDaytime EXCEPTION ;

CURSOR c_price_struct IS
SELECT object_id id
FROM objects x
WHERE class_name = 'PRICE_STRUCT'
  AND p_daytime >= Nvl(start_date,p_daytime-1)
  AND p_daytime < Nvl(end_date,p_daytime+1)
  AND NOT EXISTS
     (SELECT 'x' FROM prcl_mth_value WHERE price_struct_object_id = x.object_id AND daytime = p_daytime);
*/
BEGIN
	Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
/*
   IF (p_daytime IS NULL) THEN
       RAISE NoDaytime;
   END IF;

   -- instantiate price element value
   FOR PrcCur IN c_price_struct LOOP

        InsNewPriceElementSet(PrcCur.id, p_daytime, p_user);

   END LOOP;

EXCEPTION

         WHEN NoDaytime THEN
              RAISE_APPLICATION_ERROR(-20000,'Daytime not present when instantiation');
*/
END InstantiateMth;

PROCEDURE DeletePriceRevision
(  p_object_id VARCHAR2,
   p_daytime DATE
)

IS

BEGIN
	Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
/*
      DELETE FROM cont_price_element_value
      WHERE object_id = p_object_id
      AND daytime = p_daytime;
*/
END DeletePriceRevision;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : ValidateInUse
-- Description    :  When trying to modify a price object, this procedure check if price values exists for the given price object.
--                   In that case, modification of product and price concept is prohibited.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE ValidateInUse(p_object_id          VARCHAR2,
                        p_price_concept_code VARCHAR2,
                        p_product_id       VARCHAR2,
                        p_daytime            DATE)

IS

CURSOR c_price_value (cp_object_id VARCHAR2, cp_price_concept_code VARCHAR2, cp_product_code VARCHAR2, cp_daytime DATE)  IS
SELECT 1
  FROM product_price_value p, product_price pp, product_price_version ppv
 WHERE p.object_id = cp_object_id
   AND p.object_id = pp.object_id
   AND pp.object_id = ppv.object_id
   AND cp_daytime >= ppv.daytime
   AND cp_daytime < nvl(ppv.end_date, cp_daytime + 1)
   AND cp_daytime >= Nvl(pp.start_date, cp_daytime - 1)
   AND cp_daytime < Nvl(pp.end_date, cp_daytime + 1)
   AND (p.price_concept_code <> cp_price_concept_code OR ec_product.object_code(ec_product_price.product_id(cp_object_id)) <>
       cp_product_code);


BEGIN



FOR c_val IN c_price_value (p_object_id, p_price_concept_code, ec_product.object_code(p_product_id), p_daytime) LOOP

Raise_Application_Error(-20601, '');

END LOOP;


END ValidateInUse;

PROCEDURE InsNewPriceObjectValue(
       p_object_id VARCHAR2
       ,p_price_concept_code VARCHAR2
       ,p_price_element_code VARCHAR2
       ,p_daytime DATE
	   ,p_price_category VARCHAR2)
IS
lrec_product_price product_price%ROWTYPE;
lrec_product_price_value product_price_value%ROWTYPE;
BEGIN

     lrec_product_price := ec_product_price.row_by_object_id(p_object_id);
     lrec_product_price_value := ec_product_price_value.row_by_pk(p_object_id, p_price_concept_code, p_price_element_code, p_daytime,p_price_category);

     IF (lrec_product_price_value.object_id IS NULL) THEN
         -- Insert new version
         INSERT INTO product_price_value ppv
         (object_id
         ,price_concept_code
         ,price_element_code
         ,daytime
		 ,price_category
         ,calc_price_value
         ,adj_price_value
         ,comments)
         SELECT object_id
         ,price_concept_code
         ,price_element_code
         ,p_daytime
		 ,p_price_category
         ,calc_price_value
         ,adj_price_value
         ,comments FROM product_price_value ppv
         WHERE object_id = p_object_id
         AND ppv.price_concept_code = p_price_concept_code
         AND ppv.price_element_code = p_price_element_code
         AND lrec_product_price.price_concept_code = ppv.price_concept_code
         AND  daytime = (SELECT max(daytime) FROM product_price_value WHERE object_id = ppv.object_id
                         AND price_concept_code = ppv.price_concept_code
                         AND price_element_code = ppv.price_element_code
                         AND daytime <= p_daytime);
     END IF;

END InsNewPriceObjectValue;

FUNCTION getUnitPrice(
    p_object_id VARCHAR2 -- PriceObject ID
    ,p_price_concept VARCHAR2
    ,p_price_element VARCHAR2
    ,p_daytime DATE
) RETURN NUMBER
IS

CURSOR c_derived_price(cp_price_object_id VARCHAR2, cp_price_concept_code VARCHAR2, cp_price_element_code VARCHAR2) IS
SELECT pvs.*
FROM price_value_setup pvs
WHERE pvs.object_id = cp_price_object_id
AND   pvs.price_concept_code = cp_price_concept_code
AND   pvs.price_element_code = cp_price_element_code
AND   pvs.daytime <= p_daytime
AND   NVL(pvs.end_date, p_daytime + 1) >= p_daytime
ORDER BY pvs.daytime;

CURSOR c_price(cp_price_object_id VARCHAR2, cp_price_concept_code VARCHAR2, cp_price_element_code VARCHAR2) IS
SELECT pvv.*
FROM product_price_value pvv
WHERE pvv.object_id = cp_price_object_id
AND   pvv.price_concept_code = cp_price_concept_code
AND   pvv.price_element_code = cp_price_element_code
AND   pvv.daytime <= p_daytime
ORDER BY pvv.daytime;

ln_price NUMBER := NULL;
ln_derived_price NUMBER := NULL;

BEGIN
    -- Factor based price
    FOR CurFactor IN c_derived_price(p_object_id, p_price_concept, p_price_element) LOOP
        ln_derived_price := getUnitPrice(CurFactor.object_id, CurFactor.Src_Price_Concept_Code, CurFactor.Src_Price_Element_Code, p_daytime);
        ln_price := CurFactor.Factor * ln_derived_price;
    END LOOP;

    -- Normal price
    IF (ln_price IS NULL) THEN
        FOR CurPrice IN c_price(p_object_id, p_price_concept, p_price_element) LOOP
            ln_price := CurPrice.adj_price_value;
            IF (ln_price IS NULL) THEN
                ln_price := CurPrice.calc_price_value;
            END IF;
        END LOOP;
    END IF;

    RETURN ln_price;
END getUnitPrice;

FUNCTION isEditable(
    p_object_id VARCHAR2 -- PriceObject ID
    ,p_price_concept VARCHAR2
    ,p_price_element VARCHAR2
    ,p_daytime DATE
) RETURN VARCHAR2
IS

lv2_editable VARCHAR2(32) := 'true';

CURSOR c_derived_price(cp_price_object_id VARCHAR2, cp_price_concept_code VARCHAR2, cp_price_element_code VARCHAR2) IS
SELECT pvs.*
FROM price_value_setup pvs
WHERE pvs.object_id = cp_price_object_id
AND   pvs.price_concept_code = cp_price_concept_code
AND   pvs.price_element_code = cp_price_element_code
AND   pvs.daytime <= p_daytime
AND   NVL(pvs.end_date, p_daytime + 1) >= p_daytime;

BEGIN
    -- Factor based price
    FOR CurFactor IN c_derived_price(p_object_id, p_price_concept, p_price_element) LOOP
        lv2_editable := 'false';
    END LOOP;

    RETURN lv2_editable;

END isEditable;




--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : EndDateCheck
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE EndDateCheck(p_object_id          VARCHAR2,
                       p_end_date           DATE,
                       p_daytime            DATE
                       )

IS
	lv_end_date			DATE ;
	lv_start_date    DATE;

	CURSOR c_object IS
	 SELECT end_date, start_date
	 FROM OBJECTS
	 WHERE object_id = p_object_id;

BEGIN

	 FOR cur_object IN c_object LOOP

		lv_end_date := cur_object.end_date;
		lv_start_date := cur_object.start_date;

	 END LOOP;


	IF p_end_date < lv_start_date THEN
    	Raise_Application_Error(-20000,'The start date of the contract is greater than the end date of price object' );
   END IF;
	IF p_end_date > lv_end_date THEN
    	Raise_Application_Error(-20000,'The end date of the contract is smaller than the end date of price object' );
   END IF;
  IF p_end_date < p_daytime THEN
    	Raise_Application_Error(-20000,'The end date must be bigger than daytime' );
  END IF;
END EndDateCheck;

END EcDp_Price;