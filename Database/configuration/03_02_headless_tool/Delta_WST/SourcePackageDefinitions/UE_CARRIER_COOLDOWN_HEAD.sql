CREATE OR REPLACE PACKAGE ue_carrier_cooldown IS

/******************************************************************************
** Package        :  ue_carrier_cooldown, header part
**
** $Revision: 1.1 $
**
** Purpose        :  Includes user-exit functionality for carrier cooldown
**
** Documentation  :  www.energy-components.com
**
** Created  : 10.12.2012 Lee Wei Yap
**
** Modification history:
**
** Date        Whom     Change description:
** -------     ------   -----------------------------------------------
** 10.12.2012 leeeewei	Added initiateCarrierTank,initializeTemp,copyCooldown,deleteCarrierTank
*/

-- Public function and procedure declarations
PROCEDURE initiateCarrierTank (p_carrier_id VARCHAR2);
PROCEDURE initializeTemp (p_carrier_id VARCHAR2,p_tank_no NUMBER);
PROCEDURE copyCooldown(p_from_carrier_id VARCHAR2, p_to_carrier_id VARCHAR2);
PROCEDURE deleteCarrierTank (p_carrier_id VARCHAR2,  p_tank_no NUMBER);

END ue_carrier_cooldown;