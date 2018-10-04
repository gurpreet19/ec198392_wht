CREATE OR REPLACE package EcDp_Class_Validation is
/****************************************************************
** Package        :  EcDp_Class_Validation, header part
**
** $Revision: 1.5 $
**
** Purpose        :  Provide special procedures to create new version of classes and delete the existing version of classes
**
** Documentation  :  www.energy-components.com
**
** Created        : 15.03.2006  SeongKok
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- --------------------------------------
** 23.03.07     Seongkok    Added two new methods newVersionObject and deleteVersionObject
** 03.05.2010   oonnnng    ECPD-14276: Added getClassAttributeViewLabelHead() function.
** 18.05.2010   oonnnng    ECPD-14541: Added addMissingAttrClass() and addMissingAttrObject() function.
*****************************************************************/

  PROCEDURE newVersionClass (
   p_class_name VARCHAR2,
   p_daytime DATE,
   p_user VARCHAR2 DEFAULT NULL);

  PROCEDURE deleteVersionClass (
   p_class_name VARCHAR2,
   p_daytime DATE);

  PROCEDURE newVersionObject (
   p_class_name VARCHAR2,
   p_object_id VARCHAR2,
   p_daytime DATE,
   p_user VARCHAR2 DEFAULT NULL);

  PROCEDURE deleteVersionObject (
   p_class_name VARCHAR2,
   p_object_id VARCHAR2,
   p_daytime DATE);

  PROCEDURE copyValidation(
   p_copy_from varchar2,
   p_copy_to   varchar2,
   p_from_daytime   date,
   p_to_daytime date);

  FUNCTION getClassAttributeViewLabelHead(
           p_class_name class_attr_presentation.class_name%TYPE,
           p_attribute_name class_attr_presentation.attribute_name%TYPE)
  RETURN VARCHAR2;

  PROCEDURE addMissingAttrClass (
     p_class_name VARCHAR2,
     p_daytime DATE,
     p_user VARCHAR2 DEFAULT NULL);

  PROCEDURE addMissingAttrObject (
     p_class_name VARCHAR2,
     p_object_id  VARCHAR2,
     p_daytime DATE,
     p_user VARCHAR2 DEFAULT NULL);

end EcDp_Class_Validation;