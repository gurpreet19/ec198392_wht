CREATE OR REPLACE PACKAGE BODY EcBp_Report IS
/**************************************************************
** Package:    EcBp_Report
**
** $Revision: 1.25 $
**
** Filename:   EcBp_Report_body.sql
**
** Part of :   Reporting
**
** Purpose: This package is used by the EC Reporting screens.
**
** General Logic:
**
** Document References:
**
**
** Created:     08.11.05  Magnus Otterå
**
**
*
** Modification history:
**
**
** Date:     Whom:      Change description:
** --------  ---------  --------------------------------------------
** 22.11.05    MOT       Referring to tables instead of class views
** 22.11.05   DN        Formatting and EC-DOC directives.
** 06.12.05   MOT       Added function isReportDefInGroup
** 06.01.06   MOT       Added insertReportRunnableParams and deleteReportRunnableParams
** 22.02.06   MOT       When adding a new parameter to a template: Not copying this to runable report
** 21.02.07   kaurrnar  ECPD 5045: Added SORT_ORDER in cursors
** 03.09.07   ottermag  Major changes due to Jira ecpd-6438
** 18.07.08   olberegi  Fixed cursors returning identical rows causing inique constraint violation
** 16.09.11   RJe        Added alias handling
** 15.08.16   bjerkari  Added support for new version of report set
** 22.11.16   bjerkari  Fixed bugs with report parameters. Refactoring of the code, to remove complexity.
**************************************************************/



/********************* Cursors *********************************/

-- Find all parameters in report definitions that are linked to the given report template and have the given parameter name
CURSOR gc_definitionParams(p_report_template VARCHAR2, p_parameter_name VARCHAR2)  IS
    SELECT DISTINCT rdp.report_definition_no, rdp.parameter_name, rdp.alias, rdp.daytime
    FROM report_definition rd, report_definition_param rdp
    WHERE rd.template_code = p_report_template
        AND rd.report_definition_no = rdp.report_definition_no
        AND rdp.parameter_name = p_parameter_name;


--Find parameters on all report runable for given report template and parameter name
CURSOR gc_report_runable_param(p_report_template VARCHAR2, p_parameter_name VARCHAR2) IS
    SELECT DISTINCT rr.report_runable_no, rd.daytime, nvl(rdp.alias,rdp.parameter_name) as parameter_name
    FROM report_runable rr, report_definition_group rdg, report_definition rd,report_definition_param rdp
    WHERE rr.rep_group_code = rdg.rep_group_code
        AND rdg.rep_group_code = rd.rep_group_code
        AND ecbp_report.isReportDefInGroup(rd.report_definition_no,rdg.rep_group_code) = 'Y'
        AND rd.template_code = p_report_template
        AND rd.report_definition_no = rdp.report_definition_no
        AND rdp.parameter_name = p_parameter_name;


-- Private functions/procedures
FUNCTION otherConnTempParam(p_report_definition_no VARCHAR2, p_report_parameter_name VARCHAR2, p_daytime DATE) RETURN VARCHAR2;
FUNCTION runnableParamExists(p_report_runable_no VARCHAR2, p_report_parameter_name VARCHAR2, p_daytime DATE) RETURN VARCHAR2;
FUNCTION reportSetParamExists(p_report_set_no VARCHAR2, p_report_parameter_name VARCHAR2, p_daytime DATE) RETURN VARCHAR2;
FUNCTION otherConnRunnParam(p_report_set_no VARCHAR2, p_report_runable_no VARCHAR2, p_report_parameter_name VARCHAR2, p_daytime DATE) RETURN VARCHAR2;
FUNCTION otherConnTempParamWithoutValue(p_report_definition_no VARCHAR2, p_report_parameter_name VARCHAR2, p_daytime DATE) RETURN VARCHAR2;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : createReportSystemParams
-- Description  : Instantiates all report system parameters associated with the current report system
--                into the REPORT_SYSTEM_PARAM class.
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: REPORT_TEMPLATE, REPORT_TEMPLATE_PARAM, PROSTY_CODES
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:   Only instantiate if there is no records in the REPORT_SYSTEM_PARAM
--                              for this report template
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE createReportSystemParams(p_report_template VARCHAR2, p_report_system VARCHAR2)
--</EC-DOC>
IS
-- Find report system parameters related to the given report system
CURSOR c_system_params(p_report_system VARCHAR2) IS
        SELECT ec_prosty_codes.code_text(d.code2,d.code_type2) AS name,d.code2 AS code, d.code_type2 AS code_type
        FROM ctrl_code_dependency d
        WHERE d.dependency_type = 'REPORT_SYSTEM_PARAMS'
        AND d.code_type1 = 'REPORT_SYSTEM'
        AND d.code1 = p_report_system;

ln_no_params NUMBER;

BEGIN

    ln_no_params := 0;

    SELECT count(template_code)
    INTO ln_no_params
    FROM report_template_param
    WHERE parameter_type = 'REPORT_SYSTEM_PARAM'
        AND template_code = p_report_template;

    IF ln_no_params = 0 THEN

        FOR cur_rec IN c_system_params(p_report_system) LOOP

            INSERT INTO report_template_param(template_code, parameter_name, parameter_type, parameter_sub_type)
            VALUES (p_report_template,cur_rec.name, cur_rec.code_type, cur_rec.code);

        END LOOP;
    END IF;

END createReportSystemParams;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : deleteReportSystemParams
-- Description  : Deletes report system parameters associated with the current report template
--                in the REPORT_TEMPLATE_PARAM table
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: REPORT_TEMPLATE_PARAM
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE deleteReportSystemParams(p_report_template VARCHAR2, p_param_type VARCHAR2)
--</EC-DOC>
IS

BEGIN

    DELETE report_template_param
    WHERE template_code = p_report_template
        AND parameter_type = p_param_type;

END deleteReportSystemParams;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : insertReportDefinitionParam
-- Description  : Insert a new report parameter on all report definitions connected to given report template
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: REPORT_TEMPLATE_PARAM, REPORT_DEFINITION_PARAM
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE insertReportDefinitionParam(p_report_template VARCHAR2, p_parameter_name VARCHAR2, p_parameter_type VARCHAR2, p_parameter_sub_type VARCHAR2, p_access_check_ind VARCHAR2, p_sort_order NUMBER)
--</EC-DOC>
IS

-- Find all report definitions that are linked to the given report template
CURSOR c_definitions(p_report_template VARCHAR2) IS
        SELECT rd.report_definition_no, rd.daytime
        FROM report_definition rd
        WHERE rd.template_code = p_report_template;

BEGIN

   --Insert parameters into report definition
   FOR cur_rec IN c_definitions(p_report_template) LOOP
        INSERT INTO tv_report_definition_param(report_definition_no, daytime, parameter_name, parameter_type, parameter_sub_type, access_check_ind, sort_order)
        VALUES (cur_rec.report_definition_no,cur_rec.daytime, p_parameter_name, p_parameter_type, p_parameter_sub_type, p_access_check_ind, p_sort_order);
   END LOOP;

