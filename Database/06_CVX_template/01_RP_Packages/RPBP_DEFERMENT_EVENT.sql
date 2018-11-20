
 -- START PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.36.01 AM


CREATE or REPLACE PACKAGE RPBP_DEFERMENT_EVENT
IS

   FUNCTION GETCURRENTACTION(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;

END RPBP_DEFERMENT_EVENT;

/



CREATE or REPLACE PACKAGE BODY RPBP_DEFERMENT_EVENT
IS

   FUNCTION GETCURRENTACTION(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECBP_DEFERMENT_EVENT.GETCURRENTACTION      (
         P_EVENT_NO );
         RETURN ret_value;
   END GETCURRENTACTION;

END RPBP_DEFERMENT_EVENT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPBP_DEFERMENT_EVENT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.36.02 AM

