CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_DASH_INV_CNT_BU" ("SORT_ORDER", "IS_DEFAULT", "PERIOD_CHAR", "PERIOD_DATE", "INV_COUNT", "STATUS", "INC_BOOKED", "DASH_HEADER", "BU_CODE", "BU_ID") AS 
  select max(m.sort_order) as sort_order,
       max(m.is_default) as is_default,
       to_char(trunc(max(m.daytime), 'MM'), 'Mon YYYY') as PERIOD_CHAR,
       trunc(max(m.daytime), 'MM') as PERIOD_DATE,
       sum(decode(x.object_id, null, 0, 1)) as INV_COUNT,
       m.code as STATUS,
       decode(max(m.code),'BOOKED','Y','N') as INC_BOOKED,
       'Inventory Validation Count for Business Unit '''||max(m.bu_name)||'''' as DASH_HEADER,
       max(m.BU_CODE) as BU_CODE,
       m.bu_id as BU_ID
  from (select distinct m.daytime,
                        p.code,
                        p.sort_order,
                        p.is_default,
                        buv.name as BU_NAME,
                        bu.object_code as BU_CODE,
                        bu.object_id as BU_ID
          from system_mth_status     m,
               prosty_codes          p,
               business_unit_version buv,
               business_unit         bu
         where p.code_type = 'DOCUMENT_LEVEL_CODE'
         and bu.object_id = buv.object_id
         and ec_ctrl_system_attribute.attribute_text(m.daytime,'INV_4EYE_VALIDATION','<=') = 'N'
         and p.code in ('OPEN','VALID1','TRANSFER','BOOKED')
         ) m
  left join inv_valuation x
    on (m.daytime = trunc(x.daytime, 'MM')
       and m.code = x.document_level_code
       and m.BU_ID = ec_inventory_area_version.business_unit_id(ec_inventory_version.inventory_area_id(x.object_id, x.daytime,'<='),x.daytime,'<=')
       )
 group by m.code, m.daytime, m.bu_id
union all
select max(m.sort_order) as sort_order,
       max(m.is_default) as is_default,
       to_char(trunc(max(m.daytime), 'MM'), 'Mon YYYY') as PERIOD_CHAR,
       trunc(max(m.daytime), 'MM') as PERIOD_DATE,
       sum(decode(x.object_id, null, 0, 1)) as INV_COUNT,
       m.code as STATUS,
       decode(max(m.code),'BOOKED','Y','N') as INC_BOOKED,
       'Inventory Validation Count for Business Unit '''||max(m.bu_name)||'''' as DASH_HEADER,
       max(m.BU_CODE) as BU_CODE,
       m.bu_id as BU_ID
  from (select distinct m.daytime,
                        p.code,
                        p.sort_order,
                        p.is_default,
                        buv.name as BU_NAME,
                        bu.object_code as BU_CODE,
                        bu.object_id as BU_ID
          from system_mth_status     m,
               prosty_codes          p,
               business_unit_version buv,
               business_unit         bu
         where p.code_type = 'DOCUMENT_LEVEL_CODE'
         and bu.object_id = buv.object_id
         and ec_ctrl_system_attribute.attribute_text(m.daytime,'INV_4EYE_VALIDATION','<=') = 'Y'
         and p.code in ('OPEN','VALID1','VALID2','TRANSFER','BOOKED')
        ) m
  left join inv_valuation x
    on (m.daytime = trunc(x.daytime, 'MM')
       and m.code = x.document_level_code
       and m.BU_ID = ec_inventory_area_version.business_unit_id(ec_inventory_version.inventory_area_id(x.object_id, x.daytime,'<='),x.daytime,'<=')
       )
 group by m.code, m.daytime, m.bu_id
 order by period_date, is_default desc, sort_order