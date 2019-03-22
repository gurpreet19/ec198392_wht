CREATE OR REPLACE PACKAGE BODY EcDp_Generate IS
/**************************************************************
** Package :               EcDp_Generate, body part
**
** Purpose :               code generation for ec packages
**
** Documentation :         www.energy-components.no
**
** Created :               23.01.2017
**
** Modification history:
**
** Date:    Whom: Change description:
** -------- ----- --------------------------------------------
**
***********************************************************************************************/
CURSOR c_table_columns (p_table_name IN VARCHAR2) IS
   SELECT table_name, column_name, data_type, nullable, column_id
   FROM user_tab_columns
   WHERE  table_name = p_table_name
   ORDER BY table_name, column_id;

CURSOR c_table_key_columns (p_table_name IN VARCHAR2) IS
   SELECT   uc.constraint_type, uc.constraint_name, uc.table_name, ucc.column_name, NULL AS data_type
   FROM     user_constraints uc, user_cons_columns ucc
   WHERE    uc.table_name = p_table_name
   AND      uc.constraint_type IN ('P','R','U')
   AND      ucc.owner = uc.owner
   AND      ucc.constraint_name = uc.constraint_name
   AND      ucc.table_name = uc.table_name
   -- We are only referring to FK column OBJECT_ID in the code, so we don't have to read the other FK columns
   AND     (uc.constraint_type <> 'R' OR ucc.column_name = 'OBJECT_ID')
   ORDER BY uc.constraint_name, decode(ucc.column_name, 'SUMMER_TIME',1,0), position;

CURSOR c_ctrl_object(cp_table VARCHAR2) IS
   SELECT Nvl(o.view_pk_table_name, o.object_name) AS table_name,
          o.object_name,
          o.view_pk_table_name,
          o.math,
          nvl(o.ec_package, 'Y') AS ec_package,
          nvl(o.pinc_trigger_ind, 'Y') AS pinc_trigger_ind
   FROM   ctrl_object o
   WHERE  o.object_name = Nvl(cp_table, o.object_name);

CURSOR c_ctrl_gen_functions(p_table VARCHAR2) IS
   SELECT table_name, column_name, alias_name, calc_type, mtd_average, mtd_cumulative, ytd_average, ytd_cumulative, ttd_average, ttd_cumulative, calc_formula,
          CASE WHEN calc_type != 'COLUMN' THEN Nvl(calc_formula, column_name) ELSE column_name END AS formula
   FROM   ctrl_gen_function
   WHERE  table_name = p_table
   AND    calc_type IN ('COLUMN','CALC');

TYPE t_table_columns IS TABLE OF c_table_columns%ROWTYPE;
TYPE t_table_key_columns IS TABLE OF c_table_key_columns%ROWTYPE;
TYPE t_ctrl_gen_function_rows IS TABLE OF c_ctrl_gen_functions%ROWTYPE;

TYPE t_alias_map IS TABLE OF VARCHAR2(30) INDEX BY VARCHAR2(30);
TYPE Varchar_30_M IS TABLE OF VARCHAR(30) INDEX BY VARCHAR2(30);

TYPE r_table_data IS RECORD (
   table_name VARCHAR2(30),
   cols       t_table_columns,
   jn_cols    t_table_columns,
   pk_cols    t_table_key_columns,
   uk_cols    t_table_key_columns,
   fk_cols    t_table_key_columns,
   ctrlObj    c_ctrl_object%ROWTYPE,
   genFns     t_ctrl_gen_function_rows,
   alias      t_alias_map,
   jnDataType Varchar_30_M,
   dataType   Varchar_30_M,
   isNullable Varchar_30_M
);

pv_package_header DBMS_SQL.varchar2a;
pv_package_body   DBMS_SQL.varchar2a;

-- Package variable that holds metadata for the "current table"
--
tbl  r_table_data;

-- Dashed line used in generated code
--
P_DASHED_LINE CONSTANT VARCHAR2(100) := '------------------------------------------------------------------------------------' || CHR(10);

-- IUR trigger body
--
IUR_TRIGGER_CODE CONSTANT VARCHAR2(1000) := q'[
DECLARE
o_rec_id          VARCHAR2(32) := :OLD.rec_id;
BEGIN
    IF Inserting THEN
      IF :new.rec_id IS NULL THEN
         :new.rec_id := SYS_GUID();
      END IF;
    ELSE
         IF o_rec_id is null THEN
            o_rec_id := SYS_GUID();
          END IF;
          IF NOT UPDATING('REC_ID') THEN
            :new.rec_id := o_rec_id;
          END IF;
     END IF;
END;
]';

-- Bitmasks values used to indicate which objects to generate.
--
I_PCK_MASK   CONSTANT INTEGER := Power(2, 0);
I_AP_MASK    CONSTANT INTEGER := Power(2, 1);
I_IUR_MASK   CONSTANT INTEGER := Power(2, 2);
I_JN_MASK    CONSTANT INTEGER := Power(2, 3);
I_IU_MASK    CONSTANT INTEGER := Power(2, 4);
I_AUT_MASK   CONSTANT INTEGER := Power(2, 5);
I_AIUDT_MASK CONSTANT INTEGER := Power(2, 6);
I_JN_INDEX_MASK CONSTANT INTEGER := Power(2, 7);

