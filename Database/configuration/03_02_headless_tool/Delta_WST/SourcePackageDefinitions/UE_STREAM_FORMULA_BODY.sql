CREATE OR REPLACE PACKAGE BODY ue_stream_formula IS
/**************************************************************
** Package	:  ue_stream_formula, body part
**
** $Revision: 1.1 $
**
** Purpose	:  User exit package for evaluating user exit methods used in
**                 stream formulas.
** Created        :  03.02.2010	Azura
** General Logic:
**
** Modification history:
**
** Date:     Whom	Change description:
** --------  ---- ---------------------------------------------
**************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : evaluateMethod
-- Description    : Function to parse methods described in <p_method>,
--                  translate these into PLSQL package calls,
--                  execute these and return the answer
---------------------------------------------------------------------------------------------------
FUNCTION evaluateMethod(
      p_object_type VARCHAR2,
      p_object_id stream.object_id%TYPE,
      p_method  VARCHAR2,
      p_daytime DATE,
      p_to_date DATE DEFAULT NULL,
      p_stream_id VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
--</EC-DOC>
      IS

BEGIN
  RETURN NULL;
END evaluateMethod;

END ue_stream_formula;