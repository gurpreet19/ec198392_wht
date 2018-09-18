CREATE OR REPLACE PACKAGE BODY ue_RR_Revn_Mapping IS
/****************************************************************
** Package        :  ue_RR_Revn_Mapping, body part
*****************************************************************/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : LoadPriceIndexData
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE LoadPriceIndexData(p_contract VARCHAR2,
                           p_daytime  DATE,
                           p_user_id  VARCHAR2)
--</EC-DOC>
IS
BEGIN
    NULL;
END LoadPriceIndexData;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : LoadPNCBPriceIndexData
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE LoadPNCBPriceIndexData(p_contract VARCHAR2,
                               p_daytime  DATE,
                               p_user_id  VARCHAR2)
--</EC-DOC>
IS
BEGIN
    NULL;
END LoadPNCBPriceIndexData;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : LoadAllocatedVolumes
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE LoadAllocatedVolumes(p_contract VARCHAR2,
                             p_daytime  DATE,
                             p_user_id  VARCHAR2)
--</EC-DOC>
IS
BEGIN
    NULL;
END LoadAllocatedVolumes;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : DsSourceSetup
-- Description    : Runs configured user-exit routines to deploy data from different sources into the table cont_journal_entry
--                  for further mapping/processing
--
-- Preconditions  : Any user-exit routines must be enabled in the package in order to do anything.
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE DsSourceSetup(p_dataset VARCHAR2,
                      p_daytime DATE,
                      p_user_id VARCHAR2,
                      p_contract_group_id VARCHAR2)
--</EC-DOC>
IS
BEGIN
    NULL;
END DsSourceSetup;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
  -- Procedure      : DsPostSetup
-- Description    : Runs configured user-exit routines to deploy data from different sources into the table cont_journal_entry
--                  for further mapping/processing
--
-- Preconditions  : Any user-exit routines must be enabled in the package in order to do anything.
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE DsPostSetup(p_dataset VARCHAR2,
                    p_daytime DATE,
                    p_user_id VARCHAR2)
--</EC-DOC>
IS
BEGIN
    NULL;
END DsPostSetup;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : GetThroughput
-- Description    :
  --
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetThroughput(p_object_id VARCHAR2,
                     p_daytime   DATE,
                     p_period    VARCHAR2 DEFAULT NULL) RETURN NUMBER
--</EC-DOC>
IS
BEGIN
    RETURN NULL;
END;


END ue_RR_Revn_Mapping;