
update calc_set
set calc_set_type = 'DB_OBJECT_TYPE', sort_order = 'ASC', sort_by_sql_syntax = 'Code'
where calc_set_name = 'ProfitCentre'
and calc_context_id = ec_calc_context.object_id_by_uk('EC_SALE_SA')
and calc_set_type = 'FILTERED_SET';
