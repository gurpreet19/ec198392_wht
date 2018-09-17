CREATE OR REPLACE PACKAGE BODY UE_RR_REVN_MAPPING_INTERFACE IS

-------------------------------------------------------------------------------------------------
-- Function       : ValidateNewIfacUpd_P
-- Description    : This is an INSTEAD OF user-exit addon to the standard ECDP_RR_REVN_MAPPING_INTERFACE.ValidateNewIfacUpd_P.
-- Preconditions  : Must be enabled using global variable isValidateNewIfacUpdUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
PROCEDURE ValidateNewIfacUpd_P(p_new_journal_entry_record   IN OUT NOCOPY IFAC_JOURNAL_ENTRY%ROWTYPE)
IS
BEGIN

  NULL;

END ValidateNewIfacUpd_P;


-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-- Function       : ValidateNewIfacUpd_P
-- Description    : This is an PRE user-exit addon to the standard ECDP_RR_REVN_MAPPING_INTERFACE.ValidateNewIfacUpd_P.
-- Preconditions  : Must be enabled using global variable isValidateNewIfacUpdPreUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
PROCEDURE ValidateNewIfacUpd_Pre(p_new_journal_entry_record   IN OUT NOCOPY IFAC_JOURNAL_ENTRY%ROWTYPE)
IS
BEGIN

   NULL;

END ValidateNewIfacUpd_Pre;


-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-- Function       : ValidateNewIfacUpd_P
-- Description    : This is an POST user-exit addon to the standard ECDP_RR_REVN_MAPPING_INTERFACE.ValidateNewIfacUpd_P.
-- Preconditions  : Must be enabled using global variable isValidateNewIfacUpdPostUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
PROCEDURE ValidateNewIfacUpd_Post(p_new_journal_entry_record   IN OUT NOCOPY IFAC_JOURNAL_ENTRY%ROWTYPE)
IS
BEGIN

   NULL;

END ValidateNewIfacUpd_Post;

--<EC-DOC>
-------------------------------------------------------------------------------------------------

END UE_RR_REVN_MAPPING_INTERFACE;