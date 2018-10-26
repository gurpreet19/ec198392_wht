CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_PRICE_CNTR_ATTRIBUTE" ("OBJECT_ID", "ATTRIBUTE_NAME", "DAYTIME", "ATTRIBUTE_STRING", "ATTRIBUTE_NUMBER", "ATTRIBUTE_DATE", "TIME_SPAN", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_BY", "APPROVAL_DATE", "APPROVAL_STATE", "REC_ID") AS 
  SELECT p.object_id,
       ca.attribute_name,
       ca.daytime,
       ca.attribute_string,
       ca.attribute_number,
       ca.attribute_date,
       a.time_span,
       ca.record_status,
       ca.created_by,
       ca.created_date,
       ca.last_updated_by,
       ca.last_updated_date,
       ca.rev_no,
       ca.rev_text,
       ca.approval_by,
       ca.approval_date,
       ca.approval_state,
       ca.rec_id
FROM   contract_attribute ca,cntr_template_attribute a, contract c, product_price p
WHERE c.object_id = ca.object_id
      AND ca.object_id = p.contract_id
      AND ca.attribute_name = a.attribute_name
      AND ca.daytime >= trunc(add_months(c.start_date,c.start_year),'YEAR')
      AND ca.daytime < nvl(c.end_date, ca.daytime+1)
	  AND ca.daytime < nvl(p.end_date, ca.daytime+1)
      AND a.template_code = c.template_code
      AND a.time_span = 'YR' AND a.attribute_type <> 'USER_EXIT'
UNION ALL
-- monthly attributes, no user exits
SELECT p.object_id,
       ca.attribute_name,
       ca.daytime,
       ca.attribute_string,
       ca.attribute_number,
       ca.attribute_date,
       a.time_span,
       ca.record_status,
       ca.created_by,
       ca.created_date,
       ca.last_updated_by,
       ca.last_updated_date,
       ca.rev_no,
       ca.rev_text,
       ca.approval_by,
       ca.approval_date,
       ca.approval_state,
       ca.rec_id
FROM   contract_attribute ca,cntr_template_attribute a, contract c, product_price p
WHERE c.object_id = ca.object_id
      AND ca.object_id = p.contract_id
      AND ca.attribute_name = a.attribute_name
      AND ca.daytime >= TRUNC(c.start_date,'MONTH')
      AND ca.daytime < nvl(c.end_date, ca.daytime+1)
	  AND ca.daytime < nvl(p.end_date, ca.daytime+1)
      AND a.template_code = c.template_code
      AND a.time_span = 'MTH' AND a.attribute_type <> 'USER_EXIT'
UNION ALL
-- daily attributes, no user exits
SELECT p.object_id,
       ca.attribute_name,
       ca.daytime,
       ca.attribute_string,
       ca.attribute_number,
       ca.attribute_date,
       a.time_span,
       ca.record_status,
       ca.created_by,
       ca.created_date,
       ca.last_updated_by,
       ca.last_updated_date,
       ca.rev_no,
       ca.rev_text,
       ca.approval_by,
       ca.approval_date,
       ca.approval_state,
       ca.rec_id
FROM   contract_attribute ca,cntr_template_attribute a, contract c, product_price p
WHERE c.object_id = ca.object_id
      AND ca.object_id = p.contract_id
      AND ca.attribute_name = a.attribute_name
      AND ca.daytime >= c.start_date
      AND ca.daytime < nvl(c.end_date, ca.daytime+1)
	  AND ca.daytime < nvl(p.end_date, ca.daytime+1)
      AND a.template_code = c.template_code
      AND Nvl(a.time_span,'DAY') = 'DAY' AND a.attribute_type <> 'USER_EXIT'
UNION ALL
-- year attributes, user exits
SELECT p.object_id,
     a.attribute_name,
       d.daytime,
     ecdp_contract_attribute.getAttributeString(c.object_id, a.attribute_name, d.daytime, 'Y') attribute_string,
     ecdp_contract_attribute.getAttributeNumber(c.object_id, a.attribute_name, d.daytime, 'Y') attribute_number,
     ecdp_contract_attribute.getAttributeDate(c.object_id, a.attribute_name, d.daytime, 'Y') attribute_date,
       a.time_span,
     a.record_status,
     a.created_by,
     a.created_date,
     a.last_updated_by,
     a.last_updated_date,
     a.rev_no,
     a.rev_text,
     a.approval_by,
     a.approval_date,
     a.approval_state,
     a.rec_id
FROM system_days d, cntr_template_attribute a, contract c, product_price p
WHERE d.daytime >= trunc(add_months(c.start_date,c.start_year),'YEAR')
      AND d.daytime < nvl(c.end_date, d.daytime+1)
	  AND d.daytime < nvl(p.end_date, d.daytime+1)
      AND TO_CHAR(d.daytime,'DDMM') = TO_CHAR(TRUNC(add_months(d.daytime,c.start_year),'YEAR'),'DDMM')
      AND a.template_code = c.template_code
      AND a.time_span = 'YR'
      AND a.attribute_type = 'USER_EXIT'
      AND c.object_id = p.contract_id
UNION ALL
-- month attributes, user exits
SELECT p.object_id,
     a.attribute_name,
     d.daytime,
     ecdp_contract_attribute.getAttributeString(c.object_id, a.attribute_name, d.daytime, 'Y') attribute_string,
     ecdp_contract_attribute.getAttributeNumber(c.object_id, a.attribute_name, d.daytime, 'Y') attribute_number,
     ecdp_contract_attribute.getAttributeDate(c.object_id, a.attribute_name, d.daytime, 'Y') attribute_date,
       a.time_span,
     a.record_status,
     a.created_by,
     a.created_date,
     a.last_updated_by,
     a.last_updated_date,
     a.rev_no,
     a.rev_text,
     a.approval_by,
     a.approval_date,
     a.approval_state,
     a.rec_id
FROM system_days d, cntr_template_attribute a, contract c, product_price p
WHERE d.daytime >= TRUNC(c.start_date,'MONTH')
      AND TO_CHAR(d.daytime,'DD') = '01'
      AND d.daytime < nvl(c.end_date, d.daytime+1)
	  AND d.daytime < nvl(p.end_date, d.daytime+1)
      AND a.template_code = c.template_code
      AND a.time_span = 'MTH'
      AND a.attribute_type = 'USER_EXIT'
      AND c.object_id = p.contract_id
UNION ALL
-- day attributes, user exits
SELECT p.object_id,
     a.attribute_name,
     d.daytime,
     ecdp_contract_attribute.getAttributeString(c.object_id, a.attribute_name, d.daytime, 'Y') attribute_string,
     ecdp_contract_attribute.getAttributeNumber(c.object_id, a.attribute_name, d.daytime, 'Y') attribute_number,
     ecdp_contract_attribute.getAttributeDate(c.object_id, a.attribute_name, d.daytime, 'Y') attribute_date,
       a.time_span,
     a.record_status,
     a.created_by,
     a.created_date,
     a.last_updated_by,
     a.last_updated_date,
     a.rev_no,
     a.rev_text,
     a.approval_by,
     a.approval_date,
     a.approval_state,
     a.rec_id
FROM system_days d, cntr_template_attribute a, contract c, product_price p
WHERE d.daytime >= c.start_date
      AND d.daytime < nvl(c.end_date, d.daytime+1)
	  AND d.daytime < nvl(p.end_date, d.daytime+1)
      AND a.template_code = c.template_code
      AND Nvl(a.time_span,'DAY') = 'DAY'
      AND a.attribute_type = 'USER_EXIT'
      AND c.object_id = p.contract_id