END insertReportDefinitionParam;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : insertReportRunableParam
-- Description  : Insert a new report parameter on all report runnable connected to given version of report definition.
--
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables:
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE insertReportRunableParam(p_report_definition_no NUMBER, p_daytime DATE, p_parameter_name VARCHAR2, p_parameter_type VARCHAR2, p_parameter_sub_type VARCHAR2, p_access_check_ind VARCHAR2, p_sort_order NUMBER)
--</EC-DOC>
IS

--Find runables connected to given definition, that does not already have the given parameter
CURSOR c_report_runables(p_report_definition_no NUMBER) IS
        SELECT DISTINCT rr.report_runable_no, rd.daytime
        FROM report_runable rr, report_definition_group rdg, report_definition rd
        WHERE rd.report_definition_no = p_report_definition_no
            AND rr.rep_group_code = rdg.rep_group_code
            AND rdg.rep_group_code = rd.rep_group_code
            AND rd.daytime = p_daytime
            AND rr.report_runable_no NOT IN (
                select rr.report_runable_no
                from report_runable_param rrp
                where rrp.report_runable_no = rr.report_runable_no
                    AND rrp.parameter_name = p_parameter_name
                    AND rrp.daytime = rd.daytime);

BEGIN
   FOR cur_rec IN c_report_runables(p_report_definition_no) LOOP
        INSERT INTO tv_report_runable_param(report_runable_no, daytime, parameter_name, parameter_type, parameter_sub_type, access_check_ind, sort_order)
        VALUES (cur_rec.report_runable_no,cur_rec.daytime, p_parameter_name, p_parameter_type, p_parameter_sub_type, p_access_check_ind, p_sort_order);
   END LOOP;
END insertReportRunableParam;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : insertReportSetParam
-- Description  : Insert new report parameter on all report sets and reports in report sets, connected to the given version of report runnable.
--
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: REPORT_SET_LIST, REPORT_RUNABLE, REPORT_RUNABLE_PARAM, REPORT_SET_PARAM, REPORT_SET_REPORT_PARAM
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE insertReportSetParam(p_report_runable_no NUMBER, p_daytime DATE, p_parameter_name VARCHAR2, p_parameter_type VARCHAR2, p_parameter_sub_type VARCHAR2, p_access_check_ind VARCHAR2, p_sort_order NUMBER)
--</EC-DOC>
IS
--Find report sets that have the given report runable and where parameter/daytime does not exists in report_set_param
CURSOR c_report_sets(p_report_runable_no NUMBER, p_parameter_name VARCHAR2, p_daytime DATE) IS
        SELECT DISTINCT rsl.report_set_no, rrp.daytime
        FROM report_set_list rsl,
             report_runable rr,
             report_runable_param rrp
        WHERE rr.report_runable_no = p_report_runable_no
            AND rrp.parameter_name = p_parameter_name
            AND rrp.report_runable_no = rr.report_runable_no
            AND rsl.report_runable_no = rr.report_runable_no
            AND rrp.daytime = p_daytime
            AND rsl.report_set_no NOT IN (
                SELECT  distinct rsp.report_set_no
                FROM report_set_param rsp
                 WHERE rsp.parameter_name = p_parameter_name
                    AND rsp.daytime = rrp.daytime
                    AND rsp.report_set_no = rsl.report_set_no);

--Find reports in report sets for given report runable, where given parameter/daytime is missing in report_set_report_param
CURSOR c_report_set_reports(p_report_runable_no NUMBER, p_parameter_name VARCHAR2, p_daytime DATE) IS
        SELECT DISTINCT rsl.report_set_no, rsl.ref_no, rrp.daytime
        FROM report_set_list rsl,
             report_runable rr,
             report_runable_param rrp
        WHERE rsl.report_runable_no = p_report_runable_no
            AND rr.report_runable_no = rsl.report_runable_no
            AND rrp.report_runable_no = rr.report_runable_no
            AND rrp.parameter_name = p_parameter_name
            AND rrp.daytime = p_daytime
            AND rsl.ref_no NOT IN (
                SELECT distinct rsrp.ref_no
                FROM report_set_report_param rsrp
                WHERE rsrp.parameter_name = p_parameter_name
                    AND rsrp.daytime = rrp.daytime
                    AND rsrp.ref_no = rsl.ref_no
                    AND report_set_no = rsl.report_set_no );

BEGIN
   --Insert parameters into report set
   FOR cur_rec IN c_report_sets(p_report_runable_no, p_parameter_name, p_daytime) LOOP
        INSERT INTO tv_report_set_param(report_set_no, daytime, parameter_name, parameter_type, parameter_sub_type, access_check_ind)
        VALUES (cur_rec.report_set_no,cur_rec.daytime, p_parameter_name, p_parameter_type, p_parameter_sub_type, p_access_check_ind);
   END LOOP;

   --Insert parameters into report set report param
   FOR cur_rec IN c_report_set_reports(p_report_runable_no, p_parameter_name, p_daytime) LOOP
        INSERT INTO tv_report_set_report_param(report_set_no, ref_no, daytime, parameter_name, parameter_type, parameter_sub_type, access_check_ind, sort_order)
        VALUES (cur_rec.report_set_no,cur_rec.ref_no, cur_rec.daytime, p_parameter_name, p_parameter_type, p_parameter_sub_type, p_access_check_ind, p_sort_order);
   END LOOP;

END insertReportSetParam;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : updateReportDefParam
-- Description  : Updates the report definition parameter based on changes on report template parameter.
--                Used as update trigger on report_template_param.
--                The runnable- and set parameters will be updated by cascading triggers.
--
--
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: REPORT_TEMPLATE_PARAM, REPORT_DEFINITION_PARAM
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE updateReportDefParam(p_report_template VARCHAR2, p_new_parameter_name VARCHAR2,
          p_old_parameter_name VARCHAR2, p_parameter_type VARCHAR2, p_new_parameter_sub_type VARCHAR2,p_old_parameter_sub_type VARCHAR2,
          p_new_access_check_ind VARCHAR2, p_old_access_check_ind VARCHAR2, p_sort_order NUMBER)
--</EC-DOC>
IS
BEGIN
    IF(p_new_parameter_sub_type = p_old_parameter_sub_type) THEN
        FOR cur_rec IN gc_definitionParams(p_report_template, p_old_parameter_name) LOOP
            UPDATE tv_report_definition_param
            SET parameter_name = p_new_parameter_name, access_check_ind = p_new_access_check_ind, sort_order = p_sort_order
            WHERE report_definition_no = cur_rec.report_definition_no
                AND parameter_name = p_old_parameter_name
                AND daytime = cur_rec.daytime;
        END LOOP;

    ELSE
        FOR cur_rec IN gc_definitionParams(p_report_template, p_old_parameter_name) LOOP
            -- Delete this parameter on all definitions using the given template
            DELETE tv_report_definition_param
            WHERE report_definition_no = cur_rec.report_definition_no
                AND parameter_name = cur_rec.parameter_name
                AND daytime = cur_rec.daytime;

            -- Insert the parameter with the new sub type. Note that the value itself will be cleared
            INSERT INTO tv_report_definition_param(report_definition_no, daytime, parameter_name, parameter_type, parameter_sub_type, access_check_ind, alias, sort_order)
            VALUES (cur_rec.report_definition_no, cur_rec.daytime, p_new_parameter_name, p_parameter_type, p_new_parameter_sub_type, p_new_access_check_ind, cur_rec.alias, p_sort_order);

        END LOOP;

     END IF;

