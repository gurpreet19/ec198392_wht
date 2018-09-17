CREATE OR REPLACE PACKAGE BODY EcDp_Webo_Press_Test IS
/****************************************************************
** Package        :  EcDp_Webo_Press_Test, body part
**
** $Revision: 1.3.2.1 $
**
** Purpose        :  Provide Well Bore Press test numbers
**
** Documentation  :  www.energy-components.com
**
** Created  : 27.04.2011  Geir Olav Hagen
**
** Modification history:
**
** Date         Whom       Change description:
** --------     -----      --------------------------------------
** 27.04.2011   xxhageog   Initial version
** 02.05.2011   madondin   ECPD-17395: added new function addPreviousGradients,saveAndCalcDatumPress, toDepthPress and delPerfInterval
** 03.01.2012	madondin   ECPD-19212: modified function toDepthPress in order to control the updation of Datum Source column
** 23-01-2013   musthram   ECPD-23161: Added new function countChildEvent and deleteChildEvent
*****************************************************************/

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : assignNextGradientSeq
-- Description    : Increments the numerical sequence for a given well bore press test.
--
-- Preconditions  :
--
-- Postconditions : Autonomous transaction where only this inserted record is committed. The surrounding
--                  trnasaction will not commit.
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Creates a new assign-entry for the requested table if it is not there.
--
-------------------------------------------------------------------------------------------------
FUNCTION assignNextGradientSeq(p_event_no NUMBER)
RETURN NUMBER
--</EC-DOC>
IS
PRAGMA AUTONOMOUS_TRANSACTION;

CURSOR c_webo_press_test_grad(cp_event_no NUMBER) IS
SELECT max(gradient_seq) gradient_seq
FROM webo_press_test_grad
WHERE event_no = cp_event_no;

ln_next_val NUMBER;

BEGIN

   FOR cur_rec IN c_webo_press_test_grad(p_event_no) LOOP

      ln_next_val := Nvl(cur_rec.gradient_seq, 0) + 1;

   END LOOP;

   IF ln_next_val IS NULL THEN

      ln_next_val := 1;

   END IF;

   COMMIT;

   RETURN ln_next_val;

END assignNextGradientSeq;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : addPreviousGradients                                                           --
-- Description    : Find the last test for current well bore to copy the gradients into this test  --
--					by a trigger action on section 1. This is a class trigger action on section 1  --
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
PROCEDURE addPreviousGradients(p_event_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)

--</EC-DOC>
IS
  CURSOR c_webo_press_test_grad IS
  SELECT GRADIENT_SEQ, FROM_DEPTH, TO_DEPTH, GRADIENT, TO_DEPTH_PRESS
    from webo_press_test_grad a
   where a.event_no =
         (select a.event_no
            from webo_press_test a
           where a.object_id = p_object_id
             and a.daytime =
                 (select max(b.daytime)
                    from webo_press_test b
                   where b.object_id = p_object_id and b.event_no != p_event_no and b.daytime < p_daytime));

  ln_gradient_seq NUMBER;
  ln_from_depth   NUMBER;
  ln_to_depth     NUMBER;
  ln_gradient     NUMBER;
  ln_depth_press  NUMBER;

BEGIN


    FOR cur_webo_press_test_grad IN c_webo_press_test_grad LOOP

        ln_gradient_seq := cur_webo_press_test_grad.gradient_seq;
        ln_from_depth := cur_webo_press_test_grad.from_depth;
        ln_to_depth :=  cur_webo_press_test_grad.to_depth;
        ln_gradient := cur_webo_press_test_grad.gradient;
        ln_depth_press := cur_webo_press_test_grad.to_depth_press;

        INSERT INTO WEBO_PRESS_TEST_GRAD(EVENT_NO,OBJECT_ID,GRADIENT_SEQ, FROM_DEPTH, TO_DEPTH, GRADIENT, TO_DEPTH_PRESS)
        VALUES(p_event_no, p_object_id, ln_gradient_seq, ln_from_depth, ln_to_depth, ln_gradient, ln_to_depth);

    END LOOP;


END addPreviousGradients;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : saveAndCalcDatumPress                                                          --
-- Description    : This package will perform the complete calculation of the TVD press to the     --
--                  datum pressure and store the value in the datum press in section one, but      --
--                  if the datum pressure have a manual source it is not suppose to override the   --
--                  datum press in section 1. The calculation itself is described in the excel     --
--                  spreadsheet, and you need to use the gradient sequence for the calculation,    --
--                  since the depth can go up and down.                                            --
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
PROCEDURE saveAndCalcDatumPress(p_event_no NUMBER, p_object_id VARCHAR2, p_datum_press NUMBER)

--</EC-DOC>
IS

  lr_webo_press_test_rec webo_press_test%ROWTYPE;

