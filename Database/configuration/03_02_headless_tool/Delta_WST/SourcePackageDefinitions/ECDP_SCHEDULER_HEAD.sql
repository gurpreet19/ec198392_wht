CREATE OR REPLACE package ECDP_SCHEDULER is
/****************************************************************
** Package        :  EcDp_Client_Scheduler
**
** $Revision: 1.7 $
**
** Purpose        :  Functions used to Deal with the scheduler
**
** Documentation  :
**
** Created        :  08.15.2005  Micah Rupersburg
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
  3-2-2006  rupermic  Added statusOrPinStatus and getPinnedToNode
******************************************************************/
FUNCTION statusOrPinStatus(sNAME VARCHAR2, sgroup VARCHAR2, realStatus VARCHAR2) RETURN VARCHAR2;
--

FUNCTION getPinnedToNode RETURN VARCHAR2;
--


FUNCTION isJobExecuting(NAME VARCHAR2, sgroup VARCHAR2) RETURN VARCHAR2;

FUNCTION ScheduleType(cron VARCHAR2) RETURN VARCHAR2;

FUNCTION getUniqueName(p_name VARCHAR) RETURN VARCHAR2;

FUNCTION CronPartMonth(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartSec(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartMin(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartDOW(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartDOM(cronExpression VARCHAR2) RETURN VARCHAR2;

--In case DOM has this format n/m, return m.
FUNCTION CronPartDOMDay(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartYear(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartHour(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartSyntaxMonth(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartSyntaxMin(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartSyntaxDOW(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartSyntaxDOM(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartSyntaxHour(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronExpressionSyntax(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPart(cronExpression VARCHAR2, part INTEGER) RETURN VARCHAR2;

FUNCTION QuartLongTimeToDate(longtime NUMBER) RETURN DATE;

FUNCTION QuartLongTimeToEcDate(longtime NUMBER) RETURN DATE;

FUNCTION DateToEcDate(theDate DATE) RETURN DATE;

FUNCTION TriggerDescription(NAME VARCHAR2, sgroup VARCHAR2) RETURN VARCHAR2;

FUNCTION TriggerCronExpression(NAME VARCHAR2, sgroup VARCHAR2) RETURN VARCHAR2;

FUNCTION TriggerStartDate(NAME VARCHAR2, sgroup VARCHAR2) RETURN DATE;

FUNCTION TriggerEndDate(NAME VARCHAR2, sgroup VARCHAR2) RETURN DATE;

FUNCTION isTriggerEnabled(NAME VARCHAR2, sgroup VARCHAR2) RETURN VARCHAR2;

FUNCTION TriggerStatus(NAME VARCHAR2, sgroup VARCHAR2) RETURN VARCHAR2;

FUNCTION isJobStateful(NAME VARCHAR2, sgroup VARCHAR2) RETURN VARCHAR2;

FUNCTION TriggerScheduleType(NAME VARCHAR2, sgroup VARCHAR2) RETURN VARCHAR2;

FUNCTION TriggerNextFireTime(NAME VARCHAR2, sgroup VARCHAR2) RETURN DATE;

FUNCTION ReadyToRun(p_shcedule_no NUMBER) RETURN VARCHAR2;

FUNCTION CronPartNthWeek(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartSyntaxNthWeek(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartMonday(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartSyntaxMonday(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartTuesday(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartSyntaxTuesday(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartWednesday(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartSyntaxWednesday(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartThursday(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartSyntaxThursday(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartFriday(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartSyntaxFriday(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartSaturday(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartSyntaxSaturday(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartSunday(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartSyntaxSunday(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartMonthlyOp1(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartMonthlyOp2(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartYearlyOp1(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartYearlyOp2(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartYearlyDay(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartYearlyWeekDay(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartYearlyDayRecurring(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartYearlyMonthRecurring(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartMonthlyDay(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartMonthlyEveryMonth(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartMonthlyDayRecurring(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartMonthlyWeekDay(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartMonthlyEveryMonthOp2(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartSubDailyOp1(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartSubDailyOp2(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartDailyOp1(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartDailyOp2(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartSubDailyMin(cronExpression VARCHAR2) RETURN VARCHAR2;

FUNCTION CronPartSubDailyHour(cronExpression VARCHAR2) RETURN VARCHAR2;

PROCEDURE SchedulesCleanup(p_retain_days NUMBER);

end ECDP_SCHEDULER;