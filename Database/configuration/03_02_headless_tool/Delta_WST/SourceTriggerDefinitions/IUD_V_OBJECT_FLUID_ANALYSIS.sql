CREATE OR REPLACE EDITIONABLE TRIGGER "IUD_V_OBJECT_FLUID_ANALYSIS" 
 INSTEAD OF INSERT OR UPDATE OR DELETE ON v_object_fluid_analysis
FOR EACH ROW
-- $Revision: 1.12 $
-- $Author: HAK
DECLARE
-- Variables for storing temporary values

BEGIN

-- INSERT BLOCK
IF INSERTING THEN

  INSERT INTO object_fluid_analysis (
      analysis_no,
      object_id,
      object_class_name,
      daytime,
      analysis_type,
      sampling_method,
      phase,
      valid_from_date,
      production_day,
      analysis_status,
      sample_press,
      sample_temp,
      density,
      gas_density,
      oil_density,
      gross_liq_density,
      density_obs,
      sp_grav,
      api,
      shrinkage_factor,
      solution_gor,
      bs_w,
      bs_w_wt,
      mol_wt,
      cnpl_mol_wt,
      cnpl_sp_grav,
      cnpl_density,
      mw_mix,
      sg_mix,
      sulfur_wt,
      gcv,
      gcv_flash,
      gcv_flash_press,
      gcv_press,
      ncv,
      gcr,
      cgr,
      wdp,
      rvp,
      h2s,
      co2,
      sand,
      salt,
      emulsion,
      emulsion_frac,
      emulsion_fact,
      scale_inhib,
      wax_content,
      critical_press,
      critical_temp,
      laboratory,
      lab_ref_no,
      sampled_by,
      sampled_date,
      oil_in_water,
      o2,
      chlorine,
      aluminium,
      barium,
      bicarbonate,
      boron,
      calcium,
      carbonate,
      chloride,
      hydroxide,
      iron,
      iron_total,
      lithium,
      magnesium,
      organic_acid,
      potassium,
      silicon,
      sodium,
      strontium,
      sulfate,
      phosphorus,
      cnpl_gcv,
      cnpl_api,
      vapour,
      salinity,
      flash_gas_factor,
      oil_in_water_content,
      butanoate,
      diss_solids,
      ethanoate,
      hexanoate,
      methanoate,
      pentanoate,
      ph,
      propionate,
      resistivity,
      sulfate_2,
      susp_solids,
      tot_alkalinity,
      sampling_point,
      fluid_state,
      check_unique,
      component_set,
      rel_density,
      wobbe_index,
      zmix,
      comments,
      value_1,
      value_2,
      value_3,
      value_4,
      value_5,
      value_6,
      value_7,
      value_8,
      value_9,
      value_10,
      value_11,
      value_12,
      value_13,
      value_14,
      value_15,
      value_16,
      value_17,
      value_18,
      value_19,
      value_20,
      value_21,
      value_22,
      value_23,
      value_24,
      value_25,
      value_26,
      value_27,
      value_28,
      value_29,
      value_30,
      value_31,
      value_32,
      value_33,
      value_34,
      value_35,
      value_36,
      value_37,
      value_38,
      value_39,
      value_40,
      value_41,
      value_42,
      value_43,
      value_44,
      value_45,
      value_46,
      value_47,
      text_1,
      text_2,
      text_3,
      text_4,
      text_5,
      text_6,
      text_7,
      text_8,
      text_9,
      text_10,
      text_11,
      text_12,
      text_13,
      text_14,
      text_15,
      text_16,
      text_17,
      text_18,
      text_19,
      text_20,
      text_21,
      text_22,
      text_23,
      text_24,
      text_25,
      text_26,
      text_27,
      text_28,
      text_29,
      text_30,
      text_31,
      text_32,
      text_33,
      text_34,
      text_35,
      text_36,
      text_37,
      text_38,
      text_39,
      text_40,
      text_41,
      text_42,
      date_1,
      date_2,
      date_3,
      date_4,
      date_5,
      date_6,
      date_7,
      date_8,
      date_9,
      date_10,
      date_11,
      record_status,
      created_by,
      created_date,
      last_updated_by,
      last_updated_date,
      rev_no,
      rev_text,
      approval_by,
      approval_date,
      approval_state,
      rec_id
  ) values (
      :NEW.analysis_no,
      :NEW.object_id,
      EcDp_Objects.getObjClassName(:New.object_id),
      :NEW.daytime,
      :NEW.analysis_type,
      :NEW.sampling_method,
      :NEW.phase,
      :NEW.valid_from_date,
      :NEW.production_day,
      :NEW.analysis_status,
      :NEW.sample_press,
      :NEW.sample_temp,
      :NEW.density,
      :NEW.gas_density,
      :NEW.oil_density,
      :NEW.gross_liq_density,
      :NEW.density_obs,
      :NEW.sp_grav,
      :NEW.api,
      :NEW.shrinkage_factor,
      :NEW.solution_gor,
      :NEW.bs_w,
      :NEW.bs_w_wt,
      :NEW.mol_wt,
      :NEW.cnpl_mol_wt,
      :NEW.cnpl_sp_grav,
      :NEW.cnpl_density,
      :NEW.mw_mix,
      :NEW.sg_mix,
      :NEW.sulfur_wt,
      :NEW.gcv,
      :NEW.gcv_flash,
      :NEW.gcv_flash_press,
      :NEW.gcv_press,
      :NEW.ncv,
      :NEW.gcr,
      :NEW.cgr,
      :NEW.wdp,
      :NEW.rvp,
      :NEW.h2s,
      :NEW.co2,
      :NEW.sand,
      :NEW.salt,
      :NEW.emulsion,
      :NEW.emulsion_frac,
      :NEW.emulsion_fact,
      :NEW.scale_inhib,
      :NEW.wax_content,
      :NEW.critical_press,
      :NEW.critical_temp,
      :NEW.laboratory,
      :NEW.lab_ref_no,
      :NEW.sampled_by,
      :NEW.sampled_date,
      :NEW.oil_in_water,
      :NEW.o2,
      :NEW.chlorine,
      :NEW.aluminium,
      :NEW.barium,
      :NEW.bicarbonate,
      :NEW.boron,
      :NEW.calcium,
      :NEW.carbonate,
      :NEW.chloride,
      :NEW.hydroxide,
      :NEW.iron,
      :NEW.iron_total,
      :NEW.lithium,
      :NEW.magnesium,
      :NEW.organic_acid,
      :NEW.potassium,
      :NEW.silicon,
      :NEW.sodium,
      :NEW.strontium,
      :NEW.sulfate,
      :NEW.phosphorus,
      :NEW.cnpl_gcv,
      :NEW.cnpl_api,
      :NEW.vapour,
      :NEW.salinity,
      :NEW.flash_gas_factor,
      :NEW.oil_in_water_content,
      :NEW.butanoate,
      :NEW.diss_solids,
      :NEW.ethanoate,
      :NEW.hexanoate,
      :NEW.methanoate,
      :NEW.pentanoate,
      :NEW.ph,
      :NEW.propionate,
      :NEW.resistivity,
      :NEW.sulfate_2,
      :NEW.susp_solids,
      :NEW.tot_alkalinity,
      :NEW.sampling_point,
      :NEW.fluid_state,
      :NEW.check_unique,
      Nvl(:NEW.component_set,Nvl(EcBp_Fluid_Analysis.getCompSet(:new.object_class_name, :new.object_id, :new.daytime,:new.analysis_type), :new.analysis_type)),
      :NEW.rel_density,
      :NEW.wobbe_index,
      :NEW.zmix,
      :NEW.comments,
      :NEW.value_1,
      :NEW.value_2,
      :NEW.value_3,
      :NEW.value_4,
      :NEW.value_5,
      :NEW.value_6,
      :NEW.value_7,
      :NEW.value_8,
      :NEW.value_9,
      :NEW.value_10,
      :NEW.value_11,
      :NEW.value_12,
      :NEW.value_13,
      :NEW.value_14,
      :NEW.value_15,
      :NEW.value_16,
      :NEW.value_17,
      :NEW.value_18,
      :NEW.value_19,
      :NEW.value_20,
      :NEW.value_21,
      :NEW.value_22,
      :NEW.value_23,
      :NEW.value_24,
      :NEW.value_25,
      :NEW.value_26,
      :NEW.value_27,
      :NEW.value_28,
      :NEW.value_29,
      :NEW.value_30,
      :NEW.value_31,
      :NEW.value_32,
      :NEW.value_33,
      :NEW.value_34,
      :NEW.value_35,
      :NEW.value_36,
      :NEW.value_37,
      :NEW.value_38,
      :NEW.value_39,
      :NEW.value_40,
      :NEW.value_41,
      :NEW.value_42,
      :NEW.value_43,
      :NEW.value_44,
      :NEW.value_45,
      :NEW.value_46,
      :NEW.value_47,
      :NEW.text_1,
      :NEW.text_2,
      :NEW.text_3,
      :NEW.text_4,
      :NEW.text_5,
      :NEW.text_6,
      :NEW.text_7,
      :NEW.text_8,
      :NEW.text_9,
      :NEW.text_10,
      :NEW.text_11,
      :NEW.text_12,
      :NEW.text_13,
      :NEW.text_14,
      :NEW.text_15,
      :NEW.text_16,
      :NEW.text_17,
      :NEW.text_18,
      :NEW.text_19,
      :NEW.text_20,
      :NEW.text_21,
      :NEW.text_22,
      :NEW.text_23,
      :NEW.text_24,
      :NEW.text_25,
      :NEW.text_26,
      :NEW.text_27,
      :NEW.text_28,
      :NEW.text_29,
      :NEW.text_30,
      :NEW.text_31,
      :NEW.text_32,
      :NEW.text_33,
      :NEW.text_34,
      :NEW.text_35,
      :NEW.text_36,
      :NEW.text_37,
      :NEW.text_38,
      :NEW.text_39,
      :NEW.text_40,
      :NEW.text_41,
      :NEW.text_42,
      :NEW.date_1,
      :NEW.date_2,
      :NEW.date_3,
      :NEW.date_4,
      :NEW.date_5,
      :NEW.date_6,
      :NEW.date_7,
      :NEW.date_8,
      :NEW.date_9,
      :NEW.date_10,
      :NEW.date_11,
      :NEW.record_status,
      :NEW.created_by,
      :NEW.created_date,
      :NEW.last_updated_by,
      :NEW.last_updated_date,
      :NEW.rev_no,
      :NEW.rev_text,
      :NEW.approval_by,
      :NEW.approval_date,
      :NEW.approval_state,
      :NEW.rec_id
  );

