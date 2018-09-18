CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_DASH_DOC_CNT_DD_ALL" ("SORT_ORDER", "IS_DEFAULT", "PERIOD_CHAR", "PERIOD_DATE", "DOC_COUNT", "STATUS", "DASH_HEADER", "INC_BOOKED") AS 
  select max(m.sort_order) as sort_order,
       max(m.is_default) as is_default,
       to_char(trunc(max(m.daytime), 'MM'), 'Mon YYYY') as PERIOD_CHAR,
       trunc(max(m.daytime), 'MM') as PERIOD_DATE,
       sum(decode(x.object_id, null, 0, 1)) as DOC_COUNT,
       m.code as STATUS,
       'Document Validation Count by Document Date - System overall' as DASH_HEADER,
       decode(max(m.code),'BOOKED','Y','N') as INC_BOOKED
  from (select distinct m.daytime,
                        p.code,
                        p.sort_order,
                        p.is_default
          from system_mth_status m,
               prosty_codes      p
         where p.code_type = 'DOCUMENT_LEVEL_CODE') m
  left join cont_document x
    on (m.daytime = trunc(x.document_date, 'MM') and
       m.code = x.document_level_code)
 group by m.code, m.daytime
 order by period_date, is_default desc, sort_order