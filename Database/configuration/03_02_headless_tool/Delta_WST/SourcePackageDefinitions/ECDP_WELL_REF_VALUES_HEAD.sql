CREATE OR REPLACE PACKAGE EcDp_Well_Ref_Values IS

/****************************************************************
** Package        :  EcDp_Well_Ref_Values
**
** $Revision: 1.3 $
**
** Purpose        :  This package is responsible well constants from well_reference_value
**
** Documentation  :  www.energy-components.com
**
** Created  : 08.02.2007 Arief Zaki
**
** Modification history:
**
** Version  Date        Whom      Change description:
** -------  ------      -----     -----------------------------------
** 9.2      08.02.2007  zakiiari  First version
** 9.3      29.08.2007  kaurrnar  ECPD6294: Added
*****************************************************************/

PROCEDURE copyToNewDaytime (
   p_object_id      well.object_id%TYPE,
   p_daytime        DATE     DEFAULT NULL);

FUNCTION getAttribute (
   p_object_id      well.object_id%TYPE,
   p_attribute      VARCHAR2,
   p_daytime        DATE)
RETURN NUMBER;

FUNCTION getAttributeValue(
   p_object_id      well.object_id%TYPE,
   p_column_name    VARCHAR2,
   p_table_name     VARCHAR2,
   p_daytime        DATE DEFAULT NULL)
RETURN NUMBER;

END EcDp_Well_Ref_Values;