END updateReportDefParam;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : updateReportRunnableParam
-- Description  : Updates the report runnable parameter based on update on the report definition parameter.
--                It will handle: Update in parameter name (for new alias, the new parameter name must be the alias), access_check_ind, sort_order.
--                Used as update trigger on report_definition_param.
--                The report set parameters will be updated by cascading trigger.
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: REPORT_DEFINITION_PARAM, REPORT_RUNABLE_PARAM
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE updateReportRunnableParam(p_report_definition_no VARCHAR2, p_daytime DATE, p_new_parameter_name VARCHAR2,
          p_old_parameter_name VARCHAR2, p_parameter_type VARCHAR2, p_parameter_sub_type VARCHAR2, p_new_access_check_ind VARCHAR2,
          p_new_sort_order NUMBER, p_old_parameter_value VARCHAR2, p_new_parameter_value VARCHAR2, p_old_alias VARCHAR2, p_new_alias VARCHAR2 )
--</EC-DOC>
IS
-- report runables connected to the given report definition
CURSOR c_report_runable(p_report_definition_no VARCHAR2) IS
    SELECT DISTINCT rr.report_runable_no
    FROM report_runable rr, report_definition rd
    WHERE rd.report_definition_no = p_report_definition_no
        AND rr.rep_group_code = rd.rep_group_code;

BEGIN
    FOR cur_rec IN c_report_runable(p_report_definition_no) LOOP

        IF (p_new_parameter_value IS NOT NULL AND p_old_parameter_value IS NULL) THEN
            IF ( otherConnTempParamWithoutValue(p_report_definition_no, NVL( p_old_alias, p_old_parameter_name ), p_daytime) = 'N' ) THEN
               -- We remove the parameter when a definition-value as added
                DELETE FROM tv_report_runable_param WHERE report_runable_no = cur_rec.report_runable_no AND daytime = p_daytime AND parameter_name = NVL(p_old_alias, p_old_parameter_name);
            END IF;
        ELSIF (p_new_parameter_value IS NULL AND p_old_parameter_value IS NOT NULL) THEN
            IF ( runnableParamExists(cur_rec.report_runable_no, NVL( p_new_alias, p_old_parameter_name ), p_daytime) = 'N' ) THEN
	            -- We insert the parameter when the definition value is removed
	            INSERT INTO tv_report_runable_param(report_runable_no, parameter_name, parameter_type, parameter_sub_type, access_check_ind, daytime)
                VALUES (cur_rec.report_runable_no, NVL(p_new_alias, p_new_parameter_name), p_parameter_type, p_parameter_sub_type, p_new_access_check_ind, p_daytime);
            END IF;

        ELSE
           IF ((p_new_alias IS NULL AND p_old_alias IS NOT NULL) OR (p_old_alias IS NULL AND p_new_alias IS NOT NULL) OR (p_new_alias != p_old_alias)) THEN
            -- Handle update on alias
                 IF ( otherConnTempParam(p_report_definition_no, NVL( p_old_alias, p_old_parameter_name ), p_daytime) = 'N' ) THEN
                     IF ( runnableParamExists(cur_rec.report_runable_no, NVL( p_new_alias, p_old_parameter_name ), p_daytime) = 'N' ) THEN
                        -- We can rename the existing parameter because it is not connected to other template-parameters, and the new parameter does not exist
                         UPDATE tv_report_runable_param
                         SET parameter_name = NVL(p_new_alias, p_new_parameter_name)
                         WHERE report_runable_no = cur_rec.report_runable_no
                            AND parameter_name = NVL(p_old_alias, p_old_parameter_name)
                            AND daytime = p_daytime;
                   ELSE
                        -- We just need to delete the old parameter. The old perameter is not connected to other template-parameters, and the new parameter already exists.
                            DELETE FROM tv_report_runable_param
                          WHERE report_runable_no = cur_rec.report_runable_no
                            AND parameter_name = NVL(p_old_alias, p_old_parameter_name)
                            AND daytime = p_daytime;
                   END IF;

                 ELSIF ( runnableParamExists(cur_rec.report_runable_no, NVL( p_new_alias, p_new_parameter_name ), p_daytime ) = 'N' ) THEN
                    -- We need to insert a new parameter because it is missing,  We don't delete the old parameter because it is connected to other template-parameters
                    INSERT INTO tv_report_runable_param(report_runable_no, daytime, parameter_name, parameter_type, parameter_sub_type, access_check_ind, sort_order)
                    VALUES (cur_rec.report_runable_no, p_daytime, NVL( p_new_alias, p_new_parameter_name), p_parameter_type, p_parameter_sub_type, p_new_access_check_ind, p_new_sort_order);

               END IF;

           ELSE

                -- Update values. This will be executed only if changes are done to the template (parameter name, access check and sort order)
              UPDATE tv_report_runable_param
              SET parameter_name = NVL( p_new_parameter_name, p_old_parameter_name),
                  access_check_ind = p_new_access_check_ind,
                  sort_order = p_new_sort_order
              WHERE report_runable_no = cur_rec.report_runable_no
                  AND parameter_name = NVL( p_old_alias, p_old_parameter_name)
                  AND daytime = p_daytime;
            END IF;
        END IF;

    END LOOP;

END updateReportRunnableParam;


--
-- Return 'Y' if there are parameters with the same name connected to other templates on the definition, for given daytime
-- Internal function
--
FUNCTION otherConnTempParam(p_report_definition_no VARCHAR2, p_report_parameter_name VARCHAR2, p_daytime DATE)
RETURN VARCHAR2
IS
    lv_num_rows NUMBER;
BEGIN
    SELECT count(*) INTO lv_num_rows
    FROM report_definition rd,
        report_definition_param rdp
    WHERE rd.rep_group_code = (SELECT rep_group_code FROM report_definition WHERE report_definition_no = p_report_definition_no)
        AND  rd.report_definition_no != p_report_definition_no
        AND rdp.report_definition_no = rd.report_definition_no
        AND rdp.parameter_name = p_report_parameter_name
        AND rdp.daytime = p_daytime;

    IF ( lv_num_rows > 0 ) THEN
       RETURN 'Y';
    ELSE
       RETURN 'N';
    END IF;

END otherConnTempParam;

--
-- Return 'Y' if there are parameters with the same name connected to other templates on the definition, for given daytime, without a parameter value
-- Internal function
--
FUNCTION otherConnTempParamWithoutValue(p_report_definition_no VARCHAR2, p_report_parameter_name VARCHAR2, p_daytime DATE)
RETURN VARCHAR2
IS
    lv_num_rows NUMBER;
