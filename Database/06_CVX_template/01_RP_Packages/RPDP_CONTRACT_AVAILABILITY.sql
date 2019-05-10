
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.50.54 AM


CREATE or REPLACE PACKAGE RPDP_CONTRACT_AVAILABILITY
IS

   FUNCTION GETCALCULATEDQTY(
      P_OBJECT_ID IN VARCHAR2,
      P_DELIVERY_POINT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARATOR_UOM IN VARCHAR2)
      RETURN NUMBER;

END RPDP_CONTRACT_AVAILABILITY;

/



CREATE or REPLACE PACKAGE BODY RPDP_CONTRACT_AVAILABILITY
IS

   FUNCTION GETCALCULATEDQTY(
      P_OBJECT_ID IN VARCHAR2,
      P_DELIVERY_POINT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARATOR_UOM IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_CONTRACT_AVAILABILITY.GETCALCULATEDQTY      (
         P_OBJECT_ID,
         P_DELIVERY_POINT_ID,
         P_DAYTIME,
         P_COMPARATOR_UOM );
         RETURN ret_value;
   END GETCALCULATEDQTY;

END RPDP_CONTRACT_AVAILABILITY;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_CONTRACT_AVAILABILITY TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.50.55 AM

