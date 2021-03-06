
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.46.33 AM


CREATE or REPLACE PACKAGE RPDP_REVN_IFAC_WRAPPER_PERIOD
IS

   FUNCTION AGGREGATE(
      P_COLLECTION IN OUT T_TABLE_IFAC_SALES_QTY,
      P_BY IN VARCHAR2)
      RETURN T_TABLE_VARCHAR2;
   FUNCTION FILTER(
      P_COLLECTION IN OUT T_TABLE_IFAC_SALES_QTY,
      P_CONDITION IN VARCHAR2)
      RETURN T_TABLE_IFAC_SALES_QTY;
   FUNCTION FIND_ONE(
      P_IFAC IN OUT T_TABLE_IFAC_SALES_QTY,
      P_RANGE IN T_TABLE_NUMBER DEFAULT NULL,
      P_LEVEL IN VARCHAR2 default null,
      P_TRANS_ID IN NUMBER default null,
      P_LI_ID IN NUMBER default null,
      P_TRANSACTION_KEY IN VARCHAR2 default null,
      P_LINE_ITEM_KEY IN VARCHAR2 default NULL,
      P_PROFIT_CENTER_ID IN VARCHAR2 DEFAULT NULL,
      P_VENDOR_ID IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION GETIFACRELATESTO(
      P_SOURCE_ENTRY_NO IN NUMBER,
      P_SCOPE IN VARCHAR2)
      RETURN T_TABLE_IFAC_SALES_QTY;
   FUNCTION GETVENDORLEVELIFACRECORDS(
      P_RECORDS IN T_TABLE_IFAC_SALES_QTY,
      P_PC_LEVEL_RECORD IN T_IFAC_SALES_QTY,
      P_VENDOR_ID IN VARCHAR2 DEFAULT NULL)
      RETURN T_TABLE_IFAC_SALES_QTY;
   FUNCTION SORT(
      P_COLLECTION IN OUT T_TABLE_IFAC_SALES_QTY,
      P_BY IN VARCHAR2 DEFAULT NULL,
      P_DECODES IN VARCHAR2 DEFAULT NULL)
      RETURN T_TABLE_IFAC_SALES_QTY;
   FUNCTION GETIFACFORDOCUMENT(
      P_CONTRACT_ID IN VARCHAR2,
      P_DOCUMENT_SETUP_ID IN VARCHAR2,
      P_PROCESSING_PERIOD IN DATE,
      P_CUSTOMER_ID IN VARCHAR2,
      P_DOCUMENT_STATUS IN VARCHAR2)
      RETURN T_TABLE_IFAC_SALES_QTY;
   FUNCTION GETTRANSACTIONLEVELIFACRECORDS(
      P_RECORDS IN T_TABLE_IFAC_SALES_QTY)
      RETURN T_TABLE_IFAC_SALES_QTY;
   FUNCTION GETPCLEVELIFACRECORDS(
      P_RECORDS IN T_TABLE_IFAC_SALES_QTY,
      P_TRANSACTION_LEVEL_RECORD IN T_IFAC_SALES_QTY,
      P_PROFIT_CENTER_ID IN VARCHAR2 DEFAULT NULL)
      RETURN T_TABLE_IFAC_SALES_QTY;
   FUNCTION IFACRECORDHASVENDORPC(
      P_SOURCE_ENTRY_NO IN NUMBER,
      P_VENDOR_ID IN VARCHAR2 default 'XX',
      P_PROFIT_CENTRE IN VARCHAR2 default 'XX')
      RETURN VARCHAR2;
   FUNCTION FILTER(
      P_COLLECTION IN OUT T_TABLE_IFAC_SALES_QTY,
      P_LEVEL IN VARCHAR2,
      P_TRANS_ID IN NUMBER,
      P_LI_ID IN NUMBER,
      P_TRANSACTION_KEY IN VARCHAR2)
      RETURN T_TABLE_IFAC_SALES_QTY;
   FUNCTION FIND(
      P_IFAC IN OUT T_TABLE_IFAC_SALES_QTY,
      P_RANGE IN T_TABLE_NUMBER DEFAULT NULL,
      P_LEVEL IN VARCHAR2 default null,
      P_TRANS_ID IN NUMBER default null,
      P_LI_ID IN NUMBER default null,
      P_TRANSACTION_KEY IN VARCHAR2 default null,
      P_LINE_ITEM_KEY IN VARCHAR2 default NULL,
      P_PROFIT_CENTER_ID IN VARCHAR2 DEFAULT NULL,
      P_VENDOR_ID IN VARCHAR2 DEFAULT NULL)
      RETURN T_TABLE_NUMBER;

END RPDP_REVN_IFAC_WRAPPER_PERIOD;

/



CREATE or REPLACE PACKAGE BODY RPDP_REVN_IFAC_WRAPPER_PERIOD
IS

   FUNCTION AGGREGATE(
      P_COLLECTION IN OUT T_TABLE_IFAC_SALES_QTY,
      P_BY IN VARCHAR2)
      RETURN T_TABLE_VARCHAR2
   IS
      ret_value    T_TABLE_VARCHAR2 ;
   BEGIN
      ret_value := ECDP_REVN_IFAC_WRAPPER_PERIOD.AGGREGATE      (
         P_COLLECTION,
         P_BY );
         RETURN ret_value;
   END AGGREGATE;
   FUNCTION FILTER(
      P_COLLECTION IN OUT T_TABLE_IFAC_SALES_QTY,
      P_CONDITION IN VARCHAR2)
      RETURN T_TABLE_IFAC_SALES_QTY
   IS
      ret_value    T_TABLE_IFAC_SALES_QTY ;
   BEGIN
      ret_value := ECDP_REVN_IFAC_WRAPPER_PERIOD.FILTER      (
         P_COLLECTION,
         P_CONDITION );
         RETURN ret_value;
   END FILTER;
   FUNCTION FIND_ONE(
      P_IFAC IN OUT T_TABLE_IFAC_SALES_QTY,
      P_RANGE IN T_TABLE_NUMBER DEFAULT NULL,
      P_LEVEL IN VARCHAR2 default null,
      P_TRANS_ID IN NUMBER default null,
      P_LI_ID IN NUMBER default null,
      P_TRANSACTION_KEY IN VARCHAR2 default null,
      P_LINE_ITEM_KEY IN VARCHAR2 default NULL,
      P_PROFIT_CENTER_ID IN VARCHAR2 DEFAULT NULL,
      P_VENDOR_ID IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_REVN_IFAC_WRAPPER_PERIOD.FIND_ONE      (
         P_IFAC,
         P_RANGE,
         P_LEVEL,
         P_TRANS_ID,
         P_LI_ID,
         P_TRANSACTION_KEY,
         P_LINE_ITEM_KEY,
         P_PROFIT_CENTER_ID,
         P_VENDOR_ID );
         RETURN ret_value;
   END FIND_ONE;
   FUNCTION GETIFACRELATESTO(
      P_SOURCE_ENTRY_NO IN NUMBER,
      P_SCOPE IN VARCHAR2)
      RETURN T_TABLE_IFAC_SALES_QTY
   IS
      ret_value    T_TABLE_IFAC_SALES_QTY ;
   BEGIN
      ret_value := ECDP_REVN_IFAC_WRAPPER_PERIOD.GETIFACRELATESTO      (
         P_SOURCE_ENTRY_NO,
         P_SCOPE );
         RETURN ret_value;
   END GETIFACRELATESTO;
   FUNCTION GETVENDORLEVELIFACRECORDS(
      P_RECORDS IN T_TABLE_IFAC_SALES_QTY,
      P_PC_LEVEL_RECORD IN T_IFAC_SALES_QTY,
      P_VENDOR_ID IN VARCHAR2 DEFAULT NULL)
      RETURN T_TABLE_IFAC_SALES_QTY
   IS
      ret_value    T_TABLE_IFAC_SALES_QTY ;
   BEGIN
      ret_value := ECDP_REVN_IFAC_WRAPPER_PERIOD.GETVENDORLEVELIFACRECORDS      (
         P_RECORDS,
         P_PC_LEVEL_RECORD,
         P_VENDOR_ID );
         RETURN ret_value;
   END GETVENDORLEVELIFACRECORDS;
   FUNCTION SORT(
      P_COLLECTION IN OUT T_TABLE_IFAC_SALES_QTY,
      P_BY IN VARCHAR2 DEFAULT NULL,
      P_DECODES IN VARCHAR2 DEFAULT NULL)
      RETURN T_TABLE_IFAC_SALES_QTY
   IS
      ret_value    T_TABLE_IFAC_SALES_QTY ;
   BEGIN
      ret_value := ECDP_REVN_IFAC_WRAPPER_PERIOD.SORT      (
         P_COLLECTION,
         P_BY,
         P_DECODES );
         RETURN ret_value;
   END SORT;
   FUNCTION GETIFACFORDOCUMENT(
      P_CONTRACT_ID IN VARCHAR2,
      P_DOCUMENT_SETUP_ID IN VARCHAR2,
      P_PROCESSING_PERIOD IN DATE,
      P_CUSTOMER_ID IN VARCHAR2,
      P_DOCUMENT_STATUS IN VARCHAR2)
      RETURN T_TABLE_IFAC_SALES_QTY
   IS
      ret_value    T_TABLE_IFAC_SALES_QTY ;
   BEGIN
      ret_value := ECDP_REVN_IFAC_WRAPPER_PERIOD.GETIFACFORDOCUMENT      (
         P_CONTRACT_ID,
         P_DOCUMENT_SETUP_ID,
         P_PROCESSING_PERIOD,
         P_CUSTOMER_ID,
         P_DOCUMENT_STATUS );
         RETURN ret_value;
   END GETIFACFORDOCUMENT;
   FUNCTION GETTRANSACTIONLEVELIFACRECORDS(
      P_RECORDS IN T_TABLE_IFAC_SALES_QTY)
      RETURN T_TABLE_IFAC_SALES_QTY
   IS
      ret_value    T_TABLE_IFAC_SALES_QTY ;
   BEGIN
      ret_value := ECDP_REVN_IFAC_WRAPPER_PERIOD.GETTRANSACTIONLEVELIFACRECORDS      (
         P_RECORDS );
         RETURN ret_value;
   END GETTRANSACTIONLEVELIFACRECORDS;
   FUNCTION GETPCLEVELIFACRECORDS(
      P_RECORDS IN T_TABLE_IFAC_SALES_QTY,
      P_TRANSACTION_LEVEL_RECORD IN T_IFAC_SALES_QTY,
      P_PROFIT_CENTER_ID IN VARCHAR2 DEFAULT NULL)
      RETURN T_TABLE_IFAC_SALES_QTY
   IS
      ret_value    T_TABLE_IFAC_SALES_QTY ;
   BEGIN
      ret_value := ECDP_REVN_IFAC_WRAPPER_PERIOD.GETPCLEVELIFACRECORDS      (
         P_RECORDS,
         P_TRANSACTION_LEVEL_RECORD,
         P_PROFIT_CENTER_ID );
         RETURN ret_value;
   END GETPCLEVELIFACRECORDS;
   FUNCTION IFACRECORDHASVENDORPC(
      P_SOURCE_ENTRY_NO IN NUMBER,
      P_VENDOR_ID IN VARCHAR2 default 'XX',
      P_PROFIT_CENTRE IN VARCHAR2 default 'XX')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_REVN_IFAC_WRAPPER_PERIOD.IFACRECORDHASVENDORPC      (
         P_SOURCE_ENTRY_NO,
         P_VENDOR_ID,
         P_PROFIT_CENTRE );
         RETURN ret_value;
   END IFACRECORDHASVENDORPC;
   FUNCTION FILTER(
      P_COLLECTION IN OUT T_TABLE_IFAC_SALES_QTY,
      P_LEVEL IN VARCHAR2,
      P_TRANS_ID IN NUMBER,
      P_LI_ID IN NUMBER,
      P_TRANSACTION_KEY IN VARCHAR2)
      RETURN T_TABLE_IFAC_SALES_QTY
   IS
      ret_value    T_TABLE_IFAC_SALES_QTY ;
   BEGIN
      ret_value := ECDP_REVN_IFAC_WRAPPER_PERIOD.FILTER      (
         P_COLLECTION,
         P_LEVEL,
         P_TRANS_ID,
         P_LI_ID,
         P_TRANSACTION_KEY );
         RETURN ret_value;
   END FILTER;
   FUNCTION FIND(
      P_IFAC IN OUT T_TABLE_IFAC_SALES_QTY,
      P_RANGE IN T_TABLE_NUMBER DEFAULT NULL,
      P_LEVEL IN VARCHAR2 default null,
      P_TRANS_ID IN NUMBER default null,
      P_LI_ID IN NUMBER default null,
      P_TRANSACTION_KEY IN VARCHAR2 default null,
      P_LINE_ITEM_KEY IN VARCHAR2 default NULL,
      P_PROFIT_CENTER_ID IN VARCHAR2 DEFAULT NULL,
      P_VENDOR_ID IN VARCHAR2 DEFAULT NULL)
      RETURN T_TABLE_NUMBER
   IS
      ret_value    T_TABLE_NUMBER ;
   BEGIN
      ret_value := ECDP_REVN_IFAC_WRAPPER_PERIOD.FIND      (
         P_IFAC,
         P_RANGE,
         P_LEVEL,
         P_TRANS_ID,
         P_LI_ID,
         P_TRANSACTION_KEY,
         P_LINE_ITEM_KEY,
         P_PROFIT_CENTER_ID,
         P_VENDOR_ID );
         RETURN ret_value;
   END FIND;

END RPDP_REVN_IFAC_WRAPPER_PERIOD;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_REVN_IFAC_WRAPPER_PERIOD TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.46.36 AM


