CREATE OR REPLACE PACKAGE EcDp_ContractDay IS
/****************************************************************
** Package        :  EcDp_ProductionDay, header part
**
** $Revision: 1.11 $
**
** Purpose        :  DUMMY version will be replaced after code freeze
**
** Documentation  :  www.energy-components.com
**
** Created  : 28.04.2006  Arild Vervik
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------
** 28.04.2006  AV     Initial version
*****************************************************************/

FUNCTION findContractDayDefinition(p_class_name VARCHAR2, p_object_id  VARCHAR2, p_daytime  DATE)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(findContractDayDefinition, WNDS, WNPS, RNPS);

--
FUNCTION findProductionDayDefinition(p_class_name VARCHAR2, p_object_id  VARCHAR2, p_daytime  DATE)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(findProductionDayDefinition, WNDS, WNPS, RNPS);

--


FUNCTION getProductionDay(p_class_name VARCHAR2, p_object_id  VARCHAR2, p_daytime  DATE, p_summertime_flag VARCHAR2 DEFAULT NULL)
RETURN DATE;

PRAGMA RESTRICT_REFERENCES(getProductionDay, WNDS, WNPS, RNPS);

--


FUNCTION getProductionDayOffset(p_class_name VARCHAR2, p_object_id VARCHAR2, p_daytime DATE, p_summer_time VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getProductionDayOffset, WNDS, WNPS, RNPS);

--

PROCEDURE validateDaytimeVsFreq(p_class_name VARCHAR2,
                                p_object_id  VARCHAR2,
                                p_daytime  DATE,
                                p_summertime_flag VARCHAR2
                                );
PRAGMA RESTRICT_REFERENCES(validateDaytimeVsFreq, WNDS, WNPS, RNPS);
--

FUNCTION findSubDailyFreq(p_class_name  VARCHAR2,
                          p_object_id   VARCHAR2,
                          p_daytime     DATE
                         )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(findSubDailyFreq, WNDS, WNPS, RNPS);

--

FUNCTION getProductionDayDaytimes(p_class_name  VARCHAR2,
                                  p_object_id   VARCHAR2,
                                  p_day         DATE)
RETURN Ecdp_Date_Time.Ec_Unique_Daytimes;
PRAGMA RESTRICT_REFERENCES(getProductionDayDaytimes, WNDS, WNPS, RNPS);
--

FUNCTION getProductionDayFraction(p_class_name        VARCHAR2,
                                  p_object_id         VARCHAR2,
                                  p_day               DATE,
                                  p_from_daytime      DATE,
                                  p_from_summer_time  VARCHAR2,
                                  p_to_daytime        DATE,
                                  p_to_summer_time    VARCHAR2
                                  )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getProductionDayFraction, WNDS, WNPS, RNPS);

--

FUNCTION getProductionDayStartTime(p_class_name VARCHAR2,
                                   p_object_id  VARCHAR2,
                                   p_day        DATE
                                   )
RETURN Ecdp_Date_Time.Ec_Unique_Daytime;

PRAGMA RESTRICT_REFERENCES(getProductionDayStartTime, WNDS, WNPS, RNPS);


FUNCTION getProductionDayStart(p_class_name VARCHAR2,
                                   p_object_id  VARCHAR2,
                                   p_day        DATE
                                   )
RETURN DATE;

PRAGMA RESTRICT_REFERENCES(getProductionDayStart, WNDS, WNPS, RNPS);

END;