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
PRAGMA RESTRICT_REFERENCES (sumFieldAllocProdVolume, WNDS, WNPS, RNPS);

--

FUNCTION sumFieldAllocProdMass(
    p_object_id        field.object_id%TYPE,
    p_phase    VARCHAR2,
    p_daytime  DATE)

RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (sumFieldAllocProdMass, WNDS, WNPS, RNPS);

--

FUNCTION sumFieldAllocInjVolume(
    p_object_id        field.object_id%TYPE,
    p_phase    VARCHAR2,
    p_daytime  DATE)

RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (sumFieldAllocInjVolume, WNDS, WNPS, RNPS);

--

FUNCTION sumFieldAllocInjMass(
    p_object_id        field.object_id%TYPE,
    p_phase    VARCHAR2,
    p_daytime  DATE)

RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (sumFieldAllocInjMass, WNDS, WNPS, RNPS);

--

END EcDp_Field_Alloc;