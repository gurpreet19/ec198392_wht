
 -- START PKG_GEN_PKGS.sf_get_functions at:05/08/2019 04.22.25 AM


CREATE or REPLACE PACKAGE RPTP_COUNTRY
IS

   FUNCTION ALIGNPARENTVERSIONS(
      P_VT IN ECTP_COUNTRY.VER_TAB_TYPE,
      P_GROUP_TYPE IN VARCHAR2,
      P_FROM_CLASS IN VARCHAR2 DEFAULT NULL)
      RETURN ECTP_COUNTRY.VER_TAB_TYPE;
   FUNCTION SETOBJENDDATE(
      P_VT IN ECTP_COUNTRY.VER_TAB_TYPE,
      P_OBJECT_ID IN VARCHAR2,
      P_END_DATE IN DATE,
      P_LAST_UPDATED_BY IN VARCHAR2 DEFAULT USER,
      P_LAST_UPDATED_DATE IN DATE DEFAULT Ecdp_Timestamp.getCurrentSysdate,
      P_REV_TEXT IN VARCHAR2)
      RETURN ECTP_COUNTRY.VER_TAB_TYPE;
   FUNCTION SETOBJSTARTDATE(
      P_VT IN ECTP_COUNTRY.VER_TAB_TYPE,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_LAST_UPDATED_BY IN VARCHAR2 DEFAULT USER,
      P_LAST_UPDATED_DATE IN DATE DEFAULT Ecdp_Timestamp.getCurrentSysdate)
      RETURN ECTP_COUNTRY.VER_TAB_TYPE;

END RPTP_COUNTRY;

/



CREATE or REPLACE PACKAGE BODY RPTP_COUNTRY
IS

   FUNCTION ALIGNPARENTVERSIONS(
      P_VT IN ECTP_COUNTRY.VER_TAB_TYPE,
      P_GROUP_TYPE IN VARCHAR2,
      P_FROM_CLASS IN VARCHAR2 DEFAULT NULL)
      RETURN ECTP_COUNTRY.VER_TAB_TYPE
   IS
      ret_value    ECTP_COUNTRY.VER_TAB_TYPE ;
   BEGIN
      ret_value := ECTP_COUNTRY.ALIGNPARENTVERSIONS      (
         P_VT,
         P_GROUP_TYPE,
         P_FROM_CLASS );
         RETURN ret_value;
   END ALIGNPARENTVERSIONS;
   FUNCTION SETOBJENDDATE(
      P_VT IN ECTP_COUNTRY.VER_TAB_TYPE,
      P_OBJECT_ID IN VARCHAR2,
      P_END_DATE IN DATE,
      P_LAST_UPDATED_BY IN VARCHAR2 DEFAULT USER,
      P_LAST_UPDATED_DATE IN DATE DEFAULT Ecdp_Timestamp.getCurrentSysdate,
      P_REV_TEXT IN VARCHAR2)
      RETURN ECTP_COUNTRY.VER_TAB_TYPE
   IS
      ret_value    ECTP_COUNTRY.VER_TAB_TYPE ;
   BEGIN
      ret_value := ECTP_COUNTRY.SETOBJENDDATE      (
         P_VT,
         P_OBJECT_ID,
         P_END_DATE,
         P_LAST_UPDATED_BY,
         P_LAST_UPDATED_DATE,
         P_REV_TEXT );
         RETURN ret_value;
   END SETOBJENDDATE;
   FUNCTION SETOBJSTARTDATE(
      P_VT IN ECTP_COUNTRY.VER_TAB_TYPE,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_LAST_UPDATED_BY IN VARCHAR2 DEFAULT USER,
      P_LAST_UPDATED_DATE IN DATE DEFAULT Ecdp_Timestamp.getCurrentSysdate)
      RETURN ECTP_COUNTRY.VER_TAB_TYPE
   IS
      ret_value    ECTP_COUNTRY.VER_TAB_TYPE ;
   BEGIN
      ret_value := ECTP_COUNTRY.SETOBJSTARTDATE      (
         P_VT,
         P_OBJECT_ID,
         P_DAYTIME,
         P_LAST_UPDATED_BY,
         P_LAST_UPDATED_DATE );
         RETURN ret_value;
   END SETOBJSTARTDATE;

END RPTP_COUNTRY;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPTP_COUNTRY TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/08/2019 04.22.26 AM


