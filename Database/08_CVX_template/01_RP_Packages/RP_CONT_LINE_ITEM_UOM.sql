
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.36.53 AM


CREATE or REPLACE PACKAGE RP_CONT_LINE_ITEM_UOM
IS

   FUNCTION NET_ENERGY_BE(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION NET_MASS_UV(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION NET_VOLUME_SF(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION TEXT_3(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION NET_ENERGY_WH(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION NET_MASS_MA(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_5(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION NET_ENERGY_TH(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION OBJECT_ID(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN DATE;
   FUNCTION DATE_5(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN DATE;
   FUNCTION NET_VOLUME_BI(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_6(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN DATE;
   FUNCTION NET_MASS_MV(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION RECORD_STATUS(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN DATE;
   FUNCTION NET_MASS_UA(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION NET_VOLUME_BM(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         LINE_ITEM_KEY VARCHAR2 (32) ,
         NET_ENERGY_JO NUMBER ,
         NET_ENERGY_TH NUMBER ,
         NET_ENERGY_WH NUMBER ,
         NET_MASS_MA NUMBER ,
         NET_MASS_MV NUMBER ,
         NET_MASS_UA NUMBER ,
         NET_MASS_UV NUMBER ,
         NET_VOLUME_BI NUMBER ,
         NET_VOLUME_BM NUMBER ,
         NET_VOLUME_SF NUMBER ,
         NET_VOLUME_NM NUMBER ,
         NET_VOLUME_SM NUMBER ,
         NET_ENERGY_BE NUMBER ,
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
         DATE_1  DATE ,
         DATE_2  DATE ,
         DATE_3  DATE ,
         DATE_4  DATE ,
         DATE_5  DATE ,
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
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN DATE;
   FUNCTION NET_ENERGY_JO(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION NET_VOLUME_SM(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN DATE;
   FUNCTION NET_VOLUME_NM(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_10(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER;

END RP_CONT_LINE_ITEM_UOM;

/



CREATE or REPLACE PACKAGE BODY RP_CONT_LINE_ITEM_UOM
IS

   FUNCTION NET_ENERGY_BE(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_LINE_ITEM_UOM.NET_ENERGY_BE      (
         P_LINE_ITEM_KEY );
         RETURN ret_value;
   END NET_ENERGY_BE;
   FUNCTION NET_MASS_UV(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_LINE_ITEM_UOM.NET_MASS_UV      (
         P_LINE_ITEM_KEY );
         RETURN ret_value;
   END NET_MASS_UV;
   FUNCTION NET_VOLUME_SF(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_LINE_ITEM_UOM.NET_VOLUME_SF      (
         P_LINE_ITEM_KEY );
         RETURN ret_value;
   END NET_VOLUME_SF;
   FUNCTION TEXT_3(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONT_LINE_ITEM_UOM.TEXT_3      (
         P_LINE_ITEM_KEY );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CONT_LINE_ITEM_UOM.TEXT_4      (
         P_LINE_ITEM_KEY );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CONT_LINE_ITEM_UOM.APPROVAL_BY      (
         P_LINE_ITEM_KEY );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CONT_LINE_ITEM_UOM.APPROVAL_STATE      (
         P_LINE_ITEM_KEY );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION NET_ENERGY_WH(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_LINE_ITEM_UOM.NET_ENERGY_WH      (
         P_LINE_ITEM_KEY );
         RETURN ret_value;
   END NET_ENERGY_WH;
   FUNCTION NET_MASS_MA(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_LINE_ITEM_UOM.NET_MASS_MA      (
         P_LINE_ITEM_KEY );
         RETURN ret_value;
   END NET_MASS_MA;
   FUNCTION VALUE_5(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_LINE_ITEM_UOM.VALUE_5      (
         P_LINE_ITEM_KEY );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION NET_ENERGY_TH(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_LINE_ITEM_UOM.NET_ENERGY_TH      (
         P_LINE_ITEM_KEY );
         RETURN ret_value;
   END NET_ENERGY_TH;
   FUNCTION OBJECT_ID(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_LINE_ITEM_UOM.OBJECT_ID      (
         P_LINE_ITEM_KEY );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION DATE_3(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_LINE_ITEM_UOM.DATE_3      (
         P_LINE_ITEM_KEY );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_LINE_ITEM_UOM.DATE_5      (
         P_LINE_ITEM_KEY );
         RETURN ret_value;
   END DATE_5;
   FUNCTION NET_VOLUME_BI(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_LINE_ITEM_UOM.NET_VOLUME_BI      (
         P_LINE_ITEM_KEY );
         RETURN ret_value;
   END NET_VOLUME_BI;
   FUNCTION VALUE_6(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_LINE_ITEM_UOM.VALUE_6      (
         P_LINE_ITEM_KEY );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION DATE_2(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_LINE_ITEM_UOM.DATE_2      (
         P_LINE_ITEM_KEY );
         RETURN ret_value;
   END DATE_2;
   FUNCTION NET_MASS_MV(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_LINE_ITEM_UOM.NET_MASS_MV      (
         P_LINE_ITEM_KEY );
         RETURN ret_value;
   END NET_MASS_MV;
   FUNCTION RECORD_STATUS(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CONT_LINE_ITEM_UOM.RECORD_STATUS      (
         P_LINE_ITEM_KEY );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_LINE_ITEM_UOM.VALUE_1      (
         P_LINE_ITEM_KEY );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_LINE_ITEM_UOM.APPROVAL_DATE      (
         P_LINE_ITEM_KEY );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION NET_MASS_UA(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_LINE_ITEM_UOM.NET_MASS_UA      (
         P_LINE_ITEM_KEY );
         RETURN ret_value;
   END NET_MASS_UA;
   FUNCTION NET_VOLUME_BM(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_LINE_ITEM_UOM.NET_VOLUME_BM      (
         P_LINE_ITEM_KEY );
         RETURN ret_value;
   END NET_VOLUME_BM;
   FUNCTION ROW_BY_PK(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CONT_LINE_ITEM_UOM.ROW_BY_PK      (
         P_LINE_ITEM_KEY );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_LINE_ITEM_UOM.VALUE_2      (
         P_LINE_ITEM_KEY );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_LINE_ITEM_UOM.VALUE_3      (
         P_LINE_ITEM_KEY );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_LINE_ITEM_UOM.VALUE_4      (
         P_LINE_ITEM_KEY );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_LINE_ITEM_UOM.DATE_4      (
         P_LINE_ITEM_KEY );
         RETURN ret_value;
   END DATE_4;
   FUNCTION NET_ENERGY_JO(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_LINE_ITEM_UOM.NET_ENERGY_JO      (
         P_LINE_ITEM_KEY );
         RETURN ret_value;
   END NET_ENERGY_JO;
   FUNCTION NET_VOLUME_SM(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_LINE_ITEM_UOM.NET_VOLUME_SM      (
         P_LINE_ITEM_KEY );
         RETURN ret_value;
   END NET_VOLUME_SM;
   FUNCTION REC_ID(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_LINE_ITEM_UOM.REC_ID      (
         P_LINE_ITEM_KEY );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_CONT_LINE_ITEM_UOM.TEXT_1      (
         P_LINE_ITEM_KEY );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_LINE_ITEM_UOM.TEXT_2      (
         P_LINE_ITEM_KEY );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_LINE_ITEM_UOM.VALUE_7      (
         P_LINE_ITEM_KEY );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_LINE_ITEM_UOM.VALUE_9      (
         P_LINE_ITEM_KEY );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DATE_1(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_LINE_ITEM_UOM.DATE_1      (
         P_LINE_ITEM_KEY );
         RETURN ret_value;
   END DATE_1;
   FUNCTION NET_VOLUME_NM(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_LINE_ITEM_UOM.NET_VOLUME_NM      (
         P_LINE_ITEM_KEY );
         RETURN ret_value;
   END NET_VOLUME_NM;
   FUNCTION VALUE_10(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_LINE_ITEM_UOM.VALUE_10      (
         P_LINE_ITEM_KEY );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_LINE_ITEM_KEY IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_LINE_ITEM_UOM.VALUE_8      (
         P_LINE_ITEM_KEY );
         RETURN ret_value;
   END VALUE_8;

END RP_CONT_LINE_ITEM_UOM;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CONT_LINE_ITEM_UOM TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.37.02 AM


