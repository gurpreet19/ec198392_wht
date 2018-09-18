CREATE OR REPLACE PACKAGE ue_RR_Revn_Mapping IS
/****************************************************************
** Package        :  ue_RR_Revn_Mapping, header part
**
** $Revision: 1.5 $
**
** Purpose        :  Provide functionality for regulatory reporting Canada
**
** Documentation  :  http://energyextra.tietoenator.com
**
** Created  : 04.06.2010  Stian Skj?tad
**
** Modification history:
**
** Version  Date        Whom  Change description:
** -------  ------      ----- --------------------------------------
********************************************************************/


-- Enabling User Exits for EcDp_RR_Revn_Mapping.DsPostSetup
isDsPostSetupUEE  VARCHAR2(32) := 'FALSE';

-- Enabling User Exits for EcDp_RR_Revn_Mapping.DsSourceSetup
isDsSourceSetupUEE  VARCHAR2(32) := 'FALSE';



PROCEDURE LoadPriceIndexData(p_contract VARCHAR2,
                             p_daytime  DATE,
                             p_user_id  VARCHAR2);

PROCEDURE LoadPNCBPriceIndexData(p_contract VARCHAR2,
                                 p_daytime  DATE,
                                 p_user_id  VARCHAR2);

PROCEDURE LoadAllocatedVolumes(p_contract VARCHAR2,
                               p_daytime  DATE,
                               p_user_id  VARCHAR2);

PROCEDURE DsSourceSetup(p_dataset VARCHAR2,
                        p_daytime DATE,
                        p_user_id VARCHAR2,
                        p_contract_group_id VARCHAR2);

PROCEDURE DsPostSetup(p_dataset VARCHAR2,
                        p_daytime DATE,
                        p_user_id VARCHAR2);

FUNCTION GetThroughput(p_object_id VARCHAR2,
                       p_daytime   DATE,
                       p_period    VARCHAR2 DEFAULT NULL) RETURN NUMBER;


END ue_RR_Revn_Mapping;