CREATE OR REPLACE PACKAGE EcDp_Stream_Set_List IS
/****************************************************************
** Package        :  EcDp_Stream_Set_List; head part
**
** $Revision: 1.5 $
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
** 15.04.2014  kumarsur     ECPD-27001 : Added getStreamSet.
** 15.02.2016  choooshu     ECPD-30030 : Added validateBalancingFlag to allow only one balancing flag per stream.
** 27.09.2017  mishrdha     ECPD-48000 : Edit validateBalancingFlag to updateBalancingFlag.
** 13.11.2017  choooshu     ECPD-37955 : Removed updateBalancingFlag as this is no longer used.
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

FUNCTION getStreamSet(p_object_id VARCHAR2, p_daytime DATE DEFAULT NULL) RETURN VARCHAR2;

END EcDp_Stream_Set_List;