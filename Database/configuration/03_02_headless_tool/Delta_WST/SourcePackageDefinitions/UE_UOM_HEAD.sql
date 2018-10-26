CREATE OR REPLACE PACKAGE UE_UOM IS
/******************************************************************************
** Package        :  UE_UOM, header part
**
** $Revision:
**
** Purpose        :  For use when linear uom is not sufficient
**
** Documentation  :
**
** Created        :  24.11.2011 Erik Hodne
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
** 24-11-11    EH    Intial Version
********************************************************************/

FUNCTION CONVERT(p_from_unit VARCHAR2,
                          p_to_unit VARCHAR2,
                          p_value NUMBER,
                          p_precision NUMBER DEFAULT NULL,
                          p_object_id VARCHAR2 DEFAULT NULL,
                          p_daytime VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

END UE_UOM;