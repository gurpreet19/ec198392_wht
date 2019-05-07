create or replace PACKAGE RP_CT_DG_NOMINATIONS
IS

   FUNCTION getPAADQ(p_object_id VARCHAR2, p_daytime DATE, p_offset NUMBER DEFAULT 8) RETURN NUMBER;

END RP_CT_DG_NOMINATIONS;
/
create or replace PACKAGE BODY RP_CT_DG_NOMINATIONS
IS

   FUNCTION getPAADQ(p_object_id VARCHAR2, p_daytime DATE, p_offset NUMBER DEFAULT 8) RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := UE_CT_DG_NOMINATIONS.getPAADQ      (
         p_object_id,
         P_DAYTIME,
		 p_offset);
         RETURN ret_value;
   END getPAADQ;

END RP_CT_DG_NOMINATIONS;
/