ALTER TABLE T_BASIS_OBJECT ADD (CONSTRAINT UK_T_BASIS_OBJECT_1 UNIQUE ( APP_ID, OBJECT_NAME ) USING INDEX STORAGE ( PCTINCREASE 50 INITIAL 65536 NEXT 65536 MAXEXTENTS 249 ) TABLESPACE INDEX02_WST);