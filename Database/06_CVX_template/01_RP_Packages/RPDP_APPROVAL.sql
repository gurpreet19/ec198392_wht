
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.52.40 AM


CREATE or REPLACE PACKAGE RPDP_APPROVAL
IS

   FUNCTION CHANGEDCLASSCOLUMNS(
      P_CLASS_NAME IN VARCHAR2,
      P_REC_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION HASROWACCESS(
      P_CLASS_NAME IN VARCHAR2,
      P_REC_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION INAPPROVALMODE
      RETURN BOOLEAN;
   FUNCTION ISACCEPTING
      RETURN BOOLEAN;
   FUNCTION ISREJECTING
      RETURN BOOLEAN;

END RPDP_APPROVAL;

/



CREATE or REPLACE PACKAGE BODY RPDP_APPROVAL
IS

   FUNCTION CHANGEDCLASSCOLUMNS(
      P_CLASS_NAME IN VARCHAR2,
      P_REC_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_APPROVAL.CHANGEDCLASSCOLUMNS      (
         P_CLASS_NAME,
         P_REC_ID );
         RETURN ret_value;
   END CHANGEDCLASSCOLUMNS;
   FUNCTION HASROWACCESS(
      P_CLASS_NAME IN VARCHAR2,
      P_REC_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_APPROVAL.HASROWACCESS      (
         P_CLASS_NAME,
         P_REC_ID );
         RETURN ret_value;
   END HASROWACCESS;
   FUNCTION INAPPROVALMODE
      RETURN BOOLEAN
   IS
      ret_value    BOOLEAN ;
   BEGIN

         ret_value := ECDP_APPROVAL.INAPPROVALMODE ;
         RETURN ret_value;
   END INAPPROVALMODE;
   FUNCTION ISACCEPTING
      RETURN BOOLEAN
   IS
      ret_value    BOOLEAN ;
   BEGIN

         ret_value := ECDP_APPROVAL.ISACCEPTING ;
         RETURN ret_value;
   END ISACCEPTING;
   FUNCTION ISREJECTING
      RETURN BOOLEAN
   IS
      ret_value    BOOLEAN ;
   BEGIN

         ret_value := ECDP_APPROVAL.ISREJECTING ;
         RETURN ret_value;
   END ISREJECTING;

END RPDP_APPROVAL;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_APPROVAL TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.52.41 AM


