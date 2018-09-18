CREATE OR REPLACE package body ECDP_CONSTANT_STANDARD is
/****************************************************************
** Package        :  ECDP_CONSTANT_STANDARD, body part
**
** $Revision: 1.4 $
**
** Purpose        :  Definition of phase constants
**
** Documentation  :  www.energy-components.com
**
** Created  : 5/31/2007 5:10:52 PM NURLIZA JAILUDDIN
**
** Modification history:
**
** Version  Date        Whom  Change description:
** -------  ------      ----- -----------------------------------
** 	    01.10.2009  sharawan   ECPD-10161: Added new procedure copyStandardConstant to enable new functionality
**                                             to copy existing Constant Standard record
**          01.10.2009  davendran  ECPD-12842: EC9_3 and SP9 - ECDP_CONSTANT_STANDARD with a compile error of: component 'NCVM' must be declared.
*****************************************************************/

FUNCTION next_daytime(
         p_object_id VARCHAR2,
         p_daytime DATE,
         p_class_name VARCHAR2,
         p_num_rows NUMBER DEFAULT 1)
RETURN DATE IS
CURSOR c_sum_fac IS
SELECT daytime
FROM CONST_STD_COMP_SUM_FAC
WHERE object_id = p_object_id
AND daytime > p_daytime
ORDER BY daytime ASC;

CURSOR c_ideal_mol IS
SELECT daytime
FROM CONST_STD_CV_IDEAL
WHERE object_id = p_object_id
AND method='MOL'
AND daytime > p_daytime
ORDER BY daytime ASC;

CURSOR c_ideal_mass IS
SELECT daytime
FROM CONST_STD_CV_IDEAL
WHERE object_id = p_object_id
AND method ='MASS'
AND daytime > p_daytime
ORDER BY daytime ASC;

CURSOR c_ideal_vol IS
SELECT daytime
FROM CONST_STD_CV_IDEAL_VOL
WHERE object_id = p_object_id
AND daytime > p_daytime
ORDER BY daytime ASC;

CURSOR c_k_interpol IS
SELECT daytime
FROM CONST_STD_K_INTERPOL
WHERE object_id = p_object_id
AND daytime > p_daytime
ORDER BY daytime ASC;

CURSOR c_vi_interpol IS
SELECT daytime
FROM CONST_STD_VI_INTERPOL
WHERE object_id = p_object_id
AND daytime > p_daytime
ORDER BY daytime ASC;

ld_return_val DATE := NULL;

BEGIN

IF p_class_name='CONST_STD_COMP_SUM_FAC' THEN
        IF p_num_rows >= 1 THEN
            FOR cur_rec IN c_sum_fac LOOP
               ld_return_val := cur_rec.daytime;
               IF c_sum_fac%ROWCOUNT = p_num_rows THEN
                  EXIT;
               END IF;
            END LOOP;
         END IF;
         RETURN ld_return_val;
ELSIF p_class_name='CONST_STD_CV_IDEAL_MOL' THEN
      IF p_num_rows >= 1 THEN
            FOR cur_rec IN c_ideal_mol LOOP
               ld_return_val := cur_rec.daytime;
               IF c_ideal_mol%ROWCOUNT = p_num_rows THEN
                  EXIT;
               END IF;
            END LOOP;
         END IF;
         RETURN ld_return_val;
ELSIF p_class_name='CONST_STD_CV_IDEAL_MASS' THEN
      IF p_num_rows >= 1 THEN
            FOR cur_rec IN c_ideal_mass LOOP
               ld_return_val := cur_rec.daytime;
               IF c_ideal_mass%ROWCOUNT = p_num_rows THEN
                  EXIT;
               END IF;
            END LOOP;
         END IF;
         RETURN ld_return_val;
