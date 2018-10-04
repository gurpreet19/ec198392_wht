CREATE OR REPLACE PACKAGE BODY EcBp_Report IS
/**************************************************************
** Package:    EcBp_Report
**
** $Revision: 1.23.4.2 $
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
** Created:     08.11.05  Magnus Otter?
**
**
** Modification history:
**
**
** Date:     Whom:      Change description:
** --------  ---------  --------------------------------------------
** 22.11.05	  MOT       Referring to tables instead of class views
** 22.11.05   DN        Formatting and EC-DOC directives.
** 06.12.05   MOT       Added function isReportDefInGroup
** 06.01.06   MOT       Added insertReportRunnableParams and deleteReportRunnableParams
** 22.02.06   MOT       When adding a new parameter to a template: Not copying this to runable report
** 21.02.07   kaurrnar  ECPD 5045: Added SORT_ORDER in cursors
** 03.09.07   ottermag  Major changes due to Jira ecpd-6438
** 18.07.08   olberegi  Fixed cursors returning identical rows causing inique constraint violation
** 26.05.09   rajarsar  Updated updateReportParamFromDef, copyReportParam, insertReportDefParam, insertReportRunnableParams to add daytime and added insertReportDefinition and deleteReportDefinition
** 16.09.11   RJe				Added alias handling
**************************************************************/



/********************* Cursors *********************************/

-- Find all parameters in report definitions that are linked to the given report template and have the given parameter name
CURSOR gc_params(p_report_template VARCHAR2, p_parameter_name VARCHAR2)  IS
        SELECT DISTINCT rdp.report_definition_no, rdp.parameter_name, rdp.alias
        FROM report_definition rd, report_definition_param rdp
        WHERE rd.template_code = p_report_template
        AND rd.report_definition_no = rdp.report_definition_no
        AND rdp.parameter_name = p_parameter_name;


--Find parameters on all report runable for given report template and parameter name
CURSOR gc_report_runable_param(p_report_template VARCHAR2, p_parameter_name VARCHAR2) IS
        SELECT DISTINCT rr.report_runable_no, nvl(rdp.alias,rdp.parameter_name) as parameter_name
        FROM report_runable rr, report_definition_group rdg, report_definition rd,report_definition_param rdp
        WHERE rr.rep_group_code = rdg.rep_group_code
        AND rdg.rep_group_code = rd.rep_group_code
        AND ecbp_report.isReportDefInGroup(rd.report_definition_no,rdg.rep_group_code) = 'Y'
        AND rd.template_code = p_report_template
        AND rd.report_definition_no = rdp.report_definition_no
        AND rdp.parameter_name = p_parameter_name;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : createReportSystemParams
-- Description  : Instantiates all report system parameters associated with the current report system
--                into the REPORT_SYSTEM_PARAM class.
--
--
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
--
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
-- Procedure    : copyReportParam
-- Description  : Copies the report template parameter to the report definition
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
PROCEDURE copyReportParam(p_report_template VARCHAR2, p_parameter_name VARCHAR2, p_parameter_type VARCHAR2, p_parameter_sub_type VARCHAR2, p_access_check_ind VARCHAR2, p_sort_order NUMBER)
--</EC-DOC>
IS

-- Find all report definitions that are linked to the given report template
CURSOR c_definitions(p_report_template VARCHAR2) IS
        SELECT rd.report_definition_no, rd.daytime
        FROM report_definition rd
        WHERE rd.template_code = p_report_template;

--Find runables connected to given template
CURSOR c_report_runables(p_report_template VARCHAR2) IS
        SELECT DISTINCT rr.report_runable_no, rd.daytime
        FROM report_runable rr, report_definition_group rdg, report_definition rd
        WHERE rr.rep_group_code = rdg.rep_group_code
        AND rdg.rep_group_code = rd.rep_group_code
        AND ecbp_report.isReportDefInGroup(rd.report_definition_no,rdg.rep_group_code) = 'Y'
        AND rd.template_code = p_report_template;

--Find report sets for given report template where parameter name does not exists
CURSOR c_report_sets(p_report_template VARCHAR2, p_parameter_name VARCHAR2) IS
        SELECT DISTINCT rsl.report_set_no, rd.daytime
        FROM
             report_set_list rsl,
             report_runable rr,
             report_definition_group rdg,
             report_definition rd
        WHERE
            rsl.report_runable_no = rr.report_runable_no
        AND rr.rep_group_code = rdg.rep_group_code
        AND ecbp_report.isReportDefInGroup(rd.report_definition_no,rdg.rep_group_code) = 'Y'
        AND rd.template_code =p_report_template
        AND rsl.report_set_no NOT IN (
            SELECT  distinct rsl.report_set_no
            FROM
                 report_set_param rsp,
                 report_set_list rsl,
                 report_runable rr,
                 report_definition_group rdg,
                 report_definition rd
             WHERE
                 rsp.parameter_name = p_parameter_name
             AND rsp.report_set_no = rsl.report_set_no
             AND rsl.report_runable_no = rr.report_runable_no
             AND rr.rep_group_code = rdg.rep_group_code
             AND ecbp_report.isReportDefInGroup(rd.report_definition_no,rdg.rep_group_code) = 'Y'
             AND rd.template_code =p_report_template);

