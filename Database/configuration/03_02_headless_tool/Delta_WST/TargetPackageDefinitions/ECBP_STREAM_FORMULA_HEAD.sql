CREATE OR REPLACE PACKAGE ecbp_stream_formula IS
/**************************************************************
** Package	:  ecbp_stream_formula, header part
**
** $Revision: 1.6 $
**
** Purpose	:  Package header for evaluating generic methods used in
**                 stream formulas.
**
** General Logic:
**
** Modification history:
**
** Date:     Whom	Change description:
** --------  ---- ---------------------------------------------
** 15.03.04  EOL  Created package
** 23.07.04  kaurrnar	Removed p_sysnam and update as necessary
** 26.08.08  aliassit	ECPD-9080: Added p_stream_id to some places in function evaluateMethod
**************************************************************/

FUNCTION evaluateMethod(--p_sysnam varchar2,
                        p_object_type VARCHAR2,
                        p_object_id stream.object_id%TYPE,
                        p_method VARCHAR2,
                        p_daytime DATE,
                        p_to_date DATE DEFAULT NULL,
			p_stream_id VARCHAR2 DEFAULT NULL) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(evaluateMethod, WNDS, WNPS, RNPS);

PROCEDURE checkStrmFormulaLock(p_operation VARCHAR2, p_new_lock_columns IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns IN OUT EcDp_Month_Lock.column_list);
PROCEDURE checkStrmFormulaVariableLock(p_operation VARCHAR2, p_new_lock_columns EcDp_Month_lock.column_list, p_old_lock_columns EcDp_Month_lock.column_list);

END ecbp_stream_formula;