
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.43.57 AM


CREATE or REPLACE PACKAGE RPDP_UNIT
IS

   FUNCTION CONVERTVALUE(
      P_INPUT_VAL IN NUMBER,
      P_FROM_UNIT IN VARCHAR2,
      P_TO_UNIT IN VARCHAR2,
      P_DAYTIME IN DATE DEFAULT NULL,
      P_PRECISION IN NUMBER DEFAULT NULL,
      P_VIA_GROUP IN VARCHAR2 DEFAULT 'N',
      P_SUPRESS_ERROR IN VARCHAR2 DEFAULT 'N',
      P_SOURCE_OBJECT_ID_1 IN VARCHAR2 DEFAULT NULL ,
      P_SOURCE_OBJECT_ID_2 IN VARCHAR2 DEFAULT NULL ,
      P_SOURCE_OBJECT_ID_3 IN VARCHAR2 DEFAULT NULL ,
      P_SOURCE_OBJECT_ID_4 IN VARCHAR2 DEFAULT NULL ,
      P_SOURCE_OBJECT_ID_5 IN VARCHAR2 DEFAULT NULL )
      RETURN NUMBER;
   FUNCTION GETBASEUNITFACTOR(
      P_FROM_UNIT IN VARCHAR2,
      P_TO_UNIT IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN ECDP_UNIT.T_UNIT_REC;
   FUNCTION GETREVNVIEWFORMATMASK(
      P_MEASUREMENT_TYPE IN VARCHAR2,
      P_UOM_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETSUBGROUPFROMUOM(
      P_UOM IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETREVNVIEWFORMATMASKVALUE(
      P_MEASUREMENT_TYPE IN VARCHAR2,
      P_UOM_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETUNITLABEL(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETVIEWFORMATMASK(
      P_UOM_CODE IN VARCHAR2,
      P_STATIC_PRES_SYNTAX IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETVIEWUNITFROMLOGICAL(
      P_MEASUREMENT_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETUOMGROUP(
      P_UOM_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETUOMSUBGROUP(
      P_UOM_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETUOMSUBGROUPTARGET(
      P_UOM_SUBGROUP IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETUNITFROMLOGICAL(
      P_MEASUREMENT_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETDEFAULTCONVFACTOR(
      P_FROM_UNIT IN VARCHAR2,
      P_TO_UNIT IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN ECDP_UNIT.T_UNIT_REC;
      TYPE T_UNIT_REC IS RECORD (
         FROM_UNIT VARCHAR2 (32) ,
         TO_UNIT VARCHAR2 (32) ,
         PREFIX VARCHAR2 (32) ,
         PREFIX_FACTOR NUMBER ,
         MULT_FACT NUMBER ,
         ADD_NUMB NUMBER ,
         PRECISION NUMBER ,
         USE_UE VARCHAR2 (1) ,
         USER_EXIT VARCHAR2 (240) ,
         INVERSE VARCHAR2 (1)  );
   FUNCTION GETOBJECTCONVFACTOR(
      P_FROM_UNIT IN VARCHAR2,
      P_TO_UNIT IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_PREFIX_IND IN VARCHAR2 DEFAULT 'N')
      RETURN ECDP_UNIT.T_UNIT_REC;
   FUNCTION GETUOMSETQTY(
      PTAB_UOM_SET IN OUT ECDP_UNIT.T_UOMTABLE,
      TARGET_UOM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;

END RPDP_UNIT;

/



CREATE or REPLACE PACKAGE BODY RPDP_UNIT
IS

   FUNCTION CONVERTVALUE(
      P_INPUT_VAL IN NUMBER,
      P_FROM_UNIT IN VARCHAR2,
      P_TO_UNIT IN VARCHAR2,
      P_DAYTIME IN DATE DEFAULT NULL,
      P_PRECISION IN NUMBER DEFAULT NULL,
      P_VIA_GROUP IN VARCHAR2 DEFAULT 'N',
      P_SUPRESS_ERROR IN VARCHAR2 DEFAULT 'N',
      P_SOURCE_OBJECT_ID_1 IN VARCHAR2 DEFAULT NULL ,
      P_SOURCE_OBJECT_ID_2 IN VARCHAR2 DEFAULT NULL ,
      P_SOURCE_OBJECT_ID_3 IN VARCHAR2 DEFAULT NULL ,
      P_SOURCE_OBJECT_ID_4 IN VARCHAR2 DEFAULT NULL ,
      P_SOURCE_OBJECT_ID_5 IN VARCHAR2 DEFAULT NULL )
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_UNIT.CONVERTVALUE      (
         P_INPUT_VAL,
         P_FROM_UNIT,
         P_TO_UNIT,
         P_DAYTIME,
         P_PRECISION,
         P_VIA_GROUP,
         P_SUPRESS_ERROR,
         P_SOURCE_OBJECT_ID_1,
         P_SOURCE_OBJECT_ID_2,
         P_SOURCE_OBJECT_ID_3,
         P_SOURCE_OBJECT_ID_4,
         P_SOURCE_OBJECT_ID_5 );
         RETURN ret_value;
   END CONVERTVALUE;
   FUNCTION GETBASEUNITFACTOR(
      P_FROM_UNIT IN VARCHAR2,
      P_TO_UNIT IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN ECDP_UNIT.T_UNIT_REC
   IS
      ret_value    ECDP_UNIT.T_UNIT_REC ;
   BEGIN
      ret_value := ECDP_UNIT.GETBASEUNITFACTOR      (
         P_FROM_UNIT,
         P_TO_UNIT,
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETBASEUNITFACTOR;
   FUNCTION GETREVNVIEWFORMATMASK(
      P_MEASUREMENT_TYPE IN VARCHAR2,
      P_UOM_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_UNIT.GETREVNVIEWFORMATMASK      (
         P_MEASUREMENT_TYPE,
         P_UOM_CODE );
         RETURN ret_value;
   END GETREVNVIEWFORMATMASK;
   FUNCTION GETSUBGROUPFROMUOM(
      P_UOM IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_UNIT.GETSUBGROUPFROMUOM      (
         P_UOM );
         RETURN ret_value;
   END GETSUBGROUPFROMUOM;
   FUNCTION GETREVNVIEWFORMATMASKVALUE(
      P_MEASUREMENT_TYPE IN VARCHAR2,
      P_UOM_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_UNIT.GETREVNVIEWFORMATMASKVALUE      (
         P_MEASUREMENT_TYPE,
         P_UOM_CODE );
         RETURN ret_value;
   END GETREVNVIEWFORMATMASKVALUE;
   FUNCTION GETUNITLABEL(
      P_UNIT IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_UNIT.GETUNITLABEL      (
         P_UNIT );
         RETURN ret_value;
   END GETUNITLABEL;
   FUNCTION GETVIEWFORMATMASK(
      P_UOM_CODE IN VARCHAR2,
      P_STATIC_PRES_SYNTAX IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_UNIT.GETVIEWFORMATMASK      (
         P_UOM_CODE,
         P_STATIC_PRES_SYNTAX );
         RETURN ret_value;
   END GETVIEWFORMATMASK;
   FUNCTION GETVIEWUNITFROMLOGICAL(
      P_MEASUREMENT_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_UNIT.GETVIEWUNITFROMLOGICAL      (
         P_MEASUREMENT_TYPE );
         RETURN ret_value;
   END GETVIEWUNITFROMLOGICAL;
   FUNCTION GETUOMGROUP(
      P_UOM_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_UNIT.GETUOMGROUP      (
         P_UOM_CODE );
         RETURN ret_value;
   END GETUOMGROUP;
   FUNCTION GETUOMSUBGROUP(
      P_UOM_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_UNIT.GETUOMSUBGROUP      (
         P_UOM_CODE );
         RETURN ret_value;
   END GETUOMSUBGROUP;
   FUNCTION GETUOMSUBGROUPTARGET(
      P_UOM_SUBGROUP IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_UNIT.GETUOMSUBGROUPTARGET      (
         P_UOM_SUBGROUP );
         RETURN ret_value;
   END GETUOMSUBGROUPTARGET;
   FUNCTION GETUNITFROMLOGICAL(
      P_MEASUREMENT_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_UNIT.GETUNITFROMLOGICAL      (
         P_MEASUREMENT_TYPE );
         RETURN ret_value;
   END GETUNITFROMLOGICAL;
   FUNCTION GETDEFAULTCONVFACTOR(
      P_FROM_UNIT IN VARCHAR2,
      P_TO_UNIT IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN ECDP_UNIT.T_UNIT_REC
   IS
      ret_value    ECDP_UNIT.T_UNIT_REC ;
   BEGIN
      ret_value := ECDP_UNIT.GETDEFAULTCONVFACTOR      (
         P_FROM_UNIT,
         P_TO_UNIT,
         P_DAYTIME );
         RETURN ret_value;
   END GETDEFAULTCONVFACTOR;
   FUNCTION GETOBJECTCONVFACTOR(
      P_FROM_UNIT IN VARCHAR2,
      P_TO_UNIT IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_PREFIX_IND IN VARCHAR2 DEFAULT 'N')
      RETURN ECDP_UNIT.T_UNIT_REC
   IS
      ret_value    ECDP_UNIT.T_UNIT_REC ;
   BEGIN
      ret_value := ECDP_UNIT.GETOBJECTCONVFACTOR      (
         P_FROM_UNIT,
         P_TO_UNIT,
         P_OBJECT_ID,
         P_DAYTIME,
         P_PREFIX_IND );
         RETURN ret_value;
   END GETOBJECTCONVFACTOR;
   FUNCTION GETUOMSETQTY(
      PTAB_UOM_SET IN OUT ECDP_UNIT.T_UOMTABLE,
      TARGET_UOM_CODE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_UNIT.GETUOMSETQTY      (
         PTAB_UOM_SET,
         TARGET_UOM_CODE,
         P_DAYTIME );
         RETURN ret_value;
   END GETUOMSETQTY;

END RPDP_UNIT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_UNIT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.44.00 AM


