CREATE OR REPLACE PACKAGE EcBp_Carrier_Cooldown IS
/******************************************************************************
** Package        :  EcBp_Carrier_Cooldown, header part
**
** $Revision: 1.1 $
**
** Purpose        :  Business logic for carrier cooldown
**
** Documentation  :  www.energy-components.com
**
** Created  : 06.12.2012 Lee Wei Yap
**
** Modification history:
**
** Date        Whom     Change description:
** ----------  -----    -------------------------------------------
** 06.12.2012  leeeewei	Added procedure initiate,initializeTemp, copyCooldown deleteCarrierTank
********************************************************************/

PROCEDURE initiateCarrierTank (p_carrier_id VARCHAR2);
PROCEDURE initializeTemp (p_carrier_id VARCHAR2,p_tank_no NUMBER);
PROCEDURE copyCooldown (p_from_carrier_id VARCHAR2, p_to_carrier_id VARCHAR2);
PROCEDURE deleteCarrierTank (p_carrier_id VARCHAR2,  p_tank_no NUMBER);

END EcBp_Carrier_Cooldown;