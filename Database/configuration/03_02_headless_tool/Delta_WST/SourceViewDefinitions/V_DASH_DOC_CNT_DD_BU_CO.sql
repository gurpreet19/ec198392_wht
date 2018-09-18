CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_DASH_DOC_CNT_DD_BU_CO" ("SORT_ORDER", "IS_DEFAULT", "PERIOD_CHAR", "PERIOD_DATE", "DOC_COUNT", "STATUS", "INC_BOOKED", "DASH_HEADER", "CO_ID", "BU_ID") AS 
  select max(m.sort_order) as sort_order,
       max(m.is_default) as is_default,
       to_char(trunc(max(m.daytime), 'MM'), 'Mon YYYY') as PERIOD_CHAR,
       trunc(max(m.daytime), 'MM') as PERIOD_DATE,
       sum(decode(x.object_id, null, 0, 1)) as DOC_COUNT,
       m.code as STATUS,
       decode(max(m.code),'BOOKED','Y','N') as INC_BOOKED,
       'Document Validation Count by Document Date for Company/Business Unit '''
       ||max(m.co_name)
       ||''''
       ||'/'''
       ||max(m.bu_name)
       ||'''' as DASH_HEADER,
       m.CO_ID as CO_ID,
       m.BU_ID as BU_ID
  from (select distinct m.daytime,
                        p.code,
                        p.sort_order,
                        p.is_default,
                        cov.name as CO_NAME,
                        co.object_id  as CO_ID,
                        buv.name as BU_NAME,
                        bu.object_id as BU_ID
          from system_mth_status     m,
               prosty_codes          p,
               company               co,
               company_version       cov,
               business_unit_version buv,
               business_unit         bu
         where p.code_type = 'DOCUMENT_LEVEL_CODE'
           and cov.system_company_ind = 'Y'
           and co.object_id = cov.object_id
           and bu.object_id = buv.object_id
         ) m
  left join cont_document x
    on (m.daytime = trunc(x.document_date, 'MM')
        and m.code = x.document_level_code and m.CO_ID = x.owner_company_id
        and m.bu_id = ec_contract_area_version.business_unit_id(ec_contract_area.object_id_by_uk(x.CONTRACT_AREA_CODE), x.daytime,'<=')
       )
 group by m.code, m.CO_ID, m.bu_id, m.daytime
 order by period_date, m.CO_ID, m.bu_id, is_default desc, sort_order