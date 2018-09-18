CREATE OR REPLACE PACKAGE EcBp_Price_Value IS
/******************************************************************************
** Package        :  EcBp_Price_Value, head part
**
** $Revision: 1.1 $
**
** Purpose        :  working with price_values
**
** Documentation  :  www.energy-components.com
**
** Created        :  05.12.2005 Jean Ferre
**
** Modification history:
**
** Date        Whom  	Change description:
** ------      ----- 	-------------------------------------------------------
** 03.01.06		eideekri	added procedure setPriceConceptCode
** 21.04.15		leeeewei	added paramter p_price_category in validateDelete
********************************************************************/

PROCEDURE validateDelete(
  	p_object_id   				VARCHAR2,
  	p_price_concept_code   	VARCHAR2,
  	p_price_element_code    VARCHAR2,
	p_daytime					DATE,
	p_price_category 		VARCHAR2
);

END EcBp_Price_Value;