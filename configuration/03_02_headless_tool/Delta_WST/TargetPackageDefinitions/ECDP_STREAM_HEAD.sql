CREATE OR REPLACE PACKAGE Ecdp_Stream IS

/****************************************************************
** Package        :  EcDp_Stream
**
** $Revision: 1.14 $
**
** Purpose        :  This package is responsible for stream data access
**
** Documentation  :  www.energy-components.com
**
** Created  : 22.11.1999  Carl-Fredrik Sørensen
**
** Modification history:
**
** Version  Date        Whom   Change description:
** -------  ----------  -----  --------------------------------------
** 1.0      22.11.1999  CFS    First version
**          03.07.2001  FAS    Added validStreamInSet for checking
**                             daytime of stream against valid
**                             period of stream and strm_set_list
** 3.3      25.09.2001  FBa    Added function findEquipmentForStream
** 3.3      04.03.2002  DN     Added procedures createMeteredStream and setEquipmentStreamConnection.
**          01.06.2004  AV     Added function getStreamFacility
** 1.3      07.06.2004  AV     Added function getStreamTank
** 1.4      10.06.2004  HNE    Added function getStreamCodeByObjectId
** 1.5      04.08.2004  kaurrnar     removed sysnam and stream_code and update as necessary
**          20.08.2004  Toha   Removed function getStreamCodeByObjectId. Stream Code is removed from column.
**                             Altered param signature for findEquipmentForStream
**          23.11.2004  DN     Added pragma on getStreamFacility.
**	    03.03.2005 kaurrnar	Removed createMeteredStream procedure
**          18.08.2005 Toha    TI 2282: Added getAnalysisStream, validateAnalysisReference
**          20.09.2007 idrussab ECPD-6591: Remove function getwelldatarowfromstream, getStreamWell
** 28.09.2007 amirrasn   ECPD-12097: Changed function validStreamInSet since from_date being a part of the key on strm_set_list
*****************************************************************/


FUNCTION getStreamPhase(
   p_object_id stream.object_id%TYPE)

RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (getStreamPhase, WNDS, WNPS, RNPS);

FUNCTION validStreamInSet(
   p_object_id stream.object_id%TYPE,
   p_stream_set   IN VARCHAR2,
   p_daytime      IN DATE)

RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (validStreamInSet, WNDS, WNPS, RNPS);

FUNCTION findEquipmentForStream(
   p_object_id stream.object_id%TYPE,
   p_daytime      IN DATE,
   p_class_name IN VARCHAR2)

RETURN EQUIPMENT.object_id%TYPE;

PRAGMA RESTRICT_REFERENCES (findEquipmentForStream, WNDS, WNPS, RNPS);

PROCEDURE setEquipmentStreamConnection
(
   p_object_id stream.object_id%TYPE,
   p_equipment_id equipment.object_id%TYPE,
   p_start_date VARCHAR2
);

FUNCTION  getStreamFacility(
   p_stream_object_id  IN VARCHAR2,
   p_daytime           IN DATE)

RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (getStreamFacility, WNDS, WNPS, RNPS);


FUNCTION  getStreamTank(
   p_stream_object_id  IN VARCHAR2,
   p_daytime           IN DATE)

RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (getStreamTank, WNDS, WNPS, RNPS);

FUNCTION getAnalysisStream (
   p_object_id    IN stream.object_id%TYPE,
   p_daytime IN DATE)

RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (getAnalysisStream, WNDS, WNPS, RNPS);

PROCEDURE validateAnalysisReference (
   p_object_id    IN stream.object_id%TYPE,
   p_reference_id IN stream.object_id%TYPE,
   p_daytime      IN DATE)
;

PRAGMA RESTRICT_REFERENCES (validateAnalysisReference, WNDS, WNPS, RNPS);

END;