CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CASCADING_DAILY_VALUES" ("OBJECT_ID", "OBJECT_CODE", "EQUATION", "CALC_METHOD", "MEASURE", "NETMASS", "NETMASSUNIT", "NETVOLUME", "NETVOLUMEUNIT", "NETENERGY", "NETENERGYUNIT", "NETEXTRA1", "EXTRA1UNIT", "EXTRA1UNITGROUP", "NETEXTRA2", "EXTRA2UNIT", "EXTRA2UNITGROUP", "NETEXTRA3", "EXTRA3UNIT", "EXTRA3UNITGROUP", "CONVERSION_METHOD", "SPLITSHARE", "DAYTIME", "STATUS", "RECORD_STATUS", "SPLIT_TYPE", "DENSITY", "DENSITY_MASS_UOM", "DENSITY_VOLUME_UOM", "GCV", "GCV_ENERGY_UOM", "GCV_VOLUME_UOM", "MCV", "MCV_ENERGY_UOM", "MCV_MASS_UOM", "BOE_FROM_UOM_CODE", "BOE_TO_UOM_CODE", "BOE_FACTOR", "DENSITY_SOURCE_ID", "GCV_SOURCE_ID", "MCV_SOURCE_ID", "BOE_SOURCE_ID", "SET_TO_ZERO_METHOD", "LAST_UPDATED_BY") AS 
  SELECT sdv.object_id object_id
          ,si.object_code object_code
          ,ec_stream_item_version.stream_item_formula(sdv.object_id
                                                     ,sdv.daytime
                                                     ,'<=') equation
          ,nvl(sdv.calc_method
              ,ec_stream_item_version.calc_method(sdv.object_id
                                                 ,sdv.daytime
                                                 ,'<=')) calc_method
          ,ec_stream_item_version.MASTER_UOM_GROUP(sdv.object_id
                                                  ,sdv.daytime
                                                  ,'<=') measure
          ,sdv.net_mass_value NetMass
          ,sdv.mass_uom_code NetMassUnit
          ,sdv.net_volume_value NetVolume
          ,sdv.volume_uom_code NetVolumeUnit
          ,sdv.net_energy_value NetEnergy
          ,sdv.energy_uom_code NetEnergyUnit
          ,sdv.net_extra1_value NetExtra1
          ,sdv.extra1_uom_code Extra1Unit
          ,EcDp_Unit.GetUOMGroup(sdv.extra1_uom_code) Extra1UnitGroup
          ,sdv.net_extra2_value NetExtra2
          ,sdv.extra2_uom_code Extra2Unit
          ,EcDp_Unit.GetUOMGroup(sdv.extra2_uom_code) Extra2UnitGroup
          ,sdv.net_extra3_value NetExtra3
          ,sdv.extra3_uom_code Extra3Unit
          ,EcDp_Unit.GetUOMGroup(sdv.extra3_uom_code) Extra3UnitGroup
          ,ec_stream_item_version.conversion_method(sdv.object_id
                                                   ,sdv.daytime
                                                   ,'<=') conversion_method
          ,decode(nvl(sdv.calc_method
                     ,ec_stream_item_version.calc_method(sdv.object_id
                                                        ,sdv.daytime
                                                        ,'<='))
                 ,'SK'
                 ,ecdp_stream_item.GetSplitShareDay(sdv.object_id, sdv.daytime)
                 ,sdv.split_share) SplitShare
          ,sdv.daytime daytime
          ,sdv.status status
          ,sdv.record_status record_status
          ,ec_split_key_version.split_type(ec_stream_item_version.split_key_id(sdv.object_id
                                                                              ,sdv.daytime
                                                                              ,'<=')
                                          ,sdv.daytime
                                          ,'<=') split_type
          ,ecdp_stream_item.getConversionFactorValue(sdv.object_id
                                                    ,sdv.density_source_id
                                                    ,sdv.daytime
                                                    ,'DENSITY'
                                                    ,sdv.density) density
          ,decode(sdv.density_source_id
                 ,NULL
                 ,sdv.density_mass_uom
                 ,ecdp_stream_item.getConversionFactorUOM(sdv.object_id
                                                         ,sdv.density_source_id
                                                         ,sdv.daytime
                                                         ,'DENSITY'
                                                         ,sdv.density
                                                         ,'TO_UOM')) density_mass_uom
          ,decode(sdv.density_source_id
                 ,NULL
                 ,sdv.density_volume_uom
                 ,ecdp_stream_item.getConversionFactorUOM(sdv.object_id
                                                         ,sdv.density_source_id
                                                         ,sdv.daytime
                                                         ,'DENSITY'
                                                         ,sdv.density
                                                         ,'FROM_UOM')) density_volume_uom
          ,ecdp_stream_item.getConversionFactorValue(sdv.object_id
                                                    ,sdv.gcv_source_id
                                                    ,sdv.daytime
                                                    ,'GCV'
                                                    ,sdv.gcv) gcv
          ,decode(sdv.gcv_source_id
                 ,NULL
                 ,sdv.gcv_energy_uom
                 ,ecdp_stream_item.getConversionFactorUOM(sdv.object_id
                                                         ,sdv.gcv_source_id
                                                         ,sdv.daytime
                                                         ,'GCV'
                                                         ,sdv.gcv
                                                         ,'TO_UOM')) gcv_energy_uom
          ,decode(sdv.gcv_source_id
                 ,NULL
                 ,sdv.gcv_volume_uom
                 ,ecdp_stream_item.getConversionFactorUOM(sdv.object_id
                                                         ,sdv.gcv_source_id
                                                         ,sdv.daytime
                                                         ,'GCV'
                                                         ,sdv.gcv
                                                         ,'FROM_UOM')) gcv_volume_uom
          ,ecdp_stream_item.getConversionFactorValue(sdv.object_id
                                                    ,sdv.mcv_source_id
                                                    ,sdv.daytime
                                                    ,'MCV'
                                                    ,sdv.mcv) mcv
          ,decode(sdv.mcv_source_id
                 ,NULL
                 ,sdv.mcv_energy_uom
                 ,ecdp_stream_item.getConversionFactorUOM(sdv.object_id
                                                         ,sdv.mcv_source_id
                                                         ,sdv.daytime
                                                         ,'MCV'
                                                         ,sdv.mcv
                                                         ,'TO_UOM')) mcv_energy_uom
          ,decode(sdv.mcv_source_id
                 ,NULL
                 ,sdv.mcv_mass_uom
                 ,ecdp_stream_item.getConversionFactorUOM(sdv.object_id
                                                         ,sdv.mcv_source_id
                                                         ,sdv.daytime
                                                         ,'MCV'
                                                         ,sdv.mcv
                                                         ,'FROM_UOM')) mcv_mass_uom
          ,decode(sdv.boe_source_id
                 ,NULL
                 ,sdv.boe_from_uom_code
                 ,ecdp_stream_item.getConversionFactorUOM(sdv.object_id
                                                         ,sdv.boe_source_id
                                                         ,sdv.daytime
                                                         ,'BOE'
                                                         ,sdv.boe_factor
                                                         ,'FROM_UOM')) boe_from_uom_code
          ,decode(sdv.boe_source_id
                 ,NULL
                 ,sdv.boe_to_uom_code
                 ,ecdp_stream_item.getConversionFactorUOM(sdv.object_id
                                                         ,sdv.boe_source_id
                                                         ,sdv.daytime
                                                         ,'BOE'
                                                         ,sdv.boe_factor
                                                         ,'TO_UOM')) boe_to_uom_code
          ,ecdp_stream_item.getConversionFactorValue(sdv.object_id
                                                    ,sdv.boe_source_id
                                                    ,sdv.daytime
                                                    ,'BOE'
                                                    ,sdv.boe_factor) boe_factor
          ,sdv.density_source_id
          ,sdv.gcv_source_id
          ,sdv.mcv_source_id
          ,sdv.boe_source_id
          ,ec_stream_item_version.set_to_zero_method_day(sdv.object_id
                                                        ,sdv.daytime
                                                        ,'<=') set_to_zero_method
          ,sdv.last_updated_by
    FROM stim_day_value sdv, stream_item si
    where sdv.object_id = si.object_id