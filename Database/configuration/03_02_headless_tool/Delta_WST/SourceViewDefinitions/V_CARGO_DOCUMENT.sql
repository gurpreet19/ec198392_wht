CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CARGO_DOCUMENT" ("REPORT_NO", "FORMAT_CODE", "PARCEL_NO", "DOC_CODE", "RECEIVER", "ORIGINAL", "RUN_DATE", "UPLOAD", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_cargo_document.sql
-- View name: v_cargo_document
--
-- $Revision: 1.4 $
--
-- Purpose  :
--
-- Modification history:
--
-- Date       Whom      Change description:
-- ---------- ----      --------------------------------------------------------------------------------
-- 05.19.2007 OLN       Intial version
-- 28.09.2007 OLN       Added revision info fields
-- 22.10.2018 asareswi  ECPD-59461: Added upper clause on parameter_name column.
----------------------------------------------------------------------------------------------------
SELECT r.report_no,
			 r.format_code,
			 p.parameter_value PARCEL_NO,
			 ec_prosty_codes.code_text(a.rep_group_code, 'CARGO_DOCUMENT') DOC_CODE,
			 ecdp_objects.GetObjName(ec_report_param.parameter_value(r.report_no, 'RECEIVER_ID'), r.run_date)RECEIVER,
			 decode(nvl(ec_report_param.parameter_value(r.report_no, 'ORIGINAL'), 'N'), 'N', '', 'Y', 'Yes', ec_prosty_codes.code_text(ec_report_param.parameter_value(r.report_no, 'ORIGINAL'), 'CARGO_DOC_ORIGINAL')) ORIGINAL,
			 r.run_date,
       			 'N' as UPLOAD,
			 r.record_status AS RECORD_STATUS,
       r.created_by AS CREATED_BY,
       r.created_date AS CREATED_DATE,
       r.last_updated_by AS LAST_UPDATED_BY,
       r.last_updated_date AS LAST_UPDATED_DATE,
       r.rev_no AS REV_NO,
       r.rev_text AS REV_TEXT
FROM 	report r,
			report_param p,
			report_runable a
WHERE 			r.report_no = p.report_no
          		and upper(p.parameter_name) = 'PARCEL_NO'
          		and r.report_runable_no = a.report_runable_no
Union all
SELECT   		c.cargo_document_no REPORT_NO,
         		format as FORMAT_CODE,
         		CAST(c.parcel_no AS VARCHAR2(2000)),
        		c.doc_name DOC_CODE,
         		'UPLOAD' RECIEVER,
         		'' ORIGINAL,
         		c.daytime RUN_DATE,
            		'Y' as UPLOAD,
         		c.record_status AS RECORD_STATUS,
      			c.created_by AS CREATED_BY,
      			c.created_date AS CREATED_DATE,
      			c.last_updated_by AS LAST_UPDATED_BY,
      			c.last_updated_date AS LAST_UPDATED_DATE,
      			c.rev_no AS REV_NO,
      			c.rev_text AS REV_TEXT
FROM      		cargo_document c
)
ORDER BY 7