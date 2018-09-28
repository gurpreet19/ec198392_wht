-- Prevent this script form running if the Class_cnfg tables already exists 
WHENEVER OSERROR EXIT -1
WHENEVER SQLERROR EXIT SQL.SQLCODE

declare
  cursor c_class_tables is
  select table_name from user_tables 
  where table_name in ('CLASS_CNFG','CLASS_ATTRIBUTE_CNFG','CLASS_RELATION_CNFG','CLASS_TRIGGER_ACTN_CNFG','CLASS_DEPENDENCY_CNFG',
                       'CLASS_PROPERTY_CNFG','CLASS_ATTR_PROPERTY_CNFG','CLASS_REL_PROPERTY_CNFG','CLASS_PROPERTY_CNFG','CLASS_TRA_PROPERTY_CNFG','CLASS_PROPERTY_CODES');
                       

begin
  
  FOR curtab IN c_class_tables LOOP
  
      Raise_Application_Error(-20101,'Can not run this step when new class tables already exist!');
  
  END LOOP;

end;
/

prompt Creating CLASS_CNFG...
create table CLASS_CNFG
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


create table CLASS_CNFG_JN
 (JN_OPERATION CHAR(3) NOT NULL
 ,JN_ORACLE_USER VARCHAR2(30) NOT NULL
 ,JN_DATETIME DATE NOT NULL
 ,JN_NOTES VARCHAR2(240)
 ,JN_APPLN VARCHAR2(35)
 ,JN_SESSION NUMBER(38)
 ,class_name               VARCHAR2(24) not null,
  class_type               VARCHAR2(32),
  app_space_cntx           VARCHAR2(32),
  time_scope_code          VARCHAR2(32),
  owner_class_name         VARCHAR2(24),
  db_object_type           VARCHAR2(32),
  db_object_owner          VARCHAR2(32),
  db_object_name           VARCHAR2(32),
  db_object_attribute      VARCHAR2(32),
  db_where_condition       VARCHAR2(4000),
  record_status            VARCHAR2(1),
  created_by               VARCHAR2(30),
  created_date             DATE,
  last_updated_by          VARCHAR2(30),
  last_updated_date        DATE,
  rev_no                   NUMBER,
  rev_text                 VARCHAR2(2000),
  approval_state           VARCHAR2(1),
  approval_by              VARCHAR2(30),
  approval_date            DATE,
  rec_id                   VARCHAR2(32)
)
 PCTUSED 5
 PCTFREE 60
 TABLESPACE &ts_data
/


