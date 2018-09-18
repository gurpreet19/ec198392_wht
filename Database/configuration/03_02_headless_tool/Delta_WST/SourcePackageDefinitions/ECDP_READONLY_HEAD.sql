CREATE OR REPLACE PACKAGE EcDp_ReadOnly IS
/******************************************************************************
**
** Purpose:
** This package is used in conjunction with object partitioning. It performs read-only object access checks
** on classes calling EcDp_ReadOnly.ReadOnlyLockRule from their lock rule. Updates are denied if an object is read-only.
**
** A note on read-only precedence:
**
** In the object partition setup it's possible to add the same object to multiple roles granted to the same user
** and set the object to read-only in some of the roles and non-read-only in the others.
** The 'Object Partition Read Only Precedence' EC Setting decides how to evaluate read-only access in this situation.
** If 'Y' the object will be read-only, i.e. the read-only partition setting takes precedence.
** If 'N' the object will be non-read-only (editable), i.e. the non-read-only partition setting takes precedence.
**
** If you set 'Object Partition Read Only Precedence' = 'N', keep in mind that this will also allow child objects to
** override parent object read-only access, thus making it possible to edit e.g. a facility even if the parent
** area is read-only.
**
******************************************************************************/

PROCEDURE ReadOnlyLockRule(p_operation VARCHAR2, p_new_lock_columns IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns IN OUT EcDp_Month_Lock.column_list);
FUNCTION  IsReadOnly(p_user_name VARCHAR2, p_object_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2;

END EcDp_ReadOnly;