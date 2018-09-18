CREATE OR REPLACE PACKAGE BODY ue_Nomination_Cycle IS
/******************************************************************************
** Package        :  ue_Nomination_Cycle, body part
**
** $Revision: 1.1 $
**
** Purpose        :  Business logic for nomination cycle handlings
**
** Documentation  :  www.energy-components.com
**
** Created        :  18.02.2008 Kari Sandvik
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
**
**
********************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCurrentNomCycle
-- Description    : Gets the current nomination cycle based in date. If date is empty system date is used
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : nomination_cycle
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getCurrentNomCycle(p_daytime DATE DEFAULT NULL)
	RETURN VARCHAR2
--</EC-DOC>
IS
	CURSOR c_cycle (cp_offset NUMBER) IS
		SELECT 	c.nom_cycle_code,
				concat(to_char(c.nom_deadline, 'HH24'), to_char(c.nom_deadline, 'MI')) nom_deadline
		FROM 	nomination_cycle c
		WHERE 	TO_NUMBER(c.gas_day_offset) = cp_offset
		ORDER BY c.sort_order;

	CURSOR c_min IS
		SELECT	MIN(TO_NUMBER(gas_day_offset)) min_offset
		FROM	nomination_cycle;

	lv_nom_cycle VARCHAR2(32);
	ld_date DATE;
	ln_diff NUMBER;
	ln_min_offset NUMBER;
	ln_offset NUMBER := 0;

BEGIN
	IF p_daytime IS NULL THEN
		ld_date := Ecdp_Timestamp.getCurrentSysdate;
	ELSE
		ld_date := p_daytime;
	END IF;

	-- if navigator day is the same as current day
	IF TRUNC(ld_date, 'DD') = TRUNC(Ecdp_Timestamp.getCurrentSysdate, 'DD') THEN
		FOR curCycle IN c_cycle(ln_offset) LOOP
			lv_nom_cycle := curCycle.nom_cycle_code;
			IF curCycle.nom_deadline > concat(to_char(ld_date, 'HH24'), to_char(ld_date, 'MI')) THEN
				EXIT;
			END IF;
		END LOOP;
	-- if navigator value after today
	ELSIF TRUNC(ld_date, 'DD') > TRUNC(Ecdp_Timestamp.getCurrentSysdate, 'DD') THEN
		FOR curMin IN c_min LOOP
			ln_min_offset := curMin.min_offset;
		END LOOP;

		ln_diff := TRUNC(Ecdp_Timestamp.getCurrentSysdate, 'DD') - TRUNC(ld_date, 'DD');

		IF ln_min_offset < ln_diff THEN
			ln_offset := ln_diff;
		ELSE
			ln_offset := ln_min_offset;
		END IF;

		FOR curCycle IN c_cycle(ln_offset) LOOP
			lv_nom_cycle := curCycle.nom_cycle_code;
			IF curCycle.nom_deadline > concat(to_char(ld_date, 'HH24'), to_char(ld_date, 'MI')) THEN
				EXIT;
			END IF;
		END LOOP;

	-- if navigator value before today
	ELSIF TRUNC(ld_date, 'DD') < TRUNC(Ecdp_Timestamp.getCurrentSysdate, 'DD') THEN
		FOR curCycle IN c_cycle(ln_offset) LOOP
			lv_nom_cycle := curCycle.nom_cycle_code;
		END LOOP;
	END IF;

	RETURN lv_nom_cycle;

END getCurrentNomCycle;


END ue_Nomination_Cycle;