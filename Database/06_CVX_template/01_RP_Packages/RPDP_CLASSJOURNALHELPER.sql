
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.51.27 AM


CREATE or REPLACE PACKAGE RPDP_CLASSJOURNALHELPER
IS

   FUNCTION MAKEJOURNALRULESECTION(
      P_CLASS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION MAKEOBJECTRULESECTION(
      P_CLASS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION MAKEOBJECTREVTEXTSECTION(
      P_CLASS_NAME IN VARCHAR2)
      RETURN VARCHAR2;

END RPDP_CLASSJOURNALHELPER;

/



CREATE or REPLACE PACKAGE BODY RPDP_CLASSJOURNALHELPER
IS

   FUNCTION MAKEJOURNALRULESECTION(
      P_CLASS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSJOURNALHELPER.MAKEJOURNALRULESECTION      (
         P_CLASS_NAME );
         RETURN ret_value;
   END MAKEJOURNALRULESECTION;
   FUNCTION MAKEOBJECTRULESECTION(
      P_CLASS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSJOURNALHELPER.MAKEOBJECTRULESECTION      (
         P_CLASS_NAME );
         RETURN ret_value;
   END MAKEOBJECTRULESECTION;
   FUNCTION MAKEOBJECTREVTEXTSECTION(
      P_CLASS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSJOURNALHELPER.MAKEOBJECTREVTEXTSECTION      (
         P_CLASS_NAME );
         RETURN ret_value;
   END MAKEOBJECTREVTEXTSECTION;

END RPDP_CLASSJOURNALHELPER;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_CLASSJOURNALHELPER TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.51.28 AM


