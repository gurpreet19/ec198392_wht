CREATE OR REPLACE PACKAGE BODY EcBp_Calc_Disp IS
/****************************************************************
** Package        :  EcBp_Calc_Disp
**
** $Revision: 1.3 $
**
** Purpose        :  This package is check if a dispatching calculation
**                   that is approved have already been run.
**
**
** Documentation  :  www.energy-components.com
**
** Created  : 06.03.2009  Olav Nćrland
**
** Modification history:
**
** Version  Date     Whom  		Change description:
** -------  ------   ----- --------------------------------------
** 1.0    06.03.2009  ON  		First version
** 1.1    07.09.2015  asareswi  Added validation for ctrl_property AllowRerunApprovedCalc flag to enable multiple execution of Approved calculation.
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : ValidateCalcRun
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : alloc_job_log
--
-- Using functions:
--
-- Configuration
-- required       : NOMCYCLE is mapped to CALC_TEXT_1
--
-- Behavior      : The function check that no approved allocation run exists for network, job, period and nomination cycle.
--                 An application error is raised if an approved run exists.
---------------------------------------------------------------------------------------------------
PROCEDURE ValidateCalcRun(
    p_calc_collection_id VARCHAR2,
    p_from_date          DATE,
    p_to_date            DATE,
    p_job_no             NUMBER,
    p_nomcycle           VARCHAR2 DEFAULT NULL,
	p_job_id             VARCHAR2)
--</EC-DOC>
IS

 cursor c_check is
SELECT run_no
FROM alloc_job_log RUN
WHERE run.CALC_COLLECTION_ID = p_calc_collection_id
  AND RUN.EXIT_STATUS='SUCCESS'
  AND RUN.ACCEPT_STATUS ='A'
  AND nvl(RUN.JOB_NO,99999) = nvl(p_job_no,99999)
  AND RUN.DAYTIME BETWEEN p_from_date AND p_to_date
  AND nvl(RUN.CALC_TEXT_1, 'XXxx') = nvl(p_nomcycle, 'XXxx')
  AND RUN.JOB_ID = p_job_id;

  lv_sys_att varchar2(32);

BEGIN
	lv_sys_att := ecdp_ctrl_property.getSystemProperty('RERUN_APPROVED_CALC', p_from_date);

	IF upper(nvl(lv_sys_att,'N')) = 'N' then
		FOR c_res IN c_check LOOP
		RAISE_APPLICATION_ERROR(-20335,'Dispatching calculation can not been run for network: ' || ec_calc_collection_version.name(p_calc_collection_id, p_from_date, '<=') || ', job: ' || ec_alloc_job_definition.name(p_job_no) || ' in period ' || to_char(p_from_date) || ' - ' || to_char(p_to_date) || ',  because an approved run exists.' );
		END LOOP;
	END IF;

END;

END EcBp_Calc_Disp;