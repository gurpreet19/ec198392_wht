CREATE OR REPLACE PACKAGE EcDp_SubDaily_Utilities IS
/**************************************************************
** Package:    EcDp_SubDaily_Utilities
**
** $Revision: 1.2.30.2 $
**
** Filename:   EcDp_SubDaily_Utilities.sql
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
** Created:     30.07.2008  Toha Taipur
**
**
** Modification history:
**
**
** Date:      Whom:      Change description:
** --------   -----      --------------------------------------------
** 11-12-12   musthram   ECPD-22832 - Added checkRecordStatus and checkAccessLevel
** 26-07-13   musthram   ECPD-24737 - Modified checkRecordStatus and checkAccessLevel
**************************************************************/

TYPE pkey_Rec IS RECORD (
  name VARCHAR2(32),
  value VARCHAR2(245));

TYPE t_pkey_list IS TABLE OF pkey_Rec INDEX BY PLS_INTEGER;
TYPE t_number_array IS TABLE OF DBMS_SQL.Number_Table INDEX BY PLS_INTEGER;

PROCEDURE generateMissingRecords (
    p_object_id          VARCHAR2,
    p_day                DATE,
    p_subday_class       VARCHAR2,
    p_method             VARCHAR2,
    p_pkeys       IN OUT EcDp_SubDaily_Utilities.t_pkey_list,
    p_user_id            VARCHAR2,
    p_prod_day_ref       VARCHAR2 DEFAULT NULL -- needed for e.g. wbi which use well's productionday instead of its own
);

FUNCTION checkRecordStatus(
  p_daytime            DATE,
  p_object_id          VARCHAR2,
  p_daily_class        VARCHAR2) RETURN VARCHAR2;

FUNCTION checkAccessLevel(
  p_objecturl          VARCHAR2,
  p_subdaily_class     VARCHAR2 DEFAULT NULL,
  p_daily_class        VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

END EcDp_SubDaily_Utilities;