END IF;

-- UPDATE BLOCK
IF UPDATING THEN
  UPDATE object_fluid_analysis
     SET analysis_no            = :New.analysis_no,
      object_id                 = :NEW.object_id,
      object_class_name         = EcDp_Objects.getObjClassName(:New.object_id),
      daytime                   = :NEW.daytime,
      analysis_type             = :NEW.analysis_type,
      sampling_method           = :NEW.sampling_method,
      phase                     = :NEW.phase,
      valid_from_date           = :NEW.valid_from_date,
      production_day            = :NEW.production_day,
      analysis_status           = :NEW.analysis_status,
      sample_press              = :NEW.sample_press,
      sample_temp               = :NEW.sample_temp,
      density                   = :NEW.density,
      gas_density               = :NEW.gas_density,
      oil_density               = :NEW.oil_density,
      gross_liq_density         = :NEW.gross_liq_density,
      density_obs               = :NEW.density_obs,
      sp_grav                   = :NEW.sp_grav,
      api                       = :NEW.api,
      shrinkage_factor          = :NEW.shrinkage_factor,
      solution_gor              = :NEW.solution_gor,
      bs_w                      = :NEW.bs_w,
      bs_w_wt                   = :NEW.bs_w_wt,
      mol_wt                    = :NEW.mol_wt,
      cnpl_mol_wt               = :NEW.cnpl_mol_wt,
      cnpl_sp_grav              = :NEW.cnpl_sp_grav,
      cnpl_density              = :NEW.cnpl_density,
      mw_mix                    = :NEW.mw_mix,
      sg_mix                    = :NEW.sg_mix,
      sulfur_wt                 = :NEW.sulfur_wt,
      gcv                       = :NEW.gcv,
      gcv_flash                 = :NEW.gcv_flash,
      gcv_flash_press           = :NEW.gcv_flash_press,
      gcv_press                 = :NEW.gcv_press,
      ncv                       = :NEW.ncv,
      gcr                       = :NEW.gcr,
      cgr                   	= :NEW.cgr,
      wdp                       = :NEW.wdp,
      rvp                       = :NEW.rvp,
      h2s                       = :NEW.h2s,
      co2                       = :NEW.co2,
      sand                      = :NEW.sand,
      salt                      = :NEW.salt,
      emulsion                  = :NEW.emulsion,
      emulsion_frac             = :NEW.emulsion_frac,
      emulsion_fact             = :NEW.emulsion_fact,
      scale_inhib               = :NEW.scale_inhib,
      wax_content               = :NEW.wax_content,
      critical_press            = :NEW.critical_press,
      critical_temp             = :NEW.critical_temp,
      laboratory                = :NEW.laboratory,
      lab_ref_no                = :NEW.lab_ref_no,
      sampled_by                = :NEW.sampled_by,
      sampled_date              = :NEW.sampled_date,
      oil_in_water              = :NEW.oil_in_water,
      o2                        = :NEW.o2,
      chlorine                  = :NEW.chlorine,
      aluminium                 = :NEW.aluminium,
      barium                    = :NEW.barium,
      bicarbonate               = :NEW.bicarbonate,
      boron                     = :NEW.boron,
      calcium                   = :NEW.calcium,
      carbonate                 = :NEW.carbonate,
      chloride                  = :NEW.chloride,
      hydroxide                 = :NEW.hydroxide,
      iron                      = :NEW.iron,
      iron_total                = :NEW.iron_total,
      lithium                   = :NEW.lithium,
      magnesium                 = :NEW.magnesium,
      organic_acid              = :NEW.organic_acid,
      potassium                 = :NEW.potassium,
      silicon                   = :NEW.silicon,
      sodium                    = :NEW.sodium,
      strontium                 = :NEW.strontium,
      sulfate                   = :NEW.sulfate,
      phosphorus                = :NEW.phosphorus,
      cnpl_gcv                  = :NEW.cnpl_gcv,
      cnpl_api                  = :NEW.cnpl_api,
      vapour                    = :NEW.vapour,
      salinity                  = :NEW.salinity,
      flash_gas_factor          = :NEW.flash_gas_factor,
      oil_in_water_content      = :NEW.oil_in_water_content,
      butanoate                 = :NEW.butanoate,
      diss_solids               = :NEW.diss_solids,
      ethanoate                 = :NEW.ethanoate,
      hexanoate                 = :NEW.hexanoate,
      methanoate                = :NEW.methanoate,
      pentanoate                = :NEW.pentanoate,
      ph                        = :NEW.ph,
      propionate                = :NEW.propionate,
      resistivity               = :NEW.resistivity,
      sulfate_2                 = :NEW.sulfate_2,
      susp_solids               = :NEW.susp_solids,
      tot_alkalinity            = :NEW.tot_alkalinity,
      sampling_point            = :NEW.sampling_point,
      fluid_state               = :NEW.fluid_state,
      check_unique              = :NEW.check_unique,
      component_set             = Nvl(:NEW.component_set,Nvl(EcBp_Fluid_Analysis.getCompSet(:new.object_class_name, :new.object_id, :new.daytime,:new.analysis_type), :new.analysis_type)),
      rel_density               = :NEW.rel_density,
      wobbe_index               = :NEW.wobbe_index,
      zmix                      = :NEW.zmix,
      comments                  = :NEW.comments,
      value_1                   = :NEW.value_1,
      value_2                   = :NEW.value_2,
      value_3                   = :NEW.value_3,
      value_4                   = :NEW.value_4,
      value_5                   = :NEW.value_5,
      value_6                   = :NEW.value_6,
      value_7                   = :NEW.value_7,
      value_8                   = :NEW.value_8,
      value_9                   = :NEW.value_9,
      value_10                  = :NEW.value_10,
      value_11                  = :NEW.value_11,
      value_12                  = :NEW.value_12,
      value_13                  = :NEW.value_13,
      value_14                  = :NEW.value_14,
      value_15                  = :NEW.value_15,
      value_16                  = :NEW.value_16,
      value_17                  = :NEW.value_17,
      value_18                  = :NEW.value_18,
      value_19                  = :NEW.value_19,
      value_20                  = :NEW.value_20,
      value_21                  = :NEW.value_21,
      value_22                  = :NEW.value_22,
      value_23                  = :NEW.value_23,
      value_24                  = :NEW.value_24,
      value_25                  = :NEW.value_25,
      value_26                  = :NEW.value_26,
      value_27                  = :NEW.value_27,
      value_28                  = :NEW.value_28,
      value_29                  = :NEW.value_29,
      value_30                  = :NEW.value_30,
      value_31                  = :NEW.value_31,
      value_32                  = :NEW.value_32,
      value_33                  = :NEW.value_33,
      value_34                  = :NEW.value_34,
      value_35                  = :NEW.value_35,
      value_36                  = :NEW.value_36,
      value_37                  = :NEW.value_37,
      value_38                  = :NEW.value_38,
      value_39                  = :NEW.value_39,
      value_40                  = :NEW.value_40,
      value_41                  = :NEW.value_41,
      value_42                  = :NEW.value_42,
      value_43                  = :NEW.value_43,
      value_44                  = :NEW.value_44,
      value_45                  = :NEW.value_45,
      value_46                  = :NEW.value_46,
      value_47                  = :NEW.value_47,
      text_1                    = :NEW.text_1,
      text_2                    = :NEW.text_2,
      text_3                    = :NEW.text_3,
      text_4                    = :NEW.text_4,
      text_5                    = :NEW.text_5,
      text_6                    = :NEW.text_6,
      text_7                    = :NEW.text_7,
      text_8                    = :NEW.text_8,
      text_9                    = :NEW.text_9,
      text_10                   = :NEW.text_10,
      text_11                   = :NEW.text_11,
      text_12                   = :NEW.text_12,
      text_13                   = :NEW.text_13,
      text_14                   = :NEW.text_14,
      text_15                   = :NEW.text_15,
      text_16                   = :NEW.text_16,
      text_17                   = :NEW.text_17,
      text_18                   = :NEW.text_18,
      text_19                   = :NEW.text_19,
      text_20                   = :NEW.text_20,
      text_21                   = :NEW.text_21,
      text_22                   = :NEW.text_22,
      text_23                   = :NEW.text_23,
      text_24                   = :NEW.text_24,
      text_25                   = :NEW.text_25,
      text_26                   = :NEW.text_26,
      text_27                   = :NEW.text_27,
      text_28                   = :NEW.text_28,
      text_29                   = :NEW.text_29,
      text_30                   = :NEW.text_30,
      text_31                   = :NEW.text_31,
      text_32                   = :NEW.text_32,
      text_33                   = :NEW.text_33,
      text_34                   = :NEW.text_34,
      text_35                   = :NEW.text_35,
      text_36                   = :NEW.text_36,
      text_37                   = :NEW.text_37,
      text_38                   = :NEW.text_38,
      text_39                   = :NEW.text_39,
      text_40                   = :NEW.text_40,
      text_41                   = :NEW.text_41,
      text_42                   = :NEW.text_42,
      date_1                    = :NEW.date_1,
      date_2                    = :NEW.date_2,
      date_3                    = :NEW.date_3,
      date_4                    = :NEW.date_4,
      date_5                    = :NEW.date_5,
      date_6                    = :NEW.date_6,
      date_7                    = :NEW.date_7,
      date_8                    = :NEW.date_8,
      date_9                    = :NEW.date_9,
      date_10                   = :NEW.date_10,
      date_11                   = :NEW.date_11,
      record_status             = :NEW.record_status,
      created_by                = :NEW.created_by,
      created_date              = :NEW.created_date,
      last_updated_by           = :NEW.last_updated_by,
      last_updated_date         = :NEW.last_updated_date,
      rev_no                    = :NEW.rev_no,
      rev_text                  = :NEW.rev_text,
      approval_by               = :NEW.approval_by,
      approval_date             = :NEW.approval_date,
      approval_state            = :NEW.approval_state,
      rec_id                    = :NEW.rec_id
   WHERE analysis_no            = :Old.analysis_no  ;
END IF;

-- If inserting or updating, then generate values for new mapping
IF DELETING THEN
  DELETE FROM object_fluid_analysis
   WHERE analysis_no = :Old.analysis_no;
END IF;

END;

