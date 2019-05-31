
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.16.11 AM


CREATE or REPLACE PACKAGE RP_FCST_ANALYSIS_COMMENT
IS

   FUNCTION SCENARIO_ANALYSIS_TYPE(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_3(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_16(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_18(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_21(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_27(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_30(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_37(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_47(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_48(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_51(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_59(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_67(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_71(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_76(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_78(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_82(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_89(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_23(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_28(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_42(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_46(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_5(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_56(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_60(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_61(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_68(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_74(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_77(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_92(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION OBJECT_ID(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_29(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_31(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_32(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_36(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_54(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_62(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_75(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_83(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_87(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_95(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION COMMENTS(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION COMPARISON_TYPE(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_COMMENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_COMMENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION VALUE_12(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_22(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_26(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_45(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_49(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_58(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_6(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_66(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_73(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_88(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_97(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_COMMENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_15(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_19(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_33(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_34(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_52(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_63(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_65(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_72(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_81(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_84(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_90(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_93(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_99(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_COMMENT_NO IN NUMBER)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         SCENARIO_ANALYSIS_TYPE VARCHAR2 (32) ,
         COMPARISON_TYPE VARCHAR2 (32) ,
         COMMENT_NO NUMBER ,
         COMMENTS VARCHAR2 (2000) ,
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
         VALUE_11 NUMBER ,
         VALUE_12 NUMBER ,
         VALUE_13 NUMBER ,
         VALUE_14 NUMBER ,
         VALUE_15 NUMBER ,
         VALUE_16 NUMBER ,
         VALUE_17 NUMBER ,
         VALUE_18 NUMBER ,
         VALUE_19 NUMBER ,
         VALUE_20 NUMBER ,
         VALUE_21 NUMBER ,
         VALUE_22 NUMBER ,
         VALUE_23 NUMBER ,
         VALUE_24 NUMBER ,
         VALUE_25 NUMBER ,
         VALUE_26 NUMBER ,
         VALUE_27 NUMBER ,
         VALUE_28 NUMBER ,
         VALUE_29 NUMBER ,
         VALUE_30 NUMBER ,
         VALUE_31 NUMBER ,
         VALUE_32 NUMBER ,
         VALUE_33 NUMBER ,
         VALUE_34 NUMBER ,
         VALUE_35 NUMBER ,
         VALUE_36 NUMBER ,
         VALUE_37 NUMBER ,
         VALUE_38 NUMBER ,
         VALUE_39 NUMBER ,
         VALUE_40 NUMBER ,
         VALUE_41 NUMBER ,
         VALUE_42 NUMBER ,
         VALUE_43 NUMBER ,
         VALUE_44 NUMBER ,
         VALUE_45 NUMBER ,
         VALUE_46 NUMBER ,
         VALUE_47 NUMBER ,
         VALUE_48 NUMBER ,
         VALUE_49 NUMBER ,
         VALUE_50 NUMBER ,
         VALUE_51 NUMBER ,
         VALUE_52 NUMBER ,
         VALUE_53 NUMBER ,
         VALUE_54 NUMBER ,
         VALUE_55 NUMBER ,
         VALUE_56 NUMBER ,
         VALUE_57 NUMBER ,
         VALUE_58 NUMBER ,
         VALUE_59 NUMBER ,
         VALUE_60 NUMBER ,
         VALUE_61 NUMBER ,
         VALUE_62 NUMBER ,
         VALUE_63 NUMBER ,
         VALUE_64 NUMBER ,
         VALUE_65 NUMBER ,
         VALUE_66 NUMBER ,
         VALUE_67 NUMBER ,
         VALUE_68 NUMBER ,
         VALUE_69 NUMBER ,
         VALUE_70 NUMBER ,
         VALUE_71 NUMBER ,
         VALUE_72 NUMBER ,
         VALUE_73 NUMBER ,
         VALUE_74 NUMBER ,
         VALUE_75 NUMBER ,
         VALUE_76 NUMBER ,
         VALUE_77 NUMBER ,
         VALUE_78 NUMBER ,
         VALUE_79 NUMBER ,
         VALUE_80 NUMBER ,
         VALUE_81 NUMBER ,
         VALUE_82 NUMBER ,
         VALUE_83 NUMBER ,
         VALUE_84 NUMBER ,
         VALUE_85 NUMBER ,
         VALUE_86 NUMBER ,
         VALUE_87 NUMBER ,
         VALUE_88 NUMBER ,
         VALUE_89 NUMBER ,
         VALUE_90 NUMBER ,
         VALUE_91 NUMBER ,
         VALUE_92 NUMBER ,
         VALUE_93 NUMBER ,
         VALUE_94 NUMBER ,
         VALUE_95 NUMBER ,
         VALUE_96 NUMBER ,
         VALUE_97 NUMBER ,
         VALUE_98 NUMBER ,
         VALUE_99 NUMBER ,
         VALUE_100 NUMBER ,
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
         REV_TEXT VARCHAR2 (240) ,
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_DATE  DATE ,
         APPROVAL_STATE VARCHAR2 (1) ,
         REC_ID VARCHAR2 (32)  );
   FUNCTION ROW_BY_PK(
      P_COMMENT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_13(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_17(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_2(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_20(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_25(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_55(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_70(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_85(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_91(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_COMMENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REC_ID(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_38(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_39(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_40(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_43(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_44(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_69(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_7(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_79(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_80(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_96(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_COMMENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION VALUE_10(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_100(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_11(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_14(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_24(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_35(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_41(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_50(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_53(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_57(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_64(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_86(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_94(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_98(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER;

END RP_FCST_ANALYSIS_COMMENT;

/



CREATE or REPLACE PACKAGE BODY RP_FCST_ANALYSIS_COMMENT
IS

   FUNCTION SCENARIO_ANALYSIS_TYPE(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.SCENARIO_ANALYSIS_TYPE      (
         P_COMMENT_NO );
         RETURN ret_value;
   END SCENARIO_ANALYSIS_TYPE;
   FUNCTION TEXT_3(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.TEXT_3      (
         P_COMMENT_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.TEXT_4      (
         P_COMMENT_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION VALUE_16(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_16      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_16;
   FUNCTION VALUE_18(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_18      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_18;
   FUNCTION VALUE_21(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_21      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_21;
   FUNCTION VALUE_27(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_27      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_27;
   FUNCTION VALUE_30(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_30      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_30;
   FUNCTION VALUE_37(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_37      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_37;
   FUNCTION VALUE_47(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_47      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_47;
   FUNCTION VALUE_48(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_48      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_48;
   FUNCTION VALUE_51(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_51      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_51;
   FUNCTION VALUE_59(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_59      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_59;
   FUNCTION VALUE_67(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_67      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_67;
   FUNCTION VALUE_71(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_71      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_71;
   FUNCTION VALUE_76(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_76      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_76;
   FUNCTION VALUE_78(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_78      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_78;
   FUNCTION VALUE_82(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_82      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_82;
   FUNCTION VALUE_89(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_89      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_89;
   FUNCTION APPROVAL_BY(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.APPROVAL_BY      (
         P_COMMENT_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.APPROVAL_STATE      (
         P_COMMENT_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_23(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_23      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_23;
   FUNCTION VALUE_28(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_28      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_28;
   FUNCTION VALUE_42(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_42      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_42;
   FUNCTION VALUE_46(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_46      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_46;
   FUNCTION VALUE_5(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_5      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION VALUE_56(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_56      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_56;
   FUNCTION VALUE_60(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_60      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_60;
   FUNCTION VALUE_61(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_61      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_61;
   FUNCTION VALUE_68(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_68      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_68;
   FUNCTION VALUE_74(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_74      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_74;
   FUNCTION VALUE_77(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_77      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_77;
   FUNCTION VALUE_92(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_92      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_92;
   FUNCTION OBJECT_ID(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.OBJECT_ID      (
         P_COMMENT_NO );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION VALUE_29(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_29      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_29;
   FUNCTION VALUE_31(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_31      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_31;
   FUNCTION VALUE_32(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_32      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_32;
   FUNCTION VALUE_36(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_36      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_36;
   FUNCTION VALUE_54(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_54      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_54;
   FUNCTION VALUE_62(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_62      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_62;
   FUNCTION VALUE_75(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_75      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_75;
   FUNCTION VALUE_83(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_83      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_83;
   FUNCTION VALUE_87(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_87      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_87;
   FUNCTION VALUE_95(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_95      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_95;
   FUNCTION COMMENTS(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.COMMENTS      (
         P_COMMENT_NO );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION COMPARISON_TYPE(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.COMPARISON_TYPE      (
         P_COMMENT_NO );
         RETURN ret_value;
   END COMPARISON_TYPE;
   FUNCTION DATE_3(
      P_COMMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.DATE_3      (
         P_COMMENT_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_COMMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.DATE_5      (
         P_COMMENT_NO );
         RETURN ret_value;
   END DATE_5;
   FUNCTION VALUE_12(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_12      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_12;
   FUNCTION VALUE_22(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_22      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_22;
   FUNCTION VALUE_26(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_26      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_26;
   FUNCTION VALUE_45(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_45      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_45;
   FUNCTION VALUE_49(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_49      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_49;
   FUNCTION VALUE_58(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_58      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_58;
   FUNCTION VALUE_6(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_6      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION VALUE_66(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_66      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_66;
   FUNCTION VALUE_73(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_73      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_73;
   FUNCTION VALUE_88(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_88      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_88;
   FUNCTION VALUE_97(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_97      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_97;
   FUNCTION DATE_2(
      P_COMMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.DATE_2      (
         P_COMMENT_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION RECORD_STATUS(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.RECORD_STATUS      (
         P_COMMENT_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_1      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION VALUE_15(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_15      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_15;
   FUNCTION VALUE_19(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_19      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_19;
   FUNCTION VALUE_33(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_33      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_33;
   FUNCTION VALUE_34(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_34      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_34;
   FUNCTION VALUE_52(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_52      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_52;
   FUNCTION VALUE_63(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_63      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_63;
   FUNCTION VALUE_65(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_65      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_65;
   FUNCTION VALUE_72(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_72      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_72;
   FUNCTION VALUE_81(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_81      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_81;
   FUNCTION VALUE_84(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_84      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_84;
   FUNCTION VALUE_90(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_90      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_90;
   FUNCTION VALUE_93(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_93      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_93;
   FUNCTION VALUE_99(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_99      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_99;
   FUNCTION APPROVAL_DATE(
      P_COMMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.APPROVAL_DATE      (
         P_COMMENT_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_COMMENT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.ROW_BY_PK      (
         P_COMMENT_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_13(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_13      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_13;
   FUNCTION VALUE_17(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_17      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_17;
   FUNCTION VALUE_2(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_2      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_20(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_20      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_20;
   FUNCTION VALUE_25(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_25      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_25;
   FUNCTION VALUE_3(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_3      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_4      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION VALUE_55(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_55      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_55;
   FUNCTION VALUE_70(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_70      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_70;
   FUNCTION VALUE_85(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_85      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_85;
   FUNCTION VALUE_91(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_91      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_91;
   FUNCTION DATE_4(
      P_COMMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.DATE_4      (
         P_COMMENT_NO );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.REC_ID      (
         P_COMMENT_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.TEXT_1      (
         P_COMMENT_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.TEXT_2      (
         P_COMMENT_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_38(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_38      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_38;
   FUNCTION VALUE_39(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_39      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_39;
   FUNCTION VALUE_40(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_40      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_40;
   FUNCTION VALUE_43(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_43      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_43;
   FUNCTION VALUE_44(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_44      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_44;
   FUNCTION VALUE_69(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_69      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_69;
   FUNCTION VALUE_7(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_7      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_79(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_79      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_79;
   FUNCTION VALUE_80(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_80      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_80;
   FUNCTION VALUE_9(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_9      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION VALUE_96(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_96      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_96;
   FUNCTION DATE_1(
      P_COMMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.DATE_1      (
         P_COMMENT_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION VALUE_10(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_10      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_100(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_100      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_100;
   FUNCTION VALUE_11(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_11      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_11;
   FUNCTION VALUE_14(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_14      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_14;
   FUNCTION VALUE_24(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_24      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_24;
   FUNCTION VALUE_35(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_35      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_35;
   FUNCTION VALUE_41(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_41      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_41;
   FUNCTION VALUE_50(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_50      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_50;
   FUNCTION VALUE_53(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_53      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_53;
   FUNCTION VALUE_57(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_57      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_57;
   FUNCTION VALUE_64(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_64      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_64;
   FUNCTION VALUE_8(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_8      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_8;
   FUNCTION VALUE_86(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_86      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_86;
   FUNCTION VALUE_94(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_94      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_94;
   FUNCTION VALUE_98(
      P_COMMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS_COMMENT.VALUE_98      (
         P_COMMENT_NO );
         RETURN ret_value;
   END VALUE_98;

END RP_FCST_ANALYSIS_COMMENT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_FCST_ANALYSIS_COMMENT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.16.34 AM


