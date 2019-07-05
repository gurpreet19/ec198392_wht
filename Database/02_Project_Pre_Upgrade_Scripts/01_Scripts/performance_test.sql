create table Schedule_t as select * from Schedule;
create table schedule_history_t as select * from schedule_history;
create table action_instance_t as select * from action_instance;
create table action_instance_value_t as select * from action_instance_value;
create table action_instance_history_t as select * from action_instance_history;

truncate table action_instance_history;
truncate table action_instance_value;
truncate table action_instance;
truncate table schedule_history;
truncate table schedule;
