CREATE OR REPLACE PACKAGE BODY EcDp_Stream_Set_List IS
/****************************************************************
** Package        :  EcDp_Stream_Set_List; body part
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

 --<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validateOverlappingPeriod
-- Description    : Validate that the new entry should not overlap with existing period
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : STRM_SET_LIST
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

PROCEDURE validateOverlappingPeriod (
   p_object_id  strm_set_list.object_id%TYPE,
   p_strm_set   VARCHAR,
   p_start_date	DATE)

--</EC-DOC>
IS

  CURSOR c_overlap_period (cp_object_id strm_set_list.object_id%TYPE,
						   cp_strm_set strm_set_list.stream_set%TYPE,
						   cp_start_date strm_set_list.from_date%TYPE) IS

    SELECT 'x' FROM strm_set_list t
	 WHERE t.object_id = cp_object_id
	   AND t.stream_set = cp_strm_set
	   AND t.from_date <= cp_start_date
	   AND cp_start_date < t.end_date;

BEGIN

  FOR curStreamSet IN c_overlap_period(p_object_id, p_strm_set, p_start_date)
   LOOP
    RAISE_APPLICATION_ERROR(-20606, 'A record is overlapping with an existing record.');
   END LOOP;

END validateOverlappingPeriod;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validateOverlappingPeriod
-- Description    : Validate that the new entry should not overlap with existing period
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : STRM_SET_LIST
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

PROCEDURE validateOverlappingPeriod (
   p_object_id  strm_set_list.object_id%TYPE,
   p_rec_id     strm_set_list.rec_id%TYPE,
   p_strm_set   VARCHAR,
   p_start_date	DATE,
   p_end_date   DATE)

--</EC-DOC>
IS

  CURSOR c_overlap_period (cp_object_id strm_set_list.object_id%TYPE,
               cp_rec_id strm_set_list.rec_id%TYPE,
						   cp_strm_set strm_set_list.stream_set%TYPE,
						   cp_start_date strm_set_list.from_date%TYPE,
               cp_end_date strm_set_list.end_date%TYPE) IS

    SELECT 'x' FROM strm_set_list t
	 WHERE t.object_id = cp_object_id
	   AND t.stream_set = cp_strm_set
	   AND t.from_date <= cp_end_date
	   AND (t.end_date >= cp_start_date or t.end_date is null)
     AND t.rec_id != cp_rec_id;

BEGIN

  FOR curStreamSet IN c_overlap_period(p_object_id, p_rec_id, p_strm_set, p_start_date, p_end_date)
   LOOP
    RAISE_APPLICATION_ERROR(-20606, 'A record is overlapping with an existing record.');
   END LOOP;

END validateOverlappingPeriod;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSortOrder
-- Description    : Returns the sort_order for strm_set_list
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : STRM_SET_LIST
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getSortOrder(p_object_id IN VARCHAR2,
						          p_stream_set  IN VARCHAR2,
                      p_daytime IN DATE DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
   ld_date       	DATE;
   ln_sort_order 	NUMBER;

    CURSOR c_strm_set_list (cp_date date) is
  	SELECT sort_order
   	  FROM STRM_SET_LIST t
     WHERE t.object_id = p_object_id
       AND t.stream_set = p_stream_set
       AND t.from_date <= cp_date
       and nvl(t.end_date, cp_date+1) > cp_date;

BEGIN

  	ld_date := Nvl(p_daytime, EcDp_Date_Time.getCurrentSysdate);

  	for one in c_strm_set_list (ld_date) loop
      ln_sort_order := one.sort_order;
    end loop;

  	RETURN ln_sort_order;

END getSortOrder;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getStreamSet
-- Description    : Returns strm_set_list
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : STRM_SET_LIST
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getStreamSet(p_object_id VARCHAR2,
                      p_daytime DATE DEFAULT NULL)
RETURN VARCHAR2
--</EC-DOC>
IS
   ld_date       	DATE;
   lv_stream_set	VARCHAR2(100);

    CURSOR c_strm_set_list (cp_date date) is
  	SELECT stream_set
   	  FROM STRM_SET_LIST t
     WHERE t.object_id = p_object_id
       AND t.stream_set in ('PO.0086_VF_NR','PO.0086_VF_R')
       AND t.from_date <= cp_date
       and nvl(t.end_date, cp_date+1) > cp_date;

BEGIN

  	ld_date := Nvl(p_daytime, EcDp_Date_Time.getCurrentSysdate);

  	for one in c_strm_set_list (ld_date) loop
      lv_stream_set := one.stream_set;
    end loop;

  	RETURN lv_stream_set;

END getStreamSet;

END EcDp_Stream_Set_List;