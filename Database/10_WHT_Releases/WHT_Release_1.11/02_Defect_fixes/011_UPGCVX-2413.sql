
insert into bf_component_action (bf_component_action_no, bf_component_no, name, url)
values (5018, (select bf_component_no from bf_component where bf_code = 'TO.0009' and comp_code = 'nom_docs'), 'Generate Documents', null);

insert into control_point_link (control_point_link_no, object_id, bf_component_action_no, business_action_no, active_ind)
values (5001, ec_control_point.object_id_by_uk('CargoAnalysisTrigger'), (select bf_component_action_no from bf_component_action where name = 'Generate Documents'), (select business_action_no from business_action where name = 'CargoDocGenerate'), 'Y');
