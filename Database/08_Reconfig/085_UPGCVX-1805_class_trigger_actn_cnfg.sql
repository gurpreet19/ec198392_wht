-- Class trigger action for update statement
insert into class_trigger_actn_cnfg (class_name, triggering_event, trigger_type, sort_order, db_sql_syntax)
values ('CT_TRNP_DAY_AVAIL_ALLOC','UPDATING','AFTER',200,'-- Remove the CLASS_NAME from the update statement in the section -- End Update relation block
      UPDATE NOMPNT_DAY_AVAILABILITY 
      SET OBJECT_ID = n_OBJECT_ID, DAYTIME = n_DAYTIME, 
          VALUE_1 = n_AVAIL_CAP_QTY, VALUE_5 = n_AVAIL_CAP_QTY_OLD, VALUE_2 = n_ADJ_AVAIL_CAP_QTY, 
          VALUE_3 = n_FORECAST_FLOW_QTY, VALUE_6 = n_PROD_ACTUAL, TEXT_2 = n_SCENARIO_ID_0321, 
          CREATED_BY = n_CREATED_BY, CREATED_DATE = n_CREATED_DATE , LAST_UPDATED_BY = n_LAST_UPDATED_BY,
          LAST_UPDATED_DATE = n_LAST_UPDATED_DATE ,REV_NO = n_rev_no, REV_TEXT = n_REV_TEXT, 
          RECORD_STATUS = n_RECORD_STATUS, REC_ID = n_rec_id
      WHERE OBJECT_ID= o_OBJECT_ID AND DAYTIME= o_DAYTIME;');
-- Class trigger action for delete statement
insert into class_trigger_actn_cnfg (class_name, triggering_event, trigger_type, sort_order, db_sql_syntax)
values ('CT_TRNP_DAY_AVAIL_ALLOC','DELETING','AFTER',300,'-- Remove the CLASS_NAME from the DELETE statement in the section -- End Update relation block
      DELETE FROM NOMPNT_DAY_AVAILABILITY
      WHERE OBJECT_ID= o_OBJECT_ID AND DAYTIME= o_DAYTIME;');

--update viewlayer_dirty_log set dirty_ind='Y' where object_name like 'CT_TRNP_DAY_AVAIL_ALLOC' ;
--commit;
--execute ecdp_viewlayer.BuildViewLayer('CT_TRNP_DAY_AVAIL_ALLOC');
