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
PRAGMA RESTRICT_REFERENCES(getLiftedNetVolSM3, WNDS, WNPS, RNPS);

FUNCTION getLiftedNetVolBBLS(p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getLiftedNetVolBBLS, WNDS, WNPS, RNPS);

FUNCTION getLiftedGrsVolSM3(p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getLiftedGrsVolSM3, WNDS, WNPS, RNPS);

FUNCTION getLiftedGrsVolBBLS(p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getLiftedGrsVolBBLS, WNDS, WNPS, RNPS);

FUNCTION getDayExpNotLiftedNetSM3(p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getDayExpNotLiftedNetSM3, WNDS, WNPS, RNPS);

FUNCTION getDayExpNotLiftedNetBBLS(p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getDayExpNotLiftedNetBBLS, WNDS, WNPS, RNPS);

FUNCTION getMthExpNotLiftedNetSM3(p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getMthExpNotLiftedNetSM3, WNDS, WNPS, RNPS);

FUNCTION getMthExpNotLiftedNetBBLS(p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getMthExpNotLiftedNetBBLS, WNDS, WNPS, RNPS);

FUNCTION getDayExpNotLiftedGrsSM3(p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getDayExpNotLiftedGrsSM3, WNDS, WNPS, RNPS);

FUNCTION getMthExpNotLiftedGrsSM3(p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getMthExpNotLiftedGrsSM3, WNDS, WNPS, RNPS);

FUNCTION getDayExpNotLiftedGrsBBLS(p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getDayExpNotLiftedGrsBBLS, WNDS, WNPS, RNPS);

FUNCTION getMthExpNotLiftedGrsBBLS(p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getMthExpNotLiftedGrsBBLS, WNDS, WNPS, RNPS);

END ecdp_if_tran_cargo;