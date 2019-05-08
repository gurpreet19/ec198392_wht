
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.50.06 AM


CREATE or REPLACE PACKAGE RPDP_DEFER_LOSS_ACCOUNTING
IS

   FUNCTION CALCKBOE(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION CALCDURATION(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_END_DATE IN DATE)
      RETURN VARCHAR2;
   FUNCTION CALCSTRMDURATION(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;

END RPDP_DEFER_LOSS_ACCOUNTING;

/



CREATE or REPLACE PACKAGE BODY RPDP_DEFER_LOSS_ACCOUNTING
IS

   FUNCTION CALCKBOE(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_DEFER_LOSS_ACCOUNTING.CALCKBOE      (
         P_EVENT_NO,
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END CALCKBOE;
   FUNCTION CALCDURATION(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_END_DATE IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_DEFER_LOSS_ACCOUNTING.CALCDURATION      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_END_DATE );
         RETURN ret_value;
   END CALCDURATION;
   FUNCTION CALCSTRMDURATION(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_DEFER_LOSS_ACCOUNTING.CALCSTRMDURATION      (
         P_EVENT_NO,
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END CALCSTRMDURATION;

END RPDP_DEFER_LOSS_ACCOUNTING;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_DEFER_LOSS_ACCOUNTING TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.50.07 AM


