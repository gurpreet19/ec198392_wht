create or replace PACKAGE UE_CT_MESSAGE_GENERATION IS
/****************************************************************
** Package        :  UE_CT_MESSAGE_GENERATION, header part
**
** Purpose        :  Helper functions for message generation
**
** Created        :  24-OCT-2014  Samuel Webb
**
** Modification history:
**
** Date        Whom  Change description:
** ---------   ----- --------------------------------------
** 24-OCT-14   SWGN  Initial version, adapted from initial Gorgon deployment, adjusted for standardization and 10.3 SP5
** 23-JAN-2019   kolleadr   Chevron Bulk Upgrade to EC 12.1  Added function hasDirectObjectAccess
*****************************************************************/

FUNCTION MessageParameterValid(p_message_distribution_no NUMBER, p_daytime DATE) RETURN VARCHAR2;
FUNCTION hasDirectObjectAccess(p_user_id VARCHAR2,p_object_id VARCHAR2, p_class_name VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

END UE_CT_MESSAGE_GENERATION;
/

create or replace PACKAGE BODY UE_CT_MESSAGE_GENERATION IS
/****************************************************************
** Package        :  UE_CT_MESSAGE_GENERATION, header part
**
** Purpose        :  Helper functions for message generation
**
** Created        :  24-OCT-2014  Samuel Webb
**
** Modification history:
**
** Date        Whom  Change description:
** ---------   ----- --------------------------------------
** 24-OCT-14   SWGN  Initial version, adapted from initial Gorgon deployment, adjusted for standardization and 10.3 SP5
** 23-JAN-2019   kolleadr   Chevron Bulk Upgrade to EC 12.1  Added function hasDirectObjectAccess
*****************************************************************/

FUNCTION MessageParameterValid(p_message_distribution_no NUMBER, p_daytime DATE) RETURN VARCHAR2
IS

    CURSOR parameter_cursor IS
    SELECT *
     FROM message_distr_param
     WHERE message_distribution_no = p_message_distribution_no
     AND parameter_type = 'EC_OBJECT_TYPE'
     ORDER BY parameter_name desc;

BEGIN

    FOR item IN parameter_cursor LOOP
		IF EC_CTRL_SYSTEM_ATTRIBUTE.ATTRIBUTE_TEXT(p_daytime, 'ENABLE_CP_SCEN_DATE_VAL', '<=')='Y' THEN
			-- Is this object alive on this date? Only do this check if the object is alive as of today
			IF ecdp_objects.getobjstartdate(item.parameter_value) <= trunc(ecdp_date_time.getCurrentSysdate) AND (p_daytime < ecdp_objects.getobjstartdate(item.parameter_value) OR p_daytime > nvl(ecdp_objects.getobjenddate(item.parameter_value), p_daytime + 1)) THEN
				RETURN 'N';
			END IF;
		END IF;
        -- Does user have access to this object?
        IF EcDp_Context.getAppUser IS NOT NULL AND hasDirectObjectAccess(EcDp_Context.getAppUser, item.parameter_value, ecdp_objects.getobjclassname(item.parameter_value)) = 'N' THEN
            RETURN 'N';
        END IF;
    END LOOP;

    RETURN 'Y';
END;

FUNCTION hasDirectObjectAccess(p_user_id VARCHAR2, p_object_id VARCHAR2, p_class_name VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
IS
    access_flag VARCHAR2(1) := 'N';

    CURSOR useraccess_cursor IS
    SELECT aobj.*
     FROM acl_objects aobj, t_basis_userrole tur
     WHERE aobj.role_id = tur.role_id
     AND tur.user_id = p_user_id
     AND aobj.class_name = p_class_name
     AND aobj.object_id = p_object_id;

BEGIN

    FOR item IN useraccess_cursor LOOP
        -- User is connected to a role that has access to the object
        access_flag := 'Y';
    END LOOP;
    RETURN access_flag;
END;

END UE_CT_MESSAGE_GENERATION;
/