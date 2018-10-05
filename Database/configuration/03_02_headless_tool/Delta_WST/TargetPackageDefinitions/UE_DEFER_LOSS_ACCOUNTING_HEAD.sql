CREATE OR REPLACE PACKAGE ue_defer_loss_accounting IS
/**************************************************************
** Package	:  ue_defer_loss_accounting, header part
**
** $Revision: 1.2.4.1 $
**
** Purpose        :  User exit functions should be put here.
**
** Documentation  :  www.energy-components.com
**
** Created        :  07.12.2011 Sarojini Rajaretnam
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
** 12.12.2011  rajarsar	ECPD-19175:Initial version
** 08.08.2012  makkkkam	ECPD-21684: Added getPlannedVol
**************************************************************/

FUNCTION getStrmBoeConstant(p_object_id VARCHAR2,
                        p_daytime DATE,
                        p_db_unit VARCHAR2) RETURN NUMBER;

FUNCTION getPlannedVol(p_object_id VARCHAR2,
                        p_daytime DATE) RETURN NUMBER;

END  ue_defer_loss_accounting;