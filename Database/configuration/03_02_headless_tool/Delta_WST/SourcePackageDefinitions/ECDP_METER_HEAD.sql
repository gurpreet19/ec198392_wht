CREATE OR REPLACE PACKAGE EcDp_Meter IS
/****************************************************************
** Package        :  EcDp_Meter; head part
**
** $Revision: 1.5 $
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
** 11.02.09    Olav N�and Added getProductionDay
**************************************************************************************************/

PROCEDURE validateMeter(p_METER_TYPE VARCHAR2,p_DELIVERY_STREAM_ID VARCHAR2,p_DELIVERY_POINT_ID VARCHAR2,p_PIPE_SEGMENT_ID VARCHAR2);
PROCEDURE validateMeterTypeEntryExit(p_DELIVERY_STREAM_ID VARCHAR2,p_DELIVERY_POINT_ID VARCHAR2,p_PIPE_SEGMENT_ID VARCHAR2);
PROCEDURE validateMeterTypeFuel(p_DELIVERY_STREAM_ID VARCHAR2,p_DELIVERY_POINT_ID VARCHAR2,p_PIPE_SEGMENT_ID VARCHAR2);
PROCEDURE validateMeterTypeTransit(p_DELIVERY_STREAM_ID VARCHAR2,p_DELIVERY_POINT_ID VARCHAR2,p_PIPE_SEGMENT_ID VARCHAR2);

FUNCTION hasDeliveryStreamMeter(p_delivery_stream_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2;
FUNCTION hasPipelineSegmentMeter(p_pipeline_segment_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2;

FUNCTION getProductionDay(p_object_id  VARCHAR2, p_daytime  DATE, p_summertime_flag VARCHAR2 DEFAULT NULL)
RETURN DATE;

END EcDp_Meter;