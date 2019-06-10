CREATE OR REPLACE PACKAGE ecdp_trigger_utils IS

/**
 * This function is called from the generated AIUDT triggers on main object tables. 
 * The function keeps the objects_table entry for the relevant object in sync with 
 * the triggering event.
 * 
 * @param p_class_name 
 * @param p_object_id 
 * @param p_code 
 * @param p_start_date 
 * @param p_end_date 
 * @param p_created_by 
 * @param p_created_date
 * @param p_insert true for insert or update, false for delete
 */
PROCEDURE iudObject(p_class_name VARCHAR2, p_object_id VARCHAR2, p_code VARCHAR2, p_start_date DATE, p_end_date DATE, p_created_by VARCHAR2, p_created_date DATE, p_insert BOOLEAN DEFAULT TRUE);

/**
 * This function is called from the generated AIUDT triggers on object version tables. 
 * The function keeps the objects_version_table entry for the relevant object in sync  
 * with the triggering event.
 * 
 * @param p_class_name 
 * @param p_object_id 
 * @param p_name 
 * @param p_daytime 
 * @param p_end_date 
 * @param p_created_by 
 * @param p_created_date 
 * @param p_insert true for insert or update, false for delete
 */
PROCEDURE iudObjectVersion(p_class_name VARCHAR2, p_object_id VARCHAR2, p_name VARCHAR2, p_daytime DATE, p_end_date DATE, p_created_by VARCHAR2, p_created_date DATE, p_insert BOOLEAN DEFAULT TRUE);

END ecdp_trigger_utils;
/
