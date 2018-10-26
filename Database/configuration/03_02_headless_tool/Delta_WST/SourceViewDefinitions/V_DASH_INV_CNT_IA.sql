CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_DASH_INV_CNT_IA" ("SORT_ORDER", "IS_DEFAULT", "PERIOD_CHAR", "PERIOD_DATE", "INV_COUNT", "STATUS", "INC_BOOKED", "DASH_HEADER", "IA_CODE", "IA_ID") AS 
  select max(m.sort_order) as sort_order,
       max(m.is_default) as is_default,
       to_char(trunc(max(m.daytime), 'MM'), 'Mon YYYY') as PERIOD_CHAR,
       trunc(max(m.daytime), 'MM') as PERIOD_DATE,
       sum(decode(x.object_id, null, 0, 1)) as INV_COUNT,
       m.code as STATUS,
       decode(max(m.code),'BOOKED','Y','N') as INC_BOOKED,
       'Inventory Validation Count for Inventory Area '''||max(m.ia_name)||'''' as DASH_HEADER,
       max(m.IA_CODE) as IA_CODE,
       m.ia_id as IA_ID
  from (select distinct m.daytime,
                        p.code,
                        p.sort_order,
                        p.is_default,
                        iav.name as IA_NAME,
                        ia.object_code as IA_CODE,
                        ia.object_id as IA_ID
          from system_mth_status        m,
               prosty_codes             p,
               inventory_area_version   iav,
               inventory_area           ia
         where p.code_type = 'DOCUMENT_LEVEL_CODE'
         and ec_ctrl_system_attribute.attribute_text(m.daytime,'INV_4EYE_VALIDATION','<=') = 'N'
         and p.code in ('OPEN','VALID1','TRANSFER','BOOKED')
         and ia.object_id = iav.object_id
         ) m
  left join inv_valuation x
    on (m.daytime = trunc(x.daytime, 'MM')
       and m.code = x.document_level_code
       and m.IA_ID = ec_inventory_version.inventory_area_id(x.object_id, x.daytime, '<='))
 group by m.code, m.daytime, m.ia_id
union all
select max(m.sort_order) as sort_order,
       max(m.is_default) as is_default,
       to_char(trunc(max(m.daytime), 'MM'), 'Mon YYYY') as PERIOD_CHAR,
       trunc(max(m.daytime), 'MM') as PERIOD_DATE,
       sum(decode(x.object_id, null, 0, 1)) as INV_COUNT,
       m.code as STATUS,
       decode(max(m.code),'BOOKED','Y','N') as INC_BOOKED,
       'Inventory Validation Count for Inventory Area '''||max(m.ia_name)||'''' as DASH_HEADER,
       max(m.IA_CODE) as IA_CODE,
       m.ia_id as IA_ID
  from (select distinct m.daytime,
                        p.code,
                        p.sort_order,
                        p.is_default,
                        iav.name as IA_NAME,
                        ia.object_code as IA_CODE,
                        ia.object_id as IA_ID
          from system_mth_status        m,
               prosty_codes             p,
               inventory_area_version   iav,
               inventory_area           ia
         where p.code_type = 'DOCUMENT_LEVEL_CODE'
         and ec_ctrl_system_attribute.attribute_text(m.daytime,'INV_4EYE_VALIDATION','<=') = 'Y'
         and p.code in ('OPEN','VALID1','VALID2','TRANSFER','BOOKED')
         and ia.object_id = iav.object_id
        ) m
  left join inv_valuation x
    on (m.daytime = trunc(x.daytime, 'MM')
       and m.code = x.document_level_code
       and m.IA_ID = ec_inventory_version.inventory_area_id(x.object_id, x.daytime, '<='))
 group by m.code, m.daytime, m.ia_id
 order by period_date, ia_id, is_default desc, sort_order