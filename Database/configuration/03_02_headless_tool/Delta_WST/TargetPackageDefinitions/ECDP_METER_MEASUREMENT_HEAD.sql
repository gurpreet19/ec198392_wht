CREATE OR REPLACE PACKAGE EcDp_Meter_Measurement IS
/******************************************************************************
** Package        :  EcDp_Meter_Measurement, header part
**
** $Revision: 1.5 $
**
** Purpose        :  Find and work with meter measurement data
**
** Documentation  :  www.energy-components.com
**
** Created        :  11.02.2009 Olav Nærland
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
** 07.12.2011  leeeewei Added new function setMeterCompStatus
** 03.01.2012  leeeewei ECPD-19090: Modified setMeterCompStatus to only update when there is changes on record status
********************************************************************/

FUNCTION getNumberOfSubDailyRecords(
  p_object_id   VARCHAR2,
  p_date                DATE
)
RETURN INTEGER;

PRAGMA RESTRICT_REFERENCES(getNumberOfSubDailyRecords, WNDS, WNPS, RNPS);

--

PROCEDURE aggregateSubDailyToDaily(
  	p_object_id   	VARCHAR2,
  	p_daytime       DATE,
	  p_user		      VARCHAR2
);

--

PROCEDURE createMeterDayHours(
	p_object_id	    VARCHAR2,
	p_daytime       DATE,
	p_curr_user	    VARCHAR2,
  p_accessLevel	  INTEGER
);

PROCEDURE setMeterCompStatus(
    p_analysis_no VARCHAR2,
    p_user_id VARCHAR2 DEFAULT NULL
);

END EcDp_Meter_Measurement;