BEGIN
    SELECT count(*) INTO lv_num_rows
    FROM report_definition rd,
        report_definition_param rdp
    WHERE rd.rep_group_code = (SELECT rep_group_code FROM report_definition WHERE report_definition_no = p_report_definition_no)
        AND  rd.report_definition_no != p_report_definition_no
        AND rdp.report_definition_no = rd.report_definition_no
        AND rdp.parameter_name = p_report_parameter_name
        AND rdp.daytime = p_daytime
        AND rdp.parameter_value is null;

    IF ( lv_num_rows > 0 ) THEN
       RETURN 'Y';
    ELSE
       RETURN 'N';
    END IF;

END otherConnTempParamWithoutValue;


--
-- Return 'Y' if the parameter exist in report_runable_param
-- Internal function
--
FUNCTION runnableParamExists(p_report_runable_no VARCHAR2, p_report_parameter_name VARCHAR2, p_daytime DATE)
RETURN VARCHAR2
IS
  lv_num_rows NUMBER;
BEGIN
    SELECT count(*) into lv_num_rows
    FROM report_runable_param rrp
    WHERE rrp.report_runable_no = p_report_runable_no
        AND rrp.parameter_name = p_report_parameter_name
        AND rrp.daytime = p_daytime;

    IF ( lv_num_rows > 0 ) THEN
       RETURN 'Y';
    ELSE
       RETURN 'N';
    END IF;
END runnableParamExists;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : updateReportSetParam
-- Description  : Updates the report set parameter based on update on the report runable parameter (both report_set_report_param and report_set_param)
--                Used as update trigger on report_runable_param.
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: REPORT_RUNABLE_PARAM, REPORT_SET_PARAM, REPORT_SET_REPORT_PARAM
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
---------------------------------------------------------------------------------------------------
PROCEDURE updateReportSetParam(p_report_runable_no NUMBER, p_daytime DATE, p_new_parameter_name VARCHAR2,
          p_old_parameter_name VARCHAR2, p_new_access_check_ind VARCHAR2, p_old_access_check_ind VARCHAR2, p_new_sort_order NUMBER, p_old_sort_order NUMBER,
          p_old_parameter_value VARCHAR2, p_new_parameter_value VARCHAR2)
--</EC-DOC>
IS



--Find report sets that contains the given report runable and where any of the parameter is not updated
--(assumes that all values will be like the old values, if it is not updated)
CURSOR c_report_set_param(p_report_runable_no NUMBER, p_old_parameter_name VARCHAR2, p_old_access_check_ind VARCHAR2) IS
        SELECT distinct rsl.report_set_no, rsp.parameter_type, rsp.parameter_sub_type
        FROM report_set_param rsp,
            report_set_list rsl
        WHERE rsl.report_runable_no = p_report_runable_no
            AND rsp.report_set_no = rsl.report_set_no
            AND rsp.parameter_name = p_old_parameter_name;

--Find all reports in reports sets for given report runable, that are not already updated
CURSOR c_report_set_report_param(p_report_runable_no VARCHAR2, p_old_parameter_name VARCHAR2, p_old_access_check_ind VARCHAR2, p_old_sort_order NUMBER) IS
        SELECT distinct rsrp.report_set_no, rsrp.ref_no, rsrp.parameter_type, rsrp.parameter_sub_type
        FROM report_set_list rsl,
            report_set_report_param rsrp
        WHERE rsl.report_runable_no = p_report_runable_no
            AND rsrp.report_set_no = rsl.report_set_no
            AND rsrp.ref_no = rsl.ref_no
            AND rsrp.parameter_name = p_old_parameter_name;

BEGIN

    -- Handle Report Set Param
    FOR cur_rec IN c_report_set_param(p_report_runable_no, p_old_parameter_name, p_old_access_check_ind) LOOP

        IF ( p_old_parameter_name != p_new_parameter_name ) THEN
            IF ( otherConnRunnParam(cur_rec.report_set_no, p_report_runable_no, p_old_parameter_name, p_daytime ) = 'N' ) THEN

                IF ( reportSetParamExists(cur_rec.report_set_no, p_new_parameter_name, p_daytime ) = 'N' ) THEN
                  -- The old parameter name is not used by other runnables in the set, and the new name does not exist, so we just rename
                    UPDATE tv_report_set_param
                    SET parameter_name = p_new_parameter_name,
                        access_check_ind = p_new_access_check_ind
                    WHERE report_set_no = cur_rec.report_set_no
                        AND parameter_name = p_old_parameter_name
                        AND daytime = p_daytime;
                ELSE
                    -- The old parameter name is not used by other runnables, but the new name exist already, so we just delete the old
                    DELETE FROM tv_report_set_param
                    WHERE parameter_name = p_old_parameter_name
                         AND report_set_no = cur_rec.report_set_no
                         AND daytime = p_daytime;
                END IF;

            ELSIF ( reportSetParamExists(cur_rec.report_set_no, p_new_parameter_name, p_daytime ) = 'N' ) THEN
                -- The new parameter name does not exist, so we insert the new parameter.
                -- We don't delete the old, because it is connected to other runnables in the set.
                INSERT INTO tv_report_set_param(report_set_no, daytime, parameter_name, parameter_type, parameter_sub_type, access_check_ind)
                VALUES (cur_rec.report_set_no, p_daytime, p_new_parameter_name, cur_rec.parameter_type, cur_rec.parameter_sub_type, p_new_access_check_ind);
            END IF;
        END IF;
    END LOOP;

    -- Handle Report Set Report Param
    FOR cur_rec IN c_report_set_report_param(p_report_runable_no, p_old_parameter_name, p_old_access_check_ind, p_old_sort_order) LOOP
        UPDATE tv_report_set_report_param
        SET parameter_name = p_new_parameter_name,
            access_check_ind = p_new_access_check_ind,
            sort_order = p_new_sort_order
        WHERE report_set_no = cur_rec.report_set_no
              AND ref_no = cur_rec.ref_no
              AND parameter_name = p_old_parameter_name
              AND daytime = p_daytime;
    END LOOP;
END updateReportSetParam;

--
-- Return 'Y' if the parameter exist in report_set_param
-- Internal function
--
FUNCTION reportSetParamExists(p_report_set_no VARCHAR2, p_report_parameter_name VARCHAR2, p_daytime DATE)
RETURN VARCHAR2
IS
    lv_num_rows number;
BEGIN
    SELECT count(*) INTO lv_num_rows
    FROM report_set_param rsp
    WHERE rsp.report_set_no = p_report_set_no
        AND rsp.parameter_name = p_report_parameter_name
        AND rsp.daytime = p_daytime;

    IF ( lv_num_rows > 0 ) THEN
       RETURN 'Y';
    ELSE
       RETURN 'N';
    END IF;
END reportSetParamExists;



--
-- Return 'Y' if there are parameters with the same name connected to other report runnables in the report set
--
FUNCTION otherConnRunnParam(p_report_set_no VARCHAR2, p_report_runable_no VARCHAR2, p_report_parameter_name VARCHAR2, p_daytime DATE)
RETURN VARCHAR2
IS
    lv_num_rows NUMBER;
