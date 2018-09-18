CREATE OR REPLACE PACKAGE BODY EcDp_Stream_ORF_Value IS
/******************************************************************************************
** Package        :  EcDp_Stream_ORF_Value, body part
**
** $Revision: 1.5 $
**
** Purpose        :  This package is responsible for data access to strm_orf_component
**
** Documentation  :  www.energy-components.com
**
** Created        :  25.04.2006  Jerome Chong
**
** Modification history:
**
** Date        Whom     Change description:
** ----------  ------   ----------------------------------------------------------------
** 25.04.2006  Jerome   Initial Version
** 28.09.2007  rajarsar ECPD#6052: Updated copyToNewDaytime.
** 21.11.2008  oonnnng  ECPD-6067: Added local month lock checking in copyToNewDaytime function.
** 17.02.2009  leongsei ECPD-6067: Modified function copyToNewDaytime for new parameter p_local_lock
******************************************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : copyToNewDaytime                                                             --
-- Description    :                                                                              --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
PROCEDURE copyToNewDaytime (
   p_object_id    stream.object_id%TYPE,
   p_daytime      DATE,
   p_orf_type     VARCHAR2)

--</EC-DOC>
IS

CURSOR c_prev_daytime_rec IS
    SELECT *
      FROM strm_orf_component
     WHERE object_id = p_object_id
       AND orf_type = p_orf_type
       AND daytime = (
         SELECT MAX(daytime)
           FROM strm_orf_component
          WHERE object_id = p_object_id
            AND orf_type = p_orf_type
            AND daytime < p_daytime
       );

CURSOR c_next_daytime_rec IS
    SELECT daytime
      FROM strm_orf_component
     WHERE object_id = p_object_id
       AND orf_type = p_orf_type
       AND daytime = (
         SELECT MIN(daytime)
           FROM strm_orf_component
          WHERE object_id = p_object_id
            AND orf_type = p_orf_type
            AND daytime > p_daytime
       );

CURSOR c_orf_component IS
    SELECT component_no
      FROM comp_set_list
     WHERE component_set = 'STRM_ORF_COMP'
     AND p_daytime >= daytime AND (p_daytime < end_date OR end_date IS NULL);

ln_count NUMBER;
ld_next_daytime DATE := NULL;

BEGIN

   ln_count :=0;

   FOR mycur IN c_prev_daytime_rec LOOP

      ln_count := ln_count + 1;

      mycur.object_id := p_object_id;
      mycur.daytime   := p_daytime;
      mycur.orf_type  := p_orf_type;

      -- Lock philosophy, since this is copying all from the previous allow it for unlocked months, without checking if next is in locked month
      IF EcDp_Month_lock.withinLockedMonth(p_daytime) IS NOT NULL THEN

        EcDp_Month_lock.raiseValidationError('PROCEDURE', p_daytime, p_daytime, trunc(p_daytime,'MONTH'), 'EcDp_Stream_ORF_Value.copyToNewDaytime: Can not do this in a locked month');

      END IF;

      EcDp_Month_Lock.localLockCheck('withinLockedMonth', p_object_id,
                                     p_daytime, p_daytime,
                                     'PROCEDURE', 'EcDp_Stream_ORF_Value.copyToNewDaytime: Can not do this in a local locked month');

      INSERT INTO strm_orf_component VALUES mycur;

   END LOOP;

   IF (ln_count = 0)  THEN

     FOR curnext IN c_next_daytime_rec LOOP

       ld_next_daytime := curnext.Daytime;

     END LOOP;

     EcDp_Month_Lock.validatePeriodForLockOverlap('PROCEDURE',p_daytime,ld_next_daytime, 'EcDp_Stream_ORF_Value.copyToNewDaytime: Can not do this when there are locked months in the lifespan of these values', p_object_id);

     FOR cur_orf_comp IN c_orf_component LOOP

       INSERT INTO strm_orf_component (OBJECT_ID, DAYTIME, ORF_TYPE, COMPONENT_NO) VALUES (p_object_id, p_daytime, p_orf_type, cur_orf_comp.component_no);

     END LOOP;

   END IF;

END copyToNewDaytime;

END;