is_unique_parameter NUMBER;
BEGIN

   --Insert parameters into report definition
   FOR cur_rec IN c_definitions(p_report_template) LOOP

        INSERT INTO report_definition_param(report_definition_no, daytime, parameter_name, parameter_type, parameter_sub_type, access_check_ind, sort_order)
        VALUES (cur_rec.report_definition_no,cur_rec.daytime, p_parameter_name, p_parameter_type, p_parameter_sub_type, p_access_check_ind, p_sort_order);

   END LOOP;

   --Insert parameters into report runable
   FOR cur_rec IN c_report_runables(p_report_template) LOOP
    is_unique_parameter := 0;

     SELECT count(parameter_name)
     INTO is_unique_parameter
     FROM report_runable_param rrp
     WHERE rrp.report_runable_no = report_runable_no
     AND rrp.parameter_name = p_parameter_name;

     IF is_unique_parameter = 0 THEN
          INSERT INTO report_runable_param(report_runable_no, daytime, parameter_name, parameter_type, parameter_sub_type, access_check_ind)
          VALUES (cur_rec.report_runable_no,cur_rec.daytime, p_parameter_name, p_parameter_type, p_parameter_sub_type, p_access_check_ind);
     END IF;
   END LOOP;

   --Insert parameters into report set
   FOR cur_rec IN c_report_sets(p_report_template, p_parameter_name) LOOP

        INSERT INTO report_set_param(report_set_no, daytime, parameter_name, parameter_type, parameter_sub_type, access_check_ind)
        VALUES (cur_rec.report_set_no,cur_rec.daytime, p_parameter_name, p_parameter_type, p_parameter_sub_type, p_access_check_ind);

   END LOOP;

END copyReportParam;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : updateReportParam
-- Description  : Updates the report definition parameter and report runable parameter due to an update on the report template parameter
--
--
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: REPORT_TEMPLATE_PARAM, REPORT_DEFINITION_PARAM, REPORT_RUNABLE_PARAM
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
PROCEDURE updateReportParam(p_report_template VARCHAR2, p_new_parameter_name VARCHAR2,
          p_old_parameter_name VARCHAR2, p_parameter_type VARCHAR2, p_new_parameter_sub_type VARCHAR2,p_old_parameter_sub_type VARCHAR2, p_new_access_check_ind VARCHAR2, p_old_access_check_ind VARCHAR2, p_sort_order NUMBER)
--</EC-DOC>
IS

--Find parameters on all report sets for given report template and parameter name
CURSOR c_report_set_param(p_report_template VARCHAR2, p_parameter_name VARCHAR2) IS
        SELECT distinct rsp.report_set_no, nvl(rdp.alias,rdp.parameter_name) as parameter_name, rd.daytime
        FROM report_set_param rsp, report_set_list rsl, report_runable rr, report_definition_group rdg, report_definition rd, report_definition_param rdp
        WHERE rsp.report_set_no = rsl.report_set_no
        AND rsl.report_runable_no = rr.report_runable_no
        AND rr.rep_group_code = rdg.rep_group_code
        AND ecbp_report.isReportDefInGroup(rd.report_definition_no,rdg.rep_group_code) = 'Y'
        AND rd.template_code = p_report_template
        AND rd.report_definition_no = rdp.report_definition_no
        AND rdp.parameter_name = p_parameter_name
        AND rdp.alias IS NULL;

CURSOR gc_report_runable_param_alias(p_report_template VARCHAR2, p_parameter_name VARCHAR2) IS
        SELECT DISTINCT rr.report_runable_no, nvl(rdp.alias,rdp.parameter_name) as parameter_name
        FROM report_runable rr, report_definition_group rdg, report_definition rd,report_definition_param rdp
        WHERE rr.rep_group_code = rdg.rep_group_code
        AND rdg.rep_group_code = rd.rep_group_code
        AND ecbp_report.isReportDefInGroup(rd.report_definition_no,rdg.rep_group_code) = 'Y'
        AND rd.template_code = p_report_template
        AND rd.report_definition_no = rdp.report_definition_no
        AND rdp.parameter_name = p_parameter_name
        AND rdp.alias IS NULL;

BEGIN
    IF(p_new_parameter_sub_type = p_old_parameter_sub_type) THEN

        --report set
        FOR cur_rec IN c_report_set_param(p_report_template, p_old_parameter_name) LOOP

             UPDATE report_set_param set parameter_name = p_new_parameter_name, access_check_ind = p_new_access_check_ind
             WHERE report_set_no = cur_rec.report_set_no
             AND parameter_name = cur_rec.parameter_name;
        END LOOP;

       --report runable
        FOR cur_rec IN gc_report_runable_param_alias(p_report_template, p_old_parameter_name) LOOP

             UPDATE report_runable_param set parameter_name = p_new_parameter_name, access_check_ind = p_new_access_check_ind
             WHERE report_runable_no = cur_rec.report_runable_no
             AND parameter_name = p_old_parameter_name;
        END LOOP;

        --report definition
        FOR cur_rec IN gc_params(p_report_template, p_old_parameter_name) LOOP

            UPDATE report_definition_param set parameter_name = p_new_parameter_name, access_check_ind = p_new_access_check_ind
            WHERE report_definition_no = cur_rec.report_definition_no
            AND parameter_name = p_old_parameter_name;

        END LOOP;


    ELSE
        --report set
        FOR cur_rec IN c_report_set_param(p_report_template, p_old_parameter_name) LOOP

            -- Delete this parameter on all report runable using the given template
             DELETE report_set_param
             WHERE report_set_no = cur_rec.report_set_no
             AND parameter_name = cur_rec.parameter_name;


             -- Insert the parameter with the new name or new type/sub type. Note that the value itself will be cleared
             INSERT INTO report_set_param(report_set_no, parameter_name, parameter_type, parameter_sub_type, access_check_ind, daytime)
             VALUES (cur_rec.report_set_no,p_new_parameter_name, p_parameter_type, p_new_parameter_sub_type, p_new_access_check_ind, cur_rec.daytime);

        END LOOP;

       -- Update in report runable
        FOR cur_rec IN gc_report_runable_param(p_report_template, p_old_parameter_name) LOOP

            -- Delete this parameter on all report runable using the given template
             DELETE report_runable_param
             WHERE report_runable_no = cur_rec.report_runable_no
             AND parameter_name = cur_rec.parameter_name;


             -- Insert the parameter with the new name or new type/sub type. Note that the value itself will be cleared
             INSERT INTO report_runable_param(report_runable_no, parameter_name, parameter_type, parameter_sub_type, access_check_ind)
             VALUES (cur_rec.report_runable_no,p_new_parameter_name, p_parameter_type, p_new_parameter_sub_type, p_new_access_check_ind);

        END LOOP;

       -- Update in report definition
        FOR cur_rec IN gc_params(p_report_template, p_old_parameter_name) LOOP

              -- Delete this parameter on all definitions using the given template
            DELETE report_definition_param
            WHERE report_definition_no = cur_rec.report_definition_no
            AND parameter_name = cur_rec.parameter_name;

            -- Insert the parameter with the new name or new type/sub type. Note that the value itself will be cleared
            INSERT INTO report_definition_param(report_definition_no, parameter_name, parameter_type, parameter_sub_type, access_check_ind, alias, sort_order)
            VALUES (cur_rec.report_definition_no,p_new_parameter_name, p_parameter_type, p_new_parameter_sub_type, p_new_access_check_ind, cur_rec.alias, p_sort_order);

        END LOOP;

     END IF;

