CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_DASH_DOC_VAL_BP_BC_CA" ("SORT_ORDER", "PERIOD_CHAR", "PERIOD_DATE", "DOC_VALUE", "FIN_CODE_TEXT", "CO_NAME", "CA_NAME", "CA_ID", "CO_ID", "BOOKING_CURRENCY_CODE", "BOOKING_CURRENCY_ID") AS 
  select
   max(m.sort_order) as sort_order,
   to_char(trunc(max(m.daytime),'MM'), 'Mon YYYY') as PERIOD_CHAR,
   trunc(max(m.daytime), 'MM') as PERIOD_DATE,
   case when max(x.object_id) = ''  then 0
        when m.code in ('SALE','TA_INCOME','JOU_ENT','PURCHASE','TA_COST') then nvl(sum(x.booking_value),0)
   end as DOC_VALUE,
   max(m.code_text) as FIN_CODE_TEXT,
   ec_company_version.name(m.co_id,m.daytime,'<=') as co_name,
   max(m.ca_name) as ca_name,
   m.ca_id as ca_id,
   m.co_id as co_id,
   max(m.booking_currency_code) as BOOKING_CURRENCY_CODE,
   m.booking_currency_id as BOOKING_CURRENCY_ID
  from (select distinct m.daytime,
                        p.code,
                        p.sort_order,
                        p.code_text,
                        co.company_id as co_id,
                        ca.object_id as ca_id,
                        cav.name as ca_name,
                        cu.object_id as booking_currency_id,
                        cu.object_code as booking_currency_code
          from system_mth_status     m,
               prosty_codes          p,
               company               co,
               contract_area         ca,
               contract_area_version cav,
               currency              cu
         where p.code_type = 'FINANCIAL_CODE_BASIC'
          and p.code in ('SALE','TA_INCOME','JOU_ENT','PURCHASE','TA_COST')
          and co.company_id is not null
          and ca.object_id = cav.object_id
        ) m
  left join V_DASH_DOC_VAL_BP x
    on (m.daytime = trunc(x.booking_period, 'MM')
        and m.code = x.financial_code
        and m.co_id = x.co_id
        and m.booking_currency_id = x.booking_currency_id
        and m.ca_id = x.contract_area_id
        )
 group by m.code, m.daytime, m.co_id, m.ca_id, m.booking_currency_id
order by period_date, co_id, ca_id, booking_currency_id, sort_order