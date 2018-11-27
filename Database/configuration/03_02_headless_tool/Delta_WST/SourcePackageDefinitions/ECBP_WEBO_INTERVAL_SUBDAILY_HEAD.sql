CREATE OR REPLACE PACKAGE EcBp_Webo_Interval_SubDaily IS
/**************************************************************
** Package:    EcBp_Webo_Interval_SubDaily
**
** $Revision: 1.5 $
**
** Filename:   EcBp_Webo_Interval_SubDaily.sql
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
** Created:   	23.03.2006  Arief Zaki
**
**
** Modification history:
**
**
** Date:      Whom:      Change description:
** --------   -----      --------------------------------------------
** 23.03.2006 zakiiari   TI#3381-Initial version based on EcBp_Well_SubDaily.
** 03.04.2006 chongjer   TI#2351-added aggregateAllSubDaily
** 23.06.2006 chongjer   TI#3887 Added p_facility_id to aggregateAllSubDaily
** 04.08.2008 Toha       ECPD-4606 Adds user_id for generateMissing
** 27.02.2013 abdulmaw   ECPD-22552: Updated aggregateSubDaily and aggregateAllSubDaily
**************************************************************/

PROCEDURE aggregateSubDaily(
  p_daytime                 DATE,
  p_webo_interval_object_id   VARCHAR2,
  p_subdaily_class     VARCHAR2,
  p_daily_class        VARCHAR2,
  p_aggr_method        VARCHAR2      DEFAULT 'ON_STREAM',
  p_objecturl          VARCHAR2
);


PROCEDURE aggregateAllSubDaily(
  p_daytime                 DATE,
  p_webo_interval_object_id   VARCHAR2,
  p_facility_id        VARCHAR2,
  p_subdaily_class     VARCHAR2,
  p_daily_class        VARCHAR2,
  p_aggr_method        VARCHAR2      DEFAULT 'ON_STREAM',
  p_objecturl          VARCHAR2
);


PROCEDURE generateMissing(
  p_daytime            DATE,
  p_webo_interval_object_id     VARCHAR2,
  p_subday_class       VARCHAR2,
  p_generate_method    VARCHAR2      DEFAULT 'INTERPOLATE',
  p_user_id            VARCHAR2      DEFAULT NULL
);

END EcBp_Webo_Interval_SubDaily;