BEGIN

  lr_webo_press_test_rec := ec_webo_press_test.row_by_pk(p_event_no);

  IF (lr_webo_press_test_rec.datum_source IS NULL) THEN

        UPDATE WEBO_PRESS_TEST wbt
        SET wbt.datum_source = 'MANUAL'
        WHERE wbt.event_no = p_event_no;

  ELSIF (lr_webo_press_test_rec.datum_source = 'CALC' OR lr_webo_press_test_rec.datum_press <> p_datum_press) THEN

        UPDATE WEBO_PRESS_TEST wbt
        SET wbt.datum_source = 'MANUAL'
        WHERE wbt.event_no = p_event_no;
  END IF;

END saveAndCalcDatumPress;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : toDepthPress                                                                   --
-- Description    : Use the current row in the gradient screen looking at the from and to date and --
--                  calculate the specific to depth press with the gradients.                      --
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
PROCEDURE toDepthPress(p_event_no NUMBER, p_object_id VARCHAR2, p_user VARCHAR2)

--</EC-DOC>
IS
  CURSOR c_calc_depth_press IS
         SELECT GRADIENT_SEQ, FROM_DEPTH, TO_DEPTH, GRADIENT, TO_DEPTH_PRESS
         from webo_press_test_grad a
         where a.event_no = p_event_no ORDER BY a.gradient_seq;


  ln_gradient_seq         NUMBER;
  ln_from_depth           NUMBER;
  ln_to_depth             NUMBER;
  ln_gradient             NUMBER;
  ln_depth_press          NUMBER;
  ln_depth_press_temp     NUMBER;
  lv2_first               VARCHAR2(32);
  lv2_datum_source        VARCHAR2(32);

  lr_webo_press_test_rec webo_press_test%ROWTYPE;

BEGIN

  lv2_first := 'Y';
  lr_webo_press_test_rec := ec_webo_press_test.row_by_pk(p_event_no);
  lv2_datum_source := lr_webo_press_test_rec.datum_source;


    FOR cur_webo_press_test_grad IN c_calc_depth_press LOOP
        ln_gradient_seq := cur_webo_press_test_grad.gradient_seq;
        ln_from_depth := cur_webo_press_test_grad.from_depth;
        ln_to_depth :=  cur_webo_press_test_grad.to_depth;
        ln_gradient := cur_webo_press_test_grad.gradient;
        IF (lv2_first = 'Y') THEN
           ln_depth_press := lr_webo_press_test_rec.tdv_press + (ln_to_depth - ln_from_depth) * ln_gradient;
           ln_depth_press_temp := ln_depth_press;
           lv2_first := 'N';
        ELSE
           ln_depth_press := ln_depth_press_temp + (ln_to_depth - ln_from_depth) * ln_gradient;
           ln_depth_press_temp := ln_depth_press;
        END IF;

        UPDATE WEBO_PRESS_TEST_GRAD wptg
        SET wptg.to_depth_press = ln_depth_press,
        wptg.last_updated_by = p_user
        WHERE EVENT_NO = p_event_no AND GRADIENT_SEQ = ln_gradient_seq
        and object_id =  p_object_id;



    END LOOP;

        IF (lv2_datum_source = 'MANUAL') AND (ln_depth_press IS NOT NULL) THEN
          UPDATE WEBO_PRESS_TEST SET datum_source = 'CALC',
          datum_press = ln_depth_press,
          last_updated_by = p_user
          WHERE EVENT_NO = p_event_no;

        ELSIF (ln_depth_press IS NULL) THEN
          UPDATE WEBO_PRESS_TEST SET datum_source = NULL,
          datum_press = ln_depth_press,
          last_updated_by = p_user
          WHERE EVENT_NO = p_event_no;

        ELSE
          UPDATE WEBO_PRESS_TEST SET datum_source = 'CALC',
          datum_press = ln_depth_press,
           last_updated_by = p_user
          WHERE EVENT_NO = p_event_no;

        END IF;




END toDepthPress;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : delPerfInterval                                                          	   --
-- Description    : This function is to check whether there's any child in Perforation Interval    --
--					screen, if have, need to delete the child first before delete the Well Bore    --
--					Interval 																	   --
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
PROCEDURE delPerfInterval(p_event_no NUMBER,p_object_id VARCHAR2)

--</EC-DOC>
IS

ln_del_wpt_perf_count	INTEGER;

BEGIN

  ln_del_wpt_perf_count := 0;

  SELECT COUNT(*)
	INTO 	ln_del_wpt_perf_count
  FROM webo_press_test_perf a
	WHERE  a.event_no = p_event_no and a.webo_interval_id = p_object_id;


  IF p_event_no IS NOT NULL and ln_del_wpt_perf_count > 0 THEN
	  Raise_Application_Error(-20234,'Records in Perforation Interval must be deleted first.');
  END IF;


END delPerfInterval;