ELSIF p_class_name='CONST_STD_CV_IDEAL_VOL' THEN
      IF p_num_rows >= 1 THEN
            FOR cur_rec IN c_ideal_vol LOOP
               ld_return_val := cur_rec.daytime;
               IF c_ideal_vol%ROWCOUNT = p_num_rows THEN
                  EXIT;
               END IF;
            END LOOP;
         END IF;
         RETURN ld_return_val;
ELSIF p_class_name='CONST_STD_K_INTERPOL' THEN
      IF p_num_rows >= 1 THEN
            FOR cur_rec IN c_k_interpol LOOP
               ld_return_val := cur_rec.daytime;
               IF c_k_interpol%ROWCOUNT = p_num_rows THEN
                  EXIT;
               END IF;
            END LOOP;
         END IF;
         RETURN ld_return_val;
ELSIF p_class_name='CONST_STD_VI_INTERPOL' THEN
      IF p_num_rows >= 1 THEN
            FOR cur_rec IN c_vi_interpol LOOP
               ld_return_val := cur_rec.daytime;
               IF c_vi_interpol%ROWCOUNT = p_num_rows THEN
                  EXIT;
               END IF;
            END LOOP;
         END IF;
         RETURN ld_return_val;
END IF;
RETURN ld_return_val;

END next_daytime;



FUNCTION prev_daytime(
         p_object_id VARCHAR2,
         p_daytime DATE,
         p_class_name VARCHAR2,
         p_num_rows NUMBER DEFAULT 1)
RETURN DATE IS

CURSOR c_sum_fac IS
SELECT daytime
FROM CONST_STD_COMP_SUM_FAC
WHERE object_id = p_object_id
AND daytime < p_daytime
ORDER BY daytime DESC;

CURSOR c_ideal_mol IS
SELECT daytime
FROM CONST_STD_CV_IDEAL
WHERE object_id = p_object_id
AND daytime < p_daytime
ORDER BY daytime ASC;

CURSOR c_ideal_mass IS
SELECT daytime
FROM CONST_STD_CV_IDEAL
WHERE object_id = p_object_id
AND method ='MASS'
AND daytime < p_daytime
ORDER BY daytime ASC;

CURSOR c_ideal_vol IS
SELECT daytime
FROM CONST_STD_CV_IDEAL_VOL
WHERE object_id = p_object_id
AND daytime < p_daytime
ORDER BY daytime ASC;

CURSOR c_k_interpol IS
SELECT daytime
FROM CONST_STD_K_INTERPOL
WHERE object_id = p_object_id
AND daytime < p_daytime
ORDER BY daytime ASC;

CURSOR c_vi_interpol IS
SELECT daytime
FROM CONST_STD_VI_INTERPOL
WHERE object_id = p_object_id
AND daytime < p_daytime
ORDER BY daytime ASC;

ld_return_val DATE := NULL;

BEGIN

IF p_class_name='CONST_STD_COMP_SUM_FAC' THEN
   IF p_num_rows >= 1 THEN
      FOR cur_rec IN c_sum_fac LOOP
         ld_return_val := cur_rec.daytime;
         IF c_sum_fac%ROWCOUNT = p_num_rows THEN
            EXIT;
         END IF;
      END LOOP;
   END IF;
   RETURN ld_return_val;
ELSIF p_class_name='CONST_STD_CV_IDEAL_MOL' THEN
   IF p_num_rows >= 1 THEN
      FOR cur_rec IN c_ideal_mol LOOP
         ld_return_val := cur_rec.daytime;
         IF c_ideal_mol%ROWCOUNT = p_num_rows THEN
            EXIT;
         END IF;
      END LOOP;
   END IF;
   RETURN ld_return_val;
ELSIF p_class_name='CONST_STD_CV_IDEAL_MASS' THEN
      IF p_num_rows >= 1 THEN
            FOR cur_rec IN c_ideal_mass LOOP
               ld_return_val := cur_rec.daytime;
               IF c_ideal_mass%ROWCOUNT = p_num_rows THEN
                  EXIT;
               END IF;
            END LOOP;
         END IF;
         RETURN ld_return_val;
