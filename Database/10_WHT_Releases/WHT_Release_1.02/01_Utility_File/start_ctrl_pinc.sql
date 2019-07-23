Prompt -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
Prompt start delta entry in ctrl_pinc
Prompt -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
Insert into CTRL_PINC (TYPE, NAME, MD5SUM, DAYTIME, RECORD_STATUS,CREATED_BY, CREATED_DATE, REV_NO)
 Values
   ('DELTA', 'START '||'&ctrl_pinc_entry', 'N/A',sysdate , 'P',USER, sysdate, 0);