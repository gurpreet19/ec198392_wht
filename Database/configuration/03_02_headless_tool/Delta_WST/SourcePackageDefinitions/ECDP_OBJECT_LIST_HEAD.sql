CREATE OR REPLACE PACKAGE EcDp_Object_List IS

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION IsInObjectList(
         p_code                             objects.code%TYPE
        ,p_code_class_name                  objects.class_name%TYPE
        ,p_code_ec_type                     prosty_codes.code_type%TYPE
        ,p_check_linked_ec_code             ecdp_revn_common.T_BOOLEAN_STR
        ,p_object_list_code                 object_list.object_code%TYPE
        ,p_daytime                          object_list_version.daytime%TYPE
        )
    RETURN ecdp_revn_common.T_BOOLEAN_STR;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION VerifySplitShare(
         p_object_id                        object_list.object_id%TYPE
        ,p_daytime                          object_list_setup.daytime%TYPE
        )
    RETURN ecdp_revn_common.T_BOOLEAN_STR;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    PROCEDURE CheckInsertDuplicate(
                                p_object_id                        object_list.object_id%TYPE
                               ,p_generic_object_code              object_list_setup.generic_object_code%TYPE
                               ,p_daytime                          object_list_setup.daytime%TYPE
                               ,p_end_date                         object_list_setup.daytime%TYPE
                               ,p_relational_obj_code              object_list_setup.relational_obj_code%TYPE
                               ,p_rec_id                           object_list_setup.rec_id%TYPE
                               );

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    PROCEDURE COPY_GROUP (p_object_id VARCHAR2 , p_group NUMBER) ;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    PROCEDURE insObject (
         p_object_code                     VARCHAR2
        ,p_object_class                    VARCHAR2
        ,p_daytime                         DATE
        ,p_end_date                        DATE DEFAULT NULL
        ,p_object_name                     VARCHAR2 DEFAULT NULL
		,p_desc                            VARCHAR2 DEFAULT NULL
		,p_gl_code                         VARCHAR2 DEFAULT NULL
        );
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------

    PROCEDURE ObjectListUpload ( p_obj_list_rec V_OBJECT_LIST_UPLOAD%ROWTYPE ) ;

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------

END EcDp_Object_List;