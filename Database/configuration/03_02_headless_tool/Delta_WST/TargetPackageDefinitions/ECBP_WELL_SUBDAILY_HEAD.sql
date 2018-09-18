CREATE OR REPLACE PACKAGE EcBp_Well_SubDaily IS
/**************************************************************
** Package:    EcBp_Well_SubDaily
**
** $Revision: 1.9.12.2 $
**
** Filename:   EcBp_Well_SubDaily.sql
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
** --------   -----      --------------------------------------------
** 11.08.2004 mazrina    removed sysnam and update as necessary
** 23.04.2005 ROV        updated parameters
** 21.06.2005 DN         Removed default option on parameters.
** 03.04.2006 Jerome     TI#2351 Added aggregateAllSubDaily
** 23.06.2006 Jerome     TI#3887 Added p_facility_id to aggregateAllSubDaily
** 04.08.2008 Toha       ECPD-4606 Adds user_id for generateMissing
** 27.05.2010 Leongwen   ECPD-10821: Misc sub daily improvements
** 31.12.2012 musthram   ECPD-22832: Updated aggregateSubDaily and aggregateAllSubDaily
** 11.09.2013 musthram   ECPD-25372: Added getPeriodHrs to be referenced from EcBp_Well_Theoretical
**************************************************************/

PROCEDURE chkObjSubDayFreq(p_on_strm_hrs NUMBER, p_classname VARCHAR2, p_object_id VARCHAR2, p_daytime DATE);

PROCEDURE aggregateSubDaily(
  p_daytime            DATE,
  p_well_object_id     VARCHAR2,
  p_subdaily_class     VARCHAR2,
  p_daily_class        VARCHAR2,
  p_aggr_method        VARCHAR2      DEFAULT 'ON_STREAM',
  p_objecturl          VARCHAR2
);

PROCEDURE aggregateAllSubDaily(
  p_daytime            DATE,
  p_well_object_id     VARCHAR2,
  p_facility_id        VARCHAR2,
  p_subdaily_class     VARCHAR2,
  p_daily_class        VARCHAR2,
  p_aggr_method        VARCHAR2      DEFAULT 'ON_STREAM',
  p_objecturl          VARCHAR2
);

PROCEDURE generateMissing(
  p_daytime            DATE,
  p_well_object_id     VARCHAR2,
  p_subday_class       VARCHAR2,
  p_generate_method    VARCHAR2      DEFAULT 'INTERPOLATE',
  p_user_id            VARCHAR2      DEFAULT NULL
);

FUNCTION getPeriodHrs(
  p_object_id         VARCHAR2,
  p_daytime           DATE) RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getPeriodHrs, WNDS, WNPS, RNPS);

END;