CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_IMP_STAGING_POPUP" ("INTERFACE_CODE", "FILE_NAME", "CODE", "STAGING_TYPE", "SORT_ORDER", "M_SORT_ORDER", "EC_KEY", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  select distinct s.INTERFACE_CODE,s.FILE_NAME,
                '[TABLE]' code,
                'TABLE' staging_type,
                0 sort_order,
                0 m_sort_order,
                null ec_key,
                'P' AS RECORD_STATUS ,
                null AS CREATED_BY,
                null AS CREATED_DATE,
                null AS LAST_UPDATED_BY,
                null AS LAST_UPDATED_DATE,
                null AS REV_NO,
                null AS REV_TEXT
   from imp_staging s, imp_source_mapping m
  where s.interface_code = m.interface_code
    and s.code = m.code
union
select
distinct s.INTERFACE_CODE,
         s.FILE_NAME,
         s.code,
         s.staging_type,
         1 sort_order,
         m.sort_order,
         s.ec_key,
         'P' AS RECORD_STATUS ,
         null AS CREATED_BY,
         null AS CREATED_DATE,
         null AS LAST_UPDATED_BY,
         null AS LAST_UPDATED_DATE,
         null AS REV_NO,
         null AS REV_TEXT
   from imp_staging s, imp_source_mapping m
  where s.interface_code = m.interface_code
    and s.code = m.code
order by interface_code,sort_order,m_sort_order