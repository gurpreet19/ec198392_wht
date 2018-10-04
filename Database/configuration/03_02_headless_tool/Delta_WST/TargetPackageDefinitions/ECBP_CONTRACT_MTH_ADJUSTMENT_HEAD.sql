CREATE OR REPLACE PACKAGE EcBp_Contract_Mth_Adjustment IS
/******************************************************************************
** Package        :  EcBp_Contract_Mth_Adjustment, header part
**
** $Revision: 1.1 $
**
** Purpose        :  Handles validation for screen Monthly Contract Allocation Ajustment
**
** Documentation  :  www.energy-components.com
**
** Created        : 15.12.2005 Stian Skjørestad
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------

********************************************************************/

FUNCTION getAllocatedCompanyAdjustedVol (p_company_id VARCHAR2,
                                 p_object_id  VARCHAR2,
                                 p_daytime    DATE
)
RETURN NUMBER;

PROCEDURE validateAdjustment (p_company_id VARCHAR2,p_object_id  VARCHAR2,p_daytime    DATE);
PROCEDURE validateTotalAdjustment (p_company_id VARCHAR2, p_daytime    DATE);

END EcBp_Contract_Mth_Adjustment;