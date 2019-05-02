ALTER TABLE T_BASIS_ACCESS DISABLE ALL TRIGGERS;
ALTER TABLE T_BASIS_USERROLE DISABLE ALL TRIGGERS;
ALTER TABLE T_BASIS_ROLE DISABLE ALL TRIGGERS;

DELETE from T_BASIS_ACCESS where role_id in ('INST.MAN');
DELETE from T_BASIS_ACCESS where role_id in ('OP');
DELETE from T_BASIS_ACCESS where role_id in ('RES');
DELETE from T_BASIS_ACCESS where role_id in ('SUP');
DELETE from T_BASIS_ACCESS where role_id in ('DISP');
DELETE from T_BASIS_ACCESS where role_id in ('FORECAST');
DELETE from T_BASIS_ACCESS where role_id in ('GAS_ADM');
DELETE from T_BASIS_ACCESS where role_id in ('GAS_PLAN');
DELETE from T_BASIS_ACCESS where role_id in ('LEAD_DISP');
DELETE from T_BASIS_ACCESS where role_id in ('MARINE_SINT');
DELETE from T_BASIS_ACCESS where role_id in ('SCHEDULER');
DELETE from T_BASIS_ACCESS where role_id in ('TERMINAL_OP');

DELETE from T_BASIS_USERROLE where role_id in ('INST.MAN');
DELETE from T_BASIS_USERROLE where role_id in ('OP');
DELETE from T_BASIS_USERROLE where role_id in ('RES');
DELETE from T_BASIS_USERROLE where role_id in ('SUP');
DELETE from T_BASIS_USERROLE where role_id in ('DISP');
DELETE from T_BASIS_USERROLE where role_id in ('FORECAST');
DELETE from T_BASIS_USERROLE where role_id in ('GAS_ADM');
DELETE from T_BASIS_USERROLE where role_id in ('GAS_PLAN');
DELETE from T_BASIS_USERROLE where role_id in ('LEAD_DISP');
DELETE from T_BASIS_USERROLE where role_id in ('MARINE_SINT');
DELETE from T_BASIS_USERROLE where role_id in ('SCHEDULER');
DELETE from T_BASIS_USERROLE where role_id in ('TERMINAL_OP');

DELETE from T_BASIS_ROLE where role_id in ('INST.MAN');
DELETE from T_BASIS_ROLE where role_id in ('OP');
DELETE from T_BASIS_ROLE where role_id in ('RES');
DELETE from T_BASIS_ROLE where role_id in ('SUP');
DELETE from T_BASIS_ROLE where role_id in ('DISP');
DELETE from T_BASIS_ROLE where role_id in ('FORECAST');
DELETE from T_BASIS_ROLE where role_id in ('GAS_ADM');
DELETE from T_BASIS_ROLE where role_id in ('GAS_PLAN');
DELETE from T_BASIS_ROLE where role_id in ('LEAD_DISP');
DELETE from T_BASIS_ROLE where role_id in ('MARINE_SINT');
DELETE from T_BASIS_ROLE where role_id in ('SCHEDULER');
DELETE from T_BASIS_ROLE where role_id in ('TERMINAL_OP');

ALTER TABLE T_BASIS_ACCESS ENABLE ALL TRIGGERS;
ALTER TABLE T_BASIS_USERROLE ENABLE ALL TRIGGERS;
ALTER TABLE T_BASIS_ROLE ENABLE ALL TRIGGERS;