BEGIN
    SELECT count(*) INTO lv_num_rows
    FROM report_set_list rsl,
         report_set_report_param rsrp
    WHERE rsl.report_runable_no != p_report_runable_no
          AND rsrp.ref_no = rsl.ref_no
          AND rsrp.report_set_no = rsl.report_set_no
          AND rsrp.daytime = p_daytime
          AND rsrp.parameter_name = p_report_parameter_name;

    IF ( lv_num_rows > 0 ) THEN
       RETURN 'Y';
    ELSE
       RETURN 'N';
    END IF;
END otherConnRunnParam;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : deleteReportDefParam
-- Description  : Deletes a report definition parameter on all definitions connected to a template
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: REPORT_DEFINITION_PARAM
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE deleteReportDefParam(p_report_template VARCHAR2, p_parameter_name VARCHAR2)
--</EC-DOC>
IS

BEGIN
    FOR cur_rec IN gc_definitionParams(p_report_template, p_parameter_name) LOOP
        DELETE from tv_report_definition_param
        WHERE report_definition_no = cur_rec.report_definition_no
            AND parameter_name = cur_rec.parameter_name
            AND daytime = cur_rec.daytime;
    END LOOP;
END deleteReportDefParam;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : deleteReportRunableParam
-- Description  : Deletes the report runnable parameter connected to a definition. If the definition parameter has
--                alias, this need to be provided as p_parameter_name.
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: REPORT_RUNABLE_PARAM
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE deleteReportRunableParam(p_report_definition VARCHAR2, p_daytime DATE, p_parameter_name VARCHAR2)
--</EC-DOC>
IS
  --Find report runables connected to given report definition for the specific daytime
CURSOR c_report_runables(p_report_definition VARCHAR2) IS
        SELECT distinct rr.report_runable_no
        FROM
            report_runable rr,
            report_definition_group rdg,
            report_definition rd
        WHERE
            rd.report_definition_no = p_report_definition
            AND rdg.rep_group_code = rd.rep_group_code
            AND rr.rep_group_code = rd.rep_group_code
            AND rd.daytime = p_daytime;

BEGIN
    FOR cur_rec IN c_report_runables(p_report_definition) LOOP
        IF ( otherConnTempParamWithoutValue(p_report_definition, p_parameter_name, p_daytime) = 'N' ) THEN
            DELETE tv_report_runable_param
            WHERE report_runable_no = cur_rec.report_runable_no
            AND parameter_name = p_parameter_name
            AND daytime = p_daytime;
        END IF;
    END LOOP;
END deleteReportRunableParam;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : deleteReportSetParam
-- Description  : Deletes the report parameter from all report sets (both report_set_report_param and report_set_param)
--                connected to the given report runnable.
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: REPORT_SET_PARAM
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE deleteReportSetParam(p_report_runable_no VARCHAR2, p_daytime DATE, p_parameter_name VARCHAR2)
--</EC-DOC>
IS

--Find report sets with report set parameter that can be deleted (not linked to other report runables)
CURSOR c_report_set_param(p_report_runable_no VARCHAR2, p_parameter_name VARCHAR2, p_daytime DATE) IS
    SELECT distinct rsl.report_set_no
    FROM report_set_list rsl
    WHERE rsl.report_runable_no = p_report_runable_no
        AND not exists (
               --rows where the parameter is connected to other runables in the current report set
               SELECT 1
               FROM
                   report_set_list rsl2,
                   report_runable rr,
                   report_runable_param rrp
               WHERE
                   rsl2.report_set_no = rsl.report_set_no
                   and rsl2.report_runable_no != p_report_runable_no
                   AND rr.report_runable_no = rsl2.report_runable_no
                   AND rrp.report_runable_no = rr.report_runable_no
                   AND rrp.parameter_name = p_parameter_name
                   AND rrp.daytime = p_daytime);

--Find all reports in report sets, connected to the given report runable.
CURSOR c_report_set_report_param(p_report_runable_no VARCHAR2) IS
    SELECT distinct report_set_no, ref_no
    from report_set_list rsl
    where report_runable_no = p_report_runable_no;

BEGIN
    -- Delete from report_set_param
    FOR cur_rec IN c_report_set_param(p_report_runable_no, p_parameter_name, p_daytime) LOOP
        DELETE FROM tv_report_set_param
        WHERE report_set_no = cur_rec.report_set_no
            AND parameter_name = p_parameter_name
            AND daytime = p_daytime;
    END LOOP;

    -- Delete parameter from report_set_report_param
    FOR cur_rec IN c_report_set_report_param(p_report_runable_no) LOOP
        DELETE tv_report_set_report_param
        WHERE report_set_no = cur_rec.report_set_no
            AND ref_no = cur_rec.ref_no
            AND parameter_name = p_parameter_name
            AND daytime = p_daytime;
    END LOOP;

END deleteReportSetParam;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : deleteReportDefParams
-- Description  : Delete all parameters from a version of report definition
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: REPORT_DEFINITION, REPORT_DEFINITION_PARAM
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE deleteReportDefParams(p_report_definition_no VARCHAR2, p_daytime DATE)
--</EC-DOC>
IS
BEGIN

    DELETE FROM tv_report_definition_param
    WHERE report_definition_no = p_report_definition_no
        AND daytime = p_daytime;

END deleteReportDefParams;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : insertReportDefParams
-- Description  : Insert all parameters in report definition given by the report template
--
--
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: REPORT_DEFINITION, REPORT_DEFINITION_PARAM
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE insertReportDefParams(p_report_template VARCHAR2,p_report_definition_no NUMBER, p_daytime DATE)
--</EC-DOC>
IS

-- Find all report parameters of the given template
CURSOR c_params_on_template(p_report_template VARCHAR2) IS
        SELECT parameter_name, parameter_type, parameter_sub_type, access_check_ind, sort_order
        FROM report_template_param
        WHERE parameter_type != 'REPORT_SYSTEM_PARAM'
        AND template_code = p_report_template;

BEGIN

    FOR cur_rec IN c_params_on_template(p_report_template) LOOP
        INSERT INTO tv_report_definition_param(report_definition_no, parameter_name, parameter_type, parameter_sub_type, access_check_ind, sort_order, daytime)
        VALUES (p_report_definition_no,cur_rec.parameter_name, cur_rec.parameter_type, cur_rec.parameter_sub_type, cur_rec.access_check_ind, cur_rec.sort_order, p_daytime);
    END LOOP;

