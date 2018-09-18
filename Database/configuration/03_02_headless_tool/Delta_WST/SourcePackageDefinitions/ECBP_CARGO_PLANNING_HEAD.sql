CREATE OR REPLACE PACKAGE EcBp_Cargo_Planning IS
  /****************************************************************
  ** Package        :  EcBp_Cargo_Planning; head part
  **
  ** $Revision: 1.1 $
  **
  ** Purpose        :  Handles cargo planning forecast
  **
  ** Documentation  :  www.energy-components.com
  **
  ** Created        :  21.02.2013 Lee Wei Yap
  **
  ** Modification history:
  **
  ** Date        Whom   Change description:
  ** ----------  -----  -------------------------------------------
  ** 05/3/2013   leeeewei ECPD-20212: Initial version
  *************************************************************************/

  PROCEDURE setProcessTrainEvent(p_object_id  VARCHAR2,
                                 p_daytime    DATE,
                                 p_end_date   DATE,
                                 p_event_code VARCHAR2);

  PROCEDURE delProcessTrainEvent(p_object_id  VARCHAR2,
                                 p_daytime    DATE,
                                 p_end_date   DATE);

END EcBp_Cargo_Planning;