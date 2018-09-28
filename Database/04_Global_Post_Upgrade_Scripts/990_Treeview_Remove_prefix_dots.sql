update ctrl_tv_presentation
set    component_ext_name = regexp_replace(component_ext_name, '^\.{2}', '', 1, 0, 'i')
where  regexp_like(component_ext_name, '^\.{2}');