prompt Creating CLASS_ATTRIBUTE_CNFG...
create table CLASS_ATTRIBUTE_CNFG(
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


create table CLASS_ATTRIBUTE_CNFG_JN
 (JN_OPERATION CHAR(3) NOT NULL
 ,JN_ORACLE_USER VARCHAR2(30) NOT NULL
 ,JN_DATETIME DATE NOT NULL
 ,JN_NOTES VARCHAR2(240)
 ,JN_APPLN VARCHAR2(35)
 ,JN_SESSION NUMBER(38)
 ,class_name           VARCHAR2(24) not null,
  attribute_name       VARCHAR2(24) not null,
  app_space_cntx       VARCHAR2(32),
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
  created_by           VARCHAR2(30) ,
  created_date         DATE,
  last_updated_by      VARCHAR2(30),
  last_updated_date    DATE,
  rev_no               NUMBER,
  rev_text             VARCHAR2(2000),
  approval_state       VARCHAR2(1),
  approval_by          VARCHAR2(30),
  approval_date        DATE,
  rec_id               VARCHAR2(32)
)
 PCTUSED 5
 PCTFREE 60
 TABLESPACE &ts_data
/


prompt Creating CLASS_DEPENDENCY_CNFG...
create table CLASS_DEPENDENCY_CNFG
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

create table CLASS_DEPENDENCY_CNFG_JN
(JN_OPERATION CHAR(3) NOT NULL
 ,JN_ORACLE_USER VARCHAR2(30) NOT NULL
 ,JN_DATETIME DATE NOT NULL
 ,JN_NOTES VARCHAR2(240)
 ,JN_APPLN VARCHAR2(35)
 ,JN_SESSION NUMBER(38)
 , parent_class      VARCHAR2(24) not null,
  child_class       VARCHAR2(24) not null,
  dependency_type   VARCHAR2(32) not null,
  app_space_cntx    VARCHAR2(32) not null,
  record_status     VARCHAR2(1),
  created_by        VARCHAR2(30),
  created_date      DATE,
  last_updated_by   VARCHAR2(30),
  last_updated_date DATE,
  rev_no            NUMBER,
  rev_text          VARCHAR2(2000),
  approval_state    VARCHAR2(1),
  approval_by       VARCHAR2(30),
  approval_date     DATE,
  rec_id            VARCHAR2(32)
)
 PCTUSED 5
 PCTFREE 60
 TABLESPACE &ts_data
/


prompt Creating CLASS_RELATION_CNFG...
create table CLASS_RELATION_CNFG
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
  

create table CLASS_RELATION_CNFG_JN
(JN_OPERATION CHAR(3) NOT NULL
 ,JN_ORACLE_USER VARCHAR2(30) NOT NULL
 ,JN_DATETIME DATE NOT NULL
 ,JN_NOTES VARCHAR2(240)
 ,JN_APPLN VARCHAR2(35)
 ,JN_SESSION NUMBER(38)
 , from_class_name       VARCHAR2(24) not null,
  to_class_name         VARCHAR2(24) not null,
  role_name             VARCHAR2(24) not null,
  app_space_cntx        VARCHAR2(32),
  is_key                VARCHAR2(1),
  is_bidirectional      VARCHAR2(1),
  group_type            VARCHAR2(32),
  multiplicity          VARCHAR2(32),
  db_mapping_type       VARCHAR2(32),
  db_sql_syntax         VARCHAR2(4000),
  record_status         VARCHAR2(1),
  created_by            VARCHAR2(30),
  created_date          DATE,
  last_updated_by       VARCHAR2(30),
  last_updated_date     DATE,
  rev_no                NUMBER,
  rev_text              VARCHAR2(2000),
  approval_state        VARCHAR2(1),
  approval_by           VARCHAR2(30),
  approval_date         DATE,
  rec_id                VARCHAR2(32)
)
 PCTUSED 5
 PCTFREE 60
 TABLESPACE &ts_data
/





prompt Creating CLASS_TRIGGER_ACTN_CNFG...
create table CLASS_TRIGGER_ACTN_CNFG
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

comment on table CLASS_TRIGGER_ACTN_CNFG
  is 'Holds code that will be merged into the generated Instead of Triggers for Object and data classes';


create table CLASS_TRIGGER_ACTN_CNFG_JN
(JN_OPERATION CHAR(3) NOT NULL
 ,JN_ORACLE_USER VARCHAR2(30) NOT NULL
 ,JN_DATETIME DATE NOT NULL
 ,JN_NOTES VARCHAR2(240)
 ,JN_APPLN VARCHAR2(35)
 ,JN_SESSION NUMBER(38)
 ,class_name        VARCHAR2(24) not null,
  triggering_event  VARCHAR2(250) not null,
  trigger_type      VARCHAR2(30) not null,
  sort_order        NUMBER not null,
  app_space_cntx    VARCHAR2(32),
  db_sql_syntax     VARCHAR2(4000),
  record_status     VARCHAR2(1),
  created_by        VARCHAR2(30),
  created_date      DATE,
  last_updated_by   VARCHAR2(30),
  last_updated_date DATE,
  rev_no            NUMBER,
  rev_text          VARCHAR2(2000),
  approval_by       VARCHAR2(30),
  approval_date     DATE,
  approval_state    VARCHAR2(1),
  rec_id            VARCHAR2(32)
)
 PCTUSED 5
 PCTFREE 60
 TABLESPACE &ts_data
/


prompt Creating CLASS_TRA_PROPERTY_CNFG...
create table CLASS_TRA_PROPERTY_CNFG
(
  class_name           VARCHAR2(24) not null,
  triggering_event     VARCHAR2(250) not null,
  trigger_type         VARCHAR2(30) not null,
  sort_order           NUMBER not null,
  property_code        VARCHAR2(100) not null,
  owner_cntx           NUMBER not null,
  property_type        VARCHAR2(24) not null,
  property_value       VARCHAR2(4000),
  record_status        VARCHAR2(1),
  created_by           VARCHAR2(30) not null,
  created_date         DATE not null,
  last_updated_by      VARCHAR2(30),
  last_updated_date    DATE,
  rev_no               NUMBER,
  rev_text             VARCHAR2(2000),
  approval_by          VARCHAR2(30),
  approval_date        DATE,
  approval_state       VARCHAR2(1),
  rec_id              VARCHAR2(32)
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



create table CLASS_TRA_PROPERTY_CNFG_JN
(JN_OPERATION          CHAR(3) NOT NULL
 ,JN_ORACLE_USER       VARCHAR2(30) NOT NULL
 ,JN_DATETIME          DATE NOT NULL
 ,JN_NOTES             VARCHAR2(240)
 ,JN_APPLN             VARCHAR2(35)
 ,JN_SESSION           NUMBER(38),
  class_name           VARCHAR2(24) not null,
  triggering_event     VARCHAR2(250) not null,
  trigger_type         VARCHAR2(30) not null,
  sort_order           NUMBER not null,
  property_code        VARCHAR2(100) not null,
  owner_cntx           NUMBER not null,
  property_type        VARCHAR2(24) not null,
  property_value       VARCHAR2(4000),
  record_status        VARCHAR2(1),
  created_by           VARCHAR2(30),
  created_date         DATE,
  last_updated_by      VARCHAR2(30),
  last_updated_date    DATE,
  rev_no               NUMBER,
  rev_text             VARCHAR2(2000),
  approval_by          VARCHAR2(30),
  approval_date        DATE,
  approval_state       VARCHAR2(1),
  rec_id               VARCHAR2(32)
)
 PCTUSED 5
 PCTFREE 60
 TABLESPACE &ts_data
/



prompt Creating CLASS_PROPERTY_CNFG...
create table CLASS_PROPERTY_CNFG
(
  class_name           VARCHAR2(24) not null,
  property_code        VARCHAR2(100) not null,
  owner_cntx           NUMBER    not null,
  presentation_cntx    VARCHAR2(250) default '/EC' not null,
  property_type        VARCHAR2(24) not null,
  property_value       VARCHAR2(4000),
  record_status     		VARCHAR2(1),
  created_by        		VARCHAR2(30) not null,
  created_date      		DATE not null,
  last_updated_by   		VARCHAR2(30),
  last_updated_date 		DATE,
  rev_no            		NUMBER,
  rev_text          		VARCHAR2(2000),
  approval_state    		VARCHAR2(1),
  approval_by       		VARCHAR2(30),
  approval_date     		DATE,
  rec_id            		VARCHAR2(32)
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

create table CLASS_PROPERTY_CNFG_JN
( JN_OPERATION CHAR(3) NOT NULL
 ,JN_ORACLE_USER VARCHAR2(30) NOT NULL
 ,JN_DATETIME DATE NOT NULL
 ,JN_NOTES VARCHAR2(240)
 ,JN_APPLN VARCHAR2(35)
 ,JN_SESSION NUMBER(38)
 , class_name          VARCHAR2(24) not null,
  property_code        VARCHAR2(100) not null,
  owner_cntx           NUMBER        not null,
  presentation_cntx    VARCHAR2(250)  not null,
  property_type        VARCHAR2(24) ,
  property_value       VARCHAR2(4000),
  record_status        VARCHAR2(1),
  created_by           VARCHAR2(30),
  created_date         DATE,
  last_updated_by      VARCHAR2(30),
  last_updated_date    DATE,
  rev_no               NUMBER,
  rev_text             VARCHAR2(2000),
  approval_state       VARCHAR2(1),
  approval_by          VARCHAR2(30),
  approval_date        DATE,
  rec_id               VARCHAR2(32)
)
 PCTUSED 5
 PCTFREE 60
 TABLESPACE &ts_data
/



prompt Creating CLASS_ATTR_PROPERTY_CNFG...
create table CLASS_ATTR_PROPERTY_CNFG
(
  class_name            VARCHAR2(24) not null,
  attribute_name        VARCHAR2(24) not null,
  property_code         VARCHAR2(100) not null,
  owner_cntx            NUMBER    not null,
  presentation_cntx     VARCHAR2(250) default '/EC' not null,
  property_type         VARCHAR2(24) not null,
  property_value        VARCHAR2(4000),
  record_status         VARCHAR2(1),
  created_by            VARCHAR2(30) not null,
  created_date          DATE not null,
  last_updated_by       VARCHAR2(30),
  last_updated_date     DATE,
  rev_no                NUMBER,
  rev_text              VARCHAR2(2000),
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

create table CLASS_ATTR_PROPERTY_CNFG_JN
( JN_OPERATION CHAR(3) NOT NULL
 ,JN_ORACLE_USER VARCHAR2(30) NOT NULL
 ,JN_DATETIME DATE NOT NULL
 ,JN_NOTES VARCHAR2(240)
 ,JN_APPLN VARCHAR2(35)
 ,JN_SESSION NUMBER(38)
 , class_name          VARCHAR2(24) not null,
  attribute_name       VARCHAR2(24)  not null,
  property_code        VARCHAR2(100) not null,
  owner_cntx           NUMBER        not null,
  presentation_cntx    VARCHAR2(250)  not null,
  property_type        VARCHAR2(24) ,
  property_value       VARCHAR2(4000),
  record_status        VARCHAR2(1),
  created_by           VARCHAR2(30),
  created_date         DATE,
  last_updated_by      VARCHAR2(30),
  last_updated_date    DATE,
  rev_no               NUMBER,
  rev_text             VARCHAR2(2000),
  approval_state       VARCHAR2(1),
  approval_by          VARCHAR2(30),
  approval_date        DATE,
  rec_id               VARCHAR2(32)
)
 PCTUSED 5
 PCTFREE 60
 TABLESPACE &ts_data
/


prompt Creating CLASS_REL_PROPERTY_CNFG...
create table CLASS_REL_PROPERTY_CNFG
(
  from_class_name      VARCHAR2(24) not null,
  to_class_name        VARCHAR2(24) not null,
  role_name            VARCHAR2(24) not null,
  property_code        VARCHAR2(100) not null,
  owner_cntx           NUMBER        not null,
  presentation_cntx    VARCHAR2(250) default '/EC' not null,
  property_type        VARCHAR2(24) not null,
  property_value       VARCHAR2(4000),
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




create table CLASS_REL_PROPERTY_CNFG_JN
( JN_OPERATION CHAR(3) NOT NULL
 ,JN_ORACLE_USER VARCHAR2(30) NOT NULL
 ,JN_DATETIME DATE NOT NULL
 ,JN_NOTES VARCHAR2(240)
 ,JN_APPLN VARCHAR2(35)
 ,JN_SESSION NUMBER(38)
 ,from_class_name      VARCHAR2(24) not null,
  to_class_name        VARCHAR2(24) not null,
  role_name            VARCHAR2(24) not null,
  property_code        VARCHAR2(100) not null,
  owner_cntx           NUMBER  not null,
  presentation_cntx    VARCHAR2(250)  not null,
  property_type        VARCHAR2(24) ,
  property_value       VARCHAR2(4000),
  record_status        VARCHAR2(1),
  created_by           VARCHAR2(30) ,
  created_date         DATE ,
  last_updated_by      VARCHAR2(30),
  last_updated_date    DATE,
  rev_no               NUMBER,
  rev_text             VARCHAR2(2000),
  approval_state       VARCHAR2(1),
  approval_by          VARCHAR2(30),
  approval_date        DATE,
  rec_id               VARCHAR2(32)
)
 PCTUSED 5
 PCTFREE 60
 TABLESPACE &ts_data
/

PROMPT Creating class_property_codes...
CREATE TABLE class_property_codes
(
  property_table_name      VARCHAR2(24) not null,
  property_code            VARCHAR2(100) not null,
  property_type            VARCHAR2(32) not null,
  override_allowed_ind     VARCHAR2(1) not null,
  protected_ind            VARCHAR2(1) not null,
  data_type                VARCHAR2(32) not null,
  presentation_cntx_regexp VARCHAR2(250) not null,
  sort_order               NUMBER,
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
COMMENT ON COLUMN class_property_codes.property_table_name IS 'Name of property table where this property code can be used'
/
COMMENT ON COLUMN class_property_codes.property_code IS 'Property code'
/
COMMENT ON COLUMN class_property_codes.property_type IS 'Property type'
/
COMMENT ON COLUMN class_property_codes.override_allowed_ind IS 'Y/N flag indicating whether the property can be overidden or not'
/
COMMENT ON COLUMN class_property_codes.protected_ind IS 'Y/N flag indicating whether the property is writable or not'
/
COMMENT ON COLUMN class_property_codes.data_type IS 'Property value data type'
/
COMMENT ON COLUMN class_property_codes.presentation_cntx_regexp IS 'Regular expression that matches all presentation contexts where this property can be used'
/
COMMENT ON COLUMN class_property_codes.sort_order IS 'Property sort order '
/

CREATE TABLE class_property_codes_jn
( jn_operation             CHAR(3) NOT NULL,
  jn_oracle_user           VARCHAR2(30) NOT NULL,
  jn_datetime              DATE NOT NULL,
  jn_notes                 VARCHAR2(240),
  jn_appln                 VARCHAR2(35),
  jn_session               NUMBER(38),
  property_table_name      VARCHAR2(24) NOT NULL,
  property_code            VARCHAR2(100) NOT NULL,
  property_type            VARCHAR2(32) NOT NULL,
  override_allowed_ind     VARCHAR2(1) NOT NULL,
  protected_ind            VARCHAR2(1) NOT NULL,
  data_type                VARCHAR2(32) NOT NULL,
  presentation_cntx_regexp VARCHAR2(32) NOT NULL,
  sort_order               NUMBER,
  record_status            VARCHAR2(1),
  created_by               VARCHAR2(30) NOT NULL,
  created_date             DATE NOT NULL,
  last_updated_by          VARCHAR2(30),
  last_updated_date        DATE,
  rev_no                   NUMBER,
  rev_text                 VARCHAR2(2000),
  approval_state           VARCHAR2(1),
  approval_by              VARCHAR2(30),
  approval_date            DATE,
  rec_id                   VARCHAR2(32)
)
 PCTUSED 5
 PCTFREE 60
 TABLESPACE &ts_data
/


alter table CLASS_CNFG
  add constraint PK_CLASS_CNFG primary key (CLASS_NAME)
  using index 
  tablespace &ts_index
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );

alter table CLASS_CNFG
  add constraint CHK_CLASS_CNFG_1
  check (class_type
IN ('OBJECT','DATA','SUB_CLASS','INTERFACE','TABLE', 'REPORT','META'));
alter table CLASS_CNFG
  add constraint CHK_CLASS_CNFG_2
  check (time_scope_code
IN ('DAY','MTH','WEEK','YR','QTR','1HR','2HR','SAMPLE','EVENT','NONE',
'VERSIONED'));
alter table CLASS_CNFG
  add constraint CHK_CLASS_CNFG_3
  check (db_object_type IN ('TABLE','VIEW'));
alter table CLASS_CNFG
  add constraint CHK_CLASS_CNFG_4
  check (APPROVAL_STATE IS NULL OR APPROVAL_STATE IN ('N','O','U','D'));


alter table CLASS_PROPERTY_CNFG
  add constraint PK_CLASS_PROPERTY_CNFG primary key (CLASS_NAME, PROPERTY_CODE, PROPERTY_TYPE, OWNER_CNTX, PRESENTATION_CNTX)
  using index 
  tablespace &ts_index
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
  
PROMPT Creating Foreign Key on 'CLASS_PROPERTY_CNFG'
ALTER TABLE CLASS_PROPERTY_CNFG 
 ADD (CONSTRAINT FK_CLASS_PROPERTY_CNFG FOREIGN KEY 
  (CLASS_NAME) REFERENCES CLASS_CNFG
  (CLASS_NAME))
/
  

alter table CLASS_ATTRIBUTE_CNFG
  add constraint PK_CLASS_ATTRIBUTE_CNFG primary key (CLASS_NAME, ATTRIBUTE_NAME)
  using index 
  tablespace &ts_index
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );


PROMPT Creating Foreign Key on 'CLASS_ATTRIBUTE_CNFG'
ALTER TABLE CLASS_ATTRIBUTE_CNFG 
 ADD (CONSTRAINT FK_CLASS_ATTRIBUTE_CNFG FOREIGN KEY 
  (CLASS_NAME) REFERENCES CLASS_CNFG
  (CLASS_NAME))
/


alter table CLASS_ATTRIBUTE_CNFG
  add constraint CHK_CLASS_ATTRIBUTE_CNFG_1
  check (is_key IN ('Y','N'));
alter table CLASS_ATTRIBUTE_CNFG
  add constraint CHK_CLASS_ATTRIBUTE_CNFG_3
  check (data_type IN ('STRING','NUMBER','INTEGER','DATE','BOOLEAN','FLOAT'));
alter table CLASS_ATTRIBUTE_CNFG
  add constraint CHK_CLASS_ATTRIBUTE_CNFG_4
  check (APPROVAL_STATE IS NULL OR APPROVAL_STATE IN ('N','O','U','D'));


alter table CLASS_ATTR_PROPERTY_CNFG
  add constraint PK_CLASS_ATTR_PROPERTY_CNFG primary key (CLASS_NAME, ATTRIBUTE_NAME, PROPERTY_CODE, PROPERTY_TYPE,OWNER_CNTX, PRESENTATION_CNTX)
  using index 
  tablespace &ts_index
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );


PROMPT Creating Foreign Key on 'CLASS_ATTR_PROPERTY_CNFG'
ALTER TABLE CLASS_ATTR_PROPERTY_CNFG 
 ADD (CONSTRAINT FK_CLASS_ATTR_PROPERTY_CNFG FOREIGN KEY 
  (CLASS_NAME,ATTRIBUTE_NAME) REFERENCES CLASS_ATTRIBUTE_CNFG
  (CLASS_NAME,ATTRIBUTE_NAME))
/


  
alter table CLASS_ATTR_PROPERTY_CNFG
  add constraint CHK_CLASS_ATTR_PROPERTY_CNFG_1
  check (APPROVAL_STATE IS NULL OR APPROVAL_STATE IN ('N','O','U','D'));


alter table CLASS_DEPENDENCY_CNFG
  add constraint PK_CLASS_DEPENDENCY_CNFG primary key (PARENT_CLASS, CHILD_CLASS, DEPENDENCY_TYPE)
  using index 
  tablespace &ts_index
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );

alter table CLASS_DEPENDENCY_CNFG
  add constraint CHK_CLASS_DEPENDENCY_CNFG_1
  check (DEPENDENCY_TYPE
IN ('IMPLEMENTS','REPORT_MEMBER','ACCESS_CONTROLLED_BY'));

alter table CLASS_DEPENDENCY_CNFG
  add constraint CHK_CLASS_DEPENDENCY_CNFG_2
  check (APPROVAL_STATE IS NULL OR APPROVAL_STATE IN ('N','O','U','D'));


alter table CLASS_RELATION_CNFG
  add constraint PK_CLASS_RELATION_CNFG primary key (FROM_CLASS_NAME, TO_CLASS_NAME, ROLE_NAME)
  using index 
  tablespace &ts_index
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );


alter table CLASS_RELATION_CNFG
  add constraint CHK_CLASS_RELATION_CNFG_4
  check (APPROVAL_STATE IS NULL OR APPROVAL_STATE IN ('N','O','U','D'));


alter table CLASS_REL_PROPERTY_CNFG
  add constraint PK_CLASS_REL_PROPERTY_CNFG primary key (FROM_CLASS_NAME, TO_CLASS_NAME, ROLE_NAME, PROPERTY_CODE, PROPERTY_TYPE, OWNER_CNTX, PRESENTATION_CNTX)
  using index 
  tablespace &ts_index
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );


