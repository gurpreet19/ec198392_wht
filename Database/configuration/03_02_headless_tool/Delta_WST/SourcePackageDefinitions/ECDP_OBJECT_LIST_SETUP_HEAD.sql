CREATE OR REPLACE PACKAGE EcDp_Object_List_Setup IS

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION ValidateOpenTargetListArgs(
        p_target_daytime_string            VARCHAR2 DEFAULT NULL,
        p_target_object_list_name          VARCHAR2 DEFAULT NULL
        )
    RETURN VARCHAR2;

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION GetTargetObjectID(
        p_target_object_list_id            VARCHAR2 DEFAULT NULL,
        p_target_object_list_name          VARCHAR2 DEFAULT NULL
        )
    RETURN VARCHAR2;

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION CopyToTargetObjectList(
        p_user_id                          VARCHAR2,
        p_source_generic_class_name        VARCHAR2 DEFAULT NULL,
        p_source_object_list_id            VARCHAR2 DEFAULT NULL,
        p_target_daytime_string            VARCHAR2 DEFAULT NULL,
        p_target_object_list_name          VARCHAR2 DEFAULT NULL,
        p_target_object_list_id            VARCHAR2 DEFAULT NULL,
        p_delete_from_currrent_ind         VARCHAR2 DEFAULT NULL,
        p_set_end_date_currrent_ind        VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2;

END EcDp_Object_List_Setup;