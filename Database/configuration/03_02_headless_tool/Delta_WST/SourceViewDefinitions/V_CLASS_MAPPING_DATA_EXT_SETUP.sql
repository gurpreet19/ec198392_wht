CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CLASS_MAPPING_DATA_EXT_SETUP" ("OBJECT_ID", "DAYTIME", "PARAMETER_NAME", "VALUE_CATEGORY", "VALUE", "REPORT_REF_ITEM_ID") AS 
  SELECT
-- This view is called in from DataFilterParameterValueInfoRepository java to process the class mappings.
-- If a Cost Mapping is based on Report Reference Group, then consider the class mapping filter parameters
-- configured at Cost Mapping Setup as well as look for any specific class mapping filter parameter configured
-- at Report Reference Item  connected with the Report Reference Group which is linked with the Cost Mapping.
--
-- So First SELECT will retrive the parameters which are configured at Cost Mapping Setup screen and no setup found
-- for same parameter at Report Reference Group Setup screen
	   jou.object_id,
       jou.daytime,
       jou.parameter_name,
       jou.value_category,
       jou.value,
       '*ALL_REPORT_REF*' report_ref_item_id
FROM journal_map_data_ext_setup jou
WHERE NOT EXISTS ( SELECT 1
                     FROM cost_mapping_version c,
                          report_ref_item_version i,
                          report_ref_grp_class_setup cl
                    WHERE i.object_id = cl.object_id
                      AND i.daytime = cl.daytime
                      AND i.report_ref_group_id = c.report_ref_group_id
                      AND c.object_id = jou.object_id
                      AND cl.parameter_name = jou.parameter_name
		  )
UNION
SELECT
-- This SELECT will retrive the parameters which are configured at Report Reference Group Setup screen.
-- However, for class mapping filter parameters if the Value Type at Cost Mapping setup is set to 'From Ref Group'
-- then only pick the setup configured at Report Reference Group Setup
-- else take the parameter configuration from Cost Mapping Setup
	   jou.object_id,
       jou.daytime,
       jou.parameter_name,
       CASE WHEN jou.value_category = 'REPORT_REF_GROUP'
            THEN grp.value_category
            ELSE jou.value_category
       END value_category,
       CASE WHEN jou.value_category = 'REPORT_REF_GROUP'
            THEN grp.parameter_value
            ELSE jou.value
       END value,
       grp.object_id report_ref_item_id
FROM journal_map_data_ext_setup jou,
     (SELECT c.object_id cost_mapping_id,
             c.report_ref_group_id,
             cl.object_id,
             cl.daytime,
             cl.parameter_name,
             cl.value_category,
             cl.parameter_value
        FROM cost_mapping_version c,
             report_ref_item_version i,
             report_ref_grp_class_setup cl
       WHERE i.object_id = cl.object_id
         AND i.daytime = cl.daytime
         AND i.report_ref_group_id = c.report_ref_group_id) grp
WHERE jou.object_id = grp.cost_mapping_id
AND jou.parameter_name = grp.parameter_name