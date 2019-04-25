create or replace PACKAGE ZP_DG_MSG_LOADER IS
/****************************************************************
** Package        :  ZP_DG_MSG_LOADER, header part
**
** Purpose        :  Handles the loading of Domgas messages into EC
**
** Documentation  :
**
** Created  : 02-NOV-2015  Samuel Webb
**
** Modification history:
**
** Date           Whom  Change Description
** -----------    ----  ------------------------------------------
** 02-NOV-2015    swgn  Initial version
*****************************************************************/

PROCEDURE buildNewEstimateScenario(p_seller_contact VARCHAR2, p_start_date DATE, p_end_date DATE, p_scenario_id OUT VARCHAR2);

PROCEDURE IUSellerDailyEstimate(p_scenario_id VARCHAR2, p_contract_code VARCHAR2, p_daytime DATE, p_estimate NUMBER, p_unit VARCHAR2, p_comments VARCHAR2);

END ZP_DG_MSG_LOADER;
/
create or replace PACKAGE BODY ZP_DG_MSG_LOADER IS
/****************************************************************
** Package        :  ZP_DG_MSG_LOADER, body part
**
** Purpose        :  Handles the loading of Domgas messages into EC
**
** Documentation  :
**
** Created  : 02-NOV-2015  Samuel Webb
**
** Modification history:
**
** Date           Whom  Change Description
** -----------    ----  ------------------------------------------
** 02-NOV-2015    swgn  Initial version
*****************************************************************/

PROCEDURE buildNewEstimateScenario(p_seller_contact VARCHAR2, p_start_date DATE, p_end_date DATE, p_scenario_id OUT VARCHAR2)
IS
    v_contract_id VARCHAR2(32);
    v_scenario_code VARCHAR2(255);
    v_company_name VARCHAR2(200);
    v_scenario_name VARCHAR2(1000);
    v_scenario_desc VARCHAR2(1000);
    v_scenario_count NUMBER := 0;

    CURSOR get_contracts IS
    SELECT msg.code, msg.name, cntr.object_id as contract_id, cntr.code as contract_code, cntr.company_name as company_name, cntr.company_code as company_code
    FROM ov_message_contact msg, ov_contract cntr
    WHERE msg.company_id = cntr.company_id
    AND contract_area_code IN ('CA_WST_DOMGAS_SELLERS','CA_DOMGAS_EQUITY')
    AND msg.object_id = p_seller_contact;

BEGIN

    --EcDp_DynSql.WriteTempText('ZP_DG_MSG_LOADER', 'Contact code [' || ecdp_objects.getobjname(p_seller_contact, sysdate) || '] From [' || to_char(p_start_Date, 'DD-MON-YYYY') || '] To [' || to_char(p_end_date, 'DD-MON-YYYY') || ']');

    -- Find the contract information
    FOR item IN get_contracts LOOP
        v_contract_id := item.contract_id;
        v_company_name := item.company_name;
        v_scenario_code := 'SE_' || item.contract_code || '_' || to_char(p_start_date, 'YYYY');
        v_scenario_name := item.company_code || ' Sellers Estimate (' || to_char(p_start_date, 'YYYY') || ')';
        v_scenario_desc := to_char(p_start_date, 'YYYY') || ' seller''s estimates for ' || item.company_name;
    END LOOP;

    -- Figure out if we have a scenario with this code already
    SELECT count(DISTINCT code) INTO v_scenario_count
    FROM ov_forecast_tran_fc
    WHERE code LIKE v_scenario_code || '%';

    IF v_scenario_count > 0 THEN
        v_scenario_code := v_scenario_code || '_' || to_char(v_scenario_count);
		v_scenario_name := v_scenario_name || '_' || to_char(v_scenario_count);
		v_scenario_desc := v_scenario_desc || '_' || to_char(v_scenario_count);
    END IF;

    -- Add the new scenario object
    INSERT INTO ov_forecast_tran_fc(code, name, object_start_date, object_end_date, description, scenario_type, prod_fcst_type, prod_fcst_scenario)
    VALUES (v_scenario_code, v_scenario_name, p_start_date, p_end_date, v_scenario_desc, 'DG_EST', 'NOMINATIONS', 'MED_CONF');

    -- Get the forecast id
    SELECT object_id INTO p_scenario_id
    FROM ov_forecast_tran_fc
    WHERE code = v_scenario_code;

END buildNewEstimateScenario;

PROCEDURE IUSellerDailyEstimate(p_scenario_id VARCHAR2, p_contract_code VARCHAR2, p_daytime DATE, p_estimate NUMBER, p_unit VARCHAR2, p_comments VARCHAR2)
IS

    v_count NUMBER;
    v_ade NUMBER := EcDp_Unit.convertValue(p_estimate, NVL(p_unit, EcDp_Unit.getUnitFromLogical(ec_class_attr_property_cnfg.property_value('FCST_CNTR_DAY_STATUS', 'ADE','UOM_CODE','VIEWLAYER',2500,'/'))), EcDp_Unit.getUnitFromLogical(ec_class_attr_property_cnfg.property_value('FCST_CNTR_DAY_STATUS', 'ADE','UOM_CODE','VIEWLAYER',2500,'/')));

BEGIN

    SELECT count(*) INTO v_count
    FROM dv_fcst_cntr_day_status
    WHERE forecast_id = p_scenario_id
    AND object_code = p_contract_code
    AND daytime = p_daytime;

    IF v_count = 0 THEN
        INSERT INTO dv_fcst_cntr_day_status (object_code, daytime, ade, forecast_id)
        VALUES (p_contract_code, p_daytime, v_ade, p_scenario_id);
    ELSE
        UPDATE dv_fcst_cntr_day_status
        SET ade = v_ade
        WHERE forecast_id = p_scenario_id
        AND object_code = p_contract_code
        AND daytime = p_daytime;
    END IF;

END IUSellerDailyEstimate;

END ZP_DG_MSG_LOADER;
/