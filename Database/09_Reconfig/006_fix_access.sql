delete
from   t_basis_access m
where  exists ( select 'X'
                from   ( select role_id, app_id, object_id, class_name, level_id from t_basis_access
                         minus
                         select role_id, app_id, object_id, class_name, max(level_id) from t_basis_access group by role_id, app_id, object_id, class_name
                       ) s
                where  m.role_id             = s.role_id
                and    m.app_id              = s.app_id
                and    m.object_id           = s.object_id
                and    nvl(m.class_name,'X') = nvl(s.class_name,'X')
                and    m.level_id            = s.level_id
              );

delete
from   pre_upg_t_basis_access m
where  exists ( select 'X'
                from   ( select role_id, app_id, object_id, class_name, level_id from pre_upg_t_basis_access
                         minus
                         select role_id, app_id, object_id, class_name, max(level_id) from pre_upg_t_basis_access group by role_id, app_id, object_id, class_name
                       ) s
                where  m.role_id             = s.role_id
                and    m.app_id              = s.app_id
                and    m.object_id           = s.object_id
                and    nvl(m.class_name,'X') = nvl(s.class_name,'X')
                and    m.level_id            = s.level_id
              );

commit;
			  
declare 

  cursor c_changes is
    select old.object_id object_id_old
    ,      new.object_id object_id_new
    from   pre_upg_t_basis_object old
    ,      t_basis_object         new
    where  new.object_name = decode( old.object_name
                                   ,'/com.ec.prod.po.screens/daily_oil_stream_status_1', '/com.ec.prod.po.screens/daily_stream_status/CLASS_NAME/STRM_DAY_STREAM_MEAS_OIL/CLASS_NAME_DETAIL/STRM_DAY_STREAM_DER_OIL'
								   ,'/com.ec.prod.po.screens/daily_gas_stream_status_1','/com.ec.prod.po.screens/daily_stream_status/CLASS_NAME/STRM_DAY_STREAM_MEAS_GAS/CLASS_NAME_DETAIL/STRM_DAY_STREAM_DER_GAS'
								   ,'/com.ec.prod.po.screens/daily_water_stream_status','/com.ec.prod.po.screens/daily_stream_status/CLASS_NAME/STRM_DAY_STREAM_MEAS_WAT/CLASS_NAME_DETAIL/STRM_DAY_STREAM_DER_WAT'
								   ,'/com.ec.prod.wr.screens/well_oil_component_analysis','/com.ec.prod.wr.screens/well_oil_component_analysis/COMP_SET/WELL_OIL_COMP'
								   ,'/com.ec.prod.wr.screens/well_gas_component_analysis','/com.ec.prod.wr.screens/well_gas_component_analysis/COMP_SET/WELL_GAS_COMP'
								   ,'/user/changepassword','/com.ec.frmw.co.screens/changepassword','/com.ec.frmw.co.screens/manage_object/CLASS_NAME/FUNCTIONAL_AREA','/com.ec.frmw.co.screens/manage_object_nav/CLASS_NAME/FUNCTIONAL_AREA'
								   ,'/com.ec.frmw.co.screens/manage_object/CLASS_NAME/COMPANY','/com.ec.frmw.co.screens/manage_object_nav/CLASS_NAME/COMPANY'
								   ,'/com.ec.prod.co.screens/stream_pt_conversion','/com.ec.prod.co.screens/stream_pt_conversion/CLASS_NAME/STRM_PT_CONVERSION'
								   ,'/com.ec.prod.co.netscreens/stream_node_diagram','/com.ec.prod.co.screens.snd/stream_node_diagram/OBJ_CLASS/ALLOC_NETWORK/DATA_CLASS/ALLOC_NETWORK_LIST'
								   ,'/com.ec.frmw.co.screens/manage_object_groupmodel_nav/GROUPMODEL/WELL/TARGET/WELL/CLASS_NAME/WELL','/com.ec.prod.co.screens/manage_object_groupmodel_nav/GROUPMODEL/WELL/TARGET/WELL/CLASS_NAME/WELL'
								   ,'/com.ec.frmw.co.screens/manage_object/CLASS_NAME/PRODUCTIONUNIT','/com.ec.frmw.co.screens/manage_object_nav/CLASS_NAME/PRODUCTIONUNIT'
								   ,'/com.ec.frmw.co.screens/manage_object/CLASS_NAME/CHEM_PRODUCT','/com.ec.frmw.co.screens/manage_object_nav/CLASS_NAME/CHEM_PRODUCT'
								   ,'/com.ec.frmw.co.screens/manage_object/CLASS_NAME/LICENCE','/com.ec.frmw.co.screens/manage_object_nav/CLASS_NAME/LICENCE'
								   ,'/com.ec.frmw.co.screens/manage_table/CLASS_NAME/HYDROCARBON_COMPONENT','/com.ec.prod.co.screens/hydrocarbon_component'
								   ,'/com.ec.frmw.co.screens/manage_object/CLASS_NAME/PRODUCT','/com.ec.frmw.co.screens/manage_object_nav/CLASS_NAME/PRODUCT'
								   ,'/com.ec.frmw.co.screens/manage_object_groupmodel_nav/GROUPMODEL/STREAM/TARGET/STREAM/CLASS_NAME/STREAM','/com.ec.prod.co.screens/manage_object_groupmodel_nav/GROUPMODEL/STREAM/TARGET/STREAM/CLASS_NAME/STREAM'
								   ,'/com.ec.frmw.co.screens/manage_object/CLASS_NAME/ALLOC_NETWORK','/com.ec.frmw.co.screens/manage_object_nav/CLASS_NAME/ALLOC_NETWORK'
								   ,'/com.ec.frmw.co.screens/manage_object/CLASS_NAME/PIPELINE','/com.ec.frmw.co.screens/manage_object_groupmodel_nav/GROUPMODEL/PIPELINE/TARGET/PIPELINE/CLASS_NAME/PIPELINE'
								   ,'/com.ec.frmw.co.screens/manage_object/CLASS_NAME/ORIFICE_PLATE','/com.ec.frmw.co.screens/manage_object_nav/CLASS_NAME/ORIFICE_PLATE'
								   ,'/com.ec.frmw.co.screens/manage_object/CLASS_NAME/METER_RUN','/com.ec.frmw.co.screens/manage_object_nav/CLASS_NAME/METER_RUN'
								   ,'/com.ec.prod.wr.screens/well_bore_pressure_test','/com.ec.prod.wr.screens/webo_pressure_test'
								   ,'/com.ec.frmw.co.screens/maintain_class_attribute','/com.ec.frmw.co.screens/maintain_class_attr_property'
								   ,'/com.ec.frmw.co.screens/create_and_maintain_class','/com.ec.frmw.co.screens/class_configuration'
								   ,'/com.ec.frmw.co.screens/maintain_class_relation','/com.ec.frmw.co.screens/maintain_class_rel_property'
								   ,'/com.ec.prod.pd.screens/well_downtime','/com.ec.prod.pd.screens/well_deferment'
								   ,'/com.ec.prod.pd.screens/well_downtime/moveToGroupBtn','/com.ec.prod.pd.screens/well_deferment/moveToGroup'
								   ,'/com.ec.prod.pd.screens/well_downtime/addToGroupBtn','/com.ec.prod.pd.screens/well_deferment/addToGroup'
								   ,'/com.ec.prod.pd.screens/well_downtime/allocate_button','/com.ec.prod.pd.screens/well_deferment/allocate_button'
								   ,'/com.ec.prod.pd.screens/well_downtime/sum_button','/com.ec.prod.pd.screens/well_deferment/sum_button'
								   ,'/com.ec.prod.pd.screens/well_downtime/verify_button','/com.ec.prod.pd.screens/well_deferment/verify_button'
								   ,'/com.ec.prod.pd.screens/well_downtime/approve_button','/com.ec.prod.pd.screens/well_deferment/approve_button'
								   ,'/com.ec.prod.pd.screens/well_downtime/new_masterEvent_button','/com.ec.prod.pd.screens/well_deferment/new_masterEvent_button'
								   ,'/com.ec.prod.pd.screens/well_downtime/removeFromGroupBtn','/com.ec.prod.pd.screens/well_deferment/removeFromGroup'
								   ,'/com.ec.prod.pd.screens/well_downtime','/com.ec.prod.pd.screens/well_deferment/calcDefermentButton'
								   ,'/com.ec.prod.pd.screens/eqpm_downtime','/com.ec.prod.pd.screens/equip_downtime'
								   ,'/com.ec.prod.pd.screens/eqpm_downtime/new_masterEvent_button','/com.ec.prod.pd.screens/equip_downtime/new_masterEvent_button'
								   ,'/com.ec.prod.pd.screens/eqpm_downtime/removeFromGroupBtn','/com.ec.prod.pd.screens/equip_downtime/removeFromGroupBtn'
								   ,'/com.ec.prod.pd.screens/eqpm_downtime/moveToGroupBtn','/com.ec.prod.pd.screens/equip_downtime/moveToGroupBtn'
								   ,'/com.ec.prod.pd.screens/eqpm_downtime/addToGroupBtn','/com.ec.prod.pd.screens/equip_downtime/addToGroupBtn'
								   ,'/com.ec.prod.pd.screens/eqpm_downtime/verify_button','/com.ec.prod.pd.screens/equip_downtime/verify_button'
								   ,'/com.ec.prod.pd.screens/eqpm_downtime/approve_button','/com.ec.prod.pd.screens/equip_downtime/approve_button'
								   ,'/com.ec.frmw.co.screens/manage_object_groupmodel_nav/GROUPMODEL/PROCESSING_UNIT/TARGET/PROCESSING_UNIT/CLASS_NAME/PROCESSING_UNIT','/com.ec.sale.co.screens/processing_unit'
								   ,'/com.ec.prod.co.screens/chem_injection','/com.ec.frmw.co.screens/manage_object_groupmodel_nav/GROUPMODEL/CHEM_INJ_POINT/TARGET/CHEM_INJ_POINT/CLASS_NAME/CHEM_INJ_POINT'
								   ,'/com.ec.prod.po.screens/chemical_injection','/com.ec.prod.po.screens/daily_chem_inj_point_status'
								   ,'/com.ec.prod.co.screens/maintain_commercial_entity','/com.ec.prod.co.screens/commercial_entity'
								   ,'/com.ec.prod.co.netscreens/node_type_configuration','/com.ec.frmw.bs.calc.screens/maintain_calculation'
								   ,'/com.ec.frmw.co.screens/manage_object/CLASS_NAME/PROCESS_TRAIN','/com.ec.frmw.co.screens/manage_object_nav/CLASS_NAME/PROCESS_TRAIN'
                                   ,'/com.ec.frmw.co.screens/manage_object/CLASS_NAME/RESV_BLOCK','/com.ec.frmw.co.screens/manage_object_nav/CLASS_NAME/RESV_BLOCK'
                                   ,'/com.ec.frmw.co.screens/manage_object/CLASS_NAME/RESV_FORMATION','/com.ec.frmw.co.screens/manage_object_nav/CLASS_NAME/RESV_FORMATION'
                                   ,'/com.ec.frmw.co.screens/manage_object/CLASS_NAME/RESV_BLOCK_FORMATION','/com.ec.frmw.co.screens/manage_object_nav/CLASS_NAME/RESV_BLOCK_FORMATION'
								   ,'/com.ec.prod.pt.screens/performance_curve','/com.ec.prod.pt.screens/well_performance_curve'
								   ,'/com.ec.prod.wr.screens/sub_daily_oil_production_well_status','/com.ec.prod.wr.screens/sub_daily_oil_production_well_status/CLASS_NAME/PWEL_SUB_DAY_STATUS/DAILY_CLASS_NAME/PWEL_DAY_STATUS'
								   ,'/com.ec.frmw.bs.calc.screens/calculation_export','/DownloadService/com.ec.frmw.bs.calc.screens.model.web.CalculationExporter'
								   ,'/com.ec.frmw.bs.calc.screens/log_viewer','/DownloadService/com.ec.frmw.bs.calc.screens.model.web.CalcLogViewer'
								   ,'/com.ec.frmw.co.netscreens/eqnedit_insert_const_popup','/com.ec.frmw.bs.calc.screens/eqnedit_const_popup'
								   ,'/com.ec.frmw.co.netscreens/eqnedit_insert_obj_attr_popup','/com.ec.frmw.bs.calc.screens/eqnedit_insert_obj_attr_popup'
								   ,'/com.ec.frmw.co.screens/xsd_download_zip','/DownloadService/com.ec.frmw.is.ext.ws.XSDZipDownload'
								   ,'/com.ec.frmw.co.screens/xsd_download_single','/DownloadService/com.ec.frmw.is.ext.ws.XSDDownload'
								   ,'/com.ec.frmw.co.screens/downloadScheduleDetailedLog','/DownloadService/com.ec.frmw.scheduler.model.web.SchedulerDetailedLogDownload'
								   ,'/com.ec.frmw.co.netscreens/xls_calculation_export','/DownloadService/com.ec.frmw.bs.calc.screens.model.web.XlsCalculationExporter'
								   ,'/com.ec.pf.mainframe/aboutscreen','/xhtml/pages/about'
								   ,'/com.ec.revn.sp/fin_documents/TYPE/PERIOD','/com.ec.revn.sp/fin_documents_simple/TYPE/PERIOD'
								   , null
                                   );

  cursor c_access_old_list (cp_object_id varchar2) is
    select app_id
  ,      role_id
  ,      max(level_id) level_id
    from   pre_upg_t_basis_access
    where  object_id = cp_object_id
	and role_id<>'NO.ACCESS'
    group by app_id, role_id;

begin
  for c_change in c_changes loop
    begin
      if c_change.object_id_old <> c_change.object_id_new then
        for c_access_old in c_access_old_list( c_change.object_id_old ) loop
          begin
            insert into t_basis_access ( app_id, role_id, level_id, object_id, created_by ) 
            select c_access_old.app_id
            ,      c_access_old.role_id
            ,      c_access_old.level_id
            ,      c_change.object_id_new
            ,      'Upgrade 12.1'
            from   dual
            where  not exists ( select 'X'
                                from   t_basis_access  ac
                                where  ac.app_id    = c_access_old.app_id
                                and    ac.role_id   = c_access_old.role_id
                                and    ac.level_id  = c_access_old.level_id
                                and    ac.object_id = c_change.object_id_new
                              );
          end;
        end loop;
      end if;
    end;
  end loop;  
end;
/