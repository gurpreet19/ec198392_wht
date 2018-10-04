CREATE OR REPLACE PACKAGE EcDp_Contract_Availability IS
/****************************************************************
** Package        :  EcDp_Contract_Availability
**
** $Revision: 1.3 $
**
** Purpose        :  Retrieves the calculated quantity with UOM corresponding to available quantity attribute/column
**
** Documentation  :  www.energy-components.com
**
** Created  : 22.12.2005  Stian Skjørestad
**
** Modification history:
**
** Date       Whom  	 Change description:
** --------   ----- 	--------------------------------------

******************************************************************/

FUNCTION getCalculatedQty(
	p_object_id			VARCHAR2,
	p_delivery_point_id	VARCHAR2,
	p_daytime			DATE,
	p_comparator_uom	VARCHAR2
)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getCalculatedQty, WNDS, WNPS, RNPS);


END EcDp_Contract_Availability;