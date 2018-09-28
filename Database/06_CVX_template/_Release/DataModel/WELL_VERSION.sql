UPDATE WELL_VERSION SET BF_PROFILE = 'PROD', created_by = created_by, created_date = created_date, last_updated_by = last_updated_by, last_updated_date = last_updated_date, rev_no = rev_no WHERE well_class = 'P';
UPDATE WELL_VERSION SET BF_PROFILE = 'INJ', created_by = created_by, created_date = created_date, last_updated_by = last_updated_by, last_updated_date = last_updated_date, rev_no = rev_no WHERE well_class = 'I';
COMMIT;