PROMPT Creating Foreign Key on 'CLASS_REL_PROPERTY_CNFG'
ALTER TABLE CLASS_REL_PROPERTY_CNFG 
 ADD (CONSTRAINT FK_CLASS_REL_PROPERTY_CNFG_1 FOREIGN KEY 
  (FROM_CLASS_NAME,TO_CLASS_NAME,ROLE_NAME) REFERENCES CLASS_RELATION_CNFG
  (FROM_CLASS_NAME,TO_CLASS_NAME,ROLE_NAME))
/



alter table CLASS_REL_PROPERTY_CNFG
  add constraint CHK_CLASS_REL_PROPERTY_CNFG_1
  check (APPROVAL_STATE IS NULL OR APPROVAL_STATE IN ('N','O','U','D'));


alter table CLASS_TRIGGER_ACTN_CNFG
  add constraint PK_CLASS_TRIGGER_ACTN_CNFG primary key (CLASS_NAME, TRIGGERING_EVENT, TRIGGER_TYPE, SORT_ORDER)
  using index 
  tablespace &ts_index
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );


PROMPT Creating Foreign Key on 'CLASS_TRIGGER_ACTN_CNFG'
ALTER TABLE CLASS_TRIGGER_ACTN_CNFG 
 ADD (CONSTRAINT FK_CLASS_TRIGGER_ACTN_CNFG_1 FOREIGN KEY 
  (CLASS_NAME) REFERENCES CLASS_CNFG
  (CLASS_NAME))
