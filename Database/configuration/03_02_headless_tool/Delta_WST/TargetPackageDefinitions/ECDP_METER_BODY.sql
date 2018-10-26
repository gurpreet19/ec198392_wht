CREATE OR REPLACE PACKAGE BODY EcDp_Meter IS
/****************************************************************
** Package        :  EcDp_Meter; body part
**
** $Revision: 1.6 $
**
** Purpose        :  Handles validation on class Meter
**
** Documentation  :  www.energy-components.com
**
** Created        :  06.03.2008 Solveig I. Monsen
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------
** 11.02.09    Olav Nærland Added getProductionDay
**************************************************************************************************/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validateMeter
-- Description    : Validates meter object relations based on meter type
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
-- Behaviour      : Each metertype (ENTRY, EXIT, FUEL, TRANSIT)  has a set of predefined legal associated relation objects.
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateMeter(p_METER_TYPE VARCHAR2,p_DELIVERY_STREAM_ID VARCHAR2,p_DELIVERY_POINT_ID VARCHAR2,p_PIPE_SEGMENT_ID VARCHAR2)
--</EC-DOC>
IS

BEGIN
    IF ((p_METER_TYPE = 'ENTRY') OR (p_METER_TYPE = 'EXIT')) THEN
        validateMeterTypeEntryExit(p_DELIVERY_STREAM_ID, p_DELIVERY_POINT_ID, p_PIPE_SEGMENT_ID);
    ELSIF ((p_METER_TYPE = 'FUEL')) THEN
        validateMeterTypeFuel(p_DELIVERY_STREAM_ID, p_DELIVERY_POINT_ID, p_PIPE_SEGMENT_ID);
    ELSE
        validateMeterTypeTransit(p_DELIVERY_STREAM_ID, p_DELIVERY_POINT_ID, p_PIPE_SEGMENT_ID);
    END IF;

END validateMeter;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validateMeterTypeEntryExit
-- Description    :
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
-- Behaviour      : checks that accepted classrelations are set for metertype=ENTRY.
-- Legal combination of class relations: [Delivery Stream, Delivery Point]
--
---------------------------------------------------------------------------------------------------

PROCEDURE validateMeterTypeEntryExit(p_DELIVERY_STREAM_ID VARCHAR2,p_DELIVERY_POINT_ID VARCHAR2,p_PIPE_SEGMENT_ID VARCHAR2)
IS
          correctCombination BOOLEAN;

BEGIN
    correctCombination := FALSE;

    IF ((p_DELIVERY_STREAM_ID IS NOT NULL) AND (p_DELIVERY_POINT_ID IS NOT NULL) AND (p_PIPE_SEGMENT_ID IS NULL)) THEN
        correctCombination := TRUE;
    END IF;
    IF (correctCombination = FALSE) THEN
        RAISE_APPLICATION_ERROR(-20527, 'Incorrect relation. Meters of type ENTRY and EXIT require a Delivery Stream and a Delivery Point relation.'
);
    END IF;
END validateMeterTypeEntryExit;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validateMeterTypeFuel
-- Description    :
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
-- Behaviour      : checks that accepted classrelations are set for metertype=FUEL.
-- Legal combination of class relations: a)	Delivery Point b)	[Delivery Point, Delivery Stream] or [Delivery Point,  Pipeline Segment]

--
---------------------------------------------------------------------------------------------------

PROCEDURE validateMeterTypeFuel(p_DELIVERY_STREAM_ID VARCHAR2,p_DELIVERY_POINT_ID VARCHAR2,p_PIPE_SEGMENT_ID VARCHAR2)
IS
          correctCombination BOOLEAN;

BEGIN
    correctCombination := FALSE;

    IF ((p_DELIVERY_STREAM_ID IS NULL) AND (p_DELIVERY_POINT_ID IS NOT NULL) AND (p_PIPE_SEGMENT_ID IS NULL)) THEN
        correctCombination := TRUE;
    ELSIF ((p_DELIVERY_STREAM_ID IS NOT NULL) AND (p_DELIVERY_POINT_ID IS NOT NULL) AND (p_PIPE_SEGMENT_ID IS NULL)) THEN
        correctCombination := TRUE;
    ELSIF ((p_DELIVERY_STREAM_ID IS NULL) AND (p_DELIVERY_POINT_ID IS NOT NULL) AND (p_PIPE_SEGMENT_ID IS NOT NULL)) THEN
        correctCombination := TRUE;
    ELSE
        correctCombination := FALSE;
    END IF;

    IF (correctCombination = FALSE) THEN
        RAISE_APPLICATION_ERROR(-20528, 'Incorrect relation. Meters of type FUEL require either a Delivery Point relation or a combination of Delivery Point, Delivery Stream relation or a combination of a Delivery Point, Pipeline Segment relation.');

    END IF;
