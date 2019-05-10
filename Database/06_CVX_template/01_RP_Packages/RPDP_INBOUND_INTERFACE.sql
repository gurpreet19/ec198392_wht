
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.48.50 AM


CREATE or REPLACE PACKAGE RPDP_INBOUND_INTERFACE
IS

   FUNCTION GETQTYALLOCNO(
      P_PRODUCT IN VARCHAR2,
      P_COMPANY IN VARCHAR2,
      P_PROFIT_CENTER IN VARCHAR2,
      P_SI_CATEGORY IN VARCHAR2,
      P_DAY_MTH IN VARCHAR2,
      P_NODE IN VARCHAR2,
      P_STREAM_ITEM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION ISOBJECTCODEINOBJECTLIST(
      P_OBJECT_CODE IN VARCHAR2,
      P_OBJECT_LIST_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2;
   FUNCTION GETIFACRECORDLEVEL(
      P_PROFIT_CENTER_CODE IN VARCHAR2,
      P_VENDOR_CODE IN VARCHAR2,
      P_CONTRACT_COMP IN VARCHAR2,
      P_OBJECT_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
      TYPE REC_REANALYSECARGORECORD IS RECORD (
         CONTRACT_CODE VARCHAR2 (240) ,
         CARGO_NO VARCHAR2 (240) ,
         PARCEL_NO VARCHAR2 (240) ,
         VENDOR_CODE VARCHAR2 (240) ,
         QTY_TYPE VARCHAR2 (240) ,
         PROFIT_CENTER_CODE VARCHAR2 (240) ,
         ALLOC_NO NUMBER ,
         SO_NUMBER VARCHAR2 (240) ,
         LOADING_DATE  DATE ,
         LOADING_COMM_DATE  DATE ,
         DELIVERY_DATE  DATE ,
         DELIVERY_COMM_DATE  DATE ,
         POINT_OF_SALE_DATE  DATE ,
         BL_DATE  DATE ,
         PRICE_DATE  DATE ,
         PRICE_OBJECT_CODE VARCHAR2 (32) ,
         PRICE_OBJECT_ID VARCHAR2 (32) ,
         PRICE_STATUS VARCHAR2 (32) ,
         PRICING_VALUE NUMBER ,
         DISCHARGE_BERTH_CODE VARCHAR2 (240) ,
         LOADING_BERTH_CODE VARCHAR2 (240) ,
         DISCHARGE_PORT_CODE VARCHAR2 (240) ,
         LOADING_PORT_CODE VARCHAR2 (240) ,
         CONSIGNOR_CODE VARCHAR2 (240) ,
         CONSIGNEE_CODE VARCHAR2 (240) ,
         CARRIER_CODE VARCHAR2 (240) ,
         VOYAGE_NO VARCHAR2 (240) ,
         PRODUCT_CODE VARCHAR2 (240) ,
         PRICE_CONCEPT_CODE VARCHAR2 (240) ,
         LINE_ITEM_CODE VARCHAR2 (32) ,
         LINE_ITEM_BASED_TYPE VARCHAR2 (32) ,
         LINE_ITEM_TEMPLATE_ID VARCHAR2 (32) ,
         UNIT_PRICE_UNIT VARCHAR2 (32) ,
         INT_TYPE VARCHAR2 (32) ,
         INT_BASE_AMOUNT NUMBER ,
         INT_COMPOUNDING_PERIOD NUMBER ,
         INT_BASE_RATE NUMBER ,
         INT_RATE_OFFSET NUMBER ,
         INT_FROM_DATE  DATE ,
         INT_TO_DATE  DATE ,
         PERCENTAGE_VALUE NUMBER ,
         PERCENTAGE_BASE_AMOUNT NUMBER ,
         LI_PRICE_OBJECT_CODE VARCHAR2 (32) ,
         LI_PRICE_OBJECT_ID VARCHAR2 (32) ,
         LINE_ITEM_TYPE VARCHAR2 (32) ,
         LINE_ITEM_KEY VARCHAR2 (32) ,
         NET_QTY1 NUMBER ,
         GRS_QTY1 NUMBER ,
         UOM1_CODE VARCHAR2 (240) ,
         NET_QTY2 NUMBER ,
         GRS_QTY2 NUMBER ,
         UOM2_CODE VARCHAR2 (240) ,
         NET_QTY3 NUMBER ,
         GRS_QTY3 NUMBER ,
         UOM3_CODE VARCHAR2 (240) ,
         NET_QTY4 NUMBER ,
         GRS_QTY4 NUMBER ,
         UOM4_CODE VARCHAR2 (240) ,
         STATUS VARCHAR2 (240) ,
         DESCRIPTION VARCHAR2 (240) ,
         CARRIER_ID VARCHAR2 (32) ,
         CONSIGNEE_ID VARCHAR2 (32) ,
         CONSIGNOR_ID VARCHAR2 (32) ,
         CONTRACT_ID VARCHAR2 (32) ,
         DISCHARGE_BERTH_ID VARCHAR2 (32) ,
         DISCHARGE_PORT_ID VARCHAR2 (32) ,
         DOC_SETUP_CODE VARCHAR2 (32) ,
         DOC_SETUP_ID VARCHAR2 (32) ,
         DOC_STATUS VARCHAR2 (32) ,
         IGNORE_IND VARCHAR2 (1) ,
         LOADING_BERTH_ID VARCHAR2 (32) ,
         LOADING_PORT_ID VARCHAR2 (32) ,
         PRECEDING_DOC_KEY VARCHAR2 (32) ,
         PRECEDING_TRANS_KEY VARCHAR2 (32) ,
         PRECEDING_LI_KEY VARCHAR2 (32) ,
         PRODUCT_ID VARCHAR2 (32) ,
         PRODUCT_SALES_ORDER_ID VARCHAR2 (32) ,
         PROFIT_CENTER_ID VARCHAR2 (32) ,
         PRODUCT_SALES_ORDER_CODE VARCHAR2 (240) ,
         SOURCE_ENTRY_NO NUMBER ,
         SOURCE_NODE_CODE VARCHAR2 (32) ,
         SOURCE_NODE_ID VARCHAR2 (32) ,
         TRANSACTION_KEY VARCHAR2 (32) ,
         TRANS_TEMP_CODE VARCHAR2 (32) ,
         TRANS_TEMP_ID VARCHAR2 (32) ,
         TRANS_TEMP_CODE_OVRD VARCHAR2 (32) ,
         TRANS_TEMP_ID_OVRD VARCHAR2 (32) ,
         UNIT_PRICE NUMBER ,
         VENDOR_ID VARCHAR2 (32) ,
         VAT_CODE VARCHAR2 (32) ,
         IFAC_TT_CONN_CODE VARCHAR2 (32) ,
         IFAC_LI_CONN_CODE VARCHAR2 (32) ,
         ALLOC_NO_MAX_IND VARCHAR2 (1) ,
         TRANS_KEY_SET_IND VARCHAR2 (1) ,
         ORIGINAL_IFAC_DATA  CLOB ,
         CUSTOMER_CODE VARCHAR2 (32) ,
         CUSTOMER_ID VARCHAR2 (32) ,
         DOCUMENT_KEY VARCHAR2 (32) ,
         DIST_TYPE VARCHAR2 (32) ,
         OBJECT_TYPE VARCHAR2 (32) ,
         TEXT_1 VARCHAR2 (240) ,
         TEXT_2 VARCHAR2 (240) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (240) ,
         TEXT_5 VARCHAR2 (240) ,
         TEXT_6 VARCHAR2 (240) ,
         TEXT_7 VARCHAR2 (240) ,
         TEXT_8 VARCHAR2 (240) ,
         TEXT_9 VARCHAR2 (240) ,
         TEXT_10 VARCHAR2 (240) ,
         VALUE_1 NUMBER ,
         VALUE_2 NUMBER ,
         VALUE_3 NUMBER ,
         VALUE_4 NUMBER ,
         VALUE_5 NUMBER ,
         VALUE_6 NUMBER ,
         VALUE_7 NUMBER ,
         VALUE_8 NUMBER ,
         VALUE_9 NUMBER ,
         VALUE_10 NUMBER ,
         DATE_1  DATE ,
         DATE_2  DATE ,
         DATE_3  DATE ,
         DATE_4  DATE ,
         DATE_5  DATE ,
         DATE_6  DATE ,
         DATE_7  DATE ,
         DATE_8  DATE ,
         DATE_9  DATE ,
         DATE_10  DATE ,
         REF_OBJECT_ID_1 VARCHAR2 (32) ,
         REF_OBJECT_ID_2 VARCHAR2 (32) ,
         REF_OBJECT_ID_3 VARCHAR2 (32) ,
         REF_OBJECT_ID_4 VARCHAR2 (32) ,
         REF_OBJECT_ID_5 VARCHAR2 (32) ,
         REF_OBJECT_ID_6 VARCHAR2 (32) ,
         REF_OBJECT_ID_7 VARCHAR2 (32) ,
         REF_OBJECT_ID_8 VARCHAR2 (32) ,
         REF_OBJECT_ID_9 VARCHAR2 (32) ,
         REF_OBJECT_ID_10 VARCHAR2 (32) ,
         LI_UNIQUE_KEY_1 VARCHAR2 (240) ,
         LI_UNIQUE_KEY_2 VARCHAR2 (240) ,
         RECORD_STATUS VARCHAR2 (1) ,
         CREATED_BY VARCHAR2 (30) ,
         CREATED_DATE  DATE ,
         LAST_UPDATED_BY VARCHAR2 (30) ,
         LAST_UPDATED_DATE  DATE ,
         REV_NO NUMBER ,
         REV_TEXT VARCHAR2 (2000) ,
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_DATE  DATE ,
         APPROVAL_STATE VARCHAR2 (1) ,
         REC_ID VARCHAR2 (32)  );
   FUNCTION GETALLIFACPOSSIBLETT(
      P_SOURCE_ENTRY_NO IN NUMBER,
      P_DOC_SETUP_ID IN VARCHAR2,
      P_TYPE IN VARCHAR2)
      RETURN T_TABLE_MIXED_DATA;
      TYPE REC_REANALYSESALESQTYRECORD IS RECORD (
         CONTRACT_CODE VARCHAR2 (240) ,
         CARGO_NO VARCHAR2 (240) ,
         PARCEL_NO VARCHAR2 (240) ,
         VENDOR_CODE VARCHAR2 (240) ,
         QTY_TYPE VARCHAR2 (240) ,
         PROFIT_CENTER_CODE VARCHAR2 (240) ,
         ALLOC_NO NUMBER ,
         SO_NUMBER VARCHAR2 (240) ,
         LOADING_DATE  DATE ,
         LOADING_COMM_DATE  DATE ,
         DELIVERY_DATE  DATE ,
         DELIVERY_COMM_DATE  DATE ,
         POINT_OF_SALE_DATE  DATE ,
         BL_DATE  DATE ,
         PRICE_DATE  DATE ,
         PRICE_OBJECT_CODE VARCHAR2 (32) ,
         PRICE_OBJECT_ID VARCHAR2 (32) ,
         PRICE_STATUS VARCHAR2 (32) ,
         PRICING_VALUE NUMBER ,
         DISCHARGE_BERTH_CODE VARCHAR2 (240) ,
         LOADING_BERTH_CODE VARCHAR2 (240) ,
         DISCHARGE_PORT_CODE VARCHAR2 (240) ,
         LOADING_PORT_CODE VARCHAR2 (240) ,
         CONSIGNOR_CODE VARCHAR2 (240) ,
         CONSIGNEE_CODE VARCHAR2 (240) ,
         CARRIER_CODE VARCHAR2 (240) ,
         VOYAGE_NO VARCHAR2 (240) ,
         PRODUCT_CODE VARCHAR2 (240) ,
         PRICE_CONCEPT_CODE VARCHAR2 (240) ,
         LINE_ITEM_CODE VARCHAR2 (32) ,
         LINE_ITEM_BASED_TYPE VARCHAR2 (32) ,
         LINE_ITEM_TEMPLATE_ID VARCHAR2 (32) ,
         UNIT_PRICE_UNIT VARCHAR2 (32) ,
         INT_TYPE VARCHAR2 (32) ,
         INT_BASE_AMOUNT NUMBER ,
         INT_COMPOUNDING_PERIOD NUMBER ,
         INT_BASE_RATE NUMBER ,
         INT_RATE_OFFSET NUMBER ,
         INT_FROM_DATE  DATE ,
         INT_TO_DATE  DATE ,
         PERCENTAGE_VALUE NUMBER ,
         PERCENTAGE_BASE_AMOUNT NUMBER ,
         LI_PRICE_OBJECT_CODE VARCHAR2 (32) ,
         LI_PRICE_OBJECT_ID VARCHAR2 (32) ,
         LINE_ITEM_TYPE VARCHAR2 (32) ,
         LINE_ITEM_KEY VARCHAR2 (32) ,
         NET_QTY1 NUMBER ,
         GRS_QTY1 NUMBER ,
         UOM1_CODE VARCHAR2 (240) ,
         NET_QTY2 NUMBER ,
         GRS_QTY2 NUMBER ,
         UOM2_CODE VARCHAR2 (240) ,
         NET_QTY3 NUMBER ,
         GRS_QTY3 NUMBER ,
         UOM3_CODE VARCHAR2 (240) ,
         NET_QTY4 NUMBER ,
         GRS_QTY4 NUMBER ,
         UOM4_CODE VARCHAR2 (240) ,
         STATUS VARCHAR2 (240) ,
         DESCRIPTION VARCHAR2 (240) ,
         CARRIER_ID VARCHAR2 (32) ,
         CONSIGNEE_ID VARCHAR2 (32) ,
         CONSIGNOR_ID VARCHAR2 (32) ,
         CONTRACT_ID VARCHAR2 (32) ,
         DISCHARGE_BERTH_ID VARCHAR2 (32) ,
         DISCHARGE_PORT_ID VARCHAR2 (32) ,
         DOC_SETUP_CODE VARCHAR2 (32) ,
         DOC_SETUP_ID VARCHAR2 (32) ,
         DOC_STATUS VARCHAR2 (32) ,
         IGNORE_IND VARCHAR2 (1) ,
         LOADING_BERTH_ID VARCHAR2 (32) ,
         LOADING_PORT_ID VARCHAR2 (32) ,
         PRECEDING_DOC_KEY VARCHAR2 (32) ,
         PRECEDING_TRANS_KEY VARCHAR2 (32) ,
         PRECEDING_LI_KEY VARCHAR2 (32) ,
         PRODUCT_ID VARCHAR2 (32) ,
         PRODUCT_SALES_ORDER_ID VARCHAR2 (32) ,
         PROFIT_CENTER_ID VARCHAR2 (32) ,
         PRODUCT_SALES_ORDER_CODE VARCHAR2 (240) ,
         SOURCE_ENTRY_NO NUMBER ,
         SOURCE_NODE_CODE VARCHAR2 (32) ,
         SOURCE_NODE_ID VARCHAR2 (32) ,
         TRANSACTION_KEY VARCHAR2 (32) ,
         TRANS_TEMP_CODE VARCHAR2 (32) ,
         TRANS_TEMP_ID VARCHAR2 (32) ,
         TRANS_TEMP_CODE_OVRD VARCHAR2 (32) ,
         TRANS_TEMP_ID_OVRD VARCHAR2 (32) ,
         UNIT_PRICE NUMBER ,
         VENDOR_ID VARCHAR2 (32) ,
         VAT_CODE VARCHAR2 (32) ,
         IFAC_TT_CONN_CODE VARCHAR2 (32) ,
         IFAC_LI_CONN_CODE VARCHAR2 (32) ,
         ALLOC_NO_MAX_IND VARCHAR2 (1) ,
         TRANS_KEY_SET_IND VARCHAR2 (1) ,
         ORIGINAL_IFAC_DATA  CLOB ,
         CUSTOMER_CODE VARCHAR2 (32) ,
         CUSTOMER_ID VARCHAR2 (32) ,
         DOCUMENT_KEY VARCHAR2 (32) ,
         DIST_TYPE VARCHAR2 (32) ,
         OBJECT_TYPE VARCHAR2 (32) ,
         TEXT_1 VARCHAR2 (240) ,
         TEXT_2 VARCHAR2 (240) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (240) ,
         TEXT_5 VARCHAR2 (240) ,
         TEXT_6 VARCHAR2 (240) ,
         TEXT_7 VARCHAR2 (240) ,
         TEXT_8 VARCHAR2 (240) ,
         TEXT_9 VARCHAR2 (240) ,
         TEXT_10 VARCHAR2 (240) ,
         VALUE_1 NUMBER ,
         VALUE_2 NUMBER ,
         VALUE_3 NUMBER ,
         VALUE_4 NUMBER ,
         VALUE_5 NUMBER ,
         VALUE_6 NUMBER ,
         VALUE_7 NUMBER ,
         VALUE_8 NUMBER ,
         VALUE_9 NUMBER ,
         VALUE_10 NUMBER ,
         DATE_1  DATE ,
         DATE_2  DATE ,
         DATE_3  DATE ,
         DATE_4  DATE ,
         DATE_5  DATE ,
         DATE_6  DATE ,
         DATE_7  DATE ,
         DATE_8  DATE ,
         DATE_9  DATE ,
         DATE_10  DATE ,
         REF_OBJECT_ID_1 VARCHAR2 (32) ,
         REF_OBJECT_ID_2 VARCHAR2 (32) ,
         REF_OBJECT_ID_3 VARCHAR2 (32) ,
         REF_OBJECT_ID_4 VARCHAR2 (32) ,
         REF_OBJECT_ID_5 VARCHAR2 (32) ,
         REF_OBJECT_ID_6 VARCHAR2 (32) ,
         REF_OBJECT_ID_7 VARCHAR2 (32) ,
         REF_OBJECT_ID_8 VARCHAR2 (32) ,
         REF_OBJECT_ID_9 VARCHAR2 (32) ,
         REF_OBJECT_ID_10 VARCHAR2 (32) ,
         LI_UNIQUE_KEY_1 VARCHAR2 (240) ,
         LI_UNIQUE_KEY_2 VARCHAR2 (240) ,
         RECORD_STATUS VARCHAR2 (1) ,
         CREATED_BY VARCHAR2 (30) ,
         CREATED_DATE  DATE ,
         LAST_UPDATED_BY VARCHAR2 (30) ,
         LAST_UPDATED_DATE  DATE ,
         REV_NO NUMBER ,
         REV_TEXT VARCHAR2 (2000) ,
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_DATE  DATE ,
         APPROVAL_STATE VARCHAR2 (1) ,
         REC_ID VARCHAR2 (32)  );
   FUNCTION VALIDATEINTERFACEDECCODE(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2,
      P_TABLE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALIDATEINTERFACEDECOBJECT(
      P_OBJECT_ID IN VARCHAR2,
      P_OBJECT_ID_BY_UK IN VARCHAR2,
      P_OBJECT_CODE IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_TABLE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETMAPPINGCODE(
      P_CODE IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_DAYTIME IN DATE DEFAULT Ecdp_Timestamp.getCurrentSysdate,
      P_SYSTEM IN VARCHAR2 default null)
      RETURN VARCHAR2;
   FUNCTION ISOBJECTINOBJECTLIST(
      P_OBJECT_ID IN VARCHAR2,
      P_OBJECT_LIST_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2;

END RPDP_INBOUND_INTERFACE;

/



CREATE or REPLACE PACKAGE BODY RPDP_INBOUND_INTERFACE
IS

   FUNCTION GETQTYALLOCNO(
      P_PRODUCT IN VARCHAR2,
      P_COMPANY IN VARCHAR2,
      P_PROFIT_CENTER IN VARCHAR2,
      P_SI_CATEGORY IN VARCHAR2,
      P_DAY_MTH IN VARCHAR2,
      P_NODE IN VARCHAR2,
      P_STREAM_ITEM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_INBOUND_INTERFACE.GETQTYALLOCNO      (
         P_PRODUCT,
         P_COMPANY,
         P_PROFIT_CENTER,
         P_SI_CATEGORY,
         P_DAY_MTH,
         P_NODE,
         P_STREAM_ITEM_CODE,
         P_DAYTIME );
         RETURN ret_value;
   END GETQTYALLOCNO;
   FUNCTION ISOBJECTCODEINOBJECTLIST(
      P_OBJECT_CODE IN VARCHAR2,
      P_OBJECT_LIST_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_INBOUND_INTERFACE.ISOBJECTCODEINOBJECTLIST      (
         P_OBJECT_CODE,
         P_OBJECT_LIST_ID,
         P_DAYTIME );
         RETURN ret_value;
   END ISOBJECTCODEINOBJECTLIST;
   FUNCTION GETIFACRECORDLEVEL(
      P_PROFIT_CENTER_CODE IN VARCHAR2,
      P_VENDOR_CODE IN VARCHAR2,
      P_CONTRACT_COMP IN VARCHAR2,
      P_OBJECT_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_INBOUND_INTERFACE.GETIFACRECORDLEVEL      (
         P_PROFIT_CENTER_CODE,
         P_VENDOR_CODE,
         P_CONTRACT_COMP,
         P_OBJECT_TYPE );
         RETURN ret_value;
   END GETIFACRECORDLEVEL;
   FUNCTION GETALLIFACPOSSIBLETT(
      P_SOURCE_ENTRY_NO IN NUMBER,
      P_DOC_SETUP_ID IN VARCHAR2,
      P_TYPE IN VARCHAR2)
      RETURN T_TABLE_MIXED_DATA
   IS
      ret_value    T_TABLE_MIXED_DATA ;
   BEGIN
      ret_value := ECDP_INBOUND_INTERFACE.GETALLIFACPOSSIBLETT      (
         P_SOURCE_ENTRY_NO,
         P_DOC_SETUP_ID,
         P_TYPE );
         RETURN ret_value;
   END GETALLIFACPOSSIBLETT;
   FUNCTION VALIDATEINTERFACEDECCODE(
      P_CODE IN VARCHAR2,
      P_CODE_TYPE IN VARCHAR2,
      P_TABLE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_INBOUND_INTERFACE.VALIDATEINTERFACEDECCODE      (
         P_CODE,
         P_CODE_TYPE,
         P_TABLE_NAME );
         RETURN ret_value;
   END VALIDATEINTERFACEDECCODE;
   FUNCTION VALIDATEINTERFACEDECOBJECT(
      P_OBJECT_ID IN VARCHAR2,
      P_OBJECT_ID_BY_UK IN VARCHAR2,
      P_OBJECT_CODE IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_TABLE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_INBOUND_INTERFACE.VALIDATEINTERFACEDECOBJECT      (
         P_OBJECT_ID,
         P_OBJECT_ID_BY_UK,
         P_OBJECT_CODE,
         P_CLASS_NAME,
         P_TABLE_NAME );
         RETURN ret_value;
   END VALIDATEINTERFACEDECOBJECT;
   FUNCTION GETMAPPINGCODE(
      P_CODE IN VARCHAR2,
      P_CLASS IN VARCHAR2,
      P_DAYTIME IN DATE DEFAULT Ecdp_Timestamp.getCurrentSysdate,
      P_SYSTEM IN VARCHAR2 default null)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_INBOUND_INTERFACE.GETMAPPINGCODE      (
         P_CODE,
         P_CLASS,
         P_DAYTIME,
         P_SYSTEM );
         RETURN ret_value;
   END GETMAPPINGCODE;
   FUNCTION ISOBJECTINOBJECTLIST(
      P_OBJECT_ID IN VARCHAR2,
      P_OBJECT_LIST_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_INBOUND_INTERFACE.ISOBJECTINOBJECTLIST      (
         P_OBJECT_ID,
         P_OBJECT_LIST_ID,
         P_DAYTIME );
         RETURN ret_value;
   END ISOBJECTINOBJECTLIST;

END RPDP_INBOUND_INTERFACE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_INBOUND_INTERFACE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.48.54 AM