/


  
alter table CLASS_TRIGGER_ACTN_CNFG
  add constraint CHK_CLASS_TRIGGER_ACTN_CNFG_1
  check (APPROVAL_STATE IS NULL OR APPROVAL_STATE IN ('N','O','U','D'));
  
  
alter table CLASS_TRA_PROPERTY_CNFG
  add constraint PK_CLASS_TRA_PROPERTY_CNFG primary key (CLASS_NAME, TRIGGERING_EVENT, TRIGGER_TYPE, SORT_ORDER, PROPERTY_CODE, OWNER_CNTX)
  using index 
  tablespace &ts_index
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );

PROMPT Creating Foreign Key on 'CLASS_TRA_PROPERTY_CNFG'
ALTER TABLE CLASS_TRA_PROPERTY_CNFG 
 ADD (CONSTRAINT FK_CLASS_TRA_PROPERTY_CNFG FOREIGN KEY 
  (CLASS_NAME,TRIGGERING_EVENT,TRIGGER_TYPE,SORT_ORDER) REFERENCES CLASS_TRIGGER_ACTN_CNFG
  (CLASS_NAME,TRIGGERING_EVENT,TRIGGER_TYPE,SORT_ORDER))
/


  
alter table CLASS_TRA_PROPERTY_CNFG
  add constraint CHK_CLASS_TRA_PROPERTY_CNFG_1
  check (APPROVAL_STATE IS NULL OR APPROVAL_STATE IN ('N','O','U','D'));
  

