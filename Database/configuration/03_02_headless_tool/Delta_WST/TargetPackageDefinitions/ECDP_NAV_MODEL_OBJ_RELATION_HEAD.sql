CREATE OR REPLACE PACKAGE EcDp_nav_model_obj_relation IS
/****************************************************************
** Package        :  EcDp_nav_model_obj_relation, header part
**
** $Revision: 1.4 $
**
** Purpose        :  Maintain persisted group model structure in nav_model_obj_relation
**
** Documentation  :  www.energy-components.com
**
** Created  : 03.08.2007  Arild Vervik
**
** Modification history:
**

** Date     Whom   Change description:
** -------- ------ ------ --------------------------------------
**
*****************************************************************/



PROCEDURE Syncronize(p_operation          VARCHAR2 DEFAULT NULL,
                     p_from_class_name    VARCHAR2 DEFAULT NULL,
                     p_to_class_name      VARCHAR2 DEFAULT NULL,
                     p_role_name          VARCHAR2 DEFAULT NULL,
                     p_new_ref_object_id  VARCHAR2 DEFAULT NULL,
                     p_old_ref_object_id  VARCHAR2 DEFAULT NULL,
                     p_object_id          VARCHAR2 DEFAULT NULL,
                     p_object_start_date  DATE     DEFAULT NULL,
                     p_object_end_date    DATE     DEFAULT NULL,
                     p_daytime            DATE     DEFAULT NULL,
                     p_end_date           DATE     DEFAULT NULL,
                     p_ignore_error       VARCHAR2 DEFAULT 'N'
                     );

PROCEDURE Syncronize_model(p_model VARCHAR2);


END;