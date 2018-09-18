CREATE OR REPLACE PACKAGE EcDp_Price IS
/****************************************************************
** Package        :  EcDp_Price, header part
**
** $Revision: 1.15 $
**
** Purpose        :  Provide special functions on Price Objects. Use EcDp_Objects for basis functions
**
** Documentation  :  www.energy-components.com
**
** Created  : 27.11.2005  Trond-Arne Brattli
**
** Modification history:
**
** Version  Date        Whom  Change description:
** -------  ------      ----- --------------------------------------
** 1.2      2006-11-23  SSK   Modified getAnyPriceElement to review actual price element used in product_price_value for current price_object/price_concept
                              Moved InsNewPriceElementSet to transport package EcDp_Sales_Contract_Price
**          2009-01-23  leeeewei Added order by clause to getUnitPrice cursors
*****************************************************************/

FUNCTION GetPriceStructVal(
   p_object_id VARCHAR2,
   p_daytime   DATE
)

RETURN NUMBER;


FUNCTION GetPriceElemVal(p_price_elem_id   VARCHAR2, -- price element
                         p_price_struct_id VARCHAR2,
                         p_daytime         DATE)

RETURN NUMBER;



PROCEDURE InstantiateMth(p_daytime DATE, p_user VARCHAR2);




FUNCTION IsPriceElemSumGroup(p_object_id VARCHAR2, -- price element
                             p_daytime   DATE) RETURN VARCHAR2;



PROCEDURE DeletePriceRevision(p_object_id VARCHAR2, p_daytime DATE);

PROCEDURE EndDateCheck(p_object_id          VARCHAR2,
                       p_end_date           DATE,
                       p_daytime            DATE
                       );

PROCEDURE ValidateInUse(p_object_id          VARCHAR2,
                        p_price_concept_code VARCHAR2,
                        p_product_id         VARCHAR2,
                        p_daytime            DATE);

PROCEDURE InsNewPriceObjectValue(
       p_object_id VARCHAR2
       ,p_price_concept_code VARCHAR2
       ,p_price_element_code VARCHAR2
       ,p_daytime DATE
	   ,p_price_category VARCHAR2)
;

FUNCTION getUnitPrice(
    p_object_id VARCHAR2 -- PriceObject ID
    ,p_price_concept VARCHAR2
    ,p_price_element VARCHAR2
    ,p_daytime DATE
) RETURN NUMBER
;

FUNCTION isEditable(
    p_object_id VARCHAR2 -- PriceObject ID
    ,p_price_concept VARCHAR2
    ,p_price_element VARCHAR2
    ,p_daytime DATE
) RETURN VARCHAR2
;

END EcDp_Price;