PROMPT Creating Primary Key on 'class_property_codes'
ALTER TABLE class_property_codes
 ADD (CONSTRAINT PK_CLASS_PROPERTY_CODES PRIMARY KEY 
  (PROPERTY_TABLE_NAME
  ,PROPERTY_CODE
  ,PROPERTY_TYPE
  )
 USING INDEX 
 STORAGE
 (
   INITIAL 65536
   MINEXTENTS 1
   MAXEXTENTS UNLIMITED
 )
 TABLESPACE &ts_index)
/

ALTER TABLE class_property_codes ADD CONSTRAINT chk_class_property_codes_1 
    CHECK (property_table_name IS NULL OR property_table_name IN ('CLASS_ATTR_PROPERTY_CNFG','CLASS_PROPERTY_CNFG','CLASS_REL_PROPERTY_CNFG','CLASS_TRA_PROPERTY_CNFG'))
/ 
ALTER TABLE class_property_codes ADD CONSTRAINT chk_class_property_codes_2 
    CHECK (override_allowed_ind IS NULL OR override_allowed_ind IN ('Y','N'))
/ 
ALTER TABLE class_property_codes ADD CONSTRAINT chk_class_property_codes_3 
    CHECK (protected_ind IS NULL OR protected_ind IN ('Y','N'))
