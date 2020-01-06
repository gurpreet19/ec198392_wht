Prompt -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
Prompt end delta entry in ctrl_pinc
Prompt -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
set define on
INSERT INTO ctrl_pinc (DAYTIME, TYPE, NAME, MD5SUM, CREATED_BY ,CREATED_DATE) VALUES (sysdate, 'DELTA', 'END '||'&ctrl_pinc_entry', 'N/A', USER ,SYSDATE);
