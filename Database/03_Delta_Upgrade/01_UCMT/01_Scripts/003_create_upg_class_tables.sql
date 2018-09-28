-- Copy of new class tables used for previous version of EC
prompt Creating U_CLASS_CNFG...
create table U_CLASS_CNFG
(
  class_name               VARCHAR2(24) not null,
  class_type               VARCHAR2(32) not null,
  app_space_cntx           VARCHAR2(32) not null,
  time_scope_code          VARCHAR2(32),
  owner_class_name         VARCHAR2(24),
  db_object_type           VARCHAR2(32),
  db_object_owner          VARCHAR2(32),
  db_object_name           VARCHAR2(32),
  db_object_attribute      VARCHAR2(32),
  db_where_condition       VARCHAR2(4000),
  record_status            VARCHAR2(1),
  created_by               VARCHAR2(30) not null,
  created_date             DATE not null,
  last_updated_by          VARCHAR2(30),
  last_updated_date        DATE,
  rev_no                   NUMBER,
  rev_text                 VARCHAR2(2000),
  approval_state           VARCHAR2(1),
  approval_by              VARCHAR2(30),
  approval_date            DATE,
  rec_id                   VARCHAR2(32)
)
 INITRANS 1
 MAXTRANS 255
 PCTUSED 40
 PCTFREE 40
 STORAGE
 (
   PCTINCREASE 10
   NEXT 1M
 )
 TABLESPACE &ts_data
 NOCACHE
/



prompt Creating U_CLASS_ATTRIBUTE_CNFG...
create table U_CLASS_ATTRIBUTE_CNFG(
  class_name           VARCHAR2(24) not null,
  attribute_name       VARCHAR2(24) not null,
  app_space_cntx       VARCHAR2(32) not null,
  is_key               varchar2(1),
  data_type            VARCHAR2(32),
  db_mapping_type      VARCHAR2(32),
  db_sql_syntax        VARCHAR2(4000),
  db_join_table        VARCHAR2(32),
  db_join_where        VARCHAR2(4000),
  reference_key        VARCHAR2(30),
  reference_type       VARCHAR2(24),
  reference_value      VARCHAR2(32),
  record_status        VARCHAR2(1),
  created_by           VARCHAR2(30) not null,
  created_date         DATE not null,
  last_updated_by      VARCHAR2(30),
  last_updated_date    DATE,
  rev_no               NUMBER,
  rev_text             VARCHAR2(2000),
  approval_state       VARCHAR2(1),
  approval_by          VARCHAR2(30),
  approval_date        DATE,
  rec_id               VARCHAR2(32)
)
 INITRANS 1
 MAXTRANS 255
 PCTUSED 40
 PCTFREE 40
 STORAGE
 (
   PCTINCREASE 10
   NEXT 1M
 )
 TABLESPACE &ts_data
 NOCACHE
/




prompt Creating U_CLASS_DEPENDENCY_CNFG...
create table U_CLASS_DEPENDENCY_CNFG
(
  parent_class      VARCHAR2(24) not null,
  child_class       VARCHAR2(24) not null,
  dependency_type   VARCHAR2(32) not null,
  app_space_cntx    VARCHAR2(32) not null,
  record_status     VARCHAR2(1),
  created_by        VARCHAR2(30) not null,
  created_date      DATE not null,
  last_updated_by   VARCHAR2(30),
  last_updated_date DATE,
  rev_no            NUMBER,
  rev_text          VARCHAR2(2000),
  approval_state    VARCHAR2(1),
  approval_by       VARCHAR2(30),
  approval_date     DATE,
  rec_id            VARCHAR2(32)
)
 INITRANS 1
 MAXTRANS 255
 PCTUSED 40
 PCTFREE 40
 STORAGE
 (
   PCTINCREASE 10
   NEXT 1M
 )
 TABLESPACE &ts_data
 NOCACHE
/



prompt Creating U_CLASS_RELATION_CNFG...
create table U_CLASS_RELATION_CNFG
(
  from_class_name       VARCHAR2(24) not null,
  to_class_name         VARCHAR2(24) not null,
  role_name             VARCHAR2(24) not null,
  app_space_cntx        VARCHAR2(32) not null,
  is_key                VARCHAR2(1),
  is_bidirectional      VARCHAR2(1),
  group_type            VARCHAR2(32),
  multiplicity          VARCHAR2(32),
  db_mapping_type       VARCHAR2(32),
  db_sql_syntax         VARCHAR2(4000),
  record_status         VARCHAR2(1),
  created_by            VARCHAR2(30) not null,
  created_date          DATE not null,
  last_updated_by       VARCHAR2(30),
  last_updated_date     DATE,
  rev_no                NUMBER,
  rev_text              VARCHAR2(2000),
  reverse_approval_ind  VARCHAR2(1),
  approval_ind          VARCHAR2(1),
  approval_state        VARCHAR2(1),
  approval_by           VARCHAR2(30),
  approval_date         DATE,
  rec_id                VARCHAR2(32)
)
 INITRANS 1
 MAXTRANS 255
 PCTUSED 40
 PCTFREE 40
 STORAGE
 (
   PCTINCREASE 10
   NEXT 1M
 )
 TABLESPACE &ts_data
 NOCACHE
/
  

prompt Creating U_CLASS_TRIGGER_ACTN_CNFG...
create table U_CLASS_TRIGGER_ACTN_CNFG
(
  class_name        VARCHAR2(24) not null,
  triggering_event  VARCHAR2(250) not null,
  trigger_type      VARCHAR2(30) not null,
  sort_order        NUMBER not null,
  app_space_cntx    VARCHAR2(32),
  db_sql_syntax     VARCHAR2(4000),
  record_status     VARCHAR2(1),
  created_by        VARCHAR2(30) not null,
  created_date      DATE not null,
  last_updated_by   VARCHAR2(30),
  last_updated_date DATE,
  rev_no            NUMBER,
  rev_text          VARCHAR2(2000),
  approval_by       VARCHAR2(30),
  approval_date     DATE,
  approval_state    VARCHAR2(1),
  rec_id            VARCHAR2(32)
)
 INITRANS 1
 MAXTRANS 255
 PCTUSED 40
 PCTFREE 40
 STORAGE
 (
   PCTINCREASE 10
   NEXT 1M
 )
 TABLESPACE &ts_data
 NOCACHE
/

