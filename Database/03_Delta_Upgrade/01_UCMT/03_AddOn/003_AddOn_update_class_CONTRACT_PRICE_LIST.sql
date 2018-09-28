update class_attr_property_cnfg
set    property_value =  'EcDp_Price.isEditable(object_id, price_concept_code, price_element_code, daytime) || '';'' || DECODE(PRICE_DECIMALS, NULL, NULL, ''viewformatmask=#,##0'' || DECODE(PRICE_DECIMALS,''.'','''',PRICE_DECIMALS))'
where  class_name = 'CONTRACT_PRICE_LIST' 
and    attribute_name = 'ADJ_PRICE_VALUE'
and    property_code = 'PresentationSyntax'
and    owner_cntx = 0
and    property_type = 'DYNAMIC_PRESENTATION'
and    presentation_cntx =  '/EC'
and    property_value <> 'EcDp_Price.isEditable(object_id, price_concept_code, price_element_code, daytime) || '';'' || DECODE(PRICE_DECIMALS, NULL, NULL, ''viewformatmask=#,##0'' || DECODE(PRICE_DECIMALS,''.'','''',PRICE_DECIMALS))'
;

update class_attr_property_cnfg
set    property_value =  'DECODE(PRICE_DECIMALS, NULL, NULL, ''viewformatmask=#,##0'' || DECODE(PRICE_DECIMALS,''.'','''',PRICE_DECIMALS))'
where  class_name = 'CONTRACT_PRICE_LIST' 
and    attribute_name = 'CALC_PRICE_VALUE'
and    property_code = 'PresentationSyntax'
and    owner_cntx = 0
and    property_type = 'DYNAMIC_PRESENTATION'
and    presentation_cntx =  '/EC'
and    property_value <> 'DECODE(PRICE_DECIMALS, NULL, NULL, ''viewformatmask=#,##0'' || DECODE(PRICE_DECIMALS,''.'','''',PRICE_DECIMALS))'
;
