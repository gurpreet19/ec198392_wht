CREATE OR REPLACE PACKAGE ue_Contract_Dispatching IS
/******************************************************************************
** Package        :  ue_Contract_Dispatching, head part
**
** $Revision: 1.4 $
**
** Purpose        :  user exit functions should be put here
**
** Documentation  :  www.energy-components.com
**
** Created        :  21.03.2007 Narinder Kaur
**
** Modification history:
**
** Date        	Whom     	Change description:
** ------      	-----    	-----------------------------------------------------------------------------------------------
** 02-Jan-2012 	xxsteino 	ECPD-19662: added procedures populate_qa_handling_comp and remove_qa_handling_comp
** 13-Aug-2013	muhammah	ECPD-24691: added procedure aggregateSubDaily
********************************************************************/


PROCEDURE apportionSubDaily(p_object_id VARCHAR2, p_field_id VARCHAR2, p_production_day DATE, p_corrected_value NUMBER, p_user VARCHAR2 DEFAULT NULL, p_class_name VARCHAR2 DEFAULT 'GAS_DAY_EXP_AND_FUEL');

PROCEDURE populate_qa_handling_comp(p_quality_handling_no NUMBER);

PROCEDURE remove_qa_handling_comp(p_quality_handling_no NUMBER);

PROCEDURE aggregateSubDaily(p_class_name VARCHAR2 DEFAULT 'GAS_DAY_EXP_AND_FUEL', p_stream_mapping VARCHAR2, p_profitcentre_id VARCHAR2, p_stream_id VARCHAR2, p_production_day DATE, p_user VARCHAR2 DEFAULT NULL);

END ue_Contract_Dispatching;