END updateReportParam;


---------------------------------------------------------------------------------------------------
-- Procedure    : updateReportParamFromDef
-- Description  :
--
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
PROCEDURE updateReportParamFromDef(p_report_definition_no NUMBER, p_parameter_name VARCHAR2, p_parameter_type VARCHAR2,
          p_parameter_sub_type VARCHAR2, p_new_parameter_value VARCHAR2, p_old_parameter_value VARCHAR2, p_new_alias VARCHAR2, p_old_alias VARCHAR2, p_daytime DATE, p_new_access_check_ind VARCHAR2, p_old_access_check_ind VARCHAR2)
--</EC-DOC>
IS

--Find report runable for given report definition
CURSOR c_report_runable(p_report_definition_no VARCHAR2) IS
        SELECT DISTINCT rr.report_runable_no
        FROM
             report_runable rr,
             report_definition_group rdg,
             report_definition rd
        WHERE
            rr.rep_group_code = rdg.rep_group_code
        AND rdg.rep_group_code = rd.rep_group_code
        AND ecbp_report.isReportDefInGroup(rd.report_definition_no,rdg.rep_group_code) = 'Y'
        AND rd.report_definition_no = p_report_definition_no;

--Find report runable for given report definition and where given parameter does exists
CURSOR c_report_runable_param(p_report_definition_no VARCHAR2, p_parameter_name VARCHAR2) IS
        SELECT DISTINCT rr.report_runable_no
        FROM
             report_runable rr,
             report_definition_group rdg,
             report_definition rd
        WHERE
            rr.rep_group_code = rdg.rep_group_code
        AND rdg.rep_group_code = rd.rep_group_code
        AND ecbp_report.isReportDefInGroup(rd.report_definition_no,rdg.rep_group_code) = 'Y'
        AND rd.report_definition_no = p_report_definition_no
        AND rr.report_runable_no NOT IN (
                   SELECT rr2.report_runable_no
                   FROM
                         report_runable_param rrp2,
                         report_runable rr2,
                         report_definition_group rdg2,
                         report_definition rd2
                   WHERE
                       rrp2.parameter_name = p_parameter_name
                   AND rrp2.report_runable_no = rr2.report_runable_no
                   AND rr2.rep_group_code = rdg2.rep_group_code
                   AND rdg2.rep_group_code = rd2.rep_group_code
                   AND ecbp_report.isReportDefInGroup(rd2.report_definition_no,rdg2.rep_group_code) = 'Y'
                   AND rd2.report_definition_no = p_report_definition_no);


--Find report runable for given report definition and parameter
CURSOR c_report_runable_alias(p_report_definition_no VARCHAR2) IS
        SELECT DISTINCT rr.report_runable_no
        FROM
             report_runable rr,
             report_definition_group rdg,
             report_definition rd
        WHERE
            rr.rep_group_code = rdg.rep_group_code
        AND rdg.rep_group_code = rd.rep_group_code
        AND ecbp_report.isReportDefInGroup(rd.report_definition_no,rdg.rep_group_code) = 'Y'
        AND rd.report_definition_no = p_report_definition_no;


--Find report set for given report definition where this parameter does not exists in other runables as well
CURSOR c_report_set1(p_report_definition_no VARCHAR2, p_parameter_name VARCHAR2) IS
        SELECT distinct rsl.report_set_no
        FROM
             report_set_list rsl,
             report_runable rr,
             report_definition_group rdg,
             report_definition rd
        WHERE
            rsl.report_runable_no = rr.report_runable_no
        AND rr.rep_group_code = rdg.rep_group_code
        AND rdg.rep_group_code = rd.rep_group_code
        AND ecbp_report.isReportDefInGroup(rd.report_definition_no,rdg.rep_group_code) = 'Y'
        AND rd.report_definition_no = p_report_definition_no
        AND rsl.report_set_no not in
        ( SELECT rsl2.report_set_no
                 FROM
                      report_set_param rsp2,
                      report_set_list rsl2,
                      report_runable rr2,
                      report_definition_group rdg2,
                      report_definition rd2
                 WHERE
                       rsp2.parameter_name = p_parameter_name
                   AND rsp2.report_set_no = rsl2.report_set_no
                   AND rsl2.report_set_no = rsl.report_set_no
                   AND rsl2.report_runable_no = rr2.report_runable_no
                   AND rr2.report_runable_no != rr.report_runable_no --from main select
                   AND rr2.rep_group_code = rdg2.rep_group_code
                   AND rdg2.rep_group_code = rd2.rep_group_code
                   AND ecbp_report.isReportDefInGroup(rd2.report_definition_no,rdg2.rep_group_code) = 'Y'
                   AND rd2.report_definition_no = p_report_definition_no);


