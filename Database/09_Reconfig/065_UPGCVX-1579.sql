insert into cntr_group_job_conn (contract_group_id, job_id, daytime, end_date, sort_order)
select cg.object_id as contract_group_id, calc.object_id as job_id, greatest(cg.daytime, calc.daytime) as daytime, cg.end_date as end_date, 10 * (ROW_NUMBER() over (order by cg.name, calc.name)) as sort_order from ov_contract_group cg, ov_calculation calc
where cg.period = 'DAY' 
and calc.calc_scope = 'MAIN' and calc.calc_context_code = 'EC_SALE_SA' and calc.calc_period = 'DAY'
order by cg.name, calc.name;

insert into cntr_group_job_conn (contract_group_id, job_id, daytime, end_date, sort_order)
select cg.object_id as contract_group_id, calc.object_id as job_id, greatest(cg.daytime, calc.daytime) as daytime, cg.end_date as end_date, 10 * (ROW_NUMBER() over (order by cg.name, calc.name)) as sort_order from ov_contract_group cg, ov_calculation calc
where cg.period = 'MONTH' 
and calc.calc_scope = 'MAIN' and calc.calc_context_code = 'EC_SALE_SA' and calc.calc_period = 'MTH'
order by cg.name, calc.name;
