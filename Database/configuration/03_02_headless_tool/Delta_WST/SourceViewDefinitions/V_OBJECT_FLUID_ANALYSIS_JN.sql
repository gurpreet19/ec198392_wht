CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_OBJECT_FLUID_ANALYSIS_JN" ("JN_OPERATION", "JN_ORACLE_USER", "JN_DATETIME", "JN_NOTES", "JN_APPLN", "JN_SESSION", "ANALYSIS_NO", "OBJECT_ID", "OBJECT_CLASS_NAME", "DAYTIME", "ANALYSIS_TYPE", "SAMPLING_METHOD", "PHASE", "VALID_FROM_DATE", "PRODUCTION_DAY", "ANALYSIS_STATUS", "SAMPLE_PRESS", "SAMPLE_TEMP", "DENSITY", "GAS_DENSITY", "OIL_DENSITY", "GROSS_LIQ_DENSITY", "DENSITY_OBS", "SP_GRAV", "API", "SHRINKAGE_FACTOR", "SOLUTION_GOR", "BS_W", "BS_W_WT", "MOL_WT", "CNPL_MOL_WT", "CNPL_SP_GRAV", "CNPL_DENSITY", "MW_MIX", "SG_MIX", "SULFUR_WT", "GCV", "GCV_FLASH", "GCV_FLASH_PRESS", "GCV_PRESS", "NCV", "GCR", "CGR", "WDP", "RVP", "H2S", "CO2", "SAND", "SALT", "EMULSION", "EMULSION_FRAC", "EMULSION_FACT", "SCALE_INHIB", "WAX_CONTENT", "CRITICAL_PRESS", "CRITICAL_TEMP", "LABORATORY", "LAB_REF_NO", "SAMPLED_BY", "SAMPLED_DATE", "OIL_IN_WATER", "O2", "CHLORINE", "ALUMINIUM", "BARIUM", "BICARBONATE", "BORON", "CALCIUM", "CARBONATE", "CHLORIDE", "HYDROXIDE", "IRON", "IRON_TOTAL", "LITHIUM", "MAGNESIUM", "ORGANIC_ACID", "POTASSIUM", "SILICON", "SODIUM", "STRONTIUM", "SULFATE", "PHOSPHORUS", "CNPL_GCV", "CNPL_API", "VAPOUR", "SALINITY", "FLASH_GAS_FACTOR", "OIL_IN_WATER_CONTENT", "BUTANOATE", "DISS_SOLIDS", "ETHANOATE", "HEXANOATE", "METHANOATE", "PENTANOATE", "PH", "PROPIONATE", "RESISTIVITY", "SULFATE_2", "SUSP_SOLIDS", "TOT_ALKALINITY", "SAMPLING_POINT", "FLUID_STATE", "CHECK_UNIQUE", "COMPONENT_SET", "REL_DENSITY", "WOBBE_INDEX", "ZMIX", "COMMENTS", "VALUE_1", "VALUE_2", "VALUE_3", "VALUE_4", "VALUE_5", "VALUE_6", "VALUE_7", "VALUE_8", "VALUE_9", "VALUE_10", "VALUE_11", "VALUE_12", "VALUE_13", "VALUE_14", "VALUE_15", "VALUE_16", "VALUE_17", "VALUE_18", "VALUE_19", "VALUE_20", "VALUE_21", "VALUE_22", "VALUE_23", "VALUE_24", "VALUE_25", "VALUE_26", "VALUE_27", "VALUE_28", "VALUE_29", "VALUE_30", "VALUE_31", "VALUE_32", "VALUE_33", "VALUE_34", "VALUE_35", "VALUE_36", "VALUE_37", "VALUE_38", "VALUE_39", "VALUE_40", "VALUE_41", "VALUE_42", "VALUE_43", "VALUE_44", "VALUE_45", "VALUE_46", "VALUE_47", "TEXT_1", "TEXT_2", "TEXT_3", "TEXT_4", "TEXT_5", "TEXT_6", "TEXT_7", "TEXT_8", "TEXT_9", "TEXT_10", "TEXT_11", "TEXT_12", "TEXT_13", "TEXT_14", "TEXT_15", "TEXT_16", "TEXT_17", "TEXT_18", "TEXT_19", "TEXT_20", "TEXT_21", "TEXT_22", "TEXT_23", "TEXT_24", "TEXT_25", "TEXT_26", "TEXT_27", "TEXT_28", "TEXT_29", "TEXT_30", "TEXT_31", "TEXT_32", "TEXT_33", "TEXT_34", "TEXT_35", "TEXT_36", "TEXT_37", "TEXT_38", "TEXT_39", "TEXT_40", "TEXT_41", "TEXT_42", "DATE_1", "DATE_2", "DATE_3", "DATE_4", "DATE_5", "DATE_6", "DATE_7", "DATE_8", "DATE_9", "DATE_10", "DATE_11", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_BY", "APPROVAL_DATE", "APPROVAL_STATE", "REC_ID") AS 
  (
SELECT JN_OPERATION,
      JN_ORACLE_USER,
      JN_DATETIME,
      JN_NOTES,
      JN_APPLN,
      JN_SESSION,
      ANALYSIS_NO,
      OBJECT_ID,
      OBJECT_CLASS_NAME,
      DAYTIME,
      ANALYSIS_TYPE,
      SAMPLING_METHOD,
      PHASE,
      VALID_FROM_DATE,
      PRODUCTION_DAY,
      ANALYSIS_STATUS,
      SAMPLE_PRESS,
      SAMPLE_TEMP,
      DENSITY,
      GAS_DENSITY,
      OIL_DENSITY,
      GROSS_LIQ_DENSITY,
      DENSITY_OBS,
      SP_GRAV,
      API,
      SHRINKAGE_FACTOR,
      SOLUTION_GOR,
      BS_W,
      BS_W_WT,
      MOL_WT,
      CNPL_MOL_WT,
      CNPL_SP_GRAV,
      CNPL_DENSITY,
      MW_MIX,
      SG_MIX,
      SULFUR_WT,
      GCV,
      GCV_FLASH,
      GCV_FLASH_PRESS,
      GCV_PRESS,
      NCV,
      GCR,
	  CGR,
      WDP,
      RVP,
      H2S,
      CO2,
      SAND,
      SALT,
      EMULSION,
      EMULSION_FRAC,
      EMULSION_FACT,
      SCALE_INHIB,
      WAX_CONTENT,
      CRITICAL_PRESS,
      CRITICAL_TEMP,
      LABORATORY,
      LAB_REF_NO,
      SAMPLED_BY,
      SAMPLED_DATE,
      OIL_IN_WATER,
      O2,
      CHLORINE,
      ALUMINIUM,
      BARIUM,
      BICARBONATE,
      BORON,
      CALCIUM,
      CARBONATE,
      CHLORIDE,
      HYDROXIDE,
      IRON,
      IRON_TOTAL,
      LITHIUM,
      MAGNESIUM,
      ORGANIC_ACID,
      POTASSIUM,
      SILICON,
      SODIUM,
      STRONTIUM,
      SULFATE,
      PHOSPHORUS,
      CNPL_GCV,
      CNPL_API,
      VAPOUR,
      SALINITY,
      FLASH_GAS_FACTOR,
      OIL_IN_WATER_CONTENT,
      BUTANOATE,
      DISS_SOLIDS,
      ETHANOATE,
      HEXANOATE,
      METHANOATE,
      PENTANOATE,
      PH,
      PROPIONATE,
      RESISTIVITY,
      SULFATE_2,
      SUSP_SOLIDS,
      TOT_ALKALINITY,
      SAMPLING_POINT,
      FLUID_STATE,
      CHECK_UNIQUE,
      COMPONENT_SET,
      REL_DENSITY,
      WOBBE_INDEX,
      ZMIX,
      COMMENTS,
      VALUE_1,
      VALUE_2,
      VALUE_3,
      VALUE_4,
      VALUE_5,
      VALUE_6,
      VALUE_7,
      VALUE_8,
      VALUE_9,
      VALUE_10,
      VALUE_11,
      VALUE_12,
      VALUE_13,
      VALUE_14,
      VALUE_15,
      VALUE_16,
      VALUE_17,
      VALUE_18,
      VALUE_19,
      VALUE_20,
      VALUE_21,
      VALUE_22,
      VALUE_23,
      VALUE_24,
      VALUE_25,
      VALUE_26,
      VALUE_27,
      VALUE_28,
      VALUE_29,
      VALUE_30,
      VALUE_31,
      VALUE_32,
      VALUE_33,
      VALUE_34,
      VALUE_35,
      VALUE_36,
      VALUE_37,
      VALUE_38,
      VALUE_39,
      VALUE_40,
      VALUE_41,
      VALUE_42,
      VALUE_43,
      VALUE_44,
      VALUE_45,
      VALUE_46,
      VALUE_47,
      TEXT_1,
      TEXT_2,
      TEXT_3,
      TEXT_4,
      TEXT_5,
      TEXT_6,
      TEXT_7,
      TEXT_8,
      TEXT_9,
      TEXT_10,
      TEXT_11,
      TEXT_12,
      TEXT_13,
      TEXT_14,
      TEXT_15,
      TEXT_16,
      TEXT_17,
      TEXT_18,
      TEXT_19,
      TEXT_20,
      TEXT_21,
      TEXT_22,
      TEXT_23,
      TEXT_24,
      TEXT_25,
      TEXT_26,
      TEXT_27,
      TEXT_28,
      TEXT_29,
      TEXT_30,
      TEXT_31,
      TEXT_32,
      TEXT_33,
      TEXT_34,
      TEXT_35,
      TEXT_36,
      TEXT_37,
      TEXT_38,
      TEXT_39,
      TEXT_40,
      TEXT_41,
      TEXT_42,
      DATE_1,
      DATE_2,
      DATE_3,
      DATE_4,
      DATE_5,
      DATE_6,
      DATE_7,
      DATE_8,
      DATE_9,
      DATE_10,
      DATE_11,
      RECORD_STATUS,
      CREATED_BY,
      CREATED_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATED_DATE,
      REV_NO,
      REV_TEXT,
      APPROVAL_BY,
      APPROVAL_DATE,
      APPROVAL_STATE,
      REC_ID
FROM OBJECT_FLUID_ANALYSIS_JN
)