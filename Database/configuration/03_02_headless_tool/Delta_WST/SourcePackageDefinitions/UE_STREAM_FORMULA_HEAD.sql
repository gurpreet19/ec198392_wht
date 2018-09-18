CREATE OR REPLACE PACKAGE ue_stream_formula IS
/**************************************************************
** Package	:  ue_stream_formula, header part
**
** $Revision: 1.1 $
**
** Purpose	:  User exit package for evaluating user exit methods used in
**                 stream formulas.
** Created  :  03-03-2010 Azura
** General Logic:
**
** Modification history:
**
** Date:     Whom	Change description:
** --------  ---- ---------------------------------------------
**************************************************************/

FUNCTION evaluateMethod(p_object_type VARCHAR2,
                        p_object_id stream.object_id%TYPE,
                        p_method VARCHAR2,
                        p_daytime DATE,
                        p_to_date DATE DEFAULT NULL,
			p_stream_id VARCHAR2 DEFAULT NULL) RETURN NUMBER;

END ue_stream_formula;