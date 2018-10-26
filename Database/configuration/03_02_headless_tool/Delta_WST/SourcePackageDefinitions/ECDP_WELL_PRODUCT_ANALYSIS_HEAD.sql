CREATE OR REPLACE PACKAGE EcDp_Well_Product_Analysis IS
/****************************************************************
** Package      :  EcDp_Well_Product_Analysis, header part
**
** $Revision: 1.2 $
**
** Purpose      :
**
**
** Documentation:  www.energy-components.com
**
** Created      : 21.10.2013  wonggkai
**
** Modification history:
**
** Version      Date        whom    Change description:
** -------      ----------- -----------------------------------
**  1.0         21-10-2013  wonggkai ECPD-25327: Initial Version
*****************************************************************/

FUNCTION getYieldFactor(p_well_object_id VARCHAR2, p_daytime date, p_product_id VARCHAR2)
RETURN NUMBER;

PROCEDURE deleteAnalysisDetail(p_well_object_id VARCHAR2, p_daytime date);

END;