ELSIF p_class_name='CONST_STD_CV_IDEAL_VOL' THEN
      IF p_num_rows >= 1 THEN
            FOR cur_rec IN c_ideal_vol LOOP
               ld_return_val := cur_rec.daytime;
               IF c_ideal_vol%ROWCOUNT = p_num_rows THEN
                  EXIT;
               END IF;
            END LOOP;
         END IF;
         RETURN ld_return_val;
ELSIF p_class_name='CONST_STD_K_INTERPOL' THEN
      IF p_num_rows >= 1 THEN
            FOR cur_rec IN c_k_interpol LOOP
               ld_return_val := cur_rec.daytime;
               IF c_k_interpol%ROWCOUNT = p_num_rows THEN
                  EXIT;
               END IF;
            END LOOP;
         END IF;
         RETURN ld_return_val;
ELSIF p_class_name='CONST_STD_VI_INTERPOL' THEN
      IF p_num_rows >= 1 THEN
            FOR cur_rec IN c_vi_interpol LOOP
               ld_return_val := cur_rec.daytime;
               IF c_vi_interpol%ROWCOUNT = p_num_rows THEN
                  EXIT;
               END IF;
            END LOOP;
         END IF;
         RETURN ld_return_val;
END IF;
    RETURN ld_return_val;

END prev_daytime;

PROCEDURE copyStandardConstant(p_std_code      VARCHAR2,
                               p_std_copy_code VARCHAR2,
                               p_std_copy_name VARCHAR2,
                               p_user_id       VARCHAR2) IS

  cs_row constant_standard%ROWTYPE;
  csv_row constant_standard_version%ROWTYPE;
  cc_row component_constant%ROWTYPE;
  csf_row const_std_comp_sum_fac%ROWTYPE;
  cim_row const_std_cv_ideal%ROWTYPE;--for mass
  cimol_row const_std_cv_ideal%ROWTYPE;--for mol
  civ_row const_std_cv_ideal_vol%ROWTYPE;
  ki_row const_std_k_interpol%ROWTYPE;
  vi_row const_std_vi_interpol%ROWTYPE;

   CURSOR c_cs IS
    SELECT tcs.*
      FROM CONSTANT_STANDARD tcs
     WHERE tcs.object_code = p_std_code;

  CURSOR c_csv IS
    SELECT csv.*
      FROM constant_standard_version csv,
           constant_standard cs
      WHERE csv.object_id = cs.object_id
       AND cs.object_code = p_std_code;

   CURSOR c_cc IS
    SELECT cc.*
      FROM COMPONENT_CONSTANT cc,
           constant_standard cs
       WHERE cc.object_id = cs.object_id
        AND cs.object_code = p_std_code;

   CURSOR c_csf IS
    SELECT tcsf.*
      FROM const_std_comp_sum_fac tcsf,
           constant_standard cs
     WHERE tcsf.OBJECT_ID = cs.object_id
      AND cs.object_code = p_std_code;

   CURSOR c_cim IS
    SELECT tcim.*
      FROM const_std_cv_ideal tcim,
           constant_standard cs
      WHERE tcim.OBJECT_ID = cs.object_id
       AND cs.object_code = p_std_code
       AND tcim.method = 'MASS';

   CURSOR c_cimol IS
    SELECT tcimol.*
      FROM const_std_cv_ideal tcimol,
           constant_standard cs
      WHERE tcimol.OBJECT_ID = cs.object_id
       AND cs.object_code = p_std_code
       AND tcimol.method = 'MOL';

   CURSOR c_civ IS
    SELECT tciv.*
      FROM const_std_cv_ideal_vol tciv,
           constant_standard cs
      WHERE tciv.OBJECT_ID = cs.object_id
       AND cs.object_code = p_std_code;

   CURSOR c_ki IS
    SELECT tki.*
      FROM const_std_k_interpol tki,
           constant_standard cs
      WHERE tki.OBJECT_ID = cs.object_id
       AND cs.object_code = p_std_code;

   CURSOR c_vi IS
    SELECT tvi.*
      FROM const_std_vi_interpol tvi,
           constant_standard cs
      WHERE tvi.OBJECT_ID = cs.object_id
       AND cs.object_code = p_std_code;


