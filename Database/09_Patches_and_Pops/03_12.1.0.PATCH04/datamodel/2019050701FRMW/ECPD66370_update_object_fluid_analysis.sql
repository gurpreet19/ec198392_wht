-- The issue was about check_unique column calculation in object_fluid_analysis.
-- The update statement below will automatically recalculate check_unique field.
UPDATE object_fluid_analysis SET valid_from_utc_date = Ecdp_Timestamp.local2utc(object_id, valid_from_date) WHERE valid_from_date IS NOT NULL AND valid_from_utc_date IS NULL;
