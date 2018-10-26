CREATE OR REPLACE PACKAGE body EcBp_Tag_Mapping IS

/****************************************************************
** Package        :   body part
**
** $Revision: 1.4 $
**
** Purpose        :  This package is responsible to generate new
**                   mapping for an object based on an existing object.
**
** Documentation  :  www.energy-components.com
**
** Created        :
**
** Modification history:
**
** Version  Date        Whom         Change description:
** -------  ----------  --------     --------------------------------------
** 1.0      28-04-2006  Lau          Added generateMapping
*****************************************************************/

PROCEDURE generateMapping(p_object_id VARCHAR2, p_new_object_id VARCHAR2, p_last_transfer DATE)
--</EC-DOC>
IS
 BEGIN
    IF p_object_id is null THEN RAISE_APPLICATION_ERROR (-20692, 'Object Name is not set');
    END IF;
    IF p_new_object_id is null THEN RAISE_APPLICATION_ERROR (-20693, 'New Mapping Object Name is not set');
    END IF;
    IF p_last_transfer is null THEN RAISE_APPLICATION_ERROR (-20694, 'Last Transfer Date is not set');
    END IF;
    IF p_object_id = p_new_object_id THEN RAISE_APPLICATION_ERROR (-20695, 'Object Name cannot be the same as New Mapping Object Name');
    END IF;

    INSERT INTO v_trans_config (template_no, template_code, source_id,
                                from_unit, to_unit, data_class, attribute,
                                pk_attr_1, pk_val_1, pk_attr_2, pk_val_2,
                                pk_attr_3, pk_val_3, pk_attr_4, pk_val_4,
                                pk_attr_5, pk_val_5, pk_attr_6, pk_val_6,
								pk_attr_7, pk_val_7, pk_attr_8, pk_val_8,
								pk_attr_9, pk_val_9, pk_attr_10, pk_val_10,
								active, description, last_transfer)
        (SELECT template_no, template_code, source_id,
                from_unit, to_unit, data_class, attribute,
                pk_attr_1, p_new_object_id, pk_attr_2, pk_val_2,
                pk_attr_3, pk_val_3, pk_attr_4, pk_val_4,
                pk_attr_5, pk_val_5, pk_attr_6, pk_val_6,
				pk_attr_7, pk_val_7, pk_attr_8, pk_val_8,
				pk_attr_9, pk_val_9, pk_attr_10, pk_val_10,
				active, description,
                p_last_transfer
        FROM v_trans_config
        WHERE pk_attr_1='OBJECT_ID'
        AND pk_val_1=p_object_id);

END generateMapping;

END;