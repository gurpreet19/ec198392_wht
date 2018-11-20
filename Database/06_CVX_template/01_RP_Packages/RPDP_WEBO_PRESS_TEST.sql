
 -- START PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.18.30 AM


CREATE or REPLACE PACKAGE RPDP_WEBO_PRESS_TEST
IS

   FUNCTION ASSIGNNEXTGRADIENTSEQ(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION COUNTCHILDEVENT(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION GETDEPTHTOPRESS(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRAD_SEQ IN NUMBER)
      RETURN NUMBER;

END RPDP_WEBO_PRESS_TEST;

/



CREATE or REPLACE PACKAGE BODY RPDP_WEBO_PRESS_TEST
IS

   FUNCTION ASSIGNNEXTGRADIENTSEQ(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_WEBO_PRESS_TEST.ASSIGNNEXTGRADIENTSEQ      (
         P_EVENT_NO );
         RETURN ret_value;
   END ASSIGNNEXTGRADIENTSEQ;
   FUNCTION COUNTCHILDEVENT(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_WEBO_PRESS_TEST.COUNTCHILDEVENT      (
         P_EVENT_NO );
         RETURN ret_value;
   END COUNTCHILDEVENT;
   FUNCTION GETDEPTHTOPRESS(
      P_EVENT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_GRAD_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_WEBO_PRESS_TEST.GETDEPTHTOPRESS      (
         P_EVENT_NO,
         P_OBJECT_ID,
         P_GRAD_SEQ );
         RETURN ret_value;
   END GETDEPTHTOPRESS;

END RPDP_WEBO_PRESS_TEST;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_WEBO_PRESS_TEST TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.18.31 AM

