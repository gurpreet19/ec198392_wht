CREATE OR REPLACE PACKAGE BODY EcDp_Facility_Reference IS
/***************************************************************************************************
** Package        : EcDp_Facility_Reference, body part
**
** Release        : EC-12_1
**
** Purpose        : This package is responsible for facility information from fcty_reference_value.
**
**
**
** Created        : 2018-10-11 - rainanid
**
** Modification history:
**
** Date        Whom      Change description:
** ----------  --------  ---------------------------------------------------------------------------
** 2018-10-11  rainanid  Initial version.
***************************************************************************************************/

--<EC-DOC>
----------------------------------------------------------------------------------------------------
-- Function       : copyToNewDaytime														     --
-- Description    : Copy values from previous record into new record. 	                         --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :  																			 --
-- Using Tables   : FCTY_REFERENCE_VALUE														 --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--
----------------------------------------------------------------------------------------------------
PROCEDURE copyToNewDaytime (
    p_class_name     VARCHAR2,
    p_object_id      VARCHAR2,
    p_daytime        DATE     DEFAULT NULL)
--</EC-DOC>
IS

    CURSOR c_prev_daytime_rec IS
        SELECT *
          FROM fcty_reference_value
         WHERE object_id = p_object_id
           AND daytime = (
               SELECT max(daytime)
                 FROM fcty_reference_value
                WHERE object_id = p_object_id
                  AND daytime < p_daytime);

    CURSOR c_next_daytime_rec IS
        SELECT *
          FROM fcty_reference_value
         WHERE object_id = p_object_id
           AND daytime = (
               SELECT MIN(daytime)
                 FROM fcty_reference_value
                WHERE object_id = p_object_id
                  AND daytime > p_daytime
    );

    ln_count NUMBER;
    ld_next_daytime DATE := NULL;

BEGIN

    ln_count := 0;

    FOR mycur IN c_prev_daytime_rec LOOP

        ln_count := ln_count + 1;
        mycur.daytime := p_daytime;

        -- Lock philosophy, since this is copying all values from the previous, allow it for unlocked months, without checking if next is in locked month
        IF EcDp_Month_lock.withinLockedMonth(p_daytime) IS NOT NULL THEN
            EcDp_Month_lock.raiseValidationError('PROCEDURE', p_daytime, p_daytime, TRUNC(p_daytime,'MONTH'), 'EcDp_Facility_Reference.copyToNewDaytime: Can not do this in a locked month');
        END IF;

        EcDp_Month_Lock.localLockCheck('withinLockedMonth', p_object_id, p_daytime, p_daytime, 'PROCEDURE', 'EcDp_Facility_Reference.copyToNewDaytime: Can not do this in a locked month');
        mycur.created_by := Nvl(EcDp_User_Session.getUserSessionParameter('USERNAME'), User);

        INSERT INTO fcty_reference_value VALUES mycur;

    END LOOP;

    IF (ln_count = 0)  THEN

        FOR curnext IN c_next_daytime_rec LOOP
            ld_next_daytime := curnext.Daytime;
        END LOOP;

        EcDp_Month_Lock.validatePeriodForLockOverlap('PROCEDURE', p_daytime, ld_next_daytime, 'EcDp_Facility_Reference.copyToNewDaytime: Can not do this when there are locked months in the lifespan of these values', p_object_id);

        INSERT INTO fcty_reference_value (object_id, daytime, created_by) VALUES (p_object_id, p_daytime, NVL(EcDp_User_Session.getUserSessionParameter('USERNAME'), User));

    END IF;

END copyToNewDaytime;

END EcDp_Facility_Reference;