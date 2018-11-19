
 -- START PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.35.34 AM


CREATE or REPLACE PACKAGE RPBP_FLOWLINE_CHOKE
IS

   FUNCTION CONVERTTOMILLIMETER(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CHOKE_NATURAL IN NUMBER)
      RETURN NUMBER;

END RPBP_FLOWLINE_CHOKE;

/



CREATE or REPLACE PACKAGE BODY RPBP_FLOWLINE_CHOKE
IS

   FUNCTION CONVERTTOMILLIMETER(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CHOKE_NATURAL IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_FLOWLINE_CHOKE.CONVERTTOMILLIMETER      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CHOKE_NATURAL );
         RETURN ret_value;
   END CONVERTTOMILLIMETER;

END RPBP_FLOWLINE_CHOKE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPBP_FLOWLINE_CHOKE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.35.34 AM


