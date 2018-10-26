CREATE OR REPLACE PACKAGE EcBp_Aggregate IS
/**************************************************************
** Package:    EcBp_Aggregate
**
** $Revision: 1.1.8.1 $
**
** Filename:   EcBp_Aggregate.sql
**
** Part of :   EC Kernel
**
** Purpose:
**
** General Logic:
**
** Document References:
**
**
** Created:   	11.05.2004  Frode Barstad
**
**
** Modification history:
**
**
** Date:      Whom:      Change description:
** ---------- ---------- --------------------------------------------
** 2006-04-03 Jerome     TI#2351 Added function aggregateAllSubDaily
** 2006-06-26 Jerome     TI#3887 Modified aggregateAllSubDaily (use facility)
** 2006-07-20 Zakiiari   TI#4194 Modified aggregateSubDaily by adding p_aggr_datetime optional parameter
** 2013-04-09 limmmchu   ECPD-23847: Modified aggregateAllSubDaily
** 2013-07-27 musthram   ECPD-24737: Modified aggregateAllSubDaily by adding access level
**************************************************************/

FUNCTION aggregateSubDaily(
  p_from_class_name    VARCHAR2,
  p_to_class_name      VARCHAR2,
  p_object_id          VARCHAR2,
  p_daytime            DATE,
  p_period_hrs         NUMBER,
  p_aggr_method        VARCHAR2 DEFAULT 'ON_STREAM',
  p_aggr_datetime      VARCHAR2 DEFAULT NULL
)
RETURN VARCHAR2;

--PRAGMA RESTRICT_REFERENCES (aggregateSubDaily, WNDS);

FUNCTION aggregateAllSubDaily(
  p_from_class_name    VARCHAR2,
  p_to_class_name      VARCHAR2,
  p_object_id          VARCHAR2,
  p_facility_id        VARCHAR2,
  p_daytime            DATE,
  p_period_hrs         NUMBER,
  p_aggr_method        VARCHAR2 DEFAULT 'ON_STREAM',
  p_access_level       NUMBER,
  p_strm_set           VARCHAR2 DEFAULT NULL
)
RETURN VARCHAR2;

--PRAGMA RESTRICT_REFERENCES (aggregateSubDaily, WNDS);

END;