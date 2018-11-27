CREATE OR REPLACE PACKAGE BODY EcBp_Contract_Pc_Conn IS
/****************************************************************
** Package        :  EcBp_Contract_Pc_Conn; body part
**
** $Revision: 1.1 $
**
** Purpose        :  Handles validation on Contract Profit Centre (Company) List screens
**
** Documentation  :  www.energy-components.com
**
** Created        :  15.12.2005	Stian Skjørestad
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------

**************************************************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : valSctrPcCompany
-- Description    : Validates date period for overlap.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : cntr_pc_company
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Validates that rows with same contract, profit_centre and company does not have date-period overlap
--
---------------------------------------------------------------------------------------------------
PROCEDURE valSctrPcCompany(p_contract_id VARCHAR2)
--</EC-DOC>
IS

-- Check for overlapping
CURSOR c_val(cp_contract_id     VARCHAR2)
IS
	SELECT DISTINCT s.object_id, s.profit_centre_id, s.company_id
	FROM 	cntr_pc_company s
	WHERE 	s.object_id = cp_contract_id;

BEGIN

	FOR tmp_val IN c_val(p_contract_id) LOOP
	      validateDatePeriod(tmp_val.object_id, tmp_val.profit_centre_id, tmp_val.company_id);
	END LOOP;
END valSctrPcCompany;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : valSctrPc
-- Description    : Validates date period for overlap.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : cntr_pc_conn
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Validates that rows with same contract, profit_centre and company does not have date-period overlap
--
---------------------------------------------------------------------------------------------------
PROCEDURE valSctrPc(p_contract_id VARCHAR2)
--</EC-DOC>
IS

-- Check for overlapping
CURSOR c_val(cp_contract_id     VARCHAR2)
IS
	SELECT 	DISTINCT s.object_id, s.profit_centre_id
	FROM 	cntr_pc_conn s
	WHERE 	s.object_id = cp_contract_id;

BEGIN

	FOR tmp_val IN c_val(p_contract_id) LOOP
	      validateDatePeriod(tmp_val.object_id, tmp_val.profit_centre_id);
	END LOOP;
END valSctrPc;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validateDatePeriod
-- Description    : Validates date period for overlap.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : cntr_pc_company, cntr_pc_conn
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Validates that rows with same contract, profit_centre and company does not have date-period overlap
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateDatePeriod(p_contract_id     VARCHAR2,
			     p_profit_centre_id VARCHAR2,
  			     p_company_id VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS

	CURSOR c_pc_company(cp_contract_id     VARCHAR2,
				       cp_profit_centre_id VARCHAR2,
	  			       cp_company_id VARCHAR2)
	IS

	SELECT 'a'
	FROM cntr_pc_company s, cntr_pc_company a
	WHERE cp_contract_id = s.object_id
	AND cp_profit_centre_id = s.profit_centre_id
	AND cp_company_id = s.company_id
	    AND a.object_id = s.object_id
	    AND a.profit_centre_id = s.profit_centre_id
	    AND a.company_id = s.company_id
	    AND s.daytime <> a.daytime
	    AND Nvl(s.end_date, a.daytime+1) > a.daytime
	    AND s.daytime < nvl(a.end_date, s.daytime+1);


	CURSOR c_pc(cp_contract_id     VARCHAR2,
				    cp_profit_centre_id VARCHAR2)
	IS
	SELECT 'a'
	FROM cntr_pc_conn s, cntr_pc_conn a
	WHERE cp_contract_id = s.object_id
	AND cp_profit_centre_id = s.profit_centre_id
	    AND a.object_id = s.object_id
	    AND a.profit_centre_id = s.profit_centre_id
	    AND s.daytime <> a.daytime
	    AND Nvl(s.end_date, a.daytime+1) > a.daytime
	    AND s.daytime < nvl(a.end_date, s.daytime+1);


BEGIN

IF p_company_id IS NOT NULL THEN
	FOR ITEM IN c_pc_company(p_contract_id, p_profit_centre_id, p_company_id) LOOP
	      Raise_Application_Error(-20121, 'The date overlaps with another period');
	END LOOP;

ELSE
	FOR ITEM IN c_pc(p_contract_id, p_profit_centre_id) LOOP
	      Raise_Application_Error(-20121, 'The date overlaps with another period');
	END LOOP;
END IF;


END validateDatePeriod;

END EcBp_Contract_Pc_Conn;