--Find report set for given report definition and where parameter does not exists
CURSOR c_report_set2(p_report_definition_no VARCHAR2, p_parameter_name VARCHAR2) IS
        SELECT DISTINCT  rsl.report_set_no
        FROM
             report_set_list rsl,
             report_runable rr,
             report_definition_group rdg,
             report_definition rd
        WHERE
            rsl.report_runable_no = rr.report_runable_no
        AND rr.rep_group_code = rdg.rep_group_code
        AND rdg.rep_group_code = rd.rep_group_code
        AND ecbp_report.isReportDefInGroup(rd.report_definition_no,rdg.rep_group_code) = 'Y'
        AND rd.report_definition_no = p_report_definition_no
        AND rsl.report_set_no not in
        ( SELECT distinct rsl2.report_set_no
                 FROM
                      report_set_param rsp2,
                      report_set_list rsl2,
                      report_runable rr2,
                      report_definition_group rdg2,
                      report_definition rd2
                 WHERE
                       rsp2.parameter_name = p_parameter_name
                   AND rsp2.report_set_no = rsl2.report_set_no
                   AND rsl2.report_runable_no = rr2.report_runable_no
                   AND rr2.report_runable_no = rr.report_runable_no --from main select
                   AND rr2.rep_group_code = rdg2.rep_group_code
                   AND rdg2.rep_group_code = rd2.rep_group_code
                   AND ecbp_report.isReportDefInGroup(rd2.report_definition_no,rdg2.rep_group_code) = 'Y'
                   AND rd2.report_definition_no = p_report_definition_no);

--Find report set for given report definition where this parameter is not existing in other definitions
CURSOR c_report_set_alias(p_report_definition_no VARCHAR2, p_parameter_name VARCHAR2,p_new_parameter_name VARCHAR2) IS
     SELECT  distinct rsl.report_set_no
        FROM
             report_set_param rsp,
             report_set_list rsl,
             report_runable rr,
             report_definition_group rdg,
             report_definition rd
        WHERE
            rsp.parameter_name = p_parameter_name
        AND rsp.report_set_no = rsl.report_set_no
        AND rsl.report_runable_no = rr.report_runable_no
        AND rr.rep_group_code = rdg.rep_group_code
        AND rdg.rep_group_code = rd.rep_group_code
        AND ecbp_report.isReportDefInGroup(rd.report_definition_no,rdg.rep_group_code) = 'Y'
        AND rd.report_definition_no = p_report_definition_no
        AND rsl.report_set_no not in
        ( SELECT rsl2.report_set_no
                 FROM

                      report_set_list rsl2,
                      report_runable rr2,
                      report_definition_group rdg2,
                      report_definition rd2,
                      report_definition_param rdp2
                 WHERE
                       rsl2.report_set_no = rsl.report_set_no --from main select
                   AND rsl2.report_runable_no = rr2.report_runable_no
                   AND rr2.rep_group_code = rdg2.rep_group_code
                   AND rdg2.rep_group_code = rd2.rep_group_code
                   AND ecbp_report.isReportDefInGroup(rd2.report_definition_no,rdg2.rep_group_code) = 'Y'
                   AND rd2.report_definition_no != p_report_definition_no
                   AND rd2.report_definition_no = rdp2.report_definition_no
                   AND nvl(rdp2.alias,rdp2.parameter_name) = p_parameter_name)
        AND rsl.report_set_no not in
        ( SELECT rsl2.report_set_no
                 FROM
                      report_set_param rsp2,
                      report_set_list rsl2,
                      report_runable rr2,
                      report_definition_group rdg2,
                      report_definition rd2,
                      report_definition_param rdp2
                 WHERE
                       rsp2.parameter_name = p_new_parameter_name
                   AND rsp2.report_set_no = rsl2.report_set_no
                   AND rsl2.report_set_no = rsl.report_set_no --from main select
                   AND rsl2.report_runable_no = rr2.report_runable_no
                   AND rr2.rep_group_code = rdg2.rep_group_code
                   AND rdg2.rep_group_code = rd2.rep_group_code
                   AND ecbp_report.isReportDefInGroup(rd2.report_definition_no,rdg2.rep_group_code) = 'Y'
                   AND rd2.report_definition_no = p_report_definition_no
                   AND rd2.report_definition_no = rdp2.report_definition_no
                   AND nvl(rdp2.alias,rdp2.parameter_name) = p_new_parameter_name);


