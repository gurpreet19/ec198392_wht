CREATE OR REPLACE PACKAGE EcDp_Facility_Reference IS
/***************************************************************************************************
** Package        : EcDp_Facility_Reference, header part
**
** Release        : EC-12_1
**
** Purpose        : This package is responsible for facility constant information from fcty_reference_value.
**
**
**
** Created        : 2018-10-11 - rainanid
**
** Modification history:
**
** Date        Whom      Change description:
** ----------  --------  ---------------------------------------------------------------------------
** 2018-10-11  rainanid  Initial version.
***************************************************************************************************/

PROCEDURE copyToNewDaytime (
    p_class_name          VARCHAR2,
    p_object_id           VARCHAR2,
    p_daytime             DATE     DEFAULT NULL
);

END EcDp_Facility_Reference;