/ 
ALTER TABLE class_property_codes ADD CONSTRAINT chk_class_property_codes_4 
    CHECK (data_type IS NULL OR data_type IN ('BOOLEAN','DATE','NUMBER','STRING','FLOAT','INTEGER'))
/ 


CREATE INDEX IR_CLASS_DEPENDENCY_CNFG_2 ON CLASS_DEPENDENCY_CNFG
  (CHILD_CLASS)
 INITRANS 2
 MAXTRANS 255
 PCTFREE 50
 STORAGE
 (
   PCTINCREASE 50
   NEXT 65536
 )
 TABLESPACE &ts_index
/

 
CREATE INDEX IR_CLASS_RELATION_CNFG_2 ON CLASS_RELATION_CNFG
  (TO_CLASS_NAME)
 INITRANS 2
 MAXTRANS 255
 PCTFREE 50
 STORAGE
 (
   PCTINCREASE 50
   NEXT 65536
 )
 TABLESPACE &ts_index
/


exec ec_generate.basicIUTriggers('CLASS_CNFG');
exec ec_generate.basicIUTriggers('CLASS_ATTRIBUTE_CNFG');
exec ec_generate.basicIUTriggers('CLASS_RELATION_CNFG');
exec ec_generate.basicIUTriggers('CLASS_TRIGGER_ACTN_CNFG');
exec ec_generate.basicIUTriggers('CLASS_DEPENDENCY_CNFG');
exec ec_generate.basicIUTriggers('CLASS_PROPERTY_CNFG');
exec ec_generate.basicIUTriggers('CLASS_ATTR_PROPERTY_CNFG');
exec ec_generate.basicIUTriggers('CLASS_REL_PROPERTY_CNFG');
exec ec_generate.basicIUTriggers('CLASS_TRA_PROPERTY_CNFG');
exec ec_generate.basicIUTriggers('CLASS_PROPERTY_CODES');