--Find report set for given report definition where this parameter exists in other definitions
CURSOR c_report_set_alias2(p_report_definition_no VARCHAR2, p_parameter_name VARCHAR2) IS
        SELECT DISTINCT rsl.report_set_no
        FROM
             report_set_list rsl,
             report_runable rr,
             report_definition_group rdg,
             report_definition rd
        WHERE
            rsl.report_runable_no = rr.report_runable_no
        AND rr.rep_group_code = rdg.rep_group_code
        AND rdg.rep_group_code = rd.rep_group_code
        AND ecbp_report.isReportDefInGroup(rd.report_definition_no,rdg.rep_group_code) = 'Y'
        AND rd.report_definition_no = p_report_definition_no
        AND rsl.report_set_no not in

        ( SELECT rsl2.report_set_no
                 FROM
                      report_set_param rsp2,
                      report_set_list rsl2

                 WHERE
                       rsp2.parameter_name = p_parameter_name -- new alias
                   AND rsp2.report_set_no = rsl2.report_set_no
                   AND rsl2.report_set_no = p_report_definition_no --from main select
                  );

--Find report set for given report definition where this parameter exists in other definitions
CURSOR c_report_set_alias3(p_report_definition_no VARCHAR2, p_parameter_name VARCHAR2, p_old_alias VARCHAR2) IS
        SELECT DISTINCT rsl.report_set_no
        FROM
             report_set_list rsl,
             report_runable rr,
             report_definition_group rdg,
             report_definition rd
        WHERE
            rsl.report_runable_no = rr.report_runable_no
        AND rr.rep_group_code = rdg.rep_group_code
        AND rdg.rep_group_code = rd.rep_group_code
        AND ecbp_report.isReportDefInGroup(rd.report_definition_no,rdg.rep_group_code) = 'Y'
        AND rd.report_definition_no = p_report_definition_no
        AND rsl.report_set_no not in
        ( SELECT rsl2.report_set_no
                 FROM
                      report_set_list rsl2,
                      report_runable rr2,
                      report_definition_group rdg2,
                      report_definition rd2,
                      report_definition_param rdp2
                 WHERE
                       rsl2.report_set_no = rsl.report_set_no --from main select
                   AND rsl2.report_runable_no = rr2.report_runable_no
                   AND rr2.rep_group_code = rdg2.rep_group_code
                   AND rdg2.rep_group_code = rd2.rep_group_code
                   AND ecbp_report.isReportDefInGroup(rd2.report_definition_no,rdg2.rep_group_code) = 'Y'
                   AND rd2.report_definition_no != p_report_definition_no
                   AND rd2.report_definition_no = rdp2.report_definition_no
                   AND nvl(rdp2.alias,rdp2.parameter_name) = p_old_alias) --old alias

                   AND rsl.report_set_no in
        ( SELECT rsl2.report_set_no
                 FROM
                      report_set_param rsp2,
                      report_set_list rsl2,
                      report_runable rr2,
                      report_definition_group rdg2,
                      report_definition rd2,
                      report_definition_param rdp2
                 WHERE
                       rsp2.parameter_name = p_old_alias--old alias
                   AND rsp2.report_set_no = rsl2.report_set_no
                   AND rsl2.report_set_no =rsl.report_set_no --from main select
                   AND rsl2.report_runable_no = rr2.report_runable_no
                   AND rr2.rep_group_code = rdg2.rep_group_code
                   AND rdg2.rep_group_code = rd2.rep_group_code
                   AND ecbp_report.isReportDefInGroup(rd2.report_definition_no,rdg2.rep_group_code) = 'Y'
                   AND rd2.report_definition_no = p_report_definition_no
                   AND rd2.report_definition_no = rdp2.report_definition_no
                   AND nvl(rdp2.alias,rdp2.parameter_name) = p_parameter_name); --current parameter

BEGIN

     IF (p_new_parameter_value IS NOT NULL AND p_old_parameter_value IS NULL) THEN
       --remove this param from report runable and report set. In report set, we must verify that no other runables are using this parameter

               FOR cur_rec IN c_report_runable(p_report_definition_no) LOOP

                 DELETE report_runable_param
                 WHERE report_runable_no = cur_rec.report_runable_no
                 AND parameter_name = nvl(p_old_alias,p_parameter_name);

              END LOOP;

              FOR cur_rec IN c_report_set1(p_report_definition_no,nvl(p_old_alias,p_parameter_name)) LOOP

                 DELETE report_set_param
                 WHERE report_set_no = cur_rec.report_set_no
                 AND parameter_name = nvl(p_old_alias,p_parameter_name);

              END LOOP;

     ELSIF (p_new_parameter_value IS NULL AND p_old_parameter_value IS NOT NULL) THEN
       --add this parameter to report runable and report set if it is not already existing
              FOR cur_rec IN c_report_runable_param(p_report_definition_no, nvl(p_new_alias,p_parameter_name)) LOOP
                 INSERT INTO report_runable_param(report_runable_no, parameter_name, parameter_type, parameter_sub_type, access_check_ind, daytime)
                 VALUES (cur_rec.report_runable_no,nvl(p_new_alias,p_parameter_name), p_parameter_type, p_parameter_sub_type, p_new_access_check_ind, p_daytime);
              END LOOP;

              FOR cur_rec IN c_report_set2(p_report_definition_no, nvl(p_new_alias,p_parameter_name)) LOOP
                INSERT INTO report_set_param(report_set_no, parameter_name, parameter_type, parameter_sub_type, access_check_ind, parameter_value, daytime)
               VALUES (cur_rec.report_set_no,nvl(p_new_alias,p_parameter_name), p_parameter_type, p_parameter_sub_type, p_new_access_check_ind, p_new_parameter_value, p_daytime);
              END LOOP;

     ELSIF (nvl(p_new_access_check_ind, ' ') != nvl(p_old_access_check_ind, ' ')) THEN
       --update Access Check in report runable param and report set param
              FOR cur_rec IN c_report_runable(p_report_definition_no) LOOP

                 UPDATE report_runable_param
                 SET access_check_ind = p_new_access_check_ind
                 WHERE report_runable_no = cur_rec.report_runable_no
                 AND parameter_name = nvl(p_old_alias,p_parameter_name);

              END LOOP;

              FOR cur_rec IN c_report_set1(p_report_definition_no,nvl(p_old_alias,p_parameter_name)) LOOP

                 UPDATE report_set_param
                 SET access_check_ind = p_new_access_check_ind
                 WHERE report_set_no = cur_rec.report_set_no
                 AND parameter_name = nvl(p_old_alias,p_parameter_name);

              END LOOP;
     END IF;


    IF ((p_new_alias IS NULL AND p_old_alias IS NOT NULL) OR (p_old_alias IS NULL AND p_new_alias IS NOT NULL) OR (p_new_alias != p_old_alias)) THEN

              FOR cur_rec IN c_report_runable_alias(p_report_definition_no) LOOP

                  UPDATE report_runable_param set parameter_name =  nvl(p_new_alias,p_parameter_name)
                  WHERE report_runable_no = cur_rec.report_runable_no
                  AND parameter_name = nvl(p_old_alias,p_parameter_name);

              END LOOP;

              FOR cur_rec IN c_report_set_alias(p_report_definition_no,nvl(p_old_alias,p_parameter_name),nvl(p_new_alias,p_parameter_name)) LOOP
                  --if old_alias = any of the existing parameters. Update if no other report definitions have this parameter as original.
                  --otherwice, insert new parameter!
                  --insert into t_temptext(id,line_number,text) values('1',1,nvl(p_old_alias,p_parameter_name) || 'next' || nvl(p_new_alias,p_parameter_name));
                  UPDATE report_set_param set parameter_name = nvl(p_new_alias,p_parameter_name)
                  WHERE report_set_no = cur_rec.report_set_no
                  AND parameter_name = nvl(p_old_alias,p_parameter_name);

              END LOOP;


              FOR cur_rec IN c_report_set_alias3(p_report_definition_no, p_parameter_name, nvl(p_old_alias,p_parameter_name)) LOOP
                  DELETE report_set_param
                  WHERE report_set_no = cur_rec.report_set_no
                  AND parameter_name = nvl(p_old_alias,p_parameter_name);
              END LOOP;


     END IF;


