CREATE OR REPLACE EDITIONABLE TRIGGER "AIU_STIM_MTH_REPORTED" 
  after insert or update of NET_ENERGY_JO, NET_ENERGY_TH, NET_ENERGY_WH, NET_ENERGY_BE, NET_MASS_MA, NET_MASS_MV
                          ,NET_MASS_UA, NET_MASS_UV, NET_VOLUME_SF, NET_VOLUME_NM, NET_VOLUME_SM, NET_VOLUME_BM, NET_VOLUME_BI
  on stim_mth_reported
declare

begin

    -- check that we have anything to update...
    IF EcTrgPck_stim_mth_reported.ptab IS NOT NULL THEN

      -- empty the table
      EcTrgPck_stim_mth_reported.ptab.DELETE;

   END IF;

end AIU_STIM_MTH_REPORTED;
