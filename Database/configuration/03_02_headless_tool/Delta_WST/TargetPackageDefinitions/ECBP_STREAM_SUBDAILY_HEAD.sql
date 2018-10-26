CREATE OR REPLACE PACKAGE EcBp_Stream_SubDaily IS
/**************************************************************
** Package:    EcBp_Stream_SubDaily
**
** $Revision: 1.6.12.2 $
**
** Filename:   EcBp_Stream_SubDaily.sql
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
** Created:   	25.04.2005  Roar Vika
**
**
** Modification history:
**
**
** Date:      Whom:  Change description:
** --------   -----  --------------------------------------------
** 25.04.2005 ROV    Initial version based on EcBp_Well_Subdaily
** 21.06.2005 DN     Removed default option on parameters.
** 03.04.2006 Jerome TI#2351 Added aggregateAllSubDaily
** 23.06.2006 Jerome TI#3887 Added p_facility_id to aggregateAllSubDaily
** 04.08.2008 Toha   ECPD-4606 Adds user_id for generateMissing
** 25.05.2010 Leongwen ECPD-10821: Misc sub daily improvements
** 31.12.2012 musthram ECPD-22832: Updated aggregateSubDaily and aggregateAllSubDaily
** 09.04.2013 limmmchu ECPD-23847: Modified aggregateAllSubDaily
**************************************************************/

PROCEDURE chkObjSubDayFreq(p_on_strm_hrs NUMBER, p_classname VARCHAR2, p_object_id VARCHAR2, p_daytime DATE);

PROCEDURE aggregateSubDaily(
  p_daytime            DATE,
  p_stream_object_id   VARCHAR2,
  p_subdaily_class     VARCHAR2,
  p_daily_class        VARCHAR2,
  p_aggr_method        VARCHAR2  DEFAULT 'ON_STREAM',
  p_objecturl          VARCHAR2
);


PROCEDURE aggregateAllSubDaily(
  p_daytime            DATE,
  p_stream_object_id   VARCHAR2,
  p_facility_id        VARCHAR2,
  p_subdaily_class     VARCHAR2,
  p_daily_class        VARCHAR2,
  p_aggr_method        VARCHAR2  DEFAULT 'ON_STREAM',
  p_objecturl          VARCHAR2,
  p_strm_set           VARCHAR2  DEFAULT NULL
);


PROCEDURE generateMissing(
  p_daytime            DATE,
  p_stream_object_id   VARCHAR2,
  p_subday_class       VARCHAR2,
  p_generate_method    VARCHAR2  DEFAULT 'INTERPOLATE',
  p_user_id            VARCHAR2      DEFAULT NULL
);

END;