END updateReportParamFromDef;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : deleteReportParam
-- Description  : Deletes the report definition parameter, report runable parameter and report set parameter
--                due to a delete on the report template parameter
--
--
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: REPORT_TEMPLATE_PARAM, REPORT_DEFINITION_PARAM, REPORT_RUNABLE_PARAM, REPORT_SET_PARAM
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
PROCEDURE deleteReportParam(p_report_template VARCHAR2, p_parameter_name VARCHAR2)
--</EC-DOC>
IS

--Find all set parameters linked to given template and where other templates have no such parameter
CURSOR c_report_set_param_excl(p_report_template VARCHAR2, p_parameter_name VARCHAR2) IS
SELECT distinct rsp.report_set_no, nvl(rdp.alias,rdp.parameter_name) as parameter_name
        FROM
             report_set_param rsp,
             report_set_list rsl,
             report_runable rr,
             report_definition_group rdg,
             report_definition rd,
             report_definition_param rdp
        WHERE
            rsp.report_set_no = rsl.report_set_no
        AND rsl.report_runable_no = rr.report_runable_no
        AND rr.rep_group_code = rdg.rep_group_code
        AND ecbp_report.isReportDefInGroup(rd.report_definition_no,rdg.rep_group_code) = 'Y'
        AND rd.report_definition_no = rdp.report_definition_no
        AND rd.template_code = p_report_template
        AND rdp.parameter_name = p_parameter_name -- This is the parameter we are intending to delete
        AND nvl(rdp.alias,rdp.parameter_name) NOT IN  -- This is parameter from all other templates
            (       select
                          nvl(rdp2.alias,rdp2.parameter_name)
                    from
                         report_set_list rsl2,
                         report_runable rr2,
                         report_definition_group rdg2,
                         report_definition rd2,
                         report_definition_param rdp2
                    where
                        rsl2.report_set_no = rsl.report_set_no
                    AND rsl2.report_runable_no = rr2.report_runable_no
                    AND rr2.rep_group_code = rdg2.rep_group_code
                    AND ecbp_report.isReportDefInGroup(rd2.report_definition_no,rdg2.rep_group_code) = 'Y'
                    AND rd2.report_definition_no = rdp2.report_definition_no
                    AND rdp2.parameter_name = p_parameter_name
                    AND rd2.template_code NOT LIKE p_report_template);

BEGIN
    -- report set
    FOR cur_rec IN c_report_set_param_excl(p_report_template, p_parameter_name) LOOP
        DELETE report_set_param
        WHERE report_set_no = cur_rec.report_set_no
        AND parameter_name = cur_rec.parameter_name;

    END LOOP;
    -- Delete this parameter on all runables using the given template
    FOR cur_rec IN gc_report_runable_param(p_report_template, p_parameter_name) LOOP
        DELETE report_runable_param
        WHERE report_runable_no = cur_rec.report_runable_no
        AND parameter_name = cur_rec.parameter_name;

    END LOOP;

   -- Delete this parameter on all definitions using the given template
    FOR cur_rec IN gc_params(p_report_template, p_parameter_name) LOOP
        DELETE report_definition_param
        WHERE report_definition_no = cur_rec.report_definition_no
        AND parameter_name = cur_rec.parameter_name;

    END LOOP;


END deleteReportParam;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : deleteReportDefParam
-- Description  : Delete parameters from report definition given by the report template
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
PROCEDURE deleteReportDefParam(p_report_template VARCHAR2,p_report_definition_no NUMBER)
--</EC-DOC>
IS

