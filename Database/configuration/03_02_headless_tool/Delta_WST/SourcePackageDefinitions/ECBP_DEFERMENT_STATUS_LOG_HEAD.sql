CREATE OR REPLACE PACKAGE EcBp_Deferment_Status_Log IS
/****************************************************************
** Package        :  EcBp_Deferment_Status_Log, spec part
**
** $Revision: 1.0 $
**
** Purpose        :  This package is responsible for supporting business function
**                   related to Automatic Deferment Raw Data (PD.0024)
** Documentation  :  www.energy-components.com
**
** Created  : 20.02.2018  Gaurav Chaudhary
**
**
** Modification history:
**
** Date        Whom     Change description:
** ------      -------- --------------------------------------
** 01.06.2018  jainnraj ECPD-56263 : Modified parameters for flushData
** 05.06.2018  chaudgau ECPD-54420 : Added new procedure promoteOfficial and changed formal arguments for purgeStatusNoise
********************************************************************/
FUNCTION getSystemSetting
(
  p_key VARCHAR2
 ,p_daytime DATE DEFAULT ecdp_date_time.getcurrentsysdate
) RETURN VARCHAR2
RESULT_CACHE;

FUNCTION getPrevStatus
(
  p_object_id VARCHAR2
 ,p_daytime DATE
 ,p_status NUMBER
) RETURN deferment_status_log.status%TYPE;

PROCEDURE promoteOfficial
(
  p_object_id VARCHAR2
 ,p_daytime DATE
 ,p_status NUMBER
 ,p_prev_daytime DATE
 ,p_prev_status NUMBER
 ,p_lag_daytime DATE
 ,p_lag_status NUMBER
);

PROCEDURE purgeStatusNoise
(
  p_object_id VARCHAR2
 ,p_prev_daytime DATE
 ,p_prev_status NUMBER
);

PROCEDURE flushData;

PROCEDURE createEvent
(
  p_start_date DATE
 ,p_end_date DATE DEFAULT NULL
 ,p_object_id VARCHAR2
 ,p_created_by VARCHAR2
);

END EcBp_Deferment_Status_Log;