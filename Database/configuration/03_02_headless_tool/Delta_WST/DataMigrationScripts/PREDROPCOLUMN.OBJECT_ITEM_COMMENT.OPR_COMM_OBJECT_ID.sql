BEGIN
UPDATE object_item_comment
   SET object_id         = opr_comm_object_id
      ,last_updated_by   = last_updated_by
      ,last_updated_date = last_updated_date
 WHERE opr_comm_object_id IS NOT NULL;
 
END;
 