-- Find all parameters of the given report definition that are linked to the given report template
CURSOR c_params_by_template(p_report_template VARCHAR2, p_report_definition_no NUMBER)  IS
        SELECT rdp.parameter_name, rdp.report_definition_no
        FROM report_definition rd, report_definition_param rdp
        WHERE rd.template_code = p_report_template
        AND rd.report_definition_no = rdp.report_definition_no
        AND rd.report_definition_no = p_report_definition_no;

BEGIN

    FOR cur_rec IN c_params_by_template(p_report_template, p_report_definition_no) LOOP
        -- Delete all parameters on the given definition using the given template
        DELETE report_definition_param
        WHERE parameter_name = cur_rec.parameter_name
        AND report_definition_no = cur_rec.report_definition_no;

    END LOOP;

END deleteReportDefParam;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : insertReportDefParam
-- Description  : Insert parameters in report definition given by the report template
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
PROCEDURE insertReportDefParam(p_report_template VARCHAR2,p_report_definition_no NUMBER, p_daytime DATE)
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
        -- Insert the parameter in report definition
        INSERT INTO report_definition_param(report_definition_no, parameter_name, parameter_type, parameter_sub_type, access_check_ind, sort_order, daytime)
        VALUES (p_report_definition_no,cur_rec.parameter_name, cur_rec.parameter_type, cur_rec.parameter_sub_type, cur_rec.access_check_ind, cur_rec.sort_order, p_daytime);

    END LOOP;

END insertReportDefParam;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : InsertReportRunnableParams
-- Description  : Insert parameters in report runable parameter
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
        SELECT distinct nvl(rdp.alias,rdp.parameter_name) as parameter_name, rdp.parameter_type, rdp.parameter_sub_type, rdp.access_check_ind, max(rdp.sort_order) as sort_order,
        rdp.daytime
        FROM report_definition rd, report_definition_param rdp
        WHERE ecbp_report.isReportDefInGroup(rd.report_definition_no,p_report_group) = 'Y'
        AND rd.report_definition_no = rdp.report_definition_no
        AND rdp.parameter_value IS NULL
    -- check if this must be not null
        AND rdp.daytime IS NOT NULL
        group by nvl(rdp.alias,rdp.parameter_name),rdp.parameter_type, rdp.parameter_sub_type, rdp.access_check_ind, rdp.daytime;

        ln_no_param NUMBER;
BEGIN

        ln_no_param := 0;

        -- check to see if the parent exist
        IF ec_report_runable.name(p_report_runable_no) IS NOT NULL THEN

           SELECT count(parameter_name)
           INTO ln_no_param
           FROM report_runable_param
           WHERE report_runable_no = p_report_runable_no;

           IF ln_no_param = 0 THEN

              FOR cur_rec IN c_latebinding_params_in_group(p_report_group) LOOP
              -- Insert the parameter in report definition

                INSERT INTO report_runable_param(report_runable_no, parameter_name, parameter_type, parameter_sub_type, access_check_ind, sort_order, daytime, created_by)
                VALUES (p_report_runable_no,cur_rec.parameter_name, cur_rec.parameter_type, cur_rec.parameter_sub_type, cur_rec.access_check_ind, cur_rec.sort_order, cur_rec.daytime,  p_user_id);
              END LOOP;
           END IF;
        END IF;
END insertReportRunnableParams;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : InsertReportSetParams
-- Description  : Insert parameters in report set
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
PROCEDURE InsertReportSetParams(p_report_set_no NUMBER)
--</EC-DOC>
IS

-- Find distinct report parameters in report runable
CURSOR c_latebinding_params_in_rr(p_report_set_no NUMBER) IS
       select parameter_name,
              parameter_type,
              parameter_sub_type,
              access_check_ind,
              daytime,
              rownum sort_order
              from (
          SELECT distinct rrp.parameter_name, rrp.parameter_type, rrp.parameter_sub_type, rrp.access_check_ind, rrp.daytime
          FROM report_runable_param rrp,
               report_runable rr,
               report_set_list rsl,
               report_set rs,
               report_set_param rsp
          WHERE
              rrp.report_runable_no = rr.report_runable_no
          AND rr.report_runable_no = rsl.report_runable_no
          AND rsl.report_set_no = rs.report_set_no
          AND rrp.daytime IS NOT NULL
          AND rs.report_set_no = rsp.report_set_no (+)
          AND NOT 'EXISTS' in (select 'EXISTS'
                               from report_set_param
                               where
                                   parameter_name = rrp.parameter_name
                               AND report_set_no = rs.report_set_no)
          AND rs.report_set_no = p_report_set_no
          UNION ALL
          -- Add the constant parameters for all the versions
          SELECT distinct 'PRINTER', 'EC_TABLE_TYPE', 'PRINTER', 'N', rd1.daytime from dual,
               report_runable rr2,
               report_set_list rsl2,
               report_definition rd1
          WHERE
           rr2.report_runable_no = rsl2.report_runable_no
           AND rsl2.report_set_no = p_report_set_no
           AND rr2.rep_group_code = rd1.rep_group_code
           AND rd1.daytime IS NOT NULL
          AND
          NOT 'EXISTS' in (select 'EXISTS' from report_set_param where parameter_name = 'PRINTER' and report_set_no = p_report_set_no )
          UNION ALL
          -- Add the constant parameters for all the versions
          SELECT  distinct 'SEND_MSG', 'BASIC_TYPE', 'BOOL', 'N', rd1.daytime from dual,
               report_runable rr2,
               report_set_list rsl2,
               report_definition rd1
          WHERE
           rr2.report_runable_no = rsl2.report_runable_no
           AND rsl2.report_set_no = p_report_set_no
           AND rr2.rep_group_code = rd1.rep_group_code
           AND rd1.daytime IS NOT NULL
          AND
          NOT 'EXISTS' in (select 'EXISTS' from report_set_param where parameter_name = 'SEND_MSG' and report_set_no = p_report_set_no)
          );
