create or replace PACKAGE ue_calc_engine IS
/******************************************************************************
** Package        :  ue_calc_engine, head part
**
** $Revision: 1.2 $
**
** Purpose        :  User exit package called from the calculation engine.
**
** Documentation  :  www.energy-components.com
**
** Created        :  09.05.2006	Hanne Austad
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
********************************************************************/

PROCEDURE postDataWrite(
	p_runno		NUMBER,                             /* alloc_job_log.run_no for the calling calc engine transaction */
	p_transstart	VARCHAR2,                       /* Start date for the calling calc engine transaction, received as string since a DST flag is postfixed, must be parsed in routine */
	p_transend	VARCHAR2,                              /* End date for the calling calc engine transaction */
	p_startdate	DATE,                               /* Value of 'startdate' calc engine parameter */
	p_enddate	DATE,                               /* Value of 'enddate' calc engine parameter */
	p_context	VARCHAR2,                           /* Value of 'context' calc engine parameter */
	p_jobcode	VARCHAR2,                           /* Value of 'jobcode' calc engine parameter */
	p_loglevel	VARCHAR2,                           /* Value of 'loglevel' calc engine parameter */
	p_period	VARCHAR2,                           /* Value of 'period' calc engine parameter */
	p_network_id    VARCHAR2,                           /* Value of 'network_id' calc engine parameter */
	p_dataset       VARCHAR2,                           /* Value of 'dataset' calc engine parameter */
	p_extra_params	VARCHAR2);                          /* Additional calc engine parameters passed as a semi-colon separated string of <param name>=<param value> */

------------------------calcObjAttrFilter---------------------------------------------------------------------------
-- Function       : calcObjAttrFilter
-- Description    : Returns true if should be included
---------------------------------------------------------------------------------------------------
FUNCTION calcObjAttrFilter(
	p_startdate	DATE,                               /* Value of 'startdate' calc engine parameter */
	p_enddate	DATE,                               /* Value of 'enddate' calc engine parameter */
	p_object_type	VARCHAR2,                           /* Value of className */
	p_attr_name	VARCHAR2,                           /* Value of attribute name (sqlSyntax) */
	p_attr_value	VARCHAR2,                       /* Value of attribute */
	p_engineparams	Ecdp_Calculation.PARAM_MAP                       /* Value of calc engine parameter names semicolon separated */
	)	RETURN VARCHAR2;							/* return 'Y' for true */
END;
/