END validateMeterTypeFuel;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validateMeterTypeTransit
-- Description    :
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
-- Behaviour      : checks that accepted classrelations are set for metertype=TRANSIT.
-- Legal combination of class relations: [Delivery Point, Pipeline Segment] or [Delivery Point, Delivery Stream]


--
---------------------------------------------------------------------------------------------------

PROCEDURE validateMeterTypeTransit(p_DELIVERY_STREAM_ID VARCHAR2,p_DELIVERY_POINT_ID VARCHAR2,p_PIPE_SEGMENT_ID VARCHAR2)
IS
          correctCombination BOOLEAN;

BEGIN
    correctCombination := FALSE;

    IF ((p_DELIVERY_STREAM_ID IS NULL) AND (p_DELIVERY_POINT_ID IS NOT NULL) AND (p_PIPE_SEGMENT_ID IS NOT NULL)) THEN
        correctCombination := TRUE;
    ELSIF ((p_DELIVERY_STREAM_ID IS NOT NULL) AND (p_DELIVERY_POINT_ID IS NOT NULL) AND (p_PIPE_SEGMENT_ID IS NULL)) THEN
        correctCombination := TRUE;
    ELSE
        correctCombination := FALSE;
    END IF;

    IF (correctCombination = FALSE) THEN
        RAISE_APPLICATION_ERROR(-20529, 'Incorrect relation. Meters of type TRANSIT require either a combination of a Delivery Point, Pipeline Segment relation or a combination of a Delivery Point, Delivery Stream relation.');
    END IF;
END validateMeterTypeTransit;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : hasDeliveryStreamMeter
-- Description    : Get meter id on meter
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
FUNCTION hasDeliveryStreamMeter(p_delivery_stream_id VARCHAR2, p_daytime DATE)
RETURN VARCHAR2
--</EC-DOC>
IS
	CURSOR c_exist (cp_delivery_stream_id VARCHAR2, cp_daytime DATE) IS
		SELECT t.object_id, t.name,  t.daytime, t.delivery_point_id, t.delivery_stream_id, t.pipeline_segment_id
		FROM meter_version t
		WHERE t.delivery_stream_id = cp_delivery_stream_id
		AND daytime <= cp_daytime
		AND Nvl(end_date, cp_daytime+1) > cp_daytime;

	lv_exist VARCHAR2(1):= 'N';
BEGIN
	FOR curExist IN c_exist(p_delivery_stream_id , p_daytime) LOOP
		lv_exist := 'Y';
	END LOOP;

   RETURN lv_exist;
END hasDeliveryStreamMeter;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : hasDeliveryStreamMeter
-- Description    : Get meter id on meter
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
FUNCTION hasPipelineSegmentMeter(p_pipeline_segment_id VARCHAR2, p_daytime DATE)
RETURN VARCHAR2
--</EC-DOC>
IS
	CURSOR c_exist (cp_pipeline_segment_id VARCHAR2, cp_daytime DATE) IS
		SELECT t.object_id, t.name,  t.daytime, t.delivery_point_id, t.delivery_stream_id, t.pipeline_segment_id
		FROM meter_version t
		WHERE t.pipeline_segment_id = cp_pipeline_segment_id
		AND daytime <= cp_daytime
		AND Nvl(end_date, cp_daytime+1) > cp_daytime;

	lv_exist VARCHAR2(1):= 'N';
BEGIN
	FOR curExist IN c_exist(p_pipeline_segment_id , p_daytime) LOOP
		lv_exist := 'Y';
	END LOOP;

   RETURN lv_exist;
END hasPipelineSegmentMeter;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getProductionDay
-- Description    : Return the production day to the meter.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:  ec_meter_version, EcDp_Date_Time
--
-- Configuration
-- required       :
--
-- Behaviour      : Find the production day definition to the meter. If not configured, use the default production day.
--                  Return the production day to the daytime based on the production day definition.
---------------------------------------------------------------------------------------------------
FUNCTION getProductionDay(p_object_id  VARCHAR2, p_daytime  DATE, p_summertime_flag VARCHAR2 DEFAULT NULL)

RETURN DATE
--</EC-DOC>
IS
  lv2_pdd_object_id   VARCHAR2(32);
  lv2_summertime_flag VARCHAR2(1);
  ld_production_day   DATE;

BEGIN
  lv2_pdd_object_id := Nvl(ec_meter_version.production_day_id(p_object_id,p_daytime,'<='),Ecdp_Date_Time.getDefaultProdDayDefinition(p_daytime));

  IF p_summertime_flag IS NULL THEN
    lv2_summertime_flag := Ecdp_Date_Time.summertime_flag(p_daytime);
  ELSE
    lv2_summertime_flag := p_summertime_flag;
  END IF;

  ld_production_day := Ecdp_Date_Time.getProductionDay(lv2_pdd_object_id,p_daytime,lv2_summertime_flag);

  RETURN TRUNC(ld_production_day);

END getProductionDay;

END EcDp_Meter;