CREATE OR REPLACE PACKAGE EcDp_Well_Hookup_Alloc IS
/****************************************************************
** Package        :  EcDp_Well_Hookup_Alloc, header part
**
** $Revision: 1.1 $
**
** Purpose        :  Provides well hookup alloc data service
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
FUNCTION sumWellHookAllocProdVolume(
    p_object_id        well_hookup.object_id%TYPE,
    p_phase    VARCHAR2,
    p_daytime  DATE)

RETURN NUMBER;

--

FUNCTION sumWellHookAllocProdMass(
    p_object_id        well_hookup.object_id%TYPE,
    p_phase    VARCHAR2,
    p_daytime  DATE)

RETURN NUMBER;

--

FUNCTION sumWellHookAllocInjVolume(
    p_object_id        well_hookup.object_id%TYPE,
    p_phase    VARCHAR2,
    p_daytime  DATE)

RETURN NUMBER;

--

FUNCTION sumWellHookAllocInjMass(
    p_object_id        well_hookup.object_id%TYPE,
    p_phase    VARCHAR2,
    p_daytime  DATE)

RETURN NUMBER;

--

END EcDp_Well_Hookup_Alloc;