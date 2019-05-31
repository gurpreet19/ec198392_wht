
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 08.32.29 AM


CREATE or REPLACE PACKAGE RP_PARCEL_NOMINATION
IS

   FUNCTION GRS_VOL_NOMINATED(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NOM_CORRECT(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SORT_ORDER(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_3(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION BALANCE_FLAG(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CARRIER_ID(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NOM_FIRM_DATE(
      P_PARCEL_NO IN NUMBER)
      RETURN DATE;
   FUNCTION NOM_TENTATIVE_DATE(
      P_PARCEL_NO IN NUMBER)
      RETURN DATE;
   FUNCTION VALUE_5(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION LIFTING_SPLIT_PCT(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NET_MASS(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NOM_MONTH(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PARCEL_LOAD_NO(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION COMMENTS(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DISCHARGE_NO(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DISCHARGE_PCT(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DOC_SCHEDULE_NO(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION LIFTING_SEQ(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NET_VOL(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION PARCEL_CODE(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_6(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION CARGO_NO(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION COMMENCED_LOADING(
      P_PARCEL_NO IN NUMBER)
      RETURN DATE;
   FUNCTION COMPANY_ID(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION COMPLETED_LOADING(
      P_PARCEL_NO IN NUMBER)
      RETURN DATE;
   FUNCTION LOAD_EXACT(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NOM_SEQUENCE(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION RECORD_STATUS(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SPECIAL_INSTRUCTIONS(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_PARCEL_NO IN NUMBER)
      RETURN DATE;
   FUNCTION BALANCE_IND(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION LIFTING_SPLIT_CODE(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION MAXIMUM_GRS_VOL(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION REQUESTED_DATE(
      P_PARCEL_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REQUESTED_DATE_RANGE(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         PARCEL_NO NUMBER ,
         PARCEL_CODE VARCHAR2 (16) ,
         STORAGE_ID VARCHAR2 (32) ,
         CARGO_NO NUMBER ,
         PARCEL_LOAD_NO NUMBER ,
         COMPANY_ID VARCHAR2 (32) ,
         CARRIER_ID VARCHAR2 (32) ,
         DISCHARGE_NO NUMBER ,
         WHAT_IF_DATE  DATE ,
         REQUESTED_DATE  DATE ,
         REQUESTED_DATE_RANGE VARCHAR2 (8) ,
         GRS_VOL_REQUESTED NUMBER ,
         NOMINATION_STAGE VARCHAR2 (8) ,
         NOM_CORRECT VARCHAR2 (1) ,
         NOM_MONTH VARCHAR2 (8) ,
         NOM_FIRM_DATE  DATE ,
         NOM_FIRM_DATE_RANGE VARCHAR2 (8) ,
         NOM_SEQUENCE NUMBER ,
         NOM_TENTATIVE_DATE  DATE ,
         GRS_VOL_TENTATIVE NUMBER ,
         GRS_VOL_NOMINATED NUMBER ,
         SCHEDULE_DATE_RANGE VARCHAR2 (8) ,
         SCHEDULE_DATE  DATE ,
         MINIMUM_GRS_VOL NUMBER ,
         MAXIMUM_GRS_VOL NUMBER ,
         LOAD_EXACT VARCHAR2 (1) ,
         LIFTING_SEQ NUMBER ,
         LIFTING_SPLIT_CODE VARCHAR2 (16) ,
         LIFTING_SPLIT_PCT NUMBER ,
         LIFTING_SHORT_NAME VARCHAR2 (30) ,
         COMMENCED_LOADING  DATE ,
         COMPLETED_LOADING  DATE ,
         GRS_VOL NUMBER ,
         NET_VOL NUMBER ,
         GRS_MASS NUMBER ,
         NET_MASS NUMBER ,
         SPECIAL_INSTRUCTIONS VARCHAR2 (2000) ,
         CONSIGNOR_NAME VARCHAR2 (255) ,
         CONSIGNEE_NAME VARCHAR2 (255) ,
         DOC_SCHEDULE_NO VARCHAR2 (16) ,
         DOC_REF VARCHAR2 (30) ,
         TELEX_REF VARCHAR2 (30) ,
         GRAPH_VALUE NUMBER ,
         DISCHARGE_PCT NUMBER ,
         BALANCE_IND VARCHAR2 (1) ,
         BALANCE_FLAG VARCHAR2 (3) ,
         SORT_ORDER NUMBER ,
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
         TEXT_1 VARCHAR2 (16) ,
         TEXT_2 VARCHAR2 (32) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (2000) ,
         COMMENTS VARCHAR2 (2000) ,
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
   FUNCTION ROW_BY_PK(
      P_PARCEL_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION SCHEDULE_DATE(
      P_PARCEL_NO IN NUMBER)
      RETURN DATE;
   FUNCTION VALUE_2(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION WHAT_IF_DATE(
      P_PARCEL_NO IN NUMBER)
      RETURN DATE;
   FUNCTION CONSIGNEE_NAME(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION GRAPH_VALUE(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION GRS_MASS(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION GRS_VOL(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION GRS_VOL_TENTATIVE(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION LIFTING_SHORT_NAME(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION MINIMUM_GRS_VOL(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TELEX_REF(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION CONSIGNOR_NAME(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DOC_REF(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION GRS_VOL_REQUESTED(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NOMINATION_STAGE(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NOM_FIRM_DATE_RANGE(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SCHEDULE_DATE_RANGE(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION STORAGE_ID(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER;

END RP_PARCEL_NOMINATION;

/



CREATE or REPLACE PACKAGE BODY RP_PARCEL_NOMINATION
IS

   FUNCTION GRS_VOL_NOMINATED(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.GRS_VOL_NOMINATED      (
         P_PARCEL_NO );
         RETURN ret_value;
   END GRS_VOL_NOMINATED;
   FUNCTION NOM_CORRECT(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.NOM_CORRECT      (
         P_PARCEL_NO );
         RETURN ret_value;
   END NOM_CORRECT;
   FUNCTION SORT_ORDER(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.SORT_ORDER      (
         P_PARCEL_NO );
         RETURN ret_value;
   END SORT_ORDER;
   FUNCTION TEXT_3(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.TEXT_3      (
         P_PARCEL_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.TEXT_4      (
         P_PARCEL_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.APPROVAL_BY      (
         P_PARCEL_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.APPROVAL_STATE      (
         P_PARCEL_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION BALANCE_FLAG(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (3) ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.BALANCE_FLAG      (
         P_PARCEL_NO );
         RETURN ret_value;
   END BALANCE_FLAG;
   FUNCTION CARRIER_ID(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.CARRIER_ID      (
         P_PARCEL_NO );
         RETURN ret_value;
   END CARRIER_ID;
   FUNCTION NOM_FIRM_DATE(
      P_PARCEL_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.NOM_FIRM_DATE      (
         P_PARCEL_NO );
         RETURN ret_value;
   END NOM_FIRM_DATE;
   FUNCTION NOM_TENTATIVE_DATE(
      P_PARCEL_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.NOM_TENTATIVE_DATE      (
         P_PARCEL_NO );
         RETURN ret_value;
   END NOM_TENTATIVE_DATE;
   FUNCTION VALUE_5(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.VALUE_5      (
         P_PARCEL_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION LIFTING_SPLIT_PCT(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.LIFTING_SPLIT_PCT      (
         P_PARCEL_NO );
         RETURN ret_value;
   END LIFTING_SPLIT_PCT;
   FUNCTION NET_MASS(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.NET_MASS      (
         P_PARCEL_NO );
         RETURN ret_value;
   END NET_MASS;
   FUNCTION NOM_MONTH(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (8) ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.NOM_MONTH      (
         P_PARCEL_NO );
         RETURN ret_value;
   END NOM_MONTH;
   FUNCTION PARCEL_LOAD_NO(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.PARCEL_LOAD_NO      (
         P_PARCEL_NO );
         RETURN ret_value;
   END PARCEL_LOAD_NO;
   FUNCTION COMMENTS(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.COMMENTS      (
         P_PARCEL_NO );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION DISCHARGE_NO(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.DISCHARGE_NO      (
         P_PARCEL_NO );
         RETURN ret_value;
   END DISCHARGE_NO;
   FUNCTION DISCHARGE_PCT(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.DISCHARGE_PCT      (
         P_PARCEL_NO );
         RETURN ret_value;
   END DISCHARGE_PCT;
   FUNCTION DOC_SCHEDULE_NO(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.DOC_SCHEDULE_NO      (
         P_PARCEL_NO );
         RETURN ret_value;
   END DOC_SCHEDULE_NO;
   FUNCTION LIFTING_SEQ(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.LIFTING_SEQ      (
         P_PARCEL_NO );
         RETURN ret_value;
   END LIFTING_SEQ;
   FUNCTION NET_VOL(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.NET_VOL      (
         P_PARCEL_NO );
         RETURN ret_value;
   END NET_VOL;
   FUNCTION PARCEL_CODE(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.PARCEL_CODE      (
         P_PARCEL_NO );
         RETURN ret_value;
   END PARCEL_CODE;
   FUNCTION VALUE_6(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.VALUE_6      (
         P_PARCEL_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION CARGO_NO(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.CARGO_NO      (
         P_PARCEL_NO );
         RETURN ret_value;
   END CARGO_NO;
   FUNCTION COMMENCED_LOADING(
      P_PARCEL_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.COMMENCED_LOADING      (
         P_PARCEL_NO );
         RETURN ret_value;
   END COMMENCED_LOADING;
   FUNCTION COMPANY_ID(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.COMPANY_ID      (
         P_PARCEL_NO );
         RETURN ret_value;
   END COMPANY_ID;
   FUNCTION COMPLETED_LOADING(
      P_PARCEL_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.COMPLETED_LOADING      (
         P_PARCEL_NO );
         RETURN ret_value;
   END COMPLETED_LOADING;
   FUNCTION LOAD_EXACT(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.LOAD_EXACT      (
         P_PARCEL_NO );
         RETURN ret_value;
   END LOAD_EXACT;
   FUNCTION NOM_SEQUENCE(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.NOM_SEQUENCE      (
         P_PARCEL_NO );
         RETURN ret_value;
   END NOM_SEQUENCE;
   FUNCTION RECORD_STATUS(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.RECORD_STATUS      (
         P_PARCEL_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION SPECIAL_INSTRUCTIONS(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.SPECIAL_INSTRUCTIONS      (
         P_PARCEL_NO );
         RETURN ret_value;
   END SPECIAL_INSTRUCTIONS;
   FUNCTION VALUE_1(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.VALUE_1      (
         P_PARCEL_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_PARCEL_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.APPROVAL_DATE      (
         P_PARCEL_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION BALANCE_IND(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.BALANCE_IND      (
         P_PARCEL_NO );
         RETURN ret_value;
   END BALANCE_IND;
   FUNCTION LIFTING_SPLIT_CODE(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.LIFTING_SPLIT_CODE      (
         P_PARCEL_NO );
         RETURN ret_value;
   END LIFTING_SPLIT_CODE;
   FUNCTION MAXIMUM_GRS_VOL(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.MAXIMUM_GRS_VOL      (
         P_PARCEL_NO );
         RETURN ret_value;
   END MAXIMUM_GRS_VOL;
   FUNCTION REQUESTED_DATE(
      P_PARCEL_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.REQUESTED_DATE      (
         P_PARCEL_NO );
         RETURN ret_value;
   END REQUESTED_DATE;
   FUNCTION REQUESTED_DATE_RANGE(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (8) ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.REQUESTED_DATE_RANGE      (
         P_PARCEL_NO );
         RETURN ret_value;
   END REQUESTED_DATE_RANGE;
   FUNCTION ROW_BY_PK(
      P_PARCEL_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.ROW_BY_PK      (
         P_PARCEL_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION SCHEDULE_DATE(
      P_PARCEL_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.SCHEDULE_DATE      (
         P_PARCEL_NO );
         RETURN ret_value;
   END SCHEDULE_DATE;
   FUNCTION VALUE_2(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.VALUE_2      (
         P_PARCEL_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.VALUE_3      (
         P_PARCEL_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.VALUE_4      (
         P_PARCEL_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION WHAT_IF_DATE(
      P_PARCEL_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.WHAT_IF_DATE      (
         P_PARCEL_NO );
         RETURN ret_value;
   END WHAT_IF_DATE;
   FUNCTION CONSIGNEE_NAME(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (255) ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.CONSIGNEE_NAME      (
         P_PARCEL_NO );
         RETURN ret_value;
   END CONSIGNEE_NAME;
   FUNCTION GRAPH_VALUE(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.GRAPH_VALUE      (
         P_PARCEL_NO );
         RETURN ret_value;
   END GRAPH_VALUE;
   FUNCTION GRS_MASS(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.GRS_MASS      (
         P_PARCEL_NO );
         RETURN ret_value;
   END GRS_MASS;
   FUNCTION GRS_VOL(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.GRS_VOL      (
         P_PARCEL_NO );
         RETURN ret_value;
   END GRS_VOL;
   FUNCTION GRS_VOL_TENTATIVE(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.GRS_VOL_TENTATIVE      (
         P_PARCEL_NO );
         RETURN ret_value;
   END GRS_VOL_TENTATIVE;
   FUNCTION LIFTING_SHORT_NAME(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.LIFTING_SHORT_NAME      (
         P_PARCEL_NO );
         RETURN ret_value;
   END LIFTING_SHORT_NAME;
   FUNCTION MINIMUM_GRS_VOL(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.MINIMUM_GRS_VOL      (
         P_PARCEL_NO );
         RETURN ret_value;
   END MINIMUM_GRS_VOL;
   FUNCTION REC_ID(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.REC_ID      (
         P_PARCEL_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TELEX_REF(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.TELEX_REF      (
         P_PARCEL_NO );
         RETURN ret_value;
   END TELEX_REF;
   FUNCTION TEXT_1(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.TEXT_1      (
         P_PARCEL_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.TEXT_2      (
         P_PARCEL_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.VALUE_7      (
         P_PARCEL_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.VALUE_9      (
         P_PARCEL_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION CONSIGNOR_NAME(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (255) ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.CONSIGNOR_NAME      (
         P_PARCEL_NO );
         RETURN ret_value;
   END CONSIGNOR_NAME;
   FUNCTION DOC_REF(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.DOC_REF      (
         P_PARCEL_NO );
         RETURN ret_value;
   END DOC_REF;
   FUNCTION GRS_VOL_REQUESTED(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.GRS_VOL_REQUESTED      (
         P_PARCEL_NO );
         RETURN ret_value;
   END GRS_VOL_REQUESTED;
   FUNCTION NOMINATION_STAGE(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (8) ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.NOMINATION_STAGE      (
         P_PARCEL_NO );
         RETURN ret_value;
   END NOMINATION_STAGE;
   FUNCTION NOM_FIRM_DATE_RANGE(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (8) ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.NOM_FIRM_DATE_RANGE      (
         P_PARCEL_NO );
         RETURN ret_value;
   END NOM_FIRM_DATE_RANGE;
   FUNCTION SCHEDULE_DATE_RANGE(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (8) ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.SCHEDULE_DATE_RANGE      (
         P_PARCEL_NO );
         RETURN ret_value;
   END SCHEDULE_DATE_RANGE;
   FUNCTION STORAGE_ID(
      P_PARCEL_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.STORAGE_ID      (
         P_PARCEL_NO );
         RETURN ret_value;
   END STORAGE_ID;
   FUNCTION VALUE_10(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.VALUE_10      (
         P_PARCEL_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_PARCEL_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PARCEL_NOMINATION.VALUE_8      (
         P_PARCEL_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_PARCEL_NOMINATION;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_PARCEL_NOMINATION TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 08.32.50 AM


