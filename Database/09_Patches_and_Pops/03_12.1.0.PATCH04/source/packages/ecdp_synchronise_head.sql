CREATE OR REPLACE PACKAGE ecdp_synchronise IS
/**
 * Refresh/sync objects_version_table and objects_table for the given object and its group model children.
 *
 * @param p_object_id
 */
PROCEDURE SyncObjectGroups(p_object_id VARCHAR2);

/**
 * Refresh/sync groups table for the given object and its group model children.
 * Sync groups table for the given object.
 *
 * @param p_class_name
 * @param p_object_id
 */
PROCEDURE SyncGroups(p_class_name VARCHAR2 DEFAULT NULL, p_object_id VARCHAR2 DEFAULT NULL);

/**
 * Refresh/sync objects_version_table, objects_table and groups table for the given object and its group model children.
 *
 * @param p_class_name
 * @param p_object_id
 */
PROCEDURE Synchronise(p_class_name VARCHAR2 DEFAULT NULL, p_object_id VARCHAR2 DEFAULT NULL);

/**
 * Refresh/sync objects_version_table and objects_table for a given class.
 *
 * @param p_class_name null value means sync all 
 * @param p_object_id unused. Always sync entire class.
 */
PROCEDURE SyncObjects(p_class_name VARCHAR2 DEFAULT NULL, p_object_id VARCHAR2 DEFAULT NULL);
END;
/
