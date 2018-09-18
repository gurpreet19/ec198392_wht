CREATE OR REPLACE PACKAGE EcDp_Field_Alloc IS
/****************************************************************
** Package        :  EcDp_Field_Alloc, header part
**
** $Revision: 1.1 $
**
** Purpose        :  Provides geo field alloc data service
**
** Documentation  :  www.energy-components.com
**
** Created  : 24.09.09  Siti Azura Alias
**
** Modification history:
**
** Date     Whom Change description:
** ------   ---- --------------------------------------
*****************************************************************/
FUNCTION sumFieldAllocProdVolume(
    p_object_id        field.object_id%TYPE,
    p_phase    VARCHAR2,
    p_daytime  DATE)

RETURN NUMBER;

--

FUNCTION sumFieldAllocProdMass(
    p_object_id        field.object_id%TYPE,
    p_phase    VARCHAR2,
    p_daytime  DATE)

RETURN NUMBER;

--

FUNCTION sumFieldAllocInjVolume(
    p_object_id        field.object_id%TYPE,
    p_phase    VARCHAR2,
    p_daytime  DATE)

RETURN NUMBER;

--

FUNCTION sumFieldAllocInjMass(
    p_object_id        field.object_id%TYPE,
    p_phase    VARCHAR2,
    p_daytime  DATE)

RETURN NUMBER;

--

END EcDp_Field_Alloc;