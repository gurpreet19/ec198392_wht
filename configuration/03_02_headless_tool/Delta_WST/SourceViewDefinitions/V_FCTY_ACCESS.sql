CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCTY_ACCESS" ("OBJECT_ID", "NAME", "FACILITY_TYPE") AS 
  SELECT   pf.object_id,
         ec_fcty_version.name(pf.object_id,
         		      Ecdp_Timestamp.getCurrentSysdate,
         		      '<=') AS name,
         pf.class_name AS facility_type
    FROM t_basis_access a, t_basis_userrole u, t_basis_object o, fcty_version fv, production_facility pf
   WHERE a.object_id = o.object_id
     AND u.role_id = a.role_id
     AND u.app_id = a.app_id
     AND u.app_id = o.app_id
     AND a.level_id >= 10
     AND upper(u.user_id) = upper(USER)
     AND pf.object_code = o.object_name
     AND fv.daytime <= Ecdp_Timestamp.getCurrentSysdate
     AND Nvl(fv.end_date, Ecdp_Timestamp.getCurrentSysdate + 1) > Ecdp_Timestamp.getCurrentSysdate
     AND pf.object_id=fv.object_id