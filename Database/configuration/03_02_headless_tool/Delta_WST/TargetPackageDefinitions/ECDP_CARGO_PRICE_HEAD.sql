CREATE OR REPLACE PACKAGE EcDp_Cargo_Price IS
/******************************************************************************
** Package        :  EcDp_Cargo_Price, head part
**
** $Revision: 1.2 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created        :  05.21.2007 Imelda Anggraeny Ismailputri
**
** Modification history:
**
** Date        Whom  	Change description:
** ------      ----- 	-------------------------------------------------------
** 01-12-2008 leeeewei ECPD-10167: Added new procedure InsNewPriceElementSet
********************************************************************/

FUNCTION getCargoParcelName(
  	p_parcel_key VARCHAR2
)
RETURN VARCHAR2;

PROCEDURE InsNewPriceElementSet(
    p_parcel_key                VARCHAR2,
    p_object_id                 VARCHAR2,
    p_price_concept_code        VARCHAR2,
    p_price_element_code        VARCHAR2,
    p_daytime                   DATE,
    p_user                      VARCHAR2
);

END EcDp_Cargo_Price;