-----------------------------------------------------------------
-- Function:    getDepthToPress
-- Description: Returns depth to press
--
--
-----------------------------------------------------------------
FUNCTION getDepthToPress(p_event_no NUMBER, p_object_id VARCHAR2, p_grad_seq NUMBER)
RETURN NUMBER IS

	 CURSOR c_calc_depth_press_grad IS
         SELECT GRADIENT_SEQ, FROM_DEPTH, TO_DEPTH, GRADIENT, TO_DEPTH_PRESS
         from webo_press_test_grad a
         where a.event_no = p_event_no AND a.gradient_seq < p_grad_seq ORDER BY a.gradient_seq;


  lr_webo_press_test_rec         webo_press_test%ROWTYPE;
  lr_webo_press_test_grad        webo_press_test_grad%ROWTYPE;

  ln_gradient_seq                NUMBER;
  ln_from_depth                  NUMBER;
  ln_to_depth                    NUMBER;
  ln_gradient                    NUMBER;
  ln_depth_press                 NUMBER;
  ln_depth_press_temp            NUMBER;
  lv2_first                      VARCHAR2(32);
  ln_count                       NUMBER;
  ln_return_val                  NUMBER;

BEGIN
   lv2_first := 'Y';
   lr_webo_press_test_rec := ec_webo_press_test.row_by_pk(p_event_no);
   lr_webo_press_test_grad := ec_webo_press_test_grad.row_by_pk(p_event_no,p_object_id,p_grad_seq );


   select count(*) into ln_count from webo_press_test_grad a where a.event_no = p_event_no and a.gradient_seq < p_grad_seq;

   IF (ln_count < 1 OR ln_count is null) THEN

      ln_depth_press_temp := lr_webo_press_test_rec.tdv_press;

   ELSE

    FOR cur_webo_press_test_grad IN c_calc_depth_press_grad LOOP
        ln_gradient_seq := cur_webo_press_test_grad.gradient_seq;
        ln_from_depth := cur_webo_press_test_grad.from_depth;
        ln_to_depth :=  cur_webo_press_test_grad.to_depth;
        ln_gradient := cur_webo_press_test_grad.gradient;
        IF (lv2_first = 'Y') THEN
           ln_depth_press := lr_webo_press_test_rec.tdv_press + (ln_to_depth - ln_from_depth) * ln_gradient;
           ln_depth_press_temp := ln_depth_press;
           lv2_first := 'N';
        ELSE
           ln_depth_press := ln_depth_press_temp + (ln_to_depth - ln_from_depth) * ln_gradient;
           ln_depth_press_temp := ln_depth_press;
        END IF;
     END LOOP;


    END IF;

   ln_from_depth := lr_webo_press_test_grad.from_depth;
   ln_to_depth := lr_webo_press_test_grad.to_depth;
   ln_gradient := lr_webo_press_test_grad.gradient;
   ln_depth_press := ln_depth_press_temp;
   ln_return_val := ln_depth_press_temp + (ln_to_depth - ln_from_depth)*ln_gradient;

   RETURN ln_return_val;

END getDepthToPress;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : deleteChildEvent
-- Description    : Delete child events. Child table is WEBO_PRESS_TEST_PERF, WEBO_PRESS_TEST_INT,
--                  WEBO_PRESS_TEST_GRAD, parent table is WEBO_PRESS_TEST.
--
--
-- Preconditions  : All Child records related to the Event No will be deleted first.
-- Postconditions : Parent Test Record will be deleted finally.
--
-- Using tables   : WEBO_PRESS_TEST_PERF, WEBO_PRESS_TEST_INT, WEBO_PRESS_TEST_GRAD
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
PROCEDURE deleteChildEvent(p_event_no NUMBER)
--</EC-DOC>
IS

BEGIN

  DELETE FROM WEBO_PRESS_TEST_PERF where event_no = p_event_no;
  DELETE FROM WEBO_PRESS_TEST_INT WHERE event_no = p_event_no;
  DELETE FROM WEBO_PRESS_TEST_GRAD WHERE event_no = p_event_no;

END deleteChildEvent;

--<EC-DOC>

---------------------------------------------------------------------------------------------------
-- Procedure      : countChildEvent
-- Description    : Count child events exist for the parent test. Child table is WEBO_PRESS_TEST_PERF,
--                  WEBO_PRESS_TEST_INT, WEBO_PRESS_TEST_GRAD, parent table is WEBO_PRESS_TEST.
--
--
-- Preconditions  :
-- Postconditions : .
--
-- Using tables   : WEBO_PRESS_TEST_PERF, WEBO_PRESS_TEST_INT, WEBO_PRESS_TEST_GRAD
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
FUNCTION countChildEvent(p_event_no NUMBER)
RETURN NUMBER
--</EC-DOC>
IS

  CURSOR c_child_event  IS
        select sum(totalrecord) totalrecord from
        (
          SELECT count(object_id) totalrecord
          FROM WEBO_PRESS_TEST_GRAD
          WHERE event_no = p_event_no
          UNION ALL
          SELECT count(object_id) totalrecord
          FROM WEBO_PRESS_TEST_INT
          WHERE event_no = p_event_no
          UNION ALL
          SELECT count(object_id) totalrecord
          FROM WEBO_PRESS_TEST_PERF
          WHERE event_no = p_event_no
         );

 ln_child_record NUMBER;

BEGIN

  ln_child_record := 0;

  FOR cur_child_event IN c_child_event LOOP
    ln_child_record := cur_child_event.totalrecord ;
  END LOOP;

  return ln_child_record;

END countChildEvent;

END EcDp_Webo_Press_Test;