----------------------------------------------------------------------------------------
-- Return inpot string surrounded by single quotes
----------------------------------------------------------------------------------------
FUNCTION squote(p_string IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
   RETURN CHR(39) || p_string || CHR(39);
END squote;

----------------------------------------------------------------------------------------
-- Bitwise OR
----------------------------------------------------------------------------------------
FUNCTION bitor(x IN NUMBER, y IN NUMBER)
RETURN NUMBER
IS
BEGIN
    RETURN x + y - bitand(x,y);
END bitor;

----------------------------------------------------------------------------------------
-- Clear internal structure that holds the table meta data
----------------------------------------------------------------------------------------
PROCEDURE clearTbl
IS
BEGIN
   tbl.table_name := NULL;
   IF tbl.cols IS NOT NULL THEN
      tbl.cols.DELETE;
   END IF;
   IF tbl.jn_cols IS NOT NULL THEN
      tbl.jn_cols.DELETE;
   END IF;
   IF tbl.pk_cols IS NOT NULL THEN
      tbl.pk_cols.DELETE;
   END IF;
   IF tbl.uk_cols IS NOT NULL THEN
      tbl.uk_cols.DELETE;
   END IF;
   IF tbl.fk_cols IS NOT NULL THEN
      tbl.fk_cols.DELETE;
   END IF;
   IF tbl.genFns IS NOT NULL THEN
      tbl.genFns.DELETE;
   END IF;
   tbl.cols := t_table_columns();
   tbl.jn_cols := t_table_columns();
   tbl.pk_cols := t_table_key_columns();
   tbl.uk_cols := t_table_key_columns();
   tbl.fk_cols := t_table_key_columns();
   tbl.genFns := t_ctrl_gen_function_rows();
   tbl.dataType.DELETE;
   tbl.jnDataType.DELETE;
   tbl.isNullable.DELETE;
   tbl.alias.DELETE;
   tbl.ctrlObj := NULL;
END clearTbl;

----------------------------------------------------------------------------------------
-- Add input text as line in header buffer
----------------------------------------------------------------------------------------
PROCEDURE addHeaderLine(p_text VARCHAR2)
IS
BEGIN
   EcDp_DynSql.AddSqlLineNoWrap(pv_package_header, p_text);
END addHeaderLine;

----------------------------------------------------------------------------------------
-- Add input text as line in body buffer
----------------------------------------------------------------------------------------
PROCEDURE addBodyLine(p_text VARCHAR2)
IS
BEGIN
   EcDp_DynSql.AddSqlLineNoWrap(pv_package_body, p_text);
END addBodyLine;

----------------------------------------------------------------------------------------
-- Build package header (and clear header afterwards)
----------------------------------------------------------------------------------------
PROCEDURE buildPackageHeader(p_package_name IN VARCHAR2)
IS
BEGIN
  Ecdp_Dynsql.SafeBuildSupressErrors(p_package_name, 'PACKAGE', pv_package_header, 'EC_PACKAGE_HEADER');

  pv_package_header.DELETE;

END buildPackageHeader;

----------------------------------------------------------------------------------------
-- Build package body (and clear buffer afterwards)
----------------------------------------------------------------------------------------
PROCEDURE buildPackageBody(p_package_name IN VARCHAR2)
IS
BEGIN

  Ecdp_Dynsql.SafeBuildSupressErrors(p_package_name, 'PACKAGE', pv_package_body, 'EC_PACKAGE_BODY');

  pv_package_body.DELETE;

END buildPackageBody;

----------------------------------------------------------------------------------------
-- Build package view (and clear buffer afterwards)
----------------------------------------------------------------------------------------
PROCEDURE buildPackageView(p_view_name IN VARCHAR2, p_col_list IN VARCHAR2, p_table_name IN VARCHAR2)
IS
   lv_view DBMS_SQL.varchar2a;
BEGIN
  EcDp_DynSql.AddSqlLineNoWrap(lv_view,
              'CREATE OR REPLACE FORCE VIEW ' || p_view_name || ' AS' || CHR(10)||
              '----------------------------------------------------------------------------' || CHR(10) ||
              '-- View name: ' || p_view_name || CHR(10) ||
              '-- Generated by EC_GENERATE.' || CHR(10) ||
              '----------------------------------------------------------------------------' || CHR(10) ||
              'SELECT ' || p_col_list || CHR(10) || 'FROM ' || p_table_name);

  Ecdp_Dynsql.SafeBuildSupressErrors(p_view_name, 'VIEW', lv_view, 'EC_PACKAGE_VIEWS');
  lv_view.DELETE;
END buildPackageView;

----------------------------------------------------------------------------------------
-- Build package view (and clear buffer afterwards)
----------------------------------------------------------------------------------------
PROCEDURE buildTrigger(p_trigger_name IN VARCHAR2, p_trigger_code IN VARCHAR2)
IS
   lv_code DBMS_SQL.varchar2a;
BEGIN
   EcDp_DynSql.AddSqlLineNoWrap(lv_code, p_trigger_code);
   Ecdp_Dynsql.SafeBuildSupressErrors(p_trigger_name, 'TRIGGER', lv_code, 'EC_TRIGGERS');
   lv_code.DELETE;
END buildTrigger;

----------------------------------------------------------------------------------------
-- Build function signature from given parameters
----------------------------------------------------------------------------------------
FUNCTION getFnSignature(p_fn_name IN VARCHAR2, p_parameter_list IN VARCHAR2, p_fn_type IN VARCHAR2, p_separator IN VARCHAR2 DEFAULT ' ')
RETURN VARCHAR2
IS
BEGIN
   RETURN P_DASHED_LINE||'FUNCTION '||p_fn_name||p_parameter_list||p_separator||'RETURN '||p_fn_type;
END getFnSignature;

----------------------------------------------------------------------------------------
-- Return package header declaration and comments
----------------------------------------------------------------------------------------
FUNCTION getPackageHeadHeader(p_package_name IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
   RETURN 'CREATE OR REPLACE PACKAGE ec_'||p_package_name||' IS '||CHR(10)||
          P_DASHED_LINE||
          '-- Package: ec_'||p_package_name||CHR(10)||
          '-- Generated by EC_GENERATE.'||CHR(10)||
          CHR(10)||
          '-- DO NOT MODIFY THIS PACKAGE! Changes will be lost when the package is regenerated.'||CHR(10)||
          '-- Packages named pck_<component> will hold all manual written common code.'||CHR(10)||
          '-- Packages named <sysnam>_<component> will hold all code not beeing common.'||CHR(10)||
          P_DASHED_LINE||CHR(10);
END getPackageHeadHeader;

----------------------------------------------------------------------------------------
-- Return package body declaration and comments
----------------------------------------------------------------------------------------
FUNCTION getPackageBodyHeader(p_package_name IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
   RETURN 'CREATE OR REPLACE PACKAGE BODY ec_'||p_package_name||' IS'||CHR(10)||
          P_DASHED_LINE||
          '-- Package body: ec_'||p_package_name||CHR(10)||
          '-- Generated by EC_GENERATE.'||CHR(10)||
          P_DASHED_LINE||CHR(10);
END getPackageBodyHeader;

----------------------------------------------------------------------------------------
-- Return "cumulative" function body text
----------------------------------------------------------------------------------------
FUNCTION getCumFnBody(
         p_row IN c_ctrl_gen_functions%ROWTYPE,
         p_where_clause IN VARCHAR2,
         p_fn_name IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
   RETURN q'[IS
CURSOR c_calculate IS
   SELECT Sum(]'||Lower(p_row.formula)||q'[) result
   FROM ]'||p_row.table_name||CHR(10)||
   p_where_clause||q'[;

ln_return_val NUMBER := NULL;
BEGIN
   FOR mycur IN c_calculate LOOP
       ln_return_val := mycur.result;
   END LOOP;
   RETURN ln_return_val;
END ]'||p_fn_name||';'||CHR(10);
END getCumFnBody;

----------------------------------------------------------------------------------------
-- Return "average" function body text
----------------------------------------------------------------------------------------
FUNCTION getAveFnBody(
         p_row IN c_ctrl_gen_functions%ROWTYPE,
         p_where_clause IN VARCHAR2,
         p_fn_name IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
   RETURN q'[IS
CURSOR c_calculate IS
   SELECT Avg(]'||Lower(p_row.formula)||q'[) result
   FROM ]'||p_row.table_name||q'[
   ]'||p_where_clause||q'[;

ln_return_val NUMBER := NULL;
BEGIN
   FOR mycur IN c_calculate LOOP
       ln_return_val := mycur.result;
   END LOOP;
   RETURN ln_return_val;
END ]'||p_fn_name||q'[;
]';
END getAveFnBody;

----------------------------------------------------------------------------------------
-- Return "math" function body text
----------------------------------------------------------------------------------------
FUNCTION getMathFnBody(
         p_table_name IN VARCHAR2,
         p_column_name IN VARCHAR2,
         p_fn_name IN VARCHAR2,
         p_where_clause IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
   RETURN q'[IS

CURSOR c_calculate IS
   SELECT Decode(Upper(p_method),
              'SUM', Sum(]'||Lower(p_column_name)||q'[),
              'AVG', Avg(]'||Lower(p_column_name)||q'[),
              'MIN', Min(]'||Lower(p_column_name)||q'[),
              'MAX', Max(]'||Lower(p_column_name)||q'[),
              'COUNT', Count(]'||Lower(p_column_name)||q'[),
              NULL) result
   FROM ]'||p_table_name||q'[
   ]'||p_where_clause||q'[;

ln_return_val NUMBER := NULL;

BEGIN
   FOR mycur IN c_calculate LOOP
      ln_return_val := mycur.result;
   END LOOP;
   RETURN ln_return_val;
END ]'||p_fn_name||q'[;
]';
END getMathFnBody;

----------------------------------------------------------------------------------------
-- Return "count" function body text
----------------------------------------------------------------------------------------
FUNCTION getCountFnBody(p_table_name IN VARCHAR2, p_where_clause IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
    RETURN q'[ IS

CURSOR c_calculate IS
   SELECT Count(*) result
   FROM ]'||p_table_name||q'[
   ]'||p_where_clause||q'[;
ln_return_val NUMBER := NULL;

BEGIN
   FOR mycur IN c_calculate LOOP
      ln_return_val := mycur.result;
   END LOOP;
   RETURN ln_return_val;
END count_rows ;

]';
END getCountFnBody;

----------------------------------------------------------------------------------------
-- Return column function body text
----------------------------------------------------------------------------------------
FUNCTION getColumnFnBody(
  p_table_name IN VARCHAR2,
  p_column_name IN VARCHAR2,
  p_where_clause IN VARCHAR2,
  p_fn_name IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
   RETURN q'[IS
   v_return_val ]'||p_table_name||'.'||p_column_name||q'[%TYPE;
CURSOR c_col_val IS
   SELECT ]'||lower(p_column_name)||' col '||CHR(10)||
   'FROM '||p_table_name||q'[
   ]'||p_where_clause||q'[;
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
   RETURN v_return_val;
END ]'||p_fn_name||';'||CHR(10);

END getColumnFnBody;

----------------------------------------------------------------------------------------
-- Return date column function body text
----------------------------------------------------------------------------------------
FUNCTION getColumnFunctionDtBody(
  p_is_version_table IN BOOLEAN,
  p_table_name IN VARCHAR2,
  p_column_name IN VARCHAR2,
  p_where_clause_eq IN VARCHAR2,
  p_where_clause_le IN VARCHAR2,
  p_where_clause_lt IN VARCHAR2,
  p_where_clause_ge IN VARCHAR2,
  p_where_clause_gt IN VARCHAR2,
  p_where_clause_sub IN VARCHAR2,
  p_fn_name IN VARCHAR2)
RETURN VARCHAR2
IS
  lv2_where_clause_eq VARCHAR2(1000) :=
    '      ' || REPLACE(p_where_clause_eq, CHR(10), CHR(10) || '      ');

  lv2_where_clause_le VARCHAR2(1000) :=
    CASE WHEN p_is_version_table THEN
      '      WHERE object_id = p_object_id' || CHR(10) ||
      '      AND p_daytime >= daytime AND p_daytime < nvl(end_date, p_daytime + 1)'
    ELSE
      '      ' || REPLACE(p_where_clause_sub, CHR(10), CHR(10) || '      ') || CHR(10) ||
      '         (SELECT max(daytime) FROM ' || p_table_name || CHR(10) ||
      '         ' || REPLACE(p_where_clause_le, CHR(10), CHR(10) || '         ') || ')'
    END;

  lv2_where_clause_lt VARCHAR2(1000) :=
    CASE WHEN p_is_version_table THEN
      '      WHERE object_id = p_object_id' || CHR(10) ||
      '      AND daytime < p_daytime AND nvl(end_date, p_daytime) >= p_daytime'
    ELSE
      '      ' || REPLACE(p_where_clause_sub, CHR(10), CHR(10) || '      ') || CHR(10) ||
      '         (SELECT max(daytime) FROM ' || p_table_name || CHR(10) ||
      '         ' || REPLACE(p_where_clause_lt, CHR(10), CHR(10) || '         ') || ')'
    END;

  lv2_where_clause_ge VARCHAR2(1000) :=
    '      ' || REPLACE(p_where_clause_sub, CHR(10), CHR(10) || '      ') || CHR(10) ||
    '         (SELECT min(daytime) FROM ' || p_table_name || CHR(10) ||
    '         ' || REPLACE(p_where_clause_ge, CHR(10), CHR(10) || '         ') || ')';

  lv2_where_clause_gt VARCHAR2(1000) :=
    '      ' || REPLACE(p_where_clause_sub, CHR(10), CHR(10) || '      ') || CHR(10) ||
    '         (SELECT min(daytime) FROM ' || p_table_name || CHR(10) ||
    '         ' || REPLACE(p_where_clause_gt, CHR(10), CHR(10) || '         ') || ')';
BEGIN
  RETURN 'IS ' || CHR(10) ||
  '   lr_field ' || p_table_name || '.' || p_column_name || '%TYPE;' || CHR(10) ||
  'BEGIN ' || CHR(10) ||
  '   IF p_compare_oper = ''='' THEN ' || CHR(10) ||
  '      SELECT ' || p_column_name || ' INTO lr_field FROM ' || p_table_name || CHR(10) || CHR(10) || lv2_where_clause_eq || ';' || CHR(10) ||
  '   ELSIF p_compare_oper IN (''<='',''=<'') THEN ' || CHR(10) ||
  '      SELECT ' || p_column_name || ' INTO lr_field FROM ' || p_table_name || CHR(10) || CHR(10) || lv2_where_clause_le || ';' || CHR(10) ||
  '   ELSIF p_compare_oper = ''<'' THEN ' || CHR(10) ||
  '      SELECT ' || p_column_name || ' INTO lr_field FROM ' || p_table_name || CHR(10) || CHR(10) || lv2_where_clause_lt || ';' || CHR(10) ||
  '   ELSIF p_compare_oper IN (''>='',''=>'') THEN ' || CHR(10) ||
  '      SELECT ' || p_column_name || ' INTO lr_field FROM ' || p_table_name || CHR(10) || CHR(10) || lv2_where_clause_ge || ';' || CHR(10) ||
  '   ELSIF p_compare_oper = ''>'' THEN ' || CHR(10) ||
  '      SELECT ' || p_column_name || ' INTO lr_field FROM ' || p_table_name || CHR(10) || lv2_where_clause_gt || ';' || CHR(10) ||
  '   END IF;' || CHR(10) ||
  '   RETURN lr_field;' || CHR(10) ||
  '   EXCEPTION WHEN NO_DATA_FOUND THEN RETURN lr_field;' || CHR(10) ||
  'END ' || p_fn_name || ';' || CHR(10);
END getColumnFunctionDtBody;

----------------------------------------------------------------------------------------
-- Return row_by_pk function body text
----------------------------------------------------------------------------------------
FUNCTION getRowByPkFnBody(
  p_table_name IN VARCHAR2,
  p_row_cache_key IN VARCHAR2,
  p_where_clause IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
    RETURN q'[IS
   v_return_rec ]'||p_table_name||q'[%ROWTYPE;
   lv2_sc_key VARCHAR2(4000) := ]'||p_row_cache_key||q'[;
   CURSOR c_read_row IS
   SELECT *
   FROM ]'||p_table_name||q'[
   ]'||p_where_clause||q'[;
BEGIN
   IF NOT sg_row_cache.EXISTS(lv2_sc_key) THEN
      sg_row_cache.DELETE;
   FOR cur_rec IN c_read_row LOOP
      v_return_rec := cur_rec;
   END LOOP;
      sg_row_cache(lv2_sc_key) := v_return_rec;
   END IF;
   RETURN sg_row_cache(lv2_sc_key);
END row_by_pk;
]';
END getRowByPkFnBody;

----------------------------------------------------------------------------------------
-- Return row_by_pk function body text
----------------------------------------------------------------------------------------
FUNCTION getRowByPkFunctionDtBody(
  p_parameter_list_cursor IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
   RETURN 'IS ' || CHR(10) ||
           'BEGIN ' || CHR(10) ||
           '   RETURN row_by_rel_operator' || p_parameter_list_cursor || ';' || CHR(10) ||
           'END row_by_pk' || ';' || CHR(10);
END getRowByPkFunctionDtBody;

----------------------------------------------------------------------------------------
-- Return row_by_object_id function body text
----------------------------------------------------------------------------------------
FUNCTION getRowByObjectIdFnBody(
  p_table_name IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
    RETURN q'[IS
   v_return_rec ]'||p_table_name||q'[%ROWTYPE;
   lv2_sc_key VARCHAR2(33) := 'x'||p_object_id;
   CURSOR c_read_row IS
   SELECT *
   FROM ]'||p_table_name||q'[
   WHERE object_id = p_object_id;
BEGIN
   IF NOT sg_row_cache.EXISTS(lv2_sc_key) THEN
      sg_row_cache.DELETE;
   FOR cur_rec IN c_read_row LOOP
      v_return_rec := cur_rec;
   END LOOP;
      sg_row_cache(lv2_sc_key) := v_return_rec;
   END IF;
   RETURN sg_row_cache(lv2_sc_key);
END row_by_object_id;
]';
END getRowByObjectIdFnBody;

----------------------------------------------------------------------------------------
-- Return "row by relational operator" function body text
----------------------------------------------------------------------------------------
FUNCTION getRowByRelOpFnBody(
  p_table_name IN VARCHAR2,
  p_row_cache_key IN VARCHAR2,
  p_parameter_list_cursor IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
   RETURN ' IS' || CHR(10) ||
          '   lr_return_rec '||p_table_name||'%ROWTYPE;'|| CHR(10) ||
          '   lv2_sc_key VARCHAR2(4000) := '||p_row_cache_key||';'|| CHR(10) ||
          'BEGIN'|| CHR(10) ||
          '   IF NOT sg_row_cache.EXISTS(lv2_sc_key) THEN'|| CHR(10) ||
          '      sg_row_cache.DELETE;'|| CHR(10) ||
          '   IF p_compare_oper = '||squote('=')||' THEN'|| CHR(10) ||
          '      FOR cur_row IN c_equal'||p_parameter_list_cursor||' LOOP'|| CHR(10) ||
          '         lr_return_rec := cur_row;'|| CHR(10) ||
          '      END LOOP;'|| CHR(10) ||
          '   ELSIF p_compare_oper IN ('||squote('<=')||','||squote('=<')||') THEN'|| CHR(10) ||
          '      FOR cur_row IN c_less_equal'||p_parameter_list_cursor||' LOOP'|| CHR(10) ||
          '         lr_return_rec := cur_row;'|| CHR(10) ||
          '      END LOOP;'|| CHR(10) ||
          '   ELSIF p_compare_oper = '||squote('<')||' THEN'|| CHR(10) ||
          '      FOR cur_row IN c_less'||p_parameter_list_cursor||' LOOP'|| CHR(10) ||
          '         lr_return_rec := cur_row;'|| CHR(10) ||
          '      END LOOP;'|| CHR(10) ||
          '   ELSIF p_compare_oper IN ('||squote('>=')||','||squote('=>')||') THEN'|| CHR(10) ||
          '      FOR cur_row IN c_greater_equal'||p_parameter_list_cursor||' LOOP'|| CHR(10) ||
          '         lr_return_rec := cur_row;'|| CHR(10) ||
          '      END LOOP;'|| CHR(10) ||
          '   ELSIF p_compare_oper = '||squote('>')||' THEN'|| CHR(10) ||
          '      FOR cur_row IN c_greater'||p_parameter_list_cursor||' LOOP'|| CHR(10) ||
          '         lr_return_rec := cur_row;'|| CHR(10) ||
          '      END LOOP;'|| CHR(10) ||
          '   END IF;'|| CHR(10) ||
          '      sg_row_cache(lv2_sc_key) := lr_return_rec;'|| CHR(10) ||
          '   END IF;'|| CHR(10) ||
          '   RETURN sg_row_cache(lv2_sc_key);'|| CHR(10) ||
          'END row_by_rel_operator;'|| CHR(10);
END getRowByRelOpFnBody;

----------------------------------------------------------------------------------------
-- Return "prev/next daytime" function body text
----------------------------------------------------------------------------------------
FUNCTION getDaytimeFnBody(
  p_table_name IN VARCHAR2,
  p_sort_order IN VARCHAR2,
  p_where_clause IN VARCHAR2,
  p_fn_name IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
   RETURN q'[IS
CURSOR c_compute IS
   SELECT daytime
   FROM ]'||lower(p_table_name)||q'[
   ]'||p_where_clause||q'[
   ORDER BY daytime ]'||p_sort_order||q'[;
ld_return_val DATE := NULL;
BEGIN
   IF p_num_rows >= 1 THEN
      FOR cur_rec IN c_compute LOOP
         ld_return_val := cur_rec.daytime;
         IF c_compute%ROWCOUNT = p_num_rows THEN
            EXIT;
         END IF;
      END LOOP;
   END IF;
   RETURN ld_return_val;
END ]'||p_fn_name||q'[;
]';
END getDaytimeFnBody;

----------------------------------------------------------------------------------------
-- Return 'Y' if p_key_columns contains a column with the given name. Otherwise return 'N'.
----------------------------------------------------------------------------------------
FUNCTION hasKeyColumn(p_key_columns t_table_key_columns, p_column_name VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
  FOR i IN 1..p_key_columns.COUNT LOOP
    IF Upper(p_key_columns(i).column_name) = Upper(p_column_name) THEN
      RETURN 'Y';
    END IF;
  END LOOP;
  RETURN 'N';
END hasKeyColumn;

----------------------------------------------------------------------------------------
-- Return 'Y' if the "current table" has a unique key column with the given name.
-- Otherwise return 'N'.
----------------------------------------------------------------------------------------
FUNCTION hasUkColumn(p_column_name VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
  RETURN hasKeyColumn(tbl.uk_cols, p_column_name);
END hasUkColumn;

----------------------------------------------------------------------------------------
-- Return 'Y' if the "current table" has a primary key column with the given name.
-- Otherwise return 'N'.
----------------------------------------------------------------------------------------
FUNCTION hasPkColumn(p_column_name VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
  RETURN hasKeyColumn(tbl.pk_cols, p_column_name);
END hasPkColumn;

----------------------------------------------------------------------------------------
-- Return 'Y' if the "current table" has a foreign key column with the given name.
-- Otherwise return 'N'.
----------------------------------------------------------------------------------------
FUNCTION hasFkColumn(p_column_name VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
  RETURN hasKeyColumn(tbl.fk_cols, p_column_name);
END hasFkColumn;

----------------------------------------------------------------------------------------
-- Return 'Y' if the "current table" has a column with the given name. Otherwise return 'N'.
----------------------------------------------------------------------------------------
FUNCTION hasColumn(p_column_name VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
  IF tbl.dataType.EXISTS(p_column_name) THEN
     RETURN 'Y';
  END IF;
  RETURN 'N';
END hasColumn;

----------------------------------------------------------------------------------------
-- Return 'Y' if the "current table" has a journal table column with the given name.
-- Otherwise return 'N'.
--
-- NOTE: If the "current table" does not have a journal table, tbl.jn_cols will be empty.
----------------------------------------------------------------------------------------
FUNCTION hasJnColumn(p_column_name VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
  IF tbl.jnDataType.EXISTS(p_column_name) THEN
     RETURN 'Y';
  END IF;
  RETURN 'N';
END hasJnColumn;

----------------------------------------------------------------------------------------
-- This procedure creates object_id_by_uk function code. Generated for tables with a
-- primary key constraint consisting of OBJECT_ID and any related unique key constraint
-- with at least OBJECT_CODE in it.
----------------------------------------------------------------------------------------
FUNCTION getObjectIdFunction(p_table_data r_table_data, p_package_part VARCHAR2)
RETURN VARCHAR2
IS
  lv2_parameter_list  VARCHAR2(2000);
  lv2_cur_par_list    VARCHAR2(2000);
  lv2_cur_call_list   VARCHAR2(2000);
  lv2_qualifier_list  VARCHAR2(2000);
  lv2_plsql_code      VARCHAR2(4000);
  lv2_comma           VARCHAR2(10);
  lv2_and             VARCHAR2(10);
  lv2_uk_name         VARCHAR2(30);
  b_has_object_id_fn  BOOLEAN := FALSE;
BEGIN
   lv2_parameter_list := '';
   lv2_comma := '';
   lv2_and := '';

   -- Find unique constraint that contains OBJECT_CODE
   FOR i IN 1..p_table_data.uk_cols.COUNT LOOP
     IF p_table_data.uk_cols(i).column_name = 'OBJECT_CODE' THEN
       lv2_uk_name := p_table_data.uk_cols(i).constraint_name;
     END IF;
   END LOOP;

   -- Build parameter list from unique constraint that contains OBJECT_CODE
   FOR i IN 1..p_table_data.uk_cols.COUNT LOOP
     IF p_table_data.uk_cols(i).constraint_name = lv2_uk_name THEN
       b_has_object_id_fn := TRUE;
       lv2_parameter_list := lv2_parameter_list || lv2_comma || 'p_' || LOWER(p_table_data.uk_cols(i).column_name) || ' ' || p_table_data.uk_cols(i).data_type;
       lv2_cur_par_list := lv2_cur_par_list || lv2_comma || 'cp_' || LOWER(p_table_data.uk_cols(i).column_name) || ' ' || p_table_data.uk_cols(i).data_type;
       lv2_cur_call_list := lv2_cur_call_list || lv2_comma || 'p_' || LOWER(p_table_data.uk_cols(i).column_name);
       lv2_qualifier_list := lv2_qualifier_list || lv2_and || LOWER(p_table_data.uk_cols(i).column_name) || ' = cp_' || LOWER(p_table_data.uk_cols(i).column_name);

       lv2_comma := ', ';
       lv2_and := CHR(10) || '   AND ';
     END IF;
   END LOOP;

   IF b_has_object_id_fn THEN
      IF p_package_part = 'HEAD' THEN
         lv2_plsql_code := 'FUNCTION object_id_by_uk(' || lv2_parameter_list || ') RETURN ' || p_table_data.ctrlObj.object_name ||'.OBJECT_ID%TYPE';
         lv2_plsql_code := lv2_plsql_code || ';' || CHR(10);
      ELSE
         lv2_plsql_code := 'FUNCTION object_id_by_uk(' || lv2_parameter_list || ')' || CHR(10) || 'RETURN ' || p_table_data.ctrlObj.object_name ||'.OBJECT_ID%TYPE';
         lv2_plsql_code := lv2_plsql_code || CHR(10) ||
                        'IS' || CHR(10) ||
                        '   v_return_val ' || p_table_data.ctrlObj.object_name || '.OBJECT_ID%TYPE;' || CHR(10) ||
                        '   CURSOR c_col_val(' || lv2_cur_par_list || ') IS' || CHR(10) ||
                        '   SELECT object_id col' || CHR(10) ||
                        '   FROM ' || p_table_data.ctrlObj.object_name || CHR(10) ||
                        '   WHERE ' || lv2_qualifier_list || ';' || CHR(10) ||
                        'BEGIN' || CHR(10) ||
                        '   FOR cur_row IN c_col_val(' || lv2_cur_call_list || ') LOOP' || CHR(10) ||
                        '      v_return_val := cur_row.col;' || CHR(10) ||
                        '   END LOOP;' || CHR(10) ||
                        '   RETURN v_return_val;' || CHR(10) ||
                        'END object_id_by_uk;' || CHR(10);
      END IF;
   END IF;
   RETURN lv2_plsql_code;
END getObjectIdFunction;

----------------------------------------------------------------------------------
-- Procedure : generatePackageViews
-- Purpose   : Builds and generates the package views
----------------------------------------------------------------------------------
PROCEDURE generatePackageViews IS
  lv2_parameter_list   VARCHAR2(2000);

  lv2_view_name_m      VARCHAR2(32);
  lv2_view_name_y      VARCHAR2(32);
  lv2_view_name_t      VARCHAR2(32);
  lv2_view_col_list    VARCHAR2(2000);
  lv2_pk_list          VARCHAR2(2000);

  lv2_table_name       VARCHAR2(32);
  lv2_alias            VARCHAR2(32);

  ln_func_l            NUMBER := 25;
  ln_view_l            NUMBER := 28;

  ln_count             NUMBER;
  lv2_delim            VARCHAR2(10) := '';
  lv2_view             VARCHAR2(30) := Lower(Substr(tbl.ctrlObj.object_name, 1, ln_view_l));
BEGIN
   lv2_parameter_list := '';
   lv2_table_name := Nvl(tbl.ctrlObj.view_pk_table_name, tbl.ctrlObj.object_name);

   -----------------------------------------------------------
   -- BUILD LIST OF COLUMNS BEING PART OF PK
   -----------------------------------------------------------
   FOR i IN 1..tbl.pk_cols.COUNT LOOP
      IF tbl.pk_cols(i).column_name != 'SUMMER_TIME' THEN
      lv2_parameter_list := lv2_parameter_list || lv2_delim || Lower(tbl.pk_cols(i).column_name);
      lv2_delim := ', ';
      END IF;
   END LOOP;

   IF upper(tbl.ctrlObj.object_name) like '%DAY%' THEN
      lv2_view_name_m := Replace(lv2_view, 'day', 'mtd');
      lv2_view_name_y := Replace(lv2_view, 'day', 'ytd');
      lv2_view_name_t := Replace(lv2_view, 'day', 'ttd');
   ELSIF upper(tbl.ctrlObj.object_name) like '%MTH%' THEN
      lv2_view_name_m := Replace(lv2_view, 'mth', 'mmtd');     -- should not be used
      lv2_view_name_y := Replace(lv2_view, 'mth', 'mytd');
      lv2_view_name_t := Replace(lv2_view, 'mth', 'mttd');
   ELSE
      lv2_view_name_m := 'mtd_' || lv2_view;
      lv2_view_name_y := 'ytd_' || lv2_view;
      lv2_view_name_t := 'ttd_' || lv2_view;
   END IF;

   IF Lower(Substr(tbl.ctrlObj.object_name,1,2)) <> 'v_' THEN
      lv2_view_name_m := 'v_' || lv2_view_name_m;
      lv2_view_name_y := 'v_' || lv2_view_name_y;
      lv2_view_name_t := 'v_' || lv2_view_name_t;
   END IF;

   lv2_pk_list := lv2_parameter_list;
   lv2_parameter_list := '(' || lv2_parameter_list || ')';

   ------------------------------------------------------------
   -- CREATE MTD VIEWS
   ------------------------------------------------------------
   ln_count := 0;
   lv2_view_col_list := lv2_pk_list;
   FOR i IN 1..tbl.genFns.COUNT LOOP
      IF tbl.genFns(i).mtd_cumulative = 'Y' OR tbl.genFns(i).mtd_average = 'Y' THEN
         ln_count := ln_count + 1;
         lv2_alias := tbl.alias(tbl.genFns(i).column_name);
         IF tbl.genFns(i).mtd_cumulative = 'Y' THEN
            lv2_view_col_list := lv2_view_col_list || CHR(10) ||
                              ', ec_' || Lower(lv2_table_name) || '.cumm_' || Nvl(Lower(lv2_alias), Lower(Substr(tbl.genFns(i).column_name,1,ln_func_l))) || lv2_parameter_list ||
                              ' CUMM_' || Nvl(Upper(lv2_alias), Upper(Substr(tbl.genFns(i).column_name,1,ln_func_l)));
         END IF;

         IF tbl.genFns(i).mtd_average = 'Y' THEN
            lv2_view_col_list := lv2_view_col_list || CHR(10) ||
                              ', ec_' || Lower(lv2_table_name) || '.avem_' || Nvl(Lower(lv2_alias), Lower(Substr(tbl.genFns(i).column_name,1,ln_func_l))) || lv2_parameter_list ||
                              ' AVEM_' || Nvl(Upper(lv2_alias), Upper(Substr(tbl.genFns(i).column_name,1,ln_func_l)));
         END IF;
      END IF;
   END LOOP;

   IF ln_count > 0 THEN
       buildPackageView(lv2_view_name_m, lv2_view_col_list, tbl.ctrlObj.object_name);
   END IF;

   ------------------------------------------------------------
   -- CREATE YTD VIEWS
   ------------------------------------------------------------
   ln_count := 0;
   lv2_view_col_list := lv2_pk_list;
   FOR i IN 1..tbl.genFns.COUNT LOOP
      IF tbl.genFns(i).ytd_cumulative = 'Y' OR tbl.genFns(i).ytd_average = 'Y' THEN
         ln_count := ln_count + 1;
         lv2_alias := tbl.alias(tbl.genFns(i).column_name);
         IF tbl.genFns(i).ytd_cumulative = 'Y' THEN
            lv2_view_col_list := lv2_view_col_list || CHR(10) ||
                              ', ec_' || Lower(lv2_table_name) || '.cumy_' || Nvl(Lower(lv2_alias), Lower(Substr(tbl.genFns(i).column_name,1,ln_func_l))) || lv2_parameter_list ||
                              ' CUMY_' || Nvl(Upper(lv2_alias), Upper(Substr(tbl.genFns(i).column_name,1,ln_func_l)));
         END IF;

         IF tbl.genFns(i).ytd_average = 'Y' THEN
            lv2_view_col_list := lv2_view_col_list || CHR(10) ||
                              ', ec_' || Lower(lv2_table_name) || '.avey_' || Nvl(Lower(lv2_alias), Lower(Substr(tbl.genFns(i).column_name,1,ln_func_l))) || lv2_parameter_list ||
                              ' AVEY_' || Nvl(Upper(lv2_alias), Upper(Substr(tbl.genFns(i).column_name,1,ln_func_l)));
         END IF;
      END IF;
   END LOOP;

   IF ln_count > 0 THEN
       buildPackageView(lv2_view_name_y, lv2_view_col_list, tbl.ctrlObj.object_name);
   END IF;

     ------------------------------------------------------------
   -- CREATE TTD VIEWS
   ------------------------------------------------------------
   ln_count := 0;
   lv2_view_col_list := lv2_pk_list;
   FOR i IN 1..tbl.genFns.COUNT LOOP
      IF tbl.genFns(i).ttd_cumulative = 'Y' OR tbl.genFns(i).ttd_average = 'Y' THEN
         ln_count := ln_count + 1;
         lv2_alias := tbl.alias(tbl.genFns(i).column_name);
         IF tbl.genFns(i).ttd_cumulative = 'Y' THEN
            lv2_view_col_list := lv2_view_col_list || CHR(10) ||
                              ', ec_' || Lower(lv2_table_name) || '.cumt_' || Nvl(Lower(lv2_alias), Lower(Substr(tbl.genFns(i).column_name,1,ln_func_l))) || lv2_parameter_list ||
                              ' CUMT_' || Nvl(Upper(lv2_alias), Upper(Substr(tbl.genFns(i).column_name,1,ln_func_l)));
         END IF;

         IF tbl.genFns(i).ttd_average = 'Y' THEN
            lv2_view_col_list := lv2_view_col_list || CHR(10) ||
                              ', ec_' || Lower(lv2_table_name) || '.avet_' || Nvl(Lower(lv2_alias), Lower(Substr(tbl.genFns(i).column_name,1,ln_func_l))) || lv2_parameter_list ||
                              ' AVET_' || Nvl(Upper(lv2_alias), Upper(Substr(tbl.genFns(i).column_name,1,ln_func_l)));
         END IF;
      END IF;
   END LOOP;

   IF ln_count > 0 THEN
       buildPackageView(lv2_view_name_t, lv2_view_col_list, tbl.ctrlObj.object_name);
   END IF;
END generatePackageViews;

----------------------------------------------------------------------------------
-- Builds and generates the package header and body
----------------------------------------------------------------------------------
PROCEDURE generatePackage IS

  -- Local variables used in procedure
  lv2_parameter_list              VARCHAR2(2000);
  lv2_parameter_list_oper         VARCHAR2(2000); -- Parameter list included v_compare_operator DEFAULT '='
  lv2_parameter_list_cursor       VARCHAR2(2000); -- Parameter list to be used for cursor loop
  lv2_par_list_cursor_func        VARCHAR2(2000); -- Parameter list to be used calling cursor function
  lv2_parameter_list_period       VARCHAR2(2000); -- Parameter list to be used calling period function
  lv2_parameter_list_count        VARCHAR2(2000);
  lv2_parameter_list_n_rows       VARCHAR2(2000); -- Parameter list to be used calling prev or next daytime
  lv2_summer_time_flag            VARCHAR2(1);
  lv2_parameter_list_s            VARCHAR2(2000);
  lv2_parameter_list_oper_s       VARCHAR2(2000);
  lv2_parameter_list_cursor_s     VARCHAR2(2000);
  lv2_row_cache_key               VARCHAR2(2000);

  lv2_where_clause_m              VARCHAR2(2000);
  lv2_where_clause_y              VARCHAR2(2000);
  lv2_where_clause_t              VARCHAR2(2000);
  lv2_where_clause_p              VARCHAR2(2000);
  lv2_where_clause_n              VARCHAR2(2000);
  lv2_where_clause_pe             VARCHAR2(2000);
  lv2_where_clause_ne             VARCHAR2(2000);
  lv2_where_clause_sub            VARCHAR2(2000);
  lv2_where_clause                VARCHAR2(2000);
  lv2_where_clause_per            VARCHAR2(2000);
  lv2_where_clause_count          VARCHAR2(2000);
  lv2_where_clause_s              VARCHAR2(2000);

  lv2_daytime                     VARCHAR2(1);

  lv2_daytime_clause_m            VARCHAR2(2000);
  lv2_daytime_clause_y            VARCHAR2(2000);
  lv2_daytime_clause_t            VARCHAR2(2000);
  lv2_daytime_clause_p            VARCHAR2(2000);
  lv2_daytime_clause_n            VARCHAR2(2000);
  lv2_daytime_clause_pe           VARCHAR2(2000);
  lv2_daytime_clause_ne           VARCHAR2(2000);
  lv2_daytime_clause              VARCHAR2(2000);
  lv2_daytime_clause_sub          VARCHAR2(2000);
  lv2_daytime_clause_per          VARCHAR2(2000);

  lv2_table_name                  VARCHAR2(32);
  ln_package_l                    NUMBER := 28;
  lv2_package_name                VARCHAR2(30);
  lb_version_table                VARCHAR2(1);

  lv2_delim                       VARCHAR2(100);
  lv2_delim2                      VARCHAR2(100);
  lv2_delim3                      VARCHAR2(100);
  lv2_fn_name                     VARCHAR2(1000);
  lv2_fn_type                     VARCHAR2(255);

  -- Find if this is a version tables where we can make assumptions about end_date handling
  CURSOR c_version_table(p_table_name VARCHAR2) IS
    SELECT 1
    FROM  class_cnfg c
    WHERE c.class_type = 'OBJECT'
    AND   c.db_object_attribute = p_table_name
    AND   p_table_name LIKE '%VERSION';
BEGIN

    pv_package_body.DELETE;

    lv2_package_name := lower(substr(tbl.ctrlObj.object_name, 1, ln_package_l));

    ------------------------------------------------------------
    -- BUILD DAYTIME CLAUSES
    ------------------------------------------------------------
    lv2_daytime_clause_m := 'daytime BETWEEN to_date(to_char(p_daytime,''YYYYMM'') || ''01'',''YYYYMMDD'') AND p_daytime';
    lv2_daytime_clause_y := 'daytime BETWEEN to_date(to_char(p_daytime,''YYYY'') || ''0101'',''YYYYMMDD'') AND p_daytime';
    lv2_daytime_clause_t := 'daytime <= p_daytime';
    lv2_daytime_clause_p := 'daytime < p_daytime';
    lv2_daytime_clause_n := 'daytime > p_daytime';
    lv2_daytime_clause_pe := 'daytime <= p_daytime';
    lv2_daytime_clause_ne := 'daytime >= p_daytime';
    lv2_daytime_clause   := 'daytime = p_daytime';
    lv2_daytime_clause_sub   := 'daytime = '; -- used if subselect max/min is needed

    -- Daytime clause for Math - functions
    lv2_daytime_clause_per := 'daytime BETWEEN Nvl(p_from_day, to_date(''01-JAN-1900'',''dd-mon-yyyy'')) AND Nvl(p_to_day, p_from_day)';

    ------------------------------------------------------------
    -- CREATE PACKAGE BODY HEADER
    ------------------------------------------------------------
    addHeaderLine(getPackageHeadHeader(lv2_package_name));
    addBodyLine(getPackageBodyHeader(lv2_package_name));

    lv2_parameter_list := Null;
    lv2_parameter_list_cursor := Null;
    lv2_parameter_list_period := Null;
    lv2_par_list_cursor_func := Null;
    lv2_where_clause  := Null;
    lv2_table_name := Nvl(tbl.ctrlObj.view_pk_table_name, tbl.ctrlObj.object_name);
    lv2_daytime := hasPkColumn('DAYTIME');
    lv2_summer_time_flag := hasPkColumn('SUMMER_TIME');
    lv2_row_cache_key := '''x''';

    lb_version_table := 'N';

    FOR curTable IN c_version_table(lv2_table_name) LOOP
      lb_version_table := 'Y';
    END LOOP;

    addBodyLine(
        P_DASHED_LINE||
        'TYPE row_cache IS TABLE OF ' || tbl.ctrlObj.object_name || '%ROWTYPE INDEX BY VARCHAR2(4000);'||CHR(10)||
        'sg_row_cache row_cache;'||CHR(10));

    -----------------------------------------------------------
    -- BUILD LIST OF COLUMNS BEING PART OF PK
    -----------------------------------------------------------
    lv2_delim2 := 'WHERE ';
    lv2_delim3 := CHR(10);

    FOR i IN 1..tbl.pk_cols.COUNT LOOP
     IF tbl.pk_cols(i).column_name != 'SUMMER_TIME' THEN
       IF i = 1 THEN
         lv2_delim := CHR(10);
       ELSE
         lv2_delim := ', '||CHR(10);
       END IF;

       lv2_parameter_list := lv2_parameter_list || lv2_delim || '         p_' || Lower(tbl.pk_cols(i).column_name) || ' ' || tbl.pk_cols(i).data_type;
       lv2_parameter_list_cursor := lv2_parameter_list_cursor || lv2_delim || '         p_' || Lower(tbl.pk_cols(i).column_name);

       IF tbl.pk_cols(i).data_type = 'DATE' THEN
          lv2_row_cache_key := lv2_row_cache_key || '||to_char(p_' || Lower(tbl.pk_cols(i).column_name) || ', ''yyyy-mm-dd"T"hh24:mi:ss'')';
       ELSE
          lv2_row_cache_key := lv2_row_cache_key || '||p_' || Lower(tbl.pk_cols(i).column_name);
       END IF;

       IF tbl.pk_cols(i).column_name != 'DAYTIME' THEN
          lv2_where_clause := lv2_where_clause || lv2_delim2 || Lower(tbl.pk_cols(i).column_name) || ' = ' || 'p_' || Lower(tbl.pk_cols(i).column_name);
          lv2_parameter_list_period := lv2_parameter_list_period || lv2_delim3 || '         p_' || Lower(tbl.pk_cols(i).column_name) || ' ' || tbl.pk_cols(i).data_type;
          lv2_parameter_list_count := lv2_parameter_list_count || lv2_delim3 || '         p_' || Lower(tbl.pk_cols(i).column_name) || ' ' || tbl.pk_cols(i).data_type;

          lv2_delim2 :=  CHR(10) || 'AND ';
          lv2_delim3 := ',' || CHR(10);
       END IF;
     END IF;
    END LOOP;

    -----------------------------------------------------------
    -- INITIATE THE PARAMETERLISTS
    -----------------------------------------------------------
    IF lv2_parameter_list IS NOT NULL THEN
       lv2_parameter_list_oper := '(' || lv2_parameter_list || ',' || CHR(10) || '         p_compare_oper VARCHAR2 DEFAULT ''='')';
       lv2_par_list_cursor_func := '(' || lv2_parameter_list_cursor || ', p_compare_oper)';
       lv2_parameter_list_cursor   := '(' || lv2_parameter_list_cursor || ')';
       lv2_parameter_list_period := '(' || lv2_parameter_list_period || ',' || CHR(10) || '         p_from_day DATE,' || CHR(10) || '         p_to_day DATE,' || CHR(10) || '         p_method VARCHAR2 DEFAULT ''SUM'')';
       lv2_parameter_list_count := '(' || lv2_parameter_list_count || ',' || CHR(10) || '         p_from_day DATE,' || CHR(10) || '         p_to_day DATE)';
       lv2_parameter_list_n_rows := '(' || lv2_parameter_list || ',' || CHR(10) || '         p_num_rows NUMBER DEFAULT 1' || ')';
       lv2_parameter_list   := '(' || lv2_parameter_list || ')';
    END IF;

    IF lv2_daytime = 'Y' THEN
       IF lv2_where_clause IS NULL THEN
          lv2_where_clause_m := 'WHERE ' || lv2_daytime_clause_m;
          lv2_where_clause_y := 'WHERE ' || lv2_daytime_clause_y;
          lv2_where_clause_t := 'WHERE ' || lv2_daytime_clause_t;
          lv2_where_clause_p := 'WHERE ' || lv2_daytime_clause_p;
          lv2_where_clause_n := 'WHERE ' || lv2_daytime_clause_n;
          lv2_where_clause_pe:= 'WHERE ' || lv2_daytime_clause_pe;
          lv2_where_clause_ne:= 'WHERE ' || lv2_daytime_clause_ne;
          lv2_where_clause_sub:='WHERE ' || lv2_daytime_clause_sub;
          lv2_where_clause   := 'WHERE ' || lv2_daytime_clause;
          lv2_where_clause_per :='WHERE ' || lv2_daytime_clause_per;
          lv2_where_clause_count :='WHERE ' || lv2_daytime_clause_per;
       ELSE
          lv2_where_clause_m := lv2_where_clause || CHR(10) || 'AND ' || lv2_daytime_clause_m;
          lv2_where_clause_y := lv2_where_clause || CHR(10) || 'AND ' || lv2_daytime_clause_y;
          lv2_where_clause_t := lv2_where_clause || CHR(10) || 'AND ' || lv2_daytime_clause_t;
          lv2_where_clause_p := lv2_where_clause || CHR(10) || 'AND ' || lv2_daytime_clause_p;
          lv2_where_clause_n := lv2_where_clause || CHR(10) || 'AND ' || lv2_daytime_clause_n;
          lv2_where_clause_pe:= lv2_where_clause || CHR(10) || 'AND ' || lv2_daytime_clause_pe;
          lv2_where_clause_ne:= lv2_where_clause || CHR(10) || 'AND ' || lv2_daytime_clause_ne;
          lv2_where_clause_sub:=lv2_where_clause || CHR(10) || 'AND ' || lv2_daytime_clause_sub;
          lv2_where_clause_per:=lv2_where_clause || CHR(10) || 'AND ' || lv2_daytime_clause_per;
          lv2_where_clause_count:=lv2_where_clause || CHR(10) || 'AND ' || lv2_daytime_clause_per;
          lv2_where_clause   := lv2_where_clause || CHR(10) || 'AND ' || lv2_daytime_clause;
       END IF;

       lv2_row_cache_key := lv2_row_cache_key || '||p_compare_oper';
    ELSE
       IF lv2_where_clause IS NULL THEN
          lv2_where_clause_m := null;
          lv2_where_clause_y := null;
          lv2_where_clause_t := null;
          lv2_where_clause_p := null;
          lv2_where_clause_n := null;
          lv2_where_clause_pe:= null;
          lv2_where_clause_ne:= null;
          lv2_where_clause_sub:= null;
          lv2_where_clause   := null;
          lv2_where_clause_per:= null;
          lv2_where_clause_count:= null;
       ELSE
          lv2_where_clause_m := lv2_where_clause;
          lv2_where_clause_y := lv2_where_clause;
          lv2_where_clause_t := lv2_where_clause;
          lv2_where_clause_p := lv2_where_clause;
          lv2_where_clause_n := lv2_where_clause;
          lv2_where_clause_pe:= lv2_where_clause;
          lv2_where_clause_ne:= lv2_where_clause;
          lv2_where_clause_sub:= lv2_where_clause;
          lv2_where_clause   := lv2_where_clause;
          lv2_where_clause_per:= lv2_where_clause;
          lv2_where_clause_count:= lv2_where_clause;
       END IF;
    END IF;

    ------------------------------------------------------------
    -- CREATE COMMON CURSORS, IF TABLE CONTAINS 'DAYTIME'
    ------------------------------------------------------------
    IF lv2_daytime = 'Y' THEN

      ------------------------------------------------------------
      -- cursor for daytime = v_daytime
      ------------------------------------------------------------
      IF lv2_summer_time_flag = 'Y' then
         lv2_parameter_list_s := substr(lv2_parameter_list,1, LENGTH(lv2_parameter_list)-1) ||','|| CHR(10) || '          p_summertime VARCHAR2 DEFAULT NULL)';
         lv2_where_clause_s := lv2_where_clause ||CHR(10) || 'AND SUMMER_TIME = nvl(p_summertime, SUMMER_TIME)' || CHR(10) ||'ORDER BY SUMMER_TIME ';
      ELSE
      lv2_parameter_list_s := lv2_parameter_list;
      lv2_where_clause_s := lv2_where_clause;
      END IF;

      addBodyLine(
          P_DASHED_LINE ||
          'CURSOR c_equal ' || lv2_parameter_list_s ||' IS '|| CHR(10) ||
          '   SELECT * ' || CHR(10) ||
          '   FROM ' || tbl.ctrlObj.object_name || CHR(10) ||
          '   ' || lv2_where_clause_s || ';' || CHR(10));

      ------------------------------------------------------------
      -- cursor for daytime <= v_daytime
      ------------------------------------------------------------
      IF lb_version_table = 'N' THEN
            addBodyLine(
              P_DASHED_LINE ||
              'CURSOR c_less_equal ' || lv2_parameter_list_s ||' IS '|| CHR(10) ||
              '   SELECT * ' || CHR(10) ||
              '   FROM ' || tbl.ctrlObj.object_name || CHR(10) ||
              '   ' || lv2_where_clause_sub || CHR(10) ||
              '     (SELECT max(daytime) ' || CHR(10) ||
              '      FROM '|| tbl.ctrlObj.object_name || CHR(10) ||
              '      ' || lv2_where_clause_pe || ');' || CHR(10));
        ELSE
            addBodyLine(
              P_DASHED_LINE ||
              'CURSOR c_less_equal ' || lv2_parameter_list_s ||' IS '|| CHR(10) ||
              '   SELECT * ' || CHR(10) ||
              '   FROM ' || tbl.ctrlObj.object_name || CHR(10) ||
              '   WHERE object_id = p_object_id' || CHR(10) ||
              '   AND p_daytime >= daytime' || CHR(10) ||
              '   AND p_daytime  < nvl(end_date,p_daytime+1);' || CHR(10));
      END IF;

      ------------------------------------------------------------
      -- cursor for daytime < v_daytime
      ------------------------------------------------------------
      IF lb_version_table = 'N' THEN
            addBodyLine(
              P_DASHED_LINE ||
              'CURSOR c_less ' || lv2_parameter_list_s ||' IS '|| CHR(10) ||
              '   SELECT * ' || CHR(10) ||
              '   FROM ' || tbl.ctrlObj.object_name || CHR(10) ||
              '   ' || lv2_where_clause_sub || CHR(10) ||
              '     (SELECT max(daytime) ' || CHR(10) ||
              '      FROM '|| tbl.ctrlObj.object_name || CHR(10) ||
              '      ' || lv2_where_clause_p || ');' || CHR(10));
      ELSE
            addBodyLine(
              P_DASHED_LINE ||
              'CURSOR c_less ' || lv2_parameter_list_s ||' IS '|| CHR(10) ||
              '   SELECT * ' || CHR(10) ||
              '   FROM ' || tbl.ctrlObj.object_name || CHR(10) ||
              '   WHERE object_id = p_object_id' || CHR(10) ||
              '   AND daytime < p_daytime' || CHR(10) ||
              '   AND nvl(end_date,p_daytime) >= p_daytime;' || CHR(10));

      END IF;

        ------------------------------------------------------------
        -- cursor for daytime >= v_daytime
        ------------------------------------------------------------
        addBodyLine(
          P_DASHED_LINE ||
          'CURSOR c_greater_equal ' || lv2_parameter_list_s ||' IS '|| CHR(10) ||
          '   SELECT * ' || CHR(10) ||
          '   FROM ' || tbl.ctrlObj.object_name || CHR(10) ||
          '   ' || lv2_where_clause_sub || CHR(10) ||
          '     (SELECT min(daytime) ' || CHR(10) ||
          '      FROM '|| tbl.ctrlObj.object_name || CHR(10) ||
          '      ' || lv2_where_clause_ne || ');' || CHR(10));

        ------------------------------------------------------------
        -- cursor for daytime > v_daytime
        ------------------------------------------------------------
        addBodyLine(
          P_DASHED_LINE ||
          'CURSOR c_greater ' || lv2_parameter_list_s ||' IS '|| CHR(10) ||
          '   SELECT * ' || CHR(10) ||
          '   FROM ' || tbl.ctrlObj.object_name || CHR(10) ||
          '   ' || lv2_where_clause_sub || CHR(10) ||
          '     (SELECT min(daytime) ' || CHR(10) ||
          '      FROM '|| tbl.ctrlObj.object_name || CHR(10) ||
          '      ' || lv2_where_clause_n || ');' || CHR(10));
      END IF;

      ------------------------------------------------------------
      -- CREATE FUNCTION CODE
      ------------------------------------------------------------

      ------------------------------------------------------------
      -- count_rows
      ------------------------------------------------------------
      IF tbl.ctrlObj.math = 'Y' AND hasPkColumn('DAYTIME') = 'Y' THEN
         addHeaderLine(getFnSignature('count_rows', lv2_parameter_list_count, 'NUMBER')||';'||CHR(10));
         addBodyLine(getFnSignature('count_rows', lv2_parameter_list_count, 'NUMBER', CHR(10))||
                     getCountFnBody(tbl.ctrlObj.object_name, lv2_where_clause_count));
      END IF;

      ------------------------------------------------------------
      -- period functions
      ------------------------------------------------------------
      IF tbl.ctrlObj.math = 'Y' AND hasPkColumn('DAYTIME') = 'Y' THEN
        FOR i IN 1..tbl.cols.COUNT LOOP
          IF tbl.cols(i).data_type = 'NUMBER' AND Upper(tbl.cols(i).column_name) <> 'REV_NO' THEN
            lv2_fn_name := 'math_'||Lower(tbl.alias(tbl.cols(i).column_name));
            addHeaderLine(getFnSignature(lv2_fn_name, lv2_parameter_list_period, 'NUMBER')||';'||CHR(10));
            addBodyLine(getFnSignature(lv2_fn_name, lv2_parameter_list_period, 'NUMBER')||CHR(10)||
                        getMathFnBody(
                                   tbl.ctrlObj.object_name,
                                   tbl.cols(i).column_name,
                                   'math_'||Lower(tbl.alias(tbl.cols(i).column_name)),
                                   lv2_where_clause_per));
          END IF;
        END LOOP;
      END IF;

      ------------------------------------------------------------
      -- cummulative
      ------------------------------------------------------------
      FOR i IN 1..tbl.genFns.COUNT LOOP
        IF tbl.genFns(i).mtd_cumulative = 'Y' THEN
           lv2_fn_name := 'cumm_'||lower(tbl.alias(tbl.genFns(i).column_name));
           addHeaderLine(getFnSignature(lv2_fn_name, lv2_parameter_list, 'NUMBER')||';'||CHR(10));
           addBodyLine(getFnSignature(lv2_fn_name, lv2_parameter_list, 'NUMBER', CHR(10)) ||  ' ' ||
                getCumFnBody(tbl.genFns(i), lv2_where_clause_m, lv2_fn_name));
        END IF;
      END LOOP;

      FOR i IN 1..tbl.genFns.COUNT LOOP
        IF tbl.genFns(i).ytd_cumulative = 'Y' THEN
           lv2_fn_name := 'cumy_'||lower(tbl.alias(tbl.genFns(i).column_name));
           addHeaderLine(getFnSignature(lv2_fn_name, lv2_parameter_list, 'NUMBER')||';'||CHR(10));
           addBodyLine(getFnSignature(lv2_fn_name, lv2_parameter_list, 'NUMBER', CHR(10)) || ' ' ||
                getCumFnBody(tbl.genFns(i), lv2_where_clause_y, lv2_fn_name));
        END IF;
      END LOOP;

      FOR i IN 1..tbl.genFns.COUNT LOOP
        IF tbl.genFns(i).ttd_cumulative = 'Y' THEN
           lv2_fn_name := 'cumt_'||lower(tbl.alias(tbl.genFns(i).column_name));
           addHeaderLine(getFnSignature(lv2_fn_name, lv2_parameter_list, 'NUMBER')||';'||CHR(10));
           addBodyLine(
                getFnSignature(lv2_fn_name, lv2_parameter_list, 'NUMBER', CHR(10)) || ' ' ||
                getCumFnBody(tbl.genFns(i), lv2_where_clause_t, lv2_fn_name));
        END IF;
       END LOOP;

       ------------------------------------------------------------
       -- average
       ------------------------------------------------------------
       FOR i IN 1..tbl.genFns.COUNT LOOP
         IF tbl.genFns(i).mtd_average = 'Y' THEN
             lv2_fn_name := 'avem_'||lower(tbl.alias(tbl.genFns(i).column_name));
             addHeaderLine(getFnSignature(lv2_fn_name, lv2_parameter_list, 'NUMBER')||';'||CHR(10));
             addBodyLine(
                   getFnSignature(lv2_fn_name, lv2_parameter_list, 'NUMBER', CHR(10))|| ' ' ||
                   getAveFnBody(tbl.genFns(i),
                                   lv2_where_clause_m,
                                   lv2_fn_name));
         END IF;
       END LOOP;

       FOR i IN 1..tbl.genFns.COUNT LOOP
         IF tbl.genFns(i).ytd_average = 'Y' THEN
            lv2_fn_name := 'avey_'||lower(tbl.alias(tbl.genFns(i).column_name));
            addHeaderLine(getFnSignature(lv2_fn_name, lv2_parameter_list, 'NUMBER')||';'||CHR(10));
            addBodyLine(
                getFnSignature(lv2_fn_name, lv2_parameter_list, 'NUMBER', CHR(10))|| ' ' ||
                getAveFnBody(tbl.genFns(i),
                                   lv2_where_clause_y,
                                   lv2_fn_name));
         END IF;
       END LOOP;

       FOR i IN 1..tbl.genFns.COUNT LOOP
         IF tbl.genFns(i).ttd_average = 'Y' THEN
             lv2_fn_name := 'avet_'||lower(tbl.alias(tbl.genFns(i).column_name));
             addHeaderLine(getFnSignature(lv2_fn_name, lv2_parameter_list, 'NUMBER')||';'||CHR(10));
             addBodyLine(
                getFnSignature(lv2_fn_name, lv2_parameter_list, 'NUMBER', CHR(10))|| ' ' ||
                getAveFnBody(tbl.genFns(i),
                                   lv2_where_clause_t,
                                   lv2_fn_name));
         END IF;
       END LOOP;

       IF hasColumn('DAYTIME') = 'Y' THEN
          ------------------------------------------------------------
          -- prev_daytime
          ------------------------------------------------------------
          lv2_fn_name := 'prev_daytime';
          addHeaderLine(getFnSignature(lv2_fn_name, lv2_parameter_list_n_rows, 'DATE')||';'||CHR(10));
          addBodyLine(
                getFnSignature(lv2_fn_name, lv2_parameter_list_n_rows, 'DATE', CHR(10))||' '||
                getDaytimeFnBody(
                      tbl.ctrlObj.object_name,
                      'DESC',
                      lv2_where_clause_p,
                      lv2_fn_name)
                  );

          ------------------------------------------------------------
          -- prev_equal_daytime
          ------------------------------------------------------------
          lv2_fn_name := 'prev_equal_daytime';
          addHeaderLine(getFnSignature(lv2_fn_name, lv2_parameter_list_n_rows, 'DATE')||';'||CHR(10));
          addBodyLine(
                getFnSignature(lv2_fn_name, lv2_parameter_list_n_rows, 'DATE', CHR(10))||' '||
                getDaytimeFnBody(
                      tbl.ctrlObj.object_name,
                      'DESC',
                      lv2_where_clause_pe,
                      lv2_fn_name)
                  );

          ------------------------------------------------------------
          -- next_daytime
          ------------------------------------------------------------
          lv2_fn_name := 'next_daytime';
          addHeaderLine(getFnSignature(lv2_fn_name, lv2_parameter_list_n_rows, 'DATE')||';'||CHR(10));
          addBodyLine(
                getFnSignature(lv2_fn_name, lv2_parameter_list_n_rows, 'DATE', CHR(10))||' '||
                getDaytimeFnBody(
                      tbl.ctrlObj.object_name,
                      'ASC',
                      lv2_where_clause_n,
                      lv2_fn_name)
                  );

          ------------------------------------------------------------
          -- next_equal_daytime
          ------------------------------------------------------------
          lv2_fn_name := 'next_equal_daytime';
          addHeaderLine(getFnSignature(lv2_fn_name, lv2_parameter_list_n_rows, 'DATE')||';'||CHR(10));
          addBodyLine(
                getFnSignature(lv2_fn_name, lv2_parameter_list_n_rows, 'DATE', CHR(10))||' '||
                getDaytimeFnBody(
                      tbl.ctrlObj.object_name,
                      'ASC',
                      lv2_where_clause_ne,
                      lv2_fn_name)
                  );
        END IF;

        IF hasPkColumn('OBJECT_ID') = 'Y' AND tbl.pk_cols.COUNT = 1 THEN
            -- OBJECT_ID is the only PK column
            --
            IF hasUkColumn('OBJECT_CODE') = 'Y' THEN
               -- We have a unique constraint that includes OBJECT_CODE
               --
               addHeaderLine(CHR(10) || getObjectIdFunction(tbl, 'HEAD'));
               addBodyLine(getObjectIdFunction(tbl, 'BODY'));
            END IF;
        END IF;

        IF lv2_daytime = 'Y' THEN
            IF lv2_summer_time_flag = 'Y' then
                   lv2_parameter_list_oper_s := substr(lv2_parameter_list_oper,1, LENGTH(lv2_parameter_list_oper)-1) ||','|| CHR(10) || '        p_summertime VARCHAR2 DEFAULT NULL)';
                   lv2_parameter_list_cursor_s := substr(lv2_parameter_list_cursor,1, LENGTH(lv2_parameter_list_cursor)-1) ||','|| CHR(10) || '        p_summertime)';
                   lv2_row_cache_key := lv2_row_cache_key || '||p_summertime';
            ELSE
            lv2_parameter_list_oper_s := lv2_parameter_list_oper;
            lv2_parameter_list_cursor_s := lv2_parameter_list_cursor;
            END IF;

            lv2_fn_name := 'row_by_rel_operator';
            lv2_fn_type := tbl.ctrlObj.object_name || '%ROWTYPE';
            addHeaderLine(getFnSignature(lv2_fn_name, lv2_parameter_list_oper_s, lv2_fn_type)||';'||CHR(10));
            addBodyLine(
                  getFnSignature(lv2_fn_name, lv2_parameter_list_oper_s, lv2_fn_type, CHR(10))||CHR(10)||
                  getRowByRelOpFnBody(
                      tbl.ctrlObj.object_name,
                      lv2_row_cache_key,
                      lv2_parameter_list_cursor_s
                  ));

            ------------------------------------------------------------
            -- single columns, if daytime is present
            ------------------------------------------------------------
            FOR i IN 1..tbl.cols.COUNT LOOP
               IF tbl.cols(i).column_name NOT IN ('REV_NO','REV_TEXT','CREATED_BY','CREATED_DATE','LAST_UPDATED_BY','LAST_UPDATED_DATE') AND
                  hasPkColumn(tbl.cols(i).column_name) = 'N' THEN
                  lv2_fn_name := Lower(tbl.alias(tbl.cols(i).column_name));
                  lv2_fn_type := tbl.ctrlObj.object_name || '.' || tbl.cols(i).column_name || '%TYPE';
                  addHeaderLine(getFnSignature(lv2_fn_name, lv2_parameter_list_oper_s, lv2_fn_type)||';'||CHR(10));
                  addBodyLine(
                      getFnSignature(lv2_fn_name, lv2_parameter_list_oper_s, lv2_fn_type, CHR(10))||' '||
                      getColumnFunctionDtBody(
                              CASE WHEN lb_version_table = 'Y' THEN TRUE ELSE FALSE END,
                              tbl.ctrlObj.object_name,
                              tbl.cols(i).column_name,
                              lv2_where_clause_s,
                              lv2_where_clause_pe,
                              lv2_where_clause_p,
                              lv2_where_clause_ne,
                              lv2_where_clause_n,
                              lv2_where_clause_sub,
                              Lower(tbl.alias(tbl.cols(i).column_name))));
               END IF;
            END LOOP;

        ------------------------------------------------------------
        -- rowtype, if daytime is present
        ------------------------------------------------------------
            IF tbl.ctrlObj.view_pk_table_name IS NULL THEN
               lv2_fn_name := 'row_by_pk';
               lv2_fn_type := tbl.ctrlObj.object_name || '%ROWTYPE';
               addHeaderLine(getFnSignature(lv2_fn_name, lv2_parameter_list_oper, lv2_fn_type)||';'||CHR(10));
               addBodyLine(getFnSignature(lv2_fn_name, lv2_parameter_list_oper, lv2_fn_type, CHR(10)) ||' '||getRowByPkFunctionDtBody(lv2_par_list_cursor_func));
            END IF;
     ELSE
            ------------------------------------------------------------
            -- single columns, if daytime is not present
            ------------------------------------------------------------
        FOR i IN 1..tbl.cols.COUNT LOOP
           IF tbl.cols(i).column_name NOT IN ('REV_NO','REV_TEXT','CREATED_BY','CREATED_DATE','LAST_UPDATED_BY','LAST_UPDATED_DATE') AND
              hasPkColumn(tbl.cols(i).column_name) = 'N' THEN
               lv2_fn_name := Lower(tbl.alias(tbl.cols(i).column_name));
               lv2_fn_type := tbl.ctrlObj.object_name || '.' || tbl.cols(i).column_name || '%TYPE';
               addHeaderLine(getFnSignature(lv2_fn_name, lv2_parameter_list, lv2_fn_type)||';'||CHR(10));
               addBodyLine(
                  getFnSignature(lv2_fn_name, lv2_parameter_list, lv2_fn_type, CHR(10)) || ' ' ||
                  getColumnFnBody(
                          lv2_table_name,
                          tbl.cols(i).column_name,
                          lv2_where_clause,
                          Lower(tbl.alias(tbl.cols(i).column_name))));
           END IF;
        END LOOP;

        ------------------------------------------------------------
        -- rowtype
        ------------------------------------------------------------
        IF tbl.ctrlObj.view_pk_table_name IS NULL THEN
           lv2_fn_name := 'row_by_pk';
           lv2_fn_type := tbl.ctrlObj.object_name || '%ROWTYPE';
           addHeaderLine(getFnSignature(lv2_fn_name, lv2_parameter_list, lv2_fn_type)||';'||CHR(10));
           addBodyLine(
                  getFnSignature(lv2_fn_name, lv2_parameter_list, lv2_fn_type, CHR(10)) || ' ' ||
                  getRowByPkFnBody(
                          lv2_table_name,
                          lv2_row_cache_key,
                          lv2_where_clause));
              IF hasPkColumn('OBJECT_ID') = 'Y' AND tbl.pk_cols.COUNT = 1 THEN
                  lv2_fn_name := 'row_by_object_id';
                  lv2_fn_type := tbl.table_name || '%ROWTYPE';
                  addHeaderLine(getFnSignature(lv2_fn_name, '(p_object_id VARCHAR2)', lv2_fn_type)||';'||CHR(10));
                  addBodyLine(
                    getFnSignature(lv2_fn_name, '(p_object_id VARCHAR2)', lv2_fn_type, CHR(10))||' '||
                    getRowByObjectIdFnBody(lv2_table_name));
              END IF;
        END IF;
        END IF;

        ------------------------------------------------------------
        -- flush_row_cache
        ------------------------------------------------------------
        addHeaderLine(P_DASHED_LINE || 'PROCEDURE flush_row_cache;'||CHR(10)||CHR(10));
        addBodyLine(CHR(10)||P_DASHED_LINE||
q'[PROCEDURE flush_row_cache IS
BEGIN
   sg_row_cache.DELETE;
END flush_row_cache;

]');

        ------------------------------------------------------------
        -- CREATE PACKAGE FOOTER
        ------------------------------------------------------------
        addHeaderLine(CHR(10)||'END ec_'||lv2_package_name||';');
        addBodyLine('END ec_' || lv2_package_name || ';');

        buildPackageHeader('EC_' || lv2_package_name);
        buildPackageBody('EC_' || lv2_package_name);
END generatePackage;

----------------------------------------------------------------------------------
-- Return TRUE if the given table is on the "exception list"
----------------------------------------------------------------------------------
FUNCTION isExceptionTable(p_table_name IN VARCHAR2)
RETURN BOOLEAN
IS
   ln_count NUMBER := 0;
BEGIN
   SELECT count(*) INTO ln_count
   FROM   ctrl_object
   WHERE  object_name = p_table_name
   AND    nvl(pinc_trigger_ind, 'Y') = 'N';
   RETURN ln_count > 0 OR p_table_name = 'CTRL_OBJECT' OR p_table_name = 'CTRL_PINC';
END isExceptionTable;

----------------------------------------------------------------------------------
-- Return TRUE if the given trigger exists
----------------------------------------------------------------------------------
FUNCTION existsTrigger(p_trigger_name IN VARCHAR2)
RETURN BOOLEAN
IS
   ln_count NUMBER := 0;
BEGIN
   SELECT count(*) INTO ln_count
   FROM   user_triggers
   WHERE  trigger_name = p_trigger_name;
   RETURN ln_count > 0;
END existsTrigger;

----------------------------------------------------------------------------------------
-- DATE column in PINC triggers
----------------------------------------------------------------------------------------
FUNCTION pincTriggerDateColumn(p_column_name IN VARCHAR2, p_old_or_new IN VARCHAR2, p_is_key IN VARCHAR2, p_col_prefix IN VARCHAR2)
RETURN VARCHAR2
IS
   lv2_line VARCHAR2(1000);
BEGIN
   lv2_line := q'[        dbms_lob.append(lcl_row,utl_raw.cast_to_raw(']'||p_column_name||q'[='|| to_char(:]'||p_old_or_new||'.'||p_column_name||q'[,'yyyy.mm.dd hh24:mi:ss') ||';'));
]';
   IF p_is_key = 'Y' THEN
      lv2_line := lv2_line || '        ' || p_col_prefix || 'to_char('||p_column_name||',''''yyyy.mm.dd hh24:mi:ss'''')=''''''|| to_char(:'||p_old_or_new||'.'||p_column_name||',''yyyy.mm.dd hh24:mi:ss'') || '''''''';'||CHR(10);
   END IF;
   RETURN lv2_line;
END pincTriggerDateColumn;

----------------------------------------------------------------------------------------
-- NUMBER column in PINC triggers
----------------------------------------------------------------------------------------
FUNCTION pincTriggerNumberColumn(p_column_name IN VARCHAR2, p_old_or_new IN VARCHAR2, p_is_key IN VARCHAR2, p_col_prefix IN VARCHAR2)
RETURN VARCHAR2
IS
   lv2_line VARCHAR2(1000);
BEGIN
   lv2_line := q'[        dbms_lob.append(lcl_row,utl_raw.cast_to_raw(']'||p_column_name||q'[='|| TO_CHAR(:]'||p_old_or_new||'.'||p_column_name||q'[,'9999999999999999D9999999999','NLS_NUMERIC_CHARACTERS=''.,''') ||';'));
]';
   IF p_is_key = 'Y' THEN
      lv2_line := lv2_line || '        ' || p_col_prefix || p_column_name||'=''|| to_char(:'||p_old_or_new||'.'||p_column_name||',''9999999999999999D9999999999'',''NLS_NUMERIC_CHARACTERS=''''.,'''''');'||CHR(10);
   END IF;
   RETURN lv2_line;
END pincTriggerNumberColumn;

----------------------------------------------------------------------------------------
-- VARCHAR column in PINC triggers
----------------------------------------------------------------------------------------
FUNCTION pincTriggerTextColumn(p_column_name IN VARCHAR2, p_old_or_new IN VARCHAR2, p_is_key IN VARCHAR2, p_col_prefix IN VARCHAR2)
RETURN VARCHAR2
IS
   lv2_line VARCHAR2(1000);
BEGIN
   lv2_line := q'[        dbms_lob.append(lcl_row,utl_raw.cast_to_raw(']'||p_column_name||q'[='|| Replace(:]'||p_old_or_new||'.'||p_column_name||q'[,CHR(39),CHR(39)||CHR(39)) ||';'));
]';
   IF p_is_key = 'Y' THEN
      lv2_line := lv2_line || '        ' || p_col_prefix || p_column_name||'=''''''|| Replace(:new'||'.'||p_column_name||',CHR(39),CHR(39)||CHR(39)) ||'''''''';'||CHR(10);
   END IF;
   RETURN lv2_line;
END pincTriggerTextColumn;

----------------------------------------------------------------------------------------
-- Build journal trigger for "current table"
----------------------------------------------------------------------------------------
PROCEDURE buildJournalTrigger
IS
   lv_code DBMS_SQL.varchar2a;
   lv2_cols VARCHAR2(30000);
   lv2_vals VARCHAR2(30000);
   lv2_trigger_name VARCHAR2(30) := 'JN_'||substr(tbl.table_name, 1, 25);
BEGIN
   lv2_cols := 'jn_operation, jn_oracle_user, jn_datetime, jn_notes'||CHR(10);
   lv2_vals := 'lv2_operation, lv2_last_updated_by, EcDp_Timestamp.getCurrentSysdate, EcDp_User_Session.getUserSessionParameter(''JN_NOTES'') ' || CHR(10);
   FOR i IN 1..tbl.cols.COUNT LOOP
      IF hasJnColumn(tbl.cols(i).column_name) = 'Y' THEN
        lv2_cols := lv2_cols || '       ,' || tbl.cols(i).column_name || CHR(10);
        lv2_vals := lv2_vals || '       ,:old.' || tbl.cols(i).column_name || CHR(10);
      END IF;
   END LOOP;

   EcDp_DynSql.AddSqlLineNoWrap(lv_code, 'CREATE OR REPLACE TRIGGER ' || lv2_trigger_name || CHR(10));
   EcDp_DynSql.AddSqlLineNoWrap(lv_code, 'AFTER UPDATE OR DELETE ON ' || tbl.table_name || CHR(10));
   EcDp_DynSql.AddSqlLineNoWrap(lv_code, 'FOR EACH ROW ' || CHR(10));
   EcDp_DynSql.AddSqlLineNoWrap(lv_code, q'[DECLARE
   lv2_operation char(3);
   lv2_last_updated_by VARCHAR2(30);
BEGIN
   IF (Nvl(:new.rev_no, 0) <> :old.rev_no) OR (Deleting) THEN
   IF Deleting THEN
     lv2_operation := 'DEL';
     lv2_last_updated_by := Nvl(EcDp_User_Session.getUserSessionParameter('USERNAME'), User);
   ELSE
     lv2_operation := 'UPD';
     lv2_last_updated_by := :new.last_updated_by;
   END IF;
]');
   EcDp_DynSql.AddSqlLineNoWrap(lv_code,
       '     INSERT INTO ' || tbl.table_name || '_JN' || CHR(10) ||
       '     ('||lv2_cols||')'||CHR(10)||'VALUES'||CHR(10)||'('||lv2_vals||');'||CHR(10) ||
       'END IF;' ||CHR(10) ||
       'END;');

   Ecdp_Dynsql.SafeBuildSupressErrors(lv2_trigger_name, 'TRIGGER', lv_code, 'EC_TRIGGERS');

   lv_code.DELETE;
END buildJournalTrigger;

----------------------------------------------------------------------------------------
-- Build PINC trigger for "current table"
----------------------------------------------------------------------------------------
PROCEDURE buildPINCTrigger
IS
   lv_code DBMS_SQL.varchar2a;
   lv2_trigger_name VARCHAR2(30) := 'AP_'||substr(tbl.table_name, 1, 27);
   lv2_is_pk_column VARCHAR2(1);
   lv_ins_or_upd_code DBMS_SQL.varchar2a;
   lv_del_code DBMS_SQL.varchar2a;
   lv2_col_prefix VARCHAR2(1000) := NULL;
BEGIN
   IF isExceptionTable(tbl.table_name) AND NOT existsTrigger(lv2_trigger_name) THEN
      RETURN;
   END IF;

   FOR i IN 1..tbl.cols.COUNT LOOP
     IF tbl.cols(i).data_type NOT IN ('CLOB','BLOB','LONG') AND
        tbl.cols(i).column_name NOT IN ('RECORD_STATUS','CREATED_BY','CREATED_DATE','LAST_UPDATED_BY','LAST_UPDATED_DATE','REV_NO','REV_TEXT','REC_ID') THEN
          lv2_is_pk_column := hasPkColumn(tbl.cols(i).column_name);
          IF lv2_is_pk_column = 'Y' THEN
            IF lv2_col_prefix IS NULL THEN
               lv2_col_prefix := 'lv2_key := ''';
            ELSE
               lv2_col_prefix := 'lv2_key := lv2_key ||'' AND ';
            END IF;
          END IF;

          IF tbl.cols(i).data_type = 'DATE' THEN
             Ecdp_Dynsql.AddSqlLineNoWrap(lv_ins_or_upd_code, pincTriggerDateColumn(tbl.cols(i).column_name, 'new', lv2_is_pk_column, lv2_col_prefix));
             Ecdp_Dynsql.AddSqlLineNoWrap(lv_del_code, pincTriggerDateColumn(tbl.cols(i).column_name, 'old', lv2_is_pk_column, lv2_col_prefix));
          ELSIF tbl.cols(i).data_type = 'NUMBER' THEN
             Ecdp_Dynsql.AddSqlLineNoWrap(lv_ins_or_upd_code, pincTriggerNumberColumn(tbl.cols(i).column_name, 'new', lv2_is_pk_column, lv2_col_prefix));
             Ecdp_Dynsql.AddSqlLineNoWrap(lv_del_code, pincTriggerNumberColumn(tbl.cols(i).column_name, 'old', lv2_is_pk_column, lv2_col_prefix));
          ELSE
             Ecdp_Dynsql.AddSqlLineNoWrap(lv_ins_or_upd_code, pincTriggerTextColumn(tbl.cols(i).column_name, 'new', lv2_is_pk_column, lv2_col_prefix));
             Ecdp_Dynsql.AddSqlLineNoWrap(lv_del_code, pincTriggerTextColumn(tbl.cols(i).column_name, 'old', lv2_is_pk_column, lv2_col_prefix));
          END IF;
     END IF;
   END LOOP;

   EcDp_DynSql.AddSqlLineNoWrap(lv_code,
               'CREATE OR REPLACE TRIGGER ' || lv2_trigger_name || CHR(10) ||
               'AFTER INSERT OR UPDATE OR DELETE ON ' || tbl.table_name || CHR(10) ||
               'FOR EACH ROW' || CHR(10) ||
q'[  DECLARE
    CURSOR c_pinc_trigger_ind IS
      SELECT pinc_trigger_ind
      FROM   ctrl_object
      WHERE  object_name=']'||tbl.table_name||q'[' AND pinc_trigger_ind='N';

    lv2_InstallModeTag varchar2(240);
    lcl_row BLOB;
    lv2_key VARCHAR2(4000);
    lv2_operation VARCHAR2(30);
    lv2_pinc_trigger_ind VARCHAR2(1) := 'Y';
BEGIN
    -- Note, this is a autogenerated trigger, do not put handcoded logic here.
    lv2_InstallModeTag := ecdp_pinc.getInstallModeTag;

    IF lv2_InstallModeTag IS NOT NULL THEN
      FOR cur IN c_pinc_trigger_ind LOOP
        lv2_pinc_trigger_ind := cur.pinc_trigger_ind;
      END LOOP;
      --
      -- NOTE: No pinc logging in install mode if ctrl_object.pinc_trigger_ind = 'N' (defaults to 'Y')
      --
      IF nvl(lv2_pinc_trigger_ind, 'Y') <> 'N' THEN
        dbms_lob.createtemporary(lcl_row, TRUE, dbms_lob.CALL);
        lv2_key := NULL;

        IF INSERTING OR UPDATING THEN
]');

   EcDp_DynSql.AddSqlLinesNoWrap(lv_code, lv_ins_or_upd_code);

   EcDp_DynSql.AddSqlLineNoWrap(lv_code, '       ELSE'||CHR(10));

   EcDp_DynSql.AddSqlLinesNoWrap(lv_code, lv_del_code);

   EcDp_DynSql.AddSqlLineNoWrap(lv_code, q'[

        END IF;

        IF INSERTING THEN
          lv2_operation := 'INSERTING';
        ELSIF UPDATING THEN
          lv2_operation := 'UPDATING';
        ELSE
          lv2_operation := 'DELETING';
        END IF;

        EcDp_PInC.logTableContent(']'||tbl.table_name||q'['
                          ,lv2_operation
                          ,lv2_key
                          ,lcl_row);
      END IF;
    END IF;
END;]');

   Ecdp_Dynsql.SafeBuildSupressErrors(lv2_trigger_name, 'TRIGGER', lv_code, 'EC_TRIGGERS');

   lv_code.DELETE;

   IF isExceptionTable(tbl.table_name) AND existsTrigger(lv2_trigger_name) THEN
     EcDp_DynSql.execute_statement('ALTER TRIGGER '||lv2_trigger_name||' DISABLE');
   END IF;

END buildPINCTrigger;

----------------------------------------------------------------------------------------
-- Build IU trigger for "current table"
----------------------------------------------------------------------------------------
PROCEDURE buildIUTrigger
IS
   lv2_trigger_body VARCHAR2(4000);
   lv2_sys_guid VARCHAR2(1000);
   lv2_utc_daytime VARCHAR2(1000);
   lv2_up_utc_date VARCHAR2(1000);
   lv2_prod_day VARCHAR2(1000);
   lv2_up_prod_day VARCHAR2(1000);
   lv2_daytime VARCHAR2(240);
   lv2_day VARCHAR2(240);
   lv2_dayhr VARCHAR2(240);
   lv2_trigger_name VARCHAR2(30) := substr('IU_'||tbl.table_name, 1, 30);
BEGIN
   IF hasColumn('REV_NO') <> 'Y' THEN
      RETURN;
   END IF;

   lv2_sys_guid := NULL;

   IF hasColumn('OBJECT_ID') = 'Y' AND
      tbl.isNullable('OBJECT_ID') = 'N' AND
      tbl.dataType('OBJECT_ID') = 'VARCHAR2' AND
      hasFkColumn('OBJECT_ID') = 'N' AND
      hasPkColumn('OBJECT_ID') = 'Y' AND tbl.pk_cols.COUNT = 1 THEN
      -- The original criterion also supported OBJECT_ID as a unique constraint
      -- We have no unique constraints with OBJECT_ID as the only column, though.
      lv2_sys_guid := '      IF :new.object_id IS NULL THEN' || CHR(10) ||
                      '         :new.object_id := SYS_GUID();'  || chr(10) ||
                      '      END IF;' || chr(10);
   END IF;

   lv2_utc_daytime := NULL;

   IF hasColumn('UTC_DAYTIME') = 'Y' AND
      hasColumn('DAYTIME') = 'Y' THEN
      -- Add sync code
      IF hasColumn('SUMMER_TIME') = 'Y' THEN
         lv2_utc_daytime := '      EcDp_Timestamp_Utils.syncUtcDate(:NEW.object_id, :NEW.utc_daytime, ' ||
           ':NEW.daytime, :NEW.summer_time);' || CHR(10);
         lv2_up_utc_date := '      EcDp_Timestamp_Utils.updateUtcAndDaytime(:NEW.object_id, :OLD.utc_daytime, :NEW.utc_daytime' ||
            ', :OLD.daytime, :NEW.daytime, :OLD.summer_time, :NEW.summer_time);' || CHR(10);
      ELSE
         lv2_utc_daytime := '      EcDp_Timestamp_Utils.syncUtcDate(:NEW.object_id, :NEW.utc_daytime, ' ||
           ':NEW.daytime);' || CHR(10);
         lv2_up_utc_date := '      EcDp_Timestamp_Utils.updateUtcAndDaytime(:NEW.object_id, :OLD.utc_daytime, :NEW.utc_daytime' ||
            ', :OLD.daytime, :NEW.daytime);' || CHR(10);
      END IF;

      IF hasColumn('PRODUCTION_DAY') = 'Y' THEN
	    lv2_prod_day := '      :NEW.production_day := EcDp_Timestamp.getProductionDayFromLocal(:NEW.object_id, :NEW.daytime);';
	    lv2_up_prod_day := '      :NEW.production_day := EcDp_Timestamp.getProductionDayFromLocal(:NEW.object_id, :NEW.daytime);';
      ELSIF hasColumn('EVENT_DAY') = 'Y' THEN
	    lv2_prod_day := '      :NEW.event_day := EcDp_Timestamp.getProductionDayFromLocal(:NEW.object_id, :NEW.daytime);';
	    lv2_up_prod_day := '      :NEW.event_day := EcDp_Timestamp.getProductionDayFromLocal(:NEW.object_id, :NEW.daytime);';
      ELSIF hasColumn('DAY') = 'Y' THEN
	    lv2_prod_day := '      :NEW.day := EcDp_Timestamp.getProductionDayFromLocal(:NEW.object_id, :NEW.daytime);';
	    lv2_up_prod_day := '      :NEW.day := EcDp_Timestamp.getProductionDayFromLocal(:NEW.object_id, :NEW.daytime);';
      ELSE
        -- production_day not exists
        lv2_prod_day := '';
        lv2_up_prod_day := '';
      END IF;
      lv2_utc_daytime := lv2_utc_daytime || lv2_prod_day || CHR(10);
      lv2_up_utc_date := CHR(10) || lv2_up_utc_date || lv2_up_prod_day || CHR(10);
   END IF;

   IF hasColumn('UTC_END_DATE') = 'Y' AND
      hasColumn('END_DATE') = 'Y' THEN
      -- Add sync code
      IF hasColumn('END_SUMMER_TIME') = 'Y' THEN
         lv2_utc_daytime := lv2_utc_daytime || CHR(10) || '      EcDp_Timestamp_Utils.syncUtcDate(:NEW.object_id, :NEW.utc_end_date, ' ||
           ':NEW.end_date, :NEW.end_summer_time);' || CHR(10);
         lv2_up_utc_date := lv2_up_utc_date || CHR(10) || '      EcDp_Timestamp_Utils.updateUtcAndDaytime(:NEW.object_id, :OLD.utc_end_date, :NEW.utc_end_date' ||
            ', :OLD.end_date, :NEW.end_date, :OLD.end_summer_time, :NEW.end_summer_time);' || CHR(10);
      ELSE
         lv2_utc_daytime := lv2_utc_daytime || CHR(10) || '      EcDp_Timestamp_Utils.syncUtcDate(:NEW.object_id, :NEW.utc_end_date, ' ||
           ':NEW.end_date);' || CHR(10);
         lv2_up_utc_date := lv2_up_utc_date || CHR(10) || '      EcDp_Timestamp_Utils.updateUtcAndDaytime(:NEW.object_id, :OLD.utc_end_date, :NEW.utc_end_date' ||
            ', :OLD.end_date, :NEW.end_date);' || CHR(10);
      END IF;

      IF hasColumn('END_DAY') = 'Y' THEN
	    lv2_prod_day := '      :NEW.end_day := EcDp_Timestamp.getProductionDayFromLocal(:NEW.object_id, :NEW.end_date);';
	    lv2_up_prod_day := '      :NEW.end_day := EcDp_Timestamp.getProductionDayFromLocal(:NEW.object_id, :NEW.end_date);';
      ELSE
        -- production_day not exists
        lv2_prod_day := '';
        lv2_up_prod_day := '';
      END IF;
      lv2_utc_daytime := lv2_utc_daytime || lv2_prod_day || CHR(10);
      lv2_up_utc_date := lv2_up_utc_date || lv2_up_prod_day || CHR(10);
   END IF;

   lv2_daytime := NULL;
   lv2_day := NULL;
   lv2_dayhr := NULL;

   IF lv2_sys_guid IS NULL THEN
      FOR i IN 1..tbl.cols.COUNT LOOP
         IF tbl.cols(i).column_name = 'DAYTIME' THEN
            IF INSTR(tbl.table_name,'_DAY_') > 0 AND INSTR(tbl.table_name,'_SUB_') < 1 THEN
               lv2_daytime := '      :new.daytime := trunc(:new.daytime,''DD'');' || chr(10);
            ELSIF INSTR(tbl.table_name,'_MTH_') > 0 THEN
               lv2_daytime := '      :new.daytime := trunc(:new.daytime,''MM'');' || chr(10);
            END IF;
         ELSIF tbl.cols(i).column_name = 'DAY' THEN
            IF (INSTR(tbl.table_name,'_DAY_') + INSTR(tbl.table_name,'_MTH_')) < 1 AND SUBSTR(tbl.table_name,1,5) <> 'CTRL_' THEN
               lv2_day := '      :new.day := trunc(:new.daytime,''DD'');' || chr(10);
            END IF;
         ELSIF tbl.cols(i).column_name = 'DAYHR' THEN
            IF (INSTR(tbl.table_name,'_DAY_') + INSTR(tbl.table_name,'_MTH_')) < 1 AND SUBSTR(tbl.table_name,1,5) <> 'CTRL_' THEN
               lv2_dayhr := '      :new.dayhr := trunc(:new.daytime,''HH24'');' || chr(10);
            END IF;
         END IF;
      END LOOP;
   END IF;

   lv2_trigger_body := 'CREATE OR REPLACE TRIGGER ' || lv2_trigger_name || chr(10) ||
                       'BEFORE INSERT OR UPDATE ON ' || tbl.table_name || chr(10) ||
                       'FOR EACH ROW'||CHR(10)||
q'[BEGIN
    -- Basis
    IF Inserting THEN
]' || lv2_daytime ||  lv2_day ||  lv2_dayhr || q'[
      :new.record_status := nvl(:new.record_status, 'P');
]' || lv2_sys_guid || lv2_utc_daytime || q'[
      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;
      IF :new.created_date IS NULL THEN
         :new.created_date := EcDp_Timestamp.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;
    ELSE ]' || lv2_up_utc_date || q'[
      IF Nvl(:new.record_status,'P') = Nvl(:old.record_status,'P') THEN
         IF NOT UPDATING('LAST_UPDATED_BY') THEN
            :new.last_updated_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
         END IF;
         IF NOT UPDATING('LAST_UPDATED_DATE') THEN
           :new.last_updated_date := EcDp_Timestamp.getCurrentSysdate;
         END IF;
      END IF;
    END IF;
END;]';
   buildTrigger(lv2_trigger_name, lv2_trigger_body);
END buildIUTrigger;

----------------------------------------------------------------------------------------
-- Build AIUDT trigger
----------------------------------------------------------------------------------------
PROCEDURE buildAiudtTrigger
IS
   lv2_trigger_name VARCHAR2(30) := SUBSTR('AIUDT_'||tbl.table_name, 1, 30);
   lb_is_object_table BOOLEAN;
   lb_is_object_version_table BOOLEAN;
   lb_has_class_name_column BOOLEAN;

BEGIN
   lb_is_object_table :=
                      tbl.table_name NOT LIKE '%/_JN' ESCAPE '/' AND
                      tbl.table_name NOT IN ('OBJECTS_DATA', 'OBJECTS_ATTR_ROW') AND
                      hasColumn('OBJECT_ID') = 'Y' AND
                      hasColumn('OBJECT_CODE') = 'Y' AND
                      hasColumn('START_DATE') = 'Y' AND
                      hasColumn('END_DATE') = 'Y';

   lb_is_object_version_table :=
                      tbl.table_name LIKE '%/_VERSION' ESCAPE '/' AND
                      tbl.table_name NOT IN ('OBJECTS_ATTR_ROW_VERSION', 'OBJECTS_VERSION') AND
                      hasColumn('OBJECT_ID') = 'Y' AND
                      hasColumn('NAME') = 'Y' AND
                      hasColumn('DAYTIME') = 'Y' AND
                      hasColumn('END_DATE') = 'Y';

   lb_has_class_name_column := hasColumn('CLASS_NAME') = 'Y';

   IF lb_is_object_table THEN
      buildTrigger(lv2_trigger_name,
          'CREATE OR REPLACE TRIGGER ' || lv2_trigger_name || CHR(10) ||
          'AFTER INSERT OR UPDATE OR DELETE ON ' || tbl.table_name || CHR(10) ||
          'FOR EACH ROW ' || CHR(10) ||
          'BEGIN ' || CHR(10) ||
          '    IF Inserting THEN' || CHR(10) ||
          '      ecdp_trigger_utils.iudObject(' || CASE WHEN lb_has_class_name_column THEN ' :NEW.class_name, ' ELSE '''' || tbl.table_name || ''', ' END ||
          'NULL, :NEW.object_id, :NEW.object_code, :NEW.start_date, :NEW.end_date, :NEW.created_by, :NEW.created_date);' || CHR(10) ||
          '    ELSIF Updating THEN' || CHR(10) ||
          '      ecdp_trigger_utils.iudObject(' || CASE WHEN lb_has_class_name_column THEN ' :OLD.class_name, ' ELSE '''' || tbl.table_name || ''', ' END ||
          ':OLD.object_id, :NEW.object_id, :NEW.object_code, :NEW.start_date, :NEW.end_date, :NEW.created_by, :NEW.created_date);' || CHR(10) ||
          '    ELSE' || CHR(10) ||
          '      ecdp_trigger_utils.iudObject(' || CASE WHEN lb_has_class_name_column THEN ' :OLD.class_name, ' ELSE '''' || tbl.table_name || ''', ' END ||
          ':OLD.object_id,NULL, :OLD.object_code, :OLD.start_date, :OLD.end_date, :OLD.created_by, :OLD.created_date, FALSE);' || CHR(10) ||
          '    END IF;' || CHR(10) ||
          'END;' || CHR(10));
   ELSIF lb_is_object_version_table THEN
      buildTrigger(lv2_trigger_name,
          'CREATE OR REPLACE TRIGGER ' || lv2_trigger_name || CHR(10) ||
          'AFTER INSERT OR UPDATE OR DELETE ON ' || tbl.table_name || CHR(10) ||
          'FOR EACH ROW ' || CHR(10) ||
          'BEGIN ' || CHR(10) ||
          '    IF Inserting THEN' || CHR(10) ||
          '      ecdp_trigger_utils.iudObjectVersion(''' || tbl.table_name || ''', ' ||
          'NULL, :NEW.object_id, :NEW.name, :NEW.daytime, :NEW.end_date, :NEW.created_by, :NEW.created_date);' || CHR(10) ||
          '    ELSIF Updating THEN' || CHR(10) ||
          '      ecdp_trigger_utils.iudObjectVersion(''' || tbl.table_name || ''', ' ||
          ':OLD.object_id, :NEW.object_id, :NEW.name, :NEW.daytime, :NEW.end_date, :NEW.created_by, :NEW.created_date);' || CHR(10) ||
          '    ELSE' || CHR(10) ||
          '      ecdp_trigger_utils.iudObjectVersion(''' || tbl.table_name || ''', ' ||
          ':OLD.object_id, NULL, :OLD.name, :OLD.daytime, :OLD.end_date, :OLD.created_by, :OLD.created_date, FALSE);' || CHR(10) ||
          '    END IF;' || CHR(10) ||
          'END;' || CHR(10));
   END IF;
END buildAiudtTrigger;

----------------------------------------------------------------------------------------
-- Bit mask for "generate packages and views"
----------------------------------------------------------------------------------------
FUNCTION PACKAGES
RETURN INTEGER
IS
BEGIN
   RETURN I_PCK_MASK;
END PACKAGES;

----------------------------------------------------------------------------------------
-- Bit mask for "generate all triggers"
----------------------------------------------------------------------------------------
FUNCTION ALL_TRIGGERS
RETURN INTEGER
IS
BEGIN
   RETURN AP_TRIGGERS + AUT_TRIGGERS + AIUDT_TRIGGERS + IUR_TRIGGERS + IU_TRIGGERS + JN_TRIGGERS;
END ALL_TRIGGERS;

----------------------------------------------------------------------------------------
-- Bit mask for "generate basic triggers"
----------------------------------------------------------------------------------------
FUNCTION BASIC_TRIGGERS
RETURN INTEGER
IS
BEGIN
   RETURN AUT_TRIGGERS + AIUDT_TRIGGERS + IU_TRIGGERS;
END BASIC_TRIGGERS;

----------------------------------------------------------------------------------------
-- Bit mask for "generate PINC/AP trigger"
----------------------------------------------------------------------------------------
FUNCTION AP_TRIGGERS
RETURN INTEGER
IS
BEGIN
   RETURN I_AP_MASK;
END AP_TRIGGERS;

----------------------------------------------------------------------------------------
-- Bit mask for "generate AUT trigger"
----------------------------------------------------------------------------------------
FUNCTION AUT_TRIGGERS
RETURN INTEGER
IS
BEGIN
   RETURN I_AUT_MASK;
END AUT_TRIGGERS;

----------------------------------------------------------------------------------------
-- Bit mask for "generate AIUDT trigger"
----------------------------------------------------------------------------------------
FUNCTION AIUDT_TRIGGERS
RETURN INTEGER
IS
BEGIN
   RETURN I_AIUDT_MASK;
END AIUDT_TRIGGERS;

----------------------------------------------------------------------------------------
-- Bit mask for "generate IUR trigger"
----------------------------------------------------------------------------------------
FUNCTION IUR_TRIGGERS
RETURN INTEGER
IS
BEGIN
   RETURN I_IUR_MASK;
END IUR_TRIGGERS;

----------------------------------------------------------------------------------------
-- Bit mask for "generate IU trigger"
----------------------------------------------------------------------------------------
FUNCTION IU_TRIGGERS
RETURN INTEGER
IS
BEGIN
   RETURN I_IU_MASK;
END IU_TRIGGERS;

----------------------------------------------------------------------------------------
-- Bit mask for "generate JN trigger"
----------------------------------------------------------------------------------------
FUNCTION JN_TRIGGERS
RETURN INTEGER
IS
BEGIN
   RETURN I_JN_MASK;
END JN_TRIGGERS;

----------------------------------------------------------------------------------------
-- Bit mask for "generate JN index"
----------------------------------------------------------------------------------------
FUNCTION JN_INDEX
RETURN INTEGER
IS
BEGIN
   RETURN I_JN_INDEX_MASK;
END JN_INDEX;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : generateJnIndex
-- Description    : This procedure generates indexes for JN tables, based on
--                  the primary key of the base table.
--                  If the table has any index except on the REC_ID column
--                  , then the index is not generated
-- Postconditions :
--
-- Using tables   : user_tables
--                  user_ind_columns
--                  user_constraints
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : If p_table_name is null, then indexes generated for all JN tables
--                  If p_table_name is given, then indexes generated only for that table
---------------------------------------------------------------------------------------------------
PROCEDURE generateJnIndex(p_table VARCHAR2 DEFAULT '%') IS
  ln_count PLS_INTEGER;
  lv2_columns VARCHAR2(2000);
  lv2_stmt VARCHAR2(2000);
BEGIN
  FOR tab in (WITH t1 as
               (select table_name
                 from user_tables
                where table_name like '%/_JN' ESCAPE '/'),
              t2 as
               (select table_name
                 from user_tables
                where table_name not like '/%_JN' ESCAPE '/'
                  and table_name like p_table)
              SELECT t1.table_name jn_table_name, t2.table_name
                FROM t1
                join t2
                  ON substr(t1.table_name, 1, length(t1.table_name) - 3) =
                     t2.table_name)
   LOOP

    select count(*)
      into ln_count
      from user_ind_columns
      where table_name = tab.jn_table_name
      AND column_name != 'REC_ID';

    if ln_count>0 then
      dbms_output.put_line('--'||tab.jn_table_name||' - more than 1 index, will NOT generate index');
    else
      dbms_output.put_line(CHR(10)||tab.jn_table_name);
      begin
      select listagg(a.column_name,', ')
         within group ( order by a.column_position)
       into lv2_columns
       from user_ind_columns a
       join user_constraints b
       on b.constraint_name = a.index_name
       where b.table_name = tab.table_name
       and b.constraint_type='P'
       and b.table_name != 'AUDIT_LOGIN';

       IF length(lv2_columns)>0 THEN
         lv2_stmt := 'CREATE INDEX IG_'||substr(tab.jn_table_name,1,27)
           ||' ON '||tab.jn_table_name||'('||lv2_columns||')';
         dbms_output.put_line(lv2_stmt);
         BEGIN
           EXECUTE IMMEDIATE lv2_stmt;
           EXCEPTION
             WHEN OTHERS THEN
               dbms_output.put_line(sqlerrm);
         END;
       END IF;

      end;
    end if;

  END LOOP;
END;

---------------------------------------------------------------------------------------------------
-- Generate triggers and EC package for the given table, or all tables if none is given.
-- The target type mask determines which objects to generate.
--
-- Example:
--     -- Generate EC packages for all tables
--     EcDp_Generate.generate(NULL, EcDp_Generate.PACKAGES);
--
--     -- Generate EC package for the BERTH table
--     EcDp_Generate.generate('BERTH', EcDp_Generate.PACKAGES);
--
--     -- Generate all triggers for BERTH table
--     EcDp_Generate.generate('BERTH', EcDp_Generate.ALL_TRIGGERS);
--
--     -- Generate AP, IUR and  triggers for all tables
--     EcDp_Generate.generate(NULL, EcDp_Generate.IU + EcDp_Generate.AUT + EcDp_Generate.AIUDT);
---------------------------------------------------------------------------------------------------
PROCEDURE generate(
          p_table_name IN VARCHAR2,
          p_target_mask IN INTEGER,
          p_missing_ind IN VARCHAR2 DEFAULT NULL)
IS
  CURSOR c_user_tables(cp_table_name IN VARCHAR2) IS
    SELECT ut.table_name, 'TABLE' AS object_type, ut.table_name AS key_table_name
    FROM   user_tables ut
    WHERE  ut.table_name NOT LIKE '%/_JN' ESCAPE '/'
    AND    ut.table_name = Nvl(cp_table_name, table_name)
    AND NOT EXISTS (SELECT 1 FROM user_mviews m WHERE ut.table_name = m.mview_name)
    UNION
    SELECT co.object_name AS table_name, 'VIEW' AS object_type, co.view_pk_table_name AS key_table_name
    FROM   ctrl_object co
    INNER JOIN user_views uv ON uv.view_name = co.object_name
    WHERE  co.view_pk_table_name IS NOT NULL
    AND    co.object_name = Nvl(cp_table_name, object_name)
    AND NOT EXISTS (SELECT 1 FROM user_mviews m WHERE uv.view_name = m.mview_name)
     ;

  CURSOR c_alias(p_table_name VARCHAR) IS
    SELECT column_name, alias_name
    FROM   ctrl_gen_function
    WHERE  table_name = p_table_name;

  CURSOR c_exists IS
    SELECT object_name FROM user_objects WHERE object_name LIKE 'IU/_%' ESCAPE '/' AND object_type='TRIGGER'
    UNION ALL
    SELECT object_name FROM user_objects WHERE object_name LIKE 'IUR/_%' ESCAPE '/' AND object_type='TRIGGER'
    UNION ALL
    SELECT object_name FROM user_objects WHERE object_name LIKE 'AP/_%' ESCAPE '/' AND object_type='TRIGGER'
    UNION ALL
    SELECT object_name FROM user_objects WHERE object_name LIKE 'AUT/_%' ESCAPE '/' AND object_type='TRIGGER'
    UNION ALL
    SELECT object_name FROM user_objects WHERE object_name LIKE 'AIUDT/_%' ESCAPE '/' AND object_type='TRIGGER'
    UNION ALL
    SELECT object_name FROM user_objects WHERE object_name LIKE 'JN/_%' ESCAPE '/' AND object_type='TRIGGER'
    UNION ALL
    SELECT object_name FROM user_objects WHERE object_name LIKE 'EC/_%' ESCAPE '/' AND object_type='PACKAGE'
    ;

  b_regenerate_existing BOOLEAN := Nvl(p_missing_ind, 'N') = 'N';
  b_generate_package BOOLEAN := bitand(p_target_mask, PACKAGES) > 0;
  b_generate_ap BOOLEAN := bitand(p_target_mask, AP_TRIGGERS) > 0;
  b_generate_aut BOOLEAN := bitand(p_target_mask, AUT_TRIGGERS) > 0;
  b_generate_aiudt BOOLEAN := bitand(p_target_mask, AIUDT_TRIGGERS) > 0;
  b_generate_iu BOOLEAN := bitand(p_target_mask, IU_TRIGGERS) > 0;
  b_generate_iur BOOLEAN := bitand(p_target_mask, IUR_TRIGGERS) > 0;
  b_generate_jn BOOLEAN := bitand(p_target_mask, JN_TRIGGERS) > 0;
  b_generate_jn_index BOOLEAN := bitand(p_target_mask, JN_INDEX) > 0;

  m_exists Varchar_30_M;

  v_target_mask INTEGER := 0;

  key_cols t_table_key_columns := NULL;

BEGIN
   IF NOT b_regenerate_existing THEN
     FOR cur IN c_exists LOOP
       m_exists(cur.object_name) := 'Y';
     END LOOP;
   END IF;

   FOR curTable IN c_user_tables(p_table_name) LOOP
      clearTbl;

      IF key_cols IS NOT NULL THEN
         key_cols.DELETE;
      END IF;

      key_cols := t_table_key_columns();

      b_regenerate_existing := Nvl(p_missing_ind, 'N') = 'N';
      b_generate_package := bitand(p_target_mask, PACKAGES) > 0;
      b_generate_ap := bitand(p_target_mask, AP_TRIGGERS) > 0 AND curTable.object_type = 'TABLE';
      b_generate_aut := bitand(p_target_mask, AUT_TRIGGERS) > 0 AND curTable.object_type = 'TABLE';
      b_generate_aiudt := bitand(p_target_mask, AIUDT_TRIGGERS) > 0 AND curTable.object_type = 'TABLE';
      b_generate_iu := bitand(p_target_mask, IU_TRIGGERS) > 0 AND curTable.object_type = 'TABLE';
      b_generate_iur := bitand(p_target_mask, IUR_TRIGGERS) > 0 AND curTable.object_type = 'TABLE';
      b_generate_jn := bitand(p_target_mask, JN_TRIGGERS) > 0 AND curTable.object_type = 'TABLE';
      b_generate_jn_index := bitand(p_target_mask, JN_INDEX) > 0 AND curTable.object_type = 'TABLE';

      IF NOT b_regenerate_existing THEN
        b_generate_package := b_generate_package AND NOT m_exists.EXISTS(substr('EC_'||curTable.table_name, 1, 30));
        b_generate_ap := b_generate_ap AND NOT m_exists.EXISTS(substr('AP_'||curTable.table_name, 1, 30));
        b_generate_aut := b_generate_aut AND NOT m_exists.EXISTS(substr('AUT_'||curTable.table_name, 1, 30));
        b_generate_aiudt := b_generate_aiudt AND NOT m_exists.EXISTS(substr('AIUDT_'||curTable.table_name, 1, 30));
        b_generate_iu := b_generate_iu AND NOT m_exists.EXISTS(substr('IU_'||curTable.table_name, 1, 30));
        b_generate_iur := b_generate_iur AND NOT m_exists.EXISTS(substr('IUR_'||curTable.table_name, 1, 30));
        b_generate_jn := b_generate_jn AND NOT m_exists.EXISTS(substr('JN_'||curTable.table_name, 1, 30));
      END IF;

      IF NOT (b_generate_package OR
              b_generate_ap OR
              b_generate_aut OR
              b_generate_aiudt OR
              b_generate_iu OR
              b_generate_iur OR
              b_generate_jn OR
			  b_generate_jn_index) THEN
        CONTINUE;
      END IF;

      v_target_mask := 0;

      IF b_generate_package THEN
         v_target_mask := v_target_mask + PACKAGES;
      END IF;

      IF b_generate_ap THEN
         v_target_mask := v_target_mask + AP_TRIGGERS;
      END IF;

      IF b_generate_aut THEN
         v_target_mask := v_target_mask + AUT_TRIGGERS;
      END IF;

      IF b_generate_aiudt THEN
         v_target_mask := v_target_mask + AIUDT_TRIGGERS;
      END IF;

      IF b_generate_iu THEN
         v_target_mask := v_target_mask + IU_TRIGGERS;
      END IF;

      IF b_generate_iur THEN
         v_target_mask := v_target_mask + IUR_TRIGGERS;
      END IF;

      IF b_generate_jn THEN
         v_target_mask := v_target_mask + JN_TRIGGERS;
      END IF;

      IF b_generate_jn_index THEN
         v_target_mask := v_target_mask + JN_INDEX;
      END IF;

      tbl.table_name := curTable.table_name;

      IF b_generate_package OR b_generate_ap OR b_generate_iu THEN
         OPEN c_table_key_columns(curTable.key_table_name);
         FETCH c_table_key_columns BULK COLLECT INTO key_cols;
         CLOSE c_table_key_columns;

         FOR i IN 1..key_cols.COUNT LOOP
            IF key_cols(i).constraint_type = 'R' THEN
               tbl.fk_cols.EXTEND(1);
               tbl.fk_cols(tbl.fk_cols.COUNT) := key_cols(i);
            ELSIF key_cols(i).constraint_type = 'P' THEN
               tbl.pk_cols.EXTEND(1);
               tbl.pk_cols(tbl.pk_cols.COUNT) := key_cols(i);
            ELSIF key_cols(i).constraint_type = 'U' THEN
               tbl.uk_cols.EXTEND(1);
               tbl.uk_cols(tbl.uk_cols.COUNT) := key_cols(i);
            END IF;
         END LOOP;
      END IF;

      IF b_generate_package OR b_generate_aut THEN
         FOR cur IN c_ctrl_object(tbl.table_name) LOOP
            tbl.ctrlObj := cur;
         END LOOP;
      END IF;

      OPEN c_table_columns(tbl.table_name);
      FETCH c_table_columns BULK COLLECT INTO tbl.cols;
      CLOSE c_table_columns;

      FOR i IN 1..tbl.cols.COUNT LOOP
         tbl.alias(tbl.cols(i).column_name) := tbl.cols(i).column_name;
      END LOOP;

      IF b_generate_package THEN
        OPEN c_ctrl_gen_functions(curTable.table_name);
        FETCH c_ctrl_gen_functions BULK COLLECT INTO tbl.genFns;
        CLOSE c_ctrl_gen_functions;

        FOR curAlias IN c_alias(curTable.table_name) LOOP
           tbl.alias(curAlias.column_name) := Nvl(curAlias.alias_name, curAlias.column_name);
        END LOOP;
      END IF;

      IF b_generate_jn THEN
         OPEN c_table_columns(tbl.table_name||'_JN');
         FETCH c_table_columns BULK COLLECT INTO tbl.jn_cols;
         CLOSE c_table_columns;
      END IF;

      FOR i IN 1..tbl.cols.COUNT LOOP
         tbl.dataType(tbl.cols(i).column_name) := tbl.cols(i).data_type;
         tbl.isNullable(tbl.cols(i).column_name) := tbl.cols(i).nullable;
      END LOOP;

      FOR i IN 1..tbl.jn_cols.COUNT LOOP
         tbl.jnDataType(tbl.jn_cols(i).column_name) := tbl.jn_cols(i).data_type;
      END LOOP;

      FOR i IN 1..tbl.pk_cols.COUNT LOOP
         IF NOT tbl.dataType.EXISTS(tbl.pk_cols(i).column_name) THEN
            tbl.dataType(tbl.pk_cols(i).column_name) := tbl.pk_cols(i).data_type;
            tbl.isNullable(tbl.pk_cols(i).column_name) := 'N';
         END IF;
         tbl.pk_cols(i).data_type := tbl.dataType(tbl.pk_cols(i).column_name);
      END LOOP;

      FOR i IN 1..tbl.uk_cols.COUNT LOOP
         IF NOT tbl.dataType.EXISTS(tbl.uk_cols(i).column_name) THEN
            tbl.dataType(tbl.uk_cols(i).column_name) := tbl.uk_cols(i).data_type;
         END IF;
         tbl.uk_cols(i).data_type := tbl.dataType(tbl.uk_cols(i).column_name);
      END LOOP;

      FOR i IN 1..tbl.fk_cols.COUNT LOOP
         IF NOT tbl.dataType.EXISTS(tbl.fk_cols(i).column_name) THEN
           tbl.dataType(tbl.fk_cols(i).column_name) := tbl.fk_cols(i).data_type;
           tbl.isNullable(tbl.fk_cols(i).column_name) := 'N';
         END IF;
         tbl.fk_cols(i).data_type := tbl.dataType(tbl.fk_cols(i).column_name);
      END LOOP;

      IF b_generate_package AND tbl.ctrlObj.object_name IS NOT NULL AND Nvl(tbl.ctrlObj.ec_package, 'Y') = 'Y' THEN
        generatePackage;
        generatePackageViews;
      END IF;

      IF b_generate_ap AND Nvl(tbl.ctrlObj.pinc_trigger_ind, 'Y') = 'Y' THEN
         buildPINCTrigger;
      END IF;

      IF b_generate_aut THEN
        IF tbl.ctrlObj.object_name IS NOT NULL AND Nvl(tbl.ctrlObj.ec_package, 'Y') = 'Y' THEN
          buildTrigger(
                 substr('AUT_'||tbl.table_name, 1, 30),
                 'CREATE OR REPLACE TRIGGER ' || substr('AUT_'||tbl.table_name, 1, 30) || CHR(10) ||
                 'AFTER UPDATE ON ' || tbl.table_name || CHR(10) ||
                 'BEGIN ' || CHR(10) || '    '||
                 substr('EC_'||tbl.table_name, 1, 30) || '.flush_row_cache;' || CHR(10) ||
                 'END;' || CHR(10));
        END IF;
      END IF;

      IF b_generate_aiudt THEN
         buildAiudtTrigger;
      END IF;

      IF b_generate_iu THEN
         buildIUTrigger;
      END IF;

      IF b_generate_iur THEN
         IF hasColumn('REV_NO') = 'Y' AND hasColumn('REC_ID') = 'Y' THEN
            buildTrigger(
               substr('IUR_'||tbl.table_name, 1, 30),
               'CREATE OR REPLACE TRIGGER ' || substr('IUR_'||tbl.table_name, 1, 30) || CHR(10) ||
               'BEFORE INSERT OR UPDATE ON ' || tbl.table_name || CHR(10) ||
               'FOR EACH ROW'|| CHR(10) ||
               IUR_TRIGGER_CODE);
         END IF;
      END IF;

      IF b_generate_jn AND tbl.jn_cols.COUNT > 0 THEN
         buildJournalTrigger;
      END IF;

	  IF b_generate_jn_index THEN
        generateJnIndex(tbl.table_name);
	  END IF;
   END LOOP;
END generate;

END EcDp_Generate;