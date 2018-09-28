DROP TABLE CT_EC_INSTALLED_FEATURES CASCADE CONSTRAINTS;

CREATE TABLE CT_EC_INSTALLED_FEATURES
(
  FEATURE_ID         VARCHAR2(32 BYTE)          NOT NULL,
  FEATURE_NAME       VARCHAR2(255 BYTE)         NOT NULL,
  CONTEXT_CODE       VARCHAR2(32 BYTE)          NOT NULL,
  MAJOR_VERSION      NUMBER                     NOT NULL,
  MINOR_VERSION      NUMBER                     NOT NULL,
  DESCRIPTION        VARCHAR2(1000 BYTE),
  RECORD_STATUS      VARCHAR2(32 BYTE),
  CREATED_BY         VARCHAR2(32 BYTE),
  CREATED_DATE       DATE,
  LAST_UPDATED_BY    VARCHAR2(32 BYTE),
  LAST_UPDATED_DATE  DATE,
  REV_NO             NUMBER,
  REV_TEXT           VARCHAR2(100 BYTE)
)
TABLESPACE &ts_data
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          80K
            NEXT             1M
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

COMMENT ON TABLE CT_EC_INSTALLED_FEATURES IS 'Contains a list of all features installed on top of EC by Chevron';

COMMENT ON COLUMN CT_EC_INSTALLED_FEATURES.FEATURE_ID IS 'A unique ID for the feature';

COMMENT ON COLUMN CT_EC_INSTALLED_FEATURES.FEATURE_NAME IS 'A user-friendly name for the feature';

COMMENT ON COLUMN CT_EC_INSTALLED_FEATURES.CONTEXT_CODE IS 'Indicates which department drove the feature.';

COMMENT ON COLUMN CT_EC_INSTALLED_FEATURES.MAJOR_VERSION IS 'Major version number. Increments on fundamental feature changes only.';

COMMENT ON COLUMN CT_EC_INSTALLED_FEATURES.MINOR_VERSION IS 'Major version number. Increments with each patch.';


CREATE UNIQUE INDEX PK_CT_EC_INSTALLED_FEATURES ON CT_EC_INSTALLED_FEATURES
(FEATURE_ID)
LOGGING
TABLESPACE &ts_index
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          96K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


CREATE OR REPLACE TRIGGER "IU_CT_EC_INSTALLED_FEATURES" 
BEFORE INSERT OR UPDATE ON CT_EC_INSTALLED_FEATURES FOR EACH ROW
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