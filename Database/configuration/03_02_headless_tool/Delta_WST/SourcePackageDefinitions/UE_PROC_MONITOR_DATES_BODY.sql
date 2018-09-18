CREATE OR REPLACE PACKAGE BODY UE_PROC_MONITOR_DATES IS

/****************************************************************
** Package        :  UE_PROC_MONITOR_DATES, body part
**
** $Revision: 1.2 $
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

RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
RETURN '2009-12-01;3. desember 2009;5th des 09;Chrismas Eve 2009';
END GetDateStrings;

FUNCTION GetDates
(seed_date_ISO_format VARCHAR2, process_monitor_no NUMBER )

RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
RETURN '2009-12-01T00:00:00;2009-12-03T00:00:00;2009-12-05T00:00:00;2009-12-24T00:00:00';
END GetDates;
FUNCTION GetEnd
(seed_date_ISO_format VARCHAR2, process_monitor_no NUMBER )

RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
RETURN '2009-12-25T00:00:00';
END GetEnd;
END UE_PROC_MONITOR_DATES;