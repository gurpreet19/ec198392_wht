CREATE OR REPLACE EDITIONABLE TRIGGER "IUD_V_CALC_OBJECT_FILTER" 
 instead of insert or update or delete on v_calc_object_filter
for each row
-- $revision: 1.1 $
-- $author: siah
declare

ln_cnt number;

begin

if inserting or updating then

  select count(*) into ln_cnt from calc_object_filter cof
  where cof.object_id = :new.object_id
  and cof.object_type_code = :new.object_type_code
  and cof.impl_class_name = :new.impl_class_name
  and cof.sql_syntax = :new.sql_syntax;

  --ecdp_dynsql.writetemptext('ln_cnt ',ln_cnt);

  if (ln_cnt = 0 and (:new.parameter_filter is not null  or :new.calc_obj_attr_filter is not null)) then

    insert into calc_object_filter (
    object_id,
    object_type_code,
    impl_class_name,
    sql_syntax,
    calc_obj_attr_filter,
    parameter_filter
    ) values (
    :new.object_id,
    :new.object_type_code,
    :new.impl_class_name,
    :new.sql_syntax,
    :new.calc_obj_attr_filter,
    :new.parameter_filter
    );

  elsif (ln_cnt > 0 and :new.parameter_filter is null  and :new.calc_obj_attr_filter is null) then
    delete from calc_object_filter
    where object_id = :old.object_id
    and  object_type_code = :old.object_type_code
    and impl_class_name = :old.impl_class_name
    and sql_syntax = :old.sql_syntax;

  else
    update calc_object_filter
    set
      calc_obj_attr_filter = :new.calc_obj_attr_filter,
      parameter_filter = :new.parameter_filter,
      rev_text = :new.rev_text,
      rev_no = :new.rev_no,
      record_status = :new.record_status
    where object_id = :old.object_id
    and  object_type_code = :old.object_type_code
    and impl_class_name = :old.impl_class_name
    and sql_syntax = :old.sql_syntax;
  end if;
end if;

end;
