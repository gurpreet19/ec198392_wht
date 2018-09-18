CREATE OR REPLACE PACKAGE EcBp_Object_Class IS

/****************************************************************
** Package        :  EcBp_Object_Class, header part
**
** $Revision: 1.3 $
**
** Purpose        :  Provide basic functions on Objects
**
** Documentation  :  www.energy-components.com
**
** Created  : 08.04.2008  Nurliza Jailuddin
**
** Modification history:
**
** Date     Whom   		description:
** -------  ------ 		--------------------------------------
**  06.03.08 LIZ    	ECPD-4576: Added new procedures CopyObject, WellObject, StreamObject, TankObject
**  13.09.13 abdulmaw   ECPD-23509: Added new function  getObjName
**  01.11.13 abdulmaw 	ECPD-22183: Added new function  copyNewRecord
*****************************************************************/
PROCEDURE CopyObject(
    p_class_name           VARCHAR2,
    p_object_id            VARCHAR2,
    p_daytime              DATE,
    p_new_code             VARCHAR2,
    p_new_name             VARCHAR2,
    p_new_date             DATE
);

PROCEDURE WellObject(
          p_ori_id         VARCHAR2,
          p_new_id         VARCHAR2,
          p_new_code       VARCHAR2,
          p_new_name       VARCHAR2,
          p_new_date       DATE,
          p_daytime        DATE
);

PROCEDURE TankObject(
          p_ori_id         VARCHAR2,
          p_new_id         VARCHAR2,
          p_new_code       VARCHAR2,
          p_new_name       VARCHAR2,
          p_new_date       DATE,
          p_daytime        DATE
);

PROCEDURE StreamObject(
          p_ori_id         VARCHAR2,
          p_new_id         VARCHAR2,
          p_new_code       VARCHAR2,
          p_new_name       VARCHAR2,
          p_new_date       DATE,
          p_daytime        DATE
);

FUNCTION getObjName(
  p_object_id VARCHAR2,
  p_object_type VARCHAR2,
  p_daytime DATE
)
RETURN VARCHAR2;

PROCEDURE copyNewRecord(
  p_object_id VARCHAR2,
  p_daytime DATE,
  p_valid_from DATE,
  p_todate DATE
);

END EcBp_Object_Class;