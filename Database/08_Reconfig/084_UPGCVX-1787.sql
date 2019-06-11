--UPGCVX-1787

Insert into CLASS_TRIGGER_ACTN_CNFG(CLASS_NAME, TRIGGERING_EVENT, TRIGGER_TYPE, SORT_ORDER, APP_SPACE_CNTX, DB_SQL_SYNTAX)
Values('STRM_LNG_ANALYSIS', 'UPDATING', 'AFTER', 6000, 'WST', 'IF UPDATING(''LAST_UPDATED_BY'') THEN NULL; ELSE IF NVL(:OLD.ANALYSIS_STATUS, ''N'') <> ''N'' AND NVL(:OLD.ANALYSIS_STATUS, ''N'') <> NVL(:NEW.ANALYSIS_STATUS, ''N'') AND NVL(:NEW.ANALYSIS_STATUS, ''N'') IN (''NEW'', ''REJECTED'', ''INFO'') AND ec_object_fluid_analysis.sampling_method(n_analysis_no) = ''SPOT'' THEN ue_ct_trigger_action.HandleSpotSampleDelete(n_valid_from, n_Object_id, n_analysis_no); END IF;END IF;');

Insert into CLASS_TRA_PROPERTY_CNFG(CLASS_NAME, TRIGGERING_EVENT, TRIGGER_TYPE, SORT_ORDER, PROPERTY_CODE,OWNER_CNTX, PROPERTY_TYPE, PROPERTY_VALUE)
Values ('STRM_LNG_ANALYSIS', 'UPDATING', 'AFTER', 6000, 'DESCRIPTION', 2500, 'APPLICATION', 'C5+ Split out to C9+ Component Analysis After UpdateTrigger ');
                                            
Insert into CLASS_TRA_PROPERTY_CNFG (CLASS_NAME, TRIGGERING_EVENT, TRIGGER_TYPE, SORT_ORDER, PROPERTY_CODE, OWNER_CNTX, PROPERTY_TYPE, PROPERTY_VALUE)
Values('STRM_LNG_ANALYSIS', 'UPDATING', 'AFTER', 6000, 'DISABLED_IND', 2500, 'VIEWLAYER', 'N');
                                                 
Insert into CLASS_TRA_PROPERTY_CNFG (CLASS_NAME, TRIGGERING_EVENT, TRIGGER_TYPE, SORT_ORDER, PROPERTY_CODE, OWNER_CNTX, PROPERTY_TYPE, PROPERTY_VALUE)
Values('STRM_LNG_ANALYSIS', 'UPDATING', 'AFTER', 1000, 'DISABLED_IND', 2500, 'VIEWLAYER', 'Y');

Insert into CLASS_TRIGGER_ACTN_CNFG(CLASS_NAME, TRIGGERING_EVENT, TRIGGER_TYPE, SORT_ORDER, APP_SPACE_CNTX, DB_SQL_SYNTAX)
Values('STRM_LNG_ANALYSIS', 'DELETING', 'AFTER', 7000, 'WST', 'IF DELETING THEN NULL; ELSE IF n_sampling_method = ''SPOT'' THEN ue_ct_trigger_action.HandleSpotSampleDelete(n_valid_from, n_Object_id, n_analysis_no); ELSIF n_sampling_method IN (''GC'') THEN ue_ct_trigger_action.HandleGCSampleDelete(n_analysis_no); END IF;END IF;');

Insert into CLASS_TRA_PROPERTY_CNFG(CLASS_NAME, TRIGGERING_EVENT, TRIGGER_TYPE, SORT_ORDER, PROPERTY_CODE,OWNER_CNTX, PROPERTY_TYPE, PROPERTY_VALUE)
Values ('STRM_LNG_ANALYSIS', 'DELETING', 'AFTER', 7000, 'DESCRIPTION', 2500, 'APPLICATION', 'C5+ Split out to C9+ Component Analysis on Delete Trigger');
                                            
Insert into CLASS_TRA_PROPERTY_CNFG (CLASS_NAME, TRIGGERING_EVENT, TRIGGER_TYPE, SORT_ORDER, PROPERTY_CODE, OWNER_CNTX, PROPERTY_TYPE, PROPERTY_VALUE)
Values('STRM_LNG_ANALYSIS', 'DELETING', 'AFTER', 7000, 'DISABLED_IND', 2500, 'VIEWLAYER', 'N');
                                                 
Insert into CLASS_TRA_PROPERTY_CNFG (CLASS_NAME, TRIGGERING_EVENT, TRIGGER_TYPE, SORT_ORDER, PROPERTY_CODE, OWNER_CNTX, PROPERTY_TYPE, PROPERTY_VALUE)
Values('STRM_LNG_ANALYSIS', 'DELETING', 'AFTER', 5000, 'DISABLED_IND', 2500, 'VIEWLAYER', 'Y');

commit;