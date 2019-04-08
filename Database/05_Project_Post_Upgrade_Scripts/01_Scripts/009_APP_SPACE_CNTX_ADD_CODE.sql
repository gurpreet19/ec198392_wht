INSERT INTO APP_SPACE_CNTX (CODE, NAME, OWNER_CNTX, SORT_ORDER) VALUES('CVX', 'Chevron Global Template', 2500, 90);
INSERT INTO APP_SPACE_CNTX (CODE, NAME, OWNER_CNTX, SORT_ORDER) VALUES('WST', 'WHEATSTONE Customizations', 2500, 100);
INSERT INTO APP_SPACE_CNTX (CODE, NAME, OWNER_CNTX, SORT_ORDER) VALUES('GORGON', 'GORGON Customizations', 2500, 110);
INSERT INTO APP_SPACE_CNTX (CODE, NAME, OWNER_CNTX, SORT_ORDER) VALUES('DELETE_CANDIDATE', 'To be deleted', 2500, 120);
update CLASS_DEPENDENCY_CNFG set app_space_cntx ='WST' where app_space_cntx in ('XX_TRAN','XX_PROD');
ALTER TABLE CLASS_ATTRIBUTE_CNFG ADD CONSTRAINT FK_CLASS_ATTRIBUTE_CNFG_1 FOREIGN KEY (APP_SPACE_CNTX) REFERENCES APP_SPACE_CNTX (CODE);
ALTER TABLE CLASS_CNFG ADD CONSTRAINT FK_CLASS_CNFG_1 FOREIGN KEY (APP_SPACE_CNTX) REFERENCES APP_SPACE_CNTX (CODE);
ALTER TABLE CLASS_DEPENDENCY_CNFG ADD CONSTRAINT FK_CLASS_DEPENDENCY_CNFG_1 FOREIGN KEY (APP_SPACE_CNTX) REFERENCES APP_SPACE_CNTX (CODE);
ALTER TABLE CLASS_RELATION_CNFG ADD CONSTRAINT FK_CLASS_RELATION_CNFG_1 FOREIGN KEY (APP_SPACE_CNTX) REFERENCES APP_SPACE_CNTX (CODE);
ALTER TABLE CLASS_TRIGGER_ACTN_CNFG ADD CONSTRAINT FK_CLASS_TRIGGER_ACTN_CNFG_2 FOREIGN KEY (APP_SPACE_CNTX) REFERENCES APP_SPACE_CNTX (CODE);