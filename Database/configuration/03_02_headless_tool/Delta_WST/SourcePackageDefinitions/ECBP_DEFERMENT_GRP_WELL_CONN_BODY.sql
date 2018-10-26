CREATE OR REPLACE PACKAGE BODY EcBp_Deferment_Grp_Well_Conn IS
/****************************************************************
** Package        :  EcBp_Deferment_Grp_Well_Conn, body part
**
** $Revision: 1.1 $
**
** Purpose        :  Provide basic functions on deferment group well connection
**
** Documentation  :  www.energy-components.com
**
** Created  : 29.07.2010  Lee Wei Yap
**
** Modification history:
**
** Date       Whom     Change description:
** --------   -------- --------------------------------------
** 29.07.10   leeeewei  Add new procedures checkDateWithinObjects, checkIfEventOverlaps
** 07.08.2017 jainnraj  ECPD-46835: Modified procedure checkIfEventOverlaps to correct the error message.
** 28.09.2017 bintjnor  ECPD-48789: Modified procedure checkDateWithinObjects to correct the check for end_date.
**
******************************************************************************/

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : checkDateWithinObjects                                                   --
-- Description    : Check start date and end date of deferment group connection is within start date
--                  and end date of deferment group and well
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : DEFERMENT_GROUP, WELL
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
PROCEDURE checkDateWithinObjects(p_object_id VARCHAR2,
								 p_well_id VARCHAR2,
								 p_start_date DATE,
								 p_end_date DATE)

IS

CURSOR c_defer_grp IS
SELECT START_DATE, END_DATE
   FROM DEFERMENT_GROUP dg
   WHERE dg.object_id = p_object_id;

CURSOR c_well IS
SELECT START_DATE, END_DATE
   FROM WELL w
   WHERE w.object_id = p_well_id;

BEGIN

FOR cur_defer_grp IN c_defer_grp LOOP
    FOR cur_well IN c_well LOOP

      IF (p_start_date < cur_defer_grp.start_date)
		  THEN
			   Raise_Application_Error(-20109,'Start Date must not be less than deferment group start date: ' || cur_defer_grp.start_date);
		  END IF;

      IF (p_start_date < cur_well.start_date)
		  THEN
			   Raise_Application_Error(-20109,'Start Date must not be less than well start date: ' || cur_well.start_date);
		  END IF;

	--Only check end date is within deferment group and well end date if p_end_date is not null
      IF (p_end_date IS NOT NULL)THEN

         IF (p_end_date > nvl(cur_defer_grp.end_date, p_end_date) )
			THEN
			      Raise_Application_Error(-20110,'End date must be less than deferment group end date: ' || cur_defer_grp.end_date);
		    END IF;

         IF (p_end_date > nvl(cur_well.end_date, p_end_date) )
			THEN
			      Raise_Application_Error(-20110,'End date must be less than well end date: ' || cur_well.end_date);
		     END IF;
      END IF;
    END LOOP;
END LOOP;

END checkDateWithinObjects;

---------------------------------------------------------------------------------------------------
-- Procedure      : checkIfEventOverlaps
-- Description    : Check well connecting to deferment group does not have
--                  overlapping start date and end date
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : DEFERMENT_GROUP_WELL
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

PROCEDURE checkIfEventOverlaps(p_object_id VARCHAR2,
								               p_well_id VARCHAR2,
								               p_start_date DATE,
								               p_end_date DATE)
IS

--check overlapping well connecting to deferment group
CURSOR c_overlap IS
   SELECT OBJECT_ID, WELL_ID,START_DATE, END_DATE
   FROM DEFERMENT_GROUP_WELL dgw
   WHERE dgw.object_id = p_object_id
   AND dgw.well_id = p_well_id
   AND dgw.start_date <> p_start_date
   AND (p_start_date < dgw.end_date OR dgw.end_date IS NULL)
   AND (p_end_date > dgw.start_date OR p_end_date IS NULL);


BEGIN


    FOR cur_overlap IN c_overlap LOOP
       RAISE_APPLICATION_ERROR(-20226, 'An event must not overlap with the existing event period. START DATE: '
       ||cur_overlap.start_date||' END_DATE:'||cur_overlap.end_date||'\n');
    END LOOP;


END checkIfEventOverlaps;

END EcBp_Deferment_Grp_Well_Conn;