CREATE OR REPLACE PACKAGE BODY EcBp_Carrier_Cooldown IS
/******************************************************************************
** Package        :  EcBp_Carrier_Cooldown, body part
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
** Date       Whom      Change description:
** ------     -----     -----------------------------------------------------------------------------------------------
** 06.12.2012 leeeewei	Added functions InitiateCarrierTank
********************************************************************/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : initiateCarrierTank
-- Description    : Initiate empty rows for all tanks for the selected vessels
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE initiateCarrierTank (p_carrier_id VARCHAR2)
--</EC-DOC>
IS

--number of tanks for the selected carrier
ln_no_of_tanks		NUMBER;
ln_count			NUMBER;

ld_daytime			DATE;

BEGIN

  ld_daytime     := trunc(Ecdp_Timestamp.getCurrentSysdate);
  ln_no_of_tanks := ec_carrier_version.no_of_tanks(p_carrier_id,ld_daytime,'<=');

  IF ln_no_of_tanks IS NOT NULL THEN
    ln_count := 1;
    WHILE (ln_count <= ln_no_of_tanks) LOOP
      INSERT INTO carrier_tank
        (object_id, tank_no)
      VALUES
        (p_carrier_id, ln_count);
      initializeTemp(p_carrier_id, ln_count);
      ln_count := ln_count + 1;
    END LOOP;

  END IF;

END initiateCarrierTank;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : initializeTemp
-- Description    : initialize temperature for a given carrier
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE initializeTemp (p_carrier_id VARCHAR2,p_tank_no NUMBER)
--</EC-DOC>
IS

ln_temp 	NUMBER;
ln_max_temp 	NUMBER;
ld_daytime		DATE;

BEGIN
    ld_daytime := TRUNC(Ecdp_Timestamp.getCurrentSysdate);
    ln_temp := ec_carrier_version.min_temp(p_carrier_id,ld_daytime,'<=');
	ln_max_temp := ec_carrier_version.max_temp(p_carrier_id,ld_daytime,'<=');

	WHILE (ln_temp <= ln_max_temp) LOOP
		INSERT INTO carrier_tank_cooldown(object_id, tank_no, temp) VALUES (p_carrier_id, p_tank_no, ln_temp);
		ln_temp := ln_temp + 1;
	END LOOP;

END initializeTemp;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : copyCooldown
-- Description    : Calculate unload value
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE copyCooldown(p_from_carrier_id VARCHAR2,
                       p_to_carrier_id   VARCHAR2)
--</EC-DOC>
 IS
BEGIN

  INSERT INTO carrier_tank c
    (c.object_id, c.tank_no, c.comments) --,c.created_by, c.created_date)
    SELECT p_to_carrier_id, ct.tank_no, ct.comments
      FROM carrier_tank ct
     WHERE ct.object_id = p_from_carrier_id;

  INSERT INTO carrier_tank_cooldown c
    (c.object_id, c.tank_no, c.temp, c.qty) --,c.created_by, c.created_date)
    SELECT p_to_carrier_id, ctc.tank_no, ctc.temp, ctc.qty
      FROM carrier_tank_cooldown ctc
     WHERE ctc.object_id = p_from_carrier_id;

END copyCooldown;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : deleteCarrierTank
-- Description    : Delete carrier tank will also delete its child record (cooldown)
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE deleteCarrierTank (p_carrier_id VARCHAR2,  p_tank_no NUMBER)
--</EC-DOC>
IS

BEGIN

  DELETE FROM CARRIER_TANK_COOLDOWN c
    WHERE   c.object_id = p_carrier_id
    AND     c.tank_no = p_tank_no;


END deleteCarrierTank;

END EcBp_Carrier_Cooldown;