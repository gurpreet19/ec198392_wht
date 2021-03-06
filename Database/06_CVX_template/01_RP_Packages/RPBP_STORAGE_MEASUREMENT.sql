
 -- START PKG_GEN_PKGS.sf_get_functions at:05/08/2019 03.37.46 AM


CREATE or REPLACE PACKAGE RPBP_STORAGE_MEASUREMENT
IS

   FUNCTION FINDEXPNOTLIFTEDDAYGRSBBLS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION FINDEXPNOTLIFTEDDAYNETBBLS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION FINDEXPNOTLIFTEDMTHNETSM3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION FINDSTORAGETOTALAVAILABLE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EXCLUDE_OUT_OF_SERVICE IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER;
   FUNCTION FINDSTORAGEWATMTHDIFF(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETSTORAGEDAYCLOSINGNETMASS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EXCLUDE_OUT_OF_SERVICE IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER;
   FUNCTION GETSTORAGELIFTEDGRSVOLBBLS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION FINDSTORAGEENERGYMTHDIFF(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION FINDSTORAGEGRSDAYDIFF(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION FINDSTORAGEGRSMASSMTHDIFF(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION FINDSTORAGEWATDAYDIFF(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETSTORAGEDAYCLOSINGENERGY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EXCLUDE_OUT_OF_SERVICE IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER;
   FUNCTION GETSTORAGELIFTEDNETVOLBBLS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION FINDEXPNOTLIFTEDMTHGRSBBLS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION FINDEXPNOTLIFTEDMTHGRSSM3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION FINDEXPNOTLIFTEDMTHNETBBLS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION FINDSTORAGENETMASSMTHDIFF(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETSTORAGEDAYCLOSINGNETVOL(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EXCLUDE_OUT_OF_SERVICE IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER;
   FUNCTION GETSTORAGEDAYGRSCLOSINGMASS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EXCLUDE_OUT_OF_SERVICE IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER;
   FUNCTION GETSTORAGEDAYOPENINGDILUENT(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EXCLUDE_OUT_OF_SERVICE IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER;
   FUNCTION GETSTORAGEDAYOPENINGENERGY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EXCLUDE_OUT_OF_SERVICE IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER;
   FUNCTION GETSTORAGEDAYOPENINGNETMASS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EXCLUDE_OUT_OF_SERVICE IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER;
   FUNCTION FINDEXPNOTLIFTEDDAYNETSM3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION FINDSTORAGELIFTEDGRSVOLSM3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION FINDEXPNOTLIFTEDDAYGRSSM3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION FINDSTORAGEENERGYDAYDIFF(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION FINDSTORAGELIFTEDGRSVOLBBLS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION FINDSTORAGELIFTEDNETVOLBBLS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION FINDSTORAGEGRSMTHDIFF(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETSTORAGEDAYCLOSINGWATVOL(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EXCLUDE_OUT_OF_SERVICE IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER;
   FUNCTION GETSTORAGEDAYOPENINGNETVOL(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EXCLUDE_OUT_OF_SERVICE IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER;
   FUNCTION GETSTORAGEDAYOPENINGWATVOL(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EXCLUDE_OUT_OF_SERVICE IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER;
   FUNCTION GETSTORAGELIFTEDGRSVOLSM3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION FINDSTORAGEGRSMASSDAYDIFF(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION FINDSTORAGELIFTEDNETVOLSM3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION FINDSTORAGENETDAYDIFF(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION FINDSTORAGENETMASSDAYDIFF(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION FINDSTORAGETOTALVOLUME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EXCLUDE_OUT_OF_SERVICE IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER;
   FUNCTION GETSTORAGEDAYGRSCLOSINGVOL(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EXCLUDE_OUT_OF_SERVICE IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER;
   FUNCTION GETSTORAGEDAYGRSOPENINGVOL(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EXCLUDE_OUT_OF_SERVICE IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER;
   FUNCTION FINDSTORAGEDILUENTDAYDIFF(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION FINDSTORAGENETMTHDIFF(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETSTORAGEDAYCLOSINGDILUENT(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EXCLUDE_OUT_OF_SERVICE IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER;
   FUNCTION GETSTORAGEDAYGRSOPENINGMASS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EXCLUDE_OUT_OF_SERVICE IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER;
   FUNCTION GETSTORAGEDAYGRSSTDOILCLOSEVOL(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EXCLUDE_OUT_OF_SERVICE IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER;
   FUNCTION GETSTORAGELIFTEDNETVOLSM3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;

END RPBP_STORAGE_MEASUREMENT;

/



CREATE or REPLACE PACKAGE BODY RPBP_STORAGE_MEASUREMENT
IS

   FUNCTION FINDEXPNOTLIFTEDDAYGRSBBLS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.FINDEXPNOTLIFTEDDAYGRSBBLS      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END FINDEXPNOTLIFTEDDAYGRSBBLS;
   FUNCTION FINDEXPNOTLIFTEDDAYNETBBLS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.FINDEXPNOTLIFTEDDAYNETBBLS      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END FINDEXPNOTLIFTEDDAYNETBBLS;
   FUNCTION FINDEXPNOTLIFTEDMTHNETSM3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.FINDEXPNOTLIFTEDMTHNETSM3      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END FINDEXPNOTLIFTEDMTHNETSM3;
   FUNCTION FINDSTORAGETOTALAVAILABLE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EXCLUDE_OUT_OF_SERVICE IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.FINDSTORAGETOTALAVAILABLE      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EXCLUDE_OUT_OF_SERVICE );
         RETURN ret_value;
   END FINDSTORAGETOTALAVAILABLE;
   FUNCTION FINDSTORAGEWATMTHDIFF(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.FINDSTORAGEWATMTHDIFF      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END FINDSTORAGEWATMTHDIFF;
   FUNCTION GETSTORAGEDAYCLOSINGNETMASS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EXCLUDE_OUT_OF_SERVICE IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.GETSTORAGEDAYCLOSINGNETMASS      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EXCLUDE_OUT_OF_SERVICE );
         RETURN ret_value;
   END GETSTORAGEDAYCLOSINGNETMASS;
   FUNCTION GETSTORAGELIFTEDGRSVOLBBLS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.GETSTORAGELIFTEDGRSVOLBBLS      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETSTORAGELIFTEDGRSVOLBBLS;
   FUNCTION FINDSTORAGEENERGYMTHDIFF(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.FINDSTORAGEENERGYMTHDIFF      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END FINDSTORAGEENERGYMTHDIFF;
   FUNCTION FINDSTORAGEGRSDAYDIFF(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.FINDSTORAGEGRSDAYDIFF      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END FINDSTORAGEGRSDAYDIFF;
   FUNCTION FINDSTORAGEGRSMASSMTHDIFF(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.FINDSTORAGEGRSMASSMTHDIFF      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END FINDSTORAGEGRSMASSMTHDIFF;
   FUNCTION FINDSTORAGEWATDAYDIFF(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.FINDSTORAGEWATDAYDIFF      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END FINDSTORAGEWATDAYDIFF;
   FUNCTION GETSTORAGEDAYCLOSINGENERGY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EXCLUDE_OUT_OF_SERVICE IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.GETSTORAGEDAYCLOSINGENERGY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EXCLUDE_OUT_OF_SERVICE );
         RETURN ret_value;
   END GETSTORAGEDAYCLOSINGENERGY;
   FUNCTION GETSTORAGELIFTEDNETVOLBBLS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.GETSTORAGELIFTEDNETVOLBBLS      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETSTORAGELIFTEDNETVOLBBLS;
   FUNCTION FINDEXPNOTLIFTEDMTHGRSBBLS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.FINDEXPNOTLIFTEDMTHGRSBBLS      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END FINDEXPNOTLIFTEDMTHGRSBBLS;
   FUNCTION FINDEXPNOTLIFTEDMTHGRSSM3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.FINDEXPNOTLIFTEDMTHGRSSM3      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END FINDEXPNOTLIFTEDMTHGRSSM3;
   FUNCTION FINDEXPNOTLIFTEDMTHNETBBLS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.FINDEXPNOTLIFTEDMTHNETBBLS      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END FINDEXPNOTLIFTEDMTHNETBBLS;
   FUNCTION FINDSTORAGENETMASSMTHDIFF(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.FINDSTORAGENETMASSMTHDIFF      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END FINDSTORAGENETMASSMTHDIFF;
   FUNCTION GETSTORAGEDAYCLOSINGNETVOL(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EXCLUDE_OUT_OF_SERVICE IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.GETSTORAGEDAYCLOSINGNETVOL      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EXCLUDE_OUT_OF_SERVICE );
         RETURN ret_value;
   END GETSTORAGEDAYCLOSINGNETVOL;
   FUNCTION GETSTORAGEDAYGRSCLOSINGMASS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EXCLUDE_OUT_OF_SERVICE IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.GETSTORAGEDAYGRSCLOSINGMASS      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EXCLUDE_OUT_OF_SERVICE );
         RETURN ret_value;
   END GETSTORAGEDAYGRSCLOSINGMASS;
   FUNCTION GETSTORAGEDAYOPENINGDILUENT(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EXCLUDE_OUT_OF_SERVICE IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.GETSTORAGEDAYOPENINGDILUENT      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EXCLUDE_OUT_OF_SERVICE );
         RETURN ret_value;
   END GETSTORAGEDAYOPENINGDILUENT;
   FUNCTION GETSTORAGEDAYOPENINGENERGY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EXCLUDE_OUT_OF_SERVICE IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.GETSTORAGEDAYOPENINGENERGY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EXCLUDE_OUT_OF_SERVICE );
         RETURN ret_value;
   END GETSTORAGEDAYOPENINGENERGY;
   FUNCTION GETSTORAGEDAYOPENINGNETMASS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EXCLUDE_OUT_OF_SERVICE IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.GETSTORAGEDAYOPENINGNETMASS      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EXCLUDE_OUT_OF_SERVICE );
         RETURN ret_value;
   END GETSTORAGEDAYOPENINGNETMASS;
   FUNCTION FINDEXPNOTLIFTEDDAYNETSM3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.FINDEXPNOTLIFTEDDAYNETSM3      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END FINDEXPNOTLIFTEDDAYNETSM3;
   FUNCTION FINDSTORAGELIFTEDGRSVOLSM3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.FINDSTORAGELIFTEDGRSVOLSM3      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END FINDSTORAGELIFTEDGRSVOLSM3;
   FUNCTION FINDEXPNOTLIFTEDDAYGRSSM3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.FINDEXPNOTLIFTEDDAYGRSSM3      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END FINDEXPNOTLIFTEDDAYGRSSM3;
   FUNCTION FINDSTORAGEENERGYDAYDIFF(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.FINDSTORAGEENERGYDAYDIFF      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END FINDSTORAGEENERGYDAYDIFF;
   FUNCTION FINDSTORAGELIFTEDGRSVOLBBLS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.FINDSTORAGELIFTEDGRSVOLBBLS      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END FINDSTORAGELIFTEDGRSVOLBBLS;
   FUNCTION FINDSTORAGELIFTEDNETVOLBBLS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.FINDSTORAGELIFTEDNETVOLBBLS      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END FINDSTORAGELIFTEDNETVOLBBLS;
   FUNCTION FINDSTORAGEGRSMTHDIFF(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.FINDSTORAGEGRSMTHDIFF      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END FINDSTORAGEGRSMTHDIFF;
   FUNCTION GETSTORAGEDAYCLOSINGWATVOL(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EXCLUDE_OUT_OF_SERVICE IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.GETSTORAGEDAYCLOSINGWATVOL      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EXCLUDE_OUT_OF_SERVICE );
         RETURN ret_value;
   END GETSTORAGEDAYCLOSINGWATVOL;
   FUNCTION GETSTORAGEDAYOPENINGNETVOL(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EXCLUDE_OUT_OF_SERVICE IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.GETSTORAGEDAYOPENINGNETVOL      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EXCLUDE_OUT_OF_SERVICE );
         RETURN ret_value;
   END GETSTORAGEDAYOPENINGNETVOL;
   FUNCTION GETSTORAGEDAYOPENINGWATVOL(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EXCLUDE_OUT_OF_SERVICE IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.GETSTORAGEDAYOPENINGWATVOL      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EXCLUDE_OUT_OF_SERVICE );
         RETURN ret_value;
   END GETSTORAGEDAYOPENINGWATVOL;
   FUNCTION GETSTORAGELIFTEDGRSVOLSM3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.GETSTORAGELIFTEDGRSVOLSM3      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETSTORAGELIFTEDGRSVOLSM3;
   FUNCTION FINDSTORAGEGRSMASSDAYDIFF(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.FINDSTORAGEGRSMASSDAYDIFF      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END FINDSTORAGEGRSMASSDAYDIFF;
   FUNCTION FINDSTORAGELIFTEDNETVOLSM3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.FINDSTORAGELIFTEDNETVOLSM3      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END FINDSTORAGELIFTEDNETVOLSM3;
   FUNCTION FINDSTORAGENETDAYDIFF(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.FINDSTORAGENETDAYDIFF      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END FINDSTORAGENETDAYDIFF;
   FUNCTION FINDSTORAGENETMASSDAYDIFF(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.FINDSTORAGENETMASSDAYDIFF      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END FINDSTORAGENETMASSDAYDIFF;
   FUNCTION FINDSTORAGETOTALVOLUME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EXCLUDE_OUT_OF_SERVICE IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.FINDSTORAGETOTALVOLUME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EXCLUDE_OUT_OF_SERVICE );
         RETURN ret_value;
   END FINDSTORAGETOTALVOLUME;
   FUNCTION GETSTORAGEDAYGRSCLOSINGVOL(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EXCLUDE_OUT_OF_SERVICE IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.GETSTORAGEDAYGRSCLOSINGVOL      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EXCLUDE_OUT_OF_SERVICE );
         RETURN ret_value;
   END GETSTORAGEDAYGRSCLOSINGVOL;
   FUNCTION GETSTORAGEDAYGRSOPENINGVOL(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EXCLUDE_OUT_OF_SERVICE IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.GETSTORAGEDAYGRSOPENINGVOL      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EXCLUDE_OUT_OF_SERVICE );
         RETURN ret_value;
   END GETSTORAGEDAYGRSOPENINGVOL;
   FUNCTION FINDSTORAGEDILUENTDAYDIFF(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.FINDSTORAGEDILUENTDAYDIFF      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END FINDSTORAGEDILUENTDAYDIFF;
   FUNCTION FINDSTORAGENETMTHDIFF(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.FINDSTORAGENETMTHDIFF      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END FINDSTORAGENETMTHDIFF;
   FUNCTION GETSTORAGEDAYCLOSINGDILUENT(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EXCLUDE_OUT_OF_SERVICE IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.GETSTORAGEDAYCLOSINGDILUENT      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EXCLUDE_OUT_OF_SERVICE );
         RETURN ret_value;
   END GETSTORAGEDAYCLOSINGDILUENT;
   FUNCTION GETSTORAGEDAYGRSOPENINGMASS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EXCLUDE_OUT_OF_SERVICE IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.GETSTORAGEDAYGRSOPENINGMASS      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EXCLUDE_OUT_OF_SERVICE );
         RETURN ret_value;
   END GETSTORAGEDAYGRSOPENINGMASS;
   FUNCTION GETSTORAGEDAYGRSSTDOILCLOSEVOL(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EXCLUDE_OUT_OF_SERVICE IN VARCHAR2 DEFAULT 'N')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.GETSTORAGEDAYGRSSTDOILCLOSEVOL      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EXCLUDE_OUT_OF_SERVICE );
         RETURN ret_value;
   END GETSTORAGEDAYGRSSTDOILCLOSEVOL;
   FUNCTION GETSTORAGELIFTEDNETVOLSM3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_STORAGE_MEASUREMENT.GETSTORAGELIFTEDNETVOLSM3      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETSTORAGELIFTEDNETVOLSM3;

END RPBP_STORAGE_MEASUREMENT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPBP_STORAGE_MEASUREMENT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/08/2019 03.37.55 AM


