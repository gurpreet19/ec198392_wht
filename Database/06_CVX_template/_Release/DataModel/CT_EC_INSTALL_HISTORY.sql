DROP TABLE CT_EC_INSTALL_HISTORY;

CREATE TABLE CT_EC_INSTALL_HISTORY
(
  INSTALL_ID         VARCHAR2(32 BYTE)          NOT NULL,
  RELEASE_DATE       DATE                       NOT NULL,
  INSTALLED_DATE     DATE,
  INSTALLED_BY       VARCHAR2(32 BYTE)          NOT NULL,
  DESCRIPTION        VARCHAR2(1000 BYTE),
  RECORD_STATUS      VARCHAR2(32 BYTE),
  CREATED_BY         VARCHAR2(32 BYTE),
  CREATED_DATE       DATE,
  LAST_UPDATED_BY    VARCHAR2(32 BYTE),
  LAST_UPDATED_DATE  DATE,
  REV_NO             NUMBER,
  REV_TEXT           VARCHAR2(100 BYTE),
  PREPARED_BY        VARCHAR2(100 BYTE)
)
TABLESPACE &ts_data
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          80K
            NEXT             2M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING;

COMMENT ON TABLE CT_EC_INSTALL_HISTORY IS 'Contains the installation history of the database. To be used for all releases and patches.';

COMMENT ON COLUMN CT_EC_INSTALL_HISTORY.INSTALL_ID IS 'The name of the patch or release.If a patch use the name of the main file.';

COMMENT ON COLUMN CT_EC_INSTALL_HISTORY.RELEASE_DATE IS 'The date of release to the client';

CREATE UNIQUE INDEX PK_CT_EC_INSTALL_HISTORY ON CT_EC_INSTALL_HISTORY
(INSTALL_ID, INSTALLED_DATE)
LOGGING
TABLESPACE &ts_index
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          80K
            MINEXTENTS       1
            MAXEXTENTS       2147483645
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


CREATE OR REPLACE TRIGGER CT_IU_TE_INSTALL_HISTORY
BEFORE INSERT OR UPDATE ON CT_EC_INSTALL_HISTORY
FOR EACH ROW
DECLARE
    lv_user VARCHAR2(32);
BEGIN
    BEGIN
      lv_user := sys_context('USERENV','OS_USER');
    EXCEPTION WHEN OTHERS THEN
      lv_user := user;
    END;
    IF Inserting THEN
      :new.installed_by := lv_user;
      :new.installed_date := EcDp_Date_Time.getCurrentSysdate;
      :new.rev_no := 0;
    ELSE
      :new.rev_no := NVL(:old.rev_no,0) + 1;
      :new.last_updated_by := lv_user;
      :new.last_updated_date := EcDp_Date_Time.getCurrentSysdate;
    END IF;
END;
/
SHOW ERRORS;


CREATE OR REPLACE TRIGGER IU_CT_EC_INSTALL_HISTORY
BEFORE INSERT OR UPDATE ON CT_EC_INSTALL_HISTORY
FOR EACH ROW
BEGIN
    -- $Revision: 1.19 $
    -- Basis
    IF Inserting THEN
      :new.record_status := 'P';
      IF :new.created_by IS NULL THEN
         :new.created_by := User;
      END IF;
      IF :new.created_date IS NULL THEN
         :new.created_date := EcDp_Date_Time.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;
    ELSE
      IF Nvl(:new.record_status,'P') = Nvl(:old.record_status,'P') THEN
         IF NOT UPDATING('LAST_UPDATED_BY') THEN
            :new.last_updated_by := User;
         END IF;
         IF NOT UPDATING('LAST_UPDATED_DATE') THEN
           :new.last_updated_date := EcDp_Date_Time.getCurrentSysdate;
         END IF;
      END IF;
    END IF;
END;
/


