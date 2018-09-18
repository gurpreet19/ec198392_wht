CREATE OR REPLACE PACKAGE EcDp_Cost IS
/****************************************************************
** Package        :  EcDp_Cost, header part
**
** $Revision: 1.6 $
**
** Purpose        :  Support functionality for Cost of Service etc.
**
** Documentation  :  www.energy-components.com
**
** Created  : 31.08.2010  Stian Skj?restad
**
** Modification history:
**
** Version  Date        Whom  Change description:
** -------  ------      ----- --------------------------------------
*****************************************************************/


PROCEDURE InstantiateMth(p_object_id VARCHAR2,
                         p_daytime   DATE,
                         p_user      VARCHAR2);

PROCEDURE InstantiateYear(p_object_id VARCHAR2,
                         p_daytime   DATE,
                         p_user      VARCHAR2);

PROCEDURE CalculateMth(p_object_id VARCHAR2,
                       p_daytime   DATE,
                       p_user      VARCHAR2);

PROCEDURE CalculateYear(p_object_id VARCHAR2,
                        p_daytime   DATE,
                        p_user      VARCHAR2);

FUNCTION GetRunningCapitalCost(
                    p_trans_inv_id VARCHAR2,
                    p_daytime DATE)
RETURN NUMBER;

FUNCTION GetOperatingCharge(
                    p_trans_inv_id VARCHAR2,
                    p_daytime DATE,
                    p_period VARCHAR2)
RETURN NUMBER;

FUNCTION GetReturnOnCapital(
                    p_trans_inv_id VARCHAR2,
                    p_daytime DATE,
                    p_starting_balance NUMBER DEFAULT NULL,
                    p_ending_balance NUMBER DEFAULT NULL,
                    p_period VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION GetAdditionMethod(p_daytime   DATE,
                         p_object_id VARCHAR2,
                         p_ytd_value NUMBER DEFAULT NULL) RETURN VARCHAR2;

FUNCTION GetYearThreshold(p_daytime DATE, p_object_id VARCHAR2) RETURN NUMBER;

FUNCTION GetRequiredAction(p_daytime   DATE,
                         p_object_id VARCHAR2,
                         p_ytd_value NUMBER DEFAULT NULL) RETURN VARCHAR2;

FUNCTION GetRequiredActionYR(p_daytime   DATE,
                         p_object_id VARCHAR2,
                         p_ytd_value NUMBER DEFAULT NULL) RETURN VARCHAR2;

END EcDp_Cost;