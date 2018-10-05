CREATE OR REPLACE PACKAGE BODY EcDp_Well_Choke IS

/****************************************************************
** Package        :  EcDp_Well_Choke, body part
**
** $Revision: 1.4 $
**
** Purpose        :  Provides choke data services
**
** Documentation  :  www.energy-components.com
**
** Created  : 12.05.2000  Carl-Fredrik S?sen
**
** Modification history:
**
** Date     Whom    Change description:
** -------- ------  -------------------------------------------
** 10.07.01 KEJ     Added function FindMostRecentConfigDate
** 10.07.01 KEJ     Added function FindMostRecentChokeCode
** 02.10.03 DN      Added criticalOpening. Rel. 7.2.
** 11.08.2004 mazrina    removed sysnam and update as necessary
** 05.10.07 LAU     ECPD-6519: Adapted to new table structure.
** 21.12.11 kumarsur ECPD-18142: FindMostRecentConfigDate now returns the actual date of choketype change, instead of just the last well_version date
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : criticalOpening
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : well_version
--                  chok_properties
--                  t_preferanse
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION criticalOpening(
                                                                        p_object_id well.object_id%TYPE,
                  p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

ln_crit_opening NUMBER;
lv2_choke_id VARCHAR2(32);

BEGIN

   lv2_choke_id := ec_well_version.choke_id(p_object_id, p_daytime, '<=');
   ln_crit_opening := ec_choke_version.critical_opening(lv2_choke_id, p_daytime, '<=');

   RETURN ln_crit_opening;

END criticalOpening;


FUNCTION FindMostRecentConfigDate(
         p_object_id well.object_id%TYPE,
         p_daytime DATE)
RETURN DATE IS

CURSOR  c_last_choke_config IS
select  object_id, daytime, choke_id
  from  well_version
 where  object_id = p_object_id
   and  daytime <= p_daytime
 order  by daytime desc;

ld_return_val DATE   := NULL;
ln_count      NUMBER :=0;
lv2_prev_code VARCHAR2(32);

BEGIN

   FOR mycur IN c_last_choke_config LOOP
      IF ln_count>0 and lv2_prev_code <> mycur.choke_id THEN
         EXIT;
      END IF;

      lv2_prev_code := mycur.choke_id;
      ld_return_val := mycur.daytime;
      ln_count      := ln_count + 1;

   END LOOP;

   RETURN ld_return_val;

END FindMostRecentConfigDate;
-------------------------------------------------

FUNCTION FindMostRecentChokeCode(
         p_object_id well.object_id%TYPE,
         p_daytime DATE)
RETURN VARCHAR2 IS

CURSOR c_last_choke_config IS
SELECT c.object_code choke_code
FROM well_version wv, choke c
WHERE wv.object_id = p_object_id
AND wv.daytime <= p_daytime
AND wv.choke_id is not null
and wv.choke_id = c.object_id
ORDER by daytime DESC;

ld_return_val VARCHAR2(32) := NULL;

BEGIN

   FOR mycur IN c_last_choke_config LOOP
      ld_return_val := mycur.choke_code;
      EXIT;
   END LOOP;

   RETURN ld_return_val;

END FindMostRecentChokeCode;


END EcDp_Well_Choke;