create table CT_DQ_RULE_RUN_LOG
( RUN_ID        INTEGER NOT NULL,
  RULE_ID   INTEGER NOT NULL,
  TOTAL_ERRORS   INTEGER,
  TOTAL_NEW_ERRORS   INTEGER,
  TOTAL_OLD_ERRORS   INTEGER,
  TOTAL_DELETED_ERRORS INTEGER,
  TOTAL_ROLLED_ERRORS INTEGER,
  STARTED_DATE   DATE,
  COMPLETED_DATE   DATE,
  RECORD_STATUS VARCHAR2(1),
  CREATED_BY     VARCHAR2(30),
  CREATED_DATE   DATE,
  LAST_UPDATED_BY VARCHAR2(30),
  LAST_UPDATED_DATE DATE,
  REV_NO    NUMBER,
  REV_TEXT   VARCHAR2(240)
)
 INITRANS 1
 MAXTRANS 255
 PCTUSED 40
 PCTFREE 40
 STORAGE
 (
   PCTINCREASE 20
   INITIAL 1048576
   NEXT 1048576
   MAXEXTENTS 240
 )
 TABLESPACE &&ts_data
 NOCACHE
/

CREATE UNIQUE INDEX CT_DQ_RULE_RUN_LOG_PK ON CT_DQ_RULE_RUN_LOG
(RUN_ID, RULE_ID)
LOGGING
TABLESPACE &&ts_index
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          1M
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;

ALTER TABLE CT_DQ_RULE_RUN_LOG ADD (
  CONSTRAINT CT_DQ_RULE_RUN_LOG_PK
 PRIMARY KEY
(RUN_ID, RULE_ID)
    USING INDEX 
    TABLESPACE &&ts_index
    PCTFREE    10
    INITRANS   2
    MAXTRANS   255
    STORAGE    (
                INITIAL          1M
                NEXT             1M
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                PCTINCREASE      0
               ));
