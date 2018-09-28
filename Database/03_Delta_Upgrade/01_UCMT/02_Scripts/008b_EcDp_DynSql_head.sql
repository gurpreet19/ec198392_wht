CREATE OR REPLACE PACKAGE EcDp_DynSql IS
/**************************************************************
** Package:    EcDp_DynSql
**
** $Revision: 1.14 $
**
** Filename:   EcDp_DynSql.sql
**
** Part of :   EC Kernel
**
** Purpose:
**
** General Logic:
**
** Document References:
**
**
** Created:   	21.12.98  Arild Vervik, ISI AS
**
**
** Modification history:
**
**
** Date:      Whom:  Change description:
** --------   ----- --------------------------------------------
** 13.10.2004 AV     added 3 new functions SafeString, SafeNumber, safeDate
** 13.12.2005 AV   Support function converting an ID to anydata building up dynamic SQL
** 07.03.2006 DN   TI 3569: Added overloaded version of SafeBuild.
** 08.03.2006 AV   Added p_raise_error VARCHAR2 DEFAULT 'N' to SafeBuild procedure
** 11.08.2006 AV   Added new parameter to Safebuild, allowing user to spesify if parsing should
                   add linefeed after each line is structure, this is a default parameter, the default behaviour
                   remains unchanged
** 18.04.2007 HUS  Added AddSqlLines
** 28.08.2008 KEB  Added WriteDebugText
**************************************************************/

--
PROCEDURE execute_statement(
   p_statement      VARCHAR2
   ) ;

--

FUNCTION  execute_singlerow_date(
  p_statement varchar2
  )
RETURN DATE;

--

FUNCTION  execute_singlerow_varchar2(
  p_statement varchar2
  )
RETURN VARCHAR2;

--

FUNCTION  execute_singlerow_number(
  p_statement varchar2
  )
RETURN NUMBER;

--

FUNCTION date_to_string(p_daytime date
)
RETURN VARCHAR2;

FUNCTION SafeNumber(p_number NUMBER, p_datatype VARCHAR2 DEFAULT 'NUMBER')
RETURN VARCHAR2;

FUNCTION Safedate(p_date DATE)
RETURN VARCHAR2;

FUNCTION SafeString(p_string VARCHAR2)
RETURN VARCHAR2;

PROCEDURE PurgeRecycleBin;

PROCEDURE AddSqlLine(p_lines   IN OUT DBMS_SQL.varchar2a,
                     p_newline IN     VARCHAR2,
                     p_nowrap         VARCHAR2 DEFAULT 'N'   -- Don't wrap long lines if this flag is set = 'Y'
);

PROCEDURE AddSqlLines(p_lines    IN OUT DBMS_SQL.varchar2a,
                      p_newlines IN DBMS_SQL.varchar2a
);

PROCEDURE WriteDebugText(p_id_type VARCHAR2, p_sql VARCHAR2, p_debuglevel VARCHAR2);

PROCEDURE WriteTempText(p_id_type VARCHAR2, p_sql VARCHAR2);



PROCEDURE SafeBuild(p_object_name VARCHAR2,
                    p_object_type VARCHAR2,
                    p_lines       DBMS_SQL.varchar2a,
                    p_target      VARCHAR2 DEFAULT 'CREATE',
                    p_id          VARCHAR2 DEFAULT 'GENCODE',
                    p_raise_error VARCHAR2 DEFAULT 'N',
                    p_lfflg       VARCHAR2 DEFAULT 'N'  -- Should be set to 'Y' if dbms_sql.parse should add chr(10) after each line in p_lines
                    );



FUNCTION Anydata_to_String(p_datetype VARCHAR2,p_id VARCHAR2) RETURN VARCHAR2;



PROCEDURE RecompileInvalid;


PROCEDURE BackupAndDeleteTable(p_table_name VARCHAR2);


FUNCTION CompareTableStructure(p_table_1 varchar2,
                               p_table_2 varchar2,
                               p_ignore_columns varchar2) RETURN NUMBER;
                               
                                


PROCEDURE drop_dependent_constraints (p_table_name varchar2);	

END;
/

