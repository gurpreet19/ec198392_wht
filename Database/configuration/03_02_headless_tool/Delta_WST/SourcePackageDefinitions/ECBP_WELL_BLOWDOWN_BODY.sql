CREATE OR REPLACE PACKAGE BODY EcBp_Well_Blowdown IS

/****************************************************************
** Package        :  EcBp_Well_Blowdown, body part
**
** $Revision: 1.1 $
**
** Purpose        :  This package is responsible for supporting business function
**                   related to Well Blowdown Event.
** Documentation  :  www.energy-components.com
**
** Created  : 20.04.2017  Gaurav Chaudhary
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
********************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : deleteChildEvent
-- Description    : Delete child events.
--
--
-- Preconditions  :
-- Postconditions : .
--
-- Using tables   : well_blowdown_data
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE deletechildevent(p_event_no NUMBER)
--</EC-DOC>
 IS

BEGIN

    DELETE FROM well_blowdown_data WHERE parent_event_no = p_event_no;

END deletechildevent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : insertBlowdownData
-- Description    : Generate child records with given frequency of data collection.
--
--
-- Preconditions  :
-- Postconditions : .
--
-- Using tables   : well_blowdown_data, well_blowdown_event
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE insertblowdowndata(p_parent_event_no NUMBER
                            ,p_object_id       VARCHAR2
                            ,p_start_date      DATE
                            ,p_end_date        DATE
                            ,p_blowdown_freq   VARCHAR2
                            ,p_username        VARCHAR2)
--</EC-DOC>
 IS
    ln_data_freq NUMBER;
BEGIN

    ln_data_freq := ec_prosty_codes.code_text(p_blowdown_freq,
                                              'WELL_BLOWDOWN_FREQ');

    FOR i IN (SELECT p_start_date + LEVEL * ln_data_freq / 1440 next_date
                FROM dual
              CONNECT BY LEVEL <= (((p_end_date - p_start_date) * 1440) /
                         ln_data_freq))
    LOOP
        IF i.next_date > p_end_date
        THEN
            continue;
        END IF;

        INSERT INTO well_blowdown_data
            (object_id, event_no, parent_event_no, daytime, created_by)
        VALUES
            (p_object_id
            ,ecdp_system_key.assignnextnumber('WELL_BLOWDOWN_DATA')
            ,p_parent_event_no
            ,i.next_date
            ,p_username);
    END LOOP;

END insertblowdowndata;

FUNCTION validateblowdowntime(p_daytime         DATE
                              ,p_parent_event_no NUMBER)
RETURN NUMBER
IS
  ln_record_cnt NUMBER;
BEGIN
  SELECT COUNT(*) INTO ln_record_cnt
  FROM well_blowdown_event
  WHERE event_no=p_parent_event_no
  AND p_daytime BETWEEN START_DATE AND END_DATE;

  RETURN ln_record_cnt;

END validateblowdowntime;

FUNCTION countChildEvent(p_parent_event_no NUMBER)
RETURN NUMBER
IS
 ln_row_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO ln_row_count
    FROM well_blowdown_data
   WHERE parent_event_no = p_parent_event_no;

  RETURN ln_row_count;
END;

END EcBp_Well_Blowdown;