create or replace PACKAGE RP_CT_DG_REPORTING
IS

   FUNCTION DG_GET_DDG_RENOM(
      P_DELIVERY_POINT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;

END RP_CT_DG_REPORTING;
/
create or replace PACKAGE BODY RP_CT_DG_REPORTING
IS

   FUNCTION DG_GET_DDG_RENOM(
      P_DELIVERY_POINT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := UE_CT_DG_REPORTING.DG_GET_DDG_RENOM      (
         P_DELIVERY_POINT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END DG_GET_DDG_RENOM;

END RP_CT_DG_REPORTING;
/
