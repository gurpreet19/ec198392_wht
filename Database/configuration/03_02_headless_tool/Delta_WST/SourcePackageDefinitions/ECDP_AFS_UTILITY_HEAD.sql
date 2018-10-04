CREATE OR REPLACE PACKAGE ecdp_afs_utility IS

  /**************************************************************************************************************
  ** Package  :  ecdp_afs_utility, header part
  **
  ** $Revision: 1.1
  **
  ** Purpose        :  Utility package for AFS screens.
  **
  ** Created        :  27.02.2015 Siew Meng
  **
  ** Modification history:
  **
  ** Date         Whom             Change description:
  ** ------       -----            ------------------------------------------------------------------------------------------
  ** 27.02.2015   chooysie         Initial version.
  ** 11.03.2015   farhaann         ECPD-29637 - Added function getCummDiffMth,getCummAfsMth,getDailyDiffPerc,getCpySortOrder
  ** 13.04.2017   thotesan         ECPD-44257 - Added procedure deleteNomPointCompanyAfs to delete the record from FCST_NOMPNT_DAY_CPY_AFS as soon as the record get deleted from FCST_NOMPNT_DAY_AFS table.
  ** 02.04.2018   asareswi         ECPD-50718 - Added procedure deleteStrDaySpAfs, deleteStrDayAfs to delete records from FCST_STRM_DAY_CPY_AFS, FCST_STRM_DAY_SP_CPY_AFS table as soon as records deleted from their respective table.
  **************************************************************************************************************/
  FUNCTION getActualVol(p_object_id  VARCHAR2
                      , p_daytime    DATE
                       ) RETURN NUMBER;

  FUNCTION getActualCpy( p_object_id   VARCHAR2
                        , p_daytime    DATE
                        , p_ap_share   NUMBER
                        ) RETURN NUMBER;

  FUNCTION getCummDiffMth(p_forecast_id      VARCHAR2,
						  p_object_id        VARCHAR2,
                          p_daytime          DATE,
                          p_transaction_type VARCHAR2
                          ) RETURN NUMBER;

  FUNCTION getCummAfsMth(p_forecast_id      VARCHAR2,
                         p_object_id        VARCHAR2,
                         p_daytime          DATE,
                         p_transaction_type VARCHAR2
                        ) RETURN NUMBER;

  FUNCTION getDailyDiffPerc(p_forecast_id      VARCHAR2,
                            p_object_id        VARCHAR2,
                            p_daytime          DATE,
                            p_transaction_type VARCHAR2
                            ) RETURN NUMBER;


  FUNCTION getCpySortOrder(p_forecast_id      VARCHAR2,
                           p_object_id        VARCHAR2,
                           p_daytime          DATE,
                           p_transaction_type VARCHAR2,
                           p_company_id       VARCHAR2
					       ) RETURN NUMBER;


  Procedure deleteCompanyAfs(p_forecast_id varchar2,
                      p_ref_afs_seq  NUMBER);

  PROCEDURE deleteNomPointCompanyAfs(p_forecast_id 	  VARCHAR2,
                                     p_ref_afs_seq 	  NUMBER);

  PROCEDURE deleteStrDaySpAfs(p_class_name        IN VARCHAR2,
                              p_forecast_id       IN VARCHAR2,
                              p_supply_point_id   IN VARCHAR2,
                              p_daytime           IN DATE,
                              p_company_id        IN VARCHAR2 DEFAULT NULL,
                              p_transaction_type  IN VARCHAR2);

  PROCEDURE deleteStrDayAfs(p_class_name        IN VARCHAR2,
                            p_forecast_id       IN VARCHAR2,
                            p_object_id         IN VARCHAR2,
                            p_daytime           IN DATE,
                            p_company_id        IN VARCHAR2 DEFAULT NULL,
                            p_transaction_type  IN VARCHAR2);

END ecdp_afs_utility;