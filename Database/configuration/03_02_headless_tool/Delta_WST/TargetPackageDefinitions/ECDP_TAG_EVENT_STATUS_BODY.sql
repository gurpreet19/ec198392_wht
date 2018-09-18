CREATE OR REPLACE PACKAGE BODY ecdp_tag_event_status IS
/******************************************************************************
** Package        :  ecdp_tag_event_status, body part
**
** $Revision: 1.2.6.2 $
**
** Purpose        :  Main package of EC IS Staging Table extension
**
** Documentation  :  www.energy-components.com
**
** Created        :  03.01.2008	Harald Kaada
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- ------------------------------------------------------------------------------
** 26.04.07    HUS   Removed t_temptext debug
********************************************************************/

CURSOR temp_records IS
       SELECT *
         FROM tag_event_status
        WHERE in_sync = 'N'
        ORDER BY staging_type, daytime
       FOR UPDATE;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : transfer
-- Description    : Transfer data from staging tables to final tables
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

PROCEDURE transfer
IS

  lv2_status varchar2(1);
BEGIN

	FOR r_record IN temp_records LOOP

      lv2_status := ue_tag_event_status.transfer (r_record);

      UPDATE tag_event_status tes SET tes.in_sync = lv2_status
       WHERE tes.object_id = r_record.object_id
         AND tes.daytime = r_record.daytime
         AND tes.staging_type = r_record.staging_type;

  END LOOP;

END transfer;

END ecdp_tag_event_status;