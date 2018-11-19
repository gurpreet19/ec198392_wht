
 -- START PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.25.32 AM


CREATE or REPLACE PACKAGE RPDP_CLASSMETA_CNFG
IS

   FUNCTION GETAPPROVALIND(
      P_CLASS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETCREATEEVENTIND(
      P_CLASS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETDYNAMICPRESENTATIONSYNTAX(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETDYNAMICPRESENTATIONSYNTAX(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETDBPRESSYNTAX(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETLABEL(
      P_CLASS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETSCREENSORTORDER(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETSTATICPRESENTATIONSYNTAX(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION ISDISABLED(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETDBPRESSYNTAX(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETLOCKIND(
      P_CLASS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETMAXSTATICPRESPROPERTY(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_PROPERTY_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETSTATICVIEWHIDDEN(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETSTATICVIEWLABELHEAD(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION INCLUDEINWEBSERVICE(
      P_CLASS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CLASS_TRA_PROPERTY_CNFG
      RETURN VARCHAR2;
   FUNCTION GETAPPROVALIND(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETCLASSSHORTCODE(
      P_CLASS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETENSUREREVTEXTONUPDATE(
      P_CLASS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETMAXSTATICPRESPROPERTY(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2,
      P_PROPERTY_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETNAME(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION ISDISABLED(
      P_CLASS_NAME IN VARCHAR2,
      P_TRIGGERING_EVENT IN VARCHAR2,
      P_TRIGGER_TYPE IN VARCHAR2,
      P_SORT_ORDER IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CLASS_PROPERTY_CNFG
      RETURN VARCHAR2;
   FUNCTION GETDESCRIPTION(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETLABEL(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETLABEL(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION INCLUDEINMAPPING(
      P_CLASS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION ISDISABLED(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION SKIPTRIGGERCHECK(
      P_CLASS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETCACHESIZE
      RETURN NUMBER;
   FUNCTION GETDESCRIPTION(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETJOURNALRULEDBSYNTAX(
      P_CLASS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETREVERSEAPPROVALIND(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETSTATICPRESENTATIONSYNTAX(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION INCLUDEINVALIDATION(
      P_CLASS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION ISVIEWLAYERPROPERTY(
      P_PROPERTY_TABLE_NAME IN VARCHAR2,
      P_PROPERTY_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETDBSORTORDER(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETDESCRIPTION(
      P_CLASS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETLOCKRULE(
      P_CLASS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETUOMCODE(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION ISMANDATORY(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION ISMANDATORY(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION ISREADONLY(
      P_CLASS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION ISREADONLY(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION ISREPORTONLY(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CLASS_ATTR_PROPERTY_CNFG
      RETURN VARCHAR2;
   FUNCTION CLASS_REL_PROPERTY_CNFG
      RETURN VARCHAR2;
   FUNCTION GETACCESSCONTROLIND(
      P_CLASS_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETACCESSCONTROLMETHOD(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETALLOCPRIORITY(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETCLASSVIEWNAME(
      P_CLASS_NAME IN VARCHAR2,
      P_CLASS_TYPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETDBSORTORDER(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETDESCRIPTION(
      P_CLASS_NAME IN VARCHAR2,
      P_TRIGGERING_EVENT IN VARCHAR2,
      P_TRIGGER_TYPE IN VARCHAR2,
      P_SORT_ORDER IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION GETNAME(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION ISREPORTONLY(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;

END RPDP_CLASSMETA_CNFG;

/



CREATE or REPLACE PACKAGE BODY RPDP_CLASSMETA_CNFG
IS

   FUNCTION GETAPPROVALIND(
      P_CLASS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.GETAPPROVALIND      (
         P_CLASS_NAME );
         RETURN ret_value;
   END GETAPPROVALIND;
   FUNCTION GETCREATEEVENTIND(
      P_CLASS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.GETCREATEEVENTIND      (
         P_CLASS_NAME );
         RETURN ret_value;
   END GETCREATEEVENTIND;
   FUNCTION GETDYNAMICPRESENTATIONSYNTAX(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.GETDYNAMICPRESENTATIONSYNTAX      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END GETDYNAMICPRESENTATIONSYNTAX;
   FUNCTION GETDYNAMICPRESENTATIONSYNTAX(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.GETDYNAMICPRESENTATIONSYNTAX      (
         P_FROM_CLASS_NAME,
         P_TO_CLASS_NAME,
         P_ROLE_NAME );
         RETURN ret_value;
   END GETDYNAMICPRESENTATIONSYNTAX;
   FUNCTION GETDBPRESSYNTAX(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.GETDBPRESSYNTAX      (
         P_FROM_CLASS_NAME,
         P_TO_CLASS_NAME,
         P_ROLE_NAME );
         RETURN ret_value;
   END GETDBPRESSYNTAX;
   FUNCTION GETLABEL(
      P_CLASS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.GETLABEL      (
         P_CLASS_NAME );
         RETURN ret_value;
   END GETLABEL;
   FUNCTION GETSCREENSORTORDER(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.GETSCREENSORTORDER      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END GETSCREENSORTORDER;
   FUNCTION GETSTATICPRESENTATIONSYNTAX(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.GETSTATICPRESENTATIONSYNTAX      (
         P_FROM_CLASS_NAME,
         P_TO_CLASS_NAME,
         P_ROLE_NAME );
         RETURN ret_value;
   END GETSTATICPRESENTATIONSYNTAX;
   FUNCTION ISDISABLED(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.ISDISABLED      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END ISDISABLED;
   FUNCTION GETDBPRESSYNTAX(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.GETDBPRESSYNTAX      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END GETDBPRESSYNTAX;
   FUNCTION GETLOCKIND(
      P_CLASS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.GETLOCKIND      (
         P_CLASS_NAME );
         RETURN ret_value;
   END GETLOCKIND;
   FUNCTION GETMAXSTATICPRESPROPERTY(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2,
      P_PROPERTY_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.GETMAXSTATICPRESPROPERTY      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME,
         P_PROPERTY_CODE );
         RETURN ret_value;
   END GETMAXSTATICPRESPROPERTY;
   FUNCTION GETSTATICVIEWHIDDEN(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.GETSTATICVIEWHIDDEN      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END GETSTATICVIEWHIDDEN;
   FUNCTION GETSTATICVIEWLABELHEAD(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.GETSTATICVIEWLABELHEAD      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END GETSTATICVIEWLABELHEAD;
   FUNCTION INCLUDEINWEBSERVICE(
      P_CLASS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.INCLUDEINWEBSERVICE      (
         P_CLASS_NAME );
         RETURN ret_value;
   END INCLUDEINWEBSERVICE;
   FUNCTION CLASS_TRA_PROPERTY_CNFG
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CLASSMETA_CNFG.CLASS_TRA_PROPERTY_CNFG ;
         RETURN ret_value;
   END CLASS_TRA_PROPERTY_CNFG;
   FUNCTION GETAPPROVALIND(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.GETAPPROVALIND      (
         P_FROM_CLASS_NAME,
         P_TO_CLASS_NAME,
         P_ROLE_NAME );
         RETURN ret_value;
   END GETAPPROVALIND;
   FUNCTION GETCLASSSHORTCODE(
      P_CLASS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.GETCLASSSHORTCODE      (
         P_CLASS_NAME );
         RETURN ret_value;
   END GETCLASSSHORTCODE;
   FUNCTION GETENSUREREVTEXTONUPDATE(
      P_CLASS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.GETENSUREREVTEXTONUPDATE      (
         P_CLASS_NAME );
         RETURN ret_value;
   END GETENSUREREVTEXTONUPDATE;
   FUNCTION GETMAXSTATICPRESPROPERTY(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2,
      P_PROPERTY_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.GETMAXSTATICPRESPROPERTY      (
         P_FROM_CLASS_NAME,
         P_TO_CLASS_NAME,
         P_ROLE_NAME,
         P_PROPERTY_CODE );
         RETURN ret_value;
   END GETMAXSTATICPRESPROPERTY;
   FUNCTION GETNAME(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.GETNAME      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END GETNAME;
   FUNCTION ISDISABLED(
      P_CLASS_NAME IN VARCHAR2,
      P_TRIGGERING_EVENT IN VARCHAR2,
      P_TRIGGER_TYPE IN VARCHAR2,
      P_SORT_ORDER IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.ISDISABLED      (
         P_CLASS_NAME,
         P_TRIGGERING_EVENT,
         P_TRIGGER_TYPE,
         P_SORT_ORDER );
         RETURN ret_value;
   END ISDISABLED;
   FUNCTION CLASS_PROPERTY_CNFG
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CLASSMETA_CNFG.CLASS_PROPERTY_CNFG ;
         RETURN ret_value;
   END CLASS_PROPERTY_CNFG;
   FUNCTION GETDESCRIPTION(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.GETDESCRIPTION      (
         P_FROM_CLASS_NAME,
         P_TO_CLASS_NAME,
         P_ROLE_NAME );
         RETURN ret_value;
   END GETDESCRIPTION;
   FUNCTION GETLABEL(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.GETLABEL      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END GETLABEL;
   FUNCTION GETLABEL(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.GETLABEL      (
         P_FROM_CLASS_NAME,
         P_TO_CLASS_NAME,
         P_ROLE_NAME );
         RETURN ret_value;
   END GETLABEL;
   FUNCTION INCLUDEINMAPPING(
      P_CLASS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.INCLUDEINMAPPING      (
         P_CLASS_NAME );
         RETURN ret_value;
   END INCLUDEINMAPPING;
   FUNCTION ISDISABLED(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.ISDISABLED      (
         P_FROM_CLASS_NAME,
         P_TO_CLASS_NAME,
         P_ROLE_NAME );
         RETURN ret_value;
   END ISDISABLED;
   FUNCTION SKIPTRIGGERCHECK(
      P_CLASS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.SKIPTRIGGERCHECK      (
         P_CLASS_NAME );
         RETURN ret_value;
   END SKIPTRIGGERCHECK;
   FUNCTION GETCACHESIZE
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN

         ret_value := ECDP_CLASSMETA_CNFG.GETCACHESIZE ;
         RETURN ret_value;
   END GETCACHESIZE;
   FUNCTION GETDESCRIPTION(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.GETDESCRIPTION      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END GETDESCRIPTION;
   FUNCTION GETJOURNALRULEDBSYNTAX(
      P_CLASS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.GETJOURNALRULEDBSYNTAX      (
         P_CLASS_NAME );
         RETURN ret_value;
   END GETJOURNALRULEDBSYNTAX;
   FUNCTION GETREVERSEAPPROVALIND(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.GETREVERSEAPPROVALIND      (
         P_FROM_CLASS_NAME,
         P_TO_CLASS_NAME,
         P_ROLE_NAME );
         RETURN ret_value;
   END GETREVERSEAPPROVALIND;
   FUNCTION GETSTATICPRESENTATIONSYNTAX(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.GETSTATICPRESENTATIONSYNTAX      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END GETSTATICPRESENTATIONSYNTAX;
   FUNCTION INCLUDEINVALIDATION(
      P_CLASS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.INCLUDEINVALIDATION      (
         P_CLASS_NAME );
         RETURN ret_value;
   END INCLUDEINVALIDATION;
   FUNCTION ISVIEWLAYERPROPERTY(
      P_PROPERTY_TABLE_NAME IN VARCHAR2,
      P_PROPERTY_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.ISVIEWLAYERPROPERTY      (
         P_PROPERTY_TABLE_NAME,
         P_PROPERTY_CODE );
         RETURN ret_value;
   END ISVIEWLAYERPROPERTY;
   FUNCTION GETDBSORTORDER(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.GETDBSORTORDER      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END GETDBSORTORDER;
   FUNCTION GETDESCRIPTION(
      P_CLASS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.GETDESCRIPTION      (
         P_CLASS_NAME );
         RETURN ret_value;
   END GETDESCRIPTION;
   FUNCTION GETLOCKRULE(
      P_CLASS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.GETLOCKRULE      (
         P_CLASS_NAME );
         RETURN ret_value;
   END GETLOCKRULE;
   FUNCTION GETUOMCODE(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.GETUOMCODE      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END GETUOMCODE;
   FUNCTION ISMANDATORY(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.ISMANDATORY      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END ISMANDATORY;
   FUNCTION ISMANDATORY(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.ISMANDATORY      (
         P_FROM_CLASS_NAME,
         P_TO_CLASS_NAME,
         P_ROLE_NAME );
         RETURN ret_value;
   END ISMANDATORY;
   FUNCTION ISREADONLY(
      P_CLASS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.ISREADONLY      (
         P_CLASS_NAME );
         RETURN ret_value;
   END ISREADONLY;
   FUNCTION ISREADONLY(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.ISREADONLY      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END ISREADONLY;
   FUNCTION ISREPORTONLY(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.ISREPORTONLY      (
         P_FROM_CLASS_NAME,
         P_TO_CLASS_NAME,
         P_ROLE_NAME );
         RETURN ret_value;
   END ISREPORTONLY;
   FUNCTION CLASS_ATTR_PROPERTY_CNFG
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CLASSMETA_CNFG.CLASS_ATTR_PROPERTY_CNFG ;
         RETURN ret_value;
   END CLASS_ATTR_PROPERTY_CNFG;
   FUNCTION CLASS_REL_PROPERTY_CNFG
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CLASSMETA_CNFG.CLASS_REL_PROPERTY_CNFG ;
         RETURN ret_value;
   END CLASS_REL_PROPERTY_CNFG;
   FUNCTION GETACCESSCONTROLIND(
      P_CLASS_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.GETACCESSCONTROLIND      (
         P_CLASS_NAME );
         RETURN ret_value;
   END GETACCESSCONTROLIND;
   FUNCTION GETACCESSCONTROLMETHOD(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.GETACCESSCONTROLMETHOD      (
         P_FROM_CLASS_NAME,
         P_TO_CLASS_NAME,
         P_ROLE_NAME );
         RETURN ret_value;
   END GETACCESSCONTROLMETHOD;
   FUNCTION GETALLOCPRIORITY(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.GETALLOCPRIORITY      (
         P_FROM_CLASS_NAME,
         P_TO_CLASS_NAME,
         P_ROLE_NAME );
         RETURN ret_value;
   END GETALLOCPRIORITY;
   FUNCTION GETCLASSVIEWNAME(
      P_CLASS_NAME IN VARCHAR2,
      P_CLASS_TYPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.GETCLASSVIEWNAME      (
         P_CLASS_NAME,
         P_CLASS_TYPE );
         RETURN ret_value;
   END GETCLASSVIEWNAME;
   FUNCTION GETDBSORTORDER(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.GETDBSORTORDER      (
         P_FROM_CLASS_NAME,
         P_TO_CLASS_NAME,
         P_ROLE_NAME );
         RETURN ret_value;
   END GETDBSORTORDER;
   FUNCTION GETDESCRIPTION(
      P_CLASS_NAME IN VARCHAR2,
      P_TRIGGERING_EVENT IN VARCHAR2,
      P_TRIGGER_TYPE IN VARCHAR2,
      P_SORT_ORDER IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.GETDESCRIPTION      (
         P_CLASS_NAME,
         P_TRIGGERING_EVENT,
         P_TRIGGER_TYPE,
         P_SORT_ORDER );
         RETURN ret_value;
   END GETDESCRIPTION;
   FUNCTION GETNAME(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.GETNAME      (
         P_FROM_CLASS_NAME,
         P_TO_CLASS_NAME,
         P_ROLE_NAME );
         RETURN ret_value;
   END GETNAME;
   FUNCTION ISREPORTONLY(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CLASSMETA_CNFG.ISREPORTONLY      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END ISREPORTONLY;

END RPDP_CLASSMETA_CNFG;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_CLASSMETA_CNFG TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.25.43 AM