BEGIN

     FOR cur_rec IN c_latebinding_params_in_rr(p_report_set_no) LOOP
        -- Insert the parameter in report set param
        INSERT INTO report_set_param(report_set_no, parameter_name, parameter_type, parameter_sub_type, access_check_ind, daytime)
        VALUES (p_report_set_no, cur_rec.parameter_name, cur_rec.parameter_type, cur_rec.parameter_sub_type, cur_rec.access_check_ind, cur_rec.daytime);


    END LOOP;

END InsertReportSetParams;
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

    DELETE report_runable_param where report_runable_no = p_report_runable_no;

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
      INSERT INTO report_template_param (template_code,parameter_name,parameter_type,parameter_sub_type,mandatory_ind,access_check_ind,sort_order,created_by)
      VALUES (p_report_template_code,p_report_parameter_name,p_report_parameter_type,p_report_parameter_sub_type,p_mandatory_ind,p_access_check_ind,p_sort_order,p_userid);
  ELSE
    IF lr_report_template.parameter_type<>Nvl(p_report_parameter_type, lr_report_template.parameter_type)  OR
       lr_report_template.parameter_sub_type<>Nvl(p_report_parameter_sub_type, lr_report_template.parameter_sub_type) OR
       lr_report_template.mandatory_ind<>Nvl(p_mandatory_ind, lr_report_template.mandatory_ind) OR
       lr_report_template.access_check_ind<>Nvl(p_access_check_ind, lr_report_template.access_check_ind)
    THEN
      UPDATE report_template_param
      SET parameter_type=p_report_parameter_type
      ,   parameter_sub_type=p_report_parameter_sub_type
      ,   mandatory_ind=p_mandatory_ind
      ,   access_check_ind=p_access_check_ind
      ,   last_updated_by=p_userid
      WHERE template_code = lr_report_template.template_code
      AND   parameter_name = lr_report_template.parameter_name;
    END IF;
  END IF;
END setReportTmplParam;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : insertReportDefinition
-- Description    :
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

-- verify this statement below for the rownum = 1
CURSOR c_report_definition IS
SELECT a.report_definition_no, a.template_code,a.sort_order
FROM  report_definition a
WHERE a.rep_group_code = p_rep_group_code
AND rownum =1;

BEGIN

  FOR newreporttemplate IN c_report_definition LOOP

    INSERT INTO tv_report_definition(table_class_name, rep_group_code,template_code,sort_order,daytime)
    VALUES ('REPORT_DEFINITION', p_rep_group_code,newreporttemplate.template_code,newreporttemplate.sort_order,p_daytime);
  END LOOP;




END insertReportDefinition;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : deleteReportDefinition
-- Description  : Delete linked records in report_definition and report_definition_param
--
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
PROCEDURE deleteReportDefinition(p_rep_group_code VARCHAR2,p_daytime DATE)
--</EC-DOC>
IS


-- Find all parameters of the given report definition that are linked to the given report template
CURSOR c_params_by_report_def(p_rep_group_code VARCHAR2, p_daytime DATE)  IS
        SELECT rdp.parameter_name, rdp.report_definition_no
        FROM report_definition rd, report_definition_param rdp
        WHERE rd.rep_group_code = p_rep_group_code
        AND rd.daytime = p_daytime
        AND rd.report_definition_no = rdp.report_definition_no
        AND rdp.daytime = rd.daytime;

   lv2_param_name           VARCHAR2(32);
   ln_rep_def_no            NUMBER;


BEGIN



    FOR cur_rec IN c_params_by_report_def(p_rep_group_code, p_daytime) LOOP
        -- Delete all parameters on the given definition using the given template for that version
         ln_rep_def_no  := cur_rec.report_definition_no;
    END LOOP;

    DELETE FROM report_definition_param a WHERE a.daytime = p_daytime AND a.report_definition_no = ln_rep_def_no;
    DELETE FROM report_definition b WHERE b.rep_group_code = p_rep_group_code  AND b.daytime = p_daytime AND b.report_definition_no = ln_rep_def_no;

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
    INSERT INTO dv_report_published_param(class_name, REPORT_PUBLISHED_NO,OBJECT_CLASS_NAME,PARAMETER_VALUE)
    VALUES ('REPORT_PUBLISHED_PARAM', p_report_published_no,ac_definition_param.parameter_sub_type, ac_definition_param.parameter_value);
  END LOOP;
-- insert all report runable parameters with access_check = 'Y' to report_published_param with given report_published_no
  FOR ac_runable_param IN c_ac_runable_param LOOP
    INSERT INTO dv_report_published_param(class_name, REPORT_PUBLISHED_NO,OBJECT_CLASS_NAME,PARAMETER_VALUE)
    VALUES ('REPORT_PUBLISHED_PARAM', p_report_published_no,ac_runable_param.parameter_sub_type, ac_runable_param.parameter_value);
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

     SELECT hide_ind INTO lv_return_value FROM report_definition_group
            WHERE rep_group_code = p_rep_group_code;

     IF lv_return_value IS NOT NULL THEN
       RETURN lv_return_value;
       else
         RETURN 'N';
      END IF;


END getHideInd;

END EcBp_Report;