
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 09.10.42 AM


CREATE or REPLACE PACKAGE RP_GENERATE
IS

   FUNCTION GET_TABLE_COLUMS(
      P_TABLE IN VARCHAR2,
      P_DELIMITER IN VARCHAR2,
      P_EXCEPT_COLS IN VARCHAR2 DEFAULT NULL,
      P_TRUNC_LENGTH IN NUMBER DEFAULT 30)
      RETURN VARCHAR2;
   FUNCTION GETATTRIBUTEPARENTTABLE(
      P_TABLE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION HAS_TABLE_CONSTRAINT(
      P_TABLE_NAME IN VARCHAR2,
      P_CONSTRAINT_TYPE IN VARCHAR2)
      RETURN BOOLEAN;
   FUNCTION TABLE_EXIST(
      P_TABLE_NAME IN VARCHAR2)
      RETURN BOOLEAN;
   FUNCTION GET_PK_PARAM_LIST(
      P_TABLE IN VARCHAR2,
      P_DELIMITER IN VARCHAR2,
      P_EXCEPT_COLS IN VARCHAR2 DEFAULT NULL,
      P_PARAM_PREFIX IN VARCHAR2 DEFAULT 'p_',
      P_PARAM_POSTFIX IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION GET_PK_WHERE_CLAUSE(
      P_TABLE IN VARCHAR2,
      P_DELIMITER IN VARCHAR2,
      P_EXCEPT_COLS IN VARCHAR2 DEFAULT NULL,
      P_TABLE_ALIAS IN VARCHAR2 DEFAULT NULL,
      P_PARAM_PREFIX IN VARCHAR2 DEFAULT 'p_',
      P_PARAM_POSTFIX IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION COLUMN_EXIST(
      P_TABLE IN VARCHAR2,
      P_COLUMN IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETFUNCTIONNAME(
      P_TABLE IN VARCHAR2,
      P_COLUMN IN VARCHAR2)
      RETURN VARCHAR2;

END RP_GENERATE;

/



CREATE or REPLACE PACKAGE BODY RP_GENERATE
IS

   FUNCTION GET_TABLE_COLUMS(
      P_TABLE IN VARCHAR2,
      P_DELIMITER IN VARCHAR2,
      P_EXCEPT_COLS IN VARCHAR2 DEFAULT NULL,
      P_TRUNC_LENGTH IN NUMBER DEFAULT 30)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := EC_GENERATE.GET_TABLE_COLUMS      (
         P_TABLE,
         P_DELIMITER,
         P_EXCEPT_COLS,
         P_TRUNC_LENGTH );
         RETURN ret_value;
   END GET_TABLE_COLUMS;
   FUNCTION GETATTRIBUTEPARENTTABLE(
      P_TABLE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := EC_GENERATE.GETATTRIBUTEPARENTTABLE      (
         P_TABLE );
         RETURN ret_value;
   END GETATTRIBUTEPARENTTABLE;
   FUNCTION HAS_TABLE_CONSTRAINT(
      P_TABLE_NAME IN VARCHAR2,
      P_CONSTRAINT_TYPE IN VARCHAR2)
      RETURN BOOLEAN
   IS
      ret_value    BOOLEAN ;
   BEGIN
      ret_value := EC_GENERATE.HAS_TABLE_CONSTRAINT      (
         P_TABLE_NAME,
         P_CONSTRAINT_TYPE );
         RETURN ret_value;
   END HAS_TABLE_CONSTRAINT;
   FUNCTION TABLE_EXIST(
      P_TABLE_NAME IN VARCHAR2)
      RETURN BOOLEAN
   IS
      ret_value    BOOLEAN ;
   BEGIN
      ret_value := EC_GENERATE.TABLE_EXIST      (
         P_TABLE_NAME );
         RETURN ret_value;
   END TABLE_EXIST;
   FUNCTION GET_PK_PARAM_LIST(
      P_TABLE IN VARCHAR2,
      P_DELIMITER IN VARCHAR2,
      P_EXCEPT_COLS IN VARCHAR2 DEFAULT NULL,
      P_PARAM_PREFIX IN VARCHAR2 DEFAULT 'p_',
      P_PARAM_POSTFIX IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := EC_GENERATE.GET_PK_PARAM_LIST      (
         P_TABLE,
         P_DELIMITER,
         P_EXCEPT_COLS,
         P_PARAM_PREFIX,
         P_PARAM_POSTFIX );
         RETURN ret_value;
   END GET_PK_PARAM_LIST;
   FUNCTION GET_PK_WHERE_CLAUSE(
      P_TABLE IN VARCHAR2,
      P_DELIMITER IN VARCHAR2,
      P_EXCEPT_COLS IN VARCHAR2 DEFAULT NULL,
      P_TABLE_ALIAS IN VARCHAR2 DEFAULT NULL,
      P_PARAM_PREFIX IN VARCHAR2 DEFAULT 'p_',
      P_PARAM_POSTFIX IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := EC_GENERATE.GET_PK_WHERE_CLAUSE      (
         P_TABLE,
         P_DELIMITER,
         P_EXCEPT_COLS,
         P_TABLE_ALIAS,
         P_PARAM_PREFIX,
         P_PARAM_POSTFIX );
         RETURN ret_value;
   END GET_PK_WHERE_CLAUSE;
   FUNCTION COLUMN_EXIST(
      P_TABLE IN VARCHAR2,
      P_COLUMN IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_GENERATE.COLUMN_EXIST      (
         P_TABLE,
         P_COLUMN );
         RETURN ret_value;
   END COLUMN_EXIST;
   FUNCTION GETFUNCTIONNAME(
      P_TABLE IN VARCHAR2,
      P_COLUMN IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := EC_GENERATE.GETFUNCTIONNAME      (
         P_TABLE,
         P_COLUMN );
         RETURN ret_value;
   END GETFUNCTIONNAME;

END RP_GENERATE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_GENERATE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 09.10.44 AM


