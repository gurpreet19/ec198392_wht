CREATE OR REPLACE PACKAGE BODY ue_Contract_Dispatching IS
/******************************************************************************
** Package        :  ue_Contract_Dispatching, body part
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

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : apportionSubDaily
-- Description    : User exit function for spliting the corrected value from the input field into corrected
--                   column in the SubDaily section
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE apportionSubDaily(p_object_id       VARCHAR2,
                            p_field_id        VARCHAR2,
                            p_production_day  DATE,
                            p_corrected_value NUMBER,
                            p_user            VARCHAR2 DEFAULT NULL,
                            p_class_name      VARCHAR2 DEFAULT 'GAS_DAY_EXP_AND_FUEL'
)

--</EC-DOC>

IS

BEGIN

     NULL;

END apportionSubDaily;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : populate_qa_handling_comp
-- Description    : Populate quality handling comp table. User exit function
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE populate_qa_handling_comp(p_quality_handling_no NUMBER)
IS

  CURSOR c_comp_set_list(b_component_set VARCHAR2
                        ,b_daytime DATE)
  IS
  SELECT   csl.component_no
  FROM     comp_set_list csl
  WHERE    csl.component_set = b_component_set
  AND      csl.daytime <= b_daytime
  AND      NVL(csl.end_date, b_daytime +1) >= b_daytime;

BEGIN

  FOR r_comp_set_list IN c_comp_set_list('TR_QUALITY_COMP',ec_cntr_quality_handling.daytime(p_quality_handling_no))
  LOOP

    INSERT INTO cntr_quality_comp(quality_handling_no, component_no, created_by)
    VALUES (p_quality_handling_no, r_comp_set_list.component_no, ecdp_context.getAppUser);

  END LOOP;

END populate_qa_handling_comp;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : remove_qa_handling_comp
-- Description    : Remove quality comp. User exit function
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE remove_qa_handling_comp(p_quality_handling_no NUMBER)
  IS

BEGIN

  DELETE FROM cntr_quality_comp qc
  WHERE qc.quality_handling_no = p_quality_handling_no;

END remove_qa_handling_comp;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : aggregateSubDaily
-- Description    : Is needed in the product package is because of the Update button in the Wet Gas Export and Fuel screen
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE aggregateSubDaily(p_class_name      VARCHAR2 DEFAULT 'GAS_DAY_EXP_AND_FUEL',
                            p_stream_mapping  VARCHAR2,
                            p_profitcentre_id VARCHAR2,
                            p_stream_id       VARCHAR2,
                            p_production_day  DATE,
                            p_user            VARCHAR2 DEFAULT NULL
)
--</EC-DOC>

IS

BEGIN

     NULL;

END aggregateSubDaily;

END ue_Contract_Dispatching;