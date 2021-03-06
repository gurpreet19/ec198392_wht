CREATE OR REPLACE PACKAGE BODY UE_CT_COND_INV_CP IS
/******************************************************************************
** Package        :  UE_CT_COND_INV_CP, head part
**
** $Revision: 1.0 $
**
** Purpose        : To push the Daily production inventory from UPG allocation to a temp table. the data will be then used in Condensate Inventory Report
**
** Created      :
**
** Modification history:
**
** Date          Whom        Change description:
** ------        -----       -----------------------------------------------------------------------------------------------
** 20 AUG 2015  tlxt       Initial version.
**							This package will first purge off the historical date before it generate new entries
**							Get the last available Prod Actuals Closing from the Daily contract Result (with the Account Code = "COND_IN").
**							Use it to build the opening for the next day in Forecast
**							calculate the Prod focast from the Production profile using SDS Medium Conf
**							calculate the nomination using the ETD from the Nomination
**							build the Forecast date range set from the next day when we have the Prod actuals until next available TBD cargo.
** 19 NOV 2019  kolleadr    Chevron Bulk Upgrade: Added PRAGMA AUTONOMOUS_TRANSACTION;
********************************************************************************************************************************/

PROCEDURE CALCINVENTORY(p_date DATE)
IS
	PRAGMA AUTONOMOUS_TRANSACTION;

	--UPDATE OPENING AND CLOSING
	CURSOR UPD_CLOSING(c_daytime DATE) IS
	SELECT DAYTIME
	FROM CT_COND_INV
	WHERE DAYTIME > c_daytime
	GROUP BY DAYTIME
	ORDER BY DAYTIME;

    --GET LAST AVAILABLE ACTUAL
    CURSOR LAST_ACTUAL(c_daytime DATE) IS
    SELECT DAYTIME, (VOL_QTY)AS ACT_CLOSING, TRIM(SUBSTR(OBJECT_CODE,13,10))AS COMPANY_CODE
    FROM DV_SCTR_ACC_DAY_STATUS
    WHERE OBJECT_CODE IN (SELECT DISTINCT(CODE) FROM OV_CONTRACT WHERE CONTRACT_AREA_CODE = 'CA_ALLOC_JVP') AND ACCOUNT_CODE = 'IN_COND'
    AND DAYTIME = NVL(c_daytime,(SELECT MAX(DAYTIME)FROM DV_SCTR_ACC_DAY_STATUS
    WHERE OBJECT_CODE IN (SELECT DISTINCT(CODE) FROM OV_CONTRACT WHERE CONTRACT_AREA_CODE = 'CA_ALLOC_JVP') AND ACCOUNT_CODE = 'IN_COND' ));



    --GET TBD DATE (PASSING IN ACTUAL'S DATE)
    CURSOR GET_TBD(c_daytime DATE) IS
    SELECT MAX(TRUNC(ETD)) TBD_DATE
    FROM DV_STORAGE_LIFT_NOMINATION
    WHERE TRUNC(ETD) > c_daytime
    AND OBJECT_CODE = 'STW_COND'
    AND LIFTING_ACCOUNT_CODE LIKE '%TBD%';

    --GET FCST LIFTING
    CURSOR GET_LIFTING(c_daytime DATE, c_tbd_date DATE) IS
	SELECT TRUNC(ETD) AS ETD,LIFTING_ACCOUNT_CODE,
	ECDP_UNIT.CONVERTVALUE(SUM(NOM_GRS_VOL) , 'SM3', 'BBLS') AS OUTGOING
    FROM DV_STORAGE_LIFT_NOMINATION
    WHERE TRUNC(ETD) > c_daytime AND TRUNC(ETD) < c_tbd_date
    AND OBJECT_CODE = 'STW_COND'
	GROUP BY ETD,LIFTING_ACCOUNT_CODE
	ORDER BY ETD;

    --GET FCST PROD BY LIFTER BASED ON EQUITY SHARE
    --PROVIDED DATE RANGE FROM ACTUAL+1 AND TBD-1
    --IF NO TBD FOUND, THEN GET UNTIL LAST DATE
    --SDS SCENARIO
    --SDS_MC_BASED
    CURSOR GET_PROD_FCST(c_daytime DATE, c_tbd_date DATE) IS
	  SELECT DAYTIME,
			 ROUND(ECDP_UNIT.CONVERTVALUE(SUM (TAPL_SHARE) , 'SM3', 'BBLS'),2) AS TAPL,
			 ROUND(ECDP_UNIT.CONVERTVALUE(SUM (CAPL_SHARE) , 'SM3', 'BBLS'),2) AS CAPL,
			 ROUND(ECDP_UNIT.CONVERTVALUE(SUM (PEW_SHARE) , 'SM3', 'BBLS'),2) AS PEW,
			 ROUND(ECDP_UNIT.CONVERTVALUE(SUM (KWI_SHARE) , 'SM3', 'BBLS'),2) AS KWI,
			 ROUND(ECDP_UNIT.CONVERTVALUE(SUM (QE_SHARE) , 'SM3', 'BBLS'),2) AS QE,
			 ROUND(ECDP_UNIT.CONVERTVALUE(SUM (KJB_SHARE) , 'SM3', 'BBLS'),2) AS KJB,
			 ROUND(ECDP_UNIT.CONVERTVALUE(SUM (WEJ_SHARE) , 'SM3', 'BBLS'),2) AS WEJ,
			 ROUND(ECDP_UNIT.CONVERTVALUE(SUM (TOTAL_UPG) , 'SM3', 'BBLS'),2) AS TOTAL_ALL
		FROM (SELECT DAYTIME,
					   TOTAL_UPG
					 / 100
					 * EC_EQUITY_SHARE.ECO_SHARE (
						  ECDP_OBJECTS.GETOBJIDFROMCODE ('COMMERCIAL_ENTITY',
														 'CE_WST_IAG_UUOA'),
						  ECDP_OBJECTS.GETOBJIDFROMCODE ('COMPANY', 'TAPL'),
						  'CONDENSATE',
						  DAYTIME,
						  '<=')
						AS TAPL_SHARE,
					   TOTAL_UPG
					 / 100
					 * EC_EQUITY_SHARE.ECO_SHARE (
						  ECDP_OBJECTS.GETOBJIDFROMCODE ('COMMERCIAL_ENTITY',
														 'CE_WST_IAG_UUOA'),
						  ECDP_OBJECTS.GETOBJIDFROMCODE ('COMPANY', 'CAPL'),
						  'CONDENSATE',
						  DAYTIME,
						  '<=')
						AS CAPL_SHARE,
					   TOTAL_UPG
					 / 100
					 * EC_EQUITY_SHARE.ECO_SHARE (
						  ECDP_OBJECTS.GETOBJIDFROMCODE ('COMMERCIAL_ENTITY',
														 'CE_WST_IAG_UUOA'),
						  ECDP_OBJECTS.GETOBJIDFROMCODE ('COMPANY', 'PEW'),
						  'CONDENSATE',
						  DAYTIME,
						  '<=')
						AS PEW_SHARE,
					   TOTAL_UPG
					 / 100
					 * EC_EQUITY_SHARE.ECO_SHARE (
						  ECDP_OBJECTS.GETOBJIDFROMCODE ('COMMERCIAL_ENTITY',
														 'CE_WST_IAG_UUOA'),
						  ECDP_OBJECTS.GETOBJIDFROMCODE ('COMPANY', 'KWI'),
						  'CONDENSATE',
						  DAYTIME,
						  '<=')
						AS KWI_SHARE,
					   TOTAL_UPG
					 / 100
					 * EC_EQUITY_SHARE.ECO_SHARE (
						  ECDP_OBJECTS.GETOBJIDFROMCODE ('COMMERCIAL_ENTITY',
														 'CE_WST_IAG_UUOA'),
						  ECDP_OBJECTS.GETOBJIDFROMCODE ('COMPANY', 'QE'),
						  'CONDENSATE',
						  DAYTIME,
						  '<=')
						AS QE_SHARE,
					 0 AS KJB_SHARE,
					 0 AS WEJ_SHARE,
					 TOTAL_UPG
				FROM (  SELECT DAYTIME,
							   PROFIT_CENTRE_CODE,
							   SUM (COND_VOL_RATE) AS TOTAL_UPG
						  FROM DV_CT_PROD_STRM_PC_FORECAST
						 WHERE     OBJECT_CODE LIKE '%COND%'
							   AND FORECAST_OBJECT_CODE = 'SDS_MC_BASED'
								AND DAYTIME >= (c_daytime +1)
								AND DAYTIME < c_tbd_date
							   AND PROFIT_CENTRE_CODE = 'F_WST_IAGO'
					  GROUP BY DAYTIME, PROFIT_CENTRE_CODE)
			  UNION ALL
			  SELECT DAYTIME,
					 0 AS TAPL_SHARE,
					 0 AS CAPL_SHARE,
					 0 AS PEW_SHARE,
					 0 AS KWI_SHARE,
					 0 AS QE_SHARE,
					   TOTAL_UPG
					 / 100
					 * EC_EQUITY_SHARE.ECO_SHARE (
						  ECDP_OBJECTS.GETOBJIDFROMCODE ('COMMERCIAL_ENTITY',
														 'CE_JUL_BRU_UUOA'),
						  ECDP_OBJECTS.GETOBJIDFROMCODE ('COMPANY', 'KJB'),
						  'CONDENSATE',
						  DAYTIME,
						  '<=')
						AS KJB_SHARE,
					   TOTAL_UPG
					 / 100
					 * EC_EQUITY_SHARE.ECO_SHARE (
						  ECDP_OBJECTS.GETOBJIDFROMCODE ('COMMERCIAL_ENTITY',
														 'CE_JUL_BRU_UUOA'),
						  ECDP_OBJECTS.GETOBJIDFROMCODE ('COMPANY', 'WEJ'),
						  'CONDENSATE',
						  DAYTIME,
						  '<=')
						AS WEJ_SHARE,
					 TOTAL_UPG
				FROM (  SELECT DAYTIME,
							   PROFIT_CENTRE_CODE,
							   SUM (COND_VOL_RATE) AS TOTAL_UPG
						  FROM DV_CT_PROD_STRM_PC_FORECAST
						 WHERE     OBJECT_CODE LIKE '%COND%'
							   AND FORECAST_OBJECT_CODE = 'SDS_MC_BASED'
								AND DAYTIME >= (c_daytime +1)
								AND DAYTIME < c_tbd_date
							   AND PROFIT_CENTRE_CODE = 'F_JUL_BRU'
					  GROUP BY DAYTIME, PROFIT_CENTRE_CODE))
	GROUP BY DAYTIME
	ORDER BY DAYTIME;

    ld_PA_date  DATE;
    ld_Actual_date DATE;
    ld_TBD_date DATE;
	ln_actual_closing NUMBER;
	lv_Storage_id VARCHAR2(32) := ECDP_OBJECTS.GETOBJIDFROMCODE('STORAGE','STW_COND');
	ln_temp_closing NUMBER;


BEGIN

    ld_PA_date:= p_date;
	ld_Actual_date := '01-JAN-2011';
	ln_actual_closing := 0;

    DELETE FROM T_TEMPTEXT WHERE ID = 'COND_INV';
    COMMIT;

	DELETE FROM CT_COND_INV;
    COMMIT;


    --GET LAST_ACTUAL FROM INVENTORY ACCOUNTING FROM PA
    FOR C_GET_LAST_ACTUAL IN LAST_ACTUAL(NULL) LOOP
        ld_Actual_date:= C_GET_LAST_ACTUAL.DAYTIME;
		ln_actual_closing := C_GET_LAST_ACTUAL.ACT_CLOSING;
		CASE C_GET_LAST_ACTUAL.COMPANY_CODE
			WHEN  'TAPL' THEN
				INSERT INTO CT_COND_INV(OBJECT_ID, LIFTING_ACCOUNT_ID, DAYTIME, CLASS_NAME, CLOSING )
				VALUES(lv_Storage_id,ECDP_OBJECTS.GETOBJIDFROMCODE('LIFTING_ACCOUNT','LA_TAPL_COND'),C_GET_LAST_ACTUAL.DAYTIME,'CT_COND_INV',C_GET_LAST_ACTUAL.ACT_CLOSING);
			WHEN  'CAPL' THEN
				INSERT INTO CT_COND_INV(OBJECT_ID, LIFTING_ACCOUNT_ID, DAYTIME, CLASS_NAME, CLOSING )
				VALUES(lv_Storage_id,ECDP_OBJECTS.GETOBJIDFROMCODE('LIFTING_ACCOUNT','LA_CAPL_COND'),C_GET_LAST_ACTUAL.DAYTIME,'CT_COND_INV',C_GET_LAST_ACTUAL.ACT_CLOSING);
			WHEN  'PEW' THEN
				INSERT INTO CT_COND_INV(OBJECT_ID, LIFTING_ACCOUNT_ID, DAYTIME, CLASS_NAME, CLOSING )
				VALUES(lv_Storage_id,ECDP_OBJECTS.GETOBJIDFROMCODE('LIFTING_ACCOUNT','LA_PEW_COND'),C_GET_LAST_ACTUAL.DAYTIME,'CT_COND_INV',C_GET_LAST_ACTUAL.ACT_CLOSING);
			WHEN  'KWI' THEN
				INSERT INTO CT_COND_INV(OBJECT_ID, LIFTING_ACCOUNT_ID, DAYTIME, CLASS_NAME, CLOSING )
				VALUES(lv_Storage_id,ECDP_OBJECTS.GETOBJIDFROMCODE('LIFTING_ACCOUNT','LA_KWI_COND'),C_GET_LAST_ACTUAL.DAYTIME,'CT_COND_INV',C_GET_LAST_ACTUAL.ACT_CLOSING);
			WHEN  'QE' THEN
				INSERT INTO CT_COND_INV(OBJECT_ID, LIFTING_ACCOUNT_ID, DAYTIME, CLASS_NAME, CLOSING )
				VALUES(lv_Storage_id,ECDP_OBJECTS.GETOBJIDFROMCODE('LIFTING_ACCOUNT','LA_QE_COND'),C_GET_LAST_ACTUAL.DAYTIME,'CT_COND_INV',C_GET_LAST_ACTUAL.ACT_CLOSING);
			WHEN  'WEJ' THEN
				INSERT INTO CT_COND_INV(OBJECT_ID, LIFTING_ACCOUNT_ID, DAYTIME, CLASS_NAME, CLOSING )
				VALUES(lv_Storage_id,ECDP_OBJECTS.GETOBJIDFROMCODE('LIFTING_ACCOUNT','LA_WEJ_COND'),C_GET_LAST_ACTUAL.DAYTIME,'CT_COND_INV',C_GET_LAST_ACTUAL.ACT_CLOSING);
			WHEN  'KJB' THEN
				INSERT INTO CT_COND_INV(OBJECT_ID, LIFTING_ACCOUNT_ID, DAYTIME, CLASS_NAME, CLOSING )
				VALUES(lv_Storage_id,ECDP_OBJECTS.GETOBJIDFROMCODE('LIFTING_ACCOUNT','LA_KJB_COND'),C_GET_LAST_ACTUAL.DAYTIME,'CT_COND_INV',C_GET_LAST_ACTUAL.ACT_CLOSING);
			ELSE
			    ECDP_DYNSQL.WRITETEMPTEXT('COND_INV','DAYTIME='       ||C_GET_LAST_ACTUAL.DAYTIME);
				ECDP_DYNSQL.WRITETEMPTEXT('COND_INV','ACT_CLOSING='   ||C_GET_LAST_ACTUAL.ACT_CLOSING);
		END CASE;
    END LOOP;
	COMMIT;

    --GET TBD DATE (PASSING IN ACTUAL'S DATE)
    FOR C_GET_TBD_DATE IN GET_TBD(ld_Actual_date) LOOP
        ld_TBD_date := C_GET_TBD_DATE.TBD_DATE;
    END LOOP;
    COMMIT;

	IF ld_TBD_date IS NULL THEN
		ld_TBD_date := '31-DEC-2099';
	END IF;

    --GET FCST PROD
	ECDP_DYNSQL.WRITETEMPTEXT('COND_INV','ld_Actual_date='||ld_Actual_date || ' ld_TBD_date='||ld_TBD_date);
    FOR C_GET_FCST_PROD IN GET_PROD_FCST(ld_Actual_date, ld_TBD_date) LOOP

		INSERT INTO CT_COND_INV(OBJECT_ID, LIFTING_ACCOUNT_ID, DAYTIME, CLASS_NAME, INCOMING )
		VALUES(lv_Storage_id,ECDP_OBJECTS.GETOBJIDFROMCODE('LIFTING_ACCOUNT','LA_WEJ_COND'),C_GET_FCST_PROD.DAYTIME,'CT_COND_INV',C_GET_FCST_PROD.WEJ);

		INSERT INTO CT_COND_INV(OBJECT_ID, LIFTING_ACCOUNT_ID, DAYTIME, CLASS_NAME, INCOMING )
		VALUES(lv_Storage_id,ECDP_OBJECTS.GETOBJIDFROMCODE('LIFTING_ACCOUNT','LA_KJB_COND'),C_GET_FCST_PROD.DAYTIME,'CT_COND_INV',C_GET_FCST_PROD.KJB);

		INSERT INTO CT_COND_INV(OBJECT_ID, LIFTING_ACCOUNT_ID, DAYTIME, CLASS_NAME, INCOMING )
		VALUES(lv_Storage_id,ECDP_OBJECTS.GETOBJIDFROMCODE('LIFTING_ACCOUNT','LA_QE_COND'),C_GET_FCST_PROD.DAYTIME,'CT_COND_INV',C_GET_FCST_PROD.QE);

		INSERT INTO CT_COND_INV(OBJECT_ID, LIFTING_ACCOUNT_ID, DAYTIME, CLASS_NAME, INCOMING )
		VALUES(lv_Storage_id,ECDP_OBJECTS.GETOBJIDFROMCODE('LIFTING_ACCOUNT','LA_KWI_COND'),C_GET_FCST_PROD.DAYTIME,'CT_COND_INV',C_GET_FCST_PROD.KWI);

		INSERT INTO CT_COND_INV(OBJECT_ID, LIFTING_ACCOUNT_ID, DAYTIME, CLASS_NAME, INCOMING )
		VALUES(lv_Storage_id,ECDP_OBJECTS.GETOBJIDFROMCODE('LIFTING_ACCOUNT','LA_PEW_COND'),C_GET_FCST_PROD.DAYTIME,'CT_COND_INV',C_GET_FCST_PROD.PEW);

		INSERT INTO CT_COND_INV(OBJECT_ID, LIFTING_ACCOUNT_ID, DAYTIME, CLASS_NAME, INCOMING )
		VALUES(lv_Storage_id,ECDP_OBJECTS.GETOBJIDFROMCODE('LIFTING_ACCOUNT','LA_CAPL_COND'),C_GET_FCST_PROD.DAYTIME,'CT_COND_INV',C_GET_FCST_PROD.CAPL);

		INSERT INTO CT_COND_INV(OBJECT_ID, LIFTING_ACCOUNT_ID, DAYTIME, CLASS_NAME, INCOMING )
		VALUES(lv_Storage_id,ECDP_OBJECTS.GETOBJIDFROMCODE('LIFTING_ACCOUNT','LA_TAPL_COND'),C_GET_FCST_PROD.DAYTIME,'CT_COND_INV',C_GET_FCST_PROD.TAPL);

		END LOOP;
    COMMIT;

    --GET FCST LIFTING
    FOR C_GET_FCST_LIFT IN GET_LIFTING(ld_Actual_date, ld_TBD_date) LOOP
        ECDP_DYNSQL.WRITETEMPTEXT('COND_INV','ETD(FCST_LIFT)='       ||C_GET_FCST_LIFT.ETD);
        ECDP_DYNSQL.WRITETEMPTEXT('COND_INV','OUTGOING(FCST_LIFT)='         ||C_GET_FCST_LIFT.OUTGOING);
		CASE C_GET_FCST_LIFT.LIFTING_ACCOUNT_CODE
			WHEN  'LA_TAPL_COND' THEN
				UPDATE CT_COND_INV SET OUTGOING = C_GET_FCST_LIFT.OUTGOING
				WHERE OBJECT_ID = lv_Storage_id
				AND LIFTING_ACCOUNT_ID = ECDP_OBJECTS.GETOBJIDFROMCODE('LIFTING_ACCOUNT','LA_TAPL_COND')
				AND DAYTIME = C_GET_FCST_LIFT.ETD
				AND CLASS_NAME = 'CT_COND_INV';
			WHEN  'LA_CAPL_COND' THEN
				UPDATE CT_COND_INV SET OUTGOING = C_GET_FCST_LIFT.OUTGOING
				WHERE OBJECT_ID = lv_Storage_id
				AND LIFTING_ACCOUNT_ID = ECDP_OBJECTS.GETOBJIDFROMCODE('LIFTING_ACCOUNT','LA_CAPL_COND')
				AND DAYTIME = C_GET_FCST_LIFT.ETD
				AND CLASS_NAME = 'CT_COND_INV';
			WHEN  'LA_KWI_COND' THEN
				UPDATE CT_COND_INV SET OUTGOING = C_GET_FCST_LIFT.OUTGOING
				WHERE OBJECT_ID = lv_Storage_id
				AND LIFTING_ACCOUNT_ID = ECDP_OBJECTS.GETOBJIDFROMCODE('LIFTING_ACCOUNT','LA_KWI_COND')
				AND DAYTIME = C_GET_FCST_LIFT.ETD
				AND CLASS_NAME = 'CT_COND_INV';
			WHEN  'LA_PEW_COND' THEN
				UPDATE CT_COND_INV SET OUTGOING = C_GET_FCST_LIFT.OUTGOING
				WHERE OBJECT_ID = lv_Storage_id
				AND LIFTING_ACCOUNT_ID = ECDP_OBJECTS.GETOBJIDFROMCODE('LIFTING_ACCOUNT','LA_PEW_COND')
				AND DAYTIME = C_GET_FCST_LIFT.ETD
				AND CLASS_NAME = 'CT_COND_INV';
			WHEN  'LA_QE_COND' THEN
				UPDATE CT_COND_INV SET OUTGOING = C_GET_FCST_LIFT.OUTGOING
				WHERE OBJECT_ID = lv_Storage_id
				AND LIFTING_ACCOUNT_ID = ECDP_OBJECTS.GETOBJIDFROMCODE('LIFTING_ACCOUNT','LA_QE_COND')
				AND DAYTIME = C_GET_FCST_LIFT.ETD
				AND CLASS_NAME = 'CT_COND_INV';
			WHEN  'LA_KJB_COND' THEN
				UPDATE CT_COND_INV SET OUTGOING = C_GET_FCST_LIFT.OUTGOING
				WHERE OBJECT_ID = lv_Storage_id
				AND LIFTING_ACCOUNT_ID = ECDP_OBJECTS.GETOBJIDFROMCODE('LIFTING_ACCOUNT','LA_KJB_COND')
				AND DAYTIME = C_GET_FCST_LIFT.ETD
				AND CLASS_NAME = 'CT_COND_INV';
			WHEN  'LA_WEJ_COND' THEN
				UPDATE CT_COND_INV SET OUTGOING = C_GET_FCST_LIFT.OUTGOING
				WHERE OBJECT_ID = lv_Storage_id
				AND LIFTING_ACCOUNT_ID = ECDP_OBJECTS.GETOBJIDFROMCODE('LIFTING_ACCOUNT','LA_WEJ_COND')
				AND DAYTIME = C_GET_FCST_LIFT.ETD
				AND CLASS_NAME = 'CT_COND_INV';
			ELSE
				ECDP_DYNSQL.WRITETEMPTEXT('COND_INV','ETD(FCST_LIFT)='       ||C_GET_FCST_LIFT.ETD);
		END CASE;

    END LOOP;
    COMMIT;
    FOR C_UPDATE_CLOSING IN UPD_CLOSING(ld_Actual_date) LOOP
		ln_temp_closing := EC_CT_COND_INV.CLOSING(ECDP_OBJECTS.GETOBJIDFROMCODE('STORAGE','STW_COND'), C_UPDATE_CLOSING.DAYTIME-1, 'CT_COND_INV' , ECDP_OBJECTS.GETOBJIDFROMCODE('LIFTING_ACCOUNT','LA_TAPL_COND') , '=');
		UPDATE CT_COND_INV
		SET OPENING = NVL(ln_temp_closing,0),
		CLOSING = NVL(ln_temp_closing,0) + NVL(INCOMING,0) - NVL(OUTGOING,0)
		WHERE DAYTIME = C_UPDATE_CLOSING.DAYTIME
		AND LIFTING_ACCOUNT_ID = ECDP_OBJECTS.GETOBJIDFROMCODE('LIFTING_ACCOUNT','LA_TAPL_COND');
		COMMIT;

		ln_temp_closing := EC_CT_COND_INV.CLOSING(ECDP_OBJECTS.GETOBJIDFROMCODE('STORAGE','STW_COND'), C_UPDATE_CLOSING.DAYTIME-1, 'CT_COND_INV' , ECDP_OBJECTS.GETOBJIDFROMCODE('LIFTING_ACCOUNT','LA_CAPL_COND') , '=');
		UPDATE CT_COND_INV
		SET OPENING = NVL(ln_temp_closing,0),
		CLOSING = NVL(ln_temp_closing,0) + NVL(INCOMING,0) - NVL(OUTGOING,0)
		WHERE DAYTIME = C_UPDATE_CLOSING.DAYTIME
		AND LIFTING_ACCOUNT_ID = ECDP_OBJECTS.GETOBJIDFROMCODE('LIFTING_ACCOUNT','LA_CAPL_COND');
		COMMIT;

		ln_temp_closing := EC_CT_COND_INV.CLOSING(ECDP_OBJECTS.GETOBJIDFROMCODE('STORAGE','STW_COND'), C_UPDATE_CLOSING.DAYTIME-1, 'CT_COND_INV' , ECDP_OBJECTS.GETOBJIDFROMCODE('LIFTING_ACCOUNT','LA_KWI_COND') , '=');
		UPDATE CT_COND_INV
		SET OPENING = NVL(ln_temp_closing,0),
		CLOSING = NVL(ln_temp_closing,0) + NVL(INCOMING,0) - NVL(OUTGOING,0)
		WHERE DAYTIME = C_UPDATE_CLOSING.DAYTIME
		AND LIFTING_ACCOUNT_ID = ECDP_OBJECTS.GETOBJIDFROMCODE('LIFTING_ACCOUNT','LA_KWI_COND');
		COMMIT;

		ln_temp_closing := EC_CT_COND_INV.CLOSING(ECDP_OBJECTS.GETOBJIDFROMCODE('STORAGE','STW_COND'), C_UPDATE_CLOSING.DAYTIME-1, 'CT_COND_INV' , ECDP_OBJECTS.GETOBJIDFROMCODE('LIFTING_ACCOUNT','LA_PEW_COND') , '=');
		UPDATE CT_COND_INV
		SET OPENING = NVL(ln_temp_closing,0),
		CLOSING = NVL(ln_temp_closing,0) + NVL(INCOMING,0) - NVL(OUTGOING,0)
		WHERE DAYTIME = C_UPDATE_CLOSING.DAYTIME
		AND LIFTING_ACCOUNT_ID = ECDP_OBJECTS.GETOBJIDFROMCODE('LIFTING_ACCOUNT','LA_PEW_COND');
		COMMIT;

		ln_temp_closing := EC_CT_COND_INV.CLOSING(ECDP_OBJECTS.GETOBJIDFROMCODE('STORAGE','STW_COND'), C_UPDATE_CLOSING.DAYTIME-1, 'CT_COND_INV' , ECDP_OBJECTS.GETOBJIDFROMCODE('LIFTING_ACCOUNT','LA_QE_COND') , '=');
		UPDATE CT_COND_INV
		SET OPENING = NVL(ln_temp_closing,0),
		CLOSING = NVL(ln_temp_closing,0) + NVL(INCOMING,0) - NVL(OUTGOING,0)
		WHERE DAYTIME = C_UPDATE_CLOSING.DAYTIME
		AND LIFTING_ACCOUNT_ID = ECDP_OBJECTS.GETOBJIDFROMCODE('LIFTING_ACCOUNT','LA_QE_COND');
		COMMIT;

		ln_temp_closing := EC_CT_COND_INV.CLOSING(ECDP_OBJECTS.GETOBJIDFROMCODE('STORAGE','STW_COND'), C_UPDATE_CLOSING.DAYTIME-1, 'CT_COND_INV' , ECDP_OBJECTS.GETOBJIDFROMCODE('LIFTING_ACCOUNT','LA_KJB_COND') , '=');
		UPDATE CT_COND_INV
		SET OPENING = NVL(ln_temp_closing,0),
		CLOSING = NVL(ln_temp_closing,0) + NVL(INCOMING,0) - NVL(OUTGOING,0)
		WHERE DAYTIME = C_UPDATE_CLOSING.DAYTIME
		AND LIFTING_ACCOUNT_ID = ECDP_OBJECTS.GETOBJIDFROMCODE('LIFTING_ACCOUNT','LA_KJB_COND');
		COMMIT;

		ln_temp_closing := EC_CT_COND_INV.CLOSING(ECDP_OBJECTS.GETOBJIDFROMCODE('STORAGE','STW_COND'), C_UPDATE_CLOSING.DAYTIME-1, 'CT_COND_INV' , ECDP_OBJECTS.GETOBJIDFROMCODE('LIFTING_ACCOUNT','LA_WEJ_COND') , '=');
		UPDATE CT_COND_INV
		SET OPENING = NVL(ln_temp_closing,0),
		CLOSING = NVL(ln_temp_closing,0) + NVL(INCOMING,0) - NVL(OUTGOING,0)
		WHERE DAYTIME = C_UPDATE_CLOSING.DAYTIME
		AND LIFTING_ACCOUNT_ID = ECDP_OBJECTS.GETOBJIDFROMCODE('LIFTING_ACCOUNT','LA_WEJ_COND');
		COMMIT;
	END LOOP;

END CALCINVENTORY;

END UE_CT_COND_INV_CP;
/