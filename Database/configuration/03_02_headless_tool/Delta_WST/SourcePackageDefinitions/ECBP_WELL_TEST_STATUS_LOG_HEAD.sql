CREATE OR REPLACE PACKAGE EcBp_Well_Test_Status_Log IS
/****************************************************************
** Package        :  EcBp_Well_Test_Status_Log, spec part
**
** $Revision: 1.0 $
**
** Purpose        :  This package is responsible for supporting business function
**                   related to Automatic Well Test Event Creation (PT.0021)
** Documentation  :  www.energy-components.com
**
** Created  : 11.09.2018  Gaurav Chaudhary
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 11.09.2018 chaudgau ECPD-50462 Initial Draft
********************************************************************/
FUNCTION getSystemSetting
(
  p_key VARCHAR2
 ,p_daytime DATE DEFAULT ecdp_date_time.getcurrentsysdate
) RETURN VARCHAR2
RESULT_CACHE;

PROCEDURE flushData;

PROCEDURE createEvent
(
     p_td_object_id        VARCHAR2
    ,p_start_date            DATE
    ,p_end_date             DATE
    ,p_n_wells_on_test  VARCHAR2
    ,p_o_wells_on_test  VARCHAR2
    ,p_creation_mode    VARCHAR2
	,p_event_type           VARCHAR2
	,p_test_no                 NUMBER DEFAULT NULL
);

FUNCTION isRedundant
(
   p_td_object_id VARCHAR2
  ,p_wells_on_test VARCHAR2
  ,p_daytime DATE
  ,p_chk_proposed_tab VARCHAR2 DEFAULT 'N'
) RETURN NUMBER;

PROCEDURE proposeEvent
(
	 p_td_object_id VARCHAR2
	,p_daytime DATE
	,p_wells_on_test VARCHAR2
);

END EcBp_Well_Test_Status_Log;