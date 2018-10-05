CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_DASH_DOC_VAL_BP" ("OBJECT_ID", "DOCUMENT_KEY", "BOOKING_PERIOD", "FINANCIAL_CODE", "GROUP_VALUE", "BOOKING_VALUE", "CO_ID", "CO_NAME", "CONTRACT_AREA_ID", "CA_NAME", "BUSINESS_UNIT_ID", "BU_NAME", "BOOKING_CURRENCY_ID") AS 
  select
  x.object_id,
  x.document_key,
  ec_cont_document.booking_period(x.document_key) as booking_period,
  ec_contract_version.financial_code(x.object_id,x.daytime,'<=') as financial_code,
  x.group_value as group_value,
  x.booking_value as booking_value,
  ec_company.company_id(x.vendor_id) as CO_ID,
  ec_company_version.name(ec_company.company_id(x.vendor_id),x.daytime,'<=') as CO_NAME,
  ec_contract_version.contract_area_id(x.object_id,x.daytime,'<=') as contract_area_id,
  ec_contract_area_version.name(ec_contract_version.contract_area_id(x.object_id,x.daytime,'<='),x.daytime,'<=') as CA_NAME,
  ec_contract_area_version.business_unit_id(ec_contract_version.contract_area_id(x.object_id,x.daytime,'<='),x.daytime,'<=') as business_unit_id,
  ec_business_unit_version.name(ec_contract_area_version.business_unit_id(ec_contract_version.contract_area_id(x.object_id,x.daytime,'<='),x.daytime,'<='),x.daytime,'<=') as bu_name,
  ec_cont_document.booking_currency_id(x.document_key) as booking_currency_id
 from cont_li_dist_company x
 where ec_contract_version.financial_code(x.object_id,x.daytime,'<=') in ('SALE','TA_INCOME','JOU_ENT')
  and ec_cont_document.document_level_code(x.document_key) = 'BOOKED'
union all
 select
  x.object_id,
  x.document_key,
  ec_cont_document.booking_period(x.document_key) as booking_period,
  ec_contract_version.financial_code(x.object_id,x.daytime,'<=') as financial_code,
  -1*x.group_value as group_value,
  -1*x.booking_value as booking_value,
  ec_company.company_id(x.customer_id) as CO_ID,
  ec_company_version.name(ec_company.company_id(x.vendor_id),x.daytime,'<=') as CO_NAME,
  ec_contract_version.contract_area_id(x.object_id,x.daytime,'<=') as contract_area_id,
  ec_contract_area_version.name(ec_contract_version.contract_area_id(x.object_id,x.daytime,'<='),x.daytime,'<=') as CA_NAME,
  ec_contract_area_version.business_unit_id(ec_contract_version.contract_area_id(x.object_id,x.daytime,'<='),x.daytime,'<=') as business_unit_id,
  ec_business_unit_version.name(ec_contract_area_version.business_unit_id(ec_contract_version.contract_area_id(x.object_id,x.daytime,'<='),x.daytime,'<='),x.daytime,'<=') as bu_name,
  ec_cont_document.booking_currency_id(x.document_key) as booking_currency_id
 from cont_li_dist_company x
 where ec_contract_version.financial_code(x.object_id,x.daytime,'<=') in ('PURCHASE','TA_COST')
  and ec_cont_document.document_level_code(x.document_key) = 'BOOKED'