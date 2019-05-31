
 -- START PKG_GEN_PKGS.sf_get_functions at:05/08/2019 03.39.38 AM


CREATE or REPLACE PACKAGE RPBP_CALCULATEAGA
IS

   FUNCTION CALCEXPANSIONFACTOR(
      P_TAPTYPE IN VARCHAR2,
      P_BETA IN NUMBER,
      P_LOCATIONTYPE IN NUMBER,
      P_ISENTROPICEXP IN VARCHAR2,
      P_PRESSURERATIO IN NUMBER,
      P_AGA3IFLUID IN NUMBER)
      RETURN NUMBER;
   FUNCTION CALCCOMPRESSIBILITY_RK(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_PRESSURE IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN NUMBER;
   FUNCTION CALCE(
      P_N_TAPS IN VARCHAR2,
      P_BETA IN NUMBER,
      P_DM IN NUMBER,
      P_DO IN NUMBER)
      RETURN NUMBER;
   FUNCTION CALCULATEFLOWDENSITY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_STATIC_PRESSURE IN NUMBER,
      P_TEMP IN NUMBER,
      P_COMPRESS IN NUMBER,
      P_MR IN NUMBER DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION CALC_HN(
      P_CID IN ECBP_CALCULATEAGA.T_PI_Z_CID,
      P_X IN ECBP_CALCULATEAGA.T_PN_Z_ARRAY,
      P_NCC IN INTEGER ,
      P_TB IN NUMBER)
      RETURN NUMBER;
   FUNCTION CALC_Z_BMIX(
      P_TK IN NUMBER)
      RETURN NUMBER;
   FUNCTION CALC_Z_PARAMDL(
      P_NCC IN INTEGER ,
      P_CID IN ECBP_CALCULATEAGA.T_PI_Z_CID)
      RETURN INTEGER;
   FUNCTION CALCAGA3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_USER IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION CALCULATETDEVFLOWDENSITY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_STATIC_PRESSURE IN NUMBER,
      P_TEMP IN NUMBER,
      P_COMPRESS IN NUMBER,
      P_GRS IN NUMBER DEFAULT NULL,
      P_CLASS_NAME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION CALC_PGROSS(
      P_D IN NUMBER,
      P_TK IN NUMBER,
      P_XCH IN NUMBER,
      P_XN2 IN NUMBER,
      P_XCO2 IN NUMBER,
      P_XH2 IN NUMBER,
      P_XCO IN NUMBER)
      RETURN NUMBER;
   FUNCTION CALC_Z_PDETAIL(
      P_D IN NUMBER,
      P_TK IN NUMBER)
      RETURN NUMBER;
   FUNCTION CALCEV(
      P_BETA IN NUMBER)
      RETURN NUMBER;
   FUNCTION CALCFR(
      P_BETA IN NUMBER,
      P_DIFFPRESSURE IN NUMBER,
      P_STATICPRESSURE IN NUMBER,
      P_DO IN NUMBER,
      P_E IN NUMBER)
      RETURN NUMBER;
   FUNCTION CALCULATETDEVSTDDENSITY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_PRESSURE IN NUMBER,
      P_TEMP IN NUMBER,
      P_COMPRESS IN NUMBER,
      P_GRS IN NUMBER DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION CALC_RK_FZ(
      P_COMPRESSIBILITY IN NUMBER)
      RETURN NUMBER;
   FUNCTION CALC_ZGROSS(
      P_D IN NUMBER,
      P_TK IN NUMBER,
      P_XCH IN NUMBER,
      P_XN2 IN NUMBER,
      P_XCO2 IN NUMBER,
      P_XH2 IN NUMBER,
      P_XCO IN NUMBER)
      RETURN NUMBER;
   FUNCTION CALCKO(
      P_N_TAPS IN VARCHAR2,
      P_BETA IN NUMBER,
      P_DM IN NUMBER,
      P_DO IN NUMBER)
      RETURN NUMBER;
   FUNCTION CALC_Z_ZDETAIL(
      P_D IN NUMBER,
      P_TK IN NUMBER)
      RETURN NUMBER;
   FUNCTION CALC_DGROSS(
      P_P IN NUMBER,
      P_T IN NUMBER,
      P_XCH IN NUMBER,
      P_XN2 IN NUMBER,
      P_XCO2 IN NUMBER,
      P_XH2 IN NUMBER,
      P_XCO IN NUMBER)
      RETURN NUMBER;
   FUNCTION CALCULATESTDDENSITY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_PRESSURE IN NUMBER,
      P_TEMP IN NUMBER,
      P_COMPRESS IN NUMBER,
      P_MR IN NUMBER DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION CALC_Z_DDETAIL(
      P_P IN NUMBER,
      P_TK IN NUMBER)
      RETURN NUMBER;

END RPBP_CALCULATEAGA;

/



CREATE or REPLACE PACKAGE BODY RPBP_CALCULATEAGA
IS

   FUNCTION CALCEXPANSIONFACTOR(
      P_TAPTYPE IN VARCHAR2,
      P_BETA IN NUMBER,
      P_LOCATIONTYPE IN NUMBER,
      P_ISENTROPICEXP IN VARCHAR2,
      P_PRESSURERATIO IN NUMBER,
      P_AGA3IFLUID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_CALCULATEAGA.CALCEXPANSIONFACTOR      (
         P_TAPTYPE,
         P_BETA,
         P_LOCATIONTYPE,
         P_ISENTROPICEXP,
         P_PRESSURERATIO,
         P_AGA3IFLUID );
         RETURN ret_value;
   END CALCEXPANSIONFACTOR;
   FUNCTION CALCCOMPRESSIBILITY_RK(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_PRESSURE IN NUMBER,
      P_TEMP IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_CALCULATEAGA.CALCCOMPRESSIBILITY_RK      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_PRESSURE,
         P_TEMP );
         RETURN ret_value;
   END CALCCOMPRESSIBILITY_RK;
   FUNCTION CALCE(
      P_N_TAPS IN VARCHAR2,
      P_BETA IN NUMBER,
      P_DM IN NUMBER,
      P_DO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_CALCULATEAGA.CALCE      (
         P_N_TAPS,
         P_BETA,
         P_DM,
         P_DO );
         RETURN ret_value;
   END CALCE;
   FUNCTION CALCULATEFLOWDENSITY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_STATIC_PRESSURE IN NUMBER,
      P_TEMP IN NUMBER,
      P_COMPRESS IN NUMBER,
      P_MR IN NUMBER DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_CALCULATEAGA.CALCULATEFLOWDENSITY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_STATIC_PRESSURE,
         P_TEMP,
         P_COMPRESS,
         P_MR );
         RETURN ret_value;
   END CALCULATEFLOWDENSITY;
   FUNCTION CALC_HN(
      P_CID IN ECBP_CALCULATEAGA.T_PI_Z_CID,
      P_X IN ECBP_CALCULATEAGA.T_PN_Z_ARRAY,
      P_NCC IN INTEGER ,
      P_TB IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_CALCULATEAGA.CALC_HN      (
         P_CID,
         P_X,
         P_NCC,
         P_TB );
         RETURN ret_value;
   END CALC_HN;
   FUNCTION CALC_Z_BMIX(
      P_TK IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_CALCULATEAGA.CALC_Z_BMIX      (
         P_TK );
         RETURN ret_value;
   END CALC_Z_BMIX;
   FUNCTION CALC_Z_PARAMDL(
      P_NCC IN INTEGER ,
      P_CID IN ECBP_CALCULATEAGA.T_PI_Z_CID)
      RETURN INTEGER
   IS
      ret_value   INTEGER ;
   BEGIN
      ret_value := ECBP_CALCULATEAGA.CALC_Z_PARAMDL      (
         P_NCC,
         P_CID );
         RETURN ret_value;
   END CALC_Z_PARAMDL;
   FUNCTION CALCAGA3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_USER IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_CALCULATEAGA.CALCAGA3      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_TYPE,
         P_USER );
         RETURN ret_value;
   END CALCAGA3;
   FUNCTION CALCULATETDEVFLOWDENSITY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_STATIC_PRESSURE IN NUMBER,
      P_TEMP IN NUMBER,
      P_COMPRESS IN NUMBER,
      P_GRS IN NUMBER DEFAULT NULL,
      P_CLASS_NAME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_CALCULATEAGA.CALCULATETDEVFLOWDENSITY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_STATIC_PRESSURE,
         P_TEMP,
         P_COMPRESS,
         P_GRS,
         P_CLASS_NAME );
         RETURN ret_value;
   END CALCULATETDEVFLOWDENSITY;
   FUNCTION CALC_PGROSS(
      P_D IN NUMBER,
      P_TK IN NUMBER,
      P_XCH IN NUMBER,
      P_XN2 IN NUMBER,
      P_XCO2 IN NUMBER,
      P_XH2 IN NUMBER,
      P_XCO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_CALCULATEAGA.CALC_PGROSS      (
         P_D,
         P_TK,
         P_XCH,
         P_XN2,
         P_XCO2,
         P_XH2,
         P_XCO );
         RETURN ret_value;
   END CALC_PGROSS;
   FUNCTION CALC_Z_PDETAIL(
      P_D IN NUMBER,
      P_TK IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_CALCULATEAGA.CALC_Z_PDETAIL      (
         P_D,
         P_TK );
         RETURN ret_value;
   END CALC_Z_PDETAIL;
   FUNCTION CALCEV(
      P_BETA IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_CALCULATEAGA.CALCEV      (
         P_BETA );
         RETURN ret_value;
   END CALCEV;
   FUNCTION CALCFR(
      P_BETA IN NUMBER,
      P_DIFFPRESSURE IN NUMBER,
      P_STATICPRESSURE IN NUMBER,
      P_DO IN NUMBER,
      P_E IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_CALCULATEAGA.CALCFR      (
         P_BETA,
         P_DIFFPRESSURE,
         P_STATICPRESSURE,
         P_DO,
         P_E );
         RETURN ret_value;
   END CALCFR;
   FUNCTION CALCULATETDEVSTDDENSITY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_PRESSURE IN NUMBER,
      P_TEMP IN NUMBER,
      P_COMPRESS IN NUMBER,
      P_GRS IN NUMBER DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_CALCULATEAGA.CALCULATETDEVSTDDENSITY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_PRESSURE,
         P_TEMP,
         P_COMPRESS,
         P_GRS );
         RETURN ret_value;
   END CALCULATETDEVSTDDENSITY;
   FUNCTION CALC_RK_FZ(
      P_COMPRESSIBILITY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_CALCULATEAGA.CALC_RK_FZ      (
         P_COMPRESSIBILITY );
         RETURN ret_value;
   END CALC_RK_FZ;
   FUNCTION CALC_ZGROSS(
      P_D IN NUMBER,
      P_TK IN NUMBER,
      P_XCH IN NUMBER,
      P_XN2 IN NUMBER,
      P_XCO2 IN NUMBER,
      P_XH2 IN NUMBER,
      P_XCO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_CALCULATEAGA.CALC_ZGROSS      (
         P_D,
         P_TK,
         P_XCH,
         P_XN2,
         P_XCO2,
         P_XH2,
         P_XCO );
         RETURN ret_value;
   END CALC_ZGROSS;
   FUNCTION CALCKO(
      P_N_TAPS IN VARCHAR2,
      P_BETA IN NUMBER,
      P_DM IN NUMBER,
      P_DO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_CALCULATEAGA.CALCKO      (
         P_N_TAPS,
         P_BETA,
         P_DM,
         P_DO );
         RETURN ret_value;
   END CALCKO;
   FUNCTION CALC_Z_ZDETAIL(
      P_D IN NUMBER,
      P_TK IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_CALCULATEAGA.CALC_Z_ZDETAIL      (
         P_D,
         P_TK );
         RETURN ret_value;
   END CALC_Z_ZDETAIL;
   FUNCTION CALC_DGROSS(
      P_P IN NUMBER,
      P_T IN NUMBER,
      P_XCH IN NUMBER,
      P_XN2 IN NUMBER,
      P_XCO2 IN NUMBER,
      P_XH2 IN NUMBER,
      P_XCO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_CALCULATEAGA.CALC_DGROSS      (
         P_P,
         P_T,
         P_XCH,
         P_XN2,
         P_XCO2,
         P_XH2,
         P_XCO );
         RETURN ret_value;
   END CALC_DGROSS;
   FUNCTION CALCULATESTDDENSITY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_PRESSURE IN NUMBER,
      P_TEMP IN NUMBER,
      P_COMPRESS IN NUMBER,
      P_MR IN NUMBER DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_CALCULATEAGA.CALCULATESTDDENSITY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_PRESSURE,
         P_TEMP,
         P_COMPRESS,
         P_MR );
         RETURN ret_value;
   END CALCULATESTDDENSITY;
   FUNCTION CALC_Z_DDETAIL(
      P_P IN NUMBER,
      P_TK IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_CALCULATEAGA.CALC_Z_DDETAIL      (
         P_P,
         P_TK );
         RETURN ret_value;
   END CALC_Z_DDETAIL;

END RPBP_CALCULATEAGA;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPBP_CALCULATEAGA TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/08/2019 03.39.43 AM


