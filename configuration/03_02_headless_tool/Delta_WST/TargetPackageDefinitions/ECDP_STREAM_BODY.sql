CREATE OR REPLACE PACKAGE BODY Ecdp_Stream IS
/****************************************************************
** Package        :  EcDp_Stream, body part
**
** $Revision: 1.25 $
**
** Purpose        :  This package is responsible for stream data access
**
** Documentation  :  www.energy-components.com
**
** Created  : 05.12.1999  Carl-Fredrik Sørensen
**
** Modification history:
**
** Date        Whom      Change description:
** ----------  --------  --------------------------------------
** 05.12.1999  CFS       First version
** 03.04.2001  KEJ       Documented functions and procedures.
** 03.07.2001  FAS       Added validStreamInSet for checking
**                       daytime of stream against valid
**                       period of stream and strm_set_list
** 25.09.2001  FBa       Added function findEquipmentForStream
** 04.03.2002  DN        Added procedures createMeteredStream and setEquipmentStreamConnection.
** 01.06.2004  AV        Added function getStreamFacility
** 01.06.2004  DN        Corrected some documentation.
** 10.06.2004  HNE       Added getStreamCodeByObjectId
** 04.08.2004            removed sysnam and stream_code and update as necessary
** 20.08.2004  Toha      Removed function getStreamCodeByObjectId. Stream Code is removed from column.
**                       Altered createMeteredStream - stream_code is unnecessary.
** 23.11.2004  DN        Removed commented code.
** 25.02.2005	kaurrnar  Removed deadcodes. Changed tank_attribute to tank_version. Other performance task.
** 28.02.2005  Darren    Change from_date in validStreamInSet to start_date
**	                      createMeteredStream :- Name in production_facility moved to fcty_version
** 03.03.2005	kaurrnar  Removed createMeteredStream procedure
**		                   Changed nnumber of argument passed for ecdp_groups package
** 27.05.2005  DN        Function getStreamFacility: Replaced EcDp_Groups.findParentObjectID with direct ec-package call.
** 28.06.2005  SHN       Tracker 2385. Updated getStreamPhase because stream_category is moved from table STREAM to STRM_VERSION.
** 18.08.2005  Toha      TI 2282: Added getAnalysisStream,validateAnalysisReference
** 02.11.2005  DN        Replaced objects with specific object table.
** 13.07.2006  Khew      Tracker 3849. Updated validStreamInSet by setting virtual future date in NVL() against ld_strm_set_from.
** 20.09.2007 idrussab 	 ECPD-6591: Remove function getwelldatarowfromstream, getStreamWell
** 28.09.2007 amirrasn   ECPD-12097: Changed function validStreamInSet since from_date being a part of the key on strm_set_list
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getStreamPhase
-- Description  : Returns the stream phase of the given input stream
--                If the stream phase is not set explicitly, the stream phase may be
--                determined implicitly by the stream category. This should however
--                not be kept whenever all streams have been given an explicit stream
--                phase.
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables:
--
-- Using functions:
--                 EC_STREAM.STREAM_PHASE
--                 EC_STREAM.STREAM_CATEGORY
--
-- Configuration
-- required:
--
-- Behaviour
--
---------------------------------------------------------------------------------------------------
FUNCTION getStreamPhase(p_object_id stream.object_id%TYPE)

RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR c_max_daytime IS
SELECT MAX(daytime) daytime
FROM strm_version
WHERE object_id = p_object_id;

lv2_return_val VARCHAR2(20);
lv2_stream_cat VARCHAR2(20);
ld_daytime     DATE;

BEGIN

   FOR curMaxDaytime IN c_max_daytime LOOP
      ld_daytime := curMaxDaytime.daytime;
   END LOOP;

   lv2_return_val := Ec_Strm_Version.stream_phase(p_object_id,ld_daytime);

   IF (lv2_return_val IS NULL) THEN

      lv2_stream_cat := Ec_Strm_Version.stream_category(p_object_id,ld_daytime);

      IF (lv2_stream_cat IS NOT NULL) THEN

         lv2_return_val := SUBSTR(lv2_stream_cat ,1,3);

      END IF;

   END IF;

   RETURN lv2_return_val;

END getStreamPhase;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : validStreamInSet                                                               --
-- Description  : Returns TRUE for streams that are valid in the period of from date to          --
--                end date in STREAM and STRM_SET_LIST.                                          --
--                                                                                               --
-- Preconditions:                                                                                --
-- Postcondition:                                                                                --
--                                                                                               --
-- Using Tables:                                                                                 --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required:                                                                                     --
--                                                                                               --
-- Behaviour                                                                                     --
--                                                                                               --
---------------------------------------------------------------------------------------------------

FUNCTION validStreamInSet(p_object_id stream.object_id%TYPE,
                          p_stream_set   VARCHAR2,
                          p_daytime      DATE)

RETURN VARCHAR2
--</EC-DOC>
IS

lv2_return_val    VARCHAR2(5) := 'FALSE';

CURSOR c_val_date IS
SELECT *
FROM STRM_SET_LIST
WHERE object_id = p_object_id
AND stream_set = p_stream_set
AND from_date <= p_daytime
AND NVL(end_date,to_date('2100-01-01T00:00:00','''YYYY-MM-DD"T"HH24:MI:SS')) > p_daytime;

BEGIN

   FOR cur_row IN c_val_date LOOP

		IF c_val_date%ROWCOUNT <> 0 THEN
		  lv2_return_val := 'TRUE';
		END IF;

	END LOOP;

   RETURN lv2_return_val;

END validStreamInSet;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : findEquipmentForStream                                                         --
-- Description  : Returns the equipment_code the given stream is connected to                    --
--                                                                                               --
-- Preconditions:                                                                                --
-- Postcondition:                                                                                --
--                                                                                               --
-- Using Tables:                                                                                 --
--                 EQUIPMENT_STRM_CONN                                                           --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required:                                                                                     --
--                                                                                               --
-- Behaviour                                                                                     --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION findEquipmentForStream(p_object_id   stream.object_id%TYPE,
                                p_daytime     IN DATE,
                                p_class_name  IN VARCHAR2)

RETURN EQUIPMENT.object_id%TYPE
--</EC-DOC>
IS

CURSOR c_eqpm_strm_conn IS
SELECT con.object_id
  FROM EQUIPMENT_STRM_CONN con,
       equipment eq
 WHERE stream_id      =  p_object_id
   AND eq.object_id   =  con.object_id
   AND eq.class_name  =  p_class_name
   AND con.daytime    <= p_daytime
   AND (con.end_date  >= p_daytime OR con.end_date IS NULL);

lv2_equipment_id EQUIPMENT.Object_Id%TYPE;

BEGIN

   OPEN c_eqpm_strm_conn;

   FETCH c_eqpm_strm_conn INTO lv2_equipment_id;

   CLOSE c_eqpm_strm_conn;

   RETURN lv2_equipment_id;

END findEquipmentForStream;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : setEquipmentStreamConnection                                                 --
-- Description    : Establishes a new connection between a stream and an equipment.              --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions : Uncommited changes                                                           --
--                                                                                               --
-- Using tables   : EQUIPMENT_STRM_CONN                                                          --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       : WELL_VERSION.... (STD_DENSITY_METHOD)                                    		 --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
PROCEDURE setEquipmentStreamConnection(p_object_id stream.object_id%TYPE,
                                       p_equipment_id equipment.object_id%TYPE,
                                       p_start_date VARCHAR2
)
--</EC-DOC>
IS
BEGIN

   --- Close old connections for this equipment (can only be connected to one place)
   UPDATE equipment_strm_conn
   SET END_DATE = p_start_date
   WHERE OBJECT_ID=p_equipment_id
     AND STREAM_ID=p_object_id;

   -- And create the new connection
   INSERT INTO equipment_strm_conn(DAYTIME,OBJECT_ID,STREAM_ID)
   VALUES (p_start_date,p_equipment_id,p_object_id);

END setEquipmentStreamConnection;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getStreamFacility
-- Description    : Find the facilty for a stream
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
FUNCTION  getStreamFacility(
   p_stream_object_id  IN VARCHAR2,
   p_daytime           IN DATE)

RETURN VARCHAR2
--</EC-DOC>
IS

BEGIN

   RETURN ec_strm_version.op_fcty_class_1_id(p_stream_object_id, p_daytime, '<=');

END getStreamFacility;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getStreamTank
-- Description    : Find the tank for a stream from stream relation on Tank
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
FUNCTION  getStreamTank(
   p_stream_object_id  IN VARCHAR2,
   p_daytime           IN DATE)

RETURN VARCHAR2
--</EC-DOC>
IS

  lv2_tank_object_id  tank.object_id%TYPE;

  CURSOR c_tank_attribute IS
  SELECT object_id
  FROM  tank_version
  WHERE export_stream_id = p_stream_object_id
  AND   daytime <= p_daytime
  ORDER BY daytime DESC;  -- In case there are more than 1, always pick the newest


BEGIN


   FOR curTank IN  c_tank_attribute LOOP

     lv2_tank_object_id := curTank.object_id;
     EXIT;   -- should we have raised exception if stream is linked to more than 1 tank

   END LOOP;



   RETURN  lv2_tank_object_id;

END getStreamTank;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getAnalysisStream
-- Description    : Find the analysis object_id for this stream, based on REF_ANALYSIS_STREAM
--                  attribute. If the attribute is null, return this object_id
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
FUNCTION getAnalysisStream (
   p_object_id    IN stream.object_id%TYPE,
   p_daytime IN DATE
)

RETURN VARCHAR2
--</EC-DOC>
IS

BEGIN
  -- should work even if a well is passed
  RETURN NVL(ec_strm_version.ref_analysis_stream_id(p_object_id, p_daytime, '<='), p_object_id);

END getAnalysisStream;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validateAnalysisReference
-- Description    : Verify that this stream can make reference to that stream
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
-- Behaviour      : validation: This stream must not have reference from other stream
--                              Referenced stream must not make reference to other stream
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateAnalysisReference (
   p_object_id    IN stream.object_id%TYPE,
   p_reference_id IN stream.object_id%TYPE,
   p_daytime      IN DATE)

--</EC-DOC>
IS
  lv2_ref_ref_id stream.object_id%TYPE;

  CURSOR c_strm (cp_object_id stream.object_id%TYPE, cp_daytime DATE) IS
  SELECT 1 FROM stream
  WHERE ec_strm_version.ref_analysis_stream_id(object_id, cp_daytime, '<=') = cp_object_id;

BEGIN

  -- shortcut: always okay to reset
  IF p_reference_id IS NULL THEN
    RETURN;
  END IF;

  FOR curStream IN c_strm(p_object_id, p_daytime) LOOP
    RAISE_APPLICATION_ERROR(-20100, 'This stream is referenced by another stream');
  END LOOP;

  lv2_ref_ref_id := ec_strm_version.ref_analysis_stream_id(p_reference_id, p_daytime, '<=');

  IF lv2_ref_ref_id IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20100, 'Stream ' || ecdp_objects.getobjname(p_reference_id, p_daytime)
                                    || ' has analysis reference to ' ||
                                    ecdp_objects.getobjname(lv2_ref_ref_id, p_daytime));
  END IF;

END validateAnalysisReference;

END;