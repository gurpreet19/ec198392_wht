CREATE OR REPLACE FORCE VIEW "V_WELL_ACCESS" ("FACILITY_ID", "DAYTIME", "OBJECT_ID", "NAME", "FACILITY_TYPE") AS 
  SELECT   pf.object_id as facility_id,
         EcDp_Date_Time.getCurrentSysdate AS daytime,
         pf.object_id,
         ec_fcty_version.name(pf.object_id, EcDp_Date_Time.getCurrentSysdate, '<=') AS name,
         pf.class_name AS facility_type
    FROM t_basis_access a, t_basis_userrole u, t_basis_object o, fcty_version fv, production_facility pf
    WHERE a.object_id = o.object_id
     AND u.role_id = a.role_id
     AND u.app_id = a.app_id
     AND u.app_id = o.app_id
     AND a.level_id >= 10
     AND upper(u.user_id) = upper(USER)
     AND EcDp_Date_Time.getCurrentSysdate BETWEEN fv.daytime AND Nvl(fv.end_date, EcDp_Date_Time.getCurrentSysdate + 1)
     AND pf.object_id = fv.object_id
     AND EcDp_Date_Time.getCurrentSysdate BETWEEN pf.start_date AND Nvl(pf.end_date, EcDp_Date_Time.getCurrentSysdate + 1)