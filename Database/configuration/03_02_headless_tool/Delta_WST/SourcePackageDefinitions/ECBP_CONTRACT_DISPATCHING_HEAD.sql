CREATE OR REPLACE PACKAGE EcBp_Contract_Dispatching IS
/****************************************************************
** Package	:  EcBp_Contract_Dispatching
**
** $Revision: 1.5 $
**
** Purpose	:
**
** Documentation  :  www.energy-components.com
**
** Created  : 12.01.2006  by Kristin Eide
**
** Modification history:
**
** Date	   Whom  	 	Change description:
** --------   ----- 		--------------------------------------
** 12.01.06	eideekri   	Initial version
** 13.01.06	Jean Ferre	Added a procedure ApportionSubDaily
** 27.02.06	kallesve	Added the aggregateSubDaily procedure
** 28.09.06 	siahohwi  	Added apportionNGLSubDaily procedure
**27.01.09  masamken change this table STRM_SUB_DAY_FLD_SCHEME to STRM_SUB_DAY_SCHEME, and attribute feild_id to parent_object_id
******************************************************************/

FUNCTION  getCellValue(
	p_column 	VARCHAR2,
	p_object_id 	VARCHAR2,
	p_parent_object_id 	VARCHAR2,
	p_daytime 	DATE,
	p_summer_time 	VARCHAR2)

RETURN NUMBER;

PROCEDURE apportionSubDaily(
  	p_object_id		VARCHAR2,
  	p_parent_object_id		VARCHAR2,
  	p_production_day	DATE,
   p_corrected_value	NUMBER,
   p_user 		VARCHAR2	DEFAULT NULL,
  p_class_name    VARCHAR2  DEFAULT 'GAS_DAY_EXP_AND_FUEL'
);

PROCEDURE aggregateSubDaily(
	p_class_name VARCHAR2,
  	p_stream_mapping		VARCHAR2,
   	p_profitcentre_id   		VARCHAR2,
	p_stream_id VARCHAR2,
	  p_production_day	DATE,
   	p_user 			VARCHAR2 	DEFAULT NULL

);

PROCEDURE apportionNGLSubDaily(
  	p_object_id		VARCHAR2,
  	p_production_day	DATE,
   p_corrected_value	NUMBER,
   p_user 		VARCHAR2	DEFAULT NULL
);

END EcBp_Contract_Dispatching;