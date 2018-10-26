CREATE OR REPLACE PACKAGE EcBp_Stream IS

/****************************************************************
** Package        :  EcBp_Stream, header part
**
** $Revision: 1.11 $
**
** Purpose        :  This package is responsible for finding specific
**                   stream properties that is not achievable directly
**                   in the stream objects.
**
** Documentation  :  www.energy-components.com
**
** Created  : 22.11.1999  Carl-Fredrik S�sen
**
** Modification history:
**
** Date     Whom  Change description:
** ------   ----- --------------------------------------
** 22.11.1999  CFS    First version
** 02.04.2001  JEH    Added aggStrmFromPeriodToDay and aggStrmFromDayToMonth
** 12.06.2001  AIE    Added aggAllStrmPeriodToDay and aggAllStrmDayToMonth
** 10.08.2004  Toha   Replaced sysnam and stream_code to stream.object_id in signature as updated as necessary.
** 28.01.2005  Ron    Added getResvBlockFormationValue to get the value for the Resvoir Block Formation field in the Maintain Stream Screen.
** 28.02.2005 kaurrnar	Removed deadcode
** 07.03.2005  Toha   TI 1965: Removed function aggAllStrmPeriodToDay, aggAllStrmDayToMonth
** 27.04.2005  DN        Removed function getRefValue.
** 20.09.2007  idrussab   ECPD-6591: removed function getRefQualityStream
** 27.01.2012  kumarsur   ECPD-19809: added getRateUom.
*****************************************************************/

FUNCTION findRefAnalysisStream (
   p_object_id   stream.object_id%TYPE,
   p_daytime     DATE)
RETURN VARCHAR2;

--

FUNCTION getResvBlockFormationValue(
         p_block_id VARCHAR2,
         p_formation_id VARCHAR2)
RETURN VARCHAR2;

--
PROCEDURE aggStrmFromPeriodToDay(
   p_object_id   stream.object_id%TYPE,
   p_day         DATE,
   p_time_span   VARCHAR2
);

--

PROCEDURE aggStrmFromDayToMonth(
   p_object_id   stream.object_id%TYPE,
   p_day         DATE
);

--

PROCEDURE setDefaultTicketVol(
   p_strm_object_id STREAM.OBJECT_ID%TYPE,
   p_daytime DATE,
   p_ticket_net_vol STRM_EVENT.NET_VOL%TYPE);

--

FUNCTION getRateUom(p_object_id VARCHAR2,
                          p_daytime  DATE,
                          p_rate_type VARCHAR2)
RETURN VARCHAR2;

--

END;