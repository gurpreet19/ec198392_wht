CREATE OR REPLACE PACKAGE EcDp_Tdev_Ref_Values IS

/****************************************************************
** Package        :  EcDp_Tdev_Ref_Values
**
** $Revision: 1.3 $
**
** Purpose        :  This package is responsible test device constants from tdev_reference_value
**
** Documentation  :  www.energy-components.com
**
** Created  : 09.09.2015 Dhavaalo
**
** Modification history:
**
** Version  Date        Whom      Change description:
** -------  ------      -----     -----------------------------------
** 1.0      09.09.2015  dhavaalo  Initial version
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

END EcDp_Tdev_Ref_Values;