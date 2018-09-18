CREATE OR REPLACE package UE_RR_REVN_MAPPING_INTERFACE IS

-- Enabling User Exits for ECDP_RR_REVN_MAPPING_INTERFACE.ValidateNewIfacUpd_P
isValidateNewIfacUpdUEE     VARCHAR2(32)    := 'FALSE'; -- Instead of
isValidateNewIfacUpdPreUEE  VARCHAR2(32)    := 'FALSE'; -- Pre
isValidateNewIfacUpdPostUEE VARCHAR2(32)    := 'FALSE'; -- Post

-- User Exit Set for ECDP_RR_REVN_MAPPING_INTERFACE.ValidateNewIfacUpd_P

PROCEDURE ValidateNewIfacUpd_P(p_new_journal_entry_record      IN OUT NOCOPY IFAC_JOURNAL_ENTRY%ROWTYPE);
PROCEDURE ValidateNewIfacUpd_Post(p_new_journal_entry_record   IN OUT NOCOPY IFAC_JOURNAL_ENTRY%ROWTYPE);
PROCEDURE ValidateNewIfacUpd_Pre(p_new_journal_entry_record    IN OUT NOCOPY IFAC_JOURNAL_ENTRY%ROWTYPE);

END UE_RR_REVN_MAPPING_INTERFACE;