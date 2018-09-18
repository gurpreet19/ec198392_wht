CREATE OR REPLACE PACKAGE ue_Inventory IS
/****************************************************************
** Package        :  ue_Inventory, header part
**
** $Revision: 1.3 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created  : 11.05.2009
**
** Modification history:
**
** Version  Date         Whom   Change description:
** -------  ------       -----  --------------------------------------
******************************************************************/

isGenMthBookingDataUEEnabled  VARCHAR2(32) := 'FALSE';
isCalcPricingValueUEEnabled   VARCHAR2(32) := 'FALSE';
isCalcCurrencyValuesUEEnabled VARCHAR2(32) := 'FALSE';
isValidateInventoryPreUEE     VARCHAR2(32) := 'FALSE';
isValidateInventoryUEE        VARCHAR2(32) := 'FALSE';
isValidateInventoryPostUEE    VARCHAR2(32) := 'FALSE';

PROCEDURE GenMthBookingData(p_object_id VARCHAR2
       ,p_daytime   DATE
       ,p_user      VARCHAR2);

PROCEDURE CalcPricingValue(p_object_id VARCHAR2, p_daytime DATE, p_user VARCHAR2);

PROCEDURE CalcCurrencyValues(p_object_id VARCHAR2, p_daytime DATE, p_user VARCHAR2);

PROCEDURE ValidateInventoryPre(p_object_id VARCHAR2,
                               p_daytime DATE);

PROCEDURE ValidateInventory(p_object_id VARCHAR2,
                            p_daytime DATE);

PROCEDURE ValidateInventoryPost(p_object_id VARCHAR2,
                                p_daytime DATE);

END ue_Inventory;