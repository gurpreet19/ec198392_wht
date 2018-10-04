CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CASCADING_MONTHLY_VALUES" ("OBJECT_ID", "OBJECT_CODE", "EQUATION", "CALC_METHOD", "MEASURE", "NETMASS", "NETMASSUNIT", "NETVOLUME", "NETVOLUMEUNIT", "NETENERGY", "NETENERGYUNIT", "NETEXTRA1", "EXTRA1UNIT", "EXTRA1UNITGROUP", "NETEXTRA2", "EXTRA2UNIT", "EXTRA2UNITGROUP", "NETEXTRA3", "EXTRA3UNIT", "EXTRA3UNITGROUP", "CONVERSION_METHOD", "SPLITSHARE", "DAYTIME", "STATUS", "RECORD_STATUS", "SPLIT_TYPE", "DENSITY", "DENSITY_MASS_UOM", "DENSITY_VOLUME_UOM", "GCV", "GCV_ENERGY_UOM", "GCV_VOLUME_UOM", "MCV", "MCV_ENERGY_UOM", "MCV_MASS_UOM", "BOE_FROM_UOM_CODE", "BOE_TO_UOM_CODE", "BOE_FACTOR", "DENSITY_SOURCE_ID", "GCV_SOURCE_ID", "MCV_SOURCE_ID", "BOE_SOURCE_ID", "SET_TO_ZERO_METHOD", "LAST_UPDATED_BY") AS 
  SELECT smv.object_id object_id
        ,si.object_code object_code
        ,ec_stream_item_version.stream_item_formula(smv.object_id
                                                   ,smv.daytime
                                                   ,'<=') Equation
        ,nvl(smv.calc_method
            ,ec_stream_item_version.calc_method(smv.object_id
                                               ,smv.daytime
                                               ,'<=')) calc_method
        ,ec_stream_item_version.MASTER_UOM_GROUP(smv.object_id
                                                ,smv.daytime
                                                ,'<=') Measure
        ,smv.net_mass_value NetMass
        ,smv.mass_uom_code NetMassUnit
        ,smv.net_volume_value NetVolume
        ,smv.volume_uom_code NetVolumeUnit
        ,smv.net_energy_value NetEnergy
        ,smv.energy_uom_code NetEnergyUnit
        ,smv.net_extra1_value NetExtra1
        ,smv.extra1_uom_code Extra1Unit
        ,EcDp_Unit.GetUOMGroup(smv.extra1_uom_code) Extra1UnitGroup
        ,smv.net_extra2_value NetExtra2
        ,smv.extra2_uom_code Extra2Unit
        ,EcDp_Unit.GetUOMGroup(smv.extra2_uom_code) Extra2UnitGroup
        ,smv.net_extra3_value NetExtra3
        ,smv.extra3_uom_code Extra3Unit
        ,EcDp_Unit.GetUOMGroup(smv.extra3_uom_code) Extra3UnitGroup
        ,ec_stream_item_version.conversion_method(smv.object_id
                                                 ,smv.daytime
                                                 ,'<=') conversion_method
        ,decode(nvl(smv.calc_method
                   ,ec_stream_item_version.calc_method(smv.object_id
                                                      ,smv.daytime
                                                      ,'<='))
               ,'SK'
               ,ecdp_stream_item.GetSplitShareMth(smv.object_id
                                                 ,smv.daytime)
               ,smv.split_share) SplitShare
        ,smv.daytime daytime
        ,smv.status status
        ,smv.record_status record_status
        ,ec_split_key_version.split_type(ec_stream_item_version.split_key_id(smv.object_id
                                                                            ,smv.daytime
                                                                            ,'<=')
                                        ,smv.daytime
                                        ,'<=') split_type
        ,ecdp_stream_item.getConversionFactorValue(smv.object_id
                                                  ,smv.density_source_id
                                                  ,smv.daytime
                                                  ,'DENSITY'
                                                  ,smv.density) density
        ,decode(smv.density_source_id
               ,NULL
               ,smv.density_mass_uom
               ,ecdp_stream_item.getConversionFactorUOM(smv.object_id
                                                       ,smv.density_source_id
                                                       ,smv.daytime
                                                       ,'DENSITY'
                                                       ,smv.density
                                                       ,'TO_UOM')) density_mass_uom
        ,decode(smv.density_source_id
               ,NULL
               ,smv.density_volume_uom
               ,ecdp_stream_item.getConversionFactorUOM(smv.object_id
                                                       ,smv.density_source_id
                                                       ,smv.daytime
                                                       ,'DENSITY'
                                                       ,smv.density
                                                       ,'FROM_UOM')) density_volume_uom
        ,ecdp_stream_item.getConversionFactorValue(smv.object_id
                                                  ,smv.gcv_source_id
                                                  ,smv.daytime
                                                  ,'GCV'
                                                  ,smv.gcv) gcv
        ,decode(smv.gcv_source_id
               ,NULL
               ,smv.gcv_energy_uom
               ,ecdp_stream_item.getConversionFactorUOM(smv.object_id
                                                       ,smv.gcv_source_id
                                                       ,smv.daytime
                                                       ,'GCV'
                                                       ,smv.gcv
                                                       ,'TO_UOM')) gcv_energy_uom
        ,decode(smv.gcv_source_id
               ,NULL
               ,smv.gcv_volume_uom
               ,ecdp_stream_item.getConversionFactorUOM(smv.object_id
                                                       ,smv.gcv_source_id
                                                       ,smv.daytime
                                                       ,'GCV'
                                                       ,smv.gcv
                                                       ,'FROM_UOM')) gcv_volume_uom
        ,ecdp_stream_item.getConversionFactorValue(smv.object_id
                                                  ,smv.mcv_source_id
                                                  ,smv.daytime
                                                  ,'MCV'
                                                  ,smv.mcv) mcv
        ,decode(smv.mcv_source_id
               ,NULL
               ,smv.mcv_energy_uom
               ,ecdp_stream_item.getConversionFactorUOM(smv.object_id
                                                       ,smv.mcv_source_id
                                                       ,smv.daytime
                                                       ,'MCV'
                                                       ,smv.mcv
                                                       ,'TO_UOM')) mcv_energy_uom
        ,decode(smv.mcv_source_id
               ,NULL
               ,smv.mcv_mass_uom
               ,ecdp_stream_item.getConversionFactorUOM(smv.object_id
                                                       ,smv.mcv_source_id
                                                       ,smv.daytime
                                                       ,'MCV'
                                                       ,smv.mcv
                                                       ,'FROM_UOM')) mcv_mass_uom
        ,decode(smv.boe_source_id
               ,NULL
               ,smv.boe_from_uom_code
               ,ecdp_stream_item.getConversionFactorUOM(smv.object_id
                                                       ,smv.boe_source_id
                                                       ,smv.daytime
                                                       ,'BOE'
                                                       ,smv.boe_factor
                                                       ,'FROM_UOM')) boe_from_uom_code
        ,decode(smv.boe_source_id
               ,NULL
               ,smv.boe_to_uom_code
               ,ecdp_stream_item.getConversionFactorUOM(smv.object_id
                                                       ,smv.boe_source_id
                                                       ,smv.daytime
                                                       ,'BOE'
                                                       ,smv.boe_factor
                                                       ,'TO_UOM')) boe_to_uom_code
        ,ecdp_stream_item.getConversionFactorValue(smv.object_id
                                                  ,smv.boe_source_id
                                                  ,smv.daytime
                                                  ,'BOE'
                                                  ,smv.boe_factor) boe_factor
        ,smv.density_source_id
        ,smv.gcv_source_id
        ,smv.mcv_source_id
        ,smv.boe_source_id
        ,ec_stream_item_version.set_to_zero_method_mth(smv.object_id
                                                      ,smv.daytime
                                                      ,'<=') set_to_zero_method
        ,smv.last_updated_by
    FROM stim_mth_value smv, stream_item si
    where smv.object_id = si.object_id