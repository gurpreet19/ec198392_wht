CREATE OR REPLACE PACKAGE EcDp_Objects_Partition IS

/****************************************************************
** Package        :  EcDp_Objects_Partition, body part
**
** $Revision: 1.3.26.1 $
**
** Purpose        :  Provide basic functions on objects
**
** Documentation  :  www.energy-components.com
**
** Created  : 22.07.2005  Tor-Erik Hauge
**
** Modification history:
**
**  Date     Whom  					Change description:
**  ------   ----- 					--------------------------------------
**  28.08.2013 Lim Chun Guan 	     Add new function finderObjectPartition
****************************************************************/

FUNCTION objectPartOfPartition(
  p_daytime     DATE,
  p_object_id	VARCHAR2,
  p_class_name  VARCHAR2,
  p_user	    VARCHAR2)
RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (getSumEstDILRate, WNDS, WNPS, RNPS);

PROCEDURE validatePartition(p_T_BASIS_ACCESS_ID NUMBER, P_ATTRIBUTE_NAME VARCHAR2);

FUNCTION hasDirectObjectAccess(p_user_id VARCHAR2,p_object_id VARCHAR2, p_class_name VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;

FUNCTION finderObjectPartition(
  p_daytime     DATE,
  p_object_id	VARCHAR2,
  p_class_name  VARCHAR2,
  p_user	    VARCHAR2)
RETURN NUMBER;

END EcDp_Objects_Partition;