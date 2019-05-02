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
/


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

      ln_return_value NUMBER;
	  lr_analysis_sample  object_fluid_analysis%ROWTYPE;
      lv2_profit_centre_id VARCHAR2(32);							 
BEGIN
   IF p_method = 'USER_EXIT_01' then

        --UE Handle Multi-use Separator phases split based on profit center
        IF p_object_type IN ('STREAM' ) THEN

            select profit_centre_id into lv2_profit_centre_id from DV_STRM_PROFIT_CENTRE_CONN where object_id = p_stream_id and daytime <= p_daytime and p_daytime < nvl(end_date,p_daytime+1);

            IF lv2_profit_centre_id is not null then

                select split into ln_return_value from DV_STRM_PC_SPLIT
                where object_id = p_object_id
                and profit_centre_id = lv2_profit_centre_id
                --tlxt 23-Feb-2016: work item 106167
                --and daytime <= p_daytime
                --and end_date is null;
                AND p_daytime >= daytime
                AND p_daytime < nvl(end_date,p_daytime+1);
                --end edit tlxt 23-Feb-2016: work item 106167
            END IF;

        END IF;

    END IF;

    IF p_method = 'USER_EXIT_02' then

        --UE Handle returning Out of Service Flag from the DRY or WET Flare Header streams
        IF p_object_type IN ('STREAM') THEN

            select decode(OOS_FLAG,NULL,0,'N',0,'Y',1) into ln_return_value from DV_STRM_DAY_STREAM_MEAS_GAS where object_id = p_object_id and daytime = p_daytime;

        END IF;

    END IF;

    IF p_method = 'USER_EXIT_03' then

        --UE Handle returning In Use Fall Back calculation Flag from the DRY or WET Flare Header streams
        IF p_object_type IN ('STREAM') THEN

            select decode(FB_CALC_FLAG,NULL,0,'N',0,'Y',1) into ln_return_value from DV_STRM_DAY_STREAM_MEAS_GAS where object_id = p_object_id and daytime = p_daytime;

        END IF;

    END IF;

	IF p_method = 'USER_EXIT_04' THEN

		IF p_object_type IN('STREAM')THEN

			lr_analysis_sample :=Ecdp_Fluid_Analysis.getLastAnalysisSample(p_object_id,'STRM_LNG_COMP',null,p_daytime);

			ln_return_value:= lr_analysis_sample.value_46;

		END IF;

	END IF;

    return ln_return_value;
END evaluateMethod;

END ue_stream_formula;
/
