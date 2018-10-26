CREATE OR REPLACE PACKAGE BODY EcDp_Pipeline_Calculation IS

/****************************************************************
** Package        :  EcDp_Pipeline_Calculation, body part
**
** $Revision: 1.7 $
**
** Purpose        :  Calculation on pipelines.
**
** Documentation  :  www.energy-components.com
**
** Created  : 09.05.2006  Kristin Eide
**
** Modification history:
**
** Version  Date     	Whom  		Change description:
** -------  ------   	----- 		--------------------------------------
** 1.0	   09.05.06 	eideekri   	Initial version. Added function getTransactionBalace.
** 1.1     04.07.2006   Lau             TI#4101: Fixed nvl problem. Sum up to current daytime instead of only returning existing records
** 1.3     23.08.06     rajarsar        Tracker 4233. Added function getPigTravelDuration.
** 1.4     30.11.06     baerhlin        TI#4822 (Copy of #4561): Switched credit and debit. More logic on summertime flag, on which daytime to include in sum.
**		   10.10.07	    rajarsar        ECPD-6281: Updated getPigTravelDuration to change the return type
**		   19.11.07	    rajarsar        ECPD-6940: Updated getPigTravelDuration
**         01.04.08     rajarsar    	ECPD-7844 Replaced getNumHours with 24 at getPigTravelDuration
*****************************************************************/


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getTransactionBalance                                                        --
-- Description    :
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : pipe_pc_transactions
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                           --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------

FUNCTION getTransactionBalance(p_pipe_id VARCHAR2, p_profit_centre_id VARCHAR2, p_daytime DATE, p_summer_time VARCHAR2)
RETURN NUMBER
--<EC-DOC>
IS

ln_balance NUMBER;

CURSOR c_balanceW (cp_pipe_id VARCHAR2, cp_profit_centre_id VARCHAR2, cp_daytime DATE, cp_summer_time VARCHAR2) IS
SELECT SUM(nvl(credit,0)-nvl(debit,0)) balance
FROM pipe_pc_transaction
WHERE object_id = cp_pipe_id
AND profit_centre_id = cp_profit_centre_id
AND daytime <= cp_daytime;

CURSOR c_balanceS (cp_pipe_id VARCHAR2, cp_profit_centre_id VARCHAR2, cp_daytime DATE, cp_summer_time VARCHAR2) IS
SELECT SUM(nvl(credit,0)-nvl(debit,0)) balance
FROM pipe_pc_transaction
WHERE object_id = cp_pipe_id
AND profit_centre_id = cp_profit_centre_id
AND daytime < cp_daytime;

CURSOR c_balance_lastHourS (cp_pipe_id VARCHAR2, cp_profit_centre_id VARCHAR2, cp_daytime DATE, cp_summer_time VARCHAR2) IS
SELECT SUM(nvl(credit,0)-nvl(debit,0)) balance
FROM pipe_pc_transaction
WHERE object_id = cp_pipe_id
AND profit_centre_id = cp_profit_centre_id
AND daytime = cp_daytime
AND summer_time = cp_summer_time;

BEGIN

   ln_balance := NULL;
   IF(p_summer_time = 'S' OR p_summer_time = 'Y') THEN
   	FOR r_balance IN c_balanceS(p_pipe_id, p_profit_centre_id, p_daytime, p_summer_time) LOOP
      		ln_balance := Nvl(r_balance.balance, 0);
   	END LOOP;

   	FOR r_balance IN c_balance_lastHourS(p_pipe_id, p_profit_centre_id, p_daytime, p_summer_time) LOOP
      		ln_balance := ln_balance + Nvl(r_balance.balance, 0);
   	END LOOP;
   ELSE
   	FOR r_balance IN c_balanceW(p_pipe_id, p_profit_centre_id, p_daytime, p_summer_time) LOOP
      		ln_balance := Nvl(r_balance.balance, 0);
   	END LOOP;
   END IF;

   RETURN ln_balance;

END getTransactionBalance;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getPigTravelDuration                                                      --
-- Description    :
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : pipe_pigging_event
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                           --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------

FUNCTION getPigTravelDuration(p_pipe_id VARCHAR2, p_daytime DATE)
RETURN VARCHAR2
--<EC-DOC>
IS

ln_diff     	  NUMBER := 0;
ln_hour           NUMBER := 0;
ln_minute         NUMBER := 0;
lv2_travel_time   VARCHAR(32);

CURSOR c_duration (cp_pipe_id VARCHAR2, cp_daytime DATE) IS
SELECT (actual_arrival - daytime) duration
FROM pipe_pigging_event
WHERE object_id = cp_pipe_id
AND daytime = cp_daytime;

BEGIN

   ln_diff := NULL;
   FOR r_duration IN c_duration(p_pipe_id, p_daytime) LOOP
      ln_diff := abs(r_duration.duration);
   END LOOP;
   -- replaced getNumhours with 24
   IF ln_diff  IS NOT NULL THEN
    ln_diff := ln_diff * 24;
    ln_hour := trunc(ln_diff);
    ln_minute := round((ln_diff - ln_hour) * 60, 2);
    If ln_minute = 60 then
      ln_hour := ln_hour + 1;
      ln_minute := 0;
    END If;
    lv2_travel_time := to_char(ln_hour) ||' hrs, '|| to_char(ln_minute) || ' min' ;
  ELSE
    lv2_travel_time := null;
  END IF;

 RETURN lv2_travel_time;

END getPigTravelDuration;

END EcDp_Pipeline_Calculation;