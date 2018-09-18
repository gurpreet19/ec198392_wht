CREATE OR REPLACE PACKAGE ue_NOMPNT_SHARE IS

/******************************************************************************
** Package        :  UE_CNTR_CONTRACT_SHARE, header part
**
** $Revision: 1.2 $
**
** Purpose        :  Includes user-exit functionality for cntr contract share screen
**
** Documentation  :  www.energy-components.com
**
** Created  : 02.02.2012 Tommy Hassel
**
** Modification history:
**
** Date        Whom     Change description:
** -------     ------   -----------------------------------------------
** 27.06.2012  sharawan ECPD-21296 : Added new procedure validateShare to regulate the share sum not exceeding 100.
**
*/


-- Public function and procedure declarations
PROCEDURE set_end_date(p_object_id VARCHAR2, p_daytime DATE);

PROCEDURE copy_prev_values(p_object_id VARCHAR2, p_daytime DATE);

PROCEDURE validateShare(p_nompnt_id VARCHAR2, p_daytime DATE);

END ue_NOMPNT_SHARE;