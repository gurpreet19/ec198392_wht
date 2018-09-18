CREATE OR REPLACE PACKAGE ecdp_if_tran_cargo IS
/******************************************************************************
** Package        :  ecdp_if_tran_cargo, header part
**
** $Revision: 1.4 $
**
** Purpose        :  Functions used by EC Production
**
** Documentation  :  www.energy-components.com
**
** Created  : 07.11.2006 Kari Sandvik
**
** Modification history:
**
** Version  Date       Whom     Change description:
** -------  ---------- -------- -------------------------------------------
** 	    09.01.2007 kaurrjes ECPD-4806: Added 6 new functions ie getLiftedGrsVolSM3, getLiftedGrsVolBBLS, getDayExpNotLiftedGrsSM3, getMthExpNotLiftedGrsSM3,
**					   getDayExpNotLiftedGrsBBLS, getMthExpNotLiftedGrsBBLS
********************************************************************/

FUNCTION getLiftedNetVolSM3(p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER;

FUNCTION getLiftedNetVolBBLS(p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER;

FUNCTION getLiftedGrsVolSM3(p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER;

FUNCTION getLiftedGrsVolBBLS(p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER;

FUNCTION getDayExpNotLiftedNetSM3(p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER;

FUNCTION getDayExpNotLiftedNetBBLS(p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER;

FUNCTION getMthExpNotLiftedNetSM3(p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER;

FUNCTION getMthExpNotLiftedNetBBLS(p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER;

FUNCTION getDayExpNotLiftedGrsSM3(p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER;

FUNCTION getMthExpNotLiftedGrsSM3(p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER;

FUNCTION getDayExpNotLiftedGrsBBLS(p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER;

FUNCTION getMthExpNotLiftedGrsBBLS(p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER;

END ecdp_if_tran_cargo;