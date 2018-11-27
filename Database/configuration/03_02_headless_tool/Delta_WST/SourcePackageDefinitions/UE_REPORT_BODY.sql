CREATE OR REPLACE PACKAGE BODY ue_report IS
/******************************************************************************
** Package        :  ue_report, header part
**
** $Revision: 1.5 $
**
** Purpose        :  License specific package to provide customer specific report functions
**
** Documentation  :  www.energy-components.com
**
** Created  : 06.10.2004 Egil �berg
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- -------------------------------------------
** #.#   DD.MM.YYYY  <initials>
********************************************************************/


FUNCTION getZipFileName(
	p_report_no NUMBER,
	p_exec_order NUMBER
	)
RETURN VARCHAR2

IS

    cursor c_report_item (p_report_no number, p_exec_order number) is
    select
          rr.name name,
          ri.format_code,
          ri.report_definition_no
    from
        report_runable rr,
        report r,
        report_item ri
    where
         rr.report_runable_no = r.report_runable_no and
         r.report_no = ri.report_no and
         ri.report_no = p_report_no and
         ri.exec_order = p_exec_order
    ;

    cursor c_report_path (p_report_definition_no number) is
    select
           NVL(name, rep_group_code) AS NAME, rep_group_code
    from (
         select
             rdg.parent_rep_group_code, rdg.rep_group_code, rdg.name, rd.report_definition_no
         from
             report_definition_group rdg,
             report_definition rd
         where
              rd.rep_group_code (+) = rdg.rep_group_code
         )
    start with report_definition_no = p_report_definition_no connect by rep_group_code  =  prior parent_rep_group_code
    order by level desc
    ;

    cursor c_report_name (p_report_definition_no number) is
        select
            parameter_value
        from
            report_definition_param
        where
             parameter_name = 'ZipFileName' and
             report_definition_no = p_report_definition_no
     ;


ln_report_definition_no NUMBER;
lv_report_name          VARCHAR2(2000);
lv_format_code          VARCHAR2(2000);
lv_parameter_name       VARCHAR2(2000);
lv_path_sep             VARCHAR2(1) := '/';
lb_has_report_name      BOOLEAN :=false;


BEGIN

   lv_parameter_name := '';

   FOR cur_rec IN c_report_item(p_report_no, p_exec_order) LOOP
       ln_report_definition_no := cur_rec.report_definition_no;
       lv_report_name := cur_rec.name;
       lv_format_code := cur_rec.format_code;
   END LOOP;


   FOR cur_rec IN c_report_path(ln_report_definition_no) LOOP
       lv_parameter_name := lv_parameter_name || lv_path_sep || cur_rec.name;
   END LOOP;


   FOR cur_rec IN c_report_name(ln_report_definition_no) LOOP
       lv_parameter_name := lv_parameter_name || lv_path_sep || cur_rec.parameter_value || '.' || lv_format_code;
       lb_has_report_name := TRUE;
   END LOOP;

   IF lb_has_report_name = FALSE THEN
      IF p_exec_order > 0 THEN
            lv_parameter_name := lv_report_name || '_' || p_exec_order || '.' || lv_format_code;
      ELSE
            lv_parameter_name := lv_report_name || '.' || lv_format_code;
      END IF;
   END IF;

   RETURN lv_parameter_name;

END getZipFileName;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getAttachmentName
-- Description    : User exit function used by the report engine returning the file name for the generated report.
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
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getAttachmentName(	p_report_no NUMBER
) RETURN VARCHAR2
IS
--</EC-DOC>
BEGIN

	RETURN NULL;
END getAttachmentName;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : generateXml
-- Description    : User exit procedure used by the report engine when an xml report can be created in db
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       : The report template must use the template name /com.ec.frmw.report.screens/gen_xml_report_db
--					There must exist 7 XML_ARG<#>s. All Strings.
-- Behaviour      :	Typically the first argument will be used to route the call to the correct z package. The rest is used as needed
--					If some are numbers or date it can be converted to its proper data type. Note that dates will be on the iso format (2010-06-15T00:00:00).
---------------------------------------------------------------------------------------------------
FUNCTION generateXml(    p_arg1      VARCHAR2,
                         p_arg2      VARCHAR2,
                         p_arg3      VARCHAR2,
                         p_arg4      VARCHAR2,
                         p_arg5      VARCHAR2,
                         p_arg6      VARCHAR2,
                         p_arg7      VARCHAR2) RETURN CLOB
IS
--</EC-DOC>
	ctx dbms_xmlgen.ctxHandle;
	xml CLOB;

BEGIN

	RETURN NULL;

	-- Very simple example
	--ctx := dbms_xmlgen.newContext('some columns from a table');
	--dbms_xmlgen.setRowSetTag(ctx, 'CONTENT');
	--xml := dbms_xmlgen.getXML(ctx);
	--return xml;
END;

END ue_report;