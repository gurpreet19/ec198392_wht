CREATE OR REPLACE PACKAGE EcDp_Objects_Partition IS

/****************************************************************
** Package        :  EcDp_Objects_Partition, body part
**
** $Revision: 1.5 $
**
** Purpose        :  Provide basic functions on objects
**
** Documentation  :  www.energy-components.com
**
** Created  : 22.07.2005  Tor-Erik Hauge
**
** Modification history:
**
**  Date     Whom                Change description:
**  ------   -----             --------------------------------------
**  24.07.2013 Mawaddah 	     Add new function finderObjectPartition
**  05.08.2013 Lim Chun Guan 	 Modified finderObjectPartition
****************************************************************/

PROCEDURE validatePartition(p_T_BASIS_ACCESS_ID NUMBER, P_ATTRIBUTE_NAME VARCHAR2);

END EcDp_Objects_Partition;