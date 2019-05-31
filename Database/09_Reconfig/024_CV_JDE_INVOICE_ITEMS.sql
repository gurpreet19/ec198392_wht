CREATE OR REPLACE VIEW "CV_JDE_INVOICE_ITEMS" ("INVOICE_TYPE", "CARGO_NO", "CARGO_HARBOUR_DUES_NO", "TRANSPORTER_ADDRESS", "SERVICE_DATE", "INVOICE_ADDRESS", "LINE_ITEM_CODE", "QTY", "UNIT", "INVOICE_AMOUNT", "CURRENCY_CODE", "LIFTING_NUMBER", "LIFTER_CARGO_NAME", "DESCRIPTION", "JDE_ACCOUNT_CODE", "LIFTER_ADDRESS", "JDE_BATCH_NO", "INVOICE_APPROVED", "SPLIT_PCT", "PARCEL_NO", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_STATE", "APPROVAL_BY", "APPROVAL_DATE", "REC_ID") AS 
  (SELECT 'EC-RPC' AS INVOICE_TYPE,
           dues.CARGO_NO,
           dues.CARGO_HARBOUR_DUES_NO,
           EC_COMPANY_VERSION.ADDRESS_8 (
              EC_CARGO_TRANSPORT.REF_OBJECT_ID_10 (dues.CARGO_NO),
              SYSDATE,
              '<=')
              AS TRANSPORTER_ADDRESS,
           NVL (
              UE_CT_LEADTIME.getLastTimesheetEntry (
                 dues.cargo_no,
                 'LNG_PILOT_AWAY',
                 ec_stor_version.product_id (nom.object_id, SYSDATE, '<=')),
              UE_CT_LEADTIME.getLastTimesheetEntry (
                 dues.cargo_no,
                 'COND_PILOT_AWAY',
                 ec_stor_version.product_id (nom.object_id, SYSDATE, '<=')))
              AS SERVICE_DATE,
           EC_COMPANY_VERSION.ADDRESS_8 (
              EC_COMPANY.OBJECT_ID_BY_UK ('WST_JVP', 'COMPANY'),
              SYSDATE,
              '<=')
              AS INVOICE_ADDRESS,
           dues.LINE_ITEM_COST,
           COALESCE(dues.QTY,dues.CALC_DURATION),
           DECODE(DUES.UNIT_UOM,'HRS','HR','EA') AS UNIT,
			DECODE(DUES.UNIT_UOM,'HRS',dues.LINE_ITEM_COST,(dues.LINE_ITEM_COST * dues.QTY))  * NVL(EC_STORAGE_LIFT_NOMINATION.VALUE_11(NOM.PARCEL_NO),100)/100 AS INVOICE_AMOUNT,
           EC_HARBOUR_DUES.TEXT_7 (dues.DUE_CODE,sysdate,'<=') AS CURRENCY_CODE,
           EC_CT_LIFTING_NUMBERS.lifting_number (
              NOM.PARCEL_NO)
              AS LIFTING_NUMBER,
           EC_STORAGE_LIFT_NOMINATION.TEXT_5(NOM.PARCEL_NO) AS LIFTER_CARGO_NAME,
	   EC_CARRIER_VERSION.NAME(NOM.CARRIER_ID, NOM.NOM_DATE , '<=') as DESCRIPTION,
           EC_HARBOUR_DUES.TEXT_8 (dues.DUE_CODE,sysdate,'<=') AS JDE_ACCOUNT_CODE,
           EC_COMPANY_VERSION.ADDRESS_8 (
              EC_LIFTING_ACCOUNT.COMPANY_ID (nom.lifting_account_id),
              SYSDATE,
              '<=')
              AS LIFTER_ADDRESS,
           dues.JDE_BATCH_NO,
           NVL (dues.INVOICE_APPROVED, 'N') AS INVOICE_APPROVED,
		   EC_STORAGE_LIFT_NOMINATION.VALUE_11(NOM.PARCEL_NO) AS SPLIT_PCT,
		   nom.PARCEL_NO,
           dues.RECORD_STATUS,
           dues.CREATED_BY,
           dues.CREATED_DATE,
           dues.LAST_UPDATED_BY,
           dues.LAST_UPDATED_DATE,
           dues.REV_NO,
           dues.REV_TEXT,
           dues.APPROVAL_STATE,
           dues.APPROVAL_BY,
           dues.APPROVAL_DATE,
           dues.REC_ID
      FROM DV_CARGO_HARBOUR_DUES dues
           INNER JOIN DV_STORAGE_LIFT_NOMINATION nom
              ON dues.cargo_no = nom.cargo_no
    UNION ALL
    SELECT 'EC-REBC' AS INVOICE_TYPE,
           dues.CARGO_NO,
           dues.CARGO_HARBOUR_DUES_NO,
           EC_COMPANY_VERSION.ADDRESS_8 (
              EC_CARGO_TRANSPORT.REF_OBJECT_ID_10 (dues.CARGO_NO),
              SYSDATE,
              '<=')
              AS TRANSPORTER_ADDRESS,
           NVL (
              UE_CT_LEADTIME.getLastTimesheetEntry (
                 dues.cargo_no,
                 'LNG_PILOT_AWAY',
                 ec_stor_version.product_id (nom.object_id, SYSDATE, '<=')),
              UE_CT_LEADTIME.getLastTimesheetEntry (
                 dues.cargo_no,
                 'COND_PILOT_AWAY',
                 ec_stor_version.product_id (nom.object_id, SYSDATE, '<=')))
              AS SERVICE_DATE,
           EC_COMPANY_VERSION.ADDRESS_8 (
              EC_COMPANY.OBJECT_ID_BY_UK ('WST_JVP', 'COMPANY'),
              SYSDATE,
              '<=')
              AS INVOICE_ADDRESS,
           dues.DEMURRAGE_RATE / 24 AS LINE_ITEM_CODE, -- Converting daily rate to hourly rate
           dues.DEMURRAGE * 24 AS QTY, -- Converting day duration to hour duration
           'HR' AS UNIT,
           dues.CALCULATED_CLAIM AS INVOICE_AMOUNT,
           dues.CURRENCY_UNIT AS CURRENCY_CODE,
           EC_CT_LIFTING_NUMBERS.lifting_number (
              nom.PARCEL_NO)
              AS LIFTING_NUMBER,
           EC_STORAGE_LIFT_NOMINATION.TEXT_5(NOM.PARCEL_NO) AS LIFTER_CARGO_NAME,
           EC_CARRIER_VERSION.NAME(NOM.CARRIER_ID, NOM.NOM_DATE , '<=') as DESCRIPTION,
           UE_CT_DEMURRAGE.GetJDEAccountCode (dues.cargo_no,
                                              dues.demurrage_type,
                                              dues.lifting_event)
              AS JDE_ACCOUNT_CODE,
           EC_COMPANY_VERSION.ADDRESS_8 (
              EC_LIFTING_ACCOUNT.COMPANY_ID (nom.lifting_account_id),
              SYSDATE,
              '<=')
              AS LIFTER_ADDRESS,
           dues.JDE_BATCH_NO,
           DECODE (dues.STATUS, 'ACCEPTED', 'Y', 'N') AS INVOICE_APPROVED,
		   EC_STORAGE_LIFT_NOMINATION.VALUE_11(NOM.PARCEL_NO) AS SPLIT_PCT,
		   NOM.PARCEL_NO,
           dues.RECORD_STATUS,
           dues.CREATED_BY,
           dues.CREATED_DATE,
           dues.LAST_UPDATED_BY,
           dues.LAST_UPDATED_DATE,
           dues.REV_NO,
           dues.REV_TEXT,
           dues.APPROVAL_STATE,
           dues.APPROVAL_BY,
           dues.APPROVAL_DATE,
           dues.REC_ID
      FROM DV_DEMURRAGE dues
           INNER JOIN DV_STORAGE_LIFT_NOMINATION nom
              ON dues.cargo_no = nom.cargo_no
     WHERE dues.demurrage_type IN ('COND_EBO', 'EBO'));
/