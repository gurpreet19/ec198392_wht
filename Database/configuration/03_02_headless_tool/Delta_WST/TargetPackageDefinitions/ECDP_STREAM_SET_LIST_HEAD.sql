CREATE OR REPLACE PACKAGE EcDp_Stream_Set_List IS
/****************************************************************
** Package        :  EcDp_Stream_Set_List; head part
**
** $Revision: 1.3.12.2 $
**
** Purpose        :  Stream set list handler
**
** Documentation  :  www.energy-components.com
**
** Created        :  09/11/2009,  Wan Shara
**
** Modification history:
**
** Date        Whom      Change description:
** ----------  -------   -------------------------------------------
** 09.11.2009  sharawan     Initial Version
** 15.04.2014  kumarsur     ECPD-27329 : Added getStreamSet.
**************************************************************************************************/

PROCEDURE validateOverlappingPeriod(p_object_id strm_set_list.object_id%TYPE,
									p_strm_set VARCHAR,
									p_start_date DATE
									);
PROCEDURE validateOverlappingPeriod (
   p_object_id  strm_set_list.object_id%TYPE,
   p_rec_id     strm_set_list.rec_id%TYPE,
   p_strm_set   VARCHAR,
   p_start_date	DATE,
   p_end_date   DATE);

FUNCTION getSortOrder(p_object_id IN VARCHAR2, p_stream_set  IN VARCHAR2, p_daytime IN DATE DEFAULT NULL) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getSortOrder, WNDS, WNPS, RNPS);

FUNCTION getStreamSet(p_object_id VARCHAR2, p_daytime DATE DEFAULT NULL) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (getStreamSet, WNDS, WNPS, RNPS);

END EcDp_Stream_Set_List;