BEGIN

  -- Copy constant_standard
  OPEN c_cs;
  LOOP
      FETCH c_cs INTO cs_row;
      EXIT WHEN c_cs%NOTFOUND;

      INSERT
        INTO CONSTANT_STANDARD (OBJECT_CODE,START_DATE,END_DATE,COMMENTS,created_by,created_date)
      VALUES(p_std_copy_code,cs_row.START_DATE,cs_row.END_DATE,cs_row.COMMENTS,p_user_id,sysdate);

  END LOOP;
  CLOSE c_cs;

  -- Copy constant_standard_version
  OPEN c_csv;
  LOOP
      FETCH c_csv INTO csv_row;
      EXIT WHEN c_csv%NOTFOUND;

     INSERT
       INTO CONSTANT_STANDARD_VERSION (OBJECT_ID,DAYTIME,END_DATE,NAME,REF_PRESSURE,created_by,created_date)
      VALUES(ec_constant_standard.object_id_by_uk(p_std_copy_code),csv_row.DAYTIME,csv_row.END_DATE,p_std_copy_name,csv_row.REF_PRESSURE,p_user_id,sysdate);

  END LOOP;
  CLOSE c_csv;

   -- Copy component_constant
  OPEN c_cc;
  LOOP
      FETCH c_cc INTO cc_row;
      EXIT WHEN c_cc%NOTFOUND;

     INSERT
        INTO component_constant(OBJECT_ID,DAYTIME,COMPONENT_NO,MOL_WT,MOL_VOL,COMP_FACTOR,IDEAL_DENSITY,SUM_FACTOR,IDEAL_GCV,IDEAL_NCV,OIL_DENSITY,NCV,GCVM,NCVM,CREATED_BY,CREATED_DATE)
     VALUES (ec_constant_standard.object_id_by_uk(p_std_copy_code),cc_row.DAYTIME,cc_row.COMPONENT_NO,cc_row.MOL_WT,cc_row.MOL_VOL,cc_row.COMP_FACTOR,cc_row.IDEAL_DENSITY,cc_row.SUM_FACTOR,cc_row.IDEAL_GCV,cc_row.IDEAL_NCV,cc_row.OIL_DENSITY,cc_row.NCV,cc_row.GCVM,cc_row.NCVM,p_user_id,sysdate);

  END LOOP;
  CLOSE c_cc;

  -- Copy const_std_comp_sum_fac
  OPEN c_csf;
  LOOP
      FETCH c_csf INTO csf_row;
      EXIT WHEN c_csf%NOTFOUND;

      INSERT
        INTO const_std_comp_sum_fac(OBJECT_ID,DAYTIME,COMPONENT_NO,METER_TEMP,Z_FACTOR,SQRTB_FACTOR,COMMENTS,CREATED_BY,CREATED_DATE)
      VALUES (ec_constant_standard.object_id_by_uk(p_std_copy_code),csf_row.DAYTIME,csf_row.COMPONENT_NO,csf_row.METER_TEMP,csf_row.Z_FACTOR,csf_row.SQRTB_FACTOR,csf_row.COMMENTS,p_user_id,sysdate);

  END LOOP;
  CLOSE c_csf;

  -- Copy const_std_cv_ideal for MASS
  OPEN c_cim;
  LOOP
      FETCH c_cim INTO cim_row;
      EXIT WHEN c_cim%NOTFOUND;

      INSERT
        INTO const_std_cv_ideal(OBJECT_ID,DAYTIME,METHOD,COMPONENT_NO,COMB_TEMP,SUPERIOR,INFERIOR,COMMENTS,CREATED_BY,CREATED_DATE)
      VALUES (ec_constant_standard.object_id_by_uk(p_std_copy_code),cim_row.DAYTIME,cim_row.METHOD,cim_row.COMPONENT_NO,cim_row.COMB_TEMP,cim_row.SUPERIOR,cim_row.INFERIOR,cim_row.COMMENTS,p_user_id,sysdate);

  END LOOP;
  CLOSE c_cim;

  -- Copy const_std_cv_ideal for MOL
  OPEN c_cimol;
  LOOP
      FETCH c_cimol INTO cimol_row;
      EXIT WHEN c_cimol%NOTFOUND;

      INSERT
        INTO const_std_cv_ideal(OBJECT_ID,DAYTIME,METHOD,COMPONENT_NO,COMB_TEMP,SUPERIOR,INFERIOR,COMMENTS,CREATED_BY,CREATED_DATE)
      VALUES (ec_constant_standard.object_id_by_uk(p_std_copy_code),cimol_row.DAYTIME,cimol_row.METHOD,cimol_row.COMPONENT_NO,cimol_row.COMB_TEMP,cimol_row.SUPERIOR,cimol_row.INFERIOR,cimol_row.COMMENTS,p_user_id,sysdate);

  END LOOP;
  CLOSE c_cimol;

  -- Copy const_std_cv_ideal_vol
  OPEN c_civ;
  LOOP
      FETCH c_civ INTO civ_row;
      EXIT WHEN c_civ%NOTFOUND;

      INSERT
        INTO const_std_cv_ideal_vol(OBJECT_ID,DAYTIME,COMPONENT_NO,COMB_TEMP,METER_TEMP,SUPERIOR,INFERIOR,COMMENTS,CREATED_BY,CREATED_DATE)
      VALUES (ec_constant_standard.object_id_by_uk(p_std_copy_code),civ_row.DAYTIME,civ_row.COMPONENT_NO,civ_row.COMB_TEMP,civ_row.METER_TEMP,civ_row.SUPERIOR,civ_row.INFERIOR,civ_row.COMMENTS,p_user_id,sysdate);

  END LOOP;
  CLOSE c_civ;

  -- Copy const_std_k_interpol
  OPEN c_ki;
  LOOP
      FETCH c_ki INTO ki_row;
      EXIT WHEN c_ki%NOTFOUND;

      INSERT
        INTO const_std_k_interpol(OBJECT_ID,DAYTIME,MOL_WT,GAS_TEMP,K1_FACTOR,K2_FACTOR,COMMENTS,CREATED_BY,CREATED_DATE)
      VALUES (ec_constant_standard.object_id_by_uk(p_std_copy_code),ki_row.DAYTIME,ki_row.MOL_WT,ki_row.GAS_TEMP,ki_row.K1_FACTOR,ki_row.K2_FACTOR,ki_row.COMMENTS,p_user_id,sysdate);

  END LOOP;
  CLOSE c_ki;

  -- Copy const_std_vi_interpol
  OPEN c_vi;
  LOOP
      FETCH c_vi INTO vi_row;
      EXIT WHEN c_vi%NOTFOUND;

      INSERT
        INTO const_std_vi_interpol(OBJECT_ID,DAYTIME,COMPONENT_NO,GAS_TEMP,VI_FACTOR,COMMENTS,CREATED_BY,CREATED_DATE)
      VALUES (ec_constant_standard.object_id_by_uk(p_std_copy_code),vi_row.DAYTIME,vi_row.COMPONENT_NO,vi_row.GAS_TEMP,vi_row.VI_FACTOR,vi_row.COMMENTS,p_user_id,sysdate);

  END LOOP;
  CLOSE c_vi;

END copyStandardConstant;

end ECDP_CONSTANT_STANDARD;