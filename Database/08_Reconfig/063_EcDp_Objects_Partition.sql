create or replace PACKAGE EcDp_Objects_Partition IS

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
/
create or replace PACKAGE BODY EcDp_Objects_Partition IS

/****************************************************************
** Package        :  EcDp_Objects_Partition, body part
**
** $Revision: 1.8 $
**
** Purpose        :  Provide basic functions on objects
**
** Documentation  :  www.energy-components.com
**
** Created  : 19.01.2004  Sven Harald Nilsen
**
** Modification history:
**
**  Date       Whom  		Change description:
**  ------     ----- 		--------------------------------------
**  19.03.2004 SHN   		Added procedure ValidateValues
**  09.11.2005 AV  			Changed references to WriteTempText from EcDp_genClasscode to EcDp_DynSQL (code cleanup)
**  24.07.2013 Mawaddah 	Add new function finderObjectPartition
**  05.08.2013 Lim Chun Guan 	Modified finderObjectPartition
**  22.10.2013 abdulmaw 	ECPD-25799: Modified finderObjectPartition
****************************************************************/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Prcedure       : validatePartition                                                                 --
-- Description    :                                                                              --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
PROCEDURE validatePartition(p_T_BASIS_ACCESS_ID NUMBER, P_ATTRIBUTE_NAME VARCHAR2)
--<EC-DOC>
IS
CURSOR c (cp_T_BASIS_ACCESS_ID NUMBER, cP_ATTRIBUTE_NAME VARCHAR2) IS
SELECT operator, ROWNUM
FROM t_basis_object_partition
WHERE t_basis_access_id = cp_T_BASIS_ACCESS_ID
	AND ATTRIBUTE_NAME = cP_ATTRIBUTE_NAME;

	lv_all	BOOLEAN := FALSE;

BEGIN
	FOR cur IN c (p_T_BASIS_ACCESS_ID, P_ATTRIBUTE_NAME) LOOP
		IF (cur.operator = 'ALL') THEN
			lv_all := TRUE;
		END IF;

		IF (lv_all AND cur.ROWNUM > 1) THEN
			Raise_Application_Error(-20000,'No more partitions can be added for the attribute ('||P_ATTRIBUTE_NAME||') when there exist an ALL operator');
		END IF;
	END LOOP;

END validatePartition;

END EcDp_Objects_Partition;
/