END insertReportDefParams;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : InsertReportRunnableParams
-- Description  : Insert parameters for a new report runable
--
--
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: REPORT_DEFINITION, REPORT_DEFINITION_PARAM, REPORT_RUNABLE_PARAM
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE insertReportRunnableParams(p_report_runable_no NUMBER, p_report_group VARCHAR2,  p_user_id VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS

-- Find distinct report parameters in group without value
CURSOR c_latebinding_params_in_group(p_report_group VARCHAR2) IS
        SELECT distinct nvl(rdp.alias,rdp.parameter_name) as parameter_name, rdp.parameter_type, rdp.parameter_sub_type, rdp.access_check_ind, max(rdp.sort_order) as sort_order, rdp.daytime
        FROM report_definition rd, report_definition_param rdp
        WHERE rd.report_definition_no = rdp.report_definition_no
            AND rdp.parameter_value IS NULL
            AND ecbp_report.isReportDefInGroup(rd.report_definition_no,p_report_group) = 'Y'
            -- daytime cannot be null
            AND rdp.daytime IS NOT NULL
            group by nvl(rdp.alias,rdp.parameter_name),rdp.parameter_type, rdp.parameter_sub_type, rdp.access_check_ind, rdp.daytime;

        ln_no_param NUMBER;
BEGIN

        ln_no_param := 0;

        -- check to see if the report runable exist
        IF ec_report_runable.name(p_report_runable_no) IS NOT NULL THEN

           SELECT count(parameter_name)
           INTO ln_no_param
           FROM report_runable_param
           WHERE report_runable_no = p_report_runable_no;

           IF ln_no_param = 0 THEN

              FOR cur_rec IN c_latebinding_params_in_group(p_report_group) LOOP
              -- Insert the parameter in report runable param
                INSERT INTO tv_report_runable_param(report_runable_no, parameter_name, parameter_type, parameter_sub_type, access_check_ind, sort_order, daytime, created_by)
                VALUES (p_report_runable_no,cur_rec.parameter_name, cur_rec.parameter_type, cur_rec.parameter_sub_type, cur_rec.access_check_ind, cur_rec.sort_order, cur_rec.daytime,  p_user_id);
              END LOOP;
           END IF;
        END IF;
END insertReportRunnableParams;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : insertReportSetParams
-- Description  : Insert parameters in report set, based on parameters in the given report runable
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: REPORT_DEFINITION, REPORT_DEFINITION_PARAM, REPORT_RUNABLE_PARAM
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE insertReportSetParams(p_report_set_no NUMBER, p_ref_no NUMBER)
--</EC-DOC>
IS

-- Find report parameters in report runable, that does not already exists in report_set_param
-- Note: We cannot insert sort_order here. Diffrent reports could have the same parameter name with different sort_order.
CURSOR c_params_for_report_set(p_report_set_no NUMBER) IS
    -- all parameters in report_runable param
    ( SELECT rrp.parameter_name, rrp.parameter_type, rrp.parameter_sub_type, rrp.access_check_ind, rrp.daytime
    FROM report_runable_param rrp,
         report_set_list rsl
    WHERE
        rrp.report_runable_no = rsl.report_runable_no
        AND rsl.ref_no = p_ref_no
        AND rsl.report_set_no = p_report_set_no

    UNION ALL
    -- Add the PRINTER parameter for all versions
    SELECT 'PRINTER', 'EC_TABLE_TYPE', 'PRINTER', 'N', rrp2.daytime
    FROM report_runable_param rrp2,
         report_set_list rsl2
    WHERE
        rrp2.report_runable_no = rsl2.report_runable_no
        AND rsl2.ref_no = p_ref_no
        AND rsl2.report_set_no = p_report_set_no

    UNION ALL
    -- Add the constant parameters for all the versions
    SELECT  'SEND_MSG', 'BASIC_TYPE', 'BOOL', 'N', rrp3.daytime
    FROM report_runable_param rrp3,
         report_set_list rsl3
    WHERE
        rrp3.report_runable_no = rsl3.report_runable_no
        AND rsl3.ref_no = p_ref_no
        AND rsl3.report_set_no = p_report_set_no )

    MINUS
    -- all parameters in report_set_param
    SELECT rsp.parameter_name, rsp.parameter_type, rsp.parameter_sub_type, rsp.access_check_ind, rsp.daytime
    FROM report_set_param rsp
    WHERE rsp.report_set_no = p_report_set_no;


-- Find all report parameters in report runable
CURSOR c_params_for_reports(p_report_set_no NUMBER) IS
    SELECT rrp.parameter_name, rrp.parameter_type, rrp.parameter_sub_type, rrp.access_check_ind, rrp.sort_order, rrp.daytime
    FROM report_runable_param rrp,
         report_set_list rsl
    WHERE
        rrp.report_runable_no = rsl.report_runable_no
        AND rsl.ref_no = p_ref_no
        AND rsl.report_set_no = p_report_set_no;

BEGIN
     -- Insert parameters for the report set
     FOR cur_rec IN c_params_for_report_set(p_report_set_no) LOOP
        INSERT INTO report_set_param(report_set_no, parameter_name, parameter_type, parameter_sub_type, access_check_ind, daytime)
        VALUES (p_report_set_no, cur_rec.parameter_name, cur_rec.parameter_type, cur_rec.parameter_sub_type, cur_rec.access_check_ind, cur_rec.daytime);
     END LOOP;

     -- Insert parameters for the individual reports in the report set
     FOR cur_rec IN c_params_for_reports(p_report_set_no) LOOP
        INSERT INTO report_set_report_param(report_set_no, ref_no, parameter_name, parameter_type, parameter_sub_type, access_check_ind, sort_order, daytime )
        VALUES (p_report_set_no, p_ref_no, cur_rec.parameter_name, cur_rec.parameter_type, cur_rec.parameter_sub_type, cur_rec.access_check_ind, cur_rec.sort_order, cur_rec.daytime);
     END LOOP;


END insertReportSetParams;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : deleteReportRunnableParams
-- Description  : Delete parameters in report runable parameter
--
--
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: REPORT_RUNABLE_PARAM
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE deleteReportRunnableParams(p_report_runable_no NUMBER)
--</EC-DOC>
IS

BEGIN

    DELETE tv_report_runable_param where report_runable_no = p_report_runable_no;

END deleteReportRunnableParams;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : deleteReportSetParams
-- Description  : Delete parameters in report set parameter
--
--
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: REPORT_SET_PARAM
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE deleteReportSetParams(p_report_set_no number)
--</EC-DOC>
IS

BEGIN

    delete from report_set_param rsp where
      rsp.report_set_no = p_report_set_no
      and not exists (select '1' from
                 report_set_list rsl,
                 report_runable_param rrp
                 where
                      rrp.report_runable_no = rsl.report_runable_no and
                      rsl.report_set_no = p_report_set_no and
                      rsp.parameter_name = rrp.parameter_name)
      and not exists (select '1' from dual where rsp.parameter_name = 'PRINTER')
      and not exists (select '1' from dual where rsp.parameter_name = 'SEND_MSG')
      ;
END deleteReportSetParams;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : deleteReportSetReportParams
-- Description  : Delete parameters in report set report parameter, and from report set parameter, if they are not connected to other reports as well.
--
--
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: REPORT_SET_REPORT_PARAM
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE deleteReportSetReportParams(p_report_set_no NUMBER, p_ref_no NUMBER)
--</EC-DOC>
IS

BEGIN

      -- Delete all report parameters from report_set_param connected to given report, but only if it is not connected to other reports in the set.
      delete from report_set_param rsp
      where rsp.report_set_no = p_report_set_no
            and rsp.parameter_name NOT IN ('PRINTER', 'SEND_MSG')
            and not exists (
                 select '1'
                 from report_set_report_param rsrp,
                      report_set_param rsp2
                 where
                             rsrp.report_set_no = p_report_set_no
                             and rsrp.ref_no != p_ref_no
                             and rsrp.parameter_name = rsp2.parameter_name
                             and rsp2.parameter_name = rsp.parameter_name
                             and rsp2.report_set_no = p_report_set_no );


      -- Delete parameters for the report in report_set_report_param
     delete from report_set_report_param
     where report_set_no = p_report_set_no
     and ref_no = p_ref_no;

END deleteReportSetReportParams;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : deleteReportSetDependencies
-- Description  : Delete report set generations connected to a report set
--                (Note: Currently, reports in the report set need to be deleted manually. Trigger vil ensure to remove references from the generated reports. )
--
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: REPORT_SET_GENERATION
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE deleteReportSetDependencies(p_report_set_no NUMBER)
--</EC-DOC>
IS
BEGIN
    --Delete report set generations
    delete from report_set_generation
    where report_set_no = p_report_set_no;

    --Delete report set parameters (PRINTER and SEND_MSG)
    delete from report_set_param
    where report_set_no = p_report_set_no;

END deleteReportSetDependencies;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : delReportParams
-- Description  : Delete parameters from report_param table.
--
--
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: REPORT_PARAM
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE  delReportParam(p_report_no  number)

--</EC-DOC>
IS

BEGIN

   DELETE FROM report_param WHERE report_no= p_report_no;


END delReportParam;




--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isReportDefInGroup
-- Description    : Check if the given report definition is a part of the given group. Return 'Y' if it is.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

FUNCTION isReportDefInGroup(p_report_def_no VARCHAR2, p_report_group VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS

theParent VARCHAR2(32);

BEGIN

     SELECT rep_group_code INTO theParent FROM report_definition WHERE report_definition_no = p_report_def_no;

     WHILE theParent IS NOT NULL
     LOOP
           IF theParent = p_report_group THEN
              RETURN 'Y';
           END IF;
           SELECT parent_rep_group_code INTO theParent FROM report_definition_group WHERE rep_group_code = theParent;
     END LOOP;
     RETURN 'N';

END isReportDefInGroup;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : setReportTmplParam
-- Description    : Insert template parameter if it does not exist, update it otherwise.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

PROCEDURE setReportTmplParam(
      p_report_template_code VARCHAR2,
      p_report_parameter_name VARCHAR2,
      p_report_parameter_type VARCHAR2,
      p_report_parameter_sub_type VARCHAR2,
      p_mandatory_ind VARCHAR2,
      p_access_check_ind VARCHAR2,
      p_sort_order NUMBER,
      p_userid VARCHAR2
)
--</EC-DOC>
IS
  lr_report_template REPORT_TEMPLATE_PARAM%ROWTYPE;
BEGIN
  lr_report_template := ec_report_template_param.row_by_pk(p_report_template_code, p_report_parameter_name);
  IF lr_report_template.template_code IS NULL THEN
      INSERT INTO dv_report_template_param (template_code,parameter_name,parameter_type,parameter_sub_type,mandatory_ind,access_check_ind,sort_order,created_by)
      VALUES (p_report_template_code,p_report_parameter_name,p_report_parameter_type,p_report_parameter_sub_type,p_mandatory_ind,p_access_check_ind,p_sort_order,p_userid);
  ELSE
    IF lr_report_template.parameter_type<>Nvl(p_report_parameter_type, lr_report_template.parameter_type)
        OR lr_report_template.parameter_sub_type<>Nvl(p_report_parameter_sub_type, lr_report_template.parameter_sub_type)
        OR lr_report_template.mandatory_ind<>Nvl(p_mandatory_ind, lr_report_template.mandatory_ind)
        OR lr_report_template.access_check_ind<>Nvl(p_access_check_ind, lr_report_template.access_check_ind)
    THEN
      UPDATE dv_report_template_param
      SET parameter_type=p_report_parameter_type,
        parameter_sub_type=p_report_parameter_sub_type,
        mandatory_ind=p_mandatory_ind,
        access_check_ind=p_access_check_ind,
        last_updated_by=p_userid
      WHERE template_code = lr_report_template.template_code
      AND   parameter_name = lr_report_template.parameter_name;
    END IF;
  END IF;
END setReportTmplParam;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : insertReportDefinition
-- Description    : Insert report templates for the new version of the report definition.
--                  All templates connected to the previous version is inserted (if it exists).
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : -
--
---------------------------------------------------------------------------------------------------
PROCEDURE insertReportDefinition(
  p_rep_group_code VARCHAR2,
  p_daytime DATE
 )
 --</EC-DOC>
IS

CURSOR c_report_definition IS
SELECT a.report_definition_no, a.template_code, a.sort_order
FROM  report_definition a
WHERE a.rep_group_code = p_rep_group_code
    and a.daytime =
        (SELECT max(daytime)
        FROM report_def_grp_version
        WHERE rep_group_code = p_rep_group_code
              and daytime < p_daytime);
BEGIN

  FOR newreporttemplate IN c_report_definition LOOP
    INSERT INTO tv_report_definition(rep_group_code,template_code,sort_order,daytime)
    VALUES (p_rep_group_code,newreporttemplate.template_code,newreporttemplate.sort_order,p_daytime);
  END LOOP;

END insertReportDefinition;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : deleteReportDefinition
-- Description  : Delete a version of report_definition (parameters will be deleted by cascading triggers)
--
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: REPORT_DEFINITION and REPORT_DEFINITION_PARAM
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE deleteReportDefinition(p_rep_group_code VARCHAR2, p_daytime DATE)
--</EC-DOC>
IS
BEGIN

    DELETE FROM tv_report_definition WHERE rep_group_code = p_rep_group_code  AND daytime = p_daytime;

END deleteReportDefinition;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : insertReportPublishedParams
-- Description    : Insert default report published parameters for one generated report
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :REPORT, REPORT_RUNABLE, REPORT_DEFINITION, REPORT_DEFINITION_PARAM, REPORT_RUNABLE_PARAM
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : -
--
---------------------------------------------------------------------------------------------------
PROCEDURE insertReportPublishedParams(
  p_report_no NUMBER,
  p_report_published_no NUMBER
 )
 --</EC-DOC>
IS
-- find all report defintion parameters with access_check = 'Y' and has been set parameter value
CURSOR c_ac_definition_param IS
    SELECT rdp.parameter_sub_type, rdp.parameter_value
    FROM REPORT r, REPORT_RUNABLE rr, REPORT_DEFINITION rd, REPORT_DEFINITION_PARAM rdp
    WHERE r.report_no = p_report_no
        AND r.report_runable_no = rr.report_runable_no
        AND rr.rep_group_code = rd.rep_group_code
        AND r.daytime = rd.daytime
        AND rd.report_definition_no = rdp.report_definition_no
        AND rdp.access_check_ind = 'Y'
        AND rdp.parameter_value is not null;

-- find all report runable parameters with access_check = 'Y' and has been set parameter value
CURSOR c_ac_runable_param IS
    SELECT rrp.parameter_sub_type, rrp.parameter_value
    FROM REPORT r, REPORT_RUNABLE_PARAM rrp
    WHERE r.report_no = p_report_no
        AND r.report_runable_no = rrp.report_runable_no
        AND rrp.access_check_ind = 'Y'
        AND rrp.parameter_value is not null;

BEGIN

    -- insert all report defintion parameters with access_check = 'Y' to report_published_param with given report_published_no
    FOR ac_definition_param IN c_ac_definition_param LOOP
        INSERT INTO report_published_param(REPORT_PUBLISHED_NO,OBJECT_CLASS_NAME,PARAMETER_VALUE)
        VALUES (p_report_published_no,ac_definition_param.parameter_sub_type, ac_definition_param.parameter_value);
    END LOOP;
    -- insert all report runable parameters with access_check = 'Y' to report_published_param with given report_published_no
    FOR ac_runable_param IN c_ac_runable_param LOOP
        INSERT INTO report_published_param(REPORT_PUBLISHED_NO,OBJECT_CLASS_NAME,PARAMETER_VALUE)
        VALUES (p_report_published_no,ac_runable_param.parameter_sub_type, ac_runable_param.parameter_value);
    END LOOP;

END insertReportPublishedParams;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getHideInd
-- Description    : Check if the given report definition is to be hidden or not
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : report definition group
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

FUNCTION getHideInd(p_rep_group_code VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS

lv_return_value VARCHAR2(1);

BEGIN

     SELECT hide_ind INTO lv_return_value
     FROM report_definition_group
     WHERE rep_group_code = p_rep_group_code;

     IF lv_return_value IS NOT NULL THEN
       RETURN lv_return_value;
       else
         RETURN 'N';
      END IF;
END getHideInd;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : setReportSetGenStartTime
-- Description    : Sets the report set generation start time. This is done as an autonomous transaction,
--                  so that the start time is visible before all reports are finsihed generated.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : report_set_generation
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE setReportSetGenStartTime( p_seq_no NUMBER )
IS
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    update report_set_generation
    set GENERATION_STARTED = Ecdp_Timestamp.getCurrentSysdate()
    where seq_no = p_seq_no;
    commit;
END setReportSetGenStartTime;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : hasAccessToGeneratedReport
-- Description    : Check if the user has access to see the generated report
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : report, report_param
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION hasAccessToGeneratedReport( p_report_no NUMBER )
RETURN VARCHAR2
--</EC-DOC>
IS
lv_no_access_count NUMBER;

BEGIN
    lv_no_access_count := 0;
    SELECT count(report_no) INTO lv_no_access_count
    FROM report_param rp
    WHERE ROWNUM = 1
        AND rp.report_no = p_report_no
        AND rp.access_check_ind = 'Y'
        AND rp.parameter_value is not null
        AND rp.parameter_type = 'EC_OBJECT_TYPE'
        AND ecdp_objects.CheckObjectAccess(rp.parameter_value, rp.parameter_sub_type) = 'N';

    IF lv_no_access_count = 0 THEN
        RETURN 'Y';
    ELSE
        RETURN 'N';
    END IF;

END hasAccessToGeneratedReport;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : hasAccessToReportRunable
-- Description    : Check if the user has access to see the report runable.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : report, report_param
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION hasAccessToReportRunable( p_report_runable_no NUMBER, p_rep_group_code VARCHAR2, p_report_area_id VARCHAR2, p_nav_date DATE)
RETURN VARCHAR2
--</EC-DOC>
IS
lv_no_access_count NUMBER;

BEGIN

    -- Check access to Report Area (ringfencing)
    IF p_report_area_id is not null THEN
        select count(*) into lv_no_access_count
        from ov_report_area
        where ROWNUM = 1 AND object_id = p_report_area_id;

        IF lv_no_access_count = 0 THEN
            RETURN 'N';
        END IF;

    END IF;

    -- Check access to report parameters connected to object classes
    select count(*) into lv_no_access_count
    from report_def_grp_version rdgv,
       report_runable rr,
       report_definition_param rdp,
       report_definition rd
    where rr.rep_group_code = rdgv.rep_group_code
        and rd.rep_group_code = rdgv.rep_group_code
        and rdp.report_definition_no = rd.report_definition_no
        and rr.report_runable_no = p_report_runable_no
        and rdp.access_check_ind = 'Y'
        and rdp.parameter_value is not null
        and rdp.parameter_type = 'EC_OBJECT_TYPE'
        and rdp.daytime = ( select max(daytime)
                            from report_def_grp_version
                            where rep_group_code = p_rep_group_code
                                AND daytime <= p_nav_date )
        and ecdp_objects.CheckObjectAccess(rdp.parameter_value, rdp.parameter_sub_type) <> 'Y'
        and rownum = 1;

    IF lv_no_access_count = 0 THEN
        RETURN 'Y';
    ELSE
        RETURN 'N';
    END IF;
END hasAccessToReportRunable;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : hasAccessToPublishedReport
-- Description    : Check if the user has access to see the published report
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION hasAccessToPublishedReport( p_report_published_no NUMBER, p_report_no NUMBER )
RETURN VARCHAR2
--</EC-DOC>
IS
lv_no_access_count NUMBER;
lv_report_area VARCHAR2(250);

BEGIN

    -- Only do Check to Generated Reports, NOT to uploaded ones
    IF p_report_no is not null THEN
       -- Check access to Report Area (ringfencing)
       select report_area_id INTO lv_report_area
       from tv_report_runable rr, report r
       where r.report_no = p_report_no
           and rr.report_runable_no = r.report_runable_no;

       IF lv_report_area is not null THEN
           select count(*) into lv_no_access_count
           from ov_report_area
           where ROWNUM = 1 and object_id = lv_report_area;

          IF lv_no_access_count = 0 THEN
              RETURN 'N';
           END IF;
       END IF;
    END IF;

    -- Check access to publish report parameters
    SELECT count(report_published_no) INTO lv_no_access_count
    FROM report_published_param
    WHERE ROWNUM = 1
        and parameter_value is not null
        and report_published_no = p_report_published_no
        and ecdp_objects.CheckObjectAccess(parameter_value, object_class_name) = 'N';

    IF lv_no_access_count = 0 THEN
        RETURN 'Y';
    ELSE
        RETURN 'N';
    END IF;
END hasAccessToPublishedReport;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : Test plsql queries in jasper
---------------------------------------------------------------------------------------------------
PROCEDURE testJasperPlsql( emp_cursor out sys_refcursor )
--</EC-DOC>
IS
BEGIN
	open emp_cursor for
        select 'Testing text' as text from dual;

END testJasperPlsql;



END EcBp_Report;