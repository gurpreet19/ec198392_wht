CREATE OR REPLACE PACKAGE EcDp_Balance IS
/****************************************************************
** Package        :  EcDp_Balance, header part
**
** $Revision: 1.2 $
**
** Purpose        :  Provide special functions on Balance. Use EcDp_Objects for basis functions
**
** Documentation  :  www.energy-components.com
**
** Created  : 27.06.2006  Stian Skj�tad
**
** Modification history:
**
** Version  Date        Whom  Change description:
** -------  ------      ----- --------------------------------------
********************************************************************/

FUNCTION GetStreamDir(
   p_balance_id     VARCHAR2,
   p_object_id      VARCHAR2,
   p_daytime        DATE,
   p_node_id        VARCHAR2
) RETURN NUMBER;


FUNCTION GetBetweenNodeDirAc(
   p_balance_id     VARCHAR2,
   p_object_id      VARCHAR2,
   p_daytime        DATE,
   p_from_node_id   VARCHAR2,
   p_to_node_id     VARCHAR2
)

RETURN NUMBER;


END EcDp_Balance;