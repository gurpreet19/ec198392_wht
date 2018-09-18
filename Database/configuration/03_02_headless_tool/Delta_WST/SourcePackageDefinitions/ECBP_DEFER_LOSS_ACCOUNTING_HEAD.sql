CREATE OR REPLACE PACKAGE EcBp_Defer_Loss_Accounting IS
/****************************************************************
** Package        :  EcBp_Defer_Loss_Accounting
**
** $Revision: 1.6 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Daily Facility and Field Loss Accounting.
**
** Documentation  :  www.energy-components.com
**
** Created  : 21.11.2011  Sarojini Rajaretnam
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
**21.11.2011  rajarsar ECPD-18825:Added getRateUom
**12.12.2011  rajarsar ECPD-19175:Added calcDailyVolLoss,calcDailyMassLoss,calcProdEff and calcOpEff
**05.01.2012  rajarsar ECPD-19701:Added calcDailyVariance
**15.02.2012  abdulmaw ECPD-19811:Added getTotalPotentialBudgetkboe and getTotalActualkboe
**17.07.2012  rajarsar ECPD-21437:Added getEventNo and getPlannedVol.
*****************************************************************/

FUNCTION getRateUom(p_object_id VARCHAR2,
                          p_daytime  DATE,
                          p_rate_type VARCHAR2) RETURN VARCHAR2;

FUNCTION calcDailyVolLoss(p_object_id VARCHAR2,p_stream_id VARCHAR2, p_type VARCHAR2,
p_daytime DATE) RETURN NUMBER;

FUNCTION calcDailyMassLoss(p_object_id VARCHAR2,p_stream_id VARCHAR2, p_type VARCHAR2,
p_daytime DATE) RETURN NUMBER;

FUNCTION calcProdEff(p_object_id VARCHAR2,p_daytime DATE) RETURN NUMBER;

FUNCTION calcOpEff(p_object_id VARCHAR2,p_daytime DATE) RETURN NUMBER;

FUNCTION getTotalOELosses(p_object_id VARCHAR2,p_daytime DATE) RETURN NUMBER;

FUNCTION calcDailyVariance(p_object_id VARCHAR2,p_strm_object_id  VARCHAR2,p_type  VARCHAR2, p_daytime DATE)  RETURN NUMBER;

FUNCTION getTotalPotentialBudgetkboe(p_object_id VARCHAR2,p_daytime DATE,p_type VARCHAR2) RETURN NUMBER;

FUNCTION getTotalActualkboe(p_object_id VARCHAR2,p_daytime DATE,p_type VARCHAR2) RETURN NUMBER;

FUNCTION getEventNo(p_object_id VARCHAR2, p_daytime DATE) RETURN NUMBER;

FUNCTION getPlannedVol(p_object_id VARCHAR2,p_daytime DATE,p_class_name VARCHAR2) RETURN NUMBER;

END EcBp_Defer_Loss_Accounting;