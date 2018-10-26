CREATE OR REPLACE FORCE VIEW "V_DEFER_LOSS_STRM_DAY_REPORT" ("EVENT_NO", "OBJECT_ID", "PARENT_OBJECT_ID", "DAYTIME", "TYPE", "CLASS_NAME", "PARENT_ID", "CHOKE_MODEL_ID", "NET_VOL_RATE", "ACTUAL_NET_VOL_RATE", "NET_MASS_RATE", "ACTUAL_NET_MASS_RATE", "FCST_NET_VOL_RATE", "FCST_NET_MASS_RATE", "BALANCE_VOL", "BALANCE_MASS", "UNASSIGNED_LOSS_VOL", "UNASSIGNED_LOSS_MASS", "UOM", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_defer_loss_strm_day_report.sql
-- View name: V_DEFER_LOSS_STRM_DAY_REPORT
--
-- $Revision: 1.13.2.2 $
--
-- Purpose  :
--
-- Modification history:
--
-- Date       Whom      Change description:
-- ---------- --------  --------------------------------------------------------------------------------
-- 18.06.2010 farhaann  New
-- 09.11.2010 rajarsar  ECPD-15770:Updated
-- 27.12.2010 rajarsar  ECPD-16192:Updated
-- 27.04.2011 rajarsar  ECPD-17107:Added event no to enable filtering based on events for streams
-- 12.07.2011 rajarsar  ECPD-18053:Updated business logics for unassigned vol and unassigned mass
-- 29.07.2011 rajarsar  ECPD-18206:Added support unit conversion for ACTUAL_NET_VOL_RATE and ACTUAL_NET_MASS_RATE
-- 21.11.2011 rajarsar  ECPD-18825:Added unit conversion support for FCST_NET_VOL_RATE and FCST_NET_MASS_RATE
-- 12.12.2011 rajarsar  ECPD-19175:Updated with function call to retrieve sum of net vol and net mass
-- 20.04.2012 rajarsar  ECPD-20660:Updated function call for unassigned vol and unassigned mass to return abs value
-- 08.08.2012 makkkkam  ECPD-21684:Updated to support configuration from strm_day_stream_loss
----------------------------------------------------------------------------------------------------
select
event_no
      ,object_id
      , parent_object_id
      ,daytime
      ,type
      ,class_name
      ,parent_id
      , choke_model_id
      ,net_vol_rate
      ,ACTUAL_NET_VOL_RATE
      , NET_MASS_RATE
      , ACTUAL_NET_MASS_RATE
      , FCST_NET_VOL_RATE
      , FCST_NET_MASS_RATE
      ,BALANCE_VOL
      ,BALANCE_MASS
      ,UNASSIGNED_LOSS_VOL
      ,UNASSIGNED_LOSS_MASS
      ,UOM
       ,TO_CHAR('P') RECORD_STATUS
      ,TO_CHAR(NULL) CREATED_BY
      ,TO_DATE(Null) CREATED_DATE
      ,TO_CHAR(NULL) LAST_UPDATED_BY
      ,TO_DATE(NULL) LAST_UPDATED_DATE
      ,TO_NUMBER(NULL) REV_NO
      ,TO_CHAR(NULL) REV_TEXT
      FROM (
        select  f.event_no event_no
        ,e.object_id object_id
        ,f.object_id parent_object_id
        ,s.daytime daytime
        ,s.type type
        ,f.class_name class_name
        ,decode(f.class_name,'DEFER_LOSS_FCTY_EVENT',nvl(cmv.op_fcty_class_2_id, cmv.op_fcty_class_1_id),nvl(cmv.geo_field_id,cmv.geo_sub_field_id)) parent_id -- parent id is either the id of facility or field the choke model belongs to
        ,e.choke_model_id choke_model_id
        ,ecbp_defer_loss_accounting.calcDailyVolLoss( f.object_id,e.object_id,s.type, s.daytime) net_vol_rate
        ,EcDp_Unit.convertValue(EcBp_Stream_Fluid.findNetStdVol(e.object_id, s.daytime), EcDp_Unit.GetUnitFromLogical(ec_choke_model_version.uom(e.choke_model_id, s.daytime,'<=')),EcDp_Unit.GetViewUnitFromLogical(ec_choke_model_version.uom(e.choke_model_id, s.daytime,'<=')),s.daytime) ACTUAL_NET_VOL_RATE
        ,ecbp_defer_loss_accounting.calcDailyMassLoss(f.object_id,e.object_id,s.type, s.daytime) NET_MASS_RATE
        ,EcDp_Unit.convertValue(EcBp_Stream_Fluid.findNetStdMass(e.object_id, s.daytime), EcDp_Unit.GetUnitFromLogical(ec_choke_model_version.uom(e.choke_model_id, s.daytime,'<=')),EcDp_Unit.GetViewUnitFromLogical(ec_choke_model_version.uom(e.choke_model_id, s.daytime,'<=')),s.daytime) ACTUAL_NET_MASS_RATE
        ,decode(f.type,'BUDGET',EcDp_Unit.convertValue(ec_object_plan.volume_rate(e.object_id,s.daytime,'STRM_PLAN_BUDGET','<='),EcDp_Unit.GetUnitFromLogical(ecbp_defer_loss_accounting.getRateUom(e.object_id, s.daytime,'VOLUME')),EcDp_Unit.GetViewUnitFromLogical(ecbp_defer_loss_accounting.getRateUom(e.object_id, s.daytime,'VOLUME')),s.daytime),'POTENTIAL',ecbp_choke_model.calcTotalMppLip(e.choke_model_id,s.daytime,'CHOKE_MODEL_MPP'))FCST_NET_VOL_RATE
     ,decode(f.type,'BUDGET',EcDp_Unit.convertValue(ec_object_plan.mass_rate(e.object_id,s.daytime,'STRM_PLAN_BUDGET','<='),EcDp_Unit.GetUnitFromLogical(ecbp_defer_loss_accounting.getRateUom(e.object_id, s.daytime,'MASS')),EcDp_Unit.GetViewUnitFromLogical(ecbp_defer_loss_accounting.getRateUom(e.object_id, s.daytime,'MASS')),s.daytime),'POTENTIAL',ecbp_choke_model.calcTotalMppLip(e.choke_model_id,s.daytime,'CHOKE_MODEL_MPP'))FCST_NET_MASS_RATE
     ,nvl(EcDp_Unit.convertValue(EcBp_Stream_Fluid.findNetStdVol(e.object_id, s.daytime), EcDp_Unit.GetUnitFromLogical(ec_choke_model_version.uom(e.choke_model_id, s.daytime,'<=')),EcDp_Unit.GetViewUnitFromLogical(ec_choke_model_version.uom(e.choke_model_id, s.daytime,'<=')),s.daytime),0) -  nvl(decode(f.type,'BUDGET',EcDp_Unit.convertValue(ec_object_plan.volume_rate(e.object_id,s.daytime,'STRM_PLAN_BUDGET','<='),EcDp_Unit.GetUnitFromLogical(ecbp_defer_loss_accounting.getRateUom(e.object_id, s.daytime,'VOLUME')),EcDp_Unit.GetViewUnitFromLogical(ecbp_defer_loss_accounting.getRateUom(e.object_id, s.daytime,'VOLUME')),s.daytime),'POTENTIAL',ecbp_choke_model.calcTotalMppLip(e.choke_model_id,s.daytime,'CHOKE_MODEL_MPP')),0) BALANCE_VOL
     ,nvl(EcDp_Unit.convertValue(EcBp_Stream_Fluid.findNetStdMass(e.object_id, s.daytime), EcDp_Unit.GetUnitFromLogical(ec_choke_model_version.uom(e.choke_model_id, s.daytime,'<=')),EcDp_Unit.GetViewUnitFromLogical(ec_choke_model_version.uom(e.choke_model_id, s.daytime,'<=')),s.daytime),0) -   nvl(decode(f.type,'BUDGET',EcDp_Unit.convertValue(ec_object_plan.mass_rate(e.object_id,s.daytime,'STRM_PLAN_BUDGET','<='),EcDp_Unit.GetUnitFromLogical(ecbp_defer_loss_accounting.getRateUom(e.object_id, s.daytime,'MASS')),EcDp_Unit.GetViewUnitFromLogical(ecbp_defer_loss_accounting.getRateUom(e.object_id, s.daytime,'MASS')),s.daytime),'POTENTIAL',ecbp_choke_model.calcTotalMppLip(e.choke_model_id,s.daytime,'CHOKE_MODEL_MPP')),0) BALANCE_MASS
     ,abs(abs(nvl(EcDp_Unit.convertValue(EcBp_Stream_Fluid.findNetStdVol(e.object_id, s.daytime), EcDp_Unit.GetUnitFromLogical(ec_choke_model_version.uom(e.choke_model_id, s.daytime,'<=')),EcDp_Unit.GetViewUnitFromLogical(ec_choke_model_version.uom(e.choke_model_id, s.daytime,'<=')),s.daytime),0) - nvl(decode(f.type,'BUDGET',EcDp_Unit.convertValue(ec_object_plan.volume_rate(e.object_id,s.daytime,'STRM_PLAN_BUDGET','<='),EcDp_Unit.GetUnitFromLogical(ecbp_defer_loss_accounting.getRateUom(e.object_id, s.daytime,'VOLUME')),EcDp_Unit.GetViewUnitFromLogical(ecbp_defer_loss_accounting.getRateUom(e.object_id, s.daytime,'VOLUME')),s.daytime),'POTENTIAL',ecbp_choke_model.calcTotalMppLip(e.choke_model_id,s.daytime,'CHOKE_MODEL_MPP')),0)) - abs(nvl(ecbp_defer_loss_accounting.calcDailyVolLoss(f.object_id,e.object_id,s.type, s.daytime),0))) UNASSIGNED_LOSS_VOL
     ,abs(abs(nvl(EcDp_Unit.convertValue(EcBp_Stream_Fluid.findNetStdMass(e.object_id, s.daytime), EcDp_Unit.GetUnitFromLogical(ec_choke_model_version.uom(e.choke_model_id, s.daytime,'<=')),EcDp_Unit.GetViewUnitFromLogical(ec_choke_model_version.uom(e.choke_model_id, s.daytime,'<=')),s.daytime),0) - nvl(decode(f.type,'BUDGET',EcDp_Unit.convertValue(ec_object_plan.mass_rate(e.object_id,s.daytime,'STRM_PLAN_BUDGET','<='),EcDp_Unit.GetUnitFromLogical(ecbp_defer_loss_accounting.getRateUom(e.object_id, s.daytime,'MASS')),EcDp_Unit.GetViewUnitFromLogical(ecbp_defer_loss_accounting.getRateUom(e.object_id, s.daytime,'MASS')),s.daytime),'POTENTIAL',ecbp_choke_model.calcTotalMppLip(e.choke_model_id,s.daytime,'CHOKE_MODEL_MPP')),0)) - abs(nvl( ecbp_defer_loss_accounting.calcDailyMassLoss(f.object_id,e.object_id,s.type, s.daytime),0)) ) UNASSIGNED_LOSS_MASS
     ,ecdp_unit.getviewunitfromlogical(ec_choke_model_version.uom(e.choke_model_id, s.daytime,'<=')) UOM
      ,TO_CHAR('P') RECORD_STATUS
      ,TO_CHAR(NULL) CREATED_BY
      ,TO_DATE(Null) CREATED_DATE
      ,TO_CHAR(NULL) LAST_UPDATED_BY
      ,TO_DATE(NULL) LAST_UPDATED_DATE
      ,TO_NUMBER(NULL) REV_NO
      ,TO_CHAR(NULL) REV_TEXT
      from
     (select d.daytime, c.code type
        from system_days d, prosty_codes c
        where c.is_active = 'Y'
        and c.code_type = 'DEFER_LOSS_ACC_TYPE'
          ) s,
          DEFER_LOSS_STRM_EVENT e,
          DEFER_LOSS_ACC_EVENT f,
          choke_model_version cmv
          where
   e.daytime(+) = s.daytime
   and e.event_no = f.event_no
   and f.type = s.type
   and e.choke_model_id  = cmv.object_id
   and cmv.daytime <= s.daytime
   and nvl(cmv.end_date, s.daytime+1) > s.daytime
   group by f.event_no
     ,e.object_id
     ,f.object_id
     ,s.daytime,s.type
     ,f.class_name
     ,decode(f.class_name,'DEFER_LOSS_FCTY_EVENT',nvl(cmv.op_fcty_class_2_id, cmv.op_fcty_class_1_id),nvl(cmv.geo_field_id,cmv.geo_sub_field_id))
     ,e.choke_model_id
      ,decode(f.type,'BUDGET',EcDp_Unit.convertValue(ec_object_plan.volume_rate(e.object_id,s.daytime,'STRM_PLAN_BUDGET','<='),EcDp_Unit.GetUnitFromLogical(ecbp_defer_loss_accounting.getRateUom(e.object_id, s.daytime,'VOLUME')),EcDp_Unit.GetViewUnitFromLogical(ecbp_defer_loss_accounting.getRateUom(e.object_id, s.daytime,'VOLUME')),s.daytime),'POTENTIAL',ecbp_choke_model.calcTotalMppLip(e.choke_model_id,s.daytime,'CHOKE_MODEL_MPP'))
     ,decode(f.type,'BUDGET',EcDp_Unit.convertValue(ec_object_plan.mass_rate(e.object_id,s.daytime,'STRM_PLAN_BUDGET','<='),EcDp_Unit.GetUnitFromLogical(ecbp_defer_loss_accounting.getRateUom(e.object_id, s.daytime,'MASS')),EcDp_Unit.GetViewUnitFromLogical(ecbp_defer_loss_accounting.getRateUom(e.object_id, s.daytime,'MASS')),s.daytime),'POTENTIAL',ecbp_choke_model.calcTotalMppLip(e.choke_model_id,s.daytime,'CHOKE_MODEL_MPP'))
UNION
select  f.event_no event_no
      ,e.object_id object_id
      ,f.object_id parent_object_id
      ,s.daytime daytime
      ,null as type
      ,f.class_name class_name
      ,nvl(sv.op_fcty_class_2_id, sv.op_fcty_class_1_id) parent_id -- parent id is either the id of facility or field the choke model belongs to
      ,null choke_model_id
      ,ecbp_defer_loss_accounting.calcDailyVolLoss( f.object_id,e.object_id,null, s.daytime) net_vol_rate
      ,EcBp_Stream_Fluid.findNetStdVol(e.object_id, s.daytime) ACTUAL_NET_VOL_RATE
      ,null NET_MASS_RATE
      ,null ACTUAL_NET_MASS_RATE
      ,ecbp_defer_loss_accounting.getPlannedVol(e.object_id,s.daytime,'STRM_PLAN_BUDGET')FCST_NET_VOL_RATE
      ,null FCST_NET_MASS_RATE
      , EcBp_Stream_Fluid.findNetStdVol(e.object_id, s.daytime) - ecbp_defer_loss_accounting.getPlannedVol(e.object_id,s.daytime,'STRM_PLAN_BUDGET') BALANCE_VOL
     ,null BALANCE_MASS
     , EcBp_Stream_Fluid.findNetStdVol(e.object_id, s.daytime) -ecbp_defer_loss_accounting.getPlannedVol(e.object_id,s.daytime,'STRM_PLAN_BUDGET')- ecbp_defer_loss_accounting.calcDailyVolLoss( f.object_id,e.object_id,null, s.daytime) UNASSIGNED_LOSS_VOL
     ,NULL  UNASSIGNED_LOSS_MASS
     ,EcBp_Stream.getRateUom(e.object_id,e.daytime,'VOLUME') UOM
    ,TO_CHAR('P') RECORD_STATUS
    ,TO_CHAR(NULL) CREATED_BY
    ,TO_DATE(Null) CREATED_DATE
    ,TO_CHAR(NULL) LAST_UPDATED_BY
    ,TO_DATE(NULL) LAST_UPDATED_DATE
    ,TO_NUMBER(NULL) REV_NO
    ,TO_CHAR(NULL) REV_TEXT
    FROM
      system_days s,
      DEFER_LOSS_STRM_EVENT e,
      DEFER_LOSS_ACC_EVENT f,
      strm_version sv
      where
   e.daytime(+) = s.daytime
   and e.event_no = f.event_no
   and e.object_id  = sv.object_id
   and f.type is null
   and e.choke_model_id is null
   and sv.daytime <= s.daytime
   and nvl(sv.end_date, s.daytime+1) > s.daytime))
order by ec_choke_model_version.sort_order(choke_model_id, daytime,'<='), ecdp_objects.GetObjName(object_id,daytime)