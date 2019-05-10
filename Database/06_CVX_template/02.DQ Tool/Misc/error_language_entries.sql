

insert into tv_language_source
(source_id, source)
values
((select max(source_id) + 1 from tv_language_source),'ORA-20910');

insert into tv_language_source
(source_id, source)
values
((select max(source_id) + 1 from tv_language_source),'ORA-20911');

insert into tv_language_source
(source_id, source)
values
((select max(source_id) + 1 from tv_language_source),'ORA-20912');

insert into tv_language_source
(source_id, source)
values
((select max(source_id) + 1 from tv_language_source),'ORA-20913');

insert into tv_language_source
(source_id, source)
values
((select max(source_id) + 1 from tv_language_source),'ORA-20914');

insert into tv_language_source
(source_id, source)
values
((select max(source_id) + 1 from tv_language_source),'ORA-20915');

insert into tv_language_source
(source_id, source)
values
((select max(source_id) + 1 from tv_language_source),'ORA-20916');

insert into tv_language_source
(source_id, source)
values
((select max(source_id) + 1 from tv_language_source),'ORA-20917');

insert into tv_language_source
(source_id, source)
values
((select max(source_id) + 1 from tv_language_source),'ORA-20918');

insert into tv_language_source
(source_id, source)
values
((select max(source_id) + 1 from tv_language_source),'ORA-20919');

insert into tv_language_source
(source_id, source)
values
((select max(source_id) + 1 from tv_language_source),'ORA-20920');

insert into tv_language_source
(source_id, source)
values
((select max(source_id) + 1 from tv_language_source),'ORA-20921');

insert into tv_language_source
(source_id, source)
values
((select max(source_id) + 1 from tv_language_source),'ORA-20922');


---

-- insert into tv_language_target
-- (language_id, source_id, target)
-- values
-- (1,(select source_id from tv_language_source where source = 'ORA-20910') ,'Start Date Source is Required');

-- insert into tv_language_target
-- (language_id, source_id, target)
-- values
-- (1,(select source_id from tv_language_source where source = 'ORA-20911'),'End Date Source is Required');

-- insert into tv_language_target
-- (language_id, source_id, target)
-- values
-- (1,(select source_id from tv_language_source where source = 'ORA-20912'),'Start Date Source is not allowed for Report Only Rule Groups');

-- insert into tv_language_target
-- (language_id, source_id, target)
-- values
-- (1,(select source_id from tv_language_source where source = 'ORA-20913'),'End Date Source is not allowed for Report Only Rule Groups');

-- insert into tv_language_target
-- (language_id, source_id, target)
-- values
-- (1,(select source_id from tv_language_source where source = 'ORA-20914'),'Invalid Date Source Function');

-- insert into tv_language_target
-- (language_id, source_id, target)
-- values
-- (1,(select source_id from tv_language_source where source = 'ORA-20915'),'Invalid Generated Dynamic SQL');

-- insert into tv_language_target
-- (language_id, source_id, target)
-- values
-- (1,(select source_id from tv_language_source where source = 'ORA-20916'),'Invalid Dynamic SQL: Invalid Column Name');

-- insert into tv_language_target
-- (language_id, source_id, target)
-- values
-- (1,(select source_id from tv_language_source where source = 'ORA-20917'),'Invalid Dynamic SQL: Column Ambiguously Defined');

-- insert into tv_language_target
-- (language_id, source_id, target)
-- values
-- (1,(select source_id from tv_language_source where source = 'ORA-20918'),'Invalid Dynamic SQL: FROM keyword not found where expected');

-- insert into tv_language_target
-- (language_id, source_id, target)
-- values
-- (1,(select source_id from tv_language_source where source = 'ORA-20919'),'Invalid Dynamic SQL: SQL not properly ended');

-- insert into tv_language_target
-- (language_id, source_id, target)
-- values
-- (1,(select source_id from tv_language_source where source = 'ORA-20920'),'Invalid Dynamic SQL: Invalid Table Name');

-- insert into tv_language_target
-- (language_id, source_id, target)
-- values
-- (1,(select source_id from tv_language_source where source = 'ORA-20921'),'Invalid Dynamic SQL: Not a Group By Expression');

-- insert into tv_language_target
-- (language_id, source_id, target)
-- values
-- (1,(select source_id from tv_language_source where source = 'ORA-20922'),'Invalid Dynamic SQL: Missing Right Parenthesis');

