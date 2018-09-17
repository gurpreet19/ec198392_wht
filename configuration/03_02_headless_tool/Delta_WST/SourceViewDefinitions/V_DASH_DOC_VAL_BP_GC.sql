CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_DASH_DOC_VAL_BP_GC" ("SORT_ORDER", "PERIOD_CHAR", "PERIOD_DATE", "DOC_VALUE", "FIN_CODE_TEXT", "CO_NAME", "GROUP_CURRENCY_CODE", "CO_ID") AS 
  select
   max(m.sort_order) as sort_order,
   to_char(trunc(max(m.daytime),'MM'), 'Mon YYYY') as PERIOD_CHAR,
   trunc(max(m.daytime), 'MM') as PERIOD_DATE,
   case when max(x.object_id) = ''  then 0
        when m.code in ('SALE','TA_INCOME','JOU_ENT','PURCHASE','TA_COST') then nvl(sum(x.group_value),0)
   end as DOC_VALUE,
   max(m.code_text) as FIN_CODE_TEXT,
   ec_company_version.name(m.co_id,m.daytime,'<=') as co_name,
   max(GROUP_CURRENCY_CODE) as GROUP_CURRENCY_CODE,
   m.co_id as co_id
  from (select distinct m.daytime,
                        p.code,
                        p.sort_order,
                        p.is_default,
                        p.code_text,
                        a.attribute_text as GROUP_CURRENCY_CODE,
                        co.company_id as co_id
          from system_mth_status      m,
               prosty_codes           p,
               ctrl_system_attribute  a,
               company                co
         where p.code_type = 'FINANCIAL_CODE_BASIC'
         and p.code in ('SALE','TA_INCOME','JOU_ENT','PURCHASE','TA_COST')
         and a.attribute_type = 'GROUP_CURRENCY_CODE'
           and co.company_id is not null
           ) m
  left join V_DASH_DOC_VAL_BP x
    on (m.daytime = trunc(x.booking_period, 'MM')
        and m.code = x.financial_code
        and m.co_id = x.co_id
        )
 group by m.code, m.daytime, m.co_id
order by period_date, co_id, sort_order