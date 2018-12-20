CREATE OR REPLACE PACKAGE UE_PROC_MONITOR_DATES IS

/****************************************************************
** Package        :  UE_PROC_MONITOR_DATES, heder part
**
** $Revision: 1.3 $
**
** Purpose        :  License specific package to provide customer specific process monitor dates
**
** Documentation  :  www.energy-components.com
**
** Created  : 20.12.2009 Erlend Ellingsen
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- -------------------------------------------
** #.#   DD.MM.YYYY  <initials>
********************************************************************/

FUNCTION GetDateStrings
(seed_date_ISO_format VARCHAR2, process_monitor_no NUMBER )
RETURN VARCHAR2;

FUNCTION GetDates
(seed_date_ISO_format VARCHAR2, process_monitor_no NUMBER )
RETURN VARCHAR2;

FUNCTION GetEnd
(seed_date_ISO_format VARCHAR2, process_monitor_no NUMBER )
RETURN VARCHAR2;

END UE_PROC_MONITOR_DATES;